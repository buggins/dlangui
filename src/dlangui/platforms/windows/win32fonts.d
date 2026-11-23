// Written in the D programming language.

/**

This module contains implementation of Win32 fonts support

Part of Win32 platform support.

Usually you don't need to use this module directly.


Synopsis:

----
import dlangui.platforms.windows.win32fonts;
----

Copyright: Vadim Lopatin, 2014
License:   Boost License 1.0
Authors:   Vadim Lopatin, coolreader.org@gmail.com
*/
module dlangui.platforms.windows.win32fonts;

version(Windows):
public import dlangui.core.config;
static if (BACKEND_GUI):

import core.sys.windows.windows;
import dlangui.graphics.fonts;
import dlangui.platforms.windows.win32drawbuf;
import std.string;
import std.utf;
import std.windows.charset;

/// define debug=FontResources for logging of font file resources creation/freeing
//debug = FontResources;

//auto toUTF16z(S)(S s)
//{
    //return toUTFz!(const(wchar)*)(s);
//}

private struct FontDef {
    immutable FontFamily _family;
    immutable string _face;
    immutable ubyte _pitchAndFamily;
    @property FontFamily family() { return _family; }
    @property string face() { return _face; }
    @property ubyte pitchAndFamily() { return _pitchAndFamily; }
    this(FontFamily family, string face, ubyte pitchAndFamily) {
        _family = family;
        _face = face;
        _pitchAndFamily = pitchAndFamily;
    }
}

// support of subpixel rendering
// from AntigrainGeometry https://rsdn.ru/forum/src/830679.1
import std.math;
// Sub-pixel energy distribution lookup table.
// See description by Steve Gibson: http://grc.com/cttech.htm
// The class automatically normalizes the coefficients
// in such a way that primary + 2*secondary + 3*tertiary = 1.0
// Also, the input values are in range of 0...NumLevels, output ones
// are 0...255
//---------------------------------
struct lcd_distribution_lut(int maxv = 65)
{
    this(double prim, double second, double tert)
    {
        double norm = (255.0 / (maxv - 1)) / (prim + second*2 + tert*2);
        prim   *= norm;
        second *= norm;
        tert   *= norm;
        for(int i = 0; i < maxv; i++)
        {
            m_primary[i]   = cast(ubyte)floor(prim   * i);
            m_secondary[i] = cast(ubyte)floor(second * i);
            m_tertiary[i]  = cast(ubyte)floor(tert   * i);
        }
    }

    uint primary(int v)   const {
        if (v >= maxv) {
            Log.e("pixel value returned from font engine > 64: ", v);
            v = maxv - 1;
        }
        return m_primary[v];
    }
    uint secondary(int v) const {
        if (v >= maxv) {
            Log.e("pixel value returned from font engine > 64: ", v);
            v = maxv - 1;
        }
        return m_secondary[v];
    }
    uint tertiary(int v)  const {
        if (v >= maxv) {
            Log.e("pixel value returned from font engine > 64: ", v);
            v = maxv - 1;
        }
        return m_tertiary[v];
    }

private:
    ubyte[maxv] m_primary;
    ubyte[maxv] m_secondary;
    ubyte[maxv] m_tertiary;
}

private __gshared lcd_distribution_lut!65 lut;
void initWin32FontsTables() {
    lut = lcd_distribution_lut!65(0.5, 0.25, 0.125);
}



private int myabs(int n) {
    return n < 0 ? -n : n;
}
private int colorStat(ubyte * p) {
    int avg = (cast(int)p[0] + cast(int)p[1] + cast(int)p[2]) / 3;
    return myabs(avg - cast(int)p[0]) + myabs(avg - cast(int)p[1]) + myabs(avg - cast(int)p[2]);
}

private int minIndex(int n0, int n1, int n2) {
    if (n0 <= n1 && n0 <= n2)
        return 0;
    if (n1 <= n0 && n1 <= n2)
        return 1;
    return n2;
}

// This function prepares the alpha-channel information
// for the glyph averaging the values in accordance with
// the method suggested by Steve Gibson. The function
// extends the width by 4 extra pixels, 2 at the beginning
// and 2 at the end. Also, it doesn't align the new width
// to 4 bytes, that is, the output gm.gmBlackBoxX is the
// actual width of the array.
// returns dst glyph width
// leftPad: empty subpixel columns added at the left, so that the bitmap starts at a pixel boundary (#861);
// the source rows are aligned to 4 bytes, the output rows are not padded
//---------------------------------
ushort prepare_lcd_glyph(ubyte * gbuf1,
                       ref GLYPHMETRICS gm,
                       ref ubyte[] gbuf2,
                       int leftPad)
{
    uint src_stride = (gm.gmBlackBoxX + 3) / 4 * 4;
    uint dst_width  = leftPad + gm.gmBlackBoxX + 4;
    gbuf2 = new ubyte[dst_width * gm.gmBlackBoxY];

    for(uint y = 0; y < gm.gmBlackBoxY; ++y)
    {
        ubyte * src_ptr = gbuf1 + src_stride * y;
        ubyte * dst_ptr = gbuf2.ptr + dst_width * y + leftPad;
        for(uint x = 0; x < gm.gmBlackBoxX; ++x)
        {
            uint v = *src_ptr++;
            dst_ptr[0] += lut.tertiary(v);
            dst_ptr[1] += lut.secondary(v);
            dst_ptr[2] += lut.primary(v);
            dst_ptr[3] += lut.secondary(v);
            dst_ptr[4] += lut.tertiary(v);
            ++dst_ptr;
        }
    }
    /*
    int dx = (dst_width - 2) / 3;
    int stats[3] = [0, 0, 0];
    for (uint y = 0; y < gm.gmBlackBoxY; y++) {
        for(uint x = 0; x < dx; ++x)
        {
            for (uint x0 = 0; x0 < 3; x0++) {
                stats[x0] += colorStat(gbuf2.ptr + dst_width * y + x0);
            }
        }
    }
    shiftedBy = 0; //minIndex(stats[0], stats[1], stats[2]);
    if (shiftedBy) {
        for (uint y = 0; y < gm.gmBlackBoxY; y++) {
            ubyte * dst_ptr = gbuf2.ptr + dst_width * y;
            for(uint x = 0; x < gm.gmBlackBoxX; ++x)
            {
                if (x + shiftedBy < gm.gmBlackBoxX)
                    dst_ptr[x] = dst_ptr[x + shiftedBy];
                else
                    dst_ptr[x] = 0;
            }
        }
    }
    */
    // apply FontManager.fontGamma to the filtered subpixel coverage, as for FreeType LCD glyphs (#833)
    foreach(ref v; gbuf2)
        v = _gamma256.correct(v);
    return cast(ushort) dst_width;
}

/**
* Font implementation based on Win32 API system fonts.
*/
class Win32Font : Font {
    protected HFONT _hfont;
    protected int _dpi;
    protected int _size;
    protected int _height;
    protected int _weight;
    protected int _baseline;
    protected bool _italic;
    protected string _face;
    protected FontFamily _family;
    protected LOGFONTA _logfont;
    protected Win32ColorDrawBuf _drawbuf;
    protected GlyphCache _glyphCache;
    /// kerning pairs of the font (#864): (first << 16) | second (UTF-16 code units) -> offset in pixels
    protected int[uint] _kerningPairs;

    /// need to call create() after construction to initialize font
    this() {
    }

    /// do cleanup
    ~this() {
        if (inGCFinalizer()) return; // finalized by the GC: a leak, touch nothing (#975)
        clear();
    }

    /// cleanup resources
    override void clear() {
        if (_hfont !is null)
        {
            DeleteObject(_hfont);
            _hfont = NULL;
            _height = 0;
            _baseline = 0;
            _size = 0;
        }
        _kerningPairs = null;
        if (_drawbuf !is null) {
            destroy(_drawbuf);
            _drawbuf = null;
        }
    }

    uint getGlyphIndex(dchar code)
    {
        if (_drawbuf is null)
            return 0;
        wchar[2] s;
        wchar[2] g;
        s[0] = cast(wchar)code;
        s[1] = 0;
        g[0] = 0;
        GCP_RESULTSW gcp;
        gcp.lStructSize = GCP_RESULTSW.sizeof;
        gcp.lpOutString = null;
        gcp.lpOrder = null;
        gcp.lpDx = null;
        gcp.lpCaretPos = null;
        gcp.lpClass = null;
        gcp.lpGlyphs = g.ptr;
        gcp.nGlyphs = 2;
        gcp.nMaxFit = 2;

        DWORD res = GetCharacterPlacementW(
                                           _drawbuf.dc, s.ptr, 1,
                                           1000,
                                           &gcp,
                                           0
                                           );
        if (!res)
            return 0;
        return g[0];
    }

    /// check presence of codepoint in the font with GetGlyphIndicesW (#886); no font linking
    override protected CodepointPresence loadCodepointPresence(dchar ch) {
        if (ch > 0xFFFF)
            return CodepointPresence.missing; // GDI glyph lookup takes UTF-16 code units: no glyphs above U+FFFF (#779)
        if (_drawbuf is null)
            return CodepointPresence.unknown;
        wchar code = cast(wchar)ch;
        WORD index;
        if (GetGlyphIndicesW(_drawbuf.dc, &code, 1, &index, GGI_MARK_NONEXISTING_GLYPHS) == GDI_ERROR)
            return CodepointPresence.unknown;
        return index == 0xFFFF ? CodepointPresence.missing : CodepointPresence.present;
    }

    /// glyph of this font, without fallback fonts (#888): for characters the font has no glyph for, a replacement
    /// character or the missing glyph
    override protected Glyph * getOwnCharGlyph(dchar ch, bool withImage) {
        Glyph * found = _glyphCache.find(ch);
        if (found !is null)
            return found;
        // characters in the font's character map are drawn (#899): getGlyphIndex() (GetCharacterPlacementW) shapes
        // the character and returns no glyph for a lone combining mark, e.g. Devanagari and Bengali vowel signs;
        // it is still used for characters not in the font: it gives glyphs of GDI font linking
        uint glyphIndex = hasCodepoint(ch) ? 1 : getGlyphIndex(ch);
        if (!glyphIndex) {
            ch = getReplacementChar(ch);
            if (!ch)
                return null;
            glyphIndex = getGlyphIndex(ch);
            if (!glyphIndex) {
                ch = getReplacementChar(ch);
                if (!ch)
                    return null;
                glyphIndex = getGlyphIndex(ch);
            }
        }
        if (!glyphIndex)
            return null;
        if (glyphIndex >= 0xFFFF)
            return null;
        GLYPHMETRICS metrics;

        bool needSubpixelRendering = FontManager.subpixelRenderingMode && antialiased;
        int subpixelLeftPad = 0; // empty subpixel columns before the bitmap: its subpixel phase (#861)
        MAT2 scaleMatrix = { {0,1}, {0,0}, {0,0}, {0,1} };

        uint res;
        res = GetGlyphOutlineW( _drawbuf.dc, cast(wchar)ch,
                                GGO_METRICS,
                               &metrics,
                               0,
                               null,
                               &scaleMatrix );
        if (res == GDI_ERROR)
            return null;

        Glyph * g = new Glyph;
        static if (ENABLE_OPENGL) {
            g.id = nextGlyphId();
        }
        //g.blackBoxX = cast(ushort)metrics.gmBlackBoxX;
        //g.blackBoxY = cast(ubyte)metrics.gmBlackBoxY;
        //g.originX = cast(byte)metrics.gmptGlyphOrigin.x;
        //g.originY = cast(byte)metrics.gmptGlyphOrigin.y;
        //g.width = cast(ubyte)metrics.gmCellIncX;
        g.subpixelMode = SubpixelRenderingMode.None;

        if (needSubpixelRendering) {
            scaleMatrix.eM11.value = 3; // request glyph 3 times wider for subpixel antialiasing
        }

        int gs = 0;
        // calculate bitmap size
        if (antialiased) {
            gs = GetGlyphOutlineW( _drawbuf.dc, cast(wchar)ch,
                                       GGO_GRAY8_BITMAP,
                                      &metrics,
                                      0,
                                      NULL,
                                      &scaleMatrix );
        } else {
            gs = GetGlyphOutlineW( _drawbuf.dc, cast(wchar)ch,
                                   GGO_BITMAP,
                                  &metrics,
                                  0,
                                  NULL,
                                  &scaleMatrix );
        }

        if (gs >= 0x10000 || gs < 0)
            return null;

        if (needSubpixelRendering) {
            //Log.d("ch=", ch);
            //Log.d("NORMAL:  blackBoxX=", g.blackBoxX, " \tblackBoxY=", g.blackBoxY, " \torigin.x=", g.originX, " \torigin.y=", g.originY, "\tgmCellIncX=", g.width);
            g.blackBoxX = cast(ushort)metrics.gmBlackBoxX;
            g.blackBoxY = cast(ubyte)metrics.gmBlackBoxY;
            // the bitmap from prepare_lcd_glyph starts 2 subpixels before the glyph (its filter spreads each
            // subpixel over 2 neighbours on each side): its first column is at gmptGlyphOrigin.x - 2 subpixels.
            // Glyph bitmaps are drawn from a pixel boundary, so the subpixel phase is added as empty columns
            // at the left of the bitmap; truncating the origin to pixels misplaced glyphs by up to 2/3 pixel
            // (gaps between letters, #861)
            int startSubpixel = metrics.gmptGlyphOrigin.x - 2;
            int originPixel = startSubpixel >= 0 ? startSubpixel / 3 : -((-startSubpixel + 2) / 3); // floor
            subpixelLeftPad = startSubpixel - originPixel * 3;
            g.originX = cast(byte)originPixel;
            g.originY = cast(byte)metrics.gmptGlyphOrigin.y;
            // the advance of the 3 times wider glyph divided by 3: kept in 1/64 pixel, rounded only to whole
            // pixels for widthPixels (rounding it up for each glyph made gaps between letters, #861)
            g.widthScaled = cast(ushort)((metrics.gmCellIncX * 64 + 1) / 3);
            g.widthPixels = cast(ubyte)((metrics.gmCellIncX + 1) / 3);
            g.subpixelMode = FontManager.subpixelRenderingMode;
            //Log.d(" *3   :  blackBoxX=", metrics.gmBlackBoxX, " \tblackBoxY=", metrics.gmBlackBoxY, " \torigin.x=", metrics.gmptGlyphOrigin.x, " \torigin.y=", metrics.gmptGlyphOrigin.y, " \tgmCellIncX=", metrics.gmCellIncX);
            //Log.d("  /3  :  blackBoxX=", g.blackBoxX, " \tblackBoxY=", g.blackBoxY, " \torigin.x=", g.originX, " \torigin.y=", g.originY, "\tgmCellIncX=", g.width);
        } else {
            g.blackBoxX = cast(ushort)metrics.gmBlackBoxX;
            g.blackBoxY = cast(ubyte)metrics.gmBlackBoxY;
            g.originX = cast(byte)metrics.gmptGlyphOrigin.x;
            g.originY = cast(byte)metrics.gmptGlyphOrigin.y;
            g.widthPixels = cast(ubyte)metrics.gmCellIncX;
            g.widthScaled = g.widthPixels << 6;
        }

        if (g.blackBoxX > 0 && g.blackBoxY > 0)    {
            g.glyph = new ubyte[g.blackBoxX * g.blackBoxY];
            if (gs>0)
            {
                if (antialiased) {
                    // antialiased glyph
                    ubyte[] glyph = new ubyte[gs];
                    res = GetGlyphOutlineW( _drawbuf.dc, cast(wchar)ch,
                                            GGO_GRAY8_BITMAP, //GGO_METRICS
                                           &metrics,
                                           gs,
                                           glyph.ptr,
                                           &scaleMatrix);
                    if (res==GDI_ERROR)
                    {
                        return null;
                    }
                    if (needSubpixelRendering) {
                        ubyte[] newglyph;
                        g.blackBoxX = prepare_lcd_glyph(glyph.ptr,
                                                 metrics,
                                                 newglyph,
                                                 subpixelLeftPad);
                        g.glyph = newglyph;
                    } else {
                        int glyph_row_size = (g.blackBoxX + 3) / 4 * 4;
                        ubyte * src = glyph.ptr;
                        ubyte * dst = g.glyph.ptr;
                        for (int y = 0; y < g.blackBoxY; y++)
                        {
                            for (int x = 0; x < g.blackBoxX; x++)
                            {
                                dst[x] = _gamma65.correct(src[x]);
                            }
                            src += glyph_row_size;
                            dst += g.blackBoxX;
                        }
                    }
                } else {
                    // bitmap glyph
                    ubyte[] glyph = new ubyte[gs];
                    res = GetGlyphOutlineW( _drawbuf.dc, cast(wchar)ch,
                                            GGO_BITMAP, //GGO_METRICS
                                           &metrics,
                                           gs,
                                           glyph.ptr,
                                           &scaleMatrix );
                    if (res==GDI_ERROR)
                    {
                        return null;
                    }
                    int glyph_row_bytes = ((g.blackBoxX + 7) / 8);
                    int glyph_row_size = (glyph_row_bytes + 3) / 4 * 4;
                    ubyte * src = glyph.ptr;
                    ubyte * dst = g.glyph.ptr;
                    for (int y = 0; y < g.blackBoxY; y++)
                    {
                        for (int x = 0; x < g.blackBoxX; x++)
                        {
                            int offset = x >> 3;
                            int shift = 7 - (x & 7);
                            ubyte b = ((src[offset] >> shift) & 1) ? 255 : 0;
                            dst[x] = b;
                        }
                        src += glyph_row_size;
                        dst += g.blackBoxX;
                    }
                }
            }
            else
            {
                // empty glyph
                for (int i = g.blackBoxX * g.blackBoxY - 1; i >= 0; i--)
                    g.glyph[i] = 0;
            }
        }
        // found!
        return _glyphCache.put(ch, g);
    }

    /// init from font definition
    bool create(FontDef * def, int size, int weight, bool italic) {
        if (!isNull())
            clear();
        LOGFONTA lf;
        // OEM charset face name
        lf.lfCharSet = DEFAULT_CHARSET; //ANSI_CHARSET;
        // lf.lfFaceName[0..def.face.length] = def.face;
        // lf.lfFaceName[def.face.length] = 0;
        string oemFace = fromStringz(toMBSz(def.face)).dup;
        if (oemFace.length > LF_FACESIZE - 1)
            oemFace = oemFace[0 .. LF_FACESIZE - 1]; // registerFontData() skips such names (#652)
        lf.lfFaceName[0..oemFace.length] = oemFace;
        lf.lfFaceName[oemFace.length] = 0;
        lf.lfHeight = -size; //pixelsToPoints(size);
        lf.lfItalic = italic;
        lf.lfWeight = weight;
        lf.lfOutPrecision = OUT_TT_ONLY_PRECIS; //OUT_OUTLINE_PRECIS; //OUT_TT_ONLY_PRECIS;
        lf.lfClipPrecision = CLIP_DEFAULT_PRECIS;
        //lf.lfQuality = NONANTIALIASED_QUALITY; //ANTIALIASED_QUALITY;
        //lf.lfQuality = PROOF_QUALITY; //ANTIALIASED_QUALITY;
        lf.lfQuality = antialiased ? NONANTIALIASED_QUALITY : ANTIALIASED_QUALITY; //PROOF_QUALITY; //ANTIALIASED_QUALITY; //size < 18 ? NONANTIALIASED_QUALITY : PROOF_QUALITY; //ANTIALIASED_QUALITY;
        lf.lfPitchAndFamily = def.pitchAndFamily;
        _hfont = CreateFontIndirectA(&lf);
        _drawbuf = new Win32ColorDrawBuf(1, 1);
        SelectObject(_drawbuf.dc, _hfont);

        TEXTMETRICW tm;
        GetTextMetricsW(_drawbuf.dc, &tm);

        _size = size;
        _height = tm.tmHeight;
        debug(FontResources) Log.d("Win32Font.create: height=", _height, " for size=", _size, "  points=", lf.lfHeight, " dpi=", _dpi);
        _baseline = _height - tm.tmDescent;
        _weight = weight;
        _italic = italic;
        _face = def.face;
        _family = def.family;
        loadKerningPairs();
        debug(FontResources) Log.d("Created font ", _face, " ", _size);
        return true;
    }

    /// read the kerning pairs of the font (its kern table), in pixels for its size (#864)
    protected void loadKerningPairs() {
        _kerningPairs = null;
        _allowKerning = true;
        DWORD count = GetKerningPairsW(_drawbuf.dc, 0, null);
        if (count == 0 || count > 1_000_000)
            return;
        KERNINGPAIR[] pairs = new KERNINGPAIR[count];
        count = GetKerningPairsW(_drawbuf.dc, count, pairs.ptr);
        foreach (ref p; pairs[0 .. count])
            if (p.iKernAmount)
                _kerningPairs[(cast(uint)p.wFirst << 16) | p.wSecond] = p.iKernAmount;
        debug(FontResources) Log.d("Font ", _face, " ", _size, ": ", _kerningPairs.length, " kerning pairs");
    }

    /// kerning is used if the font has kerning pairs
    override @property bool allowKerning() {
        return _allowKerning && _kerningPairs.length > 0;
    }

    /// kerning offset between two characters, in 1/64 pixel
    override int getKerningOffset(dchar prevChar, dchar currentChar) {
        if (!_allowKerning || prevChar > 0xFFFF || currentChar > 0xFFFF)
            return 0;
        if (int * p = ((cast(uint)prevChar << 16) | currentChar) in _kerningPairs)
            return *p * 64;
        return 0;
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
    @property override int height() { return _height; }
    @property override int weight() { return _weight; }
    @property override int baseline() { return _baseline; }
    @property override bool italic() { return _italic; }
    @property override string face() { return _face; }
    @property override FontFamily family() { return _family; }
    @property override bool isNull() { return _hfont is null; }
}


/**
* Font manager implementation based on Win32 API system fonts.
*/
class Win32FontManager : FontManager {
    private FontList _activeFonts;
    private FontDef[] _fontFaces;
    /// index in _fontFaces by lowercase face name: face names match case-insensitively, as in the FreeType font
    /// manager (#1137); indices, not pointers: appending to _fontFaces may move it (#1142)
    private size_t[string] _faceByName;

    /// override to return list of font faces available
    override FontFaceProps[] getFaces() {
        FontFaceProps[] res;
        for (int i = 0; i < _fontFaces.length; i++) {
            FontFaceProps item = FontFaceProps(_fontFaces[i].face, _fontFaces[i].family);
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


    /// initialize in constructor
    this() {
        debug Log.i("Creating Win32FontManager");
        //instance = this;
        initialize();
    }
    ~this() {
        if (inGCFinalizer()) return; // finalized by the GC: a leak, touch nothing (#975)
        debug Log.i("Destroying Win32FontManager");
        releaseFallbackFonts(); // fallback references may form cycles (#888)
        foreach (cache; _codepointPresence)
            cache.clear();
        _codepointPresence = null;
        foreach (h; _memoryFonts)
            RemoveFontMemResourceEx(h);
        _memoryFonts = null;
        _memoryFontData = null;
        _memoryFontKeys = null;
    }

    /// fonts installed from memory (#652): handles from AddFontMemResourceEx, their data, and keys (length and
    /// CRC-32 of the data) to recognize a font registered again
    private HANDLE[] _memoryFonts;
    private immutable(ubyte)[][] _memoryFontData;
    private static struct MemoryFontKey {
        size_t length;
        ubyte[4] crc;
    }
    private MemoryFontKey[] _memoryFontKeys;

    /**
        Registers the faces of a TrueType / OpenType font file or collection kept in memory (#652): installs
        it for this process only (AddFontMemResourceEx) and registers its family names, which are read from
        the font's name table (GDI doesn't report them for such fonts). GDI chooses the weight and italic
        variant among the installed faces of a family.
        Returns: number of faces in the font.
    */
    override int registerFontData(immutable(ubyte)[] data, FontFamily family, string name = null) {
        import std.algorithm : canFind;
        import std.digest.crc : crc32Of;
        FontFileFaceInfo[] faces = fontFileFaces(data);
        if (!faces.length) {
            Log.e("registerFontData: not a TrueType / OpenType font: ", name);
            return 0;
        }
        MemoryFontKey key = MemoryFontKey(data.length, crc32Of(data));
        if (_memoryFontKeys.canFind(key))
            return cast(int)faces.length; // already registered
        DWORD installed = 0;
        HANDLE h = AddFontMemResourceEx(cast(void*)data.ptr, cast(DWORD)data.length, null, &installed);
        if (h is null || installed == 0) {
            Log.e("registerFontData: AddFontMemResourceEx failed for ", name);
            return 0;
        }
        _memoryFonts ~= h;
        _memoryFontKeys ~= key;
        // GDI probably copies the data, but the docs don't say so; embedded resources cost nothing to keep
        _memoryFontData ~= data;
        ubyte familyFlags;
        final switch (family) with (FontFamily) {
            case Unspecified: familyFlags = FF_DONTCARE; break;
            case SansSerif: familyFlags = FF_SWISS; break;
            case Serif: familyFlags = FF_ROMAN; break;
            case Fantasy: familyFlags = FF_DECORATIVE; break;
            case Cursive: familyFlags = FF_SCRIPT; break;
            case MonoSpace: familyFlags = FF_MODERN; break;
        }
        foreach (face; faces) {
            // the face name goes into LOGFONT.lfFaceName (31 characters in the ANSI code page)
            if (fromStringz(toMBSz(face.family)).length > LF_FACESIZE - 1) {
                Log.w("registerFontData: face name too long for GDI, skipped: ", face.family);
                continue;
            }
            // other weights and italic of a family have the same family name; a name that is already
            // registered (also an installed font) isn't added again, but GDI may now use the new font:
            // forget which codepoints the face has
            if (face.family.toLower in _faceByName) {
                forgetCodepoints(face.family);
                installedFacesChanged();
                continue;
            }
            registerFont(family, face.family, cast(ubyte)((face.fixedPitch ? FIXED_PITCH : VARIABLE_PITCH) | familyFlags));
        }
        return cast(int)faces.length;
    }

    private static struct FaceVariant {
        string face;
        int weight;
        bool italic;
    }
    /// presence of codepoints in font faces, shared by fonts of all sizes (#886)
    private CodepointPresenceCache*[FaceVariant] _codepointPresence;

    /// forget which codepoints face has, in all weights and italic; the name matches case-insensitively (#1137)
    private void forgetCodepoints(string face) {
        import std.uni : icmp;
        foreach (k, cache; _codepointPresence)
            if (icmp(k.face, face) == 0)
                cache.clear();
    }

    /// returns codepoint presence cache for font face, weight and italic
    private CodepointPresenceCache * codepointPresence(string face, int weight, bool italic) {
        FaceVariant key = FaceVariant(face, weight, italic);
        if (auto p = key in _codepointPresence)
            return *p;
        CodepointPresenceCache * cache = new CodepointPresenceCache;
        _codepointPresence[key] = cache;
        return cache;
    }

    /// initialize font manager by enumerating of system fonts
    bool initialize() {
        debug Log.i("Win32FontManager.initialize()");
        Win32ColorDrawBuf drawbuf = new Win32ColorDrawBuf(1,1);
        LOGFONTA lf;
        lf.lfCharSet = DEFAULT_CHARSET; //ANSI_CHARSET;
        lf.lfFaceName[0] = 0;
        HDC dc = drawbuf.dc;
        int res =
            EnumFontFamiliesExA(
                                dc,                  // handle to DC
                                &lf,                              // font information
                                cast(FONTENUMPROCA)&LVWin32FontEnumFontFamExProc, // callback function (FONTENUMPROC)
                                cast(LPARAM)(cast(void*)this),                    // additional data
                                0U                     // not used; must be 0
                                    );
        destroy(drawbuf);
        Log.i("Found ", _fontFaces.length, " font faces");
        if (!_fontFaces.length)
            Log.e("Win32FontManager: GDI found no TrueType font faces, there will be no fonts (#1151)");
        return res!=0;
    }

    /// for returning of not found font
    FontRef _emptyFontRef;

    /// get font by properties
    override ref FontRef getFont(int size, int weight, bool italic, FontFamily family, string face) {
        //Log.i("getFont()");
        FontDef * def = findFace(family, face);
        if (def !is null) {
            //Log.i("getFont() found face ", def.face, " by requested face ", face);
            int index = _activeFonts.find(size, weight, italic, def.family, def.face);
            if (index >= 0)
                return _activeFonts.get(index);
            debug(FontResources) Log.d("Creating new font");
            Win32Font item = new Win32Font();
            if (!item.create(def, size, weight, italic))
                return _emptyFontRef;
            item.codepointPresenceCache = codepointPresence(def.face, weight, italic);
            debug(FontResources) Log.d("Adding to list of active fonts");
            return _activeFonts.add(item);
        } else {
            return _emptyFontRef;
        }
    }

    /// find font face definition by family only (try to get one of defaults for family if possible); the
    /// pointer is valid until the next font registration, which may move the definitions (#1142)
    FontDef * findFace(FontFamily family) {
        FontDef * res = null;
        switch(family) {
            case FontFamily.SansSerif:
                res = findFace("Segoe UI"); if (res !is null) return res; // the Windows UI font since Vista (#796)
                res = findFace("Arial"); if (res !is null) return res;
                res = findFace("Tahoma"); if (res !is null) return res;
                res = findFace("Calibri"); if (res !is null) return res;
                res = findFace("Verdana"); if (res !is null) return res;
                res = findFace("Lucida Sans"); if (res !is null) return res;
                break;
            case FontFamily.Serif:
                res = findFace("Times New Roman"); if (res !is null) return res;
                res = findFace("Georgia"); if (res !is null) return res;
                res = findFace("Century Schoolbook"); if (res !is null) return res;
                res = findFace("Bookman Old Style"); if (res !is null) return res;
                break;
            case FontFamily.MonoSpace:
                res = findFace("Courier New"); if (res !is null) return res;
                res = findFace("Lucida Console"); if (res !is null) return res;
                res = findFace("Century Schoolbook"); if (res !is null) return res;
                res = findFace("Bookman Old Style"); if (res !is null) return res;
                break;
            case FontFamily.Cursive:
                res = findFace("Comic Sans MS"); if (res !is null) return res;
                res = findFace("Lucida Handwriting"); if (res !is null) return res;
                res = findFace("Monotype Corsiva"); if (res !is null) return res;
                break;
            default:
                break;
        }
        return null;
    }

    /// find font face definition by face only: the first installed face of a comma separated list; names match
    /// case-insensitively, and the definition has the registered name (#1137); the pointer is valid until the
    /// next font registration, which may move the definitions (#1142)
    FontDef * findFace(string face) {
        if (face.length == 0)
            return null;
        foreach (f; split(face, ",")) {
            // a list may have spaces after the commas, as the FreeType font manager allows (#1132)
            if (auto p = f.strip.toLower in _faceByName)
                return &_fontFaces[*p];
        }
        return null;
    }

    /// find font face definition by family and face, null only if there are no faces; the pointer is valid
    /// until the next font registration, which may move the definitions (#1142)
    FontDef * findFace(FontFamily family, string face) {
        // by face only
        FontDef * res = findFace(face);
        if (res !is null)
            return res;
        // best for family
        res = findFace(family);
        if (res !is null)
            return res;
        for (int i = 0; i < _fontFaces.length; i++) {
            res = &_fontFaces[i];
            if (res.family == family)
                return res;
        }
        res = findFace(FontFamily.SansSerif);
        if (res !is null)
            return res;
        // null when no face is registered (#1151)
        return _fontFaces.length ? &_fontFaces[0] : null;
    }

    /// register enumerated font; a name that differs from a registered one only in case replaces it in face
    /// lookups (#1137)
    bool registerFont(FontFamily family, string fontFace, ubyte pitchAndFamily) {
        Log.d("registerFont(", family, ",", fontFace, ")");
        _fontFaces ~= FontDef(family, fontFace, pitchAndFamily);
        _faceByName[fontFace.toLower] = _fontFaces.length - 1;
        installedFacesChanged();
        return true;
    }

    /// clear usage flags for all entries
    override void checkpoint() {
        _activeFonts.checkpoint();
    }

    /// list of cached fonts, for cleanup() (#888)
    override protected void forEachFontList(scope void delegate(ref FontList list) callback) {
        callback(_activeFonts);
    }

    /// clears glyph cache
    override void clearGlyphCaches() {
        _activeFonts.clearGlyphCache();
    }
}

FontFamily pitchAndFamilyToFontFamily(ubyte flags) {
    if ((flags & FF_DECORATIVE) == FF_DECORATIVE)
        return FontFamily.Fantasy;
    else if ((flags & (FIXED_PITCH)) != 0) // | | MONO_FONT
        return FontFamily.MonoSpace;
    else if ((flags & (FF_ROMAN)) != 0)
        return FontFamily.Serif;
    else if ((flags & (FF_SCRIPT)) != 0)
        return FontFamily.Cursive;
    return FontFamily.SansSerif;
}

// definition
extern(Windows) {
    int LVWin32FontEnumFontFamExProc(
                                     const (LOGFONTA) *lf,    // logical-font data
                                     const (TEXTMETRICA) *lpntme,  // physical-font data
                                     //ENUMLOGFONTEX *lpelfe,    // logical-font data
                                     //NEWTEXTMETRICEX *lpntme,  // physical-font data
                                     DWORD fontType,           // type of font
                                     LPARAM lParam             // application-defined data
                                         )
    {
        //
        //Log.d("LVWin32FontEnumFontFamExProc fontType=", fontType);
        if (fontType == TRUETYPE_FONTTYPE)
        {
            void * p = cast(void*)lParam;
            Win32FontManager fontman = cast(Win32FontManager)p;
            // OEM charset face name
            // string face = fromStringz(lf.lfFaceName.ptr).dup;
            string face = fromMBSz(cast(immutable)lf.lfFaceName.ptr).dup;
            FontFamily family = pitchAndFamilyToFontFamily(lf.lfPitchAndFamily);
            if (face.length < 2 || face[0] == '@')
                return 1;
            //Log.d("face:", face);
            fontman.registerFont(family, face, lf.lfPitchAndFamily);
        }
        return 1;
    }
}

// FontDef keeps pitch and family, passed to LOGFONT.lfPitchAndFamily (#981)
unittest {
    FontDef def = FontDef(FontFamily.MonoSpace, "Courier New", FIXED_PITCH | FF_MODERN);
    assert(def.family == FontFamily.MonoSpace && def.face == "Courier New");
    assert(def.pitchAndFamily == (FIXED_PITCH | FF_MODERN));
}

// a face list may have spaces around the commas (#1132)
unittest {
    auto fm = new Win32FontManager();
    scope (exit) destroy(fm);
    fm.registerFont(FontFamily.SansSerif, "DlangUI Test Face", VARIABLE_PITCH | FF_SWISS);
    FontDef * def = fm.findFace("No Such Face 1132, DlangUI Test Face");
    assert(def && def.face == "DlangUI Test Face");
    def = fm.findFace(" DlangUI Test Face ,No Such Face 1132");
    assert(def && def.face == "DlangUI Test Face");
    assert(fm.findFace("No Such Face 1132, ") is null);
}

// face names match case-insensitively, as in the FreeType font manager; the registered name is kept (#1137)
unittest {
    auto fm = new Win32FontManager();
    scope (exit) destroy(fm);
    fm.registerFont(FontFamily.SansSerif, "DlangUI Test Face", VARIABLE_PITCH | FF_SWISS);
    foreach (name; ["dlangui test face", "DLANGUI TEST FACE", "No Such Face 1137, dlangUI test FACE"]) {
        FontDef * def = fm.findFace(name);
        assert(def && def.face == "DlangUI Test Face", name);
    }
    // the codepoint caches of a face are forgotten by a name in another case, in all variants
    CodepointPresenceCache * regular = fm.codepointPresence("DlangUI Test Face", FontWeight.Normal, false);
    CodepointPresenceCache * boldItalic = fm.codepointPresence("DlangUI Test Face", FontWeight.Bold, true);
    CodepointPresenceCache * other = fm.codepointPresence("Other Test Face", FontWeight.Normal, false);
    foreach (cache; [regular, boldItalic, other])
        cache.setPresence('A', CodepointPresence.missing);
    fm.forgetCodepoints("dlangui TEST face");
    assert(regular.getPresence('A') == CodepointPresence.unknown);
    assert(boldItalic.getPresence('A') == CodepointPresence.unknown);
    assert(other.getPresence('A') == CodepointPresence.missing);
}

// face lookups find the entries of _fontFaces, also after the array moved, as appending to it may (#1142)
unittest {
    auto fm = new Win32FontManager();
    scope (exit) destroy(fm);
    fm.registerFont(FontFamily.SansSerif, "DlangUI Test Face", VARIABLE_PITCH | FF_SWISS);
    immutable size_t index = fm._fontFaces.length - 1;
    // whether an append moves the array depends on the GC: move it here
    fm._fontFaces = fm._fontFaces.dup;
    fm.registerFont(FontFamily.SansSerif, "DlangUI Other Test Face", VARIABLE_PITCH | FF_SWISS);
    assert(fm.findFace("DlangUI Test Face") is &fm._fontFaces[index]);
    assert(fm.findFace("DlangUI Other Test Face") is &fm._fontFaces[$ - 1]);
}

// without registered faces (GDI enumerated no TrueType fonts) there is no face and no font (#1151)
unittest {
    auto fm = new Win32FontManager();
    scope (exit) destroy(fm);
    // the cached installed fallback faces aren't reset (installedFacesChanged() is protected): no fallback
    // checks here
    fm._fontFaces = null;
    fm._faceByName = null;
    assert(fm.findFace(FontFamily.SansSerif, "Arial") is null);
    assert(fm.getFont(12, FontWeight.Normal, false, FontFamily.SansSerif, "Arial").isNull);
}
