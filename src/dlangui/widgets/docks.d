module dlangui.widgets.docks;

import dlangui.widgets.layouts;
import dlangui.widgets.controls;

class DockHost : WidgetGroupDefaultDrawing {
    protected Widget _bodyWidget;
    @property Widget bodyWidget() { return _bodyWidget; }
    @property void bodyWidget(Widget widget) { 
        _children.replace(_bodyWidget, widget);
        _bodyWidget = widget;
        _bodyWidget.layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT);
    }

    this() {
        super("DOCK_HOST");
    }
}

enum DockAlignment {
    Left,
    Right,
    Top,
    Bottom
}

class DockWindow : VerticalLayout {

    protected Widget _bodyWidget;
    @property Widget bodyWidget() { return _bodyWidget; }
    @property void bodyWidget(Widget widget) { 
        _children.replace(_bodyWidget, widget);
        _bodyWidget = widget;
        _bodyWidget.layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT);
    }

    protected DockAlignment _dockAlignment;
    protected HorizontalLayout _captionLayout;
    protected TextWidget _caption;
    protected ImageButton _closeButton;
    this(string ID) {
        super(ID);
        init();
    }
    protected bool onCloseButtonClick(Widget source) {
        return true;
    }
    protected void init() {

        styleId = STYLE_DOCK_WINDOW;

        _captionLayout = new HorizontalLayout("DOCK_WINDOW_CAPTION_PANEL");
        _captionLayout.layoutWidth(FILL_PARENT).layoutHeight(WRAP_CONTENT);
        _captionLayout.styleId = STYLE_DOCK_WINDOW_CAPTION;

        uint bcolor = _captionLayout.backgroundColor;
        Log.d("caption layout back color=", bcolor);

        //_captionLayout.backgroundColor = 0x204060;

        _caption = new TextWidget("DOCK_WINDOW_CAPTION");
        _caption.styleId = STYLE_DOCK_WINDOW_CAPTION_LABEL;

        _closeButton = new ImageButton("DOCK_WINDOW_CAPTION_CLOSE_BUTTON");
        _closeButton.styleId = STYLE_BUTTON_TRANSPARENT;
        _closeButton.drawableId = "close";
		_closeButton.trackHover = true;
        _closeButton.onClickListener = &onCloseButtonClick;

        _captionLayout.addChild(_caption);
        _captionLayout.addChild(_closeButton);

        _bodyWidget = createBodyWidget();
        _bodyWidget.styleId = STYLE_DOCK_WINDOW_BODY;
        //_bodyWidget.backgroundColor = 0xFFFFFF;
        //_bodyWidget.layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT);

        addChild(_captionLayout);
        addChild(_bodyWidget);
    }
    protected Widget createBodyWidget() {
        return new Widget("DOCK_WINDOW_BODY");
    }
}
