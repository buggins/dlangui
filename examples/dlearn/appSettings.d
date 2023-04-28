//module appSettings;

import dlangui.core.settings;
import dlangui.core.i18n;
// import dlangui.dialogs.dialog;
//import dlangui.graphics.fonts;

import std.algorithm : equal;

const AVAILABLE_LANGUAGES = ["en", "cn"];

class AppSettings : SettingsFile {

    this(string filename) {
        super(filename);
    }

    override void updateDefaults() {
        Setting ui = uiSettings();
        ui.setStringDef("language", "cn");
    }

    /// override to do something after loading - e.g. set defaults
    override void afterLoad() {
    }
    
    @property string uiLanguage() {
        return limitString(uiSettings.getString("language", "cn"), AVAILABLE_LANGUAGES);
    }

    @property AppSettings uiLanguage(string v) {
        uiSettings.setString("language", limitString(v, AVAILABLE_LANGUAGES));
        return this;
    }

    @property Setting uiSettings() {
	Setting res = _setting.objectByPath("interface", true);
	return res;
    }
}

