module fontconfig;

public import fontconfig.fctypes;
public import fontconfig.functions;

private {
    import derelict.util.loader;
    import derelict.util.system;

    static if( Derelict_OS_Windows )
        enum libNames = "libfontconfig-1.dll";
    else static if( Derelict_OS_Mac )
        enum libNames = "/usr/local/lib/libfontconfig.dylib";
    else static if( Derelict_OS_Posix )
        enum libNames = "libfontconfig.so.1, libfontconfig.so";
    else
        static assert( 0, "Need to implement FontConfig libNames for this operating system." );
}


class DerelictFCLoader : SharedLibLoader {
      public this() {
            super( libNames );
      }

      protected override void loadSymbols() {
            bindFunc( cast( void** )&FcObjectSetBuild, "FcObjectSetBuild" );
            bindFunc( cast( void** )&FcPatternCreate, "FcPatternCreate" );
            bindFunc( cast( void** )&FcPatternAddBool, "FcPatternAddBool" );
            bindFunc( cast( void** )&FcFontList, "FcFontList" );
            bindFunc( cast( void** )&FcPatternDestroy, "FcPatternDestroy" );
            bindFunc( cast( void** )&FcObjectSetDestroy, "FcObjectSetDestroy" );
            bindFunc( cast( void** )&FcPatternGetString, "FcPatternGetString" );
            bindFunc( cast( void** )&FcPatternGetInteger, "FcPatternGetInteger" );
            bindFunc( cast( void** )&FcPatternGetBool, "FcPatternGetBool" );
            bindFunc( cast( void** )&FcFontSetDestroy, "FcFontSetDestroy" );
      }
}

__gshared DerelictFCLoader DerelictFC;

shared static this() {
    DerelictFC = new DerelictFCLoader();
}
