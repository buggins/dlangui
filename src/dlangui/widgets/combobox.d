module dlangui.widgets.combobox;

import dlangui.widgets.widget;
import dlangui.widgets.layouts;
import dlangui.widgets.editors;
import dlangui.widgets.lists;
import dlangui.widgets.controls;

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

    override bool onClick(Widget source) {
        // TODO
        return true;
    }

    protected ImageButton createButton() {
        ImageButton res = new ImageButton("COMBOBOX_BUTTON");
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
    this(string ID, string[] items) {
        super(ID, new StringListAdapter(items), true);
    }
    this(string ID, dstring[] items) {
        super(ID, new StringListAdapter(items), true);
    }
}
