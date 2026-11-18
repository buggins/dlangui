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
        // the arguments are formatted here, so the attributes of log() follow their types (#931)
        if (isLogLevelEnabled(level))
            writeMessage(level, text(args));
    }

    /// Log message with arbitrary log level with format string
    static public void logf(S...)(LogLevel level, string fmt, S args) {
        import std.format : format;
        if (isLogLevelEnabled(level))
            writeMessage(level, format(fmt, args));
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

void onResourceDestroyWhileShutdown(string resourceName, string objname = null) {
    Log.e("Resource leak: destroying resource while shutdown! ", resourceName, " ", objname);
}

/// set to true when exiting main - to detect destructor calls for resources by GC
__gshared bool APP_IS_SHUTTING_DOWN = false;

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
    string text = readText(fn);
    remove(fn);
    assert(text.canFind(" D  value 42 [1, 2]\n"));
    assert(text.canFind(" I  key=7\n"));
    assert(!text.canFind("hidden"));
}
