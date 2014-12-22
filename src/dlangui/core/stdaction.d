// Written in the D programming language.

/**
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

const Action ACTION_OK;
const Action ACTION_CANCEL;
const Action ACTION_YES;
const Action ACTION_NO;
const Action ACTION_CLOSE;
const Action ACTION_ABORT;
const Action ACTION_RETRY;
const Action ACTION_IGNORE;
const Action ACTION_OPEN;
const Action ACTION_SAVE;

static this()
{
  ACTION_OK = new Action(StandardAction.Ok, "ACTION_OK"c);
  ACTION_CANCEL = cast(immutable(Action)) new Action(StandardAction.Cancel, "ACTION_CANCEL"c);
  ACTION_YES = cast(immutable(Action)) new Action(StandardAction.Yes, "ACTION_YES"c);
  ACTION_NO = cast(immutable(Action)) new Action(StandardAction.No, "ACTION_NO"c);
  ACTION_CLOSE = cast(immutable(Action)) new Action(StandardAction.Close, "ACTION_CLOSE"c);
  ACTION_ABORT = cast(immutable(Action)) new Action(StandardAction.Abort, "ACTION_ABORT"c);
  ACTION_RETRY = cast(immutable(Action)) new Action(StandardAction.Retry, "ACTION_RETRY"c);
  ACTION_IGNORE = cast(immutable(Action)) new Action(StandardAction.Ignore, "ACTION_IGNORE"c);
  ACTION_OPEN = cast(immutable(Action)) new Action(StandardAction.Open, "ACTION_OPEN"c);
  ACTION_SAVE = cast(immutable(Action)) new Action(StandardAction.Save, "ACTION_SAVE"c);
}
