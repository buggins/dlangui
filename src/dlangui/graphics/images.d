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

    auto image = loadImageFromMemory(data);
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
