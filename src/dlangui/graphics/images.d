module dlangui.graphics.images;

import dlangui.core.logger;
import dlangui.core.types;
import dlangui.graphics.drawbuf;
import std.stream;
import libpng.png;

/// load and decode image from file to ColorDrawBuf, returns null if loading or decoding is failed
ColorDrawBuf loadImage(string filename) {
    Log.d("Loading image from file " ~ filename);
    try {
        std.stream.File f = new std.stream.File(filename);
	    scope(exit) { f.close(); }
        return loadImage(f);
    } catch (Exception e) {
        return null;
    }
}

/// load and decode image from stream to ColorDrawBuf, returns null if loading or decoding is failed
ColorDrawBuf loadImage(InputStream stream) {
    if (stream is null || !stream.isOpen)
        return null;
	static if (USE_FREEIMAGE) {
		return loadFreeImage(stream);
	} else static if (USE_LIBPNG) {
	    return loadPngImage(stream);
	}
}

class ImageDecodingException : Exception {
    this(string msg) {
        super(msg);
    }
}

immutable bool USE_LIBPNG = false;
immutable bool USE_FREEIMAGE = true;

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
		int pixelSize = FreeImage_GetBPP(dib)/8;
		int size = width*height*pixelSize;

		ColorDrawBuf res = new ColorDrawBuf(width, height);

		//swap R and B and invert image while copying
		ubyte* src;
		uint* dst;
		uint r, g, b, a;
		for( int i = 0, ii = height-1; i < height ; ++i, --ii ) {
			dst = res.scanLine(i);
			src = data + (ii * width) * pixelSize;
			for( int j = 0; j < width; ++j, ++dst, src += pixelSize ) {
				a = 0;
				switch (pixelSize) {
				case 4:
					a = src[3] ^ 255;
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
		FreeImage_CloseMemory(hmem);
		return res;
	}
}

static if (USE_LIBPNG) {

	extern (C) void lvpng_error_func (png_structp png, png_const_charp msg)
	{
		string s = fromStringz(msg);
		Log.d("Error while reading PNG image: ", s);
		// todo: exceptions do not work inside C function
		throw new ImageDecodingException("Error while decoding PNG image");
	}

	extern (C) void lvpng_warning_func (png_structp png, png_const_charp msg)
	{
		string s = fromStringz(msg);
		Log.d("Warn while reading PNG image: ", s);
		// todo: exceptions do not work inside C function
		throw new ImageDecodingException("Error while decoding PNG image");
	}

	extern (C) void lvpng_read_func(png_structp png, png_bytep buf, png_size_t len)
	{
		InputStream stream = cast(InputStream)png_get_io_ptr(png);
		ubyte[] localbuf = new ubyte[len];
		if (stream.read(localbuf) != len)
			throw new ImageDecodingException("Error while reading PNG image");
		for (uint i = 0; i < len; i++)
			buf[i] = localbuf[i];
	}

	/// load and decode PNG image
	ColorDrawBuf loadPngImage(InputStream stream)
	{
		png_structp png_ptr = null;
		png_infop info_ptr = null;
		png_ptr = png_create_read_struct(PNG_LIBPNG_VER_STRING,
										 cast(png_voidp)stream, &lvpng_error_func, &lvpng_warning_func);
		if ( !png_ptr )
			return null;

		try {
			//
			info_ptr = png_create_info_struct(png_ptr);
			if (!info_ptr)
				lvpng_error_func(png_ptr, "cannot create png info struct");
			png_set_read_fn(png_ptr,
							cast(void*)stream, &lvpng_read_func);
			png_read_info( png_ptr, info_ptr );


			png_uint_32 width, height;
			int bit_depth, color_type, interlace_type;
			png_get_IHDR(png_ptr, info_ptr, &width, &height,
						 &bit_depth, &color_type, &interlace_type,
						 null, null);
			ColorDrawBuf drawbuf = new ColorDrawBuf(width, height);

			if (color_type & PNG_COLOR_MASK_PALETTE)
				png_set_palette_to_rgb(png_ptr);

			if (color_type == PNG_COLOR_TYPE_GRAY && bit_depth < 8)
				png_set_expand_gray_1_2_4_to_8(png_ptr);

			if (png_get_valid(png_ptr, info_ptr, PNG_INFO_tRNS))
				png_set_tRNS_to_alpha(png_ptr);

			if (bit_depth == 16)
				png_set_strip_16(png_ptr);

			png_set_invert_alpha(png_ptr);

			if (bit_depth < 8)
				png_set_packing(png_ptr);

			png_set_filler(png_ptr, 0, PNG_FILLER_AFTER);

			if (color_type == PNG_COLOR_TYPE_GRAY ||
				color_type == PNG_COLOR_TYPE_GRAY_ALPHA)
				png_set_gray_to_rgb(png_ptr);

			int number_passes = png_set_interlace_handling(png_ptr);
			png_set_bgr(png_ptr);

			for (int pass = 0; pass < number_passes; pass++)
			{
				for (int y = 0; y < height; y++)
				{
					uint * row = drawbuf.scanLine(y);
					png_read_rows(png_ptr, cast(ubyte **)&row, null, 1);
				}
			}

			png_read_end(png_ptr, info_ptr);

			png_destroy_read_struct(&png_ptr, &info_ptr, null);

			return drawbuf;
		} catch (ImageDecodingException e) {
			if (png_ptr)
			{
				png_destroy_read_struct(&png_ptr, &info_ptr, null);
			}
			return null;
		}
	}

	//bool LVPngImageSource::CheckPattern( const lUInt8 * buf, int )
	//{
		//return( !png_sig_cmp((unsigned char *)buf, (png_size_t)0, 4) );
	//}

}