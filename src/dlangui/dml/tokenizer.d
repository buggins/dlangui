module dlangui.dml.tokenizer;

import dlangui.core.types;
import dlangui.core.linestream;

import std.conv : to;
import std.utf : toUTF32;
import std.algorithm : equal, min, max;

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
    /// / operator
    divide,
    /// , operator
    comma,
    /// - operator
    minus,
    /// + operator
    plus,
    /// {
    curlyOpen,
    /// }
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
    bool multiline;
    string text;
    union {
        int intvalue;
        double floatvalue;
    }
    public @property string toString() const {
        if (type == TokenType.integer)
            return "" ~ to!string(line) ~ ":" ~ to!string(pos) ~ " " ~ to!string(type) ~ " " ~ to!string(intvalue);
        else if (type == TokenType.floating)
            return "" ~ to!string(line) ~ ":" ~ to!string(pos) ~ " " ~ to!string(type) ~ " " ~ to!string(floatvalue);
        else
            return "" ~ to!string(line) ~ ":" ~ to!string(pos) ~ " " ~ to!string(type) ~ " \"" ~ text ~ "\"";
    }
    @property bool isMultilineComment() {
        return type == TokenType.comment && multiline;
    }
}

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
        super(msg ~ " at " ~ file ~ " line " ~ to!string(line) ~ " column " ~ to!string(pos));
        _msg = msg;
        _file = file;
        _line = line;
        _pos = pos;
    }
}

/// simple tokenizer for DlangUI ML
class Tokenizer {

    protected string[] _singleLineCommentPrefixes = ["//"];
    protected LineStream  _lines;
    protected dchar[] _lineText;
    protected ushort _line;
    protected ushort _pos;
    protected int _len;
    protected dchar _prevChar;
    protected string _filename;
    protected Token _token;

    enum : int {
        EOF_CHAR = 0x001A,
        EOL_CHAR = 0x000A
    }

    this(string source, string filename = "", string[] singleLineCommentPrefixes = ["//"]) {
        _singleLineCommentPrefixes = singleLineCommentPrefixes;
        _filename = filename;
        _lines = LineStream.create(source, filename);
        _lineText = _lines.readLine();
        _len = cast(int)_lineText.length;
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
            _len = cast(int)_lineText.length;
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
        //skipChar(); // skip "
        bool lastBackslash = false;
        _stringbuf.length = 0;
        dchar quoteChar = peekChar();
        for(;;) {
            dchar ch = skipChar();
            if (ch == quoteChar) { // '\"'
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
        int div = 1;
        int n2 = 0;
        for (;;) {
            ch = skipChar();
            if (!isNum(ch))
                break;
            n2 = n2 * 10 + (ch - '0');
            div *= 10;
        }
        _token.floatvalue = cast(double)n + (div > 0 ? cast(double)n2 / div : 0.0);
        string suffix;
        if (ch == '%') {
            suffix ~= ch;
            ch = skipChar();
        } else {
            while (ch >= 'a' && ch <= 'z') {
                suffix ~= ch;
                ch = skipChar();
            }
        }
        if (isAlphaNum(ch) || ch == '.')
            return parseError();
        _token.text = suffix;
        return _token;
    }

    protected ref const(Token) parseHex(int prefixLen) {
        dchar ch = 0;
        foreach(i; 0 .. prefixLen)
            ch = skipChar();

        uint n = parseHexDigit(ch);
        if (n == uint.max)
            return parseError();

        for(;;) {
            ch = skipChar();
            uint digit = parseHexDigit(ch);
            if (digit == uint.max)
                break;
            n = (n << 4) + digit;
        }
        string suffix;
        if (ch == '%') {
            suffix ~= ch;
            ch = skipChar();
        } else {
            while (ch >= 'a' && ch <= 'z') {
                suffix ~= ch;
                ch = skipChar();
            }
        }
        if (isAlphaNum(ch) || ch == '.')
            return parseError();
        _token.type = TokenType.integer;
        _token.intvalue = n;
        _token.text = suffix;
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
        string suffix;
        if (ch == '%') {
            suffix ~= ch;
            ch = skipChar();
        } else {
            while (ch >= 'a' && ch <= 'z') {
                suffix ~= ch;
                ch = skipChar();
            }
        }
        if (isAlphaNum(ch) || ch == '.')
            return parseError();
        _token.type = TokenType.integer;
        _token.intvalue = n;
        _token.text = suffix;
        return _token;
    }

    protected ref const(Token) parseSingleLineComment() {
        for(;;) {
            dchar ch = skipChar();
            if (ch == EOL_CHAR || ch == EOF_CHAR)
                break;
        }
        _token.type = TokenType.comment;
        _token.multiline = false;
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
        _token.multiline = true;
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
        if (ch == '\"' || ch == '\'' || ch == '`')
            return parseString();
        if (isAlpha(ch))
            return parseIdent();
        if (ch == '0' && peekNextChar == 'x')
            return parseHex(2);
        if (ch == '#')
            return parseHex(1);
        if (isNum(ch))
            return parseNumber();
        if (ch == '.' && isNum(peekNextChar()))
            return parseFloating(0);
        foreach(prefix; _singleLineCommentPrefixes) {
            if (ch == prefix[0] && (prefix.length == 1 || peekNextChar() == prefix[1]))
                return parseSingleLineComment();
        }
        if (ch == '/' && peekNextChar() == '*')
            return parseMultiLineComment();
        switch (ch) {
            case '.': return parseOp(TokenType.dot);
            case ':': return parseOp(TokenType.colon);
            case ';': return parseOp(TokenType.semicolon);
            case ',': return parseOp(TokenType.comma);
            case '-': return parseOp(TokenType.minus);
            case '+': return parseOp(TokenType.plus);
            case '{': return parseOp(TokenType.curlyOpen);
            case '}': return parseOp(TokenType.curlyClose);
            case '(': return parseOp(TokenType.open);
            case ')': return parseOp(TokenType.close);
            case '[': return parseOp(TokenType.squareOpen);
            case ']': return parseOp(TokenType.squareClose);
            case '/': return parseOp(TokenType.divide);
            default:
                return parseError();
        }
    }

    string getContextSource() {
        string s = toUTF8(cast(dstring)_lineText);
        if (_pos == 0)
            return " near `^^^" ~ s[0..min($,30)] ~ "`";
        if (_pos >= _len)
            return " near `" ~ s[max(_len - 30, 0) .. $] ~ "^^^`";
        return " near `" ~ s[max(_pos - 15, 0) .. _pos] ~ "^^^" ~ s[_pos .. min(_pos + 15, $)] ~ "`";
    }

    @property string filename() {
        return filename;
    }
    @property int line() {
        return _token.line;
    }
    @property int pos() {
        return _token.pos;
    }

    void emitError(string msg) {
        throw new ParserException(msg ~ getContextSource(), _filename, _token.line, _token.pos);
    }

    void emitError(string msg, ref const Token token) {
        throw new ParserException(msg, _filename, token.line, token.pos);
    }
}

/// tokenize source into array of tokens (excluding EOF)
public Token[] tokenize(string code, string[] _singleLineCommentPrefixes = ["//"], bool skipSpace = false, bool skipEols = false, bool skipComments = false) {
    Token[] res;
    auto tokenizer = new Tokenizer(code, "", _singleLineCommentPrefixes);
    for (;;) {
        auto token = tokenizer.nextToken();
        if (token.type == TokenType.eof)
            break;
        if (skipSpace && token.type == TokenType.whitespace)
            continue;
        if (skipEols &&  token.type == TokenType.eol)
            continue;
        if (skipComments &&  token.type == TokenType.comment)
            continue;
        res ~= token;
    }
    return res;
}

/// exclude whitespace tokens at beginning and end of token sequence
Token[] trimSpaceTokens(Token[] tokens, bool trimBeginning = true, bool trimEnd = true) {
    if (trimBeginning)
        while(tokens.length > 0 && tokens[0].type == TokenType.whitespace)
            tokens = tokens[1 .. $];
    if (trimEnd)
        while(tokens.length > 0 && tokens[$ - 1].type == TokenType.whitespace)
            tokens = tokens[0 .. $ - 1];
    return tokens;
}
