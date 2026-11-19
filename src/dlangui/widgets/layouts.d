// Written in the D programming language.

/**
This module contains common layouts implementations.

Layouts are similar to the same in Android.

LinearLayout - either VerticalLayout or HorizontalLayout.
VerticalLayout - just LinearLayout with orientation=Orientation.Vertical
HorizontalLayout - just LinearLayout with orientation=Orientation.Horizontal
FrameLayout - children occupy the same place, usually one one is visible at a time
TableLayout - children aligned into rows and columns
ResizerWidget - widget to resize sibling widgets

Synopsis:

----
import dlangui.widgets.layouts;

----

Copyright: Vadim Lopatin, 2014
License:   Boost License 1.0
Authors:   Vadim Lopatin, coolreader.org@gmail.com
*/
module dlangui.widgets.layouts;

public import dlangui.widgets.widget;
import std.conv;

/// helper for layouts
struct LayoutItem {
    Widget _widget;
    Orientation _orientation;
    int _measuredSize; // primary size for orientation
    int _secondarySize; // other measured size
    int _layoutSize; //  layout size for primary dimension
    int _minSize; //  min size for primary dimension
    int _maxSize; //  max size for primary dimension
    int _weight; // weight
    bool _fillParent;
    bool _isResizer;
    int  _resizerDelta;
    @property bool canExtend() { return !_isResizer; }
    @property int measuredSize() { return _measuredSize; }
    @property int minSize() { return _measuredSize; }
    @property int maxSize() { return _maxSize; }
    @property int layoutSize() { return _layoutSize; }
    @property int secondarySize() { return _layoutSize; }
    @property bool fillParent() { return _fillParent; }
    @property int weight() { return _weight; }
    // just to help GC
    void clear() {
        _widget = null;
    }
    /// sets item for widget
    void set(Widget widget, Orientation orientation) {
        _widget = widget;
        _orientation = orientation;
        if (cast(ResizerWidget)widget) {
            _isResizer = true;
            _resizerDelta = (cast(ResizerWidget)widget).delta;
        }
    }
    /// set item and measure it
    void measure(int parentWidth, int parentHeight) {
        _widget.measure(parentWidth, parentHeight);
        _weight = _widget.layoutWeight;
        if (_orientation == Orientation.Horizontal) {
            _secondarySize = _widget.measuredHeight;
            _measuredSize = _widget.measuredWidth;
            _minSize = _widget.minWidth;
            _maxSize = _widget.maxWidth;
            _layoutSize = _widget.layoutWidth;
        } else {
            _secondarySize = _widget.measuredWidth;
            _measuredSize = _widget.measuredHeight;
            _minSize = _widget.minHeight;
            _maxSize = _widget.maxHeight;
            _layoutSize = _widget.layoutHeight;
        }
        _fillParent = _layoutSize == FILL_PARENT;
    }
    void layout(ref Rect rc) {
        _widget.layout(rc);
    }
}

/// helper class for layouts
class LayoutItems {
    Orientation _orientation;
    LayoutItem[] _list;
    int _count;
    int _totalSize;
    int _maxSecondarySize;
    Point _measureParentSize;

    int _layoutWidth;
    int _layoutHeight;

    void setLayoutParams(Orientation orientation, int layoutWidth, int layoutHeight) {
        _orientation = orientation;
        _layoutWidth = layoutWidth;
        _layoutHeight = layoutHeight;
    }

    /// fill widget layout list with Visible or Invisible items, measure them
    Point measure(int parentWidth, int parentHeight) {
        _totalSize = 0;
        _maxSecondarySize = 0;
        _measureParentSize.x = parentWidth;
        _measureParentSize.y = parentHeight;
        bool hasPercentSizeWidget = false;
        size_t percenSizeWidgetIndex;
        // measure
        for (int i = 0; i < _count; i++) {
            LayoutItem * item = &_list[i];

            item.measure(parentWidth, parentHeight);

            if (isPercentSize(item._layoutSize)) {
                if (!hasPercentSizeWidget) {
                    percenSizeWidgetIndex = i;
                    hasPercentSizeWidget = true;
                }
            }
            else
                _totalSize += item._measuredSize;

            if (_maxSecondarySize < item._secondarySize)
                _maxSecondarySize = item._secondarySize;
        }
        if (hasPercentSizeWidget) {
            LayoutItem * item = &_list[percenSizeWidgetIndex];
            if (_totalSize > 0)
                item._measuredSize = to!int(_totalSize * ((1 / (1 - cast (double) (fromPercentSize(item._layoutSize, 100))/100)) - 1));
            _totalSize += item._measuredSize;
        }
        return _orientation == Orientation.Horizontal ? Point(_totalSize, _maxSecondarySize) : Point(_maxSecondarySize, _totalSize);
    }

    /// fill widget layout list with Visible or Invisible items, measure them
    void setWidgets(ref WidgetList widgets) {
        // remove old items, if any
        clear();
        // reserve space
        if (_list.length < widgets.count)
            _list.length = widgets.count;
        // copy
        for (int i = 0; i < widgets.count; i++) {
            Widget item = widgets.get(i);
            if (item.visibility == Visibility.Gone)
                continue;
            _list[_count++].set(item, _orientation);
        }
    }

    void layout(Rect rc) {
        // measure again - available area could be changed
        if (_measureParentSize.x != rc.width || _measureParentSize.y != rc.height)
            measure(rc.width, rc.height);
        int contentSecondarySize = 0;
        int totalSize = 0;
        int delta = 0;
        int resizableSize = 0;
        int resizableWeight = 0;
        int nonresizableSize = 0;
        int nonresizableWeight = 0;
        int maxItem = 0; // max item dimention
        // calc total size
        int visibleCount = cast(int)_list.length;
        int resizersSize = 0;
        bool hasPercentSize = false;
        for (int i = 0; i < _count; i++) {
            LayoutItem * item = &_list[i];
            int weight = item.weight;
            int size = item.measuredSize;
            totalSize += size;
            if (maxItem < item.secondarySize)
                maxItem = item.secondarySize;
            if (item._isResizer) {
                resizersSize += size;
            } else if (item.fillParent || isPercentSize(item.layoutSize)) {
                resizableWeight += weight;
                resizableSize += size * weight;
                if (isPercentSize(item.layoutSize))
                    hasPercentSize = true;
            } else {
                nonresizableWeight += weight;
                nonresizableSize += size * weight;
            }
        }
        // FILL_PARENT items share extra space in proportion to measured size * weight; when all of them
        // are measured as 0 (e.g. empty panels), by weight only, or they would get nothing (#973).
        // Not for percent sizes: they keep their old behavior.
        immutable bool growByWeight = resizableSize == 0 && resizableWeight > 0 && !hasPercentSize;
        if (_orientation == Orientation.Vertical) {
            if (_layoutWidth == WRAP_CONTENT && maxItem < rc.width)
                contentSecondarySize = maxItem;
            else
                contentSecondarySize = rc.width;
            if ((_layoutHeight == FILL_PARENT || isPercentSize(_layoutHeight)) && totalSize < rc.height && (resizableSize > 0 || growByWeight)) {
                delta = rc.height - totalSize; // total space to add to fit
            } else if (totalSize > rc.height) {
                delta = rc.height - totalSize; // total space to reduce to fit
            }
        } else {
            if (_layoutHeight == WRAP_CONTENT && maxItem < rc.height)
                contentSecondarySize = maxItem;
            else
                contentSecondarySize = rc.height;
            if ((_layoutWidth == FILL_PARENT || isPercentSize(_layoutWidth)) && totalSize < rc.width && (resizableSize > 0 || growByWeight))
                delta = rc.width - totalSize; // total space to add to fit
            else if (totalSize > rc.width)
                delta = rc.width - totalSize; // total space to reduce to fit
        }
        // calculate resize options and scale
        bool needForceResize = false;
        bool needResize = false;
        immutable bool byWeight = growByWeight && delta > 0;
        int scaleFactor = 10000; // per weight unit
        if (delta != 0 && visibleCount > 0) {
            if (delta < 0)
                nonresizableSize += resizersSize; // allow to shrink resizers
            // need resize of some children
            needResize = true;
            // resize all if need to shrink or only resizable are too small to correct delta
            // (also when shrinking and the resizable ones are all measured as 0: they can't shrink, #973)
            needForceResize = resizableWeight == 0 || (delta < 0 && resizableSize == 0);
            // calculate scale factor: weight / delta * 10000
            if (needForceResize && nonresizableSize + resizableSize > 0)
                scaleFactor = 10000 * delta / (nonresizableSize + resizableSize);
            else if (byWeight)
                scaleFactor = 10000 * delta / resizableWeight; // per weight unit, not per pixel
            else if (resizableSize > 0)
                scaleFactor = 10000 * delta / resizableSize;
            else
                scaleFactor = 0;
        }
        //Log.d("VerticalLayout delta=", delta, ", nonres=", nonresizableWeight, ", res=", resizableWeight, ", scale=", scaleFactor);
        // find last resized - to allow fill space 1 pixel accurate
        int lastResized = -1;
        int resizerIndex = -1;
        int resizerDelta = 0;
        for (int i = 0; i < _count; i++) {
            LayoutItem * item = &_list[i];
            // when shrinking, not an item measured as 0: the remainder would make its size negative
            if ((item.fillParent || isPercentSize(item.layoutSize) || needForceResize) && (delta < 0 || item.canExtend)
                    && (delta > 0 || item.measuredSize > 0)) {
                lastResized = i;
            }
            if (item._isResizer) {
                resizerIndex = i;
                resizerDelta = item._resizerDelta;
            }
        }
        // final resize and layout of children
        int position = 0;
        int deltaTotal = 0;
        for (int i = 0; i < _count; i++) {
            LayoutItem * item = &_list[i];
            int layoutSize = item.layoutSize;
            int weight = item.weight;
            int size = item.measuredSize;
            if (needResize && (layoutSize == FILL_PARENT || isPercentSize(layoutSize) || needForceResize)) {
                // do resize
                int share = byWeight ? weight : weight * size;
                int correction = (delta < 0 || item.canExtend) ? scaleFactor * share / 10000 : 0;
                deltaTotal += correction;
                // for last resized, apply additional correction to resolve calculation inaccuracy
                if (i == lastResized) {
                    correction += delta - deltaTotal;
                }
                size += correction;
            }
            // apply size
            Rect childRect = rc;
            if (_orientation == Orientation.Vertical) {
                // Vertical
                childRect.top += position;
                childRect.bottom = childRect.top + size;
                childRect.right = childRect.left + contentSecondarySize;
                item.layout(childRect);
            } else {
                // Horizontal
                childRect.left += position;
                childRect.right = childRect.left + size;
                childRect.bottom = childRect.top + contentSecondarySize;
                item.layout(childRect);
            }
            position += size;
        }
    }

    void clear() {
        for (int i = 0; i < _count; i++)
            _list[i].clear();
        _count = 0;
    }
    ~this() {
        clear();
    }
}

enum ResizerEventType : int {
    StartDragging,
    Dragging,
    EndDragging
}

interface ResizeHandler {
    void onResize(ResizerWidget source, ResizerEventType event, int currentPosition);
}

/**
 * Resizer control.
 * Put it between other items in LinearLayout to allow resizing its siblings.
 * While dragging, it will resize previous and next children in layout.
 */
class ResizerWidget : Widget {
    protected Orientation _orientation;
    protected Widget _previousWidget;
    protected Widget _nextWidget;
    protected string _styleVertical;
    protected string _styleHorizontal;
    Signal!ResizeHandler resizeEvent;

    /// Minimum size of the previous item when dragging: width, or height for a vertical resizer
    size_t minPreviousItemWidth = 100;

    /// Minimum size of the next item when dragging: width, or height for a vertical resizer
    size_t minNextItemWidth = 100;

    /// Orientation: Vertical to resize vertically, Horizontal - to resize horizontally
    @property Orientation orientation() { return _orientation; }
    /// empty parameter list constructor - for usage by factory
    this() {
        this(null);
        minWidth = 7;
    }
    /// create with ID parameter
    this(string ID, Orientation orient = Orientation.Vertical) {
        super(ID);
        _styleVertical = "RESIZER_VERTICAL";
        _styleHorizontal = "RESIZER_HORIZONTAL";
        _orientation = orient;
        trackHover = true;
    }

    @property bool validProps() {
        return _previousWidget && _nextWidget;
    }

    /// returns mouse cursor type for widget
    override uint getCursorType(int x, int y) {
        if (_orientation == Orientation.Vertical) {
            return CursorType.SizeNS;
        } else {
            return CursorType.SizeWE;
        }
    }

    protected void updateProps() {
        _previousWidget = null;
        _nextWidget = null;
        LinearLayout parentLayout = cast(LinearLayout)_parent;
        if (parentLayout) {
            _orientation = parentLayout.orientation;
            int index = parentLayout.childIndex(this);
            _previousWidget = parentLayout.child(index - 1);
            _nextWidget = parentLayout.child(index + 1);
        }
        if (validProps) {
            if (_orientation == Orientation.Vertical) {
                styleId = _styleVertical;
            } else {
                styleId = _styleHorizontal;
            }
        } else {
            _previousWidget = null;
            _nextWidget = null;
        }
    }

    /**
       Measure widget according to desired width and height constraints. (Step 1 of two phase layout).

    */
    override void measure(int parentWidth, int parentHeight) {
        updateProps();
        if (_orientation == Orientation.Vertical) {

        }
        measuredContent(parentWidth, parentHeight, 7, 7);
    }

    /// Set widget rectangle to specified value and layout widget contents. (Step 2 of two phase layout).
    override void layout(Rect rc) {
        updateProps();
        if (visibility == Visibility.Gone) {
            return;
        }
        _pos = rc;
        _needLayout = false;
    }

    protected int _delta;
    protected int _minDragDelta;
    protected int _maxDragDelta;
    protected bool _dragging;
    protected int _dragStartPosition; // drag start delta
    protected Point _dragStart;
    protected Rect _dragStartRect;
    protected Rect _scrollArea;
    protected int _dragStartPreviousSize; // size of the previous widget at drag start
    protected int _dragStartNextSize; // size of the next widget at drag start

    @property int delta() { return _delta; }

    /// process mouse event; return true if event is processed by widget.
    override bool onMouseEvent(MouseEvent event) {
        // support onClick
        immutable newWidth = _orientation == Orientation.Vertical ? event.y : event.x;
        if (event.action == MouseAction.ButtonDown && event.button == MouseButton.Left) {
            setState(State.Pressed);
            _dragging = true;
            _dragStart.x = event.x;
            _dragStart.y = event.y;
            _dragStartPosition = _delta;
            _dragStartRect = _pos;
            _scrollArea = _pos;
            _minDragDelta = 0;
            _maxDragDelta = 0;
            if (validProps) {
                Rect r1 = _previousWidget.pos;
                Rect r2 = _nextWidget.pos;
                _dragStartPreviousSize = _orientation == Orientation.Vertical ? r1.height : r1.width;
                _dragStartNextSize = _orientation == Orientation.Vertical ? r2.height : r2.width;
                _scrollArea.left = r1.left;
                _scrollArea.right = r2.right;
                _scrollArea.top = r1.top;
                _scrollArea.bottom = r2.bottom;
                if (_orientation == Orientation.Vertical) {
                    _minDragDelta = _scrollArea.top - _dragStartRect.top;
                    _maxDragDelta = _scrollArea.bottom - _dragStartRect.bottom;
                }
                if (_delta < _minDragDelta)
                    _delta = _minDragDelta;
                if (_delta > _maxDragDelta)
                    _delta = _maxDragDelta;
            }
            resizeAndFireEvent(newWidth, ResizerEventType.StartDragging);
            return true;
        }
        if (event.action == MouseAction.FocusOut && _dragging) {
            return true;
        }
        if (event.action == MouseAction.Cancel && _dragging) {
            // before the hover handling below, which would keep the drag going (#972)
            resetState(State.Pressed | State.Hovered);
            _dragging = false;
            resizeAndFireEvent(newWidth, ResizerEventType.EndDragging);
            return true;
        }
        if ((event.action == MouseAction.ButtonUp && event.button == MouseButton.Left) || (!event.lbutton.isDown && _dragging)) {
            resetState(State.Pressed);
            if (_dragging) {
                //sendScrollEvent(ScrollAction.SliderReleased, _position);
                _dragging = false;
                resizeAndFireEvent(newWidth, ResizerEventType.EndDragging);
            }
            return true;
        }
        if (event.action == MouseAction.Move && _dragging) {
            int delta = _orientation == Orientation.Vertical ? event.y - _dragStart.y : event.x - _dragStart.x;
            resizeAndFireEvent(newWidth, ResizerEventType.Dragging);
            _delta = _dragStartPosition + delta;
            if (_delta < _minDragDelta)
                _delta = _minDragDelta;
            if (_delta > _maxDragDelta)
                _delta = _maxDragDelta;
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
            //_pos = rc;
            //int position = space > 0 ? _minValue + offset * (_maxValue - _minValue - _pageSize) / space : 0;
            requestLayout();
            invalidate();
            //onIndicatorDragging(_dragStartPosition, position);
            return true;
        }
        if (event.action == MouseAction.Move && trackHover) {
            if (!(state & State.Hovered)) {
                //Log.d("Hover ", id);
                setState(State.Hovered);
            }
            return true;
        }
        if ((event.action == MouseAction.Leave || event.action == MouseAction.Cancel) && trackHover) {
            //Log.d("Leave ", id);
            resetState(State.Hovered);
            return true;
        }
        if (event.action == MouseAction.Cancel) {
            //Log.d("SliderButton.onMouseEvent event.action == MouseAction.Cancel");
            if (_dragging) {
                resetState(State.Pressed);
                _dragging = false;
                resizeAndFireEvent(newWidth, ResizerEventType.EndDragging);
            }
            return true;
        }
        return false;
    }

    /// newPosition: mouse x (horizontal) or y (vertical) in window coordinates
    private void resizeAndFireEvent(int newPosition, ResizerEventType type)
    {
        if (validProps && type == ResizerEventType.Dragging)
            resizeNeighbours(newPosition);
        // listeners without previous/next widgets (e.g. DockHost areas) apply their own limits
        if (resizeEvent.assigned)
            resizeEvent(this, type, newPosition);
    }

    /// set the sizes of the previous and next widgets while dragging to newPosition (#972)
    private void resizeNeighbours(int newPosition) {
        import std.algorithm : max, min;
        immutable bool vertical = _orientation == Orientation.Vertical;
        int layoutSize(Widget w) { return vertical ? w.layoutHeight : w.layoutWidth; }
        bool fills(Widget w) { return layoutSize(w) == FILL_PARENT || isPercentSize(layoutSize(w)); }
        // the previous widget: its size at drag start plus the mouse movement since then
        immutable int total = _dragStartPreviousSize + _dragStartNextSize;
        int size = _dragStartPreviousSize + newPosition - (vertical ? _dragStart.y : _dragStart.x);
        // sizes of the previous widget at which both widgets stay within their limits
        int minPrevious = max(cast(int)minPreviousItemWidth, vertical ? _previousWidget.minHeight : _previousWidget.minWidth);
        int maxPrevious = vertical ? _previousWidget.maxHeight : _previousWidget.maxWidth;
        int minNext = max(cast(int)minNextItemWidth, vertical ? _nextWidget.minHeight : _nextWidget.minWidth);
        int maxNext = vertical ? _nextWidget.maxHeight : _nextWidget.maxWidth;
        int low = max(minPrevious, total - maxNext);
        int high = min(maxPrevious, total - minNext);
        if (low > high)
            return; // no size fits both widgets
        size = max(low, min(high, size));
        // the widget which fills the rest of the layout takes the difference: set the size of the other one
        Widget target = _previousWidget;
        if (fills(_previousWidget) && !fills(_nextWidget)) {
            target = _nextWidget;
            size = total - size;
        }
        if (vertical)
            target.layoutHeight = size;
        else
            target.layoutWidth = size;
    }
}

// dragging a resizer between two widgets of a linear layout (#972)
unittest {
    import dlangui.widgets.styles : currentTheme, createDefaultTheme;
    // the currentTheme setter destroys the previous theme: replace only a theme created here
    immutable bool ownTheme = currentTheme is null;
    if (ownTheme)
        currentTheme = createDefaultTheme();
    scope(exit) if (ownTheme) currentTheme = null;

    MouseEvent mouse(MouseAction action, int x, int y, bool buttonDown = true) {
        auto e = new MouseEvent(action, action == MouseAction.ButtonDown || action == MouseAction.ButtonUp
                                ? MouseButton.Left : MouseButton.None,
                                buttonDown ? MouseFlag.LButton : 0, cast(short)x, cast(short)y);
        if (buttonDown)
            e.lbutton.down(cast(short)x, cast(short)y, MouseFlag.LButton);
        return e;
    }

    foreach (vertical; [false, true]) {
        // first: sizeFirst px or FILL_PARENT, second: FILL_PARENT or sizeSecond px;
        // the layout doesn't start at 0, 0 in the window
        void test(int sizeFirst, int sizeSecond, int length, void delegate(Widget first, Widget second,
                  ResizerWidget resizer, int delegate(MouseAction, int) send) check) {
            LinearLayout layout = new LinearLayout(null, vertical ? Orientation.Vertical : Orientation.Horizontal);
            scope(exit) destroy(layout);
            layout.layoutWidth = FILL_PARENT;
            layout.layoutHeight = FILL_PARENT;
            Widget first = new Widget("first");
            Widget second = new Widget("second");
            foreach (w, size; [first: sizeFirst, second: sizeSecond]) {
                if (vertical)
                    w.layoutHeight = size;
                else
                    w.layoutWidth = size;
            }
            ResizerWidget resizer = new ResizerWidget();
            layout.addChild(first);
            layout.addChild(resizer);
            layout.addChild(second);
            Rect rc = vertical ? Rect(20, 30, 220, 30 + length) : Rect(20, 30, 20 + length, 230);
            layout.measure(rc.width, rc.height);
            layout.layout(rc);
            assert(resizer.orientation == (vertical ? Orientation.Vertical : Orientation.Horizontal));
            int start = vertical ? resizer.pos.top + 2 : resizer.pos.left + 2; // grab it 2 px inside
            int send(MouseAction action, int pos) {
                resizer.onMouseEvent(mouse(action, vertical ? 100 : start + pos, vertical ? start + pos : 100,
                                           action != MouseAction.ButtonUp && action != MouseAction.Cancel));
                return vertical ? first.layoutHeight : first.layoutWidth;
            }
            check(first, second, resizer, &send);
        }
        int size(Widget w) { return vertical ? w.layoutHeight : w.layoutWidth; }

        // next widget fills the layout: the size of the previous one follows the mouse
        test(150, FILL_PARENT, 500, (Widget first, Widget second, ResizerWidget resizer, int delegate(MouseAction, int) send) {
            ResizerEventType[] events;
            resizer.resizeEvent = delegate(ResizerWidget source, ResizerEventType event, int position) {
                events ~= event;
            };
            send(MouseAction.ButtonDown, 0);
            assert(events == [ResizerEventType.StartDragging]);
            assert(send(MouseAction.Move, 50) == 200);
            assert(send(MouseAction.Move, -30) == 120);
            // limits: 100 px for the previous widget, and 100 px left for the next one
            assert(send(MouseAction.Move, -120) == 100);
            int total = vertical ? first.pos.height + second.pos.height : first.pos.width + second.pos.width;
            assert(send(MouseAction.Move, 1000) == total - 100);
            // releasing the button doesn't change the size
            assert(send(MouseAction.ButtonUp, 10) == total - 100);
            assert(events[$ - 1] == ResizerEventType.EndDragging);
            assert(size(second) == FILL_PARENT);
            // the other dimension is not changed
            assert((vertical ? first.layoutWidth : first.layoutHeight) == WRAP_CONTENT);
            // max size of the previous widget
            if (vertical)
                first.maxHeight = 250;
            else
                first.maxWidth = 250;
            send(MouseAction.ButtonDown, 0);
            assert(send(MouseAction.Move, 1000) == 250);
            // a cancelled drag ends: later moves don't resize
            send(MouseAction.Cancel, 0);
            assert(events[$ - 1] == ResizerEventType.EndDragging);
            assert(send(MouseAction.Move, -50) == 250);
        });

        // previous widget fills the layout: the next one gets the size
        test(FILL_PARENT, 150, 500, (Widget first, Widget second, ResizerWidget resizer, int delegate(MouseAction, int) send) {
            // a click without moving keeps FILL_PARENT
            send(MouseAction.ButtonDown, 0);
            assert(send(MouseAction.ButtonUp, 0) == FILL_PARENT);
            assert(size(second) == 150);
            send(MouseAction.ButtonDown, 0);
            assert(send(MouseAction.Move, -40) == FILL_PARENT);
            assert(size(second) == 190);
            assert(send(MouseAction.Move, 30) == FILL_PARENT);
            assert(size(second) == 120);
            send(MouseAction.ButtonUp, 30);
        });

        // too small for the minimum sizes of both widgets (100 + 100): no resizing
        test(90, FILL_PARENT, 190, (Widget first, Widget second, ResizerWidget resizer, int delegate(MouseAction, int) send) {
            send(MouseAction.ButtonDown, 0);
            assert(send(MouseAction.Move, 1) == 90);
            assert(send(MouseAction.Move, -20) == 90);
            send(MouseAction.ButtonUp, -20);
        });
    }
}


// FILL_PARENT items measured as 0 (e.g. empty panels) share the extra space by weight (#973)
unittest {
    import dlangui.widgets.styles : currentTheme, createDefaultTheme;
    // the currentTheme setter destroys the previous theme: replace only a theme created here
    immutable bool ownTheme = currentTheme is null;
    if (ownTheme)
        currentTheme = createDefaultTheme();
    scope(exit) if (ownTheme) currentTheme = null;

    foreach (vertical; [false, true]) {
        // children: size in px, FILL_PARENT or -weight (FILL_PARENT with that weight); minSize: their min size
        Rect[] layoutChildren(int[] sizes, int minSize = 0) {
            LinearLayout layout = new LinearLayout(null, vertical ? Orientation.Vertical : Orientation.Horizontal);
            scope(exit) destroy(layout);
            layout.layoutWidth = FILL_PARENT;
            layout.layoutHeight = FILL_PARENT;
            foreach (size; sizes) {
                Widget w = new Widget();
                int layoutSize = size < 0 ? FILL_PARENT : size;
                if (size < 0)
                    w.layoutWeight = -size;
                if (vertical)
                    w.layoutHeight = layoutSize;
                else
                    w.layoutWidth = layoutSize;
                w.minWidth = minSize;
                w.minHeight = minSize;
                layout.addChild(w);
            }
            Rect rc = vertical ? Rect(20, 30, 220, 430) : Rect(20, 30, 420, 230);
            layout.measure(rc.width, rc.height);
            layout.layout(rc);
            Rect[] res;
            foreach (i; 0 .. layout.childCount)
                res ~= layout.child(i).pos;
            return res;
        }
        int size(Rect rc) { return vertical ? rc.height : rc.width; }
        int start(Rect rc) { return vertical ? rc.top : rc.left; }

        // an empty FILL_PARENT widget after a fixed one gets the rest
        Rect[] r = layoutChildren([150, FILL_PARENT]);
        assert(size(r[0]) == 150 && size(r[1]) == 250 && start(r[1]) == (vertical ? 180 : 170));
        // empty FILL_PARENT widgets by weight
        r = layoutChildren([-1, -3]);
        assert(size(r[0]) == 100 && size(r[1]) == 300);
        // not empty: in proportion to measured size * weight, as before
        r = layoutChildren([-1, -1], 10);
        assert(size(r[0]) == 200 && size(r[1]) == 200);
        // too small: the fixed items shrink, an empty FILL_PARENT item stays 0 (was negative)
        r = layoutChildren([300, 200, FILL_PARENT]);
        assert(size(r[0]) + size(r[1]) == 400 && size(r[0]) > size(r[1]));
        assert(size(r[2]) == 0 && start(r[2]) == (vertical ? 430 : 420));
        // percent sizes measured as 0 keep the old behavior (no weight sharing)
        r = layoutChildren([makePercentSize(30), makePercentSize(70)]);
        assert(size(r[0]) == 0 && size(r[1]) == 0);
    }
}

/// Arranges items either vertically or horizontally
class LinearLayout : WidgetGroupDefaultDrawing {
    protected Orientation _orientation = Orientation.Vertical;
    /// returns linear layout orientation (Vertical, Horizontal)
    @property Orientation orientation() const { return _orientation; }
    /// sets linear layout orientation
    @property LinearLayout orientation(Orientation value) { _orientation = value; requestLayout(); return this; }

    /// set int property value, for ML loaders: `orientation: Vertical` or `orientation: Horizontal` in DML
    override bool setIntProperty(string name, int value) {
        import std.algorithm : equal;
        if (name.equal("orientation")) {
            if (value != Orientation.Vertical && value != Orientation.Horizontal)
                return false;
            orientation = cast(Orientation)value;
            return true;
        }
        return super.setIntProperty(name, value);
    }

    /// empty parameter list constructor - for usage by factory
    this() {
        this(null);
    }
    /// create with ID parameter and orientation
    this(string ID, Orientation orientation = Orientation.Vertical) {
        super(ID);
        _layoutItems = new LayoutItems();
        _orientation = orientation;
    }

    LayoutItems _layoutItems;
    /// Measure widget according to desired width and height constraints. (Step 1 of two phase layout).
    override void measure(int parentWidth, int parentHeight) {
        Rect m = margins;
        Rect p = padding;
        // calc size constraints for children
        int pwidth = parentWidth;
        int pheight = parentHeight;
        if (parentWidth != SIZE_UNSPECIFIED)
            pwidth -= m.left + m.right + p.left + p.right;
        if (parentHeight != SIZE_UNSPECIFIED)
            pheight -= m.top + m.bottom + p.top + p.bottom;
        // measure children
        _layoutItems.setLayoutParams(orientation, layoutWidth, layoutHeight);
        _layoutItems.setWidgets(_children);
        Point sz = _layoutItems.measure(pwidth, pheight);
        measuredContent(parentWidth, parentHeight, sz.x, sz.y);
    }

    /// Set widget rectangle to specified value and layout widget contents. (Step 2 of two phase layout).
    override void layout(Rect rc) {
        _needLayout = false;
        if (visibility == Visibility.Gone) {
            return;
        }
        _pos = rc;
        applyMargins(rc);
        applyPadding(rc);
        //debug Log.d("LinearLayout.layout id=", _id, " rc=", rc, " fillHoriz=", layoutWidth == FILL_PARENT);
        _layoutItems.layout(rc);
    }

}

/// Arranges children vertically
class VerticalLayout : LinearLayout {
    /// empty parameter list constructor - for usage by factory
    this() {
        this(null);
    }
    /// create with ID parameter
    this(string ID) {
        super(ID);
        orientation = Orientation.Vertical;
    }
}

/// Arranges children horizontally
class HorizontalLayout : LinearLayout {
    /// empty parameter list constructor - for usage by factory
    this() {
        this(null);
    }
    /// create with ID parameter
    this(string ID) {
        super(ID);
        orientation = Orientation.Horizontal;
    }
}

/// place all children into same place (usually, only one child should be visible at a time)
class FrameLayout : WidgetGroupDefaultDrawing {
    /// empty parameter list constructor - for usage by factory
    this() {
        this(null);
    }
    /// create with ID parameter
    this(string ID) {
        super(ID);
    }
    /// Measure widget according to desired width and height constraints. (Step 1 of two phase layout).
    override void measure(int parentWidth, int parentHeight) {
        Rect m = margins;
        Rect p = padding;
        // calc size constraints for children
        int pwidth = parentWidth;
        int pheight = parentHeight;
        if (parentWidth != SIZE_UNSPECIFIED)
            pwidth -= m.left + m.right + p.left + p.right;
        if (parentHeight != SIZE_UNSPECIFIED)
            pheight -= m.top + m.bottom + p.top + p.bottom;
        // measure children
        Point sz;
        for (int i = 0; i < _children.count; i++) {
            Widget item = _children.get(i);
            if (item.visibility != Visibility.Gone) {
                item.measure(pwidth, pheight);
                if (sz.x < item.measuredWidth)
                    sz.x = item.measuredWidth;
                if (sz.y < item.measuredHeight)
                    sz.y = item.measuredHeight;
            }
        }
        measuredContent(parentWidth, parentHeight, sz.x, sz.y);
    }

    /// Set widget rectangle to specified value and layout widget contents. (Step 2 of two phase layout).
    override void layout(Rect rc) {
        _needLayout = false;
        if (visibility == Visibility.Gone) {
            return;
        }
        _pos = rc;
        applyMargins(rc);
        applyPadding(rc);
        for (int i = 0; i < _children.count; i++) {
            Widget item = _children.get(i);
            if (item.visibility == Visibility.Visible) {
                item.layout(rc);
            }
        }
    }

    /// make one of children (with specified ID) visible, for the rest, set visibility to otherChildrenVisibility
    bool showChild(string ID, Visibility otherChildrenVisibility = Visibility.Invisible, bool updateFocus = false) {
        bool found = false;
        Widget foundWidget = null;
        for (int i = 0; i < _children.count; i++) {
            Widget item = _children.get(i);
            if (item.compareId(ID)) {
                item.visibility = Visibility.Visible;
                item.requestLayout();
                foundWidget = item;
                found = true;
            } else {
                item.visibility = otherChildrenVisibility;
            }
        }
        if (foundWidget !is null && updateFocus)
            foundWidget.setFocus();
        return found;
    }
}

/// layout children as table with rows and columns
class TableLayout : WidgetGroupDefaultDrawing {

    this(string ID) {
        super(ID);
    }

    this() {
        this(null);
    }

    protected static struct TableLayoutCell {
        int col;
        int row;
        Widget widget;
        @property bool layoutWidthFill() { return widget ? widget.layoutWidth == FILL_PARENT : false; }
        @property bool layoutHeightFill() { return widget ? widget.layoutHeight == FILL_PARENT : false; }
        @property int measuredWidth() { return widget ? widget.measuredWidth : 0; }
        @property int measuredHeight() { return widget ? widget.measuredHeight : 0; }
        @property int layoutWidth() { return widget ? widget.layoutWidth : 0; }
        @property int layoutHeight() { return widget ? widget.layoutHeight : 0; }
        @property int minWidth() { return widget ? widget.minWidth : 0; }
        @property int maxWidth() { return widget ? widget.maxWidth : 0; }
        @property int minHeight() { return widget ? widget.minHeight : 0; }
        @property int maxHeight() { return widget ? widget.maxHeight : 0; }
        void clear(int col, int row) {
            this.col = col;
            this.row = row;
            widget = null;
        }
        void measure(Widget w, int pwidth, int pheight) {
            widget = w;
            if (widget)
                widget.measure(pwidth, pheight);
        }
    }

    protected static struct TableLayoutGroup {
        int index;
        int measuredSize;
        int layoutSize;
        int minSize;
        int maxSize;
        int size;
        bool fill;
        void initialize(int index) {
            measuredSize = minSize = maxSize = layoutSize = size = 0;
            fill = false;
            this.index = index;
        }
        void rowCellMeasured(ref TableLayoutCell cell) {
            if (cell.layoutHeightFill)
                fill = true;
            if (measuredSize < cell.measuredHeight)
                measuredSize = cell.measuredHeight;
            if (minSize < cell.minHeight)
                minSize = cell.minHeight;
            if (cell.layoutHeight == FILL_PARENT)
                layoutSize = FILL_PARENT;
            size = measuredSize;
        }
        void colCellMeasured(ref TableLayoutCell cell) {
            if (cell.layoutWidthFill)
                fill = true;
            if (measuredSize < cell.measuredWidth)
                measuredSize = cell.measuredWidth;
            if (minSize < cell.minWidth)
                minSize = cell.minWidth;
            if (cell.layoutWidth == FILL_PARENT)
                layoutSize = FILL_PARENT;
            size = measuredSize;
        }
    }

    protected static struct TableLayoutHelper {
        protected TableLayoutGroup[] _cols;
        protected TableLayoutGroup[] _rows;
        protected TableLayoutCell[] _cells;
        protected int colCount;
        protected int rowCount;
        protected bool layoutWidthFill;
        protected bool layoutHeightFill;

        void initialize(int cols, int rows, bool layoutWidthFill, bool layoutHeightFill) {
            colCount = cols;
            rowCount = rows;
            this.layoutWidthFill = layoutWidthFill;
            this.layoutHeightFill = layoutHeightFill;
            _cells.length = cols * rows;
            _rows.length = rows;
            _cols.length = cols;
            for(int i = 0; i < rows; i++)
                _rows[i].initialize(i);
            for(int i = 0; i < cols; i++)
                _cols[i].initialize(i);
            for (int y = 0; y < rows; y++) {
                for (int x = 0; x < cols; x++) {
                    cell(x, y).clear(x, y);
                }
            }
        }

        ref TableLayoutCell cell(int col, int row) {
            return _cells[row * colCount + col];
        }

        ref TableLayoutGroup col(int c) {
            return _cols[c];
        }

        ref TableLayoutGroup row(int r) {
            return _rows[r];
        }

        Point measure(Widget parent, int cc, int rc, int pwidth, int pheight, bool layoutWidthFill, bool layoutHeightFill) {
            //Log.d("grid measure ", parent.id, " pw=", pwidth, " ph=", pheight);
            initialize(cc, rc, layoutWidthFill, layoutHeightFill);
            for (int y = 0; y < rc; y++) {
                for (int x = 0; x < cc; x++) {
                    int index = y * cc + x;
                    Widget child = index < parent.childCount ? parent.child(index) : null;
                    cell(x, y).measure(child, pwidth, pheight);
                    //if (child)
                    //    Log.d("cell ", x, ",", y, " child=", child.id, " measuredWidth=", child.measuredWidth, " minWidth=", child.minWidth);
                }
            }
            // calc total row size
            int totalHeight = 0;
            for (int y = 0; y < rc; y++) {
                for (int x = 0; x < cc; x++) {
                    row(y).rowCellMeasured(cell(x,y));
                }
                totalHeight += row(y).measuredSize;
            }
            // calc total col size
            int totalWidth = 0;
            for (int x = 0; x < cc; x++) {
                for (int y = 0; y < rc; y++) {
                    col(x).colCellMeasured(cell(x,y));
                }
                totalWidth += col(x).measuredSize;
            }
            //Log.d("             ", parent.id, " w=", totalWidth, " h=", totalHeight);
            return Point(totalWidth, totalHeight);
        }

        void layoutRows(int parentSize) {
            if (layoutHeightFill && rowCount) {
                int totalSize = 0;
                int fillCount = 0;
                for (int y = 0; y < rowCount; y++) {
                    totalSize += row(y).size;
                    if (row(y).fill)
                        fillCount++;
                }
                int extraSize = parentSize - totalSize;
                int resizeCount = fillCount > 0 ? fillCount : rowCount;
                int delta = extraSize / resizeCount;
                int delta0 = extraSize % resizeCount;

                if (extraSize > 0) {
                    for (int y = 0; y < rowCount; y++) {
                        if (fillCount == 0 || row(y).fill) {
                            row(y).size += delta + delta0;
                            delta0 = 0;
                        }
                    }
                }
            }
        }
        void layoutCols(int parentSize) {
            if (layoutWidthFill) {
                int totalSize = 0;
                int fillCount = 0;
                for (int x = 0; x < colCount; x++) {
                    totalSize += col(x).size;
                    if (col(x).fill)
                        fillCount++;
                }
                int extraSize = parentSize - totalSize;
                int resizeCount = fillCount > 0 ? fillCount : colCount;
                int delta = extraSize / resizeCount;
                int delta0 = extraSize % resizeCount;

                if (extraSize > 0) {
                    for (int x = 0; x < colCount; x++) {
                        if (fillCount == 0 || col(x).fill) {
                            col(x).size += delta + delta0;
                            delta0 = 0;
                        }
                    }
                } else if (extraSize < 0) {
                    for (int x = 0; x < colCount; x++) {
                        if (fillCount == 0 || col(x).fill) {
                            col(x).size += delta + delta0;
                            delta0 = 0;
                        }
                    }
                }
            }
        }

        void layout(Rect rc) {
            layoutRows(rc.height);
            layoutCols(rc.width);
            int y0 = 0;
            for (int y = 0; y < rowCount; y++) {
                int x0 = 0;
                for (int x = 0; x < colCount; x++) {
                    Rect r;
                    r.left = rc.left + x0;
                    r.top = rc.top + y0;
                    r.right = r.left + col(x).size;
                    r.bottom = r.top + row(y).size;
                    if (cell(x, y).widget)
                        cell(x, y).widget.layout(r);
                    x0 += col(x).size;
                }
                y0 += row(y).size;
            }
        }
    }
    protected TableLayoutHelper _cells;

    protected int _colCount = 1;
    /// number of columns
    @property int colCount() { return _colCount; }
    @property TableLayout colCount(int count) { if (_colCount != count) requestLayout(); _colCount = count; return this; }
    @property int rowCount() {
        return (childCount + (_colCount - 1)) / _colCount * _colCount;
    }

    /// set int property value, for ML loaders
    mixin(generatePropertySettersMethodOverride("setIntProperty", "int",
          "colCount"));

    /// Measure widget according to desired width and height constraints. (Step 1 of two phase layout).
    override void measure(int parentWidth, int parentHeight) {
        Rect m = margins;
        Rect p = padding;
        // calc size constraints for children
        int pwidth = parentWidth;
        int pheight = parentHeight;
        if (parentWidth != SIZE_UNSPECIFIED)
            pwidth -= m.left + m.right + p.left + p.right;
        if (parentHeight != SIZE_UNSPECIFIED)
            pheight -= m.top + m.bottom + p.top + p.bottom;

        int rc = rowCount;
        Point sz = _cells.measure(this, colCount, rc, pwidth, pheight, layoutWidth == FILL_PARENT, layoutHeight == FILL_PARENT);
        measuredContent(parentWidth, parentHeight, sz.x, sz.y);
    }

    /// Set widget rectangle to specified value and layout widget contents. (Step 2 of two phase layout).
    override void layout(Rect rc) {
        _needLayout = false;
        if (visibility == Visibility.Gone) {
            return;
        }
        _pos = rc;
        applyMargins(rc);
        applyPadding(rc);
        _cells.layout(rc);
    }

}

//import dlangui.widgets.metadata;
//mixin(registerWidgets!(VerticalLayout, HorizontalLayout, TableLayout, FrameLayout)());
