module dlangui.widgets.tree;

import dlangui.widgets.widget;
import dlangui.widgets.controls;
import dlangui.widgets.scroll;
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
        _text = label;
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
        _text = labelRes;
    }
    /// create and add new child item
    TreeItem newChild(string id, dstring label, string iconRes = null) {
        TreeItem res = new TreeItem(id, label, iconRes);
        addChild(res);
        return res;
    }

    /// returns topmost item
    @property TreeItems root() {
        TreeItem p = this;
        while (p._parent)
            p = p._parent;
        return cast(TreeItems)p;
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

    @property TreeItem selectedItem() {
        return root.selectedItem();
    }

    bool isSelected() {
        return (selectedItem is this);
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

    /// returns true if item has at least one child
    @property bool hasChildren() { return childCount > 0; }

    /// returns number of children of this widget
    @property int childCount() { return _children.count; }
    /// returns child by index
    TreeItem child(int index) { return _children.get(index); }
    /// adds child, returns added item
    TreeItem addChild(TreeItem item) { 
        return _children.add(item).parent(this).level(_level + 1);
    }
    /// removes child, returns removed item
    TreeItem removeChild(int index) { 
        TreeItem res = _children.remove(index);
        if (res !is null)
            res.parent = null;
        return res;
    }
    /// removes child by ID, returns removed item
    TreeItem removeChild(string ID) {
        TreeItem res = null;
        int index = _children.indexOf(ID);
        if (index < 0)
            return null;
        res = _children.remove(index); 
        if (res !is null)
            res.parent = null;
        return res;
    }
    /// returns index of widget in child list, -1 if passed widget is not a child of this widget
    int childIndex(TreeItem item) { return _children.indexOf(item); }
    /// notify listeners
    protected void onUpdate(TreeItem item) {
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
}

interface OnTreeContentChangeListener {
    void onTreeContentChange(TreeItems source);
}

interface OnTreeStateChangeListener {
    void onTreeStateChange(TreeItems source);
}

interface OnTreeSelectionChangeListener {
    void onTreeItemSelected(TreeItems source, TreeItem selectedItem, bool activated);
}

class TreeItems : TreeItem {
    // signal handler OnTreeContentChangeListener
    Listener!OnTreeContentChangeListener contentListener;
    Listener!OnTreeStateChangeListener stateListener;
    Listener!OnTreeSelectionChangeListener selectionListener;

    protected TreeItem _selectedItem;

    this() {
        super("tree");
    }

    /// notify listeners
    override protected void onUpdate(TreeItem item) {
        if (contentListener.assigned)
            contentListener(this);
    }

    override void toggleExpand(TreeItem item) {
        if (item.expanded)
            item.collapse();
        else
            item.expand();
        if (stateListener.assigned)
            stateListener(this);
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

class TreeItemWidget : HorizontalLayout {
    TreeItem _item;
    TextWidget _tab;
    ImageWidget _expander;
    ImageWidget _icon;
    TextWidget _label;
    long lastClickTime;

    @property TreeItem item() { return _item; }


    this(TreeItem item) {
        super(item.id);
        styleId = "TREE_ITEM";

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
        int w = (_item.level - 1) * style.font.size * 2;
        _tab.minWidth = w;
        _tab.maxWidth = w;
        if (_item.hasChildren) {
            _expander = new ImageWidget("expander", _item.hasChildren && _item.expanded ? "arrow_right_down_black" : "arrow_right_hollow");
            _expander.styleId = "TREE_ITEM_EXPAND_ICON";
            _expander.clickable = true;
            _expander.trackHover = true;
            //_expander.setState(State.Parent);

            _expander.onClickListener = delegate(Widget source) {
                _item.selectItem(_item);
                _item.toggleExpand(_item);
                return true;
            };
        }
        onClickListener = delegate(Widget source) {
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
        if (_item.iconRes.length > 0) {
            _icon = new ImageWidget("icon", _item.iconRes);
            _icon.styleId = "TREE_ITEM_ICON";
            _icon.setState(State.Parent);
        }
        _label = new TextWidget("label", _item.text);
        _label.styleId = "TREE_ITEM_LABEL";
        _label.setState(State.Parent);
        // append children
        addChild(_tab);
        if (_expander)
            addChild(_expander);
        if (_icon)
            addChild(_icon);
        addChild(_label);
    }

    override bool onKeyEvent(KeyEvent event) {
        if (onKeyListener.assigned && onKeyListener(this, event))
            return true; // processed by external handler
        if (!focused || !visible)
            return false;
        if (event.action != KeyAction.KeyDown)
            return false;
        int action = 0;
        switch (event.keyCode) {
            case KeyCode.SPACE:
            case KeyCode.RETURN:
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
    }
}

class TreeWidgetBase :  ScrollWidget, OnTreeContentChangeListener, OnTreeStateChangeListener, OnTreeSelectionChangeListener, OnKeyHandler {

    protected TreeItems _tree;

    @property ref TreeItems items() { return _tree; }

    Signal!OnTreeSelectionChangeListener selectionListener;

    protected bool _needUpdateWidgets;
    protected bool _needUpdateWidgetStates;

	this(string ID = null, ScrollBarMode hscrollbarMode = ScrollBarMode.Visible, ScrollBarMode vscrollbarMode = ScrollBarMode.Visible) {
		super(ID, hscrollbarMode, vscrollbarMode);
        contentWidget = new VerticalLayout("TREE_CONTENT");
        _tree = new TreeItems();
        _tree.contentListener = this;
        _tree.stateListener = this;
        _tree.selectionListener = this;
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
        Widget res = new TreeItemWidget(item);
        res.onKeyListener = this;
        return res;
    }

    override bool onKey(Widget source, KeyEvent event) {
		if (event.action == KeyAction.KeyDown) {
			Action action = findKeyAction(event.keyCode, event.flags & (KeyFlag.Shift | KeyFlag.Alt | KeyFlag.Control));
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
    }

    override void onTreeStateChange(TreeItems source) {
        _needUpdateWidgetStates = true;
        requestLayout();
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
        if (selectionListener.assigned)
            selectionListener(source, selectedItem, activated);
    }

    void makeItemVisible(TreeItem item) {
        TreeItemWidget widget = findItemWidget(item);
        if (widget && widget.visibility == Visibility.Visible) {
            makeWidgetVisible(widget, false, true);
        }
    }

	override protected bool handleAction(const Action a) {
        Log.d("tree.handleAction ", a.id);
        switch (a.id) {
            case TreeActions.ScrollLeft:
                if (_hscrollbar)
                    _hscrollbar.sendScrollEvent(ScrollAction.LineUp);
                break;
            case TreeActions.ScrollRight:
                if (_hscrollbar)
                    _hscrollbar.sendScrollEvent(ScrollAction.LineDown);
                break;
            case TreeActions.ScrollUp:
                if (_vscrollbar)
                    _vscrollbar.sendScrollEvent(ScrollAction.LineUp);
                break;
            case TreeActions.ScrollPageUp:
                if (_vscrollbar)
                    _vscrollbar.sendScrollEvent(ScrollAction.PageUp);
                break;
            case TreeActions.ScrollDown:
                if (_vscrollbar)
                    _vscrollbar.sendScrollEvent(ScrollAction.LineDown);
                break;
            case TreeActions.ScrollPageDown:
                if (_vscrollbar)
                    _vscrollbar.sendScrollEvent(ScrollAction.PageDown);
                break;
            case TreeActions.Up:
                _tree.selectPrevious();
                break;
            case TreeActions.Down:
                _tree.selectNext();
                break;
            case TreeActions.PageUp:
                // TODO: implement page up
                _tree.selectPrevious();
                break;
            case TreeActions.PageDown:
                // TODO: implement page down
                _tree.selectPrevious();
                break;
            default:
                return super.handleAction(a);
        }
        return true;
    }
}

class TreeWidget :  TreeWidgetBase {
	this(string ID = null) {
		super(ID);
    }
}
