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

public import dlangui.core.config;
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

enum dchar UNICODE_SOFT_HYPHEN_CODE = 0x00ad;
enum dchar UNICODE_ZERO_WIDTH_SPACE = 0x200b;
enum dchar UNICODE_NO_BREAK_SPACE = 0x00a0;
enum dchar UNICODE_HYPHEN = 0x2010;
enum dchar UNICODE_NB_HYPHEN = 0x2011;

/// custom character properties - for char-by-char drawing of text string with different character color and style
struct CustomCharProps {
    uint color;
    uint textFlags;

    this(uint color, bool underline = false, bool strikeThrough = false) {
        this.color = color;
        this.textFlags = 0;
        if (underline)
            this.textFlags |= TextFlag.Underline;
        if (strikeThrough)
            this.textFlags |= TextFlag.StrikeThrough;
    }
}

static if (ENABLE_OPENGL) {

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
enum int MAX_WIDTH_UNSPECIFIED = int.max;

/// Where to truncate text which doesn't fit, replacing the removed part with an ellipsis (as android:ellipsize)
enum TextEllipsis : ubyte {
    /// no truncation (text is clipped)
    None,
    /// "…end of text"
    Start,
    /// "start…end"
    Middle,
    /// "start of text…"
    End,
}

/// Part of text to replace with an ellipsis: text[start .. end]; when truncated is false, text is shown as is
struct EllipsisCut {
    /// index of the first removed character
    size_t start;
    /// index after the last removed character
    size_t end;
    /// true if text is truncated (an ellipsis is inserted at start; end may be equal to start, e.g. for forced ellipsis)
    bool truncated;
}

/**
 * Custom rule to choose the part of text to replace with an ellipsis.
 *
 * Params:
 *      text = the whole text
 *      widths = accumulated widths as returned by Font.measureText: widths[i] is the width of text[0 .. i + 1]
 *      availWidth = width available for the result, including the ellipsis
 *      ellipsisWidth = width of the ellipsis
 */
alias EllipsisCutFinder = EllipsisCut delegate(const dchar[] text, const int[] widths, int availWidth, int ellipsisWidth);

/// Options for text truncation with an ellipsis
struct EllipsisOptions {
    /// where to cut
    TextEllipsis mode = TextEllipsis.End;
    /**
     * Preferred cut points; empty to cut between any characters.
     *
     * The text before the ellipsis is cut after a separator, the text after the ellipsis starts with a separator,
     * e.g. "/\\" for file paths ("/home/user/…/src/app.d") or " " for words.
     */
    dstring separators;
    /// for Middle: share of the available width, in percent, given to the text after the ellipsis
    int endShare = 50;
    /// maximum width, in percent of the available width, to give up to cut at a separator; beyond it, cut between characters
    int separatorTolerance = 30;
    /// custom rule (replaces the built-in ones when set)
    EllipsisCutFinder cutFinder;

    /// cut at word boundaries (spaces)
    static EllipsisOptions words(TextEllipsis mode = TextEllipsis.End) {
        EllipsisOptions res;
        res.mode = mode;
        res.separators = " \t"d;
        return res;
    }
    /// file path: keep the beginning and the end (file name), cut whole path components in the middle
    static EllipsisOptions path() {
        EllipsisOptions res;
        res.mode = TextEllipsis.Middle;
        res.separators = "/\\"d;
        res.endShare = 60;
        res.separatorTolerance = 40;
        return res;
    }
}

/**
 * Find the part of text to replace with an ellipsis so that the result fits availWidth.
 *
 * Uses accumulated widths from a single Font.measureText call; O(N).
 *
 * Params:
 *      text = text to truncate
 *      widths = accumulated widths: widths[i] is the width of text[0 .. i + 1] (at least text.length items)
 *      availWidth = width available for the result, including the ellipsis
 *      ellipsisWidth = width of the ellipsis
 *      opts = where and how to cut
 *      forceEllipsis = for End mode: add the ellipsis even if text fits (e.g. the last visible line of a longer text)
 * Returns: the part to replace; result.truncated is false if text fits as is
 */
EllipsisCut findEllipsisCut(const dchar[] text, const int[] widths, int availWidth, int ellipsisWidth, EllipsisOptions opts, bool forceEllipsis = false) {
    immutable size_t n = text.length;
    assert(widths.length >= n);
    // width of text[0 .. k]
    int startWidth(size_t k) { return k == 0 ? 0 : widths[k - 1]; }
    immutable int total = startWidth(n);
    TextEllipsis mode = opts.mode;
    if (forceEllipsis && mode == TextEllipsis.None)
        mode = TextEllipsis.End;
    if (mode == TextEllipsis.None)
        return EllipsisCut(n, n, false);
    if (total <= availWidth && !forceEllipsis)
        return EllipsisCut(n, n, false);
    if (opts.cutFinder)
        return opts.cutFinder(text, widths[0 .. n], availWidth, ellipsisWidth);
    if (forceEllipsis)
        mode = TextEllipsis.End;
    immutable int avail = availWidth - ellipsisWidth;
    if (avail <= 0)
        return EllipsisCut(0, n, true); // only the ellipsis
    if (forceEllipsis && total <= avail)
        return EllipsisCut(n, n, true); // whole text + ellipsis

    bool isSeparator(dchar ch) {
        foreach (s; opts.separators)
            if (s == ch)
                return true;
        return false;
    }
    // text before the ellipsis may end after a separator
    bool isStartBoundary(size_t k) { return k > 0 && isSeparator(text[k - 1]); }
    // text after the ellipsis may start with a separator
    bool isEndBoundary(size_t k) { return k < n && isSeparator(text[k]); }
    immutable bool useSeparators = opts.separators.length > 0;
    immutable int tolerance = cast(int)(cast(long)avail * opts.separatorTolerance / 100);

    // longest start text[0 .. k], k <= limit, with width <= w
    size_t fitStart(int w, size_t limit) {
        size_t lo = 0, hi = limit;
        while (lo < hi) {
            size_t mid = (lo + hi + 1) / 2;
            if (startWidth(mid) <= w)
                lo = mid;
            else
                hi = mid - 1;
        }
        return lo;
    }
    // longest end text[k .. n], k >= limit, with width <= w
    size_t fitEnd(int w, size_t limit) {
        size_t lo = limit, hi = n;
        while (lo < hi) {
            size_t mid = (lo + hi) / 2;
            if (total - startWidth(mid) <= w)
                hi = mid;
            else
                lo = mid + 1;
        }
        return lo;
    }
    // nearest start boundary <= k losing at most tolerance, or size_t.max
    size_t startBoundary(size_t k) {
        for (size_t j = k; j > 0 && startWidth(k) - startWidth(j) <= tolerance; j--)
            if (isStartBoundary(j))
                return j;
        return size_t.max;
    }
    // nearest end boundary >= k losing at most tolerance, or size_t.max
    size_t endBoundary(size_t k) {
        for (size_t j = k; j < n && startWidth(j) - startWidth(k) <= tolerance; j++)
            if (isEndBoundary(j))
                return j;
        return size_t.max;
    }

    final switch (mode) {
        case TextEllipsis.None:
            assert(false);
        case TextEllipsis.End: {
            size_t a = fitStart(avail, n);
            if (useSeparators) {
                size_t sb = startBoundary(a);
                if (sb != size_t.max)
                    a = sb;
            }
            return EllipsisCut(a, n, true);
        }
        case TextEllipsis.Start: {
            size_t b = fitEnd(avail, 0);
            if (useSeparators) {
                size_t eb = endBoundary(b);
                if (eb != size_t.max)
                    b = eb;
            }
            return EllipsisCut(0, b, true);
        }
        case TextEllipsis.Middle: {
            int share = opts.endShare < 0 ? 0 : (opts.endShare > 100 ? 100 : opts.endShare);
            int endBudget = cast(int)(cast(long)avail * share / 100);
            // char level: end part by its share, start part takes the rest, then the end part takes what is left
            size_t b = fitEnd(endBudget, 0);
            size_t a = fitStart(avail - (total - startWidth(b)), b);
            b = fitEnd(avail - startWidth(a), a);
            if (useSeparators) {
                // both sides at separators: among pairs within tolerance of the char level split,
                // keep the most text (ties: the longer end); two pointers, O(N)
                immutable int startTarget = startWidth(a);
                immutable int endTarget = total - startWidth(b);
                size_t bestA = size_t.max, bestB = n;
                int bestKept = -1, bestEnd = -1;
                size_t bp = 0;
                for (size_t ai = 1; ai <= n; ai++) {
                    if (!isStartBoundary(ai))
                        continue;
                    immutable int sw = startWidth(ai);
                    if (sw < startTarget - tolerance)
                        continue;
                    if (sw > startTarget + tolerance || sw > avail)
                        break;
                    if (bp < ai)
                        bp = ai;
                    // first end boundary that fits next to this start and isn't too long
                    while (bp < n && !(isEndBoundary(bp) && total - startWidth(bp) <= avail - sw
                                       && total - startWidth(bp) <= endTarget + tolerance))
                        bp++;
                    if (bp >= n)
                        break;
                    immutable int ew = total - startWidth(bp);
                    if (ew < endTarget - tolerance)
                        break; // a longer start only makes the end shorter
                    if (sw + ew > bestKept || (sw + ew == bestKept && ew > bestEnd)) {
                        bestKept = sw + ew;
                        bestEnd = ew;
                        bestA = ai;
                        bestB = bp;
                    }
                }
                size_t sa = startBoundary(a);
                size_t sb = endBoundary(b);
                if (bestA != size_t.max) {
                    a = bestA;
                    b = bestB;
                } else if (sa != size_t.max) {
                    a = sa;
                    b = fitEnd(avail - startWidth(a), a);
                } else if (sb != size_t.max) {
                    b = sb;
                    a = fitStart(avail - (total - startWidth(b)), b);
                }
            }
            return EllipsisCut(a, b, true);
        }
    }
}

unittest {
    // fixed width 10 per character; ellipsis width 10
    int[] w(dstring s) {
        int[] res;
        foreach (i; 0 .. s.length)
            res ~= cast(int)(i + 1) * 10;
        return res;
    }
    dstring apply(dstring s, EllipsisCut c) {
        return c.truncated ? s[0 .. c.start] ~ "…"d ~ s[c.end .. $] : s;
    }
    EllipsisOptions opts;
    dstring s = "abcdefghij"d; // width 100
    // fits
    opts.mode = TextEllipsis.End;
    assert(!findEllipsisCut(s, w(s), 100, 10, opts).truncated);
    opts.mode = TextEllipsis.None;
    assert(!findEllipsisCut(s, w(s), 50, 10, opts).truncated);
    // char level
    opts.mode = TextEllipsis.End;
    assert(apply(s, findEllipsisCut(s, w(s), 55, 10, opts)) == "abcd…"d);
    opts.mode = TextEllipsis.Start;
    assert(apply(s, findEllipsisCut(s, w(s), 55, 10, opts)) == "…ghij"d);
    opts.mode = TextEllipsis.Middle;
    assert(apply(s, findEllipsisCut(s, w(s), 50, 10, opts)) == "ab…ij"d);
    assert(apply(s, findEllipsisCut(s, w(s), 60, 10, opts)) == "abc…ij"d);
    opts.endShare = 100;
    assert(apply(s, findEllipsisCut(s, w(s), 50, 10, opts)) == "…ghij"d);
    opts.endShare = 0;
    assert(apply(s, findEllipsisCut(s, w(s), 50, 10, opts)) == "abcd…"d);
    // too narrow even for the ellipsis
    opts = EllipsisOptions.init;
    assert(apply(s, findEllipsisCut(s, w(s), 5, 10, opts)) == "…"d);
    // forced ellipsis
    assert(apply(s, findEllipsisCut(s, w(s), 200, 10, opts, true)) == "abcdefghij…"d);
    assert(apply(s, findEllipsisCut(s, w(s), 100, 10, opts, true)) == "abcdefghi…"d);
    // words: cut after a space when within tolerance
    dstring t = "hello brave new world"d; // width 210
    opts = EllipsisOptions.words();
    assert(apply(t, findEllipsisCut(t, w(t), 150, 10, opts)) == "hello brave …"d); // trailing space is trimmed by Font.ellipsize
    opts.separatorTolerance = 0;
    assert(apply(t, findEllipsisCut(t, w(t), 150, 10, opts)) == "hello brave ne…"d);
    opts = EllipsisOptions.words(TextEllipsis.Start);
    assert(apply(t, findEllipsisCut(t, w(t), 150, 10, opts)) == "… new world"d);
    // path
    dstring p = "/home/user/projects/app/src/main.d"d;
    opts = EllipsisOptions.path();
    assert(apply(p, findEllipsisCut(p, w(p), 250, 10, opts)) == "/home/user/…/src/main.d"d);
    assert(apply(p, findEllipsisCut(p, w(p), 200, 10, opts)) == "/home/user/…/main.d"d);
    assert(apply(p, findEllipsisCut(p, w(p), 150, 10, opts)) == "/home/…/main.d"d);
    // file name alone is too long: falls back to a cut between characters
    dstring q = "/a/verylongfilename_without_separators.d"d;
    auto cq = findEllipsisCut(q, w(q), 150, 10, opts);
    assert(cq.truncated && apply(q, cq).length == 15);
    // custom rule
    opts = EllipsisOptions.init;
    opts.cutFinder = delegate(const dchar[] text, const int[] widths, int availWidth, int ellipsisWidth) {
        return EllipsisCut(1, text.length - 1, true);
    };
    assert(apply(s, findEllipsisCut(s, w(s), 50, 10, opts)) == "a…j"d);
}

/** Instance of font with specific size, weight, face, etc.
 *
 * Allows to measure text string and draw it on DrawBuf
 *
 * Use FontManager.instance.getFont() to retrieve font instance.
 */
class Font : RefCountedObject {

    this() {
        _textSizeBuffer.reserve(100);
        _textSizeBuffer.assumeSafeAppend();
    }
    ~this() { clear(); }


    /// returns font size (as requested from font engine)
    abstract @property int size();
    /// returns actual font height including interline space
    abstract @property int height();
    /// returns font weight
    abstract @property int weight();
    /// returns baseline offset
    abstract @property int baseline();

    protected int _capHeight = -1;
    /// height of the capital letters above the baseline (top of 'H'), in pixels (#856); between 0 and baseline
    @property int capHeight() {
        if (_capHeight < 0) {
            int b = baseline;
            Glyph * g = getCharGlyph('H', false);
            int h = g !is null && g.originY > 0 ? g.originY : b * 7 / 10;
            _capHeight = h > b ? b : (h < 0 ? 0 : h);
        }
        return _capHeight;
    }
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

    protected int _spaceWidth = -1;

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
        return !g ? 0 : g.widthPixels;
    }

    protected bool _allowKerning;
    /// override to enable kerning support
    @property bool allowKerning() {
        return false;
    }
    /// override to enable kerning support
    @property void allowKerning(bool allow) {
        _allowKerning = allow;
    }

    /// override to implement kerning offset calculation
    int getKerningOffset(dchar prevChar, dchar currentChar) {
        return 0;
    }

    /*******************************************************************************************
     * Measure text string, return accumulated widths[] (distance to end of n-th character), returns number of measured chars.
     *
     * Supports Tab character processing and processing of menu item labels like '&File'.
     *
     * Params:
     *          text = text string to measure
     *          widths = output buffer to put measured widths (widths[i] will be set to cumulative widths text[0..i], see also _textSizeBuffer description)
     *          maxWidth = maximum width to measure - measure is stopping if max width is reached (pass MAX_WIDTH_UNSPECIFIED to measure all characters)
     *          tabSize = tabulation size, in number of spaces
     *          tabOffset = when string is drawn not from left position, use to move tab stops left/right
     *          textFlags = TextFlag bit set - to control underline, hotkey label processing, etc...
     * Returns:
     *          number of characters measured (may be less than text.length if maxWidth is reached)
     ******************************************************************************************/
    int measureText(const dchar[] text, ref int[] widths, int maxWidth = MAX_WIDTH_UNSPECIFIED, int tabSize = 4, int tabOffset = 0, uint textFlags = 0) {
        if (text.length == 0)
            return 0;
        const dchar * pstr = text.ptr;
        uint len = cast(uint)text.length;
        if (widths.length < len) {
            widths.assumeSafeAppend;
            widths.length = len + 16;
        }
        bool fixed = isFixed;
        bool useKerning = allowKerning && !fixed;
        int fixedCharWidth = charWidth('M');
        if (fixedCharWidth == 0)
            fixedCharWidth = spaceWidth;
        int x = 0; // position in pixels: x64 rounded
        int x64 = 0; // position in 1/64 pixel: advances and kerning are added without rounding them (#861)
        int charsMeasured = 0;
        int * pwidths = widths.ptr;
        int spWidth = fixed ? fixedCharWidth : spaceWidth;
        int tabWidth = spWidth * tabSize; // width of full tab in pixels
        tabOffset = tabOffset % tabWidth;
        if (tabOffset < 0)
            tabOffset += tabWidth;
        dchar prevChar = 0;
        foreach(int i; 0 .. len) {
            //auto measureStart = std.datetime.Clock.currAppTick;
            dchar ch = pstr[i];
            if (ch == '\t') {
                // measure tab
                int tabPosition = (x + tabWidth - tabOffset) / tabWidth * tabWidth + tabOffset;
                while (tabPosition < x + spWidth)
                    tabPosition += tabWidth;
                pwidths[i] = tabPosition;
                charsMeasured = i + 1;
                x = tabPosition;
                x64 = x << 6;
                prevChar = 0;
                continue;
            } else if (ch == '&' && (textFlags & (TextFlag.UnderlineHotKeys | TextFlag.HotKeys | TextFlag.UnderlineHotKeysWhenAltPressed))) {
                pwidths[i] = x;
                prevChar = 0;
                continue; // skip '&' in hot key when measuring
            }
            if (fixed) {
                // fast calculation for fixed pitch
                x += fixedCharWidth;
                x64 = x << 6;
                pwidths[i] = x;
                charsMeasured = i + 1;
            } else {
                Glyph * glyph = getCharGlyph(pstr[i], true); // TODO: what is better
                //auto measureEnd = std.datetime.Clock.currAppTick;
                //auto duration = measureEnd - measureStart;
                //if (duration.length > 10)
                //    Log.d("ft measureText took ", duration.length, " ticks");
                if (glyph is null) {
                    // if no glyph, use previous width - treat as zero width
                    pwidths[i] = x;
                    prevChar = 0;
                    continue;
                }
                // kerning between the previous character and this one moves this one (#863): glyph i is drawn
                // at widths[i - 1], so that boundary (also the caret position between them) is moved
                if (useKerning && prevChar) {
                    int kerningDelta = getKerningOffset(prevChar, ch); // 1/64 pixel
                    if (kerningDelta) {
                        x64 += kerningDelta;
                        int kx = roundPosition(x64);
                        if (kx != x) {
                            x = kx;
                            pwidths[i - 1] = x;
                        }
                    }
                }
                // the advance, in 1/64 pixel; not rounded per glyph, which made text wider (#861)
                int advance = glyph.widthScaled;
                // at least as wide as the glyph's black box, so that the next glyph doesn't overlap it; not for
                // subpixel glyphs, whose bitmap is wider than the ink (LCD filter), which made some glyphs wider
                if (!glyph.subpixelMode && advance < ((glyph.originX + glyph.correctedBlackBoxX) << 6))
                    advance = (glyph.originX + glyph.correctedBlackBoxX) << 6;
                x64 += advance;
                x = roundPosition(x64);
                pwidths[i] = x;
                charsMeasured = i + 1;
            }
            if (x > maxWidth)
                break;
            prevChar = ch;
        }
        return charsMeasured;
    }

    /// position in 1/64 pixel rounded to pixels
    private static int roundPosition(int pos64) pure nothrow @nogc @safe {
        return pos64 >= 0 ? (pos64 + 32) >> 6 : -((-pos64 + 32) >> 6);
    }

    /*************************************************************************
     * Buffer to reuse while measuring strings to avoid GC
     *
     * This array store character widths cumulatively.
     * For example, after measure of monospaced 10-pixel-width font line
     * "abc def" _textSizeBuffer should contain something like:
     * [10, 20, 30, 40, 50, 60, 70]
     ************************************************************************/
    protected int[] _textSizeBuffer;

    /*************************************************************************
     * Measure text string as single line, returns width and height
     *
     * Params:
     *          text = text string to measure
     *          maxWidth = maximum width - measure is stopping if max width is reached
     *          tabSize = tabulation size, in number of spaces
     *          tabOffset = when string is drawn not from left position, use to move tab stops left/right
     *          textFlags = TextFlag bit set - to control underline, hotkey label processing, etc...
     ************************************************************************/
    Point textSize(dstring text, int maxWidth = MAX_WIDTH_UNSPECIFIED, int tabSize = 4, int tabOffset = 0, uint textFlags = 0) {
        return textSizeMemoized(this, text, maxWidth, tabSize, tabOffset, textFlags);
    }

    import std.functional;
    alias textSizeMemoized = memoize!(Font.textSizeImpl);

    static Point textSizeImpl(Font font, const dchar[] text, int maxWidth = MAX_WIDTH_UNSPECIFIED, int tabSize = 4, int tabOffset = 0, uint textFlags = 0) {
        if (font._textSizeBuffer.length < text.length + 1)
            font._textSizeBuffer.length = text.length + 1;
        int charsMeasured = font.measureText(text, font._textSizeBuffer, maxWidth, tabSize, tabOffset, textFlags);
        if (charsMeasured < 1)
            return Point(0,0);
        return Point(font._textSizeBuffer[charsMeasured - 1], font.height);
    }

    protected dstring _ellipsisText;
    protected int _ellipsisWidth = -1;
    protected int[] _ellipsisWidthsBuffer;

    /// ellipsis string used by ellipsize(): "…", or "..." if the font has no glyph for U+2026
    @property dstring ellipsisText() {
        if (!_ellipsisText.length)
            _ellipsisText = getCharGlyph('…', true) !is null ? "…"d : "..."d;
        return _ellipsisText;
    }

    /// width of ellipsisText, in pixels
    @property int ellipsisWidth() {
        if (_ellipsisWidth < 0) {
            dstring e = ellipsisText;
            int n = measureText(e, _ellipsisWidthsBuffer);
            _ellipsisWidth = n > 0 ? _ellipsisWidthsBuffer[n - 1] : 0;
        }
        return _ellipsisWidth;
    }

    /**
     * Truncate single line text to fit maxWidth, replacing the removed part with an ellipsis (see EllipsisOptions).
     *
     * Measures the text once and finds the cut with findEllipsisCut (O(N)). Returns text itself (no allocation) if it fits.
     *
     * Params:
     *      text = text to truncate (single line)
     *      maxWidth = available width in pixels
     *      opts = where and how to cut
     *      tabSize = tabulation size, in number of spaces
     *      textFlags = TextFlag bit set (hot key '&' prefixes are not counted, and are not left right before the ellipsis)
     *      forceEllipsis = add the ellipsis at the end even if text fits (e.g. last visible line of a longer text)
     *      resultWidthPtr = if not null, receives the width of the result
     */
    dstring ellipsize(dstring text, int maxWidth, EllipsisOptions opts, int tabSize = 4, uint textFlags = 0, bool forceEllipsis = false, int* resultWidthPtr = null) {
        int resultWidthDummy;
        int* resultWidth = resultWidthPtr ? resultWidthPtr : &resultWidthDummy;
        int measure(const dchar[] s) {
            if (_textSizeBuffer.length < s.length + 1)
                _textSizeBuffer.length = s.length + 1;
            int n = measureText(s, _textSizeBuffer, MAX_WIDTH_UNSPECIFIED, tabSize, 0, textFlags);
            return n > 0 ? _textSizeBuffer[n - 1] : 0;
        }
        *resultWidth = measure(text);
        if (opts.mode == TextEllipsis.None && !forceEllipsis)
            return text;
        if (*resultWidth <= maxWidth && !forceEllipsis)
            return text;
        immutable bool hotKeys = (textFlags & (TextFlag.HotKeys | TextFlag.UnderlineHotKeys | TextFlag.UnderlineHotKeysWhenAltPressed)) != 0;
        dstring e = ellipsisText;
        EllipsisCut cut = findEllipsisCut(text, _textSizeBuffer, maxWidth, ellipsisWidth, opts, forceEllipsis);
        if (!cut.truncated)
            return text;
        size_t s = cut.start, en = cut.end;
        // build the result; adjust if it's still too wide (kerning next to the ellipsis, tabs moved by a cut)
        for (int attempt = 0; ; attempt++) {
            size_t ps = s, pe = en;
            while (ps > 0 && (text[ps - 1] == ' ' || text[ps - 1] == '\t'))
                ps--;
            if (hotKeys && ps > 0 && text[ps - 1] == '&')
                ps--; // don't underline the ellipsis
            while (pe < text.length && (text[pe] == ' ' || text[pe] == '\t'))
                pe++;
            dstring res = text[0 .. ps] ~ e ~ text[pe .. $];
            *resultWidth = measure(res);
            if (*resultWidth <= maxWidth || attempt >= 16 || (s == 0 && en >= text.length))
                return res;
            // remove one more character: from the end of the start part, or from the start of the end part
            if (s > 0 && (opts.mode != TextEllipsis.Start || en >= text.length))
                s--;
            else if (en < text.length)
                en++;
            else
                s--;
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
        foreach(int i; 0 .. charsMeasured) {
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
    *      charProps =  array of character properties, charProps[i] are properties for character text[i]
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
        foreach(int i; 0 .. charsMeasured) {
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

}

unittest {
    // kerning in measureText (#863): a pair moves the second character, and the boundary between them
    static class KerningTestFont : Font {
        Glyph[dchar] _glyphs;
        this() {
            foreach (ch, w; ['T': 10, 'o': 8, 'A': 10, 'V': 10, ' ': 4, 'i': 3, 'M': 12]) {
                Glyph g;
                g.blackBoxX = cast(ushort)(w - 1);
                g.blackBoxY = 10;
                g.originX = 0;
                g.originY = 10;
                g.widthPixels = cast(ubyte)w;
                g.widthScaled = cast(ushort)(w << 6);
                _glyphs[ch] = g;
            }
            // fractional advance, 5.5 px (#861)
            Glyph f;
            f.blackBoxX = 4; f.blackBoxY = 10; f.originY = 10;
            f.widthPixels = 6; f.widthScaled = 5 * 64 + 32;
            _glyphs['f'] = f;
            // subpixel glyph: 7 px advance, bitmap 3 * 9 subpixels wide (with LCD filter padding)
            Glyph l;
            l.blackBoxX = 27; l.blackBoxY = 10; l.originY = 10; l.subpixelMode = SubpixelRenderingMode.RGB;
            l.widthPixels = 7; l.widthScaled = 7 * 64;
            _glyphs['l'] = l;
        }
        override @property int size() { return 12; }
        override @property int height() { return 14; }
        override @property int weight() { return 400; }
        override @property int baseline() { return 11; }
        override @property bool italic() { return false; }
        override @property string face() { return "test"; }
        override @property FontFamily family() { return FontFamily.SansSerif; }
        override @property bool isNull() { return false; }
        override Glyph * getCharGlyph(dchar ch, bool withImage = true) { return ch in _glyphs; }
        override void checkpoint() {}
        override void cleanup() {}
        override void clearGlyphCache() {}
        override @property bool allowKerning() { return true; }
        override int getKerningOffset(dchar prevChar, dchar currentChar) {
            if (prevChar == 'T' && currentChar == 'o') return -3 * 64;
            if (prevChar == 'A' && currentChar == 'V') return -2 * 64 - 20; // rounded to -2
            return 0;
        }
    }
    auto font = new KerningTestFont();
    int[] w;
    font.measureText("To"d, w);
    assert(w[0] == 7 && w[1] == 15); // o starts 3 px earlier
    font.measureText("oT"d, w);
    assert(w[0] == 8 && w[1] == 18); // no pair o->T
    font.measureText("AVA"d, w);
    assert(w[0] == 8 && w[1] == 18 && w[2] == 28);
    // fractional advances are added before rounding (#861): 5.5 + 5.5 + 5.5 px
    font.measureText("fff"d, w);
    assert(w[0] == 6 && w[1] == 11 && w[2] == 17); // rounding each glyph up made it 6, 12, 18
    // a subpixel glyph keeps its advance although its bitmap is wider
    font.measureText("ll"d, w);
    assert(w[0] == 7 && w[1] == 14);
    destroy(font);
}
alias FontRef = Ref!Font;

/// helper to split text into several lines and draw it
struct SimpleTextFormatter {
    dstring[] _lines;
    int[] _linesWidths;
    int _maxLineWidth;
    int _tabSize;
    int _tabOffset;
    uint _textFlags;
    /// true if the last format() call cut the text by maxLines
    bool _truncated;
    /// split text into lines and measure it; returns size in pixels
    /// (ellipsis: if not None and text is cut by maxLines, the last line ends with an ellipsis, cut at a word boundary if possible)
    Point format(const dchar[] text, FontRef fnt, int maxLines = 0, int maxWidth = 0, int tabSize = 4, int tabOffset = 0, uint textFlags = 0, TextEllipsis ellipsis = TextEllipsis.None) {
        _tabSize = tabSize;
        _tabOffset = tabOffset;
        _textFlags = textFlags;
        Point sz;
        _lines.length = 0;
        _linesWidths.length = 0;
        _truncated = false;
        int lineHeight = fnt.height;
        if (text.length == 0) {
            sz.y = lineHeight;
            return sz;
        }
        int[] widths;
        int charsMeasured = fnt.measureText(text, widths, MAX_WIDTH_UNSPECIFIED, _tabSize, _tabOffset, _textFlags);
        int lineStart = 0;
        int lineStartX = 0;
        int lastLineStart = 0; // start of the last added line
        bool truncated = false; // text is cut by maxLines
        int lastWordEnd = 0;
        int lastWordEndX = 0;
        dchar prevChar = 0;
        foreach(int i; 0 .. charsMeasured + 1) {
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
                _linesWidths ~= lineWidth;
                lastLineStart = lineStart;
                if (i == charsMeasured) // end of text reached
                    break;

                // check max lines constraint
                if (maxLines && _lines.length >= maxLines) { // max lines reached
                    truncated = i + 1 < charsMeasured;
                    break;
                }

                lineStart = i + 1;
                lineStartX = widths[i];
            } else {
                // split by width
                int x = widths[i];
                if (ch == '\t' || ch == ' ') {
                    // track last word end
                    if (prevChar != '\t' && prevChar != ' ' && prevChar != 0) {
                        lastWordEnd = i;
                        lastWordEndX = widths[i];
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
                    dstring line = cast(dstring)text[lineStart .. lineEnd]; //lastWordEnd];
                    int lineWidth = lineEndX - lineStartX;
                    sz.y += lineHeight;
                    if (sz.x < lineWidth)
                        sz.x = lineWidth;
                    _lines ~= line;
                    _linesWidths ~= lineWidth;
                    lastLineStart = lineStart;

                    // check max lines constraint
                    if (maxLines && _lines.length >= maxLines) { // max lines reached
                        foreach (j; lineEnd .. charsMeasured)
                            if (text[j] != ' ' && text[j] != '\t' && text[j] != '\n') {
                                truncated = true;
                                break;
                            }
                        break;
                    }

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
        _truncated = truncated;
        if (truncated && ellipsis != TextEllipsis.None && _lines.length) {
            // last line: as much of its paragraph as fits, then the ellipsis
            size_t paraEnd = lastLineStart;
            while (paraEnd < charsMeasured && text[paraEnd] != '\n')
                paraEnd++;
            int avail = (maxWidth > 0 && maxWidth != MAX_WIDTH_UNSPECIFIED) ? maxWidth : MAX_WIDTH_UNSPECIFIED;
            int w;
            _lines[$ - 1] = fnt.ellipsize(cast(dstring)text[lastLineStart .. paraEnd], avail, EllipsisOptions.words(TextEllipsis.End),
                                          _tabSize, _textFlags, true, &w);
            _linesWidths[$ - 1] = w;
            sz.x = 0;
            foreach (lw; _linesWidths)
                if (sz.x < lw)
                    sz.x = lw;
        }
        _maxLineWidth = sz.x;
        return sz;
    }
    /// draw formatted text
    void draw(DrawBuf buf, int x, int y, FontRef fnt, uint color) {
        int lineHeight = fnt.height;
        foreach(line; _lines) {
            fnt.drawText(buf, x, y, line, color, _tabSize, _tabOffset, _textFlags);
            y += lineHeight;
        }
    }

    /// draw horizontaly aligned formatted text
    void draw(DrawBuf buf, int x, int y, FontRef fnt, uint color, ubyte alignment) {
        int lineHeight = fnt.height;
        dstring line;
        int lineWidth;
        for (int i = 0 ; i < _lines.length ; i++) {
            line = _lines[i];
            lineWidth = _linesWidths[i];
            if ((alignment & Align.HCenter) == Align.HCenter) {
                fnt.drawText(buf, x + (_maxLineWidth - lineWidth) / 2, y, line, color, _tabSize, _tabOffset, _textFlags);
            }
            else if (alignment & Align.Left) {
                fnt.drawText(buf, x, y, line, color, _tabSize, _tabOffset, _textFlags);
            }
            else if (alignment & Align.Right) {
                fnt.drawText(buf, x + _maxLineWidth - lineWidth, y, line, color, _tabSize, _tabOffset, _textFlags);
            }
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
        foreach(i; 0 .. _len) {
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
        foreach(int i; 0 .. _len) {
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
        foreach(int i; 0 .. _len) {
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
        foreach(i; 0 .. _len)
            if (_list[i].refCount <= 1)
                _list[i].clear();
        uint dst = 0;
        foreach(i; 0 .. _len) {
            if (!_list[i].isNull)
                if (i != dst)
                    _list[dst++] = _list[i];
        }
        _len = dst;
        foreach(i; 0 .. _len)
            _list[i].cleanup();
    }
    void checkpoint() {
        foreach(i; 0 .. _len)
            _list[i].checkpoint();
    }
    /// clears glyph cache
    void clearGlyphCache() {
        foreach(i; 0 .. _len)
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

/// font face properties item
struct FontFaceProps {
    /// font face name
    string face;
    /// font family
    FontFamily family;
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

    /// override to return list of font faces available
    FontFaceProps[] getFaces() {
        return null;
    }

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
        double gamma = clamp(v, 0.1, 4);
        if (_fontGamma != gamma) {
            _fontGamma = gamma;
            _gamma65.gamma = gamma;
            _gamma256.gamma = gamma;
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
    glyph_ptr find(dchar ch) {
        ch = ch & 0xF_FFFF;
        //if (_array is null)
        //    _array = new Glyph[0x10000];
        uint p = ch >> 8;
        glyph_ptr[] row = _glyphs[p];
        if (row is null)
            return null;
        uint i = ch & 0xFF;
        glyph_ptr res = row[i];
        if (!res)
            return null;
        res.lastUsage = 1;
        return res;
    }

    /// put character glyph to cache
    glyph_ptr put(dchar ch, glyph_ptr glyph) {
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
                    static if (ENABLE_OPENGL) {
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
                    static if (ENABLE_OPENGL) {
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
class glyph_gamma_table(int maxv = 65)
{
    this(double gammaValue = 1.0)
    {
        gamma(gammaValue);
    }
    @property double gamma() { return _gamma; }
    @property void gamma(double g) {
        _gamma = g;
        foreach(int i; 0 .. maxv)
        {
            double v = (maxv - 1.0 - i) / maxv;
            v = pow(v, g);
            int n = 255 - cast(int)round(v * 255);
            ubyte n_clamp = cast(ubyte)clamp(n, 0, 255);
            _map[i] = n_clamp;
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
}

/// find some suitable replacement for important characters missing in font
dchar getReplacementChar(dchar code) {
    switch (code) {
        case UNICODE_SOFT_HYPHEN_CODE:
            return '-';
        case 0x0401: // CYRILLIC CAPITAL LETTER IO
            return 0x0415; //CYRILLIC CAPITAL LETTER IE
        case 0x0451: // CYRILLIC SMALL LETTER IO
            return 0x0435; // CYRILLIC SMALL LETTER IE
        case UNICODE_NO_BREAK_SPACE:
            return ' ';
        case 0x2010:
        case 0x2011:
        case 0x2012:
        case 0x2013:
        case 0x2014:
        case 0x2015:
            return '-';
        case 0x2018:
        case 0x2019:
        case 0x201a:
        case 0x201b:
            return '\'';
        case 0x201c:
        case 0x201d:
        case 0x201e:
        case 0x201f:
        case 0x00ab:
        case 0x00bb:
            return '\"';
        case 0x2039:
            return '<';
        case 0x203A:
        case '‣':
        case '►':
            return '>';
        case 0x2044:
            return '/';
        case 0x2022: // css_lst_disc:
            return '*';
        case 0x26AA: // css_lst_disc:
        case 0x25E6: // css_lst_disc:
        case 0x25CF: // css_lst_disc:
            return 'o';
        case 0x25CB: // css_lst_circle:
            return '*';
        case 0x25A0: // css_lst_square:
            return '-';
        case '↑': //
            return '▲';
        case '↓': //
            return '▼';
        case '▲': //
            return '^';
        case '▼': //
            return 'v';
        default:
            return 0;
    }
}

__gshared glyph_gamma_table!65 _gamma65;
__gshared glyph_gamma_table!256 _gamma256;
