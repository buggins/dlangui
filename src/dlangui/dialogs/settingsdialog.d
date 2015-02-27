module dlangui.dialogs.settingsdialog;

import dlangui.core.events;
import dlangui.core.i18n;
import dlangui.core.stdaction;
import dlangui.core.files;
import dlangui.core.settings;
import dlangui.widgets.controls;
import dlangui.widgets.lists;
import dlangui.widgets.layouts;
import dlangui.widgets.tree;
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

class SettingsItem {
    protected string _id;
    protected UIString _label;
    protected SettingsPage _page;
    this(string id, UIString label) {
        _id = id;
        _label = label;
    }
    /// setting path, e.g. "editor/tabSize"
    @property string id() { return _id; }
    @property ref UIString label() { return _label; }
}

class SettingsPage {
    protected SettingsPage _parent;
    protected ObjectList!SettingsPage _children;
    protected ObjectList!SettingsItem _items;
    protected string _id;
    protected UIString _label;

    this(string id, UIString label) {
        _id = id;
        _label = label;
    }

    @property string id() { return _id; }
    @property ref UIString label() { return _label; }

    @property int childCount() {
        return _children.count;
    }

    /// returns child page by index
    SettingsPage child(int index) {
        return _children[index];
    }

    void addChild(SettingsPage item) {
        _children.add(item);
        item._parent = this;
    }

    @property int itemCount() {
        return _items.count;
    }

    /// returns page item by index
    SettingsItem item(int index) {
        return _items[index];
    }

    void addChild(SettingsItem item) {
        _items.add(item);
        item._page = this;
    }
}

class SettingsDialog : Dialog {
    protected TreeWidget _tree;
    protected FrameLayout _frame;
    protected SettingsFile _settings;

	this(UIString caption, Window parent, SettingsFile settings) {
        super(caption, parent, DialogFlag.Modal | DialogFlag.Resizable | DialogFlag.Popup);
        _settings = settings;
    }

    void onTreeItemSelected(TreeItems source, TreeItem selectedItem, bool activated) {
        if (!selectedItem)
            return;
    }

    /// override to implement creation of dialog controls
	override void init() {
		minWidth(600).minHeight(400);
        _tree = new TreeWidget("prop_tree");
        _tree.layoutHeight(FILL_PARENT).layoutHeight(FILL_PARENT);
        _tree.selectionListener = &onTreeItemSelected;
		_tree.fontSize = 16;
        _frame = new FrameLayout("prop_pages");

    }

}
