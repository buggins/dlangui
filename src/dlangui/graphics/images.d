module dlangui.graphics.images;

import dlangui.graphics.drawbuf;
import std.stream;
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
}

/// load and decode image from file to ColorDrawBuf, returns null if loading or decoding is failed
ColorDrawBuf loadImage(string filename) {
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
    // TODO: support more image types
    return loadPngImage(stream);
}

class ImageDecodingException : Exception {
    this(string msg) {
        super(msg);
    }
}

extern (C) void lvpng_error_func (png_structp png, png_const_charp)
{
    throw new ImageDecodingException("Error while decoding PNG image");
}

extern (C) void lvpng_warning_func (png_structp png, png_const_charp)
{
    throw new ImageDecodingException("Error while decoding PNG image");
}

extern (C) void lvpng_read_func(png_structp png, png_bytep buf, png_size_t len)
{
    InputStream stream = cast(InputStream)png_get_io_ptr(png);
    ubyte[] localbuf = new ubyte[len];
    if (stream.read(localbuf) != len)
        throw new ImageDecodingException("Error while reading PNG image");
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

