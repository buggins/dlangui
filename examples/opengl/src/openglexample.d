module openglexample;

import dlangui;

mixin APP_ENTRY_POINT;

/// entry point for dlangui based application
extern (C) int UIAppMain(string[] args) {
    // embed resources listed in views/resources.list into executable
    embeddedResourceList.addResources(embedResourcesFromList!("resources.list")());

    // the old API example works on old context because of OpenGL deprecation model
    // otherwise there will be GL_INVALID_OPERATION error
    // new API functions on a modern graphics card will work even if you set context version to 1.0
    Platform.instance.GLVersionMajor = 2;
    Platform.instance.GLVersionMinor = 1;

    // create window
    Window window = Platform.instance.createWindow("DlangUI OpenGL Example", null, WindowFlag.Resizable, 800, 700);

    static if (ENABLE_OPENGL) {
        window.mainWidget = new MyOpenglWidget();
    } else {
        window.mainWidget = new TextWidget(null, "DlangUI is built with OpenGL support disabled"d);
    }

    window.windowIcon = drawableCache.getImage("dlangui-logo1");

    window.show();
    // run message loop
    return Platform.instance.enterMessageLoop();
}

static if (ENABLE_OPENGL):

import derelict.opengl3.gl3;
import derelict.opengl3.gl;
import dlangui.graphics.glsupport;
import dlangui.graphics.gldrawbuf;

class MyOpenglWidget : VerticalLayout {
    this() {
        super("OpenGLView");
        layoutWidth = FILL_PARENT;
        layoutHeight = FILL_PARENT;
        alignment = Align.Center;
        // add some UI on top of OpenGL drawable
        Widget w = parseML(q{
            VerticalLayout {
                alignment: center
                layoutWidth: fill; layoutHeight: fill
                // background for window - tiled texture
                backgroundImageId: "tx_fabric.tiled"
                VerticalLayout {
                    // child widget - will draw using OpenGL here
                    id: glView
                    margins: 20
                    padding: 20
                    layoutWidth: fill; layoutHeight: fill

                    TextWidget { text: "DlangUI OpenGL custom drawable example"; textColor: "red"; fontSize: 150%; fontWeight: 800; fontFace: "Arial" }

                    TextWidget { text: "Choose OpenGL drawable:" }
                    VerticalLayout {
                        RadioButton { id: rbExample1; text: "Shaders based example - Cube"; checked: true }
                        RadioButton { id: rbExample2; text: "Legacy OpenGL API example - glxGears" }
                    }

                    TextWidget { text: "Some controls to draw on top of OpenGL scene"; textColor: "red"; fontSize: 150%; fontWeight: 800; fontFace: "Arial" }

                    // arrange controls as form - table with two columns
                    TableLayout {
                        colCount: 2
                        TextWidget { text: "param 1" }
                        EditLine { id: edit1; text: "some text" }
                        TextWidget { text: "param 2" }
                        EditLine { id: edit2; text: "some text for param2" }
                        TextWidget { text: "some radio buttons" }
                        // arrange some radio buttons vertically
                        VerticalLayout {
                            RadioButton { id: rb1; text: "Item 1" }
                            RadioButton { id: rb2; text: "Item 2" }
                            RadioButton { id: rb3; text: "Item 3" }
                        }
                        TextWidget { text: "and checkboxes" }
                        // arrange some checkboxes horizontally
                        HorizontalLayout {
                            CheckBox { id: cb1; text: "checkbox 1" }
                            CheckBox { id: cb2; text: "checkbox 2" }
                        }
                    }
                    VSpacer { layoutWeight: 10 }
                    HorizontalLayout {
                        Button { id: btnOk; text: "Ok" }
                        Button { id: btnCancel; text: "Cancel" }
                    }
                }
            }
        });
        // assign OpenGL drawable to child widget background
        w.childById("glView").backgroundDrawable = DrawableRef(new OpenGLDrawable(&doDraw));

        w.childById("rbExample1").click = delegate(Widget w) {
            _exampleIndex = 0; // new API
            return true;
        };
        w.childById("rbExample2").click = delegate(Widget w) {
            _exampleIndex = 1; // old API
            return true;
        };

        addChild(w);
    }

    int _exampleIndex = 0;

    /// returns true is widget is being animated - need to call animate() and redraw
    @property override bool animating() { return true; }
    /// animates window; interval is time left from previous draw, in hnsecs (1/10000000 of second)
    override void animate(long interval) {
        if (_exampleIndex == 1) {
            // animate legacy API example
            // rotate gears
            angle += interval * 0.000002f;
        } else {
            // TODO: some other animation for new API example
            angle += interval * 0.000002f;
        }
        invalidate();
    }

    /// this is OpenGLDrawableDelegate implementation
    private void doDraw(Rect windowRect, Rect rc) {
        if (!openglEnabled) {
            Log.v("GlGears: OpenGL is disabled");
            return;
        }
        bool canUseOldApi = !!glLightfv;
        bool canUseNewApi = !glSupport.legacyMode;
        if (_exampleIndex == 0 || !canUseOldApi)
            drawUsingNewAPI(windowRect, rc);
        else if (_exampleIndex == 1 || !canUseNewApi)
            drawUsingOldAPI(windowRect, rc);
    }

    /// Legacy API example (glBegin/glEnd) - glxGears
    void drawUsingOldAPI(Rect windowRect, Rect rc) {
        static bool _initCalled;
        if (!_initCalled) {
            Log.d("GlGears: calling init()");
            _initCalled = true;
            glxgears_init();
        }
        glxgears_reshape(rc);
        glEnable(GL_LIGHTING);
        glEnable(GL_LIGHT0);
        glEnable(GL_DEPTH_TEST);
        glxgears_draw();
        glDisable(GL_LIGHTING);
        glDisable(GL_LIGHT0);
        glDisable(GL_DEPTH_TEST);
    }

    ~this() {
        if (_program)
            destroy(_program);
        if (_vao)
            destroy(_vao);
        if (_vbo)
            destroy(_vbo);
        if (_tx)
            destroy(_tx);
    }

    MyGLProgram _program;
    GLTexture _tx;
    VAO _vao;
    VBO _vbo;

    /// New API example (OpenGL3+, shaders)
    void drawUsingNewAPI(Rect windowRect, Rect rc) {
        if (!_program) {
            _program = new MyGLProgram;
            _program.compile();
            createMesh();
            auto buf = _program.createBuffers(vertices, colors, texcoords);
            _vao = buf[0];
            _vbo = buf[1];
        }
        if (!_program.check())
            return;
        if (!_tx.isValid) {
            Log.e("Invalid texture");
            return;
        }

        checkgl!glEnable(GL_CULL_FACE);
        checkgl!glEnable(GL_DEPTH_TEST);
        checkgl!glCullFace(GL_BACK);

        // ======== Projection Matrix ==================
        mat4 projectionMatrix;
        float aspectRatio = cast(float)rc.width / cast(float)rc.height;
        projectionMatrix.setPerspective(45.0f, aspectRatio, 0.1f, 100.0f);

        // ======== View Matrix ==================
        mat4 viewMatrix;
        viewMatrix.translate(0, 0, -6);
        viewMatrix.rotatex(-15.0f);
        //viewMatrix.lookAt(vec3(-10, 0, 0), vec3(0, 0, 0), vec3(0, 1, 0));//translation(0.0f, 0.0f, 4.0f).rotatez(angle);

        // ======== Model Matrix ==================
        mat4 modelMatrix;
        modelMatrix.scale(1.5f);
        modelMatrix.rotatez(30.0f + angle * 0.3456778);
        modelMatrix.rotatey(angle);
        modelMatrix.rotatez(angle * 1.98765f);

        // ======= PMV matrix =====================
        mat4 projectionViewModelMatrix = projectionMatrix * viewMatrix * modelMatrix;

        _program.execute(_vao, cast(int)vertices.length / 3, _tx.texture, true, projectionViewModelMatrix.m);

        checkgl!glDisable(GL_CULL_FACE);
        checkgl!glDisable(GL_DEPTH_TEST);
    }

    // Cube mesh
    float[] vertices;
    float[] texcoords;
    float[4*6*6] colors;
    void createMesh() {
        if (!_tx)
            _tx = new GLTexture("crate");

        // define Cube mesh
        auto p000 = [-1.0f, -1.0f, -1.0f];
        auto p100 = [ 1.0f, -1.0f, -1.0f];
        auto p010 = [-1.0f,  1.0f, -1.0f];
        auto p110 = [ 1.0f,  1.0f, -1.0f];
        auto p001 = [-1.0f, -1.0f,  1.0f];
        auto p101 = [ 1.0f, -1.0f,  1.0f];
        auto p011 = [-1.0f,  1.0f,  1.0f];
        auto p111 = [ 1.0f,  1.0f,  1.0f];
        vertices = p000 ~ p010 ~ p110 ~  p110 ~ p100 ~ p000 // front face
                 ~ p101 ~ p111 ~ p011 ~  p011 ~ p001 ~ p101 // back face
                 ~ p100 ~ p110 ~ p111 ~  p111 ~ p101 ~ p100 // right face
                 ~ p001 ~ p011 ~ p010 ~  p010 ~ p000 ~ p001 // left face
                 ~ p010 ~ p011 ~ p111 ~  p111 ~ p110 ~ p010 // top face
                 ~ p001 ~ p000 ~ p100 ~  p100 ~ p101 ~ p001 // bottom face
            ;
        // texture coordinates
        float[2] uv = _tx.uv;
        float tx0 = 0.0f;
        float tx1 = uv[0];
        float ty0 = 0.0f;
        float ty1 = uv[1];
        float[12] facetx = [tx1, ty1, // triangle 1
                            tx0, ty0,
                            tx0, ty1,
                            tx0, ty1, // triangle 2
                            tx1, ty0,
                            tx1, ty1];
        texcoords = facetx ~ facetx ~ facetx ~ facetx ~ facetx ~ facetx;
        // init with white color (1, 1, 1, 1)
        foreach(ref cl; colors)
            cl = 1.0f;
    }
}

// ====================================================================================
// Shaders based example

// Simple texture + color shader
class MyGLProgram : GLProgram {
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

    // attribute locations
    protected GLint matrixLocation;
    protected GLint vertexLocation;
    protected GLint colAttrLocation;
    protected GLint texCoordLocation;

    override bool initLocations() {
        matrixLocation = getUniformLocation("matrix");
        vertexLocation = getAttribLocation("vertex");
        colAttrLocation = getAttribLocation("colAttr");
        texCoordLocation = getAttribLocation("texCoord");
        return matrixLocation >= 0 && vertexLocation >= 0 && colAttrLocation >= 0 && texCoordLocation >= 0;
    }

    import std.typecons : Tuple, tuple;
    Tuple!(VAO, VBO) createBuffers(float[] vertices, float[] colors, float[] texcoords) {

        VBO vbo = new VBO;
        vbo.fill([vertices, colors, texcoords]);

        VAO vao = new VAO;
        glVertexAttribPointer(vertexLocation, 3, GL_FLOAT, GL_FALSE, 0, cast(void*) 0);
        glVertexAttribPointer(colAttrLocation, 4, GL_FLOAT, GL_FALSE, 0, cast(void*) (vertices.length * vertices[0].sizeof));
        glVertexAttribPointer(texCoordLocation, 2, GL_FLOAT, GL_FALSE, 0, cast(void*) (vertices.length * vertices[0].sizeof + colors.length * colors[0].sizeof));

        glEnableVertexAttribArray(vertexLocation);
        glEnableVertexAttribArray(colAttrLocation);
        glEnableVertexAttribArray(texCoordLocation);

        return tuple(vao, vbo);
    }

    void execute(VAO vao, int vertsCount, Tex2D texture, bool linear, float[16] matrix) {

        bind();
        checkgl!glUniformMatrix4fv(matrixLocation, 1, false, matrix.ptr);

        texture.setup();
        texture.setSamplerParams(linear);

        vao.bind();
        checkgl!glDrawArrays(GL_TRIANGLES, 0, vertsCount);

        texture.unbind();
        unbind();
    }
}




//=====================================================================================
// Legacy OpenGL API example
// GlxGears
//=====================================================================================

import std.math;
static __gshared GLfloat view_rotx = 20.0, view_roty = 30.0, view_rotz = 0.0;
static __gshared GLint gear1, gear2, gear3;
static __gshared GLfloat angle = 0.0;
alias M_PI = std.math.PI;

/*
*
*  Draw a gear wheel.  You'll probably want to call this function when
*  building a display list since we do a lot of trig here.
*
*  Input:  inner_radius - radius of hole at center
*          outer_radius - radius at center of teeth
*          width - width of gear
*          teeth - number of teeth
*          tooth_depth - depth of tooth
*/
static void
    gear(GLfloat inner_radius, GLfloat outer_radius, GLfloat width,
            GLint teeth, GLfloat tooth_depth)
{
    GLint i;
    GLfloat r0, r1, r2;
    GLfloat angle, da;
    GLfloat u, v, len;

    r0 = inner_radius;
    r1 = outer_radius - tooth_depth / 2.0;
    r2 = outer_radius + tooth_depth / 2.0;

    da = 2.0 * M_PI / teeth / 4.0;

    glShadeModel(GL_FLAT);

    glNormal3f(0.0, 0.0, 1.0);

    /* draw front face */
    glBegin(GL_QUAD_STRIP);
    for (i = 0; i <= teeth; i++) {
        angle = i * 2.0 * M_PI / teeth;
        glVertex3f(r0 * cos(angle), r0 * sin(angle), width * 0.5);
        glVertex3f(r1 * cos(angle), r1 * sin(angle), width * 0.5);
        if (i < teeth) {
            glVertex3f(r0 * cos(angle), r0 * sin(angle), width * 0.5);
            glVertex3f(r1 * cos(angle + 3 * da), r1 * sin(angle + 3 * da),
                        width * 0.5);
        }
    }
    glEnd();

    /* draw front sides of teeth */
    glBegin(GL_QUADS);
    da = 2.0 * M_PI / teeth / 4.0;
    for (i = 0; i < teeth; i++) {
        angle = i * 2.0 * M_PI / teeth;

        glVertex3f(r1 * cos(angle), r1 * sin(angle), width * 0.5);
        glVertex3f(r2 * cos(angle + da), r2 * sin(angle + da), width * 0.5);
        glVertex3f(r2 * cos(angle + 2 * da), r2 * sin(angle + 2 * da),
                    width * 0.5);
        glVertex3f(r1 * cos(angle + 3 * da), r1 * sin(angle + 3 * da),
                    width * 0.5);
    }
    glEnd();

    glNormal3f(0.0, 0.0, -1.0);

    /* draw back face */
    glBegin(GL_QUAD_STRIP);
    for (i = 0; i <= teeth; i++) {
        angle = i * 2.0 * M_PI / teeth;
        glVertex3f(r1 * cos(angle), r1 * sin(angle), -width * 0.5);
        glVertex3f(r0 * cos(angle), r0 * sin(angle), -width * 0.5);
        if (i < teeth) {
            glVertex3f(r1 * cos(angle + 3 * da), r1 * sin(angle + 3 * da),
                        -width * 0.5);
            glVertex3f(r0 * cos(angle), r0 * sin(angle), -width * 0.5);
        }
    }
    glEnd();

    /* draw back sides of teeth */
    glBegin(GL_QUADS);
    da = 2.0 * M_PI / teeth / 4.0;
    for (i = 0; i < teeth; i++) {
        angle = i * 2.0 * M_PI / teeth;

        glVertex3f(r1 * cos(angle + 3 * da), r1 * sin(angle + 3 * da),
                    -width * 0.5);
        glVertex3f(r2 * cos(angle + 2 * da), r2 * sin(angle + 2 * da),
                    -width * 0.5);
        glVertex3f(r2 * cos(angle + da), r2 * sin(angle + da), -width * 0.5);
        glVertex3f(r1 * cos(angle), r1 * sin(angle), -width * 0.5);
    }
    glEnd();

    /* draw outward faces of teeth */
    glBegin(GL_QUAD_STRIP);
    for (i = 0; i < teeth; i++) {
        angle = i * 2.0 * M_PI / teeth;

        glVertex3f(r1 * cos(angle), r1 * sin(angle), width * 0.5);
        glVertex3f(r1 * cos(angle), r1 * sin(angle), -width * 0.5);
        u = r2 * cos(angle + da) - r1 * cos(angle);
        v = r2 * sin(angle + da) - r1 * sin(angle);
        len = sqrt(u * u + v * v);
        u /= len;
        v /= len;
        glNormal3f(v, -u, 0.0);
        glVertex3f(r2 * cos(angle + da), r2 * sin(angle + da), width * 0.5);
        glVertex3f(r2 * cos(angle + da), r2 * sin(angle + da), -width * 0.5);
        glNormal3f(cos(angle), sin(angle), 0.0);
        glVertex3f(r2 * cos(angle + 2 * da), r2 * sin(angle + 2 * da),
                    width * 0.5);
        glVertex3f(r2 * cos(angle + 2 * da), r2 * sin(angle + 2 * da),
                    -width * 0.5);
        u = r1 * cos(angle + 3 * da) - r2 * cos(angle + 2 * da);
        v = r1 * sin(angle + 3 * da) - r2 * sin(angle + 2 * da);
        glNormal3f(v, -u, 0.0);
        glVertex3f(r1 * cos(angle + 3 * da), r1 * sin(angle + 3 * da),
                    width * 0.5);
        glVertex3f(r1 * cos(angle + 3 * da), r1 * sin(angle + 3 * da),
                    -width * 0.5);
        glNormal3f(cos(angle), sin(angle), 0.0);
    }

    glVertex3f(r1 * cos(0.0), r1 * sin(0.0), width * 0.5);
    glVertex3f(r1 * cos(0.0), r1 * sin(0.0), -width * 0.5);

    glEnd();

    glShadeModel(GL_SMOOTH);

    /* draw inside radius cylinder */
    glBegin(GL_QUAD_STRIP);
    for (i = 0; i <= teeth; i++) {
        angle = i * 2.0 * M_PI / teeth;
        glNormal3f(-cos(angle), -sin(angle), 0.0);
        glVertex3f(r0 * cos(angle), r0 * sin(angle), -width * 0.5);
        glVertex3f(r0 * cos(angle), r0 * sin(angle), width * 0.5);
    }
    glEnd();
}


static void glxgears_draw()
{
    glPushMatrix();
    glRotatef(view_rotx, 1.0, 0.0, 0.0);
    glRotatef(view_roty, 0.0, 1.0, 0.0);
    glRotatef(view_rotz, 0.0, 0.0, 1.0);

    glPushMatrix();
    glTranslatef(-3.0, -2.0, 0.0);
    glRotatef(angle, 0.0, 0.0, 1.0);
    glCallList(gear1);
    glPopMatrix();

    glPushMatrix();
    glTranslatef(3.1, -2.0, 0.0);
    glRotatef(-2.0 * angle - 9.0, 0.0, 0.0, 1.0);
    glCallList(gear2);
    glPopMatrix();

    glPushMatrix();
    glTranslatef(-3.1, 4.2, 0.0);
    glRotatef(-2.0 * angle - 25.0, 0.0, 0.0, 1.0);
    glCallList(gear3);
    glPopMatrix();

    glPopMatrix();
}


/* new window size or exposure */
static void
    glxgears_reshape(Rect rc)
{
    GLfloat h = cast(GLfloat) rc.height / cast(GLfloat) rc.width;
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glFrustum(-1.0, 1.0, -h, h, 5.0, 60.0);
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    glTranslatef(0.0, 0.0, -40.0);
}


static void glxgears_init()
{
    static GLfloat[4] pos = [ 5.0, 5.0, 10.0, 0.0 ];
    static GLfloat[4] red = [ 0.8, 0.1, 0.0, 1.0 ];
    static GLfloat[4] green = [ 0.0, 0.8, 0.2, 1.0 ];
    static GLfloat[4] blue = [ 0.2, 0.2, 1.0, 1.0 ];

    glLightfv(GL_LIGHT0, GL_POSITION, pos.ptr);
    glEnable(GL_CULL_FACE);
    glEnable(GL_LIGHTING);
    glEnable(GL_LIGHT0);
    glEnable(GL_DEPTH_TEST);

    /* make the gears */
    gear1 = glGenLists(1);
    glNewList(gear1, GL_COMPILE);
    glMaterialfv(GL_FRONT, GL_AMBIENT_AND_DIFFUSE, red.ptr);
    gear(1.0, 4.0, 1.0, 20, 0.7);
    glEndList();

    gear2 = glGenLists(1);
    glNewList(gear2, GL_COMPILE);
    glMaterialfv(GL_FRONT, GL_AMBIENT_AND_DIFFUSE, green.ptr);
    gear(0.5, 2.0, 2.0, 10, 0.7);
    glEndList();

    gear3 = glGenLists(1);
    glNewList(gear3, GL_COMPILE);
    glMaterialfv(GL_FRONT, GL_AMBIENT_AND_DIFFUSE, blue.ptr);
    gear(1.3, 2.0, 0.5, 10, 0.7);
    glEndList();

    glEnable(GL_NORMALIZE);
}
