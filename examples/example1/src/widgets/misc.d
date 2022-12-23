module widgets.misc;

import dlangui;

class TimerTest : HorizontalLayout {
    ulong timerId;
    TextWidget _counter;
    int _value;
    Button _start;
    Button _stop;
    override bool onTimer(ulong id) {
        _value++;
        _counter.text = to!dstring(_value);
        return true;
    }
    this() {
        addChild(new TextWidget(null, "Timer test."d));
        _counter = new TextWidget(null, "0"d);
        _counter.fontSize(32);
        _start = new Button(null, "Start timer"d);
        _stop = new Button(null, "Stop timer"d);
        _stop.enabled = false;
        _start.click = delegate(Widget src) {
            _start.enabled = false;
            _stop.enabled = true;
            timerId = setTimer(1000);
            return true;
        };
        _stop.click = delegate(Widget src) {
            _start.enabled = true;
            _stop.enabled = false;
            cancelTimer(timerId);
            return true;
        };
        addChild(_start);
        addChild(_stop);
        addChild(_counter);
    }
}

class MiscExample : LinearLayout
{
    this(string ID)
    {
        super(ID);
        addChild((new TextWidget()).textColor(0x00802000).text("Text widget 0"));
        addChild((new TextWidget()).textColor(0x40FF4000).text("Text widget"));
        addChild(new ProgressBarWidget().progress(300).animationInterval(50));
        addChild(new ProgressBarWidget().progress(-1).animationInterval(50));
        addChild((new Button("BTN1")).textResource("EXIT")); //.textColor(0x40FF4000)
        addChild(new TimerTest());

        MenuItem editPopupItem = new MenuItem(null);
        editPopupItem.add(new Action(EditorActions.Copy, "MENU_EDIT_COPY"c, "edit-copy", KeyCode.KEY_C, KeyFlag.Control));
        editPopupItem.add(new Action(EditorActions.Paste, "MENU_EDIT_PASTE"c, "edit-paste", KeyCode.KEY_V, KeyFlag.Control));
        editPopupItem.add(new Action(EditorActions.Cut, "MENU_EDIT_CUT"c, "edit-cut", KeyCode.KEY_X, KeyFlag.Control));
        editPopupItem.add(new Action(EditorActions.Undo, "MENU_EDIT_UNDO"c, "edit-undo", KeyCode.KEY_Z, KeyFlag.Control));
        editPopupItem.add(new Action(EditorActions.Redo, "MENU_EDIT_REDO"c, "edit-redo", KeyCode.KEY_Y, KeyFlag.Control));
        editPopupItem.add(new Action(EditorActions.Indent, "MENU_EDIT_INDENT"c, "edit-indent", KeyCode.TAB, 0));
        editPopupItem.add(new Action(EditorActions.Unindent, "MENU_EDIT_UNINDENT"c, "edit-unindent", KeyCode.TAB, KeyFlag.Control));

        LinearLayout hlayout = new HorizontalLayout();
        hlayout.layoutWidth(FILL_PARENT);
        //hlayout.addChild((new Button()).text("<<")); //.textColor(0x40FF4000)
        hlayout.addChild((new TextWidget()).text("Several").alignment(Align.Center));
        hlayout.addChild((new ImageWidget()).drawableId("btn_radio").padding(Rect(5,5,5,5)).alignment(Align.Center));
        hlayout.addChild((new TextWidget()).text("items").alignment(Align.Center));
        hlayout.addChild((new ImageWidget()).drawableId("btn_check").padding(Rect(5,5,5,5)).alignment(Align.Center));
        hlayout.addChild((new TextWidget()).text("in horizontal layout"));
        hlayout.addChild((new ImageWidget()).drawableId("exit").padding(Rect(5,5,5,5)).alignment(Align.Center));
        hlayout.addChild((new EditLine("editline", "Some text to edit"d)).popupMenu(editPopupItem).alignment(Align.Center).layoutWidth(FILL_PARENT));
        hlayout.addChild((new EditLine("passwd", "Password"d)).passwordChar('*').popupMenu(editPopupItem).alignment(Align.Center).layoutWidth(FILL_PARENT));
        //hlayout.addChild((new Button()).text(">>")); //.textColor(0x40FF4000)
        hlayout.backgroundColor = 0x8080C0;
        addChild(hlayout);

        LinearLayout vlayoutgroup = new HorizontalLayout();
        LinearLayout vlayout = new VerticalLayout();
        vlayout.addChild((new TextWidget()).text("VLayout line 1").textColor(0x40FF4000)); //
        vlayout.addChild((new TextWidget()).text("VLayout line 2").textColor(0x40FF8000));
        vlayout.addChild((new TextWidget()).text("VLayout line 2").textColor(0x40008000));
        vlayout.addChild(new RadioButton("rb1", "Radio button 1"d));
        vlayout.addChild(new RadioButton("rb2", "Radio button 2"d));
        vlayout.addChild(new RadioButton("rb3", "Radio button 3"d));
        vlayout.layoutWidth(FILL_PARENT);
        vlayoutgroup.addChild(vlayout);
        vlayoutgroup.layoutWidth(FILL_PARENT);
        ScrollBar vsb = new ScrollBar("vscroll", Orientation.Vertical);
        vlayoutgroup.addChild(vsb);
        addChild(vlayoutgroup);

        ScrollBar sb = new ScrollBar("hscroll", Orientation.Horizontal);
        addChild(sb.layoutHeight(WRAP_CONTENT).layoutWidth(FILL_PARENT));

        addChild((new CheckBox("BTN2", "Some checkbox"d)));
        addChild((new TextWidget()).textColor(0x40FF4000).text("Text widget"));
        addChild((new ImageWidget()).drawableId("exit").padding(Rect(5,5,5,5)));
        addChild((new TextWidget()).textColor(0xFF4000).text("Text widget2").padding(Rect(5,5,5,5)).margins(Rect(5,5,5,5)).backgroundColor(0xA0A0A0));
        addChild((new RadioButton("BTN3", "Some radio button"d)));
        addChild((new TextWidget(null, "Text widget3 with very long text"d)).textColor(0x004000));
        addChild(new VSpacer()); // vertical spacer to fill extra space

        childById("BTN1").click = delegate (Widget w) {
            Log.d("onClick ", w.id);
            //w.backgroundImageId = null;
            //w.backgroundColor = 0xFF00FF;
            w.textColor = 0xFF00FF;
            w.styleId = STYLE_BUTTON_NOMARGINS;
            return true;
        };
        childById("BTN2").click = delegate (Widget w) { Log.d("onClick ", w.id); return true; };
        childById("BTN3").click = delegate (Widget w) { Log.d("onClick ", w.id); return true; };

        layoutHeight(FILL_PARENT).layoutWidth(FILL_PARENT);

    }
}