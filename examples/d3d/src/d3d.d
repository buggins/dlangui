module d3d;

import dlangui;

mixin APP_ENTRY_POINT;

/// entry point for dlangui based application
extern (C) int UIAppMain(string[] args) {
    // create window
    Window window = Platform.instance.createWindow("DlangUI example - 3D Application", null);

    // create some widget to show in window
    //window.mainWidget = (new Button()).text("Hello, world!"d).margins(Rect(20,20,20,20));
    window.mainWidget = parseML(q{
        VerticalLayout {
            margins: 10
            padding: 10
            backgroundColor: "#C0E0E070" // semitransparent yellow background
            // red bold text with size = 150% of base style size and font face Arial
            TextWidget { text: "Hello World example for DlangUI"; textColor: "red"; fontSize: 150%; fontWeight: 800; fontFace: "Arial" }
            // arrange controls as form - table with two columns
            TableLayout {
                colCount: 2
                TextWidget { text: "param 1" }
                EditLine { id: edit1; text: "some text" }
                TextWidget { text: "param 2" }
                EditLine { id: edit2; text: "some text for param2" }
                TextWidget { text: "some radio buttons" }
                // arrange some radio buttons vertically
                VerticalLayout {
                    RadioButton { id: rb1; text: "Item 1" }
                    RadioButton { id: rb2; text: "Item 2" }
                    RadioButton { id: rb3; text: "Item 3" }
                }
                TextWidget { text: "and checkboxes" }
                // arrange some checkboxes horizontally
                HorizontalLayout {
                    CheckBox { id: cb1; text: "checkbox 1" }
                    CheckBox { id: cb2; text: "checkbox 2" }
                }
            }
            HorizontalLayout {
                Button { id: btnOk; text: "Ok" }
                Button { id: btnCancel; text: "Cancel" }
            }
        }
    });

    // show window
    window.show();

    // run message loop
    return Platform.instance.enterMessageLoop();
}
