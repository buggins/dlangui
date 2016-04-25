module dminer.core.world;

import dminer.core.minetypes;
import dminer.core.blocks;

const int MAX_VIEW_DISTANCE_BITS = 6;
const int MAX_VIEW_DISTANCE = (1 << MAX_VIEW_DISTANCE_BITS);

// Layer is 16x16 (CHUNK_DX_SHIFT x CHUNK_DX_SHIFT) cells
immutable int CHUNK_DX_SHIFT = 4;
immutable int CHUNK_DX = (1<<CHUNK_DX_SHIFT);
immutable int CHUNK_DX_MASK = (CHUNK_DX - 1);

// Y range: 0..CHUNK_DY-1
immutable int CHUNK_DY_SHIFT = 6;
immutable int CHUNK_DY = (1<<CHUNK_DY_SHIFT);
immutable int CHUNK_DY_MASK = (CHUNK_DY - 1);
immutable int CHUNK_DY_INV_MASK = ~CHUNK_DY_MASK;

//extern bool HIGHLIGHT_GRID;

// Layer is 256x16x16 CHUNK_DY layers = CHUNK_DY * (CHUNK_DX_SHIFT x CHUNK_DX_SHIFT) cells
struct ChunkLayer {

    cell_t[CHUNK_DX * CHUNK_DX] cells;

    cell_t* ptr(int x, int z) {
        return &cells.ptr[(z << CHUNK_DX_SHIFT) + x];
    }
    cell_t get(int x, int z) {
        return cells.ptr[(z << CHUNK_DX_SHIFT) + x];
    }
    void set(int x, int z, cell_t cell) {
        cells.ptr[(z << CHUNK_DX_SHIFT) + x] = cell;
    }
}

struct Chunk {
private:
    ChunkLayer*[CHUNK_DY] layers;
    int bottomLayer = - 1;
    int topLayer = -1;
public:
    ~this() {
        for (int i = 0; i < CHUNK_DY; i++)
            if (layers[i])
                destroy(layers[i]);
    }
    int getMinLayer() { return bottomLayer; }
    int getMaxLayer() { return topLayer; }
    void updateMinMaxLayer(ref int minLayer, ref int maxLayer) {
        if (minLayer == -1 || minLayer > bottomLayer)
            minLayer = bottomLayer;
        if (maxLayer == -1 || maxLayer < topLayer)
            maxLayer = topLayer;
    }
    cell_t get(int x, int y, int z) {
        //if (!this)
        //    return NO_CELL;
        ChunkLayer * layer = layers[y & CHUNK_DY_MASK];
        if (!layer)
            return NO_CELL;
        return layer.get(x & CHUNK_DX_MASK, z & CHUNK_DY_MASK);
    }

    /// get, x, y, z are already checked for bounds
    cell_t getNoCheck(int x, int y, int z) {
        ChunkLayer * layer = layers.ptr[y];
        if (!layer) // likely
            return NO_CELL;
        return layer.cells.ptr[(z << CHUNK_DX_SHIFT) + x]; // inlined return layer.get(x, z);
    }

    void set(int x, int y, int z, cell_t cell) {
        int layerIndex = y & CHUNK_DY_MASK;
        ChunkLayer * layer = layers.ptr[layerIndex];
        if (!layer) {
            layer = new ChunkLayer();
            layers.ptr[layerIndex] = layer;
            if (topLayer == -1 || topLayer < layerIndex)
                topLayer = layerIndex;
            if (bottomLayer == -1 || bottomLayer > layerIndex)
                bottomLayer = layerIndex;
        }
        layer.set(x & CHUNK_DX_MASK, z & CHUNK_DY_MASK, cell);
    }

    /// srcpos coords x, z are in chunk bounds
    //void getCells(Vector3d srcpos, Vector3d dstpos, Vector3d size, VolumeData & buf);
}

alias ChunkMatrix = InfiniteMatrix!(Chunk *);

/// Voxel World
class World {
private:
    Position _camPosition;
    int maxVisibleRange = MAX_VIEW_DISTANCE;
    ChunkMatrix chunks;
    DiamondVisitor visitorHelper;
public:
    this() {
        _camPosition = Position(Vector3d(0, 13, 0), Vector3d(0, 0, 1));
    }
    ~this() {
    }
    @property final ref Position camPosition() { return _camPosition; }

    final cell_t getCell(int x, int y, int z) {
        if (!(y & CHUNK_DY_INV_MASK)) {
            if (Chunk * p = chunks.get(x >> CHUNK_DX_SHIFT, z >> CHUNK_DX_SHIFT))
                return p.getNoCheck(x & CHUNK_DX_MASK, y, z & CHUNK_DX_MASK);
            return NO_CELL;
        }
        // y out of bounds
        if (y < 0)
            return BOUND_BOTTOM;
        //if (y >= CHUNK_DY)
        else
            return BOUND_SKY;
    }

    final bool isOpaque(int x, int y, int z) {
        cell_t cell = getCell(x, y, z);
        return BLOCK_TYPE_OPAQUE.ptr[cell] && cell != BOUND_SKY;
    }

    final void setCell(int x, int y, int z, cell_t value) {
        int chunkx = x >> CHUNK_DX_SHIFT;
        int chunkz = z >> CHUNK_DX_SHIFT;
        Chunk * p = chunks.get(chunkx, chunkz);
        if (!p) {
            p = new Chunk();
            chunks.set(chunkx, chunkz, p);
        }
        p.set(x & CHUNK_DX_MASK, y, z & CHUNK_DX_MASK, value);
    }

    void setCellRange(Vector3d pos, Vector3d sz, cell_t value) {
        for (int x = 0; x < sz.x; x++)
            for (int y = 0; y < sz.y; y++)
                for (int z = 0; z < sz.z; z++)
                    setCell(pos.x + x, pos.y + y, pos.z + z, value);
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
            int maxUp = (((dist + 1) * 7) / 8) + 1;
            int maxDown = - (dist < 3 ? 3 : (((dist + 1) * 7) / 8)) - 1;
            //CRLog::trace("dist: %d cells: %d", dist, oldcells.length());
            for (int i = 0; i < oldcells.length(); i++) {
                Vector3d pt = oldcells[i];
                assert(myAbs(pt.x) + myAbs(pt.y) + myAbs(pt.z) == dist - 1);
                if (((pt.x + maxDist) | (pt.y + maxDist) | (pt.z + maxDist)) & maxDistMask)
                    continue;
                if (dist > 2) {
                    // skip some directions
                    if (pt.y > maxUp || pt.y < maxDown)
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

static short[] TERRAIN_INIT_DATA = [
    //                                      V
    10,  10,  10,  10,  30,  30,  30,  30,  30,  30,  30,  30,  10,  10,  10,  10,  10,
    10,  10,  20,  50,  50,  50,  50,  50,  50,  50,  50,  50,  20,  20,  20,  20,  10,
    10,  20,  20,  50,  50,  50,  50,  50,  50,  50,  50,  50,  50,  50,  20,  20,  10,
    10,  20,  50,  50,  50,  50,  50,  50,  50,  50,  50,  50,  50,  50,  50,  20,  10,
    10,  50,  50,  50,  50,  50,  50,  50,  50,  50,  50,  50,  50,  50,  50,  20,  30,
    30,  50,  50,  50,  50,  50,  50,  50,  50,  50,  50,  50,  50,  50,  50,  50,  30,
    30,  50,  50,  50,  50,  50,  50,  50, 120,  50,  50,  50,  50,  50,  50,  50,  30,
    30,  50,  50,  50,  50,  50,  50, 110, 140, 130,  50,  50,  50,  50,  50,  50,  30,
    30,  50,  50,  50,  50,  50,  50, 140, 150, 140,  50,  50,  50,  50,  50,  50,  30, // <==
    30,  50,  50,  50,  50,  50,  50, 110, 140, 120,  50,  50,  50,  50,  50,  50,  30,
    30,  50,  50,  50,  50,  50,  50,  50, 110,  50,  50,  50,  50,  50,  50,  50,  30,
    30,  50,  50,  50,  50,  50,  50,  50,  50,  50,  50,  50,  50,  50,  50,  50,  10,
    30,  50,  50,  50,  50,  50,  50,  50,  50,  50,  50,  50,  50,  50,  50,  50,  10,
    30,  50,  50,  50,  50,  50,  50,  50,  50,  50,  50,  50,  50,  50,  40,  50,  10,
    30,  20,  50,  50,  50,  50,  50,  50,  50,  50,  50,  50,  50,  40,  20,  20,  10,
    30,  20,  20,  50,  50,  50,  50,  50,  50,  50,  40,  20,  20,  20,  20,  20,  10,
    30,  30,  30,  30,  30,  30,  30,  30,  30,  30,  30,  30,  10,  10,  10,  10,  10,
    //                                      ^
];

static short[] TERRAIN_SCALE_DATA = [
    //                                      V
    20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,
    20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,
    20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,
    20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  30,  20,  20,  20,
    20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  45,  20,  20,  20,
    20,  20,  20,  20,  20,  20,  20,  20,  80,  20,  20,  20,  40,  50,  40,  20,  20,
    20,  20,  20,  20,  20,  20,  90,  20,  80,  20,  30,  20,  20,  30,  20,  20,  20,
    20,  20,  20,  20,  20,  90,  20,  80,  30,  20,  40,  20,  20,  20,  20,  20,  20,
    20,  20,  20,  20,  20,  20,  90,  30,  40,  30,  50,  20,  20,  20,  20,  20,  20, // <==
    20,  20,  20,  20,  20,  20,  50,  20,  30,  20,  20,  20,  20,  20,  20,  20,  20,
    20,  20,  20,  20,  20,  20,  40,  70,  40,  90,  20,  40,  20,  20,  20,  20,  20,
    20,  20,  20,  20,  20,  20,  20,  20,  80,  20,  50,  70,  50,  20,  20,  20,  20,
    20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  60,  20,  20,  20,  20,  20,
    20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,
    20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,
    20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,
    20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,
    //                                      ^
];

void initWorldTerrain(World world, int terrSizeBits = 10, int x0 = 0, int z0 = 0) {
    import dminer.core.terrain;
    int terrSize = 1 << terrSizeBits;
    TerrainGen scaleterr = TerrainGen(terrSizeBits, terrSizeBits); // 512x512
    scaleterr.generate(4321, TERRAIN_SCALE_DATA, terrSizeBits - 4); // init grid is 16x16 (1 << (9-7))
    scaleterr.filter(1);
    //scaleterr.filter(2);
    scaleterr.limit(0, 90);
    TerrainGen terr = TerrainGen(terrSizeBits, terrSizeBits); // 512x512
    terr.generateWithScale(123456, TERRAIN_INIT_DATA, terrSizeBits - 4, scaleterr); // init grid is 16x16 (1 << (9-7))
    terr.filter(1);
    terr.limit(5, CHUNK_DY * 3 / 4);
    terr.filter(1);
    for (int x = 0; x < terrSize; x++) {
        for (int z = 0; z < terrSize; z++) {
            int cellx = x0 + x - terrSize / 2;
            int cellz = z0 + z - terrSize / 2;
            int h = terr.get(x, z);
            //cell_t cell = BlockId.bedrock;
            //cell_t cell = BlockId.grass;
            cell_t cell = BlockId.face_test;
            //if (h < CHUNK_DY / 10)
            //    cell = 100;
            //else if (h < CHUNK_DY / 5)
            //    cell = 101;
            //else if (h < CHUNK_DY / 4)
            //    cell = 102;
            //else if (h < CHUNK_DY / 3)
            //    cell = 103;
            //else if (h < CHUNK_DY / 2)
            //    cell = 104;
            //else
            //    cell = 105;
            for (int y = 0; y < h; y++) {
                world.setCell(cellx, y, cellz, cell);
            }
        }
    }
}
