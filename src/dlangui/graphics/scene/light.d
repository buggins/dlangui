module dlangui.graphics.scene.light;

import dlangui.core.math3d;
import dlangui.core.types;

enum LightType : ubyte {
    directional,
    point,
    spot
}

/// Reference counted Light object
alias LightRef = Ref!Light;

class Light  : RefCountedObject {
    protected vec3 _color;
    protected this(vec3 color) {}
    @property vec3 color() { return _color; }
    @property Light color(vec3 c) { _color = c; return this; }
    @property LightType type() { return LightType.directional; }
    /// create new directional light
    static Light createDirectional(vec3 color) {
        return new DirectionalLight(color);
    }
}

protected class DirectionalLight : Light {
    protected this(vec3 color) {
        super(color);
    }
}
