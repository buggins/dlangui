// Written in the D programming language.

/**
This module contains common Plaform definitions.

Platform is abstraction layer for application.


Synopsis:

----
import dlangui.platforms.common.platform;

----

Copyright: Vadim Lopatin, 2014
License:   Boost License 1.0
Authors:   Vadim Lopatin, coolreader.org@gmail.com
*/
module dlangui.platforms.common.platform;

public import dlangui.core.config;
public import dlangui.core.events;
import dlangui.core.collections;
import dlangui.widgets.widget;
import dlangui.widgets.popup;
import dlangui.widgets.scrollbar;
import dlangui.graphics.drawbuf;
import dlangui.core.stdaction;
import dlangui.core.asyncsocket;
import dlangui.graphics.iconprovider;

static if (ENABLE_OPENGL) {
    private import dlangui.graphics.gldrawbuf;
}
private import std.algorithm;
private import core.sync.mutex;
private import std.string;

/// entry point - declare such function to use as main for dlangui app
extern(C) int UIAppMain(string[] args);

/// type of UIAppMain
alias UIAppMainFunction = extern(C) int function(string[] args);

/**
The application's UIAppMain, set by `mixin APP_ENTRY_POINT` before it starts the backend. The backends call it through
this pointer (`callUIAppMain`), so the library doesn't refer to the UIAppMain symbol itself: a test build that leaves
out the application's module with UIAppMain still links, e.g. `dub test --coverage` with DMD, which links the backend
modules (#270). An application with its own `main` that calls `DLANGUImain` sets it first: `uiAppMainFunction = &UIAppMain;`
*/
__gshared UIAppMainFunction uiAppMainFunction;

/// calls the application's UIAppMain through `uiAppMainFunction`; logs an error and returns 1 if it isn't set
int callUIAppMain(string[] args) {
    if (uiAppMainFunction is null) {
        Log.e("UIAppMain is not set: use mixin APP_ENTRY_POINT, or set uiAppMainFunction = &UIAppMain before starting the backend");
        return 1;
    }
    return uiAppMainFunction(args);
}

unittest {
    static extern(C) int testMain(string[] args) { return cast(int)args.length + 40; }
    UIAppMainFunction saved = uiAppMainFunction;
    scope (exit)
        uiAppMainFunction = saved;
    uiAppMainFunction = null;
    assert(callUIAppMain(["a"]) == 1);
    uiAppMainFunction = &testMain;
    assert(callUIAppMain(["a", "b"]) == 42);
}


// specify debug=DebugMouseEvents for logging mouse handling
// specify debug=DebugRedraw for logging drawing and layouts handling
// specify debug=DebugKeys for logging of key events

/// window creation flags
enum WindowFlag : uint {
    /// window can be resized
    Resizable = 1,
    /// window should be shown in fullscreen mode
    Fullscreen = 2,
    /// modal window - grabs input focus
    Modal = 4,
    /// measure window size on window.show() - helps if you want scrollWindow but on show() you want to set window to mainWidget measured size
    MeasureSize = 8,
    /// window without decorations
    Borderless = 16,
    /// expand window size if main widget minimal size is greater than size defined in window constructor
    ExpandSize = 32,
}

/// Window states
enum WindowState : int {
    /// state is unknown (not supported by platform?), as well for using in setWindowState when only want to activate window or change its size/position
    unspecified,
    /// normal state
    normal,
    /// window is maximized
    maximized,
    /// window is maximized
    minimized,
    /// fullscreen mode (supported not on all platforms)
    fullscreen,
    /// application is paused (e.g. on Android)
    paused,
    /// window is hidden
    hidden,
    /// closed
    closed,
}

///  Flags to set start window position on show
enum ShowPosition {
    /// do nothing just show
    dontCare,
    /// window will be centered on parent window
    parentWindowCenter,
    /// window will be centered on the screen: the work area (without taskbars and panels) of its monitor (#580)
    screenCenter
}

/**
 * Top left corner of a window of the given size centered in an area of the screen (#580). A window bigger
 * than the area starts at the area's top left corner, so its title bar stays visible.
 */
Point centeredWindowPosition(int width, int height, Rect area) {
    import std.algorithm : max;
    return Point(area.left + max(0, (area.width - width) / 2), area.top + max(0, (area.height - height) / 2));
}

unittest {
    Rect work = Rect(0, 0, 1920, 1152); // 1920x1200 screen, 48 px taskbar at the bottom
    assert(centeredWindowPosition(800, 600, work) == Point(560, 276));
    // second monitor on the right, taskbar on the left
    assert(centeredWindowPosition(800, 600, Rect(1980, 0, 3840, 1200)) == Point(2510, 300));
    // bigger than the area in one direction: starts at its edge there
    assert(centeredWindowPosition(2000, 600, work) == Point(0, 276));
}

/**
 * Client size limits of a window from the min and max size constraints of its main widget, in pixels (#455):
 * 0 in a limit means no limit. A missing max size (SIZE_UNSPECIFIED) is no limit; a max size smaller than
 * the min size becomes the min size.
 */
void clientSizeLimits(int minWidth, int minHeight, int maxWidth, int maxHeight, out Point minSize, out Point maxSize) {
    import std.algorithm : max;
    // values with size flags (SIZE_UNSPECIFIED, FILL_PARENT, WRAP_CONTENT, percents) aren't sizes
    static int limit(int value) { return value > 0 && value < SIZE_IN_PERCENTS_FLAG ? value : 0; }
    minSize = Point(limit(minWidth), limit(minHeight));
    maxSize = Point(limit(maxWidth), limit(maxHeight));
    if (maxSize.x)
        maxSize.x = max(maxSize.x, minSize.x);
    if (maxSize.y)
        maxSize.y = max(maxSize.y, minSize.y);
}

/// A client size kept within limits from clientSizeLimits (0: no limit) (#455)
Point clientSizeWithinLimits(Point size, Point minSize, Point maxSize) {
    import std.algorithm : min, max;
    if (maxSize.x)
        size.x = min(size.x, maxSize.x);
    if (maxSize.y)
        size.y = min(size.y, maxSize.y);
    return Point(max(size.x, minSize.x), max(size.y, minSize.y));
}

unittest {
    Point mn, mx;
    // no constraints: widget defaults (0 and SIZE_UNSPECIFIED)
    clientSizeLimits(0, 0, SIZE_UNSPECIFIED, SIZE_UNSPECIFIED, mn, mx);
    assert(mn == Point(0, 0) && mx == Point(0, 0));
    clientSizeLimits(600, 400, SIZE_UNSPECIFIED, 900, mn, mx);
    assert(mn == Point(600, 400) && mx == Point(0, 900));
    // max smaller than min: the min size wins
    clientSizeLimits(600, 400, 500, 300, mn, mx);
    assert(mn == Point(600, 400) && mx == Point(600, 400));
    // sizes that aren't real sizes are no limit
    clientSizeLimits(FILL_PARENT, -1, WRAP_CONTENT, 0, mn, mx);
    assert(mn == Point(0, 0) && mx == Point(0, 0));

    Point size = Point(500, 1000);
    assert(clientSizeWithinLimits(size, Point(0, 0), Point(0, 0)) == size);
    assert(clientSizeWithinLimits(size, Point(600, 400), Point(0, 900)) == Point(600, 900));
    assert(clientSizeWithinLimits(size, Point(0, 0), Point(400, 0)) == Point(400, 1000));
}

/**
 * Limits an outer window rectangle to an area of the screen, e.g. the work area of a monitor (the screen
 * without the taskbar): shrinks the rectangle if it is bigger than the area, then moves it inside (#806).
 * An empty area leaves the rectangle as it is.
 */
Rect fitWindowRectIntoArea(Rect rc, Rect area) {
    import std.algorithm : min, max;
    if (area.empty)
        return rc;
    int w = min(rc.width, area.width);
    int h = min(rc.height, area.height);
    int x = max(area.left, min(rc.left, area.right - w));
    int y = max(area.top, min(rc.top, area.bottom - h));
    return Rect(x, y, x + w, y + h);
}

unittest {
    Rect work = Rect(0, 0, 1920, 1152); // 1920x1200 screen, 48 px taskbar at the bottom
    // fits: unchanged
    assert(fitWindowRectIntoArea(Rect(100, 50, 1100, 850), work) == Rect(100, 50, 1100, 850));
    // too tall: shrunk to the area height and moved up
    assert(fitWindowRectIntoArea(Rect(26, 26, 1826, 1486), work) == Rect(26, 0, 1826, 1152));
    // sticks out at the right and the bottom: moved inside, size kept
    assert(fitWindowRectIntoArea(Rect(1500, 1000, 2100, 1400), work) == Rect(1320, 752, 1920, 1152));
    // left of the area (e.g. a restored position from a monitor that is gone): moved inside
    assert(fitWindowRectIntoArea(Rect(-2000, 100, -1400, 500), work) == Rect(0, 100, 600, 500));
    // area not at the origin (second monitor)
    assert(fitWindowRectIntoArea(Rect(1900, -50, 2500, 350), Rect(1920, 0, 3840, 1040)) == Rect(1920, 0, 2520, 400));
    // bigger than the area in both directions: becomes the area
    assert(fitWindowRectIntoArea(Rect(-10, -10, 5000, 5000), work) == work);
    // empty area: unchanged
    assert(fitWindowRectIntoArea(Rect(-10, -10, 5000, 5000), Rect()) == Rect(-10, -10, 5000, 5000));
}

/**
 * Index of the area (e.g. a monitor's work area) that the larger part of a window rectangle is on, for
 * fitWindowRectIntoArea (#1114): -1 if the rectangle is on none of them (e.g. a position restored from a monitor
 * that is gone). Empty areas are skipped.
 */
ptrdiff_t areaIndexForRect(Rect rc, const(Rect)[] areas) {
    ptrdiff_t res = -1;
    long bestOverlap = 0;
    foreach (i, area; areas) {
        if (area.empty)
            continue;
        Rect overlap = rc;
        if (!overlap.intersect(area))
            continue;
        long size = cast(long)overlap.width * overlap.height;
        if (size > bestOverlap) {
            bestOverlap = size;
            res = i;
        }
    }
    return res;
}

unittest {
    // two monitors side by side, the second one smaller; work areas without taskbars
    const Rect[] areas = [Rect(0, 0, 1920, 1152), Rect(1920, 0, 3200, 984)];
    assert(areaIndexForRect(Rect(100, 100, 900, 700), areas) == 0);
    assert(areaIndexForRect(Rect(2000, 100, 2800, 700), areas) == 1);
    // across both: the one with the larger part
    assert(areaIndexForRect(Rect(1500, 100, 2300, 700), areas) == 0);
    assert(areaIndexForRect(Rect(1800, 100, 2600, 700), areas) == 1);
    // on none
    assert(areaIndexForRect(Rect(-2000, 100, -1200, 700), areas) == -1);
    assert(areaIndexForRect(Rect(100, 100, 900, 700), []) == -1);
    // empty areas (e.g. a display whose bounds can't be read) are skipped
    assert(areaIndexForRect(Rect(100, 100, 900, 700), [Rect(), Rect(0, 0, 1920, 1152)]) == 1);
}

/// Dialog display modes - used to configure dialogs should be showed as a popup or window
enum DialogDisplayMode : ulong {
    /// show all types of dialogs in windows
    allTypesOfDialogsInWindow = 0,
    /// show file dialogs in popups
    fileDialogInPopup = 1,
    /// show message boxes in popups
    messageBoxInPopup = 2,
    /// show input boxes in popups
    inputBoxInPopup = 4,
    /// show settings dialogs in popups
    settingsDialogInPopup = 8,
    /// show user dialogs in popups - flag for user dialogs
    userDialogInPopup = 16,
    /// show all types of dialogs in popups
    allTypesOfDialogsInPopup = fileDialogInPopup | messageBoxInPopup | inputBoxInPopup | settingsDialogInPopup | userDialogInPopup
}

/// Sets what's should be done when window content is too big
enum WindowOrContentResizeMode {
    /// widgets are shrink to fit in window
    shrinkWidgets,
    /// resize window when window is too small
    resizeWindow,
    /// add scrollbars to window
    scrollWindow
}

/// Window state signal listener
interface OnWindowStateHandler {
    /// signal listener - called when state of window is changed
    bool onWindowStateChange(Window window, WindowState winState, Rect rect);
}

/// Window activate/deactivate signal listener
interface OnWindowActivityHandler {
    /// signal listener - called when window activity is changed
    bool onWindowActivityChange(Window window, bool isWindowActive);
}

/// Window main widget changing signal listener
interface OnMainWidgetChange
{
    void onMainWidgetChange(Window window, Widget previous, Widget newWidget);
}

/// protected event list
/// references to posted messages can be stored here at least to keep live reference and avoid GC
/// as well, on some platforms it's easy to send id to message queue, but not pointer
class EventList {
    protected Mutex _mutex;
    protected Collection!CustomEvent _events;
    this() {
        _mutex = new Mutex();
    }
    ~this() {
        if (inGCFinalizer()) return; // finalized by the GC: a leak, touch nothing (#975)
        destroy(_mutex);
        _mutex = null;
    }
    /// puts event into queue, returns event's unique id
    long put(CustomEvent event) {
        _mutex.lock();
        scope(exit) _mutex.unlock();
        _events.pushBack(event);
        return event.uniqueId;
    }
    /// return next event
    CustomEvent get() {
        _mutex.lock();
        scope(exit) _mutex.unlock();
        return _events.popFront();
    }
    /// return event by unique id
    CustomEvent get(uint uniqueId) {
        _mutex.lock();
        scope(exit) _mutex.unlock();
        for (int i = 0; i < _events.length; i++) {
            if (_events[i].uniqueId == uniqueId) {
                return _events.remove(i);
            }
        }
        // not found
        return null;
    }
}

class TimerInfo {
    static __gshared ulong nextId;

    this(Widget targetWidget, long intervalMillis) {
        _id = ++nextId;
        assert(intervalMillis >= 0 && intervalMillis < 7*24*60*60*1000L);
        _targetWidget = targetWidget;
        _interval = intervalMillis;
        _nextTimestamp = currentTimeMillis + _interval;
    }
    /// cancel timer
    void cancel() {
        _targetWidget = null;
    }
    /// cancel timer
    void notify() {
        if (_targetWidget) {
            _nextTimestamp = currentTimeMillis + _interval;
            if (!_targetWidget.onTimer(_id)) {
                _targetWidget = null;
            }
        }
    }
    /// unique Id of timer
    @property ulong id() { return _id; }
    /// timer interval, milliseconds
    @property long interval() { return _interval; }
    /// next timestamp to invoke timer at, as per currentTimeMillis()
    @property long nextTimestamp() { return _nextTimestamp; }
    /// widget to route timer event to
    @property Widget targetWidget() { return _targetWidget; }
    /// return true if timer is not yet cancelled
    @property bool valid() { return _targetWidget !is null; }

    protected ulong _id;
    protected long _interval;
    protected long _nextTimestamp;
    protected Widget _targetWidget;

    override int opCmp(Object obj) {
        TimerInfo b = cast(TimerInfo)obj;
        if (!b)
            return false;
        if (valid && !b.valid)
            return -1;
        if (!valid && b.valid)
            return 1;
        if (!valid && !b.valid)
            return 0;
        if (_nextTimestamp < b._nextTimestamp)
            return -1;
        if (_nextTimestamp > b._nextTimestamp)
            return 1;
        return 0;
    }
}


/**
 * Window abstraction layer. Widgets can be shown only inside window.
 *
 */
class Window : CustomEventTarget {
    import dlangui.core.settings;

    protected int _dx;
    protected int _dy;
    protected uint _keyboardModifiers;
    protected uint _backgroundColor;
    /// theme color id of the background, looked up again on a theme change; null for a color set with
    /// backgroundColor (#1140)
    protected string _backgroundColorId = STYLE_COLOR_WINDOW_BACKGROUND;
    /// background color for a theme without _backgroundColorId
    protected uint _backgroundColorDefault = DEFAULT_WINDOW_BACKGROUND_COLOR;
    protected Widget _mainWidget;
    protected EventList _eventList;
    protected uint _flags;
    /// minimal good looking content width
    protected int _minContentWidth;
    /// minimal good looking content height
    protected int _minContentHeight;

    // current content width calculated using _windowOrContentResizeMode flag, usually used in measure()
    protected int _currentContentWidth;
    // current content height calculated using _windowOrContentResizeMode flag, usually used in measure()
    protected int _currentContentHeight;

    @property uint flags() { return _flags; }
    @property uint backgroundColor() const { return _backgroundColor; }
    /// sets a fixed background color: a theme change keeps it
    @property void backgroundColor(uint color) {
        _backgroundColor = color;
        _backgroundColorId = null;
    }
    /// theme color id of the background (default: STYLE_COLOR_WINDOW_BACKGROUND); null after backgroundColor was set
    @property string backgroundColorId() const { return _backgroundColorId; }
    /// sets the background to the theme color `id` (defaultColor if the theme has none), looked up again when
    /// the theme changes (#1140); a null id sets the fixed color defaultColor
    void setBackgroundColorId(string id, uint defaultColor) {
        _backgroundColorId = id;
        _backgroundColorDefault = defaultColor;
        if (id is null)
            _backgroundColor = defaultColor;
        updateBackgroundColor();
    }
    /// the background color from the current theme, if it is a theme color
    private void updateBackgroundColor() {
        if (_backgroundColorId is null)
            return;
        _backgroundColor = currentTheme ? currentTheme.customColor(_backgroundColorId, _backgroundColorDefault)
            : _backgroundColorDefault;
    }
    @property int width() const { return _dx; }
    @property int height() const { return _dy; }
    @property uint keyboardModifiers() const { return _keyboardModifiers; }
    @property inout(Widget) mainWidget() inout { return _mainWidget; }
    @property void mainWidget(Widget widget)
    {
        mainWidgetChange(this, _mainWidget, widget);
        if (_mainWidget !is null)
        {
            _mainWidget.window = null;
            destroy(_mainWidget);
        }
        _mainWidget = widget;
        if (_mainWidget !is null)
            _mainWidget.window = this;
    }

    Signal!OnMainWidgetChange mainWidgetChange;

    /// the window rectangle of the normal state (as windowRect: position, client size), kept while the window is
    /// maximized, minimized or fullscreen; windowRect if none was recorded (#1200)
    @property Rect normalWindowRect() const {
        return _normalWindowRect.right > 0 && _normalWindowRect.bottom > 0 ? _normalWindowRect : _windowRect;
    }
    /// ditto
    protected Rect _normalWindowRect;

    /// true if the window is in the normal state (or hidden, e.g. not shown yet) as the system reports it now:
    /// handleWindowStateChange() keeps its rectangles as normalWindowRect. Backends override it where the state is
    /// recorded later than the rectangle changes (#1200)
    protected bool isNormalStateNow() {
        return _windowState == WindowState.normal || _windowState == WindowState.hidden;
    }

    /// save window state to setting object; the rectangle is the normal window's, also of a maximized, minimized or
    /// fullscreen window, so that restoreWindowState() gives it back when the window leaves that state (#1200)
    void saveWindowState(Setting setting) {
        if (!setting)
            return;
        WindowState state = windowState;
        Rect rect = state == WindowState.normal ? windowRect : normalWindowRect;
        if (state == WindowState.fullscreen
            || state == WindowState.minimized
            || state == WindowState.maximized
            || state == WindowState.normal) {
            //
            setting.setInteger("windowState", state);
            if (rect.right > 0 && rect.bottom > 0) {
                setting.setInteger("windowPositionLeft", rect.left);
                setting.setInteger("windowPositionTop", rect.top);
                setting.setInteger("windowWidth", rect.right);
                setting.setInteger("windowHeight", rect.bottom);
            }
        }
    }

    /// restore window state from setting object
    bool restoreWindowState(Setting setting) {
        if (!setting)
            return false;
        WindowState state = cast(WindowState)setting.getInteger("windowState", WindowState.unspecified);
        Rect rect;
        rect.left = cast(int)setting.getInteger("windowPositionLeft", WindowState.unspecified);
        rect.top = cast(int)setting.getInteger("windowPositionTop", 0);
        int w = cast(int)setting.getInteger("windowWidth", 0);
        int h = cast(int)setting.getInteger("windowHeight", 0);
        if (w <= 0 || h <= 0)
            return false;
        rect.right = w;
        rect.bottom = h;
        if (correctWindowPositionOnScreen(rect) && (state == WindowState.fullscreen
             || state == WindowState.minimized
             || state == WindowState.maximized
             || state == WindowState.normal)) {
            if (state != WindowState.normal) {
                // the rect is the normal window's, and backends apply a rect only to a normal window: restore it
                // first, also for a maximized one, which gets it back when it is restored (#1200); a window closed
                // while minimized starts normal, not minimized (#1190)
                setWindowState(WindowState.normal, false, rect);
                if (state == WindowState.fullscreen || state == WindowState.maximized)
                    setWindowState(state);
            } else {
                setWindowState(state, false, rect);
            }
            return true;
        }
        return false;
    }

    /// check if window position inside screen bounds; try to correct if needed; returns true if position is ok.
    bool correctWindowPositionOnScreen(ref Rect rect) {
        // override to apply screen size bounds
        return true;
    }

    protected Rect _caretRect;
    /// blinking caret position (empty rect if no blinking caret)
    @property void caretRect(Rect rc) { _caretRect = rc; }
    @property Rect caretRect() { return _caretRect; }

    protected bool _caretReplace;
    /// blinking caret is in Replace mode if true, insert mode if false
    @property void caretReplace(bool flg) { _caretReplace = flg; }
    @property bool caretReplace() { return _caretReplace; }

    // window content resize mode
    //protected WindowOrContentResizeMode _windowOrContentResizeMode = WindowOrContentResizeMode.resizeWindow;
    //protected WindowOrContentResizeMode _windowOrContentResizeMode = WindowOrContentResizeMode.shrinkWidgets;
    protected WindowOrContentResizeMode _windowOrContentResizeMode = WindowOrContentResizeMode.scrollWindow;

    @property WindowOrContentResizeMode windowOrContentResizeMode() {return _windowOrContentResizeMode; }
    @property void windowOrContentResizeMode(WindowOrContentResizeMode newMode) {
        _windowOrContentResizeMode = newMode;
        if (_mainWidget) {
            _mainWidget.measure(SIZE_UNSPECIFIED, SIZE_UNSPECIFIED);
            adjustWindowOrContentSize(_mainWidget.measuredWidth, _mainWidget.measuredHeight);
        }
    }

    protected ShowPosition _showPosition = ShowPosition.parentWindowCenter;

    /// returns how the window is positioned when shown (don't care, parent center or screen center)
    @property ShowPosition showPosition() {
        return _showPosition;
    }

    /// sets how the window is positioned when shown, before show() (don't care, parent center or screen center);
    /// the default, parentWindowCenter, leaves a window without a parent where the system puts it
    @property void showPosition(ShowPosition newPosition) {
        _showPosition = newPosition;
    }

    // Abstract methods : override in platform implementation

    /// show window
    abstract void show();
    /// returns window caption
    abstract @property dstring windowCaption() const;
    /// sets window caption
    abstract @property void windowCaption(dstring caption);
    /// sets window icon
    abstract @property void windowIcon(DrawBufRef icon);
    /**
        Sets window icon from resource id (e.g. "dlangui-logo1"): the backend makes the icon in the sizes the desktop
        uses (title bar, taskbar, window switcher); an SVG resource is rendered at each size, so it stays sharp (#835).
        The default implementation sets the image of the resource with windowIcon.
     */
    @property void windowIconId(string resourceId) {
        static if (BACKEND_GUI)
            windowIcon = drawableCache.getImage(resourceId);
    }
    /// request window redraw
    abstract void invalidate();
    /// close window
    abstract void close();
    /// returns parent window
    @property Window parentWindow() {
        return null;
    }

    protected WindowState _windowState = WindowState.normal;
    /// returns current window state
    @property WindowState windowState() {
        return _windowState;
    }

    protected Rect _windowRect = RECT_VALUE_IS_NOT_SET;
    /// returns window rectangle on screen (includes window frame and title)
    @property Rect windowRect() {
        if (_windowRect != RECT_VALUE_IS_NOT_SET)
            return _windowRect;
        // fake window rectangle -- at position 0,0 and
        return Rect(0, 0, _dx, _dy);
    }
    /// window state change signal
    Signal!OnWindowStateHandler windowStateChanged;
    /// update and signal window state and/or size/positon changes - for using in platform inplementations
    protected void handleWindowStateChange(WindowState newState, Rect newWindowRect = RECT_VALUE_IS_NOT_SET) {
        bool signalWindow = false;
        if (newState != WindowState.unspecified && newState != _windowState) {
            _windowState = newState;
            //Log.d("Window ", windowCaption, " has new state - ", newState);
            signalWindow = true;
        }
        if (newWindowRect != RECT_VALUE_IS_NOT_SET && newWindowRect != _windowRect) {
            _windowRect = newWindowRect;
            //Log.d("Window ", windowCaption, " rect changed - ", newWindowRect);
            signalWindow = true;
            // the rectangle of the normal state, for saveWindowState() of a maximized or fullscreen window (#1200)
            if (isNormalStateNow())
                _normalWindowRect = _windowRect;
        }

        if(newState == WindowState.minimized)
            _popups.each!(x => x.close());

        if (signalWindow && windowStateChanged.assigned)
            windowStateChanged(this, newState, newWindowRect);
    }

    /// change window state, position, or size; returns true if successful, false if not supported by platform
    bool setWindowState(WindowState newState, bool activate = false, Rect newWindowRect = RECT_VALUE_IS_NOT_SET) {
        // override for particular platforms
        return false;
    }
    /// maximize window
    bool maximizeWindow(bool activate = false) { return setWindowState(WindowState.maximized, activate); }
    /// minimize window
    bool minimizeWindow() { return setWindowState(WindowState.minimized); }
    /// restore window if maximized/minimized/hidden
    bool restoreWindow(bool activate = false) { return setWindowState(WindowState.normal, activate); }
    /// restore window if maximized/minimized/hidden
    bool hideWindow() { return setWindowState(WindowState.hidden); }
    /// just activate window
    bool activateWindow() { return setWindowState(WindowState.unspecified, true); }
    /// change window position only
    bool moveWindow(Point topLeft, bool activate = false) { return setWindowState(WindowState.unspecified, activate, Rect(topLeft.x, topLeft.y, int.min, int.min)); }
    /// change window size only
    bool resizeWindow(Point sz, bool activate = false) { return setWindowState(WindowState.unspecified, activate, Rect(int.min, int.min, sz.x, sz.y)); }
    /// set window rectangle
    bool moveAndResizeWindow(Rect rc, bool activate = false) { return setWindowState(WindowState.unspecified, activate, rc); }

    /// centers window on parent window, do nothing if there is no parent window
    void centerOnParentWindow() {
        if (parentWindow) {
            Rect parentRect = parentWindow.windowRect();
            Point newPos;
            newPos.x = parentRect.left + (parentRect.right - _windowRect.right) / 2;
            newPos.y = parentRect.top + (parentRect.bottom - _windowRect.bottom) / 2;
            moveWindow(newPos);
        }
    }

    /**
        Centers the window on the screen: on the work area (the screen without taskbars and panels) of the monitor
        the window is on (#580). Backends: Win32 (monitor work area), X11 (_NET_WORKAREA, else the whole display;
        with several monitors that may span all of them), SDL (bounds of the window's display). Does nothing in
        other backends, and for maximized, minimized and fullscreen windows.
     */
    void centerOnScreen() {
        // override in platform implementation
    }

    ///adjust window position during show()
    protected void adjustPositionDuringShow() {
        final switch (_showPosition) {
            case ShowPosition.dontCare:
                return;
            case ShowPosition.parentWindowCenter: {
                centerOnParentWindow();
                break;
            }
            case ShowPosition.screenCenter:
                centerOnScreen();
                break;
        }
    }

    // things needed for WindowOrContentResizeMode.scrollWindow:
    /// vertical scrollbar control
    protected ScrollBar _vScrollBar = null;
    /// horizontal scrollbar control
    protected ScrollBar _hScrollBar = null;

    /// Sets the minimal content size and adjust window or content should be called from window show
    void adjustWindowOrContentSize(int minContentWidth, int minContentHeight) {
        // A measured size of SIZE_UNSPECIFIED or more is not a real size: usually some widget reports
        // the parent size it got from measure(SIZE_UNSPECIFIED, SIZE_UNSPECIFIED) as its own size.
        // Treat it as "no minimum", instead of creating window scrollbars for a ~1.6e9 px content (#658).
        if (minContentWidth >= SIZE_UNSPECIFIED) {
            Log.w("Window main widget measured width is unspecified (some widget reports parent size as its own?), ignoring it");
            minContentWidth = 0;
        }
        if (minContentHeight >= SIZE_UNSPECIFIED) {
            Log.w("Window main widget measured height is unspecified (some widget reports parent size as its own?), ignoring it");
            minContentHeight = 0;
        }
        _minContentWidth = minContentWidth;
        _minContentHeight = minContentHeight;
        // A window the user can't resize grows to its content, as with ExpandSize: window scrollbars would be
        // the only way to see the rest of it (#807). Backends keep it inside the screen; if it still doesn't fit,
        // the scrollbars are created below.
        bool expand = _windowOrContentResizeMode == WindowOrContentResizeMode.resizeWindow
            || (flags & WindowFlag.ExpandSize)
            || !(flags & (WindowFlag.Resizable | WindowFlag.Fullscreen));
        if (expand)
            resizeWindow(Point(max(_windowRect.right, minContentWidth), max(_windowRect.bottom, minContentHeight)));
        updateWindowOrContentSize();
    }

    /// smallest client size the user can resize the window to (0: no limit, #455); see updateClientSizeLimits
    protected Point _minClientSize;
    /// largest client size the user can resize the window to (0: no limit, #455); see updateClientSizeLimits
    protected Point _maxClientSize;

    /// smallest client size the user can resize the window to, in pixels (0: no limit): the main widget's
    /// minWidth and minHeight, for a resizable window (#455)
    @property Point minClientSize() const { return _minClientSize; }
    /// largest client size the user can resize the window to, in pixels (0: no limit): the main widget's
    /// maxWidth and maxHeight, for a resizable window (#455)
    @property Point maxClientSize() const { return _maxClientSize; }

    /**
        Takes the client size limits of a resizable, not fullscreen window from the min and max size of the main
        widget (minWidth, minHeight, maxWidth, maxHeight; e.g. `minWidth: 400pt` in DML) and passes changed ones to
        the backend (#455). Called when the window is shown (resizeNow: true) and when the main widget is measured,
        so a change of its style applies on the next layout. A window in the normal state outside new limits is
        resized into them: at once if resizeNow, else after the current layout pass.
    */
    protected void updateClientSizeLimits(bool resizeNow) {
        Point minSize, maxSize;
        if (_mainWidget && (_flags & WindowFlag.Resizable) && !(_flags & WindowFlag.Fullscreen))
            clientSizeLimits(_mainWidget.minWidth, _mainWidget.minHeight, _mainWidget.maxWidth, _mainWidget.maxHeight,
                minSize, maxSize);
        _clientSizeLimitsDpi = SCREEN_DPI; // also when unchanged: they are for it now
        if (minSize == _minClientSize && maxSize == _maxClientSize)
            return;
        _minClientSize = minSize;
        _maxClientSize = maxSize;
        applyClientSizeLimits();
        if (resizeNow)
            resizeIntoClientSizeLimits();
        else
            executeInUiThread(&resizeIntoClientSizeLimits); // not from inside measure()
    }

    /// resizes a window in the normal state to fit into minClientSize and maxClientSize (#455)
    protected void resizeIntoClientSizeLimits() {
        if (_windowState != WindowState.normal || _windowRect.right <= 0 || _windowRect.bottom <= 0)
            return;
        Point size = Point(_windowRect.right, _windowRect.bottom);
        Point newSize = clientSizeWithinLimits(size, _minClientSize, _maxClientSize);
        if (newSize != size)
            resizeWindow(newSize);
    }

    /// backends: make the system keep the user's resizing of the window within minClientSize and maxClientSize
    /// (0: no limit); called when they change (#455)
    protected void applyClientSizeLimits() {
    }

    /// SCREEN_DPI when the client size limits were set
    protected int _clientSizeLimitsDpi;

    /// SCREEN_DPI changed since the client size limits (pixels) were set: scales them to it now, so that they don't
    /// hold the window at its old size when the backend resizes it for the new DPI; the next layout takes them from
    /// the main widget again (#1162, #1163)
    protected void scaleClientSizeLimitsToScreenDpi() {
        int fromDpi = _clientSizeLimitsDpi;
        int toDpi = SCREEN_DPI;
        _clientSizeLimitsDpi = toDpi;
        if (fromDpi <= 0 || fromDpi == toDpi || (_minClientSize == Point(0, 0) && _maxClientSize == Point(0, 0)))
            return;
        _minClientSize = Point(scaleForDpi(_minClientSize.x, fromDpi, toDpi),
            scaleForDpi(_minClientSize.y, fromDpi, toDpi));
        _maxClientSize = Point(scaleForDpi(_maxClientSize.x, fromDpi, toDpi),
            scaleForDpi(_maxClientSize.y, fromDpi, toDpi));
        applyClientSizeLimits();
    }

    /// keep current position of window scrollbar after its range or page size is changed (e.g. on window resize, #632),
    /// moving it only if it is out of the new range
    private static void keepScrollPositionInRange(ScrollBar scrollBar) {
        scrollBar.position = max(0, min(scrollBar.position, scrollBar.maxValue - scrollBar.pageSize));
    }

    /// update current content size based on windowOrContentResizeMode flag, usually used when window is resized
    void updateWindowOrContentSize() {
        final switch (_windowOrContentResizeMode) {
            case WindowOrContentResizeMode.shrinkWidgets: {
                _currentContentWidth = _windowRect.right;
                _currentContentHeight = _windowRect.bottom;
                return;
            }
            case WindowOrContentResizeMode.resizeWindow: {
                    //maybe should not permit to resize when new window size is smaller than content size, now do nothing
                _currentContentWidth = _windowRect.right;
                _currentContentHeight = _windowRect.bottom;
                break;
            }
            case WindowOrContentResizeMode.scrollWindow: {
                if (_windowRect.right < _minContentWidth) {
                    // create scrollbar
                    _currentContentWidth = _minContentWidth;
                    if (!_hScrollBar) {
                        _hScrollBar = new ScrollBar(null,Orientation.Horizontal);
                        _hScrollBar.position = 0; // AbstractSlider default position is not 0
                        _hScrollBar.scrollEvent = delegate bool (AbstractSlider source, ScrollEvent event) {
                            if (event.action == ScrollAction.SliderMoved || event.action == ScrollAction.SliderReleased)
                                requestLayout();
                            else if (event.action == ScrollAction.PageUp) {
                                source.position = max(0, source.position - _windowRect.right * 3 / 4);
                                requestLayout();
                            } else if (event.action == ScrollAction.PageDown) {
                                source.position = min(source.maxValue - _windowRect.right, source.position + _windowRect.right *3 / 4);
                                requestLayout();
                            } else if (event.action == ScrollAction.LineUp) {
                                source.position = max(0, source.position - _windowRect.right / 10);
                                requestLayout();
                            } else if (event.action == ScrollAction.LineDown) {
                                source.position = min(source.maxValue - _windowRect.right, source.position + _windowRect.right / 10);
                                requestLayout();
                            }
                            return true;
                        };
                    }
                    _hScrollBar.measure(_windowRect.right, _windowRect.bottom);
                    if (windowRect().bottom < _minContentHeight)
                        _hScrollBar.setRange(0, _minContentWidth + _hScrollBar.measuredHeight);
                    else
                        _hScrollBar.setRange(0, _minContentWidth);
                    _hScrollBar.pageSize(_windowRect.right);
                    keepScrollPositionInRange(_hScrollBar);
                }
                else {
                    if (_hScrollBar) {
                        destroy(_hScrollBar);
                        _hScrollBar = null;
                    }
                    _currentContentWidth = _windowRect.right;
                }

                if (windowRect().bottom < _minContentHeight) {
                    // create scrollbar
                    _currentContentHeight = _minContentHeight;
                    if (!_vScrollBar) {
                        _vScrollBar = new ScrollBar(null,Orientation.Vertical);
                        _vScrollBar.position = 0; // AbstractSlider default position is not 0
                        _vScrollBar.scrollEvent = delegate bool (AbstractSlider source, ScrollEvent event) {
                            if (event.action == ScrollAction.SliderMoved || event.action == ScrollAction.SliderReleased)
                                requestLayout();
                            else if (event.action == ScrollAction.PageUp) {
                                source.position = max(0, source.position - _windowRect.bottom * 3 / 4);
                                requestLayout();
                            } else if (event.action == ScrollAction.PageDown) {
                                source.position = min(source.maxValue - _windowRect.bottom, source.position + _windowRect.bottom *3 / 4);
                                requestLayout();
                            } else if (event.action == ScrollAction.LineUp) {
                                source.position = max(0, source.position - _windowRect.bottom / 10);
                                requestLayout();
                            } else if (event.action == ScrollAction.LineDown) {
                                source.position = min(source.maxValue - _windowRect.bottom, source.position + _windowRect.bottom / 10);
                                requestLayout();
                            }
                            return true;
                        };
                    }
                    _vScrollBar.measure(_windowRect.right, _windowRect.bottom);
                    if (_hScrollBar)
                        _vScrollBar.setRange(0, _minContentHeight+_hScrollBar.measuredHeight);
                    else
                        _vScrollBar.setRange(0, _minContentHeight);
                    _vScrollBar.pageSize(windowRect().bottom);
                    keepScrollPositionInRange(_vScrollBar);

                    if (!_hScrollBar)
                        _currentContentWidth = _windowRect.right - _vScrollBar.measuredWidth;
                }
                else {
                    if (_vScrollBar) {
                        destroy(_vScrollBar);
                        _vScrollBar = null;
                    }
                    _currentContentHeight = _hScrollBar ? _windowRect.bottom - _hScrollBar.measuredHeight : _windowRect.bottom;
                }
                return;
            }
        }
    }


    /// requests layout for main widget and popups
    void requestLayout() {
        if (_mainWidget)
            _mainWidget.requestLayout();
        if (_hScrollBar)
            _hScrollBar.requestLayout();
        if (_vScrollBar)
            _vScrollBar.requestLayout();
        foreach(p; _popups)
            p.requestLayout();
        if (_tooltip.popup)
            _tooltip.popup.requestLayout();
    }
    void measure() {
        updateClientSizeLimits(false);
        if (_hScrollBar)
            _hScrollBar.measure(_dx, _dy);

        if (_vScrollBar)
            _vScrollBar.measure(_dx, _dy);

        if (_mainWidget !is null) {
            _mainWidget.measure(_currentContentWidth, _currentContentHeight);
        }
        foreach(p; _popups)
            p.measure(_currentContentWidth, _currentContentHeight);
        if (_tooltip.popup)
            _tooltip.popup.measure(_currentContentWidth, _currentContentHeight);
    }
    void layout() {
        if (_hScrollBar)
            _hScrollBar.layout(Rect(0, _dy - _hScrollBar.measuredHeight, _vScrollBar ? _dx - _vScrollBar.measuredWidth : _dx, _dy));

        if (_vScrollBar)
            _vScrollBar.layout(Rect(_dx - _vScrollBar.measuredWidth, 0, _dx, _hScrollBar ? _dy - _hScrollBar.measuredHeight : _dy));

        int deltaX = 0;
        if (_hScrollBar)
            deltaX = -_hScrollBar.position;

        int deltaY = 0;
        if (_vScrollBar)
            deltaY = -_vScrollBar.position;

        Rect rc = Rect(deltaX, deltaY, _currentContentWidth + deltaX, _currentContentHeight + deltaY);
        if (_mainWidget !is null) {
            _mainWidget.layout(rc);
        }
        // popups are placed within the visible part of the window, not the whole scrolled content (#227)
        Rect popupRc = rc;
        if (_hScrollBar || _vScrollBar)
            popupRc = Rect(0, 0, _vScrollBar ? _dx - _vScrollBar.measuredWidth : _dx, _hScrollBar ? _dy - _hScrollBar.measuredHeight : _dy);
        foreach(p; _popups)
            p.layout(popupRc);
        if (_tooltip.popup)
            _tooltip.popup.layout(popupRc);
    }
    void onResize(int width, int height) {
        if (_dx == width && _dy == height)
            return;
        _dx = width;
        _dy = height;
        // fix window rect for platforms that don't set it yet
        _windowRect.right = width;
        _windowRect.bottom = height;
        if (_mainWidget !is null) {
            Log.d("onResize ", _dx, "x", _dy);
            long measureStart = currentTimeMillis;
            updateWindowOrContentSize();
            measure();
            //Log.d("measured size: ", _mainWidget.measuredWidth, "x", _mainWidget.measuredHeight);
            long measureEnd = currentTimeMillis;
            debug Log.d("resize: measure took ", measureEnd - measureStart, " ms");
            layout();
            long layoutEnd = currentTimeMillis;
            debug Log.d("resize: layout took ", layoutEnd - measureEnd, " ms");
            //Log.d("layout position: ", _mainWidget.pos);
        }
        update(true);
    }

    protected PopupWidget[] _popups;

    protected static struct TooltipInfo {
        PopupWidget popup;
        ulong timerId;
        Widget ownerWidget;
        uint alignment;
        int x;
        int y;
    }

    protected TooltipInfo _tooltip;

    /// schedule tooltip for widget be shown with specified delay
    void scheduleTooltip(Widget ownerWidget, long delay, uint alignment = PopupAlign.Below, int x = 0, int y = 0) {
        _tooltip.alignment = alignment;
        _tooltip.x = x;
        _tooltip.y = y;
        _tooltip.ownerWidget = ownerWidget;
        _tooltip.timerId = setTimer(ownerWidget, delay);
    }

    /// call when tooltip timer is expired
    private bool onTooltipTimer() {
        _tooltip.timerId = 0;
        if (isChild(_tooltip.ownerWidget)) {
            Widget w = _tooltip.ownerWidget.createTooltip(_lastMouseX, _lastMouseY, _tooltip.alignment, _tooltip.x, _tooltip.y);
            if (w)
                showTooltip(w, _tooltip.ownerWidget, _tooltip.alignment, _tooltip.x, _tooltip.y);
        }
        return false;
    }

    /// called when user dragged file(s) to application window
    void handleDroppedFiles(string[] filenames) {
        //Log.d("handleDroppedFiles(", filenames, ")");
        if (_onFilesDropped)
            _onFilesDropped(filenames);
    }

    protected void delegate(string[]) _onFilesDropped;
    /// get handler for files dropped to app window
    @property void delegate(string[]) onFilesDropped() { return _onFilesDropped; }
    /// set handler for files dropped to app window
    @property Window onFilesDropped(void delegate(string[]) handler) { _onFilesDropped = handler; return this; }

    protected bool delegate() _onCanClose;
    /// get handler for closing of app (it must return true to allow immediate close, false to cancel close or close window later)
    @property bool delegate() onCanClose() { return _onCanClose; }
    /// set handler for closing of app (it must return true to allow immediate close, false to cancel close or close window later)
    @property Window onCanClose(bool delegate() handler) { _onCanClose = handler; return this; }

    protected void delegate() _onClose;
    /// get handler for closing of window
    @property void delegate() onClose() { return _onClose; }
    /// set handler for closing of window
    @property Window onClose(void delegate() handler) { _onClose = handler; return this; }

    /// returns true if there is some modal window opened above this window, and this window should not process mouse/key input and should not allow closing
    bool hasModalWindowsAbove() {
        return platform.hasModalWindowsAbove(this);
    }

    /// calls onCanClose handler if set to check if system may close window
    bool handleCanClose() {
        if (hasModalWindowsAbove())
            return false;
        if (!_onCanClose)
            return true;
        bool res = _onCanClose();
        if (!res)
            update(true); // redraw window if it was decided to not close immediately
        return res;
    }


    /// hide tooltip if shown and cancel tooltip timer if set
    void hideTooltip() {
        if (_tooltip.popup) {
            destroy(_tooltip.popup);
            _tooltip.popup = null;
            if (_mainWidget)
                _mainWidget.invalidate();
        }
        if (_tooltip.timerId)
            cancelTimer(_tooltip.timerId);
    }

    /// show tooltip immediately
    PopupWidget showTooltip(Widget content, Widget anchor = null, uint alignment = PopupAlign.Center, int x = 0, int y = 0) {
        hideTooltip();
        if (!content)
            return null;
        PopupWidget res = new PopupWidget(content, this);
        res.anchor.widget = anchor !is null ? anchor : _mainWidget;
        res.anchor.alignment = alignment;
        res.anchor.x = x;
        res.anchor.y = y;
        _tooltip.popup = res;
        return res;
    }

    /// show new popup
    PopupWidget showPopup(Widget content, Widget anchor = null, uint alignment = PopupAlign.Center, int x = 0, int y = 0) {
        PopupWidget res = new PopupWidget(content, this);
        res.anchor.widget = anchor !is null ? anchor : _mainWidget;
        res.anchor.alignment = alignment;
        res.anchor.x = x;
        res.anchor.y = y;
        _popups ~= res;
        if (_mainWidget !is null) {
            _mainWidget.requestLayout();
        }
        update(false);
        return res;
    }
    /// remove popup
    bool removePopup(PopupWidget popup) {
        if (!popup)
            return false;
        for (int i = 0; i < _popups.length; i++) {
            PopupWidget p = _popups[i];
            if (p is popup) {
                for (int j = i; j < _popups.length - 1; j++)
                    _popups[j] = _popups[j + 1];
                _popups.length--;
                p.onClose();
                destroy(p);
                // force redraw
                _mainWidget.invalidate();
                return true;
            }
        }
        return false;
    }

    /// returns last modal popup widget, or null if no modal popups opened
    PopupWidget modalPopup() {
        for (int i = cast(int)_popups.length - 1; i >= 0; i--) {
            if (_popups[i].flags & PopupFlags.Modal)
                return _popups[i];
        }
        return null;
    }

    /// returns true if widget is child of either main widget, one of popups or window scrollbar
    bool isChild(Widget w) {
        if (_mainWidget !is null && _mainWidget.isChild(w))
            return true;
        foreach(p; _popups)
            if (p.isChild(w))
                return true;
        if (_tooltip.popup)
            if (_tooltip.popup.isChild(w))
                return true;
        if (_hScrollBar !is null && _hScrollBar.isChild(w))
            return true;
        if (_vScrollBar !is null && _vScrollBar.isChild(w))
            return true;
        return false;
    }

    private long lastDrawTs;

    this() {
        _eventList = new EventList();
        _timerQueue = new TimerQueue();
        updateBackgroundColor();
    }
    ~this() {
        if (destroyedByGC(this.classinfo.name)) return; // finalized by the GC: report the leak (#975)
        debug Log.d("Destroying window");
        destroyWidgets();
        destroy(_eventList);
        destroy(_timerQueue);
        _eventList = null;
    }

    /// calls the onClose handler, once: from destroyWidgets(), or earlier by a backend's destructor (#1250)
    protected void callOnClose() {
        if (_onClose) {
            auto handler = _onClose;
            _onClose = null;
            handler();
        }
    }

    /**
    Calls onClose, then destroys the window's widgets: popups, tooltip, main widget and scrollbars. Called by the
    destructor; a backend with a GL context per window calls it first in its own destructor, with the window's context
    current, so the widgets' GL objects are deleted in their context (#1250). Does nothing the second time.
    */
    protected void destroyWidgets() {
        callOnClose();
        if (_tooltip.popup) {
            destroy(_tooltip.popup);
            _tooltip.popup = null;
        }
        foreach(p; _popups)
            destroy(p);
        _popups = null;
        if (_mainWidget !is null) {
            destroy(_mainWidget);
            _mainWidget = null;
        }
        if (_hScrollBar) {
            destroy(_hScrollBar);
            _hScrollBar = null;
        }
        if (_vScrollBar) {
            destroy(_vScrollBar);
            _vScrollBar = null;
        }
    }

    /**
    Allows queue destroy of widget.

    Sometimes when you have very complicated UI with dynamic create/destroy lists of widgets calling simple destroy()
    on widget makes segmentation fault.

    Usually because you destroy widget that on some stage call another that tries to destroy widget that calls it.
    When the control flow returns widget not exist and you have seg. fault.

    This function use internally $(LINK2 $(DDOX_ROOT_DIR)dlangui/core/events/QueueDestroyEvent.html, QueueDestroyEvent).
    */
    void queueWidgetDestroy(Widget widgetToDestroy)
    {
        QueueDestroyEvent ev = new QueueDestroyEvent(widgetToDestroy);
        postEvent(ev);
    }

    private void animate(Widget root, long interval) {
        if (root is null)
            return;
        if (root.visibility != Visibility.Visible)
            return;
        for (int i = 0; i < root.childCount; i++)
            animate(root.child(i), interval);
        if (root.animating)
            root.animate(interval);
    }

    private void animate(long interval) {
        animate(_mainWidget, interval);
        foreach(p; _popups)
            p.animate(interval);
        if (_tooltip.popup)
            _tooltip.popup.animate(interval);
    }

    static immutable int PERFORMANCE_LOGGING_THRESHOLD_MS = 20;

    /// set when first draw is called: don't handle mouse/key input until draw (layout) is called
    protected bool _firstDrawCalled = false;
    void onDraw(DrawBuf buf) {
        _firstDrawCalled = true;
        static import std.datetime;
        try {
            bool needDraw = false;
            bool needLayout = false;
            bool animationActive = false;
            checkUpdateNeeded(needDraw, needLayout, animationActive);
            if (needLayout || animationActive)
                needDraw = true;
            long ts = std.datetime.Clock.currStdTime;
            if (animationActive && lastDrawTs != 0) {
                animate(ts - lastDrawTs);
                // layout required flag could be changed during animate - check again
                checkUpdateNeeded(needDraw, needLayout, animationActive);
            }
            lastDrawTs = ts;
            if (needLayout) {
                long measureStart = currentTimeMillis;
                measure();
                long measureEnd = currentTimeMillis;
                if (measureEnd - measureStart > PERFORMANCE_LOGGING_THRESHOLD_MS) {
                    debug(DebugRedraw) Log.d("measure took ", measureEnd - measureStart, " ms");
                }
                layout();
                long layoutEnd = currentTimeMillis;
                if (layoutEnd - measureEnd > PERFORMANCE_LOGGING_THRESHOLD_MS) {
                    debug(DebugRedraw) Log.d("layout took ", layoutEnd - measureEnd, " ms");
                }
                //checkUpdateNeeded(needDraw, needLayout, animationActive);
            }
            long drawStart = currentTimeMillis;
            // draw main widget
            _mainWidget.onDraw(buf);

            PopupWidget modal = modalPopup();

            // draw popups
            foreach(p; _popups) {
                if (p is modal) {
                    // TODO: get shadow color from theme
                    buf.fillRect(Rect(0, 0, buf.width, buf.height), 0xD0404040);
                }
                p.onDraw(buf);
            }

            if (_tooltip.popup)
                _tooltip.popup.onDraw(buf);

            if (_hScrollBar)
                _hScrollBar.onDraw(buf);
            if (_vScrollBar)
                _vScrollBar.onDraw(buf);
            if (_hScrollBar && _vScrollBar)
                buf.fillRect(Rect(_vScrollBar.left, _hScrollBar.top, buf.width, buf.height), _backgroundColor);

            long drawEnd = currentTimeMillis;
            debug(DebugRedraw) {
                if (drawEnd - drawStart > PERFORMANCE_LOGGING_THRESHOLD_MS)
                    Log.d("draw took ", drawEnd - drawStart, " ms");
            }
            if (animationActive)
                scheduleAnimation();
            _actionsUpdateRequested = false;
        } catch (Exception e) {
            Log.e("Exception inside winfow.onDraw: ", e);
        }
    }

    /// after drawing, call to schedule redraw if animation is active
    void scheduleAnimation() {
        // override if necessary
    }


    protected void setCaptureWidget(Widget w, MouseEvent event) {
        _mouseCaptureWidget = w;
        _mouseCaptureButtons = event.flags & (MouseFlag.LButton|MouseFlag.RButton|MouseFlag.MButton);
    }

    protected Widget _focusedWidget;
    protected auto _focusStateToApply = State.Focused;
    /// returns current focused widget
    @property Widget focusedWidget() {
        if (!isChild(_focusedWidget))
            _focusedWidget = null;
        return _focusedWidget;
    }

    /// change focus to widget
    Widget setFocus(Widget newFocus, FocusReason reason = FocusReason.Unspecified) {
        if (!isChild(_focusedWidget))
            _focusedWidget = null;
        Widget oldFocus = _focusedWidget;
        auto targetState = State.Focused;
        if(reason == FocusReason.TabFocus)
            targetState = State.Focused | State.KeyboardFocused;
        _focusStateToApply = targetState;
        if (oldFocus is newFocus)
            return oldFocus;
        if (oldFocus !is null) {
            oldFocus.resetState(targetState);
            if (oldFocus)
                oldFocus.focusGroupFocused(false);
        }
        if (newFocus is null || isChild(newFocus)) {
            if (newFocus !is null) {
                // when calling, setState(focused), window.focusedWidget is still previously focused widget
                debug(DebugFocus) Log.d("new focus: ", newFocus.id);
                newFocus.setState(targetState);
            }
            _focusedWidget = newFocus;
            if (_focusedWidget)
                _focusedWidget.focusGroupFocused(true);
            // after focus change, ask for actions update automatically
            //requestActionsUpdate();
        }
        return _focusedWidget;
    }

    protected Widget removeFocus() {
        if (!isChild(_focusedWidget))
            _focusedWidget = null;
        if (_focusedWidget) {
            _focusedWidget.resetState(_focusStateToApply);
            update();
        }
        return _focusedWidget;
    }

    protected Widget applyFocus() {
        if (!isChild(_focusedWidget))
            _focusedWidget = null;
        if (_focusedWidget) {
            _focusedWidget.setState(_focusStateToApply);
            update();
        }
        return _focusedWidget;
    }

    @property bool isActive() {
        return true;
    }

    /// window state change signal
    Signal!OnWindowActivityHandler windowActivityChanged;

    protected void handleWindowActivityChange(bool isWindowActive) {
        if (isWindowActive)
            applyFocus();
        else
            removeFocus();
        if (windowActivityChanged.assigned)
            windowActivityChanged(this, isWindowActive);
    }

    /// dispatch key event to widgets which have wantsKeyTracking == true
    protected bool dispatchKeyEvent(Widget root, KeyEvent event) {
        if (root.visibility != Visibility.Visible)
            return false;
        if (root.wantsKeyTracking) {
            if (root.onKeyEvent(event))
                return true;
        }
        for (int i = 0; i < root.childCount; i++) {
            Widget w = root.child(i);
            if (dispatchKeyEvent(w, event))
                return true;
        }
        return false;
    }

    /// dispatch a key event only to widgets with wantsKeyTracking (MainMenu hotkeys), not to the focused widget:
    /// for characters a backend gets as hotkeys rather than text, e.g. the Win32 WM_SYSCHAR of Alt+Ф (#1240)
    protected bool dispatchKeyTrackingEvent(KeyEvent event) {
        if (hasModalWindowsAbove() || !_firstDrawCalled)
            return false;
        // as dispatchKeyEvent(): no empty text and no control characters
        if (event.action == KeyAction.Text && (!event.text.length || event.text[0] < ' ' || event.text[0] == 0x7F))
            return false;
        PopupWidget modal = modalPopup();
        Widget root = modal ? modal : _mainWidget;
        return root !is null && dispatchKeyEvent(root, event);
    }

    /// dispatch keyboard event
    bool dispatchKeyEvent(KeyEvent event) {
        if (hasModalWindowsAbove() || !_firstDrawCalled)
            return false;
        bool res = false;
        hideTooltip();
        PopupWidget modal = modalPopup();
        if (event.action == KeyAction.KeyDown || event.action == KeyAction.KeyUp) {
            _keyboardModifiers = event.flags;
            if (event.keyCode == KeyCode.ALT || event.keyCode == KeyCode.LALT || event.keyCode == KeyCode.RALT) {
                debug(DebugKeys) Log.d("ALT key: keyboardModifiers = ", _keyboardModifiers);
                if (_mainWidget) {
                    _mainWidget.invalidate();
                    res = true;
                }
            }
        }
        if (event.action == KeyAction.Text) {
            // filter text
            if (event.text.length < 1)
                return res;
            dchar ch = event.text[0];
            if (ch < ' ' || ch == 0x7F) // filter out control symbols
                return res;
        }
        Widget focus = focusedWidget;
        if (!modal || modal.isChild(focus)) {
            while (focus) {
                if (focus.onKeyEvent(event))
                    return true; // processed by focused widget
                if (focus.focusGroup)
                    break;
                focus = focus.parent;
            }
        }
        // a widget with wantsKeyTracking (MainMenu: Alt+letter hotkeys) that takes the key handles it: the backend
        // must know, e.g. Win32 then doesn't pass the key on to DefWindowProc (#1239)
        if (modal) {
            if (dispatchKeyEvent(modal, event))
                return true;
            return modal.onKeyEvent(event) || res;
        } else if (_mainWidget) {
            if (dispatchKeyEvent(_mainWidget, event))
                return true;
            return _mainWidget.onKeyEvent(event) || res;
        }
        return res;
    }

    /// Keep overrided cursor type or NotSet to get cursor from widget
    protected CursorType _overrideCursorType = CursorType.NotSet;

    /// Allow override cursor for entire window. Set to CursorType.NotSet to remove cursor type overriding.
    @property void overrideCursorType(CursorType newCursorType) {
        _overrideCursorType = newCursorType;
        setCursorType(newCursorType);
    }

    /// Returns current window override cursor type or NotSet if not overriding.
    @property CursorType overrideCursorType() {
        return _overrideCursorType;
    }

    protected bool dispatchMouseEvent(Widget root, MouseEvent event, ref bool cursorIsSet) {
        // only route mouse events to visible widgets
        if (root.visibility != Visibility.Visible)
            return false;
        if (!root.isPointInside(event.pos))
            return false;
        // offer event to children first
        for (int i = 0; i < root.childCount; i++) {
            Widget child = root.child(i);
            if (child.isPointInside(event.pos) && dispatchMouseEvent(child, event, cursorIsSet))
                return true;
        }

        if (event.action == MouseAction.Move && !cursorIsSet) {
            uint cursorType = root.getCursorType(event.x, event.y);
            if (cursorType != CursorType.NotSet) {
                setCursorType(cursorType);
                cursorIsSet = true;
            }
        }
        // if not processed by children, offer event to root
        if (sendAndCheckOverride(root, event)) {
            debug(DebugMouseEvents) Log.d("MouseEvent is processed");
            if (event.action == MouseAction.ButtonDown && _mouseCaptureWidget is null && !event.doNotTrackButtonDown) {
                debug(DebugMouseEvents) Log.d("Setting active widget");
                setCaptureWidget(root, event);
            } else if (event.action == MouseAction.Move) {
                addTracking(root);
            }
            return true;
        }
        return false;
    }

    /// widget which tracks Move events
    //protected Widget _mouseTrackingWidget;
    protected Widget[] _mouseTrackingWidgets;
    private void addTracking(Widget w) {
        for(int i = 0; i < _mouseTrackingWidgets.length; i++)
            if (w is _mouseTrackingWidgets[i])
                return;
        //foreach(widget; _mouseTrackingWidgets)
        //    if (widget is w)
        //       return;
        //Log.d("addTracking ", w.id, " items before: ", _mouseTrackingWidgets.length);
        _mouseTrackingWidgets ~= w;
        //Log.d("addTracking ", w.id, " items after: ", _mouseTrackingWidgets.length);
    }
    private bool checkRemoveTracking(MouseEvent event) {
        bool res = false;
        for(int i = cast(int)_mouseTrackingWidgets.length - 1; i >=0; i--) {
            Widget w = _mouseTrackingWidgets[i];
            if (!isChild(w)) {
                // std.algorithm.remove does not work for me
                //_mouseTrackingWidgets.remove(i);
                for (int j = i; j < _mouseTrackingWidgets.length - 1; j++)
                    _mouseTrackingWidgets[j] = _mouseTrackingWidgets[j + 1];
                _mouseTrackingWidgets.length--;
                continue;
            }
            if (event.action == MouseAction.Leave || !w.isPointInside(event.x, event.y)) {
                // send Leave message
                MouseEvent leaveEvent = new MouseEvent(event);
                leaveEvent.changeAction(MouseAction.Leave);
                res = w.onMouseEvent(leaveEvent) || res;
                // std.algorithm.remove does not work for me
                //Log.d("removeTracking ", w.id, " items before: ", _mouseTrackingWidgets.length);
                //_mouseTrackingWidgets.remove(i);
                //_mouseTrackingWidgets.length--;
                for (int j = i; j < _mouseTrackingWidgets.length - 1; j++)
                    _mouseTrackingWidgets[j] = _mouseTrackingWidgets[j + 1];
                _mouseTrackingWidgets.length--;
                //Log.d("removeTracking ", w.id, " items after: ", _mouseTrackingWidgets.length);
            }
        }
        return res;
    }

    /// widget which tracks all events after processed ButtonDown
    protected Widget _mouseCaptureWidget;
    protected ushort _mouseCaptureButtons;
    protected bool _mouseCaptureFocusedOut;
    /// does current capture widget want to receive move events even if pointer left it
    protected bool _mouseCaptureFocusedOutTrackMovements;

    protected void clearMouseCapture() {
        _mouseCaptureWidget = null;
        _mouseCaptureFocusedOut = false;
        _mouseCaptureFocusedOutTrackMovements = false;
        _mouseCaptureButtons = 0;
    }

    protected bool dispatchCancel(MouseEvent event) {
        event.changeAction(MouseAction.Cancel);
        bool res = _mouseCaptureWidget.onMouseEvent(event);
        clearMouseCapture();
        return res;
    }

    protected bool sendAndCheckOverride(Widget widget, MouseEvent event) {
        if (!isChild(widget))
            return false;
        bool res = widget.onMouseEvent(event);
        if (event.trackingWidget !is null && _mouseCaptureWidget !is event.trackingWidget) {
            setCaptureWidget(event.trackingWidget, event);
        }
        return res;
    }

    /// returns true if mouse is currently captured
    bool isMouseCaptured() {
        return (_mouseCaptureWidget !is null && isChild(_mouseCaptureWidget));
    }

    /// dispatch action to main widget
    bool dispatchAction(const Action action, Widget sourceWidget = null) {
        // try to handle by source widget
        if(sourceWidget && isChild(sourceWidget)) {
            if (sourceWidget.handleAction(action))
                return true;
            sourceWidget = sourceWidget.parent;
        }
        Widget focus = focusedWidget;
        // then offer action to focused widget
        if (focus && isChild(focus)) {
            if (focus.handleAction(action))
                return true;
            focus = focus.parent;
        }
        // then offer to parent chain of source widget
        while (sourceWidget && isChild(sourceWidget)) {
            if (sourceWidget.handleAction(action))
                return true;
            sourceWidget = sourceWidget.parent;
        }
        // then offer to parent chain of focused widget
        while (focus && isChild(focus)) {
            if (focus.handleAction(action))
                return true;
            focus = focus.parent;
        }
        if (_mainWidget && _mainWidget.handleAction(action))
            return true;
        return handleDefaultAction(action);
    }

    /// default handling of standard actions not handled by widgets (called by dispatchAction):
    /// StandardAction.OpenUrl opens URL from action.stringParam in external browser (#651)
    protected bool handleDefaultAction(const Action action) {
        if (action.id == StandardAction.OpenUrl && action.stringParam.length)
            return platform.openURL(action.stringParam);
        return false;
    }

    /// dispatch action to main widget
    bool dispatchActionStateRequest(const Action action, Widget sourceWidget = null) {
        // try to handle by source widget
        if(sourceWidget && isChild(sourceWidget)) {
            if (sourceWidget.handleActionStateRequest(action))
                return true;
            sourceWidget = sourceWidget.parent;
        }
        Widget focus = focusedWidget;
        // then offer action to focused widget
        if (focus && isChild(focus)) {
            if (focus.handleActionStateRequest(action))
                return true;
            focus = focus.parent;
        }
        // then offer to parent chain of source widget
        while (sourceWidget && isChild(sourceWidget)) {
            if (sourceWidget.handleActionStateRequest(action))
                return true;
            sourceWidget = sourceWidget.parent;
        }
        // then offer to parent chain of focused widget
        while (focus && isChild(focus)) {
            if (focus.handleActionStateRequest(action))
                return true;
            focus = focus.parent;
        }
        if (_mainWidget)
            return _mainWidget.handleActionStateRequest(action);
        return false;
    }

    /// handle theme change: e.g. reload some themed resources
    void dispatchThemeChanged() {
        if (_hScrollBar)
            _hScrollBar.onThemeChanged();
        if (_vScrollBar)
            _vScrollBar.onThemeChanged();
        if (_mainWidget)
            _mainWidget.onThemeChanged();
        // draw popups
        foreach(p; _popups) {
            p.onThemeChanged();
        }
        if (_tooltip.popup)
            _tooltip.popup.onThemeChanged();
        updateBackgroundColor();
        invalidate();
    }


    /// post event to handle in UI thread (this method can be used from background thread)
    void postEvent(CustomEvent event) {
        // override to post event into window message queue
        _eventList.put(event);
    }

    /// post task to execute in UI thread (this method can be used from background thread)
    void executeInUiThread(void delegate() runnable) {
        RunnableEvent event = new RunnableEvent(CUSTOM_RUNNABLE, null, runnable);
        postEvent(event);
    }

    /// Creates async socket
    AsyncSocket createAsyncSocket(AsyncSocketCallback callback) {
        AsyncClientConnection conn = new AsyncClientConnection(new AsyncSocketCallbackProxy(callback, &executeInUiThread));
        return conn;
    }

    /// remove event from queue by unique id if not yet dispatched (this method can be used from background thread)
    void cancelEvent(uint uniqueId) {
        CustomEvent ev = _eventList.get(uniqueId);
        if (ev) {
            //destroy(ev);
        }
    }

    /// remove event from queue by unique id if not yet dispatched and dispatch it
    void handlePostedEvent(uint uniqueId) {
        CustomEvent ev = _eventList.get(uniqueId);
        if (ev) {
            dispatchCustomEvent(ev);
        }
    }

    /// handle all events from queue, if any (call from UI thread only)
    void handlePostedEvents() {
        for(;;) {
            CustomEvent e = _eventList.get();
            if (!e)
                break;
            dispatchCustomEvent(e);
        }
    }

    /// dispatch custom event
    bool dispatchCustomEvent(CustomEvent event) {
        if (event.destinationWidget) {
            if (!isChild(event.destinationWidget)) {
                //Event is sent to widget which does not exist anymore
                return false;
            }
            return event.destinationWidget.onEvent(event);
        } else {
            // no destination widget
            RunnableEvent runnable = cast(RunnableEvent)event;
            if (runnable) {
                // handle runnable
                runnable.run();
                return true;
            }
        }
        return false;
    }

    private int _lastMouseX;
    private int _lastMouseY;
    /// dispatch mouse event to window content widgets
    bool dispatchMouseEvent(MouseEvent event) {
        if (hasModalWindowsAbove() || !_firstDrawCalled)
            return false;
        // ignore events if there is no root
        if (_mainWidget is null)
            return false;

        bool actualChange = true;
        if (event.action == MouseAction.Move) {
            actualChange = (_lastMouseX != event.x || _lastMouseY != event.y);
            _lastMouseX = event.x;
            _lastMouseY = event.y;
        }
        if (actualChange) hideTooltip();

        PopupWidget modal = modalPopup();

        // check if _mouseCaptureWidget and _mouseTrackingWidget still exist in child of root widget
        if (_mouseCaptureWidget !is null && (!isChild(_mouseCaptureWidget) || (modal && !modal.isChild(_mouseCaptureWidget)))) {
            clearMouseCapture();
        }

        debug(DebugMouseEvents) Log.d("dispatchMouseEvent ", event.action, "  (", event.x, ",", event.y, ")");

        bool res = false;
        ushort currentButtons = event.flags & (MouseFlag.LButton|MouseFlag.RButton|MouseFlag.MButton);
        if (_mouseCaptureWidget !is null) {
            // try to forward message directly to active widget
            if (event.action == MouseAction.Move) {
                debug(DebugMouseEvents) Log.d("dispatchMouseEvent: Move; buttons state=", currentButtons);
                if (!_mouseCaptureWidget.isPointInside(event.x, event.y)) {
                    if (currentButtons != _mouseCaptureButtons) {
                        debug(DebugMouseEvents) Log.d("dispatchMouseEvent: Move; buttons state changed from ", _mouseCaptureButtons, " to ", currentButtons, " - cancelling capture");
                        return dispatchCancel(event);
                    }
                    // point is no more inside of captured widget
                    if (!_mouseCaptureFocusedOut) {
                        // sending FocusOut message
                        event.changeAction(MouseAction.FocusOut);
                        _mouseCaptureFocusedOut = true;
                        _mouseCaptureButtons = currentButtons;
                        _mouseCaptureFocusedOutTrackMovements = sendAndCheckOverride(_mouseCaptureWidget, event);
                        return true;
                    } else if (_mouseCaptureFocusedOutTrackMovements) {
                        // pointer is outside, but we still need to track pointer
                        return sendAndCheckOverride(_mouseCaptureWidget, event);
                    }
                    // don't forward message
                    return true;
                } else {
                    // point is inside widget
                    if (_mouseCaptureFocusedOut) {
                        _mouseCaptureFocusedOut = false;
                        if (currentButtons != _mouseCaptureButtons)
                            return dispatchCancel(event);
                           event.changeAction(MouseAction.FocusIn); // back in after focus out
                    }
                    return sendAndCheckOverride(_mouseCaptureWidget, event);
                }
            } else if (event.action == MouseAction.Leave) {
                if (!_mouseCaptureFocusedOut) {
                    // sending FocusOut message
                    event.changeAction(MouseAction.FocusOut);
                    _mouseCaptureFocusedOut = true;
                    _mouseCaptureButtons = event.flags & (MouseFlag.LButton|MouseFlag.RButton|MouseFlag.MButton);
                    return sendAndCheckOverride(_mouseCaptureWidget, event);
                } else {
                    debug(DebugMouseEvents) Log.d("dispatchMouseEvent: mouseCaptureFocusedOut + Leave - cancelling capture");
                    return dispatchCancel(event);
                }
            } else if (event.action == MouseAction.ButtonDown || event.action == MouseAction.ButtonUp) {
                if (!_mouseCaptureWidget.isPointInside(event.x, event.y)) {
                    if (currentButtons != _mouseCaptureButtons) {
                        debug(DebugMouseEvents) Log.d("dispatchMouseEvent: ButtonUp/ButtonDown; buttons state changed from ", _mouseCaptureButtons, " to ", currentButtons, " - cancelling capture");
                        return dispatchCancel(event);
                    }
                }
            }
            // other messages
            res = sendAndCheckOverride(_mouseCaptureWidget, event);
            if (!currentButtons) {
                // usable capturing - no more buttons pressed
                debug(DebugMouseEvents) Log.d("unsetting active widget");
                clearMouseCapture();
            }
            return res;
        }

        bool processed = false;
        if (event.action == MouseAction.Move || event.action == MouseAction.Leave) {
            processed = checkRemoveTracking(event);
        }

        bool cursorIsSet = false;
        if (overrideCursorType != CursorType.NotSet) {
            cursorIsSet = true;
        }

        if (!res) {
            bool insideOneOfPopups = false;
            for (int i = cast(int)_popups.length - 1; i >= 0; i--) {
                auto p = _popups[i];
                if (p.isPointInside(event.x, event.y)) {
                    if (p !is modal)
                        insideOneOfPopups = true;
                }
                if (p is modal)
                    break;
            }
            for (int i = cast(int)_popups.length - 1; i >= 0; i--) {
                auto p = _popups[i];
                if (p is modal)
                    break;
                if (!insideOneOfPopups) {
                    if (event.action == MouseAction.ButtonDown)
                        return true; // mouse button down should do nothing when click outside when popup visible
                    if (p.onMouseEventOutside(event)) {
                        return true; // mouse button up should do nothing when click outside when popup visible
                    }
                } else {
                    if (dispatchMouseEvent(p, event, cursorIsSet))
                        return true;
                }
            }
            if (!modal) {
                res = false;
                if (_hScrollBar)
                    res = dispatchMouseEvent(_hScrollBar, event, cursorIsSet);
                if (!res && _vScrollBar)
                    res = dispatchMouseEvent(_vScrollBar, event, cursorIsSet);
                if (!res)
                    res = dispatchMouseEvent(_mainWidget, event, cursorIsSet);
            }
            else {
                if (_hScrollBar)
                    res = dispatchMouseEvent(_hScrollBar, event, cursorIsSet);
                if (!res && _vScrollBar)
                    res = dispatchMouseEvent(_vScrollBar, event, cursorIsSet);
                if (!res)
                        res = dispatchMouseEvent(modal, event, cursorIsSet);
            }
            if (!res && !modal && event.action == MouseAction.Wheel)
                res = scrollWindowByWheel(event);
        }
        return res || processed || _mainWidget.needDraw;
    }

    /// Scrolls the window content with the window scrollbars (WindowOrContentResizeMode.scrollWindow) by a mouse
    /// wheel event no widget has handled (#807): vertically, or horizontally with Shift or without a vertical scrollbar.
    protected bool scrollWindowByWheel(MouseEvent event) {
        ScrollBar bar = _vScrollBar;
        if (_hScrollBar && (!bar || (event.flags & MouseFlag.Shift)))
            bar = _hScrollBar;
        if (!bar)
            return false;
        return bar.onMouseEvent(event);
    }

    /// calls update actions recursively
    protected void dispatchWidgetUpdateActionStateRecursive(Widget root) {
        if (root is null)
            return;
        root.updateActionState(true);
        for (int i = 0; i < root.childCount; i++)
            dispatchWidgetUpdateActionStateRecursive(root.child(i));
    }
    /// checks content widgets for necessary redraw and/or layout
    protected void checkUpdateNeeded(Widget root, ref bool needDraw, ref bool needLayout, ref bool animationActive) {
        if (root is null)
            return;
        if (root.visibility != Visibility.Visible)
            return;
        needDraw = root.needDraw || needDraw;
        if (!needLayout) {
            needLayout = root.needLayout || needLayout;
            if (needLayout) {
                debug(DebugRedraw) Log.d("need layout: ", root.classinfo.name, " id=", root.id);
            }
        }
        if (root.animating && root.visible)
            animationActive = true; // check animation only for visible widgets
        for (int i = 0; i < root.childCount; i++)
            checkUpdateNeeded(root.child(i), needDraw, needLayout, animationActive);
    }
    /// sets cursor type for window
    protected void setCursorType(uint cursorType) {
        // override to support different mouse cursors
    }
    /// update action states
    protected void dispatchWidgetUpdateActionStateRecursive() {
        if (_mainWidget !is null)
            dispatchWidgetUpdateActionStateRecursive(_mainWidget);
        foreach(p; _popups)
            dispatchWidgetUpdateActionStateRecursive(p);
    }
    /// checks content widgets for necessary redraw and/or layout
    bool checkUpdateNeeded(ref bool needDraw, ref bool needLayout, ref bool animationActive) {
        if (_actionsUpdateRequested) {
            // call update action check - as requested
            dispatchWidgetUpdateActionStateRecursive();
            _actionsUpdateRequested = false;
        }
        needDraw = needLayout = animationActive = false;
        if (_mainWidget is null)
            return false;
        checkUpdateNeeded(_mainWidget, needDraw, needLayout, animationActive);
        if (_hScrollBar)
            checkUpdateNeeded(_hScrollBar, needDraw, needLayout, animationActive);
        if (_vScrollBar)
            checkUpdateNeeded(_vScrollBar, needDraw, needLayout, animationActive);
        foreach(p; _popups)
            checkUpdateNeeded(p, needDraw, needLayout, animationActive);
        if (_tooltip.popup)
            checkUpdateNeeded(_tooltip.popup, needDraw, needLayout, animationActive);
        return needDraw || needLayout || animationActive;
    }

    protected bool _animationActive;

    @property bool isAnimationActive() {
        return _animationActive;
    }

    /// requests update for window (unless force is true, update will be performed only if layout, redraw or animation is required).
    void update(bool force = false) {
        if (_mainWidget is null)
            return;
        bool needDraw = false;
        bool needLayout = false;
        _animationActive = false;
        if (checkUpdateNeeded(needDraw, needLayout, _animationActive) || force) {
            debug(DebugRedraw) Log.d("Requesting update");
            invalidate();
        }
        debug(DebugRedraw) Log.d("checkUpdateNeeded returned needDraw=", needDraw, " needLayout=", needLayout, " animationActive=", _animationActive);
    }

    protected bool _actionsUpdateRequested = true;

    /// set action update request flag, will be cleared after redraw
    void requestActionsUpdate(bool immediateUpdate = false) {
        if (!immediateUpdate)
            _actionsUpdateRequested = true;
        else
            dispatchWidgetUpdateActionStateRecursive();
    }

    @property bool actionsUpdateRequested() {
        return _actionsUpdateRequested;
    }

    /// Show message box with specified title and message (title and message as UIString)
    void showMessageBox(UIString title, UIString message, const (Action)[] actions = [ACTION_OK], int defaultActionIndex = 0, bool delegate(const Action result) handler = null) {
        import dlangui.dialogs.msgbox;
        MessageBox dlg = new MessageBox(title, message, this, actions, defaultActionIndex, handler);
        dlg.show();
    }

    /// Show message box with specified title and message (title and message as dstring)
    void showMessageBox(dstring title, dstring message, const (Action)[] actions = [ACTION_OK], int defaultActionIndex = 0, bool delegate(const Action result) handler = null) {
        showMessageBox(UIString.fromRaw(title), UIString.fromRaw(message), actions, defaultActionIndex, handler);
    }

    static if (BACKEND_GUI) {
        void showInputBox(UIString title, UIString message, dstring initialText, void delegate(dstring result) handler) {
            import dlangui.dialogs.inputbox;
            InputBox dlg = new InputBox(title, message, this, initialText, handler);
            dlg.show();
        }
    }

    void showInputBox(dstring title, dstring message, dstring initialText, void delegate(dstring result) handler) {
        showInputBox(UIString.fromRaw(title), UIString.fromRaw(message), initialText, handler);
    }

    protected TimerQueue _timerQueue;


    /// schedule timer for interval in milliseconds - call window.onTimer when finished
    protected void scheduleSystemTimer(long intervalMillis) {
        //debug Log.d("override scheduleSystemTimer to support timers");
    }

    /// poll expired timers; returns true if update is needed
    bool pollTimers() {
        bool res = _timerQueue.notify();
        if (res)
            update(false);
        return res;
    }

    /// system timer interval expired - notify queue
    protected void onTimer() {
        //Log.d("window.onTimer");
        bool res = _timerQueue.notify();
        //Log.d("window.onTimer after notify");
        if (res) {
            // check if update needed and redraw if so
            //Log.d("before update");
            update(false);
            //Log.d("after update");
        }
        //Log.d("schedule next timer");
        long nextInterval = _timerQueue.nextIntervalMillis();
        if (nextInterval > 0) {
            scheduleSystemTimer(nextInterval);
        }
        //Log.d("schedule next timer done");
    }

    /// set timer for destination widget - destination.onTimer() will be called after interval expiration; returns timer id
    ulong setTimer(Widget destination, long intervalMillis) {
        if (!isChild(destination)) {
            Log.e("setTimer() is called not for child widget of window");
            return 0;
        }
        ulong res = _timerQueue.add(destination, intervalMillis);
        long nextInterval = _timerQueue.nextIntervalMillis();
        if (nextInterval > 0) {
            scheduleSystemTimer(intervalMillis);
        }
        return res;
    }

    /// cancel previously scheduled widget timer (for timerId pass value returned from setTimer)
    void cancelTimer(ulong timerId) {
        _timerQueue.cancelTimer(timerId);
    }

    /// timers queue
    private class TimerQueue {
        protected TimerInfo[] _queue;
        /// add new timer
        ulong add(Widget destination, long intervalMillis) {
            TimerInfo item = new TimerInfo(destination, intervalMillis);
            _queue ~= item;
            sort(_queue);
            return item.id;
        }
        /// cancel timer
        void cancelTimer(ulong timerId) {
            if (!_queue.length)
                return;
            for (int i = cast(int)_queue.length - 1; i >= 0; i--) {
                if (_queue[i].id == timerId) {
                    _queue[i].cancel();
                    break;
                }
            }
        }
        /// returns interval if millis of next scheduled event or -1 if no events queued
        long nextIntervalMillis() {
            if (!_queue.length || !_queue[0].valid)
                return -1;
            long delta = _queue[0].nextTimestamp - currentTimeMillis;
            if (delta < 1)
                delta = 1;
            return delta;
        }
        private void cleanup() {
            if (!_queue.length)
                return;
            sort(_queue);
            size_t newsize = _queue.length;
            for (int i = cast(int)_queue.length - 1; i >= 0; i--) {
                if (!_queue[i].valid) {
                    newsize = i;
                }
            }
            if (_queue.length > newsize)
                _queue.length = newsize;
        }
        private TimerInfo[] expired() {
            if (!_queue.length)
                return null;
            long ts = currentTimeMillis;
            TimerInfo[] res;
            for (int i = 0; i < _queue.length; i++) {
                if (_queue[i].nextTimestamp <= ts)
                    res ~= _queue[i];
            }
            return res;
        }
        /// returns true if at least one widget was notified
        bool notify() {
            bool res = false;
            checkValidWidgets();
            TimerInfo[] list = expired();
            if (list) {
                for (int i = 0; i < list.length; i++) {
                    if (_queue[i].id == _tooltip.timerId) {
                        // special case for tooltip timer
                        onTooltipTimer();
                        _queue[i].cancel();
                        res = true;
                    } else {
                        Widget w = _queue[i].targetWidget;
                        if (w && !isChild(w))
                            _queue[i].cancel();
                        else {
                            _queue[i].notify();
                            res = true;
                        }
                    }
                }
            }
            cleanup();
            return res;
        }
        private void checkValidWidgets() {
            for (int i = 0; i < _queue.length; i++) {
                Widget w = _queue[i].targetWidget;
                if (w && !isChild(w))
                    _queue[i].cancel();
            }
            cleanup();
        }
    }


}

/// saveWindowState() saves the normal rectangle of a maximized window, restoreWindowState() gives it back as the
/// normal rectangle before maximizing (#1200)
unittest {
    import dlangui.core.settings : Setting;
    import dlangui.widgets.styles : useTestTheme;
    import std.format : format;
    static class StateTestWindow : Window {
        string[] calls;
        override void show() {}
        override @property dstring windowCaption() const { return null; }
        override @property void windowCaption(dstring caption) {}
        override @property void windowIcon(DrawBufRef icon) {}
        override void invalidate() {}
        override void close() {}
        override bool setWindowState(WindowState newState, bool activate = false,
                Rect newWindowRect = RECT_VALUE_IS_NOT_SET) {
            calls ~= format("%s %s", newState, newWindowRect == RECT_VALUE_IS_NOT_SET ? "-" : format("%s", newWindowRect));
            return true;
        }
        void report(WindowState state, Rect rc) { handleWindowStateChange(state, rc); }
    }
    auto _ = useTestTheme();
    auto w = new StateTestWindow();
    scope(exit) destroy(w);
    Rect normal = Rect(100, 50, 800, 600);
    w.report(WindowState.normal, normal);
    w.report(WindowState.maximized, Rect(0, 0, 1920, 1040));
    assert(w.normalWindowRect == normal);
    auto setting = new Setting();
    w.saveWindowState(setting);
    assert(setting.getInteger("windowState") == WindowState.maximized);
    assert(setting.getInteger("windowPositionLeft") == 100 && setting.getInteger("windowPositionTop") == 50);
    assert(setting.getInteger("windowWidth") == 800 && setting.getInteger("windowHeight") == 600);
    assert(w.restoreWindowState(setting));
    assert(w.calls == [format("%s %s", WindowState.normal, normal), format("%s -", WindowState.maximized)],
        format("%s", w.calls));
    // a normal window saves its own rectangle
    w.report(WindowState.normal, Rect(10, 20, 300, 200));
    w.saveWindowState(setting);
    assert(setting.getInteger("windowState") == WindowState.normal && setting.getInteger("windowWidth") == 300);
}

unittest {
    // a theme color background follows theme changes, a color set by the application is kept (#1140)
    import dlangui.widgets.styles : useTestTheme;
    static class TestWindow : Window {
        override void show() {}
        override @property dstring windowCaption() const { return null; }
        override @property void windowCaption(dstring caption) {}
        override @property void windowIcon(DrawBufRef icon) {}
        override void invalidate() {}
        override void close() {}
    }
    // the theme colors are changed below: only in a theme created for this test, it is removed at the end
    if (currentTheme !is null)
        return;
    auto _ = useTestTheme();
    immutable uint savedWindowColor = currentTheme.customColor(STYLE_COLOR_WINDOW_BACKGROUND);
    immutable uint savedDialogColor = currentTheme.customColor(STYLE_COLOR_DIALOG_BACKGROUND);
    TestWindow[] windows = [new TestWindow, new TestWindow, new TestWindow, new TestWindow, new TestWindow];
    scope(exit) foreach (w; windows) destroy(w);
    auto window = windows[0], dialog = windows[1], fixed = windows[2], missing = windows[3], fixedById = windows[4];
    assert(window.backgroundColorId == STYLE_COLOR_WINDOW_BACKGROUND);
    assert(window.backgroundColor == savedWindowColor);
    dialog.setBackgroundColorId(STYLE_COLOR_DIALOG_BACKGROUND, DEFAULT_DIALOG_BACKGROUND_COLOR);
    assert(dialog.backgroundColor == savedDialogColor);
    fixed.backgroundColor = 0x123456;
    fixedById.setBackgroundColorId(null, 0x234567);
    assert(fixedById.backgroundColor == 0x234567);
    missing.setBackgroundColorId("test_no_such_color_1140", 0x345678);
    assert(missing.backgroundColor == 0x345678);

    currentTheme.setCustomColor(STYLE_COLOR_WINDOW_BACKGROUND, 0x111111);
    currentTheme.setCustomColor(STYLE_COLOR_DIALOG_BACKGROUND, 0x222222);
    foreach (w; windows)
        w.dispatchThemeChanged();
    assert(window.backgroundColor == 0x111111);
    assert(dialog.backgroundColor == 0x222222);
    assert(fixed.backgroundColor == 0x123456);
    assert(fixedById.backgroundColor == 0x234567);
    assert(missing.backgroundColor == 0x345678);
}

unittest {
    // a key tracking event reaches widgets with wantsKeyTracking (MainMenu), not the focused widget (#1240)
    import dlangui.widgets.styles : useTestTheme;
    import dlangui.widgets.layouts : VerticalLayout;
    static class TestWindow : Window {
        override void show() {}
        override @property dstring windowCaption() const { return null; }
        override @property void windowCaption(dstring caption) {}
        override @property void windowIcon(DrawBufRef icon) {}
        override void invalidate() {}
        override void close() {}
    }
    static class TestPlatform : Platform { // hasModalWindowsAbove() asks the platform
        override Window createWindow(dstring windowCaption, Window parent, uint flags = WindowFlag.Resizable,
                uint width = 0, uint height = 0) { return null; }
        override void closeWindow(Window w) {}
        override int enterMessageLoop() { return 0; }
        override bool hasClipboardText(bool mouseBuffer = false) { return false; }
        override dstring getClipboardText(bool mouseBuffer = false) { return null; }
        override void setClipboardText(dstring text, bool mouseBuffer = false) {}
        override void requestLayout() {}
        override protected void forEachWindow(scope void delegate(Window) dg) {}
    }
    // records the text it gets; an editor takes any text, the menu only its hotkey
    static class TextRecorder : Widget {
        bool tracking;
        dstring received;
        this(string id, bool tracking) { super(id); this.tracking = tracking; }
        override @property bool wantsKeyTracking() { return tracking; }
        override bool onKeyEvent(KeyEvent event) {
            if (event.action != KeyAction.Text)
                return false;
            received ~= event.text;
            return !tracking || event.text == "ф"d;
        }
    }
    auto _ = useTestTheme();
    Platform savedPlatform = Platform._instance;
    auto testPlatform = new TestPlatform();
    Platform._instance = testPlatform;
    scope (exit) {
        Platform._instance = savedPlatform;
        destroy(testPlatform);
    }
    auto window = new TestWindow();
    scope (exit) destroy(window);
    auto editor = new TextRecorder("editor", false);
    auto menu = new TextRecorder("menu", true);
    auto layout = new VerticalLayout("layout");
    layout.addChild(menu);
    layout.addChild(editor);
    window.mainWidget = layout;
    window._focusedWidget = editor;
    window._firstDrawCalled = true;
    // the menu's hotkey: taken by the menu
    assert(window.dispatchKeyTrackingEvent(new KeyEvent(KeyAction.Text, 0, KeyFlag.Alt, "ф"d)));
    // no hotkey: not handled (the backend passes it on), and never typed into the editor
    assert(!window.dispatchKeyTrackingEvent(new KeyEvent(KeyAction.Text, 0, KeyFlag.Alt, "щ"d)));
    // no empty text or control characters
    assert(!window.dispatchKeyTrackingEvent(new KeyEvent(KeyAction.Text, 0, KeyFlag.Alt, ""d)));
    assert(!window.dispatchKeyTrackingEvent(new KeyEvent(KeyAction.Text, 0, KeyFlag.Alt, "\x1B"d)));
    assert(menu.received == "фщ"d);
    assert(editor.received.length == 0);
    // the normal dispatch gives text to the focused widget first
    assert(window.dispatchKeyEvent(new KeyEvent(KeyAction.Text, 0, KeyFlag.Alt, "щ"d)));
    assert(editor.received == "щ"d);
}

/**
 * Platform abstraction layer.
 *
 * Represents application.
 *
 *
 *
 */
class Platform {
    static __gshared Platform _instance;
    static void setInstance(Platform instance) {
        if (_instance)
            destroy(_instance);
        _instance = instance;
    }
    @property static Platform instance() {
        return _instance;
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
    abstract Window createWindow(dstring windowCaption, Window parent, uint flags = WindowFlag.Resizable, uint width = 0, uint height = 0);

    static if (ENABLE_OPENGL) {
        /**
         * OpenGL context major version.
         * Note: if the version is invalid or not supported, this value will be set to supported one.
         */
        int GLVersionMajor = 3;
        /**
         * OpenGL context minor version.
         * Note: if the version is invalid or not supported, this value will be set to supported one.
         */
        int GLVersionMinor = 2;

        /**
         * OpenGL multisamples amount.
         * Note: 0, 2, 4, 8, or 16 are accepted.
         * TODO: Not supported on Linux
         */
        int multisamples = 0;
    }

    /**
     * Returns the amount of multisamples. Returns 0 if no OpenGL support
     */
    int getMultisamples()
    {
        static if(ENABLE_OPENGL)
            return multisamples;
        else
            return 0;
    }
    /**
     * close window
     *
     * Closes window earlier created with createWindow()
     */
    abstract void closeWindow(Window w);
    /**
     * Starts application message loop.
     *
     * When returned from this method, application is shutting down.
     */
    abstract int enterMessageLoop();
    /// check has clipboard text
    abstract bool hasClipboardText(bool mouseBuffer = false);
    /// retrieves text from clipboard (when mouseBuffer == true, use mouse selection clipboard - under linux)
    abstract dstring getClipboardText(bool mouseBuffer = false);
    /// sets text to clipboard (when mouseBuffer == true, use mouse selection clipboard - under linux)
    abstract void setClipboardText(dstring text, bool mouseBuffer = false);

    /// calls request layout for all windows
    abstract void requestLayout();

    /// returns true if there is some modal window opened above this window, and this window should not process mouse/key input and should not allow closing
    bool hasModalWindowsAbove(Window w) {
        // override in platform specific class
        return false;
    }


    protected string _uiLanguage;
    /// returns currently selected UI language code
    @property string uiLanguage() {
        return _uiLanguage;
    }
    /// set UI language (e.g. "en", "fr", "ru") - will relayout content of all windows if language has been changed
    @property Platform uiLanguage(string langCode) {
        if (_uiLanguage.equal(langCode))
            return this;
        _uiLanguage = langCode;

        Log.v("Loading language file");
        if (langCode.equal("en"))
            i18n.load("en.ini"); //"ru.ini", "en.ini"
        else
            i18n.load(langCode ~ ".ini", "en.ini");
        Log.v("Calling onThemeChanged");
        onThemeChanged();
        requestLayout();
        return this;
    }
    protected string _themeId;
    @property string uiTheme() {
        return _themeId;
    }
    /// sets application UI theme - will relayout content of all windows if theme has been changed
    @property Platform uiTheme(string themeResourceId) {
        if (_themeId.equal(themeResourceId))
            return this;
        Log.v("uiTheme setting new theme ", themeResourceId);
        _themeId = themeResourceId;
        Theme theme = loadTheme(themeResourceId);
        if (!theme) {
            Log.e("Cannot load theme from resource ", themeResourceId, " - will use default theme");
            theme = createDefaultTheme();
        } else {
            Log.i("Applying loaded theme ", theme.id);
        }
        currentTheme = theme;
        onThemeChanged();
        requestLayout();
        return this;
    }

    /// to set uiLanguage and themeId to default (en, theme_default) if not set yet
    protected void setDefaultLanguageAndThemeIfNecessary() {
        if (!_uiLanguage) {
            Log.v("setDefaultLanguageAndThemeIfNecessary : setting UI language");
            uiLanguage = "en";
        }
        if (!_themeId) {
            Log.v("setDefaultLanguageAndThemeIfNecessary : setting UI theme");
            uiTheme = "theme_default";
        }
    }

    // all dialogs in windows (#1109); the console backend shows all of them in popups
    protected ulong _uiDialogDisplayMode = DialogDisplayMode.allTypesOfDialogsInWindow;
    /// returns how dialogs should be displayed - as popup or window (DialogDisplayMode flags; default: all in windows)
    @property ulong uiDialogDisplayMode() {
        return _uiDialogDisplayMode;
    }

    // sets how dialogs should be displayed - as popup or window - use DialogDisplayMode enumeration
    @property Platform uiDialogDisplayMode(ulong newDialogDisplayMode) {
        _uiDialogDisplayMode = newDialogDisplayMode;
        return this;
    }

    protected string[] _resourceDirs;
    /// returns list of resource directories
    @property string[] resourceDirs() { return _resourceDirs; }
    /// set list of directories to load resources from
    @property Platform resourceDirs(string[] dirs) {
        // setup resource directories - will use only existing directories
        drawableCache.setResourcePaths(dirs);
        _resourceDirs = drawableCache.resourcePaths;
        // setup i18n - look for i18n directory inside one of passed directories
        i18n.findTranslationsDir(dirs);
        return this;
    }

    /// open url in external browser
    bool openURL(string url) {
        import std.process;
        browse(url);
        return true;
    }

    /// show directory or file in OS file manager (explorer, finder, etc...)
    bool showInFileManager(string pathName) {
        static import dlangui.core.filemanager;
        return dlangui.core.filemanager.showInFileManager(pathName);
    }

    /// calls dg for each window of the platform; every backend implements it, so that e.g. a theme change reaches
    /// all windows (#1173)
    protected abstract void forEachWindow(scope void delegate(Window) dg);

    /// handle theme change: reloads themed resources, and lets the widgets of all windows drop what they cached
    /// from the old theme (Window.dispatchThemeChanged())
    void onThemeChanged() {
        // the caches don't exist without initResourceManagers() (#1174)
        if (drawableCache)
            drawableCache.clear();
        static if (!WIDGET_STYLE_CONSOLE) {
            if (imageCache) {
                imageCache.checkpoint();
                imageCache.cleanup();
            }
        }
        // the theme's styles drop the fonts and drawables they cached; in every backend (#1160)
        if (currentTheme)
            currentTheme.onThemeChanged();
        // in the base class, so that no backend leaves its windows with stale fonts and drawables (#1173)
        forEachWindow((w) { w.dispatchThemeChanged(); });
    }

    /// a DPI rejected by setSystemScreenDpi() was warned about
    private bool _rejectedScreenDpiWarned;

    /// sets the screen DPI detected by the backend (SCREEN_DPI, unless overridden), e.g. after the desktop scale
    /// changed while the app runs; on a change of SCREEN_DPI, reloads the fonts and images cached for the old DPI and
    /// lays the windows out again (#1162, #1163). Returns true if SCREEN_DPI changed
    bool setSystemScreenDpi(int dpi) {
        int oldDpi = SCREEN_DPI;
        SCREEN_DPI = dpi;
        if (systemScreenDPI != dpi && !_rejectedScreenDpiWarned) {
            _rejectedScreenDpiWarned = true; // once: SDL calls this on every resize
            Log.w("Screen DPI ", dpi, " is outside the supported range, keeping ", systemScreenDPI);
        }
        if (SCREEN_DPI == oldDpi)
            return false;
        Log.i("SCREEN_DPI is changed from ", oldDpi, " to ", SCREEN_DPI);
        onThemeChanged();
        requestLayout();
        return true;
    }

    /// default icon for new created windows
    private string _defaultWindowIcon = "dlangui-logo1";

    /// sets default icon for new created windows
    @property void defaultWindowIcon(string newIcon) {
        _defaultWindowIcon = newIcon;
    }

    /// gets default icon for new created windows
    @property string defaultWindowIcon() {
        return _defaultWindowIcon;
    }

    private IconProviderBase _iconProvider;
    @property IconProviderBase iconProvider() {
        if (_iconProvider is null) {
            try {
                _iconProvider = new NativeIconProvider();
            } catch(Exception e) {
                Log.e("Error while creating icon provider.", e);
                Log.d("Could not create native icon provider, fallbacking to the dummy one");
                _iconProvider = new DummyIconProvider();
            }
        }
        return _iconProvider;
    }

    @property IconProviderBase iconProvider(IconProviderBase provider)
    {
        _iconProvider = provider;
        return _iconProvider;
    }

    ~this()
    {
        if (destroyedByGC(this.classinfo.name)) return; // finalized by the GC: report the leak (#975)
        if(_iconProvider) {
            destroy(_iconProvider);
        }
    }
}

unittest {
    // the base Platform.onThemeChanged() drops what the theme's styles cached, for every backend (#1160)
    import dlangui.widgets.styles : useTestTheme;
    import dlangui.graphics.resources : _drawableCache, DrawableCache;
    static class TestWindow : Window {
        int themeChanges; // the base Platform.onThemeChanged() reaches the windows (#1173)
        override void dispatchThemeChanged() { themeChanges++; super.dispatchThemeChanged(); }
        override void show() {}
        override @property dstring windowCaption() const { return null; }
        override @property void windowCaption(dstring caption) {}
        override @property void windowIcon(DrawBufRef icon) {}
        override void invalidate() {}
        override void close() {}
    }
    static class TestPlatform : Platform {
        override Window createWindow(dstring windowCaption, Window parent, uint flags = WindowFlag.Resizable,
                uint width = 0, uint height = 0) { return null; }
        override void closeWindow(Window w) {}
        override int enterMessageLoop() { return 0; }
        override bool hasClipboardText(bool mouseBuffer = false) { return false; }
        override dstring getClipboardText(bool mouseBuffer = false) { return null; }
        override void setClipboardText(dstring text, bool mouseBuffer = false) {}
        override void requestLayout() {}
        TestWindow window;
        override protected void forEachWindow(scope void delegate(Window) dg) { dg(window); }
    }
    // a style is added to the theme below: only to a theme created for this test, it is removed at the end
    if (currentTheme !is null)
        return;
    auto _ = useTestTheme();
    DrawableCache savedDrawables = _drawableCache;
    _drawableCache = new DrawableCache();
    scope (exit) {
        destroy(_drawableCache);
        _drawableCache = savedDrawables;
    }
    static if (!WIDGET_STYLE_CONSOLE) {
        // onThemeChanged() also cleans up the image cache, which console builds don't have
        import dlangui.graphics.resources : _imageCache, ImageCache;
        ImageCache savedImages = _imageCache;
        _imageCache = new ImageCache();
        scope (exit) {
            destroy(_imageCache);
            _imageCache = savedImages;
        }
    }
    auto platform = new TestPlatform();
    scope (exit) destroy(platform);
    platform.window = new TestWindow();
    scope (exit) destroy(platform.window);
    Style style = currentTheme.createSubstyle("test1160").backgroundImageId("#FF0000");
    DrawableRef before = style.backgroundDrawable; // keeps the old object alive for the comparison
    scope (exit) before.clear();
    assert(!before.isNull);
    platform.onThemeChanged();
    DrawableRef after = style.backgroundDrawable;
    scope (exit) after.clear();
    assert(!after.isNull && after.get !is before.get);
    assert(platform.window.themeChanges == 1);
    // without drawable and image caches (no initResourceManagers()) it works too (#1174)
    DrawableCache testDrawables = _drawableCache;
    _drawableCache = null;
    scope (exit) _drawableCache = testDrawables;
    static if (!WIDGET_STYLE_CONSOLE) {
        ImageCache testImages = _imageCache;
        _imageCache = null;
        scope (exit) _imageCache = testImages;
    }
    platform.onThemeChanged();
}

// setSystemScreenDpi() reloads the theme and lays the windows out again only when SCREEN_DPI changes (#1162, #1163)
unittest {
    static class DpiTestPlatform : Platform {
        int themeChanges;
        int layouts;
        override Window createWindow(dstring windowCaption, Window parent, uint flags = WindowFlag.Resizable,
                uint width = 0, uint height = 0) { return null; }
        override void closeWindow(Window w) {}
        override int enterMessageLoop() { return 0; }
        override bool hasClipboardText(bool mouseBuffer = false) { return false; }
        override dstring getClipboardText(bool mouseBuffer = false) { return null; }
        override void setClipboardText(dstring text, bool mouseBuffer = false) {}
        override void requestLayout() { layouts++; }
        override void onThemeChanged() { themeChanges++; }
        override protected void forEachWindow(scope void delegate(Window) dg) {}
    }
    immutable int savedDpi = systemScreenDPI;
    immutable int savedOverride = overrideScreenDPI;
    scope (exit) {
        SCREEN_DPI = savedDpi;
        overrideScreenDPI = savedOverride;
    }
    overrideScreenDPI = 0;
    SCREEN_DPI = 96;
    auto platform = new DpiTestPlatform();
    scope (exit) destroy(platform);
    assert(!platform.setSystemScreenDpi(96) && platform.themeChanges == 0 && platform.layouts == 0);
    assert(platform.setSystemScreenDpi(144) && SCREEN_DPI == 144);
    assert(platform.themeChanges == 1 && platform.layouts == 1);
    static if (!WIDGET_STYLE_CONSOLE) {
        // with an override, SCREEN_DPI stays: nothing to reload
        overrideScreenDPI = 120;
        assert(!platform.setSystemScreenDpi(96) && systemScreenDPI == 96 && SCREEN_DPI == 120);
        assert(platform.themeChanges == 1 && platform.layouts == 1);
    }
}

/// get current platform object instance
@property Platform platform() {
    return Platform.instance;
}

static if (ENABLE_OPENGL) {
    private __gshared bool _OPENGL_ENABLED = true;
    /// check if hardware acceleration is enabled
    @property bool openglEnabled() { return _OPENGL_ENABLED; }
    /// call on app initialization if OpenGL support is detected
    void setOpenglEnabled(bool enabled = true) {
        _OPENGL_ENABLED = enabled;
        if (enabled)
            glyphDestroyCallback = &onGlyphDestroyedCallback;
        else
            glyphDestroyCallback = null;
    }
} else {
    @property bool openglEnabled() { return false; }
    void setOpenglEnabled(bool enabled = true) {
        // ignore
    }
}

static if (BACKEND_CONSOLE) {
    // to remove import
    extern(C) int DLANGUImain(string[] args);
} else {
    version (Windows) {
        // to remove import
        extern(Windows) int DLANGUIWinMain(void* hInstance, void* hPrevInstance,
                                           char* lpCmdLine, int nCmdShow);
        extern(Windows)
            int DLANGUIWinMainProfile(string[] args);
    } else {
        // to remove import
        extern(C) int DLANGUImain(string[] args);
    }
}

/// put "mixin APP_ENTRY_POINT;" to main module of your dlangui based app
mixin template APP_ENTRY_POINT() {
    version (unittest) {
        // no main in unit tests
    } else {
        version (Android) {
            // android_main in the library is the entry point and calls UIAppMain itself
        } else {
            // passes the application's UIAppMain to the backend (#270); the C symbol is the one the application defines
            private void setUIAppMainFunction() {
                import dlangui.platforms.common.platform : uiAppMainFunction, UIAppMain;
                uiAppMainFunction = &UIAppMain;
            }
        }
        static if (BACKEND_CONSOLE) {
            int main(string[] args)
            {
                setUIAppMainFunction();
                return DLANGUImain(args);
            }
        } else {
            /// workaround for link issue when WinMain is located in library
            version(Windows) {
                version (ENABLE_PROFILING) {
                    int main(string[] args)
                    {
                        setUIAppMainFunction();
                        return DLANGUIWinMainProfile(args);
                    }
                } else {
                    extern (Windows) int WinMain(void* hInstance, void* hPrevInstance,
                                                    char* lpCmdLine, int nCmdShow)
                    {
                        setUIAppMainFunction();
                        try {
                            int res = DLANGUIWinMain(hInstance, hPrevInstance,
                                                        lpCmdLine, nCmdShow);
                            return res;
                        } catch (Exception e) {
                            Log.e("Exception: ", e);
                            return 1;
                        }
                    }
                }
            } else {
                version (Android) {
                } else {
                    int main(string[] args)
                    {
                        setUIAppMainFunction();
                        return DLANGUImain(args);
                    }
                }
            }
        }
    }
}

/// initialize font manager on startup
extern(C) bool initFontManager();
/// initialize logging (for win32 - to file ui.log, for other platforms - stderr; log level is TRACE for debug builds, and WARN for release builds)
extern(C) void initLogs();
/// call this when all resources are supposed to be freed to report counts of non-freed resources by type
extern(C) void releaseResourcesOnAppExit();
/// call this on application initialization
extern(C) void initResourceManagers();
/// call this from shared static this()
extern (C) void initSharedResourceManagers();


