module dminer.core.world;

import dminer.core.minetypes;
import dminer.core.blocks;
import dminer.core.chunk;

version (Android) {
    const int MAX_VIEW_DISTANCE = 60;
} else {
    const int MAX_VIEW_DISTANCE = 250;
}


class World {

    this() {
        _camPosition = Position(Vector3d(0, 13, 0), Vector3d(0, 0, 1));
    }
    ~this() {
        clear();
    }
    void clear() {
        for(int index = 0; index < _chunkStacks.length; index++) {
            if (_chunkStacks[index]) {
                destroy(_chunkStacks[index]);
                _chunkStacks[index] = null;
            }
        }
    }
    @property final ref Position camPosition() { return _camPosition; }


    protected ChunkStack*[CHUNKS_X * 2 * CHUNKS_Z * 2] _chunkStacks;

    //pragma(msg, "stack pointers array size, Kb:");
    //pragma(msg, _chunkStacks.sizeof / 1024);
    final cell_t getCell(int x, int y, int z) {
        int chunkx = (x >> 3) + CHUNKS_X;
        int chunkz = (z >> 3) + CHUNKS_Z;
        if ((chunkx & (~CHUNKS_X_MASK)) || (chunkz & (~CHUNKS_Z_MASK)))
            return 0; // out of bounds x,z
        int index = chunkx + (chunkz << (CHUNKS_BITS_X + 1));
        if (ChunkStack * stack = _chunkStacks[index]) {
            int chunkY = (y >> 3);
            if (SmallChunk * chunk = stack.get(chunkY))
                return chunk.getCell(x, y, z);
        }
        return 0;
    }
    /// get chunk stack for cell by world cell coordinates x, z
    ChunkStack * getCellChunkStack(int x, int z) {
        int chunkx = (x >> 3) + CHUNKS_X;
        int chunkz = (z >> 3) + CHUNKS_Z;
        if ((chunkx & (~CHUNKS_X_MASK)) || (chunkz & (~CHUNKS_Z_MASK)))
            return null; // out of bounds x,z
        int index = chunkx + (chunkz << (CHUNKS_BITS_X + 1));
        return _chunkStacks[index];
    }
    /// get chunk by chunkx = x / 8 + CHUNKS_X, chunky = y / 8, chunkz = z / 8 + CHUNKS_Z
    SmallChunk * getChunk(int chunkx, int chunky, int chunkz) {
        if ((chunkx & (~CHUNKS_X_MASK)) || (chunkz & (~CHUNKS_Z_MASK)))
            return null; // out of bounds x,z
        int index = chunkx + (chunkz << (CHUNKS_BITS_X + 1));
        if (ChunkStack * stack = _chunkStacks[index])
            return stack.get(chunky);
        return null;
    }
    /// get chunk for cell by world cell coordinates x, y, z
    SmallChunk * getCellChunk(int x, int y, int z) {
        int chunkx = (x >> 3) + CHUNKS_X;
        int chunkz = (z >> 3) + CHUNKS_Z;
        if ((chunkx & (~CHUNKS_X_MASK)) || (chunkz & (~CHUNKS_Z_MASK)))
            return null; // out of bounds x,z
        int index = chunkx + (chunkz << (CHUNKS_BITS_X + 1));
        int chunky = (y >> 3);
        if (ChunkStack * stack = _chunkStacks[index])
            return stack.get(chunky);
        return null;
    }

    private void updateNearChunks(SmallChunk * thisChunk, int x, int y, int z) {
        // UP
        SmallChunk * chunkAbove = getCellChunk(x, y + 8, z);
        thisChunk.nearChunks[Dir.UP] = chunkAbove;
        if (chunkAbove)
            chunkAbove.nearChunks[Dir.DOWN] = thisChunk;
        // DOWN
        SmallChunk * chunkBelow = getCellChunk(x, y - 8, z);
        thisChunk.nearChunks[Dir.DOWN] = chunkBelow;
        if (chunkBelow)
            chunkBelow.nearChunks[Dir.UP] = thisChunk;
        // WEST
        SmallChunk * chunkWest = getCellChunk(x - 8, y, z);
        thisChunk.nearChunks[Dir.WEST] = chunkWest;
        if (chunkWest)
            chunkWest.nearChunks[Dir.EAST] = thisChunk;
        // EAST
        SmallChunk * chunkEast = getCellChunk(x + 8, y, z);
        thisChunk.nearChunks[Dir.EAST] = chunkEast;
        if (chunkEast)
            chunkEast.nearChunks[Dir.WEST] = thisChunk;
        // NORTH
        SmallChunk * chunkNorth = getCellChunk(x, y, z - 8);
        thisChunk.nearChunks[Dir.NORTH] = chunkNorth;
        if (chunkNorth)
            chunkNorth.nearChunks[Dir.SOUTH] = thisChunk;
        // SOUTH
        SmallChunk * chunkSouth = getCellChunk(x, y, z + 8);
        thisChunk.nearChunks[Dir.SOUTH] = chunkSouth;
        if (chunkSouth)
            chunkSouth.nearChunks[Dir.NORTH] = thisChunk;
    }

    final void setCell(int x, int y, int z, cell_t value) {
        int chunkx = (x >> 3) + CHUNKS_X;
        int chunkz = (z >> 3) + CHUNKS_Z;
        if ((chunkx & (~CHUNKS_X_MASK)) || (chunkz & (~CHUNKS_Z_MASK)))
            return; // out of bounds x,z
        int index = chunkx + (chunkz << (CHUNKS_BITS_X + 1));
        ChunkStack * stack = _chunkStacks[index];
        SmallChunk * chunk;
        if (stack) {
            int chunkY = (y >> 3);
            chunk = stack.get(chunkY);
            if (chunk)
                chunk.setCell(x, y, z, value);
            else {
                // create chunk
                if (!value)
                    return; // don't create chunk for 0
                chunk = SmallChunk.alloc(x, y, z);
                stack.set(chunkY, chunk);
                chunk.setCell(x, y, z, value);
                updateNearChunks(chunk, x, y, z);
            }
        } else {
            if (!value)
                return; // don't create chunk for 0
            stack = new ChunkStack();
            _chunkStacks[index] = stack;
            int chunkY = (y >> 3);
            chunk = SmallChunk.alloc(x, y, z);
            stack.set(chunkY, chunk);
            chunk.setCell(x, y, z, value);
            updateNearChunks(chunk, x, y, z);
        }
    }




    void setCellRange(Vector3d pos, Vector3d sz, cell_t value) {
        for (int x = 0; x < sz.x; x++)
            for (int y = 0; y < sz.y; y++)
                for (int z = 0; z < sz.z; z++)
                    setCell(pos.x + x, pos.y + y, pos.z + z, value);
    }

    final bool isOpaque(int x, int y, int z) {
        cell_t cell = getCell(x, y, z);
        return BLOCK_TYPE_OPAQUE.ptr[cell] && cell != BOUND_SKY;
    }

    bool canPass(Vector3d pos) {
        return canPass(Vector3d(pos.x - 2, pos.y - 3, pos.z - 2), Vector3d(4, 5, 4));
    }

    bool canPass(Vector3d pos, Vector3d size) {
        for (int x = 0; x <= size.x; x++)
            for (int z = 0; z <= size.z; z++)
                for (int y = 0; y < size.y; y++) {
                    if (isOpaque(pos.x + x, pos.y + y, pos.z + z))
                        return false;
                }
        return true;
    }

    /// get max Y position of non-empty cell in region (x +- size, z +- size)
    int regionHeight(int x, int z, int size) {
        int top = -1;
        int delta = size + 1;
        for (int dx = x - delta; dx <= x + delta; dx += 8) {
            for (int dz = z - delta; dz <= z + delta; dz += 8) {
                if (ChunkStack * stack = getCellChunkStack(x, z)) {
                    if (top < stack.topNonEmptyY)
                        top = stack.topNonEmptyY;
                }
            }
        }
        return top;
    }

    private void visitChunk(ChunkVisitor visitor, Vector3d pos) {
        SmallChunk * chunk = getCellChunk(pos.x, pos.y, pos.z);
        if (chunk && chunk.hasVisibleFaces)
            visitor.visit(this, chunk);
    }

    /// visit visible chunks, starting from specified position
    void visitVisibleChunks(ChunkVisitor visitor, Vector3d pos, int maxDistance) {
        int chunkDist = (maxDistance + 7) >> 3;
        visitChunk(visitor, pos);
        for (int dist = 1; dist <= chunkDist; dist++) {
            int d = dist << 3;
            visitChunk(visitor, Vector3d(pos.x - d, pos.y, pos.z));
            visitChunk(visitor, Vector3d(pos.x + d, pos.y, pos.z));
            visitChunk(visitor, Vector3d(pos.x, pos.y - d, pos.z));
            visitChunk(visitor, Vector3d(pos.x, pos.y + d, pos.z));
            visitChunk(visitor, Vector3d(pos.x, pos.y, pos.z - d));
            visitChunk(visitor, Vector3d(pos.x, pos.y, pos.z + d));
            for (int i = 1; i <= dist; i++) {
            }
        }
    }

private:

    Position _camPosition;
    int maxVisibleRange = MAX_VIEW_DISTANCE;
}

struct VisitorCell {
    SmallChunk * chunk;
    ulong[6] accessible;
    bool visited;
    int dirFlags;
}

struct ChunkDiamondVisitor {
    World world;
    ChunkVisitor visitor;
    Vector3d pos;
    Array3d!VisitorCell cells;
    int maxDist;
    Vector3dArray oldcells;
    Vector3dArray newcells;
    void init(World world, int distance, ChunkVisitor visitor) {
        this.world = world;
        this.maxDist = (distance + 7) / 8;
        cells.reset(maxDist);
        this.visitor = visitor;
    }
    void visitCell(VisitorCell * oldCell, int x, int y, int z, Dir direction) {
        if (x < -maxDist || x > maxDist || y < -maxDist || y > maxDist || z < -maxDist || z > maxDist)
            return; // out of bounds
        auto cell = cells.ptr(x, y, z);
        if (!cell.visited) {
            cell.chunk = world.getCellChunk(pos.x + (x << 3), pos.y + (y << 3), pos.z + (z << 3));
            cell.visited = true;
            newcells.append(Vector3d(x, y, z));
        }
        cell.dirFlags |= (1 << direction);
    }
    void visitChunks(Vector3d pos) {
        this.pos = pos;
        cells.reset(maxDist);
        //cells[1,2,3] = VisitorCell.init;
        newcells.clear();
        //oldcells.append(Vector3d(0, 0, 0));
        visitCell(null, 0,0,0, Dir.NORTH);
        visitCell(null, 0,0,0, Dir.SOUTH);
        visitCell(null, 0,0,0, Dir.WEST);
        visitCell(null, 0,0,0, Dir.EAST);
        visitCell(null, 0,0,0, Dir.UP);
        visitCell(null, 0,0,0, Dir.DOWN);
        newcells.swap(oldcells);
        // call visitor for this newly visited cells
        for (int i = 0; i < oldcells.length; i++) {
            Vector3d pt = oldcells[i];
            auto cell = cells.ptr(pt.x, pt.y, pt.z);
            if (cell.chunk)
                visitor.visit(world, cell.chunk);
        }
        for (int dist = 0; dist < maxDist * 2; dist++) {
            if (oldcells.length == 0)
                break;
            newcells.clear();
            for (int i = 0; i < oldcells.length; i++) {
                Vector3d pt = oldcells[i];
                auto oldcell = cells.ptr(pt.x, pt.y, pt.z);
                if (pt.x < 0) {
                    visitCell(oldcell, pt.x - 1, pt.y, pt.z, Dir.WEST);
                } else if (pt.x > 0) {
                    visitCell(oldcell, pt.x + 1, pt.y, pt.z, Dir.EAST);
                } else {
                    visitCell(oldcell, pt.x - 1, pt.y, pt.z, Dir.WEST);
                    visitCell(oldcell, pt.x + 1, pt.y, pt.z, Dir.EAST);
                }
                if (pt.y < 0) {
                    visitCell(oldcell, pt.x, pt.y - 1, pt.z, Dir.DOWN);
                } else if (pt.y > 0) {
                    visitCell(oldcell, pt.x, pt.y + 1, pt.z, Dir.UP);
                } else {
                    visitCell(oldcell, pt.x, pt.y - 1, pt.z, Dir.DOWN);
                    visitCell(oldcell, pt.x, pt.y + 1, pt.z, Dir.UP);
                }
                if (pt.z < 0) {
                    visitCell(oldcell, pt.x, pt.y, pt.z - 1, Dir.WEST);
                } else if (pt.z > 0) {
                    visitCell(oldcell, pt.x, pt.y, pt.z + 1, Dir.EAST);
                } else {
                    visitCell(oldcell, pt.x, pt.y, pt.z - 1, Dir.WEST);
                    visitCell(oldcell, pt.x, pt.y, pt.z + 1, Dir.EAST);
                }
            }
            newcells.swap(oldcells);
            // call visitor for this newly visited cells
            for (int i = 0; i < oldcells.length; i++) {
                Vector3d pt = oldcells[i];
                auto cell = cells.ptr(pt.x, pt.y, pt.z);
                if (cell.chunk)
                    visitor.visit(world, cell.chunk);
            }
        }
    }
}

