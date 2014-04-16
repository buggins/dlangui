Dlang UI
========

GUI for D programming language, written in D.

* Crossplatform (Win32 and Linux are supported in current version)
* Mostly inspired by Android UI API (layouts, styles, two phase layout, ...)
* Supports highly customizable UI themes and styles
* Hardware acceleration using OpenGL (when built with USE_OPENGL)
* Fallback to Win32 API / XCB when OpenGL is not available

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
