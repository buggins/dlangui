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
import dlangui.dialogs.dialog;
import dlangui.dialogs.filedlg;
import dlangui.dialogs.msgbox;
import std.stdio;
import std.conv;
import std.utf;


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

class AnimatedDrawable : Drawable {
	DrawableRef background;
	this() {
		background = drawableCache.get("tx_fabric.tiled");
	}
	void drawAnimatedRect(DrawBuf buf, uint p, Rect rc, int speedx, int speedy, int sz) {
		int x = (p * speedx % rc.width);
		int y = (p * speedy % rc.height);
		if (x < 0)
			x += rc.width;
		if (y < 0)
			y += rc.height;
		uint a = 64 + ((p / 2) & 0x7F);
		uint r = 128 + ((p / 7) & 0x7F);
		uint g = 128 + ((p / 5) & 0x7F);
		uint b = 128 + ((p / 3) & 0x7F);
		uint color = (a << 24) | (r << 16) | (g << 8) | b;
		buf.fillRect(Rect(rc.left + x, rc.top + y, rc.left + x + sz, rc.top + y + sz), color);
	}
	void drawAnimatedIcon(DrawBuf buf, uint p, Rect rc, int speedx, int speedy, string resourceId) {
		int x = (p * speedx % rc.width);
		int y = (p * speedy % rc.height);
		if (x < 0)
			x += rc.width;
		if (y < 0)
			y += rc.height;
		DrawBufRef image = drawableCache.getImage(resourceId);
		buf.drawImage(x, y, image.get);
	}
	override void drawTo(DrawBuf buf, Rect rc, uint state = 0, int tilex0 = 0, int tiley0 = 0) {
		background.drawTo(buf, rc, state, cast(int)(animationProgress / 695430), cast(int)(animationProgress / 1500000));
		drawAnimatedRect(buf, cast(uint)(animationProgress / 295430), rc, 2, 3, 100);
		drawAnimatedRect(buf, cast(uint)(animationProgress / 312400) + 100, rc, 3, 2, 130);
		drawAnimatedIcon(buf, cast(uint)(animationProgress / 212400) + 200, rc, -2, 1, "dlangui-logo1");
		drawAnimatedRect(buf, cast(uint)(animationProgress / 512400) + 300, rc, 2, -2, 200);
		drawAnimatedRect(buf, cast(uint)(animationProgress / 214230) + 800, rc, 1, 2, 390);
		drawAnimatedIcon(buf, cast(uint)(animationProgress / 123320) + 900, rc, 1, 2, "cr3_logo");
		drawAnimatedRect(buf, cast(uint)(animationProgress / 100000) + 100, rc, -1, -1, 120);
	}
	@property override int width() {
		return 1;
	}
	@property override int height() {
		return 1;
	}
	ulong animationProgress;
	void animate(long interval) {
		animationProgress += interval;
	}

}

class SampleAnimationWidget : VerticalLayout {
	AnimatedDrawable drawable;
	DrawableRef drawableRef;
	this(string ID) {
		super(ID);
		drawable = new AnimatedDrawable();
		drawableRef = drawable;
		padding = Rect(20, 20, 20, 20);
		addChild(new TextWidget(null, "This is TextWidget on top of animated background"d));
		addChild(new EditLine(null, "This is EditLine on top of animated background"d));
		addChild(new Button(null, "This is Button on top of animated background"d));
		addChild(new VSpacer());
	}

	/// background drawable
	@property override DrawableRef backgroundDrawable() const {
		return (cast(SampleAnimationWidget)this).drawableRef;
	}
	
	/// returns true is widget is being animated - need to call animate() and redraw
	@property override bool animating() { return true; }
	/// animates window; interval is time left from previous draw, in hnsecs (1/10000000 of second)
	override void animate(long interval) {
		drawable.animate(interval);
		invalidate();
	}
}

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

struct FigureShape {
    // by cell index 0..3
    FigureCell[4] cells; 
    // number of cells lowest item is below 0,0 cell
    int extent;
    this(int[2] c1, int[2] c2, int[2] c3, int[2] c4) {
        cells[0] = FigureCell(c1);
        cells[1] = FigureCell(c2);
        cells[2] = FigureCell(c3);
        cells[3] = FigureCell(c4);
        extent = 0;
        for (int i = 0; i < 4; i++)
            if (extent > cells[i].dy)
                extent = cells[i].dy;
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

class CupWidget : Widget {

    int _cols;
    int _rows;
    int[] _cup;

    static const int RESERVED_ROWS = 4; // reserved for next figure
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

    enum : int {
        ORIENTATION0,
        ORIENTATION90,
        ORIENTATION180,
        ORIENTATION270
    }

    static const uint[] _figureColors = [0xFF0000, 0xFFFF00, 0xFF00FF, 0x0000FF, 0x800000, 0x408000, 0x000080];

    this() {
        super("CUP");
        layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT).layoutWeight(3);
        backgroundColor = 0xC0808080;
        padding(Rect(20, 20, 20, 20));
        init(10, 15);

        setCell(1, 1, FIGURE1);
        setCell(3, 3, FIGURE2);
        setCell(4, 4, FIGURE3);
        setCell(6, 4, FIGURE4);
        setCell(7, 4, FIGURE5);
        setCell(4, 5, FIGURE6);
        setCell(4, 6, FIGURE7);
    }

    void init(int cols, int rows) {
        _cols = cols;
        _rows = rows;
        _cup = new int[_cols * _rows];
        for (int i = 0; i < _cup.length; i++)
            _cup[i] = EMPTY;
    }

    protected int cell(int col, int row) {
        if (col < 0 || row < 0 || col >= _cols || row >= _rows)
            return WALL;
        return _cup[row * _cols + col];
    }

    protected void setCell(int col, int row, int value) {
        _cup[row * _cols + col] = value;
        invalidate();
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

    protected void drawCell(DrawBuf buf, Rect cellRc, uint color) {
        cellRc.right--;
        cellRc.bottom--;
        int w = cellRc.width / 6;
        buf.drawFrame(cellRc, color, Rect(w,w,w,w));
        cellRc.shrink(w, w);
        color = (color & 0xFFFFFF) | 0xC0000000;
        buf.fillRect(cellRc, color);
    }

    protected void drawFigure(DrawBuf buf, Rect rc, int figureIndex, int orientation, int x, int y, int dy) {
        uint color = _figureColors[figureIndex];
        FigureShape shape = FIGURES[figureIndex].shapes[orientation];
        for (int i = 0; i < 4; i++) {
            Rect cellRc = cellRect(rc, x + shape.cells[i].dx, y + shape.cells[i].dy);
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

        int fw = 3;
        uint fcl = 0x80000060;
        buf.fillRect(cupRc, 0x80A0C0B0);
        buf.fillRect(Rect(cupRc.left - 1 - fw, cupRc.top, cupRc.left - 1,       cupRc.bottom + 2), fcl);
        buf.fillRect(Rect(cupRc.right + 2,     cupRc.top, cupRc.right + 2 + fw, cupRc.bottom + 2), fcl);
        buf.fillRect(Rect(cupRc.left - 1 - fw, cupRc.bottom + 2, cupRc.right + 2 + fw, cupRc.bottom + 2 + fw), fcl);

        for (int row = 0; row < _rows; row++) {
            for (int col = 0; col < _cols; col++) {
                int value = cell(col, row);
                Rect cellRc = cellRect(rc, col, row);

                Point middle = cellRc.middle;
                buf.fillRect(Rect(middle.x - 1, middle.y - 1, middle.x + 1, middle.y + 1), 0x404040);
                if (value != EMPTY) {
                    uint cl = _figureColors[value - 1];
                    drawCell(buf, cellRc, cl);
                }
            }
        }

        drawFigure(buf, rc, 0, 0, 2, 9, 0);
        drawFigure(buf, rc, 2, 1, 6, 8, 0);

    }
    /// Measure widget according to desired width and height constraints. (Step 1 of two phase layout).
    override void measure(int parentWidth, int parentHeight) { 
        measuredContent(parentWidth, parentHeight, 300, 550);
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
}

class CupPage : HorizontalLayout {
    CupWidget _cup;
    StatusWidget _status;
    this() {
        super("CUP_PAGE");
        layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT);
        setState(State.Default);
        _cup = new CupWidget();
        _status = new StatusWidget();
        addChild(_cup);
        addChild(_status);
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
        measuredContent(parentWidth, parentHeight, 400, 600);
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
