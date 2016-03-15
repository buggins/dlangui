module dmledit;

import dlangui;
import dlangui.dialogs.filedlg;
import dlangui.dialogs.dialog;
import dlangui.dml.dmlhighlight;
import std.array : replaceFirst;
import ircclient.net.client;
import std.string : startsWith, indexOf;

mixin APP_ENTRY_POINT;

// action codes
enum IDEActions : int {
    //ProjectOpen = 1010000,
    FileNew = 1010000,
    FileOpen,
    FileSave,
    FileSaveAs,
    FileSaveAll,
    FileClose,
    FileExit,
    EditPreferences,
    DebugStart,
    HelpAbout,
}

// actions
const Action ACTION_FILE_NEW = new Action(IDEActions.FileNew, "MENU_FILE_NEW"c, "document-new", KeyCode.KEY_N, KeyFlag.Control);
const Action ACTION_FILE_SAVE = (new Action(IDEActions.FileSave, "MENU_FILE_SAVE"c, "document-save", KeyCode.KEY_S, KeyFlag.Control)).disableByDefault();
const Action ACTION_FILE_SAVE_AS = (new Action(IDEActions.FileSaveAs, "MENU_FILE_SAVE_AS"c)).disableByDefault();
const Action ACTION_FILE_OPEN = new Action(IDEActions.FileOpen, "MENU_FILE_OPEN"c, "document-open", KeyCode.KEY_O, KeyFlag.Control);
const Action ACTION_FILE_EXIT = new Action(IDEActions.FileExit, "MENU_FILE_EXIT"c, "document-close"c, KeyCode.KEY_X, KeyFlag.Alt);
const Action ACTION_EDIT_COPY = (new Action(EditorActions.Copy, "MENU_EDIT_COPY"c, "edit-copy"c, KeyCode.KEY_C, KeyFlag.Control)).addAccelerator(KeyCode.INS, KeyFlag.Control).disableByDefault();
const Action ACTION_EDIT_PASTE = (new Action(EditorActions.Paste, "MENU_EDIT_PASTE"c, "edit-paste"c, KeyCode.KEY_V, KeyFlag.Control)).addAccelerator(KeyCode.INS, KeyFlag.Shift).disableByDefault();
const Action ACTION_EDIT_CUT = (new Action(EditorActions.Cut, "MENU_EDIT_CUT"c, "edit-cut"c, KeyCode.KEY_X, KeyFlag.Control)).addAccelerator(KeyCode.DEL, KeyFlag.Shift).disableByDefault();
const Action ACTION_EDIT_UNDO = (new Action(EditorActions.Undo, "MENU_EDIT_UNDO"c, "edit-undo"c, KeyCode.KEY_Z, KeyFlag.Control)).disableByDefault();
const Action ACTION_EDIT_REDO = (new Action(EditorActions.Redo, "MENU_EDIT_REDO"c, "edit-redo"c, KeyCode.KEY_Y, KeyFlag.Control)).addAccelerator(KeyCode.KEY_Z, KeyFlag.Control|KeyFlag.Shift).disableByDefault();
const Action ACTION_EDIT_INDENT = (new Action(EditorActions.Indent, "MENU_EDIT_INDENT"c, "edit-indent"c, KeyCode.TAB, 0)).addAccelerator(KeyCode.KEY_BRACKETCLOSE, KeyFlag.Control).disableByDefault();
const Action ACTION_EDIT_UNINDENT = (new Action(EditorActions.Unindent, "MENU_EDIT_UNINDENT"c, "edit-unindent", KeyCode.TAB, KeyFlag.Shift)).addAccelerator(KeyCode.KEY_BRACKETOPEN, KeyFlag.Control).disableByDefault();
const Action ACTION_EDIT_TOGGLE_LINE_COMMENT = (new Action(EditorActions.ToggleLineComment, "MENU_EDIT_TOGGLE_LINE_COMMENT"c, null, KeyCode.KEY_DIVIDE, KeyFlag.Control)).disableByDefault();
const Action ACTION_EDIT_TOGGLE_BLOCK_COMMENT = (new Action(EditorActions.ToggleBlockComment, "MENU_EDIT_TOGGLE_BLOCK_COMMENT"c, null, KeyCode.KEY_DIVIDE, KeyFlag.Control|KeyFlag.Shift)).disableByDefault();
const Action ACTION_EDIT_PREFERENCES = (new Action(IDEActions.EditPreferences, "MENU_EDIT_PREFERENCES"c, null)).disableByDefault();
const Action ACTION_DEBUG_START = new Action(IDEActions.DebugStart, "MENU_DEBUG_UPDATE_PREVIEW"c, "debug-run"c, KeyCode.F5, 0);
const Action ACTION_HELP_ABOUT = new Action(IDEActions.HelpAbout, "MENU_HELP_ABOUT"c);

class IRCFrame : AppFrame, IRCClientCallback {

    MenuItem mainMenuItems;
    IRCClient _client;

    ~this() {
        if (_client)
            destroy(_client);
    }

    override protected void initialize() {
        _appName = "DlangUI_IRCClient";
        super.initialize();
    }

    /// create main menu
    override protected MainMenu createMainMenu() {
        mainMenuItems = new MenuItem();
        MenuItem fileItem = new MenuItem(new Action(1, "MENU_FILE"));
        fileItem.add(//ACTION_FILE_NEW, ACTION_FILE_OPEN, 
                     ACTION_FILE_EXIT);
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
                      ACTION_DEBUG_START);

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
                case IDEActions.FileExit:
                    if (onCanClose())
                        window.close();
                    return true;
                case IDEActions.HelpAbout:
                    window.showMessageBox(UIString("About DlangUI IRC Client"d), 
                                          UIString("DLangUI IRC Client\n(C) Vadim Lopatin, 2015\nhttp://github.com/buggins/dlangui\nSimple IRC client"d));
                    return true;
                case IDEActions.EditPreferences:
                    //showPreferences();
                    return true;
                case IDEActions.DebugStart:
                    connect();
                    return true;
                default:
                    return super.handleAction(a);
            }
        }
        return false;
    }

    /// override to handle specific actions state (e.g. change enabled state for supported actions)
    override bool handleActionStateRequest(const Action a) {
        switch (a.id) {
            case IDEActions.HelpAbout:
            case IDEActions.FileNew:
            case IDEActions.FileSave:
            case IDEActions.FileOpen:
            case IDEActions.DebugStart:
            case IDEActions.EditPreferences:
                a.state = ACTION_STATE_ENABLED;
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
        return _tabs;
    }

    void connect() {
        if (!_client) {
            _client = new IRCClient();
            AsyncSocket connection = window.createAsyncSocket(_client);
            _client.socket = connection;
            _client.callback = this;
        }
        _client.connect("irc.freenode.net", 6667);
    }

    IRCWindow getOrCreateWindowFor(string party) {
        string winId = party;
        IRCWindow w = cast(IRCWindow)_tabs.tabBody(winId);
        if (!w) {
            w = new IRCWindow(winId, _client);
            _tabs.addTab(w, toUTF32(winId));
        }
        return w;
    }

    void onIRCConnect(IRCClient client) {
        IRCWindow w = getOrCreateWindowFor(client.hostPort);
        w.addLine("connected to " ~ client.hostPort);
        client.sendMessage("USER username 0 * :Real name");
        client.nick("dlangui_irc");
        client.join("#clienttest");
        statusLine.setStatusText(toUTF32("Connected to " ~ client.hostPort));
    }

    void onIRCDisconnect(IRCClient client) {
        IRCWindow w = getOrCreateWindowFor(client.hostPort);
        w.addLine("disconnected from " ~ client.hostPort);
        statusLine.setStatusText(toUTF32("Disconnected"));
    }

    void onIRCPing(IRCClient client, string message) {
        IRCWindow w = getOrCreateWindowFor(client.hostPort);
        w.addLine("PING " ~ message);
        client.pong(message);
    }

    void onIRCPrivmsg(IRCClient client, IRCAddress source, string target, string message) {
        string wid = target.startsWith("#") ? target : client.hostPort;
        if (target == client.nick)
            wid = source.nick;
        else if (source.nick == client.nick)
            wid = target;
        IRCWindow w = getOrCreateWindowFor(wid);
        w.addLine("<" ~ (!source.nick.empty ? source.nick : source.full) ~ "> " ~ message);
    }

    void onIRCNotice(IRCClient client, IRCAddress source, string target, string message) {
        IRCWindow w = getOrCreateWindowFor(target.startsWith("#") ? target : client.hostPort);
        w.addLine("-" ~ source.full ~ "- " ~ message);
    }

    void onIRCMessage(IRCClient client, IRCMessage message) {
        IRCWindow w = getOrCreateWindowFor(client.hostPort);
        switch (message.commandId) with (IRCCommand) {
            case JOIN:
            case PART:
                if (message.sourceAddress && !message.sourceAddress.nick.empty && message.target.startsWith("#")) {
                    w = getOrCreateWindowFor(message.target);
                    if (message.commandId == JOIN) {
                        w.addLine("* " ~ message.sourceAddress.longName ~ " has joined " ~ message.target);
                    } else {
                        w.addLine("* " ~ message.sourceAddress.longName ~ " has left " ~ message.target ~ (message.message.empty ? "" : ("(Reason: " ~ message.message ~ ")")));
                    }
                }
                return;
            case CHANNEL_NAMES_LIST_END:
                if (message.target.startsWith("#")) {
                    w = getOrCreateWindowFor(message.target);
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
    LogWidget _editBox;
    StringListWidget _listBox;
    EditLine _editLine;
    IRCClient _client;
    IRCWindowKind _kind;
    this(string ID, IRCClient client) {
        super(ID);
        _client = client;
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
        _listBox.items = channel.userNames;
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
}

/// entry point for dlangui based application
extern (C) int UIAppMain(string[] args) {

    // embed non-standard resources listed in views/resources.list into executable
    embeddedResourceList.addResources(embedResourcesFromList!("resources.list")());

    /// set font gamma (1.0 is neutral, < 1.0 makes glyphs lighter, >1.0 makes glyphs bolder)
    FontManager.fontGamma = 0.8;
    FontManager.hintingMode = HintingMode.Normal;

    // create window
    Window window = Platform.instance.createWindow("DlangUI IRC Client"d, null, WindowFlag.Resizable, 700, 470);

    // create some widget to show in window
    window.windowIcon = drawableCache.getImage("dlangui-logo1");


    // create some widget to show in window
    window.mainWidget = new IRCFrame();

    // show window
    window.show();

    // run message loop
    return Platform.instance.enterMessageLoop();
}
