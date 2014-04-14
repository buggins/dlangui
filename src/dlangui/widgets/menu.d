module dlangui.widgets.menu;

import dlangui.core.events;
import dlangui.widgets.controls;
import dlangui.widgets.layouts;
import dlangui.widgets.lists;
import dlangui.widgets.popup;

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

interface MenuItemWidgetHandler {
    bool onItemMouseDown(MenuItemWidget itemWidget, MouseEvent ev);
    bool onItemMouseUp(MenuItemWidget itemWidget, MouseEvent ev);
}

class MenuItemWidget : HorizontalLayout {
    protected MenuItem _item;
    protected TextWidget _label;
    protected MenuItemWidgetHandler _handler;
    @property MenuItemWidgetHandler handler() { return _handler; }
    @property MenuItemWidget handler(MenuItemWidgetHandler h) { _handler = h; return this; }
    @property MenuItem item() { return _item; }
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

class MenuWidgetBase : ListWidget {
    protected MenuItem _item;
	protected PopupMenu _openedMenu;
	protected PopupWidget _openedPopup;

    this(MenuItem item, Orientation orientation) {
        _item = item;
		this.orientation = orientation;
        id = "popup_menu";
        styleId = "POPUP_MENU";
        WidgetListAdapter adapter = new WidgetListAdapter();
        for (int i=0; i < _item.subitemCount; i++) {
            MenuItem subitem = _item.subitem(i);
            MenuItemWidget widget = new MenuItemWidget(subitem);
            //widget.handler = this;
            adapter.widgets.add(widget);
        }
        ownAdapter = adapter;
    }

	/// override to handle change of selection
	override protected void selectionChanged(int index, int previouslySelectedItem = -1, MouseEvent event = null) {
		MenuItemWidget itemWidget = index >= 0 ? cast(MenuItemWidget)_adapter.itemWidget(index) : null;
        if (itemWidget.item.isSubmenu()) {
			if (_openedPopup !is null)
				_openedPopup.close();
            PopupMenu popupMenu = new PopupMenu(itemWidget.item);
            PopupWidget popup = window.showPopup(popupMenu, itemWidget, PopupAlign.Below);
			if (event !is null && (event.flags & (MouseFlag.LButton || MouseFlag.RButton)))
				event.track(popupMenu);
			_openedPopup = popup;
			_openedMenu = popupMenu;
			selectOnHover = true;
        } else {
            // normal item
        }
	}

}

class MainMenu : MenuWidgetBase {

    this(MenuItem item) {
		super(item, Orientation.Horizontal);
        id = "MAIN_MENU";
        styleId = "MAIN_MENU";
    }
}

class PopupMenu : MenuWidgetBase {

    this(MenuItem item) {
		super(item, Orientation.Vertical);
        id = "POPUP_MENU";
        styleId = "POPUP_MENU";
		selectOnHover = true;
    }
}

