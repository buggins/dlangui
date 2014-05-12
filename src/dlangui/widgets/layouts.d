// Written in the D programming language.

/**
DLANGUI library.

This module contains common layouts implementations.

Layouts are similar to the same in Android.

LinearLayout - either VerticalLayout or HorizontalLayout.
FrameLayout - children occupy the same place, usually one one is visible at a time


Synopsis:

----
import dlangui.widgets.layouts;

----

Copyright: Vadim Lopatin, 2014
License:   $(WEB boost.org/LICENSE_1_0.txt, Boost License 1.0).
Authors:   $(WEB coolreader.org, Vadim Lopatin)
*/
module dlangui.widgets.layouts;

public import dlangui.widgets.widget;

/// helper for layouts
struct LayoutItem {
	Widget _widget;
	Orientation _orientation;
	int _measuredSize; // primary size for orientation
	int _secondarySize; // other measured size
	int _layoutSize; //  layout size for primary dimension
	int _minSize; //  min size for primary dimension
	int _maxSize; //  max size for primary dimension
	int _weight; // weight
	bool _fillParent;
    @property int measuredSize() { return _measuredSize; }
    @property int minSize() { return _measuredSize; }
    @property int maxSize() { return _maxSize; }
    @property int layoutSize() { return _layoutSize; }
    @property int secondarySize() { return _layoutSize; }
    @property bool fillParent() { return _fillParent; }
    @property int weight() { return _weight; }
	// just to help GC
	void clear() {
		_widget = null;
	}
    /// sets item for widget
    void set(Widget widget, Orientation orientation) {
		_widget = widget;
		_orientation = orientation;
    }
	/// set item and measure it
	void measure(int parentWidth, int parentHeight) {
		_widget.measure(parentWidth, parentHeight);
        _weight = _widget.layoutWeight;
		if (_orientation == Orientation.Horizontal) {
			_secondarySize = _widget.measuredHeight;
			_measuredSize = _widget.measuredWidth;
			_minSize = _widget.minWidth;
			_maxSize = _widget.maxWidth;
			_layoutSize = _widget.layoutWidth;
		} else {
			_secondarySize = _widget.measuredWidth;
			_measuredSize = _widget.measuredHeight;
			_minSize = _widget.minHeight;
			_maxSize = _widget.maxHeight;
			_layoutSize = _widget.layoutHeight;
		}
		_fillParent = _layoutSize == FILL_PARENT;
	}
    void layout(ref Rect rc) {
        _widget.layout(rc);
    }
}

/// helper class for layouts
class LayoutItems {
	Orientation _orientation;
	LayoutItem[] _list;
	int _count;
	int _totalSize;
	int _maxSecondarySize;
    Point _measureParentSize;

    int _layoutWidth;
    int _layoutHeight;

    void setLayoutParams(Orientation orientation, int layoutWidth, int layoutHeight) {
        _orientation = orientation;
        _layoutWidth = layoutWidth;
        _layoutHeight = layoutHeight;
    }

	/// fill widget layout list with Visible or Invisible items, measure them
	Point measure(int parentWidth, int parentHeight) {
		_totalSize = 0;
		_maxSecondarySize = 0;
        _measureParentSize.x = parentWidth;
        _measureParentSize.y = parentHeight;
		// measure
		for (int i = 0; i < _count; i++) {
			LayoutItem * item = &_list[i];
			item.measure(parentWidth, parentHeight);
			if (_maxSecondarySize < item._secondarySize)
				_maxSecondarySize = item._secondarySize;
			_totalSize += item._measuredSize;
		}
		return _orientation == Orientation.Horizontal ? Point(_totalSize, _maxSecondarySize) : Point(_maxSecondarySize, _totalSize);
	}

	/// fill widget layout list with Visible or Invisible items, measure them
	void setWidgets(ref WidgetList widgets) {
		// remove old items, if any
		clear();
		// reserve space
		if (_list.length < widgets.count)
			_list.length = widgets.count;
		// copy
		for (int i = 0; i < widgets.count; i++) {
			Widget item = widgets.get(i);
			if (item.visibility == Visibility.Gone)
				continue;
			_list[_count++].set(item, _orientation);
		}
	}

    void layout(Rect rc) {
        // measure again - available area could be changed
        if (_measureParentSize.x != rc.width || _measureParentSize.y != rc.height)
            measure(rc.width, rc.height);
        int contentSecondarySize = 0;
        int contentHeight = 0;
        int totalSize = 0;
        int delta = 0;
        int resizableSize = 0;
        int resizableWeight = 0;
        int nonresizableSize = 0;
        int nonresizableWeight = 0;
        int maxItem = 0; // max item dimention
        // calc total size
        int visibleCount = cast(int)_list.length;
        for (int i = 0; i < _count; i++) {
			LayoutItem * item = &_list[i];
            int weight = item.weight;
			int size = item.measuredSize;
            totalSize += size;
            if (maxItem < item.secondarySize)
                maxItem = item.secondarySize;
            if (item.fillParent) {
                resizableWeight += weight;
                resizableSize += size * weight;
            } else {
                nonresizableWeight += weight;
                nonresizableSize += size * weight;
            }
        }
        if (_orientation == Orientation.Vertical) {
            if (_layoutWidth == WRAP_CONTENT && maxItem < rc.width)
                contentSecondarySize = maxItem;
            else
                contentSecondarySize = rc.width;
            if (_layoutHeight == FILL_PARENT || totalSize > rc.height)
                delta = rc.height - totalSize; // total space to add to fit
        } else {
            if (_layoutHeight == WRAP_CONTENT && maxItem < rc.height)
                contentSecondarySize = maxItem;
            else
                contentSecondarySize = rc.height;
            if (_layoutWidth == FILL_PARENT || totalSize > rc.width)
                delta = rc.width - totalSize; // total space to add to fit
        }
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
            if (needForceResize && nonresizableSize + resizableSize > 0)
                scaleFactor = 10000 * delta / (nonresizableSize + resizableSize);
            else if (resizableSize > 0)
                scaleFactor = 10000 * delta / resizableSize;
			else
				scaleFactor = 0;
        }
		//Log.d("VerticalLayout delta=", delta, ", nonres=", nonresizableWeight, ", res=", resizableWeight, ", scale=", scaleFactor);
		// find last resized - to allow fill space 1 pixel accurate
		int lastResized = -1;
        for (int i = 0; i < _count; i++) {
			LayoutItem * item = &_list[i];
            if (item.fillParent || needForceResize) {
				lastResized = i;
            }
		}
		// final resize and layout of children
        int position = 0;
		int deltaTotal = 0;
        for (int i = 0; i < _count; i++) {
			LayoutItem * item = &_list[i];
            int layoutSize = item.layoutSize;
            int weight = item.weight;
			int size = item.measuredSize;
            if (needResize && (layoutSize == FILL_PARENT || needForceResize)) {
				// do resize
				int correction = scaleFactor * weight * size / 10000;
				deltaTotal += correction;
				// for last resized, apply additional correction to resolve calculation inaccuracy
				if (i == lastResized) {
					correction += delta - deltaTotal;
				}
				size += correction;
            }
			// apply size
			Rect childRect = rc;
            if (_orientation == Orientation.Vertical) {
                // Vertical
                childRect.top += position;
			    childRect.bottom = childRect.top + size;
			    childRect.right = childRect.left + contentSecondarySize;
			    item.layout(childRect);
            } else {
                // Horizontal
                childRect.left += position;
			    childRect.right = childRect.left + size;
			    childRect.bottom = childRect.top + contentSecondarySize;
			    item.layout(childRect);
            }
			position += size;
        }
    }

	void clear() {
		for (int i = 0; i < _count; i++)
			_list[i].clear();
		_count = 0;
	}
	~this() {
		clear();
	}
}

class LinearLayout : WidgetGroup {
    protected Orientation _orientation = Orientation.Vertical;
    /// returns linear layout orientation (Vertical, Horizontal)
    @property Orientation orientation() { return _orientation; }
    /// sets linear layout orientation
    @property LinearLayout orientation(Orientation value) { _orientation = value; requestLayout(); return this; }

	this(string ID = null) {
		super(ID);
		_layoutItems = new LayoutItems();
	}

	LayoutItems _layoutItems;
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
        _layoutItems.setLayoutParams(orientation, layoutWidth, layoutHeight);
        _layoutItems.setWidgets(_children);
		Point sz = _layoutItems.measure(pwidth, pheight);
        measuredContent(parentWidth, parentHeight, sz.x, sz.y);
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
        _layoutItems.layout(rc);
    }
    /// Draw widget at its position to buffer
    override void onDraw(DrawBuf buf) {
        if (visibility != Visibility.Visible)
            return;
        super.onDraw(buf);
        Rect rc = _pos;
        applyMargins(rc);
        applyPadding(rc);
		auto saver = ClipRectSaver(buf, rc);
		for (int i = 0; i < _children.count; i++) {
			Widget item = _children.get(i);
			if (item.visibility != Visibility.Visible)
				continue;
			item.onDraw(buf);
		}
    }

}

class VerticalLayout : LinearLayout {
    this(string ID = null) {
        super(ID);
        orientation = Orientation.Vertical;
    }
}

class HorizontalLayout : LinearLayout {
    this(string ID = null) {
        super(ID);
        orientation = Orientation.Horizontal;
    }
}

/// place all children into same place (usually, only one child should be visible at a time)
class FrameLayout : WidgetGroup {
    this(string ID) {
        super(ID);
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
        for (int i = 0; i < _children.count; i++) {
            Widget item = _children.get(i);
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

    /// Set widget rectangle to specified value and layout widget contents. (Step 2 of two phase layout).
    override void layout(Rect rc) {
        _needLayout = false;
        if (visibility == Visibility.Gone) {
            return;
        }
        _pos = rc;
        applyMargins(rc);
        applyPadding(rc);
        for (int i = 0; i < _children.count; i++) {
            Widget item = _children.get(i);
            if (item.visibility != Visibility.Gone) {
                item.layout(rc);
            }
        }
    }

    /// Draw widget at its position to buffer
    override void onDraw(DrawBuf buf) {
        if (visibility != Visibility.Visible)
            return;
        super.onDraw(buf);
        Rect rc = _pos;
        applyMargins(rc);
        applyPadding(rc);
        auto saver = ClipRectSaver(buf, rc);
		for (int i = 0; i < _children.count; i++) {
			Widget item = _children.get(i);
			if (item.visibility != Visibility.Visible)
				continue;
			item.onDraw(buf);
		}
    }

    /// make one of children (with specified ID) visible, for the rest, set visibility to otherChildrenVisibility
    bool showChild(string ID, Visibility otherChildrenVisibility = Visibility.Invisible, bool updateFocus = false) {
        bool found = false;
        Widget foundWidget = null;
		for (int i = 0; i < _children.count; i++) {
			Widget item = _children.get(i);
            if (item.compareId(ID)) {
                item.visibility = Visibility.Visible;
                foundWidget = item;
                found = true;
            } else {
                item.visibility = otherChildrenVisibility;
            }
		}
        if (foundWidget !is null && updateFocus)
            foundWidget.setFocus();
        return found;
    }
}

/// layout children as table with rows and columns
class TableLayout : WidgetGroup {

	protected static struct TableLayoutItem {
		int col;
		int row;
		Widget widget;
		int measuredWidth;
		int measuredHeight;
		int layoutWidth;
		int layoutHeight;
		void clear(int col, int row) {
			this.col = col;
			this.row = row;
			widget = null;
		}
		void measure(Widget w, int pwidth, int pheight) {
			widget = w;
			if (widget) {
				widget.measure(pwidth, pheight);
				measuredWidth = widget.measuredWidth;
				measuredHeight = widget.measuredHeight;
				layoutWidth = widget.layoutWidth;
				layoutHeight = widget.layoutHeight;
			} else {
				measuredWidth = measuredHeight = layoutWidth = layoutHeight = 0;
			}
		}
	}
	protected static struct TableLayoutRow {
		int row;
		int measuredWidth;
		int measuredHeight;
		int layoutWidth;
		int layoutHeight;
		TableLayoutItem[] _cells;
		void init(int row, int colCount) {
			measuredWidth = measuredHeight = layoutWidth = layoutHeight = 0;
			this.row = row;
			_cells.length = colCount;
			for(int i = 0; i < colCount; i++) {
				_cells[i].clear(i, row);
			}
		}
		ref TableLayoutItem cell(int col) {
			return _cells[col];
		}
		void cellMeasured(ref TableLayoutItem cell) {
			if (measuredWidth < cell.measuredWidth)
				measuredWidth = cell.measuredWidth;
			if (measuredHeight < cell.measuredHeight)
				measuredHeight = cell.measuredHeight;
			if (cell.layoutWidth == FILL_PARENT)
				layoutWidth = FILL_PARENT;
			if (cell.layoutHeight == FILL_PARENT)
				layoutHeight = FILL_PARENT;
		}
	}
	protected static struct TableLayoutCol {
		int col;
		int measuredWidth;
		int measuredHeight;
		int layoutWidth;
		int layoutHeight;
		void init(int col) {
			this.col = col;
			measuredWidth = measuredHeight = layoutWidth = layoutHeight = 0;
		}
		void cellMeasured(ref TableLayoutItem cell) {
			if (measuredWidth < cell.measuredWidth)
				measuredWidth = cell.measuredWidth;
			if (measuredHeight < cell.measuredHeight)
				measuredHeight = cell.measuredHeight;
			if (cell.layoutWidth == FILL_PARENT)
				layoutWidth = FILL_PARENT;
			if (cell.layoutHeight == FILL_PARENT)
				layoutHeight = FILL_PARENT;
		}
	}
	protected static struct TableLayoutRows {
		protected TableLayoutCol[] _cols;
		protected TableLayoutRow[] _rows;
		protected int colCount;
		protected int rowCount;
		void init(int cols, int rows) {
			colCount = cols;
			rowCount = rows;
			_rows.length = rows;
			_cols.length = cols;
			for(int i = 0; i < rows; i++)
				_rows[i].init(i, cols);
			for(int i = 0; i < cols; i++)
				_cols[i].init(i);
		}
		ref TableLayoutItem cell(int col, int row) {
			return _rows[row].cell(col);
		}
		ref TableLayoutCol col(int c) {
			return _cols[c];
		}
		ref TableLayoutRow row(int r) {
			return _rows[r];
		}
		Point measure(Widget parent, int cc, int rc, int pwidth, int pheight) {
			init(cc, rc);
			for (int y = 0; y < rc; y++) {
				for (int x = 0; x < cc; x++) {
					int index = y * cc + x;
					Widget child = index < parent.childCount ? parent.child(index) : null;
					cell(x, y).measure(child, pwidth, pheight);
				}
			}
			// calc total row size
			int totalHeight = 0;
			for (int y = 0; y < rc; y++) {
				for (int x = 0; x < cc; x++) {
					row(y).cellMeasured(cell(x,y));
				}
				totalHeight += row(y).measuredHeight;
			}
			// calc total col size
			int totalWidth = 0;
			for (int x = 0; x < cc; x++) {
				for (int y = 0; y < rc; y++) {
					col(x).cellMeasured(cell(x,y));
				}
				totalWidth += col(x).measuredWidth;
			}
			return Point(totalWidth, totalHeight);
		}
	}
	protected TableLayoutRows _cells;

	protected int _colCount = 1;
	/// number of columns
	@property int colCount() { return _colCount; }
	@property TableLayout colCount(int count) { if (_colCount != count) requestLayout(); _colCount = count; return this; }
	@property int rowCount() {
		return (childCount + (_colCount - 1)) / _colCount * _colCount;
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

		int rc = rowCount;
		Point sz = _cells.measure(this, colCount, rc, pwidth, pheight);
		measuredContent(parentWidth, parentHeight, sz.x, sz.y);
	}
}
