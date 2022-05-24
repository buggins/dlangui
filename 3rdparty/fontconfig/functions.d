module fontconfig.functions;

public import fontconfig.fctypes;


extern( C ) @nogc nothrow {

    alias pFcObjectSetBuild = FcObjectSet * function(const char *first, ...);

    alias pFcPatternCreate = FcPattern * function();

    alias pFcPatternAddBool = FcBool function(FcPattern *p, const char *object, FcBool b);

    alias pFcFontList = FcFontSet * function(FcConfig    *config, FcPattern    *p, FcObjectSet *os);

    alias pFcPatternDestroy = void function(FcPattern *p);

    alias pFcObjectSetDestroy = void function(FcObjectSet *os);

    alias pFcPatternGetString = FcResult function(const FcPattern *p, const char *object, int n, FcChar8 ** s);

    alias pFcPatternGetInteger = FcResult function(const FcPattern *p, const char *object, int n, int *i);

    alias pFcPatternGetBool = FcResult function(const FcPattern *p, const char *object, int n, FcBool *b);

    alias pFcFontSetDestroy = void  function(FcFontSet *s);
}

__gshared {

    pFcObjectSetBuild FcObjectSetBuild;

    pFcPatternCreate FcPatternCreate;

    pFcPatternAddBool FcPatternAddBool;

    pFcFontList FcFontList;

    pFcPatternDestroy FcPatternDestroy;

    pFcObjectSetDestroy FcObjectSetDestroy;

    pFcPatternGetString FcPatternGetString;

    pFcPatternGetInteger FcPatternGetInteger;

    pFcPatternGetBool FcPatternGetBool;

    pFcFontSetDestroy FcFontSetDestroy;
}

/+
extern(C) FcObjectSet * FcObjectSetBuild(const char *first, ...);

extern(C) FcPattern * FcPatternCreate();

extern(C) FcBool FcPatternAddBool(FcPattern *p, const char *object, FcBool b);

extern(C) FcFontSet * FcFontList(FcConfig    *config, FcPattern    *p, FcObjectSet *os);

extern(C) void FcPatternDestroy(FcPattern *p);

extern(C) void FcObjectSetDestroy(FcObjectSet *os);

extern(C) FcResult FcPatternGetString(const FcPattern *p, const char *object, int n, FcChar8 ** s);

extern(C) FcResult FcPatternGetInteger(const FcPattern *p, const char *object, int n, int *i);

extern(C) FcResult FcPatternGetBool (const FcPattern *p, const char *object, int n, FcBool *b);

extern(C) void FcFontSetDestroy (FcFontSet *s);

+/