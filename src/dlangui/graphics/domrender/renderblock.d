module dlangui.graphics.domrender.renderblock;

import dlangui.core.types;
import dlangui.core.collections;
import dlangui.core.css;
import dlangui.core.dom;

class RenderBlock {
    Rect pos;
    Rect margins;
    Rect padding;
    Rect borderWidth;
    Rect borderStyle;
    Collection!RenderBlock children;
}
