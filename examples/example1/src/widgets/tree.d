module widgets.tree;

import dlangui;

class TreeExample : HorizontalLayout
{
    this(string ID)
    {
        super(ID);

        TreeWidget tree = new TreeWidget("TREE1");
        tree.layoutWidth(WRAP_CONTENT).layoutHeight(FILL_PARENT);
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

        LinearLayout treeControlledPanel = new VerticalLayout();
        layoutWidth = FILL_PARENT;
        treeControlledPanel.layoutWidth = FILL_PARENT;
        treeControlledPanel.layoutHeight = FILL_PARENT;
        TextWidget treeItemLabel = new TextWidget("TREE_ITEM_DESC");
        treeItemLabel.layoutWidth = FILL_PARENT;
        treeItemLabel.layoutHeight = FILL_PARENT;
        treeItemLabel.alignment = Align.Center;
        treeItemLabel.text = "Sample text"d;
        treeControlledPanel.addChild(treeItemLabel);
        addChild(tree);
        addChild(new ResizerWidget());
        addChild(treeControlledPanel);

        tree.selectionChange = delegate(TreeItems source, TreeItem selectedItem, bool activated) {
            dstring label = "Selected item: "d ~ toUTF32(selectedItem.id) ~ (activated ? " selected + activated"d : " selected"d);
            treeItemLabel.text = label;
        };

        tree.items.selectItem(tree.items.child(0));
    }
}
