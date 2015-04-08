module dlangui.graphics.scene.camera;

import dlangui.graphics.scene.node;

import gl3n.linalg;
import gl3n.math;

/// Camera
class Camera : Node3d {

    protected mat4 _projectionMatrix;

    /// get projection matrix
    @property ref mat4 projectionMatrix() {
        return _projectionMatrix;
    }

    /// set custom projection matrix
    @property void projectionMatrix(mat4 v) {
        _projectionMatrix = v;
    }

    /// set orthographic projection
    void setOrtho(float left, float right, float bottom, float top, float near, float far) {
        _projectionMatrix = mat4.orthographic(left, right, bottom, top, near, far);
    }

    /// set perspective projection
    void setPerspective(float width, float height, float fov, float near, float far) {
        _projectionMatrix = mat4.perspective(width, height, fov, near, far);
    }

}
