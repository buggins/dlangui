module dlangui.graphics.fonts;
public import dlangui.graphics.drawbuf;
public import dlangui.core.types;
public import dlangui.core.logger;
import std.algorithm;

public enum FontFamily : int {
    SansSerif,
    Serif,
	Fantasy,
	Cursive,
    MonoSpace
}

public struct Glyph
{
    public ubyte   blackBoxX;   ///< 0: width of glyph
    public ubyte   blackBoxY;   ///< 1: height of glyph black box
    public byte    originX;     ///< 2: X origin for glyph
    public byte    originY;     ///< 3: Y origin for glyph
    public ushort  glyphIndex;  ///< 4: bytes in glyph array
    public ubyte   width;       ///< 6: full width of glyph
	public ubyte   lastUsage;
    public ubyte[] glyph;    ///< 7: glyph data, arbitrary size
}

public struct GlyphCache
{
	Glyph[] _data;
	uint _len;

	// find glyph in cache
	public Glyph * find(ushort glyphIndex) {
		for (uint i = 0; i < _len; i++) {
			Glyph * item = &_data[i];
			if (item.glyphIndex == glyphIndex) {
				item.lastUsage = 1;
				return item;
			}
		}
		return null;
	}

	public Glyph * put(ushort glyphIndex, Glyph * glyph) {
		if (_len >= _data.length) {
			uint newsize = (_len < 32) ? 32 : _len * 2;
			_data.length = newsize;
		}
		_data[_len++] = *glyph;
		Glyph * res = &_data[_len - 1];
		res.lastUsage = 1;
		return res;
	}

	// clear usage flags for all entries
	public void checkpoint() {
		for (uint src = 0; src < _len; src++) {
			_data[src].lastUsage = 0;
		}
	}

	// removes entries not used after last call of checkpoint() or cleanup()
	public void cleanup() {
		uint dst = 0;
		for (uint src = 0; src < _len; src++) {
			if (_data[src].lastUsage != 0) {
				_data[src].lastUsage = 0;
				if (src != dst) {
					_data[dst++] = _data[src];
				}
			}
		}
		_len = dst;
	}

	// removes all entries
	public void clear() {
		_data = null;
		_len = 0;
	}
	public ~this() {
		clear();
	}
}

public class Font : RefCountedObject {
    abstract public @property int size();
    abstract public @property int height();
    abstract public @property int weight();
    abstract public @property int baseline();
    abstract public @property bool italic();
    abstract public @property string face();
    abstract public @property FontFamily family();
    abstract public @property bool isNull();
	// measure text string, return accumulated widths[] (distance to end of n-th character), returns number of measured chars.
	abstract public int measureText(const dchar[] text, ref int[] widths, int maxWidth);
	// draw text string to buffer
	abstract public void drawText(DrawBuf buf, int x, int y, const dchar[] text, uint color);
	abstract public Glyph * getCharGlyph(dchar ch);
    public void clear() {}
    public ~this() { clear(); }
}
alias FontRef = Ref!Font;

public struct FontList {
	FontRef[] _list;
	uint _len;
	public ~this() {
		for (uint i = 0; i < _len; i++) {
			_list[i].clear();
		}
	}
	// returns item by index
	public ref FontRef get(int index) {
		return _list[index];
	}
	// returns index of found item, -1 if not found
	public int find(int size, int weight, bool italic, FontFamily family, string face) {
		for (int i = 0; i < _list.length; i++) {
			Font item = _list[i].get;
			if (item.family != family)
				continue;
			if (item.size != size)
				continue;
			if (item.italic != italic || item.weight != weight)
				continue;
			if (!equal(item.face, face))
				continue;
			return i;
		}
		return -1;
	}
	public ref FontRef add(Font item) {
		Log.d("FontList.add() enter");
		if (_len >= _list.length) {
			_list.length = _len < 16 ? 16 : _list.length * 2;
		}
		_list[_len++] = item;
		Log.d("FontList.add() exit");
		return _list[_len - 1];
	}
}

public class FontManager {
    static __gshared FontManager _instance;
    public static @property void instance(FontManager manager) {
        _instance = manager;
    }
    public static @property FontManager instance() {
        return _instance;
    }
    abstract public ref FontRef getFont(int size, int weight, bool italic, FontFamily family, string face);
    public ~this() {}
}
