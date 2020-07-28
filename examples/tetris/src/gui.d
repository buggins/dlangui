module gui;

import model;

import dlangui;
import std.algorithm;

/// game action codes
enum TetrisAction : int {
    MoveLeft = 10000,
    MoveRight,
    RotateCCW,
    FastDown,
    Pause,
    LevelUp,
}

const Action ACTION_MOVE_LEFT   = (new Action(TetrisAction.MoveLeft,  KeyCode.LEFT)).addAccelerator(KeyCode.KEY_A).iconId("arrow-left");
const Action ACTION_MOVE_RIGHT  = (new Action(TetrisAction.MoveRight, KeyCode.RIGHT)).addAccelerator(KeyCode.KEY_D).iconId("arrow-right");
const Action ACTION_ROTATE      = (new Action(TetrisAction.RotateCCW, KeyCode.UP)).addAccelerator(KeyCode.KEY_W).iconId("rotate");
const Action ACTION_FAST_DOWN   = (new Action(TetrisAction.FastDown,  KeyCode.SPACE)).addAccelerator(KeyCode.KEY_S).iconId("arrow-down");
const Action ACTION_PAUSE       = (new Action(TetrisAction.Pause,     KeyCode.ESCAPE)).addAccelerator(KeyCode.PAUSE).iconId("pause");
const Action ACTION_LEVEL_UP    = (new Action(TetrisAction.LevelUp,   KeyCode.ADD)).addAccelerator(KeyCode.INS).iconId("levelup");

const Action[] CUP_ACTIONS = [ACTION_PAUSE,     ACTION_ROTATE,      ACTION_LEVEL_UP,
                              ACTION_MOVE_LEFT, ACTION_FAST_DOWN,   ACTION_MOVE_RIGHT];

/// about dialog
Widget createAboutWidget()
{
    LinearLayout res = new VerticalLayout();
    res.padding(Rect(10,10,10,10));
    res.addChild(new TextWidget(null, "DLangUI Tetris demo app"d));
    res.addChild(new TextWidget(null, "(C) Vadim Lopatin, 2014"d));
    res.addChild(new TextWidget(null, "http://github.com/buggins/dlangui"d));
    Button closeButton = new Button("close", "Close"d);
    closeButton.click = delegate(Widget src) {
        Log.i("Closing window");
        res.window.close();
        return true;
    };
    res.addChild(closeButton);
    return res;
}

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
    /// animation helper for fade and movement in different states
    AnimationHelper _animation;
    /// GameOver popup
    private PopupWidget _gameOverPopup;
    /// Status widget
    private StatusWidget _status;
    /// Current state
    protected CupState _state;

    protected int _totalRowsDestroyed;

    static const int[10] LEVEL_SPEED = [15000000, 10000000, 7000000, 6000000, 5000000, 4000000, 3000000, 2000000, 1500000, 1000000];

    static const int RESERVED_ROWS = 5; // reserved for next figure

    /// set difficulty level 1..10
    void setLevel(int level) {
        if (level > 10)
            return;
        _level = level;
        _movementDuration = LEVEL_SPEED[level - 1];
        _status.setLevel(_level);
    }

    static const int MIN_FAST_FALLING_INTERVAL = 600000;

    static const int ROWS_FALLING_INTERVAL = 1200000;

    /// change game state, init state animation when necessary
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
                // no animation for other states
                animationIntervalPercent = 0;
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

    void addScore(int score) {
        _score += score;
        _status.setScore(_score);
    }

    /// returns true if figure is in falling - movement state
    @property bool falling() {
        return _state == CupState.FallingFigure;
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

    static const int[] NEXT_LEVEL_SCORE = [0, 20, 50, 100, 200, 350, 500, 750, 1000, 1500, 2000];

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
            if (_level < 10 && _totalRowsDestroyed >= NEXT_LEVEL_SCORE[_level])
                setLevel(_level + 1); // level up
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
                _totalRowsDestroyed += rowsDestroyed;
                _status.setRowsDestroyed(_totalRowsDestroyed);
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

    /// start new game
    void newGame() {
        setLevel(1);
        initialize(_cols, _rows);
        _cup.dropNextFigure();
        setCupState(CupState.NewFigure);
        if (window && _gameOverPopup) {
            window.removePopup(_gameOverPopup);
            _gameOverPopup = null;
        }
        _score = 0;
        _status.setScore(0);
        _totalRowsDestroyed = 0;
        _status.setRowsDestroyed(0);
    }

    /// init cup
    void initialize(int cols, int rows) {
        _cup.initialize(cols, rows);
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

    //=================================================================================================
    // Overrides of Widget methods

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

    /// animates window; interval is time left from previous draw, in hnsecs (1/10000000 of second)
    override void animate(long interval) {
        _animation.animate(interval);
        if (_animation.finished) {
            onAnimationFinished();
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
                setLevel(_level + 1);
                return true;
            default:
                if (parent) // by default, pass to parent widget
                    return parent.handleAction(a);
                return false;
        }
    }

    /// Measure widget according to desired width and height constraints. (Step 1 of two phase layout).
    override void measure(int parentWidth, int parentHeight) {
        measuredContent(parentWidth, parentHeight, parentWidth * 3 / 5, parentHeight);
    }

    this(StatusWidget status) {
        super("CUP");
        this._status = status;
        layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT).layoutWeight(2).setState(State.Default).focusable(true).padding(Rect(20, 20, 20, 20));

        _cols = 10;
        _rows = 18;
        newGame();

        focusable = true;

        acceleratorMap.add(CUP_ACTIONS);
    }
}

/// Panel to show game status
class StatusWidget : VerticalLayout {
    private TextWidget _level;
    private TextWidget _rowsDestroyed;
    private TextWidget _score;
    private CupWidget _cup;
    private TextWidget[] _labels;
    void setCup(CupWidget cup) {
        _cup = cup;
    }
    TextWidget createTextWidget(dstring str, uint color) {
        TextWidget res = new TextWidget(null, str);
        res.layoutWidth(FILL_PARENT).alignment(Align.Center).fontSize(18.pointsToPixels).textColor(color);
        _labels ~= res;
        return res;
    }

    Widget createControls() {
        TableLayout res = new TableLayout();
        res.colCount = 3;
        foreach(const Action a; CUP_ACTIONS) {
            ImageButton btn = new ImageButton(a);
            btn.padding = 5.pointsToPixels;
            btn.focusable = false;
            res.addChild(btn);
        }
        res.alignment = Align.Center;
        res.layoutWidth(WRAP_CONTENT).layoutHeight(WRAP_CONTENT).margins(Rect(5.pointsToPixels, 5.pointsToPixels, 5.pointsToPixels, 5.pointsToPixels)).alignment(Align.Center);
        return res;
    }

    this() {
        super("CUP_STATUS");

        addChild(new VSpacer());

        ImageWidget image = new ImageWidget(null, "tetris_logo_big");
        image.layoutWidth(FILL_PARENT).alignment(Align.Center).clickable(true);
        image.click = delegate(Widget src) {
            _cup.handleAction(ACTION_PAUSE);
            // about dialog when clicking on image
            Window wnd = Platform.instance.createWindow("About...", window, WindowFlag.Modal);
            wnd.mainWidget = createAboutWidget();
            wnd.show();
            return true;
        };
        addChild(image);

        addChild(new VSpacer());
        addChild(createTextWidget("Level:"d, 0x008000));
        addChild((_level = createTextWidget(""d, 0x008000)));
        addChild(new VSpacer());
        addChild(createTextWidget("Rows:"d, 0x202080));
        addChild((_rowsDestroyed = createTextWidget(""d, 0x202080)));
        addChild(new VSpacer());
        addChild(createTextWidget("Score:"d, 0x800000));
        addChild((_score = createTextWidget(""d, 0x800000)));
        addChild(new VSpacer());
        HorizontalLayout h = new HorizontalLayout();
        h.layoutWidth = FILL_PARENT;
        h.layoutHeight = FILL_PARENT;
        h.addChild(new HSpacer());
        h.addChild(createControls());
        h.addChild(new HSpacer());
        addChild(h);
        addChild(new VSpacer());

        layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT).layoutWeight(2).padding(Rect(5.pointsToPixels, 5.pointsToPixels, 5.pointsToPixels, 5.pointsToPixels));
    }

    /// Measure widget according to desired width and height constraints. (Step 1 of two phase layout).
    override void measure(int parentWidth, int parentHeight) {
        import std.algorithm: min;
        int minw = min(parentWidth, parentHeight);
        foreach(lbl; _labels) {
            lbl.fontSize = minw / 20;
        }
        super.measure(parentWidth, parentHeight);
    }

    void setLevel(int level) {
        _level.text = toUTF32(to!string(level));
    }

    void setScore(int score) {
        _score.text = toUTF32(to!string(score));
    }

    void setRowsDestroyed(int rows) {
        _rowsDestroyed.text = toUTF32(to!string(rows));
    }

    override bool handleAction(const Action a) {
        return _cup.handleAction(a);
    }
}

/// Cup page: cup widget + status widget
class CupPage : HorizontalLayout {
    CupWidget _cup;
    StatusWidget _status;
    this() {
        super("CUP_PAGE");
        layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT);
        _status = new StatusWidget();
        _cup = new CupWidget(_status);
        _status.setCup(_cup);
        _cup.layoutWidth = 50.makePercentSize;
        _status.layoutWidth = 50.makePercentSize;
        addChild(_cup);
        addChild(_status);
    }
    /// Measure widget according to desired width and height constraints. (Step 1 of two phase layout).
    override void measure(int parentWidth, int parentHeight) {
        super.measure(parentWidth, parentHeight);
        /// fixed size
        measuredContent(parentWidth, parentHeight, 600, 550);
    }
}

//
class GameWidget : FrameLayout {

    CupPage _cupPage;
    this() {
        super("GAME");
        _cupPage = new CupPage();
        addChild(_cupPage);
        //showChild(_cupPage.id, Visibility.Invisible, true);
        backgroundImageId = "tx_fabric.tiled";
    }
}
