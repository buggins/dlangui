module src.dlangui.platforms.sdl.sdlapp;

version(USE_SDL) {
    import core.runtime;
	import std.string;
	import std.conv;
    import std.string;
    import std.utf;
    import std.stdio;
    import std.algorithm;
    import std.file;

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
		SDL_Window * _win;
		SDL_Renderer* _renderer;
		this(string caption, Window parent) {
			_caption = caption;
			Log.d("Creating SDL window");
			create();
		}

		~this() {
			Log.d("Destroying window");
			if (_renderer)
				SDL_DestroyRenderer(_renderer);
			if (_win)
				SDL_DestroyWindow(_win);
		}
			
		bool create() {
			_win = SDL_CreateWindow(_caption.toStringz, SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, 700, 500, SDL_WINDOW_RESIZABLE);
			if (!_win) {
				Log.e("SDL2: Failed to create window");
				return false;
			}
			_renderer = SDL_CreateRenderer(_win, -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC);
			if (!_renderer) {
				Log.e("SDL2: Failed to create renderer");
				return false;
			}
			//windowCaption = _caption;
			return true;
		}
		
		@property uint windowId() {
			return 1; // TODO;
		}

		void draw(ColorDrawBuf buf) {
		}
		
		bool _derelictgl3Reloaded;
		override void show() {
			Log.d("SDLWindow.show()");
			SDL_ShowWindow(_win);
		}

		protected string _caption;

		override @property string windowCaption() {
			return _caption;
		}

		override @property void windowCaption(string caption) {
			_caption = caption;
			SDL_SetWindowTitle(_win, _caption.toStringz);
		}

		void redraw() {
			
			// Select the color for drawing. It is set to red here.
			SDL_SetRenderDrawColor(_renderer, 255, 0, 0, 255);
			
			// Clear the entire screen to our selected color.
			SDL_RenderClear(_renderer);
			
			// Up until now everything was drawn behind the scenes.
			// This will show the new, red contents of the window.
			SDL_RenderPresent(_renderer);

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

		void redrawWindows() {
			foreach(w; _windowMap)
				w.redraw();
		}

		override int enterMessageLoop() {
			Log.i("entering message loop");
			SDL_Event event;
			bool quit = false;
			while(true) {
				redrawWindows();
				//if (SDL_PollEvent(&event)) {
				if (SDL_WaitEvent(&event)) {
				    //Log.d("Event.type = ", event.type);
				    if (event.type == SDL_QUIT) {
					    Log.i("event.type == SDL_QUIT");
					    break;
				    } else if (event.type == SDL_WINDOWEVENT) {
                        switch (event.window.event) {
                            case SDL_WINDOWEVENT_RESIZED:
                                Log.d("SDL_WINDOWEVENT_RESIZED win=", event.window.windowID, " pos=", event.window.data1,
                                      ",", event.window.data2);
                                break;
                            case SDL_WINDOWEVENT_CLOSE:
                                Log.d("SDL_WINDOWEVENT_CLOSE win=", event.window.windowID);
                                break;
                            default:
                                break;
                        }
                    }
                }
			}
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

    version (Windows) {
        import win32.windows;
        import dlangui.platforms.windows.win32fonts;
        pragma(lib, "gdi32.lib");
        pragma(lib, "user32.lib");
        extern(Windows)
            int DLANGUIWinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance,
                               LPSTR lpCmdLine, int nCmdShow) {
                                   int result;

                                   try
                                   {
                                       Runtime.initialize();
                                       result = myWinMain(hInstance, hPrevInstance, lpCmdLine, nCmdShow);
                                       Runtime.terminate();
                                   }
                                   catch (Throwable e) // catch any uncaught exceptions
                                   {
                                       MessageBox(null, toUTF16z(e.toString()), "Error",
                                                  MB_OK | MB_ICONEXCLAMATION);
                                       result = 0;     // failed
                                   }

                                   return result;
                               }

        string[] splitCmdLine(string line) {
            string[] res;
            int start = 0;
            bool insideQuotes = false;
            for (int i = 0; i <= line.length; i++) {
                char ch = i < line.length ? line[i] : 0;
                if (ch == '\"') {
                    if (insideQuotes) {
                        if (i > start)
                            res ~= line[start .. i];
                        start = i + 1;
                        insideQuotes = false;
                    } else {
                        insideQuotes = true;
                        start = i + 1;
                    }
                } else if (!insideQuotes && (ch == ' ' || ch == '\t' || ch == 0)) {
                    if (i > start) {
                        res ~= line[start .. i];
                    }
                    start = i + 1;
                }
            }
            return res;
        }

        int myWinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int iCmdShow)
        {
            setFileLogger(std.stdio.File("ui.log", "w"));
            setLogLevel(LogLevel.Trace);
            Log.d("myWinMain()");
            string basePath = exePath();
            Log.i("Current executable: ", exePath());
            string cmdline = fromStringz(lpCmdLine);
            Log.i("Command line: ", cmdline);
            string[] args = splitCmdLine(cmdline);
            Log.i("Command line params: ", args);

		    try {
			    // Load the SDL 2 library.
			    DerelictSDL2.load();
		    } catch (Exception e) {
			    Log.e("Cannot load SDL2 library", e);
			    return 1;
		    }

            //_cmdShow = iCmdShow;
            //_hInstance = hInstance;

            FontManager.instance = new Win32FontManager();

            return sdlmain(args);
        }
    } else {

	    int main(string[] args)
	    {
		
		    setStderrLogger();
		    setLogLevel(LogLevel.Trace);

		    try {
			    // Load the SDL 2 library.
			    DerelictSDL2.load();
		    } catch (Exception e) {
			    Log.e("Cannot load SDL2 library", e);
			    return 1;
		    }

		    SDL_DisplayMode displayMode;
		    if (SDL_Init(SDL_INIT_VIDEO|SDL_INIT_TIMER|SDL_INIT_EVENTS) != 0) {
			    Log.e("Cannot init SDL2");
			    return 2;
		    }
		    scope(exit)SDL_Quit();
		    int request = SDL_GetDesktopDisplayMode(0,&displayMode);


		    FreeTypeFontManager ft = new FreeTypeFontManager();
		    // TODO: use FontConfig
		    ft.registerFont("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", FontFamily.SansSerif, "DejaVu", false, FontWeight.Normal);
		    FontManager.instance = ft;

            return sdlmain(args);
	    }
    }

    int sdlmain(string[] args) {
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
