// Written in the D programming language.

/**
This module contains common Dialog implementation.


Use to create custom dialogs.

Synopsis:

----
import dlangui.dialogs.dialog;

----

Copyright: Vadim Lopatin, 2014
License:   Boost License 1.0
Authors:   Vadim Lopatin, coolreader.org@gmail.com
*/
module dlangui.dialogs.dialog;

import dlangui.core.i18n;
import dlangui.core.signals;
import dlangui.core.stdaction;
import dlangui.widgets.layouts;
import dlangui.widgets.controls;
import dlangui.widgets.winframe;
import dlangui.widgets.popup;
import dlangui.platforms.common.platform;

import std.conv;

/// dialog flag bits
enum DialogFlag : uint {
    /// dialog is modal
    Modal = 1,
    /// dialog can be resized
    Resizable = 2,
    /// dialog is show in popup widget inside current window instead of separate window
    Popup = 4,
}

/// slot to pass dialog result
interface DialogResultHandler {
    public void onDialogResult(Dialog dlg, const Action result);
}

/// base for all dialogs
class Dialog : VerticalLayout {
    protected Window _window;
    protected Window _parentWindow;
    protected PopupWidget _popup;
    protected UIString _caption;
    protected uint _flags;
    protected string _icon;
    protected int _initialWidth;
    protected int _initialHeight;
    protected int _defaultButtonIndex = -1;

    Signal!DialogResultHandler dialogResult;

    this(UIString caption, Window parentWindow = null, uint flags = DialogFlag.Modal, int initialWidth = 0, int initialHeight = 0) {
        super("dialog-main-widget");
        _initialWidth = initialWidth;
        _initialHeight = initialHeight;
        _caption = caption;
        _parentWindow = parentWindow;
        _flags = flags;
        _icon = "";
    }

    /**
        Measure widget according to desired width and height constraints. (Step 1 of two phase layout).
    */
    override void measure(int parentWidth, int parentHeight) {
        super.measure(parentWidth, parentHeight);
        if ((_flags & DialogFlag.Resizable) && (_flags & DialogFlag.Popup)) {
            Point sz = Point(_parentWindow.width * 4 / 5, _parentWindow.height * 4 / 5);
            measuredContent(parentWidth, parentHeight, sz.x, sz.y);
        }
    }

    /// get icon resource id
    @property string windowIcon() {
        return _icon;
    }

    /// set icon resource id
    @property Dialog windowIcon(string iconResourceId) {
        _icon = iconResourceId;
        if (_window)
            _window.windowIconId = _icon.length ? _icon : Platform.instance.defaultWindowIcon;
        return this;
    }

    @property UIString windowCaption() {
        return _caption;
    }

    /// set window caption
    @property Dialog windowCaption(dstring caption) {
        _caption = caption;
        if (_window)
            _window.windowCaption = caption;
        return this;
    }

    /// get window caption
    @property Dialog windowCaption(UIString caption) {
        _caption = caption;
        if (_window)
            _window.windowCaption = caption;
        return this;
    }

    protected const(Action) [] _buttonActions;

    protected ImageTextButton _defaultButton;
    protected ImageTextButton _cancelButton;
    /// create panel with buttons based on list of actions
    Widget createButtonsPanel(const(Action) [] actions, int defaultActionIndex, int splitBeforeIndex) {
        _defaultButtonIndex = defaultActionIndex;
        _buttonActions = actions;
        LinearLayout res = new HorizontalLayout("buttons");
        res.layoutWidth(FILL_PARENT);
        res.layoutWeight = 0;
        for (int i = 0; i < actions.length; i++) {
            if (splitBeforeIndex == i)
                res.addChild(new HSpacer());
            const Action a = actions[i];
            string id = "btn" ~ to!string(a.id);
            ImageTextButton btn = new ImageTextButton(id, a.iconId, a.label);
            if (defaultActionIndex == i) {
                btn.setState(State.Default);
                _defaultButton = btn;
            }
            if (a.id == StandardAction.Cancel || a.id == StandardAction.No)
                _cancelButton = btn;
            btn.action = a.clone();
            res.addChild(btn);
        }
        return res;
    }

    /// map key to action
    override Action findKeyAction(uint keyCode, uint flags) {
        foreach(a; _buttonActions) {
            if (a.checkAccelerator(keyCode, flags))
                return a.clone;
        }
        return super.findKeyAction(keyCode, flags);
    }

    /// Custom handling of actions
    override bool handleAction(const Action action) {
        foreach(const Action a; _buttonActions)
            if (a.id == action.id) {
                close(action);
                return true;
            }
        return false;
    }

    /// override to implement creation of dialog controls
    void initialize() {
    }

    /** Notify about dialog result, and then close dialog.

        If onDialogResult listener is assigned, pass action to it.

        If no onDialogResult listener, pass to owner window.

        If action is null, no result dispatching will occur.
      */
    void close(const Action action) {
        if (action) {
            if (dialogResult.assigned)
                dialogResult(this, action);
            else if (_parentWindow && !_popup)
                _parentWindow.dispatchAction(action);
        }
        if (_popup)
            _parentWindow.executeInUiThread( (){ _parentWindow.removePopup(_popup); });
        else
            window.close();
    }

    /// shows dialog
    void show() {
        initialize();
        uint wflags = 0;
        if (_flags & DialogFlag.Modal)
            wflags |= WindowFlag.Modal;
        if (_flags & DialogFlag.Resizable) {
            wflags |= WindowFlag.Resizable;
            layoutWidth = FILL_PARENT;
            layoutHeight = FILL_PARENT;
        }
        if (_flags & DialogFlag.Popup) {
            DialogFrame _frame = new DialogFrame(this, _cancelButton !is null);
            if (_cancelButton) {
                _frame.closeButtonClick = delegate(Widget w) {
                    close(_cancelButton.action);
                    return true;
                };
            }
            _popup = _parentWindow.showPopup(_frame);
            _popup.flags(PopupFlags.Modal);
        } else {
            if (_initialWidth == 0 && _initialHeight == 0)
                wflags |= WindowFlag.MeasureSize;
            _window = Platform.instance.createWindow(_caption, _parentWindow, wflags, _initialWidth, _initialHeight);
            windowIcon = _icon;
            _window.backgroundColor = currentTheme.customColor("dialog_background");
            _window.mainWidget = this;
            _window.show();
        }
        onShow();
    }

    /// called after window with dialog is shown
    void onShow() {
        // override to do something useful
        if (_defaultButton)
            _defaultButton.setFocus();
    }

    /// calls close with default action; returns true if default action is found and invoked
    protected bool closeWithDefaultAction() {
        if (_defaultButtonIndex >= 0 && _defaultButtonIndex < _buttonActions.length) {
            close(_buttonActions[_defaultButtonIndex]);
            return true;
        }
        return false;
    }

    /// calls close with cancel action (if found); returns true if cancel action is found and invoked
    protected bool closeWithCancelAction() {
        for (int i = 0; i < _buttonActions.length; i++) {
            if (_buttonActions[i].id == StandardAction.Cancel || _buttonActions[i].id == StandardAction.No) {
                close(_buttonActions[i]); // the Cancel/No action, not the default one (#1020)
                return true;
            }
        }
        return false;
    }

    /// a plain Enter was pressed (key down) while the dialog was open and no child used it (#728)
    private bool _enterKeyDown;

    /**
        Keys that reach the dialog (the focused child didn't use them):
        Enter presses the default button (Windows convention, #728): a control that uses Enter itself (a multi-line
        editor, a focused button that presses itself, a list, an open popup) keeps it. Only an Enter pressed while the
        dialog is open counts: not the release of the Enter that opened it. Ctrl+Enter presses the default button
        from any control; Esc closes with the Cancel/No action.
    */
    override bool onKeyEvent(KeyEvent event) {
        if (event.keyCode == KeyCode.RETURN && event.noModifiers
                && _defaultButtonIndex >= 0 && _defaultButtonIndex < _buttonActions.length) {
            if (event.action == KeyAction.KeyDown) {
                _enterKeyDown = true;
                return true;
            }
            if (event.action == KeyAction.KeyUp && _enterKeyDown) {
                _enterKeyDown = false;
                return closeWithDefaultAction();
            }
        }
        if (event.action == KeyAction.KeyUp) {
            if (event.keyCode == KeyCode.RETURN && event.modifiers == KeyFlag.Control) {
                // Ctrl+Enter: default action
                return closeWithDefaultAction();
            }
            if (event.keyCode == KeyCode.ESCAPE && event.noModifiers) {
                // ESC: cancel/no action
                return closeWithCancelAction();
            }
        }
        return super.onKeyEvent(event);
    }
}

/// frame with caption for dialog
class DialogFrame : WindowFrame {
    protected Dialog _dialog;
    this(Dialog dialog, bool enableCloseButton) {
        super(dialog.id ~ "_frame", enableCloseButton);
        styleId = STYLE_FLOATING_WINDOW;
        _dialog = dialog;
        _caption.text = _dialog.windowCaption.value;
        bodyWidget = _dialog;
    }
}

// Esc closes the dialog with its Cancel/No action, not with the default one (#1020)
unittest {
    import dlangui.widgets.styles : useTestTheme;
    import std.typecons : Rebindable;
    auto _ = useTestTheme();
    static class TestDialog : Dialog {
        Rebindable!(const Action) closedWith;
        this() { super(UIString.fromRaw("test"d)); }
        override void close(const Action action) { closedWith = action; }
    }
    // without icons: no image cache in unittests; Yes/No have no Esc accelerator, so Esc gets here
    const yes = new Action(StandardAction.Yes, "Yes"d);
    const no = new Action(StandardAction.No, "No"d);
    foreach (defaultIndex; [0, -1]) {
        auto d = new TestDialog();
        scope(exit) destroy(d);
        d.addChild(d.createButtonsPanel([yes, no], defaultIndex, 0));
        assert(d.onKeyEvent(new KeyEvent(KeyAction.KeyUp, KeyCode.ESCAPE, 0)));
        assert(d.closedWith is no);
    }
}

// plain Enter that reaches the dialog presses the default button, only when pressed while the dialog is open (#728)
unittest {
    import dlangui.widgets.styles : useTestTheme;
    import std.typecons : Rebindable;
    auto _ = useTestTheme();
    static class TestDialog : Dialog {
        Rebindable!(const Action) closedWith;
        this() { super(UIString.fromRaw("test"d)); }
        override void close(const Action action) { closedWith = action; }
    }
    const ok = new Action(StandardAction.Ok, "OK"d);
    const cancel = new Action(StandardAction.Cancel, "Cancel"d);
    auto d = new TestDialog();
    scope(exit) destroy(d);
    d.addChild(d.createButtonsPanel([ok, cancel], 0, 0));
    // the release of an Enter pressed before the dialog opened
    assert(!d.onKeyEvent(new KeyEvent(KeyAction.KeyUp, KeyCode.RETURN, 0)));
    assert(d.closedWith is null);
    // Shift+Enter isn't plain Enter
    d.onKeyEvent(new KeyEvent(KeyAction.KeyDown, KeyCode.RETURN, KeyFlag.Shift));
    d.onKeyEvent(new KeyEvent(KeyAction.KeyUp, KeyCode.RETURN, KeyFlag.Shift));
    assert(d.closedWith is null);
    assert(d.onKeyEvent(new KeyEvent(KeyAction.KeyDown, KeyCode.RETURN, 0)));
    assert(d.closedWith is null);
    assert(d.onKeyEvent(new KeyEvent(KeyAction.KeyUp, KeyCode.RETURN, 0)));
    assert(d.closedWith is ok);

    // no default button: Enter isn't used
    auto d2 = new TestDialog();
    scope(exit) destroy(d2);
    d2.addChild(d2.createButtonsPanel([ok, cancel], -1, 0));
    assert(!d2.onKeyEvent(new KeyEvent(KeyAction.KeyDown, KeyCode.RETURN, 0)));
    assert(!d2.onKeyEvent(new KeyEvent(KeyAction.KeyUp, KeyCode.RETURN, 0)));
    assert(d2.closedWith is null);
}
