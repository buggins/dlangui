/// freetype fonts support
module dlangui.graphics.ftfonts;

import dlangui.graphics.fonts;

import derelict.freetype.ft;

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

	~this() {}
}
