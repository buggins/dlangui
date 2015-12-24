// Written in the D programming language.

/**
This module contains implementation of CSS support - Cascading Style Sheets.

Port of CoolReader Engine written in C++.

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
import std.string;
import std.array : empty;
import std.algorithm : equal;

import dlangui.core.dom;

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
struct CssValue {

    int value = 0;      ///< value (*256 for all types except % and px)
    CssValueType type = CssValueType.px;  ///< type of value

    this(int px_value ) {
        value = px_value;
    }
    this(CssValueType n_type, int n_value) {
        type = n_type;
        value = n_value;
    }
    bool opEqual(CssValue v) const
    {
        return type == v.type 
            && value == v.value;
    }

    static const CssValue inherited = CssValue(CssValueType.inherited, 0);
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
    //font_names,   // string font name like Arial, Courier
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
    CssVerticalAlign verticalAlign = CssVerticalAlign.inherit;
    CssFontFamily fontFamily = CssFontFamily.inherit;
    CssFontStyle fontStyle = CssFontStyle.inherit;
    CssPageBreak pageBreakBefore = CssPageBreak.inherit;
    CssPageBreak pageBreakInside = CssPageBreak.inherit;
    CssPageBreak pageBreakAfter = CssPageBreak.inherit;
    CssListStyleType listStyleType = CssListStyleType.inherit;
    CssListStylePosition listStylePosition = CssListStylePosition.inherit;
    CssFontWeight fontWeight = CssFontWeight.inherit;
    string fontFaces;
    CssValue color = CssValue.inherited;
    CssValue backgroundColor = CssValue.inherited;
    CssValue lineHeight = CssValue.inherited;
    CssValue letterSpacing = CssValue.inherited;
    CssValue width = CssValue.inherited;
    CssValue height = CssValue.inherited;
    CssValue marginLeft = CssValue.inherited;
    CssValue marginRight = CssValue.inherited;
    CssValue marginTop = CssValue.inherited;
    CssValue marginBottom = CssValue.inherited;
    CssValue paddingLeft = CssValue.inherited;
    CssValue paddingRight = CssValue.inherited;
    CssValue paddingTop = CssValue.inherited;
    CssValue paddingBottom = CssValue.inherited;
    CssValue fontSize = CssValue.inherited;
    CssValue textIndent = CssValue.inherited;
}

/// selector rule type
enum CssSelectorRuleType : ubyte {
    universal,     // *
    parent,        // E > F
    ancessor,      // E F
    predecessor,   // E + F
    attrset,       // E[foo]
    attreq,        // E[foo="value"]
    attrhas,       // E[foo~="value"]
    attrstarts,    // E[foo|="value"]
    id,            // E#id
    class_          // E.class
}

class CssSelectorRule
{
private:
    CssSelectorRuleType _type;
    elem_id _id;
    attr_id _attrid;
    CssSelectorRule _next;
    string _value;
public:
    this(CssSelectorRuleType type) { 
        _type = type;
    }
    this(const CssSelectorRule v) {
        _type = v._type;
        _id = v._id;
        _attrid = v._attrid;
        _value = v._value;
    }
    ~this() { 
        //if (_next) 
        //    destroy(_next); 
    }

    @property elem_id id() { return _id; }
    @property void id(elem_id newid) { _id = newid; }
    @property attr_id attrid() { return _attrid; }
    @property void setAttr(attr_id newid, string value) { _attrid = newid; _value = value; }
    @property CssSelectorRule next() { return _next; }
    @property void next(CssSelectorRule v) { _next = v; }
    /// check condition for node
    bool check(ref Node node) {
        if (!node || !node.parent)
            return false;
        switch (_type) with (CssSelectorRuleType) {
            case parent:        // E > F
                node = node.parent;
                if (!node)
                    return false;
                return node.id == _id;

            case ancessor:      // E F
                for (;;) {
                    node = node.parent;
                    if (!node)
                        return false;
                    if (node.id == _id)
                        return true;
                }

            case predecessor:   // E + F
                int index = node.index;
                // while
                if (index > 0) {
                    Node elem = node.parent.childElement(index-1, _id);
                    if ( elem ) {
                        node = elem;
                        //CRLog::trace("+ selector: found pred element");
                        return true;
                    }
                    //index--;
                }
                return false;

            case attrset:       // E[foo]
                return node.hasAttr(_attrid);

            case attreq:        // E[foo="value"]
                string val = node.attrValue(Ns.any, _attrid);
                return (val == _value);

            case attrhas:       // E[foo~="value"]
                // one of space separated values
                string val = node.attrValue(Ns.any, _attrid);
                int p = val.indexOf(_value);
                if (p < 0)
                    return false;
                if ( (p > 0 && val[p - 1] != ' ') 
                        || ( p + _value.length < val.length && val[p + _value.length] != ' '))
                    return false;
                return true;

            case attrstarts:    // E[foo|="value"]
                string val = node.attrValue(Ns.any, _attrid);
                if (_value.length > val.length)
                    return false;
                return val[0 .. _value.length] == _value;

            case id:            // E#id
                string val = node.attrValue(Ns.any, Attr.id);
                return val == _value;

            case class_:         // E.class
                string val = node.attrValue(Ns.any, Attr.class_);
                return !val.icmp(_value);

            case universal:     // *
                return true;

            default:
                return true;
        }
    }
}

/** simple CSS selector

Currently supports only element name and universal selector.

- * { } - universal selector
- element-name { } - selector by element name
- element1, element2 { } - several selectors delimited by comma
*/
class CssSelector {
private:
    uint _id;
    CssDeclaration _decl;
    int _specificity;
    CssSelector _next;
    CssSelectorRule _rules;
    void insertRuleStart(CssSelectorRule rule) {
    }
    void insertRuleAfterStart(CssSelectorRule rule) {
    }
public:
    this(CssSelector v) {
        _id = v._id;
        _decl = v._decl;
        _specificity = v._specificity;
    }
    this() { }
    ~this() {
        //if (_next)
        //    destroy(_next);
        //if (_rules) 
        //    destroy(_rules); 
    }
    bool parse(ref string str) { //, lxmlDocBase * doc
        return false;
    }
    @property uint tagId() { return _id; }
    bool check(const Node node) const {
        // TODO
        return false;
    }
    /// apply to style if selector matches
    void apply(const Node node, CssStyle style) const
    {
        if (check(node))
            _decl.apply(style);
    }
    void setDeclaration(CssDeclaration decl) { 
        _decl = decl; 
    }
    int getSpecificity() { 
        return _specificity;
    }
    @property CssSelector next() { return _next; }
    @property void next(CssSelector next) { _next = next; }
    //lUInt32 getHash();
}

struct CssDeclItem {
    CssDeclType type = CssDeclType.unknown;
    union {
        int value;
        CssValue length;
    }
    string str;

    void apply(CssStyle style) const {
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

            case color: style.color = length; break;
            case background_color: style.backgroundColor = length; break;
            case vertical_align: style.verticalAlign = cast(CssVerticalAlign)value; break;
            case font_family:
                if (value >= 0)
                    style.fontFamily = cast(CssFontFamily)value;
                if (!str.empty)
                    style.fontFaces = str;
                break; // id families like serif, sans-serif
            //case font_names: break;   // string font name like Arial, Courier
            case font_style: style.fontStyle = cast(CssFontStyle)value; break;
            case font_weight: style.fontWeight = cast(CssFontWeight)value; break;
            case text_indent: style.textIndent = length; break;
            case font_size: style.fontSize = length; break;
            case line_height: style.lineHeight = length; break;
            case letter_spacing: style.letterSpacing = length; break;
            case width: style.width = length; break;
            case height: style.height = length; break;
            case margin_left: style.marginLeft = length; break;
            case margin_right: style.marginRight = length; break;
            case margin_top: style.marginTop = length; break;
            case margin_bottom: style.marginBottom = length; break;
            case padding_left: style.paddingLeft = length; break;
            case padding_right: style.paddingRight = length; break;
            case padding_top: style.paddingTop = length; break;
            case padding_bottom: style.paddingBottom = length; break;
            case page_break_before: style.pageBreakBefore = cast(CssPageBreak)value; break;
            case page_break_after: style.pageBreakAfter = cast(CssPageBreak)value; break;
            case page_break_inside: style.pageBreakInside = cast(CssPageBreak)value; break;
            case list_style: break; // TODO
            case list_style_type: style.listStyleType = cast(CssListStyleType)value; break;
            case list_style_position: style.listStylePosition = cast(CssListStylePosition)value; break;
            case list_style_image: break; // TODO
            default:
                break;
        }
    }
}

/// css declaration like { display: block; margin-top: 10px }
class CssDeclaration {
    private CssDeclItem[] _list;

    private void addLengthDecl(CssDeclType type, CssValue len) {
        CssDeclItem item;
        item.type = type;
        item.length = len;
        _list ~= item;
    }

    private void addDecl(CssDeclType type, int value, string str) {
        CssDeclItem item;
        item.type = type;
        item.value = value;
        item.str = str;
        _list ~= item;
    }

    void apply(CssStyle style) const {
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
            if (src.empty)
                break;
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
                        CssValue v;
                        if (parseColor(src, v)) {
                            addLengthDecl(propId, v);
                        }
                        break;
                    case vertical_align: n = parseEnumItem!CssVerticalAlign(src, -1); break;
                    case font_family: // id families like serif, sans-serif
                        string[] list;
                        string[] faceList;
                        if (splitPropertyValueList(src, list)) {
                            foreach(item; list) {
                                string name = item;
                                int family = parseEnumItem!CssFontFamily(name, -1); 
                                if (family != -1) {
                                    // family name, e.g. sans-serif
                                    n = family;
                                } else {
                                    faceList ~= item;
                                }
                            }
                        }
                        s = joinPropertyValueList(faceList);
                        break; 
                    case font_style: n = parseEnumItem!CssFontStyle(src, -1); break;
                    case font_weight:
                        n = parseEnumItem!CssFontWeight(src, -1);
                        if (n < 0) {
                            CssValue value;
                            if (parseLength(src, value)) {
                                if (value.type == CssValueType.px) {
                                    if (value.value < 150)
                                        n = CssFontWeight.fw_100;
                                    else if (value.value < 250)
                                        n = CssFontWeight.fw_200;
                                    else if (value.value < 350)
                                        n = CssFontWeight.fw_300;
                                    else if (value.value < 450)
                                        n = CssFontWeight.fw_400;
                                    else if (value.value < 550)
                                        n = CssFontWeight.fw_500;
                                    else if (value.value < 650)
                                        n = CssFontWeight.fw_600;
                                    else if (value.value < 750)
                                        n = CssFontWeight.fw_700;
                                    else if (value.value < 850)
                                        n = CssFontWeight.fw_800;
                                    else
                                        n = CssFontWeight.fw_900;
                                }
                            }
                        }

                        //n = parseEnumItem!Css(src, -1); 
                        break;
                    case text_indent: 
                        {
                            // read length
                            CssValue len;
                            bool negative = false;
                            if (src[0] == '-') {
                                src = src[1 .. $];
                                negative = true;
                            }
                            if (parseLength(src, len)) {
                                // read optional "hanging" flag
                                skipSpaces(src);
                                string attr = parseIdent(src);
                                if (attr == "hanging")
                                    len.value = -len.value;
                                addLengthDecl(propId, len);
                            }
                        }
                        break;
                    case line_height:
                    case letter_spacing:
                    case font_size:
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
                        // parse length
                        CssValue value;
                        if (parseLength(src, value))
                            addLengthDecl(propId, value);
                        break;
                    case margin: 
                    case padding: 
                        //n = parseEnumItem!Css(src, -1); 
                        CssValue[4] len;
                        int i;
                        for (i = 0; i < 4; ++i)
                            if (!parseLength(src, len[i]))
                                break;
                        if (i) {
                            switch (i) {
                                case 1: 
                                    len[1] = len[0];
                                    goto case; /* fall through */
                                case 2: 
                                    len[2] = len[0];
                                    goto case; /* fall through */
                                case 3: 
                                    len[3] = len[1];
                                    break;
                                default:
                                    break;
                            }
                            if (propId == margin) {
                                addLengthDecl(margin_left, len[0]);
                                addLengthDecl(margin_top, len[1]);
                                addLengthDecl(margin_right, len[2]);
                                addLengthDecl(margin_bottom, len[3]);
                            } else {
                                addLengthDecl(padding_left, len[0]);
                                addLengthDecl(padding_top, len[1]);
                                addLengthDecl(padding_right, len[2]);
                                addLengthDecl(padding_bottom, len[3]);
                            }
                        }
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
                if (n >= 0 || !s.empty)
                    addDecl(propId, n, s);
            }
            if (!nextProperty(src))
                break;
        }
        if (mustBeInBrackets && !skipChar(src, '}'))
            return false;
        return _list.length > 0;
    }
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

private bool parseColor(ref string src, ref CssValue value)
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

private bool parseLength(ref string src, ref CssValue value)
{
    value.type = CssValueType.unspecified;
    value.value = 0;
    skipSpaces(src);
    string ident = parseIdent(src);
    if (!ident.empty) {
        switch(ident) {
            case "inherited":
                value.type = CssValueType.inherited;
                return true;
            default:
                return false;
        }
    }
    if (src.empty)
        return false;
    int n = 0;
    char ch = src[0];
    if (ch != '.') {
        if (ch < '0' || ch > '9') {
            return false; // not a number
        }
        while (ch >= '0' && ch <= '9') {
            n = n*10 + (ch - '0');
            src = src[1 .. $];
            if (src.empty)
                break;
            ch = src[0];
        }
    }
    int frac = 0;
    int frac_div = 1;
    if (ch == '.') {
        src = src[1 .. $];
        if (!src.empty) {
            ch = src[0];
            while (ch >= '0' && ch <= '9') {
                frac = frac*10 + (ch - '0');
                frac_div *= 10;
                src = src[1 .. $];
                if (src.empty)
                    break;
                ch = src[0];
            }
        }
    }
    if (ch == '%') {
        value.type = CssValueType.percent;
        src = src[1 .. $];
    } else {
        ident = parseIdent(src);
        if (!ident.empty) {
            switch(ident) {
                case "em": value.type = CssValueType.em; break;
                case "pt": value.type = CssValueType.pt; break;
                case "ex": value.type = CssValueType.ex; break;
                case "px": value.type = CssValueType.px; break;
                case "in": value.type = CssValueType.in_; break;
                case "cm": value.type = CssValueType.cm; break;
                case "mm": value.type = CssValueType.mm; break;
                case "pc": value.type = CssValueType.pc; break;
                default:
                    return false;
            }
        } else {
            value.type = CssValueType.px;
        }
    }
    if ( value.type == CssValueType.px || value.type == CssValueType.percent )
        value.value = n;                               // normal
    else
        value.value = n * 256 + 256 * frac / frac_div; // *256
    return true;
}

private void appendItem(ref string[] list, ref char[] item) {
    if (!item.empty) {
        list ~= item.dup;
        item.length = 0;
    }
}

/// splits string like "Arial", Times New Roman, Courier;  into list, stops on ; and }
/// returns true if at least one item added to list; moves str to new position
bool splitPropertyValueList(ref string str, ref string[] list)
{
    int i=0;
    char quote_char = 0;
    char[] name;
    bool last_space = false;
    for (i=0; i < str.length; i++) {
        char ch = str[i];
        switch(ch) {
            case '\'':
            case '\"':
                if (quote_char == 0) {
                    if (!name.empty)
                        appendItem(list, name);
                    quote_char = ch;
                } else if (quote_char == ch) {
                    if (!name.empty)
                        appendItem(list, name);
                    quote_char = 0;
                } else {
                    // append char
                    name ~= ch;
                }
                last_space = false;
                break;
            case ',':
                {
                    if (quote_char==0) {
                        if (!name.empty)
                            appendItem(list, name);
                    } else {
                        // inside quotation: append char
                        name ~= ch;
                    }
                    last_space = false;
                }
                break;
            case '\t':
            case ' ':
                {
                    if (quote_char != 0)
                        name ~= ch;
                    last_space = true;
                }
                break;
            case ';':
            case '}':
                if (quote_char==0) {
                    if (!name.empty)
                        appendItem(list, name);
                    str = i < str.length ? str[i .. $] : null;
                    return list.length > 0;
                } else {
                    // inside quotation: append char
                    name ~= ch;
                    last_space = false;
                }
                break;
            default:
                if (last_space && !name.empty && quote_char == 0)
                    name ~= ' ';
                name ~= ch;
                last_space = false;
                break;
        }
    }
    if (!name.empty)
        appendItem(list, name);
    str = i < str.length ? str[i .. $] : null;
    return list.length > 0;
}

unittest {
    string src = "Arial, 'Times New Roman', \"Arial Black\", sans-serif; next-property: }";
    string[] list;
    assert(splitPropertyValueList(src, list));
    assert(list.length == 4);
    assert(list[0] == "Arial");
    assert(list[1] == "Times New Roman");
    assert(list[2] == "Arial Black");
    assert(list[3] == "sans-serif");
}

/// joins list of items into comma separated string, each item in quotation marks
string joinPropertyValueList(string[] list) {
    if (list.empty)
        return null;
    char[] res;

    for (int i = 0; i < list.length; i++) {
        if (i > 0)
            res ~= ", ";
        res ~= "\"";
        res ~= list[i];
        res ~= "\"";
    }

    return res.dup;
}

unittest {
    assert(joinPropertyValueList(["item1", "item 2"]) == "\"item1\", \"item 2\"");
}

unittest {
    CssStyle style = new CssStyle();
    CssDeclaration decl = new CssDeclaration();
    CssWhiteSpace whiteSpace = CssWhiteSpace.inherit;
    CssTextAlign textAlign = CssTextAlign.inherit;
    CssTextAlign textAlignLast = CssTextAlign.inherit;
    CssTextDecoration textDecoration = CssTextDecoration.inherit;
    CssHyphenate hyphenate = CssHyphenate.inherit;
    string src = "{ display: inline; text-decoration: underline; white-space: pre; text-align: right; text-align-last: left; "
        "hyphenate: auto; width: 70%; height: 1.5pt; margin-left: 2.0em; "
        "font-family: Arial, 'Times New Roman', sans-serif; font-size: 18pt; line-height: 120%; letter-spacing: 2px; font-weight: 300; "
        " }t";
    assert(decl.parse(src, true));
    assert(!src.empty && src[0] == 't');
    assert(style.display == CssDisplay.block);
    assert(style.textDecoration == CssTextDecoration.inherit);
    assert(style.whiteSpace == CssWhiteSpace.inherit);
    assert(style.textAlign == CssTextAlign.inherit);
    assert(style.textAlignLast == CssTextAlign.inherit);
    assert(style.hyphenate == CssHyphenate.inherit);
    assert(style.width == CssValue.inherited);
    decl.apply(style);
    assert(style.display == CssDisplay.inline);
    assert(style.textDecoration == CssTextDecoration.underline);
    assert(style.whiteSpace == CssWhiteSpace.pre);
    assert(style.textAlign == CssTextAlign.right);
    assert(style.textAlignLast == CssTextAlign.left);
    assert(style.hyphenate == CssHyphenate.auto_);
    assert(style.width == CssValue(CssValueType.percent, 70));
    assert(style.height == CssValue(CssValueType.pt, 1*256 + 5*256/10)); // 1.5
    assert(style.marginLeft == CssValue(CssValueType.em, 2*256 + 0*256/10)); // 2.0
    assert(style.lineHeight == CssValue(CssValueType.percent, 120)); // 120%
    assert(style.letterSpacing == CssValue(CssValueType.px, 2)); // 2px
    assert(style.fontFamily == CssFontFamily.sans_serif);
    assert(style.fontFaces == "\"Arial\", \"Times New Roman\"");
    assert(style.fontWeight == CssFontWeight.fw_300);
}
