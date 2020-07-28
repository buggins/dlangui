// Written in the D programming language.

/**
This file contains FontManager implementation based on FreeType library.

Copyright: Vadim Lopatin, 2014
License:   Boost License 1.0
Authors:   Vadim Lopatin, coolreader.org@gmail.com
*/
module dlangui.graphics.ftfonts;

import dlangui.core.config;
static if (ENABLE_FREETYPE):

import dlangui.graphics.fonts;

import derelict.freetype.ft;
import dlangui.core.logger;
import dlangui.core.collections;
import std.algorithm;
import std.file;
import std.string;
import std.utf;

__gshared int[string] STD_FONT_FACES;

int stdFontFacePriority(string face) {
    if (auto p = (face in STD_FONT_FACES))
        return *p;
    return 0;
}

/// define debug=FontResources for logging of font file resources creation/freeing
//debug = FontResources;

private struct FontDef {
    immutable FontFamily family;
    immutable string face;
    immutable bool italic;
    immutable int weight;

    this(FontFamily family, string face, bool italic, int weight) {
        this.family = family;
        this.face = face;
        this.italic = italic;
        this.weight = weight;
    }
    bool opEquals(ref const FontDef v) const {
        return family == v.family && italic == v.italic && weight == v.weight && face.equal(v.face);
    }
    hash_t toHash() const nothrow @safe {
        hash_t res = 123;
        res = res * 31 + cast(hash_t)italic;
        res = res * 31 + cast(hash_t)weight;
        res = res * 31 + cast(hash_t)family;
        res = res * 31 + typeid(face).getHash(&face);
        return res;
    }
}

private class FontFileItem {
    private FontList _activeFonts;
    private FT_Library _library;
    private FontDef _def;
    string[] _filenames;
    @property ref FontDef def() { return _def; }
    @property string[] filenames() { return _filenames; }
    @property FT_Library library() { return _library; }
    void addFile(string fn) {
        // check for duplicate entry
        foreach (ref string existing; _filenames)
            if (fn.equal(existing))
                return;
        _filenames ~= fn;
    }
    this(FT_Library library, ref FontDef def) {
        _library = library;
        _def = def;
    }

    private FontRef _nullFontRef;
    ref FontRef get(int size) {
        int index = _activeFonts.find(size);
        if (index >= 0)
            return _activeFonts.get(index);
        FreeTypeFont font = new FreeTypeFont(this, size);
        if (!font.create()) {
            destroy(font);
            return _nullFontRef;
        }
        return _activeFonts.add(font);
    }

    void clearGlyphCaches() {
        _activeFonts.clearGlyphCache();
    }
    void checkpoint() {
        _activeFonts.checkpoint();
    }
    void cleanup() {
        _activeFonts.cleanup();
    }
}

class FreeTypeFontFile {
    private string _filename;
    private string _faceName;
    private FT_Library    _library;
    private FT_Face       _face;
    private FT_GlyphSlot  _slot;
    private FT_Matrix     _matrix;                 /* transformation matrix */

    @property FT_Library library() { return _library; }

    private int _height;
    private int _size;
    private int _baseline;
    private int _weight;
    private bool _italic;

    private bool _allowKerning = true;

    /// filename
    @property string filename() { return _filename; }
    // properties as detected after opening of file
    @property string face() { return _faceName; }
    @property int height() { return _height; }
    @property int size() { return _size; }
    @property int baseline() { return _baseline; }
    @property int weight() { return _weight; }
    @property bool italic() { return _italic; }

    debug private static __gshared int _instanceCount;
    debug @property static int instanceCount() { return _instanceCount; }
    this(FT_Library library, string filename) {
        _library = library;
        _filename = filename;
        _matrix.xx = 0x10000;
        _matrix.yy = 0x10000;
        _matrix.xy = 0;
        _matrix.yx = 0;
        debug ++_instanceCount;
        debug(FontResources) Log.d("Created FreeTypeFontFile, count=", _instanceCount);
    }

    ~this() {
        clear();
        debug --_instanceCount;
        debug(FontResources) Log.d("Destroyed FreeTypeFontFile, count=", _instanceCount);
    }

    private static string familyName(FT_Face face)
    {
        string faceName = fromStringz(face.family_name).dup;
        string styleName = fromStringz(face.style_name).dup;
        if (faceName.equal("Arial") && styleName.equal("Narrow"))
            faceName ~= " Narrow";
        else if (styleName.equal("Condensed"))
            faceName ~= " Condensed";
        return faceName;
    }

    /// open face with specified size
    bool open(int size, int index = 0) {
        int error = FT_New_Face( _library, _filename.toStringz, index, &_face); /* create face object */
        if (error)
            return false;
        if ( _filename.endsWith(".pfb") || _filename.endsWith(".pfa") ) {
            string kernFile = _filename[0 .. $ - 4];
            if (exists(kernFile ~ ".afm")) {
                kernFile ~= ".afm";
            } else if (exists(kernFile ~ ".pfm" )) {
                kernFile ~= ".pfm";
            } else {
                kernFile.destroy();
            }
            if (kernFile.length > 0)
                error = FT_Attach_File(_face, kernFile.toStringz);
        }
        debug(FontResources) Log.d("Font file opened successfully");
        _slot = _face.glyph;
        _faceName = familyName(_face);
        error = FT_Set_Pixel_Sizes(
                _face,    /* handle to face object */
                0,        /* pixel_width           */
                size );  /* pixel_height          */
        if (error) {
            clear();
            return false;
        }
        _height = cast(int)((_face.size.metrics.height + 63) >> 6);
        _size = size;
        _baseline = _height + cast(int)(_face.size.metrics.descender >> 6);
        _weight = _face.style_flags & FT_STYLE_FLAG_BOLD ? FontWeight.Bold : FontWeight.Normal;
        _italic = _face.style_flags & FT_STYLE_FLAG_ITALIC ? true : false;
        debug(FontResources) Log.d("Opened font face=", _faceName, " height=", _height, " size=", size, " weight=", weight, " italic=", italic);
        return true; // successfully opened
    }


    /// find glyph index for character
    FT_UInt getCharIndex(dchar code, dchar def_char = 0) {
        if ( code=='\t' )
            code = ' ';
        FT_UInt ch_glyph_index = FT_Get_Char_Index(_face, code);
        if (ch_glyph_index == 0) {
            dchar replacement = getReplacementChar(code);
            if (replacement) {
                ch_glyph_index = FT_Get_Char_Index(_face, replacement);
                if (ch_glyph_index == 0) {
                    replacement = getReplacementChar(replacement);
                    if (replacement) {
                        ch_glyph_index = FT_Get_Char_Index(_face, replacement);
                    }
                }
            }
            if (ch_glyph_index == 0 && def_char)
                ch_glyph_index = FT_Get_Char_Index( _face, def_char );
        }
        return ch_glyph_index;
    }

    /// allow kerning
    @property bool allowKerning() {
        return FT_HAS_KERNING( _face );
    }

    /// retrieve glyph information, filling glyph struct; returns false if glyph not found
    bool getGlyphInfo(dchar code, ref Glyph glyph, dchar def_char, bool withImage = true)
    {
        //FONT_GUARD
        int glyph_index = getCharIndex(code, def_char);
        int flags = FT_LOAD_DEFAULT;
        const bool _drawMonochrome = _size < FontManager.minAnitialiasedFontSize;
        SubpixelRenderingMode subpixel = _drawMonochrome ? SubpixelRenderingMode.None : FontManager.subpixelRenderingMode;
        flags |= (!_drawMonochrome ? (subpixel ? FT_LOAD_TARGET_LCD : (FontManager.instance.hintingMode == HintingMode.Light ? FT_LOAD_TARGET_LIGHT : FT_LOAD_TARGET_NORMAL)) : FT_LOAD_TARGET_MONO);
        if (withImage)
            flags |= FT_LOAD_RENDER;
        if (FontManager.instance.hintingMode == HintingMode.AutoHint || FontManager.instance.hintingMode == HintingMode.Light)
            flags |= FT_LOAD_FORCE_AUTOHINT;
        else if (FontManager.instance.hintingMode == HintingMode.Disabled)
            flags |= FT_LOAD_NO_AUTOHINT | FT_LOAD_NO_HINTING;
        int error = FT_Load_Glyph(
                                  _face,          /* handle to face object */
                                  glyph_index,   /* glyph index           */
                                  flags );  /* load flags, see below */
        if ( error )
            return false;
        glyph.lastUsage = 1;
        glyph.blackBoxX = cast(ushort)((_slot.metrics.width + 32) >> 6);
        glyph.blackBoxY = cast(ubyte)((_slot.metrics.height + 32) >> 6);
        glyph.originX =   cast(byte)((_slot.metrics.horiBearingX + 32) >> 6);
        glyph.originY =   cast(byte)((_slot.metrics.horiBearingY + 32) >> 6);
        glyph.widthScaled = cast(ushort)(myabs(cast(int)(_slot.metrics.horiAdvance)));
        glyph.widthPixels =     cast(ubyte)(myabs(cast(int)(_slot.metrics.horiAdvance + 32)) >> 6);
        glyph.subpixelMode = subpixel;
        //glyph.glyphIndex = cast(ushort)code;
        if (withImage) {
            FT_Bitmap*  bitmap = &_slot.bitmap;
            ushort w = cast(ushort)(bitmap.width);
            ubyte h = cast(ubyte)(bitmap.rows);
            glyph.blackBoxX = w;
            glyph.blackBoxY = h;
            glyph.originX =   cast(byte)(_slot.bitmap_left);
            glyph.originY =   cast(byte)(_slot.bitmap_top);
            int sz = w * cast(int)h;
            if (sz > 0) {
                glyph.glyph = new ubyte[sz];
                if (_drawMonochrome) {
                    // monochrome bitmap
                    ubyte mask = 0x80;
                    ubyte * ptr = bitmap.buffer;
                    ubyte * dst = glyph.glyph.ptr;
                    foreach(y; 0 .. h) {
                        ubyte * row = ptr;
                        mask = 0x80;
                        foreach(x; 0 .. w) {
                            *dst++ = (*row & mask) ? 0xFF : 00;
                            mask >>= 1;
                            if ( !mask && x != w-1) {
                                mask = 0x80;
                                row++;
                            }
                        }
                        ptr += bitmap.pitch;
                    }

                } else {
                    // antialiased
                    foreach(y; 0 .. h) {
                        foreach(x; 0 .. w) {
                            glyph.glyph[y * w + x] = _gamma256.correct(bitmap.buffer[y * bitmap.pitch + x]);
                        }
                    }
                }
            }
            static if (ENABLE_OPENGL) {
                glyph.id = nextGlyphId();
            }
        }
        return true;
    }

    @property bool isNull() {
        return (_face is null);
    }

    void clear() {
        if (_face !is null)
            FT_Done_Face(_face);
        _face = null;
    }

    int getKerningOffset(FT_UInt prevCharIndex, FT_UInt nextCharIndex) {
        const FT_KERNING_DEFAULT = 0;
        FT_Vector delta;
        int error = FT_Get_Kerning( _face,          /* handle to face object */
                               prevCharIndex,      /* left glyph index      */
                               nextCharIndex,       /* right glyph index     */
                               FT_KERNING_DEFAULT,  /* kerning mode          */
                               &delta);            /* target vector         */
        const RSHIFT = 0;
        if ( !error )
            return cast(int)((delta.x) >> RSHIFT);
        return 0;
    }
}

/**
* Font implementation based on FreeType.
*/
class FreeTypeFont : Font {
    private FontFileItem _fontItem;
    private Collection!(FreeTypeFontFile, true) _files;

    debug static __gshared int _instanceCount;
    debug @property static int instanceCount() { return _instanceCount; }

    /// need to call create() after construction to initialize font
    this(FontFileItem item, int size) {
        _fontItem = item;
        _size = size;
        _height = size;
        _allowKerning = true;
        debug ++_instanceCount;
        debug(resalloc) Log.d("Created font, count=", _instanceCount);
    }

    /// do cleanup
    ~this() {
        clear();
        debug --_instanceCount;
        debug(resalloc) Log.d("Destroyed font, count=", _instanceCount);
    }

    private int _size;
    private int _height;

    private GlyphCache _glyphCache;


    /// cleanup resources
    override void clear() {
        _files.clear();
    }

    uint getGlyphIndex(dchar code)
    {
        return 0;
    }

    /// find glyph index for character
    bool findGlyph(dchar code, dchar def_char, ref FT_UInt index, ref FreeTypeFontFile file) {
        foreach(FreeTypeFontFile f; _files) {
            index = f.getCharIndex(code, def_char);
            if (index != 0) {
                file = f;
                return true;
            }
        }
        return false;
    }

    /// override to allow kerning
    override @property bool allowKerning() {
        return _allowKerning;
    }

    /// override to implement kerning offset calculation
    override int getKerningOffset(dchar prevChar, dchar currentChar) {
        if (!_allowKerning || !prevChar || !currentChar)
            return 0;
        FT_UInt index1;
        FreeTypeFontFile file1;
        if (!findGlyph(prevChar, 0, index1, file1))
            return 0;
        FT_UInt index2;
        FreeTypeFontFile file2;
        if (!findGlyph(currentChar, 0, index2, file2))
            return 0;
        if (file1 !is file2)
            return 0;
        return file1.getKerningOffset(index1, index2);
    }

    override Glyph * getCharGlyph(dchar ch, bool withImage = true) {
        if (ch > 0xFFFF) // do not support unicode chars above 0xFFFF - due to cache limitations
            return null;
        //long measureStart = std.datetime.Clock.currStdTime;
        Glyph * found = _glyphCache.find(cast(ushort)ch);
        //long measureEnd = std.datetime.Clock.currStdTime;
        //long duration = measureEnd - measureStart;
        //if (duration > 10000)
        //if (duration > 10000)
        //    Log.d("ft _glyphCache.find took ", duration / 10, " ns");
        if (found !is null)
            return found;
        //Log.v("Glyph ", ch, " is not found in cache, getting from font");
        FT_UInt index;
        FreeTypeFontFile file;
        if (!findGlyph(ch, 0, index, file)) {
            if (!findGlyph(ch, '?', index, file))
                return null;
        }
        Glyph * glyph = new Glyph;
        if (!file.getGlyphInfo(ch, *glyph, 0, withImage))
            return null;
        if (withImage)
            return _glyphCache.put(ch, glyph);
        return glyph;
    }

    /// load font files
    bool create() {
        if (!isNull())
            clear();
        foreach (string filename; _fontItem.filenames) {
            FreeTypeFontFile file = new FreeTypeFontFile(_fontItem.library, filename);
            if (file.open(_size, 0)) {
                _files.add(file);
            } else {
                destroy(file);
            }
        }
        return _files.length > 0;
    }

    /// clear usage flags for all entries
    override void checkpoint() {
        _glyphCache.checkpoint();
    }

    /// removes entries not used after last call of checkpoint() or cleanup()
    override void cleanup() {
        _glyphCache.cleanup();
    }

    /// clears glyph cache
    override void clearGlyphCache() {
        _glyphCache.clear();
    }

    @property override int size() { return _size; }
    @property override int height() { return _files.length > 0 ? _files[0].height : _size; }
    @property override int weight() { return _fontItem.def.weight; }
    @property override int baseline() { return _files.length > 0 ? _files[0].baseline : 0; }
    @property override bool italic() { return _fontItem.def.italic; }
    @property override string face() { return _fontItem.def.face; }
    @property override FontFamily family() { return _fontItem.def.family; }
    @property override bool isNull() { return _files.length == 0; }
}

private derelict.util.exception.ShouldThrow missingSymFunc( string symName ) {
    import std.algorithm : equal;
    static import derelict.util.exception;
    foreach(s; ["FT_New_Face", "FT_Attach_File", "FT_Set_Pixel_Sizes",
            "FT_Get_Char_Index", "FT_Load_Glyph", "FT_Done_Face",
            "FT_Init_FreeType", "FT_Done_FreeType", "FT_Get_Kerning"]) {
        if (symName.equal(s)) // Symbol is used
            return derelict.util.exception.ShouldThrow.Yes;
    }
    // Don't throw for unused symbol
    return derelict.util.exception.ShouldThrow.No;
}

/// FreeType based font manager.
class FreeTypeFontManager : FontManager {

    private FT_Library    _library;
    private FontFileItem[] _fontFiles;

    private FontFileItem findFileItem(ref FontDef def) {
        foreach(FontFileItem item; _fontFiles)
            if (item.def == def)
                return item;
        return null;
    }

    /// override to return list of font faces available
    override FontFaceProps[] getFaces() {
        FontFaceProps[] res;
        for (int i = 0; i < _fontFiles.length; i++) {
            FontFaceProps item = FontFaceProps(_fontFiles[i].def.face, _fontFiles[i].def.family);
            bool found = false;
            for (int j = 0; j < res.length; j++) {
                if (res[j].face == item.face) {
                    found = true;
                    break;
                }
            }
            if (!found)
                res ~= item;
        }
        return res;
    }


    private static int faceMatch(string requested, string existing) {
        if (!requested.icmp("Arial")) {
            if (!existing.icmp("DejaVu Sans")) {
                return 200;
            }
        }
        if (!requested.icmp("Times New Roman")) {
            if (!existing.icmp("DejaVu Serif")) {
                return 200;
            }
        }
        if (!requested.icmp("Courier New")) {
            if (!existing.icmp("DejaVu Sans Mono")) {
                return 200;
            }
        }
        return stdFontFacePriority(existing) * 10;
    }

    private FontFileItem findBestMatch(int weight, bool italic, FontFamily family, string face) {
        FontFileItem best = null;
        int bestScore = 0;
        string[] faces = face ? split(face, ",") : null;
        foreach(size_t index, FontFileItem item; _fontFiles) {
            int score = 0;
            int bestFaceMatch = 0;
            if (faces && face.length) {
                foreach(i; 0 .. faces.length) {
                    string f = faces[i].strip;
                    if (f.icmp(item.def.face) == 0) {
                        score += 3000 - i;
                        break;
                    }
                    int match = faceMatch(f, item.def.face);
                    if (match > bestFaceMatch)
                        bestFaceMatch = match;
                }
            }
            score += bestFaceMatch;
            if (family == item.def.family)
                score += 1000; // family match
            if (italic == item.def.italic)
                score += 50; // italic match
            int weightDiff = myabs(weight - item.def.weight);
            score += 30 - weightDiff / 30; // weight match
            if (score > bestScore) {
                bestScore = score;
                best = item;
            }
        }
        return best;
    }

    //private FontList _activeFonts;

    private static __gshared FontRef _nullFontRef;

    this() {
        // load dynaic library
        try {
            Log.v("DerelictFT: Loading FreeType library");
            if (!DerelictFT) {
                Log.w("DerelictFT is null. Compiler bug? Applying workaround to fix it.");
                version(Android) {
                    //DerelictFT = new DerelictFTLoader("libft2.so");
                    DerelictFT = new DerelictFTLoader;
                } else {
                    DerelictFT = new DerelictFTLoader;
                }
            }
            DerelictFT.missingSymbolCallback = &missingSymFunc;
            Log.v("DerelictFT: Missing symbols callback is registered");
            DerelictFT.load();
            Log.v("DerelictFT: Loaded");
        } catch (Exception e) {
            Log.e("Derelict: cannot load freetype shared library: ", e.msg);
            throw new Exception("Cannot load freetype library");
        }
        Log.v("Initializing FreeType library");
        // init library
        int error = FT_Init_FreeType(&_library);
        if (error) {
            Log.e("Cannot init freetype library, error=", error);
            throw new Exception("Cannot init freetype library");
        }
        //FT_Library_SetLcdFilter(_library, FT_LCD_FILTER_DEFAULT);
    }
    ~this() {
        debug(FontResources) Log.d("FreeTypeFontManager ~this()");
        //_activeFonts.clear();
        foreach(ref FontFileItem item; _fontFiles) {
            destroy(item);
            item = null;
        }
        _fontFiles.length = 0;
        debug(FontResources) Log.d("Destroyed all fonts. Freeing library.");
        // uninit library
        if (_library)
            FT_Done_FreeType(_library);
    }

    /// get font instance with specified parameters
    override ref FontRef getFont(int size, int weight, bool italic, FontFamily family, string face) {
        FontFileItem f = findBestMatch(weight, italic, family, face);
        if (f is null)
            return _nullFontRef;
        //Log.d("getFont requesteed: ", face, " found: ", f.def.face);
        return f.get(size);
    }

    /// clear usage flags for all entries
    override void checkpoint() {
        foreach(ref ff; _fontFiles) {
            ff.checkpoint();
        }
    }

    /// removes entries not used after last call of checkpoint() or cleanup()
    override void cleanup() {
        foreach(ref ff; _fontFiles) {
            ff.cleanup();
        }
    }

    /// clears glyph cache
    override void clearGlyphCaches() {
        foreach(ref ff; _fontFiles) {
            ff.clearGlyphCaches();
        }
    }

	bool registerFont(string filename, bool skipUnknown = false) {
		import std.path : baseName;
		FontFamily family = FontFamily.SansSerif;
		string face = null;
		bool italic = false;
		int weight = 0;
		string name = filename.baseName;
		switch(name) {
			case "DroidSans.ttf": face="Droid Sans"; weight = FontWeight.Normal; break;
			case "DroidSans-Bold.ttf": face="Droid Sans"; weight = FontWeight.Bold; break;
			case "DroidSansMono.ttf": face="Droid Sans Mono"; weight = FontWeight.Normal; family = FontFamily.MonoSpace; break;
			case "Roboto-Light.ttf": face="Roboto"; weight = FontWeight.Normal; break;
			case "Roboto-LightItalic.ttf": face="Roboto"; weight = FontWeight.Normal; italic = true; break;
			case "Roboto-Bold.ttf": face="Roboto"; weight = FontWeight.Bold; break;
			case "Roboto-BoldItalic.ttf": face="Roboto"; weight = FontWeight.Bold; italic = true; break;
			default:
				if (skipUnknown)
					return false;
		}
		return registerFont(filename, FontFamily.SansSerif, face, italic, weight);
	}

    /// register freetype font by filename - optinally font properties can be passed if known (e.g. from libfontconfig).
    bool registerFont(string filename, FontFamily family, string face = null, bool italic = false, int weight = 0, bool dontLoadFile = false) {
        if (_library is null)
            return false;
        //Log.v("FreeTypeFontManager.registerFont ", filename, " ", family, " ", face, " italic=", italic, " weight=", weight);
        if (!exists(filename) || !isFile(filename)) {
            Log.d("Font file ", filename, " not found");
            return false;
        }

        if (!dontLoadFile) {
            FreeTypeFontFile font = new FreeTypeFontFile(_library, filename);
            if (!font.open(24)) {
                Log.e("Failed to open font ", filename);
                destroy(font);
                return false;
            }

            if (face == null || weight == 0) {
                // properties are not set by caller
                // get properties from loaded font
                face = font.face;
                italic = font.italic;
                weight = font.weight;
                debug(FontResources)Log.d("Using properties from font file: face=", face, " weight=", weight, " italic=", italic);
            }
            destroy(font);
        }

        FontDef def = FontDef(family, face, italic, weight);
        FontFileItem item = findFileItem(def);
        if (item is null) {
            item = new FontFileItem(_library, def);
            _fontFiles ~= item;
        }
        item.addFile(filename);

        // registered
        return true;
    }

    /// returns number of registered fonts
    @property int registeredFontCount() {
        return cast(int)_fontFiles.length;
    }

}

private int myabs(int n) { return n >= 0 ? n : -n; }


version(Windows) {
} else {

bool registerFontConfigFonts(FreeTypeFontManager fontMan) {
    import fontconfig;

    try {
        DerelictFC.load();
    } catch (Exception e) {
        Log.w("Cannot load FontConfig shared library");
        return false;
    }

    Log.i("Getting list of fonts using FontConfig");
    long startts = currentTimeMillis();

    FcFontSet *fontset;

    FcObjectSet *os = FcObjectSetBuild(FC_FILE.toStringz, FC_WEIGHT.toStringz, FC_FAMILY.toStringz,
                                        FC_SLANT.toStringz, FC_SPACING.toStringz, FC_INDEX.toStringz,
                                        FC_STYLE.toStringz, null);
    FcPattern *pat = FcPatternCreate();
    //FcBool b = 1;
    FcPatternAddBool(pat, FC_SCALABLE.toStringz, 1);

    fontset = FcFontList(null, pat, os);

    FcPatternDestroy(pat);
    FcObjectSetDestroy(os);

    int facesFound = 0;

    // load fonts from file
    //CRLog::debug("FONTCONFIG: %d font files found", fontset->nfont);
    foreach(i; 0 .. fontset.nfont) {
        const (FcChar8) *s = "".toStringz;
        const (FcChar8) *family = "".toStringz;
        const (FcChar8) *style = "".toStringz;
        //FcBool b;
        FcResult res;
        //FC_SCALABLE
        //res = FcPatternGetBool( fontset->fonts[i], FC_OUTLINE, 0, (FcBool*)&b);
        //if(res != FcResultMatch)
        //    continue;
        //if ( !b )
        //    continue; // skip non-scalable fonts
        res = FcPatternGetString(fontset.fonts[i], FC_FILE.toStringz, 0, cast(FcChar8 **)&s);
        if (res != FcResultMatch) {
            continue;
        }
        string fn = fromStringz(s).dup;
        string fn16 = toLower(fn);
        if (!fn16.endsWith(".ttf") && !fn16.endsWith(".odf") && !fn16.endsWith(".otf") &&
            !fn16.endsWith(".ttc") && !fn16.endsWith(".pfb") && !fn16.endsWith(".pfa")  )
        {
            continue;
        }
        int weight = FC_WEIGHT_MEDIUM;
        res = FcPatternGetInteger(fontset.fonts[i], FC_WEIGHT.toStringz, 0, &weight);
        if(res != FcResultMatch) {
            //CRLog::debug("no FC_WEIGHT for %s", s);
            //continue;
        }
        switch ( weight ) {
        case FC_WEIGHT_THIN:          //    0
            weight = 100;
            break;
        case FC_WEIGHT_EXTRALIGHT:    //    40
        //case FC_WEIGHT_ULTRALIGHT        FC_WEIGHT_EXTRALIGHT
            weight = 200;
            break;
        case FC_WEIGHT_LIGHT:         //    50
        case FC_WEIGHT_BOOK:          //    75
        case FC_WEIGHT_REGULAR:       //    80
        //case FC_WEIGHT_NORMAL:            FC_WEIGHT_REGULAR
            weight = 400;
            break;
        case FC_WEIGHT_MEDIUM:        //    100
            weight = 500;
            break;
        case FC_WEIGHT_DEMIBOLD:      //    180
        //case FC_WEIGHT_SEMIBOLD:          FC_WEIGHT_DEMIBOLD
            weight = 600;
            break;
        case FC_WEIGHT_BOLD:          //    200
            weight = 700;
            break;
        case FC_WEIGHT_EXTRABOLD:     //    205
        //case FC_WEIGHT_ULTRABOLD:         FC_WEIGHT_EXTRABOLD
            weight = 800;
            break;
        case FC_WEIGHT_BLACK:         //    210
        //case FC_WEIGHT_HEAVY:             FC_WEIGHT_BLACK
            weight = 900;
            break;
        case FC_WEIGHT_EXTRABLACK:    //    215
        //case FC_WEIGHT_ULTRABLACK:        FC_WEIGHT_EXTRABLACK
            weight = 900;
            break;
        default:
            weight = 400;
            break;
        }
        FcBool scalable = 0;
        res = FcPatternGetBool(fontset.fonts[i], FC_SCALABLE.toStringz, 0, &scalable);
        int index = 0;
        res = FcPatternGetInteger(fontset.fonts[i], FC_INDEX.toStringz, 0, &index);
        if(res != FcResultMatch) {
            //CRLog::debug("no FC_INDEX for %s", s);
            //continue;
        }
        res = FcPatternGetString(fontset.fonts[i], FC_FAMILY.toStringz, 0, cast(FcChar8 **)&family);
        if(res != FcResultMatch) {
            //CRLog::debug("no FC_FAMILY for %s", s);
            continue;
        }
        res = FcPatternGetString(fontset.fonts[i], FC_STYLE.toStringz, 0, cast(FcChar8 **)&style);
        if(res != FcResultMatch) {
            //CRLog::debug("no FC_STYLE for %s", s);
            style = "".toStringz;
            //continue;
        }
        int slant = FC_SLANT_ROMAN;
        res = FcPatternGetInteger(fontset.fonts[i], FC_SLANT.toStringz, 0, &slant);
        if(res != FcResultMatch) {
            //CRLog::debug("no FC_SLANT for %s", s);
            //continue;
        }
        int spacing = 0;
        res = FcPatternGetInteger(fontset.fonts[i], FC_SPACING.toStringz, 0, &spacing);
        if(res != FcResultMatch) {
            //CRLog::debug("no FC_SPACING for %s", s);
            //continue;
        }
//                int cr_weight;
//                switch(weight) {
//                    case FC_WEIGHT_LIGHT: cr_weight = 200; break;
//                    case FC_WEIGHT_MEDIUM: cr_weight = 300; break;
//                    case FC_WEIGHT_DEMIBOLD: cr_weight = 500; break;
//                    case FC_WEIGHT_BOLD: cr_weight = 700; break;
//                    case FC_WEIGHT_BLACK: cr_weight = 800; break;
//                    default: cr_weight=300; break;
//                }
        FontFamily fontFamily = FontFamily.SansSerif;
        string face16 = family.fromStringz.toLower.dup;
        if (spacing == FC_MONO)
            fontFamily = FontFamily.MonoSpace;
        else if (face16.indexOf("sans") >= 0)
            fontFamily = FontFamily.SansSerif;
        else if (face16.indexOf("serif") >= 0)
            fontFamily = FontFamily.Serif;

        //css_ff_inherit,
        //css_ff_serif,
        //css_ff_sans_serif,
        //css_ff_cursive,
        //css_ff_fantasy,
        //css_ff_monospace,
        bool italic = (slant!=FC_SLANT_ROMAN);

        string face = family.fromStringz.dup;
        string style16 = style.fromStringz.toLower.dup;
        if (style16.indexOf("condensed") >= 0)
            face ~= " Condensed";
        else if (style16.indexOf("extralight") >= 0)
            face ~= " Extra Light";

        if (fontMan.registerFont(fn, fontFamily, face, italic, weight, true))
            facesFound++;
/*
        LVFontDef def(
            lString8((const char*)s),
            -1, // height==-1 for scalable fonts
            weight,
            italic,
            fontFamily,
            face,
            index
        );

        CRLog::debug("FONTCONFIG: Font family:%s style:%s weight:%d slant:%d spacing:%d file:%s", family, style, weight, slant, spacing, s);
        if ( _cache.findDuplicate( &def ) ) {
            CRLog::debug("is duplicate, skipping");
            continue;
        }
        _cache.update( &def, LVFontRef(NULL) );

        if ( scalable && !def.getItalic() ) {
            LVFontDef newDef( def );
            newDef.setItalic(2); // can italicize
            if ( !_cache.findDuplicate( &newDef ) )
                _cache.update( &newDef, LVFontRef(NULL) );
        }

        */
    }

    FcFontSetDestroy(fontset);


    long elapsed = currentTimeMillis - startts;
    Log.i("FontConfig: ", facesFound, " font files registered in ", elapsed, "ms");
    //CRLog::info("FONTCONFIG: %d fonts registered", facesFound);

    /+
    string[] fallback_faces = [
        "Arial Unicode MS",
        "AR PL ShanHeiSun Uni",
        "Liberation Sans"
        // TODO: more faces
    ];

    for ( int i=0; fallback_faces[i]; i++ )
        if ( SetFallbackFontFace(lString8(fallback_faces[i])) ) {
            //CRLog::info("Fallback font %s is found", fallback_faces[i]);
            break;
        } else {
            //CRLog::trace("Fallback font %s is not found", fallback_faces[i]);
        }
    +/

    return facesFound > 0;
}
}
