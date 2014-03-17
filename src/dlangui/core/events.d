module dlangui.core.events;

import std.conv;

enum MouseAction : ushort {
	LButtonDown,
	LButtonUp,
	MButtonDown,
	MButtonUp,
	RButtonDown,
	RButtonUp,
	Wheel,
	Move,
	Leave,
	Hover
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
struct ButtondDetails {
	/// Clock.currStdTime() for down event of this button (0 if button is up).
	long  _downTs;
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
		_downTs = std.datetime.Clock.currStdTime;
	}
	/// update for button up
	void up() {
		_downTs = 0;
		_downX = 0;
		_downY = 0;
		_downFlags = 0;
	}
	@property bool isDown() { return downTs != 0; }
}

class MouseEvent {
	protected MouseAction _action;
	protected ushort _flags;
	protected short _x;
	protected short _y;
	protected ButonDetails _lbutton;
	protected ButonDetails _mbutton;
	protected ButonDetails _rbutton;
	@property MouseAction action() { return _action; }
	@property ushort flags() { return _flags; }
	@property short x() { return _x; }
	@property short y() { return _y; }
	this (MouseAction a, ushort f, short x, short y) {
		_action = a;
		_flags = f;
		_x = x;
		_y = y;
	}
}
