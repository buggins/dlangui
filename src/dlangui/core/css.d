// Written in the D programming language.

/**
This module contains implementation of CSS support - Cascading Style Sheets.


Synopsis:

----
import dlangui.core.css;

----

Copyright: Vadim Lopatin, 2015
License:   Boost License 1.0
Authors:   Vadim Lopatin, coolreader.org@gmail.com
*/
module dlangui.core.css;

import std.traits;
import std.conv : to;
import std.string : startsWith, endsWith;
import std.array : empty;
import std.algorithm : equal;

/// display property values
enum CssDisplay : ubyte {
    inherit,
    inline,
    block,
    list_item, 
    run_in, 
    compact, 
    marker, 
    table, 
    inline_table, 
    table_row_group, 
    table_header_group, 
    table_footer_group, 
    table_row, 
    table_column_group, 
    table_column, 
    table_cell, 
    table_caption,
    none
}

/// white-space property values
enum CssWhiteSpace : ubyte {
    inherit,
    normal,
    pre,
    nowrap
}

/// text-align property values
enum CssTextAlign : ubyte {
    inherit,
    left,
    right,
    center,
    justify
}

/// vertical-align property values
enum CssVerticalAlign : ubyte {
    inherit,
    baseline, 
    sub,
    super_,
    top,
    text_top,
    middle,
    bottom,
    text_bottom
}

/// text-decoration property values
enum CssTextDecoration : ubyte {
    // TODO: support multiple flags
    inherit = 0,
    none = 1,
    underline = 2,
    overline = 3,
    line_through = 4,
    blink = 5
}

/// hyphenate property values
enum CssHyphenate : ubyte {
    inherit = 0,
    none = 1,
    auto_ = 2
}

/// font-style property values
enum CssFontStyle : ubyte {
    inherit,
    normal,
    italic,
    oblique
}

/// font-weight property values
enum CssFontWeight : ubyte {
    inherit,
    normal,
    bold,
    bolder,
    lighter,
    fw_100,
    fw_200,
    fw_300,
    fw_400,
    fw_500,
    fw_600,
    fw_700,
    fw_800,
    fw_900
}

/// font-family property values
enum CssFontFamily : ubyte {
    inherit,
    serif,
    sans_serif,
    cursive,
    fantasy,
    monospace
}

/// page split property values
enum CssPageBreak : ubyte {
    inherit,
    auto_,
    always,
    avoid,
    left,
    right
}

/// list-style-type property values
enum CssListStyleType : ubyte {
    inherit,
    disc,
    circle,
    square,
    decimal,
    lower_roman,
    upper_roman,
    lower_alpha,
    upper_alpha,
    none
}

/// list-style-position property values
enum CssListStylePosition : ubyte {
    inherit,
    inside,
    outside
}

/// css length value types
enum CssValueType : ubyte {
    inherited,
    unspecified,
    px,
    em,
    ex,
    in_, // 2.54 cm
    cm,
    mm,
    pt, // 1/72 in
    pc, // 12 pt
    percent,
    color
}

/// css length value
struct CssLength {
    CssValueType type = CssValueType.px;  ///< type of value
    int value = 0;      ///< value (*256 for all types except % and px)
    this(int px_value ) {
        value = px_value;
    }
    this(CssValueType n_type, int n_value) {
        type = n_type;
        value = n_value;
    }
    bool opEqual(CssLength v) const
    {
        return type == v.type 
            && value == v.value;
    }
    int pack() { return cast(int)type + (value<<4); }
    static CssLength unpack(int v) { return CssLength(cast(CssValueType)(v & 0x0F), v >> 4); }
}

enum CssDeclType : ubyte {
    unknown,
    display,
    white_space,
    text_align,
    text_align_last,
    text_decoration,
    hyphenate, // hyphenate
    hyphenate2, // -webkit-hyphens
    hyphenate3, // adobe-hyphenate
    hyphenate4, // adobe-text-layout
    color,
    background_color,
    vertical_align,
    font_family, // id families like serif, sans-serif
    font_names,   // string font name like Arial, Courier
    font_size,
    font_style,
    font_weight,
    text_indent,
    line_height,
    letter_spacing,
    width,
    height,
    margin_left,
    margin_right,
    margin_top,
    margin_bottom,
    margin,
    padding_left,
    padding_right,
    padding_top,
    padding_bottom,
    padding,
    page_break_before,
    page_break_after,
    page_break_inside,
    list_style,
    list_style_type,
    list_style_position,
    list_style_image,
    stop,
    eol
}

/// skip spaces, move to new location, return true if there are some characters left in source line
private bool skipSpaces(ref string src) {
    for(;;) {
        if (src.empty) {
            src = null;
            return false;
        }
        char ch = src[0];
        if (ch == ' ' || ch == '\t' || ch == '\r' || ch == '\n') {
            src = src[1 .. $];
        } else {
            return !src.empty;
        }
    }
}

private bool isIdentChar(char ch) {
    return (ch >= 'A' && ch <='Z') || (ch >= 'a' && ch <='z') || (ch == '-') || (ch == '_');
}

/// parse css identifier
private string parseIdent(ref string src) {
    int pos = 0;
    for ( ; pos < src.length; pos++) {
        if (!src[pos].isIdentChar)
            break;
    }
    if (!pos)
        return null;
    string res = src[0 .. pos];
    if (pos < src.length)
        src = src[pos .. $];
    else
        src = null;
    skipSpaces(src);
    return res;
}

private bool skipChar(ref string src, char ch) {
    skipSpaces(src);
    if (src.length > 0 && src[0] == ':') {
        src = src[1 .. $];
        skipSpaces(src);
        return true;
    }
    return false;
}

string replaceChar(string s, char from, char to) {
    foreach(ch; s) {
        if (ch == from) {
            char[] buf;
            foreach(c; s)
                if (c == from)
                    buf ~= to;
                else
                    buf ~= c;
            return buf.dup;
        }
    }
    return s;
}

private int parseEnumItem(E)(ref string src, int defValue = -1) if (is(E == enum)) {
    string ident = replaceChar(parseIdent(src), '_', '-');
    foreach(member; EnumMembers!E) {
        if (member.to!string.equal(ident))
            return member;
    }
    return defValue;
}

private CssDeclType parseCssDeclType(ref string src) {
    string ident = parseIdent(src);
    if (ident.empty)
        return CssDeclType.unknown;
    if (!skipChar(src, ':')) // no : after identifier
        return CssDeclType.unknown;
    switch(ident) with (CssDeclType) {
        case "display": return display;
        case "white-space": return white_space;
        case "text-align": return text_align;
        case "text-align-last": return text_align_last;
        case "text-decoration": return text_decoration;
        case "hyphenate": return hyphenate; // hyphenate
        case "-webkit-hyphens": return hyphenate2; // -webkit-hyphens
        case "-adobe-hyphenate": return hyphenate3; // adobe-hyphenate
        case "-adobe-text-layout": return hyphenate4; // adobe-text-layout
        case "color": return color;
        case "background-color": return background_color;
        case "vertical-align": return vertical_align;
        case "font-family": return font_family; // id families like serif; sans-serif
        case "font-names": return font_names;   // string font name like Arial; Courier
        case "font-size": return font_size;
        case "font-style": return font_style;
        case "font-weight": return font_weight;
        case "text-indent": return text_indent;
        case "line-height": return line_height;
        case "letter-spacing": return letter_spacing;
        case "width": return width;
        case "height": return height;
        case "margin-left": return margin_left;
        case "margin-right": return margin_right;
        case "margin-top": return margin_top;
        case "margin-bottom": return margin_bottom;
        case "margin": return margin;
        case "padding-left": return padding_left;
        case "padding-right": return padding_right;
        case "padding-top": return padding_top;
        case "padding-bottom": return padding_bottom;
        case "padding": return padding;
        case "page-break-before": return page_break_before;
        case "page-break-after": return page_break_after;
        case "page-break-inside": return page_break_inside;
        case "list-style": return list_style;
        case "list-style-type": return list_style_type;
        case "list-style-position": return list_style_position;
        case "list-style-image": return list_style_image;
        default:
            return CssDeclType.unknown;
    }
}

class CssDeclaration {
    bool parse(ref string src) {
        if (!skipSpaces(src))
            return false;
        if (!skipChar(src, '{'))
            return false; // decl must start with {
        CssDeclType propId = parseCssDeclType(src);
        int n = -1;
        switch(propId) with(CssDeclType) {
            case display: n = parseEnumItem!CssDisplay(src, -1); break;
            case white_space: n = parseEnumItem!CssWhiteSpace(src, -1); break;
            case text_align: n = parseEnumItem!CssTextAlign(src, -1); break;
            case text_align_last: n = parseEnumItem!CssTextAlign(src, -1); break;
            case text_decoration: n = parseEnumItem!CssTextDecoration(src, -1); break;
            case hyphenate:
            case hyphenate2:
            case hyphenate3:
            case hyphenate4:
                n = parseEnumItem!CssHyphenate(src, -1); 
                break; // hyphenate
            case color:
                //n = parseEnumItem!Css(src, -1); 
                break;
            case background_color: 
                //n = parseEnumItem!Css(src, -1); 
                break;
            case vertical_align: n = parseEnumItem!CssVerticalAlign(src, -1); break;
            case font_family: n = parseEnumItem!CssFontFamily(src, -1); break; // id families like serif, sans-serif
            case font_names:
                //n = parseEnumItem!Css(src, -1); 
                break;   // string font name like Arial, Courier
            case font_size:
                //n = parseEnumItem!Css(src, -1); 
                break;
            case font_style: n = parseEnumItem!CssFontStyle(src, -1); break;
            case font_weight:
                //n = parseEnumItem!Css(src, -1); 
                break;
            case text_indent: 
                //n = parseEnumItem!CssTextIndent(src, -1); 
                break;
            case line_height:
            case letter_spacing:
            case width:
            case height:
            case margin_left:
            case margin_right:
            case margin_top:
            case margin_bottom:
            case padding_left:
            case padding_right:
            case padding_top:
            case padding_bottom:
                //n = parseEnumItem!Css(src, -1); 
                break;
            case margin: 
            case padding: 
                //n = parseEnumItem!Css(src, -1); 
                break;
            case page_break_before:
            case page_break_inside:
            case page_break_after:
                n = parseEnumItem!CssPageBreak(src, -1); 
                break;
            case list_style:
                //n = parseEnumItem!Css(src, -1); 
                break;
            case list_style_type: n = parseEnumItem!CssListStyleType(src, -1); break;
            case list_style_position: n = parseEnumItem!CssListStylePosition(src, -1); break;
            case list_style_image: 
                //n = parseEnumItem!CssListStyleImage(src, -1); 
                break;
            default:
                break;
        }
        return true;
    }
}
