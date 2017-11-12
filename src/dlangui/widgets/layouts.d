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
        int contentHeight = 0;
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
            } else {
                nonresizableWeight += weight;
                nonresizableSize += size * weight;
            }
        }
        if (_orientation == Orientation.Vertical) {
            if (_layoutWidth == WRAP_CONTENT && maxItem < rc.width)
                contentSecondarySize = maxItem;
            else
                contentSecondarySize = rc.width;
            if ((_layoutHeight == FILL_PARENT || isPercentSize(_layoutHeight)) && totalSize < rc.height && resizableSize > 0) {
                delta = rc.height - totalSize; // total space to add to fit
            } else if (totalSize > rc.height) {
                delta = rc.height - totalSize; // total space to reduce to fit
            }
        } else {
            if (_layoutHeight == WRAP_CONTENT && maxItem < rc.height)
                contentSecondarySize = maxItem;
            else
                contentSecondarySize = rc.height;
            if ((_layoutWidth == FILL_PARENT || isPercentSize(_layoutWidth)) && totalSize < rc.width && resizableSize > 0)
                delta = rc.width - totalSize; // total space to add to fit
            else if (totalSize > rc.width)
                delta = rc.width - totalSize; // total space to reduce to fit
        }
        // calculate resize options and scale
        bool needForceResize = false;
        bool needResize = false;
        int scaleFactor = 10000; // per weight unit
        if (delta != 0 && visibleCount > 0) {
            if (delta < 0)
                nonresizableSize += resizersSize; // allow to shrink resizers
            // need resize of some children
            needResize = true;
            // resize all if need to shrink or only resizable are too small to correct delta
            needForceResize = /*delta < 0 || */ resizableWeight == 0; // || resizableSize * 2 / 3 < delta; // do we need resize non-FILL_PARENT items?
            // calculate scale factor: weight / delta * 10000
            if (needForceResize && nonresizableSize + resizableSize > 0)
                scaleFactor = 10000 * delta / (nonresizableSize + resizableSize);
            else if (resizableSize > 0)
                scaleFactor = 10000 * delta / resizableSize;
            else
                scaleFactor = 0;
        }
        //Log.d("VerticalLayout delta=", delta, ", nonres=", nonresizableWeight, ", res=", resizableWeight, ", scale=", scaleFactor);
        // find last resized - to allow fill space 1 pixel accurate
        int lastResized = -1;
        ResizerWidget resizer = null;
        int resizerIndex = -1;
        int resizerDelta = 0;
        for (int i = 0; i < _count; i++) {
            LayoutItem * item = &_list[i];
            if ((item.fillParent || isPercentSize(item.layoutSize) || needForceResize) && (delta < 0 || item.canExtend)) {
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
                int correction = (delta < 0 || item.canExtend) ? scaleFactor * weight * size / 10000 : 0;
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

    /// Orientation: Vertical to resize vertically, Horizontal - to resize horizontally
    @property Orientation orientation() { return _orientation; }
    /// empty parameter list constructor - for usage by factory
    this() {
        this(null);
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

    @property int delta() { return _delta; }

    /// process mouse event; return true if event is processed by widget.
    override bool onMouseEvent(MouseEvent event) {
        // support onClick
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
            } else if (resizeEvent.assigned) {
                resizeEvent(this, ResizerEventType.StartDragging, _orientation == Orientation.Vertical ? event.y : event.x);
            }
            return true;
        }
        if (event.action == MouseAction.FocusOut && _dragging) {
            return true;
        }
        if ((event.action == MouseAction.ButtonUp && event.button == MouseButton.Left) || (!event.lbutton.isDown && _dragging)) {
            resetState(State.Pressed);
            if (_dragging) {
                //sendScrollEvent(ScrollAction.SliderReleased, _position);
                _dragging = false;
                if (resizeEvent.assigned) {
                    resizeEvent(this, ResizerEventType.EndDragging, _orientation == Orientation.Vertical ? event.y : event.x);
                }
            }
            return true;
        }
        if (event.action == MouseAction.Move && _dragging) {
            int delta = _orientation == Orientation.Vertical ? event.y - _dragStart.y : event.x - _dragStart.x;
            if (resizeEvent.assigned) {
                resizeEvent(this, ResizerEventType.Dragging, _orientation == Orientation.Vertical ? event.y : event.x);
                return true;
            }
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
                if (resizeEvent.assigned) {
                    resizeEvent(this, ResizerEventType.EndDragging, _orientation == Orientation.Vertical ? event.y : event.x);
                }
            }
            return true;
        }
        return false;
    }
}


/// Arranges items either vertically or horizontally
class LinearLayout : WidgetGroupDefaultDrawing {
    protected Orientation _orientation = Orientation.Vertical;
    /// returns linear layout orientation (Vertical, Horizontal)
    @property Orientation orientation() const { return _orientation; }
    /// sets linear layout orientation
    @property LinearLayout orientation(Orientation value) { _orientation = value; requestLayout(); return this; }

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

    this(string ID = null) {
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
                    int index = y * colCount + x;
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
