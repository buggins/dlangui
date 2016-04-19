#!/bin/sh
export SDK=$HOME/android-sdk-linux

$SDK/platform-tools/adb logcat | less
#$SDK/platform-tools/adb logcat | grep "native"

