module dlangui.graphics.gldrawbuf;

import dlangui.graphics.drawbuf;
import dlangui.graphics.glsupport;

/// drawing buffer - image container which allows to perform some drawing operations
class GLDrawBuf : DrawBuf {

    int _dx;
    int _dy;
    bool _framebuffer;

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
        setOrthoProjection(_dx, _dy);
    }

    /// reserved for hardware-accelerated drawing - ends drawing batch
    override void afterDrawing() { 
        flushGL();
    }

    /// resize buffer
    override void resize(int width, int height) {
        _dx = width;
        _dy = height;
    }

    /// fill the whole buffer with solid color (no clipping applied)
    override void fill(uint color) {
    }
    /// fill rectangle with solid color (clipping is applied)
    override void fillRect(Rect rc, uint color) {
        drawSolidFillRect(rc, color, color, color, color);
    }
    /// draw 8bit alpha image - usually font glyph using specified color (clipping is applied)
	override void drawGlyph(int x, int y, ubyte[] src, int srcdx, int srcdy, uint color) {
    }
    /// draw source buffer rectangle contents to destination buffer
    override void drawFragment(int x, int y, DrawBuf src, Rect srcrect) {
    }
    /// draw source buffer rectangle contents to destination buffer rectangle applying rescaling
    override void drawRescaled(Rect dstrect, DrawBuf src, Rect srcrect) {
    }
    override void clear() {
    }
    ~this() { clear(); }
}
