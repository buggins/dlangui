module dlangui.widgets.spreadsheet;

import dlangui.core.types;
import dlangui.widgets.styles;
import dlangui.widgets.widget;
import dlangui.widgets.layouts;
import dlangui.widgets.controls;
import dlangui.widgets.tabs;
import dlangui.widgets.editors;
import dlangui.widgets.grid;
import dlangui.widgets.scrollbar;

import std.algorithm : min;

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
        _moreButton.visibility = Visibility.Gone;
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

class SpreadSheetView : StringGridWidget {
    import std.conv: to;

    this(string ID = null) {
        super(ID);
        layoutWidth = FILL_PARENT;
        layoutHeight = FILL_PARENT;
        defRowHeight = 14;
        defColumnWidth = 80;
        styleId = null;
        backgroundColor = 0xFFFFFF;
        resize(50, 50);
        _colWidths[0] = 50;
        for (int i = 0; i < 26; i++) {
            dchar[1] t;
            t[0] = cast(dchar)('A' + i);
            setColTitle(i, t.dup);
        }
        for (int i = 0; i < 50; i++) {
            dstring label = to!dstring(i + 1);
            setRowTitle(i, label);
        }
    }
}

class SpreadSheetWidget : WidgetGroupDefaultDrawing, OnScrollHandler, CellSelectedHandler, CellActivatedHandler, ViewScrolledHandler {

    SheetEditControl _editControl;
    SheetTabs _tabs;

    ScrollBar _hScroll1;
    ScrollBar _hScroll2;
    ScrollBar _vScroll1;
    ScrollBar _vScroll2;

    SpreadSheetView _viewTopLeft;
    SpreadSheetView _viewTopRight;
    SpreadSheetView _viewBottomLeft;
    SpreadSheetView _viewBottomRight;

    SpreadSheetView[4] _views;
    ScrollBar[4] _scrollbars;

    this(string ID = "spreadsheet") {
        _editControl = new SheetEditControl();
        _editControl.layoutWidth = FILL_PARENT;
        _tabs = new SheetTabs();
        _tabs.layoutWidth = FILL_PARENT;
        _tabs.addTab("Sheet1", "Sheet1"d);
        _tabs.addTab("Sheet2", "Sheet2"d);
        _tabs.addTab("Sheet3", "Sheet3"d);
        layoutWidth = FILL_PARENT;
        layoutHeight = FILL_PARENT;
        backgroundColor = 0xdce2e8;
        minHeight = 100;

        _hScroll1 = new ScrollBar("hscroll1", Orientation.Horizontal);
        _hScroll2 = new ScrollBar("hscroll2", Orientation.Horizontal);
        _vScroll1 = new ScrollBar("vscroll1", Orientation.Vertical);
        _vScroll2 = new ScrollBar("vscroll2", Orientation.Vertical);

        _scrollbars[0] = _hScroll1;
        _scrollbars[1] = _vScroll1;
        _scrollbars[2] = _hScroll2;
        _scrollbars[3] = _vScroll2;

        _viewTopLeft = new SpreadSheetView("sheetViewTopLeft");
        _viewTopRight = new SpreadSheetView("sheetViewTopRight");
        _viewBottomLeft = new SpreadSheetView("sheetViewBottomLeft");
        _viewBottomRight = new SpreadSheetView("sheetViewBottomRight");

        _viewTopRight.setColWidth(0, 0);
        _viewBottomLeft.setRowHeight(0, 0);
        _viewBottomRight.setRowHeight(0, 0);
        _viewBottomRight.setColWidth(0, 0);

        _views[0] = _viewTopLeft;
        _views[1] = _viewTopRight;
        _views[2] = _viewBottomLeft;
        _views[3] = _viewBottomRight;

        _viewTopLeft.hscrollbar = _hScroll1;
        _viewTopLeft.vscrollbar = _vScroll1;
        _viewTopRight.hscrollbar = _hScroll2;
        _viewTopRight.vscrollbar = _vScroll1;
        _viewBottomLeft.hscrollbar = _hScroll1;
        _viewBottomLeft.vscrollbar = _vScroll2;
        _viewBottomRight.hscrollbar = _hScroll2;
        _viewBottomRight.vscrollbar = _vScroll2;

        addChildren([_hScroll1, _vScroll1, _hScroll2, _vScroll2,
            _viewTopLeft, _viewTopRight, _viewBottomLeft, _viewBottomRight,
            _editControl, _tabs
        ]);

        foreach(sb; _scrollbars)
            sb.scrollEvent = this;
        foreach(view; _views) {
            view.cellSelected = this;
            view.cellActivated = this;
            view.viewScrolled = this;
        }
    }

    /// Measure widget according to desired width and height constraints. (Step 1 of two phase layout).
    override void measure(int parentWidth, int parentHeight) {
        if (visibility == Visibility.Gone) {
            return;
        }
        _measuredWidth = parentWidth;
        _measuredHeight = parentHeight;
        foreach(view; _views)
            view.measure(parentWidth, parentHeight);
        foreach(sb; _scrollbars)
            sb.measure(parentWidth, parentHeight);
        _editControl.measure(parentWidth, parentHeight);
        _tabs.measure(parentWidth, parentHeight);
    }
    /// Set widget rectangle to specified value and layout widget contents. (Step 2 of two phase layout).
    override void layout(Rect rc) {
        if (visibility == Visibility.Gone) {
            return;
        }
        _pos = rc;
        _needLayout = false;
        applyMargins(rc);
        applyPadding(rc);
        int editHeight = _editControl.measuredHeight;
        _editControl.layout(Rect(rc.left, rc.top, rc.right, rc.top + editHeight));
        rc.top += editHeight;
        int splitWidth = 4;
        int splitHeight = 4;
        int hscrollHeight = _hScroll1.measuredHeight;
        int vscrollWidth = _vScroll1.measuredWidth;
        int tabsHeight = _tabs.measuredHeight;
        int bottomSize = min(hscrollHeight, tabsHeight);
        int splitx = (rc.width - vscrollWidth - splitWidth) / 2;
        int splity = (rc.height - hscrollHeight - splitHeight) / 2;
        _viewTopLeft.layout(Rect(rc.left, rc.top, rc.left + splitx, rc.top + splity));
        _viewTopRight.layout(Rect(rc.left + splitx + splitWidth, rc.top, rc.right - vscrollWidth, rc.top + splity));
        _viewBottomLeft.layout(Rect(rc.left, rc.top + splity + splitHeight, rc.left + splitx, rc.bottom - bottomSize));
        _viewBottomRight.layout(Rect(rc.left + splitx + splitWidth, rc.top + splity + splitHeight, rc.right - vscrollWidth, rc.bottom - bottomSize));
        int tabsWidth = splitx / 2;
        _tabs.layout(Rect(rc.left, rc.bottom - bottomSize, rc.left + tabsWidth, rc.bottom - bottomSize + tabsHeight));

        _hScroll1.layout(Rect(rc.left + tabsWidth + splitWidth, rc.bottom - hscrollHeight, rc.left + splitx, rc.bottom));
        _hScroll2.layout(Rect(rc.left + splitx + splitWidth, rc.bottom - hscrollHeight, rc.right - vscrollWidth, rc.bottom));
        _vScroll1.layout(Rect(rc.right - vscrollWidth, rc.top, rc.right, rc.top + splity));
        _vScroll2.layout(Rect(rc.right - vscrollWidth, rc.top + splity + splitHeight, rc.right, rc.bottom - bottomSize));
    }

    /// handle scroll event
    override bool onScrollEvent(AbstractSlider source, ScrollEvent event) {
        if (source == _hScroll1) {
            _viewBottomLeft.onHScroll(event);
            return _viewTopLeft.onHScroll(event);
        } else if (source == _hScroll2) {
            _viewBottomRight.onHScroll(event);
            return _viewTopRight.onHScroll(event);
        } else if (source == _vScroll1) {
            _viewTopRight.onVScroll(event);
            return _viewTopLeft.onVScroll(event);
        } else if (source == _vScroll2) {
            _viewBottomRight.onVScroll(event);
            return _viewBottomLeft.onVScroll(event);
        }
        return true;
    }

    /// Callback for handling of cell selection
    void onCellSelected(GridWidgetBase source, int col, int row) {
        foreach(view; _views) {
            if (source != view)
                view.selectCell(col + view.headerCols, row + view.headerRows, false, source, false);
        }
    }

    /// Callback for handling of cell double click or Enter key press
    void onCellActivated(GridWidgetBase source, int col, int row) {
    }

    /// Callback for handling of view scroll (top left visible cell change)
    void onViewScrolled(GridWidgetBase source, int col, int row) {
        if (source == _viewTopLeft) {
            _viewTopRight.scrollTo(-1, row, source, false);
            _viewBottomLeft.scrollTo(col, -1, source, false);
        } else if (source == _viewTopRight) {
            _viewTopLeft.scrollTo(-1, row, source, false);
            _viewBottomRight.scrollTo(col, -1, source, false);
        } else if (source == _viewBottomLeft) {
            _viewTopLeft.scrollTo(col, -1, source, false);
            _viewBottomRight.scrollTo(-1, row, source, false);
        } else if (source == _viewBottomRight) {
            _viewTopRight.scrollTo(col, -1, source, false);
            _viewBottomLeft.scrollTo(-1, row, source, false);
        }
    }

}
