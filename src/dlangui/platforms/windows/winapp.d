module dlangui.platforms.windows.winapp;

version (Windows) {

import core.runtime;
import win32.windows;
import std.string;
import std.utf;
import std.stdio;
import std.algorithm;
import dlangui.platforms.common.platform;
import dlangui.graphics.drawbuf;
import dlangui.graphics.fonts;
import dlangui.core.logger;

pragma(lib, "gdi32.lib");
pragma(lib, "user32.lib");

struct FontDef {
    immutable FontFamily _family;
    immutable string _face;
	immutable ubyte _pitchAndFamily;
	@property FontFamily family() { return _family; }
	@property string face() { return _face; }
	@property ubyte pitchAndFamily() { return _pitchAndFamily; }
	this(FontFamily family, string face, ubyte putchAndFamily) {
		_family = family;
		_face = face;
		_pitchAndFamily = pitchAndFamily;
	}
}

/**
* Font implementation based on Win32 API system fonts.
*/
class Win32Font : Font {
    HFONT _hfont;
    int _size;
    int _height;
    int _weight;
    int _baseline;
    bool _italic;
    string _face;
    FontFamily _family;
    LOGFONTA _logfont;
    Win32ColorDrawBuf _drawbuf;
	GlyphCache _glyphCache;

	/// need to call create() after construction to initialize font
    this() {
    }

	/// do cleanup
	~this() {
		clear();
	}

	/// cleanup resources
    override void clear() {
        if (_hfont !is null)
        {
            DeleteObject(_hfont);
            _hfont = NULL;
            _height = 0;
            _baseline = 0;
            _size = 0;
        }
		if (_drawbuf !is null) {
			destroy(_drawbuf);
			_drawbuf = null;
		}
    }

	uint getGlyphIndex(dchar code)
	{
		if (_drawbuf is null)
			return 0;
		wchar[2] s;
		wchar[2] g;
		s[0] = cast(wchar)code;
		s[1] = 0;
		g[0] = 0;
		GCP_RESULTSW gcp;
		gcp.lStructSize = GCP_RESULTSW.sizeof;
		gcp.lpOutString = null;
		gcp.lpOrder = null;
		gcp.lpDx = null;
		gcp.lpCaretPos = null;
		gcp.lpClass = null;
		gcp.lpGlyphs = g.ptr;
		gcp.nGlyphs = 2;
		gcp.nMaxFit = 2;

		DWORD res = GetCharacterPlacementW(
						_drawbuf.dc, s.ptr, 1,
						1000,
						&gcp,
						0
						);
		if (!res)
			return 0;
		return g[0];
	}

	override Glyph * getCharGlyph(dchar ch) {
		uint glyphIndex = getGlyphIndex(ch);
		if (!glyphIndex)
			return null;
		if (glyphIndex >= 0xFFFF)
			return null;
		Glyph * found = _glyphCache.find(cast(ushort)glyphIndex);
		if (found !is null)
			return found;
		GLYPHMETRICS metrics;

		MAT2 identity = { {0,1}, {0,0}, {0,0}, {0,1} };
		uint res;
		res = GetGlyphOutlineW( _drawbuf.dc, cast(wchar)ch,
							GGO_METRICS,
							&metrics,
							0,
							null,
						    &identity );
		if (res==GDI_ERROR)
			return null;
		int gs = GetGlyphOutlineW( _drawbuf.dc, cast(wchar)ch,
								  GGO_GRAY8_BITMAP, //GGO_METRICS
								  &metrics,
								  0,
								  NULL,
								  &identity );
		if (gs >= 0x10000 || gs < 0)
			return null;

		Glyph g;
		g.blackBoxX = cast(ubyte)metrics.gmBlackBoxX;
		g.blackBoxY = cast(ubyte)metrics.gmBlackBoxY;
		g.originX = cast(byte)metrics.gmptGlyphOrigin.x;
		g.originY = cast(byte)metrics.gmptGlyphOrigin.y;
		g.width = cast(ubyte)metrics.gmCellIncX;
		g.glyphIndex = cast(ushort)glyphIndex;

		if (g.blackBoxX>0 && g.blackBoxY>0)
		{
			g.glyph = new ubyte[g.blackBoxX * g.blackBoxY];
			if (gs>0)
			{
				ubyte glyph[] = new ubyte[gs];
				res = GetGlyphOutlineW( _drawbuf.dc, cast(wchar)ch,
									   GGO_GRAY8_BITMAP, //GGO_METRICS
									   &metrics,
									   gs,
									   glyph.ptr,
									   &identity );
				if (res==GDI_ERROR)
				{
					return null;
				}
				int glyph_row_size = (g.blackBoxX + 3) / 4 * 4;
				ubyte * src = glyph.ptr;
				ubyte * dst = g.glyph.ptr;
				for (int y = 0; y < g.blackBoxY; y++)
				{
					for (int x = 0; x < g.blackBoxX; x++)
					{
						ubyte b = src[x];
						if (b>=64)
							b = 63;
						b = (b<<2) & 0xFC;
						dst[x] = b;
					}
					src += glyph_row_size;
					dst += g.blackBoxX;
				}
			}
			else
			{
				// empty glyph
				for (int i = g.blackBoxX * g.blackBoxY - 1; i >= 0; i--)
					g.glyph[i] = 0;
			}
		}
		// found!
		return _glyphCache.put(cast(ushort)glyphIndex, &g);
	}

	// draw text string to buffer
	override void drawText(DrawBuf buf, int x, int y, const dchar[] text, uint color) {
		int[] widths;
		int charsMeasured = measureText(text, widths, 3000);
		for (int i = 0; i < charsMeasured; i++) {
			int xx = (i > 0) ? widths[i - 1] : 0;
			Glyph * glyph = getCharGlyph(text[i]);
			if (glyph is null)
				continue;
			if ( glyph.blackBoxX && glyph.blackBoxY ) {
				buf.drawGlyph( x + xx + glyph.originX,
						   y + _baseline - glyph.originY,
						  glyph.glyph,
						  glyph.blackBoxX,
						  glyph.blackBoxY,
						  color);
			}
		}
	}

	override int measureText(const dchar[] text, ref int[] widths, int maxWidth) {
		if (_hfont is null || _drawbuf is null || text.length == 0)
			return 0;
		wstring utf16text = toUTF16(text);
		const wchar * pstr = utf16text.ptr;
		uint len = cast(uint)utf16text.length;
		GCP_RESULTSW gcpres;
		gcpres.lStructSize = gcpres.sizeof;
		if (widths.length < len + 1)
			widths.length = len + 1;
		gcpres.lpDx = widths.ptr;
		gcpres.nMaxFit = len;
		gcpres.nGlyphs = len;
		uint res = GetCharacterPlacementW( 
											 _drawbuf.dc,
											 pstr,
											 len,
											 maxWidth,
											 &gcpres,
											 GCP_MAXEXTENT); //|GCP_USEKERNING
		if (!res) {
			widths[0] = 0;
			return 0;
		}
		uint measured = gcpres.nMaxFit;
		int total = 0;
		for (int i = 0; i < measured; i++) {
			int w = widths[i];
			total += w;
			widths[i] = total;
		}
		return measured;
	}

	bool create(FontDef * def, int size, int weight, bool italic) {
        if (!isNull())
            clear();
		LOGFONTA lf;
        lf.lfCharSet = ANSI_CHARSET; //DEFAULT_CHARSET;
		lf.lfFaceName[0..def.face.length] = def.face;
		lf.lfFaceName[def.face.length] = 0;
		lf.lfHeight = -size;
		lf.lfItalic = italic;
		lf.lfOutPrecision = OUT_TT_ONLY_PRECIS;
		lf.lfClipPrecision = CLIP_DEFAULT_PRECIS;
		lf.lfQuality = ANTIALIASED_QUALITY;
		lf.lfPitchAndFamily = def.pitchAndFamily;
        _hfont = CreateFontIndirectA(&lf);
        _drawbuf = new Win32ColorDrawBuf(1, 1);
        SelectObject(_drawbuf.dc, _hfont);

        TEXTMETRICW tm;
        GetTextMetricsW(_drawbuf.dc, &tm);

		_size = size;
        _height = tm.tmHeight;
        _baseline = _height - tm.tmDescent;
        _weight = weight;
        _italic = italic;
        _face = def.face;
        _family = def.family;
		Log.d("Created font ", _face, " ", _size);
		return true;
	}

	// clear usage flags for all entries
	override void checkpoint() {
		_glyphCache.checkpoint();
	}

	// removes entries not used after last call of checkpoint() or cleanup()
	override void cleanup() {
		_glyphCache.cleanup();
	}

    @property override int size() { return _size; }
    @property override int height() { return _height; }
    @property override int weight() { return _weight; }
    @property override int baseline() { return _baseline; }
    @property override bool italic() { return _italic; }
    @property override string face() { return _face; }
    @property override FontFamily family() { return _family; }
    @property override bool isNull() { return _hfont is null; }
}


/**
 * Font manager implementation based on Win32 API system fonts.
 */
class Win32FontManager : FontManager {
	FontList _activeFonts;
	FontDef[] _fontFaces;
	FontDef*[string] _faceByName;

	/// initialize in constructor
    this() {
        instance = this;
        init();
    }

	/// initialize font manager by enumerating of system fonts
    bool init() {
		Log.i("Win32FontManager.init()");
        Win32ColorDrawBuf drawbuf = new Win32ColorDrawBuf(1,1);
        LOGFONTA lf;
        lf.lfCharSet = ANSI_CHARSET; //DEFAULT_CHARSET;
		lf.lfFaceName[0] = 0;
		HDC dc = drawbuf.dc;
        int res = 
            EnumFontFamiliesExA(
                                dc,                  // handle to DC
                                &lf,                              // font information
                                &LVWin32FontEnumFontFamExProc, // callback function (FONTENUMPROC)
                                cast(LPARAM)(cast(void*)this),                    // additional data
                                0U                     // not used; must be 0
                                    );
		destroy(drawbuf);
		Log.i("Found ", _fontFaces.length, " font faces");
        return res!=0;
    }

	/// for returning of not found font
	FontRef _emptyFontRef;

	/// get font by properties
    override ref FontRef getFont(int size, int weight, bool italic, FontFamily family, string face) {
		Log.i("getFont()");
		FontDef * def = findFace(family, face);
		if (def !is null) {
			int index = _activeFonts.find(size, weight, italic, def.family, def.face);
			if (index >= 0)
				return _activeFonts.get(index);
			Log.d("Creating new font");
			Win32Font item = new Win32Font();
			if (!item.create(def, size, weight, italic))
				return _emptyFontRef;
			Log.d("Adding to list of active fonts");
			return _activeFonts.add(item);
		} else {
			return _emptyFontRef;
		}
    }

	/// find font face definition by family only (try to get one of defaults for family if possible)
	FontDef * findFace(FontFamily family) {
		FontDef * res = null;
		switch(family) {
		case FontFamily.SansSerif:
			res = findFace("Arial"); if (res !is null) return res;
			res = findFace("Tahoma"); if (res !is null) return res;
			res = findFace("Calibri"); if (res !is null) return res;
			res = findFace("Verdana"); if (res !is null) return res;
			res = findFace("Lucida Sans"); if (res !is null) return res;
			break;
		case FontFamily.Serif:
			res = findFace("Times New Roman"); if (res !is null) return res;
			res = findFace("Georgia"); if (res !is null) return res;
			res = findFace("Century Schoolbook"); if (res !is null) return res;
			res = findFace("Bookman Old Style"); if (res !is null) return res;
			break;
		case FontFamily.MonoSpace:
			res = findFace("Courier New"); if (res !is null) return res;
			res = findFace("Lucida Console"); if (res !is null) return res;
			res = findFace("Century Schoolbook"); if (res !is null) return res;
			res = findFace("Bookman Old Style"); if (res !is null) return res;
			break;
		case FontFamily.Cursive:
			res = findFace("Comic Sans MS"); if (res !is null) return res;
			res = findFace("Lucida Handwriting"); if (res !is null) return res;
			res = findFace("Monotype Corsiva"); if (res !is null) return res;
			break;
		default:
			break;
		}
		return null;
	}

	/// find font face definition by face only
	FontDef * findFace(string face) {
		if (face.length == 0)
			return null;
		if (face in _faceByName)
			return _faceByName[face];
		return null;
	}

	/// find font face definition by family and face
	FontDef * findFace(FontFamily family, string face) {
		// by face only
		FontDef * res = findFace(face);
		if (res !is null)
			return res;
		// best for family
		res = findFace(family);
		if (res !is null)
			return res;
		for (int i = 0; i < _fontFaces.length; i++) {
			res = &_fontFaces[i];
			if (res.family == family)
				return res;
		}
		res = findFace(FontFamily.SansSerif);
		if (res !is null)
			return res;
		return &_fontFaces[0];
	}

	/// register enumerated font
    bool registerFont(FontFamily family, string fontFace, ubyte pitchAndFamily) {
		Log.d("registerFont(", family, ",", fontFace, ")");
		_fontFaces ~= FontDef(family, fontFace, pitchAndFamily);
		_faceByName[fontFace] = &_fontFaces[$ - 1];
        return true;
    }

	/// clear usage flags for all entries
	override void checkpoint() {
		_activeFonts.checkpoint();
	}

	/// removes entries not used after last call of checkpoint() or cleanup()
	override void cleanup() {
		_activeFonts.cleanup();
		//_list.cleanup();
	}
}

string fromStringz(const(char[]) s) {
	int i = 0;
	while(s[i])
		i++;
	return cast(string)(s[0..i].dup);
}

FontFamily pitchAndFamilyToFontFamily(ubyte flags) {
	if ((flags & FF_DECORATIVE) == FF_DECORATIVE)
		return FontFamily.Fantasy;
	else if ((flags & (FIXED_PITCH)) != 0) // | | MONO_FONT
		return FontFamily.MonoSpace;
	else if ((flags & (FF_ROMAN)) != 0)
		return FontFamily.Serif;
	else if ((flags & (FF_SCRIPT)) != 0)
		return FontFamily.Cursive;
	return FontFamily.SansSerif;
}

// definition
extern(Windows) {
    int LVWin32FontEnumFontFamExProc(
            const (LOGFONTA) *lf,    // logical-font data
            const (TEXTMETRICA) *lpntme,  // physical-font data
            //ENUMLOGFONTEX *lpelfe,    // logical-font data
            //NEWTEXTMETRICEX *lpntme,  // physical-font data
            DWORD fontType,           // type of font
            LPARAM lParam             // application-defined data
                )
    {
        //
		//Log.d("LVWin32FontEnumFontFamExProc fontType=", fontType);
        if (fontType == TRUETYPE_FONTTYPE)
        {
            void * p = cast(void*)lParam;
            Win32FontManager fontman = cast(Win32FontManager)p;
			string face = fromStringz(lf.lfFaceName);
			FontFamily family = pitchAndFamilyToFontFamily(lf.lfPitchAndFamily);
			if (face.length < 2 || face[0] == '@')
				return 1;
			//Log.d("face:", face);
			fontman.registerFont(family, face, lf.lfPitchAndFamily);
        }
        return 1;
    }
}

extern (C) int UIAppMain();

immutable WIN_CLASS_NAME = "DLANGUI_APP";

__gshared HINSTANCE _hInstance;
__gshared int _cmdShow;

class Win32Window : Window {
    private HWND _hwnd;
    string _caption;
    Win32ColorDrawBuf _drawbuf;
    this(string windowCaption, Window parent) {
        _caption = windowCaption;
        _hwnd = CreateWindow(toUTF16z(WIN_CLASS_NAME),      // window class name
                            toUTF16z(windowCaption),  // window caption
                            WS_OVERLAPPEDWINDOW,  // window style
                            CW_USEDEFAULT,        // initial x position
                            CW_USEDEFAULT,        // initial y position
                            CW_USEDEFAULT,        // initial x size
                            CW_USEDEFAULT,        // initial y size
                            null,                 // parent window handle
                            null,                 // window menu handle
                            _hInstance,           // program instance handle
                            cast(void*)this);                // creation parameters
    }
    Win32ColorDrawBuf getDrawBuf() {
        RECT rect;
        GetClientRect(_hwnd, &rect);
        int dx = rect.right - rect.left;
        int dy = rect.bottom - rect.top;
        if (_drawbuf is null)
            _drawbuf = new Win32ColorDrawBuf(dx, dy);
        else 
            _drawbuf.resize(dx, dy);
        return _drawbuf;
    }
    override void show() {
        ShowWindow(_hwnd, _cmdShow);
        UpdateWindow(_hwnd);
    }
    override @property string windowCaption() {
        return _caption;
    }
    override @property void windowCaption(string caption) {
        _caption = caption;
        SetWindowTextW(_hwnd, toUTF16z(_caption));
    }
    void onCreate() {
        writeln("Window onCreate");
    }
    void onDestroy() {
        writeln("Window onDestroy");
    }
}

class Win32Platform : Platform {
    this() {
    }
    bool registerWndClass() {
        //MSG  msg;
        WNDCLASS wndclass;

        wndclass.style         = CS_HREDRAW | CS_VREDRAW;
        wndclass.lpfnWndProc   = &WndProc;
        wndclass.cbClsExtra    = 0;
        wndclass.cbWndExtra    = 0;
        wndclass.hInstance     = _hInstance;
        wndclass.hIcon         = LoadIcon(null, IDI_APPLICATION);
        wndclass.hCursor       = LoadCursor(null, IDC_ARROW);
        wndclass.hbrBackground = cast(HBRUSH)GetStockObject(WHITE_BRUSH);
        wndclass.lpszMenuName  = null;
        wndclass.lpszClassName = toUTF16z(WIN_CLASS_NAME);

        if(!RegisterClass(&wndclass))
        {
            return false;
        }
        return true;
    }
    override int enterMessageLoop() {
        MSG  msg;
        while (GetMessage(&msg, null, 0, 0))
        {
            TranslateMessage(&msg);
            DispatchMessage(&msg);
        }
        return msg.wParam;
    }
    override Window createWindow(string windowCaption, Window parent) {
        return new Win32Window(windowCaption, parent);
    }
}

auto toUTF16z(S)(S s)
{
    return toUTFz!(const(wchar)*)(s);
}

extern (Windows)
int WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance,
            LPSTR lpCmdLine, int nCmdShow)
{
    int result;

    void exceptionHandler(Throwable e) {
        throw e;
    }

    try
    {
        Runtime.initialize(&exceptionHandler);
        result = myWinMain(hInstance, hPrevInstance, lpCmdLine, nCmdShow);
        Runtime.terminate(&exceptionHandler);
    }
    catch (Throwable e) // catch any uncaught exceptions
    {
        MessageBox(null, toUTF16z(e.toString()), "Error",
                   MB_OK | MB_ICONEXCLAMATION);
        result = 0;     // failed
    }

    return result;
}

int myWinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int iCmdShow)
{
	setFileLogger(std.stdio.File("ui.log", "w"));
	setLogLevel(LogLevel.Trace);

    _cmdShow = iCmdShow;
    _hInstance = hInstance;
    Log.d("Inside myWinMain");
    string appName = "HelloWin";


    Win32Platform platform = new Win32Platform();
    if (!platform.registerWndClass()) {
        MessageBoxA(null, "This program requires Windows NT!", appName.toStringz, MB_ICONERROR);
        return 0;
    }
    Platform.setInstance(platform);
	Win32FontManager fontMan = new Win32FontManager();
	FontManager.instance = fontMan;
    return UIAppMain();
}

class Win32ColorDrawBuf : ColorDrawBufBase {
    uint * _pixels;
    HDC _drawdc;
    HBITMAP _drawbmp;
    @property HDC dc() { return _drawdc; }
    this(int width, int height) {
        resize(width, height);
    }
    override uint * scanLine(int y) {
        if (y >= 0 && y < _dy)
            return _pixels + _dx * (_dy - 1 - y);
        return null;
    }
    override void clear() {
        if (_drawbmp !is null) {
            DeleteObject( _drawbmp );
            DeleteObject( _drawdc );
            _pixels = null;
            _dx = 0;
            _dy = 0;
        }
    }
    override void resize(int width, int height) {
        if (width< 0)
            width = 0;
        if (height < 0)
            height = 0;
        if (_dx == width && _dy == height)
            return;
        clear();
        _dx = width;
        _dy = height;
        if (_dx > 0 && _dy > 0) {
            BITMAPINFO bmi;
            //memset( &bmi, 0, sizeof(bmi) );
            bmi.bmiHeader.biSize = (bmi.bmiHeader.sizeof);
            bmi.bmiHeader.biWidth = _dx;
            bmi.bmiHeader.biHeight = _dy;
            bmi.bmiHeader.biPlanes = 1;
            bmi.bmiHeader.biBitCount = 32;
            bmi.bmiHeader.biCompression = BI_RGB;
            bmi.bmiHeader.biSizeImage = 0;
            bmi.bmiHeader.biXPelsPerMeter = 1024;
            bmi.bmiHeader.biYPelsPerMeter = 1024;
            bmi.bmiHeader.biClrUsed = 0;
            bmi.bmiHeader.biClrImportant = 0;
            _drawbmp = CreateDIBSection( NULL, &bmi, DIB_RGB_COLORS, cast(void**)(&_pixels), NULL, 0 );
            _drawdc = CreateCompatibleDC(NULL);
            SelectObject(_drawdc, _drawbmp);
        }
    }
    override void fill(uint color) {
        int len = _dx * _dy;
        for (int i = 0; i < len; i++)
            _pixels[i] = color;
    }
    void drawTo(HDC dc, int x, int y) {
        BitBlt(dc, x, y, _dx, _dx, _drawdc, 0, 0, SRCCOPY);
    }
}

//void drawBuf2DC(HDC dc, int x, int y, DrawBuf buf)
//{
//    uint * drawpixels;
//    HDC drawdc;
//    HBITMAP drawbmp;
//
//    int buf_width = buf.width();
//    int bytesPerRow = buf_width * 4;
//    BITMAPINFO bmi;
//    //memset( &bmi, 0, sizeof(bmi) );
//    bmi.bmiHeader.biSize = (bmi.bmiHeader.sizeof);
//    bmi.bmiHeader.biWidth = buf_width;
//    bmi.bmiHeader.biHeight = buf.height;
//    bmi.bmiHeader.biPlanes = 1;
//    bmi.bmiHeader.biBitCount = 32;
//    bmi.bmiHeader.biCompression = BI_RGB;
//    bmi.bmiHeader.biSizeImage = 0;
//    bmi.bmiHeader.biXPelsPerMeter = 1024;
//    bmi.bmiHeader.biYPelsPerMeter = 1024;
//    bmi.bmiHeader.biClrUsed = 0;
//    bmi.bmiHeader.biClrImportant = 0;
//    drawbmp = CreateDIBSection( NULL, &bmi, DIB_RGB_COLORS, cast(void**)(&drawpixels), NULL, 0 );
//    drawdc = CreateCompatibleDC(NULL);
//    SelectObject(drawdc, drawbmp);
//    for (int yy=0; yy < buf.height; yy++)
//    {
//        uint * src = buf.scanLine(yy);
//        uint * dst = drawpixels + (buf.height - 1 - yy) * buf.width;
//        for (int xx = 0; xx < buf_width; xx++)
//            dst[xx] = src[xx];
//    }
//    BitBlt( dc, x, y, buf_width, buf.height, drawdc, 0, 0, SRCCOPY);
//    DeleteObject( drawbmp );
//    DeleteObject( drawdc );
//}


extern(Windows)
LRESULT WndProc(HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam)
{
    HDC hdc;
    PAINTSTRUCT ps;
    RECT rect;
    void * p = cast(void*)GetWindowLongPtr(hwnd, GWLP_USERDATA);
    Win32Window window = p is null ? null : cast(Win32Window)(p);
    switch (message)
    {
        case WM_CREATE:
            {
                CREATESTRUCT * pcreateStruct = cast(CREATESTRUCT*)lParam;
                window = cast(Win32Window)pcreateStruct.lpCreateParams;
                void * ptr = cast(void*) window;
                SetWindowLongPtr(hwnd, GWLP_USERDATA, cast(LONG_PTR)ptr);
                window.onCreate();
            }
            //PlaySoundA("hellowin.wav", NULL, SND_FILENAME | SND_ASYNC);
            return 0;
        case WM_WINDOWPOSCHANGED:
            {
                WINDOWPOS * pos = cast(WINDOWPOS*)lParam;
                window.onResize(pos.cx, pos.cy);
            }
            return 0;

        case WM_PAINT:
            {
                hdc = BeginPaint(hwnd, &ps);
                Win32ColorDrawBuf buf = window.getDrawBuf();
                buf.fill(0x808080);
                window.onDraw(buf);
                buf.drawTo(hdc, 0, 0);
                //drawBuf2DC(hdc, 0, 0, buf);
                scope(exit) EndPaint(hwnd, &ps);
            }
            //DrawTextA(hdc, "Hello, Windows!", -1, &rect, DT_SINGLELINE | DT_CENTER | DT_VCENTER);
            return 0;

        case WM_DESTROY:
            window.onDestroy();
            PostQuitMessage(0);
            return 0;

        default:
    }

    return DefWindowProc(hwnd, message, wParam, lParam);
}

//===========================================
// end of version(Windows)
//===========================================
} 
