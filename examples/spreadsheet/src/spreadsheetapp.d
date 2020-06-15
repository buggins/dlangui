module spreadsheet;

import dlangui;
import dlangui.dialogs.filedlg;
import dlangui.dialogs.dialog;
import dlangui.widgets.spreadsheet;
import std.array : replaceFirst;

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

class EditFrame : AppFrame {

    MenuItem mainMenuItems;

    override protected void initialize() {
        _appName = "DlangUISpreadSheet";
        super.initialize();
    }

    /// create main menu
    override protected MainMenu createMainMenu() {
        mainMenuItems = new MenuItem();
        MenuItem fileItem = new MenuItem(new Action(1, "MENU_FILE"));
        fileItem.add(ACTION_FILE_NEW, ACTION_FILE_OPEN,
                     ACTION_FILE_EXIT);
        mainMenuItems.add(fileItem);
        MenuItem editItem = new MenuItem(new Action(2, "MENU_EDIT"));
        editItem.add(ACTION_EDIT_COPY, ACTION_EDIT_PASTE,
                     ACTION_EDIT_CUT, ACTION_EDIT_UNDO, ACTION_EDIT_REDO,
                     ACTION_EDIT_INDENT, ACTION_EDIT_UNINDENT, ACTION_EDIT_TOGGLE_LINE_COMMENT, ACTION_EDIT_TOGGLE_BLOCK_COMMENT, ACTION_DEBUG_START);

        editItem.add(ACTION_EDIT_PREFERENCES);
        mainMenuItems.add(editItem);
        MainMenu mainMenu = new MainMenu(mainMenuItems);
        return mainMenu;
    }


    /// create app toolbars
    override protected ToolBarHost createToolbars() {
        ToolBarHost res = new ToolBarHost();
        ToolBar tb;
        tb = res.getOrAddToolbar("Standard");
        tb.addButtons(ACTION_FILE_NEW, ACTION_FILE_OPEN, ACTION_FILE_SAVE, ACTION_SEPARATOR, ACTION_DEBUG_START);

        tb = res.getOrAddToolbar("Edit");
        tb.addButtons(ACTION_EDIT_COPY, ACTION_EDIT_PASTE, ACTION_EDIT_CUT, ACTION_SEPARATOR,
                      ACTION_EDIT_UNDO, ACTION_EDIT_REDO, ACTION_EDIT_INDENT, ACTION_EDIT_UNINDENT);
        return res;
    }

    string _filename;
    void openSourceFile(string filename) {
        import std.file;
        // TODO
        if (exists(filename)) {
            _filename = filename;
            window.windowCaption = toUTF32(filename);
            //_editor.load(filename);
            //updatePreview();
        }
    }

    void saveSourceFile(string filename) {
        if (filename.length == 0)
            filename = _filename;
        //import std.file;
        //_filename = filename;
        //window.windowCaption = toUTF32(filename);
        //_editor.save(filename);
    }

    bool onCanClose() {
        // todo
        return true;
    }

    FileDialog createFileDialog(UIString caption, bool fileMustExist = true) {
        uint flags = DialogFlag.Modal | DialogFlag.Resizable;
        if (fileMustExist)
            flags |= FileDialogFlag.FileMustExist;
        FileDialog dlg = new FileDialog(caption, window, null, flags);
        dlg.filetypeIcons[".d"] = "text-dml";
        return dlg;
    }

    void saveAs() {
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
                    window.showMessageBox(UIString.fromRaw("About DlangUI ML Editor"d),
                                          UIString.fromRaw("DLangIDE\n(C) Vadim Lopatin, 2015\nhttp://github.com/buggins/dlangui\nSimple editor for DML code"d));
                    return true;
                case IDEActions.FileNew:
                    UIString caption;
                    caption = "Create new DML file"d;
                    FileDialog dlg = createFileDialog(caption, false);
                    dlg.addFilter(FileFilterEntry(UIString.fromRaw("DML files"d), "*.dml"));
                    dlg.addFilter(FileFilterEntry(UIString.fromRaw("All files"d), "*.*"));
                    dlg.dialogResult = delegate(Dialog dlg, const Action result) {
                        if (result.id == ACTION_OPEN.id) {
                            string filename = result.stringParam;
                            //_editor.text=""d;
                            saveSourceFile(filename);
                        }
                    };
                    dlg.show();
                    return true;
                case IDEActions.FileSave:
                    if (_filename.length) {
                        saveSourceFile(_filename);
                        return true;
                    }
                    UIString caption;
                    caption = "Save DML File as"d;
                    FileDialog dlg = createFileDialog(caption, false);
                    dlg.addFilter(FileFilterEntry(UIString.fromRaw("DML files"d), "*.dml"));
                    dlg.addFilter(FileFilterEntry(UIString.fromRaw("All files"d), "*.*"));
                    dlg.dialogResult = delegate(Dialog dlg, const Action result) {
                        if (result.id == ACTION_OPEN.id) {
                            string filename = result.stringParam;
                            saveSourceFile(filename);
                        }
                    };
                    dlg.show();
                    return true;
                case IDEActions.FileOpen:
                    UIString caption;
                    caption = "Open DML File"d;
                    FileDialog dlg = createFileDialog(caption);
                    dlg.addFilter(FileFilterEntry(UIString.fromRaw("DML files"d), "*.dml"));
                    dlg.addFilter(FileFilterEntry(UIString.fromRaw("All files"d), "*.*"));
                    dlg.dialogResult = delegate(Dialog dlg, const Action result) {
                        if (result.id == ACTION_OPEN.id) {
                            string filename = result.stringParam;
                            openSourceFile(filename);
                        }
                    };
                    dlg.show();
                    return true;
                case IDEActions.DebugStart:
                    return true;
                case IDEActions.EditPreferences:
                    //showPreferences();
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

    SpreadSheetWidget _spreadsheet;

    /// create app body widget
    override protected Widget createBody() {
        VerticalLayout bodyWidget = new VerticalLayout();
        bodyWidget.layoutWidth = FILL_PARENT;
        bodyWidget.layoutHeight = FILL_PARENT;
        _spreadsheet = new SpreadSheetWidget();
        bodyWidget.addChild(_spreadsheet);
        return bodyWidget;
    }

}

/// entry point for dlangui based application
extern (C) int UIAppMain(string[] args) {

    // embed non-standard resources listed in views/resources.list into executable
    embeddedResourceList.addResources(embedResourcesFromList!("resources.list")());

    /// set font gamma (1.0 is neutral, < 1.0 makes glyphs lighter, >1.0 makes glyphs bolder)
    FontManager.fontGamma = 0.8;
    FontManager.hintingMode = HintingMode.Normal;

    // select translation file - for english language
    Platform.instance.uiLanguage = "en";
    // load theme from file "theme_custom.xml"
    Platform.instance.uiTheme = "theme_custom";

    // create window
    Window window = Platform.instance.createWindow("DlangUI SpreadSheet example"d, null, WindowFlag.Resizable, 700, 470);

    // create some widget to show in window
    window.windowIcon = drawableCache.getImage("dlangui-logo1");

    FontRef font = FontManager.instance.getFont(24, 300, false, FontFamily.SansSerif, "Arial");
    Log.d("font found: ", font.face);
    font = FontManager.instance.getFont(24, 300, false, FontFamily.Serif, "Times New Roman");
    Log.d("font found: ", font.face);

    // create some widget to show in window
    window.mainWidget = new EditFrame();

    // show window
    window.show();

    // run message loop
    return Platform.instance.enterMessageLoop();
}
