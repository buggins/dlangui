// Written in the D programming language.

/**
DLANGUI library.

This module contains implementation of editors.

EditLine single line editor.

Synopsis:

----
import dlangui.widgets.editors;

----

Copyright: Vadim Lopatin, 2014
License:   $(WEB boost.org/LICENSE_1_0.txt, Boost License 1.0).
Authors:   $(WEB coolreader.org, Vadim Lopatin)
*/
module dlangui.widgets.editors;

import dlangui.widgets.widget;
import dlangui.widgets.controls;
import dlangui.core.signals;
import dlangui.core.collections;
import dlangui.platforms.common.platform;

import std.algorithm;

immutable dchar EOL = '\n';

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
    Replace
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
		_content[0] = text;
	}
	this(EditAction action, TextRange range, dstring[] text) {
		_action = action;
		_range = range;
		_content = text;
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
                _oldContent[0] = (op._oldContent[0] ~ _oldContent[0]).dup;
                return true;
            } else if (_newRange.end.pos == op._range.start.pos) {
                // removed char after
                _range.end.pos++;
                _oldContent[0] = (_oldContent[0] ~ op._oldContent[0]).dup;
                return true;
            }
        }
        return false;
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
        if (!_undoList.empty) {
            if (_undoList.back.merge(op)) {
                _redoList.clear();
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
    }
}

interface EditableContentListener {
	bool onContentChange(EditableContent content, EditOperation operation, ref TextRange rangeBefore, ref TextRange rangeAfter);
}

/// editable plain text (singleline/multiline)
class EditableContent {

    this(bool multiline) {
        _multiline = multiline;
        _lines.length = 1; // initial state: single empty line
        _undoBuffer = new UndoBuffer();
    }

    protected UndoBuffer _undoBuffer;

	/// listeners for edit operations
	Signal!EditableContentListener contentChangeListeners;

    protected bool _multiline;
    /// returns true if miltyline content is supported
    @property bool multiline() { return _multiline; }

    protected dstring[] _lines;
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
    /// replace whole text with another content
    @property EditableContent text(dstring newContent) {
        clearUndo();
        _lines.length = 0;
        if (_multiline)
            _lines = splitDString(newContent);
        else {
            _lines.length = 1;
            _lines[0] = replaceEolsWithSpaces(newContent);
        }
        return this;
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

	/// returns text position for end of line lineIndex
	TextPosition lineEnd(int lineIndex) {
        return TextPosition(lineIndex, lineIndex >= 0 && lineIndex < _lines.length ? cast(int)_lines[lineIndex].length : 0);
	}

    /// returns maximum length of line
    int maxLineLength() {
        int m = 0;
        foreach(s; _lines)
            if (m < s.length)
                m = cast(int)s.length;
        return m;
    }

	bool handleContentChange(EditOperation op, ref TextRange rangeBefore, ref TextRange rangeAfter) {
		return contentChangeListeners(this, op, rangeBefore, rangeAfter);
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

    /// removes removedCount lines starting from start
    protected void removeLines(int start, int removedCount) {
        int end = start + removedCount;
        assert(removedCount > 0 && start >= 0 && end > 0 && start < _lines.length && end <= _lines.length);
        for (int i = start; i < _lines.length - removedCount; i++)
            _lines[i] = _lines[i + removedCount];
        for (int i = cast(int)_lines.length - removedCount; i < _lines.length; i++)
            _lines[i] = null; // free unused line references
        _lines.length -= removedCount;
    }

    /// inserts count empty lines at specified position
    protected void insertLines(int start, int count) {
        assert(count > 0);
        _lines.length += count;
        for (int i = cast(int)_lines.length - 1; i >= start + count; i--)
            _lines[i] = _lines[i - count];
        for (int i = start; i < start + count; i++)
            _lines[i] = ""d;
    }

    /// inserts or removes lines, removes text in range
    protected void replaceRange(TextRange before, TextRange after, dstring[] newContent) {
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
            dstring newline = newContent[i - after.start.line];
            if (i == after.start.line && i == after.end.line) {
                //Log.d("merging lines ", firstLineHead, " ", newline, " ", lastLineTail);
                _lines[i] = (firstLineHead ~ newline ~ lastLineTail).dup;
                //Log.d("merge result: ", _lines[i]);
            } else if (i == after.start.line)
                _lines[i] = (firstLineHead ~ newline).dup;
            else if (i == after.end.line)
                _lines[i] = (newline ~ lastLineTail).dup;
            else
                _lines[i] = newline; // no dup needed
        }
    }

	bool performOperation(EditOperation op) {
        if (op.action == EditAction.Replace) {
			TextRange rangeBefore = op.range;
            dstring[] oldcontent = rangeText(rangeBefore);
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
            op.newRange = rangeAfter;
            op.oldContent = oldcontent;
            replaceRange(rangeBefore, rangeAfter, newcontent);
			handleContentChange(op, rangeBefore, rangeAfter);
            _undoBuffer.saveForUndo(op);
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
    bool undo() {
        if (!hasUndo)
            return false;
        EditOperation op = _undoBuffer.undo();
        TextRange rangeBefore = op.newRange;
        dstring[] oldcontent = op.content;
        dstring[] newcontent = op.oldContent;
        TextRange rangeAfter = op.range;
        //Log.d("Undoing op rangeBefore=", rangeBefore, " contentBefore=`", oldcontent, "` rangeAfter=", rangeAfter, " contentAfter=`", newcontent, "`");
        replaceRange(rangeBefore, rangeAfter, newcontent);
        handleContentChange(op, rangeBefore, rangeAfter);
        return true;
    }
    /// redoes last undone change
    bool redo() {
        if (!hasUndo)
            return false;
        EditOperation op = _undoBuffer.redo();
        TextRange rangeBefore = op.range;
        dstring[] oldcontent = op.oldContent;
        dstring[] newcontent = op.content;
        TextRange rangeAfter = op.newRange;
        //Log.d("Redoing op rangeBefore=", rangeBefore, " contentBefore=`", oldcontent, "` rangeAfter=", rangeAfter, " contentAfter=`", newcontent, "`");
        replaceRange(rangeBefore, rangeAfter, newcontent);
        handleContentChange(op, rangeBefore, rangeAfter);
        return true;
    }
    /// clear undo/redp history
    void clearUndo() {
        _undoBuffer.clear();
    }
}

/// Editor action codes
enum EditorActions {
	None = 0,
    /// move cursor one char left
	Left = 1000,
    /// move cursor one char left with selection
	SelectLeft,
    /// move cursor one char right
	Right,
    /// move cursor one char right with selection
	SelectRight,
    /// move cursor one line up
	Up,
    /// move cursor one line up with selection
	SelectUp,
    /// move cursor one line down
	Down,
    /// move cursor one line down with selection
	SelectDown,
    /// move cursor one word left
	WordLeft,
    /// move cursor one word left with selection
	SelectWordLeft,
    /// move cursor one word right
	WordRight,
    /// move cursor one word right with selection
	SelectWordRight,
    /// move cursor one page up
	PageUp,
    /// move cursor one page up with selection
	SelectPageUp,
    /// move cursor one page down
	PageDown,
    /// move cursor one page down with selection
	SelectPageDown,
    /// move cursor to the beginning of page
	PageBegin, 
    /// move cursor to the beginning of page with selection
	SelectPageBegin, 
    /// move cursor to the end of page
	PageEnd,   
    /// move cursor to the end of page with selection
	SelectPageEnd,   
    /// move cursor to the beginning of line
	LineBegin,
    /// move cursor to the beginning of line with selection
	SelectLineBegin,
    /// move cursor to the end of line
	LineEnd,
    /// move cursor to the end of line with selection
	SelectLineEnd,
    /// move cursor to the beginning of document
	DocumentBegin,
    /// move cursor to the beginning of document with selection
	SelectDocumentBegin,
    /// move cursor to the end of document
	DocumentEnd,
    /// move cursor to the end of document with selection
	SelectDocumentEnd,
    /// delete char before cursor (backspace)
	DelPrevChar, 
    /// delete char after cursor (del key)
	DelNextChar, 
    /// delete word before cursor (ctrl + backspace)
	DelPrevWord, 
    /// delete char after cursor (ctrl + del key)
	DelNextWord, 

    /// insert new line (Enter)
	InsertNewLine,
    /// insert new line after current position (Ctrl+Enter)
	PrependNewLine,

    /// Copy selection to clipboard
	Copy, 
    /// Cut selection to clipboard
	Cut, 
    /// Paste selection from clipboard
	Paste, 
    /// Undo last change
    Undo,
    /// Redo last undoed change
    Redo,

    /// Tab (e.g., Tab key to insert tab character or indent text)
    Tab,
    /// Tab (unindent text, or remove whitespace before cursor, usually Shift+Tab)
    BackTab,

}

/// base for all editor widgets
class EditWidgetBase : WidgetGroup, EditableContentListener {
    protected EditableContent _content;
    protected Rect _clientRc;

    protected int _lineHeight;
    protected Point _scrollPos;
    protected bool _fixedFont;
    protected int _spaceWidth;
    protected int _tabSize = 4;

    protected bool _wantTabs = true;
    protected bool _useSpacesForTabs = false;


    this(string ID) {
        super(ID);
        focusable = true;
		acceleratorMap.add( [
			new Action(EditorActions.Up, KeyCode.UP, 0),
			new Action(EditorActions.SelectUp, KeyCode.UP, KeyFlag.Shift),
			new Action(EditorActions.Down, KeyCode.DOWN, 0),
			new Action(EditorActions.SelectDown, KeyCode.DOWN, KeyFlag.Shift),
			new Action(EditorActions.Left, KeyCode.LEFT, 0),
			new Action(EditorActions.SelectLeft, KeyCode.LEFT, KeyFlag.Shift),
			new Action(EditorActions.Right, KeyCode.RIGHT, 0),
			new Action(EditorActions.SelectRight, KeyCode.RIGHT, KeyFlag.Shift),
			new Action(EditorActions.WordLeft, KeyCode.LEFT, KeyFlag.Control),
			new Action(EditorActions.SelectWordLeft, KeyCode.LEFT, KeyFlag.Control | KeyFlag.Shift),
			new Action(EditorActions.WordRight, KeyCode.RIGHT, KeyFlag.Control),
			new Action(EditorActions.SelectWordRight, KeyCode.RIGHT, KeyFlag.Control | KeyFlag.Shift),
			new Action(EditorActions.PageUp, KeyCode.PAGEUP, 0),
			new Action(EditorActions.SelectPageUp, KeyCode.PAGEUP, KeyFlag.Shift),
			new Action(EditorActions.PageDown, KeyCode.PAGEDOWN, 0),
			new Action(EditorActions.SelectPageDown, KeyCode.PAGEDOWN, KeyFlag.Shift),
			new Action(EditorActions.PageBegin, KeyCode.PAGEUP, KeyFlag.Control),
			new Action(EditorActions.SelectPageBegin, KeyCode.PAGEUP, KeyFlag.Control | KeyFlag.Shift),
			new Action(EditorActions.PageEnd, KeyCode.PAGEDOWN, KeyFlag.Control),
			new Action(EditorActions.SelectPageEnd, KeyCode.PAGEDOWN, KeyFlag.Control | KeyFlag.Shift),
			new Action(EditorActions.LineBegin, KeyCode.HOME, 0),
			new Action(EditorActions.SelectLineBegin, KeyCode.HOME, KeyFlag.Shift),
			new Action(EditorActions.LineEnd, KeyCode.END, 0),
			new Action(EditorActions.SelectLineEnd, KeyCode.END, KeyFlag.Shift),
			new Action(EditorActions.DocumentBegin, KeyCode.HOME, KeyFlag.Control),
			new Action(EditorActions.SelectDocumentBegin, KeyCode.HOME, KeyFlag.Control | KeyFlag.Shift),
			new Action(EditorActions.DocumentEnd, KeyCode.END, KeyFlag.Control),
			new Action(EditorActions.SelectDocumentEnd, KeyCode.END, KeyFlag.Control | KeyFlag.Shift),

			new Action(EditorActions.InsertNewLine, KeyCode.RETURN, 0),
			new Action(EditorActions.InsertNewLine, KeyCode.RETURN, KeyFlag.Shift),
			new Action(EditorActions.PrependNewLine, KeyCode.RETURN, KeyFlag.Control),

            // Backspace/Del
			new Action(EditorActions.DelPrevChar, KeyCode.BACK, 0),
			new Action(EditorActions.DelNextChar, KeyCode.DEL, 0),
			new Action(EditorActions.DelPrevWord, KeyCode.BACK, KeyFlag.Control),
			new Action(EditorActions.DelNextWord, KeyCode.DEL, KeyFlag.Control),

            // Copy/Paste
			new Action(EditorActions.Copy, KeyCode.KEY_C, KeyFlag.Control),
			new Action(EditorActions.Copy, KeyCode.KEY_C, KeyFlag.Control|KeyFlag.Shift),
			new Action(EditorActions.Copy, KeyCode.INS, KeyFlag.Control),
			new Action(EditorActions.Cut, KeyCode.KEY_X, KeyFlag.Control),
			new Action(EditorActions.Cut, KeyCode.KEY_X, KeyFlag.Control|KeyFlag.Shift),
			new Action(EditorActions.Cut, KeyCode.DEL, KeyFlag.Shift),
			new Action(EditorActions.Paste, KeyCode.KEY_V, KeyFlag.Control),
			new Action(EditorActions.Paste, KeyCode.KEY_V, KeyFlag.Control|KeyFlag.Shift),
			new Action(EditorActions.Paste, KeyCode.INS, KeyFlag.Shift),

            // Undo/Redo
			new Action(EditorActions.Undo, KeyCode.KEY_Z, KeyFlag.Control),
			new Action(EditorActions.Redo, KeyCode.KEY_Y, KeyFlag.Control),
			new Action(EditorActions.Redo, KeyCode.KEY_Z, KeyFlag.Control|KeyFlag.Shift),

			new Action(EditorActions.Tab, KeyCode.TAB, 0),
			new Action(EditorActions.BackTab, KeyCode.TAB, KeyFlag.Shift),
		]);
    }

    /// when true, Tab / Shift+Tab presses are processed internally in widget (e.g. insert tab character) instead of focus change navigation.
    @property bool wantTabs() {
        return _wantTabs;
    }

    /// sets tab size (in number of spaces)
    @property EditWidgetBase wantTabs(bool wantTabs) {
        _wantTabs = wantTabs;
        return this;
    }

    /// when true, spaces will be inserted instead of tabs
    @property bool useSpacesForTabs() {
        return _useSpacesForTabs;
    }

    /// set new Tab key behavior flag: when true, spaces will be inserted instead of tabs
    @property EditWidgetBase useSpacesForTabs(bool useSpacesForTabs) {
        _useSpacesForTabs = useSpacesForTabs;
        return this;
    }

    /// returns tab size (in number of spaces)
    @property int tabSize() {
        return _tabSize;
    }

    /// sets tab size (in number of spaces)
    @property EditWidgetBase tabSize(int newTabSize) {
        if (newTabSize < 1)
            newTabSize = 1;
        else if (newTabSize > 16)
            newTabSize = 16;
        if (newTabSize != _tabSize) {
            _tabSize = newTabSize;
            requestLayout();
        }
        return this;
    }

    protected void updateMaxLineWidth() {
    }

	override bool onContentChange(EditableContent content, EditOperation operation, ref TextRange rangeBefore, ref TextRange rangeAfter) {
        updateMaxLineWidth();
		measureVisibleText();
		_caretPos = rangeAfter.end;
        _selectionRange.start = _caretPos;
        _selectionRange.end = _caretPos;
        ensureCaretVisible();
		invalidate();
		return true;
	}


    /// get widget text
    override @property dstring text() { return _content.text; }

    /// set text
    override @property Widget text(dstring s) { 
        _content.text = s;
        requestLayout();
		return this;
    }

    /// set text
    override @property Widget text(ref UIString s) { 
        _content.text = s;
        requestLayout();
		return this;
    }

    protected TextPosition _caretPos;
    protected TextRange _selectionRange;

    abstract protected Rect textPosToClient(TextPosition p);

    abstract protected TextPosition clientToTextPos(Point pt);

    abstract protected void ensureCaretVisible();

    abstract protected Point measureVisibleText();

    protected void updateFontProps() {
        FontRef font = font();
        _fixedFont = font.isFixed;
        _spaceWidth = font.spaceWidth;
        _lineHeight = font.height;
    }

    /// override to update scrollbars - if necessary
    protected void updateScrollbars() {
    }

    protected void correctCaretPos() {
        if (_caretPos.line >= _content.length)
            _caretPos.line = _content.length - 1;
        if (_caretPos.line < 0)
            _caretPos.line = 0;
        dstring currentLine = _content[_caretPos.line];
        if (_caretPos.pos > currentLine.length)
            _caretPos.pos = cast(int)currentLine.length;
        if (_caretPos.pos < 0)
            _caretPos.pos = 0;
    }


    private int[] _lineWidthBuf;
    protected int calcLineWidth(dstring s) {
        int w = 0;
        if (_fixedFont) {
            int tabw = _tabSize * _spaceWidth;
            // version optimized for fixed font
            for (int i = 0; i < s.length; i++) {
                if (s[i] == '\t') {
                    w += _spaceWidth;
                    w = (w + tabw - 1) / tabw * tabw;
                } else {
                    w += _spaceWidth;
                }
            }
        } else {
            // variable pitch font
            if (_lineWidthBuf.length < s.length)
                _lineWidthBuf.length = s.length;
            int charsMeasured = font.measureText(s, _lineWidthBuf, int.max);
            if (charsMeasured > 0)
                w = _lineWidthBuf[charsMeasured - 1];
        }
        return w;
    }

    protected void updateSelectionAfterCursorMovement(TextPosition oldCaretPos, bool selecting) {
        if (selecting) {
            if (oldCaretPos == _selectionRange.start) {
                if (_caretPos >= _selectionRange.end) {
                    _selectionRange.start = _selectionRange.end;
                    _selectionRange.end = _caretPos;
                } else {
                    _selectionRange.start = _caretPos;
                }
            } else if (oldCaretPos == _selectionRange.end) {
                if (_caretPos < _selectionRange.start) {
                    _selectionRange.end = _selectionRange.start;
                    _selectionRange.start = _caretPos;
                } else {
                    _selectionRange.end = _caretPos;
                }
            } else {
                _selectionRange.start = _caretPos;
                _selectionRange.end = _caretPos;
            }
        } else {
            _selectionRange.start = _caretPos;
            _selectionRange.end = _caretPos;
        }
        invalidate();
    }

    protected void updateCaretPositionByMouse(int x, int y, bool selecting) {
        TextPosition oldCaretPos = _caretPos;
        TextPosition newPos = clientToTextPos(Point(x,y));
        if (newPos != _caretPos) {
            _caretPos = newPos;
            updateSelectionAfterCursorMovement(oldCaretPos, selecting);
            invalidate();
        }
    }

    /// generate string of spaces, to reach next tab position
    protected dstring spacesForTab(int currentPos) {
        int newPos = (currentPos + tabSize + 1) / tabSize * tabSize;
        return "                "d[0..(newPos - currentPos)];
    }

    /// returns true if one or more lines selected fully
    protected bool wholeLinesSelected() {
        return _selectionRange.end.line > _selectionRange.start.line 
            && _selectionRange.end.pos == 0 
            && _selectionRange.start.pos == 0;
    }

	override protected bool handleAction(Action a) {
        TextPosition oldCaretPos = _caretPos;
        dstring currentLine = _content[_caretPos.line];
		switch (a.id) {
            case EditorActions.Left:
            case EditorActions.SelectLeft:
                correctCaretPos();
                if (_caretPos.pos > 0) {
                    _caretPos.pos--;
                    updateSelectionAfterCursorMovement(oldCaretPos, (a.id & 1) != 0);
                    ensureCaretVisible();
                } else if (_caretPos.line > 0) {
					_caretPos = _content.lineEnd(_caretPos.line - 1);
                    updateSelectionAfterCursorMovement(oldCaretPos, (a.id & 1) != 0);
                    ensureCaretVisible();
				}
                return true;
            case EditorActions.Right:
            case EditorActions.SelectRight:
                correctCaretPos();
                if (_caretPos.pos < currentLine.length) {
                    _caretPos.pos++;
                    updateSelectionAfterCursorMovement(oldCaretPos, (a.id & 1) != 0);
                    ensureCaretVisible();
                } else if (_caretPos.line < _content.length) {
                    _caretPos.pos = 0;
					_caretPos.line++;
                    updateSelectionAfterCursorMovement(oldCaretPos, (a.id & 1) != 0);
                    ensureCaretVisible();
				}
                return true;
            case EditorActions.DocumentBegin:
            case EditorActions.SelectDocumentBegin:
                if (_caretPos.pos > 0 || _caretPos.line > 0) {
                    _caretPos.line = 0;
                    _caretPos.pos = 0;
                    ensureCaretVisible();
                    updateSelectionAfterCursorMovement(oldCaretPos, (a.id & 1) != 0);
                }
                return true;
            case EditorActions.LineBegin:
            case EditorActions.SelectLineBegin:
                if (_caretPos.pos > 0) {
                    _caretPos.pos = 0;
                    ensureCaretVisible();
                    updateSelectionAfterCursorMovement(oldCaretPos, (a.id & 1) != 0);
                }
                return true;
            case EditorActions.DocumentEnd:
            case EditorActions.SelectDocumentEnd:
                if (_caretPos.line < _content.length - 1 || _caretPos.pos < _content[_content.length - 1].length) {
                    _caretPos.line = _content.length - 1;
                    _caretPos.pos = cast(int)_content[_content.length - 1].length;
                    ensureCaretVisible();
                    updateSelectionAfterCursorMovement(oldCaretPos, (a.id & 1) != 0);
                }
                return true;
            case EditorActions.LineEnd:
            case EditorActions.SelectLineEnd:
                if (_caretPos.pos < currentLine.length) {
                    _caretPos.pos = cast(int)currentLine.length;
                    ensureCaretVisible();
                    updateSelectionAfterCursorMovement(oldCaretPos, (a.id & 1) != 0);
                }
                return true;
            case EditorActions.DelPrevChar:
                if (!_selectionRange.empty) {
                    // clear selection
                    EditOperation op = new EditOperation(EditAction.Replace, _selectionRange, [""d]);
                    _content.performOperation(op);
                    ensureCaretVisible();
                    return true;
                }
                correctCaretPos();
                if (_caretPos.pos > 0) {
                    // delete prev char in current line
                    TextRange range = TextRange(_caretPos, _caretPos);
                    range.start.pos--;
                    EditOperation op = new EditOperation(EditAction.Replace, range, [""d]);
                    _content.performOperation(op);
                } else if (_caretPos.line > 0) {
                    // merge with previous line
                    TextRange range = TextRange(_caretPos, _caretPos);
                    range.start.line--;
                    dstring prevLine = _content[range.start.line];
                    range.start.pos = cast(int)prevLine.length;
                    EditOperation op = new EditOperation(EditAction.Replace, range, [""d]);
                    _content.performOperation(op);
                }
                return true;
            case EditorActions.DelNextChar:
                if (!_selectionRange.empty) {
                    EditOperation op = new EditOperation(EditAction.Replace, _selectionRange, [""d]);
                    _content.performOperation(op);
                    return true;
                }
                correctCaretPos();
                if (_caretPos.pos < currentLine.length) {
                    // delete char in current line
                    TextRange range = TextRange(_caretPos, _caretPos);
                    range.end.pos++;
                    EditOperation op = new EditOperation(EditAction.Replace, range, [""d]);
                    _content.performOperation(op);
                } else if (_caretPos.line < _content.length - 1) {
                    // merge with next line
                    TextRange range = TextRange(_caretPos, _caretPos);
                    range.end.line++;
                    range.end.pos = 0;
                    EditOperation op = new EditOperation(EditAction.Replace, range, [""d]);
                    _content.performOperation(op);
                }
                return true;
            case EditorActions.Copy:
                if (!_selectionRange.empty) {
                    dstring selectionText = concatDStrings(_content.rangeText(_selectionRange));
                    platform.setClipboardText(selectionText);
                }
                return true;
            case EditorActions.Cut:
                if (!_selectionRange.empty) {
                    dstring selectionText = concatDStrings(_content.rangeText(_selectionRange));
                    platform.setClipboardText(selectionText);
                    EditOperation op = new EditOperation(EditAction.Replace, _selectionRange, [""d]);
                    _content.performOperation(op);
                }
                return true;
            case EditorActions.Paste:
                {
                    dstring selectionText = platform.getClipboardText();
                    dstring[] lines;
                    if (_content.multiline) {
                        lines = splitDString(selectionText);
                    } else {
                        lines = [replaceEolsWithSpaces(selectionText)];
                    }
                    EditOperation op = new EditOperation(EditAction.Replace, _selectionRange, lines);
                    _content.performOperation(op);
                }
                return true;
            case EditorActions.Undo:
                {
                    _content.undo();
                }
                return true;
            case EditorActions.Redo:
                {
                    _content.redo();
                }
                return true;
            case EditorActions.Tab:
                {
                    if (_selectionRange.empty) {
                        if (_useSpacesForTabs) {
                            // insert one or more spaces to 
                            EditOperation op = new EditOperation(EditAction.Replace, TextRange(_caretPos, _caretPos), [spacesForTab(_caretPos.pos)]);
                            _content.performOperation(op);
                        } else {
                            // just insert tab character
                            EditOperation op = new EditOperation(EditAction.Replace, TextRange(_caretPos, _caretPos), ["\t"d]);
                            _content.performOperation(op);
                        }
                    } else {
                        if (wholeLinesSelected()) {
                            // indent range
                            indentRange(false);
                        } else {
                            // insert tab
                            if (_useSpacesForTabs) {
                                // insert one or more spaces to 
                                EditOperation op = new EditOperation(EditAction.Replace, _selectionRange, [spacesForTab(_selectionRange.start.pos)]);
                                _content.performOperation(op);
                            } else {
                                // just insert tab character
                                EditOperation op = new EditOperation(EditAction.Replace, _selectionRange, ["\t"d]);
                                _content.performOperation(op);
                            }
                        }

                    }
                }
                return true;
            case EditorActions.BackTab:
                {
                    if (_selectionRange.empty) {
                        // remove spaces before caret
                        TextRange r = spaceBefore(_caretPos);
                        if (!r.empty) {
                            EditOperation op = new EditOperation(EditAction.Replace, r, [""d]);
                            _content.performOperation(op);
                        }
                    } else {
                        if (wholeLinesSelected()) {
                            // unindent range
                            indentRange(true);
                        } else {
                            // remove space before selection
                            TextRange r = spaceBefore(_selectionRange.start);
                            if (!r.empty) {
                                int nchars = r.end.pos - r.start.pos;
                                TextRange saveRange = _selectionRange;
                                TextPosition saveCursor = _caretPos;
                                EditOperation op = new EditOperation(EditAction.Replace, r, [""d]);
                                _content.performOperation(op);
                                if (saveCursor.line == saveRange.start.line)
                                    saveCursor.pos -= nchars;
                                if (saveRange.end.line == saveRange.start.line)
                                    saveRange.end.pos -= nchars;
                                saveRange.start.pos -= nchars;
                                _selectionRange = saveRange;
                                _caretPos = saveCursor;
                                ensureCaretVisible();
                            }
                        }
                    }
                }
                return true;
			default:
				break;
		}
		return super.handleAction(a);
	}

    protected TextRange spaceBefore(TextPosition pos) {
        TextRange res = TextRange(pos, pos);
        dstring s = _content[pos.line];
        int x = 0;
        int start = -1;
        for (int i = 0; i < pos.pos; i++) {
            dchar ch = s[i];
            if (ch == ' ') {
                if (start == -1 || (x % tabSize) == 0)
                    start = i;
                x++;
            } else if (ch == '\t') {
                if (start == -1 || (x % tabSize) == 0)
                    start = i;
                x = (x + tabSize + 1) / tabSize * tabSize;
            } else {
                x++;
                start = -1;
            }
        }
        if (start != -1) {
            res.start.pos = start;
        }
        return res;
    }

    /// change line indent
    protected dstring indentLine(dstring src, bool back) {
        int firstNonSpace = -1;
        int x = 0;
        int unindentPos = -1;
        for (int i = 0; i < src.length; i++) {
            dchar ch = src[i];
            if (ch == ' ') {
                x++;
            } else if (ch == '\t') {
                x = (x + tabSize + 1) / tabSize * tabSize;
            } else {
                firstNonSpace = i;
                break;
            }
            if (x <= tabSize)
                unindentPos = i + 1;
        }
        if (firstNonSpace == -1) // only spaces or empty line -- do not change it
            return src;
        if (back) {
            // unindent
            if (unindentPos == -1)
                return src; // no change
            if (unindentPos == src.length)
                return ""d;
            return src[unindentPos .. $].dup;
        } else {
            // indent
            if (_useSpacesForTabs) {
                return spacesForTab(0) ~ src;
            } else {
                return "\t"d ~ src;
            }
        }
        return src;
    }

    /// indent / unindent range
    protected void indentRange(bool back) {
        int lineCount = _selectionRange.end.line - _selectionRange.start.line;
        dstring[] newContent = new dstring[lineCount + 1];
        bool changed = false;
        for (int i = 0; i < lineCount; i++) {
            dstring srcline = _content.line(_selectionRange.start.line + i);
            dstring dstline = indentLine(srcline, back);
            newContent[i] = dstline;
            if (dstline.length != srcline.length)
                changed = true;
        }
        if (changed) {
            TextRange saveRange = _selectionRange;
            TextPosition saveCursor = _caretPos;
            EditOperation op = new EditOperation(EditAction.Replace, _selectionRange, newContent);
            _content.performOperation(op);
            _selectionRange = saveRange;
            _caretPos = saveCursor;
            ensureCaretVisible();
        }
    }

    /// map key to action
    override protected Action findKeyAction(uint keyCode, uint flags) {
        // don't handle tabs when disabled
        if (keyCode == KeyCode.TAB && (flags == 0 || flags == KeyFlag.Shift) && !_wantTabs)
            return null;
        return super.findKeyAction(keyCode, flags);
    }

	/// handle keys
	override bool onKeyEvent(KeyEvent event) {
		//
		if (event.action == KeyAction.KeyDown) {
			//EditorAction a = keyToAction(event.keyCode, event.flags & (KeyFlag.Shift | KeyFlag.Alt | KeyFlag.Ctrl));
			//switch(event.keyCode) {
			//    
			//}
		} else if (event.action == KeyAction.Text && event.text.length) {
			Log.d("text entered: ", event.text);
			dchar ch = event.text[0];
			if (ch >= 32) { // ignore Backspace and Return
				EditOperation op = new EditOperation(EditAction.Replace, _selectionRange, [event.text]);
				_content.performOperation(op);
				return true;
			}
		}
		return super.onKeyEvent(event);
	}

    /// process mouse event; return true if event is processed by widget.
    override bool onMouseEvent(MouseEvent event) {
        //Log.d("onMouseEvent ", id, " ", event.action, "  (", event.x, ",", event.y, ")");
		// support onClick
	    if (event.action == MouseAction.ButtonDown && event.button == MouseButton.Left) {
            setFocus();
            updateCaretPositionByMouse(event.x - _clientRc.left, event.y - _clientRc.top, false);
            invalidate();
	        return true;
	    }
	    if (event.action == MouseAction.Move && (event.flags & MouseButton.Left) != 0) {
            updateCaretPositionByMouse(event.x - _clientRc.left, event.y - _clientRc.top, true);
	        return true;
	    }
	    if (event.action == MouseAction.ButtonUp && event.button == MouseButton.Left) {
	        return true;
	    }
	    if (event.action == MouseAction.FocusOut || event.action == MouseAction.Cancel) {
	        return true;
	    }
	    if (event.action == MouseAction.FocusIn) {
	        return true;
	    }
	    return false;
    }


}


/// single line editor
class EditLine : EditWidgetBase {

    this(string ID, dstring initialContent = null) {
        super(ID);
        _content = new EditableContent(false);
		_content.contentChangeListeners = this;
        wantTabs = false;
        styleId = "EDIT_LINE";
        text = initialContent;
    }

    protected dstring _measuredText;
    protected int[] _measuredTextWidths;
    protected Point _measuredTextSize;

    override protected Rect textPosToClient(TextPosition p) {
        Rect res;
        res.bottom = _clientRc.height;
        if (p.pos == 0)
            res.left = 0;
        else if (p.pos >= _measuredText.length)
            res.left = _measuredTextSize.x;
        else
            res.left = _measuredTextWidths[p.pos - 1];
		res.left -= _scrollPos.x;
        res.right = res.left + 1;
        return res;
    }

    override protected TextPosition clientToTextPos(Point pt) {
		pt.x += _scrollPos.x;
        TextPosition res;
        for (int i = 0; i < _measuredText.length; i++) {
            int x0 = i > 0 ? _measuredTextWidths[i - 1] : 0;
            int x1 = _measuredTextWidths[i];
            int mx = (x0 + x1) >> 1;
            if (pt.x < mx) {
                res.pos = i;
                return res;
            }
        }
        res.pos = cast(int)_measuredText.length;
        return res;
    }

    override protected void ensureCaretVisible() {
        //_scrollPos
        Rect rc = textPosToClient(_caretPos);
        if (rc.left < 0) {
            // scroll left
            _scrollPos.x -= -rc.left + _clientRc.width / 10;
            if (_scrollPos.x < 0)
                _scrollPos.x = 0;
            invalidate();
        } else if (rc.left >= _clientRc.width - 10) {
            // scroll right
            _scrollPos.x += (rc.left - _clientRc.width) + _spaceWidth * 4;
            invalidate();
        }
        updateScrollbars();
    }

    override protected Point measureVisibleText() {
        FontRef font = font();
        //Point sz = font.textSize(text);
        _measuredText = text;
        _measuredTextWidths.length = _measuredText.length;
        int charsMeasured = font.measureText(_measuredText, _measuredTextWidths, int.max, tabSize);
        _measuredTextSize.x = charsMeasured > 0 ? _measuredTextWidths[charsMeasured - 1]: 0;
        _measuredTextSize.y = font.height;
        return _measuredTextSize;
    }

    /// measure
    override void measure(int parentWidth, int parentHeight) { 
        updateFontProps();
        measureVisibleText();
        measuredContent(parentWidth, parentHeight, _measuredTextSize.x, _measuredTextSize.y);
    }

	override protected bool handleAction(Action a) {
		switch (a.id) {
            /*
            case EditorActions.DelPrevChar:
                if (_caretPos.pos > 0) {
                    TextRange range = TextRange(_caretPos, _caretPos);
                    range.start.pos--;
                    EditOperation op = new EditOperation(EditAction.Replace, range, [""d]);
                    _content.performOperation(op);
                }
                return true;
            case EditorActions.DelNextChar:
                if (_caretPos.pos < _measuredText.length) {
                    TextRange range = TextRange(_caretPos, _caretPos);
                    range.end.pos++;
                    EditOperation op = new EditOperation(EditAction.Replace, range, [""d]);
                    _content.performOperation(op);
                }
                return true;
            */
            case EditorActions.Up:
                break;
            case EditorActions.Down:
                break;
            case EditorActions.WordLeft:
                break;
            case EditorActions.WordRight:
                break;
            case EditorActions.PageUp:
                break;
            case EditorActions.PageDown:
                break;
            default:
                break;
		}
		return super.handleAction(a);
	}


	/// handle keys
	override bool onKeyEvent(KeyEvent event) {
		return super.onKeyEvent(event);
	}

    /// process mouse event; return true if event is processed by widget.
    override bool onMouseEvent(MouseEvent event) {
	    return super.onMouseEvent(event);
    }

    /// Set widget rectangle to specified value and layout widget contents. (Step 2 of two phase layout).
    override void layout(Rect rc) {
        _needLayout = false;
        if (visibility == Visibility.Gone) {
            return;
        }
        Point sz = Point(rc.width, measuredHeight);
        applyAlign(rc, sz);
        _pos = rc;
        _clientRc = rc;
        applyMargins(_clientRc);
        applyPadding(_clientRc);
    }

    /// override to custom highlight of line background
    protected void drawLineBackground(DrawBuf buf, Rect lineRect, Rect visibleRect) {
        if (!_selectionRange.empty) {
            // line inside selection
            Rect startrc = textPosToClient(_selectionRange.start);
            Rect endrc = textPosToClient(_selectionRange.end);
            int startx = startrc.left + _clientRc.left;
            int endx = endrc.left + _clientRc.left;
            Rect rc = lineRect;
            rc.left = startx;
            rc.right = endx;
            if (!rc.empty) {
                // draw selection rect for line
                buf.fillRect(rc, 0xB060A0FF);
            }
        }
    }

    /// draw content
    override void onDraw(DrawBuf buf) {
        if (visibility != Visibility.Visible)
            return;
        super.onDraw(buf);
        Rect rc = _pos;
        applyMargins(rc);
        auto saver = ClipRectSaver(buf, rc);
        applyPadding(rc);
        FontRef font = font();
        dstring txt = text;
        Point sz = font.textSize(txt);
        //applyAlign(rc, sz);
        Rect lineRect = _clientRc;
        lineRect.left = _clientRc.left - _scrollPos.x;
        lineRect.right = lineRect.left + calcLineWidth(txt);
        Rect visibleRect = lineRect;
        visibleRect.left = _clientRc.left;
        visibleRect.right = _clientRc.right;
        drawLineBackground(buf, lineRect, visibleRect);
        font.drawText(buf, rc.left - _scrollPos.x, rc.top + sz.y / 10, txt, textColor, tabSize);
        if (focused) {
            // draw caret
            Rect caretRc = textPosToClient(_caretPos);
            caretRc.offset(_clientRc.left, _clientRc.top);
            buf.fillRect(caretRc, 0x000000);
        }
    }
}



/// single line editor
class EditBox : EditWidgetBase, OnScrollHandler {
    protected ScrollBar _hscrollbar;
    protected ScrollBar _vscrollbar;

    this(string ID, dstring initialContent = null) {
        super(ID);
        _content = new EditableContent(true); // multiline
		_content.contentChangeListeners = this;
        styleId = "EDIT_BOX";
        text = initialContent;
        _hscrollbar = new ScrollBar("hscrollbar", Orientation.Horizontal);
        _vscrollbar = new ScrollBar("vscrollbar", Orientation.Vertical);
        _hscrollbar.onScrollEventListener = this;
        _vscrollbar.onScrollEventListener = this;
        addChild(_hscrollbar);
        addChild(_vscrollbar);
    }

    protected int _firstVisibleLine;

    protected int _maxLineWidth;
    protected int _numVisibleLines;             // number of lines visible in client area
    protected dstring[] _visibleLines;          // text for visible lines
    protected int[][] _visibleLinesMeasurement; // char positions for visible lines
    protected int[] _visibleLinesWidths; // width (in pixels) of visible lines

    override protected void updateMaxLineWidth() {
        // find max line width. TODO: optimize!!!
        int maxw;
        int[] buf;
        for (int i = 0; i < _content.length; i++) {
            dstring s = _content[i];
            int w = calcLineWidth(s);
            if (maxw < w)
                maxw = w;
        }
        _maxLineWidth = maxw;
    }

    override protected Point measureVisibleText() {
        Point sz;
        FontRef font = font();
        _lineHeight = font.height;
        _numVisibleLines = (_clientRc.height + _lineHeight - 1) / _lineHeight;
        if (_firstVisibleLine + _numVisibleLines > _content.length)
            _numVisibleLines = _content.length - _firstVisibleLine;
        _visibleLines.length = _numVisibleLines;
        _visibleLinesMeasurement.length = _numVisibleLines;
        _visibleLinesWidths.length = _numVisibleLines;
        for (int i = 0; i < _numVisibleLines; i++) {
            _visibleLines[i] = _content[_firstVisibleLine + i];
            _visibleLinesMeasurement[i].length = _visibleLines[i].length;
            int charsMeasured = font.measureText(_visibleLines[i], _visibleLinesMeasurement[i], int.max, tabSize);
            _visibleLinesWidths[i] = charsMeasured > 0 ? _visibleLinesMeasurement[i][charsMeasured - 1] : 0;
            if (sz.x < _visibleLinesWidths[i])
                sz.x = _visibleLinesWidths[i]; // width - max from visible lines
        }
        sz.x = _maxLineWidth;
        sz.y = _lineHeight * _content.length; // height - for all lines
        return sz;
    }

    override protected void updateScrollbars() {
        int visibleLines = _clientRc.height / _lineHeight; // fully visible lines
        if (visibleLines < 1)
            visibleLines = 1;
        _vscrollbar.setRange(0, _content.length - 1);
        _vscrollbar.pageSize = visibleLines;
        _vscrollbar.position = _firstVisibleLine;
        _hscrollbar.setRange(0, _maxLineWidth + _clientRc.width / 4);
        _hscrollbar.pageSize = _clientRc.width;
        _hscrollbar.position = _scrollPos.x;
    }

    /// handle scroll event
    override bool onScrollEvent(AbstractSlider source, ScrollEvent event) {
        if (source.id.equal("hscrollbar")) {
            if (_scrollPos.x != event.position) {
                _scrollPos.x = event.position;
                invalidate();
            }
            return true;
        } else if (source.id.equal("vscrollbar")) {
            if (_firstVisibleLine != event.position) {
                _firstVisibleLine = event.position;
                measureVisibleText();
                invalidate();
            }
            return true;
        }
        return false;

    }

    override protected void ensureCaretVisible() {
        if (_caretPos.line >= _content.length)
            _caretPos.line = _content.length - 1;
        if (_caretPos.line < 0)
            _caretPos.line = 0;
        int visibleLines = _clientRc.height / _lineHeight; // fully visible lines
        if (visibleLines < 1)
            visibleLines = 1;
        if (_caretPos.line < _firstVisibleLine) {
            _firstVisibleLine = _caretPos.line;
            measureVisibleText();
            invalidate();
        } else if (_caretPos.line >= _firstVisibleLine + visibleLines) {
            _firstVisibleLine = _caretPos.line - visibleLines + 1;
            if (_firstVisibleLine < 0)
                _firstVisibleLine = 0;
            measureVisibleText();
            invalidate();
        }
        //_scrollPos
        Rect rc = textPosToClient(_caretPos);
        if (rc.left < 0) {
            // scroll left
            _scrollPos.x -= -rc.left + _clientRc.width / 4;
            if (_scrollPos.x < 0)
                _scrollPos.x = 0;
            invalidate();
        } else if (rc.left >= _clientRc.width - 10) {
            // scroll right
            _scrollPos.x += (rc.left - _clientRc.width) + _clientRc.width / 4;
            invalidate();
        }
        updateScrollbars();    
    }

    override protected Rect textPosToClient(TextPosition p) {
        Rect res;
        int lineIndex = p.line - _firstVisibleLine;
        res.top = lineIndex * _lineHeight;
        res.bottom = res.top + _lineHeight;
        if (lineIndex >=0 && lineIndex < _visibleLines.length) {
            if (p.pos == 0)
                res.left = 0;
            else if (p.pos >= _visibleLinesMeasurement[lineIndex].length)
                res.left = _visibleLinesWidths[lineIndex];
            else
                res.left = _visibleLinesMeasurement[lineIndex][p.pos - 1];
        }
        res.left -= _scrollPos.x;
        res.right = res.left + 1;
        return res;
    }

    override protected TextPosition clientToTextPos(Point pt) {
        TextPosition res;
        pt.x += _scrollPos.x;
        int lineIndex = pt.y / _lineHeight;
        if (lineIndex < 0)
            lineIndex = 0;
        if (lineIndex < _visibleLines.length) {
            res.line = lineIndex + _firstVisibleLine;
            for (int i = 0; i < _visibleLinesMeasurement[lineIndex].length; i++) {
                int x0 = i > 0 ? _visibleLinesMeasurement[lineIndex][i - 1] : 0;
                int x1 = _visibleLinesMeasurement[lineIndex][i];
                int mx = (x0 + x1) >> 1;
                if (pt.x < mx) {
                    res.pos = i;
                    return res;
                }
            }
            res.pos = cast(int)_visibleLines[lineIndex].length;
        } else {
            res.line = _firstVisibleLine + cast(int)_visibleLines.length - 1;
            res.pos = cast(int)_visibleLines[$ - 1].length;
        }
        return res;
    }

	override protected bool handleAction(Action a) {
        TextPosition oldCaretPos = _caretPos;
        dstring currentLine = _content[_caretPos.line];
		switch (a.id) {
            case EditorActions.PrependNewLine:
                {
                    correctCaretPos();
                    _caretPos.pos = 0;
                    EditOperation op = new EditOperation(EditAction.Replace, _selectionRange, [""d, ""d]);
                    _content.performOperation(op);
                }
                return true;
            case EditorActions.InsertNewLine:
                {
                    correctCaretPos();
                    EditOperation op = new EditOperation(EditAction.Replace, _selectionRange, [""d, ""d]);
                    _content.performOperation(op);
                }
                return true;
            case EditorActions.Up:
            case EditorActions.SelectUp:
                if (_caretPos.line > 0) {
                    _caretPos.line--;
                    updateSelectionAfterCursorMovement(oldCaretPos, (a.id & 1) != 0);
                    ensureCaretVisible();
                }
                return true;
            case EditorActions.Down:
            case EditorActions.SelectDown:
                if (_caretPos.line < _content.length - 1) {
                    _caretPos.line++;
                    updateSelectionAfterCursorMovement(oldCaretPos, (a.id & 1) != 0);
                    ensureCaretVisible();
                }
                return true;
            case EditorActions.WordLeft:
            case EditorActions.SelectWordLeft:
                break;
            case EditorActions.WordRight:
            case EditorActions.SelectWordRight:
                break;
            case EditorActions.PageBegin:
            case EditorActions.SelectPageBegin:
                {
                    ensureCaretVisible();
                    _caretPos.line = _firstVisibleLine;
                    updateSelectionAfterCursorMovement(oldCaretPos, (a.id & 1) != 0);
                    return true;
                }
                break;
            case EditorActions.PageEnd:
            case EditorActions.SelectPageEnd:
                {
                    ensureCaretVisible();
                    int fullLines = _clientRc.height / _lineHeight;
                    int newpos = _firstVisibleLine + fullLines - 1;
                    if (newpos >= _content.length)
                        newpos = _content.length - 1;
                    _caretPos.line = newpos;
                    updateSelectionAfterCursorMovement(oldCaretPos, (a.id & 1) != 0);
                    return true;
                }
                break;
            case EditorActions.PageUp:
            case EditorActions.SelectPageUp:
                {
                    ensureCaretVisible();
                    int fullLines = _clientRc.height / _lineHeight;
                    int newpos = _firstVisibleLine - fullLines;
                    if (newpos < 0) {
                        _firstVisibleLine = 0;
                        _caretPos.line = 0;
                    } else {
                        int delta = _firstVisibleLine - newpos;
                        _firstVisibleLine = newpos;
                        _caretPos.line -= delta;
                    }
                    measureVisibleText();
                    updateScrollbars();
                    updateSelectionAfterCursorMovement(oldCaretPos, (a.id & 1) != 0);
                    return true;
                }
                break;
            case EditorActions.PageDown:
            case EditorActions.SelectPageDown:
                {
                    ensureCaretVisible();
                    int fullLines = _clientRc.height / _lineHeight;
                    int newpos = _firstVisibleLine + fullLines;
                    if (newpos >= _content.length) {
                        _caretPos.line = _content.length - 1;
                    } else {
                        int delta = newpos - _firstVisibleLine;
                        _firstVisibleLine = newpos;
                        _caretPos.line += delta;
                    }
                    measureVisibleText();
                    updateScrollbars();
                    updateSelectionAfterCursorMovement(oldCaretPos, (a.id & 1) != 0);
                    return true;
                }
                break;
            default:
                break;
		}
		return super.handleAction(a);
	}


    /// measure
    override void measure(int parentWidth, int parentHeight) { 
        if (visibility == Visibility.Gone) {
            return;
        }
        _hscrollbar.measure(parentWidth, parentHeight);
        _vscrollbar.measure(parentWidth, parentHeight);
        int hsbheight = _hscrollbar.measuredHeight;
        int vsbwidth = _vscrollbar.measuredWidth;

        updateFontProps();

        updateMaxLineWidth();

        //measureText();
        Point textSz = measureVisibleText();
        measuredContent(parentWidth, parentHeight, textSz.x + vsbwidth, textSz.y + hsbheight);
    }

    /// Set widget rectangle to specified value and layout widget contents. (Step 2 of two phase layout).
    override void layout(Rect rc) {
        _needLayout = false;
        if (visibility == Visibility.Gone) {
            return;
        }
        _pos = rc;


        applyMargins(rc);
        applyPadding(rc);
        int hsbheight = _hscrollbar.measuredHeight;
        int vsbwidth = _vscrollbar.measuredWidth;
        Rect sbrc = rc;
        sbrc.left = sbrc.right - vsbwidth;
        sbrc.bottom -= hsbheight;
        _vscrollbar.layout(sbrc);
        sbrc = rc;
        sbrc.right -= vsbwidth;
        sbrc.top = sbrc.bottom - hsbheight;
        _hscrollbar.layout(sbrc);
        // calc client rectangle
        _clientRc = rc;
        _clientRc.right -= vsbwidth;
        _clientRc.bottom -= hsbheight;
        Point textSz = measureVisibleText();
        updateScrollbars();
    }

    /// override to custom highlight of line background
    protected void drawLineBackground(DrawBuf buf, int lineIndex, Rect lineRect, Rect visibleRect) {
        // highlight odd lines
        //if ((lineIndex & 1))
        //    buf.fillRect(visibleRect, 0xF4808080);

        if (!_selectionRange.empty && _selectionRange.start.line <= lineIndex && _selectionRange.end.line >= lineIndex) {
            // line inside selection
            Rect startrc = textPosToClient(_selectionRange.start);
            Rect endrc = textPosToClient(_selectionRange.end);
            int startx = lineIndex == _selectionRange.start.line ? startrc.left + _clientRc.left : lineRect.left;
            int endx = lineIndex == _selectionRange.end.line ? endrc.left + _clientRc.left : lineRect.right + _spaceWidth;
            Rect rc = lineRect;
            rc.left = startx;
            rc.right = endx;
            if (!rc.empty) {
                // draw selection rect for line
                buf.fillRect(rc, 0xB060A0FF);
            }
        }

        // frame around current line
        if (lineIndex == _caretPos.line && _selectionRange.singleLine && _selectionRange.start.line == _caretPos.line) {
            buf.drawFrame(visibleRect, 0xA0808080, Rect(1,1,1,1));
        }
    }

    /// draw content
    override void onDraw(DrawBuf buf) {
        if (visibility != Visibility.Visible)
            return;
        super.onDraw(buf);
        _hscrollbar.onDraw(buf);
        _vscrollbar.onDraw(buf);
        Rect rc = _clientRc;
        auto saver = ClipRectSaver(buf, rc);

        FontRef font = font();
        //dstring txt = text;
        //Point sz = font.textSize(txt);
        //font.drawText(buf, rc.left, rc.top + sz.y / 10, txt, textColor);
        for (int i = 0; i < _visibleLines.length; i++) {
            dstring txt = _visibleLines[i];
            Rect lineRect = rc;
            lineRect.left = _clientRc.left - _scrollPos.x;
            lineRect.right = lineRect.left + calcLineWidth(_content[_firstVisibleLine + i]);
            lineRect.top = _clientRc.top + i * _lineHeight;
            lineRect.bottom = lineRect.top + _lineHeight;
            Rect visibleRect = lineRect;
            visibleRect.left = _clientRc.left;
            visibleRect.right = _clientRc.right;
            drawLineBackground(buf, _firstVisibleLine + i, lineRect, visibleRect);
            if (txt.length > 0) {
                font.drawText(buf, rc.left - _scrollPos.x, rc.top + i * _lineHeight, txt, textColor, tabSize);
            }
        }

        //buf.fillRect(_clientRc, 0x80E0E0FF); // testing clientRc
        if (focused) {
            // draw caret
            Rect caretRc = textPosToClient(_caretPos);
            caretRc.offset(_clientRc.left, _clientRc.top);
            buf.fillRect(caretRc, 0x000000);
        }
    }

}
