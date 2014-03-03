module dlangui.graphics.drawbuf;

import dlangui.core.types;

public uint blendARGB(uint dst, uint src, uint alpha) {
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

class DrawBuf {
    protected Rect _clipRect;
    public @property int width() { return 0; }
    public @property int height() { return 0; }
    public @property ref Rect clipRect() { return _clipRect; }
    public @property void clipRect(const ref Rect rect) { 
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
    public void beforeDrawing() { }
    public void afterDrawing() { }
    public uint * scanLine(int y) { return null; }
    abstract public void resize(int width, int height);
    abstract public void clear(uint color);
    public void fillRect(int left, int top, int right, int bottom, uint color) {
        fillRect(Rect(left, top, right, bottom), color);
    }
    abstract public void fillRect(Rect rc, uint color);
}

class ColorDrawBufBase : DrawBuf {
    int _dx;
    int _dy;
    public @property override int width() { return _dx; }
    public @property override int height() { return _dy; }
    public override void fillRect(int left, int top, int right, int bottom, uint color) {
        fillRect(Rect(left, top, right, bottom), color);
    }
    public override void fillRect(Rect rc, uint color) {
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
    public this(int width, int height) {
        resize(width, height);
    }
    public override uint * scanLine(int y) {
        if (y >= 0 && y < _dy)
            return _buf.ptr + _dx * y;
        return null;
    }
    public override void resize(int width, int height) {
        if (_dx == width && _dy == height)
            return;
        _dx = width;
        _dy = height;
        _buf.length = _dx * _dy;
    }
    public override void clear(uint color) {
        int len = _dx * _dy;
        uint * p = _buf.ptr;
        for (int i = 0; i < len; i++)
            p[i] = color;
    }
}
