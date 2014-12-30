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

//immutable bool USE_FREEIMAGE = true;

//version = USE_FREEIMAGE;
//version = USE_DEIMAGE;
version = USE_DLIBIMAGE;

version (USE_DEIMAGE) {
    import devisualization.image;
    import devisualization.image.png;
}

version (USE_DLIBIMAGE) {
    import dlib.image.io.io;
    import dlib.image.image;
    //version = ENABLE_DLIBIMAGE_JPEG;
}

import dlangui.core.logger;
import dlangui.core.types;
import dlangui.graphics.drawbuf;
import std.stream;
import std.conv : to;

/// load and decode image from file to ColorDrawBuf, returns null if loading or decoding is failed
ColorDrawBuf loadImage(string filename) {
    Log.d("Loading image from file " ~ filename);
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
        try {
            version (ENABLE_DLIBIMAGE_JPEG) {
            } else {
                // temporary disabling of JPEG support - until DLIB included it
                if (filename.endsWith(".jpeg") || filename.endsWith(".jpg") || filename.endsWith(".JPG") || filename.endsWith(".JPEG"))
                    return null;
            }
            SuperImage image = dlib.image.io.io.loadImage(filename);
            if (!image)
                return null;
            int w = image.width;
            int h = image.height;
            ColorDrawBuf buf = new ColorDrawBuf(w, h);
            for (int y = 0; y < h; y++) {
                uint * dstLine = buf.scanLine(y);
                for (int x = 0; x < w; x++) {
                    auto pixel = image[x, h - 1 - y].convert(8);
                    dstLine[x] = makeRGBA(pixel.r, pixel.g, pixel.b, 255 - pixel.a);
                }
            }
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

version (USE_FREEIMAGE) {
    /// load and decode image from stream to ColorDrawBuf, returns null if loading or decoding is failed
    ColorDrawBuf loadImage(InputStream stream) {
        if (stream is null || !stream.isOpen)
            return null;
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

version (USE_FREEIMAGE) {
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

