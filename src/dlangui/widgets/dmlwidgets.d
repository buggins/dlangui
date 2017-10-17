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

    import dlangui.widgets.menu;

    mixin(registerWidgetMetadataClass!MainMenu); //dlangui.widgets.menu

    import dlangui.widgets.tree;

    mixin(registerWidgetMetadataClass!TreeWidget); // dlangui.widgets.tree

    import dlangui.widgets.tabs;

    mixin(registerWidgetMetadataClass!TabWidget); // dlangui.widgets.tabs

    import dlangui.dialogs.filedlg;

    mixin(registerWidgetMetadataClass!FileNameEditLine);
    mixin(registerWidgetMetadataClass!DirEditLine);

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
    TabWidget, // dlangui.widgets.tabs
    ));


    registerWidgets1();
    //registerWidgets2();
    registerWidgets3();
    registerWidgets4();
    */
}

