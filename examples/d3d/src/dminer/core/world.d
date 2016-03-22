module dminer.core.world;

import dminer.core.minetypes;
import dminer.core.blocks;

const int MAX_VIEW_DISTANCE_BITS = 7;
const int MAX_VIEW_DISTANCE = (1 << MAX_VIEW_DISTANCE_BITS);

// Layer is 16x16 (CHUNK_DX_SHIFT x CHUNK_DX_SHIFT) cells
immutable int CHUNK_DX_SHIFT = 4;
immutable int CHUNK_DX = (1<<CHUNK_DX_SHIFT);
immutable int CHUNK_DX_MASK = (CHUNK_DX - 1);

immutable int CHUNK_DY_SHIFT = 7;
immutable int CHUNK_DY = (1<<CHUNK_DY_SHIFT);
immutable int CHUNK_DY_MASK = (CHUNK_DY - 1);

//extern bool HIGHLIGHT_GRID;

// Layer is 256x16x16 CHUNK_DY layers = CHUNK_DY * (CHUNK_DX_SHIFT x CHUNK_DX_SHIFT) cells
struct ChunkLayer {
private:
    cell_t[CHUNK_DX * CHUNK_DX] cells;
public:
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

struct ChunkMatrix {
private:
    int minx;
    int maxx;
    int minz;
    int maxz;
    InfiniteMatrix!(Chunk *) matrix;
public:
    @property int minX() { return minx; }
    @property int maxX() { return maxx; }
    @property int minZ() { return minz; }
    @property int maxZ() { return maxz; }
    Chunk * get(int x, int z) {
        return matrix.get(x, z);
    }
    void set(int x, int z, Chunk * chunk) {
        matrix.set(x, z, chunk);
        if (minz > z)
            minz = z;
        if (maxz < z + 1)
            maxz = z + 1;
        if (minx > x)
            minx = x;
        if (maxx < x + 1)
            maxx = x + 1;
    }
}

/// Voxel World
class World {
private:
    Position camPosition;
    int maxVisibleRange = MAX_VIEW_DISTANCE;
    int lastChunkX = 1000000;
    int lastChunkZ = 1000000;
    Chunk * lastChunk;
    ChunkMatrix chunks;
    DiamondVisitor visitorHelper;
public:
    this()
    {
    }
    ~this() {

    }
    ref Position getCamPosition() { return camPosition; }
    cell_t getCell(Vector3d v) {
        return getCell(v.x, v.y, v.z);
    }
    cell_t getCell(int x, int y, int z) {
        if (y < 0)
            return 3;
        int chunkx = x >> CHUNK_DX_SHIFT;
        int chunkz = z >> CHUNK_DX_SHIFT;
        Chunk * p;
        if (lastChunkX == chunkx && lastChunkZ == chunkz) {
            p = lastChunk;
        } else {
            p = chunks.get(chunkx, chunkz);
            lastChunkX = chunkx;
            lastChunkZ = chunkz;
            lastChunk = p;
        }
        if (!p)
            return NO_CELL;
        return p.get(x & CHUNK_DX_MASK, y, z & CHUNK_DX_MASK);
    }
    bool isOpaque(Vector3d v) {
        cell_t cell = getCell(v);
        return BLOCK_TYPE_OPAQUE[cell] && cell != BOUND_SKY;
    }
    void setCell(int x, int y, int z, cell_t value) {
        int chunkx = x >> CHUNK_DX_SHIFT;
        int chunkz = z >> CHUNK_DX_SHIFT;
        Chunk * p;
        if (lastChunkX == chunkx && lastChunkZ == chunkz) {
            p = lastChunk;
        } else {
            p = chunks.get(chunkx, chunkz);
            lastChunkX = chunkx;
            lastChunkZ = chunkz;
            lastChunk = p;
        }
        if (!p) {
            p = new Chunk();
            chunks.set(chunkx, chunkz, p);
            lastChunkX = chunkx;
            lastChunkZ = chunkz;
            lastChunk = p;
        }
        p.set(x & CHUNK_DX_MASK, y, z & CHUNK_DX_MASK, value);
    }
    //bool canPass(Vector3d pos, Vector3d size) {
    //}
    void visitVisibleCells(ref Position position, CellVisitor visitor) {
        visitorHelper.init(this, &position,
                           visitor);
        visitorHelper.visitAll(MAX_VIEW_DISTANCE);
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
    ubyte visitedOccupied;
    ubyte visitedEmpty;
    int m0;
    int m0mask;
    void init(World w, Position * pos, CellVisitor v) {
        world = w;
        position = pos;
        visitor = v;
        pos0 = position.pos;
    }
    void visitCell(Vector3d v) {
        //CRLog::trace("visitCell(%d %d %d) dist=%d", v.x, v.y, v.z, myAbs(v.x) + myAbs(v.y) + myAbs(v.z));

        //int occupied = visitedOccupied;
        int index = (v.x + m0) + ((v.z + m0) << (maxDistBits + 1));
        if (v.y < 0) {
            // inverse index for lower half
            index ^= m0mask;
            //m0--;
            //x ^= m0;
            //y ^= m0;
        }
        //int index = diamondIndex(v, maxDistBits);
        if (visited_ptr[index] == visitedOccupied)// || cell == visitedEmpty)
            return;
        if (v * position.direction.forward < dist / 3)
            return;
        Vector3d pos = pos0 + v;
        cell_t cell = world.getCell(pos);

        // read cell from world
        if (BLOCK_TYPE_VISIBLE[cell]) {
            int visibleFaces = 0;
            if (v.y <= 0 && v * DIRECTION_VECTORS[DIR_UP] <= 0 &&
                !world.isOpaque(pos.move(DIR_UP)))
                visibleFaces |= MASK_UP;
            if (v.y >= 0 && v * DIRECTION_VECTORS[DIR_DOWN] <= 0 &&
                !world.isOpaque(pos.move(DIR_DOWN)))
                visibleFaces |= MASK_DOWN;
            if (v.x <= 0 && v * DIRECTION_VECTORS[DIR_EAST] <= 0 &&
                !world.isOpaque(pos.move(DIR_EAST)))
                visibleFaces |= MASK_EAST;
            if (v.x >= 0 && v * DIRECTION_VECTORS[DIR_WEST] <= 0 &&
                !world.isOpaque(pos.move(DIR_WEST)))
                visibleFaces |= MASK_WEST;
            if (v.z <= 0 && v * DIRECTION_VECTORS[DIR_SOUTH] <= 0 &&
                !world.isOpaque(pos.move(DIR_SOUTH)))
                visibleFaces |= MASK_SOUTH;
            if (v.z >= 0 && v * DIRECTION_VECTORS[DIR_NORTH] <= 0 &&
                !world.isOpaque(pos.move(DIR_NORTH)))
                visibleFaces |= MASK_NORTH;
            visitor.visit(world, *position, pos, cell, visibleFaces);
        }
        // mark as visited
        if (BLOCK_TYPE_CAN_PASS[cell])
            newcells.append(v);
        //cell = BLOCK_TYPE_CAN_PASS[cell] ? visitedEmpty : visitedOccupied;
        visited_ptr[index] = visitedOccupied; // cell;
    }

    void visitAll(int maxDistance) {
        maxDist = maxDistance;
        maxDistBits = bitsFor(maxDist);

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
        visitedOccupied = 2;
        visitedEmpty = 3;
        oldcells.clear();
        oldcells.append(Vector3d(0, 0, 0));

        for (; dist < maxDistance; dist++) {
            // for each distance
            if (oldcells.length() == 0) // no cells to pass through
                break;
            newcells.clear();
            visitedOccupied += 2;
            visitedEmpty += 2;
        //CRLog::trace("dist: %d cells: %d", dist, oldcells.length());
            for (int i = 0; i < oldcells.length(); i++) {
                Vector3d pt = oldcells[i];
                int sx = mySign(pt.x);
                int sy = mySign(pt.y);
                int sz = mySign(pt.z);
                if (sx && sy && sz) {
                    // 1, 1, 1
                    visitCell(Vector3d(pt.x + sx, pt.y, pt.z));
                    visitCell(Vector3d(pt.x, pt.y + sy, pt.z));
                    visitCell(Vector3d(pt.x, pt.y, pt.z + sz));
                } else {
                    // has 0 in one of coords
                    if (!sx) {
                        if (!sy) {
                            if (!sz) {
                                // 0, 0, 0
                                visitCell(Vector3d(pt.x + 1, pt.y, pt.z));
                                visitCell(Vector3d(pt.x - 1, pt.y, pt.z));
                                visitCell(Vector3d(pt.x, pt.y + 1, pt.z));
                                visitCell(Vector3d(pt.x, pt.y - 1, pt.z));
                                visitCell(Vector3d(pt.x, pt.y, pt.z + 1));
                                visitCell(Vector3d(pt.x, pt.y, pt.z - 1));
                            } else {
                                // 0, 0, 1
                                visitCell(Vector3d(pt.x, pt.y, pt.z + sz));
                                visitCell(Vector3d(pt.x + 1, pt.y, pt.z));
                                visitCell(Vector3d(pt.x - 1, pt.y, pt.z));
                                visitCell(Vector3d(pt.x, pt.y + 1, pt.z));
                                visitCell(Vector3d(pt.x, pt.y - 1, pt.z));
                            }
                        } else {
                            if (!sz) {
                                // 0, 1, 0
                                visitCell(Vector3d(pt.x, pt.y + sy, pt.z));
                                visitCell(Vector3d(pt.x + 1, pt.y, pt.z));
                                visitCell(Vector3d(pt.x - 1, pt.y, pt.z));
                                visitCell(Vector3d(pt.x, pt.y, pt.z + 1));
                                visitCell(Vector3d(pt.x, pt.y, pt.z - 1));
                            } else {
                                // 0, 1, 1
                                visitCell(Vector3d(pt.x, pt.y + sy, pt.z));
                                visitCell(Vector3d(pt.x, pt.y, pt.z + sz));
                                visitCell(Vector3d(pt.x + 1, pt.y, pt.z));
                                visitCell(Vector3d(pt.x - 1, pt.y, pt.z));
                            }
                        }
                    } else {
                        if (!sy) {
                            if (!sz) {
                                // 1, 0, 0
                                visitCell(Vector3d(pt.x + sx, pt.y, pt.z));
                                visitCell(Vector3d(pt.x, pt.y + 1, pt.z));
                                visitCell(Vector3d(pt.x, pt.y - 1, pt.z));
                                visitCell(Vector3d(pt.x, pt.y, pt.z + 1));
                                visitCell(Vector3d(pt.x, pt.y, pt.z - 1));
                            } else {
                                // 1, 0, 1
                                visitCell(Vector3d(pt.x + sx, pt.y, pt.z));
                                visitCell(Vector3d(pt.x, pt.y, pt.z + sz));
                                visitCell(Vector3d(pt.x, pt.y + 1, pt.z));
                                visitCell(Vector3d(pt.x, pt.y - 1, pt.z));
                            }
                        } else {
                            // 1, 1, 0
                            visitCell(Vector3d(pt.x + sx, pt.y, pt.z));
                            visitCell(Vector3d(pt.x, pt.y + sy, pt.z));
                            visitCell(Vector3d(pt.x, pt.y, pt.z + 1));
                            visitCell(Vector3d(pt.x, pt.y, pt.z - 1));
                        }
                    }
                }
            }
            newcells.swap(oldcells);
        }
    }
}
