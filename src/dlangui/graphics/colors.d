// Written in the D programming language.

/**
This module contains declaration of useful color related operations.

In dlangui, colors are represented as 32 bit uint AARRGGBB values.

Synopsis:

----
import dlangui.graphics.colors;

----

Copyright: Vadim Lopatin, 2015
License:   Boost License 1.0
Authors:   Vadim Lopatin, coolreader.org@gmail.com
*/
module dlangui.graphics.colors;

import dlangui.core.types;

private import std.string : strip;

/// special color constant to identify value as not a color (to use default/parent value instead)
immutable uint COLOR_UNSPECIFIED = 0xFFDEADFF;
/// transparent color constant
immutable uint COLOR_TRANSPARENT = 0xFFFFFFFF;

immutable string COLOR_DRAWABLE = "#color";


immutable uint COLOR_TRANSFORM_OFFSET_NONE = 0x80808080;
immutable uint COLOR_TRANSFORM_MULTIPLY_NONE = 0x40404040;

uint makeRGBA(T)(T r, T g, T b, T a) pure nothrow {
    return (cast(uint)a << 24)|(cast(uint)r << 16)|(cast(uint)g << 8)|(cast(uint)b);
}

/// blend two RGB pixels using alpha
uint blendARGB(uint dst, uint src, uint alpha) pure nothrow {
    uint dstalpha = dst >> 24;
    if (dstalpha > 0x80)
        return src;
    uint srcr = (src >> 16) & 0xFF;
    uint srcg = (src >> 8) & 0xFF;
    uint srcb = (src >> 0) & 0xFF;
    uint dstr = (dst >> 16) & 0xFF;
    uint dstg = (dst >> 8) & 0xFF;
    uint dstb = (dst >> 0) & 0xFF;
    uint ialpha = 256 - alpha;
    uint r = ((srcr * ialpha + dstr * alpha) >> 8) & 0xFF;
    uint g = ((srcg * ialpha + dstg * alpha) >> 8) & 0xFF;
    uint b = ((srcb * ialpha + dstb * alpha) >> 8) & 0xFF;
    return (r << 16) | (g << 8) | b;
}

//immutable int[3] COMPONENT_OFFSET_BGR = [2, 1, 0];
immutable int[3] COMPONENT_OFFSET_BGR = [2, 1, 0];
//immutable int[3] COMPONENT_OFFSET_BGR = [1, 2, 0];
immutable int[3] COMPONENT_OFFSET_RGB = [0, 1, 2];
immutable int COMPONENT_OFFSET_ALPHA = 3;
int subpixelComponentIndex(int x0, SubpixelRenderingMode mode) pure nothrow {
    switch (mode) with(SubpixelRenderingMode) {
        case RGB:
            return COMPONENT_OFFSET_BGR[x0];
        case BGR:
        default:
            return COMPONENT_OFFSET_BGR[x0];
    }
}

/// blend subpixel using alpha
void blendSubpixel(ubyte * dst, ubyte * src, uint alpha, int x0, SubpixelRenderingMode mode) {
    uint dstalpha = dst[COMPONENT_OFFSET_ALPHA];
    int offset = subpixelComponentIndex(x0, mode);
    uint srcr = src[offset];
    dst[COMPONENT_OFFSET_ALPHA] = 0;
    if (dstalpha > 0x80) {
        dst[offset] = cast(ubyte)srcr;
        return;
    }
    uint dstr = dst[offset];
    uint ialpha = 256 - alpha;
    uint r = ((srcr * ialpha + dstr * alpha) >> 8) & 0xFF;
    dst[offset] = cast(ubyte)r;
}

/// blend two alpha values 0..255 (255 is fully transparent, 0 is opaque)
uint blendAlpha(uint a1, uint a2) pure nothrow {
    if (!a1)
        return a2;
    if (!a2)
        return a1;
    return (((a1 ^ 0xFF) * (a2 ^ 0xFF)) >> 8) ^ 0xFF;
}

/// applies additional alpha to color
uint addAlpha(uint color, uint alpha) pure nothrow {
    alpha = blendAlpha(color >> 24, alpha);
    return (color & 0xFFFFFF) | (alpha << 24);
}

ubyte rgbToGray(uint color) pure nothrow {
    uint srcr = (color >> 16) & 0xFF;
    uint srcg = (color >> 8) & 0xFF;
    uint srcb = (color >> 0) & 0xFF;
    return cast(uint)(((srcr + srcg + srcg + srcb) >> 2) & 0xFF);
}


// todo
struct ColorTransformHandler {
    void initialize(ref ColorTransform transform) {

    }
    uint transform(uint color) {
        return color;
    }
}

uint transformComponent(int src, int addBefore, int multiply, int addAfter) pure nothrow {
    int add1 = (cast(int)(addBefore << 1)) - 0x100;
    int add2 = (cast(int)(addAfter << 1)) - 0x100;
    int mul = cast(int)(multiply << 2);
    int res = (((src + add1) * mul) >> 8) + add2;
    if (res < 0)
        res = 0;
    else if (res > 255)
        res = 255;
    return cast(uint)res;
}

uint transformRGBA(uint src, uint addBefore, uint multiply, uint addAfter) pure nothrow {
    uint a = transformComponent(src >> 24, addBefore >> 24, multiply >> 24, addAfter >> 24);
    uint r = transformComponent((src >> 16) & 0xFF, (addBefore >> 16) & 0xFF, (multiply >> 16) & 0xFF, (addAfter >> 16) & 0xFF);
    uint g = transformComponent((src >> 8) & 0xFF, (addBefore >> 8) & 0xFF, (multiply >> 8) & 0xFF, (addAfter >> 8) & 0xFF);
    uint b = transformComponent(src & 0xFF, addBefore & 0xFF, multiply & 0xFF, addAfter & 0xFF);
    return (a << 24) | (r << 16) | (g << 8) | b;
}

struct ColorTransform {
    uint addBefore = COLOR_TRANSFORM_OFFSET_NONE;
    uint multiply = COLOR_TRANSFORM_MULTIPLY_NONE;
    uint addAfter = COLOR_TRANSFORM_OFFSET_NONE;
    @property bool empty() const {
        return addBefore == COLOR_TRANSFORM_OFFSET_NONE 
            && multiply == COLOR_TRANSFORM_MULTIPLY_NONE
            && addAfter == COLOR_TRANSFORM_OFFSET_NONE;
    }
    uint transform(uint color) {
        return transformRGBA(color, addBefore, multiply, addAfter);
    }
}


/// blend two RGB pixels using alpha
ubyte blendGray(ubyte dst, ubyte src, uint alpha) pure nothrow {
    uint ialpha = 256 - alpha;
    return cast(ubyte)(((src * ialpha + dst * alpha) >> 8) & 0xFF);
}

/// returns true if color is #FFxxxxxx (color alpha is 255)
bool isFullyTransparentColor(uint color) pure nothrow {
    return (color >> 24) == 0xFF;
}

/// decode color string  supported formats: #RGB #ARGB #RRGGBB #AARRGGBB
uint decodeHexColor(string s, uint defValue = 0) pure {
    s = strip(s);
    switch (s) {
        case "@null":
        case "transparent":
            return COLOR_TRANSPARENT;
        case "black":
            return 0x000000;
        case "white":
            return 0xFFFFFF;
        case "red":
            return 0xFF0000;
        case "green":
            return 0x00FF00;
        case "blue":
            return 0x0000FF;
        case "gray":
            return 0x808080;
        case "lightgray":
        case "silver":
            return 0xC0C0C0;
        default:
            break;
    }
    if (s.length != 4 && s.length != 5 && s.length != 7 && s.length != 9)
        return defValue;
    if (s[0] != '#')
        return defValue;
    uint value = 0;
    foreach(i; 1 .. s.length) {
        uint digit = parseHexDigit(s[i]);
        if (digit == uint.max)
            return defValue;
        value = (value << 4) | digit;
        if (s.length < 7) // double the same digit for short forms
            value = (value << 4) | digit;
    }
    return value;
}

