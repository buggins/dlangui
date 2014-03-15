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

class MouseEvent {
	protected MouseAction _action;
	protected ushort _flags;
	protected short _x;
	protected short _y;
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
