// dimage is actually stripped out part of dlib - just to support reading PNG and JPEG
module dimage.image;

//import dimage.color;

class ImageLoadException : Exception
{
    this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable next = null)
    {
        super(msg, file, line, next);
    }
}


class SuperImageFactory {
    SuperImage createImage(int width, int height, int components, int bitsPerComponent) {
        return new SuperImage(width, height, components, bitsPerComponent);
    }
}

class SuperImage {
    immutable int width;
    immutable int height;
    uint[] data;
    immutable int channels;
    immutable int bitDepth;
    immutable int length;

    void opIndexAssign(uint color, int x, int y) {
        data[x + y * width] = color;
    }

    uint opIndex(int x, int y) {
        return data[x + y * width];
    }

    this(int w, int h, int chan, int depth) {
        width = w;
        height = h;
        channels = chan;
        bitDepth = depth;
        length = width * height;
        data.length = width * height;
    }
    void free() {
        data = null;
    }
}

__gshared SuperImageFactory defaultImageFactory = new SuperImageFactory();


/*
 * Byte operations
 */
version (BigEndian)
{
    uint bigEndian(uint value) nothrow
    {
        return value;
    }

    uint networkByteOrder(uint value) nothrow
    {
        return value;
    }
}

version (LittleEndian)
{
    uint bigEndian(uint value) nothrow
    {
        return value << 24
            | (value & 0x0000FF00) << 8
            | (value & 0x00FF0000) >> 8
            |  value >> 24;
    }

    uint networkByteOrder(uint value) nothrow
    {
        return bigEndian(value);
    }
}
