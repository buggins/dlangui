This is template for DlangUI Android project.
============================================

Copy this directory to some DlangUI project's directory to allow Android builds.

Currently only armv7a architecture is supported.


Probably you will want to change android package name in AndroidManifest.xml and application display name in res/values/strings.xml


Modify android_app.mk, android_build_config.mk

android_app.mk
==============

Update LOCAL_SRC_FILES to include all your project's files.


android_build_config.mk
=======================

Update paths to Android NDK, SDK, DlangUI source directory.

Default values:
export DLANGUI_DIR=$HOME/src/d/dlangui
export NDK=$HOME/android-ndk-r11c
export SDK=$HOME/android-sdk-linux
export LDC=$HOME/ldc2-android-arm-0.17.0-alpha2-linux-x86_64
export NDK_ARCH=x86_64


Use LDC cross compiler for armv7a build according instructions 

https://wiki.dlang.org/Build_LDC_for_Android#Build_a_sample_OpenGL_Android_app_ported_to_D

