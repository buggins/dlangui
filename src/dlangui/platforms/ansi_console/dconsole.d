module dlangui.platforms.ansi_console.dconsole;


public import dlangui.core.config;
static if (BACKEND_CONSOLE):

import std.stdio;
import dlangui.core.logger;

version(Windows) {
    import core.sys.windows.winbase;
    import core.sys.windows.wincon;
    import core.sys.windows.winuser;
    private import core.sys.windows.basetyps, core.sys.windows.w32api, core.sys.windows.winnt;
}
import dlangui.core.signals;
import dlangui.core.events;

/// console cursor type
enum ConsoleCursorType {
    Invisible, /// hidden
    Insert,    /// insert (usually underscore)
    Replace,   /// replace (usually square)
}

enum TextColor : ubyte {
    BLACK,          // 0
    BLUE,
    GREEN,
    CYAN,
    RED,
    MAGENTA,
    YELLOW,
    GREY,
    DARK_GREY,      // 8
    LIGHT_BLUE,
    LIGHT_GREEN,
    LIGHT_CYAN,
    LIGHT_RED,
    LIGHT_MAGENTA,
    LIGHT_YELLOW,
    WHITE,          // 15
}

immutable ubyte CONSOLE_TRANSPARENT_BACKGROUND = 0xFF;

struct ConsoleChar {
    dchar ch;
    uint  attr = 0xFFFFFFFF;
    @property ubyte backgroundColor() { return cast(ubyte)((attr >> 8) & 0xFF); }
    @property void backgroundColor(ubyte b) { attr = (attr & 0xFFFF00FF) | ((cast(uint)b) << 8); }
    @property ubyte textColor() { return cast(ubyte)((attr) & 0xFF); }
    @property void textColor(ubyte b) { attr = (attr & 0xFFFFFF00) | ((cast(uint)b)); }
    @property bool underline() { return (attr & 0x10000) != 0; }
    @property void underline(bool b) { attr = (attr & ~0x10000); if (b) attr |= 0x10000; }
    /// set value, supporting transparent background
    void set(ConsoleChar v) {
        if (v.backgroundColor == CONSOLE_TRANSPARENT_BACKGROUND) {
            ch = v.ch;
            textColor = v.textColor;
            underline = v.underline;
        } else
            this = v;
    }
}

immutable ConsoleChar UNKNOWN_CHAR = ConsoleChar.init;

struct ConsoleBuf {
    protected int _width;
    protected int _height;
    protected int _cursorX;
    protected int _cursorY;
    protected ConsoleChar[] _chars;


    @property int width() { return _width; }
    @property int height() { return _height; }
    @property int cursorX() { return _cursorX; }
    @property int cursorY() { return _cursorY; }

    void clear(ConsoleChar ch) {
        _chars[0 .. $] = ch;
    }
    void copyFrom(ref ConsoleBuf buf) {
        _width = buf._width;
        _height = buf._height;
        _cursorX = buf._cursorX;
        _cursorY = buf._cursorY;
        _chars.length = buf._chars.length;
        for(int i = 0; i < _chars.length; i++)
            _chars[i] = buf._chars[i];
    }
    void set(int x, int y, ConsoleChar ch) {
        _chars[y * _width + x].set(ch);
    }
    ConsoleChar get(int x, int y) {
        return _chars[y * _width + x];
    }
    ConsoleChar[] line(int y) {
        return _chars[y * _width .. (y + 1) * _width];
    }
    void resize(int w, int h) {
        if (_width != w || _height != h) {
            _chars.length = w * h;
            _width = w;
            _height = h;
        }
        _cursorX = 0;
        _cursorY = 0;
        _chars[0 .. $] = UNKNOWN_CHAR;
    }
    void scrollUp(uint attr) {
        for (int i = 0; i + 1 < _height; i++) {
            _chars[i * _width .. (i + 1) * _width] = _chars[(i + 1) * _width .. (i + 2) * _width];
        }
        _chars[(_height - 1) * _width .. _height * _width] = ConsoleChar(' ', attr);
    }
    void setCursor(int x, int y) {
        _cursorX = x;
        _cursorY = y;
    }
    void writeChar(dchar ch, uint attr) {
        if (_cursorX >= _width) {
            _cursorY++;
            _cursorX = 0;
            if (_cursorY >= _height) {
                _cursorY = _height - 1;
                scrollUp(attr);
            }
        }
        if (ch == '\n') {
            _cursorX = 0;
            _cursorY++;
            if (_cursorY >= _height) {
                scrollUp(attr);
                _cursorY = _height - 1;
            }
            return;
        }
        if (ch == '\r') {
            _cursorX = 0;
            return;
        }
        set(_cursorX, _cursorY, ConsoleChar(ch, attr));
        _cursorX++;
        if (_cursorX >= _width) {
            if (_cursorY < _height - 1) {
                _cursorY++;
                _cursorX = 0;
            }
        }
    }
    void write(dstring str, uint attr) {
        for (int i = 0; i < str.length; i++) {
            writeChar(str[i], attr);
        }
    }
}

version (Windows) {
} else {
    import core.sys.posix.signal;
    import dlangui.core.logger;
    __gshared bool SIGHUP_flag = false;
    extern(C) void signalHandler_SIGHUP( int ) nothrow @nogc @system
    {
        SIGHUP_flag = true;
        try {
            //Log.w("SIGHUP signal fired");
        } catch (Exception e) {
        }
    }

    void setSignalHandlers() {
        signal(SIGHUP, &signalHandler_SIGHUP);
    }
}

/// console I/O support
class Console {
    import core.time : Duration;
    private Duration _escTimeout;
    private bool _escTimeoutSet;
    /**
        How long a lone ESC waits for a second key before it's the Esc key (terminals, #1041): ESC + digit is an F-key
        (ESC 1..9, ESC 0: F1..F10), ESC + another key is the key with Alt. 50 ms by default, so Esc reacts at once and
        the prefix works for terminals that send it (Alt+1 as ESC 1); ESCDELAY in milliseconds from the environment,
        as for ncurses apps, e.g. ESCDELAY=1000 to type ESC, 1 by hand for F1. ESC ESC is the Esc key after 50 ms
        whatever ESCDELAY is.
    */
    @property Duration escTimeout() {
        if (!_escTimeoutSet) {
            import std.process : environment;
            _escTimeout = escTimeoutFromEnvironment(environment.get("ESCDELAY"));
            _escTimeoutSet = true;
        }
        return _escTimeout;
    }
    /// ditto
    @property void escTimeout(Duration timeout) {
        _escTimeout = timeout;
        _escTimeoutSet = true;
    }
    private int _cursorX;
    private int _cursorY;
    private int _width;
    private int _height;

    private ConsoleBuf _buf;
    private ConsoleBuf _batchBuf;
    private uint _consoleAttr;
    private bool _stopped;

    @property int width() { return _width; }
    @property int height() { return _height; }
    @property int cursorX() { return _cursorX; }
    @property int cursorY() { return _cursorY; }
    @property void cursorX(int x) { _cursorX = x; }
    @property void cursorY(int y) { _cursorY = y; }

    version(Windows) {
        HANDLE _hstdin;
        HANDLE _hstdout;
        WORD _attr;
        immutable ushort COMMON_LVB_UNDERSCORE = 0x8000;
    } else {
        immutable int READ_BUF_SIZE = 1024;
        char[READ_BUF_SIZE] readBuf;
        int readBufPos = 0;
        bool isSequenceCompleted() {
            if (!readBufPos)
                return false;
            if (readBuf[0] == 0x1B)
                return isEscSequenceComplete(readBuf[0 .. readBufPos]);
            if (readBuf[0] & 0x80) {
                if ((readBuf[0] & 0xE0) == 0xC0)
                    return readBufPos >= 2;
                if ((readBuf[0] & 0xF0) == 0xE0)
                    return readBufPos >= 3;
                if ((readBuf[0] & 0xF8) == 0xF0)
                    return readBufPos >= 4;
                if ((readBuf[0] & 0xFC) == 0xF8)
                    return readBufPos >= 5;
                return readBufPos >= 6;
            }
            return true;
        }
        string rawRead(int pollTimeout = 3000) {
            if (_stopped)
                return null;
            import core.thread;
            import core.stdc.errno;
            int waitTime = 0;
            int startPos = readBufPos;
            while (readBufPos < READ_BUF_SIZE) {
                import core.sys.posix.unistd;
                char ch = 0;
                int res = cast(int)read(STDIN_FILENO, &ch, 1);
                if (res < 0) {
                    auto err = errno;
                    switch (err) {
                        case EBADF:
                            Log.e("rawRead stdin EINVAL - stopping terminal");
                            _stopped = true;
                            return null;
                        case EFAULT:
                            Log.e("rawRead stdin EINVAL - stopping terminal");
                            _stopped = true;
                            return null;
                        case EINVAL:
                            Log.e("rawRead stdin EINVAL - stopping terminal");
                            _stopped = true;
                            return null;
                        case EIO:
                            Log.e("rawRead stdin EIO - stopping terminal");
                            _stopped = true;
                            return null;
                        default:
                            break;
                    }
                }
                if (res <= 0) {
                    if (readBufPos == startPos && waitTime < pollTimeout) {
                        Thread.sleep( dur!("msecs")( 10 ) );
                        waitTime += 10;
                        continue;
                    }
                    break;
                }
                readBuf[readBufPos++] = ch;
                if (isSequenceCompleted())
                    break;
            }
            if (readBufPos > 0 && isSequenceCompleted()) {
                string s = readBuf[0 .. readBufPos].idup;
                readBufPos = 0;
                _partialSince = MonoTime.zero;
                return s;
            }
            if (readBufPos > 0) {
                // incomplete: a lone ESC is the Esc key after escTimeout; other bytes (ESC ESC, a sequence cut by a
                // slow link) are passed on as they are after SEQUENCE_TIMEOUT (#1041)
                immutable MonoTime now = MonoTime.currTime;
                if (_partialSince == MonoTime.zero) {
                    _partialSince = now;
                } else if (now - _partialSince >= (readBufPos == 1 ? escTimeout : SEQUENCE_TIMEOUT)) {
                    string s = readBuf[0 .. readBufPos].idup;
                    readBufPos = 0;
                    _partialSince = MonoTime.zero;
                    return s;
                }
            }
            return null;
        }
        /// time to wait for the rest of a sequence sent by the terminal: its bytes arrive within it (#1041)
        enum SEQUENCE_TIMEOUT = dur!"msecs"(50);
        import core.time : MonoTime, dur;
        private MonoTime _partialSince;
        bool rawWrite(string s) {
            import core.sys.posix.unistd;
            import core.stdc.errno;
            int res = cast(int)write(STDOUT_FILENO, s.ptr, s.length);
            if (res < 0) {
                auto err = errno;
                while (err == EAGAIN) {
                    //debug Log.d("rawWrite error EAGAIN - will retry");
                    res = cast(int)write(STDOUT_FILENO, s.ptr, s.length);
                    if (res >= 0)
                        return (res > 0);
                    err = errno;
                }
                Log.e("rawWrite error ", err, " - stopping terminal");
                _stopped = true;
            }
            return (res > 0);
        }
    }

    version (Windows) {
        DWORD savedStdinMode;
        DWORD savedStdoutMode;
    } else {
        import core.sys.posix.termios;
        import core.sys.posix.fcntl;
        import core.sys.posix.sys.ioctl;
        termios savedStdinState;
    }

    void uninit() {
        version (Windows) {
            SetConsoleMode(_hstdin, savedStdinMode);
            SetConsoleMode(_hstdout, savedStdoutMode);
        } else {
            import core.sys.posix.unistd;
            tcsetattr(STDIN_FILENO, TCSANOW, &savedStdinState);
            // reset terminal state
            rawWrite("\033[?1006l\033[?1003l"); // mouse tracking off (#1041)
            rawWrite("\033c");
            // reset attributes
            rawWrite("\x1b[0m");
            // clear screen
            rawWrite("\033[2J");
            // normal cursor
            rawWrite("\x1b[?25h");
            // set auto wrapping mode
            rawWrite("\x1b[?7h");
        }
    }

    bool init() {
        version(Windows) {
            _hstdin = GetStdHandle(STD_INPUT_HANDLE);
            if (_hstdin == INVALID_HANDLE_VALUE)
                return false;
            _hstdout = GetStdHandle(STD_OUTPUT_HANDLE);
            if (_hstdout == INVALID_HANDLE_VALUE)
                return false;
            CONSOLE_SCREEN_BUFFER_INFO csbi;
            if (!GetConsoleScreenBufferInfo(_hstdout, &csbi))
            {
                if (!AllocConsole()) {
                    return false;
                }
                _hstdin = GetStdHandle(STD_INPUT_HANDLE);
                _hstdout = GetStdHandle(STD_OUTPUT_HANDLE);
                if (!GetConsoleScreenBufferInfo(_hstdout, &csbi)) {
                    return false;
                }
                //printf( "GetConsoleScreenBufferInfo failed: %lu\n", GetLastError());
            }
            // update console modes
            immutable DWORD ENABLE_QUICK_EDIT_MODE = 0x0040;
            immutable DWORD ENABLE_VIRTUAL_TERMINAL_PROCESSING = 0x0004;
            immutable DWORD ENABLE_LVB_GRID_WORLDWIDE = 0x0010;
            DWORD mode = 0;
            GetConsoleMode(_hstdin, &mode);
            savedStdinMode = mode;
            mode = mode & ~ENABLE_ECHO_INPUT;
            mode = mode & ~ENABLE_LINE_INPUT;
            mode = mode & ~ENABLE_QUICK_EDIT_MODE;
            mode |= ENABLE_PROCESSED_INPUT;
            mode |= ENABLE_MOUSE_INPUT;
            mode |= ENABLE_WINDOW_INPUT;
            SetConsoleMode(_hstdin, mode);
            GetConsoleMode(_hstdout, &mode);
            savedStdoutMode = mode;
            mode = mode & ~ENABLE_PROCESSED_OUTPUT;
            mode = mode & ~ENABLE_WRAP_AT_EOL_OUTPUT;
            mode = mode & ~ENABLE_VIRTUAL_TERMINAL_PROCESSING;
            mode |= ENABLE_LVB_GRID_WORLDWIDE;
            SetConsoleMode(_hstdout, mode);

            _cursorX = csbi.dwCursorPosition.X;
            _cursorY = csbi.dwCursorPosition.Y;
            _width = csbi.srWindow.Right - csbi.srWindow.Left + 1; // csbi.dwSize.X;
            _height = csbi.srWindow.Bottom - csbi.srWindow.Top + 1; // csbi.dwSize.Y;
            _attr = csbi.wAttributes;
            _textColor = _attr & 0x0F;
            _backgroundColor = (_attr & 0xF0) >> 4;
            _underline = (_attr & COMMON_LVB_UNDERSCORE) != 0;
            //writeln("csbi=", csbi);
        } else {
            import core.sys.posix.unistd;
            if (!isatty(1))
                return false;
            setSignalHandlers();
            fcntl(STDIN_FILENO, F_SETFL, fcntl(STDIN_FILENO, F_GETFL) | O_NONBLOCK);
            termios ttystate;
            //get the terminal state
            tcgetattr(STDIN_FILENO, &ttystate);
            savedStdinState = ttystate;
            //turn off canonical mode
            ttystate.c_lflag &= ~ICANON;
            ttystate.c_lflag &= ~ECHO;
            // keys for the app, as in full-screen terminal apps (#1041): Ctrl+C/Z/\ (signals), Ctrl+V/O (extended
            // input processing), Ctrl+S/Q (flow control)
            ttystate.c_lflag &= ~(ISIG | IEXTEN);
            ttystate.c_iflag &= ~IXON;
            //minimum of number input read.
            ttystate.c_cc[VMIN] = 1;
            //set the terminal attributes.
            tcsetattr(STDIN_FILENO, TCSANOW, &ttystate);

            winsize w;
            ioctl(0, TIOCGWINSZ, &w);
            _width = w.ws_col;
            _height = w.ws_row;

            _cursorX = 0;
            _cursorY = 0;

            _textColor = 7;
            _backgroundColor = 0;
            _underline = false;
            // enable mouse tracking - all events, reported in the SGR format (#1041: no limit at column 223;
            // terminals without it use the X10 format)
            rawWrite("\033[?1003h\033[?1006h");
            //rawWrite("\x1b[c");
            //string termType = rawRead();
            //Log.d("Term type=", termType);
        }
        _buf.resize(_width, _height);
        _batchBuf.resize(_width, _height);
        return true;
    }

    void resize(int width, int height) {
        if (_width != width || _height != height) {
            _buf.resize(width, height);
            _batchBuf.resize(width, height);
            _width = width;
            _height = height;
            clearScreen(); //??
        }
    }

    /// clear screen and set cursor position to 0,0
    void clearScreen() {
        calcAttributes();
        if (!_batchMode) {
            _buf.clear(ConsoleChar(' ', _consoleAttr));
            version(Windows) {
                DWORD charsWritten;
                FillConsoleOutputCharacter(_hstdout, ' ', _width * _height, COORD(0, 0), &charsWritten);
                FillConsoleOutputAttribute(_hstdout, _attr, _width * _height, COORD(0, 0), &charsWritten);
            } else {
                rawWrite("\033[2J");
            }
        } else {
            _batchBuf.clear(ConsoleChar(' ', _consoleAttr));
        }
        setCursor(0, 0);
    }


    /// set cursor position
    void setCursor(int x, int y) {
        if (!_batchMode) {
            _buf.setCursor(x, y);
            rawSetCursor(x, y);
            _cursorX = x;
            _cursorY = y;
        } else {
            _batchBuf.setCursor(x, y);
        }
    }

    /// flush batched updates
    void flush() {
        if (_batchMode) {
            bool drawn = false;
            for (int i = 0; i < _batchBuf.height; i++) {
                ConsoleChar[] batchLine = _batchBuf.line(i);
                ConsoleChar[] bufLine = _buf.line(i);
                for (int x = 0; x < _batchBuf.width; x++) {
                    if (batchLine[x] != ConsoleChar.init && batchLine[x] != bufLine[x]) {
                        // found non-empty sequence
                        int xx = 1;
                        dchar[] str;
                        str ~= batchLine[x].ch;
                        bufLine[x] = batchLine[x];
                        uint firstAttr = batchLine[x].attr;
                        for ( ; x + xx < _batchBuf.width; xx++) {
                            if (batchLine[x + xx] == ConsoleChar.init || batchLine[x + xx].attr != firstAttr)
                                break;
                            str ~= batchLine[x + xx].ch;
                            bufLine[x + xx].set(batchLine[x + xx]);
                        }
                        rawWriteTextAt(x, i, firstAttr, cast(dstring)str);
                        x += xx - 1;
                        drawn = true;
                    }
                }
            }
            if (drawn || _cursorX != _batchBuf.cursorX || _cursorY != _batchBuf.cursorY) {
                _cursorX = _batchBuf.cursorX;
                _cursorY = _batchBuf.cursorY;
                rawSetCursor(_cursorX, _cursorY);
                rawSetCursorType(_cursorType);
            }
            _batchBuf.clear(ConsoleChar.init);
        }
    }

    /// write text string
    void writeText(dstring str) {
        if (!str.length)
            return;
        updateAttributes();
        if (!_batchMode) {
            // no batch mode, write directly to screen
            _buf.write(str, _consoleAttr);
            rawWriteText(str);
            _cursorX = _buf.cursorX;
            _cursorY = _buf.cursorY;
        } else {
            // batch mode
            _batchBuf.write(str, _consoleAttr);
            _cursorX = _batchBuf.cursorX;
            _cursorY = _batchBuf.cursorY;
        }
    }

    protected void rawSetCursor(int x, int y) {
        version(Windows) {
            SetConsoleCursorPosition(_hstdout, COORD(cast(short)x, cast(short)y));
        } else {
            import core.stdc.stdio;
            import core.stdc.string;
            char[50] buf;
            sprintf(buf.ptr, "\x1b[%d;%dH", y + 1, x + 1);
            rawWrite(cast(string)(buf[0 .. strlen(buf.ptr)]));
        }
    }


    private dstring _windowCaption;
    void setWindowCaption(dstring str) {
        if (_windowCaption == str)
            return;
        _windowCaption = str;
        version(Windows) {
            import std.utf;
            SetConsoleTitle(toUTF16z(str));
        } else {
            // TODO: ANSI terminal caption
        }
    }

    private ConsoleCursorType _rawCursorType = ConsoleCursorType.Insert;
    protected void rawSetCursorType(ConsoleCursorType type) {
        if (_rawCursorType == type)
            return;
        version(Windows) {
            CONSOLE_CURSOR_INFO ci;
            switch(type) {
                default:
                case ConsoleCursorType.Insert:
                    ci.dwSize = 10;
                    ci.bVisible = TRUE;
                    break;
                case ConsoleCursorType.Replace:
                    ci.dwSize = 100;
                    ci.bVisible = TRUE;
                    break;
                case ConsoleCursorType.Invisible:
                    ci.dwSize = 10;
                    ci.bVisible = FALSE;
                    break;
            }
            SetConsoleCursorInfo(_hstdout, &ci);
        } else {
            switch(type) {
                default:
                case ConsoleCursorType.Insert:
                    rawWrite("\x1b[?25h");
                    break;
                case ConsoleCursorType.Replace:
                    rawWrite("\x1b[?25h");
                    break;
                case ConsoleCursorType.Invisible:
                    rawWrite("\x1b[?25l");
                    break;
            }
        }
        _rawCursorType = type;
    }

    private ConsoleCursorType _cursorType = ConsoleCursorType.Insert;
    void setCursorType(ConsoleCursorType type) {
        _cursorType = type;
        if (!_batchMode)
            rawSetCursorType(_cursorType);
    }

    protected void rawWriteTextAt(int x, int y, uint attr, dstring str) {
        if (!str.length)
            return;
        version (Windows) {
            CHAR_INFO[1000] lineBuf;
            WORD newattr = cast(WORD) (
                                       (attr & 0x0F)
                                       | (((attr >> 8) & 0x0F) << 4)
                                       | (((attr >> 16) & 1) ? COMMON_LVB_UNDERSCORE : 0)
                                       );
            for (int i = 0; i < str.length; i++) {
                lineBuf[i].UnicodeChar = cast(WCHAR)str[i];
                lineBuf[i].Attributes = newattr;
            }
            COORD bufSize;
            COORD bufCoord;
            bufSize.X = cast(short)str.length;
            bufSize.Y = 1;
            bufCoord.X = 0;
            bufCoord.Y = 0;
            SMALL_RECT region;
            region.Left = cast(short)x;
            region.Right = cast(short)(x + cast(int)str.length);
            region.Top = cast(short)y;
            region.Bottom = cast(short)y;
            WriteConsoleOutput(_hstdout, lineBuf.ptr, bufSize, bufCoord, &region);
        } else {
            rawSetCursor(x, y);
            rawSetAttributes(attr);
            rawWriteText(cast(dstring)str);
        }
    }

    protected void rawWriteText(dstring str) {
        version(Windows) {
            import std.utf;
            wstring s16 = toUTF16(str);
            DWORD charsWritten;
            WriteConsole(_hstdout, cast(const(void)*)s16.ptr, cast(uint)s16.length, &charsWritten, cast(void*)null);
        } else {
            import std.utf;
            string s8 = toUTF8(str);
            rawWrite(s8);
        }
    }

    version (Windows) {
    } else {
        private int lastTextColor = -1;
        private int lastBackgroundColor = -1;
    }
    protected void rawSetAttributes(uint attr) {
        version(Windows) {
            WORD newattr = cast(WORD) (
                (attr & 0x0F)
                | (((attr >> 8) & 0x0F) << 4)
                | (((attr >> 16) & 1) ? COMMON_LVB_UNDERSCORE : 0)
                );
            if (newattr != _attr) {
                _attr = newattr;
                SetConsoleTextAttribute(_hstdout, _attr);
            }
        } else {
            int textCol = (attr & 0x0F);
            int bgCol = ((attr >> 8) & 0x0F);
            textCol = (textCol & 7) + (textCol & 8 ? 90 : 30);
            bgCol = (bgCol & 7) + (bgCol & 8 ? 100 : 40);
            if (textCol == lastTextColor && bgCol == lastBackgroundColor)
                return;
            import core.stdc.stdio;
            import core.stdc.string;
            char[50] buf;
            if (textCol != lastTextColor && bgCol != lastBackgroundColor)
                sprintf(buf.ptr, "\x1b[%d;%dm", textCol, bgCol);
            else if (textCol != lastTextColor && bgCol == lastBackgroundColor)
                sprintf(buf.ptr, "\x1b[%dm", textCol);
            else
                sprintf(buf.ptr, "\x1b[%dm", bgCol);
            lastBackgroundColor = bgCol;
            lastTextColor = textCol;
            rawWrite(cast(string)buf[0 .. strlen(buf.ptr)]);
        }
    }

    protected void checkResize() {
        version(Windows) {
            CONSOLE_SCREEN_BUFFER_INFO csbi;
            if (!GetConsoleScreenBufferInfo(_hstdout, &csbi))
            {
                return;
            }
            _cursorX = csbi.dwCursorPosition.X;
            _cursorY = csbi.dwCursorPosition.Y;
            int w = csbi.srWindow.Right - csbi.srWindow.Left + 1; // csbi.dwSize.X;
            int h = csbi.srWindow.Bottom - csbi.srWindow.Top + 1; // csbi.dwSize.Y;
            if (_width != w || _height != h)
                handleConsoleResize(w, h);
        } else {
            import core.sys.posix.unistd;
            //import core.sys.posix.fcntl;
            //import core.sys.posix.termios;
            import core.sys.posix.sys.ioctl;
            winsize w;
            ioctl(STDIN_FILENO, TIOCGWINSZ, &w);
            if (_width != w.ws_col || _height != w.ws_row) {
                handleConsoleResize(w.ws_col, w.ws_row);
            }
        }
    }

    protected void calcAttributes() {
        _consoleAttr = cast(uint)_textColor | (cast(uint)_backgroundColor << 8) | (_underline ? 0x10000 : 0);
        version(Windows) {
            _attr = cast(WORD) (
                _textColor
                | (_backgroundColor << 4)
                | (_underline ? COMMON_LVB_UNDERSCORE : 0)
                );
        } else {
        }
    }

    protected void updateAttributes() {
        if (_dirtyAttributes) {
            calcAttributes();
            if (!_batchMode) {
                version(Windows) {
                    SetConsoleTextAttribute(_hstdout, _attr);
                } else {
                    rawSetAttributes(_consoleAttr);
                }
            }
            _dirtyAttributes = false;
        }
    }

    protected bool _batchMode;
    @property bool batchMode() { return _batchMode; }
    @property void batchMode(bool batch) {
        if (_batchMode == batch)
            return;
        if (batch) {
            // batch mode turned ON
            _batchBuf.clear(ConsoleChar.init);
            _batchMode = true;
        } else {
            // batch mode turned OFF
            flush();
            _batchMode = false;
        }
    }

    protected bool _dirtyAttributes;
    protected ubyte _textColor;
    protected ubyte _backgroundColor;
    protected bool _underline;
    /// get underline text attribute flag
    @property bool underline() { return _underline; }
    /// set underline text attrubute flag
    @property void underline(bool flg) {
        if (flg != _underline) {
            _underline = flg;
            _dirtyAttributes = true;
        }
    }
    /// get text color
    @property ubyte textColor() { return _textColor; }
    /// set text color
    @property void textColor(ubyte color) {
        if (_textColor != color) {
            _textColor = color;
            _dirtyAttributes = true;
        }
    }
    /// get background color
    @property ubyte backgroundColor() { return _backgroundColor; }
    /// set background color
    @property void backgroundColor(ubyte color) {
        if (_backgroundColor != color) {
            _backgroundColor = color;
            _dirtyAttributes = true;
        }
    }

    /// mouse event signal
    Signal!OnMouseEvent mouseEvent;
    /// keyboard event signal
    Signal!OnKeyEvent keyEvent;
    /// console size changed signal
    Signal!OnConsoleResize resizeEvent;
    /// console input is idle
    Signal!OnInputIdle inputIdleEvent;

    protected bool handleKeyEvent(KeyEvent event) {
        if (keyEvent.assigned)
            return keyEvent(event);
        return false;
    }
    protected bool handleMouseEvent(MouseEvent event) {
        ButtonDetails * pbuttonDetails = null;
        if (event.button == MouseButton.Left)
            pbuttonDetails = &_lbutton;
        else if (event.button == MouseButton.Right)
            pbuttonDetails = &_rbutton;
        else if (event.button == MouseButton.Middle)
            pbuttonDetails = &_mbutton;
        if (pbuttonDetails) {
            if (event.action == MouseAction.ButtonDown) {
                pbuttonDetails.down(event.x, event.y, event.flags);
            } else if (event.action == MouseAction.ButtonUp) {
                pbuttonDetails.up(event.x, event.y, event.flags);
            }
        }
        event.lbutton = _lbutton;
        event.rbutton = _rbutton;
        event.mbutton = _mbutton;
        if (mouseEvent.assigned)
            return mouseEvent(event);
        return false;
    }
    protected bool handleConsoleResize(int width, int height) {
        resize(width, height);
        if (resizeEvent.assigned)
            return resizeEvent(width, height);
        return false;
    }
    protected bool handleInputIdle() {
        checkResize();
        if (inputIdleEvent.assigned)
            return inputIdleEvent();
        return false;
    }
    private ushort lastMouseFlags = 0;
    private MouseButton lastButtonDown = MouseButton.None;

    protected ButtonDetails _lbutton;
    protected ButtonDetails _mbutton;
    protected ButtonDetails _rbutton;

    void stop() {
        // set stopped flag
        _stopped = true;
    }

    /// wait for input, handle input
    bool pollInput() {
        if (_stopped) {
            debug Log.i("Console _stopped flag is set - returning false from pollInput");
            return false;
        }
        version(Windows) {
            INPUT_RECORD record;
            DWORD eventsRead;
            if (PeekConsoleInput(_hstdin, &record, 1, &eventsRead)) {
                if (eventsRead) {
                    if (ReadConsoleInput(_hstdin, &record, 1, &eventsRead)) {
                        switch (record.EventType) {
                            case KEY_EVENT:
                                KeyAction action = record.KeyEvent.bKeyDown ? KeyAction.KeyDown : KeyAction.KeyUp;
                                KeyCode keyCode = KeyCode.NONE;
                                ushort flags = 0;
                                uint keyState = record.KeyEvent.dwControlKeyState;
                                if (keyState & LEFT_ALT_PRESSED)
                                    flags |= KeyFlag.Alt | KeyFlag.LAlt;
                                if (keyState & RIGHT_ALT_PRESSED)
                                    flags |= KeyFlag.Alt | KeyFlag.RAlt;
                                if (keyState & LEFT_CTRL_PRESSED)
                                    flags |= KeyFlag.Control | KeyFlag.LControl;
                                if (keyState & RIGHT_CTRL_PRESSED)
                                    flags |= KeyFlag.Control | KeyFlag.RControl;
                                if (keyState & SHIFT_PRESSED)
                                    flags |= KeyFlag.Shift;
                                keyCode = cast(KeyCode)record.KeyEvent.wVirtualKeyCode;
                                dchar ch = record.KeyEvent.UnicodeChar;
                                handleKeyEvent(new KeyEvent(action, keyCode, flags));
                                if (action == KeyAction.KeyDown && ch) {
                                    handleKeyEvent(new KeyEvent(KeyAction.Text, keyCode, flags, [ch]));
                                }
                                break;
                            case MOUSE_EVENT:
                                short x = record.MouseEvent.dwMousePosition.X;
                                short y = record.MouseEvent.dwMousePosition.Y;
                                uint buttonState = record.MouseEvent.dwButtonState;
                                uint keyState = record.MouseEvent.dwControlKeyState;
                                uint eventFlags = record.MouseEvent.dwEventFlags;
                                ushort flags = 0;
                                if ((keyState & LEFT_ALT_PRESSED) || (keyState & RIGHT_ALT_PRESSED))
                                    flags |= MouseFlag.Alt;
                                if ((keyState & LEFT_CTRL_PRESSED) || (keyState & RIGHT_CTRL_PRESSED))
                                    flags |= MouseFlag.Control;
                                if (keyState & SHIFT_PRESSED)
                                    flags |= MouseFlag.Shift;
                                if (buttonState & FROM_LEFT_1ST_BUTTON_PRESSED)
                                    flags |= MouseFlag.LButton;
                                if (buttonState & FROM_LEFT_2ND_BUTTON_PRESSED)
                                    flags |= MouseFlag.MButton;
                                if (buttonState & RIGHTMOST_BUTTON_PRESSED)
                                    flags |= MouseFlag.RButton;
                                bool actionSent = false;
                                if ((flags & MouseFlag.ButtonsMask) != (lastMouseFlags & MouseFlag.ButtonsMask)) {
                                    MouseButton btn = MouseButton.None;
                                    MouseAction action = MouseAction.Cancel;
                                    if ((flags & MouseFlag.LButton) != (lastMouseFlags & MouseFlag.LButton)) {
                                        btn = MouseButton.Left;
                                        action = (flags & MouseFlag.LButton) ? MouseAction.ButtonDown : MouseAction.ButtonUp;
                                        handleMouseEvent(new MouseEvent(action, btn, flags, cast(short)x, cast(short)y));
                                    }
                                    if ((flags & MouseFlag.RButton) != (lastMouseFlags & MouseFlag.RButton)) {
                                        btn = MouseButton.Right;
                                        action = (flags & MouseFlag.RButton) ? MouseAction.ButtonDown : MouseAction.ButtonUp;
                                        handleMouseEvent(new MouseEvent(action, btn, flags, cast(short)x, cast(short)y));
                                    }
                                    if ((flags & MouseFlag.MButton) != (lastMouseFlags & MouseFlag.MButton)) {
                                        btn = MouseButton.Middle;
                                        action = (flags & MouseFlag.MButton) ? MouseAction.ButtonDown : MouseAction.ButtonUp;
                                        handleMouseEvent(new MouseEvent(action, btn, flags, cast(short)x, cast(short)y));
                                    }
                                    if (action != MouseAction.Cancel)
                                        actionSent = true;
                                }
                                if ((eventFlags & MOUSE_MOVED) && !actionSent) {
                                    handleMouseEvent(new MouseEvent(MouseAction.Move, MouseButton.None, flags, cast(short)x, cast(short)y));
                                    actionSent = true;
                                }
                                if (eventFlags & MOUSE_WHEELED) {
                                    short delta = (cast(short)(buttonState >> 16));
                                    handleMouseEvent(new MouseEvent(MouseAction.Wheel, MouseButton.None, flags, cast(short)x, cast(short)y, delta));
                                    actionSent = true;
                                }
                                lastMouseFlags = flags;
                                break;
                            case WINDOW_BUFFER_SIZE_EVENT:
                                handleConsoleResize(record.WindowBufferSizeEvent.dwSize.X, record.WindowBufferSizeEvent.dwSize.Y);
                                break;
                            default:
                                break;
                        }
                    } else {
                        return false;
                    }
                } else {
                    handleInputIdle();
                    Sleep(1);
                }
            } else {
                _stopped = true;
                return false;
            }
        } else {
            import std.algorithm;
            if (SIGHUP_flag) {
                Log.i("SIGHUP signal fired");
                _stopped = true;
            }
            import dlangui.core.logger;
            string s = rawRead(20);
            if (s is null) {
                handleInputIdle();
                return !_stopped;
            }
            ConsoleMouse m;
            if (parseConsoleMouse(s, m)) {
                // X10 reports no button for a release: the last pressed one
                if (m.action == MouseAction.ButtonDown)
                    lastButtonDown = m.button;
                else if (m.action == MouseAction.ButtonUp && m.button == MouseButton.None)
                    m.button = lastButtonDown;
                handleMouseEvent(new MouseEvent(m.action, m.button, m.flags, m.x, m.y, m.wheelDelta));
                return true;
            }
            ConsoleKey key = parseConsoleKey(s);
            int keyCode = key.keyCode;
            int keyFlags = key.flags;
            dstring text = key.text;
            if (keyCode) {
                KeyEvent keyDown = new KeyEvent(KeyAction.KeyDown, keyCode, keyFlags);
                handleKeyEvent(keyDown);
                if (text.length) {
                    KeyEvent keyText = new KeyEvent(KeyAction.Text, keyCode, keyFlags, text);
                    handleKeyEvent(keyText);
                }
                KeyEvent keyUp = new KeyEvent(KeyAction.KeyUp, keyCode, keyFlags);
                handleKeyEvent(keyUp);
            }
        }
        return !_stopped;
    }
}

import core.time : Duration;

/// the Esc timeout for an ESCDELAY environment value (milliseconds, 0..10000), 50 ms if it isn't set or valid (#1041)
Duration escTimeoutFromEnvironment(string escDelay) pure @safe {
    import core.time : msecs;
    import std.conv : to, ConvException;
    if (escDelay.length) {
        try {
            immutable int ms = escDelay.to!int;
            if (ms >= 0 && ms <= 10_000)
                return msecs(ms);
        } catch (ConvException e) {
            // not a number: the default
        }
    }
    return msecs(50);
}

@safe unittest {
    import core.time : msecs;
    assert(escTimeoutFromEnvironment(null) == msecs(50));
    assert(escTimeoutFromEnvironment("1000") == msecs(1000));
    assert(escTimeoutFromEnvironment("0") == msecs(0));
    assert(escTimeoutFromEnvironment("abc") == msecs(50));
    assert(escTimeoutFromEnvironment("99999") == msecs(50));
}

/// a key from console (terminal) input: key code (KeyCode), flags (KeyFlag), text for KeyAction.Text (#1041)
struct ConsoleKey {
    int keyCode;
    int flags;
    dstring text;
}

/**
    True when the bytes starting with ESC are a complete key sequence of a terminal (#1041):
    CSI `ESC [` params final byte (the Linux console's `ESC [ [ x` takes one more byte; X10 mouse `ESC [ M` takes
    three); SS3 `ESC O x`; ESC + a complete sequence (Alt+arrow in rxvt-like terminals: `ESC ESC [ A`); otherwise
    ESC and one character (Alt+key), which may be UTF-8. A lone ESC or ESC ESC is completed by the timeout of the
    reader (the Esc key).
*/
bool isEscSequenceComplete(const(char)[] s) pure nothrow @safe @nogc {
    if (s.length < 2)
        return false;
    immutable char c = s[1];
    if (c == 0x1B)
        return isEscSequenceComplete(s[1 .. $]);
    if (c == '[') {
        if (s.length >= 3 && s[2] == 'M')
            return s.length >= 6; // X10 mouse: ESC [ M b x y
        if (s.length >= 3 && s[2] == '[')
            return s.length >= 4; // Linux console F1..F5: ESC [ [ A..E
        foreach (ch; s[2 .. $])
            if (ch >= 0x40 && ch <= 0x7E)
                return true;
        return false;
    }
    if (c == 'O')
        return s.length >= 3;
    if (c & 0x80) { // Alt + a non-ASCII character
        immutable size_t len = (c & 0xE0) == 0xC0 ? 2 : (c & 0xF0) == 0xE0 ? 3 : (c & 0xF8) == 0xF0 ? 4 : 1;
        return s.length >= 1 + len;
    }
    return true;
}

private int consoleModifiers(int m) pure nothrow @safe @nogc {
    // xterm modifier parameter: 1 + (1 Shift, 2 Alt, 4 Control, 8 Meta)
    int flags;
    m--;
    if (m & 1) flags |= KeyFlag.Shift;
    if (m & 2) flags |= KeyFlag.Alt;
    if (m & 4) flags |= KeyFlag.Control;
    return flags;
}

/**
    Parses one complete key sequence from a terminal (as read by the console backend, mouse sequences excluded)
    into a key (#1041). keyCode is 0 for an unknown sequence. Besides the usual xterm, VT220, rxvt and Linux console
    sequences: ESC ESC is Esc; ESC 1..9 / ESC 0 are F1..F9 / F10 (a convention of text-UI apps); ESC + another key
    is that key with Alt.
*/
ConsoleKey parseConsoleKey(string s) pure @safe {
    import std.conv : to;
    import std.string : indexOf;
    import std.utf : decode, UTFException;
    ConsoleKey res;
    if (!s.length)
        return res;
    if (s[0] == 0x1B) {
        if (s.length == 1 || s == "\x1b\x1b") {
            res.keyCode = KeyCode.ESCAPE;
            return res;
        }
        if (s[1] == '[' && s.length >= 3) {
            if (s[2] == '[' && s.length == 4) { // Linux console F1..F5
                if (s[3] >= 'A' && s[3] <= 'E')
                    res.keyCode = KeyCode.F1 + (s[3] - 'A');
                return res;
            }
            immutable char letter = s[$ - 1];
            string params = s[2 .. $ - 1];
            string code = params, mods;
            ptrdiff_t semicolon = params.indexOf(';');
            if (semicolon >= 0) {
                code = params[0 .. semicolon];
                mods = params[semicolon + 1 .. $];
            }
            if (mods.length) {
                try {
                    res.flags = consoleModifiers(mods.to!int);
                } catch (Exception e) {
                    return res;
                }
            }
            if (letter == '~') {
                switch (code) {
                    case "1": case "7": res.keyCode = KeyCode.HOME; break;
                    case "4": case "8": res.keyCode = KeyCode.END; break;
                    case "2": res.keyCode = KeyCode.INS; break;
                    case "3": res.keyCode = KeyCode.DEL; break;
                    case "5": res.keyCode = KeyCode.PAGEUP; break;
                    case "6": res.keyCode = KeyCode.PAGEDOWN; break;
                    case "11": res.keyCode = KeyCode.F1; break;
                    case "12": res.keyCode = KeyCode.F2; break;
                    case "13": res.keyCode = KeyCode.F3; break;
                    case "14": res.keyCode = KeyCode.F4; break;
                    case "15": res.keyCode = KeyCode.F5; break;
                    case "17": res.keyCode = KeyCode.F6; break;
                    case "18": res.keyCode = KeyCode.F7; break;
                    case "19": res.keyCode = KeyCode.F8; break;
                    case "20": res.keyCode = KeyCode.F9; break;
                    case "21": res.keyCode = KeyCode.F10; break;
                    case "23": res.keyCode = KeyCode.F11; break;
                    case "24": res.keyCode = KeyCode.F12; break;
                    default: break;
                }
                return res;
            }
            if (letter == 'Z') { // Shift+Tab
                res.keyCode = KeyCode.TAB;
                res.flags |= KeyFlag.Shift;
                return res;
            }
            res.keyCode = csiSs3Key(letter);
            if (!res.keyCode)
                res.flags = 0;
            return res;
        }
        if (s[1] == 'O' && s.length == 3) { // SS3: application mode arrows, F1..F4
            res.keyCode = csiSs3Key(s[2]);
            return res;
        }
        // ESC + key: ESC 1..9, ESC 0 are F1..F9, F10; otherwise the key with Alt (no text)
        string rest = s[1 .. $];
        if (rest.length == 1 && rest[0] >= '1' && rest[0] <= '9') {
            res.keyCode = KeyCode.F1 + (rest[0] - '1');
            return res;
        }
        if (rest == "0") {
            res.keyCode = KeyCode.F10;
            return res;
        }
        res = parseConsoleKey(rest);
        if (res.keyCode && res.keyCode != KeyCode.ESCAPE) {
            res.flags |= KeyFlag.Alt;
            res.text = null;
        }
        return res;
    }
    dchar ch;
    try {
        size_t index = 0;
        ch = decode(s, index);
    } catch (UTFException e) {
        return res; // invalid UTF-8
    }
    switch (ch) {
        case '\n': case '\r': res.keyCode = KeyCode.RETURN; return res;
        case '\t': res.keyCode = KeyCode.TAB; return res;
        case 0x7F: case 0x08: res.keyCode = KeyCode.BACK; return res;
        case 0: res.keyCode = KeyCode.SPACE; res.flags = KeyFlag.Control; return res; // Ctrl+Space
        case ' ': res.keyCode = KeyCode.SPACE; res.text = " "; return res;
        default: break;
    }
    if (ch >= 1 && ch <= 26) { // Ctrl+A..Z (the ones above are Backspace, Tab and Enter)
        res.keyCode = KeyCode.KEY_A + (ch - 1);
        res.flags = KeyFlag.Control;
        return res;
    }
    if (ch < ' ')
        return res;
    res.text = [ch];
    if (ch >= 'a' && ch <= 'z') {
        res.keyCode = KeyCode.KEY_A + (ch - 'a');
    } else if (ch >= 'A' && ch <= 'Z') {
        res.keyCode = KeyCode.KEY_A + (ch - 'A');
        res.flags = KeyFlag.Shift;
    } else if (ch >= '0' && ch <= '9') {
        res.keyCode = KeyCode.KEY_0 + (ch - '0');
    } else {
        res.keyCode = 0x400000 | ch;
    }
    return res;
}

/// a mouse event from terminal input (#1041)
struct ConsoleMouse {
    MouseAction action = MouseAction.Cancel;
    MouseButton button = MouseButton.None;
    ushort flags;
    short x, y; // 0-based cell
    short wheelDelta; // 1 up, -1 down
}

/**
    Decodes the button value of an X10 or SGR mouse report (#1041): low 2 bits the button (0 left, 1 middle,
    2 right, 3 release in X10), +4 Shift, +8 Alt, +16 Control, +32 motion, +64 wheel (64 up, 65 down).
    x1, y1 are 1-based; release is the SGR release report (final 'm'), which names the button.
*/
ConsoleMouse decodeConsoleMouse(int b, int x1, int y1, bool release) pure nothrow @safe @nogc {
    ConsoleMouse m;
    m.x = cast(short)(x1 - 1);
    m.y = cast(short)(y1 - 1);
    if (b & 4)
        m.flags |= MouseFlag.Shift;
    if (b & 8)
        m.flags |= MouseFlag.Alt;
    if (b & 16)
        m.flags |= MouseFlag.Control;
    immutable int btn = b & 3;
    if (b & 64) { // wheel: it isn't a button press
        m.action = MouseAction.Wheel;
        m.wheelDelta = (btn & 1) ? -1 : 1;
        return m;
    }
    switch (btn) {
        case 0: m.button = MouseButton.Left; break;
        case 1: m.button = MouseButton.Middle; break;
        case 2: m.button = MouseButton.Right; break;
        default: break; // 3: X10 release, or motion without a button
    }
    if (b & 32) {
        m.action = MouseAction.Move;
    } else if (release || btn == 3) {
        m.action = MouseAction.ButtonUp;
    } else {
        m.action = MouseAction.ButtonDown;
    }
    // flags: the buttons held during the event
    if (m.action != MouseAction.ButtonUp) {
        if (m.button == MouseButton.Left)
            m.flags |= MouseFlag.LButton;
        else if (m.button == MouseButton.Middle)
            m.flags |= MouseFlag.MButton;
        else if (m.button == MouseButton.Right)
            m.flags |= MouseFlag.RButton;
    }
    return m;
}

/**
    Parses a mouse report: SGR `ESC [ < b ; x ; y M` (press, motion, wheel) or `... m` (release), or X10
    `ESC [ M b x y` (bytes offset by 32). Returns false when s isn't a mouse report.
*/
bool parseConsoleMouse(string s, out ConsoleMouse m) pure @safe {
    import std.algorithm : splitter;
    import std.array : array;
    import std.conv : to, ConvException;
    if (s.length == 6 && s[0] == 0x1B && s[1] == '[' && s[2] == 'M') {
        m = decodeConsoleMouse(s[3] - 32, s[4] - 32, s[5] - 32, false);
        return true;
    }
    if (s.length >= 9 && s[0 .. 3] == "\x1b[<" && (s[$ - 1] == 'M' || s[$ - 1] == 'm')) {
        string[] parts = s[3 .. $ - 1].splitter(';').array;
        if (parts.length != 3)
            return false;
        try {
            m = decodeConsoleMouse(parts[0].to!int, parts[1].to!int, parts[2].to!int, s[$ - 1] == 'm');
        } catch (ConvException e) {
            return false;
        }
        return true;
    }
    return false;
}

// mouse reports (#1041)
@safe unittest {
    ConsoleMouse m;
    // SGR: press, release, beyond column 223, motion with a button, wheel, modifiers
    assert(parseConsoleMouse("\x1b[<0;10;5M", m) && m.action == MouseAction.ButtonDown && m.button == MouseButton.Left
        && m.x == 9 && m.y == 4 && m.flags == MouseFlag.LButton);
    assert(parseConsoleMouse("\x1b[<0;10;5m", m) && m.action == MouseAction.ButtonUp && m.button == MouseButton.Left
        && m.flags == 0);
    assert(parseConsoleMouse("\x1b[<2;300;60M", m) && m.button == MouseButton.Right && m.x == 299 && m.y == 59);
    assert(parseConsoleMouse("\x1b[<32;11;5M", m) && m.action == MouseAction.Move && (m.flags & MouseFlag.LButton));
    assert(parseConsoleMouse("\x1b[<35;11;5M", m) && m.action == MouseAction.Move && m.button == MouseButton.None);
    assert(parseConsoleMouse("\x1b[<64;1;1M", m) && m.action == MouseAction.Wheel && m.wheelDelta == 1);
    assert(parseConsoleMouse("\x1b[<65;1;1M", m) && m.action == MouseAction.Wheel && m.wheelDelta == -1);
    assert(parseConsoleMouse("\x1b[<16;1;1M", m) && (m.flags & MouseFlag.Control) && m.button == MouseButton.Left);
    // X10: press, release (no button), wheel (was a button press)
    assert(parseConsoleMouse("\x1b[M *%", m) && m.action == MouseAction.ButtonDown && m.x == 9 && m.y == 4);
    assert(parseConsoleMouse("\x1b[M#*%", m) && m.action == MouseAction.ButtonUp && m.button == MouseButton.None);
    assert(parseConsoleMouse("\x1b[M`!!", m) && m.action == MouseAction.Wheel && m.wheelDelta == 1);
    // not mouse reports
    assert(!parseConsoleMouse("\x1b[A", m));
    assert(!parseConsoleMouse("\x1b[<0;10M", m));
    assert(!parseConsoleMouse("\x1b[<a;1;1M", m));
    // complete sequences
    assert(!isEscSequenceComplete("\x1b[<0;10;5"));
    assert(isEscSequenceComplete("\x1b[<0;10;5M"));
    assert(isEscSequenceComplete("\x1b[<0;10;5m"));
}

/// key of a CSI / SS3 sequence ending with this letter: arrows, Home, End, F1..F4
private int csiSs3Key(char letter) pure nothrow @safe @nogc {
    switch (letter) {
        case 'A': return KeyCode.UP;
        case 'B': return KeyCode.DOWN;
        case 'C': return KeyCode.RIGHT;
        case 'D': return KeyCode.LEFT;
        case 'H': return KeyCode.HOME;
        case 'F': return KeyCode.END;
        case 'P': return KeyCode.F1;
        case 'Q': return KeyCode.F2;
        case 'R': return KeyCode.F3;
        case 'S': return KeyCode.F4;
        default: return 0;
    }
}

// console key sequences (#1041)
@safe unittest {
    static void check(string s, int keyCode, int flags = 0, dstring text = null) {
        ConsoleKey k = parseConsoleKey(s);
        assert(k.keyCode == keyCode && k.flags == flags && k.text == text, s);
    }
    // basic keys: Enter and Tab were Ctrl+J / Ctrl+I, Backspace and Esc did nothing
    check("\n", KeyCode.RETURN);
    check("\r", KeyCode.RETURN);
    check("\t", KeyCode.TAB);
    check("\x7f", KeyCode.BACK);
    check("\x08", KeyCode.BACK);
    check("\x1b", KeyCode.ESCAPE);
    check("\x1b\x1b", KeyCode.ESCAPE);
    check(" ", KeyCode.SPACE, 0, " ");
    check("\x00", KeyCode.SPACE, KeyFlag.Control);
    // characters, Ctrl+letters
    check("a", KeyCode.KEY_A, 0, "a");
    check("Q", KeyCode.KEY_Q, KeyFlag.Shift, "Q");
    check("7", KeyCode.KEY_7, 0, "7");
    check("\x13", KeyCode.KEY_S, KeyFlag.Control); // Ctrl+S
    check("\x03", KeyCode.KEY_C, KeyFlag.Control); // Ctrl+C
    check("ж", 0x400000 | 'ж', 0, "ж");
    // Alt+key, ESC + digit = F-key
    check("\x1bf", KeyCode.KEY_F, KeyFlag.Alt);
    check("\x1bX", KeyCode.KEY_X, KeyFlag.Shift | KeyFlag.Alt);
    check("\x1b1", KeyCode.F1);
    check("\x1b9", KeyCode.F9);
    check("\x1b0", KeyCode.F10);
    check("\x1b\x7f", KeyCode.BACK, KeyFlag.Alt);
    // rxvt-like terminals: Alt + a sequence is ESC + the sequence
    check("\x1b\x1b[A", KeyCode.UP, KeyFlag.Alt);
    check("\x1b\x1bOP", KeyCode.F1, KeyFlag.Alt);
    check("\x1b\x1b[1;5D", KeyCode.LEFT, KeyFlag.Control | KeyFlag.Alt);
    // CSI and SS3 sequences
    check("\x1b[A", KeyCode.UP);
    check("\x1b[1;5D", KeyCode.LEFT, KeyFlag.Control);
    check("\x1b[1;2C", KeyCode.RIGHT, KeyFlag.Shift);
    check("\x1bOA", KeyCode.UP);
    check("\x1b[H", KeyCode.HOME);
    check("\x1b[1~", KeyCode.HOME);
    check("\x1b[7~", KeyCode.HOME);
    check("\x1b[4~", KeyCode.END);
    check("\x1b[8~", KeyCode.END);
    check("\x1bOF", KeyCode.END);
    check("\x1b[Z", KeyCode.TAB, KeyFlag.Shift);
    check("\x1bOP", KeyCode.F1);
    check("\x1b[11~", KeyCode.F1);
    check("\x1b[[A", KeyCode.F1);
    check("\x1b[[E", KeyCode.F5);
    check("\x1b[1;5P", KeyCode.F1, KeyFlag.Control);
    check("\x1b[15~", KeyCode.F5);
    check("\x1b[24;2~", KeyCode.F12, KeyFlag.Shift);
    check("\x1b[5~", KeyCode.PAGEUP);
    // Ctrl+Ins / Shift+Ins / Shift+Del: Copy / Paste / Cut in the editors
    check("\x1b[2;5~", KeyCode.INS, KeyFlag.Control);
    check("\x1b[2;2~", KeyCode.INS, KeyFlag.Shift);
    check("\x1b[3;2~", KeyCode.DEL, KeyFlag.Shift);
    // unknown
    check("\x1b[99~", 0);
    check("\x1b[1;xA", 0);
}

// complete sequences (#1041)
@safe unittest {
    assert(!isEscSequenceComplete("\x1b"));
    assert(!isEscSequenceComplete("\x1b\x1b")); // Esc after the timeout, or the start of ESC ESC [ A
    assert(!isEscSequenceComplete("\x1b\x1b["));
    assert(isEscSequenceComplete("\x1b\x1b[A"));
    assert(isEscSequenceComplete("\x1b\x1bOP"));
    assert(isEscSequenceComplete("\x1bf"));
    assert(isEscSequenceComplete("\x1b1"));
    assert(!isEscSequenceComplete("\x1b["));
    assert(!isEscSequenceComplete("\x1b[1;5"));
    assert(isEscSequenceComplete("\x1b[1;5D"));
    assert(isEscSequenceComplete("\x1b[2~"));
    assert(!isEscSequenceComplete("\x1b[["));
    assert(isEscSequenceComplete("\x1b[[A"));
    assert(!isEscSequenceComplete("\x1bO"));
    assert(isEscSequenceComplete("\x1bOP"));
    assert(!isEscSequenceComplete("\x1b[M !"));
    assert(isEscSequenceComplete("\x1b[M !!"));
    assert(!isEscSequenceComplete("\x1b\xd0"));
    assert(isEscSequenceComplete("\x1b\xd0\xb6"));
}

/// interface - slot for onMouse
interface OnMouseEvent {
    bool onMouse(MouseEvent event);
}

/// interface - slot for onKey
interface OnKeyEvent {
    bool onKey(KeyEvent event);
}

interface OnConsoleResize {
    bool onResize(int width, int height);
}

interface OnInputIdle {
    bool onInputIdle();
}
