module ircclient.ui.settingsdlg;

import dlangui.core.stdaction;
import dlangui.dialogs.dialog;
import dlangui.widgets.widget;
import dlangui.dml.parser;
import ircclient.ui.frame;

class SettingsDialog : Dialog {
    IRCFrame _frame;
    this(IRCFrame parent) {
        super(UIString("IRC Client Settings"d), parent.window, 
              DialogFlag.Modal | DialogFlag.Resizable | DialogFlag.Popup, 500, 400);
        _icon = "dlangui-logo1";
        _frame = parent;
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
                        EditLine { id: edHost; text: "irc.freenode.net"; layoutWidth: fill; minWidth: 400 }
                        TextWidget { text: "IRC Server port" }
                        EditLine { id: edHost; text: "6667"; layoutWidth: fill }
                        TextWidget { text: " " }
                        TextWidget { text: " " }
                        TextWidget { text: "Nickname" }
                        EditLine { id: edHost; text: "dlangui_test"; layoutWidth: fill }
                        TextWidget { text: "Alternate nickname" }
                        EditLine { id: edHost; text: "dlangui_tst2"; layoutWidth: fill }
                        TextWidget { text: "Username" }
                        EditLine { id: edHost; text: "user"; layoutWidth: fill }
                        TextWidget { text: "Real name" }
                        EditLine { id: edHost; text: "User Real Name"; layoutWidth: fill }
                        TextWidget { text: " " }
                        TextWidget { text: " " }
                        TextWidget { text: "Channel to join on connect" }
                        EditLine { id: edHost; text: "#d"; layoutWidth: fill }
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
        addChild(createButtonsPanel([ACTION_APPLY, ACTION_CANCEL], 0, 0));
    }

    override void close(const Action action) {
        Action newaction = action.clone();
        //if (action.id == IDEActions.FileNewWorkspace || action.id == IDEActions.FileNewProject) {
        //    newaction.objectParam = _result;
        //}
        super.close(newaction);
    }
}
