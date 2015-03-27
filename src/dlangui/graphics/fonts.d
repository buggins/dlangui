// Written in the D programming language.

/**
This module contains base fonts access interface and common implementation.

Font - base class for fonts.

FontManager - base class for font managers - provides access to available fonts.


Actual implementation is:

dlangui.graphics.ftfonts - FreeType based font manager.

dlangui.platforms.windows.w32fonts - Win32 API based font manager.


To enable OpenGL support, build with version(USE_OPENGL);

See_Also: dlangui.graphics.drawbuf, DrawBuf, drawbuf, drawbuf.html



Synopsis:

----
import dlangui.graphics.fonts;

// find suitable font of size 25, normal, preferrable Arial, or, if not available, any SansSerif font
FontRef font = FontManager.instance.getFont(25, FontWeight.Normal, false, FontFamily.SansSerif, "Arial");

dstring sampleText = "Sample text to draw"d;
// measure text string width and height (one line)
Point sz = font.textSize(sampleText);
// draw red text at center of DrawBuf buf
font.drawText(buf, buf.width / 2 - sz.x/2, buf.height / 2 - sz.y / 2, sampleText, 0xFF0000);

----

Copyright: Vadim Lopatin, 2014
License:   Boost License 1.0
Authors:   Vadim Lopatin, coolreader.org@gmail.com
*/
module dlangui.graphics.fonts;
public import dlangui.graphics.drawbuf;
public import dlangui.core.types;
public import dlangui.core.logger;
private import dlangui.widgets.styles;
import std.algorithm;

/// font families enum
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

/// font weight constants (0..1000)
enum FontWeight : int {
	/// normal font weight
    Normal = 400,
	/// bold font
    Bold = 800
}

immutable dchar UNICODE_SOFT_HYPHEN_CODE = 0x00ad;
immutable dchar UNICODE_ZERO_WIDTH_SPACE = 0x200b;
immutable dchar UNICODE_NO_BREAK_SPACE = 0x00a0;
immutable dchar UNICODE_HYPHEN = 0x2010;
immutable dchar UNICODE_NB_HYPHEN = 0x2011;

/// custom character properties - for char-by-char drawing of text string with different character color and style
struct CustomCharProps {
    uint color;
    uint textFlags;
    this(uint color) {
        this.color = color;
        this.textFlags = 0;
    }
    this(uint color, bool underline, bool strikeThrough = false) {
        this.color = color;
        if (underline)
            this.textFlags |= TextFlag.Underline;
        if (strikeThrough)
            this.textFlags |= TextFlag.StrikeThrough;
    }
}

version (USE_OPENGL) {

    private __gshared void function(uint id) _glyphDestroyCallback;
    /**
     * get glyph destroy callback (to cleanup OpenGL caches)
     * 
     * Used for resource management. Usually you don't have to call it manually.
     */
    @property void function(uint id) glyphDestroyCallback() { return _glyphDestroyCallback; }
    /**
     * Set glyph destroy callback (to cleanup OpenGL caches)
     * This callback is used to tell OpenGL glyph cache that glyph is not more used - to let OpenGL glyph cache delete texture if all glyphs in it are no longer used.
     * 
     * Used for resource management. Usually you don't have to call it manually.
     */
	@property void glyphDestroyCallback(void function(uint id) callback) { _glyphDestroyCallback = callback; }

    private __gshared uint _nextGlyphId;
    /**
     * ID generator for glyphs
     * 
     * Generates next glyph ID. Unique IDs are being used to control OpenGL glyph cache items lifetime.
     * 
     * Used for resource management. Usually you don't have to call it manually.
     */
	uint nextGlyphId() { return _nextGlyphId++; }
}

/// constant for measureText maxWidth paramenter - to tell that all characters of text string should be measured.
immutable int MAX_WIDTH_UNSPECIFIED = int.max;

/** Instance of font with specific size, weight, face, etc.
 *
 * Allows to measure text string and draw it on DrawBuf
 *
 * Use FontManager.instance.getFont() to retrieve font instance.
 */
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

    /// return true if antialiasing is enabled, false if not enabled
    @property bool antialiased() {
        return size >= FontManager.instance.minAnitialiasedFontSize;
    }


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
        if (_spaceWidth < 0) {
            _spaceWidth = charWidth(' ');
			if (_spaceWidth <= 0)
				_spaceWidth = charWidth('0');
			if (_spaceWidth <= 0)
				_spaceWidth = size;
		}
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
     * Supports Tab character processing and processing of menu item labels like '&File'.
     *
     * Params:
     *          text = text string to measure
     *          widths = output buffer to put measured widths (widths[i] will be set to cumulative widths text[0..i])
     *          maxWidth = maximum width to measure - measure is stopping if max width is reached (pass MAX_WIDTH_UNSPECIFIED to measure all characters)
     *      	tabSize = tabulation size, in number of spaces
     *      	tabOffset = when string is drawn not from left position, use to move tab stops left/right
     *      	textFlags = TextFlag bit set - to control underline, hotkey label processing, etc...
     * Returns:
     *          number of characters measured (may be less than text.length if maxWidth is reached)
     ******************************************************************************************/
	int measureText(const dchar[] text, ref int[] widths, int maxWidth = MAX_WIDTH_UNSPECIFIED, int tabSize = 4, int tabOffset = 0, uint textFlags = 0) {
		if (text.length == 0)
			return 0;
		const dchar * pstr = text.ptr;
		uint len = cast(uint)text.length;
        if (widths.length < len)
            widths.length = len + 1;
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
			} else if (ch == '&' && (textFlags & (TextFlag.UnderlineHotKeys | TextFlag.HotKeys | TextFlag.UnderlineHotKeysWhenAltPressed))) {
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
            int w2 = x + glyph.originX + glyph.correctedBlackBoxX; // using black box
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
     *      	tabSize = tabulation size, in number of spaces
     *      	tabOffset = when string is drawn not from left position, use to move tab stops left/right
     *      	textFlags = TextFlag bit set - to control underline, hotkey label processing, etc...
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
		Rect clip = buf.clipRect; //clipOrFullRect;
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
			if (ch == '&' && (textFlags & (TextFlag.UnderlineHotKeys | TextFlag.HotKeys | TextFlag.UnderlineHotKeysWhenAltPressed))) {
				if (textFlags & (TextFlag.UnderlineHotKeys | TextFlag.UnderlineHotKeysWhenAltPressed))
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
				if (gx + glyph.correctedBlackBoxX < clip.left)
					continue;
				buf.drawGlyph( gx,
                               y + _baseline - glyph.originY,
                              glyph,
                              color);
			}
		}
	}

	/*****************************************************************************************
    * Draw text string to buffer.
    *
    * Params:
    *      buf =   graphics buffer to draw text to
    *      x =     x coordinate to draw first character at
    *      y =     y coordinate to draw first character at
    *      text =  text string to draw
    *      colors =  array of colors, colors[i] is color for character text[i]
    *      tabSize = tabulation size, in number of spaces
    *      tabOffset = when string is drawn not from left position, use to move tab stops left/right
    *      textFlags = set of TextFlag bit fields
    ****************************************************************************************/
	void drawColoredText(DrawBuf buf, int x, int y, const dchar[] text, const CustomCharProps[] charProps, int tabSize = 4, int tabOffset = 0, uint textFlags = 0) {
        if (text.length == 0)
            return; // nothing to draw - empty text
        if (_textSizeBuffer.length < text.length)
            _textSizeBuffer.length = text.length;
		int charsMeasured = measureText(text, _textSizeBuffer, MAX_WIDTH_UNSPECIFIED, tabSize, tabOffset, textFlags);
		Rect clip = buf.clipRect; //clipOrFullRect;
        if (clip.empty)
            return; // not visible - clipped out
		if (y + height < clip.top || y >= clip.bottom)
			return; // not visible - fully above or below clipping rectangle
        int _baseline = baseline;
        uint customizedTextFlags = (charProps.length ? charProps[0].textFlags : 0) | textFlags;
		bool underline = (customizedTextFlags & TextFlag.Underline) != 0;
		int underlineHeight = 1;
		int underlineY = y + _baseline + underlineHeight * 2;
		for (int i = 0; i < charsMeasured; i++) {
			dchar ch = text[i];
            uint color = i < charProps.length ? charProps[i].color : charProps[$ - 1].color;
            customizedTextFlags = (i < charProps.length ? charProps[i].textFlags : charProps[$ - 1].textFlags) | textFlags;
            underline = (customizedTextFlags & TextFlag.Underline) != 0;
            // turn off underline after hot key
			if (ch == '&' && (textFlags & (TextFlag.UnderlineHotKeys | TextFlag.HotKeys | TextFlag.UnderlineHotKeysWhenAltPressed))) {
				if (textFlags & (TextFlag.UnderlineHotKeys | TextFlag.UnderlineHotKeysWhenAltPressed))
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
                if (!(customizedTextFlags & TextFlag.Underline))
                    underline = false;
			}

            if (ch == ' ' || ch == '\t')
                continue;
			Glyph * glyph = getCharGlyph(ch);
			if (glyph is null)
				continue;
			if ( glyph.blackBoxX && glyph.blackBoxY ) {
				int gx = x + xx + glyph.originX;
				if (gx + glyph.correctedBlackBoxX < clip.left)
					continue;
				buf.drawGlyph( gx,
                               y + _baseline - glyph.originY,
                              glyph,
                              color);
			}
		}
    }

    /// measure multiline text with line splitting, returns width and height in pixels
    Point measureMultilineText(const dchar[] text, int maxLines = 0, int maxWidth = 0, int tabSize = 4, int tabOffset = 0, uint textFlags = 0) {
        SimpleTextFormatter fmt;
        FontRef fnt = FontRef(this);
        return fmt.format(text, fnt, maxLines, maxWidth, tabSize, tabOffset, textFlags);
    }

    /// draws multiline text with line splitting
    void drawMultilineText(DrawBuf buf, int x, int y, const dchar[] text, uint color, int maxLines = 0, int maxWidth = 0, int tabSize = 4, int tabOffset = 0, uint textFlags = 0) {
        SimpleTextFormatter fmt;
        FontRef fnt = FontRef(this);
        fmt.format(text, fnt, maxLines, maxWidth, tabSize, tabOffset, textFlags);
        fmt.draw(buf, x, y, fnt, color);
    }


	/// get character glyph information
	abstract Glyph * getCharGlyph(dchar ch, bool withImage = true);

	/// clear usage flags for all entries
	abstract void checkpoint();
	/// removes entries not used after last call of checkpoint() or cleanup()
	abstract void cleanup();
    /// clears glyph cache
    abstract void clearGlyphCache();

    void clear() {}

    ~this() { clear(); }
}
alias FontRef = Ref!Font;

/// helper to split text into several lines and draw it
struct SimpleTextFormatter {
    dstring[] _lines;
    int _tabSize;
    int _tabOffset;
    uint _textFlags;
    /// split text into lines and measure it; returns size in pixels
    Point format(const dchar[] text, FontRef fnt, int maxLines = 0, int maxWidth = 0, int tabSize = 4, int tabOffset = 0, uint textFlags = 0) {
        _tabSize = tabSize;
        _tabOffset = tabOffset;
        _textFlags = textFlags;
        Point sz;
        _lines.length = 0;
        int lineHeight = fnt.height;
        if (text.length == 0) {
            sz.y = lineHeight;
            return sz;
        }
        int[] widths;
        int charsMeasured = fnt.measureText(text, widths, MAX_WIDTH_UNSPECIFIED, _tabSize, _tabOffset, _textFlags);
        int lineStart = 0;
        int lineStartX = 0;
        int lastWordEnd = 0;
        int lastWordEndX = 0;
        dchar prevChar = 0;
        for (int i = 0; i <= charsMeasured; i++) {
            dchar ch = i < charsMeasured ? text[i] : 0;
            if (ch == '\n' || i == charsMeasured) {
                // split by EOL char or at end of text
                dstring line = cast(dstring)text[lineStart .. i];
                int lineEndX = (i == lineStart) ? lineStartX : widths[i - 1];
                int lineWidth = lineEndX - lineStartX;
                sz.y += lineHeight;
                if (sz.x < lineWidth)
                    sz.x = lineWidth;
                _lines ~= line;
                if (i == charsMeasured) // end of text reached
                    break;

                // check max lines constraint
                if (maxLines && _lines.length >= maxLines) // max lines reached
                    break;

                lineStart = i + 1;
                lineStartX = widths[i];
            } else {
                // split by width
                int x = widths[i];
                if (ch == '\t' || ch == ' ') {
                    // track last word end
                    if (prevChar != '\t' && prevChar != ' ' && prevChar != 0) {
                        lastWordEnd = i - 1;
                        lastWordEndX = widths[i - 1];
                    }
                    prevChar = ch;
                    continue;
                }
                if (maxWidth > 0 && maxWidth != MAX_WIDTH_UNSPECIFIED && x > maxWidth && x - lineStartX > maxWidth && i > lineStart) {
                    // need splitting
                    int lineEnd = i;
                    int lineEndX = widths[i - 1];
                    if (lastWordEnd > lineStart && lastWordEndX - lineStartX >= maxWidth / 3) {
                        // split on word bound
                        lineEnd = lastWordEnd;
                        lineEndX = widths[lastWordEnd - 1];
                    }
                    // add line
                    dstring line = cast(dstring)text[lineStart .. lastWordEnd];
                    int lineWidth = lineEndX - lineStartX;
                    sz.y += lineHeight;
                    if (sz.x < lineWidth)
                        sz.x = lineWidth;
                    _lines ~= line;

                    // check max lines constraint
                    if (maxLines && _lines.length >= maxLines) // max lines reached
                        break;

                    // find next line start
                    lineStart = lineEnd;
                    while(lineStart < text.length && (text[lineStart] == ' ' || text[lineStart] == '\t'))
                        lineStart++;
                    if (lineStart >= text.length)
                        break;
                    lineStartX = widths[lineStart - 1];
                }
            }
            prevChar = ch;
        }
        return sz;
    }
    /// draw formatted text
    void draw(DrawBuf buf, int x, int y, FontRef fnt, uint color) {
        int lineHeight = fnt.height;
        for (int i = 0; i < _lines.length; i++) {
            dstring line = _lines[i];
        	fnt.drawText(buf, x, y, line, color, _tabSize, _tabOffset, _textFlags);
            y += lineHeight;
        }
    }
}


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
		//Log.d("FontList.add() enter");
		if (_len >= _list.length) {
			_list.length = _len < 16 ? 16 : _list.length * 2;
		}
		_list[_len++] = item;
		//Log.d("FontList.add() exit");
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
    /// clears glyph cache
    void clearGlyphCache() {
		for (int i = 0; i < _len; i++)
			_list[i].clearGlyphCache();
    }
}

/// default min font size for antialiased fonts (e.g. if 16 is set, for 16+ sizes antialiasing will be used, for sizes <=15 - antialiasing will be off)
const int DEF_MIN_ANTIALIASED_FONT_SIZE = 0; // 0 means always use antialiasing

/// Hinting mode (currently supported for FreeType only)
enum HintingMode : int {
    /// based on information from font (using bytecode interpreter)
    Normal, // 0
    /// force autohinting algorithm even if font contains hint data
    AutoHint, // 1
    /// disable hinting completely
    Disabled, // 2
	/// light autohint (similar to Mac)
	Light // 3
}

/// Access points to fonts.
class FontManager {
    protected static __gshared FontManager _instance;
    protected static __gshared int _minAnitialiasedFontSize = DEF_MIN_ANTIALIASED_FONT_SIZE;
    protected static __gshared HintingMode _hintingMode = HintingMode.Normal;
    protected static __gshared SubpixelRenderingMode _subpixelRenderingMode = SubpixelRenderingMode.None;

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

    /// get min font size for antialiased fonts (0 means antialiasing always on, some big value = always off)
    static @property int minAnitialiasedFontSize() {
        return _minAnitialiasedFontSize;
    }

    /// set new min font size for antialiased fonts - fonts with size >= specified value will be antialiased (0 means antialiasing always on, some big value = always off)
    static @property void minAnitialiasedFontSize(int size) {
        if (_minAnitialiasedFontSize != size) {
            _minAnitialiasedFontSize = size;
            if (_instance)
                _instance.clearGlyphCaches();
        }
    }

    /// get current hinting mode (Normal, AutoHint, Disabled)
    static @property HintingMode hintingMode() {
        return _hintingMode;
    }

    /// set hinting mode (Normal, AutoHint, Disabled)
    static @property void hintingMode(HintingMode mode) {
        if (_hintingMode != mode) {
            _hintingMode = mode;
            if (_instance)
                _instance.clearGlyphCaches();
        }
    }

    /// get current subpixel rendering mode for fonts (aka ClearType)
    static @property SubpixelRenderingMode subpixelRenderingMode() {
        return _subpixelRenderingMode;
    }

    /// set subpixel rendering mode for fonts (aka ClearType)
    static @property void subpixelRenderingMode(SubpixelRenderingMode mode) {
        _subpixelRenderingMode = mode;
    }

    private static __gshared double _fontGamma = 1.0;
    /// get font gamma (1.0 is neutral, < 1.0 makes glyphs lighter, >1.0 makes glyphs bolder)
    static @property double fontGamma() { return _fontGamma; }
    /// set font gamma (1.0 is neutral, < 1.0 makes glyphs lighter, >1.0 makes glyphs bolder)
    static @property void fontGamma(double v) { 
        if (v < 0.1)
            v = 0.1;
        else if (v > 4)
            v = 4;
        if (_fontGamma != v) {
            _fontGamma = v; 
            _gamma65.gamma = v;
            _gamma256.gamma = v;
            if (_instance)
                _instance.clearGlyphCaches();
        }
    }

    void clearGlyphCaches() {
        // override to clear glyph caches
    }

	~this() {
		Log.d("Destroying font manager");
	}
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
			foreach(ref item; part) {
				if (item && !item.lastUsage) {
					version (USE_OPENGL) {
						// notify about destroyed glyphs
						if (_glyphDestroyCallback !is null) {
							_glyphDestroyCallback(item.id);
						}
					}
					destroy(item);
                    item = null;
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
	
	/// removes all entries (when built with USE_OPENGL version, notify OpenGL cache about removed glyphs)
	void clear() {
		foreach(part; _glyphs) {
			if (part !is null)
			foreach(ref item; part) {
				if (item) {
					version (USE_OPENGL) {
						// notify about destroyed glyphs
						if (_glyphDestroyCallback !is null) {
							_glyphDestroyCallback(item.id);
						}
					}
					destroy(item);
                    item = null;
				}
			}
		}
	}
	/// on destroy, destroy all items (when built with USE_OPENGL version, notify OpenGL cache about removed glyphs)
	~this() {
		clear();
	}
}


// support of font glyph Gamma correction
// table to correct gamma and translate to output range 0..255
// maxv is 65 for win32 fonts, 256 for freetype
import std.math;
//---------------------------------
struct glyph_gamma_table(int maxv = 65)
{
    this(double gammaValue = 1.0)
    {
        gamma = gammaValue;
    }
    @property double gamma() { return _gamma; }
    @property void gamma(double g) {
        _gamma = g;
        for(int i = 0; i < maxv; i++)
        {
            double v = (maxv - 1.0 - i) / maxv;
            v = pow(v, g);
            int n = cast(int)round(v * 255);
            n = 255 - n;
            if (n < 0)
                n = 0;
            else if (n > 255)
                n = 255;
            _map[i] = cast(ubyte)n;
        }
    }
    /// correct byte value from source range to 0..255 applying gamma
    ubyte correct(ubyte src) {
        if (src >= maxv) src = maxv - 1;
        return _map[src];
    }
private:
    ubyte[maxv] _map;
    double _gamma = 1.0;
};

__gshared glyph_gamma_table!65 _gamma65;
__gshared glyph_gamma_table!256 _gamma256;
__gshared static this() {
    _gamma65 = glyph_gamma_table!65(1.0);
    _gamma256 = glyph_gamma_table!256(1.0);
}
