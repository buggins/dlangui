module dlangui.dml.dmlhighlight;

import dlangui.core.editable;
import dlangui.core.linestream;
import dlangui.core.textsource;
import dlangui.core.logger;
import dlangui.dml.parser;
import dlangui.widgets.metadata;

class DMLSyntaxSupport : SyntaxSupport {

    EditableContent _content;
    SourceFile _file;
    this (string filename) {
        _file = new SourceFile(filename);
    }

    TokenPropString[] _props;

    /// returns editable content
    @property EditableContent content() { return _content; }
    /// set editable content
    @property SyntaxSupport content(EditableContent content) {
        _content = content;
        return this;
    }

    private enum BracketMatch {
        CONTINUE,
        FOUND,
        ERROR
    }

    private static struct BracketStack {
        dchar[] buf;
        int pos;
        bool reverse;
        void init(bool reverse) {
            this.reverse = reverse;
            pos = 0;
        }
        void push(dchar ch) {
            if (buf.length <= pos)
                buf.length = pos + 16;
            buf[pos++] = ch;
        }
        dchar pop() {
            if (pos <= 0)
                return 0;
            return buf[--pos];
        }
        BracketMatch process(dchar ch) {
            if (reverse) {
                if (isCloseBracket(ch)) {
                    push(ch);
                    return BracketMatch.CONTINUE;
                } else {
                    if (pop() != pairedBracket(ch))
                        return BracketMatch.ERROR;
                    if (pos == 0)
                        return BracketMatch.FOUND;
                    return BracketMatch.CONTINUE;
                }
            } else {
                if (isOpenBracket(ch)) {
                    push(ch);
                    return BracketMatch.CONTINUE;
                } else {
                    if (pop() != pairedBracket(ch))
                        return BracketMatch.ERROR;
                    if (pos == 0)
                        return BracketMatch.FOUND;
                    return BracketMatch.CONTINUE;
                }
            }
        }
    }
    BracketStack _bracketStack;
    static bool isBracket(dchar ch) {
        return pairedBracket(ch) != 0;
    }
    static dchar pairedBracket(dchar ch) {
        switch (ch) {
            case '(':
                return ')';
            case ')':
                return '(';
            case '{':
                return '}';
            case '}':
                return '{';
            case '[':
                return ']';
            case ']':
                return '[';
            default:
                return 0; // not a bracket
        }
    }
    static bool isOpenBracket(dchar ch) {
        switch (ch) {
            case '(':
            case '{':
            case '[':
                return true;
            default:
                return false;
        }
    }
    static bool isCloseBracket(dchar ch) {
        switch (ch) {
            case ')':
            case '}':
            case ']':
                return true;
            default:
                return false;
        }
    }

    protected dchar nextBracket(int dir, ref TextPosition p) {
        for (;;) {
            TextPosition oldpos = p;
            p = dir < 0 ? _content.prevCharPos(p) : _content.nextCharPos(p);
            if (p == oldpos)
                return 0;
            auto prop = _content.tokenProp(p);
            if (tokenCategory(prop) == TokenCategory.Op) {
                dchar ch = _content[p];
                if (isBracket(ch))
                    return ch;
            }
        }
    }

    /// returns paired bracket {} () [] for char at position p, returns paired char position or p if not found or not bracket
    override TextPosition findPairedBracket(TextPosition p) {
        if (p.line < 0 || p.line >= content.length)
            return p;
        dstring s = content.line(p.line);
        if (p.pos < 0 || p.pos >= s.length)
            return p;
        dchar ch = content[p];
        dchar paired = pairedBracket(ch);
        if (!paired)
            return p;
        TextPosition startPos = p;
        int dir = isOpenBracket(ch) ? 1 : -1;
        _bracketStack.init(dir < 0);
        _bracketStack.process(ch);
        for (;;) {
            ch = nextBracket(dir, p);
            if (!ch) // no more brackets
                return startPos;
            auto match = _bracketStack.process(ch);
            if (match == BracketMatch.FOUND)
                return p;
            if (match == BracketMatch.ERROR)
                return startPos;
            // continue
        }
    }


    /// return true if toggle line comment is supported for file type
    override @property bool supportsToggleLineComment() {
        return true;
    }

    /// return true if can toggle line comments for specified text range
    override bool canToggleLineComment(TextRange range) {
        TextRange r = content.fullLinesRange(range);
        if (isInsideBlockComment(r.start) || isInsideBlockComment(r.end))
            return false;
        return true;
    }

    protected bool isLineComment(dstring s) {
        foreach(i; 0 .. s.length - 1) {
            if (s[i] == '/' && s[i + 1] == '/')
                return true;
            else if (s[i] != ' ' && s[i] != '\t')
                return false;
        }
        return false;
    }

    protected dstring commentLine(dstring s, int commentX) {
        dchar[] res;
        int x = 0;
        bool commented = false;
        foreach(i; 0 .. s.length) {
            dchar ch = s[i];
            if (ch == '\t') {
                int newX = (x + _content.tabSize) / _content.tabSize * _content.tabSize;
                if (!commented && newX >= commentX) {
                    commented = true;
                    if (newX != commentX) {
                        // replace tab with space
                        for (; x <= commentX; x++)
                            res ~= ' ';
                    } else {
                        res ~= ch;
                        x = newX;
                    }
                    res ~= "//"d;
                    x += 2;
                } else {
                    res ~= ch;
                    x = newX;
                }
            } else {
                if (!commented && x == commentX) {
                    commented = true;
                    res ~= "//"d;
                    res ~= ch;
                    x += 3;
                } else {
                    res ~= ch;
                    x++;
                }
            }
        }
        if (!commented) {
            for (; x < commentX; x++)
                res ~= ' ';
            res ~= "//"d;
        }
        return cast(dstring)res;
    }

    /// remove single line comment from beginning of line
    protected dstring uncommentLine(dstring s) {
        int p = -1;
        foreach(int i; 0 .. cast(int)s.length - 1) {
            if (s[i] == '/' && s[i + 1] == '/') {
                p = i;
                break;
            }
        }
        if (p < 0)
            return s;
        s = s[0..p] ~ s[p + 2 .. $];
        foreach(i; 0 .. s.length) {
            if (s[i] != ' ' && s[i] != '\t') {
                return s;
            }
        }
        return null;
    }

    /// searches for neares token start before or equal to position
    protected TextPosition tokenStart(TextPosition pos) {
        TextPosition p = pos;
        for (;;) {
            TextPosition prevPos = content.prevCharPos(p);
            if (p == prevPos)
                return p; // begin of file
            TokenProp prop = content.tokenProp(p);
            TokenProp prevProp = content.tokenProp(prevPos);
            if (prop && prop != prevProp)
                return p;
            p = prevPos;
        }
    }

    static struct TokenWithRange {
        Token token;
        TextRange range;
        @property string toString() const {
            return token.toString ~ range.toString;
        }
    }

    protected Token[] _tokens;
    protected int _tokenIndex;

    protected bool initTokenizer() {
        _tokens = tokenizeML(content.lines);
        _tokenIndex = 0;
        return true;
    }

    protected TokenWithRange nextToken() {
        TokenWithRange res;
        if (_tokenIndex < _tokens.length) {
            res.range.start = TextPosition(_tokens[_tokenIndex].line, _tokens[_tokenIndex].pos);
            if (_tokenIndex + 1 < _tokens.length)
                res.range.end = TextPosition(_tokens[_tokenIndex + 1].line, _tokens[_tokenIndex + 1].pos);
            else
                res.range.end = content.endOfFile();
            res.token = _tokens[_tokenIndex];
            _tokenIndex++;
        } else {
            res.range.end = res.range.start = content.endOfFile();
        }
        return res;
    }

    protected TokenWithRange getPositionToken(TextPosition pos) {
        initTokenizer();
        for (;;) {
            TokenWithRange tokenRange = nextToken();
            //Log.d("read token: ", tokenRange);
            if (tokenRange.token.type == TokenType.eof) {
                //Log.d("end of file");
                return tokenRange;
            }
            if (pos >= tokenRange.range.start && pos < tokenRange.range.end) {
                //Log.d("found: ", pos, " in ", tokenRange);
                return tokenRange;
            }
        }
    }

    protected TokenWithRange[] getRangeTokens(TextRange range) {
        TokenWithRange[] res;
        initTokenizer();
        for (;;) {
            TokenWithRange tokenRange = nextToken();
            //Log.d("read token: ", tokenRange);
            if (tokenRange.token.type == TokenType.eof) {
                return res;
            }
            if (tokenRange.range.intersects(range)) {
                //Log.d("found: ", pos, " in ", tokenRange);
                res ~= tokenRange;
            }
        }
    }

    protected bool isInsideBlockComment(TextPosition pos) {
        TokenWithRange tokenRange = getPositionToken(pos);
        if (tokenRange.token.type == TokenType.comment && tokenRange.token.isMultilineComment)
            return pos > tokenRange.range.start && pos < tokenRange.range.end;
        return false;
    }

    /// toggle line comments for specified text range
    override void toggleLineComment(TextRange range, Object source) {
        TextRange r = content.fullLinesRange(range);
        if (isInsideBlockComment(r.start) || isInsideBlockComment(r.end))
            return;
        int lineCount = r.end.line - r.start.line;
        bool noEolAtEndOfRange = false;
        if (lineCount == 0 || r.end.pos > 0) {
            noEolAtEndOfRange = true;
            lineCount++;
        }
        int minLeftX = -1;
        bool hasComments = false;
        bool hasNoComments = false;
        bool hasNonEmpty = false;
        dstring[] srctext;
        dstring[] dsttext;
        foreach(i; 0 .. lineCount) {
            int lineIndex = r.start.line + i;
            dstring s = content.line(lineIndex);
            srctext ~= s;
            TextLineMeasure m = content.measureLine(lineIndex);
            if (!m.empty) {
                if (minLeftX < 0 || minLeftX > m.firstNonSpaceX)
                    minLeftX = m.firstNonSpaceX;
                hasNonEmpty = true;
                if (isLineComment(s))
                    hasComments = true;
                else
                    hasNoComments = true;
            }
        }
        if (minLeftX < 0)
            minLeftX = 0;
        if (hasNoComments || !hasComments) {
            // comment
            foreach(i; 0 .. lineCount) {
                dsttext ~= commentLine(srctext[i], minLeftX);
            }
            if (!noEolAtEndOfRange)
                dsttext ~= ""d;
            EditOperation op = new EditOperation(EditAction.Replace, r, dsttext);
            _content.performOperation(op, source);
        } else {
            // uncomment
            foreach(i; 0 .. lineCount) {
                dsttext ~= uncommentLine(srctext[i]);
            }
            if (!noEolAtEndOfRange)
                dsttext ~= ""d;
            EditOperation op = new EditOperation(EditAction.Replace, r, dsttext);
            _content.performOperation(op, source);
        }
    }

    /// return true if toggle block comment is supported for file type
    override @property bool supportsToggleBlockComment() {
        return true;
    }
    /// return true if can toggle block comments for specified text range
    override bool canToggleBlockComment(TextRange range) {
        TokenWithRange startToken = getPositionToken(range.start);
        TokenWithRange endToken = getPositionToken(range.end);
        //Log.d("canToggleBlockComment: startToken=", startToken, " endToken=", endToken);
        if (startToken.range == endToken.range && startToken.token.isMultilineComment) {
            //Log.d("canToggleBlockComment: can uncomment");
            return true;
        }
        if (range.empty)
            return false;
        TokenWithRange[] tokens = getRangeTokens(range);
        foreach(ref t; tokens) {
            if (t.token.type == TokenType.comment) {
                if (t.token.isMultilineComment) {
                    // disable until nested comments support is implemented
                    return false;
                } else {
                    // single line comment
                    if (t.range.isInside(range.start) || t.range.isInside(range.end))
                        return false;
                }
            }
        }
        return true;
    }
    /// toggle block comments for specified text range
    override void toggleBlockComment(TextRange srcrange, Object source) {
        TokenWithRange startToken = getPositionToken(srcrange.start);
        TokenWithRange endToken = getPositionToken(srcrange.end);
        if (startToken.range == endToken.range && startToken.token.isMultilineComment) {
            TextRange range = startToken.range;
            dstring[] dsttext;
            foreach(i; range.start.line .. range.end.line + 1) {
                dstring s = content.line(i);
                int charsRemoved = 0;
                if (i == range.start.line) {
                    int maxp = content.lineLength(range.start.line);
                    if (i == range.end.line)
                        maxp = range.end.pos - 2;
                    charsRemoved = 2;
                    foreach(j; range.start.pos + charsRemoved .. maxp) {
                        if (s[j] != s[j - 1])
                            break;
                        charsRemoved++;
                    }
                    //Log.d("line before removing start of comment:", s);
                    s = s[range.start.pos + charsRemoved .. $];
                    //Log.d("line after removing start of comment:", s);
                    charsRemoved += range.start.pos;
                }
                if (i == range.end.line) {
                    int endp = range.end.pos;
                    if (charsRemoved > 0)
                        endp -= charsRemoved;
                    int endRemoved = 2;
                    for (int j = endp - endRemoved; j >= 0; j--) {
                        if (s[j] != s[j + 1])
                            break;
                        endRemoved++;
                    }
                    //Log.d("line before removing end of comment:", s);
                    s = s[0 .. endp - endRemoved];
                    //Log.d("line after removing end of comment:", s);
                }
                dsttext ~= s;
            }
            EditOperation op = new EditOperation(EditAction.Replace, range, dsttext);
            _content.performOperation(op, source);
            return;
        } else {
            if (srcrange.empty)
                return;
            TokenWithRange[] tokens = getRangeTokens(srcrange);
            foreach(ref t; tokens) {
                if (t.token.type == TokenType.comment) {
                    if (t.token.isMultilineComment) {
                        // disable until nested comments support is implemented
                        return;
                    } else {
                        // single line comment
                        if (t.range.isInside(srcrange.start) || t.range.isInside(srcrange.end))
                            return;
                    }
                }
            }
            dstring[] dsttext;
            foreach(i; srcrange.start.line .. srcrange.end.line + 1) {
                dstring s = content.line(i);
                int charsAdded = 0;
                if (i == srcrange.start.line) {
                    int p = srcrange.start.pos;
                    if (p < s.length) {
                        s = s[p .. $];
                        charsAdded = -p;
                    } else {
                        charsAdded = -(cast(int)s.length);
                        s = null;
                    }
                    s = "/*" ~ s;
                    charsAdded += 2;
                }
                if (i == srcrange.end.line) {
                    int p = srcrange.end.pos + charsAdded;
                    s = p > 0 ? s[0..p] : null;
                    s ~= "*/";
                }
                dsttext ~= s;
            }
            EditOperation op = new EditOperation(EditAction.Replace, srcrange, dsttext);
            _content.performOperation(op, source);
            return;
        }

    }

    /// categorize characters in content by token types
    void updateHighlight(dstring[] lines, TokenPropString[] props, int changeStartLine, int changeEndLine) {

        initTokenizer();
        _props = props;
        changeStartLine = 0;
        changeEndLine = cast(int)lines.length;
        int tokenPos = 0;
        int tokenLine = 0;
        ubyte category = 0;
        try {
            for (;;) {
                TokenWithRange token = nextToken();
                if (token.token.type == TokenType.eof) {
                    break;
                }
                uint newPos = token.range.start.pos;
                uint newLine = token.range.start.line;

                // fill with category
                foreach(int i; tokenLine .. newLine + 1) {
                    int start = i > tokenLine ? 0 : tokenPos;
                    int end = i < newLine ? cast(int)lines[i].length : newPos;
                    foreach(j; start .. end) {
                        if (j < _props[i].length) {
                            _props[i][j] = category;
                        }
                    }
                }

                // handle token - convert to category
                switch(token.token.type) with(TokenType)
                {
                    case comment:
                        category = TokenCategory.Comment;
                        break;
                    case ident:
                        if (isWidgetClassName(token.token.text))
                            category = TokenCategory.Identifier_Class;
                        else
                            category = TokenCategory.Identifier;
                        break;
                    case str:
                        category = TokenCategory.String;
                        break;
                    case integer:
                        category = TokenCategory.Integer;
                        break;
                    case floating:
                        category = TokenCategory.Float;
                        break;
                    case error:
                        category = TokenCategory.Error;
                        break;
                    default:
                        if (token.token.type >= colon)
                            category = TokenCategory.Op;
                        else
                            category = 0;
                        break;
                }
                tokenPos = newPos;
                tokenLine= newLine;

            }
        } catch (Exception e) {
            Log.e("exception while trying to parse DML source", e);
        }
        _props = null;
    }


    /// returns true if smart indent is supported
    override bool supportsSmartIndents() {
        return true;
    }

    protected bool _opInProgress;
    protected void applyNewLineSmartIndent(EditOperation op, Object source) {
        int line = op.newRange.end.line;
        if (line == 0)
            return; // not for first line
        int prevLine = line - 1;
        TextLineMeasure lineMeasurement = _content.measureLine(line);
        TextLineMeasure prevLineMeasurement = _content.measureLine(prevLine);
        while (prevLineMeasurement.empty && prevLine > 0) {
            prevLine--;
            prevLineMeasurement = _content.measureLine(prevLine);
        }
        if (lineMeasurement.firstNonSpaceX >= 0 && lineMeasurement.firstNonSpaceX < prevLineMeasurement.firstNonSpaceX) {
            dstring prevLineText = _content.line(prevLine);
            TokenPropString prevLineTokenProps = _content.lineTokenProps(prevLine);
            dchar lastOpChar = 0;
            for (int j = prevLineMeasurement.lastNonSpace; j >= 0; j--) {
                auto cat = j < prevLineTokenProps.length ? tokenCategory(prevLineTokenProps[j]) : 0;
                if (cat == TokenCategory.Op) {
                    lastOpChar = prevLineText[j];
                    break;
                } else if (cat != TokenCategory.Comment && cat != TokenCategory.WhiteSpace) {
                    break;
                }
            }
            int spacex = prevLineMeasurement.firstNonSpaceX;
            if (lastOpChar == '{')
                spacex = _content.nextTab(spacex);
            dstring txt = _content.fillSpace(spacex);
            EditOperation op2 = new EditOperation(EditAction.Replace, TextRange(TextPosition(line, 0), TextPosition(line, lineMeasurement.firstNonSpace >= 0 ? lineMeasurement.firstNonSpace : 0)), [txt]);
            _opInProgress = true;
            _content.performOperation(op2, source);
            _opInProgress = false;
        }
    }

    protected void applyClosingCurlySmartIndent(EditOperation op, Object source) {
        int line = op.newRange.end.line;
        TextPosition p2 = findPairedBracket(op.newRange.start);
        if (p2 == op.newRange.start || p2.line > op.newRange.start.line)
            return;
        int prevLine = p2.line;
        TextLineMeasure lineMeasurement = _content.measureLine(line);
        TextLineMeasure prevLineMeasurement = _content.measureLine(prevLine);
        if (lineMeasurement.firstNonSpace != op.newRange.start.pos)
            return; // not in beginning of line
        if (lineMeasurement.firstNonSpaceX >= 0 && lineMeasurement.firstNonSpaceX != prevLineMeasurement.firstNonSpaceX) {
            int spacex = prevLineMeasurement.firstNonSpaceX;
            if (spacex != lineMeasurement.firstNonSpaceX) {
                dstring txt = _content.fillSpace(spacex);
                txt = txt ~ "}";
                EditOperation op2 = new EditOperation(EditAction.Replace, TextRange(TextPosition(line, 0), TextPosition(line, lineMeasurement.firstNonSpace >= 0 ? lineMeasurement.firstNonSpace + 1 : 0)), [txt]);
                _opInProgress = true;
                _content.performOperation(op2, source);
                _opInProgress = false;
            }
        }
    }

    /// apply smart indent, if supported
    override void applySmartIndent(EditOperation op, Object source) {
        if (_opInProgress)
            return;
        if (op.isInsertNewLine) {
            // Enter key pressed - new line inserted or splitted
            applyNewLineSmartIndent(op, source);
        } else if (op.singleChar == '}') {
            // } entered - probably need unindent
            applyClosingCurlySmartIndent(op, source);
        } else if (op.singleChar == '{') {
            // { entered - probably need auto closing }
        }
    }

}

