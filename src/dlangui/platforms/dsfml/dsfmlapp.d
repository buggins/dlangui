module dlangui.platforms.dsfml.dsfmlapp;

version(USE_DSFML):

import dlangui.platforms.common.platform;
import dsfml.graphics;
import std.array;

import dlangui.core.collections;
import dlangui.core.logger;
import dlangui.widgets.widget;
import dlangui.widgets.popup;
import dlangui.graphics.drawbuf;
import dlangui.core.stdaction;
import dlangui.dialogs.msgbox;

private import dlangui.graphics.gldrawbuf;

/**
 * Window abstraction layer. Widgets can be shown only inside window.
 * 
 */
class DSFMLWindow : dlangui.platforms.common.platform.Window {

    private RenderWindow _wnd;
    private bool _ownRenderWindow;
    static private bool _gl3Reloaded = false;

    @property RenderWindow wnd() { return _wnd; }

    this(RenderWindow wnd, bool own) {
        _wnd = wnd;
        _ownRenderWindow = own;
        super();
        auto sz = wnd.size;
        onResize(sz.x, sz.y);
    }

    ~this() {
        if (_ownRenderWindow) {
            destroy(_wnd);
        }
        _wnd = null;
    }

    override void show() {
    }

	/// returns window caption
    override @property dstring windowCaption() {
        // TODO
        return ""d;
    }
	/// sets window caption
    override @property void windowCaption(dstring caption) {
        // TODO
    }
	/// sets window icon
	override @property void windowIcon(DrawBufRef icon) {
        // TODO
    }
    /// request window redraw
    override void invalidate() {
        // TODO
    }
	/// close window
	override void close() {
        // TODO
    }

    void draw() {
        paintUsingOpenGL();
    }

    private void paintUsingOpenGL() {
        import derelict.opengl3.gl3;
        import dlangui.graphics.gldrawbuf;
        import dlangui.graphics.glsupport;
        if (!_gl3Reloaded) {
            DerelictGL3.reload();
            _gl3Reloaded = true;
            if (!glSupport.valid && !glSupport.initShaders()) {
                Log.d("Cannot init opengl");
                assert(0);
            }
        }


        glDisable(GL_DEPTH_TEST);
        glViewport(0, 0, _dx, _dy);
		float a = 1.0f;
		float r = ((_backgroundColor >> 16) & 255) / 255.0f;
		float g = ((_backgroundColor >> 8) & 255) / 255.0f;
		float b = ((_backgroundColor >> 0) & 255) / 255.0f;
        //glClearColor(r, g, b, a);
        //glClear(GL_COLOR_BUFFER_BIT);

        GLDrawBuf buf = new GLDrawBuf(_dx, _dy, false);

        buf.beforeDrawing();
        onDraw(buf);
        buf.afterDrawing();
    }

    private MouseButton translateButton(uint btn) {
        switch(btn) {
            default:
            case Mouse.Button.Left:
                return MouseButton.Left;
            case Mouse.Button.Right:
                return MouseButton.Right;
            case Mouse.Button.Middle:
                return MouseButton.Middle;
            case Mouse.Button.XButton1:
                return MouseButton.XButton1;
            case Mouse.Button.XButton2:
                return MouseButton.XButton2;
        }
    }

    private uint translateKey(uint key) {
        switch(key) {
            case Keyboard.Key.A: return KeyCode.KEY_A;
            case Keyboard.Key.B: return KeyCode.KEY_B;
            case Keyboard.Key.C: return KeyCode.KEY_C;
            case Keyboard.Key.D: return KeyCode.KEY_D;
            case Keyboard.Key.E: return KeyCode.KEY_E;
            case Keyboard.Key.F: return KeyCode.KEY_F;
            case Keyboard.Key.G: return KeyCode.KEY_G;
            case Keyboard.Key.H: return KeyCode.KEY_H;
            case Keyboard.Key.I: return KeyCode.KEY_I;
            case Keyboard.Key.J: return KeyCode.KEY_J;
            case Keyboard.Key.K: return KeyCode.KEY_K;
            case Keyboard.Key.L: return KeyCode.KEY_L;
            case Keyboard.Key.M: return KeyCode.KEY_M;
            case Keyboard.Key.N: return KeyCode.KEY_N;
            case Keyboard.Key.O: return KeyCode.KEY_O;
            case Keyboard.Key.P: return KeyCode.KEY_P;
            case Keyboard.Key.Q: return KeyCode.KEY_Q;
            case Keyboard.Key.R: return KeyCode.KEY_R;
            case Keyboard.Key.S: return KeyCode.KEY_S;
            case Keyboard.Key.T: return KeyCode.KEY_T;
            case Keyboard.Key.U: return KeyCode.KEY_U;
            case Keyboard.Key.V: return KeyCode.KEY_V;
            case Keyboard.Key.W: return KeyCode.KEY_W;
            case Keyboard.Key.X: return KeyCode.KEY_X;
            case Keyboard.Key.Y: return KeyCode.KEY_Y;
            case Keyboard.Key.Z: return KeyCode.KEY_Z;
            case Keyboard.Key.Num0: return KeyCode.KEY_0;
            case Keyboard.Key.Num1: return KeyCode.KEY_1;
            case Keyboard.Key.Num2: return KeyCode.KEY_2;
            case Keyboard.Key.Num3: return KeyCode.KEY_3;
            case Keyboard.Key.Num4: return KeyCode.KEY_4;
            case Keyboard.Key.Num5: return KeyCode.KEY_5;
            case Keyboard.Key.Num6: return KeyCode.KEY_6;
            case Keyboard.Key.Num7: return KeyCode.KEY_7;
            case Keyboard.Key.Num8: return KeyCode.KEY_8;
            case Keyboard.Key.Num9: return KeyCode.KEY_9;
            case Keyboard.Key.Escape: return KeyCode.ESCAPE;
            case Keyboard.Key.LControl: return KeyCode.LCONTROL;
            case Keyboard.Key.LShift: return KeyCode.LSHIFT;
            case Keyboard.Key.LAlt: return KeyCode.LALT;
            case Keyboard.Key.RControl: return KeyCode.RCONTROL;
            case Keyboard.Key.RShift: return KeyCode.RSHIFT;
            case Keyboard.Key.RAlt: return KeyCode.RALT;
            case Keyboard.Key.Return: return KeyCode.RETURN;
            case Keyboard.Key.BackSpace: return KeyCode.BACK;
            case Keyboard.Key.Tab: return KeyCode.TAB;
            case Keyboard.Key.PageUp: return KeyCode.PAGEUP;
            case Keyboard.Key.PageDown: return KeyCode.PAGEDOWN;
            case Keyboard.Key.End: return KeyCode.END;
            case Keyboard.Key.Home: return KeyCode.HOME;
            case Keyboard.Key.Insert: return KeyCode.INS;
            case Keyboard.Key.Delete: return KeyCode.DEL;
            case Keyboard.Key.Add: return KeyCode.ADD;
            case Keyboard.Key.Subtract: return KeyCode.SUB;
            case Keyboard.Key.Multiply: return KeyCode.MUL;
            case Keyboard.Key.Divide: return KeyCode.DIV;
            case Keyboard.Key.Left: return KeyCode.LEFT;
            case Keyboard.Key.Right: return KeyCode.RIGHT;
            case Keyboard.Key.Up: return KeyCode.UP;
            case Keyboard.Key.Down: return KeyCode.DOWN;
            default: return 0x8000_0000 | key;
        }
    }

    private ushort mouseFlags;
    private ushort keyFlags;

    bool handleEvent(ref Event event) {
        switch (event.type) {
            case(event.EventType.Closed): {
                break;
            }
            case(event.EventType.Resized): {
                onResize(event.size.width, event.size.height);
                break;
            }
            case(event.EventType.MouseButtonPressed): {
                auto btn = translateButton(event.mouseButton.button);
                mouseFlags |= mouseButtonToFlag(btn);
                MouseEvent ev = new MouseEvent(MouseAction.ButtonDown, btn, mouseFlags, cast(short)event.mouseButton.x, cast(short)event.mouseButton.y);
                return dispatchMouseEvent(ev);
            }
            case(event.EventType.MouseButtonReleased): {
                auto btn = translateButton(event.mouseButton.button);
                mouseFlags &= ~mouseButtonToFlag(btn);
                MouseEvent ev = new MouseEvent(MouseAction.ButtonUp, btn, mouseFlags, cast(short)event.mouseButton.x, cast(short)event.mouseButton.y);
                return dispatchMouseEvent(ev);
            }
            case(event.EventType.MouseMoved): {
                MouseEvent ev = new MouseEvent(MouseAction.Move, MouseButton.None, mouseFlags, cast(short)event.mouseMove.x, cast(short)event.mouseMove.y);
                return dispatchMouseEvent(ev);
            }
            case(event.EventType.MouseEntered): {
                break;
            }
            case(event.EventType.MouseLeft): {
                mouseFlags = 0;
                break;
            }
            case(event.EventType.MouseWheelMoved): {
                break;
            }
            case(event.EventType.TextEntered): {
                KeyEvent ev = new KeyEvent(KeyAction.Text, 0, 0, [event.text.unicode]);
                return dispatchKeyEvent(ev);
            }
            case(event.EventType.KeyReleased): 
            case(event.EventType.KeyPressed): {
                keyFlags = 0;
                if (event.key.alt)
                    keyFlags |= KeyFlag.Alt;
                if (event.key.control)
                    keyFlags |= KeyFlag.Control;
                if (event.key.shift)
                    keyFlags |= KeyFlag.Shift;
                KeyEvent ev = new KeyEvent(event.type == event.EventType.KeyPressed ? KeyAction.KeyDown : KeyAction.KeyUp, translateKey(event.key.code), keyFlags, [event.text.unicode]);
                return dispatchKeyEvent(ev);
            }
            default:
                break;
        }
        return true;
    }

}

/**
 * Platform abstraction layer.
 * 
 * Represents application.
 * 
 */
class DSFMLPlatform : Platform {

    private DSFMLWindow[] _activeWindows;

    /// register DSFML window created outside dlangui
    DSFMLWindow registerWindow(RenderWindow window) {
        DSFMLWindow w = new DSFMLWindow(window, false);
        _activeWindows ~= w;
        return w;
    }

	/**
	 * create window
	 * Args:
	 * 		windowCaption = window caption text
	 * 		parent = parent Window, or null if no parent
	 * 		flags = WindowFlag bit set, combination of Resizable, Modal, Fullscreen
	 * 
	 * Window w/o Resizable nor Fullscreen will be created with size based on measurement of its content widget
	 */
	override dlangui.platforms.common.platform.Window createWindow(dstring windowCaption, 
                                                                   dlangui.platforms.common.platform.Window parent, 
                                                                   uint flags = WindowFlag.Resizable, uint width = 0, uint height = 0) {
        auto window = new RenderWindow(VideoMode(800, 600, 32), "Hello DSFML!", dsfml.window.window.Window.Style.Titlebar | dsfml.window.window.Window.Style.Close | dsfml.window.window.Window.Style.Resize);
        window.setFramerateLimit(60);
        DSFMLWindow w = new DSFMLWindow(window, true);
        _activeWindows ~= w;
        return w;
    }

	/**
	 * close window
	 * 
	 * Closes window earlier created with createWindow()
	 */
	override void closeWindow(dlangui.platforms.common.platform.Window w) {
        DSFMLWindow win = cast(DSFMLWindow)w;
        // TODO: support more than one window
        _activeWindows[0] = null;
        _activeWindows.length = 0;// = _activeWindows.remove(win);
        win.wnd.close();
    }
	/**
	 * Starts application message loop.
	 * 
	 * When returned from this method, application is shutting down.
	 */
    override int enterMessageLoop() {
        // TODO: support more than one window
        if (_activeWindows.length < 1)
            return 1;
        DSFMLWindow w = _activeWindows[0];
        RenderWindow window = w.wnd;

        while (window.isOpen())
        {
            Event event;
        
            while(window.pollEvent(event))
            {
                if(event.type == event.EventType.Closed)
                {
                    closeWindow(w);
                    //window.close();
                }
            }
        
            window.clear();
        
            //window.draw(head);
            //window.draw(leftEye);
            //window.draw(rightEye);
            //window.draw(smile);
            //window.draw(smileCover);
        
            window.display();
        }
        return 0;
    }
    /// retrieves text from clipboard (when mouseBuffer == true, use mouse selection clipboard - under linux)
    override dstring getClipboardText(bool mouseBuffer = false) {
        // TODO:
        return ""d;
    }
    /// sets text to clipboard (when mouseBuffer == true, use mouse selection clipboard - under linux)
    override void setClipboardText(dstring text, bool mouseBuffer = false) {
        // TODO:
    }

	/// calls request layout for all windows
	override void requestLayout() {
        // TODO:
    }

}

/// shortcut to current DSFMLPlatform instance
@property DSFMLPlatform dsfmlPlatform() {
    return cast(DSFMLPlatform)Platform.instance;
}

void initDSFMLApp() {
    initLogs();
    Log.d("Initializing DSFML platform");
    DSFMLPlatform p = new DSFMLPlatform();
    Platform.setInstance(p);
    initFontManager();

	currentTheme = createDefaultTheme();

    import derelict.opengl3.gl3;
    import dlangui.graphics.glsupport;
    DerelictGL3.load();
    if (!_glSupport)
        _glSupport = new GLSupport();

    Platform.instance.uiTheme = "theme_dark";
}


void uninitDSFMLApp() {
    Log.d("Destroying DSFML platform");
    Platform.setInstance(null);

    releaseResourcesOnAppExit();
}
