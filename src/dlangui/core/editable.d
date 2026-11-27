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
public import dlangui.core.filewatch : FileState, FileChangeKind;
static import std.stdio;
import std.algorithm;
import std.conv : to;
static import std.uni;

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
ubyte tokenCategory(ubyte t) @safe pure nothrow @nogc {
    return t & 0xF0;
}

/// split dstring by delimiters
dstring[] splitDString(dstring source, dchar delimiter = EOL) @safe pure nothrow {
    int start = 0;
    dstring[] res;
    for (int i = 0; i <= source.length; i++) {
        if (i == source.length || source[i] == delimiter) {
            if (i >= start) {
                dchar prevchar = i > 1 && i > start + 1 ? source[i - 1] : 0;
                int end = i;
                if (delimiter == EOL && prevchar == '\r') // windows CR/LF
                    end--;
                dstring line = i > start ? source[start .. end].idup : ""d;
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
dstring concatDStrings(dstring[] lines, dstring delimiter = SYSTEM_DEFAULT_EOL) @safe pure nothrow {
    dchar[] buf;
    foreach(i, line; lines) {
        if(i > 0)
            buf ~= delimiter;
        buf ~= line;
    }
    return (() @trusted => cast(dstring)buf)(); // buf is a new array, not referenced elsewhere
}

/// replace end of lines with spaces
dstring replaceEolsWithSpaces(dstring source) @safe pure nothrow {
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
    return (() @trusted => cast(dstring)buf)(); // buf is a new array, not referenced elsewhere
}

/// text content position
struct TextPosition {
    /// line number, zero based
    int line;
    /// character position in line (0 == before first character)
    int pos;
@safe:
    /// compares two positions
    int opCmp(ref const TextPosition v) const pure nothrow @nogc {
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
    bool opEquals(ref inout TextPosition v) inout pure nothrow @nogc {
        return line == v.line && pos == v.pos;
    }
    /// hash consistent with opEquals
    size_t toHash() const @safe pure nothrow {
        return hashOf(pos, hashOf(line));
    }
    @property string toString() const {
        return to!string(line) ~ ":" ~ to!string(pos);
    }
    /// adds deltaPos to position and returns result
    TextPosition offset(int deltaPos) const pure nothrow @nogc {
        return TextPosition(line, pos + deltaPos);
    }
}

/// text content range
struct TextRange {
    TextPosition start;
    TextPosition end;
@safe:
    bool intersects(const ref TextRange v) const pure nothrow @nogc {
        if (start >= v.end)
            return false;
        if (end <= v.start)
            return false;
        return true;
    }
    /// returns true if position is inside this range
    bool isInside(TextPosition p) const pure nothrow @nogc {
        return start <= p && end > p;
    }
    /// returns true if position is inside this range or right after this range
    bool isInsideOrNext(TextPosition p) const pure nothrow @nogc {
        return start <= p && end >= p;
    }
    /// returns true if range is empty
    @property bool empty() const pure nothrow @nogc {
        return end <= start;
    }
    /// returns true if start and end located at the same line
    @property bool singleLine() const pure nothrow @nogc {
        return end.line == start.line;
    }
    /// returns count of lines in range
    @property int lines() const pure nothrow @nogc {
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
        // removing single character (both removed texts within one line: a line break isn't a character here, #954)
        if (_newRange.empty && op._newRange.empty && _oldContent.length == 1 && op._oldContent.length == 1
                && op._oldContent[0].length == 1) {
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
        // don't merge into the operation that marks the saved state: modified would stay false (#948)
        if (!_undoList.empty && _undoList.back !is _savedState) {
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
    int accumulation(int wrapLine, bool wrapPointInfo) @safe pure nothrow @nogc
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
    @property bool empty() const @safe pure nothrow @nogc { return len == 0 || firstNonSpace < 0; }
}

/// editable plain text (singleline/multiline)
class EditableContent {

    this(bool multiline) {
        _multiline = multiline;
        _lines.length = 1; // initial state: single empty line
        _editMarks.length = 1;
        _undoBuffer = new UndoBuffer();
        newRevision();
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

    /// not used by wordBounds() any more, which counts combining marks as parts of words (isWordCharAt, #1168)
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
        // combining marks and ZWNJ/ZWJ are parts of the word they follow (#1168)
        if (isWordCharAt(s, p)) {
            // ok
        } else if (isWordCharAt(s, p - 1)) {
            p--;
        } else if (isWordCharAt(s, p + 1)) {
            p++;
        } else {
            return res;
        }
        int start = p;
        int end = p;
        while (start > 0 && isWordCharAt(s, start - 1))
            start--;
        while (end  + 1 < s.length && isWordCharAt(s, end + 1))
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
        _invalidCharCount = 0;
        _invalidCharPositions = null;
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
        newRevision();
        clearUndo();
        clearEditMarks();
        _lines.length = 0;
        _invalidCharCount = 0;
        _invalidCharPositions = null;
    }

    /// content must have at least one (possibly empty) line, like after `text = ""`
    protected void ensureLineExists() {
        if (_lines.length)
            return;
        _lines.length = 1;
        _tokenProps.length = 1;
        clearTokenProps(0, 1);
        clearEditMarks();
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

    /// identifies the state of the text: a new value with each change of the text (edits, undo and redo, new
    /// content, clear(); not saving), never the same in two content objects. Positions noted with a value refer to
    /// this text while it stays the same (#1166)
    @property ulong revision() const @safe pure nothrow @nogc { return _revision; }
    private ulong _revision;
    private static ulong _lastRevision; // per thread, as the UI is
    private void newRevision() @safe nothrow @nogc { _revision = ++_lastRevision; }

    void handleContentChange(EditOperation op, ref TextRange rangeBefore, ref TextRange rangeAfter, Object source) {
        if (op.action != EditAction.SaveContent)
            newRevision();
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
    do {
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
    /// letters and numbers (std.uni.isAlphaNum, so also e.g. '²', '½', '①') and combining marks of any script, '_',
    /// and ZWNJ/ZWJ (parts of words in Persian and Indic scripts) make up words, without context: for whole-word
    /// search and the highlight of a selected word (EditBox, #1147); word selection and moving by words use
    /// isWordCharAt (#1168)
    static bool isWordChar(dchar ch) @safe pure nothrow @nogc {
        return ch == '_' || isAlphaNum(ch) || isWordJoiner(ch);
    }
    /// a combining mark (std.uni.isMark, also variation selectors) or ZWNJ/ZWJ: part of the cluster before it
    private static bool isWordJoiner(dchar ch) @safe pure nothrow @nogc {
        import std.uni : isMark;
        return ch == '\u200C' || ch == '\u200D' || isMark(ch);
    }
    private static bool isAlphaNum(dchar ch) @safe pure nothrow @nogc {
        static import std.uni;
        return std.uni.isAlphaNum(ch);
    }
    /// the character before the combining marks and ZWNJ/ZWJ at txt[i], or txt[i] itself; 0 outside txt. At most
    /// 30 of them are skipped (the longest cluster of the Unicode stream-safe format), so scanning a line of
    /// thousands of marks stays linear: a longer run counts as no word
    static dchar baseCharAt(const(dchar)[] txt, ptrdiff_t i) @safe pure nothrow @nogc {
        if (i < 0 || i >= txt.length)
            return 0;
        for (int skipped = 0; i > 0 && isWordJoiner(txt[i]) && skipped < 30; skipped++)
            i--;
        return txt[i];
    }
    /// txt[i] is part of a word (false outside txt): a letter, number or '_', or a combining mark or ZWNJ/ZWJ after
    /// one, so the marks of a decomposed letter or an Indic syllable are inside a word, while a joiner in an emoji
    /// sequence or a variation selector after a symbol isn't (#1168)
    static bool isWordCharAt(const(dchar)[] txt, ptrdiff_t i) @safe pure nothrow @nogc {
        if (i < 0 || i >= txt.length)
            return false;
        dchar base = baseCharAt(txt, i);
        return base == '_' || isAlphaNum(base);
    }
    static bool isLowerAlpha(dchar ch) pure nothrow {
        static import std.uni;
        return std.uni.isLower(ch) || ch == '_';
    }
    static alias isUpperAlpha = std.uni.isUpper;
    static bool isPunct(dchar ch) @safe pure nothrow @nogc {
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
    static bool isBracket(dchar ch) @safe pure nothrow @nogc {
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

    /// word bounds without context; moveByWord() uses isWordBoundAt, which counts combining marks as parts of words
    static bool isWordBound(dchar thischar, dchar nextchar) {
        return  (isAlNum(thischar) && !isAlNum(nextchar))
            || (isPunct(thischar) && !isPunct(nextchar))
            || (isBracket(thischar) && !isBracket(nextchar))
            || (thischar != ' ' && nextchar == ' ');
    }

    /// isWordBound for the characters at txt[i] and txt[next] (a space outside the line, tabs as spaces): combining
    /// marks and ZWNJ/ZWJ count as parts of the word they follow (isWordCharAt, #1168)
    static bool isWordBoundAt(const(dchar)[] txt, ptrdiff_t i, ptrdiff_t next) @safe pure nothrow @nogc {
        static dchar charAt(const(dchar)[] txt, ptrdiff_t i) {
            dchar ch = i >= 0 && i < txt.length ? txt[i] : ' ';
            return ch == '\t' ? ' ' : ch;
        }
        // never between a character and a combining mark or joiner after it, also after punctuation
        ptrdiff_t later = i > next ? i : next;
        if (later >= 0 && later < txt.length && isWordJoiner(txt[later]))
            return false;
        dchar thischar = charAt(txt, i);
        dchar nextchar = charAt(txt, next);
        return (isWordCharAt(txt, i) && !isWordCharAt(txt, next))
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
                    // camel case: the letter before the marks of a decomposed letter (#1168)
                    if (isWordBoundAt(txt, i, i - 1)
                        || (camelCasePartsAsWords && i < linelen && isUpperAlpha(txt[i])
                            && isLowerAlpha(baseCharAt(txt, i - 1)))) {
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
                    // camel case: the letter before the marks of a decomposed letter (#1168)
                    if (isWordBoundAt(txt, i, i + 1)
                        || (camelCasePartsAsWords && i + 1 < linelen && isLowerAlpha(baseCharAt(txt, i))
                            && isUpperAlpha(txt[i + 1]))) {
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
        dstring[] newcontent = op.oldContent;
        EditStateMark[] newmarks = op.oldEditMarks; //_undoBuffer.savedInUndo() ?  : null;
        TextRange rangeAfter = op.range;
        //Log.d("Undoing op rangeBefore=", rangeBefore, " contentBefore=`", op.content, "` rangeAfter=", rangeAfter, " contentAfter=`", newcontent, "`");
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
        dstring[] newcontent = op.content;
        TextRange rangeAfter = op.newRange;
        //Log.d("Redoing op rangeBefore=", rangeBefore, " contentBefore=`", op.oldContent, "` rangeAfter=", rangeAfter, " contentAfter=`", newcontent, "`");
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
    protected uint _invalidCharCount;

    /// number of invalid characters (byte sequences) replaced by U+FFFD when the content was loaded from a file
    /// (#924): saving writes U+FFFD instead of the original bytes, so an application may warn after loading.
    /// 0 after clear(), setting the text and a successful save (the saved file has no invalid bytes).
    @property uint invalidCharCount() {
        return _invalidCharCount;
    }
    /// line and character (1-based) of the first invalid characters (at most 3) when the content was loaded (#944)
    @property const(LineStream.InvalidCharPosition)[] invalidCharPositions() {
        return _invalidCharPositions;
    }
    protected LineStream.InvalidCharPosition[] _invalidCharPositions;
    /// the warning logged after loading a file with invalid characters: one message, also for millions of them
    static string invalidCharsMessage(string filename, uint count, const(LineStream.InvalidCharPosition)[] positions,
            EncodingType encoding) {
        string res = "File " ~ filename ~ ": " ~ to!string(count) ~ (count == 1 ? " invalid character" : " invalid characters")
            ~ " for " ~ to!string(encoding) ~ " replaced by U+FFFD";
        foreach (i, p; positions)
            res ~= (i ? ", " : count == 1 ? ", at " : ", first at ") ~ to!string(p.line) ~ ":" ~ to!string(p.pos);
        if (positions.length && count > positions.length)
            res ~= " (and " ~ to!string(count - positions.length) ~ " more)";
        return res;
    }

    /// file used to load editor content
    @property string filename() {
        return _filename;
    }

    protected FileState _fileState;
    protected bool _fileStateUncertain;
    protected bool _keepFileContent;
    protected immutable(ubyte)[] _fileContent;

    /**
    The state of the file when the content was loaded from it (#1276): size, time, file id, and the checksum of the
    bytes read unless the file was loaded without a copy in memory (larger than `maxInMemoryLoadSize`). Compare it
    with `FileState.read(filename, true)` to find out whether another program changed the file. A successful save
    to a file makes that file the new baseline; changing the text doesn't change it (it describes the file, not the
    text). `exists` is false when the content didn't come from a file, or loading it failed.
    */
    @property ref const(FileState) fileState() const {
        return _fileState;
    }

    /// true if the file kept changing while it was loaded (another program still writing it): the content was
    /// loaded anyway, and `fileState` may not match it
    @property bool fileStateUncertain() const {
        return _fileStateUncertain;
    }

    /// keep the raw bytes of the loaded file in `fileContent`, for an exact compare with the disk and a diff view
    @property bool keepFileContent() const {
        return _keepFileContent;
    }
    /// ditto
    @property EditableContent keepFileContent(bool keep) {
        _keepFileContent = keep;
        if (!keep)
            _fileContent = null;
        return this;
    }

    /// the bytes of the loaded file, with `keepFileContent` (null otherwise, and for files loaded without a copy)
    @property immutable(ubyte)[] fileContent() const {
        return _fileContent;
    }

    /// files larger than this are decoded while they are read, without a copy in memory: their `fileState` has no
    /// checksum and `fileContent` stays null
    static __gshared ulong maxInMemoryLoadSize = 64 * 1024 * 1024;

    /// how often load(filename) reads a file again when it changes while it is read
    enum LOAD_RETRIES = 3;

    version (unittest) {
        // called after the bytes of a file are read and before its state is read again (attempt 0, 1, ...)
        static void delegate(int attempt) testHookAfterRead;
    }

    /**
    Compares the file on disk with `fileState`, the state of the file when it was loaded or saved (#1278):
    `unchanged`, `modified`, `deleted`, or `created` when a file that was missing at load time has appeared. Content
    that didn't come from a file is always `unchanged`, and so is a file whose state can't be read now.

    Size, time and file id are compared first. The file is read and compared by content when only the time or file
    id differs (a file touched, or replaced by a copy) and the content was loaded with a checksum, and always when
    `fileStateUncertain` is set (the file changed while it was loaded); the checksum of the bytes loaded decides, and
    with `keepFileContent` the bytes themselves. Identical content then becomes the new baseline, so the next check
    doesn't read the file again, and the state is no longer uncertain. Without a checksum (files larger than
    `maxInMemoryLoadSize`) an uncertain state is `modified`.

    Doesn't change the text: the caller reloads (`reload()`, #1279) or keeps it (`acceptExternalState()`).
    */
    FileChangeKind checkExternalChange() {
        if (!_fileState.path.length)
            return FileChangeKind.unchanged;
        FileState current = FileState.read(_fileState.path);
        if (current.unknown)
            return FileChangeKind.unchanged; // can't tell now
        if (_fileState.unknown && !_fileState.hasChecksum) {
            // loading failed because the state couldn't be read: the file appeared once it can be read
            return current.exists ? FileChangeKind.created : FileChangeKind.unchanged;
        }
        FileChangeKind kind = _fileState.compareTo(current);
        if (kind == FileChangeKind.deleted || kind == FileChangeKind.created)
            return kind;
        if (!_fileStateUncertain && (kind == FileChangeKind.unchanged || current.size != _fileState.size))
            return kind;
        // compare the content: same size with another time or file, or not sure the loaded text is the file's
        if (!_fileState.hasChecksum)
            return FileChangeKind.modified;
        ubyte[] data;
        bool stable;
        FileState full = readStateWithContent(_fileState.path, data, stable);
        if (!stable) {
            if (full.unknown)
                return FileChangeKind.unchanged;
            return full.exists ? FileChangeKind.modified : FileChangeKind.deleted; // still being written, or gone
        }
        if (!full.hasChecksum || full.checksum != _fileState.checksum || (_fileContent !is null && _fileContent != data))
            return FileChangeKind.modified; // with kept bytes, exact: a checksum collision is a change
        _fileState = full; // the same content: the new baseline, no read next time
        _fileStateUncertain = false;
        return FileChangeKind.unchanged;
    }

    /**
    Makes the file as it is on disk now the baseline for `checkExternalChange()`, without changing the text: for
    "keep my text" after an external change, or a deleted file the user keeps editing (#1278). The text then counts as
    a change to that file: `fileState` and `fileContent` describe the file on disk, not the text. If the file keeps
    changing while it is read, the new state is uncertain (`fileStateUncertain`).

    Returns false, keeping the old baseline, if the state of the file can't be read now.
    */
    bool acceptExternalState() {
        if (!_fileState.path.length)
            return true;
        ubyte[] data;
        bool stable;
        FileState state = readStateWithContent(_fileState.path, data, stable);
        if (state.unknown)
            return false;
        _fileState = state;
        _fileStateUncertain = !stable;
        if (_keepFileContent && state.hasChecksum) {
            import std.exception : assumeUnique;
            _fileContent = assumeUnique(data); // not used after this
        } else {
            _fileContent = null;
        }
        return true;
    }

    // the name to open a file with: on Windows the \\?\ form of long paths
    private static string osFileName(string filename) {
        version (Windows) {
            import dlangui.core.filewatch : longPathName, normalizedFilePath;
            return longPathName(normalizedFilePath(filename));
        } else {
            return filename;
        }
    }

    // a file of this size is read into memory, with a checksum (#1276); larger ones are decoded while read
    private static bool fitsInMemory(ulong size) {
        return size <= maxInMemoryLoadSize && size < size_t.max / 2;
    }

    // reads all bytes of an open file and its state after reading, again while it changes (up to LOAD_RETRIES
    // times); true if the last read was stable: the bytes belong to `after`
    private static bool readStable(ref std.stdio.File file, string filename, FileState before, out ubyte[] data,
            out FileState after) {
        for (int attempt = 0; ; attempt++) {
            data = readAllBytes(file, before.size);
            version (unittest) {
                if (testHookAfterRead)
                    testHookAfterRead(attempt);
            }
            after = FileState.read(file, filename, data);
            if (isStableRead(before, after, data.length))
                return true;
            if (attempt >= LOAD_RETRIES)
                return false;
            debug(FileFormats) Log.d("file changed while it was read, reading again: ", filename);
            before = after;
        }
    }

    // the bytes of a file and its state from one stable read (readStable), with their checksum; `stable` false if
    // the file kept changing (the last state and bytes read). A missing file, or one too large for memory: its state
    // without a checksum and no data (stable). On an error: the state without a checksum, not stable.
    private static FileState readStateWithContent(string path, out ubyte[] data, out bool stable) {
        FileState state = FileState.read(path);
        if (!state.exists || state.unknown) {
            stable = !state.unknown;
            return state;
        }
        try {
            std.stdio.File file = std.stdio.File(osFileName(path), "rb");
            scope (exit)
                file.close();
            FileState before = FileState.read(file, path);
            if (!before.unknown && !fitsInMemory(before.size)) {
                stable = true;
                return before;
            }
            FileState after;
            stable = readStable(file, path, before, data, after);
            return after;
        } catch (Exception e) {
            data = null;
            stable = false;
            return FileState.read(path);
        }
    }

    /// load content form input stream; the content then has no `fileState` (load(filename) sets it)
    bool load(InputStream f, string fname = null) {
        import dlangui.core.linestream;
        clear();
        _filename = fname;
        _format = TextFileFormat.init;
        _fileState = FileState.init;
        _fileStateUncertain = false;
        _fileContent = null;
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
                ensureLineExists();
                Log.e("Error ", lines.errorCode, " ", lines.errorMessage, " -- at line ", lines.errorLine, " position ", lines.errorPos);
                notifyContentReplaced();
                return false;
            }
            // EOF; an empty file has no lines, but content needs at least one
            ensureLineExists();
            _format = lines.textFormat;
            _invalidCharCount = lines.invalidCharCount;
            _invalidCharPositions = lines.invalidCharPositions.dup;
            if (_invalidCharCount)
                Log.w(invalidCharsMessage(fname, _invalidCharCount, _invalidCharPositions, _format.encoding));
            _undoBuffer.clear();
            debug(FileFormats)Log.d("loaded file:", filename, " format detected:", _format);
            notifyContentReplaced();
            return true;
        } catch (Exception e) {
            Log.e("Exception while trying to read file ", fname, " ", e.toString);
            clear();
            ensureLineExists();
            notifyContentReplaced();
            return false;
        }
    }
    /**
    Load content from file. The bytes and the file's state (`fileState`) come from the same open file: its state is
    read before and after reading all bytes, and the file is read again (up to LOAD_RETRIES times) if it changed
    meanwhile, e.g. while another program writes it (#1276). The bytes are then decoded from memory; files larger
    than `maxInMemoryLoadSize` are decoded while read.
    */
    bool load(string filename) {
        import std.file : exists, isFile;
        import std.exception : ErrnoException;
        import std.stdio : File;
        clear();
        // nothing of a previous file stays, also if this load fails
        _fileState = FileState.init;
        _fileStateUncertain = false;
        _fileContent = null;
        string osName = osFileName(filename);
        if (!osName.exists || !osName.isFile) {
            Log.e("Editable.load: File not found ", filename);
            ensureLineExists();
            if (!osName.exists)
                _fileState = FileState.read(filename); // a missing file: a later check can tell it appeared
            return false;
        }
        try {
            File file = File(osName, "rb");
            scope(exit) file.close();
            FileState before = FileState.read(file, filename);
            // beyond the limit, and on 32-bit systems for sizes that don't fit a buffer: decoded while read
            if (!fitsInMemory(before.size))
                return loadWhileReading(file, filename, before);
            ubyte[] data;
            FileState after;
            bool stable = readStable(file, filename, before, data, after);
            if (!stable)
                Log.w("Editable.load: file ", filename, " kept changing while it was loaded");
            bool res = load(new MemoryInputStream(data), filename);
            if (res) {
                _fileState = after;
                _fileStateUncertain = !stable;
                if (_keepFileContent) {
                    import std.exception : assumeUnique;
                    _fileContent = assumeUnique(data); // the buffer isn't used after this
                }
            }
            return res;
        } catch (ErrnoException e) {
            Log.e("Editable.load: Exception while trying to read file ", filename, " ", e.toString);
            clear();
            ensureLineExists();
            return false;
        } catch (Exception e) {
            Log.e("Editable.load: Exception while trying to read file ", filename, " ", e.toString);
            clear();
            ensureLineExists();
            return false;
        }
    }
    // the file didn't change while `length` bytes were read: its state before and after reading is known and the
    // same, and has that size; a pseudo file reporting size 0 (/proc, sysfs) counts as stable when nothing changed
    private static bool isStableRead(const FileState before, const FileState after, ulong length) {
        if (before.unknown || after.unknown || !before.sameAs(after))
            return false;
        return after.size == length || (after.size == 0 && before.size == 0);
    }

    // all bytes of an open file from its start; expectedSize is a hint for the buffer
    private static ubyte[] readAllBytes(ref std.stdio.File file, ulong expectedSize) {
        file.seek(0);
        ubyte[] data = new ubyte[cast(size_t)expectedSize + 1];
        size_t len = 0;
        for (;;) {
            if (len == data.length)
                data.length = data.length * 2 + 4096;
            size_t n = file.rawRead(data[len .. $]).length;
            if (n == 0)
                break;
            len += n;
        }
        return data[0 .. len];
    }

    // load(filename) for a large file: decoded while it is read, no copy and no checksum
    private bool loadWhileReading(ref std.stdio.File file, string filename, FileState before) {
        file.seek(0);
        bool res = load(new FileInputStream(file), filename);
        if (res) {
            FileState after = FileState.read(file, filename);
            _fileState = after;
            // the decoder read to the end: the position is the number of bytes read
            _fileStateUncertain = !isStableRead(before, after, file.tell);
        }
        return res;
    }

    protected bool _atomicSave = true;
    protected bool _syncOnSave;

    /**
    save(filename) writes a temporary file and replaces the file with it, so a failed save (e.g. a full disk)
    leaves the file as it was (#1277); files whose identity a replace would change (links, other owners) are still
    written in place, see `writeFileSafely`. False: always write the file in place.
    */
    @property bool atomicSave() const {
        return _atomicSave;
    }
    /// ditto
    @property EditableContent atomicSave(bool flag) {
        _atomicSave = flag;
        return this;
    }

    /**
    save(filename) also flushes in-place writes to the disk, and the directory after a replace (POSIX), so that the
    save survives a crash right after it. The data of an atomic save is always flushed before the replace.
    */
    @property bool syncOnSave() const {
        return _syncOnSave;
    }
    /// ditto
    @property EditableContent syncOnSave(bool flag) {
        _syncOnSave = flag;
        return this;
    }

    // the text encoded in format, as save writes it
    protected ubyte[] encodeText(string filename, TextFileFormat format) {
        auto mem = new MemoryOutputStream();
        OutputLineStream writer = new OutputLineStream(mem, filename, format);
        for (int i = 0; i < _lines.length; i++)
            writer.writeLine(_lines[i]);
        writer.close();
        return mem.data;
    }

    // after the text was written completely: the content is saved
    protected void markSaved(TextFileFormat format) {
        _format = format;
        _undoBuffer.saved();
        _invalidCharCount = 0; // the saved file has U+FFFD instead of the invalid bytes
        _invalidCharPositions = null;
        notifyContentSaved();
    }

    /// save to output stream in specified format
    bool save(OutputStream stream, string filename, TextFileFormat format) {
        if (!filename)
            filename = _filename;
        try {
            debug(FileFormats)Log.d("creating output stream, file=", filename, " format=", format);
            ubyte[] data = encodeText(filename, format);
            // written and closed before marking the content saved: write errors (e.g. a full disk) show up here (#956)
            {
                scope(exit) stream.close();
                stream.write(data);
            }
            markSaved(format);
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
    /**
    Save to file in specified format: through a temporary file that replaces it (`atomicSave`, #1277), so a failed
    save leaves the file as it was. The whole text is encoded in memory first. The content is marked saved only after the file is completely written, and the
    saved file becomes the new `fileState`, with the checksum of the bytes written (and `fileContent`, with
    `keepFileContent`).
    */
    bool save(string filename, TextFileFormat format) {
        import dlangui.core.files : writeFileSafely;
        import dlangui.core.filewatch : fileChecksum;
        if (!filename)
            filename = _filename;
        try {
            ubyte[] data = encodeText(filename, format);
            FileState written;
            if (!writeFileSafely(filename, data, written, _atomicSave, _syncOnSave))
                return false;
            markSaved(format);
            // the new baseline: the file now under that name, if it is the one written (same identity, size and time
            // as read from the written file's handle); else another program changed it meanwhile
            FileState now = FileState.read(filename);
            bool ours = now.exists && written.exists && !now.unknown && !written.unknown
                && now.size == data.length && now.modified == written.modified
                && (!now.hasFileId || !written.hasFileId || now.fileId == written.fileId);
            if (ours) {
                now.checksum = fileChecksum(data);
                now.hasChecksum = true;
            }
            _fileState = now;
            _fileStateUncertain = !ours;
            if (_keepFileContent) {
                import std.exception : assumeUnique;
                _fileContent = assumeUnique(data); // not used after this
            } else {
                _fileContent = null;
            }
            return true;
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
    this() @safe pure nothrow @nogc {
    }
    this(LineIconType type, int line, Object obj = null) @safe pure nothrow @nogc {
        this.type = type;
        this.line = line;
        this.objectParam = obj;
    }
}

/// text editor line icon list
struct LineIcons {
    private LineIcon[] _items;
    private int _len;
@safe:

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
        _len--;
        _items[_len] = null; // the vacated last slot (it cleared _items[_len], past the last item, #941)
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

/// loading an empty file gives one empty line, and editing it works (#756)
unittest {
    import std.file : write, remove, tempDir;
    import std.path : buildPath;
    import std.conv : to;
    import std.process : thisProcessID;
    string fn = buildPath(tempDir, "dlangui-empty-file-test-" ~ to!string(thisProcessID) ~ ".txt");
    write(fn, "");
    scope(exit) remove(fn);
    auto content = new EditableContent(true);
    assert(content.load(fn));
    assert(content.length == 1);
    assert(content.text == ""d);
    auto op = new EditOperation(EditAction.Replace, TextRange(TextPosition(0, 0), TextPosition(0, 0)), ["x"d]);
    assert(content.performOperation(op, null));
    assert(content.length == 1);
    assert(content.text == "x"d);
    // failed load also leaves one empty line
    auto content2 = new EditableContent(true);
    assert(!content2.load(fn ~ ".does-not-exist"));
    assert(content2.length == 1);
}

/// load(filename) keeps the state of the file it read, with the checksum of the bytes (#1276)
unittest {
    import std.file : write, remove, tempDir, exists;
    import std.path : buildPath;
    import std.conv : to;
    import std.process : thisProcessID;
    import std.stdio : File;
    import std.array : replicate;
    import dlangui.core.filewatch : FileState, FileChangeKind, fileChecksum;
    string fn = buildPath(tempDir, "dlangui-atomic-load-test-" ~ to!string(thisProcessID) ~ ".txt");
    write(fn, "one\ntwo\n");
    scope(exit) if (exists(fn)) remove(fn);

    // the state and checksum of what was read; no content copy unless asked
    auto content = new EditableContent(true);
    assert(content.load(fn));
    assert(content.text == "one\ntwo"d); // the final line break doesn't make an empty line
    assert(content.fileState.exists && content.fileState.size == 8 && content.fileState.hasChecksum);
    assert(content.fileState.checksum == fileChecksum(cast(const(ubyte)[])"one\ntwo\n"));
    assert(content.fileState.compareTo(FileState.read(fn, true)) == FileChangeKind.unchanged);
    assert(!content.fileStateUncertain && content.fileContent is null);
    content.keepFileContent = true;
    assert(content.load(fn) && content.fileContent == cast(immutable(ubyte)[])"one\ntwo\n");
    content.keepFileContent = false;
    assert(content.fileContent is null);

    // a file changed while it is read (another program writing it) is read again: the state matches the content.
    // The writer shares the file (as fopen does): std.file.write opens it exclusively, which Windows refuses while
    // the file is open for reading
    void rewrite(string text) {
        auto w = File(fn, "wb");
        w.rawWrite(text);
        w.close();
    }
    int changes = 0;
    EditableContent.testHookAfterRead = (int attempt) {
        if (attempt < 2) {
            changes++;
            rewrite("longer and longer " ~ to!string(attempt) ~ "\n" ~ "x".replicate(attempt + 1));
        }
    };
    assert(content.load(fn));
    assert(changes == 2 && !content.fileStateUncertain);
    assert(content.text == "longer and longer 1\nxx"d);
    assert(content.fileState.compareTo(FileState.read(fn, true)) == FileChangeKind.unchanged);

    // ... and loaded anyway, marked uncertain, when it keeps changing
    EditableContent.testHookAfterRead = (int attempt) {
        rewrite("changing " ~ "y".replicate(attempt + 1));
    };
    assert(content.load(fn));
    assert(content.fileStateUncertain);
    EditableContent.testHookAfterRead = null;

    // a large file is decoded while read: a state without a checksum, no content copy
    write(fn, "big file\n");
    ulong oldMax = EditableContent.maxInMemoryLoadSize;
    EditableContent.maxInMemoryLoadSize = 4;
    scope(exit) EditableContent.maxInMemoryLoadSize = oldMax;
    content.keepFileContent = true;
    assert(content.load(fn) && content.text == "big file"d);
    assert(content.fileState.exists && content.fileState.size == 9 && !content.fileState.hasChecksum);
    assert(content.fileContent is null && !content.fileStateUncertain);
    assert(content.fileState.compareTo(FileState.read(fn)) == FileChangeKind.unchanged);
    EditableContent.maxInMemoryLoadSize = oldMax;

    // content from a stream has no file state; a missing file has a missing one
    {
        auto stream = new FileInputStream(File(fn, "rb"));
        assert(content.load(stream, fn));
        stream.close(); // or the file stays open, and Windows doesn't delete an open file
    }
    assert(!content.fileState.exists && content.fileContent is null);
    // a saved file is the new baseline: comparing with the disk after the own save finds no change
    write(fn, "abc");
    content.keepFileContent = true;
    assert(content.load(fn) && content.fileContent !is null);
    auto op = new EditOperation(EditAction.Replace, TextRange(TextPosition(0, 3), TextPosition(0, 3)), ["def"d]);
    assert(content.performOperation(op, null));
    assert(content.save(fn));
    import std.file : getSize;
    assert(content.fileState.size == getSize(fn) && content.fileState.hasChecksum && !content.fileStateUncertain);
    { static import std.file; assert(content.fileContent == cast(immutable(ubyte)[])std.file.read(fn)); } // saved bytes (#1277)
    assert(content.fileState.compareTo(FileState.read(fn, true)) == FileChangeKind.unchanged);
    content.keepFileContent = false;

    // a save that fails while writing leaves the file as it was, and the text modified (#1277)
    {
        import dlangui.core.files : safeWriteTestHook;
        FileState saved = content.fileState;
        auto op2 = new EditOperation(EditAction.Replace, TextRange(TextPosition(0, 0), TextPosition(0, 0)), ["X"d]);
        assert(content.performOperation(op2, null) && content.modified);
        safeWriteTestHook = (string tmp) { throw new Exception("simulated full disk"); };
        scope (exit) safeWriteTestHook = null;
        assert(!content.save(fn));
        assert(content.modified);
        assert(saved.compareTo(FileState.read(fn, true)) == FileChangeKind.unchanged);
        safeWriteTestHook = null;
        assert(content.save(fn) && !content.modified);
    }

    // a failed load leaves nothing of the previous file: a directory isn't loaded, and has no file state
    assert(content.load(fn) && content.fileState.exists);
    assert(!content.load(tempDir));
    assert(!content.fileState.exists && content.fileContent is null && !content.fileStateUncertain);

    // a pseudo file reporting size 0 loads as stable when nothing changed
    version (linux) {
        if (exists("/proc/self/stat")) {
            assert(content.load("/proc/self/stat") && content.length >= 1);
            assert(!content.fileStateUncertain && content.fileState.size == 0);
        }
    }

    remove(fn);
    assert(!content.load(fn));
    assert(!content.fileState.exists && !content.fileState.unknown);
}

/// a file with invalid bytes for its encoding loads completely, with U+FFFD for them (#924)
unittest {
    import std.file : write, remove, tempDir;
    import std.path : buildPath;
    import std.conv : to;
    import std.process : thisProcessID;
    string fn = buildPath(tempDir, "dlangui-invalid-chars-test-" ~ to!string(thisProcessID) ~ ".txt");
    write(fn, "line one\ncaf\xE9 two\nline three\n");
    scope(exit) remove(fn);
    auto content = new EditableContent(true);
    assert(content.load(fn));
    assert(content.length == 3 && content.line(1) == "caf\uFFFD two"d && content.line(2) == "line three"d);
    assert(content.invalidCharCount == 1);
    write(fn, "valid\n");
    assert(content.load(fn) && content.invalidCharCount == 0);
    // the count belongs to the loaded content: reset by a failed load and by setting the text
    write(fn, "\xFF\n");
    assert(content.load(fn) && content.invalidCharCount == 1);
    assert(!content.load(fn ~ ".does-not-exist") && content.invalidCharCount == 0);
    assert(content.load(fn) && content.invalidCharCount == 1);
    content.text = "new text"d;
    assert(content.invalidCharCount == 0);
    // positions of the first invalid characters, in one warning message (#944)
    write(fn, "ab\xFF\nc\xFEd\n\x80\n\x81\n");
    assert(content.load(fn) && content.invalidCharCount == 4);
    alias P = LineStream.InvalidCharPosition;
    assert(content.invalidCharPositions == [P(1, 3), P(2, 2), P(3, 1)]);
    assert(EditableContent.invalidCharsMessage("f.txt", 4, content.invalidCharPositions, EncodingType.UTF8)
            == "File f.txt: 4 invalid characters for UTF8 replaced by U+FFFD, first at 1:3, 2:2, 3:1 (and 1 more)");
    assert(EditableContent.invalidCharsMessage("f.txt", 1, [P(2, 4)], EncodingType.UTF16LE)
            == "File f.txt: 1 invalid character for UTF16LE replaced by U+FFFD, at 2:4");
    content.text = "x"d;
    assert(content.invalidCharPositions.length == 0);
    write(fn, "\xFF\n"); // the content the following checks expect
    // saving writes U+FFFD (valid UTF-8), so the saved file loads without replacements
    assert(content.load(fn) && content.invalidCharCount == 1);
    assert(content.save(fn) && content.invalidCharCount == 0);
    assert(content.load(fn) && content.invalidCharCount == 0 && content.line(0) == "\uFFFD"d);
}

/// characters above U+FFFF are saved and loaded in every encoding; a lone surrogate in the text is saved as
/// U+FFFD instead of throwing (#923)
unittest {
    import std.file : remove, tempDir, exists;
    import std.path : buildPath;
    import std.conv : to;
    import std.process : thisProcessID;
    import dlangui.core.linestream : TextFileFormat, EncodingType, LineEnding;
    string fn = buildPath(tempDir, "dlangui-surrogates-test-" ~ to!string(thisProcessID) ~ ".txt");
    scope(exit) if (exists(fn)) remove(fn);
    foreach (enc; [EncodingType.UTF8, EncodingType.UTF16LE, EncodingType.UTF16BE, EncodingType.UTF32LE, EncodingType.UTF32BE]) {
        auto content = new EditableContent(true);
        content.text = "a\U0001F600b\nline 2"d;
        assert(content.save(fn, TextFileFormat(enc, LineEnding.LF, true)), to!string(enc));
        auto loaded = new EditableContent(true);
        assert(loaded.load(fn) && loaded.invalidCharCount == 0, to!string(enc));
        assert(loaded.line(0) == "a\U0001F600b"d && loaded.line(1) == "line 2"d, to!string(enc));
        assert(loaded._format.encoding == enc, to!string(enc));
        // a lone surrogate (not from a file: set as text) can't be encoded: saved as U+FFFD
        // built at run time: DMD 2.100 on Windows rejects a string literal with a surrogate ("invalid UCS-32 char")
        dchar surrogate = 0xD800;
        content.text = ("x"d ~ surrogate ~ "y"d).idup;
        assert(content.save(fn, TextFileFormat(enc, LineEnding.LF, true)), to!string(enc));
        assert(loaded.load(fn) && loaded.line(0) == "x\uFFFDy"d, to!string(enc));
    }
}

/// typing or deleting on the same line after saving marks the content modified (#948)
unittest {
    import std.file : remove, tempDir, exists;
    import std.path : buildPath;
    import std.conv : to;
    import std.process : thisProcessID;
    string fn = buildPath(tempDir, "dlangui-modified-test-" ~ to!string(thisProcessID) ~ ".txt");
    scope(exit) if (exists(fn)) remove(fn);
    auto content = new EditableContent(true);
    content.text = "ab"d;
    assert(!content.modified);
    void type(dchar ch) {
        auto pos = TextPosition(0, cast(int)content.line(0).length);
        assert(content.performOperation(new EditOperation(EditAction.Replace, TextRange(pos, pos), [[ch]]), null));
    }
    void backspace() {
        int len = cast(int)content.line(0).length;
        assert(content.performOperation(new EditOperation(EditAction.Replace,
                TextRange(TextPosition(0, len - 1), TextPosition(0, len)), [""d]), null));
    }
    type('c');
    assert(content.modified);
    assert(content.save(fn));
    assert(!content.modified);
    type('d'); // was merged into the saved operation
    assert(content.modified && content.text == "abcd"d);
    type('e'); // merging after the saved state is fine
    assert(content.modified && content.text == "abcde"d);
    assert(content.save(fn));
    backspace();
    assert(content.modified && content.text == "abcd"d);
    // undo back to the saved state: not modified; redo: modified
    assert(content.undo(null) && !content.modified && content.text == "abcde"d);
    assert(content.redo(null) && content.modified && content.text == "abcd"d);
}

/// a failed save (here: a full device) doesn't mark the content saved (#956)
version (linux) unittest {
    import std.file : exists;
    if (!exists("/dev/full"))
        return;
    auto content = new EditableContent(true);
    content.text = "some text"d;
    auto pos = TextPosition(0, 9);
    assert(content.performOperation(new EditOperation(EditAction.Replace, TextRange(pos, pos), ["!"d]), null));
    assert(content.modified);
    assert(!content.save("/dev/full"));
    assert(content.modified);
}

/// undo after deleting a character and then a character with the following line break (#954)
unittest {
    auto content = new EditableContent(true);
    content.text = "abcd\nef"d;
    void del(int l1, int p1, int l2, int p2) {
        assert(content.performOperation(new EditOperation(EditAction.Replace,
                TextRange(TextPosition(l1, p1), TextPosition(l2, p2)), [""d]), null));
    }
    del(0, 2, 0, 3); // "c" (Delete key)
    del(0, 2, 1, 0); // "d" and the line break: was merged with the previous delete as one character
    assert(content.text == "abef"d);
    assert(content.undo(null) && content.text == "abd\nef"d);
    assert(content.undo(null) && content.text == "abcd\nef"d);
    assert(!content.undo(null));
    assert(content.redo(null) && content.text == "abd\nef"d);
    assert(content.redo(null) && content.text == "abef"d);
}

/// typing and deleting around a caret, with undo and redo: no range errors, and undoing everything restores the
/// original text (#954; adjacent small deletes are merged into one undo operation)
unittest {
    import std.random : Random, uniform;
    auto rnd = Random(954);
    immutable dstring original = "first line\nsecond\n\nfourth line here"d;
    foreach (round; 0 .. 50) {
        auto content = new EditableContent(true);
        content.text = original;
        TextPosition caret = TextPosition(0, 0);
        // the position n characters after (n > 0) or before (n < 0) p, a line break counting as one character
        TextPosition move(TextPosition p, int n) {
            for (; n > 0; n--) {
                if (p.pos < content.line(p.line).length)
                    p.pos++;
                else if (p.line + 1 < content.length)
                    p = TextPosition(p.line + 1, 0);
            }
            for (; n < 0; n++) {
                if (p.pos > 0)
                    p.pos--;
                else if (p.line > 0)
                    p = TextPosition(p.line - 1, cast(int)content.line(p.line - 1).length);
            }
            return p;
        }
        foreach (step; 0 .. 200) {
            int r = uniform(0, 20, rnd);
            if (r < 2) {
                caret.line = uniform(0, content.length, rnd);
                caret.pos = uniform(0, cast(int)content.line(caret.line).length + 1, rnd);
            } else if (r < 7) {
                dstring[] text = r == 6 ? [""d, ""d] : ["x"d];
                content.performOperation(new EditOperation(EditAction.Replace, TextRange(caret, caret), text), null);
                caret = r == 6 ? TextPosition(caret.line + 1, 0) : TextPosition(caret.line, caret.pos + 1);
            } else if (r < 17) {
                int n = uniform(1, 3, rnd);
                TextPosition other = move(caret, r < 12 ? n : -n);
                TextRange range = r < 12 ? TextRange(caret, other) : TextRange(other, caret);
                content.performOperation(new EditOperation(EditAction.Replace, range, [""d]), null);
                caret = range.start;
            } else {
                if (r < 19)
                    content.undo(null);
                else
                    content.redo(null);
                caret = TextPosition(0, 0);
            }
        }
        while (content.undo(null)) {}
        assert(content.text == original);
    }
}

// text helpers, positions and ranges (#914); LineIcons.remove when the array is full (#941)
@safe unittest {
    assert(splitDString("a\r\nb\nc"d) == ["a"d, "b"d, "c"d]);
    assert(splitDString("a;;b"d, ';') == ["a"d, ""d, "b"d]);
    assert(concatDStrings(["a"d, "b"d], "\n"d) == "a\nb"d);
    assert(replaceEolsWithSpaces("a\r\nb\nc\rd"d) == "a b c d"d);
    TextPosition p1 = TextPosition(1, 5), p2 = TextPosition(2, 0);
    TextPosition p3 = p1.offset(2);
    assert(p1 < p2 && p3.line == 1 && p3.pos == 7 && p1.toString == "1:5");
    TextRange range = TextRange(p1, p2);
    assert(!range.empty && !range.singleLine && range.lines == 2);
    assert(range.isInside(TextPosition(1, 9)) && !range.isInside(p2) && range.isInsideOrNext(p2));
    TextRange after = TextRange(p2, TextPosition(3, 0));
    TextRange overlapping = TextRange(TextPosition(1, 0), TextPosition(1, 6));
    assert(!range.intersects(after) && range.intersects(overlapping));
    // 16 icons fill the array exactly: removing one cleared _items[16], past the end
    LineIcons icons;
    foreach (i; 0 .. 16)
        icons.add(new LineIcon(LineIconType.bookmark, i));
    assert(icons.length == 16 && icons._items.length == 16);
    assert(icons.remove(0).line == 0 && icons.length == 15 && icons[0].line == 1);
    assert(icons._items[15] is null); // the vacated slot keeps no reference
    assert(icons.findByLineAndType(15, LineIconType.bookmark).line == 15 && icons.findByType(LineIconType.bookmark).length == 15);
}

// revision changes with edits, undo, redo, new content and clear(), not with saving, and differs between content
// objects (#1166)
unittest {
    auto content = new EditableContent(true);
    scope (exit) destroy(content);
    auto other = new EditableContent(true);
    scope (exit) destroy(other);
    assert(content.revision != other.revision);
    content.text = "abc"d;
    ulong last = content.revision;
    bool changed() {
        bool res = content.revision != last;
        last = content.revision;
        return res;
    }
    assert(content.performOperation(new EditOperation(EditAction.Replace,
        TextRange(TextPosition(0, 0), TextPosition(0, 1)), ["x"d]), null));
    assert(changed());
    assert(content.undo(null) && changed());
    assert(content.redo(null) && changed());
    content.notifyContentSaved();
    assert(!changed());
    content.text = "new"d;
    assert(changed());
    content.clear();
    assert(changed());
    assert(content.revision != other.revision);
}

/// combining marks and ZWNJ are parts of words for word selection and moving by words (#1168)
unittest {
    auto content = new EditableContent(false);
    // positions on line 0 (TextPosition.opEquals takes a ref)
    bool word(int pos, int start, int end) {
        TextRange r = content.wordBounds(TextPosition(0, pos));
        return r.start.line == 0 && r.start.pos == start && r.end.line == 0 && r.end.pos == end;
    }
    bool move(int pos, int direction, int expected, bool camelCase = false) {
        TextPosition p = content.moveByWord(TextPosition(0, pos), direction, camelCase);
        return p.line == 0 && p.pos == expected;
    }
    // decomposed "café": 'e' and U+0301
    content.text = "x cafe\u0301 y"d;
    assert(word(3, 2, 7));
    assert(word(6, 2, 7));
    assert(move(2, 1, 7));
    assert(move(7, -1, 2));
    // Devanagari: virama U+094D and vowel sign U+0947 inside the word
    content.text = "\u0928\u092E\u0938\u094D\u0924\u0947 x"d;
    assert(word(0, 0, 6));
    assert(move(0, 1, 6));
    // Persian: ZWNJ U+200C inside the word
    content.text = "\u0645\u06CC\u200C\u062E\u0648\u0627\u0647\u0645 x"d;
    assert(word(1, 0, 8));
    assert(move(0, 1, 8));
    // punctuation and spaces still end words
    content.text = "ab.cd ef"d;
    assert(word(0, 0, 2));
    assert(move(0, 1, 2));
    // but not a joiner in an emoji sequence (man ZWJ woman), or a variation selector after a symbol
    content.text = "\U0001F468\u200D\U0001F469 x"d;
    assert(word(0, 0, 0) && word(1, 1, 1));
    assert(move(0, 1, 3));
    content.text = "abc\u2764\uFE0Fdef"d;
    assert(word(6, 5, 8));
    assert(move(8, -1, 5));
    // camel case parts after a decomposed letter: "caféBar"
    content.text = "cafe\u0301Bar"d;
    assert(move(0, 1, 5, true) && move(8, -1, 5, true));
    assert(move(0, 1, 8));
    // a mark after punctuation stays with it
    content.text = "x.\u0301 y"d;
    assert(move(1, 1, 3) && move(3, -1, 1));
    // a long run of marks stays linear: word selection ends after the 30th mark, moving by words doesn't stop
    // before a mark
    dchar[] zalgo = "a"d.dup;
    foreach (k; 0 .. 100_000)
        zalgo ~= '\u0301';
    content.text = cast(dstring)(zalgo ~ " b"d);
    assert(word(0, 0, 31));
    assert(move(0, 1, 100_001) && move(100_001, -1, 0));
}

// checkExternalChange() and acceptExternalState() (#1278)
unittest {
    import std.file : write, remove, tempDir, exists, setTimes, timeLastModified;
    import std.path : buildPath;
    import std.conv : to;
    import std.datetime : Clock, SysTime, seconds;
    string fn = buildPath(tempDir, "dlangui-check-external-" ~ to!string(Clock.currStdTime) ~ ".txt");
    scope (exit)
        if (exists(fn))
            remove(fn);
    // a file write with a later time, also on file systems with a coarse time
    void rewrite(string text) {
        SysTime t = exists(fn) ? timeLastModified(fn) + 10.seconds : Clock.currTime;
        write(fn, text);
        setTimes(fn, t, t);
    }
    void touch() {
        SysTime t = timeLastModified(fn) + 10.seconds;
        setTimes(fn, t, t);
    }
    auto content = new EditableContent(true);
    assert(content.checkExternalChange() == FileChangeKind.unchanged); // not from a file

    write(fn, "one\ntwo\n");
    assert(content.load(fn));
    assert(content.checkExternalChange() == FileChangeKind.unchanged);
    // touched: the content decides, and becomes the new baseline
    touch();
    assert(content.checkExternalChange() == FileChangeKind.unchanged);
    assert(content.fileState.modified == timeLastModified(fn));
    // same size, other content; other size
    rewrite("one\ntwX\n");
    assert(content.checkExternalChange() == FileChangeKind.modified);
    rewrite("one\ntwo\nthree\n");
    assert(content.checkExternalChange() == FileChangeKind.modified);
    assert(content.checkExternalChange() == FileChangeKind.modified); // until it is accepted or reloaded
    // keep mine: the disk is the baseline, the text stays
    content.acceptExternalState();
    assert(content.checkExternalChange() == FileChangeKind.unchanged);
    assert(content.text == "one\ntwo"d && content.fileState.size == 14 && content.fileState.hasChecksum);
    // deleted; kept; created again
    remove(fn);
    assert(content.checkExternalChange() == FileChangeKind.deleted);
    content.acceptExternalState();
    assert(!content.fileState.exists && content.checkExternalChange() == FileChangeKind.unchanged);
    rewrite("new");
    assert(content.checkExternalChange() == FileChangeKind.created);
    // missing when loaded, then created
    remove(fn);
    assert(!content.load(fn) && content.checkExternalChange() == FileChangeKind.unchanged);
    rewrite("appeared");
    assert(content.checkExternalChange() == FileChangeKind.created);

    // with keepFileContent the bytes are compared exactly, not only their checksum; accepting keeps the disk bytes
    content.keepFileContent = true;
    rewrite("same size");
    assert(content.load(fn));
    touch();
    assert(content.checkExternalChange() == FileChangeKind.unchanged);
    content._fileContent = cast(immutable(ubyte)[])"SAME SIZE"; // as if the checksums collided
    touch();
    assert(content.checkExternalChange() == FileChangeKind.modified);
    content.acceptExternalState();
    assert(content.fileContent == cast(immutable(ubyte)[])"same size");
    content.keepFileContent = false;

    // a file loaded without a checksum (large): a touch counts as modified
    ulong savedLimit = EditableContent.maxInMemoryLoadSize;
    EditableContent.maxInMemoryLoadSize = 4;
    scope (exit)
        EditableContent.maxInMemoryLoadSize = savedLimit;
    assert(content.load(fn) && !content.fileState.hasChecksum);
    touch();
    assert(content.checkExternalChange() == FileChangeKind.modified);
    EditableContent.maxInMemoryLoadSize = savedLimit;

    // a saved file is the baseline
    rewrite("x");
    assert(content.load(fn));
    rewrite("from another program");
    assert(content.checkExternalChange() == FileChangeKind.modified);
    assert(content.save(fn));
    assert(content.checkExternalChange() == FileChangeKind.unchanged);

    // writes through a handle that shares the file: Windows refuses std.file.write while the file is open
    void writeShared(const(char)[] text) {
        auto f = std.stdio.File(fn, "wb");
        f.rawWrite(text);
        f.close();
    }
    // a file rewritten while the check reads it: no baseline from bytes and a time that don't belong together
    rewrite("one\ntwo\n");
    assert(content.load(fn));
    touch();
    EditableContent.testHookAfterRead = (int attempt) {
        if (attempt == 0)
            writeShared("one\ntwX\n");
    };
    FileChangeKind kind = content.checkExternalChange();
    EditableContent.testHookAfterRead = null;
    assert(kind == FileChangeKind.modified);
    assert(content.checkExternalChange() == FileChangeKind.modified);

    // a load while the file keeps changing: its state is known, but the text isn't the file's
    {
        import std.array : replicate;
        content.keepFileContent = true;
        rewrite("v");
        int n = 0;
        EditableContent.testHookAfterRead = (int attempt) { writeShared("v" ~ "x".replicate(++n)); };
        bool loaded = content.load(fn);
        EditableContent.testHookAfterRead = null;
        assert(loaded && content.fileStateUncertain);
        assert(content.checkExternalChange() == FileChangeKind.modified);
        // the file gets the loaded bytes again: verified, no longer uncertain
        writeShared(cast(const(char)[])content.fileContent);
        assert(content.checkExternalChange() == FileChangeKind.unchanged && !content.fileStateUncertain);
        content.keepFileContent = false;
    }

    // a state that can't be read: accepting it keeps the old baseline; a load that failed because of it reports
    // the file as created once it can be read
    version (Posix) {
        import std.file : mkdir, rmdirRecurse, setAttributes;
        import std.conv : octal;
        string dir = fn ~ ".dir";
        mkdir(dir);
        scope (exit) {
            setAttributes(dir, octal!755);
            rmdirRecurse(dir);
        }
        string inner = buildPath(dir, "f.txt");
        write(inner, "inner");
        assert(content.load(inner));
        setAttributes(dir, 0);
        if (FileState.read(inner).unknown) { // not when running as root
            assert(!content.acceptExternalState() && content.fileState.exists && !content.fileState.unknown);
            assert(content.checkExternalChange() == FileChangeKind.unchanged);
            assert(!content.load(inner) && content.fileState.unknown);
            assert(content.checkExternalChange() == FileChangeKind.unchanged);
            setAttributes(dir, octal!755);
            assert(content.checkExternalChange() == FileChangeKind.created);
        }
    }

    // a path longer than MAX_PATH: loaded, and compared by content when touched
    version (Windows) {
        import std.array : replicate;
        import std.file : mkdir, rmdir;
        string longDir = fn ~ "." ~ "d".replicate(150);
        string longName = buildPath(longDir, "f".replicate(60) ~ ".txt");
        assert(longName.length > 260);
        mkdir(longDir);
        scope (exit) {
            if (exists(`\\?\` ~ longName))
                remove(`\\?\` ~ longName);
            rmdir(longDir);
        }
        write(`\\?\` ~ longName, "long");
        assert(content.load(longName) && content.text == "long"d);
        SysTime t = timeLastModified(`\\?\` ~ longName) + 10.seconds;
        setTimes(`\\?\` ~ longName, t, t);
        assert(content.checkExternalChange() == FileChangeKind.unchanged && content.fileState.modified == t);
    }
}
