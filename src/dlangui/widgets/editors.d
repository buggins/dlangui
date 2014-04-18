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
    EditableContent _content;
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

    /// measure
    override void measure(int parentWidth, int parentHeight) { 
        FontRef font = font();
        Point sz = font.textSize(text);
        measuredContent(parentWidth, parentHeight, sz.x, sz.y);
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
    }
}

