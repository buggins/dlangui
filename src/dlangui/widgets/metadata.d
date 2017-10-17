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

private bool hasPropertyAnnotation(alias ti)() {
    bool res = false;
    foreach ( attr; __traits(getFunctionAttributes, ti)) {
        static if (attr == "@property") {
            res = true;
        }
    }
    return res;
}
/*
string markupPropertyGetterType(alias overload)() {
    static if (__traits(getProtection, overload) == "public") {
        import std.traits;
        static if (is(typeof(overload) == function) && hasPropertyAnnotation!overload) {
            alias ret = ReturnType!overload;
            //alias params = Parameters!overload;
            alias params = ParameterTypeTuple!overload;
            static if (params.length == 0 && isMarkupType!ret && !isTemplate!ret) {
                return ret.stringof;
            } else {
                return null;
            }
        } else {
            return null;
        }
    }
}

string markupPropertySetterType(alias overload)() {
    static if (__traits(getProtection, overload) == "public") {
        import std.traits;
        static if (is(typeof(overload) == function) && hasPropertyAnnotation!overload) {
            //alias params = Parameters!overload;
            alias params = ParameterTypeTuple!overload;
            static if (params.length == 1 && isMarkupType!(params[0]) && !isTemplate!(params[0])) {
                return params[0].stringof;
            } else {
                return null;
            }
        } else {
            return null;
        }
    }
}
*/

private template isPublicPropertyFunction(alias overload) {
    static if (__traits(getProtection, overload) == "public") {
        static if (hasPropertyAnnotation!overload) {
            enum isPublicPropertyFunction = true;
        } else {
            enum isPublicPropertyFunction = false;
        }
    } else {
        enum isPublicPropertyFunction = false;
    }
    //pragma(msg, is(typeof(overload) == function).stringof);
    //enum isPublicPropertyFunction = (__traits(getProtection, overload) == "public") && is(typeof(overload) == function);// && hasPropertyAnnotation!overload;
}

private template markupPropertyType(alias overload) {
    import std.traits : ReturnType, ParameterTypeTuple;
    alias ret = ReturnType!overload;
    alias params = ParameterTypeTuple!overload;
    static if (params.length == 0 && isMarkupType!ret /* && !isTemplate!ret*/) {
        enum string markupPropertyType = ret.stringof;
    } else static if (params.length == 1 && isMarkupType!(params[0]) /* && !isTemplate!(params[0])*/) {
        enum string markupPropertyType = params[0].stringof;
    } else {
        enum string markupPropertyType = null;
    }
}

private string[] generatePropertyTypeList(alias T)() {
    import std.meta;
    string[] properties;
    properties ~= "[";
    foreach(m; __traits(allMembers, T)) {
        static if (__traits(compiles, (typeof(__traits(getMember, T, m))))){
            //static if (is (typeof(__traits(getMember, T, m)) == function)) {
            static if (__traits(isVirtualFunction, __traits(getMember, T, m))) {//
                import std.traits : MemberFunctionsTuple;
                alias overloads = typeof(__traits(getVirtualFunctions, T, m));
                static if (overloads.length == 2) {
                    static if (isPublicPropertyFunction!(__traits(getVirtualFunctions, T, m)[0]) && isPublicPropertyFunction!(__traits(getVirtualFunctions, T, m)[1])) {
                        //pragma(msg, m ~ " isPublicPropertyFunction0=" ~ isPublicPropertyFunction!(__traits(getVirtualFunctions, T, m)[0]).stringof);
                        //pragma(msg, m ~ " isPublicPropertyFunction1=" ~ isPublicPropertyFunction!(__traits(getVirtualFunctions, T, m)[1]).stringof);
                        immutable getterType = markupPropertyType!(__traits(getVirtualFunctions, T, m)[0]);
                        immutable setterType = markupPropertyType!(__traits(getVirtualFunctions, T, m)[1]);
                        static if (getterType && setterType && getterType == setterType) {
                            //pragma(msg, "markup property found: " ~ getterType ~ " " ~ m.stringof);
                            properties ~= "WidgetPropertyMetadata( typeid(" ~ getterType ~ "), " ~ m.stringof ~ " ), ";
                        }
                    }
                }
            }
        }
    }
    properties ~= "]";
    return properties;
}

string joinStrings(string[] lines) {
    if (lines.length == 0)
        return "";
    if (lines.length == 1)
        return lines[0];
    else
        return joinStrings(lines[0 .. $/2]) ~ joinStrings(lines[$/2 .. $]);
}

private string generatePropertiesMetadata(alias T)() if (is(T : Widget)) {
    version (GENERATE_PROPERTY_METADATA) {
        //import std.algorithm.searching;
        //import std.traits : MemberFunctionsTuple;
        //import std.meta;
        auto properties = generatePropertyTypeList!T;
        return joinStrings(properties);
    } else {
        return "[]";
    }
}

string generateMetadataClass(alias t)() if (is(t : Widget)) {
    //pragma(msg, moduleName!t);
    import std.traits;
    //pragma(msg, getSignalList!t);
    //pragma(msg, generatePropertiesMetadata!t);
    immutable string metadataClassName = t.stringof ~ "Metadata";
    return "static class " ~ metadataClassName ~ " : WidgetMetadataDef { \n" ~
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
        "    override WidgetPropertyMetadata[] properties() {\n" ~
        "        return " ~ generatePropertiesMetadata!t ~ ";\n" ~
        "    }\n" ~
        "}\n";
}

string generateRegisterMetadataClass(alias t)() if (is(t : Widget)) {
    immutable string metadataClassName = t.stringof ~ "Metadata";
    //pragma(msg, metadataClassName);
    return "registerWidgetMetadata(\"" ~ t.stringof ~ "\", new " ~ t.stringof ~ "Metadata" ~ "());\n";
}

template registerWidgetMetadataClass(alias t) if (is(t : Widget)) {
    //pragma(msg, t.stringof);
    //pragma(msg, generateMetadataClass!t);
    immutable string classDef = generateMetadataClass!t;
    immutable string registerDef = "registerWidgetMetadata(\"" ~ t.stringof ~ "\", new " ~ t.stringof ~ "Metadata" ~ "());\n";
    enum registerWidgetMetadataClass = classDef ~ registerDef;
    //mixin(classDef);

    //pragma(msg, "registerWidgetMetadata(\"" ~ t.stringof ~ "\", new " ~ t.stringof ~ "Metadata" ~ "());\n");
    //mixin("registerWidgetMetadata(\"" ~ t.stringof ~ "\", new " ~ t.stringof ~ "Metadata" ~ "());\n");
}

string registerWidgetsFunction(string registerFunctionName = "__gshared static this", T...)() {
    pragma(msg, registerFunctionName);
    pragma(msg, T);
    string[] registerDefs;
    foreach(t; T) {
        pragma(msg, t.stringof);
        //pragma(msg, moduleName!t);
        //
        static if (is(t : Widget)) {
            //pragma(msg, classdef);
            immutable string registerdef = generateRegisterMetadataClass!t;
            pragma(msg, registerdef);
            registerDefs ~= registerdef;
        } else {
            pragma(msg, "Skipping non-widget class: " ~ t.stringof);
        }
        //registerWidgetMetadata(T.stringof, new Metadata());
    }
    return registerFunctionName ~ "() {\n" ~ joinStrings(registerDefs) ~ "}\n";
}

string registerWidgets(string registerFunctionName = "__gshared static this", T...)() {
    pragma(msg, registerFunctionName);
    pragma(msg, T);
    string[] classDefs;
    string[] registerDefs;
    foreach(t; T) {
        pragma(msg, t.stringof);
        //pragma(msg, moduleName!t);
        //
        static if (is(t : Widget)) {
            immutable string classdef = generateMetadataClass!t;
            //pragma(msg, classdef);
            immutable string registerdef = generateRegisterMetadataClass!t;
            pragma(msg, registerdef);
            classDefs ~= classdef;
            registerDefs ~= registerdef;
        } else {
            pragma(msg, "Skipping non-widget class: " ~ t.stringof);
        }
        //registerWidgetMetadata(T.stringof, new Metadata());
    }
    return joinStrings(classDefs) ~ "\n" ~ registerFunctionName ~ "() {\n" ~ joinStrings(registerDefs) ~ "}\n";
}

/// returns true if passed name is identifier of registered widget class
bool isWidgetClassName(string name) {
    return (name in _registeredWidgets) !is null;
}

