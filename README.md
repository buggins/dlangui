Dlang UI
========

GUI for D programming language, written in D.

* Crossplatform (Win32 and Linux are supported in current version)
* Mostly inspired by Android UI API (layouts, styles, two phase layout, ...)
* Supports highly customizable UI themes and styles
* Supports internationalization
* Hardware acceleration using OpenGL (when built with USE_OPENGL)
* Fallback to Win32 API / XCB when OpenGL is not available
* Actually it's a port (with major refactoring) of GUI library for cross platform OpenGL based implementation of Cool Reader app prokeject from C++.
* Almost ready for 2D games development
* Goal: provide set of widgets suitable for building of IDE.


Win32 builds
------------

* Under windows, uses Win32 API as backend.
* Optionally, may use OpenGL acceleration via DerelictGL3/WGL.
* Uses Win32 API for font rendering.
* Optinally can use FreeType for font rendering.

Linux builds
------------

* Uses XCB (X C binding) as backend.
* Uses shared memory images for faster drawing.
* Uses FreeType for font rendering.
* TODO: Use FontConfig to get font list.
* TODO: OpenGL initializes ok, but images not visible on screen. Disabled temporary.

Other platforms
---------------

* Other platforms support may be added easy


Third party components used
---------------------------

* DerelictGL3 - for OpenGL support
* DerelictFT + FreeType library support under linux and optionally under Windows.
* DerelictFI + FreeImage library support for decoding of images
* WindowsAPI bindings from http://www.dsource.org/projects/bindings/wiki/WindowsApi (patched)
* XCB and X11 bindings (patched) TODO: provide links


Hello World
--------------------------------------------------------------

	// main.d
	import dlangui.all;
	mixin DLANGUI_ENTRY_POINT;

	/// entry point for dlangui based application
	extern (C) int UIAppMain(string[] args) {
	    // resource directory search paths
	    string[] resourceDirs = [
	        appendPath(exePath, "../res/"),   // for Visual D and DUB builds
	        appendPath(exePath, "../../res/") // for Mono-D builds
	    ];

	    // setup resource directories - will use only existing directories
	    drawableCache.setResourcePaths(resourceDirs);

            // optinally setup internatilnalization (if used)
	    // setup i18n - look for i18n directory inside one of passed directories
	    i18n.findTranslationsDir(resourceDirs);
	    // select translation file - for english language
	    i18n.load("en.ini"); //"ru.ini", "en.ini"
	
	    // create window
	    Window window = Platform.instance.createWindow("My Window", null);
            // create some widget to show in window
	    window.mainWidget = (new Button()).text("Hello world"d);
            // show window
            window.show();
	    // run message loop
	    return Platform.instance.enterMessageLoop();
	}
