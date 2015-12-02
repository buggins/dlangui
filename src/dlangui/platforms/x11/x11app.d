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
private __gshared XIM xim;

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
	private __gshared XIC xic;

	this(X11Platform platform, dstring caption, DWindow parent, uint flags, uint width = 0, uint height = 0) {
		_platform = platform;
		_caption = caption;
		//backgroundColor = 0xFFFFFF;
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
		XSelectInput(x11display, _win, KeyPressMask | KeyReleaseMask | ButtonPressMask | ButtonReleaseMask | 
			EnterWindowMask | LeaveWindowMask | PointerMotionMask | ButtonMotionMask | ExposureMask | VisibilityChangeMask |
			FocusChangeMask | KeymapStateMask | StructureNotifyMask);

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
		import std.utf : toUTF8;
		XSetStandardProperties(x11display, _win, cast(char*)_caption.toUTF8.toStringz, cast(char*)_caption.toUTF8.toStringz, None, cast(char**)null, 0, cast(XSizeHints*)null);
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
			_drawbuf.fill(backgroundColor);
			onDraw(_drawbuf);
			// draw buffer on X11 window
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
			//XSetClipOrigin(x11display, _gc, 0, 0);
			XPutImage(x11display, _win, 
				_gc, //DefaultGC(x11display, DefaultScreen(x11display)), 
				&img,
				0, 0, 0, 0,
				_drawbuf.width,
				_drawbuf.height);
			XFlush(x11display);
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

		drawUsingBitmap();

	}

	protected ButtonDetails _lbutton;
	protected ButtonDetails _mbutton;
	protected ButtonDetails _rbutton;

	ushort convertMouseFlags(uint flags) {
		ushort res = 0;
		if (flags & Button1Mask)
			res |= MouseFlag.LButton;
		if (flags & Button2Mask)
			res |= MouseFlag.RButton;
		if (flags & Button3Mask)
			res |= MouseFlag.MButton;
		return res;
	}
	
	MouseButton convertMouseButton(uint button) {
		if (button == Button1)
			return MouseButton.Left;
		if (button == Button2)
			return MouseButton.Right;
		if (button == Button3)
			return MouseButton.Middle;
		return MouseButton.None;
	}

	ushort lastFlags;
	short lastx;
	short lasty;
	uint _keyFlags;
	void processMouseEvent(MouseAction action, uint button, uint state, int x, int y) {
		MouseEvent event = null;
		if (action == MouseAction.Wheel) {
			// handle wheel
			short wheelDelta = cast(short)y;
			if (_keyFlags & KeyFlag.Shift)
				lastFlags |= MouseFlag.Shift;
			else
				lastFlags &= ~MouseFlag.Shift;
			if (_keyFlags & KeyFlag.Control)
				lastFlags |= MouseFlag.Control;
			else
				lastFlags &= ~MouseFlag.Control;
			if (_keyFlags & KeyFlag.Alt)
				lastFlags |= MouseFlag.Alt;
			else
				lastFlags &= ~MouseFlag.Alt;
			if (wheelDelta)
				event = new MouseEvent(action, MouseButton.None, lastFlags, lastx, lasty, wheelDelta);
		} else {
			lastFlags = convertMouseFlags(state);
			if (_keyFlags & KeyFlag.Shift)
				lastFlags |= MouseFlag.Shift;
			if (_keyFlags & KeyFlag.Control)
				lastFlags |= MouseFlag.Control;
			if (_keyFlags & KeyFlag.Alt)
				lastFlags |= MouseFlag.Alt;
			lastx = cast(short)x;
			lasty = cast(short)y;
			MouseButton btn = convertMouseButton(button);
			event = new MouseEvent(action, btn, lastFlags, lastx, lasty);
		}
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

	uint convertKeyCode(uint keyCode) {
		import x11.keysymdef;
		alias KeyCode = dlangui.core.events.KeyCode;
		switch(keyCode) {
			case XK_0:
				return KeyCode.KEY_0;
			case XK_1:
				return KeyCode.KEY_1;
			case XK_2:
				return KeyCode.KEY_2;
			case XK_3:
				return KeyCode.KEY_3;
			case XK_4:
				return KeyCode.KEY_4;
			case XK_5:
				return KeyCode.KEY_5;
			case XK_6:
				return KeyCode.KEY_6;
			case XK_7:
				return KeyCode.KEY_7;
			case XK_8:
				return KeyCode.KEY_8;
			case XK_9:
				return KeyCode.KEY_9;
			case XK_A:
				return KeyCode.KEY_A;
			case XK_B:
				return KeyCode.KEY_B;
			case XK_C:
				return KeyCode.KEY_C;
			case XK_D:
				return KeyCode.KEY_D;
			case XK_E:
				return KeyCode.KEY_E;
			case XK_F:
				return KeyCode.KEY_F;
			case XK_G:
				return KeyCode.KEY_G;
			case XK_H:
				return KeyCode.KEY_H;
			case XK_I:
				return KeyCode.KEY_I;
			case XK_J:
				return KeyCode.KEY_J;
			case XK_K:
				return KeyCode.KEY_K;
			case XK_L:
				return KeyCode.KEY_L;
			case XK_M:
				return KeyCode.KEY_M;
			case XK_N:
				return KeyCode.KEY_N;
			case XK_O:
				return KeyCode.KEY_O;
			case XK_P:
				return KeyCode.KEY_P;
			case XK_Q:
				return KeyCode.KEY_Q;
			case XK_R:
				return KeyCode.KEY_R;
			case XK_S:
				return KeyCode.KEY_S;
			case XK_T:
				return KeyCode.KEY_T;
			case XK_U:
				return KeyCode.KEY_U;
			case XK_V:
				return KeyCode.KEY_V;
			case XK_W:
				return KeyCode.KEY_W;
			case XK_X:
				return KeyCode.KEY_X;
			case XK_Y:
				return KeyCode.KEY_Y;
			case XK_Z:
				return KeyCode.KEY_Z;
			case XK_F1:
				return KeyCode.F1;
			case XK_F2:
				return KeyCode.F2;
			case XK_F3:
				return KeyCode.F3;
			case XK_F4:
				return KeyCode.F4;
			case XK_F5:
				return KeyCode.F5;
			case XK_F6:
				return KeyCode.F6;
			case XK_F7:
				return KeyCode.F7;
			case XK_F8:
				return KeyCode.F8;
			case XK_F9:
				return KeyCode.F9;
			case XK_F10:
				return KeyCode.F10;
			case XK_F11:
				return KeyCode.F11;
			case XK_F12:
				return KeyCode.F12;
			case XK_F13:
				return KeyCode.F13;
			case XK_F14:
				return KeyCode.F14;
			case XK_F15:
				return KeyCode.F15;
			case XK_F16:
				return KeyCode.F16;
			case XK_F17:
				return KeyCode.F17;
			case XK_F18:
				return KeyCode.F18;
			case XK_F19:
				return KeyCode.F19;
			case XK_F20:
				return KeyCode.F20;
			case XK_F21:
				return KeyCode.F21;
			case XK_F22:
				return KeyCode.F22;
			case XK_F23:
				return KeyCode.F23;
			case XK_F24:
				return KeyCode.F24;
			case XK_BackSpace:
				return KeyCode.BACK;
			case XK_space:
				return KeyCode.SPACE;
			case XK_Tab:
				return KeyCode.TAB;
			case XK_Return:
				return KeyCode.RETURN;
			case XK_Escape:
				return KeyCode.ESCAPE;
			case XK_Delete:
			//case 0x40000063: // dirty hack for Linux - key on keypad
				return KeyCode.DEL;
			case XK_Insert:
			//case 0x40000062: // dirty hack for Linux - key on keypad
				return KeyCode.INS;
			case XK_Home:
			//case 0x4000005f: // dirty hack for Linux - key on keypad
				return KeyCode.HOME;
			case XK_Page_Up:
			//case 0x40000061: // dirty hack for Linux - key on keypad
				return KeyCode.PAGEUP;
			case XK_End:
			//case 0x40000059: // dirty hack for Linux - key on keypad
				return KeyCode.END;
			case XK_Page_Down:
			//case 0x4000005b: // dirty hack for Linux - key on keypad
				return KeyCode.PAGEDOWN;
			case XK_Left:
			//case 0x4000005c: // dirty hack for Linux - key on keypad
				return KeyCode.LEFT;
			case XK_Right:
			//case 0x4000005e: // dirty hack for Linux - key on keypad
				return KeyCode.RIGHT;
			case XK_Up:
			//case 0x40000060: // dirty hack for Linux - key on keypad
				return KeyCode.UP;
			case XK_Down:
			//case 0x4000005a: // dirty hack for Linux - key on keypad
				return KeyCode.DOWN;
			case XK_Control_L:
				return KeyCode.LCONTROL;
			case XK_Shift_L:
				return KeyCode.LSHIFT;
			case XK_Alt_L:
				return KeyCode.LALT;
			case XK_Control_R:
				return KeyCode.RCONTROL;
			case XK_Shift_R:
				return KeyCode.RSHIFT;
			case XK_Alt_R:
				return KeyCode.RALT;
			case XK_slash:
				return KeyCode.KEY_DIVIDE;
			default:
				return 0x10000 | keyCode;
		}
	}
	
	uint convertKeyFlags(uint flags) {
		uint res;
		if (flags & ControlMask)
			res |= KeyFlag.Control;
		if (flags & ShiftMask)
			res |= KeyFlag.Shift;
		if (flags & LockMask)
			res |= KeyFlag.Alt;
//		if (flags & KMOD_RCTRL)
//			res |= KeyFlag.RControl | KeyFlag.Control;
//		if (flags & KMOD_RSHIFT)
//			res |= KeyFlag.RShift | KeyFlag.Shift;
//		if (flags & KMOD_RALT)
//			res |= KeyFlag.RAlt | KeyFlag.Alt;
//		if (flags & KMOD_LCTRL)
//			res |= KeyFlag.LControl | KeyFlag.Control;
//		if (flags & KMOD_LSHIFT)
//			res |= KeyFlag.LShift | KeyFlag.Shift;
//		if (flags & KMOD_LALT)
//			res |= KeyFlag.LAlt | KeyFlag.Alt;
		return res;
	}
	

	bool processKeyEvent(KeyAction action, uint keyCode, uint flags) {
		//debug(DebugSDL) 
		Log.d("processKeyEvent ", action, " X11 key=0x", format("%08x", keyCode), " X11 flags=0x", format("%08x", flags));
		keyCode = convertKeyCode(keyCode);
		flags = convertKeyFlags(flags);
		Log.d("processKeyEvent ", action, " converted key=0x", format("%08x", keyCode), " flags=0x", format("%08x", flags));

		alias KeyCode = dlangui.core.events.KeyCode;
		if (action == KeyAction.KeyDown) {
			switch(keyCode) {
				case KeyCode.ALT:
					flags |= KeyFlag.Alt;
					break;
				case KeyCode.RALT:
					flags |= KeyFlag.Alt | KeyFlag.RAlt;
					break;
				case KeyCode.LALT:
					flags |= KeyFlag.Alt | KeyFlag.LAlt;
					break;
				case KeyCode.CONTROL:
					flags |= KeyFlag.Control;
					break;
				case KeyCode.RCONTROL:
					flags |= KeyFlag.Control | KeyFlag.RControl;
					break;
				case KeyCode.LCONTROL:
					flags |= KeyFlag.Control | KeyFlag.LControl;
					break;
				case KeyCode.SHIFT:
					flags |= KeyFlag.Shift;
					break;
				case KeyCode.RSHIFT:
					flags |= KeyFlag.Shift | KeyFlag.RShift;
					break;
				case KeyCode.LSHIFT:
					flags |= KeyFlag.Shift | KeyFlag.LShift;
					break;
				default:
					break;
			}
		}
		_keyFlags = flags;
		
		debug(DebugSDL) Log.d("processKeyEvent ", action, " converted key=0x", format("%08x", keyCode), " converted flags=0x", format("%08x", flags));
		bool res = dispatchKeyEvent(new KeyEvent(action, keyCode, flags));
		//			if ((keyCode & 0x10000) && (keyCode & 0xF000) != 0xF000) {
		//				dchar[1] text;
		//				text[0] = keyCode & 0xFFFF;
		//				res = dispatchKeyEvent(new KeyEvent(KeyAction.Text, keyCode, flags, cast(dstring)text)) || res;
		//			}
		if (res) {
			debug(keys) Log.d("Calling update() after key event");
			invalidate();
		}
		return res;
	}

	bool processTextInput(dstring ds, uint flags) {
		flags = convertKeyFlags(flags);
		bool res = dispatchKeyEvent(new KeyEvent(KeyAction.Text, 0, flags, ds));
		if (res) {
			debug(keys) Log.d("Calling update() after text event");
			invalidate();
		}
		return res;
	}
	
	private long _nextExpectedTimerTs;

	/// schedule timer for interval in milliseconds - call window.onTimer when finished
	override protected void scheduleSystemTimer(long intervalMillis) {
		if (intervalMillis < 10)
			intervalMillis = 10;
		long nextts = currentTimeMillis + intervalMillis;
		if (!_nextExpectedTimerTs || _nextExpectedTimerTs > nextts)
			_nextExpectedTimerTs = nextts;
	}
	
	bool handleTimer() {
		if (!_nextExpectedTimerTs)
			return false;
		long ts = currentTimeMillis;
		if (ts >= _nextExpectedTimerTs) {
			_nextExpectedTimerTs = 0;
			onTimer();
			return true;
		}
		return false;
	}

	/// post event to handle in UI thread (this method can be used from background thread)
	override void postEvent(CustomEvent event) {
		super.postEvent(event);
		XEvent ev;
		ev.type = ClientMessage;
		ev.xclient.window = _win;
		ev.xclient.format = CUSTOM_EVENT;
		ev.xclient.data.l[0] = event.uniqueId;
		XSendEvent(x11display, _win, false, StructureNotifyMask, &ev);
		//		SDL_Event sdlevent;
//		sdlevent.user.type = USER_EVENT_ID;
//		sdlevent.user.code = cast(int)event.uniqueId;
//		sdlevent.user.windowID = windowId;
//		SDL_PushEvent(&sdlevent);
	}
}

private immutable int CUSTOM_EVENT = 32;

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

	bool handleTimers() {
		bool handled = false;
		foreach(w; _windowMap) {
			if (w.handleTimer()) {
				handled = true;
				break;
			}
		}
		return handled;
	}

	/**
	 * Starts application message loop.
	 * 
	 * When returned from this method, application is shutting down.
	 */
	override int enterMessageLoop() {
		import core.thread;
		XEvent event;		/* the XEvent declaration !!! */
		KeySym key;		/* a dealie-bob to handle KeyPress Events */	
		char[255] text;		/* a char buffer for KeyPress Events */

		Log.d("enterMessageLoop()");
		/* look for events forever... */
		bool finished = false;
		XComposeStatus compose;
		while(!finished) {		
			/* get the next event and stuff it into our event variable.
		   		Note:  only events we set the mask for are detected!
			*/
			handleTimers();
			if (!XPending(x11display)) {
				Thread.sleep(dur!("msecs")(10));
				continue;
			}
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
					Log.d("X11: KeyPress event");
					X11Window w = findWindow(event.xkey.window);
					if (w) {
						char[100] buf;
						KeySym ks;
						Status s;
						if (!w.xic) {
							w.xic = XCreateIC(xim,
								XNInputStyle, XIMPreeditNothing | XIMStatusNothing,
								XNClientWindow, w._win, 0);
							if (!w.xic) {
								Log.e("Cannot create input context");
							}
						}

						if (!w.xic)
							XLookupString(&event.xkey, buf.ptr, buf.length - 1, &ks, &compose);
						else {
							Xutf8LookupString(w.xic, &event.xkey, buf.ptr, cast(int)buf.length - 1, &ks, &s);
							if (s != XLookupChars && s != XLookupBoth)
								XLookupString(&event.xkey, buf.ptr, buf.length - 1, &ks, &compose);
						}
						foreach(ref ch; buf) {
							if (ch == 255 || ch < 32 || ch == 127)
								ch = 0;
						}
						string txt = fromStringz(buf.ptr).dup;
						import std.utf;
						dstring dtext;
						try {
							if (txt.length)
								dtext = toUTF32(txt);
						} catch (UTFException e) {
							// ignore, invalid text
						}
						Log.d("X11: KeyPress event bytes=", txt.length, " text=", txt, " dtext=", dtext);
						if (dtext.length) {
							w.processTextInput(dtext, event.xkey.state);
						} else {
							w.processKeyEvent(KeyAction.KeyDown, cast(uint)ks,
								//event.xkey.keycode, 
								event.xkey.state);
						}


					} else {
						Log.e("Window not found");
					}
					break;
				case KeyRelease:
					Log.d("X11: KeyRelease event");
					X11Window w = findWindow(event.xkey.window);
					if (w) {
						char[100] buf;
						KeySym ks;
						XLookupString(&event.xkey, buf.ptr, buf.length - 1, &ks, &compose);
						w.processKeyEvent(KeyAction.KeyUp, cast(uint)ks,
							//event.xkey.keycode, 
							event.xkey.state);
					} else {
						Log.e("Window not found");
					}
					break;
				case ButtonPress:
					Log.d("X11: ButtonPress event");
					X11Window w = findWindow(event.xbutton.window);
					if (w) {
						w.processMouseEvent(MouseAction.ButtonDown, event.xbutton.button, event.xbutton.state, event.xbutton.x, event.xbutton.y);
					} else {
						Log.e("Window not found");
					}
					break;
				case ButtonRelease:
					Log.d("X11: ButtonRelease event");
					X11Window w = findWindow(event.xbutton.window);
					if (w) {
						w.processMouseEvent(MouseAction.ButtonUp, event.xbutton.button, event.xbutton.state, event.xbutton.x, event.xbutton.y);
					} else {
						Log.e("Window not found");
					}
					break;
				case MotionNotify:
					Log.d("X11: MotionNotify event");
					X11Window w = findWindow(event.xmotion.window);
					if (w) {
						//w.processExpose();
						w.processMouseEvent(MouseAction.Move, 0, event.xmotion.state, event.xmotion.x, event.xmotion.y);
					} else {
						Log.e("Window not found");
					}
					break;
				case EnterNotify:
					Log.d("X11: EnterNotify event");
					X11Window w = findWindow(event.xcrossing.window);
					if (w) {
						w.processMouseEvent(MouseAction.FocusIn, 0, event.xcrossing.state, event.xcrossing.x, event.xcrossing.y);

						//w.processExpose();
					} else {
						Log.e("Window not found");
					}
					break;
				case LeaveNotify:
					Log.d("X11: LeaveNotify event");
					X11Window w = findWindow(event.xcrossing.window);
					if (w) {
						w.processMouseEvent(MouseAction.Leave, 0, event.xcrossing.state, event.xcrossing.x, event.xcrossing.y);
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
				case ClientMessage:
					Log.d("X11: ClientMessage event");
					X11Window w = findWindow(event.xclient.window);
					if (w) {
						if (event.xclient.format == CUSTOM_EVENT) {
							w.handlePostedEvent(cast(uint)event.xclient.data.l[0]);
						}
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
	xim = XOpenIM(x11display, null, null, null);
	if (!xim) {
		Log.e("Cannot open input method");
	}

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
