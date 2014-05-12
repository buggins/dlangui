module main;

import dlangui.all;
import std.stdio;
import std.conv;


mixin APP_ENTRY_POINT;

Widget createEditorSettingsControl(EditWidgetBase editor) {
    HorizontalLayout res = new HorizontalLayout("editor_options");
    res.addChild((new CheckBox("wantTabs", "wantTabs"d)).checked(editor.wantTabs).addOnCheckChangeListener(delegate(Widget, bool checked) { editor.wantTabs = checked; return true;}));
    res.addChild((new CheckBox("useSpacesForTabs", "useSpacesForTabs"d)).checked(editor.useSpacesForTabs).addOnCheckChangeListener(delegate(Widget, bool checked) { editor.useSpacesForTabs = checked; return true;}));
    res.addChild((new CheckBox("readOnly", "readOnly"d)).checked(editor.readOnly).addOnCheckChangeListener(delegate(Widget, bool checked) { editor.readOnly = checked; return true;}));
    res.addChild((new CheckBox("fixedFont", "fixedFont"d)).checked(editor.fontFamily == FontFamily.MonoSpace).addOnCheckChangeListener(delegate(Widget, bool checked) { 
        if (checked)
            editor.fontFamily(FontFamily.MonoSpace).fontFace("Courier New");
        else
            editor.fontFamily(FontFamily.SansSerif).fontFace("Arial");
        return true;
    }));
    res.addChild((new CheckBox("tabSize", "Tab size 8"d)).checked(editor.tabSize == 8).addOnCheckChangeListener(delegate(Widget, bool checked) { 
        if (checked)
            editor.tabSize(8);
        else
            editor.tabSize(4);
        return true;
    }));
    return res;
}

/// entry point for dlangui based application
extern (C) int UIAppMain(string[] args) {
    // resource directory search paths
    string[] resourceDirs = [
        appendPath(exePath, "../../../res/"),   // for Visual D and DUB builds
        appendPath(exePath, "../../../res/mdpi/"),   // for Visual D and DUB builds
        appendPath(exePath, "../../../../res/"),// for Mono-D builds
        appendPath(exePath, "../../../../res/mdpi/"),// for Mono-D builds
		appendPath(exePath, "res/"), // when res dir is located at the same directory as executable
		appendPath(exePath, "../res/"), // when res dir is located at project directory
		appendPath(exePath, "../../res/"), // when res dir is located at the same directory as executable
		appendPath(exePath, "res/mdpi/"), // when res dir is located at the same directory as executable
		appendPath(exePath, "../res/mdpi/"), // when res dir is located at project directory
		appendPath(exePath, "../../res/mdpi/") // when res dir is located at the same directory as executable
	];
    // setup resource directories - will use only existing directories
    drawableCache.setResourcePaths(resourceDirs);
    // setup i18n - look for i18n directory inside one of passed directories
    i18n.findTranslationsDir(resourceDirs);
    // select translation file - for english language
    i18n.load("en.ini"); //"ru.ini", "en.ini"

    // create window
    Window window = Platform.instance.createWindow("My Window", null);
	
	static if (true) {
        VerticalLayout contentLayout = new VerticalLayout();
        MenuItem mainMenuItems = new MenuItem();
        MenuItem fileItem = new MenuItem(new Action(1, "&File"d));
        fileItem.add(new Action(10, "&Open..."d, "document-open", KeyCode.KEY_O, KeyFlag.Control));
		fileItem.add(new Action(11, "&Save..."d, "document-save", KeyCode.KEY_S, KeyFlag.Control));
		MenuItem openRecentItem = new MenuItem(new Action(13, "Open recent..."d, "document-open-recent"));
        openRecentItem.add(new Action(100, "&1: File 1"d));
		openRecentItem.add(new Action(101, "&2: File 2"d));
		openRecentItem.add(new Action(102, "&3: File 3"d));
		openRecentItem.add(new Action(103, "&4: File 4"d));
		openRecentItem.add(new Action(104, "&5: File 5"d));
        fileItem.add(openRecentItem);
		fileItem.add(new Action(12, "E&xit"d, "document-close", KeyCode.KEY_X, KeyFlag.Alt));
        MenuItem editItem = new MenuItem(new Action(2, "&Edit"d));
		editItem.add(new Action(EditorActions.Copy, "Copy"d, "edit-copy", KeyCode.KEY_C, KeyFlag.Control));
		editItem.add(new Action(EditorActions.Paste, "Paste"d, "edit-paste", KeyCode.KEY_V, KeyFlag.Control));
		editItem.add(new Action(EditorActions.Cut, "Cut"d, "edit-cut", KeyCode.KEY_X, KeyFlag.Control));
		editItem.add(new Action(EditorActions.Undo, "Undo"d, "edit-undo", KeyCode.KEY_Z, KeyFlag.Control));
		editItem.add(new Action(EditorActions.Redo, "Redo"d, "edit-redo", KeyCode.KEY_Y, KeyFlag.Control));
		editItem.add(new Action(20, "Preferences..."d));
		MenuItem windowItem = new MenuItem(new Action(3, "&Window"d));
        windowItem.add(new Action(30, "Preferences"d));
        MenuItem helpItem = new MenuItem(new Action(4, "Help"d));
        helpItem.add(new Action(40, "View Help"d));
        helpItem.add(new Action(41, "About"d));
        mainMenuItems.add(fileItem);
        mainMenuItems.add(editItem);
        mainMenuItems.add(windowItem);
        mainMenuItems.add(helpItem);
        MainMenu mainMenu = new MainMenu(mainMenuItems);
		mainMenu.onMenuItemListener = delegate(MenuItem item) {
			Log.d("mainMenu.onMenuItemListener", item.label);
			const Action a = item.action;
			if (a) {
				if (window.focusedWidget)
					return window.focusedWidget.handleAction(a);
				else
					return contentLayout.handleAction(a);
			}
			return false;
		};
        contentLayout.addChild(mainMenu);

        TabWidget tabs = new TabWidget("TABS");
        tabs.layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT);

		LinearLayout layout = new LinearLayout("tab1");

		layout.addChild((new TextWidget()).textColor(0x00802000).text("Text widget 0"));
		layout.addChild((new TextWidget()).textColor(0x40FF4000).text("Text widget"));
		layout.addChild((new Button("BTN1")).textResource("EXIT")); //.textColor(0x40FF4000)
		
		static if (true) {
		

	    LinearLayout hlayout = new HorizontalLayout();
        hlayout.layoutWidth(FILL_PARENT);
		//hlayout.addChild((new Button()).text("<<")); //.textColor(0x40FF4000)
	    hlayout.addChild((new TextWidget()).text("Several").alignment(Align.Center));
		hlayout.addChild((new ImageWidget()).drawableId("btn_radio").padding(Rect(5,5,5,5)).alignment(Align.Center));
	    hlayout.addChild((new TextWidget()).text("items").alignment(Align.Center));
		hlayout.addChild((new ImageWidget()).drawableId("btn_check").padding(Rect(5,5,5,5)).alignment(Align.Center));
	    hlayout.addChild((new TextWidget()).text("in horizontal layout"));
		hlayout.addChild((new ImageWidget()).drawableId("exit").padding(Rect(5,5,5,5)).alignment(Align.Center));
        hlayout.addChild((new EditLine("editline", "Some text to edit"d)).alignment(Align.Center).layoutWidth(FILL_PARENT));
		//hlayout.addChild((new Button()).text(">>")); //.textColor(0x40FF4000)
	    hlayout.backgroundColor = 0x8080C0;
	    layout.addChild(hlayout);

	    LinearLayout vlayoutgroup = new HorizontalLayout();
	    LinearLayout vlayout = new VerticalLayout();
		vlayout.addChild((new TextWidget()).text("VLayout line 1").textColor(0x40FF4000)); //
	    vlayout.addChild((new TextWidget()).text("VLayout line 2").textColor(0x40FF8000));
	    vlayout.addChild((new TextWidget()).text("VLayout line 2").textColor(0x40008000));
	    vlayout.addChild(new RadioButton("rb1", "Radio button 1"d));
	    vlayout.addChild(new RadioButton("rb2", "Radio button 2"d));
	    vlayout.addChild(new RadioButton("rb3", "Radio button 3"d));
        vlayout.layoutWidth(FILL_PARENT);
	    vlayoutgroup.addChild(vlayout);
        vlayoutgroup.layoutWidth(FILL_PARENT);
        ScrollBar vsb = new ScrollBar("vscroll", Orientation.Vertical);
	    vlayoutgroup.addChild(vsb);
	    layout.addChild(vlayoutgroup);

        ScrollBar sb = new ScrollBar("hscroll", Orientation.Horizontal);
        layout.addChild(sb.layoutHeight(WRAP_CONTENT).layoutWidth(FILL_PARENT));

		layout.addChild((new CheckBox("BTN2", "Some checkbox"d)));
		layout.addChild((new TextWidget()).textColor(0x40FF4000).text("Text widget"));
		layout.addChild((new ImageWidget()).drawableId("exit").padding(Rect(5,5,5,5)));
		layout.addChild((new TextWidget()).textColor(0xFF4000).text("Text widget2").padding(Rect(5,5,5,5)).margins(Rect(5,5,5,5)).backgroundColor(0xA0A0A0));
		layout.addChild((new RadioButton("BTN3", "Some radio button"d)));
		layout.addChild((new TextWidget(null, "Text widget3 with very long text"d)).textColor(0x004000));
        layout.addChild(new VSpacer()); // vertical spacer to fill extra space

		layout.childById("BTN1").onClickListener = (delegate (Widget w) { Log.d("onClick ", w.id); return true; });
		layout.childById("BTN2").onClickListener = (delegate (Widget w) { Log.d("onClick ", w.id); return true; });
		layout.childById("BTN3").onClickListener = (delegate (Widget w) { Log.d("onClick ", w.id); return true; });

        }

		layout.layoutHeight(FILL_PARENT).layoutWidth(FILL_PARENT);

        tabs.addTab(layout, "Tab 1"d);

        static if (true) {
            ListWidget list = new ListWidget("tab2", Orientation.Vertical);
            WidgetListAdapter listAdapter = new WidgetListAdapter();
            for (int i = 0; i < 1000; i++)
                listAdapter.widgets.add((new TextWidget()).text("List item "d ~ to!dstring(i)).styleId("LIST_ITEM"));
            list.ownAdapter = listAdapter;
            listAdapter.resetItemState(0, State.Enabled);
            listAdapter.resetItemState(5, State.Enabled);
            listAdapter.resetItemState(7, State.Enabled);
            listAdapter.resetItemState(12, State.Enabled);
            assert(list.itemEnabled(5) == false);
            assert(list.itemEnabled(6) == true);
            list.layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT);
            list.selectItem(0);
            tabs.addTab(list, "Long List"d);
        }

        {
		    LinearLayout layout3 = new LinearLayout("tab3");
		    layout3.addChild(new TextWidget(null, "Buttons in HorizontalLayout"d));
		    WidgetGroup buttons1 = new HorizontalLayout();
            buttons1.addChild(new Button("btn1", "Button 1"d));
            buttons1.addChild(new Button("btn2", "Button 2"d));
            buttons1.addChild(new Button("btn3", "Button 3"d));
            buttons1.addChild(new Button("btn4", "Button 4"d));
            layout3.addChild(buttons1);
            layout3.addChild(new VSpacer());
		    layout3.addChild(new TextWidget(null, "CheckBoxes in HorizontalLayout"d));
		    WidgetGroup buttons2 = new HorizontalLayout();
            buttons2.addChild(new CheckBox("btn1", "CheckBox 1"d));
            buttons2.addChild(new CheckBox("btn2", "CheckBox 2"d));
            buttons2.addChild(new CheckBox("btn3", "CheckBox 3"d));
            buttons2.addChild(new CheckBox("btn4", "CheckBox 4"d));
            layout3.addChild(buttons2);

            layout3.addChild(new VSpacer());
		    layout3.addChild(new TextWidget(null, "RadioButtons in HorizontalLayout"d));
		    WidgetGroup buttons3 = new HorizontalLayout();
            buttons3.addChild(new RadioButton("btn1", "RadioButton 1"d));
            buttons3.addChild(new RadioButton("btn2", "RadioButton 2"d));
            buttons3.addChild(new RadioButton("btn3", "RadioButton 3"d));
            buttons3.addChild(new RadioButton("btn4", "RadioButton 4"d));
            layout3.addChild(buttons3);

            layout3.addChild(new VSpacer());
		    layout3.addChild(new TextWidget(null, "ImageButtons HorizontalLayout"d));
		    WidgetGroup buttons4 = new HorizontalLayout();
            buttons4.addChild(new ImageButton("btn1", "fileclose"));
            buttons4.addChild(new ImageButton("btn2", "fileopen"));
            buttons4.addChild(new ImageButton("btn3", "exit"));
            layout3.addChild(buttons4);

            layout3.addChild(new VSpacer());
		    layout3.addChild(new TextWidget(null, "In vertical layouts:"d));
		    HorizontalLayout hlayout2 = new HorizontalLayout();
            hlayout2.layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT);

		    buttons1 = new VerticalLayout();
		    buttons1.addChild(new TextWidget(null, "Buttons"d));
            buttons1.addChild(new Button("btn1", "Button 1"d));
            buttons1.addChild(new Button("btn2", "Button 2"d));
            buttons1.addChild((new Button("btn3", "Button 3 - disabled"d)).enabled(false));
            buttons1.addChild(new Button("btn4", "Button 4"d));
            hlayout2.addChild(buttons1);
            hlayout2.addChild(new HSpacer());

		    buttons2 = new VerticalLayout();
		    buttons2.addChild(new TextWidget(null, "CheckBoxes"d));
            buttons2.addChild(new CheckBox("btn1", "CheckBox 1"d));
            buttons2.addChild(new CheckBox("btn2", "CheckBox 2"d));
            buttons2.addChild(new CheckBox("btn3", "CheckBox 3"d));
            buttons2.addChild(new CheckBox("btn4", "CheckBox 4"d));
            hlayout2.addChild(buttons2);
            hlayout2.addChild(new HSpacer());

		    buttons3 = new VerticalLayout();
		    buttons3.addChild(new TextWidget(null, "RadioButtons"d));
            buttons3.addChild(new RadioButton("btn1", "RadioButton 1"d));
            buttons3.addChild(new RadioButton("btn2", "RadioButton 2"d));
            buttons3.addChild(new RadioButton("btn3", "RadioButton 3"d));
            buttons3.addChild(new RadioButton("btn4", "RadioButton 4"d));
            hlayout2.addChild(buttons3);
            hlayout2.addChild(new HSpacer());

		    buttons4 = new VerticalLayout();
		    buttons4.addChild(new TextWidget(null, "ImageButtons"d));
            buttons4.addChild(new ImageButton("btn1", "fileclose"));
            buttons4.addChild(new ImageButton("btn2", "fileopen"));
            buttons4.addChild(new ImageButton("btn3", "exit"));
            hlayout2.addChild(buttons4);
            hlayout2.addChild(new HSpacer());

		    WidgetGroup buttons5 = new VerticalLayout();
		    buttons5.addChild(new TextWidget(null, "ImageTextButtons"d));
            buttons5.addChild(new ImageTextButton("btn1", "fileclose", "Close"d));
            buttons5.addChild(new ImageTextButton("btn2", "fileopen", "Open"d));
            buttons5.addChild(new ImageTextButton("btn3", "exit", "Exit"d));
            hlayout2.addChild(buttons5);


            layout3.addChild(hlayout2);

            layout3.addChild(new VSpacer());
            layout3.layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT);
            tabs.addTab(layout3, "Buttons"d);
        }
        tabs.addTab((new TextWidget()).id("tab4").textColor(0x00802000).text("Tab 4 contents some long string"), "Tab 4"d);
        tabs.addTab((new TextWidget()).id("tab5").textColor(0x00802000).text("Tab 5 contents"), "Tab 5"d);

        //==========================================================================
		// create Editors test tab
		VerticalLayout editors = new VerticalLayout("editors");

        // EditLine sample
		editors.addChild(new TextWidget(null, "EditLine: Single line editor"d));
		EditLine editLine = new EditLine("editline1", "Single line editor sample text");
        editors.addChild(createEditorSettingsControl(editLine));
		editors.addChild(editLine);

        // EditBox sample
		editors.addChild(new TextWidget(null, "EditBox: Multiline editor"d));

        EditBox editBox = new EditBox("editbox1", "Some text\nSecond line\nYet another line\n\n\tforeach(s;lines);\n\t\twriteln(s);\n"d);
        editBox.layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT);
        dstring text = editBox.text;
        for (int i = 0; i < 100; i++) {
            text ~= "\n Line ";
            text ~= to!dstring(i + 5);
            text ~= " Some long long line. Blah blah blah.";
            for (int j = 0; j <= i % 4; j++)
                text ~= " The quick brown fox jumps over the lazy dog.";
        }
        editBox.text = text;
        editBox.minFontSize(12).maxFontSize(75); // allow font zoom with Ctrl + MouseWheel
        editors.addChild(createEditorSettingsControl(editBox));
		editors.addChild(editBox);

		editors.addChild(new TextWidget(null, "EditBox: additional view for the same content (split view testing)"d));
        EditBox editBox2 = new EditBox("editbox2", ""d);
        editBox2.content = editBox.content; // view the same content as first editbox
        editBox2.minFontSize(12).maxFontSize(75); // allow font zoom with Ctrl + MouseWheel
		editors.addChild(editBox2);
        editors.layoutHeight(FILL_PARENT).layoutWidth(FILL_PARENT);

        tabs.addTab(editors, "Editors"d);

        //==========================================================================

        contentLayout.addChild(tabs);
	    window.mainWidget = contentLayout;

		tabs.selectTab("tab3");

	} else {
	    window.mainWidget = (new Button()).text("sample button");
	}
    window.show();
    //window.windowCaption = "New Window Caption";
    // run message loop
    return Platform.instance.enterMessageLoop();
}
