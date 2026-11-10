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

/// buttons to show message bars (EditBox.showMessage) in the editor
Widget createMessageBarsControl(EditBox editor) {
    HorizontalLayout res = new HorizontalLayout("MessageBarsControl");
    res.addChild(new TextWidget(null, "Message bars: "d));
    TextWidget status = new TextWidget("MESSAGE_BAR_STATUS", ""d);
    enum ACTION_RELOAD = 30001, ACTION_KEEP = 30002;
    Button add(dstring label, void delegate() handler) {
        Button btn = new Button(null, label);
        btn.click = delegate(Widget w) { handler(); return true; };
        res.addChild(btn);
        return btn;
    }
    add("Info"d, () {
        editor.showMessage("info", "The file is opened read-only. (Escape dismisses this message.)"d, EditorMessageKind.Info, [ACTION_IGNORE])
            .dismissOnEscape = true;
    });
    add("Warning"d, () {
        editor.showMessage("changed", "The file was changed on disk. It has unsaved changes in the editor."d, EditorMessageKind.Warning,
            [new Action(ACTION_RELOAD, "Reload"d), new Action(ACTION_KEEP, "Keep mine"d)]);
    });
    add("Error, long text"d, () {
        editor.showMessage("error", "The file cannot be saved: permission denied. The quick brown fox jumps over the lazy dog. "d
            ~ "The quick brown fox jumps over the lazy dog. The quick brown fox jumps over the lazy dog. "d
            ~ "The quick brown fox jumps over the lazy dog. The quick brown fox jumps over the lazy dog."d,
            EditorMessageKind.Error, [ACTION_RETRY], EditorPanelPosition.Top, true);
    });
    add("Bottom"d, () {
        editor.showMessage("bottom", "A message below the text, with a close button."d, EditorMessageKind.Info, null,
            EditorPanelPosition.Bottom, true);
    });
    add("Hide all"d, () {
        foreach (id; ["info", "changed", "error", "bottom"])
            editor.hideMessage(id);
    });
    editor.messageAction = delegate(EditBox source, string messageId, const Action action) {
        status.text = "clicked: "d ~ toUTF32(messageId) ~ " / "d ~ action.label;
        if (action.id == ACTION_RELOAD || action.id == ACTION_KEEP || action.id == StandardAction.Retry)
            source.hideMessage(messageId);
        return true;
    };
    res.addChild(status);
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
    addChild(createMessageBarsControl(editBox));
    addChild(editBox);

    addChild(new TextWidget(null, "EditBox: additional view for the same content (split view testing)"d));
    SourceEdit editBox2 = new SourceEdit("editbox2");
    editBox2.content = editBox.content; // view the same content as first editbox
    addChild(editBox2);
    layoutHeight(FILL_PARENT).layoutWidth(FILL_PARENT);
    }
}
