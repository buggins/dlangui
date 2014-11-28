module dlangui.widgets.scroll;

import dlangui.widgets.widget;
import dlangui.widgets.controls;
import std.conv;

/** Scroll bar visibility mode. */
enum ScrollBarMode {
    /** always invisible */
    Invisible,
    /** always visible */
    Visible,
    /** automatically show/hide scrollbar depending on content size */
    Auto
}

class ScrollWidget :  WidgetGroup, OnScrollHandler {
    protected ScrollBarMode _vscrollbarMode;
    protected ScrollBarMode _hscrollbarMode;
    /// vertical scrollbar control
	protected ScrollBar _vscrollbar;
    /// horizontal scrollbar control
	protected ScrollBar _hscrollbar;
    /// inner area, excluding additional controls like scrollbars
	protected Rect _clientRect;

	this(string ID = null, ScrollBarMode hscrollbarMode = ScrollBarMode.Visible, ScrollBarMode vscrollbarMode = ScrollBarMode.Visible) {
		super(ID);
        _hscrollbarMode = hscrollbarMode;
        _vscrollbarMode = vscrollbarMode;
        if (_vscrollbarMode != ScrollBarMode.Invisible) {
            _vscrollbar = new ScrollBar("vscrollbar", Orientation.Vertical);
            _vscrollbar.onScrollEventListener = this;
            addChild(_vscrollbar);
        }
        if (_hscrollbarMode != ScrollBarMode.Invisible) {
            _hscrollbar = new ScrollBar("hscrollbar", Orientation.Horizontal);
            _hscrollbar.onScrollEventListener = this;
            addChild(_hscrollbar);
        }
    }

    /// process horizontal scrollbar event
    bool onHScroll(ScrollEvent event) {
        return true;
    }

    /// process vertical scrollbar event
    bool onVScroll(ScrollEvent event) {
        return true;
    }

    /// handle scroll event
    override bool onScrollEvent(AbstractSlider source, ScrollEvent event) {
        if (source.compareId("hscrollbar")) {
            return onHScroll(event);
        } else if (source.compareId("vscrollbar")) {
            return onVScroll(event);
        }
        return true;
    }

    /// update horizontal scrollbar widget position
    protected void updateHScrollBar() {
        // override it
    }

    /// update verticat scrollbar widget position
    protected void updateVScrollBar() {
        // override it
    }

    /// update scrollbar positions
    protected void updateScrollBars() {
        if (_hscrollbar) {
            updateHScrollBar();
        }
        if (_vscrollbar) {
            updateVScrollBar();
        }
    }

	protected void drawClient(DrawBuf buf) {
        // override it
    }

	/// Draw widget at its position to buffer
	override void onDraw(DrawBuf buf) {
		if (visibility != Visibility.Visible)
			return;
		Rect rc = _pos;
		applyMargins(rc);
		auto saver = ClipRectSaver(buf, rc, alpha);
		DrawableRef bg = backgroundDrawable;
		if (!bg.isNull) {
			bg.drawTo(buf, rc, state);
		}
		applyPadding(rc);
        if (_hscrollbar)
		    _hscrollbar.onDraw(buf);
        if (_vscrollbar)
		    _vscrollbar.onDraw(buf);
		drawClient(buf);
		_needDraw = false;
	}

    /// calculate full content size in pixels
    Point fullContentSize() {
        // override it
        Point sz;
        return sz;
    }

	/// Measure widget according to desired width and height constraints. (Step 1 of two phase layout).
	override void measure(int parentWidth, int parentHeight) { 
        if (visibility == Visibility.Gone) {
            return;
        }
		Rect m = margins;
		Rect p = padding;
		// calc size constraints for children
		int pwidth = parentWidth;
		int pheight = parentHeight;
		if (parentWidth != SIZE_UNSPECIFIED)
			pwidth -= m.left + m.right + p.left + p.right;
		if (parentHeight != SIZE_UNSPECIFIED)
			pheight -= m.top + m.bottom + p.top + p.bottom;
        if (_hscrollbar)
		    _hscrollbar.measure(pwidth, pheight);
        if (_vscrollbar)
		    _vscrollbar.measure(pwidth, pheight);
        Point sz = fullContentSize();
		measuredContent(parentWidth, parentHeight, sz.x, sz.y);
	}

	/// Set widget rectangle to specified value and layout widget contents. (Step 2 of two phase layout).
	override void layout(Rect rc) {
		if (visibility == Visibility.Gone) {
			return;
		}
		_pos = rc;
		_needLayout = false;
		applyMargins(rc);
		applyPadding(rc);
        Point sz = fullContentSize();
        bool needHscroll = _hscrollbarMode != ScrollBarMode.Invisible && sz.x > rc.width;
        bool needVscroll = _vscrollbarMode != ScrollBarMode.Invisible && sz.y > rc.height;
        if (needVscroll && _vscrollbarMode != ScrollBarMode.Invisible)
            needHscroll = sz.x > rc.width - _vscrollbar.measuredWidth;
        if (needHscroll && _hscrollbarMode != ScrollBarMode.Invisible)
            needVscroll = sz.y > rc.height - _hscrollbar.measuredHeight;
        if (needVscroll && _vscrollbarMode != ScrollBarMode.Invisible)
            needHscroll = sz.x > rc.width - _vscrollbar.measuredWidth;
        needVscroll = needVscroll || (_vscrollbarMode == ScrollBarMode.Visible);
        needHscroll = needHscroll || (_hscrollbarMode == ScrollBarMode.Visible);
        // scrollbars
		Rect vsbrc = rc;
		vsbrc.left = vsbrc.right - (needVscroll ? _vscrollbar.measuredWidth : 0);
		vsbrc.bottom = vsbrc.bottom - (needHscroll ? _hscrollbar.measuredHeight : 0);
		Rect hsbrc = rc;
		hsbrc.right = hsbrc.right - (needVscroll ? _vscrollbar.measuredWidth : 0);
		hsbrc.top = hsbrc.bottom - (needHscroll ? _hscrollbar.measuredHeight : 0);
        if (_vscrollbar) {
		    _vscrollbar.layout(vsbrc);
            _vscrollbar.visibility = needVscroll ? Visibility.Visible : Visibility.Gone;
        }
        if (_hscrollbar) {
            _hscrollbar.layout(hsbrc);
            _hscrollbar.visibility = needHscroll ? Visibility.Visible : Visibility.Gone;
        }
		// client area
		_clientRect = rc;
        if (needVscroll)
		    _clientRect.right = vsbrc.left;
        if (needHscroll)
            _clientRect.bottom = hsbrc.top;
        updateScrollBars();
	}

}
