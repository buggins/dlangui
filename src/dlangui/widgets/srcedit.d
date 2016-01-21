// Written in the D programming language.

/**
This module contains implementation of source code editor widget.

SourceEdit - base class for source code editors, with line numbering, syntax highlight, etc.

Synopsis:

----
import dlangui.widgets.srcedit;

----

Copyright: Vadim Lopatin, 2014
License:   Boost License 1.0
Authors:   Vadim Lopatin, coolreader.org@gmail.com
*/
module dlangui.widgets.srcedit;

import dlangui.graphics.fonts;
import dlangui.widgets.editors;
import dlangui.widgets.styles;

class SourceEdit : EditBox {
    this(string ID) {
        super(ID);
        fontFace = "Menlo,Consolas,DejaVuSansMono,DejaVu Sans Mono,Liberation Mono,Lucida Sans Typewriter,Courier New,Lucida Console";
        //fontFace = "Consolas,Lucida Console,Courier New";
        fontFamily = FontFamily.MonoSpace;
        fontSize = makePointSize(10);
        layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT);
        minFontSize(9).maxFontSize(75); // allow font zoom with Ctrl + MouseWheel
        showModificationMarks = true;

        _showLineNumbers = true;

    }
    this() {
        this("SRCEDIT");
    }
    protected string _filename;
    @property string filename() {
        return _filename;
    }
    /// load from file
    bool load(string fn) {
        if (content.load(fn)) {
            _filename = fn;
            requestLayout();
            return true;
        }
        // failed
        _filename = null;
        return false;
    }

    bool save(string fn) {
        if (content.save(fn)) {
            _filename = fn;
            requestLayout();
            window.update();
            return true;
        }
        // failed
        requestLayout();
        window.update();
        _filename = null;
        return false;
    }

}
