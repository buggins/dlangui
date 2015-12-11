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

// utility function to fill 4-float array of vertex colors with converted CR 32bit color
private void LVGLFillColor(uint color, float * buf, int count) {
    float r = ((color >> 16) & 255) / 255.0f;
    float g = ((color >> 8) & 255) / 255.0f;
    float b = ((color >> 0) & 255) / 255.0f;
    float a = (((color >> 24) & 255) ^ 255) / 255.0f;
    for (int i=0; i<count; i++) {
        *buf++ = r;
        *buf++ = g;
        *buf++ = b;
        *buf++ = a;
    }
}

/* For reporting OpenGL errors, it's nicer to get a human-readable symbolic name for the
 * error instead of the numeric form. Derelict's GLenum is just an alias for uint, so we
 * can't depend on D's nice toString() for enums.
 */
private immutable(string[int]) errors;
static this() {
    errors = [
        0x0500:  "GL_INVALID_ENUM",
        0x0501:  "GL_INVALID_VALUE",
        0x0502:  "GL_INVALID_OPERATION",
        0x0505:  "GL_OUT_OF_MEMORY"
    ];
}
/** 
 * Convenient wrapper around glGetError()
 * TODO use one of the DEBUG extensions instead
 */
bool checkError(string context="", string file=__FILE__, int line=__LINE__)
{
    GLenum err = glGetError();
    if (err != GL_NO_ERROR)
    {
        Log.e("OpenGL error ", err in errors ? errors[err] : to!string(err), " at ", file, ":", line, " -- ", context);
        return true;
    }
    return false;
}


class GLProgram {
    @property abstract string vertexSource();
    @property abstract string fragmentSource();
    protected GLuint vertexShader;
    protected GLuint fragmentShader;
    protected GLuint program;
    protected bool initialized;
    protected bool error;
	protected string glslversion;
	protected int glslversionInt;
    protected char[] glslversionString;
    this() {
    }
    
    private void compatibilityFixes(ref char[] code, GLuint type) {
        if (glslversionInt < 150) {
            code = replace(code, " texture(", " texture2D(");
			code = replace(code, "in ", "");
			code = replace(code, "out ", "");
		}
    }
    
    private GLuint compileShader(string src, GLuint type) {
        import core.stdc.stdlib;
        import std.string;

        char[] sourceCode;
        sourceCode ~= "#version ";
        sourceCode ~= glslversionString;
        sourceCode ~= "\n";
        sourceCode ~= src;
        compatibilityFixes(sourceCode, type);
        
		Log.d("compileShader glsl=", glslversion, " type:", (type == GL_VERTEX_SHADER ? "GL_VERTEX_SHADER" : (type == GL_FRAGMENT_SHADER ? "GL_FRAGMENT_SHADER" : "UNKNOWN")), " code:\n", sourceCode);
        GLuint shader = glCreateShader(type);//GL_VERTEX_SHADER
        const char * psrc = sourceCode.toStringz;
        GLuint len = cast(uint)sourceCode.length;
        glShaderSource(shader, 1, &psrc, cast(const(int)*)&len);
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
                GLchar * pmsg = &msg[0];
                glGetShaderInfoLog(shader, blen, &slen, pmsg);
                Log.d("Shader compilation error: ", fromStringz(pmsg));
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
            GLchar * pmsg = &msg[0];
            glGetProgramInfoLog(program, maxLength, &maxLength, pmsg);
            Log.e("Error while linking program: ", fromStringz(pmsg));
            error = true;
            return false;
        }
        Log.d("Program compiled successfully");
        //glDetachShader(program, vertexShader);
        //glDetachShader(program, fragmentShader);
        Log.v("trying glUseProgram with 0");
        glUseProgram(0);
        Log.v("before useProgram");
        glUseProgram(program);
        checkError("glUseProgram " ~ to!string(program));
        Log.v("after useProgram");
        if (!initLocations()) {
            Log.e("some of locations were not found");
            error = true;
        }
        initialized = true;
        Log.v("Program is initialized successfully");
        glUseProgram(0);
        checkError("glUseProgram " ~ to!string(program));
        return !error;
    }
    bool initLocations() {
        return true;
    }
    bool bind() {
        if (!initialized)
            return false;
		if (!glIsProgram(program))
			Log.e("!glIsProgram(program)");
        glUseProgram(program);
        checkError("glUseProgram " ~ to!string(program));
        return true;
    }
    void release() {
        glUseProgram(0);
        checkError("glUseProgram(0)");
    }
    ~this() {
        clear();
    }
    void clear() {
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
}

immutable string HIGHP = "";
immutable string LOWP = "";
immutable string MEDIUMP = "";

class SolidFillProgram : GLProgram {
    @property override string vertexSource() {
        return q{
            in vec4 vertex;
            in vec4 colAttr;
            out vec4 col;
            uniform mat4 matrix;
            void main(void)
            {
                gl_Position = matrix * vertex;
                col = colAttr;
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

    void beforeExecute() {
        glEnable(GL_BLEND);
        glDisable(GL_CULL_FACE);
        checkError("glDisable(GL_CULL_FACE)");
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        //glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE); 
        checkError("glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)");
        bind();
        //glUniformMatrix4fv(matrixLocation,  1, false, m.value_ptr);
        //glUniformMatrix4fv(matrixLocation,  1, false, matrix.ptr);
        glUniformMatrix4fv(matrixLocation,  1, false, glSupport.qtmatrix.ptr);
        checkError("glUniformMatrix4fv");
    }

    void afterExecute() {
        release();
    }

    protected GLint matrixLocation;
    protected GLint vertexLocation;
    protected GLint colAttrLocation;
	protected GLuint vertexBuffer;
	protected GLuint colAttrBuffer;
    override bool initLocations() {
        bool res = super.initLocations();

		//glGenBuffers(1, &vertexBuffer);
		//glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
		//glBufferData(GL_ARRAY_BUFFER, float.sizeof * 3 * 6, null, GL_DYNAMIC_DRAW);
		//glGenBuffers(1, &colAttrBuffer);
		//glBindBuffer(GL_ARRAY_BUFFER, colAttrBuffer);
		//glBufferData(GL_ARRAY_BUFFER, float.sizeof * 4 * 6, null, GL_DYNAMIC_DRAW);

        matrixLocation = glGetUniformLocation(program, "matrix");
		checkError("glGetUniformLocation matrix");
		if (matrixLocation == 0)
			Log.e("glGetUniformLocation failed for matrixLocation");
        vertexLocation = glGetAttribLocation(program, "vertex");
		checkError("glGetAttribLocation vertex");
		if (vertexLocation == 0)
			Log.e("glGetUniformLocation failed for vertexLocation");
		colAttrLocation = glGetAttribLocation(program, "colAttr");
		checkError("glGetAttribLocation colAttr");
		if (colAttrLocation == 0)
			Log.e("glGetUniformLocation failed for colAttrLocation");
		return res && matrixLocation >= 0 && vertexLocation >= 0 && colAttrLocation >= 0;
    }

    bool execute(float[] vertices, float[] colors) {
        if (error)
            return false;
        if (!initialized)
            if (!compile())
                return false;
        beforeExecute();

        GLuint vao;
        glGenVertexArrays(1, &vao);
        glBindVertexArray(vao);

        GLuint vbo;
        glGenBuffers(1, &vbo);
        glBindBuffer(GL_ARRAY_BUFFER, vbo);
        glBufferData(
            GL_ARRAY_BUFFER,
            vertices.length * vertices[0].sizeof + colors.length * colors[0].sizeof,
            null,
            GL_STREAM_DRAW);
        glBufferSubData(
            GL_ARRAY_BUFFER,
            0,
            vertices.length * vertices[0].sizeof,
            vertices.ptr);
        glBufferSubData(
            GL_ARRAY_BUFFER,
            vertices.length * vertices[0].sizeof,
            colors.length * colors[0].sizeof, colors.ptr);

        glEnableVertexAttribArray(vertexLocation);
        checkError("glEnableVertexAttribArray");
        glVertexAttribPointer(vertexLocation, 3, GL_FLOAT, GL_FALSE, 0, cast(void*) 0);
        checkError("glVertexAttribPointer");

        glEnableVertexAttribArray(colAttrLocation);
        checkError("glEnableVertexAttribArray");
        glVertexAttribPointer(colAttrLocation, 4, GL_FLOAT, GL_FALSE, 0, cast(void*) (float.sizeof*3*6));
        checkError("glVertexAttribPointer");

        glDrawArrays(GL_TRIANGLES, 0, 6);
        checkError("glDrawArrays");

        glDisableVertexAttribArray(vertexLocation);
        checkError("glDisableVertexAttribArray");
        glDisableVertexAttribArray(colAttrLocation);
        checkError("glDisableVertexAttribArray");

        afterExecute();

        glBindBuffer(GL_ARRAY_BUFFER, 0);
        glDeleteBuffers(1, &vbo);

        glBindVertexArray(0);
        glDeleteVertexArrays(1, &vao);
        return true;
    }
}

class LineProgram : SolidFillProgram {
    override bool execute(float[] vertices, float[] colors) {
        if (error)
            return false;
        if (!initialized)
            if (!compile())
                return false;
        beforeExecute();

        GLuint vao;
        glGenVertexArrays(1, &vao);
        glBindVertexArray(vao);

        GLuint vbo;
        glGenBuffers(1, &vbo);
        glBindBuffer(GL_ARRAY_BUFFER, vbo);
        glBufferData(
            GL_ARRAY_BUFFER,
            vertices.length * vertices[0].sizeof + colors.length * colors[0].sizeof,
            null,
            GL_STREAM_DRAW);
        glBufferSubData(
            GL_ARRAY_BUFFER,
            0,
            vertices.length * vertices[0].sizeof,
            vertices.ptr);
        glBufferSubData(
            GL_ARRAY_BUFFER,
            vertices.length * vertices[0].sizeof,
            colors.length * colors[0].sizeof, 
            colors.ptr);

        glEnableVertexAttribArray(vertexLocation);
        checkError("glEnableVertexAttribArray");
        glVertexAttribPointer(vertexLocation, 3, GL_FLOAT, GL_FALSE, 0, cast(void*) 0);
        checkError("glVertexAttribPointer");

        glEnableVertexAttribArray(colAttrLocation);
        checkError("glEnableVertexAttribArray");
        glVertexAttribPointer(colAttrLocation, 4, GL_FLOAT, GL_FALSE, 0, cast(void*) (float.sizeof*3*2));
        checkError("glVertexAttribPointer");

        glDrawArrays(GL_LINES, 0, 2);
        checkError("glDrawArrays");

        glDisableVertexAttribArray(vertexLocation);
        checkError("glDisableVertexAttribArray");
        glDisableVertexAttribArray(colAttrLocation);
        checkError("glDisableVertexAttribArray");

        afterExecute();

        glBindBuffer(GL_ARRAY_BUFFER, 0);
        glDeleteBuffers(1, &vbo);

        glBindVertexArray(0);
        glDeleteVertexArrays(1, &vao);
        return true;
    }
}

class TextureProgram : SolidFillProgram {
    @property override string vertexSource() {
        return q{
            in vec4 vertex;
            in vec4 colAttr;
            in vec4 texCoord;
            out vec4 col;
            out vec4 texc;
            uniform mat4 matrix;
            void main(void)
            {
                gl_Position = matrix * vertex;
                col = colAttr;
                texc = texCoord;
            }
        };

    }
    @property override string fragmentSource() {
        return q{
            uniform sampler2D tex;
            in vec4 col;
            in vec4 texc;
            out vec4 outColor;
            void main(void)
            {
                outColor = texture(tex, texc.st) * col;
            }
        };
    }

    GLint texCoordLocation;
    override bool initLocations() {
        bool res = super.initLocations();
        texCoordLocation = glGetAttribLocation(program, "texCoord");
        return res && texCoordLocation >= 0;
    }

    bool execute(float[] vertices, float[] texcoords, float[] colors, uint textureId, bool linear) {
        if (error)
            return false;
        if (!initialized)
            if (!compile())
                return false;
        beforeExecute();
        glActiveTexture(GL_TEXTURE0);
        checkError("glActiveTexture GL_TEXTURE0");
        glBindTexture(GL_TEXTURE_2D, textureId);
        checkError("glBindTexture");
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, linear ? GL_LINEAR : GL_NEAREST);
        checkError("drawColorAndTextureRect - glTexParameteri");
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, linear ? GL_LINEAR : GL_NEAREST);
        checkError("drawColorAndTextureRect - glTexParameteri");

        GLuint vao;
        glGenVertexArrays(1, &vao);
        glBindVertexArray(vao);

        GLuint vbo;
        glGenBuffers(1, &vbo);
        glBindBuffer(GL_ARRAY_BUFFER, vbo);
        glBufferData(
            GL_ARRAY_BUFFER,
            vertices.length * vertices[0].sizeof +
            colors.length * colors[0].sizeof +
            texcoords.length * texcoords[0].sizeof,
            null,
            GL_STREAM_DRAW);
        glBufferSubData(
            GL_ARRAY_BUFFER,
            0,
            vertices.length * vertices[0].sizeof,
            vertices.ptr);
        glBufferSubData(
            GL_ARRAY_BUFFER,
            vertices.length * vertices[0].sizeof,
            colors.length * colors[0].sizeof,
            colors.ptr);
        glBufferSubData(
            GL_ARRAY_BUFFER,
            vertices.length * vertices[0].sizeof + colors.length * colors[0].sizeof,
            texcoords.length * texcoords[0].sizeof,
            texcoords.ptr);

        glEnableVertexAttribArray(vertexLocation);
        glEnableVertexAttribArray(colAttrLocation);
        glEnableVertexAttribArray(texCoordLocation);

        glVertexAttribPointer(vertexLocation, 3, GL_FLOAT, GL_FALSE, 0, cast(void*) 0);
        glVertexAttribPointer(colAttrLocation, 4, GL_FLOAT, GL_FALSE, 0, cast(void*) (vertices.length * vertices[0].sizeof));
        glVertexAttribPointer(texCoordLocation, 2, GL_FLOAT, GL_FALSE, 0, cast(void*) (vertices.length * vertices[0].sizeof + colors.length * colors[0].sizeof));

        glDrawArrays(GL_TRIANGLES, 0, 6);
        checkError("glDrawArrays");

        glDisableVertexAttribArray(vertexLocation);
        glDisableVertexAttribArray(colAttrLocation);
        glDisableVertexAttribArray(texCoordLocation);

        afterExecute();

        glBindBuffer(GL_ARRAY_BUFFER, 0);
        glDeleteBuffers(1, &vbo);

        glBindVertexArray(0);
        glDeleteVertexArrays(1, &vao);

        glBindTexture(GL_TEXTURE_2D, 0);
        checkError("glBindTexture");
        return true;
    }
}

class FontProgram : SolidFillProgram {
    @property override string vertexSource() {
        return q{
            in vec4 vertex;
            in vec4 colAttr;
            in vec4 texCoord;
            out vec4 col;
            out vec4 texc;
            uniform mat4 matrix;
            void main(void)
            {
                gl_Position = matrix * vertex;
                col = colAttr;
                texc = texCoord;
            }
        };

    }
    @property override string fragmentSource() {
        return q{
            uniform sampler2D tex;
            in vec4 col;
            in vec4 texc;
            out vec4 outColor;
            void main(void)
            {
                outColor = texture(tex, texc.st) * col;
            }
        };
    }

    GLint texCoordLocation;
    override bool initLocations() {
        bool res = super.initLocations();
        texCoordLocation = glGetAttribLocation(program, "texCoord");
        return res && texCoordLocation >= 0;
    }

    override void beforeExecute() {
        glEnable(GL_BLEND);
        glDisable(GL_CULL_FACE);
        checkError("glDisable(GL_CULL_FACE)");
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        //glBlendFunc(GL_ONE, GL_SRC_COLOR);
        //glBlendFunc(GL_ONE, GL_SRC_COLOR);
        //glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
        //glBlendFunc(GL_ONE_MINUS_SRC_COLOR, GL_SRC_COLOR);
        checkError("glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR)");
        bind();
        glUniformMatrix4fv(matrixLocation,  1, false, glSupport.qtmatrix.ptr);
        checkError("glUniformMatrix4fv");
    }

    override void afterExecute() {
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        super.afterExecute();
    }

    bool execute(float[] vertices, float[] texcoords, float[] colors, uint textureId, bool linear) {
        if (error)
            return false;
        if (!initialized)
            if (!compile())
                return false;
        beforeExecute();
        glActiveTexture(GL_TEXTURE0);
        checkError("glActiveTexture GL_TEXTURE0");
        glBindTexture(GL_TEXTURE_2D, textureId);
        checkError("glBindTexture");
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, linear ? GL_LINEAR : GL_NEAREST);
        checkError("drawColorAndTextureRect - glTexParameteri");
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, linear ? GL_LINEAR : GL_NEAREST);
        checkError("drawColorAndTextureRect - glTexParameteri");

        GLuint vao;
        glGenVertexArrays(1, &vao);
        glBindVertexArray(vao);

        GLuint vbo;
        glGenBuffers(1, &vbo);
        glBindBuffer(GL_ARRAY_BUFFER, vbo);
        glBufferData(
					 GL_ARRAY_BUFFER,
					 vertices.length * vertices[0].sizeof +
					 colors.length * colors[0].sizeof +
					 texcoords.length * texcoords[0].sizeof,
					 null,
					 GL_STREAM_DRAW);
        glBufferSubData(
						GL_ARRAY_BUFFER,
						0,
						vertices.length * vertices[0].sizeof,
						vertices.ptr);
        glBufferSubData(
						GL_ARRAY_BUFFER,
						vertices.length * vertices[0].sizeof,
						colors.length * colors[0].sizeof,
						colors.ptr);
        glBufferSubData(
						GL_ARRAY_BUFFER,
						vertices.length * vertices[0].sizeof + colors.length * colors[0].sizeof,
						texcoords.length * texcoords[0].sizeof,
						texcoords.ptr);

        glEnableVertexAttribArray(vertexLocation);
        glEnableVertexAttribArray(colAttrLocation);
        glEnableVertexAttribArray(texCoordLocation);

        glVertexAttribPointer(vertexLocation, 3, GL_FLOAT, GL_FALSE, 0, cast(void*) 0);
        glVertexAttribPointer(colAttrLocation, 4, GL_FLOAT, GL_FALSE, 0, cast(void*) (vertices.length * vertices[0].sizeof));
        glVertexAttribPointer(texCoordLocation, 2, GL_FLOAT, GL_FALSE, 0, cast(void*) (vertices.length * vertices[0].sizeof + colors.length * colors[0].sizeof));

        glDrawArrays(GL_TRIANGLES, 0, 6);
        checkError("glDrawArrays");

        glDisableVertexAttribArray(vertexLocation);
        glDisableVertexAttribArray(colAttrLocation);
        glDisableVertexAttribArray(texCoordLocation);

        afterExecute();

        glBindBuffer(GL_ARRAY_BUFFER, 0);
        glDeleteBuffers(1, &vbo);

        glBindVertexArray(0);
        glDeleteVertexArrays(1, &vao);

        glBindTexture(GL_TEXTURE_2D, 0);
        checkError("glBindTexture");
        return true;
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

class GLSupport {

	private bool _legacyMode;
	@property bool legacyMode() { return _legacyMode; }

	this(bool legacy = false) {
		_legacyMode = legacy;
	}

    TextureProgram _textureProgram;
    SolidFillProgram _solidFillProgram;
    LineProgram _lineProgram;
    FontProgram _fontProgram;

    @property bool valid() {
        return _legacyMode || _textureProgram && _solidFillProgram && _fontProgram && _lineProgram;
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
        if (_fontProgram is null) {
            Log.v("Compiling font program");
            _fontProgram = new FontProgram();
            if (!_fontProgram.compile())
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
        if (_fontProgram !is null) {
            destroy(_fontProgram);
		    _fontProgram = null;
        }
        return true;
    }

    bool isTexture(uint textureId) {
        return glIsTexture(textureId) == GL_TRUE;
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
        float[2 * 4] colors;
        LVGLFillColor(color1, colors.ptr + 4*0, 1);
        LVGLFillColor(color2, colors.ptr + 4*1, 1);
        float x0 = cast(float)(p1.x);
        float y0 = cast(float)(bufferDy-p1.y);
        float x1 = cast(float)(p2.x);
        float y1 = cast(float)(bufferDy-p2.y);

        // don't flip for framebuffer
        if (currentFramebufferId) {
            y0 = cast(float)(p1.y);
            y1 = cast(float)(p2.y);
        }

        float[3 * 2] vertices = [
            x0,y0,Z_2D,
            x1,y1,Z_2D
        ];
        if (_lineProgram !is null) {
            //Log.d("solid fill: vertices ", vertices, " colors ", colors);
            _lineProgram.execute(vertices, colors);
        } else
            Log.e("No program");
    }

    static immutable float Z_2D = -2.0f;
    void drawSolidFillRect(Rect rc, uint color1, uint color2, uint color3, uint color4) {
        float[6 * 4] colors;
        LVGLFillColor(color1, colors.ptr + 4*0, 1);
        LVGLFillColor(color4, colors.ptr + 4*1, 1);
        LVGLFillColor(color3, colors.ptr + 4*2, 1);
        LVGLFillColor(color1, colors.ptr + 4*3, 1);
        LVGLFillColor(color3, colors.ptr + 4*4, 1);
        LVGLFillColor(color2, colors.ptr + 4*5, 1);
        float x0 = cast(float)(rc.left);
        float y0 = cast(float)(bufferDy-rc.top);
        float x1 = cast(float)(rc.right);
        float y1 = cast(float)(bufferDy-rc.bottom);

        // don't flip for framebuffer
        if (currentFramebufferId) {
            y0 = cast(float)(rc.top);
            y1 = cast(float)(rc.bottom);
        }

        float[3 * 6] vertices = [
            x0,y0,Z_2D,
            x0,y1,Z_2D,
            x1,y1,Z_2D,
            x0,y0,Z_2D,
            x1,y1,Z_2D,
            x1,y0,Z_2D];

		if (_legacyMode) {
			glColor4f(1,1,1,1);
			glDisable(GL_CULL_FACE);
			glEnable(GL_BLEND);
			glDisable(GL_ALPHA_TEST);
			glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
			checkError("glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)");
			glEnableClientState(GL_VERTEX_ARRAY);
			checkError("glEnableClientState(GL_VERTEX_ARRAY)");
			glEnableClientState(GL_COLOR_ARRAY);
			checkError("glEnableClientState(GL_COLOR_ARRAY)");
			glVertexPointer(3, GL_FLOAT, 0, cast(void*)vertices.ptr);
			checkError("glVertexPointer(3, GL_FLOAT, 0, vertices)");
			glColorPointer(4, GL_FLOAT, 0, cast(void*)colors);
			checkError("glColorPointer(4, GL_FLOAT, 0, colors)");
			
			glDrawArrays(GL_TRIANGLES, 0, 6);
			checkError("glDrawArrays(GL_TRIANGLES, 0, 6)");
			
			glDisableClientState(GL_COLOR_ARRAY);
			glDisableClientState(GL_VERTEX_ARRAY);
			glDisable(GL_ALPHA_TEST);
			glDisable(GL_BLEND);
		} else {
	        if (_solidFillProgram !is null) {
	            //Log.d("solid fill: vertices ", vertices, " colors ", colors);
	            _solidFillProgram.execute(vertices, colors);
	        } else
	            Log.e("No program");
		}
    }

    void drawColorAndTextureGlyphRect(uint textureId, int tdx, int tdy, Rect srcrc, Rect dstrc, uint color) {
        //Log.v("drawColorAndGlyphRect tx=", textureId, " src=", srcrc, " dst=", dstrc);
        drawColorAndTextureGlyphRect(textureId, tdx, tdy, srcrc.left, srcrc.top, srcrc.width(), srcrc.height(), dstrc.left, dstrc.top, dstrc.width(), dstrc.height(), color);
    }

    void drawColorAndTextureGlyphRect(uint textureId, int tdx, int tdy, int srcx, int srcy, int srcdx, int srcdy, int xx, int yy, int dx, int dy, uint color) {
        float[6*4] colors;
        LVGLFillColor(color, colors.ptr, 6);
        float dstx0 = cast(float)xx;
        float dsty0 = cast(float)(bufferDy - (yy));
        float dstx1 = cast(float)(xx + dx);
        float dsty1 = cast(float)(bufferDy - (yy + dy));

        // don't flip for framebuffer
        if (currentFramebufferId) {
            dsty0 = cast(float)((yy));
            dsty1 = cast(float)((yy + dy));
        }

        float srcx0 = srcx / cast(float)tdx;
        float srcy0 = srcy / cast(float)tdy;
        float srcx1 = (srcx + srcdx) / cast(float)tdx;
        float srcy1 = (srcy + srcdy) / cast(float)tdy;
        float[3 * 6] vertices = 
           [dstx0, dsty0, Z_2D,
            dstx0, dsty1, Z_2D,
            dstx1, dsty1, Z_2D,
            dstx0, dsty0, Z_2D,
            dstx1, dsty1, Z_2D,
            dstx1, dsty0, Z_2D];
        float[2 * 6] texcoords = [srcx0,srcy0, srcx0,srcy1, srcx1,srcy1, srcx0,srcy0, srcx1,srcy1, srcx1,srcy0];

		if (_legacyMode) {
			bool linear = dx != srcdx || dy != srcdy;
			glDisable(GL_CULL_FACE);
			glActiveTexture(GL_TEXTURE0);
			checkError("glActiveTexture");
			glEnable(GL_TEXTURE_2D);
			checkError("glEnable(GL_TEXTURE_2D)");
			glBindTexture(GL_TEXTURE_2D, textureId);
			checkError("glBindTexture");
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, linear ? GL_LINEAR : GL_NEAREST);
			checkError("drawColorAndTextureRect - glTexParameteri");
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, linear ? GL_LINEAR : GL_NEAREST);
			checkError("drawColorAndTextureRect - glTexParameteri");
			
			glColor4f(1,1,1,1);
			glDisable(GL_ALPHA_TEST);
			
			glEnable(GL_BLEND);
			glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
			checkError("glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)");
			
			glEnableClientState(GL_COLOR_ARRAY);
			checkError("glEnableClientState(GL_COLOR_ARRAY)");
			glEnableClientState(GL_VERTEX_ARRAY);
			checkError("glEnableClientState(GL_VERTEX_ARRAY)");
			glEnableClientState(GL_TEXTURE_COORD_ARRAY);
			checkError("glEnableClientState(GL_TEXTURE_COORD_ARRAY)");
			glVertexPointer(3, GL_FLOAT, 0, cast(void*)vertices.ptr);
			checkError("glVertexPointer(3, GL_FLOAT, 0, vertices)");
			glTexCoordPointer(2, GL_FLOAT, 0, cast(void*)texcoords.ptr);
			checkError("glTexCoordPointer(2, GL_FLOAT, 0, texcoords)");
			glColorPointer(4, GL_FLOAT, 0, cast(void*)colors.ptr);
			checkError("glColorPointer(4, GL_FLOAT, 0, colors)");
			
			glDrawArrays(GL_TRIANGLES, 0, 6);
			checkError("glDrawArrays");
			
			glDisableClientState(GL_TEXTURE_COORD_ARRAY);
			glDisableClientState(GL_VERTEX_ARRAY);
			glDisableClientState(GL_COLOR_ARRAY);
			glDisable(GL_BLEND);
			glDisable(GL_ALPHA_TEST);
			glDisable(GL_TEXTURE_2D);
		} else {
        	_fontProgram.execute(vertices, texcoords, colors, textureId, false);
		}
        //drawColorAndTextureRect(vertices, texcoords, colors, textureId, linear);
    }

    void drawColorAndTextureRect(uint textureId, int tdx, int tdy, Rect srcrc, Rect dstrc, uint color, bool linear) {
        //Log.v("drawColorAndTextureRect tx=", textureId, " src=", srcrc, " dst=", dstrc);
        drawColorAndTextureRect(textureId, tdx, tdy, srcrc.left, srcrc.top, srcrc.width(), srcrc.height(), dstrc.left, dstrc.top, dstrc.width(), dstrc.height(), color, linear);
    }

    void drawColorAndTextureRect(uint textureId, int tdx, int tdy, int srcx, int srcy, int srcdx, int srcdy, int xx, int yy, int dx, int dy, uint color, bool linear) {
        float[6*4] colors;
        LVGLFillColor(color, colors.ptr, 6);
        float dstx0 = cast(float)xx;
        float dsty0 = cast(float)(bufferDy - (yy));
        float dstx1 = cast(float)(xx + dx);
        float dsty1 = cast(float)(bufferDy - (yy + dy));

        // don't flip for framebuffer
        if (currentFramebufferId) {
            dsty0 = cast(float)((yy));
            dsty1 = cast(float)((yy + dy));
        }

        float srcx0 = srcx / cast(float)tdx;
        float srcy0 = srcy / cast(float)tdy;
        float srcx1 = (srcx + srcdx) / cast(float)tdx;
        float srcy1 = (srcy + srcdy) / cast(float)tdy;
        float[3 * 6] vertices = [dstx0,dsty0,Z_2D,
        dstx0,dsty1,Z_2D,
        dstx1,dsty1,Z_2D,
        dstx0,dsty0,Z_2D,
        dstx1,dsty1,Z_2D,
        dstx1,dsty0,Z_2D];
        float[2 * 6] texcoords = [srcx0,srcy0, srcx0,srcy1, srcx1,srcy1, srcx0,srcy0, srcx1,srcy1, srcx1,srcy0];

		if (_legacyMode) {
			glDisable(GL_CULL_FACE);
			glActiveTexture(GL_TEXTURE0);
			checkError("glActiveTexture");
			glEnable(GL_TEXTURE_2D);
			checkError("glEnable(GL_TEXTURE_2D)");
			glBindTexture(GL_TEXTURE_2D, textureId);
			checkError("glBindTexture");
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, linear ? GL_LINEAR : GL_NEAREST);
			checkError("drawColorAndTextureRect - glTexParameteri");
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, linear ? GL_LINEAR : GL_NEAREST);
			checkError("drawColorAndTextureRect - glTexParameteri");
			
			glColor4f(1,1,1,1);
			glDisable(GL_ALPHA_TEST);
			
			glEnable(GL_BLEND);
			glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
			checkError("glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)");
			
			glEnableClientState(GL_COLOR_ARRAY);
			checkError("glEnableClientState(GL_COLOR_ARRAY)");
			glEnableClientState(GL_VERTEX_ARRAY);
			checkError("glEnableClientState(GL_VERTEX_ARRAY)");
			glEnableClientState(GL_TEXTURE_COORD_ARRAY);
			checkError("glEnableClientState(GL_TEXTURE_COORD_ARRAY)");
			glVertexPointer(3, GL_FLOAT, 0, cast(void*)vertices.ptr);
			checkError("glVertexPointer(3, GL_FLOAT, 0, vertices)");
			glTexCoordPointer(2, GL_FLOAT, 0, cast(void*)texcoords.ptr);
			checkError("glTexCoordPointer(2, GL_FLOAT, 0, texcoords)");
			glColorPointer(4, GL_FLOAT, 0, cast(void*)colors.ptr);
			checkError("glColorPointer(4, GL_FLOAT, 0, colors)");
			
			glDrawArrays(GL_TRIANGLES, 0, 6);
			checkError("glDrawArrays");
			
			glDisableClientState(GL_TEXTURE_COORD_ARRAY);
			glDisableClientState(GL_VERTEX_ARRAY);
			glDisableClientState(GL_COLOR_ARRAY);
			glDisable(GL_BLEND);
			glDisable(GL_ALPHA_TEST);
			glDisable(GL_TEXTURE_2D);
		} else {
        	_textureProgram.execute(vertices, texcoords, colors, textureId, linear);
		}
        //drawColorAndTextureRect(vertices, texcoords, colors, textureId, linear);
    }

    /// generate new texture ID
    uint genTexture() {
        GLuint textureId = 0;
        glGenTextures(1, &textureId);
        return textureId;
    }

    /// delete OpenGL texture
    void deleteTexture(ref uint textureId) {
        if (!textureId)
            return;
        if (glIsTexture(textureId) != GL_TRUE) {
            Log.e("Invalid texture ", textureId);
            return;
        }
        GLuint id = textureId;
        glDeleteTextures(1, &id);
        checkError("glDeleteTextures");
        textureId = 0;
    }

    /// call glFlush
    void flushGL() {
        glFlush();
        checkError("glFlush");
    }

    bool setTextureImage(uint textureId, int dx, int dy, ubyte * pixels) {
        //checkError("before setTextureImage");
        glActiveTexture(GL_TEXTURE0);
        checkError("updateTexture - glActiveTexture");
        glBindTexture(GL_TEXTURE_2D, 0);
        checkError("updateTexture - glBindTexture(0)");
        glBindTexture(GL_TEXTURE_2D, textureId);
        checkError("updateTexture - glBindTexture");
        glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
        checkError("updateTexture - glPixelStorei");
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        checkError("updateTexture - glTexParameteri");
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        checkError("updateTexture - glTexParameteri");
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        checkError("updateTexture - glTexParameteri");
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        checkError("updateTexture - glTexParameteri");

        if (!glIsTexture(textureId))
            Log.e("second test - invalid texture passed to CRGLSupportImpl::setTextureImage");

        // ORIGINAL: glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, dx, dy, 0, GL_RGBA, GL_UNSIGNED_BYTE, pixels);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, dx, dy, 0, GL_RGBA, GL_UNSIGNED_BYTE, pixels);
        checkError("updateTexture - glTexImage2D");
        if (glGetError() != GL_NO_ERROR) {
            Log.e("Cannot set image for texture");
            return false;
        }
        checkError("after setTextureImage");
        return true;
    }

    bool setTextureImageAlpha(uint textureId, int dx, int dy, ubyte * pixels) {
        checkError("before setTextureImageAlpha");
        glActiveTexture(GL_TEXTURE0);
        checkError("updateTexture - glActiveTexture");
        glBindTexture(GL_TEXTURE_2D, 0);
        checkError("updateTexture - glBindTexture(0)");
        glBindTexture(GL_TEXTURE_2D, textureId);
        checkError("setTextureImageAlpha - glBindTexture");
        glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
        checkError("setTextureImageAlpha - glPixelStorei");
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        checkError("setTextureImageAlpha - glTexParameteri");
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        checkError("setTextureImageAlpha - glTexParameteri");
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        checkError("setTextureImageAlpha - glTexParameteri");
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        checkError("setTextureImageAlpha - glTexParameteri");

        if (!glIsTexture(textureId))
            Log.e("second test: invalid texture passed to CRGLSupportImpl::setTextureImageAlpha");

        glTexImage2D(GL_TEXTURE_2D, 0, GL_ALPHA, dx, dy, 0, GL_ALPHA, GL_UNSIGNED_BYTE, pixels);
        checkError("setTextureImageAlpha - glTexImage2D");
        if (glGetError() != GL_NO_ERROR) {
            Log.e("Cannot set image for texture");
            return false;
        }
        glBindTexture(GL_TEXTURE_2D, 0);
        checkError("updateTexture - glBindTexture(0)");
        checkError("after setTextureImageAlpha");
        return true;
    }

    private uint currentFramebufferId;

    /// returns texture ID for buffer, 0 if failed
    bool createFramebuffer(ref uint textureId, ref uint framebufferId, int dx, int dy) {
        checkError("before createFramebuffer");
        bool res = true;
        textureId = framebufferId = 0;
        textureId = genTexture();
        if (!textureId)
            return false;
        GLuint fid = 0;
        glGenFramebuffers(1, &fid);
        if (checkError("createFramebuffer glGenFramebuffersOES")) return false;
        framebufferId = fid;
        glBindFramebuffer(GL_FRAMEBUFFER, framebufferId);
        if (checkError("createFramebuffer glBindFramebuffer")) return false;

        glBindTexture(GL_TEXTURE_2D, textureId);
        checkError("glBindTexture(GL_TEXTURE_2D, _textureId)");
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, dx, dy, 0, GL_RGB, GL_UNSIGNED_SHORT_5_6_5, null);
        checkError("glTexImage2D");

        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        checkError("texParameter");
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        checkError("texParameter");
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        checkError("texParameter");
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        checkError("texParameter");

        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, textureId, 0);
        checkError("glFramebufferTexture2D");
        // Always check that our framebuffer is ok
        if(glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
            Log.e("glFramebufferTexture2D failed");
            res = false;
        }
        checkError("glCheckFramebufferStatus");
        //glClearColor(0.5f, 0, 0, 1);
        glClearColor(0.5f, 0.5f, 0.5f, 1.0f);
        checkError("glClearColor");
        glClear(GL_COLOR_BUFFER_BIT);
        checkError("glClear");
        checkError("after createFramebuffer");
        //CRLog::trace("CRGLSupportImpl::createFramebuffer %d,%d  texture=%d, buffer=%d", dx, dy, textureId, framebufferId);
        currentFramebufferId = framebufferId;

        glBindTexture(GL_TEXTURE_2D, 0);
        checkError("createFramebuffer - glBindTexture(0)");
        glBindFramebuffer(GL_FRAMEBUFFER, 0);
        checkError("createFramebuffer - glBindFramebuffer(0)");

        return res;
    }

    void deleteFramebuffer(ref uint framebufferId) {
        //CRLog::debug("GLDrawBuf::deleteFramebuffer");
        if (framebufferId != 0) {
            glBindFramebuffer(GL_FRAMEBUFFER, 0);
            checkError("deleteFramebuffer - glBindFramebuffer");
            GLuint fid = framebufferId;
            glDeleteFramebuffers(1, &fid);
            checkError("deleteFramebuffer - glDeleteFramebuffer");
        }
        //CRLog::trace("CRGLSupportImpl::deleteFramebuffer(%d)", framebufferId);
        framebufferId = 0;
        checkError("after deleteFramebuffer");
        currentFramebufferId = 0;
    }

    bool bindFramebuffer(uint framebufferId) {
        //CRLog::trace("CRGLSupportImpl::bindFramebuffer(%d)", framebufferId);
        glBindFramebuffer(GL_FRAMEBUFFER, framebufferId);
        currentFramebufferId = framebufferId;
        return !checkError("glBindFramebuffer");
    }

    /// projection matrix
    //private mat4 m;
    /// current gl buffer width
    private int bufferDx;
    /// current gl buffer height
    private int bufferDy;
    //private float[16] matrix;
    private float[16] qtmatrix;

    void QMatrix4x4_ortho(float left, float right, float bottom, float top, float nearPlane, float farPlane)
    {
        // Bail out if the projection volume is zero-sized.
        if (left == right || bottom == top || nearPlane == farPlane)
            return;

        // Construct the projection.
        float width = right - left;
        float invheight = top - bottom;
        float clip = farPlane - nearPlane;
        float[4][4] m;
        m[0][0] = 2.0f / width;
        m[1][0] = 0.0f;
        m[2][0] = 0.0f;
        m[3][0] = -(left + right) / width;
        m[0][1] = 0.0f;
        m[1][1] = 2.0f / invheight;
        m[2][1] = 0.0f;
        m[3][1] = -(top + bottom) / invheight;
        m[0][2] = 0.0f;
        m[1][2] = 0.0f;
        m[2][2] = -2.0f / clip;
        m[3][2] = -(nearPlane + farPlane) / clip;
        m[0][3] = 0.0f;
        m[1][3] = 0.0f;
        m[2][3] = 0.0f;
        m[3][3] = 1.0f;
        for (int y = 0; y < 4; y++)
            for (int x = 0; x < 4; x++)
                qtmatrix[y * 4 + x] = m[y][x];
    }

    void QMatrix4x4_perspective(float angle, float aspect, float nearPlane, float farPlane)
    {
        import std.math;
        // Bail out if the projection volume is zero-sized.
        if (nearPlane == farPlane || aspect == 0.0f)
            return;

        // Construct the projection.
        float[4][4] m;
        float radians = (angle / 2.0f) * PI / 180.0f;
        float sine = sin(radians);
        if (sine == 0.0f)
            return;
        float cotan = cos(radians) / sine;
        float clip = farPlane - nearPlane;
        m[0][0] = cotan / aspect;
        m[1][0] = 0.0f;
        m[2][0] = 0.0f;
        m[3][0] = 0.0f;
        m[0][1] = 0.0f;
        m[1][1] = cotan;
        m[2][1] = 0.0f;
        m[3][1] = 0.0f;
        m[0][2] = 0.0f;
        m[1][2] = 0.0f;
        m[2][2] = -(nearPlane + farPlane) / clip;
        m[3][2] = -(2.0f * nearPlane * farPlane) / clip;
        m[0][3] = 0.0f;
        m[1][3] = 0.0f;
        m[2][3] = -1.0f;
        m[3][3] = 0.0f;

        for (int y = 0; y < 4; y++)
            for (int x = 0; x < 4; x++)
                qtmatrix[y * 4 + x] = m[y][x];
    }

    void setOrthoProjection(Rect view) {
        bufferDx = view.width;
        bufferDy = view.height;
        QMatrix4x4_ortho(view.left, view.right, view.top, view.bottom, 0.5f, 50.0f);
		//myGlOrtho(0, dx, 0, dy, 0.1f, 5.0f);

		if (_legacyMode) {
			glMatrixMode(GL_PROJECTION);
			//glPushMatrix();
			//checkError("glPushMatrix");
			//glLoadIdentity();
			glLoadMatrixf(qtmatrix.ptr);
			//glOrthof(0, _dx, 0, _dy, -1.0f, 1.0f);
			glMatrixMode(GL_MODELVIEW);
			//glPushMatrix();
			//checkError("glPushMatrix");
			glLoadIdentity();
		}
        glViewport(view.left, view.top, view.right, view.bottom);
        checkError("glViewport");
    }

    void setPerspectiveProjection(float fieldOfView, float aspectRatio, float nearPlane, float farPlane) {
        // TODO
    }
}

