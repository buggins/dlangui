module dlangui.graphics.scene.drawableobject;

public import dlangui.core.types;
public import dlangui.graphics.scene.node;

/// Reference counted DrawableObject
alias DrawableObjectRef = Ref!DrawableObject;

class DrawableObject : RefCountedObject {
    this() {
    }
    void draw(Node3d node, bool wireframe) {
        /// override it
    }
}
