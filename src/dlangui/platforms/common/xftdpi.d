// Written in the D programming language.

/**
Screen DPI and font smoothing configured by X11 desktops.

Desktops (GNOME, KDE, Xfce, ...) publish the DPI chosen by the user (scale or font DPI setting)
as `Xft.dpi` resource in the `RESOURCE_MANAGER` property of the X server root window.
This is what X11 applications built with other toolkits use, so X11 and SDL backends prefer it
over the physical DPI of the monitor (see issue #706).

The subpixel order for font rendering is published the same way as `Xft.rgba` (and `Xft.antialias`);
when it is not set, fontconfig's configuration (FC_RGBA) is used (see issue #882).

Copyright: Vadim Lopatin, 2026
License:   Boost License 1.0
Authors:   Vadim Lopatin, coolreader.org@gmail.com
*/
module dlangui.platforms.common.xftdpi;

import dlangui.core.types : SubpixelRenderingMode;

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

/**
Value of resource `key` in X resource manager string, or null if it is not set.
When the resource is defined more than once, the last definition is used.
*/
const(char)[] xResourceValue(const(char)[] resources, string key) {
    import std.algorithm : startsWith;
    import std.string : lineSplitter, strip, stripLeft;
    const(char)[] res = null;
    foreach (line; resources.lineSplitter) {
        auto s = line.stripLeft;
        if (!s.startsWith(key))
            continue;
        s = s[key.length .. $].stripLeft;
        if (!s.startsWith(":"))
            continue; // other resource with the same prefix
        res = s[1 .. $].strip;
    }
    return res;
}

/**
Subpixel rendering mode from `Xft.rgba` and `Xft.antialias` in X resource manager string (#882).

`Xft.antialias` false gives None; `Xft.rgba`: `rgb` gives RGB, `bgr` gives BGR, `none` gives None, and `vrgb` / `vbgr`
(vertical subpixels, not supported) give None.

Returns: true if the resources define the mode, false if they don't (e.g. `Xft.rgba` not set, or `unknown`).
*/
bool parseXftSubpixelRenderingMode(const(char)[] resources, out SubpixelRenderingMode mode) {
    import std.uni : toLower;
    mode = SubpixelRenderingMode.None;
    auto antialias = xResourceValue(resources, "Xft.antialias");
    if (antialias !is null) {
        switch (antialias.toLower) {
            case "0", "false", "off", "no":
                return true; // no antialiasing at all
            default:
                break;
        }
    }
    auto rgba = xResourceValue(resources, "Xft.rgba");
    if (rgba is null)
        return false;
    switch (rgba.toLower) {
        case "rgb":
            mode = SubpixelRenderingMode.RGB;
            return true;
        case "bgr":
            mode = SubpixelRenderingMode.BGR;
            return true;
        case "none", "vrgb", "vbgr":
            return true;
        default:
            return false;
    }
}

///
unittest {
    SubpixelRenderingMode m;
    assert(!parseXftSubpixelRenderingMode(null, m) && m == SubpixelRenderingMode.None);
    assert(!parseXftSubpixelRenderingMode("Xft.dpi:\t96\nXft.antialias:\t1\n", m));
    assert(parseXftSubpixelRenderingMode("Xft.antialias:\t1\nXft.rgba:\trgb\n", m) && m == SubpixelRenderingMode.RGB);
    assert(parseXftSubpixelRenderingMode("Xft.rgba: BGR\r\n", m) && m == SubpixelRenderingMode.BGR);
    assert(parseXftSubpixelRenderingMode("Xft.rgba:\tnone\n", m) && m == SubpixelRenderingMode.None);
    assert(parseXftSubpixelRenderingMode("Xft.rgba:\tvrgb\n", m) && m == SubpixelRenderingMode.None);
    assert(!parseXftSubpixelRenderingMode("Xft.rgba:\tunknown\n", m));
    // no antialiasing: no subpixel rendering either
    assert(parseXftSubpixelRenderingMode("Xft.antialias:\t0\nXft.rgba:\trgb\n", m) && m == SubpixelRenderingMode.None);
    // the last definition wins; similar names are other resources
    assert(parseXftSubpixelRenderingMode("Xft.rgba:\trgb\nXft.rgba:\tbgr\n", m) && m == SubpixelRenderingMode.BGR);
    assert(!parseXftSubpixelRenderingMode("Xft.rgbaX:\trgb\n*rgba:\trgb\n", m));
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
    Read X resource manager string of the default X display (`$DISPLAY`), loading libX11 at runtime.

    For backends which don't link libX11 (SDL). Opens and closes its own short-lived X connection.

    Returns: the resources, or null if libX11 or X display is not available, or no resources are set.
    */
    string readXResources() {
        import core.sys.posix.dlfcn : dlopen, dlsym, dlclose, RTLD_NOW, RTLD_LOCAL;
        import std.string : fromStringz;
        alias XOpenDisplayFunc = extern(C) void* function(const(char)* displayName);
        alias XCloseDisplayFunc = extern(C) int function(void* display);
        alias XResourceManagerStringFunc = extern(C) char* function(void* display);

        void* lib = dlopen("libX11.so.6", RTLD_NOW | RTLD_LOCAL);
        if (!lib)
            lib = dlopen("libX11.so", RTLD_NOW | RTLD_LOCAL);
        if (!lib)
            return null;
        scope(exit) dlclose(lib);
        auto openDisplay = cast(XOpenDisplayFunc)dlsym(lib, "XOpenDisplay");
        auto closeDisplay = cast(XCloseDisplayFunc)dlsym(lib, "XCloseDisplay");
        auto resourceManagerString = cast(XResourceManagerStringFunc)dlsym(lib, "XResourceManagerString");
        if (!openDisplay || !closeDisplay || !resourceManagerString)
            return null;
        void* display = openDisplay(null);
        if (!display)
            return null;
        scope(exit) closeDisplay(display);
        char* resources = resourceManagerString(display);
        return resources ? fromStringz(resources).idup : null;
    }

    /**
    Read `Xft.dpi` of the default X display (`$DISPLAY`), loading libX11 at runtime.

    For backends which don't link libX11 (SDL). Opens and closes its own short-lived X connection.

    Returns: DPI, or 0 if libX11 or X display is not available, or `Xft.dpi` is not set.
    */
    int detectXftDpi() {
        string resources = readXResources();
        return resources ? parseXftDpi(resources) : 0;
    }

    /**
    Subpixel order configured by fontconfig for the default font pattern (FC_RGBA, FC_ANTIALIAS), loading
    libfontconfig at runtime (#882).

    Returns: true if fontconfig defines the mode, false if it is not available or the order is unknown.
    */
    bool detectFontconfigSubpixelRenderingMode(out SubpixelRenderingMode mode) {
        import core.sys.posix.dlfcn : dlopen, dlsym, dlclose, RTLD_NOW, RTLD_LOCAL;
        alias FcPatternCreateFunc = extern(C) void* function();
        alias FcPatternDestroyFunc = extern(C) void function(void* p);
        alias FcConfigSubstituteFunc = extern(C) int function(void* config, void* p, int kind);
        alias FcDefaultSubstituteFunc = extern(C) void function(void* p);
        alias FcPatternGetIntegerFunc = extern(C) int function(const(void)* p, const(char)* object, int n, int* i);
        alias FcPatternGetBoolFunc = extern(C) int function(const(void)* p, const(char)* object, int n, int* b);
        enum FcMatchPattern = 0, FcResultMatch = 0;
        enum FC_RGBA_RGB = 1, FC_RGBA_BGR = 2, FC_RGBA_VRGB = 3, FC_RGBA_VBGR = 4, FC_RGBA_NONE = 5;

        mode = SubpixelRenderingMode.None;
        void* lib = dlopen("libfontconfig.so.1", RTLD_NOW | RTLD_LOCAL);
        if (!lib)
            lib = dlopen("libfontconfig.so", RTLD_NOW | RTLD_LOCAL);
        if (!lib)
            return false;
        scope(exit) dlclose(lib);
        auto patternCreate = cast(FcPatternCreateFunc)dlsym(lib, "FcPatternCreate");
        auto patternDestroy = cast(FcPatternDestroyFunc)dlsym(lib, "FcPatternDestroy");
        auto configSubstitute = cast(FcConfigSubstituteFunc)dlsym(lib, "FcConfigSubstitute");
        auto defaultSubstitute = cast(FcDefaultSubstituteFunc)dlsym(lib, "FcDefaultSubstitute");
        auto patternGetInteger = cast(FcPatternGetIntegerFunc)dlsym(lib, "FcPatternGetInteger");
        auto patternGetBool = cast(FcPatternGetBoolFunc)dlsym(lib, "FcPatternGetBool");
        if (!patternCreate || !patternDestroy || !configSubstitute || !defaultSubstitute || !patternGetInteger
                || !patternGetBool)
            return false;
        void* pattern = patternCreate();
        if (!pattern)
            return false;
        scope(exit) patternDestroy(pattern);
        configSubstitute(null, pattern, FcMatchPattern); // the user's and system configuration
        defaultSubstitute(pattern);
        int antialias;
        if (patternGetBool(pattern, "antialias", 0, &antialias) == FcResultMatch && !antialias)
            return true;
        int rgba;
        if (patternGetInteger(pattern, "rgba", 0, &rgba) != FcResultMatch)
            return false;
        switch (rgba) {
            case FC_RGBA_RGB:
                mode = SubpixelRenderingMode.RGB;
                return true;
            case FC_RGBA_BGR:
                mode = SubpixelRenderingMode.BGR;
                return true;
            case FC_RGBA_VRGB, FC_RGBA_VBGR, FC_RGBA_NONE:
                return true;
            default:
                return false; // FC_RGBA_UNKNOWN
        }
    }

    /**
    Subpixel rendering mode configured by the desktop (#882): `Xft.rgba` of the X resources, or fontconfig's
    subpixel order when `Xft.rgba` is not set; None when neither is set.
    */
    SubpixelRenderingMode detectXftSubpixelRenderingMode() {
        SubpixelRenderingMode mode;
        string resources = readXResources();
        if (resources && parseXftSubpixelRenderingMode(resources, mode))
            return mode;
        if (detectFontconfigSubpixelRenderingMode(mode))
            return mode;
        return SubpixelRenderingMode.None;
    }
} else {
    /// `Xft.dpi` is not used on this platform: always returns 0.
    int detectXftDpi() {
        return 0;
    }

    /// `Xft.rgba` is not used on this platform: always returns None.
    SubpixelRenderingMode detectXftSubpixelRenderingMode() {
        return SubpixelRenderingMode.None;
    }
}
