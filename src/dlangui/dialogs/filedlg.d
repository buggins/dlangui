// Written in the D programming language.

/**
This module contains FileDialog implementation.

Can show dialog for open / save.


Synopsis:

----
import dlangui.dialogs.filedlg;

UIString caption = "Open File"d;
auto dlg = new FileDialog(caption, window, FileDialogFlag.Open);
dlg.show();

----

Copyright: Vadim Lopatin, 2014
License:   Boost License 1.0
Authors:   Vadim Lopatin, coolreader.org@gmail.com
*/
module dlangui.dialogs.filedlg;

import dlangui.core.events;
import dlangui.core.i18n;
import dlangui.core.stdaction;
import dlangui.widgets.controls;
import dlangui.widgets.lists;
import dlangui.widgets.popup;
import dlangui.widgets.layouts;
import dlangui.widgets.grid;
import dlangui.widgets.editors;
import dlangui.platforms.common.platform;
import dlangui.dialogs.dialog;

/// flags for file dialog options
enum FileDialogFlag : uint {
    /// file must exist (use this for open dialog)
    FileMustExist = 0x100,
    /// ask before saving to existing
    ConfirmOverwrite = 0x200,
    /// flags for Open dialog
    Open = FileMustExist,
    /// flags for Save dialog
    Save = ConfirmOverwrite,
}

/// file open / save dialog
class FileDialog : Dialog {
	EditLine path;
	StringGridWidget list;
	StringGridWidget places;
	VerticalLayout leftPanel;
	VerticalLayout rightPanel;
	this(UIString caption, Window parent, uint fileDialogFlags = DialogFlag.Modal | FileDialogFlag.FileMustExist) {
        super(caption, parent, fileDialogFlags);
    }
	/// override to implement creation of dialog controls
	override void init() {
		layoutWidth(FILL_PARENT);
		layoutWidth(FILL_PARENT);
		LinearLayout content = new HorizontalLayout("dlgcontent");
		content.layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT).minWidth(400).minHeight(300);
		leftPanel = new VerticalLayout("places");
		rightPanel = new VerticalLayout("main");
		leftPanel.layoutHeight(FILL_PARENT).minWidth(40);
		rightPanel.layoutHeight(FILL_PARENT).layoutWidth(FILL_PARENT);
		rightPanel.addChild(new TextWidget(null, "Path:"d));
		content.addChild(leftPanel);
		content.addChild(rightPanel);
		path = new EditLine("path");
		path.layoutWidth(FILL_PARENT);

		rightPanel.addChild(path);
		list = new StringGridWidget("files");
		list.layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT);
		list.resize(3, 3);
		list.setColTitle(0, "Name"d);
		list.setColTitle(1, "Size"d);
		list.setColTitle(2, "Modified"d);
		list.showRowHeaders = false;
		list.rowSelect = true;
		rightPanel.addChild(list);

		places = new StringGridWidget("placesList");
		places.resize(1, 10);
		places.showRowHeaders(false).showColHeaders(true);
		places.setColTitle(0, "Places"d);
		leftPanel.addChild(places);

		addChild(content);
		addChild(createButtonsPanel([ACTION_OPEN, ACTION_CANCEL], 0, 0));

		string[] path = splitPath("/home/lve/src");
		Log.d("path: ", path);
	}
}
