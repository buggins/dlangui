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

import std.stream;
import std.stdio;
import std.conv;

/** 
    Support reading of file (or string in memory) by lines

    Support utf8, utf16, utf32 be and le encodings, and line endings - according to D language source file specification.

    Low resource consuming. Doesn't flood with GC allocations. Dup line if you want to store it somewhere.

    Tracks line number.
*/
class LineStream {
    /// File encoding
	public enum EncodingType {
        /// plaing ASCII (character codes must be <= 127)
        ASCII,
        /// utf-8 unicode
        UTF8,
        /// utf-16 unicode big endian
        UTF16BE,
        /// utf-16 unicode little endian
        UTF16LE,
        /// utf-32 unicode big endian
        UTF32BE,
        /// utf-32 unicode little endian
        UTF32LE
    };

    /// Error codes
    public enum ErrorCodes {
        /// invalid character for current encoding
        INVALID_CHARACTER
    };

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

    /// Returns file name
	@property string filename() { return _filename; }
    /// Returns current line number
	@property uint line() { return _line; }
    /// Returns file encoding EncodingType
	@property EncodingType encoding() { return _encoding; }
    /// Returns error code
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
		_buf = buf;
		_len = len;
		_pos = offset;
		_streamEof = _stream.eof;
	}
	
	/// returns slice of bytes available in buffer
	protected uint readBytes() {
		uint bytesLeft = _len - _pos;
		if (_streamEof || bytesLeft > QUARTER_BYTE_BUFFER_SIZE)
			return bytesLeft;
		if (_pos > 0) {
			for (uint i = 0; i < bytesLeft; i++)
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
	protected void consumedBytes(uint count) {
		_pos += count;
	}

	// reserve text buffer for specified number of characters, and return pointer to first free character in buffer
	protected dchar * reserveTextBuf(uint len) {
		// create new text buffer if necessary
		if (_textBuf == null) {
			if (len < TEXT_BUFFER_SIZE)
				len = TEXT_BUFFER_SIZE;
			_textBuf = new dchar[len];
			return _textBuf.ptr;
		}
		uint spaceLeft = cast(uint)_textBuf.length - _textLen;
		if (spaceLeft >= len)
			return _textBuf.ptr + _textLen;
		// move text to beginning of buffer, if necessary
		if (_textPos > _textBuf.length / 2) {
			uint charCount = _textLen - _textPos;
			dchar * p = _textBuf.ptr;
			for (uint i = 0; i < charCount; i++)
				p[i] = p[i + _textPos];
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
		return _textBuf.ptr + _textLen;
	}
	
	protected void appendedText(uint len) {
		//writeln("appended ", len, " chars of text"); //:", _textBuf[_textLen .. _textLen + len]);
		_textLen += len;
	}
	
	protected void setError(int code, string message, uint errorLine, uint errorPos) {
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
				if (ch == 0x0D) {
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
					if (ch2 == 0x0A)
						eol = p + 2;
					else
						eol = p + 1;
					break;
				} else if (ch == 0x0A || ch == 0x2028 || ch == 0x2029) {
					// single char eoln
					lastchar = p;
					eol = p + 1;
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
		for (uint i = 0; i < len; i++)
			data[i + 3] = code[i];
		// BOM for UTF8
		data[0] = 0xEF;
		data[1] = 0xBB;
		data[2] = 0xBF;
		MemoryStream stream = new MemoryStream(data);
		return create(stream, filename);
	}
	
	/// Factory for InputStream parser
	public static LineStream create(InputStream stream, string filename) {
		ubyte[] buf = new ubyte[BYTE_BUFFER_SIZE];
		buf[0] = buf[1] = buf[2]  = buf[3] = 0;
		if (!stream.isOpen)
			return null;
        uint len = cast(uint)stream.read(buf);
        if (buf[0] == 0xEF && buf[1] == 0xBB && buf[2] == 0xBF) {
			return new Utf8LineStream(stream, filename, buf, len);
        } else if (buf[0] == 0x00 && buf[1] == 0x00 && buf[2] == 0xFE && buf[3] == 0xFF) {
			return new Utf32beLineStream(stream, filename, buf, len);
        } else if (buf[0] == 0xFF && buf[1] == 0xFE && buf[2] == 0x00 && buf[3] == 0x00) {
			return new Utf32leLineStream(stream, filename, buf, len);
        } else if (buf[0] == 0xFE && buf[1] == 0xFF) {
			return new Utf16beLineStream(stream, filename, buf, len);
        } else if (buf[0] == 0xFF && buf[1] == 0xFE) {
			return new Utf16leLineStream(stream, filename, buf, len);
		} else {
			return new AsciiLineStream(stream, filename, buf, len);
		}
	}
	
	protected bool invalidCharFlag;
	protected void invalidCharError() {
		uint pos = _textLen - _textPos + 1;
		setError(ErrorCodes.INVALID_CHARACTER, "Invalid character in line " ~ to!string(_line) ~ ":" ~ to!string(pos), _line, pos);
	}
}


private class AsciiLineStream : LineStream {
	this(InputStream stream, string filename, ubyte[] buf, uint len) {
		super(stream, filename, EncodingType.ASCII, buf, 0, len);
	}	
	override uint decodeText() {
		if (invalidCharFlag) {
			invalidCharError();
			return 0;
		}
		uint bytesAvailable = readBytes();
		ubyte * bytes = _buf.ptr + _pos;
		if (bytesAvailable == 0)
			return 0; // nothing to decode
		uint len = bytesAvailable;
		ubyte* b = bytes;
		dchar* text = reserveTextBuf(len);
		uint i = 0;
		for (; i < len; i++) {
			ubyte ch = b[i];
			if (ch & 0x80) {
				// invalid character
				invalidCharFlag = true;
				break;
			}
			text[i] = ch;
		}
		consumedBytes(i);
		appendedText(i);
		return len;
	}
	
}

private class Utf8LineStream : LineStream {
	this(InputStream stream, string filename, ubyte[] buf, uint len) {
		super(stream, filename, EncodingType.UTF8, buf, 3, len);
	}
	override uint decodeText() {
		if (invalidCharFlag) {
			invalidCharError();
			return 0;
		}
		uint bytesAvailable = readBytes();
		ubyte * bytes = _buf.ptr + _pos;
		if (bytesAvailable == 0)
			return 0; // nothing to decode
		uint len = bytesAvailable;
		uint chars = 0;
		ubyte* b = bytes;
		dchar* text = reserveTextBuf(len);
		uint i = 0;
		for (; i < len; i++) {
			uint ch = 0;
			uint ch0 = b[i];
			uint bleft = len - i;
			uint bread = 0;
            if (!(ch0 & 0x80)) {
                // 0x00..0x7F single byte
                ch = ch0;
                bread = 1;
            } if ((ch0 & 0xE0) == 0xC0) {
                // two bytes 110xxxxx 10xxxxxx
                if (bleft < 2)
                    break;
                uint ch1 = b[i + 1];
				if ((ch1 & 0xC0) != 0x80) {
					invalidCharFlag = true;
                    break;
				}
                ch = ((ch0 & 0x1F) << 6) | ((ch1 & 0x3F));
                bread = 2;
            } if ((ch0 & 0xF0) == 0xE0) {
                // three bytes 1110xxxx 10xxxxxx 10xxxxxx
                if (bleft < 3)
                    break;
                uint ch1 = b[i + 1];
                uint ch2 = b[i + 2];
                if ((ch1 & 0xC0) != 0x80 || (ch2 & 0xC0) != 0x80) {
					invalidCharFlag = true;
                    break;
				}
                ch = ((ch0 & 0x0F) << 12) | ((ch1 & 0x1F) << 6) | ((ch2 & 0x3F));
                bread = 3;
            } if ((ch0 & 0xF8) == 0xF0) {
                // four bytes 11110xxx 10xxxxxx 10xxxxxx 10xxxxxx
                if (bleft < 4)
                    break;
                uint ch1 = b[i + 1];
                uint ch2 = b[i + 2];
                uint ch3 = b[i + 3];
                if ((ch1 & 0xC0) != 0x80 || (ch2 & 0xC0) != 0x80 || (ch3 & 0xC0) != 0x80) {
					invalidCharFlag = true;
                    break;
				}
                ch = ((ch0 & 0x07) << 18) | ((ch1 & 0x3F) << 12) | ((ch2 & 0x3F) << 6) | ((ch3 & 0x3F));
                bread = 4;
            } if ((ch0 & 0xFC) == 0xF8) {
                // five bytes 111110xx 10xxxxxx 10xxxxxx 10xxxxxx 10xxxxxx
                if (bleft < 5)
                    break;
                uint ch1 = b[i + 1];
                uint ch2 = b[i + 2];
                uint ch3 = b[i + 3];
                uint ch4 = b[i + 4];
                if ((ch1 & 0xC0) != 0x80 || (ch2 & 0xC0) != 0x80 || (ch3 & 0xC0) != 0x80 || (ch4 & 0xC0) != 0x80) {
					invalidCharFlag = true;
                    break;
				}
                ch = ((ch0 & 0x03) << 24) | ((ch1 & 0x3F) << 18) | ((ch2 & 0x3F) << 12) | ((ch3 & 0x3F) << 6) | ((ch4 & 0x3F));
                bread = 5;
            } if ((ch0 & 0xFE) == 0xFC) {
                // six bytes 1111110x 10xxxxxx 10xxxxxx 10xxxxxx 10xxxxxx 10xxxxxx
                if (bleft < 6)
                    break;
                uint ch1 = b[i + 1];
                uint ch2 = b[i + 2];
                uint ch3 = b[i + 3];
                uint ch4 = b[i + 4];
                uint ch5 = b[i + 5];
                if ((ch1 & 0xC0) != 0x80 || (ch2 & 0xC0) != 0x80 || (ch3 & 0xC0) != 0x80 || (ch4 & 0xC0) != 0x80 || (ch5 & 0xC0) != 0x80) {
					invalidCharFlag = true;
                    break;
				}
                ch = ((ch0 & 0x01) << 30) | ((ch1 & 0x3F) << 24) | ((ch2 & 0x3F) << 18) | ((ch3 & 0x3F) << 12) | ((ch4 & 0x3F) << 6) | ((ch5 & 0x3F));
                bread = 5;
            }
			if ((ch >= 0xd800 && ch < 0xe000) || (ch > 0x10FFFF)) {
				invalidCharFlag = true;
                break;
			}
			if (ch < 0x10000) {
				text[chars++] = ch;
			} else {
				uint lo = ch & 0x3FF;
				uint hi = ch >> 10;
				text[chars++] = (0xd800 | hi);
				text[chars++] = (0xdc00 | lo);
			}
			i += bread - 1;
		}
		consumedBytes(i);
		appendedText(chars);
		uint bleft = len - i;
		if (_streamEof && bleft > 0)
			invalidCharFlag = true; // incomplete character at end of stream
		return chars;
	}
}

private class Utf16beLineStream : LineStream {
	this(InputStream stream, string filename, ubyte[] buf, uint len) {
		super(stream, filename, EncodingType.UTF16BE, buf, 2, len);
	}
	override uint decodeText() {
		if (invalidCharFlag) {
			invalidCharError();
			return 0;
		}
		uint bytesAvailable = readBytes();
		ubyte * bytes = _buf.ptr + _pos;
		if (bytesAvailable == 0)
			return 0; // nothing to decode
		uint len = bytesAvailable;
		uint chars = 0;
		ubyte* b = bytes;
		dchar* text = reserveTextBuf(len / 2 + 1);
		uint i = 0;
		for (; i < len - 1; i += 2) {
			uint ch0 = b[i];
			uint ch1 = b[i + 1];
			uint ch = (ch0 << 8) | ch1;
			// TODO: check special cases
			text[chars++] = ch;
		}
		consumedBytes(i);
		appendedText(chars);
		uint bleft = len - i;
		if (_streamEof && bleft > 0)
			invalidCharFlag = true; // incomplete character at end of stream
		return chars;
	}
}

private class Utf16leLineStream : LineStream {
	this(InputStream stream, string filename, ubyte[] buf, uint len) {
		super(stream, filename, EncodingType.UTF16LE, buf, 2, len);
	}	
	override uint decodeText() {
		if (invalidCharFlag) {
			invalidCharError();
			return 0;
		}
		uint bytesAvailable = readBytes();
		ubyte * bytes = _buf.ptr + _pos;
		if (bytesAvailable == 0)
			return 0; // nothing to decode
		uint len = bytesAvailable;
		uint chars = 0;
		ubyte* b = bytes;
		dchar* text = reserveTextBuf(len / 2 + 1);
		uint i = 0;
		for (; i < len - 1; i += 2) {
			uint ch0 = b[i];
			uint ch1 = b[i + 1];
			uint ch = (ch1 << 8) | ch0;
			// TODO: check special cases
			text[chars++] = ch;
		}
		consumedBytes(i);
		appendedText(chars);
		uint bleft = len - i;
		if (_streamEof && bleft > 0)
			invalidCharFlag = true; // incomplete character at end of stream
		return chars;
	}
}

private class Utf32beLineStream : LineStream {
	this(InputStream stream, string filename, ubyte[] buf, uint len) {
		super(stream, filename, EncodingType.UTF32BE, buf, 4, len);
	}	
	override uint decodeText() {
		if (invalidCharFlag) {
			invalidCharError();
			return 0;
		}
		uint bytesAvailable = readBytes();
		ubyte * bytes = _buf.ptr + _pos;
		if (bytesAvailable == 0)
			return 0; // nothing to decode
		uint len = bytesAvailable;
		uint chars = 0;
		ubyte* b = bytes;
		dchar* text = reserveTextBuf(len / 2 + 1);
		uint i = 0;
		for (; i < len - 3; i += 4) {
			uint ch0 = b[i];
			uint ch1 = b[i + 1];
			uint ch2 = b[i + 2];
			uint ch3 = b[i + 3];
			uint ch = (ch0 << 24) | (ch1 << 16) | (ch2 << 8) | ch3;
			if ((ch >= 0xd800 && ch < 0xe000) || (ch > 0x10FFFF)) {
				invalidCharFlag = true;
                break;
			}
			text[chars++] = ch;
		}
		consumedBytes(i);
		appendedText(chars);
		uint bleft = len - i;
		if (_streamEof && bleft > 0)
			invalidCharFlag = true; // incomplete character at end of stream
		return chars;
	}
}

private class Utf32leLineStream : LineStream {
	this(InputStream stream, string filename, ubyte[] buf, uint len) {
		super(stream, filename, EncodingType.UTF32LE, buf, 4, len);
	}	
	override uint decodeText() {
		if (invalidCharFlag) {
			invalidCharError();
			return 0;
		}
		uint bytesAvailable = readBytes();
		ubyte * bytes = _buf.ptr + _pos;
		if (bytesAvailable == 0)
			return 0; // nothing to decode
		uint len = bytesAvailable;
		uint chars = 0;
		ubyte* b = bytes;
		dchar* text = reserveTextBuf(len / 2 + 1);
		uint i = 0;
		for (; i < len - 3; i += 4) {
			uint ch3 = b[i];
			uint ch2 = b[i + 1];
			uint ch1 = b[i + 2];
			uint ch0 = b[i + 3];
			uint ch = (ch0 << 24) | (ch1 << 16) | (ch2 << 8) | ch3;
			if ((ch >= 0xd800 && ch < 0xe000) || (ch > 0x10FFFF)) {
				invalidCharFlag = true;
                break;
			}
			text[chars++] = ch;
		}
		consumedBytes(i);
		appendedText(chars);
		uint bleft = len - i;
		if (_streamEof && bleft > 0)
			invalidCharFlag = true; // incomplete character at end of stream
		return chars;
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
