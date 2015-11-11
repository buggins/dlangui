module cocoatest;

import derelict.cocoa;

import dlangui.core.logger;

void main(string[] args)
{
    Log.setStderrLogger();
    Log.setLogLevel(LogLevel.Trace);
    DerelictCocoa.load();
    
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
    
    NSApp.activateIgnoringOtherApps(YES);
    NSApp.run();

    DerelictCocoa.unload();
}
