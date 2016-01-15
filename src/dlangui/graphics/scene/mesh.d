module dlangui.graphics.scene.mesh;

import dlangui.graphics.scene.material;
import dlangui.core.math3d;

class Mesh {
    protected Submesh[] _submeshes;
}

class Submesh {
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

    /// add vertex data, returns index of added vertex
    void setVertex(int index, vec3 coord, vec3 normal, vec4 color, vec2 txcoord) {
        setVertexCoord(index, coord);
        setVertexNormal(index, normal);
        setVertexColor(index, color);
        setVertexTxCoord(index, txcoord);
    }

    /// add vertex data, returns index of added vertex
    int addVertex(vec3 coord, vec3 normal, vec4 color, vec2 txcoord) {
        _coords ~= coord.vec;
        _normals ~= normal.vec;
        _colors ~= color.vec;
        _txcoords ~= txcoord.vec;
        _vertexCount++;
        return _vertexCount - 1;
    }

    int addTriangleIndexes(int p1, int p2, int p3) {
        _indexes ~= p1;
        _indexes ~= p2;
        _indexes ~= p3;
        _triangleCount++;
        return _triangleCount - 1;
    }

}
