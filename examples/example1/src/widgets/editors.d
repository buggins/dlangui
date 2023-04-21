module widgets.editors;

import dlangui;

immutable testCode =
`
#!/usr/bin/env rdmd
// Computes average line length for standard input.
import std.stdio;

void main()
{
ulong lines = 0;
double sumLength = 0;
foreach (line; stdin.byLine())
{
    ++lines;
    sumLength += line.length;
}
writeln("Average line length: ",
        lines ? sumLength / lines : 0);
}
`;

Widget createEditorSettingsControl(EditWidgetBase editor) {
    HorizontalLayout res = new HorizontalLayout("editor_options");
    res.addChild((new CheckBox("wantTabs", "wantTabs"d)).checked(editor.wantTabs).addOnCheckChangeListener(delegate(Widget, bool checked) { editor.wantTabs = checked; return true;}));
    res.addChild((new CheckBox("useSpacesForTabs", "useSpacesForTabs"d)).checked(editor.useSpacesForTabs).addOnCheckChangeListener(delegate(Widget, bool checked) { editor.useSpacesForTabs = checked; return true;}));
    res.addChild((new CheckBox("readOnly", "readOnly"d)).checked(editor.readOnly).addOnCheckChangeListener(delegate(Widget, bool checked) { editor.readOnly = checked; return true;}));
    res.addChild((new CheckBox("showLineNumbers", "showLineNumbers"d)).checked(editor.showLineNumbers).addOnCheckChangeListener(delegate(Widget, bool checked) { editor.showLineNumbers = checked; return true;}));
    res.addChild((new CheckBox("fixedFont", "fixedFont"d)).checked(editor.fontFamily == FontFamily.MonoSpace).addOnCheckChangeListener(delegate(Widget, bool checked) {
        if (checked)
            editor.fontFamily(FontFamily.MonoSpace).fontFace("Courier New");
        else
            editor.fontFamily(FontFamily.SansSerif).fontFace("Arial");
        return true;
    }));
    res.addChild((new CheckBox("tabSize", "Tab size 8"d)).checked(editor.tabSize == 8).addOnCheckChangeListener(delegate(Widget, bool checked) {
        if (checked)
            editor.tabSize(8);
        else
            editor.tabSize(4);
        return true;
    }));
    return res;
}

class EditorsExample : VerticalLayout
{
    this(string ID)
    {
        super(ID);

    // EditLine sample
    addChild(new TextWidget(null, "EditLine: Single line editor"d));
    EditLine editLine = new EditLine("editline1", "Single line editor sample text");
    addChild(createEditorSettingsControl(editLine));
    addChild(editLine);

    // EditBox sample
    addChild(new TextWidget(null, "SourceEdit: multiline editor, for source code editing"d));

    SourceEdit editBox = new SourceEdit("editbox1");
    editBox.text = UIString.fromRaw(testCode);
    addChild(createEditorSettingsControl(editBox));
    addChild(editBox);

    addChild(new TextWidget(null, "EditBox: additional view for the same content (split view testing)"d));
    SourceEdit editBox2 = new SourceEdit("editbox2");
    editBox2.content = editBox.content; // view the same content as first editbox
    addChild(editBox2);
    layoutHeight(FILL_PARENT).layoutWidth(FILL_PARENT);
    }
}
