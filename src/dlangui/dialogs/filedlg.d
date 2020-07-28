// Written in the D programming language.

/**
This module contains FileDialog implementation.

Can show dialog for open / save.


Synopsis:

----
import dlangui.dialogs.filedlg;

UIString caption = "Open File"d;
auto dlg = new FileDialog(caption, window, FileDialogFlag.Open);
dlg.show();

----

Copyright: Vadim Lopatin, 2014
License:   Boost License 1.0
Authors:   Vadim Lopatin, coolreader.org@gmail.com
*/
module dlangui.dialogs.filedlg;

import dlangui.core.events;
import dlangui.core.i18n;
import dlangui.core.stdaction;
import dlangui.core.files;
import dlangui.widgets.controls;
import dlangui.widgets.lists;
import dlangui.widgets.popup;
import dlangui.widgets.layouts;
import dlangui.widgets.grid;
import dlangui.widgets.editors;
import dlangui.widgets.menu;
import dlangui.widgets.combobox;
import dlangui.platforms.common.platform;
import dlangui.dialogs.dialog;

private import std.algorithm;
private import std.file;
private import std.path;
private import std.utf : toUTF32;
private import std.string;
private import std.array;
private import std.conv : to;


/// flags for file dialog options
enum FileDialogFlag : uint {
    /// file must exist (use this for open dialog)
    FileMustExist = 0x100,
    /// ask before saving to existing
    ConfirmOverwrite = 0x200,
    /// select directory, not file
    SelectDirectory = 0x400,
    /// show Create Directory button
    EnableCreateDirectory = 0x800,
    /// flags for Open dialog
    Open = FileMustExist | EnableCreateDirectory,
    /// flags for Save dialog
    Save = ConfirmOverwrite | EnableCreateDirectory,

}

/// File dialog action codes
enum FileDialogActions : int {
    ShowInFileManager = 4000,
    CreateDirectory = 4001,
    DeleteFile = 4002,
}

/// filetype filter entry for FileDialog
struct FileFilterEntry {
    UIString label;
    string[] filter;
    bool executableOnly;
    this(UIString displayLabel, string filterList, bool executableOnly = false) {
        label = displayLabel;
        if (filterList.length)
            filter = split(filterList, ";");
        this.executableOnly = executableOnly;
    }
}

/// sorting orders for file dialog items
enum FileListSortOrder {
    NAME,
    NAME_DESC,
    SIZE_DESC,
    SIZE,
    TIMESTAMP_DESC,
    TIMESTAMP,
}

/// File open / save dialog
class FileDialog : Dialog, CustomGridCellAdapter {
    protected FilePathPanel _edPath;
    protected EditLine _edFilename;
    protected ComboBox _cbFilters;
    protected StringGridWidget _fileList;
    protected FileListSortOrder _sortOrder = FileListSortOrder.NAME;
    protected Widget leftPanel;
    protected VerticalLayout rightPanel;
    protected Action _action;

    protected RootEntry[] _roots;
    protected FileFilterEntry[] _filters;
    protected int _filterIndex;
    protected string _path;
    protected string _filename;
    protected DirEntry[] _entries;
    protected bool _isRoot;

    protected bool _isOpenDialog;

    protected bool _showHiddenFiles;
    protected bool _allowMultipleFiles;

    protected string[string] _filetypeIcons;

    this(UIString caption, Window parent, Action action = null, uint fileDialogFlags = DialogFlag.Modal | DialogFlag.Resizable | FileDialogFlag.FileMustExist) {
        super(caption, parent, fileDialogFlags | (Platform.instance.uiDialogDisplayMode & DialogDisplayMode.fileDialogInPopup ? DialogFlag.Popup : 0));
        _isOpenDialog = !(_flags & FileDialogFlag.ConfirmOverwrite);
        if (action is null) {
            if (fileDialogFlags & FileDialogFlag.SelectDirectory)
                action = ACTION_OPEN_DIRECTORY.clone();
            else if (_isOpenDialog)
                action = ACTION_OPEN.clone();
            else
                action = ACTION_SAVE.clone();
        }
        _action = action;
    }

    /// mapping of file extension to icon resource name, e.g. ".txt": "text-plain"
    @property ref string[string] filetypeIcons() { return _filetypeIcons; }

    /// filter list for file type filter combo box
    @property FileFilterEntry[] filters() {
        return _filters;
    }

    /// filter list for file type filter combo box
    @property void filters(FileFilterEntry[] values) {
        _filters = values;
    }

    /// add new filter entry
    void addFilter(FileFilterEntry value) {
        _filters ~= value;
    }

    /// filter index
    @property int filterIndex() {
        return _filterIndex;
    }

    /// filter index
    @property void filterIndex(int index) {
        _filterIndex = index;
    }

    /// the path to the directory whose files should be displayed
    @property string path() {
        return _path;
    }

    @property void path(string s) {
        _path = s;
    }

    /// the name of the file or directory that is currently selected
    @property string filename() {
        return _filename;
    }

    @property void filename(string s) {
        _filename = s;
    }

    /// all the selected filenames
    @property string[] filenames() {
        string[] res;
        res.reserve(_fileList.selection.length);
        int i = 0;
        foreach (val; _fileList.selection) {
            res ~= _entries[val.y];
            ++i;
        }
        return res;
    }

    @property bool showHiddenFiles() {
        return _showHiddenFiles;
    }

    @property void showHiddenFiles(bool b) {
        _showHiddenFiles = b;
    }

    @property bool allowMultipleFiles() {
        return _allowMultipleFiles;
    }

    @property void allowMultipleFiles(bool b) {
        _allowMultipleFiles = b;
    }

    /// return currently selected filter value - array of patterns like ["*.txt", "*.rtf"]
    @property string[] selectedFilter() {
        if (_filterIndex >= 0 && _filterIndex < _filters.length)
            return _filters[_filterIndex].filter;
        return null;
    }

    @property bool executableFilterSelected() {
        if (_filterIndex >= 0 && _filterIndex < _filters.length)
            return _filters[_filterIndex].executableOnly;
        return false;
    }

    protected bool upLevel() {
        return openDirectory(parentDir(_path), _path);
    }

    protected bool reopenDirectory() {
        return openDirectory(_path, null);
    }

    protected void locateFileInList(dstring pattern) {
        if (!pattern.length)
            return;
        int selection = _fileList.row;
        if (selection < 0)
            selection = 0;
        int index = -1; // first matched item
        string mask = pattern.toUTF8;
        // search forward from current row to end of list
        for(int i = selection; i < _entries.length; i++) {
            string fname = baseName(_entries[i].name);
            if (fname.startsWith(mask)) {
                index = i;
                break;
            }
        }
        if (index < 0) {
            // search from beginning of list to current position
            for(int i = 0; i < selection && i < _entries.length; i++) {
                string fname = baseName(_entries[i].name);
                if (fname.startsWith(mask)) {
                    index = i;
                    break;
                }
            }
        }
        if (index >= 0) {
            // move selection
            _fileList.selectCell(1, index + 1);
            window.update();
        }
    }

    /// change sort order after clicking on column col
    protected void changeSortOrder(int col) {
        assert(col >= 2 && col <= 4);
        // 2=NAME, 3=SIZE, 4=MODIFIED
        col -= 2;
        int n = col * 2;
        if ((n & 0xFE) == ((cast(int)_sortOrder) & 0xFE)) {
            // invert DESC / ASC if clicked same column as in current sorting order
            _sortOrder = cast(FileListSortOrder)(_sortOrder ^ 1);
        } else {
            _sortOrder = cast(FileListSortOrder)n;
        }
        string selectedItemPath;
        int currentRow = _fileList.row;
        if (currentRow >= 0 && currentRow < _entries.length) {
            selectedItemPath = _entries[currentRow].name;
        }
        updateColumnHeaders();
        sortEntries();
        entriesToCells(selectedItemPath);
        requestLayout();
        if (window)
            window.update();
    }

    /// predicate for sorting items - NAME
    static bool compareItemsByName(ref DirEntry item1, ref DirEntry item2) {
        return ((item1.isDir && !item2.isDir) || ((item1.isDir == item2.isDir) && (item1.name < item2.name)));
    }
    /// predicate for sorting items - NAME DESC
    static bool compareItemsByNameDesc(ref DirEntry item1, ref DirEntry item2) {
        return ((item1.isDir && !item2.isDir) || ((item1.isDir == item2.isDir) && (item1.name > item2.name)));
    }
    /// predicate for sorting items - SIZE
    static bool compareItemsBySize(ref DirEntry item1, ref DirEntry item2) {
        return ((item1.isDir && !item2.isDir) 
                || ((item1.isDir && item2.isDir) && (item1.name < item2.name))
                || ((!item1.isDir && !item2.isDir) && (item1.size < item2.size))
                );
    }
    /// predicate for sorting items - SIZE DESC
    static bool compareItemsBySizeDesc(ref DirEntry item1, ref DirEntry item2) {
        return ((item1.isDir && !item2.isDir) 
                || ((item1.isDir && item2.isDir) && (item1.name < item2.name))
                || ((!item1.isDir && !item2.isDir) && (item1.size > item2.size))
                );
    }
    /// predicate for sorting items - TIMESTAMP
    static bool compareItemsByTimestamp(ref DirEntry item1, ref DirEntry item2) {
        try {
            return item1.timeLastModified < item2.timeLastModified;
        } catch (Exception e) {
            return false;
        }
    }
    /// predicate for sorting items - TIMESTAMP DESC
    static bool compareItemsByTimestampDesc(ref DirEntry item1, ref DirEntry item2) {
        try {
            return item1.timeLastModified > item2.timeLastModified;
        } catch (Exception e) {
            return false;
        }
    }

    /// sort entries according to _sortOrder
    protected void sortEntries() {
        if (_entries.length < 1)
            return;
        DirEntry[] entriesToSort = _entries[0..$];
        if (_entries.length > 0) {
            string fname = baseName(_entries[0].name);
            if (fname == "..") {
                entriesToSort = _entries[1..$];
            }
        }
        import std.algorithm.sorting : sort;
        switch(_sortOrder) with(FileListSortOrder) {
            default:
            case NAME:
                sort!compareItemsByName(entriesToSort);
                break;
            case NAME_DESC:
                sort!compareItemsByNameDesc(entriesToSort);
                break;
            case SIZE:
                sort!compareItemsBySize(entriesToSort);
                break;
            case SIZE_DESC:
                sort!compareItemsBySizeDesc(entriesToSort);
                break;
            case TIMESTAMP:
                sort!compareItemsByTimestamp(entriesToSort);
                break;
            case TIMESTAMP_DESC:
                sort!compareItemsByTimestampDesc(entriesToSort);
                break;
        }
    }

    protected string formatTimestamp(ref DirEntry f) {
        import std.datetime : SysTime;
        import std.typecons : Nullable;
        Nullable!SysTime ts;
        try {
            ts = f.timeLastModified;
        } catch (Exception e) {
            Log.w(e.msg);
        }
        if (ts.isNull) {
            return "----.--.-- --:--";
        } else {
            return "%04d.%02d.%02d %02d:%02d".format(ts.get.year, ts.get.month, ts.get.day, ts.get.hour, ts.get.minute);
        }
    }

    protected int entriesToCells(string selectedItemPath) {
        _fileList.rows = cast(int)_entries.length;
        int selectionIndex = -1;
        for (int i = 0; i < _entries.length; i++) {
            if (_entries[i].name.equal(selectedItemPath))
                selectionIndex = i;
            string fname = baseName(_entries[i].name);
            string sz;
            string date;
            bool d = _entries[i].isDir;
            _fileList.setCellText(1, i, toUTF32(fname));
            if (d) {
                _fileList.setCellText(0, i, "folder");
                if (fname != "..")
                    date = formatTimestamp(_entries[i]);
            } else {
                string ext = extension(fname);
                string resname;
                if (ext in _filetypeIcons)
                    resname = _filetypeIcons[ext];
                else if (baseName(fname) in _filetypeIcons)
                    resname = _filetypeIcons[baseName(fname)];
                else
                    resname = "text-plain";
                _fileList.setCellText(0, i, toUTF32(resname));
                double size = double.nan;
                try {
                    size = _entries[i].size;
                } catch (Exception e) {
                    Log.w(e.msg);
                }
                import std.math : isNaN;
                if (size.isNaN)
                    sz = "--";
                else {
                    import std.format : format;
                    sz = size < 1024 ? to!string(size) ~ " B" :
                    (size < 1024*1024 ? "%.1f".format(size/1024) ~ " KB" :
                     (size < 1024*1024*1024 ? "%.1f".format(size/(1024*1024)) ~ " MB" :
                      "%.1f".format(size/(1024*1024*1024)) ~ " GB"));
                }
                date = formatTimestamp(_entries[i]);
            }
            _fileList.setCellText(2, i, toUTF32(sz));
            _fileList.setCellText(3, i, toUTF32(date));
        }
        if(_fileList.height > 0)
            _fileList.scrollTo(0, 0);

        autofitGrid();
        if (selectionIndex >= 0)
            _fileList.selectCell(1, selectionIndex + 1, true);
        else if (_entries.length > 0)
            _fileList.selectCell(1, 1, true);
        return selectionIndex;
    }

    protected bool openDirectory(string dir, string selectedItemPath) {
        dir = buildNormalizedPath(dir);
        Log.d("FileDialog.openDirectory(", dir, ")");
        DirEntry[] entries;

        auto attrFilter = (showHiddenFiles ? AttrFilter.all : AttrFilter.allVisible) | AttrFilter.special | AttrFilter.parent;
        if (executableFilterSelected()) {
            attrFilter |= AttrFilter.executable;
        }
        try {
            _entries = listDirectory(dir, attrFilter, selectedFilter());
        } catch(Exception e) {
            Log.e("Cannot list directory " ~ dir, e);
            //import dlangui.dialogs.msgbox;
            //auto msgBox = new MessageBox(UIString.fromId("MESSAGE_ERROR"c), UIString.fromRaw(e.msg.toUTF32), window());
            //msgBox.show();
            //return false;
            // show empty dir if failed to read
        }
        _fileList.rows = 0;
        _path = dir;
        _isRoot = isRoot(dir);
        _edPath.path = _path; //toUTF32(_path);
        int selectionIndex = entriesToCells(selectedItemPath);
        return true;
    }

    void autofitGrid() {
        _fileList.autoFitColumnWidths();
        //_fileList.setColWidth(1, 0);
        _fileList.fillColumnWidth(1);
    }

    override bool onKeyEvent(KeyEvent event) {
        if (event.action == KeyAction.KeyDown) {
            if (event.keyCode == KeyCode.BACK && event.flags == 0) {
                upLevel();
                return true;
            }
        }
        return super.onKeyEvent(event);
    }

    /// return true for custom drawn cell
    override bool isCustomCell(int col, int row) {
        if ((col == 0 || col == 1) && row >= 0)
            return true;
        return false;
    }

    protected DrawableRef rowIcon(int row) {
        string iconId = toUTF8(_fileList.cellText(0, row));
        DrawableRef res;
        if (iconId.length)
            res = drawableCache.get(iconId);
        return res;
    }

    /// return cell size
    override Point measureCell(int col, int row) {
        if (col == 1) {
            FontRef fnt = _fileList.font;
            dstring txt = _fileList.cellText(col, row);
            Point sz = fnt.textSize(txt);
            if (sz.y < fnt.height)
                sz.y = fnt.height;
            return sz;
        }
        if (WIDGET_STYLE_CONSOLE)
            return Point(0, 0);
        else {
            DrawableRef icon = rowIcon(row);
            if (icon.isNull)
                return Point(0, 0);
            return Point(icon.width + 2.pointsToPixels, icon.height + 2.pointsToPixels);
        }
    }

    /// draw data cell content
    override void drawCell(DrawBuf buf, Rect rc, int col, int row) {
        if (col == 1) {
            if (BACKEND_GUI)
                rc.shrink(2, 1);
            else
                rc.right--;
            FontRef fnt = _fileList.font;
            dstring txt = _fileList.cellText(col, row);
            Point sz = fnt.textSize(txt);
            Align ha = Align.Left;
            //if (sz.y < rc.height)
            //    applyAlign(rc, sz, ha, Align.VCenter);
            int offset = WIDGET_STYLE_CONSOLE ? 0 : 1;
            uint cl = _fileList.textColor;
            if (_entries[row].isDir)
                cl = style.customColor("file_dialog_dir_name_color", cl);
            fnt.drawText(buf, rc.left + offset, rc.top + offset, txt, cl);
            return;
        }
        DrawableRef img = rowIcon(row);
        if (!img.isNull) {
            Point sz;
            sz.x = img.width;
            sz.y = img.height;
            applyAlign(rc, sz, Align.HCenter, Align.VCenter);
            uint st = state;
            img.drawTo(buf, rc, st);
        }
    }

    protected ListWidget createRootsList() {
        ListWidget res = new ListWidget("ROOTS_LIST");
        res.styleId = STYLE_LIST_BOX;
        WidgetListAdapter adapter = new WidgetListAdapter();
        foreach(ref RootEntry root; _roots) {
            ImageTextButton btn = new ImageTextButton(null, root.icon, root.label);
            static if (WIDGET_STYLE_CONSOLE) btn.margins = Rect(1, 1, 0, 0);
            btn.orientation = Orientation.Vertical;
            btn.styleId = STYLE_TRANSPARENT_BUTTON_BACKGROUND;
            btn.focusable = false;
            btn.tooltipText = root.path.toUTF32;
            adapter.add(btn);
        }
        res.ownAdapter = adapter;
        res.layoutWidth(WRAP_CONTENT).layoutHeight(FILL_PARENT).layoutWeight(0);
        res.itemClick = delegate(Widget source, int itemIndex) {
            openDirectory(_roots[itemIndex].path, null);
            res.selectItem(-1);
            return true;
        };
        res.focusable = true;
        debug Log.d("root list styleId=", res.styleId);
        return res;
    }

    /// file list item activated (double clicked or Enter key pressed)
    protected void onItemActivated(int index) {
        DirEntry e = _entries[index];
        if (e.isDir) {
            openDirectory(e.name, _path);
        } else if (e.isFile) {
            string fname = e.name;
            if ((_flags & FileDialogFlag.ConfirmOverwrite) && exists(fname) && isFile(fname)) {
                showConfirmOverwriteQuestion(fname);
                return;
            }
            else {
                Action result = _action;
                result.stringParam = fname;
                close(result);
            }
        }
    }

    /// file list item selected
    protected void onItemSelected(int index) {
        DirEntry e = _entries[index];
        string fname = e.name;
        _edFilename.text = toUTF32(baseName(fname));
        _filename = fname;
    }

    protected void createAndEnterDirectory(string name) {
        string newdir = buildNormalizedPath(_path, name);
        try {
            mkdirRecurse(newdir);
            openDirectory(newdir, null);
        } catch (Exception e) {
            window.showMessageBox(UIString.fromId("CREATE_FOLDER_ERROR_TITLE"c), UIString.fromId("CREATE_FOLDER_ERROR_MESSAGE"c));
        }
    }

    /// calls close with default action; returns true if default action is found and invoked
    override protected bool closeWithDefaultAction() {
        return handleAction(_action);
    }

    /// Custom handling of actions
    override bool handleAction(const Action action) {
        if (action.id == StandardAction.Cancel) {
            super.handleAction(action);
            return true;
        }
        if (action.id == FileDialogActions.ShowInFileManager) {
            Platform.instance.showInFileManager(action.stringParam);
            return true;
        }
        if (action.id == StandardAction.CreateDirectory) {
            // show editor popup
            window.showInputBox(UIString.fromId("CREATE_NEW_FOLDER"c), UIString.fromId("INPUT_NAME_FOR_FOLDER"c), ""d, delegate(dstring s) {
                if (!s.empty)
                    createAndEnterDirectory(toUTF8(s));
            });
            return true;
        }
        if (action.id == StandardAction.Open || action.id == StandardAction.OpenDirectory || action.id == StandardAction.Save) {
            auto baseFilename = toUTF8(_edFilename.text);
            if (action.id == StandardAction.OpenDirectory)
                _filename = _path ~ dirSeparator;
            else
                _filename = _path ~ dirSeparator ~ baseFilename;

            if (action.id != StandardAction.OpenDirectory && exists(_filename) && isDir(_filename)) {
                // directory name in _edFileName.text but we need file so open directory
                openDirectory(_filename, null);
                return true;
            } else if (baseFilename.length > 0) {
                Action result = _action;
                result.stringParam = _filename;
                // success if either selected dir & has to open dir or if selected file
                if (action.id == StandardAction.OpenDirectory && exists(_filename) && isDir(_filename)) {
                    close(result);
                    return true;
                }
                else if (action.id == StandardAction.Save && !(_flags & FileDialogFlag.FileMustExist)) {
                    // save dialog
                    if ((_flags & FileDialogFlag.ConfirmOverwrite) && exists(_filename) && isFile(_filename)) {
                        showConfirmOverwriteQuestion(_filename);
                        return true;
                    }
                    else {
                        close(result);
                        return true;
                    }
                }
                else if (!(_flags & FileDialogFlag.FileMustExist) || (exists(_filename) && isFile(_filename))) {
                    // open dialog
                    close(result);
                    return true;
                }
            }
        }
        return super.handleAction(action);
    }

    /// shows question "override file?"
    protected void showConfirmOverwriteQuestion(string fileName) {
        window.showMessageBox(UIString.fromId("CONFIRM_OVERWRITE_TITLE"c).value, format(UIString.fromId("CONFIRM_OVERWRITE_FILE_NAMED_%s_QUESTION"c).value, baseName(fileName)), [ACTION_YES, ACTION_NO], 1, delegate bool(const Action a) {
            if (a.id == StandardAction.Yes) {
                Action result = _action;
                result.stringParam = fileName;
                close(result);
            }
            return true;
        });
    }

    bool onPathSelected(string path) {
        //
        return openDirectory(path, null);
    }

    protected MenuItem getCellPopupMenu(GridWidgetBase source, int col, int row) {
        if (row >= 0 && row < _entries.length) {
            MenuItem item = new MenuItem();
            DirEntry e = _entries[row];
            // show in explorer action
            auto showAction = new Action(FileDialogActions.ShowInFileManager, "ACTION_FILE_SHOW_IN_FILE_MANAGER"c);
            showAction.stringParam = e.name;
            item.add(showAction);
            // create directory action
            if (_flags & FileDialogFlag.EnableCreateDirectory)
                item.add(ACTION_CREATE_DIRECTORY);

            if (e.isDir) {
                //_edFilename.text = ""d;
                //_filename = "";
            } else if (e.isFile) {
                //string fname = e.name;
                //_edFilename.text = toUTF32(baseName(fname));
                //_filename = fname;
            }
            return item;
        }
        return null;
    }

    /// override to implement creation of dialog controls
    override void initialize() {
        // remember filename specified by user, file grid initialization can change it
        string defaultFilename = _filename;
        
        _roots = getRootPaths() ~ getBookmarkPaths();

        layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT).minWidth(WIDGET_STYLE_CONSOLE ? 50 : 600);
        //minHeight = 400;

        LinearLayout content = new HorizontalLayout("dlgcontent");

        content.layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT); //.minWidth(400).minHeight(300);


        //leftPanel = new VerticalLayout("places");
        //leftPanel.addChild(createRootsList());
        //leftPanel.layoutHeight(FILL_PARENT).minWidth(WIDGET_STYLE_CONSOLE ? 7 : 40);

        leftPanel = createRootsList();
        leftPanel.minWidth(WIDGET_STYLE_CONSOLE ? 7 : 40.pointsToPixels);

        rightPanel = new VerticalLayout("main");
        rightPanel.layoutHeight(FILL_PARENT).layoutWidth(FILL_PARENT);
        rightPanel.addChild(new TextWidget(null, UIString.fromId("MESSAGE_PATH"c) ~ ":"));

        content.addChild(leftPanel);
        content.addChild(rightPanel);

        _edPath = new FilePathPanel("path");
        _edPath.layoutWidth(FILL_PARENT);
        _edPath.layoutWeight = 0;
        _edPath.onPathSelectionListener = &onPathSelected;
        HorizontalLayout fnlayout = new HorizontalLayout();
        fnlayout.layoutWidth(FILL_PARENT);
        _edFilename = new EditLine("filename");
        _edFilename.layoutWidth(FILL_PARENT);
        _edFilename.setDefaultPopupMenu();
        if (_flags & FileDialogFlag.SelectDirectory) {
            _edFilename.visibility = Visibility.Gone;
        }

        //_edFilename.layoutWeight = 0;
        fnlayout.addChild(_edFilename);
        if (_filters.length) {
            dstring[] filterLabels;
            foreach(f; _filters)
                filterLabels ~= f.label.value;
            _cbFilters = new ComboBox("filter", filterLabels);
            _cbFilters.selectedItemIndex = _filterIndex;
            _cbFilters.itemClick = delegate(Widget source, int itemIndex) {
                _filterIndex = itemIndex;
                reopenDirectory();
                return true;
            };
            _cbFilters.layoutWidth(WRAP_CONTENT);
            _cbFilters.layoutWeight(0);
            //_cbFilters.backgroundColor = 0xFFC0FF;
            fnlayout.addChild(_cbFilters);
            //fnlayout.backgroundColor = 0xFFFFC0;
        }

        _fileList = new StringGridWidget("files");
        _fileList.styleId = STYLE_FILE_DIALOG_GRID;
        _fileList.layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT);
        _fileList.fullColumnOnLeft(false);
        _fileList.fullRowOnTop(false);
        _fileList.resize(4, 3);
        _fileList.setColTitle(0, " "d);
        updateColumnHeaders();
        _fileList.showRowHeaders = false;
        _fileList.rowSelect = true;
        _fileList.multiSelect = _allowMultipleFiles;
        _fileList.cellPopupMenu = &getCellPopupMenu;
        _fileList.menuItemAction = &handleAction;
        _fileList.minVisibleRows = 10;
        _fileList.minVisibleCols = 4;
        _fileList.headerCellClicked = &onHeaderCellClicked;

        _fileList.keyEvent = delegate(Widget source, KeyEvent event) {
            if (_shortcutHelper.onKeyEvent(event))
                locateFileInList(_shortcutHelper.text);
            return false;
        };

        rightPanel.addChild(_edPath);
        rightPanel.addChild(_fileList);
        rightPanel.addChild(fnlayout);


        addChild(content);
        if (_flags & FileDialogFlag.EnableCreateDirectory) {
            addChild(createButtonsPanel([ACTION_CREATE_DIRECTORY, cast(immutable)_action, ACTION_CANCEL], 1, 1));
        } else {
            addChild(createButtonsPanel([cast(immutable)_action, ACTION_CANCEL], 0, 0));
        }

        _fileList.customCellAdapter = this;
        _fileList.cellActivated = delegate(GridWidgetBase source, int col, int row) {
            onItemActivated(row);
        };
        _fileList.cellSelected = delegate(GridWidgetBase source, int col, int row) {
            onItemSelected(row);
        };

        if (_path.empty || !_path.exists || !_path.isDir) {
            _path = currentDir;
            if (!_path.exists || !_path.isDir)
                _path = homePath;
        }
        openDirectory(_path, _filename);
        _fileList.layoutHeight = FILL_PARENT;

        // set default file name if specified by user
        if (defaultFilename.length != 0)
            _edFilename.text = toUTF32(baseName(defaultFilename));
    }

    /// get sort order suffix for column title
    protected dstring appendSortOrderSuffix(dstring columnName, FileListSortOrder arrowUp, FileListSortOrder arrowDown) {
        if (_sortOrder == arrowUp)
            return columnName ~ " ▲";
        if (_sortOrder == arrowDown)
            return columnName ~ " ▼";
        return columnName;
    }

    protected void updateColumnHeaders() {
        _fileList.setColTitle(1, appendSortOrderSuffix(UIString.fromId("COL_NAME"c).value, FileListSortOrder.NAME_DESC, FileListSortOrder.NAME));
        _fileList.setColTitle(2, appendSortOrderSuffix(UIString.fromId("COL_SIZE"c).value, FileListSortOrder.SIZE_DESC, FileListSortOrder.SIZE));
        _fileList.setColTitle(3, appendSortOrderSuffix(UIString.fromId("COL_MODIFIED"c).value, FileListSortOrder.TIMESTAMP_DESC, FileListSortOrder.TIMESTAMP));
    }

    protected void onHeaderCellClicked(GridWidgetBase source, int col, int row) {
        debug Log.d("onHeaderCellClicked col=", col, " row=", row);
        if (row == 0 && col >= 2 && col <= 4) {
            // 2=NAME, 3=SIZE, 4=MODIFIED
            changeSortOrder(col);
        }
    }

    protected TextTypingShortcutHelper _shortcutHelper;

    /// Set widget rectangle to specified value and layout widget contents. (Step 2 of two phase layout).
    override void layout(Rect rc) {
        super.layout(rc);
        autofitGrid();
    }


    ///// Measure widget according to desired width and height constraints. (Step 1 of two phase layout).
    //override void measure(int parentWidth, int parentHeight) {
    //    super.measure(parentWidth, parentHeight);
    //    for(int i = 0; i < childCount; i++) {
    //        Widget w = child(i);
    //        Log.d("id=", w.id, " measuredHeight=", w.measuredHeight );
    //        for (int j = 0; j < w.childCount; j++) {
    //            Widget w2 = w.child(j);
    //            Log.d("    id=", w2.id, " measuredHeight=", w.measuredHeight );
    //        }
    //    }
    //    Log.d("this id=", id, " measuredHeight=", measuredHeight);
    //}

    override void onShow() {
        _fileList.setFocus();
    }
}

interface OnPathSelectionHandler {
    bool onPathSelected(string path);
}

class FilePathPanelItem : HorizontalLayout {
    protected string _path;
    protected TextWidget _text;
    protected ImageButton _button;
    Listener!OnPathSelectionHandler onPathSelectionListener;
    this(string path) {
        super(null);
        styleId = STYLE_LIST_ITEM;
        _path = path;
        string fname = isRoot(path) ? path : baseName(path);
        _text = new TextWidget(null, toUTF32(fname));
        _text.styleId = STYLE_BUTTON_TRANSPARENT;
        _text.clickable = true;
        _text.click = &onTextClick;
        //_text.backgroundColor = 0xC0FFFF;
        _text.state = State.Parent;
        _button = new ImageButton(null, ATTR_SCROLLBAR_BUTTON_RIGHT);
        _button.styleId = STYLE_BUTTON_TRANSPARENT;
        _button.focusable = false;
        _button.click = &onButtonClick;
        //_button.backgroundColor = 0xC0FFC0;
        _button.state = State.Parent;
        trackHover(true);
        addChild(_text);
        addChild(_button);
        margins(Rect(2.pointsToPixels + 1, 0, 2.pointsToPixels + 1, 0));
    }

    private bool onTextClick(Widget src) {
        if (onPathSelectionListener.assigned)
            return onPathSelectionListener(_path);
        return false;
    }
    private bool onButtonClick(Widget src) {
        // show popup menu with subdirs
        string[] filters;
        DirEntry[] entries;
        try {
            AttrFilter attrFilter = AttrFilter.dirs | AttrFilter.parent;
            entries = listDirectory(_path, attrFilter);
        } catch(Exception e) {
            return false;
        }
        if (entries.length == 0)
            return false;
        MenuItem dirs = new MenuItem();
        int itemId = 25000;
        foreach(ref DirEntry e; entries) {
            string fullPath = e.name;
            string d = baseName(fullPath);
            Action a = new Action(itemId++, toUTF32(d));
            a.stringParam = fullPath;
            MenuItem item = new MenuItem(a);
            item.menuItemAction = delegate(const Action action) {
                if (onPathSelectionListener.assigned)
                    return onPathSelectionListener(action.stringParam);
                return false;
            };
            dirs.add(item);
        }
        PopupMenu menuWidget = new PopupMenu(dirs);
        PopupWidget popup = window.showPopup(menuWidget, this, PopupAlign.Below);
        popup.flags = PopupFlags.CloseOnClickOutside;
        return true;
    }
}

/// Panel with buttons - path segments - for fast navigation to subdirs.
class FilePathPanelButtons : WidgetGroupDefaultDrawing {
    protected string _path;
    Listener!OnPathSelectionHandler onPathSelectionListener;
    protected bool onPathSelected(string path) {
        if (onPathSelectionListener.assigned) {
            return onPathSelectionListener(path);
        }
        return false;
    }
    this(string ID = null) {
        super(ID);
        layoutWidth = FILL_PARENT;
        clickable = true;
    }
    protected void initialize(string path) {
        _path = path;
        _children.clear();
        string itemPath = path;
        for (;;) {
            FilePathPanelItem item = new FilePathPanelItem(itemPath);
            item.onPathSelectionListener = &onPathSelected;
            addChild(item);
            if (isRoot(itemPath)) {
                break;
            }
            itemPath = parentDir(itemPath);
        }
    }
    /// Measure widget according to desired width and height constraints. (Step 1 of two phase layout).
    override void measure(int parentWidth, int parentHeight) {
        Rect m = margins;
        Rect p = padding;

        // calc size constraints for children
        int pwidth = 0;
        int pheight = 0;
        if (parentWidth != SIZE_UNSPECIFIED)
            pwidth = parentWidth - (m.left + m.right + p.left + p.right);

        if (parentHeight != SIZE_UNSPECIFIED)
            pheight = parentHeight - (m.top + m.bottom + p.top + p.bottom);
        int reservedForEmptySpace = parentWidth / 20;
        if (reservedForEmptySpace > 40.pointsToPixels)
            reservedForEmptySpace = 40.pointsToPixels;
        if (reservedForEmptySpace < 4.pointsToPixels)
            reservedForEmptySpace = 4.pointsToPixels;

        Point sz;
        sz.x += reservedForEmptySpace;
        // measure children
        bool exceeded = false;
        for (int i = 0; i < _children.count; i++) {
            Widget item = _children.get(i);
            item.measure(pwidth, pheight);
            if (sz.y < item.measuredHeight)
                sz.y = item.measuredHeight;
            if (sz.x + item.measuredWidth > pwidth) {
                exceeded = true;
            }
            if (!exceeded || i == 0) // at least one item must be measured
                sz.x += item.measuredWidth;
        }
        measuredContent(parentWidth, parentHeight, sz.x, sz.y);
    }
    /// Set widget rectangle to specified value and layout widget contents. (Step 2 of two phase layout).
    override void layout(Rect rc) {
        //Log.d("tabControl.layout enter");
        _needLayout = false;
        if (visibility == Visibility.Gone) {
            return;
        }
        _pos = rc;
        applyMargins(rc);
        applyPadding(rc);

        int reservedForEmptySpace = rc.width / 20;
        if (reservedForEmptySpace > 40)
            reservedForEmptySpace = 40;
        if (reservedForEmptySpace < 4)
            reservedForEmptySpace = 4;
        int maxw = rc.width - reservedForEmptySpace;
        int totalw = 0;
        int visibleItems = 0;
        bool exceeded = false;
        // measure and update visibility
        for (int i = 0; i < _children.count; i++) {
            Widget item = _children.get(i);
            item.visibility = Visibility.Visible;
            item.measure(rc.width, rc.height);
            if (totalw + item.measuredWidth > rc.width) {
                exceeded = true;
            }
            if (!exceeded || i == 0) { // at least one item must be visible
                totalw += item.measuredWidth;
                visibleItems++;
            } else
                item.visibility = Visibility.Gone;
        }
        // layout visible items
        // backward order
        Rect itemRect = rc;
        for (int i = visibleItems - 1; i >= 0; i--) {
            Widget item = _children.get(i);
            int w = item.measuredWidth;
            if (i == visibleItems - 1 && w > maxw)
                w = maxw;
            itemRect.right = itemRect.left + w;
            item.layout(itemRect);
            itemRect.left += w;
        }

    }


}

interface PathSelectedHandler {
    bool onPathSelected(string path);
}

/// Panel - either path segment buttons or text editor line
class FilePathPanel : FrameLayout {
    Listener!OnPathSelectionHandler onPathSelectionListener;
    static const ID_SEGMENTS = "SEGMENTS";
    static const ID_EDITOR = "ED_PATH";
    protected FilePathPanelButtons _segments;
    protected EditLine _edPath;
    protected string _path;
    Signal!PathSelectedHandler pathListener;
    this(string ID = null) {
        super(ID);
        _segments = new FilePathPanelButtons(ID_SEGMENTS);
        _edPath = new EditLine(ID_EDITOR);
        _edPath.layoutWidth = FILL_PARENT;
        _edPath.enterKey = &onEnterKey;
        _edPath.focusChange = &onEditorFocusChanged;
        _segments.click = &onSegmentsClickOutside;
        _segments.onPathSelectionListener = &onPathSelected;
        addChild(_segments);
        addChild(_edPath);
    }

    void setDefaultPopupMenu() {
        _edPath.setDefaultPopupMenu();
    }

    protected bool onEditorFocusChanged(Widget source, bool focused) {
        if (!focused) {
            _edPath.text = toUTF32(_path);
            showChild(ID_SEGMENTS);
        }
        return true;
    }
    protected bool onPathSelected(string path) {
        if (onPathSelectionListener.assigned) {
            if (exists(path))
                return onPathSelectionListener(path);
        }
        return false;
    }
    protected bool onSegmentsClickOutside(Widget w) {
        // switch to editor
        _edPath.text = toUTF32(_path);
        showChild(ID_EDITOR);
        _edPath.setFocus();
        return true;
    }
    protected bool onEnterKey(EditWidgetBase editor) {
        string fn = buildNormalizedPath(toUTF8(_edPath.text));
        if (exists(fn) && isDir(fn))
            onPathSelected(fn);
        return true;
    }

    @property void path(string value) {
        _segments.initialize(value);
        _edPath.text = toUTF32(value);
        _path = value;
        showChild(ID_SEGMENTS);
    }
    @property string path() {
        return _path;
    }
}

class FileNameEditLine : HorizontalLayout {
    protected EditLine _edFileName;
    protected Button _btn;
    protected string[string] _filetypeIcons;
    protected dstring _caption;
    protected uint _fileDialogFlags = DialogFlag.Modal | DialogFlag.Resizable | FileDialogFlag.FileMustExist | FileDialogFlag.EnableCreateDirectory;
    protected FileFilterEntry[] _filters;
    protected int _filterIndex;

    /// Modified state change listener (e.g. content has been saved, or first time modified after save)
    Signal!ModifiedStateListener modifiedStateChange;
    /// editor content is changed
    Signal!EditableContentChangeListener contentChange;

    @property ref Signal!EditorActionHandler editorAction() {
        return _edFileName.editorAction;
    }

    /// handle Enter key press inside line editor
    @property ref Signal!EnterKeyHandler enterKey() {
        return _edFileName.enterKey;
    }

    void setDefaultPopupMenu() {
        _edFileName.setDefaultPopupMenu();
    }

    this(string ID = null) {
        super(ID);
        _caption = UIString.fromId("TITLE_OPEN_FILE"c).value;
        _edFileName = new EditLine("FileNameEditLine_edFileName");
        _edFileName.minWidth(WIDGET_STYLE_CONSOLE ? 16 : 200);
        _edFileName.layoutWidth = FILL_PARENT;
        _btn = new Button("FileNameEditLine_btnFile", "..."d);
        _btn.styleId = STYLE_BUTTON_NOMARGINS;
        _btn.layoutWeight = 0;
        _btn.click = delegate(Widget src) {
            FileDialog dlg = new FileDialog(UIString.fromRaw(_caption), window, null, _fileDialogFlags);
            foreach(key, value; _filetypeIcons)
                dlg.filetypeIcons[key] = value;
            dlg.filters = _filters;
            dlg.dialogResult = delegate(Dialog dlg, const Action result) {
                if (result.id == ACTION_OPEN.id || result.id == ACTION_OPEN_DIRECTORY.id) {
                    _edFileName.text = toUTF32(result.stringParam);
                    if (contentChange.assigned)
                        contentChange(_edFileName.content);
                }
            };
            string path = toUTF8(_edFileName.text);
            if (!path.empty) {
                if (exists(path) && isFile(path)) {
                    dlg.path = dirName(path);
                    dlg.filename = baseName(path);
                } else if (exists(path) && isDir(path)) {
                    dlg.path = path;
                }
            }
            dlg.show();
            return true;
        };
        _edFileName.contentChange = delegate(EditableContent content) {
            if (contentChange.assigned)
                contentChange(content);
        };
        _edFileName.modifiedStateChange = delegate(Widget src, bool modified) {
            if (modifiedStateChange.assigned)
                modifiedStateChange(src, modified);
        };
        addChild(_edFileName);
        addChild(_btn);
    }

    @property uint fileDialogFlags() { return _fileDialogFlags; }
    @property void fileDialogFlags(uint f) { _fileDialogFlags = f; }

    @property dstring caption() { return _caption; }
    @property void caption(dstring s) { _caption = s; }

    /// returns widget content text (override to support this)
    override @property dstring text() const { return _edFileName.text; }
    /// sets widget content text (override to support this)
    override @property Widget text(dstring s) { _edFileName.text = s; return this; }
    /// sets widget content text (override to support this)
    override @property Widget text(UIString s) { _edFileName.text = s.value; return this; }

    /// mapping of file extension to icon resource name, e.g. ".txt": "text-plain"
    @property ref string[string] filetypeIcons() { return _filetypeIcons; }

    /// filter list for file type filter combo box
    @property FileFilterEntry[] filters() {
        return _filters;
    }

    /// filter list for file type filter combo box
    @property void filters(FileFilterEntry[] values) {
        _filters = values;
    }

    /// add new filter entry
    void addFilter(FileFilterEntry value) {
        _filters ~= value;
    }

    /// filter index
    @property int filterIndex() {
        return _filterIndex;
    }

    /// filter index
    @property void filterIndex(int index) {
        _filterIndex = index;
    }

    @property bool readOnly() { return _edFileName.readOnly; }
    @property void readOnly(bool f) { _edFileName.readOnly = f; }

}

class DirEditLine : FileNameEditLine {
    this(string ID = null) {
        super(ID);
        _fileDialogFlags = DialogFlag.Modal | DialogFlag.Resizable
            | FileDialogFlag.FileMustExist | FileDialogFlag.SelectDirectory | FileDialogFlag.EnableCreateDirectory;
        _caption = UIString.fromId("ACTION_SELECT_DIRECTORY"c);
    }
}

//import dlangui.widgets.metadata;
//mixin(registerWidgets!(FileNameEditLine, DirEditLine)());
