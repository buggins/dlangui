// Written in the D programming language.

/**

This module contains dlangui event types declarations.

Event types: MouseEvent, KeyEvent, ScrollEvent.

Action and Accelerator.


Copyright: Vadim Lopatin, 2014
License:   Boost License 1.0
Authors:   Vadim Lopatin, coolreader.org@gmail.com
*/
module dlangui.core.events;

import dlangui.core.i18n;
import dlangui.core.collections;

//static if (DLANGUI_GUI) {
//}
private import dlangui.widgets.widget;

private import std.string;
private import std.conv;
private import std.utf;

/// Keyboard accelerator (key + modifiers)
struct Accelerator {
    /// Key code, usually one of KeyCode enum items
    uint keyCode;
    /// Key flags bit set, usually one of KeyFlag enum items
    uint keyFlags;
    /// Returns accelerator text description
    @property dstring label() {
        dstring buf;
        version (OSX) {
            static if (true) {
                if (keyFlags & KeyFlag.Control)
                    buf ~= "Ctrl+";
                if (keyFlags & KeyFlag.Shift)
                    buf ~= "Shift+";
                if (keyFlags & KeyFlag.Option)
                    buf ~= "Opt+";
                if (keyFlags & KeyFlag.Command)
                    buf ~= "Cmd+";
            } else {
                if (keyFlags & KeyFlag.Control)
                    buf ~= "⌃";
                if (keyFlags & KeyFlag.Shift)
                    buf ~= "⇧";
                if (keyFlags & KeyFlag.Option)
                    buf ~= "⌥";
                if (keyFlags & KeyFlag.Command)
                    buf ~= "⌘";
            }
            buf ~= toUTF32(keyName(keyCode));
        } else {
            if ((keyFlags & KeyFlag.LControl) == KeyFlag.LControl && (keyFlags & KeyFlag.RControl) == KeyFlag.RControl)
                buf ~= "LCtrl+RCtrl+";
            else if ((keyFlags & KeyFlag.LControl) == KeyFlag.LControl)
                buf ~= "LCtrl+";
            else if ((keyFlags & KeyFlag.RControl) == KeyFlag.RControl)
                buf ~= "RCtrl+";
            else if (keyFlags & KeyFlag.Control)
                buf ~= "Ctrl+";
            if ((keyFlags & KeyFlag.LAlt) == KeyFlag.LAlt && (keyFlags & KeyFlag.RAlt) == KeyFlag.RAlt)
                buf ~= "LAlt+RAlt+";
            else if ((keyFlags & KeyFlag.LAlt) == KeyFlag.LAlt)
                buf ~= "LAlt+";
            else if ((keyFlags & KeyFlag.RAlt) == KeyFlag.RAlt)
                buf ~= "RAlt+";
            else if (keyFlags & KeyFlag.Alt)
                buf ~= "Alt+";
            if ((keyFlags & KeyFlag.LShift) == KeyFlag.LShift && (keyFlags & KeyFlag.RShift) == KeyFlag.RShift)
                buf ~= "LShift+RShift+";
            else if ((keyFlags & KeyFlag.LShift) == KeyFlag.LShift)
                buf ~= "LShift+";
            else if ((keyFlags & KeyFlag.RShift) == KeyFlag.RShift)
                buf ~= "RShift+";
            else if (keyFlags & KeyFlag.Shift)
                buf ~= "Shift+";
            if ((keyFlags & KeyFlag.LMenu) == KeyFlag.LMenu && (keyFlags & KeyFlag.RMenu) == KeyFlag.RMenu)
                buf ~= "LMenu+RMenu+";
            else if ((keyFlags & KeyFlag.LMenu) == KeyFlag.LMenu)
                buf ~= "LMenu+";
            else if ((keyFlags & KeyFlag.RMenu) == KeyFlag.RMenu)
                buf ~= "RMenu+";
            else if (keyFlags & KeyFlag.Menu)
                buf ~= "Menu+";
            buf ~= toUTF32(keyName(keyCode));
        }
        return cast(dstring)buf;
    }

    /// Serializes accelerator text description
    @property string toString() const {
        char[] buf;
        // ctrl
        if ((keyFlags & KeyFlag.LControl) == KeyFlag.LControl && (keyFlags & KeyFlag.RControl) == KeyFlag.RControl)
            buf ~= "LCtrl+RCtrl+";
        else if ((keyFlags & KeyFlag.LControl) == KeyFlag.LControl)
            buf ~= "LCtrl+";
        else if ((keyFlags & KeyFlag.RControl) == KeyFlag.RControl)
            buf ~= "RCtrl+";
        else if (keyFlags & KeyFlag.Control)
            buf ~= "Ctrl+";
        // alt
        if ((keyFlags & KeyFlag.LAlt) == KeyFlag.LAlt && (keyFlags & KeyFlag.RAlt) == KeyFlag.RAlt)
            buf ~= "LAlt+RAlt+";
        else if ((keyFlags & KeyFlag.LAlt) == KeyFlag.LAlt)
            buf ~= "LAlt+";
        else if ((keyFlags & KeyFlag.RAlt) == KeyFlag.RAlt)
            buf ~= "RAlt+";
        else if (keyFlags & KeyFlag.Alt)
            buf ~= "Alt+";
        // shift
        if ((keyFlags & KeyFlag.LShift) == KeyFlag.LShift && (keyFlags & KeyFlag.RShift) == KeyFlag.RShift)
            buf ~= "LShift+RShift+";
        else if ((keyFlags & KeyFlag.LShift) == KeyFlag.LShift)
            buf ~= "LShift+";
        else if ((keyFlags & KeyFlag.RShift) == KeyFlag.RShift)
            buf ~= "RShift+";
        else if (keyFlags & KeyFlag.Shift)
            buf ~= "Shift+";
        // menu
        if ((keyFlags & KeyFlag.LMenu) == KeyFlag.LMenu && (keyFlags & KeyFlag.RMenu) == KeyFlag.RMenu)
            buf ~= "LMenu+RMenu+";
        else if ((keyFlags & KeyFlag.LMenu) == KeyFlag.LMenu)
            buf ~= "LMenu+";
        else if ((keyFlags & KeyFlag.RMenu) == KeyFlag.RMenu)
            buf ~= "RMenu+";
        else if (keyFlags & KeyFlag.Menu)
            buf ~= "Menu+";
        buf ~= keyName(keyCode);
        return cast(string)buf;
    }
    /// parse accelerator from string
    bool parse(string s) {
        keyCode = 0;
        keyFlags = 0;
        s = s.strip;
        for(;;) {
            bool flagFound = false;
            if (s.startsWith("Ctrl+")) {
                keyFlags |= KeyFlag.Control;
                s = s[5 .. $];
                flagFound = true;
            }
            if (s.startsWith("LCtrl+")) {
                keyFlags |= KeyFlag.LControl;
                s = s[5 .. $];
                flagFound = true;
            }
            if (s.startsWith("RCtrl+")) {
                keyFlags |= KeyFlag.RControl;
                s = s[5 .. $];
                flagFound = true;
            }
            if (s.startsWith("Alt+")) {
                keyFlags |= KeyFlag.Alt;
                s = s[4 .. $];
                flagFound = true;
            }
            if (s.startsWith("LAlt+")) {
                keyFlags |= KeyFlag.LAlt;
                s = s[4 .. $];
                flagFound = true;
            }
            if (s.startsWith("RAlt+")) {
                keyFlags |= KeyFlag.RAlt;
                s = s[4 .. $];
                flagFound = true;
            }
            if (s.startsWith("Shift+")) {
                keyFlags |= KeyFlag.Shift;
                s = s[6 .. $];
                flagFound = true;
            }
            if (s.startsWith("LShift+")) {
                keyFlags |= KeyFlag.LShift;
                s = s[6 .. $];
                flagFound = true;
            }
            if (s.startsWith("RShift+")) {
                keyFlags |= KeyFlag.RShift;
                s = s[6 .. $];
                flagFound = true;
            }
            if (s.startsWith("Menu+")) {
                keyFlags |= KeyFlag.Menu;
                s = s[5 .. $];
                flagFound = true;
            }
            if (s.startsWith("LMenu+")) {
                keyFlags |= KeyFlag.LMenu;
                s = s[5 .. $];
                flagFound = true;
            }
            if (s.startsWith("RMenu+")) {
                keyFlags |= KeyFlag.RMenu;
                s = s[5 .. $];
                flagFound = true;
            }
            if (!flagFound)
                break;
            s = s.strip;
        }
        keyCode = parseKeyName(s);
        return keyCode != 0;
    }
}

/// use to for requesting of action state (to enable/disable, hide, get check status, etc)
struct ActionState {
    enum StateFlag {
        enabled = 1,
        visible = 2,
        checked = 4
    }
    protected ubyte _flags;
    /// when false, control showing this action should be disabled
    @property bool enabled() const { return (_flags & StateFlag.enabled) != 0; }
    @property void enabled(bool f) { _flags = f ? (_flags | StateFlag.enabled) : (_flags & ~StateFlag.enabled); }
    /// when false, control showing this action should be hidden
    @property bool visible() const { return (_flags & StateFlag.visible) != 0; }
    @property void visible(bool f) { _flags = f ? (_flags | StateFlag.visible) : (_flags & ~StateFlag.visible); }
    /// when true, for checkbox/radiobutton-like controls state should shown as checked
    @property bool checked() const { return (_flags & StateFlag.checked) != 0; }
    @property void checked(bool f) { _flags = f ? (_flags | StateFlag.checked) : (_flags & ~StateFlag.checked); }
    this(bool en, bool vis, bool check) {
        _flags = (en ? StateFlag.enabled : 0) 
            | (vis ? StateFlag.visible : 0) 
            | (check ? StateFlag.checked : 0);
    }
    string toString() const { 
        return (enabled ? "enabled" : "disabled") ~ (visible ? "_visible" : "_invisible") ~ (checked ? "_checked" : "");
    }
}

const ACTION_STATE_ENABLED = ActionState(true, true, false);
const ACTION_STATE_DISABLE = ActionState(false, true, false);
const ACTION_STATE_INVISIBLE = ActionState(false, false, false);

/// Match key flags
static bool matchKeyFlags(uint eventFlags, uint requestedFlags) {
    if (eventFlags == requestedFlags)
        return true;
    if ((requestedFlags & KeyFlag.RControl) == KeyFlag.RControl && (eventFlags & KeyFlag.RControl) != KeyFlag.RControl)
        return false;
    if ((requestedFlags & KeyFlag.LControl) == KeyFlag.LControl && (eventFlags & KeyFlag.LControl) != KeyFlag.LControl)
        return false;
    if ((requestedFlags & KeyFlag.RShift) == KeyFlag.RShift && (eventFlags & KeyFlag.RShift) != KeyFlag.RShift)
        return false;
    if ((requestedFlags & KeyFlag.LShift) == KeyFlag.LShift && (eventFlags & KeyFlag.LShift) != KeyFlag.LShift)
        return false;
    if ((requestedFlags & KeyFlag.RAlt) == KeyFlag.RAlt && (eventFlags & KeyFlag.RAlt) != KeyFlag.RAlt)
        return false;
    if ((requestedFlags & KeyFlag.LAlt) == KeyFlag.LAlt && (eventFlags & KeyFlag.LAlt) != KeyFlag.LAlt)
        return false;
    if ((requestedFlags & KeyFlag.RMenu) == KeyFlag.RMenu && (eventFlags & KeyFlag.RMenu) != KeyFlag.RMenu)
        return false;
    if ((requestedFlags & KeyFlag.LMenu) == KeyFlag.LMenu && (eventFlags & KeyFlag.LMenu) != KeyFlag.LMenu)
        return false;
    if ((requestedFlags & KeyFlag.Control) == KeyFlag.Control && (eventFlags & KeyFlag.Control) != KeyFlag.Control)
        return false;
    if ((requestedFlags & KeyFlag.Shift) == KeyFlag.Shift && (eventFlags & KeyFlag.Shift) != KeyFlag.Shift)
        return false;
    if ((requestedFlags & KeyFlag.Alt) == KeyFlag.Alt && (eventFlags & KeyFlag.Alt) != KeyFlag.Alt)
        return false;
    if ((requestedFlags & KeyFlag.Menu) == KeyFlag.Menu && (eventFlags & KeyFlag.Menu) != KeyFlag.Menu)
        return false;
    return true;
}

/** 
    UI action

    For using in menus, toolbars, etc.

 */
class Action {
    /// numerical id
    protected int _id;
    /// label to show in UI
    protected UIString _label;
    /// icon resource id
    protected string _iconId;
    /// accelerator list
    protected Accelerator[] _accelerators;
    /// optional string parameter
    protected string _stringParam;
    /// optional long parameter
    protected long _longParam = long.min;
    /// optional object parameter
    protected Object _objectParam;

    protected ActionState _state = ACTION_STATE_ENABLED;

    protected ActionState _defaultState = ACTION_STATE_ENABLED;

    /// set default state to disabled, visible, not-checked
    Action disableByDefault() { _defaultState = ACTION_STATE_DISABLE; return this; }
    /// set default state to disabled, invisible, not-checked
    Action hideByDefault() { _defaultState = ACTION_STATE_INVISIBLE; return this; }
    /// default state for action if action state lookup failed
    @property const(ActionState) defaultState() const { return _defaultState; }
    /// default state for action if action state lookup failed
    @property Action defaultState(ActionState s) { _defaultState = s; return this; }
    /// action state (can be used to enable/disable, show/hide, check/uncheck control)
    @property const(ActionState) state() const { return _state; }
    /// update action state (for non-const action)
    @property Action state(const ActionState s) { _state = s; return this; }
    /// update action state (can be changed even for const objects)
    @property const(Action) state(const ActionState s) const {
        if (_state != s) {
            // hack
            Action nonConstThis = cast(Action) this;
            nonConstThis._state = s;
        }
        return this; 
    }
    @property const(Action) checked(bool newValue) const {
        state = ActionState(_state.enabled, _state.visible, newValue);
        return this;
    }

    /// returns optional string parameter
    @property string stringParam() const {
        return _stringParam;
    }
    /// sets optional string parameter
    @property Action stringParam(string v) {
        _stringParam = v;
        return this;
    }
    /// sets optional long parameter
    @property long longParam() const {
        return _longParam;
    }
    /// returns optional long parameter
    @property Action longParam(long v) {
        _longParam = v;
        return this;
    }
    /// returns additional custom (Object) parameter
    @property Object objectParam() {
        return _objectParam;
    }
    /// returns additional custom (Object) parameter
    @property const(Object) objectParam() const {
        return _objectParam;
    }
    /// sets additional custom (Object) parameter
    @property Action objectParam(Object v) {
        _objectParam = v;
        return this;
    }
    /// deep copy constructor
    this(immutable Action a) {
        _id = a._id;
        _label = a._label;
        _iconId = a._iconId;
        _state = a._state;
        _defaultState = a._defaultState;
        _accelerators = a._accelerators.dup;
        _stringParam = a._stringParam;
        _longParam = a._longParam;
        if (a._objectParam)
            _objectParam = cast(Object)a._objectParam;
    }
    /// deep copy
    @property Action clone() immutable { return new Action(this); }
    /// deep copy
    @property Action clone() const { return new Action(cast(immutable)this); }
    /// deep copy
    @property Action clone() { return new Action(cast(immutable)this); }
    /// create action only with ID
    this(int id) {
        _id = id;
    }
    /// create action with id, labelResourceId, and optional icon and key accelerator.
    this(int id, string labelResourceId, string iconResourceId = null, uint keyCode = 0, uint keyFlags = 0) {
        _id = id;
        _label = labelResourceId;
        _iconId = iconResourceId;
        if (keyCode) {
            version (OSX) {
                if (keyFlags & KeyFlag.Control) {
                    _accelerators ~= Accelerator(keyCode, (keyFlags & ~KeyFlag.Control) | KeyFlag.Command);
                }
            }
            _accelerators ~= Accelerator(keyCode, keyFlags);
        }
    }
    /// action with accelerator, w/o label
    this(int id, uint keyCode, uint keyFlags = 0) {
        _id = id;
        version (OSX) {
            if (keyFlags & KeyFlag.Control) {
                _accelerators ~= Accelerator(keyCode, (keyFlags & ~KeyFlag.Control) | KeyFlag.Command);
            }
        }
        _accelerators ~= Accelerator(keyCode, keyFlags);
    }
    /// action with label, icon, and accelerator
    this(int id, dstring label, string iconResourceId = null, uint keyCode = 0, uint keyFlags = 0) {
        _id = id;
        _label = label;
        _iconId = iconResourceId;
        if (keyCode) {
            version (OSX) {
                if (keyFlags & KeyFlag.Control) {
                    _accelerators ~= Accelerator(keyCode, (keyFlags & ~KeyFlag.Control) | KeyFlag.Command);
                }
            }
            _accelerators ~= Accelerator(keyCode, keyFlags);
        }
    }
    /// returs array of accelerators
    @property Accelerator[] accelerators() {
        // check for accelerators override in settings
        Accelerator[] res = findActionAccelerators(_id);
        if (res) {
            //Log.d("Found accelerators ", res);
            return res;
        }
        // return this action accelerators
        return _accelerators;
    }
    /// returs const array of accelerators
    @property const(Accelerator)[] accelerators() const {
        // check for accelerators override in settings
        Accelerator[] res = findActionAccelerators(_id);
        if (res) {
            //Log.d("Found accelerators ", res);
            return res;
        }
        return _accelerators;
    }
    /// returns text description for first accelerator of action; null if no accelerators
    @property dstring acceleratorText() {
        if (_accelerators.length < 1)
            return null;
        return _accelerators[0].label;
    }
    /// returns tooltip text for action
    @property dstring tooltipText() {
        dchar[] buf;
        // strip out & characters
        foreach(ch; label) {
            if (ch != '&')
                buf ~= ch;
        }
        dstring accel = acceleratorText;
        if (accel.length > 0) {
            buf ~= " ("d;
            buf ~= accel;
            buf ~= ")"d;
        }
        return cast(dstring)buf;
    }
    /// adds one more accelerator
    Action addAccelerator(uint keyCode, uint keyFlags = 0) {
        _accelerators ~= Accelerator(keyCode, keyFlags);
        return this;
    }
    /// adds one more accelerator only if platform is OSX
    Action addMacAccelerator(uint keyCode, uint keyFlags = 0) {
        version (OSX) {
            _accelerators ~= Accelerator(keyCode, keyFlags);
        }
        return this;
    }
    /// adds one more accelerator only if platform is not OSX
    Action addNonMacAccelerator(uint keyCode, uint keyFlags = 0) {
        version (OSX) {
        } else {
            _accelerators ~= Accelerator(keyCode, keyFlags);
        }
        return this;
    }
    /// returns true if accelerator matches provided key code and flags
    bool checkAccelerator(uint keyCode, uint keyFlags) const {
        foreach(a; _accelerators) {
            if (a.keyCode == keyCode && matchKeyFlags(keyFlags, a.keyFlags))
                return true;
        }
        return false;
    }
    /// returns action id
    @property int id() const {
        return _id;
    }
    /// sets action id
    @property Action id(int newId) {
        _id = newId;
        return this;
    }
    /// compares id of this action with another action id
    bool opEquals(int anotherActionId) const {
        return _id == anotherActionId;
    }
    /// compares id of this action with another action id
    bool opEquals(const Action action) const {
        return _id == action._id;
    }
    /// sets label string resource id
    @property Action label(string resourceId) {
        _label = resourceId;
        return this;
    }
    /// sets label unicode string
    @property Action label(dstring text) {
        _label = text;
        return this;
    }
    /// returns label unicode string (translates if resource id is set)
    @property dstring label() const {
        return _label.value;
    }
    /// access to label UIString
    @property ref const (UIString) labelValue() const {
        return _label;
    }
    /// returns icon resource id
    @property string iconId() const {
        return _iconId;
    }
    /// sets icon resource id
    @property Action iconId(string id) {
        _iconId = id;
        return this;
    }
    /// returns true if it's dummy action to specify separator
    @property bool isSeparator() const {
        return _id == SEPARATOR_ACTION_ID;
    }

    override string toString() const {
        return "Action(" ~ to!string(_id) ~ ")";
    }
}

/// use this ID for menu and toolbar separators
const int SEPARATOR_ACTION_ID = -1;
__gshared Action ACTION_SEPARATOR = new Action(SEPARATOR_ACTION_ID);


/// Map of Accelerator to Action
struct ActionMap {
    protected Action[Accelerator] _map;
    /// Add all actions from list
    void add(ActionList items) {
        foreach(a; items) {
            foreach(acc; a.accelerators)
                _map[acc] = a;
        }
    }
    /// Add array of actions
    void add(Action[] items) {
        foreach(a; items) {
            foreach(acc; a.accelerators)
                _map[acc] = a;
        }
    }
    /// Add array of actions
    void add(const Action[] items) {
        foreach(a; items) {
            foreach(acc; a.accelerators)
                _map[acc] = a.clone;
        }
    }
    /// Add action
    void add(Action a) {
        foreach(acc; a.accelerators)
            _map[acc] = a;
    }
    private static __gshared immutable uint[] flagMasks = [
        KeyFlag.LRControl | KeyFlag.LRAlt | KeyFlag.LRShift | KeyFlag.LRMenu,

        KeyFlag.LRControl | KeyFlag.LRAlt | KeyFlag.LRShift | KeyFlag.LRMenu,
        KeyFlag.LRControl | KeyFlag.Alt | KeyFlag.LRShift | KeyFlag.LRMenu,
        KeyFlag.LRControl | KeyFlag.LRAlt | KeyFlag.Shift | KeyFlag.LRMenu,
        KeyFlag.LRControl | KeyFlag.LRAlt | KeyFlag.LRShift | KeyFlag.Menu,

        KeyFlag.Control | KeyFlag.Alt | KeyFlag.LRShift | KeyFlag.LRMenu,
        KeyFlag.Control | KeyFlag.LRAlt | KeyFlag.Shift | KeyFlag.LRMenu,
        KeyFlag.Control | KeyFlag.LRAlt | KeyFlag.LRShift | KeyFlag.Menu,
        KeyFlag.LRControl | KeyFlag.Alt | KeyFlag.Shift | KeyFlag.LRMenu,
        KeyFlag.LRControl | KeyFlag.Alt | KeyFlag.LRShift | KeyFlag.Menu,
        KeyFlag.LRControl | KeyFlag.LRAlt | KeyFlag.Shift | KeyFlag.Menu,

        KeyFlag.Control | KeyFlag.Alt | KeyFlag.Shift | KeyFlag.LRMenu,
        KeyFlag.Control | KeyFlag.Alt | KeyFlag.LRShift | KeyFlag.Menu,
        KeyFlag.Control | KeyFlag.LRAlt | KeyFlag.Shift | KeyFlag.Menu,
        KeyFlag.LRControl | KeyFlag.Alt | KeyFlag.Shift | KeyFlag.Menu,

        KeyFlag.Control | KeyFlag.Alt | KeyFlag.Shift | KeyFlag.Menu
    ];
    /// Aind action by key, return null if not found
    Action findByKey(uint keyCode, uint flags) {
        Accelerator acc;
        acc.keyCode = keyCode;
        foreach(mask; flagMasks) {
            acc.keyFlags = flags & mask;
            if (auto p = acc in _map) {
                if (p.checkAccelerator(keyCode, flags))
                    return *p;
            }
        }
        return null;
    }
}

/// List of Actions, for looking up Action by key
struct ActionList {
    private Collection!Action _actions;
    alias _actions this;

    /// Add several actions from array
    void add(Action[] items) {
        foreach(a; items)
            _actions ~= a;
    }

    /// Add all items from another list
    void add(ref ActionList items) {
        foreach(a; items)
            _actions ~= a;
    }

    /// Find action by key, return null if not found
    Action findByKey(uint keyCode, uint flags) {
        foreach(a; _actions)
            if (a.checkAccelerator(keyCode, flags))
                return a;
        return null;
    }
}

/// Mouse action codes for MouseEvent
enum MouseAction : ubyte {
    /// button down handling is cancelled
    Cancel,   
    /// button is down
    ButtonDown, 
    /// button is up
    ButtonUp, 
    /// mouse pointer is moving
    Move,     
    /// pointer is back inside widget while button is down after FocusOut
    FocusIn,  
    /// pointer moved outside of widget while button was down (if handler returns true, Move events will be sent even while pointer is outside widget)
    FocusOut, 
    /// scroll wheel movement
    Wheel,    
    //Hover,    // pointer entered widget which while button was not down (return true to track Hover state)
    /// pointer left widget which has before processed Move message, while button was not down
    Leave     
}

/// Mouse flag bits (mouse buttons and keyboard modifiers) for MouseEvent
enum MouseFlag : ushort {
    // mouse buttons
    /// Left mouse button is down
    LButton = 0x0001,
    /// Middle mouse button is down
    MButton = 0x0010,
    /// Right mouse button is down
    RButton = 0x0002,
    /// X1 mouse button is down
    XButton1= 0x0020,
    /// X2 mouse button is down
    XButton2= 0x0040,

    // keyboard modifiers
    /// Ctrl key is down
    Control = 0x0008,
    /// Shift key is down
    Shift   = 0x0004,
    /// Alt key is down
    Alt     = 0x0080,

    /// Mask for mouse button flags
    ButtonsMask = LButton | MButton | RButton | XButton1 | XButton2,
    /// Mask for keyboard flags
    KeyMask = Control|Shift|Alt,
}

/// Mouse button codes for MouseEvent
enum MouseButton : ubyte {
    /// no button
    None,
    /// left mouse button
    Left = MouseFlag.LButton,
    /// right mouse button
    Right = MouseFlag.RButton,
    /// right mouse button
    Middle = MouseFlag.MButton,
    /// additional mouse button 1
    XButton1 = MouseFlag.XButton1, // additional button 1
    /// additional mouse button 2
    XButton2 = MouseFlag.XButton2, // additional button 2
}

/// converts MouseButton to MouseFlag
ushort mouseButtonToFlag(MouseButton btn) {
    switch(btn) with (MouseButton) {
        case Left: return MouseFlag.LButton;
        case Right: return MouseFlag.RButton;
        case Middle: return MouseFlag.MButton;
        case XButton1: return MouseFlag.XButton1;
        case XButton2: return MouseFlag.XButton2;
        default: return 0;
    }
}

/// double click max interval, milliseconds; may be changed by platform
__gshared long DOUBLE_CLICK_THRESHOLD_MS = 400;

/// Mouse button state details for MouseEvent
struct ButtonDetails {
    /// Clock.currStdTime() for down event of this button (0 if button is up) set after double click to time when first click occured.
    protected long  _prevDownTs;
    /// Clock.currStdTime() for down event of this button (0 if button is up).
    protected long  _downTs;
    /// Clock.currStdTime() for up event of this button (0 if button is still down).
    protected long  _upTs;
    /// x coordinates of down event
    protected short _downX;
    /// y coordinates of down event
    protected short _downY;
    /// mouse button flags when down event occured
    protected ushort _downFlags;
    /// true if button is made down shortly after up - valid if button is down
    protected bool _doubleClick;
    /// true if button is made down twice shortly after up - valid if button is down
    protected bool _tripleClick;

    /// Returns true if button is made down shortly after up
    @property bool doubleClick() {
        return _doubleClick;
    }

    /// Returns true if button is made down twice shortly after up
    @property bool tripleClick() {
        return _tripleClick;
    }



    void reset() {
        _downTs = _upTs = 0;
        _downFlags = 0;
        _downX = _downY = 0;
    }

    /// update for button down
    void down(short x, short y, ushort flags) {
        static import std.datetime;
        //Log.d("Button down ", x, ",", y, " _downTs=", _downTs, " _upTs=", _upTs);
        long oldDownTs = _downTs;
        _downX = x;
        _downY = y;
        _downFlags = flags;
        _upTs = 0;
        _downTs = std.datetime.Clock.currStdTime;
        long downIntervalMs = (_downTs - oldDownTs) / 10000;
        long prevDownIntervalMs = (_downTs - _prevDownTs) / 10000;
        //Log.d("Button down ", x, ",", y, " _downTs=", _downTs, " _upTs=", _upTs, " downInterval=", downIntervalMs);
        _tripleClick = (prevDownIntervalMs && prevDownIntervalMs < DOUBLE_CLICK_THRESHOLD_MS * 2);
        _doubleClick = !_tripleClick && (oldDownTs && downIntervalMs < DOUBLE_CLICK_THRESHOLD_MS);
        _prevDownTs = _doubleClick ? oldDownTs : 0;
    }
    /// update for button up
    void up(short x, short y, ushort flags) {
        static import std.datetime;
        //Log.d("Button up ", x, ",", y, " _downTs=", _downTs, " _upTs=", _upTs);
        _doubleClick = false;
        _tripleClick = false;
        _upTs = std.datetime.Clock.currStdTime;
    }
    /// returns true if button is currently pressed
    @property bool isDown() { return _downTs != 0 && _upTs == 0; }
    /// returns button down state duration in hnsecs (1/10000 of second).
    @property int downDuration() {
        static import std.datetime;
        if (_downTs == 0)
            return 0;
        if (_downTs != 0 && _upTs != 0)
            return cast(int)(_upTs - _downTs);
        long ts = std.datetime.Clock.currStdTime;
        return cast(int)(ts - _downTs);
    }
    /// X coordinate of point where button was pressed Down last time
    @property short downX() { return _downX; }
    /// Y coordinate of point where button was pressed Down last time
    @property short downY() { return _downY; }
    /// bit set of mouse flags saved on button down
    @property ushort downFlags() { return _downFlags; }
}

/** 
    Mouse event
 */
class MouseEvent {
    /// timestamp of event
    protected long _eventTimestamp;
    /// mouse action code
    protected MouseAction _action;
    /// mouse button code for ButtonUp/ButtonDown
    protected MouseButton _button;
    /// x coordinate of pointer
    protected short _x;
    /// y coordinate of pointer
    protected short _y;
    /// flags bit set - usually from MouseFlag enum
    protected ushort _flags;
    /// wheel delta
    protected short _wheelDelta;
    /// widget which currently tracks mouse events
    protected Widget _trackingWidget;
    /// left button state details
    protected ButtonDetails _lbutton;
    /// middle button state details
    protected ButtonDetails _mbutton;
    /// right button state details
    protected ButtonDetails _rbutton;
    /// when true, no tracking of mouse on ButtonDown is necessary
    protected bool _doNotTrackButtonDown;
    /// left button state details
    @property ref ButtonDetails lbutton() { return _lbutton; }
    /// right button state details
    @property ref ButtonDetails rbutton() { return _rbutton; }
    /// middle button state details
    @property ref ButtonDetails mbutton() { return _mbutton; }
    /// button state details for event's button
    @property ref ButtonDetails buttonDetails() { 
        if (_button == MouseButton.Right)
            return _rbutton; 
        if (_button == MouseButton.Middle)
            return _mbutton; 
        return _lbutton;
    }
    /// button which caused ButtonUp or ButtonDown action
    @property MouseButton button() { return _button; }
    /// action
    @property MouseAction action() { return _action; }
    /// override action code (for usage from platform code)
    void changeAction(MouseAction a) { _action = a; }
    /// returns flags (buttons and keys state)
    @property ushort flags() { return _flags; }
    /// returns mouse button flags only
    @property ushort buttonFlags() { return _flags & MouseFlag.ButtonsMask; }
    /// returns keyboard modifier flags only
    @property ushort keyFlags() { return _flags & MouseFlag.KeyMask; }
    /// returns delta for Wheel event
    @property short wheelDelta() { return _wheelDelta; }
    /// x coordinate of mouse pointer (relative to window client area)
    @property short x() { return _x; }
    /// y coordinate of mouse pointer (relative to window client area)
    @property short y() { return _y; }

    /// returns point for mouse cursor position
    @property Point pos() { return Point(_x, _y); }

    /// returns true if no modifier flags are set
    @property bool noModifiers() { return (_flags & (MouseFlag.Control | MouseFlag.Alt | MouseFlag.Shift)) == 0; }
    /// returns true if any modifier flag is set
    @property bool hasModifiers() { return !noModifiers; }


    /// Returns true for ButtonDown event when button is pressed second time in short interval after pressing first time
    @property bool doubleClick() {
        if (_action != MouseAction.ButtonDown)
            return false;
        return buttonDetails.doubleClick;
    }

    /// Returns true for ButtonDown event when button is pressed third time in short interval after pressing first time
    @property bool tripleClick() {
        if (_action != MouseAction.ButtonDown)
            return false;
        return buttonDetails.tripleClick;
    }

    /// get event tracking widget to override
    @property Widget trackingWidget() { return _trackingWidget; }
    /// returns mouse button tracking flag
    @property bool doNotTrackButtonDown() { return _doNotTrackButtonDown; }
    /// sets mouse button tracking flag
    @property void doNotTrackButtonDown(bool flg) { _doNotTrackButtonDown = flg; }
    /// override mouse tracking widget
    void track(Widget w) {
        _trackingWidget = w;
    }
    /// copy constructor
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
    /// construct mouse event from data
    this (MouseAction a, MouseButton b, ushort f, short x, short y, short wheelDelta = 0) {
        static import std.datetime;
        _eventTimestamp = std.datetime.Clock.currStdTime;
        _action = a;
        _button = b;
        _flags = f;
        _x = x;
        _y = y;
        _wheelDelta = wheelDelta;
    }

	override @property string toString() {
		import std.conv;
		return "MouseEvent(" ~ to!string(_action) ~ ", " ~ to!string(cast(MouseButton)_button) ~ ", " ~ "%04x".format(_flags) ~ ", (" ~ to!string(_x) ~ "," ~ to!string(y) ~ "))";
	}

}

/// Keyboard actions for KeyEvent
enum KeyAction : uint {
    /// key is pressed
    KeyDown,
    /// key is released
    KeyUp,
    /// text is entered
    Text,
    /// repeated key down
    Repeat,
}

/// Keyboard flags for KeyEvent
enum KeyFlag : uint {
    /// Ctrl key is down
    Control = 0x0008,
    /// Shift key is down
    Shift   = 0x0004,
    /// Alt key is down
    Alt     = 0x0080,
    Option  = Alt,
    /// Menu key
    Menu    = 0x0040,
    Command = Menu,
    // Flags not counting left or right difference
    MainFlags = 0xFF,
    /// Right Ctrl key is down
    RControl = 0x0108,
    /// Right Shift key is down
    RShift   = 0x0104,
    /// Right Alt key is down
    RAlt     = 0x0180,
    /// Left Ctrl key is down
    LControl = 0x0208,
    /// Left Shift key is down
    LShift   = 0x0204,
    /// Left Alt key is down
    LAlt     = 0x0280,
    /// Left Menu/Win key is down
    LMenu    = 0x0240,
    /// Right Menu/Win key is down
    RMenu    = 0x0140,

    LRControl = LControl | RControl, // both left and right
    LRAlt = LAlt | RAlt, // both left and right
    LRShift = LShift | RShift, // both left and right
    LRMenu = LMenu | RMenu, // both left and right
}

/// Key code constants for KeyEvent
enum KeyCode : uint {
    NONE = 0,
    /// backspace
    BACK = 8,
    /// tab
    TAB = 9,
    /// return / enter key
    RETURN = 0x0D,
    /// shift
    SHIFT = 0x10,
    /// ctrl
    CONTROL = 0x11,
    /// alt
    ALT = 0x12, // VK_MENU
    /// pause
    PAUSE = 0x13,
    /// caps lock
    CAPS = 0x14, // VK_CAPITAL, caps lock
    /// esc
    ESCAPE = 0x1B, // esc
    /// space
    SPACE = 0x20,
    /// page up
    PAGEUP = 0x21, // VK_PRIOR
    /// page down
    PAGEDOWN = 0x22, // VK_NEXT
    /// end
    END = 0x23, // VK_END
    /// home
    HOME = 0x24, // VK_HOME
    /// left arrow
    LEFT = 0x25,
    /// up arrow
    UP = 0x26,
    /// right arrow
    RIGHT = 0x27,
    /// down arrow
    DOWN = 0x28,
    /// ins
    INS = 0x2D,
    /// delete
    DEL = 0x2E,
    /// 0
    KEY_0 = 0x30,
    /// 1
    KEY_1 = 0x31,
    /// 2
    KEY_2 = 0x32,
    /// 3
    KEY_3 = 0x33,
    /// 4
    KEY_4 = 0x34,
    /// 5
    KEY_5 = 0x35,
    /// 6
    KEY_6 = 0x36,
    /// 7
    KEY_7 = 0x37,
    /// 8
    KEY_8 = 0x38,
    /// 9
    KEY_9 = 0x39,
    /// A
    KEY_A = 0x41,
    /// B
    KEY_B = 0x42,
    /// C
    KEY_C = 0x43,
    /// D
    KEY_D = 0x44,
    /// E
    KEY_E = 0x45,
    /// F
    KEY_F = 0x46,
    /// G
    KEY_G = 0x47,
    /// H
    KEY_H = 0x48,
    /// I
    KEY_I = 0x49,
    /// J
    KEY_J = 0x4a,
    /// K
    KEY_K = 0x4b,
    /// L
    KEY_L = 0x4c,
    /// M
    KEY_M = 0x4d,
    /// N
    KEY_N = 0x4e,
    /// O
    KEY_O = 0x4f,
    /// P
    KEY_P = 0x50,
    /// Q
    KEY_Q = 0x51,
    /// R
    KEY_R = 0x52,
    /// S
    KEY_S = 0x53,
    /// T
    KEY_T = 0x54,
    /// U
    KEY_U = 0x55,
    /// V
    KEY_V = 0x56,
    /// W
    KEY_W = 0x57,
    /// X
    KEY_X = 0x58,
    /// Y
    KEY_Y = 0x59,
    /// Z
    KEY_Z = 0x5a,
    /// [
    KEY_BRACKETOPEN = 0xDB,
    /// ]
    KEY_BRACKETCLOSE = 0xDD,
    /// key /
    KEY_DIVIDE = 0x6F,
    /// key +
    KEY_ADD = 0x6B,
    /// key *
    KEY_MULTIPLY = 0x6A,
    /// key ,
    KEY_COMMA = 0xBC,
    /// key .
    KEY_PERIOD = 0xBE,
    /// key -
    KEY_SUBTRACT = 0x6D,
    /// left win key
    LWIN = 0x5b,
    /// right win key
    RWIN = 0x5c,
    /// numpad 0
    NUM_0 = 0x60,
    /// numpad 1
    NUM_1 = 0x61,
    /// numpad 2
    NUM_2 = 0x62,
    /// numpad 3
    NUM_3 = 0x63,
    /// numpad 4
    NUM_4 = 0x64,
    /// numpad 5
    NUM_5 = 0x65,
    /// numpad 6
    NUM_6 = 0x66,
    /// numpad 7
    NUM_7 = 0x67,
    /// numpad 8
    NUM_8 = 0x68,
    /// numpad 9
    NUM_9 = 0x69,
    /// numpad *
    MUL = 0x6A,
    /// numpad +
    ADD = 0x6B,
    /// numpad /
    DIV = 0x6F,
    /// numpad -
    SUB = 0x6D,
    /// numpad .
    DECIMAL = 0x6E,
    /// F1
    F1 = 0x70,
    /// F2
    F2 = 0x71,
    /// F3
    F3 = 0x72,
    /// F4
    F4 = 0x73,
    /// F5
    F5 = 0x74,
    /// F6
    F6 = 0x75,
    /// F7
    F7 = 0x76,
    /// F8
    F8 = 0x77,
    /// F9
    F9 = 0x78,
    /// F10
    F10 = 0x79,
    /// F11
    F11 = 0x7a,
    /// F12
    F12 = 0x7b,
    /// F13
    F13 = 0x7c,
    /// F14
    F14 = 0x7d,
    /// F15
    F15 = 0x7e,
    /// F16
    F16 = 0x7f,
    /// F17
    F17 = 0x80,
    /// F18
    F18 = 0x81,
    /// F19
    F19 = 0x82,
    /// F20
    F20 = 0x83,
    /// F21
    F21 = 0x84,
    /// F22
    F22 = 0x85,
    /// F23
    F23 = 0x86,
    /// F24
    F24 = 0x87,
    /// num lock
    NUMLOCK = 0x90,
    /// scroll lock
    SCROLL = 0x91, // scroll lock
    /// left shift
    LSHIFT = 0xA0,
    /// right shift
    RSHIFT = 0xA1,
    /// left ctrl
    LCONTROL = 0xA2,
    /// right ctrl
    RCONTROL = 0xA3,
    /// left alt
    LALT = 0xA4,
    /// right alt
    RALT = 0xA5,
    //LMENU = 0xA4, //VK_LMENU
    //RMENU = 0xA5,
    /// ;
    SEMICOLON = 0x201, 
    /// ~
    TILDE = 0x202,
    /// '
    QUOTE = 0x203,
    /// /
    SLASH = 0x204,
    /// \
    BACKSLASH = 0x205,
    /// =
    EQUAL = 0x206,
}

/// Keyboard event
class KeyEvent {
    /// action
    protected KeyAction _action;
    /// key code, usually from KeyCode enum
    protected uint _keyCode;
    /// key flags bit set, usually combined from KeyFlag enum
    protected uint _flags;
    /// entered text
    protected dstring _text;
    /// key action (KeyDown, KeyUp, Text, Repeat)
    @property KeyAction action() { return _action; }
    /// key code (usually from KeyCode enum)
    @property uint keyCode() { return _keyCode; }
    /// flags (shift, ctrl, alt...) - KeyFlag enum
    @property uint flags() { return _flags; }
    /// entered text, for Text action
    @property dstring text() { return _text; }

    /// returns true if no modifier flags are set
    @property bool noModifiers() { return (_flags & (KeyFlag.Control | KeyFlag.Alt | KeyFlag.Menu | KeyFlag.Shift)) == 0; }
    /// returns true if any modifier flag is set
    @property bool hasModifiers() { return !noModifiers; }

    /// create key event
    this(KeyAction action, uint keyCode, uint flags, dstring text = null) {
        _action = action;
        _keyCode = keyCode;
        _flags = flags;
        _text = text;
    }
	override @property string toString() {
		import std.conv;
		return "KeyEvent(" ~ to!string(_action) ~ ", " ~ to!string(cast(KeyCode)_keyCode) ~ ", " ~ "%04x".format(_flags) ~ ", \"" ~ toUTF8(_text) ~ "\")";
	}
}

/// Scroll bar / slider action codes for ScrollEvent.
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

/// Slider/scrollbar event
class ScrollEvent {
    private ScrollAction _action;
    private int _minValue;
    private int _maxValue;
    private int _pageSize;
    private int _position;
    private bool _positionChanged;
    /// action
    @property ScrollAction action() { return _action; }
    /// min value
    @property int minValue() { return _minValue; }
    /// max value
    @property int maxValue() { return _maxValue; }
    /// visible part size
    @property int pageSize() { return _pageSize; }
    /// current position
    @property int position() { return _position; }
    /// returns true if position has been changed using position property setter
    @property bool positionChanged() { return _positionChanged; }
    /// change position in event handler to update slider position
    @property void position(int newPosition) { _position = newPosition; _positionChanged = true; }
    /// create scroll event
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
        switch (_action) with(ScrollAction)
        {
            case LineUp:
                delta = _pageSize / 20;
                if (delta < 1)
                    delta = 1;
                delta = -delta;
                break;
            case LineDown:
                delta = _pageSize / 20;
                if (delta < 1)
                    delta = 1;
                break;
            case PageUp:
                delta = _pageSize * 3 / 4;
                if (delta < 1)
                    delta = 1;
                delta = -delta;
                break;
            case PageDown:
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

/** 
Converts key name to KeyCode enum value
For unknown key code, returns 0
*/
uint parseKeyName(string name) {
    switch (name) {
        case "A": case "a": return KeyCode.KEY_A;
        case "B": case "b": return KeyCode.KEY_B;
        case "C": case "c": return KeyCode.KEY_C;
        case "D": case "d": return KeyCode.KEY_D;
        case "E": case "e": return KeyCode.KEY_E;
        case "F": case "f": return KeyCode.KEY_F;
        case "G": case "g": return KeyCode.KEY_G;
        case "H": case "h": return KeyCode.KEY_H;
        case "I": case "i": return KeyCode.KEY_I;
        case "J": case "j": return KeyCode.KEY_J;
        case "K": case "k": return KeyCode.KEY_K;
        case "L": case "l": return KeyCode.KEY_L;
        case "M": case "m": return KeyCode.KEY_M;
        case "N": case "n": return KeyCode.KEY_N;
        case "O": case "o": return KeyCode.KEY_O;
        case "P": case "p": return KeyCode.KEY_P;
        case "Q": case "q": return KeyCode.KEY_Q;
        case "R": case "r": return KeyCode.KEY_R;
        case "S": case "s": return KeyCode.KEY_S;
        case "T": case "t": return KeyCode.KEY_T;
        case "U": case "u": return KeyCode.KEY_U;
        case "V": case "v": return KeyCode.KEY_V;
        case "W": case "w": return KeyCode.KEY_W;
        case "X": case "x": return KeyCode.KEY_X;
        case "Y": case "y": return KeyCode.KEY_Y;
        case "Z": case "z": return KeyCode.KEY_Z;
        case "F1": return KeyCode.F1;
        case "F2": return KeyCode.F2;
        case "F3": return KeyCode.F3;
        case "F4": return KeyCode.F4;
        case "F5": return KeyCode.F5;
        case "F6": return KeyCode.F6;
        case "F7": return KeyCode.F7;
        case "F8": return KeyCode.F8;
        case "F9": return KeyCode.F9;
        case "F10": return KeyCode.F10;
        case "F11": return KeyCode.F11;
        case "F12": return KeyCode.F12;
        case "F13": return KeyCode.F13;
        case "F14": return KeyCode.F14;
        case "F15": return KeyCode.F15;
        case "F16": return KeyCode.F16;
        case "F17": return KeyCode.F17;
        case "F18": return KeyCode.F18;
        case "F19": return KeyCode.F19;
        case "F20": return KeyCode.F20;
        case "F21": return KeyCode.F21;
        case "F22": return KeyCode.F22;
        case "F23": return KeyCode.F23;
        case "F24": return KeyCode.F24;
        case "/": return KeyCode.KEY_DIVIDE;
        case "*": return KeyCode.KEY_MULTIPLY;
        case "Tab": return KeyCode.TAB;
        case "PageUp": return KeyCode.PAGEUP;
        case "PageDown": return KeyCode.PAGEDOWN;
        case "Home": return KeyCode.HOME;
        case "End": return KeyCode.END;
        case "Left": return KeyCode.LEFT;
        case "Right": return KeyCode.RIGHT;
        case "Up": return KeyCode.UP;
        case "Down": return KeyCode.DOWN;
        case "Ins": return KeyCode.INS;
        case "Del": return KeyCode.DEL;
        case "[": return KeyCode.KEY_BRACKETOPEN;
        case "]": return KeyCode.KEY_BRACKETCLOSE;
        case ",": return KeyCode.KEY_COMMA;
        case ".": return KeyCode.KEY_PERIOD;
        case "Backspace": return KeyCode.BACK;
        case "Enter": return KeyCode.RETURN;
        case "Space": return KeyCode.SPACE;
        default:
            return 0;
    }
}

/** 
    Converts KeyCode enum value to human readable key name 

    For unknown key code, prints its hex value.
*/
string keyName(uint keyCode) {
    switch (keyCode) {
        case KeyCode.KEY_A:
            return "A";
        case KeyCode.KEY_B:
            return "B";
        case KeyCode.KEY_C:
            return "C";
        case KeyCode.KEY_D:
            return "D";
        case KeyCode.KEY_E:
            return "E";
        case KeyCode.KEY_F:
            return "F";
        case KeyCode.KEY_G:
            return "G";
        case KeyCode.KEY_H:
            return "H";
        case KeyCode.KEY_I:
            return "I";
        case KeyCode.KEY_J:
            return "J";
        case KeyCode.KEY_K:
            return "K";
        case KeyCode.KEY_L:
            return "L";
        case KeyCode.KEY_M:
            return "M";
        case KeyCode.KEY_N:
            return "N";
        case KeyCode.KEY_O:
            return "O";
        case KeyCode.KEY_P:
            return "P";
        case KeyCode.KEY_Q:
            return "Q";
        case KeyCode.KEY_R:
            return "R";
        case KeyCode.KEY_S:
            return "S";
        case KeyCode.KEY_T:
            return "T";
        case KeyCode.KEY_U:
            return "U";
        case KeyCode.KEY_V:
            return "V";
        case KeyCode.KEY_W:
            return "W";
        case KeyCode.KEY_X:
            return "X";
        case KeyCode.KEY_Y:
            return "Y";
        case KeyCode.KEY_Z:
            return "Z";
        case KeyCode.KEY_0:
            return "0";
        case KeyCode.KEY_1:
            return "1";
        case KeyCode.KEY_2:
            return "2";
        case KeyCode.KEY_3:
            return "3";
        case KeyCode.KEY_4:
            return "4";
        case KeyCode.KEY_5:
            return "5";
        case KeyCode.KEY_6:
            return "6";
        case KeyCode.KEY_7:
            return "7";
        case KeyCode.KEY_8:
            return "8";
        case KeyCode.KEY_9:
            return "9";
        case KeyCode.KEY_DIVIDE:
            return "/";
        case KeyCode.KEY_MULTIPLY:
            return "*";
        case KeyCode.TAB:
            return "Tab";
        case KeyCode.F1:
            return "F1";
        case KeyCode.F2:
            return "F2";
        case KeyCode.F3:
            return "F3";
        case KeyCode.F4:
            return "F4";
        case KeyCode.F5:
            return "F5";
        case KeyCode.F6:
            return "F6";
        case KeyCode.F7:
            return "F7";
        case KeyCode.F8:
            return "F8";
        case KeyCode.F9:
            return "F9";
        case KeyCode.F10:
            return "F10";
        case KeyCode.F11:
            return "F11";
        case KeyCode.F12:
            return "F12";
        case KeyCode.F13:
            return "F13";
        case KeyCode.F14:
            return "F14";
        case KeyCode.F15:
            return "F15";
        case KeyCode.F16:
            return "F16";
        case KeyCode.F17:
            return "F17";
        case KeyCode.F18:
            return "F18";
        case KeyCode.F19:
            return "F19";
        case KeyCode.F20:
            return "F20";
        case KeyCode.F21:
            return "F21";
        case KeyCode.F22:
            return "F22";
        case KeyCode.F23:
            return "F23";
        case KeyCode.F24:
            return "F24";
        case KeyCode.PAGEUP:
            return "PageUp";
        case KeyCode.PAGEDOWN:
            return "PageDown";
        case KeyCode.HOME:
            return "Home";
        case KeyCode.END:
            return "End";
        case KeyCode.LEFT:
            return "Left";
        case KeyCode.RIGHT:
            return "Right";
        case KeyCode.UP:
            return "Up";
        case KeyCode.DOWN:
            return "Down";
        case KeyCode.INS:
            return "Ins";
        case KeyCode.DEL:
            return "Del";
        case KeyCode.KEY_BRACKETOPEN:
            return "[";
        case KeyCode.KEY_BRACKETCLOSE:
            return "]";
        case KeyCode.BACK:
            return "Backspace";
        case KeyCode.SPACE:
            return "Space";
        case KeyCode.RETURN:
            return "Enter";
        default:
            return format("0x%08x", keyCode);
    }
}

/// base class for custom events
class CustomEvent {
    protected int _id;
    protected uint _uniqueId;

    protected static __gshared uint _uniqueIdGenerator;

    protected Widget _destinationWidget;
    // event id
    @property int id() { return _id; }
    @property uint uniqueId() { return _uniqueId; }
    @property Widget destinationWidget() { return _destinationWidget; }

    protected Object _objectParam;
    @property Object objectParam() {
        return _objectParam;
    }
    @property CustomEvent objectParam(Object value) {
        _objectParam = value;
        return this;
    }

    protected int _intParam;
    @property int intParam() {
        return _intParam;
    }
    @property CustomEvent intParam(int value) {
        _intParam = value;
        return this;
    }

    this(int ID) {
        _id = ID;
        _uniqueId = ++_uniqueIdGenerator;
    }
}

immutable int CUSTOM_RUNNABLE = 1;

/// operation to execute (usually sent from background threads to run some code in UI thread)
class RunnableEvent : CustomEvent {
    protected void delegate() _action;
    this(int ID, Widget destinationWidget, void delegate() action) {
        super(ID);
        _destinationWidget = destinationWidget;
        _action = action;
    }
    void run() {
        _action();
    }
}

/**
Queue destroy event.

This event allows delayed widget destruction and is used internally by 
$(LINK2 $(DDOX_ROOT_DIR)dlangui/platforms/common/platform/Window.queueWidgetDestroy.html, Window.queueWidgetDestroy()).
*/
class QueueDestroyEvent : RunnableEvent {
    private Widget _widgetToDestroy;
    this (Widget widgetToDestroy)
    {
        _widgetToDestroy = widgetToDestroy;
        super(1,null, delegate void () {
            if (_widgetToDestroy.parent) 
                _widgetToDestroy.parent.removeChild(_widgetToDestroy);
            destroy(_widgetToDestroy);
        });
    }
}

interface CustomEventTarget {
    /// post event to handle in UI thread (this method can be used from background thread)
    void postEvent(CustomEvent event);

    /// post task to execute in UI thread (this method can be used from background thread)
    void executeInUiThread(void delegate() runnable);
}

private static __gshared string[int] actionIdToNameMap;
private static __gshared int[string] actionNameToIdMap;
private static __gshared Accelerator[][int] actionAcceleratorsMap;

/// clear global action accelerators map
void clearActionAcceleratorsMap() {
    destroy(actionAcceleratorsMap);
}
/// overrides accelerators for action by id
void setActionAccelerators(int actionId, Accelerator[] accelerators) {
    actionAcceleratorsMap[actionId] = accelerators;
}
/// lookup accelerators override for action by id
Accelerator[] findActionAccelerators(int actionId) {
    if (auto found = actionId in actionAcceleratorsMap)
        return *found;
    return null;
}
/// lookup accelerators override for action by name (e.g. "EditorActions.ToggleLineComment")
Accelerator[] findActionAccelerators(string actionName) {
    int actionId = actionNameToId(actionName);
    if (actionId == 0)
        return null;
    if (auto found = actionAcceleratorsMap[actionId])
        return found;
    return null;
}

/// converts id to name for actions registered by registerActionEnum, returns null if not found
string actionIdToName(int id) {
    if (auto name = id in actionIdToNameMap) {
        return *name;
    }
    return null;
}

/// converts action name id for for actions registered by registerActionEnum, returns 0 if not found
int actionNameToId(string name) {
    if (auto id = name in actionNameToIdMap) {
        return *id;
    }
    return 0;
}

private string[] enumMemberNames(T)() if (is(T == enum)) {
    import std.traits;
    string[] res;
    foreach(item; __traits(allMembers, T)) {
        res ~= T.stringof ~ "." ~ item;
    }
    return res;
}

private int[] enumMemberValues(T)() if (is(T == enum)) {
    import std.traits;
    int[] res;
    foreach(item; EnumMembers!T) {
        res ~= cast(int)item;
    }
    return res;
}

/// register enum items as action names and ids for lookup by actionIdToName and actionNameToId functions (names will be generated as "EnumName.EnumItemName")
void registerActionEnum(T)() if (is(T == enum)) {
    immutable int[] memberValues = enumMemberValues!T;
    immutable string[] memberNames = enumMemberNames!T;
    //pragma(msg, enumMemberValues!T);
    //pragma(msg, enumMemberNames!T);
    foreach(i; 0 .. memberValues.length) {
        actionIdToNameMap[memberValues[i]] = memberNames[i];
        actionNameToIdMap[memberNames[i]] = memberValues[i];
    }
}
