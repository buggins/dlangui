module dminer.core.blocks;

import dminer.core.minetypes;
import dminer.core.world;
import dlangui.graphics.scene.mesh;

immutable string BLOCK_TEXTURE_FILENAME = "blocks";
immutable int BLOCK_TEXTURE_DX = 1024;
immutable int BLOCK_TEXTURE_DY = 1024;
immutable int BLOCK_SPRITE_SIZE = 16;
immutable int BLOCK_SPRITE_STEP = 16;
immutable int BLOCK_SPRITE_OFFSET = 0;
immutable int BLOCK_TEXTURE_SPRITES_PER_LINE = 1024/16;
immutable int VERTEX_COMPONENTS = 12;

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

    /// add cube face
    protected void addFace(Vector3d pos, Dir face, Mesh mesh, int textureIndex) {
        ushort startVertexIndex = cast(ushort)mesh.vertexCount;
        float[VERTEX_COMPONENTS * 4] vptr;
        ushort[6] iptr;
        createFaceMesh(vptr.ptr, face, pos.x, pos.y, pos.z, textureIndex);
        for (int i = 0; i < 6; i++)
            iptr[i] = cast(ushort)(startVertexIndex + face_indexes[i]);
        mesh.addVertexes(vptr);
        mesh.addPart(PrimitiveType.triangles, iptr);
    }

    /// create cube face
    void createFace(World world, ref Position camPosition, Vector3d pos, Dir face, Mesh mesh) {
        addFace(pos, face, mesh, txIndex);
    }
    /// create faces
    void createFaces(World world, ref Position camPosition, Vector3d pos, int visibleFaces, Mesh mesh) {
        for (int i = 0; i < 6; i++)
            if (visibleFaces & (1 << i))
                createFace(world, camPosition, pos, cast(Dir)i, mesh);
    }
}


// pos, normal, color, tx


/* North, z=-1
      Y^
     0 | 1
X<-----x-----
     3 | 2
*/

private immutable float CCC = 0.5; // cell cube coordinates
private immutable float TC0 = 0.0;
private immutable float TC1 = 0.99;

__gshared static const float[VERTEX_COMPONENTS * 4] face_vertices_north =
[
     CCC,  CCC, -CCC,	0.0, 0.0, -1.0,		1.0, 1.0, 1.0, 1.0,		TC0, TC0,
    -CCC,  CCC, -CCC,	0.0, 0.0, -1.0,		1.0, 1.0, 1.0, 1.0,		TC1, TC0,
    -CCC, -CCC, -CCC,	0.0, 0.0, -1.0,		1.0, 1.0, 1.0, 1.0,		TC1, TC1,
     CCC, -CCC, -CCC,	0.0, 0.0, -1.0,		1.0, 1.0, 1.0, 1.0,		TC0, TC1,
];

/* South, z=1
      Y^
     0 | 1
  -----x----->X
     3 | 2
*/

__gshared static const float[VERTEX_COMPONENTS * 4] face_vertices_south =
[
   -CCC,  CCC, CCC,    0.0, 0.0, 1.0,		1.0, 1.0, 1.0, 1.0,		TC0, TC0,
    CCC,  CCC, CCC,    0.0, 0.0, 1.0,		1.0, 1.0, 1.0, 1.0,		TC1, TC0,
    CCC, -CCC, CCC,    0.0, 0.0, 1.0,		1.0, 1.0, 1.0, 1.0,		TC1, TC1,
   -CCC, -CCC, CCC,    0.0, 0.0, 1.0,		1.0, 1.0, 1.0, 1.0,		TC0, TC1,
];

/* West, x=-1
      Y^
     0 | 1
  -----x----->Z
     3 | 2
*/

__gshared static const float[VERTEX_COMPONENTS * 4] face_vertices_west =
[
    -CCC,  CCC, -CCC,	1.0, 0.0, 0.0,		1.0, 1.0, 1.0, 1.0,		TC0, TC0,
    -CCC,  CCC,  CCC,	1.0, 0.0, 0.0,		1.0, 1.0, 1.0, 1.0,		TC1, TC0,
    -CCC, -CCC,  CCC,	1.0, 0.0, 0.0,		1.0, 1.0, 1.0, 1.0,		TC1, TC1,
    -CCC, -CCC, -CCC,	1.0, 0.0, 0.0,		1.0, 1.0, 1.0, 1.0,		TC0, TC1
];

/* East, x=1
      Y^
     0 | 1
Z<-----x-----
     3 | 2
*/

__gshared static const float[VERTEX_COMPONENTS * 4] face_vertices_east =
[
    CCC,  CCC,  CCC,	-1.0, 0.0, 0.0,		1.0, 1.0, 1.0, 1.0,		TC0, TC0,
    CCC,  CCC, -CCC,	-1.0, 0.0, 0.0,		1.0, 1.0, 1.0, 1.0,		TC1, TC0,
    CCC, -CCC, -CCC,	-1.0, 0.0, 0.0,		1.0, 1.0, 1.0, 1.0,		TC1, TC1,
    CCC, -CCC,  CCC,	-1.0, 0.0, 0.0,		1.0, 1.0, 1.0, 1.0,		TC0, TC1,
];

/* Up, y=1

     0 | 1
  -----x----->X
     3 | 2
      Zv
*/

__gshared static const float[VERTEX_COMPONENTS * 4] face_vertices_up =
[
    -CCC, CCC, -CCC,	0.0, 1.0, 0.0,		1.0, 1.0, 1.0, 1.0,		TC0, TC0,
     CCC, CCC, -CCC,	0.0, 1.0, 0.0,		1.0, 1.0, 1.0, 1.0,		TC1, TC0,
     CCC, CCC,  CCC,	0.0, 1.0, 0.0,		1.0, 1.0, 1.0, 1.0,		TC1, TC1,
    -CCC, CCC,  CCC,	0.0, 1.0, 0.0,		1.0, 1.0, 1.0, 1.0,		TC0, TC1,
];

/* Down, y=-1
     0 | 1
X<-----x-----
     3 | 2
      Zv
*/

__gshared static const float[VERTEX_COMPONENTS * 4] face_vertices_down =
[
     CCC, -CCC,-CCC,	0.0, -1.0, 0.0,		1.0, 1.0, 1.0, 1.0,		TC0, TC0,
    -CCC, -CCC,-CCC,	0.0, -1.0, 0.0,		1.0, 1.0, 1.0, 1.0,		TC1, TC0,
    -CCC, -CCC, CCC,	0.0, -1.0, 0.0,		1.0, 1.0, 1.0, 1.0,		TC1, TC1,
     CCC, -CCC, CCC,	0.0, -1.0, 0.0,		1.0, 1.0, 1.0, 1.0,		TC0, TC1,
];

__gshared static const ushort[6] face_indexes =
[
    2, 1, 0, 0, 3, 2 // CCW
];

__gshared static const ushort[6] face_indexes_back =
[
    0, 2, 1, 2, 3, 1
];

static void fillFaceMesh(float * data, const float * src, float x0, float y0, float z0, int tileX, int tileY) {
    for (int i = 0; i < 4; i++) {
        const float * srcvertex = src + i * VERTEX_COMPONENTS;
        float * dstvertex = data + i * VERTEX_COMPONENTS;
        for (int j = 0; j < VERTEX_COMPONENTS; j++) {
            float v = srcvertex[j];
            switch (j) {
                case 0: // x
                    v += x0;
                    break;
                case 1: // y
                    v += y0;
                    break;
                case 2: // z
                    v += z0;
                    break;
                case 10: // tx.u
                    v = ((tileX + v * BLOCK_SPRITE_SIZE)) / cast(float)BLOCK_TEXTURE_DX;
                    break;
                case 11: // tx.v
                    //v = (BLOCK_TEXTURE_DY - (tileY + v * BLOCK_SPRITE_SIZE)) / cast(float)BLOCK_TEXTURE_DY;
                    v = ((tileY + v * BLOCK_SPRITE_SIZE)) / cast(float)BLOCK_TEXTURE_DY;
                    break;
                default:
                    break;
            }
            dstvertex[j] = v;
        }
    }
}

static void createFaceMesh(float * data, Dir face, float x0, float y0, float z0, int tileIndex) {

    int tileX = (tileIndex % BLOCK_TEXTURE_SPRITES_PER_LINE) * BLOCK_SPRITE_STEP + BLOCK_SPRITE_OFFSET;
    int tileY = (tileIndex / BLOCK_TEXTURE_SPRITES_PER_LINE) * BLOCK_SPRITE_STEP + BLOCK_SPRITE_OFFSET;
    // data is 11 comp * 4 vert floats
    switch (face) with(Dir) {
        default:
        case NORTH:
            fillFaceMesh(data, face_vertices_north.ptr, x0, y0, z0, tileX, tileY);
            break;
        case SOUTH:
            fillFaceMesh(data, face_vertices_south.ptr, x0, y0, z0, tileX, tileY);
            break;
        case WEST:
            fillFaceMesh(data, face_vertices_west.ptr, x0, y0, z0, tileX, tileY);
            break;
        case EAST:
            fillFaceMesh(data, face_vertices_east.ptr, x0, y0, z0, tileX, tileY);
            break;
        case UP:
            fillFaceMesh(data, face_vertices_up.ptr, x0, y0, z0, tileX, tileY);
            break;
        case DOWN:
            fillFaceMesh(data, face_vertices_down.ptr, x0, y0, z0, tileX, tileY);
            break;
    }
}



// block type definitions
__gshared BlockDef[256] BLOCK_DEFS;
// faster check for block->canPass()
__gshared bool[256] BLOCK_TYPE_CAN_PASS;
// faster check for block->isOpaque()
__gshared bool[256] BLOCK_TYPE_OPAQUE;
// faster check for block->isVisible()
__gshared bool[256] BLOCK_TYPE_VISIBLE;
// faster check for block->isVisible()
__gshared bool[256] BLOCK_TERRAIN_SMOOTHING;

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

enum BlockImage : int {
    stone,
    grass_top,
    grass_side,
    grass_top_footsteps,
    dirt,
    bedrock,
    sand,
    gravel,
    sandstone,
    clay,
    cobblestone,
    cobblestone_mossy,
    brick,
    stonebrick,
    red_sand,

    face_test=64,
}

enum BlockId : cell_t {
    air, // 0
    gray_brick,
    brick,
    bedrock,
    clay,
    cobblestone,
    gravel,
    red_sand,
    sand,
    dirt,
    grass,
    face_test
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
    registerBlockType(new BlockDef(BlockId.air, "air", BlockVisibility.INVISIBLE, 0));
    // standard block types
    registerBlockType(new BlockDef(BlockId.gray_brick, "gray_brick", BlockVisibility.OPAQUE, BlockImage.stonebrick));
    registerBlockType(new BlockDef(BlockId.brick, "brick", BlockVisibility.OPAQUE, BlockImage.brick));
    registerBlockType(new BlockDef(BlockId.bedrock, "bedrock", BlockVisibility.OPAQUE, BlockImage.bedrock));
    registerBlockType(new BlockDef(BlockId.clay, "clay", BlockVisibility.OPAQUE, BlockImage.clay));
    registerBlockType(new BlockDef(BlockId.cobblestone, "cobblestone", BlockVisibility.OPAQUE, BlockImage.cobblestone));
    registerBlockType(new BlockDef(BlockId.gravel, "gravel", BlockVisibility.OPAQUE, BlockImage.gravel));
    registerBlockType(new BlockDef(BlockId.red_sand, "red_sand", BlockVisibility.OPAQUE, BlockImage.red_sand));
    registerBlockType(new BlockDef(BlockId.sand, "sand", BlockVisibility.OPAQUE, BlockImage.sand));
    registerBlockType(new BlockDef(BlockId.dirt, "dirt", BlockVisibility.OPAQUE, BlockImage.dirt));
    registerBlockType(new CustomTopBlock(BlockId.grass, "grass", BlockVisibility.OPAQUE, BlockImage.dirt, BlockImage.grass_top, BlockImage.grass_side));


    // for face texture test
    registerBlockType(new BlockDef(BlockId.face_test, "face_test", BlockVisibility.OPAQUE, BlockImage.face_test));

    //registerBlockType(new BlockDef(50, "box", BlockVisibility.HALF_OPAQUE, 50));

    //registerBlockType(new TerrainBlock(100, "terrain_bedrock", 2));
    //registerBlockType(new TerrainBlock(101, "terrain_clay", 3));
    //registerBlockType(new TerrainBlock(102, "terrain_cobblestone", 4));
    //registerBlockType(new TerrainBlock(103, "terrain_gravel", 5));
    //registerBlockType(new TerrainBlock(104, "terrain_red_sand", 6));
    //registerBlockType(new TerrainBlock(105, "terrain_sand", 7));

}

class CustomTopBlock : BlockDef {
public:
    int topTxIndex;
    int sideTxIndex;
    this(cell_t blockId, string blockName, BlockVisibility v, int tx, int topTx, int sideTx) {
        super(blockId, blockName, BlockVisibility.OPAQUE, tx);
        topTxIndex = topTx;
        sideTxIndex = sideTx;
    }
    ~this() {
    }

    /// create cube face
    override void createFace(World world, ref Position camPosition, Vector3d pos, Dir face, Mesh mesh) {
        // checking cell above
        cell_t blockAbove = world.getCell(pos.x, pos.y + 1, pos.z);
        int tx = txIndex;
        if (BLOCK_TYPE_CAN_PASS[blockAbove]) {
            if (face == Dir.UP) {
                tx = topTxIndex;
            } else if (face != Dir.DOWN) {
                tx = sideTxIndex;
            }
        }
        addFace(pos, face, mesh, tx);
    }
}

