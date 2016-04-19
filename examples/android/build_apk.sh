#!/bin/sh
# load settings for paths
. ./android_build_config.mk

echo "DlangUI Build for Android native app"
echo "===================================="
echo "DLANGUI_DIR: $DLANGUI_DIR"
echo "NDK: $NDK"
echo "SDK: $SDK"
echo "LDC: $LDC"

# dlangui sources
. $DLANGUI_DIR/android/dlangui_source_files.mk

# application sources
. ./android_app.mk

echo "\nLOCAL_MODULE: $LOCAL_MODULE"
#echo "DLANGUI SOURCES: $DLANGUI_SOURCES"

LDC_PARAMS="-mtriple=armv7-none-linux-androideabi -relocation-model=pic "
export LD=$NDK/toolchains/llvm/prebuilt/linux-$NDK_ARCH/bin/llvm-link
export CC=$NDK/toolchains/llvm/prebuilt/linux-$NDK_ARCH/bin/clang

SOURCES="$LOCAL_SRC_FILES $DLANGUI_SOURCES"
SOURCE_PATHS="-I./jni $DLANGUI_SOURCE_PATHS $DLANGUI_IMPORT_PATHS"

TARGET="libs/armeabi-v7a/lib$LOCAL_MODULE.so"
OBJFILE="build/armeabi-v7a/lib$LOCAL_MODULE.o"

LIBS="\
-L$NDK/platforms/android-19/arch-arm/usr/lib \
$LDC/lib/libphobos2-ldc.a $LDC/lib/libdruntime-ldc.a \
-lgcc \
-llog -landroid -lEGL -lGLESv3 -lGLESv1_CM -lc -lm \
$LOCAL_LDLIBS \
"

LINK_OPTIONS="\
-Wl,-soname,libnative-activity.so \
--sysroot=$NDK/platforms/android-9/arch-arm \
-gcc-toolchain $NDK/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-$NDK_ARCH \
-no-canonical-prefixes \
-target armv7-none-linux-androideabi \
-Wl,--fix-cortex-a8 \
-Wl,--no-undefined \
-Wl,-z,noexecstack \
-fuse-ld=bfd \
-Wl,-z,relro \
-Wl,-z,now \
-mthumb \
"

mkdir -p libs/armeabi-v7a/
mkdir -p build/armeabi-v7a/

#=========================================================
echo "\nCompiling $OBJFILE\n"
$LDC/bin/ldc2 $LDC_PARAMS $SOURCE_PATHS $SOURCES -c -singleobj -of=$OBJFILE || exit 1

#=========================================================
echo "\n\nLinking $TARGET\n"
$CC $OBJFILE $LIBS $LINK_OPTIONS -o $TARGET || exit 1

echo "Library is linked ok\n"

echo "Building APK"

$SDK/tools/android update project -p . -s --target 1
ant debug
