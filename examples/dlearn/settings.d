import dlangui.core.settings;
import dlangui.core.i18n;
import dlangui.widgets.lists;
import dlangui.dialogs.settingsdialog;

StringListValue[] createIntValueList(int[] values, dstring suffix = ""d) {
    import std.conv : to;
    StringListValue[] res;
    res.assumeSafeAppend();
    foreach(n; values) {
        res ~= StringListValue(n, to!dstring(n) ~ suffix);
    }
    return res;
}

SettingsPage createSettingsPages() {
    import std.conv : to;
    SettingsPage res = new SettingsPage("", UIString.fromRaw(""d));

    SettingsPage ui = res.addChild("interface", UIString.fromId("OPTION_INTERFACE"c));
    ui.addStringComboBox("interface/language", UIString.fromId("OPTION_LANGUAGE"c), [
            StringListValue("en", "MENU_VIEW_LANGUAGE_EN"c), 
	    StringListValue("cn", "MENU_VIEW_LANGUAGE_CN"c)]);
    return res;
}
