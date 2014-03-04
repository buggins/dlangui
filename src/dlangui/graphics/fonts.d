module dlangui.graphics.fonts;
import dlangui.core.types;

enum FontFamily : int {
    SansSerif,
    Serif,
	Fantasy,
	Cursive,
    MonoSpace
}

class Font : RefCountedObject {
    abstract public @property int size();
    abstract public @property int height();
    abstract public @property int weight();
    abstract public @property int baseline();
    abstract public @property bool italic();
    abstract public @property string face();
    abstract public @property FontFamily family();
    abstract public @property bool isNull();
	abstract public int measureText(const dchar[] text, ref int[] widths, int maxWidth);
    public void clear() {}
    public ~this() { clear(); }
}
alias FontRef = Ref!Font;

class FontManager {
    static __gshared FontManager _instance;
    public static @property void instance(FontManager manager) {
        _instance = manager;
    }
    public static @property FontManager instance() {
        return _instance;
    }
    abstract public FontRef getFont(int size, int weight, bool italic, FontFamily family, string face);
    public ~this() {}
}
