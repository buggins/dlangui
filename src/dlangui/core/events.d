module dlangui.core.events;

import std.conv;

enum MouseAction : ubyte {
    Cancel,   // button down handling is cancelled
	ButtonDown, // button is down
	ButtonUp, // button is up
	Move,     // mouse pointer is moving
	FocusIn,  // pointer moved outside of widget while button was down
	FocusOut, // pointer is back inside widget while button is down after FocusIn
    Wheel,    // scroll wheel movement
    Leave     // pointer left widget which has before processed Move message, while button was not down
}

enum MouseFlag : ushort {
	Control = 0x0008,
	LButton = 0x0001,
	MButton = 0x0010,
	RButton = 0x0002,
	Shift   = 0x0004,
	XButton1= 0x0020,
	XButton2= 0x0040
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
