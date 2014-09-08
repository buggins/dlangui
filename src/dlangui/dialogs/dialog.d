// Written in the D programming language.

/**
This module contains common Dialog implementation.


Synopsis:

----
import dlangui.platforms.common.platform;

----

Copyright: Vadim Lopatin, 2014
License:   Boost License 1.0
Authors:   Vadim Lopatin, coolreader.org@gmail.com
*/
module dlangui.dialogs.dialog;

import dlangui.core.i18n;
import dlangui.core.signals;
import dlangui.widgets.layouts;
import dlangui.widgets.controls;
import dlangui.platforms.common.platform;

import std.conv;

/// dialog flag bits
enum DialogFlag : uint {
    /// dialog is modal
    Modal = 1,
    /// dialog can be resized
    Resizable = 2,
}

interface DialogResultHandler {
	public void onDialogResult(Dialog dlg, Action result);
}

/// base for all dialogs
class Dialog : VerticalLayout {
    protected Window _window;
    protected Window _parentWindow;
    protected UIString _caption;
    protected uint _flags;

	Signal!DialogResultHandler onDialogResult;

    this(UIString caption, Window parentWindow = null, uint flags = DialogFlag.Modal) {
        super("dlg");
        _caption = caption;
        _parentWindow = parentWindow;
    }

	@property UIString windowCaption() {
		return _caption;
	}

	@property Dialog windowCaption(dstring caption) {
		_caption = caption;
		if (_window)
			_window.windowCaption = caption;
        return this;
	}

	@property Dialog windowCaption(UIString caption) {
		_caption = caption;
		if (_window)
			_window.windowCaption = caption;
        return this;
	}

	/// create panel with buttons based on list of actions
	Widget createButtonsPanel(const Action[] actions, int defaultActionIndex, int splitBeforeIndex) {
		LinearLayout res = new HorizontalLayout("buttons");
		res.layoutWidth(FILL_PARENT);
		for (int i = 0; i < actions.length; i++) {
			if (splitBeforeIndex == i)
				res.addChild(new HSpacer());
			const Action a = actions[i];
			string id = "btn" ~ to!string(a.id);	
			ImageTextButton btn = new ImageTextButton(id, a.iconId, a.label);
			if (defaultActionIndex == i)
				btn.setState(State.Default);
			btn.onClickListener = delegate(Widget source) {
				return handleAction(a);
			};
			res.addChild(btn);
		}
		return res;
	}

	/// override to implement creation of dialog controls
	void init() {
	}

    /// shows dialog
    void show() {
		init();
        uint wflags = 0;
        if (_flags & DialogFlag.Modal)
            wflags |= WindowFlag.Modal;
        if (_flags & DialogFlag.Resizable)
            wflags |= WindowFlag.Resizable;
        _window = Platform.instance.createWindow(_caption, _parentWindow, wflags);
        _window.mainWidget = this;
        _window.show();
    }
}
