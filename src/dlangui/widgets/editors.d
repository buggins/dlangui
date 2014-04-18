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
import dlangui.core.signals;

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
    EditAction action;
    /// range
    TextRange range;
    /// new content for range (if required for this action)
    dstring[] content;
}

/// editable plain text (multiline)
class EditableContent {
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
    /// returns line text by index
    dstring line(int index) {
        return _lines[index];
    }
}

/// single line editor
class EditLine : Widget {
    protected EditableContent _content;
    protected Rect _clientRc;


    this(string ID, dstring initialContent = null) {
        super(ID);
        _content = new EditableContent(false);
        styleId = "EDIT_LINE";
        focusable = true;
        text = initialContent;
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

    protected dstring _measuredText;
    protected int[] _measuredTextWidths;
    protected Point _measuredTextSize;

    protected TextPosition _caretPos;
    protected TextRange _selectionRange;

    protected Rect textPosToClient(TextPosition p) {
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

    protected TextPosition clientToTextPos(Point pt) {
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
        Point sz = font.textSize(text);
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

    protected void updateCaretPositionByMouse(int x, int y) {
        TextPosition newPos = clientToTextPos(Point(x,y));
        if (newPos != _caretPos) {
            _caretPos = newPos;
            invalidate();
        }
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

