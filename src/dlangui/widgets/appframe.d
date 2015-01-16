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
import dlangui.widgets.toolbars;

class AppFrame : VerticalLayout, MenuItemClickHandler {
    protected MainMenu _mainMenu;
    protected StatusLine _statusLine;
    protected ToolBarHost _toolbarHost;
    protected Widget _body;
    /// main menu widget
    @property MainMenu mainMenu() { return _mainMenu; }
    /// status line widget
    @property StatusLine statusLine() { return _statusLine; }
    /// tool bar host
    @property ToolBarHost toolbars() { return _toolbarHost; }
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
        _toolbarHost = createToolbars();
        _statusLine = createStatusLine();
        _body = createBody();
        _body.focusGroup = true;
        if (_mainMenu) {
            _mainMenu.onMenuItemClickListener = &onMenuItemClick;
            addChild(_mainMenu);
        }
        if (_toolbarHost)
            addChild(_toolbarHost);
        addChild(_body);
        if (_statusLine)
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


    /// create app toolbars
    protected ToolBarHost createToolbars() {
        ToolBarHost res = new ToolBarHost();
        return res;
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
