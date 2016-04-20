#!/bin/sh
. ./android_build_config.mk

$SDK/platform-tools/adb logcat | less
