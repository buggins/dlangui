module dlangui.widgets.grid;

import dlangui.widgets.widget;
import dlangui.widgets.controls;
import std.conv;

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

class GridWidgetBase : WidgetGroup {
	@property abstract int cols();
	@property abstract GridWidgetBase cols(int c);
	@property abstract int rows();
	@property abstract GridWidgetBase rows(int r);
	/// flag to enable column headers
	@property abstract bool showColHeaders();
	@property abstract GridWidgetBase showColHeaders(bool show);
	/// flag to enable row headers
	@property abstract bool showRowHeaders();
	@property abstract GridWidgetBase showRowHeaders(bool show);
	this(string ID = null) {
		super(ID);
	}
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
}

/**
 * Grid view with string data shown. All rows are of the same height.
 */
class StringGridWidget : GridWidgetBase {
	protected ScrollBar _vscrollbar;
	protected ScrollBar _hscrollbar;
	protected int _cols;
	protected int _rows;
	protected dstring[][] _data;
	protected dstring[] _rowTitles;
	protected dstring[] _colTitles;
	protected int[] _colWidths;
	protected int[] _rowHeights;
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

	this(string ID = null) {
		super(ID);
		_vscrollbar = new ScrollBar("vscrollbar", Orientation.Vertical);
		_hscrollbar = new ScrollBar("hscrollbar", Orientation.Horizontal);
		addChild(_vscrollbar);
		addChild(_hscrollbar);
		styleId = "EDIT_BOX";
        // create sample grid content
		_headerCols = 1;
		_headerRows = 1;
        _fixedCols = 2;
        _fixedRows = 2;
        resize(20, 30);
        _col = 3;
        _row = 4;
        for (int y = 1; y < _rows; y++) {
            for (int x = 1; x < _cols; x++) {
                _data[y][x] = "cell("d ~ to!dstring(x) ~ ","d ~ to!dstring(y) ~ ")"d;
            }
        }
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
		]);
        focusable = true;
	}
	@property override int cols() {
		return _cols;
	}
	@property override GridWidgetBase cols(int c) {
		resize(c, _rows);
		return this;
	}
	@property override int rows() {
		return _rows;
	}
	@property override GridWidgetBase rows(int r) {
		resize(_cols, r);
		return this;
	}
	/// flag to enable column headers
	@property override bool showColHeaders() {
		return _headerRows > 0;
	}
	@property override GridWidgetBase showColHeaders(bool show) {
		_headerRows = show ? 1 : 0;
		return this;
	}
	/// flag to enable row headers
	@property override bool showRowHeaders() {
		return _headerCols > 0;
	}
	@property override GridWidgetBase showRowHeaders(bool show) {
		_headerCols = show ? 1 : 0;
		return this;
	}
	/// get cell text
	dstring cellText(int col, int row) {
		return _data[row][col];
	}
	/// set cell text
	GridWidgetBase setCellText(int col, int row, dstring text) {
		_data[row][col] = text;
		return this;
	}

    /// zero based index generation of column header - like in Excel - for testing
    dstring genColHeader(int col) {
        dstring res;
        int n1 = col / 26;
        int n2 = col % 26;
        if (n1)
            res ~= n1 + 'A';
        res ~= n2 + 'A';
        return res;
    }

	/// set new size
	void resize(int cols, int rows) {
		if (cols == _cols && rows == _rows)
			return;
		_data.length = rows;
		for (int y = 0; y < rows; y++)
			_data[y].length = cols;
		_colTitles.length = cols;
        for (int i = _cols; i < cols; i++)
            _colTitles[i] = i > 0 ? ("col "d ~ to!dstring(i)) : ""d;
		_rowTitles.length = rows;
		_colWidths.length = cols;
        for (int i = _cols; i < cols; i++) {
            if (i >= _headerCols)
                _data[0][i] = genColHeader(i - _headerCols);
            _colWidths[i] = i == 0 ? 20 : 100;
        }
		_rowHeights.length = rows;
        int fontHeight = font.height;
        for (int i = _rows; i < rows; i++) {
            if (i >= _headerRows)
                _data[i][0] = to!dstring(i - _headerRows + 1);
            _rowHeights[i] = fontHeight + 2;
        }
		_cols = cols;
		_rows = rows;
	}

    /// returns column width (index includes col/row headers, if any); returns 0 for columns hidden by scroll at the left
    int colWidth(int x) {
        if (x >= _headerCols + _fixedCols && x < _headerCols + _fixedCols + _scrollCol)
            return 0;
        return _colWidths[x];
    }

    /// returns row height (index includes col/row headers, if any); returns 0 for riws hidden by scroll at the top
    int rowHeight(int y) {
        if (y >= _headerRows + _fixedRows && y < _headerRows + _fixedRows + _scrollRow)
            return 0;
        return _rowHeights[y];
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
    void updateScrollBars() {
        // TODO
    }

    /// ensure that cell is visible (scroll if necessary)
    void makeCellVisible(int col, int row) {
        bool scrolled = false;
        Rect rc = cellRect(col, row);
        if (col >= _headerCols + _fixedCols && col < _headerCols + _fixedCols + _scrollCol) {
            // scroll to the left
            _scrollCol = col - _headerCols - _fixedCols;
            scrolled = true;
        } else {
            while (rc.right > _clientRect.width && _scrollCol < _cols - _fixedCols - _headerCols - 1) {
                _scrollCol++;
                rc = cellRect(col, row);
                scrolled = true;
            }
        }
        if (row >= _headerRows + _fixedRows && row < _headerRows + _fixedRows + _scrollRow) {
            // scroll to the left
            _scrollRow = row - _headerRows - _fixedRows;
            scrolled = true;
        } else {
            while (rc.bottom > _clientRect.height && _scrollRow < _rows - _fixedRows - _headerRows - 1) {
                _scrollRow++;
                rc = cellRect(col, row);
                scrolled = true;
            }
        }
        if (scrolled) {
            updateScrollBars();
            invalidate();
        }
    }

    bool selectCell(int col, int row, bool makeVisible = true) {
        if (_col == col && _row == row)
            return false; // same position
        if (col < _headerCols || row < _headerRows || col >= _cols || row >= _rows)
            return false; // out of range
        _col = col;
        _row = row;
        invalidate();
        if (makeVisible)
            makeCellVisible(_col, _row);
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
            if (cellFound && normalCell) {
                selectCell(c, r);
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
        return super.onMouseEvent(event);
    }

    protected void calcScrollableAreaPos(ref Rect fullyVisibleCells, ref Rect fullyVisibleCellsRect) {
        fullyVisibleCells.left = _headerCols + _fixedCols + _scrollCol;
        fullyVisibleCells.top = _headerRows + _fixedRows + _scrollRow;
        Rect rc;
        int xx = 0;
        for (int i = 0; i < _cols && xx < _clientRect.width; i++) {
            if (i == fullyVisibleCells.left)
                fullyVisibleCellsRect.left = fullyVisibleCellsRect.right = xx;
            int w = colWidth(i);
            if (i >= fullyVisibleCells.left && xx + w <= _clientRect.width) {
                fullyVisibleCellsRect.right = xx + w;
                fullyVisibleCells.right = i;
            }
            xx += w;
        }
        int yy = 0;
        for (int i = 0; i < _rows && yy < _clientRect.height; i++) {
            if (i == fullyVisibleCells.top)
                fullyVisibleCellsRect.top = fullyVisibleCellsRect.bottom = yy;
            int w = rowHeight(i);
            if (i >= fullyVisibleCells.top && yy + w <= _clientRect.height) {
                fullyVisibleCellsRect.bottom = yy + w;
                fullyVisibleCells.bottom = i;
            }
            yy += w;
        }
    }

	override protected bool handleAction(const Action a) {
        Rect fullyVisibleCells;
        Rect fullyVisibleCellsRect;
        calcScrollableAreaPos(fullyVisibleCells, fullyVisibleCellsRect);
		switch (a.id) {
            case GridActions.Left:
                selectCell(_col - 1, _row);
                return true;
            case GridActions.Right:
                selectCell(_col + 1, _row);
                return true;
            case GridActions.Up:
                selectCell(_col, _row - 1);
                return true;
            case GridActions.Down:
                selectCell(_col, _row + 1);
                return true;
            case GridActions.LineBegin:
                if (_scrollCol > 0 && _col > _headerCols + _fixedCols + _scrollCol)
                    selectCell(_headerCols + _fixedCols + _scrollCol, _row);
                else {
                    if (_scrollCol > 0) {
                        _scrollCol = 0;
                        updateScrollBars();
                        invalidate();
                    }
                    selectCell(_headerCols, _row);
                }
                return true;
            case GridActions.LineEnd:
                selectCell(_cols - 1, _row);
                return true;
            case GridActions.DocumentBegin:
                if (_scrollRow > 0) {
                    _scrollRow = 0;
                    updateScrollBars();
                    invalidate();
                }
                selectCell(_col, _headerRows);
                return true;
            case GridActions.DocumentEnd:
                selectCell(_col, _rows - 1);
                return true;
            case GridActions.PageBegin:
                if (_scrollRow > 0)
                    selectCell(_col, _headerRows + _fixedRows + _scrollRow);
                else
                    selectCell(_col, _headerRows);
                return true;
            case GridActions.PageEnd:
                int found = -1;
                for (int i = _fixedRows; i < _rows; i++) {
                    Rect rc = cellRect(_col, i);
                    if (rc.bottom <= _clientRect.height)
                        found = i;
                    else
                        break;
                }
                if (found >= 0)
                    selectCell(_col, found);
                return true;
            case GridActions.PageUp:
                if (_row > fullyVisibleCells.top) {
                    // not at top scrollable cell
                    selectCell(_col, fullyVisibleCells.top);
                } else {
                    // at top of scrollable area
                    if (_scrollRow > 0) {
                        // scroll up line by line
                        int prevRow = _row;
                        for (int i = prevRow - 1; i >= _headerRows; i--) {
                            selectCell(_col, i);
                            calcScrollableAreaPos(fullyVisibleCells, fullyVisibleCellsRect);
                            if (fullyVisibleCells.bottom <= prevRow)
                                break;
                        }
                    } else {
                        // scrolled to top - move upper cell
                        selectCell(_col, _headerRows);
                    }
                }
                return true;
            case GridActions.PageDown: 
                if (_row < _rows) {
                    if (_row < fullyVisibleCells.bottom) {
                        // not at top scrollable cell
                        selectCell(_col, fullyVisibleCells.bottom);
                    } else {
                        // scroll down
                        int prevRow = _row;
                        for (int i = prevRow + 1; i < _rows; i++) {
                            selectCell(_col, i);
                            calcScrollableAreaPos(fullyVisibleCells, fullyVisibleCellsRect);
                            if (fullyVisibleCells.top >= prevRow)
                                break;
                        }
                    }
                }
                return true;
            default:
                return super.handleAction(a);
        }
    }

	/// returns row header title
	dstring rowTitle(int row) {
		return _rowTitles[row];
	}
	/// set row header title
	GridWidgetBase setRowTitle(int row, dstring title) {
		_rowTitles[row] = title;
		return this;
	}
	/// returns row header title
	dstring colTitle(int col) {
		return _colTitles[col];
	}
	/// set col header title
	GridWidgetBase setColTitle(int col, dstring title) {
		_colTitles[col] = title;
		return this;
	}
	/// draw column header
	void drawColHeader(DrawBuf buf, Rect rc, int index) {
        //FontRef fnt = font;
        //buf.fillRect(rc, 0xE0E0E0);
        //buf.drawFrame(rc, 0x808080, Rect(1,1,1,1));
        //fnt.drawText(buf, rc.left, rc.top, "col"d, 0x000000);
	}
	/// draw row header
	void drawRowHeader(DrawBuf buf, Rect rc, int index) {
        //FontRef fnt = font;
        //buf.fillRect(rc, 0xE0E0E0);
        //buf.drawFrame(rc, 0x808080, Rect(1,1,1,1));
        //fnt.drawText(buf, rc.left, rc.top, "row"d, 0x000000);
	}

	/// Measure widget according to desired width and height constraints. (Step 1 of two phase layout).
	override void measure(int parentWidth, int parentHeight) { 
		Rect m = margins;
		Rect p = padding;
		// calc size constraints for children
		int pwidth = parentWidth;
		int pheight = parentHeight;
		if (parentWidth != SIZE_UNSPECIFIED)
			pwidth -= m.left + m.right + p.left + p.right;
		if (parentHeight != SIZE_UNSPECIFIED)
			pheight -= m.top + m.bottom + p.top + p.bottom;
		_hscrollbar.measure(pwidth, pheight);
		_vscrollbar.measure(pwidth, pheight);
		measuredContent(parentWidth, parentHeight, 100, 100);
	}

	protected Rect _clientRect;

	/// Set widget rectangle to specified value and layout widget contents. (Step 2 of two phase layout).
	override void layout(Rect rc) {
		if (visibility == Visibility.Gone) {
			return;
		}
		_pos = rc;
		_needLayout = false;
		applyMargins(rc);
		applyPadding(rc);
		// scrollbars
		Rect vsbrc = rc;
		vsbrc.left = vsbrc.right - _vscrollbar.measuredWidth;
		vsbrc.bottom = vsbrc.bottom - _hscrollbar.measuredHeight;
		Rect hsbrc = rc;
		hsbrc.right = hsbrc.right - _vscrollbar.measuredWidth;
		hsbrc.top = hsbrc.bottom - _hscrollbar.measuredHeight;
		_vscrollbar.layout(vsbrc);
		_hscrollbar.layout(hsbrc);
		// client area
		_clientRect = rc;
		_clientRect.right = vsbrc.left;
		_clientRect.bottom = hsbrc.top;
	}

	/// draw cell content
	void drawCell(DrawBuf buf, Rect rc, int col, int row) {
        rc.shrink(2, 1);
		FontRef fnt = font;
        dstring txt = cellText(col, row);
        Point sz = fnt.textSize(txt);
        Align ha = Align.Left;
        if (col < _headerCols)
            ha = Align.Right;
        if (row < _headerRows)
            ha = Align.HCenter;
        applyAlign(rc, sz, ha, Align.VCenter);
		fnt.drawText(buf, rc.left + 1, rc.top + 1, txt, 0x000000);
	}

	/// draw cell background
	void drawCellBackground(DrawBuf buf, Rect rc, int col, int row) {
        Rect vborder = rc;
        Rect hborder = rc;
        vborder.left = vborder.right - 1;
        hborder.top = hborder.bottom - 1;
        hborder.right--;
        bool selectedCol = _col == col;
        bool selectedRow = _row == row;
        bool selectedCell = selectedCol && selectedRow;
        if (col < _headerCols || row < _headerRows) {
            // draw header cell background
            uint cl = 0x80909090;
            if (selectedCol || selectedRow)
                cl = 0x80FFC040;
            buf.fillRect(rc, cl);
            buf.fillRect(vborder, 0x80202020);
            buf.fillRect(hborder, 0x80202020);
        } else {
            // normal cell background
            if (col < _headerCols + _fixedCols || row < _headerRows + _fixedRows) {
                // fixed cell background
                buf.fillRect(rc, 0x80E0E0E0);
            }
            buf.fillRect(vborder, 0x80C0C0C0);
            buf.fillRect(hborder, 0x80C0C0C0);
            if (selectedCell)
                buf.drawFrame(rc, 0x404040FF, Rect(1,1,1,1), 0xC0FFFF00);
        }
	}

	void drawClient(DrawBuf buf) {
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
                    if (phase == 0)
                        drawCellBackground(buf, cellRect, x, y);
                    else
                        drawCell(buf, cellRect, x, y);
                }
            }
        }
	}
	/// Draw widget at its position to buffer
	override void onDraw(DrawBuf buf) {
		if (visibility != Visibility.Visible)
			return;
		Rect rc = _pos;
		applyMargins(rc);
		auto saver = ClipRectSaver(buf, rc, alpha);
		DrawableRef bg = backgroundDrawable;
		if (!bg.isNull) {
			bg.drawTo(buf, rc, state);
		}
		applyPadding(rc);
		_hscrollbar.onDraw(buf);
		_vscrollbar.onDraw(buf);
		drawClient(buf);
		_needDraw = false;
	}
}

/**
 * Multicolumn multirow view.
 */
class GridWidget : WidgetGroup {
	protected GridAdapter _adapter;
	/// when true, widget owns adapter and must destroy it itself.
	protected bool _ownAdapter;
	protected int _cols;
	protected int _rows;
	/// returns current grid adapter
	@property GridAdapter adapter() { return _adapter; }
	/// sets shared adapter (will not be destroyed on widget destroy)
	@property GridWidget adapter(GridAdapter a) {
		if (_ownAdapter && _adapter)
			destroy(_adapter);
		_ownAdapter = false;
		_adapter = a;
		return this;
	}
	/// sets own adapter (will be destroyed on widget destroy)
	@property GridWidget ownAdapter(GridAdapter a) {
		if (_ownAdapter && _adapter)
			destroy(_adapter);
		_adapter = a;
		return this;
	}
	/// destroy own adapter
	~this() {
		if (_ownAdapter && _adapter)
			destroy(_adapter);
	}
}

