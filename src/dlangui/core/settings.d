module dlangui.core.settings;

import dlangui.core.logger;
import std.range;
import std.algorithm : equal;
import std.conv : to;
import std.utf : encode;
import std.math : pow;

enum SettingType {
    STRING,
    INTEGER,
    UINTEGER,
    FLOAT,
    OBJECT,
    ARRAY,
    TRUE,
    FALSE,
    NULL
}

/// array
struct SettingArray {
    Setting[] list;
    @property bool empty() inout { return list.length == 0; }
    Setting set(int index, Setting value, Setting parent = null) {
        if (index < 0)
            index = cast(int)(list.length);
        if (index >= list.length) {
            int oldlen = cast(int)list.length;
            list.length = index + 1;
            for (int i = oldlen; i < index; i++)
                list[i] = new Setting(); // insert NULL items in holes
        }
        list[index] = value;
        value.parent = parent;
        return value;
    }
    /// get item by index, returns null if index out of bounds
    Setting get(int index) {
        if (index < 0 || index >= list.length)
            return null;
        return list[index];
    }
    /// remove by index, returns removed value
    Setting remove(int index) {
        Setting res = get(index);
        if (!res)
            return null;
        for (int i = index; i < list.length - 1; i++)
            list[i] = list[i + 1];
        list[$ - 1] = null;
        list.length--;
        return res;
    }
    @property int length() {
        return cast(int)list.length;
    }
}

/// ordered map
struct SettingMap {
    Setting[] list;
    int[string] map;
    @property bool empty() inout { return list.length == 0; }
    /// get item by index, returns null if index out of bounds
    Setting get(int index) {
        if (index < 0 || index >= list.length)
            return null;
        return list[index];
    }
    /// get item by key, returns null if key is not found
    Setting get(string key) {
        auto p = (key in map);
        if (!p)
            return null;
        return list[*p];
    }
    Setting set(string key, Setting value, Setting parent) {
        value.parent = parent;
        auto p = (key in map);
        if (p) {
            // key is found
            list[*p] = value;
        } else {
            // new value
            list ~= value;
            map[key] = cast(int)list.length - 1;
        }
        return value;
    }

    /// remove by index, returns removed value
    Setting remove(int index) {
        Setting res = get(index);
        if (!res)
            return null;
        for (int i = index; i < list.length - 1; i++)
            list[i] = list[i + 1];
        list[$ - 1] = null;
        list.length--;
        string key;
        foreach(k, ref v; map) {
            if (v == index) {
                key = k;
            } else if (v > index) {
                v--;
            }
        }
        if (key)
            map.remove(key);
        return res;
    }
    /// returns key for index
    string keyByIndex(int index) {
        foreach(k, ref v; map) {
            if (v == index) {
                return k;
            }
        }
        return null;
    }
    /// remove by key, returns removed value
    Setting remove(string key) {
        auto p = (key in map);
        if (!p)
            return null;
        return remove(*p);
    }
    @property int length() {
        return cast(int)list.length;
    }
}

/// setting object
final class Setting {
    union Store {
        string str;
        long integer;
        ulong uinteger;
        double floating;
        SettingArray array;
        SettingMap * map;
    }
    private Setting _parent;
    private Store _store;
    private SettingType _type = SettingType.NULL;

    this() {
        // NULL setting
    }
    this(long v) {
        integer = v;
    }
    this(ulong v) {
        uinteger = v;
    }
    this(string v) {
        str = v;
    }
    this(double v) {
        floating = v;
    }
    this(bool v) {
        boolean = v;
    }
    this(Setting[] v) {
        clear(SettingType.ARRAY);
        _store.array.list = v;
    }

    /// get parent
    @property inout(Setting) parent() inout { return _parent; }
    /// set parent
    @property Setting parent(Setting v) {
        _parent = v;
        return v;
    }

    @property SettingType type() const { return _type; }
    /// clear value and set new type
    void clear(SettingType newType) {
        if (newType != _type) {
            clear();
            _type = newType;
        }
        clear();
    }
    /// clear value
    void clear() {
        final switch(_type) with(SettingType) {
            case STRING:
                _store.str = null;
                break;
            case ARRAY:
                _store.array = _store.array.init;
                break;
            case OBJECT:
                _store.map = _store.map.init;
                break;
            case INTEGER:
                _store.integer = _store.integer.init;
                break;
            case UINTEGER:
                _store.uinteger = _store.uinteger.init;
                break;
            case FLOAT:
                _store.floating = _store.floating.init;
                break;
            case TRUE:
            case FALSE:
            case NULL:
                break;
        }
    }

    /// read as string value
    @property inout(string) str() inout { 
        final switch(_type) with(SettingType) {
            case STRING:
                return _store.str;
            case INTEGER:
                return to!string(_store.integer);
            case UINTEGER:
                return to!string(_store.uinteger);
            case FLOAT:
                return to!string(_store.floating);
            case TRUE:
                return "true";
            case FALSE:
                return "false";
            case NULL:
            case ARRAY:
            case OBJECT:
                return null;
        }
    }
    /// read as string value
    inout(string) strDef(string defValue) inout { 
        final switch(_type) with(SettingType) {
            case STRING:
                return _store.str;
            case INTEGER:
                return to!string(_store.integer);
            case UINTEGER:
                return to!string(_store.uinteger);
            case FLOAT:
                return to!string(_store.floating);
            case TRUE:
                return "true";
            case FALSE:
                return "false";
            case NULL:
            case ARRAY:
            case OBJECT:
                return defValue;
        }
    }
    /// set string value for object
    @property string str(string v) {
        if (_type != SettingType.STRING)
            clear(SettingType.STRING);
        _store.str = v;
        return v;
    }

    static long parseLong(inout string v, long defValue = 0) {
        int len = cast(int)v.length;
        if (len == 0)
            return defValue;
        int sign = 1;
        long value = 0;
        int digits = 0;
        for (int i = 0; i < len; i++) {
            char ch = v[i];
            if (ch == '-') {
                if (i != 0)
                    return defValue;
                sign = -1;
            } else if (ch >= '0' && ch <= '9') {
                digits++;
                value = value * 10 + (ch - '0');
            } else {
                return defValue;
            }
        }
        return digits > 0 ? (sign > 0 ? value : -value) : defValue;
    }

    static ulong parseULong(inout string v, ulong defValue = 0) {
        int len = cast(int)v.length;
        if (len == 0)
            return defValue;
        ulong value = 0;
        int digits = 0;
        for (int i = 0; i < len; i++) {
            char ch = v[i];
            if (ch >= '0' && ch <= '9') {
                digits++;
                value = value * 10 + (ch - '0');
            } else {
                return defValue;
            }
        }
        return digits > 0 ? value : defValue;
    }

    /// read as long value
    @property inout(long) integer() inout { 
        final switch(_type) with(SettingType) {
            case STRING:
                return parseLong(_store.str);
            case INTEGER:
                return _store.integer;
            case UINTEGER:
                return cast(long)_store.uinteger;
            case FLOAT:
                return cast(long)_store.floating;
            case TRUE:
                return 1;
            case FALSE:
            case NULL:
            case ARRAY:
            case OBJECT:
                return 0;
        }
    }
    /// read as long value
    inout(long) integerDef(long defValue) inout { 
        final switch(_type) with(SettingType) {
            case STRING:
                return parseLong(_store.str, defValue);
            case INTEGER:
                return _store.integer;
            case UINTEGER:
                return cast(long)_store.uinteger;
            case FLOAT:
                return cast(long)_store.floating;
            case TRUE:
                return 1;
            case FALSE:
                return 0;
            case NULL:
            case ARRAY:
            case OBJECT:
                return defValue;
        }
    }
    /// set long value for object
    @property long integer(long v) {
        if (_type != SettingType.INTEGER)
            clear(SettingType.INTEGER);
        _store.integer = v;
        return v;
    }

    /// read as ulong value
    @property inout(long) uinteger() inout { 
        final switch(_type) with(SettingType) {
            case STRING:
                return parseULong(_store.str);
            case INTEGER:
                return cast(ulong)_store.integer;
            case UINTEGER:
                return _store.uinteger;
            case FLOAT:
                return cast(ulong)_store.floating;
            case TRUE:
                return 1;
            case FALSE:
            case NULL:
            case ARRAY:
            case OBJECT:
                return 0;
        }
    }
    /// read as ulong value
    inout(long) uintegerDef(ulong defValue) inout { 
        final switch(_type) with(SettingType) {
            case STRING:
                return parseULong(_store.str, defValue);
            case INTEGER:
                return cast(ulong)_store.integer;
            case UINTEGER:
                return _store.uinteger;
            case FLOAT:
                return cast(ulong)_store.floating;
            case TRUE:
                return 1;
            case FALSE:
                return 0;
            case NULL:
            case ARRAY:
            case OBJECT:
                return defValue;
        }
    }
    /// set ulong value for object
    @property ulong uinteger(ulong v) {
        if (_type != SettingType.UINTEGER)
            clear(SettingType.UINTEGER);
        _store.uinteger = v;
        return v;
    }

    /// read as double value
    @property inout(double) floating() inout {
        final switch(_type) with(SettingType) {
            case STRING:
                return 0; //parseULong(_store.str);
            case INTEGER:
                return cast(double)_store.integer;
            case UINTEGER:
                return cast(double)_store.uinteger;
            case FLOAT:
                return _store.floating;
            case TRUE:
                return 1;
            case FALSE:
            case NULL:
            case ARRAY:
            case OBJECT:
                return 0;
        }
    }
    /// read as double value with default
    inout(double) floatingDef(double defValue) inout {
        final switch(_type) with(SettingType) {
            case STRING:
                return defValue; //parseULong(_store.str);
            case INTEGER:
                return cast(double)_store.integer;
            case UINTEGER:
                return cast(double)_store.uinteger;
            case FLOAT:
                return _store.floating;
            case TRUE:
                return 1;
            case FALSE:
                return 0;
            case NULL:
            case ARRAY:
            case OBJECT:
                return defValue;
        }
    }
    /// set ulong value for object
    @property double floating(double v) {
        if (_type != SettingType.FLOAT)
            clear(SettingType.FLOAT);
        _store.floating = v;
        return v;
    }

    /// parse string as boolean; supports 1, 0, y, n, yes, no, t, f, true, false; returns defValue if cannot be parsed
    static bool parseBool(inout string v, bool defValue = false) {
        int len = cast(int)v.length;
        if (len == 0)
            return defValue;
        char ch = v[0];
        if (len == 1) {
            if (ch == '1' || ch == 'y' || ch == 't')
                return true;
            if (ch == '1' || ch == 'y' || ch == 't')
                return false;
            return defValue;
        }
        if (v.equal("yes") || v.equal("true"))
            return true;
        if (v.equal("no") || v.equal("false"))
            return false;
        return defValue;
    }

    /// read as boolean value
    @property inout(bool) boolean() inout {
        final switch(_type) with(SettingType) {
            case STRING:
                return parseBool(_store.str);
            case INTEGER:
                return _store.integer != 0;
            case UINTEGER:
                return _store.uinteger != 0;
            case FLOAT:
                return _store.floating != 0;
            case TRUE:
                return true;
            case FALSE:
            case NULL:
                return false;
            case ARRAY:
                return !_store.array.empty;
            case OBJECT:
                return _store.map && !_store.map.empty;
        }
    }
    /// read as boolean value
    inout(bool) booleanDef(bool defValue) inout {
        final switch(_type) with(SettingType) {
            case STRING:
                return parseBool(_store.str, defValue);
            case INTEGER:
                return _store.integer != 0;
            case UINTEGER:
                return _store.uinteger != 0;
            case FLOAT:
                return _store.floating != 0;
            case TRUE:
                return true;
            case FALSE:
            case NULL:
                return false;
            case ARRAY:
                return defValue;
            case OBJECT:
                return defValue;
        }
    }
    /// set bool value for object
    @property bool boolean(bool v) {
        if (_type == SettingType.TRUE) {
            if (!v) _type = SettingType.FALSE;
        } else if (_type == SettingType.FALSE) {
            if (v) _type = SettingType.TRUE;
        } else {
            clear(v ? SettingType.TRUE : SettingType.FALSE);
        }
        return v;
    }

    /// get number of elements for array or map, returns 0 for other types
    int length() inout {
        if (_type == SettingType.ARRAY) {
            return cast(int)_store.array.list.length;
        } else if (_type == SettingType.OBJECT) {
            return _store.map ? cast(int)_store.map.list.length : 0;
        } else
            return 0;
    }

    /// for array or object returns item by index, null if index is out of bounds or setting is neither array nor object
    Setting opIndex(int index) {
        if (_type == SettingType.ARRAY) {
            return _store.array.get(index);
        } else if (_type == SettingType.OBJECT) {
            if (!_store.map)
                return null;
            return _store.map.get(index);
        } else {
            return null;
        }
    }

    /// for object returns item by key, null if not found or this setting is not an object
    Setting opIndex(string key) {
        if (_type == SettingType.OBJECT) {
            if (!_store.map)
                return null;
            return _store.map.get(key);
        } else {
            return null;
        }
    }

    /// for array or object remove item by index, returns removed item or null if index is out of bounds or setting is neither array nor object
    Setting remove(int index) {
        if (_type == SettingType.ARRAY) {
            return _store.array.remove(index);
        } else if (_type == SettingType.OBJECT) {
            if (!_store.map)
                return null;
            return _store.map.remove(index);
        } else {
            return null;
        }
    }

    /// for object remove item by key, returns removed item or null if is not found or setting is not an object
    Setting remove(string key) {
        if (_type == SettingType.OBJECT) {
            if (!_store.map)
                return null;
            return _store.map.remove(key);
        } else {
            return null;
        }
    }

    // assign long value
    long opAssign(long value) {
        return (integer = value);
    }
    // assign ulong value
    ulong opAssign(ulong value) {
        return (uinteger = value);
    }
    // assign string value
    string opAssign(string value) {
        return (str = value);
    }
    // assign bool value
    bool opAssign(bool value) {
        return (boolean = value);
    }
    // assign double value
    double opAssign(double value) {
        return (floating = value);
    }

    // array methods
    /// sets value for array item by integer index
    T opIndexAssign(T)(T value, int index) {
        if (_type != SettingType.ARRAY)
            clear(SettingType.ARRAY);
        static if (is(T: Setting)) {
            _store.array.set(index, value, this);
        } else {
            Setting item = _store.array.get(index);
            if (item) {
                // existing item
                item = value;
            } else {
                // create new item
                _store.array.set(index, new Setting(value), this);
            }
        }
        return value;
    }
    /// sets value for array item by integer index if not already present
    T setDef(T)(T value, int index) {
        if (_type != SettingType.ARRAY)
            clear(SettingType.ARRAY);
        Setting item = _store.array.get(index);
        if (item)
            return value;
        static if (is(value == Setting)) {
            _store.array.set(index, value, this);
        } else {
            // create new item
            _store.array.set(index, new Setting(value), this);
        }
        return value;
    }

    // map methods
    /// sets value for object item by string key
    T opIndexAssign(T)(T value, string key) {
        if (_type != SettingType.OBJECT)
            clear(SettingType.OBJECT);
        if (!_store.map)
            _store.map = new SettingMap();
        static if (is(T: Setting)) {
            _store.map.set(key, value, this);
        } else {
            Setting item = _store.map.get(key);
            if (item) {
                // existing item
                item = value;
            } else {
                // create new item
                _store.map.set(key, new Setting(value), this);
            }
        }
        return value;
    }
    /// sets value for object item by string key
    T setDef(T)(T value, string key) {
        if (_type != SettingType.OBJECT)
            clear(SettingType.OBJECT);
        if (!_store.map)
            _store.map = new SettingMap();
        Setting item = _store.map.get(key);
        if (item)
            return value;
        static if (is(value == Setting)) {
            _store.map.set(key, value, this);
        } else {
            // create new item
            _store.map.set(key, new Setting(value), this);
        }
        return value;
    }

    /// sets long item by index of array or map
    long setInteger(int index, long value) {
        return opIndexAssign(value, index);
    }
    /// sets ulong item by index of array or map
    ulong setUinteger(int index, ulong value) {
        return opIndexAssign(value, index);
    }
    /// sets bool item by index of array or map
    bool setBoolean(int index, bool value) {
        return opIndexAssign(value, index);
    }
    /// sets double item by index of array or map
    double setFloating(int index, double value) {
        return opIndexAssign(value, index);
    }
    /// sets str item by index of array or map
    string setString(int index, string value) {
        return opIndexAssign(value, index);
    }

    /// sets long item by index of array or map only if it's фдкуфвн present
    long setIntegerDef(int index, long value) {
        return setDef(value, index);
    }
    /// sets ulong item by index of array or map only if it's фдкуфвн present
    ulong setUintegerDef(int index, ulong value) {
        return setDef(value, index);
    }
    /// sets bool item by index of array or map only if it's фдкуфвн present
    bool setBooleanDef(int index, bool value) {
        return setDef(value, index);
    }
    /// sets double item by index of array or map only if it's фдкуфвн present
    double setFloatingDef(int index, double value) {
        return setDef(value, index);
    }
    /// sets str item by index of array or map only if it's фдкуфвн present
    string setStringDef(int index, string value) {
        return setDef(value, index);
    }


    /// returns long item by index of array or map
    long getInteger(int index, long defValue = 0) {
        if (auto item = opIndex(index))
            return item.integerDef(defValue);
        return defValue;
    }
    /// returns ulong item by index of array or map
    ulong getUinteger(int index, ulong defValue = 0) {
        if (auto item = opIndex(index))
            return item.uintegerDef(defValue);
        return defValue;
    }
    /// returns bool item by index of array or map
    bool getBoolean(int index, bool defValue = false) {
        if (auto item = opIndex(index))
            return item.booleanDef(defValue);
        return defValue;
    }
    /// returns double item by index of array or map
    double getFloating(int index, double defValue = 0) {
        if (auto item = opIndex(index))
            return item.floatingDef(defValue);
        return defValue;
    }
    /// returns str item by index of array or map
    string getString(int index, string defValue = null) {
        if (auto item = opIndex(index))
            return item.strDef(defValue);
        return defValue;
    }


    /// sets long item of map
    long setInteger(string key, long value) {
        return opIndexAssign(value, key);
    }
    /// sets ulong item of map
    ulong setUinteger(string key, ulong value) {
        return opIndexAssign(value, key);
    }
    /// sets bool item of map
    bool setBoolean(string key, bool value) {
        return opIndexAssign(value, key);
    }
    /// sets double item of map
    double setFloating(string key, double value) {
        return opIndexAssign(value, key);
    }
    /// sets str item of map
    string setString(string key, string value) {
        return opIndexAssign(value, key);
    }

    /// sets long item of map if key is not yet present in map
    long setIntegerDef(string key, long value) {
        return setDef(value, key);
    }
    /// sets ulong item of map if key is not yet present in map
    ulong setUintegerDef(string key, ulong value) {
        return setDef(value, key);
    }
    /// sets bool item of map if key is not yet present in map
    bool setBooleanDef(string key, bool value) {
        return setDef(value, key);
    }
    /// sets double item of map if key is not yet present in map
    double setFloatingDef(string key, double value) {
        return setDef(value, key);
    }
    /// sets str item of map if key is not yet present in map
    string setStringDef(string key, string value) {
        return setDef(value, key);
    }



    /// returns long item by key from map
    long getInteger(string key, long defValue = 0) {
        if (auto item = opIndex(key))
            return item.integerDef(defValue);
        return defValue;
    }
    /// returns ulong item by key from map
    ulong getUinteger(string key, ulong defValue = 0) {
        if (auto item = opIndex(key))
            return item.uintegerDef(defValue);
        return defValue;
    }
    /// returns bool item by key from map
    bool getBoolean(string key, bool defValue = false) {
        if (auto item = opIndex(key))
            return item.booleanDef(defValue);
        return defValue;
    }
    /// returns double item by key from map
    double getFloating(string key, double defValue = 0) {
        if (auto item = opIndex(key))
            return item.floatingDef(defValue);
        return defValue;
    }
    /// returns str item by key from map
    string getString(string key, string defValue = null) {
        if (auto item = opIndex(key))
            return item.strDef(defValue);
        return defValue;
    }

    /// serialize to json
    string toJSON(bool pretty = false) {
        Buf buf;
        toJSON(buf, 0, pretty);
        return buf.get();
    }
    private static struct Buf {
        char[] buffer;
        int pos;
        string get() {
            return buffer[0 .. pos].dup;
        }
        void reserve(int size) {
            if (pos + size >= buffer.length)
                buffer.length = buffer.length ? 4096 : (pos + size + 4096) * 2;
        }
        void append(char ch) {
            buffer[pos++] = ch;
        }
        void append(string s) {
            foreach(ch; s)
                buffer[pos++] = ch;
        }
        void appendEOL() {
            append('\n');
        }

        void appendTabs(int level) {
            reserve(level * 4 + 1024);
            for(int i = 0; i < level; i++) {
                buffer[pos++] = ' ';
                buffer[pos++] = ' ';
                buffer[pos++] = ' ';
                buffer[pos++] = ' ';
            }
        }

        void appendHex(uint ch) {
            buffer[pos++] = '\\';
            buffer[pos++] = 'u';
            for (int i = 3; i >= 0; i--) {
                uint d = (ch >> (4 * i)) & 0x0F;
                buffer[pos++] = "0123456789abcdef"[d];
            }
        }
        void appendJSONString(string s) {
            reserve(s.length * 3 + 8);
            if (s is null) {
                append("null");
            } else {
                append('\"');
                foreach(ch; s) {
                    switch (ch) {
                        case '\\':
                            buffer[pos++] = '\\';
                            buffer[pos++] = '\\';
                            break;
                        case '\"':
                            buffer[pos++] = '\\';
                            buffer[pos++] = '\"';
                            break;
                        case '\r':
                            buffer[pos++] = '\\';
                            buffer[pos++] = 'r';
                            break;
                        case '\n':
                            buffer[pos++] = '\\';
                            buffer[pos++] = 'n';
                            break;
                        case '\b':
                            buffer[pos++] = '\\';
                            buffer[pos++] = 'b';
                            break;
                        case '\t':
                            buffer[pos++] = '\\';
                            buffer[pos++] = 't';
                            break;
                        case '\f':
                            buffer[pos++] = '\\';
                            buffer[pos++] = 'f';
                            break;
                        default:
                            if (ch < ' ') {
                                appendHex(ch);
                            } else {
                                buffer[pos++] = ch;
                            }
                            break;
                    }
                }
                append('\"');
            }
        }
    }

    void toJSON(ref Buf buf, int level, bool pretty) {
        buf.reserve(1024);
        final switch(_type) with(SettingType) {
            case STRING:
                buf.appendJSONString(_store.str);
                break;
            case INTEGER:
                buf.append(to!string(_store.integer));
                break;
            case UINTEGER:
                buf.append(to!string(_store.uinteger));
                break;
            case FLOAT:
                buf.append(to!string(_store.floating));
                break;
            case TRUE:
                buf.append("true");
                break;
            case FALSE:
                buf.append("false");
                break;
            case NULL:
                buf.append("null");
                break;
            case ARRAY:
                buf.append('[');
                if (pretty && _store.array.length > 0)
                    buf.appendEOL();
                for (int i = 0; ; i++) {
                    if (pretty)
                        buf.appendTabs(level + 1);
                    _store.array.get(i).toJSON(buf, level + 1, pretty);
                    if (i >= _store.array.length - 1)
                        break;
                    buf.append(',');
                    if (pretty)
                        buf.appendEOL();
                }
                if (pretty) {
                    buf.appendEOL();
                    buf.appendTabs(level);
                }
                buf.append(']');
                break;
            case OBJECT:
                buf.append('{');
                if (_store.map && _store.map.length) {
                    if (pretty)
                        buf.appendEOL();
                    for (int i = 0; ; i++) {
                        string key = _store.map.keyByIndex(i);
                        if (pretty)
                            buf.appendTabs(level + 1);
                        buf.appendJSONString(key);
                        buf.append(':');
                        if (pretty)
                            buf.append(' ');
                        _store.map.get(i).toJSON(buf, level + 1, pretty);
                        if (i >= _store.map.length - 1)
                            break;
                        buf.append(',');
                        if (pretty)
                            buf.appendEOL();
                    }
                }
                if (pretty) {
                    buf.appendEOL();
                    buf.appendTabs(level);
                }
                buf.append('}');
                break;
        }
    }

    void save(string filename, bool pretty = true) {
        import std.file;
        write(filename, toJSON(pretty));
    }

    private static struct JsonParser {
        string json;
        int pos;
        void init(string s) {
            json = s;
            pos = 0;
        }
        /// returns current char
        @property char peek() {
            return pos < json.length ? json[pos] : 0;
        }
        /// skips current char, returns next one (or null if eof)
        @property char nextChar() {
            if (pos < json.length - 1) {
                return json[++pos];
            } else {
                if (pos < json.length)
                    pos++;
            }
            return 0;
        }
        void error(string msg) {
            string context;
            // calculate error position line and column
            int line = 1;
            int col = 1;
            int lineStart = 0;
            for (int i = 0; i < pos; i++) {
                char ch = json[i];
                if (ch == '\r') {
                    if (i < json.length - 1 && json[i + 1] == '\n')
                        i++;
                    line++;
                    col = 1;
                    lineStart = i + 1;
                } else if (ch == '\n') {
                    if (i < json.length - 1 && json[i + 1] == '\r')
                        i++;
                    line++;
                    col = 1;
                    lineStart = i + 1;
                }
            }
            int contextStart = pos;
            int contextEnd = pos;
            for (; contextEnd < json.length; contextEnd++) {
                if (json[contextEnd] == '\r' || json[contextEnd] == '\n')
                    break;
            }
            if (contextEnd - contextStart < 3) {
                for (int i = 0; i < 3 && contextStart > 0; contextStart--, i++) {
                    if (json[contextStart - 1] == '\r' || json[contextStart - 1] == '\n')
                        break;
                }
            } else if (contextEnd > contextStart + 10)
                contextEnd = contextStart + 10;
            if (contextEnd > contextStart && contextEnd < json.length)
                context = "near `" ~ json[contextStart .. contextEnd] ~ "` ";
            throw new Exception("JSON parsing error in (" ~ to!string(line) ~ ":" ~ to!string(col) ~ ") " ~ context ~ ": " ~ msg);
        }
        static bool isSpace(char ch) {
            return ch== ' ' || ch == '\t' || ch == '\r' || ch == '\n';
        }
        static bool isAlpha(char ch) {
            return (ch >= 'a' && ch <= 'z') || (ch >= 'A' && ch <= 'Z') || ch == '_';
        }
        static bool isAlNum(char ch) {
            return (ch >= 'a' && ch <= 'z') || (ch >= 'A' && ch <= 'Z') || (ch >= '0' && ch <= '9') || ch == '_';
        }
        static bool isDigit(char ch) {
            return (ch >= '0' && ch <= '9');
        }
        @property char skipSpaces() {
            for(;pos < json.length;pos++) {
                char ch = json[pos];
                if (!isSpace(ch))
                    break;
            }
            return peek;
        }
        static int parseHexDigit(char ch) {
            if (ch >= '0' && ch <='9')
                return ch - '0';
            if (ch >= 'a' && ch <='f')
                return ch - 'a' + 10;
            if (ch >= 'A' && ch <='F')
                return ch - 'A' + 10;
            return -1;
        }
        string parseUnicodeChar() {
            if (pos >= json.length - 3)
                error("unexpected end of file while parsing unicode character entity inside string");
            dchar ch = 0;
            for (int i = 0; i < 4; i++) {
                int d = parseHexDigit(nextChar);
                if (d < 0)
                    error("error while parsing unicode character entity inside string");
                ch = (ch << 4) | d;
            }
            char[4] buf;
            size_t sz = encode(buf, ch);
            return buf[0..sz].dup;
        }

        @property string parseString() {
            char[] res;
            char ch = peek;
            if (ch != '\"')
                error("cannot parse string");
            for (;;) {
                ch = nextChar;
                if (!ch)
                    error("unexpected end of file while parsing string");
                if (ch == '\"') {
                    nextChar;
                    return cast(string)res;
                }
                if (ch == '\\') {
                    // escape sequence
                    ch = nextChar;
                    switch (ch) {
                        case 'n':
                            res ~= '\n';
                            break;
                        case 'r':
                            res ~= '\r';
                            break;
                        case 'b':
                            res ~= '\b';
                            break;
                        case 'f':
                            res ~= '\f';
                            break;
                        case '\\':
                            res ~= '\\';
                            break;
                        case '\"':
                            res ~= '\"';
                            break;
                        case 'u':
                            res ~= parseUnicodeChar();
                            break;
                        default:
                            error("unexpected escape sequence in string");
                            break;
                    }
                } else {
                    res ~= ch;
                }
            }
            error("cannot parse string");
        }
        @property string parseIdent() {
            char ch = peek;
            if (ch == '\"') {
                return parseString;
            }
            char[] res;
            if (isAlpha(ch)) {
                res ~= ch;
                for (;;) {
                    ch = nextChar;
                    if (isAlNum(ch)) {
                        res ~= ch;
                    } else {
                        break;
                    }
                }
            } else
                error("cannot parse string");
            return cast(string)res;
        }
        bool parseKeyword(string ident) {
            // returns true if parsed ok
            if (pos + ident.length > json.length)
                return false;
            for (int i = 0; i < ident.length; i++) {
                if (ident[i] != json[pos + i])
                    return false;
            }
            if (pos + ident.length < json.length) {
                char ch = json[pos + ident.length];
                if (isAlNum(ch))
                    return false;
            }
            pos += ident.length;
            return true;
        }

        // parse long, ulong or double
        void parseNumber(Setting res) {
            char ch = peek;
            int sign = 1;
            if (ch == '-') {
                sign = -1;
                ch = nextChar;
            }
            if (!isDigit(ch))
                error("cannot parse number");
            ulong n = 0;
            while (isDigit(ch)) {
                n = n * 10 + (ch - '0');
                ch = nextChar;
            }
            if (ch == '.' || ch == 'e' || ch == 'E') {
                // floating
                ulong n2 = 0;
                ulong n2_div = 1;
                if (ch == '.') {
                    ch = nextChar;
                    while(isDigit(ch)) {
                        n2 = n2 * 10 + (ch - '0');
                        n2_div *= 10;
                        ch = nextChar;
                    }
                    if (isAlpha(ch) && ch != 'e' && ch != 'E')
                        error("error while parsing number");
                }
                int shift = 0;
                int shiftSign = 1;
                if (ch == 'e' || ch == 'E') {
                    ch = nextChar;
                    if (ch == '-') {
                        shiftSign = -1;
                        ch = nextChar;
                    }
                    if (!isDigit(ch))
                        error("error while parsing number");
                    while(isDigit(ch)) {
                        shift = shift * 10 + (ch - '0');
                        ch = nextChar;
                    }
                }
                if (isAlpha(ch))
                    error("error while parsing number");
                double v = cast(double)n;
                if (n2) // part after period
                    v += cast(double)n2 / n2_div;
                if (sign < 0)
                    v = -v;
                if (shift) { // E part - pow10
                    double p = pow(10.0, shift);
                    if (shiftSign > 0)
                        v *= p;
                    else
                        v /= p;
                }
                res.floating = v;
            } else {
                // integer
                if (isAlpha(ch))
                    error("cannot parse number");
                if (sign < 0 || !(n & 0x8000000000000000L))
                    res.integer = cast(long)(n * sign); // signed
                else
                    res.uinteger = n; // unsigned
            }
        }
    }

    private void parseMap(ref JsonParser parser) {
        clear(SettingType.OBJECT);
        parser.nextChar; // skip initial {
        for(;;) {
            char ch = parser.skipSpaces;
            if (ch == '}') {
                parser.nextChar;
                break;
            }
            string key = parser.parseIdent;
            ch = parser.skipSpaces;
            if (ch != ':')
                parser.error("no : char after object field name");
            parser.nextChar;
            this[key] = (new Setting()).parseJSON(parser);
            ch = parser.skipSpaces;
            if (ch == ',') {
                parser.nextChar;
                parser.skipSpaces;
            } else if (ch != '}') {
                parser.error("unexpected character when waiting for , or } while parsing object");
            }
        }
    }

    private void parseArray(ref JsonParser parser) {
        clear(SettingType.ARRAY);
        parser.nextChar; // skip initial [
        for(;;) {
            char ch = parser.skipSpaces;
            if (ch == ']') {
                parser.nextChar;
                break;
            }
            Setting value = new Setting();
            value.parseJSON(parser);
            this[_store.array.length] = value;
            ch = parser.skipSpaces;
            if (ch == ',') {
                parser.nextChar;
                parser.skipSpaces;
            } else if (ch != ']') {
                parser.error("unexpected character when waiting for , or ] while parsing array");
            }
        }
    }

    private Setting parseJSON(ref JsonParser parser) {
        char ch = parser.skipSpaces;
        if (ch == '\"') {
            this = parser.parseString;
        } else if (ch == '[') {
            parseArray(parser);
        } else if (ch == '{') {
            parseMap(parser);
        } else if (parser.parseKeyword("null")) {
            // do nothing - we already have NULL value
        } else if (parser.parseKeyword("true")) {
            this = true;
        } else if (parser.parseKeyword("false")) {
            this = false;
        } else if (ch == '-' || JsonParser.isDigit(ch)) {
            parser.parseNumber(this);
        } else {
            parser.error("cannot parse JSON value");
        }
        return this;
    }

    void parseJSON(string s) {
        clear(SettingType.NULL);
        JsonParser parser;
        parser.init(s);
        parseJSON(parser);
    }

    bool load(string filename) {
        try {
            import std.file;
            string s = readText(filename);
            parseJSON(s);
            return true;
        } catch (Exception e) {
            // Failed
            Log.e("exception while parsing json: ", e);
            return false;
        }
    }
}

version (AAA): // comment out

/// access to settings
/// keys may be either simple key identifier or path delimited by / (e.g. setting1/subsetting2/subsetting15)
interface Settings {
    /// returns true if settings object has specified key
    bool hasKey(string key);
    /// returns reference to parent settings
    @property Settings parent();
    /// get string by key, returns defValue if no such key
    string getString(string key, string defValue = null);
    /// set string for key, returns old value or null if not set
    string setString(string key, string value);
    /// get string by index, returns defValue if no such key
    string getString(int index, string defValue = null);
    /// set string for index, returns old value or null if not set
    string setString(int index, string value);
    /// get bool by key, returns defValue if no such key
    bool getBool(string key, bool defValue = false);
    /// set bool for key, returns old value or false if not set
    bool setBool(string key, bool value);
    /// get bool by index, returns defValue if no such key
    bool getBool(int index, bool defValue = false);
    /// set bool for index, returns old value or false if not set
    bool setBool(int index, bool value);
    /// get bool by key, returns defValue if no such key
    int getInt(string key, int defValue = 0);
    /// set bool for key, returns old value or 0 if not set
    int setInt(string key, int value);
    /// get bool by index, returns defValue if no such key
    int getInt(int index, int defValue = 0);
    /// set bool for index, returns old value or 0 if not set
    int setInt(int index, int value);
    /// remove setting, returns true if removed, false if no such key
    bool remove(string key);
    /// child subsettings access by index
    Settings child(string key);
    /// child subsettings access by string key
    Settings child(int index);
    /// child Object subsettings access by index
    Settings childObject(string key, bool createIfNotExist = false);
    /// child Object subsettings access by index
    Settings childObject(int index, bool createIfNotExist = false);
    /// child Array subsettings access by index
    Settings childArray(int index, bool createIfNotExist = false);
    /// returns number of number-indexed items
    @property int length();
    /// returns true if this is map (use only string-indexed operations)
    @property bool isMap();
    /// returns true if this is array (use only int-indexed operations)
    @property bool isArray();
}

class Setting {
    int _index;
    string _id;
    string _stringValue;
    SettingsImpl _objectValue;

    this(string id, string value) {
        _id = id;
        _index = -1;
        _stringValue = value;
    }

    this(int index, string value) {
        _index = index;
        _stringValue = value;
    }

    this(string id, SettingsImpl value) {
        _id = id;
        _index = -1;
        _objectValue = value;
    }

    this(int index, SettingsImpl value) {
        _index = index;
        _objectValue = value;
    }

    @property bool hasId() { return _id !is null; }
    @property bool hasIndex() { return _index >= 0; }
    @property bool isString() { return !_objectValue; }
    @property bool isObject() { return _objectValue !is null; }

    @property string id() { return _id; }
    @property int index() { return _index; }

    @property SettingsImpl objectValue() { return _objectValue; }
    @property void objectValue(SettingsImpl v) { 
        _stringValue = null;
        _objectValue = v;
    }
    @property string stringValue() { return _stringValue; }
    @property void stringValue(string v) { 
        _objectValue = null;
        _stringValue = v; 
    }
}

/// implementation of settings object
class SettingsImpl : Settings {
    protected bool _isArray;
    protected SettingsImpl _parent;

    protected Setting[string] _byId;
    protected Setting[] _byIndex;
    protected int _nextIndex;

    //protected bool removeSetting(Setting v) {

    //}

    //protected SettingsImpl[string] _children;
    //protected SettingsImpl[] _indexedChildren;
    //protected string[string] _values;
    //protected string[] _indexedValues;
    
    this(SettingsImpl parent, bool isMap) {
        _parent = parent;
        _isArray = !isMap;
    }

    /// returns true if this is map (use only string-indexed operations)
    override @property bool isMap() {
        return !_isArray;
    }
    /// returns true if this is array (use only int-indexed operations)
    override @property bool isArray() {
        return _isArray;
    }
    /// returns reference to parent settings
    override @property Settings parent() {
        return _parent;
    }

    protected void reserveIndex(int index) {
        if (_byIndex.length <= index)
            _byIndex.length = !_byIndex.length ? 8 : index * 2;
    }

    /// get string by index, returns defValue if no such key
    override string getString(int index, string defValue = null) {
        if (index < 0 || index >= _byIndex.length)
            return defValue;
        Setting res = _byIndex[index];
        if (!res || !res.isString)
            return defValue;
        return res.stringValue;
    }
    /// set string for index, returns old value or null if not set
    override string setString(int index, string value) {
        assert(index >= 0);
        assert(index < 10000);
        Setting res;
        string resString;
        if (index >= 0 && index < _byIndex.length)
            res = _byIndex[index];
        reserveIndex(index);
       if (res) {
            resString = res.stringValue;
            res.stringValue = value;
        } else {
            _byIndex[index] = new Setting(index, value);
        }
        if (_nextIndex <= index)
            _nextIndex = index + 1;
        return resString;
    }

    /// returns number items
    override @property int length() {
        return _nextIndex;
    }

    private static bool splitKey(string key, ref string part1, ref string part2) {
        int dashPos = -1;
        for (int i = 0; i < key.length; i++) {
            if (key[i] == '/') {
                dashPos = i;
                break;
            }
        }
        if (dashPos >= 0) {
            // path
            part1 = key[0 .. dashPos];
            part2 = key[dashPos + 1 .. $];
            return true;
        }
        return false;
    }
    /// get string by key, returns defValue if no such key or value for key is not a string
    override string getString(string key, string defValue = null) {
        string part1, part2;
        if (splitKey(key, part1, part2)) {
            // path
            Setting * p = (part1 in _byId);
            if (!p || !p.isObject)
                return defValue;
            return (*p).objectValue.getString(part2, defValue);
        } else {
            Setting * p = (key in _byId);
            if (p && (*p).isString)
                return (*p).stringValue;
            return defValue;
        }
    }
    /// set string for key, returns old value or null if not set
    override string setString(string key, string value) {
        string part1, part2;
        if (splitKey(key, part1, part2)) {
            // path delimited by /
            Setting * p = (part1 in _byId);
            if (!p) {
                // no such key at all - create new object
                SettingsImpl newItem = new SettingsImpl(this, true);
                int index = _nextIndex++;
                Setting s = new Setting(part1, newItem);
                _byId[part1] = s;
                reserveIndex(index);
                _byIndex[index] = s;
                return newItem.setString(part2, value);
            } else {
                // already has such key
                if (!(*p).isObject) // if not an object, replace with object
                    (*p).objectValue = new SettingsImpl(this, true);
                return (*p).objectValue.setString(part2, value);
            }
        } else {
            // simple id
            Setting * p = (key in _byId);
            if (!p) {
                // no such key - create new item
                int index = _nextIndex++;
                Setting s = new Setting(key, value);
                _byId[key] = s;
                reserveIndex(index);
                _byIndex[index] = s;
                return null;
            } else {
                // found existing item
                string oldValue = (*p).stringValue;
                (*p).stringValue = value;
                return oldValue;
            }
        }
    }

    /// returns true if settings object has specified key
    override bool hasKey(string key) {
        assert(isMap);
        string part1, part2;
        if (splitKey(key, part1, part2)) {
            auto p = (part1 in _byId);
            if (!p) {
                return false;
            } else {
                if (!(*p).isObject) // found, but it's a string
                    return false;
                return (*p).objectValue.hasKey(part2);
            }
        } else {
            return (key in _byId) !is null;
        }
    }

    override Settings childObject(string key, bool createIfNotExist = false) {
        assert(isMap);
        string part1, part2;
        if (splitKey(key, part1, part2)) {
            auto p = (part1 in _byId);
            if (!p) {
                if (!createIfNotExist)
                    return null;
                SettingsImpl newItem = new SettingsImpl(this, true);
                int index = _nextIndex++;
                Setting s = new Setting(part1, newItem);
                _byId[part1] = s;
                reserveIndex(index);
                _byIndex[index] = s;
                return newItem.childObject(part2, createIfNotExist);
            } else {
                if ((*p).isObject)
                    return (*p).objectValue.childObject(part2, createIfNotExist);
                // exists, but not an object
                if (!createIfNotExist)
                    return null;
                SettingsImpl newItem = new SettingsImpl(this, true);
                (*p).objectValue = newItem;
                return newItem.childObject(part2, createIfNotExist);
            }
        } else {
            auto p = (key in _byId);
            if (!p) {
                if (!createIfNotExist)
                    return null;
                SettingsImpl newItem = new SettingsImpl(this, true);
                int index = _nextIndex++;
                Setting s = new Setting(key, newItem);
                _byId[key] = s;
                reserveIndex(index);
                _byIndex[index] = s;
                return newItem;
            } else {
                if ((*p).isObject)
                    return (*p).objectValue;
                // exists, but not an object
                if (!createIfNotExist)
                    return null;
                SettingsImpl newItem = new SettingsImpl(this, true);
                (*p).objectValue = newItem;
                return newItem;
            }
        }
    }

    /// child subsettings access by index
    override Settings child(int index) {
        // can work both for maps and arrays
        if (index < 0 || index >= _nextIndex)
            return null; // index out of range
        return _byIndex[index].objectValue;
    }

    /// child subsettings access string key
    override Settings child(string key) {
        assert(isMap);
        auto p = (key in _byId);
        if (!p)
            return null;
        return (*p).objectValue;
    }

    /// child subsettings access by index
    override Settings childObject(int index, bool createIfNotExist = false) {
        // can work both for maps and arrays
        assert(index >= 0 && index < 10000);
        if (_byIndex.length <= index && createIfNotExist)
            reserveIndex(index);
        Setting res = index < _byIndex.length ? _byIndex[index] : null;
        if (!res && !createIfNotExist)
            return null;
        if (res && res.isObject) // exists and is object
            return res.objectValue;
        SettingsImpl newItem = new SettingsImpl(this, true);
        if (res) {
            // exists but not an object
            res.objectValue = newItem;
            return newItem;
        }
        // not exists - create new Setting
        _byIndex[index] = new Setting(index, newItem);
        if (_nextIndex <= index)
            _nextIndex = index + 1;
        return newItem;
    }

    /// child Array subsettings access by index
    Settings childArray(int index, bool createIfNotExist = false) {
        // can work both for maps and arrays
        assert(index >= 0 && index < 10000);
        if (_byIndex.length <= index && createIfNotExist)
            reserveIndex(index);
        Setting res = index < _byIndex.length ? _byIndex[index] : null;
        if (!res && !createIfNotExist)
            return null;
        if (res && res.isObject) { // exists and is object
            if (res.objectValue.isArray) // existing child is array
                return res.objectValue;
            // existing child is map
            if (!createIfNotExist)
                return null; // wrong type
            // replace it with empty array since createIfNotExist is true
            SettingsImpl newItem = new SettingsImpl(this, false);
            res.objectValue = newItem;
            return newItem;
        }
        if (res && !createIfNotExist)
            return null;
        SettingsImpl newItem = new SettingsImpl(this, false);
        if (res) {
            // exists but not an object
            res.objectValue = newItem;
            return newItem;
        }
        // not exists - create new Setting
        _byIndex[index] = new Setting(index, newItem);
        if (_nextIndex <= index)
            _nextIndex = index + 1;
        return newItem;
    }

    /// remove setting, returns true if removed, false if no such key
    bool remove(string key) {
        string part1, part2;
        if (splitKey(key, part1, part2)) {
            auto p = (part1 in _byId);
            if (!p || !(*p).isObject) {
                return false;
            } else {
                return (*p).objectValue.remove(part2);
            }
        } else {
            auto p = (key in _byId);
            if (!p)
                return false;
            for (int i = 0; i < _byIndex.length; i++) {
                if (_byIndex[i] is (*p)) {
                    return remove(i);
                }
            }
            return false;
        }
    }

    /// remove item by index
    bool remove(int index) {
        if (index < 0 || index >= _nextIndex)
            return false; // index out of range
        for (int i = index; i < _nextIndex - 1; i++)
            _byIndex[i] = _byIndex[i + 1];
        _byIndex[--_nextIndex] = null;
        return true;
    }

    static bool parseBool(string v, bool defValue) {
        int len = cast(int)v.length;
        if (len == 0)
            return defValue;
        char ch = v[0];
        if (len == 1) {
            if (ch == '1' || ch == 'y' || ch == 't')
                return true;
            if (ch == '1' || ch == 'y' || ch == 't')
                return false;
            return defValue;
        }
        if (v.equal("yes") || v.equal("true"))
            return true;
        if (v.equal("no") || v.equal("false"))
            return false;
        return defValue;
    }

    static int parseInt(string v, int defValue) {
        int len = cast(int)v.length;
        if (len == 0)
            return defValue;
        int sign = 1;
        int value = 0;
        int digits = 0;
        for (int i = 0; i < len; i++) {
            char ch = v[i];
            if (ch == '-') {
                if (i != 0)
                    return defValue;
                sign = -1;
            } else if (ch >= '0' && ch <= '9') {
                digits++;
                value = value * 10 + (ch - '0');
            } else {
                return defValue;
            }
        }
        return digits > 0 ? (sign > 0 ? value : -value) : defValue;
    }

    /// get bool by key, returns defValue if no such key
    override bool getBool(string key, bool defValue = false) {
        return parseBool(getString(key, ""), defValue);
    }
    /// set bool for key, returns old value or null if not set
    override bool setBool(string key, bool value) {
        return parseBool(setString(key, value ? "1" : "0"), false);
    }
    /// get bool by index, returns defValue if no such key
    override bool getBool(int index, bool defValue = false) {
        return parseBool(getString(index, ""), defValue);
    }
    /// set bool for index, returns old value or false if not set
    override bool setBool(int index, bool value) {
        return parseBool(setString(index, value ? "1" : "0"), false);
    }

    /// get bool by key, returns defValue if no such key
    override int getInt(string key, int defValue = 0) {
        return parseInt(getString(key, ""), defValue);
    }
    /// set bool for key, returns old value or null if not set
    override int setInt(string key, int value) {
        return parseInt(setString(key, to!string(value)), false);
    }
    /// get bool by index, returns defValue if no such key
    override int getInt(int index, int defValue = 0) {
        return parseInt(getString(index, ""), defValue);
    }
    /// set bool for index, returns old value or 0 if not set
    override int setInt(int index, int value) {
        return parseInt(setString(index, to!string(value)), false);
    }
}
