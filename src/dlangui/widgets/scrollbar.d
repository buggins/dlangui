// Written in the D programming language.

/**
This module contains simple scrollbar-like controls implementation.

ScrollBar - scrollbar control

SliderWidget - slider control



Synopsis:

----
import dlangui.widgets.scrollbar;

----

Copyright: Vadim Lopatin, 2014
License:   Boost License 1.0
Authors:   Vadim Lopatin, coolreader.org@gmail.com
*/
module dlangui.widgets.scrollbar;


import dlangui.widgets.widget;
import dlangui.widgets.layouts;
import dlangui.widgets.controls;
import dlangui.core.events;
import dlangui.core.stdaction;

private import std.algorithm;
private import std.conv : to;
private import std.utf : toUTF32;

/// scroll event handler interface
interface OnScrollHandler {
    /// handle scroll event
    bool onScrollEvent(AbstractSlider source, ScrollEvent event);
}

/// base class for widgets like scrollbars and sliders
class AbstractSlider : WidgetGroup {
    protected int _minValue = 0;
    protected int _maxValue = 100;
    protected int _pageSize = 30;
    protected int _position = 20;

    /// create with ID parameter
    this(string ID) {
        super(ID);
    }

    /// scroll event listeners
    Signal!OnScrollHandler scrollEvent;

    /// returns slider position
    @property int position() const { return _position; }
    /// sets new slider position
    @property AbstractSlider position(int newPosition) { 
        if (_position != newPosition) {
            _position = newPosition;
            onPositionChanged();
        }
        return this;
    }
    protected void onPositionChanged() {
        requestLayout();
    }
    /// returns slider range min value
    @property int minValue() const { return _minValue; }
    /// sets slider range min value
    @property AbstractSlider minValue(int v) { _minValue = v; return this; }
    /// returns slider range max value
    @property int maxValue() const { return _maxValue; }
    /// sets slider range max value
    @property AbstractSlider maxValue(int v) { _maxValue = v; return this; }



    /// page size (visible area size)
    @property int pageSize() const { return _pageSize; }
    /// set page size (visible area size)
    @property AbstractSlider pageSize(int size) {
        if (_pageSize != size) {
            _pageSize = size;
            requestLayout();
        }
        return this;
    }

    /// set int property value, for ML loaders
    //mixin(generatePropertySettersMethodOverride("setIntProperty", "int",
    //      "minValue", "maxValue", "pageSize", "position"));
    /// set int property value, for ML loaders
    override bool setIntProperty(string name, int value) {
        if (name.equal("orientation")) { // use same value for all sides
            orientation = cast(Orientation)value;
            return true;
        }
        mixin(generatePropertySetters("minValue", "maxValue", "pageSize", "position"));
        return super.setIntProperty(name, value);
    }

    /// set new range (min and max values for slider)
    AbstractSlider setRange(int min, int max) {
        if (_minValue != min || _maxValue != max) {
            _minValue = min;
            _maxValue = max;
            requestLayout();
        }
        return this;
    }

    bool sendScrollEvent(ScrollAction action) {
        return sendScrollEvent(action, _position);
    }

    bool sendScrollEvent(ScrollAction action, int position) {
        if (!scrollEvent.assigned)
            return false;
        ScrollEvent event = new ScrollEvent(action, _minValue, _maxValue, _pageSize, position);
        bool res = scrollEvent(this, event);
        if (event.positionChanged) {
            _position = event.position;
            if (_position > _maxValue)
                _position = _maxValue;
            if (_position < _minValue)
                _position = _minValue;
            onPositionChanged();
        }
        return true;
    }

    protected Orientation _orientation = Orientation.Vertical;
    /// returns scrollbar orientation (Vertical, Horizontal)
    @property Orientation orientation() { return _orientation; }
    /// sets scrollbar orientation
    @property AbstractSlider orientation(Orientation value) { 
        if (_orientation != value) {
            _orientation = value; 
            requestLayout(); 
        }
        return this; 
    }

}

/// scroll bar - either vertical or horizontal
class ScrollBar : AbstractSlider, OnClickHandler {
    protected ImageButton _btnBack;
    protected ImageButton _btnForward;
    protected SliderButton _indicator;
    protected PageScrollButton _pageUp;
    protected PageScrollButton _pageDown;
    protected Rect _scrollArea;
    protected int _btnSize;
    protected int _minIndicatorSize;



    class PageScrollButton : Widget {
        this(string ID) {
            super(ID);
            styleId = STYLE_PAGE_SCROLL;
            trackHover = true;
            clickable = true;
        }
    }

    class SliderButton : ImageButton {
        Point _dragStart;
        int _dragStartPosition;
        bool _dragging;
        Rect _dragStartRect;

        this(string resourceId) {
            super("SLIDER", resourceId);
            styleId = STYLE_SCROLLBAR_BUTTON;
            trackHover = true;
        }

        /// process mouse event; return true if event is processed by widget.
        override bool onMouseEvent(MouseEvent event) {
            // support onClick
            if (event.action == MouseAction.ButtonDown && event.button == MouseButton.Left) {
                setState(State.Pressed);
                _dragging = true;
                _dragStart.x = event.x;
                _dragStart.y = event.y;
                _dragStartPosition = _position;
                _dragStartRect = _pos;
                sendScrollEvent(ScrollAction.SliderPressed, _position);
                return true;
            }
            if (event.action == MouseAction.FocusOut && _dragging) {
                debug(scrollbar) Log.d("ScrollBar slider dragging - FocusOut");
                return true;
            }
            if (event.action == MouseAction.FocusIn && _dragging) {
                debug(scrollbar) Log.d("ScrollBar slider dragging - FocusIn");
                return true;
            }
            if (event.action == MouseAction.Move && _dragging) {
                int delta = _orientation == Orientation.Vertical ? event.y - _dragStart.y : event.x - _dragStart.x;
                debug(scrollbar) Log.d("ScrollBar slider dragging - Move delta=", delta);
                Rect rc = _dragStartRect;
                int offset;
                int space;
                if (_orientation == Orientation.Vertical) {
                    rc.top += delta;
                    rc.bottom += delta;
                    if (rc.top < _scrollArea.top) {
                        rc.top = _scrollArea.top;
                        rc.bottom = _scrollArea.top + _dragStartRect.height;
                    } else if (rc.bottom > _scrollArea.bottom) {
                        rc.top = _scrollArea.bottom - _dragStartRect.height;
                        rc.bottom = _scrollArea.bottom;
                    }
                    offset = rc.top - _scrollArea.top;
                    space = _scrollArea.height - rc.height;
                } else {
                    rc.left += delta;
                    rc.right += delta;
                    if (rc.left < _scrollArea.left) {
                        rc.left = _scrollArea.left;
                        rc.right = _scrollArea.left + _dragStartRect.width;
                    } else if (rc.right > _scrollArea.right) {
                        rc.left = _scrollArea.right - _dragStartRect.width;
                        rc.right = _scrollArea.right;
                    }
                    offset = rc.left - _scrollArea.left;
                    space = _scrollArea.width - rc.width;
                }
                layoutButtons(rc);
                //_pos = rc;
                int position = cast(int)(space > 0 ? _minValue + cast(long)offset * (_maxValue - _minValue - _pageSize) / space : 0);
                invalidate();
                onIndicatorDragging(_dragStartPosition, position);
                return true;
            }
            if (event.action == MouseAction.ButtonUp && event.button == MouseButton.Left) {
                resetState(State.Pressed);
                if (_dragging) {
                    sendScrollEvent(ScrollAction.SliderReleased, _position);
                    _dragging = false;
                }
                return true;
            }
            if (event.action == MouseAction.Move && trackHover) {
                if (!(state & State.Hovered)) {
                    debug(scrollbar) Log.d("Hover ", id);
                    setState(State.Hovered);
                }
                return true;
            }
            if (event.action == MouseAction.Leave && trackHover) {
                debug(scrollbar) Log.d("Leave ", id);
                resetState(State.Hovered);
                return true;
            }
            if (event.action == MouseAction.Cancel && trackHover) {
                debug(scrollbar) Log.d("Cancel ? trackHover", id);
                resetState(State.Hovered);
                resetState(State.Pressed);
                _dragging = false;
                return true;
            }
            if (event.action == MouseAction.Cancel) {
                debug(scrollbar) Log.d("SliderButton.onMouseEvent event.action == MouseAction.Cancel");
                resetState(State.Pressed);
                _dragging = false;
                return true;
            }
            return false;
        }

    }

    protected bool onIndicatorDragging(int initialPosition, int currentPosition) {
        _position = currentPosition;
        return sendScrollEvent(ScrollAction.SliderMoved, currentPosition);
    }

    private bool calcButtonSizes(int availableSize, ref int spaceBackSize, ref int spaceForwardSize, ref int indicatorSize) {
        int dv = _maxValue - _minValue;
        if (_pageSize >= dv) {
            // full size
            spaceBackSize = spaceForwardSize = 0;
            indicatorSize = availableSize;
            return false;
        }
        if (dv < 0)
            dv = 0;
        indicatorSize = dv ? _pageSize * availableSize / dv : _minIndicatorSize;
        if (indicatorSize < _minIndicatorSize)
            indicatorSize = _minIndicatorSize;
        if (indicatorSize >= availableSize) {
            // full size
            spaceBackSize = spaceForwardSize = 0;
            indicatorSize = availableSize;
            return false;
        }
        int spaceLeft = availableSize - indicatorSize;
        int topv = _position - _minValue;
        int bottomv = _position + _pageSize - _minValue;
        if (topv < 0)
            topv = 0;
        if (bottomv > dv)
            bottomv = dv;
        bottomv = dv - bottomv;
        spaceBackSize = cast(int)(cast(long)spaceLeft * topv / (topv + bottomv));
        spaceForwardSize = spaceLeft - spaceBackSize;
        return true;
    }

    /// returns scrollbar orientation (Vertical, Horizontal)
    override @property Orientation orientation() { return _orientation; }
    /// sets scrollbar orientation
    override @property AbstractSlider orientation(Orientation value) { 
        if (_orientation != value) {
            _orientation = value;
            _btnBack.drawableId = style.customDrawableId(_orientation == Orientation.Vertical ? ATTR_SCROLLBAR_BUTTON_UP : ATTR_SCROLLBAR_BUTTON_LEFT);
            _btnForward.drawableId = style.customDrawableId(_orientation == Orientation.Vertical ? ATTR_SCROLLBAR_BUTTON_DOWN : ATTR_SCROLLBAR_BUTTON_RIGHT);
            _indicator.drawableId = style.customDrawableId(_orientation == Orientation.Vertical ? ATTR_SCROLLBAR_INDICATOR_VERTICAL : ATTR_SCROLLBAR_INDICATOR_HORIZONTAL);
            requestLayout();
        }
        return this; 
    }

    /// set string property value, for ML loaders
    override bool setStringProperty(string name, string value) {
        if (name.equal("orientation")) {
            if (value.equal("Vertical") || value.equal("vertical"))
                orientation = Orientation.Vertical;
            else
                orientation = Orientation.Horizontal;
            return true;
        }
        return super.setStringProperty(name, value);
    }


    /// empty parameter list constructor - for usage by factory
    this() {
        this(null, Orientation.Vertical);
    }
    /// create with ID parameter
    this(string ID, Orientation orient = Orientation.Vertical) {
        super(ID);
        styleId = STYLE_SCROLLBAR;
        _orientation = orient;
        _btnBack = new ImageButton("BACK", style.customDrawableId(_orientation == Orientation.Vertical ? ATTR_SCROLLBAR_BUTTON_UP : ATTR_SCROLLBAR_BUTTON_LEFT));
        _btnForward = new ImageButton("FORWARD", style.customDrawableId(_orientation == Orientation.Vertical ? ATTR_SCROLLBAR_BUTTON_DOWN : ATTR_SCROLLBAR_BUTTON_RIGHT));
        _pageUp = new PageScrollButton("PAGE_UP");
        _pageDown = new PageScrollButton("PAGE_DOWN");
        _btnBack.styleId = STYLE_SCROLLBAR_BUTTON_TRANSPARENT;
        _btnForward.styleId = STYLE_SCROLLBAR_BUTTON_TRANSPARENT;
        _indicator = new SliderButton(style.customDrawableId(_orientation == Orientation.Vertical ? ATTR_SCROLLBAR_INDICATOR_VERTICAL : ATTR_SCROLLBAR_INDICATOR_HORIZONTAL));
        addChild(_btnBack);
        addChild(_btnForward);
        addChild(_indicator);
        addChild(_pageUp);
        addChild(_pageDown);
        _btnBack.focusable = false;
        _btnForward.focusable = false;
        _indicator.focusable = false;
        _pageUp.focusable = false;
        _pageDown.focusable = false;
        _btnBack.click = &onClick;
        _btnForward.click = &onClick;
        _pageUp.click = &onClick;
        _pageDown.click = &onClick;
    }

    override void measure(int parentWidth, int parentHeight) { 
        Point sz;
        _btnBack.measure(parentWidth, parentHeight);
        _btnForward.measure(parentWidth, parentHeight);
        _indicator.measure(parentWidth, parentHeight);
        _pageUp.measure(parentWidth, parentHeight);
        _pageDown.measure(parentWidth, parentHeight);
        _btnSize = _btnBack.measuredWidth;
        _minIndicatorSize = _orientation == Orientation.Vertical ? _indicator.measuredHeight : _indicator.measuredWidth;
        if (_btnSize < _minIndicatorSize)
            _btnSize = _minIndicatorSize;
        if (_btnSize < _btnForward.measuredWidth)
            _btnSize = _btnForward.measuredWidth;
        if (_btnSize < _btnForward.measuredHeight)
            _btnSize = _btnForward.measuredHeight;
        if (_btnSize < _btnBack.measuredHeight)
            _btnSize = _btnBack.measuredHeight;
        static if (BACKEND_GUI) {
            if (_btnSize < 16)
                _btnSize = 16;
        }
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

    override protected void onPositionChanged() {
        if (!needLayout)
            layoutButtons();
    }

    /// hide controls when scroll is not possible
    protected void updateState() {
        bool canScroll = _maxValue - _minValue > _pageSize;
        if (canScroll) {
            _btnBack.setState(State.Enabled);
            _btnForward.setState(State.Enabled);
            _indicator.visibility = Visibility.Visible;
            _pageUp.visibility = Visibility.Visible;
            _pageDown.visibility = Visibility.Visible;
        } else {
            _btnBack.resetState(State.Enabled);
            _btnForward.resetState(State.Enabled);
            _indicator.visibility = Visibility.Gone;
            _pageUp.visibility = Visibility.Gone;
            _pageDown.visibility = Visibility.Gone;
        }
        cancelLayout();
    }

    override void cancelLayout() {
        _btnBack.cancelLayout();
        _btnForward.cancelLayout();
        _indicator.cancelLayout();
        _pageUp.cancelLayout();
        _pageDown.cancelLayout();
        super.cancelLayout();
    }

    protected void layoutButtons() {
        Rect irc = _scrollArea;
        if (_orientation == Orientation.Vertical) {
            // vertical
            int spaceBackSize, spaceForwardSize, indicatorSize;
            bool indicatorVisible = calcButtonSizes(_scrollArea.height, spaceBackSize, spaceForwardSize, indicatorSize);
            irc.top += spaceBackSize;
            irc.bottom -= spaceForwardSize;
            layoutButtons(irc);
        } else {
            // horizontal
            int spaceBackSize, spaceForwardSize, indicatorSize;
            bool indicatorVisible = calcButtonSizes(_scrollArea.width, spaceBackSize, spaceForwardSize, indicatorSize);
            irc.left += spaceBackSize;
            irc.right -= spaceForwardSize;
            layoutButtons(irc);
        }
        updateState();
        cancelLayout();
    }

    protected void layoutButtons(Rect irc) {
        Rect r;
        _indicator.visibility = Visibility.Visible;
        if (_orientation == Orientation.Vertical) {
            _indicator.layout(irc);
            if (_scrollArea.top < irc.top) {
                r = _scrollArea;
                r.bottom = irc.top;
                _pageUp.layout(r);
                _pageUp.visibility = Visibility.Visible;
            } else {
                _pageUp.visibility = Visibility.Invisible;
            }
            if (_scrollArea.bottom > irc.bottom) {
                r = _scrollArea;
                r.top = irc.bottom;
                _pageDown.layout(r);
                _pageDown.visibility = Visibility.Visible;
            } else {
                _pageDown.visibility = Visibility.Invisible;
            }
        } else {
            _indicator.layout(irc);
            if (_scrollArea.left < irc.left) {
                r = _scrollArea;
                r.right = irc.left;
                _pageUp.layout(r);
                _pageUp.visibility = Visibility.Visible;
            } else {
                _pageUp.visibility = Visibility.Invisible;
            }
            if (_scrollArea.right > irc.right) {
                r = _scrollArea;
                r.left = irc.right;
                _pageDown.layout(r);
                _pageDown.visibility = Visibility.Visible;
            } else {
                _pageDown.visibility = Visibility.Invisible;
            }
        }
    }

    override void layout(Rect rc) {
        _needLayout = false;
        applyMargins(rc);
        applyPadding(rc);
        Rect r;
        if (_orientation == Orientation.Vertical) {
            // vertical
            // buttons
            int backbtnpos = rc.top + _btnSize;
            int fwdbtnpos = rc.bottom - _btnSize;
            r = rc;
            r.bottom = backbtnpos;
            _btnBack.layout(r);
            r = rc;
            r.top = fwdbtnpos;
            _btnForward.layout(r);
            // indicator
            r = rc;
            r.top = backbtnpos;
            r.bottom = fwdbtnpos;
            _scrollArea = r;
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
            // indicator
            r = rc;
            r.left = backbtnpos;
            r.right = fwdbtnpos;
            _scrollArea = r;
        }
        layoutButtons();
        _pos = rc;
    }

    override bool onClick(Widget source) {
        Log.d("Scrollbar.onClick ", source.id);
        if (source.compareId("BACK"))
            return sendScrollEvent(ScrollAction.LineUp, position);
        if (source.compareId("FORWARD"))
            return sendScrollEvent(ScrollAction.LineDown, position);
        if (source.compareId("PAGE_UP"))
            return sendScrollEvent(ScrollAction.PageUp, position);
        if (source.compareId("PAGE_DOWN"))
            return sendScrollEvent(ScrollAction.PageDown, position);
        return true;
    }

    /// handle mouse wheel events
    override bool onMouseEvent(MouseEvent event) {
        if (visibility != Visibility.Visible)
            return false;
        if (event.action == MouseAction.Wheel) {
            int delta = event.wheelDelta;
            if (delta > 0)
                sendScrollEvent(ScrollAction.LineUp, position);
            else if (delta < 0)
                sendScrollEvent(ScrollAction.LineDown, position);
            return true;
        }
        return true;
        //return super.onMouseEvent(event);
    }

    /// Draw widget at its position to buffer
    override void onDraw(DrawBuf buf) {
        if (visibility != Visibility.Visible && !buf.isClippedOut(_pos))
            return;
        super.onDraw(buf);
        Rect rc = _pos;
        applyMargins(rc);
        applyPadding(rc);
        auto saver = ClipRectSaver(buf, rc, alpha);
        _btnForward.onDraw(buf);
        _btnBack.onDraw(buf);
        _pageUp.onDraw(buf);
        _pageDown.onDraw(buf);
        _indicator.onDraw(buf);
    }
}

/// scroll bar - either vertical or horizontal
class SliderWidget : AbstractSlider, OnClickHandler {
    protected SliderButton _indicator;
    protected PageScrollButton _pageUp;
    protected PageScrollButton _pageDown;
    protected Rect _scrollArea;
    protected int _btnSize;
    protected int _minIndicatorSize;

    class PageScrollButton : Widget {
        this(string ID) {
            super(ID);
            styleId = STYLE_PAGE_SCROLL;
            trackHover = true;
            clickable = true;
        }
    }

    class SliderButton : ImageButton {
        Point _dragStart;
        int _dragStartPosition;
        bool _dragging;
        Rect _dragStartRect;

        this(string resourceId) {
            super("SLIDER", resourceId);
            styleId = STYLE_SCROLLBAR_BUTTON;
            trackHover = true;
        }

        /// process mouse event; return true if event is processed by widget.
        override bool onMouseEvent(MouseEvent event) {
            // support onClick
            if (event.action == MouseAction.ButtonDown && event.button == MouseButton.Left) {
                setState(State.Pressed);
                _dragging = true;
                _dragStart.x = event.x;
                _dragStart.y = event.y;
                _dragStartPosition = _position;
                _dragStartRect = _pos;
                sendScrollEvent(ScrollAction.SliderPressed, _position);
                return true;
            }
            if (event.action == MouseAction.FocusOut && _dragging) {
                debug(scrollbar) Log.d("ScrollBar slider dragging - FocusOut");
                return true;
            }
            if (event.action == MouseAction.FocusIn && _dragging) {
                debug(scrollbar) Log.d("ScrollBar slider dragging - FocusIn");
                return true;
            }
            if (event.action == MouseAction.Move && _dragging) {
                int delta = _orientation == Orientation.Vertical ? event.y - _dragStart.y : event.x - _dragStart.x;
                debug(scrollbar) Log.d("ScrollBar slider dragging - Move delta=", delta);
                Rect rc = _dragStartRect;
                int offset;
                int space;
                if (_orientation == Orientation.Vertical) {
                    rc.top += delta;
                    rc.bottom += delta;
                    if (rc.top < _scrollArea.top) {
                        rc.top = _scrollArea.top;
                        rc.bottom = _scrollArea.top + _dragStartRect.height;
                    } else if (rc.bottom > _scrollArea.bottom) {
                        rc.top = _scrollArea.bottom - _dragStartRect.height;
                        rc.bottom = _scrollArea.bottom;
                    }
                    offset = rc.top - _scrollArea.top;
                    space = _scrollArea.height - rc.height;
                } else {
                    rc.left += delta;
                    rc.right += delta;
                    if (rc.left < _scrollArea.left) {
                        rc.left = _scrollArea.left;
                        rc.right = _scrollArea.left + _dragStartRect.width;
                    } else if (rc.right > _scrollArea.right) {
                        rc.left = _scrollArea.right - _dragStartRect.width;
                        rc.right = _scrollArea.right;
                    }
                    offset = rc.left - _scrollArea.left;
                    space = _scrollArea.width - rc.width;
                }
                layoutButtons(rc);
                //_pos = rc;
                int position = cast(int)(space > 0 ? _minValue + cast(long)offset * (_maxValue - _minValue - _pageSize) / space : 0);
                invalidate();
                onIndicatorDragging(_dragStartPosition, position);
                return true;
            }
            if (event.action == MouseAction.ButtonUp && event.button == MouseButton.Left) {
                resetState(State.Pressed);
                if (_dragging) {
                    sendScrollEvent(ScrollAction.SliderReleased, _position);
                    _dragging = false;
                }
                return true;
            }
            if (event.action == MouseAction.Move && trackHover) {
                if (!(state & State.Hovered)) {
                    debug(scrollbar) Log.d("Hover ", id);
                    setState(State.Hovered);
                }
                return true;
            }
            if (event.action == MouseAction.Leave && trackHover) {
                debug(scrollbar) Log.d("Leave ", id);
                resetState(State.Hovered);
                return true;
            }
            if (event.action == MouseAction.Cancel && trackHover) {
                debug(scrollbar) Log.d("Cancel ? trackHover", id);
                resetState(State.Hovered);
                resetState(State.Pressed);
                _dragging = false;
                return true;
            }
            if (event.action == MouseAction.Cancel) {
                debug(scrollbar) Log.d("SliderButton.onMouseEvent event.action == MouseAction.Cancel");
                resetState(State.Pressed);
                _dragging = false;
                return true;
            }
            return false;
        }

    }

    protected bool onIndicatorDragging(int initialPosition, int currentPosition) {
        _position = currentPosition;
        return sendScrollEvent(ScrollAction.SliderMoved, currentPosition);
    }

    private bool calcButtonSizes(int availableSize, ref int spaceBackSize, ref int spaceForwardSize, ref int indicatorSize) {
        int dv = _maxValue - _minValue;
        if (_pageSize >= dv) {
            // full size
            spaceBackSize = spaceForwardSize = 0;
            indicatorSize = availableSize;
            return false;
        }
        if (dv < 0)
            dv = 0;
        indicatorSize = dv ? _pageSize * availableSize / dv : _minIndicatorSize;
        if (indicatorSize < _minIndicatorSize)
            indicatorSize = _minIndicatorSize;
        if (indicatorSize >= availableSize) {
            // full size
            spaceBackSize = spaceForwardSize = 0;
            indicatorSize = availableSize;
            return false;
        }
        int spaceLeft = availableSize - indicatorSize;
        int topv = _position - _minValue;
        int bottomv = _position + _pageSize - _minValue;
        if (topv < 0)
            topv = 0;
        if (bottomv > dv)
            bottomv = dv;
        bottomv = dv - bottomv;
        spaceBackSize = cast(int)(cast(long)spaceLeft * topv / (topv + bottomv));
        spaceForwardSize = spaceLeft - spaceBackSize;
        return true;
    }

    /// returns scrollbar orientation (Vertical, Horizontal)
    override @property Orientation orientation() { return _orientation; }
    /// sets scrollbar orientation
    override @property AbstractSlider orientation(Orientation value) { 
        if (_orientation != value) {
            _orientation = value; 
            _indicator.drawableId = style.customDrawableId(_orientation == Orientation.Vertical ? ATTR_SCROLLBAR_INDICATOR_VERTICAL : ATTR_SCROLLBAR_INDICATOR_HORIZONTAL);
            requestLayout(); 
        }
        return this; 
    }

    /// set string property value, for ML loaders
    override bool setStringProperty(string name, string value) {
        if (name.equal("orientation")) {
            if (value.equal("Vertical") || value.equal("vertical"))
                orientation = Orientation.Vertical;
            else
                orientation = Orientation.Horizontal;
            return true;
        }
        return super.setStringProperty(name, value);
    }


    /// empty parameter list constructor - for usage by factory
    this() {
        this(null, Orientation.Horizontal);
    }
    /// create with ID parameter
    this(string ID, Orientation orient = Orientation.Horizontal) {
        super(ID);
        styleId = STYLE_SLIDER;
        _orientation = orient;
        _pageSize = 1;
        _pageUp = new PageScrollButton("PAGE_UP");
        _pageDown = new PageScrollButton("PAGE_DOWN");
        _indicator = new SliderButton(style.customDrawableId(_orientation == Orientation.Vertical ? ATTR_SCROLLBAR_INDICATOR_VERTICAL : ATTR_SCROLLBAR_INDICATOR_HORIZONTAL));
        addChild(_indicator);
        addChild(_pageUp);
        addChild(_pageDown);
        _indicator.focusable = false;
        _pageUp.focusable = false;
        _pageDown.focusable = false;
        _pageUp.click = &onClick;
        _pageDown.click = &onClick;
    }

    override void measure(int parentWidth, int parentHeight) { 
        Point sz;
        _indicator.measure(parentWidth, parentHeight);
        _pageUp.measure(parentWidth, parentHeight);
        _pageDown.measure(parentWidth, parentHeight);
        _minIndicatorSize = _orientation == Orientation.Vertical ? _indicator.measuredHeight : _indicator.measuredWidth;
        _btnSize = _minIndicatorSize;
        if (_btnSize < _minIndicatorSize)
            _btnSize = _minIndicatorSize;
        static if (BACKEND_GUI) {
            if (_btnSize < 16)
                _btnSize = 16;
        }
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

    override protected void onPositionChanged() {
        if (!needLayout)
            layoutButtons();
    }

    /// hide controls when scroll is not possible
    protected void updateState() {
        bool canScroll = _maxValue - _minValue > _pageSize;
        if (canScroll) {
            _indicator.visibility = Visibility.Visible;
            _pageUp.visibility = Visibility.Visible;
            _pageDown.visibility = Visibility.Visible;
        } else {
            _indicator.visibility = Visibility.Gone;
            _pageUp.visibility = Visibility.Gone;
            _pageDown.visibility = Visibility.Gone;
        }
        cancelLayout();
    }

    override void cancelLayout() {
        _indicator.cancelLayout();
        _pageUp.cancelLayout();
        _pageDown.cancelLayout();
        super.cancelLayout();
    }

    protected void layoutButtons() {
        Rect irc = _scrollArea;
        if (_orientation == Orientation.Vertical) {
            // vertical
            int spaceBackSize, spaceForwardSize, indicatorSize;
            bool indicatorVisible = calcButtonSizes(_scrollArea.height, spaceBackSize, spaceForwardSize, indicatorSize);
            irc.top += spaceBackSize;
            irc.bottom -= spaceForwardSize;
            layoutButtons(irc);
        } else {
            // horizontal
            int spaceBackSize, spaceForwardSize, indicatorSize;
            bool indicatorVisible = calcButtonSizes(_scrollArea.width, spaceBackSize, spaceForwardSize, indicatorSize);
            irc.left += spaceBackSize;
            irc.right -= spaceForwardSize;
            layoutButtons(irc);
        }
        updateState();
        cancelLayout();
    }

    protected void layoutButtons(Rect irc) {
        Rect r;
        _indicator.visibility = Visibility.Visible;
        if (_orientation == Orientation.Vertical) {
            _indicator.layout(irc);
            if (_scrollArea.top < irc.top) {
                r = _scrollArea;
                r.bottom = irc.top;
                _pageUp.layout(r);
                _pageUp.visibility = Visibility.Visible;
            } else {
                _pageUp.visibility = Visibility.Invisible;
            }
            if (_scrollArea.bottom > irc.bottom) {
                r = _scrollArea;
                r.top = irc.bottom;
                _pageDown.layout(r);
                _pageDown.visibility = Visibility.Visible;
            } else {
                _pageDown.visibility = Visibility.Invisible;
            }
        } else {
            _indicator.layout(irc);
            if (_scrollArea.left < irc.left) {
                r = _scrollArea;
                r.right = irc.left;
                _pageUp.layout(r);
                _pageUp.visibility = Visibility.Visible;
            } else {
                _pageUp.visibility = Visibility.Invisible;
            }
            if (_scrollArea.right > irc.right) {
                r = _scrollArea;
                r.left = irc.right;
                _pageDown.layout(r);
                _pageDown.visibility = Visibility.Visible;
            } else {
                _pageDown.visibility = Visibility.Invisible;
            }
        }
    }

    override void layout(Rect rc) {
        _needLayout = false;
        applyMargins(rc);
        applyPadding(rc);
        Rect r;
        if (_orientation == Orientation.Vertical) {
            // vertical
            // buttons
            // indicator
            r = rc;
            _scrollArea = r;
        } else {
            // horizontal
            // indicator
            r = rc;
            _scrollArea = r;
        }
        layoutButtons();
        _pos = rc;
    }

    override bool onClick(Widget source) {
        Log.d("Scrollbar.onClick ", source.id);
        if (source.compareId("PAGE_UP"))
            return sendScrollEvent(ScrollAction.PageUp, position);
        if (source.compareId("PAGE_DOWN"))
            return sendScrollEvent(ScrollAction.PageDown, position);
        return true;
    }

    /// handle mouse wheel events
    override bool onMouseEvent(MouseEvent event) {
        if (visibility != Visibility.Visible)
            return false;
        if (event.action == MouseAction.Wheel) {
            int delta = event.wheelDelta;
            if (delta > 0)
                sendScrollEvent(ScrollAction.LineUp, position);
            else if (delta < 0)
                sendScrollEvent(ScrollAction.LineDown, position);
            return true;
        }
        return super.onMouseEvent(event);
    }

    /// Draw widget at its position to buffer
    override void onDraw(DrawBuf buf) {
        if (visibility != Visibility.Visible && !buf.isClippedOut(_pos))
            return;
        Rect rc = _pos;
        applyMargins(rc);
        auto saver = ClipRectSaver(buf, rc, alpha);
        DrawableRef bg = backgroundDrawable;
        if (!bg.isNull) {
            Rect r = rc;
            if (_orientation == Orientation.Vertical) {
                int dw = bg.width;
                r.left += (rc.width - dw)/2;
                r.right = r.left + dw;
            } else {
                int dw = bg.height;
                r.top += (rc.height - dw)/2;
                r.bottom = r.top + dw;
            }
            bg.drawTo(buf, r, state);
        }
        applyPadding(rc);
        if (state & State.Focused) {
            rc.expand(FOCUS_RECT_PADDING, FOCUS_RECT_PADDING);
            drawFocusRect(buf, rc);
        }
        _needDraw = false;
        _pageUp.onDraw(buf);
        _pageDown.onDraw(buf);
        _indicator.onDraw(buf);
    }
}

