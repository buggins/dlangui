// Written in the D programming language.

/**
DLANGUI library.

This module contains resource management and drawables implementation.

imageCache is RAM cache of decoded images (as DrawBuf).

drawableCache is cache of Drawables.

Supports nine-patch PNG images in .9.png files (like in Android).

Supports state drawables using XML files similar to ones in Android).

Synopsis:

----
import dlangui.graphics.resources;

----

Copyright: Vadim Lopatin, 2014
License:   $(WEB boost.org/LICENSE_1_0.txt, Boost License 1.0).
Authors:   $(WEB coolreader.org, Vadim Lopatin)
*/
module dlangui.graphics.resources;

import dlangui.graphics.images;
import dlangui.graphics.drawbuf;
import dlangui.core.logger;
import std.file;
import std.algorithm;
import std.xml;
import std.algorithm;
import std.conv;


class Drawable : RefCountedObject {
	//private static int _instanceCount;
	this() {
		//Log.d("Created drawable, count=", ++_instanceCount);
	}
	~this() {
		//Log.d("Destroyed drawable, count=", --_instanceCount);
	}
    abstract void drawTo(DrawBuf buf, Rect rc, uint state = 0, int tilex0 = 0, int tiley0 = 0);
    @property abstract int width();
    @property abstract int height();
    @property Rect padding() { return Rect(0,0,0,0); }
}

class EmptyDrawable : Drawable {
    override void drawTo(DrawBuf buf, Rect rc, uint state = 0, int tilex0 = 0, int tiley0 = 0) {
    }
    @property override int width() { return 0; }
    @property override int height() { return 0; }
}

class SolidFillDrawable : Drawable {
    protected uint _color;
    this(uint color) {
        _color = color;
    }
    override void drawTo(DrawBuf buf, Rect rc, uint state = 0, int tilex0 = 0, int tiley0 = 0) {
        if ((_color >> 24) != 0xFF) // not fully transparent
            buf.fillRect(rc, _color);
    }
    @property override int width() { return 1; }
    @property override int height() { return 1; }
}

class ImageDrawable : Drawable {
    protected DrawBufRef _image;
    protected bool _tiled;
	//private int _instanceCount;
    this(ref DrawBufRef image, bool tiled = false, bool ninePatch = false) {
        _image = image;
        _tiled = tiled;
        if (ninePatch)
            _image.detectNinePatch();
		//Log.d("Created ImageDrawable, count=", ++_instanceCount);
    }
	~this() {
		_image.clear();
		//Log.d("Destroyed ImageDrawable, count=", --_instanceCount);
	}
    @property override int width() { 
        if (_image.isNull)
            return 0;
        if (_image.hasNinePatch)
            return _image.width - 2;
        return _image.width;
    }
    @property override int height() { 
        if (_image.isNull)
            return 0;
        if (_image.hasNinePatch)
            return _image.height - 2;
        return _image.height;
    }
    @property override Rect padding() { 
        if (!_image.isNull && _image.hasNinePatch)
            return _image.ninePatch.padding;
        return Rect(0,0,0,0); 
    }
    private static void correctFrameBounds(ref int n1, ref int n2, ref int n3, ref int n4) {
        if (n1 > n2) {
            //assert(n2 - n1 == n4 - n3);
            int middledist = (n1 + n2) / 2 - n1;
            n1 = n2 = n1 + middledist;
            n3 = n4 = n3 + middledist;
        }
    }
    override void drawTo(DrawBuf buf, Rect rc, uint state = 0, int tilex0 = 0, int tiley0 = 0) {
        if (_image.isNull)
            return;
        if (_image.hasNinePatch) {
            // draw nine patch
            const NinePatch * p = _image.ninePatch;
            //Log.d("drawing nine patch image with frame ", p.frame, " padding ", p.padding);
            int w = width;
            int h = height;
            Rect dstrect = rc;
            Rect srcrect = Rect(1, 1, w + 1, h + 1);
            if (true) { //buf.applyClipping(dstrect, srcrect)) {
                int x0 = srcrect.left;
                int x1 = srcrect.left + p.frame.left;
                int x2 = srcrect.right - p.frame.right;
                int x3 = srcrect.right;
                int y0 = srcrect.top;
                int y1 = srcrect.top + p.frame.top;
                int y2 = srcrect.bottom - p.frame.bottom;
                int y3 = srcrect.bottom;
                int dstx0 = rc.left;
                int dstx1 = rc.left + p.frame.left;
                int dstx2 = rc.right - p.frame.right;
                int dstx3 = rc.right;
                int dsty0 = rc.top;
                int dsty1 = rc.top + p.frame.top;
                int dsty2 = rc.bottom - p.frame.bottom;
                int dsty3 = rc.bottom;
                //Log.d("x bounds: ", x0, ", ", x1, ", ", x2, ", ", x3, " dst ", dstx0, ", ", dstx1, ", ", dstx2, ", ", dstx3);
                //Log.d("y bounds: ", y0, ", ", y1, ", ", y2, ", ", y3, " dst ", dsty0, ", ", dsty1, ", ", dsty2, ", ", dsty3);

                correctFrameBounds(x1, x2, dstx1, dstx2);
                correctFrameBounds(y1, y2, dsty1, dsty2);

                //correctFrameBounds(x1, x2);
                //correctFrameBounds(y1, y2);
                //correctFrameBounds(dstx1, dstx2);
                //correctFrameBounds(dsty1, dsty2);
                if (y0 < y1 && dsty0 < dsty1) {
                    // top row
                    if (x0 < x1 && dstx0 < dstx1)
                        buf.drawFragment(dstx0, dsty0, _image.get, Rect(x0, y0, x1, y1)); // top left
                    if (x1 < x2 && dstx1 < dstx2)
                        buf.drawRescaled(Rect(dstx1, dsty0, dstx2, dsty1), _image.get, Rect(x1, y0, x2, y1)); // top center
                    if (x2 < x3 && dstx2 < dstx3)
                        buf.drawFragment(dstx2, dsty0, _image.get, Rect(x2, y0, x3, y1)); // top right
                }
                if (y1 < y2 && dsty1 < dsty2) {
                    // middle row
                    if (x0 < x1 && dstx0 < dstx1)
                        buf.drawRescaled(Rect(dstx0, dsty1, dstx1, dsty2), _image.get, Rect(x0, y1, x1, y2)); // middle center
                    if (x1 < x2 && dstx1 < dstx2)
                        buf.drawRescaled(Rect(dstx1, dsty1, dstx2, dsty2), _image.get, Rect(x1, y1, x2, y2)); // center
                    if (x2 < x3 && dstx2 < dstx3)
                        buf.drawRescaled(Rect(dstx2, dsty1, dstx3, dsty2), _image.get, Rect(x2, y1, x3, y2)); // middle center
                }
                if (y2 < y3 && dsty2 < dsty3) {
                    // bottom row
                    if (x0 < x1 && dstx0 < dstx1)
                        buf.drawFragment(dstx0, dsty2, _image.get, Rect(x0, y2, x1, y3)); // bottom left
                    if (x1 < x2 && dstx1 < dstx2)
                        buf.drawRescaled(Rect(dstx1, dsty2, dstx2, dsty3), _image.get, Rect(x1, y2, x2, y3)); // bottom center
                    if (x2 < x3 && dstx2 < dstx3)
                        buf.drawFragment(dstx2, dsty2, _image.get, Rect(x2, y2, x3, y3)); // bottom right
                }
            }
        } else if (_tiled) {
            // tiled
        } else {
            // rescaled or normal
            if (rc.width != _image.width || rc.height != _image.height)
                buf.drawRescaled(rc, _image.get, Rect(0, 0, _image.width, _image.height));
            else
                buf.drawImage(rc.left, rc.top, _image);
        }
    }
}

string attrValue(Element item, string attrname, string attrname2) {
    if (attrname in item.tag.attr)
        return item.tag.attr[attrname];
    if (attrname2 in item.tag.attr)
        return item.tag.attr[attrname2];
    return null;
}

string attrValue(ref string[string] attr, string attrname, string attrname2) {
    if (attrname in attr)
        return attr[attrname];
    if (attrname2 in attr)
        return attr[attrname2];
    return null;
}

void extractStateFlag(ref string[string] attr, string attrName, string attrName2, State state, ref uint stateMask, ref uint stateValue) {
    string value = attrValue(attr, attrName, attrName2);
    if (value !is null) {
        if (value.equal("true"))
            stateValue |= state;
        stateMask |= state;
    }
}

/// converts XML attribute name to State (see http://developer.android.com/guide/topics/resources/drawable-resource.html#StateList)
void extractStateFlags(ref string[string] attr, ref uint stateMask, ref uint stateValue) {
    extractStateFlag(attr, "state_pressed", "android:state_pressed", State.Pressed, stateMask, stateValue);
    extractStateFlag(attr, "state_focused", "android:state_focused", State.Focused, stateMask, stateValue);
    extractStateFlag(attr, "state_hovered", "android:state_hovered", State.Hovered, stateMask, stateValue);
    extractStateFlag(attr, "state_selected", "android:state_selected", State.Selected, stateMask, stateValue);
    extractStateFlag(attr, "state_checkable", "android:state_checkable", State.Checkable, stateMask, stateValue);
    extractStateFlag(attr, "state_checked", "android:state_checked", State.Checked, stateMask, stateValue);
    extractStateFlag(attr, "state_enabled", "android:state_enabled", State.Enabled, stateMask, stateValue);
    extractStateFlag(attr, "state_activated", "android:state_activated", State.Activated, stateMask, stateValue);
    extractStateFlag(attr, "state_window_focused", "android:state_window_focused", State.WindowFocused, stateMask, stateValue);
}

/*
sample:
(prefix android: is optional)

<?xml version="1.0" encoding="utf-8"?>
<selector xmlns:android="http://schemas.android.com/apk/res/android"
android:constantSize=["true" | "false"]
android:dither=["true" | "false"]
android:variablePadding=["true" | "false"] >
<item
android:drawable="@[package:]drawable/drawable_resource"
android:state_pressed=["true" | "false"]
android:state_focused=["true" | "false"]
android:state_hovered=["true" | "false"]
android:state_selected=["true" | "false"]
android:state_checkable=["true" | "false"]
android:state_checked=["true" | "false"]
android:state_enabled=["true" | "false"]
android:state_activated=["true" | "false"]
android:state_window_focused=["true" | "false"] />
</selector>
*/

/// Drawable which is drawn depending on state (see http://developer.android.com/guide/topics/resources/drawable-resource.html#StateList)
class StateDrawable : Drawable {

    static struct StateItem {
        uint stateMask;
        uint stateValue;
        ColorTransform transform;
        DrawableRef drawable;
        @property bool matchState(uint state) {
            return (stateMask & state) == stateValue;
        }
    }
    // list of states
    protected StateItem[] _stateList;
    // max paddings for all states
    protected Rect _paddings;
    // max drawable size for all states
    protected Point _size;

    void addState(uint stateMask, uint stateValue, string resourceId, ref ColorTransform transform) {
        StateItem item;
        item.stateMask = stateMask;
        item.stateValue = stateValue;
        item.drawable = drawableCache.get(resourceId, transform);
        itemAdded(item);
    }

    void addState(uint stateMask, uint stateValue, DrawableRef drawable) {
        StateItem item;
        item.stateMask = stateMask;
        item.stateValue = stateValue;
        item.drawable = drawable;
        itemAdded(item);
    }

    private void itemAdded(ref StateItem item) {
        _stateList ~= item;
        if (!item.drawable.isNull) {
            if (_size.x < item.drawable.width)
                _size.x = item.drawable.width;
            if (_size.y < item.drawable.height)
                _size.y = item.drawable.height;
            _paddings.setMax(item.drawable.padding);
        }
    }

    /// parse 4 comma delimited integers
    static bool parseList4(T)(string value, ref T[4] items) {
        int index = 0;
        int p = 0;
        int start = 0;
        for (;p < value.length && index < 4; p++) {
            while (p < value.length && value[p] != ',')
                p++;
            if (p > start) {
                int end = p;
                string s = value[start .. end];
                items[index++] = to!T(s);
                start = p + 1;
            }
        }
        return index == 4;
    }
    private static uint colorTransformFromStringAdd(string value) {
        if (value is null)
            return COLOR_TRANSFORM_OFFSET_NONE;
        int n[4];
        if (!parseList4(value, n))
            return COLOR_TRANSFORM_OFFSET_NONE;
        foreach (ref item; n) {
            item = item / 2 + 0x80;
            if (item < 0)
                item = 0;
            if (item > 0xFF)
                item = 0xFF;
        }
        return (n[0] << 24) | (n[1] << 16) | (n[2] << 8) | (n[3] << 0);
    }
    private static uint colorTransformFromStringMult(string value) {
        if (value is null)
            return COLOR_TRANSFORM_MULTIPLY_NONE;
        float n[4];
        uint nn[4];
        if (!parseList4!float(value, n))
            return COLOR_TRANSFORM_MULTIPLY_NONE;
        for(int i = 0; i < 4; i++) {
            int res = cast(int)(n[i] * 0x40);
            if (res < 0)
                res = 0;
            if (res > 0xFF)
                res = 0xFF;
            nn[i] = res;
        }
        return (nn[0] << 24) | (nn[1] << 16) | (nn[2] << 8) | (nn[3] << 0);
    }

    bool load(Element element) {
        foreach(item; element.elements) {
            if (item.tag.name.equal("item")) {
                string drawableId = attrValue(item, "drawable", "android:drawable");
                ColorTransform transform;
                transform.addBefore = colorTransformFromStringAdd(attrValue(item, "color_transform_add1", "android:transform_color_add1"));
                transform.multiply = colorTransformFromStringMult(attrValue(item, "color_transform_mul", "android:transform_color_mul"));
                transform.addAfter = colorTransformFromStringAdd(attrValue(item, "color_transform_add2", "android:transform_color_add2"));
                if (drawableId !is null) {
                    uint stateMask, stateValue;
                    extractStateFlags(item.tag.attr, stateMask, stateValue);
                    if (drawableId !is null) {
                        addState(stateMask, stateValue, drawableId, transform);
                    }
                }
            }
        }
        return _stateList.length > 0;
    }

    /// load from XML file
    bool load(string filename) {
        import std.file;
        import std.string;

        try {
            string s = cast(string)std.file.read(filename);

            // Check for well-formedness
            //check(s);

            // Make a DOM tree
            auto doc = new Document(s);

            return load(doc);
        } catch (CheckException e) {
            Log.e("Invalid XML file ", filename);
            return false;
        } catch (Throwable e) {
            Log.e("Cannot read drawable resource from file ", filename);
            return false;
        }
    }

    override void drawTo(DrawBuf buf, Rect rc, uint state = 0, int tilex0 = 0, int tiley0 = 0) {
        foreach(ref item; _stateList)
            if (item.matchState(state)) {
                if (!item.drawable.isNull)
                    item.drawable.drawTo(buf, rc, state, tilex0, tiley0);
                return;
            }
    }

    @property override int width() {
        return _size.x;
    }
    @property override int height() {
        return _size.y;
    }
    @property override Rect padding() { 
        return _paddings;
    }
}

alias DrawableRef = Ref!Drawable;





/// decoded image cache
class ImageCache {

    static class ImageCacheItem {
        string _filename;
        DrawBufRef _drawbuf;
        DrawBufRef[ColorTransform] _transformMap;

        bool _error; // flag to avoid loading of file if it has been failed once
        bool _used;
        this(string filename) {
            _filename = filename;
        }
        /// get normal image
        @property ref DrawBufRef get() {
            if (!_drawbuf.isNull || _error) {
                _used = true;
                return _drawbuf;
            }
            _drawbuf = loadImage(_filename);
            if (_filename.endsWith(".9.png"))
                _drawbuf.detectNinePatch();
            _used = true;
            if (_drawbuf.isNull)
                _error = true;
            return _drawbuf;
        }
        /// get color transformed image
        @property ref DrawBufRef get(ref ColorTransform transform) {
            if (transform.empty)
                return get();
            if (transform in _transformMap)
                return _transformMap[transform];
            DrawBufRef src = get();
            if (src.isNull)
                _transformMap[transform] = src;
            else {            
                DrawBufRef t = src.transformColors(transform);
                _transformMap[transform] = t;
            }
            return _transformMap[transform];
        }
        /// remove from memory, will cause reload on next access
        void compact() {
            if (!_drawbuf.isNull)
                _drawbuf.clear();
        }
        /// mark as not used
        void checkpoint() {
            _used = false;
        }
        /// cleanup if unused since last checkpoint
        void cleanup() {
            if (!_used)
                compact();
        }
    }
    ImageCacheItem[string] _map;

    /// get and cache image
    ref DrawBufRef get(string filename) {
        if (filename in _map) {
            return _map[filename].get;
        }
        ImageCacheItem item = new ImageCacheItem(filename);
        _map[filename] = item;
        return item.get;
    }
    /// get and cache color transformed image
    ref DrawBufRef get(string filename, ref ColorTransform transform) {
        if (transform.empty)
            return get(filename);
        if (filename in _map) {
            return _map[filename].get(transform);
        }
        ImageCacheItem item = new ImageCacheItem(filename);
        _map[filename] = item;
        return item.get(transform);
    }
	// clear usage flags for all entries
	void checkpoint() {
        foreach (item; _map)
            item.checkpoint();
    }
	// removes entries not used after last call of checkpoint() or cleanup()
	void cleanup() {
        foreach (item; _map)
            item.cleanup();
    }

    this() {
        Log.i("Creating ImageCache");
    }
    ~this() {
        Log.i("Destroying ImageCache");
		foreach (ref item; _map) {
			destroy(item);
            item = null;
		}
		_map.clear();
    }
}

__gshared ImageCache _imageCache;
/// image cache singleton
@property ImageCache imageCache() { return _imageCache; }
/// image cache singleton
@property void imageCache(ImageCache cache) { 
	if (_imageCache !is null)
		destroy(_imageCache);
	_imageCache = cache; 
}

__gshared DrawableCache _drawableCache;
/// drawable cache singleton
@property DrawableCache drawableCache() { return _drawableCache; }
/// drawable cache singleton
@property void drawableCache(DrawableCache cache) { 
	if (_drawableCache !is null)
		destroy(_drawableCache);
	_drawableCache = cache;
}

shared static this() {
    _imageCache = new ImageCache();
    _drawableCache = new DrawableCache();
}

class DrawableCache {
    static class DrawableCacheItem {
        string _id;
        string _filename;
        bool _tiled;
        bool _error;
        bool _used;
        DrawableRef _drawable;
        DrawableRef[ColorTransform] _transformed;

		//private int _instanceCount;
        this(string id, string filename, bool tiled) {
            _id = id;
            _filename = filename;
            _tiled = tiled;
            _error = filename is null;
			//Log.d("Created DrawableCacheItem, count=", ++_instanceCount);
        }
		~this() {
			_drawable.clear();
			//Log.d("Destroyed DrawableCacheItem, count=", --_instanceCount);
		}
        /// remove from memory, will cause reload on next access
        void compact() {
            if (!_drawable.isNull)
                _drawable.clear();
        }
        /// mark as not used
        void checkpoint() {
            _used = false;
        }
        /// cleanup if unused since last checkpoint
        void cleanup() {
            if (!_used)
                compact();
        }
        /// returns drawable (loads from file if necessary)
        @property ref DrawableRef drawable() {
            _used = true;
            if (!_drawable.isNull || _error)
                return _drawable;
            if (_filename !is null) {
                // reload from file
                if (_filename.endsWith(".xml")) {
                    // XML drawables support
                    StateDrawable d = new StateDrawable();
                    if (!d.load(_filename)) {
                        destroy(d);
                        _error = true;
                    } else {
                        _drawable = d;
                    }
                } else {
                    // PNG/JPEG drawables support
                    DrawBufRef image = imageCache.get(_filename);
                    if (!image.isNull) {
                        bool ninePatch = _filename.endsWith(".9.png");
                        _drawable = new ImageDrawable(image, _tiled, ninePatch);
                    } else
                        _error = true;
                }
            }
            return _drawable;
        }
        /// returns drawable (loads from file if necessary)
        @property ref DrawableRef drawable(ref ColorTransform transform) {
            if (transform.empty)
                return drawable();
            if (transform in _transformed)
                return _transformed[transform];
            _used = true;
            if (!_drawable.isNull || _error)
                return _drawable;
            if (_filename !is null) {
                // reload from file
                if (_filename.endsWith(".xml")) {
                    // XML drawables support
                    StateDrawable d = new StateDrawable();
                    if (!d.load(_filename)) {
                        destroy(d);
                        _error = true;
                    } else {
                        _drawable = d;
                    }
                } else {
                    // PNG/JPEG drawables support
                    DrawBufRef image = imageCache.get(_filename, transform);
                    if (!image.isNull) {
                        bool ninePatch = _filename.endsWith(".9.png");
                        _transformed[transform] = new ImageDrawable(image, _tiled, ninePatch);
                        return _transformed[transform];
                    } else
                        _error = true;
                }
            }
            return _drawable;
        }
    }
    void clear() {
		Log.d("DrawableCache.clear()");
        _idToFileMap.clear();
        foreach(DrawableCacheItem item; _idToDrawableMap)
            item.drawable.clear();
        _idToDrawableMap.clear();
    }
	// clear usage flags for all entries
	void checkpoint() {
        foreach (item; _idToDrawableMap)
            item.checkpoint();
    }
	// removes entries not used after last call of checkpoint() or cleanup()
	void cleanup() {
        foreach (item; _idToDrawableMap)
            item.cleanup();
    }
    string[] _resourcePaths;
    string[string] _idToFileMap;
    DrawableCacheItem[string] _idToDrawableMap;
    DrawableRef _nullDrawable;
    ref DrawableRef get(string id) {
        if (id.equal("@null"))
            return _nullDrawable;
        if (id in _idToDrawableMap)
            return _idToDrawableMap[id].drawable;
        string resourceId = id;
        bool tiled = false;
        if (id.endsWith(".tiled")) {
            resourceId = id[0..$-6]; // remove .tiled
            tiled = true;
        }
        string filename = findResource(resourceId);
        DrawableCacheItem item = new DrawableCacheItem(id, filename, tiled);
        _idToDrawableMap[id] = item;
        return item.drawable;
    }
    ref DrawableRef get(string id, ref ColorTransform transform) {
        if (transform.empty)
            return get(id);
        if (id.equal("@null"))
            return _nullDrawable;
        if (id in _idToDrawableMap)
            return _idToDrawableMap[id].drawable(transform);
        string resourceId = id;
        bool tiled = false;
        if (id.endsWith(".tiled")) {
            resourceId = id[0..$-6]; // remove .tiled
            tiled = true;
        }
        string filename = findResource(resourceId);
        DrawableCacheItem item = new DrawableCacheItem(id, filename, tiled);
        _idToDrawableMap[id] = item;
        return item.drawable(transform);
    }
    @property string[] resourcePaths() {
        return _resourcePaths;
    }
    /// set resource directory paths as variable number of parameters
    void setResourcePaths(string[] paths ...) {
        resourcePaths(paths);
    }
    /// set resource directory paths array (only existing dirs will be added)
    @property void resourcePaths(string[] paths) {
        string[] existingPaths;
        foreach(path; paths) {
            if (exists(path) && isDir(path)) {
                existingPaths ~= path;
                Log.d("DrawableCache: adding path ", path, " to resource dir list.");
            } else {
                Log.d("DrawableCache: path ", path, " does not exist.");
            }
        }
        _resourcePaths = existingPaths;
        clear();
    }
    /// concatenates path with resource id and extension, returns pathname if there is such file, null if file does not exist
    private string checkFileName(string path, string id, string extension) {
        char[] fn = path.dup;
        fn ~= id;
        fn ~= extension;
        if (exists(fn) && isFile(fn))
            return fn.dup;
        return null;
    }
    string findResource(string id) {
        if (id in _idToFileMap)
            return _idToFileMap[id];
        foreach(string path; _resourcePaths) {
            string fn;
            fn = checkFileName(path, id, ".xml");
            if (fn is null)
                fn = checkFileName(path, id, ".png");
            if (fn is null)
                fn = checkFileName(path, id, ".9.png");
            if (fn is null)
                fn = checkFileName(path, id, ".jpg");
            if (fn !is null) {
                _idToFileMap[id] = fn;
                return fn;
            }
        }
        return null;
    }
    this() {
        Log.i("Creating DrawableCache");
    }
    ~this() {
        Log.i("Destroying DrawableCache");
		foreach (ref item; _idToDrawableMap) {
			destroy(item);
			item = null;
		}
		_idToDrawableMap.clear();
    }
}

