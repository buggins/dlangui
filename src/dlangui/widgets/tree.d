module dlangui.widgets.tree;

import dlangui.widgets.widget;
import dlangui.widgets.controls;
import dlangui.widgets.scroll;
import std.conv;

class TreeWidgetBase :  ScrollWidgetBase {

	this(string ID = null, ScrollBarMode hscrollbarMode = ScrollBarMode.Visible, ScrollBarMode vscrollbarMode = ScrollBarMode.Visible) {
		super(ID, hscrollbarMode, vscrollbarMode);
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

class TreeWidget :  TreeWidgetBase {
	this(string ID = null) {
		super(ID);
    }
}
