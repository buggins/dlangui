module dlangui.graphics.scene.material;

public import dlangui.core.config;

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

    // textures
    protected TextureRef _texture;
    protected string _textureId;

    // colors
    protected vec4 _diffuseColor = vec4(1, 1, 1, 1);
    protected vec3 _ambientColor = vec3(1, 1, 1);
    protected vec4 _modulateColor = vec4(1, 1, 1, 1);
    protected float _modulateAlpha = 1;

    // TODO: more material properties

    this() {
    }

    this(EffectId effectId, string textureId) {
        _effectId = effectId;
        _textureId = textureId;
    }

    @property vec4 diffuseColor() { return _diffuseColor; }
    @property Material diffuseColor(vec4 color) { _diffuseColor = color; return this; }
    @property vec3 ambientColor() { return _ambientColor; }
    @property Material ambientColor(vec3 color) { _ambientColor = color; return this; }
    @property vec4 modulateColor() { return _modulateColor; }
    @property Material modulateColor(vec4 color) { _modulateColor = color; return this; }
    @property float modulateAlpha() { return _modulateAlpha; }
    @property Material modulateColor(float a) { _modulateAlpha = a; return this; }

    @property EffectRef effect() {
        if (_effect.isNull && !_effectId.empty)
            _effect = EffectCache.instance.get(_effectId); 
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
        _effect.clear();
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

    void bind(Node3d node) {
        assert(!effect.isNull);
        effect.bind();
        if (!texture.isNull) {
            texture.texture.setup();
            texture.texture.setSamplerParams(true);
        }
        // TODO: more uniforms
        if (_effect.hasUniform(DefaultUniform.u_worldViewProjectionMatrix))
            _effect.setUniform(DefaultUniform.u_worldViewProjectionMatrix, node.projectionViewModelMatrix);
        if (_effect.hasUniform(DefaultUniform.u_cameraPosition))
            _effect.setUniform(DefaultUniform.u_cameraPosition, node.cameraPosition);
        if (_effect.hasUniform(DefaultUniform.u_worldViewMatrix))
            _effect.setUniform(DefaultUniform.u_worldViewMatrix, node.worldViewMatrix);
        if (_effect.hasUniform(DefaultUniform.u_ambientColor))
            _effect.setUniform(DefaultUniform.u_ambientColor, _ambientColor);
        if (_effect.hasUniform(DefaultUniform.u_diffuseColor))
            _effect.setUniform(DefaultUniform.u_diffuseColor, _diffuseColor);
        if (_effect.hasUniform(DefaultUniform.u_modulateColor))
            _effect.setUniform(DefaultUniform.u_modulateColor, _modulateColor);
        if (_effect.hasUniform(DefaultUniform.u_modulateAlpha))
            _effect.setUniform(DefaultUniform.u_modulateAlpha, _modulateAlpha);
    }

    void drawMesh(Mesh mesh) {
        effect.draw(mesh);
    }

    void unbind() {
        if (!texture.isNull) {
            texture.texture.unbind();
        }
        effect.unbind();
    }
}
