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
    protected GLTexture _texture;

    @property EffectRef effect() { return _effect; }
    @property Material effect(EffectRef e) { 
        _effect = e; 
        return this;
    }
}
