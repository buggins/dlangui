module winmain;

import dlangui.platforms.common.platform;
import dlangui.graphics.images;
import dlangui.widgets.widget;
import dlangui.widgets.controls;
import dlangui.core.logger;
import dlangui.graphics.fonts;
import std.stdio;

ImageCache imageCache;
string resourceDir;

version(Windows) {
    import win32.windows;
    import dlangui.platforms.windows.winapp;
    /// workaround for link issue when WinMain is located in library
    extern (Windows)
        int WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance,
                    LPSTR lpCmdLine, int nCmdShow)
        {
            return DLANGUIWinMain(hInstance, hPrevInstance,
                                  lpCmdLine, nCmdShow);
        }
}


extern (C) int UIAppMain(string[] args) {

    imageCache = new ImageCache();
    resourceDir = exePath() ~ "..\\res\\";

    string[] imageDirs = [
        resourceDir
    ];
    drawableCache.resourcePaths = imageDirs;
    Window window = Platform.instance().createWindow("My Window", null);
    Widget myWidget = (new Button()).textColor(0x40FF4000);
    myWidget.text = "Some strange text string. 1234567890";
    myWidget.alignment = Align.Center;
    window.mainWidget = myWidget;
    window.show();
    window.windowCaption = "New Window Caption";



	Log.d("Before getFont");
	FontRef font = FontManager.instance.getFont(32, 400, false, FontFamily.SansSerif, "Arial");
	Log.d("After getFont");
	assert(!font.isNull);
	int[] widths;
	dchar[] text = cast(dchar[])"Test string"d;
	Log.d("Calling measureText");
	int charsMeasured = font.measureText(text, widths, 1000);
	assert(charsMeasured > 0);
	int w = widths[charsMeasured - 1];
	Log.d("Measured string: ", charsMeasured, " chars, width=", w);
	Glyph * g = font.getCharGlyph('A');
	Log.d("Char A glyph: ", g.blackBoxX, "x", g.blackBoxY);
    return Platform.instance().enterMessageLoop();
}
