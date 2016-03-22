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

import dminer.core.world;
import dminer.core.minetypes;
import dminer.core.blocks;

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

class UiWidget : VerticalLayout, CellVisitor {
    this() {
        super("OpenGLView");
        layoutWidth = FILL_PARENT;
        layoutHeight = FILL_PARENT;
        alignment = Align.Center;
        try {
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
                    // arrange controls as form - table with two columns
                    TableLayout {
                        colCount: 4
                        TextWidget { text: "Translation X" }
                        ScrollBar { id: sbTranslationX; orientation: horizontal; minValue: -100; maxValue: 100; position: 0; minWidth: 200; alpha: 0.6 }
                        TextWidget { text: "Rotation X" }
                        ScrollBar { id: sbRotationX; orientation: horizontal; minValue: -100; maxValue: 100; position: 0; minWidth: 200; alpha: 0.6 }
                        TextWidget { text: "Translation Y" }
                        ScrollBar { id: sbTranslationY; orientation: horizontal; minValue: -100; maxValue: 100; position: 0; minWidth: 200; alpha: 0.6 }
                        TextWidget { text: "Rotation Y" }
                        ScrollBar { id: sbRotationY; orientation: horizontal; minValue: -100; maxValue: 100; position: 0; minWidth: 150; alpha: 0.6 }
                        TextWidget { text: "Translation Z" }
                        ScrollBar { id: sbTranslationZ; orientation: horizontal; minValue: -100; maxValue: 100; position: 0; minWidth: 150; alpha: 0.6 }
                        TextWidget { text: "Rotation Z" }
                        ScrollBar { id: sbRotationZ; orientation: horizontal; minValue: -100; maxValue: 100; position: 0; minWidth: 150; alpha: 0.6 }
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
        } catch (Exception e) {
            Log.e("Failed to parse dml", e);
        }
        // assign OpenGL drawable to child widget background
        childById("glView").backgroundDrawable = DrawableRef(new OpenGLDrawable(&doDraw));


        mat4 m;
        m.translate(1, 2, -1);
        Log.d("M*v=", m * vec3(0, 0, 0));
        Log.d("M*v=", m * vec3(10, 10, 10));
        m.translate(0, 0, -2);
        Log.d("M*v=", m * vec3(0, 0, 0));
        Log.d("M*v=", m * vec3(10, 10, 10));


        _scene = new Scene3d();

        _cam = new Camera();
        _cam.translate(vec3(0, 14, -7));

        _scene.activeCamera = _cam;

        int x0 = 0;
        int y0 = 0;
        int z0 = 0;

        _mesh = Mesh.createCubeMesh(vec3(x0+ 0, y0 + 0, z0 + 0), 0.3f);
        for (int i = 0; i < 10; i++) {
            _mesh.addCubeMesh(vec3(x0+ 0, y0+0, z0+ i * 2 + 1.0f), 0.2f, vec4(i / 12, 1, 1, 1));
            _mesh.addCubeMesh(vec3(x0+ i * 2 + 1.0f, y0+0, z0+ 0), 0.2f, vec4(1, i / 12, 1, 1));
            _mesh.addCubeMesh(vec3(x0+ -i * 2 - 1.0f, y0+0, z0+ 0), 0.2f, vec4(1, i / 12, 1, 1));
            _mesh.addCubeMesh(vec3(x0+ 0, y0+i * 2 + 1.0f, z0+ 0), 0.2f, vec4(1, 1, i / 12 + 0.1, 1));
            _mesh.addCubeMesh(vec3(x0+ 0, y0+-i * 2 - 1.0f, z0+ 0), 0.2f, vec4(1, 1, i / 12 + 0.1, 1));
            _mesh.addCubeMesh(vec3(x0+ i * 2 + 1.0f, y0+i * 2 + 1.0f, z0+ i * 2 + 1.0f), 0.2f, vec4(i / 12, i / 12, i / 12, 1));
            _mesh.addCubeMesh(vec3(x0+ -i * 2 + 1.0f, y0+i * 2 + 1.0f, z0+ i * 2 + 1.0f), 0.2f, vec4(i / 12, i / 12, 1 - i / 12, 1));
            _mesh.addCubeMesh(vec3(x0+  i * 2 + 1.0f, y0+-i * 2 + 1.0f, z0+ i * 2 + 1.0f), 0.2f, vec4(i / 12, 1 - i / 12, i / 12, 1));
            _mesh.addCubeMesh(vec3(x0+ -i * 2 - 1.0f, y0+-i * 2 - 1.0f, z0+ -i * 2 - 1.0f), 0.2f, vec4(1 - i / 12, i / 12, i / 12, 1));
        }

        _minerMesh = new Mesh(VertexFormat(VertexElementType.POSITION, VertexElementType.NORMAL, VertexElementType.COLOR, VertexElementType.TEXCOORD0));
        _world = new World();
        for (int x = -100; x < 100; x++)
            for (int z = -100; z < 100; z++)
                _world.setCell(x, 0, z, 1);
        _world.setCell(0, 11, 10, 2);
        _world.setCell(5, 11, 15, 2);
        Random rnd;
        rnd.setSeed(12345);
        for(int i = 0; i < 1000; i++)
            _world.setCell(rnd.next(6)-32, rnd.next(4), rnd.next(6)-32, 3);

        _world.camPosition = Position(Vector3d(0, 3, 0), Vector3d(0, 0, 1));
        updateMinerMesh();
        //CellVisitor visitor = new TestVisitor();
        //Log.d("Testing cell visitor");
        //long ts = currentTimeMillis;
        //_world.visitVisibleCells(_world.camPosition, visitor);
        //long duration = currentTimeMillis - ts;
        //Log.d("DiamondVisitor finished in ", duration, " ms");
        //destroy(w);
    }

    void visit(World world, ref Position camPosition, Vector3d pos, cell_t cell, int visibleFaces) {
        BlockDef def = BLOCK_DEFS[cell];
        def.createFaces(world, world.camPosition, pos, visibleFaces, _minerMesh);
    }
    
    void updateMinerMesh() {
        _minerMesh.reset();
        long ts = currentTimeMillis;
        _world.visitVisibleCells(_world.camPosition, this);
        long duration = currentTimeMillis - ts;
        Log.d("DiamondVisitor finished in ", duration, " ms  ", "Vertex count: ", _minerMesh.vertexCount);
    }

    World _world;

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
    Mesh _minerMesh;
    GLTexture _tx;
    GLTexture _blockstx;


    /// this is OpenGLDrawableDelegate implementation
    private void doDraw(Rect windowRect, Rect rc) {
        if (!_program) {
            _program = new MyGLProgram();
        }
        if (!_program.check())
            return;
        if (!_tx)
            _tx = new GLTexture("crate");
        if (!_blockstx)
            _blockstx = new GLTexture("blocks");
        if (!_tx.isValid || !_blockstx.isValid) {
            Log.e("Invalid texture");
            return;
        }
        _cam.setPerspective(rc.width, rc.height, 45.0f, 0.1f, 100.0f);
        _cam.setIdentity();
        //_cam.translate(vec3(
        //     childById!ScrollBar("sbTranslationX").position / 10.0f,
        //     childById!ScrollBar("sbTranslationY").position / 10.0f,
        //     childById!ScrollBar("sbTranslationZ").position / 10.0f));
        _cam.translateX(childById!ScrollBar("sbTranslationX").position / 10.0f);
        _cam.translateY(childById!ScrollBar("sbTranslationY").position / 10.0f);
        _cam.translateZ(childById!ScrollBar("sbTranslationZ").position / 10.0f);
        _cam.rotateX(childById!ScrollBar("sbRotationX").position * 2.5f);
        _cam.rotateY(childById!ScrollBar("sbRotationY").position * 2.5f);
        _cam.rotateZ(childById!ScrollBar("sbRotationZ").position * 2.5f);
        //_cam.translate(vec3(-1, -1.5, -1)); // - angle/1000
        //_cam.translate(vec3(0, 0, -1.1)); // - angle/1000
        //_cam.translate(vec3(0, 3,  - angle/1000)); //
        //_cam.rotateZ(30.0f + angle * 0.3456778);
        mat4 projectionViewMatrix = _cam.projectionViewMatrix;

        Log.d("projectionViewMatrix: ", projectionViewMatrix);

        // ======== Model Matrix ==================
        mat4 modelMatrix;
        //modelMatrix.scale(0.1f);
        //modelMatrix.rotatez(30.0f + angle * 0.3456778);
        //modelMatrix.rotatey(25);
        //modelMatrix.rotatex(15);
        //modelMatrix.rotatey(angle);
        //modelMatrix.rotatex(angle * 1.98765f);

        mat4 projectionViewModelMatrix = projectionViewMatrix * modelMatrix;

        //projectionViewModelMatrix.setIdentity();
        //Log.d("matrix uniform: ", projectionViewModelMatrix.m);

        checkgl!glEnable(GL_CULL_FACE);
        //checkgl!glDisable(GL_CULL_FACE);
        checkgl!glEnable(GL_DEPTH_TEST);
        checkgl!glCullFace(GL_BACK);

        _program.bind();
        _program.setUniform("matrix", projectionViewModelMatrix);
        _tx.texture.setup();
        _tx.texture.setSamplerParams(true);

        _program.draw(_mesh);

        _tx.texture.unbind();

        _blockstx.texture.setup();
        _blockstx.texture.setSamplerParams(false);

        _program.draw(_minerMesh);

        _blockstx.texture.unbind();

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
        destroy(_world);
    }
}

class TestVisitor : CellVisitor {
    //void newDirection(ref Position camPosition) {
    //    Log.d("TestVisitor.newDirection");
    //}
    //void visitFace(World world, ref Position camPosition, Vector3d pos, cell_t cell, Dir face) {
    //    Log.d("TestVisitor.visitFace ", pos, " cell=", cell, " face=", face);
    //}
    void visit(World world, ref Position camPosition, Vector3d pos, cell_t cell, int visibleFaces) {
        //Log.d("TestVisitor.visit ", pos, " cell=", cell);
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

