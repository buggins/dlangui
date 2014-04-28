module dlangui.platforms.windows.win32drawbuf;

version (Windows) {

import win32.windows;
import dlangui.core.logger;
import dlangui.graphics.drawbuf;

class Win32ColorDrawBuf : ColorDrawBufBase {
    uint * _pixels;
    HDC _drawdc;
    HBITMAP _drawbmp;
    @property HDC dc() { return _drawdc; }
    this(int width, int height) {
        resize(width, height);
    }
    override uint * scanLine(int y) {
        if (y >= 0 && y < _dy)
            return _pixels + _dx * (_dy - 1 - y);
        return null;
    }
    ~this() {
        clear();
    }
    override void clear() {
        if (_drawbmp !is null) {
            DeleteObject( _drawbmp );
            DeleteObject( _drawdc );
            _drawbmp = null;
            _drawdc = null;
            _pixels = null;
            _dx = 0;
            _dy = 0;
        }
    }
    override void resize(int width, int height) {
        if (width< 0)
            width = 0;
        if (height < 0)
            height = 0;
        if (_dx == width && _dy == height)
            return;
        clear();
        _dx = width;
        _dy = height;
        if (_dx > 0 && _dy > 0) {
            BITMAPINFO bmi;
            //memset( &bmi, 0, sizeof(bmi) );
            bmi.bmiHeader.biSize = (bmi.bmiHeader.sizeof);
            bmi.bmiHeader.biWidth = _dx;
            bmi.bmiHeader.biHeight = _dy;
            bmi.bmiHeader.biPlanes = 1;
            bmi.bmiHeader.biBitCount = 32;
            bmi.bmiHeader.biCompression = BI_RGB;
            bmi.bmiHeader.biSizeImage = 0;
            bmi.bmiHeader.biXPelsPerMeter = 1024;
            bmi.bmiHeader.biYPelsPerMeter = 1024;
            bmi.bmiHeader.biClrUsed = 0;
            bmi.bmiHeader.biClrImportant = 0;
            _drawbmp = CreateDIBSection( NULL, &bmi, DIB_RGB_COLORS, cast(void**)(&_pixels), NULL, 0 );
            _drawdc = CreateCompatibleDC(NULL);
            SelectObject(_drawdc, _drawbmp);
        }
    }
    override void fill(uint color) {
        int len = _dx * _dy;
        for (int i = 0; i < len; i++)
            _pixels[i] = color;
    }
    void drawTo(HDC dc, int x, int y) {
        BitBlt(dc, x, y, _dx, _dy, _drawdc, 0, 0, SRCCOPY);
    }
}

}
