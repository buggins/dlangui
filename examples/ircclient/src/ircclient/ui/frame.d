module ircclient.ui.frame;

import dlangui;
import dlangui.dialogs.dialog;
import dlangui.core.settings;

import std.array : replaceFirst;

import ircclient.net.client;
import ircclient.ui.settingsdlg;
import ircclient.ui.settings;

import std.string : startsWith, indexOf;
import std.path;

// action codes
enum IRCActions : int {
    FileExit = 12300,
    EditPreferences,
    Connect,
    Disconnect,
    HelpAbout,
}

// actions
const Action ACTION_FILE_EXIT = new Action(IRCActions.FileExit, "MENU_FILE_EXIT"c, "document-close"c, KeyCode.KEY_X, KeyFlag.Alt);

const Action ACTION_EDIT_COPY = (new Action(EditorActions.Copy, "MENU_EDIT_COPY"c, "edit-copy"c, KeyCode.KEY_C, KeyFlag.Control)).addAccelerator(KeyCode.INS, KeyFlag.Control).disableByDefault();
const Action ACTION_EDIT_PASTE = (new Action(EditorActions.Paste, "MENU_EDIT_PASTE"c, "edit-paste"c, KeyCode.KEY_V, KeyFlag.Control)).addAccelerator(KeyCode.INS, KeyFlag.Shift).disableByDefault();
const Action ACTION_EDIT_CUT = (new Action(EditorActions.Cut, "MENU_EDIT_CUT"c, "edit-cut"c, KeyCode.KEY_X, KeyFlag.Control)).addAccelerator(KeyCode.DEL, KeyFlag.Shift).disableByDefault();
const Action ACTION_EDIT_UNDO = (new Action(EditorActions.Undo, "MENU_EDIT_UNDO"c, "edit-undo"c, KeyCode.KEY_Z, KeyFlag.Control)).disableByDefault();
const Action ACTION_EDIT_REDO = (new Action(EditorActions.Redo, "MENU_EDIT_REDO"c, "edit-redo"c, KeyCode.KEY_Y, KeyFlag.Control)).addAccelerator(KeyCode.KEY_Z, KeyFlag.Control|KeyFlag.Shift).disableByDefault();

const Action ACTION_EDIT_PREFERENCES = (new Action(IRCActions.EditPreferences, "MENU_EDIT_PREFERENCES"c, "document-properties"c, KeyCode.F9, 0));

const Action ACTION_CONNECT = (new Action(IRCActions.Connect, "MENU_CONNECT"c, "connect"c, KeyCode.F5, 0)).disableByDefault();
const Action ACTION_DISCONNECT = (new Action(IRCActions.Disconnect, "MENU_DISCONNECT"c, "disconnect"c, KeyCode.F5, 0)).disableByDefault();

const Action ACTION_HELP_ABOUT = new Action(IRCActions.HelpAbout, "MENU_HELP_ABOUT"c, "document-open"c, KeyCode.F1, 0);

class IRCFrame : AppFrame, IRCClientCallback {

    MenuItem mainMenuItems;
    IRCClient _client;
    IRCSettings _settings;


    this() {
    }

    ~this() {
        if (_client)
            destroy(_client);
    }

    override protected void initialize() {
        _appName = "DlangUI_IRCClient";
        _settings = new IRCSettings(buildNormalizedPath(settingsDir, "settings.json"));
        _settings.load();
        _settings.updateDefaults();
        _settings.save();
        super.initialize();
    }

    /// create main menu
    override protected MainMenu createMainMenu() {
        mainMenuItems = new MenuItem();
        MenuItem fileItem = new MenuItem(new Action(1, "MENU_FILE"));
        fileItem.add(//ACTION_FILE_NEW, ACTION_FILE_OPEN, 
                     ACTION_HELP_ABOUT, ACTION_EDIT_PREFERENCES, ACTION_FILE_EXIT);
        mainMenuItems.add(fileItem);
        //MenuItem editItem = new MenuItem(new Action(2, "MENU_EDIT"));
        //editItem.add(ACTION_EDIT_COPY, ACTION_EDIT_PASTE, 
        //             ACTION_EDIT_CUT, ACTION_EDIT_UNDO, ACTION_EDIT_REDO,
        //             ACTION_EDIT_INDENT, ACTION_EDIT_UNINDENT, ACTION_EDIT_TOGGLE_LINE_COMMENT, ACTION_EDIT_TOGGLE_BLOCK_COMMENT, ACTION_DEBUG_START);
        //
        //editItem.add(ACTION_EDIT_PREFERENCES);
        //mainMenuItems.add(editItem);
        MainMenu mainMenu = new MainMenu(mainMenuItems);
        return mainMenu;
    }


    /// create app toolbars
    override protected ToolBarHost createToolbars() {
        ToolBarHost res = new ToolBarHost();
        ToolBar tb;
        tb = res.getOrAddToolbar("Standard");
        tb.addButtons(//ACTION_FILE_NEW, ACTION_FILE_OPEN, ACTION_FILE_SAVE, ACTION_SEPARATOR, 
                      ACTION_CONNECT,
                      ACTION_DISCONNECT,
                      ACTION_SEPARATOR,
                      ACTION_EDIT_PREFERENCES,
                      ACTION_HELP_ABOUT);

        //tb = res.getOrAddToolbar("Edit");
        //tb.addButtons(ACTION_EDIT_COPY, ACTION_EDIT_PASTE, ACTION_EDIT_CUT, ACTION_SEPARATOR,
        //              ACTION_EDIT_UNDO, ACTION_EDIT_REDO, ACTION_EDIT_INDENT, ACTION_EDIT_UNINDENT);
        return res;
    }

    bool onCanClose() {
        // todo
        return true;
    }

    /// override to handle specific actions
    override bool handleAction(const Action a) {
        if (a) {
            switch (a.id) {
                case IRCActions.FileExit:
                    if (onCanClose())
                        window.close();
                    return true;
                case IRCActions.HelpAbout:
                    window.showMessageBox(UIString("About DlangUI IRC Client"d), 
                                          UIString("DLangUI IRC Client\n(C) Vadim Lopatin, 2015\nhttp://github.com/buggins/dlangui\nSimple IRC client"d));
                    return true;
                case IRCActions.EditPreferences:
                    showPreferences();
                    return true;
                case IRCActions.Connect:
                case IRCActions.Disconnect:
                    if (!_client || _client.state == SocketState.Disconnected)
                        connect();
                    else
                        _client.disconnect();
                    return true;
                default:
                    return super.handleAction(a);
            }
        }
        return false;
    }

    void showPreferences() {
        IRCSettings s = _settings.clone();
        SettingsDialog dlg = new SettingsDialog(this, s, !_client || _client.state == SocketState.Disconnected);
        dlg.dialogResult = delegate(Dialog dlg, const Action result) {
            if (result.id == ACTION_APPLY.id || result.id == ACTION_CONNECT.id) {
                _settings.applySettings(s.setting);
                _settings.save();
            }
            if (result.id == ACTION_CONNECT.id) {
                connect();
            }
        };
        dlg.show();
    }

    /// override to handle specific actions state (e.g. change enabled state for supported actions)
    override bool handleActionStateRequest(const Action a) {
        switch (a.id) {
            case IRCActions.HelpAbout:
            case IRCActions.EditPreferences:
                a.state = ACTION_STATE_ENABLED;
                return true;
            case IRCActions.Connect:
                a.state = !_client || _client.state == SocketState.Disconnected ? ACTION_STATE_ENABLED : ACTION_STATE_INVISIBLE;
                return true;
            case IRCActions.Disconnect:
                a.state = !_client || _client.state == SocketState.Disconnected ? ACTION_STATE_INVISIBLE : ACTION_STATE_ENABLED;
                return true;
            default:
                return super.handleActionStateRequest(a);
        }
    }

    TabWidget _tabs;
    /// create app body widget
    override protected Widget createBody() {
        _tabs = new TabWidget("TABS");
        _tabs.layoutWidth = FILL_PARENT;
        _tabs.layoutHeight = FILL_PARENT;
        //tabs.addTab(new IRCWindow("sample"), "Sample"d);
        statusLine.setStatusText(toUTF32("Not Connected"));
        _tabs.tabChanged = delegate(string newActiveTabId, string previousTabId) {
            if (IRCWindow w = cast(IRCWindow)_tabs.tabBody(newActiveTabId)) {
                w.onTabActivated();
            }
        };
        return _tabs;
    }

    void connect() {
        if (!_client) {
            _client = new IRCClient();
            AsyncSocket connection = window.createAsyncSocket(_client);
            _client.socket = connection;
            _client.callback = this;
        }
        _client.connect(_settings.host, _settings.port);
    }

    IRCWindow getOrCreateWindowFor(string party, bool activate) {
        string winId = party;
        IRCWindow w = cast(IRCWindow)_tabs.tabBody(winId);
        if (!w) {
            w = new IRCWindow(winId, this, _client);
            _tabs.addTab(w, toUTF32(winId));
            activate = true;
        }
        if (activate) {
            _tabs.selectTab(winId);
            w.onTabActivated();
        }
        return w;
    }

    void onIRCConnect(IRCClient client) {
        IRCWindow w = getOrCreateWindowFor(client.hostPort, true);
        w.addLine("connected to " ~ client.hostPort);
        client.sendMessage("USER " ~ _settings.userName ~ " 0 * :" ~ _settings.userRealName);
        client.nick(_settings.nick);
        string channel = _settings.defChannel;
        if (_settings.joinOnConnect && channel.length > 1 && channel.startsWith("#"))
            client.join(channel);
        statusLine.setStatusText(toUTF32("Connected to " ~ client.hostPort));
    }

    void onIRCDisconnect(IRCClient client) {
        IRCWindow w = getOrCreateWindowFor(client.hostPort, false);
        w.addLine("disconnected from " ~ client.hostPort);
        statusLine.setStatusText(toUTF32("Disconnected"));
    }

    void onIRCPing(IRCClient client, string message) {
        IRCWindow w = getOrCreateWindowFor(client.hostPort, false);
        w.addLine("PING " ~ message);
        client.pong(message);
    }

    void onIRCPrivmsg(IRCClient client, IRCAddress source, string target, string message) {
        string wid = target.startsWith("#") ? target : client.hostPort;
        if (target == client.nick)
            wid = source.nick;
        else if (source.nick == client.nick)
            wid = target;
        IRCWindow w = getOrCreateWindowFor(wid, false);
        w.addLine("<" ~ (!source.nick.empty ? source.nick : source.full) ~ "> " ~ message);
    }

    void onIRCNotice(IRCClient client, IRCAddress source, string target, string message) {
        IRCWindow w = getOrCreateWindowFor(target.startsWith("#") ? target : client.hostPort, false);
        w.addLine("-" ~ source.full ~ "- " ~ message);
    }

    void onIRCMessage(IRCClient client, IRCMessage message) {
        IRCWindow w = getOrCreateWindowFor(client.hostPort, false);
        switch (message.commandId) with (IRCCommand) {
            case JOIN:
            case PART:
                if (message.sourceAddress && !message.sourceAddress.nick.empty && message.target.startsWith("#")) {
                    w = getOrCreateWindowFor(message.target, false);
                    if (message.commandId == JOIN) {
                        w.addLine("* " ~ message.sourceAddress.longName ~ " has joined " ~ message.target);
                    } else {
                        w.addLine("* " ~ message.sourceAddress.longName ~ " has left " ~ message.target ~ (message.message.empty ? "" : ("(Reason: " ~ message.message ~ ")")));
                    }
                    IRCChannel channel = _client.channelByName(message.target);
                    w.updateUserList(channel);
                }
                return;
            case CHANNEL_NAMES_LIST_END:
                if (message.target.startsWith("#")) {
                    w = getOrCreateWindowFor(message.target, false);
                    IRCChannel channel = _client.channelByName(message.target);
                    w.updateUserList(channel);
                }
                return;
            default:
                if (message.commandId < 1000) {
                    // custom server messages
                    w.addLine(message.message);
                    return;
                }
                break;
        }
        w.addLine(message.msg);
    }
}

enum IRCWindowKind {
    Server,
    Channel,
    Private
}

class IRCWindow : VerticalLayout, EditorActionHandler {
private:
    IRCFrame _frame;
    LogWidget _editBox;
    StringListWidget _listBox;
    EditLine _editLine;
    IRCClient _client;
    IRCWindowKind _kind;
    dstring[] _userNames;
public:
    this(string ID, IRCFrame frame, IRCClient client) {
        super(ID);
        _client = client;
        _frame = frame;
        layoutWidth = FILL_PARENT;
        layoutHeight = FILL_PARENT;
        HorizontalLayout hlayout = new HorizontalLayout();
        hlayout.layoutWidth = FILL_PARENT;
        hlayout.layoutHeight = FILL_PARENT;
        _editBox = new LogWidget();
        _editBox.layoutWidth = FILL_PARENT;
        _editBox.layoutHeight = FILL_PARENT;
        hlayout.addChild(_editBox);
        if (ID.startsWith("#")) {
            _listBox = new StringListWidget();
            _listBox.layoutHeight = FILL_PARENT;
            _listBox.layoutWidth = WRAP_CONTENT;
            _listBox.minWidth = 100;
            _listBox.maxWidth = 200;
            _listBox.orientation = Orientation.Vertical;
            //_listBox.items = ["Nick1"d, "Nick2"d];
            hlayout.addChild(new ResizerWidget(null, Orientation.Horizontal));
            hlayout.addChild(_listBox);

            _listBox.itemClick = delegate(Widget source, int itemIndex) {
                auto user = itemIndex >= 0 && itemIndex < _userNames.length ? toUTF8(_userNames[itemIndex]) : null;
                if (!user.empty && user != _client.nick) {
                    _frame.getOrCreateWindowFor(user, true);
                }
                return true;
            };

            _kind = IRCWindowKind.Channel;
        } else {
            if (id.indexOf(':') >= 0)
                _kind = IRCWindowKind.Server;
            else
                _kind = IRCWindowKind.Private;
        }
        addChild(hlayout);
        _editLine = new EditLine();
        addChild(_editLine);
        _editLine.editorAction = this;
    }
    void addLine(string s) {
        _editBox.appendText(toUTF32(s ~ "\n"));
        if (visible)
            window.update();
    }
    void updateUserList(IRCChannel channel) {
        _userNames = channel.userNames;
        _listBox.items = _userNames;
        if (window)
            window.update();
    }
    bool onEditorAction(const Action action) {
        if (!_editLine.text.empty) {
            string s = toUTF8(_editLine.text);
            _editLine.text = ""d;
            if (s.startsWith("/")) {
                Log.d("Custom command: " ~ s);
                // command
                string cmd = parseDelimitedParameter(s);

                if (cmd == "/quit") {
                    _client.quit(s);
                    return true;
                }

                string param = parseDelimitedParameter(s);
                if (cmd == "/nick" && !param.empty) {
                    _client.nick(param);
                } else if (cmd == "/join" && param.startsWith("#")) {
                    _client.join(param);
                } else if (cmd == "/part" && param.startsWith("#")) {
                    _client.part(param, s);
                } else if (cmd == "/msg" && !param.empty && !s.empty) {
                    _client.privMsg(param, s);
                } else {
                    Log.d("Unknown command: " ~ cmd);
                    addLine("Supported commands: /nick /join /part /msg /quit");
                }
            } else {
                // message
                if (_kind != IRCWindowKind.Server) {
                    _client.privMsg(id, s);
                }
            }
        }
        return true;
    }
    void onTabActivated() {
        _editLine.setFocus();
    }
}
