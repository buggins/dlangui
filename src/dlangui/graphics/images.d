// Written in the D programming language.

/**
This module contains image loading functions.

Currently uses FreeImage.

Usage of libpng is not feasible under linux due to conflicts of library and binding versions.

Synopsis:

----
import dlangui.graphics.images;

----

Copyright: Vadim Lopatin, 2014
License:   Boost License 1.0
Authors:   Vadim Lopatin, coolreader.org@gmail.com
*/
module dlangui.graphics.images;

public import dlangui.core.config;
static if (BACKEND_GUI):

import arsd.image;

import dlangui.core.logger;
import dlangui.core.types;
import dlangui.graphics.colors;
import dlangui.graphics.drawbuf;
import dlangui.core.streams;
import std.path;
import std.conv : to;


/// true if data starts with the header of a Windows icon (.ico) file
private bool isIco(const(ubyte)[] data) {
    // ICONDIR: reserved 0, type 1 (icon), image count > 0
    return data.length >= 6 && data[0] == 0 && data[1] == 0 && data[2] == 1 && data[3] == 0
        && (data[4] | data[5]) != 0;
}

/// decode the largest image of a Windows icon (.ico) file (#211)
/// (arsd.ico does the same, but its DUB subpackage misses the png and bmp dependencies)
private MemoryImage largestIcoImage(const(ubyte)[] data) {
    import arsd.bmp : readBmp;
    import arsd.png : readPngFromBytes;
    uint u16(size_t pos) { return data[pos] | (data[pos + 1] << 8); }
    uint u32(size_t pos) { return u16(pos) | (u16(pos + 2) << 16); }
    // ICONDIR (6 bytes), then an ICONDIRENTRY (16 bytes) per image; width/height 0 means 256
    uint count = u16(4);
    if (data.length < 6 + 16 * count)
        throw new Exception("invalid icon file: too short");
    size_t best = size_t.max;
    uint bestArea = 0;
    foreach (i; 0 .. count) {
        size_t e = 6 + 16 * i;
        uint w = data[e] ? data[e] : 256;
        uint h = data[e + 1] ? data[e + 1] : 256;
        if (w * h > bestArea) {
            bestArea = w * h;
            best = e;
        }
    }
    uint size = u32(best + 8);
    uint offset = u32(best + 12);
    if (offset >= data.length || size < 4 || size > data.length - offset)
        throw new Exception("invalid icon file: image data out of the file");
    const(ubyte)[] image = data[offset .. offset + size];
    if (image[0 .. 4] == "\x89PNG")
        return readPngFromBytes(image);
    // a BMP without the file header, followed by the AND (transparency) mask
    return readBmp(image, false, false, true);
}

/// true if the image is an SVG file (#843): by the .svg extension, or by its content
bool isSvgImage(string filename, const(ubyte)[] data) {
    import std.uni : toLower;
    if (filename.length > 4 && filename[$ - 4 .. $].toLower == ".svg")
        return true;
    return guessImageFormatFromMemory(data) == ImageFileFormat.Svg;
}

/// Rasterize an SVG image (#843) in its own size (width and height in px, at BASE_DPI = 96) multiplied by scale.
/// If filename has a size suffix (`name.24x24.svg`, see svgSizeSuffix), that size is used instead, with the
/// content fitted and centered in it.
/// `currentColor` in the SVG is replaced by currentColor (0xRRGGBB), so one-color icons can follow the theme.
/// <style> blocks and <use> references are supported through arsd.dom. Returns null on errors.
ColorDrawBuf renderSvg(const(ubyte)[] data, double scale = 1.0, uint currentColor = 0x000000, string filename = null) {
    return renderSvgImpl(data, scale, 0, currentColor, filename);
}

/// Rasterize an SVG image (#843) so that its larger side is size pixels, keeping the aspect ratio
/// (e.g. scalable icons of an icon theme, whose own size can be anything). Returns null on errors.
ColorDrawBuf renderSvgToSize(const(ubyte)[] data, int size, uint currentColor = 0x000000, string filename = null) {
    return renderSvgImpl(data, 1.0, size, currentColor, filename);
}

/// Rasterize an SVG file so that its larger side is size pixels (see renderSvgToSize). Returns null on errors.
ColorDrawBuf renderSvgFile(string filename, int size, uint currentColor = 0x000000) {
    static import std.file;
    try {
        return renderSvgToSize(cast(const(ubyte)[])std.file.read(filename), size, currentColor, filename);
    } catch (Exception e) {
        Log.e("exception while loading image from file ", filename, ": ", e.msg);
        return null;
    }
}

/// arsd.svg keeps only <path> elements of a <clipPath> in <defs>; other shapes leave the clip area empty,
/// which hides everything clipped by it. Figma, for example, clips icons with a <rect>: convert <rect> and
/// <circle> in clip paths to equivalent <path> elements (rounded corners of a clip rect are ignored).
private string clipShapesToPaths(string text) {
    import std.conv : to, ConvException;
    import std.format : format;
    import std.regex : regex, replaceAll, matchFirst, Captures;
    auto clipRe = regex(`<clipPath\b.*?</clipPath>`, "s");
    auto shapeRe = regex(`<(rect|circle)\b([^>]*?)(/?)>`);
    auto closeRe = regex(`</(rect|circle)\s*>`);
    double num(string attrs, string name) {
        auto m = matchFirst(attrs, regex(`(?:^|\s)` ~ name ~ `\s*=\s*["']\s*([-+0-9.eE]+)`));
        if (m.empty)
            return 0;
        try {
            return to!double(m[1]);
        } catch (ConvException) {
            return 0;
        }
    }
    string shapeToPath(Captures!string m) {
        string attrs = m[2];
        string d;
        if (m[1] == "rect") {
            double w = num(attrs, "width");
            d = format("M%g %gh%gv%gh%gz", num(attrs, "x"), num(attrs, "y"), w, num(attrs, "height"), -w);
        } else {
            double r = num(attrs, "r");
            double cx = num(attrs, "cx");
            double cy = num(attrs, "cy");
            d = format("M%g %ga%g %g 0 1 0 %g 0a%g %g 0 1 0 %g 0z", cx - r, cy, r, r, 2 * r, r, r, -2 * r);
        }
        // the other attributes (e.g. transform) are kept; x, width etc. mean nothing for a path
        return "<path d=\"" ~ d ~ "\"" ~ attrs ~ m[3] ~ ">";
    }
    string fixClip(Captures!string m) {
        return replaceAll(replaceAll!shapeToPath(m.hit, shapeRe), closeRe, "</path>");
    }
    return replaceAll!fixClip(text, clipRe);
}

private ColorDrawBuf renderSvgImpl(const(ubyte)[] data, double scale, int fitSize, uint currentColor, string filename) {
    import std.array : replace;
    import std.algorithm : canFind;
    import std.format : format;
    import std.math : ceil;
    import std.string : indexOf, CaseSensitive;

    string text = cast(string)data.idup;
    if (text.indexOf("currentcolor", CaseSensitive.no) >= 0) {
        string rgb = format("#%06X", currentColor & 0xFFFFFF);
        text = text.replace("currentColor", rgb).replace("currentcolor", rgb);
    }
    NSVG * svg;
    if (text.canFind("<clipPath"))
        text = clipShapesToPaths(text);
    if (text.canFind("<style") || text.canFind("<use")) {
        // the preprocessor applies style sheets and copies <use> targets; it throws on XML it can't handle
        try {
            svg = nsvgParseWithPreprocessor(text);
        } catch (Exception e) {
            Log.w("SVG preprocessing failed for ", filename, ": ", e.msg);
        }
    }
    if (!svg)
        svg = nsvgParse(text);
    if (!svg || svg.width <= 0 || svg.height <= 0) {
        Log.e("Failed to parse SVG image ", filename);
        if (svg)
            svg.kill();
        return null;
    }
    scope(exit) svg.kill();
    // the size is rounded up, so the image is never clipped; a small tolerance avoids an extra pixel
    // from floating point errors (e.g. 16 * 1.25)
    static int pixels(double size) {
        int n = cast(int)ceil(size - 0.01);
        return n < 1 ? 1 : n;
    }
    int w, h;
    float contentScale;
    float tx = 0, ty = 0;
    int sizedW, sizedH;
    import dlangui.graphics.resources : svgSizeSuffix;
    if (fitSize > 0) {
        contentScale = fitSize / (svg.width > svg.height ? svg.width : svg.height);
        w = pixels(svg.width * contentScale);
        h = pixels(svg.height * contentScale);
    } else if (filename.length && svgSizeSuffix(filename, sizedW, sizedH) !is null) {
        // name.WxH.svg: WxH px at BASE_DPI, whatever the size of the content; it is fitted and centered
        w = pixels(sizedW * scale);
        h = pixels(sizedH * scale);
        float sx = w / svg.width;
        float sy = h / svg.height;
        contentScale = sx < sy ? sx : sy;
        tx = (w - svg.width * contentScale) / 2;
        ty = (h - svg.height * contentScale) / 2;
    } else {
        contentScale = cast(float)scale;
        w = pixels(svg.width * scale);
        h = pixels(svg.height * scale);
    }
    ubyte[] rgba = new ubyte[w * h * 4];
    auto rasterizer = nsvgCreateRasterizer();
    scope(exit) rasterizer.kill();
    rasterize(rasterizer, svg, tx, ty, contentScale, rgba.ptr, w, h, w * 4);
    // straight alpha RGBA to DlangUI colors (inverted alpha: 0 is opaque)
    ColorDrawBuf buf = new ColorDrawBuf(w, h);
    foreach (y; 0 .. h) {
        uint * line = buf.scanLine(y);
        const(ubyte) * p = rgba.ptr + y * w * 4;
        foreach (x; 0 .. w) {
            line[x] = makeRGBA(p[0], p[1], p[2], 255 - p[3]);
            p += 4;
        }
    }
    return buf;
}

unittest {
    // size from width/height at BASE_DPI, multiplied by the scale; currentColor replaced
    enum square = `<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 16 16">`
        ~ `<rect x="0" y="0" width="16" height="16" fill="currentColor"/></svg>`;
    auto data = cast(const(ubyte)[])square;
    assert(isSvgImage("icon.SVG", null));
    assert(isSvgImage("noext", data));
    ColorDrawBuf b = renderSvg(data, 1.0, 0x3366CC);
    assert(b.width == 16 && b.height == 16);
    assert(b.scanLine(8)[8] == 0x003366CC); // opaque
    destroy(b);
    b = renderSvg(data, 1.25);
    assert(b.width == 20 && b.height == 20);
    assert(b.scanLine(10)[10] == 0x00000000);
    destroy(b);
    // fit into a size, keeping the aspect ratio
    enum wide = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 128 64"><rect width="128" height="64" fill="#FF0000"/></svg>`;
    b = renderSvgToSize(cast(const(ubyte)[])wide, 32);
    assert(b.width == 32 && b.height == 16);
    assert(b.scanLine(8)[16] == 0x00FF0000);
    destroy(b);
    // <style> blocks (through the preprocessor), as in KDE Breeze icons
    enum styled = `<svg xmlns="http://www.w3.org/2000/svg" width="8" height="8">`
        ~ `<style type="text/css">.ColorScheme-Text { color:#232629; } .accent { fill:#00FF00; }</style>`
        ~ `<rect class="accent" width="8" height="4"/>`
        ~ `<rect class="ColorScheme-Text" style="fill:currentColor" y="4" width="8" height="4"/></svg>`;
    b = renderSvg(cast(const(ubyte)[])styled, 1.0, 0xE0E0E0);
    assert(b.scanLine(1)[4] == 0x0000FF00);
    assert(b.scanLine(6)[4] == 0x00E0E0E0);
    destroy(b);
    // clip paths made of a <rect> (as exported by Figma), defined after their use: left 4 px of 8 visible
    enum clipped = `<svg xmlns="http://www.w3.org/2000/svg" width="8" height="8"><g clip-path="url(#c)">`
        ~ `<rect width="8" height="8" fill="#0000FF"/></g>`
        ~ `<defs><clipPath id="c"><rect x="0" y="0" width="4" height="8" fill="white"/></clipPath></defs></svg>`;
    b = renderSvg(cast(const(ubyte)[])clipped);
    assert(b.scanLine(4)[1] == 0x000000FF);
    assert(b.scanLine(4)[6] >> 24 == 0xFF); // transparent
    destroy(b);
    assert(clipShapesToPaths(`<clipPath id="c"><circle cx="5" cy="5" r="2"></circle></clipPath>`)
        == `<clipPath id="c"><path d="M3 5a2 2 0 1 0 4 0a2 2 0 1 0 -4 0z" cx="5" cy="5" r="2"></path></clipPath>`);
    // size suffix in the file name: content drawn 100x100 becomes 24x24 at 96 DPI, 30x30 at 125%
    enum big = `<svg xmlns="http://www.w3.org/2000/svg" width="100" height="100"><rect width="100" height="100" fill="#00FF00"/></svg>`;
    b = renderSvg(cast(const(ubyte)[])big, 1.0, 0, "res/icon.24x24.svg");
    assert(b.width == 24 && b.height == 24 && b.scanLine(23)[23] == 0x0000FF00);
    destroy(b);
    b = renderSvg(cast(const(ubyte)[])big, 1.25, 0, "icon.24x24.svg");
    assert(b.width == 30 && b.height == 30 && b.scanLine(0)[0] == 0x0000FF00 && b.scanLine(29)[29] == 0x0000FF00);
    destroy(b);
    // other aspect ratio: fitted and centered (128x64 content in 32x32: 32x16 in the middle)
    b = renderSvg(cast(const(ubyte)[])wide, 1.0, 0, "wide.32x32.svg");
    assert(b.width == 32 && b.height == 32);
    assert(b.scanLine(2)[16] >> 24 == 0xFF && b.scanLine(16)[16] == 0x00FF0000 && b.scanLine(29)[16] >> 24 == 0xFF);
    destroy(b);
    // not an SVG image
    assert(renderSvg(cast(const(ubyte)[])"<html></html>") is null);
}

/// load and decode image from file to ColorDrawBuf, returns null if loading or decoding is failed
ColorDrawBuf loadImage(string filename) {
    static import std.file;
    try {
        immutable ubyte[] data = cast(immutable ubyte[])std.file.read(filename);
        return loadImage(data, filename);
    } catch (Exception e) {
        Log.e("exception while loading image from file ", filename);
        Log.e(to!string(e));
        return null;
    }
}

/// load and decode image from input stream to ColorDrawBuf, returns null if loading or decoding is failed
ColorDrawBuf loadImage(immutable ubyte[] data, string filename) {
    Log.d("Loading image from file " ~ filename);

    import std.algorithm : endsWith;
    if (filename.endsWith(".xpm")) {
        import dlangui.graphics.xpm.reader : parseXPM;
        try {
            return parseXPM(data);
        }
        catch(Exception e) {
            Log.e("Failed to load image from file ", filename);
            Log.e(to!string(e));
            return null;
        }
    }

    // SVG in its own size (arsd's readSvg renders 1 px too large)
    if (isSvgImage(filename, data))
        return renderSvg(data, 1.0, 0x000000, filename);

    MemoryImage image;
    try {
        if (isIco(data))
            image = largestIcoImage(data);
        else if (guessImageFormatFromMemory(data) == ImageFileFormat.Gif) {
            Log.e("Cannot load image ", filename, ": GIF images are not supported");
            return null;
        } else
            image = loadImageFromMemory(data);
    } catch (Exception e) {
        Log.e("Failed to decode image ", filename, ": ", e.msg);
        return null;
    }
    if (image is null)
        return null;
    ColorDrawBuf buf = new ColorDrawBuf(image.width, image.height);
    for(int j = 0; j < buf.height; j++)
    {
        auto scanLine = buf.scanLine(j);
        for(int i = 0; i < buf.width; i++)
        {
            auto color = image.getPixel(i, j);
            scanLine[i] = makeRGBA(color.r, color.g, color.b, 255 - color.a);
        }
    }
    return buf;
}

/// Smoothly resample rectangle srcRect of src to a new dstdx x dstdy image (#794):
/// area averaging when downscaling, bilinear interpolation when upscaling; colors are blended with
/// premultiplied alpha, so transparent pixels don't darken the edges.
ColorDrawBuf resampleImage(ColorDrawBuf src, Rect srcRect, int dstdx, int dstdy) {
    import std.algorithm : min, max, clamp;
    import std.math : floor, ceil, lround;
    static struct Taps {
        int first;
        float[] weights;
    }
    // source pixels and weights for each destination pixel along one axis
    static Taps[] makeTaps(int srcLen, int dstLen) {
        Taps[] res = new Taps[dstLen];
        double scale = cast(double)dstLen / srcLen;
        foreach (d; 0 .. dstLen) {
            if (scale < 1) {
                // the source interval covered by the destination pixel
                double s0 = d / scale;
                double s1 = (d + 1) / scale;
                int i0 = cast(int)floor(s0);
                int i1 = min(cast(int)ceil(s1), srcLen);
                res[d].first = i0;
                res[d].weights = new float[i1 - i0];
                foreach (i; i0 .. i1)
                    res[d].weights[i - i0] = cast(float)((min(s1, i + 1.0) - max(s0, cast(double)i)) * scale);
            } else {
                double s = (d + 0.5) / scale - 0.5;
                int i0 = cast(int)floor(s);
                float f = cast(float)(s - i0);
                int a = clamp(i0, 0, srcLen - 1);
                int b = clamp(i0 + 1, 0, srcLen - 1);
                res[d].first = a;
                res[d].weights = a == b ? [1.0f] : [1 - f, f];
            }
        }
        return res;
    }
    int sw = srcRect.width;
    int sh = srcRect.height;
    if (sw <= 0 || sh <= 0 || dstdx <= 0 || dstdy <= 0)
        return null;
    Taps[] xtaps = makeTaps(sw, dstdx);
    Taps[] ytaps = makeTaps(sh, dstdy);
    // premultiplied source: opacity, red, green, blue (DlangUI alpha is inverted: 0 is opaque)
    float[] pre = new float[sw * sh * 4];
    foreach (y; 0 .. sh) {
        uint * line = src.scanLine(srcRect.top + y) + srcRect.left;
        foreach (x; 0 .. sw) {
            uint c = line[x];
            float o = (255 - (c >> 24)) / 255.0f;
            float * p = pre.ptr + (y * sw + x) * 4;
            p[0] = o;
            p[1] = ((c >> 16) & 255) * o;
            p[2] = ((c >> 8) & 255) * o;
            p[3] = (c & 255) * o;
        }
    }
    // horizontal pass
    float[] hor = new float[dstdx * sh * 4];
    foreach (y; 0 .. sh) {
        foreach (x; 0 .. dstdx) {
            float[4] acc = 0;
            foreach (k, w; xtaps[x].weights) {
                float * p = pre.ptr + (y * sw + xtaps[x].first + cast(int)k) * 4;
                acc[] += p[0 .. 4] * w;
            }
            hor[(y * dstdx + x) * 4 .. (y * dstdx + x) * 4 + 4] = acc[];
        }
    }
    // vertical pass
    ColorDrawBuf res = new ColorDrawBuf(dstdx, dstdy);
    foreach (y; 0 .. dstdy) {
        uint * line = res.scanLine(y);
        foreach (x; 0 .. dstdx) {
            float[4] acc = 0;
            foreach (k, w; ytaps[y].weights) {
                float * p = hor.ptr + ((ytaps[y].first + cast(int)k) * dstdx + x) * 4;
                acc[] += p[0 .. 4] * w;
            }
            int o = cast(int)lround(acc[0] * 255);
            if (o <= 0) {
                line[x] = 0xFF000000; // fully transparent
                continue;
            }
            if (o > 255)
                o = 255;
            float inv = 1.0f / acc[0];
            uint r = cast(uint)clamp(lround(acc[1] * inv), 0, 255);
            uint g = cast(uint)clamp(lround(acc[2] * inv), 0, 255);
            uint b = cast(uint)clamp(lround(acc[3] * inv), 0, 255);
            line[x] = ((255 - o) << 24) | (r << 16) | (g << 8) | b;
        }
    }
    return res;
}

/// Scale an image by the factor (#794); a nine-patch image is scaled without its 1-pixel marker border,
/// which is added back as transparent pixels, and its frame and padding are scaled by the same factor.
ColorDrawBuf scaleImage(ColorDrawBuf src, double scale) {
    import std.algorithm : max, min;
    import std.math : lround;
    if (src is null)
        return null;
    int scaled(int v) { return cast(int)lround(v * scale); }
    if (!src.hasNinePatch)
        return resampleImage(src, Rect(0, 0, src.width, src.height), max(1, scaled(src.width)), max(1, scaled(src.height)));
    int cw = max(1, scaled(src.width - 2));
    int ch = max(1, scaled(src.height - 2));
    ColorDrawBuf content = resampleImage(src, Rect(1, 1, src.width - 1, src.height - 1), cw, ch);
    scope(exit) destroy(content);
    ColorDrawBuf res = new ColorDrawBuf(cw + 2, ch + 2);
    res.fill(0xFF000000); // transparent border: no nine-patch markers to detect again
    foreach (y; 0 .. ch)
        res.scanLine(y + 1)[1 .. cw + 1] = content.scanLine(y)[0 .. cw];
    const NinePatch * p = src.ninePatch;
    NinePatch * np = new NinePatch();
    np.frame = Rect(scaled(p.frame.left), scaled(p.frame.top), scaled(p.frame.right), scaled(p.frame.bottom));
    np.padding = Rect(scaled(p.padding.left), scaled(p.padding.top), scaled(p.padding.right), scaled(p.padding.bottom));
    // keep at least one stretchable pixel
    np.frame.right = min(np.frame.right, max(0, cw - 1 - np.frame.left));
    np.frame.bottom = min(np.frame.bottom, max(0, ch - 1 - np.frame.top));
    res.ninePatch = np;
    return res;
}

unittest {
    // a 4x2 image, left half opaque red, right half fully transparent
    ColorDrawBuf src = new ColorDrawBuf(4, 2);
    foreach (y; 0 .. 2) {
        uint * line = src.scanLine(y);
        line[0] = line[1] = 0x00FF0000;
        line[2] = line[3] = 0xFF000000;
    }
    // downscale 2x: the area average of red and transparent stays red with half opacity
    ColorDrawBuf half = resampleImage(src, Rect(0, 0, 4, 2), 2, 1);
    assert(half.width == 2 && half.height == 1);
    assert(half.scanLine(0)[0] == 0x00FF0000);
    assert(half.scanLine(0)[1] == 0xFF000000);
    ColorDrawBuf mixed = resampleImage(src, Rect(1, 0, 3, 2), 1, 1);
    uint c = mixed.scanLine(0)[0];
    assert((c & 0xFFFFFF) == 0xFF0000, "premultiplied: no dark fringe"); // color stays pure red
    assert((c >> 24) >= 126 && (c >> 24) <= 128); // half opacity
    // upscale keeps the size and the corner colors
    ColorDrawBuf dbl = resampleImage(src, Rect(0, 0, 4, 2), 8, 4);
    assert(dbl.width == 8 && dbl.height == 4);
    assert(dbl.scanLine(0)[0] == 0x00FF0000 && dbl.scanLine(3)[7] == 0xFF000000);
    // nine-patch: frame and padding are scaled, the border stays transparent
    ColorDrawBuf np = new ColorDrawBuf(12, 12);
    np.fill(0x00808080);
    np.ninePatch = new NinePatch(Rect(2, 2, 2, 2), Rect(4, 2, 4, 2));
    ColorDrawBuf np15 = scaleImage(np, 1.5);
    assert(np15.width == 17 && np15.height == 17); // 10 * 1.5 + 2
    assert(np15.ninePatch.frame == Rect(3, 3, 3, 3));
    assert(np15.ninePatch.padding == Rect(6, 3, 6, 3));
    assert(np15.scanLine(0)[0] == 0xFF000000 && np15.scanLine(8)[8] == 0x00808080);
}
