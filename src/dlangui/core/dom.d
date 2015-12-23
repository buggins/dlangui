module dlangui.core.dom;

import dlangui.core.collections;

import std.traits;
import std.conv : to;
import std.string;

/// Base class for DOM nodes
class Node {
private:
    Node _parent;
    Document _document;
public:
    /// returns parent node
    @property Node parent() { return _parent; }
    /// returns document node
    @property Document document() { return _document; }

    // node properties

    /// returns true if node is text
    @property bool isText() { return false; }
    /// returns true if node is element
    @property bool isElement() { return false; }
    /// returns true if node has child nodes
    @property bool hasChildren() { return false; }

    // attributes

    /// returns attribute count
    @property int attrCount() { return 0; }

    // child nodes

    /// returns child node count
    @property int childCount() { return 0; }
    /// returns child node by index
    @property Node child(int index) { return null; }
    /// returns first child node
    @property Node firstChild() { return null; }
    /// returns last child node
    @property Node lastChild() { return null; }

    /// node text
    @property dstring text() { return null; }
    /// ditto
    @property void text(dstring s) { }


}

/// Text node
class Text : Node {
private:
    dstring _text;

public:
    /// node text
    override @property dstring text() { return _text; }
    /// ditto
    override @property void text(dstring s) { _text = s; }
}

/// Element node
class Element : Node {
private:
    Collection!Node _children;
public:
    // child nodes

    /// returns child node count
    override @property int childCount() { return cast(int)_children.length; }
    /// returns child node by index
    override @property Node child(int index) { return index >= 0 && index < _children.length ? _children[index] : null; }
    /// returns first child node
    override @property Node firstChild() { return _children.length > 0 ? _children[0] : null; }
    /// returns last child node
    override @property Node lastChild() { return _children.length > 0 ? _children[_children.length - 1] : null; }
}

/// Document node
class Document : Element {
public:
    this() {
        _elemIds.init!Tag();
        _attrIds.init!Attr();
        _nsIds.init!Ns();
    }
private:
    IdentMap!(elem_id) _elemIds;
    IdentMap!(attr_id) _attrIds;
    IdentMap!(ns_id) _nsIds;
}

/// id type for interning namespaces
alias ns_id = ushort;
/// id type for interning element names
alias elem_id = uint;
/// id type for interning attribute names
alias attr_id = ushort;

/// remove trailing _ from string, e.g. "body_" -> "body"
private string removeTrailingUnderscore(string s) {
    if (s.endsWith("_"))
        return s[0..$-1];
    return s;
}

/// String identifier to Id map - for interning strings
struct IdentMap(ident_t) {
    /// initialize with elements of enum
    void init(E)() if (is(E == enum)) {
        foreach(member; EnumMembers!E) {
            internString(removeTrailingUnderscore(member.to!string), member);
        }
    }
    /// intern string - return ID assigned for it
    ident_t internString(string s, ident_t id = 0) {
        if (auto p = s in _stringToId)
            return *p;
        ident_t res;
        if (id > 0) {
            if (_nextId <= id)
                _nextId = cast(ident_t)(id + 1);
            res = id;
        } else {
           res = _nextId++;
        }
        _idToString[res] = s;
        _stringToId[s] = res;
        return res;
    }
    /// lookup id for string, return 0 if string is not found
    ident_t opIndex(string s) {
        if (auto p = s in _stringToId)
            return *p;
        return 0;
    }
    /// lookup name for id, return null if not found
    string opIndex(ident_t id) {
        if (auto p = id in _idToString)
            return *p;
        return null;
    }
private:
    string[ident_t] _idToString;
    ident_t[string] _stringToId;
    ident_t _nextId = 1;
}

/// standard tags
enum Tag {
    NONE,
    body_,
    pre,
    div,
    span
}

/// standard attributes
enum Attr {
    NONE,
    id,
    class_,
    style
}

/// standard namespaces
enum Ns {
    NONE,
    xmlns,
    xs,
    xlink,
    l,
    xsi
}

unittest {
    import std.algorithm : equal;
    //import std.stdio;
    IdentMap!(elem_id) map;
    map.init!Tag();
    //writeln("running DOM unit test");
    assert(map["pre"] == Tag.pre);
    assert(map["body"] == Tag.body_);
    assert(map[Tag.div].equal("div"));

    Document doc = new Document();
    destroy(doc);
}
