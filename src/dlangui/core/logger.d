// Written in the D programming language.

/**
DLANGUI library.

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
License:   $(WEB boost.org/LICENSE_1_0.txt, Boost License 1.0).
Authors:   $(WEB coolreader.org, Vadim Lopatin)
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

__gshared LogLevel logLevel = LogLevel.Info;
__gshared std.stdio.File logFile;

void setLogLevel(LogLevel level) {
	logLevel = level;
}

long currentTimeMillis() {
    return std.datetime.Clock.currStdTime / 10000;
}

void setStdoutLogger() {
	logFile = stdout;
}

void setStderrLogger() {
	logFile = stderr;
}

void setFileLogger(File file) {
	logFile = file;
}

class Log {
	static string logLevelName(LogLevel level) {
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
	static void log(S...)(LogLevel level, S args) {
		if (logLevel >= level && logFile.isOpen) {
			SysTime ts = Clock.currTime();
			logFile.writef("%04d-%02d-%02d %02d:%02d:%02d.%03d %s  ", ts.year, ts.month, ts.day, ts.hour, ts.minute, ts.second, ts.fracSec.msecs, logLevelName(level));
			logFile.writeln(args);
			logFile.flush();
		}
	}
	static void v(S...)(S args) {
		if (logLevel >= LogLevel.Trace && logFile.isOpen)
			log(LogLevel.Trace, args);
	}
	static void d(S...)(S args) {
		if (logLevel >= LogLevel.Debug && logFile.isOpen)
			log(LogLevel.Debug, args);
	}
	static void i(S...)(S args) {
		if (logLevel >= LogLevel.Info && logFile.isOpen)
			log(LogLevel.Info, args);
	}
	static void w(S...)(S args) {
		if (logLevel >= LogLevel.Warn && logFile.isOpen)
			log(LogLevel.Warn, args);
	}
	static void e(S...)(S args) {
		if (logLevel >= LogLevel.Error && logFile.isOpen)
			log(LogLevel.Error, args);
	}
	static void f(S...)(S args) {
		if (logLevel >= LogLevel.Fatal && logFile.isOpen)
			log(LogLevel.Fatal, args);
	}
}
