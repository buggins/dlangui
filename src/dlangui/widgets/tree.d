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
        return isVisible();
    }
    /** Returns true if all parents are expanded. */
    bool isVisible() {
        if (_parent)
            return _parent.isVisible();
        return false;
    }
    void expand() {
        _expanded = true;
        if (_parent)
            _parent.expand();
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
        if (_parent)
            _parent.onUpdate(item);
    }
}

interface OnTreeContentChangeListener {
    void onTreeContentChange(TreeItems source);
}

class TreeItems : TreeItem {
    // signal handler OnTreeContentChangeListener
    Signal!OnTreeContentChangeListener listener;

    this() {
        super("tree");
    }

    /// notify listeners
    override protected void onUpdate(TreeItem item) {
        if (listener.assigned)
            listener(this);
    }
}

class TreeItemWidget : HorizontalLayout {
    TreeItem _item;
    TextWidget _tab;
    ImageWidget _expander;
    ImageWidget _icon;
    TextWidget _label;
    this(TreeItem item) {
        super(item.id);
        _item = item;
        _tab = new TextWidget("tab");
        dchar[] tabText;
        dchar[] singleTab = [' ', ' ', ' ', ' '];
        for (int i = 1; i < _item.level; i++)
            tabText ~= singleTab;
        _tab.text = cast(dstring)tabText;
        _expander = new ImageWidget("expander", _item.hasChildren && _item.expanded ? "arrow_right_down_black" : "arrow_right_hollow");
        if (!_item.hasChildren)
            _expander.visibility = Visibility.Gone;
        if (_item.iconRes.length > 0)
            _icon = new ImageWidget("icon", _item.iconRes);
        _label = new TextWidget("label", _item.text);
        addChild(_tab);
        addChild(_expander);
        if (_icon)
            addChild(_icon);
        addChild(_label);
    }
}

class TreeWidgetBase :  ScrollWidget, OnTreeContentChangeListener {

    protected TreeItems _tree;

    @property ref TreeItems items() { return _tree; }

    protected bool _needUpdateWidgets;

	this(string ID = null, ScrollBarMode hscrollbarMode = ScrollBarMode.Visible, ScrollBarMode vscrollbarMode = ScrollBarMode.Visible) {
		super(ID, hscrollbarMode, vscrollbarMode);
        contentWidget = new VerticalLayout("TREE_CONTENT");
        _tree = new TreeItems();
        _tree.listener.connect(this);
        _needUpdateWidgets = true;
    }

    ~this() {
        if (_tree) {
            destroy(_tree);
            _tree = null;
        }
    }

    /** Override to use custom tree item widgets. */
    protected Widget createItemWidget(TreeItem item) {
        return new TreeItemWidget(item);
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

	/// Set widget rectangle to specified value and layout widget contents. (Step 2 of two phase layout).
	override void layout(Rect rc) {
		if (visibility == Visibility.Gone) {
			return;
		}
        if (_needUpdateWidgets)
            updateWidgets();
        super.layout(rc);
    }

	/// Measure widget according to desired width and height constraints. (Step 1 of two phase layout).
	override void measure(int parentWidth, int parentHeight) { 
        if (visibility == Visibility.Gone) {
            return;
        }
        if (_needUpdateWidgets)
            updateWidgets();
        super.measure(parentWidth, parentHeight);
    }

    /// listener
    override void onTreeContentChange(TreeItems source) {
        _needUpdateWidgets = true;
        requestLayout();
    }
}

class TreeWidget :  TreeWidgetBase {
	this(string ID = null) {
		super(ID);
    }
}
