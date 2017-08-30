module dlangui.graphics.scene.camera;

public import dlangui.core.config;
static if (ENABLE_OPENGL):
static if (BACKEND_GUI):

import dlangui.graphics.scene.node;

import dlangui.core.math3d;

/// Camera
class Camera : Node3d {

    protected mat4 _projectionMatrix;
    protected mat4 _viewMatrix;
    protected mat4 _viewProjectionMatrix;
    protected bool _dirtyViewProjection = true;
    protected bool _dirtyView = true;

    protected bool _enabled;

    protected float _far = 100;

    this(string ID = null) {
        super(ID);
        _enabled = true;
        setPerspective(4.0f, 3.0f, 45.0f, 0.1f, 100.0f);
    }

    /// returns FAR range of camera
    @property float farRange() { return _far; }

    /// returns true if camera is active (enabled)
    @property bool enabled() { return _enabled; }

    /// activates / deactivates camera
    @property void enabled(bool v) {
        if (scene)
            scene.activeCamera = null;
        _enabled = v;
    }

    /// returns true if some changes occured in projection or view matrix since last matrix getter call
    @property bool viewChanged() {
        return _dirtyTransform || _dirtyViewProjection || _dirtyView;
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

    override protected void invalidateTransform() {
        _dirtyTransform = true;
        _dirtyViewProjection = true;
        _dirtyView = true;
    }

    override @property ref const(mat4) viewMatrix() {
        if (_dirtyView) {
            _viewMatrix = matrix.invert();
            _dirtyView = false;
        }
        return _viewMatrix;
    }

    /// get projection*view matrix
    override @property ref const(mat4) projectionViewMatrix() {
        if (_dirtyTransform || _dirtyViewProjection) {
            _viewProjectionMatrix = _projectionMatrix * viewMatrix;
            _dirtyViewProjection = false;
        }
        return _viewProjectionMatrix;
    }

    /// set orthographic projection
    void setOrtho(float left, float right, float bottom, float top, float near, float far) {
        _far = far;
        _projectionMatrix.setOrtho(left, right, bottom, top, near, far);
        _dirtyViewProjection = true;
    }

    /// set perspective projection
    void setPerspective(float width, float height, float fov, float near, float far) {
        _far = far;
        _projectionMatrix.setPerspective(fov, width / height, near, far);
        _dirtyViewProjection = true;
    }

    ~this() {
        // disconnect active camera
        if (scene && scene.activeCamera is this)
            scene.activeCamera = null;
    }
}
