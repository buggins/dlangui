module dlangui.core.asyncsocket;

import std.socket;
import core.thread;
import dlangui.core.queue;
import dlangui.core.logger;

/// Socket state
enum SocketState {
    Disconnected,
    Connecting,
    Connected
}

/// Asynchronous socket interface
interface AsyncSocket {
    @property SocketState state();
    void connect(string host, ushort port);
    void disconnect();
    void send(ubyte[] data);
}

/// Socket error code
enum SocketError {
    ConnectError,
    WriteError,
    NotConnected,
    AlreadyConnected,
}

/// Callback interface for using by AsyncSocket implementations
interface AsyncSocketCallback {
    void onDataReceived(AsyncSocket socket, ubyte[] data);
    void onConnect(AsyncSocket socket);
    void onDisconnect(AsyncSocket socket);
    void onError(AsyncSocket socket, SocketError error, string msg);
}

/// proxy for AsyncConnectionHandler - to call in GUI thread
class AsyncSocketCallbackProxy : AsyncSocketCallback {
private:
    AsyncSocketCallback _handler;
    void delegate(void delegate() runnable) _executor;
public:
    this(AsyncSocketCallback handler, void delegate(void delegate() runnable) executor) {
        _executor = executor;
        _handler = handler;
    }
    void onDataReceived(AsyncSocket socket, ubyte[] data) {
        _executor(delegate() {
            _handler.onDataReceived(socket, data);
        });
    }
    void onConnect(AsyncSocket socket) {
        _executor(delegate() {
            _handler.onConnect(socket);
        });
    }
    void onDisconnect(AsyncSocket socket) {
        _executor(delegate() {
            _handler.onDisconnect(socket);
        });
    }
    void onError(AsyncSocket socket, SocketError error, string msg) {
        _executor(delegate() {
            _handler.onError(socket, error, msg);
        });
    }
}

/// Asynchrous socket which uses separate thread for operation
class AsyncClientConnection : Thread, AsyncSocket {
protected:
    Socket _sock;
    SocketSet _readSet;
    SocketSet _writeSet;
    SocketSet _errorSet;
    RunnableQueue _queue;
    AsyncSocketCallback _callback;
    SocketState _state = SocketState.Disconnected;
    void threadProc() {
        ubyte[] readBuf = new ubyte[65536];
        Log.d("entering ClientConnection thread proc");
        for(;;) {
            if (_queue.closed)
                break;
            Runnable task;
            if (_queue.get(task, _sock ? 10 : 1000)) {
                if (_queue.closed)
                    break;
                task();
            }
            if (_sock) {
                _readSet.reset();
                _writeSet.reset();
                _errorSet.reset();
                _readSet.add(_sock);
                _writeSet.add(_sock);
                _errorSet.add(_sock);
                if (Socket.select(_readSet, _writeSet, _errorSet, dur!"msecs"(10)) > 0) {
                    if (_writeSet.isSet(_sock)) {
                        if (_state == SocketState.Connecting) {
                            _state = SocketState.Connected;
                            _callback.onConnect(this);
                        }
                    }
                    if (_readSet.isSet(_sock)) {
                        long bytesRead = _sock.receive(readBuf);
                        if (bytesRead > 0) {
                            _callback.onDataReceived(this, readBuf[0 .. cast(int)bytesRead].dup);
                        }
                    }
                    if (_errorSet.isSet(_sock)) {
                        doDisconnect();
                    }
                }
            }
        }
        doDisconnect();
        Log.d("exiting ClientConnection thread proc");
    }
    void doDisconnect() {
        if (_sock) {
            _sock.shutdown(SocketShutdown.BOTH);
            _sock.close();
            destroy(_sock);
            _sock = null;
            if (_state != SocketState.Disconnected) {
                _state = SocketState.Disconnected;
                _callback.onDisconnect(this);
            }
        }
    }
public:
    this(AsyncSocketCallback cb) {
        super(&threadProc);
        _callback = cb;
        _queue = new RunnableQueue();
        start();
    }
    ~this() {
        _queue.close();
        join();
    }
    @property SocketState state() {
        return _state;
    }
    void connect(string host, ushort port) {
        _queue.put(delegate() {
            if (_state == SocketState.Connecting) {
                _callback.onError(this, SocketError.NotConnected, "socket is already connecting");
                return;
            }
            if (_state == SocketState.Connected) {
                _callback.onError(this, SocketError.NotConnected, "socket is already connected");
                return;
            }
            doDisconnect();
            _sock = new TcpSocket();
            _sock.blocking = false;
            _readSet = new SocketSet();
            _writeSet = new SocketSet();
            _errorSet = new SocketSet();
            _state = SocketState.Connecting;
            _sock.connect(new InternetAddress(host, port));
        });
    }
    void disconnect() {
        _queue.put(delegate() {
            if (!_sock)
                return;
            doDisconnect();
        });
    }
    void send(ubyte[] data) {
        _queue.put(delegate() {
            if (!_sock) {
                _callback.onError(this, SocketError.NotConnected, "socket is not connected");
                return;
            }
            for (;;) {
                long bytesSent = _sock.send(data);
                if (bytesSent == Socket.ERROR) {
                    _callback.onError(this, SocketError.WriteError, "error while writing to connection");
                    return;
                } else {
                    //Log.d("Bytes sent:" ~ to!string(bytesSent));
                    if (bytesSent >= data.length)
                        return;
                    data = data[cast(int)bytesSent .. $];
                }
            }
        });
    }
}
