module dlangui.widgets.controls;

import dlangui.widgets.widget;

class Button : Widget {
    protected dstring _text;
    override @property dstring text() { return _text; }
    override @property void text(dstring s) { _text = s; }
    this() {
        styleId = "BUTTON";
    }
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