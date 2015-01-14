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
private import std.utf;
private import std.conv : to;
private import std.array : split;


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

/// filetype filter entry for FileDialog
struct FileFilterEntry {
	UIString label;
	string[] filter;
	this(UIString displayLabel, string filterList) {
		label = displayLabel;
		if (filterList.length)
			filter = split(filterList, ";");
	}
}

/// File open / save dialog
class FileDialog : Dialog, CustomGridCellAdapter {
	protected FilePathPanel _edPath;
	protected EditLine _edFilename;
	protected ComboBox _cbFilters;
	protected StringGridWidget _fileList;
	protected VerticalLayout leftPanel;
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

	/// return currently selected filter value - array of patterns like ["*.txt", "*.rtf"]
	@property string[] selectedFilter() {
		if (_filterIndex >= 0 && _filterIndex < _filters.length)
			return _filters[_filterIndex].filter;
		return null;
	}

    protected bool upLevel() {
        return openDirectory(parentDir(_path), _path);
    }

	protected bool reopenDirectory() {
		return openDirectory(_path, null);
	}

    protected bool openDirectory(string dir, string selectedItemPath) {
        dir = buildNormalizedPath(dir);
        Log.d("FileDialog.openDirectory(", dir, ")");
        _fileList.rows = 0;
        if (!listDirectory(dir, true, true, false, selectedFilter, _entries))
            return false;
        _path = dir;
        _isRoot = isRoot(dir);
        _edPath.path = _path; //toUTF32(_path);
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
        res.styleId = STYLE_EDIT_BOX;
        WidgetListAdapter adapter = new WidgetListAdapter();
        foreach(ref RootEntry root; _roots) {
            ImageTextButton btn = new ImageTextButton(null, root.icon, root.label);
            btn.orientation = Orientation.Vertical;
            btn.styleId = STYLE_TRANSPARENT_BUTTON_BACKGROUND;
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

	bool onPathSelected(string path) {
		//
		return openDirectory(path, null);
	}

	/// override to implement creation of dialog controls
	override void init() {
        _roots = getRootPaths;

		layoutWidth(FILL_PARENT);
		layoutWidth(FILL_PARENT);
        minWidth = 600;
        //minHeight = 400;

		LinearLayout content = new HorizontalLayout("dlgcontent");

		content.layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT); //.minWidth(400).minHeight(300);

		leftPanel = new VerticalLayout("places");
        leftPanel.addChild(createRootsList());
		leftPanel.layoutHeight(FILL_PARENT).minWidth(40);

		rightPanel = new VerticalLayout("main");
		rightPanel.layoutHeight(FILL_PARENT).layoutWidth(FILL_PARENT);
		rightPanel.addChild(new TextWidget(null, "Path:"d));

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
        //_edFilename.layoutWeight = 0;
		fnlayout.addChild(_edFilename);
		if (_filters.length) {
			dstring[] filterLabels;
			foreach(f; _filters)
				filterLabels ~= f.label.value;
			_cbFilters = new ComboBox("filter", filterLabels);
			_cbFilters.selectedItemIndex = _filterIndex;
			_cbFilters.onItemClickListener = delegate(Widget source, int itemIndex) {
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
		_fileList.layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT);
		_fileList.resize(4, 3);
		_fileList.setColTitle(0, " "d);
		_fileList.setColTitle(1, "Name"d);
		_fileList.setColTitle(2, "Size"d);
		_fileList.setColTitle(3, "Modified"d);
		_fileList.showRowHeaders = false;
		_fileList.rowSelect = true;

		rightPanel.addChild(_edPath);
		rightPanel.addChild(_fileList);
		rightPanel.addChild(fnlayout);


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

    /// Set widget rectangle to specified value and layout widget contents. (Step 2 of two phase layout).
    override void layout(Rect rc) {
        super.layout(rc);
        _fileList.autoFitColumnWidths();
        _fileList.fillColumnWidth(1);
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
        _text.onClickListener = &onTextClick;
		//_text.backgroundColor = 0xC0FFFF;
		_text.state = State.Parent;
        _button = new ImageButton(null, "scrollbar_btn_right");
		_button.styleId = STYLE_BUTTON_TRANSPARENT;
        _button.focusable = false;
        _button.onClickListener = &onButtonClick;
		//_button.backgroundColor = 0xC0FFC0;
		_button.state = State.Parent;
		trackHover(true);
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
        // show popup menu with subdirs
        string[] filters;
		DirEntry[] entries;
        if (!listDirectory(_path, true, false, false, filters, entries))
            return false;
		if (entries.length == 0)
			return false;
		MenuItem dirs = new MenuItem();
		int itemId = 25000;
		foreach(ref DirEntry e; entries) {
			string fullPath = e.name;
			string d = baseName(fullPath);
			Action a = new Action(itemId++, toUTF32(d));
			MenuItem item = new MenuItem(a);
			item.onMenuItemClick = delegate(MenuItem item) { 
				if (onPathSelectionListener.assigned)
					return onPathSelectionListener(fullPath);
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
class FilePathPanelButtons : WidgetGroup {
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
    protected void init(string path) {
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
        int pwidth = parentWidth;
        int pheight = parentHeight;
        if (parentWidth != SIZE_UNSPECIFIED)
            pwidth -= m.left + m.right + p.left + p.right;
        if (parentHeight != SIZE_UNSPECIFIED)
            pheight -= m.top + m.bottom + p.top + p.bottom;
        int reservedForEmptySpace = parentWidth / 20;
		if (reservedForEmptySpace > 40)
			reservedForEmptySpace = 40;

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

        int reservedForEmptySpace = rc.width / 20;
		if (reservedForEmptySpace > 40)
			reservedForEmptySpace = 40;
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

    /// Draw widget at its position to buffer
    override void onDraw(DrawBuf buf) {
        if (visibility != Visibility.Visible)
            return;
        super.onDraw(buf);
        Rect rc = _pos;
        applyMargins(rc);
        applyPadding(rc);
		auto saver = ClipRectSaver(buf, rc);
		for (int i = 0; i < _children.count; i++) {
			Widget item = _children.get(i);
			if (item.visibility != Visibility.Visible)
				continue;
			item.onDraw(buf);
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
		_edPath.editorActionListener = &onEditorAction;
		_edPath.onFocusChangeListener = &onEditorFocusChanged;
		_segments.onClickListener = &onSegmentsClickOutside;
		_segments.onPathSelectionListener = &onPathSelected;
		addChild(_segments);
		addChild(_edPath);
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
	protected bool onEditorAction(const Action action) {
		if (action.id == EditorActions.InsertNewLine) {
			string fn = buildNormalizedPath(toUTF8(_edPath.text));
			if (exists(fn) && isDir(fn))
				return onPathSelected(fn);
		}
		return false;
	}

	@property void path(string value) {
		_segments.init(value);
		_edPath.text = toUTF32(value);
		_path = value;
		showChild(ID_SEGMENTS);
	}
	@property string path() {
		return _path;
	}
}
