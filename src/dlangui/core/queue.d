module dlangui.core.queue;

import core.sync.condition;
import core.sync.mutex;

class BlockingQueue(T) {

    private Mutex _mutex;
    private Condition _condition;
    private T[] _buffer;
    private int _readPos;
    private int _writePos;
    private shared bool _closed;

    this() {
        _mutex = new Mutex();
        _condition = new Condition(_mutex);
        _readPos = 0;
        _writePos = 0;
    }

    ~this() {
        close();
        if (_condition) {
            destroy(_condition);
            _condition = null;
        }
        if (_mutex) {
            destroy(_mutex);
            _mutex = null;
        }
    }

    void close() {
        if (_mutex && !_closed) {
            synchronized(_mutex) {
                _closed = true;
                if (_condition !is null)
                    _condition.notifyAll();
            }
        } else {
            _closed = true;
        }
    }

    /// returns true if queue is closed
    @property bool closed() {
        return _closed;
    }

    private void move() {
        if (_readPos > 1024 && _readPos > _buffer.length * 3 / 4) {
            // move buffer data
            for (int i = 0; _readPos + i < _writePos; i++)
                _buffer[i] = _buffer[_readPos + i];
            _writePos -= _readPos;
            _readPos = 0;
        }
    }

    private void append(ref T item) {
        if (_writePos >= _buffer.length) {
            move();
            _buffer.length = _buffer.length == 0 ? 64 : _buffer.length * 2;
        }
        _buffer[_writePos++] = item;
    }

    void put(T item) {
        if (_closed)
            return;
        synchronized(_mutex) {
            if (_closed)
                return;
            append(item);
            _condition.notifyAll();
        }
    }

    void put(T[] items) {
        if (_closed)
            return;
        synchronized(_mutex) {
            if (_closed)
                return;
            foreach(ref item; items) {
                append(item);
            }
            _condition.notifyAll();
        }
    }

    bool get(ref T value, int timeoutMillis = 0) {
        if (_closed)
            return false;
        synchronized(_mutex) {
            if (_closed)
                return false;
            if (_readPos < _writePos) {
                value = _buffer[_readPos++];
                return true;
            }
            try {
                if (timeoutMillis <= 0)
                    _condition.wait(); // no timeout
                else if (!_condition.wait(dur!"msecs"(timeoutMillis)))
                    return false; // timeout
            } catch (Exception e) {
                // ignore
            }
            if (_readPos < _writePos) {
                value = _buffer[_readPos++];
                return true;
            }
        }
        return false;
    }

    bool getAll(ref T[] values, int timeoutMillis) {
        if (_closed)
            return false;
        synchronized(_mutex) {
            if (_closed)
                return false;
            values.length = 0;
            while (_readPos < _writePos)
                values ~= _buffer[_readPos++];
            if (values.length > 0)
                return true;
            if (timeoutMillis <= 0)
                _condition.wait(); // no timeout
            else if (!_condition.wait(dur!"msecs"(timeoutMillis)))
                return false; // timeout
            while (_readPos < _writePos)
                values ~= _buffer[_readPos++];
            if (values.length > 0)
                return true;
        }
        return false;
    }
}

alias Runnable = void delegate();
alias RunnableQueue = BlockingQueue!Runnable;
