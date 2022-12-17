module widgets.animation;

import dlangui;

static if(BACKEND_GUI)
{
    class AnimatedDrawable : Drawable
    {
        DrawableRef background;
        this()
        {
            background = drawableCache.get("tx_fabric.tiled");
        }

        void drawAnimatedRect(DrawBuf buf, uint p, Rect rc, int speedx, int speedy, int sz)
        {
            int x = (p * speedx % rc.width);
            int y = (p * speedy % rc.height);
            if (x < 0)
                x += rc.width;
            if (y < 0)
                y += rc.height;
            uint a = 64 + ((p / 2) & 0x7F);
            uint r = 128 + ((p / 7) & 0x7F);
            uint g = 128 + ((p / 5) & 0x7F);
            uint b = 128 + ((p / 3) & 0x7F);
            uint color = (a << 24) | (r << 16) | (g << 8) | b;
            buf.fillRect(Rect(rc.left + x, rc.top + y, rc.left + x + sz, rc.top + y + sz), color);
        }

        void drawAnimatedIcon(DrawBuf buf, uint p, Rect rc, int speedx, int speedy, string resourceId)
        {
            int x = (p * speedx % rc.width);
            int y = (p * speedy % rc.height);
            if (x < 0)
                x += rc.width;
            if (y < 0)
                y += rc.height;
            DrawBufRef image = drawableCache.getImage(resourceId);
            buf.drawImage(x, y, image.get);
        }

        override void drawTo(DrawBuf buf, Rect rc, uint state = 0, int tilex0 = 0, int tiley0 = 0)
        {
            background.drawTo(buf, rc, state, cast(int)(animationProgress / 695430), cast(int)(animationProgress / 1500000));
            drawAnimatedRect(buf, cast(uint)(animationProgress / 295430), rc, 2, 3, 100);
            drawAnimatedRect(buf, cast(uint)(animationProgress / 312400) + 100, rc, 3, 2, 130);
            drawAnimatedIcon(buf, cast(uint)(animationProgress / 212400) + 200, rc, -2, 1, "dlangui-logo1");
            drawAnimatedRect(buf, cast(uint)(animationProgress / 512400) + 300, rc, 2, -2, 200);
            drawAnimatedRect(buf, cast(uint)(animationProgress / 214230) + 800, rc, 1, 2, 390);
            drawAnimatedIcon(buf, cast(uint)(animationProgress / 123320) + 900, rc, 1, 2, "cr3_logo");
            drawAnimatedRect(buf, cast(uint)(animationProgress / 100000) + 100, rc, -1, -1, 120);
        }
        @property override int width() { return 1; }
        @property override int height() { return 1; }
        ulong animationProgress;
        void animate(long interval) { animationProgress += interval; }

    }

    class SampleAnimationWidget : VerticalLayout
    {
        AnimatedDrawable drawable;
        DrawableRef drawableRef;
        this(string ID)
        {
            super(ID);
            drawable = new AnimatedDrawable();
            drawableRef = drawable;
            padding = Rect(20, 20, 20, 20);
            addChild(new TextWidget(null, "This is TextWidget on top of animated background"d));
            addChild(new EditLine(null, "This is EditLine on top of animated background"d));
            addChild(new Button(null, "This is Button on top of animated background"d));
            addChild(new VSpacer());
        }

        /// background drawable
        @property override DrawableRef backgroundDrawable() const
        {
            return (cast(SampleAnimationWidget)this).drawableRef;
        }

        /// returns true is widget is being animated - need to call animate() and redraw
        @property override bool animating() const { return true; }

        /// animates window; interval is time left from previous draw, in hnsecs (1/10000000 of second)
        override void animate(long interval)
        {
            drawable.animate(interval);
            invalidate();
        }
    }
}
else
{
    class SampleAnimationWidget : VerticalLayout
    {
        this(string ID)
        {
            super(ID);
            addChild(new TextWidget(null, "Animations in text mode are not supported"d));
        }
    }
}
