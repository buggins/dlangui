// Written in the D programming language.

/**
This module contains menu widgets implementation.

MenuItem - menu item properties container - to hold hierarchy of menu.
MainMenu - main menu widget
PopupMenu - popup menu widget

Synopsis:

----
import dlangui.widgets.popup;

----

Copyright: Vadim Lopatin, 2014
License:   Boost License 1.0
Authors:   Vadim Lopatin, coolreader.org@gmail.com
*/
module dlangui.widgets.menu;

import dlangui.core.events;
import dlangui.widgets.controls;
import dlangui.widgets.layouts;
import dlangui.widgets.lists;
import dlangui.widgets.popup;

// define DebugMenus for menu debug messages
//debug = DebugMenus;

/// menu item type
enum MenuItemType {
    /// normal menu item
    Normal,
    /// menu item - checkbox
    Check,
    /// menu item - radio button
    Radio,
    /// menu separator (horizontal line)
    Separator,
    /// submenu - contains child items
    Submenu
}

/// interface to handle menu item click
interface MenuItemClickHandler {
    bool onMenuItemClick(MenuItem item);
}

/// interface to handle menu item action
interface MenuItemActionHandler {
    bool onMenuItemAction(const Action action);
}


/// menu item properties
class MenuItem {
    protected bool _checked;
    protected bool _enabled;
    protected MenuItemType _type = MenuItemType.Normal;
    protected Action _action;
    protected MenuItem[] _subitems;
    protected MenuItem _parent;
    /// handle menu item click (parameter is MenuItem)
    Signal!MenuItemClickHandler menuItemClick;
    /// handle menu item click action (parameter is Action)
    Signal!MenuItemActionHandler menuItemAction;
    /// item action id, 0 if no action
    @property int id() const { return _action is null ? 0 : _action.id; }
    /// returns count of submenu items
    @property int subitemCount() {
        return cast(int)_subitems.length;
    }
    /// returns subitem index for item, -1 if item is not direct subitem of this
    @property int subitemIndex(MenuItem item) {
        for (int i = 0; i < _subitems.length; i++)
            if (_subitems[i] is item)
                return i;
        return -1;
    }
    /// returns submenu item by index
    MenuItem subitem(int index) {
        return _subitems[index];
    }

    /// map key to action
    Action findKeyAction(uint keyCode, uint flags) {
        if (_action) {
            if (_action.checkAccelerator(keyCode, flags))
                return _action;
        }
        for (int i = 0; i < subitemCount; i++) {
            Action a = subitem(i).findKeyAction(keyCode, flags);
            if (a)
                return a;
        }
        return null;
    }

    @property MenuItemType type() const {
        if (id == SEPARATOR_ACTION_ID)
            return MenuItemType.Separator;
        if (_subitems.length > 0) // if there are children, force type to Submenu
            return MenuItemType.Submenu;
        return _type;
    }

    /// set new MenuItemType
    @property MenuItem type(MenuItemType type) {
        _type = type;
        return this;
    }

    /// get check for checkbox or radio button item
    @property bool checked() {
        //if (_checked) {
        //    Log.d("Menu item is checked");
        //    return true;
        //}
        return _checked;
    }
    /// check radio button with specified index, uncheck other radio buttons in group (group consists of sequence of radio button items; other item type - end of group)
    protected void checkRadioButton(int index) {
        // find bounds of group
        int start = index;
        int end = index;
        for (; start > 0 && _subitems[start - 1].type == MenuItemType.Radio; start--) {
            // do nothing
        }
        for (; end < _subitems.length - 1 && _subitems[end + 1].type == MenuItemType.Radio; end++) {
            // do nothing
        }
        // check item with specified index, uncheck others
        for (int i = start; i <= end; i++)
            _subitems[i]._checked = (i == index);
    }
    /// set check for checkbox or radio button item
    @property MenuItem checked(bool flg) {
        if (_checked == flg)
            return this;
        if (_action)
            _action.checked = flg;
        _checked = flg;
        if (flg && _parent && type == MenuItemType.Radio) {
            int index = _parent.subitemIndex(this);
            if (index >= 0) {
                _parent.checkRadioButton(index);
            }
        }
        return this;
    }

    /// get hotkey character from label (e.g. 'F' for item labeled "&File"), 0 if no hotkey
    dchar getHotkey() {
        static import std.uni;
        dstring s = label;
        if (s.length < 2)
            return 0;
        dchar ch = 0;
        for (int i = 0; i < s.length - 1; i++) {
            if (s[i] == '&') {
                ch = s[i + 1];
                break;
            }
        }
        return std.uni.toUpper(ch);
    }

    /// find subitem by hotkey character, returns subitem index, -1 if not found
    int findSubitemByHotkey(dchar ch) {
        static import std.uni;
        if (!ch)
            return -1;
        ch = std.uni.toUpper(ch);
        for (int i = 0; i < _subitems.length; i++) {
            if (_subitems[i].getHotkey() == ch)
                return i;
        }
        return -1;
    }

    /// find subitem by hotkey character, returns subitem index, -1 if not found
    MenuItem findSubitemByHotkeyRecursive(dchar ch) {
        static import std.uni;
        if (!ch)
            return null;
        ch = std.uni.toUpper(ch);
        for (int i = 0; i < _subitems.length; i++) {
            if (_subitems[i].getHotkey() == ch)
                return _subitems[i];
        }
        for (int i = 0; i < _subitems.length; i++) {
            MenuItem res = _subitems[i].findSubitemByHotkeyRecursive(ch);
            if (res)
                return res;
        }
        return null;
    }

    /// Add separator item
    MenuItem addSeparator() {
        return add(new Action(SEPARATOR_ACTION_ID));
    }

    /// adds submenu item
    MenuItem add(MenuItem subitem) {
        _subitems ~= subitem;
        subitem._parent = this;
        return this;
    }
    /// adds submenu checkbox item
    MenuItem addCheck(const Action a) {
        MenuItem res = new MenuItem(a);
        res.type = MenuItemType.Check;
        add(res);
        return this;
    }
    /// adds submenu item(s) from one or more actions (will return item for last action)
    MenuItem add(Action[] subitemActions...) {
        MenuItem res = null;
        foreach(subitemAction; subitemActions) {
            res = add(new MenuItem(subitemAction));
        }
        return res;
    }
    /// adds submenu item(s) from one or more actions (will return item for last action)
    MenuItem add(const Action[] subitemActions...) {
        MenuItem res = null;
        foreach(subitemAction; subitemActions) {
            res = add(new MenuItem(subitemAction));
        }
        return res;
    }
    /// removes all subitems
    void clear() {
        foreach(ref item; _subitems)
            item = null;
        _subitems.length = 0;
    }
    /// returns text description for first accelerator of action; null if no accelerators
    @property dstring acceleratorText() {
        if (!_action)
            return null;
        return _action.acceleratorText;
    }
    /// returns true if item is submenu (contains subitems)
    @property bool isSubmenu() {
        return _subitems.length > 0;
    }
    /// returns item label
    @property UIString label() {
        return _action !is null ? _action.labelValue : UIString("", null);
    }
    /// returns item action
    @property const(Action) action() const { return _action; }
    /// sets item action
    @property MenuItem action(Action a) { _action = a; return this; }

    /// menu item Enabled flag
    @property bool enabled() { return _enabled && type != MenuItemType.Separator; }
    /// menu item Enabled flag
    @property MenuItem enabled(bool enabled) {
        _enabled = enabled;
        return this;
    }

    /// handle menu item click
    Signal!(void, MenuItem) onMenuItem;
    /// prepare for opening of submenu, return true if opening is allowed
    Signal!(bool, MenuItem) openingSubmenu;

    /// call to update state for action (if action is assigned for widget)
    void updateActionState(Widget w) {
        //import dlangui.widgets.editors;
        if (_action) {
            //if (_action.id == EditorActions.Copy) {
            //    Log.d("Requesting Copy action. Old state: ", _action.state);
            //}
            bool actionStateProcessed = w.updateActionState(_action, true, false);
            _enabled = _action.state.enabled;
            if (actionStateProcessed)
                _checked = _action.state.checked;
        }
        for (int i = 0; i < _subitems.length; i++) {
            _subitems[i].updateActionState(w);
        }
    }

    this() {
        _enabled = true;
    }
    this(Action action) {
        _action = action;
        _enabled = true;
    }
    this(const Action action) {
        _action = action.clone;
        _enabled = true;
    }
    ~this() {
        // TODO
    }
}

/// widget to draw menu item
class MenuItemWidget : WidgetGroupDefaultDrawing {
    protected bool _mainMenu;
    protected MenuItem _item;
    protected ImageWidget _icon;
    protected TextWidget _accel;
    protected TextWidget _label;
    protected int _labelWidth;
    protected int _iconWidth;
    protected int _accelWidth;
    protected int _height;
    @property MenuItem item() { return _item; }
    void setSubitemSizes(int maxLabelWidth, int maxHeight, int maxIconWidth, int maxAccelWidth) {
        _labelWidth = maxLabelWidth;
        _height = maxHeight;
        _iconWidth = maxIconWidth;
        _accelWidth = maxAccelWidth;
    }
    void measureSubitems(ref int maxLabelWidth, ref int maxHeight, ref int maxIconWidth, ref int maxAccelWidth) {
        if (_item.type == MenuItemType.Separator)
            return;
        _label.measure(SIZE_UNSPECIFIED, SIZE_UNSPECIFIED);
        if (maxLabelWidth < _label.measuredWidth)
            maxLabelWidth = _label.measuredWidth;
        if (maxHeight < _label.measuredHeight)
            maxHeight = _label.measuredHeight;
        if (_icon) {
            _icon.measure(SIZE_UNSPECIFIED, SIZE_UNSPECIFIED);
            if (maxIconWidth < _icon.measuredWidth)
                maxIconWidth = _icon.measuredWidth;
            if (maxHeight < _icon.measuredHeight)
                maxHeight = _icon.measuredHeight;
        }
        if (_accel) {
            _accel.measure(SIZE_UNSPECIFIED, SIZE_UNSPECIFIED);
            if (maxAccelWidth < _accel.measuredWidth)
                maxAccelWidth = _accel.measuredWidth;
            if (maxHeight < _accel.measuredHeight)
                maxHeight = _accel.measuredHeight;
        }
    }
    /// Measure widget according to desired width and height constraints. (Step 1 of two phase layout).
    override void measure(int parentWidth, int parentHeight) {
        updateState();
        Rect m = margins;
        Rect p = padding;
        if (_item.type == MenuItemType.Separator) {
            measuredContent(parentWidth, parentHeight, 1, 1); // for vertical (popup menu)
            return;
        }
        // calc size constraints for children
        int pwidth = parentWidth;
        int pheight = parentHeight;
        if (parentWidth != SIZE_UNSPECIFIED)
            pwidth -= m.left + m.right + p.left + p.right;
        if (parentHeight != SIZE_UNSPECIFIED)
            pheight -= m.top + m.bottom + p.top + p.bottom;
        if (_labelWidth)
            measuredContent(parentWidth, parentHeight, _iconWidth + _labelWidth + _accelWidth, _height); // for vertical (popup menu)
        else {
            _label.measure(pwidth, pheight);
            measuredContent(parentWidth, parentHeight, _label.measuredWidth, _label.measuredHeight); // for horizonral (main) menu
        }
    }

    /// Set widget rectangle to specified value and layout widget contents. (Step 2 of two phase layout).
    override void layout(Rect rc) {
        _needLayout = false;
        if (visibility == Visibility.Gone) {
            return;
        }
        _pos = rc;
        if (_item.type == MenuItemType.Separator)
            return;

        applyMargins(rc);
        applyPadding(rc);
        Rect labelRc = rc;
        Rect iconRc = rc;
        Rect accelRc = rc;
        iconRc.right = iconRc.left + _iconWidth;
        accelRc.left = accelRc.right - _accelWidth;
        labelRc.left += _iconWidth;
        labelRc.right -= _accelWidth;
        if (_icon)
            _icon.layout(iconRc);
        if (_accel)
            _accel.layout(accelRc);
        _label.layout(labelRc);
    }

    protected void updateState() {
        if (_item.enabled)
            setState(State.Enabled);
        else
            resetState(State.Enabled);
        if (_item.checked)
            setState(State.Checked);
        else
            resetState(State.Checked);
    }

    ///// call to update state for action (if action is assigned for widget)
    //override void updateActionState(bool force = false) {
    //    if (!_item.action)
    //        return;
    //    super.updateActionState(_item._action, force);
    //    _item.enabled = _item._action.state.enabled;
    //    _item.checked = _item._action.state.checked;
    //    updateState();
    //}

    this(MenuItem item, bool mainMenu) {
        id="menuitem";
        _mainMenu = mainMenu;
        _item = item;
        updateState();
        if (_item.type == MenuItemType.Separator) {
            styleId = "MENU_SEPARATOR";
            trackHover = false;
            clickable = false;
        } else {
            styleId = STYLE_MENU_ITEM;
            string iconId = _item.action !is null ? _item.action.iconId : "";
            if (_item.type == MenuItemType.Check)
                iconId = "btn_check";
            else if (_item.type == MenuItemType.Radio)
                iconId = "btn_radio";
            // icon
            if (_item.action && iconId.length) {
                _icon = new ImageWidget("MENU_ICON", iconId);
                _icon.styleId = STYLE_MENU_ICON;
                _icon.state = State.Parent;
                addChild(_icon);
            }
            // label
            _label = new TextWidget("MENU_LABEL");
            _label.text = _item.label;
            _label.styleId = _mainMenu ? "MAIN_MENU_LABEL" : "MENU_LABEL";
            _label.state = State.Parent;
            addChild(_label);
            // accelerator
            dstring acc = _item.acceleratorText;
            if (_item.isSubmenu && !mainMenu) {
                version (Windows) {
                    acc = ">"d;
                    //acc = "►"d;
                } else {
                    acc = "‣"d;
                }
            }
            if (acc !is null) {
                _accel = new TextWidget("MENU_ACCEL");
                _accel.styleId = STYLE_MENU_ACCEL;
                _accel.text = acc;
                _accel.state = State.Parent;
                if (_item.isSubmenu && !mainMenu)
                    _accel.alignment = Align.Right | Align.VCenter;
                addChild(_accel);
            }
            trackHover = true;
            clickable = true;
        }
    }
}

class SeparatorMenuItemWidget : MenuItemWidget {
    this(MenuItem item, bool mainMenu) {
        super(item, mainMenu);
        id="menuseparator";
    }
}

/// base class for menus
class MenuWidgetBase : ListWidget {
    protected MenuWidgetBase _parentMenu;
    protected MenuItem _item;
    protected PopupMenu _openedMenu;
    protected PopupWidget _openedPopup;
    protected int _openedPopupIndex;

    /// menu item click listener
    Signal!MenuItemClickHandler menuItemClick;
    /// menu item action listener
    Signal!MenuItemActionHandler menuItemAction;

    this(MenuWidgetBase parentMenu, MenuItem item, Orientation orientation) {
        _parentMenu = parentMenu;
        this.orientation = orientation;
        id = "popup_menu";
        styleId = STYLE_POPUP_MENU;
        menuItems = item;
    }

    /// handle theme change: e.g. reload some themed resources
    override void onThemeChanged() {
        super.onThemeChanged();
        if (_openedMenu)
            _openedMenu.onThemeChanged();
        if (_openedPopup)
            _openedPopup.onThemeChanged();
    }

    @property void menuItems(MenuItem item) {
        if (_item) {
            destroy(_item);
            _item = null;
        }
        _item = item;
        WidgetListAdapter adapter = new WidgetListAdapter();
        if (item) {
            for (int i=0; i < _item.subitemCount; i++) {
                MenuItem subitem = _item.subitem(i);
                MenuItemWidget widget = new MenuItemWidget(subitem, orientation == Orientation.Horizontal);
                if (orientation == Orientation.Horizontal)
                    widget.styleId = STYLE_MAIN_MENU_ITEM;
                widget.parent = this;
                adapter.add(widget);
            }
        }
        ownAdapter = adapter;
        requestLayout();
    }

    @property protected bool isMainMenu() {
        return _orientation == Orientation.Horizontal;
    }

    /// call to update state for action (if action is assigned for widget)
    override void updateActionState(bool force = false) {
        for (int i = 0; i < itemCount; i++) {
            MenuItemWidget w = cast(MenuItemWidget)itemWidget(i);
            if (w)
                w.updateActionState(force);
        }
    }

    /// Measure widget according to desired width and height constraints. (Step 1 of two phase layout).
    override void measure(int parentWidth, int parentHeight) {
        if (_orientation == Orientation.Horizontal) {
            // for horizontal (main) menu, don't align items
            super.measure(parentWidth, parentHeight);
            return;
        }

        if (visibility == Visibility.Gone) {
            _measuredWidth = _measuredHeight = 0;
            return;
        }
        int maxLabelWidth;
        int maxHeight;
        int maxIconWidth;
        int maxAccelWidth;
        /// find max dimensions for item icon and accelerator sizes
        for (int i = 0; i < itemCount; i++) {
            MenuItemWidget w = cast(MenuItemWidget)itemWidget(i);
            if (w)
                w.measureSubitems(maxLabelWidth, maxHeight, maxIconWidth, maxAccelWidth);
        }
        /// set equal dimensions for item icon and accelerator sizes
        for (int i = 0; i < itemCount; i++) {
            MenuItemWidget w = cast(MenuItemWidget)itemWidget(i);
            if (w)
                w.setSubitemSizes(maxLabelWidth, maxHeight, maxIconWidth, maxAccelWidth);
        }
        super.measure(parentWidth, parentHeight);
    }

    protected void performUndoSelection() {
        selectItem(-1);
        setHoverItem(-1);
    }

    protected long _lastClosedPopupTs;
    protected MenuItem _lastClosedPopupMenu;
    protected enum REOPEN_MENU_THRESHOLD_MS = 200;

    protected bool isRecentlyClosedItem(MenuItem item) {
        if (!isMainMenu)
            return false;
        long ts = currentTimeMillis;
        if (ts - _lastClosedPopupTs < REOPEN_MENU_THRESHOLD_MS && item && item is _lastClosedPopupMenu)
            return true;
        return false;
    }

    protected void onPopupClosed(PopupWidget p) {
        debug(DebugMenus) Log.d("menu ", id, " onPopupClosed selectionChanging=", _selectionChangingInProgress);
        if (_openedPopup) {
            if (_openedPopup is p) {
                _lastClosedPopupTs = currentTimeMillis;
                _lastClosedPopupMenu = _openedMenu ? _openedMenu._item : null;
                _openedMenu.onPopupClosed(p);
                //bool undoSelection = _openedPopupIndex == _selectedItemIndex;
                _openedPopup = null;
                _openedMenu = null;
                //if (undoSelection) {
                //    performUndoSelection();
                //}
                if (!isMainMenu)
                    window.setFocus(this);
                //else
                //    performUndoSelection();
                if (isMainMenu && !_selectionChangingInProgress)
                    close();
            } else if (thisPopup is p) {
                _openedPopup.close();
                _openedPopup = null;
            }
        }
    }

    void deactivate(bool force = false) {
        // override in main menu
    }

    protected void openSubmenu(int index, MenuItemWidget itemWidget, bool selectFirstItem) {
        debug(DebugMenus) Log.d("menu", id, " open submenu ", index);
        if (_openedPopup !is null) {
            if (_openedPopupIndex == index) {
                if (selectFirstItem) {
                    window.setFocus(_openedMenu);
                    _openedMenu.selectItem(0);
                }
                return;
            } else {
                _openedPopup.close();
                _openedPopup = null;
            }
        }

        if (isRecentlyClosedItem(itemWidget.item)) {
            // don't reopen main menu item on duplicate click on the same menu item - deactivate instead
            // deactivate main menu
            deactivate();
            _ignoreItemSelection = itemWidget.item;
            return;
        }

        PopupMenu popupMenu = new PopupMenu(itemWidget.item, this);
        PopupWidget popup = window.showPopup(popupMenu, itemWidget, orientation == Orientation.Horizontal ? PopupAlign.Below :  PopupAlign.Right);
        requestActionsUpdate();
        popup.popupClosed = &onPopupClosed;
        popup.flags = PopupFlags.CloseOnClickOutside;
        _openedPopup = popup;
        _openedMenu = popupMenu;
        _openedPopupIndex = index;
        _selectedItemIndex = index;
        if (selectFirstItem) {
            debug(DebugMenus) Log.d("menu: selecting first item");
            window.setFocus(popupMenu);
            _openedMenu.selectItem(0);
        }
    }

    enum MENU_OPEN_DELAY_MS = 400;
    ulong _submenuOpenTimer = 0;
    int _submenuOpenItemIndex = -1;
    protected void scheduleOpenSubmenu(int index) {
        if (_submenuOpenTimer) {
            cancelTimer(_submenuOpenTimer);
            _submenuOpenTimer = 0;
        }
        _submenuOpenItemIndex = index;
        _submenuOpenTimer = setTimer(MENU_OPEN_DELAY_MS);
    }
    protected void cancelOpenSubmenu() {
        if (_submenuOpenTimer) {
            cancelTimer(_submenuOpenTimer);
            _submenuOpenTimer = 0;
        }
    }
    /// handle timer; return true to repeat timer event after next interval, false cancel timer
    override bool onTimer(ulong id) {
        if (id == _submenuOpenTimer) {
            _submenuOpenTimer = 0;
            MenuItemWidget itemWidget = _submenuOpenItemIndex >= 0 ? cast(MenuItemWidget)_adapter.itemWidget(_submenuOpenItemIndex) : null;
            if (itemWidget !is null) {
                if (itemWidget.item.isSubmenu()) {
                    Log.d("Opening submenu by timer");
                    openSubmenu(_submenuOpenItemIndex, itemWidget, _orientation == Orientation.Horizontal); // for main menu, select first item
                } else {
                    // normal item
                }
            }
        }
        // override to do something useful
        // return true to repeat after the same interval, false to stop timer
        return false;
    }


    protected MenuItem _ignoreItemSelection;
    protected bool _selectionChangingInProgress;
    /// override to handle change of selection
    override protected void selectionChanged(int index, int previouslySelectedItem = -1) {
        debug(DebugMenus) Log.d("menu ", id, " selectionChanged ", index, ", ", previouslySelectedItem, " _selectedItemIndex=", _selectedItemIndex);
        _selectionChangingInProgress = true;
        MenuItemWidget itemWidget = index >= 0 ? cast(MenuItemWidget)_adapter.itemWidget(index) : null;
        MenuItemWidget prevWidget = previouslySelectedItem >= 0 ? cast(MenuItemWidget)_adapter.itemWidget(previouslySelectedItem) : null;
        if (itemWidget._item is _ignoreItemSelection && isMainMenu) {
            _ignoreItemSelection = null;
            deactivate();
            return;
        }
        if (index >= 0)
            setFocus();
        bool popupWasOpen = false;
        if (prevWidget !is null) {
            if (_openedPopup !is null) {
                _openedPopup.close();
                _openedPopup = null;
                popupWasOpen = true;
            }
        }
        if (itemWidget !is null) {
            if (itemWidget.item.isSubmenu()) {
                if (_selectOnHover || popupWasOpen) {
                    if (popupWasOpen && _orientation == Orientation.Horizontal) {
                        // instantly open submenu in main menu if previous submenu was opened
                        openSubmenu(index, itemWidget, false); // _orientation == Orientation.Horizontal for main menu, select first item
                    } else {
                        if (!isMainMenu)
                            scheduleOpenSubmenu(index);
                    }
                }
            } else {
                // normal item
            }
        }
        _selectionChangingInProgress = false;
    }

    protected void handleMenuItemClick(MenuItem item) {
        // precessing for CheckBox and RadioButton menus
        if (item.type == MenuItemType.Check) {
            item.checked = !item.checked;
        } else if (item.type == MenuItemType.Radio) {
            item.checked = true;
        }
        MenuItem p = item;
        while (p) {
            if (p.menuItemClick.assigned) {
                p.menuItemClick(item);
                break;
            }
            if (p.menuItemAction.assigned && item.action) {
                p.menuItemAction(item.action);
                break;
            }
            p = p._parent;
        }
    }

    protected void onMenuItem(MenuItem item) {
        debug(DebugMenus) Log.d("onMenuItem ", item.action.label);
        if (_openedPopup !is null) {
            _openedPopup.close();
            _openedPopup = null;
        }
        if (_parentMenu !is null)
            _parentMenu.onMenuItem(item);
        else {
            // top level handling
            debug(DebugMenus) Log.d("onMenuItem ", item.id);
            selectItem(-1);
            setHoverItem(-1);
            selectOnHover = false;

            // copy menu item click listeners
            Signal!MenuItemClickHandler onMenuItemClickListenerCopy = menuItemClick;
            // copy item action listeners
            Signal!MenuItemActionHandler onMenuItemActionListenerCopy = menuItemAction;

            handleMenuItemClick(item);

            PopupWidget popup = cast(PopupWidget)parent;
            if (popup)
                popup.close();

            // this pointer now can be invalid - if popup removed
            if (onMenuItemClickListenerCopy.assigned)
                if (onMenuItemClickListenerCopy(item))
                    return;
            // this pointer now can be invalid - if popup removed
            if (onMenuItemActionListenerCopy.assigned)
                onMenuItemActionListenerCopy(item.action);
        }
    }

    @property MenuItemWidget selectedMenuItemWidget() {
        return _selectedItemIndex >= 0 ? cast(MenuItemWidget)_adapter.itemWidget(_selectedItemIndex) : null;
    }

    /// override to handle mouse up on item
    override protected void itemClicked(int index) {
        MenuItemWidget itemWidget = index >= 0 ? cast(MenuItemWidget)_adapter.itemWidget(index) : null;
        if (itemWidget !is null) {
            debug(DebugMenus) Log.d("Menu ", id, " Item clicked ", itemWidget.item.action.id);
            if (itemWidget.item.isSubmenu()) {
                // submenu clicked
                if (_clickOnButtonDown && _openedPopup !is null && _openedMenu._item is itemWidget.item) {

                    if (_selectedItemIndex == index) {
                        _openedMenu.setFocus();
                        return;
                    }

                    // second click on main menu opened item
                    _openedPopup.close();
                    _openedPopup = null;
                    //selectItem(-1);
                    selectOnHover = false;
                } else {
                    openSubmenu(index, itemWidget, _orientation == Orientation.Horizontal); // for main menu, select first item
                    selectOnHover = true;
                }
            } else {
                // normal item
                onMenuItem(itemWidget.item);
            }
        }
    }

    /// returns popup this menu is located in
    @property PopupWidget thisPopup() {
        return cast(PopupWidget)parent;
    }

    protected int _menuToggleState;
    protected Widget _menuTogglePreviousFocus;

    /// override to handle specific actions state (e.g. change enabled state for supported actions)
    override bool handleActionStateRequest(const Action a) {
        if (_menuTogglePreviousFocus) {
            debug(DebugMenus) Log.d("Menu.handleActionStateRequest forwarding to ", _menuTogglePreviousFocus);
            bool res = _menuTogglePreviousFocus.handleActionStateRequest(a);
            debug(DebugMenus) Log.d("Menu.handleActionStateRequest forwarding handled successful: ", a.state.toString);
            return res;
        }
        return false;
    }

    /// list navigation using keys
    override bool onKeyEvent(KeyEvent event) {
        if (orientation == Orientation.Horizontal) {
            // no special processing
            if (event.action == KeyAction.KeyDown) {
                if (event.keyCode == KeyCode.ESCAPE) {
                    close();
                    return true;
                }
            }
        } else {
            // for vertical (popup) menu
            if (!focused)
                return false;
            if (event.action == KeyAction.KeyDown) {
                if (event.keyCode == KeyCode.LEFT) {
                    if (_parentMenu !is null) {
                        if (_parentMenu.orientation == Orientation.Vertical) {
                            if (thisPopup !is null) {
                                //int selectedItem = _selectedItemIndex;
                                // back to parent menu on Left key
                                thisPopup.close();
                                //if (selectedItem >= 0)
                                //    selectItem(selectedItem);
                                return true;
                            }
                        } else {
                            // parent is main menu
                            _parentMenu.moveSelection(-1);
                            return true;
                        }
                    }
                    return true;
                } else if (event.keyCode == KeyCode.RIGHT) {
                    MenuItemWidget thisItem = selectedMenuItemWidget();
                    if (thisItem !is null && thisItem.item.isSubmenu) {
                        openSubmenu(_selectedItemIndex, thisItem, true);
                        return true;
                    } else if (_parentMenu !is null && _parentMenu.orientation == Orientation.Horizontal) {
                        _parentMenu.moveSelection(1);
                        return true;
                    }
                    return true;
                } else if (event.keyCode == KeyCode.ESCAPE) {
                    close();
                    return true;
                }
            } else if (event.action == KeyAction.KeyUp) {
                if (event.keyCode == KeyCode.LEFT || event.keyCode == KeyCode.RIGHT) {
                    return true;
                }
            } else if (event.action == KeyAction.Text && event.flags == 0) {
                dchar ch = event.text[0];
                int index = _item.findSubitemByHotkey(ch);
                if (index >= 0) {
                    itemClicked(index);
                    return true;
                }
            }
        }
        if (_selectedItemIndex >= 0 && event.action == KeyAction.KeyDown && /*event.flags == 0 &&*/ (event.keyCode == KeyCode.RETURN || event.keyCode == KeyCode.SPACE)) {
            itemClicked(_selectedItemIndex);
            return true;
        }
        bool res = super.onKeyEvent(event);
        return res;
    }
    /// closes this menu - handle ESC key
    void close() {
        cancelOpenSubmenu();
        if (thisPopup !is null)
            thisPopup.close();
    }

    /// map key to action
    override Action findKeyAction(uint keyCode, uint flags) {
        if (!_item)
            return null;
        Action action = _item.findKeyAction(keyCode, flags);
        return action;
    }

}

/// main menu (horizontal)
class MainMenu : MenuWidgetBase {

    this() {
        super(null, null, Orientation.Horizontal);
        id = "MAIN_MENU";
        styleId = STYLE_MAIN_MENU;
        _clickOnButtonDown = true;
        selectOnHover = false;
    }

    this(MenuItem item) {
        super(null, item, Orientation.Horizontal);
        id = "MAIN_MENU";
        styleId = STYLE_MAIN_MENU;
        _clickOnButtonDown = true;
        selectOnHover = false;
    }

    /// call to update state for action (if action is assigned for widget)
    override void updateActionState(bool force) {
        //Log.d("MainMenu: updateActionState");
        //_item.updateActionState(this);

    }

    /// override and return true to track key events even when not focused
    @property override bool wantsKeyTracking() {
        return true;
    }

    /// get text flags (bit set of TextFlag enum values)
    @property override uint textFlags() {
        // override text flags for main menu
        if (_selectedItemIndex >= 0)
            return TextFlag.UnderlineHotKeys | TextFlag.HotKeys;
        else
            return TextFlag.UnderlineHotKeysWhenAltPressed | TextFlag.HotKeys;
    }

    protected int _menuToggleState;
    protected Widget _menuTogglePreviousFocus;

    override protected void onMenuItem(MenuItem item) {
        debug(DebugMenus) Log.d("MainMenu.onMenuItem ", item.action.label);

        // copy menu item click listeners
        Signal!MenuItemClickHandler onMenuItemClickListenerCopy = menuItemClick;
        // copy item action listeners
        Signal!MenuItemActionHandler onMenuItemActionListenerCopy = menuItemAction;

        deactivate();

        handleMenuItemClick(item);

        // this pointer now can be invalid - if popup removed
        if (onMenuItemClickListenerCopy.assigned)
            if (onMenuItemClickListenerCopy(item))
                return;
        // this pointer now can be invalid - if popup removed
        if (onMenuItemActionListenerCopy.assigned)
            onMenuItemActionListenerCopy(item.action);
    }

    /// return true if main menu is activated (focused or has open submenu)
    @property bool activated() {
        return focused || _selectedItemIndex >= 0 || _openedPopup !is null;
    }

    override protected void performUndoSelection() {
        deactivate();
    }

    /// closes this menu - ESC handling
    override void close() {
        debug(DebugMenus) Log.d("menu ", id, " close called");
        if (_openedPopup !is null) {
            _openedPopup.close();
            _openedPopup = null;
        } else
            deactivate();
    }

    /// request relayout of widget and its children
    //override void requestLayout() {
    //    Log.d("MainMenu.requestLayout is called");
    //    super.requestLayout();
    //}

    /// bring focus to main menu, if not yet activated
    void activate() {
        debug(DebugMenus) Log.d("activating main menu");
        if (activated)
            return;
        window.setFocus(this);
        selectItem(0);
    }

    /// close and remove focus, if activated
    override void deactivate(bool force = false) {
        debug(DebugMenus) Log.d("deactivating main menu");
        if (!activated && !force)
            return;
        if (_openedPopup !is null) {
            _openedPopup.close();
            _openedPopup = null;
        }
        selectItem(-1);
        setHoverItem(-1);
        selectOnHover = false;
        window.setFocus(_menuTogglePreviousFocus);
    }

    /// activate or deactivate main menu, return true if it has been activated
    bool toggle() {
        if (activated) {
            // unfocus
            deactivate();
            return false;
        } else {
            // focus
            activate();
            return true;
        }

    }

    /// override to handle focus changes
    override protected void handleFocusChange(bool focused, bool receivedFocusFromKeyboard = false) {
        debug(DebugMenus) Log.d("menu ", id, "handling focus change to ", focused);
        if (focused && _openedPopup is null) {
            // activating!
            _menuTogglePreviousFocus = window.focusedWidget;
            //updateActionState(true);
            debug(DebugMenus) Log.d("MainMenu: updateActionState");
            _item.updateActionState(this);
        }
        super.handleFocusChange(focused);
    }

    /// list navigation using keys
    override bool onKeyEvent(KeyEvent event) {
        // handle MainMenu activation / deactivation (Alt, Esc...)
        bool toggleMenu = false;
        bool isAlt = event.keyCode == KeyCode.ALT || event.keyCode == KeyCode.LALT || event.keyCode == KeyCode.RALT;
        bool altPressed = !!(event.flags & KeyFlag.Alt);
        bool noOtherModifiers = !(event.flags & (KeyFlag.Shift | KeyFlag.Control));
        bool noAltGrKey = !((event.flags & KeyFlag.RAlt) == KeyFlag.RAlt);

        if (event.action == KeyAction.KeyDown && event.keyCode == KeyCode.ESCAPE && event.flags == 0 && activated) {
            deactivate();
            return true;
        }
        dchar hotkey = 0;
        if (event.action == KeyAction.KeyDown && event.keyCode >= KeyCode.KEY_A && event.keyCode <= KeyCode.KEY_Z && altPressed && noOtherModifiers && noAltGrKey) {
//            Log.d("Alt + a..z");
            hotkey = cast(dchar)((event.keyCode - KeyCode.KEY_A) + 'a');
        }
        if (event.action == KeyAction.Text && altPressed && noOtherModifiers && noAltGrKey) {
            hotkey = event.text[0];
        }
        if (hotkey) {
            int index = _item.findSubitemByHotkey(hotkey);
            if (index >= 0) {
                activate();
                itemClicked(index);
                return true;
            } else {
                MenuItem item = _item.findSubitemByHotkeyRecursive(hotkey);
                if (item) {
                    Log.d("found menu item recursive");
                    onMenuItem(item);
                    return true;
                }
                return false;
            }
        }

        // toggle menu by single Alt press - for Windows only!
        version (Windows) {
            if (event.action == KeyAction.KeyDown && isAlt && noOtherModifiers) {
                _menuToggleState = 1;
            } else if (event.action == KeyAction.KeyUp && isAlt && noOtherModifiers) {
                if (_menuToggleState == 1)
                    toggleMenu = true;
                _menuToggleState = 0;
            } else {
                _menuToggleState = 0;
            }
            if (toggleMenu) {
                toggle();
                return true;
            }
        }
        if (!focused)
            return false;
        if (_selectedItemIndex >= 0 && event.action == KeyAction.KeyDown && ((event.keyCode == KeyCode.DOWN) || (event.keyCode == KeyCode.SPACE) || (event.keyCode == KeyCode.RETURN))) {
            itemClicked(_selectedItemIndex);
            return true;
        }
        return super.onKeyEvent(event);
    }

    override @property protected uint overrideStateForItem() {
        uint res = state;
        if (_openedPopup)
            res |= State.Focused; // main menu with opened popup as focused for items display
        return res;
    }

}


/// popup menu widget (vertical layout of items)
class PopupMenu : MenuWidgetBase {

    this(MenuItem item, MenuWidgetBase parentMenu = null) {
        super(parentMenu, item, Orientation.Vertical);
        id = "POPUP_MENU";
        styleId = STYLE_POPUP_MENU;
        selectOnHover = true;
    }
}
