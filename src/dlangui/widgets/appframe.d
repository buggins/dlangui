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

/// to update status for background operation in AppFrame
class BackgroundOperationWatcher {

    protected bool _cancelRequested;
    /// returns cancel status
    @property bool cancelRequested() { return _cancelRequested; }
    /// returns description of background operation to show in status line
    @property dstring description() { return null; }
    /// returns icon of background operation to show in status line
    @property string icon() { return null; }
    /// returns desired update interval
    @property long updateInterval() { return 100; }
    /// update background operation status
    void update() {
        // do some work here
        // when task is done or cancelled, finished should return true
        // either simple update of status or some real work can be done here
    }
    /// request cancel - once cancelled, finished should return true
    void cancel() {
        _cancelRequested = true;
    }
    /// return true when task is done - to remove it from AppFrame
    @property bool finished() { 
        return false; 
    }
    /// will be called by app frame when BackgroundOperationWatcher is to be removed
    void removing() {
    }
}

/// base class for application frame with main menu, status line, toolbars
class AppFrame : VerticalLayout, MenuItemClickHandler, MenuItemActionHandler {
    protected MainMenu _mainMenu;
    protected StatusLine _statusLine;
    protected ToolBarHost _toolbarHost;
    protected Widget _body;
    protected BackgroundOperationWatcher _currentBackgroundOperation;
    protected ulong _currentBackgroundOperationTimer;

    /// timer handler
    override bool onTimer(ulong timerId) {
        if (timerId == _currentBackgroundOperationTimer) {
            if (_currentBackgroundOperation) {
                _currentBackgroundOperation.update();
                if (_currentBackgroundOperation.finished) {
                    _currentBackgroundOperation.removing();
                    destroy(_currentBackgroundOperation);
                    _currentBackgroundOperation = null;
                    _currentBackgroundOperationTimer = 0;
                    return false;
                }
                return true;
            } else {
                _currentBackgroundOperationTimer = 0;
            }
        }
        return false; // stop timer
    }

    /// set background operation to show in status
    void setBackgroundOperation(BackgroundOperationWatcher op) {
        if (_currentBackgroundOperation) {
            _currentBackgroundOperation.removing();
            destroy(_currentBackgroundOperation);
            _currentBackgroundOperation = null;
        }
        _currentBackgroundOperation = op;
        if (op)
            _currentBackgroundOperationTimer = setTimer(op.updateInterval);
    }

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

    /// map key to action
    override Action findKeyAction(uint keyCode, uint flags) {
        if (_mainMenu) {
            Action action = _mainMenu.findKeyAction(keyCode, flags);
            if (action)
                return action;
        }
        return super.findKeyAction(keyCode, flags);
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
        // default handling: call Action handler
        return onMenuItemAction(item.action);
    }

    /// override to handle main menu actions
	bool onMenuItemAction(const Action action) {
        // default handling: dispatch action using window (first offered to focused control, then to main widget)
        return window.dispatchAction(action);
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

    /// override to handle specific actions
	override bool handleAction(const Action a) {
        return false;
    }

}
