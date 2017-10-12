/**
 * This module provides class for reading and accessing icon theme descriptions.
 *
 * Information about icon themes is stored in special files named index.theme and located in icon theme directory.
 *
 * Authors:
 *  $(LINK2 https://github.com/FreeSlave, Roman Chistokhodov)
 * Copyright:
 *  Roman Chistokhodov, 2015-2016
 * License:
 *  $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0).
 * See_Also:
 *  $(LINK2 http://standards.freedesktop.org/icon-theme-spec/icon-theme-spec-latest.html, Icon Theme Specification)
 */

module icontheme.file;

package
{
    import std.algorithm;
    import std.array;
    import std.conv;
    import std.exception;
    import std.path;
    import std.range;
    import std.string;
    import std.traits;
    import std.typecons;

    static if( __VERSION__ < 2066 ) enum nogc = 1;
}

import icontheme.cache;

public import inilike.file;
import inilike.common;

/**
 * Adapter of $(D inilike.file.IniLikeGroup) for easy access to icon subdirectory properties.
 */
struct IconSubDir
{
    ///The type of icon sizes for the icons in the directory.
    enum Type {
        ///Icons can be used if the size differs at some threshold from the desired size.
        Threshold,
        ///Icons can be used if the size does not differ from desired.
        Fixed,
        ///Icons are scalable without visible quality loss.
        Scalable
    }

    @safe this(const(IniLikeGroup) group) nothrow {
        collectException(group.value("Size").to!uint, _size);
        collectException(group.value("MinSize").to!uint, _minSize);
        collectException(group.value("MaxSize").to!uint, _maxSize);

        if (_minSize == 0) {
            _minSize = _size;
        }

        if (_maxSize == 0) {
            _maxSize = _size;
        }

        collectException(group.value("Threshold").to!uint, _threshold);
        if (_threshold == 0) {
            _threshold = 2;
        }

        _type = Type.Threshold;

        string t = group.value("Type");
        if (t.length) {
            if (t == "Fixed") {
                _type = Type.Fixed;
            } else if (t == "Scalable") {
                _type = Type.Scalable;
            }
        }

        _context = group.value("Context");
        _name = group.groupName();
    }

    @safe this(uint size, Type type = Type.Threshold, string context = null, uint minSize = 0, uint maxSize = 0, uint threshold = 2) nothrow pure
    {
        _size = size;
        _context = context;
        _type = type;
        _minSize = minSize ? minSize : size;
        _maxSize = maxSize ? maxSize : size;
        _threshold = threshold;
    }

    /**
     * The name of section in icon theme file and relative path to icons.
     */
    @nogc @safe string name() const nothrow pure {
        return _name;
    }

    /**
     * Nominal size of the icons in this directory.
     * Returns: The value associated with "Size" key converted to an unsigned integer, or 0 if the value is not present or not a number.
     */
    @nogc @safe uint size() const nothrow pure {
        return _size;
    }

    /**
     * The context the icon is normally used in.
     * Returns: The value associated with "Context" key.
     */
    @nogc @safe string context() const nothrow pure {
        return _context;
    }

    /**
     * The type of icon sizes for the icons in this directory.
     * Returns: The value associated with "Type" key or Type.Threshold if not specified.
     */
    @nogc @safe Type type() const nothrow pure {
        return _type;
    }

    /**
     * The maximum size that the icons in this directory can be scaled to. Defaults to the value of Size if not present.
     * Returns: The value associated with "MaxSize" key converted to an unsigned integer, or size() if the value is not present or not a number.
     * See_Also: $(D size), $(D minSize)
     */
    @nogc @safe uint maxSize() const nothrow pure {
        return _maxSize;
    }

    /**
     * The minimum size that the icons in this directory can be scaled to. Defaults to the value of Size if not present.
     * Returns: The value associated with "MinSize" key converted to an unsigned integer, or size() if the value is not present or not a number.
     * See_Also: $(D size), $(D maxSize)
     */
    @nogc @safe uint minSize() const nothrow pure {
        return _minSize;
    }

    /**
     * The icons in this directory can be used if the size differ at most this much from the desired size. Defaults to 2 if not present.
     * Returns: The value associated with "Threshold" key, or 2 if the value is not present or not a number.
     */
    @nogc @safe uint threshold() const nothrow pure {
        return _threshold;
    }
private:
    uint _size;
    uint _minSize;
    uint _maxSize;
    uint _threshold;
    Type _type;
    string _context;
    string _name;
}

final class IconThemeGroup : IniLikeGroup
{
    protected @nogc @safe this() nothrow {
        super("Icon Theme");
    }

    /**
     * Short name of the icon theme, used in e.g. lists when selecting themes.
     * Returns: The value associated with "Name" key.
     * See_Also: $(D IconThemeFile.internalName), $(D localizedDisplayName)
     */
    @safe string displayName() const nothrow pure {
        return readEntry("Name");
    }
    /**
     * Set "Name" to name escaping the value if needed.
     */
    @safe string displayName(string name) {
        return writeEntry("Name", name);
    }

    ///Returns: Localized name of icon theme.
    @safe string localizedDisplayName(string locale) const nothrow pure {
        return readEntry("Name", locale);
    }

    /**
     * Longer string describing the theme.
     * Returns: The value associated with "Comment" key.
     */
    @safe string comment() const nothrow pure {
        return readEntry("Comment");
    }
    /**
     * Set "Comment" to commentary escaping the value if needed.
     */
    @safe string comment(string commentary) {
        return writeEntry("Comment", commentary);
    }

    ///Returns: Localized comment.
    @safe string localizedComment(string locale) const nothrow pure {
        return readEntry("Comment", locale);
    }

    /**
     * Whether to hide the theme in a theme selection user interface.
     * Returns: The value associated with "Hidden" key converted to bool using isTrue.
     */
    @nogc @safe bool hidden() const nothrow pure {
        return isTrue(value("Hidden"));
    }
    ///setter
    @safe bool hidden(bool hide) {
        this["Hidden"] = boolToString(hide);
        return hide;
    }

    /**
     * The name of an icon that should be used as an example of how this theme looks.
     * Returns: The value associated with "Example" key.
     */
    @safe string example() const nothrow pure {
        return readEntry("Example");
    }
    /**
     * Set "Example" to example escaping the value if needed.
     */
    @safe string example(string example) {
        return writeEntry("Example", example);
    }

    /**
     * List of subdirectories for this theme.
     * Returns: The range of values associated with "Directories" key.
     */
    @safe auto directories() const {
        return IconThemeFile.splitValues(readEntry("Directories"));
    }
    ///setter
    string directories(Range)(Range values) if (isInputRange!Range && isSomeString!(ElementType!Range)) {
        return writeEntry("Directories", IconThemeFile.joinValues(values));
    }

    /**
     * Names of themes that this theme inherits from.
     * Returns: The range of values associated with "Inherits" key.
     * Note: It does NOT automatically adds hicolor theme if it's missing.
     */
    @safe auto inherits() const {
        return IconThemeFile.splitValues(readEntry("Inherits"));
    }
    ///setter
    string inherits(Range)(Range values) if (isInputRange!Range && isSomeString!(ElementType!Range)) {
        return writeEntry("Inherits", IconThemeFile.joinValues(values));
    }

protected:
    @trusted override void validateKey(string key, string value) const {
        if (!isValidDesktopFileKey(key)) {
            throw new IniLikeEntryException("key is invalid", groupName(), key, value);
        }
    }
}

/**
 * Class representation of index.theme file containing an icon theme description.
 */
final class IconThemeFile : IniLikeFile
{
    /**
     * Policy about reading extension groups (those start with 'X-').
     */
    enum ExtensionGroupPolicy : ubyte {
        skip, ///Don't save extension groups.
        preserve ///Save extension groups.
    }

    /**
     * Policy about reading groups with names which meaning is unknown, i.e. it's not extension nor relative directory path.
     */
    enum UnknownGroupPolicy : ubyte {
        skip, ///Don't save unknown groups.
        preserve, ///Save unknown groups.
        throwError ///Throw error when unknown group is encountered.
    }

    ///Options to manage icon theme file reading
    static struct IconThemeReadOptions
    {
        ///Base $(D inilike.file.IniLikeFile.ReadOptions).
        IniLikeFile.ReadOptions baseOptions = IniLikeFile.ReadOptions(IniLikeFile.DuplicateGroupPolicy.skip);

        alias baseOptions this;

        /**
         * Set policy about unknown groups. By default they are skipped without errors.
         * Note that all groups still need to be preserved if desktop file must be rewritten.
         */
        UnknownGroupPolicy unknownGroupPolicy = UnknownGroupPolicy.skip;

        /**
         * Set policy about extension groups. By default they are all preserved.
         * Set it to skip if you're not willing to support any extensions in your applications.
         * Note that all groups still need to be preserved if desktop file must be rewritten.
         */
        ExtensionGroupPolicy extensionGroupPolicy = ExtensionGroupPolicy.preserve;

        ///Setting parameters in any order, leaving not mentioned ones in default state.
        @nogc @safe this(Args...)(Args args) nothrow pure {
            foreach(arg; args) {
                alias Unqual!(typeof(arg)) ArgType;
                static if (is(ArgType == IniLikeFile.ReadOptions)) {
                    baseOptions = arg;
                } else static if (is(ArgType == UnknownGroupPolicy)) {
                    unknownGroupPolicy = arg;
                } else static if (is(ArgType == ExtensionGroupPolicy)) {
                    extensionGroupPolicy = arg;
                } else {
                    baseOptions.assign(arg);
                }
            }
        }

        ///
        unittest
        {
            IconThemeReadOptions options;

            options = IconThemeReadOptions(
                ExtensionGroupPolicy.skip,
                UnknownGroupPolicy.preserve,
                DuplicateKeyPolicy.skip,
                DuplicateGroupPolicy.preserve,
                No.preserveComments
            );

            assert(options.unknownGroupPolicy == UnknownGroupPolicy.preserve);
            assert(options.extensionGroupPolicy == ExtensionGroupPolicy.skip);
            assert(options.duplicateGroupPolicy == DuplicateGroupPolicy.preserve);
            assert(options.duplicateKeyPolicy == DuplicateKeyPolicy.skip);
            assert(!options.preserveComments);
        }
    }

    ///
    unittest
    {
        string contents =
`[Icon Theme]
Name=Theme
[X-SomeGroup]
Key=Value`;

        alias IconThemeFile.IconThemeReadOptions IconThemeReadOptions;

        auto iconTheme = new IconThemeFile(iniLikeStringReader(contents), IconThemeReadOptions(ExtensionGroupPolicy.skip));
        assert(iconTheme.group("X-SomeGroup") is null);

    contents =
`[Icon Theme]
Name=Theme
[/invalid group]
$=StrangeKey`;

        iconTheme = new IconThemeFile(iniLikeStringReader(contents), IconThemeReadOptions(UnknownGroupPolicy.preserve, IniLikeGroup.InvalidKeyPolicy.save));
        assert(iconTheme.group("/invalid group") !is null);
        assert(iconTheme.group("/invalid group").value("$") == "StrangeKey");

    contents =
`[X-SomeGroup]
Key=Value`;

        auto thrown = collectException!IniLikeReadException(new IconThemeFile(iniLikeStringReader(contents)));
        assert(thrown !is null);
        assert(thrown.lineNumber == 0);

        contents =
`[Icon Theme]
Valid=Key
$=Invalid`;

        assertThrown(new IconThemeFile(iniLikeStringReader(contents)));
        assertNotThrown(new IconThemeFile(iniLikeStringReader(contents), IconThemeReadOptions(IniLikeGroup.InvalidKeyPolicy.skip)));

        contents =
`[Icon Theme]
Name=Name
[/invalidpath]
Key=Value`;

        assertThrown(new IconThemeFile(iniLikeStringReader(contents), IconThemeReadOptions(UnknownGroupPolicy.throwError)));
        assertNotThrown(iconTheme = new IconThemeFile(iniLikeStringReader(contents), IconThemeReadOptions(UnknownGroupPolicy.preserve)));
        assert(iconTheme.cachePath().empty);
        assert(iconTheme.group("/invalidpath") !is null);
    }

protected:
    @trusted static bool isDirectoryName(string groupName)
    {
        return groupName.pathSplitter.all!isValidFilename;
    }

    @trusted override IniLikeGroup createGroupByName(string groupName) {
        if (groupName == "Icon Theme") {
            _iconTheme = new IconThemeGroup();
            return _iconTheme;
        } else if (groupName.startsWith("X-")) {
            if (_options.extensionGroupPolicy == ExtensionGroupPolicy.skip) {
                return null;
            } else {
                return createEmptyGroup(groupName);
            }
        } else if (isDirectoryName(groupName)) {
            return createEmptyGroup(groupName);
        } else {
            final switch(_options.unknownGroupPolicy) {
                case UnknownGroupPolicy.skip:
                    return null;
                case UnknownGroupPolicy.preserve:
                    return createEmptyGroup(groupName);
                case UnknownGroupPolicy.throwError:
                    throw new IniLikeException("Invalid group name: '" ~ groupName ~ "'. Must be valid relative path or start with 'X-'");
            }
        }
    }
public:
    /**
     * Reads icon theme from file.
     * Throws:
     *  $(B ErrnoException) if file could not be opened.
     *  $(D inilike.file.IniLikeReadException) if error occured while reading the file.
     */
    @trusted this(string fileName, IconThemeReadOptions options = IconThemeReadOptions.init) {
        this(iniLikeFileReader(fileName), options, fileName);
    }

    /**
     * Reads icon theme file from range of IniLikeReader, e.g. acquired from iniLikeFileReader or iniLikeStringReader.
     * Throws:
     *  $(D inilike.file.IniLikeReadException) if error occured while parsing.
     */
    this(IniLikeReader)(IniLikeReader reader, IconThemeReadOptions options = IconThemeReadOptions.init, string fileName = null)
    {
        _options = options;
        super(reader, fileName, options.baseOptions);
        enforce(_iconTheme !is null, new IniLikeReadException("No \"Icon Theme\" group", 0));
    }

    ///ditto
    this(IniLikeReader)(IniLikeReader reader, string fileName, IconThemeReadOptions options = IconThemeReadOptions.init)
    {
        this(reader, options, fileName);
    }

    /**
     * Constructs IconThemeFile with empty "Icon Theme" group.
     */
    @safe this() {
        super();
        _iconTheme = new IconThemeGroup();
    }

    ///
    unittest
    {
        auto itf = new IconThemeFile();
        assert(itf.iconTheme());
        assert(itf.directories().empty);
    }

    /**
     * Removes group by name. This function will not remove "Icon Theme" group.
     */
    @safe override bool removeGroup(string groupName) nothrow {
        if (groupName != "Icon Theme") {
            return super.removeGroup(groupName);
        }
        return false;
    }

    /**
     * The name of the subdirectory index.theme was loaded from.
     * See_Also: $(D IconThemeGroup.displayName)
     */
    @trusted string internalName() const {
        return fileName().absolutePath().dirName().baseName();
    }

    /**
     * Some keys can have multiple values, separated by comma. This function helps to parse such kind of strings into the range.
     * Returns: The range of multiple nonempty values.
     * See_Also: $(D joinValues)
     */
    @trusted static auto splitValues(string values) {
        return std.algorithm.splitter(values, ',').filter!(s => s.length != 0);
    }

    ///
    unittest
    {
        assert(equal(IconThemeFile.splitValues("16x16/actions,16x16/animations,16x16/apps"), ["16x16/actions", "16x16/animations", "16x16/apps"]));
        assert(IconThemeFile.splitValues(",").empty);
        assert(IconThemeFile.splitValues("").empty);
    }

    /**
     * Join range of multiple values into a string using comma as separator.
     * If range is empty, then the empty string is returned.
     * See_Also: $(D splitValues)
     */
    static string joinValues(Range)(Range values) if (isInputRange!Range && isSomeString!(ElementType!Range)) {
        auto result = values.filter!( s => s.length != 0 ).joiner(",");
        if (result.empty) {
            return string.init;
        } else {
            return text(result);
        }
    }

    ///
    unittest
    {
        assert(equal(IconThemeFile.joinValues(["16x16/actions", "16x16/animations", "16x16/apps"]), "16x16/actions,16x16/animations,16x16/apps"));
        assert(IconThemeFile.joinValues([""]).empty);
    }

    /**
     * Iterating over subdirectories of icon theme.
     * See_Also: $(D IconThemeGroup.directories)
     */
    @trusted auto bySubdir() const {
        return directories().filter!(dir => group(dir) !is null).map!(dir => IconSubDir(group(dir))).array;
    }

    /**
     * Icon Theme group in underlying file.
     * Returns: Instance of "Icon Theme" group.
     * Note: Usually you don't need to call this function since you can rely on alias this.
     */
    @nogc @safe inout(IconThemeGroup) iconTheme() nothrow inout {
        return _iconTheme;
    }

    /**
     * This alias allows to call functions related to "Icon Theme" group without need to call iconTheme explicitly.
     */
    alias iconTheme this;

    /**
     * Try to load icon cache. Loaded icon cache will be used on icon lookup.
     * Returns: Loaded $(D icontheme.cache.IconThemeCache) object or null, if cache does not exist or invalid or outdated.
     * Note: This function expects that icon theme has fileName.
     * See_Also: $(D icontheme.cache.IconThemeCache), $(D icontheme.lookup.lookupIcon), $(D cache), $(D unloadCache), $(D cachePath)
     */
    @trusted auto tryLoadCache(Flag!"allowOutdated" allowOutdated = Flag!"allowOutdated".no) nothrow
    {
        string path = cachePath();

        bool isOutdated = true;
        collectException(IconThemeCache.isOutdated(path), isOutdated);

        if (isOutdated && !allowOutdated) {
            return null;
        }

        IconThemeCache myCache;
        collectException(new IconThemeCache(path), myCache);

        if (myCache !is null) {
            _cache = myCache;
        }
        return myCache;
    }

    /**
     * Unset loaded cache.
     */
    @nogc @safe void unloadCache() nothrow {
        _cache = null;
    }

    /**
     * Set cache object.
     * See_Also: $(D tryLoadCache)
     */
    @nogc @safe IconThemeCache cache(IconThemeCache setCache) nothrow {
        _cache = setCache;
        return _cache;
    }

    /**
     * The object of loaded cache.
     * Returns: $(D icontheme.cache.IconThemeCache) object loaded via tryLoadCache or set by cache property.
     */
    @nogc @safe inout(IconThemeCache) cache() inout nothrow {
        return _cache;
    }

    /**
     * Path of icon theme cache file.
     * Returns: Path to icon-theme.cache of corresponding cache file.
     * Note: This function expects that icon theme has fileName. This function does not check if the cache file exists.
     */
    @trusted string cachePath() const nothrow {
        auto f = fileName();
        if (f.length) {
            return buildPath(fileName().dirName, "icon-theme.cache");
        } else {
            return null;
        }
    }

private:
    IconThemeReadOptions _options;
    IconThemeGroup _iconTheme;
    IconThemeCache _cache;
}

///
unittest
{
    string contents =
`# First comment
[Icon Theme]
Name=Hicolor
Name[ru]=Стандартная тема
Comment=Fallback icon theme
Comment[ru]=Резервная тема
Hidden=true
Directories=16x16/actions,32x32/animations,scalable/emblems
Example=folder
Inherits=gnome,hicolor

[16x16/actions]
Size=16
Context=Actions
Type=Threshold

[32x32/animations]
Size=32
Context=Animations
Type=Fixed

[scalable/emblems]
Context=Emblems
Size=64
MinSize=8
MaxSize=512
Type=Scalable

# Will be saved.
[X-NoName]
Key=Value`;

    string path = buildPath(".", "test", "Tango", "index.theme");

    auto iconTheme = new IconThemeFile(iniLikeStringReader(contents), path);
    assert(equal(iconTheme.leadingComments(), ["# First comment"]));
    assert(iconTheme.displayName() == "Hicolor");
    assert(iconTheme.localizedDisplayName("ru") == "Стандартная тема");
    assert(iconTheme.comment() == "Fallback icon theme");
    assert(iconTheme.localizedComment("ru") == "Резервная тема");
    assert(iconTheme.hidden());
    assert(equal(iconTheme.directories(), ["16x16/actions", "32x32/animations", "scalable/emblems"]));
    assert(equal(iconTheme.inherits(), ["gnome", "hicolor"]));
    assert(iconTheme.internalName() == "Tango");
    assert(iconTheme.example() == "folder");
    assert(iconTheme.group("X-NoName") !is null);

    iconTheme.removeGroup("Icon Theme");
    assert(iconTheme.group("Icon Theme") !is null);

    assert(iconTheme.cachePath() == buildPath(".", "test", "Tango", "icon-theme.cache"));

    assert(equal(iconTheme.bySubdir().map!(subdir => tuple(subdir.name(), subdir.size(), subdir.minSize(), subdir.maxSize(), subdir.context(), subdir.type() )),
                 [tuple("16x16/actions", 16, 16, 16, "Actions", IconSubDir.Type.Threshold),
                 tuple("32x32/animations", 32, 32, 32, "Animations", IconSubDir.Type.Fixed),
                 tuple("scalable/emblems", 64, 8, 512, "Emblems", IconSubDir.Type.Scalable)]));

    version(iconthemeFileTest)
    {
        string cachePath = iconTheme.cachePath();
        assert(cachePath.exists);

        auto cache = new IconThemeCache(cachePath);

        assert(iconTheme.cache is null);
        iconTheme.cache = cache;
        assert(iconTheme.cache is cache);
        iconTheme.unloadCache();
        assert(iconTheme.cache is null);

        assert(iconTheme.tryLoadCache(Flag!"allowOutdated".yes));
    }

    iconTheme.removeGroup("scalable/emblems");
    assert(iconTheme.group("scalable/emblems") is null);

    auto itf = new IconThemeFile();
    itf.displayName = "Oxygen";
    itf.comment = "Oxygen theme";
    itf.hidden = true;
    itf.directories = ["actions", "places"];
    itf.inherits = ["locolor", "hicolor"];
    assert(itf.displayName() == "Oxygen");
    assert(itf.comment() == "Oxygen theme");
    assert(itf.hidden());
    assert(equal(itf.directories(), ["actions", "places"]));
    assert(equal(itf.inherits(), ["locolor", "hicolor"]));
}
