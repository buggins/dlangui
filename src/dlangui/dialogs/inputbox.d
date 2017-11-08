module dlangui.dialogs.inputbox;

import dlangui.core.i18n;
import dlangui.core.signals;
import dlangui.core.stdaction;
import dlangui.widgets.layouts;
import dlangui.widgets.controls;
import dlangui.widgets.editors;
import dlangui.platforms.common.platform;
import dlangui.dialogs.dialog;

/// Message box
class InputBox : Dialog {
    protected UIString _message;
    protected const(Action)[] _actions;
    protected EditLine _editor;
    protected dstring _text;
    this(UIString caption, UIString message, Window parentWindow, dstring initialText, void delegate(dstring result) handler) {
        super(caption, parentWindow, DialogFlag.Modal | (Platform.instance.uiDialogDisplayMode & DialogDisplayMode.inputBoxInPopup ? DialogFlag.Popup : 0));
        _message = message;
        _actions = [ACTION_OK, ACTION_CANCEL];
        _defaultButtonIndex = 0;
        _text = initialText;
        if (handler) {
            dialogResult = delegate (Dialog dlg, const Action action) {
                if (action.id == ACTION_OK.id) {
                    handler(_text);
                }
            };
        }
    }
    /// override to implement creation of dialog controls
    override void initialize() {
        TextWidget msg = new MultilineTextWidget("msg", _message);
        padding(Rect(10, 10, 10, 10));
        msg.padding(Rect(10, 10, 10, 10));
        _editor = new EditLine("inputbox_editor");
        _editor.layoutWidth = FILL_PARENT;
        _editor.text = _text;
        _editor.enterKey = delegate (EditWidgetBase editor) {
            close(_buttonActions[_defaultButtonIndex]);
            return true;
        };
        _editor.contentChange = delegate(EditableContent content) {
            _text = content.text;
        };
        _editor.setDefaultPopupMenu();
        addChild(msg);
        addChild(_editor);
        addChild(createButtonsPanel(_actions, _defaultButtonIndex, 0));
    }

    /// called after window with dialog is shown
    override void onShow() {
        super.onShow();
        _editor.selectAll();
        _editor.setFocus();
    }

    override dstring text() const {
        return _text;
    }

    override Widget text(dstring t) {
        _text = t;
        return this;
    }

    override Widget text(UIString s) {
        _text = s;
        return this;
    }
}
