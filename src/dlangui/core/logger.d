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

Copyright: Vadim Lopatin, 2014
License:   Boost License 1.0
Authors:   Vadim Lopatin, coolreader.org@gmail.com
*/
module dlangui.core.logger;

import std.stdio;
import std.datetime : SysTime, Clock;
import core.sync.mutex;

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
            logFile = &stdout;
        }
    }

    /// Redirects output to stderr
    static public void setStderrLogger() {
        synchronized(mutex) {
            logFile = &stderr;
        }
    }

    /// Redirects output to file
    static public void setFileLogger(File * file) {
        synchronized(mutex) {
            if (logFile !is null && logFile != &stdout && logFile != &stderr) {
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
    /// Log message with arbitrary log level
    static public void log(S...)(LogLevel level, S args) {
        if (logLevel >= level && logFile !is null && logFile.isOpen) {
            SysTime ts = Clock.currTime();
            logFile.writef("%04d-%02d-%02d %02d:%02d:%02d.%03d %s  ", ts.year, ts.month, ts.day, ts.hour, ts.minute, ts.second, ts.fracSecs.split!("msecs").msecs, logLevelName(level));
            logFile.writeln(args);
            logFile.flush();
        }
    }
    /// Log message with arbitrary log level with format string
    static public void logf(S...)(LogLevel level, S args) {
        if (logLevel >= level && logFile !is null && logFile.isOpen) {
            SysTime ts = Clock.currTime();
            logFile.writef("%04d-%02d-%02d %02d:%02d:%02d.%03d %s  ", ts.year, ts.month, ts.day, ts.hour, ts.minute, ts.second, ts.fracSecs.split!("msecs").msecs, logLevelName(level));
            logFile.writefln(args);
            logFile.flush();
        }
    }
    /// Log verbose / trace message
    static public void v(S...)(S args) {
        synchronized(mutex) {
            if (logLevel >= LogLevel.Trace && logFile !is null && logFile.isOpen)
                log(LogLevel.Trace, args);
        }
    }
    /// Log verbose / trace message with format string
    static public void fv(S...)(S args) {
        synchronized(mutex) {
            if (logLevel >= LogLevel.Trace && logFile !is null && logFile.isOpen)
                logf(LogLevel.Trace, args);
        }
    }
    /// Log debug message
    static public void d(S...)(S args) {
        synchronized(mutex) {
            if (logLevel >= LogLevel.Debug && logFile !is null && logFile.isOpen)
                log(LogLevel.Debug, args);
        }
    }
    /// Log debug message with format string
    static public void fd(S...)(S args) {
        synchronized(mutex) {
            if (logLevel >= LogLevel.Debug && logFile !is null && logFile.isOpen)
                logf(LogLevel.Debug, args);
        }
    }
    /// Log info message
    static public void i(S...)(S args) {
        synchronized(mutex) {
            if (logLevel >= LogLevel.Info && logFile !is null && logFile.isOpen)
                log(LogLevel.Info, args);
        }
    }
    /// Log info message
    static public void fi(S...)(S args) {
        synchronized(mutex) {
            if (logLevel >= LogLevel.Info && logFile !is null && logFile.isOpen)
                logf(LogLevel.Info, args);
        }
    }
    /// Log warn message
    static public void w(S...)(S args) {
        synchronized(mutex) {
            if (logLevel >= LogLevel.Warn && logFile !is null && logFile.isOpen)
                log(LogLevel.Warn, args);
        }
    }
    /// Log warn message
    static public void fw(S...)(S args) {
        synchronized(mutex) {
            if (logLevel >= LogLevel.Warn && logFile !is null && logFile.isOpen)
                logf(LogLevel.Warn, args);
        }
    }
    /// Log error message
    static public void e(S...)(S args) {
        synchronized(mutex) {
            if (logLevel >= LogLevel.Error && logFile !is null && logFile.isOpen)
                log(LogLevel.Error, args);
        }
    }
    /// Log error message
    static public void fe(S...)(S args) {
        synchronized(mutex) {
            if (logLevel >= LogLevel.Error && logFile !is null && logFile.isOpen)
                logf(LogLevel.Error, args);
        }
    }
    /// Log fatal error message
    static public void f(S...)(S args) {
        synchronized(mutex) {
            if (logLevel >= LogLevel.Fatal && logFile !is null && logFile.isOpen)
                log(LogLevel.Fatal, args);
        }
    }
    /// Log fatal error message
    static public void ff(S...)(S args) {
        synchronized(mutex) {
            if (logLevel >= LogLevel.Fatal && logFile !is null && logFile.isOpen)
                logf(LogLevel.Fatal, args);
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

