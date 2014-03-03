module winmain;

import dlangui.platforms.common.platform;
import dlangui.widgets.widget;


extern (C) int UIAppMain() {
    Window window = Platform.instance().createWindow("My Window", null);
    Widget myWidget = new Widget();
    window.mainWidget = myWidget;
    window.show();
    window.windowCaption = "New Window Caption";
    return Platform.instance().enterMessageLoop();
}
