module app;

import dlangui;

mixin APP_ENTRY_POINT;

import dlangui.widgets.scroll;

class DragonView : ScrollWidget {

    private {
        int _scaleX;
        int _scaleY;
        int _middleX;
        int _middleY;
        int _dx;
        int _dy;
        int _x0;
        int _y0;
        int _length = 256;
        int _dir0 = 0; // either 0 or 1
        int _straightLen = 10;
        int _roundLen = 4;
        uint _bgcolor = 0x101010;
        uint _grid1color = 0x303030;
        uint _grid2color = 0x202020;
        uint _grid3color = 0x181818;
        uint _curve1color = 0x4050FF;
        uint _curve2color = 0xFF4040;
        uint _curve3color = 0x30C020;
        uint _curve4color = 0xC000D0;
        bool[4] _partVisible = [true, true, true, true];

        bool _needRepaint = true;
        Point[8] _directionVectors;
    }


    ColorDrawBuf _drawBuf;

    this(string ID) {
        super(ID);
        fillParent();
        //_fullScrollableArea.right = 2048;
        //_fullScrollableArea.bottom = 2048;
        setVectors();
        resize(2048, 2048);
    }

    void resize(int dx, int dy) {
        _dx = dx;
        _dy = dy;
        _fullScrollableArea.right = dx;
        _fullScrollableArea.bottom = dy;
        _visibleScrollableArea.left = dx / 2 - 400;
        _visibleScrollableArea.top = dy / 2 - 300;
        _visibleScrollableArea.right = _visibleScrollableArea.left + 400;
        _visibleScrollableArea.bottom = _visibleScrollableArea.top + 400;

        if (!_drawBuf) {
            _drawBuf = new ColorDrawBuf(_fullScrollableArea.width, _fullScrollableArea.height);
        } else {
            _drawBuf.resize(dx, dy);
        }
        _middleX = _fullScrollableArea.width / 2;
        _middleY = _fullScrollableArea.height / 2;
        _needRepaint = true;
        drawCurve();
    }

    void setVectors() {
        setVectors(_straightLen, _roundLen);
    }
    void setVectors(int straightLen, int roundLen) {
        if (!straightLen && !roundLen)
            straightLen = 1;
        setVectors([
            Point(straightLen, 0),
            Point(roundLen, -roundLen),
            Point(0, -straightLen),
            Point(-roundLen, -roundLen),
            Point(-straightLen, 0),
            Point(-roundLen, roundLen),
            Point(0, straightLen),
            Point(roundLen, roundLen),
        ]);
    }

    void setVectors(Point[8] vectors) {
        import std.math : abs;
        _directionVectors = vectors;
        int maxx1, maxx2, maxy1, maxy2;
        for(int i = 0; i < 8; i += 2) {
            if (maxx1 == 0 || maxx1 < abs(_directionVectors[i].x))
                maxx1 = abs(_directionVectors[i].x);
            if (maxy1 == 0 || maxy1 < abs(_directionVectors[i].y))
                maxy1 = abs(_directionVectors[i].y);
            if (maxx2 == 0 || maxx1 < abs(_directionVectors[i + 1].x))
                maxx2 = abs(_directionVectors[i + 1].x);
            if (maxy2 == 0 || maxy1 < abs(_directionVectors[i + 1].y))
                maxy2 = abs(_directionVectors[i + 1].y);
        }
        if (_dir0 == 0) {
            _scaleX = maxx1 + maxx2 * 2;
            _scaleY = maxy1 + maxy2 * 2;
        } else {
            _scaleX = maxx1 + maxx2;
            _scaleY = maxy1 + maxy2;
        }
        _x0 = vectors[1].x;
        _y0 = vectors[1].y;
        repaint();
    }

    bool getPartVisible(int n) {
        return _partVisible[n & 3];
    }
    void setPartVisible(int n, bool flgVisible) {
        n = n & 3;
        if (_partVisible[n] != flgVisible) {
            _partVisible[n] = flgVisible;
            repaint();
        }
    }

    @property int straightLen() {
        return _straightLen;
    }
    @property DragonView straightLen(int n) {
        if (_straightLen != n) {
            _straightLen = n;
            setVectors();
        }
        return this;
    }
    @property int roundLen() {
        return _roundLen;
    }
    @property DragonView roundLen(int n) {
        if (_roundLen != n) {
            _roundLen = n;
            setVectors();
        }
        return this;
    }
    @property int length() {
        return _length;
    }
    @property DragonView length(int n) {
        if (_length != n) {
            _length = n;
            repaint();
        }
        return this;
    }
    void repaint() {
        _needRepaint = true;
        invalidate();
    }
    @property int rotation() {
        return _dir0;
    }
    @property DragonView rotation(int angle) {
        if (_dir0 != (angle & 7)) {
            _dir0 = angle & 7;
            _needRepaint = true;
            repaint();
        }
        return this;
    }

    /// Draw widget at its position to buffer
    override void onDraw(DrawBuf buf) {
        if (_needRepaint)
            drawCurve();
        super.onDraw(buf);
    }

    void drawLine(Point pt1, Point pt2, uint color) {
        pt1.x += _middleX;
        pt2.x += _middleX;
        pt1.y = _middleY - pt1.y;
        pt2.y = _middleY - pt2.y;
        _drawBuf.drawLine(pt1, pt2, color);
    }

    void drawBackground() {
        _drawBuf.fill(_bgcolor);
        int i = 0;
        for (int x = 0; x < _middleX; x += _scaleX) {
            uint color = _scaleX > 2 ? _grid3color : COLOR_TRANSPARENT;
            if (i == 0)
                color = _grid1color;
            else if ((i & 15) == 0)
                color = _grid2color;
            if (color != COLOR_TRANSPARENT) {
                drawLine(Point(x, -_middleY), Point(x, _middleY), color);
                drawLine(Point(-x, -_middleY), Point(-x, _middleY), color);
                if (x == 0) {
                    drawLine(Point(x - 1, -_middleY), Point(x - 1, _middleY), color);
                    drawLine(Point(x + 1, -_middleY), Point(x + 1, _middleY), color);
                }
            }
            i++;
        }
        i = 0;
        for (int y = 0; y < _middleY; y += _scaleY) {
            uint color = _scaleY > 2 ? _grid3color : COLOR_TRANSPARENT;
            if (i == 0)
                color = _grid1color;
            else if ((i & 15) == 0)
                color = _grid2color;
            if (color != COLOR_TRANSPARENT) {
                drawLine(Point(-_middleX, y), Point(_middleX, y), color);
                drawLine(Point(-_middleX, -y), Point(_middleX, -y), color);
                if (y == 0) {
                    drawLine(Point(-_middleX, y - 1), Point(_middleX, y - 1), color);
                    drawLine(Point(-_middleX, y + 1), Point(_middleX, y + 1), color);
                }
            }
            i++;
        }
    }

    int getDirectionDelta(int n) {
        if (n == 0)
            return -1;
        for (int i = 0; i < 30; i++) {
            if (n & (1 << i)) {
                return (n & (2 << i)) ? 1 : -1;
            }
        }
        return 0;
    }

    void drawSegment(ref Point currentPoint, ref int currentDir, int n, uint color, int mirror) {
        int mx = _middleX + _scaleX * 2;
        int my = _middleY + _scaleY * 2;
        bool insideView = currentPoint.x >= -mx  && currentPoint.x <= mx && currentPoint.y >= -my && currentPoint.y <= my;
        int delta = getDirectionDelta(n) * mirror;
        Point nextPoint = currentPoint + _directionVectors[currentDir];
        if (insideView)
            drawLine(currentPoint, nextPoint, color);
        currentPoint = nextPoint;
        currentDir = (currentDir + delta) & 7;
        nextPoint = currentPoint + _directionVectors[currentDir];
        if (insideView)
            drawLine(currentPoint, nextPoint, color);
        currentPoint = nextPoint;
        currentDir = (currentDir + delta) & 7;
    }

    void drawLines() {
        int dir;
        Point p0;
        Point pt;
        if (_dir0 == 0)
            p0 = Point(0, _directionVectors[_dir0 + 1].y);
        else
            p0 = Point(-_directionVectors[0].x / 2, _directionVectors[_dir0 + 1].y / 2);
        // segment 1
        if (_partVisible[0]) {
            dir = 0 + _dir0;
            pt = p0 - (_directionVectors[dir] + _directionVectors[dir + 1]);
            for(int i = 0; i < _length; i++)
                drawSegment(pt, dir, i, _curve1color, 1);
        }
        // segment 2
        if (_partVisible[1]) {
            dir = 4 + _dir0;
            pt = p0 + _directionVectors[dir + 1];
            for(int i = -1; i > -_length; i--)
                drawSegment(pt, dir, i, _curve2color, -1);
        }
        // segment 3
        if (_partVisible[2]) {
            dir = 4 + _dir0;
            pt = p0 - (_directionVectors[dir - 1] + _directionVectors[dir]);
            for(int i = 0; i < _length; i++)
                drawSegment(pt, dir, i, _curve3color, 1);
        }
        // segment 4
        if (_partVisible[3]) {
            dir = 0 + _dir0;
            pt = p0 + _directionVectors[(dir - 1) & 7];
            for(int i = -1; i > -_length; i--)
                drawSegment(pt, dir, i, _curve4color, -1);
        }
    }
    void drawCurve() {
        drawBackground();
        drawLines();
        _needRepaint = false;
    }

    /// calculate full content size in pixels
    override Point fullContentSize() {
        Point sz = Point(_fullScrollableArea.width, _fullScrollableArea.height);
        return sz;
    }

    override protected void drawClient(DrawBuf buf) {
        Point sz = fullContentSize();
        Point p = scrollPos;
        //_contentWidget.layout(Rect(_clientRect.left - p.x, _clientRect.top - p.y, _clientRect.left + sz.x - p.x, _clientRect.top + sz.y - p.y));
        //_contentWidget.onDraw(buf);
        /// draw source buffer rectangle contents to destination buffer
        buf.drawFragment(_clientRect.left, _clientRect.top, _drawBuf, 
                         Rect(_visibleScrollableArea.left, _visibleScrollableArea.top, 
                              _visibleScrollableArea.left + _clientRect.width, _visibleScrollableArea.top + _clientRect.height));
        //Rect rc = _clientRect;
        //rc.shrink(5, 5);
        //buf.fillRect(rc, 0xFF8080);
    }


}

immutable SLIDER_ACCELERATION_STEP = 64;

int sliderToSize(int n) {
    int limit = 0;
    int total = 0;
    int factor = 1;
    for(;;) {
        int newlimit = limit + SLIDER_ACCELERATION_STEP;
        if (n < newlimit) {
            return total + (n - limit) * factor;
        }
        total += SLIDER_ACCELERATION_STEP * factor;
        limit = newlimit;
        factor *= 2;
    }
}

int sizeToSlider(int n) {
    int limit = 0;
    int total = 0;
    int factor = 1;
    for(;;) {
        int newlimit = limit + SLIDER_ACCELERATION_STEP;
        int newtotal = total + SLIDER_ACCELERATION_STEP * factor;
        if (n < newtotal) {
            return limit + (n - total) / factor;
        }
        total = newtotal;
        limit = newlimit;
        factor *= 2;
    }
}

/// entry point for dlangui based application
extern (C) int UIAppMain(string[] args) {

    // create window
    Window window = Platform.instance.createWindow("DlangUI example : Dragon Curve"d, null, WindowFlag.Resizable, 800, 600);
    int n = sliderToSize(1000);
    int n2 = sizeToSlider(n);

    DragonView dragon = new DragonView("DRAGON_VIEW");

    auto onScrollEvent = delegate(AbstractSlider source, ScrollEvent event) {
        if (event.action == ScrollAction.SliderMoved) {
            switch(source.id) {
                case "straight":
                    dragon.straightLen = event.position;
                    break;
                case "round":
                    dragon.roundLen = event.position;
                    break;
                case "size":
                    dragon.length = sliderToSize(event.position);
                    break;
                default:
                    break;
            }
        }
        return true;
    };

    auto content = new VerticalLayout().fillParent;
    auto controls1 = new HorizontalLayout().fillHorizontal.padding(3.pointsToPixels).backgroundColor(0xD8D8D8);

    controls1.addChild(new TextWidget(null," Straight"d));
    auto sliderStraight = new SliderWidget("straight");
    sliderStraight.setRange(0, 20).position(dragon.straightLen).layoutWeight(1).fillHorizontal;
    sliderStraight.scrollEvent = onScrollEvent;
    controls1.addChild(sliderStraight);

    controls1.addChild(new TextWidget(null," Rounding"d));
    auto sliderRound = new SliderWidget("round");
    sliderRound.setRange(0, 20).position(dragon.roundLen).layoutWeight(1).fillHorizontal;
    sliderRound.scrollEvent = onScrollEvent;
    controls1.addChild(sliderRound);

    auto cbRotate = new CheckBox(null, " Rotate 45`"d);
    controls1.addChild(cbRotate).checked(dragon.rotation ? true : false);
    cbRotate.checkChange = delegate(Widget w, bool check) { 
            dragon.rotation(check ? 1 : 0); return true; 
    };
    auto cbPartVisible0 = new CheckBox(null, " A1"d);
    controls1.addChild(cbPartVisible0).checked(dragon.getPartVisible(0));
    cbPartVisible0.checkChange = delegate(Widget w, bool check) { 
        dragon.setPartVisible(0, check); return true; 
    };
    auto cbPartVisible1 = new CheckBox(null, " A2"d);
    controls1.addChild(cbPartVisible1).checked(dragon.getPartVisible(1));
    cbPartVisible1.checkChange = delegate(Widget w, bool check) { 
        dragon.setPartVisible(1, check); return true; 
    };
    auto cbPartVisible2 = new CheckBox(null, " B1"d);
    controls1.addChild(cbPartVisible2).checked(dragon.getPartVisible(2));
    cbPartVisible2.checkChange = delegate(Widget w, bool check) { 
        dragon.setPartVisible(2, check); return true; 
    };
    auto cbPartVisible3 = new CheckBox(null, " B2"d);
    controls1.addChild(cbPartVisible3).checked(dragon.getPartVisible(3));
    cbPartVisible3.checkChange = delegate(Widget w, bool check) { 
        dragon.setPartVisible(3, check); return true; 
    };

    controls1.addChild(new TextWidget(null," Size"d));
    auto sliderSize = new SliderWidget("size");
    sliderSize.setRange(2, 1000).position(sizeToSlider(dragon.length)).layoutWeight(10).fillHorizontal;
    sliderSize.scrollEvent = onScrollEvent;
    controls1.addChild(sliderSize);

    content.addChildren([controls1, dragon]);

    window.mainWidget = content;

    // show window
    window.show();

    // run message loop
    return Platform.instance.enterMessageLoop();
}
