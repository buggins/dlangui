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
import dlangui.widgets.layouts;
import dlangui.widgets.controls;

interface TabHandler {
    void onTabChanged(string newActiveTabId, string previousTabId);
}

/// tab item metadata
class TabItem {
    private string _iconRes;
    private string _id;
    private UIString _label;
    private long _lastAccessTs;
    this(string id, string labelRes, string iconRes = null) {
        _id = id;
        _label = labelRes;
        _iconRes = iconRes;
    }
    this(string id, dstring labelRes, string iconRes = null) {
        _id = id;
        _label = labelRes;
        _iconRes = iconRes;
        _lastAccessTs = std.datetime.Clock.currStdTime;
    }
    @property string iconId() const { return _iconRes; }
    @property string id() const { return _id; }
    @property ref UIString text() { return _label; }
    @property TabItem iconId(string id) { _iconRes = id; return this; }
    @property TabItem id(string  id) { _id = id; return this; }
    @property long lastAccessTs() { return _lastAccessTs; }
    @property void lastAccessTs(long ts) { _lastAccessTs = ts; }
    void updateAccessTs() { _lastAccessTs = std.datetime.Clock.currStdTime; }
}

/// tab item widget - to show tab header
class TabItemWidget : HorizontalLayout {
    private ImageWidget _icon;
    private TextWidget _label;
    private ImageButton _closeButton;
    private TabItem _item;
    private bool _enableCloseButton;
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
        _closeButton.onClickListener = &onClick;
        if (_enableCloseButton) {
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
    }
    protected bool onClick(Widget source) {
        if (source.compareId("CLOSE")) {
            Log.d("tab close button pressed");
        }
        return true;
    }
    protected void setItem(TabItem item) {
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
    /// get item by id
    TabItem get(string id) {
        int idx = indexById(id);
        if (idx < 0)
            return null;
        return _list[idx];
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
    int indexById(string id) {
        import std.algorithm;
        for (int i = 0; i < _len; i++) {
            if (_list[i].id.equal(id))
                return i;
        }
        return -1;
    }
}

/// tab header - tab labels, with optional More button
class TabControl : WidgetGroup {
    protected TabItemList _items;
    protected ImageButton _moreButton;
    protected bool _enableCloseButton;
    protected TabItemWidget[] _sortedItems;


	/// signal of tab change (e.g. by clicking on tab header)
	Signal!TabHandler onTabChangedListener;

    /// empty parameter list constructor - for usage by factory
    this() {
        this(null);
    }
    /// create with ID parameter
    this(string ID) {
        super(ID);
        _items = new TabItemList();
        _moreButton = new ImageButton("MORE", "tab_more");
        _moreButton.styleId = STYLE_BUTTON_TRANSPARENT;
        _moreButton.onClickListener = &onClick;
        _moreButton.margins(Rect(3,3,3,6));
        _enableCloseButton = true;
        styleId = STYLE_TAB_UP;
        addChild(_moreButton); // first child is always MORE button, the rest corresponds to tab list
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
    /// remove tab
    TabControl removeTab(string id) {
        int index = _items.indexById(id);
        if (index >= 0) {
            _children.remove(index + 1);
            _items.remove(index);
            requestLayout();
        }
        return this;
    }
    /// add new tab
    TabControl addTab(TabItem item, int index = -1, bool enableCloseButton = false) {
        _items.insert(item, index);
        TabItemWidget widget = new TabItemWidget(item, enableCloseButton);
        widget.parent = this;
        widget.onClickListener = &onClick;
        _children.insert(widget, index);
        updateTabs();
        requestLayout();
        return this;
    }
    /// add new tab by id and label string
    TabControl addTab(string id, dstring label, string iconId = null, bool enableCloseButton = false) {
        TabItem item = new TabItem(id, label, iconId);
        return addTab(item, -1, enableCloseButton);
    }
    /// add new tab by id and label string resource id
    TabControl addTab(string id, string labelResourceId, string iconId = null, bool enableCloseButton = false) {
        TabItem item = new TabItem(id, labelResourceId, iconId);
        return addTab(item, -1, enableCloseButton);
    }
    protected bool onClick(Widget source) {
        if (source.compareId("MORE")) {
            Log.d("tab MORE button pressed");
            return true;
        }
        string id = source.id;
        int index = tabIndex(id);
        if (index >= 0) {
            selectTab(index);
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
        _moreButton.measure(pwidth, pheight);
        sz.x = _moreButton.measuredWidth;
        sz.y = _moreButton.measuredHeight;
        pwidth -= sz.x;
        for (int i = 1; i < _children.count; i++) {
            Widget tab = _children.get(i);
            tab.visibility = Visibility.Visible;
            tab.measure(pwidth, pheight);
            if (sz.y < tab.measuredHeight)
                sz.y = tab.measuredHeight;
            if (sz.x + tab.measuredWidth > pwidth)
                break;
            sz.x += tab.measuredWidth;
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
        moreRc.left = rc.right - _moreButton.measuredWidth;
        _moreButton.layout(moreRc);
        rc.right -= _moreButton.measuredWidth;
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
                w += widget.measuredWidth;
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
            rc.left += w;
        }
        //Log.d("tabControl.layout exit");
    }
    /// Draw widget at its position to buffer
    override void onDraw(DrawBuf buf) {
        //Log.d("tabControl.onDraw enter");
        if (visibility != Visibility.Visible)
            return;
        super.onDraw(buf);
        Rect rc = _pos;
        applyMargins(rc);
        applyPadding(rc);
        auto saver = ClipRectSaver(buf, rc);
		for (int i = 0; i < _children.count; i++) {
			Widget item = _children.get(i);
			if (item.visibility != Visibility.Visible)
				continue;
			item.onDraw(buf);
		}
        //Log.d("tabControl.onDraw exit");
    }

    protected string _selectedTabId;

    void selectTab(int index) {
        if (_children.get(index + 1).compareId(_selectedTabId))
            return; // already selected
        string previousSelectedTab = _selectedTabId;
		for (int i = 1; i < _children.count; i++) {
            if (index == i - 1) {
                _children.get(i).state = State.Selected;
                _selectedTabId = _children.get(i).id;
            } else {
                _children.get(i).state = State.Normal;
            }
        }
        if (onTabChangedListener.assigned)
			onTabChangedListener(_selectedTabId, previousSelectedTab);
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
            _tabControl.onTabChangedListener = &onTabChanged;
        styleId = STYLE_TAB_HOST;
    }
    protected TabControl _tabControl;
    /// get currently set control widget
    @property TabControl tabControl() { return _tabControl; }
    /// set new control widget
    @property TabHost tabControl(TabControl newWidget) { 
        _tabControl = newWidget; 
        if (_tabControl !is null)
            _tabControl.onTabChangedListener = &onTabChanged;
        return this;
    }

	/// signal of tab change (e.g. by clicking on tab header)
	Signal!TabHandler onTabChangedListener;

    protected override void onTabChanged(string newActiveTabId, string previousTabId) {
        if (newActiveTabId !is null) {
            showChild(newActiveTabId, Visibility.Invisible, true);
        }
        if (onTabChangedListener.assigned)
            onTabChangedListener(newActiveTabId, previousTabId);
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
    TabHost addTab(Widget widget, dstring label, string iconId = null, bool enableCloseButton = false) {
        assert(_tabControl !is null, "No TabControl set for TabHost");
        assert(widget.id !is null, "ID for tab host page is mandatory");
        assert(_children.indexOf(id) == -1, "duplicate ID for tab host page");
        _tabControl.addTab(widget.id, label, iconId, enableCloseButton);
        widget.focusGroup = true; // doesn't allow move focus outside of tab content
        addChild(widget);
        return this;
    }
    /// add new tab by id and label string resource id
    TabHost addTab(Widget widget, string labelResourceId, string iconId = null, bool enableCloseButton = false) {
        assert(_tabControl !is null, "No TabControl set for TabHost");
        assert(widget.id !is null, "ID for tab host page is mandatory");
        assert(_children.indexOf(id) == -1, "duplicate ID for tab host page");
        _tabControl.addTab(widget.id, labelResourceId, iconId, enableCloseButton);
        addChild(widget);
        return this;
    }
    /// select tab
    void selectTab(string ID) {
        int index = _tabControl.tabIndex(ID);
        if (index != -1) {
            _tabControl.selectTab(index);
        }
    }
//    /// request relayout of widget and its children
//    override void requestLayout() {
//		Log.d("TabHost.requestLayout called");
//		super.requestLayout();
//        //_needLayout = true;
//    }
//    /// Set widget rectangle to specified value and layout widget contents. (Step 2 of two phase layout).
//    override void layout(Rect rc) {
//		Log.d("TabHost.layout() called");
//		super.layout(rc);
//		Log.d("after layout(): needLayout = ", needLayout);
//	}

}

/// compound widget - contains from TabControl widget (tabs header) and TabHost (content pages)
class TabWidget : VerticalLayout, TabHandler {
    protected TabControl _tabControl;
    protected TabHost _tabHost;
    /// empty parameter list constructor - for usage by factory
    this() {
        this(null);
    }
    /// create with ID parameter
    this(string ID) {
        super(ID);
        _tabControl = new TabControl("TAB_CONTROL");
        _tabHost = new TabHost("TAB_HOST", _tabControl);
		_tabControl.onTabChangedListener.connect(this);
        styleId = STYLE_TAB_WIDGET;
        addChild(_tabControl);
        addChild(_tabHost);
    }

	/// signal of tab change (e.g. by clicking on tab header)
	Signal!TabHandler onTabChangedListener;

    protected override void onTabChanged(string newActiveTabId, string previousTabId) {
        // forward to listener
        if (onTabChangedListener.assigned)
            onTabChangedListener(newActiveTabId, previousTabId);
    }

    /// add new tab by id and label string resource id
    TabWidget addTab(Widget widget, string labelResourceId, string iconId = null, bool enableCloseButton = false) {
        _tabHost.addTab(widget, labelResourceId, iconId, enableCloseButton);
        return this;
    }

	/// add new tab by id and label (raw value)
    TabWidget addTab(Widget widget, dstring label, string iconId = null, bool enableCloseButton = false) {
        _tabHost.addTab(widget, label, iconId, enableCloseButton);
        return this;
    }

	/// remove tab by id
    TabWidget removeTab(string id) {
        _tabHost.removeTab(id);
        requestLayout();
        return this;
    }

	/// select tab
    void selectTab(string ID) {
        _tabHost.selectTab(ID);
    }

	/// returns tab item by id (null if index out of range)
	TabItem tab(int index) {
		return _tabControl.tab(index);
	}
	/// returns tab item by id (null if not found)
	TabItem tab(string id) {
		return _tabControl.tab(id);
	}
	/// get tab index by tab id (-1 if not found)
	int tabIndex(string id) {
		return _tabControl.tabIndex(id);
	}
}
