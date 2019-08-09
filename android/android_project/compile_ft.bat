cd freetype-2.9.1
mkdir build-arm
cd build-arm
set CC=%NDK%\prebuilt\windows-x86_64\bin\clang 
set NDK=%ANDROID_HOME%\ndk-bundle
cmake .. -G"Ninja" -DCMAKE_TOOLCHAIN_FILE=%NDK%\build\cmake\android.toolchain.cmake -DCMAKE_SYSTEM_NAME="Android" -DANDROID_NDK=%NDK% -DANDROID_TOOLCHAIN=clang -DANDROID_PLATFORM=android-21 -DBUILD_SHARED_LIBS=ON
cmake --build . --config Release