// Written in the D programming language.

/**

This module contains text stream reader implementation

Implements class LineStream for reading of unicode text from stream and returning it by lines.

Support utf8, utf16, utf32 be and le encodings, and line endings - according to D language source file specification.

Low resource consuming. Doesn't flood with GC allocations. Dup line if you want to store it somewhere.

Tracks line number.


Synopsis:

----
import dlangui.core.linestream;

import std.stdio;
import std.conv;
import std.utf;
string fname = "somefile.d";
writeln("opening file");
std.stream.File f = new std.stream.File(fname);
scope(exit) { f.close(); }
try {
    LineStream lines = LineStream.create(f, fname);
    for (;;) {
        dchar[] s = lines.readLine();
        if (s is null)
            break;
        writeln("line " ~ to!string(lines.line()) ~ ":" ~ toUTF8(s));
    }
    if (lines.errorCode != 0) {
        writeln("Error ", lines.errorCode, " ", lines.errorMessage, " -- at line ", lines.errorLine, " position ", lines.errorPos);
    } else {
        writeln("EOF reached");
    }
} catch (Exception e) {
    writeln("Exception " ~ e.toString);
}

----

Copyright: Vadim Lopatin, 2014
License:   Boost License 1.0
Authors:   Vadim Lopatin, coolreader.org@gmail.com
*/
module dlangui.core.linestream;

import dlangui.core.streams;
//import std.stream;
import std.stdio;
import std.conv;
import std.utf;

/// File encoding
public enum EncodingType : int {
    /// utf-8 unicode
    UTF8,
    /// utf-16 unicode big endian
    UTF16BE,
    /// utf-16 unicode little endian
    UTF16LE,
    /// utf-32 unicode big endian
    UTF32BE,
    /// utf-32 unicode little endian
    UTF32LE,
    /// plain ASCII (character codes must be <= 127)
    ASCII,
    /// encoding is unknown
    UNKNOWN
}
/// Line ending style
public enum LineEnding : int {
    /// LF (0x0A) - unix style
    LF,
    /// CR followed by LF (0x0D,0x0A) - windows style
    CRLF,
    /// CR (0x0D) - mac style
    CR,
    /// unknown line ending
    UNKNOWN,
    /// mixed line endings detected
    MIXED
}

/// Text file format
struct TextFileFormat {
    /// character encoding
    EncodingType encoding;
    /// line ending style
    LineEnding lineEnding;
    /// byte order mark character flag
    bool bom;
    string toString() const {
        return to!string(encoding) ~ " " ~ to!string(lineEnding) ~ (bom ? " bom" : "");
    }
}

/// Text file writer which supports different text file formats
class OutputLineStream {
    protected OutputStream _stream;
    protected string _filename;
    protected TextFileFormat _format;
    protected bool _firstLine;
    protected char[] _buf;
    protected int _len;
    protected static immutable int MAX_BUFFER_SIZE = 0x10000; // 64K
    /// create
    this(OutputStream stream, string filename, TextFileFormat format) {
        _stream = stream;
        _filename = filename;
        _format = format;
        _firstLine = true;
        // fix format
        if (_format.encoding == EncodingType.UNKNOWN || _format.encoding == EncodingType.ASCII)
            _format.encoding = EncodingType.UTF8;
        if (_format.lineEnding == LineEnding.UNKNOWN || _format.lineEnding == LineEnding.MIXED) {
            version (Windows) {
                _format.lineEnding = LineEnding.CRLF;
            } else {
                _format.lineEnding = LineEnding.LF;
            }
        }
    }

    protected void flush() {
        if (_len > 0) {
            _stream.write(cast(ubyte[])_buf[0 .. _len]);
            _len = 0;
        }
    }

    /// convert character encoding and write to output stream
    /// ch, or U+FFFD if ch isn't a valid character (a surrogate or over U+10FFFF), which can't be encoded (#923)
    protected static dchar validChar(dchar ch) @safe pure nothrow @nogc {
        return (ch < 0xD800 || (ch >= 0xE000 && ch <= 0x10FFFF)) ? ch : 0xFFFD;
    }

    protected void convertAndWrite(dstring s) {
        /// reserve buf space
        if (_buf.length < _len + s.length * 4 + 4)
            _buf.length = _len + s.length * 4 + 4;
        switch (_format.encoding) with(EncodingType)
        {
            case UTF8:
            default:
                char[4] utf8;
                foreach(i; 0 .. s.length) {
                    int bytes = cast(int)encode(utf8, validChar(s[i]));
                    foreach(j; 0 .. bytes)
                        _buf[_len++] = utf8[j];
                }
                break;
            case UTF16BE:
                wchar[2] utf16be;
                foreach(i; 0 .. s.length) {
                    int n = cast(int)encode(utf16be, validChar(s[i]));
                    foreach(j; 0 .. n) {
                        _buf[_len++] = cast(char)(utf16be[j] >> 8);
                        _buf[_len++] = cast(char)(utf16be[j] & 0xFF);
                    }
                }
                break;
            case UTF16LE:
                wchar[2] utf16le;
                foreach(i; 0 .. s.length) {
                    int n = cast(int)encode(utf16le, validChar(s[i]));
                    foreach(j; 0 .. n) {
                        _buf[_len++] = cast(char)(utf16le[j] & 0xFF);
                        _buf[_len++] = cast(char)(utf16le[j] >> 8);
                    }
                }
                break;
            case UTF32LE:
                foreach(i; 0 .. s.length) {
                    dchar ch = validChar(s[i]);
                    _buf[_len++] = cast(char)((ch >> 0) & 0xFF);
                    _buf[_len++] = cast(char)((ch >> 8) & 0xFF);
                    _buf[_len++] = cast(char)((ch >> 16) & 0xFF);
                    _buf[_len++] = cast(char)((ch >> 24) & 0xFF);
                }
                break;
            case UTF32BE:
                foreach(i; 0 .. s.length) {
                    dchar ch = validChar(s[i]);
                    _buf[_len++] = cast(char)((ch >> 24) & 0xFF);
                    _buf[_len++] = cast(char)((ch >> 16) & 0xFF);
                    _buf[_len++] = cast(char)((ch >> 8) & 0xFF);
                    _buf[_len++] = cast(char)((ch >> 0) & 0xFF);
                }
                break;
        }
        if (_len > MAX_BUFFER_SIZE)
            flush();
    }
    /// write single line
    void writeLine(dstring line) {
        if (_firstLine) {
            if (_format.bom)
                convertAndWrite("\uFEFF"d); // write BOM
            _firstLine = false;
        }
        convertAndWrite(line);
        switch(_format.lineEnding) {
            case LineEnding.LF:
                convertAndWrite("\n"d);
                break;
            case LineEnding.CR:
                convertAndWrite("\r"d);
                break;
            default:
            case LineEnding.CRLF:
                convertAndWrite("\r\n"d);
                break;
        }
    }
    /// close stream
    void close() {
        flush();
        _stream.close();
        _buf = null;
    }
}


/**
    Support reading of file (or string in memory) by lines

    Support utf8, utf16, utf32 be and le encodings, and line endings - according to D language source file specification.

    Low resource consuming. Doesn't flood with GC allocations. Dup line if you want to store it somewhere.

    Tracks line number.
*/
class LineStream {

    /// Error codes (0 means no error)
    public enum ErrorCodes {
        /// invalid character for current encoding (not used: invalid characters are replaced, see invalidCharCount)
        INVALID_CHARACTER = 1
    }

    /// replaces invalid and incomplete byte sequences in decoded text (U+FFFD)
    enum dchar REPLACEMENT_CHAR = 0xFFFD;

    private InputStream _stream;
    private string _filename;
    private ubyte[] _buf;  // stream reading buffer
    private uint _pos; // reading position of stream buffer
    private uint _len; // number of bytes in stream buffer
    private bool _streamEof; // true if input stream is in EOF state
    private uint _line; // current line number

    private uint _textPos; // start of text line in text buffer
    private uint _textLen; // position of last filled char in text buffer + 1
    private dchar[] _textBuf; // text buffer
    private bool _eof; // end of file, no more lines
    protected bool _bomDetected;
    protected int _crCount;
    protected int _lfCount;
    protected int _crlfCount;

    /// Returns file name
    @property string filename() { return _filename; }
    /// Returns current line number
    @property uint line() { return _line; }
    /// Returns file encoding EncodingType
    @property EncodingType encoding() { return _encoding; }

    @property TextFileFormat textFormat() {
        LineEnding le = LineEnding.CRLF;
        if (_crlfCount) {
            if (_crCount == _lfCount)
                le = LineEnding.CRLF;
            else
                le = LineEnding.MIXED;
        } else if (_crCount > _lfCount) {
            le = LineEnding.CR;
        } else if (_lfCount > _crCount) {
            le = LineEnding.LF;
        } else {
            le = LineEnding.MIXED;
        }
        TextFileFormat res = TextFileFormat(_encoding, le, _bomDetected);
        return res;
    }


    /// Returns the number of invalid or incomplete characters (byte sequences) replaced by REPLACEMENT_CHAR so far
    @property uint invalidCharCount() { return _invalidCharCount; }
    protected uint _invalidCharCount;

    // The error properties are kept for compatibility: decoding doesn't fail any more since invalid characters
    // are replaced (#924), so errorCode is always 0 and the others are empty.

    /// Returns error code (0: no error)
    @property int errorCode() { return _errorCode; }
    /// Returns error message
    @property string errorMessage() { return _errorMessage; }
    /// Returns line where error is found
    @property int errorLine() { return _errorLine; }
    /// Returns line position (number of character in line) where error is found
    @property int errorPos() { return _errorPos; }

    private immutable EncodingType _encoding;

    private int _errorCode;
    private string _errorMessage;
    private uint _errorLine;
    private uint _errorPos;

    /// Open file with known encoding
    protected this(InputStream stream, string filename, EncodingType encoding, ubyte[] buf, uint offset, uint len) {
        _filename = filename;
        _stream = stream;
        _encoding = encoding;
        // create() detects a BOM only in bytes that were read (the buffer is zeroed, 4-byte BOMs need len >= 4)
        assert(offset <= len, "BOM longer than the data");
        _buf = buf;
        _len = len;
        _pos = offset;
        _streamEof = _stream.eof;
    }

    /// this constructor was created for unittests only
    protected this(){
        _encoding = EncodingType.UTF8;
    }

    /// reads more bytes into the buffer if needed; returns the number of bytes available from _pos
    /// (not @safe: calls the InputStream, whose methods have no attributes)
    protected final uint readBytes() {
        uint bytesLeft = _len - _pos;
        if (_streamEof || bytesLeft > QUARTER_BYTE_BUFFER_SIZE)
            return bytesLeft;
        if (_pos > 0) {
            foreach(i; 0 .. bytesLeft)
                _buf[i] = _buf[i + _pos];
            _len = bytesLeft;
            _pos = 0;
        }
        uint bytesRead = cast(uint)_stream.read(_buf[_len .. BYTE_BUFFER_SIZE]);
        _len += bytesRead;
        _streamEof = _stream.eof;
        return _len - _pos; //_buf[_pos .. _len];
    }

    // when bytes consumed from byte buffer, call this method to update position
    protected final void consumedBytes(uint count) @safe {
        _pos += count;
    }

    // reserve text buffer for specified number of characters, and return the free space (at least len characters)
    protected final dchar[] reserveTextBuf(uint len) @safe {
        // create new text buffer if necessary
        if (_textBuf == null) {
            _textBuf = new dchar[len < TEXT_BUFFER_SIZE ? TEXT_BUFFER_SIZE : len];
            return _textBuf;
        }
        uint spaceLeft = cast(uint)_textBuf.length - _textLen;
        if (spaceLeft >= len)
            return _textBuf[_textLen .. $];
        // move text to beginning of buffer, if necessary
        if (_textPos > _textBuf.length / 2) {
            uint charCount = _textLen - _textPos;
            foreach(i; 0 .. charCount)
                _textBuf[i] = _textBuf[i + _textPos];
            _textLen = charCount;
            _textPos = 0;
        }
        // resize buffer if necessary
        if (_textLen + len > _textBuf.length) {
            // resize buffer
            uint newsize = cast(uint)_textBuf.length * 2;
            if (newsize < _textLen + len)
                newsize = _textLen + len;
            _textBuf.length = newsize;
        }
        return _textBuf[_textLen .. $];
    }

    protected final void appendedText(uint len) @safe {
        //writeln("appended ", len, " chars of text"); //:", _textBuf[_textLen .. _textLen + len]);
        _textLen += len;
    }

    protected final void setError(int code, string message, uint errorLine, uint errorPos) @safe {
        _errorCode = code;
        _errorMessage = message;
        _errorLine = errorLine;
        _errorPos = errorPos;
    }

    // override to decode text
    protected abstract uint decodeText();

    /// Unknown line position
    immutable static uint LINE_POSITION_UNDEFINED = uint.max;

    /// decodes more text, returns the number of characters decoded (0 at the end of the stream). A decoder decodes
    /// nothing before the end of the stream when the bytes left are an incomplete character, after a stream
    /// returned fewer bytes than asked for: then read more (#935), unless the stream gives no more bytes
    private uint decodeMore() {
        for (;;) {
            uint available = _len - _pos;
            uint chars = decodeText();
            if (chars || _streamEof || _errorCode != 0)
                return chars;
            if (_len - _pos <= available)
                return 0; // no bytes read: don't wait forever
        }
    }

    /// Read line from stream
    public dchar[] readLine() {
        if (_errorCode != 0) {
            //writeln("error ", _errorCode, ": ", _errorMessage, " in line ", _errorLine);
            return null; // error detected
        }
        if (_eof) {
            //writeln("EOF found");
            return null;
        }
        _line++;
        uint p = 0;
        uint eol = LINE_POSITION_UNDEFINED;
        uint eof = LINE_POSITION_UNDEFINED;
        uint lastchar = LINE_POSITION_UNDEFINED;
        do {
            if (_errorCode != 0) {
                //writeln("error ", _errorCode, ": ", _errorMessage, " in line ", _errorLine);
                return null; // error detected
            }
            uint charsLeft = _textLen - _textPos;
            if (p >= charsLeft) {
                uint decodedChars = decodeMore();
                if (_errorCode != 0) {
                    return null; // error detected
                }
                charsLeft = _textLen - _textPos;
                if (decodedChars == 0) {
                    eol = charsLeft;
                    eof = charsLeft;
                    lastchar = charsLeft;
                    break;
                }
            }
            for (; p < charsLeft; p++) {
                dchar ch = _textBuf[_textPos + p];
                if (ch == '\r') { // CR
                    lastchar = p;
                    if (p == charsLeft - 1) {
                        // need one more char to check if it's 0D0A or just 0D eol
                        //writeln("read one more char for 0D0A detection");
                        decodeMore();
                        if (_errorCode != 0) {
                            return null; // error detected
                        }
                        charsLeft = _textLen - _textPos;
                    }
                    dchar ch2 = (p < charsLeft - 1) ? _textBuf[_textPos + p + 1] : 0;
                    if (ch2 == '\n') { // LF
                        // CRLF
                        eol = p + 2;
                        _lfCount++;
                        _crCount++;
                        _crlfCount++;
                    } else {
                        // just CR
                        eol = p + 1;
                        _crCount++;
                    }
                    break;
                } else if (ch == '\n' || ch == 0x2028 || ch == 0x2029) {
                    // single char eoln
                    lastchar = p;
                    eol = p + 1;
                    _lfCount++;
                    break;
                } else if (ch == 0x001A) {
                    // Ctrl-Z ends the text only as the last character of the file (DOS end-of-file marker); NUL and
                    // Ctrl-Z elsewhere are ordinary characters: the text was cut there without an error (#934)
                    if (p == charsLeft - 1) {
                        decodeMore();
                        if (_errorCode != 0)
                            return null; // error detected
                        charsLeft = _textLen - _textPos;
                    }
                    if (p == charsLeft - 1) {
                        lastchar = p;
                        eol = eof = p + 1;
                        break;
                    }
                }
            }
        } while (eol == LINE_POSITION_UNDEFINED);
        uint lineStart = _textPos;
        uint lineEnd = _textPos + lastchar;
        _textPos += eol; // consume text
        if (eof != LINE_POSITION_UNDEFINED) {
            _eof = true;
            //writeln("Setting eof flag. lastchar=", lastchar, ", p=", p, ", lineStart=", lineStart);
            if (lineStart >= lineEnd) {
                //writeln("lineStart >= lineEnd -- treat as eof");
                return null; // eof
            }
        }
        // return slice with decoded line
        return _textBuf[lineStart .. lineEnd];
    }

    protected immutable static int TEXT_BUFFER_SIZE = 1024;
    protected immutable static int BYTE_BUFFER_SIZE = 512;
    protected immutable static int QUARTER_BYTE_BUFFER_SIZE = BYTE_BUFFER_SIZE / 4;

    /// Factory method for string parser
    public static LineStream create(string code, string filename = "") {
        uint len = cast(uint)code.length;
        ubyte[] data = new ubyte[len + 3];
        foreach(i; 0 .. len)
            data[i + 3] = code[i];
        // BOM for UTF8
        data[0] = 0xEF;
        data[1] = 0xBB;
        data[2] = 0xBF;
        InputStream stream = new MemoryInputStream(data); //new MemoryStream(data);
        return create(stream, filename);
    }

    /// true if b (4 bytes) is a valid character in UTF-32LE
    private static bool isValidUtf32le(scope const(ubyte)[] b) @safe pure nothrow @nogc {
        uint ch = b[0] | (b[1] << 8) | (b[2] << 16) | (cast(uint)b[3] << 24);
        return ch < 0xD800 || (ch >= 0xE000 && ch <= 0x10FFFF);
    }

    /// UTF-16 without BOM, detected from the zero bytes of mostly ASCII text (#934): most high bytes are 0 (at odd
    /// positions for little endian, even for big endian) and almost no low bytes; UTF8 otherwise, also for fewer
    /// than 2 units (a file read as UTF-8 with NUL characters is saved back unchanged)
    static EncodingType detectUtf16WithoutBom(scope const(ubyte)[] b) @safe pure nothrow @nogc {
        size_t units = b.length / 2;
        if (units < 2)
            return EncodingType.UTF8;
        size_t zeroEven, zeroOdd;
        foreach (i; 0 .. units) {
            if (!b[2 * i])
                zeroEven++;
            if (!b[2 * i + 1])
                zeroOdd++;
        }
        if (zeroOdd * 2 > units && zeroEven * 10 < units)
            return EncodingType.UTF16LE;
        if (zeroEven * 2 > units && zeroOdd * 10 < units)
            return EncodingType.UTF16BE;
        return EncodingType.UTF8;
    }

    /// Factory for InputStream parser
    public static LineStream create(InputStream stream, string filename, bool autodetectUTFIfNoBOM = true) {
        ubyte[] buf = new ubyte[BYTE_BUFFER_SIZE];
        buf[0] = buf[1] = buf[2]  = buf[3] = 0;
        if (!stream.isOpen)
            return null;
        uint len = cast(uint)stream.read(buf);
        // a stream may return fewer bytes than available (#935): BOM detection needs up to 8, and the detection
        // of UTF-16 without BOM a sample of the text
        while (len < QUARTER_BYTE_BUFFER_SIZE && !stream.eof) {
            uint n = cast(uint)stream.read(buf[len .. $]);
            if (!n)
                break;
            len += n;
        }
        LineStream res = null;
        if (buf[0] == 0xEF && buf[1] == 0xBB && buf[2] == 0xBF) {
            res = new Utf8LineStream(stream, filename, buf, len, 3);
        } else if (len >= 4 && buf[0] == 0x00 && buf[1] == 0x00 && buf[2] == 0xFE && buf[3] == 0xFF) {
            res = new Utf32beLineStream(stream, filename, buf, len);
        } else if (len >= 4 && buf[0] == 0xFF && buf[1] == 0xFE && buf[2] == 0x00 && buf[3] == 0x00
                && (len == 4 || (len >= 8 && isValidUtf32le(buf[4 .. 8])))) {
            // (len >= 4: an empty UTF-16LE file is just FF FE, and the buffer is zeroed, #933;
            // FF FE 00 00 is also UTF-16LE starting with U+0000: UTF-32LE only for the BOM alone or a valid next
            // character; 5 to 7 bytes (the stream has ended, see above) can't be UTF-32)
            res = new Utf32leLineStream(stream, filename, buf, len);
        } else if (buf[0] == 0xFE && buf[1] == 0xFF) {
            res =  new Utf16beLineStream(stream, filename, buf, len);
        } else if (buf[0] == 0xFF && buf[1] == 0xFE) {
            res = new Utf16leLineStream(stream, filename, buf, len);
        }
        if (res) {
            res._bomDetected = true;
        } else {
            if (autodetectUTFIfNoBOM) {
                EncodingType detected = detectUtf16WithoutBom(buf[0 .. len]);
                if (detected == EncodingType.UTF16LE)
                    res = new Utf16leLineStream(stream, filename, buf, len, 0);
                else if (detected == EncodingType.UTF16BE)
                    res = new Utf16beLineStream(stream, filename, buf, len, 0);
                else
                    res = new Utf8LineStream(stream, filename, buf, len, 0);
            } else {
                res = new AsciiLineStream(stream, filename, buf, len);
            }
        }
        return res;
    }
}


private class AsciiLineStream : LineStream {
    this(InputStream stream, string filename, ubyte[] buf, uint len) {
        super(stream, filename, EncodingType.ASCII, buf, 0, len);
    }
    override uint decodeText() {
        uint len = readBytes();
        if (len == 0)
            return 0; // nothing to decode
        return decodeBuffer(len);
    }

    /// decodes the len bytes available in the buffer
    private uint decodeBuffer(uint len) @safe {
        const(ubyte)[] b = _buf[_pos .. _pos + len];
        dchar[] text = reserveTextBuf(len);
        foreach (i; 0 .. len) {
            ubyte ch = b[i];
            if (ch & 0x80) {
                // not ASCII
                text[i] = REPLACEMENT_CHAR;
                _invalidCharCount++;
            } else {
                text[i] = ch;
            }
        }
        consumedBytes(len);
        appendedText(len);
        return len;
    }

}

private class Utf8LineStream : LineStream {
    this(InputStream stream, string filename, ubyte[] buf, uint len, int skip) {
        super(stream, filename, EncodingType.UTF8, buf, skip, len);
    }

    /// decodes one character from the start of b (not empty); returns the number of bytes used, 0 if the bytes
    /// are invalid or incomplete (then needMoreFlag is set)
    static uint decodeBytes(scope const(ubyte)[] b, out uint ch, out bool needMoreFlag) @safe pure nothrow @nogc {
        immutable size_t bleft = b.length;
        uint bread = 0;
        uint ch0 = b[0];
        if (!(ch0 & 0x80)) {
            // 0x00..0x7F single byte
            // 0x80 == 10000000
            // !(ch0 & 0x80) => ch0 < 10000000
            ch = ch0;
            bread = 1;
        } else if ((ch0 & 0xE0) == 0xC0) {
            // two bytes 110xxxxx 10xxxxxx
            if (bleft < 2) {
                needMoreFlag = true;
                return 0;
            }
            uint ch1 = b[1];
            if ((ch1 & 0xC0) != 0x80) {
                return 0;
            }
            ch = ((ch0 & 0x1F) << 6) | (ch1 & 0x3F);
            if (ch < 0x80)
                return 0; // overlong encoding
            bread = 2;
        } else if ((ch0 & 0xF0) == 0xE0) {
            // three bytes 1110xxxx 10xxxxxx 10xxxxxx
            if (bleft < 3) {
                needMoreFlag = true;
                return 0;
            }
            uint ch1 = b[1];
            uint ch2 = b[2];
            if ((ch1 & 0xC0) != 0x80 || (ch2 & 0xC0) != 0x80) {
                return 0;
            }
            ch = ((ch0 & 0x0F) << 12) | ((ch1 & 0x3F) << 6) | (ch2 & 0x3F);
            if (ch < 0x800)
                return 0; // overlong encoding
            bread = 3;
        } else if ((ch0 & 0xF8) == 0xF0) {
            // four bytes 11110xxx 10xxxxxx 10xxxxxx 10xxxxxx
            if (bleft < 4) {
                needMoreFlag = true;
                return 0;
            }
            uint ch1 = b[1];
            uint ch2 = b[2];
            uint ch3 = b[3];
            if ((ch1 & 0xC0) != 0x80 || (ch2 & 0xC0) != 0x80 || (ch3 & 0xC0) != 0x80) {
                return 0;
            }
            ch = ((ch0 & 0x07) << 18) | ((ch1 & 0x3F) << 12) | ((ch2 & 0x3F) << 6) | (ch3 & 0x3F);
            if (ch < 0x10000)
                return 0; // overlong encoding
            bread = 4;
        }
        // other lead bytes (continuation bytes 0x80..0xBF, 0xF8..0xFF: the old 5- and 6-byte forms) are invalid:
        // bread stays 0
        if ((ch >= 0xd800 && ch < 0xe000) || (ch > 0x10FFFF)) {
            return 0;
        }
        return bread;
    }

    /// length of an invalid or incomplete sequence at the start of b (not empty), replaced by one REPLACEMENT_CHAR:
    /// its maximal subpart (Unicode, "U+FFFD substitution of maximal subparts"): the longest start of a valid
    /// sequence, at least 1 byte. C0, C1 and F5..FF are never valid; the second byte has a narrower range after
    /// E0 (overlong), ED (surrogates), F0 (overlong) and F4 (over U+10FFFF).
    static uint invalidSequenceLength(scope const(ubyte)[] b) @safe pure nothrow @nogc {
        uint lead = b[0];
        uint expected = (lead >= 0xC2 && lead <= 0xDF) ? 2 : (lead >= 0xE0 && lead <= 0xEF) ? 3 : (lead >= 0xF0 && lead <= 0xF4) ? 4 : 1;
        if (expected == 1 || b.length < 2)
            return 1;
        uint second = b[1];
        uint lo = lead == 0xE0 ? 0xA0 : lead == 0xF0 ? 0x90 : 0x80;
        uint hi = lead == 0xED ? 0x9F : lead == 0xF4 ? 0x8F : 0xBF;
        if (second < lo || second > hi)
            return 1;
        uint n = 2;
        while (n < expected && n < b.length && (b[n] & 0xC0) == 0x80)
            n++;
        return n;
    }

    @safe unittest {
        ubyte[] buffer =  new ubyte[4];
        uint ch;
        bool needMoreFlag;
        uint bread;

        //convert simple character
        buffer[0] = '/';
        bread = decodeBytes(buffer[0 .. 1],ch,needMoreFlag);
        assert(!needMoreFlag);
        assert(bread == 1);
        assert(ch == '/');


        //convert 2byte character
        buffer[0] = 0xc3;
        buffer[1] = 0x84;
        bread = decodeBytes(buffer[0 .. 1],ch,needMoreFlag);
        assert(needMoreFlag);

        bread = decodeBytes(buffer[0 .. 2],ch,needMoreFlag);
        assert(!needMoreFlag);
        assert(bread == 2);
        assert(ch == 'Ä');

        //convert 3byte character
        buffer[0] = 0xe0;
        buffer[1] = 0xa4;
        buffer[2] = 0xb4;
        bread = decodeBytes(buffer[0 .. 2],ch,needMoreFlag);
        assert(needMoreFlag);

        bread = decodeBytes(buffer[0 .. 3],ch,needMoreFlag);
        assert(!needMoreFlag);
        assert(bread == 3);
        assert(ch == 'ऴ');

        //regression test for https://github.com/buggins/dlangide/issues/65
        buffer[0] = 0xEB;
        buffer[1] = 0xB8;
        buffer[2] = 0x94;
        bread = decodeBytes(buffer[0 .. 3],ch,needMoreFlag);
        assert(!needMoreFlag);
        assert(bread == 3);
        assert(ch == '블');

        // invalid: continuation byte first, bad continuation byte, surrogate code point
        buffer[0] = 0x84;
        assert(decodeBytes(buffer[0 .. 1],ch,needMoreFlag) == 0 && !needMoreFlag);
        buffer[0] = 0xc3;
        buffer[1] = 0x41;
        assert(decodeBytes(buffer[0 .. 2],ch,needMoreFlag) == 0 && !needMoreFlag);
        buffer[0] = 0xED;
        buffer[1] = 0xA0;
        buffer[2] = 0x80;
        assert(decodeBytes(buffer[0 .. 3],ch,needMoreFlag) == 0 && !needMoreFlag);
        // overlong encodings
        buffer[0] = 0xC0;
        buffer[1] = 0x80;
        assert(decodeBytes(buffer[0 .. 2],ch,needMoreFlag) == 0 && !needMoreFlag);
        buffer[0] = 0xE0;
        buffer[1] = 0x80;
        buffer[2] = 0xAF;
        assert(decodeBytes(buffer[0 .. 3],ch,needMoreFlag) == 0 && !needMoreFlag);
        assert(invalidSequenceLength(buffer[0 .. 3]) == 1); // E0 80: overlong, E0 alone is the maximal subpart
        buffer[0] = 0x84;
        assert(invalidSequenceLength(buffer[0 .. 3]) == 1);
        // 5-byte form (F8 is never valid)
        ubyte[] five = [0xF8, 0x80, 0x80, 0x80, 0x80];
        assert(decodeBytes(five,ch,needMoreFlag) == 0 && !needMoreFlag && invalidSequenceLength(five) == 1);
        // cut 3-byte sequence: lead + valid second byte
        ubyte[] cut = [0xE2, 0x82, 0x41];
        assert(decodeBytes(cut,ch,needMoreFlag) == 0 && invalidSequenceLength(cut) == 2);
    }

    override uint decodeText() {
        //number of bytesAvailable
        uint len = readBytes();
        if (len == 0)
            return 0; // nothing to decode
        return decodeBuffer(len);
    }

    /// decodes the len bytes available in the buffer
    private uint decodeBuffer(uint len) @safe {
        const(ubyte)[] b = _buf[_pos .. _pos + len];
        uint chars = 0;
        dchar[] text = reserveTextBuf(len); // at most one character per byte
        uint i = 0;

        while (i < len) {
            uint ch = 0;
            bool needMoreFlag = false;
            uint bread = decodeBytes(b[i .. len],ch,needMoreFlag);

            if (needMoreFlag && !_streamEof) {
                // incomplete character at the end of the buffer: decode it when more bytes are read
                break;
            }

            if (bread == 0) {
                // invalid or (at the end of the stream) incomplete character
                text[chars++] = REPLACEMENT_CHAR;
                _invalidCharCount++;
                i += invalidSequenceLength(b[i .. len]);
                continue;
            }

            text[chars++] = ch; // one dchar, also above U+FFFF (was split into surrogates, #923)
            i += bread;
        }
        consumedBytes(i);
        appendedText(chars);
        return chars;
    }
}

private class Utf16LineStream(bool bigEndian) : LineStream {
    /// skip: 2 after a BOM, 0 for UTF-16 detected without BOM
    this(InputStream stream, string filename, ubyte[] buf, uint len, uint skip = 2) {
        super(stream, filename, bigEndian ? EncodingType.UTF16BE : EncodingType.UTF16LE, buf, skip, len);
    }
    override uint decodeText() {
        uint len = readBytes();
        if (len == 0)
            return 0; // nothing to decode
        return decodeBuffer(len);
    }

    /// the 16-bit unit at b[i .. i + 2]
    private static uint unit(scope const(ubyte)[] b, uint i) @safe pure nothrow @nogc {
        static if (bigEndian)
            return (b[i] << 8) | b[i + 1];
        else
            return (b[i + 1] << 8) | b[i];
    }

    /// decodes the len bytes available in the buffer; surrogate pairs are combined into one character, unpaired
    /// surrogates are replaced (#923)
    private uint decodeBuffer(uint len) @safe {
        const(ubyte)[] b = _buf[_pos .. _pos + len];
        uint chars = 0;
        dchar[] text = reserveTextBuf(len / 2 + 1);
        uint i = 0;
        while (i + 1 < len) {
            uint ch = unit(b, i);
            if (ch >= 0xD800 && ch < 0xDC00) {
                // high surrogate: a low surrogate must follow
                if (i + 3 >= len && !_streamEof)
                    break; // the low surrogate isn't read yet
                uint lo = i + 3 < len ? unit(b, i + 2) : 0;
                if (lo >= 0xDC00 && lo < 0xE000) {
                    ch = 0x10000 + ((ch - 0xD800) << 10) + (lo - 0xDC00);
                    i += 4;
                } else {
                    ch = REPLACEMENT_CHAR;
                    _invalidCharCount++;
                    i += 2;
                }
            } else {
                if (ch >= 0xDC00 && ch < 0xE000) {
                    // low surrogate without a high one
                    ch = REPLACEMENT_CHAR;
                    _invalidCharCount++;
                }
                i += 2;
            }
            text[chars++] = ch;
        }
        if (_streamEof && i < len) {
            // odd byte at the end of the stream
            text[chars++] = REPLACEMENT_CHAR;
            _invalidCharCount++;
            i = len;
        }
        consumedBytes(i);
        appendedText(chars);
        return chars;
    }
}

private alias Utf16beLineStream = Utf16LineStream!true;
private alias Utf16leLineStream = Utf16LineStream!false;

private class Utf32beLineStream : LineStream {
    this(InputStream stream, string filename, ubyte[] buf, uint len) {
        super(stream, filename, EncodingType.UTF32BE, buf, 4, len);
    }
    override uint decodeText() {
        uint len = readBytes();
        if (len == 0)
            return 0; // nothing to decode
        return decodeBuffer(len);
    }

    /// decodes the len bytes available in the buffer
    private uint decodeBuffer(uint len) @safe {
        const(ubyte)[] b = _buf[_pos .. _pos + len];
        uint chars = 0;
        dchar[] text = reserveTextBuf(len / 4 + 1);
        uint i = 0;
        // i + 3 < len: len - 3 wrapped around with 1 or 2 bytes left (#922)
        for (; i + 3 < len; i += 4) {
            uint ch0 = b[i];
            uint ch1 = b[i + 1];
            uint ch2 = b[i + 2];
            uint ch3 = b[i + 3];
            uint ch = (ch0 << 24) | (ch1 << 16) | (ch2 << 8) | ch3;
            if ((ch >= 0xd800 && ch < 0xe000) || (ch > 0x10FFFF)) {
                ch = REPLACEMENT_CHAR;
                _invalidCharCount++;
            }
            text[chars++] = ch;
        }
        if (_streamEof && i < len) {
            // 1 to 3 bytes left at the end of the stream
            text[chars++] = REPLACEMENT_CHAR;
            _invalidCharCount++;
            i = len;
        }
        consumedBytes(i);
        appendedText(chars);
        return chars;
    }
}

private class Utf32leLineStream : LineStream {
    this(InputStream stream, string filename, ubyte[] buf, uint len) {
        super(stream, filename, EncodingType.UTF32LE, buf, 4, len);
    }
    override uint decodeText() {
        uint len = readBytes();
        if (len == 0)
            return 0; // nothing to decode
        return decodeBuffer(len);
    }

    /// decodes the len bytes available in the buffer
    private uint decodeBuffer(uint len) @safe {
        const(ubyte)[] b = _buf[_pos .. _pos + len];
        uint chars = 0;
        dchar[] text = reserveTextBuf(len / 4 + 1);
        uint i = 0;
        // i + 3 < len: len - 3 wrapped around with 1 or 2 bytes left (#922)
        for (; i + 3 < len; i += 4) {
            uint ch3 = b[i];
            uint ch2 = b[i + 1];
            uint ch1 = b[i + 2];
            uint ch0 = b[i + 3];
            uint ch = (ch0 << 24) | (ch1 << 16) | (ch2 << 8) | ch3;
            if ((ch >= 0xd800 && ch < 0xe000) || (ch > 0x10FFFF)) {
                ch = REPLACEMENT_CHAR;
                _invalidCharCount++;
            }
            text[chars++] = ch;
        }
        if (_streamEof && i < len) {
            // 1 to 3 bytes left at the end of the stream
            text[chars++] = REPLACEMENT_CHAR;
            _invalidCharCount++;
            i = len;
        }
        consumedBytes(i);
        appendedText(chars);
        return chars;
    }
}


// decoding of complete, truncated and invalid input: invalid and incomplete characters are replaced by U+FFFD,
// counted in invalidCharCount, and decoding continues (#924)
unittest {
    static dstring[] readAll(const(ubyte)[] data, out uint invalid, bool autodetectUTF = true) {
        LineStream ls = LineStream.create(new MemoryInputStream(data.dup), "test", autodetectUTF);
        dstring[] lines;
        foreach (n; 0 .. 1000) {
            dchar[] line = ls.readLine();
            if (line is null)
                break;
            lines ~= line.idup;
        }
        invalid = ls.invalidCharCount;
        return lines;
    }
    uint invalid;
    // complete input in every encoding (with BOM), CR LF and LF line ends
    assert(readAll(cast(const(ubyte)[])"\xEF\xBB\xBFab\r\nc\xC3\x84\n", invalid) == ["ab"d, "cÄ"d] && !invalid);
    assert(readAll(cast(const(ubyte)[])"ab\nc", invalid) == ["ab"d, "c"d] && !invalid);
    assert(readAll([0xFE, 0xFF, 0, 'a', 0, '\n', 0x09, 0x34], invalid) == ["a"d, "ऴ"d] && !invalid);
    assert(readAll([0xFF, 0xFE, 'a', 0, '\n', 0, 0x34, 0x09], invalid) == ["a"d, "ऴ"d] && !invalid);
    assert(readAll([0, 0, 0xFE, 0xFF, 0, 0, 0, 'a', 0, 0, 0, '\n', 0, 0, 0x09, 0x34], invalid) == ["a"d, "ऴ"d] && !invalid);
    assert(readAll([0xFF, 0xFE, 0, 0, 'a', 0, 0, 0, '\n', 0, 0, 0, 0x34, 0x09, 0, 0], invalid) == ["a"d, "ऴ"d] && !invalid);
    // UTF-32 with 1 or 2 bytes left: no read past the input (#922), one replacement for the incomplete character
    assert(readAll([0xFF, 0xFE, 0, 0, 'A', 0, 0, 0, 'B', 0, 0, 0, 'C', 0], invalid) == ["AB\uFFFD"d] && invalid == 1);
    assert(readAll([0, 0, 0xFE, 0xFF, 0, 0, 0, 'A', 0], invalid) == ["A\uFFFD"d] && invalid == 1);
    // UTF-32 code point out of range, decoding continues
    assert(readAll([0xFF, 0xFE, 0, 0, 'A', 0, 0, 0, 0, 0, 0x11, 0, 'B', 0, 0, 0], invalid) == ["A\uFFFDB"d] && invalid == 1);
    // UTF-16 with an odd byte count
    assert(readAll([0xFF, 0xFE, 'A', 0, 'B'], invalid) == ["A\uFFFD"d] && invalid == 1);
    assert(readAll([0xFE, 0xFF, 0, 'A', 0], invalid) == ["A\uFFFD"d] && invalid == 1);
    // UTF-8: invalid byte (e.g. Latin-1), the rest of the file is decoded
    assert(readAll(cast(const(ubyte)[])"one\ncaf\xE9 two\nthree\n", invalid) == ["one"d, "caf\uFFFD two"d, "three"d] && invalid == 1);
    // cut sequence (lead byte and its continuation bytes: one replacement) at the end and in the middle
    assert(readAll(cast(const(ubyte)[])"ab\xC3", invalid) == ["ab\uFFFD"d] && invalid == 1);
    assert(readAll(cast(const(ubyte)[])"a\xE2\x82", invalid) == ["a\uFFFD"d] && invalid == 1);
    assert(readAll(cast(const(ubyte)[])"x\xE2\x82y\xF0\x9F\x98z", invalid) == ["x\uFFFDy\uFFFDz"d] && invalid == 2);
    // stray continuation bytes: one replacement each; overlong encodings (C0 80 was decoded as 0, i.e. end of file)
    assert(readAll(cast(const(ubyte)[])"\x84\x85a", invalid) == ["\uFFFD\uFFFDa"d] && invalid == 2);
    // (each byte is a maximal subpart: C0 is never valid, 80 doesn't follow E0)
    assert(readAll(cast(const(ubyte)[])"a\xC0\x80b\xE0\x80\xAFc", invalid) == ["a\uFFFD\uFFFDb\uFFFD\uFFFD\uFFFDc"d] && invalid == 5);
    // the old 5-byte form of U+0000 (decoded as 0, i.e. end of file), FF with continuation bytes, encoded surrogate
    assert(readAll(cast(const(ubyte)[])"a\xF8\x80\x80\x80\x80b\nc", invalid) == ["a\uFFFD\uFFFD\uFFFD\uFFFD\uFFFDb"d, "c"d] && invalid == 5);
    assert(readAll(cast(const(ubyte)[])"a\xFF\x80\x80b", invalid) == ["a\uFFFD\uFFFD\uFFFDb"d] && invalid == 3);
    assert(readAll(cast(const(ubyte)[])"a\xED\xA0\x80b", invalid) == ["a\uFFFD\uFFFD\uFFFDb"d] && invalid == 3);
    // lead bytes F5..F7 (over U+10FFFF) and F4 90 (over U+10FFFF): each byte is replaced
    assert(readAll(cast(const(ubyte)[])"a\xF5\x80\x80\x80b", invalid) == ["a\uFFFD\uFFFD\uFFFD\uFFFDb"d] && invalid == 4);
    assert(readAll(cast(const(ubyte)[])"a\xF4\x90\x80\x80b", invalid) == ["a\uFFFD\uFFFD\uFFFD\uFFFDb"d] && invalid == 4);
    // empty files with a BOM: UTF-16LE (FF FE, was detected as UTF-32LE and crashed, #933), UTF-16BE, UTF-8, UTF-32LE
    assert(readAll([0xFF, 0xFE], invalid) == [] && !invalid);
    assert(readAll([0xFE, 0xFF], invalid) == [] && !invalid);
    assert(readAll([0xEF, 0xBB, 0xBF], invalid) == [] && !invalid);
    assert(readAll([0xFF, 0xFE, 0, 0], invalid) == [] && !invalid);
    assert(readAll([0xFF, 0xFE, 'a', 0], invalid) == ["a"d] && !invalid);
    // ASCII (no UTF autodetection): bytes over 0x7F
    assert(readAll(cast(const(ubyte)[])"a\xE9b", invalid, false) == ["a\uFFFDb"d] && invalid == 1);
    // text longer than the buffers (512 bytes, 1024 characters), with invalid bytes across buffer boundaries
    char[] big;
    foreach (i; 0 .. 300)
        big ~= "line \xC3\x84 \xFF\n";
    dstring[] lines = readAll(cast(const(ubyte)[])big, invalid);
    assert(lines.length == 300 && lines[299] == "line Ä \uFFFD"d && invalid == 300);
}

// characters above U+FFFF: one dchar in every encoding, unpaired UTF-16 surrogates replaced (#923)
unittest {
    static dstring[] readAll(const(ubyte)[] data, out uint invalid) {
        LineStream ls = LineStream.create(new MemoryInputStream(data.dup), "test");
        dstring[] lines;
        foreach (n; 0 .. 1000) {
            dchar[] line = ls.readLine();
            if (line is null)
                break;
            lines ~= line.idup;
        }
        invalid = ls.invalidCharCount;
        return lines;
    }
    uint invalid;
    // U+1F600 in UTF-8, UTF-16LE/BE (surrogate pair D83D DE00), UTF-32LE
    assert(readAll(cast(const(ubyte)[])"a\xF0\x9F\x98\x80b", invalid) == ["a\U0001F600b"d] && !invalid);
    assert(readAll([0xFF, 0xFE, 'a', 0, 0x3D, 0xD8, 0x00, 0xDE, 'b', 0], invalid) == ["a\U0001F600b"d] && !invalid);
    assert(readAll([0xFE, 0xFF, 0, 'a', 0xD8, 0x3D, 0xDE, 0x00, 0, 'b'], invalid) == ["a\U0001F600b"d] && !invalid);
    assert(readAll([0xFF, 0xFE, 0, 0, 0x00, 0xF6, 0x01, 0, 'b', 0, 0, 0], invalid) == ["\U0001F600b"d] && !invalid);
    // unpaired surrogates: high followed by another character, low alone, high at the end of the file
    assert(readAll([0xFF, 0xFE, 'a', 0, 0x3D, 0xD8, 'b', 0], invalid) == ["a�b"d] && invalid == 1);
    assert(readAll([0xFF, 0xFE, 'a', 0, 0x00, 0xDE, 'b', 0], invalid) == ["a�b"d] && invalid == 1);
    assert(readAll([0xFF, 0xFE, 'a', 0, 0x3D, 0xD8], invalid) == ["a�"d] && invalid == 1);
    assert(readAll([0xFF, 0xFE, 'a', 0, 0x3D, 0xD8, 0x3D, 0xD8, 0x00, 0xDE], invalid) == ["a�\U0001F600"d] && invalid == 1);
    // a surrogate pair across the 512-byte buffer boundary (BOM + 254 units, then the pair at bytes 510..513)
    ubyte[] data = [0xFF, 0xFE];
    foreach (i; 0 .. 254)
        data ~= ['x', 0];
    data ~= [0x3D, 0xD8, 0x00, 0xDE, 'y', 0];
    dstring[] lines = readAll(data, invalid);
    dchar[] expected;
    foreach (i; 0 .. 254)
        expected ~= 'x';
    expected ~= "\U0001F600y"d;
    assert(lines == [expected.idup] && !invalid);
}

// NUL and Ctrl-Z, UTF-16 without BOM (#934); streams that return fewer bytes than asked for (#935)
unittest {
    // returns at most `chunk` bytes per read
    static class ShortReadStream : InputStream {
        const(ubyte)[] _data;
        size_t _pos, _chunk;
        this(const(ubyte)[] data, size_t chunk) { _data = data; _chunk = chunk; }
        void close() {}
        @property bool isOpen() { return true; }
        size_t read(ubyte[] buffer) {
            size_t n = 0;
            while (n < buffer.length && n < _chunk && _pos < _data.length)
                buffer[n++] = _data[_pos++];
            return n;
        }
        @property bool eof() { return _pos >= _data.length; }
    }
    static dstring[] readAll(InputStream stream, out uint invalid, out TextFileFormat format) {
        LineStream ls = LineStream.create(stream, "test");
        dstring[] lines;
        foreach (n; 0 .. 1000) {
            dchar[] line = ls.readLine();
            if (line is null)
                break;
            lines ~= line.idup;
        }
        invalid = ls.invalidCharCount;
        format = ls.textFormat;
        return lines;
    }
    static dstring[] read(const(ubyte)[] data, out TextFileFormat format, size_t chunk = size_t.max) {
        uint invalid;
        dstring[] res = readAll(chunk == size_t.max ? cast(InputStream)new MemoryInputStream(data.dup)
                : new ShortReadStream(data, chunk), invalid, format);
        assert(!invalid);
        return res;
    }
    TextFileFormat f;
    // NUL is an ordinary character (it ended the text); Ctrl-Z ends the text only as the last character
    assert(read(cast(const(ubyte)[])"a\0b\nc", f) == ["a\0b"d, "c"d]);
    assert(read(cast(const(ubyte)[])"ab\nc\x1A", f) == ["ab"d, "c"d]);
    assert(read(cast(const(ubyte)[])"ab\n\x1A", f) == ["ab"d]);
    assert(read(cast(const(ubyte)[])"a\x1Ab\nc", f) == ["a\x1Ab"d, "c"d]);
    // UTF-16 without BOM: detected from the zero bytes, saved back without BOM
    assert(read(cast(const(ubyte)[])"a\0b\0\n\0c\0", f) == ["ab"d, "c"d] && f.encoding == EncodingType.UTF16LE && !f.bom);
    assert(read(cast(const(ubyte)[])"\0a\0b\0\n\0c", f) == ["ab"d, "c"d] && f.encoding == EncodingType.UTF16BE && !f.bom);
    assert(LineStream.detectUtf16WithoutBom(cast(const(ubyte)[])"abcdefgh\0ij") == EncodingType.UTF8);
    assert(LineStream.detectUtf16WithoutBom(cast(const(ubyte)[])"x\0\0\0y\0\0\0") == EncodingType.UTF8); // UTF-32LE-like
    assert(read(cast(const(ubyte)[])"abcdefgh\0ij", f) == ["abcdefgh\0ij"d] && f.encoding == EncodingType.UTF8);
    // FF FE 00 00 followed by a character that isn't valid UTF-32LE: UTF-16LE starting with U+0000
    assert(read([0xFF, 0xFE, 0, 0, 'A', 0, 'B', 0], f) == ["\0AB"d] && f.encoding == EncodingType.UTF16LE && f.bom);
    assert(read([0xFF, 0xFE, 0, 0, 'A', 0, 0, 0], f) == ["A"d] && f.encoding == EncodingType.UTF32LE);
    assert(read([0xFF, 0xFE, 0, 0, 'A', 0], f) == ["\0A"d] && f.encoding == EncodingType.UTF16LE); // 6 bytes: not UTF-32
    assert(read([0xFF, 0xFE, 0, 0], f) == [] && f.encoding == EncodingType.UTF32LE); // the BOM alone
    // fewer than 2 units: not detected as UTF-16 (read as UTF-8 with NUL, saved back unchanged)
    assert(read(cast(const(ubyte)[])"a\0", f) == ["a\0"d] && f.encoding == EncodingType.UTF8);
    // one byte per read: UTF-8 sequences, BOMs and UTF-16 surrogate pairs end in the middle of a read (#935)
    foreach (chunk; [1, 2, 3, 5]) {
        assert(read(cast(const(ubyte)[])"a\xC3\x84\xE2\x82\xAC\xF0\x9F\x98\x80\nz", f, chunk) == ["aÄ€\U0001F600"d, "z"d]);
        assert(read(cast(const(ubyte)[])"\xEF\xBB\xBFab", f, chunk) == ["ab"d] && f.encoding == EncodingType.UTF8 && f.bom);
        assert(read([0xFF, 0xFE, 'a', 0, 0x3D, 0xD8, 0x00, 0xDE], f, chunk) == ["a\U0001F600"d] && f.encoding == EncodingType.UTF16LE);
        assert(read([0, 0, 0xFE, 0xFF, 0, 0, 0, 'a', 0, 1, 0xF6, 0], f, chunk) == ["a\U0001F600"d] && f.encoding == EncodingType.UTF32BE);
        assert(read([0xFF, 0xFE, 0, 0, 'A', 0, 'B', 0], f, chunk) == ["\0AB"d] && f.encoding == EncodingType.UTF16LE);
        assert(read(cast(const(ubyte)[])"a\0b\0\n\0c\0", f, chunk) == ["ab"d, "c"d] && f.encoding == EncodingType.UTF16LE);
    }
}

unittest {
    static if (false) {
        import std.stdio;
        import std.conv;
        import std.utf;
        //string fname = "C:\\projects\\d\\ddc\\ddclexer\\src\\ddc\\lexer\\LineStream.d";
        //string fname = "/home/lve/src/d/ddc/ddclexer/" ~ __FILE__; //"/home/lve/src/d/ddc/ddclexer/src/ddc/lexer/Lexer.d";
        //string fname = "/home/lve/src/d/ddc/ddclexer/tests/LineStream_utf8.d";
        //string fname = "/home/lve/src/d/ddc/ddclexer/tests/LineStream_utf16be.d";
        //string fname = "/home/lve/src/d/ddc/ddclexer/tests/LineStream_utf16le.d";
        //string fname = "/home/lve/src/d/ddc/ddclexer/tests/LineStream_utf32be.d";
        string fname = "/home/lve/src/d/ddc/ddclexer/tests/LineStream_utf32le.d";
        writeln("opening file");
        std.stream.File f = new std.stream.File(fname);
        scope(exit) { f.close(); }
        try {
            LineStream lines = LineStream.create(f, fname);
            for (;;) {
                dchar[] s = lines.readLine();
                if (s is null)
                    break;
                writeln("line " ~ to!string(lines.line()) ~ ":" ~ toUTF8(s));
            }
            if (lines.errorCode != 0) {
                writeln("Error ", lines.errorCode, " ", lines.errorMessage, " -- at line ", lines.errorLine, " position ", lines.errorPos);
            } else {
                writeln("EOF reached");
            }
        } catch (Exception e) {
            writeln("Exception " ~ e.toString);
        }
    }
}
// LAST LINE
