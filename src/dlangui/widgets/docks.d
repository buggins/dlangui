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

/// Layout for docking support - contains body widget and optional docked windows
class DockHost : WidgetGroupDefaultDrawing {

    protected int _topSpace;
    protected int _bottomSpace;
    protected int _rightSpace;
    protected int _leftSpace;
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

    this() {
        super("DOCK_HOST");
        styleId = STYLE_DOCK_HOST;
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

    protected void layoutDocked(DockWindow[] list, Rect rc, Orientation orient) {
        int len = cast(int)list.length;
        for (int i = 0; i < len; i++) {
            Rect itemRc = rc;
            if (len > 1) {
                if (orient == Orientation.Vertical) {
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
            list[i].layout(itemRc);
        }
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
        DockWindow[] top = getDockedWindowList(DockAlignment.Top);
        DockWindow[] left = getDockedWindowList(DockAlignment.Left);
        DockWindow[] right = getDockedWindowList(DockAlignment.Right);
        DockWindow[] bottom = getDockedWindowList(DockAlignment.Bottom);
        _topSpace = top.length ? rc.height / 4 : 0;
        _bottomSpace = bottom.length ? rc.height / 4 : 0;
        _rightSpace = right.length ? rc.width / 4 : 0;
        _leftSpace = left.length ? rc.width / 4 : 0;
        if (_bodyWidget)
            _bodyWidget.layout(Rect(rc.left + _leftSpace, rc.top + _topSpace, rc.right - _rightSpace, rc.bottom - _bottomSpace));
        layoutDocked(top, Rect(rc.left + _leftSpace, rc.top, rc.right - _rightSpace, rc.top + _topSpace), Orientation.Horizontal);
        layoutDocked(bottom, Rect(rc.left + _leftSpace, rc.bottom - _bottomSpace, rc.right - _rightSpace, rc.bottom), Orientation.Horizontal);
        layoutDocked(left, Rect(rc.left, rc.top, rc.left + _leftSpace, rc.bottom), Orientation.Vertical);
        layoutDocked(right, Rect(rc.right - _rightSpace, rc.top, rc.right, rc.bottom), Orientation.Vertical);
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

/// dock alignment types
enum DockAlignment {
    Left,
    Right,
    Top,
    Bottom
}

/// docked window
class DockWindow : VerticalLayout {

    protected Widget _bodyWidget;
    @property Widget bodyWidget() { return _bodyWidget; }
    @property void bodyWidget(Widget widget) { 
        _children.replace(widget, _bodyWidget);
        _bodyWidget = widget;
        _bodyWidget.layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT);
        _bodyWidget.parent = this;
        requestLayout();
    }

    protected DockAlignment _dockAlignment;

    @property DockAlignment dockAlignment() { return _dockAlignment; }
    @property DockWindow dockAlignment(DockAlignment a) { 
        if (_dockAlignment != a) {
            _dockAlignment = a;
            requestLayout();
        }
        return this; 
    }

    protected HorizontalLayout _captionLayout;
    protected TextWidget _caption;
    protected ImageButton _closeButton;

    this(string ID) {
        super(ID);
        _dockAlignment = DockAlignment.Right; // default alignment is right
        init();
    }

    protected bool onCloseButtonClick(Widget source) {
        return true;
    }
    protected void init() {

        styleId = STYLE_DOCK_WINDOW;

        _captionLayout = new HorizontalLayout("DOCK_WINDOW_CAPTION_PANEL");
        _captionLayout.layoutWidth(FILL_PARENT).layoutHeight(WRAP_CONTENT);
        _captionLayout.styleId = STYLE_DOCK_WINDOW_CAPTION;

        _caption = new TextWidget("DOCK_WINDOW_CAPTION");
        _caption.styleId = STYLE_DOCK_WINDOW_CAPTION_LABEL;

        _closeButton = new ImageButton("DOCK_WINDOW_CAPTION_CLOSE_BUTTON");
        _closeButton.styleId = STYLE_BUTTON_TRANSPARENT;
        _closeButton.drawableId = "close";
		_closeButton.trackHover = true;
        _closeButton.onClickListener = &onCloseButtonClick;

        _captionLayout.addChild(_caption);
        _captionLayout.addChild(_closeButton);

        _bodyWidget = createBodyWidget();
        _bodyWidget.styleId = STYLE_DOCK_WINDOW_BODY;

        addChild(_captionLayout);
        addChild(_bodyWidget);
    }
    protected Widget createBodyWidget() {
        return new Widget("DOCK_WINDOW_BODY");
    }
}
