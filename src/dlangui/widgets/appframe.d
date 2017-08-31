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
import dlangui.core.files;
import dlangui.core.settings;
import std.path;

/// to update status for background operation in AppFrame
class BackgroundOperationWatcher {

    protected AppFrame _frame;
    protected bool _cancelRequested;
    protected bool _finished;

    this(AppFrame frame) {
        _frame = frame;
    }

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
        if (_frame.statusLine)
            _frame.statusLine.setBackgroundOperationStatus(icon, description);
    }
    /// request cancel - once cancelled, finished should return true
    void cancel() {
        _cancelRequested = true;
    }
    /// return true when task is done - to remove it from AppFrame
    @property bool finished() {
        return _finished;
    }
    /// will be called by app frame when BackgroundOperationWatcher is to be removed
    void removing() {
        // in this handler, you can post new background operation to AppFrame
        if (_frame.statusLine)
            _frame.statusLine.setBackgroundOperationStatus(null, null);
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


    this() {
        super("APP_FRAME");
        layoutWidth = FILL_PARENT;
        layoutHeight = FILL_PARENT;
        _appName = "dlangui";
        initialize();
    }

    protected string _appName;
    /// override to return some identifier for app, e.g. to use as settings directory name
    @property string appCodeName() {
        return _appName;
    }
    /// override to return some identifier for app, e.g. to use as settings directory name
    @property AppFrame appCodeName(string name) {
        _appName = name;
        return this;
    }

    protected string _settingsDir;
    /// Application settings directory; by default, returns .appcodename directory in user's home directory (e.g. /home/user/.appcodename, C:\Users\User\AppData\Roaming\.appcodename); override to change it
    @property string settingsDir() {
        if (!_settingsDir)
            _settingsDir = appDataPath("." ~ appCodeName);
        return _settingsDir;
    }

    protected SettingsFile _shortcutSettings;
    /// returns shortcuts settings object
    @property SettingsFile shortcutSettings() {
        if (!_shortcutSettings) {
            _shortcutSettings = new SettingsFile(buildNormalizedPath(settingsDir, "shortcuts.json"));
        }
        return _shortcutSettings;
    }

    bool applyShortcutsSettings() {
        if (shortcutSettings.loaded) {
            foreach(key, value; _shortcutSettings.map) {
                int actionId = actionNameToId(key);
                if (actionId == 0) {
                    Log.e("applyShortcutsSettings: Unknown action name: ", key);
                } else {
                    Accelerator[] accelerators = [];
                    if (value.isArray) {
                        for (int i = 0; i < value.length; i++) {
                            string v = value[i].str;
                            Accelerator a;
                            if (a.parse(v)) {
                                //Log.d("Read accelerator for action ", key, " : ", a.toString);
                                accelerators ~= a;
                            } else
                                Log.e("applyShortcutsSettings: cannot parse accelerator: ", v);
                        }
                    } else {
                        string v = value.str;
                        Accelerator a;
                        if (a.parse(v)) {
                            //Log.d("Read accelerator for action ", key, " : ", a.toString);
                            accelerators ~= a;
                        } else
                            Log.e("applyShortcutsSettings: cannot parse accelerator: ", v);
                    }
                    setActionAccelerators(actionId, accelerators);
                }
            }
            return true;
        }
        return false;
    }

    /// set shortcut settings from actions and save to file - useful for initial settings file version creation
    bool saveShortcutsSettings(const(Action)[] actions) {
        shortcutSettings.clear();
        foreach(a; actions) {
            string name = actionIdToName(a.id);
            if (name) {
                const(Accelerator)[] acc = a.accelerators;
                if (acc.length > 0) {
                    if (acc.length == 1) {
                        _shortcutSettings[name] = acc[0].toString;
                    } else {
                        string[] array;
                        foreach(accel; acc) {
                            array ~= accel.toString;
                        }
                        _shortcutSettings[name] = array;
                    }
                }
            }
        }
        return shortcutSettings.save();
    }

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
                    requestActionsUpdate();
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
        requestActionsUpdate();
    }

    /// main menu widget
    @property MainMenu mainMenu() { return _mainMenu; }
    /// status line widget
    @property StatusLine statusLine() { return _statusLine; }
    /// tool bar host
    @property ToolBarHost toolbars() { return _toolbarHost; }
    /// body widget
    @property Widget frameBody() { return _body; }

    /// map key to action
    override Action findKeyAction(uint keyCode, uint flags) {
        if (_mainMenu) {
            Action action = _mainMenu.findKeyAction(keyCode, flags);
            if (action)
                return action;
        }
        return super.findKeyAction(keyCode, flags);
    }

    protected void initialize() {
        _mainMenu = createMainMenu();
        _toolbarHost = createToolbars();
        _statusLine = createStatusLine();
        _body = createBody();
        _body.focusGroup = true;
        if (_mainMenu) {
            _mainMenu.menuItemClick = &onMenuItemClick;
            addChild(_mainMenu);
        }
        if (_toolbarHost)
            addChild(_toolbarHost);
        addChild(_body);
        if (_statusLine)
            addChild(_statusLine);
        updateShortcuts();
    }

    /// override it
    protected void updateShortcuts() {
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
