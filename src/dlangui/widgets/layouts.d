module dlangui.widgets.layouts;

import dlangui.widgets.widget;

enum Orientation : ubyte {
    Vertical,
    Horizontal
}

class LinearLayout : WidgetGroup {
    protected Orientation _orientation = Orientation.Vertical;
    /// returns linear layout orientation (Vertical, Horizontal)
    @property Orientation orientation() { return _orientation; }
    /// sets linear layout orientation
    @property LinearLayout orientation(Orientation value) { _orientation = value; requestLayout(); return this; }

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
        int contentWidth = 0;
        int contentHeight = 0;
        if (orientation == Orientation.Vertical) {
            // Vertical
            int max = 0;
            int total = 0;
            for (int i = 0; i < _children.count; i++) {
                Widget item = _children.get(i);
                if (item.visibility == Visibility.Gone)
                    continue;
                item.measure(pwidth, pheight);
                if (max < item.measuredWidth)
                    max = item.measuredWidth;
                total += item.measuredHeight;
            }
            contentWidth = max;
            contentHeight = total;
        } else {
            // Horizontal
            int max = 0;
            int total = 0;
            for (int i = 0; i < _children.count; i++) {
                Widget item = _children.get(i);
                if (item.visibility == Visibility.Gone)
                    continue;
                item.measure(pwidth, pheight);
                if (max < item.measuredHeight)
                    max = item.measuredHeight;
                total += item.measuredWidth;
            }
            contentWidth = total;
            contentHeight = max;
        }
        measuredContent(parentWidth, parentHeight, contentWidth, contentHeight);
    }

    /// Set widget rectangle to specified value and layout widget contents. (Step 2 of two phase layout).
    override void layout(Rect rc) {
        if (visibility == Visibility.Gone) {
            return;
        }
        _pos = rc;
        applyMargins(rc);
        applyPadding(rc);
        int contentWidth = 0;
        int contentHeight = 0;
        if (orientation == Orientation.Vertical) {
            // Vertical
            int position = 0;
            int totalSize = 0;
            int delta = 0;
            int resizableSize = 0;
            int resizableWeight = 0;
            int nonresizableSize = 0;
            int nonresizableWeight = 0;
            int maxItem = 0; // max item dimention
            // calc total size
            int visibleCount = 0;
            for (int i = 0; i < _children.count; i++) {
                Widget item = _children.get(i);
                if (item.visibility == Visibility.Gone)
                    continue;
                visibleCount++;
                totalSize += item.measuredHeight;
                if (maxItem < item.measuredWidth)
                    maxItem = item.measuredWidth;
                int weight = item.layoutWeight;
                if (item.layoutHeight == FILL_PARENT) {
                    resizableWeight += weight;
                    resizableSize += item.measuredHeight;
                } else {
                    nonresizableWeight += weight;
                    nonresizableSize += item.measuredHeight;
                }
            }
            if (layoutWidth == WRAP_CONTENT && maxItem < rc.width)
                contentWidth = maxItem;
            else
                contentWidth = rc.width;
            if (layoutHeight == FILL_PARENT || totalSize > rc.height)
                delta = rc.height - totalSize; // total space to add to fit
            bool needForceResize = false;
            bool needResize = false;
            int scaleFactor = 10000; // per weight unit
            if (delta != 0 && visibleCount > 0) {
                // need resize of some children
                needResize = true;
                needForceResize = delta < 0 || resizableSize < delta; // do we need resize non-FILL_PARENT items?
                if (needForceResize)
                    scaleFactor = 10000 * rc.height / (resizableSize + nonresizableSize) / (nonresizableWeight + resizableWeight);
                else
                    scaleFactor = 10000 * rc.height / (rc.height - delta) / resizableWeight;
            }
            for (int i = 0; i < _children.count; i++) {
                Widget item = _children.get(i);
                if (item.visibility == Visibility.Gone)
                    continue;
                int weight = item.layoutWeight;
                if (item.layoutHeight == FILL_PARENT) {
                    resizableWeight += weight;
                    resizableSize += item.measuredHeight;
                } else {
                    nonresizableWeight += weight;
                    nonresizableSize += item.measuredHeight;
                }
            }
            for (int i = 0; i < _children.count; i++) {
                Widget item = _children.get(i);
                if (item.visibility == Visibility.Gone)
                    continue;
                int layoutSize = item.layoutHeight;
                totalWeight += item.measuredHeight;
                int weight = item.layoutWeight;
                if (layoutSize) {
                    resizableWeight += weight;
                    resizableSize += item.measuredHeight;
                }
            }
        } else {
            // Horizontal
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
        // TODO
        _needDraw = false;
    }

}
