Dlang UI
========
[![PayPayl donate button](https://img.shields.io/badge/paypal-donate-yellow.svg)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=KPSNU8TYF6M5N "Donate once-off to this project using Paypal")

Cross platform GUI for D. Widgets, layouts, styles, themes, unicode, i18n, OpenGL based acceleration.

![screenshot](http://buggins.github.io/dlangui/screenshots/screenshot-example1-windows.png "Screenshot of widgets demo app example1")


GitHub page: [https://github.com/buggins/dlangui](https://github.com/buggins/dlangui)

Project site: [http://buggins.github.io/dlangui](http://buggins.github.io/dlangui)

API Documentation: [http://buggins.github.io/dlangui/ddox](http://buggins.github.io/dlangui/ddox)

Wiki: [https://github.com/buggins/dlangui/wiki/Home](https://github.com/buggins/dlangui/wiki/Home)

Getting Started Tutorial: [https://github.com/buggins/dlangui/wiki/Getting-Started](https://github.com/buggins/dlangui/wiki/Getting-Started)

Screenshots: [http://buggins.github.io/dlangui/screenshots.html](http://buggins.github.io/dlangui/screenshots.html)

Coding style: [https://github.com/buggins/dlangui/blob/master/CODING_STYLE.md](https://github.com/buggins/dlangui/blob/master/CODING_STYLE.md)

Main features:

* Crossplatform (Win32, OSX, Linux and Android are supported in current version)
* Mostly inspired by Android UI API (layouts, styles, two phase layout, ...)
* Supports highly customizable UI themes and styles
* Supports internationalization
* Hardware acceleration using OpenGL (when built with version USE_OPENGL)
* Fallback to pure Win32 API / SDL / X11 when OpenGL is not available (e.g. opengl dynamic library cannot be loaded)
* Actually it's a port (with major refactoring) of GUI library for cross platform OpenGL based implementation of Cool Reader app project from C++.
* Non thread safe - all UI operations should be preformed in single thread
* Simple 3d engine - allows to embed 3D scenes within GUI

D compiler versions supported
-----------------------------

Needs DMD frontend 2.100.2 or newer to build

Widgets
-------

List of widgets, layouts and other is available in the [Wiki](https://github.com/buggins/dlangui/wiki#widgets)

Resources
---------

Resources like fonts and images use reference counting. For proper resource freeing, always destroy widgets implicitly.

* FontManager: provides access to fonts
* Images: .png or .jpg images; if filename ends with .9.png, it's autodetected as nine-patch image (see Android drawables description)
* StateDrawables: .xml file can describe list of other drawables to choose based on widget's State (.xml files from android themes can be used directly)
* imageCache allows to cache unpacked images
* drawableCache provides access by resource id (string, usually filename w/o extension) to drawables located in specified list of resource directories.

Styles and Themes
-----------------

Styles and themes are a bit similar to ones in Android API.

* Theme is a container for styles. Can be load from XML theme resource file.
* Styles are accessible in theme by string ID.
* Styles can be nested to form hierarchy - when some attribute is missing in style, value from base style will be used.
* State substyles are supported: allow to change widget appearance dynamically based on its state.
* Widgets use style attributes directly from assigned style. When some attribute is being changed in widget, it creates its own copy of base style,
which allows to modify some of attributes, while getting base style attributes if they are not changed in widget. This trick can minimize memory usage for widget attributes when
standard values are used.
* Current default theme is similar to one in MS Visual Studio 2013
* Resources can be either embedded into executable or loaded from external resource directory in runtime

Important notice
================

If build of your app is failed due to dlangui or its dependencies, probably you have not upgraded dependencies.

Try following:
```sh
dub upgrade --force-remove
dub build --force
```
As well, sometimes removing of dub.json.selections can help.


Win32 builds
------------

* Under windows, uses SDL2 or Win32 API as backend.
* Optionally, may use OpenGL acceleration
* Uses Win32 API for font rendering.
* Optinally can use FreeType for font rendering.
* Executable size for release Win32 API based build is 830K.


Build and run demo app using DUB:
```sh
git clone --recursive https://github.com/buggins/dlangui.git
cd dlangui/examples/example1
dub run --build=release
```

To avoid showing console window add win_app.def file to your package source directory and add line to your dub.json.

win_app.def:
```json
"sourceFiles": ["$PACKAGE_DIR/src/win_app.def"]
```
dub.json:
```json
"sourceFiles-windows": ["$PACKAGE_DIR/src/win_app.def"],
```

Linux builds (DUB)
------------------

* Uses SDL2 as a backend.
* Uses FreeType for font rendering.
* Uses FontConfig to get list of available fonts.
* OpenGL can be optionally used for better drawing performance.

        libsdl2, libfreetype, libfontconfig

E.g. in Ubuntu, you can use following command to enable SDL2 backend builds:
```sh
sudo apt-get install libsdl2-dev
```
In runtime, .so for following libraries are being loaded (binary packages required):
```
freetype, opengl, fontconfig
```

Build and run on Linux using DUB:
```sh
cd examples/example1
dub run dlangui:example1
```
MacOS builds (DUB)
------------------
DlangUI theoretically supports MacOS, but I have no way of testing if it actually work.
The support is **not guaranteed**.

Other platforms
---------------

* Other platforms support may be added easy


Third party components used
---------------------------

* `binbc-opengl` - for OpenGL support
* `bindbc-freetype` + FreeType library support under linux and optionally under Windows.
* `bindbc-sdl` + SDL2 for cross platform support
* X11 binding when SDL2 is not used
* `arsd-official` For image reading and XML parsing


Hello World
--------------------------------------------------------------

Please refer to the [Wiki](https://github.com/buggins/dlangui/wiki#hello-world) for a hello world example.

DlangIDE project
------------------------------------------------------------

It is a project to build D language IDE using DlangUI library.

But it already can open DUB based projects, edit, build and run them.

Simple syntax highlight.

DCD integration: go to definition and autocompletion for D source code.

Project page: [https://github.com/buggins/dlangide](https://github.com/buggins/dlangide)

How to build and run using DUB:
```sh
git clone https://github.com/buggins/dlangide.git
cd dlangide
dub run
```
