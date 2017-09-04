module dlangui.graphics.scene.light;

public import dlangui.core.config;
static if (ENABLE_OPENGL):
static if (BACKEND_GUI):

import dlangui.core.math3d;
import dlangui.core.types;

import std.conv : to;

enum LightType : ubyte {
    directional,
    point,
    spot
}

/// Reference counted Light object
alias LightRef = Ref!Light;

class Light : RefCountedObject {

    import dlangui.graphics.scene.node;

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
    @property vec3 direction() { return _node ? _node.forwardVectorView : vec3(0, 0, 1); }
    /// position in world coordinates
    @property vec3 position() { return _node ? _node.translationView : vec3(0, 0, 0); }

    @property float range() const { return 1.0; }
    @property void range(float v) { assert(false); }
    @property float rangeInverse() const { return 1.0; }

    @property float innerAngle() const { assert(false); }
    @property float innerAngleCos() const { assert(false); }
    @property float outerAngle() const { assert(false); }
    @property float outerAngleCos() const { assert(false); }

    /// create new directional light
    static Light createDirectional(vec3 color) {
        return new DirectionalLight(color);
    }
    /// create new point light
    static Light createPoint(vec3 color, float range) {
        return new PointLight(color, range);
    }
    /// create new point light
    static Light createSpot(vec3 color, float range, float innerAngle, float outerAngle) {
        return new SpotLight(color, range, innerAngle, outerAngle);
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
    protected this(vec3 color, float range) {
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

protected class SpotLight : PointLight {
    protected float _innerAngle;
    protected float _innerAngleCos;
    protected float _outerAngle;
    protected float _outerAngleCos;
    protected this(vec3 color, float range, float innerAngle, float outerAngle) {
        import std.math;
        super(color, range);
        _innerAngle = innerAngle;
        _outerAngle = outerAngle;
        _innerAngleCos = cos(innerAngle);
        _outerAngleCos = cos(outerAngle);
    }

    override @property LightType type() const { return LightType.spot; }

    override @property float innerAngle() const { return _innerAngle; }
    override @property float innerAngleCos() const { return _innerAngleCos; }
    override @property float outerAngle() const { return _outerAngle; }
    override @property float outerAngleCos() const { return _outerAngleCos; }
}

alias LightCounts = int[3];

/// light collection
struct Lights {
    Light[] directional;
    Light[] point;
    Light[] spot;
    void reset() {
        directional.length = 0;
        point.length = 0;
        spot.length = 0;
    }
    @property bool empty() const { return directional.length + point.length + spot.length == 0; }
    /// returns point types by type
    @property LightCounts counts() const { return [cast(int)directional.length, cast(int)point.length, cast(int)spot.length]; }
    @property int directionalCount() const { return cast(int)directional.length; }
    @property int pointCount() const { return cast(int)point.length; }
    @property int spotCount() const { return cast(int)spot.length; }
    ///// return light count definition for shaders, e.g. "DIRECTIONAL_LIGHT_COUNT 2;POINT_LIGHT_COUNT 1"
    //@property string defs() const {
    //    if (!directional.length && !point.length && !spot.length)
    //        return null;
    //    static __gshared char[] buf;
    //    buf.length = 0; // reset buffer
    //    if (directional.length) {
    //        buf ~= "DIRECTIONAL_LIGHT_COUNT ";
    //        buf ~= directional.length.to!string;
    //    }
    //    if (point.length) {
    //        if (buf.length)
    //            buf ~= ";";
    //        buf ~= "POINT_LIGHT_COUNT ";
    //        buf ~= point.length.to!string;
    //    }
    //    if (spot.length) {
    //        if (buf.length)
    //            buf ~= ";";
    //        buf ~= "SPOT_LIGHT_COUNT ";
    //        buf ~= spot.length.to!string;
    //    }
    //    return buf.dup;
    //}
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

    @property bool empty() const { return _lights.empty; }
    //@property string defs() const { return _lights.defs; }

    void reset() {
        _lights.reset();
        u_directionalLightDirection.length = 0;
        u_directionalLightColor.length = 0;

        u_pointLightPosition.length = 0;
        u_pointLightColor.length = 0;
        u_pointLightRangeInverse.length = 0;

        u_spotLightPosition.length = 0;
        u_spotLightDirection.length = 0;
        u_spotLightColor.length = 0;
        u_spotLightRangeInverse.length = 0;
        u_spotLightInnerAngleCos.length = 0;
        u_spotLightOuterAngleCos.length = 0;
    }

    void reset(ref LightParams params) {
        reset();
        if (params._lights.directional.length)
            _lights.directional ~= params._lights.directional;
        if (params._lights.point.length)
            _lights.point ~= params._lights.point;
        if (params._lights.spot.length)
            _lights.spot ~= params._lights.spot;

        u_directionalLightDirection ~= params.u_directionalLightDirection;
        u_directionalLightColor ~= params.u_directionalLightColor;

        u_pointLightPosition ~= params.u_pointLightPosition;
        u_pointLightColor ~= params.u_pointLightColor;
        u_pointLightRangeInverse ~= params.u_pointLightRangeInverse;

        u_spotLightPosition ~= params.u_spotLightPosition;
        u_spotLightDirection ~= params.u_spotLightDirection;
        u_spotLightColor ~= params.u_spotLightColor;
        u_spotLightRangeInverse ~= params.u_spotLightRangeInverse;
        u_spotLightInnerAngleCos ~= params.u_spotLightInnerAngleCos;
        u_spotLightOuterAngleCos ~= params.u_spotLightOuterAngleCos;
    }

    void add(ref Lights lights) {
        foreach(light; lights.directional)
            add(light);
        foreach(light; lights.point)
            add(light);
        foreach(light; lights.spot)
            add(light);
    }

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
                u_spotLightPosition ~= light.position;
                u_spotLightDirection ~= light.direction;
                u_spotLightColor ~= light.color;
                u_spotLightRangeInverse ~= light.rangeInverse;
                u_spotLightInnerAngleCos ~= light.innerAngleCos;
                u_spotLightOuterAngleCos ~= light.outerAngleCos;
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
