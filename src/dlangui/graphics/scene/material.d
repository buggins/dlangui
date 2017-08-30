module dlangui.graphics.scene.material;

public import dlangui.core.config;
static if (ENABLE_OPENGL):
static if (BACKEND_GUI):

import dlangui.core.types;
import dlangui.core.logger;
import dlangui.graphics.glsupport;
import dlangui.graphics.gldrawbuf;
import dlangui.graphics.scene.effect;
import dlangui.graphics.scene.node;
import dlangui.graphics.scene.mesh;
import dlangui.graphics.scene.light;

/// Reference counted Material object
alias MaterialRef = Ref!Material;

class Material : RefCountedObject {
    // effect
    protected EffectRef _effect;
    protected EffectId _effectId;
    protected string _autoEffectParams;
    protected EffectId _autoEffectId;

    // textures
    protected TextureRef _texture;
    protected string _textureId;
    protected bool _textureLinear = true;

    protected TextureRef _bumpTexture;
    protected string _bumpTextureId;

    // colors
    protected vec4 _diffuseColor = vec4(1, 1, 1, 1);
    protected vec3 _ambientColor = vec3(0.2, 0.2, 0.2);
    protected vec4 _modulateColor = vec4(1, 1, 1, 1);
    protected float _modulateAlpha = 1;

    /// 0 - specular is disabled, 1 .. 256 - specular exponent
    protected float _specular = 0;

    // TODO: more material properties

    this() {
    }

    this(EffectId effectId, string textureId, string bumpTextureId = null) {
        _effectId = effectId;
        _autoEffectParams = null;
        _autoEffectId = effectId;
        _textureId = textureId;
        _bumpTextureId = bumpTextureId;
    }

    @property vec4 diffuseColor() { return _diffuseColor; }
    @property Material diffuseColor(vec4 color) { _diffuseColor = color; return this; }
    @property vec3 ambientColor() { return _ambientColor; }
    @property Material ambientColor(vec3 color) { _ambientColor = color; return this; }
    @property vec4 modulateColor() { return _modulateColor; }
    @property Material modulateColor(vec4 color) { _modulateColor = color; return this; }
    @property float modulateAlpha() { return _modulateAlpha; }
    @property Material modulateColor(float a) { _modulateAlpha = a; return this; }
    @property float specular() { return _specular; }
    @property Material specular(float a) { _specular = a; return this; }

    @property EffectRef effect() {
        if (_effect.isNull && !_autoEffectId.empty)
            _effect = EffectCache.instance.get(_autoEffectId);
        return _effect;
    }
    /// set as effect instance
    @property Material effect(EffectRef e) {
        _effect = e;
        return this;
    }
    /// set as effect id
    @property Material effect(EffectId effectId) {
        if (_effectId == effectId)
            return this; // no change
        _effectId = effectId;
        _autoEffectId = EffectId(_effectId, _autoEffectParams);
        _effect.clear();
        return this;
    }

    protected @property Material autoEffectParams(string params) {
        if (_autoEffectParams != params && !_effectId.empty) {
            _autoEffectId = EffectId(_effectId, params);
            _autoEffectParams = params;
            _effect.clear();
        }
        return this;
    }

    @property TextureRef texture() {
        if (_texture.isNull && _textureId.length) {
            _texture = GLTextureCache.instance.get(_textureId);
        }
        return _texture;
    }
    /// set texture
    @property Material texture(TextureRef e) {
        _texture = e;
        return this;
    }
    /// set texture from resourceId
    @property Material texture(string resourceId) {
        if (_textureId == resourceId)
            return this; // no change
        _texture.clear();
        _textureId = resourceId;
        return this;
    }
    @property bool textureLinear() { return _textureLinear; }
    @property Material textureLinear(bool v) { _textureLinear = v; return this; }


    @property TextureRef bumpTexture() {
        if (_bumpTexture.isNull && _bumpTextureId.length) {
            _bumpTexture = GLTextureCache.instance.get(_bumpTextureId);
        }
        return _bumpTexture;
    }
    /// set texture
    @property Material bumpTexture(TextureRef e) {
        _bumpTexture = e;
        return this;
    }
    /// set texture from resourceId
    @property Material bumpTexture(string resourceId) {
        if (_bumpTextureId == resourceId)
            return this; // no change
        _bumpTexture.clear();
        _bumpTextureId = resourceId;
        return this;
    }

    FogParams _fogParams;
    @property FogParams fogParams() { return _fogParams; }
    @property Material fogParams(FogParams fogParams) { _fogParams = fogParams; return this; }

    private AutoParams _lastParams;
    private string _lastDefs;
    string calcAutoEffectParams(Mesh mesh, LightParams * lights) {
        AutoParams newParams = AutoParams(mesh, lights, _specular, !bumpTexture.isNull, _fogParams);
        if (newParams != _lastParams) {
            _lastParams = newParams;
            _lastDefs = _lastParams.defs;
        }
        return _lastDefs;
    }

    void bind(Node3d node, Mesh mesh, LightParams * lights = null) {
        autoEffectParams = calcAutoEffectParams(mesh, lights);
        assert(!effect.isNull);
        effect.bind();
        if (!texture.isNull) {
            texture.texture.setup();
            texture.texture.setSamplerParams(_textureLinear, true, true);
        }
        if (!bumpTexture.isNull) {
            bumpTexture.texture.setup(1);
            bumpTexture.texture.setSamplerParams(true, true, false);
        }
        // matrixes, positions uniforms
        if (_effect.hasUniform(DefaultUniform.u_worldViewProjectionMatrix))
            _effect.setUniform(DefaultUniform.u_worldViewProjectionMatrix, node.projectionViewModelMatrix);
        if (_effect.hasUniform(DefaultUniform.u_cameraPosition))
            _effect.setUniform(DefaultUniform.u_cameraPosition, node.cameraPosition);
        if (_effect.hasUniform(DefaultUniform.u_worldViewMatrix))
            _effect.setUniform(DefaultUniform.u_worldViewMatrix, node.worldViewMatrix);
        if (_effect.hasUniform(DefaultUniform.u_inverseTransposeWorldViewMatrix))
            _effect.setUniform(DefaultUniform.u_inverseTransposeWorldViewMatrix, node.inverseTransposeWorldViewMatrix);

        // color uniforms
        if (_effect.hasUniform(DefaultUniform.u_ambientColor))
            _effect.setUniform(DefaultUniform.u_ambientColor, _ambientColor);
        if (_effect.hasUniform(DefaultUniform.u_diffuseColor))
            _effect.setUniform(DefaultUniform.u_diffuseColor, _diffuseColor);
        if (_effect.hasUniform(DefaultUniform.u_modulateColor))
            _effect.setUniform(DefaultUniform.u_modulateColor, _modulateColor);
        if (_effect.hasUniform(DefaultUniform.u_modulateAlpha))
            _effect.setUniform(DefaultUniform.u_modulateAlpha, _modulateAlpha);
        if (_effect.hasUniform(DefaultUniform.u_specularExponent))
            _effect.setUniform(DefaultUniform.u_specularExponent, _specular);

        // fog uniforms
        if (_fogParams) {
            if (_effect.hasUniform(DefaultUniform.u_fogColor))
                _effect.setUniform(DefaultUniform.u_fogColor, _fogParams.fogColor);
            if (_effect.hasUniform(DefaultUniform.u_fogMinDistance))
                _effect.setUniform(DefaultUniform.u_fogMinDistance, _fogParams.fogMinDistance);
            if (_effect.hasUniform(DefaultUniform.u_fogMaxDistance))
                _effect.setUniform(DefaultUniform.u_fogMaxDistance, _fogParams.fogMaxDistance);
        }

        // lighting uniforms
        if (lights && !lights.empty) {
            if (lights.u_directionalLightDirection.length) {
                if (_effect.hasUniform(DefaultUniform.u_directionalLightDirection)) {
                    _effect.setUniform(DefaultUniform.u_directionalLightDirection, lights.u_directionalLightDirection);
                    //Log.d("DefaultUniform.u_directionalLightDirection: ", lights.u_directionalLightDirection);
                }
                if (_effect.hasUniform(DefaultUniform.u_directionalLightColor))
                    _effect.setUniform(DefaultUniform.u_directionalLightColor, lights.u_directionalLightColor);
            }
            if (lights.u_pointLightPosition.length) {
                if (_effect.hasUniform(DefaultUniform.u_pointLightPosition))
                    _effect.setUniform(DefaultUniform.u_pointLightPosition, lights.u_pointLightPosition);
                if (_effect.hasUniform(DefaultUniform.u_pointLightColor))
                    _effect.setUniform(DefaultUniform.u_pointLightColor, lights.u_pointLightColor);
                if (_effect.hasUniform(DefaultUniform.u_pointLightRangeInverse))
                    _effect.setUniform(DefaultUniform.u_pointLightRangeInverse, lights.u_pointLightRangeInverse);
            }
            if (lights.u_spotLightPosition.length) {
                if (_effect.hasUniform(DefaultUniform.u_spotLightPosition))
                    _effect.setUniform(DefaultUniform.u_spotLightPosition, lights.u_spotLightPosition);
                if (_effect.hasUniform(DefaultUniform.u_spotLightDirection))
                    _effect.setUniform(DefaultUniform.u_spotLightDirection, lights.u_spotLightDirection);
                if (_effect.hasUniform(DefaultUniform.u_spotLightColor))
                    _effect.setUniform(DefaultUniform.u_spotLightColor, lights.u_spotLightColor);
                if (_effect.hasUniform(DefaultUniform.u_spotLightRangeInverse))
                    _effect.setUniform(DefaultUniform.u_spotLightRangeInverse, lights.u_spotLightRangeInverse);
                if (_effect.hasUniform(DefaultUniform.u_spotLightInnerAngleCos))
                    _effect.setUniform(DefaultUniform.u_spotLightInnerAngleCos, lights.u_spotLightInnerAngleCos);
                if (_effect.hasUniform(DefaultUniform.u_spotLightOuterAngleCos))
                    _effect.setUniform(DefaultUniform.u_spotLightOuterAngleCos, lights.u_spotLightOuterAngleCos);
            }
        }
    }

    void drawMesh(Mesh mesh, bool wireframe) {
        effect.draw(mesh, wireframe);
    }

    void unbind() {
        if (!texture.isNull) {
            texture.texture.unbind();
        }
        if (!bumpTexture.isNull) {
            bumpTexture.texture.unbind();
        }
        effect.unbind();
    }
}

struct AutoParams {
    ubyte directionalLightCount = 0;
    ubyte pointLightCount = 0;
    ubyte spotLightCount = 0;
    bool vertexColor = false;
    bool specular = false;
    bool bumpMapping = false;
    FogParams fogParams;
    this(Mesh mesh, LightParams * lights, float specular, bool bumpMapping, FogParams fogParams) {
        if (mesh)
            vertexColor = mesh.hasElement(VertexElementType.COLOR);
        if (lights) {
            directionalLightCount = cast(ubyte)lights.u_directionalLightDirection.length;
            pointLightCount = cast(ubyte)lights.u_pointLightPosition.length;
            spotLightCount = cast(ubyte)lights.u_spotLightPosition.length;
        }
        this.specular = specular > 0.01;
        this.bumpMapping = bumpMapping;
        this.fogParams = fogParams;
    }
    string defs() {
        import std.conv : to;
        char[] buf;
        if (fogParams) {
            buf ~= "FOG";
        }
        if (directionalLightCount) {
            if (buf.length)
                buf ~= ";";
            buf ~= "DIRECTIONAL_LIGHT_COUNT ";
            buf ~= directionalLightCount.to!string;
        }
        if (pointLightCount) {
            if (buf.length)
                buf ~= ";";
            buf ~= "POINT_LIGHT_COUNT ";
            buf ~= pointLightCount.to!string;
        }
        if (spotLightCount) {
            if (buf.length)
                buf ~= ";";
            buf ~= "SPOT_LIGHT_COUNT ";
            buf ~= spotLightCount.to!string;
        }
        if (vertexColor) {
            if (buf.length)
                buf ~= ";";
            buf ~= "VERTEX_COLOR";
        }
        if (specular) {
            if (buf.length)
                buf ~= ";";
            buf ~= "SPECULAR";
        }
        if (bumpMapping) {
            if (buf.length)
                buf ~= ";";
            buf ~= "BUMPED";
        }
        return buf.dup;
    }
}

class FogParams {
    immutable vec4 fogColor;
    immutable float fogMinDistance;
    immutable float fogMaxDistance;
    this(vec4 fogColor, float fogMinDistance, float fogMaxDistance) {
        this.fogColor = fogColor;
        this.fogMinDistance = fogMinDistance;
        this.fogMaxDistance = fogMaxDistance;
    }
}
