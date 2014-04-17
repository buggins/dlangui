module app;

import dlangui.all;
import std.stdio;
import std.conv;


mixin APP_ENTRY_POINT;

/// entry point for dlangui based application
extern (C) int UIAppMain(string[] args) {
    // resource directory search paths
    string[] resourceDirs = [
        appendPath(exePath, "../../../res/"),   // for Visual D and DUB builds
        appendPath(exePath, "../../../../res/"),// for Mono-D builds
        appendPath(exePath, "res/") // when res dir is located at the same directory as executable
    ];
    // setup resource directories - will use only existing directories
    drawableCache.setResourcePaths(resourceDirs);
    // setup i18n - look for i18n directory inside one of passed directories
    i18n.findTranslationsDir(resourceDirs);
    // select translation file - for english language
    i18n.load("en.ini"); //"ru.ini", "en.ini"

    // create window
    Window window = Platform.instance.createWindow("My Window", null);
	
    window.mainWidget = (new Button()).text("sample button");

    window.show();
    //window.windowCaption = "New Window Caption";
    // run message loop
    return Platform.instance.enterMessageLoop();
}
