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
static if (BACKEND_GUI):
static if (ENABLE_OPENGL):

public import dlangui.core.math3d;

import dlangui.core.logger;
import dlangui.core.types;

import std.conv;
import std.string;
import std.array;

version (Android) {
    enum SUPPORT_LEGACY_OPENGL = false;
    public import EGL.eglplatform : EGLint;
    public import EGL.egl;
    //public import GLES2.gl2;
    public import GLES3.gl3;
    
    static if (SUPPORT_LEGACY_OPENGL) {
        public import GLES.gl : glEnableClientState, glLightfv, glColor4f, GL_ALPHA_TEST, GL_VERTEX_ARRAY, 
		    GL_COLOR_ARRAY, glVertexPointer, glColorPointer, glDisableClientState, 
		    GL_TEXTURE_COORD_ARRAY, glTexCoordPointer, glColorPointer, glMatrixMode, 
		    glLoadMatrixf, glLoadIdentity, GL_PROJECTION, GL_MODELVIEW;
	}

} else {
    enum SUPPORT_LEGACY_OPENGL = true;
    public import derelict.opengl3.types;
    public import derelict.opengl3.gl3;
    public import derelict.opengl3.gl;

derelict.util.exception.ShouldThrow gl3MissingSymFunc( string symName ) {
    import std.algorithm : equal;
    static import derelict.util.exception;
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


}

import dlangui.graphics.scene.mesh;
import dlangui.graphics.scene.effect;


//extern (C) void func(int n);
//pragma(msg, __traits(identifier, func));

/**
 * Convenient wrapper around glGetError()
 * Using: checkgl!glFunction(funcParams);
 * TODO use one of the DEBUG extensions
 */
template checkgl(alias func)
{
    debug auto checkgl(string functionName=__FUNCTION__, int line=__LINE__, Args...)(Args args)
    {
        scope(success) checkError(__traits(identifier, func), functionName, line);
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

class GLProgram : dlangui.graphics.scene.mesh.GraphicsEffect {
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
            if(type == GL_VERTEX_SHADER) {
                code = replace(code, "in ", "attribute ");
                code = replace(code, "out ", "varying ");
            } else {
                code = replace(code, "in ", "varying ");
                code = replace(code, "out vec4 outColor;", "");
                code = replace(code, "outColor", "gl_FragColor");
            }
        }
    }

    private GLuint compileShader(string src, GLuint type) {
        import std.string : toStringz, fromStringz;

        char[] sourceCode;
        if (glslversionString.length) {
            sourceCode ~= "#version ";
            sourceCode ~= glslversionString;
            sourceCode ~= "\n";
        }
        sourceCode ~= src;
        compatibilityFixes(sourceCode, type);

        Log.d("compileShader: glslVersion = ", glslversion, ", type: ", (type == GL_VERTEX_SHADER ? "GL_VERTEX_SHADER" : (type == GL_FRAGMENT_SHADER ? "GL_FRAGMENT_SHADER" : "UNKNOWN")));
        //Log.v("Shader code:\n", sourceCode);
        GLuint shader = checkgl!glCreateShader(type);
        const char * psrc = sourceCode.toStringz;
        checkgl!glShaderSource(shader, 1, &psrc, null);
        checkgl!glCompileShader(shader);
        GLint compiled;
        checkgl!glGetShaderiv(shader, GL_COMPILE_STATUS, &compiled);
        if (compiled) {
            // compiled successfully
            return shader;
        } else {
            Log.e("Failed to compile shader source:\n", sourceCode);
            GLint blen = 0;
            GLsizei slen = 0;
            checkgl!glGetShaderiv(shader, GL_INFO_LOG_LENGTH , &blen);
            if (blen > 1)
            {
                GLchar[] msg = new GLchar[blen + 1];
                checkgl!glGetShaderInfoLog(shader, blen, &slen, msg.ptr);
                Log.e("Shader compilation error: ", fromStringz(msg.ptr));
            }
            return 0;
        }
    }

    bool compile() {
        glslversion = checkgl!fromStringz(cast(const char *)glGetString(GL_SHADING_LANGUAGE_VERSION)).dup;
        glslversionString.length = 0;
        glslversionInt = 0;
        foreach(ch; glslversion) {
            if (ch >= '0' && ch <= '9') {
                glslversionString ~= ch;
                glslversionInt = glslversionInt * 10 + (ch - '0');
            } else if (ch != '.')
                break;
        }
        version (Android) {
            glslversionInt = 130;
        }

        vertexShader = compileShader(vertexSource, GL_VERTEX_SHADER);
        fragmentShader = compileShader(fragmentSource, GL_FRAGMENT_SHADER);
        if (!vertexShader || !fragmentShader) {
            error = true;
            return false;
        }
        program = checkgl!glCreateProgram();
        checkgl!glAttachShader(program, vertexShader);
        checkgl!glAttachShader(program, fragmentShader);
        checkgl!glLinkProgram(program);
        GLint isLinked = 0;
        checkgl!glGetProgramiv(program, GL_LINK_STATUS, &isLinked);
        if (!isLinked) {
            GLint maxLength = 0;
            checkgl!glGetProgramiv(program, GL_INFO_LOG_LENGTH, &maxLength);
            GLchar[] msg = new GLchar[maxLength + 1];
            checkgl!glGetProgramInfoLog(program, maxLength, &maxLength, msg.ptr);
            Log.e("Error while linking program: ", fromStringz(msg.ptr));
            error = true;
            return false;
        }
        Log.d("Program linked successfully");

        initStandardLocations();
        if (!initLocations()) {
            Log.e("some of locations were not found");
            error = true;
        }
        initialized = true;
        Log.v("Program is initialized successfully");
        return !error;
    }


    void initStandardLocations() {
        for(DefaultUniform id = DefaultUniform.min; id <= DefaultUniform.max; id++) {
            _uniformIdLocations[id] = getUniformLocation(to!string(id));
        }
        for(DefaultAttribute id = DefaultAttribute.min; id <= DefaultAttribute.max; id++) {
            _attribIdLocations[id] = getAttribLocation(to!string(id));
        }
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
    protected int[DefaultUniform.max + 1] _uniformIdLocations;
    protected int[DefaultAttribute.max + 1] _attribIdLocations;

    /// get location for vertex attribute
    override int getVertexElementLocation(VertexElementType type) {
        return VERTEX_ELEMENT_NOT_FOUND;
    }


    /// get uniform location from program by uniform id, returns -1 if location is not found
    int getUniformLocation(DefaultUniform uniform) {
        return _uniformIdLocations[uniform];
    }

    /// get uniform location from program, returns -1 if location is not found
    int getUniformLocation(string variableName) {
        if (auto p = variableName in _uniformLocations)
            return *p;
        int res = checkgl!glGetUniformLocation(program, variableName.toStringz);
        //if (res == -1)
        //    Log.e("glGetUniformLocation failed for " ~ variableName);
        _uniformLocations[variableName] = res;
        return res;
    }

    /// get attribute location from program by uniform id, returns -1 if location is not found
    int getAttribLocation(DefaultAttribute id) {
        return _attribIdLocations[id];
    }

    /// get attribute location from program, returns -1 if location is not found
    int getAttribLocation(string variableName) {
        if (auto p = variableName in _attribLocations)
            return *p;
        int res = checkgl!glGetAttribLocation(program, variableName.toStringz);
        //if (res == -1)
        //    Log.e("glGetAttribLocation failed for " ~ variableName);
        _attribLocations[variableName] = res;
        return res;
    }

    override void setUniform(string uniformName, const vec2[] vec) {
        checkgl!glUniform2fv(getUniformLocation(uniformName), cast(int)vec.length, cast(const(float)*)vec.ptr);
    }

    override void setUniform(DefaultUniform id, const vec2[] vec) {
        checkgl!glUniform2fv(getUniformLocation(id), cast(int)vec.length, cast(const(float)*)vec.ptr);
    }

    override void setUniform(string uniformName, vec2 vec) {
        checkgl!glUniform2fv(getUniformLocation(uniformName), 1, vec.vec.ptr);
    }

    override void setUniform(DefaultUniform id, vec2 vec) {
        checkgl!glUniform2fv(getUniformLocation(id), 1, vec.vec.ptr);
    }

    override void setUniform(string uniformName, vec3 vec) {
        checkgl!glUniform3fv(getUniformLocation(uniformName), 1, vec.vec.ptr);
    }

    override void setUniform(DefaultUniform id, vec3 vec) {
        checkgl!glUniform3fv(getUniformLocation(id), 1, vec.vec.ptr);
    }

    override void setUniform(string uniformName, const vec3[] vec) {
        checkgl!glUniform3fv(getUniformLocation(uniformName), cast(int)vec.length, cast(const(float)*)vec.ptr);
    }

    override void setUniform(DefaultUniform id, const vec3[] vec) {
        checkgl!glUniform3fv(getUniformLocation(id), cast(int)vec.length, cast(const(float)*)vec.ptr);
    }

    override void setUniform(string uniformName, vec4 vec) {
        checkgl!glUniform4fv(getUniformLocation(uniformName), 1, vec.vec.ptr);
    }

    override void setUniform(DefaultUniform id, vec4 vec) {
        checkgl!glUniform4fv(getUniformLocation(id), 1, vec.vec.ptr);
    }

    override void setUniform(string uniformName, const vec4[] vec) {
        checkgl!glUniform4fv(getUniformLocation(uniformName), cast(int)vec.length, cast(const(float)*)vec.ptr);
    }

    override void setUniform(DefaultUniform id, const vec4[] vec) {
        checkgl!glUniform4fv(getUniformLocation(id), cast(int)vec.length, cast(const(float)*)vec.ptr);
    }

    override void setUniform(string uniformName, ref const(mat4) matrix) {
        checkgl!glUniformMatrix4fv(getUniformLocation(uniformName), 1, false, matrix.m.ptr);
    }

    override void setUniform(DefaultUniform id, ref const(mat4) matrix) {
        checkgl!glUniformMatrix4fv(getUniformLocation(id), 1, false, matrix.m.ptr);
    }

    override void setUniform(string uniformName, const(mat4)[] matrix) {
        checkgl!glUniformMatrix4fv(getUniformLocation(uniformName), cast(int)matrix.length, false, cast(const(float)*)matrix.ptr);
    }

    override void setUniform(DefaultUniform id, const(mat4)[] matrix) {
        checkgl!glUniformMatrix4fv(getUniformLocation(id), cast(int)matrix.length, false, cast(const(float)*)matrix.ptr);
    }

    override void setUniform(string uniformName, float v) {
        checkgl!glUniform1f(getUniformLocation(uniformName), v);
    }

    override void setUniform(DefaultUniform id, float v) {
        checkgl!glUniform1f(getUniformLocation(id), v);
    }

    override void setUniform(string uniformName, const float[] v) {
        checkgl!glUniform1fv(getUniformLocation(uniformName), cast(int)v.length, cast(const(float)*)v.ptr);
    }

    override void setUniform(DefaultUniform id, const float[] v) {
        checkgl!glUniform1fv(getUniformLocation(id), cast(int)v.length, cast(const(float)*)v.ptr);
    }

    /// returns true if effect has uniform
    override bool hasUniform(DefaultUniform id) {
        return getUniformLocation(id) >= 0;
    }

    /// returns true if effect has uniform
    override bool hasUniform(string uniformName) {
        return getUniformLocation(uniformName) >= 0;
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
            in vec3 a_position;
            in vec4 a_color;
            out vec4 col;
            uniform mat4 u_worldViewProjectionMatrix;
            void main(void)
            {
                gl_Position = u_worldViewProjectionMatrix * vec4(a_position, 1);
                col = a_color;
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
        matrixLocation = getUniformLocation(DefaultUniform.u_worldViewProjectionMatrix);
        vertexLocation = getAttribLocation(DefaultAttribute.a_position);
        colAttrLocation = getAttribLocation(DefaultAttribute.a_color);
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
    EBO ebo;

    protected void createVAO(float[] vertices, float[] colors) {
        if (!vao) {
            vao = new VAO;
            vbo = new VBO;
            ebo = new EBO;
        }
        vbo.bind();
        ebo.bind();
        vao.bind();

        glVertexAttribPointer(vertexLocation, 3, GL_FLOAT, GL_FALSE, 0, cast(void*) 0);
        glVertexAttribPointer(colAttrLocation, 4, GL_FLOAT, GL_FALSE, 0, cast(void*) (vertices.length * float.sizeof));

        glEnableVertexAttribArray(vertexLocation);
        glEnableVertexAttribArray(colAttrLocation);
    }

    protected void beforeExecute() {
        glEnable(GL_BLEND);
        checkgl!glDisable(GL_CULL_FACE);
        checkgl!glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        bind();
        setUniform(DefaultUniform.u_worldViewProjectionMatrix, glSupport.projectionMatrix);
        //checkgl!glUniformMatrix4fv(matrixLocation, 1, false, glSupport.projectionMatrix.m.ptr);
    }

    bool execute(float[] vertices, float[] colors, int[] indexes) {
        if(!check())
            return false;
        beforeExecute();

        createVAO(vertices, colors);

        vbo.bind();
        vbo.fill([vertices, colors]);

        ebo.bind();
        ebo.fill(indexes);

        vao.bind();
        checkgl!glDrawElements(GL_TRIANGLES, cast(int)indexes.length, GL_UNSIGNED_INT, cast(void*)null);

        vao.unbind();
        vbo.unbind();
        ebo.unbind();

        return true;
    }

    void destroyBuffers() {
        destroy(vao);
        destroy(vbo);
        destroy(ebo);
        vao = null;
        vbo = null;
        ebo = null;
    }
}

class LineProgram : SolidFillProgram {
    override bool execute(float[] vertices, float[] colors, int[] indexes) {
        if(!check())
            return false;
        beforeExecute();

        createVAO(vertices, colors);

        vbo.bind();
        vbo.fill([vertices, colors]);

        ebo.bind();
        ebo.fill(indexes);

        vao.bind();
        checkgl!glDrawElements(GL_LINES, cast(int)indexes.length, GL_UNSIGNED_INT, cast(void*)null);

        vao.unbind();
        vbo.unbind();
        ebo.unbind();
        return true;
    }
}

class TextureProgram : SolidFillProgram {
    @property override string vertexSource() {
        return q{
            in vec3 a_position;
            in vec4 a_color;
            in vec2 a_texCoord;
            out vec4 col;
            out vec2 UV;
            uniform mat4 u_worldViewProjectionMatrix;
            void main(void)
            {
                gl_Position = u_worldViewProjectionMatrix * vec4(a_position, 1);
                col = a_color;
                UV = a_texCoord;
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
        texCoordLocation = getAttribLocation(DefaultAttribute.a_texCoord);
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
        if (!vao) {
            vao = new VAO;
            vbo = new VBO;
            ebo = new EBO;
        }
        vbo.bind();
        ebo.bind();
        vao.bind();

        glVertexAttribPointer(vertexLocation, 3, GL_FLOAT, GL_FALSE, 0, cast(void*) 0);
        glVertexAttribPointer(colAttrLocation, 4, GL_FLOAT, GL_FALSE, 0, cast(void*) (vertices.length * float.sizeof));
        glVertexAttribPointer(texCoordLocation, 2, GL_FLOAT, GL_FALSE, 0, cast(void*) ((vertices.length + colors.length) * float.sizeof));

        glEnableVertexAttribArray(vertexLocation);
        glEnableVertexAttribArray(colAttrLocation);
        glEnableVertexAttribArray(texCoordLocation);
    }

    bool execute(float[] vertices, float[] colors, float[] texcoords, Tex2D texture, bool linear, int[] indexes) {
        if(!check())
            return false;
        beforeExecute();

        texture.setup();
        texture.setSamplerParams(linear);

        createVAO(vertices, colors, texcoords);

        vbo.bind();
        vbo.fill([vertices, colors, texcoords]);

        ebo.bind();
        ebo.fill(indexes);

        vao.bind();

        checkgl!glDrawElements(GL_TRIANGLES, cast(int)indexes.length, GL_UNSIGNED_INT, cast(void*)null);

        vao.unbind();
        vbo.unbind();
        ebo.unbind();

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
    version(Android) {
        Log.d("initGLSupport");
    } else {
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
    }
    if (!_glSupport) {
        Log.d("glSupport not initialized: trying to create");
        _glSupport = new GLSupport(legacy);
        if (_glSupport.valid || _glSupport.initShaders()) {
            Log.v("shaders are ok");
            setOpenglEnabled();
            Log.v("OpenGL is initialized ok");
            return true;
        } else {
            Log.e("Failed to compile shaders");
            version (Android) {
                // do not recreate legacy mode
            } else {
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
    @property batch() { return _batch; }

    this(bool legacy = false) {
        _batch = new OpenGLBatch();
    	version (Android) {
            Log.d("creating GLSupport");
    	} else {
    	    if (legacy && !glLightfv) {
    		    Log.w("GLSupport legacy API is not supported");
    		    legacy = false;
    	    }
    	}
        _legacyMode = legacy;
    }

    OpenGLBatch _batch;

    SolidFillProgram _solidFillProgram;
    LineProgram _lineProgram;
    TextureProgram _textureProgram;

    @property bool valid() {
        return _legacyMode || _textureProgram && _solidFillProgram && _lineProgram;
    }

    bool initShaders() {
        Log.i("initShaders() is called");
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
        if (_solidFillProgram)
            _solidFillProgram.destroyBuffers();
        if (_lineProgram)
            _lineProgram.destroyBuffers();
        if (_textureProgram)
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

    /// one rect is one line (left, top) - (right, bottom); for one line there are two color items
    void drawLines(Rect[] lines, uint[] vertexColors) {
        Color[] colors;
        colors.length = vertexColors.length;
        for (uint i = 0; i < vertexColors.length; i++)
            FillColor(vertexColors[i], colors[i .. i + 1]);

        float[] vertexArray;
        vertexArray.assumeSafeAppend();
        for (uint i = 0; i < lines.length; i++) {
            Rect rc = lines[i];

            float x0 = cast(float)(rc.left);
            float y0 = cast(float)(bufferDy-rc.top);
            float x1 = cast(float)(rc.right);
            float y1 = cast(float)(bufferDy-rc.bottom);

            // don't flip for framebuffer
            if (currentFBO) {
                y0 = cast(float)(rc.top);
                y1 = cast(float)(rc.bottom);
            }

            vertexArray ~= x0;
            vertexArray ~= y0;
            vertexArray ~= Z_2D;
            vertexArray ~= x1;
            vertexArray ~= y1;
            vertexArray ~= Z_2D;
        }

        int[] indexes = makeLineIndexesArray(lines.length);

        if (_legacyMode) {
            static if (SUPPORT_LEGACY_OPENGL) {
                glColor4f(1,1,1,1);
                glDisable(GL_CULL_FACE);
                glEnable(GL_BLEND);
                glDisable(GL_ALPHA_TEST);
                checkgl!glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                checkgl!glEnableClientState(GL_VERTEX_ARRAY);
                checkgl!glEnableClientState(GL_COLOR_ARRAY);
                checkgl!glVertexPointer(3, GL_FLOAT, 0, cast(void*)vertexArray.ptr);
                checkgl!glColorPointer(4, GL_FLOAT, 0, cast(void*)colors.ptr);

                checkgl!glDrawElements(GL_LINES, cast(int)indexes.length, GL_UNSIGNED_INT, cast(void*)indexes.ptr);

                glDisableClientState(GL_COLOR_ARRAY);
                glDisableClientState(GL_VERTEX_ARRAY);
                glDisable(GL_ALPHA_TEST);
                glDisable(GL_BLEND);
            }
        } else {
            if (_lineProgram !is null) {
                _lineProgram.execute(vertexArray, cast(float[])colors, indexes);
            } else
                Log.e("No program");
        }
    }

    static immutable float Z_2D = -2.0f;

    /// make indexes for rectangle TRIANGLES (2 triangles == 6 vertexes per rect)
    protected int[] makeRectangleIndexesArray(size_t rectCount) {
        int[] indexes;
        indexes.assumeSafeAppend();
        for (uint i = 0; i < rectCount; i++) {
            indexes ~= i * 4 + 0;
            indexes ~= i * 4 + 1;
            indexes ~= i * 4 + 2;
            indexes ~= i * 4 + 1;
            indexes ~= i * 4 + 2;
            indexes ~= i * 4 + 3;
        }
        return indexes;
    }

    /// make indexes for LINES
    protected int[] makeLineIndexesArray(size_t lineCount) {
        int[] indexes;
        indexes.assumeSafeAppend();
        for (uint i = 0; i < lineCount; i++) {
            indexes ~= i * 2 + 0;
            indexes ~= i * 2 + 1;
        }
        return indexes;
    }

    void drawSolidFillRects(Rect[] rects, uint[] vertexColors) {
        //Log.v("drawSolidFillRects rects:", rects.length, " colors:", vertexColors.length);
        float[] colors = convertColors(vertexColors);

        float[] vertexArray;
        vertexArray.assumeSafeAppend();

        for (uint i = 0; i < rects.length; i++) {
            Rect rc = rects[i];

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

            vertexArray ~= vertices;
        }

        int[] indexes = makeRectangleIndexesArray(rects.length);

        if (_legacyMode) {
            static if (SUPPORT_LEGACY_OPENGL) {
                glColor4f(1,1,1,1);
                glDisable(GL_CULL_FACE);
                glEnable(GL_BLEND);
                glDisable(GL_ALPHA_TEST);
                checkgl!glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                checkgl!glEnableClientState(GL_VERTEX_ARRAY);
                checkgl!glEnableClientState(GL_COLOR_ARRAY);
                checkgl!glVertexPointer(3, GL_FLOAT, 0, cast(void*)vertexArray.ptr);
                checkgl!glColorPointer(4, GL_FLOAT, 0, cast(void*)colors.ptr);

                checkgl!glDrawElements(GL_TRIANGLES, cast(int)indexes.length, GL_UNSIGNED_INT, cast(void*)indexes.ptr);

                glDisableClientState(GL_COLOR_ARRAY);
                glDisableClientState(GL_VERTEX_ARRAY);
                glDisable(GL_ALPHA_TEST);
                glDisable(GL_BLEND);
            }
        } else {
            if (_solidFillProgram !is null) {
                _solidFillProgram.execute(vertexArray, colors, indexes);
            } else
                Log.e("No program");
        }
    }

    float[] convertColors(uint[] cols) {
        float[] colors;
        colors.assumeSafeAppend();
        colors.length = cols.length * 4;
        for (uint i = 0; i < cols.length; i++) {
            uint color = cols[i];
            float r = ((color >> 16) & 255) / 255.0;
            float g = ((color >> 8) & 255) / 255.0;
            float b = ((color >> 0) & 255) / 255.0;
            float a = (((color >> 24) & 255) ^ 255) / 255.0;
            colors[i * 4 + 0] = r;
            colors[i * 4 + 1] = g;
            colors[i * 4 + 2] = b;
            colors[i * 4 + 3] = a;
        }
        return colors;
    }

    void drawColorAndTextureRects(Tex2D texture, int tdx, int tdy, Rect[] srcRects, Rect[] dstRects, uint[] vertexColors, bool linear) {
        float[] colors = convertColors(vertexColors);

        float[] vertexArray;
        vertexArray.assumeSafeAppend();
        float[] txcoordArray;
        txcoordArray.assumeSafeAppend();

        for (uint i = 0; i < srcRects.length; i++) {
            Rect srcrc = srcRects[i];
            Rect dstrc = dstRects[i];

            float dstx0 = cast(float)dstrc.left;
            float dsty0 = cast(float)(bufferDy - (dstrc.top));
            float dstx1 = cast(float)dstrc.right;
            float dsty1 = cast(float)(bufferDy - (dstrc.bottom));

            // don't flip for framebuffer
            if (currentFBO) {
                dsty0 = cast(float)(dstrc.top);
                dsty1 = cast(float)(dstrc.bottom);
            }

            float srcx0 = srcrc.left / cast(float)tdx;
            float srcy0 = srcrc.top / cast(float)tdy;
            float srcx1 = srcrc.right / cast(float)tdx;
            float srcy1 = srcrc.bottom / cast(float)tdy;
            float[3 * 4] vertices = [
                dstx0,dsty0,Z_2D,
                dstx0,dsty1,Z_2D,
                dstx1,dsty0,Z_2D,
                dstx1,dsty1,Z_2D];
            float[2 * 4] texcoords = [srcx0,srcy0, srcx0,srcy1, srcx1,srcy0, srcx1,srcy1];
            vertexArray ~= vertices;
            txcoordArray ~= texcoords;
        }

        int[] indexes = makeRectangleIndexesArray(srcRects.length);
        //Log.v("drawColorAndTextureRects srcrects:", srcRects.length, " dstrects:", dstRects.length, " colors:", vertexColors.length, " indexes: ", indexes);

        if (_legacyMode) {
            static if (SUPPORT_LEGACY_OPENGL) {
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
                checkgl!glVertexPointer(3, GL_FLOAT, 0, cast(void*)vertexArray.ptr);
                checkgl!glTexCoordPointer(2, GL_FLOAT, 0, cast(void*)txcoordArray.ptr);
                checkgl!glColorPointer(4, GL_FLOAT, 0, cast(void*)colors.ptr);

                checkgl!glDrawElements(GL_TRIANGLES, cast(int)indexes.length, GL_UNSIGNED_INT, cast(void*)indexes.ptr);

                glDisableClientState(GL_TEXTURE_COORD_ARRAY);
                glDisableClientState(GL_VERTEX_ARRAY);
                glDisableClientState(GL_COLOR_ARRAY);
                glDisable(GL_BLEND);
                glDisable(GL_ALPHA_TEST);
                glDisable(GL_TEXTURE_2D);
            }
        } else {
            _textureProgram.execute(vertexArray, colors, txcoordArray, texture, linear, indexes);
        }
    }

    /// call glFlush
    void flushGL() {
        checkgl!glFlush();
    }

    bool generateMipmap(int dx, int dy, ubyte * pixels, int level, ref ubyte[] dst) {
        if ((dx & 1) || (dy & 1) || dx < 2 || dy < 2)
            return false; // size is not even
        int newdx = dx / 2;
        int newdy = dy / 2;
        int newlen = newdx * newdy * 4;
        if (newlen > dst.length)
            dst.length = newlen;
        ubyte * dstptr = dst.ptr;
        ubyte * srcptr = pixels;
        int srcstride = dx * 4;
        for (int y = 0; y < newdy; y++) {
            for (int x = 0; x < newdx; x++) {
                dstptr[0] = cast(ubyte)((srcptr[0+0] + srcptr[0+4] + srcptr[0+srcstride] + srcptr[0+srcstride + 4])>>2);
                dstptr[1] = cast(ubyte)((srcptr[1+0] + srcptr[1+4] + srcptr[1+srcstride] + srcptr[1+srcstride + 4])>>2);
                dstptr[2] = cast(ubyte)((srcptr[2+0] + srcptr[2+4] + srcptr[2+srcstride] + srcptr[2+srcstride + 4])>>2);
                dstptr[3] = cast(ubyte)((srcptr[3+0] + srcptr[3+4] + srcptr[3+srcstride] + srcptr[3+srcstride + 4])>>2);
                dstptr += 4;
                srcptr += 8;
            }
            srcptr += srcstride; // skip srcline
        }
        checkgl!glTexImage2D(GL_TEXTURE_2D, level, GL_RGBA, newdx, newdy, 0, GL_RGBA, GL_UNSIGNED_BYTE, dst.ptr);
        return true;
    }

    bool setTextureImage(Tex2D texture, int dx, int dy, ubyte * pixels, int mipmapLevels = 0) {
        checkError("before setTextureImage");
        texture.bind();
        checkgl!glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
        texture.setSamplerParams(true, true);

        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_BASE_LEVEL, 0);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAX_LEVEL, mipmapLevels > 0 ? mipmapLevels - 1 : 0);
        // ORIGINAL: glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, dx, dy, 0, GL_RGBA, GL_UNSIGNED_BYTE, pixels);
        checkgl!glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, dx, dy, 0, GL_RGBA, GL_UNSIGNED_BYTE, pixels);
        if (checkError("updateTexture - glTexImage2D")) {
            Log.e("Cannot set image for texture");
            return false;
        }
        if (mipmapLevels > 1) {
            ubyte[] buffer;
            ubyte * src = pixels;
            int ndx = dx;
            int ndy = dy;
            for (int i = 1; i < mipmapLevels; i++) {
                if (!generateMipmap(ndx, ndy, src, i, buffer))
                    break;
                ndx /= 2;
                ndy /= 2;
                src = buffer.ptr;
            }
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
        //glClear(GL_DEPTH_BUFFER_BIT | GL_COLOR_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);
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
            static if (SUPPORT_LEGACY_OPENGL) {
                glMatrixMode(GL_PROJECTION);
                //checkgl!glPushMatrix();
                //glLoadIdentity();
                glLoadMatrixf(_projectionMatrix.m.ptr);
                //glOrthof(0, _dx, 0, _dy, -1.0f, 1.0f);
                glMatrixMode(GL_MODELVIEW);
                //checkgl!glPushMatrix();
                glLoadIdentity();
            }
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
            static if (SUPPORT_LEGACY_OPENGL) {
                glMatrixMode(GL_PROJECTION);
                //checkgl!glPushMatrix();
                //glLoadIdentity();
                glLoadMatrixf(_projectionMatrix.m.ptr);
                //glOrthof(0, _dx, 0, _dy, -1.0f, 1.0f);
                glMatrixMode(GL_MODELVIEW);
                //checkgl!glPushMatrix();
                glLoadIdentity();
            }
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
            checkgl!glBufferData(target,
                         length * float.sizeof,
                         null,
                         GL_STREAM_DRAW);
            int offset;
            foreach(b; buffs) {
                checkgl!glBufferSubData(target,
                                offset,
                                b.length * float.sizeof,
                                b.ptr);
                offset += b.length * float.sizeof;
            }
        }

        static if (target == GL_ELEMENT_ARRAY_BUFFER) {
            void fill(int[] indexes) {
                checkgl!glBufferData(target, cast(int)(indexes.length * int.sizeof), indexes.ptr, GL_STREAM_DRAW);
            }
        }
    }

    static if(type == GLObjectTypes.Texture)
    {
        void setSamplerParams(bool linear, bool clamp = false, bool mipmap = false) {
            glTexParameteri(target, GL_TEXTURE_MAG_FILTER, linear ? GL_LINEAR : GL_NEAREST);
            glTexParameteri(target, GL_TEXTURE_MIN_FILTER, linear ? 
                            (!mipmap ? GL_LINEAR : GL_LINEAR_MIPMAP_LINEAR) : 
                            (!mipmap ? GL_NEAREST : GL_NEAREST_MIPMAP_NEAREST)); //GL_NEAREST_MIPMAP_NEAREST
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
alias EBO = GLObject!(GLObjectTypes.Buffer, GL_ELEMENT_ARRAY_BUFFER);
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
	version (Android) {
    	    checkgl!glGenBuffers(1, &_vertexBuffer);
    	    checkgl!glGenBuffers(1, &_indexBuffer);
    	    checkgl!glGenVertexArrays(1, &_vao);
	} else {
    	    assertgl!glGenBuffers(1, &_vertexBuffer);
    	    assertgl!glGenBuffers(1, &_indexBuffer);
    	    assertgl!glGenVertexArrays(1, &_vao);
	}
    }

    ~this() {
        checkgl!glDeleteBuffers(1, &_vertexBuffer);
        checkgl!glDeleteBuffers(1, &_indexBuffer);
        checkgl!glDeleteVertexArrays(1, &_vao);
    }

    ///// bind into current context
    //override void bind() {
    //    checkgl!glBindVertexArray(_vao);
    //
    //    // TODO: is it necessary to bind vertex/index buffers?
    //    // specify vertex buffer
    //    checkgl!glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    //    // specify index buffer
    //    checkgl!glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
    //}
    //
    ///// unbind from current context
    //override void unbind() {
    //    checkgl!glBindVertexArray(0);
    //    checkgl!glBindBuffer(GL_ARRAY_BUFFER, 0);
    //    checkgl!glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
    //}

    /// update vertex element locations for effect/shader program
    void enableAttributes(GraphicsEffect effect) {
        checkgl!glBindVertexArray(_vao);
        // specify vertex buffer
        checkgl!glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
        // specify index buffer
        checkgl!glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
        int offset = 0;
        //Log.v("=== enableAttributes for ", _format);
        for(int i = 0; i < _format.length; i++) {
            int loc = effect.getVertexElementLocation(_format[i].type);
            if (loc >= 0) {
                //Log.v("setting attrib pointer for type ", _format[i].type, " offset=", offset, " location=", loc);
                checkgl!glVertexAttribPointer(loc, _format[i].size, GL_FLOAT, cast(ubyte)GL_FALSE, _format.vertexSize, cast(char*)(offset));
                checkgl!glEnableVertexAttribArray(loc);
            } else {
                //Log.v("Attribute location not found for ", _format[i].type);
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
        checkgl!glBindVertexArray(0);
        checkgl!glBindBuffer(GL_ARRAY_BUFFER, 0);
        checkgl!glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
        //unbind();
    }

    /// set or change data
    override void setData(Mesh mesh) {
        _format = mesh.vertexFormat;
        _indexFragments = mesh.indexFragments;
        _vertexCount = mesh.vertexCount;
        const(ushort[]) indexData = mesh.indexData;

        Log.d("GLVertexBuffer.setData vertex data size=", mesh.vertexData.length, " index data size=", indexData.length, " vertex count=", _vertexCount, " indexBuffer=", _indexBuffer, " vertexBuffer=", _vertexBuffer, " vao=", _vao);

        // vertex buffer
        checkgl!glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
        checkgl!glBufferData(GL_ARRAY_BUFFER, _format.vertexSize * mesh.vertexCount, mesh.vertexData.ptr, GL_STATIC_DRAW);
        checkgl!glBindBuffer(GL_ARRAY_BUFFER, 0);
        // index buffer
        checkgl!glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
        checkgl!glBufferData(GL_ELEMENT_ARRAY_BUFFER, indexData.length * ushort.sizeof, indexData.ptr, GL_STATIC_DRAW);
        checkgl!glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
        // vertex layout
        //checkgl!glBindVertexArray(_vao);
        // specify vertex buffer
        //checkgl!glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
        // specify index buffer
        //checkgl!glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);

        //unbind();
    }

    /// draw mesh using specified effect
    override void draw(GraphicsEffect effect) {
        //bind();
        enableAttributes(effect);
        foreach (fragment; _indexFragments) {
            checkgl!glDrawRangeElements(primitiveTypeToGL(fragment.type), 
                                0, _vertexCount - 1, // The first to last vertex
                                fragment.end - fragment.start, // count of indexes used to draw elements
                                GL_UNSIGNED_SHORT, 
                                cast(char*)(fragment.start * short.sizeof) // offset from index buffer beginning to fragment start
            );
        }
        disableAttributes(effect);
        //unbind();
    }
}

class DummyVertexBuffer : VertexBuffer {
    protected VertexFormat _format;
    protected IndexFragment[] _indexFragments;
    protected int _vertexCount;
    protected const(float)[] _vertexData;
    protected const(ushort)[] _indexData;

    this() {
    }

    ~this() {
    }

    ///// bind into current context
    //override void bind() {
    //}
    //
    ///// unbind from current context
    //override void unbind() {
    //}

    /// update vertex element locations for effect/shader program
    void enableAttributes(GraphicsEffect effect) {
        int offset = 0;
        for(int i = 0; i < _format.length; i++) {
            int loc = effect.getVertexElementLocation(_format[i].type);
            if (loc >= 0) {
                checkgl!glVertexAttribPointer(loc, _format[i].size, GL_FLOAT, cast(ubyte)GL_FALSE, _format.vertexSize, cast(char*)(offset));
                checkgl!glEnableVertexAttribArray(loc);
            } else {
                //Log.d("Attribute location not found for ", _format[i].type);
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
        _vertexData = mesh.vertexData;
        _indexData = mesh.indexData;
    }

    /// draw mesh using specified effect
    override void draw(GraphicsEffect effect) {
        //bind();
        enableAttributes(effect);
        foreach (fragment; _indexFragments) {
            checkgl!glDrawRangeElements(primitiveTypeToGL(fragment.type), 
                                        0, _vertexCount, 
                                        fragment.end - fragment.start, 
                                        GL_UNSIGNED_SHORT, cast(char*)(fragment.start * short.sizeof));
        }
        disableAttributes(effect);
        //unbind();
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


/// OpenGL batch buffer - to draw several triangles in single OpenGL call
class OpenGLBatch {
    private Tex2D _currentTexture;
    private int _currentTextureDx;
    private int _currentTextureDy;
    private bool _currentTextureLinear;
    private Rect[] _srcRects;
    private Rect[] _dstRects;
    private uint[] _colors;
    /// clear buffers
    void reset() {
        _colors.length = 0;
        _colors.assumeSafeAppend();
        _srcRects.length = 0;
        _srcRects.assumeSafeAppend();
        _dstRects.length = 0;
        _dstRects.assumeSafeAppend();
        _currentTexture = null;
        _currentTextureDx = 0;
        _currentTextureDy = 0;
        _currentTextureLinear = false;
    }
    /// draw buffered items
    void flush() {
        if (_dstRects.length == 0)
            return; // nothing to draw
        if (_currentTexture) {
            // draw with texture
            //Log.v("flush ", _dstRects.length, " texture rectangles");
            glSupport.drawColorAndTextureRects(_currentTexture, _currentTextureDx, _currentTextureDy, _srcRects, _dstRects, _colors, _currentTextureLinear);
        } else {
            // draw solid fill
            //Log.v("flush ", _dstRects.length, " solid rectangles");
            glSupport.drawSolidFillRects(_dstRects, _colors);
        }
        reset();
    }
    /// add textured rect
    void addTexturedRect(Tex2D texture, int textureDx, int textureDy, uint color1, uint color2, uint color3, uint color4, Rect srcRect, Rect dstRect, bool linear) {
        if (!_currentTexture 
            || _currentTexture.ID != texture.ID
            || _currentTextureLinear != linear
            //|| (textureDx != _currentTextureDx) 
            //|| (textureDy != _currentTextureDy) 
            //|| true
            ) 
        {
            flush();
            _currentTexture = texture;
            _currentTextureDx = textureDx;
            _currentTextureDy = textureDy;
            _currentTextureLinear = linear;
        }
        if (_currentTexture) {
            _srcRects ~= srcRect;
        }
        _dstRects ~= dstRect;
        _colors ~= color1;
        _colors ~= color2;
        _colors ~= color3;
        _colors ~= color4;
    }
    /// add solid rect
    void addSolidRect(Rect dstRect, uint color) {
        addGradientRect(dstRect, color, color, color, color);
    }

    /// add gradient rect
    void addGradientRect(Rect dstRect, uint color1, uint color2, uint color3, uint color4) {
        if (_currentTexture)
            flush();
        _dstRects ~= dstRect;
        _colors ~= color1;
        _colors ~= color2;
        _colors ~= color3;
        _colors ~= color4;
    }

    /// add gradient rect
    void addLine(Rect dstRect, uint color1, uint color2) {
        flush();
        // TODO: batch lines, too
        glSupport.drawLines([dstRect], [color1, color2]);
    }
}

