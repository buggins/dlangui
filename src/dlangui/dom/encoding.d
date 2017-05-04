module dom.encoding;

string findCharsetDirective(ubyte[] src) {
    import std.string;
    import std.algorithm : min;
    string encoding = null;
    if (src.length >= 17) {
        auto head = cast(string)src[0 .. min(1024, src.length)];
        auto encPos = head.indexOf(`@charset "`);
        if (encPos >= 0) {
            head = head[10 .. $];
            auto endPos = head.indexOf('"');
            if (endPos > 0) {
                head = head[0 .. endPos];
                bool valid = true;
                ubyte v = 0;
                foreach(ch; head)
                    v |= ch;
                if (v & 0x80) {
                    // only code points 0..127
                    // found valid @charset directive
                    return cast(string)head.dup;
                }
            }
        }
    }
    return null; // not found
}

/**
   Convert CSS code bytes to utf-8.
   src is source byte stream
   baseEncoding is name of HTTP stream encoding or base document encoding.
*/
char[] bytesToUtf8(ubyte[] src, string streamEncoding = null, string environmentEncoding = null) {
    import std.string;
    import std.algorithm : min;
    bool isUtf8 = false;
    string encoding = null;
    if (streamEncoding) {
        encoding = streamEncoding;
    } else {
        string charsetDirectiveEncoding = findCharsetDirective(src);
        if (charsetDirectiveEncoding) {
            encoding = charsetDirectiveEncoding;
            if (charsetDirectiveEncoding[0] == 'u' && charsetDirectiveEncoding[1] == 't' && charsetDirectiveEncoding[2] == 'f' && charsetDirectiveEncoding[3] == '-') {
                isUtf8 = true; // for utf-16be, utf-16le use utf-8
                encoding = "utf-8";
            }
        }
    }
    if (!encoding && environmentEncoding)
        encoding = environmentEncoding;
    if (!encoding) {
        // check bom
        // utf-8 BOM
        if (src.length > 3 && src[0] == 0xEF && src[1] == 0xBB && src[2] == 0xBF) {
            isUtf8 = true;
            encoding = "utf-8";
            src = src[3 .. $];
        } else {
            // TODO: support other UTF-8 BOMs
        }
    }
    if (isUtf8) {
        // no decoding needed
        return cast(char[])src.dup;
    }
    // TODO: support more encodings
    // unknown encoding
    return null;
}
