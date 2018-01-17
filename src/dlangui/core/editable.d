// Written in the D programming language.

/**
This module contains implementation of editable text content.


Synopsis:

----
import dlangui.core.editable;

----

Copyright: Vadim Lopatin, 2014
License:   Boost License 1.0
Authors:   Vadim Lopatin, coolreader.org@gmail.com
*/
module dlangui.core.editable;

import dlangui.core.logger;
import dlangui.core.signals;
import dlangui.core.collections;
import dlangui.core.linestream;
import dlangui.core.streams;
import std.algorithm;
import std.conv : to;

// uncomment FileFormats debug symbol to dump file formats for loaded/saved files.
//debug = FileFormats;

immutable dchar EOL = '\n';

const ubyte TOKEN_CATEGORY_SHIFT =   4;
const ubyte TOKEN_CATEGORY_MASK =    0xF0; // token category 0..15
const ubyte TOKEN_SUBCATEGORY_MASK = 0x0F; // token subcategory 0..15
const ubyte TOKEN_UNKNOWN = 0;

/*
Bit mask:
7654 3210
cccc ssss
|    |
|    \ ssss = token subcategory
|
\ cccc = token category

*/
/// token category for syntax highlight
enum TokenCategory : ubyte {
    WhiteSpace = (0 << TOKEN_CATEGORY_SHIFT),
    WhiteSpace_Space = (0 << TOKEN_CATEGORY_SHIFT) | 1,
    WhiteSpace_Tab = (0 << TOKEN_CATEGORY_SHIFT) | 2,

    Comment = (1 << TOKEN_CATEGORY_SHIFT),
    Comment_SingleLine = (1 << TOKEN_CATEGORY_SHIFT) | 1,   // single line comment
    Comment_SingleLineDoc = (1 << TOKEN_CATEGORY_SHIFT) | 2,// documentation in single line comment
    Comment_MultyLine = (1 << TOKEN_CATEGORY_SHIFT) | 3,    // multiline coment
    Comment_MultyLineDoc = (1 << TOKEN_CATEGORY_SHIFT) | 4, // documentation in multiline comment
    Comment_Documentation = (1 << TOKEN_CATEGORY_SHIFT) | 5,// documentation comment

    Identifier = (2 << TOKEN_CATEGORY_SHIFT), // identifier (exact subcategory is unknown)
    Identifier_Class = (2 << TOKEN_CATEGORY_SHIFT) | 1, // class name
    Identifier_Struct = (2 << TOKEN_CATEGORY_SHIFT) | 2, // struct name
    Identifier_Local = (2 << TOKEN_CATEGORY_SHIFT) | 3, // local variable
    Identifier_Member = (2 << TOKEN_CATEGORY_SHIFT) | 4, // struct or class member
    Identifier_Deprecated = (2 << TOKEN_CATEGORY_SHIFT) | 15, // usage of this identifier is deprecated
    /// string literal
    String = (3 << TOKEN_CATEGORY_SHIFT),
    /// character literal
    Character = (4 << TOKEN_CATEGORY_SHIFT),
    /// integer literal
    Integer = (5 << TOKEN_CATEGORY_SHIFT),
    /// floating point number literal
    Float = (6 << TOKEN_CATEGORY_SHIFT),
    /// keyword
    Keyword = (7 << TOKEN_CATEGORY_SHIFT),
    /// operator
    Op = (8 << TOKEN_CATEGORY_SHIFT),
    // add more here
    //....
    /// error - unparsed character sequence
    Error = (15 << TOKEN_CATEGORY_SHIFT),
    /// invalid token - generic
    Error_InvalidToken = (15 << TOKEN_CATEGORY_SHIFT) | 1,
    /// invalid number token - error occured while parsing number
    Error_InvalidNumber = (15 << TOKEN_CATEGORY_SHIFT) | 2,
    /// invalid string token - error occured while parsing string
    Error_InvalidString = (15 << TOKEN_CATEGORY_SHIFT) | 3,
    /// invalid identifier token - error occured while parsing identifier
    Error_InvalidIdentifier = (15 << TOKEN_CATEGORY_SHIFT) | 4,
    /// invalid comment token - error occured while parsing comment
    Error_InvalidComment = (15 << TOKEN_CATEGORY_SHIFT) | 7,
    /// invalid comment token - error occured while parsing comment
    Error_InvalidOp = (15 << TOKEN_CATEGORY_SHIFT) | 8,
}

/// extracts token category, clearing subcategory
ubyte tokenCategory(ubyte t) {
    return t & 0xF0;
}

/// split dstring by delimiters
dstring[] splitDString(dstring source, dchar delimiter = EOL) {
    int start = 0;
    dstring[] res;
    for (int i = 0; i <= source.length; i++) {
        if (i == source.length || source[i] == delimiter) {
            if (i >= start) {
                dchar prevchar = i > 1 && i > start + 1 ? source[i - 1] : 0;
                int end = i;
                if (delimiter == EOL && prevchar == '\r') // windows CR/LF
                    end--;
                dstring line = i > start ? cast(dstring)(source[start .. end].dup) : ""d;
                res ~= line;
            }
            start = i + 1;
        }
    }
    return res;
}

version (Windows) {
    immutable dstring SYSTEM_DEFAULT_EOL = "\r\n";
} else {
    immutable dstring SYSTEM_DEFAULT_EOL = "\n";
}

/// concat strings from array using delimiter
dstring concatDStrings(dstring[] lines, dstring delimiter = SYSTEM_DEFAULT_EOL) {
    dchar[] buf;
    foreach(i, line; lines) {
        if(i > 0)
            buf ~= delimiter;
        buf ~= line;
    }
    return cast(dstring)buf;
}

/// replace end of lines with spaces
dstring replaceEolsWithSpaces(dstring source) {
    dchar[] buf;
    dchar lastch;
    foreach(ch; source) {
        if (ch == '\r') {
            buf ~= ' ';
        } else if (ch == '\n') {
            if (lastch != '\r')
                buf ~= ' ';
        } else {
            buf ~= ch;
        }
        lastch = ch;
    }
    return cast(dstring)buf;
}

/// text content position
struct TextPosition {
    /// line number, zero based
    int line;
    /// character position in line (0 == before first character)
    int pos;
    /// compares two positions
    int opCmp(ref const TextPosition v) const {
        if (line < v.line)
            return -1;
        if (line > v.line)
            return 1;
        if (pos < v.pos)
            return -1;
        if (pos > v.pos)
            return 1;
        return 0;
    }
    bool opEquals(ref inout TextPosition v) inout {
        return line == v.line && pos == v.pos;
    }
    @property string toString() const {
        return to!string(line) ~ ":" ~ to!string(pos);
    }
    /// adds deltaPos to position and returns result
    TextPosition offset(int deltaPos) {
        return TextPosition(line, pos + deltaPos);
    }
}

/// text content range
struct TextRange {
    TextPosition start;
    TextPosition end;
    bool intersects(const ref TextRange v) const {
        if (start >= v.end)
            return false;
        if (end <= v.start)
            return false;
        return true;
    }
    /// returns true if position is inside this range
    bool isInside(TextPosition p) const {
        return start <= p && end > p;
    }
    /// returns true if position is inside this range or right after this range
    bool isInsideOrNext(TextPosition p) const {
        return start <= p && end >= p;
    }
    /// returns true if range is empty
    @property bool empty() const {
        return end <= start;
    }
    /// returns true if start and end located at the same line
    @property bool singleLine() const {
        return end.line == start.line;
    }
    /// returns count of lines in range
    @property int lines() const {
        return end.line - start.line + 1;
    }
    @property string toString() const {
        return "[" ~ start.toString ~ ":" ~ end.toString ~ "]";
    }
}

/// action performed with editable contents
enum EditAction {
    /// insert content into specified position (range.start)
    //Insert,
    /// delete content in range
    //Delete,
    /// replace range content with new content
    Replace,

    /// replace whole content
    ReplaceContent,
    /// saved content
    SaveContent,
}

/// values for editable line state
enum EditStateMark : ubyte {
    /// content is unchanged - e.g. after loading from file
    unchanged,
    /// content is changed and not yet saved
    changed,
    /// content is changed, but already saved to file
    saved,
}

/// edit operation details for EditableContent
class EditOperation {
    protected EditAction _action;
    /// action performed
    @property EditAction action() { return _action; }
    protected TextRange _range;

    /// source range to replace with new content
    @property ref TextRange range() { return _range; }
    protected TextRange _newRange;

    /// new range after operation applied
    @property ref TextRange newRange() { return _newRange; }
    @property void newRange(TextRange range) { _newRange = range; }

    /// new content for range (if required for this action)
    protected dstring[] _content;
    @property ref dstring[] content() { return _content; }

    /// line edit marks for old range
    protected EditStateMark[] _oldEditMarks;
    @property ref EditStateMark[] oldEditMarks() { return _oldEditMarks; }
    @property void oldEditMarks(EditStateMark[] marks) { _oldEditMarks = marks; }

    /// old content for range
    protected dstring[] _oldContent;
    @property ref dstring[] oldContent() { return _oldContent; }
    @property void oldContent(dstring[] content) { _oldContent = content; }

    this(EditAction action) {
        _action = action;
    }
    this(EditAction action, TextPosition pos, dstring text) {
        this(action, TextRange(pos, pos), text);
    }
    this(EditAction action, TextRange range, dstring text) {
        _action = action;
        _range = range;
        _content.length = 1;
        _content[0] = text.dup;
    }
    this(EditAction action, TextRange range, dstring[] text) {
        _action = action;
        _range = range;
        _content.length = text.length;
        foreach(i; 0 .. text.length)
            _content[i] = text[i].dup;
        //_content = text;
    }
    /// try to merge two operations (simple entering of characters in the same line), return true if succeded
    bool merge(EditOperation op) {
        if (_range.start.line != op._range.start.line) // both ops whould be on the same line
            return false;
        if (_content.length != 1 || op._content.length != 1) // both ops should operate the same line
            return false;
        // appending of single character
        if (_range.empty && op._range.empty && op._content[0].length == 1 && _newRange.end.pos == op._range.start.pos) {
            _content[0] ~= op._content[0];
            _newRange.end.pos++;
            return true;
        }
        // removing single character
        if (_newRange.empty && op._newRange.empty && op._oldContent[0].length == 1) {
            if (_newRange.end.pos == op.range.end.pos) {
                // removed char before
                _range.start.pos--;
                _newRange.start.pos--;
                _newRange.end.pos--;
                _oldContent[0] = (op._oldContent[0].dup ~ _oldContent[0].dup).dup;
                return true;
            } else if (_newRange.end.pos == op._range.start.pos) {
                // removed char after
                _range.end.pos++;
                _oldContent[0] = (_oldContent[0].dup ~ op._oldContent[0].dup).dup;
                return true;
            }
        }
        return false;
    }

    //void saved() {
    //    for (int i = 0; i < _oldEditMarks.length; i++) {
    //        if (_oldEditMarks[i] == EditStateMark.changed)
    //            _oldEditMarks[i] = EditStateMark.saved;
    //    }
    //}
    void modified(bool all = true) {
        foreach(i; 0 .. _oldEditMarks.length) {
            if (all || _oldEditMarks[i] == EditStateMark.saved)
                _oldEditMarks[i] = EditStateMark.changed;
        }
    }

    /// return true if it's insert new line operation
    @property bool isInsertNewLine() {
        return content.length == 2 && content[0].length == 0 && content[1].length == 0;
    }

    /// if new content is single char, return it, otherwise return 0
    @property dchar singleChar() {
        return content.length == 1 && content[0].length == 1 ? content[0][0] : 0;
    }
}

/// Undo/Redo buffer
class UndoBuffer {
    protected Collection!EditOperation _undoList;
    protected Collection!EditOperation _redoList;

    /// returns true if buffer contains any undo items
    @property bool hasUndo() {
        return !_undoList.empty;
    }

    /// returns true if buffer contains any redo items
    @property bool hasRedo() {
        return !_redoList.empty;
    }

    /// adds undo operation
    void saveForUndo(EditOperation op) {
        _redoList.clear();
        if (!_undoList.empty) {
            if (_undoList.back.merge(op)) {
                //_undoList.back.modified();
                return; // merged - no need to add new operation
            }
        }
        _undoList.pushBack(op);
    }

    /// returns operation to be undone (put it to redo), null if no undo ops available
    EditOperation undo() {
        if (!hasUndo)
            return null; // no undo operations
        EditOperation res = _undoList.popBack();
        _redoList.pushBack(res);
        return res;
    }

    /// returns operation to be redone (put it to undo), null if no undo ops available
    EditOperation redo() {
        if (!hasRedo)
            return null; // no undo operations
        EditOperation res = _redoList.popBack();
        _undoList.pushBack(res);
        return res;
    }

    /// clears both undo and redo buffers
    void clear() {
        _undoList.clear();
        _redoList.clear();
        _savedState = null;
    }

    protected EditOperation _savedState;

    /// current state is saved
    void saved() {
        _savedState = _undoList.peekBack;
        foreach(i; 0 .. _undoList.length) {
            _undoList[i].modified();
        }
        foreach(i; 0 .. _redoList.length) {
            _redoList[i].modified();
        }
    }

    /// returns true if saved state is in redo buffer
    bool savedInRedo() {
        if (!_savedState)
            return false;
        foreach(i; 0 .. _redoList.length) {
            if (_savedState is _redoList[i])
                return true;
        }
        return false;
    }

    /// returns true if content has been changed since last saved() or clear() call
    @property bool modified() {
        return _savedState !is _undoList.peekBack;
    }
}

/// Editable Content change listener
interface EditableContentListener {
    void onContentChange(EditableContent content, EditOperation operation, ref TextRange rangeBefore, ref TextRange rangeAfter, Object source);
}

interface EditableContentMarksChangeListener {
    void onMarksChange(EditableContent content, LineIcon[] movedMarks, LineIcon[] removedMarks);
}

/// TokenCategory holder
alias TokenProp = ubyte;
/// TokenCategory string
alias TokenPropString = TokenProp[];

struct LineSpan {
    /// start index of line
    int start;
    /// number of lines it spans
    int len;
    /// the wrapping points
    WrapPoint[] wrapPoints;
    /// the wrapped text
    dstring[] wrappedContent;
    
    enum WrapPointInfo : bool {
        Position,
        Width,
    }
    
    ///Adds up either positions or widths to a wrapLine
    int accumulation(int wrapLine, bool wrapPointInfo)
    {
        int total;
        for (int i; i < wrapLine; i++)
        {
            if (i < this.wrapPoints.length - 1)
            {
                int curVal;
                curVal = wrapPointInfo ? this.wrapPoints[i].wrapWidth : this.wrapPoints[i].wrapPos;
                total += curVal;
            }
        }
        return total;
    }
}

///Holds info about a word wrapping point
struct WrapPoint {
    ///The relative wrapping position (related to TextPosition.pos)
    int wrapPos;
    ///The associated calculated width of the wrapLine
    int wrapWidth;
}

/// interface for custom syntax highlight, comments toggling, smart indents, and other language dependent features for source code editors
interface SyntaxSupport {

    /// returns editable content
    @property EditableContent content();
    /// set editable content
    @property SyntaxSupport content(EditableContent content);

    /// categorize characters in content by token types
    void updateHighlight(dstring[] lines, TokenPropString[] props, int changeStartLine, int changeEndLine);

    /// return true if toggle line comment is supported for file type
    @property bool supportsToggleLineComment();
    /// return true if can toggle line comments for specified text range
    bool canToggleLineComment(TextRange range);
    /// toggle line comments for specified text range
    void toggleLineComment(TextRange range, Object source);

    /// return true if toggle block comment is supported for file type
    @property bool supportsToggleBlockComment();
    /// return true if can toggle block comments for specified text range
    bool canToggleBlockComment(TextRange range);
    /// toggle block comments for specified text range
    void toggleBlockComment(TextRange range, Object source);

    /// returns paired bracket {} () [] for char at position p, returns paired char position or p if not found or not bracket
    TextPosition findPairedBracket(TextPosition p);

    /// returns true if smart indent is supported
    bool supportsSmartIndents();
    /// apply smart indent after edit operation, if needed
    void applySmartIndent(EditOperation op, Object source);
}

/// measure line text (tabs, spaces, and nonspace positions)
struct TextLineMeasure {
    /// line length
    int len;
    /// first non-space index in line
    int firstNonSpace = -1;
    /// first non-space position according to tab size
    int firstNonSpaceX;
    /// last non-space character index in line
    int lastNonSpace = -1;
    /// last non-space position based on tab size
    int lastNonSpaceX;
    /// true if line has zero length or consists of spaces and tabs only
    @property bool empty() { return len == 0 || firstNonSpace < 0; }
}

/// editable plain text (singleline/multiline)
class EditableContent {

    this(bool multiline) {
        _multiline = multiline;
        _lines.length = 1; // initial state: single empty line
        _editMarks.length = 1;
        _undoBuffer = new UndoBuffer();
    }

    @property bool modified() {
        return _undoBuffer.modified;
    }

    protected UndoBuffer _undoBuffer;

    protected SyntaxSupport _syntaxSupport;

    @property SyntaxSupport syntaxSupport() {
        return _syntaxSupport;
    }

    @property EditableContent syntaxSupport(SyntaxSupport syntaxSupport) {
        _syntaxSupport = syntaxSupport;
        if (_syntaxSupport) {
            _syntaxSupport.content = this;
            updateTokenProps(0, cast(int)_lines.length);
        }
        return this;
    }

    @property const(dstring[]) lines() {
        return _lines;
    }

    /// returns true if content has syntax highlight handler set
    @property bool hasSyntaxHighlight() {
        return _syntaxSupport !is null;
    }

    protected bool _readOnly;

    @property bool readOnly() {
        return _readOnly;
    }

    @property void readOnly(bool readOnly) {
        _readOnly = readOnly;
    }

    protected LineIcons _lineIcons;
    @property ref LineIcons lineIcons() { return _lineIcons; }

    protected int _tabSize = 4;
    protected bool _useSpacesForTabs = true;
    /// returns tab size (in number of spaces)
    @property int tabSize() {
        return _tabSize;
    }
    /// sets tab size (in number of spaces)
    @property EditableContent tabSize(int newTabSize) {
        if (newTabSize < 1)
            newTabSize = 1;
        else if (newTabSize > 16)
            newTabSize = 16;
        _tabSize = newTabSize;
        return this;
    }
    /// when true, spaces will be inserted instead of tabs
    @property bool useSpacesForTabs() {
        return _useSpacesForTabs;
    }
    /// set new Tab key behavior flag: when true, spaces will be inserted instead of tabs
    @property EditableContent useSpacesForTabs(bool useSpacesForTabs) {
        _useSpacesForTabs = useSpacesForTabs;
        return this;
    }

    /// true if smart indents are supported
    @property bool supportsSmartIndents() { return _syntaxSupport && _syntaxSupport.supportsSmartIndents; }

    protected bool _smartIndents;
    /// true if smart indents are enabled
    @property bool smartIndents() { return _smartIndents; }
    /// set smart indents enabled flag
    @property EditableContent smartIndents(bool enabled) { _smartIndents = enabled; return this; }

    protected bool _smartIndentsAfterPaste;
    /// true if smart indents are enabled
    @property bool smartIndentsAfterPaste() { return _smartIndentsAfterPaste; }
    /// set smart indents enabled flag
    @property EditableContent smartIndentsAfterPaste(bool enabled) { _smartIndentsAfterPaste = enabled; return this; }

    /// listeners for edit operations
    Signal!EditableContentListener contentChanged;
    /// listeners for mark changes after edit operation
    Signal!EditableContentMarksChangeListener marksChanged;

    protected bool _multiline;
    /// returns true if miltyline content is supported
    @property bool multiline() { return _multiline; }

    /// text content by lines
    protected dstring[] _lines;
    /// token properties by lines - for syntax highlight
    protected TokenPropString[] _tokenProps;

    /// line edit marks
    protected EditStateMark[] _editMarks;
    @property EditStateMark[] editMarks() { return _editMarks; }

    /// returns all lines concatenated delimited by '\n'
    @property dstring text() const {
        if (_lines.length == 0)
            return "";
        if (_lines.length == 1)
            return _lines[0];
        // concat lines
        dchar[] buf;
        foreach(index, item;_lines) {
            if (index)
                buf ~= EOL;
            buf ~= item;
        }
        return cast(dstring)buf;
    }

    /// append one or more lines at end
    void appendLines(dstring[] lines...) {
        TextRange rangeBefore;
        rangeBefore.start = rangeBefore.end = lineEnd(_lines.length ? cast(int)_lines.length - 1 : 0);
        EditOperation op = new EditOperation(EditAction.Replace, rangeBefore, lines);
        performOperation(op, this);
    }

    static alias isAlphaForWordSelection = isAlNum;

    /// get word bounds by position
    TextRange wordBounds(TextPosition pos) {
        TextRange res;
        res.start = pos;
        res.end = pos;
        if (pos.line < 0 || pos.line >= _lines.length)
            return res;
        dstring s = line(pos.line);
        int p = pos.pos;
        if (p < 0 || p > s.length || s.length == 0)
            return res;
        dchar leftChar = p > 0 ? s[p - 1] : 0;
        dchar rightChar = p < s.length - 1 ? s[p + 1] : 0;
        dchar centerChar = p < s.length ? s[p] : 0;
        if (isAlphaForWordSelection(centerChar)) {
            // ok
        } else if (isAlphaForWordSelection(leftChar)) {
            p--;
        } else if (isAlphaForWordSelection(rightChar)) {
            p++;
        } else {
            return res;
        }
        int start = p;
        int end = p;
        while (start > 0 && isAlphaForWordSelection(s[start - 1]))
            start--;
        while (end  + 1 < s.length && isAlphaForWordSelection(s[end + 1]))
            end++;
        end++;
        res.start.pos = start;
        res.end.pos = end;
        return res;
    }

    /// call listener to say that whole content is replaced e.g. by loading from file
    void notifyContentReplaced() {
        clearEditMarks();
        TextRange rangeBefore;
        TextRange rangeAfter;
        // notify about content change
        handleContentChange(new EditOperation(EditAction.ReplaceContent), rangeBefore, rangeAfter, this);
    }

    /// call listener to say that content is saved
    void notifyContentSaved() {
        // mark all changed lines as saved
        foreach(i; 0 .. _editMarks.length) {
            if (_editMarks[i] == EditStateMark.changed)
                _editMarks[i] = EditStateMark.saved;
        }
        TextRange rangeBefore;
        TextRange rangeAfter;
        // notify about content change
        handleContentChange(new EditOperation(EditAction.SaveContent), rangeBefore, rangeAfter, this);
    }

    bool findMatchedBraces(TextPosition p, out TextRange range) {
        if (!_syntaxSupport)
            return false;
        TextPosition p2 = _syntaxSupport.findPairedBracket(p);
        if (p == p2)
            return false;
        if (p < p2) {
            range.start = p;
            range.end = p2;
        } else {
            range.start = p2;
            range.end = p;
        }
        return true;
    }

    protected void updateTokenProps(int startLine, int endLine) {
        clearTokenProps(startLine, endLine);
        if (_syntaxSupport) {
            _syntaxSupport.updateHighlight(_lines, _tokenProps, startLine, endLine);
        }
    }

    protected void markChangedLines(int startLine, int endLine) {
        foreach(i; startLine .. endLine) {
            _editMarks[i] = EditStateMark.changed;
        }
    }

    /// set props arrays size equal to text line sizes, bit fill with unknown token
    protected void clearTokenProps(int startLine, int endLine) {
        foreach(i; startLine .. endLine) {
            if (hasSyntaxHighlight) {
                int len = cast(int)_lines[i].length;
                _tokenProps[i].length = len;
                foreach(j; 0 .. len)
                    _tokenProps[i][j] = TOKEN_UNKNOWN;
            } else {
                _tokenProps[i] = null; // no token props
            }
        }
    }

    void clearEditMarks() {
        _editMarks.length = _lines.length;
        foreach(i; 0 .. _editMarks.length)
            _editMarks[i] = EditStateMark.unchanged;
    }

    /// replace whole text with another content
    @property EditableContent text(dstring newContent) {
        clearUndo();
        _lines.length = 0;
        if (_multiline) {
            _lines = splitDString(newContent);
            _tokenProps.length = _lines.length;
            updateTokenProps(0, cast(int)_lines.length);
        } else {
            _lines.length = 1;
            _lines[0] = replaceEolsWithSpaces(newContent);
            _tokenProps.length = 1;
            updateTokenProps(0, cast(int)_lines.length);
        }
        clearEditMarks();
        notifyContentReplaced();
        return this;
    }

    /// clear content
    void clear() {
        clearUndo();
        clearEditMarks();
        _lines.length = 0;
    }


    /// returns line count
    @property int length() { return cast(int)_lines.length; }
    dstring opIndex(int index) {
        return line(index);
    }

    /// returns line text by index, "" if index is out of bounds
    dstring line(int index) {
        return index >= 0 && index < _lines.length ? _lines[index] : ""d;
    }

    /// returns character at position lineIndex, pos
    dchar opIndex(int lineIndex, int pos) {
        dstring s = line(lineIndex);
        if (pos >= 0 && pos < s.length)
            return s[pos];
        return 0;
    }
    /// returns character at position lineIndex, pos
    dchar opIndex(TextPosition p) {
        dstring s = line(p.line);
        if (p.pos >= 0 && p.pos < s.length)
            return s[p.pos];
        return 0;
    }

    /// returns line token properties one item per character (index is 0 based line number)
    TokenPropString lineTokenProps(int index) {
        return index >= 0 && index < _tokenProps.length ? _tokenProps[index] : null;
    }

    /// returns token properties character position
    TokenProp tokenProp(TextPosition p) {
        return p.line >= 0 && p.line < _tokenProps.length && p.pos >= 0 && p.pos < _tokenProps[p.line].length  ? _tokenProps[p.line][p.pos] : 0;
    }

    /// returns position for end of last line
    @property TextPosition endOfFile() {
        return TextPosition(cast(int)_lines.length - 1, cast(int)_lines[$-1].length);
    }

    /// returns access to line edit mark by line index (0 based)
    ref EditStateMark editMark(int index) {
        assert (index >= 0 && index < _editMarks.length);
        return _editMarks[index];
    }

    /// returns text position for end of line lineIndex
    TextPosition lineEnd(int lineIndex) {
        return TextPosition(lineIndex, lineLength(lineIndex));
    }

    /// returns text position for begin of line lineIndex (if lineIndex > number of lines, returns end of last line)
    TextPosition lineBegin(int lineIndex) {
        if (lineIndex >= _lines.length)
            return lineEnd(lineIndex - 1);
        return TextPosition(lineIndex, 0);
    }

    /// returns previous character position
    TextPosition prevCharPos(TextPosition p) {
        if (p.line < 0)
            return TextPosition(0, 0);
        p.pos--;
        for (;;) {
            if (p.line < 0)
                return TextPosition(0, 0);
            if (p.pos >= 0 && p.pos < lineLength(p.line))
                return p;
            p.line--;
            p.pos = lineLength(p.line) - 1;
        }
    }

    /// returns previous character position
    TextPosition nextCharPos(TextPosition p) {
        TextPosition eof = endOfFile();
        if (p >= eof)
            return eof;
        p.pos++;
        for (;;) {
            if (p >= eof)
                return eof;
            if (p.pos >= 0 && p.pos < lineLength(p.line))
                return p;
            p.line++;
            p.pos = 0;
        }
    }

    /// returns text range for whole line lineIndex
    TextRange lineRange(int lineIndex) {
        return TextRange(TextPosition(lineIndex, 0), lineIndex < cast(int)_lines.length - 1 ? lineBegin(lineIndex + 1) : lineEnd(lineIndex));
    }

    /// find nearest next tab position
    int nextTab(int pos) {
        return (pos + tabSize) / tabSize * tabSize;
    }

    /// to return information about line space positions
    static struct LineWhiteSpace {
        int firstNonSpaceIndex = -1;
        int firstNonSpaceColumn = -1;
        int lastNonSpaceIndex = -1;
        int lastNonSpaceColumn = -1;
        @property bool empty() { return firstNonSpaceColumn < 0; }
    }

    LineWhiteSpace getLineWhiteSpace(int lineIndex) {
        LineWhiteSpace res;
        if (lineIndex < 0 || lineIndex >= _lines.length)
            return res;
        dstring s = _lines[lineIndex];
        int x = 0;
        for (int i = 0; i < s.length; i++) {
            dchar ch = s[i];
            if (ch == '\t') {
                x = (x + _tabSize) / _tabSize * _tabSize;
            } else if (ch == ' ') {
                x++;
            } else {
                if (res.firstNonSpaceIndex < 0) {
                    res.firstNonSpaceIndex = i;
                    res.firstNonSpaceColumn = x;
                }
                res.lastNonSpaceIndex = i;
                res.lastNonSpaceColumn = x;
                x++;
            }
        }
        return res;
    }

    /// returns spaces/tabs for filling from the beginning of line to specified position
    dstring fillSpace(int pos) {
        dchar[] buf;
        int x = 0;
        while (x + tabSize <= pos) {
            if (useSpacesForTabs) {
                foreach(i; 0 .. tabSize)
                    buf ~= ' ';
            } else {
                buf ~= '\t';
            }
            x += tabSize;
        }
        while (x < pos) {
            buf ~= ' ';
            x++;
        }
        return cast(dstring)buf;
    }

    /// measures line non-space start and end positions
    TextLineMeasure measureLine(int lineIndex) {
        TextLineMeasure res;
        dstring s = _lines[lineIndex];
        res.len = cast(int)s.length;
        if (lineIndex < 0 || lineIndex >= _lines.length)
            return res;
        int x = 0;
        for (int i = 0; i < s.length; i++) {
            dchar ch = s[i];
            if (ch == ' ') {
                x++;
            } else if (ch == '\t') {
                x = (x + _tabSize) / _tabSize * _tabSize;
            } else {
                if (res.firstNonSpace < 0) {
                    res.firstNonSpace = i;
                    res.firstNonSpaceX = x;
                }
                res.lastNonSpace = i;
                res.lastNonSpaceX = x;
                x++;
            }
        }
        return res;
    }

    /// return true if line with index lineIndex is empty (has length 0 or consists only of spaces and tabs)
    bool lineIsEmpty(int lineIndex) {
        if (lineIndex < 0 || lineIndex >= _lines.length)
            return true;
        dstring s = _lines[lineIndex];
        foreach(ch; s)
            if (ch != ' ' && ch != '\t')
                return false;
        return true;
    }

    /// corrent range to cover full lines
    TextRange fullLinesRange(TextRange r) {
        r.start.pos = 0;
        if (r.end.pos > 0 || r.start.line == r.end.line)
            r.end = lineBegin(r.end.line + 1);
        return r;
    }

    /// returns position before first non-space character of line, returns 0 position if no non-space chars
    TextPosition firstNonSpace(int lineIndex) {
        dstring s = line(lineIndex);
        for (int i = 0; i < s.length; i++)
            if (s[i] != ' ' && s[i] != '\t')
                return TextPosition(lineIndex, i);
        return TextPosition(lineIndex, 0);
    }

    /// returns position after last non-space character of line, returns 0 position if no non-space chars on line
    TextPosition lastNonSpace(int lineIndex) {
        dstring s = line(lineIndex);
        for (int i = cast(int)s.length - 1; i >= 0; i--)
            if (s[i] != ' ' && s[i] != '\t')
                return TextPosition(lineIndex, i + 1);
        return TextPosition(lineIndex, 0);
    }

    /// returns text position for end of line lineIndex
    int lineLength(int lineIndex) {
        return lineIndex >= 0 && lineIndex < _lines.length ? cast(int)_lines[lineIndex].length : 0;
    }

    /// returns maximum length of line
    int maxLineLength() {
        int m = 0;
        foreach(s; _lines)
            if (m < s.length)
                m = cast(int)s.length;
        return m;
    }

    void handleContentChange(EditOperation op, ref TextRange rangeBefore, ref TextRange rangeAfter, Object source) {
        // update highlight if necessary
        updateTokenProps(rangeAfter.start.line, rangeAfter.end.line + 1);
        LineIcon[] moved;
        LineIcon[] removed;
        if (_lineIcons.updateLinePositions(rangeBefore, rangeAfter, moved, removed)) {
            if (marksChanged.assigned)
                marksChanged(this, moved, removed);
        }
        // call listeners
        if (contentChanged.assigned)
            contentChanged(this, op, rangeBefore, rangeAfter, source);
    }

    /// return edit marks for specified range
    EditStateMark[] rangeMarks(TextRange range) {
        EditStateMark[] res;
        if (range.empty) {
            res ~= EditStateMark.unchanged;
            return res;
        }
        for (int lineIndex = range.start.line; lineIndex <= range.end.line; lineIndex++) {
            res ~= _editMarks[lineIndex];
        }
        return res;
    }

    /// return text for specified range
    dstring[] rangeText(TextRange range) {
        dstring[] res;
        if (range.empty) {
            res ~= ""d;
            return res;
        }
        for (int lineIndex = range.start.line; lineIndex <= range.end.line; lineIndex++) {
            dstring lineText = line(lineIndex);
            dstring lineFragment = lineText;
            int startchar = (lineIndex == range.start.line) ? range.start.pos : 0;
            int endchar = (lineIndex == range.end.line) ? range.end.pos : cast(int)lineText.length;
            if (endchar > lineText.length)
                endchar = cast(int)lineText.length;
            if (endchar <= startchar)
                lineFragment = ""d;
            else if (startchar != 0 || endchar != lineText.length)
                lineFragment = lineText[startchar .. endchar].dup;
            res ~= lineFragment;
        }
        return res;
    }

    /// when position is out of content bounds, fix it to nearest valid position
    void correctPosition(ref TextPosition position) {
        if (position.line >= length) {
            position.line = length - 1;
            position.pos = lineLength(position.line);
        }
        if (position.line < 0) {
            position.line = 0;
            position.pos = 0;
        }
        int currentLineLength = lineLength(position.line);
        if (position.pos > currentLineLength)
            position.pos = currentLineLength;
        if (position.pos < 0)
            position.pos = 0;
    }

    /// when range positions is out of content bounds, fix it to nearest valid position
    void correctRange(ref TextRange range) {
        correctPosition(range.start);
        correctPosition(range.end);
    }

    /// removes removedCount lines starting from start
    protected void removeLines(int start, int removedCount) {
        int end = start + removedCount;
        assert(removedCount > 0 && start >= 0 && end > 0 && start < _lines.length && end <= _lines.length);
        for (int i = start; i < _lines.length - removedCount; i++) {
            _lines[i] = _lines[i + removedCount];
            _tokenProps[i] = _tokenProps[i + removedCount];
            _editMarks[i] = _editMarks[i + removedCount];
        }
        for (int i = cast(int)_lines.length - removedCount; i < _lines.length; i++) {
            _lines[i] = null; // free unused line references
            _tokenProps[i] = null; // free unused line references
            _editMarks[i] = EditStateMark.unchanged; // free unused line references
        }
        _lines.length -= removedCount;
        _tokenProps.length = _lines.length;
        _editMarks.length = _lines.length;
    }

    /// inserts count empty lines at specified position
    protected void insertLines(int start, int count)
    in { assert(count > 0); }
    body {
        _lines.length += count;
        _tokenProps.length = _lines.length;
        _editMarks.length = _lines.length;
        for (int i = cast(int)_lines.length - 1; i >= start + count; i--) {
            _lines[i] = _lines[i - count];
            _tokenProps[i] = _tokenProps[i - count];
            _editMarks[i] = _editMarks[i - count];
        }
        foreach(i; start .. start + count) {
            _lines[i] = ""d;
            _tokenProps[i] = null;
            _editMarks[i] = EditStateMark.changed;
        }
    }

    /// inserts or removes lines, removes text in range
    protected void replaceRange(TextRange before, TextRange after, dstring[] newContent, EditStateMark[] marks = null) {
        dstring firstLineBefore = line(before.start.line);
        dstring lastLineBefore = before.singleLine ? firstLineBefore : line(before.end.line);
        dstring firstLineHead = before.start.pos > 0 && before.start.pos <= firstLineBefore.length ? firstLineBefore[0..before.start.pos] : ""d;
        dstring lastLineTail = before.end.pos >= 0 && before.end.pos < lastLineBefore.length ? lastLineBefore[before.end.pos .. $] : ""d;

        int linesBefore = before.lines;
        int linesAfter = after.lines;
        if (linesBefore < linesAfter) {
            // add more lines
            insertLines(before.start.line + 1, linesAfter - linesBefore);
        } else if (linesBefore > linesAfter) {
            // remove extra lines
            removeLines(before.start.line + 1, linesBefore - linesAfter);
        }
        foreach(int i; after.start.line .. after.end.line + 1) {
            if (marks) {
                //if (i - after.start.line < marks.length)
                _editMarks[i] = marks[i - after.start.line];
            }
            dstring newline = newContent[i - after.start.line];
            if (i == after.start.line && i == after.end.line) {
                dchar[] buf;
                buf ~= firstLineHead;
                buf ~= newline;
                buf ~= lastLineTail;
                //Log.d("merging lines ", firstLineHead, " ", newline, " ", lastLineTail);
                _lines[i] = cast(dstring)buf;
                clearTokenProps(i, i + 1);
                if (!marks)
                    markChangedLines(i, i + 1);
                //Log.d("merge result: ", _lines[i]);
            } else if (i == after.start.line) {
                dchar[] buf;
                buf ~= firstLineHead;
                buf ~= newline;
                _lines[i] = cast(dstring)buf;
                clearTokenProps(i, i + 1);
                if (!marks)
                    markChangedLines(i, i + 1);
            } else if (i == after.end.line) {
                dchar[] buf;
                buf ~= newline;
                buf ~= lastLineTail;
                _lines[i] = cast(dstring)buf;
                clearTokenProps(i, i + 1);
                if (!marks)
                    markChangedLines(i, i + 1);
            } else {
                _lines[i] = newline; // no dup needed
                clearTokenProps(i, i + 1);
                if (!marks)
                    markChangedLines(i, i + 1);
            }
        }
    }


    static alias isDigit = std.uni.isNumber;
    static bool isAlpha(dchar ch) pure nothrow {
        static import std.uni;
        return std.uni.isAlpha(ch) || ch == '_';
    }
    static bool isAlNum(dchar ch) pure nothrow {
        static import std.uni;
        return isDigit(ch) || isAlpha(ch);
    }
    static bool isLowerAlpha(dchar ch) pure nothrow {
        static import std.uni;
        return std.uni.isLower(ch) || ch == '_';
    }
    static alias isUpperAlpha = std.uni.isUpper;
    static bool isPunct(dchar ch) pure nothrow {
        switch(ch) {
            case '.':
            case ',':
            case ';':
            case '?':
            case '!':
                return true;
            default:
                return false;
        }
    }
    static bool isBracket(dchar ch) pure nothrow {
        switch(ch) {
            case '(':
            case ')':
            case '[':
            case ']':
            case '{':
            case '}':
                return true;
            default:
                return false;
        }
    }

    static bool isWordBound(dchar thischar, dchar nextchar) {
        return  (isAlNum(thischar) && !isAlNum(nextchar))
            || (isPunct(thischar) && !isPunct(nextchar))
            || (isBracket(thischar) && !isBracket(nextchar))
            || (thischar != ' ' && nextchar == ' ');
    }

    /// change text position to nearest word bound (direction < 0 - back, > 0 - forward)
    TextPosition moveByWord(TextPosition p, int direction, bool camelCasePartsAsWords) {
        correctPosition(p);
        TextPosition firstns = firstNonSpace(p.line); // before first non space
        TextPosition lastns = lastNonSpace(p.line); // after last non space
        int linelen = lineLength(p.line); // line length
        if (direction < 0) {
            // back
            if (p.pos <= 0) {
                // beginning of line - move to prev line
                if (p.line > 0)
                    p = lastNonSpace(p.line - 1);
            } else if (p.pos <= firstns.pos) { // before first nonspace
                // to beginning of line
                p.pos = 0;
            } else {
                dstring txt = line(p.line);
                int found = -1;
                for (int i = p.pos - 1; i > 0; i--) {
                    // check if position i + 1 is after word end
                    dchar thischar = i >= 0 && i < linelen ? txt[i] : ' ';
                    if (thischar == '\t')
                        thischar = ' ';
                    dchar nextchar = i - 1 >= 0 && i - 1 < linelen ? txt[i - 1] : ' ';
                    if (nextchar == '\t')
                        nextchar = ' ';
                    if (isWordBound(thischar, nextchar)
                        || (camelCasePartsAsWords && isUpperAlpha(thischar) && isLowerAlpha(nextchar))) {
                            found = i;
                            break;
                        }
                }
                if (found >= 0)
                    p.pos = found;
                else
                    p.pos = 0;
            }
        } else if (direction > 0) {
            // forward
            if (p.pos >= linelen) {
                // last position of line
                if (p.line < length - 1)
                    p = firstNonSpace(p.line + 1);
            } else if (p.pos >= lastns.pos) { // before first nonspace
                // to beginning of line
                p.pos = linelen;
            } else {
                dstring txt = line(p.line);
                int found = -1;
                for (int i = p.pos; i < linelen; i++) {
                    // check if position i + 1 is after word end
                    dchar thischar = txt[i];
                    if (thischar == '\t')
                        thischar = ' ';
                    dchar nextchar = i < linelen - 1 ? txt[i + 1] : ' ';
                    if (nextchar == '\t')
                        nextchar = ' ';
                    if (isWordBound(thischar, nextchar)
                        || (camelCasePartsAsWords && isLowerAlpha(thischar) && isUpperAlpha(nextchar))) {
                            found = i + 1;
                            break;
                        }
                }
                if (found >= 0)
                    p.pos = found;
                else
                    p.pos = linelen;
            }
        }
        return p;
    }

    /// edit content
    bool performOperation(EditOperation op, Object source) {
        if (_readOnly)
            throw new Exception("content is readonly");
        if (op.action == EditAction.Replace) {
            TextRange rangeBefore = op.range;
            assert(rangeBefore.start <= rangeBefore.end);
            //correctRange(rangeBefore);
            dstring[] oldcontent = rangeText(rangeBefore);
            EditStateMark[] oldmarks = rangeMarks(rangeBefore);
            dstring[] newcontent = op.content;
            if (newcontent.length == 0)
                newcontent ~= ""d;
            TextRange rangeAfter = op.range;
            rangeAfter.end = rangeAfter.start;
            if (newcontent.length > 1) {
                // different lines
                rangeAfter.end.line = rangeAfter.start.line + cast(int)newcontent.length - 1;
                rangeAfter.end.pos = cast(int)newcontent[$ - 1].length;
            } else {
                // same line
                rangeAfter.end.pos = rangeAfter.start.pos + cast(int)newcontent[0].length;
            }
            assert(rangeAfter.start <= rangeAfter.end);
            op.newRange = rangeAfter;
            op.oldContent = oldcontent;
            op.oldEditMarks = oldmarks;
            replaceRange(rangeBefore, rangeAfter, newcontent);
            _undoBuffer.saveForUndo(op);
            handleContentChange(op, rangeBefore, rangeAfter, source);
            return true;
        }
        return false;
    }

    /// return true if there is at least one operation in undo buffer
    @property bool hasUndo() {
        return _undoBuffer.hasUndo;
    }
    /// return true if there is at least one operation in redo buffer
    @property bool hasRedo() {
        return _undoBuffer.hasRedo;
    }
    /// undoes last change
    bool undo(Object source) {
        if (!hasUndo)
            return false;
        if (_readOnly)
            throw new Exception("content is readonly");
        EditOperation op = _undoBuffer.undo();
        TextRange rangeBefore = op.newRange;
        dstring[] oldcontent = op.content;
        dstring[] newcontent = op.oldContent;
        EditStateMark[] newmarks = op.oldEditMarks; //_undoBuffer.savedInUndo() ?  : null;
        TextRange rangeAfter = op.range;
        //Log.d("Undoing op rangeBefore=", rangeBefore, " contentBefore=`", oldcontent, "` rangeAfter=", rangeAfter, " contentAfter=`", newcontent, "`");
        replaceRange(rangeBefore, rangeAfter, newcontent, newmarks);
        handleContentChange(op, rangeBefore, rangeAfter, source ? source : this);
        return true;
    }

    /// redoes last undone change
    bool redo(Object source) {
        if (!hasRedo)
            return false;
        if (_readOnly)
            throw new Exception("content is readonly");
        EditOperation op = _undoBuffer.redo();
        TextRange rangeBefore = op.range;
        dstring[] oldcontent = op.oldContent;
        dstring[] newcontent = op.content;
        TextRange rangeAfter = op.newRange;
        //Log.d("Redoing op rangeBefore=", rangeBefore, " contentBefore=`", oldcontent, "` rangeAfter=", rangeAfter, " contentAfter=`", newcontent, "`");
        replaceRange(rangeBefore, rangeAfter, newcontent);
        handleContentChange(op, rangeBefore, rangeAfter, source ? source : this);
        return true;
    }
    /// clear undo/redp history
    void clearUndo() {
        _undoBuffer.clear();
    }

    protected string _filename;
    protected TextFileFormat _format;

    /// file used to load editor content
    @property string filename() {
        return _filename;
    }


    /// load content form input stream
    bool load(InputStream f, string fname = null) {
        import dlangui.core.linestream;
        clear();
        _filename = fname;
        _format = TextFileFormat.init;
        try {
            LineStream lines = LineStream.create(f, fname);
            for (;;) {
                dchar[] s = lines.readLine();
                if (s is null)
                    break;
                int pos = cast(int)(_lines.length++);
                _tokenProps.length = _lines.length;
                _lines[pos] = s.dup;
                clearTokenProps(pos, pos + 1);
            }
            if (lines.errorCode != 0) {
                clear();
                Log.e("Error ", lines.errorCode, " ", lines.errorMessage, " -- at line ", lines.errorLine, " position ", lines.errorPos);
                notifyContentReplaced();
                return false;
            }
            // EOF
            _format = lines.textFormat;
            _undoBuffer.clear();
            debug(FileFormats)Log.d("loaded file:", filename, " format detected:", _format);
            notifyContentReplaced();
            return true;
        } catch (Exception e) {
            Log.e("Exception while trying to read file ", fname, " ", e.toString);
            clear();
            notifyContentReplaced();
            return false;
        }
    }
    /// load content from file
    bool load(string filename) {
        import std.file : exists, isFile;
        import std.exception : ErrnoException;
        clear();
        if (!filename.exists || !filename.isFile) {
            Log.e("Editable.load: File not found ", filename);
            return false;
        }
        try {
            InputStream f;
            f = new FileInputStream(filename);
            scope(exit) { f.close(); }
            bool res = load(f, filename);
            return res;
        } catch (ErrnoException e) {
            Log.e("Editable.load: Exception while trying to read file ", filename, " ", e.toString);
            clear();
            return false;
        } catch (Exception e) {
            Log.e("Editable.load: Exception while trying to read file ", filename, " ", e.toString);
            clear();
            return false;
        }
    }
    /// save to output stream in specified format
    bool save(OutputStream stream, string filename, TextFileFormat format) {
        if (!filename)
            filename = _filename;
        _format = format;
        import dlangui.core.linestream;
        try {
            debug(FileFormats)Log.d("creating output stream, file=", filename, " format=", format);
            OutputLineStream writer = new OutputLineStream(stream, filename, format);
            scope(exit) { writer.close(); }
            for (int i = 0; i < _lines.length; i++) {
                writer.writeLine(_lines[i]);
            }
            _undoBuffer.saved();
            notifyContentSaved();
            return true;
        } catch (Exception e) {
            Log.e("Exception while trying to write file ", filename, " ", e.toString);
            return false;
        }
    }
    /// save to output stream in current format
    bool save(OutputStream stream, string filename) {
        return save(stream, filename, _format);
    }
    /// save to file in specified format
    bool save(string filename, TextFileFormat format) {
        if (!filename)
            filename = _filename;
        try {
            OutputStream f = new FileOutputStream(filename);
            scope(exit) { f.close(); }
            return save(f, filename, format);
        } catch (Exception e) {
            Log.e("Exception while trying to save file ", filename, " ", e.toString);
            return false;
        }
    }
    /// save to file in current format
    bool save(string filename = null) {
        return save(filename, _format);
    }
}

/// types of text editor line icon marks (bookmark / breakpoint / error / ...)
enum LineIconType : int {
    /// bookmark
    bookmark,
    /// breakpoint mark
    breakpoint,
    /// error mark
    error,
}

/// text editor line icon
class LineIcon {
    /// mark type
    LineIconType type;
    /// line number
    int line;
    /// arbitrary parameter
    Object objectParam;
    /// empty
    this() {
    }
    this(LineIconType type, int line, Object obj = null) {
        this.type = type;
        this.line = line;
        this.objectParam = obj;
    }
}

/// text editor line icon list
struct LineIcons {
    private LineIcon[] _items;
    private int _len;

    /// returns count of items
    @property int length() { return _len; }
    /// returns item by index, or null if index out of bounds
    LineIcon opIndex(int index) {
        if (index < 0 || index >= _len)
            return null;
        return _items[index];
    }
    private void insert(LineIcon icon, int index) {
        if (index < 0)
            index = 0;
        if (index > _len)
            index = _len;
        if (_items.length <= index)
            _items.length = index + 16;
        if (index < _len) {
            for (size_t i = _len; i > index; i--)
                _items[i] = _items[i - 1];
        }
        _items[index] = icon;
        _len++;
    }
    private int findSortedIndex(int line, LineIconType type) {
        // TODO: use binary search
        for (int i = 0; i < _len; i++) {
            if (_items[i].line > line || _items[i].type > type) {
                return i;
            }
        }
        return _len;
    }
    /// add icon mark
    void add(LineIcon icon) {
        int index = findSortedIndex(icon.line, icon.type);
        insert(icon, index);
    }
    /// add all icons from list
    void addAll(LineIcon[] list) {
        foreach(item; list)
            add(item);
    }
    /// remove icon mark by index
    LineIcon remove(int index) {
        if (index < 0 || index >= _len)
            return null;
        LineIcon res = _items[index];
        for (int i = index; i < _len - 1; i++)
            _items[i] = _items[i + 1];
        _items[_len] = null;
        _len--;
        return res;
    }

    /// remove icon mark
    LineIcon remove(LineIcon icon) {
        // same object
        for (int i = 0; i < _len; i++) {
            if (_items[i] is icon)
                return remove(i);
        }
        // has the same objectParam
        for (int i = 0; i < _len; i++) {
            if (_items[i].objectParam !is null && icon.objectParam !is null && _items[i].objectParam is icon.objectParam)
                return remove(i);
        }
        // has same line and type
        for (int i = 0; i < _len; i++) {
            if (_items[i].line == icon.line && _items[i].type == icon.type)
                return remove(i);
        }
        return null;
    }

    /// remove all icon marks of specified type, return true if any of items removed
    bool removeByType(LineIconType type) {
        bool res = false;
        for (int i = _len - 1; i >= 0; i--) {
            if (_items[i].type == type) {
                remove(i);
                res = true;
            }
        }
        return res;
    }
    /// get array of icons of specified type
    LineIcon[] findByType(LineIconType type) {
        LineIcon[] res;
        for (int i = 0; i < _len; i++) {
            if (_items[i].type == type)
                res ~= _items[i];
        }
        return res;
    }
    /// get array of icons of specified type
    LineIcon findByLineAndType(int line, LineIconType type) {
        for (int i = 0; i < _len; i++) {
            if (_items[i].type == type && _items[i].line == line)
                return _items[i];
        }
        return null;
    }
    /// update mark position lines after text change, returns true if any of marks were moved or removed
    bool updateLinePositions(TextRange rangeBefore, TextRange rangeAfter, ref LineIcon[] moved, ref LineIcon[] removed) {
        moved = null;
        removed = null;
        bool res = false;
        for (int i = _len - 1; i >= 0; i--) {
            LineIcon item = _items[i];
            if (rangeBefore.start.line > item.line && rangeAfter.start.line > item.line)
                continue; // line is before ranges
            else if (rangeBefore.start.line < item.line || rangeAfter.start.line < item.line) {
                // line is fully after change
                int deltaLines = rangeAfter.end.line - rangeBefore.end.line;
                if (!deltaLines)
                    continue;
                if (deltaLines < 0 && rangeBefore.end.line >= item.line && rangeAfter.end.line < item.line) {
                    // remove
                    removed ~= item;
                    remove(i);
                    res = true;
                } else {
                    // move
                    item.line += deltaLines;
                    moved ~= item;
                    res = true;
                }
            }
        }
        return res;
    }

    LineIcon findNext(LineIconType type, int line, int direction) {
        LineIcon firstBefore;
        LineIcon firstAfter;
        if (direction < 0) {
            // backward
            for (int i = _len - 1; i >= 0; i--) {
                LineIcon item = _items[i];
                if (item.type != type)
                    continue;
                if (!firstBefore && item.line >= line)
                    firstBefore = item;
                else if (!firstAfter && item.line < line)
                    firstAfter = item;
            }
        } else {
            // forward
            for (int i = 0; i < _len; i++) {
                LineIcon item = _items[i];
                if (item.type != type)
                    continue;
                if (!firstBefore && item.line <= line)
                    firstBefore = item;
                else if (!firstAfter && item.line > line)
                    firstAfter = item;
            }
        }
        if (firstAfter)
            return firstAfter;
        return firstBefore;
    }

    @property bool hasBookmarks() {
        for (int i = 0; i < _len; i++) {
            if (_items[i].type == LineIconType.bookmark)
                return true;
        }
        return false;
    }

    void toggleBookmark(int line) {
        LineIcon existing = findByLineAndType(line, LineIconType.bookmark);
        if (existing)
            remove(existing);
        else
            add(new LineIcon(LineIconType.bookmark, line));
    }
}

