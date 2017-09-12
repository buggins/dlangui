// Written in the D programming language.

/**
This module contains common Dialog implementation.


Synopsis:

----
import dlangui.dialogs.msgbox;

// show message box with single Ok button
window.showMessageBox(UIString("Dialog title"d), UIString("Some message"d));

// show message box with OK and CANCEL buttons, cancel by default, and handle its result
window.showMessageBox(UIString("Dialog title"d), UIString("Some message"d), [ACTION_OK, ACTION_CANCEL], 1, delegate bool(const Action a) {
    if (a.id == StandardAction.Ok)
        Log.d("OK pressed");
    else if (a.id == StandardAction.Cancel)
        Log.d("CANCEL pressed");
    return true;
});

----

Copyright: Vadim Lopatin, 2014
License:   Boost License 1.0
Authors:   Vadim Lopatin, coolreader.org@gmail.com
*/
module dlangui.dialogs.msgbox;

import dlangui.core.i18n;
import dlangui.core.signals;
import dlangui.core.stdaction;
import dlangui.widgets.layouts;
import dlangui.widgets.controls;
import dlangui.platforms.common.platform;
import dlangui.dialogs.dialog;

/// Message box
class MessageBox : Dialog {
    protected UIString _message;
    protected const(Action)[] _actions;
    this(UIString caption, UIString message, Window parentWindow = null, const(Action) [] buttons = [ACTION_OK], int defaultButtonIndex = 0, bool delegate(const Action result) handler = null) {
        super(caption, parentWindow, DialogFlag.Modal | (Platform.instance.uiDialogDisplayMode & DialogDisplayMode.messageBoxInPopup ? DialogFlag.Popup : 0));
        _message = message;
        _actions = buttons;
        _defaultButtonIndex = defaultButtonIndex;
        if (handler) {
            dialogResult = delegate (Dialog dlg, const Action action) {
                handler(action);
            };
        }
    }
    /// override to implement creation of dialog controls
    override void initialize() {
        TextWidget msg = new MultilineTextWidget("msg", _message);
        padding(Rect(10, 10, 10, 10));
        msg.padding(Rect(10, 10, 10, 10));
        addChild(msg);
        addChild(createButtonsPanel(_actions, _defaultButtonIndex, 0));
    }

}
