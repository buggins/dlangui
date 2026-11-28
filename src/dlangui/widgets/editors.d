// Written in the D programming language.

/**
This module contains implementation of editors.


EditLine - single line editor.

EditBox - multiline editor

LogWidget - readonly text box for showing logs

Synopsis:

----
import dlangui.widgets.editors;

----

Copyright: Vadim Lopatin, 2014
License:   Boost License 1.0
Authors:   Vadim Lopatin, coolreader.org@gmail.com
*/
module dlangui.widgets.editors;

import dlangui.widgets.widget;
import dlangui.widgets.controls;
import dlangui.widgets.scroll;
import dlangui.widgets.layouts;
import dlangui.core.signals;
import dlangui.core.collections;
import dlangui.core.linestream;
import dlangui.platforms.common.platform;
import dlangui.widgets.menu;
import dlangui.widgets.popup;
import dlangui.graphics.colors;
public import dlangui.core.editable;

import std.algorithm;
import std.conv : to;
import dlangui.core.streams;
import dlangui.core.stdaction : StandardAction, ACTION_CANCEL, ACTION_CLOSE, ACTION_IGNORE;

/// Modified state change listener
interface ModifiedStateListener {
    void onModifiedStateChange(Widget source, bool modified);
}

/// Modified content listener
interface EditableContentChangeListener {
    void onEditableContentChanged(EditableContent source);
}

/// editor state to display in status line
struct EditorStateInfo {
    /// editor mode: true if replace mode, false if insert mode
    bool replaceMode;
    /// cursor position column (1-based)
    int col;
    /// cursor position line (1-based)
    int line;
    /// character under cursor
    dchar character;
    /// returns true if editor is in active state
    @property bool active() { return col > 0 && line > 0; }
}

interface EditorStateListener {
    void onEditorStateUpdate(Widget source, ref EditorStateInfo editorState);
}

/// Flags used for search / replace / text highlight
enum TextSearchFlag {
    CaseSensitive = 1,
    WholeWords = 2,
    SelectionOnly = 4,
}

/// a range containing every text position: a search scope of the whole text (#1166)
immutable TextRange WHOLE_TEXT_RANGE = TextRange(TextPosition(0, 0), TextPosition(int.max, int.max));

/// Editor action codes
enum EditorActions : int {
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
    /// insert new line before current position (Ctrl+Enter)
    PrependNewLine,
    /// insert new line after current position (Ctrl+Enter)
    AppendNewLine,

    /// Turn On/Off replace mode
    ToggleReplaceMode,

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
    /// Indent text block or single line
    Indent,
    /// Unindent text
    Unindent,

    /// Select whole content (usually, Ctrl+A)
    SelectAll,

    // Scroll operations

    /// Scroll one line up (not changing cursor)
    ScrollLineUp,
    /// Scroll one line down (not changing cursor)
    ScrollLineDown,
    /// Scroll one page up (not changing cursor)
    ScrollPageUp,
    /// Scroll one page down (not changing cursor)
    ScrollPageDown,
    /// Scroll window left
    ScrollLeft,
    /// Scroll window right
    ScrollRight,

    /// Zoom in editor font
    ZoomIn,
    /// Zoom out editor font
    ZoomOut,

    /// Togle line comment
    ToggleLineComment,
    /// Toggle block comment
    ToggleBlockComment,
    /// Delete current line
    DeleteLine,
    /// Insert line
    InsertLine,

    /// Toggle bookmark in current line
    ToggleBookmark,
    /// move cursor to next bookmark
    GoToNextBookmark,
    /// move cursor to previous bookmark
    GoToPreviousBookmark,

    /// Find text
    Find,
    /// Replace text
    Replace,

    /// Find next occurence - continue search forward
    FindNext,
    /// Find previous occurence - continue search backward
    FindPrev,

    /// read the file again after another program changed it (external change message, #1280)
    ReloadFile,
    /// keep the text after another program changed or deleted the file (external change message)
    KeepFileText,
    /// write the text to the file although another program changed or deleted it (external change message)
    SaveFile,
}


void initStandardEditorActions() {
    // register editor action names and ids
    registerActionEnum!EditorActions();
}

const Action ACTION_EDITOR_COPY = (new Action(EditorActions.Copy, "MENU_EDIT_COPY"c, null, KeyCode.KEY_C, KeyFlag.Control)).addAccelerator(KeyCode.INS, KeyFlag.Control).disableByDefault();
const Action ACTION_EDITOR_PASTE = (new Action(EditorActions.Paste, "MENU_EDIT_PASTE"c, null, KeyCode.KEY_V, KeyFlag.Control)).addAccelerator(KeyCode.INS, KeyFlag.Shift).disableByDefault();
const Action ACTION_EDITOR_CUT = (new Action(EditorActions.Cut, "MENU_EDIT_CUT"c, null, KeyCode.KEY_X, KeyFlag.Control)).addAccelerator(KeyCode.DEL, KeyFlag.Shift).disableByDefault();
const Action ACTION_EDITOR_UNDO = (new Action(EditorActions.Undo, "MENU_EDIT_UNDO"c, null, KeyCode.KEY_Z, KeyFlag.Control)).disableByDefault();
const Action ACTION_EDITOR_REDO = (new Action(EditorActions.Redo, "MENU_EDIT_REDO"c, null, KeyCode.KEY_Y, KeyFlag.Control)).addAccelerator(KeyCode.KEY_Z, KeyFlag.Control|KeyFlag.Shift).disableByDefault();

const Action ACTION_EDITOR_INSERT_NEW_LINE = (new Action(EditorActions.InsertNewLine, KeyCode.RETURN, 0, ActionStateUpdateFlag.never)).addAccelerator(KeyCode.RETURN, KeyFlag.Shift);
const Action ACTION_EDITOR_PREPEND_NEW_LINE = (new Action(EditorActions.PrependNewLine, KeyCode.RETURN, KeyFlag.Control | KeyFlag.Shift, ActionStateUpdateFlag.never));
const Action ACTION_EDITOR_APPEND_NEW_LINE = (new Action(EditorActions.AppendNewLine, KeyCode.RETURN, KeyFlag.Control, ActionStateUpdateFlag.never));
const Action ACTION_EDITOR_DELETE_LINE = (new Action(EditorActions.DeleteLine, KeyCode.KEY_D, KeyFlag.Control, ActionStateUpdateFlag.never)).addAccelerator(KeyCode.KEY_L, KeyFlag.Control);
const Action ACTION_EDITOR_TOGGLE_REPLACE_MODE = (new Action(EditorActions.ToggleReplaceMode, KeyCode.INS, 0, ActionStateUpdateFlag.never));
const Action ACTION_EDITOR_SELECT_ALL = (new Action(EditorActions.SelectAll, KeyCode.KEY_A, KeyFlag.Control, ActionStateUpdateFlag.never));
const Action ACTION_EDITOR_TOGGLE_LINE_COMMENT = (new Action(EditorActions.ToggleLineComment, KeyCode.KEY_DIVIDE, KeyFlag.Control));
const Action ACTION_EDITOR_TOGGLE_BLOCK_COMMENT = (new Action(EditorActions.ToggleBlockComment, KeyCode.KEY_DIVIDE, KeyFlag.Control | KeyFlag.Shift));
const Action ACTION_EDITOR_TOGGLE_BOOKMARK = (new Action(EditorActions.ToggleBookmark, "ACTION_EDITOR_TOGGLE_BOOKMARK"c, null, KeyCode.KEY_B, KeyFlag.Control | KeyFlag.Shift));
const Action ACTION_EDITOR_GOTO_NEXT_BOOKMARK = (new Action(EditorActions.GoToNextBookmark, "ACTION_EDITOR_GOTO_NEXT_BOOKMARK"c, null, KeyCode.DOWN, KeyFlag.Control | KeyFlag.Shift | KeyFlag.Alt));
const Action ACTION_EDITOR_GOTO_PREVIOUS_BOOKMARK = (new Action(EditorActions.GoToPreviousBookmark, "ACTION_EDITOR_GOTO_PREVIOUS_BOOKMARK"c, null, KeyCode.UP, KeyFlag.Control | KeyFlag.Shift | KeyFlag.Alt));
const Action ACTION_EDITOR_FIND = (new Action(EditorActions.Find, "ACTION_EDITOR_FIND"c, null, KeyCode.KEY_F, KeyFlag.Control));
const Action ACTION_EDITOR_FIND_NEXT = (new Action(EditorActions.FindNext, "ACTION_EDITOR_FIND_NEXT"c, null, KeyCode.F3, 0));
const Action ACTION_EDITOR_FIND_PREV = (new Action(EditorActions.FindPrev, "ACTION_EDITOR_FIND_PREV"c, null, KeyCode.F3, KeyFlag.Shift));
const Action ACTION_EDITOR_REPLACE = (new Action(EditorActions.Replace, "ACTION_EDITOR_REPLACE"c, null, KeyCode.KEY_H, KeyFlag.Control));

/// buttons of the external change message of EditBox (#1280)
const Action ACTION_EDITOR_RELOAD_FILE = new Action(EditorActions.ReloadFile, "ACTION_EDITOR_RELOAD_FILE"c);
/// ditto
const Action ACTION_EDITOR_KEEP_MY_TEXT = new Action(EditorActions.KeepFileText, "ACTION_EDITOR_KEEP_MY_TEXT"c);
/// ditto
const Action ACTION_EDITOR_KEEP_TEXT = new Action(EditorActions.KeepFileText, "ACTION_EDITOR_KEEP_TEXT"c);
/// ditto
const Action ACTION_EDITOR_SAVE_FILE = new Action(EditorActions.SaveFile, "ACTION_SAVE"c);
/// ditto
const Action ACTION_EDITOR_OVERWRITE_FILE = new Action(EditorActions.SaveFile, "ACTION_EDITOR_OVERWRITE_FILE"c);

const Action[] STD_EDITOR_ACTIONS = [ACTION_EDITOR_INSERT_NEW_LINE, ACTION_EDITOR_PREPEND_NEW_LINE,
        ACTION_EDITOR_APPEND_NEW_LINE, ACTION_EDITOR_DELETE_LINE, ACTION_EDITOR_TOGGLE_REPLACE_MODE,
        ACTION_EDITOR_SELECT_ALL, ACTION_EDITOR_TOGGLE_LINE_COMMENT, ACTION_EDITOR_TOGGLE_BLOCK_COMMENT,
        ACTION_EDITOR_TOGGLE_BOOKMARK, ACTION_EDITOR_GOTO_NEXT_BOOKMARK, ACTION_EDITOR_GOTO_PREVIOUS_BOOKMARK,
        ACTION_EDITOR_FIND, ACTION_EDITOR_REPLACE,
        ACTION_EDITOR_FIND_NEXT, ACTION_EDITOR_FIND_PREV,
        ACTION_EDITOR_COPY, ACTION_EDITOR_PASTE, ACTION_EDITOR_CUT,
        ACTION_EDITOR_UNDO, ACTION_EDITOR_REDO
];

/// base for all editor widgets
class EditWidgetBase : ScrollWidgetBase, EditableContentListener, MenuItemActionHandler {
    protected EditableContent _content;

    protected int _lineHeight;
    protected Point _scrollPos;
    protected bool _fixedFont;
    protected int _spaceWidth;
    protected int _leftPaneWidth; // left pane - can be used to show line numbers, collapse controls, bookmarks, breakpoints, custom icons

    protected int _minFontSize = -1; // disable zooming
    protected int _maxFontSize = -1; // disable zooming

    protected bool _wantTabs = true;
    protected bool _showLineNumbers = false; // show line numbers in left pane
    protected bool _showModificationMarks = false; // show modification marks in left pane
    protected bool _showIcons = false; // show icons in left pane
    protected bool _showFolding = false; // show folding controls in left pane
    protected int _lineNumbersWidth = 0;
    protected int _modificationMarksWidth = 0;
    protected int _iconsWidth = 0;
    protected int _foldingWidth = 0;

    protected bool _selectAllWhenFocusedWithTab = false;
    protected bool _deselectAllWhenUnfocused = false;

    protected bool _replaceMode;

    protected uint _selectionColorFocused = 0xB060A0FF;
    protected uint _selectionColorNormal = 0xD060A0FF;
    protected uint _searchHighlightColorCurrent = 0x808080FF;
    protected uint _searchHighlightColorOther = 0xC08080FF;
    protected uint _leftPaneBackgroundColor = 0xF4F4F4;
    protected uint _leftPaneBackgroundColor2 = 0xFFFFFF;
    protected uint _leftPaneBackgroundColor3 = 0xF8F8F8;
    protected uint _leftPaneLineNumberColor = 0x4060D0;
    protected uint _leftPaneLineNumberColorEdited = 0x8A5A00;
    protected uint _leftPaneLineNumberColorSaved = 0x1A6E1A;
    protected uint _leftPaneLineNumberColorCurrentLine = 0xFFFFFFFF;
    protected uint _leftPaneLineNumberBackgroundColorCurrentLine = 0xC08080FF;
    protected uint _leftPaneLineNumberBackgroundColor = 0xF4F4F4;
    protected uint _leftPaneMarkColorChanged = 0xFFD040;
    protected uint _leftPaneMarkColorSaved = 0x20C020;
    protected uint _colorIconBreakpoint = 0xFF0000;
    protected uint _colorIconBookmark = 0x0000FF;
    protected uint _colorIconError = 0x80FF0000;

    protected uint _caretColor = 0x000000;
    protected uint _caretColorReplace = 0x808080FF;
    protected uint _matchingBracketHightlightColor = 0x60FFE0B0;

    /// widths of the left pane parts in pixels at 100% scaling (BASE_DPI): updateLeftPaneWidth() scales them to
    /// SCREEN_DPI (#840); character cells in console builds
    protected uint _iconsPaneWidth = WIDGET_STYLE_CONSOLE ? 1 : 16;
    protected uint _foldingPaneWidth = WIDGET_STYLE_CONSOLE ? 1 : 12;
    protected uint _modificationMarksPaneWidth = WIDGET_STYLE_CONSOLE ? 1 : 4;
    /// when true, call measureVisibileText on next layout
    protected bool _contentChanged = true;

    protected bool _copyCurrentLineWhenNoSelection = true;
    /// when true allows copy / cut whole current line if there is no selection
    @property bool copyCurrentLineWhenNoSelection() { return _copyCurrentLineWhenNoSelection; }
    @property EditWidgetBase copyCurrentLineWhenNoSelection(bool flg) { _copyCurrentLineWhenNoSelection = flg; return this; }

    protected bool _showTabPositionMarks = false;
    /// when true shows mark on tab positions in beginning of line
    @property bool showTabPositionMarks() { return _showTabPositionMarks; }
    @property EditWidgetBase showTabPositionMarks(bool flg) {
        if (flg != _showTabPositionMarks) {
            _showTabPositionMarks = flg;
            invalidate();
        }
        return this;
    }

    /// Modified state change listener (e.g. content has been saved, or first time modified after save)
    Signal!ModifiedStateListener modifiedStateChange;

    /// Signal to emit when editor content is changed
    Signal!EditableContentChangeListener contentChange;

    /// Signal to emit when editor cursor position or Insert/Replace mode is changed.
    Signal!EditorStateListener editorStateChange;

    /// sets focus to this widget or suitable focusable child, returns previously focused widget
    override Widget setFocus(FocusReason reason = FocusReason.Unspecified) {
        Widget res = super.setFocus(reason);
        if (focused) {
            showSoftKeyboard();
            handleEditorStateChange();
        }
        return res;
    }

    /// updates editorStateChange with recent position
    protected void handleEditorStateChange() {
        if (!editorStateChange.assigned)
            return;
        EditorStateInfo info;
        if (visible) {
            info.replaceMode = _replaceMode;
            info.line = _caretPos.line + 1;
            info.col = _caretPos.pos + 1;
            if (_caretPos.line >= 0 && _caretPos.line < _content.length) {
                dstring line = _content.line(_caretPos.line);
                if (_caretPos.pos >= 0 && _caretPos.pos < line.length)
                    info.character = line[_caretPos.pos];
                else
                    info.character = '\n';
            }
        }
        editorStateChange(this, info);
    }

    /// override to support modification of client rect after change, e.g. apply offset
    override protected void handleClientRectLayout(ref Rect rc) {
        updateLeftPaneWidth();
        rc.left += _leftPaneWidth;
    }

    /// override for multiline editors
    protected int lineCount() {
        return 1;
    }

    /// Override for EditBox
    void wordWrapRefresh(){return;}

    /// To hold _scrollpos.x toggling between normal and word wrap mode
    int previousXScrollPos;

    protected bool _wordWrap;
    /// true if word wrap mode is set
    @property bool wordWrap() {
        return _wordWrap;
    }
    /// true if word wrap mode is set
    @property EditWidgetBase wordWrap(bool v) {
        _wordWrap = v;
        //Horizontal scrollbar should not be visible in word wrap mode
        if (v)
        {
            _hscrollbar.visibility(Visibility.Invisible);
            previousXScrollPos = _scrollPos.x;
            _scrollPos.x = 0;
            wordWrapRefresh();
        }
        else
        {
            _hscrollbar.visibility(Visibility.Visible);
            _scrollPos.x = previousXScrollPos;
        }
        invalidate();
        return this;
    }

    /// Characters at which content is split for word wrap mode
    immutable dchar[] splitChars = [' ', '-', '\t'];

    /// Divides up a string for word wrapping, sets info in _span
    dstring[] wrapLine(dstring str, int lineNumber) {
        FontRef font = font();
        dstring[] words = explode(str, splitChars);
        int curLineLength = 0;
        dchar[] buildingStr;
        dstring[] buildingStrArr;
        WrapPoint[] wrapPoints;
        int wrappedLineCount = 0;
        int curLineWidth = 0;
        int maxWidth = _clientRect.width;
        for (int i = 0; i < words.length; i++)
        {
            dstring word = words[i];
            if (curLineWidth + measureWrappedText(word) > maxWidth)
            {
                if (curLineWidth > 0)
                {
                    buildingStrArr ~= to!dstring(buildingStr);
                    wrappedLineCount++;
                    wrapPoints ~= WrapPoint(curLineLength, curLineWidth);
                    curLineLength = 0;
                    curLineWidth = 0;
                    buildingStr = [];
                }
                while (measureWrappedText(word) > maxWidth)
                {
                    //For when string still too long
                    int wrapPoint = findWrapPoint(word);
                    wrapPoints ~= WrapPoint(wrapPoint, measureWrappedText(word[0..wrapPoint]));
                    buildingStr ~= word[0 .. wrapPoint];
                    word = word[wrapPoint .. $];
                    buildingStrArr ~= to!dstring(buildingStr);
                    buildingStr = [];
                    wrappedLineCount++;
                }
            }
            buildingStr ~= word;
            curLineLength += to!int(word.length);
            curLineWidth += measureWrappedText(word);
        }
        wrapPoints ~= WrapPoint(curLineLength, curLineWidth);
        buildingStrArr ~= to!dstring(buildingStr);
        _span ~= LineSpan(lineNumber, wrappedLineCount + 1, wrapPoints, buildingStrArr);
        return buildingStrArr;
    }

    /// Divide (and conquer) text into words
    dstring[] explode(dstring str, const(dchar)[] splitChars)
    {
        dstring[] parts;
        int startIndex = 0;
        import std.string:indexOfAny;
        while (true)
        {
            int index = to!int(str.indexOfAny(splitChars, startIndex));

            if (index == -1)
            {
                parts ~= str[startIndex .. $];
                //Log.d("Explode output: ", parts);
                return parts;
            }

            dstring word = str[startIndex .. index];
            dchar nextChar = (str[index .. index + 1])[0];

            import std.ascii:isWhite;
            if (isWhite(nextChar))
            {
                parts ~= word;
                parts ~= to!dstring(nextChar);
            }
            else
            {
                parts ~= word ~ nextChar;
            }
            startIndex = index + 1;
        }
    }

    /// information about line span into several lines - in word wrap mode
    protected LineSpan[] _span;
    protected LineSpan[] _spanCache;

    /// Finds good visual wrapping point for string
    int findWrapPoint(dstring text)
    {
        int maxWidth = _clientRect.width;
        int wrapPoint = 0;
        while (true)
        {
            if (measureWrappedText(text[0 .. wrapPoint]) < maxWidth)
            {
                wrapPoint++;
            }
            else
            {
                return wrapPoint;
            }
        }
     }

    /// Calls measureText for word wrap
    int measureWrappedText(dstring text)
    {
        FontRef font = font();
        int[] measuredWidths;
        measuredWidths.length = text.length;
        //DO NOT REMOVE THIS
        font.measureText(text, measuredWidths);
        if (measuredWidths.length > 0)
            return measuredWidths[$-1];
        return 0;
    }

    /// Returns number of visible wraps up to a line (not including the first wrapLines themselves)
    int wrapsUpTo(int line)
    {
        int sum;
        lineSpanIterate(delegate(LineSpan curSpan)
        {
            if (curSpan.start < line)
                sum += curSpan.len - 1;
        });
        return sum;
    }

    /// Returns LineSpan for line based on actual line number
    LineSpan getSpan(int lineNumber)
    {
        LineSpan lineSpan = LineSpan(lineNumber, 0, [WrapPoint(0,0)], []);
        lineSpanIterate(delegate(LineSpan curSpan)
        {
            if (curSpan.start == lineNumber)
                lineSpan = curSpan;
        });
        return lineSpan;
    }

    /// Based on a TextPosition, finds which wrapLine it is on for its current line
    int findWrapLine(TextPosition textPos)
    {
        int curWrapLine = 0;
        int curPosition = textPos.pos;
        LineSpan curSpan = getSpan(textPos.line);
        while (true)
        {
            if (curWrapLine == curSpan.wrapPoints.length - 1)
                return curWrapLine;
            curPosition -= curSpan.wrapPoints[curWrapLine].wrapPos;
            if (curPosition < 0)
            {
                return curWrapLine;
            }
            curWrapLine++;
        }
    }

    /// Simple way of iterating through _span
    void lineSpanIterate(void delegate(LineSpan curSpan) iterator)
    {
        //TODO: Rename iterator to iteration?
        foreach (currentSpan; _span)
            iterator(currentSpan);
    }

    /// override to add custom items on left panel; add leftPaneGap() as the gap, drawLeftPane() and
    /// handleLeftPaneMouseClick() subtract it (#840)
    protected void updateLeftPaneWidth() {
        import std.conv : to;
        _iconsWidth = _showIcons ? scaledPixels(_iconsPaneWidth) : 0;
        _foldingWidth = _showFolding ? scaledPixels(_foldingPaneWidth) : 0;
        _modificationMarksWidth = _showModificationMarks && (BACKEND_GUI || !_showLineNumbers)
            ? scaledPixels(_modificationMarksPaneWidth) : 0;
        _lineNumbersWidth = 0;
        if (_showLineNumbers) {
            dchar[] s = to!(dchar[])(lineCount + 1);
            foreach(ref ch; s)
                ch = '9';
            FontRef fnt = font;
            Point sz = fnt.textSize(cast(immutable)s);
            _lineNumbersWidth = sz.x;
        }
        _leftPaneWidth = _lineNumbersWidth + _modificationMarksWidth + _foldingWidth + _iconsWidth;
        if (_leftPaneWidth)
            _leftPaneWidth += leftPaneGap();
    }

    /// gap between the left pane parts and the text: 3 pixels at 100% scaling, scaled to SCREEN_DPI (#840);
    /// one character cell in console builds
    protected int leftPaneGap() const {
        return WIDGET_STYLE_CONSOLE ? 1 : scaledPixels(3);
    }

    protected void drawLeftPaneFolding(DrawBuf buf, Rect rc, int line) {
        buf.fillRect(rc, _leftPaneBackgroundColor2);
    }

    protected void drawLeftPaneIcon(DrawBuf buf, Rect rc, LineIcon icon) {
        if (!icon)
            return;
        if (icon.type == LineIconType.error) {
            buf.fillRect(rc, _colorIconError);
        } else if (icon.type == LineIconType.bookmark) {
            int dh = rc.height / 4;
            rc.top += dh;
            rc.bottom -= dh;
            buf.fillRect(rc, _colorIconBookmark);
        } else if (icon.type == LineIconType.breakpoint) {
            if (rc.height > rc.width) {
                int delta = rc.height - rc.width;
                rc.top += delta / 2;
                rc.bottom -= (delta + 1) / 2;
            } else {
                int delta = rc.width - rc.height;
                rc.left += delta / 2;
                rc.right -= (delta + 1) / 2;
            }
            int dh = rc.height / 5;
            rc.top += dh;
            rc.bottom -= dh;
            int dw = rc.width / 5;
            rc.left += dw;
            rc.right -= dw;
            buf.fillRect(rc, _colorIconBreakpoint);
        }
    }

    protected void drawLeftPaneIcons(DrawBuf buf, Rect rc, int line) {
        buf.fillRect(rc, _leftPaneBackgroundColor3);
        drawLeftPaneIcon(buf, rc, content.lineIcons.findByLineAndType(line, LineIconType.error));
        drawLeftPaneIcon(buf, rc, content.lineIcons.findByLineAndType(line, LineIconType.bookmark));
        drawLeftPaneIcon(buf, rc, content.lineIcons.findByLineAndType(line, LineIconType.breakpoint));
    }

    protected void drawLeftPaneModificationMarks(DrawBuf buf, Rect rc, int line) {
        if (line >= 0 && line < content.length) {
            EditStateMark m = content.editMark(line);
            if (m == EditStateMark.changed) {
                // modified, not saved
                buf.fillRect(rc, _leftPaneMarkColorChanged);
            } else if (m == EditStateMark.saved) {
                // modified, saved
                buf.fillRect(rc, _leftPaneMarkColorSaved);
            }
        }
    }

    protected void drawLeftPaneLineNumbers(DrawBuf buf, Rect rc, int line) {
        import std.conv : to;
        uint bgcolor = _leftPaneLineNumberBackgroundColor;
        if (line == _caretPos.line && !isFullyTransparentColor(_leftPaneLineNumberBackgroundColorCurrentLine))
            bgcolor = _leftPaneLineNumberBackgroundColorCurrentLine;
        buf.fillRect(rc, bgcolor);
        if (line < 0)
            return;
        dstring s = to!dstring(line + 1);
        FontRef fnt = font;
        Point sz = fnt.textSize(s);
        int x = rc.right - sz.x;
        int y = rc.top + (rc.height - sz.y) / 2;
        uint color = _leftPaneLineNumberColor;
        if (line == _caretPos.line && !isFullyTransparentColor(_leftPaneLineNumberColorCurrentLine))
            color = _leftPaneLineNumberColorCurrentLine;
        if (line >= 0 && line < content.length) {
            EditStateMark m = content.editMark(line);
            if (m == EditStateMark.changed) {
                // modified, not saved
                color = _leftPaneLineNumberColorEdited;
            } else if (m == EditStateMark.saved) {
                // modified, saved
                color = _leftPaneLineNumberColorSaved;
            }
        }
        fnt.drawText(buf, x, y, s, color);
    }

    protected bool onLeftPaneMouseClick(MouseEvent event) {
        return false;
    }

    protected bool handleLeftPaneFoldingMouseClick(MouseEvent event, Rect rc, int line) {
        return true;
    }

    protected bool handleLeftPaneModificationMarksMouseClick(MouseEvent event, Rect rc, int line) {
        return true;
    }

    protected bool handleLeftPaneLineNumbersMouseClick(MouseEvent event, Rect rc, int line) {
        return true;
    }

    protected MenuItem getLeftPaneIconsPopupMenu(int line) {
        return null;
    }

    protected bool handleLeftPaneIconsMouseClick(MouseEvent event, Rect rc, int line) {
        if (event.button == MouseButton.Right) {
            MenuItem menu = getLeftPaneIconsPopupMenu(line);
            if (menu) {
                if (menu.openingSubmenu.assigned)
                    if (!menu.openingSubmenu(_popupMenu))
                        return true;
                menu.updateActionState(this);
                PopupMenu popupMenu = new PopupMenu(menu);
                popupMenu.menuItemAction = this;
                PopupWidget popup = window.showPopup(popupMenu, this, PopupAlign.Point | PopupAlign.Right, event.x, event.y);
                popup.flags = PopupFlags.CloseOnClickOutside;
            }
            return true;
        }
        return true;
    }

    protected bool handleLeftPaneMouseClick(MouseEvent event, Rect rc, int line) {
        rc.right -= leftPaneGap();
        if (_foldingWidth) {
            Rect rc2 = rc;
            rc.right = rc2.left = rc2.right - _foldingWidth;
            if (event.x >= rc2.left && event.x < rc2.right)
                return handleLeftPaneFoldingMouseClick(event, rc2, line);
        }
        if (_modificationMarksWidth) {
            Rect rc2 = rc;
            rc.right = rc2.left = rc2.right - _modificationMarksWidth;
            if (event.x >= rc2.left && event.x < rc2.right)
                return handleLeftPaneModificationMarksMouseClick(event, rc2, line);
        }
        if (_lineNumbersWidth) {
            Rect rc2 = rc;
            rc.right = rc2.left = rc2.right - _lineNumbersWidth;
            if (event.x >= rc2.left && event.x < rc2.right)
                return handleLeftPaneLineNumbersMouseClick(event, rc2, line);
        }
        if (_iconsWidth) {
            Rect rc2 = rc;
            rc.right = rc2.left = rc2.right - _iconsWidth;
            if (event.x >= rc2.left && event.x < rc2.right)
                return handleLeftPaneIconsMouseClick(event, rc2, line);
        }
        return true;
    }

    protected void drawLeftPane(DrawBuf buf, Rect rc, int line) {
        // override for custom drawn left pane
        buf.fillRect(rc, _leftPaneBackgroundColor);
        //buf.fillRect(Rect(rc.right - 2, rc.top, rc.right - 1, rc.bottom), _leftPaneBackgroundColor2);
        //buf.fillRect(Rect(rc.right - 1, rc.top, rc.right - 0, rc.bottom), _leftPaneBackgroundColor3);
        rc.right -= leftPaneGap();
        if (_foldingWidth) {
            Rect rc2 = rc;
            rc.right = rc2.left = rc2.right - _foldingWidth;
            drawLeftPaneFolding(buf, rc2, line);
        }
        if (_modificationMarksWidth) {
            Rect rc2 = rc;
            rc.right = rc2.left = rc2.right - _modificationMarksWidth;
            drawLeftPaneModificationMarks(buf, rc2, line);
        }
        if (_lineNumbersWidth) {
            Rect rc2 = rc;
            rc.right = rc2.left = rc2.right - _lineNumbersWidth;
            drawLeftPaneLineNumbers(buf, rc2, line);
        }
        if (_iconsWidth) {
            Rect rc2 = rc;
            rc.right = rc2.left = rc2.right - _iconsWidth;
            drawLeftPaneIcons(buf, rc2, line);
        }
    }

    this(string ID, ScrollBarMode hscrollbarMode = ScrollBarMode.Visible, ScrollBarMode vscrollbarMode = ScrollBarMode.Visible) {
        super(ID, hscrollbarMode, vscrollbarMode);
        focusable = true;
        acceleratorMap.add( [
            new Action(EditorActions.Up, KeyCode.UP, 0, ActionStateUpdateFlag.never),
            new Action(EditorActions.SelectUp, KeyCode.UP, KeyFlag.Shift, ActionStateUpdateFlag.never),
            new Action(EditorActions.SelectUp, KeyCode.UP, KeyFlag.Control | KeyFlag.Shift, ActionStateUpdateFlag.never),
            new Action(EditorActions.Down, KeyCode.DOWN, 0, ActionStateUpdateFlag.never),
            new Action(EditorActions.SelectDown, KeyCode.DOWN, KeyFlag.Shift, ActionStateUpdateFlag.never),
            new Action(EditorActions.SelectDown, KeyCode.DOWN, KeyFlag.Control | KeyFlag.Shift, ActionStateUpdateFlag.never),
            new Action(EditorActions.Left, KeyCode.LEFT, 0, ActionStateUpdateFlag.never),
            new Action(EditorActions.SelectLeft, KeyCode.LEFT, KeyFlag.Shift, ActionStateUpdateFlag.never),
            new Action(EditorActions.Right, KeyCode.RIGHT, 0, ActionStateUpdateFlag.never),
            new Action(EditorActions.SelectRight, KeyCode.RIGHT, KeyFlag.Shift, ActionStateUpdateFlag.never),
            new Action(EditorActions.WordLeft, KeyCode.LEFT, KeyFlag.Control, ActionStateUpdateFlag.never),
            new Action(EditorActions.SelectWordLeft, KeyCode.LEFT, KeyFlag.Control | KeyFlag.Shift, ActionStateUpdateFlag.never),
            new Action(EditorActions.WordRight, KeyCode.RIGHT, KeyFlag.Control, ActionStateUpdateFlag.never),
            new Action(EditorActions.SelectWordRight, KeyCode.RIGHT, KeyFlag.Control | KeyFlag.Shift, ActionStateUpdateFlag.never),
            new Action(EditorActions.PageUp, KeyCode.PAGEUP, 0, ActionStateUpdateFlag.never),
            new Action(EditorActions.SelectPageUp, KeyCode.PAGEUP, KeyFlag.Shift, ActionStateUpdateFlag.never),
            new Action(EditorActions.PageDown, KeyCode.PAGEDOWN, 0, ActionStateUpdateFlag.never),
            new Action(EditorActions.SelectPageDown, KeyCode.PAGEDOWN, KeyFlag.Shift, ActionStateUpdateFlag.never),
            new Action(EditorActions.PageBegin, KeyCode.PAGEUP, KeyFlag.Control, ActionStateUpdateFlag.never),
            new Action(EditorActions.SelectPageBegin, KeyCode.PAGEUP, KeyFlag.Control | KeyFlag.Shift, ActionStateUpdateFlag.never),
            new Action(EditorActions.PageEnd, KeyCode.PAGEDOWN, KeyFlag.Control, ActionStateUpdateFlag.never),
            new Action(EditorActions.SelectPageEnd, KeyCode.PAGEDOWN, KeyFlag.Control | KeyFlag.Shift, ActionStateUpdateFlag.never),
            new Action(EditorActions.LineBegin, KeyCode.HOME, 0, ActionStateUpdateFlag.never),
            new Action(EditorActions.SelectLineBegin, KeyCode.HOME, KeyFlag.Shift, ActionStateUpdateFlag.never),
            new Action(EditorActions.LineEnd, KeyCode.END, 0, ActionStateUpdateFlag.never),
            new Action(EditorActions.SelectLineEnd, KeyCode.END, KeyFlag.Shift, ActionStateUpdateFlag.never),
            new Action(EditorActions.DocumentBegin, KeyCode.HOME, KeyFlag.Control, ActionStateUpdateFlag.never),
            new Action(EditorActions.SelectDocumentBegin, KeyCode.HOME, KeyFlag.Control | KeyFlag.Shift, ActionStateUpdateFlag.never),
            new Action(EditorActions.DocumentEnd, KeyCode.END, KeyFlag.Control, ActionStateUpdateFlag.never),
            new Action(EditorActions.SelectDocumentEnd, KeyCode.END, KeyFlag.Control | KeyFlag.Shift, ActionStateUpdateFlag.never),

            new Action(EditorActions.ScrollLineUp, KeyCode.UP, KeyFlag.Control, ActionStateUpdateFlag.never),
            new Action(EditorActions.ScrollLineDown, KeyCode.DOWN, KeyFlag.Control, ActionStateUpdateFlag.never),

            // Backspace/Del
            new Action(EditorActions.DelPrevChar, KeyCode.BACK, 0, ActionStateUpdateFlag.never),
            new Action(EditorActions.DelNextChar, KeyCode.DEL, 0, ActionStateUpdateFlag.never),
            new Action(EditorActions.DelPrevWord, KeyCode.BACK, KeyFlag.Control, ActionStateUpdateFlag.never),
            new Action(EditorActions.DelNextWord, KeyCode.DEL, KeyFlag.Control, ActionStateUpdateFlag.never),

            // Copy/Paste
            new Action(EditorActions.Copy, KeyCode.KEY_C, KeyFlag.Control),
            new Action(EditorActions.Copy, KeyCode.KEY_C, KeyFlag.Control | KeyFlag.Shift),
            new Action(EditorActions.Copy, KeyCode.INS, KeyFlag.Control),
            new Action(EditorActions.Cut, KeyCode.KEY_X, KeyFlag.Control),
            new Action(EditorActions.Cut, KeyCode.KEY_X, KeyFlag.Control | KeyFlag.Shift),
            new Action(EditorActions.Cut, KeyCode.DEL, KeyFlag.Shift),
            new Action(EditorActions.Paste, KeyCode.KEY_V, KeyFlag.Control),
            new Action(EditorActions.Paste, KeyCode.KEY_V, KeyFlag.Control | KeyFlag.Shift),
            new Action(EditorActions.Paste, KeyCode.INS, KeyFlag.Shift),

            // Undo/Redo
            new Action(EditorActions.Undo, KeyCode.KEY_Z, KeyFlag.Control),
            new Action(EditorActions.Redo, KeyCode.KEY_Y, KeyFlag.Control),
            new Action(EditorActions.Redo, KeyCode.KEY_Z, KeyFlag.Control | KeyFlag.Shift),

            new Action(EditorActions.Tab, KeyCode.TAB, 0, ActionStateUpdateFlag.never),
            new Action(EditorActions.BackTab, KeyCode.TAB, KeyFlag.Shift, ActionStateUpdateFlag.never),

            new Action(EditorActions.Find, KeyCode.KEY_F, KeyFlag.Control),
            new Action(EditorActions.Replace, KeyCode.KEY_H, KeyFlag.Control),
        ]);
        acceleratorMap.add(STD_EDITOR_ACTIONS);
        acceleratorMap.add([ACTION_EDITOR_FIND_NEXT, ACTION_EDITOR_FIND_PREV]);
    }

    ///
    override bool onMenuItemAction(const Action action) {
        return dispatchAction(action);
    }

    /// returns true if widget can show popup (e.g. by mouse right click at point x,y)
    override bool canShowPopupMenu(int x, int y) {
        if (_popupMenu is null)
            return false;
        if (_popupMenu.openingSubmenu.assigned)
            if (!_popupMenu.openingSubmenu(_popupMenu))
                return false;
        return true;
    }

    /// returns true if widget is focusable and visible and enabled
    override @property bool canFocus() {
        // allow to focus even if not enabled
        return focusable && visible;
    }

    /// override to change popup menu items state
    override bool isActionEnabled(const Action action) {
        switch (action.id) with(EditorActions)
        {
            case Tab:
            case BackTab:
            case Indent:
            case Unindent:
                return enabled;
            case Copy:
                return _copyCurrentLineWhenNoSelection || !_selectionRange.empty;
            case Cut:
                return enabled && (_copyCurrentLineWhenNoSelection || !_selectionRange.empty);
            case Paste:
                return enabled && Platform.instance.hasClipboardText();
            case Undo:
                return enabled && _content.hasUndo;
            case Redo:
                return enabled && _content.hasRedo;
            case ToggleBookmark:
                return _content.multiline;
            case GoToNextBookmark:
                return _content.multiline && _content.lineIcons.hasBookmarks;
            case GoToPreviousBookmark:
                return _content.multiline && _content.lineIcons.hasBookmarks;
            case Replace:
                return _content.multiline && !readOnly;
            case Find:
            case FindNext:
            case FindPrev:
                return _content.multiline;
            default:
                return super.isActionEnabled(action);
        }
    }

    /// shows popup at (x,y)
    override void showPopupMenu(int x, int y) {
        /// if preparation signal handler assigned, call it; don't show popup if false is returned from handler
        if (_popupMenu.openingSubmenu.assigned)
            if (!_popupMenu.openingSubmenu(_popupMenu))
                return;
        _popupMenu.updateActionState(this);
        PopupMenu popupMenu = new PopupMenu(_popupMenu);
        popupMenu.menuItemAction = this;
        PopupWidget popup = window.showPopup(popupMenu, this, PopupAlign.Point | PopupAlign.Right, x, y);
        popup.flags = PopupFlags.CloseOnClickOutside;
    }

    void onPopupMenuItem(MenuItem item) {
        // TODO
    }

    /// returns mouse cursor type for widget
    override uint getCursorType(int x, int y) {
        return x < _pos.left + _leftPaneWidth ? CursorType.Arrow : CursorType.IBeam;
    }

    /// set bool property value, for ML loaders
    mixin(generatePropertySettersMethodOverride("setBoolProperty", "bool",
          "wantTabs", "showIcons", "showFolding", "showModificationMarks", "showLineNumbers", "readOnly", "replaceMode", "useSpacesForTabs", "copyCurrentLineWhenNoSelection", "showTabPositionMarks"));

    /// set int property value, for ML loaders
    mixin(generatePropertySettersMethodOverride("setIntProperty", "int",
          "tabSize"));

    /// when true, Tab / Shift+Tab presses are processed internally in widget (e.g. insert tab character) instead of focus change navigation.
    @property bool wantTabs() {
        return _wantTabs;
    }

    /// ditto
    @property EditWidgetBase wantTabs(bool wantTabs) {
        _wantTabs = wantTabs;
        return this;
    }

    /// when true, show icons like bookmarks or breakpoints at the left
    @property bool showIcons() {
        return _showIcons;
    }

    /// when true, show icons like bookmarks or breakpoints at the left
    @property EditWidgetBase showIcons(bool flg) {
        if (_showIcons != flg) {
            _showIcons = flg;
            updateLeftPaneWidth();
            requestLayout();
        }
        return this;
    }

    /// when true, show folding controls at the left
    @property bool showFolding() {
        return _showFolding;
    }

    /// when true, show folding controls at the left
    @property EditWidgetBase showFolding(bool flg) {
        if (_showFolding != flg) {
            _showFolding = flg;
            updateLeftPaneWidth();
            requestLayout();
        }
        return this;
    }

    /// when true, show modification marks for lines (whether line is unchanged/modified/modified_saved)
    @property bool showModificationMarks() {
        return _showModificationMarks;
    }

    /// when true, show modification marks for lines (whether line is unchanged/modified/modified_saved)
    @property EditWidgetBase showModificationMarks(bool flg) {
        if (_showModificationMarks != flg) {
            _showModificationMarks = flg;
            updateLeftPaneWidth();
            requestLayout();
        }
        return this;
    }

    /// when true, line numbers are shown
    @property bool showLineNumbers() {
        return _showLineNumbers;
    }

    /// when true, line numbers are shown
    @property EditWidgetBase showLineNumbers(bool flg) {
        if (_showLineNumbers != flg) {
            _showLineNumbers = flg;
            updateLeftPaneWidth();
            requestLayout();
        }
        return this;
    }

    /// readonly flag (when true, user cannot change content of editor)
    @property bool readOnly() {
        return !enabled || _content.readOnly;
    }

    /// sets readonly flag
    @property EditWidgetBase readOnly(bool readOnly) {
        enabled = !readOnly;
        invalidate();
        return this;
    }

    /// replace mode flag (when true, entered character replaces character under cursor)
    @property bool replaceMode() {
        return _replaceMode;
    }

    /// sets replace mode flag
    @property EditWidgetBase replaceMode(bool replaceMode) {
        _replaceMode = replaceMode;
        handleEditorStateChange();
        invalidate();
        return this;
    }

    /// when true, spaces will be inserted instead of tabs
    @property bool useSpacesForTabs() {
        return _content.useSpacesForTabs;
    }

    /// set new Tab key behavior flag: when true, spaces will be inserted instead of tabs
    @property EditWidgetBase useSpacesForTabs(bool useSpacesForTabs) {
        _content.useSpacesForTabs = useSpacesForTabs;
        return this;
    }

    /// returns tab size (in number of spaces)
    @property int tabSize() {
        return _content.tabSize;
    }

    /// sets tab size (in number of spaces)
    @property EditWidgetBase tabSize(int newTabSize) {
        if (newTabSize < 1)
            newTabSize = 1;
        else if (newTabSize > 16)
            newTabSize = 16;
        if (newTabSize != tabSize) {
            _content.tabSize = newTabSize;
            requestLayout();
        }
        return this;
    }

    /// true if smart indents are supported
    @property bool supportsSmartIndents() { return _content.supportsSmartIndents; }
    /// true if smart indents are enabled
    @property bool smartIndents() { return _content.smartIndents; }
    /// set smart indents enabled flag
    @property EditWidgetBase smartIndents(bool enabled) { _content.smartIndents = enabled; return this; }

    /// true if smart indents are enabled
    @property bool smartIndentsAfterPaste() { return _content.smartIndentsAfterPaste; }
    /// set smart indents enabled flag
    @property EditWidgetBase smartIndentsAfterPaste(bool enabled) { _content.smartIndentsAfterPaste = enabled; return this; }


    /// editor content object
    @property EditableContent content() {
        return _content;
    }

    /// when _ownContent is false, _content should not be destroyed in editor destructor
    protected bool _ownContent = true;
    /// set content object
    @property EditWidgetBase content(EditableContent content) {
        if (_content is content)
            return this; // not changed
        if (_content !is null) {
            // disconnect old content
            _content.contentChanged.disconnect(this);
            if (_ownContent) {
                destroy(_content);
            }
        }
        _content = content;
        _ownContent = false;
        _content.contentChanged.connect(this);
        if (_content.readOnly)
            enabled = false;
        return this;
    }

    /// free resources
    ~this() {
        if (inGCFinalizer()) return; // finalized by the GC: a leak, touch nothing (#975)
        if (_ownContent) {
            destroy(_content);
            _content = null;
        }
    }

    protected void updateMaxLineWidth() {
    }

    protected void processSmartIndent(EditOperation operation) {
        if (!supportsSmartIndents)
            return;
        if (!smartIndents && !smartIndentsAfterPaste)
            return;
        _content.syntaxSupport.applySmartIndent(operation, this);
    }

    override void onContentChange(EditableContent content, EditOperation operation, ref TextRange rangeBefore, ref TextRange rangeAfter, Object source) {
        //Log.d("onContentChange rangeBefore=", rangeBefore, " rangeAfter=", rangeAfter, " text=", operation.content);
        _contentChanged = true;
        if (operation.action == EditAction.Reload) {
            // the file was read again (#1279), or that is undone or redone, from any source: the caret stays where
            // it was, clamped to the new text; a selection may not mean the same text any more
            _selectionRange = TextRange(_caretPos, _caretPos);
            correctCaretPos();
            updateMaxLineWidth();
            measureVisibleText();
            requestLayout();
            requestActionsUpdate();
        } else if (source is this) {
            if (operation.action == EditAction.ReplaceContent) {
                // fully replaced, e.g., loaded from file or text property is assigned
                _caretPos = rangeAfter.end;
                _selectionRange.start = _caretPos;
                _selectionRange.end = _caretPos;
                updateMaxLineWidth();
                measureVisibleText();
                ensureCaretVisible();
                correctCaretPos();
                requestLayout();
                requestActionsUpdate();
            } else if (operation.action == EditAction.SaveContent) {
                // saved
            } else {
                // modified
                _caretPos = rangeAfter.end;
                _selectionRange.start = _caretPos;
                _selectionRange.end = _caretPos;
                updateMaxLineWidth();
                measureVisibleText();
                ensureCaretVisible();
                requestActionsUpdate();
                processSmartIndent(operation);
            }
        } else {
            updateMaxLineWidth();
            measureVisibleText();
            correctCaretPos();
            requestLayout();
            requestActionsUpdate();
        }
        invalidate();
        if (modifiedStateChange.assigned) {
            if (_lastReportedModifiedState != content.modified) {
                _lastReportedModifiedState = content.modified;
                modifiedStateChange(this, content.modified);
                requestActionsUpdate();
            }
        }
        if (contentChange.assigned) {
            contentChange(_content);
        }
        handleEditorStateChange();
        return;
    }
    protected bool _lastReportedModifiedState;

    /// get widget text
    override @property dstring text() const { return _content.text; }

    /// set text
    override @property Widget text(dstring s) {
        _content.text = s;
        requestLayout();
        return this;
    }

    /// set text
    override @property Widget text(UIString s) {
        _content.text = s;
        requestLayout();
        return this;
    }

    protected TextPosition _caretPos;
    protected TextRange _selectionRange;

    abstract protected Rect textPosToClient(TextPosition p);

    abstract protected TextPosition clientToTextPos(Point pt);

    abstract protected void ensureCaretVisible(bool center = false);

    abstract protected Point measureVisibleText();

    protected int _caretBlingingInterval = 800;
    protected ulong _caretTimerId;
    protected bool _caretBlinkingPhase;
    protected long _lastBlinkStartTs;
    protected bool _caretBlinks = true;

    /// when true, enables caret blinking, otherwise it's always visible
    @property void showCaretBlinking(bool blinks) {
        _caretBlinks = blinks;
    }
    /// when true, enables caret blinking, otherwise it's always visible
    @property bool showCaretBlinking() {
        return _caretBlinks;
    }

    protected void startCaretBlinking() {
        if (window) {
            static if (WIDGET_STYLE_CONSOLE) {
                window.caretRect = caretRect;
                window.caretReplace = _replaceMode;
            } else {
                long ts = currentTimeMillis;
                if (_caretTimerId) {
                    if (_lastBlinkStartTs + _caretBlingingInterval / 4 > ts)
                        return; // don't update timer too frequently
                    cancelTimer(_caretTimerId);
                }
                _caretTimerId = setTimer(_caretBlingingInterval / 2);
                _lastBlinkStartTs = ts;
                _caretBlinkingPhase = false;
                invalidate();
            }
        }
    }

    protected void stopCaretBlinking() {
        if (window) {
            static if (WIDGET_STYLE_CONSOLE) {
                window.caretRect = Rect.init;
            } else {
                if (_caretTimerId) {
                    cancelTimer(_caretTimerId);
                    _caretTimerId = 0;
                }
            }
        }
    }

    /// handle timer; return true to repeat timer event after next interval, false cancel timer
    override bool onTimer(ulong id) {
        if (id == _caretTimerId) {
            _caretBlinkingPhase = !_caretBlinkingPhase;
            if (!_caretBlinkingPhase)
                _lastBlinkStartTs = currentTimeMillis;
            invalidate();
            //window.update(true);
            bool res = focused;
            if (!res)
                _caretTimerId = 0;
            return res;
        }
        if (id == _hoverTimer) {
            cancelHoverTimer();
            onHoverTimeout(_hoverMousePosition, _hoverTextPosition);
            return false;
        }
        return super.onTimer(id);
    }

    /// override to handle focus changes
    override protected void handleFocusChange(bool focused, bool receivedFocusFromKeyboard = false) {
        if (focused)
            startCaretBlinking();
        else {
            stopCaretBlinking();
            cancelHoverTimer();

            if(_deselectAllWhenUnfocused) {
                _selectionRange.start = _caretPos;
                _selectionRange.end = _caretPos;
            }
        }
        if(focused && _selectAllWhenFocusedWithTab && receivedFocusFromKeyboard)
            handleAction(ACTION_EDITOR_SELECT_ALL);
        super.handleFocusChange(focused);
    }

    //In word wrap mode, set by caretRect so ensureCaretVisible will know when to scroll
    protected int caretHeightOffset;

    /// returns cursor rectangle
    protected Rect caretRect() {
        Rect caretRc = textPosToClient(_caretPos);
        if (_replaceMode) {
            dstring s = _content[_caretPos.line];
            if (_caretPos.pos < s.length) {
                TextPosition nextPos = _caretPos;
                nextPos.pos++;
                Rect nextRect = textPosToClient(nextPos);
                caretRc.right = nextRect.right;
            } else {
                caretRc.right += _spaceWidth;
            }
        }
        if (_wordWrap)
        {
            _scrollPos.x = 0;
            int wrapLine = findWrapLine(_caretPos);
            int xOffset;
            if (wrapLine > 0)
            {
                LineSpan curSpan = getSpan(_caretPos.line);
                xOffset = curSpan.accumulation(wrapLine, LineSpan.WrapPointInfo.Width);
            }
            auto yOffset = -1 * _lineHeight * (wrapsUpTo(_caretPos.line) + wrapLine);
            caretHeightOffset = yOffset;
            caretRc.offset(_clientRect.left - xOffset, _clientRect.top - yOffset);
        }
        else
            caretRc.offset(_clientRect.left, _clientRect.top);
        return caretRc;
    }

    /// handle theme change: e.g. reload some themed resources
    override void onThemeChanged() {
        super.onThemeChanged();
        _caretColor = style.customColor("edit_caret");
        _caretColorReplace = style.customColor("edit_caret_replace");
        _selectionColorFocused = style.customColor("editor_selection_focused");
        _selectionColorNormal = style.customColor("editor_selection_normal");
        _searchHighlightColorCurrent = style.customColor("editor_search_highlight_current");
        _searchHighlightColorOther = style.customColor("editor_search_highlight_other");
        _leftPaneBackgroundColor = style.customColor("editor_left_pane_background");
        _leftPaneBackgroundColor2 = style.customColor("editor_left_pane_background2");
        _leftPaneBackgroundColor3 = style.customColor("editor_left_pane_background3");
        _leftPaneLineNumberColor = style.customColor("editor_left_pane_line_number_text");
        _leftPaneLineNumberColorEdited = style.customColor("editor_left_pane_line_number_text_edited", 0x8A5A00);
        _leftPaneLineNumberColorSaved = style.customColor("editor_left_pane_line_number_text_saved", 0x1A6E1A);
        _leftPaneLineNumberColorCurrentLine = style.customColor("editor_left_pane_line_number_text_current_line", 0xFFFFFFFF);
        _leftPaneLineNumberBackgroundColorCurrentLine = style.customColor("editor_left_pane_line_number_background_current_line", 0xC08080FF);
        _leftPaneLineNumberBackgroundColor = style.customColor("editor_left_pane_line_number_background");
        _leftPaneMarkColorChanged = style.customColor("editor_left_pane_mark_changed", 0xFFD040);
        _leftPaneMarkColorSaved = style.customColor("editor_left_pane_mark_saved", 0x20C020);
        _colorIconBreakpoint = style.customColor("editor_left_pane_line_icon_color_breakpoint", 0xFF0000);
        _colorIconBookmark = style.customColor("editor_left_pane_line_icon_color_bookmark", 0x0000FF);
        _colorIconError = style.customColor("editor_left_pane_line_icon_color_error", 0x80FF0000);
        _matchingBracketHightlightColor = style.customColor("editor_matching_bracket_highlight");
    }

    /// draws caret
    protected void drawCaret(DrawBuf buf) {
        if (focused) {
            if (_caretBlinkingPhase && _caretBlinks) {
                return;
            }
            // draw caret
            Rect caretRc = caretRect();
            if (caretRc.intersects(_clientRect)) {
                //caretRc.left++;
                if (_replaceMode && BACKEND_GUI)
                    buf.fillRect(caretRc, _caretColorReplace);
                //buf.drawLine(Point(caretRc.left, caretRc.bottom), Point(caretRc.left, caretRc.top), _caretColor);
                buf.fillRect(Rect(caretRc.left, caretRc.top, caretRc.left + 1, caretRc.bottom), _caretColor);
            }
        }
    }

    protected void updateFontProps() {
        FontRef font = font();
        _fixedFont = font.isFixed;
        _spaceWidth = font.spaceWidth;
        _lineHeight = font.height;
    }

    /// when cursor position or selection is out of content bounds, fix it to nearest valid position
    protected void correctCaretPos() {
        _content.correctPosition(_caretPos);
        _content.correctPosition(_selectionRange.start);
        _content.correctPosition(_selectionRange.end);
        if (_selectionRange.empty)
            _selectionRange = TextRange(_caretPos, _caretPos);
        handleEditorStateChange();
    }


    private int[] _lineWidthBuf;
    protected int calcLineWidth(dstring s) {
        int w = 0;
        if (_fixedFont) {
            int tabw = tabSize * _spaceWidth;
            FontRef fnt = font;
            // version optimized for fixed font
            for (int i = 0; i < s.length; i++) {
                if (s[i] == '\t') {
                    w += _spaceWidth;
                    w = (w + tabw - 1) / tabw * tabw;
                } else {
                    w += _spaceWidth * fnt.charCells(s[i]); // East Asian wide: 2 cells (#888)
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
                if (oldCaretPos < _caretPos) {
                    // start selection forward
                    _selectionRange.start = oldCaretPos;
                    _selectionRange.end = _caretPos;
                } else {
                    // start selection backward
                    _selectionRange.start = _caretPos;
                    _selectionRange.end = oldCaretPos;
                }
            }
        } else {
            _selectionRange.start = _caretPos;
            _selectionRange.end = _caretPos;
        }
        invalidate();
        requestActionsUpdate();
        handleEditorStateChange();
    }

    protected dstring _textToHighlight;
    protected uint _textToHighlightOptions;

    /// text pattern to highlight - e.g. for search
    @property dstring textToHighlight() {
        return _textToHighlight;
    }
    /// set text to highlight -- e.g. for search
    /// (a match is marked as the current one only on the caret line, or when it is selected)
    void setTextToHighlight(dstring pattern, uint textToHighlightOptions) {
        setTextToHighlight(pattern, textToHighlightOptions, WHOLE_TEXT_RANGE, false);
        _textToHighlightFindNext = false;
    }
    /// sets the text pattern to highlight for a search with Find next, as in the Find panel: the current match, the
    /// selected match (the one Replace takes), else the one Find next takes, is marked wherever it is (#1177). Only
    /// matches inside scope_ are highlighted, a range of the current text (other than WHOLE_TEXT_RANGE, nothing is
    /// highlighted after the text changes, until it is set again) (#1166); back: the current match is the one Find
    /// prev takes, else the one Find next takes (#1165)
    void setTextToHighlight(dstring pattern, uint textToHighlightOptions, TextRange scope_, bool back) {
        _textToHighlightFindNext = true;
        _textToHighlight = pattern;
        _textToHighlightOptions = textToHighlightOptions;
        _textToHighlightScope = scope_;
        _textToHighlightScoped = scope_ != WHOLE_TEXT_RANGE;
        _textToHighlightRevision = _content.revision;
        _textToHighlightBack = back;
        invalidate();
    }
    protected TextRange _textToHighlightScope = WHOLE_TEXT_RANGE;
    protected bool _textToHighlightScoped;
    protected ulong _textToHighlightRevision;
    protected bool _textToHighlightBack;
    protected bool _textToHighlightFindNext;

    /// Used instead of using clientToTextPos for mouse input when in word wrap mode
    protected TextPosition wordWrapMouseOffset(int x, int y) {
        if (y < 0 || _span.length == 0)
            return clientToTextPos(Point(x,y));

        int selectedVisibleLine = y / _lineHeight;
        int wrapLine = 0;
        int curLine = 0;
        bool foundWrap = false;
        int accumulativeWidths = 0;
        int curWrapOfSpan = 0;

        lineSpanIterate(delegate(LineSpan curSpan){
            while (!foundWrap)
            {
                if (wrapLine == selectedVisibleLine)
                {
                    foundWrap = true;
                    break;
                }
                accumulativeWidths += curSpan.wrapPoints[curWrapOfSpan].wrapWidth;
                wrapLine++;
                curWrapOfSpan++;
                if (curWrapOfSpan >= curSpan.len)
                {
                    break;
                }
            }
            if (!foundWrap)
            {
                accumulativeWidths = 0;
                curLine++;
            }
            curWrapOfSpan = 0;
        });

        int fakeLineHeight = curLine * _lineHeight;
        return clientToTextPos(Point(x + accumulativeWidths, fakeLineHeight));
    }

    protected void selectWordByMouse(int x, int y) {
        TextPosition oldCaretPos = _caretPos;
        TextPosition newPos = _wordWrap ? wordWrapMouseOffset(x,y) : clientToTextPos(Point(x,y));
        TextRange r = content.wordBounds(newPos);
        if (r.start < r.end) {
            _selectionRange = r;
            _caretPos = r.end;
            invalidate();
            requestActionsUpdate();
        } else {
            _caretPos = newPos;
            updateSelectionAfterCursorMovement(oldCaretPos, false);
        }
        handleEditorStateChange();
    }

    protected void selectLineByMouse(int x, int y, bool onSameLineOnly = true) {
        TextPosition oldCaretPos = _caretPos;
        TextPosition newPos = _wordWrap ? wordWrapMouseOffset(x,y) : clientToTextPos(Point(x,y));
        if (onSameLineOnly && newPos.line != oldCaretPos.line)
            return; // different lines
        TextRange r = content.lineRange(newPos.line);
        if (r.start < r.end) {
            _selectionRange = r;
            _caretPos = r.end;
            invalidate();
            requestActionsUpdate();
        } else {
            _caretPos = newPos;
            updateSelectionAfterCursorMovement(oldCaretPos, false);
        }
        handleEditorStateChange();
    }

    /// what dragging with the left button selects: set by the click count of the last button press (#958)
    protected enum MouseSelectionMode { characters, words, lines }
    protected MouseSelectionMode _mouseSelectionMode;
    /// the word or line selected by the double or triple click: dragging keeps it selected
    protected TextRange _mouseSelectionAnchor;

    /// drag after a double or triple click: extend the selection by whole words or lines, keeping the anchor
    protected void extendSelectionByMouse(int x, int y) {
        TextPosition pos = _wordWrap ? wordWrapMouseOffset(x,y) : clientToTextPos(Point(x,y));
        TextRange r = _mouseSelectionMode == MouseSelectionMode.lines ? content.lineRange(pos.line) : content.wordBounds(pos);
        if (!(r.start < r.end))
            r = TextRange(pos, pos); // between words: up to the mouse position
        TextRange sel = _mouseSelectionAnchor;
        if (r.start < sel.start) {
            sel.start = r.start;
            _caretPos = sel.start;
        } else {
            if (sel.end < r.end)
                sel.end = r.end;
            _caretPos = sel.end;
        }
        if (_selectionRange != sel) {
            _selectionRange = sel;
            invalidate();
            requestActionsUpdate();
        }
        handleEditorStateChange();
    }

    protected void updateCaretPositionByMouse(int x, int y, bool selecting) {
        TextPosition oldCaretPos = _caretPos;
        TextPosition newPos = _wordWrap ? wordWrapMouseOffset(x,y) : clientToTextPos(Point(x,y));
        if (newPos != _caretPos) {
            _caretPos = newPos;
            updateSelectionAfterCursorMovement(oldCaretPos, selecting);
            invalidate();
        }
        handleEditorStateChange();
    }

    /// generate string of spaces, to reach next tab position
    protected dstring spacesForTab(int currentPos) {
        int newPos = (currentPos + tabSize + 1) / tabSize * tabSize;
        return "                "d[0..(newPos - currentPos)];
    }

    /// returns true if one or more lines selected fully
    protected bool multipleLinesSelected() {
        return _selectionRange.end.line > _selectionRange.start.line;
    }

    protected bool _camelCasePartsAsWords = true;

    void replaceSelectionText(dstring newText) {
        EditOperation op = new EditOperation(EditAction.Replace, _selectionRange, [newText]);
        _content.performOperation(op, this);
        ensureCaretVisible();
    }

    protected bool removeSelectionTextIfSelected() {
        if (_selectionRange.empty)
            return false;
        // clear selection
        EditOperation op = new EditOperation(EditAction.Replace, _selectionRange, [""d]);
        _content.performOperation(op, this);
        ensureCaretVisible();
        return true;
    }

    /// returns current selection text (joined with LF when span over multiple lines)
    public dstring getSelectedText() {
        return getRangeText(_selectionRange);
    }

    /// returns text for specified range (joined with LF when span over multiple lines)
    public dstring getRangeText(TextRange range) {
        dstring selectionText = concatDStrings(_content.rangeText(range));
        return selectionText;
    }

    /// returns range for line with cursor
    @property public TextRange currentLineRange() {
        return _content.lineRange(_caretPos.line);
    }

    /// clears selection (don't change text, just unselect)
    void clearSelection() {
        _selectionRange = TextRange(_caretPos, _caretPos);
        invalidate();
    }

    protected bool removeRangeText(TextRange range) {
        if (range.empty)
            return false;
        _selectionRange = range;
        _caretPos = _selectionRange.start;
        EditOperation op = new EditOperation(EditAction.Replace, range, [""d]);
        _content.performOperation(op, this);
        //_selectionRange.start = _caretPos;
        //_selectionRange.end = _caretPos;
        ensureCaretVisible();
        handleEditorStateChange();
        return true;
    }

    /// returns current selection range
    @property TextRange selectionRange() {
        return _selectionRange;
    }
    /// sets current selection range
    @property void selectionRange(TextRange range) {
        if (range.empty)
            return;
        _selectionRange = range;
        _caretPos = range.end;
        handleEditorStateChange();
    }

    /// override to handle specific actions state (e.g. change enabled state for supported actions)
    override bool handleActionStateRequest(const Action a) {
        switch (a.id) with(EditorActions)
        {
            case ToggleBlockComment:
                if (!_content.syntaxSupport || !_content.syntaxSupport.supportsToggleBlockComment)
                    a.state = ACTION_STATE_INVISIBLE;
                else if (enabled && _content.syntaxSupport.canToggleBlockComment(_selectionRange))
                    a.state = ACTION_STATE_ENABLED;
                else
                    a.state = ACTION_STATE_DISABLE;
                return true;
            case ToggleLineComment:
                if (!_content.syntaxSupport || !_content.syntaxSupport.supportsToggleLineComment)
                    a.state = ACTION_STATE_INVISIBLE;
                else if (enabled && _content.syntaxSupport.canToggleLineComment(_selectionRange))
                    a.state = ACTION_STATE_ENABLED;
                else
                    a.state = ACTION_STATE_DISABLE;
                return true;
            case Copy:
            case Cut:
            case Paste:
            case Undo:
            case Redo:
            case Tab:
            case BackTab:
            case Indent:
            case Unindent:
                if (isActionEnabled(a))
                    a.state = ACTION_STATE_ENABLED;
                else
                    a.state = ACTION_STATE_DISABLE;
                return true;
            default:
                return super.handleActionStateRequest(a);
        }
    }

    override protected bool handleAction(const Action a) {
        TextPosition oldCaretPos = _caretPos;
        dstring currentLine = _content[_caretPos.line];
        switch (a.id) with(EditorActions)
        {
            case Left:
            case SelectLeft:
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
            case Right:
            case SelectRight:
                correctCaretPos();
                if (_caretPos.pos < currentLine.length) {
                    _caretPos.pos++;
                    updateSelectionAfterCursorMovement(oldCaretPos, (a.id & 1) != 0);
                    ensureCaretVisible();
                } else if (_caretPos.line < _content.length - 1 && _content.multiline) {
                    _caretPos.pos = 0;
                    _caretPos.line++;
                    updateSelectionAfterCursorMovement(oldCaretPos, (a.id & 1) != 0);
                    ensureCaretVisible();
                }
                return true;
            case WordLeft:
            case SelectWordLeft:
                {
                    TextPosition newpos = _content.moveByWord(_caretPos, -1, _camelCasePartsAsWords);
                    if (newpos != _caretPos) {
                        _caretPos = newpos;
                        updateSelectionAfterCursorMovement(oldCaretPos, a.id == EditorActions.SelectWordLeft);
                        ensureCaretVisible();
                    }
                }
                return true;
            case WordRight:
            case SelectWordRight:
                {
                    TextPosition newpos = _content.moveByWord(_caretPos, 1, _camelCasePartsAsWords);
                    if (newpos != _caretPos) {
                        _caretPos = newpos;
                        updateSelectionAfterCursorMovement(oldCaretPos, a.id == EditorActions.SelectWordRight);
                        ensureCaretVisible();
                    }
                }
                return true;
            case DocumentBegin:
            case SelectDocumentBegin:
                if (_caretPos.pos > 0 || _caretPos.line > 0) {
                    _caretPos.line = 0;
                    _caretPos.pos = 0;
                    ensureCaretVisible();
                    updateSelectionAfterCursorMovement(oldCaretPos, (a.id & 1) != 0);
                }
                return true;
            case LineBegin:
            case SelectLineBegin:
                auto space = _content.getLineWhiteSpace(_caretPos.line);
                if (_caretPos.pos > 0) {
                    if (_caretPos.pos > space.firstNonSpaceIndex && space.firstNonSpaceIndex > 0)
                        _caretPos.pos = space.firstNonSpaceIndex;
                    else
                        _caretPos.pos = 0;
                    ensureCaretVisible();
                    updateSelectionAfterCursorMovement(oldCaretPos, (a.id & 1) != 0);
                } else {
                    // caret pos is 0
                    if (space.firstNonSpaceIndex > 0)
                        _caretPos.pos = space.firstNonSpaceIndex;
                    ensureCaretVisible();
                    updateSelectionAfterCursorMovement(oldCaretPos, (a.id & 1) != 0);
                    if (a.id == EditorActions.LineBegin && _caretPos == oldCaretPos) {
                        clearSelection();
                    }
                }
                return true;
            case DocumentEnd:
            case SelectDocumentEnd:
                if (_caretPos.line < _content.length - 1 || _caretPos.pos < _content[_content.length - 1].length) {
                    _caretPos.line = _content.length - 1;
                    _caretPos.pos = cast(int)_content[_content.length - 1].length;
                    ensureCaretVisible();
                    updateSelectionAfterCursorMovement(oldCaretPos, (a.id & 1) != 0);
                }
                return true;
            case LineEnd:
            case SelectLineEnd:
                if (_caretPos.pos < currentLine.length) {
                    _caretPos.pos = cast(int)currentLine.length;
                    ensureCaretVisible();
                    updateSelectionAfterCursorMovement(oldCaretPos, (a.id & 1) != 0);
                } else if (a.id == EditorActions.LineEnd) {
                        clearSelection();
                }
                return true;
            case DelPrevWord:
                if (readOnly)
                    return true;
                correctCaretPos();
                if (removeSelectionTextIfSelected()) // clear selection
                    return true;
                TextPosition newpos = _content.moveByWord(_caretPos, -1, _camelCasePartsAsWords);
                if (newpos < _caretPos)
                    removeRangeText(TextRange(newpos, _caretPos));
                return true;
            case DelNextWord:
                if (readOnly)
                    return true;
                correctCaretPos();
                if (removeSelectionTextIfSelected()) // clear selection
                    return true;
                TextPosition newpos = _content.moveByWord(_caretPos, 1, _camelCasePartsAsWords);
                if (newpos > _caretPos)
                    removeRangeText(TextRange(_caretPos, newpos));
                return true;
            case DelPrevChar:
                if (readOnly)
                    return true;
                correctCaretPos();
                if (removeSelectionTextIfSelected()) // clear selection
                    return true;
                if (_caretPos.pos > 0) {
                    // delete prev char in current line
                    TextRange range = TextRange(_caretPos, _caretPos);
                    range.start.pos--;
                    removeRangeText(range);
                } else if (_caretPos.line > 0) {
                    // merge with previous line
                    TextRange range = TextRange(_caretPos, _caretPos);
                    range.start = _content.lineEnd(range.start.line - 1);
                    removeRangeText(range);
                }
                return true;
            case DelNextChar:
                if (readOnly)
                    return true;
                correctCaretPos();
                if (removeSelectionTextIfSelected()) // clear selection
                    return true;
                if (_caretPos.pos < currentLine.length) {
                    // delete char in current line
                    TextRange range = TextRange(_caretPos, _caretPos);
                    range.end.pos++;
                    removeRangeText(range);
                } else if (_caretPos.line < _content.length - 1) {
                    // merge with next line
                    TextRange range = TextRange(_caretPos, _caretPos);
                    range.end.line++;
                    range.end.pos = 0;
                    removeRangeText(range);
                }
                return true;
            case Copy:
            case Cut:
                TextRange range = _selectionRange;
                if (range.empty && _copyCurrentLineWhenNoSelection) {
                    range = currentLineRange;
                }
                if (!range.empty) {
                    dstring selectionText = getRangeText(range);
                    platform.setClipboardText(selectionText);
                    if (!readOnly && a.id == Cut) {
                        EditOperation op = new EditOperation(EditAction.Replace, range, [""d]);
                        _content.performOperation(op, this);
                    }
                }
                return true;
            case Paste:
                {
                    if (readOnly)
                        return true;
                    dstring selectionText = platform.getClipboardText();
                    dstring[] lines;
                    if (_content.multiline) {
                        lines = splitDString(selectionText);
                    } else {
                        lines = [replaceEolsWithSpaces(selectionText)];
                    }
                    EditOperation op = new EditOperation(EditAction.Replace, _selectionRange, lines);
                    _content.performOperation(op, this);
                }
                return true;
            case Undo:
                {
                    if (readOnly)
                        return true;
                    _content.undo(this);
                }
                return true;
            case Redo:
                {
                    if (readOnly)
                        return true;
                    _content.redo(this);
                }
                return true;
            case Indent:
                indentRange(false);
                return true;
            case Unindent:
                indentRange(true);
                return true;
            case Tab:
                {
                    if (readOnly)
                        return true;
                    if (_selectionRange.empty) {
                        if (useSpacesForTabs) {
                            // insert one or more spaces to
                            EditOperation op = new EditOperation(EditAction.Replace, TextRange(_caretPos, _caretPos), [spacesForTab(_caretPos.pos)]);
                            _content.performOperation(op, this);
                        } else {
                            // just insert tab character
                            EditOperation op = new EditOperation(EditAction.Replace, TextRange(_caretPos, _caretPos), ["\t"d]);
                            _content.performOperation(op, this);
                        }
                    } else {
                        if (multipleLinesSelected()) {
                            // indent range
                            return handleAction(new Action(EditorActions.Indent));
                        } else {
                            // insert tab
                            if (useSpacesForTabs) {
                                // insert one or more spaces to
                                EditOperation op = new EditOperation(EditAction.Replace, _selectionRange, [spacesForTab(_selectionRange.start.pos)]);
                                _content.performOperation(op, this);
                            } else {
                                // just insert tab character
                                EditOperation op = new EditOperation(EditAction.Replace, _selectionRange, ["\t"d]);
                                _content.performOperation(op, this);
                            }
                        }

                    }
                }
                return true;
            case BackTab:
                {
                    if (readOnly)
                        return true;
                    if (_selectionRange.empty) {
                        // remove spaces before caret
                        TextRange r = spaceBefore(_caretPos);
                        if (!r.empty) {
                            EditOperation op = new EditOperation(EditAction.Replace, r, [""d]);
                            _content.performOperation(op, this);
                        }
                    } else {
                        if (multipleLinesSelected()) {
                            // unindent range
                            return handleAction(new Action(EditorActions.Unindent));
                        } else {
                            // remove space before selection
                            TextRange r = spaceBefore(_selectionRange.start);
                            if (!r.empty) {
                                int nchars = r.end.pos - r.start.pos;
                                TextRange saveRange = _selectionRange;
                                TextPosition saveCursor = _caretPos;
                                EditOperation op = new EditOperation(EditAction.Replace, r, [""d]);
                                _content.performOperation(op, this);
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
            case ToggleReplaceMode:
                replaceMode = !replaceMode;
                return true;
            case SelectAll:
                selectAll();
                ensureCaretVisible();
                return true;
            case ToggleBookmark:
                if (_content.multiline) {
                    int line = a.longParam >= 0 ? cast(int)a.longParam : _caretPos.line;
                    _content.lineIcons.toggleBookmark(line);
                    return true;
                }
                return false;
            case GoToNextBookmark:
            case GoToPreviousBookmark:
                if (_content.multiline) {
                    LineIcon mark = _content.lineIcons.findNext(LineIconType.bookmark, _selectionRange.end.line, a.id == EditorActions.GoToNextBookmark ? 1 : -1);
                    if (mark) {
                        setCaretPos(mark.line, 0, true);
                        return true;
                    }
                }
                return false;
            default:
                break;
        }
        return super.handleAction(a);
    }

    /// Select whole text
    void selectAll() {
        _selectionRange.start.line = 0;
        _selectionRange.start.pos = 0;
        _selectionRange.end = _content.lineEnd(_content.length - 1);
        _caretPos = _selectionRange.end;
        requestActionsUpdate();
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
    protected dstring indentLine(dstring src, bool back, TextPosition * cursorPos) {
        int firstNonSpace = -1;
        int x = 0;
        int unindentPos = -1;
        int cursor = cursorPos ? cursorPos.pos : 0;
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
            if (unindentPos == src.length) {
                if (cursorPos)
                    cursorPos.pos = 0;
                return ""d;
            }
            if (cursor >= unindentPos)
                cursorPos.pos -= unindentPos;
            return src[unindentPos .. $].dup;
        } else {
            // indent
            if (useSpacesForTabs) {
                if (cursor > 0)
                    cursorPos.pos += tabSize;
                return spacesForTab(0) ~ src;
            } else {
                if (cursor > 0)
                    cursorPos.pos++;
                return "\t"d ~ src;
            }
        }
    }

    /// indent / unindent range
    protected void indentRange(bool back) {
        TextRange r = _selectionRange;
        r.start.pos = 0;
        if (r.end.pos > 0)
            r.end = _content.lineBegin(r.end.line + 1);
        if (r.end.line <= r.start.line)
            r = TextRange(_content.lineBegin(_caretPos.line), _content.lineBegin(_caretPos.line + 1));
        int lineCount = r.end.line - r.start.line;
        if (r.end.pos > 0)
            lineCount++;
        dstring[] newContent = new dstring[lineCount + 1];
        bool changed = false;
        for (int i = 0; i < lineCount; i++) {
            dstring srcline = _content.line(r.start.line + i);
            dstring dstline = indentLine(srcline, back, r.start.line + i == _caretPos.line ? &_caretPos : null);
            newContent[i] = dstline;
            if (dstline.length != srcline.length)
                changed = true;
        }
        if (changed) {
            TextRange saveRange = r;
            TextPosition saveCursor = _caretPos;
            EditOperation op = new EditOperation(EditAction.Replace, r, newContent);
            _content.performOperation(op, this);
            _selectionRange = saveRange;
            _caretPos = saveCursor;
            ensureCaretVisible();
        }
    }

    /// map key to action
    override protected Action findKeyAction(uint keyCode, uint flags) {
        // don't handle tabs when disabled
        if (keyCode == KeyCode.TAB && (flags == 0 || flags == KeyFlag.Shift) && (!_wantTabs || readOnly))
            return null;
        return super.findKeyAction(keyCode, flags);
    }

    static bool isAZaz(dchar ch) {
        return (ch >= 'a' && ch <='z') || (ch >= 'A' && ch <='Z');
    }

    /// handle keys
    override bool onKeyEvent(KeyEvent event) {
        //Log.d("onKeyEvent ", event.action, " ", event.keyCode, " flags ", event.flags);
        if(super.onKeyEvent(event))
            return true;
        if (focused) startCaretBlinking();
        cancelHoverTimer();
        bool ctrlOrAltPressed = !!(event.flags & KeyFlag.Control); //(event.flags & (KeyFlag.Control /* | KeyFlag.Alt */));
        //if (event.action == KeyAction.KeyDown && event.keyCode == KeyCode.SPACE && (event.flags & KeyFlag.Control)) {
        //    Log.d("Ctrl+Space pressed");
        //}
        if (event.action == KeyAction.Text && event.text.length && !ctrlOrAltPressed) {
            //Log.d("text entered: ", event.text);
            if (readOnly)
                return true;
            if (!(!!(event.flags & KeyFlag.Alt) && event.text.length == 1 && isAZaz(event.text[0]))) { // filter out Alt+A..Z
                if (replaceMode && _selectionRange.empty && _content[_caretPos.line].length >= _caretPos.pos + event.text.length) {
                    // replace next char(s)
                    TextRange range = _selectionRange;
                    range.end.pos += cast(int)event.text.length;
                    EditOperation op = new EditOperation(EditAction.Replace, range, [event.text]);
                    _content.performOperation(op, this);
                } else {
                    EditOperation op = new EditOperation(EditAction.Replace, _selectionRange, [event.text]);
                    _content.performOperation(op, this);
                }
                return true;
            }
        }
        //if (event.keyCode == KeyCode.SPACE && !readOnly) {
        //    return true;
        //}
        //if (event.keyCode == KeyCode.RETURN && !readOnly && !_content.multiline) {
        //    return true;
        //}
        return false;
    }

    /// Handle Ctrl + Left mouse click on text
    protected void onControlClick() {
        // override to do something useful on Ctrl + Left mouse click in text
    }

    protected TextPosition _hoverTextPosition;
    protected Point _hoverMousePosition;
    protected ulong _hoverTimer;
    protected long _hoverTimeoutMillis = 800;

    /// override to handle mouse hover timeout in text
    protected void onHoverTimeout(Point pt, TextPosition pos) {
        // override to do something useful on hover timeout
    }

    protected void onHover(Point pos) {
        if (_hoverMousePosition == pos)
            return;
        //Log.d("onHover ", pos);
        int x = pos.x - left - _leftPaneWidth;
        int y = pos.y - top;
        _hoverMousePosition = pos;
        _hoverTextPosition = clientToTextPos(Point(x, y));
        cancelHoverTimer();
        Rect reversePos = textPosToClient(_hoverTextPosition);
        if (x < reversePos.left + 10.pointsToPixels)
            _hoverTimer = setTimer(_hoverTimeoutMillis);
    }

    protected void cancelHoverTimer() {
        if (_hoverTimer) {
            cancelTimer(_hoverTimer);
            _hoverTimer = 0;
        }
    }

    /// process mouse event; return true if event is processed by widget.
    override bool onMouseEvent(MouseEvent event) {
        //Log.d("onMouseEvent ", id, " ", event.action, "  (", event.x, ",", event.y, ")");
        // support onClick
        bool insideLeftPane = event.x < _clientRect.left && event.x >= _clientRect.left - _leftPaneWidth;
        if (event.action == MouseAction.ButtonDown && insideLeftPane) {
            setFocus();
            cancelHoverTimer();
            if (onLeftPaneMouseClick(event))
                return true;
        }
        if (event.action == MouseAction.ButtonDown && event.button == MouseButton.Left) {
            setFocus();
            cancelHoverTimer();
            _mouseSelectionMode = MouseSelectionMode.characters;
            if (event.tripleClick) {
                selectLineByMouse(event.x - _clientRect.left, event.y - _clientRect.top);
                if (!_selectionRange.empty) {
                    _mouseSelectionMode = MouseSelectionMode.lines;
                    _mouseSelectionAnchor = _selectionRange;
                }
            } else if (event.doubleClick) {
                selectWordByMouse(event.x - _clientRect.left, event.y - _clientRect.top);
                if (!_selectionRange.empty) {
                    _mouseSelectionMode = MouseSelectionMode.words;
                    _mouseSelectionAnchor = _selectionRange;
                }
            } else {
                auto doSelect = cast(bool)(event.keyFlags & MouseFlag.Shift);
                updateCaretPositionByMouse(event.x - _clientRect.left, event.y - _clientRect.top, doSelect);

                if (event.keyFlags == MouseFlag.Control)
                    onControlClick();
            }
            startCaretBlinking();
            invalidate();
            return true;
        }
        if (event.action == MouseAction.Move && (event.flags & MouseButton.Left) != 0) {
            if (_mouseSelectionMode == MouseSelectionMode.characters)
                updateCaretPositionByMouse(event.x - _clientRect.left, event.y - _clientRect.top, true);
            else
                extendSelectionByMouse(event.x - _clientRect.left, event.y - _clientRect.top);
            ensureCaretVisible();
            return true;
        }
        if (event.action == MouseAction.Move && event.flags == 0) {
            // hover
            if (focused && !insideLeftPane) {
                onHover(event.pos);
            } else {
                cancelHoverTimer();
            }
            return true;
        }
        if (event.action == MouseAction.ButtonUp && event.button == MouseButton.Left) {
            cancelHoverTimer();
            return true;
        }
        if (event.action == MouseAction.FocusOut || event.action == MouseAction.Cancel) {
            cancelHoverTimer();
            return true;
        }
        if (event.action == MouseAction.FocusIn) {
            cancelHoverTimer();
            return true;
        }
        if (event.action == MouseAction.Wheel) {
            cancelHoverTimer();
            uint keyFlags = event.flags & (MouseFlag.Shift | MouseFlag.Control | MouseFlag.Alt);
            if (event.wheelDelta < 0) {
                if (keyFlags == MouseFlag.Shift)
                    return handleAction(new Action(EditorActions.ScrollRight));
                if (keyFlags == MouseFlag.Control)
                    return handleAction(new Action(EditorActions.ZoomOut));
                return handleAction(new Action(EditorActions.ScrollLineDown));
            } else if (event.wheelDelta > 0) {
                if (keyFlags == MouseFlag.Shift)
                    return handleAction(new Action(EditorActions.ScrollLeft));
                if (keyFlags == MouseFlag.Control)
                    return handleAction(new Action(EditorActions.ZoomIn));
                return handleAction(new Action(EditorActions.ScrollLineUp));
            }
        }
        cancelHoverTimer();
        return super.onMouseEvent(event);
    }

    /// returns caret position
    @property TextPosition caretPos() {
        return _caretPos;
    }

    /// change caret position and ensure it is visible
    void setCaretPos(int line, int column, bool makeVisible = true, bool center = false)
    {
        _caretPos = TextPosition(line,column);
        correctCaretPos();
        invalidate();
        if (makeVisible)
            ensureCaretVisible(center);
        handleEditorStateChange();
    }
}

interface EditorActionHandler {
    bool onEditorAction(const Action action);
}

interface EnterKeyHandler {
    bool onEnterKey(EditWidgetBase editor);
}

/// where EditBox places a panel (FindPanel, EditorMessageBar, or an application widget)
enum EditorPanelPosition {
    /// above the text
    Top,
    /// below the text
    Bottom,
}

/// kind of an EditorMessageBar: selects icon and colors
enum EditorMessageKind {
    Info,
    Warning,
    Error,
}

/// what an EditBox does when another program changes its file (#1280); see EditBox.externalChangeMode
enum ExternalChangeMode {
    /// nothing: no checks
    ignore,
    /// a message (Reload / Ignore) also for text without unsaved changes
    notify,
    /// text without unsaved changes is reloaded at once (one undo step; the caret stays)
    reloadUnmodified,
}

/// how an EditBox reacts to a change of its file on disk; see externalChangeReaction
enum ExternalChangeReaction {
    /// nothing to do; an external change message is hidden
    none,
    /// reload the text
    reload,
    /// message: the file changed; Reload / Ignore
    notifyChanged,
    /// message: the file changed and the text has unsaved changes; Reload / Keep mine
    notifyConflict,
    /// message: the file was deleted; Save / Keep
    notifyDeleted,
    /// message before a save: the file changed since it was loaded; Overwrite / Reload / Cancel
    confirmSave,
}

/**
The reaction of an editor to the result of a check of its file (#1280), for the text with or without unsaved
changes and the editor's mode; beforeSave: the check is made right before saving the text to the file (a deleted
file is then simply written again).
*/
ExternalChangeReaction externalChangeReaction(FileChangeKind kind, bool textModified, ExternalChangeMode mode,
        bool beforeSave) @safe pure nothrow @nogc {
    if (mode == ExternalChangeMode.ignore || kind == FileChangeKind.unchanged)
        return ExternalChangeReaction.none;
    if (kind == FileChangeKind.deleted)
        return beforeSave ? ExternalChangeReaction.none : ExternalChangeReaction.notifyDeleted;
    // modified, created again (or overflow: unknown, treated as changed)
    if (beforeSave)
        return ExternalChangeReaction.confirmSave;
    if (textModified)
        return ExternalChangeReaction.notifyConflict;
    return mode == ExternalChangeMode.reloadUnmodified ? ExternalChangeReaction.reload
        : ExternalChangeReaction.notifyChanged;
}

/**
True if a shown external change message stays when a later check of the file gives the reaction next (#1290): the
save question (Overwrite / Reload / Cancel) is not replaced by a message about the same change. The focus check
right after the save reports it when the menu or dialog that started the save closes; the user answers the
question, or Escape cancels it. fileUnchanged: the file is still as it was when the question was shown; if another
change came meanwhile, the newer message replaces the question, so Overwrite doesn't hide that change.
*/
bool keepsExternalChangeMessage(ExternalChangeReaction shown, ExternalChangeReaction next, bool fileUnchanged)
        @safe pure nothrow @nogc {
    return shown == ExternalChangeReaction.confirmSave && fileUnchanged
        && (next == ExternalChangeReaction.notifyChanged || next == ExternalChangeReaction.notifyConflict);
}

/// handles clicks on EditorMessageBar buttons; messageId is the id passed to EditBox.showMessage
interface EditorMessageActionHandler {
    /// return true if handled; otherwise the action is dispatched as usual (except Ignore and Close)
    bool onEditorMessageAction(EditBox source, string messageId, const Action action);
}

/// single line editor
class EditLine : EditWidgetBase {

    Signal!EditorActionHandler editorAction;
    /// handle Enter key press inside line editor
    Signal!EnterKeyHandler enterKey;

    /// empty parameter list constructor - for usage by factory
    this() {
        this(null);
    }
    /// create with ID parameter
    this(string ID, dstring initialContent = null) {
        super(ID, ScrollBarMode.Invisible, ScrollBarMode.Invisible);
        _content = new EditableContent(false);
        _content.contentChanged = this;
        _selectAllWhenFocusedWithTab = true;
        _deselectAllWhenUnfocused = true;
        wantTabs = false;
        styleId = STYLE_EDIT_LINE;
        text = initialContent;
        onThemeChanged();
    }

    /// sets default popup menu with copy/paste/cut/undo/redo
    EditLine setDefaultPopupMenu() {
        MenuItem items = new MenuItem();
        items.add(ACTION_EDITOR_COPY, ACTION_EDITOR_PASTE, ACTION_EDITOR_CUT,
                  ACTION_EDITOR_UNDO, ACTION_EDITOR_REDO);
        popupMenu = items;
        return this;
    }

    protected dstring _measuredText;
    protected int[] _measuredTextWidths;
    protected Point _measuredTextSize;

    protected Point _measuredTextToSetWidgetSize;
    protected dstring _textToSetWidgetSize = "aaaaa"d;

    @property void textToSetWidgetSize(dstring newText) {
        _textToSetWidgetSize = newText;
        requestLayout();
    }

    @property dstring textToSetWidgetSize() {
        return _textToSetWidgetSize;
    }

    protected int[] _measuredTextToSetWidgetSizeWidths;

    protected dchar _passwordChar = 0;
    /// password character - 0 for normal editor, some character, e.g. '*' to hide text by replacing all characters with this char
    @property dchar passwordChar() { return _passwordChar; }
    @property EditLine passwordChar(dchar ch) {
        if (_passwordChar != ch) {
            _passwordChar = ch;
            requestLayout();
        }
        return this;
    }

    override protected Rect textPosToClient(TextPosition p) {
        Rect res;
        res.bottom = _clientRect.height;
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
            if (pt.x <= mx) {
                res.pos = i;
                return res;
            }
        }
        res.pos = cast(int)_measuredText.length;
        return res;
    }

    override protected void ensureCaretVisible(bool center = false) {
        //_scrollPos
        Rect rc = textPosToClient(_caretPos);
        if (rc.left < 0) {
            // scroll left
            _scrollPos.x += rc.left - _spaceWidth * 4;
            if (_scrollPos.x < 0)
                _scrollPos.x = 0;
            invalidate();
        } else if (rc.left >= _clientRect.width - _spaceWidth * 4) {
            // scroll right
            _scrollPos.x += rc.left - _clientRect.width + _spaceWidth * 4;
            invalidate();
        }
        updateScrollBars();
        handleEditorStateChange();
    }

    protected dstring applyPasswordChar(dstring s) {
        if (!_passwordChar || s.length == 0)
            return s;
        dchar[] ss = s.dup;
        foreach(ref ch; ss)
            ch = _passwordChar;
        return cast(dstring)ss;
    }

    override protected Point measureVisibleText() {
        FontRef font = font();
        //Point sz = font.textSize(text);
        _measuredText = applyPasswordChar(text);
        _measuredTextWidths.length = _measuredText.length;
        int charsMeasured = font.measureText(_measuredText, _measuredTextWidths, MAX_WIDTH_UNSPECIFIED, tabSize);
        _measuredTextSize.x = charsMeasured > 0 ? _measuredTextWidths[charsMeasured - 1]: 0;
        _measuredTextSize.y = font.height;
        return _measuredTextSize;
    }

    protected Point measureTextToSetWidgetSize() {
        FontRef font = font();
        _measuredTextToSetWidgetSizeWidths.length = _textToSetWidgetSize.length;
        int charsMeasured = font.measureText(_textToSetWidgetSize, _measuredTextToSetWidgetSizeWidths, MAX_WIDTH_UNSPECIFIED, tabSize);
        _measuredTextToSetWidgetSize.x = charsMeasured > 0 ? _measuredTextToSetWidgetSizeWidths[charsMeasured - 1]: 0;
        _measuredTextToSetWidgetSize.y = font.height;
        return _measuredTextToSetWidgetSize;
    }

    /// measure
    override void measure(int parentWidth, int parentHeight) {
        if (visibility == Visibility.Gone)
            return;

        updateFontProps();
        measureVisibleText();
        measureTextToSetWidgetSize();
        updateLeftPaneWidth(); // set by layout: the screen DPI may have changed since (#840)
        measuredContent(parentWidth, parentHeight, _measuredTextToSetWidgetSize.x + _leftPaneWidth, _measuredTextToSetWidgetSize.y);
    }

    override bool handleAction(const Action a) {
        switch (a.id) with(EditorActions)
        {
            case InsertNewLine:
            case PrependNewLine:
            case AppendNewLine:
                if (editorAction.assigned) {
                    return editorAction(a);
                }
                break;
            case Up:
                break;
            case Down:
                break;
            case PageUp:
                break;
            case PageDown:
                break;
            default:
                break;
        }
        return super.handleAction(a);
    }


    /// handle keys
    override bool onKeyEvent(KeyEvent event) {
        if(super.onKeyEvent(event))
            return true;
        if (enterKey.assigned) {
            if (event.keyCode == KeyCode.RETURN && event.modifiers == 0) {
                if (event.action == KeyAction.KeyDown)
                    return true;
                if (event.action == KeyAction.KeyUp) {
                    if (enterKey(this))
                       return true;
                }
            }
        }
        // Escape goes to the parents, e.g. a dialog cancels or a find panel closes, as with focus on other widgets
        if (event.keyCode == KeyCode.ESCAPE)
            return false;
        // so does a plain Enter without an enterKey handler: a dialog presses its default button (#728)
        if (event.keyCode == KeyCode.RETURN && event.noModifiers
                && (event.action == KeyAction.KeyDown || event.action == KeyAction.KeyUp))
            return false;
        return true;
    }

    /// process mouse event; return true if event is processed by widget.
    override bool onMouseEvent(MouseEvent event) {
        return super.onMouseEvent(event);
    }

    /// Set widget rectangle to specified value and layout widget contents. (Step 2 of two phase layout).
    override void layout(Rect rc) {
        if (visibility == Visibility.Gone) {
            return;
        }
        _needLayout = false;
        Point sz = Point(rc.width, measuredHeight);
        applyAlign(rc, sz);
        _pos = rc;
        _clientRect = rc;
        applyMargins(_clientRect);
        applyPadding(_clientRect);
        if (_contentChanged) {
            measureVisibleText();
            _contentChanged = false;
        }
    }


    /// override to custom highlight of line background
    protected void drawLineBackground(DrawBuf buf, Rect lineRect, Rect visibleRect) {
        if (!_selectionRange.empty) {
            // line inside selection
            Rect startrc = textPosToClient(_selectionRange.start);
            Rect endrc = textPosToClient(_selectionRange.end);
            Rect rc = lineRect;
            rc.left = startrc.left + _clientRect.left;
            rc.right = endrc.left + _clientRect.left;
            if (!rc.empty) {
                // draw selection rect for line
                buf.fillRect(rc, focused ? _selectionColorFocused : _selectionColorNormal);
            }
            if (_leftPaneWidth > 0) {
                Rect leftPaneRect = visibleRect;
                leftPaneRect.right = leftPaneRect.left;
                leftPaneRect.left -= _leftPaneWidth;
                drawLeftPane(buf, leftPaneRect, 0);
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
        applyPadding(rc);
        auto _ = ClipRectSaver(buf, rc, alpha);

        FontRef font = font();
        dstring txt = applyPasswordChar(text);

        drawLineBackground(buf, _clientRect, _clientRect);
        font.drawText(buf, rc.left - _scrollPos.x, rc.top, txt, textColor, tabSize);

        drawCaret(buf);
    }
}

// SpinCtrl
private {
    import std.ascii;
}

class SpinCtrl : HorizontalLayout {

    TextWidget label;
    int min, max;

    private EditLine linEdit;
    private Button butUp, butDown;


    @property int value() { return linEdit.text.to!int; }
    @property void value(int val) {
        linEdit.text = val.to!dstring;
    }

    override @property bool enabled() { return linEdit.enabled; }
    alias enabled = Widget.enabled;
    @property void enabled(bool status) {
        linEdit.enabled = status;
        butUp.enabled = status;
        butDown.enabled = status;
    }

    this(int min, int max, int initialVal = 0, dstring labelText = null){
        this.min = min;
        this.max = max;

        if(labelText !is null){
            label = new TextWidget("label", labelText);
            addChild(label);
        }

        linEdit = new class EditLine {
            this(){super("linEdit", "0"d);}
            override bool onKeyEvent(KeyEvent event) {
                if (( KeyAction.Text == event.action && event.text[0].isDigit)
                    || event.keyCode == KeyCode.BACK
                    || event.keyCode == KeyCode.DEL
                    || event.keyCode == KeyCode.LEFT
                    || event.keyCode == KeyCode.RIGHT
                    || event.keyCode == KeyCode.TAB
                    ){
                        return super.onKeyEvent(event);
                }
                return false;
            }

            override bool onMouseEvent(MouseEvent event) {
                if(enabled && event.action == MouseAction.Wheel){
                    if((event.wheelDelta == 1) && (value < max))
                        value = value + event.wheelDelta;
                    if((event.wheelDelta == -1) && (value > min))
                        value = value + event.wheelDelta;
                    return true;
                }
                return super.onMouseEvent(event);
            }
        };

        linEdit.addOnFocusChangeListener((w, t){
            if(linEdit.text == "")
                linEdit.text = "0";
            if(linEdit.text.to!int > max)
                value = max;
            if(linEdit.text.to!int < min)
                value = min;
            return true;
        });

        linEdit.minHeight = 35;
        if(initialVal != 0)
            value = initialVal;
        addChild(linEdit);


        auto butContainer = new VerticalLayout();
        butContainer.maxHeight = linEdit.minHeight;

        butUp = new Button("butUp", "+"d);
        butUp.margins(Rect(1.pointsToPixels, 1.pointsToPixels, 1.pointsToPixels, 1.pointsToPixels));

        butDown = new Button("butDown", "-"d);
        butDown.margins(Rect(1.pointsToPixels, 1.pointsToPixels, 1.pointsToPixels, 1.pointsToPixels));

        butContainer.addChild(butUp);
        butContainer.addChild(butDown);

        addChild(butContainer);

        butUp.click = delegate(Widget w) {
            immutable val = linEdit.text.to!int;
            if(val < max )
                linEdit.text = (val + 1).to!dstring;
            return true;
        };

        butDown.click = delegate(Widget w) {
            immutable val = linEdit.text.to!int;
            if(val > min )
                linEdit.text = (val - 1).to!dstring;
            return true;
        };

        enabled = true;
    }

}

/// multiline editor
class EditBox : EditWidgetBase {
    /// empty parameter list constructor - for usage by factory
    this() {
        this(null);
    }
    /// create with ID parameter
    this(string ID, dstring initialContent = null, ScrollBarMode hscrollbarMode = ScrollBarMode.Visible, ScrollBarMode vscrollbarMode = ScrollBarMode.Visible) {
        super(ID, hscrollbarMode, vscrollbarMode);
        _content = new EditableContent(true); // multiline
        _content.contentChanged = this;
        styleId = STYLE_EDIT_BOX;
        text = initialContent;
        acceleratorMap.add( [
            // zoom
            new Action(EditorActions.ZoomIn, KeyCode.ADD, KeyFlag.Control),
            new Action(EditorActions.ZoomOut, KeyCode.SUB, KeyFlag.Control),
        ]);
        onThemeChanged();
    }

    ~this() {
        if (inGCFinalizer()) return; // finalized by the GC: a leak, touch nothing (#975)
        if (_findPanel) {
            destroy(_findPanel);
            _findPanel = null;
        }
    }

    protected int _firstVisibleLine;

    protected int _maxLineWidth;
    protected int _numVisibleLines;             // number of lines visible in client area
    protected dstring[] _visibleLines;          // text for visible lines
    protected int[][] _visibleLinesMeasurement; // char positions for visible lines
    protected int[] _visibleLinesWidths; // width (in pixels) of visible lines
    protected CustomCharProps[][] _visibleLinesHighlights;
    protected CustomCharProps[][] _visibleLinesHighlightsBuf;

    protected Point _measuredTextToSetWidgetSize;
    protected dstring _textToSetWidgetSize = "aaaaa/naaaaa"d;
    protected int[] _measuredTextToSetWidgetSizeWidths;

    /// Set _needRewrap to true;
    override void wordWrapRefresh()
    {
        _needRewrap = true;
    }

    override @property int fontSize() const { return super.fontSize(); }
    override @property Widget fontSize(int size) {
        // Need to rewrap if fontSize changed
        _needRewrap = true;
        return super.fontSize(size);
    }

    override protected int lineCount() {
        return _content.length;
    }

    override protected void updateMaxLineWidth() {
        // find max line width. TODO: optimize!!!
        int maxw;
        for (int i = 0; i < _content.length; i++) {
            dstring s = _content[i];
            int w = calcLineWidth(s);
            if (maxw < w)
                maxw = w;
        }
        _maxLineWidth = maxw;
    }

    @property int minFontSize() {
        return _minFontSize;
    }
    @property EditBox minFontSize(int size) {
        _minFontSize = size;
        return this;
    }

    @property int maxFontSize() {
        return _maxFontSize;
    }

    @property EditBox maxFontSize(int size) {
        _maxFontSize = size;
        return this;
    }

    /// Set widget rectangle to specified value and layout widget contents. (Step 2 of two phase layout).
    override void layout(Rect rc) {
        if (visibility == Visibility.Gone)
            return;

        if (rc != _pos)
            _contentChanged = true;
        // panels: top ones downward from the top edge, bottom ones upward from the bottom edge, in order of adding
        Rect contentRc = rc;
        scope(success) {
            // the text area changes when panels are shown or hidden, even if the editor rectangle stays
            _lastPanelsContentRect = contentRc;
        }
        foreach (ref p; _panels) {
            if (p.widget.visibility == Visibility.Gone)
                continue;
            p.widget.measure(rc.width, rc.height);
            int h = p.widget.measuredHeight;
            if (p.position == EditorPanelPosition.Top) {
                p.widget.layout(Rect(rc.left, contentRc.top, rc.right, contentRc.top + h));
                contentRc.top += h;
            } else {
                p.widget.layout(Rect(rc.left, contentRc.bottom - h, rc.right, contentRc.bottom));
                contentRc.bottom -= h;
            }
        }

        if (contentRc != _lastPanelsContentRect)
            _contentChanged = true;
        super.layout(contentRc);
        if (_contentChanged) {
            measureVisibleText();
            _needRewrap = true;
            _contentChanged = false;
        }

        _pos = rc;
        if (_pendingEnsureCaretVisible && _clientRect.height > 0 && _lineHeight > 0)
            ensureCaretVisible(_pendingEnsureCaretVisibleCenter); // requested before the first layout (#966)
    }

    override protected Point measureVisibleText() {
        Point sz;
        FontRef font = font();
        _lineHeight = font.height;
        _numVisibleLines = (_clientRect.height + _lineHeight - 1) / _lineHeight;
        if (_firstVisibleLine >= _content.length) {
            _firstVisibleLine = _content.length - _numVisibleLines + 1;
            if (_firstVisibleLine < 0)
                _firstVisibleLine = 0;
            _caretPos.line = _content.length - 1;
            _caretPos.pos = 0;
        }
        if (_numVisibleLines < 1)
            _numVisibleLines = 1;
        if (_firstVisibleLine + _numVisibleLines > _content.length)
            _numVisibleLines = _content.length - _firstVisibleLine;
        if (_numVisibleLines < 1)
            _numVisibleLines = 1;
        _visibleLines.length = _numVisibleLines;
        if (_visibleLinesMeasurement.length < _numVisibleLines)
            _visibleLinesMeasurement.length = _numVisibleLines;
        if (_visibleLinesWidths.length < _numVisibleLines)
            _visibleLinesWidths.length = _numVisibleLines;
        if (_visibleLinesHighlights.length < _numVisibleLines) {
            _visibleLinesHighlights.length = _numVisibleLines;
            _visibleLinesHighlightsBuf.length = _numVisibleLines;
        }
        for (int i = 0; i < _numVisibleLines; i++) {
            _visibleLines[i] = _content[_firstVisibleLine + i];
            size_t len = _visibleLines[i].length;
            if (_visibleLinesMeasurement[i].length < len)
                _visibleLinesMeasurement[i].length = len;
            if (_visibleLinesHighlightsBuf[i].length < len)
                _visibleLinesHighlightsBuf[i].length = len;
            _visibleLinesHighlights[i] = handleCustomLineHighlight(_firstVisibleLine + i, _visibleLines[i], _visibleLinesHighlightsBuf[i]);
            int charsMeasured = font.measureText(_visibleLines[i], _visibleLinesMeasurement[i], int.max, tabSize);
            _visibleLinesWidths[i] = charsMeasured > 0 ? _visibleLinesMeasurement[i][charsMeasured - 1] : 0;
            if (sz.x < _visibleLinesWidths[i])
                sz.x = _visibleLinesWidths[i]; // width - max from visible lines
        }
        sz.x = _maxLineWidth;
        sz.y = _lineHeight * _content.length; // height - for all lines
        return sz;
    }

    protected bool _extendRightScrollBound = true;
    /// width of the horizontal scroll range: the longest line, plus room after it with _extendRightScrollBound
    protected int scrollContentWidth() {
        return _maxLineWidth + (_extendRightScrollBound ? _clientRect.width / 16 : 0);
    }

    /// content size for the Auto scrollbar decision: the horizontal scroll range, and the height of all lines (#991);
    /// a single line always fits, even into a client area lower than one line (no vertical scrollbar that can't
    /// scroll anything)
    override protected Point autoScrollbarContentSize() {
        return Point(scrollContentWidth(), _content.length > 1 ? _lineHeight * _content.length : 0);
    }

    /// update horizontal scrollbar widget position
    override protected void updateHScrollBar() {
        _hscrollbar.setRange(0, scrollContentWidth());
        _hscrollbar.pageSize = _clientRect.width;
        _hscrollbar.position = _scrollPos.x;
    }

    /// update verticat scrollbar widget position
    override protected void updateVScrollBar() {
        int visibleLines = _lineHeight ? _clientRect.height / _lineHeight : 1; // fully visible lines
        if (visibleLines < 1)
            visibleLines = 1;
        _vscrollbar.setRange(0, _content.length);
        _vscrollbar.pageSize = visibleLines;
        _vscrollbar.position = _firstVisibleLine;
    }

    /// process horizontal scrollbar event
    override bool onHScroll(ScrollEvent event) {
        if (event.action == ScrollAction.SliderMoved || event.action == ScrollAction.SliderReleased) {
            if (_scrollPos.x != event.position) {
                _scrollPos.x = event.position;
                invalidate();
            }
        } else if (event.action == ScrollAction.PageUp) {
            dispatchAction(new Action(EditorActions.ScrollLeft));
        } else if (event.action == ScrollAction.PageDown) {
            dispatchAction(new Action(EditorActions.ScrollRight));
        } else if (event.action == ScrollAction.LineUp) {
            dispatchAction(new Action(EditorActions.ScrollLeft));
        } else if (event.action == ScrollAction.LineDown) {
            dispatchAction(new Action(EditorActions.ScrollRight));
        }
        return true;
    }

    /// process vertical scrollbar event
    override bool onVScroll(ScrollEvent event) {
        if (event.action == ScrollAction.SliderMoved || event.action == ScrollAction.SliderReleased) {
            if (_firstVisibleLine != event.position) {
                _firstVisibleLine = event.position;
                measureVisibleText();
                invalidate();
            }
        } else if (event.action == ScrollAction.PageUp) {
            dispatchAction(new Action(EditorActions.ScrollPageUp));
        } else if (event.action == ScrollAction.PageDown) {
            dispatchAction(new Action(EditorActions.ScrollPageDown));
        } else if (event.action == ScrollAction.LineUp) {
            dispatchAction(new Action(EditorActions.ScrollLineUp));
        } else if (event.action == ScrollAction.LineDown) {
            dispatchAction(new Action(EditorActions.ScrollLineDown));
        }
        return true;
    }

    protected bool _enableScrollAfterText = true;
    /// ensureCaretVisible() requested before the first layout, done in layout() (#966)
    protected bool _pendingEnsureCaretVisible;
    protected bool _pendingEnsureCaretVisibleCenter;

    override protected void ensureCaretVisible(bool center = false) {
        if (_caretPos.line >= _content.length)
            _caretPos.line = _content.length - 1;
        if (_caretPos.line < 0)
            _caretPos.line = 0;
        if (_clientRect.height <= 0 || _lineHeight <= 0) {
            // not laid out yet: the number of visible lines is unknown (#966)
            _pendingEnsureCaretVisible = true;
            _pendingEnsureCaretVisibleCenter = center;
            return;
        }
        _pendingEnsureCaretVisible = false;
        int visibleLines = _clientRect.height / _lineHeight; // fully visible lines
        if (visibleLines < 1)
            visibleLines = 1;
        int maxFirstVisibleLine = _content.length - 1;
        if (!_enableScrollAfterText)
            maxFirstVisibleLine = _content.length - visibleLines;
        if (maxFirstVisibleLine < 0)
            maxFirstVisibleLine = 0;
        // moving the view to show the caret doesn't scroll after the text: a short text starts at its first line
        // (scrolling after the text by the user stays possible); with word wrap, text lines aren't screen lines
        int maxRevealFirstLine = maxFirstVisibleLine;
        if (!_wordWrap && _content.length - visibleLines < maxRevealFirstLine)
            maxRevealFirstLine = _content.length - visibleLines > 0 ? _content.length - visibleLines : 0;

        if (_caretPos.line < _firstVisibleLine) {
            _firstVisibleLine = _caretPos.line;
            if (center) {
                _firstVisibleLine -= visibleLines / 2;
                if (_firstVisibleLine < 0)
                    _firstVisibleLine = 0;
            }
            if (_firstVisibleLine > maxRevealFirstLine)
                _firstVisibleLine = maxRevealFirstLine;
            measureVisibleText();
            invalidate();
        } else if(_wordWrap && !(_firstVisibleLine > maxFirstVisibleLine)) {
            //For wordwrap mode, move down sooner
            int offsetLines = -1 * caretHeightOffset / _lineHeight;
            //Log.d("offsetLines: ", offsetLines);
            if (_caretPos.line >= _firstVisibleLine + visibleLines - offsetLines)
            {
                _firstVisibleLine = _caretPos.line - visibleLines + 1 + offsetLines;
                if (center)
                    _firstVisibleLine += visibleLines / 2;
                if (_firstVisibleLine > maxFirstVisibleLine)
                    _firstVisibleLine = maxFirstVisibleLine;
                if (_firstVisibleLine < 0)
                    _firstVisibleLine = 0;
                measureVisibleText();
                invalidate();
            }
        } else if (_caretPos.line >= _firstVisibleLine + visibleLines) {
            _firstVisibleLine = _caretPos.line - visibleLines + 1;
            if (center)
                _firstVisibleLine += visibleLines / 2;
            if (_firstVisibleLine > maxRevealFirstLine)
                _firstVisibleLine = maxRevealFirstLine;
            if (_firstVisibleLine < 0)
                _firstVisibleLine = 0;
            measureVisibleText();
            invalidate();
        } else if (_firstVisibleLine > maxFirstVisibleLine) {
            _firstVisibleLine = maxFirstVisibleLine;
            if (_firstVisibleLine < 0)
                _firstVisibleLine = 0;
            measureVisibleText();
            invalidate();
        }
        //_scrollPos
        Rect rc = textPosToClient(_caretPos);
        if (rc.left < 0) {
            // scroll left
            _scrollPos.x += rc.left - _spaceWidth * 4;
            if (_scrollPos.x < 0)
                _scrollPos.x = 0;
            invalidate();
        } else if (rc.left >= _clientRect.width - _spaceWidth * 4) {
            // scroll right
            if (!_wordWrap)
                _scrollPos.x += rc.left - _clientRect.width + _spaceWidth * 4;
            invalidate();
        }
        updateScrollBars();
        handleEditorStateChange();
    }

    override protected Rect textPosToClient(TextPosition p) {
        Rect res;
        int lineIndex = p.line - _firstVisibleLine;
        res.top = lineIndex * _lineHeight;
        res.bottom = res.top + _lineHeight;
        // if visible
        if (lineIndex >= 0 && lineIndex < _visibleLines.length) {
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
        // if the point is above the first visible line
        if (pt.y < 0) {
            res.line = _firstVisibleLine > 0 ? _firstVisibleLine - 1 : _firstVisibleLine;
            res.pos = 0;
            return res;
        }
        int lineIndex = pt.y / _lineHeight;
        if (lineIndex < _visibleLines.length) {
            res.line = lineIndex + _firstVisibleLine;
            int len = cast(int)_visibleLines[lineIndex].length;
            for (int i = 0; i < len; i++) {
                int x0 = i > 0 ? _visibleLinesMeasurement[lineIndex][i - 1] : 0;
                int x1 = _visibleLinesMeasurement[lineIndex][i];
                int mx = (x0 + x1) >> 1;
                if (pt.x <= mx) {
                    res.pos = i;
                    return res;
                }
            }
            res.pos = cast(int)_visibleLines[lineIndex].length;
        } else if (_visibleLines.length > 0) {
            res.line = _firstVisibleLine + cast(int)_visibleLines.length - 1;
            res.pos = cast(int)_visibleLines[$ - 1].length;
        } else {
            res.line = 0;
            res.pos = 0;
        }
        return res;
    }

    override protected bool handleAction(const Action a) {
        TextPosition oldCaretPos = _caretPos;
        switch (a.id) with(EditorActions)
        {
            case PrependNewLine:
                if (!readOnly) {
                    correctCaretPos();
                    _caretPos.pos = 0;
                    EditOperation op = new EditOperation(EditAction.Replace, _selectionRange, [""d, ""d]);
                    _content.performOperation(op, this);
                }
                return true;
            case InsertNewLine:
                if (!readOnly) {
                    correctCaretPos();
                    EditOperation op = new EditOperation(EditAction.Replace, _selectionRange, [""d, ""d]);
                    _content.performOperation(op, this);
                }
                return true;
            case Up:
            case SelectUp:
                if ((_caretPos.line > 0) | wordWrap) {
                    if (_wordWrap)
                    {
                        LineSpan curSpan = getSpan(_caretPos.line);
                        int curWrap = findWrapLine(_caretPos);
                        if (curWrap > 0)
                        {
                            _caretPos.pos-= curSpan.wrapPoints[curWrap - 1].wrapPos;
                        }
                        else
                        {
                            int previousPos = _caretPos.pos;
                            curSpan = getSpan(_caretPos.line - 1);
                            curWrap = curSpan.len - 1;
                            if (curWrap > 0)
                            {
                                int accumulativePoint = curSpan.accumulation(curSpan.len - 1, LineSpan.WrapPointInfo.Position);
                                _caretPos.line--;
                                _caretPos.pos = accumulativePoint + previousPos;
                            }
                            else
                            {
                                _caretPos.line--;
                            }
                        }
                    }
                    else if(_caretPos.line > 0)
                        _caretPos.line--;
                     correctCaretPos();
                     updateSelectionAfterCursorMovement(oldCaretPos, (a.id & 1) != 0);
                     ensureCaretVisible();
                }
                return true;
            case Down:
            case SelectDown:
                if (_caretPos.line < _content.length - 1) {
                    if (_wordWrap)
                    {
                        LineSpan curSpan = getSpan(_caretPos.line);
                        int curWrap = findWrapLine(_caretPos);
                        if (curWrap < curSpan.len - 1)
                        {
                            int previousPos = _caretPos.pos;
                            _caretPos.pos+= curSpan.wrapPoints[curWrap].wrapPos;
                            correctCaretPos();
                            if (_caretPos.pos == previousPos)
                            {
                                _caretPos.pos = 0;
                                _caretPos.line++;
                            }
                        }
                        else if (curSpan.len > 1)
                        {
                            int previousPos = _caretPos.pos;
                            int previousAccumulatedPosition = curSpan.accumulation(curSpan.len - 1, LineSpan.WrapPointInfo.Position);
                            _caretPos.line++;
                            _caretPos.pos = previousPos - previousAccumulatedPosition;
                        }
                        else
                        {
                            _caretPos.line++;
                        }
                    }
                    else
                    {
                        _caretPos.line++;
                    }
                    correctCaretPos();
                    updateSelectionAfterCursorMovement(oldCaretPos, (a.id & 1) != 0);
                    ensureCaretVisible();
                }
                return true;
            case PageBegin:
            case SelectPageBegin:
                {
                    ensureCaretVisible();
                    _caretPos.line = _firstVisibleLine;
                    correctCaretPos();
                    updateSelectionAfterCursorMovement(oldCaretPos, (a.id & 1) != 0);
                }
                return true;
            case PageEnd:
            case SelectPageEnd:
                {
                    ensureCaretVisible();
                    int fullLines = _clientRect.height / _lineHeight;
                    int newpos = _firstVisibleLine + fullLines - 1;
                    if (newpos >= _content.length)
                        newpos = _content.length - 1;
                    _caretPos.line = newpos;
                    correctCaretPos();
                    updateSelectionAfterCursorMovement(oldCaretPos, (a.id & 1) != 0);
                }
                return true;
            case PageUp:
            case SelectPageUp:
                {
                    ensureCaretVisible();
                    int fullLines = _clientRect.height / _lineHeight;
                    int newpos = _firstVisibleLine - fullLines;
                    if (newpos < 0) {
                        _firstVisibleLine = 0;
                        _caretPos.line = 0;
                    } else {
                        int delta = _firstVisibleLine - newpos;
                        _firstVisibleLine = newpos;
                        _caretPos.line -= delta;
                    }
                    correctCaretPos();
                    measureVisibleText();
                    updateScrollBars();
                    updateSelectionAfterCursorMovement(oldCaretPos, (a.id & 1) != 0);
                }
                return true;
            case PageDown:
            case SelectPageDown:
                {
                    ensureCaretVisible();
                    int fullLines = _clientRect.height / _lineHeight;
                    int newpos = _firstVisibleLine + fullLines;
                    if (newpos >= _content.length) {
                        _caretPos.line = _content.length - 1;
                    } else {
                        int delta = newpos - _firstVisibleLine;
                        _firstVisibleLine = newpos;
                        _caretPos.line += delta;
                    }
                    correctCaretPos();
                    measureVisibleText();
                    updateScrollBars();
                    updateSelectionAfterCursorMovement(oldCaretPos, (a.id & 1) != 0);
                }
                return true;
            case ScrollLeft:
                {
                    if (_scrollPos.x > 0) {
                        int newpos = _scrollPos.x - _spaceWidth * 4;
                        if (newpos < 0)
                            newpos = 0;
                        _scrollPos.x = newpos;
                        updateScrollBars();
                        invalidate();
                    }
                }
                return true;
            case ScrollRight:
                {
                    if (_scrollPos.x < _maxLineWidth - _clientRect.width) {
                        int newpos = _scrollPos.x + _spaceWidth * 4;
                        if (newpos > _maxLineWidth - _clientRect.width)
                            newpos = _maxLineWidth - _clientRect.width;
                        _scrollPos.x = newpos;
                        updateScrollBars();
                        invalidate();
                    }
                }
                return true;
            case ScrollLineUp:
                {
                    if (_firstVisibleLine > 0) {
                        _firstVisibleLine -= 3;
                        if (_firstVisibleLine < 0)
                            _firstVisibleLine = 0;
                        measureVisibleText();
                        updateScrollBars();
                        invalidate();
                    }
                }
                return true;
            case ScrollPageUp:
                {
                    int fullLines = _clientRect.height / _lineHeight;
                    if (_firstVisibleLine > 0) {
                        _firstVisibleLine -= fullLines * 3 / 4;
                        if (_firstVisibleLine < 0)
                            _firstVisibleLine = 0;
                        measureVisibleText();
                        updateScrollBars();
                        invalidate();
                    }
                }
                return true;
            case ScrollLineDown:
                {
                    int fullLines = _clientRect.height / _lineHeight;
                    if (_firstVisibleLine + fullLines < _content.length) {
                        _firstVisibleLine += 3;
                        if (_firstVisibleLine > _content.length - fullLines)
                            _firstVisibleLine = _content.length - fullLines;
                        if (_firstVisibleLine < 0)
                            _firstVisibleLine = 0;
                        measureVisibleText();
                        updateScrollBars();
                        invalidate();
                    }
                }
                return true;
            case ScrollPageDown:
                {
                    int fullLines = _clientRect.height / _lineHeight;
                    if (_firstVisibleLine + fullLines < _content.length) {
                        _firstVisibleLine += fullLines * 3 / 4;
                        if (_firstVisibleLine > _content.length - fullLines)
                            _firstVisibleLine = _content.length - fullLines;
                        if (_firstVisibleLine < 0)
                            _firstVisibleLine = 0;
                        measureVisibleText();
                        updateScrollBars();
                        invalidate();
                    }
                }
                return true;
            case ZoomOut:
            case ZoomIn:
                {
                    int dir = a.id == ZoomIn ? 1 : -1;
                    if (_minFontSize < _maxFontSize && _minFontSize > 0 && _maxFontSize > 0) {
                        int currentFontSize = fontSize;
                        int increment = currentFontSize >= 30 ? 2 : 1;
                        int newFontSize = currentFontSize + increment * dir; //* 110 / 100;
                        if (newFontSize > 30)
                            newFontSize &= 0xFFFE;
                        if (currentFontSize != newFontSize && newFontSize <= _maxFontSize && newFontSize >= _minFontSize) {
                            Log.i("Font size in editor ", id, " zoomed to ", newFontSize);
                            fontSize = cast(ushort)newFontSize;
                            updateFontProps();
                            _needRewrap = true;
                            measureVisibleText();
                            updateScrollBars();
                            invalidate();
                        }
                    }
                }
                return true;
            case ToggleBlockComment:
                if (!readOnly && _content.syntaxSupport && _content.syntaxSupport.supportsToggleBlockComment && _content.syntaxSupport.canToggleBlockComment(_selectionRange))
                    _content.syntaxSupport.toggleBlockComment(_selectionRange, this);
                return true;
            case ToggleLineComment:
                if (!readOnly && _content.syntaxSupport && _content.syntaxSupport.supportsToggleLineComment && _content.syntaxSupport.canToggleLineComment(_selectionRange))
                    _content.syntaxSupport.toggleLineComment(_selectionRange, this);
                return true;
            case AppendNewLine:
                if (!readOnly) {
                    correctCaretPos();
                    TextPosition p = _content.lineEnd(_caretPos.line);
                    TextRange r = TextRange(p, p);
                    EditOperation op = new EditOperation(EditAction.Replace, r, [""d, ""d]);
                    _content.performOperation(op, this);
                    _caretPos = oldCaretPos;
                    handleEditorStateChange();
                }
                return true;
            case DeleteLine:
                if (!readOnly) {
                    correctCaretPos();
                    EditOperation op = new EditOperation(EditAction.Replace, _content.lineRange(_caretPos.line), [""d]);
                    _content.performOperation(op, this);
                }
                return true;
            case Find:
                openFindPanel();
                return true;
            case FindNext:
                findNext(false);
                return true;
            case FindPrev:
                findNext(true);
                return true;
            case Replace:
                openReplacePanel();
                return true;
            default:
                break;
        }
        return super.handleAction(a);
    }

    /// calculate full content size in pixels
    override Point fullContentSize() {
        Point textSz;
        textSz.y = _lineHeight * _content.length;
        textSz.x = _maxLineWidth;
        //int maxy = _lineHeight * 5; // limit measured height
        //if (textSz.y > maxy)
        //    textSz.y = maxy;
        return textSz;
    }

    // override to set minimum scrollwidget size - default 100x100
    override protected Point minimumVisibleContentSize() {
        FontRef font = font();
        _measuredTextToSetWidgetSizeWidths.length = _textToSetWidgetSize.length;
        int charsMeasured = font.measureText(_textToSetWidgetSize, _measuredTextToSetWidgetSizeWidths, MAX_WIDTH_UNSPECIFIED, tabSize);
        _measuredTextToSetWidgetSize.x = charsMeasured > 0 ? _measuredTextToSetWidgetSizeWidths[charsMeasured - 1]: 0;
        _measuredTextToSetWidgetSize.y = font.height;
        return _measuredTextToSetWidgetSize;
    }

    /// measure
    override void measure(int parentWidth, int parentHeight) {
        if (visibility == Visibility.Gone)
            return;

        updateFontProps();
        updateMaxLineWidth();
        foreach (ref p; _panels) {
            if (p.widget.visibility == Visibility.Gone)
                continue;
            p.widget.measure(parentWidth, parentHeight);
            if (parentHeight != SIZE_UNSPECIFIED)
                parentHeight -= p.widget.measuredHeight;
        }

        super.measure(parentWidth, parentHeight);
    }


    protected void highlightTextPattern(DrawBuf buf, int lineIndex, Rect lineRect, Rect visibleRect) {
        dstring pattern = _textToHighlight;
        uint options = _textToHighlightOptions;
        if (!pattern.length) {
            // support highlighting selection text - if whole word is selected
            if (_selectionRange.empty || !_selectionRange.singleLine)
                return;
            if (_selectionRange.start.line >= _content.length)
                return;
            dstring selLine = _content.line(_selectionRange.start.line);
            int start = _selectionRange.start.pos;
            int end = _selectionRange.end.pos;
            if (!isSelectedWord(selLine, start, end))
                return;
            pattern = selLine[start .. end];
            // whole word is selected - enable highlight for it
            options = TextSearchFlag.CaseSensitive | TextSearchFlag.WholeWords;
        }
        if (!pattern.length)
            return;
        bool caseSensitive = (options & TextSearchFlag.CaseSensitive) != 0;
        bool wholeWords = (options & TextSearchFlag.WholeWords) != 0;
        // the scope and the direction apply to the find text, not to the highlight of a selected word
        TextRange scope_ = WHOLE_TEXT_RANGE;
        bool back = false;
        if (_textToHighlight.length) {
            if (_textToHighlightScoped) {
                if (_content.revision != _textToHighlightRevision)
                    return; // the scope may refer to other text now
                scope_ = _textToHighlightScope;
            }
            back = _textToHighlightBack;
        }
        // the current match may be on another line (#1177); a selected word is the current match of its own
        TextRange current = _textToHighlight.length
            ? currentSearchMatch(pattern, options, scope_, back, _textToHighlightFindNext) : _selectionRange;
        forEachLineMatch(_content.line(lineIndex), lineIndex, pattern, caseSensitive, wholeWords, scope_, current,
            (TextRange r, bool isCurrent) {
                highlightLineRange(buf, lineRect, isCurrent ? _searchHighlightColorCurrent : _searchHighlightColorOther,
                    r);
            });
    }

    // the current match of the highlighted pattern, cached (#1177): searched again only when something it depends on
    // changes, not on each repaint
    private static struct CurrentMatchKey {
        ulong revision;
        dstring pattern;
        uint options;
        TextRange scope_;
        TextRange selection;
        TextPosition caret;
        bool back;
        bool anyLine;
    }
    private CurrentMatchKey _currentMatchKey;
    private TextRange _currentMatch;
    private bool _currentMatchValid;
    // all matches, when the search outward from the caret gives up: then caret moves pick from them (#1177)
    private static struct MatchesKey {
        ulong revision;
        dstring pattern;
        uint options;
        TextRange scope_;
    }
    private MatchesKey _matchesKey;
    private TextRange[] _matches;
    private bool _matchesValid;
    /// lines and characters searched outward from the caret for the current match before giving up
    private enum int CURRENT_MATCH_SEARCH_LINES = 1000;
    private enum size_t CURRENT_MATCH_SEARCH_CHARS = 100_000;
    /// milliseconds with the text unchanged before all matches are collected, when there is none near the caret
    private enum int COLLECT_MATCHES_DELAY = 300;
    // the timer collecting all matches, and for which text and pattern
    private ulong _collectMatchesTimer;
    private long _collectMatchesTimerSet; // currentTimeMillis when it was set
    private MatchesKey _collectMatchesKey;

    override void setTextToHighlight(dstring pattern, uint textToHighlightOptions, TextRange scope_, bool back) {
        // all matches of another pattern, if collected or about to be (#1177)
        if (pattern != _matchesKey.pattern || textToHighlightOptions != _matchesKey.options
                || scope_ != _matchesKey.scope_) {
            _matches = null;
            _matchesValid = false;
        }
        if (_collectMatchesTimer && (pattern != _collectMatchesKey.pattern
                || textToHighlightOptions != _collectMatchesKey.options || scope_ != _collectMatchesKey.scope_)) {
            cancelTimer(_collectMatchesTimer);
            _collectMatchesTimer = 0;
        }
        super.setTextToHighlight(pattern, textToHighlightOptions, scope_, back);
    }
    alias setTextToHighlight = EditWidgetBase.setTextToHighlight;

    override bool onTimer(ulong id) {
        if (id && id == _externalChangeCheckTimer) {
            _externalChangeCheckTimer = 0;
            checkExternalChange();
            return false;
        }
        if (id == _collectMatchesTimer) {
            _collectMatchesTimer = 0;
            // the text is unchanged since the search gave up: collect all matches and show the current one
            if (_content.revision == _collectMatchesKey.revision) {
                _matches = FindPanel.matchesInScope(findAll(_collectMatchesKey.pattern, _collectMatchesKey.options),
                    _collectMatchesKey.scope_);
                _matchesKey = _collectMatchesKey;
                _matchesValid = true;
                _currentMatchValid = false;
                invalidate();
            }
            return false;
        }
        return super.onTimer(id);
    }

    /// the current match of pattern inside scope_, as found by findCurrentMatch(); when there is none near the caret,
    /// chosen by currentMatchIndex() among all matches, collected once the text stays unchanged for a moment, so that
    /// typing doesn't search the whole text each time; until then, none (#1177)
    protected TextRange currentSearchMatch(dstring pattern, uint options, TextRange scope_, bool back, bool anyLine) {
        CurrentMatchKey key = CurrentMatchKey(_content.revision, pattern, options, scope_, _selectionRange, _caretPos,
            back, anyLine);
        if (_currentMatchValid && key == _currentMatchKey)
            return _currentMatch;
        MatchesKey matchesKey = MatchesKey(_content.revision, pattern, options, scope_);
        if (anyLine && _matchesValid && matchesKey == _matchesKey) {
            ptrdiff_t index = currentMatchIndex(_matches, _selectionRange, _caretPos, back);
            _currentMatch = index >= 0 ? _matches[index] : TextRange.init;
        } else if (!findCurrentMatch(_content.length, (int line) => _content.line(line), pattern,
                (options & TextSearchFlag.CaseSensitive) != 0, (options & TextSearchFlag.WholeWords) != 0, scope_,
                _selectionRange, _caretPos, back, anyLine, CURRENT_MATCH_SEARCH_LINES, CURRENT_MATCH_SEARCH_CHARS,
                _currentMatch)) {
            // started again by edits, not by caret moves
            // also when the timer should have fired long ago: the window can drop it, e.g. while the editor is moved
            long now = currentTimeMillis;
            if (!_collectMatchesTimer || matchesKey != _collectMatchesKey
                    || now - _collectMatchesTimerSet > 2 * COLLECT_MATCHES_DELAY) {
                if (_collectMatchesTimer)
                    cancelTimer(_collectMatchesTimer);
                _collectMatchesKey = matchesKey;
                _collectMatchesTimer = setTimer(COLLECT_MATCHES_DELAY);
                _collectMatchesTimerSet = now;
            }
        }
        _currentMatchKey = key;
        _currentMatchValid = true;
        return _currentMatch;
    }

    /// finds the current match of pattern among its matches inside scope_ in lines 0 .. lineCount - 1, the one
    /// currentMatchIndex() chooses, by searching outward from the caret rather than the whole text (#1177): the
    /// selected match if the selection is one, else the first match that ends after the caret (searching back: the
    /// last one that starts before it), wrapping around; TextRange.init if there is none. Without anyLine, only the
    /// selected match or one on the caret line, without wrapping around (a highlight without Find next). Returns
    /// false if it gave up after searching maxLines lines or maxChars characters; current is TextRange.init then
    static bool findCurrentMatch(int lineCount, scope dstring delegate(int line) lineText, dstring pattern,
            bool caseSensitive, bool wholeWords, TextRange scope_, TextRange selection, TextPosition caret, bool back,
            bool anyLine, int maxLines, size_t maxChars, out TextRange current) {
        import std.algorithm : max, min;
        bool inScope(TextRange r) { return r.start >= scope_.start && r.end <= scope_.end; }
        int searched = 0;
        size_t searchedChars = 0;
        // the match on line chosen by pred, the first one in the search direction
        TextRange onLine(int line, scope bool delegate(TextRange r) pred) {
            dstring text = lineText(line);
            searched++;
            searchedChars += text.length;
            TextRange res;
            forEachLineMatch(text, line, pattern, caseSensitive, wholeWords, (TextRange r) {
                if (inScope(r) && pred(r) && (back || res.empty))
                    res = r;
            });
            return res;
        }
        bool any(TextRange r) { return true; }
        if (!pattern.length)
            return true;
        // matches are single-line
        int selLine = selection.start.line;
        if (!selection.empty && selLine == selection.end.line && selLine >= 0 && selLine < lineCount
                && onLine(selLine, (TextRange r) => r == selection) == selection) {
            current = selection;
            return true;
        }
        // the lines that can have matches in the scope
        int first = max(0, scope_.start.line);
        int last = min(lineCount - 1, scope_.end.line);
        int line = caret.line;
        if (line >= first && line <= last) {
            current = onLine(line, back ? (TextRange r) => r.start < caret : (TextRange r) => r.end > caret);
            if (!current.empty)
                return true;
        }
        if (!anyLine)
            return true;
        // the lines in search order, after the caret line, then wrapping around up to it: 1 found, 0 not found on
        // line i, -1 gave up
        int search(int i) {
            if (searched >= maxLines || searchedChars >= maxChars)
                return -1;
            current = onLine(i, &any);
            return current.empty ? 0 : 1;
        }
        int res = 0;
        if (!back) {
            for (int i = max(line + 1, first); i <= last && !res; i++)
                res = search(i);
            for (int i = first; i <= min(line, last) && !res; i++)
                res = search(i);
        } else {
            for (int i = min(line - 1, last); i >= first && !res; i--)
                res = search(i);
            for (int i = last; i >= max(line, first) && !res; i--)
                res = search(i);
        }
        return res >= 0;
    }

    /// calls sink for each match of pattern in line lineIndex with text lineText, in order; matches don't overlap
    static void forEachLineMatch(dstring lineText, int lineIndex, dstring pattern, bool caseSensitive,
            bool wholeWords, scope void delegate(TextRange r) sink) {
        if (!pattern.length || lineText.length < pattern.length)
            return;
        size_t start = 0;
        for (;;) {
            ptrdiff_t pos = indexOfPattern(lineText[start .. $], pattern, caseSensitive);
            if (pos < 0)
                break;
            start += pos;
            if (!wholeWords || isWholeWord(lineText, start, start + pattern.length))
                sink(TextRange(TextPosition(lineIndex, cast(int)start),
                    TextPosition(lineIndex, cast(int)(start + pattern.length))));
            start += pattern.length;
        }
    }

    /// as forEachLineMatch above, only the matches inside scope_ (WHOLE_TEXT_RANGE for all), with current = true
    /// for the one equal to current (#1145, #1166, #1177)
    static void forEachLineMatch(dstring lineText, int lineIndex, dstring pattern, bool caseSensitive,
            bool wholeWords, TextRange scope_, TextRange current, scope void delegate(TextRange r, bool current) sink) {
        forEachLineMatch(lineText, lineIndex, pattern, caseSensitive, wholeWords, (TextRange r) {
            if (r.start >= scope_.start && r.end <= scope_.end)
                sink(r, r == current);
        });
    }

    /// index of the current match in matches (in text order), -1 if there are none: the selected match if the
    /// selection is one of them, else the match Find next and Replace take (nextMatchIndex()): the first one that
    /// ends after the caret (the match the caret is in, or the next one), or the first one if none does; searching
    /// back (back), the last one that starts before the caret, or the last one if none does. Of two adjacent
    /// matches, the caret at the end of the first one is at the start of the second: without a selected match, the
    /// second is current, or the first one when searching back (#1145, #1165, #1177)
    static ptrdiff_t currentMatchIndex(const(TextRange)[] matches, TextRange selection, TextPosition caret,
            bool back = false) @safe pure nothrow @nogc {
        if (!selection.empty)
            foreach (i, r; matches)
                if (r == selection)
                    return i;
        return nextMatchIndex(matches, TextRange.init, caret, back ? -1 : 1);
    }

    /// index of the first occurrence of pattern in text, -1 if there is none, 0 for an empty pattern; without
    /// caseSensitive, compared with Unicode simple case folding (std.uni.sicmp: one character for one, so a match
    /// is as long as the pattern; "ς" matches "Σ")
    static ptrdiff_t indexOfPattern(dstring text, dstring pattern, bool caseSensitive) @safe pure nothrow @nogc {
        if (!pattern.length)
            return 0;
        if (pattern.length > text.length)
            return -1;
        if (caseSensitive) {
            import std.string : indexOf;
            return text.indexOf(pattern);
        }
        // not std.string.indexOf with No.caseSensitive: for dstrings it misses matches (dlang/phobos#11160, #1144)
        import std.uni : sicmp;
        foreach (i; 0 .. text.length - pattern.length + 1)
            if (sicmp(text[i .. i + pattern.length], pattern) == 0)
                return i;
        return -1;
    }

    /// characters that make up words, for whole-word search and the highlight of a selected word (#1147): the same
    /// as for word selection and moving by words (EditableContent.isWordChar)
    static bool isWordChar(dchar ch) @safe pure nothrow @nogc {
        return EditableContent.isWordChar(ch);
    }
    static bool isValidWordBound(dchar innerChar, dchar outerChar) @safe pure nothrow @nogc {
        return !isWordChar(innerChar) || !isWordChar(outerChar);
    }
    /// returns true if selected range of string is whole word; combining marks and ZWNJ/ZWJ are parts of the word
    /// before them, as for word selection (EditableContent.isWordCharAt, #1168)
    static bool isWholeWord(dstring lineText, size_t start, size_t end) @safe pure nothrow @nogc {
        alias w = EditableContent.isWordCharAt;
        if (start >= lineText.length || start >= end)
            return false;
        if (start > 0 && w(lineText, start) && w(lineText, start - 1))
            return false;
        if (end > 0 && end < lineText.length && w(lineText, end - 1) && w(lineText, end))
            return false;
        return true;
    }

    /// true if lineText[start .. end] is a whole word that starts and ends with word characters: a selection whose
    /// other occurrences are highlighted
    static bool isSelectedWord(dstring lineText, size_t start, size_t end) @safe pure nothrow @nogc {
        if (start >= end || end > lineText.length)
            return false;
        alias w = EditableContent.isWordCharAt;
        return w(lineText, start) && w(lineText, end - 1) && isWholeWord(lineText, start, end);
    }

    // non-ASCII letters and digits are word characters (#1147)
    unittest {
        assert(isWordChar('a') && isWordChar('Z') && isWordChar('_'));
        assert(isWordChar('5') && isWordChar('п') && isWordChar('Ж') && isWordChar('é') && isWordChar('λ'));
        assert(!isWordChar(' ') && !isWordChar('.') && !isWordChar('(') && !isWordChar('-') && !isWordChar('\t'));
        assert(!isWholeWord("приветствие"d, 0, 6)); // "привет" in "приветствие"
        assert(isWholeWord("привет мир"d, 0, 6));
        assert(!isWholeWord("x1"d, 0, 1));
        assert(!isWholeWord("1x"d, 1, 2));
        assert(isWholeWord("x + 1"d, 0, 1));
        assert(!isWholeWord("café"d, 0, 3)); // "caf" in "café"
        assert(isWholeWord("a.b"d, 2, 3));
        // combining marks and ZWNJ are parts of words
        assert(!isWholeWord("cafe\u0301 noir"d, 0, 4)); // "cafe" in decomposed "café"
        assert(!isWholeWord("हिन्दी"d, 0, 3)); // before the virama
        assert(!isWholeWord("می\u200Cخواهم"d, 0, 2)); // before ZWNJ
        // but not a variation selector after a symbol, or a joiner in an emoji sequence (#1168)
        assert(isSelectedWord("abc\u2764\uFE0Fdef"d, 5, 8));
        assert(isWholeWord("\U0001F468\u200Dabc"d, 2, 5));
        // selections whose other occurrences are highlighted
        assert(isSelectedWord("привет мир"d, 0, 6));
        assert(isSelectedWord("x1 + y"d, 0, 2));
        assert(!isSelectedWord("x1 + y"d, 0, 1)); // a part of a word
        assert(!isSelectedWord(" ab"d, 0, 3)); // starts with a space
        assert(!isSelectedWord("ab."d, 0, 3)); // ends with a dot
        assert(!isSelectedWord("ab"d, 0, 3)); // past the end of the line
        assert(!isSelectedWord("ab"d, 1, 1));
    }

    /// find all occurences of text pattern in content; options = bitset of TextSearchFlag
    TextRange[] findAll(dstring pattern, uint options) {
        TextRange[] res;
        res.assumeSafeAppend();
        if (!pattern.length)
            return res;
        bool caseSensitive = (options & TextSearchFlag.CaseSensitive) != 0;
        bool wholeWords = (options & TextSearchFlag.WholeWords) != 0;
        // the same matches as highlighted (#1145)
        for (int i = 0; i < _content.length; i++)
            forEachLineMatch(_content.line(i), i, pattern, caseSensitive, wholeWords, (TextRange r) { res ~= r; });
        return res;
    }

    /// find next occurence of text pattern in content, returns true if found: pos is set to the start of the match
    /// chosen by nextMatchIndex() (#1145, #1165). Since #1165, a single selected match is found again (true, pos
    /// unchanged) instead of returning false, and without a selected match a caret right after a match goes on to
    /// the next one
    bool findNextPattern(ref TextPosition pos, dstring pattern, uint searchOptions, int direction,
            TextRange selection = TextRange.init) {
        TextRange[] all = findAll(pattern, searchOptions);
        ptrdiff_t index = nextMatchIndex(all, selection, pos, direction);
        if (index < 0)
            return false;
        pos = all[index].start;
        return true;
    }

    /// index in matches (in text order) of the match findNextPattern() goes to, -1 if there are none. From a
    /// selected match, direction (-1, 0 or 1) steps from it, wrapping around. Without one, going forward (direction
    /// >= 0) takes the first match that ends after pos (the match pos is in, or the next one), going back the last
    /// match that starts before pos, wrapping around (#1165)
    static ptrdiff_t nextMatchIndex(const(TextRange)[] matches, TextRange selection, TextPosition pos,
            int direction) @safe pure nothrow @nogc {
        if (!matches.length)
            return -1;
        if (!selection.empty)
            foreach (i, r; matches)
                if (r == selection)
                    return (i + matches.length + (direction > 0 ? 1 : direction < 0 ? -1 : 0)) % matches.length;
        if (direction >= 0) {
            foreach (i, r; matches)
                if (r.end > pos)
                    return i;
            return 0;
        }
        foreach_reverse (i, r; matches)
            if (r.start < pos)
                return i;
        return matches.length - 1;
    }

    protected void highlightLineRange(DrawBuf buf, Rect lineRect, uint color, TextRange r) {
        Rect startrc = textPosToClient(r.start);
        Rect endrc = textPosToClient(r.end);
        Rect rc = lineRect;
        rc.left = _clientRect.left + startrc.left;
        // up to the start of the end position, as the selection: its right is 1 unit further, a cell in console
        // builds (#1139)
        rc.right = _clientRect.left + endrc.left;
        if (_wordWrap && !rc.empty)
        {
            wordWrapFillRect(buf, r.start.line, rc, color);
        }
        else if (!rc.empty) {
            // draw selection rect for matching bracket
            buf.fillRect(rc, color);
        }
    }

    /// Used in place of directly calling buf.fillRect in word wrap mode
    void wordWrapFillRect(DrawBuf buf, int line, Rect lineToDivide, uint color)
    {
        Rect rc = lineToDivide;
        auto limitNumber = (int num, int limit) => num > limit ? limit : num;
        LineSpan curSpan = getSpan(line);
        int yOffset = _lineHeight * (wrapsUpTo(line));
        rc.offset(0, yOffset);
        Rect[] wrappedSelection;
        wrappedSelection.length = curSpan.len;
        foreach (size_t i_, wrapLineRect; wrappedSelection)
        {
            int i = cast(int)i_;
            int startingDifference = rc.left - _clientRect.left;
            wrapLineRect = rc;
            wrapLineRect.offset(-1 * curSpan.accumulation(cast(int)i, LineSpan.WrapPointInfo.Width), cast(int)i * _lineHeight);
            wrapLineRect.right = limitNumber(wrapLineRect.right,(rc.left + curSpan.wrapPoints[i].wrapWidth) - startingDifference);
            buf.fillRect(wrapLineRect, color);
        }
    }

    /// override to custom highlight of line background
    protected void drawLineBackground(DrawBuf buf, int lineIndex, Rect lineRect, Rect visibleRect) {
        // highlight odd lines
        //if ((lineIndex & 1))
        //    buf.fillRect(visibleRect, 0xF4808080);

        // console fills are opaque: search matches first, so that a selected match shows the selection (#1139)
        static if (WIDGET_STYLE_CONSOLE)
            highlightTextPattern(buf, lineIndex, lineRect, visibleRect);

        if (!_selectionRange.empty && _selectionRange.start.line <= lineIndex && _selectionRange.end.line >= lineIndex) {
            // line inside selection
            Rect startrc = textPosToClient(_selectionRange.start);
            Rect endrc = textPosToClient(_selectionRange.end);
            int startx = lineIndex == _selectionRange.start.line ? startrc.left + _clientRect.left : lineRect.left;
            int endx = lineIndex == _selectionRange.end.line ? endrc.left + _clientRect.left : lineRect.right + _spaceWidth;
            Rect rc = lineRect;
            rc.left = startx;
            rc.right = endx;
            if (!rc.empty && _wordWrap)
            {
                wordWrapFillRect(buf, lineIndex, rc, focused ? _selectionColorFocused : _selectionColorNormal);
            }
            else if (!rc.empty) {
                // draw selection rect for line
                buf.fillRect(rc, focused ? _selectionColorFocused : _selectionColorNormal);
            }
        }

        static if (!WIDGET_STYLE_CONSOLE)
            highlightTextPattern(buf, lineIndex, lineRect, visibleRect);

        if (_matchingBraces.start.line == lineIndex)  {
            TextRange r = TextRange(_matchingBraces.start, _matchingBraces.start.offset(1));
            highlightLineRange(buf, lineRect, _matchingBracketHightlightColor, r);
        }
        if (_matchingBraces.end.line == lineIndex)  {
            TextRange r = TextRange(_matchingBraces.end, _matchingBraces.end.offset(1));
            highlightLineRange(buf, lineRect, _matchingBracketHightlightColor, r);
        }

        // frame around current line
        if (focused && lineIndex == _caretPos.line && _selectionRange.singleLine && _selectionRange.start.line == _caretPos.line) {
            //TODO: Figure out why a little slow to catch up
            if (_wordWrap)
                visibleRect.offset(0, -caretHeightOffset);
            buf.drawFrame(visibleRect, 0xA0808080, Rect(1,1,1,1));
        }

    }

    override protected void drawExtendedArea(DrawBuf buf) {
        if (_leftPaneWidth <= 0)
            return;
        Rect rc = _clientRect;

        FontRef font = font();
        int i = _firstVisibleLine;
        int lc = lineCount;
        for (;;) {
            Rect lineRect = rc;
            lineRect.left = _clientRect.left - _leftPaneWidth;
            lineRect.right = _clientRect.left;
            lineRect.bottom = lineRect.top + _lineHeight;
            if (lineRect.top >= _clientRect.bottom)
                break;
            drawLeftPane(buf, lineRect, i < lc ? i : -1);
            rc.top += _lineHeight;
            if (_wordWrap)
            {
                int currentWrap = 1;
                for (;;)
                {
                    LineSpan curSpan = getSpan(i);
                    if (currentWrap > curSpan.len - 1)
                        break;
                    Rect lineRect2 = rc;
                    lineRect2.left = _clientRect.left - _leftPaneWidth;
                    lineRect2.right = _clientRect.left;
                    lineRect2.bottom = lineRect.top + _lineHeight;
                    if (lineRect2.top >= _clientRect.bottom)
                        break;
                    drawLeftPane(buf, lineRect2, -1);
                    rc.top += _lineHeight;

                    currentWrap++;
                }
            }
            i++;
        }
    }


    protected CustomCharProps[ubyte] _tokenHighlightColors;

    /// set highlight options for particular token category
    void setTokenHightlightColor(ubyte tokenCategory, uint color, bool underline = false, bool strikeThrough = false) {
         _tokenHighlightColors[tokenCategory] = CustomCharProps(color, underline, strikeThrough);
    }
    /// clear highlight colors
    void clearTokenHightlightColors() {
        destroy(_tokenHighlightColors);
    }

    /**
        Custom text color and style highlight (using text highlight) support.

        Return null if no syntax highlight required for line.
     */
    protected CustomCharProps[] handleCustomLineHighlight(int line, dstring txt, ref CustomCharProps[] buf) {
        if (!_tokenHighlightColors)
            return null; // no highlight colors set
        TokenPropString tokenProps = _content.lineTokenProps(line);
        if (tokenProps.length > 0) {
            bool hasNonzeroTokens = false;
            foreach(t; tokenProps)
                if (t) {
                    hasNonzeroTokens = true;
                    break;
                }
            if (!hasNonzeroTokens)
                return null; // all characters are of unknown token type (or white space)
            if (buf.length < tokenProps.length)
                buf.length = tokenProps.length;
            CustomCharProps[] colors = buf[0..tokenProps.length]; //new CustomCharProps[tokenProps.length];
            for (int i = 0; i < tokenProps.length; i++) {
                ubyte p = tokenProps[i];
                if (p in _tokenHighlightColors)
                    colors[i] = _tokenHighlightColors[p];
                else if ((p & TOKEN_CATEGORY_MASK) in _tokenHighlightColors)
                    colors[i] = _tokenHighlightColors[(p & TOKEN_CATEGORY_MASK)];
                else
                    colors[i].color = textColor;
                if (isFullyTransparentColor(colors[i].color))
                    colors[i].color = textColor;
            }
            return colors;
        }
        return null;
    }

    TextRange _matchingBraces;

    bool _showWhiteSpaceMarks;
    /// when true, show marks for tabs and spaces at beginning and end of line, and tabs inside line
    @property bool showWhiteSpaceMarks() const { return _showWhiteSpaceMarks; }
    @property void showWhiteSpaceMarks(bool show) {
        if (_showWhiteSpaceMarks != show) {
            _showWhiteSpaceMarks = show;
            invalidate();
        }
    }

    /// find max tab mark column position for line
    protected int findMaxTabMarkColumn(int lineIndex) {
        if (lineIndex < 0 || lineIndex >= content.length)
            return -1;
        int maxSpace = -1;
        auto space = content.getLineWhiteSpace(lineIndex);
        maxSpace = space.firstNonSpaceColumn;
        if (maxSpace >= 0)
            return maxSpace;
        for(int i = lineIndex - 1; i >= 0; i--) {
            space = content.getLineWhiteSpace(i);
            if (!space.empty) {
                maxSpace = space.firstNonSpaceColumn;
                break;
            }
        }
        for(int i = lineIndex + 1; i < content.length; i++) {
            space = content.getLineWhiteSpace(i);
            if (!space.empty) {
                if (maxSpace < 0 || maxSpace < space.firstNonSpaceColumn)
                    maxSpace = space.firstNonSpaceColumn;
                break;
            }
        }
        return maxSpace;
    }

    void drawTabPositionMarks(DrawBuf buf, ref FontRef font, int lineIndex, Rect lineRect) {
        int maxCol = findMaxTabMarkColumn(lineIndex);
        if (maxCol > 0) {
            int spaceWidth = font.charWidth(' ');
            Rect rc = lineRect;
            uint color = addAlpha(textColor, 0xC0);
            for (int i = 0; i < maxCol; i += tabSize) {
                rc.left = lineRect.left + i * spaceWidth;
                rc.right = rc.left + 1;
                buf.fillRectPattern(rc, color, PatternType.dotted);
            }
        }
    }

    void drawWhiteSpaceMarks(DrawBuf buf, ref FontRef font, dstring txt, int tabSize, Rect lineRect, Rect visibleRect) {
        // _showTabPositionMarks
        // _showWhiteSpaceMarks
        int firstNonSpace = -1;
        int lastNonSpace = -1;
        bool hasTabs = false;
        for(int i = 0; i < txt.length; i++) {
            if (txt[i] == '\t') {
                hasTabs = true;
            } else if (txt[i] != ' ') {
                if (firstNonSpace == -1)
                    firstNonSpace = i;
                lastNonSpace = i + 1;
            }
        }
        bool spacesOnly = txt.length > 0 && firstNonSpace < 0;
        if (firstNonSpace <= 0 && lastNonSpace >= txt.length && !hasTabs && !spacesOnly)
            return;
        uint color = addAlpha(textColor, 0xC0);
        static int[] textSizeBuffer;
        int charsMeasured = font.measureText(txt, textSizeBuffer, MAX_WIDTH_UNSPECIFIED, tabSize, 0, 0);
        int ts = tabSize;
        if (ts < 1)
            ts = 1;
        if (ts > 8)
            ts = 8;
        for (int i = 0; i < txt.length && i < charsMeasured; i++) {
            dchar ch = txt[i];
            bool outsideText = (i < firstNonSpace || i >= lastNonSpace || spacesOnly);
            if ((ch == ' ' && outsideText) || ch == '\t') {
                Rect rc = lineRect;
                rc.left = lineRect.left + (i > 0 ? textSizeBuffer[i - 1] : 0);
                rc.right = lineRect.left + textSizeBuffer[i];
                int h = rc.height;
                if (rc.intersects(visibleRect)) {
                    // draw space mark
                    if (ch == ' ') {
                        // space
                        int sz = h / 6;
                        if (sz < 1)
                            sz = 1;
                        rc.top += h / 2 - sz / 2;
                        rc.bottom = rc.top + sz;
                        rc.left += rc.width / 2 - sz / 2;
                        rc.right = rc.left + sz;
                        buf.fillRect(rc, color);
                    } else if (ch == '\t') {
                        // tab
                        Point p1 = Point(rc.left + 1, rc.top + h / 2);
                        Point p2 = p1;
                        p2.x = rc.right - 1;
                        int sz = h / 4;
                        if (sz < 2)
                            sz = 2;
                        if (sz > p2.x - p1.x)
                            sz = p2.x - p1.x;
                        buf.drawLine(p1, p2, color);
                        buf.drawLine(p2, Point(p2.x - sz, p2.y - sz), color);
                        buf.drawLine(p2, Point(p2.x - sz, p2.y + sz), color);
                    }
                }
            }
        }
    }

    /// Clear _span
    void resetVisibleSpans()
    {
        //TODO: Don't erase spans which have not been modified, cache them
        _span = [];
    }

    private bool _needRewrap = true;
    private int lastStartingLine;

    override protected void drawClient(DrawBuf buf) {
        // update matched braces
        if (!content.findMatchedBraces(_caretPos, _matchingBraces)) {
            _matchingBraces.start.line = -1;
            _matchingBraces.end.line = -1;
        }

        Rect rc = _clientRect;

        if (_contentChanged)
          _needRewrap = true;
        if (lastStartingLine != _firstVisibleLine)
        {
            _needRewrap = true;
            lastStartingLine = _firstVisibleLine;
        }
        if (rc.width <= 0 && _wordWrap)
        {
            //Prevent drawClient from getting stuck in loop
            return;
        }
        bool doRewrap = false;
        if (_needRewrap && _wordWrap)
        {
            resetVisibleSpans();
            _needRewrap = false;
            doRewrap = true;
        }

        FontRef font = font();
        int previousWraps;
        for (int i = 0; i < _visibleLines.length; i++) {
            dstring txt = _visibleLines[i];
            Rect lineRect;
            lineRect.left = _clientRect.left - _scrollPos.x;
            lineRect.right = lineRect.left + calcLineWidth(_content[_firstVisibleLine + i]);
            lineRect.top = _clientRect.top + i * _lineHeight;
            lineRect.bottom = lineRect.top + _lineHeight;
            Rect visibleRect = lineRect;
            visibleRect.left = _clientRect.left;
            visibleRect.right = _clientRect.right;
            drawLineBackground(buf, _firstVisibleLine + i, lineRect, visibleRect);
            if (_showTabPositionMarks)
                drawTabPositionMarks(buf, font, _firstVisibleLine + i, lineRect);
            if (!txt.length && !_wordWrap)
                continue;
            if (_showWhiteSpaceMarks)
            {
                Rect whiteSpaceRc = lineRect;
                Rect whiteSpaceRcVisible = visibleRect;
                for(int z; z < previousWraps; z++)
                {
                    whiteSpaceRc.offset(0, _lineHeight);
                    whiteSpaceRcVisible.offset(0, _lineHeight);
                }
                drawWhiteSpaceMarks(buf, font, txt, tabSize, whiteSpaceRc, whiteSpaceRcVisible);
            }
            if (_leftPaneWidth > 0) {
                Rect leftPaneRect = visibleRect;
                leftPaneRect.right = leftPaneRect.left;
                leftPaneRect.left -= _leftPaneWidth;
                drawLeftPane(buf, leftPaneRect, 0);
            }
            if (txt.length > 0 || _wordWrap) {
                CustomCharProps[] highlight = _visibleLinesHighlights[i];
                if (_wordWrap)
                {
                    dstring[] wrappedLine;
                    if (doRewrap)
                        wrappedLine = wrapLine(txt, _firstVisibleLine + i);
                    else
                        if (i < _span.length)
                            wrappedLine = _span[i].wrappedContent;
                    int accumulativeLength;
                    CustomCharProps[] wrapProps;
                    foreach (size_t q_, curWrap; wrappedLine)
                    {
                        int q = cast(int)q_;
                        auto lineOffset = q + i + wrapsUpTo(i + _firstVisibleLine);
                        if (highlight)
                        {
                            wrapProps = highlight[accumulativeLength .. $];
                            accumulativeLength += curWrap.length;
                            font.drawColoredText(buf, rc.left - _scrollPos.x, rc.top + lineOffset * _lineHeight, curWrap, wrapProps, tabSize);
                        }
                        else
                            font.drawText(buf, rc.left - _scrollPos.x, rc.top + lineOffset * _lineHeight, curWrap, textColor, tabSize);

                    }
                    previousWraps += to!int(wrappedLine.length - 1);
                }
                else
                {
                    if (highlight)
                        font.drawColoredText(buf, rc.left - _scrollPos.x, rc.top + i * _lineHeight, txt, highlight, tabSize);
                    else
                        font.drawText(buf, rc.left - _scrollPos.x, rc.top + i * _lineHeight, txt, textColor, tabSize);
                }
            }
        }

        drawCaret(buf);
    }

    protected override bool onLeftPaneMouseClick(MouseEvent event) {
        if (_leftPaneWidth <= 0)
            return false;
        Rect rc = _clientRect;
        FontRef font = font();
        int i = _firstVisibleLine;
        for (;;) {
            Rect lineRect = rc;
            lineRect.left = _clientRect.left - _leftPaneWidth;
            lineRect.right = _clientRect.left;
            lineRect.bottom = lineRect.top + _lineHeight;
            if (lineRect.top >= _clientRect.bottom)
                break;
            if (event.y >= lineRect.top && event.y < lineRect.bottom) {
                return handleLeftPaneMouseClick(event, lineRect, i);
            }
            i++;
            rc.top += _lineHeight;
        }
        return false;
    }

    override protected MenuItem getLeftPaneIconsPopupMenu(int line) {
        MenuItem menu = new MenuItem();
        Action toggleBookmarkAction = ACTION_EDITOR_TOGGLE_BOOKMARK.clone();
        toggleBookmarkAction.longParam = line;
        toggleBookmarkAction.objectParam = this;
        menu.add(toggleBookmarkAction);
        return menu;
    }

    protected FindPanel _findPanel;

    dstring selectionText(bool singleLineOnly = false) {
        TextRange range = _selectionRange;
        if (range.empty) {
            return null;
        }
        dstring res = getRangeText(range);
        if (singleLineOnly) {
            for (int i = 0; i < res.length; i++) {
                if (res[i] == '\n') {
                    res = res[0 .. i];
                    break;
                }
            }
        }
        return res;
    }

    protected void findNext(bool backward) {
        createFindPanel(false, false);
        _findPanel.findNext(backward);
        // don't change replace mode
    }

    protected void openFindPanel() {
        createFindPanel(false, false);
        _findPanel.replaceMode = false;
        _findPanel.activate();
    }

    protected void openReplacePanel() {
        createFindPanel(false, true);
        _findPanel.replaceMode = true;
        _findPanel.activate();
    }

    /// create find panel; returns true if panel was not yet visible
    protected bool createFindPanel(bool selectionOnly, bool replaceMode) {
        bool res = false;
        dstring txt = selectionText(true);
        if (!_findPanel) {
            _findPanel = new FindPanel(this, selectionOnly, replaceMode, txt);
            addPanel(_findPanel, EditorPanelPosition.Bottom);
            res = true;
        } else {
            if (_findPanel.visibility != Visibility.Visible) {
                _findPanel.visibility = Visibility.Visible;
                // a new scope or the panel's own match keeps the find text, else the selected text becomes it; the
                // scope comes first, as setting the text checks it (#1166, #1179)
                bool keepText = _findPanel.onReopen();
                if (txt.length && !keepText)
                    _findPanel.searchText = txt;
                res = true;
            }
        }
        if (!pos.empty)
            layout(pos);
        requestLayout();
        return res;
    }

    /// close find panel
    protected void closeFindPanel(bool hideOnly = true) {
        if (_findPanel) {
            setFocus();
            if (hideOnly) {
                _findPanel.visibility = Visibility.Gone;
            } else {
                removePanel(_findPanel);
                _findPanel = null;
            }
        }
    }

    /// Draw widget at its position to buffer
    override void onDraw(DrawBuf buf) {
        if (visibility != Visibility.Visible)
            return;
        super.onDraw(buf);
        foreach (ref p; _panels)
            if (p.widget.visibility == Visibility.Visible)
                p.widget.onDraw(buf);
    }

    protected Rect _lastPanelsContentRect;

    protected static struct EditorPanel {
        Widget widget;
        EditorPanelPosition position;
    }
    protected EditorPanel[] _panels;

    /**
     * Add a panel above or below the text (like the find / replace panel); the panel becomes a child of the editor.
     *
     * Top panels are stacked downward from the top edge, bottom panels upward from the bottom edge, in order
     * of adding. Panels with visibility Gone take no space.
     */
    void addPanel(Widget panel, EditorPanelPosition position = EditorPanelPosition.Bottom) {
        foreach (ref p; _panels) {
            if (p.widget is panel) {
                p.position = position;
                requestLayout();
                return;
            }
        }
        _panels ~= EditorPanel(panel, position);
        addChild(panel);
        requestLayout();
    }

    /// remove a panel added with addPanel; destroys it unless destroyPanel is false
    void removePanel(Widget panel, bool destroyPanel = true) {
        foreach (i, ref p; _panels) {
            if (p.widget is panel) {
                _panels = _panels[0 .. i] ~ _panels[i + 1 .. $];
                removeChild(panel);
                if (destroyPanel)
                    destroy(panel);
                requestLayout();
                return;
            }
        }
    }

    /// panels added with addPanel, in order of adding
    @property Widget[] panels() {
        Widget[] res;
        foreach (ref p; _panels)
            res ~= p.widget;
        return res;
    }

    /// called when a button of a message bar is clicked; action.stringParam is the message id
    Signal!EditorMessageActionHandler messageAction;

    /**
     * Show a message bar above (default) or below the text, with optional action buttons.
     *
     * A message with the same id is replaced. The bar doesn't take the keyboard focus. Button clicks go to
     * messageAction, then, if not handled, are dispatched as usual actions (so an application can handle them
     * in handleAction); action.stringParam is the message id. Buttons for StandardAction.Ignore (e.g.
     * ACTION_IGNORE) and StandardAction.Close, and the close button, hide the message; other buttons don't,
     * call hideMessage when done. Set dismissOnEscape on the result to let Escape dismiss the message.
     *
     * Params:
     *      id = message id, to replace or hide it later
     *      message = text; up to 3 lines, longer text ends with an ellipsis and is shown in full as a tooltip
     *      kind = info, warning or error: icon and colors
     *      actions = buttons, in this order
     *      position = above or below the text
     *      closeButton = show a close (x) button
     */
    EditorMessageBar showMessage(string id, dstring message, EditorMessageKind kind = EditorMessageKind.Info,
            const(Action)[] actions = null, EditorPanelPosition position = EditorPanelPosition.Top, bool closeButton = false) {
        EditorMessageBar bar = new EditorMessageBar(id, message, kind, actions, closeButton);
        bar._editor = this;
        bar._shownOrder = ++_messageShowCounter;
        // replace a message with the same id at the same place
        foreach (i, ref p; _panels) {
            EditorMessageBar old = cast(EditorMessageBar)p.widget;
            if (old && old.id == id) {
                p.widget = bar;
                p.position = position;
                addChild(bar);
                discardPanelLater(old);
                requestLayout();
                return bar;
            }
        }
        addPanel(bar, position);
        return bar;
    }

    /// hide and remove a message shown with showMessage (safe to call from its own button handler)
    void hideMessage(string id) {
        foreach (i, ref p; _panels) {
            EditorMessageBar bar = cast(EditorMessageBar)p.widget;
            if (bar && bar.id == id) {
                _panels = _panels[0 .. i] ~ _panels[i + 1 .. $];
                discardPanelLater(bar);
                requestLayout();
                return;
            }
        }
    }

    protected ulong _messageShowCounter;

    /// id of the message EditBox shows when another program changed or deleted its file (#1280)
    enum EXTERNAL_CHANGE_MESSAGE_ID = "external-change";
    /// id of the message EditBox shows when reloading, reading or saving the file after an external change failed
    enum EXTERNAL_CHANGE_ERROR_ID = "external-change-error";

    /**
    The mode of editors that don't set their own `externalChangeMode`. `ignore` by default: applications opt in,
    e.g. from their preferences, since existing ones may handle changed files themselves.
    */
    static __gshared ExternalChangeMode defaultExternalChangeMode = ExternalChangeMode.ignore;

    protected ExternalChangeMode _externalChangeMode;
    protected bool _externalChangeModeSet;
    protected ExternalChangeReaction _externalChangeShown; // the external change message shown, or none
    protected FileState _saveQuestionFileState; // the file when the save question was shown (#1290)

    /**
    What the editor does when another program changes its file (#1280): ignore it, show a message, or reload text
    without unsaved changes at once. Text with unsaved changes always gets a message (Reload / Keep mine), a
    deleted file too (Save / Keep). Default: `defaultExternalChangeMode`.
    */
    @property ExternalChangeMode externalChangeMode() const {
        return _externalChangeModeSet ? _externalChangeMode : defaultExternalChangeMode;
    }
    /// ditto
    @property EditBox externalChangeMode(ExternalChangeMode mode) {
        _externalChangeMode = mode;
        _externalChangeModeSet = true;
        if (mode == ExternalChangeMode.ignore)
            hideExternalChangeMessage();
        return this;
    }

    /**
    Checks whether another program changed the file of the content (`EditableContent.checkExternalChange()`) and
    reacts as `externalChangeMode` says: reloads the text, or shows a message (#1280). Called when the editor gets
    the focus, which includes the activation of its window; applications call it for editors that are visible
    without the focus, or when a tab is selected.
    */
    FileChangeKind checkExternalChange() {
        if (externalChangeMode == ExternalChangeMode.ignore || !_content.fileState.path.length) {
            hideExternalChangeMessage(); // e.g. the mode was switched off while a message was shown
            return FileChangeKind.unchanged;
        }
        FileChangeKind kind = _content.checkExternalChange();
        applyExternalChangeReaction(externalChangeReaction(kind, _content.modified, externalChangeMode, false));
        return kind;
    }

    /**
    Call before saving the text to its file (the file it was loaded from): false if another program changed the file
    since it was loaded or saved, after showing a message (Overwrite / Reload / Cancel; Escape cancels); Overwrite
    saves with `saveAfterExternalChange()`, unless the application handles `EditorActions.SaveFile` in
    `messageAction` with its own save.
    */
    bool checkBeforeSave() {
        if (externalChangeMode == ExternalChangeMode.ignore || !_content.fileState.path.length) {
            hideExternalChangeMessage();
            return true;
        }
        FileChangeKind kind = _content.checkExternalChange();
        ExternalChangeReaction reaction = externalChangeReaction(kind, _content.modified, externalChangeMode, true);
        applyExternalChangeReaction(reaction);
        return reaction != ExternalChangeReaction.confirmSave;
    }

    /// the text of an external change message
    protected dstring externalChangeMessage(ExternalChangeReaction reaction) {
        switch (reaction) {
            case ExternalChangeReaction.notifyChanged:
                return UIString.fromId("EXTERNAL_CHANGE_CHANGED"c).value;
            case ExternalChangeReaction.notifyConflict:
                return UIString.fromId("EXTERNAL_CHANGE_CONFLICT"c).value;
            case ExternalChangeReaction.notifyDeleted:
                return UIString.fromId("EXTERNAL_CHANGE_DELETED"c).value;
            case ExternalChangeReaction.confirmSave:
                return UIString.fromId("EXTERNAL_CHANGE_BEFORE_SAVE"c).value;
            default:
                return null;
        }
    }

    /// the buttons of an external change message; override to add own ones (e.g. Close), handled in messageAction
    protected const(Action)[] externalChangeActions(ExternalChangeReaction reaction) {
        switch (reaction) {
            case ExternalChangeReaction.notifyChanged:
                return [ACTION_EDITOR_RELOAD_FILE, ACTION_IGNORE];
            case ExternalChangeReaction.notifyConflict:
                return [ACTION_EDITOR_RELOAD_FILE, ACTION_EDITOR_KEEP_MY_TEXT];
            case ExternalChangeReaction.notifyDeleted:
                return [ACTION_EDITOR_SAVE_FILE, ACTION_EDITOR_KEEP_TEXT];
            case ExternalChangeReaction.confirmSave:
                return [ACTION_EDITOR_OVERWRITE_FILE, ACTION_EDITOR_RELOAD_FILE, ACTION_CANCEL];
            default:
                return null;
        }
    }

    /**
    Writes the text to its file for the Save and Overwrite buttons of the external change message: the content's
    save by default; editors with their own save (SourceEdit) override it, so their subclasses' saves run.
    */
    protected bool saveAfterExternalChange() {
        return _content.save();
    }

    protected void applyExternalChangeReaction(ExternalChangeReaction reaction) {
        if (findMessage(EXTERNAL_CHANGE_MESSAGE_ID) && _externalChangeShown == ExternalChangeReaction.confirmSave
                && keepsExternalChangeMessage(_externalChangeShown, reaction,
                    _saveQuestionFileState.sameAs(FileState.read(_content.fileState.path))))
            return; // the save question stays (#1290)
        final switch (reaction) {
            case ExternalChangeReaction.none:
                hideExternalChangeMessage(); // an error message stays until the user closes it
                break;
            case ExternalChangeReaction.reload:
                hideExternalChangeMessage();
                reloadAfterExternalChange();
                break;
            case ExternalChangeReaction.notifyChanged:
            case ExternalChangeReaction.notifyConflict:
            case ExternalChangeReaction.notifyDeleted:
            case ExternalChangeReaction.confirmSave:
                if (reaction == ExternalChangeReaction.confirmSave) // asked again: about the file as it is now
                    _saveQuestionFileState = FileState.read(_content.fileState.path);
                if (_externalChangeShown == reaction && findMessage(EXTERNAL_CHANGE_MESSAGE_ID))
                    break; // shown already: not replaced on each check
                EditorMessageKind kind = reaction == ExternalChangeReaction.notifyChanged
                    ? EditorMessageKind.Info : EditorMessageKind.Warning;
                hideExternalChangeError();
                EditorMessageBar bar = showMessage(EXTERNAL_CHANGE_MESSAGE_ID, externalChangeMessage(reaction), kind,
                        externalChangeActions(reaction));
                // Escape cancels a pending save; the other choices are never made by Escape
                bar.dismissOnEscape = reaction == ExternalChangeReaction.confirmSave;
                _externalChangeShown = reaction;
                break;
        }
    }

    protected void reloadAfterExternalChange() {
        if (_content.reload(this))
            hideExternalChangeError();
        else
            showExternalChangeError("EXTERNAL_CHANGE_RELOAD_FAILED"c);
    }

    protected void hideExternalChangeMessage() {
        if (findMessage(EXTERNAL_CHANGE_MESSAGE_ID))
            hideMessage(EXTERNAL_CHANGE_MESSAGE_ID);
        _externalChangeShown = ExternalChangeReaction.none;
    }

    // an error after an external change: its own message, closed by the user (the next check doesn't hide it)
    protected void showExternalChangeError(string messageId) {
        hideExternalChangeMessage();
        showMessage(EXTERNAL_CHANGE_ERROR_ID, UIString.fromId(messageId).value, EditorMessageKind.Error, null,
                EditorPanelPosition.Top, true);
    }

    protected void hideExternalChangeError() {
        if (findMessage(EXTERNAL_CHANGE_ERROR_ID))
            hideMessage(EXTERNAL_CHANGE_ERROR_ID);
    }

    /// handles a button of the external change message that messageAction didn't handle; true if handled
    protected bool handleExternalChangeAction(const Action action) {
        ExternalChangeReaction shown = _externalChangeShown;
        int id = action.id;
        if (id == StandardAction.Ignore && shown == ExternalChangeReaction.confirmSave)
            id = StandardAction.Cancel; // Escape on the save question
        if (id == StandardAction.Cancel) {
            hideExternalChangeMessage();
            return true;
        }
        if (id != EditorActions.ReloadFile && id != EditorActions.KeepFileText && id != EditorActions.SaveFile
                && id != StandardAction.Ignore)
            return false;
        // the message may be stale (another editor of the content handled it, the file is back as it was, the
        // mode was switched off): act only if the file still differs
        if (externalChangeMode == ExternalChangeMode.ignore
                || _content.checkExternalChange() == FileChangeKind.unchanged) {
            hideExternalChangeMessage();
            return true;
        }
        hideExternalChangeMessage();
        if (id == EditorActions.ReloadFile) {
            reloadAfterExternalChange();
        } else if (id == EditorActions.SaveFile) {
            if (saveAfterExternalChange())
                hideExternalChangeError();
            else
                showExternalChangeError("EXTERNAL_CHANGE_SAVE_FAILED"c);
        } else {
            // Keep, Keep mine, Ignore: the file as it is now is the baseline, the message doesn't come back for it
            if (_content.acceptExternalState())
                hideExternalChangeError();
            else
                showExternalChangeError("EXTERNAL_CHANGE_RELOAD_FAILED"c);
        }
        return true;
    }

    protected ulong _externalChangeCheckTimer;

    /// checks the file when the editor gets the focus (also when its window is activated, #1280): right after the
    /// focus change, so a reload doesn't happen in the middle of a click or of the window's focus handling
    override protected void handleFocusChange(bool focused, bool receivedFocusFromKeyboard = false) {
        super.handleFocusChange(focused, receivedFocusFromKeyboard);
        if (focused && !_externalChangeCheckTimer && externalChangeMode != ExternalChangeMode.ignore
                && _content.fileState.path.length && window)
            _externalChangeCheckTimer = setTimer(1);
    }


    /// Escape closes the find panel if it's open, else dismisses the most recently shown message bar
    /// with dismissOnEscape set (one per key press)
    override bool onKeyEvent(KeyEvent event) {
        if (event.keyCode == KeyCode.ESCAPE && !(event.flags & (KeyFlag.Control | KeyFlag.Alt | KeyFlag.Shift | KeyFlag.Menu))) {
            if (_findPanel && _findPanel.visibility == Visibility.Visible) {
                if (event.action == KeyAction.KeyDown)
                    _findPanel.close();
                return true;
            }
            EditorMessageBar target;
            foreach (ref p; _panels) {
                EditorMessageBar bar = cast(EditorMessageBar)p.widget;
                if (bar && bar.dismissOnEscape && bar.visibility == Visibility.Visible
                        && (!target || bar._shownOrder > target._shownOrder))
                    target = bar;
            }
            if (target) {
                if (event.action == KeyAction.KeyDown)
                    target.onButton(ACTION_IGNORE); // reported to messageAction as Ignore, then hidden
                return true;
            }
        }
        return super.onKeyEvent(event);
    }

    /// returns a message shown with showMessage, or null
    EditorMessageBar findMessage(string id) {
        foreach (ref p; _panels) {
            EditorMessageBar bar = cast(EditorMessageBar)p.widget;
            if (bar && bar.id == id)
                return bar;
        }
        return null;
    }

    /// remove a widget which is no longer in _panels now, destroy it later
    /// (it may be in the middle of handling its own mouse event; the editor may be destroyed before that)
    protected void discardPanelLater(Widget w) {
        Window wnd = window;
        removeChild(w);
        if (wnd)
            wnd.executeInUiThread(delegate() { destroy(w); });
        else
            destroy(w);
    }

    /// handles a message bar button click: messageAction, then usual action dispatching
    protected bool onMessageAction(EditorMessageBar bar, const Action action) {
        bool dismiss = action.id == StandardAction.Ignore || action.id == StandardAction.Close;
        bool handled = messageAction.assigned && messageAction(this, bar.id, action);
        if (!handled && bar.id == EXTERNAL_CHANGE_MESSAGE_ID)
            handled = handleExternalChangeAction(action);
        if (!handled && !dismiss)
            handled = dispatchAction(action);
        if (dismiss) {
            // Ignore and Close are never dispatched further (Close could close a tab or window)
            if (bar.id == EXTERNAL_CHANGE_MESSAGE_ID)
                hideExternalChangeMessage(); // also forgets which message it was
            else
                hideMessage(bar.id);
        }
        return handled || dismiss;
    }
}

/// Read only edit box for displaying logs with lines append operation
class LogWidget : EditBox {

    protected int  _maxLines;
    /// max lines to show (when appended more than max lines, older lines will be truncated), 0 means no limit
    @property int maxLines() { return _maxLines; }
    /// set max lines to show (when appended more than max lines, older lines will be truncated), 0 means no limit
    @property void maxLines(int n) { _maxLines = n; }

    protected bool _scrollLock;
    /// when true, automatically scrolls down when new lines are appended (usually being reset by scrollbar interaction)
    @property bool scrollLock() { return _scrollLock; }
    /// when true, automatically scrolls down when new lines are appended (usually being reset by scrollbar interaction)
    @property void scrollLock(bool flg) { _scrollLock = flg; }

    this() {
        this(null);
    }

    this(string ID) {
        super(ID);
        styleId = STYLE_LOG_WIDGET;
        _scrollLock = true;
        _enableScrollAfterText = false;
        enabled = false;
        minFontSize(pointsToPixels(6)).maxFontSize(pointsToPixels(32)); // allow font zoom with Ctrl + MouseWheel
        onThemeChanged();
    }

    /// append lines to the end of text
    void appendText(dstring text) {
        import std.array : split;
        if (text.length == 0)
            return;
        dstring[] lines = text.split("\n");
        //lines ~= ""d; // append new line after last line
        content.appendLines(lines);
        if (_maxLines > 0 && lineCount > _maxLines) {
            TextRange range;
            range.end.line = lineCount - _maxLines;
            EditOperation op = new EditOperation(EditAction.Replace, range, [""d]);
            _content.performOperation(op, this);
            _contentChanged = true;
        }
        updateScrollBars();
        if (_scrollLock) {
            _caretPos = lastLineBegin();
            ensureCaretVisible();
        }
    }

    TextPosition lastLineBegin() {
        TextPosition res;
        if (_content.length == 0)
            return res;
        if (_content.lineLength(_content.length - 1) == 0 && _content.length > 1)
            res.line = _content.length - 2;
        else
            res.line = _content.length - 1;
        return res;
    }

    /// Set widget rectangle to specified value and layout widget contents. (Step 2 of two phase layout).
    override void layout(Rect rc) {
        if (visibility == Visibility.Gone)
            return;

        super.layout(rc);
        if (_scrollLock) {
            measureVisibleText();
            _caretPos = lastLineBegin();
            ensureCaretVisible();
        }
    }

}

class FindPanel : HorizontalLayout {
    protected EditBox _editor;
    protected EditLine _edFind;
    protected EditLine _edReplace;
    protected ImageCheckButton _cbCaseSensitive;
    protected ImageCheckButton _cbWholeWords;
    protected CheckBox _cbSelection;
    protected Button _btnFindNext;
    protected Button _btnFindPrev;
    protected Button _btnReplace;
    protected Button _btnReplaceAndFind;
    protected Button _btnReplaceAll;
    protected ImageButton _btnClose;
    protected bool _replaceMode;
    /// the text searched in when the Selection option is on: the selection when the option was turned on, which
    /// becomes empty when replacements remove all its text (#1166)
    protected TextRange _selectionScope;
    /// EditableContent.revision for which _selectionScope is valid: another change of the text drops the scope
    protected ulong _selectionScopeRevision;
    /// the match the panel selected last: not a new scope when the panel is shown again (#1166)
    protected TextRange _lastFoundMatch;
    /// EditableContent.revision for which _lastFoundMatch is valid
    protected ulong _lastFoundMatchRevision;
    /// returns true if panel is working in replace mode
    @property bool replaceMode() { return _replaceMode; }
    @property FindPanel replaceMode(bool newMode) {
        if (newMode != _replaceMode) {
            _replaceMode = newMode;
            childById("replace").visibility = newMode ? Visibility.Visible : Visibility.Gone;
        }
        return this;
    }

    @property dstring searchText() {
        return _edFind.text;
    }

    @property FindPanel searchText(dstring newText) {
        _edFind.text = newText;
        return this;
    }

    this(EditBox editor, bool selectionOnly, bool replace, dstring initialText = ""d) {
        _replaceMode = replace;
        import dlangui.dml.parser;
        try {
            parseML(q{
                {
                    layoutWidth: fill
                    VerticalLayout {
                        layoutWidth: fill
                        HorizontalLayout {
                            layoutWidth: fill
                            EditLine { id: edFind; layoutWidth: fill; alignment: vcenter }
                            Button { id: btnFindNext; text: EDIT_FIND_NEXT }
                            Button { id: btnFindPrev; text: EDIT_FIND_PREV }
                            VerticalLayout {
                                VSpacer {}
                                HorizontalLayout {
                                    ImageCheckButton { id: cbCaseSensitive; drawableId: "find_case_sensitive"; tooltipText: EDIT_FIND_CASE_SENSITIVE; styleId: TOOLBAR_BUTTON; alignment: vcenter }
                                    ImageCheckButton { id: cbWholeWords; drawableId: "find_whole_words"; tooltipText: EDIT_FIND_WHOLE_WORDS; styleId: TOOLBAR_BUTTON; alignment: vcenter }
                                    CheckBox { id: cbSelection; text: "Sel" }
                                }
                                VSpacer {}
                            }
                        }
                        HorizontalLayout {
                            id: replace
                            layoutWidth: fill;
                            EditLine { id: edReplace; layoutWidth: fill; alignment: vcenter }
                            Button { id: btnReplace; text: EDIT_REPLACE_NEXT }
                            Button { id: btnReplaceAndFind; text: EDIT_REPLACE_AND_FIND }
                            Button { id: btnReplaceAll; text: EDIT_REPLACE_ALL }
                        }
                    }
                    VerticalLayout {
                        VSpacer {}
                        ImageButton { id: btnClose; drawableId: close; styleId: BUTTON_TRANSPARENT }
                        VSpacer {}
                    }
                }
            }, null, this);
        } catch (Exception e) {
            Log.e("Exception while parsing DML: ", e);
        }
        _editor = editor;
        _edFind = childById!EditLine("edFind");
        _edReplace = childById!EditLine("edReplace");

        if (initialText.length) {
            _edFind.text = initialText;
            _edReplace.text = initialText;
        }

        _edFind.editorAction.connect(&onFindEditorAction);
        _edFind.contentChange.connect(&onFindTextChange);

        //_edFind.keyEvent = &onEditorKeyEvent;
        //_edReplace.keyEvent = &onEditorKeyEvent;

        _btnFindNext = childById!Button("btnFindNext");
        _btnFindNext.click = &onButtonClick;
        _btnFindPrev = childById!Button("btnFindPrev");
        _btnFindPrev.click = &onButtonClick;
        _btnReplace = childById!Button("btnReplace");
        _btnReplace.click = &onButtonClick;
        _btnReplaceAndFind = childById!Button("btnReplaceAndFind");
        _btnReplaceAndFind.click = &onButtonClick;
        _btnReplaceAll = childById!Button("btnReplaceAll");
        _btnReplaceAll.click = &onButtonClick;
        _btnClose = childById!ImageButton("btnClose");
        _btnClose.click = &onButtonClick;
        _cbCaseSensitive = childById!ImageCheckButton("cbCaseSensitive");
        _cbWholeWords = childById!ImageCheckButton("cbWholeWords");
        _cbSelection =  childById!CheckBox("cbSelection");
        if (selectionOnly && !editor.selectionRange.empty) {
            _cbSelection.checked = true;
            setSelectionScope(editor.selectionRange);
        }
        _cbCaseSensitive.checkChange = &onCaseSensitiveCheckChange;
        _cbWholeWords.checkChange = &onCaseSensitiveCheckChange;
        _cbSelection.checkChange = &onSelectionCheckChange;
        focusGroup = true;
        if (!replace)
            childById("replace").visibility = Visibility.Gone;
        //_edFind = new EditLine("edFind"
        dstring currentText = _edFind.text;
        Log.d("currentText=", currentText);
        setDirection(false);
        updateHighlight();
    }
    void activate() {
        _edFind.setFocus();
        dstring currentText = _edFind.text;
        Log.d("activate.currentText=", currentText);
        _edFind.setCaretPos(0, cast(int)currentText.length, true);
    }

    bool onButtonClick(Widget source) {
        switch (source.id) {
            case "btnFindNext":
                findNext(false);
                return true;
            case "btnFindPrev":
                findNext(true);
                return true;
            case "btnClose":
                close();
                return true;
            case "btnReplace":
                replaceOne();
                return true;
            case "btnReplaceAndFind":
                replaceAndFind();
                return true;
            case "btnReplaceAll":
                replaceAll();
                return true;
            default:
                return true;
        }
    }

    void close() {
        _editor.setTextToHighlight(null, 0);
        _editor.closeFindPanel();
    }

    override bool onKeyEvent(KeyEvent event) {
        if (event.keyCode == KeyCode.TAB)
            return super.onKeyEvent(event);
        if (event.action == KeyAction.KeyDown && event.keyCode == KeyCode.ESCAPE) {
            close();
            return true;
        }
        return true;
    }

    /// override to handle specific actions
    override bool handleAction(const Action a) {
        switch (a.id) {
            case EditorActions.FindNext:
                findNext(false);
                return true;
            case EditorActions.FindPrev:
                findNext(true);
                return true;
            default:
                return false;
        }
    }

    protected bool _backDirection;
    void setDirection(bool back) {
        _backDirection = back;
        if (back) {
            _btnFindNext.resetState(State.Default);
            _btnFindPrev.setState(State.Default);
        } else {
            _btnFindNext.setState(State.Default);
            _btnFindPrev.resetState(State.Default);
        }
    }

    uint makeSearchFlags() {
        uint res = 0;
        if (_cbCaseSensitive.checked)
            res |= TextSearchFlag.CaseSensitive;
        if (_cbWholeWords.checked)
            res |= TextSearchFlag.WholeWords;
        if (_cbSelection.checked)
            res |= TextSearchFlag.SelectionOnly;
        return res;
    }
    /// the matches of text in the editor, only those inside the selection scope when the Selection option is on
    protected TextRange[] findMatches(dstring text, uint flags) {
        TextRange[] all = _editor.findAll(text, flags);
        if (flags & TextSearchFlag.SelectionOnly)
            return matchesInScope(all, _selectionScope);
        return all;
    }

    /// the search scope of the Selection option, valid for the current text (#1166)
    protected void setSelectionScope(TextRange scope_) {
        _selectionScope = scope_;
        _selectionScopeRevision = _editor.content.revision;
    }

    /// turns the Selection option off (dropping its scope) when the text changed other than by this panel's
    /// replacements, e.g. typing, undo or other content: the scope may refer to other text (#1166). True if it was
    /// dropped: an operation is then skipped once, rather than done in the whole text
    protected bool checkSelectionScope() {
        if (!_cbSelection.checked || _editor.content.revision == _selectionScopeRevision)
            return false;
        _cbSelection.checked = false; // onSelectionCheckChange() drops the scope and updates the highlight
        return true;
    }

    /// the panel is shown again: as decided by reopenDecision(), sets a new scope; returns true if the find text
    /// should stay (#1166, #1179)
    bool onReopen() {
        TextRange selection = _editor.selectionRange;
        bool newScope;
        bool keepText;
        reopenDecision(selection, _lastFoundMatch, _lastFoundMatchRevision == _editor.content.revision,
            _cbSelection.checked, _edFind.text.length > 0, newScope, keepText);
        if (newScope)
            setSelectionScope(selection);
        updateHighlight();
        return keepText;
    }

    /// what showing the panel again does with the selection (#1166, #1179). The panel's own match is lastFound while
    /// the text didn't change since it was found (lastFoundValid), e.g. F3 after Esc: it keeps the scope. A new
    /// selection becomes the scope (newScope) with the Selection option on. No selection keeps the scope. keepText:
    /// the find text stays when the selection is the new scope or the panel's own match (its case may differ from the
    /// find text), unless the find text is empty; else the selected text becomes the find text
    static void reopenDecision(TextRange selection, TextRange lastFound, bool lastFoundValid, bool selectionOption,
            bool hasFindText, out bool newScope, out bool keepText) @safe pure nothrow @nogc {
        bool ownMatch = !selection.empty && lastFoundValid && selection == lastFound;
        newScope = selectionOption && !selection.empty && !ownMatch;
        keepText = hasFindText && (ownMatch || newScope);
    }

    /// highlights the matches of text, inside the selection scope when the Selection option is on
    protected void highlight(dstring text, uint flags) {
        _editor.setTextToHighlight(text, flags,
            (flags & TextSearchFlag.SelectionOnly) ? _selectionScope : WHOLE_TEXT_RANGE, _backDirection);
    }

    /// matches inside scope_ (none if it is empty) (#1166)
    static TextRange[] matchesInScope(TextRange[] matches, TextRange scope_) @safe pure nothrow {
        TextRange[] res;
        foreach (r; matches)
            if (r.start >= scope_.start && r.end <= scope_.end)
                res ~= r;
        return res;
    }

    /// scope_ after replacing the text of replaced, inside it, with newLength characters on the same line: an end on
    /// that line moves (#1166)
    static TextRange scopeAfterReplace(TextRange scope_, TextRange replaced, size_t newLength) @safe pure nothrow @nogc {
        if (!scope_.empty && replaced.end.line == scope_.end.line && replaced.end <= scope_.end)
            scope_.end.pos += cast(int)newLength - (replaced.end.pos - replaced.start.pos);
        return scope_;
    }

    bool findNext(bool back) {
        setDirection(back);
        dstring currentText = _edFind.text;
        Log.d("findNext text=", currentText, " back=", back);
        if (!currentText.length || checkSelectionScope())
            return false;
        uint flags = makeSearchFlags;
        highlight(currentText, flags);
        TextRange[] all = findMatches(currentText, flags);
        ptrdiff_t index = EditBox.nextMatchIndex(all, _editor.selectionRange, _editor.caretPos, back ? -1 : 1);
        if (index < 0)
            return false;
        _editor.selectionRange = all[index];
        _lastFoundMatch = all[index];
        _lastFoundMatchRevision = _editor.content.revision;
        _editor.ensureCaretVisible();
        return true;
    }

    /// replaces the selected match: false if the selection isn't a match. Leaves the caret after the replacement
    /// (before it when searching back) with nothing selected, so that Find next goes on from there (#1164). The
    /// caller checks the selection scope first (checkSelectionScope())
    protected bool replaceSelectedMatch() {
        dstring currentText = _edFind.text;
        dstring newText = _edReplace.text;
        if (!currentText.length)
            return false;
        uint flags = makeSearchFlags;
        TextRange selection = _editor.selectionRange;
        foreach (r; findMatches(currentText, flags)) {
            if (r != selection)
                continue;
            _editor.replaceSelectionText(newText); // the caret is at the end of the replacement, nothing selected
            setSelectionScope(scopeAfterReplace(_selectionScope, r, newText.length));
            if (_backDirection) {
                _editor.setCaretPos(r.start.line, r.start.pos);
                // the empty selection at the caret, not at the end of the replacement; notified again, so that
                // listeners see the final state
                _editor.clearSelection();
                _editor.handleEditorStateChange();
            }
            _editor.ensureCaretVisible();
            highlight(currentText, flags);
            return true;
        }
        return false;
    }

    /// replaces the selected match; without one, selects the next match in the search direction, which the next
    /// Replace replaces: only a match shown as selected is replaced (#1164)
    bool replaceOne() {
        Log.d("replaceOne text=", _edFind.text, " back=", _backDirection, " newText=", _edReplace.text);
        if (checkSelectionScope())
            return false;
        if (replaceSelectedMatch())
            return true;
        return findNext(_backDirection);
    }

    /// replaces the selected match, if any, and selects the next match in the search direction (#1164)
    bool replaceAndFind() {
        if (checkSelectionScope())
            return false;
        replaceSelectedMatch();
        return findNext(_backDirection);
    }

    int replaceAll() {
        dstring currentText = _edFind.text;
        dstring newText = _edReplace.text;
        debug Log.d("replaceAll text=", currentText, " newText=", newText);
        if (!currentText.length || checkSelectionScope())
            return 0;
        uint flags = makeSearchFlags;
        highlight(currentText, flags);
        // all matches in the whole text (or in the selection), collected up front and replaced from the last
        // to the first, so that earlier positions stay valid; before, it started at the caret and stopped
        // when the search wrapped around, missing the matches before the caret
        TextRange[] all = findMatches(currentText, flags); // in the selection scope, not the selection (#1166)
        TextRange scope_ = _selectionScope;
        foreach_reverse (r; all) {
            _editor.selectionRange = r;
            _editor.replaceSelectionText(newText);
            scope_ = scopeAfterReplace(scope_, r, newText.length);
        }
        if (all.length) {
            setSelectionScope(scope_);
            // the last replacement made was the first match: the caret is after it, nothing selected, so that the
            // next Replace doesn't replace it again (#1164)
            _editor.ensureCaretVisible();
            highlight(currentText, flags);
        }
        debug Log.d("replaceAll - done, replace count = ", all.length);
        return cast(int)all.length;
    }

    void updateHighlight() {
        dstring currentText = _edFind.text;
        Log.d("onFindTextChange.currentText=", currentText);
        checkSelectionScope();
        highlight(currentText, makeSearchFlags);
    }

    void onFindTextChange(EditableContent source) {
        Log.d("onFindTextChange");
        updateHighlight();
    }

    bool onCaseSensitiveCheckChange(Widget source, bool checkValue) {
        updateHighlight();
        return true;
    }

    /// the Selection option keeps the selection it was turned on with as the search scope, Find next selecting
    /// matches doesn't change it; it needs a selection (#1166)
    bool onSelectionCheckChange(Widget source, bool checkValue) {
        if (checkValue && _editor.selectionRange.empty) {
            _cbSelection.checked = false; // calls this again
            return true;
        }
        setSelectionScope(checkValue ? _editor.selectionRange : TextRange.init);
        updateHighlight();
        return true;
    }

    bool onFindEditorAction(const Action action) {
        Log.d("onFindEditorAction ", action);
        if (action.id == EditorActions.InsertNewLine) {
            findNext(_backDirection);
            return true;
        }
        return false;
    }
}

/**
 * Message bar shown above or below the text of an EditBox (see EditBox.showMessage):
 * kind icon, message text (up to 3 lines), action buttons, optional close button.
 */
class EditorMessageBar : HorizontalLayout {
    protected EditBox _editor;
    protected ulong _shownOrder;
    protected bool _dismissOnEscape;
    protected EditorMessageKind _kind;
    protected ImageWidget _icon;
    protected TextWidget _text;

    this(string id, dstring message, EditorMessageKind kind = EditorMessageKind.Info, const(Action)[] actions = null, bool closeButton = false) {
        super(id);
        _kind = kind;
        final switch (kind) {
            case EditorMessageKind.Info: styleId = STYLE_EDIT_MESSAGE_BAR_INFO; break;
            case EditorMessageKind.Warning: styleId = STYLE_EDIT_MESSAGE_BAR_WARNING; break;
            case EditorMessageKind.Error: styleId = STYLE_EDIT_MESSAGE_BAR_ERROR; break;
        }
        layoutWidth = FILL_PARENT;
        static if (BACKEND_GUI) {
            string iconId = kind == EditorMessageKind.Error ? "dialog-error" : (kind == EditorMessageKind.Warning ? "dialog-warning" : "dialog-information");
            _icon = new ImageWidget("icon", iconId);
            _icon.styleId = STYLE_EDIT_MESSAGE_BAR_ICON;
            addChild(_icon);
        }
        _text = new MultilineTextWidget("text", message);
        _text.styleId = STYLE_EDIT_MESSAGE_BAR_TEXT;
        _text.layoutWidth = FILL_PARENT;
        _text.maxLines = 3;
        _text.ellipsize = TextEllipsis.End;
        _text.fullTextTooltip = true;
        addChild(_text);
        // buttons, vertically centered (a child of a horizontal layout gets the whole height)
        HorizontalLayout buttons = new HorizontalLayout("buttons");
        foreach (a; actions)
            buttons.addChild(createButton(a));
        if (closeButton) {
            static if (BACKEND_GUI) {
                ImageButton btn = new ImageButton("close", "close");
                btn.styleId = STYLE_BUTTON_TRANSPARENT;
            } else {
                Button btn = new Button("close", "x"d);
                btn.styleId = STYLE_EDIT_MESSAGE_BAR_BUTTON;
            }
            btn.focusable = false;
            btn.tooltipText = UIString.fromId("ACTION_CLOSE", "Close"d);
            btn.click = delegate(Widget w) { return onButton(ACTION_CLOSE); };
            buttons.addChild(btn);
        }
        if (buttons.childCount) {
            VerticalLayout column = new VerticalLayout();
            column.addChild(new VSpacer().minHeight(0)); // no extra height
            column.addChild(buttons);
            column.addChild(new VSpacer().minHeight(0));
            addChild(column);
        } else {
            destroy(buttons);
        }
    }

    /// creates a button for an action (in its own function: delegates created in a loop would share the loop variable)
    protected Button createButton(const Action action) {
        Button btn = new Button(action);
        btn.styleId = STYLE_EDIT_MESSAGE_BAR_BUTTON;
        btn.focusable = false; // keep the focus in the editor
        btn.click = delegate(Widget w) { return onButton(action); };
        return btn;
    }

    /// message kind
    @property EditorMessageKind kind() { return _kind; }

    /**
     * When true, Escape pressed in the editor dismisses this message (the most recently shown one first),
     * reported to EditBox.messageAction as ACTION_IGNORE. Off by default: leave it off for messages
     * which need a decision.
     */
    @property bool dismissOnEscape() { return _dismissOnEscape; }
    /// ditto
    @property EditorMessageBar dismissOnEscape(bool flag) { _dismissOnEscape = flag; return this; }

    /// message text
    @property dstring message() { return _text.text; }
    /// ditto (can be changed while the bar is shown)
    @property EditorMessageBar message(dstring text) {
        _text.text = text;
        requestLayout();
        return this;
    }

    /// editor showing this message (null if not shown with EditBox.showMessage)
    @property EditBox editor() { return _editor; }

    /// measure: the text wraps in the width left after the icon and the buttons (LinearLayout measures
    /// each child with the whole width, which would give too few lines and a too low bar)
    override void measure(int parentWidth, int parentHeight) {
        super.measure(parentWidth, parentHeight);
        if (parentWidth == SIZE_UNSPECIFIED || visibility == Visibility.Gone)
            return;
        Rect m = margins;
        Rect p = padding;
        int avail = parentWidth - m.left - m.right - p.left - p.right;
        int others = 0;
        int height = 0;
        for (int i = 0; i < childCount; i++) {
            Widget w = child(i);
            if (w is _text || w.visibility == Visibility.Gone)
                continue;
            others += w.measuredWidth;
            if (height < w.measuredHeight)
                height = w.measuredHeight;
        }
        int textWidth = avail - others;
        if (textWidth < 10)
            textWidth = 10;
        _text.measure(textWidth, parentHeight);
        if (height < _text.measuredHeight)
            height = _text.measuredHeight;
        measuredContent(parentWidth, parentHeight, others + _text.measuredWidth, height);
    }

    protected bool onButton(const Action a) {
        Action action = a.clone();
        action.stringParam = id;
        if (_editor)
            return _editor.onMessageAction(this, action);
        return dispatchAction(action);
    }
}

// case-insensitive search finds every match (#1144: Phobos indexOf with No.caseSensitive missed matches when a pattern
// character equals the last one in another case)
@safe unittest {
    alias find = EditBox.indexOfPattern;
    assert(find("    TextWidget {"d, "Text"d, false) == 4);
    assert(find("    TextWidget {"d, "text"d, false) == 4);
    assert(find("    TextWidget {"d, "TEXTWIDGET"d, false) == 4);
    assert(find("    TextWidget {"d, "text"d, true) == -1);
    assert(find("    TextWidget {"d, "Text"d, true) == 4);
    assert(find("abcdText"d, "tExT"d, false) == 4);
    assert(find("aXa"d, "xa"d, false) == 1);
    assert(find("Привет, ПРИВЕТ"d, "привет"d, false) == 0);
    assert(find("Привет, ПРИВЕТ"d, "ПРИВЕТ"d, true) == 8);
    assert(find("text"d, "texts"d, false) == -1);
    assert(find("tex"d, "text"d, false) == -1);
    assert(find("abc"d, "d"d, false) == -1);
    assert(find("οδος"d, "ΟΔΟΣ"d, false) == 0); // final sigma, simple case folding
    assert(find("abc"d, ""d, false) == 0);
    assert(find(""d, ""d, false) == 0);
    assert(find(""d, ""d, true) == 0);
}

// of two adjacent search matches, only one is current: the selected one, else the one Find next and Replace take
// (#1145, #1165, #1177); with a scope, only the matches inside it (#1166)
unittest {
    // positions of the matches of "aa" in "aaaaaa", the current one marked with *
    static string matches(TextRange selection, int caret, TextRange scope_ = WHOLE_TEXT_RANGE, bool back = false) {
        TextRange current;
        bool settled = EditBox.findCurrentMatch(1, (int line) => "aaaaaa"d, "aa"d, true, false, scope_, selection,
            TextPosition(0, caret), back, true, int.max, size_t.max, current);
        assert(settled);
        string res;
        EditBox.forEachLineMatch("aaaaaa"d, 0, "aa"d, true, false, scope_, current,
            (TextRange r, bool current) {
                import std.conv : to;
                res ~= (current ? "*" : "") ~ r.start.pos.to!string ~ " ";
            });
        return res;
    }
    static TextRange sel(int start, int end) { return TextRange(TextPosition(0, start), TextPosition(0, end)); }
    TextRange none;
    assert(matches(none, 0) == "*0 2 4 "); // at the start of the first match
    assert(matches(none, 2) == "0 *2 4 "); // at the end of the first match and the start of the second
    assert(matches(none, 3) == "0 *2 4 "); // inside the second match
    assert(matches(none, 6) == "*0 2 4 "); // after the last match: Find next wraps around to the first one
    // a selected match is current, wherever the caret is (Find next leaves it at the end, Shift+Left at the start)
    assert(matches(sel(0, 2), 2) == "*0 2 4 ");
    assert(matches(sel(2, 4), 2) == "0 *2 4 ");
    assert(matches(sel(2, 4), 4) == "0 *2 4 ");
    // a selection that isn't a match: the caret decides
    assert(matches(sel(1, 3), 3) == "0 *2 4 ");
    // the current match on another line than the caret (#1177): "foo foo" and "foo", the caret at the end of the
    // first line; Find next takes the match on the second line, Find prev from its start the second "foo" before it
    dstring[] lines = ["foo foo"d, "foo"d];
    TextRange[] foos;
    foreach (i, line; lines)
        EditBox.forEachLineMatch(line, cast(int)i, "foo"d, true, false, (TextRange r) { foos ~= r; });
    assert(foos.length == 3);
    assert(EditBox.currentMatchIndex(foos, none, TextPosition(0, 7)) == 2);
    assert(EditBox.currentMatchIndex(foos, none, TextPosition(1, 0), true) == 1);
    // a scope: the matches inside it, the current one among them
    assert(matches(none, 0, sel(2, 6)) == "*2 4 ");
    assert(matches(sel(0, 2), 2, sel(2, 6)) == "*2 4 "); // the selected match is outside the scope
    assert(matches(none, 0, sel(3, 3)) == ""); // an empty scope: no matches
    // searching back: the last match that starts before the caret
    assert(matches(none, 2, WHOLE_TEXT_RANGE, true) == "*0 2 4 "); // at the end of the first match
    assert(matches(none, 3, WHOLE_TEXT_RANGE, true) == "0 *2 4 "); // inside the second match
    assert(matches(none, 6, WHOLE_TEXT_RANGE, true) == "0 2 *4 "); // at the end of the line
    assert(matches(none, 0, WHOLE_TEXT_RANGE, true) == "0 2 *4 "); // at the start: Find prev wraps around
    assert(matches(sel(2, 4), 6, WHOLE_TEXT_RANGE, true) == "0 *2 4 "); // a selected match is current
    assert(matches(none, 6, sel(0, 4), true) == "0 *2 "); // the last one in the scope

    // the current match: the selected one, else the first one that ends after the caret, wrapping around
    TextRange[] all = [sel(0, 2), sel(2, 4), sel(4, 6)];
    assert(EditBox.currentMatchIndex(all, none, TextPosition(0, 2)) == 1);
    assert(EditBox.currentMatchIndex(all, sel(2, 4), TextPosition(0, 2)) == 1);
    assert(EditBox.currentMatchIndex(all, sel(1, 3), TextPosition(0, 3)) == 1);
    assert(EditBox.currentMatchIndex(all, none, TextPosition(1, 0)) == 0);
    assert(EditBox.currentMatchIndex(all, none, TextPosition(0, 2), true) == 0);
    assert(EditBox.currentMatchIndex(all, none, TextPosition(0, 0), true) == 2);
    assert(EditBox.currentMatchIndex(null, none, TextPosition(0, 0)) == -1);
    assert(EditBox.currentMatchIndex(all, sel(2, 4), TextPosition(0, 6), true) == 1);
    // Find next (1), Find prev (-1) and direction 0 from a selected match, with the caret at either end of it
    foreach (caret; [2, 4]) {
        assert(EditBox.nextMatchIndex(all, sel(2, 4), TextPosition(0, caret), 1) == 2);
        assert(EditBox.nextMatchIndex(all, sel(2, 4), TextPosition(0, caret), -1) == 0);
        assert(EditBox.nextMatchIndex(all, sel(2, 4), TextPosition(0, caret), 0) == 1);
    }
    // wrapping around
    assert(EditBox.nextMatchIndex(all, sel(4, 6), TextPosition(0, 6), 1) == 0);
    assert(EditBox.nextMatchIndex(all, sel(0, 2), TextPosition(0, 0), -1) == 2);
    // no current match: the nearest one after or before the caret
    TextRange[] spaced = [sel(0, 2), sel(5, 7)];
    assert(EditBox.nextMatchIndex(spaced, none, TextPosition(0, 3), 1) == 1);
    assert(EditBox.nextMatchIndex(spaced, none, TextPosition(0, 3), -1) == 0);
    // a single selected match stays selected
    assert(EditBox.nextMatchIndex(all[0 .. 1], sel(0, 2), TextPosition(0, 2), 1) == 0);
    assert(EditBox.nextMatchIndex(all[0 .. 1], sel(0, 2), TextPosition(0, 2), -1) == 0);
    assert(EditBox.nextMatchIndex(null, none, TextPosition(0, 0), 1) == -1);
}

// the current match found outward from the caret is the one currentMatchIndex() chooses among all matches, for every
// caret position, selection, direction and scope, also when the search may give up after a few lines (#1177)
unittest {
    static TextRange range(int startLine, int startPos, int endLine, int endPos) {
        return TextRange(TextPosition(startLine, startPos), TextPosition(endLine, endPos));
    }
    dstring[][] texts = [["foo foo"d, ""d, "xfoo foo"d, "foo"d], ["foofoo"d, "foo  foo"d, ""d, "fo"d, "foo"d],
        ["bar"d, "foo"d, "bar"d], ["bar"d]];
    TextRange[] scopes = [WHOLE_TEXT_RANGE, range(0, 2, 2, 5), range(1, 0, 1, 8), range(2, 1, 2, 1),
        range(5, 0, 9, 0)];
    foreach (lines; texts) {
        TextRange[] all;
        foreach (i, line; lines)
            EditBox.forEachLineMatch(line, cast(int)i, "foo"d, true, false, (TextRange r) { all ~= r; });
        foreach (scope_; scopes) {
            TextRange[] inScope = FindPanel.matchesInScope(all, scope_);
            // no selection, each match, and a selection that isn't a match
            TextRange[] selections = [TextRange.init, range(0, 1, 0, 4)] ~ all;
            foreach (selection; selections)
            foreach (back; [false, true])
            foreach (int line; 0 .. cast(int)lines.length + 1)
            foreach (int pos; 0 .. (line < lines.length ? cast(int)lines[line].length : 0) + 1) {
                TextPosition caret = TextPosition(line, pos);
                ptrdiff_t index = EditBox.currentMatchIndex(inScope, selection, caret, back);
                TextRange expected = index >= 0 ? inScope[index] : TextRange.init;
                TextRange found;
                bool settled = EditBox.findCurrentMatch(cast(int)lines.length, (int i) => lines[i], "foo"d, true,
                    false, scope_, selection, caret, back, true, int.max, size_t.max, found);
                assert(settled && found == expected);
                // a search that may give up: if it doesn't, the same match; else none
                settled = EditBox.findCurrentMatch(cast(int)lines.length, (int i) => lines[i], "foo"d, true, false,
                    scope_, selection, caret, back, true, 2, size_t.max, found);
                assert(found == (settled ? expected : TextRange.init));
            }
        }
    }
    // giving up after maxLines lines or maxChars characters searched outward from the caret
    dstring[] sparse = ["foo"d, "1234567890"d, ""d, ""d, ""d];
    static bool settles(dstring[] lines, int maxLines, size_t maxChars, out TextRange found) {
        return EditBox.findCurrentMatch(cast(int)lines.length, (int i) => lines[i], "foo"d, true, false,
            WHOLE_TEXT_RANGE, TextRange.init, TextPosition(1, 0), false, true, maxLines, maxChars, found);
    }
    TextRange found;
    assert(!settles(sparse, 3, size_t.max, found));
    assert(!settles(sparse, int.max, 10, found)); // the caret line alone has 10 characters
    assert(settles(sparse, 5, 13, found));
    assert(found == range(0, 0, 0, 3)); // wrapped around to the first line
}

// without anyLine (a highlight without Find next): only the selected match or one after the caret on its line (before
// it when searching back), never wrapping around (#1177)
unittest {
    static TextRange range(int startLine, int startPos, int endLine, int endPos) {
        return TextRange(TextPosition(startLine, startPos), TextPosition(endLine, endPos));
    }
    dstring[] lines = ["foo foo"d, "bar"d, "foo"d];
    static TextRange current(dstring[] lines, TextRange selection, int line, int pos, bool back) {
        TextRange res;
        // a single line searched, never giving up
        bool settled = EditBox.findCurrentMatch(cast(int)lines.length, (int i) => lines[i], "foo"d, true, false,
            WHOLE_TEXT_RANGE, selection, TextPosition(line, pos), back, false, 1, 1, res);
        assert(settled);
        return res;
    }
    TextRange none;
    assert(current(lines, none, 0, 0, false) == range(0, 0, 0, 3)); // the caret at a match
    assert(current(lines, none, 0, 3, false) == range(0, 4, 0, 7)); // the next one on the line
    assert(current(lines, none, 0, 7, false) == none); // after the last match of the line: not the one on line 2
    assert(current(lines, none, 1, 1, false) == none); // a line without matches
    assert(current(lines, none, 0, 7, true) == range(0, 4, 0, 7)); // searching back: the one before the caret
    assert(current(lines, none, 2, 0, true) == none); // before the first match of the line: not the ones on line 0
    assert(current(lines, range(2, 0, 2, 3), 0, 0, false) == range(2, 0, 2, 3)); // a selected match on another line
    assert(current(lines, range(0, 1, 0, 4), 1, 0, false) == none); // a selection that isn't a match
}

// without a selected match, Find next takes the match at or after the caret, Find prev the one at or before it,
// also the only match (#1165)
unittest {
    static TextRange sel(int start, int end) { return TextRange(TextPosition(0, start), TextPosition(0, end)); }
    static TextPosition at(int pos) { return TextPosition(0, pos); }
    TextRange none;
    TextRange[] spaced = [sel(2, 4), sel(8, 10)]; // "  aa    aa"
    alias next = EditBox.nextMatchIndex;
    assert(next(spaced, none, at(2), 1) == 0); // right before a match: that match
    assert(next(spaced, none, at(3), 1) == 0); // inside it
    assert(next(spaced, none, at(4), 1) == 1); // right after it: the next one
    assert(next(spaced, none, at(10), 1) == 0); // after the last one: wraps around
    assert(next(spaced, none, at(4), -1) == 0); // right after a match: that match
    assert(next(spaced, none, at(3), -1) == 0); // inside it
    assert(next(spaced, none, at(8), -1) == 0); // right before the second one: the first one
    assert(next(spaced, none, at(2), -1) == 1); // before the first one: wraps around
    // the only match, the caret inside it or at either end
    foreach (pos; [2, 3, 4]) {
        assert(next(spaced[0 .. 1], none, at(pos), 1) == 0);
        assert(next(spaced[0 .. 1], none, at(pos), -1) == 0);
    }
    // a selected match: one step from it
    assert(next(spaced, sel(2, 4), at(4), 1) == 1);
    assert(next(spaced, sel(8, 10), at(10), -1) == 0);
}

// the Selection option limits the search to the selection it was turned on with, which follows replacements on its
// last line (#1166)
unittest {
    static TextRange range(int startLine, int startPos, int endLine, int endPos) {
        return TextRange(TextPosition(startLine, startPos), TextPosition(endLine, endPos));
    }
    TextRange scope_ = range(1, 0, 3, 5);
    TextRange[] all = [range(0, 2, 0, 4), range(1, 0, 1, 2), range(2, 3, 2, 5), range(3, 3, 3, 5), range(3, 6, 3, 8)];
    assert(FindPanel.matchesInScope(all, scope_) == all[1 .. 4]);
    TextRange none;
    assert(FindPanel.matchesInScope(all, WHOLE_TEXT_RANGE) == all);
    // an empty scope, e.g. after replacing all its text with nothing: no matches
    assert(FindPanel.matchesInScope(all, range(3, 3, 3, 3)).length == 0);
    // a replacement on the last line moves the end, one on another line doesn't
    assert(FindPanel.scopeAfterReplace(scope_, range(3, 3, 3, 5), 5) == range(1, 0, 3, 8));
    assert(FindPanel.scopeAfterReplace(scope_, range(3, 3, 3, 5), 0) == range(1, 0, 3, 3));
    assert(FindPanel.scopeAfterReplace(scope_, range(2, 3, 2, 5), 7) == scope_);
    assert(FindPanel.scopeAfterReplace(none, range(3, 3, 3, 5), 7) == none);
}

// showing the panel again: a new selection becomes the scope with the Selection option on, the panel's own match
// (unless the text changed since) keeps it; the find text stays for both, unless it is empty (#1166, #1179)
unittest {
    static TextRange sel(int start, int end) { return TextRange(TextPosition(0, start), TextPosition(0, end)); }
    static string decide(TextRange selection, bool lastFoundValid, bool selectionOption, bool hasFindText) {
        bool newScope;
        bool keepText;
        FindPanel.reopenDecision(selection, sel(2, 4), lastFoundValid, selectionOption, hasFindText, newScope,
            keepText);
        return (newScope ? "scope" : "-") ~ " " ~ (keepText ? "keep" : "set");
    }
    TextRange none;
    assert(decide(sel(2, 4), true, true, true) == "- keep"); // the panel's own match (F3 after Esc)
    assert(decide(sel(2, 4), true, false, true) == "- keep"); // also without the option: the find text keeps its case
    assert(decide(sel(2, 4), false, true, true) == "scope keep"); // the same positions after an edit: a new selection
    assert(decide(sel(0, 6), true, true, true) == "scope keep"); // a new selection with the option on
    assert(decide(sel(0, 6), true, false, true) == "- set"); // with the option off: the selected text is the find text
    assert(decide(sel(0, 6), true, true, false) == "scope set"); // an empty find text takes the selected text
    assert(decide(none, true, true, true) == "- set"); // no selection: the scope stays (there is no text to set)
}

//import dlangui.widgets.metadata;
//mixin(registerWidgets!(EditLine, EditBox, LogWidget)());

// externalChangeReaction(): file change x text modified x mode x before a save (#1280)
unittest {
    alias K = FileChangeKind;
    alias M = ExternalChangeMode;
    alias R = ExternalChangeReaction;
    foreach (kind; [K.unchanged, K.modified, K.deleted, K.created, K.overflow])
        foreach (modified; [false, true])
            foreach (beforeSave; [false, true])
                assert(externalChangeReaction(kind, modified, M.ignore, beforeSave) == R.none);
    foreach (mode; [M.notify, M.reloadUnmodified]) {
        foreach (modified; [false, true])
            foreach (beforeSave; [false, true])
                assert(externalChangeReaction(K.unchanged, modified, mode, beforeSave) == R.none);
        foreach (kind; [K.modified, K.created, K.overflow]) {
            assert(externalChangeReaction(kind, true, mode, false) == R.notifyConflict);
            assert(externalChangeReaction(kind, false, mode, true) == R.confirmSave);
            assert(externalChangeReaction(kind, true, mode, true) == R.confirmSave);
        }
        foreach (modified; [false, true]) {
            assert(externalChangeReaction(K.deleted, modified, mode, false) == R.notifyDeleted);
            assert(externalChangeReaction(K.deleted, modified, mode, true) == R.none); // the save writes it again
        }
    }
    // text without unsaved changes: the mode decides
    foreach (kind; [K.modified, K.created]) {
        assert(externalChangeReaction(kind, false, M.notify, false) == R.notifyChanged);
        assert(externalChangeReaction(kind, false, M.reloadUnmodified, false) == R.reload);
    }
}

// the external change messages and buttons are translated in every standard language
unittest {
    import std.algorithm : canFind;
    static immutable string[] keys = ["ACTION_EDITOR_RELOAD_FILE", "ACTION_EDITOR_KEEP_MY_TEXT",
        "ACTION_EDITOR_KEEP_TEXT", "ACTION_EDITOR_OVERWRITE_FILE", "ACTION_SAVE", "ACTION_IGNORE", "ACTION_CANCEL",
        "EXTERNAL_CHANGE_CHANGED", "EXTERNAL_CHANGE_CONFLICT", "EXTERNAL_CHANGE_DELETED",
        "EXTERNAL_CHANGE_BEFORE_SAVE", "EXTERNAL_CHANGE_RELOAD_FAILED", "EXTERNAL_CHANGE_SAVE_FAILED"];
    static foreach (lang; ["en", "ru", "pl"]) {{
        string text = import("res/i18n/std_" ~ lang ~ ".ini");
        foreach (key; keys)
            assert(text.canFind("\n" ~ key ~ "="), lang ~ ": " ~ key);
    }}
}

// #1290: only the save question stays, and only for a message about the same change
@safe unittest {
    alias R = ExternalChangeReaction;
    // the focus check after the save: modified text gives notifyConflict, unmodified text in notify mode notifyChanged
    assert(keepsExternalChangeMessage(R.confirmSave, R.notifyConflict, true));
    assert(keepsExternalChangeMessage(R.confirmSave, R.notifyChanged, true));
    // the file changed again since the question was shown: the newer message replaces it
    assert(!keepsExternalChangeMessage(R.confirmSave, R.notifyConflict, false));
    assert(!keepsExternalChangeMessage(R.confirmSave, R.notifyChanged, false));
    // a deleted file, a file back as it was, an unmodified text reloaded at once: the question is gone
    assert(!keepsExternalChangeMessage(R.confirmSave, R.notifyDeleted, true));
    assert(!keepsExternalChangeMessage(R.confirmSave, R.none, true));
    assert(!keepsExternalChangeMessage(R.confirmSave, R.reload, true));
    // other messages are replaced as before, e.g. "changed" becomes a conflict once the text is edited
    assert(!keepsExternalChangeMessage(R.notifyChanged, R.notifyConflict, true));
    assert(!keepsExternalChangeMessage(R.notifyConflict, R.notifyChanged, true));
    assert(!keepsExternalChangeMessage(R.notifyDeleted, R.notifyConflict, true));
    assert(!keepsExternalChangeMessage(R.none, R.notifyConflict, true));
}
