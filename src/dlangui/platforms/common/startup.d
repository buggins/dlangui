module dlangui.platforms.common.startup;

import dlangui.core.config;
import dlangui.core.events;
import dlangui.widgets.styles;
import dlangui.graphics.fonts;
import dlangui.graphics.resources;
import dlangui.widgets.widget;
import std.utf : toUTF32;

private immutable dstring DLANGUI_VERSION_VALUE = toUTF32(import("DLANGUI_VERSION"));
extern(C) @property dstring DLANGUI_VERSION() {
    return DLANGUI_VERSION_VALUE;
}

static if (BACKEND_GUI) {
import dlangui.graphics.ftfonts;

version (Windows) {

    /// initialize font manager - default implementation
    /// On win32 - first it tries to init freetype, and falls back to win32 fonts.
    /// On linux/mac - tries to init freetype with some hardcoded font paths
    extern(C) bool initFontManager() {
        import core.sys.windows.windows;
        import std.utf;
        import dlangui.platforms.windows.win32fonts;
        try {
            /// testing freetype font manager
            static if (ENABLE_FREETYPE) {
                Log.v("Trying to init FreeType font manager");

                import dlangui.graphics.ftfonts;
                // trying to create font manager
                Log.v("Creating FreeTypeFontManager");
                FreeTypeFontManager ftfontMan = new FreeTypeFontManager();

                import core.sys.windows.shlobj;
                string fontsPath = "c:\\Windows\\Fonts\\";
                static if (true) { // SHGetFolderPathW not found in shell32.lib
                    WCHAR[MAX_PATH] szPath;
                    static if (false) {
                        const CSIDL_FLAG_NO_ALIAS = 0x1000;
                        const CSIDL_FLAG_DONT_UNEXPAND = 0x2000;
                        if(SUCCEEDED(SHGetFolderPathW(NULL,
                                    CSIDL_FONTS|CSIDL_FLAG_NO_ALIAS|CSIDL_FLAG_DONT_UNEXPAND,
                                    NULL,
                                    0,
                                    szPath.ptr)))
                        {
                            fontsPath = toUTF8(fromWStringz(szPath));
                        }
                    } else {
                        if (GetWindowsDirectory(szPath.ptr, MAX_PATH - 1)) {
                            fontsPath = toUTF8(fromWStringz(szPath));
                            Log.i("Windows directory: ", fontsPath);
                            fontsPath ~= "\\Fonts\\";
                            Log.i("Fonts directory: ", fontsPath);
                        }
                    }
                }
                Log.v("Registering fonts");
                // arial
                ftfontMan.registerFont(fontsPath ~ "arial.ttf",     FontFamily.SansSerif, "Arial", false, FontWeight.Normal);
                ftfontMan.registerFont(fontsPath ~ "arialbd.ttf",   FontFamily.SansSerif, "Arial", false, FontWeight.Bold);
                ftfontMan.registerFont(fontsPath ~ "arialbi.ttf",   FontFamily.SansSerif, "Arial", true, FontWeight.Bold);
                ftfontMan.registerFont(fontsPath ~ "ariali.ttf",    FontFamily.SansSerif, "Arial", true, FontWeight.Normal);
                // arial unicode ms
                ftfontMan.registerFont(fontsPath ~ "arialni.ttf",    FontFamily.SansSerif, "Arial Unicode MS", false, FontWeight.Normal);
                // arial narrow
                ftfontMan.registerFont(fontsPath ~ "arialn.ttf",     FontFamily.SansSerif, "Arial Narrow", false, FontWeight.Normal);
                ftfontMan.registerFont(fontsPath ~ "arialnb.ttf",   FontFamily.SansSerif, "Arial Narrow", false, FontWeight.Bold);
                ftfontMan.registerFont(fontsPath ~ "arialnbi.ttf",   FontFamily.SansSerif, "Arial Narrow", true, FontWeight.Bold);
                ftfontMan.registerFont(fontsPath ~ "arialni.ttf",    FontFamily.SansSerif, "Arial Narrow", true, FontWeight.Normal);
                // calibri
                ftfontMan.registerFont(fontsPath ~ "calibri.ttf",     FontFamily.SansSerif, "Calibri", false, FontWeight.Normal);
                ftfontMan.registerFont(fontsPath ~ "calibrib.ttf",   FontFamily.SansSerif, "Calibri", false, FontWeight.Bold);
                ftfontMan.registerFont(fontsPath ~ "calibriz.ttf",   FontFamily.SansSerif, "Calibri", true, FontWeight.Bold);
                ftfontMan.registerFont(fontsPath ~ "calibrii.ttf",    FontFamily.SansSerif, "Calibri", true, FontWeight.Normal);
                // cambria
                ftfontMan.registerFont(fontsPath ~ "cambria.ttc",     FontFamily.SansSerif, "Cambria", false, FontWeight.Normal);
                ftfontMan.registerFont(fontsPath ~ "cambriab.ttf",   FontFamily.SansSerif, "Cambria", false, FontWeight.Bold);
                ftfontMan.registerFont(fontsPath ~ "cambriaz.ttf",   FontFamily.SansSerif, "Cambria", true, FontWeight.Bold);
                ftfontMan.registerFont(fontsPath ~ "cambriai.ttf",    FontFamily.SansSerif, "Cambria", true, FontWeight.Normal);
                // candara
                ftfontMan.registerFont(fontsPath ~ "Candara.ttf",     FontFamily.SansSerif, "Candara", false, FontWeight.Normal);
                ftfontMan.registerFont(fontsPath ~ "Candarab.ttf",   FontFamily.SansSerif, "Candara", false, FontWeight.Bold);
                ftfontMan.registerFont(fontsPath ~ "Candaraz.ttf",   FontFamily.SansSerif, "Candara", true, FontWeight.Bold);
                ftfontMan.registerFont(fontsPath ~ "Candarai.ttf",    FontFamily.SansSerif, "Candara", true, FontWeight.Normal);
                // century
                ftfontMan.registerFont(fontsPath ~ "CENTURY.TTF",     FontFamily.Serif, "Century", false, FontWeight.Normal);
                // comic sans ms
                ftfontMan.registerFont(fontsPath ~ "comic.ttf",     FontFamily.Serif, "Comic Sans MS", false, FontWeight.Normal);
                ftfontMan.registerFont(fontsPath ~ "comicbd.ttf",     FontFamily.Serif, "Comic Sans MS", false, FontWeight.Bold);
                // constantia
                ftfontMan.registerFont(fontsPath ~ "constan.ttf",     FontFamily.Serif, "Constantia", false, FontWeight.Normal);
                ftfontMan.registerFont(fontsPath ~ "constanb.ttf",   FontFamily.Serif, "Constantia", false, FontWeight.Bold);
                ftfontMan.registerFont(fontsPath ~ "constanz.ttf",   FontFamily.Serif, "Constantia", true, FontWeight.Bold);
                ftfontMan.registerFont(fontsPath ~ "constani.ttf",    FontFamily.Serif, "Constantia", true, FontWeight.Normal);
                // corbel
                ftfontMan.registerFont(fontsPath ~ "corbel.ttf",     FontFamily.SansSerif, "Corbel", false, FontWeight.Normal);
                ftfontMan.registerFont(fontsPath ~ "corbelb.ttf",   FontFamily.SansSerif, "Corbel", false, FontWeight.Bold);
                ftfontMan.registerFont(fontsPath ~ "corbelz.ttf",   FontFamily.SansSerif, "Corbel", true, FontWeight.Bold);
                ftfontMan.registerFont(fontsPath ~ "corbeli.ttf",    FontFamily.SansSerif, "Corbel", true, FontWeight.Normal);
                // courier new
                ftfontMan.registerFont(fontsPath ~ "cour.ttf",      FontFamily.MonoSpace, "Courier New", false, FontWeight.Normal);
                ftfontMan.registerFont(fontsPath ~ "courbd.ttf",    FontFamily.MonoSpace, "Courier New", false, FontWeight.Bold);
                ftfontMan.registerFont(fontsPath ~ "courbi.ttf",    FontFamily.MonoSpace, "Courier New", true, FontWeight.Bold);
                ftfontMan.registerFont(fontsPath ~ "couri.ttf",     FontFamily.MonoSpace, "Courier New", true, FontWeight.Normal);
                // franklin gothic book
                ftfontMan.registerFont(fontsPath ~ "frank.ttf",     FontFamily.SansSerif, "Franklin Gothic Book", false, FontWeight.Normal);
                // times new roman
                ftfontMan.registerFont(fontsPath ~ "times.ttf",     FontFamily.Serif, "Times New Roman", false, FontWeight.Normal);
                ftfontMan.registerFont(fontsPath ~ "timesbd.ttf",   FontFamily.Serif, "Times New Roman", false, FontWeight.Bold);
                ftfontMan.registerFont(fontsPath ~ "timesbi.ttf",   FontFamily.Serif, "Times New Roman", true, FontWeight.Bold);
                ftfontMan.registerFont(fontsPath ~ "timesi.ttf",    FontFamily.Serif, "Times New Roman", true, FontWeight.Normal);
                // consolas
                ftfontMan.registerFont(fontsPath ~ "consola.ttf",   FontFamily.MonoSpace, "Consolas", false, FontWeight.Normal);
                ftfontMan.registerFont(fontsPath ~ "consolab.ttf",  FontFamily.MonoSpace, "Consolas", false, FontWeight.Bold);
                ftfontMan.registerFont(fontsPath ~ "consolai.ttf",  FontFamily.MonoSpace, "Consolas", true, FontWeight.Normal);
                ftfontMan.registerFont(fontsPath ~ "consolaz.ttf",  FontFamily.MonoSpace, "Consolas", true, FontWeight.Bold);
                // garamond
                ftfontMan.registerFont(fontsPath ~ "GARA.TTF",     FontFamily.Serif, "Garamond", false, FontWeight.Normal);
                ftfontMan.registerFont(fontsPath ~ "GARABD.TTF",   FontFamily.Serif, "Garamond", false, FontWeight.Bold);
                ftfontMan.registerFont(fontsPath ~ "GARAIT.TTF",    FontFamily.Serif, "Garamond", true, FontWeight.Normal);
                // georgia
                ftfontMan.registerFont(fontsPath ~ "georgia.ttf",     FontFamily.SansSerif, "Georgia", false, FontWeight.Normal);
                ftfontMan.registerFont(fontsPath ~ "georgiab.ttf",   FontFamily.SansSerif, "Georgia", false, FontWeight.Bold);
                ftfontMan.registerFont(fontsPath ~ "georgiaz.ttf",   FontFamily.SansSerif, "Georgia", true, FontWeight.Bold);
                ftfontMan.registerFont(fontsPath ~ "georgiai.ttf",    FontFamily.SansSerif, "Georgia", true, FontWeight.Normal);
                // KaiTi
                ftfontMan.registerFont(fontsPath ~ "kaiu.ttf",     FontFamily.SansSerif, "KaiTi", false, FontWeight.Normal);
                // Lucida Console
                ftfontMan.registerFont(fontsPath ~ "lucon.ttf",   FontFamily.MonoSpace, "Lucida Console", false, FontWeight.Normal);
                // malgun gothic
                ftfontMan.registerFont(fontsPath ~ "malgun.ttf",     FontFamily.Serif, "Malgun Gothic", false, FontWeight.Normal);
                ftfontMan.registerFont(fontsPath ~ "malgunbd.ttf",     FontFamily.Serif, "Malgun Gothic", false, FontWeight.Bold);
                // meiryo
                ftfontMan.registerFont(fontsPath ~ "meiryo.ttc",     FontFamily.Serif, "Meiryo", false, FontWeight.Normal);
                ftfontMan.registerFont(fontsPath ~ "meiryob.ttc",     FontFamily.Serif, "Meiryo", false, FontWeight.Bold);
                // ms mhei
                ftfontMan.registerFont(fontsPath ~ "MSMHei.ttf",     FontFamily.Serif, "Microsoft MHei", false, FontWeight.Normal);
                ftfontMan.registerFont(fontsPath ~ "MSMHei-Bold.ttf",     FontFamily.Serif, "Microsoft MHei", false, FontWeight.Bold);
                // ms neo gothic
                ftfontMan.registerFont(fontsPath ~ "MSNeoGothic.ttf",     FontFamily.Serif, "Microsoft NeoGothic", false, FontWeight.Normal);
                ftfontMan.registerFont(fontsPath ~ "MSNeoGothic-Bold.ttf",     FontFamily.Serif, "Microsoft NeoGothic", false, FontWeight.Bold);
                // palatino linotype
                ftfontMan.registerFont(fontsPath ~ "pala.ttf",     FontFamily.Serif, "Palatino Linotype", false, FontWeight.Normal);
                ftfontMan.registerFont(fontsPath ~ "palab.ttf",   FontFamily.Serif, "Palatino Linotype", false, FontWeight.Bold);
                ftfontMan.registerFont(fontsPath ~ "palabi.ttf",   FontFamily.Serif, "Palatino Linotype", true, FontWeight.Bold);
                ftfontMan.registerFont(fontsPath ~ "palai.ttf",    FontFamily.Serif, "Palatino Linotype", true, FontWeight.Normal);
                // segoeui
                ftfontMan.registerFont(fontsPath ~ "segoeui.ttf",     FontFamily.SansSerif, "Segoe UI", false, FontWeight.Normal);
                ftfontMan.registerFont(fontsPath ~ "segoeuib.ttf",   FontFamily.SansSerif, "Segoe UI", false, FontWeight.Bold);
                ftfontMan.registerFont(fontsPath ~ "segoeuiz.ttf",   FontFamily.SansSerif, "Segoe UI", true, FontWeight.Bold);
                ftfontMan.registerFont(fontsPath ~ "segoeuii.ttf",    FontFamily.SansSerif, "Segoe UI", true, FontWeight.Normal);
                // SimSun
                ftfontMan.registerFont(fontsPath ~ "simsun.ttc",     FontFamily.SansSerif, "SimSun", false, FontWeight.Normal);
                ftfontMan.registerFont(fontsPath ~ "simsunb.ttf",     FontFamily.SansSerif, "SimSun", false, FontWeight.Bold);
                // tahoma
                ftfontMan.registerFont(fontsPath ~ "tahoma.ttf",     FontFamily.SansSerif, "Tahoma", false, FontWeight.Normal);
                ftfontMan.registerFont(fontsPath ~ "tahomabd.ttf",     FontFamily.SansSerif, "Tahoma", false, FontWeight.Bold);
                // trebuchet ms
                ftfontMan.registerFont(fontsPath ~ "trebuc.ttf",     FontFamily.SansSerif, "Trebuchet MS", false, FontWeight.Normal);
                ftfontMan.registerFont(fontsPath ~ "trebucbd.ttf",   FontFamily.SansSerif, "Trebuchet MS", false, FontWeight.Bold);
                ftfontMan.registerFont(fontsPath ~ "trebucbi.ttf",   FontFamily.SansSerif, "Trebuchet MS", true, FontWeight.Bold);
                ftfontMan.registerFont(fontsPath ~ "trebucit.ttf",    FontFamily.SansSerif, "Trebuchet MS", true, FontWeight.Normal);
                // verdana
                ftfontMan.registerFont(fontsPath ~ "verdana.ttf",   FontFamily.SansSerif, "Verdana", false, FontWeight.Normal);
                ftfontMan.registerFont(fontsPath ~ "verdanab.ttf",  FontFamily.SansSerif, "Verdana", false, FontWeight.Bold);
                ftfontMan.registerFont(fontsPath ~ "verdanai.ttf",  FontFamily.SansSerif, "Verdana", true, FontWeight.Normal);
                ftfontMan.registerFont(fontsPath ~ "verdanaz.ttf",  FontFamily.SansSerif, "Verdana", true, FontWeight.Bold);
                if (ftfontMan.registeredFontCount()) {
                    FontManager.instance = ftfontMan;
                } else {
                    Log.w("No fonts registered in FreeType font manager. Disabling FreeType.");
                    destroy(ftfontMan);
                }
            }
        } catch (Exception e) {
            Log.e("Cannot create FreeTypeFontManager - falling back to win32");
        }

        // use Win32 font manager
        if (FontManager.instance is null) {
            FontManager.instance = new Win32FontManager();
        }
        return true;
    }

} else {
    import dlangui.graphics.ftfonts;
    bool registerFonts(FreeTypeFontManager ft, string path) {
        import std.file;
        if (!exists(path) || !isDir(path))
            return false;
        ft.registerFont(path ~ "DejaVuSans.ttf", FontFamily.SansSerif, "DejaVuSans", false, FontWeight.Normal);
        ft.registerFont(path ~ "DejaVuSans-Bold.ttf", FontFamily.SansSerif, "DejaVuSans", false, FontWeight.Bold);
        ft.registerFont(path ~ "DejaVuSans-Oblique.ttf", FontFamily.SansSerif, "DejaVuSans", true, FontWeight.Normal);
        ft.registerFont(path ~ "DejaVuSans-BoldOblique.ttf", FontFamily.SansSerif, "DejaVuSans", true, FontWeight.Bold);
        ft.registerFont(path ~ "DejaVuSansMono.ttf", FontFamily.MonoSpace, "DejaVuSansMono", false, FontWeight.Normal);
        ft.registerFont(path ~ "DejaVuSansMono-Bold.ttf", FontFamily.MonoSpace, "DejaVuSansMono", false, FontWeight.Bold);
        ft.registerFont(path ~ "DejaVuSansMono-Oblique.ttf", FontFamily.MonoSpace, "DejaVuSansMono", true, FontWeight.Normal);
        ft.registerFont(path ~ "DejaVuSansMono-BoldOblique.ttf", FontFamily.MonoSpace, "DejaVuSansMono", true, FontWeight.Bold);
        return true;
    }

	string[] findFontsInDirectory(string dir) {
		import dlangui.core.files;
		import std.file : DirEntry;
		DirEntry[] entries;
        try {
            entries = listDirectory(dir, AttrFilter.files, ["*.ttf"]);
        } catch(Exception e) {
            return null;
        }

		string[] res;
		foreach(entry; entries) {
			res ~= entry.name;
		}
		return res;
	}

	void registerFontsFromDirectory(FreeTypeFontManager ft, string dir) {
		string[] fontFiles = findFontsInDirectory(dir);
		Log.d("Fonts in ", dir, " : ", fontFiles);
		foreach(file; fontFiles)
			ft.registerFont(file);
	}

    /// initialize font manager - default implementation
    /// On win32 - first it tries to init freetype, and falls back to win32 fonts.
    /// On linux/mac - tries to init freetype with some hardcoded font paths
    extern(C) bool initFontManager() {
        FreeTypeFontManager ft = new FreeTypeFontManager();

        if (!registerFontConfigFonts(ft)) {
            // TODO: use FontConfig
            Log.w("No fonts found using FontConfig. Trying hardcoded paths.");
			version (Android) {
				ft.registerFontsFromDirectory("/system/fonts");
			} else {
	            ft.registerFonts("/usr/share/fonts/truetype/dejavu/");
	            ft.registerFonts("/usr/share/fonts/TTF/");
	            ft.registerFonts("/usr/share/fonts/dejavu/");
	            ft.registerFonts("/usr/share/fonts/truetype/ttf-dejavu/"); // let it compile on Debian Wheezy
			}
            version(OSX) {
                ft.registerFont("/Library/Fonts/Arial.ttf", FontFamily.SansSerif, "Arial", false, FontWeight.Normal, true);
                ft.registerFont("/Library/Fonts/Arial Bold.ttf", FontFamily.SansSerif, "Arial", false, FontWeight.Bold, true);
                ft.registerFont("/Library/Fonts/Arial Italic.ttf", FontFamily.SansSerif, "Arial", true, FontWeight.Normal, true);
                ft.registerFont("/Library/Fonts/Arial Bold Italic.ttf", FontFamily.SansSerif, "Arial", true, FontWeight.Bold, true);
                ft.registerFont("/Library/Fonts/Arial.ttf", FontFamily.SansSerif, "Arial", false, FontWeight.Normal, true);
                ft.registerFont("/Library/Fonts/Arial Bold.ttf", FontFamily.SansSerif, "Arial", false, FontWeight.Bold, true);
                ft.registerFont("/Library/Fonts/Arial Italic.ttf", FontFamily.SansSerif, "Arial", true, FontWeight.Normal, true);
                ft.registerFont("/Library/Fonts/Arial Bold Italic.ttf", FontFamily.SansSerif, "Arial", true, FontWeight.Bold, true);
                ft.registerFont("/Library/Fonts/Arial Narrow.ttf", FontFamily.SansSerif, "Arial Narrow", false, FontWeight.Normal, true);
                ft.registerFont("/Library/Fonts/Arial Narrow Bold.ttf", FontFamily.SansSerif, "Arial Narrow", false, FontWeight.Bold, true);
                ft.registerFont("/Library/Fonts/Arial Narrow Italic.ttf", FontFamily.SansSerif, "Arial Narrow", true, FontWeight.Normal, true);
                ft.registerFont("/Library/Fonts/Arial Narrow Bold Italic.ttf", FontFamily.SansSerif, "Arial Narrow", true, FontWeight.Bold, true);
                ft.registerFont("/Library/Fonts/Courier New.ttf", FontFamily.MonoSpace, "Courier New", false, FontWeight.Normal, true);
                ft.registerFont("/Library/Fonts/Courier New Bold.ttf", FontFamily.MonoSpace, "Courier New", false, FontWeight.Bold, true);
                ft.registerFont("/Library/Fonts/Courier New Italic.ttf", FontFamily.MonoSpace, "Courier New", true, FontWeight.Normal, true);
                ft.registerFont("/Library/Fonts/Courier New Bold Italic.ttf", FontFamily.MonoSpace, "Courier New", true, FontWeight.Bold, true);
                ft.registerFont("/Library/Fonts/Georgia.ttf", FontFamily.Serif, "Georgia", false, FontWeight.Normal, true);
                ft.registerFont("/Library/Fonts/Georgia Bold.ttf", FontFamily.Serif, "Georgia", false, FontWeight.Bold, true);
                ft.registerFont("/Library/Fonts/Georgia Italic.ttf", FontFamily.Serif, "Georgia", true, FontWeight.Normal, true);
                ft.registerFont("/Library/Fonts/Georgia Bold Italic.ttf", FontFamily.Serif, "Georgia", true, FontWeight.Bold, true);
                ft.registerFont("/Library/Fonts/Comic Sans MS.ttf", FontFamily.SansSerif, "Comic Sans", false, FontWeight.Normal, true);
                ft.registerFont("/Library/Fonts/Comic Sans MS Bold.ttf", FontFamily.SansSerif, "Comic Sans", false, FontWeight.Bold, true);
                ft.registerFont("/Library/Fonts/Tahoma.ttf", FontFamily.SansSerif, "Tahoma", false, FontWeight.Normal, true);
                ft.registerFont("/Library/Fonts/Tahoma Bold.ttf", FontFamily.SansSerif, "Tahoma", false, FontWeight.Bold, true);

                ft.registerFont("/Library/Fonts/Microsoft/Arial.ttf", FontFamily.SansSerif, "Arial", false, FontWeight.Normal, true);
                ft.registerFont("/Library/Fonts/Microsoft/Arial Bold.ttf", FontFamily.SansSerif, "Arial", false, FontWeight.Bold, true);
                ft.registerFont("/Library/Fonts/Microsoft/Arial Italic.ttf", FontFamily.SansSerif, "Arial", true, FontWeight.Normal, true);
                ft.registerFont("/Library/Fonts/Microsoft/Arial Bold Italic.ttf", FontFamily.SansSerif, "Arial", true, FontWeight.Bold, true);
                ft.registerFont("/Library/Fonts/Microsoft/Calibri.ttf", FontFamily.SansSerif, "Calibri", false, FontWeight.Normal, true);
                ft.registerFont("/Library/Fonts/Microsoft/Calibri Bold.ttf", FontFamily.SansSerif, "Calibri", false, FontWeight.Bold, true);
                ft.registerFont("/Library/Fonts/Microsoft/Calibri Italic.ttf", FontFamily.SansSerif, "Calibri", true, FontWeight.Normal, true);
                ft.registerFont("/Library/Fonts/Microsoft/Calibri Bold Italic.ttf", FontFamily.SansSerif, "Calibri", true, FontWeight.Bold, true);
                ft.registerFont("/Library/Fonts/Microsoft/Times New Roman.ttf", FontFamily.Serif, "Times New Roman", false, FontWeight.Normal, true);
                ft.registerFont("/Library/Fonts/Microsoft/Times New Roman Bold.ttf", FontFamily.Serif, "Times New Roman", false, FontWeight.Bold, true);
                ft.registerFont("/Library/Fonts/Microsoft/Times New Roman Italic.ttf", FontFamily.Serif, "Times New Roman", true, FontWeight.Normal, true);
                ft.registerFont("/Library/Fonts/Microsoft/Times New Roman Bold Italic.ttf", FontFamily.Serif, "Times New Roman", true, FontWeight.Bold, true);
                ft.registerFont("/Library/Fonts/Microsoft/Verdana.ttf", FontFamily.SansSerif, "Verdana", false, FontWeight.Normal, true);
                ft.registerFont("/Library/Fonts/Microsoft/Verdana Bold.ttf", FontFamily.SansSerif, "Verdana", false, FontWeight.Bold, true);
                ft.registerFont("/Library/Fonts/Microsoft/Verdana Italic.ttf", FontFamily.SansSerif, "Verdana", true, FontWeight.Normal, true);
                ft.registerFont("/Library/Fonts/Microsoft/Verdana Bold Italic.ttf", FontFamily.SansSerif, "Verdana", true, FontWeight.Bold, true);

                ft.registerFont("/Library/Fonts/Microsoft/Consolas.ttf", FontFamily.MonoSpace, "Consolas", false, FontWeight.Normal, true);
                ft.registerFont("/Library/Fonts/Microsoft/Consolas Bold.ttf", FontFamily.MonoSpace, "Consolas", false, FontWeight.Bold, true);
                ft.registerFont("/Library/Fonts/Microsoft/Consolas Italic.ttf", FontFamily.MonoSpace, "Consolas", true, FontWeight.Normal, true);
                ft.registerFont("/Library/Fonts/Microsoft/Consolas Bold Italic.ttf", FontFamily.MonoSpace, "Consolas", true, FontWeight.Bold, true);

                ft.registerFont("/System/Library/Fonts/Menlo.ttc", FontFamily.MonoSpace, "Menlo", false, FontWeight.Normal, true);
            }
        }

        if (!ft.registeredFontCount)
            return false;

        FontManager.instance = ft;
        return true;
    }
}
}

/// initialize logging (for win32 - to file ui.log, for other platforms - stderr; log level is TRACE for debug builds, and WARN for release builds)
extern (C) void initLogs() {
    static if (BACKEND_CONSOLE) {
        static import std.stdio;
        debug {
            Log.setFileLogger(new std.stdio.File("ui.log", "w"));
            Log.i("Debug build. Logging to file ui.log");
            Log.setLogLevel(LogLevel.Trace);
        } else {
            // no logging unless version ForceLogs is set
            version(ForceLogs) {
                Log.setFileLogger(new std.stdio.File("ui.log", "w"));
                Log.i("Logging to file ui.log");
                //Log.setLogLevel(LogLevel.Trace);
            }
        }
    } else {
        static import std.stdio;
        version (Windows) {
            debug {
                Log.setFileLogger(new std.stdio.File("ui.log", "w"));
            } else {
                // no logging unless version ForceLogs is set
                version(ForceLogs) {
                    Log.setFileLogger(new std.stdio.File("ui.log", "w"));
                    Log.i("Logging to file ui.log");
                }
            }
        } else version(Android) {
            Log.setLogTag("dlangui");
            Log.setLogLevel(LogLevel.Trace);
        } else {
            Log.setStderrLogger();
        }
        debug {
            Log.setLogLevel(LogLevel.Trace);
        } else {
            version(ForceLogs) {
                Log.setLogLevel(LogLevel.Trace);
                Log.i("Log level: trace");
            } else {
                Log.setLogLevel(LogLevel.Warn);
                Log.i("Log level: warn");
            }
        }
    }
    Log.i("Logger is initialized");
}

/// call this on application initialization
extern (C) void initResourceManagers() {
    Log.d("initResourceManagers()");
    import dlangui.graphics.fonts;
    _gamma65 = new glyph_gamma_table!65(1.0);
    _gamma256 = new glyph_gamma_table!256(1.0);
    static if (ENABLE_FREETYPE) {
        import dlangui.graphics.ftfonts;
        STD_FONT_FACES = [
            "Arial": 12,
            "Times New Roman": 12,
            "Courier New": 10,
            "DejaVu Serif": 10,
            "DejaVu Sans": 10,
            "DejaVu Sans Mono": 10,
            "Liberation Serif": 11,
            "Liberation Sans": 11,
            "Liberation Mono": 11,
            "Verdana": 10,
            "Menlo": 13,
            "Consolas": 12,
            "DejaVuSansMono": 10,
            "Lucida Sans Typewriter": 10,
            "Lucida Console": 12,
            "FreeMono": 8,
            "FreeSans": 8,
            "FreeSerif": 8,
        ];
    }
    static if (ENABLE_OPENGL) {
        import dlangui.graphics.gldrawbuf;
        initGLCaches();
    }
    import dlangui.graphics.resources;
    embedStandardDlangUIResources();
    static if (BACKEND_GUI) {
        _imageCache = new ImageCache();
    }
    _drawableCache = new DrawableCache();
    static if (BACKEND_GUI) {
        version (Windows) {
            import dlangui.platforms.windows.win32fonts;
            initWin32FontsTables();
        }
    }

    Log.d("Calling initSharedResourceManagers()");
    initSharedResourceManagers();

    Log.d("Calling initStandardEditorActions()");
    import dlangui.widgets.editors;
    initStandardEditorActions();

    Log.d("Calling registerStandardWidgets()");
    registerStandardWidgets();


    Log.d("initResourceManagers() -- finished");
}



/// call this from shared static this()
extern (C) void initSharedResourceManagers() {
    //Log.d("initSharedResourceManagers()");
    //import dlangui.core.i18n;
    //if (!i18n) {
    //    Log.d("Creating i18n object");
    //    i18n = new shared UIStringTranslator();
    //}
}

shared static this() {
    //initSharedResourceManagers();
}

/// register standard widgets to use in DML
extern(C) void registerStandardWidgets();

/// call this when all resources are supposed to be freed to report counts of non-freed resources by type
extern (C) void releaseResourcesOnAppExit() {

    //
    debug setAppShuttingDownFlag();

    debug {
        if (Widget.instanceCount() > 0) {
            Log.e("Non-zero Widget instance count when exiting: ", Widget.instanceCount);
        }
    }

    currentTheme = null;
    drawableCache = null;
    static if (BACKEND_GUI) {
        imageCache = null;
    }
    FontManager.instance = null;
    static if (ENABLE_OPENGL) {
        import dlangui.graphics.gldrawbuf;
        destroyGLCaches();
    }

    debug {
        if (DrawBuf.instanceCount > 0) {
            Log.e("Non-zero DrawBuf instance count when exiting: ", DrawBuf.instanceCount);
        }
        if (Style.instanceCount > 0) {
            Log.e("Non-zero Style instance count when exiting: ", Style.instanceCount);
        }
        if (ImageDrawable.instanceCount > 0) {
            Log.e("Non-zero ImageDrawable instance count when exiting: ", ImageDrawable.instanceCount);
        }
        if (Drawable.instanceCount > 0) {
            Log.e("Non-zero Drawable instance count when exiting: ", Drawable.instanceCount);
        }
        static if (ENABLE_FREETYPE) {
            import dlangui.graphics.ftfonts;
            if (FreeTypeFontFile.instanceCount > 0) {
                Log.e("Non-zero FreeTypeFontFile instance count when exiting: ", FreeTypeFontFile.instanceCount);
            }
            if (FreeTypeFont.instanceCount > 0) {
                Log.e("Non-zero FreeTypeFont instance count when exiting: ", FreeTypeFont.instanceCount);
            }
        }
    }
}

version(unittest) {
    version (Windows) {
        mixin APP_ENTRY_POINT;

        /// entry point for dlangui based application
        extern (C) int UIAppMain(string[] args) {
            // just to enable running unit tests
            import core.runtime;
            import std.stdio;
            if (!runModuleUnitTests()) {
                writeln("Error occured in unit tests. Press enter.");
                readln();
                return 1;
            }
            return 0;
        }
    }
}


