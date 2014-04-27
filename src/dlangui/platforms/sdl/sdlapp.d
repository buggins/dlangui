module src.dlangui.platforms.sdl.sdlapp;

version(USE_SDL) {
	import std.string;
	import std.conv;

	import dlangui.core.logger;
	import dlangui.core.events;
	import dlangui.graphics.drawbuf;
	import dlangui.graphics.fonts;
	import dlangui.graphics.ftfonts;
	import dlangui.graphics.resources;
	import dlangui.widgets.styles;
	import dlangui.platforms.common.platform;

	import derelict.sdl2.sdl;

	version (USE_OPENGL) {
	    import dlangui.graphics.glsupport;
	}
	
	import derelict.opengl3.gl3;
	import derelict.opengl3.glx;

//	pragma(lib, "xcb");
//	pragma(lib, "xcb-shm");
//	pragma(lib, "xcb-image");
//	pragma(lib, "X11-xcb");
//	pragma(lib, "X11");
//	pragma(lib, "dl");	
		
	class SDLWindow : Window {

		this(string caption, Window parent) {
			_caption = caption;
			Log.d("Creating SDL window");
			create();
		}
		~this() {
			Log.d("Destroying window");
		}
			
		bool create() {
			windowCaption = _caption;
			return true;
		}
		
		@property uint windowId() {
			return 1; // TODO;
		}

		void draw(ColorDrawBuf buf) {
		}
		
		bool _derelictgl3Reloaded;
		override void show() {
			Log.d("XCBWindow.show()");
		}

		protected string _caption;

		override @property string windowCaption() {
			return _caption;
		}

		override @property void windowCaption(string caption) {
			_caption = caption;
			//TODO
		}

		void redraw() {
			
			if (_enableOpengl) {
                version(USE_OPENGL) {
                }
			} else {
				if (!_drawbuf)
					_drawbuf = new ColorDrawBuf(_dx, _dy);
				_drawbuf.resize(_dx, _dy);
				_drawbuf.fill(_backgroundColor);
				onDraw(_drawbuf);
				draw(_drawbuf);
			}
		}
		
		ColorDrawBuf _drawbuf;

		bool _exposeSent;
		void processExpose() {
			redraw();
			_exposeSent = false;
		}

		/// request window redraw
		override void invalidate() {
			if (_exposeSent)
				return;
			_exposeSent = true;
			//TODO
		}
				
		protected ButtonDetails _lbutton;
		protected ButtonDetails _mbutton;
		protected ButtonDetails _rbutton;
		void processMouseEvent(MouseAction action, ubyte detail, ushort state, short x, short y) {
			bool res = false; //dispatchMouseEvent(event);
	        if (res) {
	            Log.d("Calling update() after mouse event");
	            invalidate();
	        }
		}

		uint convertKeyCode(uint keyCode) {
			return 0x10000 | keyCode;
		}
		
		uint convertKeyFlags(uint flags) {
			return 0;
		}
				
		bool processKeyEvent(KeyAction action, uint keyCode, uint flags) {
			Log.d("processKeyEvent ", action, " x11 key=", keyCode, " x11 flags=", flags);
			keyCode = convertKeyCode(keyCode);
			flags = convertKeyFlags(flags);
			Log.d("processKeyEvent ", action, " converted key=", keyCode, " converted flags=", flags);
			bool res = dispatchKeyEvent(new KeyEvent(action, keyCode, flags));
			if (keyCode & 0x10000 && (keyCode & 0xF000) != 0xF000) {
				dchar[1] text;
				text[0] = keyCode & 0xFFFF;
				res = dispatchKeyEvent(new KeyEvent(KeyAction.Text, keyCode, flags, cast(dstring)text)) || res;
			}
	        if (res) {
	            Log.d("Calling update() after key event");
	            invalidate();
	        }
			return res;
		}
	}

	private __gshared bool _enableOpengl;

	class SDLPlatform : Platform {
		this() {
			
		}
		~this() {
			foreach(ref SDLWindow wnd; _windowMap) {
				destroy(wnd);
				wnd = null;
			}
			_windowMap.clear();
			disconnect();
		}
		void disconnect() {
			/* Cleanup */
		}
		bool connect() {
			
			try {
				DerelictGL3.load();
				_enableOpengl = true;
			} catch (Exception e) {
				Log.e("Cannot load opengl library", e);
			}
			try {
				// Load the SDL 2 library.
				DerelictSDL2.load();
			} catch (Exception e) {
				Log.e("Cannot load SDL2 library", e);
			}

			return true;
		}
		SDLWindow getWindow(uint w) {
			if (w in _windowMap)
				return _windowMap[w];
			return null;
		}
		override Window createWindow(string windowCaption, Window parent) {
			SDLWindow res = new SDLWindow(windowCaption, parent);
			_windowMap[res.windowId] = res;
			return res;
		}
		override int enterMessageLoop() {
			Log.i("entering message loop");
			Log.i("exiting message loop");
			return 0;
		}
		
    	/// retrieves text from clipboard (when mouseBuffer == true, use mouse selection clipboard - under linux)
		override dstring getClipboardText(bool mouseBuffer = false) {
			return ""d;
		}
		
    	/// sets text to clipboard (when mouseBuffer == true, use mouse selection clipboard - under linux)
		override void setClipboardText(dstring text, bool mouseBuffer = false) {
		}
		
		protected SDLWindow[uint] _windowMap;
	}

	// entry point
	extern(C) int UIAppMain(string[] args);
		
	int main(string[] args)
	{
		
		setStderrLogger();
		setLogLevel(LogLevel.Trace);

		FreeTypeFontManager ft = new FreeTypeFontManager();
		// TODO: use FontConfig
		ft.registerFont("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", FontFamily.SansSerif, "DejaVu", false, FontWeight.Normal);
		FontManager.instance = ft;

		currentTheme = createDefaultTheme();
				
		SDLPlatform sdl = new SDLPlatform();
		if (!sdl.connect()) {
			return 1;
		}
		Platform.setInstance(sdl);

		int res = 0;
			
		res = UIAppMain(args);

		Platform.setInstance(null);
		Log.d("Destroying SDL platform");
		destroy(sdl);
		
		currentTheme = null;
		drawableCache = null;
		imageCache = null;
		FontManager.instance = null;
		
		Log.d("Exiting main");

	  	return res;
	}

}
