module app;
import dlangui;

mixin APP_ENTRY_POINT;

/// Entry point for dlangui based application
extern (C) int UIAppMain(string[] args) {
	auto view = new View("EditLine List Example");
    return Platform.instance.enterMessageLoop();
}

// Our View example
class View {
	this(dstring aTitle) {
		// Prep the window
		auto window = Platform.instance.createWindow(aTitle, null, WindowFlag.Resizable, 640, 480);
		window.mainWidget = parseML(q{
			VerticalLayout {
				margins: 5pt;
				layoutWidth: fill
				layoutHeight: fill
			}
		});

		// Prep the adapter and list
		auto listAdapter = new WidgetListAdapterKeysMouse();
		auto editLineList = new EditLineList();
			editLineList.layoutWidth(FILL_PARENT);
			editLineList.layoutHeight(FILL_PARENT);
			editLineList.ownAdapter = listAdapter;
		window.mainWidget.addChild(editLineList);
		
		// Add some EditLineForList objects
		import std.conv : to;
		listAdapter.add(new EditLineForList("editLine2", "Double click me! You can select a word."d));
		listAdapter.add(new EditLineForList("editLine1", "Use left/right keys to move cursor left/right of selection."d));
		listAdapter.add(new EditLineForList("editLine0", "Use up/down keys to move to the next edit line."d));
		listAdapter.add(new EditLineForList("editLine3", "You can also do select all via keys, and do other edit line features."d));
		listAdapter.add(new EditLineForList("editLine3", "The edit line list could be used to edit data rapidly."d));
		for (int i=4; i<64; ++i) {
			listAdapter.add(new EditLineForList("editLine" ~ to!string(i), "editLine "d ~ to!dstring(i)));
		}

		// Event handling example
		editLineList.itemSelected = delegate(Widget source, int itemIndex) {
			auto item = cast(EditLineForList) listAdapter.itemWidget(itemIndex);
			window.windowCaption = aTitle ~ " | Selected: "d ~ item.idAsDstring;
			return true;
		};

		window.show;
	} // End this(dstring aTitle)

} // End class View

// BEGIN EditLineList, adapter, and EditLineForList
// -------------------------------------------------------------------------
class EditLineList : ListWidget {
	override bool onKeyEvent(KeyEvent event) {
        if (itemCount == 0 || _selectedItemIndex < 0) return false;

        int navigationDelta = 0;
        if (event.action == KeyAction.KeyDown) {
            if (orientation == Orientation.Vertical) {
                if (event.keyCode == KeyCode.DOWN)
                    navigationDelta = 1;
                else if (event.keyCode == KeyCode.UP)
                    navigationDelta = -1;
            }
        }

		auto item = cast(EditLineForList) _adapter.itemWidget(_selectedItemIndex);

        if (navigationDelta != 0) {
            moveSelection(navigationDelta);
			item = cast(EditLineForList) _adapter.itemWidget(_selectedItemIndex); // because the item changed
			item.allAndFocus(); // Do a select all on the EditLine
            return true;
        }

		if (item.onKeyEvent(event)) {
			invalidate();
			return true;
		}
		
		return super.onKeyEvent(event);
	} // End onKeyEvent(KeyEvent event)

	
	// Modify the behavior of the mouse on the list slightly.
	override bool onMouseEvent(MouseEvent event) {
		super.onMouseEvent(event);
		if (_selectedItemIndex == -1) { return false; }
		_adapter.itemWidget(_selectedItemIndex).onMouseEvent(event);
		return true;
	}

} // End EditLineList

// Adapter that can use keys and mouse events.
class WidgetListAdapterKeysMouse : WidgetListAdapter {
	override @property bool wantKeyEvents() { return true; }
	override @property bool wantMouseEvents() { return true; }
}

// EditLine with slight modifications for list environment.
class EditLineForList : EditLine {

	this(string id, dstring text = null) {
		this.id = id;
		this.text = text;
	}

	void allAndFocus() {
		bool focused = true;
		bool receivedFocusFromKeyboard = true;
		handleFocusChange(focused, receivedFocusFromKeyboard);
	}

	override bool onKeyEvent(KeyEvent event) {
		import std.stdio : writeln;
		bool focused = true;
		bool receivedFocusFromKeyboard = false;
		handleFocusChange(focused, receivedFocusFromKeyboard);

		// Move the cursor to the left or right of selection.
		if (_selectionRange.end.pos - _selectionRange.start.pos > 0) {
			if (event.keyCode == KeyCode.LEFT) {
				_caretPos.pos = _selectionRange.start.pos;
				_selectionRange.start.pos = _caretPos.pos;
				_selectionRange.end.pos = _caretPos.pos;
				ensureCaretVisible();
				return true;
			} else if (event.keyCode == KeyCode.RIGHT) {
				_caretPos.pos = _selectionRange.end.pos;
				_selectionRange.start.pos = _caretPos.pos;
				_selectionRange.end.pos = _caretPos.pos;
				ensureCaretVisible();
				return true;
			}
		}

		super.onKeyEvent(event);
		return true;
	} // End onKeyEvent(KeyEvent event)


	dstring idAsDstring() {
		import std.conv : to;
		return to!dstring(id);
	}
} // End EditLineForList

// END EditLineList, adapter, and EditLineForList