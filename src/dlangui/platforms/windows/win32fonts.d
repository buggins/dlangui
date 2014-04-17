module dlangui.platforms.windows.win32fonts;

version (Windows) {

import win32.windows;
import dlangui.graphics.fonts;
import dlangui.platforms.windows.win32drawbuf;
import std.string;
import std.utf;

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
	this(FontFamily family, string face, ubyte putchAndFamily) {
		_family = family;
		_face = face;
		_pitchAndFamily = pitchAndFamily;
	}
}


/**
* Font implementation based on Win32 API system fonts.
*/
class Win32Font : Font {
    HFONT _hfont;
    int _size;
    int _height;
    int _weight;
    int _baseline;
    bool _italic;
    string _face;
    FontFamily _family;
    LOGFONTA _logfont;
    Win32ColorDrawBuf _drawbuf;
	GlyphCache _glyphCache;

	/// need to call create() after construction to initialize font
    this() {
    }

	/// do cleanup
	~this() {
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

	override Glyph * getCharGlyph(dchar ch, bool withImage = true) {
		uint glyphIndex = getGlyphIndex(ch);
		if (!glyphIndex)
			return null;
		if (glyphIndex >= 0xFFFF)
			return null;
		Glyph * found = _glyphCache.find(cast(ushort)glyphIndex);
		if (found !is null)
			return found;
		GLYPHMETRICS metrics;

		MAT2 identity = { {0,1}, {0,0}, {0,0}, {0,1} };
		uint res;
		res = GetGlyphOutlineW( _drawbuf.dc, cast(wchar)ch,
                                GGO_METRICS,
                               &metrics,
                               0,
                               null,
                               &identity );
		if (res==GDI_ERROR)
			return null;
		int gs = GetGlyphOutlineW( _drawbuf.dc, cast(wchar)ch,
                                   GGO_GRAY8_BITMAP, //GGO_METRICS
								  &metrics,
								  0,
								  NULL,
								  &identity );
		if (gs >= 0x10000 || gs < 0)
			return null;

		Glyph g;
        version (USE_OPENGL) {
            g.id = nextGlyphId();
        }
		g.blackBoxX = cast(ubyte)metrics.gmBlackBoxX;
		g.blackBoxY = cast(ubyte)metrics.gmBlackBoxY;
		g.originX = cast(byte)metrics.gmptGlyphOrigin.x;
		g.originY = cast(byte)metrics.gmptGlyphOrigin.y;
		g.width = cast(ubyte)metrics.gmCellIncX;
		g.glyphIndex = cast(ushort)glyphIndex;

		if (g.blackBoxX>0 && g.blackBoxY>0)
		{
			g.glyph = new ubyte[g.blackBoxX * g.blackBoxY];
			if (gs>0)
			{
				ubyte glyph[] = new ubyte[gs];
				res = GetGlyphOutlineW( _drawbuf.dc, cast(wchar)ch,
                                        GGO_GRAY8_BITMAP, //GGO_METRICS
									   &metrics,
									   gs,
									   glyph.ptr,
									   &identity );
				if (res==GDI_ERROR)
				{
					return null;
				}
				int glyph_row_size = (g.blackBoxX + 3) / 4 * 4;
				ubyte * src = glyph.ptr;
				ubyte * dst = g.glyph.ptr;
				for (int y = 0; y < g.blackBoxY; y++)
				{
					for (int x = 0; x < g.blackBoxX; x++)
					{
						ubyte b = src[x];
						if (b>=64)
							b = 63;
						b = (b<<2) & 0xFC;
						dst[x] = b;
					}
					src += glyph_row_size;
					dst += g.blackBoxX;
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
		return _glyphCache.put(cast(ushort)glyphIndex, &g);
	}

	// draw text string to buffer
	override void drawText(DrawBuf buf, int x, int y, const dchar[] text, uint color) {
		int[] widths;
		int charsMeasured = measureText(text, widths, 3000);
		Rect clip = buf.clipOrFullRect;
		if (y + height < clip.top || y >= clip.bottom)
			return;
		for (int i = 0; i < charsMeasured; i++) {
			int xx = (i > 0) ? widths[i - 1] : 0;
			if (x + xx > clip.right)
				break;
			Glyph * glyph = getCharGlyph(text[i]);
			if (glyph is null)
				continue;
			if ( glyph.blackBoxX && glyph.blackBoxY ) {
				int gx = x + xx + glyph.originX;
				if (gx + glyph.blackBoxX < clip.left)
					continue;
				buf.drawGlyph( gx,
                               y + _baseline - glyph.originY,
                              glyph,
                              color);
			}
		}
	}

    static if (true) {
	    override int measureText(const dchar[] text, ref int[] widths, int maxWidth) {
		    if (text.length == 0)
			    return 0;
		    const dchar * pstr = text.ptr;
		    uint len = cast(uint)text.length;
            if (widths.length < len)
                widths.length = len;
            int x = 0;
            int charsMeasured = 0;
		    for (int i = 0; i < len; i++) {
			    Glyph * glyph = getCharGlyph(text[i], true); // TODO: what is better
			    if (glyph is null) {
                    // if no glyph, use previous width - treat as zero width
                    widths[i] = i > 0 ? widths[i-1] : 0;
				    continue;
                }
                int w = x + glyph.width; // using advance
                int w2 = x + glyph.originX + glyph.blackBoxX; // using black box
                if (w < w2) // choose bigger value
                    w = w2;
                widths[i] = w;
                x += glyph.width;
                charsMeasured = i + 1;
                if (x > maxWidth)
                    break;
            }
		    return charsMeasured;
	    }
    } else {

	    override int measureText(const dchar[] text, ref int[] widths, int maxWidth) {
		    if (_hfont is null || _drawbuf is null || text.length == 0)
			    return 0;
		    wstring utf16text = toUTF16(text);
		    const wchar * pstr = utf16text.ptr;
		    uint len = cast(uint)utf16text.length;
		    GCP_RESULTSW gcpres;
		    gcpres.lStructSize = gcpres.sizeof;
		    if (widths.length < len + 1)
			    widths.length = len + 1;
		    gcpres.lpDx = widths.ptr;
		    gcpres.nMaxFit = len;
		    gcpres.nGlyphs = len;
		    uint res = GetCharacterPlacementW( 
                                              _drawbuf.dc,
                                              pstr,
                                              len,
                                              maxWidth,
                                              &gcpres,
                                              GCP_MAXEXTENT); //|GCP_USEKERNING
		    if (!res) {
			    widths[0] = 0;
			    return 0;
		    }
		    uint measured = gcpres.nMaxFit;
		    int total = 0;
		    for (int i = 0; i < measured; i++) {
			    int w = widths[i];
			    total += w;
			    widths[i] = total;
		    }
		    return measured;
	    }
    }

	bool create(FontDef * def, int size, int weight, bool italic) {
        if (!isNull())
            clear();
		LOGFONTA lf;
        lf.lfCharSet = ANSI_CHARSET; //DEFAULT_CHARSET;
		lf.lfFaceName[0..def.face.length] = def.face;
		lf.lfFaceName[def.face.length] = 0;
		lf.lfHeight = -size;
		lf.lfItalic = italic;
		lf.lfOutPrecision = OUT_OUTLINE_PRECIS; //OUT_TT_ONLY_PRECIS;
		lf.lfClipPrecision = CLIP_DEFAULT_PRECIS;
		//lf.lfQuality = NONANTIALIASED_QUALITY; //ANTIALIASED_QUALITY;
		//lf.lfQuality = PROOF_QUALITY; //ANTIALIASED_QUALITY;
		lf.lfQuality = size < 18 ? NONANTIALIASED_QUALITY : PROOF_QUALITY; //ANTIALIASED_QUALITY;
		lf.lfPitchAndFamily = def.pitchAndFamily;
        _hfont = CreateFontIndirectA(&lf);
        _drawbuf = new Win32ColorDrawBuf(1, 1);
        SelectObject(_drawbuf.dc, _hfont);

        TEXTMETRICW tm;
        GetTextMetricsW(_drawbuf.dc, &tm);

		_size = size;
        _height = tm.tmHeight;
        _baseline = _height - tm.tmDescent;
        _weight = weight;
        _italic = italic;
        _face = def.face;
        _family = def.family;
		Log.d("Created font ", _face, " ", _size);
		return true;
	}

	// clear usage flags for all entries
	override void checkpoint() {
		_glyphCache.checkpoint();
	}

	// removes entries not used after last call of checkpoint() or cleanup()
	override void cleanup() {
		_glyphCache.cleanup();
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
	private FontDef*[string] _faceByName;

	/// initialize in constructor
    this() {
        Log.i("Creating Win32FontManager");
        //instance = this;
        init();
    }
    ~this() {
        Log.i("Destroying Win32FontManager");
    }

	/// initialize font manager by enumerating of system fonts
    bool init() {
		Log.i("Win32FontManager.init()");
        Win32ColorDrawBuf drawbuf = new Win32ColorDrawBuf(1,1);
        LOGFONTA lf;
        lf.lfCharSet = ANSI_CHARSET; //DEFAULT_CHARSET;
		lf.lfFaceName[0] = 0;
		HDC dc = drawbuf.dc;
        int res = 
            EnumFontFamiliesExA(
                                dc,                  // handle to DC
                                &lf,                              // font information
                                &LVWin32FontEnumFontFamExProc, // callback function (FONTENUMPROC)
                                cast(LPARAM)(cast(void*)this),                    // additional data
                                0U                     // not used; must be 0
                                    );
		destroy(drawbuf);
		Log.i("Found ", _fontFaces.length, " font faces");
        return res!=0;
    }

	/// for returning of not found font
	FontRef _emptyFontRef;

	/// get font by properties
    override ref FontRef getFont(int size, int weight, bool italic, FontFamily family, string face) {
		//Log.i("getFont()");
		FontDef * def = findFace(family, face);
		if (def !is null) {
			int index = _activeFonts.find(size, weight, italic, def.family, def.face);
			if (index >= 0)
				return _activeFonts.get(index);
			Log.d("Creating new font");
			Win32Font item = new Win32Font();
			if (!item.create(def, size, weight, italic))
				return _emptyFontRef;
			Log.d("Adding to list of active fonts");
			return _activeFonts.add(item);
		} else {
			return _emptyFontRef;
		}
    }

	/// find font face definition by family only (try to get one of defaults for family if possible)
	FontDef * findFace(FontFamily family) {
		FontDef * res = null;
		switch(family) {
            case FontFamily.SansSerif:
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

	/// find font face definition by face only
	FontDef * findFace(string face) {
		if (face.length == 0)
			return null;
		if (face in _faceByName)
			return _faceByName[face];
		return null;
	}

	/// find font face definition by family and face
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
		return &_fontFaces[0];
	}

	/// register enumerated font
    bool registerFont(FontFamily family, string fontFace, ubyte pitchAndFamily) {
		Log.d("registerFont(", family, ",", fontFace, ")");
		_fontFaces ~= FontDef(family, fontFace, pitchAndFamily);
		_faceByName[fontFace] = &_fontFaces[$ - 1];
        return true;
    }

	/// clear usage flags for all entries
	override void checkpoint() {
		_activeFonts.checkpoint();
	}

	/// removes entries not used after last call of checkpoint() or cleanup()
	override void cleanup() {
		_activeFonts.cleanup();
		//_list.cleanup();
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
			string face = fromStringz(lf.lfFaceName.ptr);
			FontFamily family = pitchAndFamilyToFontFamily(lf.lfPitchAndFamily);
			if (face.length < 2 || face[0] == '@')
				return 1;
			//Log.d("face:", face);
			fontman.registerFont(family, face, lf.lfPitchAndFamily);
        }
        return 1;
    }
}

}
