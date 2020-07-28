module d3d;

import dlangui;
import dlangui.graphics.scene.scene3d;
import dlangui.graphics.scene.camera;
import dlangui.graphics.scene.mesh;
import dlangui.graphics.scene.material;
import dlangui.graphics.scene.effect;
import dlangui.graphics.scene.model;
import dlangui.graphics.scene.node;
import dlangui.graphics.scene.light;
import dlangui.graphics.scene.objimport;
import dlangui.graphics.scene.fbximport;
import dlangui.graphics.glsupport;
import dlangui.graphics.gldrawbuf;
import derelict.opengl.gl;

mixin APP_ENTRY_POINT;

/// entry point for dlangui based application
extern (C) int UIAppMain(string[] args) {
    // embed resources listed in views/resources.list into executable
    embeddedResourceList.addResources(embedResourcesFromList!("resources.list")());

    // create window
    Window window = Platform.instance.createWindow("DlangUI example - 3D Application", null, WindowFlag.Resizable, 600, 500);
    static if (ENABLE_OPENGL) {
        window.mainWidget = new UiWidget();
    } else {
        window.mainWidget = new TextWidget("error", "Please build with OpenGL enabled"d);
    }

    //MeshPart part = new MeshPart();

    // show window
    window.show();

    // run message loop
    return Platform.instance.enterMessageLoop();
}

static if (ENABLE_OPENGL):

class UiWidget : VerticalLayout {
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

        dirLightNode = new Node3d();
        //dirLightNode.lookAt(vec3(-5, -5, -5), vec3(0, 0, 0), vec3(0, 1, 0));
        dirLightNode.rotateY(-15);
        //dirLightNode.rotateX(20);
        dirLightNode.translateX(2);
        dirLightNode.translateY(3);
        dirLightNode.translateZ(0);
        dirLightNode.light = Light.createPoint(vec3(2, 2, 2), 15); //Light.createDirectional(vec3(1, 0.5, 0.5));
        //dirLightNode.light = Light.createDirectional(vec3(1, 0.5, 0.8));
        dirLightNode.light.enabled = true;
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

        debug(fbximport) {
            // test FBX import
            FbxModelImport importer;
            string src = loadTextResource("suzanne.fbx");
            importer.filename = "suzanne.fbx";
            importer.parse(src);
        }

        ObjModelImport importer;
        string src = loadTextResource("suzanne.obj");
        importer.parse(src);
        Log.d("suzanne mesh:", importer.mesh.dumpVertexes(20));
        Material suzanneMaterial = new Material(EffectId("colored.vert", "colored.frag", null), null); //"SPECULAR"
        //suzanneMaterial.ambientColor = vec3(0.5, 0.5, 0.5);
        suzanneMaterial.diffuseColor = vec4(0.7, 0.7, 0.5, 1.0);
        //suzanneMaterial.specular = true;
        Model suzanneDrawable = new Model(suzanneMaterial, importer.mesh);
        suzanneNode = new Node3d("suzanne", suzanneDrawable);
        suzanneNode.translate(vec3(2, 2, -5));
        _scene.addChild(suzanneNode);


        brickNode = new Node3d("brick");
        brickNode.translate(vec3(-2, 2, -3));
        Mesh brickMesh = Mesh.createCubeMesh(vec3(0, 0, 0), 0.8, vec4(0.8, 0.8, 0.8, 1));
        Material brickMaterial = new Material(EffectId("textured.vert", "textured.frag", null), "brick", "brickn"); // with bump mapping
        //brickMaterial.specular = true;
        brickNode.drawable = new Model(brickMaterial, brickMesh);
        _scene.addChild(brickNode);

    }

    Node3d dirLightNode;
    Node3d suzanneNode;
    Node3d brickNode;

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

    /// returns true is widget is being animated - need to call animate() and redraw
    @property override bool animating() { return true; }
    /// animates window; interval is time left from previous draw, in hnsecs (1/10000000 of second)
    override void animate(long interval) {
        //Log.d("animating");
        _cam.rotateX(0.01);
        _cam.rotateY(0.02);
        angle += interval * 0.000002f;
        invalidate();
        suzanneNode.rotateY(interval * 0.000002f);
        brickNode.rotateY(interval * 0.00000123f);
        brickNode.rotateZ(interval * 0.0000004123f);
        brickNode.rotateX(interval * 0.0000007543f);
    }
    float angle = 0;

    Scene3dRef _scene;
    Camera _cam;

    /// this is OpenGLDrawableDelegate implementation
    private void doDraw(Rect windowRect, Rect rc) {
        _cam.setPerspective(rc.width, rc.height, 45.0f, near, far);
        _cam.setIdentity();
        _cam.translateX(translationX);
        _cam.translateY(translationY);
        _cam.translateZ(translationZ);
        _cam.rotateX(rotationX);
        _cam.rotateY(rotationY);
        _cam.rotateZ(rotationZ);

        checkgl!glEnable(GL_CULL_FACE);
        //checkgl!glDisable(GL_CULL_FACE);
        checkgl!glEnable(GL_DEPTH_TEST);
        checkgl!glCullFace(GL_BACK);

        _scene.drawScene(false);

        checkgl!glDisable(GL_DEPTH_TEST);
        checkgl!glDisable(GL_CULL_FACE);
    }

    ~this() {
    }
}
