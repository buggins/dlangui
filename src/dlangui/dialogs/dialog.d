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
import dlangui.widgets.layouts;
import dlangui.widgets.controls;
import dlangui.platforms.common.platform;

/// dialog flag bits
enum DialogFlag : uint {
    /// dialog is modal
    Modal = 1,
    /// dialog can be resized
    Resizable = 2,
}

/// base for all dialogs
class Dialog : VerticalLayout {
    protected Window _window;
    protected Window _parentWindow;
    protected UIString _caption;
    protected uint _flags;

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

    /// shows dialog
    void show() {
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
