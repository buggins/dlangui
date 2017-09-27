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
import dlangui.widgets.editors;

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
        _icon.minWidth = BACKEND_CONSOLE ? 1 : 20;
        _icon.minHeight = BACKEND_CONSOLE ? 1 : 20;
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

class StatusLineEditorStatePanel : StatusLineTextPanel {
    EditorStateInfo _editorState;

    this(string ID = "statusLineEditorStateLabel") {
        super(ID);
        _text.alignment = Align.VCenter | Align.Right;
        //_text.backgroundColor = 0x80FF0000;
        //backgroundColor = 0x8000FF00;
        updateSize();
        visibility = Visibility.Gone;
    }

    dstring makeStateString() {
        if (!_editorState.active)
            return null;
        import std.string : format;
        return "%d : %d    ch=0x%05x    %s  "d.format(_editorState.line, _editorState.col, _editorState.character, _editorState.replaceMode ? "OVR"d : "INS"d);
    }

    private void updateSize() {
        FontRef fnt = font;
        Point sz = fnt.textSize("  ch=0x00000    000000 : 000    INS  "d);
        _text.minWidth = sz.x;
    }

    /// handle theme change: e.g. reload some themed resources
    override void onThemeChanged() {
        super.onThemeChanged();
        updateSize();
    }

    void setState(Widget source, ref EditorStateInfo editorState) {
        if (editorState != _editorState) {
            _editorState = editorState;
            text = makeStateString();
            Visibility newVisibility = _editorState.active ? Visibility.Visible : Visibility.Gone;
            if (newVisibility != visibility)
                visibility = newVisibility;
        }
    }
}

/// Status line control
class StatusLine : HorizontalLayout, EditorStateListener {
    protected TextWidget _defStatus;
    protected StatusLineBackgroundOperationPanel _backgroundOperationPanel;
    protected StatusLineEditorStatePanel _editorStatePanel;
    this() {
        super("STATUS_LINE");
        styleId = STYLE_STATUS_LINE;
        initialize();
    }
    void initialize() {
        _defStatus = new TextWidget("STATUS_LINE_TEXT");
        _defStatus.layoutWidth(FILL_PARENT);
        _defStatus.text = " "d;
        addChild(_defStatus);
        _backgroundOperationPanel = new StatusLineBackgroundOperationPanel("BACKGROUND_OP_STATUS");
        _editorStatePanel = new StatusLineEditorStatePanel("EDITOR_STATE_PANEL");
        addChild(_backgroundOperationPanel);
        addChild(_editorStatePanel);
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

    /// EditorStateListener implementation
    override void onEditorStateUpdate(Widget source, ref EditorStateInfo editorState) {
        _editorStatePanel.setState(source, editorState);
    }

    void hideEditorState() {
        EditorStateInfo editorState;
        _editorStatePanel.setState(null, editorState);
    }
}
