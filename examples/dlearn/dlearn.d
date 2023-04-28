module dlearn;

import dlangui;
import dlangui.core.logger;
import dlangui.dialogs.filedlg;
import dlangui.dialogs.dialog;
import dlangui.dml.dmlhighlight;
import dlangui.widgets.metadata;
import std.array : replaceFirst;
import std.algorithm;
import std.process;
import std.stdio;
import std.array;
import std.file;
import std.path;

import dlangui.dialogs.settingsdialog;
import settings;
import appSettings;

mixin APP_ENTRY_POINT;

enum IDEActions : int {
    About = 1010000,
    Lang
}

dstring SAMPLE_SOURCE_CODE = q{import std.stdio;
import std.path;
import std.file;
import std.string;
import std.algorithm;
import std.array;
import std.conv;
import std.typecons;

int main() {
    
    
    writeln("Ok!");
    return 0;
}
};

const Action ACTION_ABOUT = new Action(IDEActions.About, "MENU_ABOUT"c, "document-about", KeyCode.KEY_A, KeyFlag.Control);
const Action ACTION_LANG = new Action(IDEActions.Lang, "MENU_LANG"c, "document-lang", KeyCode.KEY_L, KeyFlag.Control);

string BUTTONS_CODE = q{
    HorizontalLayout {
    	layoutWidth: FILL_PARENT
    	layoutHeight: 20
    	alignment: HCenter
    
    	Button { id: btnRun; text: "compile/run"; 
		margins: Rect { left: 60; right: 0;  top: 20; bottom: 20}
                layoutWidth: 180; layoutHeight: 20 }
        Button { id: btnReset; text: "reset"; padding: 0; 
		margins: Rect { left: 80; right: 0; top: 20; bottom: 20 }
		layoutWidth: 200; layoutHeight: 20 }

        Button { id: btnSave; text: "save"; padding: 0; 
		margins: Rect { left: 80; right: 0; top: 20; bottom: 20 }
		layoutWidth: 200; layoutHeight: 20 }
    }
};

immutable string RESULT_WIDGET = `
	MultilineTextWidget {
	    /* this widget can be accessed via id myLabel1
	        e.g. w.childById!TextWidget("myLabel1")
	    */
	    id: logTxtWidget
	    text: ""
	    padding: 5
	    layoutWidth: FILL_PARENT
	    layoutHeight: 100
	    //readonly: true
	}
`;

string cacheFile;

class DMLSourceEdit : SourceEdit {
    this(string ID) {
        super(ID);

        content.syntaxSupport = new DMLSyntaxSupport("");
        setTokenHightlightColor(TokenCategory.Comment, 0x008000); // green
        setTokenHightlightColor(TokenCategory.Keyword, 0x0000FF); // blue
        setTokenHightlightColor(TokenCategory.String, 0xa31515);  // brown
        setTokenHightlightColor(TokenCategory.Integer, 0xa315C0);  //
        setTokenHightlightColor(TokenCategory.Float, 0xa315C0);  //
        setTokenHightlightColor(TokenCategory.Error, 0xFF0000);  // red
        setTokenHightlightColor(TokenCategory.Op, 0x503000);
        setTokenHightlightColor(TokenCategory.Identifier_Class, 0x000080);  // blue

    }
    this() {
        this("Dlearn");
    }
}


class MainFrame : AppFrame {

    MenuItem mainMenuItems;
    AppSettings _settings;

    override protected void initialize() {
        _appName = "DLearn";
        super.initialize();
    }

    this(Window window) {
	_settings = new AppSettings(buildNormalizedPath(settingsDir, "dlearnrc.json"));
	cacheFile = buildNormalizedPath(settingsDir, "dlearn_ini.d");
        applySettings(_settings);

        super();
    }

    ~this() {
    //    if (_dcdInterface) {
    //        destroy(_dcdInterface);
    //        _dcdInterface = null;
    //    }
    }

    /// create main menu
    override protected MainMenu createMainMenu() {
        mainMenuItems = new MenuItem();

        MenuItem aboutMenu = new MenuItem(new Action(1, "MENU_ABOUT"));
        aboutMenu.add(ACTION_ABOUT);
        mainMenuItems.add(aboutMenu);

        MenuItem langMenu = new MenuItem(new Action(2, "MENU_LANG"));
        langMenu.add(ACTION_LANG);
        mainMenuItems.add(langMenu);

        MainMenu mainMenu = new MainMenu(mainMenuItems);

        return mainMenu;
    }

    void applySettings(AppSettings settings) {
        Platform.instance.uiLanguage = settings.uiLanguage;
	//Log.d("settings.uiLanguage=");
	//Log.d(settings.uiLanguage);
        //Platform.instance.uiLanguage = "cn";
        requestLayout();
    }

    override bool handleAction(const Action a) {
        if (!a) {
	    return false;
	}
        switch (a.id) {
	    case IDEActions.About:
		window.showMessageBox(UIString.fromId("ABOUT"), UIString.fromId("ABOUT_TEXT"));
                return true;
	    case IDEActions.Lang:
		showPreferences();
                return true;
	    default:
		return super.handleAction(a);
	}
	//return false;
    }

    override protected ToolBarHost createToolbars() {
        ToolBarHost res = new ToolBarHost();
        ToolBar tb;
        tb = res.getOrAddToolbar("About");
        tb.addButtons(ACTION_ABOUT);

        tb = res.getOrAddToolbar("Lang");
        tb.addButtons(ACTION_LANG);

        return res;
    }

    string _filename;
    void openSourceFile(string filename) {
        import std.file;
        // TODO
        if (exists(filename)) {
            _filename = filename;
            window.windowCaption = toUTF32(filename);
            _editor.load(filename);
        }
    }

    void saveSourceFile(string filename) {
        if (filename.length == 0)
            filename = _filename;
        import std.file;
        _filename = filename;
        window.windowCaption = toUTF32(filename);
        _editor.save(filename);
    }

    bool onCanClose() {
        // todo
        return true;
    }

    void showPreferences() {
        Setting s = _settings.copySettings();
        SettingsDialog dlg = new SettingsDialog(UIString.fromId("HEADER_SETTINGS"), window, s, createSettingsPages());
        dlg.dialogResult = delegate(Dialog dlg, const Action result) {
            if (result.id == ACTION_APPLY.id) {
                _settings.applySettings(s);
                applySettings(_settings);
                _settings.save();
            }
        };
        dlg.show();
    }

    protected DMLSourceEdit _editor;
    // protected ScrollWidget _preview;

    void setText(Widget w, string text) {
	w.text(toUTF32(text.replace("\r\n", "\n")));
    }

    override protected Widget createBody() {
        auto dockHost = new DockHost();
        dockHost.layoutWidth = FILL_PARENT;
        dockHost.layoutHeight = FILL_PARENT;
        dockHost.alignment = Align.Top;

	auto ml = parseML(RESULT_WIDGET);
	auto topFrame = parseML(BUTTONS_CODE);

        _editor = new DMLSourceEdit();
        _editor.text = getCacheText();
        _editor.layoutHeight = 200;

        auto resultDockWin = new DockWindow("result"); // false: don't show close button
        resultDockWin.bodyWidget = ml;
        resultDockWin.dockAlignment = DockAlignment.Bottom;
        resultDockWin.layoutHeight = makePercentSize(40);
        resultDockWin.layoutWidth = FILL_PARENT;
	resultDockWin.caption.text = UIString.fromId("RESULT") ~ ":";

        auto topDockWin = new DockWindow("top");
        topDockWin.bodyWidget = topFrame;
        topDockWin.dockAlignment = DockAlignment.Top;
        topDockWin.layoutHeight = makePercentSize(10);
        topDockWin.layoutWidth = FILL_PARENT;
	topDockWin.caption.text = UIString.fromId("BUTTONS") ~ ":";

        dockHost.addDockedWindow(topDockWin);
        dockHost.bodyWidget = _editor;
        dockHost.addDockedWindow(resultDockWin);

	auto logTxtWidget = ml.childById!TextWidget("logTxtWidget");

        auto btnSave = topFrame.childById!Button("btnSave");
        btnSave.text = UIString.fromId("SAVE");
	btnSave.click = delegate(Widget srcWidget) {
	    auto fp = new File(cacheFile, "w");
	    fp.write(_editor.text);
	    setText(logTxtWidget, "Saved: " ~ cacheFile);
	    return true;
	};

        auto btnRun = topFrame.childById!Button("btnRun");
        btnRun.text = UIString.fromId("COMPILE_AND_RUN");

	btnRun.click = delegate(Widget srcWidget) {
	    auto tmpDir = std.file.tempDir();
	    auto tmp_filename = buildPath(tmpDir, "aa.d");

	    this.saveSourceFile(tmp_filename);

	    auto tmp_exeFile = tmp_filename ~ ".exe";

	    logTxtWidget.text = " ";

	    try {
	        auto result0 = execute(["dmd", tmp_filename, "-of=" ~ tmp_exeFile],
			null, Config.suppressConsole);

	        setText(logTxtWidget, result0.output);

	        Log.i("dmd result: ", result0.output);
	        if (result0.status != 0) {
	            return false;
	        }
	    } catch (Exception e) {
	        setText(logTxtWidget, "编译出错：" ~ e.toString());
	        return false;
	    }


	    if (exists(tmp_exeFile)) {
	        try {
	            auto result1 = execute([tmp_exeFile], null, Config.suppressConsole);
	            setText(logTxtWidget, "\n\n" ~ result1.output);
	            if (result1.status != 0) {
	        	return false;
	            }
	        } catch (Exception e) {
	            setText(logTxtWidget, UIString.fromId("ERROR").to!string ~ "：" ~ e.toString());
	            return false;
	        }
	    }

	    return true;
	};

        auto btnReset = topFrame.childById!Button("btnReset");
        btnReset.text = UIString.fromId("RESET");

	btnReset.click = delegate(Widget srcWidget) {
	    _editor.text = getCacheText();
	    return true;
	};

	return dockHost;
    }
}

dstring getCacheText() {
    if (exists(cacheFile)) {
	return readText(cacheFile).to!dstring;
    } else {
	return SAMPLE_SOURCE_CODE;
    }
}

extern (C) int UIAppMain(string[] args) {
    embeddedResourceList.addResources(embedResourcesFromList!("resources.list")());
    FontManager.fontGamma = 0.8;
    FontManager.hintingMode = HintingMode.Normal;

    Window window = Platform.instance.createWindow("Dlang Learn"d, null, 
			WindowFlag.Resizable, 500, 500);

    window.windowIcon = drawableCache.getImage("dlangui-logo1");
    window.mainWidget = new MainFrame(window);

    window.show();
    return Platform.instance.enterMessageLoop();
}
