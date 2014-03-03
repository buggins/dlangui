module dlangui.platforms.common.platform;

import dlangui.widgets.widget;
import dlangui.graphics.drawbuf;

public class Window {
    int _dx;
    int _dy;
    Widget _mainWidget;
    public @property int width() { return _dx; }
    public @property int height() { return _dy; }
    public @property Widget mainWidget() { return _mainWidget; }
    public @property void mainWidget(Widget widget) { 
        if (_mainWidget !is null)
            _mainWidget.window = null;
        _mainWidget = widget; 
        if (_mainWidget !is null)
            _mainWidget.window = this;
    }
    abstract public void show();
    abstract public @property string windowCaption();
    abstract public @property void windowCaption(string caption);
    public void onResize(int width, int height) {
        _dx = width;
        _dy = height;
        if (_mainWidget !is null) {
            _mainWidget.measure(_dx, _dy);
            _mainWidget.layout(Rect(0, 0, _dx, _dy));
        }
    }
    public void onDraw(DrawBuf buf) {
        if (_mainWidget !is null)
            _mainWidget.onDraw(buf);
    }
}

public class Platform {
    static __gshared Platform _instance;
    public static void setInstance(Platform instance) {
        _instance = instance;
    }
    public static Platform instance() {
        return _instance;
    }
    abstract public Window createWindow(string windowCaption, Window parent);
    abstract public int enterMessageLoop();
}

