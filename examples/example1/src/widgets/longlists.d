module widgets.longlists;

import dlangui;

class LongListsExample : HorizontalLayout
{
    this(string ID)
    {
        super(ID);
        layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT);

        ListWidget list = new ListWidget("list1", Orientation.Vertical);
        list.layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT);

        StringListAdapter stringList = new StringListAdapter();
        WidgetListAdapter listAdapter = new WidgetListAdapter();
        listAdapter.add((new TextWidget()).text("This is a list of widgets"d).styleId("LIST_ITEM"));
        stringList.add("This is a list of strings from StringListAdapter"d);
        stringList.add("If you type with your keyboard,"d);
        stringList.add("then you can find the"d);
        stringList.add("item in the list"d);
        stringList.add("neat!"d);
        for (int i = 1; i < 1000; i++) {
            dstring label = "List item "d ~ to!dstring(i);
            listAdapter.add((new TextWidget()).text("Widget list - "d ~ label).styleId("LIST_ITEM"));
            stringList.add("Simple string - "d ~ label);
        }
        list.ownAdapter = listAdapter;
        listAdapter.resetItemState(0, State.Enabled);
        listAdapter.resetItemState(5, State.Enabled);
        listAdapter.resetItemState(7, State.Enabled);
        listAdapter.resetItemState(12, State.Enabled);
        assert(list.itemEnabled(5) == false);
        assert(list.itemEnabled(6) == true);
        list.layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT);
        list.selectItem(0);

        addChild(list);

        ListWidget list2 = new StringListWidget("list2");
        list2.ownAdapter = stringList;
        list2.layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT);
        list2.selectItem(0);
        addChild(list2);

        VerticalLayout itemedit = new VerticalLayout();
        itemedit.addChild(new TextWidget(null, "New item text:"d));
        EditLine itemtext = new EditLine(null, "Text for new item"d);
        itemedit.addChild(itemtext);
        Button btn = new Button(null, "Add item"d);
        itemedit.addChild(btn);
        addChild(itemedit);
        btn.click = delegate(Widget src)
        {
            stringList.add(itemtext.text);
            listAdapter.add((new TextWidget()).text(itemtext.text).styleId("LIST_ITEM"));
            return true;
        };
    }
}
