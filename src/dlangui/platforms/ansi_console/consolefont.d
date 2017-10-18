module dlangui.platforms.ansi_console.consolefont;


public import dlangui.core.config;
static if (BACKEND_CONSOLE):

import dlangui.graphics.fonts;
import dlangui.widgets.styles;

class ConsoleFont : Font {
    private Glyph _glyph;
    this() {
        _spaceWidth = 1;
        _glyph.blackBoxX = 1;
        _glyph.blackBoxY = 1;
        _glyph.widthPixels = 1;
        _glyph.widthScaled = 1 << 6;
        _glyph.originX = 0;
        _glyph.originY = 0;
        _glyph.subpixelMode = SubpixelRenderingMode.None;
        _glyph.glyph = [0];
    }

    /// returns font size (as requested from font engine)
    override @property int size() { return 1; }
    /// returns actual font height including interline space
    override @property int height() { return 1; }
    /// returns font weight
    override @property int weight() { return 400; }
    /// returns baseline offset
    override @property int baseline() { return 0; }
    /// returns true if font is italic
    override @property bool italic() { return false; }
    /// returns font face name
    override @property string face() { return "console"; }
    /// returns font family
    override @property FontFamily family() { return FontFamily.MonoSpace; }
    /// returns true if font object is not yet initialized / loaded
    override @property bool isNull() { return false; }

    /// return true if antialiasing is enabled, false if not enabled
    override @property bool antialiased() {
        return false;
    }

    /// returns true if font has fixed pitch (all characters have equal width)
    override @property bool isFixed() {
        return true;
    }

    /// returns true if font is fixed
    override @property int spaceWidth() {
        return 1;
    }

    /// returns character width
    override int charWidth(dchar ch) {
        return 1;
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
    *          tabSize = tabulation size, in number of spaces
    *          tabOffset = when string is drawn not from left position, use to move tab stops left/right
    *          textFlags = TextFlag bit set - to control underline, hotkey label processing, etc...
    * Returns:
    *          number of characters measured (may be less than text.length if maxWidth is reached)
    ******************************************************************************************/
    override int measureText(const dchar[] text, ref int[] widths, int maxWidth = MAX_WIDTH_UNSPECIFIED, int tabSize = 4, int tabOffset = 0, uint textFlags = 0) {
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
        foreach(int i; 0 .. len) {
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
            int w = x + 1; // using advance
            pwidths[i] = w;
            x += 1;
            charsMeasured = i + 1;
            if (x > maxWidth)
                break;
        }
        return charsMeasured;
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
    override void drawText(DrawBuf drawBuf, int x, int y, const dchar[] text, uint color, int tabSize = 4, int tabOffset = 0, uint textFlags = 0) {
        if (text.length == 0)
            return; // nothing to draw - empty text
        import dlangui.platforms.ansi_console.consoleapp;
        import dlangui.platforms.ansi_console.dconsole;
        ANSIConsoleDrawBuf buf = cast(ANSIConsoleDrawBuf)drawBuf;
        if (!buf)
            return;
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
        buf.console.textColor = ANSIConsoleDrawBuf.toConsoleColor(color);
        buf.console.backgroundColor = CONSOLE_TRANSPARENT_BACKGROUND;
        //Log.d("drawText: (", x, ',', y, ") '", text, "', color=", buf.console.textColor);
        foreach(int i; 0 .. charsMeasured) {
            dchar ch = text[i];
            if (ch == '&' && (textFlags & (TextFlag.UnderlineHotKeys | TextFlag.HotKeys | TextFlag.UnderlineHotKeysWhenAltPressed))) {
                if (textFlags & (TextFlag.UnderlineHotKeys | TextFlag.UnderlineHotKeysWhenAltPressed))
                    underline = true; // turn ON underline for hot key
                continue; // skip '&' in hot key when measuring
            }
            int xx = (i > 0) ? _textSizeBuffer[i - 1] : 0;
            if (x + xx >= clip.right)
                break;
            if (x + xx < clip.left)
                continue; // far at left of clipping region

            if (underline) {
                // draw underline
                buf.console.underline = true;
                // turn off underline after hot key
                if (!(textFlags & TextFlag.Underline)) {
                    underline = false;
                    buf.console.underline = false;
                }
            }

            if (ch == ' ' || ch == '\t')
                continue;
            int gx = x + xx;
            if (gx < clip.left)
                continue;
            buf.console.setCursor(gx, y);
            buf.console.writeText(cast(dstring)(text[i .. i + 1]));
        }
        buf.console.underline = false;
    }

    /*****************************************************************************************
    * Draw text string to buffer.
    *
    * Params:
    *      buf =   graphics buffer to draw text to
    *      x =     x coordinate to draw first character at
    *      y =     y coordinate to draw first character at
    *      text =  text string to draw
    *      charProps =  array of character properties, charProps[i] are properties for character text[i]
    *      tabSize = tabulation size, in number of spaces
    *      tabOffset = when string is drawn not from left position, use to move tab stops left/right
    *      textFlags = set of TextFlag bit fields
    ****************************************************************************************/
    override void drawColoredText(DrawBuf drawBuf, int x, int y, const dchar[] text, const CustomCharProps[] charProps, int tabSize = 4, int tabOffset = 0, uint textFlags = 0) {
        if (text.length == 0)
            return; // nothing to draw - empty text

        import dlangui.platforms.ansi_console.consoleapp;
        import dlangui.platforms.ansi_console.dconsole;
        ANSIConsoleDrawBuf buf = cast(ANSIConsoleDrawBuf)drawBuf;

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
        buf.console.backgroundColor = CONSOLE_TRANSPARENT_BACKGROUND;
        foreach(int i; 0 .. charsMeasured) {
            dchar ch = text[i];
            uint color = i < charProps.length ? charProps[i].color : charProps[$ - 1].color;
            buf.console.textColor = ANSIConsoleDrawBuf.toConsoleColor(color);
            customizedTextFlags = (i < charProps.length ? charProps[i].textFlags : charProps[$ - 1].textFlags) | textFlags;
            underline = (customizedTextFlags & TextFlag.Underline) != 0;
            // turn off underline after hot key
            if (ch == '&' && (textFlags & (TextFlag.UnderlineHotKeys | TextFlag.HotKeys | TextFlag.UnderlineHotKeysWhenAltPressed))) {
                // draw underline
                buf.console.underline = true;
                // turn off underline after hot key
                if (!(textFlags & TextFlag.Underline)) {
                    underline = false;
                    buf.console.underline = false;
                }
                continue; // skip '&' in hot key when measuring
            }
            int xx = (i > 0) ? _textSizeBuffer[i - 1] : 0;
            if (x + xx >= clip.right)
                break;
            if (x + xx < clip.left)
                continue; // far at left of clipping region

            if (underline) {
                // draw underline
                buf.console.underline = true;
                // turn off underline after hot key
                if (!(customizedTextFlags & TextFlag.Underline)) {
                    underline = false;
                    buf.console.underline = false;
                }
            }

            if (ch == ' ' || ch == '\t')
                continue;

            int gx = x + xx;
            if (gx < clip.left)
                continue;
            buf.console.setCursor(gx, y);
            buf.console.writeText(cast(dstring)(text[i .. i + 1]));
        }
    }

    /// measure multiline text with line splitting, returns width and height in pixels
    override Point measureMultilineText(const dchar[] text, int maxLines = 0, int maxWidth = 0, int tabSize = 4, int tabOffset = 0, uint textFlags = 0) {
        SimpleTextFormatter fmt;
        FontRef fnt = FontRef(this);
        return fmt.format(text, fnt, maxLines, maxWidth, tabSize, tabOffset, textFlags);
    }

    /// draws multiline text with line splitting
    override void drawMultilineText(DrawBuf buf, int x, int y, const dchar[] text, uint color, int maxLines = 0, int maxWidth = 0, int tabSize = 4, int tabOffset = 0, uint textFlags = 0) {
        SimpleTextFormatter fmt;
        FontRef fnt = FontRef(this);
        fmt.format(text, fnt, maxLines, maxWidth, tabSize, tabOffset, textFlags);
        fmt.draw(buf, x, y, fnt, color);
    }


    /// get character glyph information
    override Glyph * getCharGlyph(dchar ch, bool withImage = true) {
        return &_glyph;
    }

    /// clear usage flags for all entries
    override void checkpoint() {
        // ignore
    }
    /// removes entries not used after last call of checkpoint() or cleanup()
    override void cleanup() {
        // ignore
    }
    /// clears glyph cache
    override void clearGlyphCache() {
        // ignore
    }

    override void clear() {
    }

    ~this() {
        clear();
    }
}

class ConsoleFontManager : FontManager {
    this() {
        _font = new ConsoleFont();
    }

    private FontRef _font;

    /// get font instance best matched specified parameters
    override ref FontRef getFont(int size, int weight, bool italic, FontFamily family, string face) {
        return _font;
    }

    /// clear usage flags for all entries -- for cleanup of unused fonts
    override void checkpoint() {
        // ignore
    }

    /// removes entries not used after last call of checkpoint() or cleanup()
    override void cleanup() {
        // ignore
    }

}


