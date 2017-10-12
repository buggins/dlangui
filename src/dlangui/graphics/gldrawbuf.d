// Written in the D programming language.

/**
This module contains opengl based drawing buffer implementation.

To enable OpenGL support, build with version(USE_OPENGL);

Synopsis:

----
import dlangui.graphics.gldrawbuf;

----

Copyright: Vadim Lopatin, 2014
License:   Boost License 1.0
Authors:   Vadim Lopatin, coolreader.org@gmail.com
*/
module dlangui.graphics.gldrawbuf;

public import dlangui.core.config;
static if (BACKEND_GUI):
static if (ENABLE_OPENGL):

import dlangui.graphics.drawbuf;
import dlangui.graphics.colors;
import dlangui.core.logger;
private import dlangui.graphics.glsupport;
private import std.algorithm;

/// Reference counted GLTexture object
alias TextureRef = Ref!GLTexture;

interface GLConfigCallback {
    void saveConfiguration();
    void restoreConfiguration();
}

/// drawing buffer - image container which allows to perform some drawing operations
class GLDrawBuf : DrawBuf, GLConfigCallback {
    // width
    protected int _dx;
    // height
    protected int _dy;
    protected bool _framebuffer; // not yet supported
    protected uint _framebufferId; // not yet supported
    protected Scene _scene;

    /// get current scene (exists only between beforeDrawing() and afterDrawing() calls)
    @property Scene scene() { return _scene; }

    this(int dx, int dy, bool framebuffer = false) {
        resize(dx, dy);
        _framebuffer = framebuffer;
    }

    /// returns current width
    @property override int width() { return _dx; }
    /// returns current height
    @property override int height() { return _dy; }

    override void saveConfiguration() {
    }
    override void restoreConfiguration() {
        glSupport.setOrthoProjection(Rect(0, 0, _dx, _dy), Rect(0, 0, _dx, _dy));
    }

    /// reserved for hardware-accelerated drawing - begins drawing queue
    override void beforeDrawing() {
        _alpha = 0;
        if (_scene !is null) {
            _scene.reset();
        }
        _scene = new Scene(this);
    }

    /// reserved for hardware-accelerated drawing - ends drawing queue
    override void afterDrawing() {
        glSupport.setOrthoProjection(Rect(0, 0, _dx, _dy), Rect(0, 0, _dx, _dy));
        glSupport.beforeRenderGUI();
        _scene.draw();
        glSupport.queue.flush();
        glSupport.flushGL();
        destroy(_scene);
        _scene = null;
    }

    /// resize buffer
    override void resize(int width, int height) {
        _dx = width;
        _dy = height;
        resetClipping();
    }

    /// draw custom OpenGL scene
    override void drawCustomOpenGLScene(Rect rc, OpenGLDrawableDelegate handler) {
        _scene.add(new CustomDrawnSceneItem(Rect(0, 0, width, height), rc, handler));
    }

    /// fill the whole buffer with solid color (no clipping applied)
    override void fill(uint color) {
        if (hasClipping) {
            fillRect(_clipRect, color);
            return;
        }
        assert(_scene !is null);
        _scene.add(new SolidRectSceneItem(Rect(0, 0, _dx, _dy), applyAlpha(color)));
    }
    /// fill rectangle with solid color (clipping is applied)
    override void fillRect(Rect rc, uint color) {
        assert(_scene !is null);
        color = applyAlpha(color);
        if (!isFullyTransparentColor(color) && applyClipping(rc))
            _scene.add(new SolidRectSceneItem(rc, color));
    }

    /// fill rectangle with a gradient (clipping is applied)
    override void fillGradientRect(Rect rc, uint color1, uint color2, uint color3, uint color4) {
        assert(_scene !is null);
        color1 = applyAlpha(color1);
        color2 = applyAlpha(color2);
        color3 = applyAlpha(color3);
        color4 = applyAlpha(color4);
        if (!(isFullyTransparentColor(color1) && isFullyTransparentColor(color3)) && applyClipping(rc))
            _scene.add(new GradientRectSceneItem(rc, color1, color2, color3, color4));
    }

    /// fill rectangle with solid color and pattern (clipping is applied) 0=solid fill, 1 = dotted
    override void fillRectPattern(Rect rc, uint color, int pattern) {
        if (pattern == PatternType.solid)
            fillRect(rc, color);
        else {
            assert(_scene !is null);
            color = applyAlpha(color);
            if (!isFullyTransparentColor(color) && applyClipping(rc))
                _scene.add(new PatternRectSceneItem(rc, color, pattern));
        }
    }

    /// draw pixel at (x, y) with specified color
    override void drawPixel(int x, int y, uint color) {
        assert(_scene !is null);
        if (!_clipRect.isPointInside(x, y))
            return;
        color = applyAlpha(color);
        if (isFullyTransparentColor(color))
            return;
        _scene.add(new SolidRectSceneItem(Rect(x, y, x + 1, y + 1), color));
    }
    /// draw 8bit alpha image - usually font glyph using specified color (clipping is applied)
    override void drawGlyph(int x, int y, Glyph * glyph, uint color) {
        assert(_scene !is null);
        Rect dstrect = Rect(x,y, x + glyph.correctedBlackBoxX, y + glyph.blackBoxY);
        Rect srcrect = Rect(0, 0, glyph.correctedBlackBoxX, glyph.blackBoxY);
        color = applyAlpha(color);
        if (!isFullyTransparentColor(color) && applyClipping(dstrect, srcrect)) {
            if (!glGlyphCache.isInCache(glyph.id))
                glGlyphCache.put(glyph);
            _scene.add(new GlyphSceneItem(glyph.id, dstrect, srcrect, color, null));
        }
    }
    /// draw source buffer rectangle contents to destination buffer
    override void drawFragment(int x, int y, DrawBuf src, Rect srcrect) {
        assert(_scene !is null);
        Rect dstrect = Rect(x, y, x + srcrect.width, y + srcrect.height);
        //Log.v("GLDrawBuf.frawFragment dst=", dstrect, " src=", srcrect);
        if (applyClipping(dstrect, srcrect)) {
            if (!glImageCache.isInCache(src.id))
                glImageCache.put(src);
            _scene.add(new TextureSceneItem(src.id, dstrect, srcrect, applyAlpha(0xFFFFFF), 0, null));
        }
    }
    /// draw source buffer rectangle contents to destination buffer rectangle applying rescaling
    override void drawRescaled(Rect dstrect, DrawBuf src, Rect srcrect) {
        assert(_scene !is null);
        //Log.v("GLDrawBuf.frawRescaled dst=", dstrect, " src=", srcrect);
        if (applyClipping(dstrect, srcrect)) {
            if (!glImageCache.isInCache(src.id))
                glImageCache.put(src);
            _scene.add(new TextureSceneItem(src.id, dstrect, srcrect, applyAlpha(0xFFFFFF), 0, null));
        }
    }

    /// draw line from point p1 to p2 with specified color
    override void drawLine(Point p1, Point p2, uint colour) {
        assert(_scene !is null);
        if (!clipLine(_clipRect, p1, p2))
            return;
        _scene.add(new LineSceneItem(p1, p2, colour));
    }

    /// draw filled triangle in float coordinates; clipping is already applied
    override protected void fillTriangleFClipped(PointF p1, PointF p2, PointF p3, uint colour) {
        assert(_scene !is null);
        _scene.add(new TriangleSceneItem(p1, p2, p3, colour));
    }

    /// cleanup resources
    override void clear() {
        if (_framebuffer) {
            // TODO: delete framebuffer
        }
    }
    ~this() { clear(); }
}

/// base class for all drawing scene items.
class SceneItem {
    abstract void draw();
    /// when true, save configuration before drawing, and restore after drawing
    @property bool needSaveConfiguration() { return false; }
    /// when true, don't destroy item after drawing, since it's owned by some other component
    @property bool persistent() { return false; }
    void beforeDraw() { }
    void afterDraw() { }
}

class CustomSceneItem : SceneItem {
    private SceneItem[] _items;
    void add(SceneItem item) {
        _items ~= item;
    }
    override void draw() {
        foreach(SceneItem item; _items) {
            item.beforeDraw();
            item.draw();
            item.afterDraw();
        }
    }
    override @property bool needSaveConfiguration() { return true; }
}

/// Drawing scene (operations sheduled for drawing)
class Scene {
    private SceneItem[] _items;
    private GLConfigCallback _configCallback;
    this(GLConfigCallback configCallback) {
        _configCallback = configCallback;
        activeSceneCount++;
    }
    ~this() {
        activeSceneCount--;
    }
    /// add new scene item to scene
    void add(SceneItem item) {
        _items ~= item;
    }
    /// draws all scene items and removes them from list
    void draw() {
        foreach(SceneItem item; _items) {
            if (item.needSaveConfiguration) {
                _configCallback.saveConfiguration();
            }
            item.beforeDraw();
            item.draw();
            item.afterDraw();
            if (item.needSaveConfiguration) {
                _configCallback.restoreConfiguration();
            }
        }
        reset();
    }
    /// resets scene for new drawing - deletes all items
    void reset() {
        foreach(ref SceneItem item; _items) {
            if (!item.persistent) // only destroy items not owner by other components
                destroy(item);
            item = null;
        }
        _items.length = 0;
    }
}

private __gshared int activeSceneCount = 0;
bool hasActiveScene() {
    return activeSceneCount > 0;
}

enum MIN_TEX_SIZE = 64;
enum MAX_TEX_SIZE  = 4096;
private int nearestPOT(int n) {
    for (int i = MIN_TEX_SIZE; i <= MAX_TEX_SIZE; i *= 2) {
        if (n <= i)
            return i;
    }
    return MIN_TEX_SIZE;
}

private int correctTextureSize(int n) {
    if (n < 16)
        return 16;
    version(POT_TEXTURE_SIZES) {
        return nearestPOT(n);
    } else {
        return n;
    }
}

/// object deletion listener callback function type
void onObjectDestroyedCallback(uint pobject) {
    glImageCache.onCachedObjectDeleted(pobject);
}

/// object deletion listener callback function type
void onGlyphDestroyedCallback(uint pobject) {
    glGlyphCache.onCachedObjectDeleted(pobject);
}

private __gshared GLImageCache glImageCache;
private __gshared GLGlyphCache glGlyphCache;

void initGLCaches() {
    if (!glImageCache)
        glImageCache = new GLImageCache;
    if (!glGlyphCache)
        glGlyphCache = new GLGlyphCache;
}

void destroyGLCaches() {
    if (glImageCache)
        destroy(glImageCache);
    if (glGlyphCache)
        destroy(glGlyphCache);
}

private abstract class GLCache
{
    static class GLCacheItem
    {
        @property GLCachePage page() { return _page; }

        uint _objectId;
        // image size
        Rect _rc;
        bool _deleted;

        this(GLCachePage page, uint objectId) { _page = page; _objectId = objectId; }

        private GLCachePage _page;
    }

    static abstract class GLCachePage {
    private:
        GLCache _cache;
        int _tdx;
        int _tdy;
        ColorDrawBuf _drawbuf;
        int _currentLine;
        int _nextLine;
        int _x;
        bool _closed;
        bool _needUpdateTexture;
        Tex2D _texture;
        int _itemCount;

    public:
        this(GLCache cache, int dx, int dy) {
            _cache = cache;
            _tdx = correctTextureSize(dx);
            _tdy = correctTextureSize(dy);
            _itemCount = 0;
        }

        ~this() {
            if (_drawbuf) {
                destroy(_drawbuf);
                _drawbuf = null;
            }
            if (_texture && _texture.ID != 0) {
                destroy(_texture);
                _texture = null;
            }
        }

        final void updateTexture() {
            if (_drawbuf is null)
                return; // no draw buffer!!!
            if (_texture is null || _texture.ID == 0) {
                _texture = new Tex2D();
                Log.d("updateTexture - new texture id=", _texture.ID);
                if (!_texture.ID)
                    return;
            }
            Log.d("updateTexture for cache page - setting image ", _drawbuf.width, "x", _drawbuf.height, " tx=", _texture ? _texture.ID : 0);
            uint * pixels = _drawbuf.scanLine(0);
            if (!glSupport.setTextureImage(_texture, _drawbuf.width, _drawbuf.height, cast(ubyte*)pixels)) {
                destroy(_texture);
                _texture = null;
                return;
            }
            _needUpdateTexture = false;
            if (_closed) {
                destroy(_drawbuf);
                _drawbuf = null;
            }
        }

        final GLCacheItem reserveSpace(uint objectId, int width, int height) {
            auto cacheItem = new GLCacheItem(this, objectId);
            if (_closed)
                return null;

            int spacer = (width == _tdx || height == _tdy) ? 0 : 1;

            // next line if necessary
            if (_x + width + spacer * 2 > _tdx) {
                // move to next line
                _currentLine = _nextLine;
                _x = 0;
            }
            // check if no room left for glyph height
            if (_currentLine + height + spacer * 2 > _tdy) {
                _closed = true;
                return null;
            }
            cacheItem._rc = Rect(_x + spacer, _currentLine + spacer, _x + width + spacer, _currentLine + height + spacer);
            if (height && width) {
                if (_nextLine < _currentLine + height + 2 * spacer)
                    _nextLine = _currentLine + height + 2 * spacer;
                if (!_drawbuf) {
                    _drawbuf = new ColorDrawBuf(_tdx, _tdy);
                    //_drawbuf.SetBackgroundColor(0x000000);
                    //_drawbuf.SetTextColor(0xFFFFFF);
                    _drawbuf.fill(0xFF000000);
                }
                _x += width + spacer;
                _needUpdateTexture = true;
            }
            _itemCount++;
            return cacheItem;
        }

        final int deleteItem(GLCacheItem item) {
            _itemCount--;
            return _itemCount;
        }

        final void close() {
            _closed = true;
            if (_needUpdateTexture)
                updateTexture();
        }
    }

    GLCacheItem[uint] _map;
    GLCachePage[] _pages;
    GLCachePage _activePage;
    int tdx;
    int tdy;

    final void removePage(GLCachePage page) {
        if (_activePage == page)
            _activePage = null;
        foreach(i; 0 .. _pages.length)
            if (_pages[i] == page) {
                _pages = _pages.remove(i);
                break;
            }
        destroy(page);
    }

    final void updateTextureSize() {
        if (!tdx) {
            // TODO
            tdx = tdy = 1024; //getMaxTextureSize();
            if (tdx > 1024)
                tdx = tdy = 1024;
        }
    }

    this() {
    }
    ~this() {
        clear();
    }
    /// check if item is in cache
    final bool isInCache(uint obj) {
        if (obj in _map)
            return true;
        return false;
    }
    /// clears cache
    final void clear() {
        foreach(i; 0 .. _pages.length) {
            destroy(_pages[i]);
            _pages[i] = null;
        }
        destroy(_pages);
        destroy(_map);
    }
    /// handle cached object deletion, mark as deleted
    final void onCachedObjectDeleted(uint objectId) {
        if (objectId in _map) {
            GLCacheItem item = _map[objectId];
            if (hasActiveScene()) {
                item._deleted = true;
            } else {
                int itemsLeft = item.page.deleteItem(item);
                if (itemsLeft <= 0) {
                    removePage(item.page);
                }
                _map.remove(objectId);
                destroy(item);
            }
        }
    }
    /// remove deleted items - remove page if contains only deleted items
    final void removeDeletedItems() {
        uint[] list;
        foreach(GLCacheItem item; _map) {
            if (item._deleted)
                list ~= item._objectId;
        }
        foreach(i; 0 .. list.length) {
            onCachedObjectDeleted(list[i]);
        }
    }
}

/// OpenGL texture cache for ColorDrawBuf objects
private class GLImageCache : GLCache
{
    static class GLImageCachePage : GLCachePage {

        this(GLImageCache cache, int dx, int dy) {
            super(cache, dx, dy);
            Log.v("created image cache page ", dx, "x", dy);
        }

        void convertPixelFormat(GLCacheItem item) {
            Rect rc = item._rc;
            if (rc.top > 0)
                rc.top--;
            if (rc.left > 0)
                rc.left--;
            if (rc.right < _tdx)
                rc.right++;
            if (rc.bottom < _tdy)
                rc.bottom++;
            for (int y = rc.top; y < rc.bottom; y++) {
                uint * row = _drawbuf.scanLine(y);
                for (int x = rc.left; x < rc.right; x++) {
                    uint cl = row[x];
                    // invert A
                    cl ^= 0xFF000000;
                    // swap R and B
                    uint r = (cl & 0x00FF0000) >> 16;
                    uint b = (cl & 0x000000FF) << 16;
                    row[x] = (cl & 0xFF00FF00) | r | b;
                }
            }
        }

        GLCacheItem addItem(DrawBuf buf) {
            GLCacheItem cacheItem = reserveSpace(buf.id, buf.width, buf.height);
            if (cacheItem is null)
                return null;
            buf.onDestroyCallback = &onObjectDestroyedCallback;
            _drawbuf.drawImage(cacheItem._rc.left, cacheItem._rc.top, buf);
            convertPixelFormat(cacheItem);
            _needUpdateTexture = true;
            return cacheItem;
        }
        void drawItem(GLCacheItem item, Rect dstrc, Rect srcrc, uint color, uint options, Rect * clip) {
            if (_needUpdateTexture)
                updateTexture();
            if (_texture && _texture.ID != 0) {
                int rx = dstrc.middlex;
                int ry = dstrc.middley;
                // convert coordinates to cached texture
                srcrc.offset(item._rc.left, item._rc.top);
                if (clip) {
                    int srcw = srcrc.width();
                    int srch = srcrc.height();
                    int dstw = dstrc.width();
                    int dsth = dstrc.height();
                    if (dstw) {
                        srcrc.left += clip.left * srcw / dstw;
                        srcrc.right -= clip.right * srcw / dstw;
                    }
                    if (dsth) {
                        srcrc.top += clip.top * srch / dsth;
                        srcrc.bottom -= clip.bottom * srch / dsth;
                    }
                    dstrc.left += clip.left;
                    dstrc.right -= clip.right;
                    dstrc.top += clip.top;
                    dstrc.bottom -= clip.bottom;
                }
                if (!dstrc.empty)
                    glSupport.queue.addTexturedRect(_texture, _tdx, _tdy, color, color, color, color, srcrc, dstrc, true);
            }
        }
    }

    /// put new object to cache
    void put(DrawBuf img) {
        updateTextureSize();
        GLCacheItem res = null;
        if (img.width <= tdx / 3 && img.height < tdy / 3) {
            // trying to reuse common page for small images
            if (_activePage is null) {
                _activePage = new GLImageCachePage(this, tdx, tdy);
                _pages ~= _activePage;
            }
            res = (cast(GLImageCachePage)_activePage).addItem(img);
            if (!res) {
                auto page = new GLImageCachePage(this, tdx, tdy);
                _pages ~= page;
                res = page.addItem(img);
                _activePage = page;
            }
        } else {
            // use separate page for big image
            auto page = new GLImageCachePage(this, img.width, img.height);
            _pages ~= page;
            res = page.addItem(img);
            page.close();
        }
        _map[img.id] = res;
    }
    /// draw cached item
    void drawItem(uint objectId, Rect dstrc, Rect srcrc, uint color, int options, Rect * clip) {
        GLCacheItem* item = objectId in _map;
        if (item) {
            auto page = (cast(GLImageCachePage)item.page);
            page.drawItem(*item, dstrc, srcrc, color, options, clip);
        }
    }
}

private class GLGlyphCache : GLCache
{
    static class GLGlyphCachePage : GLCachePage {

        this(GLGlyphCache cache, int dx, int dy) {
            super(cache, dx, dy);
            Log.v("created glyph cache page ", dx, "x", dy);
        }

        GLCacheItem addItem(Glyph* glyph) {
            GLCacheItem cacheItem = reserveSpace(glyph.id, glyph.correctedBlackBoxX, glyph.blackBoxY);
            if (cacheItem is null)
                return null;
            //_drawbuf.drawGlyph(cacheItem._rc.left, cacheItem._rc.top, glyph, 0xFFFFFF);
            _drawbuf.drawGlyphToTexture(cacheItem._rc.left, cacheItem._rc.top, glyph);
            _needUpdateTexture = true;
            return cacheItem;
        }

        void drawItem(GLCacheItem item, Rect dstrc, Rect srcrc, uint color, Rect * clip) {
            if (_needUpdateTexture)
                updateTexture();
            if (_texture && _texture.ID != 0) {
                // convert coordinates to cached texture
                srcrc.offset(item._rc.left, item._rc.top);
                if (clip) {
                    int srcw = srcrc.width();
                    int srch = srcrc.height();
                    int dstw = dstrc.width();
                    int dsth = dstrc.height();
                    if (dstw) {
                        srcrc.left += clip.left * srcw / dstw;
                        srcrc.right -= clip.right * srcw / dstw;
                    }
                    if (dsth) {
                        srcrc.top += clip.top * srch / dsth;
                        srcrc.bottom -= clip.bottom * srch / dsth;
                    }
                    dstrc.left += clip.left;
                    dstrc.right -= clip.right;
                    dstrc.top += clip.top;
                    dstrc.bottom -= clip.bottom;
                }
                if (!dstrc.empty) {
                    //Log.d("drawing glyph with color ", color);
                    glSupport.queue.addTexturedRect(_texture, _tdx, _tdy, color, color, color, color, srcrc, dstrc, false);
                }
            }
        }
    }

    /// put new item to cache
    void put(Glyph* glyph) {
        updateTextureSize();
        GLCacheItem res = null;
        if (_activePage is null) {
            _activePage = new GLGlyphCachePage(this, tdx, tdy);
            _pages ~= _activePage;
        }
        res = (cast(GLGlyphCachePage)_activePage).addItem(glyph);
        if (!res) {
            auto page = new GLGlyphCachePage(this, tdx, tdy);
            _pages ~= page;
            res = page.addItem(glyph);
             _activePage = page;
        }
        _map[glyph.id] = res;
    }
    /// draw cached item
    void drawItem(uint objectId, Rect dstrc, Rect srcrc, uint color, Rect * clip) {
        GLCacheItem* item = objectId in _map;
        if (item)
            (cast(GLGlyphCachePage)item.page).drawItem(*item, dstrc, srcrc, color, clip);
    }
}





private class LineSceneItem : SceneItem {
private:
    Point _p1;
    Point _p2;
    uint _color;

public:
    this(Point p1, Point p2, uint color) {
        _p1 = p1;
        _p2 = p2;
        _color = color;
    }
    override void draw() {
        glSupport.queue.addLine(Rect(_p1, _p2), _color, _color);
    }
}

private class TriangleSceneItem : SceneItem {
private:
    PointF _p1;
    PointF _p2;
    PointF _p3;
    uint _color;

public:
    this(PointF p1, PointF p2, PointF p3, uint color) {
        _p1 = p1;
        _p2 = p2;
        _p3 = p3;
        _color = color;
    }
    override void draw() {
        glSupport.queue.addTriangle(_p1, _p2, _p3, _color, _color, _color);
    }
}

private class SolidRectSceneItem : SceneItem {
private:
    Rect _rc;
    uint _color;

public:
    this(Rect rc, uint color) {
        _rc = rc;
        _color = color;
    }
    override void draw() {
        glSupport.queue.addSolidRect(_rc, _color);
    }
}

private class GradientRectSceneItem : SceneItem {
private:
    Rect _rc;
    uint _color1;
    uint _color2;
    uint _color3;
    uint _color4;

public:
    this(Rect rc, uint color1, uint color2, uint color3, uint color4) {
        _rc = rc;
        _color1 = color1;
        _color2 = color2;
        _color3 = color3;
        _color4 = color4;
    }
    override void draw() {
        glSupport.queue.addGradientRect(_rc, _color1, _color2, _color3, _color4);
    }
}

private class PatternRectSceneItem : SceneItem {
private:
    Rect _rc;
    uint _color;
    int _pattern;

public:
    this(Rect rc, uint color, int pattern) {
        _rc = rc;
        _color = color;
        _pattern = pattern;
    }
    override void draw() {
        // TODO: support patterns
        // TODO: optimize
        for (int y = _rc.top; y < _rc.bottom; y++) {
            for (int x = _rc.left; x < _rc.right; x++)
                if ((x ^ y) & 1) {
                    glSupport.queue.addSolidRect(Rect(x, y, x + 1, y + 1), _color);
                }
        }
    }
}

private class TextureSceneItem : SceneItem {
private:
    uint objectId;
    //CacheableObject * img;
    Rect dstrc;
    Rect srcrc;
    uint color;
    uint options;
    Rect * clip;

public:
    override void draw() {
        if (glImageCache)
            glImageCache.drawItem(objectId, dstrc, srcrc, color, options, clip);
    }

    this(uint _objectId, Rect _dstrc, Rect _srcrc, uint _color, uint _options, Rect * _clip)
    {
        objectId = _objectId;
        dstrc = _dstrc;
        srcrc = _srcrc;
        color = _color;
        options = _options;
        clip = _clip;
    }
}

/// character glyph
private class GlyphSceneItem : SceneItem {
private:
    uint objectId;
    Rect dstrc;
    Rect srcrc;
    uint color;
    Rect * clip;

public:
    override void draw() {
        if (glGlyphCache)
            glGlyphCache.drawItem(objectId, dstrc, srcrc, color, clip);
    }
    this(uint _objectId, Rect _dstrc, Rect _srcrc, uint _color, Rect * _clip)
    {
        objectId = _objectId;
        dstrc = _dstrc;
        srcrc = _srcrc;
        color = _color;
        clip = _clip;
    }
}

private class CustomDrawnSceneItem : SceneItem {
private:
    Rect _windowRect;
    Rect _rc;
    OpenGLDrawableDelegate _handler;

public:
    this(Rect windowRect, Rect rc, OpenGLDrawableDelegate handler) {
        _windowRect = windowRect;
        _rc = rc;
        _handler = handler;
    }
    override void draw() {
        if (_handler) {
            glSupport.queue.flush();
            glSupport.setOrthoProjection(_windowRect, _rc);
            glSupport.clearDepthBuffer();
            _handler(_windowRect, _rc);
            glSupport.setOrthoProjection(_windowRect, _windowRect);
        }
    }
}

/// GL Texture object from image
static class GLTexture : RefCountedObject {
    protected string _resourceId;
    protected int _dx;
    protected int _dy;
    protected int _tdx;
    protected int _tdy;

    @property Point imageSize() {
        return Point(_dx, _dy);
    }

    protected Tex2D _texture;
    /// returns texture object
    @property Tex2D texture() { return _texture; }
    /// returns texture id
    @property uint textureId() { return _texture ? _texture.ID : 0; }

    bool isValid() {
        return _texture && _texture.ID;
    }
    /// image coords to UV
    float[2] uv(int x, int y) {
        float[2] res;
        res[0] = cast(float)x / _tdx;
        res[1] = cast(float)y / _tdy;
        return res;
    }
    float[2] uv(Point pt) {
        float[2] res;
        res[0] = cast(float)pt.x / _tdx;
        res[1] = cast(float)pt.y / _tdy;
        return res;
    }
    /// return UV coords for bottom right corner
    float[2] uv() {
        return uv(_dx, _dy);
    }

    this(string resourceId, int mipmapLevels = 0) {
        import dlangui.graphics.resources;
        _resourceId = resourceId;
        string path = drawableCache.findResource(resourceId);
        this(cast(ColorDrawBuf)imageCache.get(path), mipmapLevels);
    }

    this(ColorDrawBuf buf, int mipmapLevels = 0) {
        if (buf) {
            _dx = buf.width;
            _dy = buf.height;
            _tdx = correctTextureSize(_dx);
            _tdy = correctTextureSize(_dy);
            _texture = new Tex2D();
            if (!_texture.ID) {
                _texture = null;
                return;
            }
            uint * pixels = buf.scanLine(0);
            buf.invertAlphaAndByteOrder();
            if (!glSupport.setTextureImage(_texture, buf.width, buf.height, cast(ubyte*)pixels, mipmapLevels)) {
                destroy(_texture);
                _texture = null;
                buf.invertAlphaAndByteOrder();
                return;
            }
            buf.invertAlphaAndByteOrder();
        }
    }

    ~this() {
        import std.string : empty;
        if (!_resourceId.empty)
            GLTextureCache.instance.onItemRemoved(_resourceId);
        if (_texture && _texture.ID != 0) {
            destroy(_texture);
            _texture = null;
        }
    }
}

/// Cache for GLTexture
class GLTextureCache {
    protected GLTexture[string] _map;

    static __gshared GLTextureCache _instance;

    static @property GLTextureCache instance() {
        if (!_instance)
            _instance = new GLTextureCache();
        return _instance;
    }

    private void onItemRemoved(string resourceId) {
        if (resourceId in _map) {
            _map.remove(resourceId);
        }
    }

    GLTexture get(string resourceId) {
        if (auto p = resourceId in _map) {
            return *p;
        }
        GLTexture tx = new GLTexture(resourceId, 6);
        _map[resourceId] = tx;
        return tx;
    }
}
