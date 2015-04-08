module dlangui.graphics.scene.scene3d;

import dlangui.graphics.scene.node;

import gl3n.linalg;
import gl3n.math;

/// 3D scene
class Scene3d : Node3d {

    protected vec3 _ambientColor;
    @property vec3 ambientColor() { return _ambientColor; }
    @property void ambientColor(const ref vec3 v) { _ambientColor = v; }

}

