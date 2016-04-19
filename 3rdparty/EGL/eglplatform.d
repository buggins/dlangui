/* dstep -I/path/to/ndk-r9d/toolchains/llvm-3.4/prebuilt/linux-x86/lib/clang/3.4/include /path/to/ndk-r9d/platforms/android-9/arch-x86/usr/include/EGL/eglplatform.h -o eglplatform.d*/

module EGL.eglplatform;

import android.native_window;

version (Android):
extern (C):
@system:
nothrow:
@nogc:

struct egl_native_pixmap_t;

alias ANativeWindow* EGLNativeWindowType;
alias egl_native_pixmap_t* EGLNativePixmapType;
alias void* EGLNativeDisplayType;
alias EGLNativeDisplayType NativeDisplayType;
alias EGLNativePixmapType NativePixmapType;
alias EGLNativeWindowType NativeWindowType;
alias int EGLint;
