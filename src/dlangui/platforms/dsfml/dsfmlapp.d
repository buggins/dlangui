module dlangui.platforms.dsfml.dsfmlapp;

public import dlangui.core.config;

static if (BACKEND_DSFML):

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
    override @property dstring windowCaption() const {
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
        switch(btn) with(Mouse.Button) {
            default:
            case Left:
                return MouseButton.Left;
            case Right:
                return MouseButton.Right;
            case Middle:
                return MouseButton.Middle;
            case XButton1:
                return MouseButton.XButton1;
            case XButton2:
                return MouseButton.XButton2;
        }
    }

    private uint translateKey(uint key) {
        switch(key) with(Keyboard.Key)
        {
            case A: return KeyCode.KEY_A;
            case B: return KeyCode.KEY_B;
            case C: return KeyCode.KEY_C;
            case D: return KeyCode.KEY_D;
            case E: return KeyCode.KEY_E;
            case F: return KeyCode.KEY_F;
            case G: return KeyCode.KEY_G;
            case H: return KeyCode.KEY_H;
            case I: return KeyCode.KEY_I;
            case J: return KeyCode.KEY_J;
            case K: return KeyCode.KEY_K;
            case L: return KeyCode.KEY_L;
            case M: return KeyCode.KEY_M;
            case N: return KeyCode.KEY_N;
            case O: return KeyCode.KEY_O;
            case P: return KeyCode.KEY_P;
            case Q: return KeyCode.KEY_Q;
            case R: return KeyCode.KEY_R;
            case S: return KeyCode.KEY_S;
            case T: return KeyCode.KEY_T;
            case U: return KeyCode.KEY_U;
            case V: return KeyCode.KEY_V;
            case W: return KeyCode.KEY_W;
            case X: return KeyCode.KEY_X;
            case Y: return KeyCode.KEY_Y;
            case Z: return KeyCode.KEY_Z;
            case Num0: return KeyCode.KEY_0;
            case Num1: return KeyCode.KEY_1;
            case Num2: return KeyCode.KEY_2;
            case Num3: return KeyCode.KEY_3;
            case Num4: return KeyCode.KEY_4;
            case Num5: return KeyCode.KEY_5;
            case Num6: return KeyCode.KEY_6;
            case Num7: return KeyCode.KEY_7;
            case Num8: return KeyCode.KEY_8;
            case Num9: return KeyCode.KEY_9;
            case Escape: return KeyCode.ESCAPE;
            case LControl: return KeyCode.LCONTROL;
            case LShift: return KeyCode.LSHIFT;
            case LAlt: return KeyCode.LALT;
            case RControl: return KeyCode.RCONTROL;
            case RShift: return KeyCode.RSHIFT;
            case RAlt: return KeyCode.RALT;

            ///The [ key
            case LBracket: return KeyCode.KEY_BRACKETOPEN;
            ///The ] key
            case RBracket: return KeyCode.KEY_BRACKETCLOSE;
            ///The ; key
            case SemiColon: return KeyCode.KEY_BRACKETOPEN;
            ///The , key
            case Comma: return KeyCode.KEY_COMMA;
            ///The . key
            case Period: return KeyCode.KEY_PERIOD;
            ///The ' key
            case Quote: return KeyCode.QUOTE;
            ///The / key
            case Slash: return KeyCode.KEY_DIVIDE;
            ///The \ key
            case BackSlash: return KeyCode.BACKSLASH;
            ///The ~ key
            case Tilde: return KeyCode.TILDE;
            ///The = key
            case Equal: return KeyCode.EQUAL;
            ///The - key
            case Dash: return KeyCode.SUB;
            ///The Space key
            case Space: return KeyCode.SPACE;

            case Numpad0: return KeyCode.NUM_0;
            case Numpad1: return KeyCode.NUM_1;
            case Numpad2: return KeyCode.NUM_2;
            case Numpad3: return KeyCode.NUM_3;
            case Numpad4: return KeyCode.NUM_4;
            case Numpad5: return KeyCode.NUM_5;
            case Numpad6: return KeyCode.NUM_6;
            case Numpad7: return KeyCode.NUM_7;
            case Numpad8: return KeyCode.NUM_8;
            case Numpad9: return KeyCode.NUM_9;

            case F1: return KeyCode.F1;
            case F2: return KeyCode.F2;
            case F3: return KeyCode.F3;
            case F4: return KeyCode.F4;
            case F5: return KeyCode.F5;
            case F6: return KeyCode.F6;
            case F7: return KeyCode.F7;
            case F8: return KeyCode.F8;
            case F9: return KeyCode.F9;
            case F10: return KeyCode.F10;
            case F11: return KeyCode.F11;
            case F12: return KeyCode.F12;
            case F13: return KeyCode.F13;
            case F14: return KeyCode.F14;
            case F15: return KeyCode.F15;

            case Return: return KeyCode.RETURN;
            case BackSpace: return KeyCode.BACK;
            case Tab: return KeyCode.TAB;
            case PageUp: return KeyCode.PAGEUP;
            case PageDown: return KeyCode.PAGEDOWN;
            case End: return KeyCode.END;
            case Home: return KeyCode.HOME;
            case Insert: return KeyCode.INS;
            case Delete: return KeyCode.DEL;
            case Add: return KeyCode.ADD;
            case Subtract: return KeyCode.SUB;
            case Multiply: return KeyCode.MUL;
            case Divide: return KeyCode.DIV;
            case Left: return KeyCode.LEFT;
            case Right: return KeyCode.RIGHT;
            case Up: return KeyCode.UP;
            case Down: return KeyCode.DOWN;
            default: return 0x8000_0000 | key;
        }
    }

    private ushort mouseFlags;
    private ushort keyFlags;

    bool handleEvent(ref Event event) {
        switch (event.type) with(event.EventType) {
            case Closed: {
                break;
            }
            case Resized: {
                onResize(event.size.width, event.size.height);
                break;
            }
            case MouseButtonPressed: {
                auto btn = translateButton(event.mouseButton.button);
                mouseFlags |= mouseButtonToFlag(btn);
                MouseEvent ev = new MouseEvent(MouseAction.ButtonDown, btn, mouseFlags, cast(short)event.mouseButton.x, cast(short)event.mouseButton.y);
                return dispatchMouseEvent(ev);
            }
            case MouseButtonReleased: {
                auto btn = translateButton(event.mouseButton.button);
                mouseFlags &= ~mouseButtonToFlag(btn);
                MouseEvent ev = new MouseEvent(MouseAction.ButtonUp, btn, mouseFlags, cast(short)event.mouseButton.x, cast(short)event.mouseButton.y);
                return dispatchMouseEvent(ev);
            }
            case MouseMoved: {
                MouseEvent ev = new MouseEvent(MouseAction.Move, MouseButton.None, mouseFlags, cast(short)event.mouseMove.x, cast(short)event.mouseMove.y);
                return dispatchMouseEvent(ev);
            }
            case MouseEntered: {
                break;
            }
            case MouseLeft: {
                mouseFlags = 0;
                break;
            }
            case MouseWheelMoved: {
                break;
            }
            case TextEntered: {
                KeyEvent ev = new KeyEvent(KeyAction.Text, 0, 0, [event.text.unicode]);
                return dispatchKeyEvent(ev);
            }
            case KeyReleased:
            case KeyPressed: {
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
     *         windowCaption = window caption text
     *         parent = parent Window, or null if no parent
     *         flags = WindowFlag bit set, combination of Resizable, Modal, Fullscreen
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
        // TODO: implement if necessary
        return ""d;
    }
    /// check has clipboard text
    override bool hasClipboardText(bool mouseBuffer = false) {
        // TODO: implement if necessary
        return false;
    }
    /// sets text to clipboard (when mouseBuffer == true, use mouse selection clipboard - under linux)
    override void setClipboardText(dstring text, bool mouseBuffer = false) {
        // TODO: implement if necessary
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

// entry point
extern(C) int UIAppMain(string[] args);

void initDSFMLApp() {
    initLogs();
    Log.d("Initializing DSFML platform");
    DSFMLPlatform p = new DSFMLPlatform();
    Platform.setInstance(p);
    initResourceManagers();
    initFontManager();

    currentTheme = createDefaultTheme();

    import dlangui.graphics.glsupport;
    initGLSupport(false);

    Platform.instance.uiTheme = "theme_dark";
}


void uninitDSFMLApp() {
    Log.d("Destroying DSFML platform");
    Platform.setInstance(null);

    releaseResourcesOnAppExit();
}
