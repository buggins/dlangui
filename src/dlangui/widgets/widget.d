module dlangui.widgets.widget;

public import dlangui.core.types;
public import dlangui.widgets.styles;
public import dlangui.graphics.drawbuf;
public import dlangui.graphics.images;
public import dlangui.graphics.fonts;

import dlangui.platforms.common.platform;

import std.algorithm;


/// Visibility (see Android View Visibility)
enum Visibility : ubyte {
    /// Visible on screen (default)
    Visible,
    /// Not visible, but occupies a space in layout
    Invisible,
    /// Completely hidden, as not has been added
    Gone
}

class Widget {
    /// widget id
    protected string _id;
    /// current widget position, set by layout()
    protected Rect _pos;
    /// widget visibility: either Visible, Invisible, Gone
    protected Visibility _visibility = Visibility.Visible; // visible by default
    /// style id to lookup style in theme
	protected string _styleId;
    /// own copy of style - to override some of style properties, null of no properties overriden
	protected Style _ownStyle;
    /// width measured by measure()
    protected int _measuredWidth;
    /// height measured by measure()
    protected int _measuredHeight;
    /// true to force layout
    protected bool _needLayout;
    /// true to force redraw
    protected bool _needDraw;
    /// parent widget
    protected Widget _parent;
    /// window (to be used for top level widgets only!)
    protected Window _window;

    this() {
        _needLayout = true;
        _needDraw = true;
    }

    /// accessor to style - by lookup in theme by styleId (if style id is not set, theme base style will be used).
	protected @property const (Style) style() const {
		if (_ownStyle !is null)
			return _ownStyle;
		return currentTheme.get(_styleId);
	}
    /// enforces widget's own style - allows override some of style properties
	protected @property Style ownStyle() {
		if (_ownStyle is null)
			_ownStyle = currentTheme.modifyStyle(_styleId);
		return _ownStyle;
	}

    /// returns widget id, null if not set
	@property string id() const { return _styleId; }
    /// set widget id
    @property void id(string id) { _id = id; }
    /// compare widget id with specified value, returs true if matches
    bool compareId(string id) { return (_id !is null) && id.equal(_id); }

    //======================================================
    // Style related properties

    /// returns widget style id, null if not set
	@property string styleId() const { return _styleId; }
    /// set widget style id
    @property void styleId(string id) { _styleId = id; }
    /// get margins (between widget bounds and its background)
    @property Rect margins() const { return style.margins; }
    /// set margins for widget - override one from style
    @property Widget margins(Rect rc) { ownStyle.margins = rc; return this; }
    /// get padding (between background bounds and content of widget)
    @property Rect padding() const { return style.padding; }
    /// set padding for widget - override one from style
    @property Widget padding(Rect rc) { ownStyle.padding = rc; return this; }
    /// returns background color
    @property uint backgroundColor() const { return style.backgroundColor; }
    /// set background color for widget - override one from style
    @property Widget backgroundColor(uint color) { ownStyle.backgroundColor = color; return this; }
    /// get text color (ARGB 32 bit value)
    @property uint textColor() const { return style.textColor; }
    /// set text color (ARGB 32 bit value)
    @property Widget textColor(uint value) { ownStyle.textColor = value; return this; }
    /// returns font face
    @property string fontFace() const { return style.fontFace; }
    /// set font face for widget - override one from style
	@property Widget fontFace(string face) { ownStyle.fontFace = face; return this; }
    /// returns font style (italic/normal)
    @property bool fontItalic() const { return style.fontItalic; }
    /// set font style (italic/normal) for widget - override one from style
	@property Widget fontItalic(bool italic) { ownStyle.fontStyle = italic ? FONT_STYLE_ITALIC : FONT_STYLE_NORMAL; return this; }
    /// returns font weight
    @property ushort fontWeight() const { return style.fontWeight; }
    /// set font weight for widget - override one from style
	@property Widget fontWeight(ushort weight) { ownStyle.fontWeight = weight; return this; }
    /// returns font size in pixels
    @property ushort fontSize() const { return style.fontSize; }
    /// set font size for widget - override one from style
	@property Widget fontSize(ushort size) { ownStyle.fontSize = size; return this; }
    /// returns font family
    @property FontFamily fontFamily() const { return style.fontFamily; }
    /// set font family for widget - override one from style
    @property Widget fontFamily(FontFamily family) { ownStyle.fontFamily = family; return this; }
    /// returns alignment (combined vertical and horizontal)
    @property ubyte alignment() const { return style.alignment; }
    /// sets alignment (combined vertical and horizontal)
    @property Widget alignment(ubyte value) { ownStyle.alignment = value; return this; }
    /// returns horizontal alignment
    @property Align valign() { return cast(Align)(alignment & Align.VCenter); }
    /// returns vertical alignment
    @property Align halign() { return cast(Align)(alignment & Align.HCenter); }
    /// returns font set for widget using style or set manually
    @property FontRef font() const { return style.font; }

    /// returns widget content text (override to support this)
    @property dstring text() { return ""; }
    /// sets widget content text (override to support this)
    @property void text(dstring s) {  }

    //==================================================================
    // Layout and drawing related methods

    /// returns true if layout is required for widget and its children
    @property bool needLayout() { return _needLayout; }
    /// returns true if redraw is required for widget and its children
    @property bool needDraw() { return _needDraw; }
    /// returns measured width (calculated during measure() call)
    @property measuredWidth() { return _measuredWidth; }
    /// returns measured height (calculated during measure() call)
    @property measuredHeight() { return _measuredHeight; }
    /// returns current width of widget in pixels
    @property int width() { return _pos.width; }
    /// returns current height of widget in pixels
    @property int height() { return _pos.height; }
    /// returns min width constraint
    @property int minWidth() { return style.minWidth; }
    /// returns max width constraint (SIZE_UNSPECIFIED if no constraint set)
    @property int maxWidth() { return style.maxWidth; }
    /// returns min height constraint
    @property int minHeight() { return style.minHeight; }
    /// returns max height constraint (SIZE_UNSPECIFIED if no constraint set)
    @property int maxHeight() { return style.maxHeight; }

    /// set max width constraint (SIZE_UNSPECIFIED for no constraint)
    @property Widget maxWidth(int value) { ownStyle.maxWidth = value; return this; }
    /// set max width constraint (0 for no constraint)
    @property Widget minWidth(int value) { ownStyle.minWidth = value; return this; }
    /// set max height constraint (SIZE_UNSPECIFIED for no constraint)
    @property Widget maxHeight(int value) { ownStyle.maxHeight = value; return this; }
    /// set max height constraint (0 for no constraint)
    @property Widget minHeight(int value) { ownStyle.minHeight = value; return this; }

    /// returns widget visibility (Visible, Invisible, Gone)
    @property Visibility visibility() { return _visibility; }
    /// sets widget visibility (Visible, Invisible, Gone)
    @property Widget visibility(Visibility visible) { 
        _visibility = visible; 
        requestLayout();
        return this;
    }

    /// request relayout of widget and its children
    void requestLayout() {
        _needLayout = true;
    }
    /// request redraw
    void invalidate() {
        _needDraw = true;
    }

    /// Measure widget according to desired width and height constraints. (Step 1 of two phase layout).
    void measure(int parentWidth, int parentHeight) { 
        measuredContent(parentWidth, parentHeight, 0, 0);
    }

    /// helper function for implement measure() when widget's content dimensions are known
    protected void measuredContent(int parentWidth, int parentHeight, int contentWidth, int contentHeight) {
        if (visibility == Visibility.Gone) {
            _measuredWidth = _measuredHeight = 0;
            return;
        }
        Rect m = margins;
        Rect p = padding;
        // summarize margins, padding, and content size
        int dx = m.left + m.right + p.left + p.right + contentWidth;
        int dy = m.top + m.bottom + p.top + p.bottom + contentHeight;
        // apply min/max width and height constraints
        int minw = minWidth;
        int maxw = maxWidth;
        int minh = minHeight;
        int maxh = maxHeight;
        if (dx < minw)
            dx = minw;
        if (dy < minh)
            dy = minh;
        if (maxw != SIZE_UNSPECIFIED && dx > maxw)
            dx = maxw;
        if (maxh != SIZE_UNSPECIFIED && dy > maxh)
            dy = maxh;
        // apply max parent size constraint
        if (parentWidth != SIZE_UNSPECIFIED && dx > parentWidth)
            dx = parentWidth;
        if (parentHeight != SIZE_UNSPECIFIED && dy > parentHeight)
            dy = parentHeight;
        _measuredWidth = dx;
        _measuredHeight = dy;
    }

    /// Set widget rectangle to specified value and layout widget contents. (Step 2 of two phase layout).
    void layout(Rect rc) {
        if (visibility == Visibility.Gone) {
            return;
        }
        _pos = rc;
        _needLayout = false;
    }
    /// applies margins to rectangle
    void applyMargins(ref Rect rc) {
        Rect m = margins;
        rc.left += m.left;
        rc.top += m.top;
        rc.bottom -= m.bottom;
        rc.right -= m.right;
    }
    /// applies padding to rectangle
    void applyPadding(ref Rect rc) {
        Rect m = padding;
        rc.left += m.left;
        rc.top += m.top;
        rc.bottom -= m.bottom;
        rc.right -= m.right;
    }
    /// Draw widget at its position to buffer
    void onDraw(DrawBuf buf) {
        if (visibility != Visibility.Visible)
            return;
        Rect rc = _pos;
        applyMargins(rc);
        buf.fillRect(_pos, backgroundColor);
        DrawableRef bg = style.backgroundDrawable;
        bg.drawTo(buf, rc);
        applyPadding(rc);
        _needDraw = false;
    }
    /// Applies alignment for content of size sz - set rectangle rc to aligned value of content inside of initial value of rc.
    void applyAlign(ref Rect rc, Point sz) {
        Align va = valign;
        Align ha = halign;
        if (va == Align.Bottom) {
            rc.top = rc.bottom - sz.y;
        } else if (va == Align.VCenter) {
            int dy = (rc.height - sz.y) / 2;
            rc.top += dy;
            rc.bottom = rc.top + sz.y;
        } else {
            rc.bottom = rc.top + sz.y;
        }
        if (ha == Align.Right) {
            rc.left = rc.right - sz.x;
        } else if (ha == Align.HCenter) {
            int dx = (rc.width - sz.x) / 2;
            rc.left += dx;
            rc.right = rc.left + sz.x;
        } else {
            rc.right = rc.left + sz.x;
        }
    }

    // ===========================================================
    // Widget hierarhy methods

    /// returns number of children of this widget
    @property int childCount() { return 0; }
    /// returns child by index
    Widget child(int index) { return null; }
    /// adds child, returns added item
    Widget addChild(Widget item) { assert(false, "children not suported for this widget type"); }
    /// removes child, returns added item
    Widget removeChild(int index) { assert(false, "children not suported for this widget type"); }
    /// returns index of widget in child list, -1 if passed widget is not a child of this widget
    int childIndex(Widget item) { return -1; }

    /// find child by id, returns null if not found
    Widget childById(string id) { 
        if (compareId(id))
            return this;
        // lookup children
        for (int i = childCount - 1; i >= 0; i--) {
            Widget res = child(i).childById(id);
            if (res !is null)
                return res;
        }
        // not found
        return null; 
    }
    /// returns parent widget, null for top level widget
    @property Widget parent() { return _parent; }
    /// sets parent for widget
    @property void parent(Widget parent) { _parent = parent; }
    /// returns window (if widget or its parent is attached to window)
    @property Window window() {
        Widget p = this;
        while (p !is null) {
            if (p._window !is null)
                return p._window;
            p = p.parent;
        }
        return null;
    }
    /// sets window (to be used for top level widget from Window implementation). TODO: hide it from API?
    @property void window(Window window) { _window = window; }

}

/// widget list holder
struct WidgetList {
    protected Widget[] _list;
    protected int _count;
    /// returns count of items
    @property int count() { return _count; }
    /// get item by index
    Widget get(int index) {
        assert(index >= 0 && index < _count, "child index out of range");
        return _list[index];
    }
    /// add item to list
    Widget add(Widget item) {
        if (_list.length <= _count) // resize
            _list.length = _list.length < 4 ? 4 : _list.length * 2;
        _list[_count++] = item;
        return item;
    }
    /// find child index for item, return -1 if not found
    int indexOf(Widget item) {
        for (int i = 0; i < _count; i++)
            if (_list[i] == item)
                return i;
        return -1;
    }
    /// remove item from list, return removed item
    Widget remove(int index) {
        assert(index >= 0 && index < _count, "child index out of range");
        Widget item = _list[index];
        for (int i = index; i < _count - 1; i++)
            _list[i] = _list[i + 1];
        _count--;
        return item;
    }
    /// remove and destroy all items
    void clear() {
        for (int i = 0; i < _count; i++) {
            destroy(_list[i]);
            _list[i] = null;
        }
        _count = 0;
    }
    ~this() {
        clear();
    }
}

/// base class for widgets which have children
class WidgetGroup : Widget {

    protected WidgetList _children;

    /// returns number of children of this widget
    @property override int childCount() { return _children.count; }
    /// returns child by index
    override Widget child(int index) { return _children.get(index); }
    /// adds child, returns added item
    override Widget addChild(Widget item) { return _children.add(item); }
    /// removes child, returns added item
    override Widget removeChild(int index) { return _children.remove(index); }
    /// returns index of widget in child list, -1 if passed widget is not a child of this widget
    override int childIndex(Widget item) { return _children.indexOf(item); }
}
