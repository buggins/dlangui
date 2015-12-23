module d3d;

import dlangui;

mixin APP_ENTRY_POINT;

/// entry point for dlangui based application
extern (C) int UIAppMain(string[] args) {
    // create window
    Window window = Platform.instance.createWindow("DlangUI example - 3D Application", null, WindowFlag.Resizable, 600, 500);

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
            CanvasWidget {
                id: canvas
                minWidth: 500
                minHeight: 300
            }
        }
    });

    auto canvas = window.mainWidget.childById!CanvasWidget("canvas");
    canvas.onDrawListener = delegate(CanvasWidget canvas, DrawBuf buf, Rect rc) {
            Log.w("canvas.onDrawListener clipRect=" ~ to!string(buf.clipRect));
            buf.fill(0xFFFFFF);
            int x = rc.left;
            int y = rc.top;
            buf.fillRect(Rect(x+20, y+20, x+150, y+200), 0x80FF80);
            buf.fillRect(Rect(x+90, y+80, x+250, y+250), 0x80FF80FF);
            canvas.font.drawText(buf, x + 40, y + 50, "fillRect()"d, 0xC080C0);
            buf.drawFrame(Rect(x + 400, y + 30, x + 550, y + 150), 0x204060, Rect(2,3,4,5), 0x80704020);
            canvas.font.drawText(buf, x + 400, y + 5, "drawFrame()"d, 0x208020);
            canvas.font.drawText(buf, x + 300, y + 100, "drawPixel()"d, 0x000080);
            for (int i = 0; i < 80; i++)
                buf.drawPixel(x+300 + i * 4, y+140 + i * 3 % 100, 0xFF0000 + i * 2);
            canvas.font.drawText(buf, x + 200, y + 150, "drawLine()"d, 0x800020);
            for (int i = 0; i < 40; i+=3)
                buf.drawLine(Point(x+200 + i * 4, y+190), Point(x+150 + i * 7, y+320 + i * 2), 0x008000 + i * 5);
        };

    // show window
    window.show();

    // run message loop
    return Platform.instance.enterMessageLoop();
}
