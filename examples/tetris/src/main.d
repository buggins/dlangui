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

class CupWidget : Widget {

    this() {
        super("CUP");
    }

    /// Draw widget at its position to buffer
    override void onDraw(DrawBuf buf) {
        super.onDraw(buf);
    }
}

class StatusWidget : VerticalLayout {

}

class CupPage : HorizontalLayout {
    CupWidget _cup;
    this() {
        super("CUP_PAGE");
        setState(State.Default);
        _cup = new CupWidget();
        addChild(_cup);
    }
}

class GameWidget : FrameLayout {

    CupPage _cupPage;
    this() {
        super("GAME");
        _cupPage = new CupPage();
        showChild(_cupPage.id, Visibility.Invisible, true);
		backgroundImageId = "tx_fabric.tiled";
    }
    /// Measure widget according to desired width and height constraints. (Step 1 of two phase layout).
    override void measure(int parentWidth, int parentHeight) { 
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
