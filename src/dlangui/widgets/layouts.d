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
                int weight = item.layoutWeight;
				int size = item.measuredHeight;
                totalSize += size;
                if (maxItem < item.measuredWidth)
                    maxItem = item.measuredWidth;
                if (item.layoutHeight == FILL_PARENT) {
                    resizableWeight += weight;
                    resizableSize += size * weight;
                } else {
                    nonresizableWeight += weight;
                    nonresizableSize += size * weight;
                }
            }
            if (layoutWidth == WRAP_CONTENT && maxItem < rc.width)
                contentWidth = maxItem;
            else
                contentWidth = rc.width;
            if (layoutHeight == FILL_PARENT || totalSize > rc.height)
                delta = rc.height - totalSize; // total space to add to fit
			// calculate resize options and scale
            bool needForceResize = false;
            bool needResize = false;
            int scaleFactor = 10000; // per weight unit
            if (delta != 0 && visibleCount > 0) {
                // need resize of some children
                needResize = true;
				// resize all if need to shrink or only resizable are too small to correct delta
                needForceResize = delta < 0 || resizableWeight == 0; // || resizableSize * 2 / 3 < delta; // do we need resize non-FILL_PARENT items?
				// calculate scale factor: weight / delta * 10000
                if (needForceResize)
                    scaleFactor = 10000 * delta / (nonresizableSize + resizableSize);
                else
                    scaleFactor = 10000 * delta / resizableSize;
            }
			//Log.d("VerticalLayout delta=", delta, ", nonres=", nonresizableWeight, ", res=", resizableWeight, ", scale=", scaleFactor);
			// find last resized - to allow fill space 1 pixel accurate
			Widget lastResized = null;
            for (int i = 0; i < _children.count; i++) {
                Widget item = _children.get(i);
                if (item.visibility == Visibility.Gone)
                    continue;
                if (item.layoutHeight == FILL_PARENT || needForceResize) {
					lastResized = item;
                }
			}
			// final resize and layout of children
            int position = 0;
			int deltaTotal = 0;
            for (int i = 0; i < _children.count; i++) {
                Widget item = _children.get(i);
                if (item.visibility == Visibility.Gone)
                    continue;
                int layoutSize = item.layoutHeight;
                int weight = item.layoutWeight;
				int size = item.measuredHeight;
                if (needResize && (layoutSize == FILL_PARENT || needForceResize)) {
					// do resize
					int correction = scaleFactor * weight * size / 10000;
					deltaTotal += correction;
					// for last resized, apply additional correction to resolve calculation inaccuracy
					if (item == lastResized) {
						correction += delta - deltaTotal;
					}
					size += correction;
                }
				// apply size
				Rect childRect = rc;
				childRect.top += position;
				childRect.bottom = childRect.top + size;
				childRect.right = childRect.left + contentWidth;
				item.layout(childRect);
				position += size;
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
        ClipRectSaver(buf, rc);
		for (int i = 0; i < _children.count; i++) {
			Widget item = _children.get(i);
			if (item.visibility != Visibility.Visible)
				continue;
			item.onDraw(buf);
		}
    }

}
