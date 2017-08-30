module cocoatest;
version(OSX):

import derelict.cocoa;

import dlangui.core.logger;
import dlangui.core.types;
import dlangui.core.events;
import dlangui.graphics.drawbuf;
import std.uuid;
import core.stdc.stdlib;
import std.string;

void main(string[] args)
{
    Log.setStderrLogger();
    Log.setLogLevel(LogLevel.Trace);
    DerelictCocoa.load();



    static if (true) {
        auto pool = new NSAutoreleasePool;
        NSString appName = NSProcessInfo.processInfo().processName();
        Log.i("appName = %s", appName);

        CocoaWindow window = new CocoaWindow(cast(void*)null, new IWindowListenerLogger(), 300, 300);
        Log.d("");
    } else {


        NSString appName = NSProcessInfo.processInfo().processName();
        Log.i("appName = %s", appName);
        //writefln("appName = %s", appName);

        auto pool = new NSAutoreleasePool;

        auto NSApp = NSApplication.sharedApplication;

        NSApp.setActivationPolicy(NSApplicationActivationPolicyRegular);

        NSMenu menubar = NSMenu.alloc;
        menubar.init_();
        NSMenuItem appMenuItem = NSMenuItem.alloc();
        appMenuItem.init_();
        menubar.addItem(appMenuItem);
        NSApp.setMainMenu(menubar);

        NSWindow window = NSWindow.alloc();
        window.initWithContentRect(NSMakeRect(10, 10, 200, 200),
            NSTitledWindowMask | NSClosableWindowMask | NSResizableWindowMask, //NSBorderlessWindowMask,
            NSBackingStoreBuffered, NO);
        window.makeKeyAndOrderFront();

        NSView parentView;
        parentView = window.contentView();

        Log.i("parentView=", parentView);

        NSApp.activateIgnoringOtherApps(YES);

    //    string uuid = randomUUID().toString();
    //    DlanguiCocoaView.customClassName = "DlanguiCocoaView_" ~ uuid;
    //    DlanguiCocoaView.registerSubclass();
    //
    //    _view = DlanguiCocoaView.alloc();
    //    _view.initialize(this, width, height);
    //
    //    parentView.addSubview(_view);


        NSApp.run();
    }

    DerelictCocoa.unload();
}

interface IWindowListener {
    void onMouseWheel(int x, int y, int deltaX, int deltaY, MouseState state);
    void onKeyDown(uint key);
    void onKeyUp(uint key);
    void onMouseMove(int x, int y, int deltaX, int deltaY,
        MouseState mouseState);
    void onMouseRelease(int x, int y, MouseButton mb, MouseState mouseState);
    void onMouseClick(int x, int y, MouseButton mb, bool isDoubleClick, MouseState mouseState);
    void recomputeDirtyAreas();
    void onResized(int width, int height);
    void onAnimate(double dt, double time);
    Rect getDirtyRectangle();
}

class IWindowListenerLogger : IWindowListener {
    override void onMouseWheel(int x, int y, int deltaX, int deltaY, MouseState state) {
        Log.d("onMouseWheel");
    }
    override void onKeyDown(uint key) {
        Log.d("onKeyDown");
    }
    override void onKeyUp(uint key) {
        Log.d("onKeyUp");
    }
    override void onMouseMove(int x, int y, int deltaX, int deltaY,
        MouseState mouseState) {
        Log.d("onMouseMove ", x, ", ", y);
    }
    override void onMouseRelease(int x, int y, MouseButton mb, MouseState mouseState) {
        Log.d("onMouseRelease");
    }
    override void onMouseClick(int x, int y, MouseButton mb, bool isDoubleClick, MouseState mouseState) {
        Log.d("onMouseClick");
    }
    override void recomputeDirtyAreas() {
        //Log.d("recomputeDirtyAreas");
    }
    override void onResized(int width, int height) {
        Log.d("onResized ", width, ", ", height);
        _width = width;
        _height = height;
    }
    override void onAnimate(double dt, double time) {
        //Log.d("onAnimate");
    }
    override Rect getDirtyRectangle() {
        return Rect(0, 0, _width, _height);
    }
    int _width = 100;
    int _height = 100;
}

struct MouseState {
    bool leftButtonDown;
    bool rightButtonDown;
    bool middleButtonDown;
    bool ctrlPressed;
    bool shiftPressed;
    bool altPressed;
}

enum MouseButton : int {
    left,
    right,
    middle
}

final class CocoaWindow
{
private:
    IWindowListener _listener;

    // Stays null in the case of a plugin, but exists for a stand-alone program
    // For testing purpose.
    NSWindow _cocoaWindow = null;
    NSApplication _cocoaApplication;

    NSColorSpace _nsColorSpace;
    CGColorSpaceRef _cgColorSpaceRef;
    NSData _imageData;
    NSString _logFormatStr;

    ColorDrawBuf _drawBuf;

    DPlugCustomView _view = null;

    bool _terminated = false;

    int _lastMouseX, _lastMouseY;
    bool _firstMouseMove = true;

    int _width;
    int _height;

    ubyte* _buffer = null;

    uint _timeAtCreationInMs;
    uint _lastMeasturedTimeInMs;
    bool _dirtyAreasAreNotYetComputed;

public:

    this(void* parentWindow, IWindowListener listener, int width, int height)
    {
        _listener = listener;

        DerelictCocoa.load();
        NSApplicationLoad(); // to use Cocoa in Carbon applications
        bool parentViewExists = parentWindow !is null;
        NSView parentView;
        if (!parentViewExists)
        {
            // create a NSWindow to hold our NSView
            _cocoaApplication = NSApplication.sharedApplication;
            _cocoaApplication.setActivationPolicy(NSApplicationActivationPolicyRegular);

            NSWindow window = NSWindow.alloc();
            window.initWithContentRect(NSMakeRect(100, 100, width, height),
                NSTitledWindowMask | NSClosableWindowMask | NSResizableWindowMask,
                NSBackingStoreBuffered,
                NO);
            window.makeKeyAndOrderFront();

            parentView = window.contentView();
            //parentView.

            _cocoaApplication.activateIgnoringOtherApps(YES);
        }
        else
            parentView = NSView(cast(id)parentWindow);



        _width = 0;
        _height = 0;

        _nsColorSpace = NSColorSpace.sRGBColorSpace();
        // hopefully not null else the colors will be brighter
        _cgColorSpaceRef = _nsColorSpace.CGColorSpace();

        _logFormatStr = NSString.stringWith("%@");

        _timeAtCreationInMs = getTimeMs();
        _lastMeasturedTimeInMs = _timeAtCreationInMs;

        _dirtyAreasAreNotYetComputed = true;

        string uuid = randomUUID().toString();
        DPlugCustomView.customClassName = "DPlugCustomView_" ~ uuid;
        DPlugCustomView.registerSubclass();

        _view = DPlugCustomView.alloc();
        _view.initialize(this, width, height);

        parentView.addSubview(_view);

        if (_cocoaApplication)
            _cocoaApplication.run();


    }

    ~this()
    {
        if (_view)
        {
            //debug ensureNotInGC("CocoaWindow");
            _terminated = true;

            {
                _view.killTimer();
            }

            _view.removeFromSuperview();
            _view.release();
            _view = DPlugCustomView(null);

            DPlugCustomView.unregisterSubclass();

            if (_buffer != null)
            {
                free(_buffer);
                _buffer = null;
            }

            DerelictCocoa.unload();
        }
    }

    // Implements IWindow
    void waitEventAndDispatch()
    {
        assert(false); // not implemented in Cocoa, since we don't have a NSWindow
    }

    bool terminated()
    {
        return _terminated;
    }

    void debugOutput(string s)
    {
        import core.stdc.stdio;
        fprintf(stderr, toStringz(s));
    }

    uint getTimeMs()
    {
        return cast(uint)(NSDate.timeIntervalSinceReferenceDate() * 1000.0);
    }

private:

    MouseState getMouseState(NSEvent event)
    {
        // not working
        MouseState state;
        uint pressedMouseButtons = event.pressedMouseButtons();
        if (pressedMouseButtons & 1)
            state.leftButtonDown = true;
        if (pressedMouseButtons & 2)
            state.rightButtonDown = true;
        if (pressedMouseButtons & 4)
            state.middleButtonDown = true;

        NSEventModifierFlags mod = event.modifierFlags();
        if (mod & NSControlKeyMask)
            state.ctrlPressed = true;
        if (mod & NSShiftKeyMask)
            state.shiftPressed = true;
        if (mod & NSAlternateKeyMask)
            state.altPressed = true;

        return state;
    }

    void handleMouseWheel(NSEvent event)
    {
        int deltaX = cast(int)(0.5 + 10 * event.deltaX);
        int deltaY = cast(int)(0.5 + 10 * event.deltaY);
        Point mousePos = getMouseXY(_view, event, _height);
        _listener.onMouseWheel(mousePos.x, mousePos.y, deltaX, deltaY, getMouseState(event));
    }

    void handleKeyEvent(NSEvent event, bool released)
    {
        uint keyCode = event.keyCode();
        uint key;
        switch (keyCode)
        {
            case kVK_ANSI_Keypad0: key = KeyCode.KEY_0; break;
            case kVK_ANSI_Keypad1: key = KeyCode.KEY_1; break;
            case kVK_ANSI_Keypad2: key = KeyCode.KEY_2; break;
            case kVK_ANSI_Keypad3: key = KeyCode.KEY_3; break;
            case kVK_ANSI_Keypad4: key = KeyCode.KEY_4; break;
            case kVK_ANSI_Keypad5: key = KeyCode.KEY_5; break;
            case kVK_ANSI_Keypad6: key = KeyCode.KEY_6; break;
            case kVK_ANSI_Keypad7: key = KeyCode.KEY_7; break;
            case kVK_ANSI_Keypad8: key = KeyCode.KEY_8; break;
            case kVK_ANSI_Keypad9: key = KeyCode.KEY_9; break;
            case kVK_Return: key = KeyCode.RETURN; break;
            case kVK_Escape: key = KeyCode.ESCAPE; break;
            case kVK_LeftArrow: key = KeyCode.LEFT; break;
            case kVK_RightArrow: key = KeyCode.RIGHT; break;
            case kVK_DownArrow: key = KeyCode.DOWN; break;
            case kVK_UpArrow: key = KeyCode.UP; break;
            default: key = 0;
        }

        if (released)
            _listener.onKeyDown(key);
        else
            _listener.onKeyUp(key);
    }

    void handleMouseMove(NSEvent event)
    {
        Point mousePos = getMouseXY(_view, event, _height);

        if (_firstMouseMove)
        {
            _firstMouseMove = false;
            _lastMouseX = mousePos.x;
            _lastMouseY = mousePos.y;
        }

        _listener.onMouseMove(mousePos.x, mousePos.y, mousePos.x - _lastMouseX, mousePos.y - _lastMouseY,
            getMouseState(event));

        _lastMouseX = mousePos.x;
        _lastMouseY = mousePos.y;
    }

    void handleMouseClicks(NSEvent event, MouseButton mb, bool released)
    {
        Point mousePos = getMouseXY(_view, event, _height);

        if (released)
            _listener.onMouseRelease(mousePos.x, mousePos.y, mb, getMouseState(event));
        else
        {
            int clickCount = event.clickCount();
            bool isDoubleClick = clickCount >= 2;
            _listener.onMouseClick(mousePos.x, mousePos.y, mb, isDoubleClick, getMouseState(event));
        }
    }

    enum scanLineAlignment = 4; // could be anything

    // given a width, how long in bytes should scanlines be
    int byteStride(int width)
    {
        int widthInBytes = width * 4;
        return (widthInBytes + (scanLineAlignment - 1)) & ~(scanLineAlignment-1);
    }

    void drawRect(NSRect rect)
    {
        NSGraphicsContext nsContext = NSGraphicsContext.currentContext();

        CIContext ciContext = nsContext.getCIContext();

        // update internal buffers in case of startup/resize
        {
            NSRect boundsRect = _view.bounds();
            int width = cast(int)(boundsRect.size.width);   // truncating down the dimensions of bounds
            int height = cast(int)(boundsRect.size.height);
            updateSizeIfNeeded(width, height);
            _drawBuf.resize(width, height);
        }

        // The first drawRect callback occurs before the timer triggers.
        // But because recomputeDirtyAreas() wasn't called before there is nothing to draw.
        // Hence, do it.
        if (_dirtyAreasAreNotYetComputed)
        {
            _dirtyAreasAreNotYetComputed = false;
            _listener.recomputeDirtyAreas();
        }

        // draw buffers
//        ImageRef!RGBA wfb;
//        wfb.w = _width;
//        wfb.h = _height;
//        wfb.pitch = byteStride(_width);
//        wfb.pixels = cast(RGBA*)_buffer;
//        _listener.onDraw(wfb, WindowPixelFormat.ARGB8);
        _drawBuf.fill(0x8090B0);
        _drawBuf.fillRect(Rect(20, 20, 120, 120), 0xFFBBBB);

        size_t sizeNeeded = byteStride(_width) * _height;
        //_imageData = NSData.dataWithBytesNoCopy(cast(ubyte*)_drawBuf.scanLine(0), sizeNeeded, false);
        _imageData = NSData.dataWithBytesNoCopy(cast(ubyte*)_drawBuf.scanLine(0), sizeNeeded, false);

        CIImage image = CIImage.imageWithBitmapData(_imageData,
            byteStride(_drawBuf.width),
            CGSize(_drawBuf.width, _drawBuf.height),
            kCIFormatARGB8,
            _cgColorSpaceRef);
//        NSRect rc;
//        rc.origin.x = 0;
//        rc.origin.y = 0;
//        rc.size.width = _drawBuf.width;
//        rc.size.height = _drawBuf.height;
        ciContext.drawImage(image, rect, rect);
    }

    /// Returns: true if window size changed.
    bool updateSizeIfNeeded(int newWidth, int newHeight)
    {
        // only do something if the client size has changed
        if ( (newWidth != _width) || (newHeight != _height) )
        {
            // Extends buffer
            if (_buffer != null)
            {
                free(_buffer);
                _buffer = null;
            }

            size_t sizeNeeded = byteStride(newWidth) * newHeight;
            _buffer = cast(ubyte*) malloc(sizeNeeded);
            _width = newWidth;
            _height = newHeight;
            if (_drawBuf is null)
                _drawBuf = new ColorDrawBuf(_width, _height);
            else if (_drawBuf.width != _width || _drawBuf.height != _height)
                _drawBuf.resize(_width, _height);
            _listener.onResized(_width, _height);
            return true;
        }
        else
            return false;
    }

    void doAnimation()
    {
        uint now = getTimeMs();
        double dt = (now - _lastMeasturedTimeInMs) * 0.001;
        double time = (now - _timeAtCreationInMs) * 0.001; // hopefully no plug-in will be open more than 49 days
        _lastMeasturedTimeInMs = now;
        _listener.onAnimate(dt, time);
    }

    void onTimer()
    {
        // Deal with animation
        doAnimation();

        _listener.recomputeDirtyAreas();
        _dirtyAreasAreNotYetComputed = false;
        Rect dirtyRect = _listener.getDirtyRectangle();
        if (!dirtyRect.empty())
        {

            NSRect boundsRect = _view.bounds();
            int height = cast(int)(boundsRect.size.height);
            NSRect r = NSMakeRect(dirtyRect.left,
                height - dirtyRect.top - dirtyRect.height,
                dirtyRect.width,
                dirtyRect.height);
            _view.setNeedsDisplayInRect(r);
        }
    }
}

struct DPlugCustomView
{
    // This class uses a unique class name for each plugin instance
    static string customClassName = null;

    NSView parent;
    alias parent this;

    // create from an id
    this (id id_)
    {
        this._id = id_;
    }

    /// Allocates, but do not init
    static DPlugCustomView alloc()
    {
        alias fun_t = extern(C) id function (id obj, SEL sel);
        return DPlugCustomView( (cast(fun_t)objc_msgSend)(getClassID(), sel!"alloc") );
    }

    static Class getClass()
    {
        return cast(Class)( getClassID() );
    }

    static id getClassID()
    {
        assert(customClassName !is null);
        return objc_getClass(customClassName);
    }

private:

    CocoaWindow _window;
    NSTimer _timer = null;

    void initialize(CocoaWindow window, int width, int height)
    {
        // Warning: taking this address is fishy since DPlugCustomView is a struct and thus could be copied
        // we rely on the fact it won't :|
        void* thisPointer = cast(void*)(&this);
        object_setInstanceVariable(_id, "this", thisPointer);

        this._window = window;

        NSRect r = NSRect(NSPoint(0, 0), NSSize(width, height));
        initWithFrame(r);

        _timer = NSTimer.timerWithTimeInterval(1 / 60.0, this, sel!"onTimer:", null, true);
        NSRunLoop.currentRunLoop().addTimer(_timer, NSRunLoopCommonModes);
    }

    static Class clazz;

    static void registerSubclass()
    {
        clazz = objc_allocateClassPair(cast(Class) lazyClass!"NSView", toStringz(customClassName), 0);

        class_addMethod(clazz, sel!"keyDown:", cast(IMP) &keyDown, "v@:@");
        class_addMethod(clazz, sel!"keyUp:", cast(IMP) &keyUp, "v@:@");
        class_addMethod(clazz, sel!"mouseDown:", cast(IMP) &mouseDown, "v@:@");
        class_addMethod(clazz, sel!"mouseUp:", cast(IMP) &mouseUp, "v@:@");
        class_addMethod(clazz, sel!"rightMouseDown:", cast(IMP) &rightMouseDown, "v@:@");
        class_addMethod(clazz, sel!"rightMouseUp:", cast(IMP) &rightMouseUp, "v@:@");
        class_addMethod(clazz, sel!"otherMouseDown:", cast(IMP) &otherMouseDown, "v@:@");
        class_addMethod(clazz, sel!"otherMouseUp:", cast(IMP) &otherMouseUp, "v@:@");
        class_addMethod(clazz, sel!"mouseMoved:", cast(IMP) &mouseMoved, "v@:@");
        class_addMethod(clazz, sel!"mouseDragged:", cast(IMP) &mouseMoved, "v@:@");
        class_addMethod(clazz, sel!"rightMouseDragged:", cast(IMP) &mouseMoved, "v@:@");
        class_addMethod(clazz, sel!"otherMouseDragged:", cast(IMP) &mouseMoved, "v@:@");
        class_addMethod(clazz, sel!"acceptsFirstResponder", cast(IMP) &acceptsFirstResponder, "b@:");
        class_addMethod(clazz, sel!"isOpaque", cast(IMP) &isOpaque, "b@:");
        class_addMethod(clazz, sel!"acceptsFirstMouse:", cast(IMP) &acceptsFirstMouse, "b@:@");
        class_addMethod(clazz, sel!"viewDidMoveToWindow", cast(IMP) &viewDidMoveToWindow, "v@:");
        class_addMethod(clazz, sel!"drawRect:", cast(IMP) &drawRect, "v@:" ~ encode!NSRect);
        class_addMethod(clazz, sel!"onTimer:", cast(IMP) &onTimer, "v@:@");

        // This ~ is to avoid a strange DMD ICE. Didn't succeed in isolating it.
        class_addMethod(clazz, sel!("scroll" ~ "Wheel:") , cast(IMP) &scrollWheel, "v@:@");

        // very important: add an instance variable for the this pointer so that the D object can be
        // retrieved from an id
        class_addIvar(clazz, "this", (void*).sizeof, (void*).sizeof == 4 ? 2 : 3, "^v");

        objc_registerClassPair(clazz);
    }

    static void unregisterSubclass()
    {
        // For some reason the class need to continue to exist, so we leak it
        //  objc_disposeClassPair(clazz);
        // TODO: remove this crap
    }

    void killTimer()
    {
        if (_timer)
        {
            _timer.invalidate();
            _timer = NSTimer(null);
        }
    }
}

DPlugCustomView getInstance(id anId)
{
    // strange thing: object_getInstanceVariable definition is odd (void**)
    // and only works for pointer-sized values says SO
    void* thisPointer = null;
    Ivar var = object_getInstanceVariable(anId, "this", &thisPointer);
    assert(var !is null);
    assert(thisPointer !is null);
    return *cast(DPlugCustomView*)thisPointer;
}

Point getMouseXY(NSView view, NSEvent event, int windowHeight)
{
    NSPoint mouseLocation = event.locationInWindow();
    mouseLocation = view.convertPoint(mouseLocation, NSView(null));
    int px = cast(int)(mouseLocation.x) - 2;
    int py = windowHeight - cast(int)(mouseLocation.y) - 3;
    return Point(px, py);
}

// Overridden function gets called with an id, instead of the self pointer.
// So we have to get back the D class object address.
// Big thanks to Mike Ash (@macdev)
extern(C)
{
    void keyDown(id self, SEL selector, id event)
    {
        //FPControl fpctrl;
        //fpctrl.initialize();
        DPlugCustomView view = getInstance(self);
        view._window.handleKeyEvent(NSEvent(event), false);
    }

    void keyUp(id self, SEL selector, id event)
    {
        //FPControl fpctrl;
        //fpctrl.initialize();
        DPlugCustomView view = getInstance(self);
        view._window.handleKeyEvent(NSEvent(event), true);
    }

    void mouseDown(id self, SEL selector, id event)
    {
        //FPControl fpctrl;
        //fpctrl.initialize();
        DPlugCustomView view = getInstance(self);
        view._window.handleMouseClicks(NSEvent(event), MouseButton.left, false);
    }

    void mouseUp(id self, SEL selector, id event)
    {
        //FPControl fpctrl;
        //fpctrl.initialize();
        DPlugCustomView view = getInstance(self);
        view._window.handleMouseClicks(NSEvent(event), MouseButton.left, true);
    }

    void rightMouseDown(id self, SEL selector, id event)
    {
        //FPControl fpctrl;
        //fpctrl.initialize();
        DPlugCustomView view = getInstance(self);
        view._window.handleMouseClicks(NSEvent(event), MouseButton.right, false);
    }

    void rightMouseUp(id self, SEL selector, id event)
    {
        //FPControl fpctrl;
        //fpctrl.initialize();
        DPlugCustomView view = getInstance(self);
        view._window.handleMouseClicks(NSEvent(event), MouseButton.right, true);
    }

    void otherMouseDown(id self, SEL selector, id event)
    {
        //FPControl fpctrl;
        //fpctrl.initialize();
        DPlugCustomView view = getInstance(self);
        auto nsEvent = NSEvent(event);
        if (nsEvent.buttonNumber == 2)
            view._window.handleMouseClicks(nsEvent, MouseButton.middle, false);
    }

    void otherMouseUp(id self, SEL selector, id event)
    {
        //FPControl fpctrl;
        //fpctrl.initialize();
        DPlugCustomView view = getInstance(self);
        auto nsEvent = NSEvent(event);
        if (nsEvent.buttonNumber == 2)
            view._window.handleMouseClicks(nsEvent, MouseButton.middle, true);
    }

    void mouseMoved(id self, SEL selector, id event)
    {
        //FPControl fpctrl;
        //fpctrl.initialize();
        DPlugCustomView view = getInstance(self);
        view._window.handleMouseMove(NSEvent(event));
    }

    void scrollWheel(id self, SEL selector, id event)
    {
        //FPControl fpctrl;
        //fpctrl.initialize();
        DPlugCustomView view = getInstance(self);
        view._window.handleMouseWheel(NSEvent(event));
    }

    bool acceptsFirstResponder(id self, SEL selector)
    {
        return YES;
    }

    bool acceptsFirstMouse(id self, SEL selector, id pEvent)
    {
        return YES;
    }

    bool isOpaque(id self, SEL selector)
    {
        return YES;
    }

    void viewDidMoveToWindow(id self, SEL selector)
    {
        DPlugCustomView view = getInstance(self);
        NSWindow parentWindow = view.window();
        if (parentWindow)
        {
            parentWindow.makeFirstResponder(view);
            parentWindow.setAcceptsMouseMovedEvents(true);
        }
    }

    void drawRect(id self, SEL selector, NSRect rect)
    {
        //FPControl fpctrl;
        //fpctrl.initialize();
        DPlugCustomView view = getInstance(self);
        view._window.drawRect(rect);
    }

    void onTimer(id self, SEL selector, id timer)
    {
        //FPControl fpctrl;
        //fpctrl.initialize();
        DPlugCustomView view = getInstance(self);
        view._window.onTimer();
    }
}