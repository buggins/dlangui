module dlangui.graphics.scene.model;

public import dlangui.core.config;
static if (ENABLE_OPENGL):

import dlangui.graphics.scene.drawableobject;

class Model : DrawableObject {
    import dlangui.graphics.scene.mesh;
    import dlangui.graphics.scene.material;
    import dlangui.graphics.scene.light;



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

    protected static __gshared LightParams _lightParamsBuffer;
    @property protected LightParams * lights(Node3d node) {
        if (!node.scene)
            return null;
        if (_lights.empty) {
            if (node.scene.boundLights.empty)
                return null;
            return node.scene.boundLightsPtr;
        }
        if (node.scene.boundLights.empty) {
            _lightParamsBuffer.reset();
            _lightParamsBuffer.add(_lights);
        } else {
            _lightParamsBuffer.reset(node.scene.boundLights);
            _lightParamsBuffer.add(_lights);
        }
        return &_lightParamsBuffer;
    }

    override void draw(Node3d node, bool wireframe) {
        /// override it
        _material.bind(node, _mesh, lights(node));
        _material.drawMesh(_mesh);
        _material.unbind();
    }
}
