// Written in the D programming language.

/**
This module is DML (DlangUI Markup Language) parser - similar to QML in QtQuick

Synopsis:

----
// helloworld
----

Copyright: Vadim Lopatin, 2015
License:   Boost License 1.0
Authors:   Vadim Lopatin, coolreader.org@gmail.com
 */
module dlangui.core.parser;

import dlangui.core.linestream;
import dlangui.core.collections;
import dlangui.core.types;
import dlangui.widgets.widget;
import dlangui.widgets.metadata;
import std.conv : to;
import std.algorithm : equal, min, max;
import std.utf : toUTF32, toUTF8;

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

/// parser exception - unknown (unregistered) widget name
class UnknownWidgetException : ParserException {
    protected string _objectName;

    @property string objectName() { return _objectName; }

    this(string msg, string objectName, string file, int line, int pos) {
        super(msg is null ? "Unknown widget name: " ~ objectName : msg, file, line, pos);
        _objectName = objectName;
    }
}

/// parser exception - unknown property for widget
class UnknownPropertyException : UnknownWidgetException {
    protected string _propName;

    @property string propName() { return _propName; }

    this(string msg, string objectName, string propName, string file, int line, int pos) {
        super(msg is null ? "Unknown property " ~ objectName ~ "." ~ propName : msg, objectName, file, line, pos);
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
    /// - operator
    minus,
    /// + operator
    plus,
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
        //skipChar(); // skip "
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
            case '-': return parseOp(TokenType.minus);
            case '+': return parseOp(TokenType.plus);
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

    string getContextSource() {
        string s = toUTF8(_lineText);
        if (_pos == 0)
            return " near `^^^" ~ s[0..min($,30)] ~ "`";
        if (_pos >= _len)
            return " near `" ~ s[max(_len - 30, 0) .. $] ~ "^^^`";
        return " near `" ~ s[max(_pos - 15, 0) .. _pos] ~ "^^^" ~ s[_pos .. min(_pos + 15, $)] ~ "`";
    }

    void emitError(string msg) {
        throw new ParserException(msg ~ getContextSource(), _filename, _token.line, _token.pos);
    }

    void emitUnknownPropertyError(string objectName, string propName) {
        throw new UnknownPropertyException("Unknown property " ~ objectName ~ "." ~ propName ~ getContextSource(), objectName, propName, _filename, _token.line, _token.pos);
    }

    void emitUnknownObjectError(string objectName) {
        throw new UnknownWidgetException("Unknown widget type " ~ objectName ~ getContextSource(), objectName, _filename, _token.line, _token.pos);
    }

    void emitError(string msg, ref const Token token) {
        throw new ParserException(msg, _filename, token.line, token.pos);
    }
}

class MLParser {
    protected string _code;
    protected string _filename;
    protected bool _ownContext;
    protected Widget _context;
    protected Widget _currentWidget;
    protected Tokenizer _tokenizer;
    protected Collection!Widget _treeStack;
    
    protected this(string code, string filename = "", Widget context = null) {
        _code = code;
        _filename = filename;
        _context = context;
        _tokenizer = new Tokenizer(code, filename);
    }

    protected Token _token;

    /// move to next token
    protected void nextToken() {
        _token = _tokenizer.nextToken();
        Log.d("parsed token: ", _token.type, " ", _token.line, ":", _token.pos, " ", _token.text);
    }

    /// throw exception if current token is eof
    protected void checkNoEof() {
        if (_token.type == TokenType.eof)
            error("unexpected end of file");
    }

    /// move to next token, throw exception if eof
    protected void nextTokenNoEof() {
        nextToken();
        checkNoEof();
    }

    protected void skipWhitespaceAndEols() {
        for (;;) {
            if (_token.type != TokenType.eol && _token.type != TokenType.whitespace && _token.type != TokenType.comment)
                break;
            nextToken();
        }
        if (_token.type == TokenType.error)
            error("error while parsing ML code");
    }

    protected void skipWhitespaceAndEolsNoEof() {
        skipWhitespaceAndEols();
        checkNoEof();
    }

    protected void skipWhitespaceNoEof() {
        skipWhitespace();
        checkNoEof();
    }

    protected void skipWhitespace() {
        for (;;) {
            if (_token.type != TokenType.whitespace && _token.type != TokenType.comment)
                break;
            nextToken();
        }
        if (_token.type == TokenType.error)
            error("error while parsing ML code");
    }

    protected void error(string msg) {
        _tokenizer.emitError(msg);
    }

    protected void unknownObjectError(string objectName) {
        _tokenizer.emitUnknownObjectError(objectName);
    }

    protected void unknownPropertyError(string objectName, string propName) {
        _tokenizer.emitUnknownPropertyError(objectName, propName);
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
        _ownContext = true;
    }

    protected int applySuffix(int value, string suffix) {
        if (suffix.length > 0) {
            if (suffix.equal("px")) {
                // do nothing, value is in px by default
            } else if (suffix.equal("pt")) {
                value = makePointSize(value);
            } else if (suffix.equal("%")) {
                value = makePercentSize(value);
            } else
                error("unknown number suffix: " ~ suffix);
        }
        return value;
    }

    protected void setIntProperty(string propName, int value, string suffix = null) {
        value = applySuffix(value, suffix);
        if (!_currentWidget.setIntProperty(propName, value))
            error("unknown int property " ~ propName);
    }

    protected void setBoolProperty(string propName, bool value) {
        if (!_currentWidget.setBoolProperty(propName, value))
            error("unknown int property " ~ propName);
    }

    protected void setFloatProperty(string propName, double value) {
        if (!_currentWidget.setDoubleProperty(propName, value))
            error("unknown double property " ~ propName);
    }

    protected void setRectProperty(string propName, Rect value) {
        if (!_currentWidget.setRectProperty(propName, value))
            error("unknown Rect property " ~ propName);
    }

    protected void setStringProperty(string propName, string value) {
        if (propName.equal("id")) {
            if (!_currentWidget.setStringProperty(propName, value))
                error("cannot set id property for widget");
            return;
        }

        dstring v = toUTF32(value);
        if (!_currentWidget.setDstringProperty(propName, v))
            error("unknown string property " ~ propName);
    }

    protected void setIdentProperty(string propName, string value) {
        if (propName.equal("id")) {
            if (!_currentWidget.setStringProperty(propName, value))
                error("cannot set id property for widget");
            return;
        }

        if (value.equal("true"))
            setBoolProperty(propName, true);
        else if (value.equal("false"))
            setBoolProperty(propName, false);
        else if (value.equal("FILL") || value.equal("FILL_PARENT"))
            setIntProperty(propName, FILL_PARENT);
        else if (value.equal("WRAP") || value.equal("WRAP_CONTENT"))
            setIntProperty(propName, WRAP_CONTENT);
        else if (!_currentWidget.setStringProperty(propName, value))
            error("unknown ident property " ~ propName);
    }

    protected void parseRectProperty(string propName) {
        // current token is Rect
        int[4] values = [0, 0, 0, 0];
        nextToken();
        skipWhitespaceAndEolsNoEof();
        if (_token.type != TokenType.curlyOpen)
            error("{ expected after Rect");
        nextToken();
        skipWhitespaceAndEolsNoEof();
        int index = 0;
        for (;;) {
            if (_token.type == TokenType.curlyClose)
                break;
            if (_token.type == TokenType.integer) {
                if (index >= 4)
                    error("too many values in Rect");
                int n = applySuffix(_token.intvalue, _token.text);
                values[index++] = n;
                nextToken();
                skipWhitespaceAndEolsNoEof();
                if (_token.type == TokenType.comma || _token.type == TokenType.semicolon) {
                    nextToken();
                    skipWhitespaceAndEolsNoEof();
                }
            } else if (_token.type == TokenType.ident) {
                string name = _token.text;
                nextToken();
                skipWhitespaceAndEolsNoEof();
                if (_token.type != TokenType.colon)
                    error(": expected after property name " ~ name ~ " in Rect definition");
                nextToken();
                skipWhitespaceNoEof();
                if (_token.type != TokenType.integer)
                    error("integer expected as Rect property value");
                int n = applySuffix(_token.intvalue, _token.text);
                
                if (name.equal("left"))
                    values[0] = n;
                else if (name.equal("top"))
                    values[1] = n;
                else if (name.equal("right"))
                    values[2] = n;
                else if (name.equal("bottom"))
                    values[3] = n;
                else
                    error("unknown property " ~ name ~ " in Rect");

                nextToken();
                skipWhitespaceNoEof();
                if (_token.type == TokenType.comma || _token.type == TokenType.semicolon) {
                    nextToken();
                    skipWhitespaceAndEolsNoEof();
                }
            } else {
                error("invalid Rect definition");
            }

        }
        setRectProperty(propName, Rect(values[0], values[1], values[2], values[3]));
    }

    protected void parseProperty() {
        if (_token.type != TokenType.ident)
            error("identifier expected");
        string propName = _token.text;
        nextToken();
        skipWhitespaceNoEof();
        if (_token.type == TokenType.colon) { // :
            nextTokenNoEof(); // skip :
            skipWhitespaceNoEof();
            if (_token.type == TokenType.integer)
                setIntProperty(propName, _token.intvalue, _token.text);
            else if (_token.type == TokenType.minus || _token.type == TokenType.plus) {
                int sign = _token.type == TokenType.minus ? -1 : 1;
                nextTokenNoEof(); // skip :
                skipWhitespaceNoEof();
                if (_token.type == TokenType.integer) {
                    setIntProperty(propName, _token.intvalue * sign, _token.text);
                } else if (_token.type == TokenType.floating) {
                    setFloatProperty(propName, _token.floatvalue * sign);
                } else
                    error("number expected after + and -");
            } else if (_token.type == TokenType.floating)
                setFloatProperty(propName, _token.floatvalue);
            else if (_token.type == TokenType.str)
                setStringProperty(propName, _token.text);
            else if (_token.type == TokenType.ident) {
                if (_token.text.equal("Rect")) {
                    parseRectProperty(propName);
                } else {
                    setIdentProperty(propName, _token.text);
                }
            } else
                error("int, float, string or identifier are expected as property value");
            nextTokenNoEof();            
            skipWhitespaceNoEof();
            if (_token.type == TokenType.semicolon) {
                // separated by ;
                nextTokenNoEof();
                skipWhitespaceAndEolsNoEof();
                return;
            } else if (_token.type == TokenType.eol) {
                nextTokenNoEof();
                skipWhitespaceAndEolsNoEof();
                return;
            } else if (_token.type == TokenType.curlyClose) {
                // it was last property in object
                return;
            }
            error("; eol or } expected after property definition");
        } else if (_token.type == TokenType.curlyOpen) { // { -- start of object
            Widget s = createWidget(propName);
            parseWidgetProperties(s);
        } else {
            error(": or { expected after identifier");
        }

    }

    protected void parseWidgetProperties(Widget w) {
        if (_token.type != TokenType.curlyOpen) // {
            error("{ is expected");
        _treeStack.pushBack(w);
        if (_currentWidget)
            _currentWidget.addChild(w);
        _currentWidget = w;
        nextToken(); // skip {
        skipWhitespaceAndEols();
        for (;;) {
            checkNoEof();
            if (_token.type == TokenType.curlyClose) // end of object's internals
                break;
            parseProperty();
        }
        if (_token.type != TokenType.curlyClose) // {
            error("{ is expected");
        nextToken(); // skip }
        skipWhitespaceAndEols();
        _treeStack.popBack();
        _currentWidget = _treeStack.peekBack();
    }

    protected Widget parse() {
        try {
            nextToken();
            skipWhitespaceAndEols();
            if (_token.type == TokenType.ident) {
                createContext(_token.text);
                nextToken();
                skipWhitespaceAndEols();
            }
            if (_token.type != TokenType.curlyOpen) // {
                error("{ is expected");
            if (!_context)
                error("No context widget is specified!");
            parseWidgetProperties(_context);
        
            skipWhitespaceAndEols();
            if (_token.type != TokenType.eof) // {
                error("end of file expected");
            return _context;
        } catch (Exception e) {
            Log.e("exception while parsing ML", e);
            if (_context && _ownContext)
                destroy(_context);
            _context = null;
            throw e;
        }
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
