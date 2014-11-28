module dlangui.widgets.scroll;

import dlangui.widgets.widget;
import dlangui.widgets.controls;
import std.conv;

class ScrollWidget :  WidgetGroup, OnScrollHandler {
    /// vertical scrollbar control
	protected ScrollBar _vscrollbar;
    /// horizontal scrollbar control
	protected ScrollBar _hscrollbar;

	this(string ID = null) {
		super(ID);
        _vscrollbar = new ScrollBar("vscrollbar", Orientation.Vertical);
        _hscrollbar = new ScrollBar("hscrollbar", Orientation.Horizontal);
        _hscrollbar.onScrollEventListener = this;
        _vscrollbar.onScrollEventListener = this;
        addChild(_vscrollbar);
        addChild(_hscrollbar);
    }

    /// process horizontal scrollbar event
    bool onHScroll(ScrollEvent event) {
        return true;
    }

    /// process vertical scrollbar event
    bool onVScroll(ScrollEvent event) {
        return true;
    }

    /// handle scroll event
    override bool onScrollEvent(AbstractSlider source, ScrollEvent event) {
        if (source.compareId("hscrollbar")) {
            return onHScroll(event);
        } else if (source.compareId("vscrollbar")) {
            return onVScroll(event);
        }
        return true;
    }

    /// update horizontal scrollbar widget position
    protected void updateHScrollBar() {
        // override it
    }

    /// update verticat scrollbar widget position
    protected void updateVScrollBar() {
        // override it
    }

    /// update scrollbar positions
    protected void updateScrollBars() {
        if (_hscrollbar) {
            updateHScrollBar();
        }
        if (_vscrollbar) {
            updateVScrollBar();
        }
    }


}