module dlangui.widgets.combobox;

import dlangui.widgets.widget;
import dlangui.widgets.layouts;
import dlangui.widgets.editors;
import dlangui.widgets.lists;
import dlangui.widgets.controls;

private import std.algorithm;

class ComboBoxBase : HorizontalLayout, OnClickHandler {
    protected Widget _body;
    protected ImageButton _button;
    protected ListAdapter _adapter;
    protected bool _ownAdapter;
    protected int _selectedItemIndex;

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
        _selectedItemIndex = index;
    }

    override bool onClick(Widget source) {
        // TODO
        return true;
    }

    protected ImageButton createButton() {
        ImageButton res = new ImageButton("COMBOBOX_BUTTON", "scrollbar_btn_down");
        res.onClickListener = this;
        return res;
    }

    this(string ID, ListAdapter adapter, bool ownAdapter = true) {
        super(ID);
        _adapter = adapter;
        _ownAdapter = ownAdapter;
        _body = createSelectedItemWidget();
        _button = createButton();
        addChild(_body);
        addChild(_button);
    }
}

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
