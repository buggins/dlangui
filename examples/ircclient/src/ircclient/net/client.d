module ircclient.net.client;

public import dlangui.core.asyncsocket;
import dlangui.core.logger;
import std.string : empty, format;
import std.conv : to;

interface IRCClientCallback {
    void onIRCConnect(IRCClient client);
    void onIRCDisconnect(IRCClient client);
    void onIRCMessage(IRCClient client, IRCMessage message);
    void onIRCPing(IRCClient client, string message);
    void onIRCPrivmsg(IRCClient client, IRCAddress source, string target, string message);
    void onIRCNotice(IRCClient client, IRCAddress source, string target, string message);
}

enum IRCCommand : int {
    UNKNOWN,
    USER = 1000,
    PRIVMSG, // :source PRIVMSG <target> :Message
    NOTICE, // :source NOTICE <target> :Message
    NICK,
    PING, // PING :message
    PONG, // PONG :message
    QUIT, // :source QUIT :reason
    JOIN, // :source JOIN :#channel
    PART, // :source PART #channel :reason
    MODE, //
}

IRCCommand findCommandId(string s) {
    if (s.empty)
        return IRCCommand.UNKNOWN;
    if (s[0] >= '0' && s[0] <= '9') {
        // parse numeric command ID
        int n = 0;
        foreach(ch; s)
            if (ch >= '0' && ch <= '9')
                n = n * 10 + (ch - '0');
        return cast(IRCCommand)n;
    }

    switch (s) with(IRCCommand) {
        case "USER": return USER;
        case "PRIVMSG": return PRIVMSG;
        case "NICK": return NICK;
        case "QUIT": return QUIT;
        case "PING": return PING;
        case "PONG": return PONG;
        case "JOIN": return JOIN;
        case "PART": return PART;
        case "NOTICE": return NOTICE;
        default:
            return UNKNOWN;
    }
}

/// IRC message
class IRCMessage {
    /// full message text
    string msg;
    /// optional first parameter of message, starting with :  -- e.g. ":holmes.freenode.net"
    string source; // source of message
    IRCAddress sourceAddress; // parsed source
    string command;  // command text
    IRCCommand commandId = IRCCommand.UNKNOWN; // command id
    string[] params; // all parameters after command
    string message;  // optional message parameter, w/o starting :
    string target; // for some command types - message target
    /// parse message text
    bool parse(string s) {
        msg = s;
        if (s.empty)
            return false;
        if (s[0] == ':') {
            // parse source
            source = parseDelimitedParameter(s);
            if (source.length < 2)
                return false;
            source = source[1 .. $];
            sourceAddress = new IRCAddress(source);
        }
        command = parseDelimitedParameter(s);
        if (command.empty)
            return false;
        commandId = findCommandId(command);
        while (!s.empty) {
            if (s[0] == ':') {
                params ~= s;
                message = s[1 .. $];
                break;
            } else {
                params ~= parseDelimitedParameter(s);
            }
        }
        switch(commandId) with (IRCCommand) {
            case PRIVMSG:
            case NOTICE:
            case JOIN:
            case PART:
                if (params.length > 0)
                    target = params[0];
                break;
            default:
                break;
        }
        return true;
    }
}

class IRCAddress {
    string full;
    string host;
    string channel;
    string nick;
    string username;
    this(string s) {
        full = s;
        string s1 = parseDelimitedParameter(s, '!');
        if (!s.empty) {
            // VadimLopatin!~Buggins@149.62.27.44
            nick = s1;
            username = s;
        } else {
            host = s1;
        }
    }
    @property string longName() {
        if (!nick.empty) {
            return nick ~ " (" ~ username ~ ")";
        } else {
            return full;
        }
    }
}

/// IRC Client connection implementation
class IRCClient : AsyncSocketCallback {
protected:
    AsyncSocket _socket;
    IRCClientCallback _callback;
    char[] _readbuf;
    string _host;
    ushort _port;
    string _nick;
    void onDataReceived(AsyncSocket socket, ubyte[] data) {
        _readbuf ~= cast(char[])data;
        // split by lines
        int start = 0;
        for (int i = 0; i + 1 < _readbuf.length; i++) {
            if (_readbuf[i] == '\r' && _readbuf[i + 1] == '\n') {
                if (i > start)
                    onMessageText(_readbuf[start .. i].dup);
                start = i + 2;
            }
        }
        if (start < _readbuf.length) {
            // has unfinished text
            _readbuf = _readbuf[start .. $].dup;
        } else {
            // end of buffer
            _readbuf.length = 0;
        }
    }
    void onMessageText(string msgText) {
        IRCMessage msg = new IRCMessage();
        if (msg.parse(msgText)) {
            onMessage(msg);
        } else {
            Log.e("cannot parse IRC message " ~ msgText);
        }
    }
    void onMessage(IRCMessage msg) {
        Log.d("MSG: " ~ msg.msg);
        switch (msg.commandId) with (IRCCommand) {
            case PING:
                _callback.onIRCPing(this, msg.message);
                break;
            case PRIVMSG:
                _callback.onIRCPrivmsg(this, msg.sourceAddress, msg.target, msg.message);
                break;
            case NOTICE:
                _callback.onIRCNotice(this, msg.sourceAddress, msg.target, msg.message);
                break;
            default:
                _callback.onIRCMessage(this, msg);
                break;
        }
    }
    void onConnect(AsyncSocket socket) {
        Log.e("onConnect");
        _readbuf.length = 0;
        _callback.onIRCConnect(this);
    }
    void onDisconnect(AsyncSocket socket) {
        Log.e("onDisconnect");
        _readbuf.length = 0;
        _callback.onIRCDisconnect(this);
    }
    void onError(AsyncSocket socket, SocketError error, string msg) {
    }
public:
    this() {
    }
    ~this() {
        if (_socket)
            destroy(_socket);
    }
    @property string host() { return _host; }
    @property ushort port() { return _port; }
    @property string hostPort() { return "%s:%d".format(_host, _port); }
    /// set socket to use
    @property void socket(AsyncSocket sock) {
        _socket = sock;
    }
    @property void callback(IRCClientCallback callback) {
        _callback = callback;
    }
    void connect(string host, ushort port) {
        _host = host;
        _port = port;
        _socket.connect(host, port);
    }
    void sendMessage(string msg) {
        Log.d("CMD: " ~ msg);
        _socket.send(cast(ubyte[])(msg ~ "\r\n"));
    }
    void pong(string msg) {
        sendMessage("PONG :" ~ msg);
    }
    void privMsg(string destination, string message) {
        sendMessage("PRIVMSG " ~ destination ~ " :" ~ message);
        _callback.onIRCPrivmsg(this, new IRCAddress(_nick ~ "!~username@host"), destination, message);
    }
    void disconnect() {
        _socket.disconnect();
    }
    @property string nick() { 
        return _nick;
    }
    @property void nick(string nickName) {
        if (_nick.empty)
            _nick = nickName;
        sendMessage("NICK " ~ nickName);
    }
    void join(string channel) {
        sendMessage("JOIN " ~ channel);
    }
    void part(string channel, string message) {
        sendMessage("PART " ~ channel ~ (message.empty ? "" : ":" ~ message));
    }

    void quit(string message) {
        sendMessage("QUIT " ~ (message.empty ? "" : ":" ~ message));
    }
}

/// utility function to get first space delimited parameter from string
string parseDelimitedParameter(ref string s, char delimiter = ' ') {
    string res;
    int i = 0;
    // parse source
    for (; i < s.length; i++) {
        if (s[i] == delimiter)
            break;
    }
    if (i > 0) {
        res = s[0 .. i];
    }
    i++;
    s = i < s.length ? s[i .. $] : null;
    return res;
}

