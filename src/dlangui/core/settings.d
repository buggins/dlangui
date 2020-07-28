// Written in the D programming language.

/**

This module contains implementation of settings container.

Similar to JSON, can be written/read to/from JSON.

Difference from usual JSON implementations: map (object) is ordered - will be written in the same order as read (or created).

Has a lot of methods for convenient storing/accessing of settings.


Synopsis:

----
import dlangui.core.settings;

Setting s = new Setting();

----

Copyright: Vadim Lopatin, 2014
License:   Boost License 1.0
Authors:   Vadim Lopatin, coolreader.org@gmail.com
*/
module dlangui.core.settings;

import dlangui.core.logger;
import dlangui.core.types : parseHexDigit;
public import dlangui.core.parseutils;
import std.range;
//import std.algorithm : clamp, equal;
import std.algorithm : equal;
import std.conv : to;
import std.utf : encode;
import std.math : pow;
import std.file;
import std.path;
import std.datetime : SysTime;

/// setting types - same as in std.json
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

/// settings file format
enum SettingsFileFormat {
    JSON,
    SDL,
}

/// Settings object whith file information
class SettingsFile {
    protected Setting _setting;
    protected string _filename;
    protected SysTime _lastModificationTime;
    protected bool _loaded;
    protected SettingsFileFormat _format = SettingsFileFormat.JSON;

    @property Setting setting() { return _setting; }
    @property Setting copySettings() {
        return _setting.clone();
    }
    /// replace setting object
    void replaceSetting(Setting s) {
        _setting = s;
    }
    @property void applySettings(Setting settings) {
        // TODO copy only changed settings
        _setting = settings;
        //_setting.apply(settings);
    }
    alias setting this;

    /// create settings file object; if filename is provided, attempts to load settings from file
    this(string filename = null) {
        _setting = new Setting();
        _filename = filename;
        if (_filename) {
            string dir = dirName(_filename);
            if (load()) {
                // loaded ok
            } else {
            }
        }
    }

    static int limitInt(long value, int minvalue, int maxvalue) {
        if (value < minvalue)
            return minvalue;
        if (value > maxvalue)
            return maxvalue;
        return cast(int)value;
        // remove clamp to support older compilers
        //return clamp(cast(int)value, minvalue, maxvalue);
    }

    static string limitString(string value, const string[] values)
    in { assert(values.length > 0); }
    body {
        foreach(v; values)
            if (v.equal(value))
                return value;
        return values[0];
    }


    @property bool loaded() {
        return _loaded;
    }

    /// filename
    @property string filename() { return _filename; }
    /// filename
    @property void filename(string fn) { _filename = fn; }

    protected bool updateModificationTime() {
        if (_filename is null)
            return false;
        try {
            if (!_filename.exists || !_filename.isFile)
                return false;
            SysTime accTime;
            getTimes(_filename, accTime, _lastModificationTime);
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    /// load settings from file
    bool load(string filename = null) {
        if (filename !is null)
            _filename = filename;
        assert(_filename !is null);
        if (updateModificationTime()) {
            bool res = _setting.load(_filename);
            if (res)
                _loaded = true;
            afterLoad();
            return res;
        }
        return false;
    }

    /// save settings to file
    bool save(string filename = null, bool pretty = true) {
        if (filename !is null)
            _filename = filename;
        assert(_filename);
        string dir = dirName(_filename);
        if (!dir.exists) {
            try {
                mkdirRecurse(dir);
            } catch (Exception e) {
                return false;
            }
        } else if (!dir.isDir) {
            Log.d("", dir, " is file");
            return false;
        }
        bool res = _setting.save(_filename, pretty);
        res = updateModificationTime() || res;
        afterSave();
        return res;
    }

    /// override to add default values if missing
    void updateDefaults() {
    }

    /// override to do something after loading - e.g. set defaults
    void afterLoad() {
    }

    /// override to do something after saving
    void afterSave() {
    }

    bool merge(string json) {
        try {
            Setting setting = new Setting();
            setting.parseJSON(json);
            _setting.apply(setting);
        } catch (Exception e) {
            Log.e("SettingsFile.merge - failed to parse json", e);
            return false;
        }
        return true;
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
    private bool _changed;
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

    this(string[] v) {
        clear(SettingType.ARRAY);
        this.strArray = v;
    }

    this(string[string] v) {
        clear(SettingType.ARRAY);
        this.strMap = v;
    }

    /// returns true if setting has been changed
    @property bool changed() {
        return _changed;
    }

    /// sets change flag
    @property void changed(bool changed) {
        _changed = changed;
    }

    /// array
    private static struct SettingArray {
        Setting[] list;
        @property bool empty() inout { return list.length == 0; }
        Setting set(int index, Setting value, Setting parent = null) {
            if (index < 0)
                index = cast(int)(list.length);
            if (index >= list.length) {
                int oldlen = cast(int)list.length;
                list.length = index + 1;
                foreach(i; oldlen .. index)
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
            foreach(i; index .. list.length - 1)
                list[i] = list[i + 1];
            list[$ - 1] = null;
            list.length--;
            return res;
        }
        @property int length() {
            return cast(int)list.length;
        }
        /// deep copy
        void copyFrom(ref SettingArray v) {
            list.length = v.list.length;
            foreach(i; 0 .. v.list.length) {
                list[i] = v.list[i].clone();
            }
        }
    }

    /// ordered map
    private static struct SettingMap {
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
            foreach(i; index .. list.length - 1)
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
        /// deep copy
        void copyFrom(SettingMap * v) {
            list.length = v.list.length;
            foreach(i; 0 .. v.list.length) {
                list[i] = v.list[i].clone();
            }
            destroy(map);
            foreach(key, value; v.map)
                map[key] = value;
        }
    }


    /// get parent
    @property inout(Setting) parent() inout { return _parent; }
    /// set parent
    @property Setting parent(Setting v) {
        _parent = v;
        return v;
    }

    /// returns SettingType of setting
    @property SettingType type() const { return _type; }

    @property bool isString() { return _type == SettingType.STRING; }
    @property bool isInteger() { return _type == SettingType.INTEGER; }
    @property bool isUinteger() { return _type == SettingType.UINTEGER; }
    @property bool isFloating() { return _type == SettingType.FLOAT; }
    @property bool isObject() { return _type == SettingType.OBJECT; }
    @property bool isArray() { return _type == SettingType.ARRAY; }
    @property bool isBoolean() { return _type == SettingType.TRUE || _type == SettingType.FALSE; }
    @property bool isNull() { return _type == SettingType.NULL; }

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

    void apply(Setting settings) {
        if (settings.isObject) {
            foreach(key, value; settings.map) {
                this[key] = value;
            }
        }
    }

    /// deep copy of settings
    Setting clone() {
        Setting res = new Setting();
        res.clear(_type);
        final switch(_type) with(SettingType) {
            case STRING:
                res._store.str = _store.str;
                break;
            case ARRAY:
                res._store.array.copyFrom(_store.array);
                break;
            case OBJECT:
                if (_store.map) {
                    res._store.map = new SettingMap();
                    res._store.map.copyFrom(_store.map);
                }
                break;
            case INTEGER:
                res._store.integer = _store.integer;
                break;
            case UINTEGER:
                res._store.uinteger = _store.uinteger;
                break;
            case FLOAT:
                res._store.floating = _store.floating;
                break;
            case TRUE:
            case FALSE:
            case NULL:
                break;
        }
        res._changed = false;
        return res;
    }


    /// read as string value
    @property string str() {
        final switch(_type) with(SettingType) {
            case STRING:
                return _store.str;
            case INTEGER:
                return to!string(_store.integer);
            case UINTEGER:
                return to!string(_store.uinteger);
            case FLOAT:
                return to!string(cast(double)_store.floating);
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
    inout (string) strDef(inout (string) defValue) {
        final switch(_type) with(SettingType) {
            case STRING:
                return _store.str;
            case INTEGER:
                return to!string(_store.integer);
            case UINTEGER:
                return to!string(_store.uinteger);
            case FLOAT:
                return to!string(cast(double)_store.floating);
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

    /// returns items as string array
    @property string[] strArray() {
        final switch(_type) with(SettingType) {
            case STRING:
                return [_store.str];
            case INTEGER:
                return [to!string(_store.integer)];
            case UINTEGER:
                return [to!string(_store.uinteger)];
            case FLOAT:
                return [to!string(_store.floating)];
            case TRUE:
                return ["true"];
            case FALSE:
                return ["false"];
            case NULL:
                return null;
            case ARRAY:
            case OBJECT:
                string[] res;
                foreach(i; 0 .. length)
                    res ~= this[i].str;
                return res;
        }
    }
    /// sets string array
    @property string[] strArray(string[] list) {
        clear(SettingType.ARRAY);
        foreach(s; list) {
            this[length] = new Setting(s);
        }
        return list;
    }

    /// returns items as int array
    @property int[] intArray() {
        final switch(_type) with(SettingType) {
            case STRING:
            case INTEGER:
            case UINTEGER:
            case FLOAT:
            case TRUE:
            case FALSE:
                return [cast(int)integer];
            case NULL:
                return null;
            case ARRAY:
            case OBJECT:
                int[] res;
                foreach(i; 0 .. length)
                    res ~= cast(int)this[i].integer;
                return res;
        }
    }
    /// sets int array
    @property int[] intArray(int[] list) {
        clear(SettingType.ARRAY);
        foreach(s; list) {
            this[length] = new Setting(cast(long)s);
        }
        return list;
    }

    /// returns items as Setting array
    @property Setting[] array() {
        final switch(_type) with(SettingType) {
            case STRING:
            case INTEGER:
            case UINTEGER:
            case FLOAT:
            case TRUE:
            case FALSE:
                return [this];
            case NULL:
                return null;
            case ARRAY:
            case OBJECT:
                Setting[] res;
                foreach(i; 0 .. length)
                    res ~= this[i];
                return res;
        }
    }
    /// sets Setting array
    @property Setting[] array(Setting[] list) {
        clear(SettingType.ARRAY);
        foreach(s; list) {
            this[length] = s;
        }
        return list;
    }

    /// returns items as string[string] map
    @property string[string] strMap() {
        final switch(_type) with(SettingType) {
            case STRING:
            case INTEGER:
            case UINTEGER:
            case FLOAT:
            case TRUE:
            case FALSE:
            case NULL:
            case ARRAY:
                return null;
            case OBJECT:
                string[string] res;
                if (_store.map) {
                    foreach(key, value; _store.map.map)  {
                        Setting v = _store.map.get(value);
                        res[key] = v ? v.str : null;
                    }
                }
                return res;
        }
    }
    /// sets string[string] map
    @property string[string] strMap(string[string] list) {
        clear(SettingType.OBJECT);
        foreach(key, value; list) {
            this[key] = new Setting(value);
        }
        return list;
    }

    /// returns items as int[string] map
    @property int[string] intMap() {
        final switch(_type) with(SettingType) {
            case STRING:
            case INTEGER:
            case UINTEGER:
            case FLOAT:
            case TRUE:
            case FALSE:
            case NULL:
            case ARRAY:
                return null;
            case OBJECT:
                int[string] res;
                foreach(key, value; _store.map.map)
                    res[key] = cast(int)this[value].integer;
                return res;
        }
    }
    /// sets int[string] map
    @property int[string] intMap(int[string] list) {
        clear(SettingType.OBJECT);
        foreach(key, value; list) {
            this[key] = new Setting(cast(long)value);
        }
        return list;
    }

    /// returns items as Setting[string] map
    @property Setting[string] map() {
        final switch(_type) with(SettingType) {
            case STRING:
            case INTEGER:
            case UINTEGER:
            case FLOAT:
            case TRUE:
            case FALSE:
            case NULL:
            case ARRAY:
                return null;
            case OBJECT:
                Setting[string] res;
                foreach(key, value; _store.map.map)
                    res[key] = this[value];
                return res;
        }
    }
    /// sets Setting[string] map
    @property Setting[string] map(Setting[string] list) {
        clear(SettingType.OBJECT);
        foreach(key, value; list) {
            this[key] = value;
        }
        return list;
    }

    /// to iterate using foreach
    int opApply(int delegate(ref Setting)dg) {
        int result = 0;
        if (_type == SettingType.ARRAY) {
            for(int i = 0; i < _store.array.list.length; i++) {
                result = dg(_store.array.list[i]);
                if (result)
                    break;
            }
        } else if (_type == SettingType.OBJECT) {
            for(int i = 0; i < _store.map.list.length; i++) {
                result = dg(_store.map.list[i]);
                if (result)
                    break;
            }
        }
        return result;
    }

    /// to iterate over OBJECT using foreach(key, value; map)
    int opApply(int delegate(ref string, ref Setting)dg) {
        int result = 0;
        if (_type == SettingType.OBJECT) {
            for(int i = 0; i < _store.map.list.length; i++) {
                string key = _store.map.keyByIndex(i);
                result = dg(key, _store.map.list[i]);
                if (result)
                    break;
            }
        }
        return result;
    }

    /// to iterate using foreach_reverse
    int opApplyReverse(int delegate(ref Setting)dg) {
        int result = 0;
        if (_type == SettingType.ARRAY) {
            for(int i = cast(int)_store.array.list.length - 1; i >= 0; i--) {
                result = dg(_store.array.list[i]);
                if (result)
                    break;
            }
        } else if (_type == SettingType.OBJECT) {
            for(int i = cast(int)_store.map.list.length - 1; i >= 0; i--) {
                result = dg(_store.map.list[i]);
                if (result)
                    break;
            }
        }
        return result;
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
    // assign int[] value
    int[] opAssign(int[] value) {
        return (intArray = value);
    }
    // assign string[string] value
    string[string] opAssign(string[string] value) {
        return (strMap = value);
    }
    // assign string[] value
    string[] opAssign(string[] value) {
        return (strArray = value);
    }
    // assign int[string] value
    int[string] opAssign(int[string] value) {
        return (intMap = value);
    }
    // assign Setting[] value
    Setting[] opAssign(Setting[] value) {
        return (array = value);
    }
    // assign Setting[string] value
    Setting[string] opAssign(Setting[string] value) {
        return (map = value);
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

    /// returns setting by path like "editors/sourceEditor/tabSize", creates object tree "editors/sourceEditor" and object of specified type if part of path does not exist.
    Setting settingByPath(string path, SettingType type, bool createIfNotExist = true) {
        if (_type != SettingType.OBJECT)
            clear(SettingType.OBJECT);
        string part1, part2;
        if (splitKey(path, part1, part2)) {
            auto s = this[part1];
            if (!s) {
                s = new Setting();
                s.clear(SettingType.OBJECT);
                this[part1] = s;
            }
            return s.settingByPath(part2, type);
        } else {
            auto s = this[path];
            if (!s && createIfNotExist) {
                s = new Setting();
                s.clear(type);
                this[path] = s;
            }
            return s;
        }
    }

    /// get (or optionally create) object (map) by slash delimited path (e.g. key1/subkey2/subkey3)
    Setting objectByPath(string path, bool createIfNotExist = false) {
        if (type != SettingType.OBJECT) {
            if (!createIfNotExist)
                return null;
            // do we need to allow this conversion to object?
            clear(SettingType.OBJECT);
        }
        string part1, part2;
        if (splitKey(path, part1, part2)) {
            auto s = this[part1];
            if (!s) {
                if (!createIfNotExist)
                    return null;
                s = new Setting();
                s.clear(SettingType.OBJECT);
                this[part1] = s;
            }
            return s.objectByPath(part2, createIfNotExist);
        } else {
            auto s = this[path];
            if (!s) {
                if (!createIfNotExist)
                    return null;
                s = new Setting();
                s.clear(SettingType.OBJECT);
                this[path] = s;
            }
            return s;
        }
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
    /// returns string array item by key from map, returns null if not found
    string[] getStringArray(string key) {
        if (auto item = opIndex(key))
            return item.strArray();
        return null;
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
        void reserve(size_t size) {
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
            foreach(i; 0 .. level) {
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
                foreach(i; 0 .. _store.array.length) {
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

    /// save to file
    bool save(string filename, bool pretty = true) {
        try {
            write(filename, toJSON(pretty));
            return true;
        } catch (Exception e) {
            Log.e("exception while saving settings file: ", e);
            return false;
        }
    }

    private static struct JsonParser {
        string json;
        int pos;
        bool allowEol; // for SDL parsing where EOLs are meaningful
        void initialize(string s, bool allowEol) {
            json = s;
            pos = 0;
            this.allowEol = allowEol;
        }
        /// returns current char
        @property char peek() {
            return pos < json.length ? json[pos] : 0;
        }
        /// return fragment of text in current position
        @property string currentContext() {
            if (pos >= json.length)
                return "end of file";
            string res = json[pos .. $];
            if (res.length > 100)
                res.length = 100;
            return res;
        }
        /// skips current char, returns next one (or null if eof)
        @property char nextChar() {
            if (pos + 1 < json.length) {
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
            foreach(int i; 0 .. pos) {
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
            else if (pos >= json.length)
                context = "at end of file";
            throw new Exception("JSON parsing error in (" ~ to!string(line) ~ ":" ~ to!string(col) ~ ") " ~ context ~ ": " ~ msg);
        }
        static bool isAlpha(char ch) {
            static import std.ascii;
            return std.ascii.isAlpha(ch) || ch == '_';
        }
        static bool isAlNum(char ch) {
            static import std.ascii;
            return std.ascii.isAlphaNum(ch) || ch == '_';
        }
        /// skip spaces and comments, return next available character
        @property char skipSpaces() {
            static import std.ascii;
            for(;pos < json.length;pos++) {
                char ch = json[pos];
                char nextch = pos + 1 < json.length ? json[pos + 1] : 0;
                if (allowEol && ch == '\n')
                    break;
                if (ch == '#' || (ch == '/' && nextch == '/') || (ch == '-' && nextch == '-')) {
                    // skip one line comment // or # or --
                    pos++;
                    for(;pos < json.length;pos++) {
                        ch = json[pos];
                        if (ch == '\n')
                            break;
                    }
                    if (allowEol && ch == '\n')
                        break;
                    continue;
                } else if (ch == '/' && nextch == '*') {
                    // skip multiline /* */ comment
                    pos += 2;
                    for(;pos < json.length;pos++) {
                        ch = json[pos];
                        nextch = pos + 1 < json.length ? json[pos + 1] : 0;
                        if (ch == '*' && nextch == '/') {
                            pos += 2;
                            break;
                        }
                    }
                    continue;
                } else if (ch == '\\' && nextch == '\n') {
                    // continue to next line
                    pos += 2;
                    continue;
                }
                if (!std.ascii.isWhite(ch))
                    break;
            }
            return peek;
        }

        string parseUnicodeChar() {
            if (pos >= json.length - 3)
                error("unexpected end of file while parsing unicode character entity inside string");
            dchar ch = 0;
            foreach(i; 0 .. 4) {
                uint d = parseHexDigit(nextChar);
                if (d == uint.max)
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
            char quoteChar = ch;
            if (ch != '\"' && ch != '`')
                error("cannot parse string");
            for (;;) {
                ch = nextChar;
                if (!ch)
                    error("unexpected end of file while parsing string");
                if (ch == quoteChar) {
                    nextChar;
                    return cast(string)res;
                }
                if (ch == '\\' && quoteChar != '`') {
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
                        case '/':
                            res ~= '/';
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
        }
        @property string parseIdent() {
            char ch = peek;
            if (ch == '\"' || ch == '`') {
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
                error("cannot parse ident");
            return cast(string)res;
        }
        bool parseKeyword(string ident) {
            // returns true if parsed ok
            if (pos + ident.length > json.length)
                return false;
            foreach(i; 0 .. ident.length) {
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
            import std.ascii : isDigit;
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
        int startPos = parser.pos;
        //Log.v("parseMap at context ", parser.currentContext);
        char ch = parser.peek;
        parser.nextChar; // skip initial {
        if (ch != '{') {
            Log.e("expected { at ", parser.currentContext);
        }
        for(;;) {
            ch = parser.skipSpaces;
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
            //Log.v("context before skipSpaces: ", parser.currentContext);
            ch = parser.skipSpaces;
            //Log.v("context after skipSpaces: ", parser.currentContext);
            if (ch == ',') {
                parser.nextChar;
                parser.skipSpaces;
            } else if (ch != '}') {
                parser.error("unexpected character when waiting for , or } while parsing object; { position is "~ to!string(startPos));
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
        static import std.ascii;
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
        } else if (ch == '-' || std.ascii.isDigit(ch)) {
            parser.parseNumber(this);
        } else {
            parser.error("cannot parse JSON value");
        }
        return this;
    }

    void parseJSON(string s) {
        clear(SettingType.NULL);
        JsonParser parser;
        parser.initialize(convertEols(s), false);
        parseJSON(parser);
    }

    /// SDL identifiers to be converted to JSON array (name should be changed, with 's' suffix)
    private static immutable (string[]) identsToConvertToArrays = [
        "subPackage", // in JSON it's subPackages
        "configuration", // in JSON it's configurations
        "buildType", // in JSON it's buildTypes
    ];

    /// SDL identifiers to be converted to JSON object (name should be changed, with 's' suffix)
    private static immutable (string[]) identsToConvertToObjects = [
        "dependency", // in JSON it's dependencies
        "subConfiguration", // in JSON it's subConfigurations
    ];

    /// SDL identifiers of JSON array w/o name conversion
    private static immutable (string[]) arrayIdents = [
        "authors",
        "x:ddoxFilterArgs",
        "sourcePaths",
        "importPaths",
        "buildOptions",
        "libs",
        "sourceFiles",
        "buildRequirements",
        "excludedSourceFiles",
        "copyFiles",
        "versions",
        "debugVersions",
        "stringImportPaths",
        "preGenerateCommands",
        "postGenerateCommands",
        "preBuildCommands",
        "postBuildCommands",
        "dflags",
        "lflags",
        "platforms",
    ];

    protected bool isArrayItemNameIdent(string ident) {
        foreach(s; identsToConvertToArrays) {
            if (ident == s)
                return true;
        }
        return false;
    }

    protected bool isObjectItemNameIdent(string ident) {
        foreach(s; identsToConvertToObjects) {
            if (ident == s)
                return true;
        }
        return false;
    }

    protected bool isArrayIdent(string ident) {
        foreach(s; arrayIdents) {
            if (ident == s)
                return true;
        }
        return false;
    }

    private void skipEol(ref JsonParser parser) {
        char ch = parser.skipSpaces;
        if (ch == 0)
            return;
        if (ch == '\n') {
            parser.nextChar;
            return;
        }
        parser.error("end of line expected");
    }

    private void parseSDLAttributes(ref JsonParser parser, bool ignorePlatformAttribute = true) {
        string attrName;
        Setting attrValue;
        for (;;) {
            char ch = parser.skipSpaces;
            if (ch == 0)
                return;
            if (ch == '\n') {
                parser.nextChar;
                return;
            }
            if (!JsonParser.isAlpha(ch))
                parser.error("attr=value expected");
            attrName = parser.parseIdent();
            attrValue = new Setting();
            ch = parser.skipSpaces;
            if (ch != '=')
                parser.error("= expected after " ~ attrName);
            ch = parser.nextChar; // skip '='
            ch = parser.skipSpaces;
            if (ch == '\"' || ch == '`') {
                // string value
                string v = parser.parseString;
                attrValue = v;
                if (!ignorePlatformAttribute || attrName != "platform")
                    this[attrName] = attrValue;
                continue;
            }
            if (JsonParser.isAlpha(ch)) {
                string v = parser.parseIdent;
                if (v == "true" || v == "on") {
                    attrValue = true;
                    this[attrName] = attrValue;
                    continue;
                }
                if (v == "false" || v == "off") {
                    attrValue = false;
                    this[attrName] = attrValue;
                    continue;
                }
                parser.error("unexpected attribue value " ~ v);
            }
            parser.error("only string and boolean values supported for SDL attributes now");
        }
    }

    // peek platform="value" from current line
    private string peekSDLPlatformAttribute(ref JsonParser parser) {
        string res = null;
        int oldpos = parser.pos; // save position
        for(;;) {
            char ch = parser.skipSpaces;
            if (ch == 0 || ch == '\n' || ch == '{' || ch == '}')
                break;
            if (parser.isAlpha(ch)) {
                string ident = parser.parseIdent;
                ch = parser.skipSpaces;
                if (ch != '=')
                    continue;
                parser.nextChar;
                ch = parser.skipSpaces;
                string attrvalue;
                if (ch == '\"' || ch == '`')
                    attrvalue = parser.parseString;
                else if (parser.isAlpha(ch))
                    attrvalue = parser.parseIdent;
                if (ident == "platform") {
                    res = attrvalue;
                    break;
                }
            } else if (ch == '\"' || ch == '`') {
                string str = parser.parseString;
            } else if (ch == '=') {
                parser.nextChar;
                continue;
            } else {
                break;
            }
        }
        parser.pos = oldpos; // restore position
        return res;
    }

    private void skipPlatformAttribute(ref JsonParser parser) {
        char ch = parser.skipSpaces;
        int oldpos = parser.pos;
        if (parser.isAlpha(ch)) {
            string attrName = parser.parseIdent;
            if (attrName == "platform") {
                ch = parser.skipSpaces;
                if (ch == '=') {
                    parser.nextChar;
                    ch = parser.skipSpaces;
                    string value = parser.parseString;
                    return; // skipped platform attribute
                }
            }
        }
        // no changes
        parser.pos = oldpos;
    }

    private Setting parseSDL(ref JsonParser parser, bool insideCurly = false) {
        //static import std.ascii;
        for (;;) {
            // looking for ident
            char ch = parser.skipSpaces;
            if (ch == 0)
                break;
            if (ch == '\n') {
                parser.nextChar; // skip
                continue;
            }
            if (ch == '}') {
                if (!insideCurly)
                    parser.error("unexpected }");
                parser.nextChar; // skip
                return this;
            }
            string ident = parser.parseIdent();
            if (!ident.length)
                parser.error("identifier expected");
            ch = parser.skipSpaces;
            string platform = peekSDLPlatformAttribute(parser);
            bool isArrayConvName = isArrayItemNameIdent(ident);
            bool isObjectConvName= isObjectItemNameIdent(ident);
            bool isArrayName = isArrayIdent(ident) || isArrayConvName;
            if (isArrayConvName || isObjectConvName) {
                import std.algorithm : endsWith;
                if (ident.endsWith("y"))
                    ident = ident[0 .. $-1] ~ "ies"; // e.g. dependency->dependencies
                else if (!ident.endsWith("s"))
                    ident = ident ~ "s"; // a.g. author->authors
            }
            if (platform.length)
                ident = ident ~ "-" ~ platform;
            Setting valueObj = this[ident]; // looking for existing object
            if (!valueObj) { // create if not exist
                valueObj = new Setting();
                this[ident] = valueObj;
            }
            if (isArrayName) {
                if (!valueObj.isArray) {
                    // convert to array
                    valueObj.clear(SettingType.ARRAY);
                }
            }
            // now we have identifier
            if (ch == '\"' || ch == '`') {
                string value = parser.parseString;
                skipPlatformAttribute(parser);
                ch = parser.skipSpaces;
                if (ch == '{') {
                    /*
                        ident "name" {
                            //...
                        }
                    */
                    parser.nextChar; // skip {
                    Setting obj = isArrayName ? new Setting() : valueObj;
                    obj["name"] = value;
                    obj.parseSDL(parser, true);
                    if (isArrayName)
                        valueObj.array = valueObj.array ~ obj;
                    continue;
                }
                if (JsonParser.isAlpha(ch)) {
                    // ident=value pairs after "name"
                    Setting obj = (isArrayName || isObjectConvName) ? new Setting() : valueObj;
                    if (!isObjectConvName)
                        obj["name"] = value;
                    obj.parseSDLAttributes(parser);
                    if (isArrayName)
                        valueObj.array = valueObj.array ~ obj;
                    else if (isObjectConvName)
                        valueObj[value] = obj;
                    continue;
                }
                if (isArrayName) {
                    Setting[] values = valueObj.array;
                    Setting svalue = new Setting();
                    svalue = value;
                    values ~= svalue;
                    for (;;) {
                        skipPlatformAttribute(parser);
                        ch = parser.skipSpaces;
                        if (ch == '\n' || ch == 0)
                            break;
                        if (ch == '\"' || ch == '`') {
                            value = parser.parseString;
                            svalue = new Setting();
                            svalue = value;
                            values ~= svalue;
                        } else
                            parser.error("array of strings expected");
                    }
                    valueObj.array = values;
                } else {
                    if (isObjectConvName) {
                        string svalue = parser.parseString;
                        valueObj[value] = svalue;
                    } else {
                        valueObj = value;
                    }
                }
                skipPlatformAttribute(parser);
                skipEol(parser);
                continue;
            } else if (ch == '{') {
                // object
                parser.nextChar; // skip {
                if (isArrayName) {
                    Setting[] values = valueObj.array;
                    Setting item = new Setting();
                    item.clear(SettingType.OBJECT);
                    item.parseSDL(parser, true);
                    values ~= item;
                    valueObj.array = values;
                } else {
                    valueObj.parseSDL(parser, true);
                }
                continue;
            } else {
                parser.error("cannot parse SDL value");
            }
        }
        if (insideCurly)
            parser.error("} expected");
        return this;
    }

    void parseSDL(string s) {
        clear(SettingType.NULL);
        JsonParser parser;
        parser.initialize(convertEols(s), true);
        parseSDL(parser);
    }

    /// convert CR LF, LF CR, LF, CR to '\n' eol format
    static string convertEols(string src) {
        char[] res;
        res.assumeSafeAppend;
        for (int i = 0; i < src.length; i++) {
            char ch = src[i];
            if (ch == '\r' || ch == '\n') {
                char nextch = i + 1 < src.length ? src[i + 1] : 0;
                if (nextch != ch && (nextch == '\r' || nextch == '\n')) {
                    // pair \r\n or \n\r
                    res ~= '\n';
                    i++;
                } else {
                    // single \r or \n
                    res ~= '\n';
                }
            } else {
                res ~= ch;
            }
        }
        return res.dup;
    }

    /// load from file; autodetect SDL format using ".sdl" and ".SDL" extension mask; returns true if loaded successfully
    bool load(string filename) {
        try {
            import std.algorithm : endsWith;
            string s = readText(filename);
            if (filename.endsWith(".sdl") || filename.endsWith(".SDL"))
                parseSDL(s);
            else
                parseJSON(s);
            return true;
        } catch (Exception e) {
            // Failed
            Log.e("exception while parsing json: ", e);
            return false;
        }
    }
}
