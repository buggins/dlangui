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

import x11.Xlib;
import x11.Xutil;
import x11.Xtos;
import x11.X;

pragma(lib, "X11");

private __gshared Display * x11display;
private __gshared int x11screen;

class X11Window : dlangui.platforms.common.platform.Window {
	protected X11Platform _platform;
	protected dstring _caption;
	protected x11.Xlib.Window _win;
	protected GC _gc;

	this(X11Platform platform, dstring caption, dlangui.platforms.common.platform.Window parent, uint flags, uint width = 0, uint height = 0) {
		_platform = platform;
		_caption = caption;
		debug Log.d("Creating SDL window");
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
		_win = XCreateSimpleWindow(x11display, DefaultRootWindow(x11display), 0, 0,	
			_dx, _dy, 5, white, black);

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
		_gc = XCreateGC(x11display, _win, 0, cast(XGCValues*)null);        
		
		/* here is another routine to set the foreground and background
	   		colors _currently_ in use in the window.
		*/
		XSetBackground(x11display, _gc, white);
		XSetForeground(x11display, _gc, black);
		
		/* clear the window and bring it on top of the other windows */
		XClearWindow(x11display, _win);
	}

	~this() {
		if (_gc)
			XFreeGC(x11display, _gc);
		if (_win)
			XDestroyWindow(x11display, _win);
	}

	/// show window
	override void show() {
		XMapRaised(x11display, _win);
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
	}

	/// close window
	override void close() {
	}
}

class X11Platform : Platform {

	this() {
	}

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
	override dlangui.platforms.common.platform.Window createWindow(dstring windowCaption, dlangui.platforms.common.platform.Window parent, uint flags = WindowFlag.Resizable, uint width = 0, uint height = 0) {
		int newwidth = width;
		int newheight = height;
		X11Window window = new X11Window(this, windowCaption, parent, flags, newwidth, newheight);
		return window;
	}

	/**
	 * close window
	 * 
	 * Closes window earlier created with createWindow()
	 */
	override void closeWindow(dlangui.platforms.common.platform.Window w) {
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
		
		/* look for events forever... */
		while(1) {		
			/* get the next event and stuff it into our event variable.
		   		Note:  only events we set the mask for are detected!
			*/
			XNextEvent(x11display, &event);
			
			if (event.type==Expose && event.xexpose.count==0) {
				/* the window was exposed redraw it! */
				//redraw();
			}
			if (event.type == KeyPress &&
				XLookupString(&event.xkey, text.ptr, 255, &key, cast(XComposeStatus*)null) == 1) {
				/* use the XLookupString routine to convert the invent
		   			KeyPress data into regular text.  Weird but necessary...
				*/
				if (text[0]=='q') {
					break;
					//close_x();
				}
				Log.d("You pressed the key", text[0]);
			}
			if (event.type==ButtonPress) {
				/* tell where the mouse Button was Pressed */
				Log.d("You pressed a button at ",
					event.xbutton.x, ", ", event.xbutton.y);
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


	/* use the information from the environment variable DISPLAY 
	   to create the X connection:
	*/	
	x11display = XOpenDisplay(null);
	if (!x11display) {
		Log.e("Cannot open X11 display");
		return 1;
	}

	x11screen = DefaultScreen(x11display);


	currentTheme = createDefaultTheme();

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
