module dlangui.graphics.glsupport;

import dlangui.core.logger;
private import derelict.opengl3.gl3;
private import gl3n.linalg;
private import dlangui.core.types;
private import std.conv;

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

/// for OpenGL calls diagnostics.
private bool checkError(string context, string file = __FILE__, int line = __LINE__) {
    int err = glGetError();
    if (err != GL_NO_ERROR) {
        Log.e("OpenGL error ", err, " at ", file, ":", line, " -- ", context);
        return true;
    }
    return false;
}

immutable float Z_2D = -1.0f;
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
    _solidFillProgram.execute(vertices, colors);
    //drawSolidFillRect(vertices, colors);
}

void drawColorAndTextureRect(uint textureId, int tdx, int tdy, Rect srcrc, Rect dstrc, uint color, bool linear) {
    drawColorAndTextureRect(textureId, tdx, tdy, srcrc.left, srcrc.top, srcrc.width(), srcrc.height(), dstrc.left, dstrc.top, dstrc.width(), dstrc.height(), color, linear);
}

void drawColorAndTextureRect(uint textureId, int tdx, int tdy, int srcx, int srcy, int srcdx, int srcdy, int xx, int yy, int dx, int dy, uint color, bool linear) {
    //if (crconfig.getTextureFormat() == TEXTURE_ALPHA) {
    //    color = 0x000000;
    //}
    float colors[6*4];
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
    _textureProgram.execute(vertices, texcoords, colors, textureId, linear);
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
private mat4 m;
/// current gl buffer width
private int bufferDx;
/// current gl buffer height
private int bufferDy;

void setOrthoProjection(int dx, int dy) {
    //myGlOrtho(0, dx, 0, dy, -1.0f, 5.0f);
    bufferDx = dx;
    bufferDy = dy;
    //myGlOrtho(0, dx, 0, dy, -0.1f, 5.0f);

    m = mat4.orthographic(0, dx, 0, dy, 0.5f, 5.0f);
    glViewport(0, 0, dx, dy);
    checkError("glViewport");
}

class GLProgram {
    @property abstract string vertexSource();
    @property abstract string fragmentSource();
    GLuint vertexShader;
    GLuint fragmentShader;
    GLuint program;
    bool initialized;
    bool error;
    this() {
    }
    private GLuint compileShader(string src, GLuint type) {
        import core.stdc.stdlib;
        import std.string;
        GLuint shader = glCreateShader(type);//GL_VERTEX_SHADER
        const char * psrc = src.toStringz;
        GLuint len = src.length;
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
        glDetachShader(program, vertexShader);
        glDetachShader(program, fragmentShader);
        glUseProgram(program);
        checkError("glUseProgram " ~ to!string(program));
        if (!initLocations()) {
            Log.e("some of locations were not found");
            error = true;
        }
        initialized = true;
        return true;
    }
    bool initLocations() {
        return true;
    }
    bool use() {
        if (!initialized)
            return false;
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

class SolidFillProgram : GLProgram {
    @property override string vertexSource() {
        return         
            "attribute highp vec4 vertex;\n"
            "attribute lowp vec4 colAttr;\n"
            "varying lowp vec4 col;\n"
            "uniform mediump mat4 matrix;\n"
            "void main(void)\n"
            "{\n"
            "    gl_Position = matrix * vertex;\n"
            "    col = colAttr;\n"
            "}\n";

    }
    @property override string fragmentSource() {
        return
            "uniform sampler2D texture;\n"
            "varying lowp vec4 col;\n"
            "void main(void)\n"
            "{\n"
            "    gl_FragColor = col;\n"
            "}\n";
    }

    void beforeExecute() {
        glEnable(GL_BLEND);
        glDisable(GL_CULL_FACE);
        checkError("glDisable(GL_CULL_FACE)");
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        checkError("glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)");
        use();
        glDisable(GL_CULL_FACE);
        checkError("glDisable(GL_CULL_FACE)");
        glUniformMatrix4fv(matrixLocation,  1, false, m.value_ptr);
        checkError("glUniformMatrix4fv");
    }

    void afterExecute() {
        release();
    }

    protected GLint matrixLocation;
    protected GLint vertexLocation;
    protected GLint colAttrLocation;
    override bool initLocations() {
        bool res = super.initLocations();
        matrixLocation = glGetUniformLocation(program, "matrix");
        vertexLocation = glGetAttribLocation(program, "vertex");
        colAttrLocation = glGetAttribLocation(program, "colAttr");
        return res && matrixLocation >= 0 && vertexLocation >= 0 && colAttrLocation >= 0;
    }

    bool execute(float[] vertices, float[] colors) {
        if (error)
            return false;
        if (!initialized)
            if (!compile())
                return false;
        beforeExecute();

        glEnableVertexAttribArray(vertexLocation);
        checkError("glEnableVertexAttribArray");
        glEnableVertexAttribArray(colAttrLocation);
        checkError("glEnableVertexAttribArray");

        glVertexAttribPointer(vertexLocation, 3, GL_FLOAT, GL_FALSE, 0, vertices.ptr);
        checkError("glVertexAttribPointer");
        glVertexAttribPointer(colAttrLocation, 4, GL_FLOAT, GL_FALSE, 0, colors.ptr);
        checkError("glVertexAttribPointer");

        glDrawArrays(GL_TRIANGLES, 0, 6);
        checkError("glDrawArrays");
        glDisableVertexAttribArray(vertexLocation);
        checkError("glDisableVertexAttribArray");
        glDisableVertexAttribArray(colAttrLocation);
        checkError("glDisableVertexAttribArray");

        afterExecute();
        glBindTexture(GL_TEXTURE_2D, 0);
        checkError("glBindTexture");
        return true;
    }
}

class TextureProgram : SolidFillProgram {
    @property override string vertexSource() {
        return         
            "attribute highp vec4 vertex;\n"
            "attribute lowp vec4 colAttr;\n"
            "attribute mediump vec4 texCoord;\n"
            "varying lowp vec4 col;\n"
            "varying mediump vec4 texc;\n"
            "uniform mediump mat4 matrix;\n"
            "void main(void)\n"
            "{\n"
            "    gl_Position = matrix * vertex;\n"
            "    col = colAttr;\n"
            "    texc = texCoord;\n"
            "}\n";

    }
    @property override string fragmentSource() {
        return
            "uniform sampler2D texture;\n"
            "varying lowp vec4 col;\n"
            "varying mediump vec4 texc;\n"
            "void main(void)\n"
            "{\n"
            "    gl_FragColor = texture2D(texture, texc.st) * col;\n"
            "}\n";
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

        glEnableVertexAttribArray(vertexLocation);
        glEnableVertexAttribArray(colAttrLocation);
        glEnableVertexAttribArray(texCoordLocation);

        glVertexAttribPointer(vertexLocation, 3, GL_FLOAT, GL_FALSE, 0, vertices.ptr);
        glVertexAttribPointer(colAttrLocation, 4, GL_FLOAT, GL_FALSE, 0, colors.ptr);
        glVertexAttribPointer(texCoordLocation, 2, GL_FLOAT, GL_FALSE, 0, texcoords.ptr);

        glDrawArrays(GL_TRIANGLES, 0, 6);
        checkError("glDrawArrays");

        glDisableVertexAttribArray(vertexLocation);
        glDisableVertexAttribArray(colAttrLocation);
        glDisableVertexAttribArray(texCoordLocation);

        afterExecute();
        glBindTexture(GL_TEXTURE_2D, 0);
        checkError("glBindTexture");
        return true;
    }
}

__gshared TextureProgram _textureProgram;
__gshared SolidFillProgram _solidFillProgram;

bool initShaders() {
    if (_textureProgram is null) {
        _textureProgram = new TextureProgram();
        if (!_textureProgram.compile())
            return false;
    }
    if (_solidFillProgram is null) {
        _solidFillProgram = new SolidFillProgram();
        if (!_solidFillProgram.compile())
            return false;
    }
    Log.d("Shaders compiled successfully");
    return true;
}
