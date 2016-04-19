/* dstep /path/to/ndk-r10/platforms/android-9/arch-x86/usr/include/android/storage_manager.h -o storage_manager.d*/

module android.storage_manager;

version (Android):
extern (C):
@system:
nothrow:
@nogc:

alias void function(const(char)*, const int, void*) AStorageManager_obbCallbackFunc;

enum
{
    AOBB_STATE_MOUNTED = 1,
    AOBB_STATE_UNMOUNTED = 2,
    AOBB_STATE_ERROR_INTERNAL = 20,
    AOBB_STATE_ERROR_COULD_NOT_MOUNT = 21,
    AOBB_STATE_ERROR_COULD_NOT_UNMOUNT = 22,
    AOBB_STATE_ERROR_NOT_MOUNTED = 23,
    AOBB_STATE_ERROR_ALREADY_MOUNTED = 24,
    AOBB_STATE_ERROR_PERMISSION_DENIED = 25
}

struct AStorageManager;

AStorageManager* AStorageManager_new();
void AStorageManager_delete(AStorageManager* mgr);
void AStorageManager_mountObb(AStorageManager* mgr, const(char)* filename, const(char)* key, AStorageManager_obbCallbackFunc cb, void* data);
void AStorageManager_unmountObb(AStorageManager* mgr, const(char)* filename, const int force, AStorageManager_obbCallbackFunc cb, void* data);
int AStorageManager_isObbMounted(AStorageManager* mgr, const(char)* filename);
const(char)* AStorageManager_getMountedObbPath(AStorageManager* mgr, const(char)* filename);
