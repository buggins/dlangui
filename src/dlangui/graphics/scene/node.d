module dlangui.graphics.scene.node;

import dlangui.core.math3d;

import dlangui.graphics.scene.transform;
import dlangui.core.collections;
import dlangui.graphics.scene.scene3d;

/// 3D scene node
class Node3d : Transform {
    protected Node3d _parent;
    protected Scene3d _scene;
    protected string _id;

    protected mat4 _worldMatrix;

    protected ObjectList!Node3d _children;

    this() {
        super();
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

    /// add child node
    void addChild(Node3d node) {
        _children.add(node);
        node.parent = this;
        node.scene = scene;
    }

    /// removes and destroys child node by index
    void removeChild(int index) {
        destroy(_children.remove(index));
    }

    /// parent node
    @property Node3d parent() {
        return _parent;
    }

    @property Node3d parent(Node3d v) {
        _parent = v;
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
}
