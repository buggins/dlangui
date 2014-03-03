module dlangui.platforms.common.platform;

public class Window {
    abstract public void show();
    abstract public string getWindowCaption();
    abstract public void setWindowCaption(string caption);
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

