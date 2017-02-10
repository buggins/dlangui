// Written in the D programming language.

/**

This module implements support of tool bars.

ToolBarHost is layout to hold one or more toolbars.

ToolBar is bar with tool buttons and other controls arranged horizontally.

Synopsis:

----
import dlangui.widgets.toolbars;
----


Copyright: Vadim Lopatin, 2015
License:   Boost License 1.0
Authors:   Vadim Lopatin, coolreader.org@gmail.com
*/
module dlangui.widgets.toolbars;

import dlangui.widgets.widget;
import dlangui.widgets.layouts;
import dlangui.widgets.controls;
import dlangui.widgets.combobox;

/// Layout with several toolbars
class ToolBarHost : HorizontalLayout {
    this(string ID) {
        super(ID);
    }
    this() {
        this("TOOLBAR_HOST");
        styleId = STYLE_TOOLBAR_HOST;
    }
    /// create and add new toolbar (returns existing one if already exists)
    ToolBar getOrAddToolbar(string ID) {
        ToolBar res = getToolbar(ID);
        if (!res) {
            res = new ToolBar(ID);
            addChild(res);
        }
        return res;
    }
    /// get toolbar by id; null if not found
    ToolBar getToolbar(string ID) {
        Widget res = childById(ID);
        if (res) {
            ToolBar tb = cast(ToolBar)res;
            return tb;
        }
        return null;
    }
    /// override to handle specific actions
    override bool handleAction(const Action a) {
        // route to focused control first, then to main widget
        return window.dispatchAction(a);
    }

    /// map key to action
    override Action findKeyAction(uint keyCode, uint flags) {
        for (int i = 0; i < childCount; i++) {
            auto a = child(i).findKeyAction(keyCode, flags);
            if (a)
                return a;
        }
        return null;
    }
}

/// image button for toolbar
class ToolBarImageButton : ImageButton {
    this(const Action a) {
        super(a);
        styleId = STYLE_TOOLBAR_BUTTON;
        focusable = false;
    }
    mixin ActionTooltipSupport;
}

/// separator for toolbars
class ToolBarSeparator : ImageWidget {
    this() {
        super("separator", "toolbar_separator");
        styleId = STYLE_TOOLBAR_SEPARATOR;
    }
}

/// separator for toolbars
class ToolBarComboBox : ComboBox {
    this(string ID, dstring[] items) {
        super(ID, items);
        styleId = STYLE_TOOLBAR_CONTROL;
        if (items.length > 0)
            selectedItemIndex = 0;
    }
    mixin ActionTooltipSupport;
}

/// Layout with buttons
class ToolBar : HorizontalLayout {
    this(string ID) {
        super(ID);
        styleId = STYLE_TOOLBAR;
    }
    this() {
        this("TOOLBAR");
    }
    void addCustomControl(Widget widget) {
        addChild(widget);
    }
    /// adds image button to toolbar
    void addButtons(const Action[] actions...) {
        foreach(a; actions) {
            if (a.isSeparator) {
                addChild(new ToolBarSeparator());
            } else {
                Widget btn;
                if (a.iconId) {
                    btn = new ToolBarImageButton(a);
                } else {
                    btn = new Button(a);
                    btn.styleId = STYLE_TOOLBAR_BUTTON;
                }
                addChild(btn);
            }
        }
    }

    void addControl(Widget widget) {
        addChild(widget);
    }

    /// map key to action
    override Action findKeyAction(uint keyCode, uint flags) {
        for (int i = 0; i < childCount; i++) {
            auto a = child(i).findKeyAction(keyCode, flags);
            if (a)
                return a;
        }
        return null;
    }
}
