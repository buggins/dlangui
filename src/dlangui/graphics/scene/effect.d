module dlangui.graphics.scene.effect;

public import dlangui.core.config;
static if (ENABLE_OPENGL):
static if (BACKEND_GUI):

import dlangui.core.types;
import dlangui.core.logger;
import dlangui.graphics.glsupport;
import dlangui.graphics.gldrawbuf;
import dlangui.graphics.scene.mesh;

/// Reference counted Effect object
alias EffectRef = Ref!Effect;

/// Effect (aka OpenGL program)
class Effect : GLProgram {
    EffectId _id;
    string[string] _defs;
    string _defText;

    @property ref const(EffectId) id() const { return _id; }
    this(EffectId id) {
        _id = id;
        init();
    }
    this(string vertexShader, string fragmentShader, string defs) {
        _id = EffectId(vertexShader, fragmentShader, defs);
        init();
    }

    ~this() {
        EffectCache.instance.onObjectDestroyed(_id);
    }

    protected void init() {
        // parse defs
        import std.array : split;
        string[] defs = _id.definitions.split(";");
        char[] buf;
        foreach(def; defs) {
            assert(def.length > 0);
            string[] items = def.split(" ");
            if (items.length > 0) {
                string value = items.length > 1 ? items[1] : "";
                _defs[items[0]] = value;
                buf ~= "#define ";
                buf ~= items[0];
                buf ~= " ";
                buf ~= value;
                buf ~= "\n";
            }
        }
        _defText = buf.dup;
        // compile shaders
        compile();
        if (!check()) {
            Log.e("Failed to compile shaders ", _id.vertexShaderName, " ", _id.fragmentShaderName, " ", _id.definitions);
            assert(false);
        }
    }

    protected bool[string] _visitedIncludes;
    protected void preProcessIncludes(ref char[] buf, string src) {
        import std.string : strip, startsWith, endsWith;
        import dlangui.graphics.resources : splitLines;
        foreach(line; src.splitLines) {
            string s = line.strip;
            if (s.startsWith("#include ")) {
                s = s[9 .. $].strip; // remove #include
                if (s.startsWith("\"") && s.endsWith("\"")) {
                    s = s[1 .. $-1]; // remove ""
                    if (!(s in _visitedIncludes)) { // protect from duplicate include
                        _visitedIncludes[s] = true; // mark as included
                        string includedSrc = loadVertexSource(s);
                        preProcessIncludes(buf, includedSrc);
                    }
                }
            } else {
                buf ~= line;
                buf ~= "\n";
            }
        }
    }

    protected string preProcessSource(string src) {
        char[] buf;
        buf.assumeSafeAppend;
        // append definitions
        buf ~= _defText;
        // append source body
        preProcessIncludes(buf, src);
        return buf.dup;
    }

    protected string loadVertexSource(string resourceId) {
        import dlangui.graphics.resources;
        import std.string : endsWith;
        string filename;
        filename = drawableCache.findResource(resourceId);
        if (!filename) {
            Log.e("Shader source resource file not found for resourceId ", resourceId);
            assert(false);
        }
        if (!filename.endsWith(".vert") && !filename.endsWith(".frag")) {
            Log.e("Shader source resource name should have .vert or .frag extension, but found ", filename);
            assert(false);
        }
        string s = cast(string)loadResourceBytes(filename);
        if (!s) {
            Log.e("Cannot read shader source resource ", resourceId, " from file ", filename);
            assert(false);
        }
        return s;
    }

    @property override string vertexSource() {
        _visitedIncludes = null;
        _visitedIncludes[_id.vertexShaderName] = true; // mark as included
        string res = preProcessSource(loadVertexSource(_id.vertexShaderName));
        //Log.v("vertexSource:", res);
        return res;
    }

    @property override string fragmentSource() {
        _visitedIncludes = null;
        _visitedIncludes[_id.fragmentShaderName] = true; // mark as included
        string res = preProcessSource(loadVertexSource(_id.fragmentShaderName));
        //Log.v("fragmentSource:", res);
        return res;
    }

    override bool initLocations() {
        return getUniformLocation(DefaultUniform.u_worldViewProjectionMatrix) >= 0 && getAttribLocation(DefaultAttribute.a_position) >= 0; // && colAttrLocation >= 0 && texCoordLocation >= 0
    }

    /// get location for vertex attribute
    override int getVertexElementLocation(VertexElementType type) {
        switch(type) with(VertexElementType) {
            case POSITION:
                return getAttribLocation(DefaultAttribute.a_position);
            case COLOR:
                return getAttribLocation(DefaultAttribute.a_color);
            case TEXCOORD0:
                return getAttribLocation(DefaultAttribute.a_texCoord);
            case NORMAL:
                return getAttribLocation(DefaultAttribute.a_normal);
            case TANGENT:
                return getAttribLocation(DefaultAttribute.a_tangent);
            case BINORMAL:
                return getAttribLocation(DefaultAttribute.a_binormal);
            default:
                return super.getVertexElementLocation(type);
        }
    }

}

/// Effects cache
class EffectCache {
    private Effect[EffectId] _map;

    private static __gshared EffectCache _instance;

    /// returns effect cache singleton instance
    static @property EffectCache instance() {
        if (!_instance)
            _instance = new EffectCache();
        return _instance;
    }

    static private void onObjectDestroyed(EffectId id) {
        if (id in _instance._map) {
            Log.d("Destroyed effect instance: ", id);
            _instance._map.remove(id);
        }
    }

    /// get effect from cache or create new if not exist
    Effect get(string vertexShader, string fragmentShader, string defs = null) {
        return get(EffectId(vertexShader, fragmentShader, defs));
    }

    /// get effect from cache or create new if not exist
    Effect get(const EffectId id) {
        if (auto p = id in _map) {
            return *p;
        }
        Effect e = new Effect(id);
        Log.d("New effect instance: ", id);
        _map[id] = e;
        return e;
    }
}


/// Effect ID
struct EffectId {
    string vertexShaderName;
    string fragmentShaderName;
    string definitions;
    this(string vertexShader, string fragmentShader, string defs) {
        vertexShaderName = vertexShader;
        fragmentShaderName = fragmentShader;
        definitions = defs;
    }

    this(ref EffectId v, string additionalParams) {
        import std.string : empty;
        vertexShaderName = v.vertexShaderName;
        fragmentShaderName = v.fragmentShaderName;
        definitions = v.definitions;
        if (!additionalParams.empty) {
            if (!definitions.empty) {
                definitions ~= ";";
                definitions ~= additionalParams;
            } else {
                definitions = additionalParams;
            }
        }
    }

    /// returns true if ID is not assigned
    @property bool empty() {
        return !vertexShaderName.length || !vertexShaderName.length;
    }

    size_t toHash() const @safe pure nothrow
    {
        size_t hash;
        foreach (char c; vertexShaderName)
            hash = (hash * 9) + c;
        hash = (hash * 31) + 198237283;
        foreach (char c; fragmentShaderName)
            hash = (hash * 9) + c;
        hash = (hash * 31) + 84574112;
        foreach (char c; definitions)
            hash = (hash * 9) + c;
        return hash;
    }

    bool opEquals(ref const EffectId s) const @safe pure nothrow
    {
        return
            this.vertexShaderName == s.vertexShaderName &&
            this.fragmentShaderName == s.fragmentShaderName &&
            this.definitions == s.definitions;
    }
}

