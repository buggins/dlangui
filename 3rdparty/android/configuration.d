/* dstep -I/path/to/ndk-r9d/platforms/android-9/arch-x86/usr/include -I/path/to/ndk-r9d/toolchains/llvm-3.4/prebuilt/linux-x86/lib/clang/3.4/include /path/to/ndk-r9d/platforms/android-9/arch-x86/usr/include/android/configuration.h -o configuration.d*/

module android.configuration;

import android.asset_manager;

version (Android):
extern (C):
@system:
nothrow:
@nogc:

enum
{
    ACONFIGURATION_ORIENTATION_ANY = 0,
    ACONFIGURATION_ORIENTATION_PORT = 1,
    ACONFIGURATION_ORIENTATION_LAND = 2,
    ACONFIGURATION_ORIENTATION_SQUARE = 3,

    ACONFIGURATION_TOUCHSCREEN_ANY = 0,
    ACONFIGURATION_TOUCHSCREEN_NOTOUCH = 1,
    ACONFIGURATION_TOUCHSCREEN_STYLUS = 2,
    ACONFIGURATION_TOUCHSCREEN_FINGER = 3,

    ACONFIGURATION_DENSITY_DEFAULT = 0,
    ACONFIGURATION_DENSITY_LOW = 120,
    ACONFIGURATION_DENSITY_MEDIUM = 160,
    ACONFIGURATION_DENSITY_HIGH = 240,
    ACONFIGURATION_DENSITY_NONE = 65535,

    ACONFIGURATION_KEYBOARD_ANY = 0,
    ACONFIGURATION_KEYBOARD_NOKEYS = 1,
    ACONFIGURATION_KEYBOARD_QWERTY = 2,
    ACONFIGURATION_KEYBOARD_12KEY = 3,

    ACONFIGURATION_NAVIGATION_ANY = 0,
    ACONFIGURATION_NAVIGATION_NONAV = 1,
    ACONFIGURATION_NAVIGATION_DPAD = 2,
    ACONFIGURATION_NAVIGATION_TRACKBALL = 3,
    ACONFIGURATION_NAVIGATION_WHEEL = 4,

    ACONFIGURATION_KEYSHIDDEN_ANY = 0,
    ACONFIGURATION_KEYSHIDDEN_NO = 1,
    ACONFIGURATION_KEYSHIDDEN_YES = 2,
    ACONFIGURATION_KEYSHIDDEN_SOFT = 3,

    ACONFIGURATION_NAVHIDDEN_ANY = 0,
    ACONFIGURATION_NAVHIDDEN_NO = 1,
    ACONFIGURATION_NAVHIDDEN_YES = 2,

    ACONFIGURATION_SCREENSIZE_ANY = 0,
    ACONFIGURATION_SCREENSIZE_SMALL = 1,
    ACONFIGURATION_SCREENSIZE_NORMAL = 2,
    ACONFIGURATION_SCREENSIZE_LARGE = 3,
    ACONFIGURATION_SCREENSIZE_XLARGE = 4,

    ACONFIGURATION_SCREENLONG_ANY = 0,
    ACONFIGURATION_SCREENLONG_NO = 1,
    ACONFIGURATION_SCREENLONG_YES = 2,

    ACONFIGURATION_UI_MODE_TYPE_ANY = 0,
    ACONFIGURATION_UI_MODE_TYPE_NORMAL = 1,
    ACONFIGURATION_UI_MODE_TYPE_DESK = 2,
    ACONFIGURATION_UI_MODE_TYPE_CAR = 3,

    ACONFIGURATION_UI_MODE_NIGHT_ANY = 0,
    ACONFIGURATION_UI_MODE_NIGHT_NO = 1,
    ACONFIGURATION_UI_MODE_NIGHT_YES = 2,

    ACONFIGURATION_MCC = 1,
    ACONFIGURATION_MNC = 2,
    ACONFIGURATION_LOCALE = 4,
    ACONFIGURATION_TOUCHSCREEN = 8,
    ACONFIGURATION_KEYBOARD = 16,
    ACONFIGURATION_KEYBOARD_HIDDEN = 32,
    ACONFIGURATION_NAVIGATION = 64,
    ACONFIGURATION_ORIENTATION = 128,
    ACONFIGURATION_DENSITY = 256,
    ACONFIGURATION_SCREEN_SIZE = 512,
    ACONFIGURATION_VERSION = 1024,
    ACONFIGURATION_SCREEN_LAYOUT = 2048,
    ACONFIGURATION_UI_MODE = 4096
}

struct AConfiguration;

AConfiguration* AConfiguration_new();
void AConfiguration_delete(AConfiguration* config);
void AConfiguration_fromAssetManager(AConfiguration* out_, AAssetManager* am);
void AConfiguration_copy(AConfiguration* dest, AConfiguration* src);
int AConfiguration_getMcc(AConfiguration* config);
void AConfiguration_setMcc(AConfiguration* config, int mcc);
int AConfiguration_getMnc(AConfiguration* config);
void AConfiguration_setMnc(AConfiguration* config, int mnc);
void AConfiguration_getLanguage(AConfiguration* config, char* outLanguage);
void AConfiguration_setLanguage(AConfiguration* config, const(char)* language);
void AConfiguration_getCountry(AConfiguration* config, char* outCountry);
void AConfiguration_setCountry(AConfiguration* config, const(char)* country);
int AConfiguration_getOrientation(AConfiguration* config);
void AConfiguration_setOrientation(AConfiguration* config, int orientation);
int AConfiguration_getTouchscreen(AConfiguration* config);
void AConfiguration_setTouchscreen(AConfiguration* config, int touchscreen);
int AConfiguration_getDensity(AConfiguration* config);
void AConfiguration_setDensity(AConfiguration* config, int density);
int AConfiguration_getKeyboard(AConfiguration* config);
void AConfiguration_setKeyboard(AConfiguration* config, int keyboard);
int AConfiguration_getNavigation(AConfiguration* config);
void AConfiguration_setNavigation(AConfiguration* config, int navigation);
int AConfiguration_getKeysHidden(AConfiguration* config);
void AConfiguration_setKeysHidden(AConfiguration* config, int keysHidden);
int AConfiguration_getNavHidden(AConfiguration* config);
void AConfiguration_setNavHidden(AConfiguration* config, int navHidden);
int AConfiguration_getSdkVersion(AConfiguration* config);
void AConfiguration_setSdkVersion(AConfiguration* config, int sdkVersion);
int AConfiguration_getScreenSize(AConfiguration* config);
void AConfiguration_setScreenSize(AConfiguration* config, int screenSize);
int AConfiguration_getScreenLong(AConfiguration* config);
void AConfiguration_setScreenLong(AConfiguration* config, int screenLong);
int AConfiguration_getUiModeType(AConfiguration* config);
void AConfiguration_setUiModeType(AConfiguration* config, int uiModeType);
int AConfiguration_getUiModeNight(AConfiguration* config);
void AConfiguration_setUiModeNight(AConfiguration* config, int uiModeNight);
int AConfiguration_diff(AConfiguration* config1, AConfiguration* config2);
int AConfiguration_match(AConfiguration* base, AConfiguration* requested);
int AConfiguration_isBetterThan(AConfiguration* base, AConfiguration* test, AConfiguration* requested);
