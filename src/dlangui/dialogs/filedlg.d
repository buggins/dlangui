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
	protected EditLine path;
	protected EditLine filename;
	protected StringGridWidget list;
	//protected StringGridWidget places;
	protected VerticalLayout leftPanel;
	protected VerticalLayout rightPanel;

    protected RootEntry[] _roots;
    protected string _path;
    protected string _filename;
    protected DirEntry[] _entries;
    protected bool _isRoot;

	this(UIString caption, Window parent, uint fileDialogFlags = DialogFlag.Modal | DialogFlag.Resizable | FileDialogFlag.FileMustExist) {
        super(caption, parent, fileDialogFlags);
    }

    protected bool openDirectory(string dir) {
        dir = buildNormalizedPath(dir);
        Log.d("FileDialog.openDirectory(", dir, ")");
        list.rows = 0;
        string[] filters;
        if (!listDirectory(dir, true, true, filters, _entries))
            return false;
        _path = dir;
        _isRoot = isRoot(dir);
        path.text = toUTF32(_path);
        list.rows = _entries.length;
        for (int i = 0; i < _entries.length; i++) {
            string fname = baseName(_entries[i].name);
            string sz;
            string date;
            bool d = _entries[i].isDir;
            list.setCellText(1, i, toUTF32(fname));
            if (d) {
                list.setCellText(0, i, "folder");
            } else {
                list.setCellText(0, i, "text-plain"d);
                sz = to!string(_entries[i].size);
                date = "2014-01-01 00:00:00";
            }
            list.setCellText(2, i, toUTF32(sz));
            list.setCellText(3, i, toUTF32(date));
        }
        list.autoFitColumnWidths();
        return true;
    }

    /// return true for custom drawn cell
    override bool isCustomCell(int col, int row) {
        if (col == 0 && row >= 0)
            return true;
        return false;
    }

    protected DrawableRef rowIcon(int row) {
        string iconId = toUTF8(list.cellText(0, row));
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

    protected Widget createRootsList() {
        ListWidget list = new ListWidget("ROOTS_LIST");
        WidgetListAdapter adapter = new WidgetListAdapter();
        foreach(ref RootEntry root; _roots) {
            ImageTextButton btn = new ImageTextButton(null, root.icon, root.label);
            btn.orientation = Orientation.Vertical;
            btn.styleId = "TRANSPARENT_BUTTON_BACKGROUND";
            btn.focusable = false;
            adapter.widgets.add(btn);
        }
        list.ownAdapter = adapter;
        list.layoutWidth = WRAP_CONTENT;
        list.layoutHeight = FILL_PARENT;
        list.onItemClickListener = delegate(Widget source, int itemIndex) {
            openDirectory(_roots[itemIndex].path);
            return true;
        };
        return list;
    }

    protected void onItemActivated(int index) {
        DirEntry e = _entries[index];
        if (e.isDir) {
            openDirectory(e.name);
        } else if (e.isFile) {
        }

    }

	/// override to implement creation of dialog controls
	override void init() {
        _roots = getRootPaths;
		layoutWidth(FILL_PARENT);
		layoutWidth(FILL_PARENT);
		LinearLayout content = new HorizontalLayout("dlgcontent");
		content.layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT).minWidth(400).minHeight(300);
		leftPanel = new VerticalLayout("places");
        leftPanel.addChild(createRootsList());
		rightPanel = new VerticalLayout("main");
		leftPanel.layoutHeight(FILL_PARENT).minWidth(40);
		rightPanel.layoutHeight(FILL_PARENT).layoutWidth(FILL_PARENT);
		rightPanel.addChild(new TextWidget(null, "Path:"d));
		content.addChild(leftPanel);
		content.addChild(rightPanel);
		path = new EditLine("path");
		path.layoutWidth(FILL_PARENT);
		filename = new EditLine("path");
		filename.layoutWidth(FILL_PARENT);

		rightPanel.addChild(path);
		list = new StringGridWidget("files");
		list.layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT);
		list.resize(4, 3);
		list.setColTitle(0, " "d);
		list.setColTitle(1, "Name"d);
		list.setColTitle(2, "Size"d);
		list.setColTitle(3, "Modified"d);
		list.showRowHeaders = false;
		list.rowSelect = true;
		rightPanel.addChild(list);
		rightPanel.addChild(filename);

		//places = new StringGridWidget("placesList");
		//places.resize(1, 10);
		//places.showRowHeaders(false).showColHeaders(true);
		//places.setColTitle(0, "Places"d);
		//leftPanel.addChild(places);

		addChild(content);
		addChild(createButtonsPanel([ACTION_OPEN, ACTION_CANCEL], 0, 0));

		//string[] path = splitPath("/home/lve/src");
		//Log.d("path: ", path);

        list.customCellAdapter = this;
        list.onCellActivated = delegate(GridWidgetBase source, int col, int row) {
            onItemActivated(row);
        };

        openDirectory(currentDir);
        minWidth = 600;
        minHeight = 400;
        layoutWidth = FILL_PARENT;
        list.layoutHeight = FILL_PARENT;
        layoutHeight = FILL_PARENT;
	}
}
