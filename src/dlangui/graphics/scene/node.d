module dlangui.graphics.scene.node;

import gl3n.linalg;
import gl3n.math;

import dlangui.graphics.scene.transform;
import dlangui.core.collections;

/// 3D scene node
class Node3d : Transform {
    protected Node3d _parent;
    protected string _id;

    protected mat4 _worldMatrix;

    protected ObjectList!Node3d _children;

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
