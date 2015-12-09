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
    protected int _defaultButtonIndex;
    protected dstring _text;
    this(UIString caption, UIString message, Window parentWindow, dstring initialText, void delegate(dstring result) handler) {
        super(caption, parentWindow, DialogFlag.Modal | DialogFlag.Popup);
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
	override void init() {
        TextWidget msg = new MultilineTextWidget("msg", _message);
        padding(Rect(10, 10, 10, 10));
        msg.padding(Rect(10, 10, 10, 10));
        EditLine editor = new EditLine("inputbox_editor");
        editor.layoutWidth = FILL_PARENT;
        editor.text = _text;
        editor.contentChange = delegate(EditableContent content) {
            _text = content.text;
        };
		addChild(msg);
		addChild(editor);
		addChild(createButtonsPanel(_actions, _defaultButtonIndex, 0));
    }

}
