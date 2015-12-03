// Written in the D programming language.

/**
This module contains simple controls widgets implementation.

TextWidget - static text

ImageWidget - image

Button - button with only text

ImageButton - button with only image

ImageTextButton - button with text and image

ScrollBar - scrollbar control

UrlImageTextButton - URL link button

Synopsis:

----
import dlangui.widgets.controls;

----

Copyright: Vadim Lopatin, 2014
License:   Boost License 1.0
Authors:   Vadim Lopatin, coolreader.org@gmail.com
*/
module dlangui.widgets.controls;

import dlangui.widgets.widget;
import dlangui.widgets.layouts;
import dlangui.core.stdaction;

private import std.algorithm;
private import std.conv : to;
private import std.utf : toUTF32;

/// vertical spacer to fill empty space in vertical layouts
class VSpacer : Widget {
    this() {
        styleId = STYLE_VSPACER;
    }
    //override void measure(int parentWidth, int parentHeight) { 
    //    measuredContent(parentWidth, parentHeight, 8, 8);
    //}
}

/// horizontal spacer to fill empty space in horizontal layouts
class HSpacer : Widget {
    this() {
        styleId = STYLE_HSPACER;
    }
    //override void measure(int parentWidth, int parentHeight) { 
    //    measuredContent(parentWidth, parentHeight, 8, 8);
    //}
}

/// static text widget
class TextWidget : Widget {
    this(string ID = null, string textResourceId = null) {
		super(ID);
        styleId = STYLE_TEXT;
        _text = textResourceId;
    }
    this(string ID, dstring rawText) {
		super(ID);
        styleId = STYLE_TEXT;
        _text = rawText;
    }
    this(string ID, UIString uitext) {
		super(ID);
        styleId = STYLE_TEXT;
        _text = uitext;
    }

    /// max lines to show
    @property int maxLines() { return style.maxLines; }
    /// set max lines to show
    @property void maxLines(int n) { ownStyle.maxLines = n; }

    protected UIString _text;
    /// get widget text
    override @property dstring text() { return _text; }
    /// set text to show
    override @property Widget text(dstring s) { 
        _text = s; 
        requestLayout();
		return this;
    }
    /// set text to show
    override @property Widget text(UIString s) { 
        _text = s;
        requestLayout();
		return this;
    }
    /// set text resource ID to show
    @property Widget textResource(string s) { 
        _text = s; 
        requestLayout();
		return this;
    }

    override void measure(int parentWidth, int parentHeight) { 
        FontRef font = font();
        //auto measureStart = std.datetime.Clock.currAppTick;
        Point sz;
        if (maxLines == 1) {
		    sz = font.textSize(text, MAX_WIDTH_UNSPECIFIED, 4, 0, textFlags);
        } else {
            sz = font.measureMultilineText(text, maxLines, MAX_WIDTH_UNSPECIFIED, 4, 0, textFlags);
        }
        //auto measureEnd = std.datetime.Clock.currAppTick;
        //auto duration = measureEnd - measureStart;
        //if (duration.length > 10)
        //    Log.d("TextWidget measureText took ", duration.length, " ticks");
        measuredContent(parentWidth, parentHeight, sz.x, sz.y);
    }

    override void onDraw(DrawBuf buf) {
        if (visibility != Visibility.Visible)
            return;
        super.onDraw(buf);
        Rect rc = _pos;
        applyMargins(rc);
		auto saver = ClipRectSaver(buf, rc, alpha);
		applyPadding(rc);

        FontRef font = font();
        if (maxLines == 1) {
            Point sz = font.textSize(text);
            applyAlign(rc, sz);
		    font.drawText(buf, rc.left, rc.top, text, textColor, 4, 0, textFlags);
        } else {
            SimpleTextFormatter fmt;
            Point sz = fmt.format(text, font, maxLines, rc.width, 4, 0, textFlags);
            applyAlign(rc, sz);
            // TODO: apply align to alignment lines
            fmt.draw(buf, rc.left, rc.top, font, textColor);
        }
    }
}

/// static text widget with multiline text
class MultilineTextWidget : TextWidget {
    this(string ID = null, string textResourceId = null) {
		super(ID, textResourceId);
        styleId = STYLE_MULTILINE_TEXT;
    }
    this(string ID, dstring rawText) {
		super(ID, rawText);
        styleId = STYLE_MULTILINE_TEXT;
    }
    this(string ID, UIString uitext) {
		super(ID, uitext);
        styleId = STYLE_MULTILINE_TEXT;
    }
}

/// static image widget
class ImageWidget : Widget {

    protected string _drawableId;
    protected DrawableRef _drawable;

    this(string ID = null, string drawableId = null) {
		super(ID);
        _drawableId = drawableId;
	}

	~this() {
		_drawable.clear();
	}

    /// get drawable image id
    @property string drawableId() { return _drawableId; }
    /// set drawable image id
    @property ImageWidget drawableId(string id) { 
        _drawableId = id;
        _drawable.clear();
        requestLayout();
        return this;
    }
    /// get drawable
    @property ref DrawableRef drawable() {
        if (!_drawable.isNull)
            return _drawable;
        if (_drawableId !is null)
            _drawable = drawableCache.get(overrideCustomDrawableId(_drawableId));
        return _drawable;
    }
    /// set custom drawable (not one from resources)
    @property ImageWidget drawable(DrawableRef img) {
        _drawable = img;
        _drawableId = null;
        return this;
    }
    /// set custom drawable (not one from resources)
    @property ImageWidget drawable(string drawableId) {
        if (_drawableId.equal(drawableId))
            return this;
        _drawableId = drawableId; 
        _drawable.clear();
        requestLayout();
        return this;
    }

    /// set string property value, for ML loaders
    mixin(generatePropertySettersMethodOverride("setStringProperty", "string",
          "drawableId"));

    /// handle theme change: e.g. reload some themed resources
    override void onThemeChanged() {
        if (_drawableId !is null)
            _drawable.clear(); // remove cached drawable
    }

    override void measure(int parentWidth, int parentHeight) { 
        DrawableRef img = drawable;
        int w = 0;
        int h = 0;
        if (!img.isNull) {
            w = img.width;
            h = img.height;
        }
        measuredContent(parentWidth, parentHeight, w, h);
    }

    override void onDraw(DrawBuf buf) {
        if (visibility != Visibility.Visible)
            return;
        super.onDraw(buf);
        Rect rc = _pos;
        applyMargins(rc);
		auto saver = ClipRectSaver(buf, rc, alpha);
		applyPadding(rc);
        DrawableRef img = drawable;
        if (!img.isNull) {
            Point sz;
            sz.x = img.width;
            sz.y = img.height;
            applyAlign(rc, sz);
            uint st = state;
            img.drawTo(buf, rc, st);
        }
    }
}

/// button with image only
class ImageButton : ImageWidget {
    /// constructor by id and icon resource id
    this(string ID = null, string drawableId = null) {
        super(ID, drawableId);
        styleId = STYLE_BUTTON;
        _drawableId = drawableId;
        clickable = true;
        focusable = true;
        trackHover = true;
    }
    /// constructor from action
    this(const Action a) {
        this("imagebutton-action" ~ to!string(a.id), a.iconId);
        action = a;
    }
}

/// button with image and text
class ImageTextButton : HorizontalLayout {
    protected ImageWidget _icon;
    protected TextWidget _label;

    /// Get label text
    override @property dstring text() { return _label.text; }
    /// Set label plain unicode string
    override @property Widget text(dstring s) { _label.text = s; requestLayout(); return this; }
    /// Set label string resource Id
    override @property Widget text(UIString s) { _label.text = s; requestLayout(); return this; }
    
    /// Returns orientation: Vertical - image top, Horizontal - image left"
    override @property Orientation orientation() {
        return super.orientation();
    }

    /// Sets orientation: Vertical - image top, Horizontal - image left"
    override @property LinearLayout orientation(Orientation value) {
        if (!_icon || !_label)
            return super.orientation(value);
        if (value != orientation) {
            super.orientation(value);
            if (value == Orientation.Horizontal) {
                _icon.alignment = Align.Left | Align.VCenter;
                _label.alignment = Align.Right | Align.VCenter;
            } else {
                _icon.alignment = Align.Top | Align.HCenter;
                _label.alignment = Align.Bottom | Align.HCenter;
            }
        }
        return this; 
    }

    protected void init(string drawableId, UIString caption) {
        styleId = STYLE_BUTTON;
        _icon = new ImageWidget("icon", drawableId);
        _icon.styleId = STYLE_BUTTON_IMAGE;
        _label = new TextWidget("label", caption);
        _label.styleId = STYLE_BUTTON_LABEL;
        _icon.state = State.Parent;
        _label.state = State.Parent;
        addChild(_icon);
        addChild(_label);
        clickable = true;
        focusable = true;
        trackHover = true;
    }

    this(string ID = null, string drawableId = null, string textResourceId = null) {
        super(ID);
        UIString caption = textResourceId;
        init(drawableId, caption);
    }

    this(string ID, string drawableId, dstring rawText) {
        super(ID);
        UIString caption = rawText;
        init(drawableId, caption);
    }

    /// constructor from action
    this(const Action a) {
        super("imagetextbutton-action" ~ to!string(a.id));
        init(a.iconId, a.labelValue);
        action = a;
    }

}

/// button - url
class UrlImageTextButton : ImageTextButton {
    this(string ID, dstring labelText, string url, string icon = "applications-internet") {
        super(ID, icon, labelText);
        Action a = ACTION_OPEN_URL.clone();
        a.label = labelText;
        a.stringParam = url;
        _action = a;
        styleId = null;
        //_icon.styleId = STYLE_BUTTON_IMAGE;
        //_label.styleId = STYLE_BUTTON_LABEL;
        //_label.textFlags(TextFlag.Underline);
        _label.styleId = "BUTTON_LABEL_LINK";
        padding(Rect(3,3,3,3));
    }
}



/// checkbox
class CheckBox : ImageTextButton {
    this(string ID = null, string textResourceId = null) {
        super(ID, "btn_check", textResourceId);
    }
    this(string ID, dstring labelText) {
        super(ID, "btn_check", labelText);
    }
    this(string ID, UIString label) {
        super(ID, "btn_check", label);
    }
    override protected void init(string drawableId, UIString caption) {
        super.init(drawableId, caption);
        styleId = STYLE_CHECKBOX;
        if (_icon)
            _icon.styleId = STYLE_CHECKBOX_IMAGE;
        if (_label)
            _label.styleId = STYLE_CHECKBOX_LABEL;
        checkable = true;
    }
    // called to process click and notify listeners
    override protected bool handleClick() {
        checked = !checked;
        return super.handleClick();
    }
}

/// radio button
class RadioButton : ImageTextButton {
    this(string ID = null, string textResourceId = null) {
        super(ID, "btn_radio", textResourceId);
    }
    this(string ID, dstring labelText) {
        super(ID, "btn_radio", labelText);
    }
    override protected void init(string drawableId, UIString caption) {
        super.init(drawableId, caption);
        styleId = STYLE_RADIOBUTTON;
        if (_icon)
            _icon.styleId = STYLE_RADIOBUTTON_IMAGE;
        if (_label)
            _label.styleId = STYLE_RADIOBUTTON_LABEL;
        checkable = true;
    }

	void uncheckSiblings() {
		Widget p = parent;
		if (!p)
			return;
		for (int i = 0; i < p.childCount; i++) {
			Widget child = p.child(i);
			if (child is this)
				continue;
			RadioButton rb = cast(RadioButton)child;
			if (rb)
				rb.checked = false;
		}
	}

    // called to process click and notify listeners
    override protected bool handleClick() {
		uncheckSiblings();
        checked = true;

        return super.handleClick();
    }

}

/// Text only button
class Button : Widget {
    protected UIString _text;
    override @property dstring text() { return _text; }
    override @property Widget text(dstring s) { _text = s; requestLayout(); return this; }
    override @property Widget text(UIString s) { _text = s; requestLayout(); return this; }
    @property Widget textResource(string s) { _text = s; requestLayout(); return this; }
    /// empty parameter list constructor - for usage by factory
    this() {
		super(null);
        init(UIString());
    }

    private void init(UIString label) {
        styleId = STYLE_BUTTON;
        _text = label;
		clickable = true;
        focusable = true;
        trackHover = true;
    }

    /// create with ID parameter
    this(string ID) {
		super(ID);
        init(UIString());
    }
    this(string ID, UIString label) {
		super(ID);
        init(label);
    }
    this(string ID, dstring label) {
		super(ID);
        init(UIString(label));
    }
    this(string ID, string labelResourceId) {
		super(ID);
        init(UIString(labelResourceId));
    }
    /// constructor from action
    this(const Action a) {
        this("button-action" ~ to!string(a.id), a.labelValue);
        action = a;
    }

    override void measure(int parentWidth, int parentHeight) { 
        FontRef font = font();
        Point sz = font.textSize(text);
        measuredContent(parentWidth, parentHeight, sz.x, sz.y);
    }

	override void onDraw(DrawBuf buf) {
        super.onDraw(buf);
        Rect rc = _pos;
        applyMargins(rc);
        buf.fillRect(_pos, backgroundColor);
        applyPadding(rc);
		auto saver = ClipRectSaver(buf, rc, alpha);
		FontRef font = font();
        Point sz = font.textSize(text);
        applyAlign(rc, sz);
        font.drawText(buf, rc.left, rc.top, text, textColor, 4, 0, textFlags);
    }

}

/// scroll event handler interface
interface OnScrollHandler {
    /// handle scroll event
    bool onScrollEvent(AbstractSlider source, ScrollEvent event);
}

/// base class for widgets like scrollbars and sliders
class AbstractSlider : WidgetGroup {
    protected int _minValue = 0;
    protected int _maxValue = 100;
    protected int _pageSize = 30;
    protected int _position = 20;

    /// create with ID parameter
    this(string ID) {
        super(ID);
    }

    /// scroll event listeners
    Signal!OnScrollHandler onScrollEventListener;

    /// returns slider position
    @property int position() const { return _position; }
    /// sets new slider position
    @property AbstractSlider position(int newPosition) { 
        if (_position != newPosition) {
            _position = newPosition;
            onPositionChanged();
        }
        return this;
    }
    protected void onPositionChanged() {
        requestLayout();
    }
    /// returns slider range min value
    @property int minValue() const { return _minValue; }
    /// sets slider range min value
    @property AbstractSlider minValue(int v) { _minValue = v; return this; }
    /// returns slider range max value
    @property int maxValue() const { return _maxValue; }
    /// sets slider range max value
    @property AbstractSlider maxValue(int v) { _maxValue = v; return this; }



    /// page size (visible area size)
    @property int pageSize() const { return _pageSize; }
    /// set page size (visible area size)
    @property AbstractSlider pageSize(int size) {
        if (_pageSize != size) {
            _pageSize = size;
            //requestLayout();
        }
        return this;
    }

    /// set int property value, for ML loaders
    mixin(generatePropertySettersMethodOverride("setIntProperty", "int",
          "minValue", "maxValue", "pageSize", "position"));

    /// set new range (min and max values for slider)
    AbstractSlider setRange(int min, int max) {
        if (_minValue != min || _maxValue != max) {
            _minValue = min;
            _maxValue = max;
            //requestLayout();
        }
        return this;
    }

    bool sendScrollEvent(ScrollAction action) {
        return sendScrollEvent(action, _position);
    }

    bool sendScrollEvent(ScrollAction action, int position) {
        if (!onScrollEventListener.assigned)
            return false;
        ScrollEvent event = new ScrollEvent(action, _minValue, _maxValue, _pageSize, position);
        bool res = onScrollEventListener(this, event);
        if (event.positionChanged) {
            _position = event.position;
            if (_position > _maxValue)
                _position = _maxValue;
            if (_position < _minValue)
                _position = _minValue;
            onPositionChanged();
        }
        return true;
    }

    protected Orientation _orientation = Orientation.Vertical;
    /// returns scrollbar orientation (Vertical, Horizontal)
    @property Orientation orientation() { return _orientation; }
    /// sets scrollbar orientation
    @property AbstractSlider orientation(Orientation value) { 
        if (_orientation != value) {
            _orientation = value; 
            requestLayout(); 
        }
        return this; 
    }

}

/// scroll bar - either vertical or horizontal
class ScrollBar : AbstractSlider, OnClickHandler {
    protected ImageButton _btnBack;
    protected ImageButton _btnForward;
    protected SliderButton _indicator;
    protected PageScrollButton _pageUp;
    protected PageScrollButton _pageDown;
    protected Rect _scrollArea;
    protected int _btnSize;
    protected int _minIndicatorSize;



    class PageScrollButton : Widget {
        this(string ID) {
            super(ID);
            styleId = STYLE_PAGE_SCROLL;
            trackHover = true;
            clickable = true;
        }
    }

    class SliderButton : ImageButton {
        Point _dragStart;
        int _dragStartPosition;
        bool _dragging;
        Rect _dragStartRect;

        this(string resourceId) {
            super("SLIDER", resourceId);
			styleId = STYLE_SCROLLBAR_BUTTON;
            trackHover = true;
        }

        /// process mouse event; return true if event is processed by widget.
        override bool onMouseEvent(MouseEvent event) {
            // support onClick
            if (event.action == MouseAction.ButtonDown && event.button == MouseButton.Left) {
                setState(State.Pressed);
                _dragging = true;
                _dragStart.x = event.x;
                _dragStart.y = event.y;
                _dragStartPosition = _position;
                _dragStartRect = _pos;
                sendScrollEvent(ScrollAction.SliderPressed, _position);
                return true;
            }
            if (event.action == MouseAction.FocusOut && _dragging) {
                debug(scrollbar) Log.d("ScrollBar slider dragging - FocusOut");
                return true;
            }
            if (event.action == MouseAction.FocusIn && _dragging) {
                debug(scrollbar) Log.d("ScrollBar slider dragging - FocusIn");
                return true;
            }
            if (event.action == MouseAction.Move && _dragging) {
                int delta = _orientation == Orientation.Vertical ? event.y - _dragStart.y : event.x - _dragStart.x;
                debug(scrollbar) Log.d("ScrollBar slider dragging - Move delta=", delta);
                Rect rc = _dragStartRect;
                int offset;
                int space;
                if (_orientation == Orientation.Vertical) {
                    rc.top += delta;
                    rc.bottom += delta;
                    if (rc.top < _scrollArea.top) {
                        rc.top = _scrollArea.top;
                        rc.bottom = _scrollArea.top + _dragStartRect.height;
                    } else if (rc.bottom > _scrollArea.bottom) {
                        rc.top = _scrollArea.bottom - _dragStartRect.height;
                        rc.bottom = _scrollArea.bottom;
                    }
                    offset = rc.top - _scrollArea.top;
                    space = _scrollArea.height - rc.height;
                } else {
                    rc.left += delta;
                    rc.right += delta;
                    if (rc.left < _scrollArea.left) {
                        rc.left = _scrollArea.left;
                        rc.right = _scrollArea.left + _dragStartRect.width;
                    } else if (rc.right > _scrollArea.right) {
                        rc.left = _scrollArea.right - _dragStartRect.width;
                        rc.right = _scrollArea.right;
                    }
                    offset = rc.left - _scrollArea.left;
                    space = _scrollArea.width - rc.width;
                }
                layoutButtons(rc);
                //_pos = rc;
                int position = space > 0 ? _minValue + offset * (_maxValue - _minValue - _pageSize) / space : 0;
                invalidate();
                onIndicatorDragging(_dragStartPosition, position);
                return true;
            }
            if (event.action == MouseAction.ButtonUp && event.button == MouseButton.Left) {
                resetState(State.Pressed);
                if (_dragging) {
                    sendScrollEvent(ScrollAction.SliderReleased, _position);
                    _dragging = false;
                }
                return true;
            }
            if (event.action == MouseAction.Move && trackHover) {
                if (!(state & State.Hovered)) {
                    debug(scrollbar) Log.d("Hover ", id);
                    setState(State.Hovered);
                }
	            return true;
            }
            if (event.action == MouseAction.Leave && trackHover) {
                debug(scrollbar) Log.d("Leave ", id);
	            resetState(State.Hovered);
	            return true;
            }
            if (event.action == MouseAction.Cancel && trackHover) {
                debug(scrollbar) Log.d("Cancel ? trackHover", id);
	            resetState(State.Hovered);
                resetState(State.Pressed);
                _dragging = false;
	            return true;
            }
            if (event.action == MouseAction.Cancel) {
                debug(scrollbar) Log.d("SliderButton.onMouseEvent event.action == MouseAction.Cancel");
                resetState(State.Pressed);
                _dragging = false;
                return true;
            }
            return false;
        }

    }

    protected bool onIndicatorDragging(int initialPosition, int currentPosition) {
        _position = currentPosition;
        return sendScrollEvent(ScrollAction.SliderMoved, currentPosition);
    }

    private bool calcButtonSizes(int availableSize, ref int spaceBackSize, ref int spaceForwardSize, ref int indicatorSize) {
        int dv = _maxValue - _minValue;
        if (_pageSize >= dv) {
            // full size
            spaceBackSize = spaceForwardSize = 0;
            indicatorSize = availableSize;
            return false;
        }
        if (dv < 0)
            dv = 0;
        indicatorSize = _pageSize * availableSize / dv;
        if (indicatorSize < _minIndicatorSize)
            indicatorSize = _minIndicatorSize;
        if (indicatorSize >= availableSize) {
            // full size
            spaceBackSize = spaceForwardSize = 0;
            indicatorSize = availableSize;
            return false;
        }
        int spaceLeft = availableSize - indicatorSize;
        int topv = _position - _minValue;
        int bottomv = _position + _pageSize - _minValue;
        if (topv < 0)
            topv = 0;
        if (bottomv > dv)
            bottomv = dv;
        bottomv = dv - bottomv;
        spaceBackSize = spaceLeft * topv / (topv + bottomv);
        spaceForwardSize = spaceLeft - spaceBackSize;
        return true;
    }

    /// returns scrollbar orientation (Vertical, Horizontal)
    override @property Orientation orientation() { return _orientation; }
    /// sets scrollbar orientation
    override @property AbstractSlider orientation(Orientation value) { 
        if (_orientation != value) {
            _orientation = value; 
            _btnBack.drawableId = style.customDrawableId(_orientation == Orientation.Vertical ? ATTR_SCROLLBAR_BUTTON_UP : ATTR_SCROLLBAR_BUTTON_LEFT);
            _btnForward.drawableId = style.customDrawableId(_orientation == Orientation.Vertical ? ATTR_SCROLLBAR_BUTTON_DOWN : ATTR_SCROLLBAR_BUTTON_RIGHT);
            _indicator.drawableId = style.customDrawableId(_orientation == Orientation.Vertical ? ATTR_SCROLLBAR_INDICATOR_VERTICAL : ATTR_SCROLLBAR_INDICATOR_HORIZONTAL);
            requestLayout(); 
        }
        return this; 
    }

    /// set string property value, for ML loaders
    override bool setStringProperty(string name, string value) {
        if (name.equal("orientation")) {
            if (value.equal("Vertical") || value.equal("vertical"))
                orientation = Orientation.Vertical;
            else
                orientation = Orientation.Horizontal;
            return true;
        }
        return super.setStringProperty(name, value);
    }


    /// empty parameter list constructor - for usage by factory
    this() {
        this(null, Orientation.Vertical);
    }
    /// create with ID parameter
    this(string ID, Orientation orient = Orientation.Vertical) {
		super(ID);
        styleId = STYLE_SCROLLBAR;
        _orientation = orient;
        _btnBack = new ImageButton("BACK", style.customDrawableId(_orientation == Orientation.Vertical ? ATTR_SCROLLBAR_BUTTON_UP : ATTR_SCROLLBAR_BUTTON_LEFT));
        _btnForward = new ImageButton("FORWARD", style.customDrawableId(_orientation == Orientation.Vertical ? ATTR_SCROLLBAR_BUTTON_DOWN : ATTR_SCROLLBAR_BUTTON_RIGHT));
        _pageUp = new PageScrollButton("PAGE_UP");
        _pageDown = new PageScrollButton("PAGE_DOWN");
        _btnBack.styleId = STYLE_SCROLLBAR_BUTTON_TRANSPARENT;
        _btnForward.styleId = STYLE_SCROLLBAR_BUTTON_TRANSPARENT;
        _indicator = new SliderButton(style.customDrawableId(_orientation == Orientation.Vertical ? ATTR_SCROLLBAR_INDICATOR_VERTICAL : ATTR_SCROLLBAR_INDICATOR_HORIZONTAL));
        addChild(_btnBack);
        addChild(_btnForward);
        addChild(_indicator);
        addChild(_pageUp);
        addChild(_pageDown);
		_btnBack.focusable = false;
		_btnForward.focusable = false;
		_indicator.focusable = false;
		_pageUp.focusable = false;
		_pageDown.focusable = false;
        _btnBack.click = &onClick;
        _btnForward.click = &onClick;
        _pageUp.click = &onClick;
        _pageDown.click = &onClick;
    }

    override void measure(int parentWidth, int parentHeight) { 
        Point sz;
        _btnBack.measure(parentWidth, parentHeight);
        _btnForward.measure(parentWidth, parentHeight);
        _indicator.measure(parentWidth, parentHeight);
        _pageUp.measure(parentWidth, parentHeight);
        _pageDown.measure(parentWidth, parentHeight);
        _btnSize = _btnBack.measuredWidth;
        _minIndicatorSize = _orientation == Orientation.Vertical ? _indicator.measuredHeight : _indicator.measuredWidth;
		if (_btnSize < _minIndicatorSize)
			_btnSize = _minIndicatorSize;
		if (_btnSize < _btnForward.measuredWidth)
			_btnSize = _btnForward.measuredWidth;
		if (_btnSize < _btnForward.measuredHeight)
			_btnSize = _btnForward.measuredHeight;
		if (_btnSize < _btnBack.measuredHeight)
			_btnSize = _btnBack.measuredHeight;
		if (_btnSize < 16)
            _btnSize = 16;
        if (_orientation == Orientation.Vertical) {
            // vertical
            sz.x = _btnSize;
            sz.y = _btnSize * 5; // min height
        } else {
            // horizontal
            sz.y = _btnSize;
            sz.x = _btnSize * 5; // min height
        }
        measuredContent(parentWidth, parentHeight, sz.x, sz.y);
    }

	override protected void onPositionChanged() {
		if (!needLayout)
        	layoutButtons();
    }

    /// hide controls when scroll is not possible
    protected void updateState() {
        bool canScroll = _maxValue - _minValue > _pageSize;
        if (canScroll) {
            _btnBack.setState(State.Enabled);
            _btnForward.setState(State.Enabled);
            _indicator.visibility = Visibility.Visible;
            _pageUp.visibility = Visibility.Visible;
            _pageDown.visibility = Visibility.Visible;
        } else {
            _btnBack.resetState(State.Enabled);
            _btnForward.resetState(State.Enabled);
            _indicator.visibility = Visibility.Gone;
            _pageUp.visibility = Visibility.Gone;
            _pageDown.visibility = Visibility.Gone;
        }
		cancelLayout();
    }

	override void cancelLayout() {
		_btnBack.cancelLayout();
		_btnForward.cancelLayout();
		_indicator.cancelLayout();
		_pageUp.cancelLayout();
		_pageDown.cancelLayout();
		super.cancelLayout();
	}

    protected void layoutButtons() {
        Rect irc = _scrollArea;
        if (_orientation == Orientation.Vertical) {
            // vertical
            int spaceBackSize, spaceForwardSize, indicatorSize;
            bool indicatorVisible = calcButtonSizes(_scrollArea.height, spaceBackSize, spaceForwardSize, indicatorSize);
            irc.top += spaceBackSize;
            irc.bottom -= spaceForwardSize;
            layoutButtons(irc);
        } else {
            // horizontal
            int spaceBackSize, spaceForwardSize, indicatorSize;
            bool indicatorVisible = calcButtonSizes(_scrollArea.width, spaceBackSize, spaceForwardSize, indicatorSize);
            irc.left += spaceBackSize;
            irc.right -= spaceForwardSize;
            layoutButtons(irc);
        }
        updateState();
		cancelLayout();
	}

	protected void layoutButtons(Rect irc) {
        Rect r;
        _indicator.visibility = Visibility.Visible;
        if (_orientation == Orientation.Vertical) {
            _indicator.layout(irc);
            if (_scrollArea.top < irc.top) {
                r = _scrollArea;
                r.bottom = irc.top;
                _pageUp.layout(r);
                _pageUp.visibility = Visibility.Visible;
            } else {
                _pageUp.visibility = Visibility.Invisible;
            }
            if (_scrollArea.bottom > irc.bottom) {
                r = _scrollArea;
                r.top = irc.bottom;
                _pageDown.layout(r);
                _pageDown.visibility = Visibility.Visible;
            } else {
                _pageDown.visibility = Visibility.Invisible;
            }
        } else {
            _indicator.layout(irc);
            if (_scrollArea.left < irc.left) {
                r = _scrollArea;
                r.right = irc.left;
                _pageUp.layout(r);
                _pageUp.visibility = Visibility.Visible;
            } else {
                _pageUp.visibility = Visibility.Invisible;
            }
            if (_scrollArea.right > irc.right) {
                r = _scrollArea;
                r.left = irc.right;
                _pageDown.layout(r);
                _pageDown.visibility = Visibility.Visible;
            } else {
                _pageDown.visibility = Visibility.Invisible;
            }
        }
    }

    override void layout(Rect rc) {
        _needLayout = false;
        applyMargins(rc);
        applyPadding(rc);
        Rect r;
        if (_orientation == Orientation.Vertical) {
            // vertical
            // buttons
            int backbtnpos = rc.top + _btnSize;
            int fwdbtnpos = rc.bottom - _btnSize;
            r = rc;
            r.bottom = backbtnpos;
            _btnBack.layout(r);
            r = rc;
            r.top = fwdbtnpos;
            _btnForward.layout(r);
            // indicator
            r = rc;
            r.top = backbtnpos;
            r.bottom = fwdbtnpos;
            _scrollArea = r;
        } else {
            // horizontal
            int backbtnpos = rc.left + _btnSize;
            int fwdbtnpos = rc.right - _btnSize;
            r = rc;
            r.right = backbtnpos;
            _btnBack.layout(r);
            r = rc;
            r.left = fwdbtnpos;
            _btnForward.layout(r);
            // indicator
            r = rc;
            r.left = backbtnpos;
            r.right = fwdbtnpos;
            _scrollArea = r;
        }
		layoutButtons();
        _pos = rc;
    }

    override bool onClick(Widget source) {
        Log.d("Scrollbar.onClick ", source.id);
        if (source.compareId("BACK"))
            return sendScrollEvent(ScrollAction.LineUp, position);
        if (source.compareId("FORWARD"))
            return sendScrollEvent(ScrollAction.LineDown, position);
        if (source.compareId("PAGE_UP"))
            return sendScrollEvent(ScrollAction.PageUp, position);
        if (source.compareId("PAGE_DOWN"))
            return sendScrollEvent(ScrollAction.PageDown, position);
        return true;
    }

    /// handle mouse wheel events
    override bool onMouseEvent(MouseEvent event) {
        if (visibility != Visibility.Visible)
            return false;
        if (event.action == MouseAction.Wheel) {
            int delta = event.wheelDelta;
            if (delta > 0)
                sendScrollEvent(ScrollAction.LineUp, position);
            else if (delta < 0)
                sendScrollEvent(ScrollAction.LineDown, position);
            return true;
        }
        return super.onMouseEvent(event);
    }

    /// Draw widget at its position to buffer
    override void onDraw(DrawBuf buf) {
        if (visibility != Visibility.Visible && !buf.isClippedOut(_pos))
            return;
        super.onDraw(buf);
        Rect rc = _pos;
        applyMargins(rc);
        applyPadding(rc);
		auto saver = ClipRectSaver(buf, rc, alpha);
		_btnForward.onDraw(buf);
        _btnBack.onDraw(buf);
        _pageUp.onDraw(buf);
        _pageDown.onDraw(buf);
        _indicator.onDraw(buf);
    }
}

/// interface - slot for onClick
interface OnDrawHandler {
    void doDraw(CanvasWidget canvas, DrawBuf buf, Rect rc);
}

/// canvas widget - draw on it either by overriding of doDraw() or by assigning of onDrawListener
class CanvasWidget : Widget {
	
	Listener!OnDrawHandler onDrawListener;

    this(string ID = null) {
		super(ID);
    }

    override void measure(int parentWidth, int parentHeight) { 
        measuredContent(parentWidth, parentHeight, 0, 0);
    }

	void doDraw(DrawBuf buf, Rect rc) {
		if (onDrawListener.assigned)
			onDrawListener(this, buf, rc);
	}

    override void onDraw(DrawBuf buf) {
        if (visibility != Visibility.Visible)
            return;
        super.onDraw(buf);
        Rect rc = _pos;
        applyMargins(rc);
		auto saver = ClipRectSaver(buf, rc, alpha);
		applyPadding(rc);
		doDraw(buf, rc);
    }
}

import dlangui.widgets.metadata;
mixin(registerWidgets!(Widget, TextWidget, MultilineTextWidget, Button, ImageWidget, ImageButton, ImageTextButton, RadioButton, CheckBox, ScrollBar, HSpacer, VSpacer, CanvasWidget)());
