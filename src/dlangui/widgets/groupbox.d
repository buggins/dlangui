// Written in the D programming language.

/**
This module contains Group Box widget implementation.

Group box is linear layout with frame and caption for grouping controls.


Synopsis:

----
import dlangui.widgets.groupbox;

----

Copyright: Vadim Lopatin, 2016
License:   Boost License 1.0
Authors:   Vadim Lopatin, coolreader.org@gmail.com
*/
module dlangui.widgets.groupbox;

import dlangui.widgets.widget;
import dlangui.widgets.layouts;

class GroupBox : LinearLayout {
    import dlangui.widgets.controls;

    protected TextWidget _caption;

    this() {
        this(null, ""d, Orientation.Vertical);
    }

    this(string ID, UIString uitext, Orientation orientation = Orientation.Vertical) {
        super(ID, orientation);
        styleId = STYLE_GROUP_BOX;
        _caption = new TextWidget("GROUP_BOX_CAPTION");
        _caption.styleId = STYLE_GROUP_BOX_CAPTION;
        _caption.parent = this;
        text = uitext;
    }

    this(string ID, string textResourceId, Orientation orientation = Orientation.Vertical) {
        this(ID, UIString.fromId(textResourceId), orientation);
    }

    this(string ID, dstring rawText, Orientation orientation = Orientation.Vertical) {
        this(ID, UIString.fromRaw(rawText), orientation);
    }

    ~this() {
        destroy(_caption);
    }

    /// get widget text
    override @property dstring text() const { return _caption.text; }
    /// set text to show
    override @property Widget text(dstring s) {
        _caption.text = s;
        requestLayout();
        return this;
    }
    /// set text to show
    override @property Widget text(UIString s) {
        _caption.text = s;
        requestLayout();
        return this;
    }
    /// set text resource ID to show
    @property Widget textResource(string s) {
        _caption.textResource = s;
        requestLayout();
        return this;
    }

    int _topFrameHeight;
    int _topFrameLeft;
    int _topFrameRight;
    int _captionHeight;
    int _topHeight;
    int _frameLeft;
    int _frameRight;
    int _frameBottom;
    int _frameWidth;
    int _frameHeight;
    protected void calcFrame() {
        Rect captPadding = _caption.padding;
        Rect captMargins = _caption.margins;
        int captFontHeight = _caption.font.height;
        _captionHeight = captPadding.top + captPadding.bottom + captMargins.top + captMargins.bottom + captFontHeight;
        _topFrameHeight = 0;
        DrawableRef upLeftDrawable = style.customDrawable("group_box_frame_up_left");
        DrawableRef upRightDrawable = style.customDrawable("group_box_frame_up_right");
        if (!upLeftDrawable.isNull)
            _topFrameHeight = upLeftDrawable.height;
        if (!upRightDrawable.isNull && _topFrameHeight < upRightDrawable.height)
            _topFrameHeight = upRightDrawable.height;
        _topFrameLeft = 0;
        if (!upLeftDrawable.isNull)
            _topFrameLeft = upLeftDrawable.width;
        _topFrameRight = 0;
        if (!upRightDrawable.isNull)
            _topFrameRight = upRightDrawable.width;
        _frameLeft = _frameRight = _frameBottom = _frameWidth = 0;
        DrawableRef bottomDrawable = style.customDrawable("group_box_frame_bottom");
        if (!bottomDrawable.isNull) {
            Rect dp = bottomDrawable.padding;
            _frameLeft = dp.left;
            _frameRight = dp.right;
            _frameBottom = dp.bottom;
            _frameWidth = bottomDrawable.width;
            _frameHeight = bottomDrawable.height;
        }
        _topHeight = _captionHeight;
        if (_topHeight < _topFrameHeight)
            _topHeight = _topFrameHeight;
    }

    /// handle theme change: e.g. reload some themed resources
    override void onThemeChanged() {
        super.onThemeChanged();
        _caption.onThemeChanged();
    }

    /// get padding (between background bounds and content of widget)
    override @property Rect padding() const {
        // get default padding
        Rect p = super.padding();
        // correct padding based on frame drawables and caption
        (cast(GroupBox)this).calcFrame(); // hack
        if (p.top < _topHeight)
            p.top = _topHeight;
        if (p.left < _frameLeft)
            p.left = _frameLeft;
        if (p.right < _frameRight)
            p.right = _frameRight;
        if (p.bottom < _frameBottom)
            p.bottom = _frameBottom;
        return p;
    }

    /// helper function for implement measure() when widget's content dimensions are known
    override protected void measuredContent(int parentWidth, int parentHeight, int contentWidth, int contentHeight) {
        _caption.measure(parentWidth, parentHeight);
        calcFrame();
        int topPadding = _topFrameLeft + _topFrameRight;
        int bottomPadding = _frameLeft + _frameRight;
        int extraTop = topPadding - bottomPadding;
        int w = _caption.measuredWidth + extraTop;
        if (contentWidth < w)
            contentWidth = w;
        super.measuredContent(parentWidth, parentHeight, contentWidth, contentHeight);
    }

    /// Set widget rectangle to specified value and layout widget contents. (Step 2 of two phase layout).
    override void layout(Rect rc) {
        super.layout(rc);
        Rect r = rc;
        r.top += margins.top;
        r.bottom = r.top + _topHeight;
        r.left += _topFrameLeft + margins.left;
        r.right -= _topFrameRight;
        _caption.measure(r.width, r.height);
        if (r.width > _caption.measuredWidth)
            r.right = r.left + _caption.measuredWidth;
        _caption.layout(r);
    }

    /// set padding for widget - override one from style
    override @property Widget padding(Rect rc) {
        return super.padding(rc);
    }

    /// Draw widget at its position to buffer
    override void onDraw(DrawBuf buf) {
        if (visibility != Visibility.Visible)
            return;
        super.onDraw(buf);
        Rect rc = _pos;
        applyMargins(rc);

        _caption.onDraw(buf);

        int dh = 0;
        if (_topFrameHeight < _captionHeight)
            dh = (_captionHeight - _topFrameHeight) / 2;

        DrawableRef upLeftDrawable = style.customDrawable("group_box_frame_up_left");
        if (!upLeftDrawable.isNull) {
            upLeftDrawable.drawTo(buf, Rect(rc.left, rc.top + dh, rc.left + _topFrameLeft, rc.top + _topHeight));
        }
        DrawableRef upRightDrawable = style.customDrawable("group_box_frame_up_right");
        if (!upRightDrawable.isNull) {
            int cw = _caption.width;
            upRightDrawable.drawTo(buf, Rect(rc.left + _topFrameLeft + cw, rc.top + dh, rc.right, rc.top + _topHeight));
        }

        DrawableRef bottomDrawable = style.customDrawable("group_box_frame_bottom");
        if (!bottomDrawable.isNull) {
            bottomDrawable.drawTo(buf, Rect(rc.left, rc.top + _topHeight, rc.right, rc.bottom));
        }
    }
}
