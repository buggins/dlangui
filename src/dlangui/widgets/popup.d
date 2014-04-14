module dlangui.widgets.popup;

import dlangui.widgets.widget;
import dlangui.widgets.layouts;
import dlangui.platforms.common.platform;

struct PopupAnchor {
    Widget widget;
    Align  alignment;
}

/// popup widget container
class PopupWidget : LinearLayout {
    protected PopupAnchor _anchor;
    protected bool _modal;
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
        int extraw = rc.width - w;
        int extrah = rc.height - h;

        Rect r;
        if (anchor.widget !is null)
            r = anchor.widget.pos;
        else
            r = rc;
        r.left += extraw / 2;
        r.top += extrah / 2;
        r.right -= extraw / 2;
        r.bottom -= extrah / 2;
        super.layout(r);
    }

    this(Widget content, Window window) {
        _window = window;
        styleId = "POPUP_MENU";
        addChild(content);
    }
}
