// Written in the D programming language.

/**
This module contains Combo Box widgets implementation.



Synopsis:

----
import dlangui.widgets.combobox;

// creation of simple strings list
ComboBox box = new ComboBox("combo1", ["value 1"d, "value 2"d, "value 3"d]);

// select first item
box.selectedItemIndex = 0;

// get selected item text
println(box.text);

----

Copyright: Vadim Lopatin, 2014
License:   Boost License 1.0
Authors:   Vadim Lopatin, coolreader.org@gmail.com
*/
module dlangui.widgets.combobox;

import dlangui.widgets.widget;
import dlangui.widgets.layouts;
import dlangui.widgets.editors;
import dlangui.widgets.lists;
import dlangui.widgets.controls;
import dlangui.widgets.popup;

private import std.algorithm;

/** Abstract ComboBox. */
class ComboBoxBase : HorizontalLayout, OnClickHandler {
    protected Widget _body;
    protected ImageButton _button;
    protected ListAdapter _adapter;
    protected bool _ownAdapter;
    protected int _selectedItemIndex;

    /** Handle item click. */
    Signal!OnItemSelectedHandler onItemClickListener;

    protected Widget createSelectedItemWidget() {
        Widget res;
        if (_adapter && _selectedItemIndex < _adapter.itemCount) {
            res = _adapter.itemWidget(_selectedItemIndex);
            res.id = "COMBOBOX_BODY";
        } else {
            res = new Widget("COMBOBOX_BODY");
        }
        res.layoutWidth = FILL_PARENT;
        res.layoutHeight = WRAP_CONTENT;
        return res;
    }

    /** Selected item index. */
    @property int selectedItemIndex() {
        return _selectedItemIndex;
    }

    @property void selectedItemIndex(int index) {
        if (_selectedItemIndex == index)
            return;
        _selectedItemIndex = index;
        if (onItemClickListener.assigned)
            onItemClickListener(this, index);
    }

    override bool onClick(Widget source) {
        showPopup();
        return true;
    }

    protected ImageButton createButton() {
        ImageButton res = new ImageButton("COMBOBOX_BUTTON", "scrollbar_btn_down");
        res.onClickListener = this;
        return res;
    }

    protected ListWidget createPopup() {
        ListWidget list = new ListWidget("POPUP_LIST");
        list.adapter = _adapter;
        list.selectedItemIndex = _selectedItemIndex;
        return list;
    }

    protected PopupWidget _popup;
    protected ListWidget _popupList;

    protected void showPopup() {
        _popupList = createPopup();
        _popup = window.showPopup(_popupList, this, PopupAlign.Below | PopupAlign.FitAnchorSize);
        _popup.flags = PopupFlags.CloseOnClickOutside;
        _popup.styleId = "POPUP_MENU";
        _popup.onPopupCloseListener = delegate (PopupWidget source) {
            _popup = null;
            _popupList = null;
        };
        _popupList.onItemSelectedListener = delegate(Widget source, int index) {
            selectedItemIndex = index;
            return true;
        };
        _popupList.onItemClickListener = delegate(Widget source, int index) {
            selectedItemIndex = index;
            if (_popup !is null)
                _popup.close();
            return true;
        };
        _popupList.setFocus();
    }

    this(string ID, ListAdapter adapter, bool ownAdapter = true) {
        super(ID);
        _adapter = adapter;
        _ownAdapter = ownAdapter;
        _body = createSelectedItemWidget();
        _body.onClickListener = this;
        _button = createButton();
        //_body.state = State.Parent;
        //focusable = true;
        _button.focusable = false;
        _body.focusable = true;
        addChild(_body);
        addChild(_button);
    }
}


/** ComboBox with list of strings. */
class ComboBox : ComboBoxBase {
    
    protected StringListAdapter _adapter;
    protected EditLine _edit;

    this(string ID) {
        super(ID, (_adapter = new StringListAdapter()), true);
    }

    this(string ID, string[] items) {
        super(ID, (_adapter = new StringListAdapter(items)), true);
    }

    this(string ID, dstring[] items) {
        super(ID, (_adapter = new StringListAdapter(items)), true);
    }

    @property bool readOnly() {
        return _edit.readOnly;
    }

    @property ComboBox readOnly(bool ro) {
        _edit.readOnly = ro;
        return this;
    }

    @property override dstring text() {
        return _edit.text;
    }

    @property override Widget text(dstring txt) {
        int idx = _adapter.items.indexOf(txt);
        if (idx >= 0) {
            selectedItemIndex = idx;
        } else {
            if (!readOnly) {
                // not found
                _selectedItemIndex = -1;
                _edit.text = txt;
            }
        }
        return this;
    }

    @property override Widget text(UIString txt) {
        int idx = _adapter.items.indexOf(txt);
        if (idx >= 0) {
            selectedItemIndex = idx;
        } else {
            if (!readOnly) {
                // not found
                _selectedItemIndex = -1;
                _edit.text = txt;
            }
        }
        return this;
    }

    override @property void selectedItemIndex(int index) {
        _selectedItemIndex = index;
        _edit.text = _adapter.items[index];
    }

    override protected Widget createSelectedItemWidget() {
        EditLine res = new EditLine("COMBOBOX_BODY");
        res.layoutWidth = FILL_PARENT;
        res.layoutHeight = WRAP_CONTENT;
        res.readOnly = true;
        _edit = res;
        return res;
    }

}
