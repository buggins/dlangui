module widgets.grid;

import dlangui;

class GridExample : VerticalLayout
{
    this(string ID)
    {
        super(ID);
        layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT);
        HorizontalLayout gridSettings = new HorizontalLayout();
        StringGridWidget grid = new StringGridWidget("GRID1");

        gridSettings.addChild((new CheckBox("fullColumnOnLeft", "fullColumnOnLeft"d)).checked(grid.fullColumnOnLeft).tooltipText("Extends scroll area to show full column at left when scrolled to rightmost column"d).addOnCheckChangeListener(delegate(Widget, bool checked) { grid.fullColumnOnLeft = checked; return true;}));
        gridSettings.addChild((new CheckBox("fullRowOnTop", "fullRowOnTop"d)).checked(grid.fullRowOnTop).tooltipText("Extends scroll area to show full row at top when scrolled to end row"d).addOnCheckChangeListener(delegate(Widget, bool checked) { grid.fullRowOnTop = checked; return true;}));
        addChild(gridSettings);

        grid.layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT);
        grid.showColHeaders = true;
        grid.showRowHeaders = true;
        grid.resize(30, 50);
        grid.fixedCols = 3;
        grid.fixedRows = 2;
        //grid.rowSelect = true; // testing full row selection
        grid.multiSelect = true;
        grid.selectCell(4, 6, false);
        // create sample grid content
        for (int y = 0; y < grid.rows; y++) {
            for (int x = 0; x < grid.cols; x++) {
                grid.setCellText(x, y, "cell("d ~ to!dstring(x + 1) ~ ","d ~ to!dstring(y + 1) ~ ")"d);
            }
            grid.setRowTitle(y, to!dstring(y + 1));
        }
        for (int x = 0; x < grid.cols; x++) {
            int col = x + 1;
            dstring res;
            int n1 = col / 26;
            int n2 = col % 26;
            if (n1)
                res ~= n1 + 'A';
            res ~= n2 + 'A';
            grid.setColTitle(x, res);
        }
        grid.autoFit();
        addChild(grid);
    }
}
