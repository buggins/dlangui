module fontconfig.fctypes;

import std.string : toStringz, fromStringz, toLower;
import std.algorithm : endsWith;

alias FcChar8 = char;
alias FcChar16 = wchar;
alias FcChar32 = dchar;
alias FcBool = int;

enum : int {
    FcFalse = 0,
    FcTrue = 1
}

struct FcMatrix {
    double xx, xy, yx, yy;
}

struct FcCharSet {}

struct FcLangSet {}

struct FcConfig {}

enum : int {
    FcTypeUnknown = -1,
    FcTypeVoid,
    FcTypeInteger,
    FcTypeDouble,
    FcTypeString,
    FcTypeBool,
    FcTypeMatrix,
    FcTypeCharSet,
    FcTypeFTFace,
    FcTypeLangSet,
    FcTypeRange
}

alias FcType = int;

enum : int {
    FcResultMatch,
    FcResultNoMatch,
    FcResultTypeMismatch,
    FcResultNoId,
    FcResultOutOfMemory
}

alias FcResult = int;

struct FcValue {
    FcType    type;
    union {
        const FcChar8    *s;
        int        i;
        FcBool        b;
        double        d;
        const FcMatrix    *m;
        const FcCharSet    *c;
        void        *f;
        const FcLangSet    *l;
        const FcRange    *r;
    }
}

enum FcMatchKind {
    FcMatchPattern,
    FcMatchFont,
    FcMatchScan
}

enum FcLangResult {
    FcLangEqual = 0,
    FcLangDifferentCountry = 1,
    FcLangDifferentTerritory = 1,
    FcLangDifferentLang = 2
}

enum FcSetName {
    FcSetSystem = 0,
    FcSetApplication = 1
}

enum FcEndian {
    FcEndianBig,
    FcEndianLittle
}

struct FcFontSet {
    int        nfont;
    int        sfont;
    FcPattern    **fonts;
}

struct FcObjectSet {
    int        nobject;
    int        sobject;
    const char    **objects;
}

struct FcPattern {}

struct FcRange {}

enum {
    FC_WEIGHT_THIN = 0,
    FC_WEIGHT_EXTRALIGHT = 40,
    FC_WEIGHT_ULTRALIGHT = FC_WEIGHT_EXTRALIGHT,
    FC_WEIGHT_LIGHT = 50,
    FC_WEIGHT_DEMILIGHT = 55,
    FC_WEIGHT_SEMILIGHT = FC_WEIGHT_DEMILIGHT,
    FC_WEIGHT_BOOK = 75,
    FC_WEIGHT_REGULAR = 80,
    FC_WEIGHT_NORMAL = FC_WEIGHT_REGULAR,
    FC_WEIGHT_MEDIUM = 100,
    FC_WEIGHT_DEMIBOLD = 180,
    FC_WEIGHT_SEMIBOLD = FC_WEIGHT_DEMIBOLD,
    FC_WEIGHT_BOLD = 200,
    FC_WEIGHT_EXTRABOLD = 205,
    FC_WEIGHT_ULTRABOLD = FC_WEIGHT_EXTRABOLD,
    FC_WEIGHT_BLACK = 210,
    FC_WEIGHT_HEAVY = FC_WEIGHT_BLACK,
    FC_WEIGHT_EXTRABLACK = 215,
    FC_WEIGHT_ULTRABLACK = FC_WEIGHT_EXTRABLACK
}

enum {
    FC_SLANT_ROMAN            =0,
    FC_SLANT_ITALIC            =100,
    FC_SLANT_OBLIQUE        =110
}

enum {
    FC_WIDTH_ULTRACONDENSED        =50,
    FC_WIDTH_EXTRACONDENSED        =63,
    FC_WIDTH_CONDENSED        =75,
    FC_WIDTH_SEMICONDENSED        =87,
    FC_WIDTH_NORMAL            =100,
    FC_WIDTH_SEMIEXPANDED        =113,
    FC_WIDTH_EXPANDED        =125,
    FC_WIDTH_EXTRAEXPANDED        =150,
    FC_WIDTH_ULTRAEXPANDED        =200
}

enum {
    FC_PROPORTIONAL        =0,
    FC_DUAL                =90,
    FC_MONO                =100,
    FC_CHARCELL            =110
}

const FC_FAMILY = "family";        /* String */
const FC_STYLE = "style";        /* String */
const FC_SLANT = "slant";        /* Int */
const FC_WEIGHT = "weight";        /* Int */
const FC_SIZE = "size";        /* Range (double) */
const FC_ASPECT = "aspect";        /* Double */
const FC_PIXEL_SIZE = "pixelsize";        /* Double */
const FC_SPACING = "spacing";        /* Int */
const FC_FOUNDRY = "foundry";        /* String */
const FC_ANTIALIAS = "antialias";        /* Bool (depends) */
const FC_HINTING = "hinting";        /* Bool (true) */
const FC_HINT_STYLE = "hintstyle";        /* Int */
const FC_VERTICAL_LAYOUT = "verticallayout";    /* Bool (false) */
const FC_AUTOHINT = "autohint";        /* Bool (false) */
const FC_GLOBAL_ADVANCE = "globaladvance";    /* Bool (true) */
const FC_WIDTH = "width";        /* Int */
const FC_FILE = "file";        /* String */
const FC_INDEX = "index";        /* Int */
const FC_FT_FACE = "ftface";        /* FT_Face */
const FC_RASTERIZER = "rasterizer";    /* String (deprecated) */
const FC_OUTLINE = "outline";        /* Bool */
const FC_SCALABLE = "scalable";        /* Bool */
const FC_COLOR = "color";        /* Bool */
const FC_SCALE = "scale";        /* double */
const FC_DPI = "dpi";        /* double */
const FC_RGBA = "rgba";        /* Int */
const FC_MINSPACE = "minspace";        /* Bool use minimum line spacing */
const FC_SOURCE = "source";        /* String (deprecated) */
const FC_CHARSET = "charset";        /* CharSet */
const FC_LANG = "lang";        /* String RFC 3066 langs */
const FC_FONTVERSION = "fontversion";    /* Int from 'head' table */
const FC_FULLNAME = "fullname";    /* String */
const FC_FAMILYLANG = "familylang";    /* String RFC 3066 langs */
const FC_STYLELANG = "stylelang";        /* String RFC 3066 langs */
const FC_FULLNAMELANG = "fullnamelang";    /* String RFC 3066 langs */
const FC_CAPABILITY = "capability";    /* String */
const FC_FONTFORMAT = "fontformat";    /* String */
const FC_EMBOLDEN = "embolden";        /* Bool - true if emboldening needed*/
const FC_EMBEDDED_BITMAP = "embeddedbitmap";    /* Bool - true to enable embedded bitmaps */
const FC_DECORATIVE = "decorative";    /* Bool - true if style is a decorative variant */
const FC_LCD_FILTER    = "lcdfilter";        /* Int */
const FC_FONT_FEATURES = "fontfeatures";    /* String */
const FC_NAMELANG = "namelang";        /* String RFC 3866 langs */
const FC_PRGNAME = "prgname";        /* String */
const FC_HASH = "hash";        /* String (deprecated) */
const FC_POSTSCRIPT_NAME = "postscriptname";    /* String */


