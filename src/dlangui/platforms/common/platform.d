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
import dlangui.graphics.drawbuf;
import dlangui.core.stdaction;
import dlangui.core.asyncsocket;

static if (ENABLE_OPENGL) {
    private import dlangui.graphics.gldrawbuf;
}
private import std.algorithm;
private import core.sync.mutex;
private import std.string;

/// entry point - declare such function to use as main for dlangui app
extern(C) int UIAppMain(string[] args);


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

/// Window state signal listener
interface OnWindowStateHandler {
    /// signal listener - called when state of window is changed
    bool onWindowStateChange(Window window, WindowState winState, Rect rect);
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

    override bool opEquals(Object obj) const {
        TimerInfo b = cast(TimerInfo)obj;
        if (!b)
            return false;
        return b._nextTimestamp == _nextTimestamp;
    }
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
    protected int _dx;
    protected int _dy;
    protected uint _keyboardModifiers;
    protected uint _backgroundColor;
    protected Widget _mainWidget;
    protected EventList _eventList;
    protected uint _flags;

    @property uint flags() { return _flags; }
    @property uint backgroundColor() const { return _backgroundColor; }
    @property void backgroundColor(uint color) { _backgroundColor = color; }
    @property int width() const { return _dx; }
    @property int height() const { return _dy; }
    @property uint keyboardModifiers() const { return _keyboardModifiers; }
    @property Widget mainWidget() { return _mainWidget; }
    @property void mainWidget(Widget widget) { 
        if (_mainWidget !is null) {
            _mainWidget.window = null;
            destroy(_mainWidget);
        }
        _mainWidget = widget;
        if (_mainWidget !is null)
            _mainWidget.window = this;
    }

    protected Rect _caretRect;
    /// blinking caret position (empty rect if no blinking caret)
    @property void caretRect(Rect rc) { _caretRect = rc; }
    @property Rect caretRect() { return _caretRect; }

    protected bool _caretReplace;
    /// blinking caret is in Replace mode if true, insert mode if false
    @property void caretReplace(bool flg) { _caretReplace = flg; }
    @property bool caretReplace() { return _caretReplace; }

    // Abstract methods : override in platform implementatino

    /// show window
    abstract void show();
    /// returns window caption
    abstract @property dstring windowCaption();
    /// sets window caption
    abstract @property void windowCaption(dstring caption);
    /// sets window icon
    abstract @property void windowIcon(DrawBufRef icon);
    /// request window redraw
    abstract void invalidate();
    /// close window
    abstract void close();

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
        if (newState != WindowState.unspecified)
            _windowState = newState;
        if (newWindowRect != RECT_VALUE_IS_NOT_SET)
            _windowRect = newWindowRect;
        if (windowStateChanged.assigned)
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

    /// requests layout for main widget and popups
    void requestLayout() {
        if (_mainWidget)
            _mainWidget.requestLayout();
        foreach(p; _popups)
            p.requestLayout();
        if (_tooltip.popup)
            _tooltip.popup.requestLayout();
    }
    void measure() {
        if (_mainWidget !is null) {
            _mainWidget.measure(_dx, _dy);
        }
        foreach(p; _popups)
            p.measure(_dx, _dy);
        if (_tooltip.popup)
            _tooltip.popup.measure(_dx, _dy);
    }
    void layout() {
        Rect rc = Rect(0, 0, _dx, _dy);
        if (_mainWidget !is null) {
            _mainWidget.layout(rc);
        }
        foreach(p; _popups)
            p.layout(rc);
        if (_tooltip.popup)
            _tooltip.popup.layout(rc);
    }
    void onResize(int width, int height) {
        if (_dx == width && _dy == height)
            return;
        _dx = width;
        _dy = height;
        if (_mainWidget !is null) {
            Log.d("onResize ", _dx, "x", _dy);
            long measureStart = currentTimeMillis;
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

    /// returns true if widget is child of either main widget or one of popups
    bool isChild(Widget w) {
        if (_mainWidget !is null && _mainWidget.isChild(w))
            return true;
        foreach(p; _popups)
            if (p.isChild(w))
                return true;
        if (_tooltip.popup)
            if (_tooltip.popup.isChild(w))
                return true;
        return false;
    }

    private long lastDrawTs;

    this() {
        _eventList = new EventList();
        _timerQueue = new TimerQueue();
        _backgroundColor = 0xFFFFFF;
        if (currentTheme)
            _backgroundColor = currentTheme.customColor(STYLE_COLOR_WINDOW_BACKGROUND);
    }
    ~this() {
        debug Log.d("Destroying window");
        if (_onClose)
            _onClose();
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
        destroy(_eventList);
        destroy(_timerQueue);
        _eventList = null;
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
        if (modal) {
            if (dispatchKeyEvent(modal, event))
                return res;
            return modal.onKeyEvent(event) || res;
        } else if (_mainWidget) {
            if (dispatchKeyEvent(_mainWidget, event))
                return res;
            return _mainWidget.onKeyEvent(event) || res;
        }
        return res;
    }

    protected bool dispatchMouseEvent(Widget root, MouseEvent event, ref bool cursorIsSet) {
        // only route mouse events to visible widgets
        if (root.visibility != Visibility.Visible)
            return false;
        if (!root.isPointInside(event.x, event.y))
            return false;
        // offer event to children first
        for (int i = 0; i < root.childCount; i++) {
            Widget child = root.child(i);
            if (dispatchMouseEvent(child, event, cursorIsSet))
                return true;
        }
        if (event.action == MouseAction.Move && !cursorIsSet) {
            uint cursorType = root.getCursorType(event.x, event.y);
            if (cursorType != CursorType.Parent) {
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
        if (_mainWidget)
            return _mainWidget.handleAction(action);
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
        if (_mainWidget)
            _mainWidget.onThemeChanged();
            // draw popups
        foreach(p; _popups) {
            p.onThemeChanged();
        }
        if (_tooltip.popup)
            _tooltip.popup.onThemeChanged();
        if (currentTheme) {
            _backgroundColor = currentTheme.customColor(STYLE_COLOR_WINDOW_BACKGROUND);
        }
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
                    if (p.onMouseEventOutside(event)) // stop loop when true is returned, but allow other main widget to handle event
                        break;
                } else {
                    if (dispatchMouseEvent(p, event, cursorIsSet))
                        return true;
                }
            }
            if (!modal)
                res = dispatchMouseEvent(_mainWidget, event, cursorIsSet);
            else
                res = dispatchMouseEvent(modal, event, cursorIsSet);
        }
        return res || processed || _mainWidget.needDraw;
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
        showMessageBox(UIString(title), UIString(message), actions, defaultActionIndex, handler);
    }

    static if (BACKEND_GUI) {
        void showInputBox(UIString title, UIString message, dstring initialText, void delegate(dstring result) handler) {
            import dlangui.dialogs.inputbox;
            InputBox dlg = new InputBox(title, message, this, initialText, handler);
            dlg.show();
        }
    }

    void showInputBox(dstring title, dstring message, dstring initialText, void delegate(dstring result) handler) {
        showInputBox(UIString(title), UIString(message), initialText, handler);
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
        Log.w("showInFileManager is not implemented for current platform");
        return false;
    }

    /// handle theme change: e.g. reload some themed resources
    void onThemeChanged() {
        // override and call dispatchThemeChange for all windows
    }

}

/// get current platform object instance
@property Platform platform() {
    return Platform.instance;
}

static if (ENABLE_OPENGL) {
    private __gshared bool _OPENGL_ENABLED = false;
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
    } else {
        // to remove import
        extern(C) int DLANGUImain(string[] args);
    }
}

/// put "mixin APP_ENTRY_POINT;" to main module of your dlangui based app
mixin template APP_ENTRY_POINT() {
    static if (BACKEND_CONSOLE) {
        int main(string[] args)
        {
            return DLANGUImain(args);
        }
    } else {
        /// workaround for link issue when WinMain is located in library
        version(Windows) {
            extern (Windows) int WinMain(void* hInstance, void* hPrevInstance,
                                         char* lpCmdLine, int nCmdShow)
            {
                try {
                    int res = DLANGUIWinMain(hInstance, hPrevInstance,
                                             lpCmdLine, nCmdShow);
                    return res;
                } catch (Exception e) {
                    Log.e("Exception: ", e);
                    return 1;
                }
            }
        } else {
            version (Android) {
            } else {
                int main(string[] args)
                {
                    return DLANGUImain(args);
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


