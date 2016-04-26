module dminer.core.chunk;

import dminer.core.minetypes;
import dminer.core.blocks;

enum USE_NEW_WORLD_IMPL = true;


// Y range: 0..CHUNK_DY-1
immutable int CHUNK_DY_SHIFT = 7;
immutable int CHUNK_DY = (1<<CHUNK_DY_SHIFT);
immutable int CHUNK_DY_MASK = (CHUNK_DY - 1);
immutable int CHUNK_DY_INV_MASK = ~CHUNK_DY_MASK;





immutable int CHUNKS_Y = 128 / 8;
immutable int CHUNKS_BITS_X = 9;
immutable int CHUNKS_BITS_Z = 9;
immutable int CHUNKS_X = (1 << CHUNKS_BITS_X); // X range: -CHUNKS_X*8 .. CHUNKS_X*8
immutable int CHUNKS_Z = (1 << CHUNKS_BITS_Z); // Z range: -CHUNKS_Z*8 .. CHUNKS_Z*8
immutable int CHUNKS_X_MASK = (CHUNKS_X << 1) - 1;
immutable int CHUNKS_Z_MASK = (CHUNKS_Z << 1) - 1;

// vertical stack of chunks with same X, Z, and different Y
struct ChunkStack {
    protected int _minChunkY;
    protected int _chunkCount;
    SmallChunk ** _chunks;
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
                SmallChunk.free(_chunks[idx]);
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
                SmallChunk.free(_chunks[i]);
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
    cell_t[8*8*8] cells; // 512 bytes
    ubyte[8*8*8] sunlight; // 512 bytes
    ulong[8] opaquePlanesX; // 64 bytes
    ulong[8] opaquePlanesY; // 64 bytes
    ulong[8] opaquePlanesZ; // 64 bytes
    ulong[8] canPassPlanesX; // 64 bytes
    ulong[8] canPassPlanesY; // 64 bytes
    ulong[8] canPassPlanesZ; // 64 bytes
    ulong[6][6] canPassFromTo; // 288 bytes
    SmallChunk * [6] nearChunks;
    bool dirty;

    static SmallChunk * alloc() nothrow @nogc {
        import core.stdc.stdlib : malloc;
        SmallChunk * res = cast(SmallChunk *)malloc(SmallChunk.sizeof);
        *res = SmallChunk.init;
        return res;
    }

    static void free(SmallChunk * obj) {
        if (!obj)
            return;
        import core.stdc.stdlib : free;
        free(obj);
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
    void generateMasks() {
        // x planes: z,y
        for(int x = 0; x < 8; x++) {
            ulong opaqueFlags = 0;
            ulong canPassFlags = 0;
            ulong mask = 1;
            for (int y = 0; y < 8; y++) {
                for (int z = 0; z < 8; z++) {
                    cell_t cell = cells[(((y << 3) | z) << 3) | x];
                    if (BLOCK_TYPE_OPAQUE.ptr[cell])
                        opaqueFlags |= mask;
                    if (BLOCK_TYPE_CAN_PASS.ptr[cell])
                        canPassFlags |= mask;
                    mask = mask << 1;
                }
            }
            opaquePlanesX[x] = opaqueFlags;
            canPassPlanesX[x] = canPassFlags;
        }
        // y planes : x,z
        for(int y = 0; y < 8; y++) {
            ulong opaqueFlags = 0;
            ulong canPassFlags = 0;
            ulong mask = 1;
            for (int z = 0; z < 8; z++) {
                for (int x = 0; x < 8; x++) {
                    cell_t cell = cells[(((y << 3) | z) << 3) | x];
                    if (BLOCK_TYPE_OPAQUE.ptr[cell])
                        opaqueFlags |= mask;
                    if (BLOCK_TYPE_CAN_PASS.ptr[cell])
                        canPassFlags |= mask;
                    mask = mask << 1;
                }
            }
            opaquePlanesY[y] = opaqueFlags;
            canPassPlanesY[y] = canPassFlags;
        }
        // z planes: x,y
        for(int z = 0; z < 8; z++) {
            ulong opaqueFlags = 0;
            ulong canPassFlags = 0;
            ulong mask = 1;
            for (int y = 0; y < 8; y++) {
                for (int x = 0; x < 8; x++) {
                    cell_t cell = cells[(((y << 3) | z) << 3) | x];
                    if (BLOCK_TYPE_OPAQUE.ptr[cell])
                        opaqueFlags |= mask;
                    if (BLOCK_TYPE_CAN_PASS.ptr[cell])
                        canPassFlags |= mask;
                    mask = mask << 1;
                }
            }
            opaquePlanesZ[z] = opaqueFlags;
            canPassPlanesZ[z] = canPassFlags;
        }
        // can pass from to
        for (Dir from = Dir.min; from <= Dir.max; ++from) {
            for (Dir to = Dir.min; to <= Dir.max; ++to) {
            }
        }
        dirty = false;
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
