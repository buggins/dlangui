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
import dlangui.core.logger;

pragma(lib, "gdi32.lib");
pragma(lib, "user32.lib");
pragma(lib, "libpng15.lib");

extern (C) int UIAppMain(string[] args);

immutable WIN_CLASS_NAME = "DLANGUI_APP";

__gshared HINSTANCE _hInstance;
__gshared int _cmdShow;

class Win32Window : Window {
    private HWND _hwnd;
    string _caption;
    Win32ColorDrawBuf _drawbuf;
    this(string windowCaption, Window parent) {
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
        writeln("Window onCreate");
    }
    void onDestroy() {
        writeln("Window onDestroy");
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

    Log.i("Entering UIAppMain: ", args);
    int result = UIAppMain(args);
    Log.i("UIAppMain returned ", result);
    return result;
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
        case WM_WINDOWPOSCHANGED:
            {
                WINDOWPOS * pos = cast(WINDOWPOS*)lParam;
                GetClientRect(hwnd, &rect);
                int dx = rect.right - rect.left;
                int dy = rect.bottom - rect.top;
                //window.onResize(pos.cx, pos.cy);
                window.onResize(dx, dy);
                UpdateWindow(hwnd);
            }
            return 0;
        case WM_ERASEBKGND:
            return 1;
        case WM_PAINT:
            {
                GetClientRect(hwnd, &rect);
                int dx = rect.right - rect.left;
                int dy = rect.bottom - rect.top;
                window.onResize(dx, dy);
                hdc = BeginPaint(hwnd, &ps);
                Win32ColorDrawBuf buf = window.getDrawBuf();
                buf.fill(0x808080);
                window.onDraw(buf);
                buf.drawTo(hdc, 0, 0);
                //drawBuf2DC(hdc, 0, 0, buf);
                scope(exit) EndPaint(hwnd, &ps);
            }
            //DrawTextA(hdc, "Hello, Windows!", -1, &rect, DT_SINGLELINE | DT_CENTER | DT_VCENTER);
            return 0;

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


