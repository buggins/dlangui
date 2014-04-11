module dlangui.core.types;

import std.algorithm;

struct Point {
    int x;
    int y;
    this(int x0, int y0) {
        x = x0;
        y = y0;
    }
}

struct Rect {
    int left;
    int top;
    int right;
    int bottom;
    @property int middlex() { return (left + right) / 2; }
    @property int middley() { return (top + bottom) / 2; }
    void offset(int dx, int dy) {
        left += dx;
        right += dx;
        top += dy;
        bottom += dy;
    }
    @property int width() { return right - left; }
    @property int height() { return bottom - top; }
    this(int x0, int y0, int x1, int y1) {
        left = x0;
        top = y0;
        right = x1;
        bottom = y1;
    }
    @property bool empty() {
        return right <= left || bottom <= top;
    }
    /// updates this rect to intersection with rc, returns true if result is non empty
    bool intersect(Rect rc) {
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
    /// returns true if this rect has nonempty intersection with rc
    bool intersects(Rect rc) {
        if (rc.left >= right || rc.top >= bottom || rc.right <= left || rc.bottom <= top)
            return false;
        return true;
    }
    /// returns true if point is inside of this rectangle
    bool isPointInside(Point pt) {
        return pt.x >= left && pt.x < right && pt.y >= top && pt.y < bottom;
    }
    /// returns true if point is inside of this rectangle
    bool isPointInside(int x, int y) {
        return x >= left && x < right && y >= top && y < bottom;
    }
}

/// character glyph
align(1)
struct Glyph
{
    version (USE_OPENGL) {
        ///< 0: unique id of glyph (for drawing in hardware accelerated scenes)
        uint    id;
    }
    ///< 4: width of glyph black box
    ubyte   blackBoxX;
    ///< 5: height of glyph black box
    ubyte   blackBoxY;
    ///< 6: X origin for glyph
    byte    originX;
    ///< 7: Y origin for glyph
    byte    originY;
    ///< 8: bytes in glyph array
    ushort  glyphIndex;
    ///< 10: full width of glyph
    ubyte   width;
    ///< 11: usage flag, to handle cleanup of unused glyphs
	ubyte   lastUsage;
    ///< 12: glyph data, arbitrary size
    ubyte[] glyph;       
}

class RefCountedObject {
    protected int _refCount;
    @property int refCount() const { return _refCount; }
    void addRef() { 
		_refCount++; 
	}
    void releaseRef() { 
		if (--_refCount == 0) 
			destroy(this); 
	}
    ~this() {}
}

struct Ref(T) { // if (T is RefCountedObject)
    private T _data;
    alias get this;
    @property bool isNull() const { return _data is null; }
    @property int refCount() const { return _data !is null ? _data.refCount : 0; }
    this(T data) {
        _data = data;
        if (_data !is null)
            _data.addRef();
    }
	this(this) {
		if (_data !is null)
            _data.addRef();
	}
    ref Ref opAssign(ref Ref data) {
        if (data._data == _data)
            return this;
        if (_data !is null)
            _data.releaseRef();
        _data = data._data;
        if (_data !is null)
            _data.addRef();
		return this;
    }
    ref Ref opAssign(Ref data) {
        if (data._data == _data)
            return this;
        if (_data !is null)
            _data.releaseRef();
        _data = data._data;
        if (_data !is null)
            _data.addRef();
		return this;
    }
    ref Ref opAssign(T data) {
        if (data == _data)
            return this;
        if (_data !is null)
            _data.releaseRef();
        _data = data;
        if (_data !is null)
            _data.addRef();
		return this;
    }
    void clear() { 
        if (_data !is null) {
            _data.releaseRef();
            _data = null;
        }
    }
	@property T get() {
		return _data;
	}
	@property const(T) get() const {
		return _data;
	}
    ~this() {
        if (_data !is null)
            _data.releaseRef();
    }
}


// some utility functions
string fromStringz(const(char[]) s) {
    if (s is null)
        return null;
	int i = 0;
	while(s[i])
		i++;
	return cast(string)(s[0..i].dup);
}

string fromStringz(const(char*) s) {
    if (s is null)
        return null;
	int i = 0;
	while(s[i])
		i++;
	return cast(string)(s[0..i].dup);
}

wstring fromWStringz(const(wchar[]) s) {
    if (s is null)
        return null;
	int i = 0;
	while(s[i])
		i++;
	return cast(wstring)(s[0..i].dup);
}


/// widget state flags - bits
enum State : uint {
    /// state not specified / normal
    Normal = 0,
    Pressed = 1,
    Focused = 2,
    Enabled = 4,
    Hovered = 8, // mouse pointer is over control, buttons not pressed
    Selected = 16,
    Checkable = 32,
    Checked = 64,
    Activated = 128,
    WindowFocused = 256,
    Parent = 0x10000, // use parent's state
}

