// Written in the D programming language.

/**

This module implements window frame widget.


Synopsis:

----
import dlangui.widgets.docks;
----


Copyright: Vadim Lopatin, 2015
License:   Boost License 1.0
Authors:   Vadim Lopatin, coolreader.org@gmail.com
*/
module dlangui.widgets.winframe;

import dlangui.widgets.layouts;
import dlangui.widgets.controls;

/// window frame with caption widget
class WindowFrame : VerticalLayout {

    protected Widget _bodyWidget;
    @property Widget bodyWidget() { return _bodyWidget; }
    @property void bodyWidget(Widget widget) { 
        _children.replace(widget, _bodyWidget);
        _bodyWidget = widget;
        _bodyWidget.layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT);
        _bodyWidget.parent = this;
        requestLayout();
    }

    protected HorizontalLayout _captionLayout;
    protected TextWidget _caption;
    protected ImageButton _closeButton;
    protected bool _showCloseButton;

    @property TextWidget caption() { return _caption; }

    this(string ID, bool showCloseButton = true) {
        super(ID);
        _showCloseButton = showCloseButton;
        init();
    }

    Signal!OnClickHandler closeButtonClick;
    protected bool onCloseButtonClick(Widget source) {
        if (closeButtonClick.assigned)
            closeButtonClick(source);
        return true;
    }

    protected void init() {

        styleId = STYLE_DOCK_WINDOW;

        _captionLayout = new HorizontalLayout("DOCK_WINDOW_CAPTION_PANEL");
        _captionLayout.layoutWidth(FILL_PARENT).layoutHeight(WRAP_CONTENT);
        _captionLayout.styleId = STYLE_DOCK_WINDOW_CAPTION;

        _caption = new TextWidget("DOCK_WINDOW_CAPTION");
        _caption.styleId = STYLE_DOCK_WINDOW_CAPTION_LABEL;

        _closeButton = new ImageButton("DOCK_WINDOW_CAPTION_CLOSE_BUTTON");
        _closeButton.styleId = STYLE_BUTTON_TRANSPARENT;
        _closeButton.drawableId = "close";
		_closeButton.trackHover = true;
        _closeButton.click = &onCloseButtonClick;
        if (!_showCloseButton)
            _closeButton.visibility = Visibility.Gone;

        _captionLayout.addChild(_caption);
        _captionLayout.addChild(_closeButton);

        _bodyWidget = createBodyWidget();
        _bodyWidget.styleId = STYLE_DOCK_WINDOW_BODY;

        addChild(_captionLayout);
        addChild(_bodyWidget);
    }

    protected Widget createBodyWidget() {
        return new Widget("DOCK_WINDOW_BODY");
    }
}
