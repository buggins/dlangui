// Written in the D programming language.

/**
This module contains drawing buffer implementation.


Synopsis:

----
import dlangui.graphics.drawbuf;

----

Copyright: Vadim Lopatin, 2014
License:   Boost License 1.0
Authors:   Vadim Lopatin, coolreader.org@gmail.com
*/
module dlangui.graphics.drawbuf;

public import dlangui.core.config;
public import dlangui.core.types;
import dlangui.core.logger;
import dlangui.graphics.colors;

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

static if (ENABLE_OPENGL) {
    /// non thread safe
    private __gshared uint drawBufIdGenerator = 0;
}

/// Custom draw delegate for OpenGL direct drawing
alias OpenGLDrawableDelegate = void delegate(Rect windowRect, Rect rc);

/// drawing buffer - image container which allows to perform some drawing operations
class DrawBuf : RefCountedObject {
    protected Rect _clipRect;
    protected NinePatch * _ninePatch;
    protected uint _alpha;

    /// get current alpha setting (to be applied to all drawing operations)
    @property uint alpha() { return _alpha; }
    /// set new alpha setting (to be applied to all drawing operations)
    @property void alpha(uint alpha) {
        _alpha = alpha;
        if (_alpha > 0xFF)
            _alpha = 0xFF;
    }

    /// apply additional transparency to current drawbuf alpha value
    void addAlpha(uint alpha) {
        _alpha = blendAlpha(_alpha, alpha);
    }

    /// applies current drawbuf alpha to argb color value
    uint applyAlpha(uint argb) {
        if (!_alpha)
            return argb; // no drawbuf alpha
        uint a1 = (argb >> 24) & 0xFF;
        if (a1 == 0xFF)
            return argb; // fully transparent
        uint a2 = _alpha & 0xFF;
        uint a = blendAlpha(a1, a2);
        return (argb & 0xFFFFFF) | (a << 24);
    }

    static if (ENABLE_OPENGL) {
        protected uint _id;
        /// unique ID of drawbug instance, for using with hardware accelerated rendering for caching
        @property uint id() { return _id; }
    }

    this() {
        static if (ENABLE_OPENGL) {
            _id = drawBufIdGenerator++;
        }
        debug _instanceCount++;
    }

    debug private static __gshared int _instanceCount;
    debug @property static int instanceCount() { return _instanceCount; }
    ~this() {
        debug _instanceCount--;
        clear();
    }

    protected void function(uint) _onDestroyCallback;
    @property void onDestroyCallback(void function(uint) callback) { _onDestroyCallback = callback; }
    @property void function(uint) onDestroyCallback() { return _onDestroyCallback; }

    /// Call to remove this image from OpenGL cache when image is updated.
    void invalidate() {
        static if (ENABLE_OPENGL) {
            if (_onDestroyCallback) {
                // remove from cache
                _onDestroyCallback(_id);
                // assign new ID
                _id = drawBufIdGenerator++;
            }
        }
    }

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

    /// init clip rectangle to full buffer size
    void resetClipping() {
        _clipRect = Rect(0, 0, width, height);
    }
    @property bool hasClipping() {
        return _clipRect.left != 0 || _clipRect.top != 0 || _clipRect.right != width || _clipRect.bottom != height;
    }
    /// returns clipping rectangle, when clipRect.isEmpty == true -- means no clipping.
    @property ref Rect clipRect() { return _clipRect; }
    /// returns clipping rectangle, or (0,0,dx,dy) when no clipping.
    //@property Rect clipOrFullRect() { return _clipRect.empty ? Rect(0,0,width,height) : _clipRect; }
    /// sets new clipping rectangle, when clipRect.isEmpty == true -- means no clipping.
    @property void clipRect(const ref Rect rect) { 
        _clipRect = rect;
        _clipRect.intersect(Rect(0, 0, width, height));
    }
    /// sets new clipping rectangle, intersect with previous one.
    @property void intersectClipRect(const ref Rect rect) {
        //if (_clipRect.empty)
        //    _clipRect = rect;
        //else
        _clipRect.intersect(rect);
        _clipRect.intersect(Rect(0, 0, width, height));
    }
    /// returns true if rectangle is completely clipped out and cannot be drawn.
    @property bool isClippedOut(const ref Rect rect) {
        //Rect rc = clipOrFullRect();
        return !_clipRect.intersects(rect);
    }
    /// apply clipRect and buffer bounds clipping to rectangle
    bool applyClipping(ref Rect rc) {
        //if (!_clipRect.empty())
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
        //if (!_clipRect.empty())
        if (!rc.intersects(_clipRect))
            return false;
        if (rc.width == rc2.width && rc.height == rc2.height) {
            // unscaled
            //if (!_clipRect.empty) {
                if (rc.left < _clipRect.left) {
                    rc2.left += _clipRect.left - rc.left;
                    rc.left = _clipRect.left;
                }
                if (rc.top < _clipRect.top) {
                    rc2.top += _clipRect.top - rc.top;
                    rc.top = _clipRect.top;
                }
                if (rc.right > _clipRect.right) {
                    rc2.right -= rc.right - _clipRect.right;
                    rc.right = _clipRect.right;
                }
                if (rc.bottom > _clipRect.bottom) {
                    rc2.bottom -= rc.bottom - _clipRect.bottom;
                    rc.bottom = _clipRect.bottom;
                }
            //}
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
            //if (!_clipRect.empty) {
                if (rc.left < _clipRect.left) {
                    rc2.left += (_clipRect.left - rc.left) * srcdx / dstdx;
                    rc.left = _clipRect.left;
                }
                if (rc.top < _clipRect.top) {
                    rc2.top += (_clipRect.top - rc.top) * srcdy / dstdy;
                    rc.top = _clipRect.top;
                }
                if (rc.right > _clipRect.right) {
                    rc2.right -= (rc.right - _clipRect.right) * srcdx / dstdx;
                    rc.right = _clipRect.right;
                }
                if (rc.bottom > _clipRect.bottom) {
                    rc2.bottom -= (rc.bottom - _clipRect.bottom) * srcdy / dstdy;
                    rc.bottom = _clipRect.bottom;
                }
            //}
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
    void beforeDrawing() { _alpha = 0; }
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
    /// draw pixel at (x, y) with specified color 
    abstract void drawPixel(int x, int y, uint color);
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
    /// draws rectangle frame of specified color and widths (per side), and optinally fills inner area
    void drawFrame(Rect rc, uint frameColor, Rect frameSideWidths, uint innerAreaColor = 0xFFFFFFFF) {
        // draw frame
        if (!isFullyTransparentColor(frameColor)) {
            Rect r;
            // left side
            r = rc;
            r.right = r.left + frameSideWidths.left;
            if (!r.empty)
                fillRect(r, frameColor);
            // right side
            r = rc;
            r.left = r.right - frameSideWidths.right;
            if (!r.empty)
                fillRect(r, frameColor);
            // top side
            r = rc;
            r.left += frameSideWidths.left;
            r.right -= frameSideWidths.right;
            Rect rc2 = r;
            rc2.bottom = r.top + frameSideWidths.top;
            if (!rc2.empty)
                fillRect(rc2, frameColor);
            // bottom side
            rc2 = r;
            rc2.top = r.bottom - frameSideWidths.bottom;
            if (!rc2.empty)
                fillRect(rc2, frameColor);
        }
        // draw internal area
        if (!isFullyTransparentColor(innerAreaColor)) {
            rc.left += frameSideWidths.left;
            rc.top += frameSideWidths.top;
            rc.right -= frameSideWidths.right;
            rc.bottom -= frameSideWidths.bottom;
            if (!rc.empty)
                fillRect(rc, innerAreaColor);
        }
    }

    /// draw focus rectangle; vertical gradient supported - colors[0] is top color, colors[1] is bottom color
    void drawFocusRect(Rect rc, const uint[] colors) {
        // override for faster performance when using OpenGL
        if (colors.length < 1)
            return;
        uint color1 = colors[0];
        uint color2 = colors.length > 1 ? colors[1] : color1;
        if (isFullyTransparentColor(color1) && isFullyTransparentColor(color2))
            return;
        // draw horizontal lines
        foreach(int x; rc.left .. rc.right) {
            if ((x ^ rc.top) & 1)
                fillRect(Rect(x, rc.top, x + 1, rc.top + 1), color1);
            if ((x ^ (rc.bottom - 1)) & 1)
                fillRect(Rect(x, rc.bottom - 1, x + 1, rc.bottom), color2);
        }
        // draw vertical lines
        foreach(int y; rc.top + 1 .. rc.bottom - 1) {
            uint color = color1 == color2 ? color1 : blendARGB(color2, color1, 255 / (rc.bottom - rc.top));
            if ((y ^ rc.left) & 1)
                fillRect(Rect(rc.left, y, rc.left + 1, y + 1), color);
            if ((y ^ (rc.right - 1)) & 1)
                fillRect(Rect(rc.right - 1, y, rc.right, y + 1), color);
        }
    }

    /// draw line from point p1 to p2 with specified color
    void drawLine(Point p1, Point p2, uint colour) {
        if (!clipLine(_clipRect, p1, p2))
            return;
        // from rosettacode.org
        import std.math: abs;
        immutable int dx = p2.x - p1.x;
        immutable int ix = (dx > 0) - (dx < 0);
        immutable int dx2 = abs(dx) * 2;
        int dy = p2.y - p1.y;
        immutable int iy = (dy > 0) - (dy < 0);
        immutable int dy2 = abs(dy) * 2;
        drawPixel(p1.x, p1.y, colour);
        if (dx2 >= dy2) {
            int error = dy2 - (dx2 / 2);
            while (p1.x != p2.x) {
                if (error >= 0 && (error || (ix > 0))) {
                    error -= dx2;
                    p1.y += iy;
                }
                error += dy2;
                p1.x += ix;
                drawPixel(p1.x, p1.y, colour);
            }
        } else {
            int error = dx2 - (dy2 / 2);
            while (p1.y != p2.y) {
                if (error >= 0 && (error || (iy > 0))) {
                    error -= dy2;
                    p1.x += ix;
                }
                error += dx2;
                p1.y += iy;
                drawPixel(p1.x, p1.y, colour);
            }
        }
    }

    /// create drawbuf with copy of current buffer with changed colors (returns this if not supported)
    DrawBuf transformColors(ref ColorTransform transform) {
        return this;
    }

    /// draw custom OpenGL scene
    void drawCustomOpenGLScene(Rect rc, OpenGLDrawableDelegate handler) {
        // override it for OpenGL draw buffer
        Log.w("drawCustomOpenGLScene is called for non-OpenGL DrawBuf");
    }

    void clear() {
        resetClipping();
    }
}

alias DrawBufRef = Ref!DrawBuf;

/// RAII setting/restoring of clip rectangle
struct ClipRectSaver {
    private DrawBuf _buf;
    private Rect _oldClipRect;
    private uint _oldAlpha;
    /// apply (intersect) new clip rectangle and alpha to draw buf; restore 
    this(DrawBuf buf, ref Rect newClipRect, uint newAlpha = 0) {
        _buf = buf;
        _oldClipRect = buf.clipRect;
        _oldAlpha = buf.alpha;
        buf.intersectClipRect(newClipRect);
        if (newAlpha)
            buf.addAlpha(newAlpha);
    }
    ~this() {
        _buf.clipRect = _oldClipRect;
        _buf.alpha = _oldAlpha;
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
                    foreach(yy; 0 .. dy) {
                        uint * srcrow = colorDrawBuf.scanLine(srcrect.top + yy) + srcrect.left;
                        uint * dstrow = scanLine(dstrect.top + yy) + dstrect.left;
                        if (!_alpha) {
                            // simplified version - no alpha blending
                            foreach(i; 0 .. dx) {
                                uint pixel = srcrow[i];
                                uint alpha = pixel >> 24;
                                if (!alpha)
                                    dstrow[i] = pixel;
                                else if (alpha < 254) {
                                    // apply blending
                                    dstrow[i] = blendARGB(dstrow[i], pixel, alpha);
                                }
                            }
                        } else {
                            // combine two alphas
                            foreach(i; 0 .. dx) {
                                uint pixel = srcrow[i];
                                uint alpha = blendAlpha(_alpha, pixel >> 24);
                                if (!alpha)
                                    dstrow[i] = pixel;
                                else if (alpha < 254) {
                                    // apply blending
                                    dstrow[i] = blendARGB(dstrow[i], pixel, alpha);
                                }
                            }
                        }

                    }
                }
            }
        }
    }

	import std.container.array;

    /// Create mapping of source coordinates to destination coordinates, for resize.
    private Array!int createMap(int dst0, int dst1, int src0, int src1, double k) {
        int dd = dst1 - dst0;
        //int sd = src1 - src0;
		Array!int res;
		res.length = dd;
        foreach(int i; 0 .. dd)
            res[i] = src0 + cast(int)(i * k);//sd / dd;
        return res;
    }

    /// draw source buffer rectangle contents to destination buffer rectangle applying rescaling
    override void drawRescaled(Rect dstrect, DrawBuf src, Rect srcrect) {
        //Log.d("drawRescaled ", dstrect, " <- ", srcrect);
        if (_alpha >= 254)
            return; // fully transparent - don't draw
		double kx = cast(double)srcrect.width / dstrect.width;
		double ky = cast(double)srcrect.height / dstrect.height;
        if (applyClipping(dstrect, srcrect)) {
            auto xmapArray = createMap(dstrect.left, dstrect.right, srcrect.left, srcrect.right, kx);
            auto ymapArray = createMap(dstrect.top, dstrect.bottom, srcrect.top, srcrect.bottom, ky);

            int * xmap = &xmapArray[0];
            int * ymap = &ymapArray[0];
            int dx = dstrect.width;
            int dy = dstrect.height;
            ColorDrawBufBase colorDrawBuf = cast(ColorDrawBufBase) src;
            if (colorDrawBuf !is null) {
                foreach(y; 0 .. dy) {
                    uint * srcrow = colorDrawBuf.scanLine(ymap[y]);
                    uint * dstrow = scanLine(dstrect.top + y) + dstrect.left;
                    if (!_alpha) {
                        // simplified alpha calculation
                        foreach(x; 0 .. dx) {
                            uint srcpixel = srcrow[xmap[x]];
                            uint dstpixel = dstrow[x];
                            uint alpha = srcpixel >> 24;
                            if (!alpha)
                                dstrow[x] = srcpixel;
                            else if (alpha < 255) {
                                // apply blending
                                dstrow[x] = blendARGB(dstpixel, srcpixel, alpha);
                            }
                        }
                    } else {
                        // blending two alphas
                        foreach(x; 0 .. dx) {
                            uint srcpixel = srcrow[xmap[x]];
                            uint dstpixel = dstrow[x];
                            uint srca = srcpixel >> 24;
                            uint alpha = !srca ? _alpha : blendAlpha(_alpha, srca);
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
    }

    /// detect position of black pixels in row for 9-patch markup
    private bool detectHLine(int y, ref int x0, ref int x1) {
        uint * line = scanLine(y);
        bool foundUsed = false;
        x0 = 0;
        x1 = 0;
        foreach(int x; 1 .. _dx - 1) {
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
        foreach(int y; 1 .. _dy - 1) {
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
        bool clipping = true; //!_clipRect.empty();
        color = applyAlpha(color);
        bool subpixel = glyph.subpixelMode != SubpixelRenderingMode.None;
        foreach(int yy; 0 .. srcdy) {
            int liney = y + yy;
            if (clipping && (liney < _clipRect.top || liney >= _clipRect.bottom))
                continue;
            if (liney < 0 || liney >= _dy)
                continue;
            uint * row = scanLine(liney);
            ubyte * srcrow = src.ptr + yy * srcdx;
            foreach(int xx; 0 .. srcdx) {
                int colx = x + (subpixel ? xx / 3 : xx);
                if (clipping && (colx < _clipRect.left || colx >= _clipRect.right))
                    continue;
                if (colx < 0 || colx >= _dx)
                    continue;
                uint alpha2 = (color >> 24);
                uint alpha1 = srcrow[xx] ^ 255;
                uint alpha = ((((alpha1 ^ 255) * (alpha2 ^ 255)) >> 8) ^ 255) & 255;
                if (subpixel) {
                    int x0 = xx % 3;
                    ubyte * dst = cast(ubyte*)(row + colx);
                    ubyte * pcolor = cast(ubyte*)(&color);
                    blendSubpixel(dst, pcolor, alpha, x0, glyph.subpixelMode);
                } else {
                    uint pixel = row[colx];
                    if (alpha < 255) {
                        if (!alpha)
                            row[colx] = pixel;
                        else {
                            // apply blending
                            row[colx] = blendARGB(pixel, color, alpha);
                        }
                    }
                }
            }
        }
    }

    void drawGlyphToTexture(int x, int y, Glyph * glyph) {
        ubyte[] src = glyph.glyph;
        int srcdx = glyph.blackBoxX;
        int srcdy = glyph.blackBoxY;
        bool subpixel = glyph.subpixelMode != SubpixelRenderingMode.None;
        foreach(int yy; 0 .. srcdy) {
            int liney = y + yy;
            uint * row = scanLine(liney);
            ubyte * srcrow = src.ptr + yy * srcdx;
            int increment = subpixel ? 3 : 1;
            for (int xx = 0; xx <= srcdx - increment; xx += increment) {
                int colx = x + (subpixel ? xx / 3 : xx);
                if (subpixel) {
                    uint t1 = srcrow[xx];
                    uint t2 = srcrow[xx + 1];
                    uint t3 = srcrow[xx + 2];
                    //uint pixel = ((t2 ^ 0x00) << 24) | ((t1  ^ 0xFF)<< 16) | ((t2 ^ 0xFF) << 8) | (t3 ^ 0xFF);
                    uint pixel = ((t2 ^ 0x00) << 24) | 0xFFFFFF;
                    row[colx] = pixel;
                } else {
                    uint alpha1 = srcrow[xx] ^ 0xFF;
                    //uint pixel = (alpha1 << 24) | 0xFFFFFF; //(alpha1 << 16) || (alpha1 << 8) || alpha1;
                    //uint pixel = ((alpha1 ^ 0xFF) << 24) | (alpha1 << 16) | (alpha1 << 8) | alpha1;
                    uint pixel = ((alpha1 ^ 0xFF) << 24) | 0xFFFFFF;
                    row[colx] = pixel;
                }
            }
        }
    }

    override void fillRect(Rect rc, uint color) {
        if (applyClipping(rc)) {
            foreach(y; rc.top .. rc.bottom) {
                uint * row = scanLine(y);
                uint alpha = color >> 24;
                if (!alpha) {
                    row[rc.left .. rc.right] = color;
                } else if (alpha < 254) {
                    foreach(x; rc.left .. rc.right) {
                        // apply blending
                        row[x] = blendARGB(row[x], color, alpha);
                    }
                }
            }
        }
    }

    /// draw pixel at (x, y) with specified color 
    override void drawPixel(int x, int y, uint color) {
        if (!_clipRect.isPointInside(x, y))
            return;
        color = applyAlpha(color);
        uint * row = scanLine(y);
        uint alpha = color >> 24;
        if (!alpha) {
            row[x] = color;
        } else if (alpha < 254) {
            // apply blending
            row[x] = blendARGB(row[x], color, alpha);
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
        resetClipping();
    }
    override void fill(uint color) {
        if (hasClipping) {
            fillRect(_clipRect, color);
            return;
        }
        int len = _dx * _dy;
        ubyte * p = _buf.ptr;
        ubyte cl = rgbToGray(color);
        foreach(i; 0 .. len)
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
                    foreach(yy; 0 .. dy) {
                        ubyte * srcrow = grayDrawBuf.scanLine(srcrect.top + yy) + srcrect.left;
                        ubyte * dstrow = scanLine(dstrect.top + yy) + dstrect.left;
                        foreach(i; 0 .. dx) {
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
        foreach(int i; 0 .. dd)
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
                foreach(y; 0 .. dy) {
                    ubyte * srcrow = grayDrawBuf.scanLine(ymap[y]);
                    ubyte * dstrow = scanLine(dstrect.top + y) + dstrect.left;
                    foreach(x; 0 .. dx) {
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
        foreach(int x; 1 .. _dx - 1) {
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
        foreach(int y; 1 .. _dy - 1) {
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
        bool clipping = true; //!_clipRect.empty();
        foreach(int yy; 0 .. srcdy) {
            int liney = y + yy;
            if (clipping && (liney < _clipRect.top || liney >= _clipRect.bottom))
                continue;
            if (liney < 0 || liney >= _dy)
                continue;
            ubyte * row = scanLine(liney);
            ubyte * srcrow = src.ptr + yy * srcdx;
            foreach(int xx; 0 .. srcdx) {
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
        if (applyClipping(rc)) {
            uint alpha = color >> 24;
            ubyte cl = rgbToGray(color);
            foreach(y; rc.top .. rc.bottom) {
                ubyte * row = scanLine(y);
                foreach(x; rc.left .. rc.right) {
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

    /// draw pixel at (x, y) with specified color 
    override void drawPixel(int x, int y, uint color) {
        if (!_clipRect.isPointInside(x, y))
            return;
        color = applyAlpha(color);
        ubyte cl = rgbToGray(color);
        ubyte * row = scanLine(y);
        uint alpha = color >> 24;
        if (!alpha) {
            row[x] = cl;
        } else if (alpha < 254) {
            // apply blending
            row[x] = blendGray(row[x], cl, alpha);
        }
    }
}

class ColorDrawBuf : ColorDrawBufBase {
    uint[] _buf;
    /// create ARGB8888 draw buf of specified width and height
    this(int width, int height) {
        resize(width, height);
    }
    /// create copy of ColorDrawBuf
    this(ColorDrawBuf v) {
        this(v.width, v.height);
        //_buf.length = v._buf.length;
        foreach(i; 0 .. _buf.length)
            _buf[i] = v._buf[i];
    }
    /// create resized copy of ColorDrawBuf
    this(ColorDrawBuf v, int dx, int dy) {
        this(dx, dy);
        fill(0xFFFFFFFF);
        drawRescaled(Rect(0, 0, dx, dy), v, Rect(0, 0, v.width, v.height));
    }
    void invertAlpha() {
        foreach(ref pixel; _buf)
            pixel ^= 0xFF000000;
    }
    void invertByteOrder() {
        foreach(pixel; _buf) {
            pixel = (pixel & 0xFF00FF00) |
                ((pixel & 0xFF0000) >> 16) |
                ((pixel & 0xFF) << 16);
        }
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
        resetClipping();
    }
    override void fill(uint color) {
        if (hasClipping) {
            fillRect(_clipRect, color);
            return;
        }
        int len = _dx * _dy;
        uint * p = _buf.ptr;
        foreach(i; 0 .. len)
            p[i] = color;
    }
    override DrawBuf transformColors(ref ColorTransform transform) {
        if (transform.empty)
            return this;
        bool skipFrame = hasNinePatch;
        ColorDrawBuf res = new ColorDrawBuf(_dx, _dy);
        if (hasNinePatch) {
            NinePatch * p = new NinePatch;
            *p = *_ninePatch;
            res.ninePatch = p;
        }
        foreach(int y; 0 .. _dy) {
            uint * srcline = scanLine(y);
            uint * dstline = res.scanLine(y);
            bool allowTransformY = !skipFrame || (y !=0 && y != _dy - 1);
            foreach(int x; 0 .. _dx) {
                bool allowTransformX = !skipFrame || (x !=0 && x != _dx - 1);
                if (!allowTransformX || !allowTransformY)
                    dstline[x] = srcline[x];
                else
                    dstline[x] = transform.transform(srcline[x]);
            }
        }
        return res;
    }
}


// line clipping algorithm from https://en.wikipedia.org/wiki/Cohen%E2%80%93Sutherland_algorithm
private alias OutCode = int;

private const int INSIDE = 0; // 0000
private const int LEFT = 1;   // 0001
private const int RIGHT = 2;  // 0010
private const int BOTTOM = 4; // 0100
private const int TOP = 8;    // 1000

// Compute the bit code for a point (x, y) using the clip rectangle
// bounded diagonally by (xmin, ymin), and (xmax, ymax)

// ASSUME THAT xmax, xmin, ymax and ymin are global constants.

private OutCode ComputeOutCode(Rect clipRect, double x, double y)
{
    OutCode code;

    code = INSIDE;          // initialised as being inside of clip window

    if (x < clipRect.left)           // to the left of clip window
        code |= LEFT;
    else if (x > clipRect.right)      // to the right of clip window
        code |= RIGHT;
    if (y < clipRect.top)           // below the clip window
        code |= BOTTOM;
    else if (y > clipRect.bottom)      // above the clip window
        code |= TOP;

    return code;
}

package bool clipLine(ref Rect clipRect, ref Point p1, ref Point p2) {
    double x0 = p1.x;
    double y0 = p1.y;
    double x1 = p2.x;
    double y1 = p2.y;
    bool res = CohenSutherlandLineClipAndDraw(clipRect, x0, y0, x1, y1);
    if (res) {
        p1.x = cast(int)x0;
        p1.y = cast(int)y0;
        p2.x = cast(int)x1;
        p2.y = cast(int)y1;
    }
    return res;
}

// Cohen–Sutherland clipping algorithm clips a line from
// P0 = (x0, y0) to P1 = (x1, y1) against a rectangle with 
// diagonal from (xmin, ymin) to (xmax, ymax).
private bool CohenSutherlandLineClipAndDraw(ref Rect clipRect, ref double x0, ref double y0, ref double x1, ref double y1)
{
    // compute outcodes for P0, P1, and whatever point lies outside the clip rectangle
    OutCode outcode0 = ComputeOutCode(clipRect, x0, y0);
    OutCode outcode1 = ComputeOutCode(clipRect, x1, y1);
    bool accept = false;

    while (true) {
        if (!(outcode0 | outcode1)) { // Bitwise OR is 0. Trivially accept and get out of loop
            accept = true;
            break;
        } else if (outcode0 & outcode1) { // Bitwise AND is not 0. Trivially reject and get out of loop
            break;
        } else {
            // failed both tests, so calculate the line segment to clip
            // from an outside point to an intersection with clip edge
            double x, y;

            // At least one endpoint is outside the clip rectangle; pick it.
            OutCode outcodeOut = outcode0 ? outcode0 : outcode1;

            // Now find the intersection point;
            // use formulas y = y0 + slope * (x - x0), x = x0 + (1 / slope) * (y - y0)
            if (outcodeOut & TOP) {           // point is above the clip rectangle
                x = x0 + (x1 - x0) * (clipRect.bottom - y0) / (y1 - y0);
                y = clipRect.bottom;
            } else if (outcodeOut & BOTTOM) { // point is below the clip rectangle
                x = x0 + (x1 - x0) * (clipRect.top - y0) / (y1 - y0);
                y = clipRect.top;
            } else if (outcodeOut & RIGHT) {  // point is to the right of clip rectangle
                y = y0 + (y1 - y0) * (clipRect.right - x0) / (x1 - x0);
                x = clipRect.right;
            } else if (outcodeOut & LEFT) {   // point is to the left of clip rectangle
                y = y0 + (y1 - y0) * (clipRect.left - x0) / (x1 - x0);
                x = clipRect.left;
            }

            // Now we move outside point to intersection point to clip
            // and get ready for next pass.
            if (outcodeOut == outcode0) {
                x0 = x;
                y0 = y;
                outcode0 = ComputeOutCode(clipRect, x0, y0);
            } else {
                x1 = x;
                y1 = y;
                outcode1 = ComputeOutCode(clipRect, x1, y1);
            }
        }
    }
    return accept;
}
