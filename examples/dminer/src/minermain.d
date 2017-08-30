module minermain;

import dlangui;
import dlangui.graphics.scene.scene3d;
import dlangui.graphics.scene.camera;
import dlangui.graphics.scene.mesh;
import dlangui.graphics.scene.material;
import dlangui.graphics.scene.effect;
import dlangui.graphics.scene.model;
import dlangui.graphics.scene.node;
import dlangui.graphics.scene.light;
import dlangui.graphics.scene.drawableobject;
import dlangui.graphics.scene.skybox;
import dlangui.graphics.scene.effect;
import dlangui.graphics.glsupport;
import dlangui.graphics.gldrawbuf;

//version = TEST_VISITOR_PERFORMANCE;

/*
version (Android) {
    //enum SUPPORT_LEGACY_OPENGL = false;
    public import EGL.eglplatform : EGLint;
    public import EGL.egl;
    //public import GLES2.gl2;
    public import GLES3.gl3;
} else {
    //enum SUPPORT_LEGACY_OPENGL = true;
    import derelict.opengl3.gl3;
    import derelict.opengl3.gl;
}
*/

import dminer.core.minetypes;
import dminer.core.blocks;
import dminer.core.world;
import dminer.core.generators;
import dminer.core.chunk;

mixin APP_ENTRY_POINT;

/// entry point for dlangui based application
extern (C) int UIAppMain(string[] args) {
    // embed resources listed in views/resources.list into executable
    embeddedResourceList.addResources(embedResourcesFromList!("resources.list")());
    //embeddedResourceList.dumpEmbeddedResources();

    debug {
        testPlanes();
    }

    // create window
    Window window = Platform.instance.createWindow("DlangUI Voxel RPG", null, WindowFlag.Resizable, 600, 500);
    window.mainWidget = new UiWidget();

    //MeshPart part = new MeshPart();

    // show window
    window.show();

    // run message loop
    return Platform.instance.enterMessageLoop();
}

class ChunkVisitCounter : ChunkVisitor {
    int count;
    bool visit(World world, SmallChunk * chunk) {
        count++;
        return true;
    }
}

class MinerDrawable : MaterialDrawableObject, ChunkVisitor {

    import dlangui.graphics.scene.node;
    private World _world;
    private ChunkDiamondVisitor _chunkVisitor;
    private VisibilityCheckIterator _chunkIterator;
    private Vector3d _pos;
    private Node3d _node;
    private Camera _cam;
    private vec3 _camPosition;
    private vec3 _camForwardVector;
    private bool _wireframe;

    @property bool wireframe() { return _wireframe; }
    @property void wireframe(bool flgWireframe) { _wireframe = flgWireframe; }

    this(World world, Material material, Camera cam) {
        super(material);
        _world = world;
        _cam = cam;
    }
    int _skippedCount;
    int _drawnCount;
    override void draw(Node3d node, bool wireframe) {
        /// override it
        _node = node;
        //Log.d("drawing Miner scene");
        //_chunkVisitor.init(_world, MAX_VIEW_DISTANCE, this);
        _pos = _world.camPosition.pos;
        _camPosition = _cam.translation;
        _camForwardVector = _cam.forwardVectorWorld;
        //_camPosition -= _camForwardVector * 8;
        _skippedCount = _drawnCount = 0;
        long ts = currentTimeMillis();
        //_chunkVisitor.visitChunks(_pos);
        Vector3d camVector;
        camVector.x = cast(int)(_camForwardVector.x * 256);
        camVector.y = cast(int)(_camForwardVector.y * 256);
        camVector.z = cast(int)(_camForwardVector.z * 256);
        version (TEST_VISITOR_PERFORMANCE) {
            ChunkVisitCounter countVisitor = new ChunkVisitCounter();
            _chunkIterator.start(_world, _world.camPosition.pos, MAX_VIEW_DISTANCE);
            _chunkIterator.visitVisibleChunks(countVisitor, camVector);
            long durationNoDraw = currentTimeMillis() - ts;
            _chunkIterator.start(_world, _world.camPosition.pos, MAX_VIEW_DISTANCE);
            _chunkIterator.visitVisibleChunks(this, camVector);
            long duration = currentTimeMillis() - ts;
            Log.d("drawing of Miner scene finished in ", duration, " ms  skipped:", _skippedCount, " drawn:", _drawnCount, " duration(noDraw)=", durationNoDraw);
        } else {
            _chunkIterator.start(_world, _world.camPosition.pos, MAX_VIEW_DISTANCE);
            _chunkIterator.visitVisibleChunks(this, camVector);
            long duration = currentTimeMillis() - ts;
            Log.d("drawing of Miner scene finished in ", duration, " ms  skipped:", _skippedCount, " drawn:", _drawnCount);
        }
    }
    bool visit(World world, SmallChunk * chunk) {
        if (chunk) {
            Vector3d p = chunk.position;
            vec3 chunkPos = vec3(p.x + 4, p.y + 4, p.z + 4);
            float camDist = (_camPosition - chunkPos).length;
            vec3 chunkDirection = (chunkPos - (_camPosition - (_camForwardVector * 12))).normalized;
            float dot = _camForwardVector.dot(chunkDirection);
            float threshold = 0.80;
            if (camDist < 16)
                threshold = 0.2;
            //Log.d("visit() chunkPos ", chunkPos, " chunkDir ", chunkDirection, " camDir ", " dot ", dot, " threshold ", threshold);

            if (dot < threshold) { // cos(45)
                _skippedCount++;
                return false;
            }
            Mesh mesh = chunk.getMesh(world);
            if (mesh) {
                _material.bind(_node, mesh, lights(_node));
                _material.drawMesh(mesh, _wireframe);
                _material.unbind();
                _drawnCount++;
            }
            return true;
        }
        return true;
    }
}

class UiWidget : VerticalLayout { //, CellVisitor
    this() {
        super("OpenGLView");
        layoutWidth = FILL_PARENT;
        layoutHeight = FILL_PARENT;
        alignment = Align.Center;
        try {
            parseML(q{
                {
                  margins: 0
                  padding: 0
                  //backgroundImageId: "tx_fabric.tiled"
                  backgroundColor: 0x000000;
                  layoutWidth: fill
                  layoutHeight: fill

                  VerticalLayout {
                    id: glView
                    margins: 0
                    padding: 0
                    layoutWidth: fill
                    layoutHeight: fill
                    TextWidget { text: "MinerD example"; textColor: "red"; fontSize: 150%; fontWeight: 800; fontFace: "Arial" }
                    VSpacer { layoutWeight: 30 }
                    TextWidget { id: lblPosition; text: ""; backgroundColor: 0x80202020; textColor: 0xFFE0E0 }
                  }
                }
            }, "", this);
        } catch (Exception e) {
            Log.e("Failed to parse dml", e);
        }
        // assign OpenGL drawable to child widget background
        childById("glView").backgroundDrawable = DrawableRef(new OpenGLDrawable(&doDraw));

        _scene = new Scene3d();

        _cam = new Camera();
        _cam.translate(vec3(0, 14, -7));

        _scene.activeCamera = _cam;

        static if (true) {
            _scene.skyBox.setFaceTexture(SkyBox.Face.Right, "skybox_night_right1");
            _scene.skyBox.setFaceTexture(SkyBox.Face.Left, "skybox_night_left2");
            _scene.skyBox.setFaceTexture(SkyBox.Face.Top, "skybox_night_top3");
            _scene.skyBox.setFaceTexture(SkyBox.Face.Bottom, "skybox_night_bottom4");
            _scene.skyBox.setFaceTexture(SkyBox.Face.Front, "skybox_night_front5");
            _scene.skyBox.setFaceTexture(SkyBox.Face.Back, "skybox_night_back6");
        } else {
            _scene.skyBox.setFaceTexture(SkyBox.Face.Right, "debug_right");
            _scene.skyBox.setFaceTexture(SkyBox.Face.Left, "debug_left");
            _scene.skyBox.setFaceTexture(SkyBox.Face.Top, "debug_top");
            _scene.skyBox.setFaceTexture(SkyBox.Face.Bottom, "debug_bottom");
            _scene.skyBox.setFaceTexture(SkyBox.Face.Front, "debug_front");
            _scene.skyBox.setFaceTexture(SkyBox.Face.Back, "debug_back");
        }

        dirLightNode = new Node3d();
        dirLightNode.rotateY(-15);
        dirLightNode.translateX(2);
        dirLightNode.translateY(3);
        dirLightNode.translateZ(0);
        dirLightNode.light = Light.createPoint(vec3(1.0, 1.0, 1.0), 55); //Light.createDirectional(vec3(1, 0.5, 0.5));
        //dirLightNode.light = Light.createDirectional(vec3(1, 0.5, 0.5));
        dirLightNode.light.enabled = true;
        _scene.addChild(dirLightNode);


        int x0 = 0;
        int y0 = 0;
        int z0 = 0;


        _minerMesh = new Mesh(VertexFormat(VertexElementType.POSITION, VertexElementType.NORMAL, VertexElementType.COLOR, VertexElementType.TEXCOORD0));
        _world = new World();

        initWorldTerrain(_world);

        int cy0 = 3;
        for (int y = CHUNK_DY - 1; y > 0; y--)
            if (!_world.canPass(Vector3d(0, y, 0))) {
                cy0 = y;
                break;
            }
        _world.camPosition = Position(Vector3d(0, cy0, 0), Vector3d(0, 0, 1));

        _world.setCell(5, cy0 + 5, 7, BlockId.face_test);
        _world.setCell(-5, cy0 + 5, 7, BlockId.face_test);
        _world.setCell(5, cy0 + 5, -7, BlockId.face_test);
        _world.setCell(3, cy0 + 5, 13, BlockId.face_test);


        //_world.makeCastleWall(Vector3d(25, cy0 - 5, 12), Vector3d(1, 0, 0), 12, 30, 4, BlockId.brick);
        _world.makeCastle(Vector3d(0, cy0, 60), 30, 12);

        updateCamPosition(false);
        //updateMinerMesh();

        Material minerMaterial = new Material(EffectId("textured.vert", "textured.frag", null), "blocks");
        //Material minerMaterial = new Material(EffectId("colored.vert", "colored.frag", null), "blocks");
        minerMaterial.ambientColor = vec3(0.25,0.25,0.25);
        minerMaterial.textureLinear = false;
        minerMaterial.fogParams = new FogParams(vec4(0.01, 0.01, 0.01, 1), 12, 80);
        //minerMaterial.specular = 10;
        _minerDrawable = new MinerDrawable(_world, minerMaterial, _cam);
        //_minerDrawable.autobindLights = false;
        //Model minerDrawable = new Model(minerMaterial, _minerMesh);
        Node3d minerNode = new Node3d("miner", _minerDrawable);
        //_minerDrawable.wireframe = true;
        _scene.addChild(minerNode);


        focusable = true;
    }

    MinerDrawable _minerDrawable;

    int lastMouseX;
    int lastMouseY;
    /// process key event, return true if event is processed.
    override bool onMouseEvent(MouseEvent event) {
        if (event.action == MouseAction.ButtonDown) {
            lastMouseX = event.x;
            lastMouseY = event.y;
            if (event.button == MouseButton.Left && false) {
                int x = event.x;
                int y = event.y;
                int xindex = 0;
                if (x > width * 2 / 3)
                    xindex = 2;
                else if (x > width * 1 / 3)
                    xindex = 1;
                int yindex = 0;
                if (y > height * 2 / 3)
                    yindex = 2;
                else if (y > height * 1 / 3)
                    yindex = 1;
                int index = yindex * 3 + xindex;
                /*
                   index:
                     0  1  2
                     3  4  5
                     6  7  8
                */
                switch(index) {
                    default:
                    case 1:
                    case 4:
                        //_world.camPosition.forward(1);
                        //updateCamPosition();
                        startMoveAnimation(_world.camPosition.direction.forward);
                        break;
                    case 0:
                    case 3:
                        _world.camPosition.turnLeft();
                        updateCamPosition();
                        break;
                    case 2:
                    case 5:
                        _world.camPosition.turnRight();
                        updateCamPosition();
                        break;
                    case 7:
                        //_world.camPosition.backward(1);
                        //updateCamPosition();
                        startMoveAnimation(-_world.camPosition.direction.forward);
                        break;
                    case 6:
                        //_world.camPosition.moveLeft();
                        //updateCamPosition();
                        startMoveAnimation(_world.camPosition.direction.left);
                        break;
                    case 8:
                        //_world.camPosition.moveRight();
                        //updateCamPosition();
                        startMoveAnimation(_world.camPosition.direction.right);
                        break;
                }
            }
        } else if (event.action == MouseAction.Move) {
            if (event.lbutton.isDown) {
                int deltaX = event.x - lastMouseX;
                int deltaY = event.y - lastMouseY;
                int maxshift = width > 100 ? width : 100;
                float deltaAngleX = deltaX * 45.0f / maxshift;
                float deltaAngleY = deltaY * 45.0f / maxshift;
                lastMouseX = event.x;
                lastMouseY = event.y;
                float newAngle = _angle + deltaAngleX;
                if (newAngle < -180)
                    newAngle += 360;
                else if (newAngle > 180)
                    newAngle -= 360;
                setAngle(newAngle, true);
                float newAngleY = _yAngle + deltaAngleY;
                if (newAngleY < -65)
                    newAngleY = -65;
                else if (newAngleY > 65)
                    newAngleY = 65;
                setYAngle(newAngleY, true);
            }
        } else if (event.action == MouseAction.ButtonUp || event.action == MouseAction.Cancel) {
            stopMoveAnimation();
        }
        return true;
    }

    /// process key event, return true if event is processed.
    override bool onKeyEvent(KeyEvent event) {
        if (event.action == KeyAction.KeyDown) {
            switch(event.keyCode) with(KeyCode) {
                case F1:
                    _minerDrawable.wireframe = !_minerDrawable.wireframe;
                    return true;
                case KEY_W:
                case UP:
                    _world.camPosition.forward(1);
                    updateCamPosition();
                    return true;
                case DOWN:
                case KEY_S:
                    _world.camPosition.backward(1);
                    updateCamPosition();
                    return true;
                case KEY_A:
                case LEFT:
                    _world.camPosition.turnLeft();
                    updateCamPosition();
                    return true;
                case KEY_D:
                case RIGHT:
                    _world.camPosition.turnRight();
                    updateCamPosition();
                    return true;
                case HOME:
                case KEY_E:
                    _world.camPosition.moveUp();
                    updateCamPosition();
                    return true;
                case END:
                case KEY_Q:
                    _world.camPosition.moveDown();
                    updateCamPosition();
                    return true;
                case KEY_Z:
                    _world.camPosition.moveLeft();
                    updateCamPosition();
                    return true;
                case KEY_C:
                    _world.camPosition.moveRight();
                    updateCamPosition();
                    return true;
                case KEY_F:
                    flying = !flying;
                    if (!flying)
                        _world.camPosition.pos.y = CHUNK_DY - 3;
                    updateCamPosition();
                    return true;
                case KEY_U:
                    enableMeshUpdate = !enableMeshUpdate;
                    updateCamPosition();
                    return true;
                default:
                    return false;
            }
        }
        return false;
    }

    Node3d dirLightNode;

    //void visit(World world, ref Position camPosition, Vector3d pos, cell_t cell, int visibleFaces) {
    //    BlockDef def = BLOCK_DEFS[cell];
    //    def.createFaces(world, world.camPosition, pos, visibleFaces, _minerMesh);
    //}

    bool flying = false;
    bool enableMeshUpdate = true;
    Vector3d _moveAnimationDirection;

    void animateMoving() {
        if (_moveAnimationDirection != Vector3d(0,0,0)) {
            Vector3d animPos = _world.camPosition.pos + _moveAnimationDirection;
            vec3 p = vec3(animPos.x + 0.5f, animPos.y + 0.5f, animPos.z + 0.5f);
            if ((_animatingPosition - p).length < 2) {
                _world.camPosition.pos += _moveAnimationDirection;
                updateCamPosition(true);
            }
        }
    }

    void updateCamPosition(bool animateIt = true) {
        import std.string;
        import std.conv : to;
        import std.utf : toUTF32;
        import std.format;

        if (!flying) {
            animateMoving();
            while(_world.canPass(_world.camPosition.pos + Vector3d(0, -1, 0)))
                _world.camPosition.pos += Vector3d(0, -1, 0);
            if(!_world.canPass(_world.camPosition.pos + Vector3d(0, -1, 0))) {
                if (_world.canPass(_world.camPosition.pos + Vector3d(0, 1, 0)))
                    _world.camPosition.pos += Vector3d(0, 1, 0);
                else if (_world.canPass(_world.camPosition.pos + Vector3d(1, 0, 0)))
                    _world.camPosition.pos += Vector3d(1, 0, 0);
                else if (_world.canPass(_world.camPosition.pos + Vector3d(-1, 0, 0)))
                    _world.camPosition.pos += Vector3d(-1, 0, 0);
                else if (_world.canPass(_world.camPosition.pos + Vector3d(0, 0, 1)))
                    _world.camPosition.pos += Vector3d(0, 0, 1);
                else if (_world.canPass(_world.camPosition.pos + Vector3d(0, 0, -1)))
                    _world.camPosition.pos += Vector3d(0, 0, -1);
                while(_world.canPass(_world.camPosition.pos + Vector3d(0, -1, 0)))
                    _world.camPosition.pos += Vector3d(0, -1, 0);
            }
        }

        setPos(vec3(_world.camPosition.pos.x + 0.5f, _world.camPosition.pos.y + 0.5f, _world.camPosition.pos.z + 0.5f), animateIt);
        setAngle(_world.camPosition.direction.angle, animateIt);

        updatePositionMessage();
    }

    void updatePositionMessage() {
        import std.string : format;
        Widget w = childById("lblPosition");
        string dir = _world.camPosition.direction.dir.to!string;
        dstring s = format("pos(%d,%d) h=%d fps:%d %s    [F]lying: %s   [U]pdateMesh: %s  [F1] wireframe: %s", _world.camPosition.pos.x, _world.camPosition.pos.z, _world.camPosition.pos.y,
                           _fps,
                           dir,
                           flying,
                           enableMeshUpdate,
                           _minerDrawable ? _minerDrawable.wireframe : false
                           ).toUTF32;
        w.text = s;
    }

    int _fps = 0;

    void startMoveAnimation(Vector3d direction) {
        _moveAnimationDirection = direction;
        updateCamPosition();
    }

    void stopMoveAnimation() {
        _moveAnimationDirection = Vector3d(0, 0, 0);
        updateCamPosition();
    }

    //void updateMinerMesh() {
    //    _minerMesh.reset();
    //    long ts = currentTimeMillis;
    //    _world.visitVisibleCells(_world.camPosition, this);
    //    long duration = currentTimeMillis - ts;
    //    Log.d("DiamondVisitor finished in ", duration, " ms  ", "Vertex count: ", _minerMesh.vertexCount);
    //
    //    invalidate();
    //    //for (int i = 0; i < 20; i++)
    //    //    Log.d("vertex: ", _minerMesh.vertex(i));
    //}

    World _world;
    vec3 _position;
    float _directionAngle = 0;
    float _yAngle = -15;
    float _angle;
    vec3 _animatingPosition;
    float _animatingAngle;
    float _animatingYAngle;

    void setPos(vec3 newPos, bool animateIt = false) {
        if (animateIt) {
            _position = newPos;
        } else {
            _animatingPosition = newPos;
            _position = newPos;
        }
    }

    void setAngle(float newAngle, bool animateIt = false) {
        if (animateIt) {
            _angle = newAngle;
        } else {
            _animatingAngle = newAngle;
            _angle = newAngle;
        }
    }

    void setYAngle(float newAngle, bool animateIt = false) {
        if (animateIt) {
            _yAngle = newAngle;
        } else {
            _animatingYAngle = newAngle;
            _yAngle = newAngle;
        }
    }

    /// returns true is widget is being animated - need to call animate() and redraw
    @property override bool animating() { return true; }
    /// animates window; interval is time left from previous draw, in hnsecs (1/10000000 of second)
    override void animate(long interval) {
        //Log.d("animating");
        if (interval > 0) {
            int newfps = cast(int)(10000000.0 / interval);
            if (newfps < _fps - 3 || newfps > _fps + 3) {
                _fps = newfps;
                updatePositionMessage();
            }
        }
        animateMoving();
        if (_animatingAngle != _angle) {
            float delta = _angle - _animatingAngle;
            if (delta > 180)
                delta -= 360;
            else if (delta < -180)
                delta += 360;
            float dist = delta < 0 ? -delta : delta;
            if (dist < 5) {
                _animatingAngle = _angle;
            } else {
                float speed = 360 / 2;
                float step = speed * interval / 10000000.0f;
                //Log.d("Rotate animation delta=", delta, " dist=", dist, " elapsed=", interval, " step=", step);
                if (step > dist)
                    step = dist;
                delta = delta * (step /dist);
                _animatingAngle += delta;
            }
        }
        if (_animatingYAngle != _yAngle) {
            float delta = _yAngle - _animatingYAngle;
            if (delta > 180)
                delta -= 360;
            else if (delta < -180)
                delta += 360;
            float dist = delta < 0 ? -delta : delta;
            if (dist < 5) {
                _animatingYAngle = _yAngle;
            } else {
                float speed = 360 / 2;
                float step = speed * interval / 10000000.0f;
                //Log.d("Rotate animation delta=", delta, " dist=", dist, " elapsed=", interval, " step=", step);
                if (step > dist)
                    step = dist;
                delta = delta * (step /dist);
                _animatingYAngle += delta;
            }
        }
        if (_animatingPosition != _position) {
            vec3 delta = _position - _animatingPosition;
            float dist = delta.length;
            if (dist < 0.01) {
                _animatingPosition = _position;
                // done
            } else {
                float speed = 8;
                if (dist > 2)
                    speed = (dist - 2) * 3 + speed;
                float step = speed * interval / 10000000.0f;
                //Log.d("Move animation delta=", delta, " dist=", dist, " elapsed=", interval, " step=", step);
                if (step > dist)
                    step = dist;
                delta = delta * (step / dist);
                _animatingPosition += delta;
            }
        }
        invalidate();
    }
    float angle = 0;

    Scene3d _scene;
    Camera _cam;
    Mesh _minerMesh;


    /// this is OpenGLDrawableDelegate implementation
    private void doDraw(Rect windowRect, Rect rc) {
        _cam.setPerspective(rc.width, rc.height, 45.0f, 0.3, MAX_VIEW_DISTANCE);
        _cam.setIdentity();
        _cam.translate(_animatingPosition);
        _cam.rotateY(_animatingAngle);
        _cam.rotateX(_yAngle);


        dirLightNode.setIdentity();
        dirLightNode.translate(_animatingPosition);
        dirLightNode.rotateY(_animatingAngle);

        checkgl!glEnable(GL_CULL_FACE);
        //checkgl!glDisable(GL_CULL_FACE);
        checkgl!glEnable(GL_DEPTH_TEST);
        checkgl!glCullFace(GL_BACK);

        Log.d("Drawing position ", _animatingPosition, " angle ", _animatingAngle);

        _scene.drawScene(false);

        checkgl!glDisable(GL_DEPTH_TEST);
        checkgl!glDisable(GL_CULL_FACE);
    }

    ~this() {
        destroy(_scene);
        destroy(_world);
    }
}
