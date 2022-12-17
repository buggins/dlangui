module widgets.icons;

import dlangui;
import dlangui.graphics.iconprovider; // TODO_GRIM: this isn't imported by dlangui

static if(BACKEND_GUI)
{
    class IconsExample : TableLayout
    {
        this(string ID)
        {
            super(ID);
            colCount = 6;
            for(StandardIcon icon = StandardIcon.init; icon <= StandardIcon.deviceCameraVideo; ++icon)
            {
                addChild(new TextWidget(to!string(icon), to!dstring(icon)).fontSize(12.pointsToPixels).alignment(Align.Right | Align.VCenter));
                auto imageBufRef = platform.iconProvider().getStandardIcon(icon);
                auto imageWidget = new ImageWidget();
                if (!imageBufRef.isNull()) {
                    auto imageDrawable = new ImageDrawable(imageBufRef);
                    imageWidget.drawable = imageDrawable;
                }
                addChild(imageWidget).alignment(Align.Left | Align.VCenter);
            }
            margins(Rect(10,10,10,10)).layoutWidth(FILL_PARENT);
        }
    }
}
else
{
    class IconsExample : VerticalLayout
    {
        this(string ID)
        {
            super(ID);
            addChild(new TextWidget(null, "Icons in text mode are not supported"d));
        }
    }
}
