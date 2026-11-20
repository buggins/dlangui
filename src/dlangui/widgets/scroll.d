// Written in the D programming language.

/**

This module contains base implementation of scrolling capabilities for widgets


ScrollWidgetBase - abstract scrollable widget (used as a base for other widgets with scrolling)

ScrollWidget - widget which can scroll its content (directly usable class)


Synopsis:

----
import dlangui.widgets.scroll;

// Scroll view example
ScrollWidget scroll = new ScrollWidget("SCROLL1");
scroll.layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT);
WidgetGroup scrollContent = new VerticalLayout("CONTENT");
scrollContent.layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT);

TableLayout table2 = new TableLayout("TABLE2");
table2.colCount = 2;
// headers
table2.addChild((new TextWidget(null, "Parameter Name"d)).alignment(Align.Right | Align.VCenter));
table2.addChild((new TextWidget(null, "Edit Box to edit parameter"d)).alignment(Align.Left | Align.VCenter));
// row 1
table2.addChild((new TextWidget(null, "Parameter 1 name"d)).alignment(Align.Right | Align.VCenter));
table2.addChild((new EditLine("edit1", "Text 1"d)).layoutWidth(FILL_PARENT));
// row 2
table2.addChild((new TextWidget(null, "Parameter 2 name bla bla"d)).alignment(Align.Right | Align.VCenter));
table2.addChild((new EditLine("edit2", "Some text for parameter 2 blah blah blah"d)).layoutWidth(FILL_PARENT));
// row 3
table2.addChild((new TextWidget(null, "Param 3"d)).alignment(Align.Right | Align.VCenter));
table2.addChild((new EditLine("edit3", "Parameter 3 value"d)).layoutWidth(FILL_PARENT));
// row 4
table2.addChild((new TextWidget(null, "Param 4"d)).alignment(Align.Right | Align.VCenter));
table2.addChild((new EditLine("edit3", "Parameter 4 value shdjksdfh hsjdfas hdjkf hdjsfk ah"d)).layoutWidth(FILL_PARENT));
// row 5
table2.addChild((new TextWidget(null, "Param 5 - edit text here - blah blah blah"d)).alignment(Align.Right | Align.VCenter));
table2.addChild((new EditLine("edit3", "Parameter 5 value"d)).layoutWidth(FILL_PARENT));
// row 6
table2.addChild((new TextWidget(null, "Param 6 - just to fill content widget"d)).alignment(Align.Right | Align.VCenter));
table2.addChild((new EditLine("edit3", "Parameter 5 value"d)).layoutWidth(FILL_PARENT));
// row 7
table2.addChild((new TextWidget(null, "Param 7 - just to fill content widget"d)).alignment(Align.Right | Align.VCenter));
table2.addChild((new EditLine("edit3", "Parameter 5 value"d)).layoutWidth(FILL_PARENT));
// row 8
table2.addChild((new TextWidget(null, "Param 8 - just to fill content widget"d)).alignment(Align.Right | Align.VCenter));
table2.addChild((new EditLine("edit3", "Parameter 5 value"d)).layoutWidth(FILL_PARENT));
table2.margins(Rect(10,10,10,10)).layoutWidth(FILL_PARENT);
scrollContent.addChild(table2);

scrollContent.addChild(new TextWidget(null, "Now - some buttons"d));
scrollContent.addChild(new ImageTextButton("btn1", "fileclose", "Close"d));
scrollContent.addChild(new ImageTextButton("btn2", "fileopen", "Open"d));
scrollContent.addChild(new TextWidget(null, "And checkboxes"d));
scrollContent.addChild(new CheckBox("btn1", "CheckBox 1"d));
scrollContent.addChild(new CheckBox("btn2", "CheckBox 2"d));

scroll.contentWidget = scrollContent;

----

Copyright: Vadim Lopatin, 2014
License:   Boost License 1.0
Authors:   Vadim Lopatin, coolreader.org@gmail.com
*/
module dlangui.widgets.scroll;

import dlangui.widgets.widget;
import dlangui.widgets.controls;
import dlangui.widgets.scrollbar;
import std.conv;

/** Scroll bar visibility mode. */
enum ScrollBarMode {
    /** always invisible */
    Invisible,
    /** always visible */
    Visible,
    /** automatically show/hide scrollbar depending on content size */
    Auto,
    /** Scrollbar is provided by external control outside this widget */
    External,
}

/**
    Abstract scrollable widget

    Provides scroll bars and basic scrolling functionality.

 */
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
            _vscrollbar.scrollEvent = this;
            addChild(_vscrollbar);
        }
        if (_hscrollbarMode != ScrollBarMode.Invisible) {
            _hscrollbar = new ScrollBar("hscrollbar", Orientation.Horizontal);
            _hscrollbar.scrollEvent = this;
            addChild(_hscrollbar);
        }
    }

    /// vertical scrollbar mode
    @property ScrollBarMode vscrollbarMode() { return _vscrollbarMode; }
    @property void vscrollbarMode(ScrollBarMode m) { _vscrollbarMode = m; }
    /// horizontal scrollbar mode
    @property ScrollBarMode hscrollbarMode() { return _hscrollbarMode; }
    @property void hscrollbarMode(ScrollBarMode m) { _hscrollbarMode = m; }

    /// returns client area rectangle
    @property Rect clientRect() { return _clientRect; }

    /// process horizontal scrollbar event
    bool onHScroll(ScrollEvent event) {
        return true;
    }

    /// process vertical scrollbar event
    bool onVScroll(ScrollEvent event) {
        return true;
    }

    /// process mouse event; return true if event is processed by widget.
    override bool onMouseEvent(MouseEvent event) {
        if (event.action == MouseAction.Wheel) {
            if (event.flags == MouseFlag.Shift) {
                if (_hscrollbar) {
                    _hscrollbar.sendScrollEvent(event.wheelDelta > 0 ? ScrollAction.LineUp : ScrollAction.LineDown);
                    return true;
                }
            } else if (event.flags == 0) {
                if (_vscrollbar) {
                    _vscrollbar.sendScrollEvent(event.wheelDelta > 0 ? ScrollAction.LineUp : ScrollAction.LineDown);
                    return true;
                }
            }
        }
        return super.onMouseEvent(event);
    }

    /// handle scroll event
    override bool onScrollEvent(AbstractSlider source, ScrollEvent event) {
        if (source.orientation == Orientation.Horizontal) {
            return onHScroll(event);
        } else {
            return onVScroll(event);
        }
    }

    protected bool _insideChangeScrollbarVisibility;
    protected void checkIfNeededToChangeScrollbarVisibility() {
        if (_insideChangeScrollbarVisibility)
            return;
        bool needHScroll = false;
        bool needVScroll = false;
        {
            // decide with the client area of layout(), not the one left after the scrollbars: that would take
            // the space of a shown scrollbar twice and disagree with layout() (#996)
            Rect clientRect = _clientRect;
            scope(exit) _clientRect = clientRect;
            _clientRect = _clientRectWithoutScrollbars;
            checkIfScrollbarsNeeded(needHScroll, needVScroll);
        }
        bool hscrollVisible = _hscrollbar && _hscrollbar.visibility == Visibility.Visible;
        bool vscrollVisible = _vscrollbar && _vscrollbar.visibility == Visibility.Visible;
        bool needChange = false;
        // External scrollbars are shown and hidden by their owner (layout() doesn't change them)
        if (_hscrollbar && _hscrollbarMode != ScrollBarMode.External && hscrollVisible != needHScroll)
            needChange = true;
        if (_vscrollbar && _vscrollbarMode != ScrollBarMode.External && vscrollVisible != needVScroll)
            needChange = true;
        if (needChange) {
            _insideChangeScrollbarVisibility = true;
            scope(exit) _insideChangeScrollbarVisibility = false;
            if (_insideLayout) {
                // called by layout(): lay out again in the rectangle it got, without running subclass layouts
                // again (EditBox would place its panels a second time inside the area left after them, #996)
                ScrollWidgetBase.layout(_pos);
            } else {
                // outside layout(): through the subclass. A subclass that lays out the scroll area in a part of
                // its rectangle must set _pos to its whole rectangle after super.layout(), as EditBox does
                layout(_pos);
            }
        }
    }

    // client area without scrollbars in the last layout(), for the decision in
    // checkIfNeededToChangeScrollbarVisibility() (#996)
    private Rect _clientRectWithoutScrollbars;
    // set while layout() runs
    private bool _insideLayout;

    /// update scrollbar positions
    protected void updateScrollBars() {
        if (_hscrollbar) {
            updateHScrollBar();
        }
        if (_vscrollbar) {
            updateVScrollBar();
        }
        checkIfNeededToChangeScrollbarVisibility();
    }

    // rectangles of the scrollbars in the last layout(): a layout nested in updateScrollBars() changes them
    private Rect _vscrollbarRect;
    private Rect _hscrollbarRect;

    /// Called at the end of layout(): lays out again scrollbars that requested a layout when updateScrollBars()
    /// set their range or page size. Otherwise the next paint lays out the whole window, which happened after
    /// every window resize (#980). Outside layout() the request stays: it makes the window lay out and repaint.
    private void layoutScrollBarsIfNeeded() {
        if (_vscrollbar && _vscrollbarMode != ScrollBarMode.External && _vscrollbar.needLayout)
            _vscrollbar.layout(_vscrollbarRect);
        if (_hscrollbar && _hscrollbarMode != ScrollBarMode.External && _hscrollbar.needLayout)
            _hscrollbar.layout(_hscrollbarRect);
    }

    public @property ScrollBar hscrollbar() { return _hscrollbar; }
    public @property ScrollBar vscrollbar() { return _vscrollbar; }

    public @property void hscrollbar(ScrollBar hscroll) {
        if (_hscrollbar) {
            removeChild(_hscrollbar);
            destroy(_hscrollbar);
            _hscrollbar = null;
            _hscrollbarMode = ScrollBarMode.Invisible;
        }
        if (hscroll) {
            _hscrollbar = hscroll;
            _hscrollbarMode = ScrollBarMode.External;
        }
    }

    public @property void vscrollbar(ScrollBar vscroll) {
        if (_vscrollbar) {
            removeChild(_vscrollbar);
            destroy(_vscrollbar);
            _vscrollbar = null;
            _vscrollbarMode = ScrollBarMode.Invisible;
        }
        if (vscroll) {
            _vscrollbar = vscroll;
            _vscrollbarMode = ScrollBarMode.External;
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

    protected void drawExtendedArea(DrawBuf buf) {
    }

    /// Draw widget at its position to buffer
    override void onDraw(DrawBuf buf) {
        if (visibility != Visibility.Visible)
            return;
        super.onDraw(buf);
        Rect rc = _pos;
        applyMargins(rc);
        {
            auto _ = ClipRectSaver(buf, rc, alpha);
            DrawableRef bg = backgroundDrawable;
            if (!bg.isNull) {
                bg.drawTo(buf, rc, state);
            }
            applyPadding(rc);
            if (_hscrollbar)
                _hscrollbar.onDraw(buf);
            if (_vscrollbar)
                _vscrollbar.onDraw(buf);
            drawClientClipped(buf, alpha);
            drawExtendedAreaClipped(buf, rc, alpha);
        }

        _needDraw = false;
    }

    // draws the client area clipped to it
    private void drawClientClipped(DrawBuf buf, uint alpha) {
        auto _ = ClipRectSaver(buf, _clientRect, alpha);
        drawClient(buf);
    }

    // draws the extended area: no clipping, except at the bottom of the client area
    private void drawExtendedAreaClipped(DrawBuf buf, Rect rc, uint alpha) {
        Rect clipr = rc;
        clipr.bottom = _clientRect.bottom;
        auto _ = ClipRectSaver(buf, clipr, alpha);
        drawExtendedArea(buf);
    }

    /// calculate full content size in pixels
    Point fullContentSize() {
        // override it
        Point sz;
        return sz;
    }

    /// calculate full content size in pixels including widget borders / margins
    Point fullContentSizeWithBorders() {
        Point sz = fullContentSize;
        Rect paddingrc = padding;
        Rect marginsrc = margins;
        sz.x += paddingrc.left + paddingrc.right + marginsrc.left + marginsrc.right;
        sz.y += paddingrc.top + paddingrc.bottom + marginsrc.top + marginsrc.bottom;
        return sz;
    }

    // override to set minimum scrollwidget size - default 100x100
    Point minimumVisibleContentSize() {
        return Point(100,100);
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
        int vsbw = 0;
        int hsbh = 0;
        if (_hscrollbar && (_hscrollbarMode == ScrollBarMode.Visible || _hscrollbarMode == ScrollBarMode.Auto)) {
            Visibility oldVisibility = _hscrollbar.visibility;
            _hscrollbar.visibility = Visibility.Visible;
            _hscrollbar.measure(pwidth, pheight);
            hsbh = _hscrollbar.measuredHeight;
            _hscrollbar.visibility = oldVisibility;
        }
        if (_vscrollbar && (_vscrollbarMode == ScrollBarMode.Visible || _vscrollbarMode == ScrollBarMode.Auto)) {
            Visibility oldVisibility = _vscrollbar.visibility;
            _vscrollbar.visibility = Visibility.Visible;
            _vscrollbar.measure(pwidth, pheight);
            vsbw = _vscrollbar.measuredWidth;
            _vscrollbar.visibility = oldVisibility;
        }
        Point sz = minimumVisibleContentSize();
        
        //if (_hscrollbar && _hscrollbarMode == ScrollBarMode.Visible) {
            sz.y += hsbh;
        //}
        //if (_vscrollbar && _vscrollbarMode == ScrollBarMode.Visible) {
            sz.x += vsbw;
        //}

        measuredContent(parentWidth, parentHeight, sz.x, sz.y);
    }

    /// override to support modification of client rect after change, e.g. apply offset
    protected void handleClientRectLayout(ref Rect rc) {
    }

    /// measured width of the vertical scrollbar (x) and height of the horizontal one (y); 0 for a scrollbar not
    /// created (ScrollBarMode.Invisible, #985)
    protected Point scrollbarSizes() {
        return Point(_vscrollbar ? _vscrollbar.measuredWidth : 0, _hscrollbar ? _hscrollbar.measuredHeight : 0);
    }

    /// content size compared with the client area by the Auto scrollbar decision; override when the scroll range
    /// differs from fullContentSize() (EditBox: room after the longest line, #991)
    protected Point autoScrollbarContentSize() {
        return fullContentSize();
    }

    /// decides which scrollbars are shown: Visible ones always, Auto ones when autoScrollbarContentSize() doesn't
    /// fit into the client area
    protected void checkIfScrollbarsNeeded(ref bool needHScroll, ref bool needVScroll) {
        needHScroll = _hscrollbar && (_hscrollbarMode == ScrollBarMode.Visible || _hscrollbarMode == ScrollBarMode.Auto);
        needVScroll = _vscrollbar && (_vscrollbarMode == ScrollBarMode.Visible || _vscrollbarMode == ScrollBarMode.Auto);
        if (!needHScroll && !needVScroll)
            return; // not needed
        if (_hscrollbarMode != ScrollBarMode.Auto && _vscrollbarMode != ScrollBarMode.Auto)
            return; // no auto scrollbars
        // either h or v scrollbar is in auto mode
        Point contentSize = autoScrollbarContentSize();
        int contentWidth = contentSize.x;
        int contentHeight = contentSize.y;
        int clientWidth = _clientRect.width;
        int clientHeight = _clientRect.height;

        Point sb = scrollbarSizes();
        int clientWidthWithScrollbar = clientWidth - sb.x;
        int clientHeightWithScrollbar = clientHeight - sb.y;

        if (_hscrollbarMode == ScrollBarMode.Auto && _vscrollbarMode == ScrollBarMode.Auto) {
            // both scrollbars in auto mode
            bool xFits = contentWidth <= clientWidth;
            bool yFits = contentHeight <= clientHeight;
            if (!xFits && !yFits) {
                // none fits, need both scrollbars
            } else if (xFits && yFits) {
                // everything fits!
                needHScroll = false;
                needVScroll = false;
            } else if (xFits) {
                // only X fits
                if (contentWidth <= clientWidthWithScrollbar)
                    needHScroll = false; // disable hscroll
            } else { // yFits
                // only Y fits
                if (contentHeight <= clientHeightWithScrollbar)
                    needVScroll = false; // disable vscroll
            }
        } else if (_hscrollbarMode == ScrollBarMode.Auto) {
            // only hscroll is in auto mode
            if (needVScroll)
                clientWidth = clientWidthWithScrollbar;
            needHScroll = contentWidth > clientWidth;
        } else {
            // only vscroll is in auto mode
            if (needHScroll)
                clientHeight = clientHeightWithScrollbar;
            needVScroll = contentHeight > clientHeight;
        }
    }

    /// Set widget rectangle to specified value and layout widget contents. (Step 2 of two phase layout).
    override void layout(Rect rc) {
        if (visibility == Visibility.Gone) {
            return;
        }
        _pos = rc;
        _needLayout = false;
        immutable bool wasInsideLayout = _insideLayout;
        _insideLayout = true;
        scope(exit) _insideLayout = wasInsideLayout;
        applyMargins(rc);
        applyPadding(rc);

        // client area - initial setup w/o scrollbars
        _clientRect = rc;
        handleClientRectLayout(_clientRect);
        _clientRectWithoutScrollbars = _clientRect;

        bool needHscroll;
        bool needVscroll;

        checkIfScrollbarsNeeded(needHscroll, needVscroll);

        // scrollbars
        Point sb = scrollbarSizes();
        Rect vsbrc = rc;
        vsbrc.left = vsbrc.right - (needVscroll ? sb.x : 0);
        vsbrc.bottom = vsbrc.bottom - (needHscroll ? sb.y : 0);
        Rect hsbrc = rc;
        hsbrc.right = hsbrc.right - (needVscroll ? sb.x : 0);
        hsbrc.top = hsbrc.bottom - (needHscroll ? sb.y : 0);
        if (_vscrollbar && _vscrollbarMode != ScrollBarMode.External) {
            _vscrollbar.visibility = needVscroll ? Visibility.Visible : Visibility.Gone;
            _vscrollbar.layout(vsbrc);
        }
        if (_hscrollbar && _hscrollbarMode != ScrollBarMode.External) {
            _hscrollbar.visibility = needHscroll ? Visibility.Visible : Visibility.Gone;
            _hscrollbar.layout(hsbrc);
        }
        _vscrollbarRect = vsbrc;
        _hscrollbarRect = hsbrc;

        _clientRect = rc;
        if (needVscroll)
            _clientRect.right = vsbrc.left;
        if (needHscroll)
            _clientRect.bottom = hsbrc.top;
        handleClientRectLayout(_clientRect);
        updateScrollBars();
        layoutScrollBarsIfNeeded();
    }

    /// keep the visible area from going above or left of the content (#964)
    protected void clampScrollToContent() {
        if (_visibleScrollableArea.left < _fullScrollableArea.left)
            _visibleScrollableArea.offset(_fullScrollableArea.left - _visibleScrollableArea.left, 0);
        if (_visibleScrollableArea.top < _fullScrollableArea.top)
            _visibleScrollableArea.offset(0, _fullScrollableArea.top - _visibleScrollableArea.top);
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
        clampScrollToContent();
        if (_visibleScrollableArea != oldRect)
            requestLayout();
    }
}

/**
    Widget which can show content of widget group with optional scrolling

    If size of content widget exceeds available space, allows to scroll it.
 */
class ScrollWidget :  ScrollWidgetBase {
    protected Widget _contentWidget;
    @property Widget contentWidget() { return _contentWidget; }
    @property ScrollWidget contentWidget(Widget newContent) {
        if (_contentWidget) {
            removeChild(childIndex(_contentWidget));
            destroy(_contentWidget);
        }
        _contentWidget = newContent;
        addChild(_contentWidget);
        requestLayout();
        return this;
    }
    /// empty parameter list constructor - for usage by factory
    this() {
        this(null);
    }
    /// create with ID parameter
    this(string ID, ScrollBarMode hscrollbarMode = ScrollBarMode.Visible, ScrollBarMode vscrollbarMode = ScrollBarMode.Visible) {
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
        fullContentSize(); // measures the content widget
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
        clampScrollToContent();
        super.updateScrollBars();
    }

    /// lay out the content widget at the current scroll position
    protected void layoutContent() {
        if (_contentWidget) {
            Point sz = fullContentSize();
            Point p = scrollPos;
            _contentWidget.layout(Rect(_clientRect.left - p.x, _clientRect.top - p.y, _clientRect.left + sz.x - p.x, _clientRect.top + sz.y - p.y));
        }
    }

    override protected void drawClient(DrawBuf buf) {
        if (_contentWidget) {
            layoutContent();
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
            scrollTo(scrollPos.x - _clientRect.width / 10, scrollPos.y);
        } else if (event.action == ScrollAction.LineDown) {
            scrollTo(scrollPos.x + _clientRect.width / 10, scrollPos.y);
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
            scrollTo(scrollPos.x, scrollPos.y - _clientRect.height / 10);
        } else if (event.action == ScrollAction.LineDown) {
            scrollTo(scrollPos.x, scrollPos.y + _clientRect.height / 10);        }
        return true;
    }

    void makeWidgetVisible(Widget widget, bool alignHorizontally = true, bool alignVertically = true) {
        if (!widget || widget.visibility == Visibility.Gone)
            return;
        if (!_contentWidget || !_contentWidget.isChild(widget))
            return;
        // the content is laid out when drawn: a widget shown since the last draw has no position yet (#964)
        layoutContent();
        Rect wpos = widget.pos;
        Rect cpos = _contentWidget.pos;
        wpos.offset(-cpos.left, -cpos.top);
        makeRectVisible(wpos, alignHorizontally, alignVertically);
    }
}

// scroll widgets lay out again the scrollbars they update in layout(): no layout of the window is left to the next
// paint after a resize (#980)
unittest {
    import dlangui.widgets.styles : useTestTheme;
    auto _ = useTestTheme();

    auto scroll = new ScrollWidget("scroll");
    scope(exit) destroy(scroll);
    scroll.contentWidget = new Widget("content").minWidth(1000).minHeight(1000);
    // no measure(): scrollbars load their images there, and unittests have no image cache
    foreach (rc; [Rect(0, 0, 200, 150), Rect(0, 0, 300, 250), Rect(10, 20, 260, 170)]) {
        scroll.layout(rc);
        assert(!scroll.needLayout);
        assert(!scroll.vscrollbar.needLayout && !scroll.hscrollbar.needLayout);
        assert(scroll.vscrollbar.pageSize == rc.height && scroll.hscrollbar.pageSize == rc.width);
        // laid out again in their own places: the vertical one on the right edge, the horizontal one at the bottom
        assert(scroll.vscrollbar.pos.top == rc.top && scroll.vscrollbar.pos.right == rc.right);
        assert(scroll.hscrollbar.pos.left == rc.left && scroll.hscrollbar.pos.bottom == rc.bottom);
    }
    // outside layout() a new range still requests a layout: it makes the window lay out and repaint
    scroll.contentWidget.minHeight(2000);
    scroll.updateScrollBars();
    assert(scroll.vscrollbar.maxValue == 2000);
    assert(scroll.vscrollbar.needLayout);
}

version (unittest) {
    // ScrollBar.measure() loads images, and unittests have no image cache: scrollbars of a fixed size instead
    private class FixedSizeScrollBar : ScrollBar {
        this(string id, Orientation orientation) {
            super(id, orientation);
        }
        override void measure(int parentWidth, int parentHeight) {
            if (orientation == Orientation.Vertical)
                measuredContent(parentWidth, parentHeight, 16, 100);
            else
                measuredContent(parentWidth, parentHeight, 100, 16);
        }
    }
    // replaces the scrollbars a scroll widget created by FixedSizeScrollBars
    private void useFixedSizeScrollBars(ScrollWidgetBase scroll) {
        foreach (vertical; [false, true]) {
            ScrollBar* sb = vertical ? &scroll._vscrollbar : &scroll._hscrollbar;
            if (!*sb)
                continue;
            scroll.removeChild(*sb);
            destroy(*sb);
            *sb = new FixedSizeScrollBar(vertical ? "vscrollbar" : "hscrollbar",
                                         vertical ? Orientation.Vertical : Orientation.Horizontal);
            (*sb).scrollEvent = scroll;
            scroll.addChild(*sb);
        }
    }
}

// auto scrollbars: the space for the vertical scrollbar is its width, and a missing scrollbar takes none (#985)
unittest {
    import dlangui.widgets.styles : useTestTheme;
    auto _ = useTestTheme();

    ScrollWidget create(ScrollBarMode hmode, ScrollBarMode vmode, int contentWidth, int contentHeight) {
        auto scroll = new ScrollWidget("scroll", hmode, vmode);
        useFixedSizeScrollBars(scroll);
        scroll.contentWidget = new Widget("content").minWidth(contentWidth).minHeight(contentHeight);
        scroll.measure(200, 150);
        scroll.layout(Rect(0, 0, 200, 150));
        return scroll;
    }

    // width of the vertical scrollbar, with the padding of its style
    auto vsb = new FixedSizeScrollBar("vscrollbar", Orientation.Vertical);
    vsb.measure(200, 150);
    immutable int vsbWidth = vsb.measuredWidth;
    destroy(vsb);

    // too high, and exactly as wide as the client area with the vertical scrollbar: no horizontal scrollbar
    {
        auto scroll = create(ScrollBarMode.Auto, ScrollBarMode.Auto, 200 - vsbWidth, 1000);
        scope(exit) destroy(scroll);
        assert(scroll.vscrollbar.visibility == Visibility.Visible);
        assert(scroll.hscrollbar.visibility == Visibility.Gone);
    }
    // one pixel wider: both
    {
        auto scroll = create(ScrollBarMode.Auto, ScrollBarMode.Auto, 200 - vsbWidth + 1, 1000);
        scope(exit) destroy(scroll);
        assert(scroll.vscrollbar.visibility == Visibility.Visible);
        assert(scroll.hscrollbar.visibility == Visibility.Visible);
    }
    // no horizontal scrollbar (ScrollBarMode.Invisible creates none)
    foreach (contentHeight; [1000, 100]) {
        auto scroll = create(ScrollBarMode.Invisible, ScrollBarMode.Auto, 150, contentHeight);
        scope(exit) destroy(scroll);
        assert(scroll.vscrollbar.visibility == (contentHeight > 150 ? Visibility.Visible : Visibility.Gone));
    }
    // no vertical scrollbar
    foreach (contentWidth; [1000, 100]) {
        auto scroll = create(ScrollBarMode.Auto, ScrollBarMode.Invisible, contentWidth, 100);
        scope(exit) destroy(scroll);
        assert(scroll.hscrollbar.visibility == (contentWidth > 200 ? Visibility.Visible : Visibility.Gone));
    }
}

// the Auto scrollbar decision compares autoScrollbarContentSize(), which subclasses override (EditBox: room after
// the longest line), with the client area, in each combination of Auto and Visible modes (#991)
unittest {
    import dlangui.widgets.styles : useTestTheme;
    auto _ = useTestTheme();

    // content size given by the test, not the content widget's size
    static class ContentSizeScrollWidget : ScrollWidget {
        Point content;
        this(ScrollBarMode hmode, ScrollBarMode vmode) {
            super("scroll", hmode, vmode);
            contentWidget = new Widget("content").minWidth(10).minHeight(10);
        }
        override protected Point autoScrollbarContentSize() {
            return content;
        }
    }
    // client area 200 x 150; returns [horizontal visible, vertical visible]
    bool[2] scrollbarsFor(ScrollBarMode hmode, ScrollBarMode vmode, Point content) {
        auto scroll = new ContentSizeScrollWidget(hmode, vmode);
        scope(exit) destroy(scroll);
        useFixedSizeScrollBars(scroll);
        scroll.content = content;
        scroll.measure(200, 150);
        scroll.layout(Rect(0, 0, 200, 150));
        return [scroll.hscrollbar.visibility == Visibility.Visible, scroll.vscrollbar.visibility == Visibility.Visible];
    }
    // scrollbar sizes, with the padding of their style
    auto sbs = new ContentSizeScrollWidget(ScrollBarMode.Auto, ScrollBarMode.Auto);
    useFixedSizeScrollBars(sbs);
    sbs.measure(200, 150);
    immutable Point sb = sbs.scrollbarSizes();
    destroy(sbs);

    alias Auto = ScrollBarMode.Auto;
    alias Visible = ScrollBarMode.Visible;
    // both Auto
    assert(scrollbarsFor(Auto, Auto, Point(200, 150)) == [false, false]);
    assert(scrollbarsFor(Auto, Auto, Point(200 - sb.x, 151)) == [false, true]);
    assert(scrollbarsFor(Auto, Auto, Point(200 - sb.x + 1, 151)) == [true, true]);
    assert(scrollbarsFor(Auto, Auto, Point(201, 150 - sb.y)) == [true, false]);
    assert(scrollbarsFor(Auto, Auto, Point(201, 150 - sb.y + 1)) == [true, true]);
    // horizontal Auto, vertical always shown
    assert(scrollbarsFor(Auto, Visible, Point(200 - sb.x, 10)) == [false, true]);
    assert(scrollbarsFor(Auto, Visible, Point(200 - sb.x + 1, 10)) == [true, true]);
    // vertical Auto, horizontal always shown
    assert(scrollbarsFor(Visible, Auto, Point(10, 150 - sb.y)) == [true, false]);
    assert(scrollbarsFor(Visible, Auto, Point(10, 150 - sb.y + 1)) == [true, true]);
}

// the scrollbar recheck after layout() agrees with layout(), and a layout it starts doesn't run subclass layouts
// again (#996)
unittest {
    import dlangui.widgets.styles : useTestTheme;
    auto _ = useTestTheme();

    // counts layouts; like EditBox with a panel, lays out the scroll area below a 20 px panel
    static class CountingScrollWidget : ScrollWidget {
        int layouts;
        Point[] contentSizes; // returned by autoScrollbarContentSize(), the last one repeated
        int contentSizeCalls;
        this() {
            super("scroll", ScrollBarMode.Auto, ScrollBarMode.Auto);
            contentWidget = new Widget("content").minWidth(10).minHeight(10);
            useFixedSizeScrollBars(this);
        }
        override void layout(Rect rc) {
            layouts++;
            super.layout(Rect(rc.left, rc.top + 20, rc.right, rc.bottom));
            _pos = rc; // like EditBox
        }
        override protected Point autoScrollbarContentSize() {
            size_t i = contentSizeCalls++;
            return contentSizes[i < contentSizes.length ? i : $ - 1];
        }
    }
    CountingScrollWidget create(Point[] contentSizes) {
        auto scroll = new CountingScrollWidget;
        scroll.contentSizes = contentSizes;
        scroll.measure(200, 170);
        scroll.layout(Rect(0, 0, 200, 170)); // scroll area 200 x 150
        return scroll;
    }
    Point sb;
    {
        auto scroll = create([Point(10, 10)]);
        scope(exit) destroy(scroll);
        sb = scroll.scrollbarSizes();
    }

    // too high, and narrower than the client area with the vertical scrollbar, but by less than one more
    // scrollbar: vertical scrollbar only, decided once
    {
        auto scroll = create([Point(200 - sb.x - sb.x / 2, 1000)]);
        scope(exit) destroy(scroll);
        assert(scroll.vscrollbar.visibility == Visibility.Visible);
        assert(scroll.hscrollbar.visibility == Visibility.Gone);
        assert(scroll.layouts == 1);
        assert(scroll.contentSizeCalls == 2); // decided by layout() and by the recheck: no second layout
        assert(scroll._clientRect.top == 20);
        // content grows outside layout(): the recheck lays out again, through the subclass, in the same rectangle
        scroll.contentSizes = [Point(1000, 1000)];
        scroll.contentSizeCalls = 0;
        scroll.updateScrollBars();
        assert(scroll.hscrollbar.visibility == Visibility.Visible);
        assert(scroll.layouts == 2);
        assert(scroll.pos == Rect(0, 0, 200, 170));
        assert(scroll._clientRect.top == 20);
    }
    // content size changes while layout() runs: the recheck lays out again in the same rectangle, without the
    // subclass taking the panel's room a second time
    {
        auto scroll = create([Point(10, 10), Point(10, 1000)]);
        scope(exit) destroy(scroll);
        assert(scroll.vscrollbar.visibility == Visibility.Visible);
        assert(scroll.layouts == 1);
        assert(scroll._clientRect.top == 20);
    }
    // an External scrollbar, shown by its owner, doesn't make the recheck lay out again
    {
        auto hsb = new FixedSizeScrollBar("external", Orientation.Horizontal);
        scope(exit) destroy(hsb);
        auto scroll = new CountingScrollWidget;
        scope(exit) destroy(scroll);
        scroll.hscrollbar = hsb;
        scroll.contentSizes = [Point(10, 10)];
        scroll.measure(200, 170);
        scroll.layout(Rect(0, 0, 200, 170));
        assert(hsb.visibility == Visibility.Visible);
        scroll.updateScrollBars();
        assert(scroll.layouts == 1);
    }
}
