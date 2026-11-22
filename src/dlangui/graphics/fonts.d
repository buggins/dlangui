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
import core.stdc.stdlib : calloc, free;
import core.exception : onOutOfMemoryError;

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
    // opts.cutFinder is a delegate without attributes; the built-in rules are @safe (#915)
    if (opts.cutFinder) {
        immutable size_t n = text.length;
        assert(widths.length >= n);
        TextEllipsis mode = opts.mode;
        if (forceEllipsis && mode == TextEllipsis.None)
            mode = TextEllipsis.End;
        if (mode == TextEllipsis.None || ((n ? widths[n - 1] : 0) <= availWidth && !forceEllipsis))
            return EllipsisCut(n, n, false);
        return opts.cutFinder(text, widths[0 .. n], availWidth, ellipsisWidth);
    }
    return builtinEllipsisCut(text, widths, availWidth, ellipsisWidth, opts, forceEllipsis);
}

/// the built-in rules of findEllipsisCut (no opts.cutFinder)
private EllipsisCut builtinEllipsisCut(const dchar[] text, const int[] widths, int availWidth, int ellipsisWidth, ref const EllipsisOptions opts, bool forceEllipsis) @safe pure nothrow @nogc {
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

// the built-in rules are @safe pure nothrow @nogc (#915); findEllipsisCut may call a custom delegate
@safe pure nothrow @nogc unittest {
    static immutable int[5] widths = [10, 20, 30, 40, 50];
    EllipsisOptions opts;
    EllipsisCut fits = builtinEllipsisCut("abcde"d, widths[], 50, 10, opts, false);
    assert(!fits.truncated);
    EllipsisCut cut = builtinEllipsisCut("abcde"d, widths[], 35, 10, opts, false);
    assert(cut.truncated && cut.start == 2 && cut.end == 5);
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
    ~this() {
        if (inGCFinalizer()) return; // finalized by the GC: a leak, touch nothing (#975)
        clear();
        _fallbackFonts.clear();
    }


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
        checkMetricsCache();
        if (_capHeight < 0) {
            int b = baseline;
            Glyph * g = getCharGlyph('H', false);
            int h = g !is null && g.originY > 0 ? g.originY : b * 7 / 10;
            _capHeight = h > b ? b : (h < 0 ? 0 : h);
        }
        return _capHeight;
    }

    protected int _xHeight = -1;
    /// height of the lowercase letters above the baseline (top of 'x'), in pixels; between 0 and capHeight
    @property int xHeight() {
        checkMetricsCache();
        if (_xHeight < 0) {
            int c = capHeight;
            Glyph * g = getCharGlyph('x', false);
            int h = g !is null && g.originY > 0 ? g.originY : c * 7 / 10;
            _xHeight = h > c ? c : (h < 0 ? 0 : h);
        }
        return _xHeight;
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
        checkMetricsCache();
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
        if (_allowKerning != allow) {
            _allowKerning = allow;
            clearMetricsCache();
        }
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
        checkMetricsCache();
        const dchar * pstr = text.ptr;
        uint len = cast(uint)text.length;
        if (widths.length < len) {
            widths.assumeSafeAppend;
            widths.length = len + 16;
        }
        // pen positions in 1/64 pixel for drawText (#878)
        _textPos64Valid = false;
        if (_textPos64Buffer.length < len)
            _textPos64Buffer.length = len + 16;
        int * ppos64 = _textPos64Buffer.ptr;
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
        bool prevOwn = false; // prevChar is drawn with a glyph of this font, not of a fallback font
        foreach(int i; 0 .. len) {
            //auto measureStart = std.datetime.Clock.currAppTick;
            dchar ch = pstr[i];
            ppos64[i] = x64;
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
                // fast calculation for fixed pitch: whole cells, 2 for East Asian wide characters (#888)
                x += fixedCharWidth * charCells(ch);
                x64 = x << 6;
                pwidths[i] = x;
                charsMeasured = i + 1;
            } else {
                _lastGlyphFromFallback = false;
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
                // no kerning with glyphs of fallback fonts (#888)
                bool own = !_lastGlyphFromFallback;
                if (useKerning && prevChar && own && prevOwn) {
                    int kerningDelta = getKerningOffset(prevChar, ch); // 1/64 pixel
                    if (kerningDelta) {
                        x64 += kerningDelta;
                        ppos64[i] = x64;
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
                prevOwn = own;
            }
            if (x > maxWidth)
                break;
            prevChar = ch;
        }
        _textPos64Valid = true;
        return charsMeasured;
    }

    /// pen position of each character measured by the last measureText() call, in 1/64 pixel: the position the
    /// glyph is drawn at (after kerning), not rounded to pixels; valid only if _textPos64Valid (#878)
    protected int[] _textPos64Buffer;
    /// true if _textPos64Buffer holds positions for the last measureText() call (false for fonts that override it)
    protected bool _textPos64Valid;

    /// draw glyph of the character measured at index i by the last measureText() call at x + xx (in pixels);
    /// subpixel glyphs are placed with 1/3 pixel precision from the unrounded pen position (#878)
    protected final void drawMeasuredGlyph(DrawBuf buf, int x, int y, int i, int xx, Glyph * glyph, uint color) {
        // fixed pitch: glyph centered in its cells, e.g. a glyph of a fallback font (#888)
        if (isFixed && glyph.widthPixels) { // not zero width glyphs like combining marks
            int cellsWidth = _textSizeBuffer[i] - xx;
            x += (cellsWidth - glyph.widthPixels) / 2;
        }
        if (glyph.subpixelMode && _textPos64Valid) {
            // pen position in subpixels: whole pixels and a phase of 0..2 subpixels
            int sub = (_textPos64Buffer[i] * 3 + 32) >> 6;
            int px = sub >= 0 ? sub / 3 : -((-sub + 2) / 3);
            buf.drawSubpixelGlyph(x + px + glyph.originX, y, glyph, color, sub - px * 3);
        } else {
            buf.drawGlyph(x + xx + glyph.originX, y, glyph, color);
        }
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
        checkMetricsCache();
        TextSizeKey key = TextSizeKey(text, maxWidth, tabSize, tabOffset, textFlags);
        if (auto p = key in _textSizeCache)
            return *p;
        Point res = textSizeImpl(this, text, maxWidth, tabSize, tabOffset, textFlags);
        if (_textSizeCache.length >= TEXT_SIZE_CACHE_MAX_ITEMS)
            _textSizeCache.clear();
        _textSizeCache[key] = res;
        return res;
    }

    /// max number of text sizes cached by a font; the cache is cleared when full
    enum TEXT_SIZE_CACHE_MAX_ITEMS = 1024;

    private static struct TextSizeKey {
        dstring text;
        int maxWidth;
        int tabSize;
        int tabOffset;
        uint textFlags;
    }
    /// text sizes measured by textSize(), per font instance (#888)
    private Point[TextSizeKey] _textSizeCache;
    /// FontManager._glyphSettingsGeneration the cached text sizes and metrics were measured for
    private uint _metricsGeneration;

    /// drops cached text sizes and metrics if glyph settings changed since they were measured
    private void checkMetricsCache() {
        if (_metricsGeneration != FontManager._glyphSettingsGeneration)
            clearMetricsCache();
    }

    /// drops cached text sizes and metrics (space, ellipsis and capitals sizes); call when glyph widths change
    protected void clearMetricsCache() {
        _metricsGeneration = FontManager._glyphSettingsGeneration;
        _textSizeCache.clear();
        _capHeight = -1;
        _xHeight = -1;
        _spaceWidth = -1;
        _ellipsisWidth = -1;
    }

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
        checkMetricsCache();
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
                if (gx + glyph.correctedBlackBoxX + 1 < clip.left)
                    continue;
                drawMeasuredGlyph(buf, x, y + _baseline - glyph.originY, i, xx, glyph, color);
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
                if (gx + glyph.correctedBlackBoxX + 1 < clip.left)
                    continue;
                drawMeasuredGlyph(buf, x, y + _baseline - glyph.originY, i, xx, glyph, color);
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


    /**
        Returns glyph for character ch: the font's own glyph; if the font has no glyph for it, a glyph of the first
        fallback font that has one (#888); otherwise what getOwnCharGlyph() returns for missing characters
        (a replacement character, or the font's missing glyph).

        A glyph of a fallback font is owned by the fallback font (its glyph cache); it is drawn on the baseline
        of this font.
    */
    Glyph * getCharGlyph(dchar ch, bool withImage = true) {
        // the engines can't draw characters above U+FFFF yet (#779; Win32 looked them up as wrong characters and
        // indexed outside its glyph cache above U+3FFFF): they are drawn as U+FFFD, visible and with a width.
        // Text loaded from files has them since #923.
        if (ch > 0xFFFF)
            ch = 0xFFFD;
        // control characters (C0, DEL, C1) are never looked up in fallback fonts. No lookup if there are no
        // fallback fonts.
        if (ch >= 0x20 && (ch < 0x7F || ch > 0x9F)
                && !(_fallbackFontsCreated && _fallbackFonts.length == 0) && !hasCodepoint(ch)) {
            Glyph * glyph = getFallbackGlyph(ch, withImage);
            if (glyph) {
                _lastGlyphFromFallback = true;
                return glyph;
            }
        }
        return getOwnCharGlyph(ch, withImage);
    }

    /// set by getCharGlyph() when it returns a glyph of a fallback font: measureText() doesn't apply kerning to it
    private bool _lastGlyphFromFallback;

    /// returns number of cells character ch takes in a fixed pitch font: 2 for East Asian wide characters, else 1
    int charCells(dchar ch) {
        return isWideChar(ch) ? 2 : 1;
    }

    /// override to return glyph of this font only, without fallback fonts (#888); for characters the font has no
    /// glyph for, return a glyph of a replacement character, the font's missing glyph, or null
    protected Glyph * getOwnCharGlyph(dchar ch, bool withImage) {
        return null;
    }

    /**
        Returns glyph of the first fallback font that has a glyph for ch, null if there is none (#888); only
        the fallback font's own glyphs: its fallback fonts are not used.

        Fallback fonts are checked in list order with hasCodepoint(), which uses the presence cache shared by all
        sizes of a face: a few nanoseconds per fallback font (#897).
    */
    private Glyph * getFallbackGlyph(dchar ch, bool withImage) {
        FallbackFontList * list = &fallbackFonts();
        foreach (i; 0 .. list.length) {
            Font f = list.get(i);
            if (f && f.hasCodepoint(ch)) {
                Glyph * glyph = f.getOwnCharGlyph(ch, withImage);
                if (glyph)
                    return glyph;
                // the face has the character but returns no glyph for it: not looked up in it again
                f.cacheCodepointPresence(ch, CodepointPresence.missing);
            }
        }
        return null;
    }

    /// returns true if this font instance has a glyph for codepoint ch (replacement characters and fallback fonts
    /// are not used); characters >= MAX_UNICODE_CODEPOINTS are missing in any font (#886)
    bool hasCodepoint(dchar ch) {
        if (ch >= MAX_UNICODE_CODEPOINTS)
            return false;
        CodepointPresence presence = cachedCodepointPresence(ch);
        if (presence == CodepointPresence.unknown) {
            presence = loadCodepointPresence(ch);
            cacheCodepointPresence(ch, presence);
        }
        // unknown: the font engine cannot tell, assume the glyph exists
        return presence != CodepointPresence.missing;
    }

    /// codepoint presence cache shared by all instances (sizes) of the same font face, owned by the font manager;
    /// null if presence is not cached (#886)
    private CodepointPresenceCache * _codepointPresenceCache;

    /// set by font manager when the font is created
    package(dlangui) @property void codepointPresenceCache(CodepointPresenceCache * cache) {
        _codepointPresenceCache = cache;
    }

    /// returns presence of codepoint ch from the cache shared by all sizes of the font face, unknown if not cached
    protected final CodepointPresence cachedCodepointPresence(dchar ch) {
        return _codepointPresenceCache ? _codepointPresenceCache.getPresence(ch) : CodepointPresence.unknown;
    }

    /// stores presence of codepoint ch in the cache shared by all sizes of the font face (unknown is ignored);
    /// font implementations call it when they find out whether a codepoint exists in the font
    protected final void cacheCodepointPresence(dchar ch, CodepointPresence presence) {
        if (_codepointPresenceCache)
            _codepointPresenceCache.setPresence(ch, presence);
    }

    /// override to check whether codepoint ch exists in the font, without replacement characters;
    /// called by hasCodepoint() for codepoints not in the cache; returns unknown if the font engine cannot tell
    protected CodepointPresence loadCodepointPresence(dchar ch) {
        return CodepointPresence.unknown;
    }

    /// fallback fonts, asked from the font manager on first use (#888)
    private FallbackFontList _fallbackFonts;
    /// true if _fallbackFonts was asked from the font manager
    private bool _fallbackFontsCreated;

    /// returns fallback fonts of this font; asks the font manager for them on first call (#888)
    private ref FallbackFontList fallbackFonts() {
        if (!_fallbackFontsCreated) {
            _fallbackFontsCreated = true;
            if (FontManager.instance)
                _fallbackFonts = FontManager.instance.getFallbackFonts(this);
        }
        return _fallbackFonts;
    }

    /// releases fallback fonts; they are asked from the font manager again on next use
    private void clearFallbackFonts() {
        _fallbackFonts.clear();
        _fallbackFontsCreated = false;
    }

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

unittest {
    // textSize() cache per font instance (#888)
    static class TextSizeTestFont : Font {
        int measures; // calls of measureText
        int glyphWidth = 5;
        Glyph _glyph;
        this() {
            _glyph.blackBoxX = 4;
            _glyph.blackBoxY = 8;
        }
        override @property int size() { return 12; }
        override @property int height() { return 14; }
        override @property int weight() { return 400; }
        override @property int baseline() { return 11; }
        override @property bool italic() { return false; }
        override @property string face() { return "test"; }
        override @property FontFamily family() { return FontFamily.SansSerif; }
        override @property bool isNull() { return false; }
        override Glyph * getCharGlyph(dchar ch, bool withImage = true) {
            _glyph.widthPixels = cast(ubyte)(ch == 'i' ? 2 : glyphWidth);
            _glyph.widthScaled = cast(ushort)(_glyph.widthPixels << 6);
            return &_glyph;
        }
        override void checkpoint() {}
        override void cleanup() {}
        override void clearGlyphCache() {}
        override int measureText(const dchar[] text, ref int[] widths, int maxWidth = MAX_WIDTH_UNSPECIFIED, int tabSize = 4, int tabOffset = 0, uint textFlags = 0) {
            measures++;
            return super.measureText(text, widths, maxWidth, tabSize, tabOffset, textFlags);
        }
    }
    import std.conv : to;
    auto font = new TextSizeTestFont();
    assert(font.textSize("abc"d) == Point(15, 14) && font.measures == 1);
    assert(font.textSize("abc"d) == Point(15, 14) && font.measures == 1); // cached
    assert(font.textSize("abcd"d) == Point(20, 14) && font.measures == 2);
    assert(font.textSize("abc"d, 7) == Point(10, 14) && font.measures == 3); // other parameters: not cached yet
    assert(font.textSize("abc"d) == Point(15, 14) && font.measures == 3);
    assert(font.spaceWidth == 5);
    // a glyph setting changed: cached sizes and metrics are measured again
    font.glyphWidth = 6;
    HintingMode oldHinting = FontManager.hintingMode;
    FontManager.hintingMode = oldHinting == HintingMode.Light ? HintingMode.Normal : HintingMode.Light;
    FontManager.hintingMode = oldHinting;
    assert(font.textSize("abc"d) == Point(18, 14) && font.measures == 4);
    assert(font.spaceWidth == 6);
    // full cache is cleared
    foreach (i; 0 .. Font.TEXT_SIZE_CACHE_MAX_ITEMS + 10)
        font.textSize(to!dstring(i));
    assert(font._textSizeCache.length <= Font.TEXT_SIZE_CACHE_MAX_ITEMS);
    destroy(font);
}

unittest {
    // default fallback faces (#888)
    alias CJK = FontManager.CjkLanguage;
    FontManager.CjkLanguage cjk;
    assert(FontManager.parseCjkLanguage("ja", cjk) && cjk == CJK.japanese);
    assert(FontManager.parseCjkLanguage("ja_JP.UTF-8", cjk) && cjk == CJK.japanese);
    assert(FontManager.parseCjkLanguage("ko:en", cjk) && cjk == CJK.korean);
    assert(FontManager.parseCjkLanguage("zh_CN.UTF-8", cjk) && cjk == CJK.simplifiedChinese);
    assert(FontManager.parseCjkLanguage("zh.UTF-8", cjk) && cjk == CJK.simplifiedChinese);
    assert(FontManager.parseCjkLanguage("zh_TW.UTF-8", cjk) && cjk == CJK.traditionalChinese);
    assert(FontManager.parseCjkLanguage("zh-Hant-SG", cjk) && cjk == CJK.traditionalChinese);
    assert(FontManager.parseCjkLanguage("zh_HK", cjk) && cjk == CJK.traditionalChinese);
    assert(FontManager.parseCjkLanguage("zh:zh_TW", cjk) && cjk == CJK.simplifiedChinese); // first language only
    assert(!FontManager.parseCjkLanguage("en_US.UTF-8", cjk));
    assert(!FontManager.parseCjkLanguage("jav", cjk));
    assert(!FontManager.parseCjkLanguage("C", cjk));
    assert(!FontManager.parseCjkLanguage(null, cjk));

    assert(FontManager.splitFaces(" A, ,B ,") == ["A", "B"]);
    foreach (i; 0 .. FontFamily.max + 1) {
        FontFamily family = cast(FontFamily)i;
        foreach (lang; [CJK.simplifiedChinese, CJK.traditionalChinese, CJK.japanese, CJK.korean]) {
            string[] faces = FontManager.splitFaces(FontManager.defaultFallbackFaces(family, lang));
            assert(faces.length > 0);
            foreach (face; faces)
                assert(faces.count(face) == 1); // no duplicates
        }
        // the lists start as the defaults; disabling and restoring
        string[] defaults = FontManager.splitFaces(FontManager.defaultFallbackFaces(family));
        assert(FontManager.fallbackFaces(family) == defaults);
        FontManager.setFallbackFaces(family, "");
        assert(FontManager.fallbackFaces(family).length == 0);
        FontManager.setFallbackFaces(family, FontManager.defaultFallbackFaces(family));
        assert(FontManager.fallbackFaces(family) == defaults);
    }
    // CJK fonts of the language come first
    version (Windows) {
        enum ja = "Meiryo", sc = "Microsoft YaHei";
    } else version (OSX) {
        enum ja = "Hiragino Sans", sc = "PingFang SC";
    } else {
        enum ja = "Noto Sans CJK JP", sc = "Noto Sans CJK SC";
    }
    import std.algorithm : countUntil;
    string[] jaFaces = FontManager.splitFaces(FontManager.defaultFallbackFaces(FontFamily.SansSerif, CJK.japanese));
    string[] scFaces = FontManager.splitFaces(FontManager.defaultFallbackFaces(FontFamily.SansSerif, CJK.simplifiedChinese));
    assert(jaFaces.countUntil(ja) < jaFaces.countUntil(sc));
    assert(scFaces.countUntil(sc) < scFaces.countUntil(ja));
}

unittest {
    // fallback font lists and the font cache GC (#888)
    static class GCTestFont : Font {
        static int alive; // instances not destroyed yet
        string _face;
        int _size;
        this(string face, int size) { _face = face; _size = size; alive++; }
        ~this() { alive--; }
        override @property int size() { return _size; }
        override @property int height() { return _size + 2; }
        override @property int weight() { return 400; }
        override @property int baseline() { return _size; }
        override @property bool italic() { return false; }
        override @property string face() { return _face; }
        override @property FontFamily family() { return FontFamily.SansSerif; }
        override @property bool isNull() { return false; }
        override Glyph * getCharGlyph(dchar ch, bool withImage = true) { return null; }
        override void checkpoint() {}
        override void cleanup() {}
        override void clearGlyphCache() {}
    }
    static class GCTestFontManager : FontManager {
        FontList _fonts;
        string[] _faces = ["A", "B", "C", "D"];
        FontRef _nullFont;
        ~this() {
            if (inGCFinalizer()) return; // finalized by the GC: a leak, touch nothing (#975)
            releaseFallbackFonts();
            _fonts.clear();
        }
        override ref FontRef getFont(int size, int weight, bool italic, FontFamily family, string face) {
            string found = findInstalledFace(face);
            if (!found.length)
                return _nullFont;
            int index = _fonts.find(size, weight, italic, family, found);
            if (index >= 0)
                return _fonts.get(index);
            return _fonts.add(new GCTestFont(found, size));
        }
        override FontFaceProps[] getFaces() {
            FontFaceProps[] res;
            foreach (f; _faces)
                res ~= FontFaceProps(f, FontFamily.SansSerif);
            return res;
        }
        override void checkpoint() {}
        override protected void forEachFontList(scope void delegate(ref FontList list) callback) {
            callback(_fonts);
        }
    }
    if (FontManager.instance !is null)
        return; // the test needs its own font manager
    string[] oldFallbackFaces = FontManager.fallbackFaces(FontFamily.SansSerif);
    auto manager = new GCTestFontManager();
    FontManager.instance = manager;
    // not installed faces, the primary face and duplicates are skipped
    FontManager.setFallbackFaces(FontFamily.SansSerif, "Missing, b, B, A, , C");
    {
        FontRef a = manager.getFont(12, 400, false, FontFamily.SansSerif, "A");
        assert(!a._fallbackFontsCreated && GCTestFont.alive == 1);
        assert(a.fallbackFonts.length == 2 && a.fallbackFonts.face(0) == "B" && a.fallbackFonts.face(1) == "C");
        assert(GCTestFont.alive == 1); // fallback fonts are created on first use
        FontRef b = a.fallbackFonts.get(0);
        assert(GCTestFont.alive == 2 && b.face == "B" && b.size == 12);
        assert(a.fallbackFonts.get(0) is b.get); // created once
        // B falls back to A: a cycle
        assert(b.fallbackFonts.face(0) == "A" && b.fallbackFonts.get(0) is a.get);
        assert(a.refCount == 3 && b.refCount == 3); // cache, local reference, fallback of the other font
        // fonts used only as fallback fonts of a used font are kept
        a.clear();
        manager.cleanup();
        assert(GCTestFont.alive == 2 && manager._fonts.length == 2);
        // a font that is not used and not a fallback font is destroyed
        manager.getFont(20, 400, false, FontFamily.SansSerif, "D");
        manager.getFont(20, 400, false, FontFamily.SansSerif, "C");
        assert(GCTestFont.alive == 4);
        manager.cleanup();
        assert(GCTestFont.alive == 2 && manager._fonts.length == 2);
        // a cycle without other references is destroyed
        b.clear();
        manager.cleanup();
        assert(GCTestFont.alive == 0 && manager._fonts.length == 0);
    }
    {
        // a chain: A (used) -> B -> C, D not used; the fallback faces are changed: lists are released
        FontRef a = manager.getFont(12, 400, false, FontFamily.SansSerif, "A");
        Font b = a.fallbackFonts.get(0);
        Font c = b.fallbackFonts.get(1);
        assert(b.face == "B" && c.face == "C" && GCTestFont.alive == 3);
        manager.getFont(12, 400, false, FontFamily.SansSerif, "D");
        manager.cleanup();
        assert(GCTestFont.alive == 3 && manager._fonts.length == 3);
        FontManager.setFallbackFaces(FontFamily.SansSerif, "D");
        assert(!a._fallbackFontsCreated && b.refCount == 1 && c.refCount == 1);
        manager.cleanup();
        assert(GCTestFont.alive == 1);
        assert(a.fallbackFonts.length == 1 && a.fallbackFonts.get(0).face == "D");
        // a fallback face resolved to the primary font is not used
        manager._faces = ["A"];
        FontManager.setFallbackFaces(FontFamily.SansSerif, "A");
        assert(a.fallbackFonts.length == 0);
    }
    {
        // cycle at font manager destruction: no leaks
        manager._faces = ["A", "B"];
        FontManager.setFallbackFaces(FontFamily.SansSerif, "A, B");
        FontRef a = manager.getFont(12, 400, false, FontFamily.SansSerif, "A");
        Font b = a.fallbackFonts.get(0);
        assert(b.fallbackFonts.get(0) is a.get);
    }
    FontManager.instance = null;
    assert(GCTestFont.alive == 0);
    FontManager._fallbackFaces[FontFamily.SansSerif] = oldFallbackFaces;
}

unittest {
    // glyph lookup in fallback fonts (#888)
    static class LookupTestFont : Font {
        static int alive;
        string _face;
        int _size;
        bool _fixed;
        Glyph*[dchar] _glyphs; // characters the font has
        Glyph _missing; // missing glyph
        this(string face, int size) {
            _face = face;
            _size = size;
            alive++;
            void add(dchar ch, int width) {
                Glyph * g = new Glyph;
                g.blackBoxX = cast(ushort)width;
                g.blackBoxY = 8;
                g.widthPixels = cast(ubyte)width;
                g.widthScaled = cast(ushort)(width << 6);
                _glyphs[ch] = g;
            }
            if (face == "A" || face == "M") {
                _fixed = face == "M";
                foreach (dchar ch; ' ' .. '\x7F')
                    add(ch, _fixed ? 6 : (ch == 'i' ? 3 : 5));
            } else if (face == "B") {
                add(0x4E2D, 10);
                add(0x0416, 7);
                add('x', 9);
            } else if (face == "C") {
                add(0x2605, 8);
                foreach (dchar ch; "\n\u007F\u0085\u009F\U0001F600"d)
                    add(ch, 8); // must not be looked up in fallback fonts
            }
            _missing.blackBoxX = 3;
            _missing.blackBoxY = 8;
            _missing.widthPixels = 4;
            _missing.widthScaled = 4 << 6;
        }
        ~this() { alive--; }
        override @property int size() { return _size; }
        override @property int height() { return _size + 2; }
        override @property int weight() { return 400; }
        override @property int baseline() { return _size; }
        override @property bool italic() { return false; }
        override @property string face() { return _face; }
        override @property FontFamily family() { return FontFamily.SansSerif; }
        override @property bool isNull() { return false; }
        override protected Glyph * getOwnCharGlyph(dchar ch, bool withImage) {
            if (auto p = ch in _glyphs)
                return *p;
            return &_missing;
        }
        override protected CodepointPresence loadCodepointPresence(dchar ch) {
            return (ch in _glyphs) ? CodepointPresence.present : CodepointPresence.missing;
        }
        override @property bool allowKerning() { return !_fixed; }
        override int getKerningOffset(dchar prevChar, dchar currentChar) {
            assert(prevChar in _glyphs && currentChar in _glyphs); // only pairs of own glyphs
            return -64; // 1 pixel closer
        }
        override void checkpoint() {}
        override void cleanup() {}
        override void clearGlyphCache() {}
    }
    static class LookupTestFontManager : FontManager {
        FontList _fonts;
        FontRef _nullFont;
        ~this() {
            if (inGCFinalizer()) return; // finalized by the GC: a leak, touch nothing (#975)
            releaseFallbackFonts();
            _fonts.clear();
        }
        override ref FontRef getFont(int size, int weight, bool italic, FontFamily family, string face) {
            string found = findInstalledFace(face);
            if (!found.length)
                return _nullFont;
            int index = _fonts.find(size, weight, italic, family, found);
            if (index >= 0)
                return _fonts.get(index);
            return _fonts.add(new LookupTestFont(found, size));
        }
        override FontFaceProps[] getFaces() {
            return [FontFaceProps("A", FontFamily.SansSerif), FontFaceProps("B", FontFamily.SansSerif),
                FontFaceProps("C", FontFamily.SansSerif), FontFaceProps("M", FontFamily.SansSerif)];
        }
        override void checkpoint() {}
        override protected void forEachFontList(scope void delegate(ref FontList list) callback) {
            callback(_fonts);
        }
    }
    static class RecordingDrawBuf : ColorDrawBuf {
        int[] xs; // x of drawn glyphs
        this() { super(100, 20); }
        override void drawGlyph(int x, int y, Glyph * glyph, uint color) { xs ~= x; }
    }
    if (FontManager.instance !is null)
        return; // the test needs its own font manager
    string[] oldFallbackFaces = FontManager.fallbackFaces(FontFamily.SansSerif);
    auto manager = new LookupTestFontManager();
    FontManager.instance = manager;
    FontManager.setFallbackFaces(FontFamily.SansSerif, "B, C");
    {
        FontRef a = manager.getFont(12, 400, false, FontFamily.SansSerif, "A");
        LookupTestFont la = cast(LookupTestFont)a.get;
        assert(a.getCharGlyph('x') is la._glyphs['x']);
        assert(!a._fallbackFontsCreated && LookupTestFont.alive == 1); // only own characters: no fallback fonts yet
        // the first fallback font with the character; fallback fonts are created when needed
        Glyph * g = a.getCharGlyph(0x4E2D);
        assert(LookupTestFont.alive == 2);
        LookupTestFont lb = cast(LookupTestFont)a.fallbackFonts.get(0);
        assert(lb._face == "B" && g is lb._glyphs[0x4E2D]);
        assert(a.getCharGlyph(0x2605) is (cast(LookupTestFont)a.fallbackFonts.get(1))._glyphs[0x2605]);
        assert(LookupTestFont.alive == 3);
        // no fallback font has it: the font's missing glyph; control characters are not looked up, though C has
        // glyphs for them; characters above U+FFFF are drawn as U+FFFD (#779, #923), which no font has here
        assert(a.getCharGlyph(0xE000) is &la._missing);
        foreach (dchar c; "\n\u007F\u0085\u009F"d)
            assert(a.getCharGlyph(c) is &la._missing);
        foreach (dchar c; [cast(dchar)0x1F600, cast(dchar)0xE0100, cast(dchar)0x110000])
            assert(a.getCharGlyph(c) is a.getCharGlyph(0xFFFD) && a.getCharGlyph(c) is &la._missing);
        // a fallback font that has the character but returns no glyph: the next one is used, and the character
        // is marked missing in the face's presence cache
        a.clearFallbackFonts();
        lb = cast(LookupTestFont)a.fallbackFonts.get(0);
        CodepointPresenceCache bPresence;
        lb.codepointPresenceCache = &bPresence;
        lb._glyphs[0x2605] = null; // B "has" U+2605, without a glyph
        assert(lb.hasCodepoint(0x2605));
        assert(a.getCharGlyph(0x2605) is (cast(LookupTestFont)a.fallbackFonts.get(1))._glyphs[0x2605]);
        assert(!lb.hasCodepoint(0x2605));
        lb.codepointPresenceCache = null;
        lb._glyphs.remove(0x2605);
        // fallback glyph advances; kerning only between own glyphs (getKerningOffset asserts it)
        int[] w;
        assert(a.measureText("xx"d, w) == 2 && w[0] == 4 && w[1] == 9); // kerning moves the boundary (#863)
        assert(a.measureText("x中x"d, w) == 3 && w[0] == 5 && w[1] == 15 && w[2] == 20);
        // fixed pitch: whole cells, 2 for wide characters; glyphs centered in their cells
        FontRef m = manager.getFont(12, 400, false, FontFamily.SansSerif, "M");
        assert(m.isFixed);
        assert(m.measureText("x中Жx"d, w) == 4 && w[0] == 6 && w[1] == 18 && w[2] == 24 && w[3] == 30);
        auto buf = new RecordingDrawBuf();
        m.drawText(buf, 0, 0, "x中Жx"d, 0);
        // 中: 10 px glyph in 12 px (2 cells) at 6; Ж: 7 px glyph in 6 px at 18 (overhangs); x: own glyph at 24
        assert(buf.xs == [0, 7, 18, 24]);
        destroy(buf);
        // changed fallback faces: lookups are done again
        FontManager.setFallbackFaces(FontFamily.SansSerif, "C, B");
        assert(!a._fallbackFontsCreated);
        // combining marks (zero width) are not centered in fixed pitch cells
        auto mark = new Glyph;
        mark.blackBoxX = 3;
        mark.blackBoxY = 3;
        mark.originX = -4;
        (cast(LookupTestFont)m.get)._glyphs[0x0301] = mark;
        buf = new RecordingDrawBuf();
        m.drawText(buf, 0, 0, "x\u0301"d, 0);
        assert(buf.xs == [0, 6 - 4]);
        destroy(buf);
        assert(a.getCharGlyph(0x2605) is (cast(LookupTestFont)a.fallbackFonts.get(0))._glyphs[0x2605]);
        // no fallback faces: missing glyph, and no more presence lookups
        FontManager.setFallbackFaces(FontFamily.SansSerif, "");
        assert(a.getCharGlyph(0x4E2D) is &la._missing && a._fallbackFontsCreated && a.fallbackFonts.length == 0);
    }
    FontManager.instance = null;
    assert(LookupTestFont.alive == 0);
    FontManager._fallbackFaces[FontFamily.SansSerif] = oldFallbackFaces;
}

unittest {
    // Font.hasCodepoint with a presence cache shared by two sizes of a font face (#886)
    static class PresenceTestFont : Font {
        int _size;
        int loads; // calls of loadCodepointPresence
        this(int size) { _size = size; }
        override @property int size() { return _size; }
        override @property int height() { return _size + 2; }
        override @property int weight() { return 400; }
        override @property int baseline() { return _size; }
        override @property bool italic() { return false; }
        override @property string face() { return "test"; }
        override @property FontFamily family() { return FontFamily.SansSerif; }
        override @property bool isNull() { return false; }
        override Glyph * getCharGlyph(dchar ch, bool withImage = true) { return null; }
        override void checkpoint() {}
        override void cleanup() {}
        override void clearGlyphCache() {}
        override protected CodepointPresence loadCodepointPresence(dchar ch) {
            loads++;
            if (ch == '?')
                return CodepointPresence.unknown; // engine cannot tell
            return ch < 0x80 || ch == 0x1F600 ? CodepointPresence.present : CodepointPresence.missing;
        }
    }
    CodepointPresenceCache cache;
    auto font12 = new PresenceTestFont(12);
    auto font20 = new PresenceTestFont(20);
    font12.codepointPresenceCache = &cache;
    font20.codepointPresenceCache = &cache;
    assert(font12.hasCodepoint('A') && font12.loads == 1);
    assert(!font12.hasCodepoint(0x4E2D) && font12.loads == 2);
    assert(font12.hasCodepoint(0x1F600) && font12.loads == 3);
    // cached: no more engine lookups, also for the other size
    assert(font12.hasCodepoint('A') && !font12.hasCodepoint(0x4E2D) && font12.loads == 3);
    assert(font20.hasCodepoint('A') && !font20.hasCodepoint(0x4E2D) && font20.hasCodepoint(0x1F600) && font20.loads == 0);
    assert(cache.getPresence(0x4E2D) == CodepointPresence.missing);
    // unknown: assumed present, not cached
    assert(font20.hasCodepoint('?'));
    assert(font20.hasCodepoint('?') && font20.loads == 2); // asked the engine again
    assert(cache.getPresence('?') == CodepointPresence.unknown);
    // beyond Unicode: missing, the engine is not asked
    assert(!font20.hasCodepoint(cast(dchar)0x110000) && font20.loads == 2);
    // no cache: every call asks the engine
    auto font30 = new PresenceTestFont(30);
    assert(font30.hasCodepoint('A'));
    assert(font30.hasCodepoint('A') && font30.loads == 2); // asked the engine again
    destroy(font12);
    destroy(font20);
    destroy(font30);
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
        if (inGCFinalizer()) return; // finalized by the GC: a leak, touch nothing (#975)
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
            // not _list.length = n: reallocation copies the references (postblit) and leaves the old copies in the
            // old block until the GC finalizes it, so fonts would be destroyed only by the GC (#900)
            FontRef[] list = new FontRef[_list.length < 16 ? 16 : _list.length * 2];
            foreach (i; 0 .. _len) {
                list[i] = _list[i];
                _list[i].clear();
            }
            _list = list;
        }
        _list[_len++] = item;
        //Log.d("FontList.add() exit");
        return _list[_len - 1];
    }
    // remove unused items - with reference == 1; cleanup glyph caches of others
    void cleanup() {
        foreach(i; 0 .. _len)
            if (_list[i].refCount <= 1)
                _list[i].clear();
        compact();
        foreach(i; 0 .. _len)
            _list[i].cleanup();
    }
    /// removes (releases) items for which shouldRemove returns true
    void removeFonts(scope bool delegate(Font) shouldRemove) {
        foreach(i; 0 .. _len)
            if (shouldRemove(_list[i].get))
                _list[i].clear();
        compact();
    }
    // move items left over cleared ones; clear the moved items' old slots, which would keep extra references
    private void compact() {
        uint dst = 0;
        foreach(i; 0 .. _len) {
            if (_list[i].isNull)
                continue;
            if (i != dst) {
                _list[dst] = _list[i];
                _list[i].clear();
            }
            dst++;
        }
        _len = dst;
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

unittest {
    // growing the list keeps one reference per font (#900)
    static class ListTestFont : Font {
        static int alive;
        int _size;
        this(int size) { _size = size; alive++; }
        ~this() { alive--; }
        override @property int size() { return _size; }
        override @property int height() { return _size; }
        override @property int weight() { return 400; }
        override @property int baseline() { return _size; }
        override @property bool italic() { return false; }
        override @property string face() { return "T"; }
        override @property FontFamily family() { return FontFamily.SansSerif; }
        override @property bool isNull() { return false; }
        override void checkpoint() {}
        override void cleanup() {}
        override void clearGlyphCache() {}
    }
    {
        FontList list;
        foreach (i; 0 .. 70)
            list.add(new ListTestFont(i));
        foreach (i; 0 .. 70)
            assert(list.get(i).refCount == 1);
        list.clear();
        assert(ListTestFont.alive == 0); // destroyed by clear(), not by the GC
    }
}

/// fallback font of a font: parameters to create it, and the instance once created (#888)
private struct FallbackFontEntry {
    string face;
    FontFamily family;
    int weight;
    bool italic;
    int size;
    FontRef font;
    /// font could not be created, or it is the primary font itself
    bool failed;
}

/**
    Fallback fonts of a font, for characters it has no glyphs for (#888).

    FontManager.getFallbackFonts() creates the list with the faces to use. Font instances are created on first use
    by get(), through FontManager.getFont(): they are cached fonts, shared with other fonts and widgets.
    The list holds references to the instances it created; clear() or the destructor releases them. Not copyable.
*/
struct FallbackFontList {
    private FontManager _manager;
    /// font the list belongs to (not referenced)
    private Font _primary;
    private FallbackFontEntry[] _entries;

    @disable this(this);

    this(FontManager manager, Font primary) {
        _manager = manager;
        _primary = primary;
    }

    /// number of fallback fonts
    @property size_t length() const {
        return _entries.length;
    }

    /// face of fallback font
    string face(size_t index) const {
        return _entries[index].face;
    }

    /// adds fallback font (created on first get())
    void add(string face, FontFamily family, int weight, bool italic, int size) {
        FallbackFontEntry entry;
        entry.face = face;
        entry.family = family;
        entry.weight = weight;
        entry.italic = italic;
        entry.size = size;
        _entries ~= entry;
    }

    /// returns fallback font, creates it on first call; null if it cannot be created
    Font get(size_t index) {
        if (index >= _entries.length)
            return null;
        FallbackFontEntry * e = &_entries[index];
        if (e.font.isNull && !e.failed) {
            if (_manager)
                e.font = _manager.getFont(e.size, e.weight, e.italic, e.family, e.face);
            // a face resolved to the primary font itself would be a reference cycle of one font
            if (e.font.isNull || e.font.get is _primary) {
                e.font.clear();
                e.failed = true;
            }
        }
        return e.font.get;
    }

    /// calls callback for each fallback font created so far
    void forEachInstance(scope void delegate(Font font) callback) {
        foreach (ref e; _entries)
            if (!e.font.isNull)
                callback(e.font.get);
    }

    /// releases created fonts and removes all entries
    void clear() {
        foreach (ref e; _entries)
            e.font.clear();
        _entries = null;
    }

    ~this() {
        if (inGCFinalizer()) return; // finalized by the GC: a leak, touch nothing (#975)
        clear();
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

/// properties of a face in a TrueType / OpenType font file, read by fontFileFaces() (#652)
struct FontFileFaceInfo {
    /// family name (name ID 1, the name GDI uses for the face; e.g. "Roboto Light" for a light weight)
    string family;
    /// true for a fixed pitch (monospace) font (isFixedPitch of the post table)
    bool fixedPitch;
}

/**
    Reads the faces of a TrueType / OpenType font file or font collection (.ttc) kept in memory (#652):
    family names from the name table, fixed pitch from the post table.
    Returns: one entry per face; empty for data that isn't a font file, or a face without family name.
*/
FontFileFaceInfo[] fontFileFaces(const(ubyte)[] data) @safe {
    uint u16(size_t pos) { return pos + 2 <= data.length ? (data[pos] << 8) | data[pos + 1] : 0; }
    uint u32(size_t pos) { return pos + 4 <= data.length ? (u16(pos) << 16) | u16(pos + 2) : 0; }
    // offset and length of a table of the face with the table directory at faceOffset; length 0 if missing
    void findTable(size_t faceOffset, string tag, out size_t offset, out size_t length) {
        uint numTables = u16(faceOffset + 4);
        foreach (i; 0 .. numTables) {
            size_t rec = faceOffset + 12 + i * 16;
            if (rec + 16 > data.length)
                return;
            if (data[rec .. rec + 4] == cast(const(ubyte)[])tag) {
                offset = u32(rec + 8);
                length = u32(rec + 12);
                if (offset + length > data.length)
                    length = 0;
                return;
            }
        }
    }
    string familyName(size_t faceOffset) {
        size_t table, tableLength;
        findTable(faceOffset, "name", table, tableLength);
        if (tableLength < 6)
            return null;
        uint count = u16(table + 2);
        size_t strings = table + u16(table + 4);
        string best;
        int bestScore = 0;
        foreach (i; 0 .. count) {
            size_t rec = table + 6 + i * 12;
            if (rec + 12 > table + tableLength)
                break;
            uint platform = u16(rec), encoding = u16(rec + 2), language = u16(rec + 4), nameId = u16(rec + 6);
            size_t len = u16(rec + 8), pos = strings + u16(rec + 10);
            if (nameId != 1 || pos + len > data.length)
                continue;
            int score = 0;
            if (platform == 3 && (encoding == 1 || encoding == 10))
                score = language == 0x409 ? 5 : 4; // Windows, Unicode; prefer US English
            else if (platform == 3 && encoding == 0)
                score = 3; // Windows, Symbol (symbol and icon fonts), UTF-16 as well
            else if (platform == 0)
                score = 2; // Unicode
            else if (platform == 1 && encoding == 0)
                score = 1; // Macintosh, Roman
            if (score <= bestScore)
                continue;
            const(ubyte)[] bytes = data[pos .. pos + len];
            string name;
            if (platform == 3 || platform == 0) {
                import std.utf : toUTF8;
                wchar[] w;
                foreach (j; 0 .. len / 2)
                    w ~= cast(wchar)((bytes[j * 2] << 8) | bytes[j * 2 + 1]);
                try
                    name = toUTF8(w);
                catch (Exception e)
                    continue; // invalid UTF-16
            } else {
                foreach (ch; bytes)
                    name ~= ch < 0x80 ? cast(char)ch : '?';
            }
            if (name.length) {
                best = name;
                bestScore = score;
            }
        }
        return best;
    }

    size_t[] faceOffsets;
    if (data.length >= 12 && data[0 .. 4] == cast(const(ubyte)[])"ttcf") {
        uint numFonts = u32(8);
        foreach (i; 0 .. numFonts) {
            if (12 + i * 4 + 4 > data.length)
                break;
            faceOffsets ~= u32(12 + i * 4);
        }
    } else {
        faceOffsets ~= 0;
    }
    FontFileFaceInfo[] res;
    foreach (offset; faceOffsets) {
        uint sfntVersion = u32(offset);
        if (sfntVersion != 0x0001_0000 && sfntVersion != 0x4F54_544F /* OTTO */ && sfntVersion != 0x7472_7565 /* true */)
            continue;
        string family = familyName(offset);
        if (!family.length)
            continue;
        size_t post, postLength;
        findTable(offset, "post", post, postLength);
        res ~= FontFileFaceInfo(family, postLength >= 16 && u32(post + 12) != 0);
    }
    return res;
}

/// Access points to fonts.
class FontManager {
    protected static __gshared FontManager _instance;
    protected static __gshared int _minAnitialiasedFontSize = DEF_MIN_ANTIALIASED_FONT_SIZE;
    protected static __gshared HintingMode _hintingMode = HintingMode.Normal;
    // effective mode: never Auto
    protected static __gshared SubpixelRenderingMode _subpixelRenderingMode = SubpixelRenderingMode.None;
    // mode as set, Auto by default (#882)
    protected static __gshared SubpixelRenderingMode _subpixelRenderingModeSetting = SubpixelRenderingMode.Auto;
    // mode detected for the platform, used for Auto (#882)
    protected static __gshared SubpixelRenderingMode _systemSubpixelRenderingMode = SubpixelRenderingMode.None;

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

    /**
        Registers the faces of a TrueType / OpenType font file or collection kept in memory (#652), e.g. a font
        embedded as a resource; face names, weight and italic are read from the font. The faces are then used
        by name like installed fonts (getFont, `fontFace` in themes and DML). The font manager keeps a reference
        to data. Registering the same data again adds nothing.

        family: font family of the faces, used when a font is requested by family.
        name: name of the font (e.g. the resource name), for log messages.
        Returns: number of faces in the font; 0 if the data isn't a font, or the font manager can't load fonts
        from memory (e.g. the console font manager).
    */
    int registerFontData(immutable(ubyte)[] data, FontFamily family, string name = null) {
        return 0;
    }

    /**
        Registers the faces of a font file (#652), see registerFontData(). By default the file is loaded into
        memory; the FreeType font manager opens it by name.
        Returns: number of faces in the font, see registerFontData().
    */
    int registerFontFile(string filename, FontFamily family) {
        import dlangui.graphics.resources : loadResourceBytes;
        immutable(ubyte)[] data = loadResourceBytes(filename);
        return data.length ? registerFontData(data, family, filename) : 0;
    }

    /**
        Registers the faces of a font file resource (#652): embedded (views/resources.list) or found in the
        resource directories, by file name with or without extension (`.ttf`, `.otf`, `.ttc`), see
        findFontResource(). E.g. `FontManager.instance.registerFontResource("MyFont", FontFamily.SansSerif)`
        for an embedded `res/MyFont.ttf`, then use the face name of the font.
        Returns: number of faces in the font, see registerFontData().
    */
    int registerFontResource(string resourceId, FontFamily family) {
        import dlangui.graphics.resources : EMBEDDED_RESOURCE_PREFIX, findFontResource, loadResourceBytes;
        string filename = findFontResource(resourceId);
        if (!filename) {
            Log.e("Font resource ", resourceId, " not found");
            return 0;
        }
        int count;
        if (filename.startsWith(EMBEDDED_RESOURCE_PREFIX)) {
            immutable(ubyte)[] data = loadResourceBytes(filename);
            count = data.length ? registerFontData(data, family, filename) : 0;
        } else {
            count = registerFontFile(filename, family);
        }
        if (!count)
            Log.e("Cannot register font resource ", filename);
        return count;
    }

    /// clear usage flags for all entries -- for cleanup of unused fonts
    abstract void checkpoint();

    /**
        Destroys cached fonts that are not used (#888), and glyphs not used since the last call of checkpoint().

        A cached font is used if it is referenced outside of the font cache (e.g. by a widget style), or if it is
        a fallback font of a used font. Fonts referencing each other only as fallback fonts are destroyed.
    */
    void cleanup() {
        collectUnusedFonts();
        forEachFontList((ref FontList list) { list.cleanup(); });
    }

    /// override to call callback for each list of cached fonts; used by cleanup() and releaseFallbackFonts()
    protected void forEachFontList(scope void delegate(ref FontList list) callback) {
    }

    /// destroys cached fonts used neither outside of the cache nor as fallback fonts of used fonts (#888)
    private void collectUnusedFonts() {
        Font[] fonts;
        forEachFontList((ref FontList list) {
            foreach (i; 0 .. list.length)
                fonts ~= list.get(i).get;
        });
        // references from fallback lists of cached fonts
        int[Font] fallbackRefs;
        foreach (f; fonts)
            f._fallbackFonts.forEachInstance((Font fallback) { fallbackRefs[fallback]++; });
        // roots: fonts with references from outside of the cache and fallback lists; mark fonts reachable from them
        bool[Font] used;
        Font[] stack;
        foreach (f; fonts) {
            if (f.refCount > 1 + fallbackRefs.get(f, 0)) {
                used[f] = true;
                stack ~= f;
            }
        }
        while (stack.length) {
            Font f = stack[$ - 1];
            stack = stack[0 .. $ - 1];
            f._fallbackFonts.forEachInstance((Font fallback) {
                if (fallback !in used) {
                    used[fallback] = true;
                    stack ~= fallback;
                }
            });
        }
        size_t unused = 0;
        foreach (f; fonts)
            if (f !in used)
                unused++;
        if (!unused)
            return;
        Log.d("Destroying ", unused, " unused fonts of ", fonts.length);
        // unused fonts may reference each other: release their fallback fonts first, then remove them from the cache
        foreach (f; fonts)
            if (f !in used)
                f.clearFallbackFonts();
        forEachFontList((ref FontList list) {
            list.removeFonts((Font f) => f !in used);
        });
    }

    /// releases fallback fonts of all cached fonts; they are asked for again on next use.
    /// Font manager destructors call it before destroying cached fonts: fallback references may form cycles.
    protected void releaseFallbackFonts() {
        forEachFontList((ref FontList list) {
            foreach (i; 0 .. list.length)
                list.get(i).get.clearFallbackFonts();
        });
    }

    /// language whose forms Han characters take: fallback faces list CJK fonts of this language first (#888)
    enum CjkLanguage : ubyte {
        simplifiedChinese,
        traditionalChinese,
        japanese,
        korean,
    }

    /**
        Parses a language tag such as "ja", "ja_JP.UTF-8", "zh-TW", "zh_Hant" or a LANGUAGE list ("ko:en").
        Returns: true and the CJK language if the (first) language is Chinese, Japanese or Korean.
    */
    static bool parseCjkLanguage(string lang, out CjkLanguage res) pure nothrow @nogc @safe {
        static char lower(char c) { return c >= 'A' && c <= 'Z' ? cast(char)(c + 32) : c; }
        static bool isSeparator(char c) { return c == '_' || c == '-' || c == '.' || c == '@' || c == ':'; }
        if (lang.length < 2 || (lang.length > 2 && !isSeparator(lang[2])))
            return false;
        char a = lower(lang[0]), b = lower(lang[1]);
        if (a == 'j' && b == 'a') {
            res = CjkLanguage.japanese;
            return true;
        }
        if (a == 'k' && b == 'o') {
            res = CjkLanguage.korean;
            return true;
        }
        if (a != 'z' || b != 'h')
            return false;
        // region or script of the first language: TW, HK, MO, Hant
        size_t end = 2;
        while (end < lang.length && lang[end] != '.' && lang[end] != ':' && lang[end] != '@')
            end++;
        res = CjkLanguage.simplifiedChinese;
        size_t i = 3;
        while (i < end) {
            size_t j = i;
            while (j < end && !isSeparator(lang[j]))
                j++;
            if (j - i == 2 || j - i == 4) {
                char[4] buf;
                foreach (k, c; lang[i .. j])
                    buf[k] = lower(c);
                const(char)[] part = buf[0 .. j - i];
                if (part == "tw" || part == "hk" || part == "mo" || part == "hant")
                    res = CjkLanguage.traditionalChinese;
            }
            i = j + 1;
        }
        return true;
    }

    /// CJK language of the system: the first Chinese, Japanese or Korean language of the user's UI language,
    /// locale and system locale (Windows) or of the LANGUAGE, LC_ALL, LC_MESSAGES, LC_CTYPE and LANG variables;
    /// simplifiedChinese if there is none
    static CjkLanguage systemCjkLanguage() {
        CjkLanguage res;
        version (Windows) {
            import core.sys.windows.winnls : GetUserDefaultUILanguage, GetUserDefaultLangID, GetSystemDefaultLangID;
            foreach (id; [GetUserDefaultUILanguage(), GetUserDefaultLangID(), GetSystemDefaultLangID()]) {
                uint primary = id & 0x3FF, sub = id >> 10;
                if (primary == 0x11) // LANG_JAPANESE
                    return CjkLanguage.japanese;
                if (primary == 0x12) // LANG_KOREAN
                    return CjkLanguage.korean;
                if (primary == 0x04) // LANG_CHINESE: Taiwan, Hong Kong, Macao, zh-Hant
                    return sub == 1 || sub == 3 || sub == 5 || sub == 0x1F
                        ? CjkLanguage.traditionalChinese : CjkLanguage.simplifiedChinese;
            }
        } else {
            import std.process : environment;
            foreach (name; ["LANGUAGE", "LC_ALL", "LC_MESSAGES", "LC_CTYPE", "LANG"])
                if (parseCjkLanguage(environment.get(name), res))
                    return res;
        }
        return CjkLanguage.simplifiedChinese;
    }

    // joins comma separated face lists of the 4 CJK languages, the preferred language first
    private static string cjkFaces(CjkLanguage lang, string sc, string tc, string ja, string ko) pure @safe {
        string[4] order;
        final switch (lang) {
            case CjkLanguage.simplifiedChinese: order = [sc, ja, ko, tc]; break;
            case CjkLanguage.traditionalChinese: order = [tc, sc, ja, ko]; break;
            case CjkLanguage.japanese: order = [ja, sc, tc, ko]; break;
            case CjkLanguage.korean: order = [ko, tc, sc, ja]; break;
        }
        string res;
        foreach (part; order)
            res ~= (res.length ? ", " : "") ~ part;
        return res;
    }

    // joins comma separated face lists, skipping empty ones
    private static string joinFaces(string[] lists...) pure @safe {
        string res;
        foreach (list; lists)
            if (list.length)
                res ~= (res.length ? ", " : "") ~ list;
        return res;
    }

    /**
        Returns the platform's default fallback faces for a font family (#888, #899): comma separated, in order of
        preference. Faces that are not installed are skipped when fallback fonts are created.

        The lists have the same structure on all platforms: Latin fonts of the family and of sans serif, symbol
        fonts, CJK fonts with those of the language cjk first (a Han character takes the forms of the first
        installed font that has it), fonts of other living scripts, and last resort fonts. Symbol fonts come
        before CJK fonts, so that symbols don't take the forms of a CJK font. Historic and rare scripts are left to
        platform font discovery (#896).

        Sources: Firefox (GetCommonFallbackFonts and font.name-list prefs), Microsoft "Script and font support in
        Windows" and the Windows 11 font list, Android fonts.xml, fontconfig 65-nonlatin.conf.
    */
    static string defaultFallbackFaces(FontFamily family, CjkLanguage cjk) pure @safe {
        version (Windows) {
            enum latinSans = "Segoe UI, Arial, Tahoma";
            enum symbols = "Segoe UI Symbol, Cambria Math";
            string cjkSans = cjkFaces(cjk, "Microsoft YaHei, SimHei, Noto Sans CJK SC",
                "Microsoft JhengHei, Noto Sans CJK TC, Noto Sans CJK HK",
                "Meiryo, Yu Gothic, MS PGothic, MS Gothic, Noto Sans CJK JP",
                "Malgun Gothic, Gulim, Noto Sans CJK KR");
            string cjkSerif = cjkFaces(cjk, "SimSun, Noto Serif CJK SC",
                "PMingLiU, MingLiU, MingLiU_HKSCS, Noto Serif CJK TC",
                "Yu Mincho, MS PMincho, MS Mincho, Noto Serif CJK JP", "Batang, Noto Serif CJK KR");
            // UI fonts of Windows 8 and later, then fonts of Windows 7 and of optional language font packages
            enum scripts = "Nirmala UI, Leelawadee UI, Ebrima, Gadugi, Myanmar Text, Javanese Text, "
                ~ "Microsoft Himalaya, Mongolian Baiti, Microsoft Yi Baiti, Microsoft New Tai Lue, Microsoft Tai Le, "
                ~ "Microsoft PhagsPa, MV Boli, Sylfaen, Estrangelo Edessa, "
                ~ "Mangal, Kokila, Vrinda, Shruti, Raavi, Tunga, Kartika, Kalinga, Latha, Gautami, Iskoola Pota, "
                ~ "Khmer UI, DaunPenh, Lao UI, DokChampa, Nyala, Euphemia, Plantagenet Cherokee, Segoe UI Historic";
            enum lastResort = "Arial Unicode MS, Segoe UI Emoji";
            switch (family) {
                case FontFamily.MonoSpace:
                    return joinFaces("Consolas, Courier New, Lucida Console", latinSans, symbols, cjkSans, cjkSerif,
                        scripts, lastResort);
                case FontFamily.Serif:
                    return joinFaces("Times New Roman, Cambria", latinSans, symbols, cjkSerif, cjkSans, scripts,
                        lastResort);
                default:
                    return joinFaces(latinSans, symbols, cjkSans, cjkSerif, scripts, lastResort);
            }
        } else version (OSX) {
            enum latinSans = "Helvetica Neue, Helvetica, Arial, Lucida Grande";
            enum symbols = "Geneva, STIXGeneral, Apple Symbols, Zapf Dingbats";
            string cjkSans = cjkFaces(cjk, "PingFang SC, Hiragino Sans GB, STHeiti, Heiti SC",
                "PingFang TC, PingFang HK, Heiti TC, LiHei Pro",
                "Hiragino Sans, Hiragino Kaku Gothic ProN, Hiragino Kaku Gothic Pro, Osaka",
                "Apple SD Gothic Neo, Nanum Gothic, AppleGothic");
            string cjkSerif = cjkFaces(cjk, "Songti SC, STSong", "Songti TC, LiSong Pro",
                "Hiragino Mincho ProN, Hiragino Mincho Pro", "AppleMyungjo");
            enum scripts = "Geeza Pro, Mshtakan, Kefa, Thonburi, Lao MN, Khmer MN, Myanmar MN, Devanagari Sangam MN, "
                ~ "Bangla Sangam MN, Gurmukhi MN, Gujarati Sangam MN, Oriya Sangam MN, Tamil MN, Telugu MN, "
                ~ "Kannada MN, Malayalam Sangam MN, Sinhala Sangam MN, Kailasa, Plantagenet Cherokee, Euphemia UCAS, "
                ~ "Noto Sans Mongolian, Noto Sans Thaana, Noto Sans Syriac, Noto Sans Yi, Apple Braille";
            enum lastResort = "Arial Unicode MS";
            switch (family) {
                case FontFamily.MonoSpace:
                    return joinFaces("Menlo, Monaco, Courier New", latinSans, symbols, cjkSans, cjkSerif, scripts,
                        lastResort);
                case FontFamily.Serif:
                    return joinFaces("Times New Roman, Times", latinSans, symbols, cjkSerif, cjkSans, scripts,
                        lastResort);
                default:
                    return joinFaces(latinSans, symbols, cjkSans, cjkSerif, scripts, lastResort);
            }
        } else {
            enum latinSans = "Noto Sans, DejaVu Sans, Liberation Sans, FreeSans";
            enum symbols = "Noto Sans Math, Noto Sans Symbols, Noto Sans Symbols2, Noto Sans Symbols 2, Symbola";
            string cjkSans = cjkFaces(cjk,
                "Noto Sans CJK SC, Source Han Sans SC, Source Han Sans CN, Droid Sans Fallback, WenQuanYi Micro Hei, "
                    ~ "WenQuanYi Zen Hei",
                "Noto Sans CJK TC, Noto Sans CJK HK, Source Han Sans TC, Source Han Sans TW, Source Han Sans HK",
                "Noto Sans CJK JP, Source Han Sans JP, Source Han Sans, IPAGothic, IPAexGothic, IPAPGothic, "
                    ~ "TakaoPGothic, TakaoGothic, VL Gothic, UmePlus P Gothic",
                "Noto Sans CJK KR, Source Han Sans KR, Source Han Sans K, NanumGothic, UnDotum, Baekmuk Dotum");
            string cjkSerif = cjkFaces(cjk, "Noto Serif CJK SC, Source Han Serif SC, AR PL UMing CN",
                "Noto Serif CJK TC, Source Han Serif TC, AR PL UMing TW",
                "Noto Serif CJK JP, Source Han Serif JP, IPAMincho, IPAexMincho",
                "Noto Serif CJK KR, Source Han Serif KR, UnBatang, NanumMyeongjo");
            string cjkMono = cjkFaces(cjk, "Noto Sans Mono CJK SC, WenQuanYi Zen Hei Mono, WenQuanYi Micro Hei Mono",
                "Noto Sans Mono CJK TC, Noto Sans Mono CJK HK", "Noto Sans Mono CJK JP",
                "Noto Sans Mono CJK KR, NanumGothicCoding");
            // Noto fonts of living scripts (as in Android), then fonts of distributions (fontconfig 65-nonlatin)
            enum scripts = "Noto Sans Arabic, Noto Naskh Arabic, Noto Sans Hebrew, Noto Sans Armenian, "
                ~ "Noto Sans Georgian, Noto Sans Thai, Noto Sans Lao, Noto Sans Khmer, Noto Sans Myanmar, "
                ~ "Noto Sans Devanagari, Noto Sans Bengali, Noto Sans Gurmukhi, Noto Sans Gujarati, Noto Sans Oriya, "
                ~ "Noto Sans Tamil, Noto Sans Telugu, Noto Sans Kannada, Noto Sans Malayalam, Noto Sans Sinhala, "
                ~ "Noto Serif Tibetan, Noto Sans Ethiopic, Noto Sans Thaana, Noto Sans Syriac, Noto Sans Mongolian, "
                ~ "Noto Sans Yi, Noto Sans Cherokee, Noto Sans Canadian Aboriginal, Noto Sans Tifinagh, Noto Sans NKo, "
                ~ "Noto Sans Adlam, Noto Sans Javanese, Noto Sans Balinese, Noto Sans Sundanese, Noto Sans Tai Le, "
                ~ "Noto Sans New Tai Lue, Noto Sans Tai Tham, Noto Sans Tai Viet, Noto Sans Cham, Noto Sans Vai, "
                ~ "Noto Sans Ol Chiki, Noto Sans Meetei Mayek, Noto Sans Chakma, Noto Sans Lisu, "
                ~ "Lohit Devanagari, Lohit Bengali, Lohit Gurmukhi, Lohit Gujarati, Lohit Odia, Lohit Tamil, "
                ~ "Lohit Telugu, Lohit Kannada, Lohit Malayalam, LKLUG, Loma, Garuda, Waree, Umpush, Abyssinica SIL, "
                ~ "Khmer OS, Phetsarath OT, Padauk, Jomolhari, KacstOne";
            enum serifScripts = "Noto Serif Armenian, Noto Serif Georgian, Noto Serif Hebrew, Noto Serif Thai, "
                ~ "Noto Serif Lao, Noto Serif Khmer, Noto Serif Myanmar, Noto Serif Devanagari, Noto Serif Bengali, "
                ~ "Noto Serif Gurmukhi, Noto Serif Gujarati, Noto Serif Tamil, Noto Serif Telugu, Noto Serif Kannada, "
                ~ "Noto Serif Malayalam, Noto Serif Sinhala, Noto Serif Ethiopic";
            switch (family) {
                case FontFamily.MonoSpace:
                    return joinFaces("DejaVu Sans Mono, Noto Sans Mono, Liberation Mono, FreeMono", latinSans, symbols,
                        cjkMono, cjkSans, cjkSerif, scripts, "DejaVu Serif, FreeSerif");
                case FontFamily.Serif:
                    return joinFaces("DejaVu Serif, Noto Serif, Liberation Serif, FreeSerif", latinSans, symbols,
                        cjkSerif, cjkSans, serifScripts, scripts);
                default:
                    return joinFaces(latinSans, symbols, cjkSans, cjkSerif, scripts, "DejaVu Serif, FreeSerif");
            }
        }
    }

    /// returns the platform's default fallback faces for a font family, CJK fonts in the order of systemCjkLanguage()
    static string defaultFallbackFaces(FontFamily family) {
        return defaultFallbackFaces(family, systemCjkLanguage());
    }

    private static string[] splitFaces(string faces) pure @safe {
        import std.array : split;
        import std.string : strip;
        string[] list;
        foreach (f; faces.split(',')) {
            string name = f.strip;
            if (name.length)
                list ~= name;
        }
        return list;
    }

    /// fallback faces for font families (#888); set to defaults on first use
    private static __gshared string[][FontFamily.max + 1] _fallbackFaces;
    private static __gshared bool _fallbackFacesInitialized;

    private static void initFallbackFaces() {
        if (_fallbackFacesInitialized)
            return;
        _fallbackFacesInitialized = true;
        CjkLanguage cjk = systemCjkLanguage();
        foreach (i, ref list; _fallbackFaces)
            list = splitFaces(defaultFallbackFaces(cast(FontFamily)i, cjk));
    }

    /// sets fallback faces for a font family: comma separated list, in order of preference (#888). Fonts of the
    /// family use installed faces of the list for characters they have no glyphs for. An empty string disables
    /// fallback fonts for the family. The default is defaultFallbackFaces(family).
    static void setFallbackFaces(FontFamily family, string faces) {
        initFallbackFaces();
        _fallbackFaces[family] = splitFaces(faces);
        _glyphSettingsGeneration++; // text sizes may change
        if (_instance) {
            _instance._installedFallbackFacesValid[] = false;
            _instance.releaseFallbackFonts();
        }
    }

    /// returns fallback faces for a font family, as set by setFallbackFaces()
    static string[] fallbackFaces(FontFamily family) {
        initFallbackFaces();
        return _fallbackFaces[family];
    }

    /**
        Returns fallback fonts for a font, not created yet (#888): installed faces of fallbackFaces(primary.family)
        except the primary face, with size, weight and italic of the primary font.

        Override to use other faces (e.g. the platform's font fallback). May return an empty list.
    */
    FallbackFontList getFallbackFonts(Font primary) {
        import std.uni : icmp;
        FallbackFontList list = FallbackFontList(this, primary);
        foreach (installed; installedFallbackFaces(primary.family))
            if (icmp(installed, primary.face) != 0)
                list.add(installed, primary.family, primary.weight, primary.italic, primary.size);
        return list;
    }

    private string[][FontFamily.max + 1] _installedFallbackFaces;
    private bool[FontFamily.max + 1] _installedFallbackFacesValid;

    /// installed faces of fallbackFaces(family), without duplicates (case insensitive); cached until fallback
    /// faces or installed faces change
    protected string[] installedFallbackFaces(FontFamily family) {
        import std.uni : icmp;
        if (!_installedFallbackFacesValid[family]) {
            string[] res;
            foreach (face; fallbackFaces(family)) {
                string installed = findInstalledFace(face);
                if (installed.length && !res.canFind!((a, b) => icmp(a, b) == 0)(installed))
                    res ~= installed;
            }
            _installedFallbackFaces[family] = res;
            _installedFallbackFacesValid[family] = true;
        }
        return _installedFallbackFaces[family];
    }

    /// call when fonts are registered or removed: fallback faces are looked up again (#888)
    protected void installedFacesChanged() {
        _installedFallbackFacesValid[] = false;
        _installedFaceByLowerNameValid = false;
    }

    private string[string] _installedFaceByLowerName;
    private bool _installedFaceByLowerNameValid;

    /// returns name of the installed font face matching face (case insensitive), null if it's not installed;
    /// looked up in a table of getFaces(), built on first use after installedFacesChanged()
    protected string findInstalledFace(string face) {
        import std.uni : toLower;
        if (!_installedFaceByLowerNameValid) {
            _installedFaceByLowerName = null;
            foreach (ref props; getFaces()) {
                string key = props.face.toLower;
                if (key !in _installedFaceByLowerName)
                    _installedFaceByLowerName[key] = props.face;
            }
            _installedFaceByLowerNameValid = true;
        }
        if (auto p = face.toLower in _installedFaceByLowerName)
            return *p;
        return null;
    }

    /// get min font size for antialiased fonts (0 means antialiasing always on, some big value = always off)
    static @property int minAnitialiasedFontSize() {
        return _minAnitialiasedFontSize;
    }

    /// set new min font size for antialiased fonts - fonts with size >= specified value will be antialiased (0 means antialiasing always on, some big value = always off)
    static @property void minAnitialiasedFontSize(int size) {
        if (_minAnitialiasedFontSize != size) {
            _minAnitialiasedFontSize = size;
            glyphSettingsChanged();
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
            glyphSettingsChanged();
        }
    }

    /// get current subpixel rendering mode for fonts (aka ClearType): None, RGB or BGR, never Auto (for Auto, the
    /// mode detected for the platform, see subpixelRenderingModeSetting)
    static @property SubpixelRenderingMode subpixelRenderingMode() {
        return _subpixelRenderingMode;
    }

    /// set subpixel rendering mode for fonts (aka ClearType): None, RGB, BGR, or Auto (the default) for the mode
    /// detected for the platform: systemSubpixelRenderingMode (#882)
    static @property void subpixelRenderingMode(SubpixelRenderingMode mode) {
        _subpixelRenderingModeSetting = mode;
        updateSubpixelRenderingMode();
    }

    /// subpixel rendering mode as set: None, RGB, BGR or Auto (#882)
    static @property SubpixelRenderingMode subpixelRenderingModeSetting() {
        return _subpixelRenderingModeSetting;
    }

    /// subpixel rendering mode detected for the platform, used when subpixelRenderingMode is set to Auto (#882):
    /// ClearType settings on Windows, Xft.rgba or fontconfig on Linux (see detectSubpixelRenderingMode()); None for
    /// other platforms and backends
    static @property SubpixelRenderingMode systemSubpixelRenderingMode() {
        return _systemSubpixelRenderingMode;
    }

    /// set subpixel rendering mode detected for the platform; backends set it at startup
    static @property void systemSubpixelRenderingMode(SubpixelRenderingMode mode) {
        _systemSubpixelRenderingMode = mode == SubpixelRenderingMode.Auto ? SubpixelRenderingMode.None : mode;
        updateSubpixelRenderingMode();
    }

    private static void updateSubpixelRenderingMode() {
        SubpixelRenderingMode mode = _subpixelRenderingModeSetting == SubpixelRenderingMode.Auto
            ? _systemSubpixelRenderingMode : _subpixelRenderingModeSetting;
        if (_subpixelRenderingMode != mode) {
            _subpixelRenderingMode = mode;
            // glyphs are rendered for a mode: render them again (#871)
            glyphSettingsChanged();
        }
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
            glyphSettingsChanged();
        }
    }

    void clearGlyphCaches() {
        // override to clear glyph caches
    }

    /// incremented when a setting that changes glyphs (and maybe their widths) is changed: fonts drop the text sizes
    /// and metrics they cached (#888)
    private static __gshared uint _glyphSettingsGeneration;

    /// a setting that changes glyphs is changed: clear glyph caches, invalidate text sizes and metrics cached by fonts
    private static void glyphSettingsChanged() {
        _glyphSettingsGeneration++;
        if (_instance)
            _instance.clearGlyphCaches();
    }

    ~this() {
        if (destroyedByGC(this.classinfo.name)) return; // finalized by the GC: report the leak (#975)
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
        if (inGCFinalizer()) return; // finalized by the GC: a leak, touch nothing (#975)
        clear();
    }
}

/// number of Unicode codepoints (U+0000..U+10FFFF): characters >= MAX_UNICODE_CODEPOINTS are missing in any font
enum uint MAX_UNICODE_CODEPOINTS = 0x110000;

/// presence of codepoint (glyph) in font
enum CodepointPresence : ubyte {
    /// not checked yet
    unknown = 0,
    /// font has glyph for codepoint
    present = 1,
    /// font has no glyph for codepoint
    missing = 2
}

/// East Asian Wide (W) and Fullwidth (F) characters, sorted ranges; generated from Unicode 18.0 EastAsianWidth.txt
/// (W and F lines, adjacent ranges merged)
private immutable dchar[2][] WIDE_CHAR_RANGES = [
    [0x1100, 0x115F], [0x231A, 0x231B], [0x2329, 0x232A], [0x23E9, 0x23EC], [0x23F0, 0x23F0], [0x23F3, 0x23F3],
    [0x25FD, 0x25FE], [0x2614, 0x2615], [0x2630, 0x2637], [0x2648, 0x2653], [0x267F, 0x267F], [0x268A, 0x268F],
    [0x2693, 0x2693], [0x26A1, 0x26A1], [0x26AA, 0x26AB], [0x26BD, 0x26BE], [0x26C4, 0x26C5], [0x26CE, 0x26CE],
    [0x26D4, 0x26D4], [0x26EA, 0x26EA], [0x26F2, 0x26F3], [0x26F5, 0x26F5], [0x26FA, 0x26FA], [0x26FD, 0x26FD],
    [0x2705, 0x2705], [0x270A, 0x270B], [0x2728, 0x2728], [0x274C, 0x274C], [0x274E, 0x274E], [0x2753, 0x2755],
    [0x2757, 0x2757], [0x2795, 0x2797], [0x27B0, 0x27B0], [0x27BF, 0x27BF], [0x2B1B, 0x2B1C], [0x2B50, 0x2B50],
    [0x2B55, 0x2B55], [0x2E80, 0x2E99], [0x2E9B, 0x2EF3], [0x2F00, 0x2FD5], [0x2FF0, 0x303E], [0x3041, 0x3096],
    [0x3099, 0x30FF], [0x3105, 0x312F], [0x3131, 0x318E], [0x3190, 0x31E5], [0x31EF, 0x321E], [0x3220, 0x3247],
    [0x3250, 0xA48C], [0xA490, 0xA4C6], [0xA960, 0xA97C], [0xAC00, 0xD7A3], [0xF900, 0xFAFF], [0xFE10, 0xFE19],
    [0xFE30, 0xFE52], [0xFE54, 0xFE66], [0xFE68, 0xFE6B], [0xFF01, 0xFF60], [0xFFE0, 0xFFE6], [0x16FE0, 0x16FE4],
    [0x16FF0, 0x16FF6], [0x17000, 0x18CDA], [0x18CFF, 0x18D20], [0x18D80, 0x18DF2], [0x18E00, 0x19191],
    [0x191A0, 0x191D2], [0x1AFF0, 0x1AFF3], [0x1AFF5, 0x1AFFB], [0x1AFFD, 0x1AFFE], [0x1B000, 0x1B128],
    [0x1B132, 0x1B132], [0x1B150, 0x1B152], [0x1B155, 0x1B155], [0x1B164, 0x1B168], [0x1B170, 0x1B2FB],
    [0x1D300, 0x1D356], [0x1D360, 0x1D376], [0x1F004, 0x1F004], [0x1F0CF, 0x1F0CF], [0x1F18E, 0x1F18E],
    [0x1F191, 0x1F19A], [0x1F1AE, 0x1F1AE], [0x1F200, 0x1F202], [0x1F210, 0x1F23B], [0x1F240, 0x1F248],
    [0x1F250, 0x1F251], [0x1F260, 0x1F265], [0x1F300, 0x1F320], [0x1F32D, 0x1F335], [0x1F337, 0x1F37C],
    [0x1F37E, 0x1F393], [0x1F3A0, 0x1F3CA], [0x1F3CF, 0x1F3D3], [0x1F3E0, 0x1F3F0], [0x1F3F4, 0x1F3F4],
    [0x1F3F8, 0x1F43E], [0x1F440, 0x1F440], [0x1F442, 0x1F4FC], [0x1F4FF, 0x1F53D], [0x1F54B, 0x1F54E],
    [0x1F550, 0x1F567], [0x1F57A, 0x1F57A], [0x1F595, 0x1F596], [0x1F5A4, 0x1F5A4], [0x1F5FB, 0x1F64F],
    [0x1F680, 0x1F6C5], [0x1F6CC, 0x1F6CC], [0x1F6D0, 0x1F6D2], [0x1F6D5, 0x1F6D9], [0x1F6DC, 0x1F6DF],
    [0x1F6EB, 0x1F6EC], [0x1F6F4, 0x1F6FC], [0x1F7DA, 0x1F7DA], [0x1F7E0, 0x1F7EB], [0x1F7F0, 0x1F7F0],
    [0x1F90C, 0x1F93A], [0x1F93C, 0x1F945], [0x1F947, 0x1F9FF], [0x1FA70, 0x1FA7C], [0x1FA80, 0x1FAC6],
    [0x1FAC8, 0x1FAC8], [0x1FACC, 0x1FADD], [0x1FADF, 0x1FAEB], [0x1FAEF, 0x1FAFA], [0x20000, 0x2FFFD],
    [0x30000, 0x3FFFD]
];

/// returns true for East Asian Wide and Fullwidth characters, which take 2 cells of a fixed pitch font (#888)
bool isWideChar(dchar ch) pure nothrow @nogc @safe {
    if (ch < 0x1100)
        return false;
    size_t lo = 0, hi = WIDE_CHAR_RANGES.length;
    while (lo < hi) {
        size_t mid = (lo + hi) / 2;
        if (ch < WIDE_CHAR_RANGES[mid][0])
            hi = mid;
        else if (ch > WIDE_CHAR_RANGES[mid][1])
            lo = mid + 1;
        else
            return true;
    }
    return false;
}

@safe unittest {
    foreach (i; 1 .. WIDE_CHAR_RANGES.length)
        assert(WIDE_CHAR_RANGES[i][0] > WIDE_CHAR_RANGES[i - 1][1]); // sorted, not overlapping
    assert(!isWideChar('A') && !isWideChar(0x00E9) && !isWideChar(0x0416) && !isWideChar(0x2192));
    assert(!isWideChar(0x2605) && !isWideChar(0x2713)); // ambiguous / neutral symbols: 1 cell
    assert(isWideChar(0x4E2D) && isWideChar(0x65E5) && isWideChar(0x3042) && isWideChar(0x30AB)); // CJK, kana
    assert(isWideChar(0xAC00) && isWideChar(0xD55C) && isWideChar(0xD7A3) && !isWideChar(0xD7A4)); // Hangul
    assert(isWideChar(0x3000) && !isWideChar(0x303F) && isWideChar(0xFF21) && !isWideChar(0xFF61));
    assert(isWideChar(0x1F600) && isWideChar(0x20000) && !isWideChar(0xE000));
    assert(!isWideChar(0x1F321) && !isWideChar(0x1F336) && isWideChar(0x1F335)); // emoji: text presentation ones are N
    assert(isWideChar(0x16FF0) && isWideChar(0x1D300) && isWideChar(0x2630));
}

/// smallest number of bits, a power of two, enough to store values 0..maxValue
private uint bitsPerEnumItem(ulong maxValue) pure nothrow @nogc @safe {
    uint bits = 1;
    while (bits < 64 && (1UL << bits) <= maxValue)
        bits *= 2;
    return bits;
}

/**
    Array of size small enum (or unsigned integer) items packed into bits.

    Items are stored in chunkCount chunks of the same size, allocated on the first write of a non-zero value
    to a chunk; items of not allocated chunks are 0 (cast(T)0 is the default value).
    Chunks are allocated with malloc: no GC scanning; they are freed by clear() or the destructor. Not copyable.
*/
struct EnumArray(T, uint size, uint chunkCount) {
    static assert(size > 0 && chunkCount > 0 && chunkCount <= size, "EnumArray: bad size or chunkCount");
    static assert(T.min >= 0, "EnumArray: item values must not be negative");

    /// number of bits per item: enough to store T.max, a power of two
    enum uint BITS_PER_ITEM = bitsPerEnumItem(T.max);
    static assert(BITS_PER_ITEM <= 32, "EnumArray: item type is too big");
    /// items in one uint
    enum uint ITEMS_PER_UINT = 32 / BITS_PER_ITEM;
    /// items in one chunk
    enum uint ITEMS_PER_CHUNK = (size + chunkCount - 1) / chunkCount;
    /// size of one chunk in uints
    enum uint CHUNK_SIZE_UINTS = (ITEMS_PER_CHUNK + ITEMS_PER_UINT - 1) / ITEMS_PER_UINT;
    private enum uint ITEM_MASK = BITS_PER_ITEM == 32 ? uint.max : (1u << BITS_PER_ITEM) - 1;

    private alias Chunk = uint[CHUNK_SIZE_UINTS];
    /// chunk pointers, null for chunks not allocated yet
    private Chunk*[chunkCount] _chunks;

    @disable this(this);

    // calloc/free are @system: each chunk is allocated here, owned by this (non-copyable) array only, and its
    // pointer is cleared when it's freed, so no reference to a freed chunk remains
    private static Chunk* allocChunk() @trusted nothrow @nogc {
        Chunk* chunk = cast(Chunk*)calloc(1, Chunk.sizeof);
        if (!chunk)
            onOutOfMemoryError();
        return chunk;
    }
    private static void freeChunk(Chunk* chunk) @trusted nothrow @nogc {
        free(chunk);
    }

    /// returns item by index; cast(T)0 if index >= size or its chunk is not allocated
    T get(uint index) const @safe pure nothrow @nogc {
        if (index >= size)
            return cast(T)0;
        const(Chunk)* chunk = _chunks[index / ITEMS_PER_CHUNK];
        if (!chunk)
            return cast(T)0;
        uint i = index % ITEMS_PER_CHUNK;
        uint shift = (i % ITEMS_PER_UINT) * BITS_PER_ITEM;
        return cast(T)(((*chunk)[i / ITEMS_PER_UINT] >> shift) & ITEM_MASK);
    }

    /// sets item value, allocates its chunk if needed; ignored if index >= size
    void set(uint index, T value) @safe nothrow @nogc {
        if (index >= size)
            return;
        uint chunkIndex = index / ITEMS_PER_CHUNK;
        Chunk* chunk = _chunks[chunkIndex];
        if (!chunk) {
            if (value == cast(T)0)
                return; // default value: nothing to store
            chunk = allocChunk();
            _chunks[chunkIndex] = chunk;
        }
        uint i = index % ITEMS_PER_CHUNK;
        uint shift = (i % ITEMS_PER_UINT) * BITS_PER_ITEM;
        uint* p = &(*chunk)[i / ITEMS_PER_UINT];
        *p = (*p & ~(ITEM_MASK << shift)) | ((cast(uint)value & ITEM_MASK) << shift);
    }

    /// frees all chunks: all items become 0
    void clear() @safe nothrow @nogc {
        foreach (ref chunk; _chunks) {
            if (chunk) {
                freeChunk(chunk);
                chunk = null;
            }
        }
    }

    /// frees chunks
    ~this() @safe nothrow @nogc {
        clear();
    }
}

/**
    Cache of codepoint (glyph) presence in a font face (#886).

    One cache is shared by all instances (sizes) of the same font face; it is owned by the font manager item of the
    face. Font instances read it before checking a codepoint in the font (Font.hasCodepoint(), getCharGlyph()), and
    store what they find out about codepoints. Allocated on the first write: about 1 KB per 4096 codepoints used.
    Not copyable.
*/
struct CodepointPresenceCache {
    private alias PresenceArray = EnumArray!(CodepointPresence, MAX_UNICODE_CODEPOINTS, MAX_UNICODE_CODEPOINTS / 0x1000);
    static assert(__traits(isZeroInit, PresenceArray));
    private PresenceArray* _array;

    @disable this(this);

    // calloc/free are @system: the array is owned by this (non-copyable) cache only, and the pointer is cleared
    // when it's freed
    private static PresenceArray* allocArray() @trusted nothrow @nogc {
        auto array = cast(PresenceArray*)calloc(1, PresenceArray.sizeof); // zero bytes are PresenceArray.init
        if (!array)
            onOutOfMemoryError();
        return array;
    }
    private static void freeArray(PresenceArray* array) @trusted nothrow @nogc {
        free(array);
    }

    /// returns presence of codepoint ch, unknown if not cached or ch >= MAX_UNICODE_CODEPOINTS
    CodepointPresence getPresence(dchar ch) const @safe pure nothrow @nogc {
        if (ch >= MAX_UNICODE_CODEPOINTS || !_array)
            return CodepointPresence.unknown;
        return _array.get(ch);
    }

    /// stores presence of codepoint ch; ignored for ch >= MAX_UNICODE_CODEPOINTS and for unknown presence
    void setPresence(dchar ch, CodepointPresence presence) @safe nothrow @nogc {
        if (ch >= MAX_UNICODE_CODEPOINTS || presence == CodepointPresence.unknown)
            return;
        if (!_array)
            _array = allocArray();
        _array.set(ch, presence);
    }

    /// clears whole cache
    void clear() @safe nothrow @nogc {
        if (_array) {
            _array.clear();
            freeArray(_array);
            _array = null;
        }
    }

    ~this() @safe nothrow @nogc {
        clear();
    }
}

@safe unittest {
    // EnumArray (#886)
    EnumArray!(CodepointPresence, 0x110000, 0x110) a;
    static assert(a.BITS_PER_ITEM == 2 && a.ITEMS_PER_CHUNK == 0x1000 && a.CHUNK_SIZE_UINTS == 256);
    assert(a.get(0) == CodepointPresence.unknown);
    assert(a.get(0x10FFFF) == CodepointPresence.unknown);
    a.set(0x41, CodepointPresence.present);
    a.set(0x42, CodepointPresence.missing);
    a.set(0x10FFFF, CodepointPresence.missing);
    a.set(0x110000, CodepointPresence.present); // out of range: ignored
    a.set(0x5000, CodepointPresence.unknown); // default value in a not allocated chunk: nothing allocated
    assert(a.get(0x40) == CodepointPresence.unknown);
    assert(a.get(0x41) == CodepointPresence.present);
    assert(a.get(0x42) == CodepointPresence.missing);
    assert(a.get(0x43) == CodepointPresence.unknown);
    assert(a.get(0x10FFFF) == CodepointPresence.missing);
    assert(a.get(0x110000) == CodepointPresence.unknown);
    assert(a._chunks[0] !is null && a._chunks[5] is null && a._chunks[0x10F] !is null);
    a.set(0x41, CodepointPresence.missing); // overwrite, neighbours kept
    assert(a.get(0x41) == CodepointPresence.missing && a.get(0x42) == CodepointPresence.missing && a.get(0x40) == CodepointPresence.unknown);
    a.set(0x42, CodepointPresence.unknown);
    assert(a.get(0x42) == CodepointPresence.unknown && a.get(0x41) == CodepointPresence.missing);
    a.clear();
    assert(a.get(0x41) == CodepointPresence.unknown && a._chunks[0] is null);

    // other item sizes; size not divisible by chunkCount
    enum Five : ubyte { a, b, c, d, e }
    EnumArray!(Five, 1000, 3) b;
    static assert(b.BITS_PER_ITEM == 4 && b.ITEMS_PER_CHUNK == 334 && b.CHUNK_SIZE_UINTS == 42);
    foreach (uint i; 0 .. 1000)
        b.set(i, cast(Five)(i % 5));
    foreach (uint i; 0 .. 1000)
        assert(b.get(i) == cast(Five)(i % 5));
    EnumArray!(bool, 100, 1) c;
    static assert(c.BITS_PER_ITEM == 1);
    c.set(31, true);
    c.set(32, true);
    assert(!c.get(30) && c.get(31) && c.get(32) && !c.get(33));
    EnumArray!(ushort, 10, 2) d;
    static assert(d.BITS_PER_ITEM == 16);
    d.set(9, 0xFFFF);
    d.set(8, 0x1234);
    assert(d.get(9) == 0xFFFF && d.get(8) == 0x1234 && d.get(7) == 0);

    // CodepointPresenceCache
    CodepointPresenceCache cache;
    assert(cache.getPresence('A') == CodepointPresence.unknown && cache._array is null);
    cache.setPresence('A', CodepointPresence.unknown); // ignored: nothing allocated
    assert(cache._array is null);
    cache.setPresence('A', CodepointPresence.present);
    cache.setPresence(0x4E2D, CodepointPresence.missing);
    cache.setPresence(cast(dchar)0x110000, CodepointPresence.present); // ignored
    assert(cache.getPresence('A') == CodepointPresence.present);
    assert(cache.getPresence(0x4E2D) == CodepointPresence.missing);
    assert(cache.getPresence('B') == CodepointPresence.unknown);
    assert(cache.getPresence(cast(dchar)0x110000) == CodepointPresence.unknown);
    cache.clear();
    assert(cache.getPresence('A') == CodepointPresence.unknown && cache._array is null);
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

/**
 * Detect the subpixel rendering mode matching the system font smoothing settings (#880, #882).
 *
 * Windows: the ClearType settings GDI uses for its own text: RGB or BGR when font smoothing is on and its type
 * is ClearType (SPI_GETFONTSMOOTHING, SPI_GETFONTSMOOTHINGTYPE, SPI_GETFONTSMOOTHINGORIENTATION), None for
 * standard (grayscale) smoothing or no smoothing.
 *
 * Linux and other X11 desktops: Xft.rgba (and Xft.antialias) of the X resources set by the desktop, or the
 * subpixel order fontconfig configures (FC_RGBA) when Xft.rgba is not set; see dlangui.platforms.common.xftdpi.
 *
 * Other platforms: None.
 */
SubpixelRenderingMode detectSubpixelRenderingMode() {
    version (Windows) {
        import core.sys.windows.windows : SystemParametersInfoW, BOOL, UINT;
        enum : UINT {
            SPI_GETFONTSMOOTHING = 0x004A,
            SPI_GETFONTSMOOTHINGTYPE = 0x200A,
            SPI_GETFONTSMOOTHINGORIENTATION = 0x2012,
            FE_FONTSMOOTHINGCLEARTYPE = 2,
            FE_FONTSMOOTHINGORIENTATIONBGR = 0,
        }
        BOOL smoothing;
        UINT type, orientation;
        if (!SystemParametersInfoW(SPI_GETFONTSMOOTHING, 0, &smoothing, 0) || !smoothing)
            return SubpixelRenderingMode.None;
        if (!SystemParametersInfoW(SPI_GETFONTSMOOTHINGTYPE, 0, &type, 0) || type != FE_FONTSMOOTHINGCLEARTYPE)
            return SubpixelRenderingMode.None;
        if (!SystemParametersInfoW(SPI_GETFONTSMOOTHINGORIENTATION, 0, &orientation, 0))
            return SubpixelRenderingMode.RGB;
        return orientation == FE_FONTSMOOTHINGORIENTATIONBGR ? SubpixelRenderingMode.BGR : SubpixelRenderingMode.RGB;
    } else {
        import dlangui.platforms.common.xftdpi : detectXftSubpixelRenderingMode;
        return detectXftSubpixelRenderingMode();
    }
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

// fontFileFaces: family names and fixed pitch from the name and post tables, font collections (#652)
unittest {
    // big-endian helpers to build a font file
    ubyte[] be16(uint v) { return [cast(ubyte)(v >> 8), cast(ubyte)v]; }
    ubyte[] be32(uint v) { return be16(v >> 16) ~ be16(v & 0xFFFF); }
    // one face (sfnt) starting at base in the file: name table with a Mac and a Windows family name, post table
    ubyte[] face(size_t base, string windowsName, string macName, bool fixedPitch, uint sfntVersion = 0x0001_0000,
            uint platform = 3, uint encoding = 1) {
        ubyte[] winBytes;
        foreach (wchar ch; windowsName)
            winBytes ~= be16(ch);
        ubyte[] macBytes = cast(ubyte[])macName.dup;
        ubyte[] strings = macBytes ~ winBytes;
        ubyte[] name = be16(0) ~ be16(3) ~ be16(6 + 3 * 12)
            ~ be16(1) ~ be16(0) ~ be16(0) ~ be16(1) ~ be16(cast(uint)macBytes.length) ~ be16(0) // Mac, family
            ~ be16(3) ~ be16(1) ~ be16(0x409) ~ be16(2) ~ be16(2) ~ be16(0) // Windows, subfamily: ignored
            ~ be16(platform) ~ be16(encoding) ~ be16(0x409) ~ be16(1) ~ be16(cast(uint)winBytes.length) ~ be16(cast(uint)macBytes.length)
            ~ strings;
        ubyte[] post = be32(0x0003_0000) ~ be32(0) ~ be16(0) ~ be16(0) ~ be32(fixedPitch ? 1 : 0) ~ new ubyte[16];
        size_t nameOffset = base + 12 + 2 * 16;
        size_t postOffset = nameOffset + name.length;
        return be32(sfntVersion) ~ be16(2) ~ be16(0) ~ be16(0) ~ be16(0)
            ~ cast(ubyte[])"name" ~ be32(0) ~ be32(cast(uint)nameOffset) ~ be32(cast(uint)name.length)
            ~ cast(ubyte[])"post" ~ be32(0) ~ be32(cast(uint)postOffset) ~ be32(cast(uint)post.length)
            ~ name ~ post;
    }

    // single face: the Windows name is preferred to the Mac name
    ubyte[] ttf = face(0, "Test Sans \u00C4", "Mac Name", false);
    FontFileFaceInfo[] faces = fontFileFaces(ttf);
    assert(faces.length == 1);
    assert(faces[0].family == "Test Sans \u00C4" && !faces[0].fixedPitch);
    assert(fontFileFaces(face(0, "Test Mono", "Mac", true, 0x4F54_544F /* OTTO */)) == [FontFileFaceInfo("Test Mono", true)]);
    // only a Mac name
    assert(fontFileFaces(face(0, "", "Mac Only", false))[0].family == "Mac Only");
    // Windows Symbol encoding (symbol and icon fonts) and Unicode platform names, preferred to the Mac name
    assert(fontFileFaces(face(0, "Icons", "Mac", false, 0x0001_0000, 3, 0))[0].family == "Icons");
    assert(fontFileFaces(face(0, "Unicode Name", "Mac", false, 0x0001_0000, 0, 3))[0].family == "Unicode Name");

    // collection with two faces
    size_t first = 12 + 2 * 4;
    ubyte[] face1 = face(first, "Coll One", "", false);
    ubyte[] face2 = face(first + face1.length, "Coll Two", "", true);
    ubyte[] ttc = cast(ubyte[])"ttcf" ~ be32(0x0001_0000) ~ be32(2) ~ be32(cast(uint)first)
        ~ be32(cast(uint)(first + face1.length)) ~ face1 ~ face2;
    assert(fontFileFaces(ttc) == [FontFileFaceInfo("Coll One", false), FontFileFaceInfo("Coll Two", true)]);

    // not a font, truncated data: no faces, no range errors
    assert(fontFileFaces(null).length == 0);
    assert(fontFileFaces(cast(const(ubyte)[])"not a font file at all").length == 0);
    // truncated: no face, or a face with one of the names in the font, never a partial name; without the
    // complete post table, fixed pitch isn't detected (the second face of a collection comes after the first)
    foreach (len; 0 .. ttf.length) {
        FontFileFaceInfo[] truncated = fontFileFaces(ttf[0 .. len]);
        assert(truncated.length == 0 || (truncated.length == 1
            && (truncated[0].family == "Test Sans \u00C4" || truncated[0].family == "Mac Name")));
    }
    string[] collection = ["Coll One", "Coll Two"];
    foreach (len; 0 .. ttc.length) {
        FontFileFaceInfo[] truncated = fontFileFaces(ttc[0 .. len]);
        assert(truncated.length <= 2);
        foreach (i, f; truncated)
            assert(f.family == collection[i] && (i == 1 || !f.fixedPitch));
    }

    // real font files, where installed
    import std.file : exists, read;
    static struct Known { string path; string family; bool fixedPitch; }
    foreach (k; [Known("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", "DejaVu Sans", false),
                 Known("/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf", "DejaVu Sans Mono", true),
                 Known(`C:\Windows\Fonts\arial.ttf`, "Arial", false),
                 Known(`C:\Windows\Fonts\cour.ttf`, "Courier New", true)]) {
        if (!exists(k.path))
            continue;
        FontFileFaceInfo[] found = fontFileFaces(cast(const(ubyte)[])read(k.path));
        assert(found == [FontFileFaceInfo(k.family, k.fixedPitch)], k.path);
    }
}
