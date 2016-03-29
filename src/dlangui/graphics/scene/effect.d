module dlangui.graphics.scene.effect;

public import dlangui.core.config;
static if (ENABLE_OPENGL):

import dlangui.core.types;
import dlangui.core.logger;
import dlangui.graphics.glsupport;
import dlangui.graphics.gldrawbuf;
import dlangui.graphics.scene.mesh;

/// Base class for graphics effect / program - e.g. for OpenGL shader program
abstract class GraphicsEffect : RefCountedObject {
    /// get location for vertex attribute
    int getVertexElementLocation(VertexElementType type);

    void setUniform(string uniformName, mat4 matrix);

    void setUniform(string uniformName, vec2 vec);

    void setUniform(string uniformName, vec3 vec);

    void setUniform(string uniformName, vec4 vec);

    void draw(Mesh mesh);
}

/// Reference counted Effect object
alias EffectRef = Ref!Effect;

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
            std.string.cmp(this.vertexShaderName, s.vertexShaderName) == 0 &&
            std.string.cmp(this.fragmentShaderName, s.fragmentShaderName) == 0 &&
            std.string.cmp(this.definitions, s.definitions) == 0;
    }
}

/// Effect (aka OpenGL program)
class Effect : GLProgram {
    EffectId _id;
    string[string] _defs;

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
        foreach(def; defs) {
            assert(def.length > 0);
            string[] items = def.split(" ");
            if (items.length > 0) {
                _defs[items[0]] = items.length > 1 ? items[1] : "";
            }
        }
        // compile shaders
        if (!check()) {
            Log.e("Failed to compile shaders ", _id.vertexShaderName, " ", _id.fragmentShaderName, " ", _id.definitions);
            assert(false);
        }
    }

    protected string preProcessSource(string src) {
        // TODO: preprocess source code
        return src;
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
        return preProcessSource(loadVertexSource(_id.vertexShaderName));
    }

    @property override string fragmentSource() {
        return preProcessSource(loadVertexSource(_id.fragmentShaderName));
    }

    // attribute locations
    protected int matrixLocation;
    protected int vertexLocation;
    protected int colAttrLocation;
    protected int texCoordLocation;

    override bool initLocations() {
        matrixLocation = getUniformLocation("matrix");
        vertexLocation = getAttribLocation("vertex");
        colAttrLocation = getAttribLocation("colAttr");
        texCoordLocation = getAttribLocation("texCoord");
        return matrixLocation >= 0 && vertexLocation >= 0 && colAttrLocation >= 0 && texCoordLocation >= 0;
    }

    /// get location for vertex attribute
    override int getVertexElementLocation(VertexElementType type) {
        switch(type) with(VertexElementType) {
            case POSITION: 
                return vertexLocation;
            case COLOR: 
                return colAttrLocation;
            case TEXCOORD0: 
                return texCoordLocation;
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
        if (id in _instance._map)
            _instance._map.remove(id);
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
        _map[id] = e;
        return e;
    }
}

