module dlangui.core.settings;

import std.range;

/// access to settings
interface Settings {
    /// returns true if settings object has specified key
    bool hasKey(string key);
    /// returns reference to parent settings
    @property Settings parent();
    /// get string by key, returns defValue if no such key
    string getString(string key, string defValue);
    /// set string for key, returns old value or null if not set
    string setString(string key, string value);
    /// remove setting, returns true if removed, false if no such key
    bool remove(string key);
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
    override string getString(string key, string defValue) {
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
}
