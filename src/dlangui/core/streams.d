module dlangui.core.streams;

private import std.stdio;

interface Closeable {
    void close();
    @property bool isOpen();
}

interface InputStream : Closeable {
    size_t read(ubyte[] buffer);
    @property bool eof();
}

interface OutputStream : Closeable {
    void write(ubyte[] data);
}

class FileInputStream : InputStream {
    std.stdio.File _file;
    this(string filename) {
        _file = std.stdio.File(filename, "rb");
    }
    void close() {
        if (isOpen)
            _file.close();
    }
    size_t read(ubyte[] buffer) {
        ubyte[] res = _file.rawRead(buffer);
        return res.length;
    }
    @property bool isOpen() {
        return _file.isOpen;
    }
    @property bool eof() {
        return _file.eof;
    }
}

class FileOutputStream : OutputStream {
    std.stdio.File _file;
    this(string filename) {
        _file = std.stdio.File(filename, "wb");
    }
    void close() {
        _file.close();
    }
    void write(ubyte[] data) {
        _file.rawWrite(data);
    }
    @property bool isOpen() {
        return _file.isOpen;
    }
}

class MemoryInputStream : InputStream {
    private ubyte[] _data;
    private size_t _pos;
    private bool _closed;
    this(ubyte[] data) {
        _data = data;
        _closed = false;
        _pos = 0;
    }
    void close() {
        _closed = true;
    }
    @property bool isOpen() {
        return !_closed;
    }
    size_t read(ubyte[] buffer) {
        size_t bytesRead = 0;
        for (size_t i = 0; i < buffer.length && _pos < _data.length; bytesRead++) {
            buffer[i++] = _data[_pos++];
        }
        return bytesRead;
    }
    @property bool eof() {
        return _closed || (_pos >= _data.length);
    }
}
