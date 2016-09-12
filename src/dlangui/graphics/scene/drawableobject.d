module dlangui.graphics.scene.drawableobject;

import dlangui.core.config;
static if (ENABLE_OPENGL):
static if (BACKEND_GUI):

import dlangui.core.types;

/// Reference counted DrawableObject
alias DrawableObjectRef = Ref!DrawableObject;

/// base drawable object
class DrawableObject : RefCountedObject {

    import dlangui.graphics.scene.node;

    this() {
    }
    void draw(Node3d node, bool wireframe) {
        /// override it
    }
}

/// base drawable object with material
class MaterialDrawableObject : DrawableObject {
    import dlangui.graphics.scene.node;
    import dlangui.graphics.scene.material;
    import dlangui.graphics.scene.light;

    protected MaterialRef _material;
    protected bool _autobindLights = true;
    protected Lights _lights;

    this() {
    }

    this(Material material) {
        _material = material;
    }

    @property ref MaterialRef material() { return _material; }

    @property bool autobindLights() { return _autobindLights; }
    @property MaterialDrawableObject autobindLights(bool flg) { _autobindLights = flg; return this; }

    MaterialDrawableObject bindLight(Light light) {
        _lights.add(light);
        return this;
    }

    MaterialDrawableObject unbindLight(Light light) {
        _lights.remove(light);
        return this;
    }

    protected static __gshared LightParams _lightParamsBuffer;
    @property protected LightParams * lights(Node3d node) {
        if (!node.scene)
            return null;
        if (!_autobindLights)
            return null; // TODO: allow manually bound lights
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
    }
}
