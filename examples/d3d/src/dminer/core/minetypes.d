module dminer.core.minetypes;

alias cell_t = ubyte;

immutable cell_t NO_CELL = 0;
immutable cell_t END_OF_WORLD =  253;
immutable cell_t VISITED_CELL =  255;
immutable cell_t VISITED_OCCUPIED = 254;

immutable cell_t BOUND_BOTTOM = 253;
immutable cell_t BOUND_SKY =    252;

enum : ubyte {
    NORTH = 0,
    SOUTH,
    WEST,
    EAST,
    UP,
    DOWN,
}

alias Dir = ubyte;

/// Extended Dir simple Dir directions can be combined; first 6 items of DirEx match items of Dir - 26 directions (3*3*3-1) 
enum : ubyte {
    // main directions
    DIR_NORTH = 0,
    DIR_SOUTH,
    DIR_WEST,
    DIR_EAST,
    DIR_UP,
    DIR_DOWN,
    // combined directions
    DIR_WEST_UP,
    DIR_EAST_UP,
    DIR_WEST_DOWN,
    DIR_EAST_DOWN,
    DIR_NORTH_WEST,
    DIR_NORTH_EAST,
    DIR_NORTH_UP,
    DIR_NORTH_DOWN,
    DIR_NORTH_WEST_UP,
    DIR_NORTH_EAST_UP,
    DIR_NORTH_WEST_DOWN,
    DIR_NORTH_EAST_DOWN,
    DIR_SOUTH_WEST,
    DIR_SOUTH_EAST,
    DIR_SOUTH_UP,
    DIR_SOUTH_DOWN,
    DIR_SOUTH_WEST_UP,
    DIR_SOUTH_EAST_UP,
    DIR_SOUTH_WEST_DOWN,
    DIR_SOUTH_EAST_DOWN,
    DIR_MAX,
    DIR_MIN = DIR_NORTH,
}
alias DirEx = ubyte;

// 26 direction masks based on Dir
enum : uint {
    MASK_NORTH = (1 << NORTH),
    MASK_SOUTH = (1 << SOUTH),
    MASK_WEST = (1 << WEST),
    MASK_EAST = (1 << EAST),
    MASK_UP = (1 << UP),
    MASK_DOWN = (1 << DOWN),
    MASK_WEST_UP = (1 << WEST) | MASK_UP,
    MASK_EAST_UP = (1 << EAST) | MASK_UP,
    MASK_WEST_DOWN = (1 << WEST) | MASK_DOWN,
    MASK_EAST_DOWN = (1 << EAST) | MASK_DOWN,
    MASK_NORTH_WEST = MASK_NORTH | MASK_WEST,
    MASK_NORTH_EAST = MASK_NORTH | MASK_EAST,
    MASK_NORTH_UP = MASK_NORTH | MASK_UP,
    MASK_NORTH_DOWN = MASK_NORTH | MASK_DOWN,
    MASK_NORTH_WEST_UP = MASK_NORTH | MASK_WEST | MASK_UP,
    MASK_NORTH_EAST_UP = MASK_NORTH | MASK_EAST | MASK_UP,
    MASK_NORTH_WEST_DOWN = MASK_NORTH | MASK_WEST | MASK_DOWN,
    MASK_NORTH_EAST_DOWN = MASK_NORTH | MASK_EAST | MASK_DOWN,
    MASK_SOUTH_WEST = MASK_SOUTH | MASK_WEST,
    MASK_SOUTH_EAST = MASK_SOUTH | MASK_EAST,
    MASK_SOUTH_UP = MASK_SOUTH | MASK_UP,
    MASK_SOUTH_DOWN = MASK_SOUTH | MASK_DOWN,
    MASK_SOUTH_WEST_UP = MASK_SOUTH | MASK_WEST | MASK_UP,
    MASK_SOUTH_EAST_UP = MASK_SOUTH | MASK_EAST | MASK_UP,
    MASK_SOUTH_WEST_DOWN = MASK_SOUTH | MASK_WEST | MASK_DOWN,
    MASK_SOUTH_EAST_DOWN = MASK_SOUTH | MASK_EAST | MASK_DOWN,
}

alias DirMask = uint;

/+
struct SymmetricMatrix (T, T initValue) {
private:
    int _size;
    int dx;
    int dx2;
    T * data;
public:
    this(int sz = 1) {
        _size = sz;
        reset(sz);
    }
    ~this() {
        if (data)
            delete[] data;
    }
    T get(int x, int y) {
        return data[(x + dx2) * dx + (y + dx2)];
    }
    void set(int x, int y, T value) {
        data[(x + dx2) * dx + (y + dx2)] = value;
    }
    int size() {
        return _size;
    }
    void reset(int sz) {
        if (_size != sz || !data) {
            _size = sz;
            dx = _size + _size - 1;
            dx2 = dx / 2;
            if (data)
                delete[] data;
            data = new T[dx * dx];
        }
        for (int i = dx * dx - 1; i >= 0; i--)
            data[i] = initValue;
    }
}

alias BoolSymmetricMatrix = SymmetricMatrix!(bool, false);
+/

struct Vector2d {
    int x;
    int y;
    this(int xx, int yy) {
        x = xx;
        y = yy;
    }
    bool opEqual(Vector2d v) const {
        return x == v.x && y == v.y;
    }
}

immutable Vector2d ZERO2 = Vector2d(0, 0);

struct Vector3d {
    int x;
    int y;
    int z;
    this(int xx, int yy, int zz) {
        x = xx;
        y = yy;
        z = zz;
    }
    bool opEqual(const Vector3d v) const {
        return x == v.x && y == v.y && z == v.z;
    }
    
    /// returns vector with all components which are negative of components for this vector
    Vector3d opUnary(string op : "-")() const {
        return Vector3d(-x, -y, -z);
    }
    /// subtract vectors
    Vector3d opBinary(string op : "-")(const Vector3d v) const {
        return Vector3d(x - v.x, y - v.y, z - v.z);
    }
    /// add vectors
    Vector3d opBinary(string op : "+")(const Vector3d v) const {
        return Vector3d(x + v.x, y + v.y, z + v.z);
    }
    /// 
    int opBinary(string op : "*")(const Vector3d v) const {
        return x*v.x + y*v.y + z*v.z;
    }
    /// multiply vector elements by constant
    Vector3d opBinary(string op : "*")(int n) const {
        return Vector3d(x * n, y * n, z * n);
    }

    /// 
    ref Vector3d opOpAssign(string op : "+")(const Vector3d v) {
        x += v.x;
        y += v.y;
        z += v.z;
        return this;
    }
    /// 
    ref Vector3d opOpAssign(string op : "-")(const Vector3d v) {
        x -= v.x;
        y -= v.y;
        z -= v.z;
        return this;
    }
    /// 
    ref Vector3d opOpAssign(string op : "*")(int n) {
        x *= n;
        y *= n;
        z *= n;
        return this;
    }
    Vector3d turnLeft() {
        return Vector3d(z, y, -x);
    }
    Vector3d turnRight() {
        return Vector3d(-z, y, x);
    }
    Vector3d turnUp() {
        return Vector3d(x, -z, y);
    }
    Vector3d turnDown() {
        return Vector3d(x, z, -y);
    }
    Vector3d move(DirEx dir) {
        Vector3d res = this;
        switch (dir) {
        case DIR_NORTH:
            res.z--;
            break;
        case DIR_SOUTH:
            res.z++;
            break;
        case DIR_WEST:
            res.x--;
            break;
        case DIR_EAST:
            res.x++;
            break;
        case DIR_UP:
            res.y++;
            break;
        case DIR_DOWN:
            res.y--;
            break;
        default:
            break;
        }
        return res;
    }
}

const Vector3d ZERO3 = Vector3d(0, 0, 0);

struct Array(T) {
private:
    int _length;
    T[] _data;
public:
    T * ptr(int index = 0) {
        return _data.ptr + index;
    }
    void swap(ref Array v) {
        int tmp;
        tmp = _length; _length = v._length; v._length = tmp;
        T[] ptmp;
        ptmp = _data; _data = v._data; v._data = ptmp;
    }
    /// ensure capacity is enough to fit sz items
    void reserve(int sz) {
        sz += _length;
        if (_data.length < sz) {
            int oldsize = cast(int)_data.length;
            int newsize = 1024;
            while (newsize < sz)
                newsize <<= 1;
            _data.length = newsize;
            for (int i = oldsize; i < newsize; i++)
                _data[i] = T.init;
            _data.assumeSafeAppend();
        }
    }
    @property int length() {
        return _length;
    }
    /// append single item by ref
    void append(ref const T value) {
        if (_length >= _data.length)
            reserve(_data.length == 0 ? 64 : _data.length * 2 - _length);
        _data[_length++] = value;
    }
    /// append single item by value
    void append(T value) {
        if (_length >= _data.length)
            reserve(_data.length == 0 ? 64 : _data.length * 2 - _length);
        _data[_length++] = value;
    }
    /// append single item w/o check
    void appendNoCheck(ref const T value) {
        _data[_length++] = value;
    }
    /// append single item w/o check
    void appendNoCheck(T value) {
        _data[_length++] = value;
    }
    /// appends same value several times, return pointer to appended items
    T* append(ref const T value, int count) {
        reserve(count);
        int startLen = _length;
        for (int i = 0; i < count; i++)
            _data[_length++] = value;
        return _data.ptr + startLen;
    }
    /// appends same value several times, return pointer to appended items
    T* append(T value, int count) {
        reserve(count);
        int startLen = _length;
        for (int i = 0; i < count; i++)
            _data[_length++] = value;
        return _data.ptr + startLen;
    }
    void clear() {
        _length = 0;
    }
    T get(int index) {
        return _data[index];
    }
    void set(int index, T value) {
        _data[index] = value;
    }
    ref T opIndex(int index) {
        return _data[index];
    }
}

alias FloatArray = Array!(float);
alias IntArray = Array!(int);
alias CellArray = Array!(cell_t);
alias Vector2dArray = Array!(Vector2d);
alias Vector3dArray = Array!(Vector3d);

/// array with support of both positive and negative indexes
struct InfiniteArray(T) {
private:
    T[] dataPlus;
    T[] dataMinus;
    int minIdx;
    int maxIdx;
public:
    @property int minIndex() { return minIdx; }
    @property int maxIndex() { return maxIdx; }
    void disposeFunction(T p) {
        destroy(p);
    }
    ~this() {
        foreach(p; dataPlus)
            if (p !is T.init)
                disposeFunction(p);
        foreach(p; dataMinus)
            if (p !is T.init)
                disposeFunction(p);
    }
    T get(int index) {
        if (index >= 0) {
            if (index >= maxIdx)
                return T.init;
            return dataPlus[index];
        } else {
            if (index <= minIdx)
                return T.init;
            return dataMinus[-index];
        }
    }
    void set(int index, T value) {
        if (index >= 0) {
            if (index >= maxIdx) {
                // extend array
                if (index <= dataPlus.length) {
                    int oldsize = dataPlus.length;
                    int newsize = 1024;
                    while (newsize <= index)
                        newsize <<= 1;
                    dataPlus.length = newsize;
                    dataPlus.assumeSafeAppend;
                    for(int i = oldsize; i < newsize; i++)
                        dataPlus[i] = T.init;
                }
                maxIdx = index + 1;
            }
            if (dataPlus[index] !is T.init && dataPlus[index] !is value)
                disposeFunction(dataPlus[index]);
            dataPlus[index] = value;
        } else {
            if (index <= minIdx) {
                // extend array
                if (-index <= dataMinus.length) {
                    int oldsize = dataMinus.length;
                    int newsize = 1024;
                    while (newsize <= -index)
                        newsize <<= 1;
                    dataMinus.length = newsize;
                    dataMinus.assumeSafeAppend;
                    for(int i = oldsize; i < newsize; i++)
                        dataMinus[i] = T.init;
                }
                maxIdx = index - 1;
            }
            if (dataMinus[-index] !is T.init && dataMinus[-index] !is value)
                disposeFunction(dataMinus[-index]);
            dataMinus[-index] = value;
        }
    }
}

struct InfiniteMatrix(T) {
private:
    int _minx = 0;
    int _maxx = 0;
    int _miny = 0;
    int _maxy = 0;
    int _size = 0;
    int _sizeShift = 0;
    T[] _data;
    void resize(int newSizeShift) {
        int newSize = (1<<newSizeShift);
        T[] newdata;
        newdata.length = newSize * 2 * newSize * 2;
        newdata[0 .. $] = null;
        for (int y = -_size; y < _size; y++) {
            for (int x = -_size; x < _size; x++) {
                T v = get(x, y);
                if (x < -newSize || x >= newSize || y < -newSize || y >= newSize) {
                    // destory: // outside new size
                    destroy(v);
                } else {
                    // move
                    newdata[((y + newSize) << (newSizeShift + 1)) | (x + newSize)] = v;
                }
            }
        }
        _data = newdata;
        _size = newSize;
        _sizeShift = newSizeShift;
    }
    int calcIndex(int x, int y) {
        return ((y + _size) << (_sizeShift + 1)) + (x + _size);
    }
public:
    @property int size() { return _size; }
    T get(int x, int y) {
        if (x < -_size || x >= _size || y < -_size || y >= _size)
            return null;
        return _data[calcIndex(x, y)];
    }
    void set(int x, int y, T v) {
        if (x < -_size || x >= _size || y < -_size || y >= _size) {
            int newSizeShift = _sizeShift < 6 ? 6 : _sizeShift + 1;
            for (; ;newSizeShift++) {
                int sz = 1 << newSizeShift;
                if (x < -sz || x >= sz || y < -sz || y >= sz)
                    continue;
                break;
            }
            resize(newSizeShift);
        }
        int index = calcIndex(x, y);
        if (_data[index])
            destroy(_data[index]);
        _data[index] = v;
    }
    ~this() {
        foreach(ref v; _data)
            if (v)
                destroy(v);
    }
}

struct Position {
    Vector3d pos;
    Direction direction;
    this(ref Position p) {
        pos = p.pos;
        direction = p.direction;
    }
    this(Vector3d position, Vector3d dir) {
        pos = position;
        direction = dir;
    }
    Vector2d calcPlaneCoords(Vector3d v) {
        v = v - pos;
        switch (direction.dir) {
            default:
            case NORTH:
                return Vector2d(v.x, v.y);
            case SOUTH:
                return Vector2d(-v.x, v.y);
            case EAST:
                return Vector2d(v.z, v.y);
            case WEST:
                return Vector2d(-v.z, v.y);
            case UP:
                return Vector2d(-v.z, v.x);
            case DOWN:
                return Vector2d(v.z, v.x);
        }
    }
    void turnLeft() {
        direction.turnLeft();
    }
    void turnRight() {
        direction.turnRight();
    }
    void turnUp() {
        direction.turnUp();
    }
    void turnDown() {
        direction.turnDown();
    }
    void forward(int step = 1) {
        pos += direction.forward * step;
    }
    void backward(int step = 1) {
        pos -= direction.forward * step;
    }
}


/// returns opposite direction to specified direction
Dir opposite(Dir d) {
    return cast(Dir)(d ^ 1);
}

Dir turnLeft(Dir d) {
    switch (d) {
        case WEST:
            return SOUTH;
        case EAST:
            return NORTH;
        default:
        case NORTH:
            return WEST;
        case SOUTH:
            return EAST;
        case UP:
            return SOUTH;
        case DOWN:
            return NORTH;
    }
}

Dir turnRight(Dir d) {
    switch (d) {
        case WEST:
            return NORTH;
        case EAST:
            return SOUTH;
        default:
        case NORTH:
            return EAST;
        case SOUTH:
            return WEST;
        case UP:
            return NORTH;
        case DOWN:
            return SOUTH;
    }
}

Dir turnUp(Dir d) {
    switch (d) {
        case WEST:
            return UP;
        case EAST:
            return UP;
        default:
        case NORTH:
            return UP;
        case SOUTH:
            return UP;
        case UP:
            return SOUTH;
        case DOWN:
            return NORTH;
    }
}

Dir turnDown(Dir d) {
    switch (d) {
        case WEST:
            return DOWN;
        case EAST:
            return DOWN;
        default:
        case NORTH:
            return DOWN;
        case SOUTH:
            return DOWN;
        case UP:
            return NORTH;
        case DOWN:
            return SOUTH;
    }
}


struct Direction {
    this(int x, int y, int z) {
        set(x, y, z);
    }
    this(Vector3d v) {
        set(v);
    }
    this(Dir d) {
        set(d);
    }
    /// set by direction code
    void set(Dir d) {
        switch (d) {
            default:
            case NORTH:
                set(0, 0, -1);
                break;
            case SOUTH:
                set(0, 0, 1);
                break;
            case WEST:
                set(-1, 0, 0);
                break;
            case EAST:
                set(1, 0, 0);
                break;
            case UP:
                set(0, 1, 0);
                break;
            case DOWN:
                set(0, -1, 0);
                break;
        }
    }
    /// set by vector
    void set(Vector3d v) { set(v.x, v.y, v.z); }
    /// set by vector
    void set(int x, int y, int z) {
        forward = Vector3d(x, y, z);
        if (x) {
            dir = (x > 0) ? EAST : WEST;
        }
        else if (y) {
            dir = (y > 0) ? UP : DOWN;
        }
        else {
            dir = (z > 0) ? SOUTH : NORTH;
        }
        switch (dir) {
            case UP:
                up = Vector3d(1, 0, 0);
                left = Vector3d(0, 0, 1);
                break;
            case DOWN:
                up = Vector3d(1, 0, 0);
                left = Vector3d(0, 0, -1);
                break;
            default:
            case NORTH:
                up = Vector3d(0, 1, 0);
                left = Vector3d(-1, 0, 0);
                break;
            case SOUTH:
                up = Vector3d(0, 1, 0);
                left = Vector3d(1, 0, 0);
                break;
            case EAST:
                up = Vector3d(0, 1, 0);
                left = Vector3d(0, 0, -1);
                break;
            case WEST:
                up = Vector3d(0, 1, 0);
                left = Vector3d(0, 0, 1);
                break;
        }
        down = -up;
        right = -left;
        forwardUp = forward + up;
        forwardDown = forward + down;
        forwardLeft = forward + left;
        forwardLeftUp = forward + left + up;
        forwardLeftDown = forward + left + down;
        forwardRight = forward + right;
        forwardRightUp = forward + right + up;
        forwardRightDown = forward + right + down;
    }

    void turnLeft() {
        set(.turnLeft(dir));
    }
    void turnRight() {
        set(.turnRight(dir));
    }
    void turnUp() {
        set(.turnUp(dir));
    }
    void turnDown() {
        set(.turnDown(dir));
    }

    Dir dir;
    Vector3d forward;
    Vector3d up;
    Vector3d right;
    Vector3d left;
    Vector3d down;
    Vector3d forwardUp;
    Vector3d forwardDown;
    Vector3d forwardLeft;
    Vector3d forwardLeftUp;
    Vector3d forwardLeftDown;
    Vector3d forwardRight;
    Vector3d forwardRightUp;
    Vector3d forwardRightDown;
}

/// returns number of bits to store integer
int bitsFor(int n) {
	int res;
	for (res = 0; n > 0; res++)
		n >>= 1;
	return res;
}

/// returns 0 for 0, 1 for negatives, 2 for positives
int mySign(int n) {
	if (n > 0)
		return 1;
	else if (n < 0)
		return -1;
	else
		return 0;
}

immutable ulong RANDOM_MULTIPLIER  = ((cast(ulong)1 << 48) - 1);
immutable ulong RANDOM_MASK = ((cast(ulong)1 << 48) - 1);
immutable ulong RANDOM_ADDEND = cast(ulong)0xB;

struct Random {
    ulong seed;
    //Random();
    void setSeed(ulong value) {
        seed = (value ^ RANDOM_MULTIPLIER) & RANDOM_MASK;
    }

    int next(int bits) {
        seed = (seed * RANDOM_MULTIPLIER + RANDOM_ADDEND) & RANDOM_MASK;
        return cast(int)(seed >> (48 - bits));
    }

    int nextInt() {
        return next(31);
    }
    int nextInt(int n);
}

const Vector3d DIRECTION_VECTORS[6] = [
	Vector3d(0, 0, -1),
	Vector3d(0, 0, 1),
	Vector3d(-1, 0, 0),
	Vector3d(1, 0, 0),
	Vector3d(0, 1, 0),
	Vector3d(0, -1, 0)
];
