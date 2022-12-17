module widgets.canvas;

import dlangui;

static if(BACKEND_GUI)
{
    class CanvasExample : CanvasWidget
    {
        this(string ID)
        {
            super(ID);
            layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT);
            onDrawListener = delegate(CanvasWidget canvas, DrawBuf buf, Rect rc) {
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
                canvas.font.drawText(buf, x + 300, y + 420, "drawLine()"d, 0x800020);
                for (int i = 0; i < 40; i+=3)
                    buf.drawLine(Point(x+200 + i * 4, y+290), Point(x+150 + i * 7, y+420 + i * 2), 0x008000 + i * 5);

                // Poly line example
                PointF[] poly = [vec2(x+130, y+150), vec2(x+240, y+80), vec2(x+170, y+170), vec2(x+380, y+270), vec2(x+220, y+400), vec2(x+130, y+330)];
                buf.polyLineF(poly, 18.0f, 0x80804020, true, 0x80FFFF00);
                canvas.font.drawText(buf, x + 190, y + 260, "polyLineF()"d, 0x603010);
                PointF[] poly2 = [vec2(x+430, y+250), vec2(x+540, y+180), vec2(x+470, y+270), vec2(x+580, y+300),
                    vec2(x+620, y+400), vec2(x+480, y+350), vec2(x+520, y+450), vec2(x+480, y+430)];
                buf.fillPolyF(poly2, 0x80203050);
                canvas.font.drawText(buf, x + 500, y + 460, "fillPolyF()"d, 0x203050);

                buf.drawEllipseF(x+300, y+600, 200, 150, 3, 0x80008000, 0x804040FF);
                canvas.font.drawText(buf, x + 300, y + 600, "fillEllipseF()"d, 0x208050);

                buf.drawEllipseArcF(x+540, y+600, 150, 180, 45, 130, 3, 0x40008000, 0x804040FF);
                canvas.font.drawText(buf, x + 540, y + 580, "drawEllipseArcF()"d, 0x208050);
            };
        }
    }
}
else
{
    class CanvasWidget : LinearLayout
    {
        this(string ID)
        {
            super(ID);
            addChild(new TextWidget(null, "Canvas in text mode is not supported"d));
        }
    }
}
