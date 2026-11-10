module widgets.text;

import dlangui;
import std.conv : to;

/// text truncation with an ellipsis (ellipsize property): drag the slider to change the width of the labels
class TextExample : VerticalLayout
{
    this(string ID)
    {
        super(ID);
        // sizes in pixels; in console mode, pixels are character cells
        static if (BACKEND_CONSOLE) {
            enum int minW = 4, maxW = 100, initW = 40, pad = 0, gap = 0;
        } else {
            enum int minW = 20, maxW = 700, initW = 300, pad = 4, gap = 2;
        }
        layoutWidth = FILL_PARENT;
        layoutHeight = FILL_PARENT;
        padding = Rect(pad * 2, pad * 2, pad * 2, pad * 2);

        HorizontalLayout widthRow = new HorizontalLayout();
        widthRow.layoutWidth = FILL_PARENT;
        widthRow.addChild(new TextWidget(null, "Width: "d));
        SliderWidget slider = new SliderWidget("TEXT_WIDTH_SLIDER");
        slider.setRange(minW, maxW).position(initW).layoutWeight(1).fillHorizontal;
        widthRow.addChild(slider);
        TextWidget widthLabel = new TextWidget("TEXT_WIDTH_LABEL", to!dstring(initW) ~ " px"d);
        widthLabel.minWidth = BACKEND_CONSOLE ? 8 : 60.pointsToPixels;
        widthRow.addChild(widthLabel);
        addChild(widthRow);

        VerticalLayout labels = new VerticalLayout("TEXT_LABELS");
        labels.layoutWidth = initW;
        labels.backgroundColor = 0xC0808080;
        labels.padding = Rect(pad, pad, pad, pad);

        enum dstring sentence = "The quick brown fox jumps over the lazy dog near the river bank"d;
        TextWidget add(dstring text, TextEllipsis mode) {
            TextWidget w = new TextWidget(null, text);
            w.layoutWidth = FILL_PARENT;
            w.ellipsize = mode;
            w.fullTextTooltip = true;
            w.margins = Rect(0, gap, 0, gap);
            labels.addChild(w);
            return w;
        }
        add("None: "d ~ sentence, TextEllipsis.None);
        add("End: "d ~ sentence, TextEllipsis.End);
        add("Start: "d ~ sentence, TextEllipsis.Start);
        add("Middle: "d ~ sentence, TextEllipsis.Middle);
        add("Words: "d ~ sentence, TextEllipsis.End).ellipsisOptions = EllipsisOptions.words();
        add("/home/user/projects/dlangui/src/dlangui/widgets/controls.d"d, TextEllipsis.Middle).ellipsisOptions = EllipsisOptions.path();
        add("Hot key: &File menu item with a long label"d, TextEllipsis.End).textFlags = TextFlag.UnderlineHotKeys;

        TextWidget multi = add("Multi-line, maxLines 3: "d ~ sentence ~ ". "d ~ sentence ~ ". "d ~ sentence ~ "."d, TextEllipsis.End);
        multi.maxLines = 3;

        ImageTextButton btn = new ImageTextButton(null, "document-open", "Button with a long label: "d ~ sentence);
        btn.layoutWidth = FILL_PARENT;
        btn.ellipsize = TextEllipsis.End;
        btn.label.fullTextTooltip = true;
        labels.addChild(btn);

        // the same from DML
        labels.addChild(parseML(q{
            TextWidget { text: "DML, ellipsize: Middle — The quick brown fox jumps over the lazy dog"; ellipsize: Middle; layoutWidth: fill }
        }));
        // in a horizontal row, so that labels.layoutWidth is respected
        HorizontalLayout labelsRow = new HorizontalLayout();
        labelsRow.layoutWidth = FILL_PARENT;
        labelsRow.addChild(labels);
        labelsRow.addChild(new HSpacer());
        addChild(labelsRow);
        addChild(new VSpacer());

        slider.scrollEvent = delegate(AbstractSlider source, ScrollEvent event) {
            if (event.action == ScrollAction.SliderMoved || event.action == ScrollAction.SliderReleased
                    || event.action == ScrollAction.PageUp || event.action == ScrollAction.PageDown
                    || event.action == ScrollAction.LineUp || event.action == ScrollAction.LineDown) {
                int w = event.position;
                labels.layoutWidth = w;
                widthLabel.text = to!dstring(w) ~ " px"d;
                labels.requestLayout();
            }
            return false;
        };
    }
}
