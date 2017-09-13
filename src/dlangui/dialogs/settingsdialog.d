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
import dlangui.widgets.styles;
import dlangui.platforms.common.platform;
import dlangui.dialogs.dialog;

private import std.algorithm;
private import std.file;
private import std.path;
private import std.utf : toUTF32;
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
    Widget[] createWidgets(Setting settings) {
        TextWidget res = new TextWidget(_id, _label);
        return [res];
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
    override Widget[] createWidgets(Setting settings) {
        CheckBox res = new CheckBox(_id, _label);
        res.minWidth = 60.pointsToPixels;
        res.layoutWidth = FILL_PARENT;
        Setting setting = settings.settingByPath(_id, SettingType.FALSE);
        res.checked = setting.boolean ^ _inverse;
        res.checkChange = delegate(Widget source, bool checked) {
            setting.boolean = checked ^ _inverse;
            return true;
        };
        return [res];
    }
}

/// ComboBox based setting with string keys
class StringComboBoxItem : SettingsItem {
    protected StringListValue[] _items;
    this(string id, UIString label, StringListValue[] items) {
        super(id, label);
        _items = items;
    }
    /// create setting widget
    override Widget[] createWidgets(Setting settings) {
        TextWidget lbl = new TextWidget(_id ~ "-label", _label);
        ComboBox cb = new ComboBox(_id, _items);
        cb.minWidth = 60.pointsToPixels;
        cb.layoutWidth = FILL_PARENT;
        Setting setting = settings.settingByPath(_id, SettingType.STRING);
        string itemId = setting.str;
        int index = -1;
        for (int i = 0; i < _items.length; i++) {
            if (_items[i].stringId.equal(itemId)) {
                index = i;
                break;
            }
        }
        if (index >= 0)
            cb.selectedItemIndex = index;
        cb.itemClick = delegate(Widget source, int itemIndex) {
            if (itemIndex >= 0 && itemIndex < _items.length)
                setting.str = _items[itemIndex].stringId;
            return true;
        };
        return [lbl, cb];
    }
}

/// ComboBox based setting with int keys
class IntComboBoxItem : SettingsItem {
    protected StringListValue[] _items;
    this(string id, UIString label, StringListValue[] items) {
        super(id, label);
        _items = items;
    }
    /// create setting widget
    override Widget[] createWidgets(Setting settings) {
        TextWidget lbl = new TextWidget(_id ~ "-label", _label);
        ComboBox cb = new ComboBox(_id, _items);
        cb.minWidth = 60.pointsToPixels;
        cb.layoutWidth = FILL_PARENT;
        Setting setting = settings.settingByPath(_id, SettingType.INTEGER);
        long itemId = setting.integer;
        int index = -1;
        for (int i = 0; i < _items.length; i++) {
            if (_items[i].intId == itemId) {
                index = i;
                break;
            }
        }
        if (index >= 0)
            cb.selectedItemIndex = index;
        cb.itemClick = delegate(Widget source, int itemIndex) {
            if (itemIndex >= 0 && itemIndex < _items.length)
                setting.integer = _items[itemIndex].intId;
            return true;
        };
        return [lbl, cb];
    }
}

/// ComboBox based setting with floating point keys (actualy, fixed point digits after period is specidied by divider constructor parameter)
class FloatComboBoxItem : SettingsItem {
    protected StringListValue[] _items;
    protected long _divider;
    this(string id, UIString label, StringListValue[] items, long divider = 1000) {
        super(id, label);
        _items = items;
        _divider = divider;
    }
    /// create setting widget
    override Widget[] createWidgets(Setting settings) {
        TextWidget lbl = new TextWidget(_id ~ "-label", _label);
        ComboBox cb = new ComboBox(_id, _items);
        cb.minWidth = 60.pointsToPixels;
        cb.layoutWidth = FILL_PARENT;
        Setting setting = settings.settingByPath(_id, SettingType.FLOAT);
        long itemId = cast(long)(setting.floating * _divider + 0.5f);
        int index = -1;
        for (int i = 0; i < _items.length; i++) {
            if (_items[i].intId == itemId) {
                index = i;
                break;
            }
        }
        if (index >= 0)
            cb.selectedItemIndex = index;
        if (index < 0) {
            debug Log.d("FloatComboBoxItem : item ", itemId, " is not found for value ", setting.floating);
        }
        cb.itemClick = delegate(Widget source, int itemIndex) {
            if (itemIndex >= 0 && itemIndex < _items.length)
                setting.floating = _items[itemIndex].intId / cast(double)_divider;
            return true;
        };
        return [lbl, cb];
    }
}

class NumberEditItem : SettingsItem {
    protected int _minValue;
    protected int _maxValue;
    protected int _defaultValue;
    this(string id, UIString label, int minValue = int.max, int maxValue = int.max, int defaultValue = 0) {
        super(id, label);
        _minValue = minValue;
        _maxValue = maxValue;
        _defaultValue = defaultValue;
    }
    /// create setting widget
    override Widget[] createWidgets(Setting settings) {
        TextWidget lbl = new TextWidget(_id ~ "-label", _label);
        EditLine ed = new EditLine(_id ~ "-edit", _label);
        ed.minWidth = 60.pointsToPixels;
        ed.layoutWidth = FILL_PARENT;
        Setting setting = settings.settingByPath(_id, SettingType.INTEGER);
        int n = cast(int)setting.integerDef(_defaultValue);
        if (_minValue != int.max && n < _minValue)
            n = _minValue;
        if (_maxValue != int.max && n > _maxValue)
            n = _maxValue;
        setting.integer = cast(long)n;
        ed.text = toUTF32(to!string(n));
        ed.contentChange = delegate(EditableContent content) {
            long v = parseLong(toUTF8(content.text), long.max);
            if (v != long.max) {
                if ((_minValue == int.max || v >= _minValue) && (_maxValue == int.max || v <= _maxValue)) {
                    setting.integer = v;
                    ed.textColor = 0x000000;
                } else {
                    ed.textColor = 0xFF0000;
                }
            }
        };
        return [lbl, ed];
    }
}

class StringEditItem : SettingsItem {
    string _defaultValue;
    this(string id, UIString label, string defaultValue) {
        super(id, label);
        _defaultValue = defaultValue;
    }
    /// create setting widget
    override Widget[] createWidgets(Setting settings) {
        TextWidget lbl = new TextWidget(_id ~ "-label", _label);
        EditLine ed = new EditLine(_id ~ "-edit");
        ed.minWidth = 60.pointsToPixels;
        ed.layoutWidth = FILL_PARENT;
        Setting setting = settings.settingByPath(_id, SettingType.STRING);
        string value = setting.strDef(_defaultValue);
        setting.str = value;
        ed.text = toUTF32(value);
        ed.contentChange = delegate(EditableContent content) {
            string value = toUTF8(content.text);
            setting.str = value;
        };
        return [lbl, ed];
    }
}

class FileNameEditItem : SettingsItem {
    string _defaultValue;
    this(string id, UIString label, string defaultValue) {
        super(id, label);
        _defaultValue = defaultValue;
    }
    /// create setting widget
    override Widget[] createWidgets(Setting settings) {
        import dlangui.dialogs.filedlg;
        TextWidget lbl = new TextWidget(_id ~ "-label", _label);
        FileNameEditLine ed = new FileNameEditLine(_id ~ "-filename-edit");
        ed.minWidth = 60.pointsToPixels;
        Setting setting = settings.settingByPath(_id, SettingType.STRING);
        string value = setting.strDef(_defaultValue);
        setting.str = value;
        ed.text = toUTF32(value);
        ed.contentChange = delegate(EditableContent content) {
            string value = toUTF8(content.text);
            setting.str = value;
        };
        return [lbl, ed];
    }
}

class ExecutableFileNameEditItem : SettingsItem {
    string _defaultValue;
    this(string id, UIString label, string defaultValue) {
        super(id, label);
        _defaultValue = defaultValue;
    }
    /// create setting widget
    override Widget[] createWidgets(Setting settings) {
        import dlangui.dialogs.filedlg;
        TextWidget lbl = new TextWidget(_id ~ "-label", _label);
        FileNameEditLine ed = new FileNameEditLine(_id ~ "-filename-edit");
        ed.addFilter(FileFilterEntry(UIString.fromId("MESSAGE_EXECUTABLES"c), "*.exe", true));
        ed.minWidth = 60.pointsToPixels;
        ed.layoutWidth = FILL_PARENT;
        Setting setting = settings.settingByPath(_id, SettingType.STRING);
        string value = setting.strDef(_defaultValue);
        setting.str = value;
        ed.text = toUTF32(value);
        ed.contentChange = delegate(EditableContent content) {
            string value = toUTF8(content.text);
            setting.str = value;
        };
        return [lbl, ed];
    }
}

class PathNameEditItem : SettingsItem {
    string _defaultValue;
    this(string id, UIString label, string defaultValue) {
        super(id, label);
        _defaultValue = defaultValue;
    }
    /// create setting widget
    override Widget[] createWidgets(Setting settings) {
        import dlangui.dialogs.filedlg;
        TextWidget lbl = new TextWidget(_id ~ "-label", _label);
        DirEditLine ed = new DirEditLine(_id ~ "-path-edit");
        ed.addFilter(FileFilterEntry(UIString.fromId("MESSAGE_ALL_FILES"c), "*.*"));
        ed.minWidth = 60.pointsToPixels;
        ed.layoutWidth = FILL_PARENT;
        Setting setting = settings.settingByPath(_id, SettingType.STRING);
        string value = setting.strDef(_defaultValue);
        setting.str = value;
        ed.text = toUTF32(value);
        ed.contentChange = delegate(EditableContent content) {
            string value = toUTF8(content.text);
            setting.str = value;
        };
        return [lbl, ed];
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

    /// add EditLine to edit number
    NumberEditItem addNumberEdit(string id, UIString label, int minValue = int.max, int maxValue = int.max, int defaultValue = 0) {
        NumberEditItem res = new NumberEditItem(id, label, minValue, maxValue, defaultValue);
        addItem(res);
        return res;
    }

    /// add EditLine to edit string
    StringEditItem addStringEdit(string id, UIString label, string defaultValue = "") {
        StringEditItem res = new StringEditItem(id, label, defaultValue);
        addItem(res);
        return res;
    }

    /// add EditLine to edit filename
    FileNameEditItem addFileNameEdit(string id, UIString label, string defaultValue = "") {
        FileNameEditItem res = new FileNameEditItem(id, label, defaultValue);
        addItem(res);
        return res;
    }

    /// add EditLine to edit filename
    PathNameEditItem addDirNameEdit(string id, UIString label, string defaultValue = "") {
        PathNameEditItem res = new PathNameEditItem(id, label, defaultValue);
        addItem(res);
        return res;
    }

    /// add EditLine to edit executable file name
    ExecutableFileNameEditItem addExecutableFileNameEdit(string id, UIString label, string defaultValue = "") {
        ExecutableFileNameEditItem res = new ExecutableFileNameEditItem(id, label, defaultValue);
        addItem(res);
        return res;
    }

    StringComboBoxItem addStringComboBox(string id, UIString label, StringListValue[] items) {
        StringComboBoxItem res = new StringComboBoxItem(id, label, items);
        addItem(res);
        return res;
    }

    IntComboBoxItem addIntComboBox(string id, UIString label, StringListValue[] items) {
        IntComboBoxItem res = new IntComboBoxItem(id, label, items);
        addItem(res);
        return res;
    }

    FloatComboBoxItem addFloatComboBox(string id, UIString label, StringListValue[] items, long divider = 1000) {
        FloatComboBoxItem res = new FloatComboBoxItem(id, label, items, divider);
        addItem(res);
        return res;
    }

    /// create page widget (default implementation creates empty page)
    Widget createWidget(Setting settings) {
        VerticalLayout res = new VerticalLayout(_id);
        res.minWidth(80.pointsToPixels).minHeight(200.pointsToPixels).layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT);
        if (itemCount > 0) {
            TextWidget caption = new TextWidget("prop-body-caption-" ~ _id, _label);
            caption.styleId = STYLE_SETTINGS_PAGE_TITLE;
            caption.layoutWidth(FILL_PARENT);
            res.addChild(caption);
            TableLayout tbl = null;
            for (int i = 0; i < itemCount; i++) {
                SettingsItem v = item(i);
                Widget[] w = v.createWidgets(settings);
                if (w.length == 1) {
                    tbl = null;
                    res.addChild(w[0]);
                } else if (w.length == 2) {
                    if (!tbl) {
                        tbl = new TableLayout();
                        tbl.layoutWidth = FILL_PARENT;
                        tbl.colCount = 2;
                        res.addChild(tbl);
                    }
                    tbl.addChild(w[0]);
                    tbl.addChild(w[1]);
                }

            }
        }
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

    this(UIString caption, Window parent, Setting settings, SettingsPage layout, bool popup = ((Platform.instance.uiDialogDisplayMode() & DialogDisplayMode.settingsDialogInPopup) == DialogDisplayMode.settingsDialogInPopup)) {
        super(caption, parent, DialogFlag.Modal | DialogFlag.Resizable | (popup?DialogFlag.Popup:0));
        _settings = settings;
        _layout = layout;
    }

    void onTreeItemSelected(TreeItems source, TreeItem selectedItem, bool activated) {
        if (!selectedItem)
            return;
        _frame.showChild(selectedItem.id);
    }

    void createControls(SettingsPage page, TreeItem base) {
        TreeItem item = base;
        if (!page.isRoot) {
            item = page.createTreeItem();
            base.addChild(item);
            Widget widget = page.createWidget(_settings);
            _frame.addChild(widget);
        }
        if (page.childCount > 0) {
            for (int i = 0; i < page.childCount; i++) {
                createControls(page.child(i), item);
            }
        }
    }

    /// override to implement creation of dialog controls
    override void initialize() {
        import dlangui.widgets.scroll;
        minWidth(150.pointsToPixels).minHeight(150.pointsToPixels);
        layoutHeight(FILL_PARENT).layoutHeight(FILL_PARENT);
        _tree = new TreeWidget("prop_tree", ScrollBarMode.Auto, ScrollBarMode.Auto);
        _tree.styleId = STYLE_SETTINGS_TREE;
        _tree.layoutHeight(FILL_PARENT).layoutHeight(FILL_PARENT).minHeight(200.pointsToPixels).minWidth(50.pointsToPixels);
        _tree.selectionChange = &onTreeItemSelected;
        _tree.fontSize = 16;
        _frame = new FrameLayout("prop_pages");
        _frame.styleId = STYLE_SETTINGS_PAGES;
        _frame.layoutHeight(FILL_PARENT).layoutHeight(FILL_PARENT).minHeight(200.pointsToPixels).minWidth(100.pointsToPixels);
        createControls(_layout, _tree.items);
        HorizontalLayout content = new HorizontalLayout("settings_dlg_content");
        content.addChild(_tree);
        content.addChild(_frame);
        content.layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT);
        addChild(content);
        addChild(createButtonsPanel([ACTION_APPLY, ACTION_CANCEL], 0, 0));
        if (_layout.childCount > 0)
            _tree.selectItem(_layout.child(0).id);
    }

}
