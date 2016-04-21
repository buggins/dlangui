module dlangui.platforms.android.androidapp;

version(Android):

import core.stdc.stdlib : malloc;
import core.stdc.string : memset;
import dlangui.core.logger;

import dlangui.widgets.styles;
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

	protected dstring _caption;
	/// returns window caption
	override @property dstring windowCaption() {
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
	/// request window redraw
	override void invalidate() {
	}
	/// close window
	override void close() {
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
		_appstate = state;
		memset(&_engine, 0, engine.sizeof);
		state.userData = cast(void*)this;
		state.onAppCmd = &engine_handle_cmd;
		state.onInputEvent = &engine_handle_input;

		if (state.savedState != null) {
			// We are starting with a previous saved state; restore from it.
			_engine.state = *cast(saved_state*)state.savedState;
		}
		
	}

	~this() {
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
		_engine.animating = 0;
		_display = EGL_NO_DISPLAY;
		_context = EGL_NO_CONTEXT;
		_surface = EGL_NO_SURFACE;
	}

	/**
 	* Process the next input event.
 	*/
	int handle_input(AInputEvent* event) {
		Log.i("handle input, event=", AInputEvent_getType(event));
		if (AInputEvent_getType(event) == AINPUT_EVENT_TYPE_MOTION) {
			_engine.animating = 1;
			_engine.state.x = AMotionEvent_getX(event, 0);
			_engine.state.y = AMotionEvent_getY(event, 0);
			return 1;
		}
		return 0;
	}
	
	/**
	 * Process the next main command.
	 */
	void handle_cmd(int cmd) {
		Log.i("handle cmd=", cmd);
		switch (cmd) {
			case APP_CMD_SAVE_STATE:
				// The system has asked us to save our current state.  Do so.
				_appstate.savedState = malloc(saved_state.sizeof);
				*(cast(saved_state*)_appstate.savedState) = _engine.state;
				_appstate.savedStateSize = saved_state.sizeof;
				break;
			case APP_CMD_INIT_WINDOW:
				// The window is being shown, get it ready.
				if (_appstate.window != null) {
					initDisplay();
					drawWindow();
				}
				break;
			case APP_CMD_TERM_WINDOW:
				// The window is being hidden or closed, clean it up.
				termDisplay();
				break;
			case APP_CMD_GAINED_FOCUS:
				// When our app gains focus
				break;
			case APP_CMD_LOST_FOCUS:
				// When our app loses focus
				// This is to avoid consuming battery while not being used.
				// Also stop animating.
				_engine.animating = 0;
				drawWindow();
				break;
			default:
				break;
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
			while ((ident=ALooper_pollAll(_engine.animating ? 0 : -1, null, &events,
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
					return 0;
				}
			}
			
			if (_engine.animating) {
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
    int animating;
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

    currentTheme = createDefaultTheme();

	_platform = new AndroidPlatform(state);
	Platform.setInstance(_platform);


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

