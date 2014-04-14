module dlangui.widgets.menu;

import dlangui.core.events;
import dlangui.widgets.controls;
import dlangui.widgets.layouts;
import dlangui.widgets.lists;

class MenuItem {
    protected bool _checkable;
    protected bool _checked;
    protected bool _enabled;
    protected Action _action;
    protected MenuItem[] _subitems;
    /// item action id, 0 if no action
    @property int id() { return _action is null ? 0 : _action.id; }
    /// returns count of submenu items
    @property int subitemCount() {
        return cast(int)_subitems.length;
    }
    /// returns submenu item by index
    MenuItem subitem(int index) {
        return _subitems[index];
    }
    /// adds submenu item
    MenuItem add(MenuItem subitem) {
        _subitems ~= subitem;
        return this;
    }
    /// adds submenu item from action
    MenuItem add(Action subitemAction) {
        _subitems ~= new MenuItem(subitemAction);
        return this;
    }
    /// returns true if item is submenu (contains subitems)
    @property bool isSubmenu() {
        return _subitems.length > 0;
    }
    /// returns item label
    @property UIString label() {
        return _action.labelValue;
    }
    /// returns item action
    @property const(Action) action() const { return _action; }
    /// sets item action
    @property MenuItem action(Action a) { _action = a; return this; }
    this() {
        _enabled = true;
    }
    this(Action action) {
        _action = action;
        _enabled = true;
    }
    ~this() {
        // TODO
    }
}

class MenuItemWidget : HorizontalLayout {
    protected MenuItem _item;
    protected TextWidget _label;
    this(MenuItem item) {
        id="menuitem";
        _item = item;
        styleId = "MENU_ITEM";
        _label = new TextWidget("MENU_LABEL");
        _label.text = _item.label;
        addChild(_label);
        trackHover = true;
    }
}

class MainMenu : HorizontalLayout {
    protected MenuItem _item;
    protected bool onItemClick(Widget w) {
        Log.d("onItemClick ", w.id);
        return true;
    }
    this(MenuItem item) {
        id = "MAIN_MENU";
        styleId = "MAIN_MENU";
        _item = item;
        for (int i = 0; i < item.subitemCount; i++) {
			MenuItemWidget subitem = new MenuItemWidget(item.subitem(i));
            subitem.onClickListener = &onItemClick;
            addChild(subitem);
        }
        addChild((new Widget()).layoutWidth(FILL_PARENT));
    }
}

class PopupMenu : ListWidget {
    protected MenuItem _item;
    this(MenuItem item) {
        id = "popup_menu";
        styleId = "POPUP_MENU";
        _item = item;
        WidgetListAdapter adapter = new WidgetListAdapter();
        for (int i=0; i < _item.subitemCount; i++) {
            MenuItem subitem = _item.subitem(i);
            MenuItemWidget widget = new MenuItemWidget(subitem);
            adapter.widgets.add(widget);
        }
        ownAdapter = adapter;
    }
}
