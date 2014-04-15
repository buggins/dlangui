module dlangui.core.events;

import dlangui.core.i18n;
private import dlangui.widgets.widget;

import std.conv;

/// UI action
class Action {
    protected int _id;
    protected UIString _label;
    protected string _iconId;
    this(int id, string labelResourceId, string iconResourceId = null) {
        _id = id;
        _label = labelResourceId;
        _iconId = iconResourceId;
    }
    this(int id, dstring label, string iconResourceId = null) {
        _id = id;
        _label = label;
        _iconId = iconResourceId;
    }
    @property int id() const {
        return _id;
    }
    @property Action id(int newId) {
        _id = newId;
        return this;
    }
    @property Action label(string resourceId) {
        _label = resourceId;
        return this;
    }
    @property Action label(dstring text) {
        _label = text;
        return this;
    }
    @property dstring label() const {
        return _label.value;
    }
    @property ref const (UIString) labelValue() const {
        return _label;
    }
    @property string iconId() const {
        return _iconId;
    }
    @property Action iconId(string id) {
        _iconId = id;
        return this;
    }
}


enum MouseAction : ubyte {
    Cancel,   // button down handling is cancelled
	ButtonDown, // button is down
	ButtonUp, // button is up
	Move,     // mouse pointer is moving
	FocusIn,  // pointer is back inside widget while button is down after FocusOut
	FocusOut, // pointer moved outside of widget while button was down (if handler returns true, Move events will be sent even while pointer is outside widget)
    Wheel,    // scroll wheel movement
    //Hover,    // pointer entered widget which while button was not down (return true to track Hover state)
    Leave     // pointer left widget which has before processed Move message, while button was not down
}

enum MouseFlag : ushort {
	Control = 0x0008,
	LButton = 0x0001,
	MButton = 0x0010,
	RButton = 0x0002,
	Shift   = 0x0004,
	XButton1= 0x0020,
	XButton2= 0x0040,
	Alt     = 0x0080
}

/// mouse button state details
struct ButtonDetails {
	/// Clock.currStdTime() for down event of this button (0 if button is up).
	long  _downTs;
	/// Clock.currStdTime() for up event of this button (0 if button is still down).
	long  _upTs;
	/// x coordinates of down event
	short _downX;
	/// y coordinates of down event
	short _downY;
	/// mouse button flags when down event occured
	ushort _downFlags;
	/// update for button down
	void down(short x, short y, ushort flags) {
		_downX = x;
		_downY = y;
		_downFlags = flags;
        _upTs = 0;
		_downTs = std.datetime.Clock.currStdTime;
	}
	/// update for button up
	void up(short x, short y, ushort flags) {
        _upTs = std.datetime.Clock.currStdTime;
	}
	@property bool isDown() { return _downTs != 0 && _upTs == 0; }
    /// returns button down state duration in hnsecs (1/10000 of second).
    @property int downDuration() {
        if (_downTs == 0)
            return 0;
        if (_downTs != 0 && _upTs != 0)
            return cast(int)(_upTs - _downTs);
        long ts = std.datetime.Clock.currStdTime;
        return cast(int)(ts - _downTs);
    }
    @property short downX() { return _downX; }
    @property short downY() { return _downY; }
    @property ushort downFlags() { return _downFlags; }
}

enum MouseButton : ubyte {
    None,
    Left,
    Right,
    Middle
    //XButton1, // additional button
    //XButton2, // additional button
}

class MouseEvent {
    protected long _eventTimestamp;
	protected MouseAction _action;
	protected MouseButton _button;
	protected short _x;
	protected short _y;
	protected ushort _flags;
	protected short _wheelDelta;
    protected Widget _trackingWidget;
	protected ButtonDetails _lbutton;
	protected ButtonDetails _mbutton;
	protected ButtonDetails _rbutton;
	protected bool _doNotTrackButtonDown;
    @property ref ButtonDetails lbutton() { return _lbutton; }
    @property ref ButtonDetails rbutton() { return _rbutton; }
    @property ref ButtonDetails mbutton() { return _mbutton; }
    @property MouseButton button() { return _button; }
	@property MouseAction action() { return _action; }
	void changeAction(MouseAction a) { _action = a; }
	@property ushort flags() { return _flags; }
	@property short wheelDelta() { return _wheelDelta; }
	@property short x() { return _x; }
	@property short y() { return _y; }
    /// get event tracking widget to override
	@property Widget trackingWidget() { return _trackingWidget; }
	@property bool doNotTrackButtonDown() { return _doNotTrackButtonDown; }
	@property void doNotTrackButtonDown(bool flg) { _doNotTrackButtonDown = flg; }
    /// override mouse tracking widget
    void track(Widget w) {
        _trackingWidget = w;
    }
    this (MouseEvent e) {
        _eventTimestamp = e._eventTimestamp;
		_action = e._action;
        _button = e._button;
		_flags = e._flags;
		_x = e._x;
		_y = e._y;
        _lbutton = e._lbutton;
        _rbutton = e._rbutton;
        _mbutton = e._mbutton;
        _wheelDelta = e._wheelDelta;
    }
	this (MouseAction a, MouseButton b, ushort f, short x, short y, short wheelDelta = 0) {
        _eventTimestamp = std.datetime.Clock.currStdTime;
		_action = a;
        _button = b;
		_flags = f;
		_x = x;
		_y = y;
        _wheelDelta = wheelDelta;
	}
}


enum KeyAction : uint {
    KeyDown,
    KeyUp,
    Text,
    Repeat,
}

enum KeyFlag : uint {
	Control = 0x0008,
	Shift   = 0x0004,
	Alt     = 0x0080,
    RControl = 0x0108,
	RShift   = 0x0104,
	RAlt     = 0x0180
}

enum KeyCode : uint {
    BACK = 8,
    TAB = 9,
    RETURN = 0x0D,
    SHIFT = 0x10,
    CONTROL = 0x11,
    ALT = 0x12, // VK_MENU
    PAUSE = 0x13,
    CAPS = 0x14, // VK_CAPITAL, caps lock
    ESCAPE = 0x1B, // esc
    SPACE = 0x20,
    PAGEUP = 0x21, // VK_PRIOR
    PAGEDOWN = 0x22, // VK_NEXT
    END = 0x23, // VK_END
    HOME = 0x24, // VK_HOME
    LEFT = 0x25,
    UP = 0x26,
    RIGHT = 0x27,
    DOWN = 0x28,
    INS = 0x2D,
    DEL = 0x2E,
    KEY_0 = 0x30,
    KEY_1 = 0x31,
    KEY_2 = 0x32,
    KEY_3 = 0x33,
    KEY_4 = 0x34,
    KEY_5 = 0x35,
    KEY_6 = 0x36,
    KEY_7 = 0x37,
    KEY_8 = 0x38,
    KEY_9 = 0x39,
    KEY_A = 0x41,
    KEY_B = 0x42,
    KEY_C = 0x43,
    KEY_D = 0x44,
    KEY_E = 0x45,
    KEY_F = 0x46,
    KEY_G = 0x47,
    KEY_H = 0x48,
    KEY_I = 0x49,
    KEY_J = 0x4a,
    KEY_K = 0x4b,
    KEY_L = 0x4c,
    KEY_M = 0x4d,
    KEY_N = 0x4e,
    KEY_O = 0x4f,
    KEY_P = 0x50,
    KEY_Q = 0x51,
    KEY_R = 0x52,
    KEY_S = 0x53,
    KEY_T = 0x54,
    KEY_U = 0x55,
    KEY_V = 0x56,
    KEY_W = 0x57,
    KEY_X = 0x58,
    KEY_Y = 0x59,
    KEY_Z = 0x5a,
    LWIN = 0x5b,
    RWIN = 0x5c,
    NUM_0 = 0x60,
    NUM_1 = 0x61,
    NUM_2 = 0x62,
    NUM_3 = 0x63,
    NUM_4 = 0x64,
    NUM_5 = 0x65,
    NUM_6 = 0x66,
    NUM_7 = 0x67,
    NUM_8 = 0x68,
    NUM_9 = 0x69,
    MUL = 0x6A,
    ADD = 0x6B,
    DIV = 0x6F,
    SUB = 0x6D,
    DECIMAL = 0x6E,
    F1 = 0x70,
    F2 = 0x71,
    F3 = 0x72,
    F4 = 0x73,
    F5 = 0x74,
    F6 = 0x75,
    F7 = 0x76,
    F8 = 0x77,
    F9 = 0x78,
    F10 = 0x79,
    F11 = 0x7a,
    F12 = 0x7b,
    F13 = 0x7c,
    F14 = 0x7d,
    F15 = 0x7e,
    F16 = 0x7f,
    F17 = 0x80,
    F18 = 0x81,
    F19 = 0x82,
    F20 = 0x83,
    F21 = 0x84,
    F22 = 0x85,
    F23 = 0x86,
    F24 = 0x87,
    NUMLOCK = 0x90,
    SCROLL = 0x91, // scroll lock
    LSHIFT = 0xA0,
    RSHIFT = 0xA1,
    LCONTROL = 0xA2,
    RCONTROL = 0xA3,
    LALT = 0xA4,
    RALT = 0xA5,
}

/// keyboard event
class KeyEvent {
    protected KeyAction _action;
    protected uint _keyCode;
    protected uint _flags;
    protected dstring _text;
    /// key action (KeyDown, KeyUp, Text, Repeat)
    @property KeyAction action() { return _action; }
    /// key code
    @property uint keyCode() { return _keyCode; }
    /// flags (shift, ctrl, alt...)
    @property uint flags() { return _flags; }
    /// entered text, for Text action
    @property dstring text() { return _text; }
    /// create key event
    this(KeyAction action, uint keyCode, uint flags, dstring text = null) {
        _action = action;
        _keyCode = keyCode;
        _flags = flags;
        _text = text;
    }
}

enum ScrollAction : ubyte {
    /// space above indicator pressed
    PageUp,
    /// space below indicator pressed
    PageDown, 
    /// up/left button pressed
    LineUp,
    /// down/right button pressed
    LineDown,
    /// slider pressed
    SliderPressed,
    /// dragging in progress
    SliderMoved,
    /// dragging finished
    SliderReleased
}

/// slider/scrollbar event
class ScrollEvent {
    private ScrollAction _action;
    private int _minValue;
    private int _maxValue;
    private int _pageSize;
    private int _position;
    private bool _positionChanged;
    @property ScrollAction action() { return _action; }
    @property int minValue() { return _minValue; }
    @property int maxValue() { return _maxValue; }
    @property int pageSize() { return _pageSize; }
    @property int position() { return _position; }
    @property bool positionChanged() { return _positionChanged; }
    /// change position in event handler to update slider position
    @property void position(int newPosition) { _position = newPosition; _positionChanged = true; }
    this(ScrollAction action, int minValue, int maxValue, int pageSize, int position) {
        _action = action;
        _minValue = minValue;
        _maxValue = maxValue;
        _pageSize = pageSize;
        _position = position;
    }
    /// default update position for actions like PageUp/PageDown, LineUp/LineDown
    int defaultUpdatePosition() {
        int delta = 0;
        switch (_action) {
            case ScrollAction.LineUp:
                delta = _pageSize / 20;
                if (delta < 1)
                    delta = 1;
                delta = -delta;
                break;
            case ScrollAction.LineDown:
                delta = _pageSize / 20;
                if (delta < 1)
                    delta = 1;
                break;
            case ScrollAction.PageUp:
                delta = _pageSize * 3 / 4;
                if (delta < 1)
                    delta = 1;
                delta = -delta;
                break;
            case ScrollAction.PageDown:
                delta = _pageSize * 3 / 4;
                if (delta < 1)
                    delta = 1;
                break;
            default:
                return position;
        }
        int newPosition = _position + delta;
        if (newPosition > _maxValue - _pageSize)
            newPosition = _maxValue - _pageSize;
        if (newPosition < _minValue)
            newPosition = _minValue;
        if (_position != newPosition)
            position = newPosition;
        return position;
    }
}
