module dlangui.widgets.tree;

import dlangui.widgets.widget;
import dlangui.widgets.controls;
import dlangui.widgets.scroll;
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
    bool isFullyExpanded() {
        if (!_expanded)
            return false;
        if (_parent)
            return _parent.isFullyExpanded();
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

}

interface OnTreeContentChangeListener {
    void onTreeContentChange(TreeItems source);
}

class TreeItems : TreeItem {
    // signal handler OnTreeContentChangeListener
    Listener!OnTreeContentChangeListener listener;
}

class TreeWidgetBase :  ScrollWidgetBase {

	this(string ID = null, ScrollBarMode hscrollbarMode = ScrollBarMode.Visible, ScrollBarMode vscrollbarMode = ScrollBarMode.Visible) {
		super(ID, hscrollbarMode, vscrollbarMode);
    }

    /// process horizontal scrollbar event
    override bool onHScroll(ScrollEvent event) {
        return true;
    }

    /// process vertical scrollbar event
    override bool onVScroll(ScrollEvent event) {
        return true;
    }

    /// update horizontal scrollbar widget position
    override protected void updateHScrollBar() {
        // override it
    }

    /// update verticat scrollbar widget position
    override protected void updateVScrollBar() {
        // override it
    }


}

class TreeWidget :  TreeWidgetBase {
	this(string ID = null) {
		super(ID);
    }
}
