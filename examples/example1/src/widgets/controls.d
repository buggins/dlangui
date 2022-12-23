module widgets.controls;

import dlangui;

class BasicControls : LinearLayout
{
    this(string ID)
    {
        super(ID);
        layoutHeight(FILL_PARENT);
        padding = Rect(12.pointsToPixels,12.pointsToPixels,12.pointsToPixels,12.pointsToPixels);

        HorizontalLayout line1 = new HorizontalLayout();
        addChild(line1);

        GroupBox gb = new GroupBox("checkboxes", "CheckBox"d);
        gb.addChild(new CheckBox("cb1", "CheckBox 1"d));
        gb.addChild(new CheckBox("cb2", "CheckBox 2"d).checked(true));
        gb.addChild(new CheckBox("cb3", "CheckBox disabled"d).enabled(false));
        gb.addChild(new CheckBox("cb4", "CheckBox disabled"d).checked(true).enabled(false));
        line1.addChild(gb);

        GroupBox gb2 = new GroupBox("radiobuttons", "RadioButton"d);
        gb2.addChild(new RadioButton("rb1", "RadioButton 1"d).checked(true));
        gb2.addChild(new RadioButton("rb2", "RadioButton 2"d));
        gb2.addChild(new RadioButton("rb3", "RadioButton disabled"d).enabled(false));
        line1.addChild(gb2);

        VerticalLayout col1 = new VerticalLayout();
        GroupBox gb3 = new GroupBox("textbuttons", "Button"d, Orientation.Horizontal);
        gb3.addChild(new Button("tb1", "Button"d));
        gb3.addChild(new Button("tb2", "Button disabled"d).enabled(false));
        col1.addChild(gb3);
        GroupBox gb4 = new GroupBox("imagetextbuttons", "ImageTextButton"d, Orientation.Horizontal);
        gb4.addChild(new ImageTextButton("itb1", "document-open", "Enabled"d));
        gb4.addChild(new ImageTextButton("itb2", "document-save", "Disabled"d).enabled(false));
        col1.addChild(gb4);
        GroupBox gbtext = new GroupBox("text", "TextWidget"d, Orientation.Horizontal);
        gbtext.addChild(new TextWidget("t1", "Red text"d).fontSize(12.pointsToPixels).textColor(0xFF0000));
        gbtext.addChild(new TextWidget("t2", "Italic text"d).fontSize(12.pointsToPixels).fontItalic(true));
        col1.addChild(gbtext);
        line1.addChild(col1);

        VerticalLayout col2 = new VerticalLayout();
        GroupBox gb31 = new GroupBox("switches", "SwitchButton"d, Orientation.Vertical);
        gb31.addChild(new SwitchButton("sb1"));
        gb31.addChild(new SwitchButton("sb2").checked(true));
        gb31.addChild(new SwitchButton("sb3").enabled(false));
        gb31.addChild(new SwitchButton("sb4").enabled(false).checked(true));
        col2.addChild(gb31);
        line1.addChild(col2);

        VerticalLayout col3 = new VerticalLayout();
        GroupBox gb32 = new GroupBox("switches", "ImageButton"d, Orientation.Vertical);
        gb32.addChild(new ImageButton("ib1", "edit-copy"));
        gb32.addChild(new ImageButton("ib3", "edit-paste").enabled(false));
        col3.addChild(gb32);
        GroupBox gb33 = new GroupBox("images", "ImageWidget"d, Orientation.Vertical);
        gb33.addChild(new ImageWidget("cr3_logo", "cr3_logo"));
        col3.addChild(gb33);
        line1.addChild(col3);


        HorizontalLayout line2 = new HorizontalLayout();
        addChild(line2);

        GroupBox gb5 = new GroupBox("scrollbar", "horizontal ScrollBar"d);
        gb5.addChild(new ScrollBar("sb1", Orientation.Horizontal));
        line2.addChild(gb5);
        GroupBox gb6 = new GroupBox("slider", "horizontal SliderWidget"d);
        gb6.addChild(new SliderWidget("sb2", Orientation.Horizontal));
        line2.addChild(gb6);
        GroupBox gb7 = new GroupBox("editline1", "EditLine"d);
        gb7.addChild(new EditLine("ed1", "Some text"d).minWidth(120.pointsToPixels));
        line2.addChild(gb7);
        GroupBox gb8 = new GroupBox("editline2", "EditLine disabled"d);
        gb8.addChild(new EditLine("ed2", "Some text"d).enabled(false).minWidth(120.pointsToPixels));
        line2.addChild(gb8);

        HorizontalLayout line3 = new HorizontalLayout();
        line3.layoutWidth(FILL_PARENT);
        GroupBox gbeditbox = new GroupBox("editbox", "EditBox"d, Orientation.Horizontal);
        gbeditbox.layoutWidth(FILL_PARENT);
        EditBox ed1 = new EditBox("ed1", "Some text in EditBox\nOne more line\nYet another text line");
        ed1.layoutHeight(FILL_PARENT);
        gbeditbox.addChild(ed1);
        line3.addChild(gbeditbox);
        GroupBox gbtabs = new GroupBox(null, "TabWidget"d);
        gbtabs.layoutWidth(FILL_PARENT);
        TabWidget tabs1 = new TabWidget("tabs1");
        tabs1.addTab(new TextWidget("tab1", "TextWidget on tab page\nTextWidgets can be\nMultiline"d).maxLines(3), "Tab 1"d);
        tabs1.addTab(new ImageWidget("tab2", "dlangui-logo1"), "Tab 2"d);
        tabs1.tabHost.backgroundColor = 0xE0E0E0;
        tabs1.tabHost.padding = Rect(10.pointsToPixels, 10.pointsToPixels, 10.pointsToPixels, 10.pointsToPixels);
        gbtabs.addChild(tabs1);
        line3.addChild(gbtabs);
        addChild(line3);

        HorizontalLayout line4 = new HorizontalLayout();
        line4.layoutWidth(FILL_PARENT);
        line4.layoutHeight(FILL_PARENT);
        GroupBox gbgrid = new GroupBox("grid", "StringGridWidget"d, Orientation.Horizontal);
        StringGridWidget grid = new StringGridWidget("stringgrid");
        grid.resize(12, 10);
        gbgrid.layoutWidth(FILL_PARENT);
        gbgrid.layoutHeight(FILL_PARENT);
        grid.layoutWidth(FILL_PARENT);
        grid.layoutHeight(FILL_PARENT);
        foreach (index, month; ["January"d, "February"d, "March"d, "April"d, "May"d, "June"d, "July"d, "August"d, "September"d, "October"d, "November"d, "December"d])
            grid.setColTitle(cast(int)index, month);
        for (int y = 0; y < 10; y++)
            grid.setRowTitle(y, to!dstring(y+1));

        grid.setColWidth(0, 30.pointsToPixels);
        grid.autoFit();
        import std.random;
        import std.string;
        for (int x = 0; x < 12; x++) {
            for (int y = 0; y < 10; y++) {
                int n = uniform(0, 10000);
                grid.setCellText(x, y, to!dstring("%.2f".format(n / 100.0)));
            }
        }

        gbgrid.addChild(grid);
        line4.addChild(gbgrid);

        GroupBox gbtree = new GroupBox("tree", "TreeWidget"d, Orientation.Vertical);
        auto tree = new TreeWidget("gbtree");
        tree.maxHeight(200.pointsToPixels);
        TreeItem tree1 = tree.items.newChild("group1", "Group 1"d, "document-open");
        tree1.newChild("g1_1", "Group 1 item 1"d);
        tree1.newChild("g1_2", "Group 1 item 2"d);
        tree1.newChild("g1_3", "Group 1 item 3"d);
        TreeItem tree2 = tree.items.newChild("group2", "Group 2"d, "document-save");
        tree2.newChild("g2_1", "Group 2 item 1"d, "edit-copy");
        tree2.newChild("g2_2", "Group 2 item 2"d, "edit-cut");
        tree2.newChild("g2_3", "Group 2 item 3"d, "edit-paste");
        tree2.newChild("g2_4", "Group 2 item 4"d);
        TreeItem tree3 = tree.items.newChild("group3", "Group 3"d);
        tree3.newChild("g3_1", "Group 3 item 1"d);
        tree3.newChild("g3_2", "Group 3 item 2"d);
        TreeItem tree32 = tree3.newChild("g3_3", "Group 3 item 3"d);
        tree3.newChild("g3_4", "Group 3 item 4"d);
        tree32.newChild("group3_2_1", "Group 3 item 2 subitem 1"d);
        tree32.newChild("group3_2_2", "Group 3 item 2 subitem 2"d);
        tree32.newChild("group3_2_3", "Group 3 item 2 subitem 3"d);
        tree32.newChild("group3_2_4", "Group 3 item 2 subitem 4"d);
        tree32.newChild("group3_2_5", "Group 3 item 2 subitem 5"d);
        tree3.newChild("g3_5", "Group 3 item 5"d);
        tree3.newChild("g3_6", "Group 3 item 6"d);
        gbtree.addChild(tree);
        tree.items.selectItem(tree1);
        // test adding new tree items
        HorizontalLayout newTreeItem = new HorizontalLayout();
        newTreeItem.layoutWidth = FILL_PARENT;
        EditLine edNewTreeItem = new EditLine("newTreeItem", "new item"d);
        edNewTreeItem.layoutWidth = FILL_PARENT;
        Button btnAddItem = new Button("btnAddTreeItem", "Add"d);
        Button btnRemoveItem = new Button("btnRemoveTreeItem", "Remove"d);
        newTreeItem.addChild(edNewTreeItem);
        newTreeItem.addChild(btnAddItem);
        newTreeItem.addChild(btnRemoveItem);
        btnAddItem.click = delegate(Widget source) {
            import std.random;
            dstring label = edNewTreeItem.text;
            string id = "item%d".format(uniform(1000000, 9999999, rndGen));
            TreeItem item = tree.items.selectedItem;
            if (item) {
                Log.d("Creating new tree item ", id, " ", label);
                TreeItem newItem = new TreeItem(id, label);
                item.addChild(newItem);
            }
            return true;
        };
        btnRemoveItem.click = delegate(Widget source) {
            TreeItem item = tree.items.selectedItem;
            if (item) {
                Log.d("Removing tree item ", item.id, " ", item.text);
                item.parent.removeChild(item);
            }
            return true;
        };
        gbtree.addChild(newTreeItem);
        line4.addChild(gbtree);

        addChild(line4);
    }
}
