Dlang UI
========

GUI for D programming language, written in D.

Alpha stage of development.

* Crossplatform (Win32 and Linux are supported in current version)
* Mostly inspired by Android UI API (layouts, styles, two phase layout, ...)
* Supports highly customizable UI themes and styles
* Supports internationalization
* Hardware acceleration using OpenGL (when built with USE_OPENGL)
* Fallback to Win32 API / XCB when OpenGL is not available
* Actually it's a port (with major refactoring) of GUI library for cross platform OpenGL based implementation of Cool Reader app prokeject from C++.
* Almost ready for 2D games development
* Goal: provide set of widgets suitable for building of IDE.

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
* VSpacer - vertical spacer - just an empty widget with layoutHeight == FILL_PARENT, to fill vertical space in layouts
* HSpacer - horizontal spacer - just an empty widget with layoutWidth == FILL_PARENT, to fill horizontal space in layouts
* ScrollBar - scroll bar
* TabControl - tabs widget, allows to select one of tabs
* TabHost - container for pages controlled by TabControl
* TabWidget - combination of TabControl and TabHost

Layouts
-------

Similar to layouts in Android

* LinearLayout - layout children horizontally or vertically depending on orientation
* VerticalLayout - just a LinearLayout with vertical orientation
* HorizontalLayout - just a LinearLayout with vertical orientation
* FrameLayout - all children occupy the same place; usually onle one of them is visible

TODOs:

* TableLayout - layout children

List Views
----------

Lists are implemented similar to Android UI API.

* ListWidget - layout dynamic items horizontally or vertically (one in row/column) with automatic scrollbar; can reuse widgets for similar items
* ListAdapter - interface to provide data and widgets for ListWidget
* WidgetListAdapter - simple implementation of ListAdapter interface - just a list of widgets (one per list item) to show

TODOs:

* Multicolumn lists
* Tree view

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

* Theme is a container for styles. TODO: load themes from XML.
* Styles are accessible in theme by string ID.
* Styles can be nested to form hiararchy - when some attribute is missing in style, value from base style will be used.
* State substyles are supported: allow to change widget appearance dynamically based on its state.
* Widgets use style attributes directly from assigned style. When some attribute is being changed in widget, it creates its own copy of base style, 
which allows to modify some of attributes, while getting base style attributes if they are not changed in widget. This trick can minimize memory usage for widget attributes when 
standard values are used.



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
