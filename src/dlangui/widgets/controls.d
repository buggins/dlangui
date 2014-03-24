module dlangui.widgets.controls;

import dlangui.widgets.widget;



/// static text widget
class TextWidget : Widget {
    this(string ID = null) {
		super(ID);
        styleId = "TEXT";
    }
    protected dstring _text;
    /// get widget text
    override @property dstring text() { return _text; }
    /// set text to show
    override @property Widget text(dstring s) { 
        _text = s; 
        requestLayout();
		return this;
    }

    override void measure(int parentWidth, int parentHeight) { 
        FontRef font = font();
        Point sz = font.textSize(text);
        measuredContent(parentWidth, parentHeight, sz.x, sz.y);
    }

    bool onClick() {
        // override it
        Log.d("Button.onClick ", id);
        return false;
    }

    override void onDraw(DrawBuf buf) {
        if (visibility != Visibility.Visible)
            return;
        super.onDraw(buf);
        Rect rc = _pos;
        applyMargins(rc);
        ClipRectSaver(buf, rc);
        applyPadding(rc);
        FontRef font = font();
        Point sz = font.textSize(text);
        applyAlign(rc, sz);
        font.drawText(buf, rc.left, rc.top, text, textColor);
    }
}

/// image widget
class ImageWidget : Widget {

    protected string _drawableId;
    protected DrawableRef _drawable;

    this(string ID = null, string drawableId = null) {
		super(ID);
        _drawableId = drawableId;
	}

    /// get drawable image id
    @property string drawableId() { return _drawableId; }
    /// set drawable image id
    @property ImageWidget drawableId(string id) { 
        _drawableId = id; 
        _drawable.clear();
        requestLayout();
        return this; 
    }
    /// get drawable
    @property ref DrawableRef drawable() {
        if (!_drawable.isNull)
            return _drawable;
        if (_drawableId !is null)
            _drawable = drawableCache.get(_drawableId);
        return _drawable;
    }
    /// set custom drawable (not one from resources)
    @property ImageWidget drawable(DrawableRef img) {
        _drawable = img;
        _drawableId = null;
        return this;
    }

    override void measure(int parentWidth, int parentHeight) { 
        DrawableRef img = drawable;
        int w = 0;
        int h = 0;
        if (!img.isNull) {
            w = img.width;
            h = img.height;
        }
        measuredContent(parentWidth, parentHeight, w, h);
    }
    override void onDraw(DrawBuf buf) {
        if (visibility != Visibility.Visible)
            return;
        super.onDraw(buf);
        Rect rc = _pos;
        applyMargins(rc);
        ClipRectSaver(buf, rc);
        applyPadding(rc);
        DrawableRef img = drawable;
        if (!img.isNull) {
            Point sz;
            sz.x = img.width;
            sz.y = img.height;
            applyAlign(rc, sz);
            img.drawTo(buf, rc);
        }
    }
}

/// button with image only
class ImageButton : ImageWidget {
    this(string ID = null, string drawableId = null) {
        super(ID);
        styleId = "BUTTON";
        _drawableId = drawableId;
    }
}

class Button : Widget {
    protected dstring _text;
    override @property dstring text() { return _text; }
    override @property Widget text(dstring s) { _text = s; requestLayout(); return this; }
    this(string ID = null) {
		super(ID);
        styleId = "BUTTON";
    }

    override void measure(int parentWidth, int parentHeight) { 
        FontRef font = font();
        Point sz = font.textSize(text);
        measuredContent(parentWidth, parentHeight, sz.x, sz.y);
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

/// scroll bar - either vertical or horizontal
class ScrollBar : WidgetGroup {
    protected ImageButton _btnBack;
    protected ImageButton _btnForward;
    protected int _btnSize;

    protected Orientation _orientation = Orientation.Vertical;
    /// returns scrollbar orientation (Vertical, Horizontal)
    @property Orientation orientation() { return _orientation; }
    /// sets scrollbar orientation
    @property ScrollBar orientation(Orientation value) { 
        if (_orientation != value) {
            _orientation = value; 
            _btnBack.drawableId = _orientation == Orientation.Vertical ? "scrollbar_btn_up" : "scrollbar_btn_left";
            _btnForward.drawableId = _orientation == Orientation.Vertical ? "scrollbar_btn_down" : "scrollbar_btn_right";
            requestLayout(); 
        }
        return this; 
    }

    this(string ID = null, Orientation orient = Orientation.Vertical) {
		super(ID);
        styleId = "BUTTON";
        _orientation = orient;
        _btnBack = new ImageButton("BACK", _orientation == Orientation.Vertical ? "scrollbar_btn_up" : "scrollbar_btn_left");
        _btnForward = new ImageButton("FORWARD", _orientation == Orientation.Vertical ? "scrollbar_btn_down" : "scrollbar_btn_right");
        addChild(_btnBack);
        addChild(_btnForward);
    }

    override void measure(int parentWidth, int parentHeight) { 
        Point sz;
        _btnBack.measure(parentWidth, parentHeight);
        _btnForward.measure(parentWidth, parentHeight);
        _btnSize = _btnBack.measuredWidth;
        if (_btnSize < _btnBack.measuredHeight)
            _btnSize = _btnBack.measuredHeight;
        if (_btnSize < 16)
            _btnSize = 16;
        if (_orientation == Orientation.Vertical) {
            // vertical
            sz.x = _btnSize;
            sz.y = _btnSize * 5; // min height
        } else {
            // horizontal
            sz.y = _btnSize;
            sz.x = _btnSize * 5; // min height
        }
        measuredContent(parentWidth, parentHeight, sz.x, sz.y);
    }

    override void layout(Rect rc) {
        applyMargins(rc);
        applyPadding(rc);
        Rect r;
        if (_orientation == Orientation.Vertical) {
            // vertical
            int backbtnpos = rc.top + _btnSize;
            int fwdbtnpos = rc.bottom - _btnSize;
            r = rc;
            r.bottom = backbtnpos;
            _btnBack.layout(r);
            r = rc;
            r.top = fwdbtnpos;
            _btnForward.layout(r);
        } else {
            // horizontal
            int backbtnpos = rc.left + _btnSize;
            int fwdbtnpos = rc.right - _btnSize;
            r = rc;
            r.right = backbtnpos;
            _btnBack.layout(r);
            r = rc;
            r.left = fwdbtnpos;
            _btnForward.layout(r);
        }
        _pos = rc;
        _needLayout = false;
    }

    /// Draw widget at its position to buffer
    override void onDraw(DrawBuf buf) {
        if (visibility != Visibility.Visible)
            return;
        super.onDraw(buf);
        Rect rc = _pos;
        applyMargins(rc);
        applyPadding(rc);
        ClipRectSaver(buf, rc);
        _btnForward.onDraw(buf);
        _btnBack.onDraw(buf);
    }
}
