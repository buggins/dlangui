module dmledit;

import dlangui;

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

class EditFrame : AppFrame {

    MenuItem mainMenuItems;

    override protected void init() {
        _appName = "DMLEdit";
        super.init();
    }
    /// create main menu
    override protected MainMenu createMainMenu() {
        return new MainMenu(new MenuItem());
        mainMenuItems = new MenuItem();
        MenuItem fileItem = new MenuItem(new Action(1, "MENU_FILE"));
        fileItem.add(ACTION_FILE_NEW, ACTION_FILE_OPEN, 
                     ACTION_FILE_EXIT);

        MenuItem editItem = new MenuItem(new Action(2, "MENU_EDIT"));
		editItem.add(ACTION_EDIT_COPY, ACTION_EDIT_PASTE, 
                     ACTION_EDIT_CUT, ACTION_EDIT_UNDO, ACTION_EDIT_REDO,
                     ACTION_EDIT_INDENT, ACTION_EDIT_UNINDENT, ACTION_EDIT_TOGGLE_LINE_COMMENT, ACTION_EDIT_TOGGLE_BLOCK_COMMENT);

		editItem.add(ACTION_EDIT_PREFERENCES);

        MainMenu mainMenu = new MainMenu(mainMenuItems);
        return mainMenu;
    }


    /// create app toolbars
    override protected ToolBarHost createToolbars() {
        ToolBarHost res = new ToolBarHost();
        ToolBar tb;
        tb = res.getOrAddToolbar("Standard");
        tb.addButtons(ACTION_FILE_NEW, ACTION_FILE_OPEN, ACTION_FILE_SAVE);

        tb = res.getOrAddToolbar("Edit");
        tb.addButtons(ACTION_EDIT_COPY, ACTION_EDIT_PASTE, ACTION_EDIT_CUT, ACTION_SEPARATOR,
                      ACTION_EDIT_UNDO, ACTION_EDIT_REDO, ACTION_EDIT_INDENT, ACTION_EDIT_UNINDENT);
        return res;
    }

    /// create app body widget
    override protected Widget createBody() {
        VerticalLayout bodyWidget = new VerticalLayout();
        bodyWidget.layoutWidth = FILL_PARENT;
        bodyWidget.layoutHeight = FILL_PARENT;
        HorizontalLayout hlayout = new HorizontalLayout();
        hlayout.layoutWidth = makePercentSize(50);
        hlayout.layoutHeight = FILL_PARENT;
        SourceEdit editor = new SourceEdit();
        hlayout.addChild(editor);
        ScrollWidget preview = new ScrollWidget();
        preview.layoutWidth = FILL_PARENT;
        preview.layoutHeight = FILL_PARENT;
        hlayout.addChild(preview);
        bodyWidget.addChild(hlayout);
        return bodyWidget;
    }

}

/// entry point for dlangui based application
extern (C) int UIAppMain(string[] args) {

    // embed non-standard resources listed in views/resources.list into executable
    embeddedResourceList.addResources(embedResourcesFromList!("resources.list")());

    // create window
    Window window = Platform.instance.createWindow("DlangUI ML editor"d, null, WindowFlag.Resizable, 700, 470);

    // create some widget to show in window
    window.windowIcon = drawableCache.getImage("dlangui-logo1");


    // create some widget to show in window
    window.mainWidget = new EditFrame();
        /*
        parseML(q{
        VerticalLayout {
            id: vlayout
            margins: Rect { left: 5; right: 3; top: 2; bottom: 4 }
            padding: Rect { 5, 4, 3, 2 } // same as Rect { left: 5; top: 4; right: 3; bottom: 2 }
            TextWidget {
                id: myLabel1
                text: "Some text"; padding: 5
                enabled: false
            }
            TextWidget {
                id: myLabel2
                text: SOME_TEXT_RESOURCE_ID; margins: 5
                enabled: true
            }
        }
    });
    */

    // show window
    window.show();

    // run message loop
    return Platform.instance.enterMessageLoop();
}
