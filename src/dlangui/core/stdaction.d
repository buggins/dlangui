// Written in the D programming language.

/**
DLANGUI library.

Definition of standard actions commonly used in dialogs and controls.

Synopsis:

----
import dlangui.core.stdaction;

----

Copyright: Vadim Lopatin, 2014
License:   Boost License 1.0
Authors:   Vadim Lopatin, coolreader.org@gmail.com
*/
module dlangui.core.stdaction;

public import dlangui.core.events;

/// standard (commonly used) action codes
enum StandardAction : int {
    Ok = 1,
    Cancel,
    Yes,
    No,
    Close, 
    Abort,
    Retry,
    Ignore,
    Open,
    Save,
}

__gshared const Action ACTION_OK = new Action(StandardAction.Ok, "ACTION_OK"c);
__gshared const Action ACTION_CANCEL = new Action(StandardAction.Cancel, "ACTION_CANCEL"c);
__gshared const Action ACTION_YES = new Action(StandardAction.Yes, "ACTION_YES"c);
__gshared const Action ACTION_NO = new Action(StandardAction.No, "ACTION_NO"c);
__gshared const Action ACTION_CLOSE = new Action(StandardAction.Close, "ACTION_CLOSE"c);
__gshared const Action ACTION_ABORT = new Action(StandardAction.Abort, "ACTION_ABORT"c);
__gshared const Action ACTION_RETRY = new Action(StandardAction.Retry, "ACTION_RETRY"c);
__gshared const Action ACTION_IGNORE = new Action(StandardAction.Ignore, "ACTION_IGNORE"c);
__gshared const Action ACTION_OPEN = new Action(StandardAction.Open, "ACTION_OPEN"c);
__gshared const Action ACTION_SAVE = new Action(StandardAction.Save, "ACTION_SAVE"c);


