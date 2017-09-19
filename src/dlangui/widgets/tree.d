// Written in the D programming language.

/**

This module contains tree widgets implementation


TreeWidgetBase - abstract tree widget

TreeWidget - Tree widget with items which can have icons and labels


Synopsis:

----
import dlangui.widgets.tree;

// tree view example
TreeWidget tree = new TreeWidget("TREE1");
tree.layoutWidth(WRAP_CONTENT).layoutHeight(FILL_PARENT);
TreeItem tree1 = tree.items.newChild("group1", "Group 1"d, "document-open");
tree1.newChild("g1_1", "Group 1 item 1"d);
tree1.newChild("g1_2", "Group 1 item 2"d);
tree1.newChild("g1_3", "Group 1 item 3"d);
TreeItem tree2 = tree.items.newChild("group2", "Group 2"d, "document-save");
tree2.newChild("g2_1", "Group 2 item 1"d, "edit-copy");
tree2.newChild("g2_2", "Group 2 item 2"d, "edit-cut");
tree2.newChild("g2_3", "Group 2 item 3"d, "edit-paste");
tree2.newChild("g2_4", "Group 2 item 4"d);
TreeItem tree3 = tree.items.newChild("group3", "Group 3"d);
tree3.newChild("g3_1", "Group 3 item 1"d);
tree3.newChild("g3_2", "Group 3 item 2"d);
TreeItem tree32 = tree3.newChild("g3_3", "Group 3 item 3"d);
tree3.newChild("g3_4", "Group 3 item 4"d);
tree32.newChild("group3_2_1", "Group 3 item 2 subitem 1"d);
tree32.newChild("group3_2_2", "Group 3 item 2 subitem 2"d);
tree32.newChild("group3_2_3", "Group 3 item 2 subitem 3"d);
tree32.newChild("group3_2_4", "Group 3 item 2 subitem 4"d);
tree32.newChild("group3_2_5", "Group 3 item 2 subitem 5"d);
tree3.newChild("g3_5", "Group 3 item 5"d);
tree3.newChild("g3_6", "Group 3 item 6"d);

LinearLayout treeLayout = new HorizontalLayout("TREE");
LinearLayout treeControlledPanel = new VerticalLayout();
treeLayout.layoutWidth = FILL_PARENT;
treeControlledPanel.layoutWidth = FILL_PARENT;
treeControlledPanel.layoutHeight = FILL_PARENT;
TextWidget treeItemLabel = new TextWidget("TREE_ITEM_DESC");
treeItemLabel.layoutWidth = FILL_PARENT;
treeItemLabel.layoutHeight = FILL_PARENT;
treeItemLabel.alignment = Align.Center;
treeItemLabel.text = "Sample text"d;
treeControlledPanel.addChild(treeItemLabel);
treeLayout.addChild(tree);
treeLayout.addChild(new ResizerWidget());
treeLayout.addChild(treeControlledPanel);

tree.selectionListener = delegate(TreeItems source, TreeItem selectedItem, bool activated) {
    dstring label = "Selected item: "d ~ toUTF32(selectedItem.id) ~ (activated ? " selected + activated"d : " selected"d);
    treeItemLabel.text = label;
};

tree.items.selectItem(tree.items.child(0));
----

Copyright: Vadim Lopatin, 2014
License:   Boost License 1.0
Authors:   Vadim Lopatin, coolreader.org@gmail.com
*/
module dlangui.widgets.tree;

import dlangui.widgets.widget;
import dlangui.widgets.controls;
import dlangui.widgets.scroll;
import dlangui.widgets.menu;
import dlangui.widgets.popup;
import dlangui.widgets.layouts;
import std.conv;
import std.algorithm;

// tree widget item data container
class TreeItem {
    protected TreeItem _parent;
    protected string _id;
    protected string _iconRes;
    protected int _level;
    protected UIString _text;
    protected ObjectList!TreeItem _children;
    protected bool _expanded;

    this(string id) {
        _id = id;
        _expanded = true;
    }
    this(string id, dstring label, string iconRes = null) {
        _id = id;
        _expanded = true;
        _iconRes = iconRes;
        _text.value = label;
    }
    this(string id, UIString label, string iconRes = null) {
        _id = id;
        _expanded = true;
        _iconRes = iconRes;
        _text = label;
    }
    this(string id, string labelRes, string iconRes = null) {
        _id = id;
        _expanded = true;
        _iconRes = iconRes;
        _text.id = labelRes;
    }
    /// create and add new child item
    TreeItem newChild(string id, dstring label, string iconRes = null) {
        TreeItem res = new TreeItem(id, label, iconRes);
        addChild(res);
        return res;
    }

    /// returns true if item supports collapse
    @property bool canCollapse() {
        if (auto r = root) {
            return r.canCollapse(this);
        }
        return true;
    }

    /// returns topmost item
    @property TreeItems root() {
        TreeItem p = this;
        while (p._parent)
            p = p._parent;
        return cast(TreeItems)p;
    }

    /// returns true if this item is root item
    @property bool isRoot() {
        return false;
    }

    void clear() {
        foreach(c; _children) {
            c.parent = null;
            if(c is root.selectedItem)
                root.selectItem(null);
        }
        _children.clear();
        root.onUpdate(this);
    }

    @property TreeItem parent() { return _parent; }
    @property protected TreeItem parent(TreeItem p) { _parent = p; return this; }
    @property string id() { return _id; }
    @property TreeItem id(string id) { _id = id; return this; }
    @property string iconRes() { return _iconRes; }
    @property TreeItem iconRes(string res) { _iconRes = res; return this; }
    @property int level() { return _level; }
    @property protected TreeItem level(int level) {
        _level = level;
        for (int i = 0; i < childCount; i++)
            child(i).level = _level + 1;
        return this;
    }
    @property bool expanded() { return _expanded; }
    @property protected TreeItem expanded(bool expanded) { _expanded = expanded; return this; }
    /** Returns true if this item and all parents are expanded. */
    bool isFullyExpanded() {
        if (!_expanded)
            return false;
        if (!_parent)
            return true;
        return _parent.isFullyExpanded();
    }
    /** Returns true if all parents are expanded. */
    bool isVisible() {
        if (_parent)
            return _parent.isFullyExpanded();
        return false;
    }
    void expand() {
        _expanded = true;
        if (_parent)
            _parent.expand();
    }
    void collapse() {
        _expanded = false;
    }
    /// expand this node and all children
    void expandAll() {
        foreach(c; _children) {
            if (!c._expanded && c.canCollapse) //?
                c.expandAll();
        }
        if (!expanded)
            toggleExpand(this);
    }
    /// expand this node and all children
    void collapseAll() {
        foreach(c; _children) {
            if (c._expanded && c.canCollapse)
                c.collapseAll();
        }
        if (expanded)
            toggleExpand(this);
    }

    @property TreeItem selectedItem() {
        return root.selectedItem();
    }

    @property TreeItem defaultItem() {
        return root.defaultItem();
    }

    @property bool isSelected() {
        return (selectedItem is this);
    }

    @property bool isDefault() {
        return (defaultItem is this);
    }

    /// get widget text
    @property dstring text() { return _text; }
    /// set text to show
    @property TreeItem text(dstring s) {
        _text = s;
        return this;
    }
    /// set text to show
    @property TreeItem text(UIString s) {
        _text = s;
        return this;
    }
    /// set text resource ID to show
    @property TreeItem textResource(string s) {
        _text = s;
        return this;
    }

    bool compareId(string id) {
        return _id !is null && _id.equal(id);
    }

    @property TreeItem topParent() {
        if (!_parent)
            return this;
        return _parent.topParent;
    }


    protected int _intParam;
    @property int intParam() {
        return _intParam;
    }
    @property TreeItem intParam(int value) {
        _intParam = value;
        return this;
    }

    protected Object _objectParam;
    @property Object objectParam() {
        return _objectParam;
    }

    @property TreeItem objectParam(Object value) {
        _objectParam = value;
        return this;
    }


    /// returns true if item has at least one child
    @property bool hasChildren() { return childCount > 0; }

    /// returns number of children of this widget
    @property int childCount() { return _children.count; }
    /// returns child by index
    TreeItem child(int index) { return _children.get(index); }
    /// adds child, returns added item
    TreeItem addChild(TreeItem item, int index = -1) {
        TreeItem res = _children.insert(item, index).parent(this).level(_level + 1);
        root.onUpdate(res);
        return res;
    }
    /// removes child, returns removed item
    TreeItem removeChild(int index) {
        if (index < 0 || index >= _children.count)
            return null;
        TreeItem res = _children.remove(index);
        TreeItem newSelection = null;
        if (res !is null) {
            res.parent = null;
            if (root && root.selectedItem is res) {
                if (index < _children.count)
                    newSelection = _children[index];
                else if (index > 0)
                    newSelection = _children[index - 1];
                else
                    newSelection = this;
            }
        }
        root.selectItem(newSelection);
        root.onUpdate(this);
        return res;
    }
    /// removes child by reference, returns removed item
    TreeItem removeChild(TreeItem child) {
        TreeItem res = null;
        int index = _children.indexOf(child);
        return removeChild(index);
    }
    /// removes child by ID, returns removed item
    TreeItem removeChild(string ID) {
        TreeItem res = null;
        int index = _children.indexOf(ID);
        return removeChild(index);
    }
    /// returns index of widget in child list, -1 if passed widget is not a child of this widget
    int childIndex(TreeItem item) { return _children.indexOf(item); }
    /// notify listeners
    protected void onUpdate(TreeItem item) {
        if (root)
            root.onUpdate(item);
    }
    protected void toggleExpand(TreeItem item) {
        root.toggleExpand(item);
    }
    protected void selectItem(TreeItem item) {
        root.selectItem(item);
    }
    protected void activateItem(TreeItem item) {
        root.activateItem(item);
    }

    protected TreeItem nextVisible(TreeItem item, ref bool found) {
        if (this is item)
            found = true;
        else if (found && isVisible)
            return this;
        for (int i = 0; i < childCount; i++) {
            TreeItem res = child(i).nextVisible(item, found);
            if (res)
                return res;
        }
        return null;
    }

    protected TreeItem prevVisible(TreeItem item, ref TreeItem prevFoundVisible) {
        if (this is item)
            return prevFoundVisible;
        else if (isVisible)
            prevFoundVisible = this;
        for (int i = 0; i < childCount; i++) {
            TreeItem res = child(i).prevVisible(item, prevFoundVisible);
            if (res)
                return res;
        }
        return null;
    }

    /// returns item by id, null if not found
    TreeItem findItemById(string id) {
        if (_id.equal(id))
            return this;
        for (int i = 0; i < childCount; i++) {
            TreeItem res = child(i).findItemById(id);
            if (res)
                return res;
        }
        return null;
    }
}

interface OnTreeContentChangeListener {
    void onTreeContentChange(TreeItems source);
}

interface OnTreeStateChangeListener {
    void onTreeStateChange(TreeItems source);
}

interface OnTreeExpandedStateListener {
    void onTreeExpandedStateChange(TreeItems source, TreeItem item);
}

interface OnTreeSelectionChangeListener {
    void onTreeItemSelected(TreeItems source, TreeItem selectedItem, bool activated);
}

class TreeItems : TreeItem {
    // signal handler OnTreeContentChangeListener
    Listener!OnTreeContentChangeListener contentListener;
    Listener!OnTreeStateChangeListener stateListener;
    Listener!OnTreeSelectionChangeListener selectionListener;
    Listener!OnTreeExpandedStateListener expandListener;

    protected bool _noCollapseForSingleTopLevelItem;
    @property bool noCollapseForSingleTopLevelItem() { return _noCollapseForSingleTopLevelItem; }
    @property TreeItems noCollapseForSingleTopLevelItem(bool flg) { _noCollapseForSingleTopLevelItem = flg; return this; }

    protected TreeItem _selectedItem;
    protected TreeItem _defaultItem;

    this() {
        super("tree");
    }

    /// returns true if this item is root item
    override @property bool isRoot() {
        return true;
    }

    /// notify listeners
    override protected void onUpdate(TreeItem item) {
        if (contentListener.assigned)
            contentListener(this);
    }

    bool canCollapse(TreeItem item) {
        if (!_noCollapseForSingleTopLevelItem)
            return true;
        if (!hasChildren)
            return false;
        if (_children.count == 1 && _children[0] is item)
            return false;
        return true;
    }

    bool canCollapseTopLevel() {
        if (!_noCollapseForSingleTopLevelItem)
            return true;
        if (!hasChildren)
            return false;
        if (_children.count == 1)
            return false;
        return true;
    }

    override void toggleExpand(TreeItem item) {
        bool expandChanged = false;
        if (item.expanded) {
            if (item.canCollapse()) {
                item.collapse();
                expandChanged = true;
            }
        } else {
            item.expand();
            expandChanged = true;
        }
        if (stateListener.assigned)
            stateListener(this);
        if (expandChanged && expandListener.assigned)
            expandListener(this, item);
    }

    override void selectItem(TreeItem item) {
        if (_selectedItem is item)
            return;
        _selectedItem = item;
        if (stateListener.assigned)
            stateListener(this);
        if (selectionListener.assigned)
            selectionListener(this, _selectedItem, false);
    }

    void setDefaultItem(TreeItem item) {
        _defaultItem = item;
        if (stateListener.assigned)
            stateListener(this);
    }

    override void activateItem(TreeItem item) {
        if (!(_selectedItem is item)) {
            _selectedItem = item;
            if (stateListener.assigned)
                stateListener(this);
        }
        if (selectionListener.assigned)
            selectionListener(this, _selectedItem, true);
    }

    @property override TreeItem selectedItem() {
        return _selectedItem;
    }

    @property override TreeItem defaultItem() {
        return _defaultItem;
    }

    void selectNext() {
        if (!hasChildren)
            return;
        if (!_selectedItem)
            selectItem(child(0));
        bool found = false;
        TreeItem next = nextVisible(_selectedItem, found);
        if (next)
            selectItem(next);
    }

    void selectPrevious() {
        if (!hasChildren)
            return;
        TreeItem found = null;
        TreeItem prev = prevVisible(_selectedItem, found);
        if (prev)
            selectItem(prev);
    }
}

/// grid control action codes
enum TreeActions : int {
    /// no action
    None = 0,
    /// move selection up
    Up = 2000,
    /// move selection down
    Down,
    /// move selection left
    Left,
    /// move selection right
    Right,

    /// scroll up, w/o changing selection
    ScrollUp,
    /// scroll down, w/o changing selection
    ScrollDown,
    /// scroll left, w/o changing selection
    ScrollLeft,
    /// scroll right, w/o changing selection
    ScrollRight,

    /// scroll top w/o changing selection
    ScrollTop,
    /// scroll bottom, w/o changing selection
    ScrollBottom,

    /// scroll up, w/o changing selection
    ScrollPageUp,
    /// scroll down, w/o changing selection
    ScrollPageDown,
    /// scroll left, w/o changing selection
    ScrollPageLeft,
    /// scroll right, w/o changing selection
    ScrollPageRight,

    /// move cursor one page up
    PageUp,
    /// move cursor one page up with selection
    SelectPageUp,
    /// move cursor one page down
    PageDown,
    /// move cursor one page down with selection
    SelectPageDown,
    /// move cursor to the beginning of page
    PageBegin,
    /// move cursor to the beginning of page with selection
    SelectPageBegin,
    /// move cursor to the end of page
    PageEnd,
    /// move cursor to the end of page with selection
    SelectPageEnd,
    /// move cursor to the beginning of line
    LineBegin,
    /// move cursor to the beginning of line with selection
    SelectLineBegin,
    /// move cursor to the end of line
    LineEnd,
    /// move cursor to the end of line with selection
    SelectLineEnd,
    /// move cursor to the beginning of document
    DocumentBegin,
    /// move cursor to the beginning of document with selection
    SelectDocumentBegin,
    /// move cursor to the end of document
    DocumentEnd,
    /// move cursor to the end of document with selection
    SelectDocumentEnd,
}


const int DOUBLE_CLICK_TIME_MS = 250;

interface OnTreePopupMenuListener {
    MenuItem onTreeItemPopupMenu(TreeItems source, TreeItem selectedItem);
}

/// Item widget for displaying in trees
class TreeItemWidget : HorizontalLayout {
    TreeItem _item;
    TextWidget _tab;
    ImageWidget _expander;
    ImageWidget _icon;
    TextWidget _label;
    HorizontalLayout _body;
    long lastClickTime;

    Listener!OnTreePopupMenuListener popupMenuListener;

    @property TreeItem item() { return _item; }


    this(TreeItem item) {
        super(item.id);
        styleId = STYLE_TREE_ITEM;

        clickable = true;
        focusable = true;
        trackHover = true;

        _item = item;
        _tab = new TextWidget("tab");
        //dchar[] tabText;
        //dchar[] singleTab = [' ', ' ', ' ', ' '];
        //for (int i = 1; i < _item.level; i++)
        //    tabText ~= singleTab;
        //_tab.text = cast(dstring)tabText;
        int level = _item.level - 1;
        if (!_item.root.canCollapseTopLevel())
            level--;
        if (level < 0)
            level = 0;
        int w = level * style.font.size * 3 / 4;
        _tab.minWidth = w;
        _tab.maxWidth = w;
        if (_item.canCollapse()) {
            _expander = new ImageWidget("expander", _item.hasChildren && _item.expanded ? "arrow_right_down_black" : "arrow_right_hollow");
            _expander.styleId = STYLE_TREE_ITEM_EXPAND_ICON;
            _expander.clickable = true;
            _expander.trackHover = true;
            _expander.visibility = _item.hasChildren ? Visibility.Visible : Visibility.Invisible;
            //_expander.setState(State.Parent);

            _expander.click = delegate(Widget source) {
                _item.selectItem(_item);
                _item.toggleExpand(_item);
                return true;
            };
        }
        click = delegate(Widget source) {
            long ts = currentTimeMillis();
            _item.selectItem(_item);
            if (ts - lastClickTime < DOUBLE_CLICK_TIME_MS) {
                if (_item.hasChildren) {
                    _item.toggleExpand(_item);
                } else {
                    _item.activateItem(_item);
                }
            }
            lastClickTime = ts;
            return true;
        };
        _body = new HorizontalLayout("item_body");
        _body.styleId = STYLE_TREE_ITEM_BODY;
        _body.setState(State.Parent);
        if (_item.iconRes.length > 0) {
            _icon = new ImageWidget("icon", _item.iconRes);
            _icon.styleId = STYLE_TREE_ITEM_ICON;
            _icon.setState(State.Parent);
            _icon.padding(Rect(0, 0, BACKEND_GUI ? 5 : 0, 0));
            _body.addChild(_icon);
        }
        _label = new TextWidget("label", _item.text);
        _label.styleId = STYLE_TREE_ITEM_LABEL;
        _label.setState(State.Parent);
        _body.addChild(_label);
        // append children
        addChild(_tab);
        if (_expander)
            addChild(_expander);
        addChild(_body);
    }

    override bool onKeyEvent(KeyEvent event) {
        if (keyEvent.assigned && keyEvent(this, event))
            return true; // processed by external handler
        if (!focused || !visible)
            return false;
        if (event.action != KeyAction.KeyDown)
            return false;
        int action = 0;
        switch (event.keyCode) with(KeyCode) {
            case SPACE:
            case RETURN:
                if (_item.hasChildren)
                    _item.toggleExpand(_item);
                else
                    _item.activateItem(_item);
                return true;
            default:
                break;
        }
        return false;
    }

    /// process mouse event; return true if event is processed by widget.
    override bool onMouseEvent(MouseEvent event) {
        if (event.action == MouseAction.ButtonDown && event.button == MouseButton.Right) {
            if (popupMenuListener.assigned) {
                MenuItem menu = popupMenuListener(_item.root, _item);
                if (menu) {
                    PopupMenu popupMenu = new PopupMenu(menu);
                    PopupWidget popup = window.showPopup(popupMenu, this, PopupAlign.Point | PopupAlign.Right, event.x, event.y);
                    popup.flags = PopupFlags.CloseOnClickOutside;
                    return true;
                }
            }
        }
        return super.onMouseEvent(event);
    }

    void updateWidget() {
        if (_expander) {
            _expander.drawable = _item.expanded ? "arrow_right_down_black" : "arrow_right_hollow";
        }
        if (_item.isVisible)
            visibility = Visibility.Visible;
        else
            visibility = Visibility.Gone;
        if (_item.isSelected)
            setState(State.Selected);
        else
            resetState(State.Selected);
        if (_item.isDefault)
            setState(State.Default);
        else
            resetState(State.Default);
    }
}



/// Abstract tree widget
class TreeWidgetBase :  ScrollWidget, OnTreeContentChangeListener, OnTreeStateChangeListener, OnTreeSelectionChangeListener, OnTreeExpandedStateListener, OnKeyHandler {

    protected TreeItems _tree;

    @property ref TreeItems items() { return _tree; }

    Signal!OnTreeSelectionChangeListener selectionChange;
    Signal!OnTreeExpandedStateListener expandedChange;
    /// allows to provide individual popup menu for items
    Listener!OnTreePopupMenuListener popupMenu;

    protected bool _needUpdateWidgets;
    protected bool _needUpdateWidgetStates;

    protected bool _noCollapseForSingleTopLevelItem;
    @property bool noCollapseForSingleTopLevelItem() {
        return _noCollapseForSingleTopLevelItem;
    }
    @property TreeWidgetBase noCollapseForSingleTopLevelItem(bool flg) {
        _noCollapseForSingleTopLevelItem = flg;
        if (_tree)
            _tree.noCollapseForSingleTopLevelItem = flg;
        return this;
    }

    protected MenuItem onTreeItemPopupMenu(TreeItems source, TreeItem selectedItem) {
        if (popupMenu)
            return popupMenu(source, selectedItem);
        return null;
    }

    /// empty parameter list constructor - for usage by factory
    this() {
        this(null);
    }
    /// create with ID parameter
    this(string ID, ScrollBarMode hscrollbarMode = ScrollBarMode.Visible, ScrollBarMode vscrollbarMode = ScrollBarMode.Visible) {
        super(ID, hscrollbarMode, vscrollbarMode);
        contentWidget = new VerticalLayout("TREE_CONTENT");
        _tree = new TreeItems();
        _tree.contentListener = this;
        _tree.stateListener = this;
        _tree.selectionListener = this;
        _tree.expandListener = this;

        _needUpdateWidgets = true;
        _needUpdateWidgetStates = true;
        acceleratorMap.add( [
            new Action(TreeActions.Up, KeyCode.UP, 0),
            new Action(TreeActions.Down, KeyCode.DOWN, 0),
            new Action(TreeActions.ScrollLeft, KeyCode.LEFT, 0),
            new Action(TreeActions.ScrollRight, KeyCode.RIGHT, 0),
            //new Action(TreeActions.LineBegin, KeyCode.HOME, 0),
            //new Action(TreeActions.LineEnd, KeyCode.END, 0),
            new Action(TreeActions.PageUp, KeyCode.PAGEUP, 0),
            new Action(TreeActions.PageDown, KeyCode.PAGEDOWN, 0),
            //new Action(TreeActions.PageBegin, KeyCode.PAGEUP, KeyFlag.Control),
            //new Action(TreeActions.PageEnd, KeyCode.PAGEDOWN, KeyFlag.Control),
            new Action(TreeActions.ScrollTop, KeyCode.HOME, KeyFlag.Control),
            new Action(TreeActions.ScrollBottom, KeyCode.END, KeyFlag.Control),
            new Action(TreeActions.ScrollPageUp, KeyCode.PAGEUP, KeyFlag.Control),
            new Action(TreeActions.ScrollPageDown, KeyCode.PAGEDOWN, KeyFlag.Control),
            new Action(TreeActions.ScrollUp, KeyCode.UP, KeyFlag.Control),
            new Action(TreeActions.ScrollDown, KeyCode.DOWN, KeyFlag.Control),
            new Action(TreeActions.ScrollLeft, KeyCode.LEFT, KeyFlag.Control),
            new Action(TreeActions.ScrollRight, KeyCode.RIGHT, KeyFlag.Control),
        ]);
    }

    ~this() {
        if (_tree) {
            destroy(_tree);
            _tree = null;
        }
    }

    /** Override to use custom tree item widgets. */
    protected Widget createItemWidget(TreeItem item) {
        TreeItemWidget res = new TreeItemWidget(item);
        res.keyEvent = this;
        res.popupMenuListener = &onTreeItemPopupMenu;
        return res;
    }

    /// returns item by id, null if not found
    TreeItem findItemById(string id) {
        return _tree.findItemById(id);
    }

    override bool onKey(Widget source, KeyEvent event) {
        if (event.action == KeyAction.KeyDown) {
            Action action = findKeyAction(event.keyCode, event.flags); // & (KeyFlag.Shift | KeyFlag.Alt | KeyFlag.Control)
            if (action !is null) {
                return handleAction(action);
            }
        }
        return false;
    }

    protected void addWidgets(TreeItem item) {
        if (item.level > 0)
            _contentWidget.addChild(createItemWidget(item));
        for (int i = 0; i < item.childCount; i++)
            addWidgets(item.child(i));
    }

    protected void updateWidgets() {
        _contentWidget.removeAllChildren();
        addWidgets(_tree);
        _needUpdateWidgets = false;
    }

    void clearAllItems() {
        items.clear();
        updateWidgets();
        requestLayout();
    }

    protected void updateWidgetStates() {
        for (int i = 0; i < _contentWidget.childCount; i++) {
            TreeItemWidget child = cast(TreeItemWidget)_contentWidget.child(i);
            if (child)
                child.updateWidget();
        }
        _needUpdateWidgetStates = false;
    }

    /// Set widget rectangle to specified value and layout widget contents. (Step 2 of two phase layout).
    override void layout(Rect rc) {
        if (visibility == Visibility.Gone) {
            return;
        }
        if (_needUpdateWidgets)
            updateWidgets();
        if (_needUpdateWidgetStates)
            updateWidgetStates();
        super.layout(rc);
    }

    override Point minimumVisibleContentSize() {
        return Point(100.pointsToPixels, 100.pointsToPixels);
    }

    /// calculate full content size in pixels
    override Point fullContentSize() {
        if (_needUpdateWidgets)
            updateWidgets();
        if (_needUpdateWidgetStates)
            updateWidgetStates();
        return super.fullContentSize();
        //_contentWidget.measure(SIZE_UNSPECIFIED, SIZE_UNSPECIFIED);
        //return Point(_contentWidget.measuredWidth,_contentWidget.measuredHeight);
    }

    /// Measure widget according to desired width and height constraints. (Step 1 of two phase layout).
    override void measure(int parentWidth, int parentHeight) {
        if (visibility == Visibility.Gone) {
            return;
        }
        if (_needUpdateWidgets)
            updateWidgets();
        if (_needUpdateWidgetStates)
            updateWidgetStates();
        super.measure(parentWidth, parentHeight);
    }

    /// listener
    override void onTreeContentChange(TreeItems source) {
        _needUpdateWidgets = true;
        requestLayout();
        //updateScrollBars();
    }

    override void onTreeStateChange(TreeItems source) {
        _needUpdateWidgetStates = true;
        requestLayout();
        //updateScrollBars();
    }

    override void onTreeExpandedStateChange(TreeItems source, TreeItem item) {
        if (expandedChange.assigned)
            expandedChange(source, item);
        layout(pos);
        //requestLayout();
        //updateScrollBars();
    }

    TreeItemWidget findItemWidget(TreeItem item) {
        for (int i = 0; i < _contentWidget.childCount; i++) {
            TreeItemWidget child = cast(TreeItemWidget) _contentWidget.child(i);
            if (child && child.item is item)
                return child;
        }
        return null;
    }

    override void onTreeItemSelected(TreeItems source, TreeItem selectedItem, bool activated) {
        TreeItemWidget selected = findItemWidget(selectedItem);
        if (selected && selected.visibility == Visibility.Visible) {
            selected.setFocus();
            makeWidgetVisible(selected, false, true);
        }
        if (selectionChange.assigned)
            selectionChange(source, selectedItem, activated);
    }

    void makeItemVisible(TreeItem item) {
        TreeItemWidget widget = findItemWidget(item);
        if (widget && widget.visibility == Visibility.Visible) {
            makeWidgetVisible(widget, false, true);
        }
    }

    void clearSelection() {
        _tree.selectItem(null);
    }

    void selectItem(TreeItem item, bool makeVisible = true) {
        if (!item) {
            clearSelection();
            return;
        }
        _tree.selectItem(item);
        if (makeVisible)
            makeItemVisible(item);
    }

    void selectItem(string itemId, bool makeVisible = true) {
        TreeItem item = findItemById(itemId);
        selectItem(item, makeVisible);
    }

    override protected bool handleAction(const Action a) {
        Log.d("tree.handleAction ", a.id);
        switch (a.id) with(TreeActions)
        {
            case ScrollLeft:
                if (_hscrollbar)
                    _hscrollbar.sendScrollEvent(ScrollAction.LineUp);
                break;
            case ScrollRight:
                if (_hscrollbar)
                    _hscrollbar.sendScrollEvent(ScrollAction.LineDown);
                break;
            case ScrollUp:
                if (_vscrollbar)
                    _vscrollbar.sendScrollEvent(ScrollAction.LineUp);
                break;
            case ScrollPageUp:
                if (_vscrollbar)
                    _vscrollbar.sendScrollEvent(ScrollAction.PageUp);
                break;
            case ScrollDown:
                if (_vscrollbar)
                    _vscrollbar.sendScrollEvent(ScrollAction.LineDown);
                break;
            case ScrollPageDown:
                if (_vscrollbar)
                    _vscrollbar.sendScrollEvent(ScrollAction.PageDown);
                break;
            case Up:
                _tree.selectPrevious();
                break;
            case Down:
                _tree.selectNext();
                break;
            case PageUp:
                // TODO: implement page up
                _tree.selectPrevious();
                break;
            case PageDown:
                // TODO: implement page down
                _tree.selectPrevious();
                break;
            default:
                return super.handleAction(a);
        }
        return true;
    }
}

/// Tree widget with items which can have icons and labels
class TreeWidget :  TreeWidgetBase {
    /// empty parameter list constructor - for usage by factory
    this() {
        this(null);
    }
    /// create with ID parameter
    this(string ID, ScrollBarMode hscrollbarMode = ScrollBarMode.Visible, ScrollBarMode vscrollbarMode = ScrollBarMode.Visible) {
        super(ID, hscrollbarMode, vscrollbarMode);
    }
}
