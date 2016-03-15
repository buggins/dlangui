module main;

import dlangui;
import ircclient.ui.frame;

mixin APP_ENTRY_POINT;

/// entry point for dlangui based application
extern (C) int UIAppMain(string[] args) {

    // embed non-standard resources listed in views/resources.list into executable
    embeddedResourceList.addResources(embedResourcesFromList!("resources.list")());

    /// set font gamma (1.0 is neutral, < 1.0 makes glyphs lighter, >1.0 makes glyphs bolder)
    FontManager.fontGamma = 0.8;
    FontManager.hintingMode = HintingMode.Normal;

    // create window
    Window window = Platform.instance.createWindow("DlangUI IRC Client"d, null, WindowFlag.Resizable, 700, 470);

    // create some widget to show in window
    window.windowIcon = drawableCache.getImage("dlangui-logo1");


    // create some widget to show in window
    window.mainWidget = new IRCFrame();

    // show window
    window.show();

    // run message loop
    return Platform.instance.enterMessageLoop();
}
