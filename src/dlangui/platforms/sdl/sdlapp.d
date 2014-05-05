module src.dlangui.platforms.sdl.sdlapp;

version(USE_SDL) {
    import core.runtime;
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
	import dlangui.widgets.widget;
	import dlangui.platforms.common.platform;

	import derelict.sdl2.sdl;
	import derelict.opengl3.gl3;

	version (USE_OPENGL) {
        import dlangui.graphics.gldrawbuf;
	    import dlangui.graphics.glsupport;
	}
	

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
			debug Log.d("Creating SDL window");
			create();
		}

		~this() {
			debug Log.d("Destroying SDL window");
			if (_renderer)
				SDL_DestroyRenderer(_renderer);
            version(USE_OPENGL) {
                if (_context)
                    SDL_GL_DeleteContext(_context);
            }
			if (_win)
				SDL_DestroyWindow(_win);
			if (_drawbuf)
				destroy(_drawbuf);
		}

        version(USE_OPENGL) {
            static private bool _gl3Reloaded = false;
            private SDL_GLContext _context;
        }

		bool create() {
            uint windowFlags = SDL_WINDOW_RESIZABLE;
            version(USE_OPENGL) {
                if (_enableOpengl)
                    windowFlags |= SDL_WINDOW_OPENGL;
            }
			_win = SDL_CreateWindow(_caption.toStringz, SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, 
                                    700, 500, 
                                    windowFlags);
            version(USE_OPENGL) {
                if (!_win) {
                    if (_enableOpengl) {
                        Log.e("SDL_CreateWindow failed - cannot create OpenGL window: ", fromStringz(SDL_GetError()));
                        _enableOpengl = false;
                        // recreate w/o OpenGL
                        windowFlags &= ~SDL_WINDOW_OPENGL;
                        _win = SDL_CreateWindow(_caption.toStringz, SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, 
                                                700, 500, 
                                                windowFlags);
                    }
                }
            }
			if (!_win) {
				Log.e("SDL2: Failed to create window");
				return false;
			}
            version(USE_OPENGL) {
                if (_enableOpengl) {
                    _context = SDL_GL_CreateContext(_win); // Create the actual context and make it current
                    if (!_context) {
                        Log.e("SDL_GL_CreateContext failed: ", fromStringz(SDL_GetError()));
                        _enableOpengl = false;
                    } else if (!_gl3Reloaded) {
                        DerelictGL3.reload();
                        _gl3Reloaded = true;
                        if (!initShaders())
                            _enableOpengl = false;
                    }
                }
            }
            if (!_enableOpengl) {
			    _renderer = SDL_CreateRenderer(_win, -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC);
			    if (!_renderer) {
				    Log.e("SDL2: Failed to create renderer");
				    return false;
			    }
            }
			windowCaption = _caption;
			return true;
		}
		
		@property uint windowId() {
            if (_win)
			    return SDL_GetWindowID(_win);
            return 0;
		}

		
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

        SDL_Texture * _texture;
        int _txw;
        int _txh;
        private void updateBufferSize() {
            if (_texture && (_txw != _dx || _txh != _dy)) {
                SDL_DestroyTexture(_texture);
                _texture = null;
            }
            if (!_texture) {
                _texture = SDL_CreateTexture(_renderer,
                                           SDL_PIXELFORMAT_ARGB8888,
                                           SDL_TEXTUREACCESS_STATIC, //SDL_TEXTUREACCESS_STREAMING,
                                           _dx,
                                           _dy);
                _txw = _dx;
                _txh = _dy;
            }
        }

		private void draw(ColorDrawBuf buf) {
            updateBufferSize();
            SDL_Rect rect;
            rect.w = buf.width;
            rect.h = buf.height;
            SDL_UpdateTexture(_texture,
                              &rect,
                              cast(const void*)buf.scanLine(0),
                              buf.width * cast(int)uint.sizeof);
            SDL_RenderCopy(_renderer, _texture, &rect, &rect);
		}

		void redraw() {
            //Log.e("Widget instance count in SDLWindow.redraw: ", Widget.instanceCount());
            // check if size has been changed
            int w, h;
            SDL_GetWindowSize(_win, &w, &h);
            onResize(w, h);

			if (_enableOpengl) {
                version(USE_OPENGL) {
                    SDL_GL_MakeCurrent(_win, _context);
                    glDisable(GL_DEPTH_TEST);
                    glViewport(0, 0, _dx, _dy);
                    float a = 1.0f;
                    float r = ((_backgroundColor >> 16) & 255) / 255.0f;
                    float g = ((_backgroundColor >> 8) & 255) / 255.0f;
                    float b = ((_backgroundColor >> 0) & 255) / 255.0f;
                    glClearColor(r, g, b, a);
                    glClear(GL_COLOR_BUFFER_BIT);
                    GLDrawBuf buf = new GLDrawBuf(_dx, _dy, false);
                    buf.beforeDrawing();
                    onDraw(buf);
                    buf.afterDrawing();
                    SDL_GL_SwapWindow(_win);
                    destroy(buf);
                }
			} else {
                // Select the color for drawing.
                ubyte r = cast(ubyte)((_backgroundColor >> 16) & 255);
                ubyte g = cast(ubyte)((_backgroundColor >> 8) & 255);
                ubyte b = cast(ubyte)((_backgroundColor >> 0) & 255);
                SDL_SetRenderDrawColor(_renderer, r, g, b, 255);
                // Clear the entire screen to our selected color.
                SDL_RenderClear(_renderer);

				if (!_drawbuf)
					_drawbuf = new ColorDrawBuf(_dx, _dy);
				_drawbuf.resize(_dx, _dy);
				_drawbuf.fill(_backgroundColor);
				onDraw(_drawbuf);
				draw(_drawbuf);

                // Up until now everything was drawn behind the scenes.
                // This will show the new, red contents of the window.
                SDL_RenderPresent(_renderer);
			}
		}
		
		ColorDrawBuf _drawbuf;

		//bool _exposeSent;
		void processExpose() {
			redraw();
			//_exposeSent = false;
		}

		/// request window redraw
		override void invalidate() {
			//if (_exposeSent)
			//	return;
			//_exposeSent = true;
			//TODO optimize
            redraw();
		}
				
		protected ButtonDetails _lbutton;
		protected ButtonDetails _mbutton;
		protected ButtonDetails _rbutton;
        ushort convertMouseFlags(uint flags) {
            ushort res = 0;
            if (flags & SDL_BUTTON_LMASK)
                res |= MouseFlag.LButton;
            if (flags & SDL_BUTTON_RMASK)
                res |= MouseFlag.RButton;
            if (flags & SDL_BUTTON_MMASK)
                res |= MouseFlag.MButton;
            return res;
        }

        MouseButton convertMouseButton(uint button) {
            if (button == SDL_BUTTON_LEFT)
                return MouseButton.Left;
            if (button == SDL_BUTTON_RIGHT)
                return MouseButton.Right;
            if (button == SDL_BUTTON_MIDDLE)
                return MouseButton.Middle;
            return MouseButton.None;
        }

		void processMouseEvent(MouseAction action, uint button, uint state, int x, int y) {
            ushort flags = convertMouseFlags(state);
            MouseButton btn = convertMouseButton(button);
            MouseEvent event = new MouseEvent(action, btn, flags, cast(short)x, cast(short)y);
			bool res = dispatchMouseEvent(event);
	        if (res) {
	            Log.d("Calling update() after mouse event");
	            invalidate();
	        }
		}

		uint convertKeyCode(uint keyCode) {
            switch(keyCode) {
                case SDLK_0:
                    return KeyCode.KEY_0;
                case SDLK_1:
                    return KeyCode.KEY_1;
                case SDLK_2:
                    return KeyCode.KEY_2;
                case SDLK_3:
                    return KeyCode.KEY_3;
                case SDLK_4:
                    return KeyCode.KEY_4;
                case SDLK_5:
                    return KeyCode.KEY_5;
                case SDLK_6:
                    return KeyCode.KEY_6;
                case SDLK_7:
                    return KeyCode.KEY_7;
                case SDLK_8:
                    return KeyCode.KEY_8;
                case SDLK_9:
                    return KeyCode.KEY_9;
                case SDLK_a:
                    return KeyCode.KEY_A;
                case SDLK_b:
                    return KeyCode.KEY_B;
                case SDLK_c:
                    return KeyCode.KEY_C;
                case SDLK_d:
                    return KeyCode.KEY_D;
                case SDLK_e:
                    return KeyCode.KEY_E;
                case SDLK_f:
                    return KeyCode.KEY_F;
                case SDLK_g:
                    return KeyCode.KEY_G;
                case SDLK_h:
                    return KeyCode.KEY_H;
                case SDLK_i:
                    return KeyCode.KEY_I;
                case SDLK_j:
                    return KeyCode.KEY_J;
                case SDLK_k:
                    return KeyCode.KEY_K;
                case SDLK_l:
                    return KeyCode.KEY_L;
                case SDLK_m:
                    return KeyCode.KEY_M;
                case SDLK_n:
                    return KeyCode.KEY_N;
                case SDLK_o:
                    return KeyCode.KEY_O;
                case SDLK_p:
                    return KeyCode.KEY_P;
                case SDLK_q:
                    return KeyCode.KEY_Q;
                case SDLK_r:
                    return KeyCode.KEY_R;
                case SDLK_s:
                    return KeyCode.KEY_S;
                case SDLK_t:
                    return KeyCode.KEY_T;
                case SDLK_u:
                    return KeyCode.KEY_U;
                case SDLK_v:
                    return KeyCode.KEY_V;
                case SDLK_w:
                    return KeyCode.KEY_W;
                case SDLK_x:
                    return KeyCode.KEY_X;
                case SDLK_y:
                    return KeyCode.KEY_Y;
                case SDLK_z:
                    return KeyCode.KEY_Z;
                case SDLK_F1:
                    return KeyCode.F1;
                case SDLK_F2:
                    return KeyCode.F2;
                case SDLK_F3:
                    return KeyCode.F3;
                case SDLK_F4:
                    return KeyCode.F4;
                case SDLK_F5:
                    return KeyCode.F5;
                case SDLK_F6:
                    return KeyCode.F6;
                case SDLK_F7:
                    return KeyCode.F7;
                case SDLK_F8:
                    return KeyCode.F8;
                case SDLK_F9:
                    return KeyCode.F9;
                case SDLK_F10:
                    return KeyCode.F10;
                case SDLK_F11:
                    return KeyCode.F11;
                case SDLK_F12:
                    return KeyCode.F12;
                case SDLK_F13:
                    return KeyCode.F13;
                case SDLK_F14:
                    return KeyCode.F14;
                case SDLK_F15:
                    return KeyCode.F15;
                case SDLK_F16:
                    return KeyCode.F16;
                case SDLK_F17:
                    return KeyCode.F17;
                case SDLK_F18:
                    return KeyCode.F18;
                case SDLK_F19:
                    return KeyCode.F19;
                case SDLK_F20:
                    return KeyCode.F20;
                case SDLK_F21:
                    return KeyCode.F21;
                case SDLK_F22:
                    return KeyCode.F22;
                case SDLK_F23:
                    return KeyCode.F23;
                case SDLK_F24:
                    return KeyCode.F24;
                case SDLK_BACKSPACE:
                    return KeyCode.BACK;
                case SDLK_TAB:
                    return KeyCode.TAB;
                case SDLK_RETURN:
                    return KeyCode.RETURN;
                case SDLK_ESCAPE:
                    return KeyCode.ESCAPE;
                case SDLK_DELETE:
                    return KeyCode.DEL;
                case SDLK_INSERT:
                    return KeyCode.INS;
                case SDLK_HOME:
                    return KeyCode.HOME;
                case SDLK_PAGEUP:
                    return KeyCode.PAGEUP;
                case SDLK_END:
                    return KeyCode.END;
                case SDLK_PAGEDOWN:
                    return KeyCode.PAGEDOWN;
                case SDLK_LEFT:
                    return KeyCode.LEFT;
                case SDLK_RIGHT:
                    return KeyCode.RIGHT;
                case SDLK_UP:
                    return KeyCode.UP;
                case SDLK_DOWN:
                    return KeyCode.DOWN;
                case SDLK_LCTRL:
                    return KeyCode.LCONTROL;
                case SDLK_LSHIFT:
                    return KeyCode.LSHIFT;
                case SDLK_LALT:
                    return KeyCode.LALT;
                case SDLK_RCTRL:
                    return KeyCode.RCONTROL;
                case SDLK_RSHIFT:
                    return KeyCode.RSHIFT;
                case SDLK_RALT:
                    return KeyCode.RALT;
                default:
                    return 0x10000 | keyCode;
            }
		}
		
		uint convertKeyFlags(uint flags) {
            uint res;
            if (flags & KMOD_CTRL)
                res |= KeyFlag.Control;
            if (flags & KMOD_SHIFT)
                res |= KeyFlag.Shift;
            if (flags & KMOD_ALT)
                res |= KeyFlag.Alt;
            if (flags & KMOD_RCTRL)
                res |= KeyFlag.RControl;
            if (flags & KMOD_RSHIFT)
                res |= KeyFlag.RShift;
            if (flags & KMOD_RALT)
                res |= KeyFlag.RAlt;
            if (flags & KMOD_LCTRL)
                res |= KeyFlag.LControl;
            if (flags & KMOD_LSHIFT)
                res |= KeyFlag.LShift;
            if (flags & KMOD_LALT)
                res |= KeyFlag.LAlt;
            return res;
		}
				
        bool processTextInput(const char * s) {
            string str = fromStringz(s);
            dstring ds = toUTF32(str);
            uint flags = convertKeyFlags(SDL_GetModState());
            bool res = dispatchKeyEvent(new KeyEvent(KeyAction.Text, 0, flags, ds));
            if (res) {
                Log.d("Calling update() after text event");
                invalidate();
            }
            return res;
        }
        bool processKeyEvent(KeyAction action, uint keyCode, uint flags) {
            Log.d("processKeyEvent ", action, " SDL key=", keyCode, " SDL flags=", flags);
			keyCode = convertKeyCode(keyCode);
			flags = convertKeyFlags(flags);
			Log.d("processKeyEvent ", action, " converted key=", keyCode, " converted flags=", flags);
			bool res = dispatchKeyEvent(new KeyEvent(action, keyCode, flags));
//			if ((keyCode & 0x10000) && (keyCode & 0xF000) != 0xF000) {
//				dchar[1] text;
//				text[0] = keyCode & 0xFFFF;
//				res = dispatchKeyEvent(new KeyEvent(KeyAction.Text, keyCode, flags, cast(dstring)text)) || res;
//			}
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
			

			return true;
		}

		SDLWindow getWindow(uint id) {
			if (id in _windowMap)
				return _windowMap[id];
			return null;
		}

		override Window createWindow(string windowCaption, Window parent) {
			SDLWindow res = new SDLWindow(windowCaption, parent);
			_windowMap[res.windowId] = res;
			return res;
		}

        //void redrawWindows() {
        //    foreach(w; _windowMap)
        //        w.redraw();
        //}

		override int enterMessageLoop() {
			Log.i("entering message loop");
			SDL_Event event;
			bool quit = false;
            while(true) {
				//redrawWindows();

				//if (SDL_PollEvent(&event)) {
				if (SDL_WaitEvent(&event)) {

				    //Log.d("Event.type = ", event.type);

				    if (event.type == SDL_QUIT) {
					    Log.i("event.type == SDL_QUIT");
					    break;
				    } 

                    switch (event.type) {
                        case SDL_WINDOWEVENT:
                        {
                            // WINDOW EVENTS
                            uint windowID = event.window.windowID;
                            SDLWindow w = getWindow(windowID);
                            if (!w) {
                                Log.w("SDL_WINDOWEVENT ", event.window.event, " received with unknown id ", windowID);
                                break;
                            }
                            // found window
                            switch (event.window.event) {
                                case SDL_WINDOWEVENT_RESIZED:
                                    Log.d("SDL_WINDOWEVENT_RESIZED win=", event.window.windowID, " pos=", event.window.data1,
                                          ",", event.window.data2);
                                    break;
                                case SDL_WINDOWEVENT_SIZE_CHANGED:
                                    Log.d("SDL_WINDOWEVENT_SIZE_CHANGED win=", event.window.windowID, " pos=", event.window.data1,
                                            ",", event.window.data2);
                                    w.onResize(event.window.data1, event.window.data2);
                                    break;
                                case SDL_WINDOWEVENT_CLOSE:
                                    Log.d("SDL_WINDOWEVENT_CLOSE win=", event.window.windowID);
                                    _windowMap.remove(windowID);
                                    destroy(w);
                                    break;
                                case SDL_WINDOWEVENT_SHOWN:
                                    Log.d("SDL_WINDOWEVENT_SHOWN");
                                    break;
                                case SDL_WINDOWEVENT_HIDDEN:
                                    Log.d("SDL_WINDOWEVENT_HIDDEN");
                                    break;
                                case SDL_WINDOWEVENT_EXPOSED:
                                    Log.d("SDL_WINDOWEVENT_EXPOSED");
                                    w.redraw();
                                    break;
                                case SDL_WINDOWEVENT_MOVED:
                                    Log.d("SDL_WINDOWEVENT_MOVED");
                                    break;
                                case SDL_WINDOWEVENT_MINIMIZED:
                                    Log.d("SDL_WINDOWEVENT_MINIMIZED");
                                    break;
                                case SDL_WINDOWEVENT_MAXIMIZED:
                                    Log.d("SDL_WINDOWEVENT_MAXIMIZED");
                                    break;
                                case SDL_WINDOWEVENT_RESTORED:
                                    Log.d("SDL_WINDOWEVENT_MAXIMIZED");
                                    break;
                                case SDL_WINDOWEVENT_ENTER:
                                    Log.d("SDL_WINDOWEVENT_MAXIMIZED");
                                    break;
                                case SDL_WINDOWEVENT_LEAVE:
                                    Log.d("SDL_WINDOWEVENT_MAXIMIZED");
                                    break;
                                case SDL_WINDOWEVENT_FOCUS_GAINED:
                                    Log.d("SDL_WINDOWEVENT_MAXIMIZED");
                                    break;
                                case SDL_WINDOWEVENT_FOCUS_LOST:
                                    Log.d("SDL_WINDOWEVENT_MAXIMIZED");
                                    break;
                                default:
                                    break;
                            }
                            break;
                        }
                        case SDL_KEYDOWN:
                            SDLWindow w = getWindow(event.key.windowID);
                            if (w) {
                                w.processKeyEvent(KeyAction.KeyDown, event.key.keysym.sym, event.key.keysym.mod);
                                SDL_StartTextInput();
                            }
                            break;
                        case SDL_KEYUP:
                            SDLWindow w = getWindow(event.key.windowID);
                            if (w) {
                                w.processKeyEvent(KeyAction.KeyUp, event.key.keysym.sym, event.key.keysym.mod);
                            }
                            break;
                        case SDL_TEXTEDITING:
                            Log.d("SDL_TEXTEDITING");
                            break;
                        case SDL_TEXTINPUT:
                            Log.d("SDL_TEXTINPUT");
                            SDLWindow w = getWindow(event.text.windowID);
                            if (w) {
                                w.processTextInput(event.text.text.ptr);
                            }
                            break;
                        case SDL_MOUSEMOTION:
                            SDLWindow w = getWindow(event.motion.windowID);
                            if (w) {
                                w.processMouseEvent(MouseAction.Move, 0, event.motion.state, event.motion.x, event.motion.y);
                            }
                            break;
                        case SDL_MOUSEBUTTONDOWN:
                            SDLWindow w = getWindow(event.button.windowID);
                            if (w) {
                                w.processMouseEvent(MouseAction.ButtonDown, event.button.button, event.button.state, event.button.x, event.button.y);
                            }
                            break;
                        case SDL_MOUSEBUTTONUP:
                            SDLWindow w = getWindow(event.button.windowID);
                            if (w) {
                                w.processMouseEvent(MouseAction.ButtonUp, event.button.button, event.button.state, event.button.x, event.button.y);
                            }
                            break;
                        case SDL_MOUSEWHEEL:
                            break;
                        default:
                            // not supported event
                            break;
                    }
                }
			}
			Log.i("exiting message loop");
			return 0;
		}
		
    	/// retrieves text from clipboard (when mouseBuffer == true, use mouse selection clipboard - under linux)
		override dstring getClipboardText(bool mouseBuffer = false) {
            if (!SDL_HasClipboardText())
			    return ""d;
            char * txt = SDL_GetClipboardText();
            if (!txt)
                return ""d;
            string s = fromStringz(txt);
            SDL_free(txt);
            return toUTF32(s);
		}
		
    	/// sets text to clipboard (when mouseBuffer == true, use mouse selection clipboard - under linux)
		override void setClipboardText(dstring text, bool mouseBuffer = false) {
            string s = toUTF8(text);
            SDL_SetClipboardText(s.toStringz);
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
                    LPSTR lpCmdLine, int nCmdShow) 
            {
                int result;

                try
                {
                    Runtime.initialize();
                    result = myWinMain(hInstance, hPrevInstance, lpCmdLine, nCmdShow);
                    Log.i("calling Runtime.terminate()");
                    Runtime.terminate();
                }
                catch (Throwable e) // catch any uncaught exceptions
                {
                    MessageBox(null, toUTF16z(e.toString ~ "\nStack trace:\n" ~ defaultTraceHandler.toString), "Error",
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


		    FreeTypeFontManager ft = new FreeTypeFontManager();
		    // TODO: use FontConfig
		    ft.registerFont("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", FontFamily.SansSerif, "DejaVu", false, FontWeight.Normal);
		    FontManager.instance = ft;

            return sdlmain(args);
	    }
    }

    int sdlmain(string[] args) {
        currentTheme = createDefaultTheme();

        try {
            // Load the SDL 2 library.
            DerelictSDL2.load();
        } catch (Exception e) {
            Log.e("Cannot load SDL2 library", e);
            return 1;
        }

        version(USE_OPENGL) {
            try {
                DerelictGL3.load();
                _enableOpengl = true;
            } catch (Exception e) {
                Log.e("Cannot load opengl library", e);
            }
        }

        SDL_DisplayMode displayMode;
        if (SDL_Init(SDL_INIT_VIDEO|SDL_INIT_TIMER|SDL_INIT_EVENTS) != 0) {
            Log.e("Cannot init SDL2");	
            return 2;
        }
        scope(exit)SDL_Quit();
        int request = SDL_GetDesktopDisplayMode(0,&displayMode);

        version(USE_OPENGL) {
            // we want OpenGL 3.3
            SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION,3);
            SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION,2);
            // Set OpenGL attributes
            SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);
            SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE, 24);
        }

        SDLPlatform sdl = new SDLPlatform();
        if (!sdl.connect()) {
            return 1;
        }
        Platform.setInstance(sdl);

        int res = 0;

        res = UIAppMain(args);
        //Log.e("Widget instance count after UIAppMain: ", Widget.instanceCount());

        Log.d("Destroying SDL platform");
        Platform.setInstance(null);

        //
		debug(resalloc) {
            Widget.shuttingDown();
        }

        currentTheme = null;
        drawableCache = null;
        imageCache = null;
        FontManager.instance = null;
        debug(resalloc) {
			if (DrawBuf.instanceCount > 0) {
				Log.e("Non-zero DrawBuf instance count when exiting: ", DrawBuf.instanceCount);
			}
			if (Style.instanceCount > 0) {
				Log.e("Non-zero Style instance count when exiting: ", Style.instanceCount);
			}
			if (Widget.instanceCount() > 0) {
                Log.e("Non-zero Widget instance count when exiting: ", Widget.instanceCount);
            }
			if (ImageDrawable.instanceCount > 0) {
				Log.e("Non-zero ImageDrawable instance count when exiting: ", ImageDrawable.instanceCount);
			}
        }
        Log.d("Exiting main");

        return res;
    }

}
