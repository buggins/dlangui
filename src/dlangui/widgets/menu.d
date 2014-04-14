module dlangui.widgets.menu;

import dlangui.core.events;
import dlangui.widgets.controls;
import dlangui.widgets.layouts;

class MenuItem {
    bool _checkable;
    bool _checked;
    bool _enabled;
    protected Action _action;
    MenuItem[] _subitems;
    @property int subitemCount() {
        return cast(int)_subitems.length;
    }
    MenuItem subitem(int index) {
        return _subitems[index];
    }
    MenuItem add(MenuItem subitem) {
        _subitems ~= subitem;
        return this;
    }
    MenuItem add(Action subitemAction) {
        _subitems ~= new MenuItem(subitemAction);
        return this;
    }
    @property bool isSubmenu() {
        return _subitems.length > 0;
    }
    @property UIString label() {
        return _action.labelValue;
    }
    @property const(Action) action() const { return _action; }
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
        _item = item;
        styleId = "MENU_ITEM";
        _label = new TextWidget("MENU_LABEL");
        _label.text = _item.label;
        addChild(_label);
        trackHover = true;
    }
}

class MainMenu : HorizontalLayout {
    MenuItem _item;
    this(MenuItem item) {
        id = "MAIN_MENU";
        styleId = "MAIN_MENU";
        _item = item;
        for (int i = 0; i < item.subitemCount; i++) {
			MenuItemWidget subitem = new MenuItemWidget(item.subitem(i));
			if (i == 1)
				subitem.setState(State.Focused);
			else if (i == 2)
				subitem.setState(State.Pressed);
            addChild(subitem);
			
        }
        addChild((new Widget()).layoutWidth(FILL_PARENT));
    }
}
