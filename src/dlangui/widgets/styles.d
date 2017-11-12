// Written in the D programming language.

/**
This module contains declaration of themes and styles implementation.

Style - style container
Theme - parent for all styles


Synopsis:

----
import dlangui.widgets.styles;
----

Recent changes:
     Dimensions like fontSize, padding, margins, min/max width and height can be specified in points, e.g. minWidth = "3pt" margins="1pt,2pt,1pt,2pt"
     % for font size, based on parent font size, e.g. fontSize="120.5%" means parentStyle.fontSize * 120.5 / 100.0;

Copyright: Vadim Lopatin, 2014
License:   Boost License 1.0
Authors:   Vadim Lopatin, coolreader.org@gmail.com
*/
module dlangui.widgets.styles;

import dlangui.core.config;

private import std.xml;
private import std.string;
private import std.algorithm;

import dlangui.core.types;
import dlangui.graphics.colors;
import dlangui.graphics.fonts;
import dlangui.graphics.drawbuf;
import dlangui.graphics.resources;

// Standard style constants
// Themes should define all of these styles in order to support all controls
/// standard style id for TextWidget
immutable string STYLE_TEXT = "TEXT";
/// standard style id for MultilineTextWidget
immutable string STYLE_MULTILINE_TEXT = "MULTILINE_TEXT";
/// standard style id for Button
immutable string STYLE_BUTTON = "BUTTON";
/// standard style id for Button label
immutable string STYLE_BUTTON_LABEL = "BUTTON_LABEL";
/// standard style id for Button image
immutable string STYLE_BUTTON_IMAGE = "BUTTON_IMAGE";
/// style id for transparent Button
immutable string STYLE_BUTTON_TRANSPARENT = "BUTTON_TRANSPARENT";
/// style id for Button w/o margins
immutable string STYLE_BUTTON_NOMARGINS = "BUTTON_NOMARGINS";
/// standard style id for Switch
immutable string STYLE_SWITCH = "SWITCH";
/// standard style id for CheckBox
immutable string STYLE_CHECKBOX = "CHECKBOX";
/// standard style id for CheckBox image
immutable string STYLE_CHECKBOX_IMAGE = "CHECKBOX_IMAGE";
/// standard style id for CheckBox label
immutable string STYLE_CHECKBOX_LABEL = "CHECKBOX_LABEL";
/// standard style id for RadioButton
immutable string STYLE_RADIOBUTTON = "RADIOBUTTON";
/// standard style id for RadioButton image
immutable string STYLE_RADIOBUTTON_IMAGE = "RADIOBUTTON_IMAGE";
/// standard style id for RadioButton label
immutable string STYLE_RADIOBUTTON_LABEL = "RADIOBUTTON_LABEL";
/// standard style id for HSpacer
immutable string STYLE_HSPACER = "HSPACER";
/// standard style id for VSpacer
immutable string STYLE_VSPACER = "VSPACER";
/// standard style id for ScrollBar
immutable string STYLE_SCROLLBAR = "SCROLLBAR";
/// standard style id for SliderWidget
immutable string STYLE_SLIDER = "SLIDER";
/// standard style id for ScrollBar button
immutable string STYLE_SCROLLBAR_BUTTON = "SCROLLBAR_BUTTON";
/// standard style id for ScrollBar button
immutable string STYLE_SCROLLBAR_BUTTON_TRANSPARENT = "SCROLLBAR_BUTTON_TRANSPARENT";
/// standard style id for ScrollBar page control
immutable string STYLE_PAGE_SCROLL = "PAGE_SCROLL";
/// standard style id for TabWidget
immutable string STYLE_TAB_WIDGET = "TAB_WIDGET";
/// standard style id for Tab with Up alignment
immutable string STYLE_TAB_UP = "TAB_UP";
/// standard style id for button of Tab with Up alignment
immutable string STYLE_TAB_UP_BUTTON = "TAB_UP_BUTTON";
/// standard style id for button of Tab with Up alignment
immutable string STYLE_TAB_UP_BUTTON_TEXT = "TAB_UP_BUTTON_TEXT";
/// standard style id for TabHost
immutable string STYLE_TAB_HOST = "TAB_HOST";
/// standard style id for PopupMenu
immutable string STYLE_POPUP_MENU = "POPUP_MENU";
/// standard style id for menu item
immutable string STYLE_MENU_ITEM = "MENU_ITEM";
/// standard style id for menu item label
immutable string STYLE_MENU_LABEL = "MENU_LABEL";
/// standard style id for menu item icon
immutable string STYLE_MENU_ICON = "MENU_ICON";
/// standard style id for menu item accelerators label
immutable string STYLE_MENU_ACCEL = "MENU_ACCEL";
/// standard style id for main menu item
immutable string STYLE_MAIN_MENU_ITEM = "MAIN_MENU_ITEM";
/// standard style id for main menu item label
immutable string STYLE_MAIN_MENU_LABEL = "MAIN_MENU_LABEL";
/// standard style id for main menu
immutable string STYLE_MAIN_MENU = "MAIN_MENU";
/// standard style id for list items
immutable string STYLE_LIST_ITEM = "LIST_ITEM";
/// standard style id for EditLine
immutable string STYLE_EDIT_LINE = "EDIT_LINE";
/// standard style id for EditBox
immutable string STYLE_EDIT_BOX = "EDIT_BOX";
/// standard style id for LogWidget
immutable string STYLE_LOG_WIDGET = "LOG_WIDGET";
/// standard style id for lists
immutable string STYLE_LIST_BOX = "LIST_BOX";
/// standard style id for StringGrid
immutable string STYLE_STRING_GRID = "STRING_GRID";
/// standard style id for FileDialog StringGrid
immutable string STYLE_FILE_DIALOG_GRID = "FILE_DIALOG_GRID";
/// standard style id for background similar to transparent button
immutable string STYLE_TRANSPARENT_BUTTON_BACKGROUND = "TRANSPARENT_BUTTON_BACKGROUND";
/// standard style id for GroupBox
immutable string STYLE_GROUP_BOX = "GROUP_BOX";
/// standard style id for GroupBox caption
immutable string STYLE_GROUP_BOX_CAPTION = "GROUP_BOX_CAPTION";
/// standard style id for ProgressBarWidget caption
immutable string STYLE_PROGRESS_BAR = "PROGRESS_BAR";

/// standard style id for tree item
immutable string STYLE_TREE_ITEM = "TREE_ITEM";
/// standard style id for tree item body (icon + label)
immutable string STYLE_TREE_ITEM_BODY = "TREE_ITEM_BODY";
/// standard style id for tree item label
immutable string STYLE_TREE_ITEM_LABEL = "TREE_ITEM_LABEL";
/// standard style id for tree item icon
immutable string STYLE_TREE_ITEM_ICON = "TREE_ITEM_ICON";
/// standard style id for tree item expand icon
immutable string STYLE_TREE_ITEM_EXPAND_ICON = "TREE_ITEM_EXPAND_ICON";
/// standard style id for combo box
immutable string STYLE_COMBO_BOX = "COMBO_BOX";
/// standard style id for combo box button
immutable string STYLE_COMBO_BOX_BUTTON = "COMBO_BOX_BUTTON";
/// standard style id for combo box body (current item)
immutable string STYLE_COMBO_BOX_BODY = "COMBO_BOX_BODY";
/// standard style id for app frame status line
immutable string STYLE_STATUS_LINE = "STATUS_LINE";

/// standard style id for dock host
immutable string STYLE_DOCK_HOST = "DOCK_HOST";
/// standard style id for dock host body
immutable string STYLE_DOCK_HOST_BODY = "DOCK_HOST_BODY";
/// standard style id for dock window caption
immutable string STYLE_DOCK_WINDOW_CAPTION = "DOCK_WINDOW_CAPTION";
/// standard style id for dock window
immutable string STYLE_DOCK_WINDOW = "DOCK_WINDOW";
/// standard style id for dock window caption label
immutable string STYLE_DOCK_WINDOW_CAPTION_LABEL = "DOCK_WINDOW_CAPTION_LABEL";
/// standard style id for dock window body
immutable string STYLE_DOCK_WINDOW_BODY = "DOCK_WINDOW_BODY";
/// standard style id for toolbar separator
immutable string STYLE_FLOATING_WINDOW = "FLOATING_WINDOW";

/// standard style id for tab control in dock frame
immutable string STYLE_TAB_UP_DARK = "TAB_UP_DARK";
/// standard style id for tab control tab button in dock frame
immutable string STYLE_TAB_UP_BUTTON_DARK = "TAB_UP_BUTTON_DARK";
/// standard style id for tab control tab button text in dock frame
immutable string STYLE_TAB_UP_BUTTON_DARK_TEXT = "TAB_UP_BUTTON_DARK_TEXT";
/// standard style id for tab control in dock frame
immutable string STYLE_TAB_DOWN_DARK = "TAB_DOWN_DARK";
/// standard style id for tab control tab button in dock frame
immutable string STYLE_TAB_DOWN_BUTTON_DARK = "TAB_DOWN_BUTTON_DARK";
/// standard style id for tab control tab button text in dock frame
immutable string STYLE_TAB_DOWN_BUTTON_DARK_TEXT = "TAB_DOWN_BUTTON_DARK_TEXT";

/// standard style id for tooltip popup
immutable string STYLE_TOOLTIP = "TOOLTIP";


/// standard style id for toolbars layout
immutable string STYLE_TOOLBAR_HOST = "TOOLBAR_HOST";
/// standard style id for toolbars
immutable string STYLE_TOOLBAR = "TOOLBAR";
/// standard style id for toolbar button
immutable string STYLE_TOOLBAR_BUTTON = "TOOLBAR_BUTTON";
/// standard style id for toolbar control, e.g. combobox
immutable string STYLE_TOOLBAR_CONTROL = "TOOLBAR_CONTROL";
/// standard style id for toolbar separator
immutable string STYLE_TOOLBAR_SEPARATOR = "TOOLBAR_SEPARATOR";

/// standard style id for settings dialog tree
immutable string STYLE_SETTINGS_TREE = "SETTINGS_TREE";
/// standard style id for settings dialog content pages frame
immutable string STYLE_SETTINGS_PAGES = "SETTINGS_PAGES";
/// standard style id for settings dialog page title
immutable string STYLE_SETTINGS_PAGE_TITLE = "SETTINGS_PAGE_TITLE";

/// window background color resource id
immutable string STYLE_COLOR_WINDOW_BACKGROUND = "window_background";
/// dialog background color resource id
immutable string STYLE_COLOR_DIALOG_BACKGROUND = "dialog_background";



// Other style constants

/// unspecified align - to take parent's value instead
enum ubyte ALIGN_UNSPECIFIED = 0;
/// unspecified font size constant - to take parent style property value
enum ushort FONT_SIZE_UNSPECIFIED = 0xFFFF;
/// unspecified font weight constant - to take parent style property value
enum ushort FONT_WEIGHT_UNSPECIFIED = 0x0000;
/// unspecified font style constant - to take parent style property value
enum ubyte FONT_STYLE_UNSPECIFIED = 0xFF;
/// normal font style constant
enum ubyte FONT_STYLE_NORMAL = 0x00;
/// italic font style constant
enum ubyte FONT_STYLE_ITALIC = 0x01;
/// use text flags from parent style
enum uint TEXT_FLAGS_UNSPECIFIED = uint.max;
/// use text flags from parent widget
enum uint TEXT_FLAGS_USE_PARENT = uint.max - 1;
/// to take layout weight from parent
enum int WEIGHT_UNSPECIFIED = -1;

/// Align option bit constants
enum Align : ubyte {
    /// alignment is not specified
    Unspecified = ALIGN_UNSPECIFIED,
    /// horizontally align to the left of box
    Left = 1,
    /// horizontally align to the right of box
    Right = 2,
    /// horizontally align to the center of box
    HCenter = 1 | 2,
    /// vertically align to the top of box
    Top = 4,
    /// vertically align to the bottom of box
    Bottom = 8,
    /// vertically align to the center of box
    VCenter = 4 | 8,
    /// align to the center of box (VCenter | HCenter)
    Center = VCenter | HCenter,
    /// align to the top left corner of box (Left | Top)
    TopLeft = Left | Top,
}

/// text drawing flag bits
enum TextFlag : uint {
    /// text contains hot key prefixed with & char (e.g. "&File")
    HotKeys = 1,
    /// underline hot key when drawing
    UnderlineHotKeys = 2,
    /// underline hot key when drawing
    UnderlineHotKeysWhenAltPressed = 4,
    /// underline text when drawing
    Underline = 8,
    /// strikethrough text when drawing
    StrikeThrough = 16 // TODO:
}

struct DrawableAttributeList {
    DrawableAttribute[string] _customDrawables;
    ~this() {
        clear();
    }
    void clear() {
        foreach(key, ref value; _customDrawables) {
            if (value) {
                destroy(value);
                value = null;
            }
        }
        destroy(_customDrawables);
        _customDrawables = null;
    }
    bool hasKey(string key) const {
        return (key in _customDrawables) !is null;
    }
    ref DrawableRef drawable(string id) const {
        return _customDrawables[id].drawable;
    }
    /// get custom drawable attribute
    string drawableId(string id) const {
        return _customDrawables[id].drawableId;
    }
    void set(string id, string resourceId) {
        if (id in _customDrawables) {
            _customDrawables[id].drawableId = resourceId;
        } else {
            _customDrawables[id] = new DrawableAttribute(id, resourceId);
        }
    }
    void copyFrom(ref DrawableAttributeList v) {
        clear();
        foreach(key, value; v._customDrawables) {
            set(key, value.drawableId);
        }
    }
    void onThemeChanged() {
        foreach(key, ref value; _customDrawables) {
            if (value) {
                value.onThemeChanged();
            }
        }
    }
}

/// style properties
class Style {
protected:
    string _id;
    Theme _theme;
    Style _parentStyle;
    string _parentId;
    uint _stateMask;
    uint _stateValue;
    ubyte _align = Align.TopLeft;
    ubyte _fontStyle = FONT_STYLE_UNSPECIFIED;
    FontFamily _fontFamily = FontFamily.Unspecified;
    ushort _fontWeight = FONT_WEIGHT_UNSPECIFIED;
    int _fontSize = FONT_SIZE_UNSPECIFIED;
    uint _backgroundColor = COLOR_UNSPECIFIED;
    uint _textColor = COLOR_UNSPECIFIED;
    uint _textFlags = 0;
    uint _alpha;
    string _fontFace;
    string _backgroundImageId;
    string _boxShadow;
    string _border;
    Rect _padding;
    Rect _margins;
    int _minWidth = SIZE_UNSPECIFIED;
    int _maxWidth = SIZE_UNSPECIFIED;
    int _minHeight = SIZE_UNSPECIFIED;
    int _maxHeight = SIZE_UNSPECIFIED;
    int _layoutWidth = SIZE_UNSPECIFIED;
    int _layoutHeight = SIZE_UNSPECIFIED;
    int _layoutWeight = WEIGHT_UNSPECIFIED;
    int _maxLines = SIZE_UNSPECIFIED;

    uint[] _focusRectColors;

    Style[] _substates;
    Style[] _children;

    DrawableAttributeList _customDrawables;
    uint[string] _customColors;
    uint[string] _customLength;

    FontRef _font;
    DrawableRef _backgroundDrawable;

public:
    void onThemeChanged() {
        _font.clear();
        _backgroundDrawable.clear();
        foreach(s; _substates)
            s.onThemeChanged();
        foreach(s; _children)
            s.onThemeChanged();
        _customDrawables.onThemeChanged();
    }

    @property const(Theme) theme() const {
        if (_theme !is null)
            return _theme;
        return currentTheme;
    }

    @property Theme theme() {
        if (_theme !is null)
            return _theme;
        return currentTheme;
    }

    @property string id() const { return _id; }
    @property Style id(string id) {
        this._id = id;
        return this;
    }

    /// access to parent style for this style
    @property const(Style) parentStyle() const {
        if (_parentStyle !is null)
            return _parentStyle;
        if (_parentId !is null && currentTheme !is null)
            return currentTheme.get(_parentId);
        return currentTheme;
    }

    /// access to parent style for this style
    @property Style parentStyle() {
        if (_parentStyle !is null)
            return _parentStyle;
        if (_parentId !is null && currentTheme !is null)
            return currentTheme.get(_parentId);
        return currentTheme;
    }

    @property string parentStyleId() {
        return _parentId;
    }

    @property Style parentStyleId(string id) {
        _parentId = id;
        if (_parentStyle)
            if (currentTheme) {
                _parentStyle = currentTheme.get(_parentId);
            }
        return this;
    }

    @property ref DrawableRef backgroundDrawable() const {
        if (!(cast(Style)this)._backgroundDrawable.isNull)
            return (cast(Style)this)._backgroundDrawable;
        string image = backgroundImageId;
        uint color = backgroundColor;
        string borders = border;
        string shadows = boxShadow;
        if (borders !is null || shadows !is null) {
            (cast(Style)this)._backgroundDrawable = new CombinedDrawable(color, image, borders, shadows);
        } else if (image !is null) {
            (cast(Style)this)._backgroundDrawable = drawableCache.get(image);
        } else {
            (cast(Style)this)._backgroundDrawable = isFullyTransparentColor(color) ? new EmptyDrawable() : new SolidFillDrawable(color);
        }
        return (cast(Style)this)._backgroundDrawable;
    }

    /// get custom drawable attribute
    ref DrawableRef customDrawable(string id) const {
        if (_customDrawables.hasKey(id))
            return _customDrawables.drawable(id);
        return parentStyle ? parentStyle.customDrawable(id) : currentTheme.customDrawable(id);
    }

    /// get custom drawable attribute
    string customDrawableId(string id) const {
        if (_customDrawables.hasKey(id))
            return _customDrawables.drawableId(id);
        return parentStyle ? parentStyle.customDrawableId(id) : currentTheme.customDrawableId(id);
    }

    /// sets custom drawable attribute for style
    Style setCustomDrawable(string id, string resourceId) {
        _customDrawables.set(id, resourceId);
        return this;
    }

    /// get custom color attribute
    uint customColor(string id, uint defColor = COLOR_TRANSPARENT) const {
        if (id in _customColors)
            return _customColors[id];
        return parentStyle ? parentStyle.customColor(id, defColor) : currentTheme.customColor(id, defColor);
    }

    /// sets custom color attribute for style
    Style setCustomColor(string id, uint color) {
        _customColors[id] = color;
        return this;
    }

    /// get custom length attribute
    uint customLength(string id, uint defLength = 0) const {
        if (id in _customLength)
            return _customLength[id];
        return parentStyle ? parentStyle.customLength(id, defLength) : currentTheme.customLength(id, defLength);
    }

    /// sets custom length attribute for style
    Style setCustomLength(string id, uint value) {
        _customLength[id] = value;
        return this;
    }

    void clearCachedObjects() {
        onThemeChanged();
    }

    //===================================================
    // font properties

    @property ref FontRef font() const {
        if (!(cast(Style)this)._font.isNull)
            return (cast(Style)this)._font;
        string face = fontFace;
        int size = fontSize;
        ushort weight = fontWeight;
        bool italic = fontItalic;
        FontFamily family = fontFamily;
        (cast(Style)this)._font = FontManager.instance.getFont(size, weight, italic, family, face);
        return (cast(Style)this)._font;
    }

    /// font size
    @property FontFamily fontFamily() const {
        if (_fontFamily != FontFamily.Unspecified)
            return _fontFamily;
        else
            return parentStyle.fontFamily;
    }

    /// font size
    @property string fontFace() const {
        if (_fontFace !is null)
            return _fontFace;
        else
            return parentStyle.fontFace;
    }

    /// font style - italic
    @property bool fontItalic() const {
        if (_fontStyle != FONT_STYLE_UNSPECIFIED)
            return _fontStyle == FONT_STYLE_ITALIC;
        else
            return parentStyle.fontItalic;
    }

    /// font weight
    @property ushort fontWeight() const {
        if (_fontWeight != FONT_WEIGHT_UNSPECIFIED)
            return _fontWeight;
        else
            return parentStyle.fontWeight;
    }

    /// font size
    @property int fontSize() const {
        if (_fontSize != FONT_SIZE_UNSPECIFIED) {
            if (_fontSize & SIZE_IN_PERCENTS_FLAG)
                return parentStyle.fontSize * (_fontSize ^ SIZE_IN_PERCENTS_FLAG) / 10000;
            return toPixels(_fontSize);
        } else
            return parentStyle.fontSize;
    }

    /// box shadow
    @property string boxShadow() const {
        if (_boxShadow !is null)
            return _boxShadow;
        else {
            return parentStyle.boxShadow;
        }
    }

    /// border
    @property string border() const {
        if (_border !is null)
            return _border;
        else {
            return parentStyle.border;
        }
    }

    //===================================================
    // layout parameters: margins / padding

    /// padding
    @property const(Rect) padding() const {
        if (_stateMask || _padding.left == SIZE_UNSPECIFIED)
            return toPixels(parentStyle._padding);
        return toPixels(_padding);
    }

    /// margins
    @property const(Rect) margins() const {
        if (_stateMask || _margins.left == SIZE_UNSPECIFIED)
            return toPixels(parentStyle._margins);
        return toPixels(_margins);
    }

    /// alpha (0=opaque .. 255=transparent)
    @property uint alpha() const {
        if (_alpha != COLOR_UNSPECIFIED)
            return _alpha;
        else
            return parentStyle.alpha;
    }

    /// text color
    @property uint textColor() const {
        if (_textColor != COLOR_UNSPECIFIED)
            return _textColor;
        else
            return parentStyle.textColor;
    }

    /// text color
    @property int maxLines() const {
        if (_maxLines != SIZE_UNSPECIFIED)
            return _maxLines;
        else
            return parentStyle.maxLines;
    }

    /// text flags
    @property uint textFlags() const {
        if (_textFlags != TEXT_FLAGS_UNSPECIFIED)
            return _textFlags;
        else
            return parentStyle.textFlags;
    }

    //===================================================
    // background

    /// background color
    @property uint backgroundColor() const {
        if (_backgroundColor != COLOR_UNSPECIFIED)
            return _backgroundColor;
        else
            return parentStyle.backgroundColor;
    }

    /// background image id
    @property string backgroundImageId() const {
        if (_backgroundImageId == COLOR_DRAWABLE)
            return null;
        else if (_backgroundImageId !is null)
            return _backgroundImageId;
        else
            return parentStyle.backgroundImageId;
    }

    //===================================================
    // size restrictions

    /// minimal width constraint, 0 if limit is not set
    @property uint minWidth() const {
        if (_minWidth != SIZE_UNSPECIFIED)
            return toPixels(_minWidth);
        else
            return parentStyle.minWidth;
    }
    /// max width constraint, returns SIZE_UNSPECIFIED if limit is not set
    @property uint maxWidth() const {
        if (_maxWidth != SIZE_UNSPECIFIED)
            return toPixels(_maxWidth);
        else
            return parentStyle.maxWidth;
    }
    /// minimal height constraint, 0 if limit is not set
    @property uint minHeight() const {
        if (_minHeight != SIZE_UNSPECIFIED)
            return toPixels(_minHeight);
        else
            return parentStyle.minHeight;
    }
    /// max height constraint, SIZE_UNSPECIFIED if limit is not set
    @property uint maxHeight() const {
        if (_maxHeight != SIZE_UNSPECIFIED)
            return toPixels(_maxHeight);
        else
            return parentStyle.maxHeight;
    }
    /// set min width constraint
    @property Style minWidth(int value) {
        _minWidth = value;
        return this;
    }
    /// set max width constraint
    @property Style maxWidth(int value) {
        _maxWidth = value;
        return this;
    }
    /// set min height constraint
    @property Style minHeight(int value) {
        _minHeight = value;
        return this;
    }
    /// set max height constraint
    @property Style maxHeight(int value) {
        _maxHeight = value;
        return this;
    }


    /// layout width parameter
    @property uint layoutWidth() const {
        if (_layoutWidth != SIZE_UNSPECIFIED)
            return _layoutWidth;
        else
            return parentStyle.layoutWidth;
    }

    /// layout height parameter
    @property uint layoutHeight() const {
        if (_layoutHeight != SIZE_UNSPECIFIED)
            return _layoutHeight;
        else
            return parentStyle.layoutHeight;
    }

    /// layout weight parameter
    @property uint layoutWeight() const {
        if (_layoutWeight != WEIGHT_UNSPECIFIED)
            return _layoutWeight;
        else
            return parentStyle.layoutWeight;
    }

    /// set layout height
    @property Style layoutHeight(int value) {
        _layoutHeight = value;
        return this;
    }
    /// set layout width
    @property Style layoutWidth(int value) {
        _layoutWidth = value;
        return this;
    }
    /// set layout weight
    @property Style layoutWeight(int value) {
        _layoutWeight = value;
        return this;
    }

    //===================================================
    // alignment

    /// get full alignment (both vertical and horizontal)
    @property ubyte alignment() const {
        if (_align != Align.Unspecified)
            return _align;
        else
            return parentStyle.alignment;
    }
    /// vertical alignment: Top / VCenter / Bottom
    @property ubyte valign() const { return alignment & Align.VCenter; }
    /// horizontal alignment: Left / HCenter / Right
    @property ubyte halign() const { return alignment & Align.HCenter; }

    /// set alignment
    @property Style alignment(ubyte value) {
        _align = value;
        return this;
    }

    @property Style fontFace(string face) {
        if (_fontFace != face)
            clearCachedObjects();
        _fontFace = face;
        return this;
    }

    @property Style fontFamily(FontFamily family) {
        if (_fontFamily != family)
            clearCachedObjects();
        _fontFamily = family;
        return this;
    }

    @property Style fontStyle(ubyte style) {
        if (_fontStyle != style)
            clearCachedObjects();
        _fontStyle = style;
        return this;
    }

    @property Style fontWeight(ushort weight) {
        if (_fontWeight != weight)
            clearCachedObjects();
        _fontWeight = weight;
        return this;
    }

    @property Style fontSize(int size) {
        if (_fontSize != size)
            clearCachedObjects();
        _fontSize = size;
        return this;
    }

    @property Style textColor(uint color) {
        _textColor = color;
        return this;
    }

    @property Style maxLines(int lines) {
        _maxLines = lines;
        return this;
    }

    @property Style alpha(uint alpha) {
        _alpha = alpha;
        return this;
    }

    @property Style textFlags(uint flags) {
        _textFlags = flags;
        return this;
    }

    @property Style backgroundColor(uint color) {
        _backgroundColor = color;
        _backgroundImageId = COLOR_DRAWABLE;
        _backgroundDrawable.clear();
        return this;
    }

    @property Style backgroundImageId(string image) {
        _backgroundImageId = image;
        _backgroundDrawable.clear();
        return this;
    }

    @property Style boxShadow(string s) {
        _boxShadow = s;
        _backgroundDrawable.clear();
        return this;
    }

    @property Style border(string s) {
        _border = s;
        _backgroundDrawable.clear();
        return this;
    }

    @property Style margins(Rect rc) {
        _margins = rc;
        return this;
    }

    Style setMargins(int left, int top, int right, int bottom) {
        _margins.left = left;
        _margins.top = top;
        _margins.right = right;
        _margins.bottom = bottom;
        return this;
    }

    @property Style padding(Rect rc) {
        _padding = rc;
        return this;
    }

    /// returns colors to draw focus rectangle (one for solid, two for vertical gradient) or null if no focus rect should be drawn for style
    @property const(uint[]) focusRectColors() const {
        if (_focusRectColors) {
            if (_focusRectColors.length == 1 && _focusRectColors[0] == COLOR_UNSPECIFIED)
                return null;
            return cast(const)_focusRectColors;
        }
        return parentStyle.focusRectColors;
    }

    /// sets colors to draw focus rectangle or null if no focus rect should be drawn for style
    @property Style focusRectColors(uint[] colors) {
        _focusRectColors = colors;
        return this;
    }

    Style setPadding(int left, int top, int right, int bottom) {
        _padding.left = left;
        _padding.top = top;
        _padding.right = right;
        _padding.bottom = bottom;
        return this;
    }

    debug private static __gshared int _instanceCount;
    debug @property static int instanceCount() { return _instanceCount; }

    this(Theme theme, string id) {
        _theme = theme;
        _parentStyle = theme;
        _id = id;
        debug _instanceCount++;
        //Log.d("Created style ", _id, ", count=", ++_instanceCount);
    }


    ~this() {
        foreach(ref Style item; _substates) {
            //Log.d("Destroying substate");
            destroy(item);
            item = null;
        }
        _substates.destroy();
        foreach(ref Style item; _children) {
            destroy(item);
            item = null;
        }
        _children.destroy();
        _backgroundDrawable.clear();
        _font.clear();
        destroy(_customDrawables);
        debug _instanceCount--;
        //Log.d("Destroyed style ", _id, ", parentId=", _parentId, ", state=", _stateMask, ", count=", --_instanceCount);
    }

    /// create named substyle of this style
    Style createSubstyle(string id) {
        Style child = (_theme !is null ? _theme : currentTheme).createSubstyle(id);
        child._parentStyle = this;
        _children ~= child;
        return child;
    }

    /// create state substyle for this style
    Style createState(uint stateMask = 0, uint stateValue = 0) {
        assert(stateMask != 0);
        debug(styles) Log.d("Creating substate ", stateMask);
        Style child = (_theme !is null ? _theme : currentTheme).createSubstyle(null);
        child._parentStyle = this;
        child._stateMask = stateMask;
        child._stateValue = stateValue;
        child._backgroundColor = COLOR_UNSPECIFIED;
        child._textColor = COLOR_UNSPECIFIED;
        child._textFlags = TEXT_FLAGS_UNSPECIFIED;
        _substates ~= child;
        return child;
    }

    Style clone() {
        Style res = new Style(_theme, null);
        res._stateMask = _stateMask;
        res._stateValue = _stateValue;
        res._align = _align;
        res._fontStyle = _fontStyle;
        res._fontFamily = _fontFamily;
        res._fontWeight = _fontWeight;
        res._fontSize = _fontSize;
        res._backgroundColor = _backgroundColor;
        res._textColor = _textColor;
        res._textFlags = _textFlags;
        res._alpha = _alpha;
        res._fontFace = _fontFace;
        res._backgroundImageId = _backgroundImageId;
        res._boxShadow = _boxShadow;
        res._border = _border;
        res._padding = _padding;
        res._margins = _margins;
        res._minWidth = _minWidth;
        res._maxWidth = _maxWidth;
        res._minHeight = _minHeight;
        res._maxHeight = _maxHeight;
        res._layoutWidth = _layoutWidth;
        res._layoutHeight = _layoutHeight;
        res._layoutWeight = _layoutWeight;
        res._maxLines = _maxLines;

        res._focusRectColors = _focusRectColors.dup;

        res._customDrawables.copyFrom(_customDrawables);
        res._customColors = _customColors.dup;
        res._customLength = _customLength.dup;
        return res;
    }

    /// find exact existing state style or create new if no matched styles found
    Style getOrCreateState(uint stateMask = 0, uint stateValue = 0) {
        if (stateValue == State.Normal)
            return this;
        foreach(item; _substates) {
            if ((item._stateMask == stateMask) && (item._stateValue == stateValue))
                return item;
        }
        return createState(stateMask, stateValue);
    }

    /// find substyle based on widget state (e.g. focused, pressed, ...)
    Style forState(uint state) {
        if (state == State.Normal)
            return this;
        //Log.d("forState ", state, " styleId=", _id, " substates=", _substates.length);
        if (parentStyle !is null && _substates.length == 0 && parentStyle._substates.length > 0) //id is null &&
            return parentStyle.forState(state);
        foreach(item; _substates) {
            if ((item._stateMask & state) == item._stateValue)
                return item;
        }
        return this; // fallback to current style
    }

    /// find substyle based on widget state (e.g. focused, pressed, ...)
    const(Style) forState(uint state) const {
        if (state == State.Normal)
            return this;
        //Log.d("forState ", state, " styleId=", _id, " substates=", _substates.length);
        if (parentStyle !is null && _substates.length == 0 && parentStyle._substates.length > 0) //id is null &&
            return parentStyle.forState(state);
        foreach(item; _substates) {
            if ((item._stateMask & state) == item._stateValue)
                return item;
        }
        return this; // fallback to current style
    }

}

/// Theme - root for style hierarhy.
class Theme : Style {
    protected Style[string] _byId;

    this(string id) {
        super(this, id);
        _parentStyle = null;
        _backgroundColor = COLOR_TRANSPARENT; // transparent
        _textColor = 0x000000; // black
        _maxLines = 1;
        _align = Align.TopLeft;
        _fontSize = 9 | SIZE_IN_POINTS_FLAG; // TODO: from settings or screen properties / DPI
        _fontStyle = FONT_STYLE_NORMAL;
        _fontWeight = 400;
        _fontFace = "Arial"; // TODO: from settings
        //_fontFace = "Verdana"; // TODO: from settings
        _fontFamily = FontFamily.SansSerif;
        _minHeight = 0;
        _minWidth = 0;
        _layoutWidth = WRAP_CONTENT;
        _layoutHeight = WRAP_CONTENT;
        _layoutWeight = 1;
    }

    ~this() {
        //Log.d("Theme destructor");
        if (unknownStyleIds.length > 0) {
            Log.e("Unknown style statistics: ", unknownStyleIds);
        }
        foreach(ref Style item; _byId) {
            destroy(item);
            item = null;
        }
        _byId.destroy();
    }

    override void onThemeChanged() {
        super.onThemeChanged();
        foreach(key, value; _byId) {
            value.onThemeChanged();
        }
    }

    /// create wrapper style which will have currentTheme.get(id) as parent instead of fixed parent - to modify some base style properties in widget
    Style modifyStyle(string id) {
        Style style = new Style(null, null);
        style._parentId = id;
        style._align = Align.Unspecified; // inherit
        style._padding.left = SIZE_UNSPECIFIED; // inherit
        style._margins.left = SIZE_UNSPECIFIED; // inherit
        style._textColor = COLOR_UNSPECIFIED; // inherit
        style._textFlags = TEXT_FLAGS_UNSPECIFIED; // inherit
        Style parent = get(id);
        if (parent) {
            foreach(item; parent._substates) {
                Style substate = item.clone();
                substate._parentStyle = style;
                style._substates ~= substate;
            }
        }
        return style;
    }

    // ================================================
    // override to avoid infinite recursion
    /// font size
    @property override string backgroundImageId() const {
        return _backgroundImageId;
    }
    /// box shadow
    @property override string boxShadow() const {
        return _boxShadow;
    }
    /// border
    @property override string border() const {
        return _border;
    }
    /// minimal width constraint, 0 if limit is not set
    @property override uint minWidth() const {
        return _minWidth;
    }
    /// max width constraint, returns SIZE_UNSPECIFIED if limit is not set
    @property override uint maxWidth() const {
        return _maxWidth;
    }
    /// minimal height constraint, 0 if limit is not set
    @property override uint minHeight() const {
        return _minHeight;
    }
    /// max height constraint, SIZE_UNSPECIFIED if limit is not set
    @property override uint maxHeight() const {
        return _maxHeight;
    }

    private DrawableRef _emptyDrawable;
    override ref DrawableRef customDrawable(string id) const {
        if (_customDrawables.hasKey(id))
            return _customDrawables.drawable(id);
        return (cast(Theme)this)._emptyDrawable;
    }

    override string customDrawableId(string id) const {
        if (_customDrawables.hasKey(id))
            return _customDrawables.drawableId(id);
        return null;
    }

    /// get custom color attribute - transparent by default
    override uint customColor(string id, uint defColor = COLOR_TRANSPARENT) const {
        if (id in _customColors)
            return _customColors[id];
        return defColor;
    }

    /// get custom color attribute - transparent by default
    override uint customLength(string id, uint defValue = 0) const {
        if (id in _customLength)
            return _customLength[id];
        return defValue;
    }

    /// returns colors to draw focus rectangle or null if no focus rect should be drawn for style
    @property override const(uint[]) focusRectColors() const {
        if (_focusRectColors)
            return _focusRectColors;
        return null;
    }

    /// create new named style or get existing
    override Style createSubstyle(string id) {
        if (id !is null && id in _byId)
            return _byId[id]; // already exists
        Style style = new Style(this, id);
        if (id !is null)
            _byId[id] = style;
        style._parentStyle = this; // as initial value, use theme as parent
        return style;
    }

    /// to track unknown styles refernced from code
    int[string] unknownStyleIds;
    /// find style by id, returns theme if not style with specified ID is not found
    @property Style get(string id) {
        if (id is null)
            return this;
        if (id in _byId)
            return _byId[id];
        // track unknown style ID references
        if (id in unknownStyleIds)
            unknownStyleIds[id] = unknownStyleIds[id] + 1;
        else {
            Log.e("Unknown style ID requested: ", id);
            unknownStyleIds[id] = 1;
        }
        return this;
    }

    /// find substyle based on widget state (e.g. focused, pressed, ...)
    override const(Style) forState(uint state) const {
        return this;
    }

    /// find substyle based on widget state (e.g. focused, pressed, ...)
    override Style forState(uint state) {
        return this;
    }

    void dumpStats() {
        Log.d("Theme ", _id, ": children:", _children.length, ", substates:", _substates.length, ", mapsize:", _byId.length);
    }
}

/// to access current theme
private __gshared Theme _currentTheme;
/// current theme accessor
@property Theme currentTheme() { return _currentTheme; }
/// set new current theme
@property void currentTheme(Theme theme) {
    if (_currentTheme !is null) {
        destroy(_currentTheme);
    }
    _currentTheme = theme;
}

immutable ATTR_SCROLLBAR_BUTTON_UP = "scrollbar_button_up";
immutable ATTR_SCROLLBAR_BUTTON_DOWN = "scrollbar_button_down";
immutable ATTR_SCROLLBAR_BUTTON_LEFT = "scrollbar_button_left";
immutable ATTR_SCROLLBAR_BUTTON_RIGHT = "scrollbar_button_right";
immutable ATTR_SCROLLBAR_INDICATOR_VERTICAL = "scrollbar_indicator_vertical";
immutable ATTR_SCROLLBAR_INDICATOR_HORIZONTAL = "scrollbar_indicator_horizontal";

Theme createDefaultTheme() {
    Log.d("Creating default theme");
    Theme res = new Theme("default");
    //res.fontSize(14);
    version (Windows) {
        res.fontFace = "Verdana";
    }
    //res.fontFace = "Arial Narrow";
    static if (WIDGET_STYLE_CONSOLE) {
        res.fontSize = 1;
        res.textColor = 0xFFFFFF;
        Style button = res.createSubstyle(STYLE_BUTTON).backgroundColor(0x808080).alignment(Align.Center).setMargins(0, 0, 0, 0).textColor(0x000000);
        //button.createState(State.Selected, State.Selected).backgroundColor(0xFFFFFF);
        button.createState(State.Pressed, State.Pressed).backgroundColor(0xFFFF00);
        button.createState(State.Focused|State.Hovered, State.Focused|State.Hovered).textColor(0x800000).backgroundColor(0xFFFFFF);
        button.createState(State.Focused, State.Focused).backgroundColor(0xFFFFFF).textColor(0x000080);
        button.createState(State.Hovered, State.Hovered).textColor(0x800000);
        Style buttonLabel = res.createSubstyle(STYLE_BUTTON_LABEL).layoutWidth(FILL_PARENT).alignment(Align.Left|Align.VCenter);
        //buttonLabel.createState(State.Hovered, State.Hovered).textColor(0x800000);
        //buttonLabel.createState(State.Focused, State.Focused).textColor(0x000080);
        res.createSubstyle(STYLE_BUTTON_TRANSPARENT).backgroundImageId("btn_background_transparent").alignment(Align.Center);
        res.createSubstyle(STYLE_BUTTON_IMAGE).alignment(Align.Center).textColor(0x000000);
        res.createSubstyle(STYLE_TEXT).setMargins(0, 0, 0, 0).setPadding(0, 0, 0, 0);
        res.createSubstyle(STYLE_HSPACER).layoutWidth(FILL_PARENT).minWidth(5).layoutWeight(100);
        res.createSubstyle(STYLE_VSPACER).layoutHeight(FILL_PARENT).minHeight(5).layoutWeight(100);
        res.createSubstyle(STYLE_BUTTON_NOMARGINS).alignment(Align.Center); // .setMargins(5,5,5,5)
        //button.createState(State.Enabled | State.Focused, State.Focused).backgroundImageId("btn_default_small_normal_disable_focused");
        //button.createState(State.Enabled, 0).backgroundImageId("btn_default_small_normal_disable");
        //button.createState(State.Pressed, State.Pressed).backgroundImageId("btn_default_small_pressed");
        //button.createState(State.Focused, State.Focused).backgroundImageId("btn_default_small_selected");
        //button.createState(State.Hovered, State.Hovered).backgroundImageId("btn_default_small_normal_hover");
        res.setCustomDrawable(ATTR_SCROLLBAR_BUTTON_UP, "scrollbar_btn_up");
        res.setCustomDrawable(ATTR_SCROLLBAR_BUTTON_DOWN, "scrollbar_btn_down");
        res.setCustomDrawable(ATTR_SCROLLBAR_BUTTON_LEFT, "scrollbar_btn_left");
        res.setCustomDrawable(ATTR_SCROLLBAR_BUTTON_RIGHT, "scrollbar_btn_right");
        res.setCustomDrawable(ATTR_SCROLLBAR_INDICATOR_VERTICAL, "scrollbar_indicator_vertical");
        res.setCustomDrawable(ATTR_SCROLLBAR_INDICATOR_HORIZONTAL, "scrollbar_indicator_horizontal");

        Style scrollbar = res.createSubstyle(STYLE_SCROLLBAR);
        scrollbar.backgroundColor(0xC0808080);
        Style scrollbarButton = button.createSubstyle(STYLE_SCROLLBAR_BUTTON);
        Style scrollbarSlider = res.createSubstyle(STYLE_SLIDER);
        Style scrollbarPage = res.createSubstyle(STYLE_PAGE_SCROLL).backgroundColor(COLOR_TRANSPARENT);
        scrollbarPage.createState(State.Pressed, State.Pressed).backgroundColor(0xC0404080);
        scrollbarPage.createState(State.Hovered, State.Hovered).backgroundColor(0xF0404080);

        Style tabUp = res.createSubstyle(STYLE_TAB_UP);
        tabUp.backgroundImageId("tab_up_background");
        tabUp.layoutWidth(FILL_PARENT);
        tabUp.createState(State.Selected, State.Selected).backgroundImageId("tab_up_backgrond_selected");
        Style tabUpButtonText = res.createSubstyle(STYLE_TAB_UP_BUTTON_TEXT);
        tabUpButtonText.textColor(0x000000).alignment(Align.Center);
        tabUpButtonText.createState(State.Selected, State.Selected).textColor(0x000000);
        tabUpButtonText.createState(State.Selected|State.Focused, State.Selected|State.Focused).textColor(0x000000);
        tabUpButtonText.createState(State.Focused, State.Focused).textColor(0x000000);
        tabUpButtonText.createState(State.Hovered, State.Hovered).textColor(0xFFE0E0);
        Style tabUpButton = res.createSubstyle(STYLE_TAB_UP_BUTTON);
        tabUpButton.backgroundImageId("tab_btn_up");
        //tabUpButton.backgroundImageId("tab_btn_up_normal");
        //tabUpButton.createState(State.Selected, State.Selected).backgroundImageId("tab_btn_up_selected");
        //tabUpButton.createState(State.Selected|State.Focused, State.Selected|State.Focused).backgroundImageId("tab_btn_up_focused_selected");
        //tabUpButton.createState(State.Focused, State.Focused).backgroundImageId("tab_btn_up_focused");
        //tabUpButton.createState(State.Hovered, State.Hovered).backgroundImageId("tab_btn_up_hover");
        Style tabHost = res.createSubstyle(STYLE_TAB_HOST);
        tabHost.layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT);
        tabHost.backgroundColor(0xF0F0F0);
        Style tabWidget = res.createSubstyle(STYLE_TAB_WIDGET);
        tabWidget.setPadding(3,3,3,3).backgroundColor(0xEEEEEE);
        //tabWidget.backgroundImageId("frame_blue");
        //res.dumpStats();

        Style mainMenu = res.createSubstyle(STYLE_MAIN_MENU).backgroundColor(0xEFEFF2).layoutWidth(FILL_PARENT);
        Style mainMenuItem = res.createSubstyle(STYLE_MAIN_MENU_ITEM).setPadding(4,2,4,2).backgroundImageId("main_menu_item_background").textFlags(TEXT_FLAGS_USE_PARENT);
        Style menuItem = res.createSubstyle(STYLE_MENU_ITEM).setPadding(4,2,4,2); //.backgroundColor(0xE0E080)   ;
        menuItem.createState(State.Focused, State.Focused).backgroundColor(0x40C0C000);
        menuItem.createState(State.Pressed, State.Pressed).backgroundColor(0x4080C000);
        menuItem.createState(State.Selected, State.Selected).backgroundColor(0x00F8F9Fa);
        menuItem.createState(State.Hovered, State.Hovered).backgroundColor(0xC0FFFF00);
        res.createSubstyle(STYLE_MENU_ICON).setMargins(2,2,2,2).alignment(Align.VCenter|Align.Left).createState(State.Enabled,0).alpha(0xA0);
        res.createSubstyle(STYLE_MENU_LABEL).setMargins(4,2,4,2).alignment(Align.VCenter|Align.Left).textFlags(TextFlag.UnderlineHotKeys).createState(State.Enabled,0).textColor(0x80404040);
        res.createSubstyle(STYLE_MAIN_MENU_LABEL).setMargins(4,2,4,2).alignment(Align.VCenter|Align.Left).textFlags(TEXT_FLAGS_USE_PARENT).createState(State.Enabled,0).textColor(0x80404040);
        res.createSubstyle(STYLE_MENU_ACCEL).setMargins(4,2,4,2).alignment(Align.VCenter|Align.Left).createState(State.Enabled,0).textColor(0x80404040);

        Style transparentButtonBackground = res.createSubstyle(STYLE_TRANSPARENT_BUTTON_BACKGROUND).backgroundImageId("transparent_button_background").setPadding(4,2,4,2); //.backgroundColor(0xE0E080)   ;
        //transparentButtonBackground.createState(State.Focused, State.Focused).backgroundColor(0xC0C0C000);
        //transparentButtonBackground.createState(State.Pressed, State.Pressed).backgroundColor(0x4080C000);
        //transparentButtonBackground.createState(State.Selected, State.Selected).backgroundColor(0x00F8F9Fa);
        //transparentButtonBackground.createState(State.Hovered, State.Hovered).backgroundColor(0xD0FFFF00);

        Style poopupMenu = res.createSubstyle(STYLE_POPUP_MENU).backgroundImageId("popup_menu_background_normal");

        Style listItem = res.createSubstyle(STYLE_LIST_ITEM).backgroundImageId("list_item_background");
        //listItem.createState(State.Selected, State.Selected).backgroundColor(0xC04040FF).textColor(0x000000);
        //listItem.createState(State.Enabled, 0).textColor(0x80000000); // half transparent text for disabled item

        Style editLine = res.createSubstyle(STYLE_EDIT_LINE).backgroundImageId(q{
                {
                    text: [
                       "╔═╗",
                       "║ ║",
                       "╚═╝"],
                    backgroundColor: [0x000080],
                    textColor: [0xFF0000],
                    ninepatch: [1,1,1,1]
                }
            })
            .setPadding(0,0,0,0).setMargins(0,0,0,0).minWidth(20)
            .fontFace("Arial").fontFamily(FontFamily.SansSerif).fontSize(1);
        Style editBox = res.createSubstyle(STYLE_EDIT_BOX).backgroundImageId("editbox_background")
            .setPadding(0,0,0,0).setMargins(0,0,0,0).minWidth(30).minHeight(8).layoutHeight(FILL_PARENT).layoutWidth(FILL_PARENT)
            .fontFace("Courier New").fontFamily(FontFamily.MonoSpace).fontSize(1);
    } else {
        res.fontSize = 15; // TODO: choose based on DPI
        Style button = res.createSubstyle(STYLE_BUTTON).backgroundImageId("btn_background").alignment(Align.Center).setMargins(5,5,5,5);
        res.createSubstyle(STYLE_BUTTON_TRANSPARENT).backgroundImageId("btn_background_transparent").alignment(Align.Center);
        res.createSubstyle(STYLE_BUTTON_LABEL).layoutWidth(FILL_PARENT).alignment(Align.Left|Align.VCenter);
        res.createSubstyle(STYLE_BUTTON_IMAGE).alignment(Align.Center);
        res.createSubstyle(STYLE_TEXT).setMargins(2,2,2,2).setPadding(1,1,1,1);
        res.createSubstyle(STYLE_HSPACER).layoutWidth(FILL_PARENT).minWidth(5).layoutWeight(100);
        res.createSubstyle(STYLE_VSPACER).layoutHeight(FILL_PARENT).minHeight(5).layoutWeight(100);
        res.createSubstyle(STYLE_BUTTON_NOMARGINS).backgroundImageId("btn_background").alignment(Align.Center); // .setMargins(5,5,5,5)
        //button.createState(State.Enabled | State.Focused, State.Focused).backgroundImageId("btn_default_small_normal_disable_focused");
        //button.createState(State.Enabled, 0).backgroundImageId("btn_default_small_normal_disable");
        //button.createState(State.Pressed, State.Pressed).backgroundImageId("btn_default_small_pressed");
        //button.createState(State.Focused, State.Focused).backgroundImageId("btn_default_small_selected");
        //button.createState(State.Hovered, State.Hovered).backgroundImageId("btn_default_small_normal_hover");
        res.setCustomDrawable(ATTR_SCROLLBAR_BUTTON_UP, "scrollbar_btn_up");
        res.setCustomDrawable(ATTR_SCROLLBAR_BUTTON_DOWN, "scrollbar_btn_down");
        res.setCustomDrawable(ATTR_SCROLLBAR_BUTTON_LEFT, "scrollbar_btn_left");
        res.setCustomDrawable(ATTR_SCROLLBAR_BUTTON_RIGHT, "scrollbar_btn_right");
        res.setCustomDrawable(ATTR_SCROLLBAR_INDICATOR_VERTICAL, "scrollbar_indicator_vertical");
        res.setCustomDrawable(ATTR_SCROLLBAR_INDICATOR_HORIZONTAL, "scrollbar_indicator_horizontal");

        Style scrollbar = res.createSubstyle(STYLE_SCROLLBAR);
        scrollbar.backgroundColor(0xC0808080);
        Style scrollbarButton = button.createSubstyle(STYLE_SCROLLBAR_BUTTON);
        Style scrollbarSlider = res.createSubstyle(STYLE_SLIDER);
        Style scrollbarPage = res.createSubstyle(STYLE_PAGE_SCROLL).backgroundColor(COLOR_TRANSPARENT);
        scrollbarPage.createState(State.Pressed, State.Pressed).backgroundColor(0xC0404080);
        scrollbarPage.createState(State.Hovered, State.Hovered).backgroundColor(0xF0404080);

        Style tabUp = res.createSubstyle(STYLE_TAB_UP);
        tabUp.backgroundImageId("tab_up_background");
        tabUp.layoutWidth(FILL_PARENT);
        tabUp.createState(State.Selected, State.Selected).backgroundImageId("tab_up_backgrond_selected");
        Style tabUpButtonText = res.createSubstyle(STYLE_TAB_UP_BUTTON_TEXT);
        tabUpButtonText.textColor(0x000000).fontSize(12).alignment(Align.Center);
        tabUpButtonText.createState(State.Selected, State.Selected).textColor(0x000000);
        tabUpButtonText.createState(State.Selected|State.Focused, State.Selected|State.Focused).textColor(0x000000);
        tabUpButtonText.createState(State.Focused, State.Focused).textColor(0x000000);
        tabUpButtonText.createState(State.Hovered, State.Hovered).textColor(0xFFE0E0);
        Style tabUpButton = res.createSubstyle(STYLE_TAB_UP_BUTTON);
        tabUpButton.backgroundImageId("tab_btn_up");
        //tabUpButton.backgroundImageId("tab_btn_up_normal");
        //tabUpButton.createState(State.Selected, State.Selected).backgroundImageId("tab_btn_up_selected");
        //tabUpButton.createState(State.Selected|State.Focused, State.Selected|State.Focused).backgroundImageId("tab_btn_up_focused_selected");
        //tabUpButton.createState(State.Focused, State.Focused).backgroundImageId("tab_btn_up_focused");
        //tabUpButton.createState(State.Hovered, State.Hovered).backgroundImageId("tab_btn_up_hover");
        Style tabHost = res.createSubstyle(STYLE_TAB_HOST);
        tabHost.layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT);
        tabHost.backgroundColor(0xF0F0F0);
        Style tabWidget = res.createSubstyle(STYLE_TAB_WIDGET);
        tabWidget.setPadding(3,3,3,3).backgroundColor(0xEEEEEE);
        //tabWidget.backgroundImageId("frame_blue");
        //res.dumpStats();

        Style mainMenu = res.createSubstyle(STYLE_MAIN_MENU).backgroundColor(0xEFEFF2).layoutWidth(FILL_PARENT);
        Style mainMenuItem = res.createSubstyle(STYLE_MAIN_MENU_ITEM).setPadding(4,2,4,2).backgroundImageId("main_menu_item_background").textFlags(TEXT_FLAGS_USE_PARENT);
        Style menuItem = res.createSubstyle(STYLE_MENU_ITEM).setPadding(4,2,4,2); //.backgroundColor(0xE0E080)   ;
        menuItem.createState(State.Focused, State.Focused).backgroundColor(0x40C0C000);
        menuItem.createState(State.Pressed, State.Pressed).backgroundColor(0x4080C000);
        menuItem.createState(State.Selected, State.Selected).backgroundColor(0x00F8F9Fa);
        menuItem.createState(State.Hovered, State.Hovered).backgroundColor(0xC0FFFF00);
        res.createSubstyle(STYLE_MENU_ICON).setMargins(2,2,2,2).alignment(Align.VCenter|Align.Left).createState(State.Enabled,0).alpha(0xA0);
        res.createSubstyle(STYLE_MENU_LABEL).setMargins(4,2,4,2).alignment(Align.VCenter|Align.Left).textFlags(TextFlag.UnderlineHotKeys).createState(State.Enabled,0).textColor(0x80404040);
        res.createSubstyle(STYLE_MAIN_MENU_LABEL).setMargins(4,2,4,2).alignment(Align.VCenter|Align.Left).textFlags(TEXT_FLAGS_USE_PARENT).createState(State.Enabled,0).textColor(0x80404040);
        res.createSubstyle(STYLE_MENU_ACCEL).setMargins(4,2,4,2).alignment(Align.VCenter|Align.Left).createState(State.Enabled,0).textColor(0x80404040);

        Style transparentButtonBackground = res.createSubstyle(STYLE_TRANSPARENT_BUTTON_BACKGROUND).backgroundImageId("transparent_button_background").setPadding(4,2,4,2); //.backgroundColor(0xE0E080)   ;
        //transparentButtonBackground.createState(State.Focused, State.Focused).backgroundColor(0xC0C0C000);
        //transparentButtonBackground.createState(State.Pressed, State.Pressed).backgroundColor(0x4080C000);
        //transparentButtonBackground.createState(State.Selected, State.Selected).backgroundColor(0x00F8F9Fa);
        //transparentButtonBackground.createState(State.Hovered, State.Hovered).backgroundColor(0xD0FFFF00);

        Style poopupMenu = res.createSubstyle(STYLE_POPUP_MENU).backgroundImageId("popup_menu_background_normal");

        Style listItem = res.createSubstyle(STYLE_LIST_ITEM).backgroundImageId("list_item_background");
        //listItem.createState(State.Selected, State.Selected).backgroundColor(0xC04040FF).textColor(0x000000);
        //listItem.createState(State.Enabled, 0).textColor(0x80000000); // half transparent text for disabled item

        Style editLine = res.createSubstyle(STYLE_EDIT_LINE).backgroundImageId("editbox_background")
            .setPadding(5,6,5,6).setMargins(2,2,2,2).minWidth(40)
            .fontFace("Arial").fontFamily(FontFamily.SansSerif).fontSize(16);
        Style editBox = res.createSubstyle(STYLE_EDIT_BOX).backgroundImageId("editbox_background")
            .setPadding(5,6,5,6).setMargins(2,2,2,2).minWidth(100).minHeight(60).layoutHeight(FILL_PARENT).layoutWidth(FILL_PARENT)
            .fontFace("Courier New").fontFamily(FontFamily.MonoSpace).fontSize(16);
    }

    return res;
}

/// decode comma delimited dimension list or single value - and put to Rect
Rect decodeRect(string s) {
    uint[6] values;
    int valueCount = 0;
    int start = 0;
    for (int i = 0; i <= s.length; i++) {
        if (i == s.length || s[i] == ',') {
            if (i > start) {
                string item = s[start .. i];
                values[valueCount++] = decodeDimension(item);
                if (valueCount >= 6)
                    break;
            }
            start = i + 1;
        }
    }
    if (valueCount == 1) // same value for all dimensions
        return Rect(values[0], values[0], values[0], values[0]);
    else if (valueCount == 2) // one value of horizontal, and one for vertical
        return Rect(values[0], values[1], values[0], values[1]);
    else if (valueCount == 4) // separate left, top, right, bottom
        return Rect(values[0], values[1], values[2], values[3]);
    Log.e("Invalid rect attribute value ", s);
    return Rect(0,0,0,0);
}

private import std.array : split;

/// Decode color list attribute, e.g.: "#84A, #99FFFF" -> [0x8844aa, 0x99ffff]
uint[] decodeFocusRectColors(string s) {
    if (s.equal("@null"))
        return [COLOR_UNSPECIFIED];
    string[] colors = split(s, ",");
    if (colors.length < 1)
        return null;
    uint[] res = new uint[colors.length];
    for (int i = 0; i < colors.length; i++) {
        uint cl = decodeHexColor(colors[i], COLOR_UNSPECIFIED);
        if (cl == COLOR_UNSPECIFIED)
            return null;
        res[i] = cl;
    }
    return res;
}

/// parses string like "Left|VCenter" to bit set of Align flags
ubyte decodeAlignment(string s) {
    ubyte res = 0;
    int start = 0;
    for (int i = 0; i <= s.length; i++) {
        if (i == s.length || s[i] == '|') {
            if (i > start) {
                string item = s[start .. i];
                if (item.equal("Left"))
                    res |= Align.Left;
                else if (item.equal("Right"))
                    res |= Align.Right;
                else if (item.equal("Top"))
                    res |= Align.Top;
                else if (item.equal("Bottom"))
                    res |= Align.Bottom;
                else if (item.equal("HCenter"))
                    res |= Align.HCenter;
                else if (item.equal("VCenter"))
                    res |= Align.VCenter;
                else if (item.equal("Center"))
                    res |= Align.Center;
                else if (item.equal("TopLeft"))
                    res |= Align.TopLeft;
                else
                    Log.e("unknown Align value: ", item);
            }
            start = i + 1;
        }
    }
    return res;
}

/// parses string like "HotKeys|UnderlineHotKeysWhenAltPressed" to bit set of TextFlag flags
uint decodeTextFlags(string s) {
    uint res = 0;
    int start = 0;
    for (int i = 0; i <= s.length; i++) {
        if (i == s.length || s[i] == '|') {
            if (i > start) {
                string item = s[start .. i];
                if (item.equal("HotKeys"))
                    res |= TextFlag.HotKeys;
                else if (item.equal("UnderlineHotKeys"))
                    res |= TextFlag.UnderlineHotKeys;
                else if (item.equal("UnderlineHotKeysWhenAltPressed"))
                    res |= TextFlag.UnderlineHotKeysWhenAltPressed;
                else if (item.equal("Underline"))
                    res |= TextFlag.Underline;
                else if (item.equal("Unspecified"))
                    res = TEXT_FLAGS_UNSPECIFIED;
                else if (item.equal("Parent"))
                    res = TEXT_FLAGS_USE_PARENT;
                else
                    Log.e("unknown text flag value: ", item);
            }
            start = i + 1;
        }
    }
    return res;
}

/// decode FontFamily item name to value
FontFamily decodeFontFamily(string s) {
    if (s.equal("SansSerif"))
        return FontFamily.SansSerif;
    if (s.equal("Serif"))
        return FontFamily.Serif;
    if (s.equal("Cursive"))
        return FontFamily.Cursive;
    if (s.equal("Fantasy"))
        return FontFamily.Fantasy;
    if (s.equal("MonoSpace"))
        return FontFamily.MonoSpace;
    if (s.equal("Unspecified"))
        return FontFamily.Unspecified;
    Log.e("unknown font family ", s);
    return FontFamily.SansSerif;
}

/// decode FontWeight item name to value
FontWeight decodeFontWeight(string s) {
    if (s.equal("bold"))
        return FontWeight.Bold;
    if (s.equal("normal"))
        return FontWeight.Normal;
    Log.e("unknown font weight ", s);
    return FontWeight.Normal;
}

/// decode layout dimension (FILL_PARENT, WRAP_CONTENT, or just size)
int decodeLayoutDimension(string s) {
    if (s.equal("FILL_PARENT") || s.equal("fill"))
        return FILL_PARENT;
    if (s.equal("WRAP_CONTENT") || s.equal("wrap"))
        return WRAP_CONTENT;
    return decodeDimension(s);
}

/// remove superfluous space characters from a border property
string sanitizeBorderProperty(string s) pure {
    string[] parts = s.split(',');
    foreach (ref part; parts)
        part = part.strip();
    string joined = parts.join(',');

    char[] res;
    // replace repeating space characters with one space
    import std.ascii : isWhite;
    bool isSpace;
    foreach (c; joined) {
        if (isWhite(c)) {
            if (!isSpace) {
                res ~= ' ';
                isSpace = true;
            }
        } else {
            res ~= c;
            isSpace = false;
        }
    }

    return cast(string)res;
}

/// remove superfluous space characters from a box shadow property
string sanitizeBoxShadowProperty(string s) pure {
    return sanitizeBorderProperty(s);
}

/// load style attributes from XML element
bool loadStyleAttributes(Style style, Element elem, bool allowStates) {
    //Log.d("Theme: loadStyleAttributes ", style.id, " ", elem.tag.attr);
    if ("backgroundImageId" in elem.tag.attr)
        style.backgroundImageId = elem.tag.attr["backgroundImageId"];
    if ("backgroundColor" in elem.tag.attr)
        style.backgroundColor = decodeHexColor(elem.tag.attr["backgroundColor"]);
    if ("textColor" in elem.tag.attr)
        style.textColor = decodeHexColor(elem.tag.attr["textColor"]);
    if ("margins" in elem.tag.attr)
        style.margins = decodeRect(elem.tag.attr["margins"]);
    if ("padding" in elem.tag.attr)
        style.padding = decodeRect(elem.tag.attr["padding"]);
    if ("border" in elem.tag.attr)
        style.border = sanitizeBorderProperty(elem.tag.attr["border"]);
    if ("boxShadow" in elem.tag.attr)
        style.boxShadow = sanitizeBoxShadowProperty(elem.tag.attr["boxShadow"]);
    if ("align" in elem.tag.attr)
        style.alignment = decodeAlignment(elem.tag.attr["align"]);
    if ("minWidth" in elem.tag.attr)
        style.minWidth = decodeDimension(elem.tag.attr["minWidth"]);
    if ("maxWidth" in elem.tag.attr)
        style.maxWidth = decodeDimension(elem.tag.attr["maxWidth"]);
    if ("minHeight" in elem.tag.attr)
        style.minHeight = decodeDimension(elem.tag.attr["minHeight"]);
    if ("maxHeight" in elem.tag.attr)
        style.maxHeight = decodeDimension(elem.tag.attr["maxHeight"]);
    if ("maxLines" in elem.tag.attr)
        style.maxLines = decodeDimension(elem.tag.attr["maxLines"]);
    if ("fontFace" in elem.tag.attr)
        style.fontFace = elem.tag.attr["fontFace"];
    if ("fontFamily" in elem.tag.attr)
        style.fontFamily = decodeFontFamily(elem.tag.attr["fontFamily"]);
    if ("fontSize" in elem.tag.attr)
        style.fontSize = cast(int)decodeDimension(elem.tag.attr["fontSize"]);
    if ("fontWeight" in elem.tag.attr)
        style.fontWeight = cast(ushort)decodeFontWeight(elem.tag.attr["fontWeight"]);
    if ("layoutWidth" in elem.tag.attr)
        style.layoutWidth = decodeLayoutDimension(elem.tag.attr["layoutWidth"]);
    if ("layoutHeight" in elem.tag.attr)
        style.layoutHeight = decodeLayoutDimension(elem.tag.attr["layoutHeight"]);
    if ("alpha" in elem.tag.attr)
        style.alpha = decodeDimension(elem.tag.attr["alpha"]);
    if ("textFlags" in elem.tag.attr)
        style.textFlags = decodeTextFlags(elem.tag.attr["textFlags"]);
    if ("focusRectColors" in elem.tag.attr)
        style.focusRectColors = decodeFocusRectColors(elem.tag.attr["focusRectColors"]);
    foreach(item; elem.elements) {
        if (allowStates && item.tag.name.equal("state")) {
            uint stateMask = 0;
            uint stateValue = 0;
            extractStateFlags(item.tag.attr, stateMask, stateValue);
            if (stateMask) {
                Style state = style.getOrCreateState(stateMask, stateValue);
                loadStyleAttributes(state, item, false);
            }
        } else if (item.tag.name.equal("drawable")) {
            // <drawable id="scrollbar_button_up" value="scrollbar_btn_up"/>
            string drawableid = attrValue(item, "id");
            string drawablevalue = attrValue(item, "value");
            if (drawableid)
                style.setCustomDrawable(drawableid, drawablevalue);
        } else if (item.tag.name.equal("color")) {
            // <color id="buttons_panel_color" value="#303080"/>
            string colorid = attrValue(item, "id");
            string colorvalue = attrValue(item, "value");
            uint color = decodeHexColor(colorvalue, COLOR_TRANSPARENT);
            if (colorid)
                style.setCustomColor(colorid, color);
        } else if (item.tag.name.equal("length")) {
            // <length id="overlap" value="2"/>
            string lenid = attrValue(item, "id");
            string lenvalue = attrValue(item, "value");
            uint len = decodeDimension(lenvalue);
            if (lenid.length > 0 && len > 0)
                style.setCustomLength(lenid, len);
        }
    }
    return true;
}

/**
 * load theme from XML document
 *
 * Sample:
 * ---
 * <?xml version="1.0" encoding="utf-8"?>
 * <theme id="theme_custom" parent="theme_default">
 *       <style id="BUTTON"
 *             backgroundImageId="btn_background"
 *          >
 *       </style>
 * </theme>
 * ---
 *
 */
bool loadTheme(Theme theme, Element doc, int level = 0) {
    if (!doc.tag.name.equal("theme")) {
        Log.e("<theme> element should be main in theme file!");
        return false;
    }
    // <theme>
    string id = attrValue(doc, "id");
    string parent = attrValue(doc, "parent");
    theme.id = id;
    if (parent.length > 0) {
        // load base theme
        if (level < 3) // to prevent infinite recursion
            loadTheme(theme, parent, level + 1);
    }
    loadStyleAttributes(theme, doc, false);
    foreach(styleitem; doc.elements) {
        if (styleitem.tag.name.equal("style")) {
            // load <style>
            string styleid = attrValue(styleitem, "id");
            string styleparent = attrValue(styleitem, "parent");
            if (styleid.length) {
                // create new style
                Style parentStyle = null;
                parentStyle = theme.get(styleparent);
                Style style = parentStyle.createSubstyle(styleid);
                loadStyleAttributes(style, styleitem, true);
            } else {
                Log.e("style without ID in theme file");
            }
        }
    }
    return true;
}

/// load theme from file
bool loadTheme(Theme theme, string resourceId, int level = 0) {

    string filename;
    try {
        filename = drawableCache.findResource(WIDGET_STYLE_CONSOLE ? "console_" ~ resourceId : resourceId);
        if (!filename || !filename.endsWith(".xml"))
            return false;
        string s = cast(string)loadResourceBytes(filename);
        if (!s) {
            Log.e("Cannot read XML resource ", resourceId, " from file ", filename);
            return false;
        }

        // Check for well-formedness
        //check(s);

        // Make a DOM tree
        auto doc = new Document(s);

        return loadTheme(theme, doc);
    } catch (CheckException e) {
        Log.e("Invalid XML resource ", resourceId);
        return false;
    }
}

/// load theme from XML file (null if failed)
Theme loadTheme(string resourceId) {
    Theme res = new Theme(resourceId);
    if (loadTheme(res, resourceId)) {
        res.id = resourceId;
        return res;
    }
    destroy(res);
    return null;
}

/// custom drawable attribute container for styles
class DrawableAttribute {
protected:
    string _id;
    string _drawableId;
    DrawableRef _drawable;
    bool _initialized;

public:
    this(string id, string drawableId) {
        _id = id;
        _drawableId = drawableId;
    }
    ~this() {
        clear();
    }
    @property string id() const { return _id; }
    @property string drawableId() const { return _drawableId; }
    @property void drawableId(string newDrawable) { _drawableId = newDrawable; clear(); }
    @property ref DrawableRef drawable() const {
        if (!_drawable.isNull)
            return (cast(DrawableAttribute)this)._drawable;
        (cast(DrawableAttribute)this)._drawable = drawableCache.get(_drawableId);
        (cast(DrawableAttribute)this)._initialized = true;
        return (cast(DrawableAttribute)this)._drawable;
    }
    void clear() {
        _drawable.clear();
        _initialized = false;
    }
    void onThemeChanged() {
        if (!_drawableId) {
            _drawable.clear();
            _initialized = false;
        }
    }
}

/// returns custom drawable replacement id for specified id from current theme, or returns passed value if not found or no current theme
string overrideCustomDrawableId(string id) {
    string res = currentTheme ? currentTheme.customDrawableId(id) : id;
    return !res ? id : res;
}

shared static ~this() {
    currentTheme = null;
}




unittest {
    assert(sanitizeBorderProperty("   #aaa, 2  ") == "#aaa,2");
    assert(sanitizeBorderProperty("   #aaa, 2, 2, 2, 4") == "#aaa,2,2,2,4");
    assert(sanitizeBorderProperty("   #a aa  ,  2   4  ") == "#a aa,2 4");
}
