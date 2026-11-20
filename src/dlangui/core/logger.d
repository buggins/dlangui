// Written in the D programming language.

/**
This module provides logging utilities.

Use Log class static methods.

Synopsis:

----
import dlangui.core.logger;

// setup:

// use stderror for logging
setStderrLogger();
// set log level
setLogLevel(LogLevel.Debug);

// usage:

// log debug message
Log.d("mouse clicked at ", x, ",", y);
// or with format string:
Log.fd("mouse clicked at %d,%d", x, y);
// log error message
Log.e("exception while reading file", e);
----


For Android, set log tag instead of setXXXLogger:

----
Log.setLogTag("myApp");
----

Copyright: Vadim Lopatin, 2014
License:   Boost License 1.0
Authors:   Vadim Lopatin, coolreader.org@gmail.com
*/
module dlangui.core.logger;

import std.stdio;
import std.datetime : SysTime, Clock;
import core.sync.mutex;

version (Android) {
    import android.log;
}

/// Log levels
enum LogLevel : int {
    /// Fatal error, cannot resume
    Fatal,
    /// Error
    Error,
    /// Warning
    Warn,
    /// Informational message
    Info,
    /// Debug message
    Debug,
    /// Tracing message
    Trace
}

/// Returns timestamp in milliseconds since 1970 UTC similar to Java System.currentTimeMillis()
@property long currentTimeMillis() {
    static import std.datetime;
    return std.datetime.Clock.currStdTime / 10000;
}

/**

    Logging utilities

Setup example:
----
// use stderror for logging
setStderrLogger();
// set log level
setLogLevel(LogLeve.Debug);
----

Logging example:
----
// log debug message
Log.d("mouse clicked at ", x, ",", y);
// log error message
Log.e("exception while reading file", e);
----

*/

private auto std_io_err_helper(alias v)()
{
    static if (__VERSION__ < 2075)
        return &v;
    else
        return &v();
}

class Log {
    static __gshared private LogLevel logLevel = LogLevel.Info;
    static __gshared private std.stdio.File * logFile = null;
    static __gshared private Mutex _mutex = null;

    static public @property Mutex mutex() @trusted {
        if (_mutex is null)
            _mutex = new Mutex();
        return _mutex;
    }

    /// Redirects output to stdout
    static public void setStdoutLogger() {
        synchronized(mutex) {
            logFile = std_io_err_helper!stdout;
        }
    }

    /// Redirects output to stderr
    static public void setStderrLogger() {
        synchronized(mutex) {
            logFile = std_io_err_helper!stderr;
        }
    }

    /// Redirects output to file
    static public void setFileLogger(File * file) {
        synchronized(mutex) {
            if (logFile !is null && *logFile != stdout && *logFile != stderr) {
                logFile.close();
                destroy(logFile);
                logFile = null;
            }
            logFile = file;
            if (logFile !is null)
                logFile.writeln("DlangUI log file");
        }
    }

    /// Sets log level (one of LogLevel)
    static public void setLogLevel(LogLevel level) {
        synchronized(mutex) {
            logLevel = level;
            i("Log level changed to ", level);
        }
    }

    /// returns true if messages for level are enabled
    static public bool isLogLevelEnabled(LogLevel level) @trusted nothrow @nogc {
        return logLevel >= level;
    }

    /// returns true if debug log level is enabled
    @property static public bool debugEnabled() @trusted nothrow @nogc {
        return logLevel >= LogLevel.Debug;
    }

    /// returns true if trace log level is enabled
    @property static public bool traceEnabled() @trusted nothrow @nogc {
        return logLevel >= LogLevel.Trace;
    }

    /// returns true if warn log level is enabled
    @property static public bool warnEnabled() @trusted nothrow @nogc {
        return logLevel >= LogLevel.Warn;
    }

    /// Log level to name helper function
    static public string logLevelName(LogLevel level) @safe pure nothrow @nogc {
        switch (level) with(LogLevel)
        {
            case Fatal: return "F";
            case Error: return "E";
            case Warn: return "W";
            case Info: return "I";
            case Debug: return "D";
            case Trace: return "V";
            default: return "?";
        }
    }
    version (Android) {
        static android_LogPriority toAndroidLogPriority(LogLevel level) {
            switch (level) with (LogLevel) {
                /// Fatal error, cannot resume
                case Fatal:
                    return android_LogPriority.ANDROID_LOG_FATAL;
                /// Error
                case Error:
                    return android_LogPriority.ANDROID_LOG_ERROR;
                /// Warning
                case Warn:
                    return android_LogPriority.ANDROID_LOG_WARN;
                /// Informational message
                case Info:
                    return android_LogPriority.ANDROID_LOG_INFO;
                /// Debug message
                case Debug:
                    return android_LogPriority.ANDROID_LOG_DEBUG;
                /// Tracing message
                case Trace:
                default:
                    return android_LogPriority.ANDROID_LOG_VERBOSE;
            }
        }
    }
    /// Log message with arbitrary log level
    static public void log(S...)(LogLevel level, S args) {
        import std.conv : text;
        if (isLogLevelEnabled(level) && !skippedInGCFinalizer())
            // the arguments are formatted here, so the attributes of log() follow their types (#931)
            writeMessage(level, text(args));
    }

    /// Log message with arbitrary log level with format string
    static public void logf(S...)(LogLevel level, string fmt, S args) {
        import std.format : format;
        if (isLogLevelEnabled(level) && !skippedInGCFinalizer())
            writeMessage(level, format(fmt, args));
    }

    /// in a destructor run by the GC, formatting a message would allocate and throw: the message is replaced
    /// by a fixed one, at most MAX_GC_FINALIZER_REPORTS times (#975)
    static private bool skippedInGCFinalizer() nothrow @safe {
        if (!inGCFinalizer())
            return false;
        reportLimitedLogCall("Log call in a destructor run by the GC skipped (destroy the object "
            ~ "explicitly)", null, null);
        return true;
    }

    /// writes a formatted message: the only part that accesses the log output. @trusted: the log state is
    /// __gshared, guarded by the mutex; the message is a string
    static private void writeMessage(LogLevel level, string message) @trusted {
        synchronized(mutex) {
            version (Android) {
                import std.string : toStringz;
                __android_log_write(toAndroidLogPriority(level), ANDROID_LOG_TAG, message.toStringz);
            } else {
                if (logFile !is null && logFile.isOpen) {
                    SysTime ts = Clock.currTime();
                    logFile.writef("%04d-%02d-%02d %02d:%02d:%02d.%03d %s  ", ts.year, ts.month, ts.day, ts.hour, ts.minute, ts.second, ts.fracSecs.split!("msecs").msecs, logLevelName(level));
                    logFile.writeln(message);
                    logFile.flush();
                }
            }
        }
    }

    /**
        Writes an error message given as a few strings without allocating GC memory, for destructors run by the
        garbage collector: allocating there throws InvalidMemoryOperationError, and the app can hang at exit
        (#970). The line has no timestamp.

        Doesn't wait for the log mutex: while the GC runs finalizers, another thread can be suspended holding it.
        The line is written without the lock then (also when nothing was logged yet and there is no mutex).
    */
    static public void errorNoGC(scope const(char)[][] parts...) @trusted nothrow {
        if (!isLogLevelEnabled(LogLevel.Error))
            return;
        immutable bool locked = _mutex !is null && _mutex.tryLock_nothrow();
        scope(exit) if (locked) _mutex.unlock_nothrow();
        version (Android) {
            // NUL-terminated copy, cut at a character boundary
            char[512] buf = void;
            size_t len = 0;
            outer: foreach (part; parts) {
                foreach (ch; part) {
                    if (len + 4 >= buf.length && (ch & 0xC0) != 0x80)
                        break outer; // no room for another whole UTF-8 sequence
                    buf[len++] = ch ? ch : ' ';
                }
            }
            buf[len] = 0;
            __android_log_write(android_LogPriority.ANDROID_LOG_ERROR, ANDROID_LOG_TAG, buf.ptr);
        } else {
            import core.stdc.stdio : fflush, fwrite;
            if (logFile is null || !logFile.isOpen)
                return;
            try {
                auto fp = logFile.getFP();
                fwrite("E  ".ptr, 1, 3, fp);
                foreach (part; parts)
                    fwrite(part.ptr, 1, part.length, fp);
                fwrite("\n".ptr, 1, 1, fp);
                fflush(fp);
            } catch (Exception e) {
                // not open: nothing to write to
            }
        }
    }

    /// Log verbose / trace message
    static public void v(S...)(S args) {
        if (isLogLevelEnabled(LogLevel.Trace))
            log(LogLevel.Trace, args);
    }
    /// Log verbose / trace message with format string
    static public void fv(S...)(S args) {
        if (isLogLevelEnabled(LogLevel.Trace))
            logf(LogLevel.Trace, args);
    }
    /// Log debug message
    static public void d(S...)(S args) {
        if (isLogLevelEnabled(LogLevel.Debug))
            log(LogLevel.Debug, args);
    }
    /// Log debug message with format string
    static public void fd(S...)(S args) {
        if (isLogLevelEnabled(LogLevel.Debug))
            logf(LogLevel.Debug, args);
    }
    /// Log info message
    static public void i(S...)(S args) {
        if (isLogLevelEnabled(LogLevel.Info))
            log(LogLevel.Info, args);
    }
    /// Log info message
    static public void fi(S...)(S args) {
        if (isLogLevelEnabled(LogLevel.Info))
            logf(LogLevel.Info, args);
    }
    /// Log warn message
    static public void w(S...)(S args) {
        if (isLogLevelEnabled(LogLevel.Warn))
            log(LogLevel.Warn, args);
    }
    /// Log warn message
    static public void fw(S...)(S args) {
        if (isLogLevelEnabled(LogLevel.Warn))
            logf(LogLevel.Warn, args);
    }
    /// Log error message
    static public void e(S...)(S args) {
        if (isLogLevelEnabled(LogLevel.Error))
            log(LogLevel.Error, args);
    }
    /// Log error message
    static public void fe(S...)(S args) {
        if (isLogLevelEnabled(LogLevel.Error))
            logf(LogLevel.Error, args);
    }
    /// Log fatal error message
    static public void f(S...)(S args) {
        if (isLogLevelEnabled(LogLevel.Fatal))
            log(LogLevel.Fatal, args);
    }
    /// Log fatal error message
    static public void ff(S...)(S args) {
        if (isLogLevelEnabled(LogLevel.Fatal))
            logf(LogLevel.Fatal, args);
    }

    version (Android) {
        static public void setLogTag(const char * tag) {
            ANDROID_LOG_TAG = tag;
        }
    }
}

debug {
    private static __gshared bool _appShuttingDown = false;

    @property bool appShuttingDown() { return _appShuttingDown; }

    /// for debug purposes - sets shutdown flag to log widgets not destroyed in time.
    void setAppShuttingDownFlag() {
        _appShuttingDown = true;
    }
}

/// reports a resource destroyed by the GC at exit; called from destructors, so it doesn't allocate (#970)
void onResourceDestroyWhileShutdown(string resourceName, string objname = null) {
    Log.errorNoGC("Resource leak: destroying resource while shutdown! ", resourceName, " ", objname);
}

/// set to true when exiting main - to detect destructor calls for resources by GC
__gshared bool APP_IS_SHUTTING_DOWN = false;

/++
    True while the garbage collector runs a destructor (finalizer). Such a destructor must not allocate (that
    throws InvalidMemoryOperationError), log with Log.d/i/... (formatting allocates), or touch other GC objects
    (they may be finalized already: destroying children, releasing Refs, ...), and may run on any thread
    (no OpenGL or OS handles). Objects holding resources must be destroyed explicitly (#975).
+/
bool inGCFinalizer() nothrow @nogc @safe {
    import core.memory : GC;
    return GC.inFinalizer;
}

/++
    For destructors of objects holding resources (widgets, drawables, fonts, draw buffers, styles, windows, caches),
    in the class where the destructor chain ends: in a destructor run by the GC, reports the object as a leak
    (objects holding resources must be destroyed explicitly) and returns true; the destructor then must do nothing
    else. Reports are written without allocating, the first MAX_GC_FINALIZER_REPORTS ones only (#975).

    Destructors of subclasses and of other classes and structs that touch other objects check inGCFinalizer().
+/
bool destroyedByGC(string className, string id = null) nothrow @trusted { // @trusted: __gshared counters only
    if (!inGCFinalizer())
        return false;
    _resourcesDestroyedByGC++;
    reportLimited(_resourceReports, "Resource leak: destroyed by the GC, not explicitly: ", className,
        id.length ? id : null);
    return true;
}

/// count of objects holding resources destroyed by the GC (leaks) since start
@property size_t resourcesDestroyedByGC() nothrow @nogc @trusted { // @trusted: reads a __gshared counter
    return _resourcesDestroyedByGC;
}

/// at most this many leak reports from GC finalizers are written, then one more saying the rest is not (#975)
enum MAX_GC_FINALIZER_REPORTS = 20;

// @trusted access: counters only, see reportLimited()
private __gshared size_t _resourcesDestroyedByGC;
private __gshared size_t _resourceReports;
private __gshared size_t _logCallsInGCFinalizer;

version (unittest) {
    /// leak counters, saved by a test that leaks on purpose (muting the reports) and restored after it: later leaks
    /// are still counted and named (#975)
    package(dlangui) struct LeakReportCounters {
        size_t destroyed;
        size_t reports;
    }
    package(dlangui) LeakReportCounters muteLeakReports() nothrow @nogc @trusted { // __gshared counters only
        auto saved = LeakReportCounters(_resourcesDestroyedByGC, _resourceReports);
        _resourceReports = size_t.max / 2; // past the limit: nothing written
        return saved;
    }
    package(dlangui) void restoreLeakReportCounters(LeakReportCounters saved) nothrow @nogc @trusted { // same
        _resourcesDestroyedByGC = saved.destroyed;
        _resourceReports = saved.reports;
    }

    // dub test: report objects holding resources the unittests didn't destroy (#975)
    shared static ~this() {
        import core.memory : GC;
        GC.collect();
        if (_resourcesDestroyedByGC)
            stderr.writeln("Resource leak: ", _resourcesDestroyedByGC,
                " objects holding resources destroyed by the GC after the unittests");
    }
}

private void reportLimitedLogCall(string message, string name, string id) nothrow @trusted { // __gshared counter
    reportLimited(_logCallsInGCFinalizer, message, name, id);
}

// @trusted: Log.errorNoGC is @trusted, not @nogc-annotated; count is a __gshared counter
private void reportLimited(ref size_t count, string message, string name, string id) nothrow @trusted {
    // finalizers may run on several threads: an inexact count only changes how many lines are written
    immutable size_t n = ++count;
    if (n <= MAX_GC_FINALIZER_REPORTS)
        writeReport(message, name, id ? " " : null, id);
    else if (n == MAX_GC_FINALIZER_REPORTS + 1)
        writeReport(message, message.length && message[$ - 1] == ' ' ? null : " ", "(more are not reported)");
}

private void writeReport(scope const(char)[][] parts...) nothrow @trusted { // see reportLimited()
    version (unittest) {
        // dub test has no log output: the reports go to stderr, naming the objects when the GC runs during the tests
        if (Log.logFile is null) {
            import core.stdc.stdio : fflush, fwrite, stderr;
            fwrite("E  ".ptr, 1, 3, stderr);
            foreach (part; parts)
                fwrite(part.ptr, 1, part.length, stderr);
            fwrite("\n".ptr, 1, 1, stderr);
            fflush(stderr);
            return;
        }
    }
    Log.errorNoGC(parts);
}

// logging from @safe code (#931): the attributes follow the arguments
@safe unittest {
    Log.d("x = ", 1, ", y = ", 2.5, " ", "text", " ", [1, 2]);
    Log.fd("%s-%d", "a", 3);
    Log.e("error");
}

// output: timestamp, level letter, message; disabled levels are not written
unittest {
    import std.file : readText, remove, tempDir;
    import std.path : buildPath;
    import std.algorithm : canFind;
    string fn = buildPath(tempDir, "dlangui-logger-test.log");
    LogLevel oldLevel = Log.logLevel;
    File * oldFile = Log.logFile;
    Log.logFile = null;
    Log.setFileLogger(new File(fn, "w"));
    Log.setLogLevel(LogLevel.Debug);
    Log.d("value ", 42, " ", [1, 2]);
    Log.fi("%s=%d", "key", 7);
    Log.v("hidden");
    Log.setFileLogger(null); // closes the file
    Log.logFile = oldFile;
    Log.logLevel = oldLevel;
    import std.array : replace;
    string text = readText(fn).replace("\r\n", "\n"); // the file is opened in text mode: CR LF on Windows
    remove(fn);
    assert(text.canFind(" D  value 42 [1, 2]\n"));
    assert(text.canFind(" I  key=7\n"));
    assert(!text.canFind("hidden"));
}

// errorNoGC: written without GC allocations (#970)
unittest {
    import core.memory : GC;
    import std.file : readText, remove, tempDir;
    import std.path : buildPath;
    import std.algorithm : canFind;
    import std.array : replace, replicate;
    string fn = buildPath(tempDir, "dlangui-logger-nogc-test.log");
    LogLevel oldLevel = Log.logLevel;
    File * oldFile = Log.logFile;
    Log.logFile = null;
    Log.setFileLogger(new File(fn, "w"));
    Log.setLogLevel(LogLevel.Debug);
    bool restored;
    void restore() {
        if (restored)
            return;
        restored = true;
        Log.setFileLogger(null); // closes the file
        Log.logFile = oldFile;
        Log.logLevel = oldLevel;
    }
    scope(exit) restore();
    string name = "ImageCache";
    string longName = replicate("x", 600);
    immutable ulong allocated = GC.allocatedInCurrentThread;
    Log.errorNoGC("Resource leak: ", name, " ", null);
    Log.errorNoGC(longName);
    assert(GC.allocatedInCurrentThread == allocated);
    restore();
    string text = readText(fn).replace("\r\n", "\n");
    remove(fn);
    assert(text.canFind("\nE  Resource leak: ImageCache \n"));
    assert(text.canFind("\nE  " ~ longName ~ "\n"));
}
