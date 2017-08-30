module ircclient.ui.settingsdlg;

import dlangui.core.stdaction;
import dlangui.dialogs.dialog;
import dlangui.widgets.widget;
import dlangui.dml.parser;
import ircclient.ui.frame;
import ircclient.ui.settings;
import std.utf : toUTF32;
import std.conv : to;

class SettingsDialog : Dialog {
    IRCFrame _frame;
    IRCSettings _settings;
    bool _allowConnect;
    this(IRCFrame parent, IRCSettings settings, bool allowConnect) {
        super(UIString.fromRaw("IRC Client Settings"d), parent.window,
              DialogFlag.Modal | DialogFlag.Resizable | DialogFlag.Popup, 500, 400);
        _icon = "dlangui-logo1";
        _frame = parent;
        _settings = settings;
        _allowConnect = allowConnect;
    }

    /// override to implement creation of dialog controls
    override void initialize() {
        super.initialize();
        Widget content;
        try {
            content = parseML(q{
                VerticalLayout {
                    id: vlayout
                    padding: Rect { 5, 5, 5, 5 }
                    layoutWidth: fill; layoutHeight: fill
                    TableLayout {
                        margins: 5
                        colCount: 2
                        layoutWidth: fill; layoutHeight: wrap

                        TextWidget { text: "IRC Server host name" }
                        EditLine { id: edHost; layoutWidth: fill; minWidth: 400 }
                        TextWidget { text: "IRC Server port" }
                        EditLine { id: edPort; layoutWidth: fill }
                        TextWidget { text: " " }
                        TextWidget { text: " " }
                        TextWidget { text: "Nickname" }
                        EditLine { id: edNick; layoutWidth: fill }
                        TextWidget { text: "Alternate nickname" }
                        EditLine { id: edAlternateNick; layoutWidth: fill }
                        TextWidget { text: "Username" }
                        EditLine { id: edUsername; layoutWidth: fill }
                        TextWidget { text: "Real name" }
                        EditLine { id: edRealName; layoutWidth: fill }
                        TextWidget { text: " " }
                        TextWidget { text: " " }
                        TextWidget { text: "Channel to join on connect" }
                        EditLine { id: edChannel; layoutWidth: fill }
                        TextWidget { text: " " }
                        CheckBox { id: cbCreateWorkspace; text: "Connect on startup"; checked: true }
                    }
                    TextWidget { id: statusText; text: ""; layoutWidth: fill }
                }
            });
        } catch (Exception e) {
            Log.e("Exceptin while parsing DML", e);
            throw e;
        }
        addChild(content);
        addChild(createButtonsPanel(_allowConnect ? [ACTION_CONNECT, ACTION_APPLY, ACTION_CANCEL] : [ACTION_APPLY, ACTION_CANCEL], 0, 0));
        settingsToControls();
    }

    void settingsToControls() {
        childById("edHost").text = toUTF32(_settings.host);
        childById("edPort").text = toUTF32(to!string(_settings.port));
        childById("edNick").text = toUTF32(_settings.nick);
        childById("edAlternateNick").text = toUTF32(_settings.alternateNick);
        childById("edUsername").text = toUTF32(_settings.userName);
        childById("edRealName").text = toUTF32(_settings.userRealName);
        childById("edChannel").text = toUTF32(_settings.defChannel);
    }

    void controlsToSettings() {
        _settings.host = toUTF8(childById("edHost").text);
        try {
            _settings.port = cast(ushort)to!ulong(childById("edPort").text);
        } catch (Exception e) {
            // ignore
            _settings.port = 6667;
        }
        _settings.nick = toUTF8(childById("edNick").text);
        _settings.alternateNick = toUTF8(childById("edAlternateNick").text);
        _settings.userName = toUTF8(childById("edUsername").text);
        _settings.userRealName = toUTF8(childById("edRealName").text);
        _settings.defChannel = toUTF8(childById("edChannel").text);
    }

    override void close(const Action action) {
        Action newaction = action.clone();
        if (action.id != ACTION_CANCEL.id) {
            controlsToSettings();
            // TODO: validate
        }
        //if (action.id == IDEActions.FileNewWorkspace || action.id == IDEActions.FileNewProject) {
        //    newaction.objectParam = _result;
        //}
        super.close(newaction);
    }
}
