module dlangui.widgets.tree;

import dlangui.widgets.widget;
import dlangui.widgets.controls;
import dlangui.widgets.scroll;
import std.conv;

class TreeWidgetBase :  ScrollWidget {
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
    override bool onHScroll(ScrollEvent event) {
        return true;
    }

    /// process vertical scrollbar event
    override bool onVScroll(ScrollEvent event) {
        return true;
    }

    /// update horizontal scrollbar widget position
    override protected void updateHScrollBar() {
        // override it
    }

    /// update verticat scrollbar widget position
    override protected void updateVScrollBar() {
        // override it
    }


}

class TreeWidget :  ScrollWidget {
	this(string ID = null) {
		super(ID);
    }
}
