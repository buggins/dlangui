// Written in the D programming language.

/**
DLANGUI library.

This module contains definition of signals / listeners.

Similar to std.signals.

Unlike std.signals, supports any types of delegates, and as well interfaces with single method.

Unlike std.signals, can support return types for slots.

Caution: unlike std.signals, does not disconnect signal from slots belonging to destroyed objects.

Listener here stand for holder of single delegate (slot).
Signal is the same but supports multiple slots.

Can be declared either using list of result value and argument types, or by interface name with single method.


Synopsis:

----
import dlangui.core.signals;

interface SomeInterface {
    bool someMethod(string s, int n);
}
class Foo : SomeInterface {
	override bool someMethod(string s, int n) {
		writeln("someMethod called ", s, ", ", n);
		return n > 10; // can return value
	}
}

// Listener! can hold arbitrary number of connected slots

// declare using list of return value and parameter types
Listener!(bool, string, n) signal1;

Foo f = new Foo();
// when signal is defined as type list, you can use delegate
signal1 = bool delegate(string s, int n) { writeln("inside delegate - ", s, n); return false; }
// or method reference
signal1 = &f.someMethod;

// declare using interface with single method
Listener!SomeInterface signal2;
// you still can use any delegate
signal2 = bool delegate(string s, int n) { writeln("inside delegate - ", s, n); return false; }
// but for class method which overrides interface method, you can use simple syntax
signal2 = f; // it will automatically take &f.someMethod


// call listener(s) either by opcall or explicit emit
signal1("text", 1);
signal1.emit("text", 2);
signal2.emit("text", 3);

// check if any slit is connected
if (signal1.assigned)
	writeln("has listeners");

// Signal! can hold arbitrary number of connected slots

// declare using list of return value and parameter types
Signal!(bool, string, n) signal3;

// add listeners via connect call
signal3.connect(bool delegate(string, int) { return false; });
// or via ~= operator
signal3 ~= bool delegate(string, int) { return false; };

// declare using interface with single method
Signal!SomeInterface signal4;

// you can connect several slots to signal
signal4 ~= f;
signal4 ~= bool delegate(string, int) { return true; }

// calling of listeners of Signal! is similar to Listener!
// using opCall
bool res = signal4("blah", 5);
// call listeners using emit
bool res = signal4.emit("blah", 5);

// you can disconnect individual slots
// using disconnect()
signal4.disconnect(f);
// or -= operator
signal4 -= f;

----

Copyright: Vadim Lopatin, 2014
License:   Boost License 1.0
Authors:   Vadim Lopatin, coolreader.org@gmail.com
*/
module dlangui.core.signals;

import std.traits;
import dlangui.core.collections;

/// Single listener; parameter is interface with single method
struct Listener(T1) if (is(T1 == interface) && __traits(allMembers, T1).length == 1) {
    alias return_t = ReturnType!(__traits(getMember, T1, __traits(allMembers, T1)[0]));
    alias params_t = ParameterTypeTuple!(__traits(getMember, T1, __traits(allMembers, T1)[0]));
    alias slot_t = return_t delegate(params_t);
    private slot_t _listener;
    /// returns true if listener is assigned
    final bool assigned() {
        return _listener !is null;
    }
    /// assign delegate
    final void opAssign(slot_t listenerDelegate) {
        _listener = listenerDelegate;
    }
    /// assign object implementing interface
    final void opAssign(T1 listenerObject) {
        _listener = &(__traits(getMember, listenerObject, __traits(allMembers, T1)[0]));
    }
    final return_t opCall(params_t params) {
        static if (is(return_t == void)) {
            if (_listener !is null)
                _listener(params);
        } else {
            if (_listener !is null)
                return _listener(params);
            return return_t.init;
        }
    }
    final slot_t get() {
        return _listener;
    }
    alias get this;
}

/// Single listener; implicitly specified return and parameter types
struct Listener(RETURN_T, T1...)
{
    alias slot_t = RETURN_T delegate(T1);
    private slot_t _listener;
    /// returns true if listener is assigned
    final bool assigned() {
        return _listener !is null;
    }
    final void opAssign(slot_t listener) {
        _listener = listener;
    }
    final RETURN_T opCall(T1 params) {
        static if (is (RETURN_T == void)) {
            if (_listener !is null)
                _listener(params);
        } else {
            if (_listener !is null)
                return _listener(params);
            return RETURN_T.init;
        }
    }
    final slot_t get() {
        return _listener;
    }
    alias get this;
}

/// Multiple listeners; implicitly specified return and parameter types
struct Signal(T1) if (is(T1 == interface) && __traits(allMembers, T1).length == 1) {
    alias return_t = ReturnType!(__traits(getMember, T1, __traits(allMembers, T1)[0]));
    alias params_t = ParameterTypeTuple!(__traits(getMember, T1, __traits(allMembers, T1)[0]));
    alias slot_t = return_t delegate(params_t);
    private Collection!slot_t _listeners;

	this(ref Signal!T1 v) {
		_listeners.addAll(v._listeners);
	}

    /// returns true if listener is assigned
    final bool assigned() {
        return _listeners.length > 0;
    }
    /// replace all previously assigned listeners with new one (if null passed, remove all listeners)
    final void opAssign(slot_t listener) {
        _listeners.clear();
		if (listener !is null)
			_listeners ~= listener;
    }
    /// replace all previously assigned listeners with new one (if null passed, remove all listeners)
    final void opAssign(T1 listener) {
		opAssign(&__traits(getMember, listener, __traits(allMembers, T1)[0]));
    }
    /// call all listeners; for signals having non-void return type, stop iterating when first return value is nonzero
    static if (is (return_t == void)) {
        // call all listeners
        final return_t opCall(params_t params) {
            foreach(listener; _listeners)
                listener(params);
        }
        // call all listeners
        final return_t emit(params_t params) {
            foreach(listener; _listeners)
                listener(params);
        }
    } else {
        // call listeners, stop calling on first non-zero -- if (res) return res
        final return_t opCall(params_t params) {
            return emit(params);
        }
        // call listeners, stop calling on first non-zero -- if (res) return res
        final return_t emit(params_t params) {
            foreach(listener; _listeners) {
                return_t res = listener(params);
                if (res)
                    return res;
            }
            return return_t.init;
        }
    }
    /// add listener
    final void connect(slot_t listener) {
        _listeners ~= listener;
    }
    /// remove listener
    final void disconnect(slot_t listener) {
        _listeners -= listener;
    }
    /// add listener - as interface member
    final void connect(T1 listener) {
		connect(&__traits(getMember, listener, __traits(allMembers, T1)[0]));
    }
    /// add listener - as interface member
    final void disconnect(T1 listener) {
		disconnect(&__traits(getMember, listener, __traits(allMembers, T1)[0]));
    }
}

/// Multiple listeners; implicitly specified return and parameter types
struct Signal(RETURN_T, T1...)
{
    alias slot_t = RETURN_T delegate(T1);
    private Collection!slot_t _listeners;
    /// returns true if listener is assigned
    final bool assigned() {
        return _listeners.length > 0;
    }
    /// replace all previously assigned listeners with new one (if null passed, remove all listeners)
    final void opAssign(slot_t listener) {
        _listeners.clear();
		if (listener !is null)
			_listeners ~= listener;
    }
    /// call all listeners; for signals having non-void return type, stop iterating when first return value is nonzero
    static if (is (RETURN_T == void)) {
        // call all listeners
        final RETURN_T opCall(T1 params) {
            foreach(listener; _listeners)
                listener(params);
        }
        // call all listeners
        final RETURN_T emit(T1 params) {
            foreach(listener; _listeners)
                listener(params);
        }
    } else {
        // call listeners, stop calling on first non-zero -- if (res) return res
        final RETURN_T opCall(T1 params) {
            return emit(params);
        }
        // call listeners, stop calling on first non-zero -- if (res) return res
        final RETURN_T emit(T1 params) {
            foreach(listener; _listeners) {
                RETURN_T res = listener(params);
                if (res)
                    return res;
            }
            return RETURN_T.init;
        }
    }
    /// add listener
    final void connect(slot_t listener) {
        _listeners ~= listener;
    }
    /// remove listener
    final void disconnect(slot_t listener) {
        _listeners -= listener;
    }
}
