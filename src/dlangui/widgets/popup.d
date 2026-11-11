// Written in the D programming language.

/**
This module contains popup widgets implementation.

Popups appear above other widgets inside window.

Useful for popup menus, notification popups, etc.

Synopsis:

----
import dlangui.widgets.popup;

----

Copyright: Vadim Lopatin, 2014
License:   Boost License 1.0
Authors:   Vadim Lopatin, coolreader.org@gmail.com
*/
module dlangui.widgets.popup;

import dlangui.widgets.widget;
import dlangui.widgets.layouts;
import dlangui.core.signals;
import dlangui.platforms.common.platform;

/// popup alignment option flags
enum PopupAlign : uint {
    /// center popup around anchor widget center
    Center = 1,
    /// place popup below anchor widget (above it, when there is more space above)
    Below = 2,
    /// place popup above anchor widget (below it, when there is more space below)
    Above = 32,
    /// place popup to the right of anchor widget (to the left, when there is more space on the left)
    Right = 4,
    /// align to specified point
    Point = 8,
    /// if popup content size is less than anchor's size, increase it to anchor size
    FitAnchorSize = 16,
}

/**
    Position of a popup of `size` placed beside the anchor range `lo .. hi` along one axis, within `areaLo .. areaHi`:
    after the anchor (starting at `hi`) or, if `before` is true, before it (ending at `lo`).
    When the preferred side doesn't have enough space, the other side is used if the popup fits there,
    or if it has more space; the caller then moves the popup into the area.
*/
int placeBeside(int lo, int hi, int size, int areaLo, int areaHi, bool before) {
    int spaceAfter = areaHi - hi;
    int spaceBefore = lo - areaLo;
    bool useBefore = before;
    if (before && spaceBefore < size && spaceAfter > spaceBefore)
        useBefore = false;
    else if (!before && spaceAfter < size && spaceBefore > spaceAfter)
        useBefore = true;
    return useBefore ? lo - size : hi;
}

unittest {
    // fits after the anchor
    assert(placeBeside(100, 200, 50, 0, 400, false) == 200);
    // doesn't fit after: before the anchor (submenu on the left of the parent menu)
    assert(placeBeside(300, 380, 50, 0, 400, false) == 250);
    // fits in neither side: the side with more space
    assert(placeBeside(150, 250, 200, 0, 400, false) == 250);
    assert(placeBeside(250, 300, 200, 0, 400, false) == 50);
    // preferred before (above), not enough space: after (below)
    assert(placeBeside(20, 40, 100, 0, 400, true) == 40);
    assert(placeBeside(200, 220, 100, 0, 400, true) == 100);
    // point anchor
    assert(placeBeside(390, 390, 100, 0, 400, false) == 290);
}

struct PopupAnchor {
    Widget widget;
    int x;
    int y;
    uint  alignment = PopupAlign.Center;
}

/// popup behavior flags - for PopupWidget.flags property
enum PopupFlags : uint {
    /// close popup when mouse button clicked outside of its bounds
    CloseOnClickOutside = 1,
    /// modal popup - keypresses and mouse events can be routed to this popup only
    Modal = 2,
    /// close popup when mouse is moved outside this popup
    CloseOnMouseMoveOutside = 4,
}

/** interface - slot for onPopupCloseListener */
interface OnPopupCloseHandler {
    void onPopupClosed(PopupWidget source);
}

/// popup widget container
class PopupWidget : LinearLayout {
    protected PopupAnchor _anchor;
    protected bool _modal;

    protected uint _flags;
    /** popup close signal */
    Signal!OnPopupCloseHandler popupClosed;
    //protected void delegate(PopupWidget popup) _onPopupCloseListener;
    /// popup close listener (called right before closing)
    //@property void delegate(PopupWidget popup) onPopupCloseListener() { return _onPopupCloseListener; }
    /// set popup close listener (to call right before closing)
    //@property PopupWidget onPopupCloseListener(void delegate(PopupWidget popup) listener) { _onPopupCloseListener = listener; return this; }

    /// returns popup behavior flags (combination of PopupFlags)
    @property uint flags() { return _flags; }
    /// set popup behavior flags (combination of PopupFlags)
    @property PopupWidget flags(uint flags) { _flags = flags; return this; }

    /// access to popup anchor
    @property ref PopupAnchor anchor() { return _anchor; }
    /// returns true if popup is modal
    bool modal() { return _modal; }
    /// set modality flag
    PopupWidget modal(bool modal) { _modal = modal; return this; }

    /// Measure widget according to desired width and height constraints. (Step 1 of two phase layout).
    override void measure(int parentWidth, int parentHeight) {
        super.measure(parentWidth, parentHeight);
    }
    /// close and destroy popup
    void close() {
        window.removePopup(this);
    }

    /// just call on close listener
    void onClose() {
        if (popupClosed.assigned)
            popupClosed(this);
    }

    /// Set widget rectangle to specified value and layout widget contents. (Step 2 of two phase layout).
    override void layout(Rect rc) {
        if (visibility == Visibility.Gone) {
            return;
        }
        int w = measuredWidth;
        int h = measuredHeight;
        if (w > rc.width)
            w = rc.width;
        if (h > rc.height)
            h = rc.height;

        Rect anchorrc;
        if (anchor.widget !is null)
            anchorrc = anchor.widget.pos;
        else
            anchorrc = rc;

        Rect r;
        Point anchorPt;

        if (anchor.alignment & PopupAlign.Point) {
            r.left = anchor.x;
            r.top = anchor.y;
            if (anchor.alignment & PopupAlign.Center) {
                // center around center of anchor widget
                r.left -= w / 2;
                r.top -= h / 2;
            } else {
                // below (default) or above the point; to the right of it, or to the left when it doesn't fit
                r.top = placeBeside(anchor.y, anchor.y, h, rc.top, rc.bottom, (anchor.alignment & PopupAlign.Above) != 0);
                r.left = placeBeside(anchor.x, anchor.x, w, rc.left, rc.right, false);
            }
        } else {
            if (anchor.alignment & PopupAlign.FitAnchorSize)
                if (w < anchorrc.width)
                    w = anchorrc.width;
            if (anchor.alignment & PopupAlign.Center) {
                // center around center of anchor widget
                r.left = anchorrc.middlex - w / 2;
                r.top = anchorrc.middley - h / 2;
            } else if (anchor.alignment & (PopupAlign.Below | PopupAlign.Above)) {
                r.left = anchorrc.left;
                r.top = placeBeside(anchorrc.top, anchorrc.bottom, h, rc.top, rc.bottom, (anchor.alignment & PopupAlign.Below) == 0);
            } else if (anchor.alignment & PopupAlign.Right) {
                // e.g. submenu: on the left of the parent menu when it doesn't fit on the right (#227)
                r.left = placeBeside(anchorrc.left, anchorrc.right, w, rc.left, rc.right, false);
                r.top = anchorrc.top;
            }
        }
        r.right = r.left + w;
        r.bottom = r.top + h;
        r.moveToFit(rc);
        super.layout(r);
    }

    this(Widget content, Window window) {
        super("POPUP");
        _window = window;
        //styleId = "POPUP_MENU";
        addChild(content);
    }

    /// called for mouse activity outside shown popup bounds
    bool onMouseEventOutside(MouseEvent event) {
        if (visibility != Visibility.Visible)
            return false;
        if (_flags & PopupFlags.CloseOnClickOutside) {
            if (event.action == MouseAction.ButtonUp) {
                // clicked outside - close popup
                close();
                return true;
            }
        }
        if (_flags & PopupFlags.CloseOnMouseMoveOutside) {
            if (event.action == MouseAction.Move || event.action == MouseAction.Wheel) {
                int threshold = 3;
                if (event.x < _pos.left - threshold || event.x > _pos.right + threshold || event.y < _pos.top - threshold || event.y > _pos.bottom + threshold) {
                    Log.d("Closing popup due to PopupFlags.CloseOnMouseMoveOutside flag");
                    close();
                    return false;
                }
            }
        }
        return false;
    }
}
