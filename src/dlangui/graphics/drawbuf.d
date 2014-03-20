module dlangui.graphics.drawbuf;

public import dlangui.core.types;
import dlangui.core.logger;

/// blend two RGB pixels using alpha
uint blendARGB(uint dst, uint src, uint alpha) {
    uint dstalpha = dst >> 24;
    if (dstalpha > 0x80)
        return src;
    uint srcr = (src >> 16) & 0xFF;
    uint srcg = (src >> 8) & 0xFF;
    uint srcb = (src >> 0) & 0xFF;
    uint dstr = (dst >> 16) & 0xFF;
    uint dstg = (dst >> 8) & 0xFF;
    uint dstb = (dst >> 0) & 0xFF;
    uint ialpha = 256 - alpha;
    uint r = ((srcr * ialpha + dstr * alpha) >> 8) & 0xFF;
    uint g = ((srcg * ialpha + dstg * alpha) >> 8) & 0xFF;
    uint b = ((srcb * ialpha + dstb * alpha) >> 8) & 0xFF;
    return (r << 16) | (g << 8) | b;
}

ubyte rgbToGray(uint color) {
    uint srcr = (color >> 16) & 0xFF;
    uint srcg = (color >> 8) & 0xFF;
    uint srcb = (color >> 0) & 0xFF;
    return cast(uint)(((srcr + srcg + srcg + srcb) >> 2) & 0xFF);
}

/// blend two RGB pixels using alpha
ubyte blendGray(ubyte dst, ubyte src, uint alpha) {
    uint ialpha = 256 - alpha;
    return cast(ubyte)(((src * ialpha + dst * alpha) >> 8) & 0xFF);
}

/**
 * 9-patch image scaling information (see Android documentation).
 *
 * 
 */
struct NinePatch {
    /// frame (non-scalable) part size for left, top, right, bottom edges.
    Rect frame;
    /// padding (distance to content area) for left, top, right, bottom edges.
    Rect padding;
}

version (USE_OPENGL) {
    /// non thread safe
    private __gshared uint drawBufIdGenerator = 0;
}

/// drawing buffer - image container which allows to perform some drawing operations
class DrawBuf : RefCountedObject {
    protected Rect _clipRect;
    protected NinePatch * _ninePatch;

    version (USE_OPENGL) {
        protected uint _id;
        /// unique ID of drawbug instance, for using with hardware accelerated rendering for caching
        @property uint id() { return _id; }
    }

    this() {
        version (USE_OPENGL) {
            _id = drawBufIdGenerator++;
        }
    }
    protected void function(uint) _onDestroyCallback;
    @property void onDestroyCallback(void function(uint) callback) { _onDestroyCallback = callback; }
    @property void function(uint) onDestroyCallback() { return _onDestroyCallback; }

    // ===================================================
    // 9-patch functions (image scaling using 9-patch markup - unscaled frame and scaled middle parts).
    // See Android documentation for details.

    /// get nine patch information pointer, null if this is not a nine patch image buffer
    @property const (NinePatch) * ninePatch() const { return _ninePatch; }
    /// set nine patch information pointer, null if this is not a nine patch image buffer
    @property void ninePatch(NinePatch * ninePatch) { _ninePatch = ninePatch; }
    /// check whether there is nine-patch information available for drawing buffer
    @property bool hasNinePatch() { return _ninePatch !is null; }
    /// override to detect nine patch using image 1-pixel border; returns true if 9-patch markup is found in image.
    bool detectNinePatch() { return false; }

    /// returns current width
    @property int width() { return 0; }
    /// returns current height
    @property int height() { return 0; }

    // ===================================================
    // clipping rectangle functions

    /// returns clipping rectangle, when clipRect.isEmpty == true -- means no clipping.
    @property ref Rect clipRect() { return _clipRect; }
    /// sets new clipping rectangle, when clipRect.isEmpty == true -- means no clipping.
    @property void clipRect(const ref Rect rect) { 
        _clipRect = rect; 
        _clipRect.intersect(Rect(0, 0, width, height));
    }
    /// apply clipRect and buffer bounds clipping to rectangle
    bool applyClipping(ref Rect rc) {
        if (!_clipRect.empty())
            rc.intersect(_clipRect);
        if (rc.left < 0)
            rc.left = 0;
        if (rc.top < 0)
            rc.top = 0;
        if (rc.right > width)
            rc.right = width;
        if (rc.bottom > height)
            rc.bottom = height;
        return !rc.empty();
    }
    /// apply clipRect and buffer bounds clipping to rectangle; if clippinup applied to first rectangle, reduce second rectangle bounds proportionally.
    bool applyClipping(ref Rect rc, ref Rect rc2) {
        if (rc.empty || rc2.empty)
            return false;
        if (!_clipRect.empty())
            if (!rc.intersects(_clipRect))
                return false;
        if (rc.width == rc2.width && rc.height == rc2.height) {
            // unscaled
            if (!_clipRect.empty()) {
                if (rc.left < _clipRect.left) {
                    rc2.left += _clipRect.left - rc.left;
                    rc.left = _clipRect.left;
                }
                if (rc.top < _clipRect.top) {
                    rc2.top += _clipRect.top - rc.top;
                    rc.top = _clipRect.top;
                }
                if (rc.right > _clipRect.left) {
                    rc2.right -= rc.right - _clipRect.left;
                    rc.right = _clipRect.right;
                }
                if (rc.bottom > _clipRect.bottom) {
                    rc2.bottom -= rc.bottom - _clipRect.bottom;
                    rc.bottom = _clipRect.bottom;
                }
            }
            if (rc.left < 0) {
                rc2.left += -rc.left;
                rc.left = 0;
            }
            if (rc.top < 0) {
                rc2.top += -rc.top;
                rc.top = 0;
            }
            if (rc.right > width) {
                rc2.right -= rc.right - width;
                rc.right = width;
            }
            if (rc.bottom > height) {
                rc2.bottom -= rc.bottom - height;
                rc.bottom = height;
            }
        } else {
            // scaled
            int dstdx = rc.width;
            int dstdy = rc.height;
            int srcdx = rc2.width;
            int srcdy = rc2.height;
            if (!_clipRect.empty()) {
                if (rc.left < _clipRect.left) {
                    rc2.left += (_clipRect.left - rc.left) * srcdx / dstdx;
                    rc.left = _clipRect.left;
                }
                if (rc.top < _clipRect.top) {
                    rc2.top += (_clipRect.top - rc.top) * srcdy / dstdy;
                    rc.top = _clipRect.top;
                }
                if (rc.right > _clipRect.left) {
                    rc2.right -= (rc.right - _clipRect.left) * srcdx / dstdx;
                    rc.right = _clipRect.right;
                }
                if (rc.bottom > _clipRect.bottom) {
                    rc2.bottom -= (rc.bottom - _clipRect.bottom) * srcdy / dstdy;
                    rc.bottom = _clipRect.bottom;
                }
            }
            if (rc.left < 0) {
                rc2.left -= (rc.left) * srcdx / dstdx;
                rc.left = 0;
            }
            if (rc.top < 0) {
                rc2.top -= (rc.top) * srcdy / dstdy;
                rc.top = 0;
            }
            if (rc.right > width) {
                rc2.right -= (rc.right - width) * srcdx / dstdx;
                rc.right = width;
            }
            if (rc.bottom > height) {
                rc2.bottom -= (rc.bottom - height) * srcdx / dstdx;
                rc.bottom = height;
            }
        }
        return !rc.empty() && !rc2.empty();
    }
    /// reserved for hardware-accelerated drawing - begins drawing batch
    void beforeDrawing() { }
    /// reserved for hardware-accelerated drawing - ends drawing batch
    void afterDrawing() { }
    /// returns buffer bits per pixel
    @property int bpp() { return 0; }
    // returns pointer to ARGB scanline, null if y is out of range or buffer doesn't provide access to its memory
    //uint * scanLine(int y) { return null; }
    /// resize buffer
    abstract void resize(int width, int height);

    //========================================================
    // Drawing methods.

    /// fill the whole buffer with solid color (no clipping applied)
    abstract void fill(uint color);
    /// fill rectangle with solid color (clipping is applied)
    abstract void fillRect(Rect rc, uint color);
    /// draw 8bit alpha image - usually font glyph using specified color (clipping is applied)
	abstract void drawGlyph(int x, int y, Glyph * glyph, uint color);
    /// draw source buffer rectangle contents to destination buffer
    abstract void drawFragment(int x, int y, DrawBuf src, Rect srcrect);
    /// draw source buffer rectangle contents to destination buffer rectangle applying rescaling
    abstract void drawRescaled(Rect dstrect, DrawBuf src, Rect srcrect);
    /// draw unscaled image at specified coordinates
    void drawImage(int x, int y, DrawBuf src) {
        drawFragment(x, y, src, Rect(0, 0, src.width, src.height));
    }
    void clear() {}
    ~this() { clear(); }
}

alias DrawBufRef = Ref!DrawBuf;

/// RAII setting/restoring of clip rectangle
struct ClipRectSaver {
    DrawBuf _buf;
    Rect _oldClipRect;
    this(DrawBuf buf, Rect newClipRect) {
        _buf = buf;
        _oldClipRect = buf.clipRect;
        buf.clipRect = newClipRect;
    }
    ~this() {
        _buf.clipRect = _oldClipRect;
    }
}

class ColorDrawBufBase : DrawBuf {
    int _dx;
    int _dy;
    /// returns buffer bits per pixel
    override @property int bpp() { return 32; }
    @property override int width() { return _dx; }
    @property override int height() { return _dy; }

    /// returns pointer to ARGB scanline, null if y is out of range or buffer doesn't provide access to its memory
    uint * scanLine(int y) { return null; }

    /// draw source buffer rectangle contents to destination buffer
    override void drawFragment(int x, int y, DrawBuf src, Rect srcrect) {
        Rect dstrect = Rect(x, y, x + srcrect.width, y + srcrect.height);
        if (applyClipping(dstrect, srcrect)) {
            if (src.applyClipping(srcrect, dstrect)) {
                int dx = srcrect.width;
                int dy = srcrect.height;
                ColorDrawBufBase colorDrawBuf = cast(ColorDrawBufBase) src;
                if (colorDrawBuf !is null) {
                    for (int yy = 0; yy < dy; yy++) {
                        uint * srcrow = colorDrawBuf.scanLine(srcrect.top + yy) + srcrect.left;
                        uint * dstrow = scanLine(dstrect.top + yy) + dstrect.left;
                        for (int i = 0; i < dx; i++) {
                            uint pixel = srcrow[i];
                            uint alpha = pixel >> 24;
                            if (!alpha)
                                dstrow[i] = pixel;
                            else if (alpha < 255) {
                                // apply blending
                                dstrow[i] = blendARGB(dstrow[i], pixel, alpha);
                            }
                        }

                    }
                }
            }
        }
    }

    /// Create mapping of source coordinates to destination coordinates, for resize.
    private int[] createMap(int dst0, int dst1, int src0, int src1) {
        int dd = dst1 - dst0;
        int sd = src1 - src0;
        int[] res = new int[dd];
        for (int i = 0; i < dd; i++)
            res[i] = src0 + i * sd / dd;
        return res;
    }
    /// draw source buffer rectangle contents to destination buffer rectangle applying rescaling
    override void drawRescaled(Rect dstrect, DrawBuf src, Rect srcrect) {
        //Log.d("drawRescaled ", dstrect, " <- ", srcrect);
        if (applyClipping(dstrect, srcrect)) {
            int[] xmap = createMap(dstrect.left, dstrect.right, srcrect.left, srcrect.right);
            int[] ymap = createMap(dstrect.top, dstrect.bottom, srcrect.top, srcrect.bottom);
            int dx = dstrect.width;
            int dy = dstrect.height;
            ColorDrawBufBase colorDrawBuf = cast(ColorDrawBufBase) src;
            if (colorDrawBuf !is null) {
                for (int y = 0; y < dy; y++) {
                    uint * srcrow = colorDrawBuf.scanLine(ymap[y]);
                    uint * dstrow = scanLine(dstrect.top + y) + dstrect.left;
                    for (int x = 0; x < dx; x++) {
                        uint srcpixel = srcrow[xmap[x]];
                        uint dstpixel = dstrow[x];
                        uint alpha = (srcpixel >> 24) & 255;
                        if (!alpha)
                            dstrow[x] = srcpixel;
                        else if (alpha < 255) {
                            // apply blending
                            dstrow[x] = blendARGB(dstpixel, srcpixel, alpha);
                        }
                    }
                }
            }
        }
    }

    /// detect position of black pixels in row for 9-patch markup
    private bool detectHLine(int y, ref int x0, ref int x1) {
        uint * line = scanLine(y);
    	bool foundUsed = false;
        x0 = 0;
        x1 = 0;
    	for (int x = 1; x < _dx - 1; x++) {
    		if (isBlackPixel(line[x])) { // opaque black pixel
    			if (!foundUsed) {
    				x0 = x;
        			foundUsed = true;
    			}
    			x1 = x + 1;
    		}
    	}
        return x1 > x0;
    }

	static bool isBlackPixel(uint c) {
		if (((c >> 24) & 255) > 10)
			return false;
		if (((c >> 16) & 255) > 10)
			return false;
		if (((c >> 8) & 255) > 10)
			return false;
		if (((c >> 0) & 255) > 10)
			return false;
		return true;
	}
	
    /// detect position of black pixels in column for 9-patch markup
    private bool detectVLine(int x, ref int y0, ref int y1) {
    	bool foundUsed = false;
        y0 = 0;
        y1 = 0;
    	for (int y = 1; y < _dy - 1; y++) {
            uint * line = scanLine(y);
    		if (isBlackPixel(line[x])) { // opaque black pixel
    			if (!foundUsed) {
    				y0 = y;
        			foundUsed = true;
    			}
    			y1 = y + 1;
    		}
    	}
        return y1 > y0;
    }
    /// detect nine patch using image 1-pixel border (see Android documentation)
    override bool detectNinePatch() {
        if (_dx < 3 || _dy < 3)
            return false; // image is too small
        int x00, x01, x10, x11, y00, y01, y10, y11;
        bool found = true;
        found = found && detectHLine(0, x00, x01);
        found = found && detectHLine(_dy - 1, x10, x11);
        found = found && detectVLine(0, y00, y01);
        found = found && detectVLine(_dx - 1, y10, y11);
        if (!found)
            return false; // no black pixels on 1-pixel frame
        NinePatch * p = new NinePatch();
        p.frame.left = x00 - 1;
        p.frame.right = _dx - x01 - 1;
        p.frame.top = y00 - 1;
        p.frame.bottom = _dy - y01 - 1;
        p.padding.left = x10 - 1;
        p.padding.right = _dx - x11 - 1;
        p.padding.top = y10 - 1;
        p.padding.bottom = _dy - y11 - 1;
        _ninePatch = p;
		//Log.d("NinePatch detected: frame=", p.frame, " padding=", p.padding, " left+right=", p.frame.left + p.frame.right, " dx=", _dx);
        return true;
    }
	override void drawGlyph(int x, int y, Glyph * glyph, uint color) {
        ubyte[] src = glyph.glyph;
        int srcdx = glyph.blackBoxX;
        int srcdy = glyph.blackBoxY;
		bool clipping = !_clipRect.empty();
		for (int yy = 0; yy < srcdy; yy++) {
			int liney = y + yy;
			if (clipping && (liney < _clipRect.top || liney >= _clipRect.bottom))
				continue;
			if (liney < 0 || liney >= _dy)
				continue;
			uint * row = scanLine(liney);
			ubyte * srcrow = src.ptr + yy * srcdx;
			for (int xx = 0; xx < srcdx; xx++) {
				int colx = xx + x;
				if (clipping && (colx < _clipRect.left || colx >= _clipRect.right))
					continue;
				if (colx < 0 || colx >= _dx)
					continue;
				uint alpha1 = srcrow[xx] ^ 255;
				uint alpha2 = (color >> 24);
				uint alpha = ((((alpha1 ^ 255) * (alpha2 ^ 255)) >> 8) ^ 255) & 255;
				uint pixel = row[colx];
				if (!alpha)
					row[colx] = pixel;
				else if (alpha < 255) {
					// apply blending
					row[colx] = blendARGB(pixel, color, alpha);
				}
			}
		}
	}
    override void fillRect(Rect rc, uint color) {
        if (applyClipping(rc)) {
            for (int y = rc.top; y < rc.bottom; y++) {
                uint * row = scanLine(y);
                uint alpha = color >> 24;
                for (int x = rc.left; x < rc.right; x++) {
                    if (!alpha)
                        row[x] = color;
                    else if (alpha < 255) {
                        // apply blending
                        row[x] = blendARGB(row[x], color, alpha);
                    }
                }
            }
        }
    }
}

class GrayDrawBuf : DrawBuf {
    int _dx;
    int _dy;
    /// returns buffer bits per pixel
    override @property int bpp() { return 8; }
    @property override int width() { return _dx; }
    @property override int height() { return _dy; }

    ubyte[] _buf;
    this(int width, int height) {
        resize(width, height);
    }
    ubyte * scanLine(int y) {
        if (y >= 0 && y < _dy)
            return _buf.ptr + _dx * y;
        return null;
    }
    override void resize(int width, int height) {
        if (_dx == width && _dy == height)
            return;
        _dx = width;
        _dy = height;
        _buf.length = _dx * _dy;
    }
    override void fill(uint color) {
        int len = _dx * _dy;
        ubyte * p = _buf.ptr;
        ubyte cl = rgbToGray(color);
        for (int i = 0; i < len; i++)
            p[i] = cl;
    }

    /// draw source buffer rectangle contents to destination buffer
    override void drawFragment(int x, int y, DrawBuf src, Rect srcrect) {
        Rect dstrect = Rect(x, y, x + srcrect.width, y + srcrect.height);
        if (applyClipping(dstrect, srcrect)) {
            if (src.applyClipping(srcrect, dstrect)) {
                int dx = srcrect.width;
                int dy = srcrect.height;
                GrayDrawBuf grayDrawBuf = cast (GrayDrawBuf) src;
                if (grayDrawBuf !is null) {
                    for (int yy = 0; yy < dy; yy++) {
                        ubyte * srcrow = grayDrawBuf.scanLine(srcrect.top + yy) + srcrect.left;
                        ubyte * dstrow = scanLine(dstrect.top + yy) + dstrect.left;
                        for (int i = 0; i < dx; i++) {
                            ubyte pixel = srcrow[i];
                            dstrow[i] = pixel;
                        }
                    }
                }
            }
        }
    }

    /// Create mapping of source coordinates to destination coordinates, for resize.
    private int[] createMap(int dst0, int dst1, int src0, int src1) {
        int dd = dst1 - dst0;
        int sd = src1 - src0;
        int[] res = new int[dd];
        for (int i = 0; i < dd; i++)
            res[i] = src0 + i * sd / dd;
        return res;
    }
    /// draw source buffer rectangle contents to destination buffer rectangle applying rescaling
    override void drawRescaled(Rect dstrect, DrawBuf src, Rect srcrect) {
        //Log.d("drawRescaled ", dstrect, " <- ", srcrect);
        if (applyClipping(dstrect, srcrect)) {
            int[] xmap = createMap(dstrect.left, dstrect.right, srcrect.left, srcrect.right);
            int[] ymap = createMap(dstrect.top, dstrect.bottom, srcrect.top, srcrect.bottom);
            int dx = dstrect.width;
            int dy = dstrect.height;
            GrayDrawBuf grayDrawBuf = cast (GrayDrawBuf) src;
            if (grayDrawBuf !is null) {
                for (int y = 0; y < dy; y++) {
                    ubyte * srcrow = grayDrawBuf.scanLine(ymap[y]);
                    ubyte * dstrow = scanLine(dstrect.top + y) + dstrect.left;
                    for (int x = 0; x < dx; x++) {
                        ubyte srcpixel = srcrow[xmap[x]];
                        ubyte dstpixel = dstrow[x];
                        dstrow[x] = srcpixel;
                    }
                }
            }
        }
    }

    /// detect position of black pixels in row for 9-patch markup
    private bool detectHLine(int y, ref int x0, ref int x1) {
        ubyte * line = scanLine(y);
    	bool foundUsed = false;
        x0 = 0;
        x1 = 0;
    	for (int x = 1; x < _dx - 1; x++) {
    		if (line[x] == 0x00000000) { // opaque black pixel
    			if (!foundUsed) {
    				x0 = x;
        			foundUsed = true;
    			}
    			x1 = x + 1;
    		}
    	}
        return x1 > x0;
    }

    /// detect position of black pixels in column for 9-patch markup
    private bool detectVLine(int x, ref int y0, ref int y1) {
    	bool foundUsed = false;
        y0 = 0;
        y1 = 0;
    	for (int y = 1; y < _dy - 1; y++) {
            ubyte * line = scanLine(y);
    		if (line[x] == 0x00000000) { // opaque black pixel
    			if (!foundUsed) {
    				y0 = y;
        			foundUsed = true;
    			}
    			y1 = y + 1;
    		}
    	}
        return y1 > y0;
    }
    /// detect nine patch using image 1-pixel border (see Android documentation)
    override bool detectNinePatch() {
        if (_dx < 3 || _dy < 3)
            return false; // image is too small
        int x00, x01, x10, x11, y00, y01, y10, y11;
        bool found = true;
        found = found && detectHLine(0, x00, x01);
        found = found && detectHLine(_dy - 1, x10, x11);
        found = found && detectVLine(0, y00, y01);
        found = found && detectVLine(_dx - 1, y10, y11);
        if (!found)
            return false; // no black pixels on 1-pixel frame
        NinePatch * p = new NinePatch();
        p.frame.left = x00 - 1;
        p.frame.right = _dy - y01 - 1;
        p.frame.top = y00 - 1;
        p.frame.bottom = _dy - y01 - 1;
        p.padding.left = x10 - 1;
        p.padding.right = _dy - y11 - 1;
        p.padding.top = y10 - 1;
        p.padding.bottom = _dy - y11 - 1;
        _ninePatch = p;
        return true;
    }
	override void drawGlyph(int x, int y, Glyph * glyph, uint color) {
        ubyte[] src = glyph.glyph;
        int srcdx = glyph.blackBoxX;
        int srcdy = glyph.blackBoxY;
		bool clipping = !_clipRect.empty();
        ubyte cl = cast(ubyte)(color & 255);
		for (int yy = 0; yy < srcdy; yy++) {
			int liney = y + yy;
			if (clipping && (liney < _clipRect.top || liney >= _clipRect.bottom))
				continue;
			if (liney < 0 || liney >= _dy)
				continue;
			ubyte * row = scanLine(liney);
			ubyte * srcrow = src.ptr + yy * srcdx;
			for (int xx = 0; xx < srcdx; xx++) {
				int colx = xx + x;
				if (clipping && (colx < _clipRect.left || colx >= _clipRect.right))
					continue;
				if (colx < 0 || colx >= _dx)
					continue;
				uint alpha1 = srcrow[xx] ^ 255;
				uint alpha2 = (color >> 24);
				uint alpha = ((((alpha1 ^ 255) * (alpha2 ^ 255)) >> 8) ^ 255) & 255;
				uint pixel = row[colx];
				if (!alpha)
					row[colx] = cast(ubyte)pixel;
				else if (alpha < 255) {
					// apply blending
					row[colx] = cast(ubyte)blendARGB(pixel, color, alpha);
				}
			}
		}
	}
    override void fillRect(Rect rc, uint color) {
        ubyte cl = rgbToGray(color);
        if (applyClipping(rc)) {
            for (int y = rc.top; y < rc.bottom; y++) {
                ubyte * row = scanLine(y);
                uint alpha = color >> 24;
                for (int x = rc.left; x < rc.right; x++) {
                    if (!alpha)
                        row[x] = cl;
                    else if (alpha < 255) {
                        // apply blending
                        row[x] = blendGray(row[x], cl, alpha);
                    }
                }
            }
        }
    }
}

class ColorDrawBuf : ColorDrawBufBase {
    uint[] _buf;
    this(int width, int height) {
        resize(width, height);
    }
    override uint * scanLine(int y) {
        if (y >= 0 && y < _dy)
            return _buf.ptr + _dx * y;
        return null;
    }
    override void resize(int width, int height) {
        if (_dx == width && _dy == height)
            return;
        _dx = width;
        _dy = height;
        _buf.length = _dx * _dy;
    }
    override void fill(uint color) {
        int len = _dx * _dy;
        uint * p = _buf.ptr;
        for (int i = 0; i < len; i++)
            p[i] = color;
    }
}

class Drawable : RefCountedObject {
	//private static int _instanceCount;
	this() {
		//Log.d("Created drawable, count=", ++_instanceCount);
	}
	~this() {
		//Log.d("Destroyed drawable, count=", --_instanceCount);
	}
    abstract void drawTo(DrawBuf buf, Rect rc, int tilex0 = 0, int tiley0 = 0);
    @property abstract int width();
    @property abstract int height();
    @property Rect padding() { return Rect(0,0,0,0); }
}

class SolidFillDrawable : Drawable {
    protected uint _color;
    this(uint color) {
        _color = color;
    }
    override void drawTo(DrawBuf buf, Rect rc, int tilex0 = 0, int tiley0 = 0) {
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
    override void drawTo(DrawBuf buf, Rect rc, int tilex0 = 0, int tiley0 = 0) {
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

alias DrawableRef = Ref!Drawable;
