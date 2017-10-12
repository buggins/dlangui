/**
 * Getting paths where icon themes and icons are stored.
 *
 * Authors:
 *  $(LINK2 https://github.com/FreeSlave, Roman Chistokhodov)
 * Copyright:
 *  Roman Chistokhodov, 2015-2017
 * License:
 *  $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0).
 * See_Also:
 *  $(LINK2 http://standards.freedesktop.org/icon-theme-spec/icon-theme-spec-latest.html, Icon Theme Specification)
 */

module icontheme.paths;

private {
    import std.algorithm;
    import std.array;
    import std.exception;
    import std.path;
    import std.range;
    import std.traits;
    import std.process : environment;
    import isfreedesktop;
}

version(unittest) {
    package struct EnvGuard
    {
        this(string env) {
            envVar = env;
            envValue = environment.get(env);
        }

        ~this() {
            if (envValue is null) {
                environment.remove(envVar);
            } else {
                environment[envVar] = envValue;
            }
        }

        string envVar;
        string envValue;
    }
}


static if (isFreedesktop) {
    import xdgpaths;

    /**
    * The list of base directories where icon thems should be looked for as described in $(LINK2 http://standards.freedesktop.org/icon-theme-spec/icon-theme-spec-latest.html#directory_layout, Icon Theme Specification).
    *
    * $(BLUE This function is Freedesktop only).
    * Note: This function does not provide any caching of its results. This function does not check if directories exist.
    */
    @safe string[] baseIconDirs() nothrow
    {
        string[] toReturn;
        string homePath;
        collectException(environment.get("HOME"), homePath);
        if (homePath.length) {
            toReturn ~= buildPath(homePath, ".icons");
        }
        toReturn ~= xdgAllDataDirs("icons");
        toReturn ~= "/usr/share/pixmaps";
        return toReturn;
    }

    ///
    unittest
    {
        auto homeGuard = EnvGuard("HOME");
        auto dataHomeGuard = EnvGuard("XDG_DATA_HOME");
        auto dataDirsGuard = EnvGuard("XDG_DATA_DIRS");

        environment["HOME"] = "/home/user";
        environment["XDG_DATA_HOME"] = "/home/user/data";
        environment["XDG_DATA_DIRS"] = "/usr/local/data:/usr/data";

        assert(baseIconDirs() == ["/home/user/.icons", "/home/user/data/icons", "/usr/local/data/icons", "/usr/data/icons", "/usr/share/pixmaps"]);
    }

    /**
     * Writable base icon path. Depends on XDG_DATA_HOME, so this is $HOME/.local/share/icons rather than $HOME/.icons
     *
     * $(BLUE This function is Freedesktop only).
     * Note: it does not check if returned path exists and appears to be directory.
     */
    @safe string writableIconsPath() nothrow {
        return xdgDataHome("icons");
    }

    ///
    unittest
    {
        auto dataHomeGuard = EnvGuard("XDG_DATA_HOME");
        environment["XDG_DATA_HOME"] = "/home/user/data";
        assert(writableIconsPath() == "/home/user/data/icons");
    }

    ///
    enum IconThemeNameDetector
    {
        none = 0,
        fallback = 1, /// Use hardcoded fallback to detect icon theme name depending on the current desktop environment. Has lower priority than other methods.
        gtk2 = 2, /// Use gtk2 settings to detect icon theme name. Has lower priority than gtk3.
        gtk3 = 4, /// Use gtk3 settings to detect icon theme name.
        automatic =  fallback | gtk2 | gtk3 /// Use all known means to detect icon theme name.
    }
    /**
    * Try to detect the current icon name configured by user.
    *
    * $(BLUE This function is Freedesktop only).
    * Note: There's no any specification on that so some heuristics are applied.
    * Another note: It does not check if the icon theme with the detected name really exists on the file system.
    */
    @safe string currentIconThemeName(IconThemeNameDetector detector = IconThemeNameDetector.automatic) nothrow
    {
        @trusted static string fallbackIconThemeName()
        {
            string xdgCurrentDesktop = environment.get("XDG_CURRENT_DESKTOP");
            switch(xdgCurrentDesktop) {
                case "GNOME":
                case "X-Cinnamon":
                case "MATE":
                    return "gnome";
                case "LXDE":
                    return "Adwaita";
                case "XFCE":
                    return "Tango";
                case "KDE":
                    return "oxygen"; //TODO: detect KDE version and set breeze if it's KDE5
                default:
                    return "Tango";
            }
        }
        @trusted static string gtk2IconThemeName() nothrow
        {
            import std.stdio : File;
            try {
                auto home = environment.get("HOME");
                if (!home.length) {
                    return null;
                }
                string themeName;
                auto gtkConfig = buildPath(home, ".gtkrc-2.0");
                auto f = File(gtkConfig, "r");
                foreach(line; f.byLine()) {
                    auto splitted = line.findSplit("=");
                    if (splitted[0] == "gtk-icon-theme-name") {
                        if (splitted[2].length > 2 && splitted[2][0] == '"' && splitted[2][$-1] == '"') {
                            return splitted[2][1..$-1].idup;
                        }
                        break;
                    }
                }
            } catch(Exception e) {

            }
            return null;
        }
        @trusted static string gtk3IconThemeName() nothrow
        {
            import inilike.file;
            try {
                auto f = new IniLikeFile(xdgConfigHome("gtk-3.0/settings.ini"), IniLikeFile.ReadOptions(No.preserveComments));
                auto settings = f.group("Settings");
                if (settings)
                    return settings.readEntry("gtk-icon-theme-name");
            } catch(Exception e) {

            }
            return null;
        }

        try {
            string themeName;
            if (detector & IconThemeNameDetector.gtk3) {
                themeName = gtk3IconThemeName();
            }
            if (!themeName.length && (detector & IconThemeNameDetector.gtk2)) {
                themeName = gtk2IconThemeName();
            }
            if (!themeName.length && (detector & IconThemeNameDetector.fallback)) {
                themeName = fallbackIconThemeName();
            }
            return themeName;
        } catch(Exception e) {

        }
        return null;
    }

    unittest
    {
        auto desktopGuard = EnvGuard("XDG_CURRENT_DESKTOP");
        environment["XDG_CURRENT_DESKTOP"] = "";
        assert(currentIconThemeName(IconThemeNameDetector.fallback).length);
        assert(currentIconThemeName(IconThemeNameDetector.none).length == 0);

        version(iconthemeFileTest)
        {
            auto homeGuard = EnvGuard("HOME");
            environment["HOME"] = "./test";

            auto configGuard = EnvGuard("XDG_CONFIG_HOME");
            environment["XDG_CONFIG_HOME"] = "./test";

            assert(currentIconThemeName() == "gnome");
            assert(currentIconThemeName(IconThemeNameDetector.gtk3) == "gnome");
            assert(currentIconThemeName(IconThemeNameDetector.gtk2) == "oxygen");
        }
    }
}

/**
 * The list of icon theme directories based on data paths.
 * Returns: Array of paths with "icons" subdirectory appended to each data path.
 * Note: This function does not check if directories exist.
 */
@trusted string[] baseIconDirs(Range)(Range dataPaths) if (isInputRange!Range && is(ElementType!Range : string))
{
    return dataPaths.map!(p => buildPath(p, "icons")).array;
}

///
unittest
{
    auto dataPaths = ["share", buildPath("local", "share")];
    assert(equal(baseIconDirs(dataPaths), [buildPath("share", "icons"), buildPath("local", "share", "icons")]));
}
