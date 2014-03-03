module winmain;

import dlangui.platforms.common.platform;
import dlangui.widgets.widget;
import dlangui.core.logger;
import std.stdio;

extern (C) int UIAppMain() {
	Log.d("Some debug message");
	Log.e("Sample error #", 22);

    Window window = Platform.instance().createWindow("My Window", null);
    Widget myWidget = new Widget();
    window.mainWidget = myWidget;
    window.show();
    window.windowCaption = "New Window Caption";
    return Platform.instance().enterMessageLoop();
}
