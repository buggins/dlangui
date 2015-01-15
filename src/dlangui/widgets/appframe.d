// Written in the D programming language.

/**
This module contains definition for main widget for usual application - with menu and status bar.

When you need MainMenu, StatusBar, Toolbars in your app, reuse this class.

Synopsis:

----
import dlangui.widgets.appframe;

----

Copyright: Vadim Lopatin, 2015
License:   Boost License 1.0
Authors:   Vadim Lopatin, coolreader.org@gmail.com
*/
module dlangui.widgets.appframe;

import dlangui.widgets.widget;
import dlangui.widgets.menu;
import dlangui.widgets.layouts;
import dlangui.widgets.statusline;

class AppFrame : VerticalLayout, MenuItemClickHandler {
    protected MainMenu _mainMenu;
    protected StatusLine _statusLine;
    protected Widget _body;
    /// main menu widget
    @property MainMenu mainMenu() { return _mainMenu; }
    /// status line widget
    @property StatusLine statusLine() { return _statusLine; }
    /// body widget
    @property Widget frameBody() { return _body; }

    this() {
        super("APP_FRAME");
        layoutWidth = FILL_PARENT;
        layoutHeight = FILL_PARENT;
        init();
    }

    protected void init() {
        _mainMenu = createMainMenu();
		_mainMenu.onMenuItemClickListener = &onMenuItemClick;
        _statusLine = createStatusLine();
        _body = createBody();
        addChild(_mainMenu);
        addChild(_body);
        addChild(_statusLine);
    }

    /// override to handle main menu commands
    override bool onMenuItemClick(MenuItem item) {
        return false;
    }

    /// create main menu
    protected MainMenu createMainMenu() {
        return new MainMenu(new MenuItem());
    }

    /// create app status line widget
    protected StatusLine createStatusLine() {
        return new StatusLine();
    }

    /// create app body widget
    protected Widget createBody() {
        Widget res = new Widget("APP_FRAME_BODY");
        res.layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT);
        return res;
    }
}
