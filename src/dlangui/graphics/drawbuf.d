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
    @property int width() { return 0; }
    @property int height() { return 0; }
    @property ref Rect clipRect() { return _clipRect; }
    @property void clipRect(const ref Rect rect) { 
        _clipRect = rect; 
        _clipRect.intersect(Rect(0, 0, width, height));
    }
    protected bool applyClipping(ref Rect rc) {
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
    void beforeDrawing() { }
    void afterDrawing() { }
    uint * scanLine(int y) { return null; }
    abstract void resize(int width, int height);
    abstract void fill(uint color);
    void fillRect(int left, int top, int right, int bottom, uint color) {
        fillRect(Rect(left, top, right, bottom), color);
    }
    abstract void fillRect(Rect rc, uint color);
	abstract void drawGlyph(int x, int y, ubyte[] src, int srcdx, int srcdy, uint color);
    void clear() {}
    ~this() { clear(); }
}

class ColorDrawBufBase : DrawBuf {
    int _dx;
    int _dy;
    @property override int width() { return _dx; }
    @property override int height() { return _dy; }
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
