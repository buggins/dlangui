module widgets.charts;

import dlangui;

class ChartsExample : HorizontalLayout
{
    this(string ID)
    {
        super(ID);

        SimpleBarChart barChart1 = new SimpleBarChart("barChart1","SimpleBarChart Example"d);
        barChart1.addBar(12.0, makeRGBA(255,0,0,0), "Red bar"d);
        barChart1.addBar(24.0, makeRGBA(0,255,0,0), "Green bar"d);
        barChart1.addBar(5.0, makeRGBA(0,0,255,0), "Blue bar"d);
        barChart1.addBar(12.0, makeRGBA(230,126,34,0), "Orange bar"d);

        SimpleBarChart barChart2 = new SimpleBarChart("barChart2","SimpleBarChart Example - long descriptions"d);
        barChart2.addBar(12.0, makeRGBA(255,0,0,0), "Red bar\n(12.0)"d);
        barChart2.addBar(24.0, makeRGBA(0,255,0,0), "Green bar\n(24.0)"d);
        barChart2.addBar(5.0, makeRGBA(0,0,255,0), "Blue bar\n(5.0)"d);
        barChart2.addBar(12.0, makeRGBA(230,126,34,0), "Orange bar\n(12.0)\nlong long long description added here"d);

        SimpleBarChart barChart3 = new SimpleBarChart("barChart3","SimpleBarChart Example with axis ratio 0.3"d);
        barChart3.addBar(12.0, makeRGBA(255,0,0,0), "Red bar"d);
        barChart3.addBar(24.0, makeRGBA(0,255,0,0), "Green bar"d);
        barChart3.addBar(5.0, makeRGBA(0,0,255,0), "Blue bar"d);
        barChart3.addBar(12.0, makeRGBA(230,126,34,0), "Orange bar"d);
        barChart3.axisRatio = 0.3;

        SimpleBarChart barChart4 = new SimpleBarChart("barChart4","SimpleBarChart Example with axis ratio 1.3"d);
        barChart4.addBar(12.0, makeRGBA(255,0,0,0), "Red bar"d);
        barChart4.addBar(24.0, makeRGBA(0,255,0,0), "Green bar"d);
        barChart4.addBar(5.0, makeRGBA(0,0,255,0), "Blue bar"d);
        barChart4.addBar(12.0, makeRGBA(230,126,34,0), "Orange bar"d);
        barChart4.axisRatio = 1.3;

        VerticalLayout a = new VerticalLayout();
        VerticalLayout b = new VerticalLayout();

        a.addChild(barChart1);
        a.addChild(barChart2);
        b.addChild(barChart3);
        b.addChild(barChart4);

        addChild(a);
        addChild(b);

        layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT);
    }
}
