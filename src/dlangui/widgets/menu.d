module dlangui.widgets.menu;

import dlangui.core.events;
import dlangui.widgets.controls;
import dlangui.widgets.layouts;
import dlangui.widgets.lists;
import dlangui.widgets.popup;

/// menu item properties
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

/// widget to draw menu item
class MenuItemWidget : HorizontalLayout {
    protected MenuItem _item;
    protected TextWidget _label;
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

/// base class for menus
class MenuWidgetBase : ListWidget {
	protected MenuWidgetBase _parentMenu;
    protected MenuItem _item;
	protected PopupMenu _openedMenu;
	protected PopupWidget _openedPopup;
	protected bool delegate(MenuItem item) _onMenuItemClickListener;
    /// menu item click listener
	@property bool delegate(MenuItem item) onMenuItemListener() { return  _onMenuItemClickListener; }
    /// menu item click listener
	@property MenuWidgetBase onMenuItemListener(bool delegate(MenuItem item) listener) { _onMenuItemClickListener = listener; return this; }

    this(MenuWidgetBase parentMenu, MenuItem item, Orientation orientation) {
		_parentMenu = parentMenu;
        _item = item;
		this.orientation = orientation;
        id = "popup_menu";
        styleId = "POPUP_MENU";
        WidgetListAdapter adapter = new WidgetListAdapter();
        for (int i=0; i < _item.subitemCount; i++) {
            MenuItem subitem = _item.subitem(i);
            MenuItemWidget widget = new MenuItemWidget(subitem);
			if (orientation == Orientation.Horizontal)
				widget.styleId = "MAIN_MENU_ITEM";
            adapter.widgets.add(widget);
        }
        ownAdapter = adapter;
    }

	protected void openSubmenu(MenuItemWidget itemWidget) {
		if (_openedPopup !is null)
			_openedPopup.close();
		PopupMenu popupMenu = new PopupMenu(itemWidget.item, this);
		PopupWidget popup = window.showPopup(popupMenu, itemWidget, PopupAlign.Below);
		_openedPopup = popup;
		_openedMenu = popupMenu;
	}

	/// override to handle change of selection
	override protected void selectionChanged(int index, int previouslySelectedItem = -1) {
		MenuItemWidget itemWidget = index >= 0 ? cast(MenuItemWidget)_adapter.itemWidget(index) : null;
		if (itemWidget !is null) {
			if (itemWidget.item.isSubmenu()) {
				if (_selectOnHover) {
					openSubmenu(itemWidget);
				}
			} else {
				// normal item
			}
		}
	}

	protected void onMenuItem(MenuItem item) {
		if (_openedPopup !is null) {
			_openedPopup.close();
			_openedPopup = null;
		}
		if (_parentMenu !is null)
			_parentMenu.onMenuItem(item);
		else {
			// top level handling
			Log.d("onMenuItem ", item.id);
			selectItem(-1);
			selectOnHover = false;
			bool delegate(MenuItem item) listener = _onMenuItemClickListener;
			PopupWidget popup = cast(PopupWidget)parent;
			if (popup)
				popup.close();
			// this pointer now can be invalid - if popup removed
			if (listener !is null)
				listener(item);
		}
	}

	/// override to handle mouse up on item
	override protected void itemClicked(int index) {
		MenuItemWidget itemWidget = index >= 0 ? cast(MenuItemWidget)_adapter.itemWidget(index) : null;
		if (itemWidget !is null) {
			Log.d("Menu Item clicked ", itemWidget.item.action.id);
			if (itemWidget.item.isSubmenu()) {
				// submenu clicked
				if (_clickOnButtonDown && _openedPopup !is null && _openedMenu._item is itemWidget.item) {
					// second click on main menu opened item
					_openedPopup.close();
					_openedPopup = null;
					selectItem(-1);
					selectOnHover = false;
				} else {
					openSubmenu(itemWidget);
					selectOnHover = true;
				}
			} else {
				// normal item
				onMenuItem(itemWidget.item);
			}
		}
	}
}

/// main menu (horizontal)
class MainMenu : MenuWidgetBase {

    this(MenuItem item) {
		super(null, item, Orientation.Horizontal);
        id = "MAIN_MENU";
        styleId = "MAIN_MENU";
		_clickOnButtonDown = true;
    }
}

/// popup menu widget (vertical layout of items)
class PopupMenu : MenuWidgetBase {

    this(MenuItem item, MenuWidgetBase parentMenu = null) {
		super(parentMenu, item, Orientation.Vertical);
        id = "POPUP_MENU";
        styleId = "POPUP_MENU";
		selectOnHover = true;
    }
}
