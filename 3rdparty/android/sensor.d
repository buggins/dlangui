/* dstep -I/path/to/ndk-r9d/platforms/android-9/arch-x86/usr/include -I/path/to/ndk-r9d/toolchains/llvm-3.4/prebuilt/linux-x86/lib/clang/3.4/include /path/to/ndk-r9d/platforms/android-9/arch-x86/usr/include/android/sensor.h -o sensor.d*/

module android.sensor;

import core.sys.posix.sys.types;
import android.looper;

version (Android):
extern (C):
@system:
nothrow:
@nogc:

enum
{
    ASENSOR_TYPE_ACCELEROMETER = 1,
    ASENSOR_TYPE_MAGNETIC_FIELD = 2,
    ASENSOR_TYPE_GYROSCOPE = 4,
    ASENSOR_TYPE_LIGHT = 5,
    ASENSOR_TYPE_PROXIMITY = 8
}

enum
{
    ASENSOR_STATUS_UNRELIABLE = 0,
    ASENSOR_STATUS_ACCURACY_LOW = 1,
    ASENSOR_STATUS_ACCURACY_MEDIUM = 2,
    ASENSOR_STATUS_ACCURACY_HIGH = 3
}

enum ASENSOR_STANDARD_GRAVITY = 9.80665f;
enum ASENSOR_MAGNETIC_FIELD_EARTH_MAX = 60.0f;
enum ASENSOR_MAGNETIC_FIELD_EARTH_MIN = 30.0f;

struct ASensorVector
{
    union
    {
        float[3] v;
        struct
        {
            float x;
            float y;
            float z;
        }
        struct
        {
            float azimuth;
            float pitch;
            float roll;
        }
    }
    byte status;
    ubyte[3] reserved;
}

struct ASensorEvent
{
    int version_;
    int sensor;
    int type;
    int reserved0;
    long timestamp;
    union
    {
        float[16] data;
        ASensorVector vector;
        ASensorVector acceleration;
        ASensorVector magnetic;
        float temperature;
        float distance;
        float light;
        float pressure;
    }
    int[4] reserved1;
}

struct ASensorManager;
struct ASensorEventQueue;
struct ASensor;
alias const(ASensor)* ASensorRef;
alias const(ASensorRef)* ASensorList;

ASensorManager* ASensorManager_getInstance();
int ASensorManager_getSensorList(ASensorManager* manager, ASensorList* list);
const(ASensor)* ASensorManager_getDefaultSensor(ASensorManager* manager, int type);
ASensorEventQueue* ASensorManager_createEventQueue(ASensorManager* manager, ALooper* looper, int ident, ALooper_callbackFunc callback, void* data);
int ASensorManager_destroyEventQueue(ASensorManager* manager, ASensorEventQueue* queue);
int ASensorEventQueue_enableSensor(ASensorEventQueue* queue, const(ASensor)* sensor);
int ASensorEventQueue_disableSensor(ASensorEventQueue* queue, const(ASensor)* sensor);
int ASensorEventQueue_setEventRate(ASensorEventQueue* queue, const(ASensor)* sensor, int usec);
int ASensorEventQueue_hasEvents(ASensorEventQueue* queue);
ssize_t ASensorEventQueue_getEvents(ASensorEventQueue* queue, ASensorEvent* events, size_t count);
const(char)* ASensor_getName(const(ASensor)* sensor);
const(char)* ASensor_getVendor(const(ASensor)* sensor);
int ASensor_getType(const(ASensor)* sensor);
float ASensor_getResolution(const(ASensor)* sensor);
int ASensor_getMinDelay(const(ASensor)* sensor);
