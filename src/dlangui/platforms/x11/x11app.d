module dlangui.platforms.x11.x11app;

public import dlangui.core.config;
static if (BACKEND_X11):

import dlangui.core.logger;
import dlangui.core.events;
import dlangui.core.files;
import dlangui.core.types : toUTF8;
import core.time : MonoTime, seconds;
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
    import bindbc.opengl;
    import dlangui.graphics.gldrawbuf;
    import dlangui.graphics.glsupport;
    import glx.glx;

    private __gshared XVisualInfo * x11visual;
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
    Atom   atom_NET_WM_PID;

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
    Atom   atom_DLANGUI_XDND_BUFFER;

    // XDND (drag and drop) protocol
    Atom   atom_XdndAware;
    Atom   atom_XdndEnter;
    Atom   atom_XdndPosition;
    Atom   atom_XdndStatus;
    Atom   atom_XdndLeave;
    Atom   atom_XdndDrop;
    Atom   atom_XdndFinished;
    Atom   atom_XdndSelection;
    Atom   atom_XdndTypeList;
    Atom   atom_XdndActionCopy;
    Atom   atom_TEXT_URI_LIST;
}

static void setupX11Atoms()
{
    assert(x11display !is null, "X Connection must be established before getting atoms");
    // all with only_if_exists = False: the atoms are created if no window manager or other client did yet (e.g. on
    // Xvfb), so they are never None (#1181). Window manager hints set with them are data a window manager reads (also
    // one started later); the selection atoms are needed by the clipboard calls. With an atom of None, requests such as
    // XChangeProperty and XGetSelectionOwner fail with BadAtom, and Xlib's default error handler exits the app
    atom_UTF8_STRING = XInternAtom(x11display, "UTF8_STRING", False);
    atom_CLIPBOARD   = XInternAtom(x11display, "CLIPBOARD", False);
    atom_TARGETS     = XInternAtom(x11display, "TARGETS", False);
    atom_WM_PROTOCOLS = XInternAtom(x11display, "WM_PROTOCOLS", False);
    atom_WM_DELETE_WINDOW = XInternAtom(x11display, "WM_DELETE_WINDOW", False);
    atom_NET_WM_ICON = XInternAtom(x11display, "_NET_WM_ICON", False);
    atom_NET_WM_NAME = XInternAtom(x11display, "_NET_WM_NAME", False);
    atom_NET_WM_ICON_NAME = XInternAtom(x11display, "_NET_WM_ICON_NAME", False);
    atom_NET_WM_PID = XInternAtom(x11display, "_NET_WM_PID", False);
    atom_NET_WM_STATE = XInternAtom(x11display, "_NET_WM_STATE", False);
    atom_NET_WM_STATE_MODAL = XInternAtom(x11display, "_NET_WM_STATE_MODAL", False);
    atom_NET_WM_STATE_MAXIMIZED_VERT = XInternAtom(x11display, "_NET_WM_STATE_MAXIMIZED_VERT", False);
    atom_NET_WM_STATE_MAXIMIZED_HORZ = XInternAtom(x11display, "_NET_WM_STATE_MAXIMIZED_HORZ", False);
    atom_NET_WM_STATE_HIDDEN = XInternAtom(x11display, "_NET_WM_STATE_HIDDEN", False);
    atom_NET_WM_STATE_FULLSCREEN = XInternAtom(x11display, "_NET_WM_STATE_FULLSCREEN", False);
    atom_MOTIF_WM_HINTS = XInternAtom(x11display, "_MOTIF_WM_HINTS", False);

    atom_DLANGUI_TIMER_EVENT     = XInternAtom(x11display, "DLANGUI_TIMER_EVENT", False);
    atom_DLANGUI_TASK_EVENT     = XInternAtom(x11display, "DLANGUI_TASK_EVENT", False);
    atom_DLANGUI_CLOSE_WINDOW_EVENT = XInternAtom(x11display, "DLANGUI_CLOSE_WINDOW_EVENT", False);
    atom_DLANGUI_CLIPBOARD_BUFFER = XInternAtom(x11display, "DLANGUI_CLIPBOARD_BUFFER", False);
    atom_DLANGUI_REDRAW_EVENT = XInternAtom(x11display, "DLANGUI_REDRAW_EVENT", False);
    atom_DLANGUI_XDND_BUFFER = XInternAtom(x11display, "DLANGUI_XDND_BUFFER", False);

    atom_XdndAware = XInternAtom(x11display, "XdndAware", False);
    atom_XdndEnter = XInternAtom(x11display, "XdndEnter", False);
    atom_XdndPosition = XInternAtom(x11display, "XdndPosition", False);
    atom_XdndStatus = XInternAtom(x11display, "XdndStatus", False);
    atom_XdndLeave = XInternAtom(x11display, "XdndLeave", False);
    atom_XdndDrop = XInternAtom(x11display, "XdndDrop", False);
    atom_XdndFinished = XInternAtom(x11display, "XdndFinished", False);
    atom_XdndSelection = XInternAtom(x11display, "XdndSelection", False);
    atom_XdndTypeList = XInternAtom(x11display, "XdndTypeList", False);
    atom_XdndActionCopy = XInternAtom(x11display, "XdndActionCopy", False);
    atom_TEXT_URI_LIST = XInternAtom(x11display, "text/uri-list", False);
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
    private bool _mapped;
    /// hidden by hideWindow() until mapped again: _NET_WM_STATE changes are ignored (some window managers write an
    /// empty list or delete it when a window is withdrawn, events queued before can still say iconified) (#1190)
    private bool _withdrawn;
    /// mapped now (MapNotify until UnmapNotify): _NET_WM_STATE changes of a window the window manager unmapped
    /// (e.g. on another desktop) don't make it normal or maximized (#1190)
    private bool _viewable;
    /// show() was called: until then, states are set in the _NET_WM_STATE property and WM_HINTS (#1197)
    private bool _shown;
    /// when minimizeWindow() sent an iconify request (init: none pending) (#1198)
    private MonoTime _iconifyRequested;
    /// restoreWindow() came while the iconify request was pending: mapped again when the iconify is reported (#1198)
    private bool _restoreAfterIconify;
    /// WM_HINTS initial_state is IconicState: a map from the withdrawn state iconifies the window (#1198)
    private bool _initialIconic;
    /// mapped from the withdrawn state with IconicState and not mapped (viewable) since: restoreWindow() maps it,
    /// also when the window manager reports no state (ICCCM only) (#1197)
    private bool _shownIconic;
    /// the serial of the map request that showed a window hidden by hideWindow() again (0: none): events from the
    /// window manager with this serial or later come after it, earlier ones from before (#1197)
    private c_ulong _mapRequestSerial;
    // #820: correction of a position set by the application
    private bool _positionCheckPending;
    private Point _positionWanted;
    private Point _positionRequested;
    private int _positionCorrections;
    private Point _positionCorrected; // the position that caused the last correction
    private MonoTime _positionCheckDeadline;

    static if (ENABLE_OPENGL) {
        GLXContext _glc;
    }

    this(X11Platform platform, dstring caption, DWindow parent, uint flags, uint width = 0, uint height = 0) {
        _platform = platform;
        //backgroundColor = 0xFFFFFF;
        debug Log.d("X11Window: Creating window");
        // default size is 500x300 at BASE_DPI (#806)
        if (width == 0)
            width = 500 * SCREEN_DPI / BASE_DPI;
        if (height == 0)
            height = 300 * SCREEN_DPI / BASE_DPI;
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
                // the application may request software rendering with setOpenglEnabled(false) before creating
                // the window (#873)
                if (!openglEnabled)
                    _enableOpengl = false;
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
        setProcessProperties();

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
        // fullscreen and modal states: set when the window is mapped (prepareMapFromWithdrawn, #1189)
        if (flags & WindowFlag.Borderless) {
            MwmHints hints;
            hints.flags = MWM_HINTS_DECORATIONS;
            XChangeProperty(x11display, _win, atom_MOTIF_WM_HINTS, atom_MOTIF_WM_HINTS, 32, PropModeReplace, cast(ubyte*)&hints, hints.sizeof / 4);
        }
        if (flags & WindowFlag.Modal) {
            if (_parent) {
                XSetTransientForHint(x11display, _win, _parent._win);
            } else {
                Log.w("Top-level modal window");
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
            windowIconId = platform.defaultWindowIcon;
    }

    ~this() {
        if (inGCFinalizer()) return; // finalized by the GC: a leak, touch nothing (#975)
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

    /// position of the client area's top-left corner on the screen
    protected Point clientPositionOnScreen() {
        int x, y;
        XWindow child;
        XTranslateCoordinates(x11display, _win, DefaultRootWindow(x11display), 0, 0, &x, &y, &child);
        return Point(x, y);
    }

    /// A position set by the application (restoreWindowState, moveWindow, centering on the parent) is meant
    /// for the client area, but window managers place the frame there: restored windows moved by the frame
    /// size on every restart (#820). For a short time after the window is mapped or moved, adjust the
    /// requested position by the observed error until the client area is where it was wanted.
    protected void startPositionCheck(Point pos) {
        _positionCheckPending = true;
        _positionWanted = _positionRequested = pos;
        _positionCorrections = 0;
        if (_mapped)
            _positionCheckDeadline = MonoTime.currTime + 2.seconds;
    }

    /// ditto; called on configure events of a mapped window
    protected void checkPosition(Point pos) {
        import std.math : abs;
        if (!_positionCheckPending || !_mapped)
            return;
        int dx = pos.x - _positionWanted.x;
        int dy = pos.y - _positionWanted.y;
        if ((dx == 0 && dy == 0) || _positionCorrections >= 3 || MonoTime.currTime > _positionCheckDeadline) {
            _positionCheckPending = false;
            return;
        }
        if (wmStateNotNormal())
            return; // a maximized window isn't moved; the check ends at its deadline
        if (abs(dx) > 100 || abs(dy) > 100)
            return; // not placed yet (some window managers map the window off-screen first)
        if (_positionCorrections > 0 && pos == _positionCorrected)
            return; // an event from before the last correction took effect
        _positionCorrections++;
        _positionCorrected = pos;
        _positionRequested = Point(_positionRequested.x - dx, _positionRequested.y - dy);
        XMoveWindow(x11display, _win, _positionRequested.x, _positionRequested.y);
        XFlush(x11display);
    }

    /// show window
    override void show() {
        Log.d("X11Window.show");
        if (_shown && _withdrawn && _mapRequestSerial != 0) {
            // mapped again since hideWindow() (by a state request or show()), MapNotify not received yet: only
            // raised, as its state and size were set when it was mapped (#1197)
            XRaiseWindow(x11display, _win);
            if (_mainWidget)
                _mainWidget.setFocus();
            XFlush(x11display);
            return;
        }
        bool fromWithdrawn = !_shown || _withdrawn;
        bool wasHidden = _shown && _withdrawn;
        bool ewmh = fromWithdrawn && x11WindowManagerSupportsWmState();
        // a window hidden by hideWindow() is shown normal (states requested while hidden map it at once), also
        // with a window manager that keeps or rewrites maximized or fullscreen when it handles the withdraw (#1197)
        if (wasHidden)
            setInitialWmState(WindowState.normal, ewmh);
        if (fromWithdrawn)
            prepareMapFromWithdrawn(ewmh);
        // maximized or fullscreen before it is mapped (requested before show(), or the Fullscreen flag): sized
        // first, as the window manager keeps that size for a restore, and may restore a mapped maximized window
        // that is resized or moved; the window manager places it (#1197)
        WindowState requested = fromWithdrawn ? wmState() : WindowState.unspecified;
        bool sizeBeforeMap = requested == WindowState.maximized || requested == WindowState.fullscreen;
        _shown = true;
        if (sizeBeforeMap) {
            initOpenGLDuringShow();
            adjustSizeDuringShow();
            // the position for a restore, and the one the window gets if the window manager refuses the state
            if (_mainWidget)
                adjustPositionDuringShow();
            mapDuringShow(wasHidden, ewmh);
            // fitted into the work area when placed if the window manager refuses the state (e.g. for a window
            // that isn't resizable); fitAfterPlacement() does nothing for a maximized or fullscreen window
            _fitAfterPlacement = !_positionCheckPending;
            _fitAfterPlacementDeadline = MonoTime.currTime + 2.seconds;
            _fitAfterPlacementRequested = Rect();
        } else {
            mapDuringShow(wasHidden, ewmh);
            initOpenGLDuringShow();
            adjustSizeDuringShow();
            if (_mainWidget) {
                adjustPositionDuringShow();
                fitWindowIntoWorkArea();
            }
        }
        if (_mainWidget)
            _mainWidget.setFocus();
        XFlush(x11display);
    }

    /// maps and raises the window in show() (and activateWindow() of a hidden window)
    private void mapDuringShow(bool wasHidden, bool ewmh) {
        XMapRaised(x11display, _win);
        // hidden by hideWindow() (also before the first show()): stays withdrawn until the window manager handled
        // the map request, see checkMapRequestHandled; the serial of the last request, the map (XMapRaised sends
        // a raise first)
        if (_withdrawn)
            _mapRequestSerial = x11display.request;
        if (wasHidden)
            sendFlagStates(ewmh);
    }

    /// creates the OpenGL context in show() (also for a window that isn't mapped yet); once: show() can be called
    /// again, e.g. after hideWindow()
    private void initOpenGLDuringShow() {
        static if (ENABLE_OPENGL) {
            if (_enableOpengl && !_glc) {
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
            // the global state (and the glyph cache callback it sets) follows what the window uses (#873)
            setOpenglEnabled(_enableOpengl);
        }
    }

    /// sizes the window to its main widget in show()
    private void adjustSizeDuringShow() {
        if (!_mainWidget)
            return;
        _mainWidget.measure(SIZE_UNSPECIFIED, SIZE_UNSPECIFIED);
        if (flags & WindowFlag.MeasureSize)
            resizeWindow(Point(_mainWidget.measuredWidth, _mainWidget.measuredHeight));
        else
            adjustWindowOrContentSize(_mainWidget.measuredWidth, _mainWidget.measuredHeight);
        updateClientSizeLimits(true);
    }

    override protected void handleWindowStateChange(WindowState newState, Rect newWindowRect = RECT_VALUE_IS_NOT_SET) {
        super.handleWindowStateChange(newState, newWindowRect);
    }

    /// not maximized, minimized or fullscreen now: read from _NET_WM_STATE, as the configure events of a state change
    /// can come before its PropertyNotify (#1190); the rectangle is the normal one (#1200)
    override protected bool isNormalStateNow() {
        // also not while recorded minimized: ICCCM-only window managers don't set _NET_WM_STATE_HIDDEN (#1198)
        return _win != None && _windowState != WindowState.minimized && !wmStateNotNormal();
    }

    /// min and max size hints of a resizable window for the window manager (#455); a window that isn't
    /// resizable keeps its fixed size hints
    override protected void applyClientSizeLimits() {
        if (!_win || !(flags & WindowFlag.Resizable))
            return;
        import std.algorithm : max;
        enum NO_MAX = 32_767;
        XSizeHints sizeHints;
        if (_minClientSize != Point(0, 0)) {
            sizeHints.min_width = max(1, _minClientSize.x);
            sizeHints.min_height = max(1, _minClientSize.y);
            sizeHints.flags |= PMinSize;
        }
        if (_maxClientSize != Point(0, 0)) {
            sizeHints.max_width = _maxClientSize.x ? _maxClientSize.x : NO_MAX;
            sizeHints.max_height = _maxClientSize.y ? _maxClientSize.y : NO_MAX;
            sizeHints.flags |= PMaxSize;
        }
        XSetWMNormalHints(x11display, _win, &sizeHints);
        XFlush(x11display);
    }

    /// the state the window manager set in _NET_WM_STATE: minimized, fullscreen, maximized or normal (also when
    /// the property is not set: no window manager, or none of these states); unspecified if it can't be read;
    /// ignoreHidden: the state without _NET_WM_STATE_HIDDEN (of a mapped window, which isn't iconified)
    protected final WindowState wmState(bool ignoreHidden = false) {
        Atom type;
        int format;
        ubyte* properties;
        c_ulong count, overflow;
        if (XGetWindowProperty(x11display, _win, atom_NET_WM_STATE, 0, int.max / 4, False, XA_ATOM, &type, &format,
                &count, &overflow, &properties) != 0)
            return WindowState.unspecified;
        scope (exit) if (properties) XFree(properties);
        bool minimized, maximizedH, maximizedV, fullscreen;
        if (type == XA_ATOM && format == 32 && properties) {
            foreach (atom; (cast(c_ulong*)properties)[0 .. count]) { // format 32 properties are arrays of C longs
                if (atom == atom_NET_WM_STATE_HIDDEN)
                    minimized = !ignoreHidden;
                else if (atom == atom_NET_WM_STATE_FULLSCREEN)
                    fullscreen = true; // reported since #1190: setWindowState() doesn't record it
                else if (atom == atom_NET_WM_STATE_MAXIMIZED_HORZ)
                    maximizedH = true;
                else if (atom == atom_NET_WM_STATE_MAXIMIZED_VERT)
                    maximizedV = true;
            }
        }
        if (minimized)
            return WindowState.minimized;
        if (fullscreen)
            return WindowState.fullscreen;
        return maximizedH && maximizedV ? WindowState.maximized : WindowState.normal;
    }

    /// true if the window manager set a maximized, fullscreen or minimized state: read from the property, as
    /// the configure events of a state change can come before its PropertyNotify (openbox), and the state
    /// requested isn't recorded (#1190); a refused request leaves the window normal
    private bool wmStateNotNormal() {
        WindowState state = wmState();
        return state != WindowState.normal && state != WindowState.unspecified;
    }

    /// adds the states to (or removes them from) the _NET_WM_STATE property: for a window that isn't mapped yet,
    /// whose state the window manager reads from it when the window is mapped (EWMH) (#1189, #1197)
    private void setWmStateProperty(bool add, const(Atom)[] states...) {
        import std.algorithm : canFind, remove;
        Atom[] list;
        Atom type;
        int format;
        c_ulong count, after;
        ubyte* data;
        if (XGetWindowProperty(x11display, _win, atom_NET_WM_STATE, 0, int.max / 4, False, XA_ATOM, &type, &format,
                &count, &after, &data) == 0 && data) {
            if (type == XA_ATOM && format == 32)
                list = (cast(Atom*)data)[0 .. count].dup; // format 32 properties are arrays of C longs, as Atom
            XFree(data);
        }
        foreach (state; states) {
            if (add && !list.canFind(state))
                list ~= state;
            else if (!add)
                list = list.remove!(a => a == state);
        }
        XChangeProperty(x11display, _win, atom_NET_WM_STATE, XA_ATOM, 32, PropModeReplace, cast(ubyte*)list.ptr,
            cast(int)list.length);
    }

    /// whether the window is iconified when it is mapped from the withdrawn state (ICCCM WM_HINTS initial_state)
    private void setInitialIconic(bool iconic) {
        XWMHints hints;
        if (XWMHints* old = XGetWMHints(x11display, _win)) {
            hints = *old;
            XFree(old);
        }
        hints.flags |= StateHint;
        hints.nitial_state = iconic ? IconicState : NormalState; // sic: the field's name in the x11 bindings
        XSetWMHints(x11display, _win, &hints);
        _initialIconic = iconic;
    }

    /// the state requested for a window that isn't mapped (not shown yet, or hidden by hideWindow()), for the
    /// window manager to apply when it is mapped (#1197): iconified by WM_HINTS (ICCCM), the other states in the
    /// _NET_WM_STATE property only for a window manager that supports it, as wmState() reads it back
    private void setInitialWmState(WindowState state, bool ewmh) {
        setInitialIconic(state == WindowState.minimized);
        if (!ewmh)
            return;
        // the new state replaces an earlier one, also one the window manager left when the window was withdrawn;
        // the Fullscreen flag keeps the window fullscreen; iconified by WM_HINTS only
        bool maximized = state == WindowState.maximized;
        bool fullscreen = state == WindowState.fullscreen || (flags & WindowFlag.Fullscreen);
        setWmStateProperty(maximized, atom_NET_WM_STATE_MAXIMIZED_HORZ, atom_NET_WM_STATE_MAXIMIZED_VERT);
        setWmStateProperty(fullscreen, atom_NET_WM_STATE_FULLSCREEN);
        if (state != WindowState.minimized)
            setWmStateProperty(false, atom_NET_WM_STATE_HIDDEN);
    }

    /// before the window is mapped from the withdrawn state (not shown yet, or hidden by hideWindow()): the
    /// fullscreen and modal states of its flags, which window managers remove when a window is withdrawn (#1189);
    /// an iconic map counts as an iconify request, for a restoreWindow() that comes before it is reported (#1198)
    private void prepareMapFromWithdrawn(bool ewmh) {
        if (ewmh) {
            if (flags & WindowFlag.Fullscreen)
                setWmStateProperty(true, atom_NET_WM_STATE_FULLSCREEN);
            if (flags & WindowFlag.Modal)
                setWmStateProperty(true, atom_NET_WM_STATE_MODAL);
        }
        _shownIconic = _initialIconic;
        if (_initialIconic)
            _iconifyRequested = MonoTime.currTime;
    }

    /// after a window hidden by hideWindow() is mapped again: the fullscreen and modal states of its flags as
    /// messages too, as the window manager may delete the property when it handles the withdraw only after it was
    /// written (#1189)
    private void sendFlagStates(bool ewmh) {
        if (!ewmh)
            return;
        if (flags & WindowFlag.Fullscreen)
            changeWindowState(_NET_WM_STATE_ADD, atom_NET_WM_STATE_FULLSCREEN);
        if (flags & WindowFlag.Modal)
            changeWindowState(_NET_WM_STATE_ADD, atom_NET_WM_STATE_MODAL);
    }

    /// a _NET_WM_STATE change with this serial: a window hidden by hideWindow() and mapped iconified again isn't
    /// withdrawn any more when the window manager reports it iconified (it gets no MapNotify, which ends the
    /// withdrawn state of the others) (#1197). The X server gives an event the serial of the last request from
    /// this client it processed: changes before the map request reached the server have a smaller one and are
    /// still ignored; a late handling of the withdraw can have a later one, so only an iconified state counts.
    private void checkMapRequestHandled(c_ulong serial) {
        if (_withdrawn && _shownIconic && _mapRequestSerial != 0 && serial >= _mapRequestSerial
                && wmState() == WindowState.minimized) {
            _withdrawn = false;
            _mapRequestSerial = 0;
        }
    }

    /// an iconify request was sent in the last 2 seconds and isn't reported yet (#1198)
    private bool iconifyPending() {
        return _iconifyRequested != MonoTime.init && MonoTime.currTime < _iconifyRequested + 2.seconds;
    }

    /// the window manager iconified the window: a restoreWindow() that came while the request was pending maps it
    /// again (#1198); called on _NET_WM_STATE_HIDDEN and on UnmapNotify, as window managers set HIDDEN before they
    /// unmap the window (openbox) and mapping a mapped window does nothing
    private void onIconified() {
        if (_viewable)
            return; // the UnmapNotify comes later
        bool restore = _restoreAfterIconify && iconifyPending();
        _restoreAfterIconify = false;
        _iconifyRequested = MonoTime.init;
        if (restore) {
            XMapWindow(x11display, _win);
            XFlush(x11display);
        }
    }

    /// asks the window manager to activate the window (EWMH _NET_ACTIVE_WINDOW from an application); it also
    /// deiconifies it (#1198)
    private void sendActiveWindow() {
        XEvent ev;
        ev.xclient.type = ClientMessage;
        ev.xclient.window = _win;
        ev.xclient.message_type = XInternAtom(x11display, "_NET_ACTIVE_WINDOW", False);
        ev.xclient.format = 32;
        ev.xclient.data.l[0] = 1; // source indication: application
        ev.xclient.data.l[1] = CurrentTime;
        XSendEvent(x11display, RootWindow(x11display, x11screen), false, SubstructureNotifyMask|SubstructureRedirectMask,
            &ev);
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

    /// true if the window is maximized, minimized or fullscreen: then it isn't centered or fitted into the screen
    protected bool notInNormalState() {
        return _windowState == WindowState.maximized || _windowState == WindowState.minimized
            || _windowState == WindowState.fullscreen || (_flags & WindowFlag.Fullscreen);
    }

    /// the work area of the screen: _NET_WORKAREA (of the first desktop; with several monitors it may span all of
    /// them), else the whole display
    protected Rect workArea() {
        Rect area = Rect(0, 0, DisplayWidth(x11display, x11screen), DisplayHeight(x11display, x11screen));
        Atom workArea = XInternAtom(x11display, "_NET_WORKAREA", True);
        if (workArea != None) {
            Atom type;
            int format;
            c_ulong count, after;
            ubyte* data;
            if (XGetWindowProperty(x11display, DefaultRootWindow(x11display), workArea, 0, 4, False, XA_CARDINAL,
                    &type, &format, &count, &after, &data) == 0 && data) {
                if (format == 32 && count >= 4) {
                    c_long* v = cast(c_long*)data; // format 32 properties are arrays of C longs
                    if (v[2] > 0 && v[3] > 0)
                        area = Rect(cast(int)v[0], cast(int)v[1], cast(int)(v[0] + v[2]), cast(int)(v[1] + v[3]));
                }
                XFree(data);
            }
        }
        return area;
    }

    /// sizes of the frame the window manager adds around the window (_NET_FRAME_EXTENTS: left, top, right,
    /// bottom; 0 when not known yet, e.g. right after the window is mapped)
    protected Rect frameExtents() {
        Rect res = Rect(0, 0, 0, 0);
        Atom extents = XInternAtom(x11display, "_NET_FRAME_EXTENTS", True);
        if (extents == None)
            return res;
        Atom type;
        int format;
        c_ulong count, after;
        ubyte* data;
        if (XGetWindowProperty(x11display, _win, extents, 0, 4, False, XA_CARDINAL,
                &type, &format, &count, &after, &data) == 0 && data) {
            if (format == 32 && count >= 4) {
                c_long* v = cast(c_long*)data; // left, right, top, bottom
                res = Rect(cast(int)v[0], cast(int)v[2], cast(int)v[1], cast(int)v[3]);
            }
            XFree(data);
        }
        return res;
    }

    /// the screen DPI changed from oldDpi to newDpi while the app runs: the window keeps its size in physical terms,
    /// as on Win32, though not beyond the work area (#1162); maximized, minimized and fullscreen windows stay
    void scaleForDpiChange(int oldDpi, int newDpi) {
        import std.algorithm : max;
        scaleClientSizeLimitsToScreenDpi(); // also for maximized windows: for the restored size
        if (notInNormalState() || oldDpi <= 0 || newDpi <= 0)
            return;
        // the size of the last configure event, which may be newer than the last onResize()
        int w = _windowRect.right > 0 ? _windowRect.right : _dx;
        int h = _windowRect.bottom > 0 ? _windowRect.bottom : _dy;
        // setWindowState() keeps a placed window inside the work area, moving it only if needed
        resizeWindow(Point(max(scaleForDpi(w, oldDpi, newDpi), 1), max(scaleForDpi(h, oldDpi, newDpi), 1)));
    }

    /// centers the window on the work area of the screen (#580). Positions are the client area's (see #820),
    /// the frame is added around it.
    override void centerOnScreen() {
        if (notInNormalState())
            return;
        Rect frame = frameExtents();
        Rect rc = windowRect; // left, top, client width, client height
        Point pos = centeredWindowPosition(rc.right + frame.left + frame.right, rc.bottom + frame.top + frame.bottom,
            workArea());
        moveWindow(Point(pos.x + frame.left, pos.y + frame.top));
    }

    /**
        Limits a client rectangle to the work area of the screen (#1114, as #806 for Win32): with its frame, the
        window is shrunk if it is bigger, then moved inside if positionKnown. Without a known position (the window
        manager places the window) only the size is limited.
    */
    protected void fitIntoWorkArea(ref int x, ref int y, ref int w, ref int h, bool positionKnown) {
        import std.algorithm : min;
        Rect frame = frameExtents();
        Rect area = workArea();
        if (area.empty)
            return;
        if (!positionKnown) {
            w = min(w, area.width - frame.left - frame.right);
            h = min(h, area.height - frame.top - frame.bottom);
            return;
        }
        Rect res = fitWindowRectIntoArea(Rect(x - frame.left, y - frame.top, x + w + frame.right, y + h + frame.bottom), area);
        x = res.left + frame.left;
        y = res.top + frame.top;
        w = res.width - frame.left - frame.right;
        h = res.height - frame.top - frame.bottom;
    }

    /// the position of the client area if the window is mapped and on the screen (window managers may map windows
    /// off-screen before placing them, e.g. WSLg): then it can be fitted into the work area with its position
    protected bool placedClientPosition(int w, int h, out Point pos) {
        if (!_mapped)
            return false;
        pos = clientPositionOnScreen();
        return Rect(pos.x, pos.y, pos.x + w, pos.y + h).intersects(workArea());
    }

    /// a shown window is moved into the work area when the window manager places it (#1114): checked on configure
    /// events for a short time after it is mapped, as the size set when shown may come after the first placement
    private bool _fitAfterPlacement;
    /// ditto: until then, set when the window is mapped
    private MonoTime _fitAfterPlacementDeadline;
    /// ditto: the last rectangle requested, not requested again for the configure events before it is reached
    private Rect _fitAfterPlacementRequested;

    /// ditto; called on configure events of a mapped window
    protected void fitAfterPlacement() {
        if (MonoTime.currTime > _fitAfterPlacementDeadline || notInNormalState()) {
            _fitAfterPlacement = false;
            return;
        }
        if (wmStateNotNormal()) {
            _fitAfterPlacement = false;
            return;
        }
        int w = _windowRect.right, h = _windowRect.bottom;
        Point pos;
        if (w <= 0 || h <= 0 || !placedClientPosition(w, h, pos))
            return; // not placed yet
        int x = pos.x, y = pos.y;
        fitIntoWorkArea(x, y, w, h, true);
        if ((x != pos.x || y != pos.y || w != _windowRect.right || h != _windowRect.bottom)
                && Rect(x, y, w, h) != _fitAfterPlacementRequested) {
            _fitAfterPlacementRequested = Rect(x, y, w, h);
            Log.d("Window ", Rect(pos.x, pos.y, _windowRect.right, _windowRect.bottom), " (x, y, width, height) placed by the window manager doesn't fit into the screen work area, changed to ", Rect(x, y, w, h));
            // the size only if it is too big: _windowRect may not have the size requested when shown yet
            bool shrunk = w != _windowRect.right || h != _windowRect.bottom;
            setWindowState(WindowState.unspecified, false, Rect(x, y, shrunk ? w : int.min, shrunk ? h : int.min));
        }
    }

    /// Shrinks the window, if needed, to fit into the work area of the screen, and moves it inside once it is
    /// placed (#1114). Positions set by the application are fitted when they are set (setWindowState).
    protected void fitWindowIntoWorkArea() {
        _fitAfterPlacement = !_positionCheckPending; // a position set by the application is fitted already
        _fitAfterPlacementDeadline = MonoTime.currTime + 2.seconds;
        _fitAfterPlacementRequested = Rect();
        if (notInNormalState() || _windowRect.right <= 0 || _windowRect.bottom <= 0)
            return;
        int x, y, w = _windowRect.right, h = _windowRect.bottom;
        fitIntoWorkArea(x, y, w, h, false);
        if (w != _windowRect.right || h != _windowRect.bottom) {
            Log.d("Window size ", _windowRect.right, "x", _windowRect.bottom, " doesn't fit into the screen work area, changed to ", w, "x", h);
            resizeWindow(Point(w, h));
        }
    }

    override bool setWindowState(WindowState newState, bool activate = false, Rect newWindowRect = RECT_VALUE_IS_NOT_SET) {
        if (_win == None) {
            return false;
        }
        bool result = false;
        bool mappedFromWithdrawn = false; // mapped below: not mapped (raised) again for activate
        bool rejected = false; // the state can't be requested: false, also when activate shows the window
        // maximized, minimized, fullscreen and normal are states a window manager sets: they are requested only when
        // one runs (else false), and not recorded here: the window manager reports them (PropertyNotify of
        // _NET_WM_STATE), when and if they change (#1190)
        WindowState recordedState = newState;
        switch(newState) {
            case WindowState.maximized:
            case WindowState.minimized:
            case WindowState.normal:
            case WindowState.fullscreen:
                // a window not shown yet will be shown normal (show() applies the client size limits to it then)
                recordedState = newState == WindowState.normal && !_mapped ? WindowState.normal
                    : WindowState.unspecified;
                if (newState != WindowState.normal)
                    _restoreAfterIconify = false;
                bool wmRunning = x11WindowManagerRunning();
                bool ewmh = false;
                if (!_shown || _withdrawn) {
                    // a window that isn't mapped can be shown iconified by a window manager, and maximized or
                    // fullscreen by one that supports _NET_WM_STATE
                    ewmh = x11WindowManagerSupportsWmState(wmRunning);
                    bool supported = newState == WindowState.normal || (wmRunning
                        && (newState == WindowState.minimized || ewmh));
                    if (!supported) {
                        rejected = true;
                        break;
                    }
                }
                if (!_shown) {
                    // not mapped yet: window managers ignore _NET_WM_STATE messages for it; it gets the state from
                    // the _NET_WM_STATE property and WM_HINTS when show() maps it (EWMH, ICCCM) (#1197)
                    if (wmRunning)
                        setInitialWmState(newState, ewmh);
                    result = true;
                    break;
                }
                if (_withdrawn) {
                    // hidden by hideWindow(): shown again in the requested state, from the _NET_WM_STATE property
                    // and WM_HINTS; the _NET_WM_STATE messages below too, as the window manager may delete the
                    // property when it handles the withdraw after it was written (#1197)
                    setInitialWmState(newState, ewmh);
                    prepareMapFromWithdrawn(ewmh);
                    if (activate && newState != WindowState.minimized)
                        XMapRaised(x11display, _win);
                    else
                        XMapWindow(x11display, _win);
                    // stays withdrawn until the window manager handled the map request (an iconified window
                    // gets no MapNotify): its events from the withdraw are ignored; the serial of the map request
                    _mapRequestSerial = x11display.request;
                    mappedFromWithdrawn = true;
                    sendFlagStates(ewmh);
                    result = true;
                    if (!wmRunning || newState == WindowState.minimized)
                        break;
                } else if (newState == WindowState.normal
                        && (_windowState == WindowState.minimized || _shownIconic)) {
                    // iconified: mapped again (ICCCM; not a window the window manager unmapped on another desktop:
                    // that could switch desktops); needs no window manager, MapNotify reports the state; also a
                    // window shown iconified, which window managers without _NET_WM_STATE don't report
                    if (_shownIconic) {
                        // also when the window manager hasn't handled its first map yet: then it reads WM_HINTS
                        // later; the map deiconifies it, so a pending iconify ends (no restore when it is reported)
                        setInitialIconic(false);
                        _iconifyRequested = MonoTime.init;
                        _restoreAfterIconify = false;
                    }
                    XMapWindow(x11display, _win);
                    result = true;
                }
                if (!wmRunning) {
                    // nothing to do for a shown normal window
                    result = result || (newState == WindowState.normal && _windowState == WindowState.normal);
                    break;
                }
                result = true;
                if (newState == WindowState.maximized) {
                    changeWindowState(_NET_WM_STATE_ADD, atom_NET_WM_STATE_MAXIMIZED_HORZ,
                        atom_NET_WM_STATE_MAXIMIZED_VERT);
                } else if (newState == WindowState.minimized) {
                    result = XIconifyWindow(x11display, _win, x11screen) != 0;
                    if (result)
                        _iconifyRequested = MonoTime.currTime;
                } else if (newState == WindowState.normal) {
                    changeWindowState(_NET_WM_STATE_REMOVE, atom_NET_WM_STATE_MAXIMIZED_HORZ,
                        atom_NET_WM_STATE_MAXIMIZED_VERT);
                    // the Fullscreen flag keeps the window fullscreen, as before show() (setInitialWmState)
                    if (!(flags & WindowFlag.Fullscreen))
                        changeWindowState(_NET_WM_STATE_REMOVE, atom_NET_WM_STATE_FULLSCREEN);
                    // EWMH window managers may ignore it, but some (openbox) restore an iconified window: also one
                    // whose iconify request they haven't handled yet (#1190)
                    changeWindowState(_NET_WM_STATE_REMOVE, atom_NET_WM_STATE_HIDDEN);
                    // others don't: mapping a window that is still mapped does nothing, so it is mapped again when
                    // the iconify is reported (#1198)
                    bool iconifying = iconifyPending();
                    if (iconifying)
                        _restoreAfterIconify = true;
                    // activation deiconifies in EWMH window managers, also ones that keep iconified windows mapped
                    if (activate && (_windowState == WindowState.minimized || iconifying))
                        sendActiveWindow();
                } else {
                    changeWindowState(_NET_WM_STATE_ADD, atom_NET_WM_STATE_FULLSCREEN);
                }
                break;
            case WindowState.hidden:
                // withdraws an iconified window too (ICCCM: its own unmap is a no-op, the window manager needs the
                // synthetic UnmapNotify), as XUnmapWindow alone left it on the taskbar (#1190)
                XWithdrawWindow(x11display, _win, x11screen);
                _withdrawn = true;
                _mapRequestSerial = 0;
                _shownIconic = false;
                _restoreAfterIconify = false;
                _iconifyRequested = MonoTime.init;
                // a later map from the withdrawn state (show(), activateWindow()) shows it normal (#1197): its
                // _NET_WM_STATE is set then, after the window manager handled the withdraw; a window not shown yet
                // keeps the state requested for it
                if (_shown)
                    setInitialIconic(false);
                result = true;
                break;
            default:
                break;
        }

        // change size and/or position: of a normal window, and of a window not shown yet, whose geometry the window
        // manager keeps for a restore when it maps it maximized or fullscreen (restoreWindowState(), #1197)
        bool rectChanged = false;
        bool rectApplies = newState == WindowState.normal || newState == WindowState.unspecified
            || (!_shown && (newState == WindowState.maximized || newState == WindowState.fullscreen));
        if (newWindowRect != RECT_VALUE_IS_NOT_SET && rectApplies && !(_flags & WindowFlag.Fullscreen)) {
            // keep the window on the screen: e.g. a restored position from a monitor that is gone,
            // or a size measured from content bigger than the screen (#1114)
            bool positionSet = newWindowRect.top != int.min && newWindowRect.left != int.min;
            bool sizeSet = newWindowRect.bottom != int.min && newWindowRect.right != int.min;
            if (positionSet || sizeSet) {
                int x = newWindowRect.left, y = newWindowRect.top;
                int w = sizeSet ? newWindowRect.right : _windowRect.right;
                int h = sizeSet ? newWindowRect.bottom : _windowRect.bottom;
                if (w > 0 && h > 0) {
                    // a size change of a placed window keeps it on the screen too
                    Point pos;
                    bool positionKnown = positionSet;
                    if (!positionSet && placedClientPosition(w, h, pos)) {
                        x = pos.x;
                        y = pos.y;
                        positionKnown = true;
                    }
                    fitIntoWorkArea(x, y, w, h, positionKnown);
                    if (positionSet || (positionKnown && (x != pos.x || y != pos.y))) {
                        newWindowRect.left = x;
                        newWindowRect.top = y;
                    }
                    if (sizeSet || w != _windowRect.right || h != _windowRect.bottom) {
                        newWindowRect.right = w;
                        newWindowRect.bottom = h;
                    }
                }
            }
        }
        if (newWindowRect != RECT_VALUE_IS_NOT_SET && rectApplies) {
            // change position
            if (newWindowRect.top != int.min && newWindowRect.left != int.min) {
                XMoveWindow(x11display, _win, newWindowRect.left, newWindowRect.top);
                startPositionCheck(Point(newWindowRect.left, newWindowRect.top));
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

        // shown and activated also when the state was rejected: then normal, and the result stays false
        bool showNow = false;
        if (activate && !mappedFromWithdrawn) {
            if (!_shown) {
                // shown, as on Win32: show() maps and raises it after creating its OpenGL context and sizing it;
                // at the end, as it can resize the window
                showNow = true;
            } else if (newState != WindowState.minimized || rejected) {
                // not for a minimize request: mapping deiconifies the window
                bool wasHidden = _withdrawn;
                bool ewmh = wasHidden && x11WindowManagerSupportsWmState();
                if (wasHidden) {
                    // a window hidden by hideWindow() is shown normal, as by show()
                    setInitialWmState(WindowState.normal, ewmh);
                    prepareMapFromWithdrawn(ewmh);
                } else if (_shownIconic) {
                    // shown iconified: as restoreWindow(), also when the window manager hasn't handled the first
                    // map yet; the map deiconifies it, so a pending iconify ends
                    setInitialIconic(false);
                    _iconifyRequested = MonoTime.init;
                    _restoreAfterIconify = false;
                } else if (newState != WindowState.normal && iconifyPending()) {
                    // an iconify request is pending, so mapping does nothing yet: as restoreWindow() (#1198), which
                    // did this already for a normal request
                    _restoreAfterIconify = true;
                    sendActiveWindow();
                }
                mapDuringShow(wasHidden, ewmh);
            }
            if (!rejected)
                result = true;
        }
        XFlush(x11display);

        //needed here to make _windowRect and _windowState valid
        //example: change size by resizeWindow() and make some calculations using windowRect
        if (rectChanged) {
            handleWindowStateChange(recordedState,
                Rect(newWindowRect.left == int.min ? _windowRect.left : newWindowRect.left,
                newWindowRect.top == int.min ? _windowRect.top : newWindowRect.top, newWindowRect.right == int.min ? _windowRect.right : newWindowRect.right,
                newWindowRect.bottom == int.min ? _windowRect.bottom : newWindowRect.bottom));
        }
        else
            handleWindowStateChange(recordedState, RECT_VALUE_IS_NOT_SET);

        if (showNow)
            show();
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
    /// window icon sizes set in _NET_WM_ICON (#835): desktops pick one for title bars, taskbars, switchers and docks
    private static immutable int[] ICON_SIZES = [16, 32, 48, 64, 128, 256];

    /// sets _NET_WM_ICON: one entry (width, height, ARGB pixels) per image
    private void setNetWmIcon(ColorDrawBuf[] images) {
        size_t len;
        foreach (img; images)
            len += 2 + cast(size_t)img.width * img.height;
        if (!len)
            return;
        c_long[] propData = new c_long[len];
        size_t pos;
        foreach (img; images) {
            img.invertAndPreMultiplyAlpha();
            propData[pos++] = img.width;
            propData[pos++] = img.height;
            foreach (y; 0 .. img.height) {
                uint * line = img.scanLine(y);
                foreach (x; 0 .. img.width)
                    propData[pos++] = line[x];
            }
        }
        XChangeProperty(x11display, _win, atom_NET_WM_ICON, XA_CARDINAL, 32, PropModeReplace, cast(ubyte*)propData.ptr, cast(int)propData.length);
    }

    /// sets WM_CLIENT_MACHINE and _NET_WM_PID: window managers and tools use them to find the process of a window
    /// (e.g. to kill a hung app); EWMH requires WM_CLIENT_MACHINE with _NET_WM_PID (#1104)
    private void setProcessProperties() {
        version (Posix) {
            import core.sys.posix.unistd : getpid, gethostname;
            char[256] host;
            if (gethostname(host.ptr, host.length) != 0)
                return;
            host[$ - 1] = 0;
            XChangeProperty(x11display, _win, XA_WM_CLIENT_MACHINE, XA_STRING, 8, PropModeReplace,
                cast(ubyte*)host.ptr, cast(int)strlen(host.ptr));
            c_long pid = getpid();
            XChangeProperty(x11display, _win, atom_NET_WM_PID, XA_CARDINAL, 32, PropModeReplace, cast(ubyte*)&pid, 1);
        }
    }

    /// sets window icon: the image scaled to the icon sizes up to its own size (never upscaled), and always 32x32
    override @property void windowIcon(DrawBufRef buf) {
        ColorDrawBuf icon = cast(ColorDrawBuf)buf.get;
        if (!icon) {
            Log.e("Trying to set null icon for window");
            return;
        }
        int srcSize = icon.width > icon.height ? icon.width : icon.height;
        ColorDrawBuf[] images;
        scope(exit) foreach (img; images) destroy(img);
        foreach (size; ICON_SIZES) {
            if (size > srcSize && size != 32)
                continue;
            ColorDrawBuf img = new ColorDrawBuf(size, size);
            img.fill(COLOR_TRANSPARENT);
            img.drawRescaled(Rect(0, 0, size, size), icon, Rect(0, 0, icon.width, icon.height));
            images ~= img;
        }
        setNetWmIcon(images);
    }

    /// sets window icon from a resource: an SVG resource is rendered at all icon sizes, another image is scaled down
    /// to the sizes up to its own size, and to 32x32 (#835)
    override @property void windowIconId(string resourceId) {
        ColorDrawBuf[] images;
        scope(exit) foreach (img; images) destroy(img);
        foreach (size; ICON_SIZES) {
            ColorDrawBuf img = windowIconImage(resourceId, size, size == 32);
            if (img)
                images ~= img;
        }
        if (!images.length) {
            Log.e("Window icon resource not found: ", resourceId);
            return;
        }
        setNetWmIcon(images);
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

    /// convert keyboard modifiers of X11 event state to MouseFlag bits
    ushort convertMouseModifierFlags(uint state) {
        ushort res = 0;
        if (state & ShiftMask)
            res |= MouseFlag.Shift;
        if (state & ControlMask)
            res |= MouseFlag.Control;
        if (state & Mod1Mask)
            res |= MouseFlag.Alt;
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

    short lastx;
    short lasty;

    void processMouseEvent(MouseAction action, uint button, uint state, int x, int y) {
        MouseEvent event = null;
        ushort lastFlags;

        // Take keyboard modifiers from the event state, which the X server reports for the moment
        // of the event, rather than from the last key event: key releases may be missed (#582).
        ushort modifierFlags = convertMouseModifierFlags(state);
        if (action == MouseAction.Move) {
            // the X server reports the real button state: forget presses of buttons released meanwhile (#852)
            if (!(state & Button1Mask) && _lbutton.isDown)
                _lbutton.reset();
            if (!(state & Button2Mask) && _mbutton.isDown)
                _mbutton.reset();
            if (!(state & Button3Mask) && _rbutton.isDown)
                _rbutton.reset();
        }
        if (action == MouseAction.Wheel) {
            // handle wheel
            short wheelDelta = cast(short)y;
            lastFlags = modifierFlags;
            if (wheelDelta)
                event = new MouseEvent(action, MouseButton.None, lastFlags, lastx, lasty, wheelDelta);
        } else {
            MouseButton btn = convertMouseButton(button);
            lastFlags = convertMouseFlags(state, btn, action == MouseAction.ButtonDown) | modifierFlags;
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
            case XK_ISO_Left_Tab: // Shift+Tab
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
        if (flags & Mod1Mask)
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


    bool processKeyEvent(KeyAction action, uint keyCode, uint flagsX11) {
        //debug(DebugSDL)
        Log.d("processKeyEvent ", action, " X11 key=0x", format("%08x", keyCode), " X11 flags=0x", format("%08x", flagsX11));
        keyCode = convertKeyCode(keyCode);
        uint flagsConverted = convertKeyFlags(flagsX11);

        alias KeyCode = dlangui.core.events.KeyCode;

        {
        	uint flags = 0;
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
		    if (action == KeyAction.KeyDown)
		    	flagsConverted |= flags;
		    else
		    	flagsConverted &= ~flags;
		}
        Log.d("processKeyEvent ", action, " converted key=0x", format("%08x", keyCode), " flags=0x", format("%08x", flagsConverted));

        debug(DebugSDL) Log.d("processKeyEvent ", action, " converted key=0x", format("%08x", keyCode), " converted flags=0x", format("%08x", flagsConverted));
        bool res = dispatchKeyEvent(new KeyEvent(action, keyCode, flagsConverted));
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
    // ---------------------------------------------------------------------------------
    // Files dropped from other applications: XDND protocol, https://freedesktop.org/wiki/Specifications/XDND/ (#705)

    /// XDND protocol version supported
    enum XDND_VERSION = 5;
    /// source window of current drag operation
    private XWindow _xdndSource;
    /// XDND protocol version used by source of current drag operation
    private int _xdndVersion;
    /// true if source of current drag operation offers text/uri-list
    private bool _xdndHasUriList;

    /// set handler for files dropped to app window
    override @property DWindow onFilesDropped(void delegate(string[]) handler) {
        super.onFilesDropped(handler);
        // advertise XDND support only when dropped files are handled (like DragAcceptFiles in Win32 backend)
        if (handler) {
            Atom xdndVersion = XDND_VERSION;
            XChangeProperty(x11display, _win, atom_XdndAware, XA_ATOM, 32, PropModeReplace, cast(ubyte*)&xdndVersion, 1);
        } else {
            XDeleteProperty(x11display, _win, atom_XdndAware);
        }
        XFlush(x11display);
        return this;
    }

    /// true if current drag operation can be accepted
    private @property bool xdndAcceptable() {
        return _onFilesDropped !is null && _xdndSource != 0 && _xdndHasUriList;
    }

    private void sendXdndMessage(Atom messageType, long l1, long l2, long l3, long l4) {
        XEvent ev;
        ev.xclient.type = ClientMessage;
        ev.xclient.display = x11display;
        ev.xclient.window = _xdndSource;
        ev.xclient.message_type = messageType;
        ev.xclient.format = 32;
        ev.xclient.data.l[0] = cast(long)_win;
        ev.xclient.data.l[1] = l1;
        ev.xclient.data.l[2] = l2;
        ev.xclient.data.l[3] = l3;
        ev.xclient.data.l[4] = l4;
        XSendEvent(x11display, _xdndSource, False, NoEventMask, &ev);
        XFlush(x11display);
    }

    /// XdndEnter: drag operation entered the window
    void handleXdndEnter(ref XClientMessageEvent msg) {
        _xdndSource = cast(XWindow)msg.data.l[0];
        _xdndVersion = cast(int)((msg.data.l[1] >> 24) & 0xFF);
        _xdndHasUriList = false;
        if (msg.data.l[1] & 1) {
            // more than 3 data types: full list is in XdndTypeList property of source window
            Atom actualType;
            int actualFormat;
            c_ulong count, bytesAfter;
            ubyte* data;
            if (XGetWindowProperty(x11display, _xdndSource, atom_XdndTypeList, 0, 1024, False, XA_ATOM,
                    &actualType, &actualFormat, &count, &bytesAfter, &data) == 0 && data) {
                foreach (t; (cast(Atom*)data)[0 .. count])
                    if (t == atom_TEXT_URI_LIST)
                        _xdndHasUriList = true;
                XFree(data);
            }
        } else {
            foreach (i; 2 .. 5)
                if (cast(Atom)msg.data.l[i] == atom_TEXT_URI_LIST)
                    _xdndHasUriList = true;
        }
        debug(x11) Log.d("XdndEnter: source=", _xdndSource, " version=", _xdndVersion, " hasUriList=", _xdndHasUriList);
    }

    /// XdndPosition: pointer moved over the window, reply whether drop will be accepted
    void handleXdndPosition(ref XClientMessageEvent msg) {
        if (cast(XWindow)msg.data.l[0] != _xdndSource)
            return;
        bool accept = xdndAcceptable;
        // empty rectangle: source should send XdndPosition on any pointer move
        sendXdndMessage(atom_XdndStatus, accept ? 1 : 0, 0, 0, accept ? cast(long)atom_XdndActionCopy : None);
    }

    /// XdndLeave: drag operation left the window or was cancelled
    void handleXdndLeave(ref XClientMessageEvent msg) {
        if (cast(XWindow)msg.data.l[0] != _xdndSource)
            return;
        _xdndSource = 0;
        _xdndHasUriList = false;
    }

    /// XdndDrop: request dropped data; files are delivered when SelectionNotify arrives
    void handleXdndDrop(ref XClientMessageEvent msg) {
        if (cast(XWindow)msg.data.l[0] != _xdndSource)
            return;
        if (!xdndAcceptable) {
            finishXdnd(false);
            return;
        }
        Time time = _xdndVersion >= 1 ? cast(Time)msg.data.l[2] : CurrentTime;
        XConvertSelection(x11display, atom_XdndSelection, atom_TEXT_URI_LIST, atom_DLANGUI_XDND_BUFFER, _win, time);
        XFlush(x11display);
    }

    /// SelectionNotify for XdndSelection: dropped data (text/uri-list) is available
    void handleXdndSelection(ref XSelectionEvent ev) {
        if (!_xdndSource)
            return;
        string[] files;
        if (ev.property != None) {
            Atom actualType;
            int actualFormat;
            c_ulong length, bytesAfter;
            ubyte* data;
            if (XGetWindowProperty(x11display, _win, atom_DLANGUI_XDND_BUFFER, 0, int.max / 4, True, AnyPropertyType,
                    &actualType, &actualFormat, &length, &bytesAfter, &data) == 0 && data) {
                if (actualFormat == 8)
                    files = parseFileUriList((cast(char*)data)[0 .. length]);
                XFree(data);
            }
        }
        debug(x11) Log.d("XDND: dropped files ", files);
        finishXdnd(files.length > 0);
        if (files.length) {
            handleDroppedFiles(files);
            update();
        }
    }

    /// send XdndFinished to source and reset drag operation state
    private void finishXdnd(bool accepted) {
        if (_xdndVersion >= 2)
            sendXdndMessage(atom_XdndFinished, accepted ? 1 : 0, accepted ? cast(long)atom_XdndActionCopy : None, 0, 0);
        _xdndSource = 0;
        _xdndHasUriList = false;
    }

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
        static if(ENABLE_OPENGL)
            _enableOpengl = true;
        import std.file : thisExePath;
        import std.path : baseName;
        _classname = (baseName(thisExePath()) ~ "\0").dup.ptr;
    }

    private X11Window[XWindow] _windowMap;
    private char* _classname;

    ~this() {
        if (inGCFinalizer()) return; // finalized by the GC: a leak, touch nothing (#975)
        // Destroy windows the application left open while the X display is still open.
        // Otherwise GC finalizers destroy them after XCloseDisplay, and X11Window's destructor
        // calls XFreeGC/XDestroyWindow on the freed Display (heap corruption, crash on exit).
        foreach (w; _windowMap.values)
            destroy(w);
        _windowMap = null;
    }

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
        setDefaultLanguageAndThemeIfNecessary();
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
                    // synthetic events from the window manager carry screen coordinates; real ones,
                    // coordinates relative to the parent, which is the frame for a reparented window
                    Point pos = event.xconfigure.send_event ? Point(event.xconfigure.x, event.xconfigure.y)
                        : w.clientPositionOnScreen();
                    w.handleWindowStateChange(WindowState.unspecified, Rect(pos.x, pos.y, event.xconfigure.width, event.xconfigure.height));
                    // the actual position: window managers can send synthetic events for positions not reached yet
                    if (w._positionCheckPending && w._mapped)
                        w.checkPosition(w.clientPositionOnScreen());
                    if (w._fitAfterPlacement && w._mapped)
                        w.fitAfterPlacement();
                } else {
                    Log.e("ConfigureNotify: Window not found");
                }
                break;
            case PropertyNotify:
                if (event.xproperty.window == RootWindow(x11display, 0)) {
                    // desktop settings such as Xft.dpi (#1162): applied by pumpEvents(), not in the middle of
                    // waiting for the clipboard
                    if (event.xproperty.atom == XA_RESOURCE_MANAGER)
                        _resourcesChanged = true;
                    break;
                }
                if (event.xproperty.atom == atom_NET_WM_STATE && event.xproperty.state == PropertyDelete) {
                    // the window manager removed all states (#1190)
                    X11Window w = findWindow(event.xproperty.window);
                    if (w && !w._withdrawn && w._viewable)
                        w.handleWindowStateChange(WindowState.normal);
                } else if (event.xproperty.atom == atom_NET_WM_STATE && event.xproperty.state == PropertyNewValue) {
                    X11Window w = findWindow(event.xproperty.window);
                    if (w)
                        w.checkMapRequestHandled(event.xproperty.serial);
                    // an unmapped window becomes only minimized: an iconified window can be unmapped (hidden)
                    // before _NET_WM_STATE_HIDDEN is set
                    if (w && !w._withdrawn) {
                        WindowState state = w.wmState();
                        if (state == WindowState.minimized)
                            w.onIconified();
                        if (w._viewable || state == WindowState.minimized)
                            w.handleWindowStateChange(state);
                    }
                }
                break;
            case MapNotify:
                X11Window w = findWindow(event.xmap.window);
                if (w) {
                    if (!w._mapped) {
                        w._mapped = true;
                        if (w._positionCheckPending)
                            w._positionCheckDeadline = MonoTime.currTime + 2.seconds;
                        w._fitAfterPlacementDeadline = MonoTime.currTime + 2.seconds;
                    }
                    w._withdrawn = false;
                    w._mapRequestSerial = 0;
                    w._viewable = true;
                    w._shownIconic = false;
                    // normal without a window manager; a window restored from the taskbar can be maximized (#1190);
                    // a mapped window isn't iconified, though the window manager may remove HIDDEN only after mapping
                    WindowState state = w.wmState(true);
                    if (state == WindowState.unspecified)
                        state = WindowState.normal;
                    w.handleWindowStateChange(state);
                }
                break;
            case UnmapNotify:
                X11Window w = findWindow(event.xunmap.window);
                if (w) {
                    w._viewable = false;
                    // unmapped by the window manager while an iconify request is pending: iconified (also by
                    // window managers that set _NET_WM_STATE_HIDDEN only after unmapping, or never: ICCCM only),
                    // so restoreWindow() maps it again (#1198)
                    if (!w._withdrawn && w.iconifyPending()) {
                        w.handleWindowStateChange(WindowState.minimized);
                        w.onIconified();
                    } else if (w.windowState != WindowState.minimized) {
                        // an iconified window is unmapped too: it stays minimized (_NET_WM_STATE_HIDDEN, #1190)
                        w.handleWindowStateChange(WindowState.hidden);
                    }
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
                        w.processMouseEvent(MouseAction.Wheel, 0, event.xbutton.state, 0, event.xbutton.button == 4 ? 1 : -1);
                    } else if (event.xbutton.button == 6 || event.xbutton.button == 7) {
                        // horizontal wheel (#1053): Shift + wheel, as scroll widgets expect; left +1, right -1
                        w.processMouseEvent(MouseAction.Wheel, 0, event.xbutton.state | ShiftMask, 0, event.xbutton.button == 6 ? 1 : -1);
                    } else {
                        w.processMouseEvent(MouseAction.ButtonDown, event.xbutton.button, event.xbutton.state, event.xbutton.x, event.xbutton.y);
                    }
                } else {
                    Log.e("Window not found");
                }
                break;
            case ButtonRelease:
                Log.d("X11: ButtonRelease event");
                if (event.xbutton.button == 6 || event.xbutton.button == 7)
                    break; // horizontal wheel: handled on press (#1053)
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
                    // the button state of a crossing event (xmotion.state is another field of this event type);
                    // it also resyncs the buttons: a release over another window may have been missed (#852)
                    w.processMouseEvent(MouseAction.Move, 0, event.xcrossing.state, event.xcrossing.x, event.xcrossing.y);
                } else {
                    Log.e("Window not found");
                }
                break;
            case LeaveNotify:
                Log.d("X11: LeaveNotify event");
                X11Window w = findWindow(event.xcrossing.window);
                if (w) {
                    // While a mouse button is pressed, the X server keeps sending pointer events to this window
                    // (implicit grab) until the button is released; a Leave would cancel dragging (#635).
                    if (event.xcrossing.state & (Button1Mask | Button2Mask | Button3Mask))
                        break;
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
                    if (event.xselection.selection == atom_XdndSelection)
                        w.handleXdndSelection(event.xselection);
                    else
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
                    } else if (event.xclient.message_type == atom_XdndEnter) {
                        w.handleXdndEnter(event.xclient);
                    } else if (event.xclient.message_type == atom_XdndPosition) {
                        w.handleXdndPosition(event.xclient);
                    } else if (event.xclient.message_type == atom_XdndLeave) {
                        w.handleXdndLeave(event.xclient);
                    } else if (event.xclient.message_type == atom_XdndDrop) {
                        w.handleXdndDrop(event.xclient);
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
        _pumpEventsDepth++;
        scope (exit) _pumpEventsDepth--;
        XFlush(x11display);
        // Note:  only events we set the mask for are detected!
        while(numberOfPendingEvents())
        {
            if (allWindowsClosed())
                break;
            XEvent event;        /* the XEvent declaration !!! */
            XNextEvent(x11display, &event);
            processXEvent(event);
            applyResourcesChange();
        }
        // also when a change came in the nested pumpEvents() of getClipboardText() and no event follows
        applyResourcesChange();
    }
    /// desktop settings changed: applied in the outermost pumpEvents() only, and not during getClipboardText() (also
    /// when it is called outside the message loop): not while code that pastes is running (#1162, #1187)
    private void applyResourcesChange() {
        if (_resourcesChanged && _pumpEventsDepth == 1 && !_readingClipboard && !allWindowsClosed()) {
            _resourcesChanged = false;
            x11OnResourcesChanged();
        }
    }
    /// nesting of pumpEvents(): getClipboardText() calls it while waiting
    private int _pumpEventsDepth;
    /// RESOURCE_MANAGER (desktop settings such as Xft.dpi) changed, not handled yet
    private bool _resourcesChanged;

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
    /// getClipboardText() is running, until it has read the selection: desktop settings changes wait (#1187)
    private bool _readingClipboard;
    /// retrieves text from clipboard (when mouseBuffer == true, use mouse selection clipboard - under linux)
    override dstring getClipboardText(bool mouseBuffer = false) {
        bool wasReading = _readingClipboard;
        _readingClipboard = true;
        scope (exit) _readingClipboard = wasReading;
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

    /// calls dg for each window (Platform.forEachWindow: theme changes reach all windows, #1173)
    override protected void forEachWindow(scope void delegate(DWindow) dg) {
        foreach(w; _windowMap)
            dg(w);
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
        if (inGCFinalizer()) return; // finalized by the GC: a leak, touch nothing (#975)
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


/// true if a window manager runs (#1190): it selects SubstructureRedirectMask on the root window (only one client
/// can); window managers without EWMH (ICCCM only, e.g. twm) are found too
private bool x11WindowManagerRunning() {
    XWindowAttributes attributes;
    return XGetWindowAttributes(x11display, RootWindow(x11display, x11screen), &attributes) != 0
        && (attributes.all_event_masks & SubstructureRedirectMask) != 0;
}

/// true if a window manager that supports _NET_WM_STATE runs (EWMH: listed in _NET_SUPPORTED of the root window):
/// it reads the property when a window is mapped, and updates it (#1197); ICCCM-only window managers (twm) don't;
/// wmRunning: x11WindowManagerRunning(), if the caller has it
private bool x11WindowManagerSupportsWmState(bool wmRunning = x11WindowManagerRunning()) {
    import std.algorithm : canFind;
    if (!wmRunning)
        return false;
    Atom supported = XInternAtom(x11display, "_NET_SUPPORTED", True);
    if (supported == None)
        return false;
    Atom type;
    int format;
    c_ulong count, after;
    ubyte* data;
    if (XGetWindowProperty(x11display, RootWindow(x11display, x11screen), supported, 0, int.max / 4, False, XA_ATOM,
            &type, &format, &count, &after, &data) != 0 || !data)
        return false;
    scope (exit) XFree(data);
    // format 32 properties are arrays of C longs, as Atom
    return type == XA_ATOM && format == 32 && (cast(Atom*)data)[0 .. count].canFind(atom_NET_WM_STATE);
}

/// the X resource manager string (desktop settings such as Xft.dpi) from the RESOURCE_MANAGER property of the root
/// window of screen 0, as Xlib reads it (other screens don't have it), null if it is not set; read again each time,
/// while XResourceManagerString() keeps the value from when the display was opened (#1162)
private const(char)[] x11ResourceManagerString() {
    Atom type;
    int format;
    c_ulong length, remaining;
    ubyte* data;
    if (XGetWindowProperty(x11display, RootWindow(x11display, 0), XA_RESOURCE_MANAGER, 0, int.max / 4, False,
            XA_STRING, &type, &format, &length, &remaining, &data) != 0 || !data)
        return null;
    scope (exit) XFree(data);
    if (type != XA_STRING || format != 8)
        return null;
    return (cast(char*)data)[0 .. length].dup;
}

/// the desktop settings changed while the app runs: a new Xft.dpi rescales the UI (#1162); without Xft.dpi, the
/// default DPI, as at startup
private void x11OnResourcesChanged() {
    import dlangui.platforms.common.xftdpi : parseXftDpi;
    int xftDpi = parseXftDpi(x11ResourceManagerString());
    // the property is rewritten for other settings too (cursor theme, xrdb -merge): only a new Xft.dpi counts, so
    // that a SCREEN_DPI set otherwise stays (#1187)
    if (xftDpi == x11XftDpi)
        return;
    x11XftDpi = xftDpi;
    Log.d("X11: RESOURCE_MANAGER changed, Xft.dpi=", xftDpi);
    int oldDpi = SCREEN_DPI;
    if (!Platform.instance.setSystemScreenDpi(xftDpi ? xftDpi : BASE_DPI))
        return;
    if (auto x11platform = cast(X11Platform)Platform.instance) {
        // a copy: resizing runs layout and application code, which may create or close windows
        foreach (w; x11platform._windowMap.values)
            if (x11platform._windowMap.get(w._win, null) is w)
                w.scaleForDpiChange(oldDpi, SCREEN_DPI);
    }
}

/// the last Xft.dpi read from RESOURCE_MANAGER, 0 if not set (#1187)
private int x11XftDpi;

/// set screen DPI from Xft.dpi desktop setting, if available (#706); otherwise keep default DPI
private void x11UpdateScreenDpi() {
    import dlangui.platforms.common.xftdpi : parseXftDpi;
    int xftDpi = parseXftDpi(x11ResourceManagerString());
    x11XftDpi = xftDpi;
    if (xftDpi) {
        SCREEN_DPI = xftDpi;
        Log.i("X11: screen DPI from Xft.dpi=", xftDpi, ", using ", systemScreenDPI);
    } else {
        Log.i("X11: Xft.dpi is not set, using default screen DPI ", systemScreenDPI);
    }
    if (overrideScreenDPI != 0)
        Log.i("X11: screen DPI is overridden: ", overrideScreenDPI);
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
    // PropertyNotify for the root window of screen 0, where RESOURCE_MANAGER is: desktop settings such as Xft.dpi
    // changed (#1162); before reading them, so that no change is missed. It comes for every root property change
    // (window managers change some on each focus change; the clipboard buffer of setClipboardText() is there too),
    // the others are skipped in processXEvent()
    XSelectInput(x11display, RootWindow(x11display, 0), PropertyChangeMask);
    x11UpdateScreenDpi();
    x11display2 = XOpenDisplay(null);
    if (!x11display2) {
        Log.e("Cannot open secondary connection for X11 display");
        return 1;
    }

    x11screen = DefaultScreen(x11display);

    static if (ENABLE_OPENGL) {
        try {
            import bindbc.opengl : GLVersion = GLSupport;
            GLVersion support = loadOpenGL();
            if(support == GLVersion.badLibrary)
            {
                _enableOpengl = false;
                Log.e("Error loading OpenGL library");
            }
            else
            {
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
            }
        } catch (Exception e) {
            Log.e("Cannot load OpenGL library", e);
        }
    }


    setupX11Atoms();

    x11cursors[CursorType.None] = XCreateFontCursor(x11display, XC_arrow);
    x11cursors[CursorType.NotSet] = XCreateFontCursor(x11display, XC_arrow);
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
    Platform.instance.uiTheme = "theme_default";

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
