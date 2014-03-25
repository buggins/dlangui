module dlangui.widgets.lists;

import dlangui.widgets.widget;
import dlangui.widgets.controls;

/// list widget adapter provides items for list widgets
interface ListAdapter {
    /// returns number of widgets in list
    @property int itemCount();
    /// return list item widget by item index
    Widget itemWidget(int index);
}

class ListWidget : WidgetGroup {
    protected Orientation _orientation = Orientation.Vertical;
    /// returns linear layout orientation (Vertical, Horizontal)
    @property Orientation orientation() { return _orientation; }
    /// sets linear layout orientation
    @property LinearLayout orientation(Orientation value) { 
        _orientation = value;
        _scrollbar.orientation = value;
        requestLayout(); 
        return this; 
    }

    protected Rect[] _itemRects;
    protected ScrollBar _scrollbar;

    protected ListAdapter _adapter;
    /// get adapter
    @property ListAdapter adapter() { return _adapter; }
    /// set adapter
    @property ListWidget adapter(ListAdapter adapter) { 
        _adapter = adapter; 
        onAdapterChanged();
        return this; 
    }

    /// returns number of widgets in list
    @property int itemCount() {
        if (_adapter !is null)
            return _adapter.itemCount;
        return 0;
    }

    /// return list item widget by item index
    Widget itemWidget(int index) {
        if (_adapter !is null)
            return _adapter.itemWidget(index);
        return null;
    }

    void onAdapterChanged() {
        requestLayout();
    }

	this(string ID = null, Orientation orientation = Orientation.Vertical) {
		super(ID);
        _orientation = orientation;
        _scrollbar = new ScrollBar("listscroll", orientation);
        _scrollbar.visibility = Visibility.Gone;
	}

    /// Measure widget according to desired width and height constraints. (Step 1 of two phase layout).
    override void measure(int parentWidth, int parentHeight) {
        if (visibility == Visibility.Gone) {
            _measuredWidth = _measuredHeight = 0;
            return;
        }
        Rect m = margins;
        Rect p = padding;
        // calc size constraints for children
        int pwidth = parentWidth;
        int pheight = parentHeight;
        if (parentWidth != SIZE_UNSPECIFIED)
            pwidth -= m.left + m.right + p.left + p.right;
        if (parentHeight != SIZE_UNSPECIFIED)
            pheight -= m.top + m.bottom + p.top + p.bottom;
        _scrollbar.measure(pwidth, pheight);
        int sbsize = _orientation == Orientation.Vertical ? _scrollbar.measuredWidth : _scrollbar.measuredHeight;
        // measure children
		Point sz;
        Point sbsz;
        for (int i = 0; i < itemCount; i++) {
            Widget w = itemWidget(i);
            if (w is null || w.visibility == Visibility.Gone)
                continue;
            w.measure(pwidth, pheight);
            if (_orientation == Orientation.Vertical) {
                // Vertical
                if (sz.x < w.measuredWidth)
                    sz.x = w.measuredWidth;
                sz.y += w.measuredHeight;
            } else {
                // Horizontal
                w.measure(pwidth, pheight);
                if (sz.y < w.measuredHeight)
                    sz.y = w.measuredHeight;
                sz.x += w.measuredWidth;
            }
        }
        bool needScrollbar;
        if (_orientation == Orientation.Vertical) {
            if (pheight != SIZE_UNSPECIFIED && sz.y > pheight) {
                // need scrollbar
                if (pwidth != SIZE_UNSPECIFIED) {
                    pwidth -= sbsize;
                    sbsz.x = sbsize;
                    needScrollbar = true;
                }
            }
        } else {
            if (pwidth != SIZE_UNSPECIFIED && sz.x > pwidth) {
                // need scrollbar
                if (pheight != SIZE_UNSPECIFIED) {
                    pheight -= sbsize;
                    sbsz.y = sbsize;
                    needScrollbar = true;
                }
            }
        }
        if (needScrollbar) {
            // recalculate with scrollbar
            sz.x = sz.y = 0;
            for (int i = 0; i < itemCount; i++) {
                Widget w = itemWidget(i);
                if (w is null || w.visibility == Visibility.Gone)
                    continue;
                w.measure(pwidth, pheight);
                if (_orientation == Orientation.Vertical) {
                    // Vertical
                    if (sz.x < w.measuredWidth)
                        sz.x = w.measuredWidth;
                    sz.y += w.measuredHeight;
                } else {
                    // Horizontal
                    w.measure(pwidth, pheight);
                    if (sz.y < w.measuredHeight)
                        sz.y = w.measuredHeight;
                    sz.x += w.measuredWidth;
                }
            }
        }
        measuredContent(parentWidth, parentHeight, sz.x + sbsz.x, sz.y + sbsz.y);
    }

    /// Set widget rectangle to specified value and layout widget contents. (Step 2 of two phase layout).
    override void layout(Rect rc) {
        if (visibility == Visibility.Gone) {
            return;
        }
        _pos = rc;
        applyMargins(rc);
        applyPadding(rc);

        if (_itemRects.length < itemCount)
            _itemRects.length = itemCount;

        Rect r;
		Point sz;
        Point sbsz;
        int sbsize = _orientation == Orientation.Vertical ? _scrollbar.measuredWidth : _scrollbar.measuredHeight;
        r = rc;
        for (int i = 0; i < itemCount; i++) {

            Widget w = itemWidget(i);
            if (w is null || w.visibility == Visibility.Gone)
                continue;
            if (_orientation == Orientation.Vertical) {
                w.measure(rc.width, SIZE_UNSPECIFIED);
                // Vertical
                if (sz.x < w.measuredWidth)
                    sz.x = w.measuredWidth;
                sz.y += w.measuredHeight;
                r.bottom =
            } else {
                // Horizontal
                w.measure(pwidth, pheight);
                if (sz.y < w.measuredHeight)
                    sz.y = w.measuredHeight;
                sz.x += w.measuredWidth;
            }
        }

        _needLayout = false;
    }
    /// Draw widget at its position to buffer
    override void onDraw(DrawBuf buf) {
        if (visibility != Visibility.Visible)
            return;
        super.onDraw(buf);
        Rect rc = _pos;
        applyMargins(rc);
        applyPadding(rc);
        ClipRectSaver(buf, rc);
		for (int i = 0; i < _children.count; i++) {
			Widget item = _children.get(i);
			if (item.visibility != Visibility.Visible)
				continue;
			item.onDraw(buf);
		}
    }

}

