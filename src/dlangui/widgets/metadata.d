module dlangui.widgets.metadata;

import dlangui.widgets.widget;

version = GENERATE_PROPERTY_METADATA;

interface WidgetMetadataDef {
    Widget create();
    /// short class name, e.g. "EditLine"
    string className();
    /// module name, e.g. "dlangui.widgets.editors"
    string moduleName();
    /// full class name, e.g. "dlangui.widgets.editors.EditLine"
    string fullName();
    /// property list, e.g. "backgroundColor"
    WidgetPropertyMetadata[] properties();
}

struct WidgetSignalMetadata {
    string name;
    string typeString;
    //TypeTuple
    TypeInfo returnType;
    TypeInfo paramsType;
}

/**
* Stores information about property
*
*/
struct WidgetPropertyMetadata {
    TypeInfo type;
    string name;
}

private __gshared WidgetMetadataDef[string] _registeredWidgets;

string[] getRegisteredWidgetsList()
{
    return _registeredWidgets.keys;
}

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

template isMarkupType(T)
{
    enum isMarkupType = is(T==int) ||
                    is(T==float) ||
                    is(T==double) ||
                    is(T==bool) ||
                    is(T==Rect) ||
                    is(T==string) ||
                    is(T==dstring) ||
                    is(T==UIString) ||
                    is(T==UIString[]) ||
                    is(T==StringListValue[]);
}

string generatePropertiesMetadata(alias T)() {
    version (GENERATE_PROPERTY_METADATA) {
        import std.algorithm.searching;
        import std.traits;
        import std.meta;
        char[] str;
        str ~= "[";
        WidgetPropertyMetadata[] res;
        foreach(m; __traits(allMembers, T)) {
            static if (__traits(compiles, (typeof(__traits(getMember, T, m))))){
                // skip non-public members, only functions that takes 0 or 1 arguments, add only types that parseable in markup
                static if (__traits(getProtection, __traits(getMember, T, m)) == "public") {
                    static if (isFunction!(__traits(getMember, T, m))) {
                        immutable int fnArity = arity!(__traits(getMember, T, m));
                        static if (fnArity == 0 || fnArity == 1) {
                            // TODO: filter out templates, signals and such
                            static if ([__traits(getFunctionAttributes, __traits(getMember, T, m))[]].canFind("@property")) {
                                alias ret = ReturnType!(__traits(getMember, T, m));
                                alias params = Parameters!(__traits(getMember, T, m));
                                string typestring;
                                static if (fnArity == 0 && !__traits(isTemplate,ret) && isMarkupType!ret)
                                    typestring = ret.stringof;
                                else static if (fnArity == 1 && !__traits(isTemplate,params[0]) && isMarkupType!(params[0]))
                                    typestring = params[0].stringof;
                                if (typestring is null)
                                    continue;
                                str ~= "WidgetPropertyMetadata( typeid(" ~ typestring ~ "), " ~ m.stringof ~ " ), ";
                            }
                        }
                    }
                }
            }
        }
        str ~= "]";
        return cast(string)str;
    } else {
        return "[]";
    }
}

string generateMetadataClass(alias t)() {
    //pragma(msg, moduleName!t);
    import std.traits;
    //pragma(msg, getSignalList!t);
    //pragma(msg, generatePropertiesMetadata!t);
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
        "    override WidgetPropertyMetadata[] properties() {" ~
        "        return " ~ generatePropertiesMetadata!t ~ ";\n" ~
        "    }\n" ~
        "}\n";
}

string generateRegisterMetadataClass(alias t)() {
    immutable string metadataClassName = t.stringof ~ "Metadata";
    return "registerWidgetMetadata(\"" ~ t.stringof ~ "\", new " ~ metadataClassName ~ "());\n";
}

string registerWidgets(T...)(string registerFunctionName = "__gshared static this") {
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
    return classDefs ~ "\n" ~ registerFunctionName ~ "() {\n" ~ registerDefs ~ "}";
}

/// returns true if passed name is identifier of registered widget class
bool isWidgetClassName(string name) {
    return (name in _registeredWidgets) !is null;
}

