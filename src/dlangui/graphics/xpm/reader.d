module dlangui.graphics.xpm.reader;

/**
 * Reading .xpm files.
 *
 * Copyright: Roman Chistokhodov, 2015
 * License:   Boost License 1.0
 * Authors:   Roman Chistokhodov, freeslave93@gmail.com
 *
 */

import dlangui.graphics.xpm.xpmcolors;

import dlangui.graphics.colors;
import dlangui.graphics.drawbuf;

import std.algorithm : startsWith, splitter, find, equal;
import std.array;
import std.string;
import std.range;
import std.exception;
import std.format : formattedRead;

private const(char)[] extractXPMString(const(char)[] str) {
    auto firstIndex = str.indexOf('"');
    if (firstIndex != -1) {
        auto secondIndex = str.indexOf('"', firstIndex+1);
        if (secondIndex != -1) {
            return str[firstIndex+1..secondIndex];
        }
    }
    return null;
}

private uint parseRGB(in char[] rgbStr)
{
    static ubyte parsePrimaryColor(const(char)[] subStr) {
        ubyte c;
        enforce(formattedRead(subStr, "%x", &c) == 1, "Could not parse RGB value");
        return c;
    }
    enforce(rgbStr.length == 6, rgbStr ~ " : RGB string must have length of 6");
    ubyte red = parsePrimaryColor(rgbStr[0..2]);
    ubyte green = parsePrimaryColor(rgbStr[2..4]);
    ubyte blue = parsePrimaryColor(rgbStr[4..6]);

    return makeRGBA(red, green, blue, 0);
}

//Unique hashes for non-empty strings with length <= 8
private ulong xpmHash(in char[] str) {
    ulong hash = 0;
    foreach(c; str.representation) {
        hash <<= 8;
        hash += c;
    }
    return hash;
}

ColorDrawBuf parseXPM(const(ubyte)[] data)
{
    auto buf = cast(const(char)[])(data);
    auto lines = buf.splitter('\n');

    enforce(!lines.empty, "No data");

    //Read magic
    auto firstLine = lines.front;
    enforce(firstLine.startsWith("/* XPM"), "No magic");
    lines.popFront();

    //Read values
    int w, h, ncols, cpp;
    while(!lines.empty) {
        auto str = extractXPMString(lines.front);

        if (str.length) {
            enforce(formattedRead(str, " %d %d %d %d", &w, &h, &ncols, &cpp) == 4, "Could not read values");
            enforce(cpp > 0, "Bad character per pixel value");
            enforce(cpp <= 8, "Character per pixel value is too big");
            lines.popFront();
            break;
        }
        lines.popFront();
    }

    //Read color map
    size_t colorsRead = 0;
    auto sortedColors = assumeSorted(predefinedColors);
    uint[ulong] colorMap;

    while(!lines.empty && colorsRead != ncols) {
        auto str = extractXPMString(lines.front);
        if (str.length) {
            auto key = str[0..cpp];


            auto tokens = str[cpp..$].strip.splitter(' ');
            auto prefixRange = tokens.find("c");

            enforce(!prefixRange.empty, "Could not find color visual prefix");

            auto colorRange = prefixRange.drop(1);
            enforce(!colorRange.empty, "Could not get color value for " ~ key);

            auto colorStr = colorRange.front;
            auto hash = xpmHash(key);

            enforce(hash !in colorMap, key ~ " : same key is defined twice");

            if (colorStr[0] == '#') {
                colorMap[hash] = parseRGB(colorStr[1..$]);
            } else if (colorStr == "None") {
                colorMap[hash] = makeRGBA(0,0,0,255);
            } else {
                auto t = sortedColors.equalRange(colorStr);
                enforce(!t.empty, "Could not find color named " ~ colorStr);
                auto c = t.front;

                colorMap[hash] = makeRGBA(c.red, c.green, c.blue, 0);
            }

            colorsRead++;
        }
        lines.popFront();
    }

    enforce(colorsRead == ncols, "Could not load color table");

    //Read pixels
    ColorDrawBuf colorBuf = new ColorDrawBuf(w, h);

    for (int y = 0; y<h && !lines.empty; y++) {
        auto str = extractXPMString(lines.front);
        uint* dstLine = colorBuf.scanLine(y);
        if (str.length) {
            enforce(str.length >= w*cpp, "Invalid pixel line");
            foreach(int x; 0 .. w) {
                auto pixelStr = str[x*cpp..(x+1)*cpp];
                auto colorPtr = xpmHash(pixelStr) in colorMap;
                enforce(colorPtr, "Unknown pixel : '" ~ str ~ "'");
                dstLine[x] = *colorPtr;
            }
        }
        lines.popFront();
    }

    return colorBuf;
}
