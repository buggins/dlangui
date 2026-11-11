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
