module dlangui.core.settings;

import std.range;
import std.algorithm;
import std.conv;

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

    // array methods
    /// sets value for item by index
    T opIndexAssign(T)(T value, int index) {
        if (_type != SettingType.ARRAY)
            clear(SettingType.ARRAY);
        static if (is(value == Setting)) {
            _store.array.set(index, value, this);
        } else {
            if (index >= 0 && index < _store.array.list.length) {
                // existing item
                Setting item = _store.array.list[index];
            } else {
                // create new item
                _store.array.set(index, new Setting(value), this);
            }
        }
        return value;
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
