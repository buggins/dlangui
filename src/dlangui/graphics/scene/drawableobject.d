module dlangui.graphics.scene.drawableobject;

import dlangui.core.config;
static if (ENABLE_OPENGL):

import dlangui.core.types;

/// Reference counted DrawableObject
alias DrawableObjectRef = Ref!DrawableObject;

class DrawableObject : RefCountedObject {

    import dlangui.graphics.scene.node;

    this() {
    }
    void draw(Node3d node, bool wireframe) {
        /// override it
    }
}
