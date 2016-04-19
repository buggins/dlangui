/* dstep /path/to/ndk-r9d/platforms/android-9/arch-x86/usr/include/GLES2/gl2.h -o gl2.d*/

module GLES2.gl2;

import core.stdc.config;

version (Android):
extern (C):
@system:
nothrow:
@nogc:

alias void GLvoid;
alias char GLchar;
alias uint GLenum;
alias ubyte GLboolean;
alias uint GLbitfield;
alias byte GLbyte;
alias short GLshort;
alias int GLint;
alias int GLsizei;
alias ubyte GLubyte;
alias ushort GLushort;
alias uint GLuint;
alias float GLfloat;
alias float GLclampf;
alias int GLfixed;
alias c_long GLintptr;
alias c_long GLsizeiptr;

enum GL_ES_VERSION_2_0 =                 1
enum GL_DEPTH_BUFFER_BIT =               0x00000100
enum GL_STENCIL_BUFFER_BIT =             0x00000400
enum GL_COLOR_BUFFER_BIT =               0x00004000
enum GL_FALSE =                          0
enum GL_TRUE =                           1
enum GL_POINTS =                         0x0000
enum GL_LINES =                          0x0001
enum GL_LINE_LOOP =                      0x0002
enum GL_LINE_STRIP =                     0x0003
enum GL_TRIANGLES =                      0x0004
enum GL_TRIANGLE_STRIP =                 0x0005
enum GL_TRIANGLE_FAN =                   0x0006
enum GL_ZERO =                           0
enum GL_ONE =                            1
enum GL_SRC_COLOR =                      0x0300
enum GL_ONE_MINUS_SRC_COLOR =            0x0301
enum GL_SRC_ALPHA =                      0x0302
enum GL_ONE_MINUS_SRC_ALPHA =            0x0303
enum GL_DST_ALPHA =                      0x0304
enum GL_ONE_MINUS_DST_ALPHA =            0x0305
enum GL_DST_COLOR =                      0x0306
enum GL_ONE_MINUS_DST_COLOR =            0x0307
enum GL_SRC_ALPHA_SATURATE =             0x0308
enum GL_FUNC_ADD =                       0x8006
enum GL_BLEND_EQUATION =                 0x8009
enum GL_BLEND_EQUATION_RGB =             0x8009
enum GL_BLEND_EQUATION_ALPHA =           0x883D
enum GL_FUNC_SUBTRACT =                  0x800A
enum GL_FUNC_REVERSE_SUBTRACT =          0x800B
enum GL_BLEND_DST_RGB =                  0x80C8
enum GL_BLEND_SRC_RGB =                  0x80C9
enum GL_BLEND_DST_ALPHA =                0x80CA
enum GL_BLEND_SRC_ALPHA =                0x80CB
enum GL_CONSTANT_COLOR =                 0x8001
enum GL_ONE_MINUS_CONSTANT_COLOR =       0x8002
enum GL_CONSTANT_ALPHA =                 0x8003
enum GL_ONE_MINUS_CONSTANT_ALPHA =       0x8004
enum GL_BLEND_COLOR =                    0x8005
enum GL_ARRAY_BUFFER =                   0x8892
enum GL_ELEMENT_ARRAY_BUFFER =           0x8893
enum GL_ARRAY_BUFFER_BINDING =           0x8894
enum GL_ELEMENT_ARRAY_BUFFER_BINDING =   0x8895
enum GL_STREAM_DRAW =                    0x88E0
enum GL_STATIC_DRAW =                    0x88E4
enum GL_DYNAMIC_DRAW =                   0x88E8
enum GL_BUFFER_SIZE =                    0x8764
enum GL_BUFFER_USAGE =                   0x8765
enum GL_CURRENT_VERTEX_ATTRIB =          0x8626
enum GL_FRONT =                          0x0404
enum GL_BACK =                           0x0405
enum GL_FRONT_AND_BACK =                 0x0408
enum GL_TEXTURE_2D =                     0x0DE1
enum GL_CULL_FACE =                      0x0B44
enum GL_BLEND =                          0x0BE2
enum GL_DITHER =                         0x0BD0
enum GL_STENCIL_TEST =                   0x0B90
enum GL_DEPTH_TEST =                     0x0B71
enum GL_SCISSOR_TEST =                   0x0C11
enum GL_POLYGON_OFFSET_FILL =            0x8037
enum GL_SAMPLE_ALPHA_TO_COVERAGE =       0x809E
enum GL_SAMPLE_COVERAGE =                0x80A0
enum GL_NO_ERROR =                       0
enum GL_INVALID_ENUM =                   0x0500
enum GL_INVALID_VALUE =                  0x0501
enum GL_INVALID_OPERATION =              0x0502
enum GL_OUT_OF_MEMORY =                  0x0505
enum GL_CW =                             0x0900
enum GL_CCW =                            0x0901
enum GL_LINE_WIDTH =                     0x0B21
enum GL_ALIASED_POINT_SIZE_RANGE =       0x846D
enum GL_ALIASED_LINE_WIDTH_RANGE =       0x846E
enum GL_CULL_FACE_MODE =                 0x0B45
enum GL_FRONT_FACE =                     0x0B46
enum GL_DEPTH_RANGE =                    0x0B70
enum GL_DEPTH_WRITEMASK =                0x0B72
enum GL_DEPTH_CLEAR_VALUE =              0x0B73
enum GL_DEPTH_FUNC =                     0x0B74
enum GL_STENCIL_CLEAR_VALUE =            0x0B91
enum GL_STENCIL_FUNC =                   0x0B92
enum GL_STENCIL_FAIL =                   0x0B94
enum GL_STENCIL_PASS_DEPTH_FAIL =        0x0B95
enum GL_STENCIL_PASS_DEPTH_PASS =        0x0B96
enum GL_STENCIL_REF =                    0x0B97
enum GL_STENCIL_VALUE_MASK =             0x0B93
enum GL_STENCIL_WRITEMASK =              0x0B98
enum GL_STENCIL_BACK_FUNC =              0x8800
enum GL_STENCIL_BACK_FAIL =              0x8801
enum GL_STENCIL_BACK_PASS_DEPTH_FAIL =   0x8802
enum GL_STENCIL_BACK_PASS_DEPTH_PASS =   0x8803
enum GL_STENCIL_BACK_REF =               0x8CA3
enum GL_STENCIL_BACK_VALUE_MASK =        0x8CA4
enum GL_STENCIL_BACK_WRITEMASK =         0x8CA5
enum GL_VIEWPORT =                       0x0BA2
enum GL_SCISSOR_BOX =                    0x0C10
enum GL_COLOR_CLEAR_VALUE =              0x0C22
enum GL_COLOR_WRITEMASK =                0x0C23
enum GL_UNPACK_ALIGNMENT =               0x0CF5
enum GL_PACK_ALIGNMENT =                 0x0D05
enum GL_MAX_TEXTURE_SIZE =               0x0D33
enum GL_MAX_VIEWPORT_DIMS =              0x0D3A
enum GL_SUBPIXEL_BITS =                  0x0D50
enum GL_RED_BITS =                       0x0D52
enum GL_GREEN_BITS =                     0x0D53
enum GL_BLUE_BITS =                      0x0D54
enum GL_ALPHA_BITS =                     0x0D55
enum GL_DEPTH_BITS =                     0x0D56
enum GL_STENCIL_BITS =                   0x0D57
enum GL_POLYGON_OFFSET_UNITS =           0x2A00
enum GL_POLYGON_OFFSET_FACTOR =          0x8038
enum GL_TEXTURE_BINDING_2D =             0x8069
enum GL_SAMPLE_BUFFERS =                 0x80A8
enum GL_SAMPLES =                        0x80A9
enum GL_SAMPLE_COVERAGE_VALUE =          0x80AA
enum GL_SAMPLE_COVERAGE_INVERT =         0x80AB
enum GL_NUM_COMPRESSED_TEXTURE_FORMATS = 0x86A2
enum GL_COMPRESSED_TEXTURE_FORMATS =     0x86A3
enum GL_DONT_CARE =                      0x1100
enum GL_FASTEST =                        0x1101
enum GL_NICEST =                         0x1102
enum GL_GENERATE_MIPMAP_HINT =           0x8192
enum GL_BYTE =                           0x1400
enum GL_UNSIGNED_BYTE =                  0x1401
enum GL_SHORT =                          0x1402
enum GL_UNSIGNED_SHORT =                 0x1403
enum GL_INT =                            0x1404
enum GL_UNSIGNED_INT =                   0x1405
enum GL_FLOAT =                          0x1406
enum GL_FIXED =                          0x140C
enum GL_DEPTH_COMPONENT =                0x1902
enum GL_ALPHA =                          0x1906
enum GL_RGB =                            0x1907
enum GL_RGBA =                           0x1908
enum GL_LUMINANCE =                      0x1909
enum GL_LUMINANCE_ALPHA =                0x190A
enum GL_UNSIGNED_SHORT_4_4_4_4 =         0x8033
enum GL_UNSIGNED_SHORT_5_5_5_1 =         0x8034
enum GL_UNSIGNED_SHORT_5_6_5 =           0x8363
enum GL_FRAGMENT_SHADER =                  0x8B30
enum GL_VERTEX_SHADER =                    0x8B31
enum GL_MAX_VERTEX_ATTRIBS =               0x8869
enum GL_MAX_VERTEX_UNIFORM_VECTORS =       0x8DFB
enum GL_MAX_VARYING_VECTORS =              0x8DFC
enum GL_MAX_COMBINED_TEXTURE_IMAGE_UNITS = 0x8B4D
enum GL_MAX_VERTEX_TEXTURE_IMAGE_UNITS =   0x8B4C
enum GL_MAX_TEXTURE_IMAGE_UNITS =          0x8872
enum GL_MAX_FRAGMENT_UNIFORM_VECTORS =     0x8DFD
enum GL_SHADER_TYPE =                      0x8B4F
enum GL_DELETE_STATUS =                    0x8B80
enum GL_LINK_STATUS =                      0x8B82
enum GL_VALIDATE_STATUS =                  0x8B83
enum GL_ATTACHED_SHADERS =                 0x8B85
enum GL_ACTIVE_UNIFORMS =                  0x8B86
enum GL_ACTIVE_UNIFORM_MAX_LENGTH =        0x8B87
enum GL_ACTIVE_ATTRIBUTES =                0x8B89
enum GL_ACTIVE_ATTRIBUTE_MAX_LENGTH =      0x8B8A
enum GL_SHADING_LANGUAGE_VERSION =         0x8B8C
enum GL_CURRENT_PROGRAM =                  0x8B8D
enum GL_NEVER =                          0x0200
enum GL_LESS =                           0x0201
enum GL_EQUAL =                          0x0202
enum GL_LEQUAL =                         0x0203
enum GL_GREATER =                        0x0204
enum GL_NOTEQUAL =                       0x0205
enum GL_GEQUAL =                         0x0206
enum GL_ALWAYS =                         0x0207
enum GL_KEEP =                           0x1E00
enum GL_REPLACE =                        0x1E01
enum GL_INCR =                           0x1E02
enum GL_DECR =                           0x1E03
enum GL_INVERT =                         0x150A
enum GL_INCR_WRAP =                      0x8507
enum GL_DECR_WRAP =                      0x8508
enum GL_VENDOR =                         0x1F00
enum GL_RENDERER =                       0x1F01
enum GL_VERSION =                        0x1F02
enum GL_EXTENSIONS =                     0x1F03
enum GL_NEAREST =                        0x2600
enum GL_LINEAR =                         0x2601
enum GL_NEAREST_MIPMAP_NEAREST =         0x2700
enum GL_LINEAR_MIPMAP_NEAREST =          0x2701
enum GL_NEAREST_MIPMAP_LINEAR =          0x2702
enum GL_LINEAR_MIPMAP_LINEAR =           0x2703
enum GL_TEXTURE_MAG_FILTER =             0x2800
enum GL_TEXTURE_MIN_FILTER =             0x2801
enum GL_TEXTURE_WRAP_S =                 0x2802
enum GL_TEXTURE_WRAP_T =                 0x2803
enum GL_TEXTURE =                        0x1702
enum GL_TEXTURE_CUBE_MAP =               0x8513
enum GL_TEXTURE_BINDING_CUBE_MAP =       0x8514
enum GL_TEXTURE_CUBE_MAP_POSITIVE_X =    0x8515
enum GL_TEXTURE_CUBE_MAP_NEGATIVE_X =    0x8516
enum GL_TEXTURE_CUBE_MAP_POSITIVE_Y =    0x8517
enum GL_TEXTURE_CUBE_MAP_NEGATIVE_Y =    0x8518
enum GL_TEXTURE_CUBE_MAP_POSITIVE_Z =    0x8519
enum GL_TEXTURE_CUBE_MAP_NEGATIVE_Z =    0x851A
enum GL_MAX_CUBE_MAP_TEXTURE_SIZE =      0x851C
enum GL_TEXTURE0 =                       0x84C0
enum GL_TEXTURE1 =                       0x84C1
enum GL_TEXTURE2 =                       0x84C2
enum GL_TEXTURE3 =                       0x84C3
enum GL_TEXTURE4 =                       0x84C4
enum GL_TEXTURE5 =                       0x84C5
enum GL_TEXTURE6 =                       0x84C6
enum GL_TEXTURE7 =                       0x84C7
enum GL_TEXTURE8 =                       0x84C8
enum GL_TEXTURE9 =                       0x84C9
enum GL_TEXTURE10 =                      0x84CA
enum GL_TEXTURE11 =                      0x84CB
enum GL_TEXTURE12 =                      0x84CC
enum GL_TEXTURE13 =                      0x84CD
enum GL_TEXTURE14 =                      0x84CE
enum GL_TEXTURE15 =                      0x84CF
enum GL_TEXTURE16 =                      0x84D0
enum GL_TEXTURE17 =                      0x84D1
enum GL_TEXTURE18 =                      0x84D2
enum GL_TEXTURE19 =                      0x84D3
enum GL_TEXTURE20 =                      0x84D4
enum GL_TEXTURE21 =                      0x84D5
enum GL_TEXTURE22 =                      0x84D6
enum GL_TEXTURE23 =                      0x84D7
enum GL_TEXTURE24 =                      0x84D8
enum GL_TEXTURE25 =                      0x84D9
enum GL_TEXTURE26 =                      0x84DA
enum GL_TEXTURE27 =                      0x84DB
enum GL_TEXTURE28 =                      0x84DC
enum GL_TEXTURE29 =                      0x84DD
enum GL_TEXTURE30 =                      0x84DE
enum GL_TEXTURE31 =                      0x84DF
enum GL_ACTIVE_TEXTURE =                 0x84E0
enum GL_REPEAT =                         0x2901
enum GL_CLAMP_TO_EDGE =                  0x812F
enum GL_MIRRORED_REPEAT =                0x8370
enum GL_FLOAT_VEC2 =                     0x8B50
enum GL_FLOAT_VEC3 =                     0x8B51
enum GL_FLOAT_VEC4 =                     0x8B52
enum GL_INT_VEC2 =                       0x8B53
enum GL_INT_VEC3 =                       0x8B54
enum GL_INT_VEC4 =                       0x8B55
enum GL_BOOL =                           0x8B56
enum GL_BOOL_VEC2 =                      0x8B57
enum GL_BOOL_VEC3 =                      0x8B58
enum GL_BOOL_VEC4 =                      0x8B59
enum GL_FLOAT_MAT2 =                     0x8B5A
enum GL_FLOAT_MAT3 =                     0x8B5B
enum GL_FLOAT_MAT4 =                     0x8B5C
enum GL_SAMPLER_2D =                     0x8B5E
enum GL_SAMPLER_CUBE =                   0x8B60
enum GL_VERTEX_ATTRIB_ARRAY_ENABLED =        0x8622
enum GL_VERTEX_ATTRIB_ARRAY_SIZE =           0x8623
enum GL_VERTEX_ATTRIB_ARRAY_STRIDE =         0x8624
enum GL_VERTEX_ATTRIB_ARRAY_TYPE =           0x8625
enum GL_VERTEX_ATTRIB_ARRAY_NORMALIZED =     0x886A
enum GL_VERTEX_ATTRIB_ARRAY_POINTER =        0x8645
enum GL_VERTEX_ATTRIB_ARRAY_BUFFER_BINDING = 0x889F
enum GL_IMPLEMENTATION_COLOR_READ_TYPE =     0x8B9A
enum GL_IMPLEMENTATION_COLOR_READ_FORMAT =   0x8B9B
enum GL_COMPILE_STATUS =                 0x8B81
enum GL_INFO_LOG_LENGTH =                0x8B84
enum GL_SHADER_SOURCE_LENGTH =           0x8B88
enum GL_SHADER_COMPILER =                0x8DFA
enum GL_SHADER_BINARY_FORMATS =          0x8DF8
enum GL_NUM_SHADER_BINARY_FORMATS =      0x8DF9
enum GL_LOW_FLOAT =                      0x8DF0
enum GL_MEDIUM_FLOAT =                   0x8DF1
enum GL_HIGH_FLOAT =                     0x8DF2
enum GL_LOW_INT =                        0x8DF3
enum GL_MEDIUM_INT =                     0x8DF4
enum GL_HIGH_INT =                       0x8DF5
enum GL_FRAMEBUFFER =                    0x8D40
enum GL_RENDERBUFFER =                   0x8D41
enum GL_RGBA4 =                          0x8056
enum GL_RGB5_A1 =                        0x8057
enum GL_RGB565 =                         0x8D62
enum GL_DEPTH_COMPONENT16 =              0x81A5
enum GL_STENCIL_INDEX =                  0x1901
enum GL_STENCIL_INDEX8 =                 0x8D48
enum GL_RENDERBUFFER_WIDTH =             0x8D42
enum GL_RENDERBUFFER_HEIGHT =            0x8D43
enum GL_RENDERBUFFER_INTERNAL_FORMAT =   0x8D44
enum GL_RENDERBUFFER_RED_SIZE =          0x8D50
enum GL_RENDERBUFFER_GREEN_SIZE =        0x8D51
enum GL_RENDERBUFFER_BLUE_SIZE =         0x8D52
enum GL_RENDERBUFFER_ALPHA_SIZE =        0x8D53
enum GL_RENDERBUFFER_DEPTH_SIZE =        0x8D54
enum GL_RENDERBUFFER_STENCIL_SIZE =      0x8D55
enum GL_FRAMEBUFFER_ATTACHMENT_OBJECT_TYPE =           0x8CD0
enum GL_FRAMEBUFFER_ATTACHMENT_OBJECT_NAME =           0x8CD1
enum GL_FRAMEBUFFER_ATTACHMENT_TEXTURE_LEVEL =         0x8CD2
enum GL_FRAMEBUFFER_ATTACHMENT_TEXTURE_CUBE_MAP_FACE = 0x8CD3
enum GL_COLOR_ATTACHMENT0 =              0x8CE0
enum GL_DEPTH_ATTACHMENT =               0x8D00
enum GL_STENCIL_ATTACHMENT =             0x8D20
enum GL_NONE =                           0
enum GL_FRAMEBUFFER_COMPLETE =                      0x8CD5
enum GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT =         0x8CD6
enum GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT = 0x8CD7
enum GL_FRAMEBUFFER_INCOMPLETE_DIMENSIONS =         0x8CD9
enum GL_FRAMEBUFFER_UNSUPPORTED =                   0x8CDD
enum GL_FRAMEBUFFER_BINDING =            0x8CA6
enum GL_RENDERBUFFER_BINDING =           0x8CA7
enum GL_MAX_RENDERBUFFER_SIZE =          0x84E8
enum GL_INVALID_FRAMEBUFFER_OPERATION =  0x0506

void glActiveTexture(GLenum texture);
void glAttachShader(GLuint program, GLuint shader);
void glBindAttribLocation(GLuint program, GLuint index, const(GLchar)* name);
void glBindBuffer(GLenum target, GLuint buffer);
void glBindFramebuffer(GLenum target, GLuint framebuffer);
void glBindRenderbuffer(GLenum target, GLuint renderbuffer);
void glBindTexture(GLenum target, GLuint texture);
void glBlendColor(GLclampf red, GLclampf green, GLclampf blue, GLclampf alpha);
void glBlendEquation(GLenum mode);
void glBlendEquationSeparate(GLenum modeRGB, GLenum modeAlpha);
void glBlendFunc(GLenum sfactor, GLenum dfactor);
void glBlendFuncSeparate(GLenum srcRGB, GLenum dstRGB, GLenum srcAlpha, GLenum dstAlpha);
void glBufferData(GLenum target, GLsizeiptr size, const(GLvoid)* data, GLenum usage);
void glBufferSubData(GLenum target, GLintptr offset, GLsizeiptr size, const(GLvoid)* data);
GLenum glCheckFramebufferStatus(GLenum target);
void glClear(GLbitfield mask);
void glClearColor(GLclampf red, GLclampf green, GLclampf blue, GLclampf alpha);
void glClearDepthf(GLclampf depth);
void glClearStencil(GLint s);
void glColorMask(GLboolean red, GLboolean green, GLboolean blue, GLboolean alpha);
void glCompileShader(GLuint shader);
void glCompressedTexImage2D(GLenum target, GLint level, GLenum internalformat, GLsizei width, GLsizei height, GLint border, GLsizei imageSize, const(GLvoid)* data);
void glCompressedTexSubImage2D(GLenum target, GLint level, GLint xoffset, GLint yoffset, GLsizei width, GLsizei height, GLenum format, GLsizei imageSize, const(GLvoid)* data);
void glCopyTexImage2D(GLenum target, GLint level, GLenum internalformat, GLint x, GLint y, GLsizei width, GLsizei height, GLint border);
void glCopyTexSubImage2D(GLenum target, GLint level, GLint xoffset, GLint yoffset, GLint x, GLint y, GLsizei width, GLsizei height);
GLuint glCreateProgram();
GLuint glCreateShader(GLenum type);
void glCullFace(GLenum mode);
void glDeleteBuffers(GLsizei n, const(GLuint)* buffers);
void glDeleteFramebuffers(GLsizei n, const(GLuint)* framebuffers);
void glDeleteProgram(GLuint program);
void glDeleteRenderbuffers(GLsizei n, const(GLuint)* renderbuffers);
void glDeleteShader(GLuint shader);
void glDeleteTextures(GLsizei n, const(GLuint)* textures);
void glDepthFunc(GLenum func);
void glDepthMask(GLboolean flag);
void glDepthRangef(GLclampf zNear, GLclampf zFar);
void glDetachShader(GLuint program, GLuint shader);
void glDisable(GLenum cap);
void glDisableVertexAttribArray(GLuint index);
void glDrawArrays(GLenum mode, GLint first, GLsizei count);
void glDrawElements(GLenum mode, GLsizei count, GLenum type, const(GLvoid)* indices);
void glEnable(GLenum cap);
void glEnableVertexAttribArray(GLuint index);
void glFinish();
void glFlush();
void glFramebufferRenderbuffer(GLenum target, GLenum attachment, GLenum renderbuffertarget, GLuint renderbuffer);
void glFramebufferTexture2D(GLenum target, GLenum attachment, GLenum textarget, GLuint texture, GLint level);
void glFrontFace(GLenum mode);
void glGenBuffers(GLsizei n, GLuint* buffers);
void glGenerateMipmap(GLenum target);
void glGenFramebuffers(GLsizei n, GLuint* framebuffers);
void glGenRenderbuffers(GLsizei n, GLuint* renderbuffers);
void glGenTextures(GLsizei n, GLuint* textures);
void glGetActiveAttrib(GLuint program, GLuint index, GLsizei bufsize, GLsizei* length, GLint* size, GLenum* type, GLchar* name);
void glGetActiveUniform(GLuint program, GLuint index, GLsizei bufsize, GLsizei* length, GLint* size, GLenum* type, GLchar* name);
void glGetAttachedShaders(GLuint program, GLsizei maxcount, GLsizei* count, GLuint* shaders);
GLint glGetAttribLocation(GLuint program, const(GLchar)* name);
void glGetBooleanv(GLenum pname, GLboolean* params);
void glGetBufferParameteriv(GLenum target, GLenum pname, GLint* params);
GLenum glGetError();
void glGetFloatv(GLenum pname, GLfloat* params);
void glGetFramebufferAttachmentParameteriv(GLenum target, GLenum attachment, GLenum pname, GLint* params);
void glGetIntegerv(GLenum pname, GLint* params);
void glGetProgramiv(GLuint program, GLenum pname, GLint* params);
void glGetProgramInfoLog(GLuint program, GLsizei bufsize, GLsizei* length, GLchar* infolog);
void glGetRenderbufferParameteriv(GLenum target, GLenum pname, GLint* params);
void glGetShaderiv(GLuint shader, GLenum pname, GLint* params);
void glGetShaderInfoLog(GLuint shader, GLsizei bufsize, GLsizei* length, GLchar* infolog);
void glGetShaderPrecisionFormat(GLenum shadertype, GLenum precisiontype, GLint* range, GLint* precision);
void glGetShaderSource(GLuint shader, GLsizei bufsize, GLsizei* length, GLchar* source);
const(GLubyte)* glGetString(GLenum name);
void glGetTexParameterfv(GLenum target, GLenum pname, GLfloat* params);
void glGetTexParameteriv(GLenum target, GLenum pname, GLint* params);
void glGetUniformfv(GLuint program, GLint location, GLfloat* params);
void glGetUniformiv(GLuint program, GLint location, GLint* params);
GLint glGetUniformLocation(GLuint program, const(GLchar)* name);
void glGetVertexAttribfv(GLuint index, GLenum pname, GLfloat* params);
void glGetVertexAttribiv(GLuint index, GLenum pname, GLint* params);
void glGetVertexAttribPointerv(GLuint index, GLenum pname, GLvoid** pointer);
void glHint(GLenum target, GLenum mode);
GLboolean glIsBuffer(GLuint buffer);
GLboolean glIsEnabled(GLenum cap);
GLboolean glIsFramebuffer(GLuint framebuffer);
GLboolean glIsProgram(GLuint program);
GLboolean glIsRenderbuffer(GLuint renderbuffer);
GLboolean glIsShader(GLuint shader);
GLboolean glIsTexture(GLuint texture);
void glLineWidth(GLfloat width);
void glLinkProgram(GLuint program);
void glPixelStorei(GLenum pname, GLint param);
void glPolygonOffset(GLfloat factor, GLfloat units);
void glReadPixels(GLint x, GLint y, GLsizei width, GLsizei height, GLenum format, GLenum type, GLvoid* pixels);
void glReleaseShaderCompiler();
void glRenderbufferStorage(GLenum target, GLenum internalformat, GLsizei width, GLsizei height);
void glSampleCoverage(GLclampf value, GLboolean invert);
void glScissor(GLint x, GLint y, GLsizei width, GLsizei height);
void glShaderBinary(GLsizei n, const(GLuint)* shaders, GLenum binaryformat, const(GLvoid)* binary, GLsizei length);
void glShaderSource(GLuint shader, GLsizei count, in GLchar** string, const(GLint)* length);
void glStencilFunc(GLenum func, GLint ref_, GLuint mask);
void glStencilFuncSeparate(GLenum face, GLenum func, GLint ref_, GLuint mask);
void glStencilMask(GLuint mask);
void glStencilMaskSeparate(GLenum face, GLuint mask);
void glStencilOp(GLenum fail, GLenum zfail, GLenum zpass);
void glStencilOpSeparate(GLenum face, GLenum fail, GLenum zfail, GLenum zpass);
void glTexImage2D(GLenum target, GLint level, GLint internalformat, GLsizei width, GLsizei height, GLint border, GLenum format, GLenum type, const(GLvoid)* pixels);
void glTexParameterf(GLenum target, GLenum pname, GLfloat param);
void glTexParameterfv(GLenum target, GLenum pname, const(GLfloat)* params);
void glTexParameteri(GLenum target, GLenum pname, GLint param);
void glTexParameteriv(GLenum target, GLenum pname, const(GLint)* params);
void glTexSubImage2D(GLenum target, GLint level, GLint xoffset, GLint yoffset, GLsizei width, GLsizei height, GLenum format, GLenum type, const(GLvoid)* pixels);
void glUniform1f(GLint location, GLfloat x);
void glUniform1fv(GLint location, GLsizei count, const(GLfloat)* v);
void glUniform1i(GLint location, GLint x);
void glUniform1iv(GLint location, GLsizei count, const(GLint)* v);
void glUniform2f(GLint location, GLfloat x, GLfloat y);
void glUniform2fv(GLint location, GLsizei count, const(GLfloat)* v);
void glUniform2i(GLint location, GLint x, GLint y);
void glUniform2iv(GLint location, GLsizei count, const(GLint)* v);
void glUniform3f(GLint location, GLfloat x, GLfloat y, GLfloat z);
void glUniform3fv(GLint location, GLsizei count, const(GLfloat)* v);
void glUniform3i(GLint location, GLint x, GLint y, GLint z);
void glUniform3iv(GLint location, GLsizei count, const(GLint)* v);
void glUniform4f(GLint location, GLfloat x, GLfloat y, GLfloat z, GLfloat w);
void glUniform4fv(GLint location, GLsizei count, const(GLfloat)* v);
void glUniform4i(GLint location, GLint x, GLint y, GLint z, GLint w);
void glUniform4iv(GLint location, GLsizei count, const(GLint)* v);
void glUniformMatrix2fv(GLint location, GLsizei count, GLboolean transpose, const(GLfloat)* value);
void glUniformMatrix3fv(GLint location, GLsizei count, GLboolean transpose, const(GLfloat)* value);
void glUniformMatrix4fv(GLint location, GLsizei count, GLboolean transpose, const(GLfloat)* value);
void glUseProgram(GLuint program);
void glValidateProgram(GLuint program);
void glVertexAttrib1f(GLuint indx, GLfloat x);
void glVertexAttrib1fv(GLuint indx, const(GLfloat)* values);
void glVertexAttrib2f(GLuint indx, GLfloat x, GLfloat y);
void glVertexAttrib2fv(GLuint indx, const(GLfloat)* values);
void glVertexAttrib3f(GLuint indx, GLfloat x, GLfloat y, GLfloat z);
void glVertexAttrib3fv(GLuint indx, const(GLfloat)* values);
void glVertexAttrib4f(GLuint indx, GLfloat x, GLfloat y, GLfloat z, GLfloat w);
void glVertexAttrib4fv(GLuint indx, const(GLfloat)* values);
void glVertexAttribPointer(GLuint indx, GLint size, GLenum type, GLboolean normalized, GLsizei stride, const(GLvoid)* ptr);
void glViewport(GLint x, GLint y, GLsizei width, GLsizei height);
