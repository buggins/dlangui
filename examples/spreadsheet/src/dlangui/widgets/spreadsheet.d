module dlangui.widgets.spreadsheet;

import dlangui.core.types;
import dlangui.widgets.styles;
import dlangui.widgets.widget;
import dlangui.widgets.layouts;
import dlangui.widgets.controls;
import dlangui.widgets.tabs;
import dlangui.widgets.editors;
import dlangui.widgets.grid;

/// standard style id for Tab with Up alignment
immutable string STYLE_TAB_SHEET_DOWN = "TAB_SHEET_DOWN";
/// standard style id for button of Tab with Up alignment
immutable string STYLE_TAB_SHEET_DOWN_BUTTON = "TAB_SHEET_DOWN_BUTTON";
/// standard style id for button of Tab with Up alignment
immutable string STYLE_TAB_SHEET_DOWN_BUTTON_TEXT = "TAB_SHEET_DOWN_BUTTON_TEXT";

class SheetTabs : TabControl {
    /// create with ID parameter
    this(string ID = null) {
        super(ID, Align.Bottom);
        setStyles(STYLE_TAB_SHEET_DOWN, STYLE_TAB_SHEET_DOWN_BUTTON, STYLE_TAB_SHEET_DOWN_BUTTON_TEXT);
    }
}

class SheetEditControl : HorizontalLayout {
    EditLine _edPosition;
    EditLine _edText;
    this(string ID = "sheetEdit") {
        _edPosition = new EditLine("edPosition");
        _edText = new EditLine("edText");
        _edPosition.maxWidth = 100;
        _edPosition.minWidth = 100;
        _edText.layoutWidth = FILL_PARENT;
        addChild(_edPosition);
        addChild(_edText);
    }
}

class SpreadSheetWidget : VerticalLayout {

    SheetEditControl _editControl;
    StringGridWidget _grid;
    SheetTabs _tabs;

    this(string ID = "spreadsheet") {
        _editControl = new SheetEditControl();
        _editControl.layoutWidth = FILL_PARENT;
        _grid = new StringGridWidget("grid");
        _grid.layoutWidth = FILL_PARENT;
        _grid.layoutHeight = FILL_PARENT;
        _grid.resize(50, 50);
        _tabs = new SheetTabs();
        _tabs.layoutWidth = FILL_PARENT;
        _tabs.addTab("Sheet1", "Sheet1"d);
        _tabs.addTab("Sheet2", "Sheet2"d);
        _tabs.addTab("Sheet3", "Sheet3"d);
        layoutWidth = FILL_PARENT;
        layoutHeight = FILL_PARENT;
        backgroundColor = 0xFFE0E0E0;
        minHeight = 100;
        addChild(_editControl);
        addChild(_grid);
        addChild(_tabs);
    }
}
