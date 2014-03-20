module dlangui.graphics.images;

import dlangui.core.logger;
import dlangui.core.types;
import dlangui.graphics.drawbuf;
import std.stream;
import std.file;
import std.algorithm;
import libpng.png;

/// decoded image cache
class ImageCache {

    static class ImageCacheItem {
        string _filename;
        DrawBufRef _drawbuf;
        bool _error; // flag to avoid loading of file if it has been failed once
        bool _used;
        this(string filename) {
            _filename = filename;
        }
        @property ref DrawBufRef get() {
            if (!_drawbuf.isNull || _error) {
                _used = true;
                return _drawbuf;
            }
            _drawbuf = loadImage(_filename);
            _used = true;
            if (_drawbuf.isNull)
                _error = true;
            return _drawbuf;
        }
        /// remove from memory, will cause reload on next access
        void compact() {
            if (!_drawbuf.isNull)
                _drawbuf.clear();
        }
        /// mark as not used
        void checkpoint() {
            _used = false;
        }
        /// cleanup if unused since last checkpoint
        void cleanup() {
            if (!_used)
                compact();
        }
    }
    ImageCacheItem[string] _map;

    /// get and cache image
    ref DrawBufRef get(string filename) {
        if (filename in _map) {
            return _map[filename].get;
        }
        ImageCacheItem item = new ImageCacheItem(filename);
        _map[filename] = item;
        return item.get;
    }
	// clear usage flags for all entries
	void checkpoint() {
        foreach (item; _map)
            item.checkpoint();
    }
	// removes entries not used after last call of checkpoint() or cleanup()
	void cleanup() {
        foreach (item; _map)
            item.cleanup();
    }

    this() {
        Log.i("Creating ImageCache");
    }
    ~this() {
        Log.i("Destroying ImageCache");
		foreach (ref item; _map) {
			destroy(item);
            item = null;
		}
		_map.clear();
    }
}

__gshared ImageCache _imageCache;
/// image cache singleton
@property ImageCache imageCache() { return _imageCache; }
/// image cache singleton
@property void imageCache(ImageCache cache) { 
	if (_imageCache !is null)
		destroy(_imageCache);
	_imageCache = cache; 
}

__gshared DrawableCache _drawableCache;
/// drawable cache singleton
@property DrawableCache drawableCache() { return _drawableCache; }
/// drawable cache singleton
@property void drawableCache(DrawableCache cache) { 
	if (_drawableCache !is null)
		destroy(_drawableCache);
	_drawableCache = cache; 
}

shared static this() {
    _imageCache = new ImageCache();
    _drawableCache = new DrawableCache();
}

class DrawableCache {
    static class DrawableCacheItem {
        string _id;
        string _filename;
        bool _tiled;
        bool _error;
        bool _used;
        DrawableRef _drawable;
		//private int _instanceCount;
        this(string id, string filename, bool tiled) {
            _id = id;
            _filename = filename;
            _tiled = tiled;
            _error = filename is null;
			//Log.d("Created DrawableCacheItem, count=", ++_instanceCount);
        }
		~this() {
			_drawable.clear();
			//Log.d("Destroyed DrawableCacheItem, count=", --_instanceCount);
		}
        /// remove from memory, will cause reload on next access
        void compact() {
            if (!_drawable.isNull)
                _drawable.clear();
        }
        /// mark as not used
        void checkpoint() {
            _used = false;
        }
        /// cleanup if unused since last checkpoint
        void cleanup() {
            if (!_used)
                compact();
        }
        @property ref DrawableRef drawable() {
            _used = true;
            if (!_drawable.isNull || _error)
                return _drawable;
            if (_filename !is null) {
                // reload from file
                DrawBufRef image = imageCache.get(_filename);
                if (!image.isNull) {
                    bool ninePatch = _filename.endsWith(".9.png");
                    _drawable = new ImageDrawable(image, _tiled, ninePatch);
                } else
                    _error = true;
            }
            return _drawable;
        }
    }
    void clear() {
		Log.d("DrawableCache.clear()");
        _idToFileMap.clear();
        foreach(DrawableCacheItem item; _idToDrawableMap)
            item.drawable.clear();
        _idToDrawableMap.clear();
    }
	// clear usage flags for all entries
	void checkpoint() {
        foreach (item; _idToDrawableMap)
            item.checkpoint();
    }
	// removes entries not used after last call of checkpoint() or cleanup()
	void cleanup() {
        foreach (item; _idToDrawableMap)
            item.cleanup();
    }
    string[] _resourcePaths;
    string[string] _idToFileMap;
    DrawableCacheItem[string] _idToDrawableMap;
    ref DrawableRef get(string id) {
        if (id in _idToDrawableMap)
            return _idToDrawableMap[id].drawable;
        string resourceId = id;
        bool tiled = false;
        if (id.endsWith(".tiled")) {
            resourceId = id[0..$-6]; // remove .tiled
            tiled = true;
        }
        string filename = findResource(resourceId);
        DrawableCacheItem item = new DrawableCacheItem(id, filename, tiled);
        _idToDrawableMap[id] = item;
        return item.drawable;
    }
    @property string[] resourcePaths() {
        return _resourcePaths;
    }
    @property void resourcePaths(string[] paths) {
        _resourcePaths = paths;
        clear();
    }
    string findResource(string id) {
        if (id in _idToFileMap)
            return _idToFileMap[id];
        foreach(string path; _resourcePaths) {
            char[] name = path.dup;
            name ~= id;
            name ~= ".png";
            if (!exists(name)) {
                name = path.dup;
                name ~= id;
                name ~= ".9.png";
            }
            if (exists(name) && isFile(name)) {
                string filename = name.dup;
                _idToFileMap[id] = filename;
                return filename;
            }
        }
        return null;
    }
    this() {
        Log.i("Creating DrawableCache");
    }
    ~this() {
        Log.i("Destroying DrawableCache");
		foreach (ref item; _idToDrawableMap) {
			destroy(item);
			item = null;
		}
		_idToDrawableMap.clear();
    }
}

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