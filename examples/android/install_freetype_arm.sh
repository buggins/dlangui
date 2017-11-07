#!/bin/sh

# You need working NDK standalone toolchain
# $NDK/build/tools/make-standalone-toolchain.sh --platform=android-21 --install-dir=/some/dir --arch=arm
#NDK_STANDALONE=/path/to/ndk-standalone-21-arm
#PATH=$NDK_STANDALONE/bin:$PATH

#Load settings for paths
. ./android_build_config.mk

inst=$(pwd)
mkdir freetype
cd freetype
wget "https://download.savannah.gnu.org/releases/freetype/freetype-2.6.tar.gz"
tar zxvf freetype-2.6.tar.gz
cd freetype-2.6/
./configure --host=arm-linux-androideabi --without-zlib --prefix="$(pwd)/freetype" --with-png=no --with-harfbuzz=no
make -j$(nproc)
make install
echo "ERNO ERNO ENOR"
mkdir -p ../../libs/armeabi-v7a
cp freetype/lib/libfreetype.so ../../libs/armeabi-v7a/libfreetype.so

