module dlangui.dialogs.settingsdialog;

import dlangui.core.events;
import dlangui.core.i18n;
import dlangui.core.stdaction;
import dlangui.core.files;
public import dlangui.core.settings;
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

/// item on settings page
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
    /// create setting widget
    Widget createWidget(Setting settings) {
        TextWidget res = new TextWidget(_id, _label);
        return res;
    }
}

/// checkbox setting
class CheckboxItem : SettingsItem {
    private bool _inverse;
    this(string id, UIString label, bool inverse = false) {
        super(id, label);
        _inverse = inverse;
    }
    /// create setting widget
    override Widget createWidget(Setting settings) {
        CheckBox res = new CheckBox(_id, _label);
        Setting setting = settings.settingByPath(_id, SettingType.FALSE);
        res.checked = setting.boolean ^ _inverse;
        res.onCheckChangeListener = delegate(Widget source, bool checked) {
            setting.boolean = checked ^ _inverse;
            return true;
        };
        return res;
    }
}

/// settings page - item of settings tree, can edit several settings
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

    SettingsPage addChild(SettingsPage item) {
        _children.add(item);
        item._parent = this;
        return item;
    }

    SettingsPage addChild(string id, UIString label) {
        return addChild(new SettingsPage(id, label));
    }

    @property int itemCount() {
        return _items.count;
    }

    /// returns page item by index
    SettingsItem item(int index) {
        return _items[index];
    }

    SettingsItem addItem(SettingsItem item) {
        _items.add(item);
        item._page = this;
        return item;
    }

    /// add checkbox (boolean value) for setting
    CheckboxItem addCheckbox(string id, UIString label, bool inverse = false) {
        CheckboxItem res = new CheckboxItem(id, label, inverse);
        addItem(res);
        return res;
    }

    /// create page widget (default implementation creates empty page)
    Widget createWidget(Setting settings) {
        Widget res = new Widget(_id);
        res.minWidth(200).minHeight(200);
        return res;
    }

    /// returns true if this page is root page
    @property bool isRoot() {
        return !_parent;
    }

    TreeItem createTreeItem() {
        return new TreeItem(_id, _label);
    }

}

class SettingsDialog : Dialog {
    protected TreeWidget _tree;
    protected FrameLayout _frame;
    protected Setting _settings;
    protected SettingsPage _layout;

	this(UIString caption, Window parent, Setting settings, SettingsPage layout) {
        super(caption, parent, DialogFlag.Modal | DialogFlag.Resizable | DialogFlag.Popup);
        _settings = settings;
        _layout = layout;
    }

    void onTreeItemSelected(TreeItems source, TreeItem selectedItem, bool activated) {
        if (!selectedItem)
            return;
    }

    void createControls(SettingsPage page, TreeItem base) {
        TreeItem item = base;
        if (!page.isRoot) {
            item = page.createTreeItem();
            Widget widget = page.createWidget(_settings);
            base.addChild(item);
            _frame.addChild(widget);
        }
        if (page.childCount > 0) {
            for (int i = 0; i < page.childCount; i++) {
                createControls(page.child(i), item);
            }
        }
    }

    /// override to implement creation of dialog controls
	override void init() {
		minWidth(600).minHeight(400);
        _tree = new TreeWidget("prop_tree");
        _tree.layoutHeight(FILL_PARENT).layoutHeight(FILL_PARENT);
        _tree.minHeight(200).minWidth(100);
        _tree.selectionListener = &onTreeItemSelected;
		_tree.fontSize = 16;
        _frame = new FrameLayout("prop_pages");
        _frame.minHeight(200).minWidth(100);
        createControls(_layout, _tree.items);
        HorizontalLayout content = new HorizontalLayout("settings_dlg_content");
        content.addChild(_tree);
        content.addChild(_frame);
        content.layoutHeight(FILL_PARENT).layoutHeight(FILL_PARENT);
		addChild(content);
		addChild(createButtonsPanel([ACTION_APPLY, ACTION_CANCEL], 0, 0));
    }

}
