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
```
export DLANGUI_DIR=$HOME/src/d/dlangui
export NDK=$HOME/android-ndk-r11c
export SDK=$HOME/android-sdk-linux
export LDC=$HOME/ldc2-android-arm-0.17.0-alpha2-linux-x86_64
export NDK_ARCH=x86_64
```


Use LDC cross compiler for armv7a build according instructions

https://wiki.dlang.org/Build_LDC_for_Android#Build_a_sample_OpenGL_Android_app_ported_to_D



Dependencies
============

FreeType dependency is needed for dlangui, as well as D runtime for android

1\) Build D runtime with LDC 
(should this be done inside LDC install folder?)

For this and the next tasks ninja and cmake build systems is needed, 
refer to https://wiki.dlang.org/Build_D_for_Android for more info


```
set CC %ANDROID_HOME%\ndk-bundle\prebuilt\windows-x86_64\bin\clang.exe
ldc-build-runtime --ninja --targetPreset=Android-arm --dFlags="-w;-mcpu=cortex-a8" --buildDir=droid32
```

2\) Download and build FreeType

on Windows just run ./get_ft.ps1 && ./build_ft.bat

currently there is no scripts for Linux so you have to adapt those manually

then copy the binaries to your project android libs/ folder


Building
========

Run ./build_apk.sh

bin/NativeActivity-debug.apk


Deploy APK on device
====================

Run ./deploy_apk.sh

It will run `adb install bin/NativeActivity-debug.apk`
