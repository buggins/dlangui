PLATFORM_DIR=armeabi-v7a

echo "\nLOCAL_MODULE: $LOCAL_MODULE"

LDC_PARAMS="-mtriple=armv7-none-linux-androideabi -relocation-model=pic "
export LD=$NDK/toolchains/llvm/prebuilt/linux-$NDK_ARCH/bin/llvm-link
export CC=$NDK/toolchains/llvm/prebuilt/linux-$NDK_ARCH/bin/clang

SOURCES="$LOCAL_SRC_FILES $DLANGUI_SOURCES"
SOURCE_PATHS="-I./jni $DLANGUI_SOURCE_PATHS $DLANGUI_IMPORT_PATHS"

TARGET="libs/$PLATFORM_DIR/lib$LOCAL_MODULE.so"
OBJFILE="build/$PLATFORM_DIR/lib$LOCAL_MODULE.o"

LIBS="\
-L$NDK/platforms/android-19/arch-arm/usr/lib \
$LDC/lib/libphobos2-ldc.a \
$LDC/lib/libdruntime-ldc.a \
$LOCAL_LDLIBS \
$DLANGUI_LDLIBS \
"

LINK_OPTIONS="\
-Wl,-soname,libnative-activity.so \
-shared \
--sysroot=$NDK/platforms/android-19/arch-arm \
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

mkdir -p libs/$PLATFORM_DIR/
mkdir -p build/$PLATFORM_DIR/

echo "\nCompiling $OBJFILE...\n"
#=========================================================
$LDC/bin/ldc2 $LDC_PARAMS $SOURCE_PATHS $SOURCES -d-debug -d-version=EmbedStandardResources -c -singleobj -of=$OBJFILE || die 2 "ldc2 build for $OBJFILE is failed"

echo "\n\nLinking $TARGET...\n"
#=========================================================
$CC $OBJFILE $LIBS $LINK_OPTIONS -o $TARGET || die 2 "$TARGET linking is failed"
echo "Library is linked ok\n"

