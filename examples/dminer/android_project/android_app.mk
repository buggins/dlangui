# List application source files here

# application library name ("app" -> libapp.so)
LOCAL_MODULE=dlangui-activity

# applicatino source files: put list of your source files here
LOCAL_SRC_FILES="\
../src/minermain.d \
../src/dminer/core/minetypes.d \
../src/dminer/core/blocks.d \
../src/dminer/core/generators.d \
../src/dminer/core/world.d \
../src/dminer/core/terrain.d \
../src/dminer/core/chunk.d \
-J../views \
-J../views/res \
-J../views/res/mdpi \
-J../views/res/i18n \
-release -enable-inlining -O3 \
"

# Additional libraries to link
LOCAL_LDLIBS=""

# Android SDK target
ANDROID_TARGET="android-19"
