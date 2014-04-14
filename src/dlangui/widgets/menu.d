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

    /// process mouse event; return true if event is processed by widget.
    override bool onMouseEvent(MouseEvent event) {
        Log.d("onMouseEvent ", id, " ", event.action, "  (", event.x, ",", event.y, ")");
		// support onClick
		if (_handler !is null) {
	        if (event.action == MouseAction.ButtonDown && event.button == MouseButton.Left) {
	            setState(State.Pressed);
                _handler.onItemMouseDown(this, event);
	            return true;
	        }
	        if (event.action == MouseAction.ButtonUp && event.button == MouseButton.Left) {
	            resetState(State.Pressed);
                _handler.onItemMouseDown(this, event);
	            return true;
	        }
            /*
	        if (event.action == MouseAction.ButtonUp && event.button == MouseButton.Left) {
	            resetState(State.Pressed);
				_onClickListener(this);
	            return true;
	        }
	        if (event.action == MouseAction.FocusOut || event.action == MouseAction.Cancel) {
	            resetState(State.Pressed);
	            resetState(State.Hovered);
	            return true;
	        }
	        if (event.action == MouseAction.FocusIn) {
	            setState(State.Pressed);
	            return true;
	        }
            */
		}
        return super.onMouseEvent(event);
    }

}

class MainMenu : HorizontalLayout, MenuItemWidgetHandler {
    protected MenuItem _item;

    override protected bool onItemMouseDown(MenuItemWidget itemWidget, MouseEvent ev) {
        PopupMenu popupMenu = new PopupMenu(itemWidget.item);
        PopupWidget popup = window.showPopup(popupMenu, itemWidget, PopupAlign.Below);
        ev.track(popupMenu);
        return true;
    }
    override protected bool onItemMouseUp(MenuItemWidget itemWidget, MouseEvent ev) {
        return true;
    }

    /*
    protected bool onItemClick(Widget w) {
        MenuItemWidget itemWidget = cast(MenuItemWidget)w;
        Log.d("onItemClick ", w.id);
        window.showPopup(new PopupMenu(itemWidget.item), itemWidget, PopupAlign.Below);
        return true;
    }
    */
    this(MenuItem item) {
        id = "MAIN_MENU";
        styleId = "MAIN_MENU";
        _item = item;
        for (int i = 0; i < item.subitemCount; i++) {
			MenuItemWidget subitem = new MenuItemWidget(item.subitem(i));
            //subitem.onClickListener = &onItemClick;
            subitem.handler = this;
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
