// Written in the D programming language.

/**

This module contains implementation of grid widgets


GridWidgetBase - abstract grid widget

StringGridWidget - grid of strings


Synopsis:

----
import dlangui.widgets.grid;

StringGridWidget grid = new StringGridWidget("GRID1");
grid.layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT);
grid.showColHeaders = true;
grid.showRowHeaders = true;
grid.resize(30, 50);
grid.fixedCols = 3;
grid.fixedRows = 2;
//grid.rowSelect = true; // testing full row selection
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


----

Copyright: Vadim Lopatin, 2014
License:   Boost License 1.0
Authors:   Vadim Lopatin, coolreader.org@gmail.com
*/
module dlangui.widgets.grid;

import dlangui.widgets.widget;
import dlangui.widgets.controls;
import dlangui.widgets.scroll;
import std.conv;
import std.algorithm : equal;

/**
 * Data provider for GridWidget.
 */
interface GridAdapter {
    /// number of columns
    @property int cols();
    /// number of rows
    @property int rows();
    /// returns widget to draw cell at (col, row)
    Widget cellWidget(int col, int row);
    /// returns row header widget, null if no header
    Widget rowHeader(int row);
    /// returns column header widget, null if no header
    Widget colHeader(int col);
}

/**
 */
class StringGridAdapter : GridAdapter {
    protected int _cols;
    protected int _rows;
    protected dstring[][] _data;
    protected dstring[] _rowTitles;
    protected dstring[] _colTitles;
    /// number of columns
    @property int cols() { return _cols; }
    /// number of columns
    @property void cols(int v) { resize(v, _rows); }
    /// number of rows
    @property int rows() { return _rows; }
    /// number of columns
    @property void rows(int v) { resize(_cols, v); }

    /// returns row header title
    dstring rowTitle(int row) {
        return _rowTitles[row];
    }
    /// set row header title
    StringGridAdapter setRowTitle(int row, dstring title) {
        _rowTitles[row] = title;
        return this;
    }
    /// returns row header title
    dstring colTitle(int col) {
        return _colTitles[col];
    }
    /// set col header title
    StringGridAdapter setColTitle(int col, dstring title) {
        _colTitles[col] = title;
        return this;
    }
    /// get cell text
    dstring cellText(int col, int row) {
        return _data[row][col];
    }
    /// set cell text
    StringGridAdapter setCellText(int col, int row, dstring text) {
        _data[row][col] = text;
        return this;
    }
    /// set new size
    void resize(int cols, int rows) {
        if (cols == _cols && rows == _rows)
            return;
        _cols = cols;
        _rows = rows;
        _data.length = _rows;
        for (int y = 0; y < _rows; y++)
            _data[y].length = _cols;
        _colTitles.length = _cols;
        _rowTitles.length = _rows;
    }
    /// returns widget to draw cell at (col, row)
    Widget cellWidget(int col, int row) { return null; }
    /// returns row header widget, null if no header
    Widget rowHeader(int row) { return null; }
    /// returns column header widget, null if no header
    Widget colHeader(int col) { return null; }
}

/// grid control action codes
enum GridActions : int {
    /// no action
    None = 0,
    /// move selection up
    Up = 2000,
    /// move selection down
    Down,
    /// move selection left
    Left,
    /// move selection right
    Right,

    /// scroll up, w/o changing selection
    ScrollUp,
    /// scroll down, w/o changing selection
    ScrollDown,
    /// scroll left, w/o changing selection
    ScrollLeft,
    /// scroll right, w/o changing selection
    ScrollRight,

    /// scroll up, w/o changing selection
    ScrollPageUp,
    /// scroll down, w/o changing selection
    ScrollPageDown,
    /// scroll left, w/o changing selection
    ScrollPageLeft,
    /// scroll right, w/o changing selection
    ScrollPageRight,

    /// move cursor one page up
    PageUp,
    /// move cursor one page up with selection
    SelectPageUp,
    /// move cursor one page down
    PageDown,
    /// move cursor one page down with selection
    SelectPageDown,
    /// move cursor to the beginning of page
    PageBegin, 
    /// move cursor to the beginning of page with selection
    SelectPageBegin, 
    /// move cursor to the end of page
    PageEnd,   
    /// move cursor to the end of page with selection
    SelectPageEnd,   
    /// move cursor to the beginning of line
    LineBegin,
    /// move cursor to the beginning of line with selection
    SelectLineBegin,
    /// move cursor to the end of line
    LineEnd,
    /// move cursor to the end of line with selection
    SelectLineEnd,
    /// move cursor to the beginning of document
    DocumentBegin,
    /// move cursor to the beginning of document with selection
    SelectDocumentBegin,
    /// move cursor to the end of document
    DocumentEnd,
    /// move cursor to the end of document with selection
    SelectDocumentEnd,
    /// Enter key pressed on cell
    ActivateCell,
}

/// Adapter for custom drawing of some cells in grid widgets
interface CustomGridCellAdapter {
    /// return true for custom drawn cell
    bool isCustomCell(int col, int row);
    /// return cell size
    Point measureCell(int col, int row);
    /// draw data cell content
    void drawCell(DrawBuf buf, Rect rc, int col, int row);
}

interface GridModelAdapter {
    @property int fixedCols();
    @property int fixedRows();
    @property void fixedCols(int value);
    @property void fixedRows(int value);
}

/// Callback for handling of cell selection
interface CellSelectedHandler {
    void onCellSelected(GridWidgetBase source, int col, int row);
}

/// Callback for handling of cell double click or Enter key press
interface CellActivatedHandler {
    void onCellActivated(GridWidgetBase source, int col, int row);
}

/// Callback for handling of view scroll (top left visible cell change)
interface ViewScrolledHandler {
    void onViewScrolled(GridWidgetBase source, int col, int row);
}

/// Abstract grid widget
class GridWidgetBase : ScrollWidgetBase, GridModelAdapter {
    /// Callback to handle selection change
    Listener!CellSelectedHandler cellSelected;

    /// Callback to handle cell double click
    Listener!CellActivatedHandler cellActivated;

    /// Callback for handling of view scroll (top left visible cell change)
    Listener!ViewScrolledHandler viewScrolled;

    protected CustomGridCellAdapter _customCellAdapter;

    /// Get adapter to override drawing of some particular cells
    @property CustomGridCellAdapter customCellAdapter() { return _customCellAdapter; }
    /// Set adapter to override drawing of some particular cells
    @property GridWidgetBase customCellAdapter(CustomGridCellAdapter adapter) { _customCellAdapter = adapter; return this; }

    protected GridModelAdapter _gridModelAdapter;
    /// Get adapter to hold grid model data
    @property GridModelAdapter gridModelAdapter() { return _gridModelAdapter; }
    /// Set adapter to hold grid model data
    @property GridWidgetBase gridModelAdapter(GridModelAdapter adapter) { _gridModelAdapter = adapter; return this; }

    /// column count (including header columns and fixed columns)
    protected int _cols;
    /// row count (including header rows and fixed rows)
    protected int _rows;
    /// column widths
    protected int[] _colWidths;
    /// row heights
    protected int[] _rowHeights;
    /// when true, shows col headers row
    protected bool _showColHeaders;
    /// when true, shows row headers column
    protected bool _showRowHeaders;
    /// number of header rows (e.g. like col name A, B, C... in excel; 0 for no header row)
    protected int _headerRows;
    /// number of header columns (e.g. like row number in excel; 0 for no header column)
    protected int _headerCols;
    /// number of fixed (non-scrollable) columns
    protected int _fixedCols;
    /// number of fixed (non-scrollable) rows
    protected int _fixedRows;
    /// column scroll offset, relative to last fixed col; 0 = not scrolled
    protected int _scrollCol; 
    /// row scroll offset, relative to last fixed row; 0 = not scrolled
    protected int _scrollRow;
    /// selected cell column
    protected int _col;
    /// selected cell row
    protected int _row;
    /// when true, allows to select only whole row
    protected bool _rowSelect;
    /// default column width - for newly added columns
    protected int _defColumnWidth;
    /// default row height - for newly added rows
    protected int _defRowHeight;

    // properties

    /// selected column
    @property int col() { return _col - _headerCols; }
    /// selected row
    @property int row() { return _row - _headerRows; }
    /// column count
    @property int cols() { return _cols - _headerCols; }
    /// set column count
    @property GridWidgetBase cols(int c) { resize(c, rows); return this; }
    /// row count
    @property int rows() { return _rows - _headerRows; }
    /// set row count
    @property GridWidgetBase rows(int r) { resize(cols, r); return this; }

    protected uint _selectionColor = 0x804040FF;
    protected uint _selectionColorRowSelect = 0xC0A0B0FF;
    protected uint _fixedCellBackgroundColor = 0xC0E0E0E0;
    protected uint _cellBorderColor = 0xC0C0C0C0;
    protected uint _cellHeaderBorderColor = 0xC0202020;
    protected uint _cellHeaderBackgroundColor = 0xC0909090;
    protected uint _cellHeaderSelectedBackgroundColor = 0x80FFC040;

    /// row header column count
    @property int headerCols() { return _headerCols; }
    @property GridWidgetBase headerCols(int c) { 
        _headerCols = c; 
        invalidate(); 
        return this; 
    }
    /// col header row count
    @property int headerRows() { return _headerRows; }
    @property GridWidgetBase headerRows(int r) { 
        _headerRows = r; 
        invalidate(); 
        return this; 
    }

    /// fixed (non-scrollable) data column count
    @property int fixedCols() { return _gridModelAdapter is null ? _fixedCols : _gridModelAdapter.fixedCols; }
    @property void fixedCols(int c) { 
        if (_gridModelAdapter is null)
            _fixedCols = c;
        else
            _gridModelAdapter.fixedCols = c;
        invalidate(); 
    }
    /// fixed (non-scrollable) data row count
    @property int fixedRows() { return _gridModelAdapter is null ? _fixedRows : _gridModelAdapter.fixedCols; }
    @property void fixedRows(int r) {
        if (_gridModelAdapter is null)
            _fixedRows = r; 
        else
            _gridModelAdapter.fixedCols = r;
        invalidate(); 
    }

    /// default column width - for newly added columns
    @property int defColumnWidth() {
        return _defColumnWidth;
    }
    @property GridWidgetBase defColumnWidth(int v) {
        _defColumnWidth = v;
        return this;
    }
    /// default row height - for newly added rows
    @property int defRowHeight() {
        return _defRowHeight;
    }
    @property GridWidgetBase defRowHeight(int v) {
        _defRowHeight = v;
        return this;
    }

    /// when true, allows only select the whole row
    @property bool rowSelect() {
        return _rowSelect;
    }
    @property GridWidgetBase rowSelect(bool flg) {
        _rowSelect = flg;
        invalidate();
        return this;
    }

    /// set bool property value, for ML loaders
    mixin(generatePropertySettersMethodOverride("setBoolProperty", "bool",
          "showColHeaders", "showColHeaders", "rowSelect"));

    /// set int property value, for ML loaders
    mixin(generatePropertySettersMethodOverride("setIntProperty", "int",
          "headerCols", "headerRows", "fixedCols", "fixedRows", "cols", "rows", "defColumnWidth", "defRowHeight"));

    /// flag to enable column headers
    @property bool showColHeaders() {
        return _showColHeaders;
    }

    @property GridWidgetBase showColHeaders(bool show) {
        if (_showColHeaders != show) {
            _showColHeaders = show;
            for (int i = 0; i < _headerRows; i++)
                autoFitRowHeight(i);
            invalidate();
        }
        return this;
    }

    /// flag to enable row headers
    @property bool showRowHeaders() {
        return _showRowHeaders;
    }

    @property GridWidgetBase showRowHeaders(bool show) {
        if (_showRowHeaders != show) {
            _showRowHeaders = show;
            for (int i = 0; i < _headerCols; i++)
                autoFitColumnWidth(i);
            invalidate();
        }
        return this;
    }

    /// set new size
    void resize(int c, int r) {
        if (c == cols && r == rows)
            return;
        _colWidths.length = c + _headerCols;
        for (int i = _cols; i < c + _headerCols; i++) {
            _colWidths[i] = _defColumnWidth;
        }
        _rowHeights.length = r + _headerRows;
        for (int i = _rows; i < r + _headerRows; i++) {
            _rowHeights[i] = _defRowHeight;
        }
        _cols = c + _headerCols;
        _rows = r + _headerRows;
    }


    /// returns column width (index includes col/row headers, if any); returns 0 for columns hidden by scroll at the left
    int colWidth(int x) {
        if (x >= _headerCols + fixedCols && x < _headerCols + fixedCols + _scrollCol)
            return 0;
        return _colWidths[x];
    }

    void setColWidth(int x, int w) {
        _colWidths[x] = w;
    }

    /// returns row height (index includes col/row headers, if any); returns 0 for riws hidden by scroll at the top
    int rowHeight(int y) {
        if (y >= _headerRows + fixedRows && y < _headerRows + fixedRows + _scrollRow)
            return 0;
        return _rowHeights[y];
    }

    void setRowHeight(int y, int w) {
        _rowHeights[y] = w;
    }

    /// returns cell rectangle relative to client area; row 0 is col headers row; col 0 is row headers column
    Rect cellRect(int x, int y) {
        Rect rc;
        int xx = 0;
        for (int i = 0; i <= x; i++) {
            if (i == x)
                rc.left = xx;
            xx += colWidth(i);
            if (i == x) {
                rc.right = xx;
                break;
            }
        }
        int yy = 0;
        for (int i = 0; i <= y; i++) {
            if (i == y)
                rc.top = yy;
            yy += rowHeight(i);
            if (i == y) {
                rc.bottom = yy;
                break;
            }
        }
        return rc;
    }

    /// converts client rect relative coordinates to cell coordinates
    bool pointToCell(int x, int y, ref int col, ref int row, ref Rect cellRect) {
        col = row = -1;
        cellRect = Rect();
        Rect rc;
        int xx = 0;
        for (int i = 0; i < _cols; i++) {
            rc.left = xx;
            xx += colWidth(i);
            rc.right = xx;
            if (rc.left < rc.right && x >= rc.left && x < rc.right) {
                col = i;
                break;
            }
            if (xx > x)
                break;
        }
        int yy = 0;
        for (int i = 0; i < _rows; i++) {
            rc.top = yy;
            yy += rowHeight(i);
            rc.bottom = yy;

            if (rc.top < rc.bottom && y >= rc.top && y < rc.bottom) {
                row = i;
                break;
            }
            if (yy > y)
                break;
        }
        if (col >= 0 && row >= 0) {
            cellRect = rc;
            return true;
        }
        return false;
    }

    /// update scrollbar positions
    override protected void updateScrollBars() {
        calcScrollableAreaPos();
        super.updateScrollBars();
    }

    /// column by X, ignoring scroll position
    protected int colByAbsoluteX(int x) {
        int xx = 0;
        for (int i = 0; i < _cols; i++) {
            int w = _colWidths[i];
            if (x < xx + w || i == _cols - 1)
                return i;
            xx += w;
        }
        return 0;
    }

    /// row by Y, ignoring scroll position
    protected int rowByAbsoluteY(int y) {
        int yy = 0;
        for (int i = 0; i < _rows; i++) {
            int w = _rowHeights[i];
            if (y < yy + w || i == _rows - 1)
                return i;
            yy += w;
        }
        return 0;
    }

    /// move scroll position horizontally by dx, and vertically by dy; returns true if scrolled
    bool scrollBy(int dx, int dy) {
        return scrollTo(_headerCols + fixedCols + _scrollCol + dx, _headerRows + fixedRows + _scrollRow + dy);
    }

    /// set scroll position to show specified cell as top left in scrollable area; col or row -1 value means no change
    bool scrollTo(int col, int row, GridWidgetBase source = null, bool doNotify = true) {
        int oldx = _scrollCol;
        int oldy = _scrollRow;
        int newScrollCol = col == -1 ? _scrollCol : col - _headerCols - fixedCols;
        int newScrollRow = row == -1 ? _scrollRow : row - _headerRows - fixedRows;
        if (newScrollCol > _maxScrollCol)
            newScrollCol = _maxScrollCol;
        if (newScrollCol < 0)
            newScrollCol = 0;
        if (newScrollRow > _maxScrollRow)
            newScrollRow = _maxScrollRow;
        if (newScrollRow < 0)
            newScrollRow = 0;
        //bool changed = false;
        if (newScrollCol >= 0 && newScrollCol + _headerCols + fixedCols < _cols) {
            if (_scrollCol != newScrollCol) {
                _scrollCol = newScrollCol;
                //changed = true;
            }
        }
        if (newScrollRow >= 0 && newScrollRow + _headerRows + fixedRows < _rows) {
            if (_scrollRow != newScrollRow) {
                _scrollRow = newScrollRow;
                //changed = true;
            }
        }
        //if (changed)
        updateScrollBars();
        invalidate();
        bool changed = oldx != _scrollCol || oldy != _scrollRow;
        if (doNotify && changed && viewScrolled.assigned) {
            if (source is null)
                source = this;
            viewScrolled(source, col, row);
        }
        return changed;
    }

    /// process horizontal scrollbar event
    override bool onHScroll(ScrollEvent event) {
        if (event.action == ScrollAction.SliderMoved || event.action == ScrollAction.SliderReleased) {
            int col = colByAbsoluteX(event.position + _fullScrollableArea.left);
            scrollTo(col, _scrollRow + _headerRows + fixedRows);
        } else if (event.action == ScrollAction.PageUp) {
            dispatchAction(new Action(GridActions.ScrollPageLeft));
        } else if (event.action == ScrollAction.PageDown) {
            dispatchAction(new Action(GridActions.ScrollPageRight));
        } else if (event.action == ScrollAction.LineUp) {
            dispatchAction(new Action(GridActions.ScrollLeft));
        } else if (event.action == ScrollAction.LineDown) {
            dispatchAction(new Action(GridActions.ScrollRight));
        }
        return true;
    }

    /// process vertical scrollbar event
    override bool onVScroll(ScrollEvent event) {
        if (event.action == ScrollAction.SliderMoved || event.action == ScrollAction.SliderReleased) {
            int row = rowByAbsoluteY(event.position + _fullScrollableArea.top);
            scrollTo(_scrollCol + _headerCols + fixedCols, row);
        } else if (event.action == ScrollAction.PageUp) {
            dispatchAction(new Action(GridActions.ScrollPageUp));
        } else if (event.action == ScrollAction.PageDown) {
            dispatchAction(new Action(GridActions.ScrollPageDown));
        } else if (event.action == ScrollAction.LineUp) {
            dispatchAction(new Action(GridActions.ScrollUp));
        } else if (event.action == ScrollAction.LineDown) {
            dispatchAction(new Action(GridActions.ScrollDown));
        }
        return true;
    }

    /// ensure that cell is visible (scroll if necessary)
    void makeCellVisible(int col, int row) {
        bool scrolled = false;
        Rect rc = cellRect(col, row);
        if (col >= _headerCols + fixedCols && col < _headerCols + fixedCols + _scrollCol) {
            // scroll to the left
            _scrollCol = col - _headerCols - fixedCols;
            scrolled = true;
        } else {
            while (rc.right > _clientRect.width && _scrollCol < _cols - fixedCols - _headerCols - 1) {
                if (_scrollCol == col - _headerCols - fixedCols)
                    break;
                _scrollCol++;
                rc = cellRect(col, row);
                scrolled = true;
            }
        }
        if (row >= _headerRows + fixedRows && row < _headerRows + fixedRows + _scrollRow) {
            // scroll to the left
            _scrollRow = row - _headerRows - fixedRows;
            scrolled = true;
        } else {
            while (rc.bottom > _clientRect.height && _scrollRow < _rows - fixedRows - _headerRows - 1) {
                if (_scrollRow == row - _headerRows - fixedRows)
                    break;
                _scrollRow++;
                rc = cellRect(col, row);
                scrolled = true;
            }
        }
        if (scrolled) {
            updateScrollBars();
            invalidate();
            if (viewScrolled.assigned) {
                viewScrolled(this, _scrollCol + _headerCols + fixedCols, _scrollRow + _headerRows + fixedRows);
            }
        }
    }

    /// move selection to specified cell
    bool selectCell(int col, int row, bool makeVisible = true, GridWidgetBase source = null, bool needNotification = true) {
        if (source is null)
            source = this;
        if (_col == col && _row == row)
            return false; // same position
        if (col < _headerCols || row < _headerRows || col >= _cols || row >= _rows)
            return false; // out of range
        _col = col;
        _row = row;
        invalidate();
        calcScrollableAreaPos();
        if (makeVisible)
            makeCellVisible(_col, _row);
        if (needNotification && cellSelected.assigned)
            cellSelected(source, _col - _headerCols, _row - _headerRows);
        return true;
    }

    /// Select cell and call onCellActivated handler
    bool activateCell(int col, int row) {
        if (_col != col || _row != row) {
            selectCell(col, row, true);
        }
        if (cellActivated.assigned)
            cellActivated(this, this.col, this.row);
        return true;
    }

    /// handle mouse wheel events
    override bool onMouseEvent(MouseEvent event) {
        if (visibility != Visibility.Visible)
            return false;
        int c, r; // col, row
        Rect rc;
        bool cellFound = false;
        bool normalCell = false;
        // convert coordinates
        if (event.action == MouseAction.ButtonUp || event.action == MouseAction.ButtonDown || event.action == MouseAction.Move) {
            int x = event.x;
            int y = event.y;
            x -= _clientRect.left;
            y -= _clientRect.top;
            cellFound = pointToCell(x, y, c, r, rc);
            normalCell = c >= _headerCols && r >= _headerRows;
        }
        if (event.action == MouseAction.ButtonDown && event.button == MouseButton.Left) {
            if (canFocus && !focused)
                setFocus();
            if (cellFound && normalCell) {
                if (c == _col && r == _row && event.doubleClick) {
                    activateCell(c, r);
                } else {
                    selectCell(c, r);
                }
            }
            return true;
        }
        if (event.action == MouseAction.Move && (event.flags & MouseFlag.LButton)) {
            // TODO: selection
            if (cellFound && normalCell) {
                selectCell(c, r);
            }
            return true;
        }
        if (event.action == MouseAction.Wheel) {
            if (event.flags & MouseFlag.Shift)
                scrollBy(-event.wheelDelta, 0);
            else
                scrollBy(0, -event.wheelDelta);
            return true;
        }
        return super.onMouseEvent(event);
    }


    /// calculate scrollable area info
    protected void calcScrollableAreaPos() {
        _maxScrollCol = _maxScrollRow = 0;
        _fullyVisibleCells.left = _headerCols + fixedCols + _scrollCol;
        _fullyVisibleCells.top = _headerRows + fixedRows + _scrollRow;
        Rect rc;
        int xx = 0;
        for (int i = 0; i < _cols && xx < _clientRect.width; i++) {
            if (i == _fullyVisibleCells.left) {
                _fullyVisibleCellsRect.left = _fullyVisibleCellsRect.right = xx;
            }
            int w = colWidth(i);
            if (i >= _fullyVisibleCells.left && xx + w <= _clientRect.width) {
                _fullyVisibleCellsRect.right = xx + w;
                _fullyVisibleCells.right = i;
            }
            xx += w;
        }
        int yy = 0;
        for (int i = 0; i < _rows && yy < _clientRect.height; i++) {
            if (i == _fullyVisibleCells.top)
                _fullyVisibleCellsRect.top = _fullyVisibleCellsRect.bottom = yy;
            int w = rowHeight(i);
            if (i >= _fullyVisibleCells.top && yy + w <= _clientRect.height) {
                _fullyVisibleCellsRect.bottom = yy + w;
                _fullyVisibleCells.bottom = i;
            }
            yy += w;
        }

        int maxVisibleScrollWidth = _clientRect.width - _fullyVisibleCellsRect.left;
        int maxVisibleScrollHeight = _clientRect.height - _fullyVisibleCellsRect.top;
        if (maxVisibleScrollWidth < 0)
            maxVisibleScrollWidth = 0;
        if (maxVisibleScrollHeight < 0)
            maxVisibleScrollHeight = 0;


        // calc scroll area in pixels
        xx = 0;
        for (int i = 0; i < _cols; i++) {
            if (i == _headerCols + fixedCols) {
                _fullScrollableArea.left = xx;
            }
            if (i == _fullyVisibleCells.left) {
                _visibleScrollableArea.left = xx;
            }
            int w = _colWidths[i];
            xx += w;
            if (i >= _headerCols + fixedCols) {
                _fullScrollableArea.right = xx;
            }
            if (i >= _fullyVisibleCells.left) {
                _visibleScrollableArea.right = xx;
            }
        }
        xx = 0;
        for (int i = _cols - 1; i >= _headerCols + fixedCols; i--) {
            int w = _colWidths[i];
            if (xx + w > maxVisibleScrollWidth) {
                _fullScrollableArea.right += maxVisibleScrollWidth - xx;
                break;
            }
            _maxScrollCol = i - _headerCols - fixedCols;
            xx += w;
        }
        yy = 0;
        for (int i = 0; i < _rows; i++) {
            if (i == _headerRows + fixedRows) {
                _fullScrollableArea.top = yy;
            }
            if (i == _fullyVisibleCells.top) {
                _visibleScrollableArea.top = yy;
            }
            int w = _rowHeights[i];
            yy += w;
            if (i >= _headerRows + fixedRows) {
                _fullScrollableArea.bottom = yy;
            }
            if (i >= _fullyVisibleCells.top) {
                _visibleScrollableArea.bottom = yy;
            }
        }
        yy = 0;
        for (int i = _rows - 1; i >= _headerRows + fixedRows; i--) {
            int w = _rowHeights[i];
            if (yy + w > maxVisibleScrollHeight) {
                _fullScrollableArea.bottom += maxVisibleScrollHeight - yy;
                break;
            }
            _maxScrollRow = i - _headerRows - fixedRows;
            yy += w;
        }
        // crop scroll area by client rect
        //if (visibleScrollableArea.width > maxVisibleScrollWidth)
        _visibleScrollableArea.right = _visibleScrollableArea.left + maxVisibleScrollWidth;
        //if (visibleScrollableArea.height > maxVisibleScrollHeight)
        _visibleScrollableArea.bottom = _visibleScrollableArea.top + maxVisibleScrollHeight;
    }

    protected int _maxScrollCol;
    protected int _maxScrollRow;
    protected Rect _fullyVisibleCells;
    protected Rect _fullyVisibleCellsRect;

    override protected bool handleAction(const Action a) {
        calcScrollableAreaPos();
        int actionId = a.id;
        if (_rowSelect) {
            switch(actionId) with(GridActions)
            {
                case Left:
                    actionId = GridActions.ScrollLeft;
                    break;
                case Right:
                    actionId = GridActions.ScrollRight;
                    break;
                //case LineBegin:
                //    actionId = GridActions.ScrollPageLeft;
                //    break;
                //case LineEnd:
                //    actionId = GridActions.ScrollPageRight;
                //    break;
                default:
                    break;
            }
        }

        switch (actionId) with(GridActions)
        {
            case ActivateCell:
                if (cellActivated.assigned) {
                    cellActivated(this, col, row);
                    return true;
                }
                return false;
            case ScrollLeft:
                scrollBy(-1, 0);
                return true;
            case Left:
                selectCell(_col - 1, _row);
                return true;
            case ScrollRight:
                scrollBy(1, 0);
                return true;
            case Right:
                selectCell(_col + 1, _row);
                return true;
            case ScrollUp:
                scrollBy(0, -1);
                return true;
            case Up:
                selectCell(_col, _row - 1);
                return true;
            case ScrollDown:
                if (_fullyVisibleCells.bottom < _rows - 1)
                    scrollBy(0, 1);
                return true;
            case Down:
                selectCell(_col, _row + 1);
                return true;
            case ScrollPageLeft:
                // scroll left cell by cell
                int prevCol = _headerCols + fixedCols + _scrollCol;
                while (_scrollCol > 0) {
                    scrollBy(-1, 0);
                    if (_fullyVisibleCells.right <= prevCol)
                        break;
                }
                return true;
            case ScrollPageRight:
                int prevCol = _fullyVisibleCells.right;
                while (_headerCols + fixedCols + _scrollCol < prevCol) {
                    if (!scrollBy(1, 0))
                        break;
                }
                return true;
            case ScrollPageUp:
                // scroll up line by line
                int prevRow = _headerRows + fixedRows + _scrollRow;
                while (_scrollRow > 0) {
                    scrollBy(0, -1);
                    if (_fullyVisibleCells.bottom <= prevRow)
                        break;
                }
                return true;
            case ScrollPageDown:
                int prevRow = _fullyVisibleCells.bottom;
                while (_headerRows + fixedRows + _scrollRow < prevRow) {
                    if (!scrollBy(0, 1))
                        break;
                }
                return true;
            case LineBegin:
                if (_scrollCol > 0 && _col > _headerCols + fixedCols + _scrollCol && !_rowSelect)
                    selectCell(_headerCols + fixedCols + _scrollCol, _row);
                else {
                    if (_scrollCol > 0) {
                        _scrollCol = 0;
                        updateScrollBars();
                        invalidate();
                    }
                    selectCell(_headerCols, _row);
                }
                return true;
            case LineEnd:
                selectCell(_cols - 1, _row);
                return true;
            case DocumentBegin:
                if (_scrollRow > 0) {
                    _scrollRow = 0;
                    updateScrollBars();
                    invalidate();
                }
                selectCell(_col, _headerRows);
                return true;
            case DocumentEnd:
                selectCell(_col, _rows - 1);
                return true;
            case PageBegin:
                if (_scrollRow > 0)
                    selectCell(_col, _headerRows + fixedRows + _scrollRow);
                else
                    selectCell(_col, _headerRows);
                return true;
            case PageEnd:
                int found = -1;
                for (int i = fixedRows; i < _rows; i++) {
                    Rect rc = cellRect(_col, i);
                    if (rc.bottom <= _clientRect.height)
                        found = i;
                    else
                        break;
                }
                if (found >= 0)
                    selectCell(_col, found);
                return true;
            case PageUp:
                if (_row > _fullyVisibleCells.top) {
                    // not at top scrollable cell
                    selectCell(_col, _fullyVisibleCells.top);
                } else {
                    // at top of scrollable area
                    if (_scrollRow > 0) {
                        // scroll up line by line
                        int prevRow = _row;
                        for (int i = prevRow - 1; i >= _headerRows; i--) {
                            selectCell(_col, i);
                            if (_fullyVisibleCells.bottom <= prevRow)
                                break;
                        }
                    } else {
                        // scrolled to top - move upper cell
                        selectCell(_col, _headerRows);
                    }
                }
                return true;
            case PageDown: 
                if (_row < _rows) {
                    if (_row < _fullyVisibleCells.bottom) {
                        // not at top scrollable cell
                        selectCell(_col, _fullyVisibleCells.bottom);
                    } else {
                        // scroll down
                        int prevRow = _row;
                        for (int i = prevRow + 1; i < _rows; i++) {
                            selectCell(_col, i);
                            calcScrollableAreaPos();
                            if (_fullyVisibleCells.top >= prevRow)
                                break;
                        }
                    }
                }
                return true;
            default:
                return super.handleAction(a);
        }
    }

    /// calculate full content size in pixels
    override Point fullContentSize() {
        Point sz;
        for (int i = 0; i < _cols; i++)
            sz.x += _colWidths[i];
        for (int i = 0; i < _rows; i++)
            sz.y += _rowHeights[i];
        return sz;
    }

    override protected void drawClient(DrawBuf buf) {
        auto saver = ClipRectSaver(buf, _clientRect, 0);
        //buf.fillRect(_clientRect, 0x80A08080);
        Rect rc;
        for (int phase = 0; phase < 2; phase++) {
            int yy = 0;
            for (int y = 0; y < _rows; y++) {
                int rh = rowHeight(y);
                rc.top = yy;
                rc.bottom = yy + rh;
                if (rh == 0)
                    continue;
                if (yy > _clientRect.height)
                    break;
                yy += rh;
                int xx = 0;
                for (int x = 0; x < _cols; x++) {
                    int cw = colWidth(x);
                    rc.left = xx;
                    rc.right = xx + cw;
                    if (cw == 0)
                        continue;
                    if (xx > _clientRect.width)
                        break;
                    xx += cw;
                    // draw cell
                    Rect cellRect = rc;
                    cellRect.moveBy(_clientRect.left, _clientRect.top);
                    auto cellSaver = ClipRectSaver(buf, cellRect, 0);
                    bool isHeader = x < _headerCols || y < _headerRows;
                    if (phase == 0) {
                        if (isHeader)
                            drawHeaderCellBackground(buf, buf.clipRect, x - _headerCols, y - _headerRows);
                        else
                            drawCellBackground(buf, buf.clipRect, x - _headerCols, y - _headerRows);
                    } else {
                        if (isHeader)
                            drawHeaderCell(buf, buf.clipRect, x - _headerCols, y - _headerRows);
                        else
                            drawCell(buf, buf.clipRect, x - _headerCols, y - _headerRows);
                    }
                }
            }
        }
    }

    /// draw data cell content
    protected void drawCell(DrawBuf buf, Rect rc, int col, int row) {
        // override it
    }

    /// draw header cell content
    protected void drawHeaderCell(DrawBuf buf, Rect rc, int col, int row) {
        // override it
    }

    /// draw data cell background
    protected void drawCellBackground(DrawBuf buf, Rect rc, int col, int row) {
        // override it
    }

    /// draw header cell background
    protected void drawHeaderCellBackground(DrawBuf buf, Rect rc, int col, int row) {
        // override it
    }

    protected Point measureCell(int x, int y) {
        // override it!
        return Point(80, 20);
    }

    protected int measureColWidth(int x) {
        int m = 0;
        for (int i = 0; i < _rows; i++) {
            Point sz = measureCell(x - _headerCols, i - _headerRows);
            if (m < sz.x)
                m = sz.x;
        }
        if (m < 10)
            m = 10; // TODO: use min size
        return m;
    }

    protected int measureRowHeight(int y) {
        int m = 0;
        for (int i = 0; i < _cols; i++) {
            Point sz = measureCell(i - _headerCols, y - _headerRows);
            if (m < sz.y)
                m = sz.y;
        }
        if (m < 12)
            m = 12; // TODO: use min size
        return m;
    }

    void autoFitColumnWidth(int i) {
        _colWidths[i] = (i < _headerCols && !_showRowHeaders) ? 0 : measureColWidth(i) + 5;
    }

    /// extend specified column width to fit client area if grid width
    void fillColumnWidth(int colIndex) {
        int w = _clientRect.width;
        int totalw = 0;
        for (int i = 0; i < _cols; i++)
            totalw += _colWidths[i];
        if (w > totalw)
            _colWidths[colIndex + _headerCols] += w - totalw;
        invalidate();
    }

    void autoFitColumnWidths() {
        for (int i = 0; i < _cols; i++)
            autoFitColumnWidth(i);
        invalidate();
    }

    void autoFitRowHeight(int i) {
        _rowHeights[i] = (i < _headerRows && !_showColHeaders) ? 0 : measureRowHeight(i) + 2;
    }

    void autoFitRowHeights() {
        for (int i = 0; i < _rows; i++)
            autoFitRowHeight(i);
    }

    void autoFit() {
        autoFitColumnWidths();
        autoFitRowHeights();
    }

    this(string ID = null, ScrollBarMode hscrollbarMode = ScrollBarMode.Visible, ScrollBarMode vscrollbarMode = ScrollBarMode.Visible) {
        super(ID, hscrollbarMode, vscrollbarMode);
        _headerCols = 1;
        _headerRows = 1;
        _defRowHeight = pointsToPixels(16);
        _defColumnWidth = 100;
        _showColHeaders = true;
        _showRowHeaders = true;
        acceleratorMap.add( [
            new Action(GridActions.Up, KeyCode.UP, 0),
            new Action(GridActions.Down, KeyCode.DOWN, 0),
            new Action(GridActions.Left, KeyCode.LEFT, 0),
            new Action(GridActions.Right, KeyCode.RIGHT, 0),
            new Action(GridActions.LineBegin, KeyCode.HOME, 0),
            new Action(GridActions.LineEnd, KeyCode.END, 0),
            new Action(GridActions.PageUp, KeyCode.PAGEUP, 0),
            new Action(GridActions.PageDown, KeyCode.PAGEDOWN, 0),
            new Action(GridActions.PageBegin, KeyCode.PAGEUP, KeyFlag.Control),
            new Action(GridActions.PageEnd, KeyCode.PAGEDOWN, KeyFlag.Control),
            new Action(GridActions.DocumentBegin, KeyCode.HOME, KeyFlag.Control),
            new Action(GridActions.DocumentEnd, KeyCode.END, KeyFlag.Control),
            new Action(GridActions.ActivateCell, KeyCode.RETURN, 0),
        ]);
        focusable = true;
    }
}

class StringGridWidgetBase : GridWidgetBase {
    this(string ID = null) {
        super(ID);
    }
    /// get cell text
    abstract dstring cellText(int col, int row);
    /// set cell text
    abstract StringGridWidgetBase setCellText(int col, int row, dstring text);
    /// returns row header title
    abstract dstring rowTitle(int row);
    /// set row header title
    abstract StringGridWidgetBase setRowTitle(int row, dstring title);
    /// returns row header title
    abstract dstring colTitle(int col);
    /// set col header title
    abstract StringGridWidgetBase setColTitle(int col, dstring title);

    ///// selected column
    //@property override int col() { return _col - _headerCols; }
    ///// selected row
    //@property override int row() { return _row - _headerRows; }
    ///// column count
    //@property override int cols() { return _cols - _headerCols; }
    ///// set column count
    //@property override GridWidgetBase cols(int c) { resize(c, rows); return this; }
    ///// row count
    //@property override int rows() { return _rows - _headerRows; }
    ///// set row count
    //@property override GridWidgetBase rows(int r) { resize(cols, r); return this; }
    //
    ///// set new size
    //override void resize(int cols, int rows) {
    //    super.resize(cols + _headerCols, rows + _headerRows);
    //}

}

/**
 * Grid view with string data shown. All rows are of the same height
 */
class StringGridWidget : StringGridWidgetBase {

    protected dstring[][] _data;
    protected dstring[] _rowTitles;
    protected dstring[] _colTitles;

    /// empty parameter list constructor - for usage by factory
    this() {
        this(null);
    }
    /// create with ID parameter
    this(string ID) {
        super(ID);
        styleId = STYLE_EDIT_BOX;
        onThemeChanged();
    }

    /// get cell text
    override dstring cellText(int col, int row) {
        if (col >= 0 && col < cols && row >= 0 && row < rows)
            return _data[row][col];
        return ""d;
    }

    /// set cell text
    override StringGridWidgetBase setCellText(int col, int row, dstring text) {
        if (col >= 0 && col < cols && row >= 0 && row < rows)
            _data[row][col] = text;
        return this;
    }

    /// set new size
    override void resize(int c, int r) {
        if (c == cols && r == rows)
            return;
        int oldcols = cols;
        int oldrows = rows;
        super.resize(c, r);
        _data.length = r;
        for (int y = 0; y < r; y++)
            _data[y].length = c;
        _colTitles.length = c;
        _rowTitles.length = r;
    }

    /// returns row header title
    override dstring rowTitle(int row) {
        return _rowTitles[row];
    }
    /// set row header title
    override StringGridWidgetBase setRowTitle(int row, dstring title) {
        _rowTitles[row] = title;
        return this;
    }

    /// returns row header title
    override dstring colTitle(int col) {
        return _colTitles[col];
    }

    /// set col header title
    override StringGridWidgetBase setColTitle(int col, dstring title) {
        _colTitles[col] = title;
        return this;
    }

    protected override Point measureCell(int x, int y) {
        if (_customCellAdapter && _customCellAdapter.isCustomCell(x, y)) {
            return _customCellAdapter.measureCell(x, y);
        }
        //Log.d("measureCell ", x, ", ", y);
        FontRef fnt = font;
        dstring txt;
        if (x >= 0 && y >= 0)
            txt = cellText(x, y);
        else if (y < 0 && x >= 0)
            txt = colTitle(x);
        else if (y >= 0 && x < 0)
            txt = rowTitle(y);
        Point sz = fnt.textSize(txt);
        if (sz.y < fnt.height)
            sz.y = fnt.height;
        return sz;
    }


    /// draw cell content
    protected override void drawCell(DrawBuf buf, Rect rc, int col, int row) {
        if (_customCellAdapter && _customCellAdapter.isCustomCell(col, row)) {
            return _customCellAdapter.drawCell(buf, rc, col, row);
        }
        rc.shrink(2, 1);
        FontRef fnt = font;
        dstring txt = cellText(col, row);
        Point sz = fnt.textSize(txt);
        Align ha = Align.Left;
        applyAlign(rc, sz, ha, Align.VCenter);
        fnt.drawText(buf, rc.left + 1, rc.top + 1, txt, textColor);
    }

    /// draw cell content
    protected override void drawHeaderCell(DrawBuf buf, Rect rc, int col, int row) {
        rc.shrink(2, 1);
        FontRef fnt = font;
        dstring txt;
        if (row < 0 && col >= 0)
            txt = colTitle(col);
        else if (row >= 0 && col < 0)
            txt = rowTitle(row);
        if (!txt.length)
            return;
        Point sz = fnt.textSize(txt);
        Align ha = Align.Left;
        if (col < 0)
            ha = Align.Right;
        if (row < 0)
            ha = Align.HCenter;
        applyAlign(rc, sz, ha, Align.VCenter);
        fnt.drawText(buf, rc.left + 1, rc.top + 1, txt, textColor);
    }

    /// draw cell background
    protected override void drawHeaderCellBackground(DrawBuf buf, Rect rc, int c, int r) {
        Rect vborder = rc;
        Rect hborder = rc;
        vborder.left = vborder.right - 1;
        hborder.top = hborder.bottom - 1;
        hborder.right--;
        bool selectedCol = (c == col) && !_rowSelect;
        bool selectedRow = r == row;
        bool selectedCell = selectedCol && selectedRow;
        if (_rowSelect && selectedRow)
            selectedCell = true;
        // draw header cell background
        uint cl = _cellHeaderBackgroundColor;
        if (c >= _headerCols || r >= _headerRows) {
            if (c < _headerCols && selectedRow)
                cl = _cellHeaderSelectedBackgroundColor;
            if (r < _headerRows && selectedCol)
                cl = _cellHeaderSelectedBackgroundColor;
        }
        buf.fillRect(rc, cl);
        buf.fillRect(vborder, _cellHeaderBorderColor);
        buf.fillRect(hborder, _cellHeaderBorderColor);
    }


    /// handle theme change: e.g. reload some themed resources
    override void onThemeChanged() {
        _selectionColor = style.customColor("grid_selection_color", 0x804040FF);
        _selectionColorRowSelect = style.customColor("grid_selection_color_row", 0xC0A0B0FF);
        _fixedCellBackgroundColor = style.customColor("grid_cell_background_fixed", 0xC0E0E0E0);
        _cellBorderColor = style.customColor("grid_cell_border_color", 0xC0C0C0C0);
        _cellHeaderBorderColor = style.customColor("grid_cell_border_color_header", 0xC0202020);
        _cellHeaderBackgroundColor = style.customColor("grid_cell_background_header", 0xC0909090);
        _cellHeaderSelectedBackgroundColor = style.customColor("grid_cell_background_header_selected", 0x80FFC040);
        super.onThemeChanged();
    }

    /// draw cell background
    protected override void drawCellBackground(DrawBuf buf, Rect rc, int c, int r) {
        Rect vborder = rc;
        Rect hborder = rc;
        vborder.left = vborder.right - 1;
        hborder.top = hborder.bottom - 1;
        hborder.right--;
        bool selectedCol = c == col;
        bool selectedRow = r == row;
        bool selectedCell = selectedCol && selectedRow;
        if (_rowSelect && selectedRow)
            selectedCell = true;
        // normal cell background
        if (c < fixedCols || r < fixedRows) {
            // fixed cell background
            buf.fillRect(rc, _fixedCellBackgroundColor);
        }
        buf.fillRect(vborder, _cellBorderColor);
        buf.fillRect(hborder, _cellBorderColor);
        if (selectedCell) {
            if (_rowSelect)
                buf.drawFrame(rc, _selectionColorRowSelect, Rect(0,1,0,1), _cellBorderColor);
            else
                buf.drawFrame(rc, _selectionColor, Rect(1,1,1,1), _cellBorderColor);
        }
    }

}

import dlangui.widgets.metadata;
mixin(registerWidgets!(StringGridWidget)());
