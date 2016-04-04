module dlangui.graphics.scene.model;

import dlangui.graphics.scene.drawableobject;
import dlangui.graphics.scene.mesh;
import dlangui.graphics.scene.material;
import dlangui.graphics.scene.light;

class Model : DrawableObject {
    protected MaterialRef _material;
    protected MeshRef _mesh;
    protected bool _autobindLights = true;
    protected Lights _lights;

    this() {
    }

    this(Material material, Mesh mesh) {
        _material = material;
        _mesh = mesh;
    }

    @property ref MaterialRef material() { return _material; }
    @property ref MeshRef mesh() { return _mesh; }

    @property bool autobindLights() { return _autobindLights; }
    @property Model autobindLights(bool flg) { _autobindLights = flg; return this; }

    Model bindLight(Light light) {
        _lights.add(light);
        return this;
    }

    Model unbindLight(Light light) {
        _lights.remove(light);
        return this;
    }

    override void draw(Node3d node, bool wireframe) {
        /// override it
        _material.bind(node);
        _material.drawMesh(_mesh);
        _material.unbind();
    }
}
