// Written in the D programming language.

/**

This module implements object collection.

Wrapper around array of objects, providing a set of useful operations, and handling of object ownership.

Optionally can be owner of its items if instanciated with ownItems=true - will destroy removed items.


Synopsis:

----
import dlangui.core.collections;

// add
Collection!Widget widgets;
widgets ~= new Widget("id1");
widgets ~= new Widget("id2");
Widget w3 = new Widget("id3");
widgets ~= w3;

// remove by index
widgets.remove(1);

// foreach
foreach(w; widgets)
    writeln("widget: ", w.id);

// remove by value
widgets -= w3;
writeln(widgets[0].id);
----


Copyright: Vadim Lopatin, 2014
License:   Boost License 1.0
Authors:   Vadim Lopatin, coolreader.org@gmail.com
*/
module dlangui.core.collections;

import std.algorithm;

/** 
    Array based collection of items.

    Retains item order when during add/remove operations.

    Optionally destroys removed objects when instanciated with ownItems = true.
*/
struct Collection(T, bool ownItems = false) {
    private T[] _items;
    private size_t _len;
    /// returns true if there are no items in collection
    @property bool empty() { return _len == 0; }
    /// returns number of items in collection
    @property size_t length() { return _len; }
    /// returns currently allocated capacity (may be more than length)
    @property size_t size() { return _items.length; }
    /// change capacity (e.g. to reserve big space to avoid multiple reallocations)
    @property void size(size_t newSize) {
        if (_len > newSize)
            length = newSize; // shrink
        _items.length = newSize; 
    }
    /// returns number of items in collection
    @property void length(size_t newSize) { 
        if (newSize < _len) {
            // shrink
            static if (is(T == class) || is(T == struct)) {
                // clear items
                for (size_t i = newSize; i < _len; i++) {
                    static if (ownItems)
                        destroy(_items[i]);
                    _items[i] = T.init;
                }
            }
        } else if (newSize > _len) {
            // expand
            if (_items.length < newSize)
                _items.length = newSize;
        }
        _len = newSize;
    }
    /// access item by index
    ref T opIndex(size_t index) {
        assert(index < _len);
        return _items[index];
    }
    /// insert new item in specified position
    void add(T item, size_t index = size_t.max) {
        if (index > _len)
            index = _len;
        if (_items.length <= _len) {
            if (_items.length < 4)
                _items.length = 4;
            else
                _items.length = _items.length * 2;
        }
        if (index < _len) {
            for (size_t i = _len; i > index; i--)
                _items[i] = _items[i - 1];
        }
        _items[index] = item;
        _len++;
    }
    /// add all items from other collection
    void addAll(ref Collection!(T, ownItems) v) {
        for (int i = 0; i < v.length; i++)
            add(v[i]);
    }
    /// support for appending (~=, +=) and removing by value (-=)
    ref Collection opOpAssign(string op)(T item) {
        static if (op.equal("~") || op.equal("+")) {
            // append item to end of collection
            add(item);
            return this;
        } else if (op.equal("-")) {
            // remove item from collection, if present
            removeValue(item);
            return this;
        } else {
            assert(false, "not supported opOpAssign " ~ op);
        }
    }
    /// returns index of first occurence of item, size_t.max if not found
    size_t indexOf(T item) {
        for (size_t i = 0; i < _len; i++)
            if (_items[i] == item)
                return i;
        return size_t.max;
    }
    /// remove single item, returning removed item
    T remove(size_t index) {
        assert(index < _len);
        T result = _items[index];
        for (size_t i = index; i + 1 < _len; i++)
            _items[i] = _items[i + 1];
        _len--;
        _items[_len] = T.init;
        return result;
    }
    /// remove single item by value - if present in collection, returning true if item was found and removed
    bool removeValue(T value) {
        size_t index = indexOf(value);
        if (index == size_t.max)
            return false;
        T res = remove(index);
        static if (ownItems)
            destroy(res);
        return true;
    }
    /// support of foreach with reference
    int opApply(int delegate(ref T param) op) {
        int result = 0;
        for (size_t i = 0; i < _len; i++) {
            result = op(_items[i]);
            if (result)
                break;
        }
        return result;
    }
    /// remove all items
    void clear() {
        static if (is(T == class) || is(T == struct)) {
            /// clear references
            for(size_t i = 0; i < _len; i++) {
                static if (ownItems)
                    destroy(_items[i]);
                _items[i] = T.init;
            }
        }
        _len = 0;
        _items = null;
    }

    //===================================
    // stack/queue-like ops

    /// remove first item
    @property T popFront() {
        if (empty)
            return T.init; // no items
        return remove(0);
    }

    /// peek first item
    @property T peekFront() {
        if (empty)
            return T.init; // no items
        return _items[0];
    }

    /// insert item at beginning of collection
    void pushFront(T item) {
        add(item, 0);
    }

    /// remove last item
    @property T popBack() {
        if (empty)
            return T.init; // no items
        return remove(length - 1);
    }

    /// peek last item
    @property T peekBack() {
        if (empty)
            return T.init; // no items
        return _items[length - 1];
    }

    /// insert item at end of collection
    void pushBack(T item) {
        add(item);
    }

    /// peek first item
    @property T front() {
        if (empty)
            return T.init; // no items
        return _items[0];
    }

    /// peek last item
    @property T back() {
        if (empty)
            return T.init; // no items
        return _items[_len - 1];
    }
    /// removes all items on destroy
    ~this() {
        clear();
    }
}


/** object list holder, owning its objects - on destroy of holder, all own objects will be destroyed */
struct ObjectList(T) {
    protected T[] _list;
    protected int _count;
    /** returns count of items */
    @property int count() const { return _count; }
    alias length = count;
    /** get item by index */
    inout(T) get(int index) inout {
        assert(index >= 0 && index < _count, "child index out of range");
        return _list[index];
    }
    /// get item by index
    T opIndex(int index) {
        return get(index);
    }
    /** add item to list */
    T add(T item) {
        if (_list.length <= _count) // resize
            _list.length = _list.length < 4 ? 4 : _list.length * 2;
        _list[_count++] = item;
        return item;
    }
    /** add item to list */
    T insert(T item, int index = -1) {
        if (index > _count || index < 0)
            index = _count;
        if (_list.length <= _count) // resize
            _list.length = _list.length < 4 ? 4 : _list.length * 2;
        for (int i = _count; i > index; i--)
            _list[i] = _list[i - 1];
        _list[index] = item;
        _count++;
        return item;
    }
    /** find child index for item, return -1 if not found */
    int indexOf(T item) {
        if (item is null)
            return -1;
        for (int i = 0; i < _count; i++)
            if (_list[i] is item)
                return i;
        return -1;
    }
    /** find child index for item by id, return -1 if not found */
    static if (__traits(hasMember, T, "compareId")) {
        int indexOf(string id) {
            for (int i = 0; i < _count; i++)
                if (_list[i].compareId(id))
                    return i;
            return -1;
        }
    }
    /** remove item from list, return removed item */
    T remove(int index) {
        assert(index >= 0 && index < _count, "child index out of range");
        T item = _list[index];
        for (int i = index; i < _count - 1; i++)
            _list[i] = _list[i + 1];
        _count--;
        return item;
    }
    /** Replace item with another value, destroy old value. */
    void replace(T item, int index) {
        T old = _list[index];
        _list[index] = item;
        destroy(old);
    }
    /** Replace item with another value, destroy old value. */
    void replace(T newItem, T oldItem) {
        int idx = indexOf(oldItem);
        if (newItem is null) {
            if (idx >= 0) {
                T item = remove(idx);
                destroy(item);
            }
        } else {
            if (idx >= 0)
                replace(newItem, idx);
            else
                add(newItem);
        }
    }
    /** remove and destroy all items */
    void clear(bool destroyObj = true) {
        for (int i = 0; i < _count; i++) {
            if(destroyObj) {
                destroy(_list[i]);
            }
            _list[i] = null;
        }
        _count = 0;
    }
    /// Support foreach
    int opApply(int delegate(ref T) callback) {
        int res = 0;
        for(int i = 0; i < _count; i++) {
            res = callback(_list[i]);
            if (res)
                break;
        }
        return res;
    }
    /// Get items array slice. Don't try to resize it!
    T[] asArray() {
        if (!_count)
            return null;
        return _list[0.._count];
    }
    /// destructor destroys all items
    ~this() {
        clear();
    }
}

