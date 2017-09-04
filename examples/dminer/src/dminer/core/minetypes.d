module dminer.core.minetypes;

alias cell_t = ubyte;

immutable cell_t NO_CELL = 0;
immutable cell_t END_OF_WORLD =  253;
immutable cell_t VISITED_CELL =  255;
immutable cell_t VISITED_OCCUPIED = 254;

immutable cell_t BOUND_BOTTOM = 253;
immutable cell_t BOUND_SKY =    252;


/*
    World coordinates

              A UP
              |
              |  / NORTH
              | /
 WEST         |/
   -----------|-----------> EAST
             /|
            / |
      SOUTH/  |
          L   |
              | DOWN
*/

/// World direction
enum Dir : ubyte {
    NORTH = 0, /// z--
    SOUTH,     /// z++
    EAST,      /// x++
    WEST,      /// x--
    UP,        /// y++
    DOWN,      /// y--
}

// 26 direction masks based on Dir
enum DirMask : ubyte {
    MASK_NORTH = (1 << Dir.NORTH),
    MASK_SOUTH = (1 << Dir.SOUTH),
    MASK_EAST = (1 << Dir.EAST),
    MASK_WEST = (1 << Dir.WEST),
    MASK_UP = (1 << Dir.UP),
    MASK_DOWN = (1 << Dir.DOWN),
    MASK_ALL = 0x3F,
    //MASK_WEST_UP = (1 << Dir.WEST) | MASK_UP,
    //MASK_EAST_UP = (1 << Dir.EAST) | MASK_UP,
    //MASK_WEST_DOWN = (1 << Dir.WEST) | MASK_DOWN,
    //MASK_EAST_DOWN = (1 << Dir.EAST) | MASK_DOWN,
    //MASK_NORTH_WEST = MASK_NORTH | MASK_WEST,
    //MASK_NORTH_EAST = MASK_NORTH | MASK_EAST,
    //MASK_NORTH_UP = MASK_NORTH | MASK_UP,
    //MASK_NORTH_DOWN = MASK_NORTH | MASK_DOWN,
    //MASK_NORTH_WEST_UP = MASK_NORTH | MASK_WEST | MASK_UP,
    //MASK_NORTH_EAST_UP = MASK_NORTH | MASK_EAST | MASK_UP,
    //MASK_NORTH_WEST_DOWN = MASK_NORTH | MASK_WEST | MASK_DOWN,
    //MASK_NORTH_EAST_DOWN = MASK_NORTH | MASK_EAST | MASK_DOWN,
    //MASK_SOUTH_WEST = MASK_SOUTH | MASK_WEST,
    //MASK_SOUTH_EAST = MASK_SOUTH | MASK_EAST,
    //MASK_SOUTH_UP = MASK_SOUTH | MASK_UP,
    //MASK_SOUTH_DOWN = MASK_SOUTH | MASK_DOWN,
    //MASK_SOUTH_WEST_UP = MASK_SOUTH | MASK_WEST | MASK_UP,
    //MASK_SOUTH_EAST_UP = MASK_SOUTH | MASK_EAST | MASK_UP,
    //MASK_SOUTH_WEST_DOWN = MASK_SOUTH | MASK_WEST | MASK_DOWN,
    //MASK_SOUTH_EAST_DOWN = MASK_SOUTH | MASK_EAST | MASK_DOWN,
}

struct Vector2d {
    int x;
    int y;
    this(int xx, int yy) {
        x = xx;
        y = yy;
    }
    //bool opEqual(Vector2d v) const {
    //    return x == v.x && y == v.y;
    //}
}

immutable Vector2d ZERO2 = Vector2d(0, 0);

/// Integer 3d vector: x,y,z
struct Vector3d {
    /// WEST-EAST
    int x;
    /// DOWN-UP
    int y;
    /// NORTH-SOUTH
    int z;

    this(int xx, int yy, int zz) {
        x = xx;
        y = yy;
        z = zz;
    }
    //bool opEqual(const Vector3d v) const {
    //    return x == v.x && y == v.y && z == v.z;
    //}

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
    /// divide vector elements by constant
    Vector3d opBinary(string op : "/")(int n) const {
        return Vector3d(x / n, y / n, z / n);
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
    Vector3d move(Dir dir) {
        Vector3d res = this;
        switch (dir) with(Dir) {
        case NORTH:
            res.z--;
            break;
        case SOUTH:
            res.z++;
            break;
        case WEST:
            res.x--;
            break;
        case EAST:
            res.x++;
            break;
        case UP:
            res.y++;
            break;
        case DOWN:
            res.y--;
            break;
        default:
            break;
        }
        return res;
    }

    int dot(ref Vector3d v) {
        return x * v.x + y * v.y + z * v.z;
    }

    int squaredLength() {
        return x*x + y*y + z*z;
    }
}

__gshared const Vector3d ZERO3 = Vector3d(0, 0, 0);


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
                _data.ptr[i] = T.init;
            _data.assumeSafeAppend();
        }
    }
    @property int length() {
        return _length;
    }
    /// append single item by ref
    void append(ref const T value) {
        if (_length >= _data.length)
            reserve(cast(int)(_data.length == 0 ? 64 : _data.length * 2 - _length));
        _data.ptr[_length++] = value;
    }
    /// append single item by value
    void append(T value) {
        if (_length >= _data.length)
            reserve(cast(int)(_data.length == 0 ? 64 : _data.length * 2 - _length));
        _data.ptr[_length++] = value;
    }
    /// append single item w/o check
    void appendNoCheck(ref const T value) {
        _data.ptr[_length++] = value;
    }
    /// append single item w/o check
    void appendNoCheck(T value) {
        _data.ptr[_length++] = value;
    }
    /// appends same value several times, return pointer to appended items
    T* append(ref const T value, int count) {
        reserve(count);
        int startLen = _length;
        for (int i = 0; i < count; i++)
            _data.ptr[_length++] = value;
        return _data.ptr + startLen;
    }
    /// appends same value several times, return pointer to appended items
    T* append(T value, int count) {
        reserve(count);
        int startLen = _length;
        for (int i = 0; i < count; i++)
            _data.ptr[_length++] = value;
        return _data.ptr + startLen;
    }
    void clear() {
        _length = 0;
    }
    T get(int index) {
        return _data.ptr[index];
    }
    void set(int index, T value) {
        _data.ptr[index] = value;
    }
    ref T opIndex(int index) {
        return _data.ptr[index];
    }
}

alias FloatArray = Array!(float);
alias IntArray = Array!(int);
alias CellArray = Array!(cell_t);
alias Vector2dArray = Array!(Vector2d);
alias Vector3dArray = Array!(Vector3d);



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
    //Vector2d calcPlaneCoords(Vector3d v) {
    //    v = v - pos;
    //    switch (direction.dir) with(Dir) {
    //        default:
    //        case NORTH:
    //            return Vector2d(v.x, v.y);
    //        case SOUTH:
    //            return Vector2d(-v.x, v.y);
    //        case EAST:
    //            return Vector2d(v.z, v.y);
    //        case WEST:
    //            return Vector2d(-v.z, v.y);
    //        case UP:
    //            return Vector2d(-v.z, v.x);
    //        case DOWN:
    //            return Vector2d(v.z, v.x);
    //    }
    //}
    void turnLeft() {
        direction.turnLeft();
    }
    void turnRight() {
        direction.turnRight();
    }
    void shiftLeft(int step = 1) {
        pos += direction.left * step;
    }
    void shiftRight(int step = 1) {
        pos += direction.right * step;
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
    void moveUp(int step = 1) {
        pos += direction.up * step;
    }
    void moveDown(int step = 1) {
        pos += direction.down * step;
    }
    void moveLeft(int step = 1) {
        pos += direction.left * step;
    }
    void moveRight(int step = 1) {
        pos += direction.right * step;
    }
}


/// returns opposite direction to specified direction
Dir opposite(Dir d) {
    return cast(Dir)(d ^ 1);
}

Dir turnLeft(Dir d) {
    switch (d) with (Dir) {
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
    switch (d) with (Dir) {
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
    switch (d) with (Dir) {
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
    switch (d) with (Dir) {
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
    /// returns Y axis rotation angle in degrees (0, 90, 180, 270)
    @property float angle() {
        switch (dir) with (Dir) {
            default:
            case NORTH:
                return 0;
            case SOUTH:
                return 180;
            case WEST:
                return 90;
            case EAST:
                return 270;
            case UP:
            case DOWN:
                return 0;
        }
    }
    /// set by direction code
    void set(Dir d) {
        switch (d) with (Dir) {
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
            dir = (x > 0) ? Dir.EAST : Dir.WEST;
        }
        else if (y) {
            dir = (y > 0) ? Dir.UP : Dir.DOWN;
        }
        else {
            dir = (z > 0) ? Dir.SOUTH : Dir.NORTH;
        }
        switch (dir) with (Dir) {
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

immutable ulong RANDOM_MULTIPLIER  = 0x5DEECE66D;
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
    int nextInt(int n) {
        if ((n & -n) == n)  // i.e., n is a power of 2
            return cast(int)((n * cast(long)next(31)) >> 31);
        int bits, val;
        do {
            bits = next(31);
            val = bits % n;
        } while (bits - val + (n - 1) < 0);
        return val;
    }
}

__gshared const Vector3d[6] DIRECTION_VECTORS = [
    Vector3d(0, 0, -1),
    Vector3d(0, 0, 1),
    Vector3d(-1, 0, 0),
    Vector3d(1, 0, 0),
    Vector3d(0, 1, 0),
    Vector3d(0, -1, 0)
];

/// 3d array[+-size, +-size, +-size] of T
struct Array3d(T) {
    int _size;
    int _sizeBits;
    T[] _cells;
    void reset(int size) {
        if (size == 0) {
            // just clear storage
            _cells = null;
            _size = 0;
            _sizeBits = 0;
            return;
        }
        _size = size;
        _sizeBits = bitsFor(size) + 1;
        int arraySize = 1 << (_sizeBits * 3);
        if (_cells.length < arraySize)
            _cells.length = arraySize;
        foreach(ref cell; _cells)
            cell = T.init;
    }
    ref T opIndex(int x, int y, int z) {
        int index = (x + _size) + ((y + _size) << _sizeBits) + ((z + _size) << (_sizeBits + _sizeBits));
        return _cells[index];
    }
    T * ptr(int x, int y, int z) {
        int index = (x + _size) + ((y + _size) << _sizeBits) + ((z + _size) << (_sizeBits + _sizeBits));
        return &_cells[index];
    }
}

