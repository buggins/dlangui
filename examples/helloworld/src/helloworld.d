module app;

import dlangui;

mixin APP_ENTRY_POINT;

/// entry point for dlangui based application
extern (C) int UIAppMain(string[] args) {
    // create window
    Window window = Platform.instance.createWindow("DlangUI example - HelloWorld", null);

    // create some widget to show in window
    window.mainWidget = (new Button()).text("Hello, world!"d).margins(Rect(20,20,20,20));

    // show window
    window.show();

    // run message loop
    return Platform.instance.enterMessageLoop();
}
