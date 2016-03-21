module d3d;

import dlangui;
import dlangui.graphics.scene.scene3d;
import dlangui.graphics.scene.camera;
import dlangui.graphics.scene.mesh;
import dlangui.graphics.scene.material;
import dlangui.graphics.glsupport;
import dlangui.graphics.gldrawbuf;
import derelict.opengl3.gl3;
import derelict.opengl3.gl;

mixin APP_ENTRY_POINT;

/// entry point for dlangui based application
extern (C) int UIAppMain(string[] args) {
    // embed resources listed in views/resources.list into executable
    embeddedResourceList.addResources(embedResourcesFromList!("resources.list")());

    // create window
    Window window = Platform.instance.createWindow("DlangUI example - 3D Application", null, WindowFlag.Resizable, 600, 500);
    window.mainWidget = new UiWidget();

    //MeshPart part = new MeshPart();

    // show window
    window.show();

    // run message loop
    return Platform.instance.enterMessageLoop();
}

class UiWidget : VerticalLayout {
    this() {
        super("OpenGLView");
        layoutWidth = FILL_PARENT;
        layoutHeight = FILL_PARENT;
        alignment = Align.Center;
        parseML(q{
            {
              margins: 10
              padding: 10
              backgroundImageId: "tx_fabric.tiled"
              layoutWidth: fill
              layoutHeight: fill

              VerticalLayout {
                id: glView
                margins: 10
                padding: 10
                layoutWidth: fill
                layoutHeight: fill
                TextWidget { text: "There should be OpenGL animation on background"; textColor: "red"; fontSize: 150%; fontWeight: 800; fontFace: "Arial" }
                TextWidget { text: "Do you see it? If no, there is some bug in Mesh rendering code..."; fontSize: 120% }
                HorizontalLayout {
                    layoutWidth: fill
                    TextWidget { text: "Text 20%"; backgroundColor:"#80FF0000"; layoutWidth: 20% }
                    VerticalLayout {
                        layoutWidth: 30%
                        TextWidget { text: "Text 30%"; backgroundColor:"#80FF00FF" }
                        TextWidget { text: "Text 30%"; backgroundColor:"#8000FFFF" }
                        TextWidget { text: "Text 30%"; backgroundColor:"#8000FFFF" }
                    }
                    TextWidget { text: "Text 50%"; backgroundColor:"#80FFFF00"; layoutWidth: 50% }
                }
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
                VSpacer { layoutWeight: 30 }
                HorizontalLayout {
                    TextWidget { text: "Some buttons:" }
                    Button { id: btnOk; text: "Ok"; fontSize: 27px }
                    Button { id: btnCancel; text: "Cancel"; fontSize: 27px }
                }
              }
            }
        }, "", this);
        // assign OpenGL drawable to child widget background
        childById("glView").backgroundDrawable = DrawableRef(new OpenGLDrawable(&doDraw));


        _scene = new Scene3d();

        _cam = new Camera();
        _cam.translate(vec3(0, 0, -7));

        _scene.activeCamera = _cam;

        _mesh = Mesh.createCubeMesh(vec3(0, 0, 0), 0.3f);
        for (int i = 0; i < 10; i++) {
            _mesh.addCubeMesh(vec3(0, 0, i * 2 + 1.0f), 0.2f, vec4(i / 12, 1, 1, 1));
            _mesh.addCubeMesh(vec3(i * 2 + 1.0f, 0, 0), 0.2f, vec4(1, i / 12, 1, 1));
            _mesh.addCubeMesh(vec3(-i * 2 - 1.0f, 0, 0), 0.2f, vec4(1, i / 12, 1, 1));
            _mesh.addCubeMesh(vec3(0, i * 2 + 1.0f, 0), 0.2f, vec4(1, 1, i / 12 + 0.1, 1));
            _mesh.addCubeMesh(vec3(0, -i * 2 - 1.0f, 0), 0.2f, vec4(1, 1, i / 12 + 0.1, 1));
            _mesh.addCubeMesh(vec3(i * 2 + 1.0f, i * 2 + 1.0f, i * 2 + 1.0f), 0.2f, vec4(i / 12, i / 12, i / 12, 1));
            _mesh.addCubeMesh(vec3(-i * 2 + 1.0f, i * 2 + 1.0f, i * 2 + 1.0f), 0.2f, vec4(i / 12, i / 12, 1 - i / 12, 1));
            _mesh.addCubeMesh(vec3( i * 2 + 1.0f, -i * 2 + 1.0f, i * 2 + 1.0f), 0.2f, vec4(i / 12, 1 - i / 12, i / 12, 1));
            _mesh.addCubeMesh(vec3(-i * 2 - 1.0f, -i * 2 - 1.0f, -i * 2 - 1.0f), 0.2f, vec4(1 - i / 12, i / 12, i / 12, 1));
        }

        import dminer.core.world;
        World w = new World();
        for (int x = -100; x < 100; x++)
            for (int z = -100; z < 100; z++)
                w.setCell(x, 10, z, 1);
    }

    /// returns true is widget is being animated - need to call animate() and redraw
    @property override bool animating() { return true; }
    /// animates window; interval is time left from previous draw, in hnsecs (1/10000000 of second)
    override void animate(long interval) {
        //Log.d("animating");
        _cam.rotateX(0.01);
        _cam.rotateY(0.02);
        angle += interval * 0.000002f;
        invalidate();
    }
    float angle = 0;

    MyGLProgram _program;
    Scene3d _scene;
    Camera _cam;
    Mesh _mesh;
    GLTexture _tx;


    /// this is OpenGLDrawableDelegate implementation
    private void doDraw(Rect windowRect, Rect rc) {
        if (!_program) {
            _program = new MyGLProgram();
        }
        if (!_program.check())
            return;
        if (!_tx)
            _tx = new GLTexture("crate");
        if (!_tx.isValid) {
            Log.e("Invalid texture");
            return;
        }
        _cam.setPerspective(rc.width, rc.height, 45.0f, 0.1f, 100.0f);
        _cam.setIdentity();
        _cam.translate(vec3(0, 0, -1.1)); // - angle/1000
        _cam.rotateZ(30.0f + angle * 0.3456778);
        mat4 projectionViewMatrix = _cam.projectionViewMatrix;

        // ======== Model Matrix ==================
        mat4 modelMatrix;
        //modelMatrix.scale(0.1f);
        modelMatrix.rotatez(30.0f + angle * 0.3456778);
        //modelMatrix.rotatey(25);
        //modelMatrix.rotatex(15);
        modelMatrix.rotatey(angle);
        modelMatrix.rotatex(angle * 1.98765f);

        mat4 projectionViewModelMatrix = projectionViewMatrix * modelMatrix;

        //projectionViewModelMatrix.setIdentity();
        //Log.d("matrix uniform: ", projectionViewModelMatrix.m);

        checkgl!glEnable(GL_CULL_FACE);
        checkgl!glEnable(GL_DEPTH_TEST);
        checkgl!glCullFace(GL_BACK);

        _program.bind();
        _program.setUniform("matrix", projectionViewModelMatrix);
        _tx.texture.setup();
        _tx.texture.setSamplerParams(true);

        _program.draw(_mesh);

        _tx.texture.unbind();
        _program.unbind();
        checkgl!glDisable(GL_DEPTH_TEST);
        checkgl!glDisable(GL_CULL_FACE);
    }

    ~this() {
        destroy(_scene);
        if (_program)
            destroy(_program);
        if (_tx)
            destroy(_tx);
    }
}


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
    protected int matrixLocation;
    protected int vertexLocation;
    protected int colAttrLocation;
    protected int texCoordLocation;

    override bool initLocations() {
        matrixLocation = getUniformLocation("matrix");
        vertexLocation = getAttribLocation("vertex");
        colAttrLocation = getAttribLocation("colAttr");
        texCoordLocation = getAttribLocation("texCoord");
        return matrixLocation >= 0 && vertexLocation >= 0 && colAttrLocation >= 0 && texCoordLocation >= 0;
    }

    /// get location for vertex attribute
    override int getVertexElementLocation(VertexElementType type) {
        switch(type) with(VertexElementType) {
            case POSITION: 
                return vertexLocation;
            case COLOR: 
                return colAttrLocation;
            case TEXCOORD0: 
                return texCoordLocation;
            default:
                return super.getVertexElementLocation(type);
        }
    }

}

