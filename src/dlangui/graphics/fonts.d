// Written in the D programming language.

/**
DLANGUI library.

This module contains base fonts access implementation.

To enable OpenGL support, build with version(USE_OPENGL);

Synopsis:

----
import dlangui.graphics.glsupport;

----

Copyright: Vadim Lopatin, 2014
License:   $(WEB boost.org/LICENSE_1_0.txt, Boost License 1.0).
Authors:   $(WEB coolreader.org, Vadim Lopatin)
*/
module dlangui.graphics.fonts;
public import dlangui.graphics.drawbuf;
public import dlangui.core.types;
public import dlangui.core.logger;
private import dlangui.widgets.styles;
import std.algorithm;

/// font family
enum FontFamily : ubyte {
    /// Unknown / not set / does not matter
    Unspecified,
    /// Sans Serif font, e.g. Arial
    SansSerif,
    /// Serif font, e.g. Times New Roman
    Serif,
    /// Fantasy font
	Fantasy,
    /// Cursive font
	Cursive,
    /// Monospace font (fixed pitch font), e.g. Courier New
    MonoSpace
}

/// useful font weight constants
enum FontWeight : int {
    Normal = 400,
    Bold = 800
}

immutable dchar UNICODE_SOFT_HYPHEN_CODE = 0x00ad;
immutable dchar UNICODE_ZERO_WIDTH_SPACE = 0x200b;
immutable dchar UNICODE_NO_BREAK_SPACE = 0x00a0;
immutable dchar UNICODE_HYPHEN = 0x2010;
immutable dchar UNICODE_NB_HYPHEN = 0x2011;


version (USE_OPENGL) {
    private __gshared void function(uint id) _glyphDestroyCallback;
    /// get glyph destroy callback (to cleanup OpenGL caches)
    @property void function(uint id) glyphDestroyCallback() { return _glyphDestroyCallback; }
    /// set glyph destroy callback (to cleanup OpenGL caches)
    @property void glyphDestroyCallback(void function(uint id) callback) { _glyphDestroyCallback = callback; }

    private __gshared uint _nextGlyphId;
    /// ID generator for glyphs
    uint nextGlyphId() { return _nextGlyphId++; }
}

/***************************************
 * Glyph image cache
 *
 *
 * Recently used glyphs are marked with glyph.lastUsage = 1
 * 
 * checkpoint() call clears usage marks
 *
 * cleanup() removes all items not accessed since last checkpoint()
 *
 ***************************************/
struct GlyphCache
{
    alias glyph_ptr = Glyph*;
    private glyph_ptr[][1024] _glyphs;

    /// try to find glyph for character in cache, returns null if not found
	Glyph * find(dchar ch) {
        ch = ch & 0xF_FFFF;
        //if (_array is null)
        //    _array = new Glyph[0x10000];
        uint p = ch >> 8;
        glyph_ptr[] row = _glyphs[p];
        if (row is null)
            return null;
        uint i = ch & 0xFF;
        Glyph * res = row[i];
        if (!res)
            return null;
        res.lastUsage = 1;
        return res;
    }

	/// put character glyph to cache
	Glyph * put(dchar ch, Glyph * glyph) {
        ch = ch & 0xF_FFFF;
        uint p = ch >> 8;
        uint i = ch & 0xFF;
        if (_glyphs[p] is null)
            _glyphs[p] = new glyph_ptr[256];
        _glyphs[p][i] = glyph;
        glyph.lastUsage = 1;
        return glyph;
	}

	/// removes entries not used after last call of checkpoint() or cleanup()
	void cleanup() {
        foreach(part; _glyphs) {
            if (part !is null)
                foreach(item; part) {
                    if (item && !item.lastUsage) {
                        version (USE_OPENGL) {
                            // notify about destroyed glyphs
                            if (_glyphDestroyCallback !is null) {
                                _glyphDestroyCallback(item.id);
                            }
                        }
                        destroy(item);
                    }
                }
        }
	}

	/// clear usage flags for all entries
	void checkpoint() {
        foreach(part; _glyphs) {
            if (part !is null)
                foreach(item; part) {
                    if (item)
                        item.lastUsage = 0;
                }
        }
    }

	/// removes all entries (notify OpenGL cache about removed glyphs)
	void clear() {
        foreach(part; _glyphs) {
            if (part !is null)
                foreach(item; part) {
                    if (item) {
                        version (USE_OPENGL) {
                            // notify about destroyed glyphs
                            if (_glyphDestroyCallback !is null) {
                                _glyphDestroyCallback(item.id);
                            }
                        }
                        destroy(item);
                    }
                }
        }
	}
    /// on destroy, destroy all items (notify OpenGL cache about removed glyphs)
	~this() {
		clear();
	}
}

immutable int MAX_WIDTH_UNSPECIFIED = int.max;

/// Font object
class Font : RefCountedObject {
    /// returns font size (as requested from font engine)
    abstract @property int size();
    /// returns actual font height including interline space
    abstract @property int height();
    /// returns font weight
    abstract @property int weight();
    /// returns baseline offset
    abstract @property int baseline();
    /// returns true if font is italic
    abstract @property bool italic();
    /// returns font face name
    abstract @property string face();
    /// returns font family
    abstract @property FontFamily family();
    /// returns true if font object is not yet initialized / loaded
    abstract @property bool isNull();

    private int _fixedFontDetection = -1;

    /// returns true if font has fixed pitch (all characters have equal width)
    @property bool isFixed() {
        if (_fixedFontDetection < 0) {
            if (charWidth('i') == charWidth(' ') && charWidth('M') == charWidth('i'))
                _fixedFontDetection = 1;
            else
                _fixedFontDetection = 0;
        }
        return _fixedFontDetection == 1;
    }

    private int _spaceWidth = -1;
    /// returns true if font is fixed
    @property int spaceWidth() {
        if (_spaceWidth < 0)
            _spaceWidth = charWidth(' ');
        return _spaceWidth;
    }
    /// returns character width
    int charWidth(dchar ch) {
        Glyph * g = getCharGlyph(ch);
        return !g ? 0 : g.width;
    }

	/*******************************************************************************************
     * Measure text string, return accumulated widths[] (distance to end of n-th character), returns number of measured chars.
     *
     * Params:
     *         text = text string to measure
     *         widths = output buffer to put measured widths (widths[i] will be set to cumulative widths text[0..i])
     *          maxWidth = maximum width - measure is stopping if max width is reached
     *      tabSize = tabulation size, in number of spaces
     *      tabOffset = when string is drawn not from left position, use to move tab stops left/right
     ******************************************************************************************/
	int measureText(const dchar[] text, ref int[] widths, int maxWidth=MAX_WIDTH_UNSPECIFIED, int tabSize = 4, int tabOffset = 0, uint textFlags = 0) {
		if (text.length == 0)
			return 0;
		const dchar * pstr = text.ptr;
		uint len = cast(uint)text.length;
        int x = 0;
        int charsMeasured = 0;
        int * pwidths = widths.ptr;
        int tabWidth = spaceWidth * tabSize; // width of full tab in pixels
        tabOffset = tabOffset % tabWidth;
        if (tabOffset < 0)
            tabOffset += tabWidth;
		for (int i = 0; i < len; i++) {
            //auto measureStart = std.datetime.Clock.currAppTick;
            dchar ch = pstr[i];
            if (ch == '\t') {
                // measure tab
                int tabPosition = (x + tabWidth - tabOffset) / tabWidth * tabWidth + tabOffset;
                while (tabPosition < x + spaceWidth)
                    tabPosition += tabWidth;
                pwidths[i] = tabPosition;
                charsMeasured = i + 1;
                x = tabPosition;
                continue;
			} else if (ch == '&' && (textFlags & (TextFlag.UnderlineHotKeys | TextFlag.HotKeys))) {
				pwidths[i] = x;
				continue; // skip '&' in hot key when measuring
			}
			Glyph * glyph = getCharGlyph(pstr[i], true); // TODO: what is better
            //auto measureEnd = std.datetime.Clock.currAppTick;
            //auto duration = measureEnd - measureStart;
            //if (duration.length > 10)
            //    Log.d("ft measureText took ", duration.length, " ticks");
			if (glyph is null) {
                // if no glyph, use previous width - treat as zero width
                pwidths[i] = x;
				continue;
            }
            int w = x + glyph.width; // using advance
            int w2 = x + glyph.originX + glyph.blackBoxX; // using black box
            if (w < w2) // choose bigger value
                w = w2;
            pwidths[i] = w;
            x += glyph.width;
            charsMeasured = i + 1;
            if (x > maxWidth)
                break;
        }
		return charsMeasured;
	}

    private int[] _textSizeBuffer; // buffer to reuse while measuring strings - to avoid GC

	/*************************************************************************
     * Measure text string as single line, returns width and height
     * 
     * Params:
     *          text = text string to measure
     *          maxWidth = maximum width - measure is stopping if max width is reached
     ************************************************************************/
	Point textSize(const dchar[] text, int maxWidth = MAX_WIDTH_UNSPECIFIED, int tabSize = 4, int tabOffset = 0, uint textFlags = 0) {
        if (_textSizeBuffer.length < text.length + 1)
            _textSizeBuffer.length = text.length + 1;
        int charsMeasured = measureText(text, _textSizeBuffer, maxWidth, tabSize, tabOffset, textFlags);
        if (charsMeasured < 1)
            return Point(0,0);
        return Point(_textSizeBuffer[charsMeasured - 1], height);
    }

	/*****************************************************************************************
     * Draw text string to buffer.
     *
     * Params:
     *      buf =   graphics buffer to draw text to
     *      x =     x coordinate to draw first character at
     *      y =     y coordinate to draw first character at
     *      text =  text string to draw
     *      color =  color for drawing of glyphs
     *      tabSize = tabulation size, in number of spaces
     *      tabOffset = when string is drawn not from left position, use to move tab stops left/right
     *      textFlags = set of TextFlag bit fields
     ****************************************************************************************/
	void drawText(DrawBuf buf, int x, int y, const dchar[] text, uint color, int tabSize = 4, int tabOffset = 0, uint textFlags = 0) {
        if (text.length == 0)
            return; // nothing to draw - empty text
        if (_textSizeBuffer.length < text.length)
            _textSizeBuffer.length = text.length;
		int charsMeasured = measureText(text, _textSizeBuffer, MAX_WIDTH_UNSPECIFIED, tabSize, tabOffset, textFlags);
		Rect clip = buf.clipOrFullRect;
        if (clip.empty)
            return; // not visible - clipped out
		if (y + height < clip.top || y >= clip.bottom)
			return; // not visible - fully above or below clipping rectangle
        int _baseline = baseline;
		bool underline = (textFlags & TextFlag.Underline) != 0;
		int underlineHeight = 1;
		int underlineY = y + _baseline + underlineHeight * 2;
		for (int i = 0; i < charsMeasured; i++) {
			dchar ch = text[i];
			if (ch == '&' && (textFlags & (TextFlag.UnderlineHotKeys | TextFlag.HotKeys))) {
				if (textFlags & TextFlag.UnderlineHotKeys)
					underline = true; // turn ON underline for hot key
				continue; // skip '&' in hot key when measuring
			}
			int xx = (i > 0) ? _textSizeBuffer[i - 1] : 0;
			if (x + xx > clip.right)
				break;
			if (x + xx + 255 < clip.left)
				continue; // far at left of clipping region

			if (underline) {
				int xx2 = _textSizeBuffer[i];
				// draw underline
				if (xx2 > xx)
					buf.fillRect(Rect(x + xx, underlineY, x + xx2, underlineY + underlineHeight), color);
				// turn off underline after hot key
				if (!(textFlags & TextFlag.Underline))
					underline = false; 
			}

            if (ch == ' ' || ch == '\t')
                continue;
			Glyph * glyph = getCharGlyph(ch);
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

	/// get character glyph information
	abstract Glyph * getCharGlyph(dchar ch, bool withImage = true);

	/// clear usage flags for all entries
	abstract void checkpoint();
	/// removes entries not used after last call of checkpoint() or cleanup()
	abstract void cleanup();

    void clear() {}

    ~this() { clear(); }
}
alias FontRef = Ref!Font;

/// font instance collection - utility class, for font manager implementations
struct FontList {
	FontRef[] _list;
	uint _len;
	~this() {
		clear();
	}
	
	@property uint length() {
		return _len;
	}
	
	void clear() {
		for (uint i = 0; i < _len; i++) {
			_list[i].clear();
			_list[i] = null;
		}
		_len = 0;
	}
	// returns item by index
	ref FontRef get(int index) {
		return _list[index];
	}
	// find by a set of parameters - returns index of found item, -1 if not found
	int find(int size, int weight, bool italic, FontFamily family, string face) {
		for (int i = 0; i < _len; i++) {
			Font item = _list[i].get;
			if (item.family != family)
				continue;
			if (item.size != size)
				continue;
			if (item.italic != italic || item.weight != weight)
				continue;
			if (!equal(item.face, face))
				continue;
			return i;
		}
		return -1;
	}
	// find by size only - returns index of found item, -1 if not found
	int find(int size) {
		for (int i = 0; i < _len; i++) {
			Font item = _list[i].get;
			if (item.size != size)
				continue;
			return i;
		}
		return -1;
	}
	ref FontRef add(Font item) {
		Log.d("FontList.add() enter");
		if (_len >= _list.length) {
			_list.length = _len < 16 ? 16 : _list.length * 2;
		}
		_list[_len++] = item;
		Log.d("FontList.add() exit");
		return _list[_len - 1];
	}
	// remove unused items - with reference == 1
	void cleanup() {
		for (int i = 0; i < _len; i++)
			if (_list[i].refCount <= 1)
				_list[i].clear();
		int dst = 0;
		for (int i = 0; i < _len; i++) {
			if (!_list[i].isNull)
				if (i != dst)
					_list[dst++] = _list[i];
		}
		_len = dst;
		for (int i = 0; i < _len; i++)
			_list[i].cleanup();
	}
	void checkpoint() {
		for (int i = 0; i < _len; i++)
			_list[i].checkpoint();
	}
}


/// Access points to fonts.
class FontManager {
    protected static __gshared FontManager _instance;

    /// sets new font manager singleton instance
    static @property void instance(FontManager manager) {
		if (_instance !is null) {
			destroy(_instance);
            _instance = null;
        }
        _instance = manager;
    }

    /// returns font manager singleton instance
    static @property FontManager instance() {
        return _instance;
    }

    /// get font instance best matched specified parameters
    abstract ref FontRef getFont(int size, int weight, bool italic, FontFamily family, string face);

	/// clear usage flags for all entries -- for cleanup of unused fonts
	abstract void checkpoint();

	/// removes entries not used after last call of checkpoint() or cleanup()
	abstract void cleanup();

	~this() {
		Log.d("Destroying font manager");
	}
}
