// Written in the D programming language.

/**
DLANGUI library.

This module is just to simplify import of most useful DLANGUI modules.

Synopsis:

----
// helloworld
import dlangui.all;
// required in one of modules
mixin APP_ENTRY_POINT;

/// entry point for dlangui based application
extern (C) int UIAppMain(string[] args) {
    // resource directory search paths
    string[] resourceDirs = [
        appendPath(exePath, "../../../res/"),   // for Visual D and DUB builds
        appendPath(exePath, "../../../../res/"), // for Mono-D builds
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
    // create some widget to show in window
    window.mainWidget = (new Button()).text("Hello world"d);
    // show window
    window.show();
    // run message loop
    return Platform.instance.enterMessageLoop();
}


----

Copyright: Vadim Lopatin, 2014
License:   $(WEB boost.org/LICENSE_1_0.txt, Boost License 1.0).
Authors:   $(WEB coolreader.org, Vadim Lopatin)
 */
module dlangui.all;

public import dlangui.core.logger;
public import dlangui.core.types;
public import dlangui.platforms.common.platform;
public import dlangui.graphics.images;
public import dlangui.widgets.widget;
public import dlangui.widgets.controls;
public import dlangui.widgets.layouts;
public import dlangui.widgets.lists;
public import dlangui.widgets.tabs;
public import dlangui.widgets.menu;
public import dlangui.widgets.editors;
public import dlangui.graphics.fonts;
public import dlangui.core.i18n;
