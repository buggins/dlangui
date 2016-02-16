module dlangui.graphics.scene.mesh;

import dlangui.graphics.scene.material;
import dlangui.core.math3d;

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

struct VertexElement {
    private VertexElementType _type;
    private ubyte _size;
    @property VertexElementType type() const { return _type; }
    @property ubyte size() const { return _size; }
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
                default:
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
    bool opEquals(immutable ref VertexFormat fmt) {
        if (_vertexSize != fmt._vertexSize)
            return false;
        for(int i = 0; i < _elements.length; i++)
            if (_elements[i] != fmt._elements[i])
                return false;
        return true;
    }
}

/// Mesh
class Mesh {
    protected VertexFormat _vertexFormat;
    protected int _vertexCount;
    protected float[] _vertexData;
    protected MeshPart[] _parts;

    @property ref const(VertexFormat) vertexFormat() const { return _vertexFormat; }
    @property void vertexFormat(VertexFormat format) { 
        assert(_vertexCount == 0);
        _vertexFormat = format; 
    }
    /// returns vertex count
    @property int vertexCount() const { return _vertexCount; }

    /// mesh part count
    @property int partCount() const { return _parts.length; }
    /// returns mesh part by index
    MeshPart part(int index) { return _parts[index]; }

    MeshPart addPart(MeshPart meshPart) {
        _parts ~= meshPart;
        return meshPart;
    }

    MeshPart addPart(PrimitiveType type, int[] indexes) {
        return addPart(new MeshPart(type, indexes));
    }

    /// adds single vertex
    int addVertex(float[] data) {
        assert(_vertexFormat.isValid && data.length == _vertexFormat.vertexFloats);
        int res = _vertexCount;
        _vertexData.assumeSafeAppend();
        _vertexData ~= data;
        _vertexCount++;
        return res;
    }

    /// adds one or more vertexes
    int addVertexes(float[] data) {
        assert(_vertexFormat.isValid && (data.length > 0) && (data.length % _vertexFormat.vertexFloats == 0));
        int res = _vertexCount;
        _vertexData.assumeSafeAppend();
        _vertexData ~= data;
        _vertexCount += cast(int)(data.length / _vertexFormat.vertexFloats);
        return res;
    }

    this() {
    }

    this(VertexFormat vertexFormat) {
        _vertexFormat = vertexFormat;
    }
}

/// Graphics primitive type
enum PrimitiveType : int {
    triangles,
    triangleStripes,
    lines,
    lineStripes,
    points,
}

/// Mesh part - set of vertex indexes with graphics primitive type
class MeshPart {
    protected PrimitiveType _type;
    protected int[] _indexData;
    this(PrimitiveType type, int[] indexes = null) {
        _type = type;
        _indexData.assumeSafeAppend;
        add(indexes);
    }

    void add(int[] indexes) {
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
    @property int[] data() { return _indexData; }
}
