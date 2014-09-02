// Written in the D programming language.

/**
This module contains logger implementation.



Synopsis:

----
import dlangui.core.logger;

// use stderror for logging
setStderrLogger();
// set log level
setLogLevel(LogLeve.Debug);
// log debug message
Log.d("mouse clicked at ", x, ",", y);
// log error message
Log.d("exception while reading file", e);

----

Copyright: Vadim Lopatin, 2014
License:   Boost License 1.0
Authors:   Vadim Lopatin, coolreader.org@gmail.com
*/
module dlangui.core.logger;

import std.stdio;
import std.datetime;

enum LogLevel : int {
	Fatal,
	Error,
	Warn,
	Info,
	Debug,
	Trace
}

long currentTimeMillis() {
    return std.datetime.Clock.currStdTime / 10000;
}

synchronized class Log {
    static {
        private LogLevel logLevel = LogLevel.Info;
        private std.stdio.File logFile;
        
        void setStdoutLogger() {
            logFile = stdout;
        }

        void setStderrLogger() {
            logFile = stderr;
        }

        void setFileLogger(File file) {
            logFile = file;
        }

        void setLogLevel(LogLevel level) {
            logLevel = level;
        }

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
        void log(S...)(LogLevel level, S args) {
            if (logLevel >= level && logFile.isOpen) {
                SysTime ts = Clock.currTime();
                logFile.writef("%04d-%02d-%02d %02d:%02d:%02d.%03d %s  ", ts.year, ts.month, ts.day, ts.hour, ts.minute, ts.second, ts.fracSec.msecs, logLevelName(level));
                logFile.writeln(args);
                logFile.flush();
            }
        }
        void v(S...)(S args) {
            if (logLevel >= LogLevel.Trace && logFile.isOpen)
                log(LogLevel.Trace, args);
        }
        void d(S...)(S args) {
            if (logLevel >= LogLevel.Debug && logFile.isOpen)
                log(LogLevel.Debug, args);
        }
        void i(S...)(S args) {
            if (logLevel >= LogLevel.Info && logFile.isOpen)
                log(LogLevel.Info, args);
        }
        void w(S...)(S args) {
            if (logLevel >= LogLevel.Warn && logFile.isOpen)
                log(LogLevel.Warn, args);
        }
        void e(S...)(S args) {
            if (logLevel >= LogLevel.Error && logFile.isOpen)
                log(LogLevel.Error, args);
        }
        void f(S...)(S args) {
            if (logLevel >= LogLevel.Fatal && logFile.isOpen)
                log(LogLevel.Fatal, args);
        }
    }
}
