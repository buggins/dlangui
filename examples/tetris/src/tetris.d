// Written in the D programming language.

/**
This app is a Tetris demo for DlangUI library.

Synopsis:

----
    dub run dlangui:tetris
----

Copyright: Vadim Lopatin, 2014
License:   Boost License 1.0
Authors:   Vadim Lopatin, coolreader.org@gmail.com
 */
module main;

import dlangui;
import model;
import gui;

/// Required for Windows platform: DMD cannot find WinMain if it's in library
mixin APP_ENTRY_POINT;

/// entry point for dlangui based application
extern (C) int UIAppMain(string[] args) {

    // embed resources listed in views/resources.list into executable
    embeddedResourceList.addResources(embedResourcesFromList!("resources.list")());

    // select translation file - for english language
    Platform.instance.uiLanguage = "en";
    // load theme from file "theme_default.xml"
    Platform.instance.uiTheme = "theme_default";

    //SCREEN_DPI = 150;

    // create window
    Window window = Platform.instance.createWindow("DLangUI: Tetris game example"d, null, WindowFlag.Modal | WindowFlag.ExpandSize, 600, 400);

    window.mainWidget = new GameWidget();

    window.windowIcon = drawableCache.getImage("dtetris-logo1");

    window.show();

    // run message loop
    return Platform.instance.enterMessageLoop();
}
