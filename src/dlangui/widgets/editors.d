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
import std.typecons : Yes, No;
import dlangui.core.streams;

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
    protected uint _leftPaneLineNumberColorEdited = 0xC0C000;
    protected uint _leftPaneLineNumberColorSaved = 0x00C000;
    protected uint _leftPaneLineNumberColorCurrentLine = 0xFFFFFFFF;
    protected uint _leftPaneLineNumberBackgroundColorCurrentLine = 0xC08080FF;
    protected uint _leftPaneLineNumberBackgroundColor = 0xF4F4F4;
    protected uint _colorIconBreakpoint = 0xFF0000;
    protected uint _colorIconBookmark = 0x0000FF;
    protected uint _colorIconError = 0x80FF0000;

    protected uint _caretColor = 0x000000;
    protected uint _caretColorReplace = 0x808080FF;
    protected uint _matchingBracketHightlightColor = 0x60FFE0B0;

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
    dchar[] splitChars = [' ', '-', '\t'];
    
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
    dstring[] explode(dstring str, dchar[] splitChars)
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
        int boggle = font.measureText(text, measuredWidths);
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

    /// override to add custom items on left panel
    protected void updateLeftPaneWidth() {
        import std.conv : to;
        _iconsWidth = _showIcons ? _iconsPaneWidth : 0;
        _foldingWidth = _showFolding ? _foldingPaneWidth : 0;
        _modificationMarksWidth = _showModificationMarks && (BACKEND_GUI || !_showLineNumbers) ? _modificationMarksPaneWidth : 0;
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
            _leftPaneWidth += WIDGET_STYLE_CONSOLE ? 1 : 3;
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
                buf.fillRect(rc, 0xFFD040);
            } else if (m == EditStateMark.saved) {
                // modified, saved
                buf.fillRect(rc, 0x20C020);
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
        rc.right -= 3;
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
        rc.right -= WIDGET_STYLE_CONSOLE ? 1 : 3;
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
        if (source is this) {
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
        _leftPaneLineNumberColorEdited = style.customColor("editor_left_pane_line_number_text_edited", 0xC0C000);
        _leftPaneLineNumberColorSaved = style.customColor("editor_left_pane_line_number_text_saved", 0x00C000);
        _leftPaneLineNumberColorCurrentLine = style.customColor("editor_left_pane_line_number_text_current_line", 0xFFFFFFFF);
        _leftPaneLineNumberBackgroundColorCurrentLine = style.customColor("editor_left_pane_line_number_background_current_line", 0xC08080FF);
        _leftPaneLineNumberBackgroundColor = style.customColor("editor_left_pane_line_number_background");
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
    void setTextToHighlight(dstring pattern, uint textToHighlightOptions) {
        _textToHighlight = pattern;
        _textToHighlightOptions = textToHighlightOptions;
        invalidate();
    }
    
    /// Used instead of using clientToTextPos for mouse input when in word wrap mode
    protected TextPosition wordWrapMouseOffset(int x, int y)
    {
        if(_span.length == 0)
            return clientToTextPos(Point(x,y));
        int selectedVisibleLine = y / _lineHeight;
            
        LineSpan _curSpan;
        
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
        return clientToTextPos(Point(x + accumulativeWidths,fakeLineHeight));
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
        return super.onKeyEvent(event);
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
            if (event.tripleClick) {
                selectLineByMouse(event.x - _clientRect.left, event.y - _clientRect.top);
            } else if (event.doubleClick) {
                selectWordByMouse(event.x - _clientRect.left, event.y - _clientRect.top);
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
            updateCaretPositionByMouse(event.x - _clientRect.left, event.y - _clientRect.top, true);
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
            _scrollPos.x -= -rc.left + _clientRect.width / 10;
            if (_scrollPos.x < 0)
                _scrollPos.x = 0;
            invalidate();
        } else if (rc.left >= _clientRect.width - 10) {
            // scroll right
            _scrollPos.x += (rc.left - _clientRect.width) + _spaceWidth * 4;
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
        return super.onKeyEvent(event);
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
        auto saver = ClipRectSaver(buf, rc, alpha);

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
        int[] buf;
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
        Rect contentRc = rc;
        int findPanelHeight;
        if (_findPanel && _findPanel.visibility != Visibility.Gone) {
            _findPanel.measure(rc.width, rc.height);
            findPanelHeight = _findPanel.measuredHeight;
            _findPanel.layout(Rect(rc.left, rc.bottom - findPanelHeight, rc.right, rc.bottom));
            contentRc.bottom -= findPanelHeight;
        }

        super.layout(contentRc);
        if (_contentChanged) {
            measureVisibleText();
            _needRewrap = true;
            _contentChanged = false;
        }

        _pos = rc;
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
    /// override to determine if scrollbars are needed or not
    override protected void checkIfScrollbarsNeeded(ref bool needHScroll, ref bool needVScroll) {
        needHScroll = _hscrollbar && (_hscrollbarMode == ScrollBarMode.Visible || _hscrollbarMode == ScrollBarMode.Auto);
        needVScroll = _vscrollbar && (_vscrollbarMode == ScrollBarMode.Visible || _vscrollbarMode == ScrollBarMode.Auto);
        if (!needHScroll && !needVScroll)
            return; // not needed
        if (_hscrollbarMode != ScrollBarMode.Auto && _vscrollbarMode != ScrollBarMode.Auto)
            return; // no auto scrollbars
        // either h or v scrollbar is in auto mode

        int hsbHeight = _hscrollbar.measuredHeight;
        int vsbWidth = _hscrollbar.measuredWidth;

        int visibleLines = _lineHeight > 0 ? (_clientRect.height / _lineHeight) : 1; // fully visible lines
        if (visibleLines < 1)
            visibleLines = 1;
        int visibleLinesWithScrollbar = _lineHeight > 0 ? ((_clientRect.height - hsbHeight) / _lineHeight) : 1; // fully visible lines
        if (visibleLinesWithScrollbar < 1)
            visibleLinesWithScrollbar = 1;

        // either h or v scrollbar is in auto mode
        //Point contentSize = fullContentSize();
        int contentWidth = _maxLineWidth + (_extendRightScrollBound ? _clientRect.width / 16 : 0);
        int contentHeight = _content.length;

        int clientWidth = _clientRect.width;
        int clientHeight = visibleLines;

        int clientWidthWithScrollbar = clientWidth - vsbWidth;
        int clientHeightWithScrollbar = visibleLinesWithScrollbar;

        if (_hscrollbarMode == ScrollBarMode.Auto && _vscrollbarMode == ScrollBarMode.Auto) {
            // both scrollbars in auto mode
            bool xFits = contentWidth <= clientWidth;
            bool yFits = contentHeight <= clientHeight;
            if (!xFits && !yFits) {
                // none fits, need both scrollbars
            } else if (xFits && yFits) {
                // everything fits!
                needHScroll = false;
                needVScroll = false;
            } else if (xFits) {
                // only X fits
                if (contentWidth <= clientWidthWithScrollbar)
                    needHScroll = false; // disable hscroll
            } else { // yFits
                // only Y fits
                if (contentHeight <= clientHeightWithScrollbar)
                    needVScroll = false; // disable vscroll
            }
        } else if (_hscrollbarMode == ScrollBarMode.Auto) {
            // only hscroll is in auto mode
            if (needVScroll)
                clientWidth = clientWidthWithScrollbar;
            needHScroll = contentWidth > clientWidth;
        } else {
            // only vscroll is in auto mode
            if (needHScroll)
                clientHeight = clientHeightWithScrollbar;
            needVScroll = contentHeight > clientHeight;
        }
    }

    /// update horizontal scrollbar widget position
    override protected void updateHScrollBar() {
        _hscrollbar.setRange(0, _maxLineWidth + (_extendRightScrollBound ? _clientRect.width / 16 : 0));
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
    override protected void ensureCaretVisible(bool center = false) {
        if (_caretPos.line >= _content.length)
            _caretPos.line = _content.length - 1;
        if (_caretPos.line < 0)
            _caretPos.line = 0;
        int visibleLines = _lineHeight > 0 ? _clientRect.height / _lineHeight : 1; // fully visible lines
        if (visibleLines < 1)
            visibleLines = 1;
        int maxFirstVisibleLine = _content.length - 1;
        if (!_enableScrollAfterText)
            maxFirstVisibleLine = _content.length - visibleLines;
        if (maxFirstVisibleLine < 0)
            maxFirstVisibleLine = 0;

        if (_caretPos.line < _firstVisibleLine) {
            _firstVisibleLine = _caretPos.line;
            if (center) {
                _firstVisibleLine -= visibleLines / 2;
                if (_firstVisibleLine < 0)
                    _firstVisibleLine = 0;
            }
            if (_firstVisibleLine > maxFirstVisibleLine)
                _firstVisibleLine = maxFirstVisibleLine;
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
            if (_firstVisibleLine > maxFirstVisibleLine)
                _firstVisibleLine = maxFirstVisibleLine;
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
            _scrollPos.x -= -rc.left + _clientRect.width / 4;
            if (_scrollPos.x < 0)
                _scrollPos.x = 0;
            invalidate();
        } else if (rc.left >= _clientRect.width - 10) {
            // scroll right
            if (!_wordWrap)
                _scrollPos.x += (rc.left - _clientRect.width) + _clientRect.width / 4;
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
        int lineIndex = pt.y / _lineHeight;
        if (lineIndex < 0)
            lineIndex = 0;
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
        dstring currentLine = _content[_caretPos.line];
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
        int findPanelHeight;
        if (_findPanel) {
            _findPanel.measure(parentWidth, parentHeight);
            findPanelHeight = _findPanel.measuredHeight;
            if (parentHeight != SIZE_UNSPECIFIED)
                parentHeight -= findPanelHeight;
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
            if (start >= selLine.length)
                return;
            pattern = selLine[start .. end];
            if (!isWordChar(pattern[0]) || !isWordChar(pattern[$-1]))
                return;
            if (!isWholeWord(selLine, start, end))
                return;
            // whole word is selected - enable highlight for it
            options = TextSearchFlag.CaseSensitive | TextSearchFlag.WholeWords;
        }
        if (!pattern.length)
            return;
        dstring lineText = _content.line(lineIndex);
        if (lineText.length < pattern.length)
            return;
        ptrdiff_t start = 0;
        import std.string : indexOf, CaseSensitive;
        import std.typecons : Flag;
        bool caseSensitive = (options & TextSearchFlag.CaseSensitive) != 0;
        bool wholeWords = (options & TextSearchFlag.WholeWords) != 0;
        bool selectionOnly = (options & TextSearchFlag.SelectionOnly) != 0;
        for (;;) {
            ptrdiff_t pos = lineText[start .. $].indexOf(pattern, caseSensitive ? Yes.caseSensitive : No.caseSensitive);
            if (pos < 0)
                break;
            // found text to highlight
            start += pos;
            if (!wholeWords || isWholeWord(lineText, start, start + pattern.length)) {
                TextRange r = TextRange(TextPosition(lineIndex, cast(int)start), TextPosition(lineIndex, cast(int)(start + pattern.length)));
                uint color = r.isInsideOrNext(caretPos) ? _searchHighlightColorCurrent : _searchHighlightColorOther;
                highlightLineRange(buf, lineRect, color, r);
            }
            start += pattern.length;
        }
    }

    static bool isWordChar(dchar ch) {
        if (ch >= 'a' && ch <= 'z')
            return true;
        if (ch >= 'A' && ch <= 'Z')
            return true;
        if (ch == '_')
            return true;
        return false;
    }
    static bool isValidWordBound(dchar innerChar, dchar outerChar) {
        return !isWordChar(innerChar) || !isWordChar(outerChar);
    }
    /// returns true if selected range of string is whole word
    static bool isWholeWord(dstring lineText, size_t start, size_t end) {
        if (start >= lineText.length || start >= end)
            return false;
        if (start > 0 && !isValidWordBound(lineText[start], lineText[start - 1]))
            return false;
        if (end > 0 && end < lineText.length && !isValidWordBound(lineText[end - 1], lineText[end]))
            return false;
        return true;
    }

    /// find all occurences of text pattern in content; options = bitset of TextSearchFlag
    TextRange[] findAll(dstring pattern, uint options) {
        TextRange[] res;
        res.assumeSafeAppend();
        if (!pattern.length)
            return res;
        import std.string : indexOf, CaseSensitive;
        bool caseSensitive = (options & TextSearchFlag.CaseSensitive) != 0;
        bool wholeWords = (options & TextSearchFlag.WholeWords) != 0;
        bool selectionOnly = (options & TextSearchFlag.SelectionOnly) != 0;
        for (int i = 0; i < _content.length; i++) {
            dstring lineText = _content.line(i);
            if (lineText.length < pattern.length)
                continue;
            ptrdiff_t start = 0;
            for (;;) {
                ptrdiff_t pos = lineText[start .. $].indexOf(pattern, caseSensitive ? Yes.caseSensitive : No.caseSensitive);
                if (pos < 0)
                    break;
                // found text to highlight
                start += pos;
                if (!wholeWords || isWholeWord(lineText, start, start + pattern.length)) {
                    TextRange r = TextRange(TextPosition(i, cast(int)start), TextPosition(i, cast(int)(start + pattern.length)));
                    res ~= r;
                }
                start += _textToHighlight.length;
            }
        }
        return res;
    }

    /// find next occurence of text pattern in content, returns true if found
    bool findNextPattern(ref TextPosition pos, dstring pattern, uint searchOptions, int direction) {
        TextRange[] all = findAll(pattern, searchOptions);
        if (!all.length)
            return false;
        int currentIndex = -1;
        int nearestIndex = cast(int)all.length;
        for (int i = 0; i < all.length; i++) {
            if (all[i].isInsideOrNext(pos)) {
                currentIndex = i;
                break;
            }
        }
        for (int i = 0; i < all.length; i++) {
            if (pos < all[i].start) {
                nearestIndex = i;
                break;
            }
            if (pos > all[i].end) {
                nearestIndex = i + 1;
            }
        }
        if (currentIndex >= 0) {
            if (all.length < 2 && direction != 0)
                return false;
            currentIndex += direction;
            if (currentIndex < 0)
                currentIndex = cast(int)all.length - 1;
            else if (currentIndex >= all.length)
                currentIndex = 0;
            pos = all[currentIndex].start;
            return true;
        }
        if (direction < 0)
            nearestIndex--;
        if (nearestIndex < 0)
            nearestIndex = cast(int)all.length - 1;
        else if (nearestIndex >= all.length)
            nearestIndex = 0;
        pos = all[nearestIndex].start;
        return true;
    }

    protected void highlightLineRange(DrawBuf buf, Rect lineRect, uint color, TextRange r) {
        Rect startrc = textPosToClient(r.start);
        Rect endrc = textPosToClient(r.end);
        Rect rc = lineRect;
        rc.left = _clientRect.left + startrc.left;
        rc.right = _clientRect.left + endrc.right;
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
        int spaceIndex = 0;
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
        int lc = lineCount;
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
        MenuItem item = menu.add(toggleBookmarkAction);
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
            addChild(_findPanel);
            res = true;
        } else {
            if (_findPanel.visibility != Visibility.Visible) {
                _findPanel.visibility = Visibility.Visible;
                if (txt.length)
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
                removeChild(_findPanel);
                destroy(_findPanel);
                _findPanel = null;
                requestLayout();
            }
        }
    }

    /// Draw widget at its position to buffer
    override void onDraw(DrawBuf buf) {
        if (visibility != Visibility.Visible)
            return;
        super.onDraw(buf);
        if (_findPanel && _findPanel.visibility == Visibility.Visible) {
            _findPanel.onDraw(buf);
        }
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
        _cbCaseSensitive.checkChange = &onCaseSensitiveCheckChange;
        _cbWholeWords.checkChange = &onCaseSensitiveCheckChange;
        _cbSelection.checkChange = &onCaseSensitiveCheckChange;
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
                replaceOne();
                findNext(_backDirection);
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
    bool findNext(bool back) {
        setDirection(back);
        dstring currentText = _edFind.text;
        Log.d("findNext text=", currentText, " back=", back);
        if (!currentText.length)
            return false;
        _editor.setTextToHighlight(currentText, makeSearchFlags);
        TextPosition pos = _editor.caretPos;
        bool res = _editor.findNextPattern(pos, currentText, makeSearchFlags, back ? -1 : 1);
        if (res) {
            _editor.selectionRange = TextRange(pos, TextPosition(pos.line, pos.pos + cast(int)currentText.length));
            _editor.ensureCaretVisible();
            //_editor.setCaretPos(pos.line, pos.pos, true);
        }
        return res;
    }

    bool replaceOne() {
        dstring currentText = _edFind.text;
        dstring newText = _edReplace.text;
        Log.d("replaceOne text=", currentText, " back=", _backDirection, " newText=", newText);
        if (!currentText.length)
            return false;
        _editor.setTextToHighlight(currentText, makeSearchFlags);
        TextPosition pos = _editor.caretPos;
        bool res = _editor.findNextPattern(pos, currentText, makeSearchFlags, 0);
        if (res) {
            _editor.selectionRange = TextRange(pos, TextPosition(pos.line, pos.pos + cast(int)currentText.length));
            _editor.replaceSelectionText(newText);
            _editor.selectionRange = TextRange(pos, TextPosition(pos.line, pos.pos + cast(int)newText.length));
            _editor.ensureCaretVisible();
            //_editor.setCaretPos(pos.line, pos.pos, true);
        }
        return res;
    }

    int replaceAll() {
        int count = 0;
        for(int i = 0; ; i++) {
            debug Log.d("replaceAll - calling replaceOne, iteration ", i);
            if (!replaceOne())
                break;
            count++;
            TextPosition initialPosition = _editor.caretPos;
            debug Log.d("replaceAll - position is ", initialPosition);
            if (!findNext(_backDirection))
                break;
            TextPosition newPosition = _editor.caretPos;
            debug Log.d("replaceAll - next position is ", newPosition);
            if (_backDirection && newPosition >= initialPosition)
                break;
            if (!_backDirection && newPosition <= initialPosition)
                break;
        }
        debug Log.d("replaceAll - done, replace count = ", count);
        _editor.ensureCaretVisible();
        return count;
    }

    void updateHighlight() {
        dstring currentText = _edFind.text;
        Log.d("onFindTextChange.currentText=", currentText);
        _editor.setTextToHighlight(currentText, makeSearchFlags);
    }

    void onFindTextChange(EditableContent source) {
        Log.d("onFindTextChange");
        updateHighlight();
    }

    bool onCaseSensitiveCheckChange(Widget source, bool checkValue) {
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

//import dlangui.widgets.metadata;
//mixin(registerWidgets!(EditLine, EditBox, LogWidget)());
