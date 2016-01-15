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
    this(VertexElementType type, ubyte size) {
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
    /// get number of elements
    @property int length() const {
        return cast(int)_elements.length;
    }
    /// get element by index
    VertexElement opIndex(int index) const {
        return _elements[index];
    }
    /// returns vertex size in bytes for format
    @property int vertexSize() const {
        return _vertexSize;
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

class Mesh {
    protected MeshPart[] _parts;
    protected int _vertexCount;
    protected int _triangleCount;
    protected float[] _coords;  // [x, y, z]
    protected float[] _normals; // [x, y, z]
    protected float[] _colors;  // [r, g, b, a]
    protected float[] _txcoords;// [u, v]
    protected int[] _indexes;   // [v1, v2, v3] -- triangle vertex indexes

    protected Material _material;

    @property int vertexCount() { return _vertexCount; }
    @property int triangleCount() { return _triangleCount; }

    float[] arrayElement(ref float[] buf, int elemIndex, int elemLength = 3, float fillWith = 0) {
        int startIndex = elemIndex * elemLength;
        if (buf.length < startIndex + elemLength) {
            if (_vertexCount < elemIndex + 1)
                _vertexCount = elemIndex + 1;
            int p = cast(int)buf.length;
            buf.length = startIndex + elemLength;
            for(; p < buf.length; p++)
                buf[p] = fillWith;
        }
        return buf[startIndex .. startIndex + elemLength];
    }

    void setVertexCoord(int index, vec3 v) {
        arrayElement(_coords, index, 3, 0)[0..3] = v.vec[0..3];
    }

    void setVertexNormal(int index, vec3 v) {
        arrayElement(_normals, index, 3, 0)[0..3] = v.vec[0..3];
    }

    void setVertexColor(int index, vec4 v) {
        arrayElement(_colors, index, 4, 1.0f)[0..4] = v.vec[0..4];
    }

    void setVertexTxCoord(int index, vec2 v) {
        arrayElement(_txcoords, index, 2, 0)[0..2] = v.vec[0..2];
    }

    /// sets vertex data for specified vertex index, returns index of added vertex; pass index -1 to append vertex to end of list
    int setVertex(int index, vec3 coord, vec3 normal, vec4 color, vec2 txcoord) {
        if (index < 0)
            index = _vertexCount;
        setVertexCoord(index, coord);
        setVertexNormal(index, normal);
        setVertexColor(index, color);
        setVertexTxCoord(index, txcoord);
        return index;
    }

    /// adds indexes for triangle
    int addTriangleIndexes(int p1, int p2, int p3) {
        _indexes ~= p1;
        _indexes ~= p2;
        _indexes ~= p3;
        _triangleCount++;
        return _triangleCount - 1;
    }

    /// adds indexes for 2 triangles forming rectangle
    int addRectangleIndexes(int p1, int p2, int p3, int p4) {
        _indexes ~= p1;
        _indexes ~= p2;
        _indexes ~= p3;
        _indexes ~= p3;
        _indexes ~= p4;
        _indexes ~= p1;
        _triangleCount += 2;
        return _triangleCount - 2;
    }
}

class MeshPart {
}
