module dlangui.graphics.scene.scene3d;

import dlangui.graphics.scene.node;
import dlangui.graphics.scene.camera;

import dlangui.core.math3d;

/// 3D scene
class Scene3d : Node3d {

    protected vec3 _ambientColor;
    protected Camera _activeCamera;

    /// ambient light color
    @property vec3 ambientColor() { return _ambientColor; }
    /// set ambient light color
    @property void ambientColor(const ref vec3 v) { _ambientColor = v; }


    /// active camera
    @property Camera activeCamera() {
        if (_activeCamera)
            return _activeCamera;
        // TODO: find camera in child nodes
        return null;
    }
    /// set or clear current active camera
    @property void activeCamera(Camera cam) {
        _activeCamera = cam;
    }

    /// returns scene for node
    override @property Scene3d scene() { 
        return this; 
    }

    override @property void scene(Scene3d v) { 
        //ignore
    }

}


