module dlangui.widgets.popup;

import dlangui.widgets.widget;
import dlangui.widgets.layouts;
import dlangui.platforms.common.platform;

/// popup alignment option flags
enum PopupAlign : uint {
    /// center popup around anchor widget center
    Center = 1,
    /// place popup below anchor widget close to lower bound
    Below = 2,
}

struct PopupAnchor {
    Widget widget;
    uint  alignment = PopupAlign.Center;
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
	/// close and destroy popup
	void close() {
		window.removePopup(this);
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

        if (anchor.alignment & PopupAlign.Center) {
            // center around center of anchor widget
            r.left = anchorrc.middlex - w / 2;
            r.top = anchorrc.middley - h / 2;
        } else if (anchor.alignment & PopupAlign.Below) {
            r.left = anchorrc.left;
            r.top = anchorrc.bottom;
        }
        r.right = r.left + w;
        r.bottom = r.top + h;
        r.moveToFit(rc);
        super.layout(r);
    }

    this(Widget content, Window window) {
        _window = window;
        //styleId = "POPUP_MENU";
        addChild(content);
    }
}
