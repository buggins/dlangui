// Written in the D programming language.

/**
This module is DML (DlangUI Markup Language) parser - similar to QML in QtQuick

Synopsis:

----

Widget layout = parseML(q{
    VerticalLayout {
        TextWidget { text: "Some label" }
        TextLine { id: editor; text: "Some text to edit" }
        Button { id: btnOk; text: "Ok" }
    }
});


----

Copyright: Vadim Lopatin, 2015
License:   Boost License 1.0
Authors:   Vadim Lopatin, coolreader.org@gmail.com
 */
module dlangui.dml.parser;

import dlangui.core.linestream;
import dlangui.core.collections;
import dlangui.core.types;
import dlangui.widgets.widget;
import dlangui.widgets.metadata;
import std.conv : to;
import std.algorithm : equal, min, max;
import std.utf : toUTF32;
import std.array : join;
public import dlangui.dml.annotations;
public import dlangui.dml.tokenizer;

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
        //Log.d("parsed token: ", _token.type, " ", _token.line, ":", _token.pos, " ", _token.text);
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
        throw new UnknownWidgetException("Unknown widget type " ~ objectName ~ _tokenizer.getContextSource(), objectName, _tokenizer.filename, _tokenizer.line, _tokenizer.pos);
    }

    protected void unknownPropertyError(string objectName, string propName) {
        throw new UnknownPropertyException("Unknown property " ~ objectName ~ "." ~ propName ~ _tokenizer.getContextSource(), objectName, propName, _tokenizer.filename, _tokenizer.line, _tokenizer.pos);
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
            } else if (suffix.equal("m") || suffix.equal("em")) {
                // todo: implement EMs
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

    protected void setStringListValueProperty(string propName, StringListValue[] values) {
        if (!_currentWidget.setStringListValueListProperty(propName, values)) {
            UIString[] strings;
            foreach(value; values)
                strings ~= value.label;
            if (!_currentWidget.setUIStringListProperty(propName, strings)) {
                error("unknown string list property " ~ propName);
            }
        }
    }


    protected void setRectProperty(string propName, Rect value) {
        if (!_currentWidget.setRectProperty(propName, value))
            error("unknown Rect property " ~ propName);
    }

    protected void setStringProperty(string propName, string value) {
        if (propName.equal("id") || propName.equal("styleId") || propName.equal("backgroundImageId")) {
            if (!_currentWidget.setStringProperty(propName, value))
                error("cannot set " ~ propName ~ " property for widget");
            return;
        }

        dstring v = toUTF32(value);
        if (!_currentWidget.setDstringProperty(propName, v)) {
            if (!_currentWidget.setStringProperty(propName, value))
                error("unknown string property " ~ propName);
        }
    }

    protected void setIdentProperty(string propName, string value) {
        if (propName.equal("id") || propName.equal("styleId") || propName.equal("backgroundImageId")) {
            if (!_currentWidget.setStringProperty(propName, value))
                error("cannot set id property for widget");
            return;
        }

        if (value.equal("true"))
            setBoolProperty(propName, true);
        else if (value.equal("false"))
            setBoolProperty(propName, false);
        else if (value.equal("fill") || value.equal("FILL") || value.equal("FILL_PARENT"))
            setIntProperty(propName, FILL_PARENT);
        else if (value.equal("wrap") || value.equal("WRAP") || value.equal("WRAP_CONTENT"))
            setIntProperty(propName, WRAP_CONTENT);
        else if (value.equal("left") || value.equal("Left"))
            setIntProperty(propName, Align.Left);
        else if (value.equal("right") || value.equal("Right"))
            setIntProperty(propName, Align.Right);
        else if (value.equal("top") || value.equal("Top"))
            setIntProperty(propName, Align.Top);
        else if (value.equal("bottom") || value.equal("Bottom"))
            setIntProperty(propName, Align.Bottom);
        else if (value.equal("hcenter") || value.equal("HCenter"))
            setIntProperty(propName, Align.HCenter);
        else if (value.equal("vcenter") || value.equal("VCenter"))
            setIntProperty(propName, Align.VCenter);
        else if (value.equal("center") || value.equal("Center"))
            setIntProperty(propName, Align.Center);
        else if (value.equal("topleft") || value.equal("TopLeft"))
            setIntProperty(propName, Align.TopLeft);
        else if (propName.equal("orientation") && (value.equal("vertical") || value.equal("Vertical")))
            setIntProperty(propName, Orientation.Vertical);
        else if (propName.equal("orientation") && (value.equal("horizontal") || value.equal("Horizontal")))
            setIntProperty(propName, Orientation.Horizontal);
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

    // something in []
    protected void parseArrayProperty(string propName) {
        // current token is Rect
        nextToken();
        skipWhitespaceAndEolsNoEof();
        StringListValue[] values;
        for (;;) {
            if (_token.type == TokenType.squareClose)
                break;
            if (_token.type == TokenType.integer) {
                if (_token.text.length)
                    error("Integer literal suffixes not allowed for [] items");
                StringListValue value;
                value.intId = _token.intvalue;
                value.label = UIString.fromRaw(to!dstring(_token.intvalue));
                values ~= value;
                nextToken();
                skipWhitespaceAndEolsNoEof();
                if (_token.type == TokenType.comma || _token.type == TokenType.semicolon) {
                    nextToken();
                    skipWhitespaceAndEolsNoEof();
                }
            } else if (_token.type == TokenType.ident) {
                string name = _token.text;

                StringListValue value;
                value.stringId = name;
                value.label = UIString.fromRaw(name);
                values ~= value;

                nextToken();
                skipWhitespaceAndEolsNoEof();

                if (_token.type == TokenType.comma || _token.type == TokenType.semicolon) {
                    nextToken();
                    skipWhitespaceAndEolsNoEof();
                }
            } else if (_token.type == TokenType.str) {
                string name = _token.text;

                StringListValue value;
                value.stringId = name;
                value.label = UIString.fromRaw(name.toUTF32);
                values ~= value;

                nextToken();
                skipWhitespaceAndEolsNoEof();

                if (_token.type == TokenType.comma || _token.type == TokenType.semicolon) {
                    nextToken();
                    skipWhitespaceAndEolsNoEof();
                }
            } else {
                error("invalid [] item");
            }

        }
        setStringListValueProperty(propName, values);
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
            else if (_token.type == TokenType.squareOpen)
                parseArrayProperty(propName);
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
public T parseML(T = Widget)(string code, string filename = "", Widget context = null) {
    MLParser parser = new MLParser(code, filename, context);
    scope(exit) destroy(parser);
    Widget w = parser.parse();
    T res = cast(T) w;
    if (w && !res && !context) {
        destroy(w);
        throw new ParserException("Cannot convert parsed widget to " ~ T.stringof, "", 0, 0);
    }
    return res;
}

/// tokenize source into array of tokens (excluding EOF)
public Token[] tokenizeML(const(dstring[]) lines) {
    string code = toUTF8(join(lines, "\n"));
    return tokenizeML(code);
}

/// tokenize source into array of tokens (excluding EOF)
public Token[] tokenizeML(const(string[]) lines) {
    string code = join(lines, "\n");
    return tokenizeML(code);
}

/// tokenize source into array of tokens (excluding EOF)
public Token[] tokenizeML(string code) {
    Token[] res;
    auto tokenizer = new Tokenizer(code, "");
    for (;;) {
        auto token = tokenizer.nextToken();
        if (token.type == TokenType.eof)
            break;
        res ~= token;
    }
    return res;
}

//pragma(msg, tokenizeML("Widget {}"));
