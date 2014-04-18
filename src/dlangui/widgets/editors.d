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

/// editable plain text (multiline)
class EditableContent {
    this(bool multiline) {
        _multiline = multiline;
        _lines.length = 1; // initial state: single empty line
    }
    protected bool _multiline;
    protected dchar[][] _lines;
    /// returns all lines concatenated delimited by '\n'
    @property dstring text() {
        if (_lines.length == 0)
            return "";
        dchar[] buf;
        foreach(item;_lines) {
            if (buf.length)
                buf ~= '\n';
            buf ~= item;
        }
        return cast(dstring)buf;
    }
    @property EditableContent text(dstring newContent) {
        _lines.length = 0;
        // TODO: split into lines
        _lines ~= newContent.dup;
        return this;
    }
    /// returns line text
    @property int length() { return cast(int)_lines.length; }
    dstring opIndex(int index) {
        return line(index);
    }
    /// returns line text by index
    dstring line(int index) {
        return _lines[index].dup;
    }
}

/// single line editor
class EditLine : Widget {
    EditableContent _content;
    this(string ID) {
        super(ID);
        _content = new EditableContent(false);
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
}

