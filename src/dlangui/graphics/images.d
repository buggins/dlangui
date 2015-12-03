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

//version = USE_DEIMAGE;
version = USE_DLIBIMAGE;

version (USE_DEIMAGE) {
    import devisualization.image;
    import devisualization.image.png;
}

version (USE_DLIBIMAGE) {
    import dlib.image.io.io;
    import dlib.image.image;
    import dlib.image.io.png;
    import dlib.image.io.jpeg;
    version = ENABLE_DLIBIMAGE_JPEG;
}

import dlangui.core.logger;
import dlangui.core.types;
import dlangui.graphics.colors;
import dlangui.graphics.drawbuf;
import dlangui.core.streams;
import std.path;
import std.conv : to;


/// load and decode image from file to ColorDrawBuf, returns null if loading or decoding is failed
ColorDrawBuf loadImage(string filename) {
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
        import dlangui.graphics.xpm.reader;
        try {
            return parseXPM(data);
        }
        catch(Exception e) {
            Log.e("Failed to load image from file ", filename);
            Log.e(to!string(e));
            return null;
        }
    }
    
    version (USE_DEIMAGE) {
        try {
            Image image = imageFromFile(filename);
            int w = cast(int)image.width;
            int h = cast(int)image.height;
            ColorDrawBuf buf = new ColorDrawBuf(w, h);
            Color_RGBA[] pixels = image.rgba.allPixels;
            int index = 0;
            for (int y = 0; y < h; y++) {
                uint * dstLine = buf.scanLine(y);
                for (int x = 0; x < w; x++) {
                    Color_RGBA * pixel = &pixels[index + x];
                    dstLine[x] = makeRGBA(pixel.r_ubyte, pixel.g_ubyte, pixel.b_ubyte, pixel.a_ubyte);
                }
                index += w;
            }
            //destroy(image);
            return buf;
        } catch (NotAnImageException e) {
            Log.e("Failed to load image from file ", filename, " using de_image");
            Log.e(to!string(e));
            return null;
        }
    } else version (USE_DLIBIMAGE) {
        import std.algorithm;
        static import dlib.core.stream;
        try {
            version (ENABLE_DLIBIMAGE_JPEG) {
            } else {
                // temporary disabling of JPEG support - until DLIB included it
                if (filename.endsWith(".jpeg") || filename.endsWith(".jpg") || filename.endsWith(".JPG") || filename.endsWith(".JPEG"))
                    return null;
            }
            SuperImage image = null;
            dlib.core.stream.ArrayStream dlibstream = new dlib.core.stream.ArrayStream(cast(ubyte[])data, data.length);
            switch(filename.extension)
            {
                case ".jpg", ".JPG", ".jpeg":
                    image = dlib.image.io.jpeg.loadJPEG(dlibstream);
                    break;
                case ".png", ".PNG":
                    image = dlib.image.io.png.loadPNG(dlibstream);
                    break;
                default:
                    break;
            }
            //SuperImage image = dlib.image.io.io.loadImage(filename);
            if (!image)
                return null;
            ColorDrawBuf buf = importImage(image);
            destroy(image);
            return buf;
        } catch (Exception e) {
            Log.e("Failed to load image from file ", filename, " using dlib image");
            Log.e(to!string(e));
            return null;
        }
    } else {
        try {
            std.stream.File f = new std.stream.File(filename);
            scope(exit) { f.close(); }
            return loadImage(f);
        } catch (Exception e) {
            Log.e("exception while loading image from file ", filename);
            Log.e(to!string(e));
            return null;
        }
    }

}

version (USE_DLIBIMAGE) {
    ColorDrawBuf importImage(SuperImage image) {
        int w = image.width;
        int h = image.height;
        ColorDrawBuf buf = new ColorDrawBuf(w, h);
        for (int y = 0; y < h; y++) {
            uint * dstLine = buf.scanLine(y);
            for (int x = 0; x < w; x++) {
                auto pixel = image[x, y].convert(8);
                dstLine[x] = makeRGBA(pixel.r, pixel.g, pixel.b, 255 - pixel.a);
            }
        }
        return buf;
    }
}

class ImageDecodingException : Exception {
    this(string msg) {
        super(msg);
    }
}

