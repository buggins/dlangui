/* dstep -I/path/to/ndk-r10/platforms/android-9/arch-x86/usr/include -I/path/to/ndk-r10/toolchains/llvm-3.4/prebuilt/linux-x86/lib/clang/3.4/include /path/to/ndk-r10/platforms/android-9/arch-x86/usr/include/android/obb.h -o obb.d*/

module android.obb;

version (Android):
extern (C):
@system:
nothrow:
@nogc:

enum
{
    AOBBINFO_OVERLAY = 1
}

struct AObbInfo;

AObbInfo* AObbScanner_getObbInfo(const(char)* filename);
void AObbInfo_delete(AObbInfo* obbInfo);
const(char)* AObbInfo_getPackageName(AObbInfo* obbInfo);
int AObbInfo_getVersion(AObbInfo* obbInfo);
int AObbInfo_getFlags(AObbInfo* obbInfo);
