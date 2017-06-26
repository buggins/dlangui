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

    static public @property Mutex mutex() {
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
    static public bool isLogLevelEnabled(LogLevel level) {
        return logLevel >= level;
    }

    /// returns true if debug log level is enabled
    @property static public bool debugEnabled() {
        return logLevel >= LogLevel.Debug;
    }

    /// returns true if trace log level is enabled
    @property static public bool traceEnabled() {
        return logLevel >= LogLevel.Trace;
    }

    /// returns true if warn log level is enabled
    @property static public bool warnEnabled() {
        return logLevel >= LogLevel.Warn;
    }

    /// Log level to name helper function
    static public string logLevelName(LogLevel level) {
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
        if (logLevel >= level) {
            version (Android) {
                import std.format;
                import std.string : toStringz;
                import std.format;
                import std.conv : to;
                char[] msg;
                foreach(arg; args) {
                    msg ~= to!string(arg);
                }
                msg ~= cast(char)0;
                __android_log_write(toAndroidLogPriority(level), ANDROID_LOG_TAG, msg.ptr);
            } else {
                if (logFile !is null && logFile.isOpen) {
                    SysTime ts = Clock.currTime();
                    logFile.writef("%04d-%02d-%02d %02d:%02d:%02d.%03d %s  ", ts.year, ts.month, ts.day, ts.hour, ts.minute, ts.second, ts.fracSecs.split!("msecs").msecs, logLevelName(level));
                    logFile.writeln(args);
                    logFile.flush();
                }
            }
        }
    }
    /// Log message with arbitrary log level with format string
    static public void logf(S...)(LogLevel level, string fmt, S args) {
        if (logLevel >= level) {
            version (Android) {
                import std.string : toStringz;
                import std.format;
                string msg = fmt.format(args);
                __android_log_write(toAndroidLogPriority(level), ANDROID_LOG_TAG, msg.toStringz);
            } else {
                if (logFile !is null && logFile.isOpen) {
                    SysTime ts = Clock.currTime();
                    logFile.writef("%04d-%02d-%02d %02d:%02d:%02d.%03d %s  ", ts.year, ts.month, ts.day, ts.hour, ts.minute, ts.second, ts.fracSecs.split!("msecs").msecs, logLevelName(level));
                    logFile.writefln(fmt, args);
                    logFile.flush();
                }
            }
        }
    }
    /// Log verbose / trace message
    static public void v(S...)(S args) {
        synchronized(mutex) {
            if (logLevel >= LogLevel.Trace)
                log(LogLevel.Trace, args);
        }
    }
    /// Log verbose / trace message with format string
    static public void fv(S...)(S args) {
        synchronized(mutex) {
            if (logLevel >= LogLevel.Trace)
                logf(LogLevel.Trace, args);
        }
    }
    /// Log debug message
    static public void d(S...)(S args) {
        synchronized(mutex) {
            if (logLevel >= LogLevel.Debug)
                log(LogLevel.Debug, args);
        }
    }
    /// Log debug message with format string
    static public void fd(S...)(S args) {
        synchronized(mutex) {
            if (logLevel >= LogLevel.Debug)
                logf(LogLevel.Debug, args);
        }
    }
    /// Log info message
    static public void i(S...)(S args) {
        synchronized(mutex) {
            if (logLevel >= LogLevel.Info)
                log(LogLevel.Info, args);
        }
    }
    /// Log info message
    static public void fi(S...)(S args) {
        synchronized(mutex) {
            if (logLevel >= LogLevel.Info)
                logf(LogLevel.Info, args);
        }
    }
    /// Log warn message
    static public void w(S...)(S args) {
        synchronized(mutex) {
            if (logLevel >= LogLevel.Warn)
                log(LogLevel.Warn, args);
        }
    }
    /// Log warn message
    static public void fw(S...)(S args) {
        synchronized(mutex) {
            if (logLevel >= LogLevel.Warn)
                logf(LogLevel.Warn, args);
        }
    }
    /// Log error message
    static public void e(S...)(S args) {
        synchronized(mutex) {
            if (logLevel >= LogLevel.Error)
                log(LogLevel.Error, args);
        }
    }
    /// Log error message
    static public void fe(S...)(S args) {
        synchronized(mutex) {
            if (logLevel >= LogLevel.Error)
                logf(LogLevel.Error, args);
        }
    }
    /// Log fatal error message
    static public void f(S...)(S args) {
        synchronized(mutex) {
            if (logLevel >= LogLevel.Fatal)
                log(LogLevel.Fatal, args);
        }
    }
    /// Log fatal error message
    static public void ff(S...)(S args) {
        synchronized(mutex) {
            if (logLevel >= LogLevel.Fatal)
                logf(LogLevel.Fatal, args);
        }
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
