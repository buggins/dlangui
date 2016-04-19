/* dstep -I/path/to/ndk-r9d/platforms/android-9/arch-x86/usr/include -I/path/to/ndk-r9d/toolchains/llvm-3.4/prebuilt/linux-x86/lib/clang/3.4/include /path/to/ndk-r9d/sources/android/native_app_glue/android_native_app_glue.h -o android_native_app_glue.d */

module android.android_native_app_glue;

import core.sys.posix.pthread;
import android.input, android.native_window, android.rect;
import android.configuration, android.looper, android.native_activity;

version (Android):
extern (C):
@system:
nothrow:
@nogc:

enum
{
    LOOPER_ID_MAIN = 1,
    LOOPER_ID_INPUT = 2,
    LOOPER_ID_USER = 3
}

enum
{
    APP_CMD_INPUT_CHANGED,
    APP_CMD_INIT_WINDOW,
    APP_CMD_TERM_WINDOW,
    APP_CMD_WINDOW_RESIZED,
    APP_CMD_WINDOW_REDRAW_NEEDED,
    APP_CMD_CONTENT_RECT_CHANGED,
    APP_CMD_GAINED_FOCUS,
    APP_CMD_LOST_FOCUS,
    APP_CMD_CONFIG_CHANGED,
    APP_CMD_LOW_MEMORY,
    APP_CMD_START,
    APP_CMD_RESUME,
    APP_CMD_SAVE_STATE,
    APP_CMD_PAUSE,
    APP_CMD_STOP,
    APP_CMD_DESTROY
}

struct android_poll_source
{
    int id;
    android_app* app;
    void function(android_app*, android_poll_source*) process;
}

struct android_app
{
    void* userData;
    void function(android_app*, int) onAppCmd;
    int function(android_app*, AInputEvent*) onInputEvent;
    ANativeActivity* activity;
    AConfiguration* config;
    void* savedState;
    size_t savedStateSize;
    ALooper* looper;
    AInputQueue* inputQueue;
    ANativeWindow* window;
    ARect contentRect;
    int activityState;
    int destroyRequested;
    pthread_mutex_t mutex;
    pthread_cond_t cond;
    int msgread;
    int msgwrite;
    pthread_t thread;
    android_poll_source cmdPollSource;
    android_poll_source inputPollSource;
    int running;
    int stateSaved;
    int destroyed;
    int redrawNeeded;
    AInputQueue* pendingInputQueue;
    ANativeWindow* pendingWindow;
    ARect pendingContentRect;
}

byte android_app_read_cmd(android_app* android_app);
void android_app_pre_exec_cmd(android_app* android_app, byte cmd);
void android_app_post_exec_cmd(android_app* android_app, byte cmd);
void app_dummy();
void android_main(android_app* app);
