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
import dlangui.widgets.scrollbar;
import dlangui.widgets.layouts;
import dlangui.core.signals;


/** interface - slot for onAdapterChangeListener */
interface OnAdapterChangeHandler {
    void onAdapterChange(ListAdapter source);
}


/// list widget adapter provides items for list widgets
interface ListAdapter {
    /// returns number of widgets in list
    @property int itemCount() const;
    /// return list item widget by item index
    Widget itemWidget(int index);
    /// return list item's state flags
    uint itemState(int index) const;
    /// set one or more list item's state flags, returns updated state
    uint setItemState(int index, uint flags);
    /// reset one or more list item's state flags, returns updated state
    uint resetItemState(int index, uint flags);
    /// returns integer item id by index (if supported)
    int itemId(int index) const;
    /// returns string item id by index (if supported)
    string itemStringId(int index) const;

    /// remove all items
    void clear();

    /// connect adapter change handler
    ListAdapter connect(OnAdapterChangeHandler handler);
    /// disconnect adapter change handler
    ListAdapter disconnect(OnAdapterChangeHandler handler);

    /// called when theme is changed
    void onThemeChanged();

    /// return true to receive mouse events
    @property bool wantMouseEvents();
    /// return true to receive keyboard events
    @property bool wantKeyEvents();
}

/// List adapter for simple list of widget instances
class ListAdapterBase : ListAdapter {
    /** Handle items change */
    protected Signal!OnAdapterChangeHandler adapterChanged;

    /// connect adapter change handler
    override ListAdapter connect(OnAdapterChangeHandler handler) {
        adapterChanged.connect(handler);
        return this;
    }
    /// disconnect adapter change handler
    override ListAdapter disconnect(OnAdapterChangeHandler handler) {
        adapterChanged.disconnect(handler);
        return this;
    }
    /// returns integer item id by index (if supported)
    override int itemId(int index) const {
        return 0;
    }
    /// returns string item id by index (if supported)
    override string itemStringId(int index) const {
        return null;
    }

    /// returns number of widgets in list
    override @property int itemCount() const {
        // override it
        return 0;
    }

    /// return list item widget by item index
    override Widget itemWidget(int index) {
        // override it
        return null;
    }

    /// return list item's state flags
    override uint itemState(int index) const {
        // override it
        return State.Enabled;
    }
    /// set one or more list item's state flags, returns updated state
    override uint setItemState(int index, uint flags) {
        return 0;
    }
    /// reset one or more list item's state flags, returns updated state
    override uint resetItemState(int index, uint flags) {
        return 0;
    }

    /// remove all items
    override void clear() {
    }

    /// notify listeners about list items changes
    void updateViews() {
        if (adapterChanged.assigned)
            adapterChanged.emit(this);
    }

    /// called when theme is changed
    void onThemeChanged() {
    }

    /// return true to receive mouse events
    override @property bool wantMouseEvents() {
        return false;
    }

    /// return true to receive keyboard events
    override  @property bool wantKeyEvents() {
        return false;
    }
}

/// List adapter for simple list of widget instances
class WidgetListAdapter : ListAdapterBase {
    private WidgetList _widgets;
    /// list of widgets to display
    @property ref const(WidgetList) widgets() { return _widgets; }
    /// returns number of widgets in list
    @property override int itemCount() const {
        return _widgets.count;
    }
    /// return list item widget by item index
    override Widget itemWidget(int index) {
        return _widgets.get(index);
    }
    /// return list item's state flags
    override uint itemState(int index) const {
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
    /// add item
    WidgetListAdapter add(Widget item, int index = -1) {
        _widgets.insert(item, index);
        updateViews();
        return this;
    }
    /// remove item
    WidgetListAdapter remove(int index) {
        auto item = _widgets.remove(index);
        destroy(item);
        updateViews();
        return this;
    }
    /// remove all items
    override void clear() {
        _widgets.clear();
        updateViews();
    }
    /// called when theme is changed
    override void onThemeChanged() {
        super.onThemeChanged();
        foreach(w; _widgets)
            w.onThemeChanged();
    }
    ~this() {
        //Log.d("Destroying WidgetListAdapter");
    }

    /// return true to receive mouse events
    override @property bool wantMouseEvents() {
        return true;
    }
}

/** List adapter providing strings only. */
class StringListAdapterBase : ListAdapterBase {
    protected UIStringCollection _items;
    protected uint[] _states;
    protected int[] _intIds;
    protected string[] _stringIds;
    protected string[] _iconIds;
    protected int _lastItemIndex;

    /** create empty string list adapter. */
    this() {
        _lastItemIndex = -1;
    }

    /** Init with array of string resource IDs. */
    this(string[] items) {
        _items.addAll(items);
        _intIds.length = items.length;
        _stringIds.length = items.length;
        _iconIds.length = items.length;
        _lastItemIndex = -1;
        updateStatesLength();
    }

    /** Init with array of unicode strings. */
    this(dstring[] items) {
        _items.addAll(items);
        _intIds.length = items.length;
        _stringIds.length = items.length;
        _iconIds.length = items.length;
        _lastItemIndex = -1;
        updateStatesLength();
    }

    /** Init with array of StringListValue. */
    this(StringListValue[] items) {
        _intIds.length = items.length;
        _stringIds.length = items.length;
        _iconIds.length = items.length;
        for (int i = 0; i < items.length; i++) {
            _items.add(items[i].label);
            _intIds[i] = items[i].intId;
            _stringIds[i] = items[i].stringId;
            _iconIds[i] = items[i].iconId;
        }
        _lastItemIndex = -1;
        updateStatesLength();
    }

    /// remove all items
    override void clear() {
        _items.clear();
        updateStatesLength();
        updateViews();
    }

    /// remove item by index
    StringListAdapterBase remove(int index) {
        if (index < 0 || index >= _items.length)
            return this;
        for (int i = 0; i < _items.length - 1; i++) {
            _intIds[i] = _intIds[i + 1];
            _stringIds[i] = _stringIds[i + 1];
            _iconIds[i] = _iconIds[i + 1];
            _states[i] = _states[i + 1];
        }
        _items.remove(index);
        _intIds.length = items.length;
        _states.length = _items.length;
        _stringIds.length = items.length;
        _iconIds.length = items.length;
        updateViews();
        return this;
    }

    /// add new item
    StringListAdapterBase add(UIString item, int index = -1) {
        if (index < 0 || index > _items.length)
            index = _items.length;
        _items.add(item, index);
        _intIds.length = items.length;
        _states.length = _items.length;
        _stringIds.length = items.length;
        _iconIds.length = items.length;
        for (int i = _items.length - 1; i > index; i--) {
            _intIds[i] = _intIds[i - 1];
            _stringIds[i] = _stringIds[i - 1];
            _iconIds[i] = _iconIds[i - 1];
            _states[i] = _states[i - 1];
        }
        _intIds[index] = 0;
        _stringIds[index] = null;
        _iconIds[index] = null;
        _states[index] = State.Enabled;
        updateViews();
        return this;
    }
    /// add new string resource item
    StringListAdapterBase add(string item, int index = -1) {
        return add(UIString.fromId(item), index);
    }
    /// add new raw dstring item
    StringListAdapterBase add(dstring item, int index = -1) {
        return add(UIString.fromRaw(item), index);
    }

    /** Access to items collection. */
    @property ref const(UIStringCollection) items() { return _items; }

    /** Replace items collection. */
    @property StringListAdapterBase items(dstring[] values) {
        _items = values;
        _intIds.length = items.length;
        _states.length = _items.length;
        _stringIds.length = items.length;
        _iconIds.length = items.length;
        for (int i = 0; i < _items.length; i++) {
            _intIds[i] = 0;
            _stringIds[i] = null;
            _iconIds[i] = null;
            _states[i] = State.Enabled;
        }
        updateViews();
        return this;
    }

    /** Replace items collection. */
    @property StringListAdapterBase items(UIString[] values) {
        _items = values;
        _intIds.length = items.length;
        _states.length = _items.length;
        _stringIds.length = items.length;
        _iconIds.length = items.length;
        for (int i = 0; i < _items.length; i++) {
            _intIds[i] = 0;
            _stringIds[i] = null;
            _iconIds[i] = null;
            _states[i] = State.Enabled;
        }
        updateViews();
        return this;
    }

    /** Replace items collection. */
    @property StringListAdapterBase items(StringListValue[] values) {
        _items = values;
        _intIds.length = items.length;
        _states.length = _items.length;
        _stringIds.length = items.length;
        _iconIds.length = items.length;
        for (int i = 0; i < _items.length; i++) {
            _intIds[i] = values[i].intId;
            _stringIds[i] = values[i].stringId;
            _iconIds[i] = values[i].iconId;
            _states[i] = State.Enabled;
        }
        updateViews();
        return this;
    }

    /// returns number of widgets in list
    @property override int itemCount() const {
        return _items.length;
    }

    /// returns integer item id by index (if supported)
    override int itemId(int index) const {
        return index >= 0 && index < _intIds.length ? _intIds[index] : 0;
    }

    /// returns string item id by index (if supported)
    override string itemStringId(int index) const {
        return index >= 0 && index < _stringIds.length ? _stringIds[index] : null;
    }

    protected void updateStatesLength() {
        if (_states.length < _items.length) {
            int oldlen = cast(int)_states.length;
            _states.length = _items.length;
            for (int i = oldlen; i < _items.length; i++)
                _states[i] = State.Enabled;
        }
        if (_intIds.length < items.length)
            _intIds.length = items.length;
        if (_stringIds.length < items.length)
            _stringIds.length = items.length;
        if (_iconIds.length < items.length)
            _iconIds.length = items.length;
    }

    /// return list item's state flags
    override uint itemState(int index) const {
        if (index < 0 || index >= _items.length)
            return 0;
        return _states[index];
    }

    /// set one or more list item's state flags, returns updated state
    override uint setItemState(int index, uint flags) {
        updateStatesLength();
        _states[index] |= flags;
        return _states[index];
    }
    /// reset one or more list item's state flags, returns updated state
    override uint resetItemState(int index, uint flags) {
        updateStatesLength();
        _states[index] &= ~flags;
        return _states[index];
    }

    ~this() {
    }
}

/** List adapter providing strings only. */
class StringListAdapter : StringListAdapterBase {
    protected TextWidget _widget;

    /** create empty string list adapter. */
    this() {
        super();
    }

    /** Init with array of string resource IDs. */
    this(string[] items) {
        super(items);
    }

    /** Init with array of unicode strings. */
    this(dstring[] items) {
        super(items);
    }

    /** Init with array of StringListValue. */
    this(StringListValue[] items) {
        super(items);
    }

    /// return list item widget by item index
    override Widget itemWidget(int index) {
        updateStatesLength();
        if (_widget is null) {
            _widget = new TextWidget("STRING_LIST_ITEM");
            _widget.styleId = STYLE_LIST_ITEM;
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

    /// called when theme is changed
    override void onThemeChanged() {
        super.onThemeChanged();
        if (_widget)
            _widget.onThemeChanged();
    }

    /// set one or more list item's state flags, returns updated state
    override uint setItemState(int index, uint flags) {
        uint res = super.setItemState(index, flags);
        if (_widget !is null && _lastItemIndex == index)
            _widget.state = res;
        return res;
    }



    /// reset one or more list item's state flags, returns updated state
    override uint resetItemState(int index, uint flags) {
        uint res = super.resetItemState(index, flags);
        if (_widget !is null && _lastItemIndex == index)
            _widget.state = res;
        return res;
    }

    ~this() {
        if (_widget)
            destroy(_widget);
    }
}

/** List adapter providing strings with icons. */
class IconStringListAdapter : StringListAdapterBase {
    protected HorizontalLayout _widget;
    protected TextWidget _textWidget;
    protected ImageWidget _iconWidget;

    /** create empty string list adapter. */
    this() {
        super();
    }

    /** Init with array of StringListValue. */
    this(StringListValue[] items) {
        super(items);
    }

    /// return list item widget by item index
    override Widget itemWidget(int index) {
        updateStatesLength();
        if (_widget is null) {
            _widget = new HorizontalLayout("ICON_STRING_LIST_ITEM");
            _widget.styleId = STYLE_LIST_ITEM;
            _textWidget = new TextWidget("label");
            _iconWidget = new ImageWidget("icon");
            _widget.addChild(_iconWidget);
            _widget.addChild(_textWidget);
        } else {
            if (index == _lastItemIndex)
                return _widget;
        }
        // update widget
        _textWidget.text = _items.get(index);
        _textWidget.state = _states[index];
        if (_iconIds[index]) {
            _iconWidget.visibility = Visibility.Visible;
            _iconWidget.drawableId = _iconIds[index];
        } else {
            _iconWidget.visibility = Visibility.Gone;
        }
        _lastItemIndex = index;
        return _widget;
    }

    /// called when theme is changed
    override void onThemeChanged() {
        super.onThemeChanged();
        if (_widget)
            _widget.onThemeChanged();
    }

    /// set one or more list item's state flags, returns updated state
    override uint setItemState(int index, uint flags) {
        uint res = super.setItemState(index, flags);
        if (_widget !is null && _lastItemIndex == index) {
            _widget.state = res;
            _textWidget.state = res;
        }
        return res;
    }

    /// reset one or more list item's state flags, returns updated state
    override uint resetItemState(int index, uint flags) {
        uint res = super.resetItemState(index, flags);
        if (_widget !is null && _lastItemIndex == index) {
            _widget.state = res;
            _textWidget.state = res;
        }
        return res;
    }

    ~this() {
        if (_widget)
            destroy(_widget);
    }
}

/** interface - slot for onItemSelectedListener */
interface OnItemSelectedHandler {
    bool onItemSelected(Widget source, int itemIndex);
}

/** interface - slot for onItemClickListener */
interface OnItemClickHandler {
    bool onItemClick(Widget source, int itemIndex);
}


/** List widget - shows content as hori*/
class ListWidget : WidgetGroup, OnScrollHandler, OnAdapterChangeHandler {

    /** Handle selection change. */
    Signal!OnItemSelectedHandler itemSelected;
    /** Handle item click / activation (e.g. Space or Enter key press and mouse double click) */
    Signal!OnItemClickHandler itemClick;

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
        if (_adapter is adapter)
            return this; // no changes
        if (_adapter)
            _adapter.disconnect(this);
        if (_adapter !is null && _ownAdapter)
            destroy(_adapter);
        _adapter = adapter;
        if (_adapter)
            _adapter.connect(this);
        _ownAdapter = false;
        onAdapterChange(_adapter);
        return this;
    }
    /// set adapter, which will be owned by list (destroy will be called for adapter on widget destroy)
    @property ListWidget ownAdapter(ListAdapter adapter) {
        if (_adapter is adapter)
            return this; // no changes
        if (_adapter)
            _adapter.disconnect(this);
        if (_adapter !is null && _ownAdapter)
            destroy(_adapter);
        _adapter = adapter;
        if (_adapter)
            _adapter.connect(this);
        _ownAdapter = true;
        onAdapterChange(_adapter);
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

    /// empty parameter list constructor - for usage by factory
    this() {
        this(null);
    }
    /// create with ID parameter
    this(string ID, Orientation orientation = Orientation.Vertical) {
        super(ID);
        _orientation = orientation;
        focusable = true;
        _hoverItemIndex = -1;
        _selectedItemIndex = -1;
        _scrollbar = new ScrollBar("listscroll", orientation);
        _scrollbar.visibility = Visibility.Gone;
        _scrollbar.scrollEvent = &onScrollEvent;
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

    /// item list is changed
    override void onAdapterChange(ListAdapter source) {
        requestLayout();
    }

    /// override to handle change of selection
    protected void selectionChanged(int index, int previouslySelectedItem = -1) {
        if (itemSelected.assigned)
            itemSelected(this, index);
    }

    /// override to handle mouse up on item
    protected void itemClicked(int index) {
        if (itemClick.assigned)
            itemClick(this, index);
    }

    /// allow to override state for updating of items
    // currently used to treat main menu items with opened submenu as focused
    @property protected uint overrideStateForItem() {
        return state;
    }

    protected void updateSelectedItemFocus() {
        if (_selectedItemIndex != -1) {
            if ((_adapter.itemState(_selectedItemIndex) & State.Focused) != (overrideStateForItem & State.Focused)) {
                if (overrideStateForItem & State.Focused)
                    _adapter.setItemState(_selectedItemIndex, State.Focused);
                else
                    _adapter.resetItemState(_selectedItemIndex, State.Focused);
                invalidate();
            }
        }
    }

    /// override to handle focus changes
    override protected void handleFocusChange(bool focused, bool receivedFocusFromKeyboard = false) {
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
        //debug Log.d("selectItem ", index, " skipDirection=", disabledItemsSkipDirection);
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
        //debug Log.d("selectItem ", index);
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
            _adapter.setItemState(_selectedItemIndex, State.Selected | (overrideStateForItem & State.Focused));
            invalidate();
        }
        return true;
    }

    ~this() {
        if (_adapter)
            _adapter.disconnect(this);
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

    /// handle theme change: e.g. reload some themed resources
    override void onThemeChanged() {
        super.onThemeChanged();
        _scrollbar.onThemeChanged();
        for (int i = 0; i < itemCount; i++) {
            Widget w = itemWidget(i);
            w.onThemeChanged();
        }
        if (_adapter)
            _adapter.onThemeChanged();
    }

    /// sets minimum size for the list, override to change
    Point minimumVisibleContentSize() {
        if (_orientation == Orientation.Vertical)
            return Point(measureMinChildrenSize().x, 100);
        else
            return Point(100, measureMinChildrenSize().y);
    }

    protected Point measureMinChildrenSize() {
        // measure children
        Point sz;
        for (int i = 0; i < itemCount; i++) {
            Widget w = itemWidget(i);
            if (w is null || w.visibility == Visibility.Gone)
                continue;

            w.measure(SIZE_UNSPECIFIED, SIZE_UNSPECIFIED);
            if (_orientation == Orientation.Vertical) {
                // Vertical
                if (sz.x < w.measuredWidth)
                    sz.x = w.measuredWidth;
                sz.y += w.measuredHeight;
            } else {
                // Horizontal
                if (sz.y < w.measuredHeight)
                    sz.y = w.measuredHeight;
                sz.x += w.measuredWidth;
            }
        }
        return sz;
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

        // set widget area to small when first measure
        if (parentWidth == SIZE_UNSPECIFIED && parentHeight == SIZE_UNSPECIFIED)
        {
            Point sz = minimumVisibleContentSize;
            measuredContent(parentWidth, parentHeight, sz.x, sz.y);
            return;
        }

        // calc size constraints for children
        int pwidth = parentWidth;
        int pheight = parentHeight;
        if (parentWidth != SIZE_UNSPECIFIED)
            pwidth -= m.left + m.right + p.left + p.right;
        if (parentHeight != SIZE_UNSPECIFIED)
            pheight -= m.top + m.bottom + p.top + p.bottom;

        bool oldNeedLayout = _needLayout;
        Visibility oldScrollbarVisibility = _scrollbar.visibility;

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

        if (_scrollbar.visibility == oldScrollbarVisibility) {
            _needLayout = oldNeedLayout;
            _scrollbar.cancelLayout();
        }
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
            if (_orientation == Orientation.Vertical) { // FIXME:
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

        // hide scrollbar or update rc for scrollbar
        Rect sbrect = rc;
        // layout scrollbar
        if (_needScrollbar) {
            rc.right -= _sbsz.x;
            rc.bottom -= _sbsz.y;
        } else {
            _scrollbar.visibility = Visibility.Gone;
        }

        _clientRc = rc;

        // calc item rectangles
        updateItemPositions();

        // layout scrollbar - must be under updateItemPositions()
        if (_needScrollbar) {
            _scrollbar.visibility = Visibility.Visible;
            if (_orientation == Orientation.Vertical)
                sbrect.left = sbrect.right - _sbsz.x;
            else
                sbrect.top = sbrect.bottom - _sbsz.y;
            _scrollbar.layout(sbrect);
        }

        if (_makeSelectionVisibleOnNextLayout) {
            makeSelectionVisible();
            _makeSelectionVisibleOnNextLayout = false;
        }
        _needLayout = false;
        _scrollbar.cancelLayout();
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
        if ((event.keyCode == KeyCode.SPACE || event.keyCode == KeyCode.RETURN)) {
            if (event.action == KeyAction.KeyDown && enabled) {
                if (itemEnabled(_selectedItemIndex)) {
                    itemClicked(_selectedItemIndex);
                }
            }
            return true;
        }
        return super.onKeyEvent(event);
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
        if (event.action == MouseAction.Wheel) {
            if (_scrollbar)
                _scrollbar.sendScrollEvent(event.wheelDelta > 0 ? ScrollAction.LineUp : ScrollAction.LineDown);
            return true;
        }
        if (event.action == MouseAction.ButtonDown && (event.flags & (MouseFlag.LButton || MouseFlag.RButton)))
            setFocus();
        if (itemCount > _itemRects.length)
            return true; // layout not yet called
        for (int i = 0; i < itemCount; i++) {
            Rect itemrc = _itemRects[i];
            itemrc.left += rc.left - scrollOffset.x;
            itemrc.right += rc.left - scrollOffset.x;
            itemrc.top += rc.top - scrollOffset.y;
            itemrc.bottom += rc.top - scrollOffset.y;
            if (itemrc.isPointInside(Point(event.x, event.y))) {
                if (_adapter && _adapter.wantMouseEvents) {
                    auto itemWidget = _adapter.itemWidget(i);
                    if (itemWidget) {
                        Widget oldParent = itemWidget.parent;
                        itemWidget.parent = this;
                        if (event.action == MouseAction.Move && event.noModifiers && itemWidget.hasTooltip) {
                            itemWidget.scheduleTooltip(200);
                        }
                        //itemWidget.onMouseEvent(event);
                        itemWidget.parent = oldParent;
                    }
                }
                //Log.d("mouse event action=", event.action, " button=", event.button, " flags=", event.flags);
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
                if (event.button == MouseButton.Left || event.button == MouseButton.Right) {
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
    /// returns true if item is child of this widget (when deepSearch == true - returns true if item is this widget or one of children inside children tree).
    override bool isChild(Widget item, bool deepSearch = true) {
        if (_adapter && _adapter.wantMouseEvents) {
            for (int i = 0; i < itemCount; i++) {
                auto itemWidget = _adapter.itemWidget(i);
                if (itemWidget is item)
                    return true;
            }
        }
        return super.isChild(item, deepSearch);
    }
}

class StringListWidget : ListWidget {
    import std.conv : to;
    import std.datetime.stopwatch : StopWatch;
    import core.time : dur;
    private dstring _searchString;
    private StopWatch _stopWatch;

    this(string ID = null) {
        super(ID);
        styleId = STYLE_EDIT_BOX;
    }

    this(string ID, string[] items) {
        super(ID);
        styleId = STYLE_EDIT_BOX;
        ownAdapter = new StringListAdapter(items);
    }

    this(string ID, dstring[] items) {
        super(ID);
        styleId = STYLE_EDIT_BOX;
        ownAdapter = new StringListAdapter(items);
    }

    this(string ID, StringListValue[] items) {
        super(ID);
        styleId = STYLE_EDIT_BOX;
        ownAdapter = new StringListAdapter(items);
    }

    @property void items(string[] itemResourceIds) {
        _selectedItemIndex = -1;
        ownAdapter = new StringListAdapter(itemResourceIds);
        if(itemResourceIds.length > 0) {
            selectedItemIndex = 0;
        }
        requestLayout();
    }

    @property void items(dstring[] items) {
        _selectedItemIndex = -1;
        ownAdapter = new StringListAdapter(items);
        if(items.length > 0) {
            selectedItemIndex = 0;
        }
        requestLayout();
    }

    @property void items(StringListValue[] items) {
        _selectedItemIndex = -1;
        ownAdapter = new StringListAdapter(items);
        if(items.length > 0) {
            selectedItemIndex = 0;
        }
        requestLayout();
    }

    /// StringListValue list values
    override bool setStringListValueListProperty(string propName, StringListValue[] values) {
        if (propName == "items") {
            items = values;
            return true;
        }
        return false;
    }

    /// get selected item as text
    @property dstring selectedItem() {
        if (_selectedItemIndex < 0 || _selectedItemIndex >= _adapter.itemCount)
            return "";
        return (cast(StringListAdapter)adapter).items.get(_selectedItemIndex);
    }

    override bool onKeyEvent(KeyEvent event) {
        if (itemCount == 0) return false;

        // Accept user input and try to find a match in the list.
        if (event.action == KeyAction.Text) {
            if ( !_stopWatch.running) { _stopWatch.start; }

            version(DigitalMars) {
                auto timePassed = _stopWatch.peek; //.to!("seconds", float)(); // dtop is std.datetime.to

                if (timePassed > dur!"msecs"(500)) _searchString = ""d;
            } else {
                auto timePassed = _stopWatch.peek.dto!("seconds", float)(); // dtop is std.datetime.to

                if (timePassed > 0.5) _searchString = ""d;
            }
            _searchString ~= to!dchar(event.text.toUTF8);
            _stopWatch.reset;

            if ( selectClosestMatch(_searchString) ) {
                invalidate();
                return true;
            }
        }

        return super.onKeyEvent(event);
    }


    private bool selectClosestMatch(dstring term) {
        import std.uni : toLower;
        if (term.length == 0) return false;
        auto myItems = (cast(StringListAdapter)adapter).items;

        // Perfect match or best match
        int[] indexes;
        foreach(int itemIndex; 0 .. myItems.length) {
            dstring item = myItems.get(itemIndex);

            if (item == term) {
                // Perfect match
                indexes ~= itemIndex;
                break;
            } else {
                // Term approximate to something
                bool addItem = true;
                foreach(int termIndex; 0 .. cast(int)term.length) {
                    if (termIndex < item.length) {
                        if ( toLower(term[termIndex]) != toLower(item[termIndex]) ) {
                            addItem = false;
                            break;
                        }
                    }
                }

                if (addItem) { indexes ~= itemIndex; }

            }
        }

        // Return best match
        if (indexes.length > 0) {
            selectItem(indexes[0]);
            itemSelected(this, indexes[0]);
            return true;
        }

        return false; // Did not find term

    }



}

//import dlangui.widgets.metadata;
//mixin(registerWidgets!(ListWidget, StringListWidget)());
