module dlangui.platforms.android.androidapp;

version(Android):

import core.stdc.stdlib : malloc;
import core.stdc.string : memset;
import dlangui.core.logger;

import dlangui.widgets.styles;
import dlangui.widgets.widget;
import dlangui.graphics.drawbuf;
import dlangui.graphics.gldrawbuf;
import dlangui.graphics.glsupport;
import dlangui.platforms.common.platform;

import android.input, android.looper : ALooper_pollAll;
import android.native_window : ANativeWindow_setBuffersGeometry;
import android.configuration;
import android.log, android.android_native_app_glue;

/**
 * Window abstraction layer. Widgets can be shown only inside window.
 *
 */
class AndroidWindow : Window {
    // Abstract methods : override in platform implementatino

    /// show window
    override void show() {
        // TODO
        _visible = true;
        _platform.drawWindow(this);
    }
    bool _visible;

    override @property Window parentWindow() {
        return null;
    }

    override protected void handleWindowActivityChange(bool isWindowActive) {
        super.handleWindowActivityChange(isWindowActive);
    }

    override @property bool isActive() {
        //todo:
        return true;
    }

    protected dstring _caption;
    /// returns window caption
    override @property dstring windowCaption() const {
        return _caption;
    }
    /// sets window caption
    override @property void windowCaption(dstring caption) {
        _caption = caption;
    }
    /// sets window icon
    override @property void windowIcon(DrawBufRef icon) {
        // not supported
    }
    uint _lastRedrawEventCode;
    /// request window redraw
    override void invalidate() {
        _platform.sendRedrawEvent(this, ++_lastRedrawEventCode);
    }

    void processRedrawEvent(uint code) {
        //if (code == _lastRedrawEventCode)
        //    redraw();
    }
    /// close window
    override void close() {
        _platform.closeWindow(this);
    }

    protected AndroidPlatform _platform;
    this(AndroidPlatform platform) {
        super();
        _platform = platform;
    }

    ~this() {
    }

    /// after drawing, call to schedule redraw if animation is active
    override void scheduleAnimation() {
        // override if necessary
        // TODO
    }

    ushort lastFlags;
    short lastx;
    short lasty;
    protected ButtonDetails _lbutton;
    protected ButtonDetails _mbutton;
    protected ButtonDetails _rbutton;
    void processMouseEvent(MouseAction action, uint button, uint state, int x, int y) {
        MouseEvent event = null;
        lastFlags = 0; //convertMouseFlags(state);
        if (_keyFlags & KeyFlag.Shift)
            lastFlags |= MouseFlag.Shift;
        if (_keyFlags & KeyFlag.Control)
            lastFlags |= MouseFlag.Control;
        if (_keyFlags & KeyFlag.Alt)
            lastFlags |= MouseFlag.Alt;
        lastx = cast(short)x;
        lasty = cast(short)y;
        MouseButton btn = MouseButton.Left; // convertMouseButton(button);
        event = new MouseEvent(action, btn, lastFlags, lastx, lasty);
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
                invalidate();
            }
        }
    }
    uint _keyFlags;

    /**
     * Process the next input event.
     */
    int handle_input(AInputEvent* event) {
        Log.i("handle input, event=", AInputEvent_getType(event));
        auto et = AInputEvent_getType(event);
        if (et == AINPUT_EVENT_TYPE_MOTION) {
            auto action = AMotionEvent_getAction(event);
            int x = cast(int)AMotionEvent_getX(event, 0);
            int y = cast(int)AMotionEvent_getY(event, 0);
            switch(action) {
                case AMOTION_EVENT_ACTION_DOWN:
                    processMouseEvent(MouseAction.ButtonDown, 0, 0, x, y);
                    break;
                case AMOTION_EVENT_ACTION_UP:
                    processMouseEvent(MouseAction.ButtonUp, 0, 0, x, y);
                    break;
                case AMOTION_EVENT_ACTION_MOVE:
                    processMouseEvent(MouseAction.Move, 0, 0, x, y);
                    break;
                case AMOTION_EVENT_ACTION_CANCEL:
                    processMouseEvent(MouseAction.Cancel, 0, 0, x, y);
                    break;
                case AMOTION_EVENT_ACTION_OUTSIDE:
                    //processMouseEvent(MouseAction.Down, 0, 0, x, y);
                    break;
                case AMOTION_EVENT_ACTION_POINTER_DOWN:
                    processMouseEvent(MouseAction.ButtonDown, 0, 0, x, y);
                    break;
                case AMOTION_EVENT_ACTION_POINTER_UP:
                    processMouseEvent(MouseAction.ButtonUp, 0, 0, x, y);
                    break;
                default:
                    break;
            }
            return 1;
        } else if (et == AINPUT_EVENT_TYPE_KEY) {
            Log.d("AINPUT_EVENT_TYPE_KEY");
            return 0;
        }
        return 0;
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
class AndroidPlatform : Platform {

    protected AndroidWindow[] _windows;
    protected AndroidWindow _activeWindow;
    engine _engine;
    protected android_app* _appstate;
    protected EGLDisplay _display;
    protected EGLSurface _surface;
    protected EGLContext _context;
    protected int _width;
    protected int _height;

    this(android_app* state) {
        Log.d("AndroidPlatform.this()");
        _appstate = state;
        memset(&_engine, 0, engine.sizeof);
        Log.d("AndroidPlatform.this() - setting handlers");
        state.userData = cast(void*)this;
        state.onAppCmd = &engine_handle_cmd;
        state.onInputEvent = &engine_handle_input;

        //Log.d("AndroidPlatform.this() - restoring saved state");
        //if (state.savedState != null) {
        //    // We are starting with a previous saved state; restore from it.
        //    _engine.state = *cast(saved_state*)state.savedState;
        //}
        Log.d("AndroidPlatform.this() - done");
    }

    ~this() {
        foreach_reverse(w; _windows) {
            destroy(w);
        }
        _windows.length = 0;
        termDisplay();
    }


    /**
     * Initialize an EGL context for the current display.
     */
    int initDisplay() {
        // initialize OpenGL ES and EGL
        Log.i("initDisplay");

        /*
         * Here specify the attributes of the desired configuration.
         * Below, we select an EGLConfig with at least 8 bits per color
         * component compatible with on-screen windows
         */
        const(EGLint)[9] attribs = [
            EGL_SURFACE_TYPE, EGL_WINDOW_BIT,
            EGL_BLUE_SIZE, 8,
            EGL_GREEN_SIZE, 8,
            EGL_RED_SIZE, 8,
            EGL_NONE
        ];
        EGLint w, h, dummy, format;
        EGLint numConfigs;
        EGLConfig config;
        EGLSurface surface;
        EGLContext context;

        EGLDisplay display = eglGetDisplay(EGL_DEFAULT_DISPLAY);

        eglInitialize(display, null, null);

        /* Here, the application chooses the configuration it desires. In this
         * sample, we have a very simplified selection process, where we pick
          * the first EGLConfig that matches our criteria */
        eglChooseConfig(display, attribs.ptr, &config, 1, &numConfigs);

        /* EGL_NATIVE_VISUAL_ID is an attribute of the EGLConfig that is
         * guaranteed to be accepted by ANativeWindow_setBuffersGeometry().
          * As soon as we picked a EGLConfig, we can safely reconfigure the
         * ANativeWindow buffers to match, using EGL_NATIVE_VISUAL_ID. */
        eglGetConfigAttrib(display, config, EGL_NATIVE_VISUAL_ID, &format);

        ANativeWindow_setBuffersGeometry(_appstate.window, 0, 0, format);

        surface = eglCreateWindowSurface(display, config, _appstate.window, null);
        EGLint[3] contextAttrs = [EGL_CONTEXT_CLIENT_VERSION, 3, EGL_NONE];
        context = eglCreateContext(display, config, null, contextAttrs.ptr);

        if (eglMakeCurrent(display, surface, surface, context) == EGL_FALSE) {
            LOGW("Unable to eglMakeCurrent");
            return -1;
        }

        eglQuerySurface(display, surface, EGL_WIDTH, &w);
        eglQuerySurface(display, surface, EGL_HEIGHT, &h);

        Log.i("surface created: ", _width, "x", _height);

        _display = display;
        _context = context;
        _surface = surface;
        _width = w;
        _height = h;
        _engine.state.angle = 0;

        // Initialize GL state.
        //glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_FASTEST);
        glEnable(GL_CULL_FACE);
        //glShadeModel(GL_SMOOTH);
        glDisable(GL_DEPTH_TEST);

        Log.i("calling initGLSupport");
        initGLSupport(false);

        return 0;
    }


    /**
     * Tear down the EGL context currently associated with the display.
     */
    void termDisplay() {
        Log.i("termDisplay");
        if (_display != EGL_NO_DISPLAY) {
            eglMakeCurrent(_display, EGL_NO_SURFACE, EGL_NO_SURFACE, EGL_NO_CONTEXT);
            if (_context != EGL_NO_CONTEXT) {
                eglDestroyContext(_display, _context);
            }
            if (_surface != EGL_NO_SURFACE) {
                eglDestroySurface(_display, _surface);
            }
            eglTerminate(_display);
        }
        //_engine.animating = 0;
        _display = EGL_NO_DISPLAY;
        _context = EGL_NO_CONTEXT;
        _surface = EGL_NO_SURFACE;
    }

    /**
     * Process the next input event.
     */
    int handle_input(AInputEvent* event) {
        Log.i("handle input, event=", AInputEvent_getType(event));
        auto w = activeWindow;
        if (!w)
            return 0;
        return w.handle_input(event);
    }


    bool _appFocused;
    /**
     * Process the next main command.
     */
    void handle_cmd(int cmd) {
        if (_appstate.destroyRequested != 0) {
            Log.w("handle_cmd: destroyRequested is set!!!");
        }
        switch (cmd) {
            case APP_CMD_SAVE_STATE:
                Log.d("APP_CMD_SAVE_STATE");
                // The system has asked us to save our current state.  Do so.
                _appstate.savedState = malloc(saved_state.sizeof);
                *(cast(saved_state*)_appstate.savedState) = _engine.state;
                _appstate.savedStateSize = saved_state.sizeof;
                break;
            case APP_CMD_INIT_WINDOW:
                Log.d("APP_CMD_INIT_WINDOW");
                // The window is being shown, get it ready.
                if (_appstate.window != null) {
                    initDisplay();
                    drawWindow();
                }
                break;
            case APP_CMD_TERM_WINDOW:
                Log.d("APP_CMD_TERM_WINDOW");
                // The window is being hidden or closed, clean it up.
                termDisplay();
                break;
            case APP_CMD_GAINED_FOCUS:
                Log.d("APP_CMD_GAINED_FOCUS");
                // When our app gains focus
                _appFocused = true;
                break;
            case APP_CMD_LOST_FOCUS:
                Log.d("APP_CMD_LOST_FOCUS");
                // When our app loses focus
                // This is to avoid consuming battery while not being used.
                // Also stop animating.
                //_engine.animating = 0;
                _appFocused = false;
                drawWindow();
                break;
            case APP_CMD_INPUT_CHANGED:
                Log.d("APP_CMD_INPUT_CHANGED");
                break;
            case APP_CMD_WINDOW_RESIZED:
                Log.d("APP_CMD_WINDOW_RESIZED");
                break;
            case APP_CMD_WINDOW_REDRAW_NEEDED:
                Log.d("APP_CMD_WINDOW_REDRAW_NEEDED");
                drawWindow();
                break;
            case APP_CMD_CONTENT_RECT_CHANGED:
                Log.d("APP_CMD_CONTENT_RECT_CHANGED");
                drawWindow();
                break;
            case APP_CMD_CONFIG_CHANGED:
                Log.d("APP_CMD_CONFIG_CHANGED");
                break;
            case APP_CMD_LOW_MEMORY:
                Log.d("APP_CMD_LOW_MEMORY");
                break;
            case APP_CMD_START:
                Log.d("APP_CMD_START");
                break;
            case APP_CMD_RESUME:
                Log.d("APP_CMD_RESUME");
                break;
            case APP_CMD_PAUSE:
                Log.d("APP_CMD_PAUSE");
                break;
            case APP_CMD_STOP:
                Log.d("APP_CMD_STOP");
                break;
            case APP_CMD_DESTROY:
                Log.d("APP_CMD_DESTROY");
                break;
            default:
                Log.i("unknown APP_CMD_XXX=", cmd);
                break;
        }
    }

    @property bool isAnimationActive() {
        auto w = activeWindow;
        return (w && w.isAnimationActive && _appFocused);
    }



    void sendRedrawEvent(AndroidWindow w, uint redrawEventCode) {
        import core.stdc.stdio;
        import core.sys.posix.unistd;
        if (w && w is activeWindow) {
            // request update
            _appstate.redrawNeeded = true;
            Log.d("sending APP_CMD_WINDOW_REDRAW_NEEDED");
            ubyte cmd = APP_CMD_WINDOW_REDRAW_NEEDED;
            write(_appstate.msgwrite, &cmd, cmd.sizeof);
        }
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
    override Window createWindow(dstring windowCaption, Window parent, uint flags = WindowFlag.Resizable, uint width = 0, uint height = 0) {
        AndroidWindow w = new AndroidWindow(this);
        _windows ~= w;
        return w;
    }

    /**
     * close window
     *
     * Closes window earlier created with createWindow()
     */
    override  void closeWindow(Window w) {
        import std.algorithm : remove;
        for (int i = 0; i < _windows.length; i++) {
            if (_windows[i] is w) {
                _windows = _windows.remove(i);
                break;
            }
        }
        if (_windows.length == 0) {
            _appstate.destroyRequested = true;
        }
    }

    @property AndroidWindow activeWindow() {
        for (int i = cast(int)_windows.length - 1; i >= 0; i++)
            if (_windows[i]._visible)
                return _windows[i];
        return null;
    }

    GLDrawBuf _drawbuf;
    void drawWindow(AndroidWindow w = null) {
        Log.i("drawWindow");
        if (w is null)
            w = activeWindow;
        else if (!(activeWindow is w))
            return;
        if (_display == null) {
            // No display.
            return;
        }

        // Just fill the screen with a color.
        if (!w) {
            glClearColor(0, 0, 0, 1);
            glClear(GL_COLOR_BUFFER_BIT);
        } else {
            w.onResize(_width, _height);
            glDisable(GL_DEPTH_TEST);
            glViewport(0, 0, _width, _height);
            float a = 1.0f;
            float r = ((w.backgroundColor >> 16) & 255) / 255.0f;
            float g = ((w.backgroundColor >> 8) & 255) / 255.0f;
            float b = ((w.backgroundColor >> 0) & 255) / 255.0f;
            glClearColor(r, g, b, a);
            glClear(GL_COLOR_BUFFER_BIT);
            if (!_drawbuf)
                _drawbuf = new GLDrawBuf(_width, _height);
            _drawbuf.resize(_width, _height);
            _drawbuf.beforeDrawing();
            w.onDraw(_drawbuf);
            _drawbuf.afterDrawing();
        }

        eglSwapBuffers(_display, _surface);
    }

    /**
     * Starts application message loop.
     *
     * When returned from this method, application is shutting down.
     */
    override int enterMessageLoop() {
        while (1) {
            // Read all pending events.
            int ident;
            int events;
            android_poll_source* source;

            // If not animating, we will block forever waiting for events.
            // If animating, we loop until all events are read, then continue
            // to draw the next frame of animation.
            while ((ident=ALooper_pollAll(isAnimationActive ? 0 : -1, null, &events,
                        cast(void**)&source)) >= 0) {

                // Process this event.
                if (source != null) {
                    source.process(_appstate, source);
                }

                // If a sensor has data, process it now.
                if (ident == LOOPER_ID_USER) {
                    /*
                    if (_accelerometerSensor != null) {
                        ASensorEvent event;
                        while (ASensorEventQueue_getEvents(_sensorEventQueue,
                                &event, 1) > 0) {
                            LOGI("accelerometer: x=%f y=%f z=%f",
                                event.acceleration.x, event.acceleration.y,
                                event.acceleration.z);
                        }
                    }
                    */
                }

                // Check if we are exiting.
                if (_appstate.destroyRequested != 0) {
                    Log.w("destroyRequested is set: exiting message loop");
                    return 0;
                }
            }

            if (isAnimationActive) {
                // Done with events; draw next animation frame.
                _engine.state.angle += .01f;
                if (_engine.state.angle > 1) {
                    _engine.state.angle = 0;
                }

                // Drawing is throttled to the screen update rate, so there
                // is no need to do timing here.
                drawWindow();
            }
        }
    }

    protected dstring _clipboardText;

    /// check has clipboard text
    override bool hasClipboardText(bool mouseBuffer = false) {
        return (_clipboardText.length > 0);
    }

    /// retrieves text from clipboard (when mouseBuffer == true, use mouse selection clipboard - under linux)
    override dstring getClipboardText(bool mouseBuffer = false) {
        return _clipboardText;
    }

    /// sets text to clipboard (when mouseBuffer == true, use mouse selection clipboard - under linux)
    override void setClipboardText(dstring text, bool mouseBuffer = false) {
        _clipboardText = text;
    }

    /// calls request layout for all windows
    override void requestLayout() {
    }

    /// handle theme change: e.g. reload some themed resources
    override void onThemeChanged() {
        super.onThemeChanged();
        // override and call dispatchThemeChange for all windows
    }

}



/**
 * Our saved state data.
 */
struct saved_state {
    float angle;
    float x;
    float y;
}

/**
 * Shared state for our app.
 */
struct engine {
    //int animating;
    saved_state state;
}

/**
 * Process the next input event.
 */
extern(C) int engine_handle_input(android_app* app, AInputEvent* event) {
    AndroidPlatform p = cast(AndroidPlatform)app.userData;
    return p.handle_input(event);
}

/**
 * Process the next main command.
 */
extern(C) void engine_handle_cmd(android_app* app, int cmd) {
    AndroidPlatform p = cast(AndroidPlatform)app.userData;
    p.handle_cmd(cmd);
}

void main(){}

int getDensityDpi(android_app * app) {
    AConfiguration * config = AConfiguration_new();
    AConfiguration_fromAssetManager(config, app.activity.assetManager);
    int res = AConfiguration_getDensity(config);
    AConfiguration_delete(config);
    return res;
}

__gshared AndroidPlatform _platform;

/**
 * This is the main entry point of a native application that is using
 * android_native_app_glue.  It runs in its own thread, with its own
 * event loop for receiving input events and doing other things.
 */
extern (C) void android_main(android_app* state) {
    //import dlangui.platforms.common.startup : initLogs, initFontManager, initResourceManagers, ;
    LOGI("Inside android_main");
    initLogs();
    Log.i("Testing logger - Log.i");
    Log.fi("Testing logger - Log.fi %d %s", 12345, "asdfgh");

    if (!initFontManager()) {
        Log.e("******************************************************************");
        Log.e("No font files found!!!");
        Log.e("Currently, only hardcoded font paths implemented.");
        Log.e("******************************************************************");
        assert(false);
    }
    initResourceManagers();
    SCREEN_DPI = getDensityDpi(state);
    TOUCH_MODE = true;
    Log.i("SCREEN_DPI=", SCREEN_DPI);

    //currentTheme = createDefaultTheme();


    _platform = new AndroidPlatform(state);
    Platform.setInstance(_platform);

    _platform.uiTheme = "theme_default";

    // Make sure glue isn't stripped.
    app_dummy();

    int res = 0;

    version (unittest) {
    } else {
        Log.i("Calling UIAppMain");
        res = UIAppMain([]);
        Log.i("UIAppMain returned with resultCode=", res);
    }

    // loop waiting for stuff to do.
    Log.d("Destroying Android platform");
    Platform.setInstance(null);

    releaseResourcesOnAppExit();

    Log.d("Exiting main");


}

