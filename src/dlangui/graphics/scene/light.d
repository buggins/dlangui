module dlangui.graphics.scene.light;

import dlangui.core.math3d;
import dlangui.core.types;
import dlangui.graphics.scene.node;

import std.conv : to;

enum LightType : ubyte {
    directional,
    point,
    spot
}

/// Reference counted Light object
alias LightRef = Ref!Light;

class Light : RefCountedObject {

    protected Node3d _node;

    protected vec3 _color;

    protected bool _autobind = true;
    protected bool _enabled = true;

    protected this(vec3 color) { _color = color; }

    @property vec3 color() const { return _color; }
    @property Light color(vec3 c) { _color = c; return this; }
    @property LightType type() const { return LightType.directional; }

    @property bool autobind() const { return _autobind; }
    @property Light autobind(bool flg) { _autobind = flg; return this; }

    @property bool enabled() const { return _enabled; }
    @property Light enabled(bool flg) { _enabled = flg; return this; }

    @property Node3d node() { return _node; }
    @property Light node(Node3d n) { _node = n; return this; }

    /// direction in world coordinates
    @property vec3 direction() { return _node ? _node.forwardVectorWorld : vec3(0, 0, 1); }
    /// position in world coordinates
    @property vec3 position() { return _node ? _node.translationWorld : vec3(0, 0, 0); }

    @property float range() const { return 1.0; }
    @property void range(float v) { assert(false); }
    @property float rangeInverse() const { return 1.0; }

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

protected class PointLight : Light {
    protected float _range = 1;
    protected float _rangeInverse = 1;
    protected this(vec3 color, float range = 1) {
        super(color);
        _range = range;
        _rangeInverse = 1 / range;
    }

    override @property LightType type() const { return LightType.point; }

    override @property float range() const { return _range; }
    override @property void range(float v) { 
        _range = v; 
        _rangeInverse = 1 / v; 
    }
    override @property float rangeInverse() const { return _rangeInverse; }
}

alias LightCounts = int[3];

/// light collection
struct Lights {
    Light[] directional;
    Light[] point;
    Light[] spot;
    void reset() {
        directional = null;
        point = null;
        spot = null;
    }
    @property bool empty() { return directional.length + point.length + spot.length > 0; }
    /// returns point types by type
    @property LightCounts counts() const { return [cast(int)directional.length, cast(int)point.length, cast(int)spot.length]; }
    @property int directionalCount() const { return cast(int)directional.length; }
    @property int pointCount() const { return cast(int)point.length; }
    @property int spotCount() const { return cast(int)spot.length; }
    /// return light count definition for shaders, e.g. "DIRECTIONAL_LIGHT_COUNT 2;POINT_LIGHT_COUNT 1"
    @property string defs() const {
        if (!directional.length && !point.length && !spot.length)
            return null;
        char[] buf;
        if (directional.length) {
            buf ~= "DIRECTIONAL_LIGHT_COUNT ";
            buf ~= directional.length.to!string;
        }
        if (point.length) {
            if (buf)
                buf ~= ";";
            buf ~= "POINT_LIGHT_COUNT ";
            buf ~= point.length.to!string;
        }
        if (spot.length) {
            if (buf)
                buf ~= ";";
            buf ~= "SPOT_LIGHT_COUNT ";
            buf ~= spot.length.to!string;
        }
        return cast(string)buf;
    }
    void remove(Light light) {
        import std.algorithm : remove;
        switch(light.type) {
            case LightType.directional:
                foreach(index, v; directional)
                    if (v is light) {
                        directional = directional.remove(index);
                        return;
                    }
                directional ~= light;
                break;
            case LightType.point:
                foreach(index, v; point)
                    if (v is light) {
                        point = point.remove(index);
                        return;
                    }
                point ~= light;
                break;
            case LightType.spot:
                foreach(index, v; spot)
                    if (v is light) {
                        spot = spot.remove(index);
                        return;
                    }
                spot ~= light;
                break;
            default:
                break;
        }
    }
    /// returns true if light is added (not a duplicate, and enabled)
    bool add(Light light) {
        switch(light.type) {
            case LightType.directional:
                foreach(v; directional)
                    if (v is light)
                        return false;
                directional ~= light;
                return true;
            case LightType.point:
                foreach(v; point)
                    if (v is light)
                        return false;
                point ~= light;
                return true;
            case LightType.spot:
                foreach(v; spot)
                    if (v is light)
                        return false;
                spot ~= light;
                return true;
            default:
                return false;
        }
    }
    Lights clone() {
        Lights res;
        if (directional.length)
            res.directional ~= directional;
        if (point.length)
            res.point ~= point;
        if (spot.length)
            res.spot ~= spot;
        return res;
    }
}

struct LightParams {
    Lights _lights;

    /// returns true if light is added (not a duplicate, and enabled)
    bool add(Light light) {
        if (!light.node || !light.enabled || !_lights.add(light))
            return false;
        switch(light.type) {
            case LightType.directional:
                u_directionalLightDirection ~= light.direction;
                u_directionalLightColor ~= light.color;
                return true;
            case LightType.point:
                u_pointLightPosition ~= light.position;
                u_pointLightColor ~= light.color;
                u_pointLightRangeInverse ~= light.rangeInverse;
                return true;
            case LightType.spot:
                // TODO
                return true;
            default:
                return false;
        }
    }

    vec3[] u_directionalLightDirection;
    vec3[] u_directionalLightColor;

    vec3[] u_pointLightPosition;
    vec3[] u_pointLightColor;
    float[] u_pointLightRangeInverse;

    vec3[] u_spotLightPosition;
    vec3[] u_spotLightDirection;
    vec3[] u_spotLightColor;
    float[] u_spotLightRangeInverse;
    float[] u_spotLightInnerAngleCos;
    float[] u_spotLightOuterAngleCos;
}
