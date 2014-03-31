module dlangui.core.i18n;

import dlangui.core.logger;
import std.utf;

/// container for UI string - either raw value or string resource ID
struct UIString {
    /// if not null, use it, otherwise lookup by id
    dstring _value;
    /// id to find value in translator
    string _id;
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
    private string _resourceDir;
    /// get i18n resource directory
    @property string resourceDir() { return _resourceDir; }
    /// set i18n resource directory
    @property void resourceDir(string dir) { _resourceDir = dir; }

    /// convert resource path - зкуpend resource dir if necessary
    string convertResourcePath(string filename) {
        if (filename is null)
            return null;
        bool hasPathDelimiters = false;
        foreach(char ch; filename)
            if (ch == '/' || ch == '\\')
                hasPathDelimiters = true;
        if (!hasPathDelimiters && _resourceDir !is null)
            return _resourceDir ~ filename;
        return filename;
    }

    this() {
        _main = new UIStringList();
        _fallback = new UIStringList();
    }
    /// load translation file(s)
    bool load(string mainFilename, string fallbackFilename = null) {
        _main.clear();
        _fallback.clear();
        bool res = _main.load(convertResourcePath(mainFilename));
        if (fallbackFilename !is null) {
            res = _fallback.load(convertResourcePath(fallbackFilename)) || res;
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
        clear();
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
    bool load(string filename) {
        import std.stream;
        import std.file;
        try {
            Log.d("Loading string resources from file ", filename);
            if (!exists(filename) && isFile(filename)) {
                Log.e("File does not exist: ", filename);
                return false;
            }
	        std.stream.File f = new std.stream.File(filename);
            scope(exit) { f.close(); }
            return load(f);
        } catch (StreamFileException e) {
            Log.e("Cannot read string resources from file ", filename);
        }
        return false;
    }
}
