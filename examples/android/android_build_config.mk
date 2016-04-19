#!/bin/sh

#=========================================================================
# Modify this file to specify DLANGUI, Android NDK, SDK and LDC2 locations.

MY_DIR=$(dirname $(readlink -f $0))
# relative path: ../../
export DLANGUI_DIR=$(dirname $(dirname $MY_DIR))
export NDK=$HOME/android-ndk-r11c
export SDK=$HOME/android-sdk-linux
export LDC=$HOME/ldc2-android-arm-0.17.0-alpha2-linux-x86_64
export NDK_ARCH=x86_64
