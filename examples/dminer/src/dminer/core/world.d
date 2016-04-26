module dminer.core.world;

import dminer.core.minetypes;
import dminer.core.blocks;
import dminer.core.chunk;

version (Android) {
    const int MAX_VIEW_DISTANCE_BITS = 6;
} else {
    const int MAX_VIEW_DISTANCE_BITS = 5;
}
const int MAX_VIEW_DISTANCE = (1 << MAX_VIEW_DISTANCE_BITS);


class World {

    this() {
        _camPosition = Position(Vector3d(0, 13, 0), Vector3d(0, 0, 1));
    }
    ~this() {
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
                chunk = SmallChunk.alloc();
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
            chunk = SmallChunk.alloc();
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
    final void visitVisibleCells(ref Position position, CellVisitor visitor) {
        visitorHelper.init(this, 
                            &position,
                            visitor);
        visitorHelper.visitAll(maxVisibleRange);
    }

    /// get max Y position of non-empty cell in region (x +- size, z +- size)
    int regionHeight(int x, int z, int size) {
        int top = -1;
        int delta = size / 8 + 1;
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

private:

    Position _camPosition;
    int maxVisibleRange = MAX_VIEW_DISTANCE;
    DiamondVisitor visitorHelper;
}

interface CellVisitor {
    //void newDirection(ref Position camPosition);
    //void visitFace(World world, ref Position camPosition, Vector3d pos, cell_t cell, Dir face);
    void visit(World world, ref Position camPosition, Vector3d pos, cell_t cell, int visibleFaces);
}

struct DiamondVisitor {
    int maxDist;
    int maxDistBits;
    int dist;
    World world;
    Position * position;
    Vector3d pos0;
    CellVisitor visitor;
    CellArray visited;
    cell_t * visited_ptr;
    Vector3dArray oldcells;
    Vector3dArray newcells;
    ubyte visitedId;
    //ubyte visitedEmpty;
    int m0;
    int m0mask;
    int maxY;
    void init(World w, Position * pos, CellVisitor v) {
        world = w;
        position = pos;
        visitor = v;
        pos0 = position.pos;
    }
    void visitCell(int vx, int vy, int vz) {
        //CRLog::trace("visitCell(%d %d %d) dist=%d", v.x, v.y, v.z, myAbs(v.x) + myAbs(v.y) + myAbs(v.z));

        //int occupied = visitedOccupied;
        int index = (vx + m0) + ((vz + m0) << (maxDistBits + 1));
        if (vy < 0) {
            // inverse index for lower half
            index ^= m0mask;
        }
        //int index = diamondIndex(v, maxDistBits);
        if (visited_ptr[index] == visitedId)// || cell == visitedEmpty)
            return;
        visitCellNoCheck(vx, vy, vz);
        visited_ptr[index] = visitedId; // cell;
    }

    void visitCellNoCheck(int vx, int vy, int vz) {
            //if (v * position.direction.forward < dist / 3) // limit by visible from cam
        //    return;
        //Vector3d pos = pos0 + v;
        int posx = pos0.x + vx;
        int posy = pos0.y + vy;
        int posz = pos0.z + vz;
        cell_t cell = world.getCell(posx, posy, posz);

        // read cell from world
        if (BLOCK_TYPE_VISIBLE.ptr[cell]) {
            int visibleFaces = 0;
            if (vy <= 0 && !world.isOpaque(posx, posy + 1, posz))
                visibleFaces |= DirMask.MASK_UP;
            if (vy >= 0 && !world.isOpaque(posx, posy - 1, posz))
                visibleFaces |= DirMask.MASK_DOWN;
            if (vx <= 0 && !world.isOpaque(posx + 1, posy, posz))
                visibleFaces |= DirMask.MASK_EAST;
            if (vx >= 0 && !world.isOpaque(posx - 1, posy, posz))
                visibleFaces |= DirMask.MASK_WEST;
            if (vz <= 0 && !world.isOpaque(posx, posy, posz + 1))
                visibleFaces |= DirMask.MASK_SOUTH;
            if (vz >= 0 && !world.isOpaque(posx, posy, posz - 1))
                visibleFaces |= DirMask.MASK_NORTH;
            visitor.visit(world, *position, Vector3d(posx, posy, posz), cell, visibleFaces);
        }
        // mark as visited
        if (BLOCK_TYPE_CAN_PASS.ptr[cell])
            newcells.append(Vector3d(vx, vy, vz));
        //cell = BLOCK_TYPE_CAN_PASS[cell] ? visitedEmpty : visitedOccupied;
    }

    bool needVisit(int index) {
        if (visited_ptr[index] != visitedId) {
            visited_ptr[index] = visitedId;
            return true;
        }
        return false;
    }

    static int myAbs(int n) {
        return n < 0 ? -n : n;
    }

    void visitAll(int maxDistance) {

        maxY = world.regionHeight(pos0.x, pos0.z, maxDistance);
        if (maxY < pos0.y + 1)
            maxY = pos0.y + 1;

        maxDist = maxDistance;
        maxDistance *= 2;
        maxDistBits = bitsFor(maxDist);
        int maxDistMask = ~((1 << maxDistBits) - 1);
        maxDistBits++;

        m0 = 1 << maxDistBits;
        m0mask = (m0 - 1) + ((m0 - 1) << (maxDistBits + 1));

        oldcells.clear();
        newcells.clear();
        oldcells.reserve(maxDist * 4 * 4);
        newcells.reserve(maxDist * 4 * 4);

        dist = 1;

        int vsize = ((1 << maxDistBits) * (1 << maxDistBits)) << 2;
        visited.clear();
        visited.append(cast(ubyte)0, vsize);
        visited_ptr = visited.ptr();
        visitedId = 2;
        oldcells.clear();
        oldcells.append(Vector3d(0, 0, 0));
        Dir dir = position.direction.dir;

        int zstep = 1 << (maxDistBits + 1);
        for (; dist < maxDistance; dist++) {
            // for each distance
            if (oldcells.length() == 0) { // no cells to pass through
                import dlangui.core.logger;
                Log.d("No more cells at distance ", dist);
                break;
            }
            newcells.clear();
            visitedId++;
            //int maxUp = (((dist + 1) * 7) / 8) + 1;
            //int maxDown = - (dist < 3 ? 3 : (((dist + 1) * 7) / 8)) - 1;
            //CRLog::trace("dist: %d cells: %d", dist, oldcells.length());
            for (int i = 0; i < oldcells.length(); i++) {
                Vector3d pt = oldcells[i];
                assert(myAbs(pt.x) + myAbs(pt.y) + myAbs(pt.z) == dist - 1);
                if (((pt.x + maxDist) | (pt.y + maxDist) | (pt.z + maxDist)) & maxDistMask)
                    continue;
                if (dist > 2) {
                    // skip some directions
                    //if (pt.y > maxUp || pt.y < maxDown)
                    //    continue;
                    if (pt.y > maxY)
                        continue;
                    if (dir == Dir.SOUTH) {
                        if (pt.z < -1)
                            continue;
                    } else if (dir == Dir.NORTH) {
                        if (pt.z > 1)
                            continue;
                    } else if (dir == Dir.EAST) {
                        if (pt.x < -1)
                            continue;
                    } else { // WEST
                        if (pt.x > 1)
                            continue;
                    }
                }
                int mx = pt.x;
                int my = pt.y;
                int mz = pt.z;
                int sx = mx > 0 ? 1 : 0;
                int sy = my > 0 ? 1 : 0;
                int sz = mz > 0 ? 1 : 0;
                if (mx < 0) {
                    mx = -mx;
                    sx = -1;
                }
                if (my < 0) {
                    my = -my;
                    sy = -1;
                }
                if (mz < 0) {
                    mz = -mz;
                    sz = -1;
                }
                int ymask = sy < 0 ? m0mask : 0;
                int index = ((pt.x + m0) + ((pt.z + m0) << (maxDistBits + 1))) ^ ymask;
                if (sx && sy && sz) {
                    //bool noStepZ = (mx > mz) || (my > mz);
                    // 1, 1, 1
                    int xindex = index + (sy < 0 ? -sx : sx);
                    if (visited_ptr[xindex] != visitedId) {
                        visitCellNoCheck(pt.x + sx, pt.y, pt.z);
                        visited_ptr[xindex] = visitedId;
                    }
                    int zindex = index + (sz * sy > 0 ? zstep : -zstep);
                    if (visited_ptr[zindex] != visitedId) {
                        visitCellNoCheck(pt.x, pt.y, pt.z + sz);
                        visited_ptr[zindex] = visitedId;
                    }
                    if (!ymask && sy < 0)
                        index ^= m0mask;
                    if (visited_ptr[index] != visitedId) {
                        visitCellNoCheck(pt.x, pt.y + sy, pt.z);
                        visited_ptr[index] = visitedId;
                    }
                } else {
                    // has 0 in one of coords
                    if (!sx) {
                        if (!sy) {
                            if (!sz) {
                                // 0, 0, 0
                                visitCell(pt.x + 1, pt.y, pt.z);
                                visitCell(pt.x - 1, pt.y, pt.z);
                                visitCell(pt.x, pt.y + 1, pt.z);
                                visitCell(pt.x, pt.y - 1, pt.z);
                                visitCell(pt.x, pt.y, pt.z + 1);
                                visitCell(pt.x, pt.y, pt.z - 1);
                            } else {
                                // 0, 0, 1
                                visitCell(pt.x, pt.y, pt.z + sz);
                                visitCell(pt.x + 1, pt.y, pt.z);
                                visitCell(pt.x - 1, pt.y, pt.z);
                                visitCell(pt.x, pt.y + 1, pt.z);
                                visitCell(pt.x, pt.y - 1, pt.z);
                            }
                        } else {
                            if (!sz) {
                                // 0, 1, 0
                                visitCell(pt.x, pt.y + sy, pt.z);
                                visitCell(pt.x + 1, pt.y, pt.z);
                                visitCell(pt.x - 1, pt.y, pt.z);
                                visitCell(pt.x, pt.y, pt.z + 1);
                                visitCell(pt.x, pt.y, pt.z - 1);
                            } else {
                                // 0, 1, 1
                                visitCell(pt.x, pt.y + sy, pt.z);
                                visitCell(pt.x, pt.y, pt.z + sz);
                                visitCell(pt.x + 1, pt.y, pt.z);
                                visitCell(pt.x - 1, pt.y, pt.z);
                            }
                        }
                    } else {
                        if (!sy) {
                            if (!sz) {
                                // 1, 0, 0
                                visitCell(pt.x + sx, pt.y, pt.z);
                                visitCell(pt.x, pt.y + 1, pt.z);
                                visitCell(pt.x, pt.y - 1, pt.z);
                                visitCell(pt.x, pt.y, pt.z + 1);
                                visitCell(pt.x, pt.y, pt.z - 1);
                            } else {
                                // 1, 0, 1
                                visitCell(pt.x + sx, pt.y, pt.z);
                                visitCell(pt.x, pt.y, pt.z + sz);
                                visitCell(pt.x, pt.y + 1, pt.z);
                                visitCell(pt.x, pt.y - 1, pt.z);
                            }
                        } else {
                            // 1, 1, 0
                            visitCell(pt.x + sx, pt.y, pt.z);
                            visitCell(pt.x, pt.y + sy, pt.z);
                            visitCell(pt.x, pt.y, pt.z + 1);
                            visitCell(pt.x, pt.y, pt.z - 1);
                        }
                    }
                }
            }
            newcells.swap(oldcells);
        }
    }
}

