module dlangui.widgets.metadata;

import dlangui.widgets.widget;

interface WidgetMetadataDef {
    Widget create();
    /// short class name, e.g. "EditLine"
    string className();
    /// module name, e.g. "dlangui.widgets.editors"
    string moduleName();
    /// full class name, e.g. "dlangui.widgets.editors.EditLine"
    string fullName();
}

struct WidgetSignalMetadata {
    string name;
    string typeString;
    //TypeTuple
    TypeInfo returnType;
    TypeInfo paramsType;
}

private __gshared WidgetMetadataDef[string] _registeredWidgets;

WidgetMetadataDef findWidgetMetadata(string name) {
    if (auto p = name in _registeredWidgets) 
        return *p;
    return null;
}

void registerWidgetMetadata(string name, WidgetMetadataDef metadata) {
    _registeredWidgets[name] = metadata;
}

WidgetSignalMetadata[] getSignalList(alias T)() {
    WidgetSignalMetadata[] res;
    foreach(m; __traits(allMembers, T)) {
        static if (__traits(compiles, (typeof(__traits(getMember, T, m))))){
            // skip non-public members
            static if (__traits(getProtection, __traits(getMember, T, m)) == "public") {
                static if (__traits(compiles, __traits(getMember, T, m).params_t ) && __traits(compiles, __traits(getMember, T, m).return_t)) {
                    alias ti = typeof(__traits(getMember, T, m));
                    res ~= WidgetSignalMetadata(m, 
                                                __traits(getMember, T, m).return_t.stringof ~ __traits(getMember, T, m).params_t.stringof,
                                                typeid(__traits(getMember, T, m).return_t),
                                                typeid(__traits(getMember, T, m).params_t));
                }
            }
        }
    }
    return res;
}

string generateMetadataClass(alias t)() {
    //pragma(msg, moduleName!t);
    import std.traits;
    //pragma(msg, getSignalList!t);
    immutable string metadataClassName = t.stringof ~ "Metadata";
    return "class " ~ metadataClassName ~ " : WidgetMetadataDef { \n" ~
        "    override Widget create() {\n" ~
        "        return new " ~ moduleName!t ~ "." ~ t.stringof ~ "();\n" ~
        "    }\n" ~
        "    override string className() {\n" ~
        "        return \"" ~ t.stringof ~ "\";\n" ~
        "    }\n" ~
        "    override string moduleName() {\n" ~
        "        return \"" ~ moduleName!t ~ "\";\n" ~
        "    }\n" ~
        "    override string fullName() {\n" ~
        "        return \"" ~ moduleName!t ~ "." ~ t.stringof ~ "\";\n" ~
        "    }\n" ~
        "}\n";
}

string generateRegisterMetadataClass(alias t)() {
    immutable string metadataClassName = t.stringof ~ "Metadata";
    return "registerWidgetMetadata(\"" ~ t.stringof ~ "\", new " ~ metadataClassName ~ "());\n";
}

string registerWidgets(T...)() {
    string classDefs;
    string registerDefs;
    foreach(t; T) {
        //pragma(msg, t.stringof);
        //pragma(msg, moduleName!t);
        //
        immutable string classdef = generateMetadataClass!t;
        //pragma(msg, classdef);
        immutable string registerdef = generateRegisterMetadataClass!t;
        //pragma(msg, registerdef);
        classDefs ~= classdef;
        registerDefs ~= registerdef;
        //registerWidgetMetadata(T.stringof, new Metadata());
    }
    return classDefs ~ "\n__gshared static this() {\n" ~ registerDefs ~ "}";
}

/// returns true if passed name is identifier of registered widget class
bool isWidgetClassName(string name) {
    return (name in _registeredWidgets) !is null;
}

