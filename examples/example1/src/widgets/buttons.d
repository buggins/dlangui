module widgets.buttons;

import dlangui;

enum : int {
    ACTION_FILE_OPEN = 5500,
    ACTION_FILE_SAVE,
    ACTION_FILE_CLOSE,
    ACTION_FILE_EXIT,
}

class ButtonsExample : VerticalLayout
{
    this(string ID)
    {
        super(ID);
        // 3 types of buttons: Button, ImageButton, ImageTextButton
        addChild(new TextWidget(null, "Buttons in HorizontalLayout"d));
        WidgetGroup buttons1 = new HorizontalLayout();
        buttons1.addChild(new TextWidget(null, "Button widgets: "d));
        buttons1.addChild((new Button("btn1", "Button"d)).tooltipText("Tooltip text for button"d));
        buttons1.addChild((new Button("btn2", "Disabled Button"d)).enabled(false));
        buttons1.addChild(new TextWidget(null, "ImageButton widgets: "d));
        buttons1.addChild(new ImageButton("btn3", "text-plain"));
        buttons1.addChild(new TextWidget(null, "disabled: "d));
        buttons1.addChild((new ImageButton("btn4", "folder")).enabled(false));
        addChild(buttons1);

        WidgetGroup buttons10 = new HorizontalLayout();
        buttons10.addChild(new TextWidget(null, "ImageTextButton widgets: "d));
        buttons10.addChild(new ImageTextButton("btn5", "text-plain", "Enabled"d));
        buttons10.addChild((new ImageTextButton("btn6", "folder", "Disabled"d)).enabled(false));
        buttons10.addChild(new TextWidget(null, "SwitchButton widgets: "d));
        buttons10.addChild((new SwitchButton("SW1")).checked(true));
        buttons10.addChild((new SwitchButton("SW2")).checked(false));
        buttons10.addChild((new SwitchButton("SW3")).checked(true).enabled(false));
        buttons10.addChild((new SwitchButton("SW4")).checked(false).enabled(false));
        addChild(buttons10);

        WidgetGroup buttons11 = new HorizontalLayout();
        buttons11.addChild(new TextWidget(null, "Construct buttons by action (Button, ImageButton, ImageTextButton): "d));
        Action FILE_OPEN_ACTION = new Action(ACTION_FILE_OPEN, "MENU_FILE_OPEN"c, "document-open", KeyCode.KEY_O, KeyFlag.Control);
        buttons11.addChild(new Button(FILE_OPEN_ACTION));
        buttons11.addChild(new ImageButton(FILE_OPEN_ACTION));
        buttons11.addChild(new ImageTextButton(FILE_OPEN_ACTION));
        addChild(buttons11);

        WidgetGroup buttons12 = new HorizontalLayout();
        buttons12.addChild(new TextWidget(null, "The same in disabled state: "d));
        buttons12.addChild((new Button(FILE_OPEN_ACTION)).enabled(false));
        buttons12.addChild((new ImageButton(FILE_OPEN_ACTION)).enabled(false));
        buttons12.addChild((new ImageTextButton(FILE_OPEN_ACTION)).enabled(false));
        addChild(buttons12);

        addChild(new VSpacer());
        addChild(new TextWidget(null, "CheckBoxes in HorizontalLayout"d));
        WidgetGroup buttons2 = new HorizontalLayout();
        buttons2.addChild(new CheckBox("btn1", "CheckBox 1"d));
        buttons2.addChild(new CheckBox("btn2", "CheckBox 2"d));
        //buttons2.addChild(new ResizerWidget());
        buttons2.addChild(new CheckBox("btn3", "CheckBox 3"d));
        buttons2.addChild(new CheckBox("btn4", "CheckBox 4"d));
        addChild(buttons2);

        addChild(new VSpacer());
        addChild(new TextWidget(null, "RadioButtons in HorizontalLayout"d));
        WidgetGroup buttons3 = new HorizontalLayout();
        buttons3.addChild(new RadioButton("btn1", "RadioButton 1"d));
        buttons3.addChild(new RadioButton("btn2", "RadioButton 2"d));
        buttons3.addChild(new RadioButton("btn3", "RadioButton 3"d));
        buttons3.addChild(new RadioButton("btn4", "RadioButton 4"d));
        addChild(buttons3);

        addChild(new VSpacer());
        addChild(new TextWidget(null, "ImageButtons HorizontalLayout"d));
        WidgetGroup buttons4 = new HorizontalLayout();
        buttons4.addChild(new ImageButton("btn1", "fileclose"));
        buttons4.addChild(new ImageButton("btn2", "fileopen"));
        buttons4.addChild(new ImageButton("btn3", "exit"));
        addChild(buttons4);

        addChild(new VSpacer());
        addChild(new TextWidget(null, "In vertical layouts:"d));
        HorizontalLayout hlayout2 = new HorizontalLayout();
        hlayout2.layoutHeight(FILL_PARENT); //layoutWidth(FILL_PARENT).

        buttons1 = new VerticalLayout();
        buttons1.addChild(new TextWidget(null, "Buttons"d));
        buttons1.addChild(new Button("btn1", "Button 1"d));
        buttons1.addChild(new Button("btn2", "Button 2"d));
        buttons1.addChild((new Button("btn3", "Button 3 - disabled"d)).enabled(false));
        buttons1.addChild(new Button("btn4", "Button 4"d));
        hlayout2.addChild(buttons1);
        hlayout2.addChild(new HSpacer());

        buttons2 = new VerticalLayout();
        buttons2.addChild(new TextWidget(null, "CheckBoxes"d));
        buttons2.addChild(new CheckBox("btn1", "CheckBox 1"d));
        buttons2.addChild(new CheckBox("btn2", "CheckBox 2"d));
        buttons2.addChild(new CheckBox("btn3", "CheckBox 3"d));
        buttons2.addChild(new CheckBox("btn4", "CheckBox 4"d));
        hlayout2.addChild(buttons2);
        hlayout2.addChild(new HSpacer());

        buttons3 = new VerticalLayout();
        buttons3.addChild(new TextWidget(null, "RadioButtons"d));
        buttons3.addChild(new RadioButton("btn1", "RadioButton 1"d));
        buttons3.addChild(new RadioButton("btn2", "RadioButton 2"d));
        //buttons3.addChild(new ResizerWidget());
        buttons3.addChild(new RadioButton("btn3", "RadioButton 3"d));
        buttons3.addChild(new RadioButton("btn4", "RadioButton 4"d));
        hlayout2.addChild(buttons3);
        hlayout2.addChild(new HSpacer());

        buttons4 = new VerticalLayout();
        buttons4.addChild(new TextWidget(null, "ImageButtons"d));
        buttons4.addChild(new ImageButton("btn1", "fileclose"));
        buttons4.addChild(new ImageButton("btn2", "fileopen"));
        buttons4.addChild(new ImageButton("btn3", "exit"));
        hlayout2.addChild(buttons4);
        hlayout2.addChild(new HSpacer());

        WidgetGroup buttons5 = new VerticalLayout();
        buttons5.addChild(new TextWidget(null, "ImageTextButtons"d));
        buttons5.addChild(new ImageTextButton("btn1", "fileclose", "Close"d));
        buttons5.addChild(new ImageTextButton("btn2", "fileopen", "Open"d));
        buttons5.addChild(new ImageTextButton("btn3", "exit", "Exit"d));
        hlayout2.addChild(buttons5);


        addChild(hlayout2);

        addChild(new VSpacer());
        layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT);
    }
}
