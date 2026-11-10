module widgets.tree;

import dlangui;

class TreeExample : HorizontalLayout
{
    this(string ID)
    {
        super(ID);

        TreeWidget tree = new TreeWidget("TREE1");
        tree.layoutWidth(WRAP_CONTENT).layoutHeight(FILL_PARENT);
        // item marks: overlay icons on item icons
        enum : uint { MarkModified = 1, MarkError = 2, MarkWarning = 4, MarkAdded = 8 }
        tree.items.markDefs = [
            TreeItemMark(MarkModified, "emblem-modified", OverlayCorner.TopRight, 0, "unsaved changes"d, '*'),
            TreeItemMark(MarkError, "emblem-error", OverlayCorner.BottomLeft, 10, "errors"d, '!'),
            TreeItemMark(MarkWarning, "emblem-warning", OverlayCorner.BottomLeft, 5, "warnings"d, '?'),
            TreeItemMark(MarkAdded, "emblem-added", OverlayCorner.BottomRight, 0, "added"d, '+'),
        ];
        TreeItem tree1 = tree.items.newChild("group1", "Group 1"d, "document-open");
        tree1.newChild("g1_1", "Group 1 item 1"d);
        tree1.newChild("g1_2", "Group 1 item 2"d);
        tree1.newChild("g1_3", "Group 1 item 3"d);
        TreeItem tree2 = tree.items.newChild("group2", "Group 2"d, "document-save");
        tree2.newChild("g2_1", "Group 2 item 1"d, "edit-copy").marks = MarkModified;
        tree2.newChild("g2_2", "Group 2 item 2"d, "edit-cut").marks = MarkError | MarkAdded;
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
        // toggle marks of the selected item
        CheckBox[] markBoxes;
        // (a separate function, so that each delegate gets its own flag)
        CheckBox markBox(dstring name, uint flag) {
            CheckBox cb = new CheckBox(null, name);
            cb.checkChange = delegate(Widget w, bool checked) {
                if (TreeItem item = tree.items.selectedItem)
                    item.setMark(flag, checked);
                return true;
            };
            return cb;
        }
        foreach (i, name; ["Modified (top right)"d, "Error (bottom left)"d, "Warning (bottom left, lower priority)"d, "Added (bottom right)"d]) {
            CheckBox cb = markBox(name, 1u << i);
            markBoxes ~= cb;
            treeControlledPanel.addChild(cb);
        }
        addChild(tree);
        addChild(new ResizerWidget());
        addChild(treeControlledPanel);

        tree.selectionChange = delegate(TreeItems source, TreeItem selectedItem, bool activated) {
            dstring label = "Selected item: "d ~ toUTF32(selectedItem.id) ~ (activated ? " selected + activated"d : " selected"d);
            treeItemLabel.text = label;
            foreach (i, cb; markBoxes)
                cb.checked = selectedItem.hasMark(1u << i);
        };

        tree.items.selectItem(tree.items.child(0));
    }
}
