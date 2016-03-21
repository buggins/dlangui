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
	cell_t cells[CHUNK_DX * CHUNK_DX];
public:
	cell_t* ptr(int x, int z) {
		return &cells[(z << CHUNK_DX_SHIFT) + x];
	}
	cell_t get(int x, int z) {
		return cells[(z << CHUNK_DX_SHIFT) + x];
	}
	void set(int x, int z, cell_t cell) {
		cells[(z << CHUNK_DX_SHIFT) + x] = cell;
	}
}

struct Chunk {
private:
	ChunkLayer * layers[CHUNK_DY];
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
		//	return NO_CELL;
		ChunkLayer * layer = layers[y & CHUNK_DY_MASK];
		if (!layer)
			return NO_CELL;
		return layer.get(x & CHUNK_DX_MASK, z & CHUNK_DY_MASK);
	}
	void set(int x, int y, int z, cell_t cell) {
		int layerIndex = y & CHUNK_DY_MASK;
		ChunkLayer * layer = layers[layerIndex];
		if (!layer) {
			layer = new ChunkLayer();
			layers[layerIndex] = layer;
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
	//Position camPosition;
	int maxVisibleRange = MAX_VIEW_DISTANCE;
	int lastChunkX = 1000000;
	int lastChunkZ = 1000000;
	Chunk * lastChunk;
	ChunkMatrix chunks;
	//DiamondVisitor visitorHelper;
public:
	this()
    {
    }
	~this() {

	}
	//void visitVisibleCellsAllDirectionsFast(Position & position, CellVisitor * visitor);
	//Position & getCamPosition() { return camPosition; }
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
        }
        else {
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
}
