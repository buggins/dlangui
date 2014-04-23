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
import dlangui.widgets.styles;
import dlangui.widgets.widget;
import dlangui.graphics.drawbuf;
import dlangui.graphics.images;
import dlangui.graphics.fonts;
import dlangui.core.logger;

version (USE_OPENGL) {
    import dlangui.graphics.glsupport;
}

pragma(lib, "gdi32.lib");
pragma(lib, "user32.lib");
pragma(lib, "libpng15.lib");

/// this function should be defined in user application!
extern (C) int UIAppMain(string[] args);

immutable WIN_CLASS_NAME = "DLANGUI_APP";

__gshared HINSTANCE _hInstance;
__gshared int _cmdShow;

version (USE_OPENGL) {
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
}

class Win32Window : Window {
    Win32Platform _platform;
    HWND _hwnd;
    version (USE_OPENGL) {
        HGLRC _hGLRC; // opengl context
        HPALETTE _hPalette;
    }
    string _caption;
    Win32ColorDrawBuf _drawbuf;
    bool useOpengl;
    this(Win32Platform platform, string windowCaption, Window parent) {
        _platform = platform;
        _caption = windowCaption;
        _hwnd = CreateWindow(toUTF16z(WIN_CLASS_NAME),      // window class name
                            toUTF16z(windowCaption),  // window caption
                            WS_OVERLAPPEDWINDOW | WS_CLIPCHILDREN | WS_CLIPSIBLINGS,  // window style
                            CW_USEDEFAULT,        // initial x position
                            CW_USEDEFAULT,        // initial y position
                            CW_USEDEFAULT,        // initial x size
                            CW_USEDEFAULT,        // initial y size
                            null,                 // parent window handle
                            null,                 // window menu handle
                            _hInstance,           // program instance handle
                            cast(void*)this);                // creation parameters

        version (USE_OPENGL) {
            import derelict.opengl3.wgl;

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
    }

    version (USE_OPENGL) {
        private void paintUsingOpenGL() {
            // hack to stop infinite WM_PAINT loop
            PAINTSTRUCT ps;
            HDC hdc2 = BeginPaint(_hwnd, &ps);
            EndPaint(_hwnd, &ps);


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
			float a = 1.0f;
			float r = ((_backgroundColor >> 16) & 255) / 255.0f;
			float g = ((_backgroundColor >> 8) & 255) / 255.0f;
			float b = ((_backgroundColor >> 0) & 255) / 255.0f;
            glClearColor(r, g, b, a);
            glClear(GL_COLOR_BUFFER_BIT);

            GLDrawBuf buf = new GLDrawBuf(_dx, _dy, false);
            buf.beforeDrawing();
            static if (false) {
                // for testing for render
                buf.fillRect(Rect(100, 100, 200, 200), 0x704020);
                buf.fillRect(Rect(40, 70, 100, 120), 0x000000);
                buf.fillRect(Rect(80, 80, 150, 150), 0x80008000); // green
                drawableCache.get("exit").drawTo(buf, Rect(300, 100, 364, 164));
                drawableCache.get("btn_default_pressed").drawTo(buf, Rect(300, 200, 564, 264));
                drawableCache.get("btn_default_normal").drawTo(buf, Rect(300, 0, 400, 50));
                drawableCache.get("btn_default_selected").drawTo(buf, Rect(0, 0, 100, 50));
                FontRef fnt = currentTheme.font;
                fnt.drawText(buf, 40, 40, "Some Text 1234567890 !@#$^*", 0x80FF0000);
            } else {
                onDraw(buf);
            }
            buf.afterDrawing();
            SwapBuffers(hdc);
            wglMakeCurrent(hdc, null);
        }
    }

    ~this() {
        Log.d("Window destructor");
        version (USE_OPENGL) {
            import derelict.opengl3.wgl;
            if (_hGLRC) {
			    uninitShaders();
                wglMakeCurrent (null, null) ;
                wglDeleteContext(_hGLRC);
                _hGLRC = null;
            }
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
        //UpdateWindow(_hwnd);
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
        _platform.onWindowCreated(_hwnd, this);
    }
    void onDestroy() {
        Log.d("Window onDestroy");
        _platform.onWindowDestroyed(_hwnd, this);
    }

    private void paintUsingGDI() {
        PAINTSTRUCT ps;
        HDC hdc = BeginPaint(_hwnd, &ps);
        scope(exit) EndPaint(_hwnd, &ps);

        Win32ColorDrawBuf buf = getDrawBuf();
        buf.fill(_backgroundColor);
        onDraw(buf);
        buf.drawTo(hdc, 0, 0);
    }

    void onPaint() {
        Log.d("onPaint()");
        long paintStart = currentTimeMillis;
        version (USE_OPENGL) {
            if (useOpengl && _hGLRC) {
                paintUsingOpenGL();
            } else {
                paintUsingGDI();
            }
        } else {
            paintUsingGDI();
        }
        long paintEnd = currentTimeMillis;
        Log.d("WM_PAINT handling took ", paintEnd - paintStart, " ms");
    }

	protected ButtonDetails _lbutton;
	protected ButtonDetails _mbutton;
	protected ButtonDetails _rbutton;

    private bool _mouseTracking;
	private bool onMouse(uint message, uint flags, short x, short y) {
		//Log.d("Win32 Mouse Message ", message, " flags=", flags, " x=", x, " y=", y);
        MouseButton button = MouseButton.None;
        MouseAction action = MouseAction.ButtonDown;
        ButtonDetails * pbuttonDetails = null;
        short wheelDelta = 0;
        switch (message) {
            case WM_MOUSEMOVE:
                action = MouseAction.Move;
                break;
            case WM_LBUTTONDOWN:
                action = MouseAction.ButtonDown;
                button = MouseButton.Left;
                pbuttonDetails = &_lbutton;
                break;
            case WM_RBUTTONDOWN:
                action = MouseAction.ButtonDown;
                button = MouseButton.Right;
                pbuttonDetails = &_rbutton;
                break;
            case WM_MBUTTONDOWN:
                action = MouseAction.ButtonDown;
                button = MouseButton.Middle;
                pbuttonDetails = &_mbutton;
                break;
            case WM_LBUTTONUP:
                action = MouseAction.ButtonUp;
                button = MouseButton.Left;
                pbuttonDetails = &_lbutton;
                break;
            case WM_RBUTTONUP:
                action = MouseAction.ButtonUp;
                button = MouseButton.Right;
                pbuttonDetails = &_rbutton;
                break;
            case WM_MBUTTONUP:
                action = MouseAction.ButtonUp;
                button = MouseButton.Middle;
                pbuttonDetails = &_mbutton;
                break;
            case WM_MOUSELEAVE:
                Log.d("WM_MOUSELEAVE");
                action = MouseAction.Leave;
                break;
            case WM_MOUSEWHEEL:
                {
                    action = MouseAction.Wheel;
                    wheelDelta = (cast(short)(flags >> 16)) / 120;
                    POINT pt;
                    pt.x = x;
                    pt.y = y;
                    ScreenToClient(_hwnd, &pt);
                    x = cast(short)pt.x;
                    y = cast(short)pt.y;
                }
                break;
            default:
                // unsupported event
                return false;
        }
        if (action == MouseAction.ButtonDown) {
            pbuttonDetails.down(x, y, cast(ushort)flags);
        } else if (action == MouseAction.ButtonUp) {
            pbuttonDetails.up(x, y, cast(ushort)flags);
        }
        if (((message == WM_MOUSELEAVE) || (x < 0 || y < 0 || x > _dx || y > _dy)) && _mouseTracking) {
            action = MouseAction.Leave;
            Log.d("WM_MOUSELEAVE - releasing capture");
            _mouseTracking = false;
            ReleaseCapture();
        }
        if (message != WM_MOUSELEAVE && !_mouseTracking) {
            if (x >=0 && y >= 0 && x < _dx && y < _dy) {
                Log.d("Setting capture");
                _mouseTracking = true;
                SetCapture(_hwnd);
            }
        }
        MouseEvent event = new MouseEvent(action, button, cast(ushort)flags, x, y, wheelDelta);
        event.lbutton = _lbutton;
        event.rbutton = _rbutton;
        event.mbutton = _mbutton;
		bool res = dispatchMouseEvent(event);
        if (res) {
            Log.d("Calling update() after mouse event");
            update();
        }
        return res;
	}


    protected uint _keyFlags;

    protected void updateKeyFlags(KeyAction action, KeyFlag flag) {
        if (action == KeyAction.KeyDown)
            _keyFlags |= flag;
        else
            _keyFlags &= ~flag;
    }

    bool onKey(KeyAction action, uint keyCode, int repeatCount, dchar character = 0) {
        KeyEvent event;
        if (action == KeyAction.KeyDown || action == KeyAction.KeyUp) {
            switch(keyCode) {
                case KeyCode.SHIFT:
                    updateKeyFlags(action, KeyFlag.Shift);
                    break;
                case KeyCode.CONTROL:
                    updateKeyFlags(action, KeyFlag.Control);
                    break;
                case KeyCode.ALT:
                    updateKeyFlags(action, KeyFlag.Alt);
                    break;
                default:
                    break;
            }
            event = new KeyEvent(action, keyCode, _keyFlags);
        } else if (action == KeyAction.Text && character != 0) {
            dchar[] text;
            text ~= character;
            event = new KeyEvent(action, 0, _keyFlags, cast(dstring)text);
        }
        bool res = false;
        if (event !is null) {
            res = dispatchKeyEvent(event);
        }
        if (res) {
            Log.d("Calling update() after key event");
            update();
        }
        return res;
    }

    /// request window redraw
    override void invalidate() {
        InvalidateRect(_hwnd, null, FALSE);
		UpdateWindow(_hwnd);
    }

    /// after drawing, call to schedule redraw if animation is active
    override void scheduleAnimation() {
        invalidate();
    }

}

class Win32Platform : Platform {
    this() {
    }
    bool registerWndClass() {
        //MSG  msg;
        WNDCLASS wndclass;

        wndclass.style         = CS_HREDRAW | CS_VREDRAW | CS_OWNDC;
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
    private Win32Window[ulong] _windowMap;
    /// add window to window map
    void onWindowCreated(HWND hwnd, Win32Window window) {
        _windowMap[cast(ulong)hwnd] = window;
    }
    /// remove window from window map, returns true if there are some more windows left in map
    bool onWindowDestroyed(HWND hwnd, Win32Window window) {
        Win32Window wnd = getWindow(hwnd);
        if (wnd) {
            _windowMap.remove(cast(ulong)hwnd);
            destroy(window);
        }
        return _windowMap.length > 0;
    }
    /// returns number of currently active windows
    @property int windowCount() {
        return cast(int)_windowMap.length;
    }
    /// returns window instance by HWND
    Win32Window getWindow(HWND hwnd) {
        if ((cast(ulong)hwnd) in _windowMap)
            return _windowMap[cast(ulong)hwnd];
        return null;
    }
    override Window createWindow(string windowCaption, Window parent) {
        return new Win32Window(this, windowCaption, parent);
    }

    /// retrieves text from clipboard (when mouseBuffer == true, use mouse selection clipboard - under linux)
    override dstring getClipboardText(bool mouseBuffer = false) {
        dstring res = null;
        if (mouseBuffer)
            return res; // not supporetd under win32
        if (!IsClipboardFormatAvailable(CF_UNICODETEXT))
            return res; 
        if (!OpenClipboard(NULL)) 
            return res; 

        HGLOBAL hglb = GetClipboardData(CF_UNICODETEXT); 
        if (hglb != NULL) 
        { 
            LPTSTR lptstr = cast(LPTSTR)GlobalLock(hglb); 
            if (lptstr != NULL) 
            { 
                wstring w = fromWStringz(lptstr);
                res = toUTF32(w);

                GlobalUnlock(hglb); 
            } 
        } 

        CloseClipboard();
        //Log.d("getClipboardText(", res, ")");
        return res;
    }

    /// sets text to clipboard (when mouseBuffer == true, use mouse selection clipboard - under linux)
    override void setClipboardText(dstring text, bool mouseBuffer = false) {
        //Log.d("setClipboardText(", text, ")");
        if (text.length < 1 || mouseBuffer)
            return;
        if (!OpenClipboard(NULL))
            return; 
        EmptyClipboard();
        wstring w = toUTF16(text);
        HGLOBAL hglbCopy = GlobalAlloc(GMEM_MOVEABLE, 
                           (w.length + 1) * TCHAR.sizeof); 
        if (hglbCopy == NULL) { 
            CloseClipboard(); 
            return; 
        }
        LPTSTR lptstrCopy = cast(LPTSTR)GlobalLock(hglbCopy);
        for (int i = 0; i < w.length; i++) {
            lptstrCopy[i] = w[i];
        }
        lptstrCopy[w.length] = 0;
        GlobalUnlock(hglbCopy);
        SetClipboardData(CF_UNICODETEXT, hglbCopy); 
        CloseClipboard(); 
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

private __gshared Win32Platform platform;

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

    platform = new Win32Platform();
    if (!platform.registerWndClass()) {
        MessageBoxA(null, "This program requires Windows NT!", "DLANGUI App".toStringz, MB_ICONERROR);
        return 0;
    }
    Platform.setInstance(platform);


    if (true) {
        /// testing freetype font manager
        import dlangui.graphics.ftfonts;
        import win32.shlobj;
        FreeTypeFontManager ftfontMan = new FreeTypeFontManager();
        string fontsPath = "c:\\Windows\\Fonts\\";
        static if (false) { // SHGetFolderPathW not found in shell32.lib
            WCHAR szPath[MAX_PATH];
            const CSIDL_FLAG_NO_ALIAS = 0x1000;
            const CSIDL_FLAG_DONT_UNEXPAND = 0x2000;
            if(SUCCEEDED(SHGetFolderPathW(NULL,
                                          CSIDL_FONTS|CSIDL_FLAG_NO_ALIAS|CSIDL_FLAG_DONT_UNEXPAND,
                                          NULL,
                                          0,
                                          szPath.ptr)))
            {
                fontsPath = toUTF8(fromWStringz(szPath));
            }
        }
        ftfontMan.registerFont(fontsPath ~ "arial.ttf", FontFamily.SansSerif, "Arial", false, FontWeight.Normal);
        ftfontMan.registerFont(fontsPath ~ "arialbd.ttf", FontFamily.SansSerif, "Arial", false, FontWeight.Bold);
        ftfontMan.registerFont(fontsPath ~ "arialbi.ttf", FontFamily.SansSerif, "Arial", true, FontWeight.Bold);
        ftfontMan.registerFont(fontsPath ~ "ariali.ttf", FontFamily.SansSerif, "Arial", true, FontWeight.Normal);
        ftfontMan.registerFont(fontsPath ~ "cour.ttf", FontFamily.MonoSpace, "Courier New", false, FontWeight.Normal);
        ftfontMan.registerFont(fontsPath ~ "courbd.ttf", FontFamily.MonoSpace, "Courier New", false, FontWeight.Bold);
        ftfontMan.registerFont(fontsPath ~ "courbi.ttf", FontFamily.MonoSpace, "Courier New", true, FontWeight.Bold);
        ftfontMan.registerFont(fontsPath ~ "couri.ttf", FontFamily.MonoSpace, "Courier New", true, FontWeight.Normal);
        ftfontMan.registerFont(fontsPath ~ "times.ttf", FontFamily.Serif, "Times New Roman", false, FontWeight.Normal);
        ftfontMan.registerFont(fontsPath ~ "timesbd.ttf", FontFamily.Serif, "Times New Roman", false, FontWeight.Bold);
        ftfontMan.registerFont(fontsPath ~ "timesbi.ttf", FontFamily.Serif, "Times New Roman", true, FontWeight.Bold);
        ftfontMan.registerFont(fontsPath ~ "timesi.ttf", FontFamily.Serif, "Times New Roman", true, FontWeight.Normal);
        FontManager.instance = ftfontMan;
    }

    // use Win32 font manager
    if (FontManager.instance is null) {
	    //Win32FontManager fontMan = new Win32FontManager();
	    FontManager.instance = new Win32FontManager();
    }

	currentTheme = createDefaultTheme();

    version (USE_OPENGL) {
        import derelict.opengl3.gl3;
        DerelictGL3.load();

        // just to check OpenGL context
        Log.i("Trying to setup OpenGL context");
        Win32Window tmpWindow = new Win32Window(platform, "", null);
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
    Win32Window windowParam = p is null ? null : cast(Win32Window)(p);
    Win32Window window = platform.getWindow(hwnd);
    if (windowParam !is null && window !is null)
        assert(window is windowParam);
    if (window is null && windowParam !is null) {
        Log.e("Cannot find window in map by HWND");
    }

    switch (message)
    {
        case WM_CREATE:
            {
                CREATESTRUCT * pcreateStruct = cast(CREATESTRUCT*)lParam;
                window = cast(Win32Window)pcreateStruct.lpCreateParams;
                void * ptr = cast(void*) window;
                SetWindowLongPtr(hwnd, GWLP_USERDATA, cast(LONG_PTR)ptr);
                window._hwnd = hwnd;
                window.onCreate();
            }
            return 0;
        case WM_DESTROY:
            if (window !is null)
                window.onDestroy();
            if (platform.windowCount == 0)
                PostQuitMessage(0);
            return 0;
        case WM_WINDOWPOSCHANGED:
            {
                if (window !is null) {
                    WINDOWPOS * pos = cast(WINDOWPOS*)lParam;
                    GetClientRect(hwnd, &rect);
                    int dx = rect.right - rect.left;
                    int dy = rect.bottom - rect.top;
                    //window.onResize(pos.cx, pos.cy);
                    window.onResize(dx, dy);
                    InvalidateRect(hwnd, null, FALSE);
                }
            }
            return 0;
        case WM_ERASEBKGND:
            // processed
            return 1;
        case WM_PAINT:
            {
                if (window !is null)
                    window.onPaint();
            }
            return 0; // processed
        case WM_MOUSELEAVE:
		case WM_MOUSEMOVE:
		case WM_LBUTTONDOWN:
		case WM_MBUTTONDOWN:
		case WM_RBUTTONDOWN:
		case WM_LBUTTONUP:
		case WM_MBUTTONUP:
		case WM_RBUTTONUP:
        case WM_MOUSEWHEEL:
			if (window !is null) {
				if (window.onMouse(message, cast(uint)wParam, cast(short)(lParam & 0xFFFF), cast(short)((lParam >> 16) & 0xFFFF)))
                    return 0; // processed
            }
            // not processed - default handling
            return DefWindowProc(hwnd, message, wParam, lParam);
        case WM_KEYDOWN:
        case WM_KEYUP:
			if (window !is null) {
                int repeatCount = lParam & 0xFFFF;
				if (window.onKey(message == WM_KEYDOWN ? KeyAction.KeyDown : KeyAction.KeyUp, wParam, repeatCount))
                    return 0; // processed
            }
            break;
        case WM_UNICHAR:
			if (window !is null) {
                int repeatCount = lParam & 0xFFFF;
				if (window.onKey(KeyAction.Text, wParam, repeatCount, wParam == UNICODE_NOCHAR ? 0 : wParam))
                    return 1; // processed
                return 1;
            }
            break;
        case WM_CHAR:
			if (window !is null) {
                int repeatCount = lParam & 0xFFFF;
				if (window.onKey(KeyAction.Text, wParam, repeatCount, wParam == UNICODE_NOCHAR ? 0 : wParam))
                    return 1; // processed
                return 1;
            }
            break;
        case WM_GETMINMAXINFO:
        case WM_NCCREATE:
        case WM_NCCALCSIZE:
        default:
            //Log.d("Unhandled message ", message);
            break;
    }

    return DefWindowProc(hwnd, message, wParam, lParam);
}

//===========================================
// end of version(Windows)
//===========================================
} 


