module winmain;

import dlangui.all;
import std.stdio;

version (linux) {
	pragma(lib, "png");
	pragma(lib, "xcb");
	pragma(lib, "X11");
}

/// workaround for link issue when WinMain is located in library
version(Windows) {
    private import win32.windows;
    private import dlangui.platforms.windows.winapp;
    extern (Windows)
        int WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance,
                    LPSTR lpCmdLine, int nCmdShow)
        {
            return DLANGUIWinMain(hInstance, hPrevInstance,
                                  lpCmdLine, nCmdShow);
        }
}

/// entry point for dlangui based application
extern (C) int UIAppMain(string[] args) {
    // setup resource dir
    string resourceDir = exePath() ~ "..\\res\\";
    string[] imageDirs = [
        resourceDir
    ];
    drawableCache.resourcePaths = imageDirs;

    // create window
    Window window = Platform.instance().createWindow("My Window", null);
	LinearLayout layout = new LinearLayout();
	layout.addChild((new TextWidget()).textColor(0x00802000).text("Text widget 0"));
	layout.addChild((new TextWidget()).textColor(0x40FF4000).text("Text widget"));
	layout.addChild((new Button()).textColor(0x40FF4000).text("Button1"));
	layout.addChild((new Button()).textColor(0x000000FF).text("Button2"));
	layout.addChild((new TextWidget()).textColor(0x40FF4000).text("Text widget"));
	layout.addChild((new ImageWidget()).drawableId("exit").padding(Rect(5,5,5,5)));
	layout.addChild((new TextWidget()).textColor(0xFF4000).text("Text widget2").padding(Rect(5,5,5,5)).margins(Rect(5,5,5,5)).backgroundColor(0xA0A0A0));
	layout.addChild((new Button()).textColor(0x000000FF).text("Button3").layoutHeight(FILL_PARENT));
	layout.addChild((new TextWidget()).textColor(0x004000).text("Text widget3 with very long text"));

	layout.layoutHeight(FILL_PARENT).layoutWidth(FILL_PARENT);

    window.mainWidget = layout;
    window.show();
    window.windowCaption = "New Window Caption";

    // run message loop
    return Platform.instance().enterMessageLoop();
}
