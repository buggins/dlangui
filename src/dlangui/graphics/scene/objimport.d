module dlangui.graphics.scene.objimport;

public import dlangui.core.config;
static if (ENABLE_OPENGL):
static if (BACKEND_GUI):

import dlangui.core.logger;
import dlangui.core.math3d;
import dlangui.dml.tokenizer;
import dlangui.graphics.scene.mesh;

struct ObjModelImport {
    alias FaceIndex = int[3];

    private float[] _vertexData;
    private float[] _normalData;
    private float[] _txData;
    private int _vertexCount;
    private int _normalCount;
    private int _triangleCount;
    private int _txCount;
    private float[8] _buf;

    MeshRef mesh;

    protected float[] parseFloatList(Token[] tokens, int maxItems = 3, float padding = 0) return {
        int i = 0;
        int sgn = 1;
        foreach(t; tokens) {
            if (i >= maxItems)
                break;
            if (t.type == TokenType.floating) {
                _buf[i++] = cast(float)(t.floatvalue * sgn);
                sgn = 1;
            } else if (t.type == TokenType.integer) {
                _buf[i++] = cast(float)(t.intvalue * sgn);
                sgn = 1;
            } else if (t.type == TokenType.minus) {
                sgn = -1;
            }
        }
        while(i < maxItems)
            _buf[i++] = padding;
        if (i > 0)
            return _buf[0 .. i];
        return null;
    }
    //# List of geometric vertices, with (x,y,z[,w]) coordinates, w is optional and defaults to 1.0.
    //v 0.123 0.234 0.345 1.0
    protected bool parseVertexLine(Token[] tokens) {
        float[] data = parseFloatList(tokens, 3, 0);
        if (data.length == 3) {
            _vertexData ~= data;
            _vertexCount++;
            return true;
        }
        return false;
    }
    //# List of texture coordinates, in (u, v [,w]) coordinates, these will vary between 0 and 1, w is optional and defaults to 0.
    //vt 0.500 1 [0]
    protected bool parseVertexTextureLine(Token[] tokens) {
        float[] data = parseFloatList(tokens, 2, 0);
        if (data.length == 2) {
            _txData ~= data;
            _txCount++;
            return true;
        }
        return false;
    }
    //# List of vertex normals in (x,y,z) form; normals might not be unit vectors.
    //vn 0.707 0.000 0.707
    protected bool parseVertexNormalsLine(Token[] tokens) {
        float[] data = parseFloatList(tokens, 3, 0);
        if (data.length == 3) {
            _normalData ~= data;
            _normalCount++;
            return true;
        }
        return false;
    }

    static protected bool skipToken(ref Token[] tokens) {
        tokens = tokens.length > 1 ? tokens[1 .. $] : null;
        return tokens.length > 0;
    }
    static protected bool parseIndex(ref Token[] tokens, ref int data) {
        int sign = 1;
        if (tokens[0].type == TokenType.minus) {
            sign = -1;
            skipToken(tokens);
        }
        if (tokens[0].type == TokenType.integer) {
            data = tokens[0].intvalue * sign;
            skipToken(tokens);
            return true;
        }
        return false;
    }
    static protected bool skip(ref Token[] tokens, TokenType type) {
        if (tokens.length > 0 && tokens[0].type == type) {
            skipToken(tokens);
            return true;
        }
        return false;
    }
    static protected bool parseFaceIndex(ref Token[] tokens, ref FaceIndex data) {
        int i = 0;
        if (tokens.length == 0)
            return false;
        if (!parseIndex(tokens, data[0]))
            return false;
        if (skip(tokens, TokenType.divide)) {
            parseIndex(tokens, data[1]);
            if (skip(tokens, TokenType.divide)) {
                if (!parseIndex(tokens, data[2]))
                    return false;
            }
        }
        return tokens.length == 0 || skip(tokens, TokenType.whitespace);
    }
    //# Parameter space vertices in ( u [,v] [,w] ) form; free form geometry statement ( see below )
    //vp 0.310000 3.210000 2.100000
    protected bool parseParameterSpaceLine(Token[] tokens) {
        // not supported

        return true;
    }

    //f 1 2 3
    //f 3/1 4/2 5/3
    //f 6/4/1 3/5/3 7/6/5
    protected bool parseFaceLine(Token[] tokens) {
        FaceIndex[10] indexes;
        int i = 0;
        while(parseFaceIndex(tokens, indexes[i])) {
            if (++i >= 10)
                break;
        }
        for (int j = 1; j + 1 < i; j++)
            addTriangle(indexes[0], indexes[j], indexes[j + 1]);
        return true;
    }

    vec3 vertexForIndex(int index) {
        if (index < 0)
            index = _vertexCount + 1 + index;
        if (index >= 1 && index <= _vertexCount) {
            index = (index - 1) * 3;
            return vec3(&_vertexData[index]);
        }
        return vec3.init;
    }

    vec3 normalForIndex(int index) {
        if (index < 0)
            index = _normalCount + 1 + index;
        if (index >= 1 && index <= _normalCount) {
            index = (index - 1) * 3;
            return vec3(&_normalData[index]);
        }
        return vec3(0, 0, 1);
    }

    vec2 txForIndex(int index) {
        if (index < 0)
            index = _txCount + 1 + index;
        if (index >= 1 && index <= _txCount) {
            index = (index - 1) * 2;
            return vec2(&_txData[index]);
        }
        return vec2.init;
    }

    bool _meshHasTexture;
    void createMeshIfNotExist() {
        if (!mesh.isNull)
            return;
        if (_txCount) {
            mesh = new Mesh(VertexFormat(VertexElementType.POSITION, VertexElementType.NORMAL, /*VertexElementType.COLOR, */ VertexElementType.TEXCOORD0));
            _meshHasTexture = true;
        } else {
            mesh = new Mesh(VertexFormat(VertexElementType.POSITION, VertexElementType.NORMAL /*, VertexElementType.COLOR*/));
            _meshHasTexture = false;
        }
    }
    protected bool addTriangle(FaceIndex v1, FaceIndex v2, FaceIndex v3) {
        createMeshIfNotExist();
        float[16 * 3] data;
        const (VertexFormat) * fmt = mesh.vertexFormatPtr;
        int vfloats = fmt.vertexFloats;
        vec3 p1 = vertexForIndex(v1[0]);
        vec3 p2 = vertexForIndex(v2[0]);
        vec3 p3 = vertexForIndex(v3[0]);
        fmt.set(data.ptr, VertexElementType.POSITION, p1);
        fmt.set(data.ptr + vfloats, VertexElementType.POSITION, p2);
        fmt.set(data.ptr + vfloats * 2, VertexElementType.POSITION, p3);
        if (fmt.hasElement(VertexElementType.TEXCOORD0)) {
            fmt.set(data.ptr, VertexElementType.TEXCOORD0, txForIndex(v1[1]));
            fmt.set(data.ptr + vfloats, VertexElementType.TEXCOORD0, txForIndex(v2[1]));
            fmt.set(data.ptr + vfloats * 2, VertexElementType.TEXCOORD0, txForIndex(v3[1]));
        }
        if (fmt.hasElement(VertexElementType.COLOR)) {
            const vec4 white = vec4(1, 1, 1, 1);
            fmt.set(data.ptr, VertexElementType.COLOR, white);
            fmt.set(data.ptr + vfloats, VertexElementType.COLOR, white);
            fmt.set(data.ptr + vfloats * 2, VertexElementType.COLOR, white);
        }
        if (fmt.hasElement(VertexElementType.NORMAL)) {
            vec3 normal;
            if (!v1[2] || !v2[2] || !v3[2]) {
                // no normal specified, calculate it
                normal = triangleNormal(p1, p2, p3);
            }
            fmt.set(data.ptr, VertexElementType.NORMAL, v1[2] ? normalForIndex(v1[2]) : normal);
            fmt.set(data.ptr + vfloats, VertexElementType.NORMAL, v2[2] ? normalForIndex(v2[2]) : normal);
            fmt.set(data.ptr + vfloats * 2, VertexElementType.NORMAL, v3[2] ? normalForIndex(v3[2]) : normal);
        }
        int startVertex = mesh.addVertexes(data.ptr[0 .. vfloats * 3]);
        mesh.addPart(PrimitiveType.triangles, [
            cast(ushort)(startVertex + 0),
            cast(ushort)(startVertex + 1),
            cast(ushort)(startVertex + 2)]);
        _triangleCount++;
        return true;
    }

    protected bool parseLine(Token[] tokens) {
        tokens = trimSpaceTokens(tokens);
        if (tokens.length) {
            if (tokens[0].type == TokenType.comment)
                return true; // ignore comment
            if (tokens[0].type == TokenType.ident) {
                string ident = tokens[0].text;
                tokens = trimSpaceTokens(tokens[1 .. $], true, false);
                if (ident == "v") // vertex
                    return parseVertexLine(tokens);
                if (ident == "vt") // texture coords
                    return parseVertexTextureLine(tokens);
                if (ident == "vn") // normals
                    return parseVertexNormalsLine(tokens);
                if (ident == "vp") // parameter space
                    return parseParameterSpaceLine(tokens);
                if (ident == "f") // face
                    return parseFaceLine(tokens);
            }
        }
        return true;
    }
    bool parse(string source) {
        import dlangui.dml.tokenizer;
        try {
            Token[] tokens = tokenize(source, ["#"]);
            int start = 0;
            int i = 0;
            for ( ; i <= tokens.length; i++) {
                if (i == tokens.length || tokens[i].type == TokenType.eol) {
                    if (i > start && !parseLine(tokens[start .. i]))
                        return false;
                    start = i + 1;
                }
            }
        } catch (ParserException e) {
            Log.d("failed to tokenize OBJ source", e);
            return false;
        }
        return true;
    }

}

