// Written in the D programming language.

/**
This module contains OpenGL access layer.

To enable OpenGL support, build with version(USE_OPENGL);

Synopsis:

----
import dlangui.graphics.glsupport;

----

Copyright: Vadim Lopatin, 2014
License:   Boost License 1.0
Authors:   Vadim Lopatin, coolreader.org@gmail.com
*/
module dlangui.graphics.glsupport;

public import dlangui.core.config;

static if (ENABLE_OPENGL):

public import dlangui.core.math3d;
import dlangui.graphics.scene.mesh;
import dlangui.core.logger;
import derelict.opengl3.gl3;
import derelict.opengl3.gl;
import dlangui.core.types;
import std.conv;
import std.string;
import std.array;

derelict.util.exception.ShouldThrow gl3MissingSymFunc( string symName ) {
    import std.algorithm : equal;
    foreach(s; ["glGetError", "glShaderSource", "glCompileShader",
            "glGetShaderiv", "glGetShaderInfoLog", "glGetString",
            "glCreateProgram", "glUseProgram", "glDeleteProgram",
            "glDeleteShader", "glEnable", "glDisable", "glBlendFunc",
            "glUniformMatrix4fv", "glGetAttribLocation", "glGetUniformLocation",
            "glGenVertexArrays", "glBindVertexArray", "glBufferData",
            "glBindBuffer", "glBufferSubData"]) {
        if (symName.equal(s)) // Symbol is used
            return derelict.util.exception.ShouldThrow.Yes;
    }
    // Don't throw for unused symbol
    return derelict.util.exception.ShouldThrow.No;
}


/**
 * Convenient wrapper around glGetError()
 * Using: checkgl!glFunction(funcParams);
 * TODO use one of the DEBUG extensions
 */
template checkgl(alias func)
{
    debug auto checkgl(string functionName=__FUNCTION__, int line=__LINE__, Args...)(Args args)
    {
        scope(success) checkError(func.stringof, functionName, line);
        return func(args);
    } else
        alias checkgl = func;
}
bool checkError(string context="", string functionName=__FUNCTION__, int line=__LINE__)
{
    GLenum err = glGetError();
    if (err != GL_NO_ERROR) {
        Log.e("OpenGL error ", glerrorToString(err), " at ", functionName, ":", line, " -- ", context);
        return true;
    }
    return false;
}

/**
* Convenient wrapper around glGetError()
* Using: checkgl!glFunction(funcParams);
* TODO use one of the DEBUG extensions
*/
template assertgl(alias func)
{
    auto assertgl(string functionName=__FUNCTION__, int line=__LINE__, Args...)(Args args)
    {
        scope(success) assertNoError(func.stringof, functionName, line);
        return func(args);
    };
}
void assertNoError(string context="", string functionName=__FUNCTION__, int line=__LINE__)
{
    GLenum err = glGetError();
    if (err != GL_NO_ERROR) {
        Log.e("fatal OpenGL error ", glerrorToString(err), " at ", functionName, ":", line, " -- ", context);
        assert(false);
    }
}

/* For reporting OpenGL errors, it's nicer to get a human-readable symbolic name for the
 * error instead of the numeric form. Derelict's GLenum is just an alias for uint, so we
 * can't depend on D's nice toString() for enums.
 */
string glerrorToString(in GLenum err) pure nothrow {
    switch(err) {
        case 0x0500: return "GL_INVALID_ENUM";
        case 0x0501: return "GL_INVALID_VALUE";
        case 0x0502: return "GL_INVALID_OPERATION";
        case 0x0505: return "GL_OUT_OF_MEMORY";
        case 0x0506: return "GL_INVALID_FRAMEBUFFER_OPERATION";
        case 0x0507: return "GL_CONTEXT_LOST";
        case GL_NO_ERROR: return "No GL error";
        default: return "Unknown GL error: " ~ to!string(err);
    }
}


class GLProgram : GraphicsEffect {
    @property abstract string vertexSource();
    @property abstract string fragmentSource();
    protected GLuint program;
    protected bool initialized;
    protected bool error;

    private GLuint vertexShader;
    private GLuint fragmentShader;
    private string glslversion;
    private int glslversionInt;
    private char[] glslversionString;

    private void compatibilityFixes(ref char[] code, GLuint type) {
        if (glslversionInt < 150)
            code = replace(code, " texture(", " texture2D(");
        if (glslversionInt < 140) {
            if(type == GL_VERTEX_SHADER)
            {
                code = replace(code, "in ", "attribute ");
                code = replace(code, "out ", "varying ");
            } else
            {
                code = replace(code, "in ", "varying ");
                code = replace(code, "out vec4 outColor;", "");
                code = replace(code, "outColor", "gl_FragColor");
            }
        }
    }

    private GLuint compileShader(string src, GLuint type) {
        import std.string : toStringz, fromStringz;

        char[] sourceCode;
        sourceCode ~= "#version ";
        sourceCode ~= glslversionString;
        sourceCode ~= "\n";
        sourceCode ~= src;
        compatibilityFixes(sourceCode, type);

        Log.d("compileShader: glsl = ", glslversion, ", type: ", (type == GL_VERTEX_SHADER ? "GL_VERTEX_SHADER" : (type == GL_FRAGMENT_SHADER ? "GL_FRAGMENT_SHADER" : "UNKNOWN")));
        GLuint shader = glCreateShader(type);
        const char * psrc = sourceCode.toStringz;
        glShaderSource(shader, 1, &psrc, null);
        glCompileShader(shader);
        GLint compiled;
        glGetShaderiv(shader, GL_COMPILE_STATUS, &compiled);
        if (compiled) {
            // compiled successfully
            return shader;
        } else {
            GLint blen = 0;
            GLsizei slen = 0;
            glGetShaderiv(shader, GL_INFO_LOG_LENGTH , &blen);
            if (blen > 1)
            {
                GLchar[] msg = new GLchar[blen + 1];
                glGetShaderInfoLog(shader, blen, &slen, msg.ptr);
                Log.d("Shader compilation error: ", fromStringz(msg.ptr));
            }
            return 0;
        }
    }

    bool compile() {
        glslversion = std.string.fromStringz(glGetString(GL_SHADING_LANGUAGE_VERSION)).dup;

        glslversionString.length = 0;
        glslversionInt = 0;
        foreach(ch; glslversion) {
            if (ch >= '0' && ch <= '9') {
                glslversionString ~= ch;
                glslversionInt = glslversionInt * 10 + (ch - '0');
            } else if (ch != '.')
                break;
        }

        vertexShader = compileShader(vertexSource, GL_VERTEX_SHADER);
        fragmentShader = compileShader(fragmentSource, GL_FRAGMENT_SHADER);
        if (!vertexShader || !fragmentShader) {
            error = true;
            return false;
        }
        program = glCreateProgram();
        glAttachShader(program, vertexShader);
        glAttachShader(program, fragmentShader);
        glLinkProgram(program);
        GLint isLinked = 0;
        glGetProgramiv(program, GL_LINK_STATUS, &isLinked);
        if (!isLinked) {
            GLint maxLength = 0;
            glGetProgramiv(program, GL_INFO_LOG_LENGTH, &maxLength);
            GLchar[] msg = new GLchar[maxLength + 1];
            glGetProgramInfoLog(program, maxLength, &maxLength, msg.ptr);
            Log.e("Error while linking program: ", fromStringz(msg.ptr));
            error = true;
            return false;
        }
        Log.d("Program linked successfully");
        
        if (!initLocations()) {
            Log.e("some of locations were not found");
            error = true;
        }
        initialized = true;
        Log.v("Program is initialized successfully");
        return !error;
    }

    /// override to init shader code locations
    abstract bool initLocations();
    
    ~this() {
        // TODO: cleanup
        if (program)
            glDeleteProgram(program);
        if (vertexShader)
            glDeleteShader(vertexShader);
        if (fragmentShader)
            glDeleteShader(fragmentShader);
        program = vertexShader = fragmentShader = 0;
        initialized = false;
    }

    /// returns true if program is ready for use (compiles program if not yet compiled)
    bool check()
    {
        if (error)
            return false;
        if (!initialized)
            if (!compile())
                return false;
        return true;
    }

    static GLuint currentProgram;
    /// binds program to current context
    void bind() {
        if(program != currentProgram) {
            checkgl!glUseProgram(program);
            currentProgram = program;
        }
    }

    /// unbinds program from current context
    static void unbind() {
        checkgl!glUseProgram(0);
        currentProgram = 0;
    }

    protected int[string] _uniformLocations;
    protected int[string] _attribLocations;

    /// get location for vertex attribute
    override int getVertexElementLocation(VertexElementType type) {
        return VERTEX_ELEMENT_NOT_FOUND;
    }

    /// get uniform location from program, returns -1 if location is not found
    int getUniformLocation(string variableName) {
        if (auto p = variableName in _uniformLocations)
            return *p;
        int res = checkgl!glGetUniformLocation(program, variableName.toStringz);
        if (res == -1)
            Log.e("glGetUniformLocation failed for " ~ variableName);
        _uniformLocations[variableName] = res;
        return res;
    }

    /// get attribute location from program, returns -1 if location is not found
    int getAttribLocation(string variableName) {
        if (auto p = variableName in _attribLocations)
            return *p;
        int res = checkgl!glGetAttribLocation(program, variableName.toStringz);
        if (res == -1)
            Log.e("glGetAttribLocation failed for " ~ variableName);
        _attribLocations[variableName] = res;
        return res;
    }

    override void setUniform(string uniformName, mat4 matrix) {
        checkgl!glUniformMatrix4fv(getUniformLocation(uniformName), 1, false, matrix.m.ptr);
    }

    override void setUniform(string uniformName, vec2 vec) {
        checkgl!glUniform2fv(getAttribLocation(uniformName), 1, vec.vec.ptr);
    }

    override void setUniform(string uniformName, vec3 vec) {
        checkgl!glUniform3fv(getAttribLocation(uniformName), 1, vec.vec.ptr);
    }

    override void setUniform(string uniformName, vec4 vec) {
        checkgl!glUniform4fv(getAttribLocation(uniformName), 1, vec.vec.ptr);
    }

    /// draw mesh using this program (program should be bound by this time and all uniforms should be set)
    override void draw(Mesh mesh) {
        VertexBuffer vb = mesh.vertexBuffer;
        if (!vb) {
            vb = new GLVertexBuffer();
            mesh.vertexBuffer = vb;
        }
        vb.draw(this);
    }
}

class SolidFillProgram : GLProgram {
    @property override string vertexSource() {
        return q{
            in vec3 vertex_position;
            in vec4 vertex_color;
            out vec4 col;
            uniform mat4 matrix;
            void main(void)
            {
                gl_Position = matrix * vec4(vertex_position, 1);
                col = vertex_color;
            }
        };
    }

    @property override string fragmentSource() {
        return q{
            in vec4 col;
            out vec4 outColor;
            void main(void)
            {
                outColor = col;
            }
        };
    }

    protected GLint matrixLocation;
    protected GLint vertexLocation;
    protected GLint colAttrLocation;
    override bool initLocations() {
        matrixLocation = getUniformLocation("matrix");
        vertexLocation = getAttribLocation("vertex_position");
        colAttrLocation = getAttribLocation("vertex_color");
        return matrixLocation >= 0 && vertexLocation >= 0 && colAttrLocation >= 0;
    }
    /// get location for vertex attribute
    override int getVertexElementLocation(VertexElementType type) {
        switch(type) with(VertexElementType) {
            case POSITION: 
                return vertexLocation;
            case COLOR: 
                return colAttrLocation;
            default:
                return VERTEX_ELEMENT_NOT_FOUND;
        }
    }

    VAO vao;
    VBO vbo;
    bool needToCreateVAO = true;
    protected void createVAO(float[] vertices, float[] colors) {
        vao = new VAO;
        vbo = new VBO;

        glVertexAttribPointer(vertexLocation, 3, GL_FLOAT, GL_FALSE, 0, cast(void*) 0);
        glVertexAttribPointer(colAttrLocation, 4, GL_FLOAT, GL_FALSE, 0, cast(void*) (vertices.length * float.sizeof));

        glEnableVertexAttribArray(vertexLocation);
        glEnableVertexAttribArray(colAttrLocation);

        needToCreateVAO = false;
    }

    protected void beforeExecute() {
        glEnable(GL_BLEND);
        checkgl!glDisable(GL_CULL_FACE);
        checkgl!glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        bind();
        checkgl!glUniformMatrix4fv(matrixLocation, 1, false, glSupport.projectionMatrix.m.ptr);
    }

    bool execute(float[] vertices, float[] colors) {
        if(!check())
            return false;
        beforeExecute();

        if(needToCreateVAO)
            createVAO(vertices, colors);

        vbo.bind();
        vbo.fill([vertices, colors]);

        vao.bind();
        checkgl!glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
        vao.unbind();
        return true;
    }

    void destroyBuffers() {
        destroy(vao);
        destroy(vbo);
        vao = null;
        vbo = null;
        needToCreateVAO = true;
    }
}

class LineProgram : SolidFillProgram {
    override bool execute(float[] vertices, float[] colors) {
        if(!check())
            return false;
        beforeExecute();

        if(needToCreateVAO)
            createVAO(vertices, colors);

        vbo.bind();
        vbo.fill([vertices, colors]);

        vao.bind();
        checkgl!glDrawArrays(GL_LINES, 0, 2);
        vao.unbind();
        return true;
    }
}

class TextureProgram : SolidFillProgram {
    @property override string vertexSource() {
        return q{
            in vec3 vertex_position;
            in vec4 vertex_color;
            in vec2 vertex_UV;
            out vec4 col;
            out vec2 UV;
            uniform mat4 matrix;
            void main(void)
            {
                gl_Position = matrix * vec4(vertex_position, 1);
                col = vertex_color;
                UV = vertex_UV;
            }
        };
    }
    @property override string fragmentSource() {
        return q{
            uniform sampler2D tex;
            in vec4 col;
            in vec2 UV;
            out vec4 outColor;
            void main(void)
            {
                outColor = texture(tex, UV) * col;
            }
        };
    }

    GLint texCoordLocation;
    override bool initLocations() {
        bool res = super.initLocations();
        texCoordLocation = getAttribLocation("vertex_UV");
        return res && texCoordLocation >= 0;
    }
    /// get location for vertex attribute
    override int getVertexElementLocation(VertexElementType type) {
        switch(type) with(VertexElementType) {
            case TEXCOORD0: 
                return texCoordLocation;
            default:
                return super.getVertexElementLocation(type);
        }
    }

    protected void createVAO(float[] vertices, float[] colors, float[] texcoords) {
        vao = new VAO;
        vbo = new VBO;

        glVertexAttribPointer(vertexLocation, 3, GL_FLOAT, GL_FALSE, 0, cast(void*) 0);
        glVertexAttribPointer(colAttrLocation, 4, GL_FLOAT, GL_FALSE, 0, cast(void*) (vertices.length * float.sizeof));
        glVertexAttribPointer(texCoordLocation, 2, GL_FLOAT, GL_FALSE, 0, cast(void*) ((vertices.length + colors.length) * float.sizeof));

        glEnableVertexAttribArray(vertexLocation);
        glEnableVertexAttribArray(colAttrLocation);
        glEnableVertexAttribArray(texCoordLocation);

        needToCreateVAO = false;
    }

    bool execute(float[] vertices, float[] colors, float[] texcoords, Tex2D texture, bool linear) {
        if(!check())
            return false;
        beforeExecute();

        texture.setup();
        texture.setSamplerParams(linear);

        if(needToCreateVAO)
            createVAO(vertices, colors, texcoords);

        vbo.bind();
        vbo.fill([vertices, colors, texcoords]);

        vao.bind();
        checkgl!glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
        vao.unbind();

        texture.unbind();
        return true;
    }
}


struct Color
{
    float r, g, b, a;
}

// utility function to fill 4-float array of vertex colors with converted CR 32bit color
private void FillColor(uint color, Color[] buf_slice) {
    float r = ((color >> 16) & 255) / 255.0;
    float g = ((color >> 8) & 255) / 255.0;
    float b = ((color >> 0) & 255) / 255.0;
    float a = (((color >> 24) & 255) ^ 255) / 255.0;
    foreach(ref col; buf_slice) {
        col.r = r;
        col.g = g;
        col.b = b;
        col.a = a;
    }
}

__gshared GLSupport _glSupport;
@property GLSupport glSupport() {
    if (!_glSupport) {
        Log.f("GLSupport is not initialized");
        assert(false, "GLSupport is not initialized");
    }
    if (!_glSupport.valid) {
        Log.e("GLSupport programs are not initialized");
    }
    return _glSupport;
}

/// initialize OpenGL suport helper (call when current OpenGL context is initialized)
bool initGLSupport(bool legacy = false) {
    import dlangui.platforms.common.platform : setOpenglEnabled;
    if (_glSupport && _glSupport.valid)
        return true;
    static bool DERELICT_GL3_RELOADED;
    static bool gl3ReloadedOk;
    static bool glReloadedOk;
    if (!DERELICT_GL3_RELOADED) {
        DERELICT_GL3_RELOADED = true;
        try {
            Log.v("Reloading DerelictGL3");
            import derelict.opengl3.gl3;
            DerelictGL3.missingSymbolCallback = &gl3MissingSymFunc;
            DerelictGL3.reload();
            gl3ReloadedOk = true;
        } catch (Exception e) {
            Log.e("Derelict exception while reloading DerelictGL3", e);
        }
        try {
            Log.v("Reloading DerelictGL");
            import derelict.opengl3.gl;
            DerelictGL.missingSymbolCallback = &gl3MissingSymFunc;
            DerelictGL.reload();
            glReloadedOk = true;
        } catch (Exception e) {
            Log.e("Derelict exception while reloading DerelictGL", e);
        }
    }
    if (!gl3ReloadedOk && !glReloadedOk) {
        Log.e("Neither DerelictGL3 nor DerelictGL were reloaded successfully");
        return false;
    }
    if (!gl3ReloadedOk)
        legacy = true;
    else if (!glReloadedOk)
        legacy = false;
    if (!_glSupport) {
        _glSupport = new GLSupport(legacy);
        if (_glSupport.valid || _glSupport.initShaders()) {
            Log.v("shaders are ok");
            setOpenglEnabled();
            Log.v("OpenGL is initialized ok");
            return true;
        } else {
            Log.e("Failed to compile shaders");
            // try opposite legacy flag
            if (_glSupport.legacyMode == legacy) {
                Log.i("Trying to reinit GLSupport with legacy flag ", !legacy);
                _glSupport = new GLSupport(!legacy);
                if (_glSupport.valid || _glSupport.initShaders()) {
                    Log.v("shaders are ok");
                    setOpenglEnabled();
                    Log.v("OpenGL is initialized ok");
                    return true;
                }
            }
        }
        return false;
    }
    if (_glSupport.valid || _glSupport.initShaders()) {
        setOpenglEnabled();
        return true;
    } else {
        Log.e("Failed to compile shaders");
        return false;
    }
}

/// OpenGL support helper
final class GLSupport {

    private bool _legacyMode;
    @property bool legacyMode() { return _legacyMode; }

    this(bool legacy = false) {
        if (legacy && !glLightfv) {
            Log.w("GLSupport legacy API is not supported");
            legacy = false;
        }
        _legacyMode = legacy;
    }

    SolidFillProgram _solidFillProgram;
    LineProgram _lineProgram;
    TextureProgram _textureProgram;

    @property bool valid() {
        return _legacyMode || _textureProgram && _solidFillProgram && _lineProgram;
    }

    bool initShaders() {
        if (_solidFillProgram is null) {
            Log.v("Compiling solid fill program");
            _solidFillProgram = new SolidFillProgram();
            if (!_solidFillProgram.compile())
                return false;
        }
        if (_lineProgram is null) {
            Log.v("Compiling line program");
            _lineProgram = new LineProgram();
            if (!_lineProgram.compile())
                return false;
        }
        if (_textureProgram is null) {
            Log.v("Compiling texture program");
            _textureProgram = new TextureProgram();
            if (!_textureProgram.compile())
                return false;
        }
        Log.d("Shaders compiled successfully");
        return true;
    }

    bool uninitShaders() {
        Log.d("Uniniting shaders");
        if (_solidFillProgram !is null) {
            destroy(_solidFillProgram);
            _solidFillProgram = null;
        }
        if (_lineProgram !is null) {
            destroy(_lineProgram);
            _lineProgram = null;
        }
        if (_textureProgram !is null) {
            destroy(_textureProgram);
            _textureProgram = null;
        }
        return true;
    }

    void destroyBuffers() {
        _solidFillProgram.destroyBuffers();
        _lineProgram.destroyBuffers();
        _textureProgram.destroyBuffers();
    }

    void setRotation(int x, int y, int rotationAngle) {
        /*
        this->rotationAngle = rotationAngle;
        rotationX = x;
        rotationY = y;
        if (!currentFramebufferId) {
            rotationY = bufferDy - rotationY;
        }

        QMatrix4x4 matrix2;
        matrix2.ortho(0, bufferDx, 0, bufferDy, 0.5f, 5.0f);
        if (rotationAngle) {
            matrix2.translate(rotationX, rotationY, 0);
            matrix2.rotate(rotationAngle, 0, 0, 1);
            matrix2.translate(-rotationX, -rotationY, 0);
        }
        matrix2.copyDataTo(m);
        */
    }

    void drawLine(Point p1, Point p2, uint color1, uint color2) {
        Color[2] colors;
        FillColor(color1, colors[0..1]);
        FillColor(color2, colors[1..2]);
        float x0 = cast(float)(p1.x);
        float y0 = cast(float)(bufferDy-p1.y);
        float x1 = cast(float)(p2.x);
        float y1 = cast(float)(bufferDy-p2.y);

        // don't flip for framebuffer
        if (currentFBO) {
            y0 = cast(float)(p1.y);
            y1 = cast(float)(p2.y);
        }

        float[3 * 2] vertices = [
            x0,y0,Z_2D,
            x1,y1,Z_2D
        ];
        if (_lineProgram !is null) {
            _lineProgram.execute(vertices, cast(float[])colors);
        } else
            Log.e("No program");
    }

    static immutable float Z_2D = -2.0f;
    void drawSolidFillRect(Rect rc, uint color1, uint color2, uint color3, uint color4) {
        Color[4] colors;
        FillColor(color1, colors[0..1]);
        FillColor(color2, colors[1..2]);
        FillColor(color3, colors[2..3]);
        FillColor(color4, colors[3..4]);
        float x0 = cast(float)(rc.left);
        float y0 = cast(float)(bufferDy-rc.top);
        float x1 = cast(float)(rc.right);
        float y1 = cast(float)(bufferDy-rc.bottom);

        // don't flip for framebuffer
        if (currentFBO) {
            y0 = cast(float)(rc.top);
            y1 = cast(float)(rc.bottom);
        }

        float[3 * 4] vertices = [
            x0,y0,Z_2D,
            x0,y1,Z_2D,
            x1,y0,Z_2D,
            x1,y1,Z_2D];

        if (_legacyMode) {
            glColor4f(1,1,1,1);
            glDisable(GL_CULL_FACE);
            glEnable(GL_BLEND);
            glDisable(GL_ALPHA_TEST);
            checkgl!glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
            checkgl!glEnableClientState(GL_VERTEX_ARRAY);
            checkgl!glEnableClientState(GL_COLOR_ARRAY);
            checkgl!glVertexPointer(3, GL_FLOAT, 0, cast(void*)vertices.ptr);
            checkgl!glColorPointer(4, GL_FLOAT, 0, cast(void*)colors);

            checkgl!glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

            glDisableClientState(GL_COLOR_ARRAY);
            glDisableClientState(GL_VERTEX_ARRAY);
            glDisable(GL_ALPHA_TEST);
            glDisable(GL_BLEND);
        } else {
            if (_solidFillProgram !is null) {
                _solidFillProgram.execute(vertices, cast(float[])colors);
            } else
                Log.e("No program");
        }
    }

    void drawColorAndTextureRect(Tex2D texture, int tdx, int tdy, Rect srcrc, Rect dstrc, uint color, bool linear) {
        drawColorAndTextureRect(texture, tdx, tdy, srcrc.left, srcrc.top, srcrc.width(), srcrc.height(), dstrc.left, dstrc.top, dstrc.width(), dstrc.height(), color, linear);
    }

    private void drawColorAndTextureRect(Tex2D texture, int tdx, int tdy, int srcx, int srcy, int srcdx, int srcdy, int xx, int yy, int dx, int dy, uint color, bool linear) {
        Color[4] colors;
        FillColor(color, colors);
        float dstx0 = cast(float)xx;
        float dsty0 = cast(float)(bufferDy - (yy));
        float dstx1 = cast(float)(xx + dx);
        float dsty1 = cast(float)(bufferDy - (yy + dy));

        // don't flip for framebuffer
        if (currentFBO) {
            dsty0 = cast(float)(yy);
            dsty1 = cast(float)(yy + dy);
        }

        float srcx0 = srcx / cast(float)tdx;
        float srcy0 = srcy / cast(float)tdy;
        float srcx1 = (srcx + srcdx) / cast(float)tdx;
        float srcy1 = (srcy + srcdy) / cast(float)tdy;
        float[3 * 4] vertices = [
            dstx0,dsty0,Z_2D,
            dstx0,dsty1,Z_2D,
            dstx1,dsty0,Z_2D,
            dstx1,dsty1,Z_2D];
        float[2 * 4] texcoords = [srcx0,srcy0, srcx0,srcy1, srcx1,srcy0, srcx1,srcy1];

        if (_legacyMode) {
            glDisable(GL_CULL_FACE);
            glEnable(GL_TEXTURE_2D);
            texture.setup();
            texture.setSamplerParams(linear);

            glColor4f(1,1,1,1);
            glDisable(GL_ALPHA_TEST);

            glEnable(GL_BLEND);
            checkgl!glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

            checkgl!glEnableClientState(GL_COLOR_ARRAY);
            checkgl!glEnableClientState(GL_VERTEX_ARRAY);
            checkgl!glEnableClientState(GL_TEXTURE_COORD_ARRAY);
            checkgl!glVertexPointer(3, GL_FLOAT, 0, cast(void*)vertices.ptr);
            checkgl!glTexCoordPointer(2, GL_FLOAT, 0, cast(void*)texcoords.ptr);
            checkgl!glColorPointer(4, GL_FLOAT, 0, cast(void*)colors.ptr);

            checkgl!glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

            glDisableClientState(GL_TEXTURE_COORD_ARRAY);
            glDisableClientState(GL_VERTEX_ARRAY);
            glDisableClientState(GL_COLOR_ARRAY);
            glDisable(GL_BLEND);
            glDisable(GL_ALPHA_TEST);
            glDisable(GL_TEXTURE_2D);
        } else {
            _textureProgram.execute(vertices, cast(float[])colors, texcoords, texture, linear);
        }
    }

    /// call glFlush
    void flushGL() {
        checkgl!glFlush();
    }

    bool setTextureImage(Tex2D texture, int dx, int dy, ubyte * pixels) {
        checkError("before setTextureImage");
        texture.bind();
        checkgl!glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
        texture.setSamplerParams(true, true);

        // ORIGINAL: glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, dx, dy, 0, GL_RGBA, GL_UNSIGNED_BYTE, pixels);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, dx, dy, 0, GL_RGBA, GL_UNSIGNED_BYTE, pixels);
        if (checkError("updateTexture - glTexImage2D")) {
            Log.e("Cannot set image for texture");
            return false;
        }
        texture.unbind();
        return true;
    }

    bool setTextureImageAlpha(Tex2D texture, int dx, int dy, ubyte * pixels) {
        checkError("before setTextureImageAlpha");
        texture.bind();
        checkgl!glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
        texture.setSamplerParams(true, true);

        glTexImage2D(GL_TEXTURE_2D, 0, GL_ALPHA, dx, dy, 0, GL_ALPHA, GL_UNSIGNED_BYTE, pixels);
        if (checkError("setTextureImageAlpha - glTexImage2D")) {
            Log.e("Cannot set image for texture");
            return false;
        }
        texture.unbind();
        return true;
    }

    private FBO currentFBO;

    /// returns texture for buffer, null if failed
    bool createFramebuffer(out Tex2D texture, out FBO fbo, int dx, int dy) {
        checkError("before createFramebuffer");
        bool res = true;
        texture = new Tex2D();
        if (!texture.ID)
            return false;
        checkError("glBindTexture GL_TEXTURE_2D");
        FBO f = new FBO();
        if (!f.ID)
            return false;
        fbo = f;

        checkgl!glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, dx, dy, 0, GL_RGB, GL_UNSIGNED_SHORT_5_6_5, null);

        texture.setSamplerParams(true, true);

        checkgl!glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, texture.ID, 0);
        // Always check that our framebuffer is ok
        if(checkgl!glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
            Log.e("glFramebufferTexture2D failed");
            res = false;
        }
        checkgl!glClearColor(0.5f, 0.5f, 0.5f, 1.0f);
        checkgl!glClear(GL_COLOR_BUFFER_BIT);
        currentFBO = fbo;

        texture.unbind();
        fbo.unbind();

        return res;
    }

    void deleteFramebuffer(ref FBO fbo) {
        if (fbo.ID != 0) {
            destroy(fbo);
        }
        currentFBO = null;
    }

    bool bindFramebuffer(FBO fbo) {
        fbo.bind();
        currentFBO = fbo;
        return !checkError("glBindFramebuffer");
    }

    void clearDepthBuffer() {
        glClear(GL_DEPTH_BUFFER_BIT);
    }

    /// projection matrix
    /// current gl buffer width
    private int bufferDx;
    /// current gl buffer height
    private int bufferDy;
    private mat4 _projectionMatrix;

    @property ref mat4 projectionMatrix() {
        return _projectionMatrix;
    }

    void setOrthoProjection(Rect windowRect, Rect view) {
        flushGL();
        bufferDx = windowRect.width;
        bufferDy = windowRect.height;
        _projectionMatrix.setOrtho(view.left, view.right, view.top, view.bottom, 0.5f, 50.0f);

        if (_legacyMode) {
            glMatrixMode(GL_PROJECTION);
            //checkgl!glPushMatrix();
            //glLoadIdentity();
            glLoadMatrixf(_projectionMatrix.m.ptr);
            //glOrthof(0, _dx, 0, _dy, -1.0f, 1.0f);
            glMatrixMode(GL_MODELVIEW);
            //checkgl!glPushMatrix();
            glLoadIdentity();
        }
        checkgl!glViewport(view.left, currentFBO ? view.top : windowRect.height - view.bottom, view.width, view.height);
    }

    void setPerspectiveProjection(Rect windowRect, Rect view, float fieldOfView, float nearPlane, float farPlane) {
        flushGL();
        bufferDx = windowRect.width;
        bufferDy = windowRect.height;
        float aspectRatio = cast(float)view.width / cast(float)view.height;
        _projectionMatrix.setPerspective(fieldOfView, aspectRatio, nearPlane, farPlane);
        if (_legacyMode) {
            glMatrixMode(GL_PROJECTION);
            //checkgl!glPushMatrix();
            //glLoadIdentity();
            glLoadMatrixf(_projectionMatrix.m.ptr);
            //glOrthof(0, _dx, 0, _dy, -1.0f, 1.0f);
            glMatrixMode(GL_MODELVIEW);
            //checkgl!glPushMatrix();
            glLoadIdentity();
        }
        checkgl!glViewport(view.left, currentFBO ? view.top : windowRect.height - view.bottom, view.width, view.height);
    }
}

enum GLObjectTypes { Buffer, VertexArray, Texture, Framebuffer };
/** RAII OpenGL object template.
  * Note: on construction it binds itself to the target, and it binds 0 to target on destruction.
  * All methods (except ctor, dtor, bind(), unbind() and setup()) does not perform binding.
*/
class GLObject(GLObjectTypes type, GLuint target = 0) {
    immutable GLuint ID;
    //alias ID this; // good, but it confuses destroy()

    this() {
        GLuint handle;
        mixin("checkgl!glGen" ~ to!string(type) ~ "s(1, &handle);");
        ID = handle;
        bind();
    }

    ~this() {
        unbind();
        mixin("checkgl!glDelete" ~ to!string(type) ~ "s(1, &ID);");
    }

    void bind() {
        static if(target != 0)
            mixin("glBind" ~ to!string(type) ~ "(" ~ to!string(target) ~ ", ID);");
        else
            mixin("glBind" ~ to!string(type) ~ "(ID);");
    }

    static void unbind() {
        static if(target != 0)
            mixin("checkgl!glBind" ~ to!string(type) ~ "(" ~ to!string(target) ~ ", 0);");
        else
            mixin("checkgl!glBind" ~ to!string(type) ~ "(0);");
    }
    
    static if(type == GLObjectTypes.Buffer)
    {
        void fill(float[][] buffs) {
            int length;
            foreach(b; buffs)
                length += b.length;
            glBufferData(target,
                         length * float.sizeof,
                         null,
                         GL_STREAM_DRAW);
            int offset;
            foreach(b; buffs) {
                glBufferSubData(target,
                                offset,
                                b.length * float.sizeof,
                                b.ptr);
                offset += b.length * float.sizeof;
            }
        }
    }

    static if(type == GLObjectTypes.Texture)
    {
        void setSamplerParams(bool linear, bool clamp = false) {
            glTexParameteri(target, GL_TEXTURE_MAG_FILTER, linear ? GL_LINEAR : GL_NEAREST);
            glTexParameteri(target, GL_TEXTURE_MIN_FILTER, linear ? GL_LINEAR : GL_NEAREST);
            checkError("filtering - glTexParameteri");
            if(clamp) {
                glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
                glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
                checkError("clamp - glTexParameteri");
            }
        }

        void setup(GLuint binding = 0) {
            glActiveTexture(GL_TEXTURE0 + binding);
            glBindTexture(target, ID);
            checkError("setup texture");
        }
    }
}
alias VAO = GLObject!(GLObjectTypes.VertexArray);
alias VBO = GLObject!(GLObjectTypes.Buffer, GL_ARRAY_BUFFER);
alias Tex2D = GLObject!(GLObjectTypes.Texture, GL_TEXTURE_2D);
alias FBO = GLObject!(GLObjectTypes.Framebuffer, GL_FRAMEBUFFER);

class GLVertexBuffer : VertexBuffer {
    protected VertexFormat _format;
    protected IndexFragment[] _indexFragments;
    protected int _vertexCount;
    protected GLuint _vertexBuffer;
    protected GLuint _indexBuffer;
    protected GLuint _vao;

    this() {
        assertgl!glGenBuffers(1, &_vertexBuffer);
        assertgl!glGenBuffers(1, &_indexBuffer);
        assertgl!glGenVertexArrays(1, &_vao);
    }

    ~this() {
        checkgl!glDeleteBuffers(1, &_vertexBuffer);
        checkgl!glDeleteBuffers(1, &_indexBuffer);
        checkgl!glDeleteVertexArrays(1, &_vao);
    }

    /// bind into current context
    override void bind() {
        checkgl!glBindVertexArray(_vao);

        // TODO: is it necessary to bind vertex/index buffers?
        // specify vertex buffer
        //checkgl!glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
        // specify index buffer
        //checkgl!glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
    }

    /// unbind from current context
    override void unbind() {
        checkgl!glBindVertexArray(0);
        checkgl!glBindBuffer(GL_ARRAY_BUFFER, 0);
        checkgl!glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
    }

    /// update vertex element locations for effect/shader program
    void enableAttributes(GraphicsEffect effect) {
        // specify vertex buffer
        checkgl!glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
        // specify index buffer
        checkgl!glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
        int offset = 0;
        for(int i = 0; i < _format.length; i++) {
            int loc = effect.getVertexElementLocation(_format[i].type);
            if (loc >= 0) {
                checkgl!glVertexAttribPointer(loc, _format[i].size, GL_FLOAT, GL_FALSE, _format.vertexSize, cast(char*)(offset));
                checkgl!glEnableVertexAttribArray(loc);
            } else {
                Log.d("Attribute location not found for ", _format[i].type);
            }
            offset += _format[i].byteSize;
        }
    }

    void disableAttributes(GraphicsEffect effect) {
        for(int i = 0; i < _format.length; i++) {
            int loc = effect.getVertexElementLocation(_format[i].type);
            if (loc >= 0) {
                checkgl!glDisableVertexAttribArray(loc);
            }
        }
    }

    /// set or change data
    override void setData(Mesh mesh) {
        _format = mesh.vertexFormat;
        _indexFragments = mesh.indexFragments;
        _vertexCount = mesh.vertexCount;
        // vertex buffer
        checkgl!glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
        checkgl!glBufferData(GL_ARRAY_BUFFER, _format.vertexSize * mesh.vertexCount, mesh.vertexData.ptr, GL_STATIC_DRAW);
        // index buffer
        checkgl!glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
        const(ushort[]) indexData = mesh.indexData;
        checkgl!glBufferData(GL_ELEMENT_ARRAY_BUFFER, ushort.sizeof * mesh.indexData.length, indexData.ptr, GL_STATIC_DRAW);
        // vertex layout
        checkgl!glBindVertexArray(_vao);
        // specify vertex buffer
        checkgl!glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
        // specify index buffer
        checkgl!glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);

        unbind();
    }

    /// draw mesh using specified effect
    override void draw(GraphicsEffect effect) {
        bind();
        enableAttributes(effect);
        foreach (fragment; _indexFragments) {
            checkgl!glDrawRangeElements(primitiveTypeToGL(fragment.type), 
                                0, _vertexCount, 
                                fragment.end - fragment.start, 
                                GL_UNSIGNED_SHORT, cast(char*)(fragment.start * short.sizeof));
        }
        disableAttributes(effect);
        unbind();
    }
}

GLenum primitiveTypeToGL(PrimitiveType type) {
    switch(type) with (PrimitiveType) {
        case triangles:
            return GL_TRIANGLES;
        case triangleStripes:
            return GL_TRIANGLE_STRIP;
        case lines:
            return GL_LINES;
        case lineStripes:
            return GL_LINE_STRIP;
        case points:
        default:
            return GL_POINTS;
    }
}
