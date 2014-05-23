module src.dlangui.widgets.grid;

import dlangui.widgets.widget;

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

/**
 * Grid view with string data shown. All rows are of the same height.
 */
class StringGridWidget : GridWidget {
}
