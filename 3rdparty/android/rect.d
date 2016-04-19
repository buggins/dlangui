/* dstep /path/to/ndk-r9d/platforms/android-9/arch-x86/usr/include/android/rect.h -o rect.d*/

module android.rect;

version (Android):
extern (C):
@system:
nothrow:
@nogc:

struct ARect
{
    int left;
    int top;
    int right;
    int bottom;
}
