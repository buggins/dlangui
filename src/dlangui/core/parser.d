module dlangui.core.parser;

import dlangui.core.linestream;
import dlangui.widgets.widget;
import dlangui.widgets.metadata;
import std.conv : to;

class ParserException : Exception {
    protected string _msg;
    protected string _file;
    protected int _line;
    protected int _pos;

    @property string file() { return _file; }
    @property string msg() { return _msg; }
    @property int line() { return _line; }
    @property int pos() { return _pos; }

    this(string msg, string file, int line, int pos) {
        super(msg ~ " at " ~ _file ~ " line " ~ to!string(line) ~ " column " ~ to!string(pos));
        _msg = msg;
        _file = file;
        _line = line;
        _pos = pos;
    }
}


enum TokenType : ushort {
    /// end of file
    eof,
    /// end of line
    eol,
    /// whitespace
    whitespace,
    /// string literal
    str,
    /// integer literal
    integer,
    /// floating point literal
    floating,
    /// comment
    comment,
    /// ident
    ident,
    /// error
    error,
    // operators
    /// : operator
    colon,
    /// . operator
    dot,
    /// ; operator
    semicolon,
    /// , operator
    comma,
    /// [
    curlyOpen,
    /// ]
    curlyClose,
    /// (
    open,
    /// )
    close,
    /// [
    squareOpen,
    /// ]
    squareClose,
}

struct Token {
    TokenType type;
    ushort line;
    ushort pos;
    string text;
    union {
        int intvalue;
        double floatvalue;
    }
}

/// simple tokenizer for DlangUI ML
class Tokenizer {
    protected LineStream  _lines;

    dchar[] _lineText;
    ushort _line;
    ushort _pos;
    int _len;
    dchar _prevChar;
    string _filename;

    Token _token;

	enum : int {
		EOF_CHAR = 0x001A,
		EOL_CHAR = 0x000A
	};

    this(string source, string filename = "") {
        _filename = filename;
        _lines = LineStream.create(source, filename);
        _lineText = _lines.readLine();
        _len = _lineText.length;
        _line = 0;
        _pos = 0;
        _prevChar = 0;
    }

    ~this() {
        destroy(_lines);
        _lines = null;
    }

    protected dchar peekChar() {
        if (_pos < _len)
            return _lineText[_pos];
        else if (_lineText is null)
            return EOF_CHAR;
        return EOL_CHAR;
    }

    protected dchar peekNextChar() {
        if (_pos < _len - 1)
            return _lineText[_pos + 1];
        else if (_lineText is null)
            return EOF_CHAR;
        return EOL_CHAR;
    }

    protected dchar nextChar() {
        if (_pos < _len)
            _prevChar = _lineText[_pos++];
        else if (_lineText is null)
            _prevChar = EOF_CHAR;
        else {
            _lineText = _lines.readLine();
            _len = _lineText.length;
            _line++;
            _pos = 0;
            _prevChar = EOL_CHAR;
        }
        return _prevChar;
    }

    protected dchar skipChar() {
        nextChar();
        return peekChar();
    }

    protected void setTokenStart() {
        _token.pos = _pos;
        _token.line = _line;
        _token.text = null;
        _token.intvalue = 0;
    }

    protected ref const(Token) parseEof() {
        _token.type = TokenType.eof;
        return _token;
    }

    protected ref const(Token) parseEol() {
        _token.type = TokenType.eol;
        nextChar();
        return _token;
    }

    protected ref const(Token) parseWhiteSpace() {
        _token.type = TokenType.whitespace;
        for(;;) {
            dchar ch = skipChar();
            if (ch != ' ' && ch != '\t')
                break;
        }
        return _token;
    }

    static bool isAlpha(dchar ch) {
        return (ch >= 'a' && ch <= 'z') || (ch >= 'A' && ch <= 'Z') || ch == '_';
    }

    static bool isNum(dchar ch) {
        return (ch >= '0' && ch <= '9');
    }

    static bool isAlphaNum(dchar ch) {
        return isNum(ch) || isAlpha(ch);
    }

    private char[] _stringbuf;
    protected ref const(Token) parseString() {
        _token.type = TokenType.str;
        skipChar(); // skip "
        bool lastBackslash = false;
        _stringbuf.length = 0;
        for(;;) {
            dchar ch = skipChar();
            if (ch == '\"') {
                if (lastBackslash) {
                    _stringbuf ~= ch;
                    lastBackslash = false;
                } else {
                    skipChar();
                    break;
                }
            } else if (ch == '\\') {
                if (lastBackslash) {
                    _stringbuf ~= ch;
                    lastBackslash = false;
                } else {
                    lastBackslash = true;
                }
            } else if (ch == EOL_CHAR) {
                skipChar();
                break;
            } else if (lastBackslash) {
                if (ch == 'n')
                    ch = '\n';
                else if (ch == 't')
                    ch = '\t';
                _stringbuf ~= ch;
                lastBackslash = false;
            } else {
                _stringbuf ~= ch;
                lastBackslash = false;
            }
        }
        _token.text = _stringbuf.dup;
        return _token;
    }

    protected ref const(Token) parseIdent() {
        _token.type = TokenType.ident;
        _stringbuf.length = 0;
        _stringbuf ~= peekChar();
        for(;;) {
            dchar ch = skipChar();
            if (!isAlphaNum(ch))
                break;
            _stringbuf ~= ch;
        }
        _token.text = _stringbuf.dup;
        return _token;
    }

    protected ref const(Token) parseFloating(int n) {
        _token.type = TokenType.floating;
        dchar ch = peekChar();
        // floating point
        int div = 0;
        int n2 = 0;
        for (;;) {
            ch = skipChar();
            if (!isNum(ch))
                break;
            n2 = n2 * 10 + (ch - '0');
            div++;
        }
        _token.floatvalue = cast(double)n + (div > 0 ? cast(double)n2 / div : 0.0);
        return _token;
    }

    protected ref const(Token) parseNumber() {
        dchar ch = peekChar();
        uint n = ch - '0';
        for(;;) {
            ch = skipChar();
            if (!isNum(ch))
                break;
            n = n * 10 + (ch - '0');
        }
        if (ch == '.')
            return parseFloating(n);
        _token.type = TokenType.integer;
        _token.intvalue = n;
        return _token;
    }

    protected ref const(Token) parseSingleLineComment() {
        for(;;) {
            dchar ch = skipChar();
            if (ch == EOL_CHAR || ch == EOF_CHAR)
                break;
        }
        _token.type = TokenType.comment;
        return _token;
    }

    protected ref const(Token) parseMultiLineComment() {
        skipChar();
        for(;;) {
            dchar ch = skipChar();
            if (ch == '*' && peekNextChar() == '/') {
                skipChar();
                skipChar();
                break;
            }
            if (ch == EOF_CHAR)
                break;
        }
        _token.type = TokenType.comment;
        return _token;
    }

    protected ref const(Token) parseError() {
        _token.type = TokenType.error;
        for(;;) {
            dchar ch = skipChar();
            if (ch == ' ' || ch == '\t' || ch == EOL_CHAR || ch == EOF_CHAR)
                break;
        }
        return _token;
    }

    protected ref const(Token) parseOp(TokenType op) {
        _token.type = op;
        skipChar();
        return _token;
    }

    /// get next token
    ref const(Token) nextToken() {
        setTokenStart();
        dchar ch = peekChar();
        if (ch == EOF_CHAR)
            return parseEof();
        if (ch == EOL_CHAR)
            return parseEol();
        if (ch == ' ' || ch == '\t')
            return parseWhiteSpace();
        if (ch == '\"')
            return parseString();
        if (isAlpha(ch))
            return parseIdent();
        if (isNum(ch))
            return parseNumber();
        if (ch == '.' && isNum(peekNextChar()))
            return parseFloating(0);
        if (ch == '/' && peekNextChar() == '/')
            return parseSingleLineComment();
        if (ch == '/' && peekNextChar() == '*')
            return parseMultiLineComment();
        switch (ch) {
            case '.': return parseOp(TokenType.dot);
            case ':': return parseOp(TokenType.colon);
            case ';': return parseOp(TokenType.semicolon);
            case ',': return parseOp(TokenType.comma);
            case '{': return parseOp(TokenType.curlyOpen);
            case '}': return parseOp(TokenType.curlyClose);
            case '(': return parseOp(TokenType.open);
            case ')': return parseOp(TokenType.close);
            case '[': return parseOp(TokenType.squareOpen);
            case ']': return parseOp(TokenType.squareClose);
            default:
                return parseError();
        }
    }

    void emitError(string msg) {
        throw new ParserException(msg, _filename, _token.line, _token.pos);
    }

    void emitError(string msg, ref const Token token) {
        throw new ParserException(msg, _filename, token.line, token.pos);
    }
}

class MLParser {
    protected string _code;
    protected string _filename;
    protected Widget _context;
    protected Tokenizer _tokenizer;
    
    protected this(string code, string filename = "", Widget context = null) {
        _code = code;
        _filename = filename;
        _context = context;
        _tokenizer = new Tokenizer(code, filename);
    }

    protected Token _token;


    protected void nextToken() {
        _token = _tokenizer.nextToken();
        Log.d("parsed token: ", _token.type, " ", _token.line, ":", _token.pos, " ", _token.text);
    }

    protected void skipWhitespaceAndEols() {
        for (;;) {
            nextToken();
            if (_token.type != TokenType.eol && _token.type != TokenType.whitespace && _token.type != TokenType.comment)
                break;
        }
        if (_token.type == TokenType.error)
            _tokenizer.emitError("error while parsing ML code");
    }

    protected void skipWhitespace() {
        for (;;) {
            nextToken();
            if (_token.type != TokenType.whitespace && _token.type != TokenType.comment)
                break;
        }
        if (_token.type == TokenType.error)
            _tokenizer.emitError("error while parsing ML code");
    }

    protected void error(string msg) {
        _tokenizer.emitError(msg);
    }

    Widget createWidget(string name) {
        auto metadata = findWidgetMetadata(name);
        if (!metadata)
            error("Cannot create widget " ~ name ~ " : unregistered widget class");
        return metadata.create();
    }

    protected void createContext(string name) {
        if (_context)
            error("Context widget is already specified, but identifier " ~ name ~ " is found");
        _context = createWidget(name);
    }

    protected Widget parse() {
        skipWhitespaceAndEols();
        if (_token.type == TokenType.ident) {
            createContext(_token.text);
            skipWhitespaceAndEols();
        }
        if (_token.type != TokenType.curlyOpen) // {
            _tokenizer.emitError("{ is expected");
        if (!_context)
            _tokenizer.emitError("No context widget is specified!");
        skipWhitespaceAndEols();
        if (_token.type != TokenType.curlyClose) // {
            _tokenizer.emitError("} is expected");
        skipWhitespaceAndEols();
        if (_token.type != TokenType.eof) // {
            _tokenizer.emitError("end of file expected");
        return _context;
    }

    ~this() {
        destroy(_tokenizer);
        _tokenizer = null;
    }

}


/// Parse DlangUI ML code
public Widget parseML(string code, string filename = "", Widget context = null) {
    MLParser parser = new MLParser(code, filename);
    scope(exit) destroy(parser);
    return parser.parse();
}
