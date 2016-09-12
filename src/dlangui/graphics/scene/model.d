module dlangui.graphics.scene.model;

public import dlangui.core.config;
static if (ENABLE_OPENGL):
static if (BACKEND_GUI):

import dlangui.graphics.scene.drawableobject;

class Model : MaterialDrawableObject {
    import dlangui.graphics.scene.mesh;
    import dlangui.graphics.scene.node;
    import dlangui.graphics.scene.material;
    import dlangui.graphics.scene.light;



    protected MeshRef _mesh;

    this() {
    }

    this(Material material, Mesh mesh) {
        super(material);
        _mesh = mesh;
    }

    @property ref MeshRef mesh() { return _mesh; }

    override void draw(Node3d node, bool wireframe) {
        /// override it
        _material.bind(node, _mesh, lights(node));
        _material.drawMesh(_mesh);
        _material.unbind();
    }
}
