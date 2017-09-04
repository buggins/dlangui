module dminer.core.chunk;

import dminer.core.minetypes;
import dminer.core.blocks;
import dminer.core.world;
import dlangui.graphics.scene.mesh;


version = FAST_VISIBILITY_PATH;

// Y range: 0..CHUNK_DY-1
immutable int CHUNK_DY = 128;

//immutable int CHUNKS_Y = CHUNK_DY >> 3; // actually, it's not limited

immutable int CHUNKS_BITS_X = 9;
immutable int CHUNKS_BITS_Z = 9;
immutable int CHUNKS_X = (1 << CHUNKS_BITS_X); // X range: -CHUNKS_X*8 .. CHUNKS_X*8
immutable int CHUNKS_Z = (1 << CHUNKS_BITS_Z); // Z range: -CHUNKS_Z*8 .. CHUNKS_Z*8
immutable int CHUNKS_X_MASK = (CHUNKS_X << 1) - 1;
immutable int CHUNKS_Z_MASK = (CHUNKS_Z << 1) - 1;

version = SmallChunksGC;

interface CellVisitor {
    //void newDirection(ref Position camPosition);
    //void visitFace(World world, ref Position camPosition, Vector3d pos, cell_t cell, Dir face);
    void visit(World world, ref Position camPosition, Vector3d pos, cell_t cell, int visibleFaces);
}

interface ChunkVisitor {
    bool visit(World world, SmallChunk * chunk);
}

// vertical stack of chunks with same X, Z, and different Y
struct ChunkStack {
    protected int _minChunkY;
    protected int _chunkCount;
    version (SmallChunksGC) {
        protected SmallChunk * [] _chunks;
    } else {
        protected SmallChunk ** _chunks;
    }
    /// get chunk from stack by chunk Y index
    SmallChunk * get(int chunkY) {
        int idx = chunkY - _minChunkY;
        if (idx < 0 || idx >= _chunkCount)
            return null;
        return _chunks[idx];
    }
    @property int topNonEmptyY() {
        return ((_minChunkY + _chunkCount) << 3) - 1;
    }
    void set(int chunkY, SmallChunk * item) {
        int idx = chunkY - _minChunkY;
        if (idx >= 0 && idx < _chunkCount) {
            if (_chunks[idx]) {
                if (_chunks[idx] is item)
                    return;
                _chunks[idx].release;
            }
            _chunks[idx] = item;
            return;
        } else if (!_chunkCount) {
            // need to reallocate
            // initial allocation
            _minChunkY = chunkY;
            _chunkCount = 1;
            _chunks = allocChunks(1);
            _chunks[0] = item;
        } else {
            // need to reallocate
            // realloc
            int newMinY;
            int newChunkCount;
            if (chunkY < _minChunkY) {
                newMinY = chunkY;
                newChunkCount = _minChunkY + _chunkCount - newMinY;
            } else {
                newMinY = _minChunkY;
                newChunkCount = chunkY - _minChunkY + 1;
            }
            SmallChunk *[] newChunks = allocChunks(newChunkCount);
            // copy old data
            for(int i = 0; i < _chunkCount; i++)
                newChunks[i + _minChunkY - newMinY] = _chunks[i];
            newChunks[chunkY - newMinY] = item;
            freeChunks(_chunks);
            _chunkCount = newChunkCount;
            _minChunkY = newMinY;
            _chunks = newChunks;
        }
    }
    version (SmallChunksGC) {
        private SmallChunk* [] allocChunks(int len) {
            if (len <= 0)
                return null;
            SmallChunk* [] res = new SmallChunk* [len];
            return res;
        }
        private void freeChunks(ref SmallChunk *[] chunks) {
            if (chunks) {
                destroy(chunks);
                chunks = null;
            }
        }
    } else {
        private SmallChunk ** allocChunks(int len) {
            if (len <= 0)
                return null;
            import core.stdc.stdlib : malloc;
            SmallChunk ** res = cast(SmallChunk **) malloc(len * (SmallChunk *).sizeof);
            for(int i = 0; i < len; i++)
                res[i] = null;
            return res;
        }
        private void freeChunks(ref SmallChunk ** chunks) {
            if (chunks) {
                import core.stdc.stdlib : free;
                free(chunks);
                chunks = null;
            }
        }
    }
    void clear() {
        if (_chunkCount) {
            for(int i = 0; i < _chunkCount; i++) {
                _chunks[i].release;
            }
            freeChunks(_chunks);
        }
        _chunks = null;
        _chunkCount = 0;
        _minChunkY = -1;
    }
    ~this() {
        clear();
    }
}

/// 8x8x8 chunk
struct SmallChunk {
    protected cell_t[8*8*8] cells; // 512 bytes
    protected ubyte[8*8*8] sunlight; // 512 bytes
    protected ulong[8] opaquePlanesX; // 64 bytes WEST to EAST
    protected ulong[8] opaquePlanesY; // 64 bytes DOWN to UP
    protected ulong[8] opaquePlanesZ; // 64 bytes NORTH to SOUTH
    protected ulong[8] visiblePlanesX; // 64 bytes WEST to EAST
    protected ulong[8] visiblePlanesY; // 64 bytes DOWN to UP
    protected ulong[8] visiblePlanesZ; // 64 bytes NORTH to SOUTH
    protected ulong[8] canPassPlanesX; // 64 bytes WEST to EAST
    protected ulong[8] canPassPlanesY; // 64 bytes DOWN to UP
    protected ulong[8] canPassPlanesZ; // 64 bytes NORTH to SOUTH

    protected ubyte[6] canPassFromTo; // index is FROM direction, ubyte is DirMask of TO direction; 1 means can pass FROM .. TO
    //ulong[6][6] canPassFromTo; // 288 bytes
    SmallChunk * [6] nearChunks;
    protected Vector3d _pos;
    private Mesh _minerMesh;
    protected bool dirty;
    protected bool dirtyMesh = true;
    protected bool empty;
    protected bool visible;
    protected bool dirtyVisible;


    version (SmallChunksGC) {
        static SmallChunk * alloc(int x, int y, int z) {
            SmallChunk * res = new SmallChunk();
            res._pos.x = x & (~7);
            res._pos.y = y & (~7);
            res._pos.z = z & (~7);
            return res;
        }
        void release() {
            destroy(this);
        }

    } else {
        static SmallChunk * alloc(int x, int y, int z) nothrow @nogc {
            import core.stdc.stdlib : malloc;
            SmallChunk * res = cast(SmallChunk *)malloc(SmallChunk.sizeof);
            *res = SmallChunk.init;
            res._pos.x = x & (~7);
            res._pos.y = y & (~7);
            res._pos.z = z & (~7);
            return res;
        }
        void release() {
            if (!(&this))
                return;
            compact();
            import core.stdc.stdlib : free;
            free(&this);
        }

    }

    /// return chunk position in world (aligned to chunk origin)
    @property ref const(Vector3d) position() {
        return _pos;
    }

    /// returns true if chunk contains any visible faces
    @property bool hasVisibleFaces() {
        if (dirty)
            generateMasks();
        if (dirtyVisible) {
            dirtyVisible = false;
            ubyte[64*8] visibleFaceFlags;
            visible = findVisibleFaces(visibleFaceFlags) > 0;
        }
        return visible;
    }

    /// destroys mesh
    void compact() {
        if (_minerMesh) {
            destroy(_minerMesh);
            _minerMesh = null;
            dirtyMesh = true;
        }
    }

    static int calcIndex(int x, int y, int z) {
        return ((((y&7) << 3) | (z&7)) << 3) | (x&7);
    }
    cell_t getCell(int x, int y, int z) const {
        return cells[((((y&7) << 3) | (z&7)) << 3) | (x&7)];
    }
    void setCell(int x, int y, int z, cell_t value) {
        dirty = true;
        cells[((((y&7) << 3) | (z&7)) << 3) | (x&7)] = value;
    }
    cell_t getCellNoCheck(int x, int y, int z) const {
        return cells[(((y << 3) | z) << 3) | x];
    }
    /// get can pass mask for direction
    ulong getSideCanPassToMask(Dir dir) {
        if (dirty)
            generateMasks();
        final switch (dir) with (Dir) {
            case NORTH:
                return canPassPlanesZ[0];
            case SOUTH:
                return canPassPlanesZ[7];
            case WEST:
                return canPassPlanesX[0];
            case EAST:
                return canPassPlanesX[7];
            case UP:
                return canPassPlanesY[7];
            case DOWN:
                return canPassPlanesY[0];
        }
    }
    /// to this chunk for nearby chunk
    ulong getSideCanPassFromMask(Dir dir) {
        SmallChunk * chunk = nearChunks[dir];
        if (!chunk)
            return 0xFFFFFFFFFFFFFFFF; // can pass ALL
        return chunk.getSideCanPassToMask(opposite(dir));
    }

    void visitVisibleFaces(World world, CellVisitor visitor) {
        if (dirty)
            generateMasks();
        if (empty)
            return;
        ubyte[64*8] visibleFaceFlags;
        findVisibleFaces(visibleFaceFlags);
        int index = 0;
        for (int y = 0; y < 8; y++) {
            for (int z = 0; z < 8; z++) {
                for (int x = 0; x < 8; x++) {
                    int visibleFaces = visibleFaceFlags[index];
                    if (visibleFaces) {
                        visitor.visit(world, world.camPosition, Vector3d(_pos.x + x, _pos.y + y, _pos.z + z), cells[index], visibleFaces);
                    }
                    index++;
                }
            }
        }
    }

    /// get mesh for chunk (generate if not exists)
    Mesh getMesh(World world) {
        if (dirty)
            generateMasks();
        if (empty)
            return null;
        //if (!_minerMesh) {
        //    _minerMesh = new Mesh(VertexFormat(VertexElementType.POSITION, VertexElementType.NORMAL, VertexElementType.COLOR, VertexElementType.TEXCOORD0));
        //    dirtyMesh = true;
        //}
        Mesh oldMesh = _minerMesh;
        if (dirtyMesh) {
            if (_minerMesh)
                _minerMesh.reset();
            ubyte[64*8] visibleFaceFlags;
            findVisibleFaces(visibleFaceFlags);
            int index = 0;
            for (int y = 0; y < 8; y++) {
                for (int z = 0; z < 8; z++) {
                    for (int x = 0; x < 8; x++) {
                        int visibleFaces = visibleFaceFlags[index];
                        if (visibleFaces) {

                            if (!_minerMesh) {
                                _minerMesh = new Mesh(VertexFormat(VertexElementType.POSITION, VertexElementType.NORMAL, VertexElementType.COLOR, VertexElementType.TEXCOORD0));
                            }

                            BlockDef def = BLOCK_DEFS[cells[index]];
                            def.createFaces(world, world.camPosition, Vector3d(_pos.x + x, _pos.y + y, _pos.z + z), visibleFaces, _minerMesh);
                        }
                        index++;
                    }
                }
            }
            dirtyMesh = false;
        }
        if (_minerMesh && !_minerMesh.vertexCount) {
            destroy(_minerMesh);
            _minerMesh = null;
        }
        return _minerMesh;
    }

    private int findVisibleFaces(ref ubyte[64*8] visibleFaceFlags) {
        int count = 0;
        ulong[8] visibleFacesNorth;
        ulong canPass = getSideCanPassFromMask(Dir.NORTH);
        for (int i = 0; i < 8; i++) {
            visibleFacesNorth[i] = visiblePlanesZ[i] & canPass;
            canPass = canPassPlanesZ[i];
        }
        ulong[8] visibleFacesSouth;
        canPass = getSideCanPassFromMask(Dir.SOUTH);
        for (int i = 7; i >= 0; i--) {
            visibleFacesSouth[i] = visiblePlanesZ[i] & canPass;
            canPass = canPassPlanesZ[i];
        }
        ulong[8] visibleFacesWest;
        canPass = getSideCanPassFromMask(Dir.WEST);
        for (int i = 0; i < 8; i++) {
            visibleFacesWest[i] = visiblePlanesX[i] & canPass;
            canPass = canPassPlanesX[i];
        }
        //xPlanesToZplanes(visibleFacesWest);
        ulong[8] visibleFacesEast;
        canPass = getSideCanPassFromMask(Dir.EAST);
        for (int i = 7; i >= 0; i--) {
            visibleFacesEast[i] = visiblePlanesX[i] & canPass;
            canPass = canPassPlanesX[i];
        }
        ulong[8] visibleFacesUp;
        canPass = getSideCanPassFromMask(Dir.UP);
        for (int i = 7; i >= 0; i--) {
            visibleFacesUp[i] = visiblePlanesY[i] & canPass;
            canPass = canPassPlanesY[i];
        }
        ulong[8] visibleFacesDown;
        canPass = getSideCanPassFromMask(Dir.DOWN);
        for (int i = 0; i < 8; i++) {
            visibleFacesDown[i] = visiblePlanesY[i] & canPass;
            canPass = canPassPlanesY[i];
        }
        ulong xplanemask;
        ulong yplanemask;
        ulong zplanemask;
        for (int x = 0; x < 8; x++) {
            for (int y = 0; y < 8; y++) {
                for (int z = 0; z < 8; z++) {
                    xplanemask = cast(ulong)1 << ((y << 3) | z);
                    yplanemask = cast(ulong)1 << ((z << 3) | x);
                    zplanemask = cast(ulong)1 << ((y << 3) | x);
                    int visibleFaces = 0;
                    if (visibleFacesNorth[z] & zplanemask)
                        visibleFaces |= DirMask.MASK_NORTH;
                    if (visibleFacesSouth[z] & zplanemask)
                        visibleFaces |= DirMask.MASK_SOUTH;
                    if (visibleFacesWest[x] & xplanemask)
                        visibleFaces |= DirMask.MASK_WEST;
                    if (visibleFacesEast[x] & xplanemask)
                        visibleFaces |= DirMask.MASK_EAST;
                    if (visibleFacesUp[y] & yplanemask)
                        visibleFaces |= DirMask.MASK_UP;
                    if (visibleFacesDown[y] & yplanemask)
                        visibleFaces |= DirMask.MASK_DOWN;
                    visibleFaceFlags[calcIndex(x, y, z)] = cast(ubyte)visibleFaces;
                    if (visibleFaces)
                        count++;
                    //if (visibleFaces) {
                    //    visitor.visit(pos.x + x, pos.y + y, pos.z + z, getCell(x, y, z), visibleFaces);
                    //}
                }
            }
        }
        return count;
    }
    /*
      X planes (WEST EAST): z, y
         z=0  z=1  z=2  z=3  z=4  z=5  z=6  z=7
    y=0   0    1    2    3    4    5    6    7
    y=1   8    9   10   11   12   13   14   15
    y=2  16   17   18   19   29   21   22   23
    y=3  24   25   26   27   28   29   30   31
    y=4  32   33   34   35   36   37   38   39
    y=5  40   41   42   43   44   45   46   47
    y=6  48   49   50   51   52   53   54   55
    y=7  56   57   58   59   60   61   62   63

      Y planes (DOWN UP): x, z
         x=0  x=1  x=2  x=3  x=4  x=5  x=6  x=7
    z=0   0    1    2    3    4    5    6    7
    z=1   8    9   10   11   12   13   14   15
    z=2  16   17   18   19   29   21   22   23
    z=3  24   25   26   27   28   29   30   31
    z=4  32   33   34   35   36   37   38   39
    z=5  40   41   42   43   44   45   46   47
    z=6  48   49   50   51   52   53   54   55
    z=7  56   57   58   59   60   61   62   63

      Z planes (NORTH SOUTH): x, y
         x=0  x=1  x=2  x=3  x=4  x=5  x=6  x=7
    y=0   0    1    2    3    4    5    6    7
    y=1   8    9   10   11   12   13   14   15
    y=2  16   17   18   19   29   21   22   23
    y=3  24   25   26   27   28   29   30   31
    y=4  32   33   34   35   36   37   38   39
    y=5  40   41   42   43   44   45   46   47
    y=6  48   49   50   51   52   53   54   55
    y=7  56   57   58   59   60   61   62   63
    */
    private void generateMasks() {
        // x planes: z,y
        for(int x = 0; x < 8; x++) {
            ulong opaqueFlags = 0;
            ulong canPassFlags = 0;
            ulong visibleFlags = 0;
            ulong mask = 1;
            for (int y = 0; y < 8; y++) {
                for (int z = 0; z < 8; z++) {
                    cell_t cell = cells[(((y << 3) | z) << 3) | x];
                    if (BLOCK_TYPE_OPAQUE.ptr[cell])
                        opaqueFlags |= mask;
                    if (BLOCK_TYPE_CAN_PASS.ptr[cell])
                        canPassFlags |= mask;
                    if (BLOCK_TYPE_VISIBLE.ptr[cell])
                        visibleFlags |= mask;
                    mask = mask << 1;
                }
            }
            opaquePlanesX[x] = opaqueFlags;
            canPassPlanesX[x] = canPassFlags;
            visiblePlanesX[x] = visibleFlags;
        }
        // y planes : x,z
        for(int y = 0; y < 8; y++) {
            ulong opaqueFlags = 0;
            ulong canPassFlags = 0;
            ulong visibleFlags = 0;
            ulong mask = 1;
            for (int z = 0; z < 8; z++) {
                for (int x = 0; x < 8; x++) {
                    cell_t cell = cells[(((y << 3) | z) << 3) | x];
                    if (BLOCK_TYPE_OPAQUE.ptr[cell])
                        opaqueFlags |= mask;
                    if (BLOCK_TYPE_CAN_PASS.ptr[cell])
                        canPassFlags |= mask;
                    if (BLOCK_TYPE_VISIBLE.ptr[cell])
                        visibleFlags |= mask;
                    mask = mask << 1;
                }
            }
            opaquePlanesY[y] = opaqueFlags;
            canPassPlanesY[y] = canPassFlags;
            visiblePlanesY[y] = visibleFlags;
        }
        // z planes: x,y
        for(int z = 0; z < 8; z++) {
            ulong opaqueFlags = 0;
            ulong canPassFlags = 0;
            ulong visibleFlags = 0;
            ulong mask = 1;
            for (int y = 0; y < 8; y++) {
                for (int x = 0; x < 8; x++) {
                    cell_t cell = cells[(((y << 3) | z) << 3) | x];
                    if (BLOCK_TYPE_OPAQUE.ptr[cell])
                        opaqueFlags |= mask;
                    if (BLOCK_TYPE_CAN_PASS.ptr[cell])
                        canPassFlags |= mask;
                    if (BLOCK_TYPE_VISIBLE.ptr[cell])
                        visibleFlags |= mask;
                    mask = mask << 1;
                }
            }
            opaquePlanesZ[z] = opaqueFlags;
            canPassPlanesZ[z] = canPassFlags;
            visiblePlanesZ[z] = visibleFlags;
        }

        // can pass from to
        for (Dir from = Dir.min; from <= Dir.max; ++from) {
            fillCanPassFrom(from);
        }
        dirty = false;
        empty = (visiblePlanesZ[0]|visiblePlanesZ[1]|visiblePlanesZ[2]|visiblePlanesZ[3]|
                 visiblePlanesZ[4]|visiblePlanesZ[5]|visiblePlanesZ[6]|visiblePlanesZ[7]) == 0;
        dirtyVisible = !empty;
        dirtyMesh = true;
    }

    /// returns DirMask of available pass direction for specified FROM direction
    ubyte getCanPassFromFlags(Dir dirFrom) {
        return canPassFromTo[dirFrom];
    }

    protected void fillCanPassFrom(Dir dirFrom) {
        ulong[8] planes;
        ulong mask = 0xFFFFFFFFFFFFFFFFL;
        ubyte res = 0;
        final switch (dirFrom) {
            case Dir.NORTH:
                for (int i = 7; i >= 0; i--) {
                    mask = spreadZPlane(mask, canPassPlanesZ[i], DirMask.MASK_ALL);
                    if (!mask)
                        break;
                    planes[i] = mask;
                }
                if (planes[0])
                    res |= DirMask.MASK_NORTH;
                if (xPlaneFromZplanes(planes, 0))
                    res |= DirMask.MASK_WEST;
                if (xPlaneFromZplanes(planes, 7))
                    res |= DirMask.MASK_EAST;
                if (yPlaneFromZplanes(planes, 0))
                    res |= DirMask.MASK_DOWN;
                if (yPlaneFromZplanes(planes, 7))
                    res |= DirMask.MASK_UP;
                break;
            case Dir.SOUTH:
                for (int i = 0; i <= 7; i++) {
                    mask = spreadZPlane(mask, canPassPlanesZ[i], DirMask.MASK_ALL);
                    if (!mask)
                        break;
                    planes[i] = mask;
                }
                if (planes[7])
                    res |= DirMask.MASK_SOUTH;
                if (xPlaneFromZplanes(planes, 0))
                    res |= DirMask.MASK_WEST;
                if (xPlaneFromZplanes(planes, 7))
                    res |= DirMask.MASK_EAST;
                if (yPlaneFromZplanes(planes, 0))
                    res |= DirMask.MASK_DOWN;
                if (yPlaneFromZplanes(planes, 7))
                    res |= DirMask.MASK_UP;
                break;
            case Dir.WEST: // x--
                for (int i = 7; i >= 0; i--) {
                    mask = spreadXPlane(mask, canPassPlanesX[i], DirMask.MASK_ALL);
                    if (!mask)
                        break;
                    planes[i] = mask;
                }
                if (planes[0])
                    res |= DirMask.MASK_WEST;
                if (zPlaneFromXplanes(planes, 0))
                    res |= DirMask.MASK_NORTH;
                if (zPlaneFromXplanes(planes, 7))
                    res |= DirMask.MASK_SOUTH;
                if (yPlaneFromXplanes(planes, 0))
                    res |= DirMask.MASK_DOWN;
                if (yPlaneFromXplanes(planes, 7))
                    res |= DirMask.MASK_UP;
                break;
            case Dir.EAST: // x++
                for (int i = 0; i <= 7; i++) {
                    mask = spreadXPlane(mask, canPassPlanesX[i], DirMask.MASK_ALL);
                    if (!mask)
                        break;
                    planes[i] = mask;
                }
                if (planes[7])
                    res |= DirMask.MASK_EAST;
                if (zPlaneFromXplanes(planes, 0))
                    res |= DirMask.MASK_NORTH;
                if (zPlaneFromXplanes(planes, 7))
                    res |= DirMask.MASK_SOUTH;
                if (yPlaneFromXplanes(planes, 0))
                    res |= DirMask.MASK_DOWN;
                if (yPlaneFromXplanes(planes, 7))
                    res |= DirMask.MASK_UP;
                break;
            case Dir.DOWN: // y--
                for (int i = 7; i >= 0; i--) {
                    mask = spreadYPlane(mask, canPassPlanesY[i], DirMask.MASK_ALL);
                    if (!mask)
                        break;
                    planes[i] = mask;
                }
                if (planes[0])
                    res |= DirMask.MASK_DOWN;
                if (zPlaneFromYplanes(planes, 0))
                    res |= DirMask.MASK_NORTH;
                if (zPlaneFromYplanes(planes, 7))
                    res |= DirMask.MASK_SOUTH;
                if (xPlaneFromYplanes(planes, 0))
                    res |= DirMask.MASK_WEST;
                if (xPlaneFromYplanes(planes, 7))
                    res |= DirMask.MASK_EAST;
                break;
            case Dir.UP: // y--
                for (int i = 0; i <= 7; i++) {
                    mask = spreadYPlane(mask, canPassPlanesY[i], DirMask.MASK_ALL);
                    if (!mask)
                        break;
                    planes[i] = mask;
                }
                if (planes[7])
                    res |= DirMask.MASK_UP;
                if (zPlaneFromYplanes(planes, 0))
                    res |= DirMask.MASK_NORTH;
                if (zPlaneFromYplanes(planes, 7))
                    res |= DirMask.MASK_SOUTH;
                if (xPlaneFromYplanes(planes, 0))
                    res |= DirMask.MASK_WEST;
                if (xPlaneFromYplanes(planes, 7))
                    res |= DirMask.MASK_EAST;
                break;
        }
        canPassFromTo[dirFrom] = res;
    }

    static void spreadFlags(ulong src, ref ulong[8] planes, ref ulong[8] dst, int start, int end, ubyte spreadMask) {
        if (start < end) {
            for (int i = start; i <= end; ++i) {
                ulong mask = src;
                if (spreadMask & SpreadMask.SpreadLeft)
                    mask |= ((src << 1) & 0xFEFEFEFEFEFEFEFE);
                if (spreadMask & SpreadMask.SpreadRight)
                    mask |= ((src >> 1) & 0x7F7F7F7F7F7F7F7F);
                if (spreadMask & SpreadMask.SpreadUp)
                    mask |= ((src << 8) & 0xFFFFFFFFFFFFFF00);
                if (spreadMask & SpreadMask.SpreadDown)
                    mask |= ((src >> 8) & 0x00FFFFFFFFFFFFFF);
                src = planes[i] & mask;
                dst[i] = src;
            }
        } else {
            for (int i = end; i >= start; --i) {
                ulong mask = src;
                if (spreadMask & SpreadMask.SpreadLeft)
                    mask |= ((src << 1) & 0xFEFEFEFEFEFEFEFE);
                if (spreadMask & SpreadMask.SpreadRight)
                    mask |= ((src >> 1) & 0x7F7F7F7F7F7F7F7F);
                if (spreadMask & SpreadMask.SpreadUp)
                    mask |= ((src << 8) & 0xFFFFFFFFFFFFFF00);
                if (spreadMask & SpreadMask.SpreadDown)
                    mask |= ((src >> 8) & 0x00FFFFFFFFFFFFFF);
                src = planes[i] & mask;
                dst[i] = src;
            }
        }
    }

    ulong canPass(ulong mask, Dir dir, Dir to, ubyte dirMask = DirMask.MASK_ALL) {
        ulong[8] planes;
        ubyte spreadMask = DIR_AND_MASK_TO_SPREAD_FLAGS[dirMask][dir];
        final switch(dir) with (Dir) {
            case NORTH:
                spreadFlags(mask, canPassPlanesZ, planes, 0, 7, spreadMask);
                final switch (to) {
                    case NORTH:
                        return planes[7];
                    case SOUTH:
                        return planes[0];
                    case EAST:
                        return slicePlane7(planes);
                    case WEST:
                        return slicePlane0(planes);
                    case UP:
                        return slicePlane7(planes);
                    case DOWN:
                        return slicePlane0(planes);
                }
            case SOUTH:
                spreadFlags(mask, canPassPlanesZ, planes, 7, 0, spreadMask);
                final switch (to) {
                    case NORTH:
                        return planes[7];
                    case SOUTH:
                        return planes[0];
                    case EAST:
                        return slicePlane7(planes);
                    case WEST:
                        return slicePlane0(planes);
                    case UP:
                        return slicePlane7(planes);
                    case DOWN:
                        return slicePlane0(planes);
                }
            case WEST:
                spreadFlags(mask, canPassPlanesX, planes, 7, 0, spreadMask);
                final switch (to) {
                    case NORTH:
                        return slicePlane7(planes);
                    case SOUTH:
                        return slicePlane0(planes);
                    case EAST:
                        return planes[7];
                    case WEST:
                        return planes[0];
                    case UP:
                        return slicePlane7(planes);
                    case DOWN:
                        return slicePlane0(planes);
                }
            case EAST:
                spreadFlags(mask, canPassPlanesX, planes, 0, 7, spreadMask);
                final switch (to) {
                    case NORTH:
                        return slicePlane7(planes);
                    case SOUTH:
                        return slicePlane0(planes);
                    case EAST:
                        return planes[7];
                    case WEST:
                        return planes[0];
                    case UP:
                        return slicePlane7(planes);
                    case DOWN:
                        return slicePlane0(planes);
                }
            case UP:
                spreadFlags(mask, canPassPlanesY, planes, 0, 7, spreadMask);
                final switch (to) {
                    case NORTH:
                        return slicePlane7(planes);
                    case SOUTH:
                        return slicePlane0(planes);
                    case EAST:
                        return slicePlane7(planes);
                    case WEST:
                        return slicePlane0(planes);
                    case UP:
                        return planes[7];
                    case DOWN:
                        return planes[0];
                }
            case DOWN:
                spreadFlags(mask, canPassPlanesY, planes, 7, 0, spreadMask);
                final switch (to) {
                    case NORTH:
                        return slicePlane7(planes);
                    case SOUTH:
                        return slicePlane0(planes);
                    case EAST:
                        return slicePlane7(planes);
                    case WEST:
                        return slicePlane0(planes);
                    case UP:
                        return planes[7];
                    case DOWN:
                        return planes[0];
                }
        }
    }

    static ulong slicePlane0(ref ulong[8] planes) {
        ulong res = 0;
        for (int i = 0; i < 8; i++) {
            res |= (planes[i] & 0x0101010101010101) << i;
        }
        return res;
    }

    static ulong slicePlane7(ref ulong[8] planes) {
        ulong res = 0;
        for (int i = 0; i < 8; i++) {
            res |= (planes[i] & 0x8080808080808080) >> (7 - i);
        }
        return res;
    }
}

enum SpreadMask : ubyte {
    SpreadLeft = 1,
    SpreadRight = 2,
    SpreadUp = 4,
    SpreadDown = 8,
}

ubyte dirMaskToSpreadMask(Dir dir, ubyte dirMask) {
    ubyte res = 0;
    final switch (dir) with (Dir) {
        case NORTH: // from north
        case SOUTH:
            res |= (dirMask & DirMask.MASK_UP) ? SpreadMask.SpreadUp : 0;
            res |= (dirMask & DirMask.MASK_DOWN) ? SpreadMask.SpreadDown : 0;
            res |= (dirMask & DirMask.MASK_EAST) ? SpreadMask.SpreadLeft : 0;
            res |= (dirMask & DirMask.MASK_WEST) ? SpreadMask.SpreadRight : 0;
            break;
        case WEST:
        case EAST:
            res |= (dirMask & DirMask.MASK_UP) ? SpreadMask.SpreadUp : 0;
            res |= (dirMask & DirMask.MASK_DOWN) ? SpreadMask.SpreadDown : 0;
            res |= (dirMask & DirMask.MASK_NORTH) ? SpreadMask.SpreadLeft : 0;
            res |= (dirMask & DirMask.MASK_SOUTH) ? SpreadMask.SpreadRight : 0;
            break;
        case UP:
        case DOWN:
            res |= (dirMask & DirMask.MASK_EAST) ? SpreadMask.SpreadLeft : 0;
            res |= (dirMask & DirMask.MASK_WEST) ? SpreadMask.SpreadRight : 0;
            res |= (dirMask & DirMask.MASK_NORTH) ? SpreadMask.SpreadUp : 0;
            res |= (dirMask & DirMask.MASK_SOUTH) ? SpreadMask.SpreadDown : 0;
            break;
    }
    return res;
}

// immutable SpreadMask[DirMask][Dir] DIR_AND_MASK_TO_SPREAD_FLAGS
mixin(generateDirMaskSource());

string generateDirMaskSource() {
    import std.conv : to;
    char[] src;
    src ~= "immutable ubyte[64][6] DIR_AND_MASK_TO_SPREAD_FLAGS = [\n";
    for (Dir from = Dir.min; from <= Dir.max; from++) {
        if (from)
            src ~= ",\n";
        src ~= "    // ";
        src ~= to!string(from);
        src ~= "\n    [";
        for (ubyte mask = 0; mask < 64; mask++) {
            ubyte res = dirMaskToSpreadMask(from, mask);
            if (mask)
                src ~= ", ";
            if (mask == 32)
                src ~= "\n     ";
            src ~= to!string(res);
        }
        src ~= "]";
    }
    src ~= "\n];\n";
    return src.dup;
}

void testDirMaskToSpreadMask() {
    import dlangui.core.logger;
    for (Dir from = Dir.min; from <= Dir.max; from++) {
        for (ubyte mask = 0; mask < 64; mask++) {
            ubyte res = dirMaskToSpreadMask(from, mask);
            char[]buf;
            buf ~= "[";
            if (mask & DirMask.MASK_NORTH) buf ~= " NORTH";
            if (mask & DirMask.MASK_SOUTH) buf ~= " SOUTH";
            if (mask & DirMask.MASK_WEST) buf ~= " WEST";
            if (mask & DirMask.MASK_EAST) buf ~= " EAST";
            if (mask & DirMask.MASK_UP) buf ~= " UP";
            if (mask & DirMask.MASK_DOWN) buf ~= " DOWN";
            buf ~= " ] => (";
            if (res & SpreadMask.SpreadLeft) buf ~= " SpreadLeft";
            if (res & SpreadMask.SpreadRight) buf ~= " SpreadRight";
            if (res & SpreadMask.SpreadUp) buf ~= " SpreadUp";
            if (res & SpreadMask.SpreadDown) buf ~= " SpreadDown";
            buf ~= " )";
            Log.d("dirMaskToSpreadMask ", from, "  ", buf);
        }
    }
    Log.d("Source: \n", generateDirMaskSource());
}


/// mask for available spread direction for chunk dest visited from camera chunk position origin
ubyte calcSpreadMask(Vector3d dest, Vector3d origin) {
    ubyte res = 0;
    if (dest.x < origin.x) {
        res |= DirMask.MASK_WEST;
    } else if (dest.x > origin.x) {
        res |= DirMask.MASK_EAST;
    } else {
        res |= DirMask.MASK_WEST | DirMask.MASK_EAST;
    }
    if (dest.y < origin.y) {
        res |= DirMask.MASK_DOWN;
    } else if (dest.y > origin.y) {
        res |= DirMask.MASK_UP;
    } else {
        res |= DirMask.MASK_DOWN | DirMask.MASK_UP;
    }
    if (dest.z < origin.z) {
        res |= DirMask.MASK_NORTH;
    } else if (dest.z > origin.z) {
        res |= DirMask.MASK_SOUTH;
    } else {
        res |= DirMask.MASK_NORTH | DirMask.MASK_SOUTH;
    }
    return res;
}

/*
      Z planes (NORTH SOUTH): x, y
         x=0  x=1  x=2  x=3  x=4  x=5  x=6  x=7
    y=0   0    1    2    3    4    5    6    7
    y=1   8    9   10   11   12   13   14   15
    y=2  16   17   18   19   29   21   22   23
    y=3  24   25   26   27   28   29   30   31
    y=4  32   33   34   35   36   37   38   39
    y=5  40   41   42   43   44   45   46   47
    y=6  48   49   50   51   52   53   54   55
    y=7  56   57   58   59   60   61   62   63
*/
ulong spreadZPlane(ulong mask, ulong canPassMask, ubyte spreadToDirMask) {
    ulong res = mask & canPassMask;
    if (!res)
        return 0;
    if (spreadToDirMask & DirMask.MASK_WEST) { // x--
        res |= ((mask & 0xFEFEFEFEFEFEFEFEL) >> 1) & canPassMask;
    }
    if (spreadToDirMask & DirMask.MASK_EAST) { // x++
        res |= ((mask & 0x7f7f7f7f7f7f7f7fL) << 1) & canPassMask;
    }
    if (spreadToDirMask & DirMask.MASK_UP) { // y++
        res |= ((mask & 0x00ffffffffffffffL) << 8) & canPassMask;
    }
    if (spreadToDirMask & DirMask.MASK_DOWN) { // y--
        res |= ((mask & 0xffffffffffffff00L) >> 8) & canPassMask;
    }
    return res;
}

    /*
      X planes (WEST EAST): z, y
         z=0  z=1  z=2  z=3  z=4  z=5  z=6  z=7
    y=0   0    1    2    3    4    5    6    7
    y=1   8    9   10   11   12   13   14   15
    y=2  16   17   18   19   29   21   22   23
    y=3  24   25   26   27   28   29   30   31
    y=4  32   33   34   35   36   37   38   39
    y=5  40   41   42   43   44   45   46   47
    y=6  48   49   50   51   52   53   54   55
    y=7  56   57   58   59   60   61   62   63
    */
ulong spreadXPlane(ulong mask, ulong canPassMask, ubyte spreadToDirMask) {
    ulong res = mask & canPassMask;
    if (!res)
        return 0;
    if (spreadToDirMask & DirMask.MASK_NORTH) { // z--
        res |= ((mask & 0xFEFEFEFEFEFEFEFEL) >> 1) & canPassMask;
    }
    if (spreadToDirMask & DirMask.MASK_SOUTH) { // z++
        res |= ((mask & 0x7f7f7f7f7f7f7f7fL) << 1) & canPassMask;
    }
    if (spreadToDirMask & DirMask.MASK_UP) { // y++
        res |= ((mask & 0x00ffffffffffffffL) << 8) & canPassMask;
    }
    if (spreadToDirMask & DirMask.MASK_DOWN) { // y--
        res |= ((mask & 0xffffffffffffff00L) >> 8) & canPassMask;
    }
    return res;
}

    /*

      Y planes (DOWN UP): x, z
         x=0  x=1  x=2  x=3  x=4  x=5  x=6  x=7
    z=0   0    1    2    3    4    5    6    7
    z=1   8    9   10   11   12   13   14   15
    z=2  16   17   18   19   29   21   22   23
    z=3  24   25   26   27   28   29   30   31
    z=4  32   33   34   35   36   37   38   39
    z=5  40   41   42   43   44   45   46   47
    z=6  48   49   50   51   52   53   54   55
    z=7  56   57   58   59   60   61   62   63

    */

ulong spreadYPlane(ulong mask, ulong canPassMask, ubyte spreadToDirMask) {
    ulong res = mask & canPassMask;
    if (!res)
        return 0;
    if (spreadToDirMask & DirMask.MASK_WEST) { // x--
        res |= ((mask & 0xFEFEFEFEFEFEFEFEL) >> 1) & canPassMask;
    }
    if (spreadToDirMask & DirMask.MASK_EAST) { // x++
        res |= ((mask & 0x7f7f7f7f7f7f7f7fL) << 1) & canPassMask;
    }
    if (spreadToDirMask & DirMask.MASK_SOUTH) { // z++
        res |= ((mask & 0x00ffffffffffffffL) << 8) & canPassMask;
    }
    if (spreadToDirMask & DirMask.MASK_NORTH) { // z--
        res |= ((mask & 0xffffffffffffff00L) >> 8) & canPassMask;
    }
    return res;
}

    /*
            Z planes (NORTH SOUTH): x, y
                x=0  x=1  x=2  x=3  x=4  x=5  x=6  x=7
        y=0   0    1    2    3    4    5    6    7
        y=1   8    9   10   11   12   13   14   15
        y=2  16   17   18   19   29   21   22   23
        y=3  24   25   26   27   28   29   30   31
        y=4  32   33   34   35   36   37   38   39
        y=5  40   41   42   43   44   45   46   47
        y=6  48   49   50   51   52   53   54   55
        y=7  56   57   58   59   60   61   62   63

          X planes (WEST EAST): z, y
             z=0  z=1  z=2  z=3  z=4  z=5  z=6  z=7
        y=0   0    1    2    3    4    5    6    7
        y=1   8    9   10   11   12   13   14   15
        y=2  16   17   18   19   29   21   22   23
        y=3  24   25   26   27   28   29   30   31
        y=4  32   33   34   35   36   37   38   39
        y=5  40   41   42   43   44   45   46   47
        y=6  48   49   50   51   52   53   54   55
        y=7  56   57   58   59   60   61   62   63
    */
ulong xPlaneFromZplanes(ref ulong[8] planes, int x) {
    ulong res = 0;
    for (int z = 0; z < 8; z++) {
        ulong n = planes[z]; // one plane == z
        n = n >> x; // move to low bit
        n &=  0x0101010101010101L;
        n = n << z; // move to Z bit
        res |= n;
    }
    return res;
}

    /*
            Z planes (NORTH SOUTH): x, y
             x=0  x=1  x=2  x=3  x=4  x=5  x=6  x=7
        y=0   0    1    2    3    4    5    6    7
        y=1   8    9   10   11   12   13   14   15
        y=2  16   17   18   19   29   21   22   23
        y=3  24   25   26   27   28   29   30   31
        y=4  32   33   34   35   36   37   38   39
        y=5  40   41   42   43   44   45   46   47
        y=6  48   49   50   51   52   53   54   55
        y=7  56   57   58   59   60   61   62   63

          Y planes (DOWN UP): x, z
             x=0  x=1  x=2  x=3  x=4  x=5  x=6  x=7
        z=0   0    1    2    3    4    5    6    7
        z=1   8    9   10   11   12   13   14   15
        z=2  16   17   18   19   29   21   22   23
        z=3  24   25   26   27   28   29   30   31
        z=4  32   33   34   35   36   37   38   39
        z=5  40   41   42   43   44   45   46   47
        z=6  48   49   50   51   52   53   54   55
        z=7  56   57   58   59   60   61   62   63
    */
ulong yPlaneFromZplanes(ref ulong[8] planes, int y) {
    ulong res = 0;
    for (int z = 0; z < 8; z++) {
        ulong n = planes[z]; // one plane == z
        n = n >> (y * 8); // move to low byte
        n &= 0xFF;
        n = n << (z * 8); // move to Z position
        res |= n;
    }
    return res;
}

/*
X planes (WEST EAST): z, y
    z=0  z=1  z=2  z=3  z=4  z=5  z=6  z=7
y=0   0    1    2    3    4    5    6    7
y=1   8    9   10   11   12   13   14   15
y=2  16   17   18   19   29   21   22   23
y=3  24   25   26   27   28   29   30   31
y=4  32   33   34   35   36   37   38   39
y=5  40   41   42   43   44   45   46   47
y=6  48   49   50   51   52   53   54   55
y=7  56   57   58   59   60   61   62   63

Z planes (NORTH SOUTH): x, y
    x=0  x=1  x=2  x=3  x=4  x=5  x=6  x=7
y=0   0    1    2    3    4    5    6    7
y=1   8    9   10   11   12   13   14   15
y=2  16   17   18   19   29   21   22   23
y=3  24   25   26   27   28   29   30   31
y=4  32   33   34   35   36   37   38   39
y=5  40   41   42   43   44   45   46   47
y=6  48   49   50   51   52   53   54   55
y=7  56   57   58   59   60   61   62   63

*/
ulong zPlaneFromXplanes(ref ulong[8] planes, int z) {
    ulong res = 0;
    for (int x = 0; x < 8; x++) {
        ulong n = planes[x]; // one plane == z
        n = n >> z; // move to low bit
        n &=  0x0101010101010101L;
        n = n << x; // move to X bit
        res |= n;
    }
    return res;
}

/*
X planes (WEST EAST): z, y
    z=0  z=1  z=2  z=3  z=4  z=5  z=6  z=7
y=0   0    1    2    3    4    5    6    7
y=1   8    9   10   11   12   13   14   15
y=2  16   17   18   19   29   21   22   23
y=3  24   25   26   27   28   29   30   31
y=4  32   33   34   35   36   37   38   39
y=5  40   41   42   43   44   45   46   47
y=6  48   49   50   51   52   53   54   55
y=7  56   57   58   59   60   61   62   63

Y planes (DOWN UP): x, z
    x=0  x=1  x=2  x=3  x=4  x=5  x=6  x=7
z=0   0    1    2    3    4    5    6    7
z=1   8    9   10   11   12   13   14   15
z=2  16   17   18   19   29   21   22   23
z=3  24   25   26   27   28   29   30   31
z=4  32   33   34   35   36   37   38   39
z=5  40   41   42   43   44   45   46   47
z=6  48   49   50   51   52   53   54   55
z=7  56   57   58   59   60   61   62   63
*/
// move bit 0 -> 0, 1->8, 2->16, 3->24, .. 7->56
ulong flipBitsLeft(ulong n) {
    n &=  0xFFL; //
    return ((n&1) | ((n&2) << 7) | ((n&4) << 14) | ((n&8) << 21) | ((n&16) << 28) | ((n&32) << 35) | ((n&64) << 42) | ((n&128)<< 49)) & 0x0101010101010101L;
}
ulong yPlaneFromXplanes(ref ulong[8] planes, int y) {
    ulong res = 0;
    for (int x = 0; x < 8; x++) {
        ulong n = planes[x]; // one plane == z
        n = n >> (y * 8); // move to low byte
        n = flipBitsLeft(n);
        n = n << (x); // move to x position
        res |= n;
    }
    return res;
}

/*
   Y planes (DOWN UP): x, z
    x=0  x=1  x=2  x=3  x=4  x=5  x=6  x=7
z=0   0    1    2    3    4    5    6    7
z=1   8    9   10   11   12   13   14   15
z=2  16   17   18   19   29   21   22   23
z=3  24   25   26   27   28   29   30   31
z=4  32   33   34   35   36   37   38   39
z=5  40   41   42   43   44   45   46   47
z=6  48   49   50   51   52   53   54   55
z=7  56   57   58   59   60   61   62   63

Z planes (NORTH SOUTH): x, y
    x=0  x=1  x=2  x=3  x=4  x=5  x=6  x=7
y=0   0    1    2    3    4    5    6    7
y=1   8    9   10   11   12   13   14   15
y=2  16   17   18   19   29   21   22   23
y=3  24   25   26   27   28   29   30   31
y=4  32   33   34   35   36   37   38   39
y=5  40   41   42   43   44   45   46   47
y=6  48   49   50   51   52   53   54   55
y=7  56   57   58   59   60   61   62   63

*/
ulong zPlaneFromYplanes(ref ulong[8] planes, int z) {
    ulong res = 0;
    for (int y = 0; y < 8; y++) {
        ulong n = planes[y]; // one plane == z
        n = n >> (z * 8); // move to low byte
        n &= 0xFF;
        n = n << (y * 8); // move to Z position
        res |= n;
    }
    return res;
}

/*
Y planes (DOWN UP): x, z
    x=0  x=1  x=2  x=3  x=4  x=5  x=6  x=7
z=0   0    1    2    3    4    5    6    7
z=1   8    9   10   11   12   13   14   15
z=2  16   17   18   19   29   21   22   23
z=3  24   25   26   27   28   29   30   31
z=4  32   33   34   35   36   37   38   39
z=5  40   41   42   43   44   45   46   47
z=6  48   49   50   51   52   53   54   55
z=7  56   57   58   59   60   61   62   63

X planes (WEST EAST): z, y
    z=0  z=1  z=2  z=3  z=4  z=5  z=6  z=7
y=0   0    1    2    3    4    5    6    7
y=1   8    9   10   11   12   13   14   15
y=2  16   17   18   19   29   21   22   23
y=3  24   25   26   27   28   29   30   31
y=4  32   33   34   35   36   37   38   39
y=5  40   41   42   43   44   45   46   47
y=6  48   49   50   51   52   53   54   55
y=7  56   57   58   59   60   61   62   63
*/
// move bit 0 -> 0, 8->1, 16->2, 24->3, .. 56->7
ulong flipBitsRight(ulong n) {
    n &=  0x0101010101010101L; //
    return (n | (n >> 7) | (n >> 14) | (n >> 21) | (n >> 28) | (n >> 35) | (n >> 42) | (n >> 49)) & 255;
}
ulong xPlaneFromYplanes(ref ulong[8] planes, int x) {
    ulong res = 0;
    for (int y = 0; y < 8; y++) {
        ulong n = planes[y]; // one plane == y
        n = n >> x; // move to low bit
        n = flipBitsRight(n);
        n = n << (y * 8); // move to y byte
        res |= n;
    }
    return res;
}

struct Planes(immutable Dir dir) {
    ulong[8] planes;
    alias planes this;
    bool opIndex(int x, int y, int z) {
        static if (dir == Dir.NORTH || dir == Dir.SOUTH) {
            // Z planes
            ulong zplanemask = cast(ulong)1 << ((y << 3) | x);
            return (planes[z] & zplanemask) != 0;
        } else static if (dir == Dir.WEST || dir == Dir.EAST) {
            // X planes
            ulong xplanemask = cast(ulong)1 << ((y << 3) | z);
            return (planes[x] & xplanemask) != 0;
        } else {
            // Y planes
            ulong yplanemask = cast(ulong)1 << ((z << 3) | x);
            return (planes[y] & yplanemask) != 0;
        }
    }
    void opIndexAssign(bool value, int x, int y, int z) {
        static if (dir == Dir.NORTH || dir == Dir.SOUTH) {
            // Z planes
            ulong zplanemask = cast(ulong)1 << ((y << 3) | x);
            if (value)
                planes[z] |= zplanemask;
            else
                planes[z] &= ~zplanemask;
        } else static if (dir == Dir.WEST || dir == Dir.EAST) {
            // X planes
            ulong xplanemask = cast(ulong)1 << ((y << 3) | z);
            if (value)
                planes[x] |= xplanemask;
            else
                planes[x] &= ~xplanemask;
        } else {
            // Y planes
            ulong yplanemask = cast(ulong)1 << ((z << 3) | x);
            if (value)
                planes[y] |= yplanemask;
            else
                planes[y] &= ~yplanemask;
        }
    }
}

struct AllPlanes {
    Planes!(Dir.NORTH) zplanes;
    Planes!(Dir.WEST) xplanes;
    Planes!(Dir.DOWN) yplanes;
    bool opIndex(int x, int y, int z) {
        bool vx = xplanes[x, y, z];
        bool vy = yplanes[x, y, z];
        bool vz = zplanes[x, y, z];
        assert(vx == vy && vx == vz);
        return vx;
    }
    void opIndexAssign(bool value, int x, int y, int z) {
        xplanes[x, y, z] = value;
        yplanes[x, y, z] = value;
        zplanes[x, y, z] = value;
    }
    void testAllPlanesEqual() {
        for (int x = 0; x < 8; x++)
            for (int y = 0; y < 8; y++)
                for (int z = 0; z < 8; z++)
                    opIndex(x, y, z);
    }
    void testPlanesExtract() {

        testAllPlanesEqual();

        ulong n, m;

        n = xPlaneFromYplanes(yplanes, 0);
        m = xplanes.planes[0];
        assert(n == m);

        for (int i = 0; i < 8; i++) {
            n = xPlaneFromYplanes(yplanes, i);
            assert(n == xplanes.planes[i]);
            n = zPlaneFromYplanes(yplanes, i);
            assert(n == zplanes.planes[i]);
            n = xPlaneFromZplanes(zplanes, i);
            assert(n == xplanes.planes[i]);
            n = yPlaneFromZplanes(zplanes, i);
            assert(n == yplanes.planes[i]);
            n = zPlaneFromXplanes(xplanes, i);
            assert(n == zplanes.planes[i]);
            n = yPlaneFromXplanes(xplanes, i);
            assert(n == yplanes.planes[i]);
        }
    }
}

void testPlanes() {
    AllPlanes v;
    v[0, 1, 2] = true;
    v.testPlanesExtract();
    v[5, 0, 6] = true;
    v[7, 2, 0] = true;
    v[6, 7, 7] = true;
    v[3, 3, 7] = true;
    v[6, 5, 3] = true;
    v.testPlanesExtract();
    v[5, 0, 6] = true;
    v[3, 4, 5] = true;
    v[6, 2, 3] = true;
    v[1, 7, 6] = true;
    v.testPlanesExtract();
    v[3, 4, 5] = false;
    v[6, 2, 3] = false;
    v.testPlanesExtract();
}

version(FAST_VISIBILITY_PATH) {
    struct VisibilityCheckChunk {
        SmallChunk * chunk;
        ulong[6] maskFrom;
        ulong[6] maskTo;
        Vector3d pos;
        ubyte visitedFromDirMask;
        ubyte spreadToDirMask;
        void setMask(ulong mask, Dir fromDir) {
            maskFrom[fromDir] |= mask;
            visitedFromDirMask |= (1 << fromDir);
        }


        void traceFrom(Dir fromDir) {
            ubyte m = chunk ? chunk.getCanPassFromFlags(fromDir) : DirMask.MASK_ALL;
            for (ubyte dir = 0; dir < 6; dir++) {
                ubyte flag = cast(ubyte)(1 << dir);
                if (flag & spreadToDirMask)
                    if (m & flag)
                        maskTo[dir] |= 0xFFFFFFFFFFFFFFFFL;
            }

        }

        void tracePaths() {
            for (Dir dirFrom = Dir.min; dirFrom <= Dir.max; dirFrom++) {
                if ((visitedFromDirMask & (1 << dirFrom)))
                    traceFrom(dirFrom);
            }
        }
    }
} else {
    struct VisibilityCheckChunk {
        SmallChunk * chunk;
        ulong[6] maskFrom;
        ulong[6] maskTo;
        Vector3d pos;
        ubyte visitedFromDirMask;
        ubyte spreadToDirMask;
        void setMask(ulong mask, Dir fromDir) {
            maskFrom[fromDir] |= mask;
            visitedFromDirMask |= (1 << fromDir);
        }
        /*
        Z planes (NORTH SOUTH): x, y
        x=0  x=1  x=2  x=3  x=4  x=5  x=6  x=7
        y=0   0    1    2    3    4    5    6    7
        y=1   8    9   10   11   12   13   14   15
        y=2  16   17   18   19   29   21   22   23
        y=3  24   25   26   27   28   29   30   31
        y=4  32   33   34   35   36   37   38   39
        y=5  40   41   42   43   44   45   46   47
        y=6  48   49   50   51   52   53   54   55
        y=7  56   57   58   59   60   61   62   63
        */
        void applyZPlanesTrace(ref ulong[8] planes) {
            if (spreadToDirMask & DirMask.MASK_WEST) { // x--
                // X planes (WEST EAST): z, y
                maskTo[Dir.WEST] |= xPlaneFromZplanes(planes, 0);
            }
            if (spreadToDirMask & DirMask.MASK_EAST) { // x++
                // X planes (WEST EAST): z, y
                maskTo[Dir.EAST] |= xPlaneFromZplanes(planes, 7);
            }
            if (spreadToDirMask & DirMask.MASK_DOWN) { // y--
                // Y planes (DOWN UP): x, z
                maskTo[Dir.DOWN] |= yPlaneFromZplanes(planes, 0);
            }
            if (spreadToDirMask & DirMask.MASK_UP) { // y++
                // Y planes (DOWN UP): x, z
                maskTo[Dir.UP] |= yPlaneFromZplanes(planes, 7);
            }
        }

        void applyYPlanesTrace(ref ulong[8] planes) {
            if (spreadToDirMask & DirMask.MASK_WEST) { // x--
                // X planes (WEST EAST): z, y
                maskTo[Dir.WEST] |= xPlaneFromYplanes(planes, 0);
            }
            if (spreadToDirMask & DirMask.MASK_EAST) { // x++
                // X planes (WEST EAST): z, y
                maskTo[Dir.EAST] |= xPlaneFromYplanes(planes, 7);
            }
            if (spreadToDirMask & DirMask.MASK_NORTH) { // z--
                // Z planes (NORTH SOUTH): x, y
                maskTo[Dir.NORTH] |= zPlaneFromYplanes(planes, 0);
            }
            if (spreadToDirMask & DirMask.MASK_SOUTH) { // z++
                // Z planes (NORTH SOUTH): x, y
                maskTo[Dir.SOUTH] |= zPlaneFromYplanes(planes, 7);
            }
        }

        void applyXPlanesTrace(ref ulong[8] planes) {
            if (spreadToDirMask & DirMask.MASK_NORTH) { // z--
                // Z planes (NORTH SOUTH): x, y
                maskTo[Dir.NORTH] |= zPlaneFromXplanes(planes, 0);
            }
            if (spreadToDirMask & DirMask.MASK_SOUTH) { // z++
                // Z planes (NORTH SOUTH): x, y
                maskTo[Dir.SOUTH] |= zPlaneFromXplanes(planes, 7);
            }
            if (spreadToDirMask & DirMask.MASK_DOWN) { // y--
                // Y planes (DOWN UP): x, z
                maskTo[Dir.DOWN] |= yPlaneFromXplanes(planes, 0);
            }
            if (spreadToDirMask & DirMask.MASK_UP) { // y++
                // Y planes (DOWN UP): x, z
                maskTo[Dir.UP] |= yPlaneFromXplanes(planes, 7);
            }
        }


        void tracePaths() {
            if (!chunk) {
                // empty chunk - assuming transparent
                for (ubyte dir = 0; dir < 6; dir++) {
                    if (spreadToDirMask & (1 << dir))
                        maskTo[dir] |= 0xFFFFFFFFFFFFFFFFL;
                }
                return;
            }
            if (auto mask = maskFrom[Dir.NORTH]) {
                ulong[8] planes;
                for (int i = 7; i >= 0; i--) {
                    mask = spreadZPlane(mask, chunk.canPassPlanesZ[i], spreadToDirMask);
                    if (!mask)
                        break;
                    planes[i] = mask;
                }
                maskTo[Dir.NORTH] |= planes[0];
                applyZPlanesTrace(planes);
            } else if (auto mask = maskFrom[Dir.SOUTH]) {
                ulong[8] planes;
                for (int i = 0; i <= 7; i++) {
                    mask = spreadZPlane(mask, chunk.canPassPlanesZ[i], spreadToDirMask);
                    if (!mask)
                        break;
                    planes[i] = mask;
                }
                maskTo[Dir.SOUTH] |= planes[7];
                applyYPlanesTrace(planes);
            }
            if (auto mask = maskFrom[Dir.DOWN]) {
                ulong[8] planes;
                for (int i = 7; i >= 0; i--) {
                    mask = spreadYPlane(mask, chunk.canPassPlanesY[i], spreadToDirMask);
                    if (!mask)
                        break;
                    planes[i] = mask;
                }
                maskTo[Dir.DOWN] |= planes[0];
                applyYPlanesTrace(planes);
            } else if (auto mask = maskFrom[Dir.UP]) {
                ulong[8] planes;
                for (int i = 0; i <= 7; i++) {
                    mask = spreadYPlane(mask, chunk.canPassPlanesY[i], spreadToDirMask);
                    if (!mask)
                        break;
                    planes[i] = mask;
                }
                maskTo[Dir.UP] |= planes[7];
                applyYPlanesTrace(planes);
            }
            if (auto mask = maskFrom[Dir.WEST]) {
                ulong[8] planes;
                for (int i = 7; i >= 0; i--) {
                    mask = spreadXPlane(mask, chunk.canPassPlanesX[i], spreadToDirMask);
                    if (!mask)
                        break;
                    planes[i] = mask;
                }
                maskTo[Dir.WEST] |= planes[0];
                applyXPlanesTrace(planes);
            } else if (auto mask = maskFrom[Dir.EAST]) {
                ulong[8] planes;
                for (int i = 0; i <= 7; i++) {
                    mask = spreadXPlane(mask, chunk.canPassPlanesX[i], spreadToDirMask);
                    if (!mask)
                        break;
                    planes[i] = mask;
                }
                maskTo[Dir.EAST] |= planes[7];
                applyXPlanesTrace(planes);
            }
        }
    }
}


/// Diamond iterator for visibility check
struct VisibilityCheckIterator {
    World world;
    Vector3d startPos;
    Vector3d camPos;
    SmallChunk * startChunk;
    ChunkVisitor visitor;
    int maxHeight;
    int maxDistance;
    int maxDistanceSquared;
    VisibilityCheckChunk[] plannedChunks;
    VisibilityCheckChunk[] visitedChunks;
    /// get or add planned chunk by position
    VisibilityCheckChunk * getOrAddPlannedChunk(Vector3d pos) {
        foreach(ref p; plannedChunks) {
            if (p.pos == pos)
                return &p;
        }
        VisibilityCheckChunk plan;
        plan.pos = pos;
        plannedChunks ~= plan;
        return &plannedChunks[$ - 1];
    }
    // step 1: plan visiting chunk
    void planVisitingChunk(Vector3d p, Dir fromDir, ulong mask) {
        // mask test
        if (!mask)
            return;
        if (p.y > maxHeight + 16 && p.y > startPos.y)
            return;
        // distance test
        Vector3d diff = (p + Vector3d(4,4,4)) - camPos;
        if (diff.squaredLength() > maxDistanceSquared)
            return;
        int distance = diff.squaredLength;
        if (distance > 16*16) {
            diff = (diff * 256 + cameraDirection * 16) / 256;
            //diff += cameraDirection;
            // direction test (TODO)
            int dot = diff.dot(cameraDirection);
            if (dot < 8000)
                return;
        }
        //....
        // plan visiting
        VisibilityCheckChunk * plan = getOrAddPlannedChunk(p);
        if (!plan.chunk) {
            plan.chunk = world.getCellChunk(p.x, p.y, p.z);
        }
        plan.setMask(mask, fromDir);
    }
    // step 2: visit all planned chunks: move planned to visited; trace paths; plan new visits
    void visitPlannedChunks() {
        import std.algorithm : swap;
        swap(visitedChunks, plannedChunks);
        plannedChunks.length = 0;
        foreach (ref p; visitedChunks) {
            if (!visitor.visit(world, p.chunk))
                continue;
            /// set mask of spread directions
            p.spreadToDirMask = calcSpreadMask(p.pos, startPos);
            p.tracePaths();
            ubyte mask = p.spreadToDirMask;
            Vector3d pos = p.pos;

            if ((mask & DirMask.MASK_NORTH) && p.maskTo[Dir.NORTH]) { // z--
                planVisitingChunk(Vector3d(pos.x, pos.y, pos.z - 8), Dir.NORTH, p.maskTo[Dir.NORTH]);
            }
            if ((mask & DirMask.MASK_SOUTH) && p.maskTo[Dir.SOUTH]) { // z++
                planVisitingChunk(Vector3d(pos.x, pos.y, pos.z + 8), Dir.SOUTH, p.maskTo[Dir.SOUTH]);
            }
            if ((mask & DirMask.MASK_WEST) && p.maskTo[Dir.WEST]) { // x--
                planVisitingChunk(Vector3d(pos.x - 8, pos.y, pos.z), Dir.WEST, p.maskTo[Dir.WEST]);
            }
            if ((mask & DirMask.MASK_EAST) && p.maskTo[Dir.EAST]) { // x++
                planVisitingChunk(Vector3d(pos.x + 8, pos.y, pos.z), Dir.EAST, p.maskTo[Dir.EAST]);
            }
            if ((mask & DirMask.MASK_DOWN) && p.maskTo[Dir.DOWN]) { // y--
                planVisitingChunk(Vector3d(pos.x, pos.y - 8, pos.z), Dir.DOWN, p.maskTo[Dir.DOWN]);
            }
            if ((mask & DirMask.MASK_UP) && p.maskTo[Dir.UP]) { // y++
                planVisitingChunk(Vector3d(pos.x, pos.y + 8, pos.z), Dir.UP, p.maskTo[Dir.UP]);
            }
        }
    }
    void start(World world, Vector3d startPos, int maxDistance) {
        this.world = world;
        this.startChunk = world.getCellChunk(startPos.x, startPos.y, startPos.z);
        //if (!startChunk)
        //    return;
        startPos.x &= ~7;
        startPos.y &= ~7;
        startPos.z &= ~7;
        this.startPos = startPos; // position aligned by 8 cells
        plannedChunks.assumeSafeAppend;
        plannedChunks.length = 0;
        visitedChunks.assumeSafeAppend;
        visitedChunks.length = 0;
        maxDistanceSquared = maxDistance * maxDistance;
        this.maxDistance = maxDistance;
        maxHeight = world.regionHeight(startPos.x, startPos.z, maxDistance + 8) & 0xFFFFFF8 + 7;
        import dlangui.core.logger;
        Log.d("startPos: ", startPos, "  maxHeight:", maxHeight);
    }
    Vector3d cameraDirection;
    void visitVisibleChunks(ChunkVisitor visitor, Vector3d cameraDirection) {
        this.visitor = visitor;
        this.cameraDirection = cameraDirection;
        Vector3d cameraOffset = cameraDirection;
        cameraOffset.x /= 7;
        cameraOffset.y /= 7;
        cameraOffset.z /= 7;
        this.camPos = startPos - cameraOffset;
        //if (!startChunk)
        //    return;
        visitor.visit(world, startChunk);
        if (auto mask = startChunk ? startChunk.getSideCanPassToMask(Dir.NORTH) : 0xFFFFFFFFFFFFFFFFL)
            planVisitingChunk(Vector3d(startPos.x, startPos.y, startPos.z - 8), Dir.NORTH, mask);
        if (auto mask = startChunk ? startChunk.getSideCanPassToMask(Dir.SOUTH) : 0xFFFFFFFFFFFFFFFFL)
            planVisitingChunk(Vector3d(startPos.x, startPos.y, startPos.z + 8), Dir.SOUTH, mask);
        if (auto mask = startChunk ? startChunk.getSideCanPassToMask(Dir.WEST) : 0xFFFFFFFFFFFFFFFFL)
            planVisitingChunk(Vector3d(startPos.x - 8, startPos.y, startPos.z), Dir.WEST, mask);
        if (auto mask = startChunk ? startChunk.getSideCanPassToMask(Dir.EAST) : 0xFFFFFFFFFFFFFFFFL)
            planVisitingChunk(Vector3d(startPos.x + 8, startPos.y, startPos.z), Dir.EAST, mask);
        if (auto mask = startChunk ? startChunk.getSideCanPassToMask(Dir.DOWN) : 0xFFFFFFFFFFFFFFFFL)
            planVisitingChunk(Vector3d(startPos.x, startPos.y - 8, startPos.z), Dir.DOWN, mask);
        if (auto mask = startChunk ? startChunk.getSideCanPassToMask(Dir.UP) : 0xFFFFFFFFFFFFFFFFL)
            planVisitingChunk(Vector3d(startPos.x, startPos.y + 8, startPos.z), Dir.UP, mask);
        for (int d = 0; d < maxDistance; d += 5) {
            if (!plannedChunks.length)
                break;
            visitPlannedChunks();
        }
    }
}
