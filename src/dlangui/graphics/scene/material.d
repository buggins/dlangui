module dlangui.graphics.scene.material;

public import dlangui.core.config;

import dlangui.core.types;
import dlangui.core.logger;
import dlangui.graphics.glsupport;
import dlangui.graphics.gldrawbuf;
import dlangui.graphics.scene.effect;
import dlangui.graphics.scene.node;
import dlangui.graphics.scene.mesh;

/// Reference counted Material object
alias MaterialRef = Ref!Material;

class Material : RefCountedObject {
    protected EffectRef _effect;
    protected EffectId _effectId;
    protected TextureRef _texture;
    protected string _textureId;
    // TODO: more material properties

    this() {
    }

    this(EffectId effectId, string textureId) {
        _effectId = effectId;
        _textureId = textureId;
    }

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
        _effect.setUniform(DefaultUniform.u_worldViewProjectionMatrix, node.projectionViewModelMatrix);
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
