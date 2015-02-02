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
import std.algorithm;
import std.stream;


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
    Error_InvalidComment = (15 << TOKEN_CATEGORY_SHIFT) | 4,
}

class TextLineMark {
}

class TextLineMarks {
}


/// split dstring by delimiters
dstring[] splitDString(dstring source, dchar delimiter = EOL) {
    int start = 0;
    dstring[] res;
    dchar lastchar;
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
    foreach(line; lines) {
        if (buf.length)
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
}

/// text content range
struct TextRange {
    TextPosition start;
    TextPosition end;
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
        for(int i = 0; i < text.length; i++)
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

    void saved() {
        for (int i = 0; i < _oldEditMarks.length; i++) {
            if (_oldEditMarks[i] == EditStateMark.changed)
                _oldEditMarks[i] = EditStateMark.saved;
        }
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
        for (int i = 0; i < _undoList.length; i++) {
            _undoList[i].saved();
        }
        for (int i = 0; i < _redoList.length; i++) {
            _redoList[i].saved();
        }
    }

    /// returns true if saved state is in undo buffer
    bool savedInUndo() {
        if (!_savedState)
            return false;
        for (int i = 0; i < _undoList.length; i++) {
            if (_savedState is _undoList[i])
                return true;
        }
        return false;
    }

    /// returns true if saved state is in redo buffer
    bool savedInRedo() {
        if (!_savedState)
            return false;
        for (int i = 0; i < _redoList.length; i++) {
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

alias TokenPropString = ubyte[];

/// interface for custom syntax highlight
interface SyntaxHighlighter {
    /// categorize characters in content by token types
    void updateHighlight(dstring[] lines, TokenPropString[] props, int changeStartLine, int changeEndLine);
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

    protected SyntaxHighlighter _syntaxHighlighter;

    @property SyntaxHighlighter syntaxHighlighter() {
        return _syntaxHighlighter;
    }

    @property EditableContent syntaxHighlighter(SyntaxHighlighter syntaxHighlighter) {
        _syntaxHighlighter = syntaxHighlighter;
        updateTokenProps(0, cast(int)_lines.length);
        return this;
    }

    /// returns true if content has syntax highlight handler set
    @property bool hasSyntaxHighlight() {
        return _syntaxHighlighter !is null;
    }

    protected bool _readOnly;

    @property bool readOnly() {
        return _readOnly;
    }

    @property void readOnly(bool readOnly) {
        _readOnly = readOnly;
    }

	/// listeners for edit operations
	Signal!EditableContentListener contentChangeListeners;

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
    @property dstring text() {
        if (_lines.length == 0)
            return "";
        if (_lines.length == 1)
            return _lines[0];
        // concat lines
        dchar[] buf;
        foreach(item;_lines) {
            if (buf.length)
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
        for (int i = 0; i < _editMarks.length; i++) {
            if (_editMarks[i] == EditStateMark.changed)
                _editMarks[i] = EditStateMark.saved;
        }
        TextRange rangeBefore;
        TextRange rangeAfter;
        // notify about content change
        handleContentChange(new EditOperation(EditAction.SaveContent), rangeBefore, rangeAfter, this);
    }

    protected void updateTokenProps(int startLine, int endLine) {
        clearTokenProps(startLine, endLine);
        if (_syntaxHighlighter) {
            _syntaxHighlighter.updateHighlight(_lines, _tokenProps, startLine, endLine);
        }
    }

    protected void markChangedLines(int startLine, int endLine) {
        for (int i = startLine; i < endLine; i++) {
            _editMarks[i] = EditStateMark.changed;
        }
    }

    /// set props arrays size equal to text line sizes, bit fill with unknown token
    protected void clearTokenProps(int startLine, int endLine) {
        for (int i = startLine; i < endLine; i++) {
            if (hasSyntaxHighlight) {
                int len = cast(int)_lines[i].length;
                _tokenProps[i].length = len;
                for (int j = 0; j < len; j++)
                    _tokenProps[i][j] = TOKEN_UNKNOWN;
            } else {
                _tokenProps[i] = null; // no token props
            }
        }
    }

    void clearEditMarks() {
        _editMarks.length = _lines.length;
        for (int i = 0; i < _editMarks.length; i++)
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


    /// returns line text
    @property int length() { return cast(int)_lines.length; }
    dstring opIndex(int index) {
        return line(index);
    }

    /// returns line text by index, "" if index is out of bounds
    dstring line(int index) {
        return index >= 0 && index < _lines.length ? _lines[index] : ""d;
    }

    /// returns line token properties one item per character (index is 0 based line number)
    TokenPropString lineTokenProps(int index) {
        return index >= 0 && index < _tokenProps.length ? _tokenProps[index] : null;
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
        // call listeners
		if (contentChangeListeners.assigned)
			contentChangeListeners(this, op, rangeBefore, rangeAfter, source);
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
            int startchar = 0;
            int endchar = cast(int)lineText.length;
            if (lineIndex == range.start.line)
                startchar = range.start.pos;
            if (lineIndex == range.end.line)
                endchar = range.end.pos;
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
    protected void insertLines(int start, int count) {
        assert(count > 0);
        _lines.length += count;
        _tokenProps.length = _lines.length;
        _editMarks.length = _lines.length;
        for (int i = cast(int)_lines.length - 1; i >= start + count; i--) {
            _lines[i] = _lines[i - count];
            _tokenProps[i] = _tokenProps[i - count];
            _editMarks[i] = _editMarks[i - count];
        }
        for (int i = start; i < start + count; i++) {
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
        for (int i = after.start.line; i <= after.end.line; i++) {
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

    static bool isDigit(dchar ch) pure nothrow {
        return ch >= '0' && ch <= '9';
    }
    static bool isAlpha(dchar ch) pure nothrow {
        return isLowerAlpha(ch) || isUpperAlpha(ch);
    }
    static bool isAlNum(dchar ch) pure nothrow {
        return isDigit(ch) || isAlpha(ch);
    }
    static bool isLowerAlpha(dchar ch) pure nothrow {
        return (ch >= 'a' && ch <= 'z') || (ch == '_');
    }
    static bool isUpperAlpha(dchar ch) pure nothrow {
        return (ch >= 'A' && ch <= 'Z');
    }
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
        EditStateMark[] newmarks = _undoBuffer.savedInUndo() ? op.oldEditMarks : null;
        TextRange rangeAfter = op.range;
        //Log.d("Undoing op rangeBefore=", rangeBefore, " contentBefore=`", oldcontent, "` rangeAfter=", rangeAfter, " contentAfter=`", newcontent, "`");
        replaceRange(rangeBefore, rangeAfter, newcontent, newmarks);
        handleContentChange(op, rangeBefore, rangeAfter, source ? source : this);
        return true;
    }

    /// redoes last undone change
    bool redo(Object source) {
        if (!hasUndo)
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
        clear();
        try {
            std.stream.File f = new std.stream.File(filename);
            scope(exit) { f.close(); }
            return load(f, filename);
        } catch (Exception e) {
            Log.e("Exception while trying to read file ", filename, " ", e.toString);
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
            std.stream.File f = new std.stream.File(filename, FileMode.OutNew);
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

