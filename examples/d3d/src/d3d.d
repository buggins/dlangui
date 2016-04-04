module d3d;

import dlangui;
import dlangui.graphics.scene.scene3d;
import dlangui.graphics.scene.camera;
import dlangui.graphics.scene.mesh;
import dlangui.graphics.scene.material;
import dlangui.graphics.scene.effect;
import dlangui.graphics.scene.model;
import dlangui.graphics.scene.node;
import dlangui.graphics.scene.objimport;
import dlangui.graphics.scene.light;
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
                        colCount: 6
                        TextWidget { text: "Translation X" }
                        TextWidget { id: lblTranslationX; text: "0.0"; minWidth: 80; backgroundColor: 0x80FFFFFF }
                        ScrollBar { id: sbTranslationX; orientation: horizontal; minValue: -100; maxValue: 100; position: 0; minWidth: 200; alpha: 0.6 }
                        TextWidget { text: "Rotation X" }
                        TextWidget { id: lblRotationX; text: "0.0"; minWidth: 80; backgroundColor: 0x80FFFFFF }
                        ScrollBar { id: sbRotationX; orientation: horizontal; minValue: -180; maxValue: 180; position: 0; minWidth: 200; alpha: 0.6 }
                        TextWidget { text: "Translation Y" }
                        TextWidget { id: lblTranslationY; text: "0.0"; minWidth: 80; backgroundColor: 0x80FFFFFF }
                        ScrollBar { id: sbTranslationY; orientation: horizontal; minValue: -100; maxValue: 100; position: 15; minWidth: 200; alpha: 0.6 }
                        TextWidget { text: "Rotation Y" }
                        TextWidget { id: lblRotationY; text: "0.0"; minWidth: 80; backgroundColor: 0x80FFFFFF }
                        ScrollBar { id: sbRotationY; orientation: horizontal; minValue: -180; maxValue: 180; position: 0; minWidth: 150; alpha: 0.6 }
                        TextWidget { text: "Translation Z" }
                        TextWidget { id: lblTranslationZ; text: "0.0"; minWidth: 80; backgroundColor: 0x80FFFFFF }
                        ScrollBar { id: sbTranslationZ; orientation: horizontal; minValue: -100; maxValue: 100; position: 45; minWidth: 150; alpha: 0.6 }
                        TextWidget { text: "Rotation Z" }
                        TextWidget { id: lblRotationZ; text: "0.0"; minWidth: 80; backgroundColor: 0x80FFFFFF }
                        ScrollBar { id: sbRotationZ; orientation: horizontal; minValue: -180; maxValue: 180; position: 0; minWidth: 150; alpha: 0.6 }
                        TextWidget { text: "Near" }
                        TextWidget { id: lblNear; text: "0.1"; minWidth: 80; backgroundColor: 0x80FFFFFF }
                        ScrollBar { id: sbNear; orientation: horizontal; minValue: 1; maxValue: 100; position: 1; minWidth: 150; alpha: 0.6 }
                        TextWidget { text: "Far" }
                        TextWidget { id: lblFar; text: "0.0"; minWidth: 80; backgroundColor: 0x80FFFFFF }
                        ScrollBar { id: sbFar; orientation: horizontal; minValue: 20; maxValue: 1000; position: 1000; minWidth: 150; alpha: 0.6 }
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
        controlsToVars();
        assignHandlers();

        _scene = new Scene3d();

        _cam = new Camera();
        _cam.translate(vec3(0, 14, -7));

        _scene.activeCamera = _cam;

        Node3d dirLightNode = new Node3d();
        dirLightNode.rotateY(-15);
        dirLightNode.rotateX(20);
        dirLightNode.light = Light.createDirectional(vec3(1, 0.5, 0.5));
        _scene.addChild(dirLightNode);

        int x0 = 0;
        int y0 = 0;
        int z0 = 0;

        Mesh _mesh = Mesh.createCubeMesh(vec3(x0+ 0, y0 + 0, z0 + 0), 0.3f);
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
        Material cubeMaterial = new Material(EffectId("textured.vert", "textured.frag", null), "crate");
        Model cubeDrawable = new Model(cubeMaterial, _mesh);
        Node3d cubeNode = new Node3d("cubes", cubeDrawable);
        _scene.addChild(cubeNode);

        ObjModelImport importer;
        string src = loadTextResource("suzanne.obj");
        importer.parse(src);
        Log.d("suzanne mesh:", importer.mesh.dumpVertexes(20));
        Material suzanneMaterial = new Material(EffectId("colored.vert", "colored.frag", null), null); //"DIRECTIONAL_LIGHT_COUNT 1"
        suzanneMaterial.ambientColor = vec3(0.5, 1.0, 0.5);
        suzanneMaterial.diffuseColor = vec4(1.0, 0.7, 0.7, 1.0);
        Model suzanneDrawable = new Model(suzanneMaterial, importer.mesh);
        Node3d suzanneNode = new Node3d("suzanne", suzanneDrawable);
        //suzanneNode.translate(vec3(3, 4, 5));
        _scene.addChild(suzanneNode);


        _minerMesh = new Mesh(VertexFormat(VertexElementType.POSITION, VertexElementType.NORMAL, VertexElementType.COLOR, VertexElementType.TEXCOORD0));
        _world = new World();
        _world.setCell(0, 11, 10, 2);
        _world.setCell(5, 11, 15, 2);
        for (int x = -100; x < 100; x++)
            for (int z = -100; z < 100; z++)
                _world.setCell(x, 0, z, 2);
        Random rnd;
        rnd.setSeed(12345);
        for(int i = 0; i < 1000; i++) {
            int bx = rnd.next(6)-32;
            int by = rnd.next(4); 
            int bz = rnd.next(6)-32;
            Log.fd("Setting cell %d,%d,%d", bx, by, bz);
            _world.setCell(bx, by, bz, 3);
        }

        _world.camPosition = Position(Vector3d(0, 3, 0), Vector3d(0, 0, 1));
        updateMinerMesh();

        Material minerMaterial = new Material(EffectId("textured.vert", "textured.frag", null), "blocks");
        Model minerDrawable = new Model(minerMaterial, _minerMesh);
        Node3d minerNode = new Node3d("miner", minerDrawable);
        _scene.addChild(minerNode);


        //minerNode.visible = false;
        //cubeNode.visible = false;

        //CellVisitor visitor = new TestVisitor();
        //Log.d("Testing cell visitor");
        //long ts = currentTimeMillis;
        //_world.visitVisibleCells(_world.camPosition, visitor);
        //long duration = currentTimeMillis - ts;
        //Log.d("DiamondVisitor finished in ", duration, " ms");
        //destroy(w);
    }

    float rotationX;
    float rotationY;
    float rotationZ;
    float translationX;
    float translationY;
    float translationZ;
    float near;
    float far;

    /// handle scroll event
    bool onScrollEvent(AbstractSlider source, ScrollEvent event) {
        controlsToVars();
        return true;
    }

    void assignHandlers() {
        childById!ScrollBar("sbNear").scrollEvent = &onScrollEvent;
        childById!ScrollBar("sbFar").scrollEvent = &onScrollEvent;
        childById!ScrollBar("sbRotationX").scrollEvent = &onScrollEvent;
        childById!ScrollBar("sbRotationY").scrollEvent = &onScrollEvent;
        childById!ScrollBar("sbRotationZ").scrollEvent = &onScrollEvent;
        childById!ScrollBar("sbTranslationX").scrollEvent = &onScrollEvent;
        childById!ScrollBar("sbTranslationY").scrollEvent = &onScrollEvent;
        childById!ScrollBar("sbTranslationZ").scrollEvent = &onScrollEvent;
    }

    void controlsToVars() {
        near = childById!ScrollBar("sbNear").position / 10.0f;
        far = childById!ScrollBar("sbFar").position / 10.0f;
        translationX = childById!ScrollBar("sbTranslationX").position / 10.0f;
        translationY = childById!ScrollBar("sbTranslationY").position / 10.0f;
        translationZ = childById!ScrollBar("sbTranslationZ").position / 10.0f;
        rotationX = childById!ScrollBar("sbRotationX").position;
        rotationY = childById!ScrollBar("sbRotationY").position;
        rotationZ = childById!ScrollBar("sbRotationZ").position;
        childById("lblNear").text = to!dstring(near);
        childById("lblFar").text = to!dstring(far);
        childById("lblTranslationX").text = to!dstring(translationX);
        childById("lblTranslationY").text = to!dstring(translationY);
        childById("lblTranslationZ").text = to!dstring(translationZ);
        childById("lblRotationX").text = to!dstring(rotationX);
        childById("lblRotationY").text = to!dstring(rotationY);
        childById("lblRotationZ").text = to!dstring(rotationZ);
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
        for (int i = 0; i < 20; i++)
            Log.d("vertex: ", _minerMesh.vertex(i));
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

    Scene3dRef _scene;
    Camera _cam;
    Mesh _minerMesh;


    /// this is OpenGLDrawableDelegate implementation
    private void doDraw(Rect windowRect, Rect rc) {
        _cam.setPerspective(rc.width, rc.height, 45.0f, near, far);
        _cam.setIdentity();
        //_cam.translate(vec3(
        //     childById!ScrollBar("sbTranslationX").position / 10.0f,
        //     childById!ScrollBar("sbTranslationY").position / 10.0f,
        //     childById!ScrollBar("sbTranslationZ").position / 10.0f));
        _cam.translateX(translationX);
        _cam.translateY(translationY);
        _cam.translateZ(translationZ);
        _cam.rotateX(rotationX);
        _cam.rotateY(rotationY);
        _cam.rotateZ(rotationZ);
        //_cam.translate(vec3(-1, -1.5, -1)); // - angle/1000
        //_cam.translate(vec3(0, 0, -1.1)); // - angle/1000
        //_cam.translate(vec3(0, 3,  - angle/1000)); //
        //_cam.rotateZ(30.0f + angle * 0.3456778);

        mat4 projectionViewMatrix = _cam.projectionViewMatrix;

        // ======== Model Matrix ==================
        mat4 modelMatrix;
        //modelMatrix.scale(0.1f);
        //modelMatrix.rotatez(30.0f + angle * 0.3456778);
        //modelMatrix.rotatey(25);
        //modelMatrix.rotatex(15);
        //modelMatrix.rotatey(angle);
        //modelMatrix.rotatex(angle * 1.98765f);

        mat4 projectionViewModelMatrix = projectionViewMatrix * modelMatrix;
        //Log.d("projectionViewModelMatrix: ", projectionViewModelMatrix.dump);

        //{
        //    mat4 projection;
        //    projection.setPerspective(45.0f, cast(float)rc.width / rc.height, near, far);
        //    mat4 view;
        //    view.translate(translationX, translationY, translationZ);
        //    Log.d("    .viewMatrix.trans       ", view.dump);
        //    view.rotateX(rotationX);
        //    Log.d("    .viewMatrix.rx          ", view.dump);
        //    view.rotateY(rotationY);
        //    Log.d("    .viewMatrix.ry          ", view.dump);
        //    view.rotateZ(rotationZ);
        //    Log.d("    .viewMatrix.rz          ", view.dump);
        //    mat4 projectionView = projection * view;
        //    Log.d("    .projectionMatrix:      ", projection.dump);
        //    Log.d("    .viewMatrix:            ", view.dump);
        //    Log.d("    .projectionViewMatrix:  ", projectionView.dump);
        //    Log.d("    .projectionViewMMatrix: ", (projectionView * modelMatrix).dump);
        //}

        //{
        //    import gl3n.linalg;
        //    static string dump(mat4 m) {
        //        m.transpose;
        //        return to!string(m[0]) ~ to!string(m[1]) ~ to!string(m[2]) ~ to!string(m[3]);
        //    }
        //    static float toRad(float angle) { return angle * 2 * PI / 360; }
        //    mat4 projection = mat4.perspective(rc.width, rc.height, 45.0f, near, far);
        //    mat4 view = mat4.identity.translate(translationX, translationY, translationZ).rotatex(toRad(rotationX)).rotatey(toRad(rotationY)).rotatez(toRad(rotationZ));
        //    Log.d("gl3n.viewMatrix: tr         ", dump(mat4.identity.translate(translationX, translationY, translationZ)));
        //    Log.d("gl3n.viewMatrix: rx         ", dump(mat4.identity.translate(translationX, translationY, translationZ).rotatex(toRad(rotationX))));
        //    Log.d("gl3n.viewMatrix: ry         ", dump(mat4.identity.translate(translationX, translationY, translationZ).rotatex(toRad(rotationX)).rotatey(toRad(rotationY))));
        //    Log.d("gl3n.viewMatrix: rz         ", dump(mat4.identity.translate(translationX, translationY, translationZ).rotatex(toRad(rotationX)).rotatey(toRad(rotationY)).rotatez(toRad(rotationZ))));
        //    mat4 projectionView = projection * view;
        //    Log.d("gl3n.projectionMatrix:      ", dump(projection));
        //    Log.d("gl3n.viewMatrix:            ", dump(view));
        //    Log.d("gl3n.projectionViewMatrix:  ", dump(projectionView));
        //    Log.d("gl3n.projectionViewMMatrix: ", dump(projectionView * mat4.identity));
        //}

        //projectionViewModelMatrix.setIdentity();
        //Log.d("matrix uniform: ", projectionViewModelMatrix.m);

        checkgl!glEnable(GL_CULL_FACE);
        //checkgl!glDisable(GL_CULL_FACE);
        checkgl!glEnable(GL_DEPTH_TEST);
        checkgl!glCullFace(GL_BACK);

        _scene.drawScene(false);

        checkgl!glDisable(GL_DEPTH_TEST);
        checkgl!glDisable(GL_CULL_FACE);
    }

    ~this() {
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

