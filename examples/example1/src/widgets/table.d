module widgets.table;

import dlangui;

class TableExample : TableLayout
{
    this(string ID)
    {
        super(ID);

        colCount = 2;
        // headers
        addChild((new TextWidget(null, "Parameter Name"d)).alignment(Align.Right | Align.VCenter));
        addChild((new TextWidget(null, "Edit Box to edit parameter"d)).alignment(Align.Left | Align.VCenter));
        // row 1
        addChild((new TextWidget(null, "Parameter 1 name"d)).alignment(Align.Right | Align.VCenter));
        addChild((new EditLine("edit1", "Text 1"d)).layoutWidth(FILL_PARENT));
        // row 2
        addChild((new TextWidget(null, "Parameter 2 name bla bla"d)).alignment(Align.Right | Align.VCenter));
        addChild((new EditLine("edit2", "Some text for parameter 2"d)).layoutWidth(FILL_PARENT));
        // row 3
        addChild((new TextWidget(null, "Param 3 is disabled"d)).alignment(Align.Right | Align.VCenter).enabled(false));
        addChild((new EditLine("edit3", "Parameter 3 value"d)).layoutWidth(FILL_PARENT).enabled(false));
        // normal readonly combo box
        ComboBox combo1 = new ComboBox("combo1", ["item value 1"d, "item value 2"d, "item value 3"d, "item value 4"d, "item value 5"d, "item value 6"d]);
        addChild((new TextWidget(null, "Combo box param"d)).alignment(Align.Right | Align.VCenter));
        combo1.selectedItemIndex = 3;
        addChild(combo1).layoutWidth(FILL_PARENT);
        // disabled readonly combo box
        ComboBox combo2 = new ComboBox("combo2", ["item value 1"d, "item value 2"d, "item value 3"d]);
        addChild((new TextWidget(null, "Disabled combo box"d)).alignment(Align.Right | Align.VCenter));
        combo2.enabled = false;
        combo2.selectedItemIndex = 0;
        addChild(combo2).layoutWidth(FILL_PARENT);

        margins(Rect(2,2,2,2)).layoutWidth(FILL_PARENT);
    }
}
