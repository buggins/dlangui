// Written in the D programming language.

/**
This module contains implementation of SDL2 based backend for dlang library.


Synopsis:

----
import dlangui.platforms.sdl.sdlapp;

----

Copyright: Vadim Lopatin, 2014
License:   Boost License 1.0
Authors:   Vadim Lopatin, coolreader.org@gmail.com
*/
module dlangui.platforms.sdl.sdlapp;

version(USE_SDL):
import core.runtime;
import std.conv;
import std.string;
import std.utf;
import std.stdio;
import std.algorithm;
import std.file;

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
		
private __gshared uint USER_EVENT_ID;
private __gshared uint TIMER_EVENT_ID;

class SDLWindow : Window {
	SDLPlatform _platform;
	SDL_Window * _win;
	SDL_Renderer* _renderer;
	this(SDLPlatform platform, dstring caption, Window parent, uint flags, uint width = 0, uint height = 0) {
		_platform = platform;
		_caption = caption;
		debug Log.d("Creating SDL window");
        _dx = width;
        _dy = height;
		create(flags);
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


    /// post event to handle in UI thread (this method can be used from background thread)
    override void postEvent(CustomEvent event) {
        super.postEvent(event);
        SDL_Event sdlevent;
        sdlevent.user.type = USER_EVENT_ID;
        sdlevent.user.code = cast(int)event.uniqueId;
        sdlevent.user.windowID = windowId;
        SDL_PushEvent(&sdlevent);
    }


    version(USE_OPENGL) {
        static private bool _gl3Reloaded = false;
        private SDL_GLContext _context;
    }

    version(USE_OPENGL) {
        protected bool createContext(int versionMajor, int versionMinor) {
            Log.i("Trying to create OpenGL ", versionMajor, ".", versionMinor, " context");
            SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, versionMajor);
            SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, versionMinor);
            _context = SDL_GL_CreateContext(_win); // Create the actual context and make it current
            if (!_context)
                Log.e("SDL_GL_CreateContext failed: ", fromStringz(SDL_GetError()));
            else
                Log.i("Created successfully");
            return _context !is null;
        }
    }

	protected uint _flags;
	bool create(uint flags) {
        if (!_dx)
            _dx = 600;
        if (!_dy)
            _dy = 400;
		_flags = flags;
		uint windowFlags = SDL_WINDOW_HIDDEN;
		if (flags & WindowFlag.Resizable)
			windowFlags |= SDL_WINDOW_RESIZABLE;
		if (flags & WindowFlag.Fullscreen)
			windowFlags |= SDL_WINDOW_FULLSCREEN;
		// TODO: implement modal behavior
		//if (flags & WindowFlag.Modal)
		//	windowFlags |= SDL_WINDOW_INPUT_GRABBED;
        windowFlags |= SDL_WINDOW_ALLOW_HIGHDPI;
		version(USE_OPENGL) {
            if (_enableOpengl)
                windowFlags |= SDL_WINDOW_OPENGL;
            if (!_glSupport)
                _glSupport = new GLSupport();
        }
		_win = SDL_CreateWindow(toUTF8(_caption).toStringz, SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, 
                                _dx, _dy, 
                                windowFlags);
        version(USE_OPENGL) {
            if (!_win) {
                if (_enableOpengl) {
                    Log.e("SDL_CreateWindow failed - cannot create OpenGL window: ", fromStringz(SDL_GetError()));
                    _enableOpengl = false;
                    // recreate w/o OpenGL
                    windowFlags &= ~SDL_WINDOW_OPENGL;
					_win = SDL_CreateWindow(toUTF8(_caption).toStringz, SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, 
                                            _dx, _dy, 
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
                Log.i("Trying to create OpenGL 3.2 context");
                _context = SDL_GL_CreateContext(_win); // Create the actual context and make it current
                if (!_context) {
                    Log.e("SDL_GL_CreateContext failed: ", fromStringz(SDL_GetError()));
                    Log.w("trying other versions of OpenGL");
                    bool flg = false;
                    flg = flg || createContext(3, 3);
                    flg = flg || createContext(3, 1);
                    flg = flg || createContext(4, 0);
                    flg = flg || createContext(2, 1);
                    if (!flg) {
                        _enableOpengl = false;
                        Log.w("OpenGL support is disabled");
                    }
                }
                if (_context && !_gl3Reloaded) {
                    DerelictGL3.reload();
                    _gl3Reloaded = true;
                    if (!glSupport.valid && !glSupport.initShaders())
                        _enableOpengl = false;
                    fixSize();
                }
            }
        }
        if (!_enableOpengl) {
			_renderer = SDL_CreateRenderer(_win, -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC);
			if (!_renderer) {
				Log.e("SDL2: Failed to create renderer");
				return false;
			}
            fixSize();
        }
		windowCaption = _caption;
		return true;
	}
	
    void fixSize() {
        int w = 0;
        int h = 0;
        SDL_GetWindowSize(_win, &w, &h);
        doResize(w, h);
    }

    void doResize(int width, int height) {
        int w = 0;
        int h = 0;
        SDL_GL_GetDrawableSize(_win, &w, &h);
        version (Windows) {
            // DPI already calculated
        } else {
            // scale DPI
            if (w > width && h > height && width > 0 && height > 0)
                SCREEN_DPI = 96 * w / width;
        }
        onResize(std.algorithm.max(width, w), std.algorithm.max(height, h));
    }

	@property uint windowId() {
        if (_win)
			return SDL_GetWindowID(_win);
        return 0;
	}
		
	override void show() {
		Log.d("SDLWindow.show()");
		if (_mainWidget && !(_flags & WindowFlag.Resizable)) {
			_mainWidget.measure(SIZE_UNSPECIFIED, SIZE_UNSPECIFIED);
			SDL_SetWindowSize(_win, _mainWidget.measuredWidth, _mainWidget.measuredHeight);
		}
		SDL_ShowWindow(_win);
        if (_mainWidget)
            _mainWidget.setFocus();
        fixSize();
	}

	/// close window
	override void close() {
		Log.d("SDLWindow.close()");
		_platform.closeWindow(this);
	}


	protected dstring _caption;

	override @property dstring windowCaption() {
		return _caption;
	}

	override @property void windowCaption(dstring caption) {
		_caption = caption;
		if (_win)
			SDL_SetWindowTitle(_win, toUTF8(_caption).toStringz);
	}

	/// sets window icon
	@property override void windowIcon(DrawBufRef buf) {
		ColorDrawBuf icon = cast(ColorDrawBuf)buf.get;
		if (!icon) {
			Log.e("Trying to set null icon for window");
			return;
		}
        int iconw = 32;
        int iconh = 32;
        ColorDrawBuf iconDraw = new ColorDrawBuf(iconw, iconh);
        iconDraw.fill(0xE0E0E0);
        iconDraw.drawRescaled(Rect(0, 0, iconw, iconh), icon, Rect(0, 0, icon.width, icon.height));
		iconDraw.invertAlpha();
		SDL_Surface *surface = SDL_CreateRGBSurfaceFrom(iconDraw.scanLine(0), iconDraw.width, iconDraw.height, 32, iconDraw.width * 4, 0x00ff0000,0x0000ff00,0x000000ff,0xff000000);
		if (surface) {
			// The icon is attached to the window pointer
			SDL_SetWindowIcon(_win, surface); 
			// ...and the surface containing the icon pixel data is no longer required.
			SDL_FreeSurface(surface);
		} else {
			Log.e("failed to set window icon");
		}
		destroy(iconDraw);
	}

	/// after drawing, call to schedule redraw if animation is active
	override void scheduleAnimation() {
		invalidate();
	}

	protected uint _lastCursorType = CursorType.None;
	protected SDL_Cursor * [uint] _cursorMap;
	/// sets cursor type for window
	override protected void setCursorType(uint cursorType) {
		// override to support different mouse cursors
		if (_lastCursorType != cursorType) {
			if (cursorType == CursorType.None) {
				SDL_ShowCursor(SDL_DISABLE);
				return;
			}
			if (_lastCursorType == CursorType.None)
				SDL_ShowCursor(SDL_ENABLE);
			_lastCursorType = cursorType;
			SDL_Cursor * cursor;
			// check for existing cursor in map
			if (cursorType in _cursorMap) {
				//Log.d("changing cursor to ", cursorType);
				cursor = _cursorMap[cursorType];
				if (cursor)
					SDL_SetCursor(cursor);
				return;
			}
			// create new cursor
			switch (cursorType) {
				case CursorType.Arrow:
					cursor = SDL_CreateSystemCursor(SDL_SYSTEM_CURSOR_ARROW);
					break;
				case CursorType.IBeam:
					cursor = SDL_CreateSystemCursor(SDL_SYSTEM_CURSOR_IBEAM);
					break;
				case CursorType.Wait:
					cursor = SDL_CreateSystemCursor(SDL_SYSTEM_CURSOR_WAIT);
					break;
				case CursorType.WaitArrow:
					cursor = SDL_CreateSystemCursor(SDL_SYSTEM_CURSOR_WAITARROW);
					break;
				case CursorType.Crosshair:
					cursor = SDL_CreateSystemCursor(SDL_SYSTEM_CURSOR_CROSSHAIR);
					break;
				case CursorType.No:
					cursor = SDL_CreateSystemCursor(SDL_SYSTEM_CURSOR_NO);
					break;
				case CursorType.Hand:
					cursor = SDL_CreateSystemCursor(SDL_SYSTEM_CURSOR_HAND);
					break;
				case CursorType.SizeNWSE:
					cursor = SDL_CreateSystemCursor(SDL_SYSTEM_CURSOR_SIZENWSE);
					break;
				case CursorType.SizeNESW:
					cursor = SDL_CreateSystemCursor(SDL_SYSTEM_CURSOR_SIZENESW);
					break;
				case CursorType.SizeWE:
					cursor = SDL_CreateSystemCursor(SDL_SYSTEM_CURSOR_SIZEWE);
					break;
				case CursorType.SizeNS:
					cursor = SDL_CreateSystemCursor(SDL_SYSTEM_CURSOR_SIZENS);
					break;
				case CursorType.SizeAll:
					cursor = SDL_CreateSystemCursor(SDL_SYSTEM_CURSOR_SIZEALL);
					break;
				default:
					// TODO: support custom cursors
					cursor = SDL_CreateSystemCursor(SDL_SYSTEM_CURSOR_ARROW);
					break;
			}
			_cursorMap[cursorType] = cursor;
			if (cursor) {
				debug(DebugSDL) Log.d("changing cursor to ", cursorType);
				SDL_SetCursor(cursor);
			}
		}
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
        fixSize();

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
            _drawbuf.resetClipping();
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

    ushort lastFlags;
    short lastx;
    short lasty;
	void processMouseEvent(MouseAction action, uint button, uint state, int x, int y) {

        // correct mouse coordinates for HIGHDPI on mac
        int drawableW = 0;
        int drawableH = 0;
        int winW = 0;
        int winH = 0;
        SDL_GL_GetDrawableSize(_win, &drawableW, &drawableH);
        SDL_GetWindowSize(_win, &winW, &winH);
        if (drawableW != winW || drawableH != winH) {
            if (drawableW > 0 && winW > 0 && drawableH > 0 && drawableW > 0) {
                x = x * drawableW / winW;
                y = y * drawableH / winH;
            }
        }


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
            case SDLK_SPACE:
                return KeyCode.SPACE;
            case SDLK_TAB:
                return KeyCode.TAB;
            case SDLK_RETURN:
                return KeyCode.RETURN;
            case SDLK_ESCAPE:
                return KeyCode.ESCAPE;
            case SDLK_DELETE:
			case 0x40000063: // dirty hack for Linux - key on keypad
				return KeyCode.DEL;
			case SDLK_INSERT:
			case 0x40000062: // dirty hack for Linux - key on keypad
				return KeyCode.INS;
            case SDLK_HOME:
			case 0x4000005f: // dirty hack for Linux - key on keypad
				return KeyCode.HOME;
            case SDLK_PAGEUP:
			case 0x40000061: // dirty hack for Linux - key on keypad
				return KeyCode.PAGEUP;
            case SDLK_END:
			case 0x40000059: // dirty hack for Linux - key on keypad
                return KeyCode.END;
            case SDLK_PAGEDOWN:
			case 0x4000005b: // dirty hack for Linux - key on keypad
				return KeyCode.PAGEDOWN;
            case SDLK_LEFT:
			case 0x4000005c: // dirty hack for Linux - key on keypad
				return KeyCode.LEFT;
            case SDLK_RIGHT:
			case 0x4000005e: // dirty hack for Linux - key on keypad
				return KeyCode.RIGHT;
            case SDLK_UP:
			case 0x40000060: // dirty hack for Linux - key on keypad
				return KeyCode.UP;
            case SDLK_DOWN:
			case 0x4000005a: // dirty hack for Linux - key on keypad
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
            case '/':
                return KeyCode.KEY_DIVIDE;
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
			res |= KeyFlag.RControl | KeyFlag.Control;
        if (flags & KMOD_RSHIFT)
			res |= KeyFlag.RShift | KeyFlag.Shift;
        if (flags & KMOD_RALT)
			res |= KeyFlag.RAlt | KeyFlag.Alt;
        if (flags & KMOD_LCTRL)
			res |= KeyFlag.LControl | KeyFlag.Control;
        if (flags & KMOD_LSHIFT)
			res |= KeyFlag.LShift | KeyFlag.Shift;
        if (flags & KMOD_LALT)
			res |= KeyFlag.LAlt | KeyFlag.Alt;
        return res;
	}
				
    bool processTextInput(const char * s) {
        string str = fromStringz(s).dup;
        dstring ds = toUTF32(str);
        uint flags = convertKeyFlags(SDL_GetModState());
        bool res = dispatchKeyEvent(new KeyEvent(KeyAction.Text, 0, flags, ds));
        if (res) {
            debug(DebugSDL) Log.d("Calling update() after text event");
            invalidate();
        }
        return res;
    }

	uint _keyFlags;
	bool processKeyEvent(KeyAction action, uint keyCode, uint flags) {
		debug(DebugSDL) Log.d("processKeyEvent ", action, " SDL key=0x", format("%08x", keyCode), " SDL flags=0x", format("%08x", flags));
		keyCode = convertKeyCode(keyCode);
		flags = convertKeyFlags(flags);
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
	        debug(DebugSDL) Log.d("Calling update() after key event");
	        invalidate();
	    }
		return res;
	}

	uint _lastRedrawEventCode;
	/// request window redraw
	override void invalidate() {
		_platform.sendRedrawEvent(windowId, ++_lastRedrawEventCode);
	}
		
	void processRedrawEvent(uint code) {
		if (code == _lastRedrawEventCode)
			redraw();
	}


    private long _nextExpectedTimerTs;
    private SDL_TimerID _timerId = 0;

    /// schedule timer for interval in milliseconds - call window.onTimer when finished
    override protected void scheduleSystemTimer(long intervalMillis) {
        if (intervalMillis < 10)
            intervalMillis = 10;
        long nextts = currentTimeMillis + intervalMillis;
        if (_timerId && _nextExpectedTimerTs && _nextExpectedTimerTs < nextts + 10)
            return; // don't reschedule timer, timer event will be received soon
        if (_win) {
            if (_timerId) {
                SDL_RemoveTimer(_timerId);
                _timerId = 0;
            }
            _timerId = SDL_AddTimer(cast(uint)intervalMillis, &myTimerCallbackFunc, cast(void*)windowId);
            _nextExpectedTimerTs = nextts;
        }
    }

    void handleTimer(SDL_TimerID timerId) {
        SDL_RemoveTimer(_timerId);
        _timerId = 0;
		_nextExpectedTimerTs = 0;
		onTimer();
    }
}

private extern(C) uint myTimerCallbackFunc(uint interval, void *param) nothrow {
    uint windowId = cast(uint)param;
    SDL_Event sdlevent;
    sdlevent.user.type = TIMER_EVENT_ID;
    sdlevent.user.code = 0;
    sdlevent.user.windowID = windowId;
    SDL_PushEvent(&sdlevent);
    return(interval);
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
		destroy(_windowMap);
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

	SDLWindow _windowToClose;

	/// close window
	override void closeWindow(Window w) {
		SDLWindow window = cast(SDLWindow)w;
		_windowToClose = window;
	}

	/// calls request layout for all windows
	override void requestLayout() {
		foreach(w; _windowMap) {
			w.requestLayout();
			w.invalidate();
		}
	}

    /// handle theme change: e.g. reload some themed resources
    override void onThemeChanged() {
		foreach(w; _windowMap)
			w.dispatchThemeChanged();
    }

	private uint _redrawEventId;

	void sendRedrawEvent(uint windowId, uint code) {
		if (!_redrawEventId)
			_redrawEventId = SDL_RegisterEvents(1);
		SDL_Event event;
		event.type = _redrawEventId;
		event.user.windowID = windowId;
		event.user.code = code;
		SDL_PushEvent(&event);

	}

	override Window createWindow(dstring windowCaption, Window parent, uint flags = WindowFlag.Resizable, uint width = 0, uint height = 0) {
        setDefaultLanguageAndThemeIfNecessary();
        int oldDPI = SCREEN_DPI;
        int newwidth = width;
        int newheight = height;
        version(Windows) {
            newwidth = pointsToPixels(width);
            newheight = pointsToPixels(height);
        }
		SDLWindow res = new SDLWindow(this, windowCaption, parent, flags, newwidth, newheight);
		_windowMap[res.windowId] = res;
        if (oldDPI != SCREEN_DPI) {
            version(Windows) {
                newwidth = pointsToPixels(width);
                newheight = pointsToPixels(height);
                if (newwidth != width || newheight != height)
                    SDL_SetWindowSize(res._win, newwidth, newheight);
            }
            onThemeChanged();
        }
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
        bool skipNextQuit = false;
        while(!quit) {
			//redrawWindows();

			//if (SDL_PollEvent(&event)) {
			if (SDL_WaitEvent(&event)) {

				//Log.d("Event.type = ", event.type);

				if (event.type == SDL_QUIT) {
                    if (!skipNextQuit) {
					    Log.i("event.type == SDL_QUIT");
					    quit = true;
					    break;
                    }
                    skipNextQuit = false;
				} 
				if (_redrawEventId && event.type == _redrawEventId) {
					// user defined redraw event
					uint windowID = event.user.windowID;
					SDLWindow w = getWindow(windowID);
					if (w) {
						w.processRedrawEvent(event.user.code);
					}
					continue;
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
                                debug(DebugSDL) Log.d("SDL_WINDOWEVENT_RESIZED win=", event.window.windowID, " pos=", event.window.data1,
                                        ",", event.window.data2);
                                w.doResize(event.window.data1, event.window.data2);
                                w.redraw();
                                break;
                            case SDL_WINDOWEVENT_SIZE_CHANGED:
                                debug(DebugSDL) Log.d("SDL_WINDOWEVENT_SIZE_CHANGED win=", event.window.windowID, " pos=", event.window.data1,
                                        ",", event.window.data2);
                                w.doResize(event.window.data1, event.window.data2);
                                w.redraw();
                                break;
                            case SDL_WINDOWEVENT_CLOSE:
                                if (w.handleCanClose()) {
                                    debug(DebugSDL) Log.d("SDL_WINDOWEVENT_CLOSE win=", event.window.windowID);
                                    _windowMap.remove(windowID);
                                    destroy(w);
                                } else {
                                    skipNextQuit = true;
                                }
                                break;
                            case SDL_WINDOWEVENT_SHOWN:
                                debug(DebugSDL) Log.d("SDL_WINDOWEVENT_SHOWN");
                                break;
                            case SDL_WINDOWEVENT_HIDDEN:
                                debug(DebugSDL) Log.d("SDL_WINDOWEVENT_HIDDEN");
                                break;
                            case SDL_WINDOWEVENT_EXPOSED:
                                debug(DebugSDL) Log.d("SDL_WINDOWEVENT_EXPOSED");
                                w.redraw();
                                break;
                            case SDL_WINDOWEVENT_MOVED:
                                debug(DebugSDL) Log.d("SDL_WINDOWEVENT_MOVED");
                                break;
                            case SDL_WINDOWEVENT_MINIMIZED:
                                debug(DebugSDL) Log.d("SDL_WINDOWEVENT_MINIMIZED");
                                break;
                            case SDL_WINDOWEVENT_MAXIMIZED:
                                debug(DebugSDL) Log.d("SDL_WINDOWEVENT_MAXIMIZED");
                                break;
                            case SDL_WINDOWEVENT_RESTORED:
								debug(DebugSDL) Log.d("SDL_WINDOWEVENT_RESTORED");
                                break;
                            case SDL_WINDOWEVENT_ENTER:
								debug(DebugSDL) Log.d("SDL_WINDOWEVENT_ENTER");
                                break;
                            case SDL_WINDOWEVENT_LEAVE:
								debug(DebugSDL) Log.d("SDL_WINDOWEVENT_LEAVE");
                                break;
                            case SDL_WINDOWEVENT_FOCUS_GAINED:
								debug(DebugSDL) Log.d("SDL_WINDOWEVENT_FOCUS_GAINED");
                                break;
                            case SDL_WINDOWEVENT_FOCUS_LOST:
								debug(DebugSDL) Log.d("SDL_WINDOWEVENT_FOCUS_LOST");
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
                        debug(DebugSDL) Log.d("SDL_TEXTEDITING");
                        break;
                    case SDL_TEXTINPUT:
                        debug(DebugSDL) Log.d("SDL_TEXTINPUT");
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
                        SDLWindow w = getWindow(event.wheel.windowID);
                        if (w) {
                            debug(DebugSDL) Log.d("SDL_MOUSEWHEEL x=", event.wheel.x, " y=", event.wheel.y);
                            w.processMouseEvent(MouseAction.Wheel, 0, 0, event.wheel.x, event.wheel.y);
                        }
                        break;
                    default:
                        // not supported event
                        if (event.type == USER_EVENT_ID) {
                            SDLWindow w = getWindow(event.user.windowID);
                            if (w) {
                                w.handlePostedEvent(cast(uint)event.user.code);
                            }
                        } else if (event.type == TIMER_EVENT_ID) {
                            SDLWindow w = getWindow(event.user.windowID);
                            if (w) {
                                w.handleTimer(cast(uint)event.user.code);
                            }
                        }
                        break;
                }
				if (_windowToClose) {
					if (_windowToClose.windowId in _windowMap) {
						Log.i("Platform.closeWindow()");
						_windowMap.remove(_windowToClose.windowId);
						SDL_DestroyWindow(_windowToClose._win);
						Log.i("windowMap.length=", _windowMap.length);
						destroy(_windowToClose);
					}
					_windowToClose = null;
				}
				//
				if (_windowMap.length == 0) {
					//quit = true;
					SDL_Quit();
					quit = true;
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
        string s = fromStringz(txt).dup;
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

                // call SetProcessDPIAware to support HI DPI - fix by Kapps
                auto ulib = LoadLibraryA("user32.dll");
                alias SetProcessDPIAwareFunc = int function();
                auto setDpiFunc = cast(SetProcessDPIAwareFunc)GetProcAddress(ulib, "SetProcessDPIAware");
                if(setDpiFunc) // Should never fail, but just in case...
                    setDpiFunc();

                // Get screen DPI
                HDC dc = CreateCompatibleDC(NULL);
                SCREEN_DPI = GetDeviceCaps(dc, LOGPIXELSY);
                DeleteObject(dc);

                //SCREEN_DPI = 96 * 3 / 2;

                result = myWinMain(hInstance, hPrevInstance, lpCmdLine, nCmdShow);
                Log.i("calling Runtime.terminate()");
                // commented out to fix hanging runtime.terminate when there are background threads
                //Runtime.terminate();
            }
            catch (Throwable e) // catch any uncaught exceptions
            {
                MessageBoxW(null, toUTF16z(e.toString ~ "\nStack trace:\n" ~ defaultTraceHandler.toString), "Error",
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
        //Log.d("myWinMain()");
        string basePath = exePath();
        //Log.i("Current executable: ", exePath());
        string cmdline = fromStringz(lpCmdLine).dup;
        //Log.i("Command line: ", cmdline);
        string[] args = splitCmdLine(cmdline);
        //Log.i("Command line params: ", args);

        return sdlmain(args);
    }
} else {

	int DLANGUImain(string[] args)
	{
		
        initLogs();

        return sdlmain(args);
	}
}

int sdlmain(string[] args) {

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

    USER_EVENT_ID = SDL_RegisterEvents(1);
    TIMER_EVENT_ID = SDL_RegisterEvents(1);

    int request = SDL_GetDesktopDisplayMode(0,&displayMode);

    version(USE_OPENGL) {
        // we want OpenGL 3.2
        SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION,3);
        SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION,2);
        SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE);
        // Set OpenGL attributes
        SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);
        SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE, 24);
        // Share textures between contexts
        SDL_GL_SetAttribute(SDL_GL_SHARE_WITH_CURRENT_CONTEXT, 1);
    }

    SDLPlatform sdl = new SDLPlatform();
    if (!sdl.connect()) {
        return 1;
    }
    Platform.setInstance(sdl);

    int res = 0;

    version (unittest) {
    } else {
        res = UIAppMain(args);
    }
    
    //Log.e("Widget instance count after UIAppMain: ", Widget.instanceCount());

    Log.d("Destroying SDL platform");
    Platform.setInstance(null);

    releaseResourcesOnAppExit();

    Log.d("Exiting main");

    return res;
}
