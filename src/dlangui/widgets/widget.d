module dlangui.widgets.widget;

public import dlangui.core.types;
public import dlangui.widgets.styles;
public import dlangui.graphics.drawbuf;
public import dlangui.graphics.fonts;
import dlangui.platforms.common.platform;

class Widget {
    protected Rect _pos;
	protected string _styleId;
	protected Style _ownStyle;
    protected int _measuredWidth;
    protected int _measuredHeight;
    protected bool _needLayout;
    protected bool _needDraw;
    protected Widget _parent;
    protected Window _window;

    this() {
        _needLayout = true;
        _needDraw = true;
    }

	//@property 
	const (Style) style() const {
		if (_ownStyle !is null)
			return _ownStyle;
		return currentTheme.get(_styleId);
	}
	//@property 
	Style ownStyle() {
		if (_ownStyle is null)
			_ownStyle = currentTheme.modifyStyle(_styleId);
		return _ownStyle;
	}
    @property void styleId(string id) { _styleId = id; }
	@property string styleId() { return _styleId; }
    @property Rect margins() { return style.margins; }
    @property void margins(Rect rc) { ownStyle.margins = rc; }
    @property Rect padding() { return style.padding; }
    @property void padding(Rect rc) { ownStyle.padding = rc; }
    @property uint backgroundColor() { return style.backgroundColor; }
    @property void backgroundColor(uint color) { ownStyle.backgroundColor = color; }
    @property bool needLayout() { return _needLayout; }
    @property bool needDraw() { return _needDraw; }
    @property int childCount() { return 0; }
    Widget child(int index) { return null; }
    @property Widget parent() { return _parent; }
    @property void parent(Widget parent) { _parent = parent; }
    @property Window window() {
        Widget p = this;
        while (p !is null) {
            if (p._window !is null)
                return p._window;
            p = p.parent;
        }
        return null;
    }
    @property void window(Window window) { _window = window; }
    @property measuredWidth() { return _measuredWidth; }
    @property measuredHeight() { return _measuredHeight; }
    @property int width() { return _pos.width; }
    @property int height() { return _pos.height; }
    void applyMargins(ref Rect rc) {
        Rect m = margins;
        rc.left += m.left;
        rc.top += m.top;
        rc.bottom -= m.bottom;
        rc.right -= m.right;
    }
    void applyPadding(ref Rect rc) {
        Rect m = padding;
        rc.left += m.left;
        rc.top += m.top;
        rc.bottom -= m.bottom;
        rc.right -= m.right;
    }
    void measure(int width, int height) { 
        _measuredWidth = _measuredHeight = 0;
    }
    void layout(Rect rc) {
        _pos = rc;
        _needLayout = false;
    }
    void onDraw(DrawBuf buf) {
        Rect rc = _pos;
        applyMargins(rc);
        buf.fillRect(_pos, backgroundColor);
        applyPadding(rc);
        buf.fillRect(rc.left + rc.width / 2, rc.top, rc.left + rc.width / 2 + 2, rc.bottom, 0xFF8000);
        buf.fillRect(rc.left, rc.top + rc.height / 2, rc.right, rc.top + rc.height / 2 + 2, 0xFF80FF);
        _needDraw = false;
    }
    ref FontRef getFont() {
        return FontManager.instance.getFont(24, FontWeight.Normal, false, FontFamily.SansSerif, "Arial");
    }
    @property dstring text() { return ""; }
    @property void text(dstring s) {  }
    protected uint _textColor = 0x000000;
    @property uint textColor() { return _textColor; }
    @property void textColor(uint value) { _textColor = value; }
    protected ubyte _alignment = Align.Left | Align.Top;
    @property ubyte alignment() { return _alignment; }
    @property Align valign() { return cast(Align)(_alignment & Align.VCenter); }
    @property Align halign() { return cast(Align)(_alignment & Align.HCenter); }
    @property void alignment(ubyte value) { _alignment = value; }
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
        FontRef font = getFont();
        Point sz = font.textSize(text);
        applyAlign(rc, sz);
        font.drawText(buf, rc.left, rc.top, text, textColor);
    }
}
