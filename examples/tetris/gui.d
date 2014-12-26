module gui;

import dlangui.all;
import dlangui.widgets.popup;
import dlangui.graphics.drawbuf;
//import std.stdio;
import std.conv;
import std.utf;
import model;


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

enum TetrisAction : int {
    MoveLeft = 10000,
    MoveRight,
    RotateCCW,
    FastDown,
    Pause,
    LevelUp,
}


/// Cup widget
class CupWidget : Widget {
    /// cup columns count
    int _cols;
    /// cup rows count
    int _rows;
    /// cup data
    Cup _cup;


    /// Level 1..10
    int _level;
    /// Score
    int _score;
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
        /// falling after some rows were destroyed
        FallingRows,
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
        _status.setLevel(_level);
    }

    static const int MIN_FAST_FALLING_INTERVAL = 600000;
    static const int ROWS_FALLING_INTERVAL = 600000;

    void setCupState(CupState state) {
        int animationIntervalPercent = 100;
        switch (state) {
            case CupState.FallingFigure:
                animationIntervalPercent = _fastDownFlag ? 10 : 25;
                break;
            case CupState.HangingFigure:
                animationIntervalPercent = 75;
                break;
            case CupState.NewFigure:
                animationIntervalPercent = 100;
                break;
            case CupState.FallingRows:
                animationIntervalPercent = 25;
                break;
            case CupState.DestroyingRows:
                animationIntervalPercent = 50;
                break;
            default:
                break;
        }
        _state = state;
        if (animationIntervalPercent) {
            long interval = _movementDuration * animationIntervalPercent / 100;
            if (_fastDownFlag && falling && interval > MIN_FAST_FALLING_INTERVAL)
                interval = MIN_FAST_FALLING_INTERVAL;
            if (_state == CupState.FallingRows)
                interval = ROWS_FALLING_INTERVAL;
            _animation.start(interval, 255);
        }
        invalidate();
    }

    /// returns true is widget is being animated - need to call animate() and redraw
    override @property bool animating() {
        switch (_state) {
            case CupState.NewFigure:
            case CupState.FallingFigure:
            case CupState.HangingFigure:
            case CupState.DestroyingRows:
            case CupState.FallingRows:
                return true;
            default:
                return false;
        }
    }

    /// Turn on / off fast falling down
    bool handleFastDown(bool fast) {
        if (fast == true) {
            if (_fastDownFlag)
                return false;
            // handle turn on fast down
            if (falling) {
                _fastDownFlag = true;
                // if already falling, just increase speed
                _animation.interval = _movementDuration * 10 / 100;
                if (_animation.interval > MIN_FAST_FALLING_INTERVAL)
                    _animation.interval = MIN_FAST_FALLING_INTERVAL;
                return true;
            } else if (_state == CupState.HangingFigure) {
                _fastDownFlag = true;
                setCupState(CupState.FallingFigure);
                return true;
            } else {
                return false;
            }
        }
        _fastDownFlag = fast;
        return true;
    }

    /// try start next figure
    protected void nextFigure() {
        if (!_cup.dropNextFigure()) {
            // Game Over
            setCupState(CupState.GameOver);
            Widget popupWidget = new TextWidget("popup", "Game Over!"d);
            popupWidget.padding(Rect(30, 30, 30, 30)).backgroundImageId("popup_background").alpha(0x40).fontWeight(800).fontSize(30);
            _gameOverPopup = window.showPopup(popupWidget, this);
        } else {
            setCupState(CupState.NewFigure);
        }
    }

    protected void destroyFullRows() {
        setCupState(CupState.DestroyingRows);
    }

    protected void onAnimationFinished() {
        switch (_state) {
            case CupState.NewFigure:
                _fastDownFlag = false;
                _cup.genNextFigure();
                setCupState(CupState.HangingFigure);
                break;
            case CupState.FallingFigure:
                if (_cup.isPositionFreeBelow()) {
                    _cup.move(0, -1, false);
                    if (_fastDownFlag)
                        setCupState(CupState.FallingFigure);
                    else
                        setCupState(CupState.HangingFigure);
                } else {
                    // At bottom of cup
                    _cup.putFigure();
                    _fastDownFlag = false;
                    if (_cup.hasFullRows) {
                        destroyFullRows();
                    } else {
                        nextFigure();
                    }
                }
                break;
            case CupState.HangingFigure:
                setCupState(CupState.FallingFigure);
                break;
            case CupState.DestroyingRows:
                int rowsDestroyed = _cup.destroyFullRows();
                int scorePerRow = 0;
                for (int i = 0; i < rowsDestroyed; i++) {
                    scorePerRow += 10;
                    addScore(scorePerRow);
                }
                if (_cup.markFallingCells()) {
                    setCupState(CupState.FallingRows);
                } else {
                    nextFigure();
                }
                break;
            case CupState.FallingRows:
                if (_cup.moveFallingCells()) {
                    // more cells to fall
                    setCupState(CupState.FallingRows);
                } else {
                    // no more cells to fall, next figure
                    if (_cup.hasFullRows) {
                        // new full rows were constructed: destroy
                        destroyFullRows();
                    } else {
                        // next figure
                        nextFigure();
                    }
                }
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

    /// Handle keys
    override bool onKeyEvent(KeyEvent event) {
        if (event.action == KeyAction.KeyDown && _state == CupState.GameOver) {
            // restart game
            newGame();
            return true;
        }
        if (event.action == KeyAction.KeyDown && _state == CupState.NewFigure) {
            // stop new figure fade in if key is pressed
            onAnimationFinished();
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
    protected void drawCell(DrawBuf buf, Rect cellRc, uint color, int offset = 0) {
        cellRc.top += offset;
        cellRc.bottom += offset;

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

        int fallingCellOffset = 0;
        if (_state == CupState.FallingRows) {
            fallingCellOffset = _animation.getProgress(topLeft.height);
        }

        for (int row = 0; row < _rows; row++) {
            uint cellAlpha = 0;
            if (_state == CupState.DestroyingRows && _cup.isRowFull(row))
                cellAlpha = _animation.progress;
            for (int col = 0; col < _cols; col++) {

                int value = _cup[col, row];
                Rect cellRc = cellRect(rc, col, row);

                Point middle = cellRc.middle;
                buf.fillRect(Rect(middle.x - 1, middle.y - 1, middle.x + 1, middle.y + 1), 0x80404040);

                if (value != EMPTY) {
                    uint cl = addAlpha(_figureColors[value - 1], cellAlpha);
                    int offset = fallingCellOffset > 0 && _cup.isCellFalling(col, row) ? fallingCellOffset : 0;
                    drawCell(buf, cellRc, cl, offset);
                }
            }
        }

        // draw current figure falling
        if (_state == CupState.FallingFigure || _state == CupState.HangingFigure) {
            int dy = 0;
            if (falling && _cup.isPositionFreeBelow())
                dy = _animation.getProgress(topLeft.height);
            drawFigure(buf, rc, _cup.currentFigure, dy, 0);
        }

        // draw next figure
        if (_cup.hasNextFigure) {
            //auto shape = _nextFigure.shape;
            uint nextFigureAlpha = 0;
            if (_state == CupState.NewFigure) {
                nextFigureAlpha = _animation.progress;
                drawFigure(buf, rc, _cup.currentFigure, 0, 255 - nextFigureAlpha);
            }
            if (_state != CupState.GameOver) {
                drawFigure(buf, rc, _cup.nextFigure, 0, blendAlpha(0xA0, nextFigureAlpha));
            }
        }

    }
    /// Measure widget according to desired width and height constraints. (Step 1 of two phase layout).
    override void measure(int parentWidth, int parentHeight) {
        /// fixed size 350 x 550
        measuredContent(parentWidth, parentHeight, 350, 550);
    }

    @property bool falling() {
        return _state == CupState.FallingFigure;
    }

	/// override to handle specific actions
	override bool handleAction(const Action a) {
        switch (a.id) {
            case TetrisAction.MoveLeft:
                _cup.move(-1, 0, falling);
                return true;
            case TetrisAction.MoveRight:
                _cup.move(1, 0, falling);
                return true;
            case TetrisAction.RotateCCW:
                _cup.rotate(1, falling);
                return true;
            case TetrisAction.FastDown:
                handleFastDown(true);
                return true;
            case TetrisAction.Pause:
                // TODO: implement pause
                return true;
            case TetrisAction.LevelUp:
                if (_level < 10)
                    _level++;
                // TODO: update state
                return true;
            default:
                if (parent) // by default, pass to parent widget
                    return parent.handleAction(a);
                return false;
        }
	}

    void addScore(int score) {
        _score += score;
        _status.setScore(_score);
    }

    /// start new game
    void newGame() {
        setLevel(1);
        _score = 0;
        init(_cols, _rows);
        _cup.dropNextFigure();
        setCupState(CupState.NewFigure);
        if (window && _gameOverPopup) {
            window.removePopup(_gameOverPopup);
            _gameOverPopup = null;
        }
        _status.setScore(_score);
    }

    private StatusWidget _status;
    this(StatusWidget status) {
        super("CUP");
        this._status = status;
        layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT).layoutWeight(3);
        setState(State.Default);
        //backgroundColor = 0xC0808080;
        padding(Rect(20, 20, 20, 20));
        _cols = 11;
        _rows = 15;
        newGame();

        focusable = true;

		acceleratorMap.add( [
			(new Action(TetrisAction.MoveLeft,  KeyCode.LEFT)).addAccelerator(KeyCode.KEY_A),
			(new Action(TetrisAction.MoveRight, KeyCode.RIGHT)).addAccelerator(KeyCode.KEY_D),
			(new Action(TetrisAction.RotateCCW, KeyCode.UP)).addAccelerator(KeyCode.KEY_W),
			(new Action(TetrisAction.FastDown,  KeyCode.SPACE)).addAccelerator(KeyCode.KEY_S),
			(new Action(TetrisAction.Pause,     KeyCode.ESCAPE)).addAccelerator(KeyCode.PAUSE),
			(new Action(TetrisAction.LevelUp,   KeyCode.ADD)).addAccelerator(KeyCode.INS),
		]);

    }
}

/// Panel to show game status
class StatusWidget : VerticalLayout {
    private TextWidget _level;
    private TextWidget _score;
    private CupWidget _cup;
    void setCup(CupWidget cup) {
        _cup = cup;
    }
    TextWidget createTextWidget(dstring str, uint color) {
        TextWidget res = new TextWidget(null, str);
        res.layoutWidth(FILL_PARENT).alignment(Align.Center);
        res.fontSize(30);
        res.textColor(color);
        return res;
    }
    this() {
        super("CUP_STATUS");
        //backgroundColor = 0xC080FF80;
        addChild(new VSpacer());
        addChild(new ImageWidget(null, "tetris_logo_big"));
        addChild(new VSpacer());
        addChild(createTextWidget("Level:"d, 0x008000));
        addChild((_level = createTextWidget(""d, 0x008000)));
        addChild(new VSpacer());
        addChild(createTextWidget("Score:"d, 0x800000));
        addChild((_score = createTextWidget(""d, 0x800000)));
        addChild(new VSpacer());
        addChild(new VSpacer());
        layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT).layoutWeight(2);
        padding(Rect(20, 20, 20, 20));
    }

    void setLevel(int level) {
        _level.text = toUTF32(to!string(level));
    }

    void setScore(int score) {
        _score.text = toUTF32(to!string(score));
    }

    /// Measure widget according to desired width and height constraints. (Step 1 of two phase layout).
    override void measure(int parentWidth, int parentHeight) { 
        super.measure(parentWidth, parentHeight);
        /// fixed size 350 x 550
        measuredContent(parentWidth, parentHeight, 150, 550);
    }
    override bool handleAction(const Action a) {
        return _cup.handleAction(a);
    }
}

class CupPage : HorizontalLayout {
    CupWidget _cup;
    StatusWidget _status;
    this() {
        super("CUP_PAGE");
        layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT);
        _status = new StatusWidget();
        _cup = new CupWidget(_status);
        _status.setCup(_cup);
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
