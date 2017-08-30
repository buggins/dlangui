module dlangui.graphics.scene.mesh;

public import dlangui.core.config;
static if (ENABLE_OPENGL):
static if (BACKEND_GUI):

import dlangui.core.math3d;
import dlangui.core.types;
//import dlangui.graphics.scene.material;
import dlangui.graphics.scene.effect;

/// Reference counted Mesh object
alias MeshRef = Ref!Mesh;

/// Base class for graphics effect / program - e.g. for OpenGL shader program
abstract class GraphicsEffect : RefCountedObject {
    /// get location for vertex attribute
    int getVertexElementLocation(VertexElementType type);

    void setUniform(string uniformName, ref const(mat4) matrix);

    void setUniform(string uniformName, const(mat4)[] matrix);

    void setUniform(string uniformName, float v);

    void setUniform(string uniformName, const float[] v);

    void setUniform(string uniformName, vec2 vec);

    void setUniform(string uniformName, const vec2[] vec);

    void setUniform(string uniformName, vec3 vec);

    void setUniform(string uniformName, const vec3[] vec);

    void setUniform(string uniformName, vec4 vec);

    void setUniform(string uniformName, const vec4[] vec);

    void setUniform(DefaultUniform id, ref const(mat4) matrix);

    void setUniform(DefaultUniform id, const(mat4)[] matrix);

    void setUniform(DefaultUniform id, float v);

    void setUniform(DefaultUniform id, const float[] v);

    void setUniform(DefaultUniform id, vec2 vec);

    void setUniform(DefaultUniform id, const vec2[] vec);

    void setUniform(DefaultUniform id, vec3 vec);

    void setUniform(DefaultUniform id, const vec3[] vec);

    void setUniform(DefaultUniform id, vec4 vec);

    void setUniform(DefaultUniform id, const vec4[] vec);

    /// returns true if effect has uniform
    bool hasUniform(DefaultUniform id);

    /// returns true if effect has uniform
    bool hasUniform(string uniformName);

    void draw(Mesh mesh, bool wireframe);
}

enum DefaultUniform : int {
    // colors
    u_ambientColor, // vec3
    u_diffuseColor, // vec4

    // textures
    u_diffuseTexture, //uniform sampler2D u_diffuseTexture;
    u_lightmapTexture, //uniform sampler2D u_lightmapTexture;
    u_normalmapTexture, //uniform sampler2D u_normalmapTexture;

    // lights
    u_directionalLightColor, //uniform vec3 u_directionalLightColor[DIRECTIONAL_LIGHT_COUNT];
    u_directionalLightDirection, //uniform vec3 u_directionalLightDirection[DIRECTIONAL_LIGHT_COUNT];
    u_pointLightColor, //uniform vec3 u_pointLightColor[POINT_LIGHT_COUNT];
    u_pointLightPosition, //uniform vec3 u_pointLightPosition[POINT_LIGHT_COUNT];
    u_pointLightRangeInverse, //uniform float u_pointLightRangeInverse[POINT_LIGHT_COUNT];
    u_spotLightColor, //uniform vec3 u_spotLightColor[SPOT_LIGHT_COUNT];
    u_spotLightRangeInverse, //uniform float u_spotLightRangeInverse[SPOT_LIGHT_COUNT];
    u_spotLightInnerAngleCos, //uniform float u_spotLightInnerAngleCos[SPOT_LIGHT_COUNT];
    u_spotLightOuterAngleCos, //uniform float u_spotLightOuterAngleCos[SPOT_LIGHT_COUNT];
    u_spotLightPosition, //uniform vec3 u_spotLightPosition[SPOT_LIGHT_COUNT];
    u_spotLightDirection, //uniform vec3 u_spotLightDirection[SPOT_LIGHT_COUNT];

    u_specularExponent, //uniform float u_specularExponent;
    u_modulateColor, //uniform vec4 u_modulateColor;
    u_modulateAlpha, //uniform float u_modulateAlpha;

    // fog
    u_fogColor, // uniform vec4 u_fogColor
    u_fogMinDistance, // uniform float u_fogMinDistance
    u_fogMaxDistance, // uniform float u_fogMaxDistance

    // matrix
    u_worldViewProjectionMatrix, //uniform mat4 u_worldViewProjectionMatrix;
    u_inverseTransposeWorldViewMatrix, //uniform mat4 u_inverseTransposeWorldViewMatrix;
    u_worldMatrix, //uniform mat4 u_worldMatrix;
    u_worldViewMatrix, //uniform mat4 u_worldViewMatrix;
    u_cameraPosition, //uniform vec3 u_cameraPosition;

    u_matrixPalette, //uniform vec4 u_matrixPalette[SKINNING_JOINT_COUNT * 3];
    u_clipPlane, //uniform vec4 u_clipPlane;
}

enum DefaultAttribute : int {
    a_position, //attribute vec4 a_position;

    a_blendWeights, //attribute vec4 a_blendWeights;
    a_blendIndices, //attribute vec4 a_blendIndices;

    a_texCoord, //attribute vec2 a_texCoord;
    a_texCoord1, //attribute vec2 a_texCoord1;
    a_normal, //attribute vec3 a_normal;
    a_color, //attribute vec3 a_color;
    a_tangent, //attribute vec3 a_tangent;
    a_binormal, //attribute vec3 a_binormal;
}

/// vertex element type
enum VertexElementType : ubyte {
    POSITION = 0,
    NORMAL,
    COLOR,
    TANGENT,
    BINORMAL,
    BLENDWEIGHTS,
    BLENDINDICES,
    TEXCOORD0,
    TEXCOORD1,
    TEXCOORD2,
    TEXCOORD3,
    TEXCOORD4,
    TEXCOORD5,
    TEXCOORD6,
    TEXCOORD7,
}

static assert(VertexElementType.max == VertexElementType.TEXCOORD7);

/// Graphics primitive type
enum PrimitiveType : int {
    triangles,
    triangleStripes,
    lines,
    lineStripes,
    points,
}

/// Vertex buffer object base class
class VertexBuffer {
    /// bind into current context
    //void bind() {}
    /// unbind from current context
    //void unbind() {}
    /// set or change data
    void setData(Mesh mesh) { }
    /// draw mesh using specified effect
    void draw(GraphicsEffect effect, bool wireframe) { }
}

/// location for element is not found
enum VERTEX_ELEMENT_NOT_FOUND = -1;

/// vertex attribute properties
struct VertexElement {
    private VertexElementType _type;
    private ubyte _size;
    /// returns element type
    @property VertexElementType type() const { return _type; }
    /// return element size in floats
    @property ubyte size() const { return _size; }
    /// return element size in bytes
    @property ubyte byteSize() const { return cast(ubyte)(_size * float.sizeof); }

    this(VertexElementType type, ubyte size = 0) {
        if (size == 0) {
            // autoassign default size
            switch(type) with (VertexElementType) {
                case POSITION:
                case NORMAL:
                case TANGENT:
                case BINORMAL:
                    size = 3;
                    break;
                case BLENDWEIGHTS:
                case BLENDINDICES:
                case COLOR:
                    size = 4;
                    break;
                default: // tx coords
                    size = 2;
                    break;
            }
        }
        _type = type;
        _size = size;
    }
}

/// Vertex format elements list
struct VertexFormat {
    private VertexElement[] _elements;
    private byte[16] _elementOffset = [-1, -1, -1, -1,  -1, -1, -1, -1,  -1, -1, -1, -1,  -1, -1, -1, -1];
    private int _vertexSize; // vertex size in floats
    /// make using element list
    this(inout VertexElement[] elems...) {
        _elements = elems.dup;
        foreach(elem; elems) {
            _elementOffset[elem.type] = cast(byte)_vertexSize;
            _vertexSize += elem.size;
        }
    }
    /// init from vertex element types, using default sizes for types
    this(inout VertexElementType[] types...) {
        foreach(t; types) {
            _elementOffset[t] = cast(byte)_vertexSize;
            VertexElement elem = VertexElement(t);
            _elements ~= elem;
            _vertexSize += elem.size;
        }
    }
    int elementOffset(VertexElementType type) const {
        return _elementOffset[type];
    }
    bool hasElement(VertexElementType type) const {
        return _elementOffset[type] >= 0;
    }
    /// set vec2 component value of vertex
    void set(float * vertex, VertexElementType type, vec2 value) const {
        int start = _elementOffset[type];
        if (start >= 0) {
            vertex += start;
            vertex[0] = value.vec[0];
            vertex[1] = value.vec[1];
        }
    }
    /// set vec3 component value of vertex
    void set(float * vertex, VertexElementType type, vec3 value) const {
        int start = _elementOffset[type];
        if (start >= 0) {
            vertex += start;
            vertex[0] = value.vec[0];
            vertex[1] = value.vec[1];
            vertex[2] = value.vec[2];
        }
    }
    /// set vec4 component value of vertex
    void set(float * vertex, VertexElementType type, vec4 value) const {
        int start = _elementOffset[type];
        if (start >= 0) {
            vertex += start;
            vertex[0] = value.vec[0];
            vertex[1] = value.vec[1];
            vertex[2] = value.vec[2];
            vertex[3] = value.vec[3];
        }
    }
    /// get number of elements
    @property int length() const {
        return cast(int)_elements.length;
    }
    /// get element by index
    VertexElement opIndex(int index) const {
        return _elements[index];
    }
    /// returns vertex size in bytes
    @property int vertexSize() const {
        return _vertexSize * cast(int)float.sizeof;
    }
    /// returns vertex size in floats
    @property int vertexFloats() const {
        return _vertexSize;
    }
    /// returns true if it's valid vertex format
    @property bool isValid() const {
        if (!_vertexSize)
            return false;
        foreach(elem; _elements) {
            if (elem.type == VertexElementType.POSITION)
                return true;
        }
        return false;
    }
    /// compare
    bool opEquals(immutable ref VertexFormat fmt) const {
        if (_vertexSize != fmt._vertexSize)
            return false;
        for(int i = 0; i < _elements.length; i++)
            if (_elements[i] != fmt._elements[i])
                return false;
        return true;
    }
    string dump(float * data) {
        import std.conv : to;
        char[] buf;
        int pos = 0;
        foreach(VertexElement e; _elements) {
            buf ~= data[pos .. pos + e.size].to!string;
            pos += e.size;
        }
        return buf.dup;
    }
}

struct IndexFragment {
    PrimitiveType type;
    ushort start;
    ushort end;
    this(PrimitiveType type, int start, int end) {
        this.type = type;
        this.start = cast(ushort)start;
        this.end = cast(ushort)end;
    }
}

/// Mesh
class Mesh : RefCountedObject {
    protected VertexFormat _vertexFormat;
    protected int _vertexCount;
    protected float[] _vertexData;
    protected MeshPart[] _parts;
    protected VertexBuffer _vertexBuffer;
    protected bool _dirtyVertexBuffer = true;

    @property ref VertexFormat vertexFormat() { return _vertexFormat; }
    @property const(VertexFormat) * vertexFormatPtr() { return &_vertexFormat; }

    /// returns true if vertex format contains specified element
    bool hasElement(VertexElementType type) const {
        return _vertexFormat.hasElement(type);
    }

    //@property ref VertexFormat vertexFormat() { return _vertexFormat; }

    @property void vertexFormat(VertexFormat format) {
        assert(_vertexCount == 0);
        _vertexFormat = format;
        _dirtyVertexBuffer = true;
    }

    const(float[]) vertex(int index) {
        int i = _vertexFormat.vertexFloats * index;
        return _vertexData[i .. i + _vertexFormat.vertexFloats];
    }

    void reset() {
        _vertexCount = 0;
        _vertexData.length = 0;
        _dirtyVertexBuffer = true;
        if (_vertexBuffer) {
            destroy(_vertexBuffer);
            _vertexBuffer = null;
        }
        if (_parts.length) {
            foreach(p; _parts)
                destroy(p);
            _parts.length = 0;
        }
    }

    string dumpVertexes(int maxCount = 30) {
        char[] buf;
        int count = 0;
        for(int i = 0; i < _vertexData.length; i+= _vertexFormat.vertexFloats) {
            buf ~= "\n";
            buf ~= _vertexFormat.dump(_vertexData.ptr + i);
            if (++count >= maxCount)
                break;
        }
        return buf.dup;
    }

    /// returns vertex count
    @property int vertexCount() const { return _vertexCount; }

    /// returns vertex data array
    @property const(float[]) vertexData() const { return _vertexData; }

    /// return index data for all parts
    @property const(ushort[]) indexData() const {
        if (!_parts)
            return null;
        if (_parts.length == 1)
            return _parts[0].data;
        int sz = 0;
        foreach(p; _parts)
            sz += p.length;
        ushort[] res;
        res.length = 0;
        int pos = 0;
        foreach(p; _parts) {
            res[pos .. pos + p.length] = p.data[0 .. $];
            pos += p.length;
        }
        return res;
    }

    /// list of mesh fragments
    @property IndexFragment[] indexFragments() const {
        IndexFragment[] res;
        int pos = 0;
        foreach(p; _parts) {
            res ~= IndexFragment(p.type, pos, pos + p.length);
            pos += p.length;
        }
        return res;
    }

    /// get vertex buffer object
    @property VertexBuffer vertexBuffer() {
        if (_dirtyVertexBuffer && _vertexBuffer) {
            _vertexBuffer.setData(this);
            _dirtyVertexBuffer = false;
        }
        return _vertexBuffer;
    }

    /// set vertex buffer object
    @property void vertexBuffer(VertexBuffer buffer) {
        if (_vertexBuffer) {
            _vertexBuffer.destroy;
            _vertexBuffer = null;
        }
        _vertexBuffer = buffer;
        if (_vertexBuffer) {
            _vertexBuffer.setData(this);
            _dirtyVertexBuffer = false;
        }
    }

    /// mesh part count
    @property int partCount() const { return cast(int)_parts.length; }
    /// returns mesh part by index
    MeshPart part(int index) { return _parts[index]; }

    MeshPart addPart(MeshPart meshPart) {
        _parts ~= meshPart;
        _dirtyVertexBuffer = true;
        return meshPart;
    }

    /// add new mesh part or append indexes to existing part (if type matches)
    MeshPart addPart(PrimitiveType type, ushort[] indexes) {
        MeshPart lastPart = _parts.length > 0 ? _parts[$ - 1] : null;
        if (!lastPart || lastPart.type != type)
            return addPart(new MeshPart(type, indexes));
        lastPart.add(indexes);
        return lastPart;
    }

    /// adds single vertex
    int addVertex(float[] data) {
        assert(_vertexFormat.isValid && data.length == _vertexFormat.vertexFloats);
        int res = _vertexCount;
        _vertexData.assumeSafeAppend();
        _vertexData ~= data;
        _vertexCount++;
        _dirtyVertexBuffer = true;
        return res;
    }

    /// adds one or more vertexes
    int addVertexes(float[] data) {
        assert(_vertexFormat.isValid && (data.length > 0) && (data.length % _vertexFormat.vertexFloats == 0));
        int res = _vertexCount;
        _vertexData.assumeSafeAppend();
        _vertexData ~= data;
        _vertexCount += cast(int)(data.length / _vertexFormat.vertexFloats);
        _dirtyVertexBuffer = true;
        return res;
    }

    this() {
    }

    this(VertexFormat vertexFormat) {
        _vertexFormat = vertexFormat;
    }

    ~this() {
        if (_vertexBuffer) {
            _vertexBuffer.destroy;
            _vertexBuffer = null;
        }
    }


    void addQuad(ref vec3 v0, ref vec3 v1, ref vec3 v2, ref vec3 v3, ref vec4 color) {
        ushort startVertex = cast(ushort)vertexCount;
        if (hasElement(VertexElementType.NORMAL)) {
            vec3 normal = vec3.crossProduct((v1 - v0), (v3 - v0)).normalized;
            if (hasElement(VertexElementType.TANGENT)) {
                vec3 tangent = (v1 - v0).normalized;
                vec3 binormal = (v3 - v0).normalized;
                addVertex([v0.x, v0.y, v0.z, color.r, color.g, color.b, color.a, 0, 0, normal.x, normal.y, normal.z, tangent.x, tangent.y, tangent.z, binormal.x, binormal.y, binormal.z]);
                addVertex([v1.x, v1.y, v1.z, color.r, color.g, color.b, color.a, 1, 0, normal.x, normal.y, normal.z, tangent.x, tangent.y, tangent.z, binormal.x, binormal.y, binormal.z]);
                addVertex([v2.x, v2.y, v2.z, color.r, color.g, color.b, color.a, 1, 1, normal.x, normal.y, normal.z, tangent.x, tangent.y, tangent.z, binormal.x, binormal.y, binormal.z]);
                addVertex([v3.x, v3.y, v3.z, color.r, color.g, color.b, color.a, 0, 1, normal.x, normal.y, normal.z, tangent.x, tangent.y, tangent.z, binormal.x, binormal.y, binormal.z]);
            } else {
                addVertex([v0.x, v0.y, v0.z, color.r, color.g, color.b, color.a, 0, 0, normal.x, normal.y, normal.z]);
                addVertex([v1.x, v1.y, v1.z, color.r, color.g, color.b, color.a, 1, 0, normal.x, normal.y, normal.z]);
                addVertex([v2.x, v2.y, v2.z, color.r, color.g, color.b, color.a, 1, 1, normal.x, normal.y, normal.z]);
                addVertex([v3.x, v3.y, v3.z, color.r, color.g, color.b, color.a, 0, 1, normal.x, normal.y, normal.z]);
            }
        } else {
            addVertex([v0.x, v0.y, v0.z, color.r, color.g, color.b, color.a, 0, 0]);
            addVertex([v1.x, v1.y, v1.z, color.r, color.g, color.b, color.a, 1, 0]);
            addVertex([v2.x, v2.y, v2.z, color.r, color.g, color.b, color.a, 1, 1]);
            addVertex([v3.x, v3.y, v3.z, color.r, color.g, color.b, color.a, 0, 1]);
        }
        addPart(PrimitiveType.triangles, [
            cast(ushort)(startVertex + 0),
            cast(ushort)(startVertex + 1),
            cast(ushort)(startVertex + 2),
            cast(ushort)(startVertex + 2),
            cast(ushort)(startVertex + 3),
            cast(ushort)(startVertex + 0)]);
    }

    void addCubeMesh(vec3 pos, float d=1, vec4 color = vec4(1,1,1,1)) {
        auto p000 = vec3(pos.x-d, pos.y-d, pos.z-d);
        auto p100 = vec3(pos.x+d, pos.y-d, pos.z-d);
        auto p010 = vec3(pos.x-d, pos.y+d, pos.z-d);
        auto p110 = vec3(pos.x+d, pos.y+d, pos.z-d);
        auto p001 = vec3(pos.x-d, pos.y-d, pos.z+d);
        auto p101 = vec3(pos.x+d, pos.y-d, pos.z+d);
        auto p011 = vec3(pos.x-d, pos.y+d, pos.z+d);
        auto p111 = vec3(pos.x+d, pos.y+d, pos.z+d);
        addQuad(p000, p010, p110, p100, color); // front face
        addQuad(p101, p111, p011, p001, color); // back face
        addQuad(p100, p110, p111, p101, color); // right face
        addQuad(p001, p011, p010, p000, color); // left face
        addQuad(p010, p011, p111, p110, color); // top face
        addQuad(p001, p000, p100, p101, color); // bottom face
    }

    static Mesh createCubeMesh(vec3 pos, float d=1, vec4 color = vec4(1,1,1,1)) {
        Mesh mesh = new Mesh(VertexFormat(VertexElementType.POSITION, VertexElementType.COLOR, VertexElementType.TEXCOORD0
                                          , VertexElementType.NORMAL, VertexElementType.TANGENT, VertexElementType.BINORMAL
                                          ));
        mesh.addCubeMesh(pos, d, color);
        return mesh;
    }
}

/// Mesh part - set of vertex indexes with graphics primitive type
class MeshPart {
    protected PrimitiveType _type;
    protected ushort[] _indexData;
    this(PrimitiveType type, ushort[] indexes = null) {
        _type = type;
        _indexData.assumeSafeAppend;
        add(indexes);
    }

    void add(ushort[] indexes) {
        if (indexes.length)
            _indexData ~= indexes;
    }

    /// returns primitive type
    @property PrimitiveType type() const { return _type; }

    /// change primitive type
    @property void type(PrimitiveType t) { _type = t; }

    /// index length
    @property int length() const { return cast(int)_indexData.length; }

    /// index data
    @property const(ushort[]) data() const { return _indexData; }
}
