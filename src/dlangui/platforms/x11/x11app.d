module src.dlangui.platforms.x11.x11app;

version(linux) {

import std.string;
import std.c.linux.X11.xcb.xcb;
import std.c.linux.X11.xcb.shm;
import std.c.linux.X11.xcb.xproto;
import std.c.linux.X11.keysymdef;
import std.c.linux.linux;
import std.c.stdlib;
import std.conv;

import dlangui.core.logger;
import dlangui.graphics.drawbuf;
import dlangui.platforms.common.platform;
struct xcb_image_t
{
	ushort           width;   
	ushort           height;   
	xcb_image_format_t format;   
	ubyte            scanline_pad;   
	ubyte            depth;   
	ubyte            bpp;   
	ubyte          unit;  
	uint           plane_mask;   
	xcb_image_order_t  byte_order;   
	xcb_image_order_t  bit_order;    
	uint           stride;   
	uint           size;   
	void *             base;   
	ubyte *          data;   
}
	
xcb_format_t *
find_format_by_depth (xcb_setup_t *setup, ubyte depth)
{ 
  xcb_format_t *fmt = xcb_setup_pixmap_formats(setup);
  xcb_format_t *fmtend = fmt + xcb_setup_pixmap_formats_length(setup);
  for(; fmt != fmtend; ++fmt)
      if(fmt.depth == depth)
	  return fmt;
  return null;
}


xcb_image_format_t
effective_format(xcb_image_format_t format, ubyte bpp)
{
    if (format == XCB_IMAGE_FORMAT_Z_PIXMAP && bpp != 1)
	    return format;
    return XCB_IMAGE_FORMAT_XY_PIXMAP;
}


int
format_valid (ubyte depth, ubyte bpp, ubyte unit,
	      xcb_image_format_t format, ubyte xpad)
{
  xcb_image_format_t  ef = effective_format(format, bpp);
  if (depth > bpp)
      return 0;
  switch(ef) {
  case XCB_IMAGE_FORMAT_XY_PIXMAP:
      switch(unit) {
      case 8:
      case 16:
      case 32:
	  break;
      default:
	  return 0;
      }
      if (xpad < bpp)
	  return 0;
      switch (xpad) {
      case 8:
      case 16:
      case 32:
	  break;
      default:
	  return 0;
      }
      break;
  case XCB_IMAGE_FORMAT_Z_PIXMAP:
      switch (bpp) {
      case 4:
	  if (unit != 8)
	      return 0;
	  break;
      case 8:
      case 16:
      case 24:
      case 32:
	  if (unit != bpp)
	      return 0;
	  break;
      default:
	  return 0;
      }
      break;
  default:
      return 0;
  }
  return 1;
}


int
image_format_valid (xcb_image_t *image) {
    return format_valid(image.depth,
			image.bpp,
			image.unit,
			image.format,
			image.scanline_pad);
}

uint xcb_roundup(uint  	base,
		uint	pad 
)
{
    uint b = base + pad - 1;
    /* faster if pad is a power of two */
    if (((pad - 1) & pad) == 0)
       return b & -pad;
    return b - b % pad;
}

void
xcb_image_annotate (xcb_image_t *image)
{
  xcb_image_format_t  ef = effective_format(image.format, image.bpp);
  switch (ef) {
  case XCB_IMAGE_FORMAT_XY_PIXMAP:
      image.stride = xcb_roundup(image.width, image.scanline_pad) >> 3;
      image.size = image.height * image.stride * image.depth;
      break;
  case XCB_IMAGE_FORMAT_Z_PIXMAP:
      image.stride = xcb_roundup(cast(uint)image.width *
				  cast(uint)image.bpp,
				  image.scanline_pad) >> 3;
      image.size = image.height * image.stride;
      break;
  default:
      assert(0);
  }
}

xcb_image_t *
xcb_image_create_native (xcb_connection_t *  c,
			 ushort            width,
			 ushort            height,
			 xcb_image_format_t  format,
			 ubyte             depth,
			 void *              base,
			 uint            bytes,
			 ubyte *           data)
{
  xcb_setup_t *  setup = xcb_get_setup(c);
  xcb_format_t *       fmt;
  xcb_image_format_t   ef = format;
  
  if (ef == XCB_IMAGE_FORMAT_Z_PIXMAP && depth == 1)
      ef = XCB_IMAGE_FORMAT_XY_PIXMAP;
  switch (ef) {
  case XCB_IMAGE_FORMAT_XY_BITMAP:
      if (depth != 1)
	  return null;
      /* fall through */
  case XCB_IMAGE_FORMAT_XY_PIXMAP:
      if (depth > 1) {
	  fmt = find_format_by_depth(setup, depth);
	  if (!fmt)
	      return null;
      }
      return xcb_image_create(width, height, format,
			      setup.bitmap_format_scanline_pad,
			      depth, depth, setup.bitmap_format_scanline_unit,
			      setup.image_byte_order,
			      setup.bitmap_format_bit_order,
			      base, bytes, data);
  case XCB_IMAGE_FORMAT_Z_PIXMAP:
      fmt = find_format_by_depth(setup, depth);
      if (!fmt)
	  		return null;
      return xcb_image_create(width, height, format,
			      fmt.scanline_pad,
			      fmt.depth, fmt.bits_per_pixel, 0,
			      setup.image_byte_order,
			      XCB_IMAGE_ORDER_MSB_FIRST,
			      base, bytes, data);
  default:
      assert(0);
  }
  assert(0);
}

uint xcb_mask(uint n)
{
    return n == 32 ? ~0 : (1 << n) - 1;
}

xcb_image_t *
xcb_image_create (ushort           width,
		  ushort           height,
		  xcb_image_format_t format,
		  ubyte            xpad,
		  ubyte            depth,
		  ubyte            bpp,
		  ubyte            unit,
		  xcb_image_order_t  byte_order,
		  xcb_image_order_t  bit_order,
		  void *             base,
		  uint           bytes,
		  ubyte *          data)
{
  xcb_image_t *  image;

  if (unit == 0) {
      switch (format) {
	      case XCB_IMAGE_FORMAT_XY_BITMAP:
	      case XCB_IMAGE_FORMAT_XY_PIXMAP:
			  unit = 32;
			  break;
	      case XCB_IMAGE_FORMAT_Z_PIXMAP:
			  if (bpp == 1) {
			      unit = 32;
			      break;
			  }
			  if (bpp < 8) {
			      unit = 8;
			      break;
			  }
			  unit = bpp;
			  break;
		default:
			break;
						
      }
  }
  if (!format_valid(depth, bpp, unit, format, xpad))
      return null;
  import std.c.stdlib;
  image = cast(xcb_image_t*)malloc(xcb_image_t.sizeof);
  if (image is null)
      return null;
  image.width = width;
  image.height = height;
  image.format = format;
  image.scanline_pad = xpad;
  image.depth = depth;
  image.bpp = bpp;
  image.unit = unit;
  image.plane_mask = xcb_mask(depth);
  image.byte_order = byte_order;
  image.bit_order = bit_order;
  xcb_image_annotate(image);

  /*
   * Ways this function can be called:
   *   * with data: we fail if bytes isn't
   *     large enough, else leave well enough alone.
   *   * with base and !data: if bytes is zero, we
   *     default; otherwise we fail if bytes isn't
   *     large enough, else fill in data
   *   * with !base and !data: we malloc storage
   *     for the data, save that address as the base,
   *     and fail if malloc does.
   *
   * When successful, we establish the invariant that data
   * points at sufficient storage that may have been
   * supplied, and base is set iff it should be
   * auto-freed when the image is destroyed.
   * 
   * Except as a special case when base = 0 && data == 0 &&
   * bytes == ~0 we just return the image structure and let
   * the caller deal with getting the allocation right.
   */
  if (!base && !data && bytes == ~0) {
      image.base = null;
      image.data = null;
      return image;
  }
  if (!base && data && bytes == 0)
      bytes = image.size;
  image.base = base;
  image.data = data;
  if (!image.data) {
      if (image.base) {
  	  	  image.data = cast(ubyte*)image.base;
      } else {
		  bytes = image.size;
		  image.base = malloc(bytes);
		  image.data = cast(ubyte*)image.base;
      }
  }
  if (!image.data || bytes < image.size) {
      free(image);
      return null;
  }
  return image;
}


void
xcb_image_destroy (xcb_image_t *image)
{
  if (image.base)
      free (image.base);
  free (image);
}
	
ubyte
xcb_aux_get_depth(xcb_connection_t *c,
                   xcb_screen_t     *screen)
{
  xcb_drawable_t            drawable;
  xcb_get_geometry_reply_t *geom;
  ubyte                       depth;

  drawable = screen.root;
  geom = xcb_get_geometry_reply (c, xcb_get_geometry(c, drawable), null);

  if (!geom) {
	  Log.e("GetGeometry(root) failed");
    exit (0);
  }
  
  depth = geom.depth;
  free (geom);

  return depth;
}

extern (C) int xcb_image_shm_get(xcb_connection_t * conn,
	       xcb_drawable_t          draw,
	       xcb_image_t *           image,
	       xcb_shm_segment_info_t  shminfo,
	       ushort                 x,
	       ushort                 y,
	       uint                plane_mask);
const XCB_ALL_PLANES = ~0;
	
extern (C) xcb_image_t *
xcb_image_shm_put (xcb_connection_t *      conn,
		   xcb_drawable_t          draw,
		   xcb_gcontext_t          gc,
		   xcb_image_t *           image,
		   xcb_shm_segment_info_t  shminfo,
		   short                 src_x,
		   short                 src_y,
		   short                 dest_x,
		   short                 dest_y,
		   ushort                src_width,
		   ushort                src_height,
		   ubyte                 send_event);

/**
 * @struct xcb_shm_segment_info_t
 * A structure that stores the informations needed by the MIT Shm
 * Extension.
 */
struct xcb_shm_segment_info_t
{
  xcb_shm_seg_t shmseg;
  uint    shmid;
  ubyte   *shmaddr;
}

alias int key_t;
extern (C) int shmget(key_t key, size_t size, int shmflg);
extern (C) int getpagesize();
extern (C) ubyte *shmat(int shmid, ubyte *shmaddr, int shmflg);
extern (C) int shmctl(int shmid, int cmd, void *buf);
const IPC_CREAT = octal!1000;
const IPC_PRIVATE = (cast(key_t) 0);
const IPC_RMID = 0;

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
	void processExpose(xcb_expose_event_t * event) {
		Log.d("calling createImage");
		createImage();
		Log.d("done createImage");
		xcb_rectangle_t r = { 20, 20, 60, 60 };
		xcb_poly_fill_rectangle(_xcbconnection, _w, _g,  1, &r);
		r = xcb_rectangle_t(cast(short)(_dx - 20 - 60), cast(short)(_dy - 20 - 60), 60, 60);
		xcb_poly_fill_rectangle(_xcbconnection, _w, _g,  1, &r);
		xcb_flush(_xcbconnection);
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

}
