module app;

import dlangui;

mixin APP_ENTRY_POINT;

import dlangui.widgets.scroll;

class DragonView : ScrollWidget {

    int _scaleX;
    int _scaleY;
    int _middleX;
    int _middleY;
    int _dx;
    int _dy;
    int _x0;
    int _y0;
    int _length = 1000;
    int _dir0 = 0; // either 0 or 1
    int _straightLen = 10;
    int _roundLen = 4;
    uint _bgcolor = 0x101010;
    uint _grid1color = 0x303030;
    uint _grid2color = 0x202020;
    uint _grid3color = 0x181818;
    uint _curve1color = 0x4050FF;
    uint _curve2color = 0xFF4040;
    uint _curve3color = 0x30FF20;
    uint _curve4color = 0xC000D0;
    Point[8] _directionVectors = [
        Point(4, 0),
        Point(3, -3),
        Point(0, -4),
        Point(-3, -3),
        Point(-4, 0),
        Point(-3, 3),
        Point(0, 4),
        Point(3, 3),
    ];

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
        _visibleScrollableArea.left = dx / 2 - 300;
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
    }

    @property int straightLen() {
        return _straightLen;
    }
    @property DragonView straightLen(int n) {
        if (_straightLen != n) {
            _straightLen = n;
            setVectors();
            drawCurve();
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
            drawCurve();
        }
        return this;
    }
    @property int length() {
        return _length;
    }
    @property DragonView length(int n) {
        if (_length != n) {
            _length = n;
            drawCurve();
        }
        return this;
    }
    @property int rotation() {
        return _dir0;
    }
    @property DragonView rotation(int angle) {
        if (_dir0 != (angle & 7)) {
            _dir0 = angle & 7;
            drawCurve();
        }
        return this;
    }

    void drawLine(Point pt1, Point pt2, uint color) {
        pt1.x += _middleX;
        pt2.x += _middleX;
        pt1.y += _middleY;
        pt2.y += _middleY;
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
        int delta = getDirectionDelta(n) * mirror;
        Point nextPoint = currentPoint + _directionVectors[currentDir];
        drawLine(currentPoint, nextPoint, color);
        currentPoint = nextPoint;
        currentDir = (currentDir + delta) & 7;
        nextPoint = currentPoint + _directionVectors[currentDir];
        drawLine(currentPoint, nextPoint, color);
        currentPoint = nextPoint;
        currentDir = (currentDir + delta) & 7;
    }

    void drawCurve() {
        drawBackground();
        // segment 1
        int dir;
        Point p0;
        //Point p0 = Point(_directionVectors[_dir0].y, _directionVectors[_dir0 + 1].y );
        if (_dir0 == 0)
            p0 = Point(0, _directionVectors[_dir0 + 1].y);
        else
            p0 = Point(-_directionVectors[0].x / 2, _directionVectors[_dir0 + 1].y / 2);
        //Point p0 = Point(-_directionVectors[0].x * 0, -_directionVectors[0].y / 2);
        Point pt;
        ///*
        dir = 0 + _dir0;
        //Point pt = Point(_directionVectors[dir + 1].x - _scaleX, _directionVectors[dir].y);
        pt = p0 - (_directionVectors[dir] + _directionVectors[dir + 1]);
        for(int i = 0; i < _length; i++)
            drawSegment(pt, dir, i, _curve1color, 1);
        // segment 2
        ///*
        dir = 4 + _dir0;
        //pt = Point(-_directionVectors[dir + 1].x - _directionVectors[dir].x - _scaleX, _directionVectors[dir].y);
        pt = p0 + _directionVectors[dir + 1];//_directionVectors[dir].y
        for(int i = -1; i > -_length; i--)
            drawSegment(pt, dir, i, _curve2color, -1);
        //*/
        ///*
        // segment 3
        dir = 4 + _dir0;
        pt = p0 - (_directionVectors[dir - 1] + _directionVectors[dir]);
        for(int i = 0; i < _length; i++)
            drawSegment(pt, dir, i, _curve3color, 1);
        // segment 4
        dir = 0 + _dir0;
        pt = p0 + _directionVectors[(dir - 1) & 7];
        for(int i = -1; i > -_length; i--)
            drawSegment(pt, dir, i, _curve4color, -1);
        //*/
        invalidate();
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

/// entry point for dlangui based application
extern (C) int UIAppMain(string[] args) {

    // create window
    Log.d("Creating window");
    Window window = Platform.instance.createWindow("DlangUI example - Dragon Curve", null);
    Log.d("Window created");

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
                    dragon.length = event.position;
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

    controls1.addChild(new TextWidget(null," Size"d));
    auto sliderSize = new SliderWidget("size");
    sliderSize.setRange(2, 10000).position(dragon.length).layoutWeight(10).fillHorizontal;
    sliderSize.scrollEvent = onScrollEvent;
    controls1.addChild(sliderSize);

    content.addChildren([controls1, dragon]);

    window.mainWidget = content;

    // show window
    window.show();

    // run message loop
    return Platform.instance.enterMessageLoop();
}
