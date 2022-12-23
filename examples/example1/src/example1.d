// Written in the D programming language.

/**
This app is a demo for most of DlangUI library features.

Synopsis:

----
    dub run dlangui:example1
----

Copyright: Vadim Lopatin, 2014
License:   Boost License 1.0
Authors:   Vadim Lopatin, coolreader.org@gmail.com
 */
module example1;

import dlangui;
import dlangui.dialogs.dialog;
import dlangui.dialogs.filedlg;
import dlangui.dialogs.msgbox;
import std.stdio;
import std.conv;
import std.utf;
import std.algorithm;
import std.path;

import widgets;

mixin APP_ENTRY_POINT;

class TextEditorWidget : VerticalLayout {
    EditBox _edit;
    this(string ID) {
        super(ID);
        _edit = new EditBox("editor");
        _edit.layoutWidth = FILL_PARENT;
        _edit.layoutHeight = FILL_PARENT;
        addChild(_edit);
    }
}

Widget createEditorSettingsControl(EditWidgetBase editor) {
    HorizontalLayout res = new HorizontalLayout("editor_options");
    res.addChild((new CheckBox("wantTabs", "wantTabs"d)).checked(editor.wantTabs).addOnCheckChangeListener(delegate(Widget, bool checked) { editor.wantTabs = checked; return true;}));
    res.addChild((new CheckBox("useSpacesForTabs", "useSpacesForTabs"d)).checked(editor.useSpacesForTabs).addOnCheckChangeListener(delegate(Widget, bool checked) { editor.useSpacesForTabs = checked; return true;}));
    res.addChild((new CheckBox("readOnly", "readOnly"d)).checked(editor.readOnly).addOnCheckChangeListener(delegate(Widget, bool checked) { editor.readOnly = checked; return true;}));
    res.addChild((new CheckBox("showLineNumbers", "showLineNumbers"d)).checked(editor.showLineNumbers).addOnCheckChangeListener(delegate(Widget, bool checked) { editor.showLineNumbers = checked; return true;}));
    res.addChild((new CheckBox("fixedFont", "fixedFont"d)).checked(editor.fontFamily == FontFamily.MonoSpace).addOnCheckChangeListener(delegate(Widget, bool checked) {
        if (checked)
            editor.fontFamily(FontFamily.MonoSpace).fontFace("Courier New");
        else
            editor.fontFamily(FontFamily.SansSerif).fontFace("Arial");
        return true;
    }));
    res.addChild((new CheckBox("tabSize", "Tab size 8"d)).checked(editor.tabSize == 8).addOnCheckChangeListener(delegate(Widget, bool checked) {
        if (checked)
            editor.tabSize(8);
        else
            editor.tabSize(4);
        return true;
    }));
    return res;
}

/// entry point for dlangui based application
extern (C) int UIAppMain(string[] args)
{
    // always use trace, even for release builds
    //Log.setLogLevel(LogLevel.Trace);
    //Log.setFileLogger(new std.stdio.File("ui.log", "w"));

    // resource directory search paths
    // not required if only embedded resources are used
    //string[] resourceDirs = [
    //    appendPath(exePath, "../../../res/"),   // for Visual D and DUB builds
    //    appendPath(exePath, "../../../res/mdpi/"),   // for Visual D and DUB builds
    //    appendPath(exePath, "../../../../res/"),// for Mono-D builds
    //    appendPath(exePath, "../../../../res/mdpi/"),// for Mono-D builds
    //    appendPath(exePath, "res/"), // when res dir is located at the same directory as executable
    //    appendPath(exePath, "../res/"), // when res dir is located at project directory
    //    appendPath(exePath, "../../res/"), // when res dir is located at the same directory as executable
    //    appendPath(exePath, "res/mdpi/"), // when res dir is located at the same directory as executable
    //    appendPath(exePath, "../res/mdpi/"), // when res dir is located at project directory
    //    appendPath(exePath, "../../res/mdpi/") // when res dir is located at the same directory as executable
    //];
    // setup resource directories - will use only existing directories
    //Platform.instance.resourceDirs = resourceDirs;

    // embed resources listed in views/resources.list into executable
    embeddedResourceList.addResources(embedResourcesFromList!("resources.list")());

    //version (USE_OPENGL) {
    //    // you can turn on subpixel font rendering (ClearType) here
        //FontManager.subpixelRenderingMode = SubpixelRenderingMode.None; //
    //} else {
        // you can turn on subpixel font rendering (ClearType) here
        FontManager.subpixelRenderingMode = SubpixelRenderingMode.BGR; //SubpixelRenderingMode.None; //
    //}

    // select translation file - for english language
    Platform.instance.uiLanguage = "en";
    // load theme from file "theme_default.xml"
    Platform.instance.uiTheme = "theme_default";
    //Platform.instance.uiTheme = "theme_dark";

    // you can override default hinting mode here (Normal, AutoHint, Disabled)
    FontManager.hintingMode = HintingMode.Normal;
    // you can override antialiasing setting here (0 means antialiasing always on, some big value = always off)
    // fonts with size less than specified value will not be antialiased
    FontManager.minAnitialiasedFontSize = 0; // 0 means always antialiased
    //version (USE_OPENGL) {
    //    // you can turn on subpixel font rendering (ClearType) here
    FontManager.subpixelRenderingMode = SubpixelRenderingMode.None; //
    //} else {
        // you can turn on subpixel font rendering (ClearType) here
    //FontManager.subpixelRenderingMode = SubpixelRenderingMode.BGR; //SubpixelRenderingMode.None; //
    //}

    // create window
    //Window window = Platform.instance.createWindow("DlangUI Example 1", null, WindowFlag.Resizable, 800, 700);
    // Expand window size if content is bigger than 800, 700 (change to above version if you want scrollbars and 800, 700 size)
    Window window = Platform.instance.createWindow("DlangUI Example 1", null, WindowFlag.Resizable | WindowFlag.ExpandSize, 800, 700);
    // here you can see window or content resize mode
    //Window window = Platform.instance.createWindow("DlangUI Example 1", null, WindowFlag.Resizable, 400, 400);
    //window.windowOrContentResizeMode = WindowOrContentResizeMode.resizeWindow;
    //window.windowOrContentResizeMode = WindowOrContentResizeMode.scrollWindow;
    //window.windowOrContentResizeMode = WindowOrContentResizeMode.shrinkWidgets;
    static if (true) {
        VerticalLayout contentLayout = new VerticalLayout();

        TabWidget tabs = new TabWidget("TABS");
        tabs.tabClose = delegate(string tabId) {
            tabs.removeTab(tabId);
        };

        //=========================================================================
        // create main menu

        MenuItem mainMenuItems = new MenuItem();
        MenuItem fileItem = new MenuItem(new Action(1, "MENU_FILE"c));
        fileItem.add(new Action(ACTION_FILE_OPEN, "MENU_FILE_OPEN"c, "document-open", KeyCode.KEY_O, KeyFlag.Control));
        fileItem.add(new Action(ACTION_FILE_SAVE, "MENU_FILE_SAVE"c, "document-save", KeyCode.KEY_S, KeyFlag.Control));
        MenuItem openRecentItem = new MenuItem(new Action(13, "MENU_FILE_OPEN_RECENT", "document-open-recent"));
        openRecentItem.add(new Action(100, "&1: File 1"d));
        openRecentItem.add(new Action(101, "&2: File 2"d));
        openRecentItem.add(new Action(102, "&3: File 3"d));
        openRecentItem.add(new Action(103, "&4: File 4"d));
        openRecentItem.add(new Action(104, "&5: File 5"d));
        fileItem.add(openRecentItem);
        fileItem.add(new Action(ACTION_FILE_EXIT, "MENU_FILE_EXIT"c, "document-close"c, KeyCode.KEY_X, KeyFlag.Alt));

        MenuItem editItem = new MenuItem(new Action(2, "MENU_EDIT"));
        editItem.add(new Action(EditorActions.Copy, "MENU_EDIT_COPY"c, "edit-copy", KeyCode.KEY_C, KeyFlag.Control));
        editItem.add(new Action(EditorActions.Paste, "MENU_EDIT_PASTE"c, "edit-paste", KeyCode.KEY_V, KeyFlag.Control));
        editItem.add(new Action(EditorActions.Cut, "MENU_EDIT_CUT"c, "edit-cut", KeyCode.KEY_X, KeyFlag.Control));
        editItem.add(new Action(EditorActions.Undo, "MENU_EDIT_UNDO"c, "edit-undo", KeyCode.KEY_Z, KeyFlag.Control));
        editItem.add(new Action(EditorActions.Redo, "MENU_EDIT_REDO"c, "edit-redo", KeyCode.KEY_Y, KeyFlag.Control));
        editItem.add(new Action(EditorActions.Indent, "MENU_EDIT_INDENT"c, "edit-indent", KeyCode.TAB, 0));
        editItem.add(new Action(EditorActions.Unindent, "MENU_EDIT_UNINDENT"c, "edit-unindent", KeyCode.TAB, KeyFlag.Control));
        editItem.add(new Action(20, "MENU_EDIT_PREFERENCES"));

        MenuItem viewItem = new MenuItem(new Action(60, "MENU_VIEW"));
        MenuItem langItem = new MenuItem(new Action(61, "MENU_VIEW_LANGUAGE"));
        auto onLangChange = delegate (MenuItem item) {
            if (!item.checked)
                return false;
            if (item.id == 611) {
                // set interface language to english
                platform.instance.uiLanguage = "en";
            } else if (item.id == 612) {
                // set interface language to russian
                platform.instance.uiLanguage = "ru";
            }
            return true;
        };
        MenuItem enLang = (new MenuItem(new Action(611, "MENU_VIEW_LANGUAGE_EN"))).type(MenuItemType.Radio).checked(true);
        MenuItem ruLang = (new MenuItem(new Action(612, "MENU_VIEW_LANGUAGE_RU"))).type(MenuItemType.Radio);
        enLang.menuItemClick = onLangChange;
        ruLang.menuItemClick = onLangChange;
        langItem.add(enLang);
        langItem.add(ruLang);
        viewItem.add(langItem);
        MenuItem themeItem = new MenuItem(new Action(62, "MENU_VIEW_THEME"));
        MenuItem theme1 = (new MenuItem(new Action(621, "MENU_VIEW_THEME_DEFAULT"))).type(MenuItemType.Radio).checked(true);
        MenuItem theme2 = (new MenuItem(new Action(622, "MENU_VIEW_THEME_DARK"))).type(MenuItemType.Radio);
        MenuItem theme3 = (new MenuItem(new Action(623, "MENU_VIEW_THEME_CUSTOM1"))).type(MenuItemType.Radio);
        auto onThemeChange = delegate (MenuItem item) {
            if (!item.checked)
                return false;
            if (item.id == 621) {
                platform.instance.uiTheme = "theme_default";
            } else if (item.id == 622) {
                platform.instance.uiTheme = "theme_dark";
            } else if (item.id == 623) {
                platform.instance.uiTheme = "theme_custom1";
            }
            return true;
        };
        theme1.menuItemClick = onThemeChange;
        theme2.menuItemClick = onThemeChange;
        theme3.menuItemClick = onThemeChange;
        themeItem.add(theme1);
        themeItem.add(theme2);
        themeItem.add(theme3);
        viewItem.add(themeItem);

        MenuItem windowItem = new MenuItem(new Action(3, "MENU_WINDOW"c));
        windowItem.add(new Action(30, "MENU_WINDOW_PREFERENCES"));
        windowItem.add(new Action(31, UIString.fromId("MENU_WINDOW_MINIMIZE")));
        windowItem.add(new Action(32, UIString.fromId("MENU_WINDOW_MAXIMIZE")));
        windowItem.add(new Action(33, UIString.fromId("MENU_WINDOW_RESTORE")));
        MenuItem helpItem = new MenuItem(new Action(4, "MENU_HELP"c));
        helpItem.add(new Action(40, "MENU_HELP_VIEW_HELP"));
        MenuItem aboutItem = new MenuItem(new Action(41, "MENU_HELP_ABOUT"));
        helpItem.add(aboutItem);
        mainMenuItems.add(fileItem);
        mainMenuItems.add(editItem);
        mainMenuItems.add(viewItem);
        mainMenuItems.add(windowItem);
        mainMenuItems.add(helpItem);
        MainMenu mainMenu = new MainMenu(mainMenuItems);
        contentLayout.addChild(mainMenu);
        // to let main menu handle keyboard shortcuts
        contentLayout.keyToAction = delegate(Widget source, uint keyCode, uint flags) {
            return mainMenu.findKeyAction(keyCode, flags);
        };
        contentLayout.onAction = delegate(Widget source, const Action a) {
            if (a.id == ACTION_FILE_EXIT) {
                window.close();
                return true;
            } else if (a.id == 31) {
                window.minimizeWindow();
                return true;
            } else if (a.id == 32) {
                window.maximizeWindow();
                return true;
            } else if (a.id == 33) {
                window.restoreWindow();
                return true;
            } else if (a.id == 41) {
                window.showMessageBox(UIString.fromRaw("About"d), UIString.fromRaw("DLangUI demo app\n(C) Vadim Lopatin, 2014\nhttp://github.com/buggins/dlangui"d));
                return true;
            } else if (a.id == ACTION_FILE_OPEN) {
                UIString caption;
                caption = "Open Text File"d;
                FileDialog dlg = new FileDialog(caption, window, null);
                dlg.allowMultipleFiles = true;
                dlg.addFilter(FileFilterEntry(UIString("FILTER_ALL_FILES", "All files (*)"d), "*"));
                dlg.addFilter(FileFilterEntry(UIString("FILTER_TEXT_FILES", "Text files (*.txt)"d), "*.txt"));
                dlg.addFilter(FileFilterEntry(UIString("FILTER_SOURCE_FILES", "Source files"d), "*.d;*.dd;*.c;*.cc;*.cpp;*.h;*.hpp"));
                dlg.addFilter(FileFilterEntry(UIString("FILTER_EXECUTABLE_FILES", "Executable files"d), "*", true));
                //dlg.filterIndex = 2;
                dlg.dialogResult = delegate(Dialog dlg, const Action result) {
                    if (result.id == ACTION_OPEN.id) {
                        string[] filenames = (cast(FileDialog)dlg).filenames;
                        foreach (filename; filenames) {
                            if (filename.endsWith(".d") || filename.endsWith(".txt") || filename.endsWith(".cpp") || filename.endsWith(".h") || filename.endsWith(".c")
                                || filename.endsWith(".json") || filename.endsWith(".dd") || filename.endsWith(".ddoc") || filename.endsWith(".xml") || filename.endsWith(".html")
                                || filename.endsWith(".html") || filename.endsWith(".css") || filename.endsWith(".log") || filename.endsWith(".hpp")) {
                                    // open source file in tab
                                    int index = tabs.tabIndex(filename);
                                    if (index >= 0) {
                                        // file is already opened in tab
                                        tabs.selectTab(index, true);
                                    } else {
                                        SourceEdit editor = new SourceEdit(filename);
                                        if (editor.load(filename)) {
                                            tabs.addTab(editor, toUTF32(baseName(filename)), null, true);
                                            tabs.selectTab(filename);
                                        } else {
                                            destroy(editor);
                                            window.showMessageBox(UIString.fromRaw("File open error"d), UIString.fromRaw("Cannot open file "d ~ toUTF32(filename)));
                                        }
                                    }
                                } else {
                                    Log.d("FileDialog.onDialogResult: ", result, " param=", result.stringParam);
                                    window.showMessageBox(UIString.fromRaw("FileOpen result"d), UIString.fromRaw("Filename: "d ~ toUTF32(filename)));
                                }
                        }
                    }

                };
                dlg.show();
                return true;
            }
            //else
            //return contentLayout.dispatchAction(a);
            return false;
        };
        mainMenu.menuItemClick = delegate(MenuItem item) {
            Log.d("mainMenu.onMenuItemListener", item.label);
            const Action a = item.action;
            if (a) {
                return contentLayout.dispatchAction(a);
            }
            return false;
        };

        // ========= create tabs ===================

        tabs.tabChanged = delegate(string newTabId, string oldTabId) {
            window.windowCaption = tabs.tab(newTabId).text.value ~ " - dlangui example 1"d;
        };
        tabs.layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT);

        // most of controls example

        tabs.addTab(new BasicControls("controls"), "Controls"d);
        tabs.addTab(new MiscExample("tab1"), "Misc"d);
        tabs.addTab(new LongListsExample("tab2"), "TAB_LONG_LIST"c);
        tabs.addTab(new ButtonsExample("tab3"), "TAB_BUTTONS"c);

        TableLayout table = new TableLayout("TABLE");
        table.colCount = 2;
        // headers
        table.addChild((new TextWidget(null, "Parameter Name"d)).alignment(Align.Right | Align.VCenter));
        table.addChild((new TextWidget(null, "Edit Box to edit parameter"d)).alignment(Align.Left | Align.VCenter));
        // row 1
        table.addChild((new TextWidget(null, "Parameter 1 name"d)).alignment(Align.Right | Align.VCenter));
        table.addChild((new EditLine("edit1", "Text 1"d)).layoutWidth(FILL_PARENT));
        // row 2
        table.addChild((new TextWidget(null, "Parameter 2 name bla bla"d)).alignment(Align.Right | Align.VCenter));
        table.addChild((new EditLine("edit2", "Some text for parameter 2"d)).layoutWidth(FILL_PARENT));
        // row 3
        table.addChild((new TextWidget(null, "Param 3 is disabled"d)).alignment(Align.Right | Align.VCenter).enabled(false));
        table.addChild((new EditLine("edit3", "Parameter 3 value"d)).layoutWidth(FILL_PARENT).enabled(false));
        // normal readonly combo box
        ComboBox combo1 = new ComboBox("combo1", ["item value 1"d, "item value 2"d, "item value 3"d, "item value 4"d, "item value 5"d, "item value 6"d]);
        table.addChild((new TextWidget(null, "Combo box param"d)).alignment(Align.Right | Align.VCenter));
        combo1.selectedItemIndex = 3;
        table.addChild(combo1).layoutWidth(FILL_PARENT);
        // disabled readonly combo box
        ComboBox combo2 = new ComboBox("combo2", ["item value 1"d, "item value 2"d, "item value 3"d]);
        table.addChild((new TextWidget(null, "Disabled combo box"d)).alignment(Align.Right | Align.VCenter));
        combo2.enabled = false;
        combo2.selectedItemIndex = 0;
        table.addChild(combo2).layoutWidth(FILL_PARENT);

        table.margins(Rect(2,2,2,2)).layoutWidth(FILL_PARENT);
        tabs.addTab(table, "TAB_TABLE_LAYOUT"c);

        //tabs.addTab((new TextWidget()).id("tab5").textColor(0x00802000).text("Tab 5 contents"), "Tab 5"d);

        //==========================================================================
        // create Editors test tab
        VerticalLayout editors = new VerticalLayout("editors");

        // EditLine sample
        editors.addChild(new TextWidget(null, "EditLine: Single line editor"d));
        EditLine editLine = new EditLine("editline1", "Single line editor sample text");
        editors.addChild(createEditorSettingsControl(editLine));
        editors.addChild(editLine);
        //editLine.popupMenu = editPopupItem;

        // EditBox sample
        editors.addChild(new TextWidget(null, "SourceEdit: multiline editor, for source code editing"d));

        SourceEdit editBox = new SourceEdit("editbox1");
        editBox.text = q{#!/usr/bin/env rdmd
// Computes average line length for standard input.
import std.stdio;

void main()
{
    ulong lines = 0;
    double sumLength = 0;
    foreach (line; stdin.byLine())
    {
        ++lines;
        sumLength += line.length;
    }
    writeln("Average line length: ",
            lines ? sumLength / lines : 0);
}
        }d;
        editors.addChild(createEditorSettingsControl(editBox));
        editors.addChild(editBox);
        //editBox.popupMenu = editPopupItem;

        editors.addChild(new TextWidget(null, "EditBox: additional view for the same content (split view testing)"d));
        SourceEdit editBox2 = new SourceEdit("editbox2");
        editBox2.content = editBox.content; // view the same content as first editbox
        editors.addChild(editBox2);
        editors.layoutHeight(FILL_PARENT).layoutWidth(FILL_PARENT);

        tabs.addTab(editors, "TAB_EDITORS"c);

        //==========================================================================

        VerticalLayout gridContent = new VerticalLayout("GRID_CONTENT");
        gridContent.layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT);
        HorizontalLayout gridSettings = new HorizontalLayout();
        StringGridWidget grid = new StringGridWidget("GRID1");

        gridSettings.addChild((new CheckBox("fullColumnOnLeft", "fullColumnOnLeft"d)).checked(grid.fullColumnOnLeft).tooltipText("Extends scroll area to show full column at left when scrolled to rightmost column"d).addOnCheckChangeListener(delegate(Widget, bool checked) { grid.fullColumnOnLeft = checked; return true;}));
        gridSettings.addChild((new CheckBox("fullRowOnTop", "fullRowOnTop"d)).checked(grid.fullRowOnTop).tooltipText("Extends scroll area to show full row at top when scrolled to end row"d).addOnCheckChangeListener(delegate(Widget, bool checked) { grid.fullRowOnTop = checked; return true;}));
        gridContent.addChild(gridSettings);

        grid.layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT);
        grid.showColHeaders = true;
        grid.showRowHeaders = true;
        grid.resize(30, 50);
        grid.fixedCols = 3;
        grid.fixedRows = 2;
        //grid.rowSelect = true; // testing full row selection
        grid.multiSelect = true;
        grid.selectCell(4, 6, false);
        // create sample grid content
        for (int y = 0; y < grid.rows; y++) {
            for (int x = 0; x < grid.cols; x++) {
                grid.setCellText(x, y, "cell("d ~ to!dstring(x + 1) ~ ","d ~ to!dstring(y + 1) ~ ")"d);
            }
            grid.setRowTitle(y, to!dstring(y + 1));
        }
        for (int x = 0; x < grid.cols; x++) {
            int col = x + 1;
            dstring res;
            int n1 = col / 26;
            int n2 = col % 26;
            if (n1)
                res ~= n1 + 'A';
            res ~= n2 + 'A';
            grid.setColTitle(x, res);
        }
        grid.autoFit();
        gridContent.addChild(grid);
        tabs.addTab(gridContent, "Grid"d);

        //==========================================================================
        // Scroll view example
        ScrollWidget scroll = new ScrollWidget("SCROLL1");
        scroll.layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT);
        WidgetGroup scrollContent = new VerticalLayout("CONTENT");
        scrollContent.layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT);

        TableLayout table2 = new TableLayout("TABLE2");
        table2.colCount = 2;
        // headers
        table2.addChild((new TextWidget(null, "Parameter Name"d)).alignment(Align.Right | Align.VCenter));
        table2.addChild((new TextWidget(null, "Edit Box to edit parameter"d)).alignment(Align.Left | Align.VCenter));
        // row 1
        table2.addChild((new TextWidget(null, "Parameter 1 name"d)).alignment(Align.Right | Align.VCenter));
        table2.addChild((new EditLine("edit1", "Text 1"d)).layoutWidth(FILL_PARENT));
        // row 2
        table2.addChild((new TextWidget(null, "Parameter 2 name bla bla"d)).alignment(Align.Right | Align.VCenter));
        table2.addChild((new EditLine("edit2", "Some text for parameter 2 blah blah blah"d)).layoutWidth(FILL_PARENT));
        // row 3
        table2.addChild((new TextWidget(null, "Param 3"d)).alignment(Align.Right | Align.VCenter));
        table2.addChild((new EditLine("edit3", "Parameter 3 value"d)).layoutWidth(FILL_PARENT));
        // row 4
        table2.addChild((new TextWidget(null, "Param 4"d)).alignment(Align.Right | Align.VCenter));
        table2.addChild((new EditLine("edit3", "Parameter 4 value shdjksdfh hsjdfas hdjkf hdjsfk ah"d)).layoutWidth(FILL_PARENT));
        // row 5
        table2.addChild((new TextWidget(null, "Param 5 - edit text here - blah blah blah"d)).alignment(Align.Right | Align.VCenter));
        table2.addChild((new EditLine("edit3", "Parameter 5 value"d)).layoutWidth(FILL_PARENT));
        // row 6
        table2.addChild((new TextWidget(null, "Param 6 - just to fill content widget (DISABLED)"d)).alignment(Align.Right | Align.VCenter).enabled(false));
        table2.addChild((new EditLine("edit3", "Parameter 5 value"d)).layoutWidth(FILL_PARENT).enabled(false));
        // row 7
        table2.addChild((new TextWidget(null, "Param 7 - just to fill content widget (DISABLED)"d)).alignment(Align.Right | Align.VCenter).enabled(false));
        table2.addChild((new EditLine("edit3", "Parameter 5 value"d)).layoutWidth(FILL_PARENT).enabled(false));
        // row 8
        table2.addChild((new TextWidget(null, "Param 8 - just to fill content widget"d)).alignment(Align.Right | Align.VCenter));
        table2.addChild((new EditLine("edit3", "Parameter 5 value"d)).layoutWidth(FILL_PARENT));
        table2.margins(Rect(10,10,10,10)).layoutWidth(FILL_PARENT);
        scrollContent.addChild(table2);

        scrollContent.addChild(new TextWidget(null, "Now - some buttons"d));
        scrollContent.addChild(new ImageTextButton("btn1", "fileclose", "Close"d));
        scrollContent.addChild(new ImageTextButton("btn2", "fileopen", "Open"d));
        scrollContent.addChild(new TextWidget(null, "And checkboxes"d));
        scrollContent.addChild(new CheckBox("btn1", "CheckBox 1"d));
        scrollContent.addChild(new CheckBox("btn2", "CheckBox 2"d));

        scroll.contentWidget = scrollContent;
        tabs.addTab(scroll, "Scroll"d);
        //==========================================================================
        // tree view example
        TreeWidget tree = new TreeWidget("TREE1");
        tree.layoutWidth(WRAP_CONTENT).layoutHeight(FILL_PARENT);
        TreeItem tree1 = tree.items.newChild("group1", "Group 1"d, "document-open");
        tree1.newChild("g1_1", "Group 1 item 1"d);
        tree1.newChild("g1_2", "Group 1 item 2"d);
        tree1.newChild("g1_3", "Group 1 item 3"d);
        TreeItem tree2 = tree.items.newChild("group2", "Group 2"d, "document-save");
        tree2.newChild("g2_1", "Group 2 item 1"d, "edit-copy");
        tree2.newChild("g2_2", "Group 2 item 2"d, "edit-cut");
        tree2.newChild("g2_3", "Group 2 item 3"d, "edit-paste");
        tree2.newChild("g2_4", "Group 2 item 4"d);
        TreeItem tree3 = tree.items.newChild("group3", "Group 3"d);
        tree3.newChild("g3_1", "Group 3 item 1"d);
        tree3.newChild("g3_2", "Group 3 item 2"d);
        TreeItem tree32 = tree3.newChild("g3_3", "Group 3 item 3"d);
        tree3.newChild("g3_4", "Group 3 item 4"d);
        tree32.newChild("group3_2_1", "Group 3 item 2 subitem 1"d);
        tree32.newChild("group3_2_2", "Group 3 item 2 subitem 2"d);
        tree32.newChild("group3_2_3", "Group 3 item 2 subitem 3"d);
        tree32.newChild("group3_2_4", "Group 3 item 2 subitem 4"d);
        tree32.newChild("group3_2_5", "Group 3 item 2 subitem 5"d);
        tree3.newChild("g3_5", "Group 3 item 5"d);
        tree3.newChild("g3_6", "Group 3 item 6"d);

        LinearLayout treeLayout = new HorizontalLayout("TREE");
        LinearLayout treeControlledPanel = new VerticalLayout();
        treeLayout.layoutWidth = FILL_PARENT;
        treeControlledPanel.layoutWidth = FILL_PARENT;
        treeControlledPanel.layoutHeight = FILL_PARENT;
        TextWidget treeItemLabel = new TextWidget("TREE_ITEM_DESC");
        treeItemLabel.layoutWidth = FILL_PARENT;
        treeItemLabel.layoutHeight = FILL_PARENT;
        treeItemLabel.alignment = Align.Center;
        treeItemLabel.text = "Sample text"d;
        treeControlledPanel.addChild(treeItemLabel);
        treeLayout.addChild(tree);
        treeLayout.addChild(new ResizerWidget());
        treeLayout.addChild(treeControlledPanel);

        tree.selectionChange = delegate(TreeItems source, TreeItem selectedItem, bool activated) {
            dstring label = "Selected item: "d ~ toUTF32(selectedItem.id) ~ (activated ? " selected + activated"d : " selected"d);
            treeItemLabel.text = label;
        };

        tree.items.selectItem(tree.items.child(0));

        tabs.addTab(treeLayout, "Tree"d);

        tabs.addTab(new ChartsExample("charts"), "Charts"d);
        tabs.addTab((new SampleAnimationWidget("tab6")).layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT), "TAB_ANIMATION"c);
        tabs.addTab(new CanvasExample("canvas"), UIString.fromId("TAB_CANVAS"));
        tabs.addTab(new IconsExample("icons"), "Icons"d);

        static if (BACKEND_GUI && ENABLE_OPENGL)
        {
            tabs.addTab(new OpenGLExample(), "OpenGL"d);
        }

        //==========================================================================

        contentLayout.addChild(tabs);
        window.mainWidget = contentLayout;

        tabs.selectTab("controls");
    } else {
        window.mainWidget = (new Button()).text("sample button");
    }
    static if (BACKEND_GUI) {
        window.windowIcon = drawableCache.getImage("dlangui-logo1");
    }
    window.show();
    //window.windowCaption = "New Window Caption";
    // run message loop

    Log.i("HOME path: ", homePath);
    Log.i("APPDATA path: ", appDataPath(".dlangui"));
    Log.i("Root paths: ", getRootPaths);

    return Platform.instance.enterMessageLoop();
}
