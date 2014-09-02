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

immutable bool USE_FREEIMAGE = true;

import dlangui.core.logger;
import dlangui.core.types;
import dlangui.graphics.drawbuf;
import std.stream;
import std.conv : to;

/// load and decode image from file to ColorDrawBuf, returns null if loading or decoding is failed
ColorDrawBuf loadImage(string filename) {
    Log.d("Loading image from file " ~ filename);
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

/// load and decode image from stream to ColorDrawBuf, returns null if loading or decoding is failed
ColorDrawBuf loadImage(InputStream stream) {
    if (stream is null || !stream.isOpen)
        return null;
	static if (USE_FREEIMAGE) {
		return loadFreeImage(stream);
	}
}

class ImageDecodingException : Exception {
    this(string msg) {
        super(msg);
    }
}

shared static this() {
	//import derelict.freeimage.freeimage;
	//DerelictFI.load();
}

static if (USE_FREEIMAGE) {
	ColorDrawBuf loadFreeImage(InputStream stream) {
		import derelict.freeimage.freeimage;

		static bool FREE_IMAGE_LOADED;
		if (!FREE_IMAGE_LOADED) {
			DerelictFI.load();
			FREE_IMAGE_LOADED = true;
		}

		ubyte imagebuf[];
		ubyte readbuf[4096];
		for (;;) {
			size_t bytesRead = stream.read(readbuf);
			if (!bytesRead)
				break;
			imagebuf ~= readbuf[0..bytesRead];
		}
		//pointer to the image, once loaded
		FIBITMAP *dib = null;		//image format
		FREE_IMAGE_FORMAT fif = FIF_UNKNOWN;
		// attach the binary data to a memory stream
		FIMEMORY *hmem = FreeImage_OpenMemory(imagebuf.ptr, imagebuf.length);
		fif = FreeImage_GetFileTypeFromMemory(hmem);
		//check that the plugin has reading capabilities and load the file
		if(!FreeImage_FIFSupportsReading(fif)) {
			FreeImage_CloseMemory(hmem);
			return null;
		}

		// load an image from the memory stream
		dib = FreeImage_LoadFromMemory(fif, hmem, 0);
		
		//if the image failed to load, return failure
		if (!dib) {
			Log.e("Failed to decode image");
			FreeImage_CloseMemory(hmem);
			return null;
		}
		//retrieve the image data
		ubyte * data = cast(ubyte*)FreeImage_GetBits(dib);
		//get the image width and height, and size per pixel
		int width = FreeImage_GetWidth(dib);
		int height = FreeImage_GetHeight(dib);
        int stride = FreeImage_GetPitch(dib);
		int bpp = FreeImage_GetBPP(dib);
		int pixelSize = (bpp + 7)/8;
		//Log.d("image ", width, "x", height, " stride ", stride, "(", stride / pixelSize, ") bpp ", bpp, " pixelSize ", pixelSize);
		FREE_IMAGE_COLOR_TYPE colorType = FreeImage_GetColorType(dib);
        int transparentIndex = 0;
        int transparencyCount = 0;
        RGBQUAD * palette = null;
        ubyte * transparencyTable = null;
        if (colorType == FIC_PALETTE) {
            palette = FreeImage_GetPalette(dib);
            transparentIndex = FreeImage_GetTransparentIndex(dib);
            transparencyCount = FreeImage_GetTransparencyCount(dib);
            transparencyTable = FreeImage_GetTransparencyTable(dib);
        }
		//int size = stride*height;

		ColorDrawBuf res = new ColorDrawBuf(width, height);

		//swap R and B and invert image while copying
		ubyte* src;
		uint* dst;
		uint r, g, b, a;
		for( int i = 0, ii = height-1; i < height ; ++i, --ii ) {
			dst = res.scanLine(i);
			src = data + ii * stride;
			for( int j = 0; j < width; ++j, ++dst, src += pixelSize ) {
                if (colorType == FIC_PALETTE) {
                    ubyte index = src[0];
                    a = 0;
                    if (transparencyTable !is null) {
                        a = transparencyTable[index] ^ 0xFF;
                    } else if (transparentIndex >= 0 && index >= transparentIndex && index < transparentIndex + transparencyCount) {
                        a = 0xFF;
                    }
                    RGBQUAD pcolor = palette[index];
                    r = pcolor.rgbRed;
                    g = pcolor.rgbGreen;
                    b = pcolor.rgbBlue;
                    dst[0] = (a << 24) | (r << 16) | (g << 8) | b;
                } else {
				    a = 0;
				    switch (pixelSize) {
				    case 4:
					    a = src[3] ^ 255;
					    // fall through
					    goto case;
				    case 3:
					    r = src[2];
					    g = src[1];
					    b = src[0];
					    break;
				    case 2:
					    // todo: do something better
					    r = g = src[1];
					    b = src[0];
					    break;
				    default:
				    case 1:
				        r = g = b = src[0];
					    break;
				    }
				    dst[0] = (a << 24) | (r << 16) | (g << 8) | b;
                }
			}
		}
		FreeImage_CloseMemory(hmem);
		return res;
	}
}

