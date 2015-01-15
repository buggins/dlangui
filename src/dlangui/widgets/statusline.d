// Written in the D programming language.

/**
This module contains definition for status line control.

Status line is usually shown in the bottom of window, and shows status of app.

Contains one or more text and/or icon items

Synopsis:

----
import dlangui.widgets.statusline;

----

Copyright: Vadim Lopatin, 2015
License:   Boost License 1.0
Authors:   Vadim Lopatin, coolreader.org@gmail.com
*/
module dlangui.widgets.statusline;

import dlangui.widgets.layouts;
import dlangui.widgets.controls;

/// Status line control
class StatusLine : HorizontalLayout {
    TextWidget _defStatus;
    this() {
        super("STATUS_LINE");
        styleId = STYLE_STATUS_LINE;
        init();
    }
    void init() {
        _defStatus = new TextWidget("STATUS_LINE_TEXT");
        _defStatus.layoutWidth(FILL_PARENT);
        _defStatus.text = "DLANGUI"d;
        addChild(_defStatus);
    }
    /// set text to show in status line in specific panel
    void setStatusText(string itemId, dstring value) {
        _defStatus.text = value;
    }
    /// set text to show in status line
    void setStatusText(dstring value) {
        setStatusText(null, value);
    }
}
