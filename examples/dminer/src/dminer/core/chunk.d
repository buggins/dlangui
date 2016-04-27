module dminer.core.chunk;

import dminer.core.minetypes;
import dminer.core.blocks;
import dminer.core.world;
import dlangui.graphics.scene.mesh;

// Y range: 0..CHUNK_DY-1
immutable int CHUNK_DY = 128;

//immutable int CHUNKS_Y = CHUNK_DY >> 3; // actually, it's not limited

immutable int CHUNKS_BITS_X = 9;
immutable int CHUNKS_BITS_Z = 9;
immutable int CHUNKS_X = (1 << CHUNKS_BITS_X); // X range: -CHUNKS_X*8 .. CHUNKS_X*8
immutable int CHUNKS_Z = (1 << CHUNKS_BITS_Z); // Z range: -CHUNKS_Z*8 .. CHUNKS_Z*8
immutable int CHUNKS_X_MASK = (CHUNKS_X << 1) - 1;
immutable int CHUNKS_Z_MASK = (CHUNKS_Z << 1) - 1;

interface CellVisitor {
    //void newDirection(ref Position camPosition);
    //void visitFace(World world, ref Position camPosition, Vector3d pos, cell_t cell, Dir face);
    void visit(World world, ref Position camPosition, Vector3d pos, cell_t cell, int visibleFaces);
}

// vertical stack of chunks with same X, Z, and different Y
struct ChunkStack {
    protected int _minChunkY;
    protected int _chunkCount;
    protected SmallChunk ** _chunks;
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
            SmallChunk ** newChunks = allocChunks(newChunkCount);
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
    protected ulong[8] opaquePlanesX; // 64 bytes
    protected ulong[8] opaquePlanesY; // 64 bytes
    protected ulong[8] opaquePlanesZ; // 64 bytes
    protected ulong[8] visiblePlanesX; // 64 bytes
    protected ulong[8] visiblePlanesY; // 64 bytes
    protected ulong[8] visiblePlanesZ; // 64 bytes
    protected ulong[8] canPassPlanesX; // 64 bytes
    protected ulong[8] canPassPlanesY; // 64 bytes
    protected ulong[8] canPassPlanesZ; // 64 bytes
    //ulong[6][6] canPassFromTo; // 288 bytes
    SmallChunk * [6] nearChunks;
    protected Vector3d _pos;
    private Mesh _minerMesh;
    protected bool dirty;
    protected bool dirtyMesh;
    protected bool empty;
    protected bool visible;
    protected bool dirtyVisible;



    static SmallChunk * alloc(int x, int y, int z) nothrow @nogc {
        import core.stdc.stdlib : malloc;
        SmallChunk * res = cast(SmallChunk *)malloc(SmallChunk.sizeof);
        *res = SmallChunk.init;
        res._pos.x = x & (~7);
        res._pos.y = y & (~7);
        res._pos.z = z & (~7);
        return res;
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
            ubyte[64] visibleFaceFlags;
            visible = findVisibleFaces(visibleFaceFlags) > 0;
        }
        return visible;
    }

    void release() {
        if (!(&this))
            return;
        compact();
        import core.stdc.stdlib : free;
        free(&this);
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
        ubyte[64] visibleFaceFlags;
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
        if (!_minerMesh) {
            _minerMesh = new Mesh(VertexFormat(VertexElementType.POSITION, VertexElementType.NORMAL, VertexElementType.COLOR, VertexElementType.TEXCOORD0));
            dirtyMesh = true;
        }
        if (dirtyMesh) {
            _minerMesh.reset();
            ubyte[64] visibleFaceFlags;
            findVisibleFaces(visibleFaceFlags);
            int index = 0;
            for (int y = 0; y < 8; y++) {
                for (int z = 0; z < 8; z++) {
                    for (int x = 0; x < 8; x++) {
                        int visibleFaces = visibleFaceFlags[index];
                        if (visibleFaces) {
                            BlockDef def = BLOCK_DEFS[cells[index]];
                            def.createFaces(world, world.camPosition, Vector3d(_pos.x + x, _pos.y + y, _pos.z + z), visibleFaces, _minerMesh);
                        }
                        index++;
                    }
                }
            }
        }
        if (!_minerMesh.vertexCount)
            return null;
        return _minerMesh;
    }

    private int findVisibleFaces(ref ubyte[64] visibleFaceFlags) {
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
        //for (Dir from = Dir.min; from <= Dir.max; ++from) {
        //    for (Dir to = Dir.min; to <= Dir.max; ++to) {
        //    }
        //}
        dirty = false;
        empty = (visiblePlanesZ[0]|visiblePlanesZ[1]|visiblePlanesZ[2]|visiblePlanesZ[3]|
                 visiblePlanesZ[4]|visiblePlanesZ[5]|visiblePlanesZ[6]|visiblePlanesZ[7]) == 0;
        dirtyVisible = !empty;
        dirtyMesh = true;
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
