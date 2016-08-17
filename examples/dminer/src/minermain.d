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
import dlangui.graphics.glsupport;
import dlangui.graphics.gldrawbuf;
import dlangui.graphics.scene.effect;

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

    // create window
    Window window = Platform.instance.createWindow("DlangUI Voxel RPG", null, WindowFlag.Resizable, 600, 500);
    window.mainWidget = new UiWidget();

    //MeshPart part = new MeshPart();

    // show window
    window.show();

    // run message loop
    return Platform.instance.enterMessageLoop();
}

class MinerDrawable : MaterialDrawableObject, ChunkVisitor {

    import dlangui.graphics.scene.node;
    World _world;
    ChunkDiamondVisitor _chunkVisitor;
    Vector3d _pos;
    private Node3d _node;

    this(World world, Material material) {
        super(material);
        _world = world;
    }
    override void draw(Node3d node, bool wireframe) {
        /// override it
        _node = node;
        //Log.d("drawing Miner scene");
        _chunkVisitor.init(_world, 128, this);
        _pos = _world.camPosition.pos;
        long ts = currentTimeMillis();
        _chunkVisitor.visitChunks(_pos);
        long duration = currentTimeMillis() - ts;
        Log.d("drawing of Miner scene finished in ", duration, " ms");
    }
    void visit(World world, SmallChunk * chunk) {
        if (chunk) {
            Mesh mesh = chunk.getMesh(world);
            if (mesh) {
                _material.bind(_node, mesh, lights(_node));
                _material.drawMesh(mesh);
                _material.unbind();
            }
        }
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

        dirLightNode = new Node3d();
        dirLightNode.rotateY(-15);
        dirLightNode.translateX(2);
        dirLightNode.translateY(3);
        dirLightNode.translateZ(0);
        dirLightNode.light = Light.createPoint(vec3(1.0, 1.0, 1.0), 35); //Light.createDirectional(vec3(1, 0.5, 0.5));
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

        //_world.setCellRange(Vector3d(3, 11, 5), Vector3d(1, 100, 1), 1);
        //_world.setCellRange(Vector3d(13, 11, -5), Vector3d(1, 100, 1), 3);
        //_world.setCellRange(Vector3d(-6, 11, 10), Vector3d(1, 100, 1), 4);
        //_world.setCellRange(Vector3d(-8, 11, 15), Vector3d(1, 100, 1), 5);
        //_world.setCellRange(Vector3d(12, 11, -7), Vector3d(1, 100, 1), 6);
        //_world.setCellRange(Vector3d(5, 11, 9), Vector3d(1, 100, 1), 7);
        //_world.setCellRange(Vector3d(9, 11, 5), Vector3d(1, 100, 1), 7);
        //_world.setCellRange(Vector3d(-5, 11, 9), Vector3d(1, 100, 1), 7);
        //_world.setCellRange(Vector3d(9, 11, -5), Vector3d(1, 100, 1), 7);
        //_world.setCellRange(Vector3d(5, 11, -9), Vector3d(1, 100, 1), 7);
        //_world.setCellRange(Vector3d(-9, 11, 5), Vector3d(1, 100, 1), 7);
        //_world.setCellRange(Vector3d(7, 11, 3), Vector3d(1, 100, 1), 8);
        //_world.setCellRange(Vector3d(-7, 11, 3), Vector3d(1, 100, 1), 8);
        //_world.setCellRange(Vector3d(7, 11, -3), Vector3d(1, 100, 1), 8);
        //_world.setCellRange(Vector3d(-7, 11, 3), Vector3d(1, 100, 1), 8);

        updateCamPosition(false);
        //updateMinerMesh();

        Material minerMaterial = new Material(EffectId("textured.vert", "textured.frag", null), "blocks");
        minerMaterial.ambientColor = vec3(0.1,0.1,0.1);
        minerMaterial.textureLinear = false;
        //minerMaterial.specular = 10;
        _minerDrawable = new MinerDrawable(_world, minerMaterial);
        //Model minerDrawable = new Model(minerMaterial, _minerMesh);
        Node3d minerNode = new Node3d("miner", _minerDrawable);
        _scene.addChild(minerNode);


        focusable = true;
    }

    MinerDrawable _minerDrawable;

    /// process key event, return true if event is processed.
    override bool onMouseEvent(MouseEvent event) {
        if (event.action == MouseAction.ButtonDown) {
            if (event.button == MouseButton.Left) {
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
        } else if (event.action == MouseAction.ButtonUp || event.action == MouseAction.Cancel) {
            stopMoveAnimation();
        }
        return true;
    }

    /// process key event, return true if event is processed.
    override bool onKeyEvent(KeyEvent event) {
        if (event.action == KeyAction.KeyDown) {
            switch(event.keyCode) with(KeyCode) {
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
        Widget w = childById("lblPosition");
        string dir = _world.camPosition.direction.dir.to!string;
        dstring s = format("pos(%d,%d) h=%d  %s    [F]lying: %s   [U]pdateMesh: %s", _world.camPosition.pos.x, _world.camPosition.pos.z, _world.camPosition.pos.y, dir,
                           flying, enableMeshUpdate).toUTF32;
        w.text = s;
        //if (enableMeshUpdate)
        //    updateMinerMesh();
    }

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
    float _angle;
    vec3 _animatingPosition;
    float _animatingAngle;

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

    /// returns true is widget is being animated - need to call animate() and redraw
    @property override bool animating() { return true; }
    /// animates window; interval is time left from previous draw, in hnsecs (1/10000000 of second)
    override void animate(long interval) {
        //Log.d("animating");
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
                float speed = 360;
                float step = speed * interval / 10000000.0f;
                //Log.d("Rotate animation delta=", delta, " dist=", dist, " elapsed=", interval, " step=", step);
                if (step > dist)
                    step = dist;
                delta = delta * (step /dist);
                _animatingAngle += delta;
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
