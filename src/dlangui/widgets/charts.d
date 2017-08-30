// Written in the D programming language.

/**
This module contains charts widgets implementation.
Currently only SimpleBarChart.


Synopsis:

----
import dlangui.widgets.charts;

// creation of simple bar chart
SimpleBarChart chart = new SimpleBarChart("chart");

// add bars
chart.addBar(12.2, makeRGBA(255, 0, 0, 0), "new bar"c);

// update bar with index 0
chart.updateBar(0, 10, makeRGBA(255, 255, 0, 0), "new bar updated"c);
chart.updateBar(0, 20);

// remove bars with index 0
chart.removeBar(0, 20);

// change title
chart.title = "new title"d;

// change min axis ratio
chart.axisRatio = 0.3; // y axis length will be 0.3 of x axis

----

Copyright: Andrzej Kilijański, 2017
License:   Boost License 1.0
Authors:   Andrzej Kilijański, and3md@gmail.com
*/

module dlangui.widgets.charts;

import dlangui.widgets.widget;
import std.math;
import std.algorithm.comparison;
import std.algorithm : remove;
import std.conv;

class SimpleBarChart : Widget {

    this(string ID = null) {
        super(ID);
        clickable = false;
        focusable = false;
        trackHover = false;
        styleId = "SIMPLE_BAR_CHART";
        _axisX.arrowSize = 1;
        title =  UIString.fromId("TITLE_NEW_CHART"c);
        measureTextToSetWidgetSize();
    }

    this(string ID, string titleResourceId) {
        this(ID);
        title = UIString.fromId(titleResourceId);
    }

    this(string ID, dstring title) {
        this(ID);
        this.title = UIString.fromRaw(title);
    }

    this(string ID, UIString title) {
        this(ID);
        this.title = title;
    }

    struct BarData {
        double y;
        UIString title;
        private Point _titleSize;
        uint color;

        this (double y, uint color, UIString title) {
            this.y = y;
            this.color = color;
            this.title = title;
        }
    }

    protected BarData[] _bars;
    protected double _maxY = 0;

    size_t barCount() {
        return _bars.length;
    }

    void addBar(double y, uint color, UIString barTitle) {
        if (y < 0)
            return; // current limitation only positive values
        _bars ~= BarData(y, color, barTitle);
        if (y > _maxY)
            _maxY = y;
        requestLayout();
    }

    void addBar(double y, uint color, string barTitle) {
        addBar(y, color, UIString.fromId(barTitle));
    }

    void addBar(double y, uint color, dstring barTitle) {
        addBar(y, color, UIString.fromRaw(barTitle));
    }

    void removeBar(size_t index) {
        _bars = remove(_bars, index);
        // update _maxY
        _maxY = 0;
        foreach (ref bar ; _bars) {
            if (bar.y > _maxY)
                _maxY = bar.y;
        }
        requestLayout();
    }

    void updateBar(size_t index, double y, uint color, string barTitle) {
        updateBar(index, y, color, UIString.fromId(barTitle));
    }

    void updateBar(size_t index, double y, uint color, dstring barTitle) {
        updateBar(index, y, color, UIString.fromRaw(barTitle));
    }

    void updateBar(size_t index, double y, uint color, UIString barTitle) {
        if (y < 0)
            return; // current limitation only positive values
        _bars[index].y = y;
        _bars[index].color = color;
        _bars[index].title = barTitle;

        // update _maxY
        _maxY = 0;
        foreach (ref bar ; _bars) {
            if (bar.y > _maxY)
                _maxY = bar.y;
        }
        requestLayout();
    }

    void updateBar(size_t index, double y) {
        if (y < 0)
            return; // curent limitation only positive values
        _bars[index].y = y;

        // update _maxY
        _maxY = 0;
        foreach (ref bar ; _bars) {
            if (bar.y > _maxY)
                _maxY = bar.y;
        }
        requestLayout();
    }

    protected UIString _title;
    protected bool _showTitle = true;
    protected Point _titleSize;
    protected int _marginAfterTitle = 2;

    /// set title to show
    @property Widget title(string s) {
        return title(UIString.fromId(s));
    }

    @property Widget title(dstring s) {
        return title(UIString.fromRaw(s));
    }

    /// set title to show
    @property Widget title(UIString s) {
        _title = s;
        measureTitleSize();
        if (_showTitle)
            requestLayout();
        return this;
    }

    /// get title value
    @property dstring title() {
        return _title;
    }

    /// show title?
    @property bool showTitle() {
        return _showTitle;
    }

    @property void showTitle(bool show) {
        if (_showTitle != show) {
            _showTitle = show;
            requestLayout();
        }
    }

    override protected void handleFontChanged() {
        measureTitleSize();
        measureTextToSetWidgetSize();
    }

    protected void measureTitleSize() {
        FontRef font = font();
        _titleSize = font.textSize(_title, MAX_WIDTH_UNSPECIFIED, 4, 0, textFlags); //todo: more than one line title support
    }

    @property uint chartBackgroundColor() {return ownStyle.customColor("chart_background_color"); }

    @property Widget chartBackgroundColor(uint newColor) {
        ownStyle.setCustomColor("chart_background_color",newColor);
        invalidate();
        return this;
    }

    @property uint chartAxisColor() {return ownStyle.customColor("chart_axis_color"); }

    @property Widget chartAxisColor(uint newColor) {
        ownStyle.setCustomColor("chart_axis_color",newColor);
        invalidate();
        return this;
    }

    @property uint chartSegmentTagColor() {return ownStyle.customColor("chart_segment_tag_color"); }

    @property Widget chartSegmentTagColor(uint newColor) {
        ownStyle.setCustomColor("chart_segment_tag_color",newColor);
        invalidate();
        return this;
    }

    struct AxisData {
        Point maxDescriptionSize = Point(30,20);
        int thickness = 1;
        int arrowSize = 20;
        int segmentTagLength = 4;
        int zeroValueDist = 3;
        int lengthFromZeroToArrow = 200;
    }

    AxisData _axisX;
    AxisData _axisY;

    protected int _axisYMaxValueDescWidth = 30;
    protected int _axisYAvgValueDescWidth = 30;

    protected double _axisRatio = 0.6;

    @property double axisRatio() {
        return _axisRatio;
    }

    @property void axisRatio(double newRatio) {
        _axisRatio = newRatio;
        requestLayout();
    }

    protected int _minBarWidth = 10;
    protected int _barWidth = 10;
    protected int _barDistance = 3;

    protected int _axisXMinWfromZero = 150;
    protected int _axisYMinDescWidth = 30;

    protected dstring _textToSetDescLineSize = "aaaaaaaaaa";
    protected Point _measuredTextToSetDescLineSize;

    @property dstring textToSetDescLineSize() {
        return _textToSetDescLineSize;
    }

    @property void textToSetDescLineSize(dstring newText) {
        _textToSetDescLineSize = newText;
        measureTextToSetWidgetSize();
        requestLayout();
    }

    private int[] _charWidths;
    protected Point measureTextToSetWidgetSize() {
        FontRef font = font();
        _charWidths.length = _textToSetDescLineSize.length;
        int charsMeasured = font.measureText(_textToSetDescLineSize, _charWidths, MAX_WIDTH_UNSPECIFIED, 4);
        _measuredTextToSetDescLineSize.x = charsMeasured > 0 ? _charWidths[charsMeasured - 1]: 0;
        _measuredTextToSetDescLineSize.y = font.height;
        return _measuredTextToSetDescLineSize;
    }

    override void measure(int parentWidth, int parentHeight) {
        FontRef font = font();

        int mWidth = minWidth;
        int mHeight = minHeight;

        int chartW = 0;
        int chartH = 0;

        _axisY.maxDescriptionSize = measureAxisYDesc();

        int usedWidth = _axisY.maxDescriptionSize.x + _axisY.thickness + _axisY.segmentTagLength + _axisX.zeroValueDist + margins.left + padding.left + margins.right + padding.right + _axisX.arrowSize;

        int currentMinBarWidth = max(_minBarWidth, _measuredTextToSetDescLineSize.x);
        _axisX.maxDescriptionSize.y = _measuredTextToSetDescLineSize.y;

        // axis length
        _axisX.lengthFromZeroToArrow = cast(uint) barCount * (currentMinBarWidth + _barDistance);

        if (_axisX.lengthFromZeroToArrow < _axisXMinWfromZero) {
            _axisX.lengthFromZeroToArrow = _axisXMinWfromZero;
            if (barCount > 0)
                _barWidth = cast (int) ((_axisX.lengthFromZeroToArrow - (_barDistance * barCount)) / barCount);
        }

        // minWidth and minHeight check

        if (minWidth > _axisX.lengthFromZeroToArrow + usedWidth) {
            _axisX.lengthFromZeroToArrow = minWidth-usedWidth;
            if (barCount > 0)
                _barWidth = cast (int) ((_axisX.lengthFromZeroToArrow - (_barDistance * barCount)) / barCount);
        }

        // width FILL_PARENT support
        if (parentWidth != SIZE_UNSPECIFIED && layoutWidth == FILL_PARENT) {
            if (_axisX.lengthFromZeroToArrow < parentWidth - usedWidth) {
                _axisX.lengthFromZeroToArrow = parentWidth - usedWidth;
            if (barCount > 0)
                _barWidth = cast (int) ((_axisX.lengthFromZeroToArrow - (_barDistance * barCount)) / barCount);
            }
        }


        // initialize axis y length
        _axisY.lengthFromZeroToArrow = cast(int) round(_axisRatio * _axisX.lengthFromZeroToArrow);

        // is axis Y enought long
        int usedHeight = _axisX.maxDescriptionSize.y + _axisX.thickness + _axisX.segmentTagLength + _axisY.zeroValueDist + ((_showTitle) ? _titleSize.y + _marginAfterTitle : 0) + margins.top + padding.top + margins.bottom + padding.bottom + _axisY.arrowSize;
        if (minHeight > _axisY.lengthFromZeroToArrow + usedHeight) {
            _axisY.lengthFromZeroToArrow = minHeight - usedHeight;
            _axisX.lengthFromZeroToArrow = cast (int) round(_axisY.lengthFromZeroToArrow / _axisRatio);
        }

        // height FILL_PARENT support
        if (parentHeight != SIZE_UNSPECIFIED && layoutHeight == FILL_PARENT) {
            if (_axisY.lengthFromZeroToArrow < parentHeight - usedHeight)
                _axisY.lengthFromZeroToArrow = parentHeight - usedHeight;
        }

        if (barCount > 0)
            _barWidth = cast (int) ((_axisX.lengthFromZeroToArrow - (_barDistance * barCount)) / barCount);

        // compute X axis max description height
        _axisX.maxDescriptionSize = measureAxisXDesc();

        // compute chart size
        chartW = _axisY.maxDescriptionSize.x + _axisY.thickness + _axisY.segmentTagLength + _axisX.zeroValueDist + _axisX.lengthFromZeroToArrow + _axisX.arrowSize;
        if (_showTitle && chartW < _titleSize.y)
            chartW = _titleSize.y;

        chartH = _axisX.maxDescriptionSize.y + _axisX.thickness + _axisX.segmentTagLength + _axisY.zeroValueDist + _axisY.lengthFromZeroToArrow + ((_showTitle) ? _titleSize.y + _marginAfterTitle : 0) + _axisY.arrowSize;
        measuredContent(parentWidth, parentHeight, chartW, chartH);
    }


    protected Point measureAxisXDesc() {
        Point sz;
        foreach (ref bar ; _bars) {
            bar._titleSize = font.measureMultilineText(bar.title, 0, _barWidth, 4, 0, textFlags);
            if (sz.y < bar._titleSize.y)
                sz.y = bar._titleSize.y;
            if (sz.x < bar._titleSize.x)
                sz.x = bar._titleSize.y;
        }
        return sz;
    }

    protected Point measureAxisYDesc() {
        int maxDescWidth = _axisYMinDescWidth;
        double currentMaxValue = _maxY;
        if (approxEqual(_maxY, 0, 0.0000001, 0.0000001))
            currentMaxValue = 100;

        Point sz = font.textSize(to!dstring(currentMaxValue), MAX_WIDTH_UNSPECIFIED, 4, 0, textFlags);
        if (maxDescWidth<sz.x)
            maxDescWidth=sz.x;
        _axisYMaxValueDescWidth = sz.x;
        sz = font.textSize(to!dstring(currentMaxValue / 2), MAX_WIDTH_UNSPECIFIED, 4, 0, textFlags);
        if (maxDescWidth<sz.x)
            maxDescWidth=sz.x;
        _axisYAvgValueDescWidth = sz.x;
        return Point(maxDescWidth, sz.y);
    }

    protected int barYValueToPixels(int axisInPixels, double barYValue ) {
        double currentMaxValue = _maxY;
        if (approxEqual(_maxY, 0, 0.0000001, 0.0000001))
            currentMaxValue = 100;

        double pixValue = axisInPixels / currentMaxValue;
        return cast(int) round(barYValue * pixValue);
    }

    override void onDraw(DrawBuf buf) {
        if (visibility != Visibility.Visible)
            return;
        super.onDraw(buf);

        Rect rc = _pos;
        applyMargins(rc);
        applyPadding(rc);

        auto saver = ClipRectSaver(buf, rc, alpha);

        FontRef font = font();
        if (_showTitle)
            font.drawText(buf, rc.left+ (_measuredWidth - _titleSize.x)/2  , rc.top, _title, textColor, 4, 0, textFlags);

        // draw axises and
        int x1 = rc.left + _axisY.maxDescriptionSize.x + _axisY.segmentTagLength;
        int x2 = rc.left + _axisY.maxDescriptionSize.x + _axisY.segmentTagLength + _axisY.thickness + _axisX.zeroValueDist + _axisX.lengthFromZeroToArrow + _axisX.arrowSize;
        int y1 = rc.bottom - _axisX.maxDescriptionSize.y - _axisX.segmentTagLength - _axisX.thickness - _axisY.zeroValueDist - _axisY.lengthFromZeroToArrow - _axisY.arrowSize;
        int y2 = rc.bottom - _axisX.maxDescriptionSize.y - _axisX.segmentTagLength;

        buf.fillRect(Rect(x1, y1, x2, y2), chartBackgroundColor);

        // y axis
        buf.drawLine(Point(x1 + 1, y1), Point(x1 + 1, y2), chartAxisColor);

        // x axis
        buf.drawLine(Point(x1, y2 - 1), Point(x2, y2 - 1), chartAxisColor);

        // top line - will be optional in the future
        buf.drawLine(Point(x1, y1), Point(x2, y1), chartAxisColor);

        // right line - will be optional in the future
        buf.drawLine(Point(x2, y1), Point(x2, y2), chartAxisColor);

        // draw bars

        int firstBarX = x1 + _axisY.thickness + _axisX.zeroValueDist;
        int firstBarY = y2 - _axisX.thickness - _axisY.zeroValueDist;

        SimpleTextFormatter fmt;
        foreach (ref bar ; _bars) {
            // draw bar
            buf.fillRect(Rect(firstBarX, firstBarY - barYValueToPixels(_axisY.lengthFromZeroToArrow, bar.y), firstBarX + _barWidth, firstBarY), bar.color);

            // draw x axis segment under bar
            buf.drawLine(Point(firstBarX + _barWidth / 2, y2), Point(firstBarX + _barWidth / 2, rc.bottom - _axisX.maxDescriptionSize.y), chartSegmentTagColor);

            // draw x axis description
            fmt.format(bar.title, font, 0, _barWidth, 4, 0, textFlags);
            fmt.draw(buf, firstBarX + (_barWidth - bar._titleSize.x) / 2, rc.bottom -  _axisX.maxDescriptionSize.y + (_axisX.maxDescriptionSize.y - bar._titleSize.y) / 2, font, textColor, Align.HCenter);

            firstBarX += _barWidth + _barDistance;
        }

        // segments on y axis and values (now only max and max/2)
        double currentMaxValue = _maxY;
        if (approxEqual(_maxY, 0, 0.0000001, 0.0000001))
            currentMaxValue = 100;

        int yZero = rc.bottom - _axisX.maxDescriptionSize.y - _axisX.segmentTagLength - _axisX.thickness - _axisY.zeroValueDist;
        int yMax = yZero - _axisY.lengthFromZeroToArrow;
        int yAvg = (yZero + yMax) / 2;

        buf.drawLine(Point(rc.left + _axisY.maxDescriptionSize.x, yMax), Point(rc.left + _axisY.maxDescriptionSize.x + _axisY.segmentTagLength, yMax), chartSegmentTagColor);
        buf.drawLine(Point(rc.left + _axisY.maxDescriptionSize.x, yAvg), Point(rc.left + _axisY.maxDescriptionSize.x + _axisY.segmentTagLength, yAvg), chartSegmentTagColor);

        font.drawText(buf, rc.left + (_axisY.maxDescriptionSize.x - _axisYMaxValueDescWidth), yMax - _axisY.maxDescriptionSize.y / 2, to!dstring(currentMaxValue), textColor, 4, 0, textFlags);
        font.drawText(buf, rc.left + (_axisY.maxDescriptionSize.x - _axisYAvgValueDescWidth), yAvg - _axisY.maxDescriptionSize.y / 2, to!dstring(currentMaxValue / 2), textColor, 4, 0, textFlags);

    }

    override void onThemeChanged() {
        super.onThemeChanged();
        handleFontChanged();
    }
}

