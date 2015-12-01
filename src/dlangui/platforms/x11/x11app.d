module dlangui.platforms.x11.x11app;

version (USE_X11):

import dlangui.core.logger;
import dlangui.core.events;
import dlangui.core.files;
import dlangui.graphics.drawbuf;
import dlangui.graphics.fonts;
import dlangui.graphics.ftfonts;
import dlangui.graphics.resources;
import dlangui.widgets.styles;
import dlangui.widgets.widget;
import dlangui.platforms.common.platform;

import std.stdio;
import std.string;

import x11.Xlib;
import x11.Xutil;
import x11.Xtos;
import x11.X;

pragma(lib, "X11");

private __gshared Display * x11display;
private __gshared int x11screen;

alias XWindow = x11.Xlib.Window;
alias DWindow = dlangui.platforms.common.platform.Window;

private GC createGC(Display* display, XWindow win)
{
	GC gc;				/* handle of newly created GC.  */
	uint valuemask = GCFunction | GCBackground | GCForeground | GCPlaneMask;		/* which values in 'values' to  */
	/* check when creating the GC.  */
	XGCValues values;			/* initial values for the GC.   */
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
	
	uint line_width = 2;		/* line width for the GC.       */
	int line_style = LineSolid;		/* style for lines drawing and  */
	int cap_style = CapButt;		/* style of the line's edje and */
	int join_style = JoinBevel;		/*  joined lines.		*/
	
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

	this(X11Platform platform, dstring caption, DWindow parent, uint flags, uint width = 0, uint height = 0) {
		_platform = platform;
		_caption = caption;
		debug Log.d("X11Window: Creating window");
		if (width == 0)
			width = 500;
		if (height == 0)
			height = 300;
		_dx = width;
		_dy = height;
		//create(flags);

		/* get the colors black and white (see section for details) */
		ulong black, white;
		black = BlackPixel(x11display, x11screen);	/* get color black */
		white = WhitePixel(x11display, x11screen);  /* get color white */

		/* once the display is initialized, create the window.
	   		This window will be have be 200 pixels across and 300 down.
	   		It will have the foreground white and background black
		*/

		Log.d("Creating window of size ", _dx, "x", _dy);
		static if (true) {
			_win = XCreateSimpleWindow(x11display, DefaultRootWindow(x11display), 
				0, 0,	
				_dx, _dy, 5, black, white);
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
		//XMapWindow(x11display, _win);
		//XSync(x11display, false);

		//readln();
		
		/* here is where some properties of the window can be set.
	   		The third and fourth items indicate the name which appears
	   		at the top of the window and the name of the minimized window
	   		respectively.
		*/
		XSetStandardProperties(x11display, _win, cast(char*)"My Window".ptr, cast(char*)"HI!".ptr, None, cast(char**)null, 0, cast(XSizeHints*)null);

		/* this routine determines which types of input are allowed in
	   		the input.  see the appropriate section for details...
		*/
		XSelectInput(x11display, _win, ExposureMask|ButtonPressMask|KeyPressMask);
		
		/* create the Graphics Context */
		_gc = createGC(x11display, _win);
		//_gc = XCreateGC(x11display, _win, 0, cast(XGCValues*)null);
		Log.d("X11Window: windowId=", _win, " gc=", _gc);



		
		/* here is another routine to set the foreground and background
	   		colors _currently_ in use in the window.
		*/
		//XSetBackground(x11display, _gc, white);
		//XSetForeground(x11display, _gc, black);
		
		/* clear the window and bring it on top of the other windows */
		//XClearWindow(x11display, _win);
		//XFlush(x11display);
	}

	~this() {
		if (_gc)
			XFreeGC(x11display, _gc);
		if (_win)
			XDestroyWindow(x11display, _win);
	}

	/// show window
	override void show() {
		Log.d("X11Window.show");
		XMapRaised(x11display, _win);
		XFlush(x11display);
		if (_mainWidget)
			_mainWidget.setFocus();
	}

	override @property dstring windowCaption() {
		return _caption;
	}
	
	override @property void windowCaption(dstring caption) {
		_caption = caption;
		//if (_win)
		//	SDL_SetWindowTitle(_win, toUTF8(_caption).toStringz);
	}

	/// sets window icon
	override @property void windowIcon(DrawBufRef icon) {
	}
	/// request window redraw
	override void invalidate() {
		XEvent ev;
		ev.type = Expose;
		ev.xexpose.window = _win;
		XSendEvent(x11display, _win, false, ExposureMask, &ev);
	}

	/// close window
	override void close() {
	}

	ColorDrawBuf _drawbuf;
	protected void drawUsingBitmap() {
		if (_dx > 0 && _dy > 0) {
			// prepare drawbuf
			if (_drawbuf is null)
				_drawbuf = new ColorDrawBuf(_dx, _dy);
			else
				_drawbuf.resize(_dx, _dy);
			_drawbuf.resetClipping();
			// draw widgets into buffer
			onDraw(_drawbuf);
			// draw buffer on X11 window
			//_drawbuf.invertAlpha();
			//_drawbuf.invertByteOrder();
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
			XSetClipOrigin(x11display, _gc, 0, 0);
			XPutImage(x11display, _win, 
				_gc, //DefaultGC(x11display, DefaultScreen(x11display)), 
				&img,
				0, 0, 0, 0,
				_drawbuf.width,
				_drawbuf.height);
			/*
			XImage * image = XCreateImage(x11display, 
				DefaultVisual(x11display, DefaultScreen(x11display)),
				24,
				ZPixmap, //XYPixmap, 
				0,
				cast(char*)_drawbuf.scanLine(0), 
				_drawbuf.width,
				_drawbuf.height,
				32, 0);
			//image.bitmap_bit_order = MSBFirst;
			//image.b
			XPutImage(x11display, _win, 
				_gc, //DefaultGC(x11display, DefaultScreen(x11display)), 
				image,
				0, 0, 0, 0,
				_drawbuf.width,
				_drawbuf.height);
			*/
			XFlush(x11display);
			//XDestroyImage(image);
			//XFree(image);
	

//			ulong black, white;
//			black = BlackPixel(x11display, x11screen);	/* get color black */
//			white = WhitePixel(x11display, x11screen);  /* get color white */
//			Pixmap pixmap = XCreatePixmapFromBitmapData(x11display, _win, 
//				cast(char*)_drawbuf.scanLine(0), 
//				_drawbuf.width,
//				_drawbuf.height,
//				black,
//				white,
//				DefaultDepth(x11display, 0) // depth
//				);
//			//GC gc = XCreateGC(x11display, pixmap, 0, null);
//			XCopyArea(x11display, pixmap, _win,
//				_gc, //gc
//				0, 0, _drawbuf.width, _drawbuf.height,
//				0, 0);
			//XFlush(x11display);
			//XFreePixmap(x11display, pixmap);
		}
	}

	void processExpose() {
		XWindowAttributes window_attributes_return;
		XGetWindowAttributes(x11display, _win, &window_attributes_return);
		Log.d(format("XGetWindowAttributes reported size %d, %d", window_attributes_return.width, window_attributes_return.height));
		int width = window_attributes_return.width;
		int height = window_attributes_return.height;
		if (width > 0 && height > 0)
			onResize(width, height);
		Log.d(format("processExpose(%d, %d)", width, height));
		ulong black, white;
		black = BlackPixel(x11display, x11screen);	/* get color black */
		white = WhitePixel(x11display, x11screen);  /* get color white */

		XSetBackground(x11display, _gc, white);
		XClearWindow(x11display, _win);

		drawUsingBitmap();

		//XSetForeground( x11display, _gc, black );
		//XFillRectangle(x11display, _win, _gc, 5, 5, _dx - 10, 5);
		//XFillRectangle(x11display, _win, _gc, 5, _dy - 10, _dx - 10, 5);
		//XSetForeground ( x11display, _gc, black );
		//XDrawString ( x11display, _win, _gc, 20, 50,
		//	cast(char*)"First example".ptr, "First example".length );
		//XFreeGC ( x11display, gc );
		XFlush(x11display);
	}
}

class X11Platform : Platform {

	this() {
	}

	X11Window[XWindow] _windowMap;

	/**
	 * create window
	 * Args:
	 * 		windowCaption = window caption text
	 * 		parent = parent Window, or null if no parent
	 * 		flags = WindowFlag bit set, combination of Resizable, Modal, Fullscreen
     *      width = window width 
     *      height = window height
	 * 
	 * Window w/o Resizable nor Fullscreen will be created with size based on measurement of its content widget
	 */
	override DWindow createWindow(dstring windowCaption, DWindow parent, uint flags = WindowFlag.Resizable, uint width = 0, uint height = 0) {
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
		_windowMap.remove((cast(X11Window)w)._win);
	}

	/**
	 * Starts application message loop.
	 * 
	 * When returned from this method, application is shutting down.
	 */
	override int enterMessageLoop() {
		XEvent event;		/* the XEvent declaration !!! */
		KeySym key;		/* a dealie-bob to handle KeyPress Events */	
		char[255] text;		/* a char buffer for KeyPress Events */

		Log.d("enterMessageLoop()");
		/* look for events forever... */
		bool finished = false;
		while(!finished) {		
			/* get the next event and stuff it into our event variable.
		   		Note:  only events we set the mask for are detected!
			*/
			XNextEvent(x11display, &event);

			switch (event.type) {
				case Expose:
					if (event.xexpose.count==0) {
						/* the window was exposed redraw it! */
						//redraw();
						X11Window w = findWindow(event.xexpose.window);
						if (w) {

							w.processExpose();
						} else {
							Log.e("Window not found");
						}
					} else {
						Log.d("Expose: non-0 count");
					}
					break;
				case KeyPress:
					if (XLookupString(&event.xkey, text.ptr, 255, &key, cast(XComposeStatus*)null) == 1) {
						/* use the XLookupString routine to convert the invent
		   					KeyPress data into regular text.  Weird but necessary...
						*/
						if (text[0]=='q') {
							finished = true;
							break;
							//close_x();
						}
						Log.d("You pressed the key", text[0]);
					}
					break;
				case KeyRelease:
					Log.d("X11: KeyRelease event");
					X11Window w = findWindow(event.xkey.window);
					if (w) {
						//w.processExpose();
					} else {
						Log.e("Window not found");
					}
					break;
				case ButtonPress:
					if (event.type==ButtonPress) {
						/* tell where the mouse Button was Pressed */
						Log.d("You pressed a button at ",
							event.xbutton.x, ", ", event.xbutton.y);
						Log.d("...");
						//XClearArea(x11display, event.xbutton.window, 0, 0, 1, 1, true);
						X11Window w = findWindow(event.xbutton.window);
						if (w) {
							Log.e("Calling processExpose");
							w.processExpose();
						} else {
							Log.e("Window not found");
						}
					}
					break;
				case ButtonRelease:
					Log.d("X11: ButtonRelease event");
					X11Window w = findWindow(event.xbutton.window);
					if (w) {
						//w.processExpose();
					} else {
						Log.e("Window not found");
					}
					break;
				case MotionNotify:
					Log.d("X11: MotionNotify event");
					X11Window w = findWindow(event.xmotion.window);
					if (w) {
						//w.processExpose();
					} else {
						Log.e("Window not found");
					}
					break;
				case EnterNotify:
					Log.d("X11: EnterNotify event");
					X11Window w = findWindow(event.xcrossing.window);
					if (w) {
						//w.processExpose();
					} else {
						Log.e("Window not found");
					}
					break;
				case LeaveNotify:
					Log.d("X11: LeaveNotify event");
					X11Window w = findWindow(event.xcrossing.window);
					if (w) {
						//w.processExpose();
					} else {
						Log.e("Window not found");
					}
					break;
				case CreateNotify:
					Log.d("X11: CreateNotify event");
					X11Window w = findWindow(event.xcreatewindow.window);
					if (w) {
						//w.processExpose();
					} else {
						Log.e("Window not found");
					}
					break;
				case DestroyNotify:
					Log.d("X11: DestroyNotify event");
					X11Window w = findWindow(event.xdestroywindow.window);
					if (w) {
						//w.processExpose();
					} else {
						Log.e("Window not found");
					}
					break;
				case ResizeRequest:
					Log.d("X11: ResizeRequest event");
					X11Window w = findWindow(event.xresizerequest.window);
					if (w) {
						//w.processExpose();
					} else {
						Log.e("Window not found");
					}
					break;
				case FocusIn:
					Log.d("X11: FocusIn event");
					X11Window w = findWindow(event.xfocus.window);
					if (w) {
						//w.processExpose();
					} else {
						Log.e("Window not found");
					}
					break;
				case FocusOut:
					Log.d("X11: FocusOut event");
					X11Window w = findWindow(event.xfocus.window);
					if (w) {
						//w.processExpose();
					} else {
						Log.e("Window not found");
					}
					break;
				case KeymapNotify:
					Log.d("X11: KeymapNotify event");
					X11Window w = findWindow(event.xkeymap.window);
					if (w) {
						//w.processExpose();
					} else {
						Log.e("Window not found");
					}
					break;
				default:
					break;
			}
		}
		return 0;
	}

	/// retrieves text from clipboard (when mouseBuffer == true, use mouse selection clipboard - under linux)
	override dstring getClipboardText(bool mouseBuffer = false) {
		return "";
	}

	/// sets text to clipboard (when mouseBuffer == true, use mouse selection clipboard - under linux)
	override void setClipboardText(dstring text, bool mouseBuffer = false) {
		// todo
	}
	
	/// calls request layout for all windows
	override void requestLayout() {
		// todo
	}
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

	currentTheme = createDefaultTheme();

	/* use the information from the environment variable DISPLAY 
	   to create the X connection:
	*/	
	x11display = XOpenDisplay(null);
	if (!x11display) {
		Log.e("Cannot open X11 display");
		return 1;
	}

	x11screen = DefaultScreen(x11display);



	Log.d("X11 display=", x11display, " screen=", x11screen);

	X11Platform x11platform = new X11Platform();

	Platform.setInstance(x11platform);
	
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

	Log.d("Exiting main width result=", res);
	
	return res;
}
