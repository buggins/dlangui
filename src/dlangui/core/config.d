module dlangui.core.config;

version (USE_FREETYPE) {
    enum ENABLE_FREETYPE = true;
} else {
    version (Windows) {
        enum ENABLE_FREETYPE = false;
    } else {
        enum ENABLE_FREETYPE = true;
    }
}

// provide default configuratino definitions
version (USE_SDL) {
    // SDL backend already selected using version identifier
    version (USE_OPENGL) {
        enum ENABLE_OPENGL = true;
    } else {
        enum ENABLE_OPENGL = false;
    }
    enum BACKEND_SDL = true;
    enum BACKEND_X11 = false;
    enum BACKEND_DSFML = false;
    enum BACKEND_WIN32 = false;
} else version (USE_X11) {
    // X11 backend already selected using version identifier
    version (USE_OPENGL) {
        enum ENABLE_OPENGL = true;
    } else {
        enum ENABLE_OPENGL = false;
    }
    enum BACKEND_SDL = false;
    enum BACKEND_X11 = true;
    enum BACKEND_DSFML = false;
    enum BACKEND_WIN32 = false;
} else version (USE_WIN32) {
    // Win32 backend already selected using version identifier
    version (USE_OPENGL) {
        enum ENABLE_OPENGL = true;
    } else {
        enum ENABLE_OPENGL = false;
    }
    enum BACKEND_SDL = false;
    enum BACKEND_X11 = false;
    enum BACKEND_DSFML = false;
    enum BACKEND_WIN32 = true;
} else version (USE_DSFML) {
    // DSFML backend already selected using version identifier
    version (USE_OPENGL) {
        enum ENABLE_OPENGL = true;
    } else {
        enum ENABLE_OPENGL = false;
    }
    enum BACKEND_SDL = false;
    enum BACKEND_X11 = false;
    enum BACKEND_DSFML = true;
    enum BACKEND_WIN32 = false;
} else {
    // no backend selected: set default based on platform
    version (Windows) {
        // For Windows
        enum ENABLE_OPENGL = true;
        enum BACKEND_SDL = false;
        enum BACKEND_X11 = false;
        enum BACKEND_DSFML = false;
        enum BACKEND_WIN32 = true;
    } else version(linux) {
        // Default for Linux: use SDL and OpenGL
        enum ENABLE_OPENGL = true;
        enum BACKEND_SDL = true;
        enum BACKEND_X11 = false;
        enum BACKEND_DSFML = false;
        enum BACKEND_WIN32 = false;
    } else version(OSX) {
        // Default: use SDL and OpenGL
        enum ENABLE_OPENGL = true;
        enum BACKEND_SDL = true;
        enum BACKEND_X11 = false;
        enum BACKEND_DSFML = false;
        enum BACKEND_WIN32 = false;
    } else {
        // Unknown platform: use SDL and OpenGL
        enum ENABLE_OPENGL = true;
        enum BACKEND_SDL = true;
        enum BACKEND_X11 = false;
        enum BACKEND_DSFML = false;
        enum BACKEND_WIN32 = false;
    }
}
