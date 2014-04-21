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

import std.algorithm;

immutable dchar EOL = '\n';

/// split dstring by delimiters
dstring[] splitDString(dstring source, dchar delimiter = EOL) {
    int start = 0;
    dstring[] res;
    for (int i = 0; i <= source.length; i++) {
        if (i == source.length || source[i] == delimiter) {
            if (i >= start) {
                dstring line = i > start ? cast(dstring)(source[start .. i].dup) : ""d;
                res ~= line;
            }
            start = i + 1;
        }
    }
    return res;
}

/// text content position
struct TextPosition {
    /// line number, zero based
    int line;
    /// character position in line (0 == before first character)
    int pos;
}

/// text content range
struct TextRange {
    TextPosition start;
    TextPosition end;
    /// returns true if range is empty
    @property bool empty() {
        if (start.line > end.line)
            return true;
        if (start.line < end.line)
            return false;
        return (start.pos >= end.pos);
    }
}

/// action performed with editable contents
enum EditAction {
    /// insert content into specified position (range.start)
    Insert,
    /// delete content in range
    Delete,
    /// replace range content with new content
    Replace
}

/// edit operation details for EditableContent
class EditOperation {
    /// action performed
    protected EditAction _action;
	@property EditAction action() { return _action; }
    /// range
    protected TextRange _range;
	@property ref TextRange range() { return _range; }
    /// new content for range (if required for this action)
    protected dstring[] _content;
	@property ref dstring[] content() { return _content; }

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
}

interface EditableContentListener {
	bool onContentChange(EditableContent content, EditOperation operation, ref TextRange rangeBefore, ref TextRange rangeAfter);
}

/// editable plain text (multiline)
class EditableContent {
	/// listeners for edit operations
	Signal!EditableContentListener contentChangeListeners;

    this(bool multiline) {
        _multiline = multiline;
        _lines.length = 1; // initial state: single empty line
    }
    protected bool _multiline;
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
        _lines.length = 0;
        _lines = splitDString(newContent);
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

    /// returns maximum length of line
    int maxLineLength() {
        int m = 0;
        foreach(s; _lines)
            if (m < s.length)
                m = s.length;
        return m;
    }

	bool handleContentChange(EditOperation op, ref TextRange rangeBefore, ref TextRange rangeAfter) {
		return contentChangeListeners(this, op, rangeBefore, rangeAfter);
	}

	bool performOperation(EditOperation op) {
		if (op.action == EditAction.Delete) {
			TextRange rangeBefore = op.range;
			dchar[] buf;
			dstring srcline = _lines[op.range.start.line];
			buf ~= srcline[0 .. op.range.start.pos];
			buf ~= srcline[op.range.end.pos .. $];
			_lines[op.range.start.line] = cast(dstring)buf;
			TextRange rangeAfter = rangeBefore;
			rangeAfter.end = rangeAfter.start;
			handleContentChange(op, rangeBefore, rangeAfter);
			return true;
		} else if (op.action == EditAction.Insert) {
			// TODO: multiline
			TextPosition pos = op.range.start;
			TextRange rangeBefore = TextRange(pos, pos);
			dchar[] buf;
			dstring srcline = _lines[pos.line];
			dstring newline = op.content[0];
			buf ~= srcline[0 .. pos.pos];
			buf ~= newline;
			buf ~= srcline[pos.pos .. $];
			_lines[pos.line] = cast(dstring)buf;
			TextPosition newPos = pos;
			newPos.pos += newline.length;
			TextRange rangeAfter = TextRange(pos, newPos);
			handleContentChange(op, rangeBefore, rangeAfter);
			return true;
		}
		return false;
	}
}

enum EditorActions {
	None = 0,
	Left = 1000,
	Right,
	Up,
	Down,
	WordLeft,
	WordRight,
	PageUp,
	PageDown,
	LineBegin,
	LineEnd,
	DocumentBegin,
	DocumentEnd,
	DelPrevChar, // backspace
	DelNextChar, // del key
	DelPrevWord, // ctrl + backspace
	DelNextWord, // ctrl + del key
}

/// base for all editor widgets
class EditWidgetBase : WidgetGroup, EditableContentListener {
    protected EditableContent _content;
    protected Rect _clientRc;


    this(string ID) {
        super(ID);
        focusable = true;
		acceleratorMap.add( [
			new Action(EditorActions.Up, KeyCode.UP, 0),
			new Action(EditorActions.Down, KeyCode.DOWN, 0),
			new Action(EditorActions.Left, KeyCode.LEFT, 0),
			new Action(EditorActions.Right, KeyCode.RIGHT, 0),
			new Action(EditorActions.WordLeft, KeyCode.LEFT, KeyFlag.Control),
			new Action(EditorActions.WordRight, KeyCode.RIGHT, KeyFlag.Control),
			new Action(EditorActions.LineBegin, KeyCode.HOME, 0),
			new Action(EditorActions.LineEnd, KeyCode.END, 0),
			new Action(EditorActions.DocumentBegin, KeyCode.HOME, KeyFlag.Control),
			new Action(EditorActions.DocumentEnd, KeyCode.END, KeyFlag.Control),
			new Action(EditorActions.DelPrevChar, KeyCode.BACK, 0),
			new Action(EditorActions.DelNextChar, KeyCode.DEL, 0),
			new Action(EditorActions.DelPrevWord, KeyCode.BACK, KeyFlag.Control),
			new Action(EditorActions.DelNextWord, KeyCode.DEL, KeyFlag.Control),
		]);
    }

	abstract override bool onContentChange(EditableContent content, EditOperation operation, ref TextRange rangeBefore, ref TextRange rangeAfter);

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

    protected void updateCaretPositionByMouse(int x, int y) {
        TextPosition newPos = clientToTextPos(Point(x,y));
        if (newPos != _caretPos) {
            _caretPos = newPos;
            invalidate();
        }
    }

	override protected bool handleAction(Action a) {
        // todo: place some common action handling here
		return super.handleAction(a);
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
			if (ch != 8 && ch != '\n' && ch != '\r') { // ignore Backspace and Return
				EditOperation op = new EditOperation(EditAction.Insert, _caretPos, event.text);
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
            updateCaretPositionByMouse(event.x - _clientRc.left, event.y - _clientRc.top);
            invalidate();
	        return true;
	    }
	    if (event.action == MouseAction.Move && (event.flags & MouseButton.Left) != 0) {
            updateCaretPositionByMouse(event.x - _clientRc.left, event.y - _clientRc.top);
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
        styleId = "EDIT_LINE";
        text = initialContent;
    }

	override bool onContentChange(EditableContent content, EditOperation operation, ref TextRange rangeBefore, ref TextRange rangeAfter) {
		measureText();
		_caretPos = rangeAfter.end;
		invalidate();
		return true;
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
        res.right = res.left + 1;
        return res;
    }

    override protected TextPosition clientToTextPos(Point pt) {
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
        res.pos = _measuredText.length;
        return res;
    }

    protected void measureText() {
        FontRef font = font();
        //Point sz = font.textSize(text);
        _measuredText = text;
        _measuredTextWidths.length = _measuredText.length;
        int charsMeasured = font.measureText(_measuredText, _measuredTextWidths, int.max);
        _measuredTextSize.x = charsMeasured > 0 ? _measuredTextWidths[charsMeasured - 1]: 0;
        _measuredTextSize.y = font.height;
    }

    /// measure
    override void measure(int parentWidth, int parentHeight) { 
        measureText();
        measuredContent(parentWidth, parentHeight, _measuredTextSize.x, _measuredTextSize.y);
    }

	override protected bool handleAction(Action a) {
		switch (a.id) {
            case EditorActions.Left:
                if (_caretPos.pos > 0) {
                    _caretPos.pos--;
                    invalidate();
                }
                return true;
            case EditorActions.Right:
                if (_caretPos.pos < _measuredText.length) {
                    _caretPos.pos++;
                    invalidate();
                }
                return true;
            case EditorActions.DelPrevChar:
                if (_caretPos.pos > 0) {
                    TextRange range = TextRange(_caretPos, _caretPos);
                    range.start.pos--;
                    EditOperation op = new EditOperation(EditAction.Delete, range, null);
                    _content.performOperation(op);
                }
                return true;
            case EditorActions.DelNextChar:
                if (_caretPos.pos < _measuredText.length) {
                    TextRange range = TextRange(_caretPos, _caretPos);
                    range.end.pos++;
                    EditOperation op = new EditOperation(EditAction.Delete, range, null);
                    _content.performOperation(op);
                }
                return true;
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
            case EditorActions.DocumentBegin:
            case EditorActions.LineBegin:
                if (_caretPos.pos > 0) {
                    _caretPos.pos = 0;
                    invalidate();
                }
                return true;
            case EditorActions.DocumentEnd:
            case EditorActions.LineEnd:
                if (_caretPos.pos < _measuredText.length) {
                    _caretPos.pos = _measuredText.length;
                    invalidate();
                }
                return true;
            default:
                return false;
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
        font.drawText(buf, rc.left, rc.top + sz.y / 10, txt, textColor);
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

    protected int _lineHeight;

    protected Point _scrollPos;
    protected int _firstVisibleLine;

    protected int _maxLineWidth;
    protected int _numVisibleLines;             // number of lines visible in client area
    protected dstring[] _visibleLines;          // text for visible lines
    protected int[][] _visibleLinesMeasurement; // char positions for visible lines
    protected int[] _visibleLinesWidths; // width (in pixels) of visible lines

    protected Point measureVisibleText() {
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
            int charsMeasured = font.measureText(_visibleLines[i], _visibleLinesMeasurement[i], int.max);
            _visibleLinesWidths[i] = charsMeasured > 0 ? _visibleLinesMeasurement[i][charsMeasured - 1] : 0;
            if (sz.x < _visibleLinesWidths[i])
                sz.x = _visibleLinesWidths[i]; // width - max from visible lines
        }
        // find max line width. TODO: optimize!!!
        int[] buf;
        for (int i = 0; i < _content.length; i++) {
            dstring s = _content[i];
            if (buf.length < s.length)
                buf.length = s.length;
            int charsMeasured = font.measureText(s, buf, int.max);
            int w = 0;
            if (charsMeasured > 0)
                w = buf[charsMeasured - 1];
            if (sz.x < w)
                sz.x = w;
        }
        _maxLineWidth = sz.x;
        sz.y = _lineHeight * _content.length; // height - for all lines
        return sz;
    }

    protected void updateScrollbars() {
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

    protected void ensureCaretVisible() {
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

	override bool onContentChange(EditableContent content, EditOperation operation, ref TextRange rangeBefore, ref TextRange rangeAfter) {
		measureVisibleText();
		_caretPos = rangeAfter.end;
		invalidate();
		return true;
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
            res.pos = _visibleLines[lineIndex].length;
        } else {
            res.line = _firstVisibleLine + _visibleLines.length - 1;
            res.pos = _visibleLines[$ - 1].length;
        }
        return res;
    }

    protected void correctCaretPos() {
        if (_caretPos.line >= _content.length)
            _caretPos.line = _content.length - 1;
        if (_caretPos.line < 0)
            _caretPos.line = 0;
        dstring currentLine = _content[_caretPos.line];
        if (_caretPos.pos > currentLine.length)
            _caretPos.pos = currentLine.length;
        if (_caretPos.pos < 0)
            _caretPos.pos = 0;
    }

	override protected bool handleAction(Action a) {
        dstring currentLine = _content[_caretPos.line];
		switch (a.id) {
            case EditorActions.Left:
                correctCaretPos();
                if (_caretPos.pos > 0) {
                    _caretPos.pos--;
                    ensureCaretVisible();
                    invalidate();
                }
                return true;
            case EditorActions.Right:
                correctCaretPos();
                if (_caretPos.pos < currentLine.length) {
                    _caretPos.pos++;
                    ensureCaretVisible();
                    invalidate();
                }
                return true;
            case EditorActions.DelPrevChar:
                correctCaretPos();
                if (_caretPos.pos > 0) {
                    TextRange range = TextRange(_caretPos, _caretPos);
                    range.start.pos--;
                    EditOperation op = new EditOperation(EditAction.Delete, range, null);
                    _content.performOperation(op);
                    ensureCaretVisible();
                }
                return true;
            case EditorActions.DelNextChar:
                correctCaretPos();
                if (_caretPos.pos < currentLine.length) {
                    TextRange range = TextRange(_caretPos, _caretPos);
                    range.end.pos++;
                    EditOperation op = new EditOperation(EditAction.Delete, range, null);
                    _content.performOperation(op);
                    ensureCaretVisible();
                }
                return true;
            case EditorActions.Up:
                if (_caretPos.line > 0) {
                    _caretPos.line--;
                    ensureCaretVisible();
                    invalidate();
                }
                return true;
            case EditorActions.Down:
                if (_caretPos.line < _content.length - 1) {
                    _caretPos.line++;
                    ensureCaretVisible();
                    invalidate();
                }
                return true;
            case EditorActions.WordLeft:
                break;
            case EditorActions.WordRight:
                break;
            case EditorActions.PageUp:
                break;
            case EditorActions.PageDown:
                break;
            case EditorActions.DocumentBegin:
                if (_caretPos.pos > 0 || _caretPos.line > 0) {
                    _caretPos.line = 0;
                    _caretPos.pos = 0;
                    ensureCaretVisible();
                    invalidate();
                }
                return true;
            case EditorActions.LineBegin:
                if (_caretPos.pos > 0) {
                    _caretPos.pos = 0;
                    ensureCaretVisible();
                    invalidate();
                }
                return true;
            case EditorActions.DocumentEnd:
                if (_caretPos.line < _content.length - 1 || _caretPos.pos < _content[_content.length - 1].length) {
                    _caretPos.line = _content.length - 1;
                    _caretPos.pos = _content[_content.length - 1].length;
                    ensureCaretVisible();
                    invalidate();
                }
                return true;
            case EditorActions.LineEnd:
                if (_caretPos.pos < currentLine.length) {
                    _caretPos.pos = currentLine.length;
                    ensureCaretVisible();
                    invalidate();
                }
                return true;
            default:
                return false;
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
            if (txt.length > 0)
                font.drawText(buf, rc.left - _scrollPos.x, rc.top + i * _lineHeight, txt, textColor);
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
