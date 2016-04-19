/* dstep -I/path/to/ndk-r10/platforms/android-9/arch-x86/usr/include -I/path/to/ndk-r10/toolchains/llvm-3.4/prebuilt/linux-x86/lib/clang/3.4/include /path/to/ndk-r10/platforms/android-9/arch-x86/usr/include/android/bitmap.h -o bitmap.d*/

module android.bitmap;

import jni;

version (Android):
extern (C):
@system:
nothrow:
@nogc:

enum ANDROID_BITMAP_RESULT_SUCCESS           = 0;
enum ANDROID_BITMAP_RESULT_BAD_PARAMETER     = -1;
enum ANDROID_BITMAP_RESULT_JNI_EXCEPTION     = -2;
enum ANDROID_BITMAP_RESULT_ALLOCATION_FAILED = -3;

enum AndroidBitmapFormat
{
    ANDROID_BITMAP_FORMAT_NONE = 0,
    ANDROID_BITMAP_FORMAT_RGBA_8888 = 1,
    ANDROID_BITMAP_FORMAT_RGB_565 = 4,
    ANDROID_BITMAP_FORMAT_RGBA_4444 = 7,
    ANDROID_BITMAP_FORMAT_A_8 = 8
}

struct AndroidBitmapInfo
{
    uint width;
    uint height;
    uint stride;
    int format;
    uint flags;
}

int AndroidBitmap_getInfo(JNIEnv* env, jobject jbitmap, AndroidBitmapInfo* info);
int AndroidBitmap_lockPixels(JNIEnv* env, jobject jbitmap, void** addrPtr);
int AndroidBitmap_unlockPixels(JNIEnv* env, jobject jbitmap);
