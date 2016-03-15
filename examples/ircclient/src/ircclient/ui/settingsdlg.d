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
                        HorizontalLayout {
                        layoutWidth: fill; layoutHeight: fill
                                VerticalLayout {
                                margins: 5
                                        layoutWidth: 25%; layoutHeight: fill
                                        TextWidget { text: "Project template" }
                                    StringListWidget { 
                                    id: projectTemplateList 
                                            layoutWidth: wrap; layoutHeight: fill
                                    }
                                }
                            VerticalLayout {
                            margins: 5
                                    layoutWidth: 40%; layoutHeight: fill
                                    TextWidget { text: "Template description" }
                                EditBox { 
                                id: templateDescription; readOnly: true 
                                    layoutWidth: fill; layoutHeight: fill
                                }
                            }
                            VerticalLayout {
                            layoutWidth: 35%; layoutHeight: fill
                                    margins: 5
                                    TextWidget { text: "Directory layout" }
                                EditBox { 
                                id: directoryLayout; readOnly: true
                                    layoutWidth: fill; layoutHeight: fill
                                }
                            }
                        }
                    TableLayout {
                    margins: 5
                            colCount: 2
                            layoutWidth: fill; layoutHeight: wrap
                            TextWidget { text: "" }
                        CheckBox { id: cbCreateWorkspace; text: "Create new solution"; checked: true }
                        TextWidget { text: "Workspace name" }
                        EditLine { id: edWorkspaceName; text: "newworkspace"; layoutWidth: fill }
                        TextWidget { text: "" }
                        CheckBox { id: cbCreateWorkspaceSubdir; text: "Create subdirectory for workspace"; checked: true }
                        TextWidget { text: "Project name" }
                        EditLine { id: edProjectName; text: "newproject"; layoutWidth: fill }
                        TextWidget { text: "" }
                        CheckBox { id: cbCreateSubdir; text: "Create subdirectory for project"; checked: true }
                        TextWidget { text: "Location" }
                        DirEditLine { id: edLocation; layoutWidth: fill }
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
