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
    @property ListWidget orientation(Orientation value) { 
        _orientation = value;
        _scrollbar.orientation = value;
        requestLayout(); 
        return this; 
    }

    protected Rect[] _itemRects;
    protected Point[] _itemSizes;
    protected bool _needScrollbar;
    protected Point _sbsz; // scrollbar size
    protected ScrollBar _scrollbar;
    protected int _lastMeasureWidth;
    protected int _lastMeasureHeight;

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
        addChild(_scrollbar);
	}

    /// Measure widget according to desired width and height constraints. (Step 1 of two phase layout).
    override void measure(int parentWidth, int parentHeight) {
        if (visibility == Visibility.Gone) {
            _measuredWidth = _measuredHeight = 0;
            return;
        }
        if (_itemSizes.length < itemCount)
            _itemSizes.length = itemCount;
        Rect m = margins;
        Rect p = padding;
        // calc size constraints for children
        int pwidth = parentWidth;
        int pheight = parentHeight;
        if (parentWidth != SIZE_UNSPECIFIED)
            pwidth -= m.left + m.right + p.left + p.right;
        if (parentHeight != SIZE_UNSPECIFIED)
            pheight -= m.top + m.bottom + p.top + p.bottom;
        _scrollbar.visibility = Visibility.Visible;
        _scrollbar.measure(pwidth, pheight);

        _lastMeasureWidth = pwidth;
        _lastMeasureHeight = pheight;

        int sbsize = _orientation == Orientation.Vertical ? _scrollbar.measuredWidth : _scrollbar.measuredHeight;
        // measure children
		Point sz;
        _sbsz.clear;
        for (int i = 0; i < itemCount; i++) {
            Widget w = itemWidget(i);
            if (w is null || w.visibility == Visibility.Gone) {
                _itemSizes[i].x = _itemSizes[i].y = 0;
                continue;
            }
            w.measure(pwidth, pheight);
            _itemSizes[i].x = w.measuredWidth;
            _itemSizes[i].y = w.measuredHeight;
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
        if (_orientation == Orientation.Vertical) {
            if (pheight != SIZE_UNSPECIFIED && sz.y > pheight) {
                // need scrollbar
                if (pwidth != SIZE_UNSPECIFIED) {
                    pwidth -= sbsize;
                    _sbsz.x = sbsize;
                    _needScrollbar = true;
                }
            }
        } else {
            if (pwidth != SIZE_UNSPECIFIED && sz.x > pwidth) {
                // need scrollbar
                if (pheight != SIZE_UNSPECIFIED) {
                    pheight -= sbsize;
                    _sbsz.y = sbsize;
                    _needScrollbar = true;
                }
            }
        }
        if (_needScrollbar) {
            // recalculate with scrollbar
            sz.x = sz.y = 0;
            for (int i = 0; i < itemCount; i++) {
                Widget w = itemWidget(i);
                if (w is null || w.visibility == Visibility.Gone)
                    continue;
                w.measure(pwidth, pheight);
                _itemSizes[i].x = w.measuredWidth;
                _itemSizes[i].y = w.measuredHeight;
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
        measuredContent(parentWidth, parentHeight, sz.x + _sbsz.x, sz.y + _sbsz.y);
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

        // measure again if client size has been changed
        if (_lastMeasureWidth != rc.width || _lastMeasureHeight != rc.height)
            measure(rc.width, rc.height);

        // layout scrollbar
        if (_needScrollbar) {
            _scrollbar.visibility = Visibility.Visible;
            Rect sbrect = rc;
            if (_orientation == Orientation.Vertical)
                sbrect.left = sbrect.right - _sbsz.x;
            else
                sbrect.top = sbrect.bottom - _sbsz.y;
            _scrollbar.layout(sbrect);
            rc.right -= _sbsz.x;
            rc.bottom -= _sbsz.y;
        } else {
            _scrollbar.visibility = Visibility.Gone;
        }

        // calc item rectangles
        Rect r;
        int p = 0;
        for (int i = 0; i < itemCount; i++) {
            if (_itemSizes[i].x == 0 && _itemSizes[i].y == 0)
                continue;
            if (_orientation == Orientation.Vertical) {
                // Vertical
                int w = rc.width;
                int h = _itemSizes[i].y;
                r.top = p;
                r.bottom = p + h;
                r.left = 0;
                r.right = w;
                _itemRects[i] = r;
                p += h;
            } else {
                // Horizontal
                int h = rc.height;
                int w = _itemSizes[i].x;
                r.top = 0;
                r.bottom = h;
                r.left = p;
                r.right = p + w;
                _itemRects[i] = r;
                p += w;
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
        // draw scrollbar
        if (_needScrollbar)
            _scrollbar.onDraw(buf);

        Point scrollOffset;
        // todo: scrollOffset
        // draw items
        for (int i = 0; i < itemCount; i++) {
            Widget w = itemWidget(i);
            if (w is null || w.visibility != Visibility.Visible)
                continue;
            Rect itemrc = _itemRects[i];
            itemrc.left += rc.left - scrollOffset.x;
            itemrc.right += rc.left - scrollOffset.x;
            itemrc.top += rc.top - scrollOffset.y;
            itemrc.bottom += rc.top - scrollOffset.y;
            w.measure(itemrc.width, itemrc.height);
            w.layout(itemrc);
			w.onDraw(buf);
		}
    }

}

