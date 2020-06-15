// Written in the D programming language.

/**
This module contains UI internationalization support implementation.

UIString struct provides string container which can be either plain unicode string or id of string resource.

Translation strings are being stored in translation files, consisting of simple key=value pair lines:
---
STRING_RESOURCE_ID=Translation text 1
ANOTHER_STRING_RESOURCE_ID=Translation text 2
---

Supports fallback to another translation file (e.g. default language).

If string resource is not found neither in main nor fallback translation files, UNTRANSLATED: RESOURCE_ID will be returned.

String resources must be placed in i18n subdirectory inside one or more resource directories (set using Platform.instance.resourceDirs
property on application initialization).

File names must be language code with extension .ini (e.g. en.ini, fr.ini, es.ini)

If several files for the same language are found in (different directories) their content will be merged. It's useful to merge string resources
from DLangUI framework with resources of application.

Set interface language using Platform.instance.uiLanguage in UIAppMain during initialization of application settings:
---
Platform.instance.uiLanguage = "en";

/// create by id - string STR_MENU_HELP="Help" must be added to translation resources
UIString help1 = UIString.fromId("STR_MENU_HELP");
/// create by id and fallback string
UIString help2 = UIString.fromId("STR_MENU_HELP", "Help"d);
/// create from raw string
UIString help3 = UIString.fromRaw("Help"d);

---


Synopsis:

----
import dlangui.core.i18n;

// use global i18n object to get translation for string ID
dstring translated = i18n.get("STR_FILE_OPEN");
// as well, you can specify fallback value - to return if translation is not found
dstring translated = i18n.get("STR_FILE_OPEN", "Open..."d);

// UIString type can hold either string resource id or dstring raw value.
UIString text;

// assign resource id as string (will remove dstring value if it was here)
text = "ID_FILE_EXIT";
// or assign raw value as dstring (will remove id if it was here)
text = "some text"d;
// assign both resource id and fallback value - to use if string resource is not found
text = UIString("ID_FILE_EXIT", "Exit"d);

// i18n.get() will automatically be invoked when getting UIString value (e.g. using alias this).
dstring translated = text;

----

Copyright: Vadim Lopatin, 2014
License:   Boost License 1.0
Authors:   Vadim Lopatin, coolreader.org@gmail.com
*/
module dlangui.core.i18n;

import dlangui.core.types;
import dlangui.core.logger;
import dlangui.core.files;
import dlangui.graphics.resources;
private import dlangui.core.linestream;
private import std.utf : toUTF32;
private import std.algorithm;
private import std.string;
private import std.file;

/**
   Container for UI string - either raw value or string resource ID

   Set resource id (string) or plain unicode text (dstring) to it, and get dstring.

*/
struct UIString {
    /** if not null, use it, otherwise lookup by id */
    private dstring _value;
    /** id to find value in translator */
    private string _id;

    deprecated("use UIString.fromId() instead")
    /** create string with i18n resource id */
    this(string id) {
        _id = id;
    }

    /** create string with raw value; deprecated, use fromRaw() instead */
    deprecated("use UIString.fromRaw() instead")
    this(dstring value) {
        _value = value;
    }
    /** create string with resource id and raw value as fallback for missing translations */
    this(string id, dstring fallbackValue) {
        _id = id;
        _value = fallbackValue;
    }


    /// Returns string resource id
    @property string id() const { return _id; }
    /// Sets string resource id
    @property void id(string ID) {
        _id = ID;
        _value = null;
    }
    /** Get value (either raw or translated by id) */
    @property dstring value() const {
        if (_id !is null) // translate ID to dstring
            return i18n.get(_id, _value); // get from resource, use _value as fallback
        return _value;
    }
    /** Set raw value using property */
    @property void value(dstring newValue) {
        _value = newValue;
    }
    /** Assign raw value */
    ref UIString opAssign(dstring rawValue) return {
        _value = rawValue;
        _id = null;
        return this;
    }
    /** Assign string resource id */
    ref UIString opAssign(string ID) return {
        _id = ID;
        _value = null;
        return this;
    }

    /// returns true if string is empty: neither resource nor string is assigned
    bool empty() const {
        return _value.length == 0 && _id.length == 0;
    }

    /// create UIString from id - will be translated; fallback value can be provided for cases if translation is not found
    static UIString fromId(string ID, dstring fallback = null) {
        return UIString(ID, fallback);
    }

    /// Create UIString from raw utf32 string value - will not be translated
    static UIString fromRaw(dstring rawValue) {
        return UIString(null, rawValue);
    }

    /// Create UIString from raw utf8 string value - will not be translated
    static UIString fromRaw(string rawValue) {
        return UIString(null, toUTF32(rawValue));
    }

    /** Default conversion to dstring */
    alias value this;
}

/**
    UIString item collection

    Based on array.
*/
struct UIStringCollection {
    private UIString[] _items;
    private int _length;

    /** Returns number of items */
    @property int length() const { return _length; }

    /** Returns true if collection is empty */
    @property bool empty() const { return _length == 0; }

    /** Slice */
    UIString[] opIndex() {
        return _items[0 .. _length];
    }
    /** Slice */
    UIString[] opSlice() {
        return _items[0 .. _length];
    }
    /** Slice */
    UIString[] opSlice(size_t start, size_t end) {
        return _items[start .. end];
    }
    /** Read item by index */
    UIString opIndex(size_t index) const {
        return _items[index];
    }
    /** Modify item by index */
    UIString opIndexAssign(UIString value, size_t index) {
        _items[index] = value;
        return _items[index];
    }
    /** Return unicode string for item by index */
    dstring get(size_t index) const {
        return _items[index].value;
    }
    /** Assign UIStringCollection */
    void opAssign(ref UIStringCollection items) {
        clear();
        addAll(items);
    }
    /** Append UIStringCollection */
    void addAll(ref UIStringCollection items) {
        foreach (UIString item; items) {
            add(item);
        }
    }
    /** Assign array of string resource IDs */
    void opAssign(string[] items) {
        clear();
        addAll(items);
    }
    /** Assign array of unicode strings */
    void opAssign(dstring[] items) {
        clear();
        addAll(items);
    }
    /** Assign array of UIString */
    void opAssign(UIString[] items) {
        clear();
        addAll(items);
    }
    /** Assign array of StringListValue */
    void opAssign(StringListValue[] items) {
        clear();
        addAll(items);
    }
    /** Append array of unicode strings */
    void addAll(dstring[] items) {
        foreach (item; items) {
            add(item);
        }
    }
    /** Append array of unicode strings */
    void addAll(string[] items) {
        foreach (item; items) {
            add(item);
        }
    }
    /** Append array of unicode strings */
    void addAll(UIString[] items) {
        foreach (item; items) {
            add(item);
        }
    }
    /** Append array of unicode strings */
    void addAll(StringListValue[] items) {
        foreach (item; items) {
            add(item);
        }
    }
    /** Remove all items */
    void clear() {
        _items.length = 0;
        _length = 0;
    }
    /** Insert resource id item into specified position */
    void add(string item, int index = -1) {
        UIString s;
        s = item;
        add(s, index);
    }
    /** Insert unicode string item into specified position */
    void add(dstring item, int index = -1) {
        UIString s;
        s = item;
        add(s, index);
    }
    /** Insert StringListValue.label item into specified position */
    void add(StringListValue item, int index = -1) {
        add(item.label, index);
    }
    /** Insert UIString item into specified position */
    void add(UIString item, int index = -1) {
        if (index < 0 || index > _length)
            index = _length;
        if (_items.length < _length + 1) {
            if (_items.length < 8)
                _items.length = 8;
            else
                _items.length = _items.length * 2;
        }
        for (size_t i = _length; i > index; i--) {
            _items[i] = _items[i + 1];
        }
        _items[index] = item;
        _length++;
    }
    /** Remove item with specified index */
    void remove(int index) {
        if (index < 0 || index >= _length)
            return;
        foreach(i; index .. _length - 1)
            _items[i] = _items[i + 1];
        _length--;
    }
    /** Return index of first item with specified text or -1 if not found. */
    int indexOf(dstring str) const {
        foreach(i; 0 .. _length) {
            if (_items[i].value.equal(str))
                return i;
        }
        return -1;
    }
    /** Return index of first item with specified string resource id or -1 if not found. */
    int indexOf(string strId) const {
        foreach(i; 0 .. _length) {
            if (_items[i].id.equal(strId))
                return i;
        }
        return -1;
    }
    /** Return index of first item with specified string or -1 if not found. */
    int indexOf(UIString str) const {
        if (str.id !is null)
            return indexOf(str.id);
        return indexOf(str.value);
    }
}

/// string values string list adapter - each item can have optional string or integer id, and optional icon resource id
struct StringListValue {
    /// integer id for item
    int intId;
    /// string id for item
    string stringId;
    /// icon resource id
    string iconId;
    /// label to show for item
    UIString label;

    this(string id, dstring name, string iconId = null) {
        this.stringId = id;
        this.label.value = name;
        this.iconId = iconId;
    }
    this(string id, string nameResourceId, string iconId = null) {
        this.stringId = id;
        this.label.id = nameResourceId;
        this.iconId = iconId;
    }
    this(int id, dstring name, string iconId = null) {
        this.intId = id;
        this.label.value = name;
        this.iconId = iconId;
    }
    this(int id, string nameResourceId, string iconId = null) {
        this.intId = id;
        this.label.id = nameResourceId;
        this.iconId = iconId;
    }
    this(dstring name, string iconId = null) {
        this.label.value = name;
        this.iconId = iconId;
    }
}

/** UI Strings internationalization translator */
class UIStringTranslator {

    private UIStringList _main;
    private UIStringList _fallback;
    private string[] _resourceDirs;

    /** Looks for i18n directory inside one of passed dirs, and uses first found as directory to read i18n files from */
    void findTranslationsDir(string[] dirs ...) {
        _resourceDirs.length = 0;
        foreach(dir; dirs) {
            string path = appendPath(dir, "i18n/");
            if (exists(path) && isDir(path)) {
                Log.i("Adding i18n dir ", path);
                _resourceDirs ~= path;
            }
        }
    }

    /** Convert resource path - append resource dir if necessary */
    string[] convertResourcePaths(string filename) {
        if (filename is null)
            return null;
        bool hasPathDelimiters = false;
        foreach(char ch; filename)
            if (ch == '/' || ch == '\\')
                hasPathDelimiters = true;
        string[] res;
        if (!hasPathDelimiters) {
            string fn = EMBEDDED_RESOURCE_PREFIX ~ "std_" ~ filename;
            string s = cast(string)loadResourceBytes(fn);
            if (s)
                res ~= fn;
            fn = EMBEDDED_RESOURCE_PREFIX ~ filename;
            s = cast(string)loadResourceBytes(fn);
            if (s)
                res ~= fn;
            foreach (dir; _resourceDirs) {
                fn = dir ~ filename;
                if (exists(fn) && isFile(fn))
                    res ~= fn;
            }
        } else {
            // full path
            res ~= filename;
        }
        return res;
    }

    /// create empty translator
    this() {
        _main = new UIStringList();
        _fallback = new UIStringList();
    }

    /** Load translation file(s) */
    bool load(string mainFilename, string fallbackFilename = null) {
        _main.clear();
        _fallback.clear();
        bool res = _main.load(convertResourcePaths(mainFilename));
        if (fallbackFilename !is null) {
            res = _fallback.load(convertResourcePaths(fallbackFilename)) || res;
        }
        return res;
    }

    /** Translate string ID to string (returns "UNTRANSLATED: id" for missing values) */
    dstring get(string id, dstring fallbackValue = null) {
        if (id is null)
            return null;
        dstring s = _main.get(id);
        if (s !is null)
            return s;
        s = _fallback.get(id);
        if (s !is null)
            return s;
        if (fallbackValue.length > 0)
            return fallbackValue;
        return "UNTRANSLATED: "d ~ toUTF32(id);
    }
}

/** UI string translator */
private class UIStringList {
    private dstring[string] _map;
    /// remove all items
    void clear() {
        _map.destroy();
    }
    /// set item value
    void set(string id, dstring value) {
        _map[id] = value;
    }
    /// get item value, null if translation is not found for id
    dstring get(string id) const {
        if (id in _map)
            return _map[id];
        return null;
    }
    /// load strings from stream
    bool load(dstring[] lines) {
        int count = 0;
        foreach (s; lines) {
            int eqpos = -1;
            int firstNonspace = -1;
            int lastNonspace = -1;
            for (int i = 0; i < s.length; i++)
                if (s[i] == '=') {
                    eqpos = i;
                    break;
                } else if (s[i] != ' ' && s[i] != '\t') {
                    if (firstNonspace == -1)
                        firstNonspace = i;
                    lastNonspace = i;
                }
            if (eqpos > 0 && firstNonspace != -1) {
                string id = toUTF8(s[firstNonspace .. lastNonspace + 1]);
                dstring value = s[eqpos + 1 .. $].dup;
                set(id, value);
                count++;
            }
        }
        return count > 0;
    }

    /// convert to utf32 and split by lines (detecting line endings)
    static dstring[] splitLines(string src) {
        dstring dsrc = toUTF32(src);
        dstring[] split1 = split(dsrc, "\r\n");
        dstring[] split2 = split(dsrc, "\r");
        dstring[] split3 = split(dsrc, "\n");
        if (split1.length >= split2.length && split1.length >= split3.length)
            return split1;
        if (split2.length > split3.length)
            return split2;
        return split3;
    }

    /// load strings from file (utf8, id=value lines)
    bool load(string[] filenames) {
        clear();
        bool res = false;
        foreach(filename; filenames) {
            try {
                debug Log.d("Loading string resources from file ", filename);
                string s = cast(string)loadResourceBytes(filename);
                if (!s) {
                    Log.e("Cannot load i18n resource from file ", filename);
                    continue;
                }
                res = load(splitLines(s)) || res;
            } catch (Exception e) {
                Log.e("Cannot read string resources from file ", filename);
            }
        }
        return res;
    }
}

//==============================================================
// Global Shared objects

/** Global UI translator object */
private UIStringTranslator _i18n;

@property UIStringTranslator i18n() {
    if (!_i18n) {
        _i18n = new UIStringTranslator();
    }
    return _i18n;
}
