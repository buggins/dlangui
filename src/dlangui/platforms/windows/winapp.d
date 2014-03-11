module dlangui.platforms.windows.winapp;

version (Windows) {

import core.runtime;
import win32.windows;
import std.string;
import std.utf;
import std.stdio;
import std.algorithm;
import std.file;
import dlangui.platforms.common.platform;
import dlangui.platforms.windows.win32fonts;
import dlangui.platforms.windows.win32drawbuf;
import dlangui.graphics.drawbuf;
import dlangui.graphics.fonts;
import dlangui.graphics.glsupport;
import dlangui.core.logger;
//import derelict.opengl3.wgl;

pragma(lib, "gdi32.lib");
pragma(lib, "user32.lib");
pragma(lib, "libpng15.lib");

extern (C) int UIAppMain(string[] args);

immutable WIN_CLASS_NAME = "DLANGUI_APP";

__gshared HINSTANCE _hInstance;
__gshared int _cmdShow;

bool setupPixelFormat(HDC hDC)
{
    PIXELFORMATDESCRIPTOR pfd = {
        PIXELFORMATDESCRIPTOR.sizeof,  /* size */
        1,                              /* version */
        PFD_SUPPORT_OPENGL |
            PFD_DRAW_TO_WINDOW |
            PFD_DOUBLEBUFFER,               /* support double-buffering */
        PFD_TYPE_RGBA,                  /* color type */
        16,                             /* prefered color depth */
        0, 0, 0, 0, 0, 0,               /* color bits (ignored) */
        0,                              /* no alpha buffer */
        0,                              /* alpha bits (ignored) */
        0,                              /* no accumulation buffer */
        0, 0, 0, 0,                     /* accum bits (ignored) */
        16,                             /* depth buffer */
        0,                              /* no stencil buffer */
        0,                              /* no auxiliary buffers */
        0,                              /* main layer PFD_MAIN_PLANE */
        0,                              /* reserved */
        0, 0, 0,                        /* no layer, visible, damage masks */
    };
    int pixelFormat;

    pixelFormat = ChoosePixelFormat(hDC, &pfd);
    if (pixelFormat == 0) {
        Log.e("ChoosePixelFormat failed.");
        return false;
    }

    if (SetPixelFormat(hDC, pixelFormat, &pfd) != TRUE) {
        Log.e("SetPixelFormat failed.");
        return false;
    }
    return true;
}

HPALETTE setupPalette(HDC hDC)
{
    import core.stdc.stdlib;
    HPALETTE hPalette = NULL;
    int pixelFormat = GetPixelFormat(hDC);
    PIXELFORMATDESCRIPTOR pfd;
    LOGPALETTE* pPal;
    int paletteSize;

    DescribePixelFormat(hDC, pixelFormat, PIXELFORMATDESCRIPTOR.sizeof, &pfd);

    if (pfd.dwFlags & PFD_NEED_PALETTE) {
        paletteSize = 1 << pfd.cColorBits;
    } else {
        return null;
    }

    pPal = cast(LOGPALETTE*)
        malloc(LOGPALETTE.sizeof + paletteSize * PALETTEENTRY.sizeof);
    pPal.palVersion = 0x300;
    pPal.palNumEntries = cast(ushort)paletteSize;

    /* build a simple RGB color palette */
    {
        int redMask = (1 << pfd.cRedBits) - 1;
        int greenMask = (1 << pfd.cGreenBits) - 1;
        int blueMask = (1 << pfd.cBlueBits) - 1;
        int i;

        for (i=0; i<paletteSize; ++i) {
            pPal.palPalEntry[i].peRed = cast(ubyte)(
                (((i >> pfd.cRedShift) & redMask) * 255) / redMask);
            pPal.palPalEntry[i].peGreen = cast(ubyte)(
                (((i >> pfd.cGreenShift) & greenMask) * 255) / greenMask);
            pPal.palPalEntry[i].peBlue = cast(ubyte)(
                (((i >> pfd.cBlueShift) & blueMask) * 255) / blueMask);
            pPal.palPalEntry[i].peFlags = 0;
        }
    }

    hPalette = CreatePalette(pPal);
    free(pPal);

    if (hPalette) {
        SelectPalette(hDC, hPalette, FALSE);
        RealizePalette(hDC);
    }

    return hPalette;
}

private __gshared bool DERELICT_GL3_RELOADED = false;

class Win32Window : Window {
    private HWND _hwnd;
    HGLRC _hGLRC; // opengl context
    HPALETTE _hPalette;
    string _caption;
    Win32ColorDrawBuf _drawbuf;
    bool useOpengl;
    this(string windowCaption, Window parent) {
        import derelict.opengl3.wgl;
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
        /* initialize OpenGL rendering */
        HDC hDC = GetDC(_hwnd);

        if (!DERELICT_GL3_RELOADED || openglEnabled) {
            if (setupPixelFormat(hDC)) {
                _hPalette = setupPalette(hDC);
                _hGLRC = wglCreateContext(hDC);
                if (_hGLRC) {
                    wglMakeCurrent(hDC, _hGLRC);

                    if (!DERELICT_GL3_RELOADED) {
                        // run this code only once
                        DERELICT_GL3_RELOADED = true;
                        try {
                            import derelict.opengl3.gl3;
                            DerelictGL3.reload();
                            // successful
                            if (initShaders()) {
                                setOpenglEnabled();
                                useOpengl = true;
                            } else {
                                Log.e("Failed to compile shaders");
                            }
                        } catch (Exception e) {
                            Log.e("Derelict exception", e);
                        }
                    } else {
						if (initShaders()) {
							setOpenglEnabled();
							useOpengl = true;
						} else {
							Log.e("Failed to compile shaders");
						}
                    }
                }
            } else {
                Log.e("Pixelformat failed");
                // disable GL
                DERELICT_GL3_RELOADED = true;
            }
        }
    }
    ~this() {
        Log.d("Window destructor");
        import derelict.opengl3.wgl;
        if (_hGLRC) {
			uninitShaders();
            wglMakeCurrent (null, null) ;
            wglDeleteContext(_hGLRC);
            _hGLRC = null;
        }
        if (_hwnd)
            DestroyWindow(_hwnd);
        _hwnd = null;
    }
    Win32ColorDrawBuf getDrawBuf() {
        //RECT rect;
        //GetClientRect(_hwnd, &rect);
        //int dx = rect.right - rect.left;
        //int dy = rect.bottom - rect.top;
        if (_drawbuf is null)
            _drawbuf = new Win32ColorDrawBuf(_dx, _dy);
        else
            _drawbuf.resize(_dx, _dy);
        return _drawbuf;
    }
    override void show() {
        ShowWindow(_hwnd, _cmdShow);
        UpdateWindow(_hwnd);
    }
    override @property string windowCaption() {
        return _caption;
    }
    override @property void windowCaption(string caption) {
        _caption = caption;
        SetWindowTextW(_hwnd, toUTF16z(_caption));
    }
    void onCreate() {
        Log.d("Window onCreate");
    }
    void onDestroy() {
        Log.d("Window onDestroy");
    }
    void onPaint() {
        Log.d("onPaint()");
        if (useOpengl && _hGLRC) {
            import derelict.opengl3.gl3;
            import derelict.opengl3.wgl;
            import dlangui.graphics.gldrawbuf;
            //Log.d("onPaint() start drawing opengl viewport: ", _dx, "x", _dy);
            //PAINTSTRUCT ps;
            //HDC hdc = BeginPaint(_hwnd, &ps);
            //scope(exit) EndPaint(_hwnd, &ps);
            HDC hdc = GetDC(_hwnd);
            wglMakeCurrent(hdc, _hGLRC);
            glDisable(GL_DEPTH_TEST);
            glViewport(0, 0, _dx, _dy);
            glClearColor(0.5f, 0.5f, 0.5f, 1.0f);
            glClear(GL_COLOR_BUFFER_BIT);

            GLDrawBuf buf = new GLDrawBuf(_dx, _dy, false);
            buf.beforeDrawing();
            buf.fillRect(Rect(100, 100, 200, 200), 0x704020);
            buf.fillRect(Rect(40, 70, 100, 120), 0x000000);
            buf.fillRect(Rect(80, 80, 150, 150), 0x80008000); // green
            buf.afterDrawing();
            //Log.d("onPaint() end drawing opengl");
            SwapBuffers(hdc);
        } else {
            PAINTSTRUCT ps;
            HDC hdc = BeginPaint(_hwnd, &ps);
            scope(exit) EndPaint(_hwnd, &ps);

            Win32ColorDrawBuf buf = getDrawBuf();
            buf.fill(0x808080);
            onDraw(buf);
            buf.drawTo(hdc, 0, 0);
        }
    }
}

class Win32Platform : Platform {
    this() {
    }
    bool registerWndClass() {
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
    override int enterMessageLoop() {
        MSG  msg;
        while (GetMessage(&msg, null, 0, 0))
        {
            TranslateMessage(&msg);
            DispatchMessage(&msg);
        }
        return msg.wParam;
    }
    override Window createWindow(string windowCaption, Window parent) {
        return new Win32Window(windowCaption, parent);
    }
}

extern(Windows)
int DLANGUIWinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance,
            LPSTR lpCmdLine, int nCmdShow) {
    int result;

    try
    {
        Runtime.initialize();
        result = myWinMain(hInstance, hPrevInstance, lpCmdLine, nCmdShow);
        //Runtime.terminate();
    }
    catch (Throwable e) // catch any uncaught exceptions
    {
        MessageBox(null, toUTF16z(e.toString()), "Error",
                    MB_OK | MB_ICONEXCLAMATION);
        result = 0;     // failed
    }

    return result;
}

string[] splitCmdLine(string line) {
    string[] res;
    int start = 0;
    bool insideQuotes = false;
    for (int i = 0; i <= line.length; i++) {
        char ch = i < line.length ? line[i] : 0;
        if (ch == '\"') {
            if (insideQuotes) {
                if (i > start)
                    res ~= line[start .. i];
                start = i + 1;
                insideQuotes = false;
            } else {
                insideQuotes = true;
                start = i + 1;
            }
        } else if (!insideQuotes && (ch == ' ' || ch == '\t' || ch == 0)) {
            if (i > start) {
                res ~= line[start .. i];
            }
            start = i + 1;
        }
    }
    return res;
}

int myWinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int iCmdShow)
{
	setFileLogger(std.stdio.File("ui.log", "w"));
	setLogLevel(LogLevel.Trace);
    Log.d("myWinMain()");
    string basePath = exePath();
    Log.i("Current executable: ", exePath());
    string cmdline = fromStringz(lpCmdLine);
    Log.i("Command line: ", cmdline);
    string[] args = splitCmdLine(cmdline);
    Log.i("Command line params: ", args);

    _cmdShow = iCmdShow;
    _hInstance = hInstance;

    Win32Platform platform = new Win32Platform();
    if (!platform.registerWndClass()) {
        MessageBoxA(null, "This program requires Windows NT!", "DLANGUI App".toStringz, MB_ICONERROR);
        return 0;
    }
    Platform.setInstance(platform);

	Win32FontManager fontMan = new Win32FontManager();
	FontManager.instance = fontMan;

    {
        import derelict.opengl3.gl3;
        DerelictGL3.load();

        // just to check OpenGL context
        Log.i("Trying to setup OpenGL context");
        Win32Window tmpWindow = new Win32Window("", null);
        destroy(tmpWindow);
        if (openglEnabled)
            Log.i("OpenGL support is enabled");
        else
            Log.w("OpenGL support is disabled");
        // process messages
        platform.enterMessageLoop();
    }

    // Load versions 1.2+ and all supported ARB and EXT extensions.

    Log.i("Entering UIAppMain: ", args);
    int result = UIAppMain(args);
    Log.i("UIAppMain returned ", result);
    return result;
}


extern(Windows)
LRESULT WndProc(HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam)
{
    HDC hdc;
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
        case WM_WINDOWPOSCHANGED:
            {
                WINDOWPOS * pos = cast(WINDOWPOS*)lParam;
                GetClientRect(hwnd, &rect);
                int dx = rect.right - rect.left;
                int dy = rect.bottom - rect.top;
                //window.onResize(pos.cx, pos.cy);
                window.onResize(dx, dy);
                InvalidateRect(hwnd, null, FALSE);
                //UpdateWindow(hwnd);
            }
            return 0;
        case WM_ERASEBKGND:
            return 1;
        case WM_PAINT:
            {
                //GetClientRect(hwnd, &rect);
                //int dx = rect.right - rect.left;
                //int dy = rect.bottom - rect.top;
                //window.onResize(dx, dy);
                if (window !is null)
                    window.onPaint();

            }
            return 0; // processed

        case WM_DESTROY:
            window.onDestroy();
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


