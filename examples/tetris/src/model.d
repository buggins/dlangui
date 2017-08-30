module model;

import std.random : uniform;

/// Cell codes
enum : int {
    WALL = -1,
    EMPTY = 0,
    FIGURE1,
    FIGURE2,
    FIGURE3,
    FIGURE4,
    FIGURE5,
    FIGURE6,
    FIGURE7,
}

/// Orientations
enum : int {
    ORIENTATION0,
    ORIENTATION90,
    ORIENTATION180,
    ORIENTATION270
}


/// Cell offset
struct FigureCell {
    // horizontal offset
    int dx;
    // vertical offset
    int dy;
    this(int[2] v) {
        dx = v[0];
        dy = v[1];
    }
}

/// Single figure shape for some particular orientation - 4 cells
struct FigureShape {
    /// by cell index 0..3
    FigureCell[4] cells;
    /// lowest y coordinate - to show next figure above cup
    int extent;
    /// upper y coordinate - initial Y offset to place figure to cup
    int y0;
    /// Init cells (cell 0 is [0,0])
    this(int[2] c2, int[2] c3, int[2] c4) {
        cells[0] = FigureCell([0, 0]);
        cells[1] = FigureCell(c2);
        cells[2] = FigureCell(c3);
        cells[3] = FigureCell(c4);
        extent = y0 = 0;
        foreach (cell; cells) {
            if (extent > cell.dy)
                extent = cell.dy;
            if (y0 < cell.dy)
                y0 = cell.dy;
        }
    }
}

/// Figure data - shapes for 4 orientations
struct Figure {
    FigureShape[4] shapes; // by orientation
    this(FigureShape[4] v) {
        shapes = v;
    }
}

/// All shapes
__gshared const Figure[7] FIGURES;

// workaround for dmd 2.0.67 - move initialization to static this
__gshared static this() {
    FIGURES = [
        // FIGURE1 ===========================================
        //   ##     ####
        // 00##       00##
        // ##
        Figure([FigureShape([1, 0], [ 1, 1], [0,-1]),
                FigureShape([0, 1], [-1, 1], [1, 0]),
                FigureShape([1, 0], [ 1, 1], [0,-1]),
                FigureShape([0, 1], [-1, 1], [1, 0])]),
        // FIGURE2 ===========================================
        // ##         ####
        // 00##     ##00
        //   ##
        Figure([FigureShape([1, 0], [0, 1], [ 1,-1]),
                FigureShape([0, 1], [1, 1], [-1, 0]),
                FigureShape([1, 0], [0, 1], [ 1,-1]),
                FigureShape([0, 1], [1, 1], [-1, 0])]),
        // FIGURE3 ===========================================
        //            ##        ##      ####
        // ##00##     00    ##00##        00
        // ##         ####                ##
        Figure([FigureShape([1, 0], [-1, 0], [-1,-1]),
                FigureShape([0, 1], [ 0,-1], [ 1,-1]),
                FigureShape([1, 0], [-1, 0], [ 1, 1]),
                FigureShape([0, 1], [-1, 1], [ 0,-1])]),
        // FIGURE4 ===========================================
        //            ####  ##            ##
        // ##00##     00    ##00##        00
        //     ##     ##                ####
        Figure([FigureShape([1, 0], [-1, 0], [ 1,-1]),
                FigureShape([0, 1], [ 0,-1], [ 1, 1]),
                FigureShape([1, 0], [-1, 0], [-1, 1]),
                FigureShape([0, 1], [-1,-1], [ 0,-1])]),
        // FIGURE5 ===========================================
        //   ####
        //   00##
        //
        Figure([FigureShape([1, 0], [0, 1], [ 1, 1]),
                FigureShape([1, 0], [0, 1], [ 1, 1]),
                FigureShape([1, 0], [0, 1], [ 1, 1]),
                FigureShape([1, 0], [0, 1], [ 1, 1])]),
        // FIGURE6 ===========================================
        //   ##
        //   ##
        //   00     ##00####
        //   ##
        Figure([FigureShape([0, 1], [0, 2], [ 0,-1]),
                FigureShape([1, 0], [2, 0], [-1, 0]),
                FigureShape([0, 1], [0, 2], [ 0,-1]),
                FigureShape([1, 0], [2, 0], [-1, 0])]),
        // FIGURE7 ===========================================
        //            ##      ##          ##
        // ##00##     00##  ##00##      ##00
        //   ##       ##                  ##
        Figure([FigureShape([1, 0], [-1,0], [ 0,-1]),
                FigureShape([0, 1], [0,-1], [ 1, 0]),
                FigureShape([1, 0], [-1,0], [ 0, 1]),
                FigureShape([0, 1], [0,-1], [-1, 0])]),
    ];
}

/// colors for different figure types
const uint[7] _figureColors = [0xC00000, 0x80A000, 0xA00080, 0x0000C0, 0x800020, 0x408000, 0x204000];

/// Figure type, orientation and position container
struct FigurePosition {
    int index;
    int orientation;
    int x;
    int y;
    this(int index, int orientation, int x, int y) {
        this.index = index;
        this.orientation = orientation;
        this.x = x;
        this.y = y;
    }
    /// return rotated position CCW for angle=1, CW for angle=-1
    FigurePosition rotate(int angle) {
        int newOrientation = (orientation + 4 + angle) & 3;
        return FigurePosition(index, newOrientation, x, y);
    }
    /// return moved position
    FigurePosition move(int dx, int dy = 0) {
        return FigurePosition(index, orientation, x + dx, y + dy);
    }
    /// return shape for figure orientation
    @property FigureShape shape() const {
        return FIGURES[index - 1].shapes[orientation];
    }
    /// return color for figure
    @property uint color() const {
        return _figureColors[index - 1];
    }
    /// return true if figure index is not initialized
    @property empty() const {
        return index == 0;
    }
    /// clears content
    void reset() {
        index = 0;
    }
}

/**
Cup content

Coordinates are relative to bottom left corner.
*/
struct Cup {
    private int[] _cup;
    private int _cols;
    private int _rows;
    private bool[] _destroyedFullRows;
    private int[]  _cellGroups;

    private FigurePosition _currentFigure;
    /// current figure index, orientation, position
    @property ref FigurePosition currentFigure() { return _currentFigure; }

    private FigurePosition _nextFigure;
    /// next figure
    @property ref FigurePosition nextFigure() { return _nextFigure; }

    /// returns number of columns
    @property int cols() {
        return _cols;
    }
    /// returns number of columns
    @property int rows() {
        return _rows;
    }
    /// inits empty cup of specified size
    void initialize(int cols, int rows) {
        _cols = cols;
        _rows = rows;
        _cup = new int[_cols * _rows];
        _destroyedFullRows = new bool[_rows];
        _cellGroups = new int[_cols * _rows];
    }
    /// returns cell content at specified position
    int opIndex(int col, int row) {
        if (col < 0 || row < 0 || col >= _cols || row >= _rows)
            return WALL;
        return _cup[row * _cols + col];
    }
    /// set cell value
    void opIndexAssign(int value, int col, int row) {
        if (col < 0 || row < 0 || col >= _cols || row >= _rows)
            return; // ignore modification of cells outside cup
        _cup[row * _cols + col] = value;
    }
    /// put current figure into cup at current position and orientation
    void putFigure() {
        FigureShape shape = _currentFigure.shape;
        foreach(cell; shape.cells) {
            this[_currentFigure.x + cell.dx, _currentFigure.y + cell.dy] = _currentFigure.index;
        }
    }

    /// check if all cells where specified figure is located are free
    bool isPositionFree(in FigurePosition pos) {
        FigureShape shape = pos.shape;
        foreach(cell; shape.cells) {
            int value = this[pos.x + cell.dx, pos.y + cell.dy];
            if (value != 0) // occupied
                return false;
        }
        return true;
    }
    /// returns true if specified row is full
    bool isRowFull(int row) {
        for (int i = 0; i < _cols; i++)
            if (this[i, row] == EMPTY)
                return false;
        return true;
    }
    /// returns true if at least one row is full
    @property bool hasFullRows() {
        for (int i = 0; i < _rows; i++)
            if (isRowFull(i))
                return true;
        return false;
    }
    /// destroy all full rows, saving flags for destroyed rows; returns count of destroyed rows, 0 if no rows destroyed
    int destroyFullRows() {
        int res = 0;
        for (int i = 0; i < _rows; i++) {
            if (isRowFull(i)) {
                _destroyedFullRows[i] = true;
                res++;
                for (int col = 0; col < _cols; col++)
                    this[col, i] = EMPTY;
            } else {
                _destroyedFullRows[i] = false;
            }
        }
        return res;
    }

    /// check if all cells where current figire is located are free
    bool isPositionFree() {
        return isPositionFree(_currentFigure);
    }

    /// check if all cells where current figire is located are free
    bool isPositionFreeBelow() {
        return isPositionFree(_currentFigure.move(0, -1));
    }

    /// try to rotate current figure, returns true if figure rotated
    bool rotate(int angle, bool falling) {
        FigurePosition newpos = _currentFigure.rotate(angle);
        if (isPositionFree(newpos)) {
            if (falling) {
                // special handling for fall animation
                if (!isPositionFree(newpos.move(0, -1))) {
                    if (isPositionFreeBelow())
                        return false;
                }
            }
            _currentFigure = newpos;
            return true;
        } else if (isPositionFree(newpos.move(0, -1))) {
            _currentFigure = newpos.move(0, -1);
            return true;
        }
        return false;
    }

    /// try to move current figure, returns true if figure rotated
    bool move(int deltaX, int deltaY, bool falling) {
        FigurePosition newpos = _currentFigure.move(deltaX, deltaY);
        if (isPositionFree(newpos)) {
            if (falling && !isPositionFree(newpos.move(0, -1))) {
                if (isPositionFreeBelow())
                    return false;
            }
            _currentFigure = newpos;
            return true;
        }
        return false;
    }

    /// random next figure
    void genNextFigure() {
        _nextFigure.index = uniform(FIGURE1, FIGURE7 + 1);
        _nextFigure.orientation = ORIENTATION0;
        _nextFigure.x = _cols / 2;
        _nextFigure.y = _rows - _nextFigure.shape.extent + 1;
    }

    /// New figure: put it on top of cup
    bool dropNextFigure() {
        if (_nextFigure.empty)
            genNextFigure();
        _currentFigure = _nextFigure;
        _currentFigure.x = _cols / 2;
        _currentFigure.y = _rows - 1 - _currentFigure.shape.y0;
        return isPositionFree();
    }

    /// get cell group / falling cell value
    private int cellGroup(int col, int row) {
        if (col < 0 || row < 0 || col >= _cols || row >= _rows)
            return 0;
        return _cellGroups[col + row * _cols];
    }

    /// set cell group / falling cells value
    private void setCellGroup(int value, int col, int row) {
        _cellGroups[col + row * _cols] = value;
    }

    /// recursive fill occupied area of cells with group id
    private void fillCellGroup(int x, int y, int value) {
        if (x < 0 || y < 0 || x >= _cols || y >= _rows)
            return;
        if (this[x, y] != EMPTY && cellGroup(x, y) == 0) {
            setCellGroup(value, x, y);
            fillCellGroup(x + 1, y, value);
            fillCellGroup(x - 1, y, value);
            fillCellGroup(x, y + 1, value);
            fillCellGroup(x, y - 1, value);
        }
    }

    /// 1 == next cell below is occupied, 2 == one empty cell
    private int distanceToOccupiedCellBelow(int col, int row) {
        for (int y = row - 1; y >= -1; y--) {
            if (this[col, y] != EMPTY)
                return row - y;
        }
        return 1;
    }

    /// 1 == next cell below is occupied, 2 == one empty cell
    private int distanceToOccupiedCellBelowForGroup(int group) {
        int minDistanceFound = 0;
        for (int y = 0; y < _rows; y++) {
            for (int x = 0; x < _cols; x++) {
                if (cellGroup(x, y) != group)
                    continue;
                if (y == 0)
                    return 1; // right below
                if (this[x, y - 1] != EMPTY) // check only lowest cell of group
                    continue;
                int dist = 0;
                for (int d = 1; y - d >= 0; d++) {
                    if (this[x, y - d] == EMPTY) {
                        dist = d + 1;
                    } else {
                        // reached non-empty cell
                        if (cellGroup(x, y - d) == group) {
                            // non-empty cell of the same group after empty space - ignore
                            dist = 0;
                        }
                        break;
                    }
                }
                if (dist > 0) {
                    // found some empty space below
                    if (minDistanceFound == 0 || minDistanceFound > dist)
                        minDistanceFound = dist;
                }
            }
        }
        if (minDistanceFound == 0)
            return 1;
        return minDistanceFound;
    }

    /// mark cells in _cellGroups[] matrix which can fall down (value > 0 is distance to fall)
    bool markFallingCells() {
        // clear cellGroups matrix
        if (_cellGroups.length != _cols * _rows) {
            _cellGroups = new int[_cols * _rows];
        } else {
            foreach(ref cell; _cellGroups)
                cell = 0;
        }
        // find and mark all groups
        int groupId = 1;
        for (int y = 0; y < _rows; y++) {
            for (int x = 0; x < _cols; x++) {
                if (this[x, y] != EMPTY && cellGroup(x, y) == 0) {
                    fillCellGroup(x, y, groupId);
                    groupId++;
                }
            }
        }
        // check space below each group - can it fall down?
        int[] spaceBelowGroup = new int[groupId];
        static if (true) {
            for (int i = 1; i < groupId; i++)
                spaceBelowGroup[i] = distanceToOccupiedCellBelowForGroup(i);
        } else {
            for (int y = 0; y < _rows; y++) {
                for (int x = 0; x < _cols; x++) {
                    int group = cellGroup(x, y);
                    if (group > 0) {
                        if (y == 0)
                            spaceBelowGroup[group] = 1;
                        else if (this[x, y - 1] != EMPTY && cellGroup(x, y - 1) != group)
                            spaceBelowGroup[group] = 1;
                        else if (this[x, y - 1] == EMPTY) {
                            int dist = distanceToOccupiedCellBelow(x, y);
                            if (spaceBelowGroup[group] == 0 || spaceBelowGroup[group] > dist)
                                spaceBelowGroup[group] = dist;
                        }
                    }
                }
            }
        }
        // replace group IDs with distance to fall (0 == cell cannot fall)
        for (int y = 0; y < _rows; y++) {
            for (int x = 0; x < _cols; x++) {
                int group = cellGroup(x, y);
                if (group > 0) {
                    // distance to fall
                    setCellGroup(spaceBelowGroup[group] - 1, x, y);
                }
            }
        }
        bool canFall = false;
        for (int i = 1; i < groupId; i++)
            if (spaceBelowGroup[i] > 1)
                canFall = true;
        return canFall;
    }

    /// moves all falling cells one cell down
    /// returns true if there are more cells to fall
    bool moveFallingCells() {
        bool res = false;
        for (int y = 0; y < _rows - 1; y++) {
            for (int x = 0; x < _cols; x++) {
                int dist = cellGroup(x, y + 1);
                if (dist > 0) {
                    // move cell down, decreasing distance
                    setCellGroup(dist - 1, x, y);
                    this[x, y] = this[x, y + 1];
                    setCellGroup(0, x, y + 1);
                    this[x, y + 1] = EMPTY;
                    if (dist > 1)
                        res = true;
                }
            }
        }
        return res;
    }

    /// return true if cell is currently falling
    bool isCellFalling(int col, int row) {
        return cellGroup(col, row) > 0;
    }

    /// returns true if next figure is generated
    @property bool hasNextFigure() {
        return !_nextFigure.empty;
    }
}

