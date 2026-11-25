module dmledit;

import dlangui;
import dlangui.dialogs.filedlg;
import dlangui.dialogs.dialog;
import dlangui.dml.dmlhighlight;
import dlangui.widgets.metadata;
import std.array : replaceFirst;
import std.algorithm;
import std.stdio;
import std.array;
import std.file;

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

/// DIDE source file editor
class DMLSourceEdit : SourceEdit {
    this(string ID) {
        super(ID);
        MenuItem editPopupItem = new MenuItem(null);
        editPopupItem.add(ACTION_EDIT_COPY, ACTION_EDIT_PASTE, ACTION_EDIT_CUT, ACTION_EDIT_UNDO, ACTION_EDIT_REDO, ACTION_EDIT_INDENT, ACTION_EDIT_UNINDENT, ACTION_EDIT_TOGGLE_LINE_COMMENT, ACTION_DEBUG_START);
        popupMenu = editPopupItem;
        content.syntaxSupport = new DMLSyntaxSupport("");
        setTokenHightlightColor(TokenCategory.Comment, 0x008000); // green
        setTokenHightlightColor(TokenCategory.Keyword, 0x0000FF); // blue
        setTokenHightlightColor(TokenCategory.String, 0xa31515);  // brown
        setTokenHightlightColor(TokenCategory.Integer, 0xa315C0);  //
        setTokenHightlightColor(TokenCategory.Float, 0xa315C0);  //
        setTokenHightlightColor(TokenCategory.Error, 0xFF0000);  // red
        setTokenHightlightColor(TokenCategory.Op, 0x503000);
        setTokenHightlightColor(TokenCategory.Identifier_Class, 0x000080);  // blue

    }
    this() {
        this("DMLEDIT");
    }
}

immutable dstring SAMPLE_SOURCE_CODE =
q{VerticalLayout {
    id: vlayout
    margins: Rect { left: 5pt; right: 3pt; top: 2pt; bottom: 4pt } // pt: scaled with the screen DPI
    padding: Rect { 5pt, 4pt, 3pt, 2pt } // left, top, right, bottom
    TextWidget {
        /* this widget can be accessed via id myLabel1
            e.g. w.childById!TextWidget("myLabel1")
        */
        id: myLabel1
        text: "Some text"; padding: 5pt
        enabled: false
    }
    TextWidget {
        id: myLabel2
        text: "More text"; margins: 5pt
        enabled: true
    }
    CheckBox{ id: cb1; text: "Some checkbox" }
    HorizontalLayout {
        RadioButton { id: rb1; text: "Radio Button 1" }
        RadioButton { id: rb2; text: "Radio Button 2" }
    }
    HorizontalLayout {
        ImageTextButton { id: btn1; text: "Open folder"; drawableId: "folder" }
        ImageTextButton {
            id: btn2; text: "Apply"; drawableId: "dialog-ok-apply"
            orientation: Vertical // icon above the text
        }
    }
}
};

/// property list of a DML widget class, for the "Widget properties" list
dstring[] widgetPropertyList(string widgetClass) {
    dstring[] res;
    if (auto meta = findWidgetMetadata(widgetClass)) {
        auto mp = meta.properties;
        mp.sort!("a.name < b.name");
        foreach (const ref prop; mp)
            res ~= toUTF32(prop.name ~ "   [" ~ to!string(prop.type) ~ "]");
    }
    return res;
}

class EditFrame : AppFrame {

    MenuItem mainMenuItems;

    override protected void initialize() {
        _appName = "DMLEdit";
        super.initialize();
        updatePreview();
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
            _editor.load(filename);
            updatePreview();
        }
    }

    void saveSourceFile(string filename) {
        if (filename.length == 0)
            filename = _filename;
        import std.file;
        _filename = filename;
        window.windowCaption = toUTF32(filename);
        _editor.save(filename);
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
                            _editor.text=""d;
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
                    updatePreview();
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
            case IDEActions.FileOpen:
            case IDEActions.DebugStart:
            case IDEActions.EditPreferences:
            case IDEActions.FileSaveAs:
                a.state = ACTION_STATE_ENABLED;
                return true;
            case IDEActions.FileSave:
                if (_editor.content.modified)
                    a.state = ACTION_STATE_ENABLED;
                else
                    a.state = ACTION_STATE_DISABLE;
                return true;
            default:
                return super.handleActionStateRequest(a);
        }
    }

    void updatePreview() {
        dstring dsource = _editor.text;
        string source = toUTF8(dsource);
        try {
            Widget w = parseML(source);
            if (statusLine)
                statusLine.setStatusText("No errors"d);
            if (_fillHorizontal)
                w.layoutWidth = FILL_PARENT;
            if (_fillVertical)
                w.layoutHeight = FILL_PARENT;
            if (_highlightBackground)
                w.backgroundColor = 0xC0C0C0C0;
            _preview.contentWidget = w;
        } catch (ParserException e) {
            if (statusLine)
                statusLine.setStatusText(toUTF32("ERROR: " ~ e.msg));
            _editor.setCaretPos(e.line, e.pos);
            string msg = "\n" ~ e.msg ~ "\n";
            msg = replaceFirst(msg, " near `", "\nnear `");
            TextWidget w = new MultilineTextWidget(null, toUTF32(msg));
            w.padding = 10;
            w.margins = 10;
            w.maxLines = 10;
            w.backgroundColor = 0xC0FF8080;
            _preview.contentWidget = w;
        }
    }

    protected bool _fillHorizontal;
    protected bool _fillVertical;
    protected bool _highlightBackground;
    protected DMLSourceEdit _editor;
    protected ScrollWidget _preview;
    /// create app body widget
    override protected Widget createBody()
    {

        DockHost dockHost = new DockHost();

        dockHost.layoutWidth = FILL_PARENT;
        dockHost.layoutHeight = FILL_PARENT;

        WidgetsList widgetsList = new WidgetsList();
        StringListWidget propList = new StringListWidget();

        auto sla = new StringListAdapter();

        auto registeredWidgetList = getRegisteredWidgetsList();
        registeredWidgetList.sort!("a < b");

        foreach(const ref widget; registeredWidgetList)
            sla.add(UIString.fromRaw(widget));

        // the lists own their adapters and destroy them with their item widgets (#970)
        widgetsList.ownAdapter = sla;

        // the two lists share the height of the left panel: 60% for the widgets, the rest for the properties (fixed
        // min heights made the window content taller than the window; weights would follow the item counts, #1223)
        auto leftPanel = new VerticalLayout();
        leftPanel.layoutWidth = FILL_PARENT;
        leftPanel.layoutHeight = FILL_PARENT;
        widgetsList.layoutWidth = FILL_PARENT;
        widgetsList.layoutHeight = makePercentSize(60);
        propList.layoutWidth = FILL_PARENT;
        propList.layoutHeight = FILL_PARENT;

        leftPanel.addChild(widgetsList);
        // header in the style of the dock window captions (follows the theme, also in the console)
        auto propCaption = new HorizontalLayout();
        propCaption.styleId = STYLE_DOCK_WINDOW_CAPTION;
        propCaption.layoutWidth = FILL_PARENT;
        auto propCaptionLabel = new TextWidget(null, "Widget properties"d);
        propCaptionLabel.styleId = STYLE_DOCK_WINDOW_CAPTION_LABEL;
        propCaption.addChild(propCaptionLabel);
        leftPanel.addChild(propCaption);
        leftPanel.addChild(propList);

        auto leftDockWin = new DockWindow("left dock");
        leftDockWin.caption.text = "Widgets"d;
        leftDockWin.bodyWidget = leftPanel;
        leftDockWin.dockAlignment = DockAlignment.Left;
        leftDockWin.layoutHeight = FILL_PARENT;
        dockHost.addDockedWindow(leftDockWin);

        _editor = new DMLSourceEdit();
        _editor.text = SAMPLE_SOURCE_CODE;
        _editor.focusGroup = true; // as when it was in a DockWindow

        VerticalLayout previewLayout = new VerticalLayout();
        previewLayout.layoutHeight = FILL_PARENT;

        auto previewControls = new HorizontalLayout();
        auto cbFillHorizontal = new CheckBox(null, "Fill Horizontal"d);
        auto cbFillVertical = new CheckBox(null, "Fill Vertical"d);
        auto cbHighlightBackground = new CheckBox(null, "Background"d);
        cbFillHorizontal.checkChange = delegate(Widget source, bool checked) {
            _fillHorizontal = checked;
            updatePreview();
            return true;
        };
        cbFillVertical.checkChange = delegate(Widget source, bool checked) {
            _fillVertical = checked;
            updatePreview();
            return true;
        };
        cbHighlightBackground.checkChange = delegate(Widget source, bool checked) {
            _highlightBackground = checked;
            updatePreview();
            return true;
        };
        widgetsList.itemClick = delegate (Widget source, int itemIndex){
            propList.items = widgetPropertyList(to!string(widgetsList.selectedItem));
            return true;
        };
        widgetsList.onItemDoubleClick = delegate (Widget source, int itemIndex) {
            auto caret = _editor.caretPos;
            auto widgetClassName = widgetsList.selectedItem;
            EditOperation op = new EditOperation(EditAction.Replace, caret, widgetClassName);
            _editor.content.performOperation(op, this);
        };

        previewControls.addChild(cbFillHorizontal);
        previewControls.addChild(cbFillVertical);
        previewControls.addChild(cbHighlightBackground);

        _preview = new ScrollWidget();
        _preview.layoutWidth = FILL_PARENT;
        _preview.layoutHeight = FILL_PARENT;
        _preview.backgroundImageId = "tx_fabric.tiled";
        previewLayout.addChild(previewControls);
        previewLayout.addChild(_preview);

        auto previewDockWin = new DockWindow("preview");
        previewDockWin.caption.text = "Preview"d;
        previewDockWin.bodyWidget = previewLayout;
        previewDockWin.dockAlignment = DockAlignment.Right;

        previewDockWin.layoutHeight = FILL_PARENT;
        // the editor is the body of the dock host, not a docked window: added as both (in a DockWindow), it was in
        // the host's children twice and took half of the left dock area (#1223)
        dockHost.bodyWidget = _editor;
        dockHost.addDockedWindow(previewDockWin);
        // dock sizes in percent of the window width: 20% (the library default) for the lists; the preview needs
        // room for its check boxes and the sample
        dockHost.setInitialSpace(DockAlignment.Left, 20);
        dockHost.setInitialSpace(DockAlignment.Right, 35);

        return dockHost;
    }
}

alias onItemDoubleClickHandler = void delegate (Widget source, int itemIndex);

class WidgetsList : StringListWidget
{
    onItemDoubleClickHandler onItemDoubleClick;

    override bool onMouseEvent(MouseEvent event) {
        bool result = super.onMouseEvent(event);
        if (event.doubleClick) {
            if (onItemDoubleClick !is null)
                onItemDoubleClick(this, selectedItemIndex);
        }
        return result;
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
    Window window = Platform.instance.createWindow("DlangUI ML editor"d, null, WindowFlag.Resizable, 700, 470);

    // create some widget to show in window
    static if (BACKEND_GUI) window.windowIconId = "dlangui-logo1";

    // create some widget to show in window
    window.mainWidget = new EditFrame();

    // show window
    window.show();

    // run message loop
    return Platform.instance.enterMessageLoop();
}
