module dlangui.graphics.gldrawbuf;

import dlangui.graphics.drawbuf;
import dlangui.core.logger;
private import dlangui.graphics.glsupport;
private import std.algorithm;

/// drawing buffer - image container which allows to perform some drawing operations
class GLDrawBuf : DrawBuf {

    int _dx;
    int _dy;
    bool _framebuffer;
    Scene _scene;

    this(int dx, int dy, bool framebuffer = false) {
        _dx = dx;
        _dy = dy;
        _framebuffer = framebuffer;
    }

    /// returns current width
    @property override int width() { return _dx; }
    /// returns current height
    @property override int height() { return _dy; }

    /// reserved for hardware-accelerated drawing - begins drawing batch
    override void beforeDrawing() {
        if (_scene !is null) {
            destroy(_scene);
            _scene = null;
        }
        _scene = new Scene();
    }

    /// reserved for hardware-accelerated drawing - ends drawing batch
    override void afterDrawing() { 
        setOrthoProjection(_dx, _dy);
        _scene.draw();
        flushGL();
    }

    /// resize buffer
    override void resize(int width, int height) {
        _dx = width;
        _dy = height;
    }

    /// fill the whole buffer with solid color (no clipping applied)
    override void fill(uint color) {
        assert(_scene !is null);
        _scene.add(new SolidRectSceneItem(Rect(0, 0, _dx, _dy), color));
    }
    /// fill rectangle with solid color (clipping is applied)
    override void fillRect(Rect rc, uint color) {
        assert(_scene !is null);
        _scene.add(new SolidRectSceneItem(rc, color));
    }
    /// draw 8bit alpha image - usually font glyph using specified color (clipping is applied)
	override void drawGlyph(int x, int y, ubyte[] src, int srcdx, int srcdy, uint color) {
        assert(_scene !is null);
    }
    /// draw source buffer rectangle contents to destination buffer
    override void drawFragment(int x, int y, DrawBuf src, Rect srcrect) {
        assert(_scene !is null);
        Rect dstrect = Rect(x, y, x + srcrect.width, y + srcrect.height);
        //Log.v("GLDrawBuf.frawFragment dst=", dstrect, " src=", srcrect);
        if (applyClipping(dstrect, srcrect)) {
            GLImageCacheItem item = glImageCache.get(src.id);
            if (item is null)
                item = glImageCache.set(src);
            // TODO: clipping
            _scene.add(new TextureSceneItem(src.id, dstrect, srcrect, 0xFFFFFF, 0, null, 0));
        }
    }
    /// draw source buffer rectangle contents to destination buffer rectangle applying rescaling
    override void drawRescaled(Rect dstrect, DrawBuf src, Rect srcrect) {
        assert(_scene !is null);
        //Log.v("GLDrawBuf.frawRescaled dst=", dstrect, " src=", srcrect);
        if (applyClipping(dstrect, srcrect)) {
            GLImageCacheItem item = glImageCache.get(src.id);
            if (item is null)
                item = glImageCache.set(src);
            _scene.add(new TextureSceneItem(src.id, dstrect, srcrect, 0xFFFFFF, 0, null, 0));
        }
    }
    override void clear() {
    }
    ~this() { clear(); }
}


private class GLImageCacheItem {
    GLImageCachePage _page;
public:
    @property GLImageCachePage page() { return _page; }
    uint _objectId;
    // image size
    Rect _rc;
    bool _deleted;
    this(GLImageCachePage page, uint objectId) { _page = page; _objectId = objectId; }
};

class SceneItem {
    abstract void draw();
}

// non thread safe
class Scene {
    this() {
        activeSceneCount++;
    }
    ~this() {
        activeSceneCount--;
    }
    SceneItem[] _items;
    void add(SceneItem item) {
        _items ~= item;
    }
    void draw() {
        foreach(SceneItem item; _items)
            item.draw();
        _items.clear();
    }
}

class SolidRectSceneItem : SceneItem {
    Rect _rc;
    uint _color;
    this(Rect rc, uint color) {
        _rc = rc;
        _color = color;
    }
    override void draw() {
        drawSolidFillRect(_rc, _color, _color, _color, _color);
    }
}

private __gshared int activeSceneCount = 0;
bool hasActiveScene() {
    return activeSceneCount > 0;
}

private class GLImageCache {
    GLImageCacheItem[uint] _map;
    GLImageCachePage[] _pages;
    GLImageCachePage _activePage;
    int tdx;
    int tdy;
    void removePage(GLImageCachePage page) {
        if (_activePage == page)
            _activePage = null;
        for (int i = 0; i < _pages.length; i++)
            if (_pages[i] == page) {
                _pages.remove(i);
                break;
            }
        destroy(page);
    }
    void updateTextureSize() {
        if (!tdx) {
            // TODO
            tdx = tdy = 1024; //getMaxTextureSize(); 
            if (tdx > 1024)
                tdx = tdy = 1024;
        }
    }
public:
    this() {
    }
    ~this() {
        clear();
    }
    GLImageCacheItem get(uint obj) {
        if (obj in _map)
            return _map[obj];
        return null;
    }
    GLImageCacheItem set(DrawBuf img) {
        updateTextureSize();
        GLImageCacheItem res = null;
        if (img.width <= tdx / 3 && img.height < tdy / 3) {
            // trying to reuse common page for small images
            if (_activePage is null) {
                _activePage = new GLImageCachePage(this, tdx, tdy);
                _pages ~= _activePage;
            }
            res = _activePage.addItem(img);
            if (!res) {
                _activePage = new GLImageCachePage(this, tdx, tdy);
                _pages ~= _activePage;
                res = _activePage.addItem(img);
            }
        } else {
            // use separate page for big image
            GLImageCachePage page = new GLImageCachePage(this, img.width, img.height);
            _pages ~= page;
            res = page.addItem(img);
            page.close();
        }
        _map[img.id] = res;
        return res;
    }
    void clear() {
        for (int i = 0; i < _pages.length; i++) {
            destroy(_pages[i]);
            _pages[i] = null;
        }
        _pages.clear();
        _map.clear();
    }
    /// draw cached item
    void drawItem(uint objectId, Rect dstrc, Rect srcrc, uint color, int options, Rect * clip, int rotationAngle) {
        if (objectId in _map) {
            GLImageCacheItem item = _map[objectId];
            item.page.drawItem(item, dstrc, srcrc, color, options, clip, rotationAngle);
        }
    }
    /// handle cached object deletion, mark as deleted
    void onCachedObjectDeleted(uint objectId) {
        if (objectId in _map) {
            GLImageCacheItem item = _map[objectId];
            if (hasActiveScene()) {
                item._deleted = true;
            } else {
                int itemsLeft = item.page.deleteItem(item);
                //CRLog::trace("itemsLeft = %d", itemsLeft);
                if (itemsLeft <= 0) {
                    //CRLog::trace("removing page");
                    removePage(item.page);
                }
                _map.remove(objectId);
                delete item;
            }
        }
    }
    /// remove deleted items - remove page if contains only deleted items
    void removeDeletedItems() {
        uint[] list;
        foreach (GLImageCacheItem item; _map) {
            if (item._deleted)
                list ~= item._objectId;
        }
        for (int i = 0 ; i < list.length; i++) {
            onCachedObjectDeleted(list[i]);
        }
    }
};

immutable int MIN_TEX_SIZE = 64;
immutable int MAX_TEX_SIZE  = 4096;
int nearestPOT(int n) {
    for (int i = MIN_TEX_SIZE; i <= MAX_TEX_SIZE; i *= 2) {
		if (n <= i)
			return i;
	}
	return MIN_TEX_SIZE;
}

/// object deletion listener callback function type
void onObjectDestroyedCallback(uint pobject) {
	glImageCache.onCachedObjectDeleted(pobject);
}

private __gshared GLImageCache glImageCache;

shared static this() {
    glImageCache = new GLImageCache();
}

void LVGLClearImageCache() {
	glImageCache.clear();
}

private class GLImageCachePage {
	GLImageCache _cache;
	int _tdx;
	int _tdy;
	ColorDrawBuf _drawbuf;
	int _currentLine;
	int _nextLine;
	int _x;
	bool _closed;
	bool _needUpdateTexture;
    uint _textureId;
	int _itemCount;
public:
	this(GLImageCache cache, int dx, int dy) {
        _cache = cache;
        Log.v("created image cache page ", dx, "x", dy);
		_tdx = nearestPOT(dx);
		_tdy = nearestPOT(dy);
		_itemCount = 0;
    }

	~this() {
		if (_drawbuf) {
			destroy(_drawbuf);
            _drawbuf = null;
        }
        if (_textureId != 0) {
            deleteTexture(_textureId);
            _textureId = 0;
        }
	}

    void updateTexture() {
		if (_drawbuf is null)
			return; // no draw buffer!!!
	    if (_textureId == 0) {
	    	//CRLog::debug("updateTexture - new texture");
            _textureId = genTexture();
            if (!_textureId)
                return;
	    }
    	//CRLog::debug("updateTexture - setting image %dx%d", _drawbuf.width, _drawbuf.height);
        uint * pixels = _drawbuf.scanLine(0);
        if (!setTextureImage(_textureId, _drawbuf.width, _drawbuf.height, cast(ubyte*)pixels)) {
            deleteTexture(_textureId);
            _textureId = 0;
            return;
        }
	    _needUpdateTexture = false;
	    if (_closed) {
	    	destroy(_drawbuf);
	    	_drawbuf = null;
	    }
	}
	void invertAlpha(GLImageCacheItem item) {
        Rect rc = item._rc;
	    for (int y = rc.top; y < rc.bottom; y++) {
	    	uint * row = _drawbuf.scanLine(y);
	    	for (int x = rc.left; x < rc.right; x++) {
	    		uint cl = row[x];
	    		cl ^= 0xFF000000;
	    		uint r = (cl & 0x00FF0000) >> 16;
	    		uint b = (cl & 0x000000FF) << 16;
	    		row[x] = (cl & 0xFF00FF00) | r | b;
	    	}
	    }
	}
	GLImageCacheItem reserveSpace(uint objectId, int width, int height) {
		GLImageCacheItem cacheItem = new GLImageCacheItem(this, objectId);
		if (_closed)
			return null;

		// next line if necessary
		if (_x + width + 2 > _tdx) {
			// move to next line
			_currentLine = _nextLine;
			_x = 0;
		}
		// check if no room left for glyph height
		if (_currentLine + height + 2 > _tdy) {
			_closed = true;
			return null;
		}
        cacheItem._rc = Rect(_x + 1, _currentLine + 1, _x + width + 1, _currentLine + height + 1);
		if (height && width) {
			if (_nextLine < _currentLine + height + 2)
				_nextLine = _currentLine + height + 2;
			if (!_drawbuf) {
				_drawbuf = new ColorDrawBuf(_tdx, _tdy);
				//_drawbuf.SetBackgroundColor(0x000000);
				//_drawbuf.SetTextColor(0xFFFFFF);
				_drawbuf.fill(0xFF000000);
			}
			_x += width + 1;
			_needUpdateTexture = true;
		}
		_itemCount++;
		return cacheItem;
	}
	int deleteItem(GLImageCacheItem item) {
        _itemCount--;
		return _itemCount;
	}
	GLImageCacheItem addItem(DrawBuf buf) {
		GLImageCacheItem cacheItem = reserveSpace(buf.id, buf.width, buf.height);
		if (cacheItem is null)
			return null;
		buf.onDestroyCallback = &onObjectDestroyedCallback;
        _drawbuf.drawImage(cacheItem._rc.left, cacheItem._rc.top, buf);
		invertAlpha(cacheItem);
		_needUpdateTexture = true;
		return cacheItem;
	}
    void drawItem(GLImageCacheItem item, Rect dstrc, Rect srcrc, uint color, uint options, Rect * clip, int rotationAngle) {
        //CRLog::trace("drawing item at %d,%d %dx%d <= %d,%d %dx%d ", x, y, dx, dy, srcx, srcy, srcdx, srcdy);
        if (_needUpdateTexture)
			updateTexture();
		if (_textureId != 0) {
            if (!isTexture(_textureId)) {
            Log.e("Invalid texture ", _textureId);
                return;
            }
            //rotationAngle = 0;
            int rx = dstrc.middlex;
            int ry = dstrc.middley;
            if (rotationAngle) {
                //rotationAngle = 0;
                //setRotation(rx, ry, rotationAngle);
            }
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
                drawColorAndTextureRect(_textureId, _tdx, _tdy, srcrc, dstrc, color, srcrc.width() != dstrc.width() || srcrc.height() != dstrc.height());
            //drawColorAndTextureRect(vertices, texcoords, color, _textureId);

            if (rotationAngle) {
                // unset rotation
                setRotation(rx, ry, 0);
                //                glMatrixMode(GL_PROJECTION);
                //                glPopMatrix();
                //                checkError("pop matrix");
            }

        }
	}
	void close() {
		_closed = true;
		if (_needUpdateTexture)
			updateTexture();
	}
};


private class TextureSceneItem : SceneItem {
	uint objectId;
    //CacheableObject * img;
    Rect dstrc;
    Rect srcrc;
	uint color;
	uint options;
	Rect * clip;
    int rotationAngle;
public:
	override void draw() {
		if (glImageCache)
            glImageCache.drawItem(objectId, dstrc, srcrc, color, options, clip, rotationAngle);
	}
    this(uint _objectId, Rect _dstrc, Rect _srcrc, uint _color, uint _options, Rect * _clip, int _rotationAngle)
	{
        objectId = _objectId;
        dstrc = _dstrc;
        srcrc = _srcrc;
        color = _color;
        options = _options;
        clip = _clip;
        rotationAngle = _rotationAngle;
	}
	~this() {
	}
};

