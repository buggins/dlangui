module dlangui.platforms.common.platform;

public import dlangui.core.events;
import dlangui.widgets.widget;
import dlangui.graphics.drawbuf;
import std.file;
private import dlangui.graphics.gldrawbuf;

class Window {
    protected int _dx;
    protected int _dy;
    protected Widget _mainWidget;
    @property int width() { return _dx; }
    @property int height() { return _dy; }
    @property Widget mainWidget() { return _mainWidget; }
    @property void mainWidget(Widget widget) { 
        if (_mainWidget !is null)
            _mainWidget.window = null;
        _mainWidget = widget; 
        if (_mainWidget !is null)
            _mainWidget.window = this;
    }
    abstract void show();
    abstract @property string windowCaption();
    abstract @property void windowCaption(string caption);
    void onResize(int width, int height) {
        if (_dx == width && _dy == height)
            return;
        _dx = width;
        _dy = height;
        if (_mainWidget !is null) {
            _mainWidget.measure(_dx, _dy);
            _mainWidget.layout(Rect(0, 0, _dx, _dy));
        }
    }

    long lastDrawTs;

    private void animate(Widget root, long interval) {
        if (root.visibility != Visibility.Visible)
            return;
        for (int i = 0; i < root.childCount; i++)
            animate(root.child(i), interval);
        if (root.animating)
            root.animate(interval);
    }

    void onDraw(DrawBuf buf) {
        if (_mainWidget !is null) {
            bool needDraw = false;
            bool needLayout = false;
            bool animationActive = false;
            checkUpdateNeeded(needDraw, needLayout, animationActive);
            if (needLayout || animationActive)
                needDraw = true;
            long ts = std.datetime.Clock.currStdTime;
            if (animationActive && lastDrawTs != 0) {
                animate(_mainWidget, ts - lastDrawTs);
                // layout required flag could be changed during animate - check again
                checkUpdateNeeded(needDraw, needLayout, animationActive);
            }
            if (needLayout) {
                _mainWidget.measure(_dx, _dy);
                _mainWidget.layout(Rect(0, 0, _dx, _dy));
            }
            _mainWidget.onDraw(buf);
            lastDrawTs = ts;
            if (animationActive)
                scheduleAnimation();
        }
    }

    /// after drawing, call to schedule redraw if animation is active
    void scheduleAnimation() {
        // override if necessary
    }

    protected bool dispatchMouseEvent(Widget root, MouseEvent event) {
        // only route mouse events to visible widgets
        if (root.visibility != Visibility.Visible)
            return false;
        if (!root.isPointInside(event.x, event.y))
            return false;
        // offer event to children first
        for (int i = 0; i < root.childCount; i++) {
            Widget child = root.child(i);
            if (dispatchMouseEvent(child, event))
                return true;
        }
        // if not processed by children, offer event to root
        if (root.onMouseEvent(event)) {
            Log.d("MouseEvent is processed");
            if (event.action == MouseAction.ButtonDown && _mouseCaptureWidget is null) {
                Log.d("Setting active widget");
                _mouseCaptureWidget = root;
            } else if (event.action == MouseAction.Move && _mouseTrackingWidget is null) {
                Log.d("Setting tracking widget");
                _mouseTrackingWidget = root;
            }
            return true;
        }
        return false;
    }

    /// widget which tracks Move events
    protected Widget _mouseTrackingWidget;
    /// widget which tracks all events after processed ButtonDown
    protected Widget _mouseCaptureWidget;
    protected bool _mouseCaptureFocusedOut;
    /// dispatch mouse event to window content widgets
    bool dispatchMouseEvent(MouseEvent event) {
        // ignore events if there is no root
        if (_mainWidget is null)
            return false;

        // check if _mouseCaptureWidget and _mouseTrackingWidget still exist in child of root widget
        if (_mouseCaptureWidget !is null && !_mainWidget.isChild(_mouseCaptureWidget))
            _mouseCaptureWidget = null;
        if (_mouseTrackingWidget !is null && !_mainWidget.isChild(_mouseTrackingWidget))
            _mouseTrackingWidget = null;

        bool res = false;
        if (_mouseCaptureWidget !is null) {
            // try to forward message directly to active widget
            if (event.action == MouseAction.Move) {
                if (!_mouseCaptureWidget.isPointInside(event.x, event.y)) {
                    // point is no more inside of captured widget
                    if (!_mouseCaptureFocusedOut) {
                        // sending FocusOut message
                        event.changeAction(MouseAction.FocusOut);
                        _mouseCaptureFocusedOut = true;
                        return _mouseCaptureWidget.onMouseEvent(event);
                    }
                    return true;
                } else {
                    // point is inside widget
                    if (_mouseCaptureFocusedOut) {
                        event.changeAction(MouseAction.FocusIn); // back in after focus out
                        _mouseCaptureFocusedOut = false;
                    }
                    return _mouseCaptureWidget.onMouseEvent(event);
                }
            } else if (event.action == MouseAction.Leave) {
                if (!_mouseCaptureFocusedOut) {
                    // sending FocusOut message
                    event.changeAction(MouseAction.FocusOut);
                    _mouseCaptureFocusedOut = true;
                    return _mouseCaptureWidget.onMouseEvent(event);
                }
                return true;
            }
            // other messages
            res = _mouseCaptureWidget.onMouseEvent(event);
            if ((event.flags & (MouseFlag.LButton | MouseFlag.MButton | MouseFlag.RButton)) == 0) {
                // usable capturing - no more buttons pressed
                Log.d("unsetting active widget");
                _mouseCaptureWidget = null;
            }
            return res;
        }
        if (event.action == MouseAction.Move && _mouseTrackingWidget !is null) {
            if (!_mouseTrackingWidget.isPointInside(event.x, event.y)) {
                // send Leave message
                MouseEvent leaveEvent = new MouseEvent(event);
                leaveEvent.changeAction(MouseAction.Leave);
                _mouseCaptureWidget.onMouseEvent(event);
                // stop tracking
                _mouseTrackingWidget = null;
            }
        }
        if (!res) {
            res = dispatchMouseEvent(_mainWidget, event);
        }
        return res;
    }
    /// checks content widgets for necessary redraw and/or layout
    protected void checkUpdateNeeded(Widget root, ref bool needDraw, ref bool needLayout, ref bool animationActive) {
        if (!root.visibility == Visibility.Visible)
            return;
        needDraw = root.needDraw || needDraw;
        needLayout = root.needLayout || needLayout;
        animationActive = root.animating || animationActive;
        for (int i = 0; i < root.childCount; i++)
            checkUpdateNeeded(root.child(i), needDraw, needLayout, animationActive);
    }
    /// checks content widgets for necessary redraw and/or layout
    bool checkUpdateNeeded(ref bool needDraw, ref bool needLayout, ref bool animationActive) {
        needDraw = needLayout = animationActive = false;
        if (_mainWidget is null)
            return false;
        checkUpdateNeeded(_mainWidget, needDraw, needLayout, animationActive);
        return needDraw || needLayout || animationActive;
    }
    /// requests update for window (unless force is true, update will be performed only if layout, redraw or animation is required).
    void update(bool force = false) {
        if (_mainWidget is null)
            return;
        bool needDraw = false;
        bool needLayout = false;
        bool animationActive = false;
        if (checkUpdateNeeded(needDraw, needLayout, animationActive) || force) {
            Log.d("Requesting update");
            invalidate();
        }
        Log.d("checkUpdateNeeded returned needDraw=", needDraw, " needLayout=", needLayout, " animationActive=", animationActive);
    }
    /// request window redraw
    abstract void invalidate();
}

class Platform {
    static __gshared Platform _instance;
    static void setInstance(Platform instance) {
        _instance = instance;
    }
    static Platform instance() {
        return _instance;
    }
    abstract Window createWindow(string windowCaption, Window parent);
    abstract int enterMessageLoop();
}

version (USE_OPENGL) {
    private __gshared bool _OPENGL_ENABLED = false;
    /// check if hardware acceleration is enabled
    @property bool openglEnabled() { return _OPENGL_ENABLED; }
    /// call on app initialization if OpenGL support is detected
    void setOpenglEnabled() {
        _OPENGL_ENABLED = true;
	    glyphDestroyCallback = &onGlyphDestroyedCallback;
    }
}

version (Windows) {
    immutable char PATH_DELIMITER = '\\';
} else {
    immutable char PATH_DELIMITER = '/';
}

/// returns current executable path only, including last path delimiter
string exePath() {
    string path = thisExePath();
    int lastSlash = 0;
    for (int i = 0; i < path.length; i++)
        if (path[i] == PATH_DELIMITER)
            lastSlash = i;
    return path[0 .. lastSlash + 1];
}
