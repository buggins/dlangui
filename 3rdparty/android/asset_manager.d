/* dstep -I/path/to/ndk-r9d/toolchains/llvm-3.4/prebuilt/linux-x86/lib/clang/3.4/include /path/to/ndk-r9d/platforms/android-9/arch-x86/usr/include/android/asset_manager.h -o asset_manager.d */

module android.asset_manager;

import core.sys.posix.sys.types;

version (Android):
extern (C):
@system:
nothrow:
@nogc:

enum
{
    AASSET_MODE_UNKNOWN,
    AASSET_MODE_RANDOM,
    AASSET_MODE_STREAMING,
    AASSET_MODE_BUFFER
}

struct AAssetManager;
struct AAssetDir;
struct AAsset;

AAssetDir* AAssetManager_openDir(AAssetManager* mgr, const(char)* dirName);
AAsset* AAssetManager_open(AAssetManager* mgr, const(char)* filename, int mode);
const(char)* AAssetDir_getNextFileName(AAssetDir* assetDir);
void AAssetDir_rewind(AAssetDir* assetDir);
void AAssetDir_close(AAssetDir* assetDir);
int AAsset_read(AAsset* asset, void* buf, size_t count);
off_t AAsset_seek(AAsset* asset, off_t offset, int whence);
void AAsset_close(AAsset* asset);
const(void)* AAsset_getBuffer(AAsset* asset);
off_t AAsset_getLength(AAsset* asset);
off_t AAsset_getRemainingLength(AAsset* asset);
int AAsset_openFileDescriptor(AAsset* asset, off_t* outStart, off_t* outLength);
int AAsset_isAllocated(AAsset* asset);
