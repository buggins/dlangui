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
    @property int space() { return _space; }
    protected int _minSpace;
    protected int _maxSpace;
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
        _minSpace = baseSize * 1 / 10;
        _maxSpace = baseSize * 4 / 10;
        if (_docks.length) {
            if (_space < _minSpace) {
                if (_space == 0)
                    _space = _minSpace + (_maxSpace - _minSpace) * 1 / 3;
                else
                    _space = _minSpace;
            }
            if (_space > _maxSpace) {
                _space = _maxSpace;
            }
            _resizer.visibility = Visibility.Visible;
        } else {
            _space = 0;
            _resizer.visibility = Visibility.Gone;
        }
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
    @property void bodyWidget(Widget widget) {
        _children.replace(widget, _bodyWidget);
        _bodyWidget = widget;
        _bodyWidget.layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT);
        _bodyWidget.parent = this;
    }

    void addDockedWindow(DockWindow dockWin) {
        addChild(dockWin);
    }

    DockWindow removeDockedWindow(string id) {
        DockWindow res = childById!DockWindow(id);
        if (res)
            removeChild(id);
        return res;
    }

    protected int _resizeStartPos;
    void onResize(ResizerWidget source, ResizerEventType event, int newPosition) {
        layout(_pos);
    }

    this() {
        super("DOCK_HOST");
        styleId = STYLE_DOCK_HOST;
        addChild(_topSpace.initialize(this, DockAlignment.Top));
        addChild(_bottomSpace.initialize(this, DockAlignment.Bottom));
        addChild(_leftSpace.initialize(this, DockAlignment.Left));
        addChild(_rightSpace.initialize(this, DockAlignment.Right));
    }

    protected DockWindow[] getDockedWindowList(DockAlignment alignType) {
        DockWindow[] list;
        for (int i = 0; i < _children.count; i++) {
            DockWindow item = cast(DockWindow)_children.get(i);
            if (!item)
                continue; // not a docked window
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
        // measure children
        Point sz;
        Point bodySize;
        if (_bodyWidget) {
            _bodyWidget.measure(pwidth, pheight);
            bodySize.x = _bodyWidget.measuredWidth;
            bodySize.y = _bodyWidget.measuredHeight;
        }
        for (int i = 0; i < _children.count; i++) {
            Widget item = _children.get(i);
            // TODO: fix
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

    this(string ID) {
        super(ID);
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
