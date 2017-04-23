// Written in the D programming language.

/**
This module declares basic data types for usage in dlangui library.

Contains reference counting support, point and rect structures, character glyph structure, misc utility functions.

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
License:   Boost License 1.0
Authors:   Vadim Lopatin, coolreader.org@gmail.com
*/
module dlangui.core.types;

public import dlangui.core.config;

import std.algorithm;

/// 2D point
struct Point {
    int x;
    int y;

    Point opBinary(string op)(Point v) if (op == "+") {
        return Point(x + v.x, y + v.y);
    }
    Point opBinary(string op)(Point v) if (op == "-") {
        return Point(x - v.x, y - v.y);
    }
    int opCmp(ref const Point b) const {
        if (x == b.x) return y - b.y;
        return x - b.x;
    }
}

/// 2D rectangle
struct Rect {
    /// x coordinate of top left corner
    int left;
    /// y coordinate of top left corner
    int top;
    /// x coordinate of bottom right corner
    int right;
    /// y coordinate of bottom right corner
    int bottom;
    /// returns average of left, right
    @property int middlex() { return (left + right) / 2; }
    /// returns average of top, bottom
    @property int middley() { return (top + bottom) / 2; }
    /// returns middle point
    @property Point middle() { return Point(middlex, middley); }

    /// returns top left point of rectangle
    @property Point topLeft() { return Point(left, top); }
    /// returns bottom right point of rectangle
    @property Point bottomRight() { return Point(right, bottom); }

    /// returns size (width, height) in Point
    @property Point size() { return Point(right - left, bottom - top); }

    /// add offset to horizontal and vertical coordinates
    void offset(int dx, int dy) {
        left += dx;
        right += dx;
        top += dy;
        bottom += dy;
    }
    /// expand rectangle dimensions
    void expand(int dx, int dy) {
        left -= dx;
        right += dx;
        top -= dy;
        bottom += dy;
    }
    /// shrink rectangle dimensions
    void shrink(int dx, int dy) {
        left += dx;
        right -= dx;
        top += dy;
        bottom -= dy;
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
    /// returns width of rectangle (right - left)
    @property int width() { return right - left; }
    /// returns height of rectangle (bottom - top)
    @property int height() { return bottom - top; }
    /// constructs rectangle using left, top, right, bottom coordinates
    this(int x0, int y0, int x1, int y1) {
        left = x0;
        top = y0;
        right = x1;
        bottom = y1;
    }
    /// constructs rectangle using two points - (left, top), (right, bottom) coordinates
    this(Point pt0, Point pt1) {
        left = pt0.x;
        top = pt0.y;
        right = pt1.x;
        bottom = pt1.y;
    }
    /// returns true if rectangle is empty (right <= left || bottom <= top)
    @property bool empty() {
        return right <= left || bottom <= top;
    }
    /// translate rectangle coordinates by (x,y) - add deltax to x coordinates, and deltay to y coordinates
    alias moveBy = offset;
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

    bool opEquals(Rect rc) const {
        return left == rc.left && right == rc.right && top == rc.top && bottom == rc.bottom;
    }
}

/// constant acting as "rectangle not set" value
immutable Rect RECT_VALUE_IS_NOT_SET = Rect(int.min, int.min, int.min, int.min);

/// widget state bit flags
enum State : uint {
    /// state not specified / normal
    Normal = 4 | 256, // Normal is Enabled
    /// pressed (e.g. clicked by mouse)
    Pressed = 1,
    /// widget has focus
    Focused = 2,
    /// widget can process mouse and key events
    Enabled = 4,
    /// mouse pointer is over this widget
    Hovered = 8, // mouse pointer is over control, buttons not pressed
    /// widget is selected
    Selected = 16,
    /// widget can be checked
    Checkable = 32,
    /// widget is checked
    Checked = 64,
    /// widget is activated
    Activated = 128,
    /// window is focused
    WindowFocused = 256,
    /// widget is default control for form (should be focused when window gains focus first time)
    Default = 512, // widget is default for form (e.g. default button will be focused on show)
    /// widget has been focused by keyboard navigation
    KeyboardFocused = 1024,
    /// return state of parent instead of widget's state when requested
    Parent = 0x10000, // use parent's state
}


// Layout size constants
/// layout option, to occupy all available place
enum int FILL_PARENT = 0x4000_0000;
/// layout option, for size based on content
enum int WRAP_CONTENT = 0x2000_0000;
/// use as widget.layout() param to avoid applying of parent size
enum int SIZE_UNSPECIFIED = 0x6000_0000;

/// use in styles to specify size in points (1/72 inch)
enum int SIZE_IN_POINTS_FLAG = 0x1000_0000;
/// (RESERVED) use in styles to specify size in percents * 100 (e.g. 0 == 0%, 10000 == 100%, 100 = 1%)
enum int SIZE_IN_PERCENTS_FLAG = 0x0800_0000;


/// convert custom size to pixels (sz can be either pixels, or points if SIZE_IN_POINTS_FLAG bit set)
int toPixels(int sz) {
    if (sz > 0 && (sz & SIZE_IN_POINTS_FLAG) != 0) {
        return pointsToPixels(sz ^ SIZE_IN_POINTS_FLAG);
    }
    return sz;
}

/// convert custom size Point to pixels (sz can be either pixels, or points if SIZE_IN_POINTS_FLAG bit set)
Point toPixels(const Point sz) {
    return Point(toPixels(sz.x), toPixels(sz.y));
}

/// convert custom size Rect to pixels (sz can be either pixels, or points if SIZE_IN_POINTS_FLAG bit set)
Rect toPixels(const Rect sz) {
    return Rect(toPixels(sz.left), toPixels(sz.top), toPixels(sz.right), toPixels(sz.bottom));
}

/// make size value with SIZE_IN_POINTS_FLAG set
int makePointSize(int pt) {
    return pt | SIZE_IN_POINTS_FLAG;
}

/// make size value with SIZE_IN_PERCENTS_FLAG set
int makePercentSize(int percent) {
    return (percent * 100) | SIZE_IN_PERCENTS_FLAG;
}

/// make size value with SIZE_IN_PERCENTS_FLAG set
int makePercentSize(double percent) {
    return cast(int)(percent * 100) | SIZE_IN_PERCENTS_FLAG;
}

/// returns true for WRAP_CONTENT, WRAP_CONTENT, SIZE_UNSPECIFIED
bool isSpecialSize(int sz) {
    // don't forget to update if more special constants added
    return (sz & (WRAP_CONTENT | FILL_PARENT | SIZE_UNSPECIFIED)) != 0;
}

/// returns true if size has SIZE_IN_PERCENTS_FLAG bit set
bool isPercentSize(int size) {
    return (size & SIZE_IN_PERCENTS_FLAG) != 0;
}

/// if size has SIZE_IN_PERCENTS_FLAG bit set, returns percent of baseSize, otherwise returns size unchanged
int fromPercentSize(int size, int baseSize) {
    if (isPercentSize(size))
        return cast(int)(cast(long)(size & ~SIZE_IN_PERCENTS_FLAG) * baseSize / 10000);
    return size;
}

/// screen dots per inch
private __gshared int PRIVATE_SCREEN_DPI = 96;

@property int SCREEN_DPI() {
    return PRIVATE_SCREEN_DPI;
}

@property void SCREEN_DPI(int dpi) {
    static if (BACKEND_CONSOLE) {
        PRIVATE_SCREEN_DPI = dpi;
    } else {
        if (dpi >= 72 && dpi <= 500) {
            if (PRIVATE_SCREEN_DPI != dpi) {
                // changed DPI
                PRIVATE_SCREEN_DPI = dpi;
            }
        }
    }
}

/// one point is 1/72 of inch
enum POINTS_PER_INCH = 72;

/// convert length in points (1/72in units) to pixels according to SCREEN_DPI
int pointsToPixels(int pt) {
    return pt * SCREEN_DPI / POINTS_PER_INCH;
}

/// rectangle coordinates in points (1/72in units) to pixels according to SCREEN_DPI
Rect pointsToPixels(Rect rc) {
    return Rect(rc.left.pointsToPixels, rc.top.pointsToPixels, rc.right.pointsToPixels, rc.bottom.pointsToPixels);
}

/// convert points (1/72in units) to pixels according to SCREEN_DPI
int pixelsToPoints(int px) {
    return px * POINTS_PER_INCH / SCREEN_DPI;
}

/// Subpixel rendering mode for fonts (aka ClearType)
enum SubpixelRenderingMode : ubyte {
    /// no sub
    None,
    /// subpixel rendering on, subpixel order on device: B,G,R
    BGR,
    /// subpixel rendering on, subpixel order on device: R,G,B
    RGB,
}

/** 
    Character glyph.
    
    Holder for glyph metrics as well as image.
*/
align(1)
struct Glyph
{
    /// 0: width of glyph black box
    ushort   blackBoxX;

    @property ushort correctedBlackBoxX() { return subpixelMode ? blackBoxX / 3 : blackBoxX; }

    /// 2: height of glyph black box
    ubyte   blackBoxY;
    /// 3: X origin for glyph
    byte    originX;
    /// 4: Y origin for glyph
    byte    originY;

    /// 5: full width of glyph
    ubyte   width;
    /// 6: subpixel rendering mode - if !=SubpixelRenderingMode.None, glyph data contains 3 bytes per pixel instead of 1
    SubpixelRenderingMode subpixelMode;
    /// 7: usage flag, to handle cleanup of unused glyphs
    ubyte   lastUsage;
    static if (ENABLE_OPENGL) {
        /// 8: unique id of glyph (for drawing in hardware accelerated scenes)
        uint    id;
    }

    ///< 12: glyph data, arbitrary size (blackBoxX * blackBoxY)
    ubyte[] glyph;       
}

/** 
    Base class for reference counted objects, maintains reference counter inplace.

    If some class is not inherited from RefCountedObject, additional object will be required to hold counters.
*/
class RefCountedObject {
    /// count of references to this object from Ref
    protected int _refCount;
    /// returns current value of reference counter
    @property int refCount() const { return _refCount; }
    /// increments reference counter
    void addRef() { 
        _refCount++; 
    }
    /// decrement reference counter, destroy object if no more references left
    void releaseRef() { 
        if (--_refCount == 0) 
            destroy(this); 
    }
    ~this() {}
}

/** 
    Reference counting support.

    Implemented for case when T is RefCountedObject.
    Similar to shared_ptr in C++.
    Allows to share object, destroying it when no more references left.

    Useful for automatic destroy of objects.
*/
struct Ref(T) { // if (T is RefCountedObject)
    private T _data;
    alias get this;
    /// returns true if object is not assigned
    @property bool isNull() const { return _data is null; }
    /// returns counter of references
    @property int refCount() const { return _data !is null ? _data.refCount : 0; }
    /// init from T
    this(T data) {
        _data = data;
        if (_data !is null)
            _data.addRef();
    }
    /// after blit
    this(this) {
        if (_data !is null)
            _data.addRef();
    }
    /// assign from another refcount by reference
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
    /// assign from another refcount by value
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
    /// assign object
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
    /// clears reference
    void clear() { 
        if (_data !is null) {
            _data.releaseRef();
            _data = null;
        }
    }
    /// returns object reference (null if not assigned)
    @property T get() {
        return _data;
    }
    /// returns const reference from const object
    @property const(T) get() const {
        return _data;
    }
    /// decreases counter, and destroys object if no more references left
    ~this() {
        if (_data !is null)
            _data.releaseRef();
    }
}


//================================================================================
// some utility functions

/** conversion from wchar z-string */
wstring fromWStringz(const(wchar[]) s) {
    if (s is null)
        return null;
    int i = 0;
    while(s[i])
        i++;
    return cast(wstring)(s[0..i].dup);
}

/** conversion from wchar z-string */
wstring fromWStringz(const(wchar) * s) {
    if (s is null)
        return null;
    int i = 0;
    while(s[i])
        i++;
    return cast(wstring)(s[0..i].dup);
}

/** Deprecated: use std.uni.toUpper instead.
    Uppercase unicode character.
*/
deprecated dchar dcharToUpper(dchar ch) {
    static import std.uni;
    return std.uni.toUpper(ch);
}

/// decodes hex digit (0..9, a..f, A..F), returns uint.max if invalid
uint parseHexDigit(T)(T ch) pure nothrow {
    if (ch >= '0' && ch <= '9')
        return ch - '0';
    else if (ch >= 'a' && ch <= 'f')
        return ch - 'a' + 10;
    else if (ch >= 'A' && ch <= 'F')
        return ch - 'A' + 10;
    return uint.max;
}
