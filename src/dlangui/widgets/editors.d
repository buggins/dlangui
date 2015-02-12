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
import dlangui.core.signals;
import dlangui.core.collections;
import dlangui.core.linestream;
import dlangui.platforms.common.platform;
import dlangui.widgets.menu;
import dlangui.widgets.popup;
import dlangui.graphics.colors;
public import dlangui.core.editable;

import std.algorithm;
import std.stream;

/// Modified state change listener
interface ModifiedStateListener {
	void onModifiedStateChange(Widget source, bool modified);
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
	/// insert new line after current position (Ctrl+Enter)
	PrependNewLine,
	
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
}

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

    protected bool _replaceMode;

    // TODO: move to styles
    protected uint _selectionColorFocused = 0xB060A0FF;
    protected uint _selectionColorNormal = 0xD060A0FF;
    protected uint _leftPaneBackgroundColor = 0xF4F4F4;
    protected uint _leftPaneBackgroundColor2 = 0xFFFFFF;
    protected uint _leftPaneBackgroundColor3 = 0xC0C0C0;
    protected uint _leftPaneLineNumberColor = 0x4060D0;
    protected uint _leftPaneLineNumberBackgroundColor = 0xF0F0F0;
    protected uint _iconsPaneWidth = 16;
    protected uint _foldingPaneWidth = 12;
    protected uint _modificationMarksPaneWidth = 4;
    /// when true, call measureVisibileText on next layout
    protected bool _contentChanged = true;


    /// Modified state change listener
    Signal!ModifiedStateListener onModifiedStateChangeListener;

    /// override to support modification of client rect after change, e.g. apply offset
    override protected void handleClientRectLayout(ref Rect rc) {
        updateLeftPaneWidth();
        rc.left += _leftPaneWidth;
    }

    /// override for multiline editors
    protected int lineCount() {
        return 1;
    }

    /// override to add custom items on left panel
    protected void updateLeftPaneWidth() {
        _iconsWidth = _showIcons ? _iconsPaneWidth : 0;
        _foldingWidth = _showFolding ? _foldingPaneWidth : 0;
        _modificationMarksWidth = _showModificationMarks ? _modificationMarksPaneWidth : 0;
        _lineNumbersWidth = 0;
        if (_showLineNumbers) {
            dchar[] s = to!(dchar[])(lineCount + 1);
            foreach(ref ch; s)
                ch = '9';
            FontRef fnt = font;
            Point sz = fnt.textSize(s);
            _lineNumbersWidth = sz.x;
        }
        _leftPaneWidth = _lineNumbersWidth + _modificationMarksWidth + _foldingWidth + _iconsWidth;
        if (_leftPaneWidth)
            _leftPaneWidth += 3;
    }

    protected void drawLeftPaneFolding(DrawBuf buf, Rect rc, int line) {
        buf.fillRect(rc, 0xFFFFFF);
    }

    protected void drawLeftPaneIcons(DrawBuf buf, Rect rc, int line) {
        buf.fillRect(rc, 0xE0E0E0);
    }

    protected void drawLeftPaneModificationMarks(DrawBuf buf, Rect rc, int line) {
        if (line >= 0 && line < content.length) {
            EditStateMark m = content.editMark(line);
            if (m == EditStateMark.changed) {
                // modified, not saved
                buf.fillRect(rc, 0xFFD040);
            } else if (m == EditStateMark.saved) {
                // modified, not saved
                buf.fillRect(rc, 0x20C020);
            }
        }
    }

    protected void drawLeftPaneLineNumbers(DrawBuf buf, Rect rc, int line) {
        buf.fillRect(rc, _leftPaneLineNumberBackgroundColor);
        if (line < 0)
            return;
        dstring s = to!dstring(line + 1);
        FontRef fnt = font;
        Point sz = fnt.textSize(s);
        int x = rc.right - sz.x;
        int y = rc.top + (rc.height - sz.y) / 2;
        fnt.drawText(buf, x, y, s, _leftPaneLineNumberColor);
    }

    protected void drawLeftPane(DrawBuf buf, Rect rc, int line) {
        // override for custom drawn left pane
        buf.fillRect(rc, _leftPaneBackgroundColor);
        //buf.fillRect(Rect(rc.right - 2, rc.top, rc.right - 1, rc.bottom), _leftPaneBackgroundColor2);
        //buf.fillRect(Rect(rc.right - 1, rc.top, rc.right - 0, rc.bottom), _leftPaneBackgroundColor3);
        rc.right -= 3;
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

			new Action(EditorActions.ScrollLineUp, KeyCode.UP, KeyFlag.Control),
			new Action(EditorActions.ScrollLineDown, KeyCode.DOWN, KeyFlag.Control),

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

			new Action(EditorActions.ToggleReplaceMode, KeyCode.INS, 0),
			new Action(EditorActions.SelectAll, KeyCode.KEY_A, KeyFlag.Control),

			new Action(EditorActions.ToggleLineComment, KeyCode.KEY_DIVIDE, KeyFlag.Control),
			new Action(EditorActions.ToggleBlockComment, KeyCode.KEY_DIVIDE, KeyFlag.Control | KeyFlag.Shift),
			new Action(EditorActions.DeleteLine, KeyCode.KEY_D, KeyFlag.Control),
			new Action(EditorActions.DeleteLine, KeyCode.KEY_L, KeyFlag.Control),
			new Action(EditorActions.InsertLine, KeyCode.RETURN, KeyFlag.Control),
		]);
    }

	protected MenuItem _popupMenu;
	@property MenuItem popupMenu() { return _popupMenu; }
	@property EditWidgetBase popupMenu(MenuItem popupMenu) {
		_popupMenu = popupMenu;
		return this;
	}

	/// 
	override bool onMenuItemAction(const Action action) {
		return dispatchAction(action);
	}

	/// returns true if widget can show popup (e.g. by mouse right click at point x,y)
	override bool canShowPopupMenu(int x, int y) {
		if (_popupMenu is null)
			return false;
		if (_popupMenu.onBeforeOpeningSubmenu.assigned)
			if (!_popupMenu.onBeforeOpeningSubmenu(_popupMenu))
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
		switch (action.id) {
			case EditorActions.Tab:
			case EditorActions.BackTab:
			case EditorActions.Indent:
			case EditorActions.Unindent:
				return enabled;
			case EditorActions.Copy:
				return !_selectionRange.empty;
			case EditorActions.Cut:
				return enabled && !_selectionRange.empty;
			case EditorActions.Paste:
				return enabled && Platform.instance.getClipboardText().length > 0;
			case EditorActions.Undo:
				return enabled && _content.hasUndo;
			case EditorActions.Redo:
				return enabled && _content.hasRedo;
			default:
				return super.isActionEnabled(action);
		}
	}

	/// shows popup at (x,y)
	override void showPopupMenu(int x, int y) {
		/// if preparation signal handler assigned, call it; don't show popup if false is returned from handler
		if (_popupMenu.onBeforeOpeningSubmenu.assigned)
			if (!_popupMenu.onBeforeOpeningSubmenu(_popupMenu))
				return;
		_popupMenu.updateActionState(this);
		PopupMenu popupMenu = new PopupMenu(_popupMenu);
		popupMenu.onMenuItemActionListener = this;
		PopupWidget popup = window.showPopup(popupMenu, this, PopupAlign.Point | PopupAlign.Right, x, y);
		popup.flags = PopupFlags.CloseOnClickOutside;
	}

	void onPopupMenuItem(MenuItem item) {
		// TODO
	}

	/// returns mouse cursor type for widget
	override uint getCursorType(int x, int y) {
		return CursorType.IBeam;
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

    /// when true, show modification marks for lines (whether line is unchanged/modified/modified_saved
    @property bool showModificationMarks() {
        return _showModificationMarks;
    }

    /// when true, show modification marks for lines (whether line is unchanged/modified/modified_saved
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
            _content.contentChangeListeners.disconnect(this);
            if (_ownContent) {
                destroy(_content);
            }
        }
        _content = content;
        _ownContent = false;
        _content.contentChangeListeners.connect(this);
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

	override void onContentChange(EditableContent content, EditOperation operation, ref TextRange rangeBefore, ref TextRange rangeAfter, Object source) {
        //Log.d("onContentChange rangeBefore=", rangeBefore, " rangeAfter=", rangeAfter, " text=", operation.content);
        if (source is this) {
            if (operation.action == EditAction.ReplaceContent) {
                _contentChanged = true;
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
                _contentChanged = true;
                _caretPos = rangeAfter.end;
                _selectionRange.start = _caretPos;
                _selectionRange.end = _caretPos;
                updateMaxLineWidth();
                measureVisibleText();
                ensureCaretVisible();
				requestActionsUpdate();
            }
        } else {
            updateMaxLineWidth();
            measureVisibleText();
            correctCaretPos();
            requestLayout();
            requestActionsUpdate();
        }
		invalidate();
        if (onModifiedStateChangeListener.assigned) {
            if (_lastReportedModifiedState != content.modified) {
                _lastReportedModifiedState = content.modified;
                onModifiedStateChangeListener(this, content.modified);
				requestActionsUpdate();
            }
        }
		return;
	}
    protected bool _lastReportedModifiedState;

    /// get widget text
    override @property dstring text() { return _content.text; }

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

    abstract protected void ensureCaretVisible();

    abstract protected Point measureVisibleText();

    protected int _caretBlingingInterval = 800;
    protected ulong _caretTimerId;
    protected bool _caretBlinkingPhase;
    protected long _lastBlinkStartTs;
    protected void startCaretBlinking() {
        if (window) {
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
    protected void stopCaretBlinking() {
        if (window) {
            if (_caretTimerId) {
                cancelTimer(_caretTimerId);
                _caretTimerId = 0;
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
            return focused;
        }
        return super.onTimer(id);
    }
    /// override to handle focus changes
    override protected void handleFocusChange(bool focused) {
        if (focused)
            startCaretBlinking();
        else
            stopCaretBlinking();
        super.handleFocusChange(focused);
    }


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
        caretRc.offset(_clientRect.left, _clientRect.top);
        return caretRc;
    }

    /// draws caret
    protected void drawCaret(DrawBuf buf) {
        if (focused) {
            if (_caretBlinkingPhase) {
                return;
            }
            // draw caret
            Rect caretRc = caretRect();
            if (caretRc.intersects(_clientRect)) {
                Rect rc1 = caretRc;
                rc1.right = rc1.left + 1;
                caretRc.left++;
                if (_replaceMode)
                    buf.fillRect(caretRc, 0x808080FF);
                buf.fillRect(rc1, 0x000000);
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
                _selectionRange.start = _caretPos;
                _selectionRange.end = _caretPos;
            }
        } else {
            _selectionRange.start = _caretPos;
            _selectionRange.end = _caretPos;
        }
        invalidate();
		requestActionsUpdate();
    }

    protected void selectWordByMouse(int x, int y) {
        TextPosition oldCaretPos = _caretPos;
        TextPosition newPos = clientToTextPos(Point(x,y));
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
    protected bool multipleLinesSelected() {
        return _selectionRange.end.line > _selectionRange.start.line;
    }

    protected bool _camelCasePartsAsWords = true;

    protected bool removeSelectionTextIfSelected() {
        if (_selectionRange.empty)
            return false;
        // clear selection
        EditOperation op = new EditOperation(EditAction.Replace, _selectionRange, [""d]);
        _content.performOperation(op, this);
        ensureCaretVisible();
        return true;
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
        return true;
    }

	/// override to handle specific actions state (e.g. change enabled state for supported actions)
	override bool handleActionStateRequest(const Action a) {
		switch (a.id) {
			case EditorActions.ToggleBlockComment:
                if (!_content.syntaxHighlighter || !_content.syntaxHighlighter.supportsToggleBlockComment)
                    a.state = ACTION_STATE_INVISIBLE;
                else if (enabled && _content.syntaxHighlighter.canToggleBlockComment(_selectionRange))
                    a.state = ACTION_STATE_ENABLED;
                else
                    a.state = ACTION_STATE_DISABLE;
                return true;
			case EditorActions.ToggleLineComment:
                if (!_content.syntaxHighlighter || !_content.syntaxHighlighter.supportsToggleLineComment)
                    a.state = ACTION_STATE_INVISIBLE;
                else if (enabled && _content.syntaxHighlighter.canToggleLineComment(_selectionRange))
                    a.state = ACTION_STATE_ENABLED;
                else
                    a.state = ACTION_STATE_DISABLE;
                return true;
            case EditorActions.Copy:
            case EditorActions.Cut:
            case EditorActions.Paste:
            case EditorActions.Undo:
            case EditorActions.Redo:
			case EditorActions.Tab:
			case EditorActions.BackTab:
			case EditorActions.Indent:
			case EditorActions.Unindent:
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
            case EditorActions.WordLeft:
            case EditorActions.SelectWordLeft:
                {
                    TextPosition newpos = _content.moveByWord(_caretPos, -1, _camelCasePartsAsWords);
                    if (newpos != _caretPos) {
                        _caretPos = newpos;
                        updateSelectionAfterCursorMovement(oldCaretPos, a.id == EditorActions.SelectWordLeft);
                        ensureCaretVisible();
                    }
                }
                return true;
            case EditorActions.WordRight:
            case EditorActions.SelectWordRight:
                {
                    TextPosition newpos = _content.moveByWord(_caretPos, 1, _camelCasePartsAsWords);
                    if (newpos != _caretPos) {
                        _caretPos = newpos;
                        updateSelectionAfterCursorMovement(oldCaretPos, a.id == EditorActions.SelectWordRight);
                        ensureCaretVisible();
                    }
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
            case EditorActions.DelPrevWord:
                if (readOnly)
                    return true;
                correctCaretPos();
                if (removeSelectionTextIfSelected()) // clear selection
                    return true;
                TextPosition newpos = _content.moveByWord(_caretPos, -1, _camelCasePartsAsWords);
                if (newpos < _caretPos)
                    removeRangeText(TextRange(newpos, _caretPos));
                return true;
            case EditorActions.DelNextWord:
                if (readOnly)
                    return true;
                correctCaretPos();
                if (removeSelectionTextIfSelected()) // clear selection
                    return true;
                TextPosition newpos = _content.moveByWord(_caretPos, 1, _camelCasePartsAsWords);
                if (newpos > _caretPos)
                    removeRangeText(TextRange(_caretPos, newpos));
                return true;
            case EditorActions.DelPrevChar:
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
            case EditorActions.DelNextChar:
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
                    if (readOnly)
                        return true;
                    EditOperation op = new EditOperation(EditAction.Replace, _selectionRange, [""d]);
                    _content.performOperation(op, this);
                }
                return true;
            case EditorActions.Paste:
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
            case EditorActions.Undo:
                {
                    if (readOnly)
                        return true;
                    _content.undo(this);
                }
                return true;
            case EditorActions.Redo:
                {
                    if (readOnly)
                        return true;
                    _content.redo(this);
                }
                return true;
			case EditorActions.Indent:
                indentRange(false);
                return true;
			case EditorActions.Unindent:
                indentRange(true);
                return true;
            case EditorActions.Tab:
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
            case EditorActions.BackTab:
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
            case EditorActions.ToggleReplaceMode:
                replaceMode = !replaceMode;
                return true;
            case EditorActions.SelectAll:
                _selectionRange.start.line = 0;
                _selectionRange.start.pos = 0;
                _selectionRange.end = _content.lineEnd(_content.length - 1);
                _caretPos = _selectionRange.end;
                ensureCaretVisible();
				requestActionsUpdate();
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

	/// handle keys
	override bool onKeyEvent(KeyEvent event) {
        if (focused) startCaretBlinking();
		if (event.action == KeyAction.Text && event.text.length && !(event.flags & (KeyFlag.Control | KeyFlag.Alt))) {
			Log.d("text entered: ", event.text);
            if (readOnly)
                return true;
			dchar ch = event.text[0];
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
		return super.onKeyEvent(event);
	}

    /// process mouse event; return true if event is processed by widget.
    override bool onMouseEvent(MouseEvent event) {
        //Log.d("onMouseEvent ", id, " ", event.action, "  (", event.x, ",", event.y, ")");
		// support onClick
	    if (event.action == MouseAction.ButtonDown && event.button == MouseButton.Left) {
            setFocus();
            startCaretBlinking();
            if (event.doubleClick) {
                selectWordByMouse(event.x - _clientRect.left, event.y - _clientRect.top);
            } else {
                updateCaretPositionByMouse(event.x - _clientRect.left, event.y - _clientRect.top, false);
            }
            invalidate();
	        return true;
	    }
	    if (event.action == MouseAction.Move && (event.flags & MouseButton.Left) != 0) {
            updateCaretPositionByMouse(event.x - _clientRect.left, event.y - _clientRect.top, true);
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
        if (event.action == MouseAction.Wheel) {
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
	    return super.onMouseEvent(event);
    }


}

interface EditorActionHandler {
	bool onEditorAction(const Action action);
}

/// single line editor
class EditLine : EditWidgetBase {

	Signal!EditorActionHandler editorActionListener;

    /// empty parameter list constructor - for usage by factory
    this() {
        this(null);
    }
    /// create with ID parameter
    this(string ID, dstring initialContent = null) {
        super(ID, ScrollBarMode.Invisible, ScrollBarMode.Invisible);
        _content = new EditableContent(false);
		_content.contentChangeListeners = this;
        wantTabs = false;
        styleId = STYLE_EDIT_LINE;
        text = initialContent;
    }

    protected dstring _measuredText;
    protected int[] _measuredTextWidths;
    protected Point _measuredTextSize;

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
        measuredContent(parentWidth, parentHeight, _measuredTextSize.x + _leftPaneWidth, _measuredTextSize.y);
    }

	override protected bool handleAction(const Action a) {
		switch (a.id) {
			case EditorActions.InsertNewLine:
			case EditorActions.PrependNewLine:
				if (editorActionListener.assigned) {
					return editorActionListener(a);
				}
				break;
            case EditorActions.Up:
                break;
            case EditorActions.Down:
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
            int startx = startrc.left + _clientRect.left;
            int endx = endrc.left + _clientRect.left;
            Rect rc = lineRect;
            rc.left = startx;
            rc.right = endx;
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
        dstring txt = text;
        Point sz = font.textSize(txt);
        //applyAlign(rc, sz);
        Rect lineRect = _clientRect;
        lineRect.left = _clientRect.left - _scrollPos.x;
        lineRect.right = lineRect.left + calcLineWidth(txt);
        Rect visibleRect = lineRect;
        visibleRect.left = _clientRect.left;
        visibleRect.right = _clientRect.right;
        drawLineBackground(buf, lineRect, visibleRect);
        font.drawText(buf, rc.left - _scrollPos.x, rc.top, txt, textColor, tabSize);

        drawCaret(buf);
    }
}



/// single line editor
class EditBox : EditWidgetBase {
    /// empty parameter list constructor - for usage by factory
    this() {
        this(null);
    }
    /// create with ID parameter
    this(string ID, dstring initialContent = null, ScrollBarMode hscrollbarMode = ScrollBarMode.Visible, ScrollBarMode vscrollbarMode = ScrollBarMode.Visible) {
        super(ID, hscrollbarMode, vscrollbarMode);
        _content = new EditableContent(true); // multiline
		_content.contentChangeListeners = this;
        styleId = STYLE_EDIT_BOX;
        text = initialContent;
		acceleratorMap.add( [
			// zoom
			new Action(EditorActions.ZoomIn, KeyCode.ADD, KeyFlag.Control),
			new Action(EditorActions.ZoomOut, KeyCode.SUB, KeyFlag.Control),
		]);
    }
    protected uint _matchingBracketHightlightColor = 0x60FFE0B0;

    protected int _firstVisibleLine;

    protected int _maxLineWidth;
    protected int _numVisibleLines;             // number of lines visible in client area
    protected dstring[] _visibleLines;          // text for visible lines
    protected int[][] _visibleLinesMeasurement; // char positions for visible lines
    protected int[] _visibleLinesWidths; // width (in pixels) of visible lines
    protected CustomCharProps[][] _visibleLinesHighlights;
    protected CustomCharProps[][] _visibleLinesHighlightsBuf;

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
        if (visibility == Visibility.Gone) {
            return;
        }
        super.layout(rc);
        if (_contentChanged) {
            measureVisibleText();
            _contentChanged = false;
        }
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
        if (_firstVisibleLine + _numVisibleLines > _content.length)
            _numVisibleLines = _content.length - _firstVisibleLine;
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

    /// update horizontal scrollbar widget position
    override protected void updateHScrollBar() {
        _hscrollbar.setRange(0, _maxLineWidth + _clientRect.width / 4);
        _hscrollbar.pageSize = _clientRect.width;
        _hscrollbar.position = _scrollPos.x;
    }

    /// update verticat scrollbar widget position
    override protected void updateVScrollBar() {
        int visibleLines = _lineHeight ? _clientRect.height / _lineHeight : 1; // fully visible lines
        if (visibleLines < 1)
            visibleLines = 1;
        _vscrollbar.setRange(0, _content.length - 1);
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

    override protected void ensureCaretVisible() {
        if (_caretPos.line >= _content.length)
            _caretPos.line = _content.length - 1;
        if (_caretPos.line < 0)
            _caretPos.line = 0;
        int visibleLines = _lineHeight > 0 ? _clientRect.height / _lineHeight : 1; // fully visible lines
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
            _scrollPos.x -= -rc.left + _clientRect.width / 4;
            if (_scrollPos.x < 0)
                _scrollPos.x = 0;
            invalidate();
        } else if (rc.left >= _clientRect.width - 10) {
            // scroll right
            _scrollPos.x += (rc.left - _clientRect.width) + _clientRect.width / 4;
            invalidate();
        }
        updateScrollBars();
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
            int len = cast(int)_visibleLines[lineIndex].length;
            for (int i = 0; i < len; i++) {
                int x0 = i > 0 ? _visibleLinesMeasurement[lineIndex][i - 1] : 0;
                int x1 = _visibleLinesMeasurement[lineIndex][i];
                int mx = (x0 + x1) >> 1;
                if (pt.x < mx) {
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
		switch (a.id) {
            case EditorActions.PrependNewLine:
                {
                    correctCaretPos();
                    _caretPos.pos = 0;
                    EditOperation op = new EditOperation(EditAction.Replace, _selectionRange, [""d, ""d]);
                    _content.performOperation(op, this);
                }
                return true;
            case EditorActions.InsertNewLine:
                {
                    correctCaretPos();
                    EditOperation op = new EditOperation(EditAction.Replace, _selectionRange, [""d, ""d]);
                    _content.performOperation(op, this);
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
            case EditorActions.PageBegin:
            case EditorActions.SelectPageBegin:
                {
                    ensureCaretVisible();
                    _caretPos.line = _firstVisibleLine;
                    updateSelectionAfterCursorMovement(oldCaretPos, (a.id & 1) != 0);
                }
                return true;
            case EditorActions.PageEnd:
            case EditorActions.SelectPageEnd:
                {
                    ensureCaretVisible();
                    int fullLines = _clientRect.height / _lineHeight;
                    int newpos = _firstVisibleLine + fullLines - 1;
                    if (newpos >= _content.length)
                        newpos = _content.length - 1;
                    _caretPos.line = newpos;
                    updateSelectionAfterCursorMovement(oldCaretPos, (a.id & 1) != 0);
                }
                return true;
            case EditorActions.PageUp:
            case EditorActions.SelectPageUp:
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
                    measureVisibleText();
                    updateScrollBars();
                    updateSelectionAfterCursorMovement(oldCaretPos, (a.id & 1) != 0);
                }
                return true;
            case EditorActions.PageDown:
            case EditorActions.SelectPageDown:
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
                    measureVisibleText();
                    updateScrollBars();
                    updateSelectionAfterCursorMovement(oldCaretPos, (a.id & 1) != 0);
                }
                return true;
            case EditorActions.ScrollLeft:
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
            case EditorActions.ScrollRight:
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
            case EditorActions.ScrollLineUp:
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
            case EditorActions.ScrollPageUp:
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
            case EditorActions.ScrollLineDown:
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
            case EditorActions.ScrollPageDown:
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
            case EditorActions.ZoomOut:
            case EditorActions.ZoomIn:
                {
                    int dir = a.id == EditorActions.ZoomIn ? 1 : -1;
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
                            measureVisibleText();
                            updateScrollBars();
                            invalidate();
                        }
                    }
                }
                return true;
			case EditorActions.ToggleBlockComment:
                if (_content.syntaxHighlighter && _content.syntaxHighlighter.supportsToggleBlockComment && _content.syntaxHighlighter.canToggleBlockComment(_selectionRange))
                    _content.syntaxHighlighter.toggleBlockComment(_selectionRange, this);
                return true;
			case EditorActions.ToggleLineComment:
                if (_content.syntaxHighlighter && _content.syntaxHighlighter.supportsToggleLineComment && _content.syntaxHighlighter.canToggleLineComment(_selectionRange))
                    _content.syntaxHighlighter.toggleLineComment(_selectionRange, this);
                return true;
			case EditorActions.InsertLine:
                {
                    correctCaretPos();
					TextPosition p = _content.lineEnd(_caretPos.line);
					TextRange r = TextRange(p, p);
                    EditOperation op = new EditOperation(EditAction.Replace, r, [""d, ""d]);
                    _content.performOperation(op, this);
					_caretPos = oldCaretPos;
                }
				return true;
			case EditorActions.DeleteLine:
                {
                    correctCaretPos();
                    EditOperation op = new EditOperation(EditAction.Replace, _content.lineRange(_caretPos.line), [""d]);
                    _content.performOperation(op, this);
                }
				return true;
            default:
                break;
		}
		return super.handleAction(a);
	}

    /// calculate full content size in pixels
    override Point fullContentSize() {
        Point textSz = measureVisibleText();
        int maxy = _lineHeight * 5; // limit measured height
        if (textSz.y > maxy)
            textSz.y = maxy;
        return textSz;
    }

    /// measure
    override void measure(int parentWidth, int parentHeight) { 
        if (visibility == Visibility.Gone) {
            return;
        }
        updateFontProps();
        updateMaxLineWidth();
        super.measure(parentWidth, parentHeight);
        // do we need to add vsbwidth, hsbheight ???
        //measuredContent(parentWidth, parentHeight, textSz.x + vsbwidth, textSz.y + hsbheight);
    }


    protected void highlightLineRange(DrawBuf buf, Rect lineRect, uint color, TextRange r) {
        Rect startrc = textPosToClient(r.start);
        Rect endrc = textPosToClient(r.end);
        Rect rc = lineRect;
        rc.left = _clientRect.left + startrc.left;
        rc.right = _clientRect.left + endrc.right;
        if (!rc.empty) {
            // draw selection rect for matching bracket
            buf.fillRect(rc, color);
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
            if (!rc.empty) {
                // draw selection rect for line
                buf.fillRect(rc, focused ? _selectionColorFocused : _selectionColorNormal);
            }
        }

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
            i++;
            rc.top += _lineHeight;
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

	override protected void drawClient(DrawBuf buf) {
        // update matched braces
        if (!content.findMatchedBraces(_caretPos, _matchingBraces)) {
            _matchingBraces.start.line = -1;
            _matchingBraces.end.line = -1;
        }

        Rect rc = _clientRect;

        FontRef font = font();
        for (int i = 0; i < _visibleLines.length; i++) {
            dstring txt = _visibleLines[i];
            Rect lineRect = rc;
            lineRect.left = _clientRect.left - _scrollPos.x;
            lineRect.right = lineRect.left + calcLineWidth(_content[_firstVisibleLine + i]);
            lineRect.top = _clientRect.top + i * _lineHeight;
            lineRect.bottom = lineRect.top + _lineHeight;
            Rect visibleRect = lineRect;
            visibleRect.left = _clientRect.left;
            visibleRect.right = _clientRect.right;
            drawLineBackground(buf, _firstVisibleLine + i, lineRect, visibleRect);
            if (_leftPaneWidth > 0) {
                Rect leftPaneRect = visibleRect;
                leftPaneRect.right = leftPaneRect.left;
                leftPaneRect.left -= _leftPaneWidth;
                drawLeftPane(buf, leftPaneRect, 0);
            }
            if (txt.length > 0) {
                CustomCharProps[] highlight = _visibleLinesHighlights[i];
                if (highlight)
                    font.drawColoredText(buf, rc.left - _scrollPos.x, rc.top + i * _lineHeight, txt, highlight, tabSize);
                else
                    font.drawText(buf, rc.left - _scrollPos.x, rc.top + i * _lineHeight, txt, textColor, tabSize);
            }
        }

        drawCaret(buf);
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

    this(string ID) {
        super(ID);
        _scrollLock = true;
        enabled = false;
        fontSize = 14;
		//fontFace = "Consolas,Lucida Console,Courier New";
		fontFace = "Consolas,DejaVuSansMono,Lucida Sans Typewriter,Courier New,Lucida Console";
		fontFamily = FontFamily.MonoSpace;
        minFontSize(8).maxFontSize(32); // allow font zoom with Ctrl + MouseWheel
    }
    /// append lines to the end of text
    void appendText(dstring text) {
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
        }
        updateScrollBars();
        if (_scrollLock) {
            _caretPos = TextPosition(lineCount > 0 ? lineCount - 1 : 0, 0);
            ensureCaretVisible();
        }
    }
}
