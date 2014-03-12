/// freetype fonts support
module dlangui.graphics.ftfonts;

import dlangui.graphics.fonts;

import derelict.freetype.ft;
private import dlangui.core.logger;
private import std.algorithm;
private import std.file;
private import std.string;

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
    const bool opEquals(ref const FontDef v) {
        return _family == v._family && _italic == v._italic && _weight == v._weight && _face.equal(v._face);
    }
    const hash_t toHash() {
        hash_t res = 123;
        res = res * 31 + cast(hash_t)_italic;
        res = res * 31 + cast(hash_t)_weight;
        res = res * 31 + cast(hash_t)_family;
        res = res * 31 + typeid(_face).getHash(&_face);
        return res;
    }
}

private class FontFileItem {
    FontDef _def;
    string[] _filenames;
    string[] _faceName;
    @property ref FontDef def() { return _def; }
    void addFile(string fn) {
        // check for duplicate entry
        foreach (ref string existing; _filenames)
            if (fn.equal(existing))
                return;
        _filenames ~= fn;
    }
    this(FontDef def) {
        _def = def;
    }
}

private class FreeTypeFontFile {
    private string _filename;
    private string _faceName;
    private FT_Library    _library;
    private FT_Face       _face;
    private FT_GlyphSlot  _slot;
    private FT_Matrix     _matrix;                 /* transformation matrix */

    private int _height;
    private int _size;
    private int _baseline;
    private int _weight;
    private bool _italic;

    /// filename
    @property string filename() { return _filename; }
    // properties as detected after opening of file
    @property string face() { return _faceName; }
    @property int height() { return _height; }
    @property int size() { return _size; }
    @property int baseline() { return _baseline; }
    @property int weight() { return _weight; }
    @property bool italic() { return _italic; }

    this(FT_Library library, string filename) {
        _library = library;
        _filename = filename;
        _matrix.xx = 0x10000;
        _matrix.yy = 0x10000;
        _matrix.xy = 0;
        _matrix.yx = 0;
    }

    private static string familyName(FT_Face face)
    {
        string faceName = fromStringz(face.family_name);
        string styleName = fromStringz(face.style_name);
        if (faceName.equal("Arial") && styleName.equal("Narrow"))
            faceName ~= " Narrow";
        else if (styleName.equal("Condensed"))
            faceName ~= " Condensed";
        return faceName;
    }

    /// open face with specified size
    bool open(int size, int index = 0) {
        int error = FT_New_Face( _library, _filename.toStringz, index, &_face); /* create face object */
        if (error)
            return false;
        if ( _filename.endsWith(".pfb") || _filename.endsWith(".pfa") ) {
        	string kernFile = _filename[0 .. $ - 4];
            if (exists(kernFile ~ ".afm")) {
        		kernFile ~= ".afm";
            } else if (exists(kernFile ~ ".pfm" )) {
        		kernFile ~= ".pfm";
        	} else {
        		kernFile.clear();
        	}
        	if (kernFile.length > 0)
        		error = FT_Attach_File(_face, kernFile.toStringz);
        }
        Log.d("Font file opened successfully");
        _slot = _face.glyph;
        _faceName = familyName(_face);
        error = FT_Set_Pixel_Sizes(
                _face,    /* handle to face object */
                0,        /* pixel_width           */
                size );  /* pixel_height          */
        if (error) {
            clear();
            return false;
        }
        _height = _face.size.metrics.height >> 6;
        _size = size;
        _baseline = _height + (_face.size.metrics.descender >> 6);
        _weight = _face.style_flags & FT_STYLE_FLAG_BOLD ? FontWeight.Bold : FontWeight.Normal;
        _italic = _face.style_flags & FT_STYLE_FLAG_ITALIC ? true : false;
        Log.d("Opened font face=", _faceName, " height=", _height, " size=", size, " weight=", weight, " italic=", italic);
        return true; // successfully opened
    }

    @property bool isNull() {
        return (_face is null);
    }

    void clear() {
        if (_face !is null)
            FT_Done_Face(_face);
        _face = null;
    }

    ~this() {
        clear();
    }
}

/// FreeType based font manager.
class FreeTypeFontManager : FontManager {

    private FT_Library    _library;
    private FontFileItem[] _fontFiles;

    private FontFileItem findFileItem(ref FontDef def) {
        foreach(FontFileItem item; _fontFiles)
            if (item.def == def)
                return item;
        return null;
    }

	private FontList _activeFonts;

    private static FontRef _nullFontRef;

    this() {
        // load dynaic library
        DerelictFT.load();
        // init library
        int error = FT_Init_FreeType(&_library);
        if (error) {
            Log.e("Cannot init freetype library, error=", error);
            throw new Exception("Cannot init freetype library");
        }
    }
    ~this() {
        // uninit library
        if (_library)
            FT_Done_FreeType(_library);
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
        if (!exists(filename) || !isFile(filename))
            return false;

        FreeTypeFontFile font = new FreeTypeFontFile(_library, filename);
        if (!font.open(24)) {
            Log.e("Failed to open font ", filename);
            destroy(font);
            return false;
        }
        
        if (face == null || weight == 0) {
            // properties are not set by caller
            // get properties from loaded font
            face = font.face;
            italic = font.italic;
            weight = font.weight;
            Log.d("Using properties from font file: face=", face, " weight=", weight, " italic=", italic);
        }

        FontDef def = FontDef(family, face, italic, weight);
        FontFileItem item = findFileItem(def);
        if (item is null) {
            item = new FontFileItem(def);
            _fontFiles ~= item;
        }
        item.addFile(filename);

        // registered
        return true;
    }

}
