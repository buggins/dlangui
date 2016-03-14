module dlangui.graphics.scene.camera;

import dlangui.graphics.scene.node;

import dlangui.core.math3d;

/// Camera
class Camera : Node3d {

    protected mat4 _projectionMatrix;
    protected mat4 _viewProjectionMatrix;
    protected bool _dirtyViewProjection;

    protected bool _enabled;

    this() {
        _enabled = true;
        setPerspective(4.0f, 3.0f, 45.0f, 0.1f, 100.0f);
    }

    /// returns true if camera is active (enabled)
    @property bool enabled() { return _enabled; }

    /// activates / deactivates camera
    @property void enabled(bool v) { 
        if (scene)
            scene.activeCamera = null;
        _enabled = v; 
    }

    /// get projection matrix
    @property ref const(mat4) projectionMatrix() {
        return _projectionMatrix;
    }

    /// set custom projection matrix
    @property void projectionMatrix(mat4 v) {
        _projectionMatrix = v;
        _dirtyViewProjection = true;
    }

    /// get projection*view matrix
    @property ref const(mat4) projectionViewMatrix() {
        if (_dirtyTransform || _dirtyViewProjection) {
            _viewProjectionMatrix = _projectionMatrix * matrix;
            _dirtyViewProjection = false;
        }
        return _viewProjectionMatrix;
    }

    /// set orthographic projection
    void setOrtho(float left, float right, float bottom, float top, float near, float far) {
        _projectionMatrix.setOrtho(left, right, bottom, top, near, far);
        _dirtyViewProjection = true;
    }

    /// set perspective projection
    void setPerspective(float width, float height, float fov, float near, float far) {
        _projectionMatrix.setPerspective(fov, width / height, near, far);
        _dirtyViewProjection = true;
    }

    ~this() {
        // disconnect active camera
        if (scene && scene.activeCamera is this)
            scene.activeCamera = null;
    }
}
