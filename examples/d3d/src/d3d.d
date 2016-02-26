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
    // create window
    Window window = Platform.instance.createWindow("DlangUI example - 3D Application", null, WindowFlag.Resizable, 600, 500);
    window.mainWidget = new UiWidget();

    auto canvas = window.mainWidget.childById!CanvasWidget("canvas");
    canvas.onDrawListener = delegate(CanvasWidget canvas, DrawBuf buf, Rect rc) {
            Log.w("canvas.onDrawListener clipRect=" ~ to!string(buf.clipRect));
            buf.fill(0xFFFFFF);
            int x = rc.left;
            int y = rc.top;
            buf.fillRect(Rect(x+20, y+20, x+150, y+200), 0x80FF80);
            buf.fillRect(Rect(x+90, y+80, x+250, y+250), 0x80FF80FF);
            canvas.font.drawText(buf, x + 40, y + 50, "fillRect()"d, 0xC080C0);
            buf.drawFrame(Rect(x + 400, y + 30, x + 550, y + 150), 0x204060, Rect(2,3,4,5), 0x80704020);
            canvas.font.drawText(buf, x + 400, y + 5, "drawFrame()"d, 0x208020);
            canvas.font.drawText(buf, x + 300, y + 100, "drawPixel()"d, 0x000080);
            for (int i = 0; i < 80; i++)
                buf.drawPixel(x+300 + i * 4, y+140 + i * 3 % 100, 0xFF0000 + i * 2);
            canvas.font.drawText(buf, x + 200, y + 150, "drawLine()"d, 0x800020);
            for (int i = 0; i < 40; i+=3)
                buf.drawLine(Point(x+200 + i * 4, y+190), Point(x+150 + i * 7, y+320 + i * 2), 0x008000 + i * 5);
        };


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
                id: glView
                margins: 10
                padding: 10
                backgroundColor: "#C0E0E070" // semitransparent yellow background
                TextWidget { text: "Hello World example for DlangUI"; textColor: "red"; fontSize: 150%; fontWeight: 800; fontFace: "Arial" }
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
                HorizontalLayout {
                    Button { id: btnOk; text: "Ok"; fontSize: 27px }
                    Button { id: btnCancel; text: "Cancel"; fontSize: 27px }
                }
                CanvasWidget {
                id: canvas
                        minWidth: 500
                        minHeight: 300
                }
            }
        }, "", this);
        // assign OpenGL drawable to child widget background
        childById("glView").backgroundDrawable = DrawableRef(new OpenGLDrawable(&doDraw));


        _scene = new Scene3d();
        _cam = new Camera();
        _cam.translation = vec3(0, 0, -5);
        _scene.activeCamera = _cam;
        mat4 camMatrix = _scene.viewProjectionMatrix;
        VertexFormat vfmt = VertexFormat(VertexElementType.POSITION, VertexElementType.COLOR, VertexElementType.TEXCOORD0);
        _mesh = new Mesh(vfmt);
        _mesh.addVertex([1,2,3,  1,1,1,1, 0,0]);
        _mesh.addVertex([-1,2,3, 1,1,1,1, 1,0]);
        _mesh.addVertex([-1,-2,3, 1,1,1,1, 1,1]);
        _mesh.addVertex([1,-2,3, 1,1,1,1, 0,1]);
        _mesh.addPart(PrimitiveType.triangles, [0, 1, 2, 2, 3, 0]);

    }

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
        mat4 camMatrix = _scene.viewProjectionMatrix;
        _program.bind();
        _program.setUniform("matrix", camMatrix);
        _tx.texture.setup();
        _tx.texture.setSamplerParams(true);

        _program.draw(_mesh);

        _tx.texture.unbind();
        _program.unbind();
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

