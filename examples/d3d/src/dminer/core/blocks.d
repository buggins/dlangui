module dminer.core.blocks;

import dminer.core.minetypes;

immutable string BLOCK_TEXTURE_FILENAME = "blocks";
immutable int BLOCK_TEXTURE_DX = 1024;
immutable int BLOCK_TEXTURE_DY = 1024;
immutable int BLOCK_SPRITE_SIZE = 16;
immutable int BLOCK_SPRITE_STEP = 20;
immutable int BLOCK_SPRITE_OFFSET = 21;
immutable int BLOCK_TEXTURE_SPRITES_PER_LINE = 50;

enum BlockVisibility {
    INVISIBLE,
    OPAQUE, // completely opaque (cells covered by this block are invisible)
    OPAQUE_SEPARATE_TX,
    HALF_OPAQUE, // partially paque, cells covered by this block can be visible, render as normal block
    HALF_OPAQUE_SEPARATE_TX,
    HALF_TRANSPARENT, // should be rendered last (semi transparent texture)
}

class BlockDef {
public:
    cell_t id;
    string name;
    BlockVisibility visibility = BlockVisibility.INVISIBLE;
    int txIndex;
    this() {
    }
    this(cell_t blockId, string blockName, BlockVisibility v, int tx) {
        id = blockId;
        name = blockName;
        visibility = v;
        txIndex = tx;
    }
    ~this() {
    }
    // blocks behind this block can be visible
    @property bool canPass() { 
        return visibility == BlockVisibility.INVISIBLE 
            || visibility == BlockVisibility.HALF_OPAQUE 
            || visibility == BlockVisibility.HALF_OPAQUE_SEPARATE_TX 
            || visibility == BlockVisibility.HALF_TRANSPARENT; 
    }
    // block is fully opaque (all blocks behind are invisible)
    @property bool isOpaque() {
        return visibility == BlockVisibility.OPAQUE
            || visibility == BlockVisibility.OPAQUE_SEPARATE_TX;
    }
    // block is visible
    @property bool isVisible() {
        return visibility != BlockVisibility.INVISIBLE;
    }

    @property bool terrainSmoothing() {
        return false;
    }

    /// create cube face
    //void createFace(World * world, Position & camPosition, Vector3d pos, Dir face, FloatArray & vertices, IntArray & indexes) {
    //}
    /// create faces
    //void createFaces(World * world, Position & camPosition, Vector3d pos, int visibleFaces, FloatArray & vertices, IntArray & indexes) {
    //}
}


// block type definitions
__gshared BlockDef BLOCK_DEFS[256];
// faster check for block->canPass()
__gshared bool BLOCK_TYPE_CAN_PASS[256];
// faster check for block->isOpaque()
__gshared bool BLOCK_TYPE_OPAQUE[256];
// faster check for block->isVisible()
__gshared bool BLOCK_TYPE_VISIBLE[256];
// faster check for block->isVisible()
__gshared bool BLOCK_TERRAIN_SMOOTHING[256];

/// registers new block type
void registerBlockType(BlockDef def) {
    if (BLOCK_DEFS[def.id]) {
        if (BLOCK_DEFS[def.id] is def)
            return;
        destroy(BLOCK_DEFS[def.id]);
    }
    BLOCK_DEFS[def.id] = def;
    // init property shortcuts
    BLOCK_TYPE_CAN_PASS[def.id] = def.canPass;
    BLOCK_TYPE_OPAQUE[def.id] = def.isOpaque;
    BLOCK_TYPE_VISIBLE[def.id] = def.isVisible;
    BLOCK_TERRAIN_SMOOTHING[def.id] = def.terrainSmoothing;
}

/// init block types array
__gshared static this() {
    import std.string;
    for (int i = 0; i < 256; i++) {
        if (!BLOCK_DEFS[i]) {
            registerBlockType(new BlockDef(cast(cell_t)i, "undef%d".format(i), BlockVisibility.INVISIBLE, 0));
        }
    }
    BLOCK_TYPE_CAN_PASS[BOUND_SKY] = false;
    BLOCK_TYPE_VISIBLE[BOUND_SKY] = false;
    BLOCK_TYPE_CAN_PASS[BOUND_BOTTOM] = false;
    BLOCK_TYPE_VISIBLE[BOUND_BOTTOM] = true;

    // empty cell
    registerBlockType(new BlockDef(0, "empty", BlockVisibility.INVISIBLE, 0));
    // standard block types
    registerBlockType(new BlockDef(1, "gray_brick", BlockVisibility.OPAQUE, 0));
    registerBlockType(new BlockDef(2, "brick", BlockVisibility.OPAQUE, 1));
    registerBlockType(new BlockDef(3, "bedrock", BlockVisibility.OPAQUE, 2));
    registerBlockType(new BlockDef(4, "clay", BlockVisibility.OPAQUE, 3));
    registerBlockType(new BlockDef(5, "cobblestone", BlockVisibility.OPAQUE, 4));
    registerBlockType(new BlockDef(6, "gravel", BlockVisibility.OPAQUE, 5));
    registerBlockType(new BlockDef(7, "red_sand", BlockVisibility.OPAQUE, 6));
    registerBlockType(new BlockDef(8, "sand", BlockVisibility.OPAQUE, 7));

    registerBlockType(new BlockDef(50, "box", BlockVisibility.HALF_OPAQUE, 50));

    //registerBlockType(new TerrainBlock(100, "terrain_bedrock", 2));
    //registerBlockType(new TerrainBlock(101, "terrain_clay", 3));
    //registerBlockType(new TerrainBlock(102, "terrain_cobblestone", 4));
    //registerBlockType(new TerrainBlock(103, "terrain_gravel", 5));
    //registerBlockType(new TerrainBlock(104, "terrain_red_sand", 6));
    //registerBlockType(new TerrainBlock(105, "terrain_sand", 7));

}
