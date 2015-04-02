module dlangui.widgets.metadata;

import dlangui.widgets.widget;

interface WidgetMetadataDef {
    Widget create();
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

string generateMetadataClass(alias t)() {
    import std.traits;
    immutable string metadataClassName = t.stringof ~ "Metadata";
    return "class " ~ metadataClassName ~ " : WidgetMetadataDef { \n" ~
        "    override Widget create() {\n" ~
        "        return new " ~ moduleName!t ~ "." ~ t.stringof ~ "();\n" ~
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
