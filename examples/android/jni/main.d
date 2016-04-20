/*
 * Copyright (C) 2010 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

import core.stdc.stdlib : malloc;
import core.stdc.string : memset;
import dlangui.core.logger;

import dlangui.widgets.styles;
import dlangui.graphics.drawbuf;
//import dlangui.widgets.widget;
import dlangui.platforms.common.platform;

import EGL.eglplatform : EGLint;
import EGL.egl, GLES.gl;

import android.input, android.looper : ALooper_pollAll;
import android.native_window : ANativeWindow_setBuffersGeometry;
import android.sensor, android.log, android.android_native_app_glue;


/**
 * Window abstraction layer. Widgets can be shown only inside window.
 * 
 */
class AndroidWindow : Window {
	// Abstract methods : override in platform implementatino
	
	/// show window
	override void show() {
		// TODO
	}

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
	this(android_app* state) {
		_appstate = state;
		memset(&_engine, 0, engine.sizeof);
		state.userData = cast(void*)this;
		state.onAppCmd = &engine_handle_cmd;
		state.onInputEvent = &engine_handle_input;
		_engine.app = state;
		
		// Prepare to monitor accelerometer
		_engine.sensorManager = ASensorManager_getInstance();
		_engine.accelerometerSensor = ASensorManager_getDefaultSensor(_engine.sensorManager,
			ASENSOR_TYPE_ACCELEROMETER);
		_engine.sensorEventQueue = ASensorManager_createEventQueue(_engine.sensorManager,
			state.looper, LOOPER_ID_USER, null, null);
		
		if (state.savedState != null) {
			// We are starting with a previous saved state; restore from it.
			_engine.state = *cast(saved_state*)state.savedState;
		}
		
	}

	~this() {
		engine_term_display();
	}


	/**
 	* Initialize an EGL context for the current display.
 	*/
	int engine_init_display() {
		// initialize OpenGL ES and EGL
		
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
		
		ANativeWindow_setBuffersGeometry(_engine.app.window, 0, 0, format);
		
		surface = eglCreateWindowSurface(display, config, _engine.app.window, null);
		context = eglCreateContext(display, config, null, null);
		
		if (eglMakeCurrent(display, surface, surface, context) == EGL_FALSE) {
			LOGW("Unable to eglMakeCurrent");
			return -1;
		}
		
		eglQuerySurface(display, surface, EGL_WIDTH, &w);
		eglQuerySurface(display, surface, EGL_HEIGHT, &h);
		
		_engine.display = display;
		_engine.context = context;
		_engine.surface = surface;
		_engine.width = w;
		_engine.height = h;
		_engine.state.angle = 0;
		
		// Initialize GL state.
		glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_FASTEST);
		glEnable(GL_CULL_FACE);
		//glShadeModel(GL_SMOOTH);
		glDisable(GL_DEPTH_TEST);
		
		return 0;
	}
	
	/**
 	* Just the current frame in the display.
 	*/
	void engine_draw_frame() {
		if (_engine.display == null) {
			// No display.
			return;
		}
		
		// Just fill the screen with a color.
		glClearColor(_engine.state.x/_engine.width, _engine.state.angle,
			_engine.state.y/_engine.height, 1);
		glClear(GL_COLOR_BUFFER_BIT);
		
		eglSwapBuffers(_engine.display, _engine.surface);
	}
	
	/**
	 * Tear down the EGL context currently associated with the display.
	 */
	void engine_term_display() {
		if (_engine.display != EGL_NO_DISPLAY) {
			eglMakeCurrent(_engine.display, EGL_NO_SURFACE, EGL_NO_SURFACE, EGL_NO_CONTEXT);
			if (_engine.context != EGL_NO_CONTEXT) {
				eglDestroyContext(_engine.display, _engine.context);
			}
			if (_engine.surface != EGL_NO_SURFACE) {
				eglDestroySurface(_engine.display, _engine.surface);
			}
			eglTerminate(_engine.display);
		}
		_engine.animating = 0;
		_engine.display = EGL_NO_DISPLAY;
		_engine.context = EGL_NO_CONTEXT;
		_engine.surface = EGL_NO_SURFACE;
	}

	/**
 	* Process the next input event.
 	*/
	int handle_input(AInputEvent* event) {
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
		switch (cmd) {
			case APP_CMD_SAVE_STATE:
				// The system has asked us to save our current state.  Do so.
				_engine.app.savedState = malloc(saved_state.sizeof);
				*(cast(saved_state*)_engine.app.savedState) = _engine.state;
				_engine.app.savedStateSize = saved_state.sizeof;
				break;
			case APP_CMD_INIT_WINDOW:
				// The window is being shown, get it ready.
				if (_engine.app.window != null) {
					engine_init_display();
					engine_draw_frame();
				}
				break;
			case APP_CMD_TERM_WINDOW:
				// The window is being hidden or closed, clean it up.
				engine_term_display();
				break;
			case APP_CMD_GAINED_FOCUS:
				// When our app gains focus, we start monitoring the accelerometer.
				if (_engine.accelerometerSensor != null) {
					ASensorEventQueue_enableSensor(_engine.sensorEventQueue,
						_engine.accelerometerSensor);
					// We'd like to get 60 events per second (in us).
					ASensorEventQueue_setEventRate(_engine.sensorEventQueue,
						_engine.accelerometerSensor, (1000L/60)*1000);
				}
				break;
			case APP_CMD_LOST_FOCUS:
				// When our app loses focus, we stop monitoring the accelerometer.
				// This is to avoid consuming battery while not being used.
				if (_engine.accelerometerSensor != null) {
					ASensorEventQueue_disableSensor(_engine.sensorEventQueue,
						_engine.accelerometerSensor);
				}
				// Also stop animating.
				_engine.animating = 0;
				engine_draw_frame();
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
		_activeWindow = w;
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
		_activeWindow = (_windows.length > 0 ? _windows[$ - 1] : null);
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
					if (_engine.accelerometerSensor != null) {
						ASensorEvent event;
						while (ASensorEventQueue_getEvents(_engine.sensorEventQueue,
								&event, 1) > 0) {
							LOGI("accelerometer: x=%f y=%f z=%f",
								event.acceleration.x, event.acceleration.y,
								event.acceleration.z);
						}
					}
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
				engine_draw_frame();
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
    android_app* app;

    ASensorManager* sensorManager;
    const(ASensor)* accelerometerSensor;
    ASensorEventQueue* sensorEventQueue;

    int animating;
    EGLDisplay display;
    EGLSurface surface;
    EGLContext context;
    int width;
    int height;
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

    currentTheme = createDefaultTheme();

	_platform = new AndroidPlatform(state);
	Platform.setInstance(_platform);


    // Make sure glue isn't stripped.
    app_dummy();

	int res = 0;
	
	version (unittest) {
	} else {
		res = UIAppMain([]);
	}

    // loop waiting for stuff to do.
	Log.d("Destroying Android platform");
	Platform.setInstance(null);
	
	releaseResourcesOnAppExit();
	
	Log.d("Exiting main");
	

}

