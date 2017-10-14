// Written in the D programming language.

/**
This module contains declaration of tabbed view controls.

TabItemWidget - single tab header in tab control
TabWidget
TabHost
TabControl


Synopsis:

----
import dlangui.widgets.tabs;

----

Copyright: Vadim Lopatin, 2014
License:   Boost License 1.0
Authors:   Vadim Lopatin, coolreader.org@gmail.com
*/
module dlangui.widgets.tabs;

import dlangui.core.signals;
import dlangui.core.stdaction;
import dlangui.widgets.layouts;
import dlangui.widgets.controls;
import dlangui.widgets.menu;
import dlangui.widgets.popup;

import std.algorithm;

/// current tab is changed handler
interface TabHandler {
    void onTabChanged(string newActiveTabId, string previousTabId);
}

/// tab close button pressed handler
interface TabCloseHandler {
    void onTabClose(string tabId);
}

interface PopupMenuHandler {
    MenuItem getPopupMenu(Widget source);
}

/// tab item metadata
class TabItem {
    private static __gshared long _lastAccessCounter;
    private string _iconRes;
    private string _id;
    private UIString _label;
    private UIString _tooltipText;
    private long _lastAccessTs;

    this(string id, string labelRes, string iconRes = null, dstring tooltipText = null) {
        _id = id;
        _label.id = labelRes;
        _iconRes = iconRes;
        _tooltipText = UIString.fromRaw(tooltipText);
    }
    this(string id, dstring labelText, string iconRes = null, dstring tooltipText = null) {
        _id = id;
        _label.value = labelText;
        _iconRes = iconRes;
        _lastAccessTs = _lastAccessCounter++;
        _tooltipText = UIString.fromRaw(tooltipText);
    }
    this(string id, UIString labelText, string iconRes = null, dstring tooltipText = null) {
        _id = id;
        _label = labelText;
        _iconRes = iconRes;
        _lastAccessTs = _lastAccessCounter++;
        _tooltipText = UIString.fromRaw(tooltipText);
    }

    @property string iconId() const { return _iconRes; }
    @property string id() const { return _id; }
    @property ref UIString text() { return _label; }
    @property TabItem iconId(string id) { _iconRes = id; return this; }
    @property TabItem id(string  id) { _id = id; return this; }
    @property long lastAccessTs() { return _lastAccessTs; }
    @property void lastAccessTs(long ts) { _lastAccessTs = ts; }
    void updateAccessTs() {
        _lastAccessTs = _lastAccessCounter++; //std.datetime.Clock.currStdTime;
    }

    /// tooltip text
    @property dstring tooltipText() {
        if (_tooltipText.empty)
            return null;
        return _tooltipText.value;
    }
    /// tooltip text
    @property void tooltipText(dstring text) { _tooltipText = UIString.fromRaw(text); }
    /// tooltip text
    @property void tooltipText(UIString text) { _tooltipText = text; }

    protected Object _objectParam;
    @property Object objectParam() {
        return _objectParam;
    }
    @property TabItem objectParam(Object value) {
        _objectParam = value;
        return this;
    }

    protected int _intParam;
    @property int intParam() {
        return _intParam;
    }
    @property TabItem intParam(int value) {
        _intParam = value;
        return this;
    }
}

/// tab item widget - to show tab header
class TabItemWidget : HorizontalLayout {
    private ImageWidget _icon;
    private TextWidget _label;
    private ImageButton _closeButton;
    private TabItem _item;
    private bool _enableCloseButton;
    Signal!TabCloseHandler tabClose;
    @property TabItem tabItem() { return _item; }
    @property TabControl tabControl() { return cast(TabControl)parent; }

    this(TabItem item, bool enableCloseButton = true) {
        styleId = STYLE_TAB_UP_BUTTON;
        _enableCloseButton = enableCloseButton;
        _icon = new ImageWidget();
        _label = new TextWidget();
        _label.styleId = STYLE_TAB_UP_BUTTON_TEXT;
        _label.state = State.Parent;
        _closeButton = new ImageButton("CLOSE");
        _closeButton.styleId = STYLE_BUTTON_TRANSPARENT;
        _closeButton.drawableId = "close";
        _closeButton.trackHover = true;
        _closeButton.click = &onClick;
        if (!_enableCloseButton) {
            _closeButton.visibility = Visibility.Gone;
        } else {
            _closeButton.visibility = Visibility.Visible;
        }
        addChild(_icon);
        addChild(_label);
        addChild(_closeButton);
        setItem(item);
        clickable = true;
        trackHover = true;
        _label.trackHover = true;
        _label.tooltipText = _item.tooltipText;
        if (_icon)
            _icon.tooltipText = _item.tooltipText;
        if (_closeButton)
            _closeButton.tooltipText = _item.tooltipText;
    }

    /// tooltip text - when not empty, widget will show tooltips automatically; for advanced tooltips - override hasTooltip and createTooltip
    override @property dstring tooltipText() { return _item.tooltipText; }
    /// tooltip text - when not empty, widget will show tooltips automatically; for advanced tooltips - override hasTooltip and createTooltip
    override @property Widget tooltipText(dstring text) { 
        _label.tooltipText = text;
        if (_icon)
            _icon.tooltipText = text;
        if (_closeButton)
            _closeButton.tooltipText = text;
        _item.tooltipText = text;
        return this; 
    }
    /// tooltip text - when not empty, widget will show tooltips automatically; for advanced tooltips - override hasTooltip and createTooltip
    override @property Widget tooltipText(UIString text) {
        _label.tooltipText = text;
        if (_icon)
            _icon.tooltipText = text;
        if (_closeButton)
            _closeButton.tooltipText = text;
        _item.tooltipText = text;
        return this;
    }

    void setStyles(string tabButtonStyle, string tabButtonTextStyle) {
        styleId = tabButtonStyle;
        _label.styleId = tabButtonTextStyle;
    }

    override void onDraw(DrawBuf buf) {
        //debug Log.d("TabWidget.onDraw ", id);
        super.onDraw(buf);
    }

    protected bool onClick(Widget source) {
        if (source.compareId("CLOSE")) {
            Log.d("tab close button pressed");
            if (tabClose.assigned)
                tabClose(_item.id);
        }
        return true;
    }

    @property TabItem item() {
        return _item;
    }
    @property void setItem(TabItem item) {
        _item = item;
        if (item.iconId !is null) {
            _icon.visibility = Visibility.Visible;
            _icon.drawableId = item.iconId;
        } else {
            _icon.visibility = Visibility.Gone;
        }
        _label.text = item.text;
        id = item.id;
    }
}

/// tab item list helper class
class TabItemList {
    private TabItem[] _list;
    private int _len;

    this() {
    }

    /// get item by index
    TabItem get(int index) {
        if (index < 0 || index >= _len)
            return null;
        return _list[index];
    }
    /// get item by index
    const (TabItem) get(int index) const {
        if (index < 0 || index >= _len)
            return null;
        return _list[index];
    }
    /// get item by index
    TabItem opIndex(int index) {
        return get(index);
    }
    /// get item by index
    const (TabItem) opIndex(int index) const {
        return get(index);
    }
    /// get item by id
    TabItem get(string id) {
        int idx = indexById(id);
        if (idx < 0)
            return null;
        return _list[idx];
    }
    /// get item by id
    const (TabItem) get(string id) const {
        int idx = indexById(id);
        if (idx < 0)
            return null;
        return _list[idx];
    }
    /// get item by id
    TabItem opIndex(string id) {
        return get(id);
    }
    @property int length() const { return _len; }
    /// append new item
    TabItemList add(TabItem item) {
        return insert(item, -1);
    }
    /// insert new item to specified position
    TabItemList insert(TabItem item, int index) {
        if (index > _len || index < 0)
            index = _len;
        if (_list.length <= _len)
            _list.length = _len + 4;
        for (int i = _len; i > index; i--)
            _list[i] = _list[i - 1];
        _list[index] = item;
        _len++;
        return this;
    }
    /// remove item by index
    TabItem remove(int index) {
        TabItem res = _list[index];
        for (int i = index; i < _len - 1; i++)
            _list[i] = _list[i + 1];
        _len--;
        return res;
    }
    /// find tab index by id
    int indexById(string id) const {
        for (int i = 0; i < _len; i++) {
            if (_list[i].id.equal(id))
                return i;
        }
        return -1;
    }
}

/// tab header - tab labels, with optional More button
class TabControl : WidgetGroupDefaultDrawing {
    protected TabItemList _items;
    protected ImageButton _moreButton;
    protected bool _enableCloseButton;
    protected bool _autoMoreButtonMenu = true;
    protected TabItemWidget[] _sortedItems;
    protected int _buttonOverlap;

    protected string _tabStyle;
    protected string _tabButtonStyle;
    protected string _tabButtonTextStyle;

    /// signal of tab change (e.g. by clicking on tab header)
    Signal!TabHandler tabChanged;

    /// signal on tab close button
    Signal!TabCloseHandler tabClose;
    /// on more button click (bool delegate(Widget))
    Signal!OnClickHandler moreButtonClick;
    /// handler for more button popup menu
    Signal!PopupMenuHandler moreButtonPopupMenu;

    protected Align _tabAlignment;
    @property Align tabAlignment() { return _tabAlignment; }
    @property void tabAlignment(Align a) { _tabAlignment = a; }

    /// empty parameter list constructor - for usage by factory
    this() {
        this(null);
    }
    /// create with ID parameter
    this(string ID, Align tabAlignment = Align.Top) {
        super(ID);
        _tabAlignment = tabAlignment;
        setStyles(STYLE_TAB_UP, STYLE_TAB_UP_BUTTON, STYLE_TAB_UP_BUTTON_TEXT);
        _items = new TabItemList();
        _moreButton = new ImageButton("MORE", "tab_more");
        _moreButton.styleId = STYLE_BUTTON_TRANSPARENT;
        _moreButton.mouseEvent = &onMouse;
        _moreButton.margins(Rect(0,0,0,0));
        _enableCloseButton = true;
        styleId = _tabStyle;
        addChild(_moreButton); // first child is always MORE button, the rest corresponds to tab list
    }

    void setStyles(string tabStyle, string tabButtonStyle, string tabButtonTextStyle) {
        _tabStyle = tabStyle;
        _tabButtonStyle = tabButtonStyle;
        _tabButtonTextStyle = tabButtonTextStyle;
        styleId = _tabStyle;
        for (int i = 1; i < _children.count; i++) {
            TabItemWidget w = cast(TabItemWidget)_children[i];
            if (w) {
                w.setStyles(_tabButtonStyle, _tabButtonTextStyle);
            }
        }
        _buttonOverlap = currentTheme.get(tabButtonStyle).customLength("overlap", 0);
    }

    /// when true, shows close buttons in tabs
    @property bool enableCloseButton() { return _enableCloseButton; }
    /// ditto
    @property void enableCloseButton(bool enabled) {
        _enableCloseButton = enabled;
    }
    /// when true, more button is visible
    @property bool enableMoreButton() {
        return _moreButton.visibility == Visibility.Visible;
    }
    /// ditto
    @property void enableMoreButton(bool flgVisible) {
        _moreButton.visibility = flgVisible ? Visibility.Visible : Visibility.Gone;
    }
    /// when true, automatically generate popup menu for more button - allowing to select tab from list
    @property bool autoMoreButtonMenu() {
        return _autoMoreButtonMenu;
    }
    /// ditto
    @property void autoMoreButtonMenu(bool enableAutoMenu) {
        _autoMoreButtonMenu = enableAutoMenu;
    }

    /// more button custom icon
    @property string moreButtonIcon() {
        return _moreButton.drawableId;
    }
    /// ditto
    @property void moreButtonIcon(string resourceId) {
        _moreButton.drawableId = resourceId;
    }

    /// returns tab count
    @property int tabCount() const {
        return _items.length;
    }
    /// returns tab item by id (null if index out of range)
    TabItem tab(int index) {
        return _items.get(index);
    }
    /// returns tab item by id (null if not found)
    TabItem tab(string id) {
        return _items.get(id);
    }
    /// returns tab item by id (null if not found)
    const(TabItem) tab(string id) const {
        return _items.get(id);
    }
    /// get tab index by tab id (-1 if not found)
    int tabIndex(string id) {
        return _items.indexById(id);
    }
    protected void updateTabs() {
        // TODO:
    }
    static bool accessTimeComparator(TabItemWidget a, TabItemWidget b) {
        return (a.tabItem.lastAccessTs > b.tabItem.lastAccessTs);
    }

    protected TabItemWidget[] sortedItems() {
        _sortedItems.length = _items.length;
        for (int i = 0; i < _items.length; i++)
            _sortedItems[i] = cast(TabItemWidget)_children.get(i + 1);
        std.algorithm.sort!(accessTimeComparator)(_sortedItems);
        return _sortedItems;
    }

    /// find next or previous tab index, based on access time
    int getNextItemIndex(int direction) {
        if (_items.length == 0)
            return -1;
        if (_items.length == 1)
            return 0;
        TabItemWidget[] items = sortedItems();
        for (int i = 0; i < items.length; i++) {
            if (items[i].id == _selectedTabId) {
                int next = i + direction;
                if (next < 0)
                    next = cast(int)(items.length - 1);
                if (next >= items.length)
                    next = 0;
                return _items.indexById(items[next].id);
            }
        }
        return -1;
    }

    /// remove tab
    TabControl removeTab(string id) {
        string nextId;
        if (id.equal(_selectedTabId)) {
            // current tab is being closed: remember next tab id
            int nextIndex = getNextItemIndex(1);
            if (nextIndex < 0)
                nextIndex = getNextItemIndex(-1);
            if (nextIndex >= 0)
                nextId = _items[nextIndex].id;
        }
        int index = _items.indexById(id);
        if (index >= 0) {
            Widget w = _children.remove(index + 1);
            if (w)
                destroy(w);
            _items.remove(index);
            if (id.equal(_selectedTabId))
                _selectedTabId = null;
            requestLayout();
        }
        if (nextId) {
            index = _items.indexById(nextId);
            if (index >= 0) {
                selectTab(index, true);
            }
        }
        return this;
    }

    /// change name of tab
    void renameTab(string ID, dstring name) {
        int index = _items.indexById(id);
        if (index >= 0) {
            renameTab(index, name);
        }
    }

    /// change name of tab
    void renameTab(int index, dstring name) {
        _items[index].text = name;
        for (int i = 0; i < _children.count; i++) {
            TabItemWidget widget = cast (TabItemWidget)_children[i];
            if (widget && widget.item is _items[index]) {
                widget.setItem(_items[index]);
                requestLayout();
                break;
            }
        }
    }

    /// change name and id of tab
    void renameTab(int index, string id, dstring name) {
        _items[index].text = name;
        _items[index].id = id;
        for (int i = 0; i < _children.count; i++) {
            TabItemWidget widget = cast (TabItemWidget)_children[i];
            if (widget && widget.item is _items[index]) {
                widget.setItem(_items[index]);
                requestLayout();
                break;
            }
        }
    }

    protected void onTabClose(string tabId) {
        if (tabClose.assigned)
            tabClose(tabId);
    }

    /// add new tab
    TabControl addTab(TabItem item, int index = -1, bool enableCloseButton = false) {
        _items.insert(item, index);
        TabItemWidget widget = new TabItemWidget(item, enableCloseButton);
        widget.parent = this;
        widget.mouseEvent = &onMouse;
        widget.setStyles(_tabButtonStyle, _tabButtonTextStyle);
        widget.tabClose = &onTabClose;
        _children.insert(widget, index);
        updateTabs();
        requestLayout();
        return this;
    }
    /// add new tab by id and label string
    TabControl addTab(string id, dstring label, string iconId = null, bool enableCloseButton = false, dstring tooltipText = null) {
        TabItem item = new TabItem(id, label, iconId, tooltipText);
        return addTab(item, -1, enableCloseButton);
    }
    /// add new tab by id and label string resource id
    TabControl addTab(string id, string labelResourceId, string iconId = null, bool enableCloseButton = false, dstring tooltipText = null) {
        TabItem item = new TabItem(id, labelResourceId, iconId, tooltipText);
        return addTab(item, -1, enableCloseButton);
    }
    /// add new tab by id and label UIString
    TabControl addTab(string id, UIString label, string iconId = null, bool enableCloseButton = false, dstring tooltipText = null) {
        TabItem item = new TabItem(id, label, iconId, tooltipText);
        return addTab(item, -1, enableCloseButton);
    }

    protected MenuItem getMoreButtonPopupMenu() {
        if (moreButtonPopupMenu.assigned) {
            if (auto menu = moreButtonPopupMenu(this)) {
                return menu;
            }
        }
        if (_autoMoreButtonMenu) {
            if (!tabCount)
                return null;
            MenuItem res = new MenuItem();
            for (int i = 0; i < tabCount; i++) {
                TabItem item = _items[i];
                Action action = new Action(StandardAction.TabSelectItem, item.text);
                action.longParam = i;
                res.add(action);
            }
            return res;
        }
        return null;
    }

    /// try to invoke popup menu, return true if popup menu is shown
    protected bool handleMorePopupMenu() {
        if (auto menu = getMoreButtonPopupMenu()) {
            PopupMenu popupMenu = new PopupMenu(menu);
            popupMenu.menuItemAction = &handleAction;
            //popupMenu.menuItemAction = this;
            PopupWidget popup = window.showPopup(popupMenu, this, PopupAlign.Point | (_tabAlignment == Align.Top ? PopupAlign.Below : PopupAlign.Above) | PopupAlign.Right, _moreButton.pos.right, _moreButton.pos.bottom);
            popup.flags = PopupFlags.CloseOnClickOutside;
            popupMenu.setFocus();
            popupMenu.selectItem(0);
            return true;
        }
        return false;
    }

    /// override to handle specific actions
    override bool handleAction(const Action a) {
        if (a.id == StandardAction.TabSelectItem) {
            selectTab(cast(int)a.longParam, true);
            return true;
        }
        return super.handleAction(a);
    }

    protected bool onMouse(Widget source, MouseEvent event) {
        if (event.action == MouseAction.ButtonDown && event.button == MouseButton.Left) {
            if (source.compareId("MORE")) {
                Log.d("tab MORE button pressed");
                if (handleMorePopupMenu())
                    return true;
                if (moreButtonClick.assigned) {
                    moreButtonClick(this);
                }
                return true;
            }
            string id = source.id;
            int index = tabIndex(id);
            if (index >= 0) {
                selectTab(index, true);
            }
        }
        return true;
    }

    /// Measure widget according to desired width and height constraints. (Step 1 of two phase layout).
    override void measure(int parentWidth, int parentHeight) {
        //Log.d("tabControl.measure enter");
        Rect m = margins;
        Rect p = padding;
        // calc size constraints for children
        int pwidth = parentWidth;
        int pheight = parentHeight;
        if (parentWidth != SIZE_UNSPECIFIED)
            pwidth -= m.left + m.right + p.left + p.right;
        if (parentHeight != SIZE_UNSPECIFIED)
            pheight -= m.top + m.bottom + p.top + p.bottom;
        // measure children
        Point sz;
        if (_moreButton.visibility == Visibility.Visible) {
            _moreButton.measure(pwidth, pheight);
            sz.x = _moreButton.measuredWidth;
            sz.y = _moreButton.measuredHeight;
        }
        pwidth -= sz.x;
        for (int i = 1; i < _children.count; i++) {
            Widget tab = _children.get(i);
            tab.visibility = Visibility.Visible;
            tab.measure(pwidth, pheight);
            if (sz.y < tab.measuredHeight)
                sz.y = tab.measuredHeight;
            if (sz.x + tab.measuredWidth > pwidth)
                break;
            sz.x += tab.measuredWidth - _buttonOverlap;
        }
        measuredContent(parentWidth, parentHeight, sz.x, sz.y);
        //Log.d("tabControl.measure exit");
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
        // more button
        Rect moreRc = rc;
        if (_moreButton.visibility == Visibility.Visible) {
            moreRc.left = rc.right - _moreButton.measuredWidth;
            _moreButton.layout(moreRc);
            rc.right -= _moreButton.measuredWidth;
        }
        // tabs
        int maxw = rc.width;
        // measure and update visibility
        TabItemWidget[] sorted = sortedItems();
        int w = 0;
        for (int i = 0; i < sorted.length; i++) {
            TabItemWidget widget = sorted[i];
            widget.visibility = Visibility.Visible;
            widget.measure(rc.width, rc.height);
            if (w + widget.measuredWidth < maxw) {
                w += widget.measuredWidth - _buttonOverlap;
            } else {
                widget.visibility = Visibility.Gone;
            }
        }
        // layout visible items
        for (int i = 1; i < _children.count; i++) {
            TabItemWidget widget = cast(TabItemWidget)_children.get(i);
            if (widget.visibility != Visibility.Visible)
                continue;
            w = widget.measuredWidth;
            rc.right = rc.left + w;
            widget.layout(rc);
            rc.left += w - _buttonOverlap;
        }
        //Log.d("tabControl.layout exit");
    }

    /// Draw widget at its position to buffer
    override void onDraw(DrawBuf buf) {
        if (visibility != Visibility.Visible)
            return;
        //debug Log.d("TabControl.onDraw enter");
        super.Widget.onDraw(buf);
        Rect rc = _pos;
        applyMargins(rc);
        applyPadding(rc);
        auto saver = ClipRectSaver(buf, rc);
        // draw all items except selected
        for (int i = _children.count - 1; i >= 0; i--) {
            Widget item = _children.get(i);
            if (item.visibility != Visibility.Visible)
                continue;
            if (item.id.equal(_selectedTabId)) // skip selected
                continue;
            item.onDraw(buf);
        }
        // draw selected item
        for (int i = 0; i < _children.count; i++) {
            Widget item = _children.get(i);
            if (item.visibility != Visibility.Visible)
                continue;
            if (!item.id.equal(_selectedTabId)) // skip all except selected
                continue;
            item.onDraw(buf);
        }
        //debug Log.d("TabControl.onDraw exit");
    }

    protected string _selectedTabId;

    @property string selectedTabId() const {
        return _selectedTabId;
    }

    void updateAccessTs() {
        int index = _items.indexById(_selectedTabId);
        if (index >= 0)
            _items[index].updateAccessTs();
    }

    void selectTab(int index, bool updateAccess) {
        if (index < 0 || index + 1 >= _children.count) {
            Log.e("Tried to access tab out of bounds (index = %d, count = %d)",index,_children.count-1);
            return;
        }
        if (_children.get(index + 1).compareId(_selectedTabId))
            return; // already selected
        string previousSelectedTab = _selectedTabId;
        for (int i = 1; i < _children.count; i++) {
            if (index == i - 1) {
                _children.get(i).state = State.Selected;
                _selectedTabId = _children.get(i).id;
                if (updateAccess)
                    updateAccessTs();
            } else {
                _children.get(i).state = State.Normal;
            }
        }
        if (tabChanged.assigned)
            tabChanged(_selectedTabId, previousSelectedTab);
    }
}

/// container for widgets controlled by TabControl
class TabHost : FrameLayout, TabHandler {
    /// empty parameter list constructor - for usage by factory
    this() {
        this(null);
    }
    /// create with ID parameter
    this(string ID, TabControl tabControl = null) {
        super(ID);
        _tabControl = tabControl;
        if (_tabControl !is null)
            _tabControl.tabChanged = &onTabChanged;
        styleId = STYLE_TAB_HOST;
    }
    protected TabControl _tabControl;
    /// get currently set control widget
    @property TabControl tabControl() { return _tabControl; }
    /// set new control widget
    @property TabHost tabControl(TabControl newWidget) {
        _tabControl = newWidget;
        if (_tabControl !is null)
            _tabControl.tabChanged = &onTabChanged;
        return this;
    }

    protected Visibility _hiddenTabsVisibility = Visibility.Invisible;
    @property Visibility hiddenTabsVisibility() { return _hiddenTabsVisibility; }
    @property void hiddenTabsVisibility(Visibility v) { _hiddenTabsVisibility = v; }

    /// signal of tab change (e.g. by clicking on tab header)
    Signal!TabHandler tabChanged;

    protected override void onTabChanged(string newActiveTabId, string previousTabId) {
        if (newActiveTabId !is null) {
            showChild(newActiveTabId, _hiddenTabsVisibility, true);
        }
        if (tabChanged.assigned)
            tabChanged(newActiveTabId, previousTabId);
    }

    /// get tab content widget by id
    Widget tabBody(string id) {
        for (int i = 0; i < _children.count; i++) {
            if (_children[i].compareId(id))
                return _children[i];
        }
        return null;
    }

    /// remove tab
    TabHost removeTab(string id) {
        assert(_tabControl !is null, "No TabControl set for TabHost");
        Widget child = removeChild(id);
        if (child !is null) {
            destroy(child);
        }
        _tabControl.removeTab(id);
        requestLayout();
        return this;
    }

    /// add new tab by id and label string
    TabHost addTab(Widget widget, dstring label, string iconId = null, bool enableCloseButton = false, dstring tooltipText = null) {
        assert(_tabControl !is null, "No TabControl set for TabHost");
        assert(widget.id !is null, "ID for tab host page is mandatory");
        assert(_children.indexOf(id) == -1, "duplicate ID for tab host page");
        _tabControl.addTab(widget.id, label, iconId, enableCloseButton, tooltipText);
        tabInitialization(widget);
        //widget.focusGroup = true; // doesn't allow move focus outside of tab content
        addChild(widget);
        return this;
    }

    /// add new tab by id and label string resource id
    TabHost addTab(Widget widget, string labelResourceId, string iconId = null, bool enableCloseButton = false, dstring tooltipText = null) {
        assert(_tabControl !is null, "No TabControl set for TabHost");
        assert(widget.id !is null, "ID for tab host page is mandatory");
        assert(_children.indexOf(id) == -1, "duplicate ID for tab host page");
        _tabControl.addTab(widget.id, labelResourceId, iconId, enableCloseButton, tooltipText);
        tabInitialization(widget);
        addChild(widget);
        return this;
    }

    /// add new tab by id and label UIString
    TabHost addTab(Widget widget, UIString label, string iconId = null, bool enableCloseButton = false, dstring tooltipText = null) {
        assert(_tabControl !is null, "No TabControl set for TabHost");
        assert(widget.id !is null, "ID for tab host page is mandatory");
        assert(_children.indexOf(id) == -1, "duplicate ID for tab host page");
        _tabControl.addTab(widget.id, label, iconId, enableCloseButton, tooltipText);
        tabInitialization(widget);
        addChild(widget);
        return this;
    }

    // handles initial tab selection & hides subsequently added tabs so
    // they don't appear in the same frame
    private void tabInitialization(Widget widget) {
        if(_tabControl.selectedTabId is null) {
            selectTab(_tabControl.tab(0).id,false);
        } else {
            widget.visibility = Visibility.Invisible;
        }
    }

    /// select tab
    void selectTab(string ID, bool updateAccess) {
        int index = _tabControl.tabIndex(ID);
        if (index != -1) {
            _tabControl.selectTab(index, updateAccess);
        }
    }
//    /// request relayout of widget and its children
//    override void requestLayout() {
//        Log.d("TabHost.requestLayout called");
//        super.requestLayout();
//        //_needLayout = true;
//    }
//    /// Set widget rectangle to specified value and layout widget contents. (Step 2 of two phase layout).
//    override void layout(Rect rc) {
//        Log.d("TabHost.layout() called");
//        super.layout(rc);
//        Log.d("after layout(): needLayout = ", needLayout);
//    }

}



/// compound widget - contains from TabControl widget (tabs header) and TabHost (content pages)
class TabWidget : VerticalLayout, TabHandler, TabCloseHandler {
    protected TabControl _tabControl;
    protected TabHost _tabHost;
    /// empty parameter list constructor - for usage by factory
    this() {
        this(null);
    }
    /// create with ID parameter
    this(string ID, Align tabAlignment = Align.Top) {
        super(ID);
        _tabControl = new TabControl("TAB_CONTROL", tabAlignment);
        _tabHost = new TabHost("TAB_HOST", _tabControl);
        _tabControl.tabChanged.connect(this);
        _tabControl.tabClose.connect(this);
        styleId = STYLE_TAB_WIDGET;
        if (tabAlignment == Align.Top) {
            addChild(_tabControl);
            addChild(_tabHost);
        } else {
            addChild(_tabHost);
            addChild(_tabControl);
        }
        focusGroup = true;
    }

    TabControl tabControl() { return _tabControl; }
    TabHost tabHost() { return _tabHost; }

    /// signal of tab change (e.g. by clicking on tab header)
    Signal!TabHandler tabChanged;
    /// signal on tab close button
    Signal!TabCloseHandler tabClose;

    protected override void onTabClose(string tabId) {
        if (tabClose.assigned)
            tabClose(tabId);
    }

    protected override void onTabChanged(string newActiveTabId, string previousTabId) {
        // forward to listener
        if (tabChanged.assigned)
            tabChanged(newActiveTabId, previousTabId);
    }

    /// add new tab by id and label string resource id
    TabWidget addTab(Widget widget, string labelResourceId, string iconId = null, bool enableCloseButton = false, dstring tooltipText = null) {
        _tabHost.addTab(widget, labelResourceId, iconId, enableCloseButton, tooltipText);
        return this;
    }

    /// add new tab by id and label (raw value)
    TabWidget addTab(Widget widget, dstring label, string iconId = null, bool enableCloseButton = false, dstring tooltipText = null) {
        _tabHost.addTab(widget, label, iconId, enableCloseButton, tooltipText);
        return this;
    }

    /// remove tab by id
    TabWidget removeTab(string id) {
        _tabHost.removeTab(id);
        requestLayout();
        return this;
    }

    /// change name of tab
    void renameTab(string ID, dstring name) {
        _tabControl.renameTab(ID, name);
    }

    /// change name of tab
    void renameTab(int index, dstring name) {
        _tabControl.renameTab(index, name);
    }

    /// change name of tab
    void renameTab(int index, string id, dstring name) {
        _tabControl.renameTab(index, id, name);
    }

    @property Visibility hiddenTabsVisibility() { return _tabHost.hiddenTabsVisibility; }
    @property void hiddenTabsVisibility(Visibility v) { _tabHost.hiddenTabsVisibility = v; }

    /// select tab
    void selectTab(string ID, bool updateAccess = true) {
        _tabHost.selectTab(ID, updateAccess);
    }

    /// select tab
    void selectTab(int index, bool updateAccess = true) {
        _tabControl.selectTab(index, updateAccess);
    }

    /// get tab content widget by id
    Widget tabBody(string id) {
        return _tabHost.tabBody(id);
    }

    /// get tab content widget by id
    Widget tabBody(int index) {
        string id = _tabControl.tab(index).id;
        return _tabHost.tabBody(id);
    }

    /// returns tab item by id (null if index out of range)
    TabItem tab(int index) {
        return _tabControl.tab(index);
    }
    /// returns tab item by id (null if not found)
    TabItem tab(string id) {
        return _tabControl.tab(id);
    }
    /// returns tab count
    @property int tabCount() const {
        return _tabControl.tabCount;
    }
    /// get tab index by tab id (-1 if not found)
    int tabIndex(string id) {
        return _tabControl.tabIndex(id);
    }

    /// change style ids
    void setStyles(string tabWidgetStyle, string tabStyle, string tabButtonStyle, string tabButtonTextStyle, string tabHostStyle = null) {
        styleId = tabWidgetStyle;
        _tabControl.setStyles(tabStyle, tabButtonStyle, tabButtonTextStyle);
        _tabHost.styleId = tabHostStyle;
    }

    /// override to handle specific actions
    override bool handleAction(const Action a) {
        if (a.id == StandardAction.TabSelectItem) {
            selectTab(cast(int)a.longParam);
            return true;
        }
        return super.handleAction(a);
    }

    private bool _tabNavigationInProgress;

    /// process key event, return true if event is processed.
    override bool onKeyEvent(KeyEvent event) {
        if (_tabNavigationInProgress) {
            if (event.action == KeyAction.KeyDown || event.action == KeyAction.KeyUp) {
                if (!(event.flags & KeyFlag.Control)) {
                    _tabNavigationInProgress = false;
                    _tabControl.updateAccessTs();
                }
            }
        }
        if (event.action == KeyAction.KeyDown) {
            if (event.keyCode == KeyCode.TAB && (event.flags & KeyFlag.Control)) {
                // support Ctrl+Tab and Ctrl+Shift+Tab for navigation
                _tabNavigationInProgress = true;
                int direction = (event.flags & KeyFlag.Shift) ? - 1 : 1;
                int index = _tabControl.getNextItemIndex(direction);
                if (index >= 0)
                    selectTab(index, false);
                return true;
            }
        }
        return super.onKeyEvent(event);
    }

    @property const(TabItem) selectedTab() const {
        return _tabControl.tab(selectedTabId);
    }

    @property TabItem selectedTab() {
        return _tabControl.tab(selectedTabId);
    }

    @property string selectedTabId() const {
        return _tabControl._selectedTabId;
    }

    /// focus selected tab body
    void focusSelectedTab() {
        if (!visible)
            return;
        Widget w = selectedTabBody;
        if (w)
            w.setFocus();
    }

    /// get tab content widget by id
    @property Widget selectedTabBody() {
        return _tabHost.tabBody(_tabControl._selectedTabId);
    }

}
