module dlangui.graphics.drawbuf;

public import dlangui.core.types;

uint blendARGB(uint dst, uint src, uint alpha) {
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

class DrawBuf : RefCountedObject {
    protected Rect _clipRect;
    /// returns current width
    @property int width() { return 0; }
    /// returns current height
    @property int height() { return 0; }
    /// returns clipping rectangle, when clipRect.isEmpty == true -- means no clipping.
    @property ref Rect clipRect() { return _clipRect; }
    /// sets new clipping rectangle, when clipRect.isEmpty == true -- means no clipping.
    @property void clipRect(const ref Rect rect) { 
        _clipRect = rect; 
        _clipRect.intersect(Rect(0, 0, width, height));
    }
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
    bool applyClipping(ref Rect rc, ref Rect rc2) {
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
        return !rc.empty() && !rc2.empty();
    }
    void beforeDrawing() { }
    void afterDrawing() { }
    /// returns buffer bits per pixel
    @property int bpp() { return 0; }
    /// returns pointer to ARGB scanline, null if y is out of range or buffer doesn't provide access to its memory
    uint * scanLine(int y) { return null; }
    abstract void resize(int width, int height);
    abstract void fill(uint color);
    void fillRect(int left, int top, int right, int bottom, uint color) {
        fillRect(Rect(left, top, right, bottom), color);
    }
    abstract void fillRect(Rect rc, uint color);
	abstract void drawGlyph(int x, int y, ubyte[] src, int srcdx, int srcdy, uint color);
    /// draw source buffer rectangle contents to destination buffer
    abstract void drawFragment(int x, int y, DrawBuf src, Rect srcrect);
    /// draw whole unscaled image at specified coordinates
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
    /// draw source buffer rectangle contents to destination buffer
    override void drawFragment(int x, int y, DrawBuf src, Rect srcrect) {
        Rect dstrect = Rect(x, y, x + srcrect.width, y + srcrect.height);
        if (applyClipping(dstrect, srcrect)) {
            if (src.applyClipping(srcrect, dstrect)) {
                int dx = srcrect.width;
                int dy = srcrect.height;
                for (int yy = 0; yy < dy; yy++) {
                    uint * srcrow = src.scanLine(srcrect.top + yy) + srcrect.left;
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
    override void fillRect(int left, int top, int right, int bottom, uint color) {
        fillRect(Rect(left, top, right, bottom), color);
    }
	override void drawGlyph(int x, int y, ubyte[] src, int srcdx, int srcdy, uint color) {
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
