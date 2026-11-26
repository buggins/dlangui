// Written in the D programming language.

/**

This module implements dockable windows UI support.

DockHost is main layout for docking support - contains body widget and optional docked windows.

DockWindow is window to use with DockHost - can be docked on top, left, right or bottom side of DockHost.

Synopsis:

----
import dlangui.widgets.docks;
----


Copyright: Vadim Lopatin, 2015
License:   Boost License 1.0
Authors:   Vadim Lopatin, coolreader.org@gmail.com
*/
module dlangui.widgets.docks;

import dlangui.widgets.layouts;
import dlangui.widgets.controls;
import dlangui.widgets.winframe;

/// dock alignment types
enum DockAlignment {
    /// at left of body
    Left,
    /// at right of body
    Right,
    /// above body
    Top,
    /// below body
    Bottom
}


struct DockSpace {
    protected Rect _rc;
    protected Rect _resizerRect;
    protected Rect _dockRect;
    protected DockWindow[] _docks;
    @property DockWindow[] docks() { return _docks; }
    protected DockHost _host;
    protected DockAlignment _alignment;
    @property DockAlignment alignment() { return _alignment; }
    protected ResizerWidget _resizer;
    @property ResizerWidget resizer() { return _resizer; }
    protected int _space;
    /// current size in pixels, including the resizer; 0 if there are no visible docked windows
    @property int space() { return _space; }
    protected int _baseSize;
    /// host client width (left/right) or height (top/bottom) at the last layout
    @property int baseSize() { return _baseSize; }
    /// current size in percent of baseSize, rounded (so that initialPercent = percent gives the same size); 0 if empty.
    /// Until the user resizes the area it's the initial percentage (clamped to 10..40%): the size was set from it at
    /// the first layout, whose host size may differ from the later ones, e.g. of a window being shown (#968)
    @property int percent() {
        if (_space <= 0 || _baseSize <= 0)
            return 0;
        if (!_resizedByUser)
            return _initialPercent < 10 ? 10 : (_initialPercent > 40 ? 40 : _initialPercent);
        return (_space * 100 + _baseSize / 2) / _baseSize;
    }
    protected int _minSpace;
    protected int _maxSpace;
    protected int _initialPercent = 20;
    /// false until the user resizes the area with its resizer
    protected bool _resizedByUser;
    /// initial size in percent of the host width (left/right) or height (top/bottom), clamped to 10..40%;
    /// setting it resets the current size, so the new initial size is used on the next layout
    @property void initialPercent(int percent) {
        _initialPercent = percent;
        _space = 0;
        _resizedByUser = false;
    }
    ResizerWidget initialize(DockHost host, DockAlignment a) {
        _host = host;
        _alignment = a;
        final switch (a) with(DockAlignment)
        {
            case Top:
                _resizer =  new ResizerWidget("top_resizer", Orientation.Vertical);
                break;
            case Bottom:
                _resizer =  new ResizerWidget("bottom_resizer", Orientation.Vertical);
                break;
            case Left:
                _resizer =  new ResizerWidget("left_resizer", Orientation.Horizontal);
                break;
            case Right:
                _resizer =  new ResizerWidget("right_resizer", Orientation.Horizontal);
                break;
        }
        _resizer.visibility = Visibility.Gone;
        _resizer.resizeEvent = &onResize;
        return _resizer;
    }
    /// host to be layed out
    void beforeLayout(Rect rc, DockWindow[] docks) {
        _docks = docks;
        int baseSize;
        if (_resizer.orientation == Orientation.Vertical)
            baseSize = rc.height;
        else
            baseSize = rc.width;
        _baseSize = baseSize;
        _minSpace = baseSize * 1 / 10;
        _maxSpace = baseSize * 4 / 10;
        if (_docks.length) {
            // the host may be laid out before it has a size: don't initialize the space from that,
            // or the real initial size is never applied (the space would only be clamped to the minimum)
            if (baseSize > 0) {
                if (_space <= 0)
                    _space = baseSize * _initialPercent / 100;
                if (_space < _minSpace)
                    _space = _minSpace;
                if (_space > _maxSpace)
                    _space = _maxSpace;
            }
            _resizer.visibility = Visibility.Visible;
        } else {
            _space = 0;
            _resizer.visibility = Visibility.Gone;
        }
    }
    /**
        Size the area is expected to get at the next layout, for DockHost.measure() (#1234), the same as beforeLayout()
        computes: dockCount - number of visible docked windows, baseSize - host client width (left/right) or height
        (top/bottom), SIZE_UNSPECIFIED if not known.

        Returns 0 without docked windows, -1 if the size can't be told (base size unknown, area not laid out yet).
    */
    int expectedSpace(size_t dockCount, int baseSize) const {
        if (!dockCount)
            return 0;
        if (baseSize == SIZE_UNSPECIFIED || baseSize <= 0)
            return _space > 0 ? _space : -1;
        int space = _space > 0 ? _space : baseSize * _initialPercent / 100;
        if (space < baseSize * 1 / 10)
            space = baseSize * 1 / 10;
        if (space > baseSize * 4 / 10)
            space = baseSize * 4 / 10;
        return space;
    }
    void layout(Rect rc) {
        int rsWidth = 3; // resizer width
        if (_space) {
            _rc = rc;
            final switch (_alignment) with(DockAlignment)
            {
                case Top:
                    _resizerRect = Rect(rc.left, rc.bottom - rsWidth, rc.right, rc.bottom + rsWidth);
                    _dockRect = Rect(rc.left, rc.top, rc.right, rc.bottom - rsWidth);
                    break;
                case Bottom:
                    _resizerRect = Rect(rc.left, rc.top - rsWidth, rc.right, rc.top + rsWidth);
                    _dockRect = Rect(rc.left, rc.top + rsWidth, rc.right, rc.bottom);
                    break;
                case Left:
                    _resizerRect = Rect(rc.right - rsWidth, rc.top, rc.right + rsWidth, rc.bottom);
                    _dockRect = Rect(rc.left, rc.top, rc.right - rsWidth, rc.bottom);
                    break;
                case Right:
                    _resizerRect = Rect(rc.left - rsWidth, rc.top, rc.left + rsWidth, rc.bottom);
                    _dockRect = Rect(rc.left + rsWidth, rc.top, rc.right, rc.bottom);
                    break;
            }
            // layout resizer
            _resizer.layout(_resizerRect);
            // layout docked
            layoutDocked();
        } else {
            _rc = _resizerRect = _dockRect = Rect(0, 0, 0, 0); // empty rect
        }
    }
    protected int _dragStartSpace;
    protected int _dragStartPosition;
    protected void onResize(ResizerWidget source, ResizerEventType event, int newPosition) {
        if (!_space)
            return;
        if (event == ResizerEventType.StartDragging) {
            _dragStartSpace = _space;
            _dragStartPosition = newPosition;
        } else if (event == ResizerEventType.Dragging) {
            int dir = _alignment == DockAlignment.Right || _alignment == DockAlignment.Bottom ? -1 : 1;
            _space = _dragStartSpace + dir * (newPosition - _dragStartPosition);
            // keep the limits while dragging, also outside the window (#972): a space <= 0 would mean
            // "not initialized" in beforeLayout() and bring back the initial size
            if (_space < _minSpace)
                _space = _minSpace;
            if (_space > _maxSpace)
                _space = _maxSpace;
            _resizedByUser = true;
            if (_host) // null in the unittest
                _host.onResize(source, event, newPosition);
        }
    }
    protected void layoutDocked() {
        Rect rc = _rc; //_dockRect;
        int len = cast(int)_docks.length;
        for (int i = 0; i < len; i++) {
            Rect itemRc = rc;
            if (len > 1) {
                if (_resizer.orientation == Orientation.Horizontal) {
                    itemRc.top = rc.top + rc.height * i / len;
                    if (i != len - 1)
                        itemRc.bottom = rc.top + rc.height * (i + 1) / len;
                    else
                        itemRc.bottom = rc.bottom;
                } else {
                    itemRc.left = rc.left + rc.width * i / len;
                    if (i != len - 1)
                        itemRc.right = rc.left + rc.width * (i + 1) / len;
                    else
                        itemRc.right = rc.right;
                }
            }
            _docks[i].layout(itemRc);
        }
    }
}

/// Layout for docking support - contains body widget and optional docked windows
class DockHost : WidgetGroupDefaultDrawing {


    protected DockSpace _topSpace;
    protected DockSpace _bottomSpace;
    protected DockSpace _rightSpace;
    protected DockSpace _leftSpace;
    protected Widget _bodyWidget;
    @property Widget bodyWidget() { return _bodyWidget; }
    /// set the body widget (null: none); the previous body is destroyed
    @property void bodyWidget(Widget widget) {
        if (widget is _bodyWidget)
            return; // replacing it with itself would destroy it (#1225)
        // a widget that is a child already (e.g. added as a docked window) must not be in the children twice
        if (widget) {
            int index = _children.indexOf(widget);
            if (index >= 0)
                _children.remove(index);
        }
        _children.replace(widget, _bodyWidget);
        _bodyWidget = widget;
        if (widget) {
            widget.layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT);
            widget.parent = this;
        }
        requestLayout();
    }

    void addDockedWindow(DockWindow dockWin) {
        addChild(dockWin);
    }

    /// remove a docked window (a direct child, not the body) and return it, or null if there is none with this id
    DockWindow removeDockedWindow(string id) {
        int index = _children.indexOf(id);
        if (index < 0)
            return null;
        DockWindow res = cast(DockWindow)_children.get(index);
        if (!res || res is _bodyWidget)
            return null; // not a docked window (#1225)
        removeChild(index);
        return res;
    }

    protected int _resizeStartPos;
    void onResize(ResizerWidget source, ResizerEventType event, int newPosition) {
        layout(_pos);
    }

    this() {
        this("DOCK_HOST");
    }

    this(string ID) {
        super(ID);
        styleId = STYLE_DOCK_HOST;
        addChild(_topSpace.initialize(this, DockAlignment.Top));
        addChild(_bottomSpace.initialize(this, DockAlignment.Bottom));
        addChild(_leftSpace.initialize(this, DockAlignment.Left));
        addChild(_rightSpace.initialize(this, DockAlignment.Right));
    }

    /// set initial size of a dock area in percent of the host width (left/right) or height (top/bottom);
    /// default is 20%, the value is clamped to 10..40%. Call before the host is shown.
    void setInitialSpace(DockAlignment alignment, int percent) {
        dockSpace(alignment).initialPercent = percent;
        requestLayout();
    }

    /// current size of a dock area in pixels, including its resizer; 0 if it has no visible docked windows
    int dockSpaceSize(DockAlignment alignment) {
        return dockSpace(alignment).space;
    }

    /**
        Current size of a dock area in percent of the host client width (left/right) or height (top/bottom), rounded;
        0 if it has no visible docked windows.

        Passing it to setInitialSpace() gives the same size, e.g. to restore dock sizes saved on exit at the next start.
    */
    int dockSpacePercent(DockAlignment alignment) {
        return dockSpace(alignment).percent;
    }

    protected ref DockSpace dockSpace(DockAlignment alignment) {
        final switch (alignment) with(DockAlignment) {
            case Top: return _topSpace;
            case Bottom: return _bottomSpace;
            case Left: return _leftSpace;
            case Right: return _rightSpace;
        }
    }

    protected DockWindow[] getDockedWindowList(DockAlignment alignType) {
        DockWindow[] list;
        for (int i = 0; i < _children.count; i++) {
            DockWindow item = cast(DockWindow)_children.get(i);
            if (!item || item is _bodyWidget)
                continue; // not a docked window; a DockWindow can also be the body (#1225)
            if(item.dockAlignment == alignType && item.visibility == Visibility.Visible) {
                list ~= item;
            }
        }
        return list;
    }

    protected DockAlignment[4] _layoutPriority = [DockAlignment.Top, DockAlignment.Left, DockAlignment.Right, DockAlignment.Bottom];
    @property DockAlignment[4] layoutPriority() { return _layoutPriority; }
    @property void layoutPriority(DockAlignment[4] p) {
        _layoutPriority = p;
        requestLayout();
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
        foreach(a; _layoutPriority) {
            if (a == DockAlignment.Top) _topSpace.beforeLayout(rc, getDockedWindowList(DockAlignment.Top));
            if (a == DockAlignment.Left) _leftSpace.beforeLayout(rc, getDockedWindowList(DockAlignment.Left));
            if (a == DockAlignment.Right) _rightSpace.beforeLayout(rc, getDockedWindowList(DockAlignment.Right));
            if (a == DockAlignment.Bottom) _bottomSpace.beforeLayout(rc, getDockedWindowList(DockAlignment.Bottom));
        }
        int topsp, bottomsp, leftsp, rightsp;
        foreach(a; _layoutPriority) {
            if (a == DockAlignment.Top) {
                _topSpace.layout(Rect(rc.left + leftsp, rc.top, rc.right - rightsp, rc.top + _topSpace.space));
                topsp = _topSpace.space;
            }
            if (a == DockAlignment.Bottom) {
                _bottomSpace.layout(Rect(rc.left + leftsp, rc.bottom - _bottomSpace.space, rc.right - rightsp, rc.bottom));
                bottomsp = _bottomSpace.space;
            }
            if (a == DockAlignment.Left) {
                _leftSpace.layout(Rect(rc.left, rc.top + topsp, rc.left + _leftSpace.space, rc.bottom - bottomsp));
                leftsp = _leftSpace.space;
            }
            if (a == DockAlignment.Right) {
                _rightSpace.layout(Rect(rc.right - _rightSpace.space, rc.top + topsp, rc.right, rc.bottom - bottomsp));
                rightsp = _rightSpace.space;
            }
        }
        if (_bodyWidget)
            _bodyWidget.layout(Rect(rc.left + _leftSpace.space, rc.top + _topSpace.space, rc.right - _rightSpace.space, rc.bottom - _bottomSpace.space));
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
        // dock areas (#1234), in layoutPriority order like layout(): each one takes its space from the part of the
        // client rect the areas before it left, and spans the rest of it across. Its space is the size the next
        // layout gives it, a percentage of the client size; if that isn't known and the area was never laid out,
        // the largest measured size of its docked windows: only an estimate, the layout gives it the percentage of
        // the real size. Docked windows share the cross size of their area equally.
        int[4] spaces; // by DockAlignment
        int[4] crossSizes; // by DockAlignment: the cross size the docked windows of the area need
        int availWidth = pwidth;
        int availHeight = pheight;
        foreach (a; _layoutPriority) {
            immutable bool horizontal = a == DockAlignment.Left || a == DockAlignment.Right; // space is a width
            DockWindow[] docks = getDockedWindowList(a);
            int space = dockSpace(a).expectedSpace(docks.length, horizontal ? pwidth : pheight);
            immutable int dockSize = space > 0 ? space : SIZE_UNSPECIFIED;
            int crossShare = horizontal ? availHeight : availWidth;
            if (crossShare != SIZE_UNSPECIFIED && docks.length)
                crossShare /= cast(int)docks.length;
            int maxSize, maxCross;
            foreach (d; docks) {
                if (horizontal)
                    d.measure(dockSize, crossShare);
                else
                    d.measure(crossShare, dockSize);
                immutable int size = horizontal ? d.measuredWidth : d.measuredHeight;
                immutable int cross = horizontal ? d.measuredHeight : d.measuredWidth;
                if (maxSize < size)
                    maxSize = size;
                if (maxCross < cross)
                    maxCross = cross;
            }
            if (space < 0)
                space = maxSize;
            spaces[a] = space;
            crossSizes[a] = maxCross * cast(int)docks.length;
            if (horizontal && availWidth != SIZE_UNSPECIFIED)
                availWidth = availWidth > space ? availWidth - space : 0;
            if (!horizontal && availHeight != SIZE_UNSPECIFIED)
                availHeight = availHeight > space ? availHeight - space : 0;
        }
        // the body gets the rest of the client rect
        Point sz;
        if (_bodyWidget && _bodyWidget.visibility != Visibility.Gone) {
            _bodyWidget.measure(availWidth, availHeight);
            sz = Point(_bodyWidget.measuredWidth, _bodyWidget.measuredHeight);
        }
        // add the areas around it, the last laid out first: each adds its space and needs its cross size across
        foreach_reverse (a; _layoutPriority) {
            if (a == DockAlignment.Left || a == DockAlignment.Right) {
                sz.x += spaces[a];
                if (sz.y < crossSizes[a])
                    sz.y = crossSizes[a];
            } else {
                sz.y += spaces[a];
                if (sz.x < crossSizes[a])
                    sz.x = crossSizes[a];
            }
        }
        // other children (the resizers; docked windows that aren't visible) are measured, but not counted: the
        // resizers lie inside the dock areas
        for (int i = 0; i < _children.count; i++) {
            Widget item = _children.get(i);
            if (item is _bodyWidget || item.visibility == Visibility.Gone)
                continue;
            if (auto d = cast(DockWindow)item)
                if (d.visibility == Visibility.Visible)
                    continue; // measured above
            item.measure(pwidth, pheight);
        }
        measuredContent(parentWidth, parentHeight, sz.x, sz.y);
    }
}

/// docked window
class DockWindow : WindowFrame {

    protected DockAlignment _dockAlignment;

    @property DockAlignment dockAlignment() { return _dockAlignment; }
    @property DockWindow dockAlignment(DockAlignment a) {
        if (_dockAlignment != a) {
            _dockAlignment = a;
            requestLayout();
        }
        return this;
    }

    /// showCloseButton = false: no close button in the caption, e.g. when the app has no way to show the window again
    this(string ID, bool showCloseButton = true) {
        super(ID, showCloseButton);
        focusGroup = true;
    }

    override protected void initialize() {
        super.initialize();
        _dockAlignment = DockAlignment.Right; // default alignment is right
    }

    //protected Widget createBodyWidget() {
    //    return new Widget("DOCK_WINDOW_BODY");
    //}
}

/// the body widget is not a docked window, also when it is a DockWindow, and it is measured once (#1225)
unittest {
    import dlangui.widgets.styles : useTestTheme;
    auto _ = useTestTheme();
    static class MeasureCounter : Widget {
        int count;
        override void measure(int parentWidth, int parentHeight) {
            count++;
            super.measure(parentWidth, parentHeight);
        }
    }
    {
        auto host = new DockHost();
        scope(exit) destroy(host);
        auto counter = new MeasureCounter();
        host.bodyWidget = counter;
        host.measure(1000, 800);
        assert(counter.count == 1);
    }
    {
        auto host = new DockHost();
        scope(exit) destroy(host);
        auto bodyWin = new DockWindow("body"); // default alignment: Right
        host.bodyWidget = bodyWin;
        auto right = new DockWindow("right");
        right.dockAlignment = DockAlignment.Right;
        host.addDockedWindow(right);
        assert(host.getDockedWindowList(DockAlignment.Right) == [right]);
        // the right docked window gets the full height of the right area, the body the rest of the width
        host.layout(Rect(0, 0, 1000, 800));
        // the host's client rect: theme margins and padding of DOCK_HOST may apply
        immutable Rect m = host.margins, p = host.padding;
        immutable Rect rc = Rect(m.left + p.left, m.top + p.top, 1000 - m.right - p.right, 800 - m.bottom - p.bottom);
        assert(right.pos.top == rc.top && right.pos.bottom == rc.bottom && right.pos.right == rc.right);
        assert(bodyWin.pos.left == rc.left && bodyWin.pos.right == right.pos.left);
        // removeDockedWindow: not the body; a docked window is removed and returned
        assert(host.removeDockedWindow("body") is null && host.bodyWidget is bodyWin);
        assert(host.removeDockedWindow("right") is right && host.getDockedWindowList(DockAlignment.Right).length == 0);
        destroy(right);
        assert(host.removeDockedWindow("right") is null);
    }
    {
        auto host = new DockHost();
        scope(exit) destroy(host);
        int countOf(Widget w) {
            int n;
            for (int i = 0; i < host.childCount; i++)
                if (host.child(i) is w)
                    n++;
            return n;
        }
        // setting the same body again doesn't destroy it
        auto w = new Widget("w");
        host.bodyWidget = w;
        host.bodyWidget = w;
        assert(host.bodyWidget is w && w.id == "w" && countOf(w) == 1);
        // a docked window that becomes the body is a child once
        auto dock = new DockWindow("dock");
        host.addDockedWindow(dock);
        host.bodyWidget = dock; // destroys w
        assert(host.bodyWidget is dock && countOf(dock) == 1);
        // no body
        host.bodyWidget = null; // destroys dock
        assert(host.bodyWidget is null);
        host.layout(Rect(0, 0, 1000, 800));
    }
}

/// measure: the body is measured with the size left after the dock areas, which are added to the host's size (#1234)
unittest {
    import dlangui.widgets.styles : useTestTheme;
    auto _ = useTestTheme();
    static class BodyWidget : Widget {
        int lastParentWidth, lastParentHeight;
        override void measure(int parentWidth, int parentHeight) {
            lastParentWidth = parentWidth;
            lastParentHeight = parentHeight;
            super.measure(parentWidth, parentHeight);
        }
    }
    // docked windows with a fixed measured size: a real caption can't be measured without a font manager
    static class FixedDock : DockWindow {
        int fixedWidth, fixedHeight;
        int lastParentWidth, lastParentHeight;
        this(string ID, DockAlignment a, int w, int h) {
            super(ID);
            dockAlignment = a;
            fixedWidth = w;
            fixedHeight = h;
        }
        override void measure(int parentWidth, int parentHeight) {
            lastParentWidth = parentWidth;
            lastParentHeight = parentHeight;
            _measuredWidth = fixedWidth;
            _measuredHeight = fixedHeight;
        }
    }
    auto host = new DockHost();
    scope(exit) destroy(host);
    // the host's client size: theme margins and padding of DOCK_HOST may apply
    immutable Rect m = host.margins, p = host.padding;
    immutable int extraWidth = m.left + m.right + p.left + p.right;
    immutable int extraHeight = m.top + m.bottom + p.top + p.bottom;
    immutable int clientWidth = 1000 - extraWidth, clientHeight = 800 - extraHeight;
    auto bodyWidget = new BodyWidget();
    host.bodyWidget = bodyWidget;
    bodyWidget.minWidth = 600;
    bodyWidget.minHeight = 300;
    // no docked windows: the body's size
    host.measure(1000, 800);
    assert(bodyWidget.lastParentWidth == clientWidth && bodyWidget.lastParentHeight == clientHeight);
    assert(host.measuredWidth == 600 + extraWidth && host.measuredHeight == 300 + extraHeight);
    // a right dock: 20% of the client width by default, also before the first layout
    auto right = new FixedDock("right", DockAlignment.Right, 50, 100);
    host.addDockedWindow(right);
    immutable int rightSpace = clientWidth * 20 / 100;
    host.measure(1000, 800);
    assert(bodyWidget.lastParentWidth == clientWidth - rightSpace && bodyWidget.lastParentHeight == clientHeight);
    assert(right.lastParentWidth == rightSpace && right.lastParentHeight == clientHeight);
    assert(host.measuredWidth == 600 + rightSpace + extraWidth);
    // the same after a layout
    host.layout(Rect(0, 0, 1000, 800));
    assert(host.dockSpaceSize(DockAlignment.Right) == rightSpace);
    host.measure(1000, 800);
    assert(bodyWidget.lastParentWidth == clientWidth - rightSpace);
    assert(host.measuredWidth == 600 + rightSpace + extraWidth);
    // unknown size: the size from the last layout
    host.measure(SIZE_UNSPECIFIED, SIZE_UNSPECIFIED);
    assert(bodyWidget.lastParentWidth == SIZE_UNSPECIFIED && bodyWidget.lastParentHeight == SIZE_UNSPECIFIED);
    assert(host.measuredWidth == 600 + rightSpace + extraWidth);
    // a top dock wider than the body and the right area together: laid out first (default layoutPriority), the top
    // area spans the full client width, the right area the height below it
    auto top = new FixedDock("top", DockAlignment.Top, 900, 50);
    host.addDockedWindow(top);
    immutable int topSpace = clientHeight * 20 / 100;
    host.measure(1000, 800);
    assert(top.lastParentWidth == clientWidth && top.lastParentHeight == topSpace);
    assert(right.lastParentWidth == rightSpace && right.lastParentHeight == clientHeight - topSpace);
    assert(bodyWidget.lastParentWidth == clientWidth - rightSpace);
    assert(bodyWidget.lastParentHeight == clientHeight - topSpace);
    assert(host.measuredWidth == 900 + extraWidth);
    assert(host.measuredHeight == 300 + topSpace + extraHeight);
    // two docked windows in the right area share its height
    auto right2 = new FixedDock("right2", DockAlignment.Right, 60, 250);
    host.addDockedWindow(right2);
    host.measure(1000, 800);
    assert(right.lastParentHeight == (clientHeight - topSpace) / 2 && right2.lastParentHeight == right.lastParentHeight);
    assert(host.measuredHeight == 2 * 250 + topSpace + extraHeight);
    host.removeDockedWindow("right2");
    destroy(right2);
    // the right area laid out first: it spans the full height, the top area the width left of it
    host.layoutPriority = [DockAlignment.Right, DockAlignment.Top, DockAlignment.Left, DockAlignment.Bottom];
    host.measure(1500, 800);
    assert(right.lastParentWidth == rightSpace && right.lastParentHeight == clientHeight);
    assert(top.lastParentWidth == 1500 - extraWidth - rightSpace && top.lastParentHeight == topSpace);
    assert(host.measuredWidth == 900 + rightSpace + extraWidth);
    assert(host.measuredHeight == 300 + topSpace + extraHeight);
    // a new host with unknown size, never laid out: the measured size of the docked window
    auto host2 = new DockHost();
    scope(exit) destroy(host2);
    auto left = new FixedDock("left", DockAlignment.Left, 150, 200);
    auto left2 = new FixedDock("left2", DockAlignment.Left, 120, 250);
    host2.addDockedWindow(left);
    host2.addDockedWindow(left2);
    host2.measure(SIZE_UNSPECIFIED, SIZE_UNSPECIFIED);
    assert(left.lastParentWidth == SIZE_UNSPECIFIED);
    // the widest docked window; two windows share the height of the area
    assert(host2.measuredWidth == 150 + extraWidth);
    assert(host2.measuredHeight == 2 * 250 + extraHeight);
}

/// the close button of the caption can be hidden (#1226)
unittest {
    import dlangui.widgets.styles : useTestTheme;
    import dlangui.widgets.controls : ImageButton;
    auto _ = useTestTheme();
    auto withButton = new DockWindow("with");
    scope(exit) destroy(withButton);
    auto withoutButton = new DockWindow("without", false);
    scope(exit) destroy(withoutButton);
    assert(withButton.childById!ImageButton("DOCK_WINDOW_CAPTION_CLOSE_BUTTON").visibility == Visibility.Visible);
    assert(withoutButton.childById!ImageButton("DOCK_WINDOW_CAPTION_CLOSE_BUTTON").visibility == Visibility.Gone);
    // also later, e.g. in a subclass that calls super(ID)
    withButton.showCloseButton = false;
    assert(!withButton.showCloseButton);
    assert(withButton.childById!ImageButton("DOCK_WINDOW_CAPTION_CLOSE_BUTTON").visibility == Visibility.Gone);
    withoutButton.showCloseButton = true;
    assert(withoutButton.childById!ImageButton("DOCK_WINDOW_CAPTION_CLOSE_BUTTON").visibility == Visibility.Visible);
}

/// initial dock space: not taken from a layout without size, default 20%, settable, clamped to 10..40% (#762)
unittest {
    import dlangui.widgets.styles : useTestTheme;
    auto _ = useTestTheme();
    DockSpace space;
    auto resizer = space.initialize(null, DockAlignment.Left); // left: based on host width
    scope(exit) destroy(resizer);
    DockWindow[] oneDock = [null];
    // first layout before the host has a size: space stays uninitialized
    space.beforeLayout(Rect(0, 0, -4, -4), oneDock);
    assert(space.space == 0);
    // real size: default initial size 20%
    space.beforeLayout(Rect(0, 0, 1000, 800), oneDock);
    assert(space.space == 200);
    // size is kept on later layouts; the percentage stays the initial one until the user resizes the area (#968)
    space.beforeLayout(Rect(0, 0, 1200, 800), oneDock);
    assert(space.space == 200 && space.percent == 20);
    // custom initial size
    space.initialPercent = 25;
    space.beforeLayout(Rect(0, 0, 1000, 800), oneDock);
    assert(space.space == 250);
    // clamped to 40%
    space.initialPercent = 60;
    space.beforeLayout(Rect(0, 0, 1000, 800), oneDock);
    assert(space.space == 400 && space.percent == 40);
    // resized by the user: the percentage of the current size
    space.initialPercent = 25;
    space.beforeLayout(Rect(0, 0, 1000, 800), oneDock);
    space.onResize(resizer, ResizerEventType.StartDragging, 500);
    space.onResize(resizer, ResizerEventType.Dragging, 560);
    assert(space.space == 310 && space.percent == 31);
    // dragged beyond the limits, also outside the window: clamped to 10..40% (#972)
    space.onResize(resizer, ResizerEventType.Dragging, -200);
    assert(space.space == 100);
    space.onResize(resizer, ResizerEventType.Dragging, 1500);
    assert(space.space == 400);
    space.onResize(resizer, ResizerEventType.Dragging, 560);
    assert(space.space == 310 && space.percent == 31);
    space.beforeLayout(Rect(0, 0, 1240, 800), oneDock);
    assert(space.space == 310 && space.percent == 25);
    // no docked windows: no space
    space.beforeLayout(Rect(0, 0, 1000, 800), null);
    assert(space.space == 0);
}
