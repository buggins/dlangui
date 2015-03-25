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
        res.layoutWidth = WRAP_CONTENT;
        res.layoutHeight = WRAP_CONTENT;
        return res;
    }

    /** Selected item index. */
    @property int selectedItemIndex() {
        return _selectedItemIndex;
    }

    @property ComboBoxBase selectedItemIndex(int index) {
        if (_selectedItemIndex == index)
            return this;
        _selectedItemIndex = index;
        if (onItemClickListener.assigned)
            onItemClickListener(this, index);
        return this;
    }

	/// change enabled state
    override @property Widget enabled(bool flg) { 
        super.enabled(flg);
        _button.enabled = flg;
        return this; 
    }
	/// return true if state has State.Enabled flag set
    override @property bool enabled() { return super.enabled; }

    override bool onClick(Widget source) {
        if (enabled)
            showPopup();
        return true;
    }

    protected ImageButton createButton() {
        ImageButton res = new ImageButton("COMBOBOX_BUTTON", "scrollbar_btn_down");
        res.styleId = STYLE_COMBO_BOX_BUTTON;
		res.layoutWeight = 0;
        res.onClickListener = this;
        res.alignment = Align.VCenter | Align.Right;
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

    /// Set widget rectangle to specified value and layout widget contents. (Step 2 of two phase layout).
    override void layout(Rect rc) {
        super.layout(rc);
        _pos = rc;
        applyMargins(rc);
        applyPadding(rc);
        rc.left = rc.right - _button.measuredWidth;
        _button.layout(rc);
    }

    protected void showPopup() {
        _popupList = createPopup();
        _popup = window.showPopup(_popupList, this, PopupAlign.Below | PopupAlign.FitAnchorSize);
        _popup.flags = PopupFlags.CloseOnClickOutside;
        _popup.styleId = STYLE_POPUP_MENU;
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
        styleId = STYLE_COMBO_BOX;
        trackHover = true;
		init();
    }

	protected void init() {
        _body = createSelectedItemWidget();
        _body.onClickListener = this;
        _button = createButton();
        //_body.state = State.Parent;
        //focusable = true;
        _button.focusable = false;
        _body.focusable = false;
        focusable = true;
        //_body.focusable = true;
        addChild(_body);
        addChild(_button);
	}

    ~this() {
    }
}


/** ComboBox with list of strings. */
class ComboBox : ComboBoxBase {
    
    protected StringListAdapter _adapter;

    /// empty parameter list constructor - for usage by factory
    this() {
        this(null);
    }
    /// create with ID parameter
    this(string ID) {
        super(ID, (_adapter = new StringListAdapter()), true);
    }

    this(string ID, string[] items) {
        super(ID, (_adapter = new StringListAdapter(items)), true);
    }

    this(string ID, dstring[] items) {
        super(ID, (_adapter = new StringListAdapter(items)), true);
    }

    this(string ID, StringListValue[] items) {
        super(ID, (_adapter = new StringListAdapter(items)), true);
    }

    @property override dstring text() {
        return _body.text;
    }

    @property override Widget text(dstring txt) {
        int idx = _adapter.items.indexOf(txt);
        if (idx >= 0) {
            selectedItemIndex = idx;
        } else {
            // not found
            _selectedItemIndex = -1;
            _body.text = txt;
        }
        return this;
    }

    @property override Widget text(UIString txt) {
        int idx = _adapter.items.indexOf(txt);
        if (idx >= 0) {
            selectedItemIndex = idx;
        } else {
            // not found
            _selectedItemIndex = -1;
            _body.text = txt;
        }
        return this;
    }

    override @property ComboBoxBase selectedItemIndex(int index) {
        _body.text = _adapter.items[index];
		return super.selectedItemIndex(index);
    }

	override void init() {
		super.init();
		_body.focusable = false;
		_body.clickable = true;
		focusable = true;
		clickable = true;
		onClickListener = this;
	}

    override protected Widget createSelectedItemWidget() {
        TextWidget res = new TextWidget("COMBO_BOX_BODY");
		res.styleId = STYLE_COMBO_BOX_BODY;
		res.clickable = true;
        res.layoutWidth = FILL_PARENT;
        res.layoutHeight = WRAP_CONTENT;
		int maxItemWidth = 0;
		for(int i = 0; i < _adapter.itemCount; i++) {
			Widget item = _adapter.itemWidget(i);
			item.measure(SIZE_UNSPECIFIED, SIZE_UNSPECIFIED);
			if (maxItemWidth < item.measuredWidth)
				maxItemWidth = item.measuredWidth;
		}
		res.minWidth = maxItemWidth;
        return res;
    }

    ~this() {
        if (_adapter) {
            destroy(_adapter);
            _adapter = null;
        }
    }

}

/** Editable ComboBox with list of strings. */
class ComboEdit : ComboBox {

    protected EditLine _edit;

    /// empty parameter list constructor - for usage by factory
    this() {
        this(null);
    }
    /// create with ID parameter
    this(string ID) {
        super(ID);
    }

    this(string ID, string[] items) {
        super(ID, items);
    }

    this(string ID, dstring[] items) {
        super(ID, items);
    }

    @property bool readOnly() {
        return _edit.readOnly;
    }

    @property ComboBox readOnly(bool ro) {
        _edit.readOnly = ro;
        return this;
    }

    override protected Widget createSelectedItemWidget() {
        EditLine res = new EditLine("COMBOBOX_BODY");
        res.layoutWidth = FILL_PARENT;
        res.layoutHeight = WRAP_CONTENT;
        res.readOnly = true;
        _edit = res;
        return res;
    }

	override void init() {
		super.init();
		//focusable = false;
		//_body.focusable = true;
	}

}

