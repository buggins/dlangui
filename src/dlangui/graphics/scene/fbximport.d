module dlangui.graphics.scene.fbximport;

public import dlangui.core.config;
static if (ENABLE_OPENGL):
static if (BACKEND_GUI):

import dlangui.core.logger;
import dlangui.core.math3d;
import dlangui.dml.tokenizer;
import dlangui.graphics.scene.mesh;
import std.string : startsWith;

struct FbxModelImport {
    Token[] tokens;
    ParseState[] stateStack;
    ParseState state;
    string filename;
    static class ParseState {
        ParseState parent;
        string paramName;
        Token[] literalParams;
        ParseState[] children;
        Token[] additionalLiteralParams;
        this(string name) {
            paramName = name;
        }
        void addLiteral(Token token) {
            literalParams ~= token;
        }
    }
    static class FBXProperties {
        FBXProperty[string] map;
        void add(FBXProperty p) {
            map[p.name] = p;
        }
    }
    static class FBXProperty {
        string name;
        string type;
        Token[] params;
    }
    protected void pushState(ParseState state) {
        state.parent = this.state;
        if (this.state) {
            this.state.children ~= state;
        }
        stateStack ~= state;
        this.state = state;
        Log.d("pushState:[", stateStack.length, "] name=", state.paramName);
    }
    protected ParseState popState() {
        if (!state || stateStack.length < 1)
            error("stack is empty");
        Log.d("popState: [", stateStack.length, "] name=", state.paramName, " params:", state.literalParams, " addParams: ", state.additionalLiteralParams );
        stateStack.length = stateStack.length - 1;
        state = stateStack.length ? stateStack[$ - 1] : null;
        return state;
    }
    protected bool matchTypes(TokenType t1, TokenType t2) {
        return (tokens.length > 1 && tokens[0].type == t1 && tokens[1].type == t2);
    }
    protected bool skip(int count) {
        if (count >= tokens.length) {
            tokens = null;
            return false;
        }
        tokens = tokens[count .. $];
        return true;
    }
    protected string parseParamName() {
        if (matchParamName()) {
            string name = tokens[0].text;
            skip(2);
            return name;
        }
        return null;
    }
    protected bool matchParamName() {
        return matchTypes(TokenType.ident, TokenType.colon);
    }
    protected void error(string msg) {
        if (tokens.length)
            throw new ParserException(msg, filename, tokens[0].line, tokens[0].pos);
        throw new ParserException(msg, filename, tokens[0].line, tokens[0].pos);
    }
    // current token is {, parse till matching }
    protected void parseObject() {
        if (!skip(1))
            error("unexpected eof");
        pushState(new ParseState(null));
        for (;;) {
            if (string name = parseParamName()) {
                parseParam(name);
            } else {
                break;
            }
        }
        if (!tokens.length)
            error("eof while looking for }");
        if (tokens[0].type != TokenType.curlyClose)
            error("}  expected");
        skip(1);
        popState();
    }
    protected Token[] parseLiteralList() {
        Token[] res;
        if (!tokens.length)
            error("unexpected eof");
        Token t = tokens[0];
        while (t.type == TokenType.str || t.type == TokenType.integer || t.type == TokenType.floating || t.type == TokenType.minus || (t.type == TokenType.ident && !matchParamName())) {
            // unary minus handling
            if (t.type == TokenType.minus) {
                if (!skip(1))
                    error("Unexpected eof");
                t = tokens[0];
                if (t.type == TokenType.integer)
                    t.intvalue = -t.intvalue;
                else if (t.type == TokenType.floating)
                    t.floatvalue = -t.floatvalue;
                else
                    error("number expected");
            }
            res ~= t;
            if (!skip(1)) {
                break;
            }
            t = tokens[0];
            if (t.type != TokenType.comma)
                break;
            if (!skip(1))
                error("Unexpected eof");
            t = tokens[0];
        }
        return res;
    }
    protected FBXProperties parseProperties(string name) {
        FBXProperties res = new FBXProperties();
        return res;
    }
    protected void parseParam(string name) {
        //if (name.startsWith("Properties")) {
        //    parseProperties(name);
        //    return;
        //}
        pushState(new ParseState(name));
        if (!tokens.length)
            error("unexpected eof");
        if (matchParamName()) {
            // next param
            popState();
            return;
        }
        // process non-named parameter list
        Token t = tokens[0];
        if (t.type == TokenType.str || t.type == TokenType.integer || t.type == TokenType.floating || t.type == TokenType.minus || (t.type == TokenType.ident && !matchParamName())) {
            state.literalParams = parseLiteralList();
            if (!tokens.length) {
                popState();
                return;
            }
            t = tokens[0];
        }
        if (t.type == TokenType.curlyOpen) {
            parseObject();
            if (tokens.length) {
                t = tokens[0];
                if (t.type == TokenType.comma) {
                    // additional params
                    if (!skip(1))
                        error("unexpected eof");
                    t = tokens[0];
                    if (t.type == TokenType.str || t.type == TokenType.integer || t.type == TokenType.floating || t.type == TokenType.minus || (t.type == TokenType.ident && !matchParamName())) {
                        state.additionalLiteralParams = parseLiteralList();
                    }
                }
            }
            popState();
            return;
        }
        if (matchParamName() || t.type == TokenType.curlyClose) {
            // next param
            popState();
            return;
        } else {
            error("parameter name expected");
        }
    }
    protected bool parseAll() {
        while (tokens.length) {
            if (string name = parseParamName()) {
                parseParam(name);
            } else {
                if (tokens.length)
                    error("Parameter name expected");
            }
        }
        return true;
    }
    bool parse(string source) {
        import dlangui.dml.tokenizer;
        try {
            tokens = tokenize(source, [";"], true, true, true);
            return parseAll();
        } catch (ParserException e) {
            Log.d("failed to tokenize OBJ source", e);
            return false;
        }
    }
}

