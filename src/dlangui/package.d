// Written in the D programming language.

/**
`import dlangui;` imports the modules most apps need:

$(UL
    $(LI core: config, logger, types, i18n, files, standard actions)
    $(LI graphics: images, colors, fonts, draw buffers)
    $(LI widgets: the base widget, controls, scroll bars, progress bar, layouts, group box, lists, tabs, menus,
        scroll widget, editors and source editor, grid, tree, process output, combo boxes, popups, app frame,
        status line, docks, toolbars, charts)
    $(LI dialogs: Dialog, FileDialog, message box and input box)
    $(LI the platform (Platform, Window, APP_ENTRY_POINT) and the DML parser)
    $(LI from Phobos: std.algorithm.equal, std.conv.to, std.utf.toUTF32)
)

Other modules, e.g. dlangui.dialogs.settingsdialog, dlangui.widgets.styles or dlangui.graphics.resources,
are imported where needed.

Synopsis:

----
// helloworld
import dlangui;
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
    Platform.instance.resourceDirs = resourceDirs;
    // select translation file - for english language
    Platform.instance.uiLanguage = "en";
    // load theme from file "theme_default.xml"
    Platform.instance.uiTheme = "theme_default";

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
License:   Boost License 1.0
Authors:   Vadim Lopatin, coolreader.org@gmail.com
 */
module dlangui;

public {
    import dlangui.core.config;
    import dlangui.core.logger;
    import dlangui.core.types;
    import dlangui.core.i18n;
    import dlangui.core.files;
    import dlangui.core.stdaction;
    import dlangui.graphics.images;
    import dlangui.graphics.colors;
    import dlangui.graphics.fonts;
    import dlangui.graphics.drawbuf;
    import dlangui.widgets.widget;
    import dlangui.widgets.controls;
    import dlangui.widgets.scrollbar;
    import dlangui.widgets.progressbar;
    import dlangui.widgets.layouts;
    import dlangui.widgets.groupbox;
    import dlangui.widgets.lists;
    import dlangui.widgets.tabs;
    import dlangui.widgets.menu;
    import dlangui.widgets.scroll;
    import dlangui.widgets.editors;
    import dlangui.widgets.srcedit;
    import dlangui.widgets.grid;
    import dlangui.widgets.tree;
    import dlangui.widgets.processoutput;
    import dlangui.widgets.combobox;
    import dlangui.widgets.popup;
    import dlangui.widgets.appframe;
    import dlangui.widgets.statusline;
    import dlangui.widgets.docks;
    import dlangui.widgets.toolbars;
    import dlangui.widgets.charts;
    import dlangui.dialogs.dialog;
    import dlangui.dialogs.filedlg;
    import dlangui.dialogs.msgbox;
    import dlangui.dialogs.inputbox;
    import dlangui.platforms.common.platform;
    import dlangui.dml.parser;

    // some useful imports from Phobos
    import std.algorithm : equal;
    import std.conv : to;
    import std.utf : toUTF32;
}
