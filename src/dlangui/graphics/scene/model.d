module dlangui.graphics.scene.model;

import dlangui.graphics.scene.drawableobject;
import dlangui.graphics.scene.mesh;
import dlangui.graphics.scene.material;

class Model : DrawableObject {
    protected MaterialRef _material;
    protected MeshRef _mesh;

    this() {
    }

    this(Material material, Mesh mesh) {
        _material = material;
        _mesh = mesh;
    }

    @property ref MaterialRef material() { return _material; }
    @property ref MeshRef mesh() { return _mesh; }

    override void draw(Node3d node, bool wireframe) {
        /// override it
        _material.bind(node);
        _material.drawMesh(_mesh);
        _material.unbind();
    }
}
