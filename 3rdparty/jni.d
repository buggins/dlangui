/* dstep -I/path/to/ndk-r9d/platforms/android-9/arch-x86/usr/include -I/path/to/ndk-r9d/toolchains/llvm-3.4/prebuilt/linux-x86/lib/clang/3.4/include /path/to/ndk-r9d/platforms/android-9/arch-x86/usr/include/jni.h -o jni.d*/

module jni;

version (Android):
extern (C):
@system:
nothrow:
@nogc:

import core.stdc.stdarg;

alias ubyte jboolean;
alias byte jbyte;
alias ushort jchar;
alias short jshort;
alias int jint;
alias long jlong;
alias float jfloat;
alias double jdouble;
alias jint jsize;
alias void* jobject;
alias jobject jclass;
alias jobject jstring;
alias jobject jarray;
alias jarray jobjectArray;
alias jarray jbooleanArray;
alias jarray jbyteArray;
alias jarray jcharArray;
alias jarray jshortArray;
alias jarray jintArray;
alias jarray jlongArray;
alias jarray jfloatArray;
alias jarray jdoubleArray;
alias jobject jthrowable;
alias jobject jweak;
alias _jfieldID* jfieldID;
alias _jmethodID* jmethodID;
alias const(JNINativeInterface)* C_JNIEnv;
alias const(JNINativeInterface)* JNIEnv;
alias const(JNIInvokeInterface)* JavaVM;

enum jobjectRefType
{
    JNIInvalidRefType = 0,
    JNILocalRefType = 1,
    JNIGlobalRefType = 2,
    JNIWeakGlobalRefType = 3
}

enum JNI_FALSE = 0;
enum JNI_TRUE = 1;
enum JNI_VERSION_1_1 = 0x00010001;
enum JNI_VERSION_1_2 = 0x00010002;
enum JNI_VERSION_1_4 = 0x00010004;
enum JNI_VERSION_1_6 = 0x00010006;
enum JNI_OK = 0;
enum JNI_ERR = -1;
enum JNI_EDETACHED = -2;
enum JNI_EVERSION = -3;
enum JNI_COMMIT = 1;
enum JNI_ABORT = 2;

struct JNINativeMethod
{
    const(char)* name;
    const(char)* signature;
    void* fnPtr;
}

struct JNINativeInterface
{
    void* reserved0;
    void* reserved1;
    void* reserved2;
    void* reserved3;
    jint function(JNIEnv*) GetVersion;
    jclass function(JNIEnv*, const(char)*, jobject, const(jbyte)*, jsize) DefineClass;
    jclass function(JNIEnv*, const(char)*) FindClass;
    jmethodID function(JNIEnv*, jobject) FromReflectedMethod;
    jfieldID function(JNIEnv*, jobject) FromReflectedField;
    jobject function(JNIEnv*, jclass, jmethodID, jboolean) ToReflectedMethod;
    jclass function(JNIEnv*, jclass) GetSuperclass;
    jboolean function(JNIEnv*, jclass, jclass) IsAssignableFrom;
    jobject function(JNIEnv*, jclass, jfieldID, jboolean) ToReflectedField;
    jint function(JNIEnv*, jthrowable) Throw;
    jint function(JNIEnv*, jclass, const(char)*) ThrowNew;
    jthrowable function(JNIEnv*) ExceptionOccurred;
    void function(JNIEnv*) ExceptionDescribe;
    void function(JNIEnv*) ExceptionClear;
    void function(JNIEnv*, const(char)*) FatalError;
    jint function(JNIEnv*, jint) PushLocalFrame;
    jobject function(JNIEnv*, jobject) PopLocalFrame;
    jobject function(JNIEnv*, jobject) NewGlobalRef;
    void function(JNIEnv*, jobject) DeleteGlobalRef;
    void function(JNIEnv*, jobject) DeleteLocalRef;
    jboolean function(JNIEnv*, jobject, jobject) IsSameObject;
    jobject function(JNIEnv*, jobject) NewLocalRef;
    jint function(JNIEnv*, jint) EnsureLocalCapacity;
    jobject function(JNIEnv*, jclass) AllocObject;
    jobject function(JNIEnv*, jclass, jmethodID, ...) NewObject;
    jobject function(JNIEnv*, jclass, jmethodID, va_list) NewObjectV;
    jobject function(JNIEnv*, jclass, jmethodID, jvalue*) NewObjectA;
    jclass function(JNIEnv*, jobject) GetObjectClass;
    jboolean function(JNIEnv*, jobject, jclass) IsInstanceOf;
    jmethodID function(JNIEnv*, jclass, const(char)*, const(char)*) GetMethodID;
    jobject function(JNIEnv*, jobject, jmethodID, ...) CallObjectMethod;
    jobject function(JNIEnv*, jobject, jmethodID, va_list) CallObjectMethodV;
    jobject function(JNIEnv*, jobject, jmethodID, jvalue*) CallObjectMethodA;
    jboolean function(JNIEnv*, jobject, jmethodID, ...) CallBooleanMethod;
    jboolean function(JNIEnv*, jobject, jmethodID, va_list) CallBooleanMethodV;
    jboolean function(JNIEnv*, jobject, jmethodID, jvalue*) CallBooleanMethodA;
    jbyte function(JNIEnv*, jobject, jmethodID, ...) CallByteMethod;
    jbyte function(JNIEnv*, jobject, jmethodID, va_list) CallByteMethodV;
    jbyte function(JNIEnv*, jobject, jmethodID, jvalue*) CallByteMethodA;
    jchar function(JNIEnv*, jobject, jmethodID, ...) CallCharMethod;
    jchar function(JNIEnv*, jobject, jmethodID, va_list) CallCharMethodV;
    jchar function(JNIEnv*, jobject, jmethodID, jvalue*) CallCharMethodA;
    jshort function(JNIEnv*, jobject, jmethodID, ...) CallShortMethod;
    jshort function(JNIEnv*, jobject, jmethodID, va_list) CallShortMethodV;
    jshort function(JNIEnv*, jobject, jmethodID, jvalue*) CallShortMethodA;
    jint function(JNIEnv*, jobject, jmethodID, ...) CallIntMethod;
    jint function(JNIEnv*, jobject, jmethodID, va_list) CallIntMethodV;
    jint function(JNIEnv*, jobject, jmethodID, jvalue*) CallIntMethodA;
    jlong function(JNIEnv*, jobject, jmethodID, ...) CallLongMethod;
    jlong function(JNIEnv*, jobject, jmethodID, va_list) CallLongMethodV;
    jlong function(JNIEnv*, jobject, jmethodID, jvalue*) CallLongMethodA;
    jfloat function(JNIEnv*, jobject, jmethodID, ...) CallFloatMethod;
    jfloat function(JNIEnv*, jobject, jmethodID, va_list) CallFloatMethodV;
    jfloat function(JNIEnv*, jobject, jmethodID, jvalue*) CallFloatMethodA;
    jdouble function(JNIEnv*, jobject, jmethodID, ...) CallDoubleMethod;
    jdouble function(JNIEnv*, jobject, jmethodID, va_list) CallDoubleMethodV;
    jdouble function(JNIEnv*, jobject, jmethodID, jvalue*) CallDoubleMethodA;
    void function(JNIEnv*, jobject, jmethodID, ...) CallVoidMethod;
    void function(JNIEnv*, jobject, jmethodID, va_list) CallVoidMethodV;
    void function(JNIEnv*, jobject, jmethodID, jvalue*) CallVoidMethodA;
    jobject function(JNIEnv*, jobject, jclass, jmethodID, ...) CallNonvirtualObjectMethod;
    jobject function(JNIEnv*, jobject, jclass, jmethodID, va_list) CallNonvirtualObjectMethodV;
    jobject function(JNIEnv*, jobject, jclass, jmethodID, jvalue*) CallNonvirtualObjectMethodA;
    jboolean function(JNIEnv*, jobject, jclass, jmethodID, ...) CallNonvirtualBooleanMethod;
    jboolean function(JNIEnv*, jobject, jclass, jmethodID, va_list) CallNonvirtualBooleanMethodV;
    jboolean function(JNIEnv*, jobject, jclass, jmethodID, jvalue*) CallNonvirtualBooleanMethodA;
    jbyte function(JNIEnv*, jobject, jclass, jmethodID, ...) CallNonvirtualByteMethod;
    jbyte function(JNIEnv*, jobject, jclass, jmethodID, va_list) CallNonvirtualByteMethodV;
    jbyte function(JNIEnv*, jobject, jclass, jmethodID, jvalue*) CallNonvirtualByteMethodA;
    jchar function(JNIEnv*, jobject, jclass, jmethodID, ...) CallNonvirtualCharMethod;
    jchar function(JNIEnv*, jobject, jclass, jmethodID, va_list) CallNonvirtualCharMethodV;
    jchar function(JNIEnv*, jobject, jclass, jmethodID, jvalue*) CallNonvirtualCharMethodA;
    jshort function(JNIEnv*, jobject, jclass, jmethodID, ...) CallNonvirtualShortMethod;
    jshort function(JNIEnv*, jobject, jclass, jmethodID, va_list) CallNonvirtualShortMethodV;
    jshort function(JNIEnv*, jobject, jclass, jmethodID, jvalue*) CallNonvirtualShortMethodA;
    jint function(JNIEnv*, jobject, jclass, jmethodID, ...) CallNonvirtualIntMethod;
    jint function(JNIEnv*, jobject, jclass, jmethodID, va_list) CallNonvirtualIntMethodV;
    jint function(JNIEnv*, jobject, jclass, jmethodID, jvalue*) CallNonvirtualIntMethodA;
    jlong function(JNIEnv*, jobject, jclass, jmethodID, ...) CallNonvirtualLongMethod;
    jlong function(JNIEnv*, jobject, jclass, jmethodID, va_list) CallNonvirtualLongMethodV;
    jlong function(JNIEnv*, jobject, jclass, jmethodID, jvalue*) CallNonvirtualLongMethodA;
    jfloat function(JNIEnv*, jobject, jclass, jmethodID, ...) CallNonvirtualFloatMethod;
    jfloat function(JNIEnv*, jobject, jclass, jmethodID, va_list) CallNonvirtualFloatMethodV;
    jfloat function(JNIEnv*, jobject, jclass, jmethodID, jvalue*) CallNonvirtualFloatMethodA;
    jdouble function(JNIEnv*, jobject, jclass, jmethodID, ...) CallNonvirtualDoubleMethod;
    jdouble function(JNIEnv*, jobject, jclass, jmethodID, va_list) CallNonvirtualDoubleMethodV;
    jdouble function(JNIEnv*, jobject, jclass, jmethodID, jvalue*) CallNonvirtualDoubleMethodA;
    void function(JNIEnv*, jobject, jclass, jmethodID, ...) CallNonvirtualVoidMethod;
    void function(JNIEnv*, jobject, jclass, jmethodID, va_list) CallNonvirtualVoidMethodV;
    void function(JNIEnv*, jobject, jclass, jmethodID, jvalue*) CallNonvirtualVoidMethodA;
    jfieldID function(JNIEnv*, jclass, const(char)*, const(char)*) GetFieldID;
    jobject function(JNIEnv*, jobject, jfieldID) GetObjectField;
    jboolean function(JNIEnv*, jobject, jfieldID) GetBooleanField;
    jbyte function(JNIEnv*, jobject, jfieldID) GetByteField;
    jchar function(JNIEnv*, jobject, jfieldID) GetCharField;
    jshort function(JNIEnv*, jobject, jfieldID) GetShortField;
    jint function(JNIEnv*, jobject, jfieldID) GetIntField;
    jlong function(JNIEnv*, jobject, jfieldID) GetLongField;
    jfloat function(JNIEnv*, jobject, jfieldID) GetFloatField;
    jdouble function(JNIEnv*, jobject, jfieldID) GetDoubleField;
    void function(JNIEnv*, jobject, jfieldID, jobject) SetObjectField;
    void function(JNIEnv*, jobject, jfieldID, jboolean) SetBooleanField;
    void function(JNIEnv*, jobject, jfieldID, jbyte) SetByteField;
    void function(JNIEnv*, jobject, jfieldID, jchar) SetCharField;
    void function(JNIEnv*, jobject, jfieldID, jshort) SetShortField;
    void function(JNIEnv*, jobject, jfieldID, jint) SetIntField;
    void function(JNIEnv*, jobject, jfieldID, jlong) SetLongField;
    void function(JNIEnv*, jobject, jfieldID, jfloat) SetFloatField;
    void function(JNIEnv*, jobject, jfieldID, jdouble) SetDoubleField;
    jmethodID function(JNIEnv*, jclass, const(char)*, const(char)*) GetStaticMethodID;
    jobject function(JNIEnv*, jclass, jmethodID, ...) CallStaticObjectMethod;
    jobject function(JNIEnv*, jclass, jmethodID, va_list) CallStaticObjectMethodV;
    jobject function(JNIEnv*, jclass, jmethodID, jvalue*) CallStaticObjectMethodA;
    jboolean function(JNIEnv*, jclass, jmethodID, ...) CallStaticBooleanMethod;
    jboolean function(JNIEnv*, jclass, jmethodID, va_list) CallStaticBooleanMethodV;
    jboolean function(JNIEnv*, jclass, jmethodID, jvalue*) CallStaticBooleanMethodA;
    jbyte function(JNIEnv*, jclass, jmethodID, ...) CallStaticByteMethod;
    jbyte function(JNIEnv*, jclass, jmethodID, va_list) CallStaticByteMethodV;
    jbyte function(JNIEnv*, jclass, jmethodID, jvalue*) CallStaticByteMethodA;
    jchar function(JNIEnv*, jclass, jmethodID, ...) CallStaticCharMethod;
    jchar function(JNIEnv*, jclass, jmethodID, va_list) CallStaticCharMethodV;
    jchar function(JNIEnv*, jclass, jmethodID, jvalue*) CallStaticCharMethodA;
    jshort function(JNIEnv*, jclass, jmethodID, ...) CallStaticShortMethod;
    jshort function(JNIEnv*, jclass, jmethodID, va_list) CallStaticShortMethodV;
    jshort function(JNIEnv*, jclass, jmethodID, jvalue*) CallStaticShortMethodA;
    jint function(JNIEnv*, jclass, jmethodID, ...) CallStaticIntMethod;
    jint function(JNIEnv*, jclass, jmethodID, va_list) CallStaticIntMethodV;
    jint function(JNIEnv*, jclass, jmethodID, jvalue*) CallStaticIntMethodA;
    jlong function(JNIEnv*, jclass, jmethodID, ...) CallStaticLongMethod;
    jlong function(JNIEnv*, jclass, jmethodID, va_list) CallStaticLongMethodV;
    jlong function(JNIEnv*, jclass, jmethodID, jvalue*) CallStaticLongMethodA;
    jfloat function(JNIEnv*, jclass, jmethodID, ...) CallStaticFloatMethod;
    jfloat function(JNIEnv*, jclass, jmethodID, va_list) CallStaticFloatMethodV;
    jfloat function(JNIEnv*, jclass, jmethodID, jvalue*) CallStaticFloatMethodA;
    jdouble function(JNIEnv*, jclass, jmethodID, ...) CallStaticDoubleMethod;
    jdouble function(JNIEnv*, jclass, jmethodID, va_list) CallStaticDoubleMethodV;
    jdouble function(JNIEnv*, jclass, jmethodID, jvalue*) CallStaticDoubleMethodA;
    void function(JNIEnv*, jclass, jmethodID, ...) CallStaticVoidMethod;
    void function(JNIEnv*, jclass, jmethodID, va_list) CallStaticVoidMethodV;
    void function(JNIEnv*, jclass, jmethodID, jvalue*) CallStaticVoidMethodA;
    jfieldID function(JNIEnv*, jclass, const(char)*, const(char)*) GetStaticFieldID;
    jobject function(JNIEnv*, jclass, jfieldID) GetStaticObjectField;
    jboolean function(JNIEnv*, jclass, jfieldID) GetStaticBooleanField;
    jbyte function(JNIEnv*, jclass, jfieldID) GetStaticByteField;
    jchar function(JNIEnv*, jclass, jfieldID) GetStaticCharField;
    jshort function(JNIEnv*, jclass, jfieldID) GetStaticShortField;
    jint function(JNIEnv*, jclass, jfieldID) GetStaticIntField;
    jlong function(JNIEnv*, jclass, jfieldID) GetStaticLongField;
    jfloat function(JNIEnv*, jclass, jfieldID) GetStaticFloatField;
    jdouble function(JNIEnv*, jclass, jfieldID) GetStaticDoubleField;
    void function(JNIEnv*, jclass, jfieldID, jobject) SetStaticObjectField;
    void function(JNIEnv*, jclass, jfieldID, jboolean) SetStaticBooleanField;
    void function(JNIEnv*, jclass, jfieldID, jbyte) SetStaticByteField;
    void function(JNIEnv*, jclass, jfieldID, jchar) SetStaticCharField;
    void function(JNIEnv*, jclass, jfieldID, jshort) SetStaticShortField;
    void function(JNIEnv*, jclass, jfieldID, jint) SetStaticIntField;
    void function(JNIEnv*, jclass, jfieldID, jlong) SetStaticLongField;
    void function(JNIEnv*, jclass, jfieldID, jfloat) SetStaticFloatField;
    void function(JNIEnv*, jclass, jfieldID, jdouble) SetStaticDoubleField;
    jstring function(JNIEnv*, const(jchar)*, jsize) NewString;
    jsize function(JNIEnv*, jstring) GetStringLength;
    const(jchar)* function(JNIEnv*, jstring, jboolean*) GetStringChars;
    void function(JNIEnv*, jstring, const(jchar)*) ReleaseStringChars;
    jstring function(JNIEnv*, const(char)*) NewStringUTF;
    jsize function(JNIEnv*, jstring) GetStringUTFLength;
    const(char)* function(JNIEnv*, jstring, jboolean*) GetStringUTFChars;
    void function(JNIEnv*, jstring, const(char)*) ReleaseStringUTFChars;
    jsize function(JNIEnv*, jarray) GetArrayLength;
    jobjectArray function(JNIEnv*, jsize, jclass, jobject) NewObjectArray;
    jobject function(JNIEnv*, jobjectArray, jsize) GetObjectArrayElement;
    void function(JNIEnv*, jobjectArray, jsize, jobject) SetObjectArrayElement;
    jbooleanArray function(JNIEnv*, jsize) NewBooleanArray;
    jbyteArray function(JNIEnv*, jsize) NewByteArray;
    jcharArray function(JNIEnv*, jsize) NewCharArray;
    jshortArray function(JNIEnv*, jsize) NewShortArray;
    jintArray function(JNIEnv*, jsize) NewIntArray;
    jlongArray function(JNIEnv*, jsize) NewLongArray;
    jfloatArray function(JNIEnv*, jsize) NewFloatArray;
    jdoubleArray function(JNIEnv*, jsize) NewDoubleArray;
    jboolean* function(JNIEnv*, jbooleanArray, jboolean*) GetBooleanArrayElements;
    jbyte* function(JNIEnv*, jbyteArray, jboolean*) GetByteArrayElements;
    jchar* function(JNIEnv*, jcharArray, jboolean*) GetCharArrayElements;
    jshort* function(JNIEnv*, jshortArray, jboolean*) GetShortArrayElements;
    jint* function(JNIEnv*, jintArray, jboolean*) GetIntArrayElements;
    jlong* function(JNIEnv*, jlongArray, jboolean*) GetLongArrayElements;
    jfloat* function(JNIEnv*, jfloatArray, jboolean*) GetFloatArrayElements;
    jdouble* function(JNIEnv*, jdoubleArray, jboolean*) GetDoubleArrayElements;
    void function(JNIEnv*, jbooleanArray, jboolean*, jint) ReleaseBooleanArrayElements;
    void function(JNIEnv*, jbyteArray, jbyte*, jint) ReleaseByteArrayElements;
    void function(JNIEnv*, jcharArray, jchar*, jint) ReleaseCharArrayElements;
    void function(JNIEnv*, jshortArray, jshort*, jint) ReleaseShortArrayElements;
    void function(JNIEnv*, jintArray, jint*, jint) ReleaseIntArrayElements;
    void function(JNIEnv*, jlongArray, jlong*, jint) ReleaseLongArrayElements;
    void function(JNIEnv*, jfloatArray, jfloat*, jint) ReleaseFloatArrayElements;
    void function(JNIEnv*, jdoubleArray, jdouble*, jint) ReleaseDoubleArrayElements;
    void function(JNIEnv*, jbooleanArray, jsize, jsize, jboolean*) GetBooleanArrayRegion;
    void function(JNIEnv*, jbyteArray, jsize, jsize, jbyte*) GetByteArrayRegion;
    void function(JNIEnv*, jcharArray, jsize, jsize, jchar*) GetCharArrayRegion;
    void function(JNIEnv*, jshortArray, jsize, jsize, jshort*) GetShortArrayRegion;
    void function(JNIEnv*, jintArray, jsize, jsize, jint*) GetIntArrayRegion;
    void function(JNIEnv*, jlongArray, jsize, jsize, jlong*) GetLongArrayRegion;
    void function(JNIEnv*, jfloatArray, jsize, jsize, jfloat*) GetFloatArrayRegion;
    void function(JNIEnv*, jdoubleArray, jsize, jsize, jdouble*) GetDoubleArrayRegion;
    void function(JNIEnv*, jbooleanArray, jsize, jsize, const(jboolean)*) SetBooleanArrayRegion;
    void function(JNIEnv*, jbyteArray, jsize, jsize, const(jbyte)*) SetByteArrayRegion;
    void function(JNIEnv*, jcharArray, jsize, jsize, const(jchar)*) SetCharArrayRegion;
    void function(JNIEnv*, jshortArray, jsize, jsize, const(jshort)*) SetShortArrayRegion;
    void function(JNIEnv*, jintArray, jsize, jsize, const(jint)*) SetIntArrayRegion;
    void function(JNIEnv*, jlongArray, jsize, jsize, const(jlong)*) SetLongArrayRegion;
    void function(JNIEnv*, jfloatArray, jsize, jsize, const(jfloat)*) SetFloatArrayRegion;
    void function(JNIEnv*, jdoubleArray, jsize, jsize, const(jdouble)*) SetDoubleArrayRegion;
    jint function(JNIEnv*, jclass, const(JNINativeMethod)*, jint) RegisterNatives;
    jint function(JNIEnv*, jclass) UnregisterNatives;
    jint function(JNIEnv*, jobject) MonitorEnter;
    jint function(JNIEnv*, jobject) MonitorExit;
    jint function(JNIEnv*, JavaVM**) GetJavaVM;
    void function(JNIEnv*, jstring, jsize, jsize, jchar*) GetStringRegion;
    void function(JNIEnv*, jstring, jsize, jsize, char*) GetStringUTFRegion;
    void* function(JNIEnv*, jarray, jboolean*) GetPrimitiveArrayCritical;
    void function(JNIEnv*, jarray, void*, jint) ReleasePrimitiveArrayCritical;
    const(jchar)* function(JNIEnv*, jstring, jboolean*) GetStringCritical;
    void function(JNIEnv*, jstring, const(jchar)*) ReleaseStringCritical;
    jweak function(JNIEnv*, jobject) NewWeakGlobalRef;
    void function(JNIEnv*, jweak) DeleteWeakGlobalRef;
    jboolean function(JNIEnv*) ExceptionCheck;
    jobject function(JNIEnv*, void*, jlong) NewDirectByteBuffer;
    void* function(JNIEnv*, jobject) GetDirectBufferAddress;
    jlong function(JNIEnv*, jobject) GetDirectBufferCapacity;
    jobjectRefType function(JNIEnv*, jobject) GetObjectRefType;
}

struct _JNIEnv
{
    const(JNINativeInterface)* functions;
}

struct JNIInvokeInterface
{
    void* reserved0;
    void* reserved1;
    void* reserved2;
    jint function(JavaVM*) DestroyJavaVM;
    jint function(JavaVM*, JNIEnv**, void*) AttachCurrentThread;
    jint function(JavaVM*) DetachCurrentThread;
    jint function(JavaVM*, void**, jint) GetEnv;
    jint function(JavaVM*, JNIEnv**, void*) AttachCurrentThreadAsDaemon;
}

struct _JavaVM
{
    const(JNIInvokeInterface)* functions;
}

struct JavaVMAttachArgs
{
    jint version_;
    const(char)* name;
    jobject group;
}

struct JavaVMOption
{
    const(char)* optionString;
    void* extraInfo;
}

struct JavaVMInitArgs
{
    jint version_;
    jint nOptions;
    JavaVMOption* options;
    jboolean ignoreUnrecognized;
}

struct _jfieldID;
struct _jmethodID;

union jvalue
{
    jboolean z;
    jbyte b;
    jchar c;
    jshort s;
    jint i;
    jlong j;
    jfloat f;
    jdouble d;
    jobject l;
}

jint JNI_OnLoad(JavaVM* vm, void* reserved);
void JNI_OnUnload(JavaVM* vm, void* reserved);
