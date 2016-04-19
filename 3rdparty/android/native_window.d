/* dstep -I/path/to/ndk-r9d/platforms/android-9/arch-x86/usr/include -I/path/to/ndk-r9d/toolchains/llvm-3.4/prebuilt/linux-x86/lib/clang/3.4/include /path/to/ndk-r9d/platforms/android-9/arch-x86/usr/include/android/native_window.h -o native_window.d*/

module android.native_window;

import android.rect;

version (Android):
extern (C):
@system:
nothrow:
@nogc:

enum
{
    WINDOW_FORMAT_RGBA_8888 = 1,
    WINDOW_FORMAT_RGBX_8888 = 2,
    WINDOW_FORMAT_RGB_565 = 4
}

struct ANativeWindow;

struct ANativeWindow_Buffer
{
    int width;
    int height;
    int stride;
    int format;
    void* bits;
    uint[6] reserved;
}

void ANativeWindow_acquire(ANativeWindow* window);
void ANativeWindow_release(ANativeWindow* window);
int ANativeWindow_getWidth(ANativeWindow* window);
int ANativeWindow_getHeight(ANativeWindow* window);
int ANativeWindow_getFormat(ANativeWindow* window);
int ANativeWindow_setBuffersGeometry(ANativeWindow* window, int width, int height, int format);
int ANativeWindow_lock(ANativeWindow* window, ANativeWindow_Buffer* outBuffer, ARect* inOutDirtyBounds);
int ANativeWindow_unlockAndPost(ANativeWindow* window);
