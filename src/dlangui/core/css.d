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
    _webkit_hyphens, // -webkit-hyphens
    adobe_hyphenate, // adobe-hyphenate
    adobe_text_layout, // adobe-text-layout
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
    list_style_image
}

class CssStyle {
    CssDisplay display = CssDisplay.block;
    CssWhiteSpace whiteSpace = CssWhiteSpace.inherit;
    CssTextAlign textAlign = CssTextAlign.inherit;
    CssTextAlign textAlignLast = CssTextAlign.inherit;
    CssTextDecoration textDecoration = CssTextDecoration.inherit;
    CssHyphenate hyphenate = CssHyphenate.inherit;
    CssLength color;
    CssLength backgroundColor;
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
    if (src.length > 0 && src[0] == ch) {
        src = src[1 .. $];
        skipSpaces(src);
        return true;
    }
    return false;
}

private string replaceChar(string s, char from, char to) {
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

/// remove trailing _ from string, e.g. "body_" -> "body"
private string removeTrailingUnderscore(string s) {
    if (s.endsWith("_"))
        return s[0..$-1];
    return s;
}

private int parseEnumItem(E)(ref string src, int defValue = -1) if (is(E == enum)) {
    string ident = replaceChar(parseIdent(src), '-', '_');
    foreach(member; EnumMembers!E) {
        if (ident == removeTrailingUnderscore(member.to!string)) {
            return member.to!int;
        }
    }
    return defValue;
}

private CssDeclType parseCssDeclType(ref string src) {
    int n = parseEnumItem!CssDeclType(src, -1);
    if (n < 0)
        return CssDeclType.unknown;
    if (!skipChar(src, ':')) // no : after identifier
        return CssDeclType.unknown;
    return cast(CssDeclType)n;
}

private bool nextProperty(ref string str) {
    int pos = 0;
    for (; pos < str.length; pos++) {
        char ch = str[pos];
        if (ch == '}')
            break;
        if (ch == ';') {
            pos++;
            break;
        }
    }
    str = pos < str.length ? str[pos .. $] : null;
    skipSpaces(str);
    return !str.empty && str[0] != '}';
}

struct CssDeclItem {
    CssDeclType type;
    int value;
    string str;

    void apply(CssStyle style) {
        switch (type) with (CssDeclType) {
            case display: style.display = cast(CssDisplay)value; break;
            case white_space: style.whiteSpace = cast(CssWhiteSpace)value; break;
            case text_align: style.textAlign = cast(CssTextAlign)value; break;
            case text_align_last: style.textAlignLast = cast(CssTextAlign)value; break;
            case text_decoration: style.textDecoration = cast(CssTextDecoration)value; break;

            case _webkit_hyphens: // -webkit-hyphens
            case adobe_hyphenate: // adobe-hyphenate
            case adobe_text_layout: // adobe-text-layout
            case hyphenate: 
                style.hyphenate = cast(CssHyphenate)value; 
                break; // hyphenate

            case color:
                style.color = CssLength.unpack(value);
                break;
            case background_color:
                style.backgroundColor = CssLength.unpack(value);
                break;
            case vertical_align: break;
            case font_family: break; // id families like serif, sans-serif
            case font_names: break;   // string font name like Arial, Courier
            case font_size: break;
            case font_style: break;
            case font_weight: break;
            case text_indent: break;
            case line_height: break;
            case letter_spacing: break;
            case width: break;
            case height: break;
            case margin_left: break;
            case margin_right: break;
            case margin_top: break;
            case margin_bottom: break;
            case margin: break;
            case padding_left: break;
            case padding_right: break;
            case padding_top: break;
            case padding_bottom: break;
            case padding: break;
            case page_break_before: break;
            case page_break_after: break;
            case page_break_inside: break;
            case list_style: break;
            case list_style_type: break;
            case list_style_position: break;
            case list_style_image: break;
            default:
                break;
        }
    }
}

/// css declaration like { display: block; margin-top: 10px }
class CssDeclaration {
    private CssDeclItem[] _list;

    void apply(CssStyle style) {
        foreach(item; _list)
            item.apply(style);
    }

    bool parse(ref string src, bool mustBeInBrackets = true) {
        if (!skipSpaces(src))
            return false;
        if (mustBeInBrackets && !skipChar(src, '{'))
            return false; // decl must start with {
        for (;;) {
            CssDeclType propId = parseCssDeclType(src);
            if (propId != CssDeclType.unknown) {
                int n = -1;
                string s = null;
                switch(propId) with(CssDeclType) {
                    case display: n = parseEnumItem!CssDisplay(src, -1); break;
                    case white_space: n = parseEnumItem!CssWhiteSpace(src, -1); break;
                    case text_align: n = parseEnumItem!CssTextAlign(src, -1); break;
                    case text_align_last: n = parseEnumItem!CssTextAlign(src, -1); break;
                    case text_decoration: n = parseEnumItem!CssTextDecoration(src, -1); break;
                    case hyphenate:
                    case _webkit_hyphens: // -webkit-hyphens
                    case adobe_hyphenate: // adobe-hyphenate
                    case adobe_text_layout: // adobe-text-layout
                        n = parseEnumItem!CssHyphenate(src, -1); 
                        break; // hyphenate
                    case color:
                    case background_color:
                        CssLength v;
                        if (parseColor(src, v)) {
                            n = v.pack();
                        }
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
                if (n >= 0 || !s.empty) {
                    CssDeclItem item;
                    item.type = propId;
                    item.value = n;
                    item.str = s;
                    _list ~= item;
                }
            }
            if (!nextProperty(src))
                break;
        }
        if (mustBeInBrackets && !skipChar(src, '}'))
            return false;
        return _list.length > 0;
    }
}

private int hexDigit( char c )
{
    if ( c >= '0' && c <= '9' )
        return c-'0';
    if ( c >= 'A' && c <= 'F' )
        return c - 'A' + 10;
    if ( c >= 'a' && c <= 'f' )
        return c - 'a' + 10;
    return -1;
}

private int parseStandardColor(string ident) {
    switch(ident) {
        case "black": return 0x000000;
        case "green": return 0x008000;
        case "silver": return 0xC0C0C0;
        case "lime": return 0x00FF00;
        case "gray": return 0x808080;
        case "olive": return 0x808000;
        case "white": return 0xFFFFFF;
        case "yellow": return 0xFFFF00;
        case "maroon": return 0x800000;
        case "navy": return 0x000080;
        case "red": return 0xFF0000;
        case "blue": return 0x0000FF;
        case "purple": return 0x800080;
        case "teal": return 0x008080;
        case "fuchsia": return 0xFF00FF;
        case "aqua": return 0x00FFFF;
        default: return -1;
    }
}

private bool parseColor(ref string src, ref CssLength value)
{
    value.type = CssValueType.unspecified;
    value.value = 0;
    skipSpaces(src);
    if (src.empty)
        return false;
    string ident = parseIdent(src);
    if (!ident.empty) {
        switch(ident) {
            case "inherited":
                value.type = CssValueType.inherited;
                return true;
            case "none":
                return true;
            default:
                int v = parseStandardColor(ident);
                if (v >= 0) {
                    value.value = v;
                    value.type = CssValueType.color;
                    return true;
                }
                return false;
        }
    }
    char ch = src[0];
    if (ch == '#') {
        // #rgb or #rrggbb colors
        src = src[1 .. $];
        int nDigits = 0;
        for ( ; nDigits < src.length && hexDigit(src[nDigits])>=0; nDigits++ ) {
        }
        if ( nDigits==3 ) {
            int r = hexDigit( src[0] );
            int g = hexDigit( src[1] );
            int b = hexDigit( src[2] );
            value.type = CssValueType.color;
            value.value = (((r + r*16) * 256) | (g + g*16)) * 256 | (b + b*16);
            src = src[3..$];
            return true;
        } else if ( nDigits==6 ) {
            int r = hexDigit( src[0] ) * 16;
            r += hexDigit( src[1] );
            int g = hexDigit( src[2] ) * 16;
            g += hexDigit( src[3] );
            int b = hexDigit( src[4] ) * 16;
            b += hexDigit( src[5] );
            value.type = CssValueType.color;
            value.value = ((r * 256) | g) * 256 | b;
            src = src[6..$];
            return true;
        }
    }
    return false;
}


unittest {
    CssStyle style = new CssStyle();
    CssDeclaration decl = new CssDeclaration();
    CssWhiteSpace whiteSpace = CssWhiteSpace.inherit;
    CssTextAlign textAlign = CssTextAlign.inherit;
    CssTextAlign textAlignLast = CssTextAlign.inherit;
    CssTextDecoration textDecoration = CssTextDecoration.inherit;
    CssHyphenate hyphenate = CssHyphenate.inherit;
    string src = "{ display: inline; text-decoration: underline; white-space: pre; text-align: right; text-align-last: left; hyphenate: auto }";
    assert(decl.parse(src, true));
    assert(style.display == CssDisplay.block);
    assert(style.textDecoration == CssTextDecoration.inherit);
    assert(style.whiteSpace == CssWhiteSpace.inherit);
    assert(style.textAlign == CssTextAlign.inherit);
    assert(style.textAlignLast == CssTextAlign.inherit);
    assert(style.hyphenate == CssHyphenate.inherit);
    decl.apply(style);
    assert(style.display == CssDisplay.inline);
    assert(style.textDecoration == CssTextDecoration.underline);
    assert(style.whiteSpace == CssWhiteSpace.pre);
    assert(style.textAlign == CssTextAlign.right);
    assert(style.textAlignLast == CssTextAlign.left);
    assert(style.hyphenate == CssHyphenate.auto_);
}
