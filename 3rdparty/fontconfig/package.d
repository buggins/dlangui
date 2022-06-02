module fontconfig;

public import fontconfig.fctypes;
public import fontconfig.functions;

import bindbc.loader;

enum FCSupport {
    noLibrary,
    badLibrary,
    // TODO: real versions and stuff
    fc100      = 100,
}

private {
    SharedLib lib;
    FCSupport loadedVersion;
}


@nogc nothrow:
void unloadFC()
{
    if(lib != invalidHandle) {
        lib.unload();
    }
}


FCSupport loadedFCVersion() { return loadedVersion; }

bool isFCLoaded()
{
    return  lib != invalidHandle;
}


FCSupport loadFC()
{
    // #1778 prevents from using static arrays here :(
    version(Windows) {
        const(char)[][1] libNames = [ "libfontconfig-1.dll"];
    }
    else version(OSX) {
        const(char)[][1] libNames = [
            "/usr/local/lib/libfontconfig.dylib"
        ];
    }
    else version(Posix) {
        const(char)[][2] libNames = [
            "libfontconfig.so.1", 
            "libfontconfig.so"
        ];
    }
    else static assert(0, "bindbc-fc is not yet supported on this platform.");

    FCSupport ret;
    foreach(name; libNames) {
        ret = loadFC(name.ptr);
        if(ret != FCSupport.noLibrary) break;
    }
    return ret;
}

FCSupport loadFC(const(char)* libName)
{
    lib = load(libName);
    if(lib == invalidHandle) {
        return FCSupport.noLibrary;
    }

    auto errCount = errorCount();
    loadedVersion = FCSupport.badLibrary;

    lib.bindSymbol( cast( void** )&FcObjectSetBuild, "FcObjectSetBuild" );
    lib.bindSymbol( cast( void** )&FcPatternCreate, "FcPatternCreate" );
    lib.bindSymbol( cast( void** )&FcPatternAddBool, "FcPatternAddBool" );
    lib.bindSymbol( cast( void** )&FcFontList, "FcFontList" );
    lib.bindSymbol( cast( void** )&FcPatternDestroy, "FcPatternDestroy" );
    lib.bindSymbol( cast( void** )&FcObjectSetDestroy, "FcObjectSetDestroy" );
    lib.bindSymbol( cast( void** )&FcPatternGetString, "FcPatternGetString" );
    lib.bindSymbol( cast( void** )&FcPatternGetInteger, "FcPatternGetInteger" );
    lib.bindSymbol( cast( void** )&FcPatternGetBool, "FcPatternGetBool" );
    lib.bindSymbol( cast( void** )&FcFontSetDestroy, "FcFontSetDestroy" );

    if(errorCount() != errCount) return FCSupport.badLibrary;
    else loadedVersion = FCSupport.fc100;

    return loadedVersion;
}
