Dlang UI
========

Cross platform GUI for D. Layouts, styles, themes, unicode, i18n, OpenGL based acceleration, widget set.

Project page: [https://github.com/buggins/dlangui](https://github.com/buggins/dlangui)

API Documentation: [http://buggins.github.io/dlangui/ddox](http://buggins.github.io/dlangui/ddox)

Wiki: [https://github.com/buggins/dlangui/wiki/Home](https://github.com/buggins/dlangui/wiki/Home)

Some screenshots: [http://buggins.github.io/dlangui/screenshots.html](http://buggins.github.io/dlangui/screenshots.html)

[![Gitter](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/buggins/dlangui?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

[![Build Status](https://travis-ci.org/buggins/dlangui.svg?branch=master)](https://travis-ci.org/buggins/dlangui)


Main features:

* Crossplatform (Win32 and Linux are supported in current version); can use SDL2 as a backend.
* Mostly inspired by Android UI API (layouts, styles, two phase layout, ...)
* Supports highly customizable UI themes and styles
* Supports internationalization
* Hardware acceleration using OpenGL (when built with version USE_OPENGL)
* Fallback to pure Win32 API / SDL / XCB when OpenGL is not available (e.g. opengl dynamic library cannot be loaded)
* Actually it's a port (with major refactoring) of GUI library for cross platform OpenGL based implementation of Cool Reader app project from C++.
* Non thread safe - all UI operations should be preformed in single thread


Widgets
-------

* Widget - base class for all widgets and widget containers, similar to Android's View

Currently implemented widgets:

* TextWidget - simple static text (TODO: implement multiline formatting)
* ImageWidget - static image
* Button - simple button with text label
* ImageButton - image only button
* TextImageButton - button with icon and label
* CheckBox - check button with label
* RadioButton - radio button with label
* EditLine - single line edit
* EditBox - multiline editor
* VSpacer - vertical spacer - just an empty widget with layoutHeight == FILL_PARENT, to fill vertical space in layouts
* HSpacer - horizontal spacer - just an empty widget with layoutWidth == FILL_PARENT, to fill horizontal space in layouts
* ScrollBar - scroll bar
* TabControl - tabs widget, allows to select one of tabs
* TabHost - container for pages controlled by TabControl
* TabWidget - combination of TabControl and TabHost
* GridWidgetBase - abstract Grid widget
* StringGrid - grid view with strings content
* TreeWidget - tree view
* ComboBox - combo box with text items
* ToolBar - tool bar with buttons
* StatusLine - control to show misc application statuses
* AppFrame - base class for easy implementation of apps with main menu, toolbars, status bar

Layouts
-------

Similar to layouts in Android

* LinearLayout - layout children horizontally or vertically depending on orientation
* VerticalLayout - just a LinearLayout with vertical orientation
* HorizontalLayout - just a LinearLayout with vertical orientation
* FrameLayout - all children occupy the same place; usually onle one of them is visible
* TableLayout - children are aligned into rows and columns of table
* ResizerWidget - put into LinearLayout between two other widgets to resize them using mouse
* ScrollWidget - allow to scroll its child if its dimensions are bigger than possible
* DockHost - layout with main widget and additional dockable panels around it
* DockWindow - dockable window with caption, usually to be used with DockHost

List Views
----------

Lists are implemented similar to Android UI API.

* ListWidget - layout dynamic items horizontally or vertically (one in row/column) with automatic scrollbar; can reuse widgets for similar items
* ListAdapter - interface to provide data and widgets for ListWidget
* WidgetListAdapter - simple implementation of ListAdapter interface - just a list of widgets (one per list item) to show

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
* Styles can be nested to form hiararchy - when some attribute is missing in style, value from base style will be used.
* State substyles are supported: allow to change widget appearance dynamically based on its state.
* Widgets use style attributes directly from assigned style. When some attribute is being changed in widget, it creates its own copy of base style, 
which allows to modify some of attributes, while getting base style attributes if they are not changed in widget. This trick can minimize memory usage for widget attributes when 
standard values are used.
* Current default theme is similar to one in MS Visual Studio 2013


Win32 builds
------------

* Under windows, uses SDL2 or Win32 API as backend.
* Optionally, may use OpenGL acceleration via DerelictGL3/WGL.
* Uses Win32 API for font rendering.
* Optinally can use FreeType for font rendering.
* Executable size for release Win32 API based build is 830K.


Build and run demo app using DUB:

        git clone https://github.com/buggins/dlangui.git
        cd dlangui
        dub run dlangui:example1 --build=release

Run Tetris game example

        dub run dlangui:tetris --build=release

To develop using Visual-D or MonoD, download sources for dlabgui and dependencies into some directory:

        git clone https://github.com/buggins/dlangui.git
        git clone https://github.com/DerelictOrg/DerelictUtil.git
        git clone https://github.com/DerelictOrg/DerelictGL3.git
        git clone https://github.com/DerelictOrg/DerelictFT.git
        git clone https://github.com/DerelictOrg/DerelictSDL2.git
        git clone https://github.com/gecko0307/dlib.git
        git clone https://github.com/Devisualization/image.git de_image
  

Then open dlangui.sln using Visual D (or dlangui-monod.sln for MonoD)




Linux builds
------------

* Uses SDL2 or XCB as a backend (SDL2 is recommended, since has better support now).
* Uses shared memory images for faster drawing.
* Uses FreeType for font rendering.
* TODO: Use FontConfig to get font list.
* OpenGL is now working under SDL2 only.
* Entering of unicode characters is now working under SDL2 only.


For linux build with SDL2 backend, following libraries are required:

        libsdl2

To build dlangui apps with XCB backend, development packages for following libraries required for XCB backend build:

        xcb, xcb-util, xcb-shm, xcb-image, xcb-keysyms, X11-xcb, X11

E.g. in Ubuntu, you can use following command to enable SDL2 backend builds:

        sudo apt-get install libsdl2-dev

or (for XCB backend)

        sudo apt-get install libxcb-image0-dev libxcb-shm0-dev libxcb-keysyms1-dev


In runtime, .so for following libraries are being loaded (binary packages required):

        freetype, opengl


Build and run on Linux using DUB:

        dub run dlangui:example1

Development using Mono-D: 

* open solution dlangui/dlanguimonod.sln 
* build and run project example1

You need fresh version of MonoDevelop to use Mono-D. It can be installed from PPA repository.

        sudo add-apt-repository ppa:ermshiperete/monodevelop
        sudo apt-get update
        sudo apt-get install monodevelop-current


Other platforms
---------------

* Other platforms support may be added easy


Third party components used
---------------------------

* DerelictGL3 - for OpenGL support
* DerelictFT + FreeType library support under linux and optionally under Windows.
* DerelictSDL2 + SDL2 for cross platform support
* WindowsAPI bindings from http://www.dsource.org/projects/bindings/wiki/WindowsApi (patched)
* XCB and X11 bindings (patched) when SDL2 is not used; TODO: provide links
* DLIB - for loading images (it replaced FreeImage recently)


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
	    Platform.instance.resourceDirs = resourceDirs;
	    // select translation file - for english language
	    Platform.instance.uiLanguage = "en";
	    // load theme from file "theme_default.xml"
	    Platform.instance.uiTheme = "theme_default";
	
	    // create window
	    Window window = Platform.instance.createWindow("My Window", null);
	    // create some widget to show in window
	    window.mainWidget = (new Button()).text("Hello world"d).textColor(0xFF0000); // red text
	    // show window
	    window.show();
	    // run message loop
	    return Platform.instance.enterMessageLoop();
	}


Sample dub.json:
--------------------------------

	{
	    "name": "myproject",
	    "description": "sample DLangUI project",
	    "homepage": "https://github.com/buggins/dlangui",
	    "license": "Boost",
	    "authors": ["Vadim Lopatin"],
	
	    "targetName": "example",
	    "targetPath": "bin",
	    "targetType": "executable",
	
	    "sourcePaths": ["src"],
	
	    "sourceFiles": [
	         "src/app.d"
	    ],

	    "copyFiles": [
	        "res"
	    ],

	    "dependencies": {
	        "dlangui:dlanguilib": "~master"
	    }
	}


DlangIDE project
------------------------------------------------------------

It is a project to build D language IDE using DlangUI library.

Now it's in early alpha stage, and could be used as a demo for DlangUI.

Project page: [https://github.com/buggins/dlangide](https://github.com/buggins/dlangide)

How to build and run using DUB:
	
	git clone https://github.com/buggins/dlangide.git
	cd dlangide
	dub run

