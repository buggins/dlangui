module dlangui.platforms.android.imm;

version(Android):

import jni;
import android.android_native_app_glue;
import android.input;

import dlangui.core.logger;


alias IMMResult = int;
// values from InputMethodManager.java
private enum : IMMResult
{
    RESULT_UNCHANGED_SHOWN = 0,
    RESULT_UNCHANGED_HIDDEN = 1,
    RESULT_SHOWN = 2,
    RESULT_HIDDEN = 3,
}


alias IMMFlags = int;
// values from InputMethodManager.java
private enum : IMMFlags
{
    SHOW_IMPLICIT = 0x0001,
    SHOW_FORCED = 0x0002,

    HIDE_IMPLICIT_ONLY = 0x0001,
    HIDE_NOT_ALWAYS = 0x0002,
}



/**
* JNI wrapper used with native actitiy to show/hide software keyboard
* It relies on java reflection and it might be slow.
*/
void showSoftKeyboard(android_app* app, bool shouldShow)
{
    // The code is based on https://stackoverflow.com/questions/5864790/how-to-show-the-soft-keyboard-on-native-activity
    // Attaches the current thread to the JVM.
    jint result;
    IMMFlags flags;

    auto javaVM = app.activity.vm;
    auto env = app.activity.env;

    JavaVMAttachArgs attachArgs;
    attachArgs.version_ = JNI_VERSION_1_6;
    attachArgs.name = "NativeThread";
    attachArgs.group = null;

    if ((*javaVM).AttachCurrentThread(javaVM, &env, &attachArgs) == JNI_ERR)
    {
        Log.e("showSoftKeyboard Unable to attach to JVM");
        return;
    }

    // Retrieves NativeActivity.
    jobject nativeActivity = app.activity.clazz;
    jclass nativeActivityClass = (*env).GetObjectClass(env, nativeActivity);

    // Retrieves Context.INPUT_METHOD_SERVICE.
    jclass contextClass = (*env).FindClass(env, "android/content/Context");
    jfieldID FieldINPUT_METHOD_SERVICE =
        (*env).GetStaticFieldID(env, contextClass,
            "INPUT_METHOD_SERVICE", "Ljava/lang/String;");
    jobject INPUT_METHOD_SERVICE =
        (*env).GetStaticObjectField(env, contextClass, FieldINPUT_METHOD_SERVICE);
    //jniCheck(INPUT_METHOD_SERVICE);

    // Runs getSystemService(Context.INPUT_METHOD_SERVICE).
    jclass immClass = (*env).FindClass(
        env, "android/view/inputmethod/InputMethodManager");
    jmethodID MethodGetSystemService = (*env).GetMethodID(
        env, nativeActivityClass, "getSystemService",
        "(Ljava/lang/String;)Ljava/lang/Object;");
    jobject imm = (*env).CallObjectMethod(
        env, nativeActivity, MethodGetSystemService,
        INPUT_METHOD_SERVICE);

    // Runs getWindow().getDecorView().
    jmethodID MethodGetWindow = (*env).GetMethodID(
        env, nativeActivityClass, "getWindow", "()Landroid/view/Window;");
    jobject window = (*env).CallObjectMethod(
        env, nativeActivity, MethodGetWindow);
    jclass windowClass = (*env).FindClass(
        env, "android/view/Window");
    jmethodID MethodGetDecorView = (*env).GetMethodID(
        env, windowClass, "getDecorView", "()Landroid/view/View;");
    jobject decorView = (*env).CallObjectMethod(
        env, window, MethodGetDecorView);

    if (shouldShow) {
        // Runs imm.showSoftInput(...).
        jmethodID MethodShowSoftInput = (*env).GetMethodID(
            env, immClass, "showSoftInput", "(Landroid/view/View;I)Z");
        jboolean res = (*env).CallBooleanMethod(
            env, imm, MethodShowSoftInput, decorView, flags);
    } else {
        // Runs lWindow.getViewToken()
        jclass viewClass = (*env).FindClass(
            env, "android/view/View");
        jmethodID MethodGetWindowToken = (*env).GetMethodID(
            env, viewClass, "getWindowToken", "()Landroid/os/IBinder;");
        jobject binder = (*env).CallObjectMethod(
            env, decorView, MethodGetWindowToken);

        // lInputMethodManager.hideSoftInput(...).
        jmethodID MethodHideSoftInput = (*env).GetMethodID(
            env, immClass, "hideSoftInputFromWindow",
            "(Landroid/os/IBinder;I)Z");
        jboolean res = (*env).CallBooleanMethod(
            env, imm, MethodHideSoftInput, binder, flags);
    }

    // Finished with the JVM.
    (*javaVM).DetachCurrentThread(javaVM);
}


int GetUnicodeChar(android_app* app, int eventType, int keyCode, int metaState)
{
    auto javaVM = app.activity.vm;
    auto env = app.activity.env;

    JavaVMAttachArgs attachArgs;
    attachArgs.version_ = JNI_VERSION_1_6;
    attachArgs.name = "NativeThread";
    attachArgs.group = null;

    if ((*javaVM).AttachCurrentThread(javaVM, &env, &attachArgs) == JNI_ERR)
        return 0;

    jclass class_key_event = (*env).FindClass(env, "android/view/KeyEvent");
    int unicodeKey;

    if(metaState == 0)
    {
        jmethodID method_get_unicode_char = (*env).GetMethodID(env, class_key_event, "getUnicodeChar", "()I");
        jmethodID eventConstructor = (*env).GetMethodID(env, class_key_event, "<init>", "(II)V");
        jobject eventObj = (*env).NewObject(env, class_key_event, eventConstructor, eventType, keyCode);

        unicodeKey = (*env).CallIntMethod(env, eventObj, method_get_unicode_char);
    }
    else
    {
        jmethodID method_get_unicode_char = (*env).GetMethodID(env, class_key_event, "getUnicodeChar", "(I)I");
        jmethodID eventConstructor = (*env).GetMethodID(env, class_key_event, "<init>", "(II)V");
        jobject eventObj = (*env).NewObject(env, class_key_event, eventConstructor, eventType, keyCode);

        unicodeKey = (*env).CallIntMethod(env, eventObj, method_get_unicode_char, metaState);
    }

    (*javaVM).DetachCurrentThread(javaVM);

    return unicodeKey;
}


// Issue: native app glue seems to mess up the input. 
// It is clearly seen in debugger that initally key event do have real input, 
//    but second time it is called it is all messed up
string GetUnicodeString(android_app* app, AInputEvent* event)
{
    string str;
    auto javaVM = app.activity.vm;
    auto env = app.activity.env;

    JavaVMAttachArgs attachArgs;
    attachArgs.version_ = JNI_VERSION_1_6;
    attachArgs.name = "NativeThread";
    attachArgs.group = null;

    if ((*javaVM).AttachCurrentThread(javaVM, &env, &attachArgs) == JNI_ERR)
    {
        Log.e("showSoftKeyboard Unable to attach to JVM");
        return null;
    }


    jclass class_key_event = (*env).FindClass(env, "android/view/KeyEvent");

    jmethodID eventConstructor = (*env).GetMethodID(env, class_key_event, "<init>", "(JJIIIIIIII)V");
    jobject eventObj = (*env).NewObject(env, class_key_event, eventConstructor, 
        AKeyEvent_getDownTime(event), 
        AKeyEvent_getEventTime(event), 
        AKeyEvent_getAction(event), 
        AKeyEvent_getKeyCode(event), 
        AKeyEvent_getRepeatCount(event), 
        AKeyEvent_getMetaState(event),
        AInputEvent_getDeviceId(event),
        AKeyEvent_getScanCode(event),
        AKeyEvent_getFlags(event),
        AInputEvent_getSource(event)
    );
    
    // this won't work because characters is a member passed on construction and getCharacter() is just a getter
    jmethodID method_get_characters = (*env).GetMethodID(env, class_key_event, "getCharacters", "()Ljava/lang/String;");
    if (auto jstr = (*env).CallObjectMethod(env, eventObj, method_get_characters)) {
        str.length = (*env).GetStringUTFLength(env, jstr);
        (*env).GetStringUTFRegion(env, jstr, 0, str.length, cast(char*)str.ptr);
    }

    {
        jmethodID method_get_unicode_char = (*env).GetMethodID(env, class_key_event, "getUnicodeChar", "()I");
        int unicodeKey = (*env).CallIntMethod(env, eventObj, method_get_unicode_char);
        if (str.length == 0) {
            import std.conv : to;
            dchar[] tmp;
            tmp ~= unicodeKey;
            str = to!string(tmp);
        }
    }
    
    (*javaVM).DetachCurrentThread(javaVM);

    return str;
}