// Written in the D programming language.

/**
This app is a Tetris demo for DlangUI library.

Synopsis:

----
	dub run dlangui:tetris
----

Copyright: Vadim Lopatin, 2014
License:   Boost License 1.0
Authors:   Vadim Lopatin, coolreader.org@gmail.com
 */
module main;

import dlangui.all;
//import dlangui.dialogs.dialog;
//import dlangui.dialogs.filedlg;
//import dlangui.dialogs.msgbox;
import dlangui.widgets.popup;
import dlangui.graphics.drawbuf;
import std.stdio;
import std.conv;
import std.utf;
import std.random;


mixin APP_ENTRY_POINT;

Widget createAboutWidget()
{
	LinearLayout res = new VerticalLayout();
	res.padding(Rect(10,10,10,10));
	res.addChild(new TextWidget(null, "DLangUI Tetris demo app"d));
	res.addChild(new TextWidget(null, "(C) Vadim Lopatin, 2014"d));
	res.addChild(new TextWidget(null, "http://github.com/buggins/dlangui"d));
	Button closeButton = new Button("close", "Close"d);
	closeButton.onClickListener = delegate(Widget src) {
		Log.i("Closing window");
		res.window.close();
		return true;
	};
	res.addChild(closeButton);
	return res;
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
    this(int[2] c1, int[2] c2, int[2] c3, int[2] c4) {
        cells[0] = FigureCell(c1);
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

struct Figure {
    FigureShape[4] shapes; // by orientation
    this(FigureShape[4] v) {
        shapes = v;
    }
}

const Figure[6] FIGURES = [
    //   ##     ####
    // 00##       00##
    // ##       
    Figure([FigureShape([0, 0], [1, 0], [1, 1],  [0, -1]),
            FigureShape([0, 0], [0, 1], [-1, 1], [1, 0]),
            FigureShape([0, 0], [1, 0], [1, 1],  [0, -1]),
            FigureShape([0, 0], [0, 1], [-1, 1], [1, 0])]),
    // ##         ####
    // 00##     ##00
    //   ##     
    Figure([FigureShape([0, 0], [1, 0], [0, 1],  [1, 1]),
            FigureShape([0, 0], [0, 1], [1, 1],  [-1, 0]),
            FigureShape([0, 0], [1, 0], [0, 1],  [1, 1]),
            FigureShape([0, 0], [0, 1], [1, 1],  [-1, 0])]),
    //            ##        ##      ####
    // ##00##     00    ##00##        00
    // ##         ####                ##
    Figure([FigureShape([0, 0], [1, 0], [-1,0],  [-1,-1]),
            FigureShape([0, 0], [0, 1], [0,-1],  [ 1,-1]),
            FigureShape([0, 0], [1, 0], [-1,0],  [1, 1]),
            FigureShape([0, 0], [0, 1], [-1,1],  [0,-1])]),
    //            ####  ##            ##
    // ##00##     00    ##00##        00
    //     ##     ##                ####    
    Figure([FigureShape([0, 0], [1, 0], [-1,0],  [ 1, 1]),
            FigureShape([0, 0], [0, 1], [0,-1],  [ 1, 1]),
            FigureShape([0, 0], [1, 0], [-1,0],  [-1, 1]),
            FigureShape([0, 0], [0, 1], [-1,-1], [0, -1])]),
    //   ####
    //   00##
    //       
    Figure([FigureShape([0, 0], [1, 0], [0, 1],  [ 1, 1]),
            FigureShape([0, 0], [1, 0], [0, 1],  [ 1, 1]),
            FigureShape([0, 0], [1, 0], [0, 1],  [ 1, 1]),
            FigureShape([0, 0], [1, 0], [0, 1],  [ 1, 1])]),
    //   ##
    //   ##
    //   00     ##00####
    //   ##    
    Figure([FigureShape([0, 0], [0, 1], [0, 2],  [ 0,-1]),
            FigureShape([0, 0], [1, 0], [2, 0],  [-1, 0]),
            FigureShape([0, 0], [0, 1], [0, 2],  [ 0,-1]),
            FigureShape([0, 0], [1, 0], [2, 0],  [-1, 0])]),
];

enum TetrisAction : int {
    MoveLeft = 10000,
    MoveRight,
    RotateCCW,
    FastDown,
}

enum : int {
    WALL = -1,
    EMPTY = 0,
    FIGURE1,
    FIGURE2,
    FIGURE3,
    FIGURE4,
    FIGURE5,
    FIGURE6,
}

enum : int {
    ORIENTATION0,
    ORIENTATION90,
    ORIENTATION180,
    ORIENTATION270
}

const uint[6] _figureColors = [0xFF0000, 0xA0A000, 0xA000A0, 0x0000FF, 0x800000, 0x408000];

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
}

/** 
    Cup content

    Coordinates are relative to bottom left corner.
 */
struct Cup {
    private int[] _cup;
    private int _cols;
    private int _rows;
    /// returns number of columns
    @property int cols() {
        return _cols;
    }
    /// returns number of columns
    @property int rows() {
        return _rows;
    }
    /// inits empty cup of specified size
    void init(int cols, int rows) {
        _cols = cols;
        _rows = rows;
        _cup = new int[_cols * _rows];
        for (int i = 0; i < _cup.length; i++)
            _cup[i] = EMPTY;
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
    /// put figure at specified position
    void putFigure(FigurePosition pos) {
        FigureShape shape = pos.shape;
        foreach(cell; shape.cells) {
            this[pos.x + cell.dx, pos.y + cell.dy] = pos.index;
        }
    }
    /// check if all cells where figire is located are free
    bool isPositionFree(in FigurePosition pos) {
        FigureShape shape = pos.shape;
        foreach(cell; shape.cells) {
            int value = this[pos.x + cell.dx, pos.y + cell.dy];
            if (value != 0) // occupied
                return false;
        }
        return true;
    }
}

/// Cup widget
class CupWidget : Widget {
    /// cup columns count
    int _cols;
    /// cup rows count
    int _rows;
    /// cup data
    Cup _cup;

    /// current figure index, orientation, position
    FigurePosition _currentFigure;
    /// next figure id
    FigurePosition _nextFigure;

    /// Level 1..10
    int _level;
    /// Single cell movement duration for current level, in 1/10000000 of seconds
    long _movementDuration;
    /// When true, figure is falling down fast
    bool _fastDownFlag;

    AnimationHelper _animation;
    private PopupWidget _gameOverPopup;

    /// Cup States
    enum CupState : int {
        /// New figure appears
        NewFigure,
        /// Game is paused
        Paused,
        /// Figure is falling
        FallingFigure,
        /// Figure is hanging - pause between falling by one row
        HangingFigure,
        /// destroying complete rows
        DestroyingRows,
        /// Game is over
        GameOver,
    }

    protected CupState _state;

    static const int[10] LEVEL_SPEED = [15000000, 10000000, 7000000, 6000000, 5000000, 4000000, 3500000, 3000000, 2500000, 2000000];


    static const int RESERVED_ROWS = 5; // reserved for next figure



    /// set difficulty level 1..10
    void setLevel(int level) {
        _level = level;
        _movementDuration = LEVEL_SPEED[level - 1];
    }

    void setCupState(CupState state, int animationIntervalPercent = 100, int maxProgress = 10000) {
        _state = state;
        if (animationIntervalPercent)
            _animation.start(_movementDuration * animationIntervalPercent / 100, maxProgress);
        invalidate();
    }

    /// returns true is widget is being animated - need to call animate() and redraw
    override @property bool animating() {
        switch (_state) {
            case CupState.NewFigure:
            case CupState.FallingFigure:
            case CupState.HangingFigure:
            case CupState.DestroyingRows:
                return true;
            default:
                return false;
        }
    }

    /// Turn on / off fast falling down
    bool handleFastDown(bool fast) {
        if (fast == true) {
            // handle turn on fast down
            if (_state == CupState.FallingFigure) {
                _fastDownFlag = true;
                _animation.interval = _movementDuration * 10 / 100; // increase speed
                return true;
            } else if (_state == CupState.HangingFigure) {
                _fastDownFlag = true;
                setCupState(CupState.FallingFigure, 10);
                return true;
            } else {
                return false;
            }
        }
        _fastDownFlag = fast;
        return true;
    }

    bool rotate(int angle) {
        FigurePosition newpos = _currentFigure.rotate(angle);
        if (_cup.isPositionFree(newpos)) {
            if (_state == CupState.FallingFigure) {
                // special handling for fall animation
                if (!_cup.isPositionFree(newpos.move(0, -1))) {
                    if (isPositionFreeBelow())
                        return false;
                }
            }
            _currentFigure = newpos;
            return true;
        } else if (_cup.isPositionFree(newpos.move(0, -1))) {
            _currentFigure = newpos.move(0, -1);
            return true;
        }
        return false;
    }

    bool move(int deltaX) {
        FigurePosition newpos = _currentFigure.move(deltaX);
        if (_cup.isPositionFree(newpos)) {
            if (_state == CupState.FallingFigure && !_cup.isPositionFree(newpos.move(0, -1))) {
                if (isPositionFreeBelow())
                    return false;
            }
            _currentFigure = newpos;
            return true;
        }
        return false;
    }

    protected void onAnimationFinished() {
        switch (_state) {
            case CupState.NewFigure:
                _fastDownFlag = false;
                genNextFigure();
                setCupState(CupState.HangingFigure, 75);
                break;
            case CupState.FallingFigure:
                if (isPositionFreeBelow()) {
                    _currentFigure.y--;
                    if (_fastDownFlag)
                        setCupState(CupState.FallingFigure, 10);
                    else
                        setCupState(CupState.HangingFigure, 75);
                } else {
                    // At bottom of cup
                    _cup.putFigure(_currentFigure);
                    _fastDownFlag = false;
                    if (!dropNextFigure()) {
                        // Game Over
                        setCupState(CupState.GameOver);
                        Widget popupWidget = new TextWidget("popup", "Game Over!"d);
                        popupWidget.padding(Rect(30, 30, 30, 30)).backgroundImageId("popup_background").alpha(0x40).fontWeight(800).fontSize(30);
                        _gameOverPopup = window.showPopup(popupWidget, this);
                    }
                }
                break;
            case CupState.HangingFigure:
                setCupState(CupState.FallingFigure, 25);
                break;
            case CupState.DestroyingRows:
                // TODO
                _fastDownFlag = false;
                break;
            default:
                break;
        }
    }

    /// animates window; interval is time left from previous draw, in hnsecs (1/10000000 of second)
    override void animate(long interval) {
        _animation.animate(interval);
        if (_animation.finished) {
            onAnimationFinished();
        }
    }

    void genNextFigure() {
        _nextFigure.index = uniform(FIGURE1, FIGURE6 + 1);
        _nextFigure.orientation = ORIENTATION0;
        _nextFigure.x = _cols / 2;
        _nextFigure.y = _rows - _nextFigure.shape.extent + 1;
    }

    bool dropNextFigure() {
        if (_nextFigure.index == 0)
            genNextFigure();
        _currentFigure = _nextFigure;
        _currentFigure.x = _cols / 2;
        _currentFigure.y = _rows - 1 - _currentFigure.shape.y0;
        setCupState(CupState.NewFigure, 100, 255);
        return isPositionFree();
    }

    void init(int cols, int rows) {
        _cup.init(cols, rows);
        _cols = cols;
        _rows = rows;
    }

    protected Rect cellRect(Rect rc, int col, int row) {
        int dx = rc.width / _cols;
        int dy = rc.height / (_rows + RESERVED_ROWS);
        int dd = dx;
        if (dd > dy)
            dd = dy;
        int x0 = rc.left + (rc.width - dd * _cols) / 2 + dd * col;
        int y0 = rc.bottom - (rc.height - dd * (_rows + RESERVED_ROWS)) / 2 - dd * row - dd;
        return Rect(x0, y0, x0 + dd, y0 + dd);
    }

    protected bool isPositionFree() {
        return _cup.isPositionFree(_currentFigure);
    }

    protected bool isPositionFreeBelow() {
        return _cup.isPositionFree(_currentFigure.move(0, -1));
    }

    /// Handle keys
    override bool onKeyEvent(KeyEvent event) {
        if (event.action == KeyAction.KeyDown && _state == CupState.GameOver) {
            newGame();
            return true;
        }
        if (event.keyCode == KeyCode.DOWN) {
            if (event.action == KeyAction.KeyDown) {
                handleFastDown(true);
            } else if (event.action == KeyAction.KeyUp) {
                handleFastDown(false);
            }
            return true;
        }
        if ((event.action == KeyAction.KeyDown || event.action == KeyAction.KeyUp) && event.keyCode != KeyCode.SPACE)
            handleFastDown(false); // don't stop fast down on Space key KeyUp
        return super.onKeyEvent(event);
    }

    /// draw cup cell
    protected void drawCell(DrawBuf buf, Rect cellRc, uint color) {
        cellRc.right--;
        cellRc.bottom--;
        int w = cellRc.width / 6;
        buf.drawFrame(cellRc, color, Rect(w,w,w,w));
        cellRc.shrink(w, w);
        color = addAlpha(color, 0xC0);
        buf.fillRect(cellRc, color);
    }

    /// draw figure
    protected void drawFigure(DrawBuf buf, Rect rc, FigurePosition figure, int dy, uint alpha = 0) {
        uint color = addAlpha(_figureColors[figure.index - 1], alpha);
        FigureShape shape = figure.shape;
        foreach(cell; shape.cells) {
            Rect cellRc = cellRect(rc, figure.x + cell.dx, figure.y + cell.dy);
            cellRc.top += dy;
            cellRc.bottom += dy;
            drawCell(buf, cellRc, color);
        }
    }

    /// Draw widget at its position to buffer
    override void onDraw(DrawBuf buf) {
        super.onDraw(buf);
        Rect rc = _pos;
        applyMargins(rc);
		auto saver = ClipRectSaver(buf, rc, alpha);
	    applyPadding(rc);

        Rect topLeft = cellRect(rc, 0, _rows - 1);
        Rect bottomRight = cellRect(rc, _cols - 1, 0);
        Rect cupRc = Rect(topLeft.left, topLeft.top, bottomRight.right, bottomRight.bottom);

        int fw = 7;
        int dw = 0;
        uint fcl = 0xA0606090;
        buf.fillRect(cupRc, 0xC0A0C0B0);
        buf.fillRect(Rect(cupRc.left - dw - fw, cupRc.top, cupRc.left - dw,       cupRc.bottom + dw), fcl);
        buf.fillRect(Rect(cupRc.right + dw,     cupRc.top, cupRc.right + dw + fw, cupRc.bottom + dw), fcl);
        buf.fillRect(Rect(cupRc.left - dw - fw, cupRc.bottom + dw, cupRc.right + dw + fw, cupRc.bottom + dw + fw), fcl);

        for (int row = 0; row < _rows; row++) {
            for (int col = 0; col < _cols; col++) {

                int value = _cup[col, row];
                Rect cellRc = cellRect(rc, col, row);

                Point middle = cellRc.middle;
                buf.fillRect(Rect(middle.x - 1, middle.y - 1, middle.x + 1, middle.y + 1), 0x80404040);

                if (value != EMPTY) {
                    uint cl = _figureColors[value - 1];
                    drawCell(buf, cellRc, cl);
                }
            }
        }

        // draw current figure falling
        if (_state == CupState.FallingFigure || _state == CupState.HangingFigure) {
            int dy = 0;
            if (_state == CupState.FallingFigure && isPositionFreeBelow()) {
                dy = _animation.getProgress(topLeft.height);
            }
            drawFigure(buf, rc, _currentFigure, dy, 0);
        }


        if (_nextFigure.index != 0) {
            //auto shape = _nextFigure.shape;
            uint nextFigureAlpha = 0;
            if (_state == CupState.NewFigure) {
                nextFigureAlpha = _animation.progress;
                drawFigure(buf, rc, _currentFigure, 0, 255 - nextFigureAlpha);
            }
            if (_state != CupState.GameOver) {
                drawFigure(buf, rc, _nextFigure, 0, blendAlpha(0xA0, nextFigureAlpha));
            }
        }

    }
    /// Measure widget according to desired width and height constraints. (Step 1 of two phase layout).
    override void measure(int parentWidth, int parentHeight) { 
        /// fixed size 350 x 550
        measuredContent(parentWidth, parentHeight, 350, 550);
    }

	/// override to handle specific actions
	override bool handleAction(const Action a) {
        switch (a.id) {
            case TetrisAction.MoveLeft:
                move(-1);
                return true;
            case TetrisAction.MoveRight:
                move(1);
                return true;
            case TetrisAction.RotateCCW:
                rotate(1);
                return true;
            case TetrisAction.FastDown:
                handleFastDown(true);
                return true;
            default:
                if (parent) // by default, pass to parent widget
                    return parent.handleAction(a);
                return false;
        }
	}

    void newGame() {
        setLevel(1);
        init(_cols, _rows);
        dropNextFigure();
        if (window && _gameOverPopup) {
            window.removePopup(_gameOverPopup);
            _gameOverPopup = null;
        }
    }

    this() {
        super("CUP");
        layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT).layoutWeight(3);
        setState(State.Default);
        backgroundColor = 0xC0808080;
        padding(Rect(20, 20, 20, 20));
        _cols = 11;
        _rows = 15;
        newGame();

        focusable = true;

		acceleratorMap.add( [
			new Action(TetrisAction.MoveLeft,  KeyCode.LEFT, 0),
			new Action(TetrisAction.MoveRight, KeyCode.RIGHT, 0),
			new Action(TetrisAction.RotateCCW, KeyCode.UP, 0),
			new Action(TetrisAction.FastDown,  KeyCode.SPACE, 0),
		]);

    }
}

class StatusWidget : VerticalLayout {
    TextWidget _score;
    TextWidget _lblNext;
    this() {
        super("CUP_STATUS");
        _score = new TextWidget("SCORE", "Score: 0"d);
        _lblNext = new TextWidget("NEXT", "Next:"d);
        backgroundColor = 0xC080FF80;
        addChild(_score);
        addChild(_lblNext);
        layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT).layoutWeight(2);
        padding(Rect(20, 20, 20, 20));
    }
    /// Measure widget according to desired width and height constraints. (Step 1 of two phase layout).
    override void measure(int parentWidth, int parentHeight) { 
        super.measure(parentWidth, parentHeight);
        /// fixed size 350 x 550
        measuredContent(parentWidth, parentHeight, 150, 550);
    }
}

class CupPage : HorizontalLayout {
    CupWidget _cup;
    StatusWidget _status;
    this() {
        super("CUP_PAGE");
        layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT);
        _cup = new CupWidget();
        _status = new StatusWidget();
        addChild(_cup);
        addChild(_status);
    }
    /// Measure widget according to desired width and height constraints. (Step 1 of two phase layout).
    override void measure(int parentWidth, int parentHeight) { 
        super.measure(parentWidth, parentHeight);
        /// fixed size 350 x 550
        measuredContent(parentWidth, parentHeight, 500, 550);
    }
}

//FrameLayout
class GameWidget : HorizontalLayout {

    CupPage _cupPage;
    this() {
        super("GAME");
        _cupPage = new CupPage();
        addChild(_cupPage);
        //showChild(_cupPage.id, Visibility.Invisible, true);
		backgroundImageId = "tx_fabric.tiled";
    }
    /// Measure widget according to desired width and height constraints. (Step 1 of two phase layout).
    override void measure(int parentWidth, int parentHeight) {
        super.measure(parentWidth, parentHeight);
        measuredContent(parentWidth, parentHeight, 500, 550);
    }
}

enum : int {
    ACTION_FILE_OPEN = 5500,
    ACTION_FILE_SAVE,
    ACTION_FILE_CLOSE,
    ACTION_FILE_EXIT,
}

/// entry point for dlangui based application
extern (C) int UIAppMain(string[] args) {

    //auto power2 = delegate(int X) { return X * X; };
    auto power2 = (int X) => X * X;

    // resource directory search paths
    string[] resourceDirs = [
        	appendPath(exePath, "../../../res/"),   // for Visual D and DUB builds
	        appendPath(exePath, "../../../res/mdpi/"),   // for Visual D and DUB builds
	        appendPath(exePath, "../../../../res/"),// for Mono-D builds
	        appendPath(exePath, "../../../../res/mdpi/"),// for Mono-D builds
		appendPath(exePath, "res/"), // when res dir is located at the same directory as executable
		appendPath(exePath, "../res/"), // when res dir is located at project directory
		appendPath(exePath, "../../res/"), // when res dir is located at the same directory as executable
		appendPath(exePath, "res/mdpi/"), // when res dir is located at the same directory as executable
		appendPath(exePath, "../res/mdpi/"), // when res dir is located at project directory
		appendPath(exePath, "../../res/mdpi/") // when res dir is located at the same directory as executable
	];

    // setup resource directories - will use only existing directories
	Platform.instance.resourceDirs = resourceDirs;
    // select translation file - for english language
	Platform.instance.uiLanguage = "en";
	// load theme from file "theme_default.xml"
	Platform.instance.uiTheme = "theme_default";

    //drawableCache.get("tx_fabric.tiled");

    // create window
    Window window = Platform.instance.createWindow("DLangUI: Tetris game example", null, WindowFlag.Modal);

    GameWidget game = new GameWidget();

    window.mainWidget = game;

    window.windowIcon = drawableCache.getImage("dtetris-logo1");

    window.show();

    // run message loop
    return Platform.instance.enterMessageLoop();
}
