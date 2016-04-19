/* dstep -I/path/to/ndk-r9d/platforms/android-9/arch-x86/usr/include -I/path/to/ndk-r9d/toolchains/llvm-3.4/prebuilt/linux-x86/lib/clang/3.4/include /path/to/ndk-r9d/platforms/android-9/arch-x86/usr/include/android/native_activity.h -o native_activity.d*/

module android.native_activity;

import jni;
import android.rect;
import android.asset_manager, android.input, android.native_window;

version (Android):
extern (C):
@system:
nothrow:
@nogc:

enum
{
    ANATIVEACTIVITY_SHOW_SOFT_INPUT_IMPLICIT = 1,
    ANATIVEACTIVITY_SHOW_SOFT_INPUT_FORCED = 2
}

enum
{
    ANATIVEACTIVITY_HIDE_SOFT_INPUT_IMPLICIT_ONLY = 1,
    ANATIVEACTIVITY_HIDE_SOFT_INPUT_NOT_ALWAYS = 2
}

struct ANativeActivity
{
    ANativeActivityCallbacks* callbacks;
    JavaVM* vm;
    JNIEnv* env;
    jobject clazz;
    const(char)* internalDataPath;
    const(char)* externalDataPath;
    int sdkVersion;
    void* instance;
    AAssetManager* assetManager;
}

struct ANativeActivityCallbacks
{
    void function(ANativeActivity*) onStart;
    void function(ANativeActivity*) onResume;
    void* function(ANativeActivity*, size_t*) onSaveInstanceState;
    void function(ANativeActivity*) onPause;
    void function(ANativeActivity*) onStop;
    void function(ANativeActivity*) onDestroy;
    void function(ANativeActivity*, int) onWindowFocusChanged;
    void function(ANativeActivity*, ANativeWindow*) onNativeWindowCreated;
    void function(ANativeActivity*, ANativeWindow*) onNativeWindowResized;
    void function(ANativeActivity*, ANativeWindow*) onNativeWindowRedrawNeeded;
    void function(ANativeActivity*, ANativeWindow*) onNativeWindowDestroyed;
    void function(ANativeActivity*, AInputQueue*) onInputQueueCreated;
    void function(ANativeActivity*, AInputQueue*) onInputQueueDestroyed;
    void function(ANativeActivity*, const(ARect)*) onContentRectChanged;
    void function(ANativeActivity*) onConfigurationChanged;
    void function(ANativeActivity*) onLowMemory;
}

void ANativeActivity_onCreate(ANativeActivity* activity, void* savedState, size_t savedStateSize);
void ANativeActivity_finish(ANativeActivity* activity);
void ANativeActivity_setWindowFormat(ANativeActivity* activity, int format);
void ANativeActivity_setWindowFlags(ANativeActivity* activity, uint addFlags, uint removeFlags);
void ANativeActivity_showSoftInput(ANativeActivity* activity, uint flags);
void ANativeActivity_hideSoftInput(ANativeActivity* activity, uint flags);
