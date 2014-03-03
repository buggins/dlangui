module dlangui.platforms.windows.winapp;


version (Windows) {

import core.runtime;
import win32.windows;
import std.string;
import std.utf;
import std.stdio;
import dlangui.platforms.common.platform;
import dlangui.graphics.drawbuf;

pragma(lib, "gdi32.lib");
pragma(lib, "user32.lib");

extern (C) int UIAppMain();

immutable WIN_CLASS_NAME = "DLANGUI_APP";

__gshared HINSTANCE _hInstance;
__gshared int _cmdShow;

class Win32Window : Window {
    private HWND _hwnd;
    string _caption;
    Win32ColorDrawBuf _drawbuf;
    public this(string windowCaption, Window parent) {
        _caption = windowCaption;
        _hwnd = CreateWindow(toUTF16z(WIN_CLASS_NAME),      // window class name
                            toUTF16z(windowCaption),  // window caption
                            WS_OVERLAPPEDWINDOW,  // window style
                            CW_USEDEFAULT,        // initial x position
                            CW_USEDEFAULT,        // initial y position
                            CW_USEDEFAULT,        // initial x size
                            CW_USEDEFAULT,        // initial y size
                            null,                 // parent window handle
                            null,                 // window menu handle
                            _hInstance,           // program instance handle
                            cast(void*)this);                // creation parameters
    }
    public Win32ColorDrawBuf getDrawBuf() {
        RECT rect;
        GetClientRect(_hwnd, &rect);
        int dx = rect.right - rect.left;
        int dy = rect.bottom - rect.top;
        if (_drawbuf is null)
            _drawbuf = new Win32ColorDrawBuf(dx, dy);
        else 
            _drawbuf.resize(dx, dy);
        return _drawbuf;
    }
    public override void show() {
        ShowWindow(_hwnd, _cmdShow);
        UpdateWindow(_hwnd);
    }
    public override string getWindowCaption() {
        return _caption;
    }
    public override void setWindowCaption(string caption) {
        _caption = caption;
        SetWindowTextW(_hwnd, toUTF16z(_caption));
    }
    public void onCreate() {
        writeln("Window onCreate");
    }
}

class Win32Platform : Platform {
    public this() {
    }
    public bool registerWndClass() {
        //MSG  msg;
        WNDCLASS wndclass;

        wndclass.style         = CS_HREDRAW | CS_VREDRAW;
        wndclass.lpfnWndProc   = &WndProc;
        wndclass.cbClsExtra    = 0;
        wndclass.cbWndExtra    = 0;
        wndclass.hInstance     = _hInstance;
        wndclass.hIcon         = LoadIcon(null, IDI_APPLICATION);
        wndclass.hCursor       = LoadCursor(null, IDC_ARROW);
        wndclass.hbrBackground = cast(HBRUSH)GetStockObject(WHITE_BRUSH);
        wndclass.lpszMenuName  = null;
        wndclass.lpszClassName = toUTF16z(WIN_CLASS_NAME);

        if(!RegisterClass(&wndclass))
        {
            return false;
        }
        return true;
    }
    public override int enterMessageLoop() {
        MSG  msg;
        while (GetMessage(&msg, null, 0, 0))
        {
            TranslateMessage(&msg);
            DispatchMessage(&msg);
        }
        return msg.wParam;
    }
    public override Window createWindow(string windowCaption, Window parent) {
        return new Win32Window(windowCaption, parent);
    }
}

auto toUTF16z(S)(S s)
{
    return toUTFz!(const(wchar)*)(s);
}

extern (Windows)
int WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance,
            LPSTR lpCmdLine, int nCmdShow)
{
    int result;

    void exceptionHandler(Throwable e) {
        throw e;
    }

    try
    {
        Runtime.initialize(&exceptionHandler);
        result = myWinMain(hInstance, hPrevInstance, lpCmdLine, nCmdShow);
        Runtime.terminate(&exceptionHandler);
    }
    catch (Throwable e) // catch any uncaught exceptions
    {
        MessageBox(null, toUTF16z(e.toString()), "Error",
                   MB_OK | MB_ICONEXCLAMATION);
        result = 0;     // failed
    }

    return result;
}

int myWinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int iCmdShow)
{
    _cmdShow = iCmdShow;
    _hInstance = hInstance;
    writeln("Creating window");
    string appName = "HelloWin";


    Win32Platform platform = new Win32Platform();
    if (!platform.registerWndClass()) {
        MessageBoxA(null, "This program requires Windows NT!", appName.toStringz, MB_ICONERROR);
        return 0;
    }
    Platform.setInstance(platform);
    return UIAppMain();
}

class Win32ColorDrawBuf : ColorDrawBufBase {
    uint * _pixels;
    HDC _drawdc;
    HBITMAP _drawbmp;
    public @property HDC dc() { return _drawdc; }
    public this(int width, int height) {
        resize(width, height);
    }
    public override uint * scanLine(int y) {
        if (y >= 0 && y < _dy)
            return _pixels + _dx * (_dy - 1 - y);
        return null;
    }
    public override void resize(int width, int height) {
        if (width< 0)
            width = 0;
        if (height < 0)
            height = 0;
        if (_dx == width && _dy == height)
            return;
        _dx = width;
        _dy = height;
        if (_drawbmp !is null) {
            DeleteObject( _drawbmp );
            DeleteObject( _drawdc );
            _pixels = null;
        }
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
    public override void clear(uint color) {
        int len = _dx * _dy;
        for (int i = 0; i < len; i++)
            _pixels[i] = color;
    }
    public void drawTo(HDC dc, int x, int y) {
        BitBlt(dc, x, y, _dx, _dx, _drawdc, 0, 0, SRCCOPY);
    }
}

void drawBuf2DC(HDC dc, int x, int y, DrawBuf buf)
{
    uint * drawpixels;
    HDC drawdc;
    HBITMAP drawbmp;

    int buf_width = buf.width();
    int bytesPerRow = buf_width * 4;
    BITMAPINFO bmi;
    //memset( &bmi, 0, sizeof(bmi) );
    bmi.bmiHeader.biSize = (bmi.bmiHeader.sizeof);
    bmi.bmiHeader.biWidth = buf_width;
    bmi.bmiHeader.biHeight = buf.height;
    bmi.bmiHeader.biPlanes = 1;
    bmi.bmiHeader.biBitCount = 32;
    bmi.bmiHeader.biCompression = BI_RGB;
    bmi.bmiHeader.biSizeImage = 0;
    bmi.bmiHeader.biXPelsPerMeter = 1024;
    bmi.bmiHeader.biYPelsPerMeter = 1024;
    bmi.bmiHeader.biClrUsed = 0;
    bmi.bmiHeader.biClrImportant = 0;
    drawbmp = CreateDIBSection( NULL, &bmi, DIB_RGB_COLORS, cast(void**)(&drawpixels), NULL, 0 );
    drawdc = CreateCompatibleDC(NULL);
    SelectObject(drawdc, drawbmp);
    for (int yy=0; yy < buf.height; yy++)
    {
        uint * src = buf.scanLine(yy);
        uint * dst = drawpixels + (buf.height - 1 - yy) * buf.width;
        for (int xx = 0; xx < buf_width; xx++)
            dst[xx] = src[xx];
    }
    BitBlt( dc, x, y, buf_width, buf.height, drawdc, 0, 0, SRCCOPY);
    DeleteObject( drawbmp );
    DeleteObject( drawdc );
}


extern(Windows)
LRESULT WndProc(HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam)
{
    HDC hdc;
    PAINTSTRUCT ps;
    RECT rect;
    void * p = cast(void*)GetWindowLongPtr(hwnd, GWLP_USERDATA);
    Win32Window window = p is null ? null : cast(Win32Window)(p);
    switch (message)
    {
        case WM_CREATE:
            {
                CREATESTRUCT * pcreateStruct = cast(CREATESTRUCT*)lParam;
                window = cast(Win32Window)pcreateStruct.lpCreateParams;
                void * ptr = cast(void*) window;
                SetWindowLongPtr(hwnd, GWLP_USERDATA, cast(LONG_PTR)ptr);
                window.onCreate();
            }
            //PlaySoundA("hellowin.wav", NULL, SND_FILENAME | SND_ASYNC);
            return 0;

        case WM_PAINT:
            {
                hdc = BeginPaint(hwnd, &ps);
                Win32ColorDrawBuf buf = window.getDrawBuf();
                buf.clear(0x808080);
                buf.fillRect(40, 40, 200, 200, 0xFF8000);
                buf.fillRect(150, 120, 500, 400, 0xFF80FF);
                buf.drawTo(hdc, 0, 0);
                //drawBuf2DC(hdc, 0, 0, buf);
                scope(exit) EndPaint(hwnd, &ps);
            }
            //DrawTextA(hdc, "Hello, Windows!", -1, &rect, DT_SINGLELINE | DT_CENTER | DT_VCENTER);
            return 0;

        case WM_DESTROY:
            PostQuitMessage(0);
            return 0;

        default:
    }

    return DefWindowProc(hwnd, message, wParam, lParam);
}

//===========================================
// end of version(Windows)
//===========================================
} 
