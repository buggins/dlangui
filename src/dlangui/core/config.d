module dlangui.core.config;

version (USE_FREETYPE) {
    immutable bool USE_FREETYPE = true;
} else {
    version (Windows) {
        immutable bool ENABLE_FREETYPE = false;
    } else {
        immutable bool ENABLE_FREETYPE = true;
    }
}

// provide default configuratino definitions
version (USE_SDL) {
    // SDL backend already selected using version identifier
    version (USE_OPENGL) {
        immutable bool ENABLE_OPENGL = true;
    } else {
        immutable bool ENABLE_OPENGL = false;
    }
    immutable bool BACKEND_SDL = true;
    immutable bool BACKEND_X11 = false;
    immutable bool BACKEND_DSFML = false;
    immutable bool BACKEND_WIN32 = false;
} else version (USE_X11) {
    // X11 backend already selected using version identifier
    version (USE_OPENGL) {
        immutable bool ENABLE_OPENGL = true;
    } else {
        immutable bool ENABLE_OPENGL = false;
    }
    immutable bool BACKEND_SDL = false;
    immutable bool BACKEND_X11 = true;
    immutable bool BACKEND_DSFML = false;
    immutable bool BACKEND_WIN32 = false;
} else version (USE_WIN32) {
    // Win32 backend already selected using version identifier
    version (USE_OPENGL) {
        immutable bool ENABLE_OPENGL = true;
    } else {
        immutable bool ENABLE_OPENGL = false;
    }
    immutable bool BACKEND_SDL = false;
    immutable bool BACKEND_X11 = false;
    immutable bool BACKEND_DSFML = false;
    immutable bool BACKEND_WIN32 = true;
} else version (USE_DSFML) {
    // DSFML backend already selected using version identifier
    version (USE_OPENGL) {
        immutable bool ENABLE_OPENGL = true;
    } else {
        immutable bool ENABLE_OPENGL = false;
    }
    immutable bool BACKEND_SDL = false;
    immutable bool BACKEND_X11 = false;
    immutable bool BACKEND_DSFML = true;
    immutable bool BACKEND_WIN32 = false;
} else {
    // no backend selected: set default based on platform
    version (Windows) {
        // For Windows
        immutable bool ENABLE_OPENGL = true;
        immutable bool BACKEND_SDL = false;
        immutable bool BACKEND_X11 = false;
        immutable bool BACKEND_DSFML = false;
        immutable bool BACKEND_WIN32 = true;
    } else version(linux) {
        // Default for Linux: use SDL and OpenGL
        immutable bool ENABLE_OPENGL = true;
        immutable bool BACKEND_SDL = true;
        immutable bool BACKEND_X11 = false;
        immutable bool BACKEND_DSFML = false;
        immutable bool BACKEND_WIN32 = false;
    } else version(OSX) {
        // Default: use SDL and OpenGL
        immutable bool ENABLE_OPENGL = true;
        immutable bool BACKEND_SDL = true;
        immutable bool BACKEND_X11 = false;
        immutable bool BACKEND_DSFML = false;
        immutable bool BACKEND_WIN32 = false;
    } else {
        // Unknown platform: use SDL and OpenGL
        immutable bool ENABLE_OPENGL = true;
        immutable bool BACKEND_SDL = true;
        immutable bool BACKEND_X11 = false;
        immutable bool BACKEND_DSFML = false;
        immutable bool BACKEND_WIN32 = false;
    }
}
