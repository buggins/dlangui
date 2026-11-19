module dlangui.widgets.dmlwidgets;

/// register standard widgets to use in DML
extern(C) void registerStandardWidgets() {
    import dlangui.core.config;
    import dlangui.core.logger;

    Log.d("Registering standard widgets for DML");

    import dlangui.widgets.metadata;
    import dlangui.widgets.widget;

    mixin(registerWidgetMetadataClass!Widget);

    import dlangui.widgets.layouts;
    mixin(registerWidgetMetadataClass!VerticalLayout);
    mixin(registerWidgetMetadataClass!HorizontalLayout);
    mixin(registerWidgetMetadataClass!TableLayout);
    mixin(registerWidgetMetadataClass!FrameLayout); // dlangui.widgets.layouts

    import dlangui.widgets.controls;

    mixin(registerWidgetMetadataClass!TextWidget);
    mixin(registerWidgetMetadataClass!MultilineTextWidget);
    mixin(registerWidgetMetadataClass!Button);
    mixin(registerWidgetMetadataClass!ImageWidget);
    mixin(registerWidgetMetadataClass!ImageButton);
    mixin(registerWidgetMetadataClass!ImageCheckButton);
    mixin(registerWidgetMetadataClass!ImageTextButton);
    mixin(registerWidgetMetadataClass!SwitchButton);
    mixin(registerWidgetMetadataClass!RadioButton);
    mixin(registerWidgetMetadataClass!CheckBox);
    mixin(registerWidgetMetadataClass!HSpacer);
    mixin(registerWidgetMetadataClass!VSpacer);
    mixin(registerWidgetMetadataClass!CanvasWidget); // dlangui.widgets.controls

    import dlangui.widgets.scrollbar;

    mixin(registerWidgetMetadataClass!ScrollBar);
    mixin(registerWidgetMetadataClass!SliderWidget); // dlangui.widgets.scrollbar

    import dlangui.widgets.lists;

    mixin(registerWidgetMetadataClass!ListWidget);
    mixin(registerWidgetMetadataClass!StringListWidget);//dlangui.widgets.lists


    import dlangui.widgets.editors;

    mixin(registerWidgetMetadataClass!EditLine);
    mixin(registerWidgetMetadataClass!EditBox);
    mixin(registerWidgetMetadataClass!LogWidget);//dlangui.widgets.editors

    import dlangui.widgets.combobox;
    mixin(registerWidgetMetadataClass!ComboBox);
    mixin(registerWidgetMetadataClass!ComboEdit); //dlangui.widgets.combobox

    import dlangui.widgets.grid;

    mixin(registerWidgetMetadataClass!StringGridWidget); //dlangui.widgets.grid

    import dlangui.widgets.groupbox;

    mixin(registerWidgetMetadataClass!GroupBox); // dlangui.widgets.groupbox

    import dlangui.widgets.progressbar;

    mixin(registerWidgetMetadataClass!ProgressBarWidget); // dlangui.widgets.progressbar

    import dlangui.widgets.processoutput;

    mixin(registerWidgetMetadataClass!ProcessOutputWidget); // dlangui.widgets.processoutput

    import dlangui.widgets.menu;

    mixin(registerWidgetMetadataClass!MainMenu); //dlangui.widgets.menu

    import dlangui.widgets.tree;

    mixin(registerWidgetMetadataClass!TreeWidget); // dlangui.widgets.tree

    import dlangui.widgets.tabs;

    mixin(registerWidgetMetadataClass!TabWidget); // dlangui.widgets.tabs
    mixin(registerWidgetMetadataClass!TabPage);

    import dlangui.dialogs.filedlg;

    mixin(registerWidgetMetadataClass!FileNameEditLine);
    mixin(registerWidgetMetadataClass!DirEditLine);

    mixin(registerWidgetMetadataClass!ResizerWidget);

    /*
    mixin (registerWidgets!("void registerWidgets1",
    FileNameEditLine, DirEditLine, //dlangui.dialogs.filedlg
    ComboBox, ComboEdit, //dlangui.widgets.combobox
    //                       )());
    //mixin(registerWidgets!("void registerWidgets2",
    Widget, TextWidget, MultilineTextWidget, Button, ImageWidget, ImageButton, ImageCheckButton, ImageTextButton,
    ));
    mixin(registerWidgets!("void registerWidgets3",
    SwitchButton, RadioButton, CheckBox, HSpacer, VSpacer, CanvasWidget, // dlangui.widgets.controls
    ScrollBar, SliderWidget, // dlangui.widgets.scrollbar
    EditLine, EditBox, LogWidget,//dlangui.widgets.editors
    ));
    mixin(registerWidgets!("void registerWidgets4",
    GroupBox, // dlangui.widgets.groupbox
    ProgressBarWidget, // dlangui.widgets.progressbar
    StringGridWidget, //dlangui.widgets.grid
    VerticalLayout, HorizontalLayout, TableLayout, FrameLayout, // dlangui.widgets.layouts
    MainMenu, //dlangui.widgets.menu
    TreeWidget, // dlangui.widgets.tree
    TabWidget, TabPage, // dlangui.widgets.tabs
    ));


    registerWidgets1();
    //registerWidgets2();
    registerWidgets3();
    registerWidgets4();
    */
}

unittest {
    import dlangui.widgets.metadata;
    registerStandardWidgets();
    assert(findWidgetMetadata("ProcessOutputWidget") !is null, "ProcessOutputWidget is not registered for DML");
}

// ImageTextButton icon and LinearLayout orientation set from DML and code (#838)
unittest {
    import dlangui.dml.parser : parseML;
    import dlangui.widgets.controls : ImageTextButton, ImageWidget;
    import dlangui.widgets.layouts : HorizontalLayout;
    import dlangui.widgets.widget : Orientation, Visibility;
    import dlangui.widgets.styles : currentTheme, createDefaultTheme;
    // the currentTheme setter destroys the previous theme: replace only a theme created here
    immutable bool ownTheme = currentTheme is null;
    if (ownTheme)
        currentTheme = createDefaultTheme();
    scope (exit) if (ownTheme) currentTheme = null;
    registerStandardWidgets();

    auto b = cast(ImageTextButton)parseML(q{
        ImageTextButton { id: btn; text: "Open"; drawableId: "document-open"; orientation: Vertical }
    });
    assert(b !is null);
    scope (exit) destroy(b);
    ImageWidget icon = b.childById!ImageWidget("icon");
    assert(icon !is null);
    assert(b.drawableId == "document-open");
    assert(icon.drawableId == "document-open");
    assert(icon.visibility == Visibility.Visible);
    assert(b.orientation == Orientation.Vertical);
    assert(b.text == "Open");
    b.drawableId = "";
    assert(b.drawableId is null);
    assert(icon.visibility == Visibility.Gone);
    b.drawableId = "folder";
    assert(icon.drawableId == "folder");
    assert(icon.visibility == Visibility.Visible);
    b.drawableId = null;
    assert(icon.visibility == Visibility.Gone);

    auto l = cast(HorizontalLayout)parseML(q{ HorizontalLayout { orientation: vertical } });
    assert(l !is null);
    scope (exit) destroy(l);
    assert(l.orientation == Orientation.Vertical);
    assert(!l.setIntProperty("orientation", 5));
    assert(l.orientation == Orientation.Vertical);
}
