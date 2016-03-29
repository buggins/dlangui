module dlangui.graphics.scene.material;

public import dlangui.core.config;

import dlangui.core.types;
import dlangui.core.logger;
import dlangui.graphics.glsupport;
import dlangui.graphics.gldrawbuf;
import dlangui.graphics.scene.effect;

/// Reference counted Material object
alias MaterialRef = Ref!Material;

class Material : RefCountedObject {
    protected EffectRef _effect;
    protected TextureRef _texture;
    // TODO: more material properties

    @property EffectRef effect() { return _effect; }
    /// set as effect instance
    @property Material effect(EffectRef e) {
        _effect = e; 
        return this;
    }
    /// set as effect id
    @property Material effect(EffectId effectId) {
        _effect = EffectCache.instance.get(effectId); 
        return this;
    }

    @property TextureRef texture() { return _texture; }
    /// set texture
    @property Material texture(TextureRef e) { 
        _texture = e; 
        return this;
    }
    /// set texture from resourceId
    @property Material texture(string resourceId) { 
        _texture = GLTextureCache.instance.get(resourceId);
        return this;
    }
}
