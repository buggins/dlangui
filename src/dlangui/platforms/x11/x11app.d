module src.dlangui.platforms.x11.x11app;

version(linux) {

	import std.string;
	import std.c.linux.X11.xcb.xcb;
	import std.c.linux.X11.xcb.shm;
	import std.c.linux.X11.xcb.xproto;
	import std.c.linux.X11.xcb.image;
	import std.c.linux.X11.keysymdef;
	import std.c.linux.linux;
	import std.c.stdlib;
	import std.conv;

	import dlangui.core.logger;
	import dlangui.core.events;
	import dlangui.graphics.drawbuf;
	import dlangui.graphics.fonts;
	import dlangui.graphics.ftfonts;
	import dlangui.platforms.common.platform;

	class XCBWindow : Window {
		xcb_window_t         _w;
		xcb_gcontext_t       _g;
		xcb_image_t * 		_image;
		xcb_shm_segment_info_t shminfo;
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
				| XCB_EVENT_MASK_KEY_PRESS      | XCB_EVENT_MASK_KEY_RELEASE
				| XCB_EVENT_MASK_STRUCTURE_NOTIFY | XCB_EVENT_MASK_VISIBILITY_CHANGE;
			xcb_create_window(_xcbconnection, _xcbscreen.root_depth, _w, _xcbscreen.root,
		          50, 50, 500, 400, 1,
		          XCB_WINDOW_CLASS_INPUT_OUTPUT, _xcbscreen.root_visual,
		          mask, &values[0]);
		  	xcb_flush(_xcbconnection);
			windowCaption = _caption;
			return true;
		}
			
		void createImage() {
	        Log.i("CRXCBScreen::createImage ", _dx, "x", _dy);
	        if (_image)
	            xcb_image_destroy(_image);
			_image = null;
	        xcb_shm_query_version_reply_t * rep_shm;
	        rep_shm = xcb_shm_query_version_reply (_xcbconnection,
	                xcb_shm_query_version(_xcbconnection),
	                null);
	        if(rep_shm) {
	            xcb_image_format_t format;
	            int shmctl_status;

	            if (rep_shm.shared_pixmaps &&
	                    (rep_shm.major_version > 1 || rep_shm.minor_version > 0))
	                format = cast(xcb_image_format_t)rep_shm.pixmap_format;
	            else
	                format = XCB_IMAGE_FORMAT_Z_PIXMAP;

	            _image = xcb_image_create_native (_xcbconnection, cast(short)_dx, cast(short)_dy,
	                 format, _xcbscreendepth, null, ~0, null);
	            //format, depth, NULL, ~0, NULL);
	            //format, depth, NULL, ~0, NULL);
	            assert(_image);

	            shminfo.shmid = shmget (IPC_PRIVATE,
	                    _image.stride*_image.height,
	                    IPC_CREAT | octal!777);
	            assert(shminfo.shmid != cast(uint)-1);
	            shminfo.shmaddr = cast(ubyte*)shmat (shminfo.shmid, null, 0);
	            assert(shminfo.shmaddr);
	            _image.data = shminfo.shmaddr;
	            Log.d("Created image depth=", _image.depth, " bpp=", _image.bpp, " stride=", _image.stride );

	            shminfo.shmseg = xcb_generate_id (_xcbconnection);
	            xcb_shm_attach (_xcbconnection, shminfo.shmseg,
	                    shminfo.shmid, 0);
	            shmctl_status = shmctl(shminfo.shmid, IPC_RMID, null);
	            assert(shmctl_status != -1);
	            free(rep_shm);
	        } else {
	            Log.e("Can't get shms");
	        }
		}
		
		void draw(ColorDrawBuf buf) {
	        int i;
	        i = xcb_image_shm_get(_xcbconnection, _w,
	                _image, shminfo,
	                0, 0,
	                XCB_ALL_PLANES);
	        if (!i) {
	            Log.e("cannot get shm image");
	            return;
	        }
			Rect rc;
			rc.right = buf.width;
			rc.bottom = buf.height;
			switch ( _image.bpp ) {
	            case 32:
	                {
	                    for (int y = rc.top; y<rc.bottom; y++) {
	                        uint * src = buf.scanLine(y);
	                        uint * dst = cast(uint *)(_image.data + _image.stride * y);
	                        for ( int x = 0; x < rc.right; x++ ) {
	                            uint data = src[x];
	                            dst[x] = data;
	                        }
	                    }
	                }
	                break;
				default:
					Log.d("image bit depth not supported: ", _image.bpp);
					break;
			}
	        xcb_image_shm_put(_xcbconnection, _w, _g,
	                _image, shminfo,
	                cast(short)rc.left, cast(short)rc.top, cast(short)rc.left, cast(short)rc.top, cast(ushort)rc.width(), cast(ushort)rc.height(), 0);
	        xcb_flush(_xcbconnection);
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
			const char * title = _caption.toStringz;
	        xcb_change_property (_xcbconnection,
	                             XCB_PROP_MODE_REPLACE,
	                             _w,
	                             XCB_ATOM_WM_NAME,
	                             XCB_ATOM_STRING,
	                             8,
	                             cast(uint)_caption.length,
	                             cast(void*)title);
		}

		void redraw() {
			if (!_drawbuf)
				_drawbuf = new ColorDrawBuf(_dx, _dy);
			_drawbuf.resize(_dx, _dy);
			_drawbuf.fill(_backgroundColor);
			Log.d("calling createImage");
			createImage();
			Log.d("done createImage");
			onDraw(_drawbuf);
			draw(_drawbuf);
				/*
			xcb_rectangle_t r = { 20, 20, 60, 60 };
			xcb_poly_fill_rectangle(_xcbconnection, _w, _g,  1, &r);
			r = xcb_rectangle_t(cast(short)(_dx - 20 - 60), cast(short)(_dy - 20 - 60), 60, 60);
			xcb_poly_fill_rectangle(_xcbconnection, _w, _g,  1, &r);
				 */
			xcb_flush(_xcbconnection);
		}
		
		ColorDrawBuf _drawbuf;
		bool _exposeSent;
		void processExpose(xcb_expose_event_t * event) {
			redraw();
			_exposeSent = false;
		}

		/// request window redraw
		override void invalidate() {
			if (_exposeSent)
				return;
			_exposeSent = true;
			xcb_expose_event_t * event = cast(xcb_expose_event_t*)std.c.stdlib.malloc(xcb_expose_event_t.sizeof);
		    event.response_type = XCB_EXPOSE; /* The type of the event, here it is XCB_EXPOSE */
		    event.sequence = 0;
		    event.window = _w;        /* The Id of the window that receives the event (in case */
		                                    /* our application registered for events on several windows */
		    event.x = 0;             /* The x coordinate of the top-left part of the window that needs to be redrawn */
		    event.y = 0;             /* The y coordinate of the top-left part of the window that needs to be redrawn */
		    event.width = cast(ushort)_dx;         /* The width of the part of the window that needs to be redrawn */
		    event.height = cast(ushort)_dy;        /* The height of the part of the window that needs to be redrawn */
		    event.count = 1;

			xcb_void_cookie_t res = xcb_send_event(_xcbconnection, false, _w, XCB_EVENT_MASK_EXPOSURE, cast(char *)event);
		  	xcb_flush(_xcbconnection);
		}
				
		protected ButtonDetails _lbutton;
		protected ButtonDetails _mbutton;
		protected ButtonDetails _rbutton;
		void processMouseEvent(MouseAction action, ubyte detail, ushort state, short x, short y) {
			MouseButton button = MouseButton.None;
			short wheelDelta = 0;
        	ButtonDetails * pbuttonDetails = null;
			ushort flags = 0;
			if (state & XCB_BUTTON_MASK_1)
				flags |= MouseFlag.LButton;
			if (state & XCB_BUTTON_MASK_2)
				flags |= MouseFlag.MButton;
			if (state & XCB_BUTTON_MASK_3)
				flags |= MouseFlag.RButton;
			if (state & XCB_MOD_MASK_SHIFT)
				flags |= MouseFlag.Shift;
			if (state & XCB_MOD_MASK_CONTROL)
				flags |= MouseFlag.Control;
			if (state & XCB_MOD_MASK_LOCK)
				flags |= MouseFlag.Alt;
			if (action == MouseAction.ButtonDown || action == MouseAction.ButtonUp) {
				switch (detail) {
					case 1:
						button = MouseButton.Left;
		                pbuttonDetails = &_lbutton;
						if (action == MouseAction.ButtonDown)
							flags |= MouseFlag.LButton;
						break;
					case 2:
						button = MouseButton.Middle;
		                pbuttonDetails = &_mbutton;
						if (action == MouseAction.ButtonDown)
							flags |= MouseFlag.MButton;
						break;
					case 3:
						button = MouseButton.Right;
		                pbuttonDetails = &_rbutton;
						if (action == MouseAction.ButtonDown)
							flags |= MouseFlag.RButton;
						break;
					case 4:
						if (action == MouseAction.ButtonUp)
							return;
						wheelDelta = -1;
						action = MouseAction.Wheel;
						break;
					case 5:
						if (action == MouseAction.ButtonUp)
							return;
						wheelDelta = 1;
						action = MouseAction.Wheel;
						break;
					default:
						// unknown button
						return;
				}
			}
			Log.d("processMouseEvent ", action, " detail=", detail, " state=", state, " at coords ", x, ", ", y);
	        if (action == MouseAction.ButtonDown) {
	            pbuttonDetails.down(x, y, cast(ushort)flags);
	        } else if (action == MouseAction.ButtonUp) {
	            pbuttonDetails.up(x, y, cast(ushort)flags);
	        }
	        MouseEvent event = new MouseEvent(action, button, cast(ushort)flags, x, y, wheelDelta);
	        event.lbutton = _lbutton;
	        event.rbutton = _rbutton;
	        event.mbutton = _mbutton;
			bool res = dispatchMouseEvent(event);
	        if (res) {
	            Log.d("Calling update() after mouse event");
	            invalidate();
	        }
		}
		
	}

	private __gshared xcb_connection_t * _xcbconnection;
	private __gshared xcb_screen_t     * _xcbscreen;
	private __gshared ubyte _xcbscreendepth;

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
			//XSetEventQueueOwner(display, XCBOwnsEventQueue);
			Log.d("Getting first screen");
		    /* get the first screen */
		  	_xcbscreen = xcb_setup_roots_iterator( xcb_get_setup(_xcbconnection) ).data;
	        _xcbscreendepth = xcb_aux_get_depth(_xcbconnection, _xcbscreen);
				
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
		  		e = xcb_wait_for_event(_xcbconnection);
				if (e is null) {
					Log.w("NULL event received. Exiting message loop");
					break;
				}
		    	switch (e.response_type & ~0x80) {
					case XCB_CREATE_NOTIFY: {
							xcb_create_notify_event_t *event = cast(xcb_create_notify_event_t *)e;
							Log.i("XCB_CREATE_NOTIFY");
							XCBWindow window = getWindow(event.window);
							if (window !is null) {
								//
							} else {
								Log.w("Received message for unknown window", event.window);
							}
							break;
						}
					case XCB_DESTROY_NOTIFY: {
							xcb_destroy_notify_event_t *event = cast(xcb_destroy_notify_event_t *)e;
							Log.i("XCB_DESTROY_NOTIFY");
							XCBWindow window = getWindow(event.window);
							if (window !is null) {
								//
							} else {
								Log.w("Received message for unknown window", event.window);
							}
							break;
						}
					case XCB_MAP_NOTIFY: {
							xcb_map_notify_event_t *event = cast(xcb_map_notify_event_t *)e;
							Log.i("XCB_MAP_NOTIFY");
							XCBWindow window = getWindow(event.window);
							if (window !is null) {
								//
							} else {
								Log.w("Received message for unknown window", event.window);
							}
							break;
						}
					case XCB_UNMAP_NOTIFY: {
							xcb_unmap_notify_event_t *event = cast(xcb_unmap_notify_event_t *)e;
							Log.i("XCB_UNMAP_NOTIFY");
							XCBWindow window = getWindow(event.window);
							if (window !is null) {
								//
							} else {
								Log.w("Received message for unknown window", event.window);
							}
							break;
						}
					case XCB_VISIBILITY_NOTIFY: {
							xcb_visibility_notify_event_t *event = cast(xcb_visibility_notify_event_t *)e;
							Log.i("XCB_VISIBILITY_NOTIFY ", event.state);
							XCBWindow window = getWindow(event.window);
							if (window !is null) {
								//
							} else {
								Log.w("Received message for unknown window", event.window);
							}
							break;
						}
					case XCB_REPARENT_NOTIFY: {
							xcb_reparent_notify_event_t *event = cast(xcb_reparent_notify_event_t *)e;
							Log.i("XCB_REPARENT_NOTIFY");
							break;
						}
					case XCB_CONFIGURE_NOTIFY: {
							xcb_configure_notify_event_t *event = cast(xcb_configure_notify_event_t *)e;
							Log.i("XCB_CONFIGURE_NOTIFY ", event.width, "x", event.height);
							XCBWindow window = getWindow(event.window);
							if (window !is null) {
								//
								window.onResize(event.width, event.height);
							} else {
								Log.w("Received message for unknown window", event.window);
							}
							break;
						}
					case XCB_EXPOSE: {   /* draw or redraw the window */
							xcb_expose_event_t *expose = cast(xcb_expose_event_t *)e;
							Log.i("XCB_EXPOSE");
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
							XCBWindow window = getWindow(bp.event);
							if (window !is null) {
								//
								window.processMouseEvent(MouseAction.ButtonDown, bp.detail, bp.state, bp.event_x, bp.event_y);
							} else {
								Log.w("Received message for unknown window", bp.event);
							}
							break;
						}
					case XCB_BUTTON_RELEASE: {
							Log.d("XCB_BUTTON_RELEASE");
							xcb_button_release_event_t *br = cast(xcb_button_release_event_t *)e;
							XCBWindow window = getWindow(br.event);
							if (window !is null) {
								//
								window.processMouseEvent(MouseAction.ButtonUp, br.detail, br.state, br.event_x, br.event_y);
							} else {
								Log.w("Received message for unknown window", br.event);
							}
							break;
						}
		            case XCB_MOTION_NOTIFY: {
			                xcb_motion_notify_event_t *motion = cast(xcb_motion_notify_event_t *)e;
			                Log.d("XCB_MOTION_NOTIFY ", motion.event, " at coords ", motion.event_x, ", ", motion.event_y);
							XCBWindow window = getWindow(motion.event);
							if (window !is null) {
								//
								window.processMouseEvent(MouseAction.Move, 0, motion.state, motion.event_x, motion.event_y);
							} else {
								Log.w("Received message for unknown window", motion.event);
							}
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
						XCBWindow window = getWindow(leave.event);
						if (window !is null) {
							//
							window.processMouseEvent(MouseAction.Leave, 0, leave.state, leave.event_x, leave.event_y);
						} else {
							Log.w("Received message for unknown window", leave.event);
						}
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
						Log.v("unknown event: ", e.response_type & ~0x80);	
						break;
		      	}
		    	free(e);
		  	} while(!done);
			Log.i("exiting message loop");
			return 0;
		}
		XCBWindow[xcb_window_t] _windowMap;
	}

	// entry point
	extern(C) int UIAppMain(string[] args);
		
	int main(string[] args)
	{
		
		setStderrLogger();
		setLogLevel(LogLevel.Trace);

		FreeTypeFontManager ft = new FreeTypeFontManager();
		ft.registerFont("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", FontFamily.SansSerif, "DejaVu", false, FontWeight.Normal);
		FontManager.instance = ft;
		
		XCBPlatform xcb = new XCBPlatform();
		if (!xcb.connect()) {
			return 1;
		}
		Platform.setInstance(xcb);

		int res = 0;
			
			static if (true) {
				res = UIAppMain(args);
			} else {
				Window window = xcb.createWindow("Window Caption", null);
				window.show();
					
				res = xcb.enterMessageLoop();
			}
		
		Platform.setInstance(null);
		destroy(xcb);
		

	  	return res;
	}

}
