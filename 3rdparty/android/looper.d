/* dstep /path/to/ndk-r9d/platforms/android-9/arch-x86/usr/include/android/looper.h -o looper.d*/

module android.looper;

version (Android):
extern (C):
@system:
nothrow:
@nogc:

alias int function(int, int, void*) ALooper_callbackFunc;

enum
{
    ALOOPER_PREPARE_ALLOW_NON_CALLBACKS = 1
}

enum
{
    ALOOPER_POLL_WAKE = -1,
    ALOOPER_POLL_CALLBACK = -2,
    ALOOPER_POLL_TIMEOUT = -3,
    ALOOPER_POLL_ERROR = -4
}

enum
{
    ALOOPER_EVENT_INPUT = 1,
    ALOOPER_EVENT_OUTPUT = 2,
    ALOOPER_EVENT_ERROR = 4,
    ALOOPER_EVENT_HANGUP = 8,
    ALOOPER_EVENT_INVALID = 16
}

struct ALooper;

ALooper* ALooper_forThread();
ALooper* ALooper_prepare(int opts);
void ALooper_acquire(ALooper* looper);
void ALooper_release(ALooper* looper);
int ALooper_pollOnce(int timeoutMillis, int* outFd, int* outEvents, void** outData);
int ALooper_pollAll(int timeoutMillis, int* outFd, int* outEvents, void** outData);
void ALooper_wake(ALooper* looper);
int ALooper_addFd(ALooper* looper, int fd, int ident, int events, ALooper_callbackFunc callback, void* data);
int ALooper_removeFd(ALooper* looper, int fd);
