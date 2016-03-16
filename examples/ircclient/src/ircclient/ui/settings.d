module ircclient.ui.settings;

import dlangui.core.settings;

class IRCSettings : SettingsFile {
    this(string filename) {
        super(filename);
    }

    IRCSettings clone() {
        IRCSettings res = new IRCSettings(filename);
        res.applySettings(setting);
        return res;
    }

    override void updateDefaults() {
        // def server
        serverSettings.setStringDef("host", "irc.freenode.net");
        serverSettings.setUintegerDef("port", 6667);
        // def user
        userSettings.setStringDef("username", "user");
        userSettings.setStringDef("realname", "User");
        userSettings.setStringDef("nick", "dlanguiIRC");
        userSettings.setStringDef("alternick", "d_IRC_client");
        // channel settings
        channelSettings.setStringDef("channelName", "#d");
        channelSettings.setBooleanDef("joinOnConnect", true);
    }

    @property Setting serverSettings() { return _setting.objectByPath("server", true); }

    @property string host() { return serverSettings.getString("host", "irc.freenode.net"); }
    @property void host(string s) { serverSettings.setString("host", s); }
    @property ushort port() { return cast(ushort)serverSettings.getUinteger("port", 6667); }
    @property void port(ushort v) { serverSettings.setUinteger("port", v); }

    @property Setting channelSettings() { return _setting.objectByPath("channels/startup", true); }

    @property string defChannel() { return channelSettings.getString("channelName", ""); }
    @property void defChannel(string s) { channelSettings.setString("channelName", s); }
    @property bool joinOnConnect() { return channelSettings.getBoolean("joinOnConnect", true); }
    @property void joinOnConnect(bool v) { channelSettings.setBoolean("joinOnConnect", v); }

    @property Setting userSettings() { return _setting.objectByPath("user", true); }

    @property string nick() { return userSettings.getString("nick", ""); }
    @property void nick(string s) { userSettings.setString("nick", s); }
    @property string alternateNick() { return userSettings.getString("alternick", ""); }
    @property void alternateNick(string s) { userSettings.setString("alternick", s); }
    @property string userName() { return userSettings.getString("username", "user"); }
    @property void userName(string s) { userSettings.setString("username", s); }
    @property string userRealName() { return userSettings.getString("realname", "User"); }
    @property void userRealName(string s) { userSettings.setString("realname", s); }

}


