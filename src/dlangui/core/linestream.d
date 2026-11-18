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
                    int bytes = cast(int)encode(utf8, s[i]);
                    foreach(j; 0 .. bytes)
                        _buf[_len++] = utf8[j];
                }
                break;
            case UTF16BE:
                wchar[2] utf16be;
                foreach(i; 0 .. s.length) {
                    int n = cast(int)encode(utf16be, s[i]);
                    foreach(j; 0 .. n) {
                        _buf[_len++] = cast(char)(utf16be[j] >> 8);
                        _buf[_len++] = cast(char)(utf16be[j] & 0xFF);
                    }
                }
                break;
            case UTF16LE:
                wchar[2] utf16le;
                foreach(i; 0 .. s.length) {
                    int n = cast(int)encode(utf16le, s[i]);
                    foreach(j; 0 .. n) {
                        _buf[_len++] = cast(char)(utf16le[j] & 0xFF);
                        _buf[_len++] = cast(char)(utf16le[j] >> 8);
                    }
                }
                break;
            case UTF32LE:
                foreach(i; 0 .. s.length) {
                    dchar ch = s[i];
                    _buf[_len++] = cast(char)((ch >> 0) & 0xFF);
                    _buf[_len++] = cast(char)((ch >> 8) & 0xFF);
                    _buf[_len++] = cast(char)((ch >> 16) & 0xFF);
                    _buf[_len++] = cast(char)((ch >> 24) & 0xFF);
                }
                break;
            case UTF32BE:
                foreach(i; 0 .. s.length) {
                    dchar ch = s[i];
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
                uint decodedChars = decodeText();
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
                        decodeText();
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
                } else if (ch == 0 || ch == 0x001A) {
                    // eof
                    //writeln("EOF char found");
                    lastchar = p;
                    eol = eof = p + 1;
                    break;
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

    /// Factory for InputStream parser
    public static LineStream create(InputStream stream, string filename, bool autodetectUTFIfNoBOM = true) {
        ubyte[] buf = new ubyte[BYTE_BUFFER_SIZE];
        buf[0] = buf[1] = buf[2]  = buf[3] = 0;
        if (!stream.isOpen)
            return null;
        uint len = cast(uint)stream.read(buf);
        LineStream res = null;
        if (buf[0] == 0xEF && buf[1] == 0xBB && buf[2] == 0xBF) {
            res = new Utf8LineStream(stream, filename, buf, len, 3);
        } else if (len >= 4 && buf[0] == 0x00 && buf[1] == 0x00 && buf[2] == 0xFE && buf[3] == 0xFF) {
            res = new Utf32beLineStream(stream, filename, buf, len);
        } else if (len >= 4 && buf[0] == 0xFF && buf[1] == 0xFE && buf[2] == 0x00 && buf[3] == 0x00) {
            // (len >= 4: an empty UTF-16LE file is just FF FE, and the buffer is zeroed, #933)
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
        uint maxResultingBytes = len*2; //len*2 because worst case is if all input chars are singelbyte and resulting in two bytes
        dchar[] text = reserveTextBuf(maxResultingBytes);
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

            if (ch < 0x10000) {
                text[chars++] = ch;
            } else {
                uint lo = ch & 0x3FF;
                uint hi = ch >> 10;
                text[chars++] = (0xd800 | hi);
                text[chars++] = (0xdc00 | lo);
            }
            i += bread;
        }
        consumedBytes(i);
        appendedText(chars);
        return chars;
    }
}

private class Utf16beLineStream : LineStream {
    this(InputStream stream, string filename, ubyte[] buf, uint len) {
        super(stream, filename, EncodingType.UTF16BE, buf, 2, len);
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
        dchar[] text = reserveTextBuf(len / 2 + 1);
        uint i = 0;
        for (; i + 1 < len; i += 2) {
            uint ch0 = b[i];
            uint ch1 = b[i + 1];
            uint ch = (ch0 << 8) | ch1;
            // TODO: check special cases
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

private class Utf16leLineStream : LineStream {
    this(InputStream stream, string filename, ubyte[] buf, uint len) {
        super(stream, filename, EncodingType.UTF16LE, buf, 2, len);
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
        dchar[] text = reserveTextBuf(len / 2 + 1);
        uint i = 0;
        for (; i + 1 < len; i += 2) {
            uint ch0 = b[i];
            uint ch1 = b[i + 1];
            uint ch = (ch1 << 8) | ch0;
            // TODO: check special cases
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
