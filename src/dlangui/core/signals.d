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
    /// returns true if listener is assigned
    final bool assigned() {
        return _listeners.length > 0;
    }
    /// replace all previously assigned listeners with new one (if null passed, remove all listeners)
    final void opAssign(slot_t listener) {
        _listeners.clear();
        _listeners ~= listener;
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
    final void opAssign(slot_t listener) {
        _listeners.clear();
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
