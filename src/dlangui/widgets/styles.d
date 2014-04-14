module dlangui.widgets.styles;

import dlangui.core.types;
import dlangui.graphics.fonts;
import dlangui.graphics.drawbuf;
//import dlangui.graphics.images;
import dlangui.graphics.resources;

immutable ubyte ALIGN_UNSPECIFIED = 0;
immutable uint COLOR_UNSPECIFIED = 0xFFDEADFF;
immutable uint COLOR_TRANSPARENT = 0xFFFFFFFF;
immutable ushort FONT_SIZE_UNSPECIFIED = 0xFFFF;
immutable ushort FONT_WEIGHT_UNSPECIFIED = 0x0000;
immutable ubyte FONT_STYLE_UNSPECIFIED = 0xFF;
immutable ubyte FONT_STYLE_NORMAL = 0x00;
immutable ubyte FONT_STYLE_ITALIC = 0x01;
/// use as widget.layout() param to avoid applying of parent size
immutable int SIZE_UNSPECIFIED = int.max;

immutable int FILL_PARENT = int.max - 1;
immutable int WRAP_CONTENT = int.max - 2;
immutable int WEIGHT_UNSPECIFIED = -1;

enum Align : ubyte {
    Unspecified = ALIGN_UNSPECIFIED,
    Left = 1,
    Right = 2,
    HCenter = 1 | 2,
    Top = 4,
    Bottom = 8,
    VCenter = 4 | 8,
    Center = VCenter | HCenter,
	TopLeft = Left | Top,
}

class DrawableAttribute {
    protected string _id;
    protected string _drawableId;
    protected DrawableRef _drawable;
    protected bool _initialized;
    this(string id, string drawableId) {
        _id = id;
        _drawableId = drawableId;
    }
    @property string id() const { return _id; }
    @property string drawableId() const { return _drawableId; }
    @property void drawableId(string newDrawable) { _drawableId = newDrawable; clear(); }
    @property ref DrawableRef drawable() const {
        if (!_drawable.isNull)
            return (cast(DrawableAttribute)this)._drawable;
        (cast(DrawableAttribute)this)._drawable = drawableCache.get(_id);
        (cast(DrawableAttribute)this)._initialized = true;
        return (cast(DrawableAttribute)this)._drawable;
    }
    void clear() {
        _drawable.clear();
        _initialized = false;
    }
}

/// style properties
class Style {
	protected string _id;
	protected Theme _theme;
	protected Style _parentStyle;
	protected string _parentId;
	protected uint _stateMask;
	protected uint _stateValue;
	protected ubyte _align = Align.TopLeft;
	protected ubyte _fontStyle = FONT_STYLE_UNSPECIFIED;
	protected FontFamily _fontFamily = FontFamily.Unspecified;
	protected ushort _fontSize = FONT_SIZE_UNSPECIFIED;
	protected ushort _fontWeight = FONT_WEIGHT_UNSPECIFIED;
	protected uint _backgroundColor = COLOR_UNSPECIFIED;
	protected uint _textColor = COLOR_UNSPECIFIED;
	protected string _fontFace;
	protected string _backgroundImageId;
	protected Rect _padding;
	protected Rect _margins;
    protected int _minWidth = SIZE_UNSPECIFIED;
    protected int _maxWidth = SIZE_UNSPECIFIED;
    protected int _minHeight = SIZE_UNSPECIFIED;
    protected int _maxHeight = SIZE_UNSPECIFIED;
    protected int _layoutWidth = SIZE_UNSPECIFIED;
    protected int _layoutHeight = SIZE_UNSPECIFIED;
    protected int _layoutWeight = WEIGHT_UNSPECIFIED;

	protected Style[] _substates;
	protected Style[] _children;

    protected DrawableAttribute[string] _customDrawables;

	protected FontRef _font;
	protected DrawableRef _backgroundDrawable;

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

	@property const(Style) parentStyle() const {
		if (_parentStyle !is null)
			return _parentStyle;
		if (_parentId !is null && currentTheme !is null)
			return currentTheme.get(_parentId);
		return currentTheme;
	}

	@property Style parentStyle() {
		if (_parentStyle !is null)
			return _parentStyle;
		if (_parentId !is null && currentTheme !is null)
			return currentTheme.get(_parentId);
		return currentTheme;
	}

    @property ref DrawableRef backgroundDrawable() const {
		if (!(cast(Style)this)._backgroundDrawable.isNull)
			return (cast(Style)this)._backgroundDrawable;
        string image = backgroundImageId;
        if (image !is null) {
            (cast(Style)this)._backgroundDrawable = drawableCache.get(image);
        } else {
            uint color = backgroundColor;
            (cast(Style)this)._backgroundDrawable = new SolidFillDrawable(color);
        }
        return (cast(Style)this)._backgroundDrawable;
    }

    /// get custom drawable attribute
    @property ref DrawableRef customDrawable(string id) {
        if (id in _customDrawables)
            return _customDrawables[id].drawable;
        return parentStyle.customDrawable(id);
    }

    /// get custom drawable attribute
    @property string customDrawableId(string id) const {
        if (id in _customDrawables)
            return _customDrawables[id].drawableId;
        return parentStyle.customDrawableId(id);
    }

    /// sets custom drawable attribute for style
    Style setCustomDrawable(string id, string resourceId) {
        if (id in _customDrawables)
            _customDrawables[id].drawableId = resourceId;
        else
            _customDrawables[id] = new DrawableAttribute(id, resourceId);
        return this;
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
	@property ushort fontSize() const {
        if (_fontSize != FONT_SIZE_UNSPECIFIED)
            return _fontSize;
        else
            return parentStyle.fontSize;
	}

    //===================================================
    // layout parameters: margins / padding

	/// padding
	@property ref const(Rect) padding() const {
		if (_stateValue != 0)
			return parentStyle._padding;
		return _padding;
	}

	/// margins
	@property ref const(Rect) margins() const {
		if (_stateValue != 0)
			return parentStyle._margins;
		return _margins;
	}

	/// text color
	@property uint textColor() const {
        if (_textColor != COLOR_UNSPECIFIED)
            return _textColor;
        else
            return parentStyle.textColor;
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

	/// font size
	@property string backgroundImageId() const {
        if (_backgroundImageId !is null)
            return _backgroundImageId;
        else
            return parentStyle.backgroundImageId;
	}

    //===================================================
    // size restrictions

	/// minimal width constraint, 0 if limit is not set
	@property uint minWidth() const {
        if (_minWidth != SIZE_UNSPECIFIED)
            return _minWidth;
        else
            return parentStyle.minWidth;
	}
	/// max width constraint, returns SIZE_UNSPECIFIED if limit is not set
	@property uint maxWidth() const {
        if (_maxWidth != SIZE_UNSPECIFIED)
            return _maxWidth;
        else
            return parentStyle.maxWidth;
	}
	/// minimal height constraint, 0 if limit is not set
	@property uint minHeight() const {
        if (_minHeight != SIZE_UNSPECIFIED)
            return _minHeight;
        else
            return parentStyle.minHeight;
	}
	/// max height constraint, SIZE_UNSPECIFIED if limit is not set
	@property uint maxHeight() const {
        if (_maxHeight != SIZE_UNSPECIFIED)
            return _maxHeight;
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
		_fontFace = face;
		_font.clear();
		return this;
	}

	@property Style fontFamily(FontFamily family) {
		_fontFamily = family;
		_font.clear();
		return this;
	}

	@property Style fontStyle(ubyte style) {
		_fontStyle = style;
		_font.clear();
		return this;
	}

	@property Style fontWeight(ushort weight) {
		_fontWeight = weight;
		_font.clear();
		return this;
	}

	@property Style fontSize(ushort size) {
		_fontSize = size;
		_font.clear();
		return this;
	}

	@property Style textColor(uint color) {
		_textColor = color;
		return this;
	}

	@property Style backgroundColor(uint color) {
		_backgroundColor = color;
        _backgroundImageId = null;
		_backgroundDrawable.clear();
		return this;
	}

	@property Style backgroundImageId(string image) {
		_backgroundImageId = image;
		_backgroundDrawable.clear();
		return this;
	}

	@property Style margins(Rect rc) {
		_margins = rc;
		return this;
	}

	@property Style padding(Rect rc) {
		_padding = rc;
		return this;
	}

	private static int _instanceCount;
	this(Theme theme, string id) {
		_theme = theme;
		_parentStyle = theme;
		_id = id;
		Log.d("Created style ", _id, ", count=", ++_instanceCount);
	}

	~this() {
		foreach(ref Style item; _substates) {
			Log.d("Destroying substate");
			destroy(item);
			item = null;
		}
		_substates.clear();
		foreach(ref Style item; _children) {
			destroy(item);
			item = null;
		}
		_children.clear();
		_backgroundDrawable.clear();
		_font.clear();
		Log.d("Destroyed style ", _id, ", parentId=", _parentId, ", state=", _stateMask, ", count=", --_instanceCount);
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
		Log.d("Creating substate ", stateMask);
		Style child = (_theme !is null ? _theme : currentTheme).createSubstyle(null);
		child._parentStyle = this;
		child._stateMask = stateMask;
		child._stateValue = stateValue;
		child._backgroundColor = COLOR_UNSPECIFIED;
		_substates ~= child;
		return child;
	}

	/// find substyle based on widget state (e.g. focused, pressed, ...)
	const(Style) forState(uint state) const {
		if (state == 0)
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
		_backgroundColor = 0xFFFFFFFF; // transparent
		_textColor = 0x000000; // black
		_align = Align.TopLeft;
		_fontSize = 24; // TODO: from settings or screen properties / DPI
		_fontStyle = FONT_STYLE_NORMAL;
		_fontWeight = 400;
		_fontFace = "Arial"; // TODO: from settings
        _fontFamily = FontFamily.SansSerif;
        _minHeight = 0;
        _minWidth = 0;
        _layoutWidth = WRAP_CONTENT;
        _layoutHeight = WRAP_CONTENT;
        _layoutWeight = 1;
	}
	
	~this() {
		Log.d("Theme destructor");
		foreach(ref Style item; _byId) {
			destroy(item);
			item = null;
		}
		_byId.clear();
	}

	/// create wrapper style which will have currentTheme.get(id) as parent instead of fixed parent - to modify some base style properties in widget
	Style modifyStyle(string id) {
		Style style = new Style(null, null);
		style._parentId = id;
        style._align = Align.Unspecified; // inherit
		return style;
	}

	// ================================================
	// override to avoid infinite recursion
	/// font size
	@property override string backgroundImageId() const {
        return _backgroundImageId;
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
    @property override ref DrawableRef customDrawable(string id) const {
        if (id in _customDrawables)
            return _customDrawables[id].drawable;
        return (cast(Theme)this)._emptyDrawable;
    }

    @property override string customDrawableId(string id) const {
        if (id in _customDrawables)
            return _customDrawables[id].drawableId;
        return null;
    }

	/// create new named style
	override Style createSubstyle(string id) {
		Style style = new Style(this, id);
		if (id !is null)
			_byId[id] = style;
        style._parentStyle = this; // as initial value, use theme as parent
		return style;
	}

	/// find style by id, returns theme if not style with specified ID is not found
	@property Style get(string id) {
		if (id !is null && id in _byId)
			return _byId[id];
		return this;
	}
	
	/// find substyle based on widget state (e.g. focused, pressed, ...)
	override const(Style) forState(uint state) const {
		return this;
	}

	void dumpStats() {
		Log.d("Theme ", _id, ": children:", _children.length, ", substates:", _substates.length, ", mapsize:", _byId.length);
	}
}

/// to access current theme
private __gshared Theme _currentTheme;
@property Theme currentTheme() { return _currentTheme; }
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
    res.fontSize(24);
    Style button = res.createSubstyle("BUTTON").backgroundImageId("btn_default_small").alignment(Align.Center);
    Style buttonTransparent = res.createSubstyle("BUTTON_TRANSPARENT").backgroundImageId("btn_default_small_transparent").alignment(Align.Center);
    Style text = res.createSubstyle("TEXT").margins(Rect(2,2,2,2)).padding(Rect(1,1,1,1));
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

    Style scrollbar = res.createSubstyle("SCROLLBAR");
    scrollbar.backgroundColor(0xC0808080);
    Style scrollbarButton = button.createSubstyle("SCROLLBAR_BUTTON");
    Style scrollbarSlider = res.createSubstyle("SLIDER");
    Style scrollbarPage = res.createSubstyle("PAGE_SCROLL").backgroundColor(0xFFFFFFFF);
    scrollbarPage.createState(State.Pressed, State.Pressed).backgroundColor(0xC0404080);
    scrollbarPage.createState(State.Hovered, State.Hovered).backgroundColor(0xF0404080);

    Style tabUp = res.createSubstyle("TAB_UP");
    tabUp.backgroundImageId("tab_up_background");
    tabUp.layoutWidth(FILL_PARENT);
    tabUp.createState(State.Selected, State.Selected).backgroundImageId("tab_up_backgrond_selected");
    Style tabUpButtonText = res.createSubstyle("TAB_UP_BUTTON_TEXT");
    tabUpButtonText.textColor(0x000000).fontSize(12).alignment(Align.Center);
    tabUpButtonText.createState(State.Selected, State.Selected).textColor(0x000000);
    tabUpButtonText.createState(State.Selected|State.Focused, State.Selected|State.Focused).textColor(0x000000);
    tabUpButtonText.createState(State.Focused, State.Focused).textColor(0x000000);
    tabUpButtonText.createState(State.Hovered, State.Hovered).textColor(0xFFE0E0);
    Style tabUpButton = res.createSubstyle("TAB_UP_BUTTON");
    tabUpButton.backgroundImageId("tab_btn_up");
    //tabUpButton.backgroundImageId("tab_btn_up_normal");
    //tabUpButton.createState(State.Selected, State.Selected).backgroundImageId("tab_btn_up_selected");
    //tabUpButton.createState(State.Selected|State.Focused, State.Selected|State.Focused).backgroundImageId("tab_btn_up_focused_selected");
    //tabUpButton.createState(State.Focused, State.Focused).backgroundImageId("tab_btn_up_focused");
    //tabUpButton.createState(State.Hovered, State.Hovered).backgroundImageId("tab_btn_up_hover");
    Style tabHost = res.createSubstyle("TAB_HOST");
    tabHost.layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT);
    tabHost.backgroundColor(0xF0F0F0);
    Style tabWidget = res.createSubstyle("TAB_WIDGET");
	tabWidget.padding(Rect(3,3,3,3)).backgroundColor(0xEEEEEE);
    //tabWidget.backgroundImageId("frame_blue");
	//res.dumpStats();

    Style mainMenu = res.createSubstyle("MAIN_MENU").backgroundColor(0xE0E0E0).layoutWidth(FILL_PARENT);
    Style menuItem = res.createSubstyle("MENU_ITEM").padding(Rect(4,2,4,2)).backgroundColor(0xE0E080)   ;
    menuItem.createState(State.Focused, State.Focused).backgroundColor(0x40C0C000);
    menuItem.createState(State.Pressed, State.Pressed).backgroundColor(0x4080C000);
    menuItem.createState(State.Hovered, State.Hovered).backgroundColor(0x80E0E000);

	return res;
}

shared static ~this() {
	currentTheme = null;
}