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
setLogLevel(LogLeve.Debug);

// usage:

// log debug message
Log.d("mouse clicked at ", x, ",", y);
// log error message
Log.e("exception while reading file", e);
----

Copyright: Vadim Lopatin, 2014
License:   Boost License 1.0
Authors:   Vadim Lopatin, coolreader.org@gmail.com
*/
module dlangui.core.logger;

import std.stdio;
import std.datetime;

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
synchronized class Log {
    static:
    private LogLevel logLevel = LogLevel.Info;
    private std.stdio.File logFile;
        
    /// Redirects output to stdout
    void setStdoutLogger() {
        logFile = stdout;
    }

    /// Redirects output to stderr
    void setStderrLogger() {
        logFile = stderr;
    }

    /// Redirects output to file
    void setFileLogger(File file) {
        logFile = file;
    }

    /// Sets log level (one of LogLevel)
    void setLogLevel(LogLevel level) {
        logLevel = level;
    }

    /// Log level to name helper function
    string logLevelName(LogLevel level) {
        switch (level) {
            case LogLevel.Fatal: return "F";
            case LogLevel.Error: return "E";
            case LogLevel.Warn: return "W";
            case LogLevel.Info: return "I";
            case LogLevel.Debug: return "D";
            case LogLevel.Trace: return "V";
            default: return "?";
        }
    }
    /// Log message with arbitrary log level
    void log(S...)(LogLevel level, S args) {
        if (logLevel >= level && logFile.isOpen) {
            SysTime ts = Clock.currTime();
            logFile.writef("%04d-%02d-%02d %02d:%02d:%02d.%03d %s  ", ts.year, ts.month, ts.day, ts.hour, ts.minute, ts.second, ts.fracSec.msecs, logLevelName(level));
            logFile.writeln(args);
            logFile.flush();
        }
    }
    /// Log verbose / trace message
    void v(S...)(S args) {
        if (logLevel >= LogLevel.Trace && logFile.isOpen)
            log(LogLevel.Trace, args);
    }
    /// Log debug message
    void d(S...)(S args) {
        if (logLevel >= LogLevel.Debug && logFile.isOpen)
            log(LogLevel.Debug, args);
    }
    /// Log info message
    void i(S...)(S args) {
        if (logLevel >= LogLevel.Info && logFile.isOpen)
            log(LogLevel.Info, args);
    }
    /// Log warn message
    void w(S...)(S args) {
        if (logLevel >= LogLevel.Warn && logFile.isOpen)
            log(LogLevel.Warn, args);
    }
    /// Log error message
    void e(S...)(S args) {
        if (logLevel >= LogLevel.Error && logFile.isOpen)
            log(LogLevel.Error, args);
    }
    /// Log fatal error message
    void f(S...)(S args) {
        if (logLevel >= LogLevel.Fatal && logFile.isOpen)
            log(LogLevel.Fatal, args);
    }
}
