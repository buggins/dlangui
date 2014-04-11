module dlangui.core.events;

import dlangui.core.i18n;

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
	protected ButtonDetails _lbutton;
	protected ButtonDetails _mbutton;
	protected ButtonDetails _rbutton;
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
