module dlangui.graphics.scene.node;

public import dlangui.core.config;
static if (ENABLE_OPENGL):

import dlangui.core.math3d;

import dlangui.graphics.scene.transform;

/// 3D scene node
class Node3d : Transform {
    import dlangui.core.collections;
    import dlangui.graphics.scene.scene3d;
    import dlangui.graphics.scene.drawableobject;
    import dlangui.graphics.scene.light;
    import dlangui.graphics.scene.camera;

    protected Node3d _parent;
    protected Scene3d _scene;
    protected string _id;
    protected bool _visible = true;
    protected DrawableObjectRef _drawable;
    protected LightRef _light;

    protected mat4 _worldMatrix;

    protected ObjectList!Node3d _children;

    this(string id = null) {
        super();
        _id = id;
    }

    this(string id, DrawableObject drawable) {
        super();
        _id = id;
        _drawable = drawable;
    }

    @property bool visible() { return _visible; }
    @property Node3d visible(bool v) { _visible = v; return this; }

    /// drawable attached to node
    @property ref DrawableObjectRef drawable() { return _drawable; }

    /// light attached to node
    @property ref LightRef light() { return _light; }

    /// attach light to node
    @property Node3d light(Light v) {
        if (_light.get is v)
            return this;
        Node3d oldNode = v.node;
        v.node = this;
        _light = v;
        if (oldNode)
            oldNode._light = null;
        return this;
    }

    /// returns scene for node
    @property Scene3d scene() { 
        if (_scene)
            return _scene;
        if (_parent)
            return _parent.scene;
        return cast(Scene3d) this; 
    }

    @property void scene(Scene3d v) { _scene = v; }

    /// returns child node count
    @property int childCount() {
        return _children.count;
    }

    /// returns child node by index
    Node3d child(int index) {
        return _children[index];
    }

    /// add child node, return current node
    Node3d addChild(Node3d node) {
        _children.add(node);
        node.parent = this;
        node.scene = scene;
        return this;
    }

    /// removes and destroys child node by index
    void removeChild(int index) {
        destroy(_children.remove(index));
    }

    /// remove and destroy child node (returns true if child is found and removed)
    bool removeChild(Node3d child) {
        int index = findChild(child);
        if (index >= 0) {
            removeChild(index);
            return true;
        }
        return false;
    }

    /// find node index, returns -1 if not found
    int findChild(Node3d node) {
        if (node is null)
            return -1;
        for (int i = 0; i < childCount; i++) {
            if (child(i) is node)
                return i;
        }
        return -1;
    }

    @property ref ObjectList!Node3d children() { return _children; }

    /// parent node
    @property Node3d parent() {
        return _parent;
    }

    @property Node3d parent(Node3d v) {
        _parent = v;
        _scene = v.scene;
        return this;
    }
    /// id of node
    @property string id() {
        return _id;
    }
    /// set id for node
    @property Node3d id(string v) {
        _id = v;
        return this;
    }

    /// active camera or null of no camera
    @property Camera activeCamera() {
        if (!scene)
            return null;
        return scene.activeCamera;
    }

    @property vec3 cameraPosition() {
        auto cam = activeCamera;
        if (cam)
            return cam.translationWorld;
        return vec3(0, 0, 0);
    }

    /// get view matrix based on active camera
    @property ref const(mat4) viewMatrix() {
        auto cam = activeCamera;
        if (cam)
            return cam.viewMatrix;
        return mat4.IDENTITY;
    }

    /// get projection*view matrix based on active camera
    @property ref const(mat4) projectionViewMatrix() {
        auto cam = activeCamera;
        if (cam)
            return cam.projectionViewMatrix;
        return mat4.IDENTITY;
    }

    protected mat4 _projectionViewModelMatrix;

    /// returns projectionMatrix * viewMatrix * modelMatrix
    @property ref const(mat4) projectionViewModelMatrix() {
        // TODO: optimize
        _projectionViewModelMatrix = _scene.projectionViewMatrix * matrix;
        return _projectionViewModelMatrix;
    }

    /// returns world matrix
    @property ref const(mat4) worldMatrix() {
        if (!parent)
            return matrix;
        _worldMatrix = parent.worldMatrix * matrix;
        return _worldMatrix;
    }

    /**
    * Gets the world view matrix corresponding to this node.
    *
    * @return The world view matrix of this node.
    */
    @property ref const(mat4) worldViewMatrix() {
        static mat4 worldView;
        worldView = viewMatrix * worldMatrix;
        return worldView;
    }

    /// returns translation vector (position) of this node in world space
    @property vec3 translationWorld() {
        vec3 translation;
        worldMatrix.getTranslation(translation);
        return translation;
    }

    /// returns translation vector (position) of this node in view space
    @property vec3 translationView() {
        vec3 translation;
        worldMatrix.getTranslation(translation);
        viewMatrix.transformPoint(translation);
        return translation;
    }

    /**
    * Gets the inverse transpose world matrix corresponding to this node.
    *
    * This matrix is typically used to transform normal vectors into world space.
    *
    * @return The inverse world matrix of this node.
    */
    @property ref const(mat4) inverseTransposeWorldMatrix() {
        static __gshared mat4 invTransWorld;
        invTransWorld = worldMatrix;
        invTransWorld.invert();
        invTransWorld.transpose();
        return invTransWorld;
    }

    /**
    * Gets the inverse transpose world view matrix corresponding to this node.
    *
    * This matrix is typically used to transform normal vectors into view space.
    *
    * @return The inverse world view matrix of this node.
    */
    @property ref const(mat4) inverseTransposeWorldViewMatrix() {
        static __gshared mat4 invTransWorldView;
        invTransWorldView = viewMatrix * worldMatrix;
        invTransWorldView.invert();
        invTransWorldView.transpose();
        return invTransWorldView;
    }


    /**
    * Returns the forward vector of the Node in world space.
    *
    * @return The forward vector in world space.
    */
    @property vec3 forwardVectorWorld() {
        return worldMatrix.forwardVector;
    }
    /**
    * Returns the forward vector of the Node in view space.
    *
    * @return The forward vector in view space.
    */
    @property vec3 forwardVectorView() {
        vec3 vector = worldMatrix.forwardVector;
        viewMatrix.transformVector(vector);
        return vector;
    }
}
