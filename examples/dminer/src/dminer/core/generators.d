module dminer.core.generators;

import dminer.core.minetypes;
import dminer.core.blocks;
import dminer.core.world;
import dminer.core.terrain;
import dminer.core.chunk;


__gshared static short[] TERRAIN_INIT_DATA = [
    //                                      V
    10,  10,  10,  10,  30,  30,  30,  30,  30,  30,  30,  30,  10,  10,  10,  10,  10,
    10,  10,  20,  50,  50,  50,  50,  50,  50,  50,  50,  50,  20,  20,  20,  20,  10,
    10,  20,  20,  50,  50, 150,  50,  50,  50,  50, 250,  50,  50,  50,  20,  20,  10,
    10,  20,  50,  50,  50,  50,  50, 150,  50,  50,  50, 150,  50,  50,  50,  20,  10,
    10,  50, 250,  50,  50,  50,  50,  50,  50,  50,  50,  50,  50, 150,  50,  20,  30,
    30,  50,  50,  50,  50,  50, 150,  50,  50,  50, 250,  50,  50,  50,  50,  50,  30,
    30,  50,  50,  50,  50,  50,  50,  50, 100,  50,  50,  50,  80,  50, 250,  50,  30,
    30,  50,  50,  50,  50,  50,  50, 110,  80, 130,  50,  50, 250,  50,  50,  50,  30,
    30,  50,  50,  50,  50,  50, 150, 100,  50, 140,  50,  50,  50,  50,  50,  50,  30, // <==
    30,  50,  50,  50,  50,  50,  50, 110,  40, 120,  50,  90,  50, 250,  50,  50,  30,
    30,  50,  50,  50,  50, 150,  50,  50, 110,  50,  50,  50,  50,  50,  50,  50,  30,
    30,  50,  50,  50,  50,  50, 150,  50,  50,  50, 150,  50, 150,  50,  50,  50,  10,
    30,  50,  50,  50,  50,  50,  80,  50,  50, 150,  50,  50,  50,  50,  50,  50,  10,
    30,  50, 250,  80,  50,  50, 250,  50,  50,  50, 250,  50,  50,  50,  40,  50,  10,
    30,  20,  50,  50,  50,  50,  50,  50,  50,  50,  50,  50,  50,  40,  20,  20,  10,
    30,  20,  20,  50,  50,  50,  50,  50,  50,  50,  40,  20,  20,  20,  20,  20,  10,
    30,  30,  30,  30,  30,  30,  30,  30,  30,  30,  30,  30,  10,  10,  10,  10,  10,
    //                                      ^
];

__gshared static short[] TERRAIN_SCALE_DATA = [
    //                                      V
    20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,
    20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,
    20,  20,  20,  20, 120,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,
    20,  20,  20,  20,  20,  20,  20,  20,  40,  60,  50,  20,  20,  30,  20,  20,  20,
    20,  20, 120,  20,  20,  20,  20,  20,  20,  50,  20,  20,  20,  45,  20,  20,  20,
    20,  20,  20,  20,  20,  20,  20,  20,  80,  20,  50,  20,  40,  50,  40,  20,  20,
    20,  20,  20,  20,  20,  20,  90,  20,  80,  20,  80,  20,  20,  30,  20,  20,  20,
    20,  20,  20,  20,  20,  90,  20,  80,  30,  20,  40,  20,  20,  20,  20,  20,  20,
    20,  20,  20,  20,  20,  20,  90,  30,  20,  30,  50, 120,  20,  20,  20,  20,  20, // <==
    20,  20,  20,  20,  20,  20,  50,  20,  30,  20,  20,  20,  20,  20,  20,  20,  20,
    20,  20,  20,  20,  20,  20,  40,  70,  40,  90,  20,  40,  20,  20,  20,  20,  20,
    20,  20,  20,  20,  20,  20,  80,  20,  80,  20,  50,  70,  50,  20,  20,  20,  20,
    20,  20,  20,  20,  20,  20,  80,  20,  20,  20,  20,  60,  20,  20,  20,  20,  20,
    20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,
    20,  20,  20, 120,  20,  20,  20,  20,  20,  20,  20,  20,  20, 120,  20,  20,  20,
    20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,
    20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,
    //                                      ^
];

void initWorldTerrain(World world, int terrSizeBits = 10, int x0 = 0, int z0 = 0) {
    import dminer.core.terrain;
    int terrSize = 1 << terrSizeBits;
    TerrainGen scaleterr = TerrainGen(terrSizeBits, terrSizeBits); // 512x512
    scaleterr.generate(4321, TERRAIN_SCALE_DATA, terrSizeBits - 4); // init grid is 16x16 (1 << (9-7))
    //scaleterr.filter(1);
    //scaleterr.filter(2);
    scaleterr.limit(0, 90);
    TerrainGen terr = TerrainGen(terrSizeBits, terrSizeBits); // 512x512
    terr.generateWithScale(123456, TERRAIN_INIT_DATA, terrSizeBits - 4, scaleterr); // init grid is 16x16 (1 << (9-7))
    //terr.filter(1);
    terr.limit(5, CHUNK_DY * 3 / 4);
    terr.filter(1);
    for (int x = 0; x < terrSize; x++) {
        for (int z = 0; z < terrSize; z++) {
            int cellx = x0 + x - terrSize / 2;
            int cellz = z0 + z - terrSize / 2;
            int h = terr.get(x, z);
            int dh = terr.getHeightDiff(x, z);


            cell_t cell = BlockId.bedrock;
            //cell_t cell = BlockId.grass;
            //cell_t cell = BlockId.face_test;
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

            cell_t topcell = BlockId.bedrock;
            if (dh <= 1)
                topcell = BlockId.grass;

            for (int y = 0; y < h; y++) {
                world.setCell(cellx, y, cellz, cell);
            }
            world.setCell(cellx, h, cellz, topcell);
        }
    }
}


void makeCastleWall(World world, Vector3d start, Vector3d direction, int height, int length, int width, cell_t material) {
    Vector3d normal = direction.turnLeft;
    for (int x = 0; x < length; x++) {
        Vector3d x0 = start + direction * x;
        for (int y = 0; y < height; y++) {
            Vector3d y0 = x0;
            y0.y += y;
            for (int z = -width / 2; z <= width / 2; z++) {
                Vector3d z0 = y0 + normal * z;
                bool side = (z == -width/2 || z == width/2);
                cell_t cell = material;
                if (y >= height - 2) {
                    if (!side)
                        cell = BlockId.air;
                    else if ((x & 1) && (y >= height - 1)) {
                        cell = BlockId.air;
                    }
                }
                if (cell != BlockId.air)
                    world.setCell(z0.x, z0.y, z0.z, cell);
            }
        }
    }
}

void makeCastleWalls(World world, Vector3d start, int size, int height, int width, cell_t material) {
    world.makeCastleWall(Vector3d(start.x - size - width/2, start.y, start.z - size), Vector3d(1, 0, 0), height, size * 2 + width, width, material);
    world.makeCastleWall(Vector3d(start.x - size, start.y, start.z - size - width/2), Vector3d(0, 0, 1), height, size * 2 + width, width, material);
    world.makeCastleWall(Vector3d(start.x + size, start.y, start.z - size - width/2), Vector3d(0, 0, 1), height, size * 2 + width, width, material);
    world.makeCastleWall(Vector3d(start.x - size - width/2, start.y, start.z + size), Vector3d(1, 0, 0), height, size * 2 + width, width, material);
}

void prepareCastleBase(World world, Vector3d start, int size) {
    // basement - bedrock
    world.setCellRange(Vector3d(start.x - size - 3, start.y - 10, start.z - size - 3), Vector3d(size*2 + 6, 10, size*2 + 6), BlockId.bedrock);
    world.setCellRange(Vector3d(start.x - size - 4, start.y - 11, start.z - size - 4), Vector3d(size*2 + 8, 10, size*2 + 8), BlockId.bedrock);
    // empty
    world.setCellRange(Vector3d(start.x - size - 5, start.y, start.z - size - 5), Vector3d(size*2 + 10, 10, size*2 + 10), BlockId.air);
    world.setCellRange(Vector3d(start.x - size - 6, start.y + 1, start.z - size - 6), Vector3d(size*2 + 12, 10, size*2 + 12), BlockId.air);
    world.setCellRange(Vector3d(start.x - size - 7, start.y + 2, start.z - size - 7), Vector3d(size*2 + 14, 10, size*2 + 14), BlockId.air);
    // floor
    world.setCellRange(Vector3d(start.x - size, start.y - 10, start.z - size), Vector3d(size*2, 10, size*2), BlockId.red_sand);//cobblestone
}

void makeCastle(World world, Vector3d start, int size, int height) {
    world.prepareCastleBase(start, size);
    // main walls
    world.makeCastleWalls(start, size, height, 4, BlockId.brick);
    // gates
    world.setCellRange(Vector3d(start.x - 3, start.y - 1, start.z - size - 7), Vector3d(7, 1, 10), BlockId.cobblestone);
    world.setCellRange(Vector3d(start.x - 3, start.y - 2, start.z - size - 8), Vector3d(7, 1, 10), BlockId.cobblestone);
    world.setCellRange(Vector3d(start.x - 3, start.y - 3, start.z - size - 9), Vector3d(7, 1, 10), BlockId.cobblestone);
    world.setCellRange(Vector3d(start.x - 3, start.y, start.z - size - 4), Vector3d(7, height * 7 / 10, 7), BlockId.air);
    world.setCellRange(Vector3d(start.x - 4, start.y, start.z - size), Vector3d(9, height * 7 / 10 + 1, 1), BlockId.air);
    // corner towers
    world.makeCastleWalls(start + Vector3d(-size + 1, -5, -size + 1), 5, height + 2 + 5, 3, BlockId.gray_brick);
    world.makeCastleWalls(start + Vector3d(size - 1, -5, -size + 1), 5, height + 2 + 5, 3, BlockId.gray_brick);
    world.makeCastleWalls(start + Vector3d(-size + 1, -5, size - 1), 5, height + 2 + 5, 3, BlockId.gray_brick);
    world.makeCastleWalls(start + Vector3d(size - 1, -5, size - 1), 5, height + 2 + 5, 3, BlockId.gray_brick);
    // dungeon
    world.makeCastleWalls(start, size / 3, height * 15 / 10, 2, BlockId.gray_brick);
    world.setCellRange(Vector3d(start.x - 2, start.y, start.z - size - 4), Vector3d(5, height * 6 / 10, size), BlockId.air);
}
