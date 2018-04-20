module app;

static assert(ENABLE_OPENGL, "All bezier samples in this module using 
    floating point drawing functions which is not supported in minimal config");

import dlangui;

import std.algorithm.comparison;

mixin APP_ENTRY_POINT;

// helper for scaling relative to average 96dpi FullHD, IDK but maybe a bad idea after all
T scaledByDPI(T)(T val) {
    return val *= (SCREEN_DPI()/cast(T)96);
}

/// Entry point for dlangui based application
extern (C) int UIAppMain(string[] args) {
    // portrait "mode" window
    Window window = Platform.instance.createWindow("Bezier curves", null, WindowFlag.Resizable, 480.scaledByDPI, 600.scaledByDPI);
    window.mainWidget = new BezierSamples();
    window.show();
    return Platform.instance.enterMessageLoop();
}

class BezierSamples : VerticalLayout {

    this() {
        this(null);
    }
    this(string id) {
        super(id);
        addChild(new CubicTraceSample);
        addChild(new FlattenCubicSample);
        addChild(new ColoredCubicTraceSample);
        addChild(new FlattenCubicGuidesSample);
        addChild(new FlattenQuadraticSample);
    }

    override bool animating() { return true; }
}


abstract class SampleCanvas : CanvasWidget {

    dstring _sampleName = "Bezier sample";
    static immutable vec2[] _controlPointsDefaultRatios = [vec2(0,0.2), vec2(0.2,0.2), vec2(0.8,0.8), vec2(1,0.8)];
    static immutable vec2[] _controlPointsQuadratic = [vec2(0.2,0.8), vec2(0.7,0.4), vec2(0.3,0.2)];

    this() {
        fillHorizontal();
        auto p = 5.scaledByDPI;
        margins(Rect(p, p, p, p));
        p = 15.scaledByDPI;
        padding(Rect(p, p, p, p));
        minHeight = 250.scaledByDPI;
    }

    dstring sampleName() { return _sampleName; }

    override protected void measuredContent(int parentWidth, int parentHeight, int contentWidth, int contentHeight) {
        _measuredWidth = max(minHeight, contentWidth);
        _measuredHeight = minHeight;
    }

    protected void drawText(DrawBuf buf, Rect rc, dstring text) {
        FontRef font = font();
        Point sz = font.textSize(text);
        applyAlign(rc, sz, Align.HCenter, Align.Bottom );
        font.drawText(buf, rc.left, rc.top, text, textColor, 4, 0, textFlags);
    }

    protected void calcRectSize(const vec2[] controlPoints, vec2[] result) {
        assert(result.length >= controlPoints.length);
        auto r = _pos;
        applyMargins(r);
        applyPadding(r);
        vec2 pos = vec2(r.left, r.top);
        vec2 size = vec2(r.width, r.height);
        result[] = controlPoints[]; // copy points
        result[0] = result[0].mul(size) + pos;
        result[1] = result[1].mul(size) + pos;
        result[2] = result[2].mul(size) + pos;
        if(controlPoints.length > 3)
        result[3] = result[3].mul(size) + pos;
    }

    // override to draw
    override void doDraw(DrawBuf buf, Rect rc) {
    }
}

class CubicTraceSample : SampleCanvas {
    this() {
        _sampleName = "Cubic bezier curve drawn with ellipses (slow, high overdraw)";
    }
    override void doDraw(DrawBuf buf, Rect rc) {
        vec2[4] points;
        calcRectSize(_controlPointsDefaultRatios, points);
        auto len = (points[0]-points[3]).magnitude;
        auto interval = 1f/len;
        auto step = interval;
        // evaluate normal bezier curve and trace with circles
        foreach ( i ; 0..len ) {
            auto b = bezierCubic(points, interval); 
            interval+=step;
            buf.drawEllipseF(b.x, b.y, 3, 3, 0, Color.black, Color.black);
        }
        drawText(buf,rc, sampleName());
    }
}

class FlattenCubicSample : SampleCanvas {
    this() {
        _sampleName = "Flattened cubic bezier curve drawn with lines (fast)";
    }
    override void doDraw(DrawBuf buf, Rect rc) {
        vec2[4] points;
        calcRectSize(_controlPointsDefaultRatios, points);
        enum segments = 10;
        auto lines = flattenBezierCubic(points, segments);
        buf.polyLineF(lines, 3f.scaledByDPI, Color.black);
        drawText(buf,rc, sampleName());
    }
}

class ColoredCubicTraceSample : SampleCanvas {
    this() {
        _sampleName = "Simple colored cubic bezier curve drawn with ellipsises";
    }
    override void doDraw(DrawBuf buf, Rect rc) {
        vec2[4] points;
        calcRectSize(_controlPointsDefaultRatios, points);
        auto len = (points[0]-points[3]).magnitude;
        auto interval = 1/len;
        auto step = interval;
        // evaluate normal bezier curve and trace with circles
        foreach ( i ; 0..len ) {
            auto b = bezierCubic(points, interval); 
            interval+=step;
            buf.drawEllipseF(b.x, b.y, 3, 3, 0, COLOR_TRANSPARENT, lerpColor01(Color.blue, Color.red, interval));
        }
        drawText(buf,rc, sampleName());
    }

    // clamp to [0,1] and lerp color
    static uint lerpColor01(uint a, uint b, float ratio) {
        ratio = clamp(ratio, 0, 1);
        return blendARGB(b, a, cast(uint)(ratio * 255));
    }
}

class FlattenCubicGuidesSample : SampleCanvas {
    this() {
        _sampleName = "Flattened cubic bezier curve with direction and normal vectors";
    }
    override void doDraw(DrawBuf buf, Rect rc) {
        vec2[4] points;
        calcRectSize(_controlPointsDefaultRatios, points);
        enum segmentsCount = 10;
        auto lines = flattenBezierCubic(points, segmentsCount);
        drawCubicControlsGuides(buf, points);
        buf.polyLineF(lines, 3f.scaledByDPI, Color.black);
        drawCubicSegmentsNormDir(buf, points, segmentsCount, lines, true, true);
        drawText(buf,rc, sampleName());
    }
}

class FlattenQuadraticSample : SampleCanvas {
    this() {
        _sampleName = "Flattened quadratic bezier curve";
    }
    override void doDraw(DrawBuf buf, Rect rc) {
        vec2[3] points;
        calcRectSize(_controlPointsQuadratic, points);

        // guide lines
        buf.drawLineF(points[0], points[1], 1, Color.dark_gray);
        buf.drawLineF(points[1], points[2], 1, Color.dark_gray);
        

        enum segmentCount = 10;
        auto lines = flattenBezierQuadratic(points, segmentCount);
        buf.polyLineF(lines, 3f.scaledByDPI, Color.black);

        // end points
        buf.drawEllipseF(points[0].x, points[0].y, 5,5, 1, Color.antique_white, Color.cyan);
        buf.drawEllipseF(points[2].x, points[2].y, 5,5, 1, Color.antique_white, Color.cyan);
        buf.drawEllipseF(points[1].x, points[1].y, 3,3, 0, Color.antique_white, Color.cyan);

        // draw the direction & normal vectors
        auto segStep = 1f/segmentCount;
        foreach(i; 0..segmentCount) {
            auto dir = bezierQuadraticDirection(points, i*segStep);
            auto norm = dir.rotated90ccw;
            auto point = lines[i];
            buf.drawLineF(point, point + (dir * 15f), 3.scaledByDPI, Color.yellow );
            buf.drawLineF(point, point + (norm * 15f), 3.scaledByDPI, Color.red );
    }

        drawText(buf,rc, sampleName());
    }
}



void drawCubicControlsGuides(DrawBuf buf, vec2[] controls) {
    buf.drawLineF(controls[0], controls[1], 1, Color.black);
    buf.drawLineF(controls[2], controls[3], 1, Color.black);
    buf.drawEllipseF(controls[0].x, controls[0].y, 5,5, 1, Color.antique_white, Color.cyan);
    buf.drawEllipseF(controls[3].x, controls[3].y, 5,5, 1, Color.antique_white, Color.cyan);
    buf.drawEllipseF(controls[1].x, controls[1].y, 3,3, 0, Color.antique_white, Color.cyan);
    buf.drawEllipseF(controls[2].x, controls[2].y, 3,3, 0, Color.antique_white, Color.cyan);
}

void drawCubicSegmentsNormDir(DrawBuf buf, vec2[] controls, int segmentCount, vec2[] segments, bool direction, bool normals) {
    if ( !direction && !normals && segments.length < 2)
        return;
    // draw the direction & normal vectors
    auto segStep = 1f/segmentCount;
    foreach(i; 0..segmentCount) {
        auto dir = bezierCubicDirection(controls, i*segStep);
        auto norm = dir.rotated90ccw;
        auto point = segments[i];
        if ( direction )
        buf.drawLineF(point, point + (dir * 15f), 3.scaledByDPI, Color.yellow );
        if ( normals )
        buf.drawLineF(point, point + (norm * 15f), 3.scaledByDPI, Color.red );
    }
}