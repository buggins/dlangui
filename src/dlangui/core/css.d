// Written in the D programming language.

/**
This module contains implementation of CSS support - Cascading Style Sheets.

Port of CoolReader Engine written in C++.

Supports subset of CSS standards.


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
import std.ascii : isAlpha;

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
    bool check(ref Node node) const {
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
                int p = cast(int)val.indexOf(_value);
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

import dlangui.core.cssparser;

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
public:
    /// get element tag id (0 - any tag)
    @property elem_id id() { return _id; }
    /// set element tag id (0 - any tag)
    @property void id(elem_id id) { _id = id; }

    this() { }

    ~this() {
        //if (_next)
        //    destroy(_next);
    }

    void insertRuleStart(CssSelectorRule rule) {
        rule.next = _rules;
        _rules = rule;
    }

    void insertRuleAfterStart(CssSelectorRule rule) {
        if (!_rules) {
            _rules = rule;
        } else {
            rule.next = _rules.next;
            _rules.next = rule;
        }
    }

    /// check if selector rules match this node
    bool check(Node node) const {
        CssSelectorRule rule = cast(CssSelectorRule)_rules;
        while (rule && node) {
            if (!rule.check(node))
                return false;
            rule = rule.next;
        }
        return true;
    }

    /// apply to style if selector matches
    void apply(Node node, CssStyle style) const {
        if (check(node))
            _decl.apply(style);
    }

    void setDeclaration(CssDeclaration decl) {
        _decl = decl;
    }
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

    @property bool empty() {
        return _list.length == 0;
    }

    void addLengthDecl(CssDeclType type, CssValue len) {
        CssDeclItem item;
        item.type = type;
        item.length = len;
        _list ~= item;
    }

    void addDecl(CssDeclType type, int value, string str) {
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
}

/// CSS Style Sheet
class StyleSheet {
private:
    CssSelector[elem_id] _selectorMap;
    int _len;
public:
    /// clears stylesheet
    void clear() {
        _selectorMap = null;
        _len = 0;
    }

    /// count of selectors in stylesheet
    @property int length() { return _len; }

    /// add selector to stylesheet
    void add(CssSelector selector) {
        elem_id id = selector.id;
        if (auto p = id in _selectorMap) {
            for (;;) {
                if (!(*p) || (*p)._specificity < selector._specificity) {
                    selector._next = (*p);
                    (*p) = selector;
                    _len++;
                    break;
                }
                p = &((*p)._next);
            }
        } else {
            // first selector for this id
            _selectorMap[id] = selector;
            _len++;
        }
    }

    /// apply stylesheet to node style
    void apply(Node node, CssStyle style) {
        elem_id id = node.id;
        CssSelector selector_0, selector_id;
        if (auto p = 0 in _selectorMap)
            selector_0 = *p;
        if (id) {
            if (auto p = id in _selectorMap)
                selector_id = *p;
        }
        for (;;) {
            if (selector_0) {
                if (!selector_id || selector_id._specificity < selector_0._specificity) {
                    selector_0.apply(node, style);
                    selector_0 = selector_0._next;
                } else {
                    selector_id.apply(node, style);
                    selector_id = selector_id._next;
                }
            } else if (selector_id) {
                selector_id.apply(node, style);
                selector_id = selector_id._next;
            } else {
                // end of lists
                break;
            }
        }
    }
}

unittest {
    CssStyle style = new CssStyle();
    CssWhiteSpace whiteSpace = CssWhiteSpace.inherit;
    CssTextAlign textAlign = CssTextAlign.inherit;
    CssTextAlign textAlignLast = CssTextAlign.inherit;
    CssTextDecoration textDecoration = CssTextDecoration.inherit;
    CssHyphenate hyphenate = CssHyphenate.inherit;
    string src = "{ display: inline; text-decoration: underline; white-space: pre; text-align: right; text-align-last: left; " ~
        "hyphenate: auto; width: 70%; height: 1.5pt; margin-left: 2.0em; " ~
        "font-family: Arial, 'Times New Roman', sans-serif; font-size: 18pt; line-height: 120%; letter-spacing: 2px; font-weight: 300; " ~
        " }tail";
    CssDeclaration decl = parseCssDeclaration(src, true);
    assert(decl !is null);
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
