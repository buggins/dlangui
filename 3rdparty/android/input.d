/* dstep -I/path/to/ndk-r9d/platforms/android-9/arch-x86/usr/include -I/path/to/ndk-r9d/toolchains/llvm-3.4/prebuilt/linux-x86/lib/clang/3.4/include /path/to/ndk-r9d/platforms/android-9/arch-x86/usr/include/android/input.h -o input.d*/

module android.input;

import android.keycodes, android.looper;

version (Android):
extern (C):
@system:
nothrow:
@nogc:

enum
{
    AKEY_STATE_UNKNOWN = -1,
    AKEY_STATE_UP = 0,
    AKEY_STATE_DOWN = 1,
    AKEY_STATE_VIRTUAL = 2
}

enum
{
    AMETA_NONE = 0,
    AMETA_ALT_ON = 2,
    AMETA_ALT_LEFT_ON = 16,
    AMETA_ALT_RIGHT_ON = 32,
    AMETA_SHIFT_ON = 1,
    AMETA_SHIFT_LEFT_ON = 64,
    AMETA_SHIFT_RIGHT_ON = 128,
    AMETA_SYM_ON = 4
}

enum
{
    AINPUT_EVENT_TYPE_KEY = 1,
    AINPUT_EVENT_TYPE_MOTION = 2
}

enum
{
    AKEY_EVENT_ACTION_DOWN = 0,
    AKEY_EVENT_ACTION_UP = 1,
    AKEY_EVENT_ACTION_MULTIPLE = 2
}

enum
{
    AKEY_EVENT_FLAG_WOKE_HERE = 1,
    AKEY_EVENT_FLAG_SOFT_KEYBOARD = 2,
    AKEY_EVENT_FLAG_KEEP_TOUCH_MODE = 4,
    AKEY_EVENT_FLAG_FROM_SYSTEM = 8,
    AKEY_EVENT_FLAG_EDITOR_ACTION = 16,
    AKEY_EVENT_FLAG_CANCELED = 32,
    AKEY_EVENT_FLAG_VIRTUAL_HARD_KEY = 64,
    AKEY_EVENT_FLAG_LONG_PRESS = 128,
    AKEY_EVENT_FLAG_CANCELED_LONG_PRESS = 256,
    AKEY_EVENT_FLAG_TRACKING = 512
}

enum AMOTION_EVENT_ACTION_POINTER_INDEX_SHIFT = 8;

enum
{
    AMOTION_EVENT_ACTION_MASK = 255,
    AMOTION_EVENT_ACTION_POINTER_INDEX_MASK = 65280,
    AMOTION_EVENT_ACTION_DOWN = 0,
    AMOTION_EVENT_ACTION_UP = 1,
    AMOTION_EVENT_ACTION_MOVE = 2,
    AMOTION_EVENT_ACTION_CANCEL = 3,
    AMOTION_EVENT_ACTION_OUTSIDE = 4,
    AMOTION_EVENT_ACTION_POINTER_DOWN = 5,
    AMOTION_EVENT_ACTION_POINTER_UP = 6
}

enum
{
    AMOTION_EVENT_FLAG_WINDOW_IS_OBSCURED = 1
}

enum
{
    AMOTION_EVENT_EDGE_FLAG_NONE = 0,
    AMOTION_EVENT_EDGE_FLAG_TOP = 1,
    AMOTION_EVENT_EDGE_FLAG_BOTTOM = 2,
    AMOTION_EVENT_EDGE_FLAG_LEFT = 4,
    AMOTION_EVENT_EDGE_FLAG_RIGHT = 8
}

enum
{
    AINPUT_SOURCE_CLASS_MASK = 255,
    AINPUT_SOURCE_CLASS_BUTTON = 1,
    AINPUT_SOURCE_CLASS_POINTER = 2,
    AINPUT_SOURCE_CLASS_NAVIGATION = 4,
    AINPUT_SOURCE_CLASS_POSITION = 8
}

enum
{
    AINPUT_SOURCE_UNKNOWN = 0,
    AINPUT_SOURCE_KEYBOARD = 257,
    AINPUT_SOURCE_DPAD = 513,
    AINPUT_SOURCE_TOUCHSCREEN = 4098,
    AINPUT_SOURCE_MOUSE = 8194,
    AINPUT_SOURCE_TRACKBALL = 65540,
    AINPUT_SOURCE_TOUCHPAD = 1048584,
    AINPUT_SOURCE_ANY = 0xffffff00
}

enum
{
    AINPUT_KEYBOARD_TYPE_NONE = 0,
    AINPUT_KEYBOARD_TYPE_NON_ALPHABETIC = 1,
    AINPUT_KEYBOARD_TYPE_ALPHABETIC = 2
}

enum
{
    AINPUT_MOTION_RANGE_X = 0,
    AINPUT_MOTION_RANGE_Y = 1,
    AINPUT_MOTION_RANGE_PRESSURE = 2,
    AINPUT_MOTION_RANGE_SIZE = 3,
    AINPUT_MOTION_RANGE_TOUCH_MAJOR = 4,
    AINPUT_MOTION_RANGE_TOUCH_MINOR = 5,
    AINPUT_MOTION_RANGE_TOOL_MAJOR = 6,
    AINPUT_MOTION_RANGE_TOOL_MINOR = 7,
    AINPUT_MOTION_RANGE_ORIENTATION = 8
}

struct AInputQueue;
struct AInputEvent;

int AInputEvent_getType(const(AInputEvent)* event);
int AInputEvent_getDeviceId(const(AInputEvent)* event);
int AInputEvent_getSource(const(AInputEvent)* event);
int AKeyEvent_getAction(const(AInputEvent)* key_event);
int AKeyEvent_getFlags(const(AInputEvent)* key_event);
int AKeyEvent_getKeyCode(const(AInputEvent)* key_event);
int AKeyEvent_getScanCode(const(AInputEvent)* key_event);
int AKeyEvent_getMetaState(const(AInputEvent)* key_event);
int AKeyEvent_getRepeatCount(const(AInputEvent)* key_event);
long AKeyEvent_getDownTime(const(AInputEvent)* key_event);
long AKeyEvent_getEventTime(const(AInputEvent)* key_event);
int AMotionEvent_getAction(const(AInputEvent)* motion_event);
int AMotionEvent_getFlags(const(AInputEvent)* motion_event);
int AMotionEvent_getMetaState(const(AInputEvent)* motion_event);
int AMotionEvent_getEdgeFlags(const(AInputEvent)* motion_event);
long AMotionEvent_getDownTime(const(AInputEvent)* motion_event);
long AMotionEvent_getEventTime(const(AInputEvent)* motion_event);
float AMotionEvent_getXOffset(const(AInputEvent)* motion_event);
float AMotionEvent_getYOffset(const(AInputEvent)* motion_event);
float AMotionEvent_getXPrecision(const(AInputEvent)* motion_event);
float AMotionEvent_getYPrecision(const(AInputEvent)* motion_event);
size_t AMotionEvent_getPointerCount(const(AInputEvent)* motion_event);
int AMotionEvent_getPointerId(const(AInputEvent)* motion_event, size_t pointer_index);
float AMotionEvent_getRawX(const(AInputEvent)* motion_event, size_t pointer_index);
float AMotionEvent_getRawY(const(AInputEvent)* motion_event, size_t pointer_index);
float AMotionEvent_getX(const(AInputEvent)* motion_event, size_t pointer_index);
float AMotionEvent_getY(const(AInputEvent)* motion_event, size_t pointer_index);
float AMotionEvent_getPressure(const(AInputEvent)* motion_event, size_t pointer_index);
float AMotionEvent_getSize(const(AInputEvent)* motion_event, size_t pointer_index);
float AMotionEvent_getTouchMajor(const(AInputEvent)* motion_event, size_t pointer_index);
float AMotionEvent_getTouchMinor(const(AInputEvent)* motion_event, size_t pointer_index);
float AMotionEvent_getToolMajor(const(AInputEvent)* motion_event, size_t pointer_index);
float AMotionEvent_getToolMinor(const(AInputEvent)* motion_event, size_t pointer_index);
float AMotionEvent_getOrientation(const(AInputEvent)* motion_event, size_t pointer_index);
size_t AMotionEvent_getHistorySize(const(AInputEvent)* motion_event);
long AMotionEvent_getHistoricalEventTime(const(AInputEvent)* motion_event, size_t history_index);
float AMotionEvent_getHistoricalRawX(const(AInputEvent)* motion_event, size_t pointer_index, size_t history_index);
float AMotionEvent_getHistoricalRawY(const(AInputEvent)* motion_event, size_t pointer_index, size_t history_index);
float AMotionEvent_getHistoricalX(const(AInputEvent)* motion_event, size_t pointer_index, size_t history_index);
float AMotionEvent_getHistoricalY(const(AInputEvent)* motion_event, size_t pointer_index, size_t history_index);
float AMotionEvent_getHistoricalPressure(const(AInputEvent)* motion_event, size_t pointer_index, size_t history_index);
float AMotionEvent_getHistoricalSize(const(AInputEvent)* motion_event, size_t pointer_index, size_t history_index);
float AMotionEvent_getHistoricalTouchMajor(const(AInputEvent)* motion_event, size_t pointer_index, size_t history_index);
float AMotionEvent_getHistoricalTouchMinor(const(AInputEvent)* motion_event, size_t pointer_index, size_t history_index);
float AMotionEvent_getHistoricalToolMajor(const(AInputEvent)* motion_event, size_t pointer_index, size_t history_index);
float AMotionEvent_getHistoricalToolMinor(const(AInputEvent)* motion_event, size_t pointer_index, size_t history_index);
float AMotionEvent_getHistoricalOrientation(const(AInputEvent)* motion_event, size_t pointer_index, size_t history_index);
void AInputQueue_attachLooper(AInputQueue* queue, ALooper* looper, int ident, ALooper_callbackFunc callback, void* data);
void AInputQueue_detachLooper(AInputQueue* queue);
int AInputQueue_hasEvents(AInputQueue* queue);
int AInputQueue_getEvent(AInputQueue* queue, AInputEvent** outEvent);
int AInputQueue_preDispatchEvent(AInputQueue* queue, AInputEvent* event);
void AInputQueue_finishEvent(AInputQueue* queue, AInputEvent* event, int handled);
