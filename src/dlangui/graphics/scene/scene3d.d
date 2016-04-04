module dlangui.graphics.scene.scene3d;

import dlangui.core.types;
import dlangui.graphics.scene.node;
import dlangui.graphics.scene.camera;

public import dlangui.core.math3d;

/// Reference counted Scene3d object
alias Scene3dRef = Ref!Scene3d;

/// 3D scene
class Scene3d : Node3d {

    protected vec3 _ambientColor;
    protected Camera _activeCamera;

    /// ambient light color
    @property vec3 ambientColor() { return _ambientColor; }
    /// set ambient light color
    @property void ambientColor(const ref vec3 v) { _ambientColor = v; }


    /// active camera
    override @property Camera activeCamera() {
        if (_activeCamera)
            return _activeCamera;
        // TODO: find camera in child nodes
        return null;
    }
    /// set or clear current active camera
    @property void activeCamera(Camera cam) {
        _activeCamera = cam;
        if (cam && cam.parent != this)
            addChild(cam);
    }

    /// returns scene for node
    override @property Scene3d scene() { 
        return this; 
    }

    override @property void scene(Scene3d v) { 
        //ignore
    }

    protected bool _wireframe;
    void drawScene(bool wireframe) {
        _wireframe = wireframe;
        visit(this, &sceneDrawVisitor);
    }

    protected bool sceneDrawVisitor(Node3d node) {
        if (!node.drawable.isNull)
            node.drawable.draw(node, _wireframe);
        return false;
    }
}

/// depth-first recursive node traversion, stops if visitor returns true
bool visit(Node3d node, bool delegate(Node3d node) visitor) {
    if (!node.visible)
        return false;
    bool res = visitor(node);
    if (res)
        return true;
    foreach(child; node.children) {
        bool res = visit(child, visitor);
        if (res)
            return true;
    }
    return false;
}
