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

class ScrollWidgetBase :  WidgetGroup, OnScrollHandler {
    protected ScrollBarMode _vscrollbarMode;
    protected ScrollBarMode _hscrollbarMode;
    /// vertical scrollbar control
	protected ScrollBar _vscrollbar;
    /// horizontal scrollbar control
	protected ScrollBar _hscrollbar;
    /// inner area, excluding additional controls like scrollbars
	protected Rect _clientRect;

    protected Rect _fullScrollableArea;
    protected Rect _visibleScrollableArea;

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

    /// update scrollbar positions
    protected void updateScrollBars() {
        if (_hscrollbar) {
            updateHScrollBar();
        }
        if (_vscrollbar) {
            updateVScrollBar();
        }
    }

    /// update horizontal scrollbar widget position
    protected void updateHScrollBar() {
        // default implementation: use _fullScrollableArea, _visibleScrollableArea: override it if necessary
        _hscrollbar.setRange(0, _fullScrollableArea.width);
        _hscrollbar.pageSize(_visibleScrollableArea.width);
        _hscrollbar.position(_visibleScrollableArea.left - _fullScrollableArea.left);
    }

    /// update verticat scrollbar widget position
    protected void updateVScrollBar() {
        // default implementation: use _fullScrollableArea, _visibleScrollableArea: override it if necessary
        _vscrollbar.setRange(0, _fullScrollableArea.height);
        _vscrollbar.pageSize(_visibleScrollableArea.height);
        _vscrollbar.position(_visibleScrollableArea.top - _fullScrollableArea.top);
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
        {
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
            // apply clipping
            {
		        auto saver2 = ClipRectSaver(buf, _clientRect, alpha);
		        drawClient(buf);
            }
        }

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

    void makeRectVisible(Rect rc, bool alignHorizontally = true, bool alignVertically = true) {
        if (rc.isInsideOf(_visibleScrollableArea))
            return;
        Rect oldRect = _visibleScrollableArea;
        if (alignHorizontally && rc.right > _visibleScrollableArea.right)
            _visibleScrollableArea.offset(rc.right - _visibleScrollableArea.right, 0);
        if (alignVertically && rc.bottom > _visibleScrollableArea.bottom)
            _visibleScrollableArea.offset(0, rc.bottom - _visibleScrollableArea.bottom);
        if (alignHorizontally && rc.left < _visibleScrollableArea.left)
            _visibleScrollableArea.offset(rc.left - _visibleScrollableArea.left, 0);
        if (alignVertically && rc.top < _visibleScrollableArea.top)
            _visibleScrollableArea.offset(0, rc.top - _visibleScrollableArea.top);
        if (_visibleScrollableArea != oldRect)
            requestLayout();
    }
}

/**
    Widget which can show content of widget group with optional scrolling.
 */
class ScrollWidget :  ScrollWidgetBase {
    protected WidgetGroup _contentWidget;
    @property WidgetGroup contentWidget() { return _contentWidget; }
    @property ScrollWidget contentWidget(WidgetGroup newContent) { 
        if (_contentWidget) {
            removeChild(childIndex(_contentWidget));
            destroy(_contentWidget);
        }
        _contentWidget = newContent;
        addChild(_contentWidget);
        requestLayout();
        return this;
    }
	this(string ID = null, ScrollBarMode hscrollbarMode = ScrollBarMode.Visible, ScrollBarMode vscrollbarMode = ScrollBarMode.Visible) {
		super(ID, hscrollbarMode, vscrollbarMode);
    }

    /// calculate full content size in pixels
    override Point fullContentSize() {
        // override it
        Point sz;
        if (_contentWidget) {
            _contentWidget.measure(SIZE_UNSPECIFIED, SIZE_UNSPECIFIED);
            sz.x = _contentWidget.measuredWidth;
            sz.y = _contentWidget.measuredHeight;
        }
        _fullScrollableArea.right = sz.x;
        _fullScrollableArea.bottom = sz.y;
        return sz;
    }

    /// update scrollbar positions
    override protected void updateScrollBars() {
        Point sz = fullContentSize();
        _visibleScrollableArea.right = _visibleScrollableArea.left + _clientRect.width;
        _visibleScrollableArea.bottom = _visibleScrollableArea.top + _clientRect.height;
        // move back if scroll is too big after window resize
        int extrax = _visibleScrollableArea.right - _fullScrollableArea.right;
        int extray = _visibleScrollableArea.bottom - _fullScrollableArea.bottom;
        if (extrax > _visibleScrollableArea.left)
            extrax = _visibleScrollableArea.left;
        if (extray > _visibleScrollableArea.top)
            extray = _visibleScrollableArea.top;
        if (extrax < 0)
            extrax = 0;
        if (extray < 0)
            extray = 0;
        _visibleScrollableArea.offset(-extrax, -extray);
        super.updateScrollBars();
    }

	override protected void drawClient(DrawBuf buf) {
        if (_contentWidget) {
            Point sz = fullContentSize();
            Point p = scrollPos;
            _contentWidget.layout(Rect(_pos.left - p.x, _pos.top - p.y, _pos.left + sz.x - p.x, _pos.top + sz.y - p.y));
            _contentWidget.onDraw(buf);
        }
    }


    @property Point scrollPos() {
        return Point(_visibleScrollableArea.left - _fullScrollableArea.left, _visibleScrollableArea.top - _fullScrollableArea.top);
    }

    protected void scrollTo(int x, int y) {
        if (x > _fullScrollableArea.right - _visibleScrollableArea.width)
            x = _fullScrollableArea.right - _visibleScrollableArea.width;
        if (y > _fullScrollableArea.bottom - _visibleScrollableArea.height)
            y = _fullScrollableArea.bottom - _visibleScrollableArea.height;
        if (x < 0)
            x = 0;
        if (y < 0)
            y = 0;
        _visibleScrollableArea.left = x;
        _visibleScrollableArea.top = y;
        updateScrollBars();
        invalidate();
    }

    /// process horizontal scrollbar event
    override bool onHScroll(ScrollEvent event) {
        if (event.action == ScrollAction.SliderMoved || event.action == ScrollAction.SliderReleased) {
            scrollTo(event.position, scrollPos.y);
        } else if (event.action == ScrollAction.PageUp) {
            scrollTo(scrollPos.x - _clientRect.width * 3 / 4, scrollPos.y);
        } else if (event.action == ScrollAction.PageDown) {
            scrollTo(scrollPos.x + _clientRect.width * 3 / 4, scrollPos.y);
        } else if (event.action == ScrollAction.LineUp) {
            scrollTo(scrollPos.x - _clientRect.width / 20, scrollPos.y);
        } else if (event.action == ScrollAction.LineDown) {
            scrollTo(scrollPos.x + _clientRect.width / 20, scrollPos.y);
        }
        return true;
    }

    /// process vertical scrollbar event
    override bool onVScroll(ScrollEvent event) {
        if (event.action == ScrollAction.SliderMoved || event.action == ScrollAction.SliderReleased) {
            scrollTo(scrollPos.x, event.position);
        } else if (event.action == ScrollAction.PageUp) {
            scrollTo(scrollPos.x, scrollPos.y - _clientRect.height * 3 / 4);
        } else if (event.action == ScrollAction.PageDown) {
            scrollTo(scrollPos.x, scrollPos.y + _clientRect.height * 3 / 4);
        } else if (event.action == ScrollAction.LineUp) {
            scrollTo(scrollPos.x, scrollPos.y - _clientRect.height / 20);
        } else if (event.action == ScrollAction.LineDown) {
            scrollTo(scrollPos.x, scrollPos.y + _clientRect.height / 20);
        }
        return true;
    }

    void makeWidgetVisible(Widget widget, bool alignHorizontally = true, bool alignVertically = true) {
        if (!widget || !widget.visibility == Visibility.Gone)
            return;
        if (!_contentWidget || !_contentWidget.isChild(widget))
            return;
        Rect wpos = widget.pos;
        Rect cpos = _contentWidget.pos;
        wpos.offset(-cpos.left, -cpos.top);
        makeRectVisible(wpos, alignHorizontally, alignVertically);
    }
}
