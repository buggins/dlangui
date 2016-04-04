module dlangui.graphics.scene.node;

import dlangui.core.math3d;

import dlangui.graphics.scene.transform;
import dlangui.core.collections;
import dlangui.graphics.scene.scene3d;
import dlangui.graphics.scene.drawableobject;
import dlangui.graphics.scene.light;

/// 3D scene node
class Node3d : Transform {
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

    protected mat4 _projectionViewModelMatrix;
    /// returns projectionMatrix * viewMatrix * modelMatrix
    @property ref const(mat4) projectionViewModelMatrix() {
        _projectionViewModelMatrix = _scene.projectionViewMatrix * matrix;
        return _projectionViewModelMatrix;
    }
}
