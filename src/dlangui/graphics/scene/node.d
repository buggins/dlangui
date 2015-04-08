module dlangui.graphics.scene.node;

import gl3n.linalg;
import gl3n.math;

import dlangui.graphics.scene.transform;

/// 3D scene node
class Node3d : Transform {
    protected Node3d _parent;
    protected string _id;

    protected mat4 _worldMatrix;


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
