module winmain;

import dlangui.all;
import std.stdio;
import std.conv;

version (linux) {
	//pragma(lib, "png");
	pragma(lib, "xcb");
	pragma(lib, "xcb-shm");
	pragma(lib, "xcb-image");
	pragma(lib, "X11-xcb");
	pragma(lib, "X11");
	pragma(lib, "dl");
}

/// workaround for link issue when WinMain is located in library
version(Windows) {
    private import win32.windows;
    private import dlangui.platforms.windows.winapp;
    extern (Windows)
        int WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance,
                    LPSTR lpCmdLine, int nCmdShow)
        {
            return DLANGUIWinMain(hInstance, hPrevInstance,
                                  lpCmdLine, nCmdShow);
        }
}

/// entry point for dlangui based application
extern (C) int UIAppMain(string[] args) {
    // setup resource dir
	version (Windows) {
    	string resourceDir = exePath() ~ "..\\res\\";
    	string i18nDir = exePath() ~ "..\\res\\i18n\\";
	} else {
    	string resourceDir = exePath() ~ "../../res/";
    	string i18nDir = exePath() ~ "../res/i18n/";
	}
    string[] imageDirs = [
        resourceDir
    ];
    drawableCache.resourcePaths = imageDirs;
    i18n.resourceDir = i18nDir;
    i18n.load("ru.ini", "en.ini");

    // create window
    Window window = Platform.instance().createWindow("My Window", null);
	
	static if (true) {
        VerticalLayout contentLayout = new VerticalLayout();
        MenuItem mainMenuItems = new MenuItem();
        MenuItem fileItem = new MenuItem(new Action(1, "File"d));
        fileItem.add(new Action(10, "Open..."d));
        fileItem.add(new Action(11, "Save..."d));
        MenuItem openRecentItem = new MenuItem(new Action(13, "Open recent..."d));
        openRecentItem.add(new Action(100, "File 1"d));
        openRecentItem.add(new Action(101, "File 2"d));
        openRecentItem.add(new Action(102, "File 3"d));
        openRecentItem.add(new Action(103, "File 4"d));
        openRecentItem.add(new Action(104, "File 5"d));
        fileItem.add(openRecentItem);
        fileItem.add(new Action(12, "Exit"d));
        MenuItem editItem = new MenuItem(new Action(2, "Edit"d));
        editItem.add(new Action(20, "Copy"d));
        editItem.add(new Action(21, "Paste"d));
        editItem.add(new Action(22, "Cut"d));
        MenuItem windowItem = new MenuItem(new Action(3, "Window"d));
        windowItem.add(new Action(30, "Preferences"d));
        MenuItem helpItem = new MenuItem(new Action(4, "Help"d));
        helpItem.add(new Action(40, "View Help"d));
        helpItem.add(new Action(41, "About"d));
        mainMenuItems.add(fileItem);
        mainMenuItems.add(editItem);
        mainMenuItems.add(windowItem);
        mainMenuItems.add(helpItem);
        MainMenu mainMenu = new MainMenu(mainMenuItems);
        contentLayout.addChild(mainMenu);

        TabWidget tabs = new TabWidget("TABS");
        tabs.layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT);

		LinearLayout layout = new LinearLayout("tab1");

		layout.addChild((new TextWidget()).textColor(0x00802000).text("Text widget 0"));
		layout.addChild((new TextWidget()).textColor(0x40FF4000).text("Text widget"));
		layout.addChild((new Button("BTN1")).textResource("EXIT")); //.textColor(0x40FF4000)
		
		static if (false) {
		

	    LinearLayout hlayout = new HorizontalLayout();
		//hlayout.addChild((new Button()).text("<<")); //.textColor(0x40FF4000)
	    hlayout.addChild((new TextWidget()).text("Several").alignment(Align.Center));
		hlayout.addChild((new ImageWidget()).drawableId("exit").padding(Rect(5,5,5,5)).alignment(Align.Center));
	    hlayout.addChild((new TextWidget()).text("items").alignment(Align.Center));
		hlayout.addChild((new ImageWidget()).drawableId("exit").padding(Rect(5,5,5,5)).alignment(Align.Center));
	    hlayout.addChild((new TextWidget()).text("in horizontal layout"));
		hlayout.addChild((new ImageWidget()).drawableId("exit").padding(Rect(5,5,5,5)).alignment(Align.Center));
		//hlayout.addChild((new Button()).text(">>")); //.textColor(0x40FF4000)
	    hlayout.backgroundColor = 0x8080C0;
	    layout.addChild(hlayout);

	    LinearLayout vlayoutgroup = new HorizontalLayout();
	    LinearLayout vlayout = new VerticalLayout();
		vlayout.addChild((new TextWidget()).text("VLayout line 1").textColor(0x40FF4000)); //
	    vlayout.addChild((new TextWidget()).text("VLayout line 2").textColor(0x40FF8000));
	    vlayout.addChild((new TextWidget()).text("VLayout line 2").textColor(0x40008000));
        vlayout.layoutWidth(FILL_PARENT);
	    vlayoutgroup.addChild(vlayout);
        vlayoutgroup.layoutWidth(FILL_PARENT);
        ScrollBar vsb = new ScrollBar("vscroll", Orientation.Vertical);
	    vlayoutgroup.addChild(vsb);
	    layout.addChild(vlayoutgroup);

        ScrollBar sb = new ScrollBar("hscroll", Orientation.Horizontal);
        layout.addChild(sb.layoutHeight(WRAP_CONTENT).layoutWidth(FILL_PARENT));

		layout.addChild((new Button("BTN2")).textColor(0x000000FF).text("Button2"));
		layout.addChild((new TextWidget()).textColor(0x40FF4000).text("Text widget"));
		layout.addChild((new ImageWidget()).drawableId("exit").padding(Rect(5,5,5,5)));
		layout.addChild((new TextWidget()).textColor(0xFF4000).text("Text widget2").padding(Rect(5,5,5,5)).margins(Rect(5,5,5,5)).backgroundColor(0xA0A0A0));
		layout.addChild((new Button("BTN3")).textColor(0x000000FF).text("Button3").layoutHeight(FILL_PARENT));
		layout.addChild((new TextWidget()).textColor(0x004000).text("Text widget3 with very long text"));

		layout.childById("BTN1").onClickListener(delegate (Widget w) { Log.d("onClick ", w.id); return true; });
		layout.childById("BTN2").onClickListener(delegate (Widget w) { Log.d("onClick ", w.id); return true; });
		layout.childById("BTN3").onClickListener(delegate (Widget w) { Log.d("onClick ", w.id); return true; });

        }

		layout.layoutHeight(FILL_PARENT).layoutWidth(FILL_PARENT);

        tabs.addTab(layout, "Tab 1"d);

        static if (false) {
            ListWidget list = new ListWidget("tab2", Orientation.Vertical);
            WidgetListAdapter listAdapter = new WidgetListAdapter();
            for (int i = 0; i < 3000; i++)
                listAdapter.widgets.add((new TextWidget()).text("List item "d ~ to!dstring(i)));
            list.ownAdapter = listAdapter;
            list.layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT);
            tabs.addTab(list, "Lists"d);
        }

        tabs.addTab((new TextWidget()).id("tab3").textColor(0x00802000).text("Tab 3 contents"), "Tab 3"d);
        tabs.addTab((new TextWidget()).id("tab4").textColor(0x00802000).text("Tab 4 contents some long string"), "Tab 4"d);
        tabs.addTab((new TextWidget()).id("tab5").textColor(0x00802000).text("Tab 5 contents"), "Tab 5"d);

        tabs.selectTab("tab1");

        contentLayout.addChild(tabs);
	    window.mainWidget = contentLayout;
	} else {
	    window.mainWidget = (new Button()).text("sample button");
	}
    window.show();
    window.showPopup((new TextWidget()).text("POPUP"d));
    window.windowCaption = "New Window Caption";

    // run message loop
    return Platform.instance().enterMessageLoop();
}
