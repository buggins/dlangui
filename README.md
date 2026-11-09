Dlang UI
========
[![CI](https://github.com/buggins/dlangui/actions/workflows/pipeline.yml/badge.svg)](https://github.com/buggins/dlangui/actions/workflows/pipeline.yml) [![DUB](https://img.shields.io/dub/v/dlangui)](https://code.dlang.org/packages/dlangui) [![PayPal donate button](https://img.shields.io/badge/paypal-donate-yellow.svg)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=KPSNU8TYF6M5N "Donate once-off to this project using Paypal")

Cross platform GUI for D. Widgets, layouts, styles, themes, unicode, i18n, OpenGL based acceleration.

![screenshot](http://buggins.github.io/dlangui/screenshots/screenshot-example1-windows.png "Screenshot of widgets demo app example1")


GitHub page: [https://github.com/buggins/dlangui](https://github.com/buggins/dlangui)

DUB package: [https://code.dlang.org/packages/dlangui](https://code.dlang.org/packages/dlangui)

API Documentation: [https://dlangui.dpldocs.info/](https://dlangui.dpldocs.info/)

Wiki: [https://github.com/buggins/dlangui/wiki/Home](https://github.com/buggins/dlangui/wiki/Home)

Getting Started Tutorial: [https://github.com/buggins/dlangui/wiki/Getting-Started](https://github.com/buggins/dlangui/wiki/Getting-Started)

Old project site with screenshots (not updated since 2017): [http://buggins.github.io/dlangui](http://buggins.github.io/dlangui)

Coding style: [https://github.com/buggins/dlangui/blob/master/CODING_STYLE.md](https://github.com/buggins/dlangui/blob/master/CODING_STYLE.md)

Main features:

* Crossplatform: Windows, Linux and macOS (macOS builds in CI, but is not tested at runtime); also runs in a text console
* Mostly inspired by Android UI API (layouts, styles, two phase layout, ...)
* Supports highly customizable UI themes and styles; light and dark themes included
* DML: QML-like markup language to describe widget trees
* Supports internationalization
* HiDPI support: sizes in points (`pt`) scale with screen DPI
* Hardware acceleration using OpenGL (when built with version USE_OPENGL)
* Fallback to pure Win32 API / SDL / X11 when OpenGL is not available (e.g. opengl dynamic library cannot be loaded)
* Actually it's a port (with major refactoring) of GUI library for cross platform OpenGL based implementation of Cool Reader app project from C++.
* Non thread safe - all UI operations should be performed in single thread
* Simple 3d engine - allows to embed 3D scenes within GUI

D compiler versions supported
-----------------------------

Needs DMD frontend 2.100.2 or newer to build (DMD 2.100.2+, LDC 1.30+, or a GDC with the same frontend).

Hello World
-----------

dub.json:
```json
{
    "name": "hello",
    "targetType": "executable",
    "dependencies": {
        "dlangui": "~>0.11.3"
    }
}
```

source/app.d:
```d
import dlangui;

mixin APP_ENTRY_POINT;

/// entry point for dlangui based application
extern (C) int UIAppMain(string[] args) {
    // create window
    Window window = Platform.instance.createWindow("Hello", null);
    // create a widget tree from DML (QML-like markup)
    window.mainWidget = parseML(q{
        VerticalLayout {
            margins: 10pt
            padding: 10pt
            TextWidget { text: "Hello, world!"; textColor: "red"; fontSize: 150% }
            Button { id: btnOk; text: "Close" }
        }
    });
    // handle button click
    window.mainWidget.childById!Button("btnOk").click = delegate(Widget w) {
        window.close();
        return true;
    };
    // show window and run message loop
    window.show();
    return Platform.instance.enterMessageLoop();
}
```

Build and run with `dub run`. More examples are in the [Wiki](https://github.com/buggins/dlangui/wiki) and in the `examples` directory.

Examples
--------

Run from the repository root with `dub run dlangui:<name>`, e.g. `dub run dlangui:example1`:

* `example1` - widgets demo
* `helloworld` - simple DML form
* `dmledit` - DML editor with live preview
* `tetris` - game
* `d3d`, `dminer` - 3D scenes
* `spreadsheet`, `ircclient`, `dragon` - other demos

Widgets
-------

List of widgets, layouts and other is available in the [Wiki](https://github.com/buggins/dlangui/wiki#widgets)

Resources
---------

Resources like fonts and images use reference counting. For proper resource freeing, always destroy widgets explicitly (or let their parent widget destroy them).

* FontManager: provides access to fonts
* Images: .png or .jpg images; if filename ends with .9.png, it's autodetected as nine-patch image (see Android drawables description)
* StateDrawables: .xml file can describe list of other drawables to choose based on widget's State (.xml files from android themes can be used directly)
* imageCache allows to cache unpacked images
* drawableCache provides access by resource id (string, usually filename w/o extension) to drawables located in specified list of resource directories.

Styles and Themes
-----------------

Styles and themes are a bit similar to ones in Android API.

* Theme is a container for styles. Can be loaded from XML theme resource file.
* Styles are accessible in theme by string ID.
* Styles can be nested to form hierarchy - when some attribute is missing in style, value from base style will be used.
* State substyles are supported: allow to change widget appearance dynamically based on its state.
* Widgets use style attributes directly from assigned style. When some attribute is being changed in widget, it creates its own copy of base style,
which allows to modify some of attributes, while getting base style attributes if they are not changed in widget. This trick can minimize memory usage for widget attributes when
standard values are used.
* Included themes: `theme_default` (similar to MS Visual Studio 2013) and `theme_dark`; select one with `Platform.instance.uiTheme = "theme_dark";`
* Resources can be either embedded into executable or loaded from external resource directory in runtime

HiDPI
-----

* Sizes in themes and DML can be given in points (`pt`), which scale with the screen DPI; pixel sizes (`px`) don't scale.
* Images can be provided in `mdpi` and `hdpi` variants.
* Screen DPI detection: Windows uses the system DPI; on Linux, the desktop's `Xft.dpi` setting is used when set; SDL detects scaled (e.g. Retina) displays.
* Applications can override the DPI with `overrideScreenDPI`.

Important notice
================

If build of your app is failed due to dlangui or its dependencies, probably you have not upgraded dependencies.

Try following:
```sh
dub upgrade
dub build --force
```
As well, sometimes removing of dub.selections.json can help.


Windows builds
--------------

* Under Windows, uses Win32 API (default configuration) or SDL2 (`sdl` configuration) as backend.
* Optionally, may use OpenGL acceleration
* Uses Win32 API for font rendering.
* Optionally can use FreeType for font rendering.


Build and run demo app using DUB:
```sh
git clone https://github.com/buggins/dlangui.git
cd dlangui/examples/example1
dub run --build=release
```

To avoid showing console window, add a `win_app.def` file to your package source directory and add a line to your dub.json.

src/win_app.def:
```
EXETYPE NT
SUBSYSTEM WINDOWS
```
dub.json:
```json
"sourceFiles-windows": ["$PACKAGE_DIR/src/win_app.def"],
```

Linux builds (DUB)
------------------

* Uses SDL2 as a backend (or native X11 with `x11` configuration).
* Uses FreeType for font rendering.
* Uses FontConfig to get list of available fonts.
* OpenGL can be optionally used for better drawing performance.

SDL2, FreeType, FontConfig and OpenGL are loaded at runtime, so only their runtime (binary) packages are needed.
To build, besides a D compiler and DUB, the zlib development package is needed
(DlangUI links with zlib; Linux distribution builds of LDC and GDC use system zlib).

| Distribution | Build | Runtime |
|---|---|---|
| Debian, Ubuntu | `zlib1g-dev` | `libsdl2-2.0-0 libfreetype6 libfontconfig1 libgl1` |
| Fedora | `zlib-devel` | `SDL2 freetype fontconfig mesa-libGL` |
| Arch, Manjaro | `zlib` | `sdl2 freetype2 fontconfig libglvnd` |

E.g. in Ubuntu:
```sh
sudo apt-get install zlib1g-dev libsdl2-2.0-0 libfreetype6 libfontconfig1 libgl1
```
The `x11` configuration links libX11 and GLX at build time, so it additionally needs their development packages
(`libx11-dev libgl-dev` on Debian/Ubuntu, `libX11-devel libglvnd-devel` on Fedora).

Build and run on Linux using DUB:
```sh
git clone https://github.com/buggins/dlangui.git
cd dlangui
dub run dlangui:example1
```

MacOS builds (DUB)
------------------

* Uses SDL2 as a backend, FreeType for font rendering. Install SDL2 e.g. with Homebrew: `brew install sdl2`.
* DlangUI builds on macOS in CI, but it is not tested at runtime. The support is **not guaranteed**.

Console (text mode)
-------------------

The `console` configuration draws the UI with text characters in a terminal (ANSI terminals on Linux and macOS,
the Windows console on Windows), without OpenGL or FreeType. Build with `-c console`, e.g.:
```sh
dub run dlangui:example1 -c console
```

Other platforms
---------------

* Android: there is a NativeActivity backend (`platforms/android`, makefiles in `android/`), but it is not maintained or tested.
* Other platforms support may be added easily


Third party components used
---------------------------

* `bindbc-opengl` - for OpenGL support
* `bindbc-freetype` + FreeType library support under linux and optionally under Windows.
* `bindbc-sdl` + SDL2 for cross platform support
* `x11` and `glx-d` bindings for the native X11 backend
* `arsd-official` For image reading and XML parsing
* `inilike` and `icontheme` - freedesktop icon themes on Linux


DlangIDE project
----------------

[DlangIDE](https://github.com/buggins/dlangide) is a cross platform D language IDE built with DlangUI:
DUB projects, DCD based completion and navigation, build, run and debug.

Run the latest release:
```sh
dub run dlangide --build=release
```


Reporting issues and contributing
---------------------------------

Please report bugs and feature requests in [GitHub issues](https://github.com/buggins/dlangui/issues).
Pull requests are welcome; see the [coding style](https://github.com/buggins/dlangui/blob/master/CODING_STYLE.md).


License
-------

Boost Software License 1.0, see [LICENSE.txt](LICENSE.txt).
The icons of the default theme have their own license, see [LICENSE_default_theme_icons.txt](LICENSE_default_theme_icons.txt).
