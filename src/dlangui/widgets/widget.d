module dlangui.widgets.widget;

import dlangui.core.types;
import dlangui.graphics.drawbuf;
import dlangui.platforms.common.platform;

public class Widget {
    Rect _pos;
    Rect _margins;
    Rect _padding;
    int _measuredWidth;
    int _measuredHeight;
    bool _needLayout;
    bool _needDraw;
    Widget _parent;
    Window _window;

    uint _backgroundColor = 0xC0C0C0;

    public this() {
        _needLayout = true;
        _needDraw = true;
    }
    public @property Rect margins() { return _margins; }
    public @property void margins(Rect rc) { _margins = rc; }
    public @property Rect padding() { return _padding; }
    public @property void padding(Rect rc) { _padding = rc; }
    public @property uint backgroundColor() { return _backgroundColor; }
    public @property void backgroundColor(uint color) { _backgroundColor = color; }
    public @property bool needLayout() { return _needLayout; }
    public @property bool needDraw() { return _needDraw; }
    public @property int childCount() { return 0; }
    public Widget child(int index) { return null; }
    public @property Widget parent() { return _parent; }
    public @property void parent(Widget parent) { _parent = parent; }
    public @property Window window() {
        Widget p = this;
        while (p !is null) {
            if (p._window !is null)
                return p._window;
            p = p.parent;
        }
        return null;
    }
    public @property void window(Window window) { _window = window; }
    public @property measuredWidth() { return _measuredWidth; }
    public @property measuredHeight() { return _measuredHeight; }
    public void measure(int width, int height) { 
        _measuredWidth = _measuredHeight = 0;
    }
    public void layout(Rect rc) { 
        _pos = rc;
    }
    public @property int width() { return _pos.width; }
    public @property int height() { return _pos.height; }
    public void applyMargins(ref Rect rc) {
        Rect m = margins;
        rc.left += m.left;
        rc.top += m.top;
        rc.bottom -= m.bottom;
        rc.right -= m.right;
    }
    public void applyPadding(ref Rect rc) {
        Rect m = padding;
        rc.left += m.left;
        rc.top += m.top;
        rc.bottom -= m.bottom;
        rc.right -= m.right;
    }
    public void onDraw(DrawBuf buf) {
        Rect rc = _pos;
        applyMargins(rc);
        buf.fillRect(_pos, _backgroundColor);
        applyPadding(rc);
        buf.fillRect(rc.left + rc.width / 2, rc.top, rc.left + rc.width / 2 + 2, rc.bottom, 0xFF8000);
        buf.fillRect(rc.left, rc.top + rc.height / 2, rc.right, rc.top + rc.height / 2 + 2, 0xFF80FF);
    }
}
