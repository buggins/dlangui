module dlangui.core.config;

version (Windows) {
    // force Unicode definition under Windows
    version = Unicode;
} else {
    version = USE_FREETYPE;
}

// provide default configuratino definitions
version (USE_SDL) {
    // SDL backend already selected
} else version (USE_X11) {
    // X11 backend already selected
} else version (USE_DSFML) {
    // DSFML backend already selected
} else {
    version (Windows) {
        // For Windows
        // by default: no freetype
        version = USE_OPENGL;
    } else version(linux) {
        // Default for Linux: use SDL and OpenGL
        version = USE_SDL;
        version = USE_OPENGL;
    } else version(OSX) {
        // Default: use SDL and OpenGL
        version = USE_SDL;
        version = USE_OPENGL;
    } else {
        // Unknown platform: use SDL and OpenGL
        version = USE_SDL;
        version = USE_OPENGL;
    }
}
