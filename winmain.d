module winmain;

import dlangui.platforms.common.platform;
import dlangui.widgets.widget;
import dlangui.core.logger;
import dlangui.graphics.fonts;
import std.stdio;

extern (C) int UIAppMain() {
	Log.d("Some debug message");
	Log.e("Sample error #", 22);

    Window window = Platform.instance().createWindow("My Window", null);
    Widget myWidget = new Widget();
    window.mainWidget = myWidget;
    window.show();
    window.windowCaption = "New Window Caption";
	FontRef font = FontManager.instance.getFont(32, 400, false, FontFamily.SansSerif, "Arial");
	assert(!font.isNull);
	int[] widths;
	dchar[] text = cast(dchar[])"Test string"d;
	int charsMeasured = font.measureText(text, widths, 1000);
	assert(charsMeasured > 0);
	int w = widths[charsMeasured - 1];
	Log.d("Measured string: ", charsMeasured, " chars, width=", w);
	Glyph * g = font.getCharGlyph('A');
	Log.d("Char A glyph: ", g.blackBoxX, "x", g.blackBoxY);
    return Platform.instance().enterMessageLoop();
}
