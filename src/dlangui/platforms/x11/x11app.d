module src.dlangui.platforms.x11.x11app;

import std.stdio;
import std.c.linux.X11.xcb.xcb;
import std.c.linux.X11.xcb.xproto;
import std.c.linux.X11.keysymdef;
import std.c.stdlib;

import dlangui.core.logger;
import dlangui.platforms.common.platform;

class XCBWindow : Window {
	xcb_window_t         _w;
	xcb_gcontext_t       _g;
	@property xcb_window_t windowId() { return _w; }
	this(string caption, Window parent) {
		_caption = caption;
		Log.d("Creating XCB window");
		create();
	}
	~this() {
		Log.d("Destroying window");
	}
	bool create() {
		uint mask;
		uint values[2];

	    /* create black graphics context */
		_g = xcb_generate_id(_xcbconnection);
		_w = _xcbscreen.root;
		mask = XCB_GC_FOREGROUND | XCB_GC_GRAPHICS_EXPOSURES;
		values[0] = _xcbscreen.black_pixel;
		values[1] = 0;
		xcb_create_gc(_xcbconnection, _g, _w, mask, &values[0]);

	    /* create window */
		_w = xcb_generate_id(_xcbconnection);
		
		Log.d("window=", _w, " gc=", _g);
		
		mask = XCB_CW_BACK_PIXEL | XCB_CW_EVENT_MASK;
		values[0] = _xcbscreen.white_pixel;
		values[1] = XCB_EVENT_MASK_EXPOSURE | XCB_EVENT_MASK_KEY_PRESS | XCB_EVENT_MASK_BUTTON_PRESS | XCB_EVENT_MASK_BUTTON_RELEASE 
			| XCB_EVENT_MASK_POINTER_MOTION | XCB_EVENT_MASK_BUTTON_MOTION 
			| XCB_EVENT_MASK_ENTER_WINDOW   | XCB_EVENT_MASK_LEAVE_WINDOW
			| XCB_EVENT_MASK_KEY_PRESS      | XCB_EVENT_MASK_KEY_RELEASE;
		xcb_create_window(_xcbconnection, _xcbscreen.root_depth, _w, _xcbscreen.root,
	          10, 10, 100, 100, 1,
	          XCB_WINDOW_CLASS_INPUT_OUTPUT, _xcbscreen.root_visual,
	          mask, &values[0]);
	  	xcb_flush(_xcbconnection);
		return true;
	}
	override void show() {
		Log.d("XCBWindow.show()");
	    /* map (show) the window */
	  	xcb_map_window(_xcbconnection, _w);
	  	xcb_flush(_xcbconnection);
	}
	string _caption;
	override @property string windowCaption() {
		return _caption;
	}
	override @property void windowCaption(string caption) {
		_caption = caption;
	}
	void processExpose(xcb_expose_event_t * event) {
		static xcb_rectangle_t      r = { 20, 20, 60, 60 };
		xcb_poly_fill_rectangle(_xcbconnection, _w, _g,  1, &r);
		xcb_flush(_xcbconnection);
	}
}

private __gshared xcb_connection_t * _xcbconnection;
private __gshared xcb_screen_t     * _xcbscreen;

class XCBPlatform : Platform {
	this() {
	}
	~this() {
		disconnect();
	}
	void disconnect() {
		if (_xcbconnection) {
		    /* close connection to server */
  			xcb_disconnect(_xcbconnection);
		}
	}
	bool connect() {
		Log.d("Opening connection");
	    /* open connection with the server */
	    _xcbconnection = xcb_connect(null,null);
	    if (xcb_connection_has_error(_xcbconnection)) {
	        Log.e("Cannot open display");
			_xcbconnection = null;
	        return false;
	    }
		
		Log.d("Getting first screen");
	    /* get the first screen */
	  	_xcbscreen = xcb_setup_roots_iterator( xcb_get_setup(_xcbconnection) ).data;
		
		return true;
	}
	XCBWindow getWindow(xcb_window_t w) {
		if (w in _windowMap)
			return _windowMap[w];
		return null;
	}
	override Window createWindow(string windowCaption, Window parent) {
		XCBWindow res = new XCBWindow(windowCaption, parent);
		_windowMap[res.windowId] = res;
		return res;
	}
	override int enterMessageLoop() {
		Log.i("entering message loop");
		int done = 0;
		xcb_generic_event_t *e;
	    /* event loop */
	  	do {
			Log.v("waiting for event");			
	  		e = xcb_wait_for_event(_xcbconnection);
			if (e is null) {
				Log.w("NULL event received. Exiting message loop");
				break;
			}
	    	switch (e.response_type & ~0x80) {
				case XCB_EXPOSE: {   /* draw or redraw the window */
						xcb_expose_event_t *expose = cast(xcb_expose_event_t *)e;
						Log.i("expose event");
						XCBWindow window = getWindow(expose.window);
						if (window !is null) {
							window.processExpose(expose);
						} else {
							Log.w("Received message for unknown window", expose.window);
						}
			      		break;
					}
				case XCB_BUTTON_PRESS: {
						xcb_button_press_event_t *bp = cast(xcb_button_press_event_t *)e;
						Log.d("XCB_BUTTON_PRESS");
						break;
					}
				case XCB_BUTTON_RELEASE: {
						Log.d("XCB_BUTTON_RELEASE");
						xcb_button_release_event_t *br = cast(xcb_button_release_event_t *)e;
						break;
					}
	            case XCB_MOTION_NOTIFY: {
		                xcb_motion_notify_event_t *motion = cast(xcb_motion_notify_event_t *)e;
		                Log.d("XCB_MOTION_NOTIFY ", motion.event, " at coords ", motion.event_x, ", ", motion.event_y);
		                break;
		            }
	            case XCB_ENTER_NOTIFY: {
		                xcb_enter_notify_event_t *enter = cast(xcb_enter_notify_event_t *)e;
		                Log.d("XCB_ENTER_NOTIFY ", enter.event, " at coords ", enter.event_x, ", ", enter.event_y);
		                break;
		            }
	            case XCB_LEAVE_NOTIFY: {
	                xcb_leave_notify_event_t *leave = cast(xcb_leave_notify_event_t *)e;

		                Log.d("XCB_LEAVE_NOTIFY ", leave.event, " at coords ", leave.event_x, ", ", leave.event_y);
	                break;
	            }
	            case XCB_KEY_PRESS: {
		                xcb_key_press_event_t *kp = cast(xcb_key_press_event_t *)e;
		                //print_modifiers(kp.state);
		                Log.d("XCB_KEY_PRESS ", kp.event, " key=", kp.detail);
						if (kp.detail == XK_space) // exist by space
	      					done = 1;
		                break;
		            }
	            case XCB_KEY_RELEASE: {
		                xcb_key_release_event_t *kr = cast(xcb_key_release_event_t *)e;
		                //print_modifiers(kr.state);
			            Log.d("XCB_KEY_RELEASE ", kr.event, " key=", kr.detail);
		                break;
		            }			
				default:
					break;
	      	}
	    	free(e);
	  	} while(!done);
		Log.i("exiting message loop");
		return 0;
	}
	XCBWindow[xcb_window_t] _windowMap;
}

int main(string[] args)
{
	
	setStderrLogger();
	setLogLevel(LogLevel.Trace);
	
	XCBPlatform xcb = new XCBPlatform();
	if (!xcb.connect()) {
		return 1;
	}
	Platform.setInstance(xcb);

	Window window = xcb.createWindow("Window Caption", null);
	window.show();
		
	int res = xcb.enterMessageLoop();
	
	Platform.setInstance(null);
	destroy(xcb);
	

  	return res;
}
