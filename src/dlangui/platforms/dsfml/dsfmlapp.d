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
