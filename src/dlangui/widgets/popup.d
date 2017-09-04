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
    /// place popup below anchor widget close to lower bound
    Below = 2,
    /// place popup below anchor widget close to lower bound
    Above = 16,
    /// place popup below anchor widget close to right bound (when no space enough, align near left bound)
    Right = 4,
    /// align to specified point
    Point = 8,
    /// if popup content size is less than anchor's size, increase it to anchor size
    FitAnchorSize = 16,
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
            } else if (anchor.alignment & PopupAlign.Below) {
            } else if (anchor.alignment & PopupAlign.Above) {
                r.top -= h;
            } else if (anchor.alignment & PopupAlign.Right) {
            }
        } else {
            if (anchor.alignment & PopupAlign.Center) {
                // center around center of anchor widget
                r.left = anchorrc.middlex - w / 2;
                r.top = anchorrc.middley - h / 2;
            } else if (anchor.alignment & PopupAlign.Below) {
                r.left = anchorrc.left;
                r.top = anchorrc.bottom;
            } else if (anchor.alignment & PopupAlign.Above) {
                r.left = anchorrc.left;
                r.top = anchorrc.top - h;
            } else if (anchor.alignment & PopupAlign.Right) {
                r.left = anchorrc.right;
                r.top = anchorrc.top;
            }
            if (anchor.alignment & PopupAlign.FitAnchorSize)
                if (w < anchorrc.width)
                    w = anchorrc.width;
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
            if (event.action == MouseAction.ButtonDown) {
                // clicked outside - close popup
                close();
                return false;
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
