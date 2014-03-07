module winmain;

import dlangui.all;
import std.stdio;

/// workaround for link issue when WinMain is located in library
version(Windows) {
    import win32.windows;
    import dlangui.platforms.windows.winapp;
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
    Widget myWidget = (new Button()).textColor(0x40FF4000);
    myWidget.text = "Some strange text string. 1234567890";
    window.mainWidget = myWidget;
    window.show();
    window.windowCaption = "New Window Caption";

    // run message loop
    return Platform.instance().enterMessageLoop();
}
