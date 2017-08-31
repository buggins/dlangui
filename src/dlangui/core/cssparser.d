module dlangui.core.cssparser;

import std.traits;
import std.conv : to;
import std.string;
import std.array : empty;
import std.algorithm : equal;
import std.ascii : isAlpha, isWhite;

import dlangui.core.dom;
import dlangui.core.css;
import dlangui.core.types : parseHexDigit;

/// skip specified count of chars of string, returns next available character, or 0 if end of string reached
private char skip(ref string src, int count = 1) {
    if (count >= src.length) {
        src = null;
        return 0;
    }
    src = src[count .. $];
    return src[0];
}

/// returns char of string at specified position (first by default) or 0 if end of string reached
private char peek(string str, int offset = 0) {
    return offset >= str.length ? 0 : str[offset];
}

/// skip spaces, move to new location, return first character in string, 0 if end of string reached
private char skipSpaces(ref string str)
{
    string oldpos = str;
    for (;;) {
        char ch = str.peek;
        if (!ch)
            return 0;
        while (isWhite(ch))
            ch = str.skip;
        if (str.peek == '/' && str.peek(1) == '*') {
            // comment found
            str.skip(2);
            while (str.peek && (str.peek(0) != '*' || str.peek(1) != '/'))
                str.skip;
            if (str.peek == '*' && str.peek(1) == '/' )
                str.skip(2);
        }
        ch = str.peek;
        while (isWhite(ch))
            ch = str.skip;
        if (oldpos.ptr is str.ptr)
            break;
        if (str.empty)
            return 0;
        oldpos = str;
    }
    return str.peek;
}


private bool isIdentChar(char ch) {
    return isAlpha(ch) || (ch == '-') || (ch == '_');
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
    src.skip(pos);
    src.skipSpaces;
    return res;
}

private bool skipChar(ref string src, char ch) {
    src.skipSpaces;
    if (src.peek == ch) {
        src.skip;
        src.skipSpaces;
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
    str.skip(pos);
    str.skipSpaces;
    return !str.empty && str[0] != '}';
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
    if (!src.skipSpaces)
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
        ch = src.skip;
        int nDigits = 0;
        for ( ; nDigits < src.length && parseHexDigit(src[nDigits]) != uint.max; nDigits++ ) {
        }
        if ( nDigits==3 ) {
            int r = parseHexDigit( src[0] );
            int g = parseHexDigit( src[1] );
            int b = parseHexDigit( src[2] );
            value.type = CssValueType.color;
            value.value = (((r + r*16) * 256) | (g + g*16)) * 256 | (b + b*16);
            src.skip(3);
            return true;
        } else if ( nDigits==6 ) {
            int r = parseHexDigit( src[0] ) * 16;
            r += parseHexDigit( src[1] );
            int g = parseHexDigit( src[2] ) * 16;
            g += parseHexDigit( src[3] );
            int b = parseHexDigit( src[4] ) * 16;
            b += parseHexDigit( src[5] );
            value.type = CssValueType.color;
            value.value = ((r * 256) | g) * 256 | b;
            src.skip(6);
            return true;
        }
    }
    return false;
}

private bool parseLength(ref string src, ref CssValue value)
{
    value.type = CssValueType.unspecified;
    value.value = 0;
    src.skipSpaces;
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
            ch = src.skip;
            if (!ch)
                break;
        }
    }
    int frac = 0;
    int frac_div = 1;
    if (ch == '.') {
        src.skip;
        if (!src.empty) {
            ch = src[0];
            while (ch >= '0' && ch <= '9') {
                frac = frac*10 + (ch - '0');
                frac_div *= 10;
                ch = src.skip;
                if (!ch)
                    break;
            }
        }
    }
    if (ch == '%') {
        value.type = CssValueType.percent;
        src.skip;
    } else {
        ident = parseIdent(src);
        if (!ident.empty) {
            switch(ident) {
                case "em":
                case "m": // for DML - cannot add suffix which starts from 'e'
                    value.type = CssValueType.em; break;
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


private bool parseAttrValue(ref string str, ref string attrvalue)
{
    char[] buf;
    int pos = 0;
    if (!str.skipSpaces)
        return false;
    char ch = str[0];
    if (ch == '\"') {
        str.skip;
        for ( ; pos < str.length && str[pos] != '\"'; pos++) {
            if (pos >= 1000)
                return false;
        }
        if (pos >= str.length || str[pos] != '\"')
            return false;
        buf ~= str[0 .. pos];
        str.skip(pos + 1);
        if (!str.skipSpaces)
            return false;
        if (str[0] != ']')
            return false;
        str.skip;
        attrvalue = buf.dup;
        return true;
    } else {
        for ( ; pos < str.length && str[pos] != ' ' && str[pos] != '\t' && str[pos] != ']'; pos++) {
            if (pos >= 1000)
                return false;
        }
        if (pos >= str.length || str[pos] != ']')
            return false;
        buf ~= str[0 .. pos];
        str.skip(pos + 1);
        attrvalue = buf.dup;
        return true;
    }
}

private CssSelectorRule parseAttr(ref string str, Document doc)
{
    CssSelectorRuleType st = CssSelectorRuleType.universal;
    char ch = str[0];
    if (ch == '.') {
        // E.class
        str.skip;
        str.skipSpaces;
        string attrvalue = parseIdent(str);
        if (attrvalue.empty)
            return null;
        CssSelectorRule rule = new CssSelectorRule(CssSelectorRuleType.class_);
        rule.setAttr(Attr.class_, attrvalue.toLower);
        return rule;
    } else if (ch == '#') {
        // E#id
        str.skip;
        str.skipSpaces;
        string attrvalue = parseIdent(str);
        if (attrvalue.empty)
            return null;
        CssSelectorRule rule = new CssSelectorRule(CssSelectorRuleType.id);
        rule.setAttr(Attr.id, attrvalue.toLower);
        return rule;
    } else if (ch != '[')
        return null;
    // [.....] rule
    str.skip; // skip [
    str.skipSpaces;
    string attrname = parseIdent(str);
    if (attrname.empty)
        return null;
    if (!str.skipSpaces)
        return null;
    string attrvalue = null;
    ch = str[0];
    if (ch == ']') {
        // empty []
        st = CssSelectorRuleType.attrset;
        str.skip; // skip ]
    } else if (ch == '=') {
        str.skip; // skip =
        if (!parseAttrValue(str, attrvalue))
            return null;
        st = CssSelectorRuleType.attreq;
    } else if (ch == '~' && str.length > 1 && str[1] == '=') {
        str.skip(2); // skip ~=
        if (!parseAttrValue(str, attrvalue))
            return null;
        st = CssSelectorRuleType.attrhas;
    } else if (ch == '|' && str.length > 1 && str[1] == '=') {
        str.skip(2); // skip |=
        if (!parseAttrValue(str, attrvalue))
            return null;
        st = CssSelectorRuleType.attrstarts;
    } else {
        return null;
    }
    CssSelectorRule rule = new CssSelectorRule(st);
    attr_id id = doc.attrId(attrname);
    rule.setAttr(id, attrvalue);
    return rule;
}

/// Parse css properties declaration either in {} or w/o {} - e.g.  { width: 40%; margin-top: 3px } -- returns null if parse error occured or property list is empty
CssDeclaration parseCssDeclaration(ref string src, bool mustBeInBrackets = true) {
    if (!src.skipSpaces)
        return null;
    if (mustBeInBrackets && !skipChar(src, '{'))
        return null; // decl must start with {
    CssDeclaration res = new CssDeclaration();
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
                        res.addLengthDecl(propId, v);
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
                            src.skip;
                            negative = true;
                        }
                        if (parseLength(src, len)) {
                            // read optional "hanging" flag
                            src.skipSpaces;
                            string attr = parseIdent(src);
                            if (attr == "hanging")
                                len.value = -len.value;
                            res.addLengthDecl(propId, len);
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
                        res.addLengthDecl(propId, value);
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
                            res.addLengthDecl(margin_left, len[0]);
                            res.addLengthDecl(margin_top, len[1]);
                            res.addLengthDecl(margin_right, len[2]);
                            res.addLengthDecl(margin_bottom, len[3]);
                        } else {
                            res.addLengthDecl(padding_left, len[0]);
                            res.addLengthDecl(padding_top, len[1]);
                            res.addLengthDecl(padding_right, len[2]);
                            res.addLengthDecl(padding_bottom, len[3]);
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
                res.addDecl(propId, n, s);
        }
        if (!nextProperty(src))
            break;
    }
    if (mustBeInBrackets && !skipChar(src, '}'))
        return null;
    if (res.empty)
        return null;
    return res;
}

/// parse Css selector, return selector object if parsed ok, null if error occured
CssSelector parseCssSelector(ref string str, Document doc) {
    if (str.empty)
        return null;
    CssSelector res = new CssSelector();
    for (;;) {
        if (!str.skipSpaces)
            return null;
        char ch = str[0];
        string ident = parseIdent(str);
        if (ch == '*') { // universal selector
            str.skip;
            str.skipSpaces;
            res.id = 0;
        }  else if (ch == '.') { // classname follows
            res.id = 0;
            // will be parsed as attribute
        }  else if (!ident.empty) {
            // ident
            res.id = doc.tagId(ident);
        } else {
            return null;
        }
        if (!str.skipSpaces)
            return null;
        ch = str[0];
        if (ch == ',' || ch == '{')
            return res;
        // one or more attribute rules
        bool attr_rule = false;
        while (ch == '[' || ch == '.' || ch == '#') {
            CssSelectorRule rule = parseAttr(str, doc);
            if (!rule)
                return null;
            res.insertRuleStart(rule); //insertRuleAfterStart
            ch = str.skipSpaces;
            attr_rule = true;
            //continue;
        }
        // element relation
        if (ch == '>') {
            str.skip;
            CssSelectorRule rule = new CssSelectorRule(CssSelectorRuleType.parent);
            rule.id = res.id;
            res.insertRuleStart(rule);
            res.id = 0;
            continue;
        } else if (ch == '+') {
            str.skip;
            CssSelectorRule rule = new CssSelectorRule(CssSelectorRuleType.predecessor);
            rule.id = res.id;
            res.insertRuleStart(rule);
            res.id = 0;
            continue;
        } else if (ch.isAlpha) {
            CssSelectorRule rule = new CssSelectorRule(CssSelectorRuleType.ancessor);
            rule.id = res.id;
            res.insertRuleStart(rule);
            res.id = 0;
            continue;
        }
        if (!attr_rule)
            return null;
        else if (str.length > 0 && (str[0] == ',' || str[0] == '{'))
            return res;
    }
}

/// skips until } or end of string, returns true if some characters left in string
private bool skipUntilEndOfRule(ref string str)
{
    while (str.length && str[0] != '}')
        str.skip;
    if (str.peek == '}')
        str.skip;
    return !str.empty;
}


unittest {
    Document doc = new Document();
    string str;
    str = "body { width: 50% }";
    assert(parseCssSelector(str, doc) !is null);
    assert(parseCssDeclaration(str, true) !is null);
    str = "body > p { font-family: sans-serif }";
    assert(parseCssSelector(str, doc) !is null);
    assert(parseCssDeclaration(str, true) !is null);
    str = ".myclass + div { }";
    assert(parseCssSelector(str, doc) !is null);
    assert(parseCssDeclaration(str, true) is null); // empty property decl
    destroy(doc);
}

/// parse stylesheet text
bool parseStyleSheet(StyleSheet sheet, Document doc, string str) {
    bool res = false;
    for(;;) {
        if (!str.skipSpaces)
            break;
        CssSelector[] selectors;
        for(;;) {
            CssSelector selector = parseCssSelector(str, doc);
            if (!selector)
                break;
            selectors ~= selector;
            str.skipChar(',');
        }
        if (selectors.length) {
            if (CssDeclaration decl = parseCssDeclaration(str, true)) {
                foreach(item; selectors) {
                    item.setDeclaration(decl);
                    sheet.add(item);
                    res = true;
                }
            }
        }
        if (!skipUntilEndOfRule(str))
            break;
    }
    return res;
}

unittest {
    string src = q{
        body { width: 50%; color: blue }
        body > div, body > section {
            /* some comment
               goes here */
            font-family: serif;
            background-color: yellow;
        }
        section {
            margin-top: 5px
        }
    };
    Document doc = new Document();
    StyleSheet sheet = new StyleSheet();
    assert(parseStyleSheet(sheet, doc, src));
    assert(sheet.length == 2);
    // check appending of additional source text
    assert(parseStyleSheet(sheet, doc, "pre { white-space: pre }"));
    assert(sheet.length == 3);
    destroy(doc);
}

unittest {
    Document doc = new Document();
    StyleSheet sheet = new StyleSheet();
    assert(parseStyleSheet(sheet, doc, "* { color: #aaa }"));
    assert(sheet.length == 1);
    assert(parseStyleSheet(sheet, doc, "div, p { display: block }"));
    assert(sheet.length == 3);
    // check appending of additional source text
    assert(parseStyleSheet(sheet, doc, "pre { white-space: pre }"));
    assert(sheet.length == 4);
    assert(parseStyleSheet(sheet, doc, "pre { font-size: 120% }"));
    assert(sheet.length == 5);
    destroy(doc);
}
