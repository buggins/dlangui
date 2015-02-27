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
    SaveAll,
    DiscardChanges,
    DiscardAll,
    OpenUrl,
    Apply,
}

const Action ACTION_OK = new Action(StandardAction.Ok, "ACTION_OK"c, "dialog-ok");
const Action ACTION_CANCEL = new Action(StandardAction.Cancel, "ACTION_CANCEL"c, "dialog-cancel");
const Action ACTION_APPLY = new Action(StandardAction.Apply, "ACTION_APPLY"c, null);
const Action ACTION_YES = new Action(StandardAction.Yes, "ACTION_YES"c, "dialog-ok");
const Action ACTION_NO = new Action(StandardAction.No, "ACTION_NO"c, "dialog-cancel");
const Action ACTION_CLOSE = new Action(StandardAction.Close, "ACTION_CLOSE"c, "dialog-close");
const Action ACTION_ABORT =  new Action(StandardAction.Abort, "ACTION_ABORT"c);
const Action ACTION_RETRY = new Action(StandardAction.Retry, "ACTION_RETRY"c);
const Action ACTION_IGNORE = new Action(StandardAction.Ignore, "ACTION_IGNORE"c);
const Action ACTION_OPEN = new Action(StandardAction.Open, "ACTION_OPEN"c);
const Action ACTION_SAVE = new Action(StandardAction.Save, "ACTION_SAVE"c);
const Action ACTION_SAVE_ALL = new Action(StandardAction.SaveAll, "ACTION_SAVE_ALL"c);
const Action ACTION_DISCARD_CHANGES = new Action(StandardAction.DiscardChanges, "ACTION_DISCARD_CHANGES"c);
const Action ACTION_DISCARD_ALL = new Action(StandardAction.DiscardAll, "ACTION_DISCARD_ALL"c);
const Action ACTION_OPEN_URL = (new Action(StandardAction.OpenUrl)).iconId("applications-internet");

