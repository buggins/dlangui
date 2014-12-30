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
import dlangui.platforms.common.platform;
import dlangui.dialogs.dialog;

private import std.algorithm;
private import std.file;
private import std.path;
private import std.utf;
private import std.conv : to;


/// flags for file dialog options
enum FileDialogFlag : uint {
    /// file must exist (use this for open dialog)
    FileMustExist = 0x100,
    /// ask before saving to existing
    ConfirmOverwrite = 0x200,
    /// flags for Open dialog
    Open = FileMustExist,
    /// flags for Save dialog
    Save = ConfirmOverwrite,
}

/// File open / save dialog
class FileDialog : Dialog, CustomGridCellAdapter {
	protected EditLine _edPath;
	protected EditLine _edFilename;
	protected StringGridWidget _fileList;
	//protected StringGridWidget places;
	protected VerticalLayout leftPanel;
	protected VerticalLayout rightPanel;
    protected Action _action;

    protected RootEntry[] _roots;
    protected string _path;
    protected string _filename;
    protected DirEntry[] _entries;
    protected bool _isRoot;

    protected bool _isOpenDialog;

	this(UIString caption, Window parent, Action action = null, uint fileDialogFlags = DialogFlag.Modal | DialogFlag.Resizable | FileDialogFlag.FileMustExist) {
        super(caption, parent, fileDialogFlags);
        _isOpenDialog = !(_flags & FileDialogFlag.ConfirmOverwrite);
        if (action is null) {
            if (_isOpenDialog)
                action = ACTION_OPEN.clone();
            else
                action = ACTION_SAVE.clone();
        }
        _action = action;
    }

    /// Set widget rectangle to specified value and layout widget contents. (Step 2 of two phase layout).
    override void layout(Rect rc) {
        super.layout(rc);
        _fileList.autoFitColumnWidths();
        _fileList.fillColumnWidth(1);
    }

    protected bool upLevel() {
        return openDirectory(parentDir(_path), _path);
    }

    protected bool openDirectory(string dir, string selectedItemPath) {
        dir = buildNormalizedPath(dir);
        Log.d("FileDialog.openDirectory(", dir, ")");
        _fileList.rows = 0;
        string[] filters;
        if (!listDirectory(dir, true, true, false, filters, _entries))
            return false;
        _path = dir;
        _isRoot = isRoot(dir);
        _edPath.text = toUTF32(_path);
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
            } else {
                _fileList.setCellText(0, i, "text-plain"d);
                sz = to!string(_entries[i].size);
                date = "2014-01-01 00:00:00";
            }
            _fileList.setCellText(2, i, toUTF32(sz));
            _fileList.setCellText(3, i, toUTF32(date));
        }
        _fileList.autoFitColumnWidths();
        _fileList.fillColumnWidth(1);
        if (selectionIndex >= 0)
            _fileList.selectCell(1, selectionIndex + 1, true);
        else if (_entries.length > 0)
            _fileList.selectCell(1, 1, true);
        return true;
    }

    override bool onKeyEvent(KeyEvent event) {
        if (event.action == KeyAction.KeyDown) {
            if (event.keyCode == KeyCode.BACK && event.flags == 0) {
                upLevel();
                return true;
            }
        }
        return false;
    }

    /// return true for custom drawn cell
    override bool isCustomCell(int col, int row) {
        if (col == 0 && row >= 0)
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
        DrawableRef icon = rowIcon(row);
        if (icon.isNull)
            return Point(0, 0);
        return Point(icon.width + 2, icon.height + 2);
    }

	/// draw data cell content
	override void drawCell(DrawBuf buf, Rect rc, int col, int row) {
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
        res.styleId = "EDIT_BOX";
        WidgetListAdapter adapter = new WidgetListAdapter();
        foreach(ref RootEntry root; _roots) {
            ImageTextButton btn = new ImageTextButton(null, root.icon, root.label);
            btn.orientation = Orientation.Vertical;
            btn.styleId = "TRANSPARENT_BUTTON_BACKGROUND";
            btn.focusable = false;
            adapter.widgets.add(btn);
        }
        res.ownAdapter = adapter;
        res.layoutWidth(WRAP_CONTENT).layoutHeight(FILL_PARENT).layoutWeight(0);
        res.onItemClickListener = delegate(Widget source, int itemIndex) {
            openDirectory(_roots[itemIndex].path, null);
            return true;
        };
        res.focusable = true;
        debug Log.d("root lisk styleId=", res.styleId);
        return res;
    }

    /// file list item activated (double clicked or Enter key pressed)
    protected void onItemActivated(int index) {
        DirEntry e = _entries[index];
        if (e.isDir) {
            openDirectory(e.name, _path);
        } else if (e.isFile) {
            string fname = e.name;
            Action result = _action;
            result.stringParam = fname;
            close(result);
        }

    }

    /// file list item selected
    protected void onItemSelected(int index) {
        DirEntry e = _entries[index];
        if (e.isDir) {
            _edFilename.text = ""d;
            _filename = "";
        } else if (e.isFile) {
            string fname = e.name;
            _edFilename.text = toUTF32(baseName(fname));
            _filename = fname;
        }
    }

    /// Custom handling of actions
    override bool handleAction(const Action action) {
        if (action.id == StandardAction.Cancel) {
            super.handleAction(action);
            return true;
        }
        if (action.id == StandardAction.Open || action.id == StandardAction.Save) {
            if (_filename.length > 0) {
                Action result = _action;
                result.stringParam = _filename;
                close(result);
                return true;
            }
        }
        return super.handleAction(action);
    }


	/// override to implement creation of dialog controls
	override void init() {
        _roots = getRootPaths;

		layoutWidth(FILL_PARENT);
		layoutWidth(FILL_PARENT);
        minWidth = 600;
        minHeight = 400;

		LinearLayout content = new HorizontalLayout("dlgcontent");

		content.layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT).minWidth(400).minHeight(300);

		leftPanel = new VerticalLayout("places");
        leftPanel.addChild(createRootsList());
		leftPanel.layoutHeight(FILL_PARENT).minWidth(40);

		rightPanel = new VerticalLayout("main");
		rightPanel.layoutHeight(FILL_PARENT).layoutWidth(FILL_PARENT);
		rightPanel.addChild(new TextWidget(null, "Path:"d));

		content.addChild(leftPanel);
		content.addChild(rightPanel);

		_edPath = new EditLine("path");
		_edPath.layoutWidth(FILL_PARENT);
        _edPath.layoutWeight = 0;

		_edFilename = new EditLine("filename");
		_edFilename.layoutWidth(FILL_PARENT);
        _edFilename.layoutWeight = 0;

		rightPanel.addChild(_edPath);
		_fileList = new StringGridWidget("files");
		_fileList.layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT);
		_fileList.resize(4, 3);
		_fileList.setColTitle(0, " "d);
		_fileList.setColTitle(1, "Name"d);
		_fileList.setColTitle(2, "Size"d);
		_fileList.setColTitle(3, "Modified"d);
		_fileList.showRowHeaders = false;
		_fileList.rowSelect = true;
		rightPanel.addChild(_fileList);
		rightPanel.addChild(_edFilename);


		addChild(content);
		addChild(createButtonsPanel([cast(immutable)_action, ACTION_CANCEL], 0, 0));

        _fileList.customCellAdapter = this;
        _fileList.onCellActivated = delegate(GridWidgetBase source, int col, int row) {
            onItemActivated(row);
        };
        _fileList.onCellSelected = delegate(GridWidgetBase source, int col, int row) {
            onItemSelected(row);
        };

        openDirectory(currentDir, null);
        _fileList.layoutHeight = FILL_PARENT;

	}

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
        _path = path;
        string fname = baseName(path);
        _text = new TextWidget(null, toUTF32(fname));
        _text.clickable = true;
        _text.onClickListener = &onTextClick;
        _button = new ImageButton(null, "scrollbar_btn_right");
        _button.focusable = false;
        _button.onClickListener = &onButtonClick;
        addChild(_text);
        addChild(_button);
        margins(Rect(2,0,2,0));
    }
    private bool onTextClick(Widget src) {
        if (onPathSelectionListener.assigned)
            return onPathSelectionListener(_path);
        return false;
    }
    private bool onButtonClick(Widget src) {
        // TODO: show popup menu with subdirs
        return true;
    }
}

class FilePathPanelButtons : WidgetGroup {
    protected string _path;
    this() {
        super(null);
    }
    void init(string path) {
        _path = path;
        _children.clear();
        string itemPath = path;
        for (;;) {
            FilePathPanelItem item = new FilePathPanelItem(itemPath);
            addChild(item);
            if (isRoot(path)) {
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
        int pwidth = parentWidth;
        int pheight = parentHeight;
        if (parentWidth != SIZE_UNSPECIFIED)
            pwidth -= m.left + m.right + p.left + p.right;
        if (parentHeight != SIZE_UNSPECIFIED)
            pheight -= m.top + m.bottom + p.top + p.bottom;
        int reservedForEmptySpace = parentWidth / 16;
        Point sz;
        sz.x += reservedForEmptySpace;
        // measure children
        bool exceeded = false;
        for (int i = 0; i < _children.count; i++) {
            Widget item = _children.get(i);
            item.visibility = Visibility.Visible;
            item.measure(pwidth, pheight);
            if (sz.y < item.measuredHeight)
                sz.y = item.measuredHeight;
            if (sz.x + item.measuredWidth > pwidth) {
                exceeded = true;
            }
            if (!exceeded || i == 0) // at least one item must be visible
                sz.x += item.measuredWidth;
            else
                item.visibility = Visibility.Gone;
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

        int reservedForEmptySpace = rc.width / 16;
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
            rc.right = rc.left + w;
            item.layout(rc);
            rc.left += w;
        }

    }

}

class FilePathPanel : FrameLayout {
    protected HorizontalLayout _segments;
	protected EditLine _edPath;
    this(string ID = null) {
        super(ID);
    }
}
