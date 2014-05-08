// Written in the D programming language.

/**
DLANGUI library.

This module declares basic data types for usage in dlangui library.

Synopsis:

----
import dlangui.core.types;

// points 
Point p(5, 10);

// rectangles
Rect r(5, 13, 120, 200);
writeln(r);

// reference counted objects, useful for RAII / resource management.
class Foo : RefCountedObject {
	int[] resource;
	~this() {
		writeln("freeing Foo resources");
	}
}
{
	Ref!Foo ref1;
	{
		Ref!Foo fooRef = new RefCountedObject();
		ref1 = fooRef;
	}
	// RAII: will destroy object when no more references
}

----

Copyright: Vadim Lopatin, 2014
License:   $(WEB boost.org/LICENSE_1_0.txt, Boost License 1.0).
Authors:   $(WEB coolreader.org, Vadim Lopatin)
*/
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
    /// for all fields, sets this.field to rc.field if rc.field > this.field
    void setMax(Rect rc) {
        if (left < rc.left)
            left = rc.left;
        if (right < rc.right)
            right = rc.right;
        if (top < rc.top)
            top = rc.top;
        if (bottom < rc.bottom)
            bottom = rc.bottom;
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
    void moveBy(int deltax, int deltay) {
        left += deltax;
        right += deltax;
        top += deltay;
        bottom += deltay;
    }
    /// moves this rect to fit rc bounds, retaining the same size
    void moveToFit(ref Rect rc) {
        if (right > rc.right)
            moveBy(rc.right - right, 0);
        if (bottom > rc.bottom)
            moveBy(0, rc.bottom - bottom);
        if (left < rc.left)
            moveBy(rc.left - left, 0);
        if (top < rc.top)
            moveBy(0, rc.top - top);

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
    /// this rectangle is completely inside rc
    bool isInsideOf(Rect rc) {
        return left >= rc.left && right <= rc.right && top >= rc.top && bottom <= rc.bottom;
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

    ///< 8: full width of glyph
    ubyte   width;
    ///< 9: usage flag, to handle cleanup of unused glyphs
	ubyte   lastUsage;
    ///< 12: glyph data, arbitrary size
    ubyte[] glyph;       
}

/// base class for reference counted objects, maintains reference counter inplace.
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

wstring fromWStringz(const(wchar) * s) {
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
    Normal = 4, // Normal is Enabled
    Pressed = 1,
    Focused = 2,
    Enabled = 4,
    Hovered = 8, // mouse pointer is over control, buttons not pressed
    Selected = 16,
    Checkable = 32,
    Checked = 64,
    Activated = 128,
    WindowFocused = 256,
    Default = 512, // widget is default for form (e.g. default button will be focused on show)
    Parent = 0x10000, // use parent's state
}

/// uppercase unicode character
dchar dcharToUpper(dchar ch) {
	// TODO: support non-ascii letters
	if (ch >= 'a' && ch <= 'z')
		return ch - 'a' + 'A';
	return ch;
}

version (Windows) {
    immutable char PATH_DELIMITER = '\\';
} else {
    immutable char PATH_DELIMITER = '/';
}

/// returns true if char ch is / or \ slash
bool isPathDelimiter(char ch) {
    return ch == '/' || ch == '\\';
}

/// returns current executable path only, including last path delimiter
@property string exePath() {
    import std.file;
    string path = thisExePath();
    int lastSlash = 0;
    for (int i = 0; i < path.length; i++)
        if (path[i] == PATH_DELIMITER)
            lastSlash = i;
    return path[0 .. lastSlash + 1];
}

/// converts path delimiters to standard for platform inplace in buffer(e.g. / to \ on windows, \ to / on posix), returns buf
char[] convertPathDelimiters(char[] buf) {
    foreach(ref ch; buf) {
        version (Windows) {
            if (ch == '/')
                ch = '\\';
        } else {
            if (ch == '\\')
                ch = '/';
        }
    }
    return buf;
}

/// converts path delimiters to standard for platform (e.g. / to \ on windows, \ to / on posix)
string convertPathDelimiters(string src) {
    char[] buf = src.dup;
    return cast(string)convertPathDelimiters(buf);
}

/// appends file path parts with proper delimiters e.g. appendPath("/home/user", ".myapp", "config") => "/home/user/.myapp/config"
string appendPath(string[] pathItems ...) {
    char[] buf;
    foreach (s; pathItems) {
        if (buf.length && !isPathDelimiter(buf[$-1]))
            buf ~= PATH_DELIMITER;
        buf ~= s;
    }
    return convertPathDelimiters(buf).dup;
}

/// appends file path parts with proper delimiters (as well converts delimiters inside path to system) to buffer e.g. appendPath("/home/user", ".myapp", "config") => "/home/user/.myapp/config"
char[] appendPath(char[] buf, string[] pathItems ...) {
    foreach (s; pathItems) {
        if (buf.length && !isPathDelimiter(buf[$-1]))
            buf ~= PATH_DELIMITER;
        buf ~= s;
    }
    return convertPathDelimiters(buf);
}

