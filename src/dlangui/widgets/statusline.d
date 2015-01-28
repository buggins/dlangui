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

class StatusLinePanelBase : HorizontalLayout {
    this(string ID) {
        super(ID);
    }
}

class StatusLineTextPanel : StatusLinePanelBase {
    protected TextWidget _text;
    this(string ID) {
        super(ID);
        _text = new TextWidget(null, ""d);
        addChild(_text);
    }
    /// returns widget content text (override to support this)
    override @property dstring text() { return _text.text; }
    /// sets widget content text (override to support this)
    override @property Widget text(dstring s) { _text.text = s; return this; }
    /// sets widget content text (override to support this)
    override @property Widget text(UIString s) { _text.text = s; return this; }
}

class StatusLineIconPanel : StatusLinePanelBase {
    protected ImageWidget _icon;
    this(string ID) {
        super(ID);
        _icon = new ImageWidget(null);
        addChild(_icon);
    }
    @property string iconId() {
        return _icon.drawableId;
    }
    @property void iconId(string icon) {
        _icon.drawableId = icon;
    }
}

class StatusLineTextAndIconPanel : StatusLineTextPanel {
    protected ImageWidget _icon;
    this(string ID) {
        super(ID);
        _icon = new ImageWidget(null);
        _icon.minWidth = 20;
        _icon.minHeight = 20;
        _icon.alignment = Align.Center;
        addChild(_icon);
    }
    @property string iconId() {
        return _icon.drawableId;
    }
    @property void iconId(string icon) {
        _icon.drawableId = icon;
    }
}

class StatusLineBackgroundOperationPanel : StatusLineTextAndIconPanel {
    this(string ID) {
        super(ID);
        visibility = Visibility.Gone;
    }
    protected uint animationProgress;
    /// show / update / animate background operation status; when both parameters are nulls, hide background op status panel
    void setBackgroundOperationStatus(string icon, dstring statusText) {
        if (icon || statusText) {
            visibility = Visibility.Visible;
            text = statusText;
            iconId = icon;
            animationProgress = (animationProgress + 30) % 512;
            uint a = animationProgress;
            if (a >= 256)
                a = 512 - a;
            _icon.backgroundColor((a << 24) | (0x00FF00));
        } else {
            visibility = Visibility.Gone;
        }
    }
}

/// Status line control
class StatusLine : HorizontalLayout {
    protected TextWidget _defStatus;
    protected StatusLineBackgroundOperationPanel _backgroundOperationPanel;
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
        _backgroundOperationPanel = new StatusLineBackgroundOperationPanel("BACKGROUND_OP_STATUS");
        addChild(_backgroundOperationPanel);
    }
    /// set text to show in status line in specific panel
    void setStatusText(string itemId, dstring value) {
        _defStatus.text = value;
    }
    /// set text to show in status line
    void setStatusText(dstring value) {
        setStatusText(null, value);
    }
    /// show / update / animate background operation status; when both parameters are nulls, hide background op status panel
    void setBackgroundOperationStatus(string icon, dstring statusText = null) {
        _backgroundOperationPanel.setBackgroundOperationStatus(icon, statusText);
    }
}
