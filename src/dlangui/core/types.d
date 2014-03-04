module dlangui.core.types;

public struct Point {
    int x;
    int y;
    public this(int x0, int y0) {
        x = x0;
        y = y0;
    }
}

public struct Rect {
    public int left;
    public int top;
    public int right;
    public int bottom;
    public @property int width() { return right - left; }
    public @property int height() { return bottom - top; }
    public this(int x0, int y0, int x1, int y1) {
        left = x0;
        top = y0;
        right = x1;
        bottom = y1;
    }
    public bool empty() {
        return right <= left || bottom <= top;
    }
    public bool intersect(Rect rc) {
        if (left < rc.left)
            left = rc.left;
        if (top < rc.top)
            top = rc.top;
        if (right > rc.right)
            right = rc.right;
        if (bottom > rc.bottom)
            bottom = rc.bottom;
        return right > left && bottom > top;
    }
}

public class RefCountedObject {
    protected int _refCount;
    public @property int refCount() { return _refCount; }
    public void addRef() { _refCount++; }
    public void releaseRef() { if (--_refCount == 0) destroy(this); }
    public ~this() {}
}

public struct Ref(T) { // if (T is RefCountedObject)
    T _data;
    alias _data this;
    public @property bool isNull() { return _data is null; }
    public @property int refCount() { return _data !is null ? _data.refCount : 0; }
    public this(T data) {
        _data = data;
        if (_data !is null)
            _data.addRef();
    }
    public void opAssign(Ref!T data) {
        if (data._data == _data)
            return;
        if (_data !is null)
            _data.releaseRef();
        _data = data._data;
        if (_data !is null)
            _data.addRef();
    }
    public void opAssign(T data) {
        if (data == _data)
            return;
        if (_data !is null)
            _data.releaseRef();
        _data = data;
        if (_data !is null)
            _data.addRef();
    }
    public void clear() { 
        if (_data !is null) {
            _data.releaseRef();
            _data = null;
        }
    }
	public @property T get() {
		return _data;
	}
    public ~this() {
        if (_data !is null)
            _data.releaseRef();
    }
}
