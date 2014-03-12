/// freetype fonts support
module dlangui.graphics.ftfonts;

import dlangui.graphics.fonts;

import derelict.freetype.ft;
private import dlangui.core.logger;

private struct FontDef {
    immutable FontFamily _family;
    immutable string _face;
	immutable bool _italic;
	immutable int _weight;
	@property FontFamily family() { return _family; }
	@property string face() { return _face; }
	@property bool italic() { return _italic; }
	@property int weight() { return _weight; }
	this(FontFamily family, string face, bool italic, int weight) {
		_family = family;
		_face = face;
		_italic = italic;
        _weight = weight;
	}
}

/// FreeType based font manager.
class FreeTypeFontManager : FontManager {

	private FontList _activeFonts;

    private FontRef _nullFontRef;

    this() {
        // load dynaic library
        DerelictFT.load();
    }

    /// get font instance with specified parameters
    override ref FontRef getFont(int size, int weight, bool italic, FontFamily family, string face) {
        return _nullFontRef;
    }

	/// clear usage flags for all entries
	override void checkpoint() {
    }

	/// removes entries not used after last call of checkpoint() or cleanup()
	override void cleanup() {
    }

    /// register freetype font by filename - optinally font properties can be passed if known (e.g. from libfontconfig).
    bool registerFont(string filename, FontFamily family = FontFamily.SansSerif, string face = null, bool italic = false, int weight = 0) {
        Log.d("FreeTypeFontManager.registerFont ", filename, " ", family, " ", face, " italic=", italic, " weight=", weight);
        return false;
    }

	~this() {}
}
