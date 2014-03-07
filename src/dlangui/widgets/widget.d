module dlangui.widgets.widget;

public import dlangui.core.types;
public import dlangui.widgets.styles;
public import dlangui.graphics.drawbuf;
public import dlangui.graphics.fonts;
import dlangui.platforms.common.platform;

class Widget {
    /// current widget position, set by layout()
    protected Rect _pos;
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

    //======================================================
    // Style related properties

    /// returns widget style id, null if not set
    @property void styleId(string id) { _styleId = id; }
    /// set widget style id
	@property string styleId() const { return _styleId; }
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
    /// Measure widget according to desired width and height constraints. (Step 1 of two phase layout).
    void measure(int width, int height) { 
        _measuredWidth = _measuredHeight = 0;
    }
    /// Set widget rectangle to specified value and layout widget contents. (Step 2 of two phase layout).
    void layout(Rect rc) {
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
        Rect rc = _pos;
        applyMargins(rc);
        buf.fillRect(_pos, backgroundColor);
        applyPadding(rc);
        buf.fillRect(Rect(rc.left + rc.width / 2, rc.top, rc.left + rc.width / 2 + 2, rc.bottom), 0xFF8000);
        buf.fillRect(Rect(rc.left, rc.top + rc.height / 2, rc.right, rc.top + rc.height / 2 + 2), 0xFF80FF);
        _needDraw = false;
    }
    /// Applies alignment for content of size sz - set rectangle rc to aligned value of content inside of initial value of rc.
    void applyAlign(ref Rect rc, Point sz) {
        if (valign == Align.Bottom) {
            rc.top = rc.bottom - sz.y;
        } else if (valign == Align.VCenter) {
            int dy = (rc.height - sz.y) / 2;
            rc.top += dy;
            rc.bottom = rc.top + sz.y;
        } else {
            rc.bottom = rc.top + sz.y;
        }
        if (halign == Align.Right) {
            rc.left = rc.right - sz.x;
        } else if (halign == Align.HCenter) {
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

class TextWidget : Widget {
    protected dstring _text;
    override @property dstring text() { return _text; }
    override @property void text(dstring s) { _text = s; }
    override void measure(int width, int height) { 
        _measuredWidth = _measuredHeight = 0;
    }
    override void layout(Rect rc) { 
        _pos = rc;
        _needLayout = false;
    }
    override void onDraw(DrawBuf buf) {
        super.onDraw(buf);
        Rect rc = _pos;
        applyMargins(rc);
        buf.fillRect(_pos, backgroundColor);
        applyPadding(rc);
        ClipRectSaver(buf, rc);
        FontRef font = font();
        Point sz = font.textSize(text);
        applyAlign(rc, sz);
        font.drawText(buf, rc.left, rc.top, text, textColor);
    }
}
