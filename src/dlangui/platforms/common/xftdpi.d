// Written in the D programming language.

/**
Screen DPI configured by X11 desktops.

Desktops (GNOME, KDE, Xfce, ...) publish the DPI chosen by the user (scale or font DPI setting)
as `Xft.dpi` resource in the `RESOURCE_MANAGER` property of the X server root window.
This is what X11 applications built with other toolkits use, so X11 and SDL backends prefer it
over the physical DPI of the monitor (see issue #706).

Copyright: Vadim Lopatin, 2026
License:   Boost License 1.0
Authors:   Vadim Lopatin, coolreader.org@gmail.com
*/
module dlangui.platforms.common.xftdpi;

/**
Parse value of `Xft.dpi` from X resource manager string
(content of `RESOURCE_MANAGER` root window property, as returned by `XResourceManagerString()`).

Returns: DPI rounded to integer, or 0 if `Xft.dpi` is not set or has invalid value.
When `Xft.dpi` is defined more than once, the last valid definition is used, like in X resource database.
*/
int parseXftDpi(const(char)[] resources) {
    import std.algorithm : startsWith;
    import std.conv : to, ConvException;
    import std.string : lineSplitter, strip, stripLeft;
    enum key = "Xft.dpi";
    int res = 0;
    foreach (line; resources.lineSplitter) {
        auto s = line.stripLeft;
        if (!s.startsWith(key))
            continue;
        s = s[key.length .. $].stripLeft;
        if (!s.startsWith(":"))
            continue; // other resource with the same prefix, e.g. Xft.dpiX
        s = s[1 .. $].strip;
        try {
            double dpi = s.to!double;
            if (dpi > 0 && dpi < 10000)
                res = cast(int)(dpi + 0.5);
        } catch (ConvException e) {
            // ignore invalid value
        }
    }
    return res;
}

///
unittest {
    assert(parseXftDpi(null) == 0);
    assert(parseXftDpi("") == 0);
    assert(parseXftDpi("Xft.dpi:\t192\n") == 192);
    assert(parseXftDpi("Xft.dpi: 144.0") == 144);
    assert(parseXftDpi("Xft.dpi:\t120.6\n") == 121);
    assert(parseXftDpi("  Xft.dpi :  96  \r\n") == 96);
    // other resources around it
    assert(parseXftDpi("Xcursor.size:\t24\nXft.antialias:\t1\nXft.dpi:\t168\nXft.hinting:\t1\n") == 168);
    // not set
    assert(parseXftDpi("Xcursor.size:\t24\nXft.antialias:\t1\n") == 0);
    // similar names are not Xft.dpi
    assert(parseXftDpi("Xft.dpiX:\t200\n*dpi:\t200\nXft.dpi.foo:\t200\n") == 0);
    // invalid values
    assert(parseXftDpi("Xft.dpi:\tabc\n") == 0);
    assert(parseXftDpi("Xft.dpi:\n") == 0);
    assert(parseXftDpi("Xft.dpi:\t-96\n") == 0);
    // last valid definition wins
    assert(parseXftDpi("Xft.dpi:\t96\nXft.dpi:\t192\n") == 192);
    assert(parseXftDpi("Xft.dpi:\t96\nXft.dpi:\tbad\n") == 96);
}

version (Posix) {
    version (OSX) {
    } else version (iOS) {
    } else version (Android) {
    } else {
        version = X11Desktop;
    }
}

version (X11Desktop) {
    /**
    Read `Xft.dpi` of the default X display (`$DISPLAY`), loading libX11 at runtime.

    For backends which don't link libX11 (SDL). Opens and closes its own short-lived X connection.

    Returns: DPI, or 0 if libX11 or X display is not available, or `Xft.dpi` is not set.
    */
    int detectXftDpi() {
        import core.sys.posix.dlfcn : dlopen, dlsym, dlclose, RTLD_NOW, RTLD_LOCAL;
        import std.string : fromStringz;
        alias XOpenDisplayFunc = extern(C) void* function(const(char)* displayName);
        alias XCloseDisplayFunc = extern(C) int function(void* display);
        alias XResourceManagerStringFunc = extern(C) char* function(void* display);

        void* lib = dlopen("libX11.so.6", RTLD_NOW | RTLD_LOCAL);
        if (!lib)
            lib = dlopen("libX11.so", RTLD_NOW | RTLD_LOCAL);
        if (!lib)
            return 0;
        scope(exit) dlclose(lib);
        auto openDisplay = cast(XOpenDisplayFunc)dlsym(lib, "XOpenDisplay");
        auto closeDisplay = cast(XCloseDisplayFunc)dlsym(lib, "XCloseDisplay");
        auto resourceManagerString = cast(XResourceManagerStringFunc)dlsym(lib, "XResourceManagerString");
        if (!openDisplay || !closeDisplay || !resourceManagerString)
            return 0;
        void* display = openDisplay(null);
        if (!display)
            return 0;
        scope(exit) closeDisplay(display);
        char* resources = resourceManagerString(display);
        return resources ? parseXftDpi(fromStringz(resources)) : 0;
    }
} else {
    /// `Xft.dpi` is not used on this platform: always returns 0.
    int detectXftDpi() {
        return 0;
    }
}
