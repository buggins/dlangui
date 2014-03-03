module winmain;

import dlangui.platforms.common.platform;


extern (C) int UIAppMain() {
    Window window = Platform.instance().createWindow("My Window", null);
    window.show();
    window.setWindowCaption("New Window Caption");
    return Platform.instance().enterMessageLoop();
}
