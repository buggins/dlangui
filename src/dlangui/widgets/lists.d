// Written in the D programming language.

/**
This module contains list widgets implementation.

Similar to lists implementation in Android UI API.

Synopsis:

----
import dlangui.widgets.lists;

----

Copyright: Vadim Lopatin, 2014
License:   Boost License 1.0
Authors:   Vadim Lopatin, coolreader.org@gmail.com
*/
module dlangui.widgets.lists;

import dlangui.widgets.widget;
import dlangui.widgets.controls;

/// list widget adapter provides items for list widgets
interface ListAdapter {
    /// returns number of widgets in list
    @property int itemCount();
    /// return list item widget by item index
    Widget itemWidget(int index);
	/// return list item's state flags
	uint itemState(int index);
	/// set one or more list item's state flags, returns updated state
	uint setItemState(int index, uint flags);
	/// reset one or more list item's state flags, returns updated state
	uint resetItemState(int index, uint flags);
}

/// List adapter for simple list of widget instances
class WidgetListAdapter : ListAdapter {
    WidgetList _widgets;
    /// list of widgets to display
    @property ref WidgetList widgets() { return _widgets; }
    /// returns number of widgets in list
    @property override int itemCount() {
        return _widgets.count;
    }
    /// return list item widget by item index
    override Widget itemWidget(int index) {
        return _widgets.get(index);
    }
	/// return list item's state flags
	override uint itemState(int index) {
		return _widgets.get(index).state;
	}
	/// set one or more list item's state flags, returns updated state
	override uint setItemState(int index, uint flags) {
		return _widgets.get(index).setState(flags).state;
	}
	/// reset one or more list item's state flags, returns updated state
	override uint resetItemState(int index, uint flags) {
		return _widgets.get(index).resetState(flags).state;
	}
    ~this() {
        //Log.d("Destroying WidgetListAdapter");
    }
}

/** List adapter providing strings only. */
class StringListAdapter : ListAdapter {
    protected UIStringCollection _items;
    protected uint[] _states;
    protected TextWidget _widget;
    protected int _lastItemIndex;

    /** create empty string list adapter. */
    this() {
        _lastItemIndex = -1;
    }

    /** Init with array of string resource IDs. */
    this(string[] items) {
        _items.addAll(items);
        _lastItemIndex = -1;
        updateStatesLength();
    }

    /** Init with array of unicode strings. */
    this(dstring[] items) {
        _items.addAll(items);
        _lastItemIndex = -1;
        updateStatesLength();
    }

    /** Access to items collection. */
    @property ref UIStringCollection items() { return _items; }

    /// returns number of widgets in list
    @property override int itemCount() {
        return _items.length;
    }

    protected void updateStatesLength() {
        if (_states.length < _items.length) {
            int oldlen = _states.length;
            _states.length = _items.length;
            for (int i = oldlen; i < _items.length; i++)
                _states[i] = State.Enabled;
        }
    }

    /// return list item widget by item index
    override Widget itemWidget(int index) {
        updateStatesLength();
        if (_widget is null) {
            _widget = new TextWidget("LIST_ITEM");
            _widget.styleId = "LIST_ITEM";
        } else {
            if (index == _lastItemIndex)
                return _widget;
        }
        // update widget
        _widget.text = _items.get(index);
        _widget.state = _states[index];
        _lastItemIndex = index;
        return _widget;
    }

	/// return list item's state flags
	override uint itemState(int index) {
        updateStatesLength();
        return _states[index];
	}

	/// set one or more list item's state flags, returns updated state
	override uint setItemState(int index, uint flags) {
        updateStatesLength();
        _states[index] |= flags;
        if (_widget !is null && _lastItemIndex == index)
            _widget.state = _states[index];
        return _states[index];
	}
	/// reset one or more list item's state flags, returns updated state
	override uint resetItemState(int index, uint flags) {
        updateStatesLength();
        _states[index] &= ~flags;
        if (_widget !is null && _lastItemIndex == index)
            _widget.state = _states[index];
		return _states[index];
	}

    ~this() {
        //Log.d("Destroying StringListAdapter");
        if (_widget)
            destroy(_widget);
    }
}

/// List
class ListWidget : WidgetGroup, OnScrollHandler {
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

    /// first visible item index
    protected int _firstVisibleItem;
    /// scroll position - offset of scroll area
    protected int _scrollPosition;
    /// maximum scroll position
    protected int _maxScrollPosition;
    /// client area rectangle (counting padding, margins, and scrollbar)
    protected Rect _clientRc;
    /// total height of all items for Vertical orientation, or width for Horizontal
    protected int _totalSize;
	/// item with Hover state, -1 if no such item
	protected int _hoverItemIndex;
	/// item with Selected state, -1 if no such item
	protected int _selectedItemIndex;

	/// when true, mouse hover selects underlying item
	protected bool _selectOnHover;
	/// when true, mouse hover selects underlying item
	@property bool selectOnHover() { return _selectOnHover; }
	/// when true, mouse hover selects underlying item
	@property ListWidget selectOnHover(bool select) { _selectOnHover = select; return this; }

	/// if true, generate itemClicked on mouse down instead mouse up event
	protected bool _clickOnButtonDown;

    /// returns rectangle for item (not scrolled, first item starts at 0,0)
    Rect itemRectNoScroll(int index) {
        if (index < 0 || index >= _itemRects.length)
            return Rect.init;
        Rect res;
        res = _itemRects[index];
        return res;
    }

    /// returns rectangle for item (scrolled)
    Rect itemRect(int index) {
        if (index < 0 || index >= _itemRects.length)
            return Rect.init;
        Rect res = itemRectNoScroll(index);
        if (_orientation == Orientation.Horizontal) {
            res.left -= _scrollPosition;
            res.right -= _scrollPosition;
        } else {
            res.top -= _scrollPosition;
            res.bottom -= _scrollPosition;
        }
        return res;
    }

    /// returns item index by 0-based offset from top/left of list content
    int itemByPosition(int pos) {
        return 0;
    }

    protected ListAdapter _adapter;
    /// when true, need to destroy adapter on list destroy
    protected bool _ownAdapter;

    /// get adapter
    @property ListAdapter adapter() { return _adapter; }
    /// set adapter
    @property ListWidget adapter(ListAdapter adapter) {
        if (_adapter !is null && _ownAdapter)
            destroy(_adapter);
        _adapter = adapter; 
        _ownAdapter = false;
        onAdapterChanged();
        return this; 
    }
    /// set adapter, which will be owned by list (destroy will be called for adapter on widget destroy)
    @property ListWidget ownAdapter(ListAdapter adapter) { 
        if (_adapter !is null && _ownAdapter)
            destroy(_adapter);
        _adapter = adapter; 
        _ownAdapter = true;
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

    /// returns true if item with corresponding index is enabled
    bool itemEnabled(int index) {
        if (_adapter !is null && index >= 0 && index < itemCount)
            return (_adapter.itemState(index) & State.Enabled) != 0;
        return false;
    }

    void onAdapterChanged() {
        requestLayout();
    }

	this(string ID = null, Orientation orientation = Orientation.Vertical) {
		super(ID);
        _orientation = orientation;
        focusable = true;
		_hoverItemIndex = -1;
		_selectedItemIndex = -1;
        _scrollbar = new ScrollBar("listscroll", orientation);
        _scrollbar.visibility = Visibility.Gone;
        _scrollbar.onScrollEventListener = &onScrollEvent;
        addChild(_scrollbar);
	}

	protected void setHoverItem(int index) {
		if (_hoverItemIndex == index)
			return;
		if (_hoverItemIndex != -1) {
			_adapter.resetItemState(_hoverItemIndex, State.Hovered);
			invalidate();
		}
		_hoverItemIndex = index;
		if (_hoverItemIndex != -1) {
			_adapter.setItemState(_hoverItemIndex, State.Hovered);
			invalidate();
		}
	}

	/// override to handle change of selection
	protected void selectionChanged(int index, int previouslySelectedItem = -1) {
	}

	/// override to handle mouse up on item
	protected void itemClicked(int index) {
	}

    protected void updateSelectedItemFocus() {
		if (_selectedItemIndex != -1) {
            if ((_adapter.itemState(_selectedItemIndex) & State.Focused) != (state & State.Focused)) {
                if (state & State.Focused)
                    _adapter.setItemState(_selectedItemIndex, State.Focused);
                else
                    _adapter.resetItemState(_selectedItemIndex, State.Focused);
                invalidate();
            }
        }
    }

    /// override to handle focus changes
    override protected void handleFocusChange(bool focused) {
        updateSelectedItemFocus();
    }

    /// ensure selected item is visible (scroll if necessary)
    void makeSelectionVisible() {
        if (_selectedItemIndex < 0)
            return; // no selection
        if (needLayout) {
            _makeSelectionVisibleOnNextLayout = true;
            return;
        }
        makeItemVisible(_selectedItemIndex);
    }

    protected bool _makeSelectionVisibleOnNextLayout;
    /// ensure item is visible
    void makeItemVisible(int itemIndex) {
        if (itemIndex < 0 || itemIndex >= itemCount)
            return; // no selection

        Rect viewrc = Rect(0, 0, _clientRc.width, _clientRc.height);
        Rect scrolledrc = itemRect(itemIndex);
        if (scrolledrc.isInsideOf(viewrc)) // completely visible
            return;
        int delta = 0;
        if (_orientation == Orientation.Vertical) {
            if (scrolledrc.top < viewrc.top)
                delta = scrolledrc.top - viewrc.top;
            else if (scrolledrc.bottom > viewrc.bottom)
                delta = scrolledrc.bottom - viewrc.bottom;
        } else {
            if (scrolledrc.left < viewrc.left)
                delta = scrolledrc.left - viewrc.left;
            else if (scrolledrc.right > viewrc.right)
                delta = scrolledrc.right - viewrc.right;
        }
        int newPosition = _scrollPosition + delta;
        _scrollbar.position = newPosition;
        _scrollPosition = newPosition;
        invalidate();
    }

    /// move selection
    bool moveSelection(int direction, bool wrapAround = true) {
        if (itemCount <= 0)
            return false;
        int maxAttempts = itemCount - 1;
        int index = _selectedItemIndex;
        for (int i = 0; i < maxAttempts; i++) {
            int newIndex = 0;
            if (index < 0) {
                // no previous selection
                if (direction > 0)
                    newIndex = wrapAround ? 0 : itemCount - 1;
                else
                    newIndex = wrapAround ? itemCount - 1 : 0;
            } else {
                // step
                newIndex = index + direction;
            }
            if (newIndex < 0)
                newIndex = wrapAround ? itemCount - 1 : 0;
            else if (newIndex >= itemCount)
                newIndex = wrapAround ? 0 : itemCount - 1;
            if (newIndex != index) {
                if (selectItem(newIndex)) {
                    selectionChanged(_selectedItemIndex, index);
                    return true;
                }
                index = newIndex;
            }
        }
        return true;
    }

	bool selectItem(int index, int disabledItemsSkipDirection) {
        debug Log.d("selectItem ", index, " skipDirection=", disabledItemsSkipDirection);
        if (index == -1 || disabledItemsSkipDirection == 0)
            return selectItem(index);
        int maxAttempts = itemCount;
        for (int i = 0; i < maxAttempts; i++) {
            if (selectItem(index))
                return true;
            index += disabledItemsSkipDirection > 0 ? 1 : -1;
            if (index < 0)
                index = itemCount - 1;
            if (index >= itemCount)
                index = 0;
        }
        return false;
    }

    /** Selected item index. */
    @property int selectedItemIndex() {
        return _selectedItemIndex;
    }

    @property void selectedItemIndex(int index) {
        selectItem(index);
    }

	bool selectItem(int index) {
        debug Log.d("selectItem ", index);
		if (_selectedItemIndex == index) {
            updateSelectedItemFocus();
            makeSelectionVisible();
            return true;
        }
        if (index != -1 && !itemEnabled(index))
            return false;
		if (_selectedItemIndex != -1) {
			_adapter.resetItemState(_selectedItemIndex, State.Selected | State.Focused);
			invalidate();
		}
		_selectedItemIndex = index;
		if (_selectedItemIndex != -1) {
            makeSelectionVisible();
			_adapter.setItemState(_selectedItemIndex, State.Selected | (state & State.Focused));
			invalidate();
		}
        return true;
	}

    ~this() {
        //Log.d("Destroying List ", _id);
        if (_adapter !is null && _ownAdapter)
            destroy(_adapter);
        _adapter = null;
    }

    /// handle scroll event
    override bool onScrollEvent(AbstractSlider source, ScrollEvent event) {
        int newPosition = _scrollPosition;
        if (event.action == ScrollAction.SliderMoved) {
            // scroll
            newPosition = event.position;
        } else {
            // use default handler for page/line up/down events
            newPosition = event.defaultUpdatePosition();
        }
        if (_scrollPosition != newPosition) {
            _scrollPosition = newPosition;
            if (_scrollPosition > _maxScrollPosition)
                _scrollPosition = _maxScrollPosition;
            if (_scrollPosition < 0)
                _scrollPosition = 0;
            invalidate();
        }
        return true;
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
        _sbsz.destroy();
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
        _needScrollbar = false;
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


    protected void updateItemPositions() {
        Rect r;
        int p = 0;
        for (int i = 0; i < itemCount; i++) {
            if (_itemSizes[i].x == 0 && _itemSizes[i].y == 0)
                continue;
            if (_orientation == Orientation.Vertical) {
                // Vertical
                int w = _clientRc.width;
                int h = _itemSizes[i].y;
                r.top = p;
                r.bottom = p + h;
                r.left = 0;
                r.right = w;
                _itemRects[i] = r;
                p += h;
            } else {
                // Horizontal
                int h = _clientRc.height;
                int w = _itemSizes[i].x;
                r.top = 0;
                r.bottom = h;
                r.left = p;
                r.right = p + w;
                _itemRects[i] = r;
                p += w;
            }
        }
        _totalSize = p;
        if (_needScrollbar) {
            if (_orientation == Orientation.Vertical) {
                _scrollbar.setRange(0, p);
                _scrollbar.pageSize = _clientRc.height;
                _scrollbar.position = _scrollPosition;
            } else {
                _scrollbar.setRange(0, p);
                _scrollbar.pageSize = _clientRc.width;
                _scrollbar.position = _scrollPosition;
            }
        }
        /// maximum scroll position
        if (_orientation == Orientation.Vertical) {
            _maxScrollPosition = _totalSize - _clientRc.height;
            if (_maxScrollPosition < 0)
                _maxScrollPosition = 0;
        } else {
            _maxScrollPosition = _totalSize - _clientRc.width;
            if (_maxScrollPosition < 0)
                _maxScrollPosition = 0;
        }
        if (_scrollPosition > _maxScrollPosition)
            _scrollPosition = _maxScrollPosition;
        if (_scrollPosition < 0)
            _scrollPosition = 0;
        if (_needScrollbar) {
            if (_orientation == Orientation.Vertical) {
                _scrollbar.position = _scrollPosition;
            } else {
                _scrollbar.position = _scrollPosition;
            }
        }
    }

    /// Set widget rectangle to specified value and layout widget contents. (Step 2 of two phase layout).
    override void layout(Rect rc) {
        _needLayout = false;
        if (visibility == Visibility.Gone) {
            return;
        }
        _pos = rc;

        Rect parentrc = rc;
        applyMargins(rc);
        applyPadding(rc);

        if (_itemRects.length < itemCount)
            _itemRects.length = itemCount;

        // measure again if client size has been changed
        if (_lastMeasureWidth != rc.width || _lastMeasureHeight != rc.height)
            measure(parentrc.width, parentrc.height);

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

        _clientRc = rc;

        // calc item rectangles
        updateItemPositions();

        if (_makeSelectionVisibleOnNextLayout) {
            makeSelectionVisible();
            _makeSelectionVisibleOnNextLayout = false;
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
		auto saver = ClipRectSaver(buf, rc, alpha);
		// draw scrollbar
        if (_needScrollbar)
            _scrollbar.onDraw(buf);

        Point scrollOffset;
        if (_orientation == Orientation.Vertical) {
            scrollOffset.y = _scrollPosition;
        } else {
            scrollOffset.x = _scrollPosition;
        }
        // draw items
        for (int i = 0; i < itemCount; i++) {
            Rect itemrc = _itemRects[i];
            itemrc.left += rc.left - scrollOffset.x;
            itemrc.right += rc.left - scrollOffset.x;
            itemrc.top += rc.top - scrollOffset.y;
            itemrc.bottom += rc.top - scrollOffset.y;
            if (itemrc.intersects(rc)) {
                Widget w = itemWidget(i);
                if (w is null || w.visibility != Visibility.Visible)
                    continue;
                w.measure(itemrc.width, itemrc.height);
                w.layout(itemrc);
			    w.onDraw(buf);
            }
		}
    }

    /// list navigation using keys
    override bool onKeyEvent(KeyEvent event) {
        if (itemCount == 0)
            return false;
        int navigationDelta = 0;
        if (event.action == KeyAction.KeyDown) {
            if (orientation == Orientation.Vertical) {
                if (event.keyCode == KeyCode.DOWN)
                    navigationDelta = 1;
                else if (event.keyCode == KeyCode.UP)
                    navigationDelta = -1;
            } else {
                if (event.keyCode == KeyCode.RIGHT)
                    navigationDelta = 1;
                else if (event.keyCode == KeyCode.LEFT)
                    navigationDelta = -1;
            }
        }
        if (navigationDelta != 0) {
            moveSelection(navigationDelta);
            return true;
        }
        if (event.action == KeyAction.KeyDown) {
            if (event.keyCode == KeyCode.HOME) {
                // select first enabled item on HOME key
                selectItem(0, 1);
                return true;
            } else if (event.keyCode == KeyCode.END) {
                // select last enabled item on END key
                selectItem(itemCount - 1, -1);
                return true;
            } else if (event.keyCode == KeyCode.PAGEDOWN) {
                // TODO
            } else if (event.keyCode == KeyCode.PAGEUP) {
                // TODO
            }
        }
        return false;
        //if (_selectedItemIndex != -1 && event.action == KeyAction.KeyUp && (event.keyCode == KeyCode.SPACE || event.keyCode == KeyCode.RETURN)) {
        //    itemClicked(_selectedItemIndex);
        //    return true;
        //}
        //if (navigationDelta != 0) {
        //    int p = _selectedItemIndex;
        //    if (p < 0) {
        //        if (navigationDelta < 0)
        //            p = itemCount - 1;
        //        else
        //            p = 0;
        //    } else {
        //        p += navigationDelta;
        //        if (p < 0)
        //            p = itemCount - 1;
        //        else if (p >= itemCount)
        //            p = 0;
        //    }
        //    setHoverItem(-1);
        //    selectItem(p);
        //    return true;
        //}
        //return false;
    }

    /// process mouse event; return true if event is processed by widget.
    override bool onMouseEvent(MouseEvent event) {
        //Log.d("onMouseEvent ", id, " ", event.action, "  (", event.x, ",", event.y, ")");
		if (event.action == MouseAction.Leave || event.action == MouseAction.Cancel) {
			setHoverItem(-1);
			return true;
		}
        // delegate processing of mouse wheel to scrollbar widget
        if (event.action == MouseAction.Wheel && _needScrollbar) {
            return _scrollbar.onMouseEvent(event);
        }
		// support onClick
        Rect rc = _pos;
        applyMargins(rc);
        applyPadding(rc);
        Point scrollOffset;
        if (_orientation == Orientation.Vertical) {
            scrollOffset.y = _scrollPosition;
        } else {
            scrollOffset.x = _scrollPosition;
        }
        if (event.action == MouseAction.ButtonDown && (event.flags & (MouseFlag.LButton || MouseFlag.RButton)))
            setFocus();
        for (int i = 0; i < itemCount; i++) {
            Rect itemrc = _itemRects[i];
            itemrc.left += rc.left - scrollOffset.x;
            itemrc.right += rc.left - scrollOffset.x;
            itemrc.top += rc.top - scrollOffset.y;
            itemrc.bottom += rc.top - scrollOffset.y;
            if (itemrc.isPointInside(Point(event.x, event.y))) {
				if ((event.flags & (MouseFlag.LButton || MouseFlag.RButton)) || _selectOnHover) {
					if (_selectedItemIndex != i && itemEnabled(i)) {
						int prevSelection = _selectedItemIndex;
						selectItem(i);
						setHoverItem(-1);
						selectionChanged(_selectedItemIndex, prevSelection);
					}
				} else {
                    if (itemEnabled(i))
					    setHoverItem(i);
                }
				if ((event.button == MouseFlag.LButton || event.button == MouseFlag.RButton)) {
					if ((_clickOnButtonDown && event.action == MouseAction.ButtonDown) || (!_clickOnButtonDown && event.action == MouseAction.ButtonUp)) {
                        if (itemEnabled(i)) {
						    itemClicked(i);
						    if (_clickOnButtonDown)
							    event.doNotTrackButtonDown = true;
                        }
					}
				}
				return true;
            }
		}
        return true;
    }

}

