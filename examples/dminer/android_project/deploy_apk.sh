#!/bin/sh
. ./android_build_config.mk

$SDK/platform-tools/adb install -r bin/NativeActivity-debug.apk
