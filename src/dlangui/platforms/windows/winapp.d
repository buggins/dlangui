// Written in the D programming language.

/**

This module contains implementation of Win32 platform support

Provides Win32Window and Win32Platform classes.

Usually you don't need to use this module directly.


Synopsis:

----
import dlangui.platforms.windows.winapp;
----

Copyright: Vadim Lopatin, 2014
License:   Boost License 1.0
Authors:   Vadim Lopatin, coolreader.org@gmail.com
*/
module dlangui.platforms.windows.winapp;

public import dlangui.core.config;

static if (BACKEND_WIN32):

import core.runtime;
import core.sys.windows.windows;
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
import dlangui.core.files;

static if (ENABLE_OPENGL) {
    import dlangui.graphics.glsupport;
}

// specify debug=DebugMouseEvents for logging mouse handling
// specify debug=DebugRedraw for logging drawing and layouts handling
// specify debug=DebugKeys for logging of key events

pragma(lib, "gdi32.lib");
pragma(lib, "user32.lib");

/// this function should be defined in user application!
extern (C) int UIAppMain(string[] args);

immutable WIN_CLASS_NAME = "DLANGUI_APP";

__gshared HINSTANCE _hInstance;
__gshared int _cmdShow;

static if (ENABLE_OPENGL) {
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

const uint CUSTOM_MESSAGE_ID = WM_USER + 1;

static if (ENABLE_OPENGL) {

    /// Shared opengl context helper
    struct SharedGLContext {
        import derelict.opengl3.wgl;

        HGLRC _hGLRC; // opengl context
        HPALETTE _hPalette;
        bool _error;
        /// Init OpenGL context, if not yet initialized
        bool init(HDC hDC) {
            if (_hGLRC) {
                // just setup pixel format
                if (setupPixelFormat(hDC)) {
                    Log.i("OpenGL context already exists. Setting pixel format.");
                } else {
                    Log.e("Cannot setup pixel format");
                }
                return true;
            }
            if (_error)
                return false;
            if (setupPixelFormat(hDC)) {
                _hPalette = setupPalette(hDC);
                _hGLRC = wglCreateContext(hDC);
                if (_hGLRC) {
                    bind(hDC);
                    bool initialized = initGLSupport(Platform.instance.GLVersionMajor < 3);
                    unbind(hDC);
                    if (!initialized) {
                        uninit();
                        Log.e("Failed to init OpenGL shaders");
                        _error = true;
                        return false;
                    }
                    return true;
                } else {
                    _error = true;
                    return false;
                }
            } else {
                Log.e("Cannot setup pixel format");
                _error = true;
                return false;
            }
        }
        void uninit() {
            if (_hGLRC) {
                wglDeleteContext(_hGLRC);
                _hGLRC = null;
            }
        }
        /// make this context current for DC
        void bind(HDC hDC) {
            if (!wglMakeCurrent(hDC, _hGLRC)) {
                import std.string : format;
                Log.e("wglMakeCurrent is failed. GetLastError=%x".format(GetLastError()));
            }
        }
        /// make null context current for DC
        void unbind(HDC hDC) {
            //wglMakeCurrent(hDC, null);
            wglMakeCurrent(null, null);
        }
        void swapBuffers(HDC hDC) {
            SwapBuffers(hDC);
        }
    }

    /// OpenGL context to share between windows
    __gshared SharedGLContext sharedGLContext;
}

interface UnknownWindowMessageHandler {
    /// return true if message is handled, put return value into result
    bool onUnknownWindowMessage(HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam, ref LRESULT result);
}

class Win32Window : Window {
    Win32Platform _platform;

    HWND _hwnd;
    dstring _caption;
    Win32ColorDrawBuf _drawbuf;
    private Win32Window _w32parent;
    bool useOpengl;

    /// win32 only - return window handle
    @property HWND windowHandle() {
        return _hwnd;
    }

    this(Win32Platform platform, dstring windowCaption, Window parent, uint flags, uint width = 0, uint height = 0) {
        _w32parent = cast(Win32Window)parent;
        HWND parenthwnd = _w32parent ? _w32parent._hwnd : null;
        _dx = width;
        _dy = height;
        if (!_dx)
            _dx = 600;
        if (!_dy)
            _dy = 400;
        _platform = platform;
        _caption = windowCaption;
        _windowState = WindowState.hidden;
        _flags = flags;
        uint ws = WS_CLIPCHILDREN | WS_CLIPSIBLINGS;
        if (flags & WindowFlag.Resizable)
            ws |= WS_OVERLAPPEDWINDOW;
        else
            ws |= WS_OVERLAPPED | WS_CAPTION | WS_CAPTION | WS_BORDER | WS_SYSMENU;
        //if (flags & WindowFlag.Fullscreen)
        //    ws |= SDL_WINDOW_FULLSCREEN;
        Rect screenRc = getScreenDimensions();
        Log.d("Screen dimensions: ", screenRc);

        int x = CW_USEDEFAULT;
        int y = CW_USEDEFAULT;

        if (flags & WindowFlag.Fullscreen) {
            // fullscreen
            x = screenRc.left;
            y = screenRc.top;
            _dx = screenRc.width;
            _dy = screenRc.height;
            ws = WS_POPUP;
        }
        if (flags & WindowFlag.Borderless) {
            ws = WS_POPUP | WS_SYSMENU;
        }


        _hwnd = CreateWindowW(toUTF16z(WIN_CLASS_NAME),      // window class name
                            toUTF16z(windowCaption),  // window caption
                            ws,  // window style
                            x,        // initial x position
                            y,        // initial y position
                            _dx,        // initial x size
                            _dy,        // initial y size
                            parenthwnd,                 // parent window handle
                            null,                 // window menu handle
                            _hInstance,           // program instance handle
                            cast(void*)this);                // creation parameters
        static if (ENABLE_OPENGL) {
            /* initialize OpenGL rendering */
            HDC hDC = GetDC(_hwnd);

            if (openglEnabled) {
                useOpengl = sharedGLContext.init(hDC);
            }
        }

        RECT rect;
        GetWindowRect(_hwnd, &rect);
        handleWindowStateChange(WindowState.unspecified, Rect(rect.left, rect.top, _dx, _dy));

        if (platform.defaultWindowIcon.length != 0)
            windowIcon = drawableCache.getImage(platform.defaultWindowIcon);
    }

    static if (ENABLE_OPENGL) {
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
            sharedGLContext.bind(hdc);
            //_glSupport = _gl;
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
            sharedGLContext.swapBuffers(hdc);
            //sharedGLContext.unbind(hdc);
            destroy(buf);
        }
    }

    protected Rect getScreenDimensions() {
        MONITORINFO monitor_info;
        monitor_info.cbSize = monitor_info.sizeof;
        HMONITOR hMonitor;
        if (_hwnd) {
            hMonitor = MonitorFromWindow(_hwnd, MONITOR_DEFAULTTONEAREST);
        } else {
            hMonitor = MonitorFromPoint(POINT(0,0), MONITOR_DEFAULTTOPRIMARY);
        }
        GetMonitorInfo(hMonitor,
                       &monitor_info);
        Rect res;
        res.left = monitor_info.rcMonitor.left;
        res.top = monitor_info.rcMonitor.top;
        res.right = monitor_info.rcMonitor.right;
        res.bottom = monitor_info.rcMonitor.bottom;
        return res;
    }

    protected bool _destroying;
    ~this() {
        debug Log.d("Window destructor");
        _destroying = true;
        if (_drawbuf) {
            destroy(_drawbuf);
            _drawbuf = null;
        }
            
        /*
        static if (ENABLE_OPENGL) {
            import derelict.opengl3.wgl;
            if (_hGLRC) {
                //glSupport.uninitShaders();
                //destroy(_glSupport);
                //_glSupport = null;
                //_gl = null;
                wglMakeCurrent (null, null) ;
                wglDeleteContext(_hGLRC);
                _hGLRC = null;
            }
        }
        */
        if (_hwnd)
            DestroyWindow(_hwnd);
        _hwnd = null;
    }

    /// post event to handle in UI thread (this method can be used from background thread)
    override void postEvent(CustomEvent event) {
        super.postEvent(event);
        PostMessageW(_hwnd, CUSTOM_MESSAGE_ID, 0, event.uniqueId);
    }

    /// set handler for files dropped to app window
    override @property Window onFilesDropped(void delegate(string[]) handler) { 
        super.onFilesDropped(handler);
        DragAcceptFiles(_hwnd, handler ? TRUE : FALSE);
        return this; 
    }

    private long _nextExpectedTimerTs;
    private UINT_PTR _timerId = 1;

    /// schedule timer for interval in milliseconds - call window.onTimer when finished
    override protected void scheduleSystemTimer(long intervalMillis) {
        if (intervalMillis < 10)
            intervalMillis = 10;
        long nextts = currentTimeMillis + intervalMillis;
        if (_timerId && _nextExpectedTimerTs && _nextExpectedTimerTs < nextts + 10)
            return; // don't reschedule timer, timer event will be received soon
        if (_hwnd) {
            //_timerId = 
            SetTimer(_hwnd, _timerId, cast(uint)intervalMillis, null);
            _nextExpectedTimerTs = nextts;
        }
    }

    void handleTimer(UINT_PTR timerId) {
        //Log.d("handleTimer id=", timerId);
        if (timerId == _timerId) {
            KillTimer(_hwnd, timerId);
            //_timerId = 0;
            _nextExpectedTimerTs = 0;
            onTimer();
        }
    }

    /// custom window message handler
    Signal!UnknownWindowMessageHandler onUnknownWindowMessage;
    private LRESULT handleUnknownWindowMessage(UINT message, WPARAM wParam, LPARAM lParam) {
        if (onUnknownWindowMessage.assigned) {
            LRESULT res;
            if (onUnknownWindowMessage(_hwnd, message, wParam, lParam, res))
                return res;
        }
        return DefWindowProc(_hwnd, message, wParam, lParam);
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
        _drawbuf.resetClipping();
        return _drawbuf;
    }
    override void show() {
        if (!_mainWidget) {
            Log.e("Window is shown without main widget");
            _mainWidget = new Widget();
        }
        ReleaseCapture();
        if (_mainWidget) {
            _mainWidget.measure(SIZE_UNSPECIFIED, SIZE_UNSPECIFIED);
            if (flags & WindowFlag.MeasureSize)
                resizeWindow(Point(_mainWidget.measuredWidth, _mainWidget.measuredHeight));
            else
                adjustWindowOrContentSize(_mainWidget.measuredWidth, _mainWidget.measuredHeight);
        }
        
        adjustPositionDuringShow();
        
        if (_flags & WindowFlag.Fullscreen) {
            Rect rc = getScreenDimensions();
            SetWindowPos(_hwnd, HWND_TOPMOST, 0, 0, rc.width, rc.height, SWP_SHOWWINDOW);
            _windowState = WindowState.fullscreen;
        } else {
            ShowWindow(_hwnd, SW_SHOWNORMAL);
            _windowState = WindowState.normal;
        }
        if (_mainWidget)
            _mainWidget.setFocus();
        SetFocus(_hwnd);
        //UpdateWindow(_hwnd);
    }

    override @property Window parentWindow() {
        return _w32parent;
    }
    
    override protected void handleWindowActivityChange(bool isWindowActive) {
        super.handleWindowActivityChange(isWindowActive);
    }
    
    override @property bool isActive() {
        return _hwnd == GetForegroundWindow();
    }
    
    override @property dstring windowCaption() const {
        return _caption;
    }

    override @property void windowCaption(dstring caption) {
        _caption = caption;
        if (_hwnd) {
            Log.d("windowCaption ", caption);
            SetWindowTextW(_hwnd, toUTF16z(_caption));
        }
    }

    /// change window state, position, or size; returns true if successful, false if not supported by platform
    override bool setWindowState(WindowState newState, bool activate = false, Rect newWindowRect = RECT_VALUE_IS_NOT_SET) {
        if (!_hwnd)
            return false;
        bool res = false;
        // change state and activate support
        switch(newState) {
            case WindowState.unspecified:
                if (activate) {
                    switch (_windowState) {
                        case WindowState.hidden:
                            // show hidden window
                            ShowWindow(_hwnd, SW_SHOW);
                            res = true;
                            break;
                        case WindowState.normal:
                            ShowWindow(_hwnd, SW_SHOWNORMAL);
                            res = true;
                            break;
                        case WindowState.fullscreen:
                            ShowWindow(_hwnd, SW_SHOWNORMAL);
                            res = true;
                            break;
                        case WindowState.minimized:
                            ShowWindow(_hwnd, SW_SHOWMINIMIZED);
                            res = true;
                            break;
                        case WindowState.maximized:
                            ShowWindow(_hwnd, SW_SHOWMAXIMIZED);
                            res = true;
                            break;
                        default:
                            break;
                    }
                    res = true;
                }
                break;
            case WindowState.maximized:
                if (_windowState != WindowState.maximized || activate) {
                    ShowWindow(_hwnd, activate ? SW_SHOWMAXIMIZED : SW_MAXIMIZE);
                    res = true;
                }
                break;
            case WindowState.minimized:
                if (_windowState != WindowState.minimized || activate) {
                    ShowWindow(_hwnd, activate ? SW_SHOWMINIMIZED : SW_MINIMIZE);
                    res = true;
                }
                break;
            case WindowState.hidden:
                if (_windowState != WindowState.hidden) {
                    ShowWindow(_hwnd, SW_HIDE);
                    res = true;
                }
                break;
            case WindowState.normal: 
                if (_windowState != WindowState.normal || activate) {
                    ShowWindow(_hwnd, activate ? SW_SHOWNORMAL : SW_SHOWNA); // SW_RESTORE
                    res = true;
                }
                break;

            default:
                break;
        }
        // change size and/or position
        bool rectChanged = false;
        if (newWindowRect != RECT_VALUE_IS_NOT_SET && (newState == WindowState.normal || newState == WindowState.unspecified)) {
            UINT flags = SWP_NOOWNERZORDER | SWP_NOZORDER;
            if (!activate)
                flags |= SWP_NOACTIVATE;
            if (newWindowRect.top == int.min || newWindowRect.left == int.min) {
                // no position specified
                if (newWindowRect.bottom != int.min && newWindowRect.right != int.min) {
                    // change size only
                    SetWindowPos(_hwnd, NULL, 0, 0, newWindowRect.right + 2 * GetSystemMetrics(SM_CXDLGFRAME), newWindowRect.bottom + GetSystemMetrics(SM_CYCAPTION) + 2 * GetSystemMetrics(SM_CYDLGFRAME), flags | SWP_NOMOVE);
                    rectChanged = true;
                    res = true;
                }
            } else {
                if (newWindowRect.bottom != int.min && newWindowRect.right != int.min) {
                    // change size and position
                    SetWindowPos(_hwnd, NULL, newWindowRect.left, newWindowRect.top, newWindowRect.right + 2 * GetSystemMetrics(SM_CXDLGFRAME), newWindowRect.bottom + GetSystemMetrics(SM_CYCAPTION) + 2 * GetSystemMetrics(SM_CYDLGFRAME), flags);
                    rectChanged = true;
                    res = true;
                } else {
                    // change position only
                    SetWindowPos(_hwnd, NULL, newWindowRect.left, newWindowRect.top, 0, 0, flags | SWP_NOSIZE);
                    rectChanged = true;
                    res = true;
                }
            }
        }
        
        if (rectChanged) {
            handleWindowStateChange(newState, Rect(newWindowRect.left == int.min ? _windowRect.left : newWindowRect.left, 
                newWindowRect.top == int.min ? _windowRect.top : newWindowRect.top, newWindowRect.right == int.min ? _windowRect.right : newWindowRect.right, 
                newWindowRect.bottom == int.min ? _windowRect.bottom : newWindowRect.bottom));
        }
        else
            handleWindowStateChange(newState, RECT_VALUE_IS_NOT_SET);
        
        return res;
    }

    void onCreate() {
        Log.d("Window onCreate");
        _platform.onWindowCreated(_hwnd, this);
    }
    void onDestroy() {
        Log.d("Window onDestroy");
        _platform.onWindowDestroyed(_hwnd, this);
    }

    protected bool _closeCalled;
    /// close window
    override void close() {
        if (_closeCalled)
            return;
        _closeCalled = true;
        Log.d("Window.close()");
        _platform.closeWindow(this);
    }
    
    override protected void handleWindowStateChange(WindowState newState, Rect newWindowRect = RECT_VALUE_IS_NOT_SET) {
        if (_destroying)
            return;
        super.handleWindowStateChange(newState, newWindowRect);
    }

    HICON _icon;

    uint _cursorType;

    HANDLE[ushort] _cursorCache;

    HANDLE loadCursor(ushort id) {
        if (id in _cursorCache)
            return _cursorCache[id];
        HANDLE h = LoadCursor(null, MAKEINTRESOURCE(id));
        _cursorCache[id] = h;
        return h;
    }

    void onSetCursorType() {
        HANDLE winCursor = null;
        switch (_cursorType) with(CursorType)
        {
            case None:
                winCursor = null;
                break;
            case Parent:
                break;
            case Arrow:
                winCursor = loadCursor(IDC_ARROW);
                break;
            case IBeam:
                winCursor = loadCursor(IDC_IBEAM);
                break;
            case Wait:
                winCursor = loadCursor(IDC_WAIT);
                break;
            case Crosshair:
                winCursor = loadCursor(IDC_CROSS);
                break;
            case WaitArrow:
                winCursor = loadCursor(IDC_APPSTARTING);
                break;
            case SizeNWSE:
                winCursor = loadCursor(IDC_SIZENWSE);
                break;
            case SizeNESW:
                winCursor = loadCursor(IDC_SIZENESW);
                break;
            case SizeWE:
                winCursor = loadCursor(IDC_SIZEWE);
                break;
            case SizeNS:
                winCursor = loadCursor(IDC_SIZENS);
                break;
            case SizeAll:
                winCursor = loadCursor(IDC_SIZEALL);
                break;
            case No:
                winCursor = loadCursor(IDC_NO);
                break;
            case Hand:
                winCursor = loadCursor(IDC_HAND);
                break;
            default:
                break;
        }
        SetCursor(winCursor);
    }

    /// sets cursor type for window
    override protected void setCursorType(uint cursorType) {
        // override to support different mouse cursors
        _cursorType = cursorType;
        onSetCursorType();
    }

    /// sets window icon
    @property override void windowIcon(DrawBufRef buf) {
        if (_icon)
            DestroyIcon(_icon);
        _icon = null;
        ColorDrawBuf icon = cast(ColorDrawBuf)buf.get;
        if (!icon) {
            Log.e("Trying to set null icon for window");
            return;
        }
        Win32ColorDrawBuf resizedicon = new Win32ColorDrawBuf(icon, 32, 32);
        resizedicon.invertAlpha();
        ICONINFO ii;
        HBITMAP mask = resizedicon.createTransparencyBitmap();
        HBITMAP color = resizedicon.destroyLeavingBitmap();
        ii.fIcon = TRUE;
        ii.xHotspot = 0;
        ii.yHotspot = 0;
        ii.hbmMask = mask;
        ii.hbmColor = color;
        _icon = CreateIconIndirect(&ii);
        if (_icon) {
            SendMessageW(_hwnd, WM_SETICON, ICON_SMALL, cast(LPARAM)_icon);
            SendMessageW(_hwnd, WM_SETICON, ICON_BIG, cast(LPARAM)_icon);
        } else {
            Log.e("failed to create icon");
        }
        if (mask)
            DeleteObject(mask);
        DeleteObject(color);
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
        debug(DebugRedraw) Log.d("onPaint()");
        long paintStart = currentTimeMillis;
        static if (ENABLE_OPENGL) {
            if (useOpengl && sharedGLContext._hGLRC) {
                paintUsingOpenGL();
            } else {
                paintUsingGDI();
            }
        } else {
            paintUsingGDI();
        }
        long paintEnd = currentTimeMillis;
        debug(DebugRedraw) Log.d("WM_PAINT handling took ", paintEnd - paintStart, " ms");
    }

    protected ButtonDetails _lbutton;
    protected ButtonDetails _mbutton;
    protected ButtonDetails _rbutton;

    private void updateButtonsState(uint flags) {
        if (!(flags & MK_LBUTTON) && _lbutton.isDown)
            _lbutton.reset();
        if (!(flags & MK_MBUTTON) && _mbutton.isDown)
            _mbutton.reset();
        if (!(flags & MK_RBUTTON) && _rbutton.isDown)
            _rbutton.reset();
    }

    private bool _mouseTracking;
    private bool onMouse(uint message, uint flags, short x, short y) {
        debug(DebugMouseEvents) Log.d("Win32 Mouse Message ", message, " flags=", flags, " x=", x, " y=", y);
        MouseButton button = MouseButton.None;
        MouseAction action = MouseAction.ButtonDown;
        ButtonDetails * pbuttonDetails = null;
        short wheelDelta = 0;
        switch (message) {
            case WM_MOUSEMOVE:
                action = MouseAction.Move;
                updateButtonsState(flags);
                break;
            case WM_LBUTTONDOWN:
                action = MouseAction.ButtonDown;
                button = MouseButton.Left;
                pbuttonDetails = &_lbutton;
                SetFocus(_hwnd);
                break;
            case WM_RBUTTONDOWN:
                action = MouseAction.ButtonDown;
                button = MouseButton.Right;
                pbuttonDetails = &_rbutton;
                SetFocus(_hwnd);
                break;
            case WM_MBUTTONDOWN:
                action = MouseAction.ButtonDown;
                button = MouseButton.Middle;
                pbuttonDetails = &_mbutton;
                SetFocus(_hwnd);
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
                debug(DebugMouseEvents) Log.d("WM_MOUSELEAVE");
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
        if (((message == WM_MOUSELEAVE) || (x < 0 || y < 0 || x >= _dx || y >= _dy)) && _mouseTracking) {
            if (!isMouseCaptured() || (!_lbutton.isDown && !_rbutton.isDown && !_mbutton.isDown)) {
                action = MouseAction.Leave;
                debug(DebugMouseEvents) Log.d("Win32Window.onMouse releasing capture");
                _mouseTracking = false;
                ReleaseCapture();
            }
        }
        if (message != WM_MOUSELEAVE && !_mouseTracking) {
            if (x >=0 && y >= 0 && x < _dx && y < _dy) {
                debug(DebugMouseEvents) Log.d("Win32Window.onMouse Setting capture");
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
            //Log.v("Calling update() after mouse event");
            update();
        }
        return res;
    }


    protected uint _keyFlags;

    protected void updateKeyFlags(KeyAction action, KeyFlag flag, uint preserveFlag) {
        if (action == KeyAction.KeyDown)
            _keyFlags |= flag;
        else {
            if (preserveFlag && (_keyFlags & preserveFlag) == preserveFlag) {
                // e.g. when both lctrl and rctrl are pressed, and lctrl is up, preserve rctrl flag
                _keyFlags = (_keyFlags & ~flag) | preserveFlag;
            } else {
                _keyFlags &= ~flag;
            }
        }
    }

    bool onKey(KeyAction action, uint keyCode, int repeatCount, dchar character = 0, bool syskey = false) {
        debug(KeyInput) Log.d("enter onKey action=", action, " keyCode=", keyCode, " char=", character, "(", cast(int)character, ")", " syskey=", syskey, "    _keyFlags=", "%04x"d.format(_keyFlags));
        KeyEvent event;
        if (syskey)
            _keyFlags |= KeyFlag.Alt;
        //else
        //    _keyFlags &= ~KeyFlag.Alt;
        uint oldFlags = _keyFlags;
        if (action == KeyAction.KeyDown || action == KeyAction.KeyUp) {
            switch(keyCode) {
                case KeyCode.LSHIFT:
                    updateKeyFlags(action, KeyFlag.LShift, KeyFlag.RShift);
                    break;
                case KeyCode.RSHIFT:
                    updateKeyFlags(action, KeyFlag.RShift, KeyFlag.LShift);
                    break;
                case KeyCode.LCONTROL:
                    updateKeyFlags(action, KeyFlag.LControl, KeyFlag.RControl);
                    break;
                case KeyCode.RCONTROL:
                    updateKeyFlags(action, KeyFlag.RControl, KeyFlag.LControl);
                    break;
                case KeyCode.LALT:
                    updateKeyFlags(action, KeyFlag.LAlt, KeyFlag.RAlt);
                    break;
                case KeyCode.RALT:
                    updateKeyFlags(action, KeyFlag.RAlt, KeyFlag.LAlt);
                    break;
                case KeyCode.LWIN:
                    updateKeyFlags(action, KeyFlag.LMenu, KeyFlag.RMenu);
                    break;
                case KeyCode.RWIN:
                    updateKeyFlags(action, KeyFlag.RMenu, KeyFlag.LMenu);
                    break;
                //case KeyCode.WIN:
                case KeyCode.CONTROL:
                case KeyCode.SHIFT:
                case KeyCode.ALT:
                //case KeyCode.WIN:
                    break;
                default:
                    updateKeyFlags((GetKeyState(VK_LCONTROL) & 0x8000) != 0 ? KeyAction.KeyDown : KeyAction.KeyUp, KeyFlag.LControl, KeyFlag.RControl);
                    updateKeyFlags((GetKeyState(VK_RCONTROL) & 0x8000) != 0 ? KeyAction.KeyDown : KeyAction.KeyUp, KeyFlag.RControl, KeyFlag.LControl);
                    updateKeyFlags((GetKeyState(VK_LSHIFT) & 0x8000) != 0 ? KeyAction.KeyDown : KeyAction.KeyUp, KeyFlag.LShift, KeyFlag.RShift);
                    updateKeyFlags((GetKeyState(VK_RSHIFT) & 0x8000) != 0 ? KeyAction.KeyDown : KeyAction.KeyUp, KeyFlag.RShift, KeyFlag.LShift);
                    updateKeyFlags((GetKeyState(VK_LWIN) & 0x8000) != 0 ? KeyAction.KeyDown : KeyAction.KeyUp, KeyFlag.LMenu, KeyFlag.RMenu);
                    updateKeyFlags((GetKeyState(VK_RWIN) & 0x8000) != 0 ? KeyAction.KeyDown : KeyAction.KeyUp, KeyFlag.RMenu, KeyFlag.LMenu);
                    updateKeyFlags((GetKeyState(VK_LMENU) & 0x8000) != 0 ? KeyAction.KeyDown : KeyAction.KeyUp, KeyFlag.LAlt, KeyFlag.RAlt);
                    updateKeyFlags((GetKeyState(VK_RMENU) & 0x8000) != 0 ? KeyAction.KeyDown : KeyAction.KeyUp, KeyFlag.RAlt, KeyFlag.LAlt);
                    //updateKeyFlags((GetKeyState(VK_LALT) & 0x8000) != 0 ? KeyAction.KeyDown : KeyAction.KeyUp, KeyFlag.LAlt, KeyFlag.RAlt);
                    //updateKeyFlags((GetKeyState(VK_RALT) & 0x8000) != 0 ? KeyAction.KeyDown : KeyAction.KeyUp, KeyFlag.RAlt, KeyFlag.LAlt);
                    break;
            }
            //updateKeyFlags((GetKeyState(VK_CONTROL) & 0x8000) != 0 ? KeyAction.KeyDown : KeyAction.KeyUp, KeyFlag.Control);
            //updateKeyFlags((GetKeyState(VK_SHIFT) & 0x8000) != 0 ? KeyAction.KeyDown : KeyAction.KeyUp, KeyFlag.Shift);
            //updateKeyFlags((GetKeyState(VK_MENU) & 0x8000) != 0 ? KeyAction.KeyDown : KeyAction.KeyUp, KeyFlag.Alt);
            if (keyCode == 0xBF)
                keyCode = KeyCode.KEY_DIVIDE;

            debug(KeyInput) {
                if (oldFlags != _keyFlags) {
                    debug(KeyInput) Log.d(" flags updated: onKey action=", action, " keyCode=", keyCode, " char=", character, "(", cast(int)character, ")", " syskey=", syskey, "    _keyFlags=", "%04x"d.format(_keyFlags));
                }
                //if (action == KeyAction.KeyDown)
                //    Log.d("keydown, keyFlags=", _keyFlags);
            }

            event = new KeyEvent(action, keyCode, _keyFlags);
        } else if (action == KeyAction.Text && character != 0) {
            bool ctrlAZKeyCode = (character >= 1 && character <= 26);
            if ((_keyFlags & (KeyFlag.Control | KeyFlag.Alt)) && ctrlAZKeyCode) {
                event = new KeyEvent(action, KeyCode.KEY_A + character - 1, _keyFlags);
            } else {
                dchar[] text;
                text ~= character;
                uint newFlags = _keyFlags;
                if ((newFlags & KeyFlag.Alt) && (newFlags & KeyFlag.Control)) {
                    newFlags &= (~(KeyFlag.LRAlt)) & (~(KeyFlag.LRControl));
                    debug(KeyInput) Log.d(" flags updated for text: onKey action=", action, " keyCode=", keyCode, " char=", character, "(", cast(int)character, ")", " syskey=", syskey, "    _keyFlags=", "%04x"d.format(_keyFlags));
                }
                event = new KeyEvent(action, 0, newFlags, cast(dstring)text);
            }
        }
        bool res = false;
        if (event !is null) {
            res = dispatchKeyEvent(event);
        }
        if (res) {
            debug(DebugRedraw) Log.d("Calling update() after key event");
            update();
        }
        return res;
    }

    /// request window redraw
    override void invalidate() {
        InvalidateRect(_hwnd, null, FALSE);
        //UpdateWindow(_hwnd);
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
        WNDCLASSW wndclass;

        wndclass.style         = CS_HREDRAW | CS_VREDRAW | CS_OWNDC;
        wndclass.lpfnWndProc   = cast(WNDPROC)&WndProc;
        wndclass.cbClsExtra    = 0;
        wndclass.cbWndExtra    = 0;
        wndclass.hInstance     = _hInstance;
        wndclass.hIcon         = LoadIcon(null, IDI_APPLICATION);
        wndclass.hCursor       = LoadCursor(null, IDC_ARROW);
        wndclass.hbrBackground = cast(HBRUSH)GetStockObject(WHITE_BRUSH);
        wndclass.lpszMenuName  = null;
        wndclass.lpszClassName = toUTF16z(WIN_CLASS_NAME);

        if(!RegisterClassW(&wndclass))
        {
            return false;
        }
        HDC dc = CreateCompatibleDC(NULL);
        SCREEN_DPI = GetDeviceCaps(dc, LOGPIXELSY);
        DeleteObject(dc);

        return true;
    }
    override int enterMessageLoop() {
        MSG  msg;
        while (GetMessage(&msg, null, 0, 0))
        {
            TranslateMessage(&msg);
            DispatchMessage(&msg);
            destroyClosedWindows();
        }
        return cast(int)msg.wParam;
    }

    private Win32Window[ulong] _windowMap;
    private Win32Window[] _windowList;

    /// add window to window map
    void onWindowCreated(HWND hwnd, Win32Window window) {
        Log.v("created window, adding to map");
        _windowMap[cast(ulong)hwnd] = window;
        _windowList ~= window;
    }
    /// remove window from window map, returns true if there are some more windows left in map
    bool onWindowDestroyed(HWND hwnd, Win32Window window) {
        Log.v("destroyed window, removing from map");
        Win32Window wnd = getWindow(hwnd);
        if (wnd) {
            _windowMap.remove(cast(ulong)hwnd);
            _windowsToDestroy ~= window;
            //destroy(window);
        }
        for (uint i = 0; i < _windowList.length; i++) {
            if (window is _windowList[i]) {
                for (uint j = i; j + 1 < _windowList.length; j++)
                    _windowList[j] = _windowList[j + 1];
                _windowList[$ - 1] = null;
                _windowList.length--;
                break;
            }
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
    override Window createWindow(dstring windowCaption, Window parent, uint flags = WindowFlag.Resizable, uint width = 0, uint height = 0) {
        Log.d("Platform.createWindow is called");
        width = pointsToPixels(width);
        height = pointsToPixels(height);
        Log.v("Platform.createWindow : setDefaultLanguageAndThemeIfNecessary");
        setDefaultLanguageAndThemeIfNecessary();
        Log.v("Platform.createWindow : new Win32Window");
        return new Win32Window(this, windowCaption, parent, flags, width, height);
    }

    /// calls request layout for all windows
    override void requestLayout() {
        foreach(w; _windowMap) {
            w.requestLayout();
            w.invalidate();
        }
    }

    /// returns true if there is some modal window opened above this window, and this window should not process mouse/key input and should not allow closing
    override bool hasModalWindowsAbove(Window w) {
        // override in platform specific class
        for (uint i = 0; i + 1 < _windowList.length; i++) {
            if (_windowList[i] is w) {
                for (uint j = i + 1; j < _windowList.length; j++) {
                    if (_windowList[j].flags & WindowFlag.Modal && _windowList[j].windowState != WindowState.hidden)
                        return true;
                }
                return false;
            }
        }
        return false;
    }

    /// handle theme change: e.g. reload some themed resources
    override void onThemeChanged() {
        super.onThemeChanged();
        if (currentTheme)
            currentTheme.onThemeChanged();
        foreach(w; _windowMap)
            w.dispatchThemeChanged();
    }

    /// list of windows for deferred destroy in message loop
    Win32Window[] _windowsToDestroy;

    /// close window
    override void closeWindow(Window w) {
        Win32Window window = cast(Win32Window)w;
        _windowsToDestroy ~= window;
        SendMessage(window._hwnd, WM_CLOSE, 0, 0);
        //window
    }

    /// destroy window objects planned for destroy
    void destroyClosedWindows() {
        foreach(Window w; _windowsToDestroy) {
            destroy(w);
        }
        _windowsToDestroy.length = 0;
    }

    /// check has clipboard text
    override bool hasClipboardText(bool mouseBuffer = false) {
        if (mouseBuffer)
            return false;
        return (IsClipboardFormatAvailable(CF_UNICODETEXT) != 0);
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
            LPWSTR lptstr = cast(LPWSTR)GlobalLock(hglb); 
            if (lptstr != NULL) 
            { 
                wstring w = fromWStringz(lptstr);
                res = normalizeEndOfLineCharacters(toUTF32(w));

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
                           cast(uint)((w.length + 1) * TCHAR.sizeof)); 
        if (hglbCopy == NULL) { 
            CloseClipboard(); 
            return; 
        }
        LPWSTR lptstrCopy = cast(LPWSTR)GlobalLock(hglbCopy);
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
int DLANGUIWinMain(void* hInstance, void* hPrevInstance,
            char* lpCmdLine, int nCmdShow) {
    int result;

    try {
        Runtime.initialize();

        // call SetProcessDPIAware to support HI DPI - fix by Kapps
        auto ulib = LoadLibraryA("user32.dll");
        alias SetProcessDPIAwareFunc = int function();
        auto setDpiFunc = cast(SetProcessDPIAwareFunc)GetProcAddress(ulib, "SetProcessDPIAware");
        if(setDpiFunc) // Should never fail, but just in case...
            setDpiFunc();

        result = myWinMain(hInstance, hPrevInstance, lpCmdLine, nCmdShow);
        // TODO: fix hanging on multithreading app
        Runtime.terminate();
    }
    catch (Throwable e) // catch any uncaught exceptions
    {
        MessageBoxW(null, toUTF16z(e.toString()), "Error",
                    MB_OK | MB_ICONEXCLAMATION);
        result = 0;     // failed
    }

    return result;
}

extern(Windows)
int DLANGUIWinMainProfile(string[] args) 
{
    int result;

    try {
        // call SetProcessDPIAware to support HI DPI - fix by Kapps
        auto ulib = LoadLibraryA("user32.dll");
        alias SetProcessDPIAwareFunc = int function();
        auto setDpiFunc = cast(SetProcessDPIAwareFunc)GetProcAddress(ulib, "SetProcessDPIAware");
        if(setDpiFunc) // Should never fail, but just in case...
            setDpiFunc();

        result = myWinMainProfile(args);
    }
    catch (Throwable e) // catch any uncaught exceptions
    {
        MessageBoxW(null, toUTF16z(e.toString()), "Error",
                    MB_OK | MB_ICONEXCLAMATION);
        result = 0;     // failed
    }

    return result;
}

/// split command line arg list; prepend with executable file name
string[] splitCmdLine(string line) {
    string[] res;
    res ~= exeFilename();
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

private __gshared Win32Platform w32platform;

static if (ENABLE_OPENGL) {
    import derelict.opengl3.gl3;
    import derelict.opengl3.gl;

    void initOpenGL() {
        try {
            Log.d("Loading Derelict GL");
            DerelictGL.load();
            DerelictGL3.load();
            Log.d("Derelict GL - loaded");
            //
            //// just to check OpenGL context
            //Log.i("Trying to setup OpenGL context");
            //Win32Window tmpWindow = new Win32Window(w32platform, ""d, null, 0);
            //destroy(tmpWindow);
            //if (openglEnabled)
            //    Log.i("OpenGL support is enabled");
            //else
            //    Log.w("OpenGL support is disabled");
            //// process messages
            //platform.enterMessageLoop();
        } catch (Exception e) {
            Log.e("Exception while trying to init OpenGL", e);
            setOpenglEnabled(false);
        }
    }
}


int myWinMain(void* hInstance, void* hPrevInstance, char* lpCmdLine, int iCmdShow)
{
    initLogs();

    Log.d("myWinMain()");
    string basePath = exePath();
    Log.i("Current executable: ", exePath());
    string cmdline = fromStringz(lpCmdLine).dup;
    Log.i("Command line: ", cmdline);
    string[] args = splitCmdLine(cmdline);
    Log.i("Command line params: ", args);

    _cmdShow = iCmdShow;
    _hInstance = hInstance;

    Log.v("Creating platform");
    w32platform = new Win32Platform();
    Log.v("Registering window class");
    if (!w32platform.registerWndClass()) {
        MessageBoxA(null, "This program requires Windows NT!", "DLANGUI App".toStringz, MB_ICONERROR);
        return 0;
    }
    Platform.setInstance(w32platform);

    DOUBLE_CLICK_THRESHOLD_MS = GetDoubleClickTime();

    Log.v("Initializing font manager");
    if (!initFontManager()) {
        Log.e("******************************************************************");
        Log.e("No font files found!!!");
        Log.e("Currently, only hardcoded font paths implemented.");
        Log.e("Probably you can modify sdlapp.d to add some fonts for your system.");
        Log.e("******************************************************************");
        assert(false);
    }
    initResourceManagers();

    currentTheme = createDefaultTheme();

    static if (ENABLE_OPENGL) {
        initOpenGL();
    }

    // Load versions 1.2+ and all supported ARB and EXT extensions.

    Log.i("Entering UIAppMain: ", args);
    int result = -1;
    try {
        result = UIAppMain(args);
        Log.i("UIAppMain returned ", result);
    } catch (Exception e) {
        Log.e("Abnormal UIAppMain termination");
        Log.e("UIAppMain exception: ", e);
    }

    releaseResourcesOnAppExit();

    Log.d("Exiting main");
    debug {
        APP_IS_SHUTTING_DOWN = true;
        import core.memory : GC;
        Log.d("Calling GC.collect");
        GC.collect();
        if (DrawBuf.instanceCount)
            Log.d("Non-zero DrawBuf instance count when exiting: ", DrawBuf.instanceCount);
    }

    return result;
}

int myWinMainProfile(string[] args)
{
    initLogs();

    Log.d("myWinMain()");
    string basePath = exePath();
    Log.i("Current executable: ", exePath());
    Log.i("Command line params: ", args);

    _cmdShow = SW_SHOW;
    _hInstance = GetModuleHandle(NULL);

    Log.v("Creating platform");
    w32platform = new Win32Platform();
    Log.v("Registering window class");
    if (!w32platform.registerWndClass()) {
        MessageBoxA(null, "This program requires Windows NT!", "DLANGUI App".toStringz, MB_ICONERROR);
        return 0;
    }
    Platform.setInstance(w32platform);

    DOUBLE_CLICK_THRESHOLD_MS = GetDoubleClickTime();

    Log.v("Initializing font manager");
    if (!initFontManager()) {
        Log.e("******************************************************************");
        Log.e("No font files found!!!");
        Log.e("Currently, only hardcoded font paths implemented.");
        Log.e("Probably you can modify sdlapp.d to add some fonts for your system.");
        Log.e("******************************************************************");
        assert(false);
    }
    initResourceManagers();

    currentTheme = createDefaultTheme();

    static if (ENABLE_OPENGL) {
        initOpenGL();
    }

    // Load versions 1.2+ and all supported ARB and EXT extensions.

    Log.i("Entering UIAppMain: ", args);
    int result = -1;
    try {
        result = UIAppMain(args);
        Log.i("UIAppMain returned ", result);
    } catch (Exception e) {
        Log.e("Abnormal UIAppMain termination");
        Log.e("UIAppMain exception: ", e);
    }

    releaseResourcesOnAppExit();

    Log.d("Exiting main");
    debug {
        APP_IS_SHUTTING_DOWN = true;
        import core.memory : GC;
        Log.d("Calling GC.collect");
        GC.collect();
        if (DrawBuf.instanceCount)
            Log.d("Non-zero DrawBuf instance count when exiting: ", DrawBuf.instanceCount);
    }

    return result;
}


extern(Windows)
LRESULT WndProc(HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam)
{
    HDC hdc;
    RECT rect;

    void * p = cast(void*)GetWindowLongPtr(hwnd, GWLP_USERDATA);
    Win32Window windowParam = p is null ? null : cast(Win32Window)(p);
    Win32Window window = w32platform.getWindow(hwnd);
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
                //window.handleUnknownWindowMessage(message, wParam, lParam);
            }
            return 0;
        case WM_DESTROY:
            if (window !is null) {
                //window.handleUnknownWindowMessage(message, wParam, lParam);
                window.onDestroy();
            }
            if (w32platform.windowCount == 0)
                PostQuitMessage(0);
            return 0;
        case WM_WINDOWPOSCHANGED:
            {
                if (window !is null) {
                    
                    if (IsIconic(hwnd)) {
                        window.handleWindowStateChange(WindowState.minimized);
                    }
                    else {
                        WINDOWPOS * pos = cast(WINDOWPOS*)lParam;
                        //Log.d("WM_WINDOWPOSCHANGED: ", *pos);

                        GetClientRect(hwnd, &rect);
                        int dx = rect.right - rect.left;
                        int dy = rect.bottom - rect.top;
                        WindowState state = WindowState.unspecified;
                        if (IsZoomed(hwnd))
                            state = WindowState.maximized;
                        else if (IsIconic(hwnd))
                            state = WindowState.minimized;
                        else if (IsWindowVisible(hwnd))
                            state = WindowState.normal;
                        else
                            state = WindowState.hidden;
                        window.handleWindowStateChange(state,
                            Rect(pos.x, pos.y, dx, dy));
                        if (window.width != dx || window.height != dy) {
                            window.onResize(dx, dy);
                            InvalidateRect(hwnd, null, FALSE);
                        }
                    }
                }
            }
            return 0;
        case WM_ACTIVATE:
            {
                if (window) {
                    if (wParam == WA_INACTIVE) 
                        window.handleWindowActivityChange(false);
                    else if (wParam == WA_ACTIVE || wParam == WA_CLICKACTIVE)
                        window.handleWindowActivityChange(true);
                }
            }
            return 0;
        case CUSTOM_MESSAGE_ID:
            if (window !is null) {
                window.handlePostedEvent(cast(uint)lParam);
            }
            return 1;
        case WM_ERASEBKGND:
            // processed
            return 1;
        case WM_PAINT:
            {
                if (window !is null)
                    window.onPaint();
            }
            return 0; // processed
        case WM_SETCURSOR:
            {
                if (window !is null) {
                    if (LOWORD(lParam) == HTCLIENT) {
                        window.onSetCursorType();
                        return 1;
                    }
                }
            }
            break;
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
        case WM_SYSKEYDOWN:
        case WM_KEYUP:
        case WM_SYSKEYUP:
            if (window !is null) {
                int repeatCount = lParam & 0xFFFF;
                WPARAM vk = wParam;
                WPARAM new_vk = vk;
                UINT scancode = (lParam & 0x00ff0000) >> 16;
                int extended  = (lParam & 0x01000000) != 0;
                switch (vk) {
                    case VK_SHIFT:
                        new_vk = MapVirtualKey(scancode, 3); //MAPVK_VSC_TO_VK_EX
                        break;
                    case VK_CONTROL:
                        new_vk = extended ? VK_RCONTROL : VK_LCONTROL;
                        break;
                    case VK_MENU:
                        new_vk = extended ? VK_RMENU : VK_LMENU;
                        break;
                    default:
                        // not a key we map from generic to left/right specialized
                        //  just return it.
                        new_vk = vk;
                        break;    
                }

                if (window.onKey(message == WM_KEYDOWN || message == WM_SYSKEYDOWN ? KeyAction.KeyDown : KeyAction.KeyUp, cast(uint)new_vk, repeatCount, 0, message == WM_SYSKEYUP || message == WM_SYSKEYDOWN))
                    return 0; // processed
            }
            break;
        case WM_UNICHAR:
            if (window !is null) {
                int repeatCount = lParam & 0xFFFF;
                dchar ch = wParam == UNICODE_NOCHAR ? 0 : cast(uint)wParam;
                debug(KeyInput) Log.d("WM_UNICHAR ", ch, " (", cast(int)ch, ")");
                if (window.onKey(KeyAction.Text, cast(uint)wParam, repeatCount, ch))
                    return 1; // processed
                return 1;
            }
            break;
        case WM_CHAR:
            if (window !is null) {
                int repeatCount = lParam & 0xFFFF;
                dchar ch = wParam == UNICODE_NOCHAR ? 0 : cast(uint)wParam;
                debug(KeyInput) Log.d("WM_CHAR ", ch, " (", cast(int)ch, ")");
                if (window.onKey(KeyAction.Text, cast(uint)wParam, repeatCount, ch))
                    return 1; // processed
                return 1;
            }
            break;
        case WM_TIMER:
            if (window !is null) {
                window.handleTimer(wParam);
                return 0;
            }
            break;
        case WM_DROPFILES:
            if (window !is null) {
                HDROP hdrop = cast(HDROP)wParam;
                string[] files;
                wchar[] buf;
                auto count = DragQueryFileW(hdrop, 0xFFFFFFFF, cast(wchar*)NULL, 0);
                for (int i = 0; i < count; i++) {
                    auto sz = DragQueryFileW(hdrop, i, cast(wchar*)NULL, 0); 
                    buf.length = sz + 2;
                    sz = DragQueryFileW(hdrop, i, buf.ptr, sz + 1); 
                    files ~= toUTF8(buf[0..sz]);
                }
                if (files.length)
                    window.handleDroppedFiles(files);
                DragFinish(hdrop);
            }
            return 0;
        case WM_CLOSE:
            if (window !is null) {
                bool canClose = window.handleCanClose();
                if (!canClose) {
                    Log.d("WM_CLOSE: canClose is false");
                    return 0; // prevent closing
                }
                Log.d("WM_CLOSE: closing window ");
                //destroy(window);
            }
            // default handler inside DefWindowProc will close window
            break;
        case WM_GETMINMAXINFO:
        case WM_NCCREATE:
        case WM_NCCALCSIZE:
        default:
            //Log.d("Unhandled message ", message);
            break;
    }
    if (window)
        return window.handleUnknownWindowMessage(message, wParam, lParam);
    return DefWindowProc(hwnd, message, wParam, lParam);
}

//===========================================
// end of version(Windows)
//===========================================

