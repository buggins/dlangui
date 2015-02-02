module dlangui.core.settings;

import std.range;
import std.algorithm;
import std.conv;

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
    /// get bool by key, returns defValue if no such key
    bool getBool(string key, bool defValue = false);
    /// set bool for key, returns old value or null if not set
    bool setBool(string key, bool value);
    /// get bool by key, returns defValue if no such key
    int getInt(string key, int defValue = 0);
    /// set bool for key, returns old value or null if not set
    int setInt(string key, int value);
    /// remove setting, returns true if removed, false if no such key
    bool remove(string key);
    /// child subsettings access
    Settings child(string key, bool createIfNotExist = false);
}

/// implementation of settings object
class SettingsImpl : Settings {
    protected SettingsImpl _parent;
    protected SettingsImpl[string] _children;
    protected string[string] _values;
    
    this(SettingsImpl parent = null) {
        _parent = parent;
    }

    /// returns reference to parent settings
    override @property Settings parent() {
        return _parent;
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
    /// get string by key, returns defValue if no such key
    override string getString(string key, string defValue = null) {
        string part1, part2;
        if (splitKey(key, part1, part2)) {
            // path
            auto p = (part1 in _children);
            if (!p)
                return defValue;
            return p.getString(part2, defValue);
        } else {
            auto p = (key in _values);
            if (p)
                return *p;
            return defValue;
        }
    }
    /// set string for key, returns old value or null if not set
    override string setString(string key, string value) {
        string part1, part2;
        if (splitKey(key, part1, part2)) {
            // path
            auto p = (part1 in _children);
            if (!p) {
                SettingsImpl newItem = new SettingsImpl(this);
                _children[part1] = newItem;
                return newItem.setString(part2, value);
            } else {
                return (*p).setString(part2, value);
            }
        } else {
            auto p = (key in _values);
            string res;
            if (p)
                res = *p;
            _values[key] = value;
            return res;
        }
    }
    /// returns true if settings object has specified key
    override bool hasKey(string key) {
        string part1, part2;
        if (splitKey(key, part1, part2)) {
            auto p = (part1 in _children);
            if (!p) {
                return false;
            } else {
                return (*p).hasKey(part2);
            }
        } else {
            return (key in _values) !is null;
        }
    }

    override Settings child(string key, bool createIfNotExist = false) {
        string part1, part2;
        if (splitKey(key, part1, part2)) {
            auto p = (part1 in _children);
            if (!p) {
                if (!createIfNotExist)
                    return null;
                SettingsImpl newItem = new SettingsImpl(this);
                _children[part1] = newItem;
                return newItem.child(part2, createIfNotExist);
            } else {
                return (*p).child(part2);
            }
        } else {
            auto p = (key in _children);
            if (!p) {
                if (!createIfNotExist)
                    return null;
                SettingsImpl newItem = new SettingsImpl(this);
                _children[key] = newItem;
                return newItem;
            } else {
                return (*p);
            }
        }
    }


    /// remove setting, returns true if removed, false if no such key
    bool remove(string key) {
        string part1, part2;
        if (splitKey(key, part1, part2)) {
            auto p = (part1 in _children);
            if (!p) {
                return false;
            } else {
                return (*p).remove(part2);
            }
        } else {
            return _values.remove(key);
        }
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
    bool getBool(string key, bool defValue = false) {
        return parseBool(getString(key, ""), defValue);
    }
    /// set bool for key, returns old value or null if not set
    bool setBool(string key, bool value) {
        return parseBool(setString(key, value ? "1" : "0"), false);
    }

    /// get bool by key, returns defValue if no such key
    int getInt(string key, int defValue = 0) {
        return parseInt(getString(key, ""), defValue);
    }
    /// set bool for key, returns old value or null if not set
    int setInt(string key, int value) {
        return parseInt(setString(key, to!string(value)), false);
    }
}
