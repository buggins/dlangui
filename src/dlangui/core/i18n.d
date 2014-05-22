// Written in the D programming language.

/**
This module contains internationalization support implementation.

Translation files contain of simple key=value pair lines.

STRING_RESOURCE_ID=Translation text.

Supports fallback to another translation file (e.g. default language).



Synopsis:

----
import dlangui.core.i18n;

// use global i18n object to get translation for string ID
dstring translated = i18n.get("STR_FILE_OPEN");

// UIString type can hold either string resource id or dstring raw value.
UIString text;

// assign resource id as string
text = "ID_FILE_EXIT";
// or assign raw value as dstring
text = "some text"d;

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
import std.utf;

/// container for UI string - either raw value or string resource ID
struct UIString {
    /// if not null, use it, otherwise lookup by id
    private dstring _value;
    /// id to find value in translator
    private string _id;

    /// create string with i18n resource id
    this(string id) {
        _id = id;
    }
    /// create string with raw value
    this(dstring value) {
        _value = value;
    }



    @property string id() const { return _id; }
    @property void id(string ID) {
        _id = ID;
        _value = null;
    }
    /// get value (either raw or translated by id)
    @property dstring value() const { 
        if (_value !is null)
            return _value;
        if (_id is null)
            return null;
        // translate ID to dstring
        return i18n.get(_id); 
    }
    /// set raw value
    @property void value(dstring newValue) {
        _value = newValue;
    }
    /// assign raw value
    ref UIString opAssign(dstring rawValue) {
        _value = rawValue;
        _id = null;
        return this;
    }
    /// assign ID
    ref UIString opAssign(string ID) {
        _id = ID;
        _value = null;
        return this;
    }
    /// default conversion to dstring
    alias value this;
}

public __gshared UIStringTranslator i18n = new UIStringTranslator();
//static shared this() {
//    i18n = new UIStringTranslator();
//}

class UIStringTranslator {
    private UIStringList _main;
    private UIStringList _fallback;
    private string[] _resourceDirs;
    /// get i18n resource directory
    @property string[] resourceDirs() { return _resourceDirs; }
    /// set i18n resource directory
    @property void resourceDirs(string[] dirs) { _resourceDirs = dirs; }
    /// looks for i18n directory inside one of passed dirs, and uses first found as directory to read i18n files from
    string[] findTranslationsDir(string[] dirs ...) {
        _resourceDirs.length = 0;
        import std.file;
        foreach(dir; dirs) {
            string path = appendPath(dir, "i18n/");
            if (exists(path) && isDir(path)) {
				Log.i("Adding i18n dir ", path);
                _resourceDirs ~= path;
            }
        }
        return _resourceDirs;
    }

    /// convert resource path - append resource dir if necessary
    string[] convertResourcePaths(string filename) {
        if (filename is null)
            return null;
        bool hasPathDelimiters = false;
        foreach(char ch; filename)
            if (ch == '/' || ch == '\\')
                hasPathDelimiters = true;
        string[] res;
        if (!hasPathDelimiters && _resourceDirs.length) {
            foreach (dir; _resourceDirs)
                res ~= dir ~ filename;
        } else {
            res ~= filename;
        }
        return res;
    }

    this() {
        _main = new UIStringList();
        _fallback = new UIStringList();
    }
    /// load translation file(s)
    bool load(string mainFilename, string fallbackFilename = null) {
        _main.clear();
        _fallback.clear();
        bool res = _main.load(convertResourcePaths(mainFilename));
        if (fallbackFilename !is null) {
            res = _fallback.load(convertResourcePaths(fallbackFilename)) || res;
        }
        return res;
    }
    /// translate string ID to string (returns "UNTRANSLATED: id" for missing values)
    dstring get(string id) {
        if (id is null)
            return null;
        dstring s = _main.get(id);
        if (s !is null)
            return s;
        s = _fallback.get(id);
        if (s !is null)
            return s;
        return "UNTRANSLATED: "d ~ toUTF32(id);
    }
}

/// UI string translator
class UIStringList {
    private dstring[string] _map;
    /// remove all items
    void clear() {
        _map.clear();
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
    bool load(std.stream.InputStream stream) {
        dlangui.core.linestream.LineStream lines = dlangui.core.linestream.LineStream.create(stream, "");
        int count = 0;
        for (;;) {
            dchar[] s = lines.readLine();
            if (s is null)
                break;
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

    /// load strings from file (utf8, id=value lines)
    bool load(string[] filenames) {
        clear();
        bool res = false;
        foreach(filename; filenames) {
            import std.stream;
            import std.file;
            try {
                Log.d("Loading string resources from file ", filename);
                if (!exists(filename) || !isFile(filename)) {
                    Log.e("File does not exist: ", filename);
                    continue;
                }
	            std.stream.File f = new std.stream.File(filename);
                scope(exit) { f.close(); }
                res = load(f) || res;
            } catch (StreamFileException e) {
                Log.e("Cannot read string resources from file ", filename);
            }
        }
        return res;
    }
}
