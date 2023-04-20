module widgets.scroll;

import dlangui;

class ScrollExample : ScrollWidget
{
    this(string ID)
    {
        super(ID);

        layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT);
        WidgetGroup scrollContent = new VerticalLayout("CONTENT");
        scrollContent.layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT);

        TableLayout table2 = new TableLayout("TABLE2");
        table2.colCount = 2;
        // headers
        table2.addChild((new TextWidget(null, "Parameter Name"d)).alignment(Align.Right | Align.VCenter));
        table2.addChild((new TextWidget(null, "Edit Box to edit parameter"d)).alignment(Align.Left | Align.VCenter));
        // row 1
        table2.addChild((new TextWidget(null, "Parameter 1 name"d)).alignment(Align.Right | Align.VCenter));
        table2.addChild((new EditLine("edit1", "Text 1"d)).layoutWidth(FILL_PARENT));
        // row 2
        table2.addChild((new TextWidget(null, "Parameter 2 name bla bla"d)).alignment(Align.Right | Align.VCenter));
        table2.addChild((new EditLine("edit2", "Some text for parameter 2 blah blah blah"d)).layoutWidth(FILL_PARENT));
        // row 3
        table2.addChild((new TextWidget(null, "Param 3"d)).alignment(Align.Right | Align.VCenter));
        table2.addChild((new EditLine("edit3", "Parameter 3 value"d)).layoutWidth(FILL_PARENT));
        // row 4
        table2.addChild((new TextWidget(null, "Param 4"d)).alignment(Align.Right | Align.VCenter));
        table2.addChild((new EditLine("edit3", "Parameter 4 value shdjksdfh hsjdfas hdjkf hdjsfk ah"d)).layoutWidth(FILL_PARENT));
        // row 5
        table2.addChild((new TextWidget(null, "Param 5 - edit text here - blah blah blah"d)).alignment(Align.Right | Align.VCenter));
        table2.addChild((new EditLine("edit3", "Parameter 5 value"d)).layoutWidth(FILL_PARENT));
        // row 6
        table2.addChild((new TextWidget(null, "Param 6 - just to fill content widget (DISABLED)"d)).alignment(Align.Right | Align.VCenter).enabled(false));
        table2.addChild((new EditLine("edit3", "Parameter 5 value"d)).layoutWidth(FILL_PARENT).enabled(false));
        // row 7
        table2.addChild((new TextWidget(null, "Param 7 - just to fill content widget (DISABLED)"d)).alignment(Align.Right | Align.VCenter).enabled(false));
        table2.addChild((new EditLine("edit3", "Parameter 5 value"d)).layoutWidth(FILL_PARENT).enabled(false));
        // row 8
        table2.addChild((new TextWidget(null, "Param 8 - just to fill content widget"d)).alignment(Align.Right | Align.VCenter));
        table2.addChild((new EditLine("edit3", "Parameter 5 value"d)).layoutWidth(FILL_PARENT));
        table2.margins(Rect(10,10,10,10)).layoutWidth(FILL_PARENT);
        scrollContent.addChild(table2);

        scrollContent.addChild(new TextWidget(null, "Now - some buttons"d));
        scrollContent.addChild(new ImageTextButton("btn1", "fileclose", "Close"d));
        scrollContent.addChild(new ImageTextButton("btn2", "fileopen", "Open"d));
        scrollContent.addChild(new TextWidget(null, "And checkboxes"d));
        scrollContent.addChild(new CheckBox("btn1", "CheckBox 1"d));
        scrollContent.addChild(new CheckBox("btn2", "CheckBox 2"d));

        contentWidget = scrollContent;
    }
}
