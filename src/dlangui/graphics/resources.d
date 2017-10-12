// Written in the D programming language.

/**
This module contains resource management and drawables implementation.

imageCache is RAM cache of decoded images (as DrawBuf).

drawableCache is cache of Drawables.

Supports nine-patch PNG images in .9.png files (like in Android).

Supports state drawables using XML files similar to ones in Android.



When your application uses custom resources, you can embed resources into executable and/or specify external resource directory(s).

To embed resources, put them into views/res directory, and create file views/resources.list with list of all files to embed.

Use following code to embed resources:

----
/// entry point for dlangui based application
extern (C) int UIAppMain(string[] args) {

    // embed non-standard resources listed in views/resources.list into executable
    embeddedResourceList.addResources(embedResourcesFromList!("resources.list")());

    ...
----

Resource list resources.list file may look similar to following:

----
res/i18n/en.ini
res/i18n/ru.ini
res/mdpi/cr3_logo.png
res/mdpi/document-open.png
res/mdpi/document-properties.png
res/mdpi/document-save.png
res/mdpi/edit-copy.png
res/mdpi/edit-paste.png
res/mdpi/edit-undo.png
res/mdpi/tx_fabric.jpg
res/theme_custom1.xml
----

As well you can specify list of external directories to get resources from.

----

/// entry point for dlangui based application
extern (C) int UIAppMain(string[] args) {
    // resource directory search paths
    string[] resourceDirs = [
        appendPath(exePath, "../../../res/"),   // for Visual D and DUB builds
        appendPath(exePath, "../../../res/mdpi/"),   // for Visual D and DUB builds
        appendPath(exePath, "../../../../res/"),// for Mono-D builds
        appendPath(exePath, "../../../../res/mdpi/"),// for Mono-D builds
        appendPath(exePath, "res/"), // when res dir is located at the same directory as executable
        appendPath(exePath, "../res/"), // when res dir is located at project directory
        appendPath(exePath, "../../res/"), // when res dir is located at the same directory as executable
        appendPath(exePath, "res/mdpi/"), // when res dir is located at the same directory as executable
        appendPath(exePath, "../res/mdpi/"), // when res dir is located at project directory
        appendPath(exePath, "../../res/mdpi/") // when res dir is located at the same directory as executable
    ];
    // setup resource directories - will use only existing directories
    Platform.instance.resourceDirs = resourceDirs;

----

When same file exists in both embedded and external resources, one from external resource directory will be used - it's useful for developing
and testing of resources.


Synopsis:

----
import dlangui.graphics.resources;

// embed non-standard resources listed in views/resources.list into executable
embeddedResourceList.addResources(embedResourcesFromList!("resources.list")());
----

Copyright: Vadim Lopatin, 2014
License:   Boost License 1.0
Authors:   Vadim Lopatin, coolreader.org@gmail.com

*/

module dlangui.graphics.resources;

import dlangui.core.config;

import dlangui.core.logger;
import dlangui.core.types;
static if (BACKEND_GUI) {
    import dlangui.graphics.images;
}
import dlangui.graphics.colors;
import dlangui.graphics.drawbuf;
import std.file;
import std.algorithm;
import std.xml;
import std.conv;
import std.string;
import std.path;

/// filename prefix for embedded resources
immutable string EMBEDDED_RESOURCE_PREFIX = "@embedded@/";

struct EmbeddedResource {
    immutable string name;
    immutable ubyte[] data;
    immutable string dir;
    this(immutable string name, immutable ubyte[] data, immutable string dir = null) {
        this.name = name;
        this.data = data;
        this.dir = dir;
    }
}

struct EmbeddedResourceList {
    private EmbeddedResource[] list;
    void addResources(EmbeddedResource[] resources) {
        list ~= resources;
    }
    void dumpEmbeddedResources() {
        foreach(r; list) {
            Log.d("EmbeddedResource: ", r.name);
        }
    }
    /// find by exact file name
    EmbeddedResource * find(string name) {
        // search backwards to allow overriding standard resources (which are added first)
        if (SCREEN_DPI > 110 && (name.endsWith(".png") || name.endsWith(".jpg") || name.endsWith(".jpeg"))) {
            // HIGH DPI resources are in /hdpi/ directory and started with hdpi_ prefix
            string prefixedName = "hdpi_" ~ name;
            for (int i = cast(int)list.length - 1; i >= 0; i--)
                if (prefixedName.equal(list[i].name)) {
                    Log.d("found hdpi resource ", prefixedName);
                    return &list[i];
                }
        }
        for (int i = cast(int)list.length - 1; i >= 0; i--)
            if (name.equal(list[i].name))
                return &list[i];
        return null;
    }
    /// find by name w/o extension
    EmbeddedResource * findAutoExtension(string name) {
        string xmlname = name ~ ".xml";
        string pngname = name ~ ".png";
        string png9name = name ~ ".9.png";
        string jpgname = name ~ ".jpg";
        string jpegname = name ~ ".jpeg";
        string xpmname = name ~ ".xpm";
        string timname = name ~ ".tim";
        // search backwards to allow overriding standard resources (which are added first)
        for (int i = cast(int)list.length - 1; i >= 0; i--) {
            string s = list[i].name;
            if (s.equal(name) || s.equal(xmlname) || s.equal(pngname) || s.equal(png9name)
                    || s.equal(jpgname) || s.equal(jpegname) || s.equal(xpmname) || s.equal(timname))
                return &list[i];
        }
        return null;
    }
}

__gshared EmbeddedResourceList embeddedResourceList;

//immutable string test_res = import("res/background.xml");
// Unfortunately, import with full pathes does not work on Windows
version = USE_FULL_PATH_FOR_RESOURCES;

string resDirName(string fullname) {
    immutable string step0 = fullname.dirName;
    immutable string step1 = step0.startsWith("res/") ? step0[4 .. $] : step0;
    return step1 == "." ? null : step1;
}

EmbeddedResource[] embedResource(string resourceName)() {
    static if (resourceName.startsWith("#")) {
        return [];
    } else {
        version (USE_FULL_PATH_FOR_RESOURCES) {
            immutable string name = resourceName;
        } else {
            immutable string name = baseName(resourceName);
        }
        static if (name.length > 0) {
            immutable ubyte[] data = cast(immutable ubyte[])import(name);
            immutable string resname = baseName(name);
            immutable string resdir = resDirName(name);
            static if (data.length > 0)
                return [EmbeddedResource(resname, data, resdir)];
            else
                return [];
        } else
            return [];
    }
}

/// embed all resources from list
EmbeddedResource[] embedResources(string[] resourceNames)() {
    static if (resourceNames.length == 0)
        return [];
    static if (resourceNames.length == 1)
        return embedResource!(resourceNames[0])();
    else
        return embedResources!(resourceNames[0 .. $/2])() ~ embedResources!(resourceNames[$/2 .. $])();
}

/// split string into lines, autodetect line endings
string[] splitLines(string s) {
    auto lines_crlf = split(s, "\r\n");
    auto lines_cr = split(s, "\r");
    auto lines_lf = split(s, "\n");
    if (lines_crlf.length >= lines_cr.length && lines_crlf.length >= lines_lf.length)
        return lines_crlf;
    if (lines_cr.length > lines_lf.length)
        return lines_cr;
    return lines_lf;
}

/// embed all resources from list
EmbeddedResource[] embedResourcesFromList(string resourceList)() {
    static if (BACKEND_CONSOLE) {
        return embedResources!(splitLines(import("console_" ~ resourceList)))();
    } else {
        return embedResources!(splitLines(import(resourceList)))();
    }
}


void embedStandardDlangUIResources() {
    version (EmbedStandardResources) {
        embeddedResourceList.addResources(embedResourcesFromList!("standard_resources.list")());
    }
}

/// load resource bytes from embedded resource or file
immutable(ubyte[]) loadResourceBytes(string filename) {
    if (filename.startsWith(EMBEDDED_RESOURCE_PREFIX)) {
        EmbeddedResource * embedded = embeddedResourceList.find(filename[EMBEDDED_RESOURCE_PREFIX.length .. $]);
        if (embedded)
            return embedded.data;
        return null;
    } else {
        try {
            immutable ubyte[] data = cast(immutable ubyte[])std.file.read(filename);
            return data;
        } catch (Exception e) {
            Log.e("exception while loading file ", filename);
            return null;
        }
    }
}

/// Base class for all drawables
class Drawable : RefCountedObject {
    debug static __gshared int _instanceCount;
    debug @property static int instanceCount() { return _instanceCount; }

    this() {
        debug ++_instanceCount;
        //Log.d("Created drawable, count=", ++_instanceCount);
    }
    ~this() {
        //Log.d("Destroyed drawable, count=", --_instanceCount);
        debug --_instanceCount;
    }
    abstract void drawTo(DrawBuf buf, Rect rc, uint state = 0, int tilex0 = 0, int tiley0 = 0);
    @property abstract int width();
    @property abstract int height();
    @property Rect padding() { return Rect(0,0,0,0); }
}

static if (ENABLE_OPENGL) {
    /// Custom drawing inside openGL
    class OpenGLDrawable : Drawable {

        private OpenGLDrawableDelegate _drawHandler;

        @property OpenGLDrawableDelegate drawHandler() { return _drawHandler; }
        @property OpenGLDrawable drawHandler(OpenGLDrawableDelegate handler) { _drawHandler = handler; return this; }

        this(OpenGLDrawableDelegate drawHandler = null) {
            _drawHandler = drawHandler;
        }

        void onDraw(Rect windowRect, Rect rc) {
            // either override this method or assign draw handler
            if (_drawHandler) {
                _drawHandler(windowRect, rc);
            }
        }

        override void drawTo(DrawBuf buf, Rect rc, uint state = 0, int tilex0 = 0, int tiley0 = 0) {
            buf.drawCustomOpenGLScene(rc, &onDraw);
        }

        override @property int width() {
            return 20; // dummy size
        }
        override @property int height() {
            return 20; // dummy size
        }
    }
}

class EmptyDrawable : Drawable {
    override void drawTo(DrawBuf buf, Rect rc, uint state = 0, int tilex0 = 0, int tiley0 = 0) {
    }
    @property override int width() { return 0; }
    @property override int height() { return 0; }
}

class SolidFillDrawable : Drawable {
    protected uint _color;
    this(uint color) {
        _color = color;
    }
    override void drawTo(DrawBuf buf, Rect rc, uint state = 0, int tilex0 = 0, int tiley0 = 0) {
        if (!_color.isFullyTransparentColor)
            buf.fillRect(rc, _color);
    }
    @property override int width() { return 1; }
    @property override int height() { return 1; }
}

class GradientDrawable : Drawable {
    protected uint _color1; // top left
    protected uint _color2; // bottom left
    protected uint _color3; // top right
    protected uint _color4; // bottom right
    this(uint angle, uint color1, uint color2) {
        // rotate a gradient; angle goes clockwise
        import std.math;
        float radians = angle * PI / 180;
        float c = cos(radians);
        float s = sin(radians);
        if (s >= 0) {
            if (c >= 0) {
                // 0-90 degrees
                _color1 = blendARGB(color1, color2, cast(uint)(255 * c));
                _color2 = color2;
                _color3 = color1;
                _color4 = blendARGB(color1, color2, cast(uint)(255 * s));
            } else {
                // 90-180 degrees
                _color1 = color2;
                _color2 = blendARGB(color1, color2, cast(uint)(255 * -c));
                _color3 = blendARGB(color1, color2, cast(uint)(255 * s));
                _color4 = color1;
            }
        } else {
            if (c < 0) {
                // 180-270 degrees
                _color1 = blendARGB(color1, color2, cast(uint)(255 * -s));
                _color2 = color1;
                _color3 = color2;
                _color4 = blendARGB(color1, color2, cast(uint)(255 * -c));
            } else {
                // 270-360 degrees
                _color1 = color1;
                _color2 = blendARGB(color1, color2, cast(uint)(255 * -s));
                _color3 = blendARGB(color1, color2, cast(uint)(255 * c));
                _color4 = color2;
            }
        }
    }
    override void drawTo(DrawBuf buf, Rect rc, uint state = 0, int tilex0 = 0, int tiley0 = 0) {
        buf.fillGradientRect(rc, _color1, _color2, _color3, _color4);
    }
    @property override int width() { return 1; }
    @property override int height() { return 1; }
}

/// solid borders (may be of different width) and, optionally, solid inner area
class FrameDrawable : Drawable {
    protected uint _frameColor;  // frame color
    protected Rect _frameWidths; // left, top, right, bottom border widths, in pixels
    protected uint _middleColor; // middle area color (may be transparent)
    this(uint frameColor, Rect borderWidths, uint innerAreaColor = 0xFFFFFFFF) {
        _frameColor = frameColor;
        _frameWidths = borderWidths;
        _middleColor = innerAreaColor;
    }
    this(uint frameColor, int borderWidth, uint innerAreaColor = 0xFFFFFFFF) {
        _frameColor = frameColor;
        _frameWidths = Rect(borderWidth, borderWidth, borderWidth, borderWidth);
        _middleColor = innerAreaColor;
    }
    override void drawTo(DrawBuf buf, Rect rc, uint state = 0, int tilex0 = 0, int tiley0 = 0) {
        buf.drawFrame(rc, _frameColor, _frameWidths, _middleColor);
    }
    @property override int width() { return 1 + _frameWidths.left + _frameWidths.right; }
    @property override int height() { return 1 + _frameWidths.top + _frameWidths.bottom; }
    @property override Rect padding() { return _frameWidths; }
}

enum DimensionUnits {
    pixels,
    points,
    percents
}

/// decode size string, e.g. 1px or 2 or 3pt
static uint decodeDimension(string s) {
    uint value = 0;
    DimensionUnits units = DimensionUnits.pixels;
    bool dotFound = false;
    uint afterPointValue = 0;
    uint afterPointDivider = 1;
    foreach(c; s) {
        int digit = -1;
        if (c >='0' && c <= '9')
            digit = c - '0';
        if (digit >= 0) {
            if (dotFound) {
                afterPointValue = afterPointValue * 10 + digit;
                afterPointDivider *= 10;
            } else {
                value = value * 10 + digit;
            }
        } else if (c == 't') // just test by containing 't' - for NNNpt
            units = DimensionUnits.points; // "pt"
        else if (c == '%')
            units = DimensionUnits.percents;
        else if (c == '.')
            dotFound = true;
    }
    // TODO: convert points to pixels
    switch(units) {
    case DimensionUnits.points:
        // need to convert points to pixels
        value |= SIZE_IN_POINTS_FLAG;
        break;
    case DimensionUnits.percents:
        // need to convert percents
        value = ((value * 100) + (afterPointValue * 100 / afterPointDivider)) | SIZE_IN_PERCENTS_FLAG;
        break;
    default:
        break;
    }
    return value;
}

/// decode angle; only Ndeg format for now
static uint decodeAngle(string s) {
    int angle;
    if (s.endsWith("deg"))
        angle = to!int(s[0 .. $ - 3]);
    else
        Log.e("Invalid angle format: ", s);

    // transform the angle to [0, 360)
    return ((angle % 360) + 360) % 360;
}

static if (BACKEND_CONSOLE) {
    /**
    Sample format:
    {
        text: [
            "╔═╗",
            "║ ║",
            "╚═╝"],
        backgroundColor: [0x000080], // put more values for individual colors of cells
        textColor: [0xFF0000], // put more values for individual colors of cells
        ninepatch: [1,1,1,1]
    }
    */
    static Drawable createTextDrawable(string s) {
        TextDrawable drawable = new TextDrawable(s);
        if (drawable.width == 0 || drawable.height == 0)
            return null;
        return drawable;
    }
}

/// decode solid color / gradient / frame drawable from string like #AARRGGBB, e.g. #5599AA
///
/// SolidFillDrawable: #AARRGGBB  - e.g. #8090A0 or #80ffffff
/// GradientDrawable: #linear,Ndeg,#firstColor,#secondColor
/// FrameDrawable: #frameColor,frameWidth[,#middleColor]
///             or #frameColor,leftBorderWidth,topBorderWidth,rightBorderWidth,bottomBorderWidth[,#middleColor]
///                e.g. #000000,2,#C0FFFFFF - black frame of width 2 with 75% transparent white middle
///                e.g. #0000FF,2,3,4,5,#FFFFFF - blue frame with left,top,right,bottom borders of width 2,3,4,5 and white inner area
static Drawable createColorDrawable(string s) {
    Log.d("creating color drawable ", s);

    enum DrawableType { SolidColor, LinearGradient, Frame }
    auto type = DrawableType.SolidColor;

    string[] items = s.split(',');
    uint[] values;
    foreach (i, item; items) {
        if (item == "#linear")
            type = DrawableType.LinearGradient;
        else if (item.startsWith("#"))
            values ~= decodeHexColor(item);
        else if (item.endsWith("deg"))
            values ~= decodeAngle(item);
        else {
            values ~= decodeDimension(item);
            type = DrawableType.Frame;
        }
        if (i >= 6)
            break;
    }

    if (type == DrawableType.SolidColor && values.length == 1) // only color #AARRGGBB
        return new SolidFillDrawable(values[0]);
    else if (type == DrawableType.LinearGradient && values.length == 3) // angle and two gradient colors
        return new GradientDrawable(values[0], values[1], values[2]);
    else if (type == DrawableType.Frame) {
        if (values.length == 2) // frame color and frame width, with transparent inner area - #AARRGGBB,NN
            return new FrameDrawable(values[0], values[1]);
        else if (values.length == 3) // frame color, frame width, inner area color - #AARRGGBB,NN,#AARRGGBB
            return new FrameDrawable(values[0], values[1], values[2]);
        else if (values.length == 5) // frame color, frame widths for left,top,right,bottom and transparent inner area - #AARRGGBB,NNleft,NNtop,NNright,NNbottom
            return new FrameDrawable(values[0], Rect(values[1], values[2], values[3], values[4]));
        else if (values.length == 6) // frame color, frame widths for left,top,right,bottom, inner area color - #AARRGGBB,NNleft,NNtop,NNright,NNbottom,#AARRGGBB
            return new FrameDrawable(values[0], Rect(values[1], values[2], values[3], values[4]), values[5]);
    }
    Log.e("Invalid drawable string format: ", s);
    return new EmptyDrawable(); // invalid format - just return empty drawable
}

static if (BACKEND_CONSOLE) {
    /**
        Text image drawable.
        Resource file extension: .tim
        Image format is JSON based. Sample:
                {
                    text: [
                       "╔═╗",
                       "║ ║",
                       "╚═╝"],
                    backgroundColor: [0x000080],
                    textColor: [0xFF0000],
                    ninepatch: [1,1,1,1]
                }

        Short form:

    {'╔═╗' '║ ║' '╚═╝' bc 0x000080 tc 0xFF0000 ninepatch 1 1 1 1}

    */
    class TextDrawable : Drawable {
        import dlangui.platforms.console.consoleapp : ConsoleDrawBuf;
        private int _width;
        private int _height;
        private dchar[] _text;
        private uint[] _bgColors;
        private uint[] _textColors;
        private Rect _padding;
        private Rect _ninePatch;
        private bool _tiled;
        private bool _stretched;
        private bool _hasNinePatch;
        this(int dx, int dy, dstring text, uint textColor, uint bgColor) {
            _width = dx;
            _height = dy;
            _text.assumeSafeAppend;
            for (int i = 0; i < text.length && i < dx * dy; i++)
                _text ~= text[i];
            for (int i = cast(int)_text.length; i < dx * dy; i++)
                _text ~= ' ';
            _textColors.assumeSafeAppend;
            _bgColors.assumeSafeAppend;
            for (int i = 0; i < dx * dy; i++) {
                _textColors ~= textColor;
                _bgColors ~= bgColor;
            }
        }
        this(string src) {
            import std.utf;
            this(toUTF32(src));
        }
        /**
           Create from text drawable source file format:
           {
            text:
           "text line 1"
           "text line 2"
           "text line 3"
           backgroundColor: 0xFFFFFF [,0xFFFFFF]*
           textColor: 0x000000, [,0x000000]*
           ninepatch: left,top,right,bottom
           padding: left,top,right,bottom
            }

           Text lines may be in "" or '' or `` quotes.
           bc can be used instead of backgroundColor, tc instead of textColor

           Sample short form:
           { 'line1' 'line2' 'line3' bc 0xFFFFFFFF tc 0x808080 stretch }
        */
        this(dstring src) {
            import dlangui.dml.tokenizer;
            import std.utf;
            Token[] tokens = tokenize(toUTF8(src), ["//"], true, true, true);
            dstring[] lines;
            enum Mode {
                None,
                Text,
                BackgroundColor,
                TextColor,
                Padding,
                NinePatch,
            }
            Mode mode = Mode.Text;
            uint[] bg;
            uint[] col;
            uint[] pad;
            uint[] nine;
            for (int i; i < tokens.length; i++) {
                if (tokens[i].type == TokenType.ident) {
                    if (tokens[i].text == "backgroundColor" || tokens[i].text == "bc")
                        mode = Mode.BackgroundColor;
                    else if (tokens[i].text == "textColor" || tokens[i].text == "tc")
                        mode = Mode.TextColor;
                    else if (tokens[i].text == "text")
                        mode = Mode.Text;
                    else if (tokens[i].text == "stretch")
                        _stretched = true;
                    else if (tokens[i].text == "tile")
                        _tiled = true;
                    else if (tokens[i].text == "padding") {
                        mode = Mode.Padding;
                    } else if (tokens[i].text == "ninepatch") {
                        _hasNinePatch = true;
                        mode = Mode.NinePatch;
                    } else
                        mode = Mode.None;
                } else if (tokens[i].type == TokenType.integer) {
                    switch(mode) {
                        case Mode.BackgroundColor: _bgColors ~= tokens[i].intvalue; break;
                        case Mode.TextColor:
                        case Mode.Text:
                            _textColors ~= tokens[i].intvalue; break;
                        case Mode.Padding: pad ~= tokens[i].intvalue; break;
                        case Mode.NinePatch: nine ~= tokens[i].intvalue; break;
                        default:
                            break;
                    }
                } else if (tokens[i].type == TokenType.str && mode == Mode.Text) {
                    dstring line = toUTF32(tokens[i].text);
                    lines ~= line;
                    if (_width < line.length)
                        _width = cast(int)line.length;
                }
            }
            // pad and convert text
            _height = cast(int)lines.length;
            if (!_height) {
                _width = 0;
                return;
            }
            for (int y = 0; y < _height; y++) {
                for (int x = 0; x < _width; x++) {
                    if (x < lines[y].length)
                        _text ~= lines[y][x];
                    else
                        _text ~= ' ';
                }
            }
            // pad padding and ninepatch
            for (int k = 1; k <= 4; k++) {
                if (nine.length < k)
                    nine ~= 0;
                if (pad.length < k)
                    pad ~= 0;
                //if (pad[k-1] < nine[k-1])
                //    pad[k-1] = nine[k-1];
            }
            _padding = Rect(pad[0], pad[1], pad[2], pad[3]);
            _ninePatch = Rect(nine[0], nine[1], nine[2], nine[3]);
            // pad colors
            for (int k = 1; k <= _width * _height; k++) {
                if (_textColors.length < k)
                    _textColors ~= _textColors.length ? _textColors[$ - 1] : 0;
                if (_bgColors.length < k)
                    _bgColors ~= _bgColors.length ? _bgColors[$ - 1] : 0xFFFFFFFF;
            }
        }
        @property override int width() {
            return _width;
        }
        @property override int height() {
            return _height;
        }
        @property override Rect padding() {
            return _padding;
        }

        protected void drawChar(ConsoleDrawBuf buf, int srcx, int srcy, int dstx, int dsty) {
            if (srcx < 0 || srcx >= _width || srcy < 0 || srcy >= _height)
                return;
            int index = srcy * _width + srcx;
            if (_textColors[index].isFullyTransparentColor && _bgColors[index].isFullyTransparentColor)
                return; // do not draw
            buf.drawChar(dstx, dsty, _text[index], _textColors[index], _bgColors[index]);
        }

        private static int wrapNinePatch(int v, int width, int ninewidth, int left, int right) {
            if (v < left)
                return v;
            if (v >= width - right)
                return v - (width - right) + (ninewidth - right);
            return left + (ninewidth - left - right) * (v - left) / (width - left - right);
        }

        override void drawTo(DrawBuf drawbuf, Rect rc, uint state = 0, int tilex0 = 0, int tiley0 = 0) {
            if (!_width || !_height)
                return; // empty image
            ConsoleDrawBuf buf = cast(ConsoleDrawBuf)drawbuf;
            if (!buf) // wrong draw buffer
                return;
            if (_hasNinePatch || _tiled || _stretched) {
                for (int y = 0; y < rc.height; y++) {
                    for (int x = 0; x < rc.width; x++) {
                        int srcx = wrapNinePatch(x, rc.width, _width, _ninePatch.left, _ninePatch.right);
                        int srcy = wrapNinePatch(y, rc.height, _height, _ninePatch.top, _ninePatch.bottom);
                        drawChar(buf, srcx, srcy, rc.left + x, rc.top + y);
                    }
                }
            } else {
                for (int y = 0; y < rc.height && y < _height; y++) {
                    for (int x = 0; x < rc.width && x < _width; x++) {
                        drawChar(buf, x, y, rc.left + x, rc.top + y);
                    }
                }
            }
            //buf.drawImage(rc.left, rc.top, _image);
        }
    }
}

class ImageDrawable : Drawable {
    protected DrawBufRef _image;
    protected bool _tiled;

    debug static __gshared int _instanceCount;
    debug @property static int instanceCount() { return _instanceCount; }

    this(ref DrawBufRef image, bool tiled = false, bool ninePatch = false) {
        _image = image;
        _tiled = tiled;
        if (ninePatch)
            _image.detectNinePatch();
        debug _instanceCount++;
        debug(resalloc) Log.d("Created ImageDrawable, count=", _instanceCount);
    }
    ~this() {
        _image.clear();
        debug _instanceCount--;
        debug(resalloc) Log.d("Destroyed ImageDrawable, count=", _instanceCount);
    }
    @property override int width() {
        if (_image.isNull)
            return 0;
        if (_image.hasNinePatch)
            return _image.width - 2;
        return _image.width;
    }
    @property override int height() {
        if (_image.isNull)
            return 0;
        if (_image.hasNinePatch)
            return _image.height - 2;
        return _image.height;
    }
    @property override Rect padding() {
        if (!_image.isNull && _image.hasNinePatch)
            return _image.ninePatch.padding;
        return Rect(0,0,0,0);
    }
    private static void correctFrameBounds(ref int n1, ref int n2, ref int n3, ref int n4) {
        if (n1 > n2) {
            //assert(n2 - n1 == n4 - n3);
            int middledist = (n1 + n2) / 2 - n1;
            n1 = n2 = n1 + middledist;
            n3 = n4 = n3 + middledist;
        }
    }
    override void drawTo(DrawBuf buf, Rect rc, uint state = 0, int tilex0 = 0, int tiley0 = 0) {
        if (_image.isNull)
            return;
        if (_image.hasNinePatch) {
            // draw nine patch
            const NinePatch * p = _image.ninePatch;
            //Log.d("drawing nine patch image with frame ", p.frame, " padding ", p.padding);
            int w = width;
            int h = height;
            Rect srcrect = Rect(1, 1, w + 1, h + 1);
            if (true) { //buf.applyClipping(dstrect, srcrect)) {
                int x0 = srcrect.left;
                int x1 = srcrect.left + p.frame.left;
                int x2 = srcrect.right - p.frame.right;
                int x3 = srcrect.right;
                int y0 = srcrect.top;
                int y1 = srcrect.top + p.frame.top;
                int y2 = srcrect.bottom - p.frame.bottom;
                int y3 = srcrect.bottom;
                int dstx0 = rc.left;
                int dstx1 = rc.left + p.frame.left;
                int dstx2 = rc.right - p.frame.right;
                int dstx3 = rc.right;
                int dsty0 = rc.top;
                int dsty1 = rc.top + p.frame.top;
                int dsty2 = rc.bottom - p.frame.bottom;
                int dsty3 = rc.bottom;
                //Log.d("x bounds: ", x0, ", ", x1, ", ", x2, ", ", x3, " dst ", dstx0, ", ", dstx1, ", ", dstx2, ", ", dstx3);
                //Log.d("y bounds: ", y0, ", ", y1, ", ", y2, ", ", y3, " dst ", dsty0, ", ", dsty1, ", ", dsty2, ", ", dsty3);

                correctFrameBounds(x1, x2, dstx1, dstx2);
                correctFrameBounds(y1, y2, dsty1, dsty2);

                //correctFrameBounds(x1, x2);
                //correctFrameBounds(y1, y2);
                //correctFrameBounds(dstx1, dstx2);
                //correctFrameBounds(dsty1, dsty2);
                if (y0 < y1 && dsty0 < dsty1) {
                    // top row
                    if (x0 < x1 && dstx0 < dstx1)
                        buf.drawFragment(dstx0, dsty0, _image.get, Rect(x0, y0, x1, y1)); // top left
                    if (x1 < x2 && dstx1 < dstx2)
                        buf.drawRescaled(Rect(dstx1, dsty0, dstx2, dsty1), _image.get, Rect(x1, y0, x2, y1)); // top center
                    if (x2 < x3 && dstx2 < dstx3)
                        buf.drawFragment(dstx2, dsty0, _image.get, Rect(x2, y0, x3, y1)); // top right
                }
                if (y1 < y2 && dsty1 < dsty2) {
                    // middle row
                    if (x0 < x1 && dstx0 < dstx1)
                        buf.drawRescaled(Rect(dstx0, dsty1, dstx1, dsty2), _image.get, Rect(x0, y1, x1, y2)); // middle center
                    if (x1 < x2 && dstx1 < dstx2)
                        buf.drawRescaled(Rect(dstx1, dsty1, dstx2, dsty2), _image.get, Rect(x1, y1, x2, y2)); // center
                    if (x2 < x3 && dstx2 < dstx3)
                        buf.drawRescaled(Rect(dstx2, dsty1, dstx3, dsty2), _image.get, Rect(x2, y1, x3, y2)); // middle center
                }
                if (y2 < y3 && dsty2 < dsty3) {
                    // bottom row
                    if (x0 < x1 && dstx0 < dstx1)
                        buf.drawFragment(dstx0, dsty2, _image.get, Rect(x0, y2, x1, y3)); // bottom left
                    if (x1 < x2 && dstx1 < dstx2)
                        buf.drawRescaled(Rect(dstx1, dsty2, dstx2, dsty3), _image.get, Rect(x1, y2, x2, y3)); // bottom center
                    if (x2 < x3 && dstx2 < dstx3)
                        buf.drawFragment(dstx2, dsty2, _image.get, Rect(x2, y2, x3, y3)); // bottom right
                }
            }
        } else if (_tiled) {
            // tiled
            int imgdx = _image.width;
            int imgdy = _image.height;
            tilex0 %= imgdx;
            if (tilex0 < 0)
                tilex0 += imgdx;
            tiley0 %= imgdy;
            if (tiley0 < 0)
                tiley0 += imgdy;
            int xx0 = rc.left;
            int yy0 = rc.top;
            if (tilex0)
                xx0 -= imgdx - tilex0;
            if (tiley0)
                yy0 -= imgdy - tiley0;
            for (int yy = yy0; yy < rc.bottom; yy += imgdy) {
                for (int xx = xx0; xx < rc.right; xx += imgdx) {
                    Rect dst = Rect(xx, yy, xx + imgdx, yy + imgdy);
                    Rect src = Rect(0, 0, imgdx, imgdy);
                    if (dst.intersects(rc)) {
                        Rect sr = src;
                        if (dst.right > rc.right)
                            sr.right -= dst.right - rc.right;
                        if (dst.bottom > rc.bottom)
                            sr.bottom -= dst.bottom - rc.bottom;
                        if (!sr.empty)
                            buf.drawFragment(dst.left, dst.top, _image.get, sr);
                    }
                }
            }
        } else {
            // rescaled or normal
            if (rc.width != _image.width || rc.height != _image.height)
                buf.drawRescaled(rc, _image.get, Rect(0, 0, _image.width, _image.height));
            else
                buf.drawImage(rc.left, rc.top, _image);
        }
    }
}

string attrValue(Element item, string attrname, string attrname2 = null) {
    if (attrname in item.tag.attr)
        return item.tag.attr[attrname];
    if (attrname2 && attrname2 in item.tag.attr)
        return item.tag.attr[attrname2];
    return null;
}

string attrValue(ref string[string] attr, string attrname, string attrname2 = null) {
    if (attrname in attr)
        return attr[attrname];
    if (attrname2 && attrname2 in attr)
        return attr[attrname2];
    return null;
}

void extractStateFlag(ref string[string] attr, string attrName, string attrName2, State state, ref uint stateMask, ref uint stateValue) {
    string value = attrValue(attr, attrName, attrName2);
    if (value !is null) {
        if (value.equal("true"))
            stateValue |= state;
        stateMask |= state;
    }
}

/// converts XML attribute name to State (see http://developer.android.com/guide/topics/resources/drawable-resource.html#StateList)
void extractStateFlags(ref string[string] attr, ref uint stateMask, ref uint stateValue) {
    extractStateFlag(attr, "state_pressed", "android:state_pressed", State.Pressed, stateMask, stateValue);
    extractStateFlag(attr, "state_focused", "android:state_focused", State.Focused, stateMask, stateValue);
    extractStateFlag(attr, "state_default", "android:state_default", State.Default, stateMask, stateValue);
    extractStateFlag(attr, "state_hovered", "android:state_hovered", State.Hovered, stateMask, stateValue);
    extractStateFlag(attr, "state_selected", "android:state_selected", State.Selected, stateMask, stateValue);
    extractStateFlag(attr, "state_checkable", "android:state_checkable", State.Checkable, stateMask, stateValue);
    extractStateFlag(attr, "state_checked", "android:state_checked", State.Checked, stateMask, stateValue);
    extractStateFlag(attr, "state_enabled", "android:state_enabled", State.Enabled, stateMask, stateValue);
    extractStateFlag(attr, "state_activated", "android:state_activated", State.Activated, stateMask, stateValue);
    extractStateFlag(attr, "state_window_focused", "android:state_window_focused", State.WindowFocused, stateMask, stateValue);
}

/*
sample:
(prefix android: is optional)

<?xml version="1.0" encoding="utf-8"?>
<selector xmlns:android="http://schemas.android.com/apk/res/android"
android:constantSize=["true" | "false"]
android:dither=["true" | "false"]
android:variablePadding=["true" | "false"] >
<item
android:drawable="@[package:]drawable/drawable_resource"
android:state_pressed=["true" | "false"]
android:state_focused=["true" | "false"]
android:state_hovered=["true" | "false"]
android:state_selected=["true" | "false"]
android:state_checkable=["true" | "false"]
android:state_checked=["true" | "false"]
android:state_enabled=["true" | "false"]
android:state_activated=["true" | "false"]
android:state_window_focused=["true" | "false"] />
</selector>
*/

/// Drawable which is drawn depending on state (see http://developer.android.com/guide/topics/resources/drawable-resource.html#StateList)
class StateDrawable : Drawable {

    static class StateItem {
        uint stateMask;
        uint stateValue;
        ColorTransform transform;
        DrawableRef drawable;
        @property bool matchState(uint state) {
            return (stateMask & state) == stateValue;
        }
    }
    // list of states
    protected StateItem[] _stateList;
    // max paddings for all states
    protected Rect _paddings;
    // max drawable size for all states
    protected Point _size;

    ~this() {
        foreach(ref item; _stateList)
            destroy(item);
        _stateList = null;
    }

    void addState(uint stateMask, uint stateValue, string resourceId, ref ColorTransform transform) {
        StateItem item = new StateItem();
        item.stateMask = stateMask;
        item.stateValue = stateValue;
        item.drawable = drawableCache.get(resourceId, transform);
        itemAdded(item);
    }

    void addState(uint stateMask, uint stateValue, DrawableRef drawable) {
        StateItem item = new StateItem();
        item.stateMask = stateMask;
        item.stateValue = stateValue;
        item.drawable = drawable;
        itemAdded(item);
    }

    private void itemAdded(StateItem item) {
        _stateList ~= item;
        if (!item.drawable.isNull) {
            if (_size.x < item.drawable.width)
                _size.x = item.drawable.width;
            if (_size.y < item.drawable.height)
                _size.y = item.drawable.height;
            _paddings.setMax(item.drawable.padding);
        }
    }

    /// parse 4 comma delimited integers
    static bool parseList4(T)(string value, ref T[4] items) {
        int index = 0;
        int p = 0;
        int start = 0;
        for (;p < value.length && index < 4; p++) {
            while (p < value.length && value[p] != ',')
                p++;
            if (p > start) {
                int end = p;
                string s = value[start .. end];
                items[index++] = to!T(s);
                start = p + 1;
            }
        }
        return index == 4;
    }
    private static uint colorTransformFromStringAdd(string value) {
        if (value is null)
            return COLOR_TRANSFORM_OFFSET_NONE;
        int [4]n;
        if (!parseList4(value, n))
            return COLOR_TRANSFORM_OFFSET_NONE;
        foreach (ref item; n) {
            item = item / 2 + 0x80;
            if (item < 0)
                item = 0;
            if (item > 0xFF)
                item = 0xFF;
        }
        return (n[0] << 24) | (n[1] << 16) | (n[2] << 8) | (n[3] << 0);
    }
    private static uint colorTransformFromStringMult(string value) {
        if (value is null)
            return COLOR_TRANSFORM_MULTIPLY_NONE;
        float[4] n;
        uint[4] nn;
        if (!parseList4!float(value, n))
            return COLOR_TRANSFORM_MULTIPLY_NONE;
        foreach(i; 0 .. 4) {
            int res = cast(int)(n[i] * 0x40);
            if (res < 0)
                res = 0;
            if (res > 0xFF)
                res = 0xFF;
            nn[i] = res;
        }
        return (nn[0] << 24) | (nn[1] << 16) | (nn[2] << 8) | (nn[3] << 0);
    }

    bool load(Element element) {
        foreach(item; element.elements) {
            if (item.tag.name.equal("item")) {
                string drawableId = attrValue(item, "drawable", "android:drawable");
                if (drawableId.startsWith("@drawable/"))
                    drawableId = drawableId[10 .. $];
                ColorTransform transform;
                transform.addBefore = colorTransformFromStringAdd(attrValue(item, "color_transform_add1", "android:transform_color_add1"));
                transform.multiply = colorTransformFromStringMult(attrValue(item, "color_transform_mul", "android:transform_color_mul"));
                transform.addAfter = colorTransformFromStringAdd(attrValue(item, "color_transform_add2", "android:transform_color_add2"));
                if (drawableId !is null) {
                    uint stateMask, stateValue;
                    extractStateFlags(item.tag.attr, stateMask, stateValue);
                    if (drawableId !is null) {
                        addState(stateMask, stateValue, drawableId, transform);
                    }
                }
            }
        }
        return _stateList.length > 0;
    }

    /// load from XML file
    bool load(string filename) {
        try {
            string s = cast(string)loadResourceBytes(filename);
            if (!s) {
                Log.e("Cannot read drawable resource from file ", filename);
                return false;
            }

            // Check for well-formedness
            //check(s);

            // Make a DOM tree
            auto doc = new Document(s);

            return load(doc);
        } catch (CheckException e) {
            Log.e("Invalid XML file ", filename);
            return false;
        }
    }

    override void drawTo(DrawBuf buf, Rect rc, uint state = 0, int tilex0 = 0, int tiley0 = 0) {
        foreach(ref item; _stateList)
            if (item.matchState(state)) {
                if (!item.drawable.isNull) {
                    item.drawable.drawTo(buf, rc, state, tilex0, tiley0);
                }
                return;
            }
    }

    @property override int width() {
        return _size.x;
    }
    @property override int height() {
        return _size.y;
    }
    @property override Rect padding() {
        return _paddings;
    }
}

alias DrawableRef = Ref!Drawable;




static if (BACKEND_GUI) {
/// decoded raster images cache (png, jpeg) -- access by filenames
class ImageCache {

    static class ImageCacheItem {
        string _filename;
        DrawBufRef _drawbuf;
        DrawBufRef[ColorTransform] _transformMap;

        bool _error; // flag to avoid loading of file if it has been failed once
        bool _used;
        this(string filename) {
            _filename = filename;
        }
        /// get normal image
        @property ref DrawBufRef get() {
            if (!_drawbuf.isNull || _error) {
                _used = true;
                return _drawbuf;
            }
            immutable ubyte[] data = loadResourceBytes(_filename);
            if (data) {
                _drawbuf = loadImage(data, _filename);
                if (_filename.endsWith(".9.png"))
                    _drawbuf.detectNinePatch();
                _used = true;
            }
            if (_drawbuf.isNull)
                _error = true;
            return _drawbuf;
        }
        /// get color transformed image
        @property ref DrawBufRef get(ref ColorTransform transform) {
            if (transform.empty)
                return get();
            if (transform in _transformMap)
                return _transformMap[transform];
            DrawBufRef src = get();
            if (src.isNull)
                _transformMap[transform] = src;
            else {
                DrawBufRef t = src.transformColors(transform);
                _transformMap[transform] = t;
            }
            return _transformMap[transform];
        }
        /// remove from memory, will cause reload on next access
        void compact() {
            if (!_drawbuf.isNull)
                _drawbuf.clear();
        }
        /// mark as not used
        void checkpoint() {
            _used = false;
        }
        /// cleanup if unused since last checkpoint
        void cleanup() {
            if (!_used)
                compact();
        }
    }
    ImageCacheItem[string] _map;

    /// get and cache image
    ref DrawBufRef get(string filename) {
        if (filename in _map) {
            return _map[filename].get;
        }
        ImageCacheItem item = new ImageCacheItem(filename);
        _map[filename] = item;
        return item.get;
    }

    /// get and cache color transformed image
    ref DrawBufRef get(string filename, ref ColorTransform transform) {
        if (transform.empty)
            return get(filename);
        if (filename in _map) {
            return _map[filename].get(transform);
        }
        ImageCacheItem item = new ImageCacheItem(filename);
        _map[filename] = item;
        return item.get(transform);
    }
    // clear usage flags for all entries
    void checkpoint() {
        foreach (item; _map)
            item.checkpoint();
    }
    // removes entries not used after last call of checkpoint() or cleanup()
    void cleanup() {
        foreach (item; _map)
            item.cleanup();
    }

    this() {
        debug Log.i("Creating ImageCache");
    }
    ~this() {
        debug Log.i("Destroying ImageCache");
        foreach (ref item; _map) {
            destroy(item);
            item = null;
        }
        _map.destroy();
    }
}

__gshared ImageCache _imageCache;
/// image cache singleton
@property ImageCache imageCache() { return _imageCache; }
/// image cache singleton
@property void imageCache(ImageCache cache) {
    if (_imageCache !is null)
        destroy(_imageCache);
    _imageCache = cache;
}
}

__gshared DrawableCache _drawableCache;
/// drawable cache singleton
@property DrawableCache drawableCache() { return _drawableCache; }
/// drawable cache singleton
@property void drawableCache(DrawableCache cache) {
    if (_drawableCache !is null)
        destroy(_drawableCache);
    _drawableCache = cache;
}

class DrawableCache {
    static class DrawableCacheItem {
        string _id;
        string _filename;
        bool _tiled;
        bool _error;
        bool _used;
        DrawableRef _drawable;
        DrawableRef[ColorTransform] _transformed;

        debug private static __gshared int _instanceCount;
        debug @property static int instanceCount() { return _instanceCount; }
        this(string id, string filename, bool tiled) {
            _id = id;
            _filename = filename;
            _tiled = tiled;
            _error = filename is null;
            debug ++_instanceCount;
            debug(resalloc) Log.d("Created DrawableCacheItem, count=", _instanceCount);
        }
        ~this() {
            _drawable.clear();
            foreach(ref t; _transformed)
                t.clear();
            _transformed.destroy();
            debug --_instanceCount;
            debug(resalloc) Log.d("Destroyed DrawableCacheItem, count=", _instanceCount);
        }
        /// remove from memory, will cause reload on next access
        void compact() {
            if (!_drawable.isNull)
                _drawable.clear();
            foreach(t; _transformed)
                t.clear();
            _transformed.destroy();
        }
        /// mark as not used
        void checkpoint() {
            _used = false;
        }
        /// cleanup if unused since last checkpoint
        void cleanup() {
            if (!_used)
                compact();
        }

        /// returns drawable (loads from file if necessary)
        @property ref DrawableRef drawable() {
            _used = true;
            if (!_drawable.isNull || _error)
                return _drawable;
            if (_filename !is null) {
                // reload from file
                if (_filename.endsWith(".xml")) {
                    // XML drawables support
                        StateDrawable d = new StateDrawable();
                        if (!d.load(_filename)) {
                            destroy(d);
                            _error = true;
                        } else {
                            _drawable = d;
                        }
                } else if (_filename.endsWith(".tim")) {
                    static if (BACKEND_CONSOLE) {
                        try {
                            // .tim (text image) drawables support
                            string s = cast(string)loadResourceBytes(_filename);
                            if (s.length) {
                                TextDrawable d = new TextDrawable(s);
                                if (d.width && d.height) {
                                    _drawable = d;
                                }
                            }
                        } catch (Exception e) {
                            // cannot find drawable file
                        }
                    }
                    if (!_drawable)
                        _error = true;
                } else if (_filename.startsWith("#")) {
                    // color reference #AARRGGBB, e.g. #5599AA, or FrameDrawable description string #frameColor,frameSize,#innerColor
                    _drawable = createColorDrawable(_filename);
                } else if (_filename.startsWith("{")) {
                    // json in {} with text drawable description
                    static if (BACKEND_CONSOLE) {
                        _drawable = createTextDrawable(_filename);
                    }
                } else {
                    static if (BACKEND_GUI) {
                        // PNG/JPEG drawables support
                        DrawBufRef image = imageCache.get(_filename);
                        if (!image.isNull) {
                            bool ninePatch = _filename.endsWith(".9.png");
                            _drawable = new ImageDrawable(image, _tiled, ninePatch);
                        } else
                            _error = true;
                    } else {
                        _error = true;
                    }
                }
            }
            return _drawable;
        }
        /// returns drawable (loads from file if necessary)
        @property ref DrawableRef drawable(ref ColorTransform transform) {
            if (transform.empty)
                return drawable();
            if (transform in _transformed)
                return _transformed[transform];
            _used = true;
            if (!_drawable.isNull || _error)
                return _drawable;
            if (_filename !is null) {
                // reload from file
                if (_filename.endsWith(".xml") || _filename.endsWith(".XML")) {
                    // XML drawables support
                    StateDrawable d = new StateDrawable();
                    if (!d.load(_filename)) {
                        Log.e("failed to load .xml drawable from ", _filename);
                        destroy(d);
                        _error = true;
                    } else {
                        Log.d("loaded .xml drawable from ", _filename);
                        _drawable = d;
                    }
                } else if (_filename.endsWith(".tim") || _filename.endsWith(".TIM")) {
                    static if (BACKEND_CONSOLE) {
                        try {
                            // .tim (text image) drawables support
                            string s = cast(string)loadResourceBytes(_filename);
                            if (s.length) {
                                TextDrawable d = new TextDrawable(s);
                                if (d.width && d.height) {
                                    _drawable = d;
                                }
                            }
                        } catch (Exception e) {
                            // cannot find drawable file
                        }
                    }
                    if (!_drawable)
                        _error = true;
                } else if (_filename.startsWith("{")) {
                    // json in {} with text drawable description
                    static if (BACKEND_CONSOLE) {
                        _drawable = createTextDrawable(_filename);
                    }
                } else {
                    static if (BACKEND_GUI) {
                        // PNG/JPEG drawables support
                        DrawBufRef image = imageCache.get(_filename, transform);
                        if (!image.isNull) {
                            bool ninePatch = _filename.endsWith(".9.png") ||  _filename.endsWith(".9.PNG");
                            _transformed[transform] = new ImageDrawable(image, _tiled, ninePatch);
                            return _transformed[transform];
                        } else {
                            Log.e("failed to load image from ", _filename);
                            _error = true;
                        }
                    } else {
                        _error = true;
                    }
                }
            }
            return _drawable;
        }
    }
    void clear() {
        Log.d("DrawableCache.clear()");
        _idToFileMap.destroy();
        foreach(DrawableCacheItem item; _idToDrawableMap)
            item.drawable.clear();
        _idToDrawableMap.destroy();
    }
    // clear usage flags for all entries
    void checkpoint() {
        foreach (item; _idToDrawableMap)
            item.checkpoint();
    }
    // removes entries not used after last call of checkpoint() or cleanup()
    void cleanup() {
        foreach (item; _idToDrawableMap)
            item.cleanup();
    }
    string[] _resourcePaths;
    string[string] _idToFileMap;
    DrawableCacheItem[string] _idToDrawableMap;
    DrawableRef _nullDrawable;
    ref DrawableRef get(string id) {
        while (id.length && (id[0] == ' ' || id[0] == '\t' || id[0] == '\r' || id[0] == '\n'))
               id = id[1 .. $];
        if (id.equal("@null"))
            return _nullDrawable;
        if (id in _idToDrawableMap)
            return _idToDrawableMap[id].drawable;
        string resourceId = id;
        bool tiled = false;
        if (id.endsWith(".tiled")) {
            resourceId = id[0..$-6]; // remove .tiled
            tiled = true;
        }
        string filename = findResource(resourceId);
        DrawableCacheItem item = new DrawableCacheItem(id, filename, tiled);
        _idToDrawableMap[id] = item;
        return item.drawable;
    }
    ref DrawableRef get(string id, ref ColorTransform transform) {
        if (transform.empty)
            return get(id);
        if (id.equal("@null"))
            return _nullDrawable;
        if (id in _idToDrawableMap)
            return _idToDrawableMap[id].drawable(transform);
        string resourceId = id;
        bool tiled = false;
        if (id.endsWith(".tiled")) {
            resourceId = id[0..$-6]; // remove .tiled
            tiled = true;
        }
        string filename = findResource(resourceId);
        DrawableCacheItem item = new DrawableCacheItem(id, filename, tiled);
        _idToDrawableMap[id] = item;
        return item.drawable(transform);
    }
    @property string[] resourcePaths() {
        return _resourcePaths;
    }
    /// set resource directory paths as variable number of parameters
    void setResourcePaths(string[] paths ...) {
        resourcePaths(paths);
    }
    /// set resource directory paths array (only existing dirs will be added)
    @property void resourcePaths(string[] paths) {
        string[] existingPaths;
        foreach(path; paths) {
            if (exists(path) && isDir(path)) {
                existingPaths ~= path;
                Log.d("DrawableCache: adding path ", path, " to resource dir list.");
            } else {
                Log.d("DrawableCache: path ", path, " does not exist.");
            }
        }
        _resourcePaths = existingPaths;
        clear();
    }
    /// concatenates path with resource id and extension, returns pathname if there is such file, null if file does not exist
    private string checkFileName(string path, string id, string extension) {
        char[] fn = path.dup;
        fn ~= id;
        fn ~= extension;
        if (exists(fn) && isFile(fn))
            return fn.dup;
        return null;
    }
    /// get resource file full pathname by resource id, null if not found
    string findResource(string id) {
        if (id.startsWith("#") || id.startsWith("{"))
            return id; // it's not a file name, just a color #AARRGGBB
        if (id in _idToFileMap)
            return _idToFileMap[id];
        EmbeddedResource * embedded = embeddedResourceList.findAutoExtension(id);
        if (embedded) {
            string fn = EMBEDDED_RESOURCE_PREFIX ~ embedded.name;
            _idToFileMap[id] = fn;
            return fn;
        }
        foreach(string path; _resourcePaths) {
            string fn;
            fn = checkFileName(path, id, ".xml");
            if (fn is null && BACKEND_CONSOLE)
                fn = checkFileName(path, id, ".tim");
            if (fn is null)
                fn = checkFileName(path, id, ".png");
            if (fn is null)
                fn = checkFileName(path, id, ".9.png");
            if (fn is null)
                fn = checkFileName(path, id, ".jpg");
            if (fn !is null) {
                _idToFileMap[id] = fn;
                return fn;
            }
        }
        Log.w("resource ", id, " is not found");
        return null;
    }
    static if (BACKEND_GUI) {
        /// get image (DrawBuf) from imageCache by resource id
        DrawBufRef getImage(string id) {
            DrawBufRef res;
            string fname = findResource(id);
            if (fname.endsWith(".png") || fname.endsWith(".jpg"))
                return imageCache.get(fname);
            return res;
        }
    }
    this() {
        debug Log.i("Creating DrawableCache");
    }
    ~this() {
        debug(resalloc) Log.e("Drawable instace count before destroying of DrawableCache: ", ImageDrawable.instanceCount);

        //Log.i("Destroying DrawableCache _idToDrawableMap.length=", _idToDrawableMap.length);
        Log.i("Destroying DrawableCache");
        foreach (ref item; _idToDrawableMap) {
            destroy(item);
            item = null;
        }
        _idToDrawableMap.destroy();
        debug if(ImageDrawable.instanceCount) Log.e("Drawable instace count after destroying of DrawableCache: ", ImageDrawable.instanceCount);
    }
}


// load text resource
string loadTextResource(string resourceId) {
    import dlangui.graphics.resources;
    import std.string : endsWith;
    string filename;
    filename = drawableCache.findResource(resourceId);
    if (!filename) {
        Log.e("Object resource file not found for resourceId ", resourceId);
        assert(false);
    }
    string s = cast(string)loadResourceBytes(filename);
    if (!s) {
        Log.e("Cannot read text resource ", resourceId, " from file ", filename);
        assert(false);
    }
    return s;
}
