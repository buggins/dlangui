module dlangui.graphics.scene.mesh;

import dlangui.graphics.scene.material;
import dlangui.core.math3d;

/// vertex element type
enum VertexElementType : ubyte {
    POSITION = 1,
    NORMAL,
    COLOR,
    TEXCOORD0,
    TEXCOORD1,
    TEXCOORD2,
    TEXCOORD3,
    TEXCOORD4,
    TEXCOORD5,
    TEXCOORD6,
    TEXCOORD7,
}

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
    void bind() {}
    /// unbind from current context
    void unbind() {}
    /// set or change data
    void setData(Mesh mesh) { }
    /// update vertex element locations for effect/shader program
    void prepareDrawing(GraphicsEffect effect) { }
    /// draw mesh using specified effect
    void draw(GraphicsEffect effect) { }
}

/// location for element is not found
enum VERTEX_ELEMENT_NOT_FOUND = -1;

/// Base class for graphics effect / program - e.g. for OpenGL shader program
abstract class GraphicsEffect {
    /// get location for vertex attribute
    int getVertexElementLocation(VertexElementType type);

    void setUniform(string uniformName, mat4 matrix);

    void setUniform(string uniformName, vec2 vec);

    void setUniform(string uniformName, vec3 vec);

    void setUniform(string uniformName, vec4 vec);

    void draw(Mesh mesh);
}

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
            switch(type) with (VertexElementType) {
                case POSITION:
                case NORMAL:
                    size = 3;
                    break;
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
    private int _vertexSize;
    /// make using element list
    this(inout VertexElement[] elems...) {
        _elements = elems.dup;
        foreach(elem; elems)
            _vertexSize += elem.size * float.sizeof;
    }
    /// init from vertex element types, using default sizes for types
    this(inout VertexElementType[] types...) {
        foreach(t; types) {
            VertexElement elem = VertexElement(t);
            _elements ~= elem;
            _vertexSize += elem.size;
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
class Mesh {
    protected VertexFormat _vertexFormat;
    protected int _vertexCount;
    protected float[] _vertexData;
    protected MeshPart[] _parts;
    protected VertexBuffer _vertexBuffer;
    protected bool _dirtyVertexBuffer = true;

    @property ref const(VertexFormat) vertexFormat() const { return _vertexFormat; }

    @property VertexFormat vertexFormat() { return _vertexFormat; }

    @property void vertexFormat(VertexFormat format) {
        assert(_vertexCount == 0);
        _vertexFormat = format; 
        _dirtyVertexBuffer = true;
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

    MeshPart addPart(PrimitiveType type, ushort[] indexes) {
        return addPart(new MeshPart(type, indexes));
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
