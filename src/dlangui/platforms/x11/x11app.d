module dlangui.platforms.x11.x11app;

public import dlangui.core.config;
static if (BACKEND_X11):

import dlangui.core.logger;
import dlangui.core.events;
import dlangui.core.files;
import dlangui.core.types : toUTF8;
import dlangui.graphics.drawbuf;
import dlangui.graphics.fonts;
import dlangui.graphics.ftfonts;
import dlangui.graphics.resources;
import dlangui.widgets.styles;
import dlangui.widgets.widget;
import dlangui.platforms.common.platform;

import core.stdc.string;
import std.stdio;
import std.string;
import std.utf;
private import core.stdc.config : c_ulong, c_long;

import x11.Xlib;
import x11.Xutil;
import x11.Xtos;
import x11.Xatom;
import x11.X;

static if (ENABLE_OPENGL) {
    import derelict.opengl3.gl3;
    import derelict.opengl3.gl;
    import dlangui.graphics.gldrawbuf;
    import dlangui.graphics.glsupport;
    import derelict.opengl3.glx;

    private __gshared derelict.util.xtypes.XVisualInfo * x11visual;
    private __gshared Colormap x11cmap;
    private __gshared bool _gl3Reloaded = false;
}

//pragma(lib, "X11");

alias XWindow = x11.Xlib.Window;
alias DWindow = dlangui.platforms.common.platform.Window;

private struct MwmHints
{
    int flags;
    int functions;
    int decorations;
    int input_mode;
    int status;
}

private enum
{
    MWM_HINTS_FUNCTIONS = (1L << 0),
    MWM_HINTS_DECORATIONS =  (1L << 1),

    MWM_FUNC_ALL = (1L << 0),
    MWM_FUNC_RESIZE = (1L << 1),
    MWM_FUNC_MOVE = (1L << 2),
    MWM_FUNC_MINIMIZE = (1L << 3),
    MWM_FUNC_MAXIMIZE = (1L << 4),
    MWM_FUNC_CLOSE = (1L << 5)
}

private __gshared
{
    Display * x11display;
    Display * x11display2;
    int x11screen;
    XIM xim;

    bool _enableOpengl = false;

    Cursor[CursorType.Hand + 1] x11cursors;

    Atom   atom_UTF8_STRING;
    Atom   atom_CLIPBOARD;
    Atom   atom_TARGETS;

    Atom   atom_WM_PROTOCOLS;
    Atom   atom_WM_DELETE_WINDOW;

    Atom   atom_NET_WM_ICON;
    Atom   atom_NET_WM_NAME;
    Atom   atom_NET_WM_ICON_NAME;

    Atom   atom_NET_WM_STATE;
    Atom   atom_NET_WM_STATE_MODAL;
    Atom   atom_NET_WM_STATE_MAXIMIZED_VERT;
    Atom   atom_NET_WM_STATE_MAXIMIZED_HORZ;
    Atom   atom_NET_WM_STATE_HIDDEN;
    Atom   atom_NET_WM_STATE_FULLSCREEN;

    Atom   atom_MOTIF_WM_HINTS;

    Atom   atom_DLANGUI_TIMER_EVENT;
    Atom   atom_DLANGUI_TASK_EVENT;
    Atom   atom_DLANGUI_CLOSE_WINDOW_EVENT;
    Atom   atom_DLANGUI_CLIPBOARD_BUFFER;
    Atom   atom_DLANGUI_REDRAW_EVENT;
}

static void setupX11Atoms()
{
    assert(x11display !is null, "X Connection must be established before getting atoms");
    //TODO: not sure which atoms should be taken with or without onlyIfExists flag
    atom_UTF8_STRING = XInternAtom(x11display, "UTF8_STRING", True);
    atom_CLIPBOARD   = XInternAtom(x11display, "CLIPBOARD", True);
    atom_TARGETS     = XInternAtom(x11display, "TARGETS", True);
    atom_WM_PROTOCOLS = XInternAtom(x11display, "WM_PROTOCOLS", False);
    atom_WM_DELETE_WINDOW = XInternAtom(x11display, "WM_DELETE_WINDOW", False);
    atom_NET_WM_ICON = XInternAtom(x11display, "_NET_WM_ICON", True);
    atom_NET_WM_NAME = XInternAtom(x11display, "_NET_WM_NAME", True);
    atom_NET_WM_ICON_NAME = XInternAtom(x11display, "_NET_WM_ICON_NAME", True);
    atom_NET_WM_STATE = XInternAtom(x11display, "_NET_WM_STATE", True);
    atom_NET_WM_STATE_MODAL = XInternAtom(x11display, "_NET_WM_STATE_MODAL", True);
    atom_NET_WM_STATE_MAXIMIZED_VERT = XInternAtom(x11display, "_NET_WM_STATE_MAXIMIZED_VERT", True);
    atom_NET_WM_STATE_MAXIMIZED_HORZ = XInternAtom(x11display, "_NET_WM_STATE_MAXIMIZED_HORZ", True);
    atom_NET_WM_STATE_HIDDEN = XInternAtom(x11display, "_NET_WM_STATE_HIDDEN", True);
    atom_NET_WM_STATE_FULLSCREEN = XInternAtom(x11display, "_NET_WM_STATE_FULLSCREEN", True);
    atom_MOTIF_WM_HINTS = XInternAtom(x11display, "_MOTIF_WM_HINTS", True);

    atom_DLANGUI_TIMER_EVENT     = XInternAtom(x11display, "DLANGUI_TIMER_EVENT", False);
    atom_DLANGUI_TASK_EVENT     = XInternAtom(x11display, "DLANGUI_TASK_EVENT", False);
    atom_DLANGUI_CLOSE_WINDOW_EVENT = XInternAtom(x11display, "DLANGUI_CLOSE_WINDOW_EVENT", False);
    atom_DLANGUI_CLIPBOARD_BUFFER = XInternAtom(x11display, "DLANGUI_CLIPBOARD_BUFFER", False);
    atom_DLANGUI_REDRAW_EVENT = XInternAtom(x11display, "DLANGUI_REDRAW_EVENT", False);
}

// Cursor font constants
enum {
    XC_X_cursor=0,
    XC_arrow=2,
    XC_based_arrow_down=4,
    XC_based_arrow_up=6,
    XC_boat = 8,
    XC_bogosity = 10,
    XC_bottom_left_corner=12,
    XC_bottom_right_corner=14,
    XC_bottom_side=16,
    XC_bottom_tee=18,
    XC_box_spiral=20,
    XC_center_ptr=22,
    XC_circle=24,
    XC_clock=26,
    XC_coffee_mug=28,
    XC_cross=30,
    XC_cross_reverse=32,
    XC_crosshair=34,
    XC_diamond_cross=36,
    XC_dot=38,
    XC_dotbox=40,
    XC_double_arrow=42,
    XC_draft_large=44,
    XC_draft_small=46,
    XC_draped_box=48,
    XC_exchange=50,
    XC_fleur=52,
    XC_gobbler=54,
    XC_gumby=56,
    XC_hand1=58,
    XC_hand2=60,
    XC_heart=62,
    XC_icon=64,
    XC_iron_cross=66,
    XC_left_ptr=68,
    XC_left_side=70,
    XC_left_tee=72,
    XC_leftbutton=74,
    XC_ll_angle=76,
    XC_lr_angle=78,
    XC_man=80,
    XC_middlebutton=82,
    XC_mouse=84,
    XC_pencil=86,
    XC_pirate=88,
    XC_plus=90,
    XC_question_arrow=92,
    XC_right_ptr=94,
    XC_right_side=96,
    XC_right_tee=98,
    XC_rightbutton=100,
    XC_rtl_logo=102,
    XC_sailboat=104,
    XC_sb_down_arrow=106,
    XC_sb_h_double_arrow=108,
    XC_sb_left_arrow=110,
    XC_sb_right_arrow=112,
    XC_sb_up_arrow=114,
    XC_sb_v_double_arrow=116,
    XC_shuttle=118,
    XC_sizing=120,
    XC_spider=122,
    XC_spraycan=124,
    XC_star=126,
    XC_target=128,
    XC_tcross=130,
    XC_top_left_arrow=132,
    XC_top_left_corner=134,
    XC_top_right_corner=136,
    XC_top_side=138,
    XC_top_tee=140,
    XC_trek=142,
    XC_ul_angle=144,
    XC_umbrella=146,
    XC_ur_angle=148,
    XC_watch=150,
    XC_xterm=152,
}

private GC createGC(Display* display, XWindow win)
{
    GC gc;                /* handle of newly created GC.  */
    uint valuemask = GCFunction | GCBackground | GCForeground | GCPlaneMask;        /* which values in 'values' to  */
    /* check when creating the GC.  */
    XGCValues values;            /* initial values for the GC.   */
    values.plane_mask = AllPlanes;
    int screen_num = DefaultScreen(display);
    values.function_ = GXcopy;
    values.background = WhitePixel(display, screen_num);
    values.foreground = BlackPixel(display, screen_num);

    gc = XCreateGC(display, win, valuemask, &values);
    if (!gc) {
        Log.e("X11: Cannot create GC");
        return null;
        //fprintf(stderr, "XCreateGC: \n");
    }

    uint line_width = 2;        /* line width for the GC.       */
    int line_style = LineSolid;        /* style for lines drawing and  */
    int cap_style = CapButt;        /* style of the line's edje and */
    int join_style = JoinBevel;        /*  joined lines.        */

    /* define the style of lines that will be drawn using this GC. */
    XSetLineAttributes(display, gc,
        line_width, line_style, cap_style, join_style);

    /* define the fill style for the GC. to be 'solid filling'. */
    XSetFillStyle(display, gc, FillSolid);

    return gc;
}

class X11Window : DWindow {
    protected X11Platform _platform;
    protected dstring _caption;
    protected XWindow _win;
    protected GC _gc;
    private __gshared XIC xic;

    X11Window[] _children;
    X11Window _parent;

    int _cachedWidth, _cachedHeight;

    static if (ENABLE_OPENGL) {
        GLXContext _glc;
    }

    this(X11Platform platform, dstring caption, DWindow parent, uint flags, uint width = 0, uint height = 0) {
        _platform = platform;
        //backgroundColor = 0xFFFFFF;
        debug Log.d("X11Window: Creating window");
        if (width == 0)
            width = 500;
        if (height == 0)
            height = 300;
        _cachedWidth = _dx = width;
        _cachedHeight = _dy = height;
        _flags = flags;

        /* get the colors black and white (see section for details) */
        c_ulong black, white;
        black = BlackPixel(x11display, x11screen);    /* get color black */
        white = WhitePixel(x11display, x11screen);  /* get color white */

        /* once the display is initialized, create the window.
               This window will be have be 200 pixels across and 300 down.
               It will have the foreground white and background black
        */

        Log.d("Creating window of size ", _dx, "x", _dy);
        static if (true) {
            XSetWindowAttributes swa;
            uint swamask = CWEventMask | CWBackPixel;
            swa.background_pixel = white;
            swa.event_mask = KeyPressMask | KeyReleaseMask | ButtonPressMask | ButtonReleaseMask |
                EnterWindowMask | LeaveWindowMask | PointerMotionMask | ButtonMotionMask | ExposureMask | VisibilityChangeMask |
                    FocusChangeMask | KeymapStateMask | StructureNotifyMask | PropertyChangeMask;
            Visual * visual = DefaultVisual(x11display, x11screen);
            int depth = DefaultDepth(x11display, x11screen);
            static if (ENABLE_OPENGL) {
                if (_enableOpengl) {
                    swamask |= CWColormap;
                    swa.colormap = x11cmap;
                    visual = cast(Visual*)x11visual.visual;
                    depth = x11visual.depth;
                }
            }

            _win = XCreateWindow(x11display, DefaultRootWindow(x11display),
                0, 0,
                _dx, _dy, 0,
                depth,
                InputOutput,
                visual,
                swamask,
                &swa);
//            _win = XCreateSimpleWindow(x11display, DefaultRootWindow(x11display),
//                0, 0,
//                _dx, _dy, 5, black, white);
        } else {
            XSetWindowAttributes attr;
            attr.do_not_propagate_mask = 0;
            attr.override_redirect = True;
            attr.cursor = Cursor();
            attr.event_mask = ExposureMask | KeyPressMask | KeyReleaseMask | ButtonPressMask | ButtonReleaseMask;
            attr.background_pixel = white;

            _win = XCreateWindow(x11display, DefaultRootWindow(x11display),
                0, 0,
                _dx, _dy, 5,
                CopyFromParent, // depth
                CopyFromParent, // class
                cast(Visual*)CopyFromParent, // visual
                CWEventMask|CWBackPixel|CWCursor|CWDontPropagate,
                &attr
                );
            if (!_win)
                return;

        }
        windowCaption = caption;
        XSetWMProtocols(x11display, _win, &atom_WM_DELETE_WINDOW, 1);
        _windowState = WindowState.hidden;

        auto classHint = XAllocClassHint();
        if (classHint) {
            classHint.res_name = platform._classname;
            classHint.res_class = platform._classname;
            XSetClassHint(x11display, _win, classHint);
            XFree(classHint);
        }

        _children.reserve(20);
        _parent = cast(X11Window) parent;
        if (_parent)
            _parent._children ~= this;

        if (!(flags & WindowFlag.Resizable)) {
            XSizeHints sizeHints;
            sizeHints.min_width = width;
            sizeHints.min_height = height;
            sizeHints.max_width = width;
            sizeHints.max_height = height;
            sizeHints.flags = PMaxSize | PMinSize;
            XSetWMNormalHints(x11display, _win, &sizeHints);
        }
        if (flags & WindowFlag.Fullscreen) {
            if (atom_NET_WM_STATE_FULLSCREEN != None) {
                changeWindowState(_NET_WM_STATE_ADD, atom_NET_WM_STATE_FULLSCREEN);
            }
            else
                Log.w("Missing _NET_WM_STATE_FULLSCREEN atom");
        }
        if (flags & WindowFlag.Borderless) {
            if (atom_MOTIF_WM_HINTS != None) {
                MwmHints hints;
                hints.flags = MWM_HINTS_DECORATIONS;
                XChangeProperty(x11display, _win, atom_MOTIF_WM_HINTS, atom_MOTIF_WM_HINTS, 32, PropModeReplace, cast(ubyte*)&hints, hints.sizeof / 4);
            }
        }
        if (flags & WindowFlag.Modal) {
            if (_parent) {
                XSetTransientForHint(x11display, _win, _parent._win);
            } else {
                Log.w("Top-level modal window");
            }
            if (atom_NET_WM_STATE_MODAL != None) {
                changeWindowState(_NET_WM_STATE_ADD, atom_NET_WM_STATE_MODAL);
            } else {
                Log.w("Missing _NET_WM_STATE_MODAL atom");
            }
        }
        /* this routine determines which types of input are allowed in
               the input.  see the appropriate section for details...
        */
//        XSelectInput(x11display, _win, KeyPressMask | KeyReleaseMask | ButtonPressMask | ButtonReleaseMask |
//            EnterWindowMask | LeaveWindowMask | PointerMotionMask | ButtonMotionMask | ExposureMask | VisibilityChangeMask |
//            FocusChangeMask | KeymapStateMask | StructureNotifyMask);

        /* create the Graphics Context */
        _gc = createGC(x11display, _win);
        //_gc = XCreateGC(x11display, _win, 0, cast(XGCValues*)null);
        //Log.d("X11Window: windowId=", _win, " gc=", _gc);




        /* here is another routine to set the foreground and background
               colors _currently_ in use in the window.
        */
        //XSetBackground(x11display, _gc, white);
        //XSetForeground(x11display, _gc, black);

        /* clear the window and bring it on top of the other windows */
        //XClearWindow(x11display, _win);
        //XFlush(x11display);

        handleWindowStateChange(WindowState.unspecified, Rect(0, 0, _dx, _dy));

        if (platform.defaultWindowIcon.length != 0)
            windowIcon = drawableCache.getImage(platform.defaultWindowIcon);
    }

    ~this() {
        debug Log.d("Destroying X11 window");
        if (timer) {
            timer.stop();
        }
        if (_parent) {
            import std.algorithm : countUntil, remove;
            ptrdiff_t index = countUntil(_parent._children,this);
            if (index > -1 ) {
                _parent._children = _parent._children.remove(index);
            }
            _parent = null;
        }
        static if (ENABLE_OPENGL) {
            if (_glc) {
                glXDestroyContext(x11display, _glc);
                _glc = null;
            }
        }
        if (_drawbuf)
            destroy(_drawbuf);
        if (_gc) {
            XFreeGC(x11display, _gc);
            _gc = null;
        }
        if (_win) {
            XDestroyWindow(x11display, _win);
            _win = 0;
        }
    }

    private bool hasVisibleModalChild() {
        foreach (X11Window w;_children) {
            if (w.flags & WindowFlag.Modal && w._windowState != WindowState.hidden)
                return true;
        }
        return false;
    }

    /// show window
    override void show() {
        Log.d("X11Window.show");
        XMapRaised(x11display, _win);

        static if (ENABLE_OPENGL) {
            if (_enableOpengl) {
                _glc = glXCreateContext(x11display, x11visual, null, GL_TRUE);
                if (!_glc) {
                    _enableOpengl = false;
                } else {
                    glXMakeCurrent(x11display, cast(uint)_win, _glc);
                    _enableOpengl = initGLSupport(_platform.GLVersionMajor < 3);
                    if (!_enableOpengl && _glc) {
                        glXDestroyContext(x11display, _glc);
                        _glc = null;
                    }
                }
            }
            if (_enableOpengl) {
                Log.d("Open GL support is enabled");
            } else {
                Log.d("Open GL support is disabled");
            }
        }
        if (_mainWidget) {
            _mainWidget.measure(SIZE_UNSPECIFIED, SIZE_UNSPECIFIED);
            if (flags & WindowFlag.MeasureSize)
                resizeWindow(Point(_mainWidget.measuredWidth, _mainWidget.measuredHeight));
            else
                adjustWindowOrContentSize(_mainWidget.measuredWidth, _mainWidget.measuredHeight);

            adjustPositionDuringShow();

            _mainWidget.setFocus();
        }
        XFlush(x11display);
    }

    override protected void handleWindowStateChange(WindowState newState, Rect newWindowRect = RECT_VALUE_IS_NOT_SET) {
        super.handleWindowStateChange(newState, newWindowRect);
    }

    protected final void changeWindowState(int action, Atom firstProperty, Atom secondProperty = None) nothrow
    {
        XEvent ev;
        memset(&ev, 0, ev.sizeof);
        ev.xany.type = ClientMessage;
        ev.xclient.window = _win;
        ev.xclient.message_type = atom_NET_WM_STATE;
        ev.xclient.format = 32;
        ev.xclient.data.l[0] = action;
        ev.xclient.data.l[1] = firstProperty;
        if (secondProperty != None)
            ev.xclient.data.l[2] = secondProperty;
        ev.xclient.data.l[3] = 0;
        XSendEvent(x11display, RootWindow(x11display, x11screen), false, SubstructureNotifyMask|SubstructureRedirectMask, &ev);
    }

    protected enum {
        _NET_WM_STATE_REMOVE = 0,
        _NET_WM_STATE_ADD,
        _NET_WM_STATE_TOGGLE
    }

    override bool setWindowState(WindowState newState, bool activate = false, Rect newWindowRect = RECT_VALUE_IS_NOT_SET) {
        if (_win == None) {
            return false;
        }
        bool result = false;
        switch(newState) {
            case WindowState.maximized:
                if (atom_NET_WM_STATE != None && atom_NET_WM_STATE_MAXIMIZED_HORZ != None && atom_NET_WM_STATE_MAXIMIZED_VERT != None) {
                    changeWindowState(_NET_WM_STATE_ADD, atom_NET_WM_STATE_MAXIMIZED_HORZ, atom_NET_WM_STATE_MAXIMIZED_VERT);
                    result = true;
                }
                break;
            case WindowState.minimized:
                if (XIconifyWindow(x11display, _win, x11screen))
                    result = true;
                break;
            case WindowState.hidden:
                XUnmapWindow(x11display, _win);
                result = true;
                break;
            case WindowState.normal:
                if (atom_NET_WM_STATE != None &&
                    atom_NET_WM_STATE_MAXIMIZED_HORZ != None &&
                    atom_NET_WM_STATE_MAXIMIZED_VERT != None &&
                    atom_NET_WM_STATE_HIDDEN != None)
                {
                    changeWindowState(_NET_WM_STATE_REMOVE, atom_NET_WM_STATE_MAXIMIZED_HORZ, atom_NET_WM_STATE_MAXIMIZED_VERT);
                    changeWindowState(_NET_WM_STATE_REMOVE, atom_NET_WM_STATE_HIDDEN);
                    changeWindowState(_NET_WM_STATE_REMOVE, atom_NET_WM_STATE_FULLSCREEN);
                    result = true;
                }
                break;
            case WindowState.fullscreen:
                if (atom_NET_WM_STATE != None && atom_NET_WM_STATE_FULLSCREEN != None) {
                    changeWindowState(_NET_WM_STATE_ADD, atom_NET_WM_STATE_FULLSCREEN);
                    result = true;
                }
                break;
            default:
                break;
        }

        // change size and/or position
        bool rectChanged = false;
        if (newWindowRect != RECT_VALUE_IS_NOT_SET && (newState == WindowState.normal || newState == WindowState.unspecified)) {
            // change position
            if (newWindowRect.top != int.min && newWindowRect.left != int.min) {
                XMoveWindow(x11display, _win, newWindowRect.left, newWindowRect.top);
                rectChanged = true;
                result = true;
            }

            // change size
            if (newWindowRect.bottom != int.min && newWindowRect.right != int.min) {
                if (!(flags & WindowFlag.Resizable)) {
                    XSizeHints sizeHints;
                    sizeHints.min_width = newWindowRect.right;
                    sizeHints.min_height = newWindowRect.bottom;
                    sizeHints.max_width = newWindowRect.right;
                    sizeHints.max_height = newWindowRect.bottom;
                    sizeHints.flags = PMaxSize | PMinSize;
                    XSetWMNormalHints(x11display, _win, &sizeHints);
                }
                XResizeWindow(x11display, _win, newWindowRect.right, newWindowRect.bottom);
                rectChanged = true;
                result = true;
            }
        }

        if (activate) {
            XMapRaised(x11display, _win);
            result = true;
        }
        XFlush(x11display);

        //needed here to make _windowRect and _windowState valid
        //example: change size by resizeWindow() and make some calculations using windowRect
        if (rectChanged) {
            handleWindowStateChange(newState, Rect(newWindowRect.left == int.min ? _windowRect.left : newWindowRect.left,
                newWindowRect.top == int.min ? _windowRect.top : newWindowRect.top, newWindowRect.right == int.min ? _windowRect.right : newWindowRect.right,
                newWindowRect.bottom == int.min ? _windowRect.bottom : newWindowRect.bottom));
        }
        else
            handleWindowStateChange(newState, RECT_VALUE_IS_NOT_SET);


        return result;
    }

    override @property DWindow parentWindow() {
        return _parent;
    }

    private bool _isActive;
    override protected void handleWindowActivityChange(bool isWindowActive) {
        _isActive = isWindowActive;
        super.handleWindowActivityChange(isWindowActive);
    }

    override @property bool isActive() {
        return _isActive;
    }

    override @property dstring windowCaption() const {
        return _caption;
    }

    override @property void windowCaption(dstring caption) {
        _caption = caption;
        auto captionc = _caption.toUTF8;
        auto captionz = cast(ubyte*)captionc.toStringz;
        XTextProperty nameProperty;
        nameProperty.value = captionz;
        nameProperty.encoding = atom_UTF8_STRING;
        nameProperty.format = 8;
        nameProperty.nitems = cast(uint)captionc.length;
        XStoreName(x11display, _win, cast(char*)captionz); // this may not support unicode
        XSetWMName(x11display, _win, &nameProperty);
        XChangeProperty(x11display, _win, atom_NET_WM_NAME, atom_UTF8_STRING, 8, PropModeReplace, captionz, cast(int)captionc.length);
        //XFlush(x11display); //TODO: not sure if XFlush is required
    }

    /// sets window icon
    override @property void windowIcon(DrawBufRef buf) {
        ColorDrawBuf icon = cast(ColorDrawBuf)buf.get;
        if (!icon) {
            Log.e("Trying to set null icon for window");
            return;
        }
        immutable int iconw = 32;
        immutable int iconh = 32;
        ColorDrawBuf iconDraw = new ColorDrawBuf(iconw, iconh);
        scope(exit) destroy(iconDraw);
        iconDraw.fill(0xFF000000);
        iconDraw.drawRescaled(Rect(0, 0, iconw, iconh), icon, Rect(0, 0, icon.width, icon.height));
        iconDraw.invertAndPreMultiplyAlpha();
        c_long[] propData = new c_long[2 + iconw * iconh];
        propData[0] = iconw;
        propData[1] = iconh;
        auto iconData = iconDraw.scanLine(0);
        foreach(i; 0..iconw*iconh) {
            propData[i+2] = iconData[i];
        }
        XChangeProperty(x11display, _win, atom_NET_WM_ICON, XA_CARDINAL, 32, PropModeReplace, cast(ubyte*)propData.ptr, cast(int)propData.length);
    }

    uint _lastRedrawEventCode;
    /// request window redraw
    override void invalidate() {
        XEvent ev;
        ev.xclient.type = ClientMessage;
        ev.xclient.message_type = atom_DLANGUI_REDRAW_EVENT;
        ev.xclient.window = _win;
        ev.xclient.display = x11display;
        ev.xclient.format = 32;
        ev.xclient.data.l[0] = ++_lastRedrawEventCode;
        XSendEvent(x11display, _win, false, StructureNotifyMask, &ev);
        XFlush(x11display);
    }

    /// close window
    override void close() {
        Log.d("X11Window.close()");
        _platform.closeWindow(this);
    }

    ColorDrawBuf _drawbuf;
    protected void drawUsingBitmap() {
        if (_dx > 0 && _dy > 0) {
            //Log.d("drawUsingBitmap()");
            // prepare drawbuf
            if (_drawbuf is null)
                _drawbuf = new ColorDrawBuf(_dx, _dy);
            else
                _drawbuf.resize(_dx, _dy);
            _drawbuf.resetClipping();
            // draw widgets into buffer
            _drawbuf.fill(backgroundColor);
            onDraw(_drawbuf);
            // draw buffer on X11 window
            XImage img;
            img.width = _drawbuf.width;
            img.height = _drawbuf.height;
            img.xoffset = 0;
            img.format = ZPixmap;
            img.data = cast(char*)_drawbuf.scanLine(0);
            img.bitmap_unit = 32;
            img.bitmap_pad = 32;
            img.bitmap_bit_order = LSBFirst;
            img.depth = 24;
            img.chars_per_line = _drawbuf.width * 4;
            img.bits_per_pixel = 32;
            img.red_mask = 0xFF0000;
            img.green_mask = 0x00FF00;
            img.blue_mask = 0x0000FF;
            XInitImage(&img);
            //XSetClipOrigin(x11display, _gc, 0, 0);
            XPutImage(x11display, _win,
                _gc, //DefaultGC(x11display, DefaultScreen(x11display)),
                &img,
                0, 0, 0, 0,
                _drawbuf.width,
                _drawbuf.height);
            //XFlush(x11display); // no need to XFlush since it will be called in event loop
        }
    }

    protected void drawUsingOpengl() {
        static if (ENABLE_OPENGL) {
            //Log.d("drawUsingOpengl()");
            glXMakeCurrent(x11display, cast(uint)_win, _glc);
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
            onDraw(buf);
            buf.afterDrawing();
            glXSwapBuffers(x11display, cast(uint)_win);
            destroy(buf);
        }
    }

    void redraw() {
        _lastRedrawEventCode = 0;
        //Use values cached by ConfigureNotify to avoid XGetWindowAttributes call.
        //XWindowAttributes window_attributes_return;
        //XGetWindowAttributes(x11display, _win, &window_attributes_return);
        //Log.d(format("XGetWindowAttributes reported size %d, %d", window_attributes_return.width, window_attributes_return.height));
        immutable width = _cachedWidth;
        immutable height = _cachedHeight;
        if (width > 0 && height > 0)
            onResize(width, height);
        debug(x11) Log.d(format("redraw(%d, %d)", width, height));
        if (_enableOpengl)
            drawUsingOpengl();
        else
            drawUsingBitmap();
    }

    protected ButtonDetails _lbutton;
    protected ButtonDetails _mbutton;
    protected ButtonDetails _rbutton;

    // x11 gives flags from time prior event so if left button is pressed there is not Button1Mask
    ushort convertMouseFlags(uint flags, MouseButton btn, bool pressed) {
        ushort res = 0;
        if (btn == MouseButton.Left) {
            if (pressed)
                res |= MouseFlag.LButton;
            else
                res &= ~MouseFlag.LButton;
        }
        else
            if (flags & Button1Mask)
                res |= MouseFlag.LButton;

        if (btn == MouseButton.Middle) {
            if (pressed)
                res |= MouseFlag.MButton;
            else
                res &= ~MouseFlag.MButton;
        }
        else
            if (flags & Button2Mask)
                res |= MouseFlag.MButton;

        if (btn == MouseButton.Right) {
            if (pressed)
                res |= MouseFlag.RButton;
            else
                res &= ~MouseFlag.RButton;
        }
        else
            if (flags & Button3Mask)
                res |= MouseFlag.RButton;

        return res;
    }

    MouseButton convertMouseButton(uint button) {
        if (button == Button1)
            return MouseButton.Left;
        if (button == Button2)
            return MouseButton.Middle;
        if (button == Button3)
            return MouseButton.Right;
        return MouseButton.None;
    }

    ushort lastFlags;
    short lastx;
    short lasty;
    uint _keyFlags;
    void processMouseEvent(MouseAction action, uint button, uint state, int x, int y) {
        MouseEvent event = null;
        if (action == MouseAction.Wheel) {
            // handle wheel
            short wheelDelta = cast(short)y;
            if (_keyFlags & KeyFlag.Shift)
                lastFlags |= MouseFlag.Shift;
            else
                lastFlags &= ~MouseFlag.Shift;
            if (_keyFlags & KeyFlag.Control)
                lastFlags |= MouseFlag.Control;
            else
                lastFlags &= ~MouseFlag.Control;
            if (_keyFlags & KeyFlag.Alt)
                lastFlags |= MouseFlag.Alt;
            else
                lastFlags &= ~MouseFlag.Alt;
            if (wheelDelta)
                event = new MouseEvent(action, MouseButton.None, lastFlags, lastx, lasty, wheelDelta);
        } else {
            MouseButton btn = convertMouseButton(button);
            lastFlags = convertMouseFlags(state, btn, action == MouseAction.ButtonDown);

            if (_keyFlags & KeyFlag.Shift)
                lastFlags |= MouseFlag.Shift;
            if (_keyFlags & KeyFlag.Control)
                lastFlags |= MouseFlag.Control;
            if (_keyFlags & KeyFlag.Alt)
                lastFlags |= MouseFlag.Alt;
            lastx = cast(short)x;
            lasty = cast(short)y;
            event = new MouseEvent(action, btn, lastFlags, lastx, lasty);
        }
        if (event) {
            ButtonDetails * pbuttonDetails = null;
            if (button == MouseButton.Left)
                pbuttonDetails = &_lbutton;
            else if (button == MouseButton.Right)
                pbuttonDetails = &_rbutton;
            else if (button == MouseButton.Middle)
                pbuttonDetails = &_mbutton;
            if (pbuttonDetails) {
                if (action == MouseAction.ButtonDown) {
                    pbuttonDetails.down(cast(short)x, cast(short)y, lastFlags);
                } else if (action == MouseAction.ButtonUp) {
                    pbuttonDetails.up(cast(short)x, cast(short)y, lastFlags);
                }
            }
            event.lbutton = _lbutton;
            event.rbutton = _rbutton;
            event.mbutton = _mbutton;

            bool res = dispatchMouseEvent(event);
            if (res) {
                debug(mouse) Log.d("Calling update() after mouse event");
                update();
                //invalidate();
            }
        }
    }

    uint convertKeyCode(uint keyCode) {
        import x11.keysymdef;
        alias KeyCode = dlangui.core.events.KeyCode;
        switch(keyCode) {
            case XK_0:
                return KeyCode.KEY_0;
            case XK_1:
                return KeyCode.KEY_1;
            case XK_2:
                return KeyCode.KEY_2;
            case XK_3:
                return KeyCode.KEY_3;
            case XK_4:
                return KeyCode.KEY_4;
            case XK_5:
                return KeyCode.KEY_5;
            case XK_6:
                return KeyCode.KEY_6;
            case XK_7:
                return KeyCode.KEY_7;
            case XK_8:
                return KeyCode.KEY_8;
            case XK_9:
                return KeyCode.KEY_9;
            case XK_A:
            case XK_a:
                return KeyCode.KEY_A;
            case XK_B:
            case XK_b:
                return KeyCode.KEY_B;
            case XK_C:
            case XK_c:
                return KeyCode.KEY_C;
            case XK_D:
            case XK_d:
                return KeyCode.KEY_D;
            case XK_E:
            case XK_e:
                return KeyCode.KEY_E;
            case XK_F:
            case XK_f:
                return KeyCode.KEY_F;
            case XK_G:
            case XK_g:
                return KeyCode.KEY_G;
            case XK_H:
            case XK_h:
                return KeyCode.KEY_H;
            case XK_I:
            case XK_i:
                return KeyCode.KEY_I;
            case XK_J:
            case XK_j:
                return KeyCode.KEY_J;
            case XK_K:
            case XK_k:
                return KeyCode.KEY_K;
            case XK_L:
            case XK_l:
                return KeyCode.KEY_L;
            case XK_M:
            case XK_m:
                return KeyCode.KEY_M;
            case XK_N:
            case XK_n:
                return KeyCode.KEY_N;
            case XK_O:
            case XK_o:
                return KeyCode.KEY_O;
            case XK_P:
            case XK_p:
                return KeyCode.KEY_P;
            case XK_Q:
            case XK_q:
                return KeyCode.KEY_Q;
            case XK_R:
            case XK_r:
                return KeyCode.KEY_R;
            case XK_S:
            case XK_s:
                return KeyCode.KEY_S;
            case XK_T:
            case XK_t:
                return KeyCode.KEY_T;
            case XK_U:
            case XK_u:
                return KeyCode.KEY_U;
            case XK_V:
            case XK_v:
                return KeyCode.KEY_V;
            case XK_W:
            case XK_w:
                return KeyCode.KEY_W;
            case XK_X:
            case XK_x:
                return KeyCode.KEY_X;
            case XK_Y:
            case XK_y:
                return KeyCode.KEY_Y;
            case XK_Z:
            case XK_z:
                return KeyCode.KEY_Z;
            case XK_F1:
                return KeyCode.F1;
            case XK_F2:
                return KeyCode.F2;
            case XK_F3:
                return KeyCode.F3;
            case XK_F4:
                return KeyCode.F4;
            case XK_F5:
                return KeyCode.F5;
            case XK_F6:
                return KeyCode.F6;
            case XK_F7:
                return KeyCode.F7;
            case XK_F8:
                return KeyCode.F8;
            case XK_F9:
                return KeyCode.F9;
            case XK_F10:
                return KeyCode.F10;
            case XK_F11:
                return KeyCode.F11;
            case XK_F12:
                return KeyCode.F12;
            case XK_F13:
                return KeyCode.F13;
            case XK_F14:
                return KeyCode.F14;
            case XK_F15:
                return KeyCode.F15;
            case XK_F16:
                return KeyCode.F16;
            case XK_F17:
                return KeyCode.F17;
            case XK_F18:
                return KeyCode.F18;
            case XK_F19:
                return KeyCode.F19;
            case XK_F20:
                return KeyCode.F20;
            case XK_F21:
                return KeyCode.F21;
            case XK_F22:
                return KeyCode.F22;
            case XK_F23:
                return KeyCode.F23;
            case XK_F24:
                return KeyCode.F24;
            case XK_BackSpace:
                return KeyCode.BACK;
            case XK_space:
                return KeyCode.SPACE;
            case XK_Tab:
                return KeyCode.TAB;
            case XK_Return:
            case XK_KP_Enter:
                return KeyCode.RETURN;
            case XK_Escape:
                return KeyCode.ESCAPE;
            case XK_KP_Delete:
            case XK_Delete:
            //case 0x40000063: // dirty hack for Linux - key on keypad
                return KeyCode.DEL;
            case XK_Insert:
            case XK_KP_Insert:
                //case 0x40000062: // dirty hack for Linux - key on keypad
                return KeyCode.INS;
            case XK_KP_Home:
            case XK_Home:
            //case 0x4000005f: // dirty hack for Linux - key on keypad
                return KeyCode.HOME;
            case XK_KP_Page_Up:
            case XK_Page_Up:
            //case 0x40000061: // dirty hack for Linux - key on keypad
                return KeyCode.PAGEUP;
            case XK_KP_End:
            case XK_End:
            //case 0x40000059: // dirty hack for Linux - key on keypad
                return KeyCode.END;
            case XK_KP_Page_Down:
            case XK_Page_Down:
            //case 0x4000005b: // dirty hack for Linux - key on keypad
                return KeyCode.PAGEDOWN;
            case XK_KP_Left:
            case XK_Left:
            //case 0x4000005c: // dirty hack for Linux - key on keypad
                return KeyCode.LEFT;
            case XK_KP_Right:
            case XK_Right:
            //case 0x4000005e: // dirty hack for Linux - key on keypad
                return KeyCode.RIGHT;
            case XK_KP_Up:
            case XK_Up:
            //case 0x40000060: // dirty hack for Linux - key on keypad
                return KeyCode.UP;
            case XK_KP_Down:
            case XK_Down:
            //case 0x4000005a: // dirty hack for Linux - key on keypad
                return KeyCode.DOWN;
            case XK_Control_L:
                return KeyCode.LCONTROL;
            case XK_Shift_L:
                return KeyCode.LSHIFT;
            case XK_Alt_L:
                return KeyCode.LALT;
            case XK_Control_R:
                return KeyCode.RCONTROL;
            case XK_Shift_R:
                return KeyCode.RSHIFT;
            case XK_Alt_R:
                return KeyCode.RALT;
            case XK_slash:
            case XK_KP_Divide:
                return KeyCode.KEY_DIVIDE;
            default:
                return 0x10000 | keyCode;
        }
    }

    uint convertKeyFlags(uint flags) {
        uint res;
        if (flags & ControlMask)
            res |= KeyFlag.Control;
        if (flags & ShiftMask)
            res |= KeyFlag.Shift;
        if (flags & LockMask)
            res |= KeyFlag.Alt;
//        if (flags & KMOD_RCTRL)
//            res |= KeyFlag.RControl | KeyFlag.Control;
//        if (flags & KMOD_RSHIFT)
//            res |= KeyFlag.RShift | KeyFlag.Shift;
//        if (flags & KMOD_RALT)
//            res |= KeyFlag.RAlt | KeyFlag.Alt;
//        if (flags & KMOD_LCTRL)
//            res |= KeyFlag.LControl | KeyFlag.Control;
//        if (flags & KMOD_LSHIFT)
//            res |= KeyFlag.LShift | KeyFlag.Shift;
//        if (flags & KMOD_LALT)
//            res |= KeyFlag.LAlt | KeyFlag.Alt;
        return res;
    }


    bool processKeyEvent(KeyAction action, uint keyCode, uint flags) {
        //debug(DebugSDL)
        Log.d("processKeyEvent ", action, " X11 key=0x", format("%08x", keyCode), " X11 flags=0x", format("%08x", flags));
        keyCode = convertKeyCode(keyCode);
        flags = convertKeyFlags(flags);
        Log.d("processKeyEvent ", action, " converted key=0x", format("%08x", keyCode), " flags=0x", format("%08x", flags));

        alias KeyCode = dlangui.core.events.KeyCode;
        if (action == KeyAction.KeyDown) {
            switch(keyCode) {
                case KeyCode.ALT:
                    flags |= KeyFlag.Alt;
                    break;
                case KeyCode.RALT:
                    flags |= KeyFlag.Alt | KeyFlag.RAlt;
                    break;
                case KeyCode.LALT:
                    flags |= KeyFlag.Alt | KeyFlag.LAlt;
                    break;
                case KeyCode.CONTROL:
                    flags |= KeyFlag.Control;
                    break;
                case KeyCode.RCONTROL:
                    flags |= KeyFlag.Control | KeyFlag.RControl;
                    break;
                case KeyCode.LCONTROL:
                    flags |= KeyFlag.Control | KeyFlag.LControl;
                    break;
                case KeyCode.SHIFT:
                    flags |= KeyFlag.Shift;
                    break;
                case KeyCode.RSHIFT:
                    flags |= KeyFlag.Shift | KeyFlag.RShift;
                    break;
                case KeyCode.LSHIFT:
                    flags |= KeyFlag.Shift | KeyFlag.LShift;
                    break;
                default:
                    break;
            }
        }
        _keyFlags = flags;

        debug(DebugSDL) Log.d("processKeyEvent ", action, " converted key=0x", format("%08x", keyCode), " converted flags=0x", format("%08x", flags));
        bool res = dispatchKeyEvent(new KeyEvent(action, keyCode, flags));
        //            if ((keyCode & 0x10000) && (keyCode & 0xF000) != 0xF000) {
        //                dchar[1] text;
        //                text[0] = keyCode & 0xFFFF;
        //                res = dispatchKeyEvent(new KeyEvent(KeyAction.Text, keyCode, flags, cast(dstring)text)) || res;
        //            }
        if (res) {
            debug(keys) Log.d("Calling update() after key event");
            //invalidate();
            update();
        }
        return res;
    }

    bool processTextInput(dstring ds, uint flags) {
        flags = convertKeyFlags(flags);
        bool res = dispatchKeyEvent(new KeyEvent(KeyAction.Text, 0, flags, ds));
        if (res) {
            debug(keys) Log.d("Calling update() after text event");
            invalidate();
        }
        return res;
    }

    /// after drawing, call to schedule redraw if animation is active
    override void scheduleAnimation() {
        invalidate();
    }

    TimerThread timer;
    private long _nextExpectedTimerTs;

    /// schedule timer for interval in milliseconds - call window.onTimer when finished
    override protected void scheduleSystemTimer(long intervalMillis) {
        if (!timer) {
            timer = new TimerThread(delegate() {
                XEvent ev;
                memset(&ev, 0, ev.sizeof);
                //ev.xclient = XClientMessageEvent.init;
                ev.xclient.type = ClientMessage;
                ev.xclient.message_type = atom_DLANGUI_TIMER_EVENT;
                ev.xclient.window = _win;
                ev.xclient.display = x11display2;
                ev.xclient.format = 32;
                //Log.d("Sending timer event");
                XLockDisplay(x11display2);
                XSendEvent(x11display2, _win, false, StructureNotifyMask, &ev);
                XFlush(x11display2);
                XUnlockDisplay(x11display2);
            });
        }
        if (intervalMillis < 10)
            intervalMillis = 10;
        long nextts = currentTimeMillis + intervalMillis;
        if (_nextExpectedTimerTs == 0 || _nextExpectedTimerTs > nextts) {
            _nextExpectedTimerTs = nextts;
            timer.set(nextts);
        }
    }

    bool handleTimer() {
        if (!_nextExpectedTimerTs)
            return false;
        long ts = currentTimeMillis;
        if (ts >= _nextExpectedTimerTs) {
            _nextExpectedTimerTs = 0;
            onTimer();
            return true;
        }
        return false;
    }

    /// post event to handle in UI thread (this method can be used from background thread)
    override void postEvent(CustomEvent event) {
        super.postEvent(event);
        XEvent ev;
        memset(&ev, 0, ev.sizeof);
        ev.xclient.type = ClientMessage;
        ev.xclient.window = _win;
        ev.xclient.display = x11display2;
        ev.xclient.message_type = atom_DLANGUI_TASK_EVENT;
        ev.xclient.format = 32;
        ev.xclient.data.l[0] = event.uniqueId;
        XLockDisplay(x11display2);
        XSendEvent(x11display2, _win, false, StructureNotifyMask, &ev);
        XFlush(x11display2);
        XUnlockDisplay(x11display2);
        //        SDL_Event sdlevent;
//        sdlevent.user.type = USER_EVENT_ID;
//        sdlevent.user.code = cast(int)event.uniqueId;
//        sdlevent.user.windowID = windowId;
//        SDL_PushEvent(&sdlevent);
    }

    protected uint _lastCursorType = CursorType.None;
    /// sets cursor type for window
    override protected void setCursorType(uint cursorType) {
        if (_lastCursorType != cursorType) {
            Log.d("setCursorType(", cursorType, ")");
            _lastCursorType = cursorType;
            XDefineCursor(x11display, _win, x11cursors[cursorType]);
            XFlush(x11display);
        }
    }
}

private immutable int CUSTOM_EVENT = 32;
private immutable int TIMER_EVENT = 8;

class X11Platform : Platform {

    this() {
        import std.file : thisExePath;
        import std.path : baseName;
        _classname = (baseName(thisExePath()) ~ "\0").dup.ptr;
    }

    private X11Window[XWindow] _windowMap;
    private char* _classname;

    /**
     * create window
     * Args:
     *         windowCaption = window caption text
     *         parent = parent Window, or null if no parent
     *         flags = WindowFlag bit set, combination of Resizable, Modal, Fullscreen
     *      width = window width
     *      height = window height
     *
     * Window w/o Resizable nor Fullscreen will be created with size based on measurement of its content widget
     */
    override DWindow createWindow(dstring windowCaption, DWindow parent, uint flags = WindowFlag.Resizable, uint width = 0, uint height = 0) {
        int newwidth = width;
        int newheight = height;
        X11Window window = new X11Window(this, windowCaption, parent, flags, newwidth, newheight);
        _windowMap[window._win] = window;
        return window;
    }

    X11Window findWindow(XWindow windowId) {
        if (windowId in _windowMap)
            return _windowMap[windowId];
        return null;
    }

    /**
     * close window
     *
     * Closes window earlier created with createWindow()
     */
    override void closeWindow(DWindow w) {
        X11Window window = cast(X11Window)w;
        XEvent ev;
        memset(&ev, 0, ev.sizeof);
        ev.xclient.type = ClientMessage;
        ev.xclient.message_type = atom_DLANGUI_CLOSE_WINDOW_EVENT;
        ev.xclient.window = window._win;
        ev.xclient.display = x11display2;
        ev.xclient.format = 32;
        Log.d("Sending close window event");
        XLockDisplay(x11display2);
        XSendEvent(x11display2, window._win, false, StructureNotifyMask, &ev);
        XFlush(x11display2);
        XUnlockDisplay(x11display2);
    }

    bool handleTimers() {
        bool handled = false;
        foreach(w; _windowMap) {
            if (w.handleTimer()) {
                handled = true;
                break;
            }
        }
        return handled;
    }

    final bool allWindowsClosed() {
        return _windowMap.length == 0;
    }

    protected int numberOfPendingEvents(int msecs = 10)
    {
        import core.sys.posix.sys.select;
        int x11displayFd = ConnectionNumber(x11display);
        fd_set fdSet;
        FD_ZERO(&fdSet);
        FD_SET(x11displayFd, &fdSet);
        scope(exit) FD_ZERO(&fdSet);

        int eventsInQueue = XEventsQueued(x11display, QueuedAlready);
        if (!eventsInQueue) {
            import core.stdc.errno;
            int selectResult;
            do {
                timeval timeout;
                timeout.tv_usec = msecs;
                selectResult = select(x11displayFd + 1, &fdSet, null, null, &timeout);
            } while(selectResult == -1 && errno == EINTR);
            if (selectResult < 0) {
                Log.e("X11: display fd select error");
            } else if (selectResult == 1) {
                //Log.d("X11: XPending");
                eventsInQueue = XPending(x11display);
            }
        }
        return eventsInQueue;
    }

    protected void processXEvent(ref XEvent event)
    {
        XComposeStatus compose;
        switch (event.type) {
            case ConfigureNotify:
                X11Window w = findWindow(event.xconfigure.window);
                if (w) {
                    w._cachedWidth = event.xconfigure.width;
                    w._cachedHeight = event.xconfigure.height;
                    w.handleWindowStateChange(WindowState.unspecified, Rect(event.xconfigure.x, event.xconfigure.y, event.xconfigure.width, event.xconfigure.height));
                } else {
                    Log.e("ConfigureNotify: Window not found");
                }
                break;
            case PropertyNotify:
                if (event.xproperty.atom == atom_NET_WM_STATE && event.xproperty.state == PropertyNewValue) {
                    X11Window w = findWindow(event.xproperty.window);
                    if (w) {
                        Atom type;
                        int format;
                        ubyte* properties;
                        c_ulong dataLength, overflow;
                        if (XGetWindowProperty(x11display, event.xproperty.window, atom_NET_WM_STATE,
                            0, int.max/4, False, AnyPropertyType, &type, &format, &dataLength, &overflow, &properties) == 0) {
                            scope(exit) XFree(properties);
                            // check for minimized
                            bool minimized = false;
                            for (int i=0; i < dataLength ; i++) {
                                if (((cast(c_ulong*)properties)[i]) == atom_NET_WM_STATE_HIDDEN) {
                                    w.handleWindowStateChange(WindowState.minimized);
                                    minimized = true;
                                }
                            }
                            if (!minimized) {
                                bool maximizedH = false;
                                bool maximizedV = false;
                                for (int i=0; i < dataLength ; i++) {
                                    if (((cast(c_ulong*)properties)[i]) == atom_NET_WM_STATE_MAXIMIZED_VERT)
                                        maximizedV = true;
                                    if (((cast(c_ulong*)properties)[i]) == atom_NET_WM_STATE_MAXIMIZED_HORZ)
                                        maximizedH = true;
                                }

                                if (maximizedV && maximizedH)
                                    w.handleWindowStateChange(WindowState.maximized);
                                else
                                    w.handleWindowStateChange(WindowState.normal);

                            }
                        }
                    }
                }
                break;
            case MapNotify:
                X11Window w = findWindow(event.xmap.window);
                if (w) {
                    w.handleWindowStateChange(WindowState.normal);
                }
                break;
            case UnmapNotify:
                X11Window w = findWindow(event.xunmap.window);
                if (w) {
                    w.handleWindowStateChange(WindowState.hidden);
                }
                break;
            case Expose:
                if (event.xexpose.count == 0) {
                    X11Window w = findWindow(event.xexpose.window);
                    if (w) {
                        w.invalidate();
                    } else {
                        Log.e("Expose: Window not found");
                    }
                } else {
                    Log.d("Expose: non-0 count");
                }
                break;
            case KeyPress:
                Log.d("X11: KeyPress event");
                X11Window w = findWindow(event.xkey.window);
                if (w) {
                    char[100] buf;
                    KeySym ks;
                    Status s;
                    if (!w.xic) {
                        w.xic = XCreateIC(xim,
                            XNInputStyle, XIMPreeditNothing | XIMStatusNothing,
                            XNClientWindow, w._win, 0);
                        if (!w.xic) {
                            Log.e("Cannot create input context");
                        }
                    }

                    if (!w.xic)
                        XLookupString(&event.xkey, buf.ptr, buf.length - 1, &ks, &compose);
                    else {
                        Xutf8LookupString(w.xic, &event.xkey, buf.ptr, cast(int)buf.length - 1, &ks, &s);
                        if (s != XLookupChars && s != XLookupBoth)
                            XLookupString(&event.xkey, buf.ptr, buf.length - 1, &ks, &compose);
                    }
                    foreach(ref ch; buf) {
                        if (ch == 255 || ch < 32 || ch == 127)
                            ch = 0;
                    }
                    string txt = fromStringz(buf.ptr).dup;
                    import std.utf;
                    dstring dtext;
                    try {
                        if (txt.length)
                            dtext = toUTF32(txt);
                    } catch (UTFException e) {
                        // ignore, invalid text
                    }
                    debug(x11) Log.d("X11: KeyPress event bytes=", txt.length, " text=", txt, " dtext=", dtext);
                    if (dtext.length) {
                        w.processTextInput(dtext, event.xkey.state);
                    } else {
                        w.processKeyEvent(KeyAction.KeyDown, cast(uint)ks,
                            //event.xkey.keycode,
                            event.xkey.state);
                    }
                } else {
                    Log.e("Window not found");
                }
                break;
            case KeyRelease:
                Log.d("X11: KeyRelease event");
                X11Window w = findWindow(event.xkey.window);
                if (w) {
                    char[100] buf;
                    KeySym ks;
                    XLookupString(&event.xkey, buf.ptr, buf.length - 1, &ks, &compose);
                    w.processKeyEvent(KeyAction.KeyUp, cast(uint)ks,
                        //event.xkey.keycode,
                        event.xkey.state);
                } else {
                    Log.e("Window not found");
                }
                break;
            case ButtonPress:
                Log.d("X11: ButtonPress event");
                X11Window w = findWindow(event.xbutton.window);
                if (w) {
                    if (event.xbutton.button == 4 || event.xbutton.button == 5) {
                        w.processMouseEvent(MouseAction.Wheel, 0, 0, 0, event.xbutton.button == 4 ? 1 : -1);
                    } else {
                        w.processMouseEvent(MouseAction.ButtonDown, event.xbutton.button, event.xbutton.state, event.xbutton.x, event.xbutton.y);
                    }
                } else {
                    Log.e("Window not found");
                }
                break;
            case ButtonRelease:
                Log.d("X11: ButtonRelease event");
                X11Window w = findWindow(event.xbutton.window);
                if (w) {
                    w.processMouseEvent(MouseAction.ButtonUp, event.xbutton.button, event.xbutton.state, event.xbutton.x, event.xbutton.y);
                } else {
                    Log.e("Window not found");
                }
                break;
            case MotionNotify:
                debug(x11) Log.d("X11: MotionNotify event");
                X11Window w = findWindow(event.xmotion.window);
                if (w) {
                    w.processMouseEvent(MouseAction.Move, 0, event.xmotion.state, event.xmotion.x, event.xmotion.y);
                } else {
                    Log.e("Window not found");
                }
                break;
            case EnterNotify:
                Log.d("X11: EnterNotify event");
                X11Window w = findWindow(event.xcrossing.window);
                if (w) {
                    w.processMouseEvent(MouseAction.Move, 0, event.xmotion.state, event.xcrossing.x, event.xcrossing.y);
                } else {
                    Log.e("Window not found");
                }
                break;
            case LeaveNotify:
                Log.d("X11: LeaveNotify event");
                X11Window w = findWindow(event.xcrossing.window);
                if (w) {
                    w.processMouseEvent(MouseAction.Leave, 0, event.xcrossing.state, event.xcrossing.x, event.xcrossing.y);
                } else {
                    Log.e("Window not found");
                }
                break;
            case CreateNotify:
                Log.d("X11: CreateNotify event");
                X11Window w = findWindow(event.xcreatewindow.window);
                if (!w) {
                    Log.e("Window not found");
                }
                break;
            case DestroyNotify:
                Log.d("X11: DestroyNotify event");
                break;
            case ResizeRequest:
                Log.d("X11: ResizeRequest event");
                X11Window w = findWindow(event.xresizerequest.window);
                if (!w) {
                    Log.e("Window not found");
                }
                break;
            case FocusIn:
                Log.d("X11: FocusIn event");
                X11Window w = findWindow(event.xfocus.window);
                if (w)
                    w.handleWindowActivityChange(true);
                else
                    Log.e("Window not found");
                break;
            case FocusOut:
                Log.d("X11: FocusOut event");
                X11Window w = findWindow(event.xfocus.window);
                if (w)
                    w.handleWindowActivityChange(false);
                else
                    Log.e("Window not found");
                break;
            case KeymapNotify:
                Log.d("X11: KeymapNotify event");
                X11Window w = findWindow(event.xkeymap.window);
                break;
            case SelectionClear:
                Log.d("X11: SelectionClear event");
                break;
            case SelectionRequest:
                debug(x11) Log.d("X11: SelectionRequest event");
                if (event.xselectionrequest.owner in _windowMap) {
                    XSelectionRequestEvent *selectionRequest = &event.xselectionrequest;

                    XEvent selectionEvent;
                    memset(&selectionEvent, 0, selectionEvent.sizeof);
                    selectionEvent.xany.type = SelectionNotify;
                    selectionEvent.xselection.selection = selectionRequest.selection;
                    selectionEvent.xselection.target = selectionRequest.target;
                    selectionEvent.xselection.property = None;
                    selectionEvent.xselection.requestor = selectionRequest.requestor;
                    selectionEvent.xselection.time = selectionRequest.time;

                    if (selectionRequest.target == XA_STRING || selectionRequest.target == atom_UTF8_STRING) {
                        int currentSelectionFormat;
                        Atom currentSelectionType;
                        c_ulong selectionDataLength, overflow;
                        ubyte* selectionDataPtr;
                        if (XGetWindowProperty(x11display, DefaultRootWindow(x11display), atom_DLANGUI_CLIPBOARD_BUFFER,
                            0, int.max/4, False, selectionRequest.target,
                            &currentSelectionType, &currentSelectionFormat, &selectionDataLength,
                            &overflow, &selectionDataPtr) == 0)
                        {
                            scope(exit) XFree(selectionDataPtr);
                            XChangeProperty(x11display, selectionRequest.requestor, selectionRequest.property,
                                selectionRequest.target, 8, PropModeReplace,
                                selectionDataPtr, cast(int)selectionDataLength);
                        }
                        selectionEvent.xselection.property = selectionRequest.property;
                    } else if (selectionRequest.target == atom_TARGETS) {
                        Atom[3] supportedFormats = [atom_UTF8_STRING, XA_STRING, atom_TARGETS];
                        XChangeProperty(x11display, selectionRequest.requestor, selectionRequest.property,
                            XA_ATOM, 32, PropModeReplace,
                            cast(ubyte*)supportedFormats.ptr, cast(int)supportedFormats.length);
                        selectionEvent.xselection.property = selectionRequest.property;
                    }
                    XSendEvent(x11display, selectionRequest.requestor, False, 0, &selectionEvent);
                }
                break;
            case SelectionNotify:
                debug(x11) Log.d("X11: SelectionNotify event");
                X11Window w = findWindow(event.xselection.requestor);
                if (w) {
                    waitingForSelection = false;
                }
                break;
            case ClientMessage:
                debug(x11) Log.d("X11: ClientMessage event");
                X11Window w = findWindow(event.xclient.window);
                if (w) {
                    if (event.xclient.message_type == atom_DLANGUI_TASK_EVENT) {
                        w.handlePostedEvent(cast(uint)event.xclient.data.l[0]);
                    } else if (event.xclient.message_type == atom_DLANGUI_TIMER_EVENT) {
                        w.handleTimer();
                    } else if (event.xclient.message_type == atom_DLANGUI_REDRAW_EVENT) {
                        if (event.xclient.data.l[0] == w._lastRedrawEventCode)
                            w.redraw();
                    } else if (event.xclient.message_type == atom_WM_PROTOCOLS) {
                        Log.d("Handling WM_PROTOCOLS");
                        if ((event.xclient.format == 32) && (event.xclient.data.l[0]) == atom_WM_DELETE_WINDOW) {
                            Log.d("Handling WM_DELETE_WINDOW");
                            _windowMap.remove(w._win);
                            destroy(w);
                        }
                    } else if (event.xclient.message_type == atom_DLANGUI_CLOSE_WINDOW_EVENT) {
                        _windowMap.remove(w._win);
                        destroy(w);
                    }
                } else {
                    Log.e("Window not found");
                }
                break;
            default:
                break;
        }
    }

    protected void pumpEvents()
    {
        XFlush(x11display);
        // Note:  only events we set the mask for are detected!
        while(numberOfPendingEvents())
        {
            if (allWindowsClosed())
                break;
            XEvent event;        /* the XEvent declaration !!! */
            XNextEvent(x11display, &event);
            processXEvent(event);
        }
    }

    /**
     * Starts application message loop.
     *
     * When returned from this method, application is shutting down.
     */
    override int enterMessageLoop() {
        Log.d("enterMessageLoop()");

        while(!allWindowsClosed()) {
            pumpEvents();
        }
        return 0;
    }

    /// check has clipboard text
    override bool hasClipboardText(bool mouseBuffer = false) {
        const selectionType = mouseBuffer ? XA_PRIMARY : atom_CLIPBOARD;
        return XGetSelectionOwner(x11display, selectionType) != None;
    }

    protected bool waitingForSelection;
    /// retrieves text from clipboard (when mouseBuffer == true, use mouse selection clipboard - under linux)
    override dstring getClipboardText(bool mouseBuffer = false) {
        const selectionType = mouseBuffer ? XA_PRIMARY : atom_CLIPBOARD;
        auto owner = XGetSelectionOwner(x11display, selectionType);
        if (owner == None) {
            Log.d("Selection owner is none");
            return ""d;
        } else {
            // Find any top-level window
            XWindow xwindow;
            foreach(w; _windowMap) {
                if (w._parent is null && w._win != None) {
                    xwindow = w._win;
                    break;
                }
            }
            if (xwindow != None) {
                import std.datetime;
                waitingForSelection = true;
                XConvertSelection(x11display, selectionType, atom_UTF8_STRING, atom_DLANGUI_CLIPBOARD_BUFFER, xwindow, CurrentTime);
                auto stopWaiting = Clock.currTime() + dur!"msecs"(500);
                while(waitingForSelection) {
                    if (stopWaiting <= Clock.currTime()) {
                        waitingForSelection = false;
                        setClipboardText(""d);
                        Log.e("Waiting for clipboard contents timeout");
                        return ""d;
                    }
                    pumpEvents();
                }
                Atom selectionTarget;
                int selectionFormat;
                c_ulong selectionDataLength, overflow;
                ubyte* selectionDataPtr;
                if (XGetWindowProperty(x11display, xwindow, atom_DLANGUI_CLIPBOARD_BUFFER, 0, int.max/4, False, 0, &selectionTarget, &selectionFormat, &selectionDataLength, &overflow, &selectionDataPtr) == 0)
                {
                    scope(exit) XFree(selectionDataPtr);
                    if (selectionTarget == XA_STRING || selectionTarget == atom_UTF8_STRING) {
                        char[] selectionText = cast(char[])selectionDataPtr[0..selectionDataLength];
                        return toUTF32(selectionText);
                    } else {
                        Log.d("Selection type is not a string!");
                    }
                }
            } else {
                Log.d("Could not find any window to get selection");
            }
        }
        return ""d;
    }

    /// sets text to clipboard (when mouseBuffer == true, use mouse selection clipboard - under linux)
    override void setClipboardText(dstring text, bool mouseBuffer = false) {
        if (!mouseBuffer && atom_CLIPBOARD == None) {
            Log.e("No CLIPBOARD atom available");
            return;
        }
        auto selection = mouseBuffer ? XA_PRIMARY : atom_CLIPBOARD;
        XWindow xwindow = None;
        // Find any top-level window
        foreach(w; _windowMap) {
            if (w._parent is null && w._win != None) {
                xwindow = w._win;
            }
        }
        if (xwindow == None) {
            Log.e("Could not find window to save clipboard text");
            return;
        }

        auto textc = text.toUTF8;
        XChangeProperty(x11display, DefaultRootWindow(x11display), atom_DLANGUI_CLIPBOARD_BUFFER, atom_UTF8_STRING, 8, PropModeReplace, cast(ubyte*)textc.ptr, cast(int)textc.length);

        if (XGetSelectionOwner(x11display, selection) != xwindow) {
            XSetSelectionOwner(x11display, selection, xwindow, CurrentTime);
        }
    }

    /// calls request layout for all windows
    override void requestLayout() {
        foreach(w; _windowMap) {
            w.requestLayout();
        }
    }

    /// returns true if there is some modal window opened above this window, and this window should not process mouse/key input and should not allow closing
    override bool hasModalWindowsAbove(DWindow w) {
        X11Window x11Win = cast (X11Window) w;
        if (x11Win) {
            return x11Win.hasVisibleModalChild();
        }
        return false;
    }

    /// handle theme change: e.g. reload some themed resources
    override void onThemeChanged() {
        super.onThemeChanged();
        foreach(w; _windowMap)
            w.dispatchThemeChanged();
    }

}

import core.thread;
import core.sync.mutex;
import core.sync.condition;
class TimerThread : Thread {
    Mutex mutex;
    Condition condition;
    bool stopped;
    long nextEventTs;
    void delegate() callback;

    this(void delegate() timerCallback) {
        callback = timerCallback;
        mutex = new Mutex();
        condition = new Condition(mutex);
        super(&run);
        start();
    }

    ~this() {
        stop();
        destroy(condition);
        destroy(mutex);
    }

    void set(long nextTs) {
        mutex.lock();
        if (nextEventTs == 0 || nextEventTs > nextTs) {
            nextEventTs = nextTs;
            condition.notify();
        }
        mutex.unlock();
    }
    void run() {

        while (!stopped) {
            bool expired = false;

            mutex.lock();

            long ts = currentTimeMillis;
            long timeToWait = nextEventTs == 0 ? 1000000 : nextEventTs - ts;
            if (timeToWait < 10)
                timeToWait = 10;

            if (nextEventTs == 0)
                condition.wait();
            else
                condition.wait(dur!"msecs"(timeToWait));

            if (stopped) {
                mutex.unlock();
                break;
            }
            ts = currentTimeMillis;
            if (nextEventTs && nextEventTs < ts && !stopped) {
                expired = true;
                nextEventTs = 0;
            }

            mutex.unlock();

            if (expired)
                callback();
        }
    }
    void stop() {
        if (stopped)
            return;
        stopped = true;
        mutex.lock();
        condition.notify();
        mutex.unlock();
        join();
    }
}


extern(C) int DLANGUImain(string[] args)
{
    initLogs();

    if (!initFontManager()) {
        Log.e("******************************************************************");
        Log.e("No font files found!!!");
        Log.e("Currently, only hardcoded font paths implemented.");
        Log.e("Probably you can modify sdlapp.d to add some fonts for your system.");
        Log.e("TODO: use fontconfig");
        Log.e("******************************************************************");
        assert(false);
    }
    initResourceManagers();

    currentTheme = createDefaultTheme();

    XInitThreads();

    /* use the information from the environment variable DISPLAY
       to create the X connection:
    */
    x11display = XOpenDisplay(null);
    if (!x11display) {
        Log.e("Cannot open X11 display");
        return 1;
    }
    x11display2 = XOpenDisplay(null);
    if (!x11display2) {
        Log.e("Cannot open secondary connection for X11 display");
        return 1;
    }

    x11screen = DefaultScreen(x11display);

    static if (ENABLE_OPENGL) {
        try {
            DerelictGL3.missingSymbolCallback = &gl3MissingSymFunc;
            DerelictGL3.load();
            DerelictGL.missingSymbolCallback = &gl3MissingSymFunc;
            DerelictGL.load();
            Log.d("OpenGL library loaded ok");
            GLint[] att = [ GLX_RGBA, GLX_DEPTH_SIZE, 24, GLX_DOUBLEBUFFER, None ];
            XWindow root;
            root = DefaultRootWindow(x11display);
            x11visual = glXChooseVisual(x11display, 0, cast(int*)att.ptr);
            if (x11visual) {
                x11cmap = XCreateColormap(x11display, root, cast(Visual*)x11visual.visual, AllocNone);
                _enableOpengl = true;
            } else {
                Log.e("Cannot find suitable Visual for using of OpenGL");
            }
        } catch (Exception e) {
            Log.e("Cannot load OpenGL library", e);
        }
    }


    setupX11Atoms();

    x11cursors[CursorType.None] = XCreateFontCursor(x11display, XC_arrow);
    x11cursors[CursorType.Parent] = XCreateFontCursor(x11display, XC_arrow);
    x11cursors[CursorType.Arrow] = XCreateFontCursor(x11display, XC_left_ptr);
    x11cursors[CursorType.IBeam] = XCreateFontCursor(x11display, XC_xterm);
    x11cursors[CursorType.Wait] = XCreateFontCursor(x11display, XC_watch);
    x11cursors[CursorType.Crosshair] = XCreateFontCursor(x11display, XC_tcross);
    x11cursors[CursorType.WaitArrow] = XCreateFontCursor(x11display, XC_watch);
    x11cursors[CursorType.SizeNWSE] = XCreateFontCursor(x11display, XC_fleur);
    x11cursors[CursorType.SizeNESW] = XCreateFontCursor(x11display, XC_fleur);
    x11cursors[CursorType.SizeWE] = XCreateFontCursor(x11display, XC_sb_h_double_arrow);
    x11cursors[CursorType.SizeNS] = XCreateFontCursor(x11display, XC_sb_v_double_arrow);
    x11cursors[CursorType.SizeAll] = XCreateFontCursor(x11display, XC_fleur);
    x11cursors[CursorType.No] = XCreateFontCursor(x11display, XC_pirate);
    x11cursors[CursorType.Hand] = XCreateFontCursor(x11display, XC_hand2);

    xim = XOpenIM(x11display, null, null, null);
    if (!xim) {
        Log.e("Cannot open input method");
    }

    Log.d("X11 display=", x11display, " screen=", x11screen);



    X11Platform x11platform = new X11Platform();

    Platform.setInstance(x11platform);

    int res = 0;

    version (unittest) {
    } else {
        res = UIAppMain(args);
    }

    //Log.e("Widget instance count after UIAppMain: ", Widget.instanceCount());

    Log.d("Destroying X11 platform");
    Platform.setInstance(null);

    releaseResourcesOnAppExit();


    XCloseDisplay(x11display);
    XCloseDisplay(x11display2);

    Log.d("Exiting main width result=", res);

    return res;
}
