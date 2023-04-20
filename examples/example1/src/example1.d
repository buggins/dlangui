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

/// Constructs items for main menu
auto constructMainMenu()
{
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
    return mainMenuItems;
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

    VerticalLayout contentLayout = new VerticalLayout();

    TabWidget tabs = new TabWidget("TABS");
    tabs.tabClose = delegate(string tabId) {
        tabs.removeTab(tabId);
    };

    //=========================================================================
    // create main menu

    MainMenu mainMenu = new MainMenu(constructMainMenu());
    mainMenu.menuItemClick = delegate(MenuItem item) {
        Log.d("mainMenu.onMenuItemListener", item.label);
        const Action a = item.action;
        if (a) {
            return contentLayout.dispatchAction(a);
        }
        return false;
    };
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

    // Setup tab view
    tabs.tabChanged = delegate(string newTabId, string oldTabId)
    {
        window.windowCaption = tabs.tab(newTabId).text.value ~ " - dlangui example 1"d;
    };
    tabs.layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT);


    // Add all the example tabs
    tabs.addTab(new BasicControls("controls"), "Controls"d);
    tabs.addTab(new MiscExample("tab1"), "Misc"d);
    tabs.addTab(new LongListsExample("tab2"), "TAB_LONG_LIST"c);
    tabs.addTab(new ButtonsExample("tab3"), "TAB_BUTTONS"c);
    tabs.addTab(new TableExample("TABLE"), "TAB_TABLE_LAYOUT"c);
    tabs.addTab(new EditorsExample("EDITORS"), "TAB_EDITORS"c);
    tabs.addTab(new GridExample("GRID_CONTENT"), "Grid"d);
    tabs.addTab(new ScrollExample("SCROLL1"), "Scroll"d);
    tabs.addTab(new TreeExample("TREE"), "Tree"d);
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
