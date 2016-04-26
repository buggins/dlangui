module dminer.core.terrain;

import dminer.core.minetypes;
import dlangui.core.logger;


struct TerrainGen {
    private int dx;
    private int dy;
    private int xpow;
    private int ypow;
    private short[] data;
    private Random rnd;
    private void diamond(int x, int y, int size, int offset) {
        int avg = (get(x, y - size) + get(x + size, y) + get(x, y + size) + get(x - size, y)) >> 2;
        set(x, y, avg + offset);
    }
    private void square(int x, int y, int size, int offset) {
        int avg = (get(x - size, y - size) + get(x + size, y - size) + get(x - size, y + size) + get(x - size, y - size)) >> 2;
        set(x, y, avg + offset);
    }

    this(int xbits, int zbits) {
        xpow = xbits;
        ypow = zbits;
        dx = (1 << xpow) + 1;
        dy = (1 << ypow) + 1;
        data = new short[dx * dy];
    }
    ~this() {
    }
    void filter(int range) {
        short[] tmp = new short[dx * dy];
        int div = (range * 2 + 1) * (range * 2 + 1);
        for (int y = 0; y < dy; y++) {
            for (int x = 0; x < dx; x++) {
                int s = 0;
                for (int yy = -range; yy <= range; yy++) {
                    for (int xx = -range; xx <= range; xx++) {
                        s += get(x + xx, y + yy);
                    }
                }
                s /= div;
                tmp[(y << ypow) + y + x] = cast(short)s;
            }
        }
        int sz = dx * dy;
        data[0 .. sz] = tmp[0 .. sz];
    }

    void generate(int seed, short[] initData, int stepBits) {
        Log.d("TerrainGen.generate(initData.length=", initData.length, " stepBits=", stepBits, ")");
        rnd.setSeed(seed);
        int step = 1 << stepBits;
        int index = 0;
        for (int y = 0; y <= dy; y += step) {
            for (int x = 0; x <= dx; x += step) {
                set(x, y, initData[index++]);
            }
        }
        Log.f("last index = ", index);
        int half = step >> 1;
        while (half > 0) {
            Log.f("halfstep=", half);
            int scale = step;
            for (int y = half; y < dy; y += step) {
                for (int x = half; x < dx; x++) {
                    square(x, y, half, rnd.nextInt(scale * 2) - scale);
                }
            }
            for (int y = 0; y <= dy; y += half) {
                for (int x = (y + half) % step; x <= dx; x += step) {
                    diamond(x, y, half, rnd.nextInt(scale * 2) - scale);
                }
            }
            step >>= 1;
            half >>= 1;
        }
    }
    void generateWithScale(int seed, short[] initData, int stepBits, TerrainGen scaleMap) {
        Log.d("TerrainGen.generateWithScale(initData.length=", initData.length, " stepBits=", stepBits, ")");
        rnd.setSeed(seed);
        int step = 1 << stepBits;
        int index = 0;
        for (int y = 0; y <= dy; y += step) {
            for (int x = 0; x <= dx; x += step) {
                set(x, y, initData[index++]);
            }
        }
        Log.f("last index = ", index);
        int half = step >> 1;
        while (half > 0) {
            Log.f("halfstep=", half);
            for (int y = half; y < dy; y += step) {
                for (int x = half; x < dx; x++) {
                    int scale = (scaleMap.get(x, y) * step) >> 8;
                    scale = rnd.nextInt(scale * 2) - scale;
                    if (step < 4)
                        scale = 0;
                    square(x, y, half, scale);
                }
            }
            for (int y = 0; y <= dy; y += half) {
                for (int x = (y + half) % step; x <= dx; x += step) {
                    int scale = (scaleMap.get(x, y) * step) >> 8;
                    scale = rnd.nextInt(scale * 2) - scale;
                    if (step < 4)
                        scale = 0;
                    diamond(x, y, half, scale);
                }
            }
            step >>= 1;
            half >>= 1;
        }
    }
    @property int width() {
        return dx - 1;
    }
    @property int height() {
        return dy - 1;
    }
    int get(int x, int y) {
        if (x < 0 || y < 0 || x >= dx || y >= dy)
            return 0;
        return data[(y << ypow) + y + x];
    }
    int getHeightDiff(int x, int y) {
        import std.algorithm;
        int h0 = get(x, y);
        int h1 = get(x+1, y)-h0;
        int h2 = get(x-1, y)-h0;
        int h3 = get(x, y+1)-h0;
        int h4 = get(x, y-1)-h0;
        int mindh = min(h1, h2, h3, h4);
        int maxdh = max(h1, h2, h3, h4);
        return max(-mindh, maxdh);
    }
    void set(int x, int y, int value) {
        if (x < 0 || y < 0 || x >= dx || y >= dy)
            return;
        if (value < -32767)
            value = -32767;
        if (value > 32767)
            value = 32767;
        data[(y << ypow) + y + x] = cast(short)value;
    }
    /// ensure that data is in range [minvalue, maxvalue]
    void limit(int minvalue, int maxvalue) {
        // find actual min/max
        int minv, maxv;
        minv = maxv = get(0, 0);
        for (int y = 0; y <= dy; y++) {
            for (int x = 0; x <= dx; x++) {
                int v = get(x, y);
                if (minv > v)
                    minv = v;
                if (maxv < v)
                    maxv = v;
            }
        }
        int mul = (maxvalue - minvalue);
        int div = (maxv - minv);
        if (div > 0) {
            for (int y = 0; y <= dy; y++) {
                for (int x = 0; x <= dx; x++) {
                    set(x, y, minvalue + (get(x, y) - minv) * mul / div);
                }
            }
        }
    }
}


