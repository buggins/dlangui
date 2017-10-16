/**
 * Lookup of icon themes and icons.
 *
 * Note: All found icons are just paths. They are not verified to be valid images.
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

module icontheme.lookup;

import icontheme.file;

package {
    import std.file;
    import std.path;
    import std.range;
    import std.traits;
    import std.typecons;
}

@trusted bool isDirNothrow(string dir) nothrow
{
    bool ok;
    collectException(dir.isDir(), ok);
    return ok;
}

@trusted bool isFileNothrow(string file) nothrow
{
    bool ok;
    collectException(file.isFile(), ok);
    return ok;
}

/**
 * Default icon extensions. This array includes .png and .xpm.
 * PNG is recommended format.
 * XPM is kept for backward compatibility.
 *
 * Note: Icon Theme Specificiation also lists .svg as possible format,
 * but it's less common to have SVG support for applications,
 * hence this format is defined as optional by specificiation.
 * If your application has proper support for SVG images,
 * array should include it in the first place as the most preferred format
 * because SVG images are scalable.
 */
enum defaultIconExtensions = [".png", ".xpm"];

/**
 * Find all icon themes in searchIconDirs.
 * Note:
 *  You may want to skip icon themes duplicates if there're different versions of the index.theme file for the same theme.
 * Returns:
 *  Range of paths to index.theme files represented icon themes.
 * Params:
 *  searchIconDirs = base icon directories to search icon themes.
 * See_Also: $(D icontheme.paths.baseIconDirs)
 */
auto iconThemePaths(Range)(Range searchIconDirs)
if(is(ElementType!Range : string))
{
    return searchIconDirs
        .filter!(function(dir) {
            bool ok;
            collectException(dir.isDir, ok);
            return ok;
        }).map!(function(iconDir) {
            return iconDir.dirEntries(SpanMode.shallow)
                .map!(p => buildPath(p, "index.theme")).cache()
                .filter!(isFileNothrow);
        }).joiner;
}

///
version(iconthemeFileTest) unittest
{
    auto paths = iconThemePaths(["test"]).array;
    assert(paths.length == 3);
    assert(paths.canFind(buildPath("test", "NewTango", "index.theme")));
    assert(paths.canFind(buildPath("test", "Tango", "index.theme")));
    assert(paths.canFind(buildPath("test", "hicolor", "index.theme")));
}

/**
 * Lookup index.theme files by theme name.
 * Params:
 *  themeName = theme name.
 *  searchIconDirs = base icon directories to search icon themes.
 * Returns:
 *  Range of paths to index.theme file corresponding to the given theme.
 * Note:
 *  Usually you want to use the only first found file.
 * See_Also: $(D icontheme.paths.baseIconDirs), $(D findIconTheme)
 */
auto lookupIconTheme(Range)(string themeName, Range searchIconDirs)
if(is(ElementType!Range : string))
{
    return searchIconDirs
        .map!(dir => buildPath(dir, themeName, "index.theme")).cache()
        .filter!(isFileNothrow);
}

/**
 * Find index.theme file by theme name.
 * Returns:
 *  Path to the first found index.theme file or null string if not found.
 * Params:
 *  themeName = Theme name.
 *  searchIconDirs = Base icon directories to search icon themes.
 * Returns:
 *  Path to the first found index.theme file corresponding to the given theme.
 * See_Also: $(D icontheme.paths.baseIconDirs), $(D lookupIconTheme)
 */
auto findIconTheme(Range)(string themeName, Range searchIconDirs)
{
    auto paths = lookupIconTheme(themeName, searchIconDirs);
    if (paths.empty) {
        return null;
    } else {
        return paths.front;
    }
}

/**
 * Find index.theme file for given theme and create instance of $(D icontheme.file.IconThemeFile). The first found file will be used.
 * Returns: $(D icontheme.file.IconThemeFile) object read from the first found index.theme file corresponding to given theme or null if none were found.
 * Params:
 *  themeName = theme name.
 *  searchIconDirs = base icon directories to search icon themes.
 *  options = options for $(D icontheme.file.IconThemeFile) reading.
 * Throws:
 *  $(B ErrnoException) if file could not be opened.
 *  $(B IniLikeException) if error occured while reading the file.
 * See_Also: $(D findIconTheme), $(D icontheme.paths.baseIconDirs)
 */
IconThemeFile openIconTheme(Range)(string themeName,
                                         Range searchIconDirs,
                                         IconThemeFile.IconThemeReadOptions options = IconThemeFile.IconThemeReadOptions.init)
{
    auto path = findIconTheme(themeName, searchIconDirs);
    return path.empty ? null : new IconThemeFile(to!string(path), options);
}

///
version(iconthemeFileTest) unittest
{
    auto tango = openIconTheme("Tango", ["test"]);
    assert(tango);
    assert(tango.displayName() == "Tango");

    auto hicolor = openIconTheme("hicolor", ["test"]);
    assert(hicolor);
    assert(hicolor.displayName() == "Hicolor");

    assert(openIconTheme("Nonexistent", ["test"]) is null);
}

/**
 * Result of icon lookup.
 */
struct IconSearchResult(IconTheme) if (is(IconTheme : const(IconThemeFile)))
{
    /**
     * File path of found icon.
     */
    string filePath;
    /**
     * Subdirectory the found icon belongs to.
     */
    IconSubDir subdir;
    /**
     * $(D icontheme.file.IconThemeFile) the found icon belongs to.
     */
    IconTheme iconTheme;
}

/**
 * Lookup icon alternatives in icon themes. It uses icon theme cache wherever it's loaded. If searched icon is found in some icon theme all subsequent themes are ignored.
 *
 * This function may require many $(B stat) calls, so beware. Use subdirFilter to filter icons by $(D icontheme.file.IconSubDir) properties (e.g. by size or context) to decrease the number of searchable items and allocations. Loading $(D icontheme.cache.IconThemeCache) may also descrease the number of stats.
 *
 * Params:
 *  iconName = Icon name.
 *  iconThemes = Icon themes to search icon in.
 *  searchIconDirs = Case icon directories.
 *  extensions = Possible file extensions of needed icon file, in order of preference.
 *  sink = Output range accepting $(D IconSearchResult)s.
 *  reverse = Iterate over icon theme sub-directories in reverse way.
 *      Usually directories with larger icon size are listed the last,
 *      so this parameter may speed up the search when looking for the largest icon.
 * Note: Specification says that extension must be ".png", ".xpm" or ".svg", though SVG is not required to be supported. Some icon themes also contain .svgz images.
 * Example:
----------
lookupIcon!(subdir => subdir.context == "Places" && subdir.size >= 32)(
    "folder", iconThemes, baseIconDirs(), [".png", ".xpm"],
    delegate void (IconSearchResult!IconThemeFile item) {
        writefln("Icon file: %s. Context: %s. Size: %s. Theme: %s", item.filePath, item.subdir.context, item.subdir.size, item.iconTheme.displayName);
    });
----------
 * See_Also: $(D icontheme.paths.baseIconDirs), $(D lookupFallbackIcon)
 */
void lookupIcon(alias subdirFilter = (a => true), IconThemes, BaseDirs, Exts, OutputRange)(string iconName, IconThemes iconThemes, BaseDirs searchIconDirs, Exts extensions, OutputRange sink, Flag!"reverse" reverse = No.reverse)
if (isInputRange!(IconThemes) && isForwardRange!(BaseDirs) && isForwardRange!(Exts) &&
    is(ElementType!IconThemes : const(IconThemeFile)) && is(ElementType!BaseDirs : string) &&
    is(ElementType!Exts : string) && isOutputRange!(OutputRange, IconSearchResult!(ElementType!IconThemes)))
{
    bool onExtensions(string themeBaseDir, IconSubDir subdir, ElementType!IconThemes iconTheme)
    {
        string subdirPath = buildPath(themeBaseDir, subdir.name);
        if (!subdirPath.isDirNothrow) {
            return false;
        }
        bool found;
        foreach(extension; extensions) {
            string path = buildPath(subdirPath, iconName ~ extension);
            if (path.isFileNothrow) {
                found = true;
                put(sink, IconSearchResult!(ElementType!IconThemes)(path, subdir, iconTheme));
            }
        }
        return found;
    }

    foreach(iconTheme; iconThemes) {
        if (iconTheme is null || iconTheme.internalName().length == 0) {
            continue;
        }

        string[] themeBaseDirs = searchIconDirs.map!(dir => buildPath(dir, iconTheme.internalName())).filter!(isDirNothrow).array;

        bool found;

        auto bySubdir = choose(reverse, iconTheme.bySubdir().retro(), iconTheme.bySubdir());
        foreach(subdir; bySubdir) {
            if (!subdirFilter(subdir)) {
                continue;
            }
            foreach(themeBaseDir; themeBaseDirs) {
                if (iconTheme.cache !is null && themeBaseDir == iconTheme.cache.fileName.dirName) {
                    if (iconTheme.cache.containsIcon(iconName, subdir.name)) {
                        found = onExtensions(themeBaseDir, subdir, iconTheme) || found;
                    }
                } else {
                    found = onExtensions(themeBaseDir, subdir, iconTheme) || found;
                }
            }
        }
        if (found) {
            return;
        }
    }
}

/**
 * Iterate over all icons in icon themes.
 * iconThemes is usually the range of the main theme and themes it inherits from.
 * Note: Usually if some icon was found in icon theme, it should be ignored in all subsequent themes, including sizes not presented in former theme.
 * Use subdirFilter to filter icons by $(D icontheme.file.IconSubDir) thus decreasing the number of searchable items and allocations.
 * Returns: Range of $(D IconSearchResult).
 * Params:
 *  iconThemes = icon themes to search icon in.
 *  searchIconDirs = base icon directories.
 *  extensions = possible file extensions for icon files.
 * Example:
-------------
foreach(item; lookupThemeIcons!(subdir => subdir.context == "MimeTypes" && subdir.size >= 32)(iconThemes, baseIconDirs(), [".png", ".xpm"]))
{
    writefln("Icon file: %s. Context: %s. Size: %s", item.filePath, item.subdir.context, item.subdir.size);
}
-------------
 * See_Also: $(D icontheme.paths.baseIconDirs), $(D lookupIcon), $(D openBaseThemes)
 */

auto lookupThemeIcons(alias subdirFilter = (a => true), IconThemes, BaseDirs, Exts)(IconThemes iconThemes, BaseDirs searchIconDirs, Exts extensions)
if (is(ElementType!IconThemes : const(IconThemeFile)) && is(ElementType!BaseDirs : string) && is (ElementType!Exts : string))
{
    return iconThemes.filter!(iconTheme => iconTheme !is null).map!(
        iconTheme => iconTheme.bySubdir().filter!(subdirFilter).map!(
            subdir => searchIconDirs.map!(
                basePath => buildPath(basePath, iconTheme.internalName(), subdir.name)
            ).filter!(isDirNothrow).map!(
                subdirPath => subdirPath.dirEntries(SpanMode.shallow).filter!(
                    filePath => filePath.isFileNothrow && extensions.canFind(filePath.extension)
                ).map!(filePath => IconSearchResult!(ElementType!IconThemes)(filePath, subdir, iconTheme))
            ).joiner
        ).joiner
    ).joiner;
}

/**
 * Iterate over all icons out of icon themes.
 * Returns: Range of found icon file paths.
 * Params:
 *  searchIconDirs = base icon directories.
 *  extensions = possible file extensions for icon files.
 * See_Also:
 *  $(D lookupFallbackIcon), $(D icontheme.paths.baseIconDirs)
 */
auto lookupFallbackIcons(BaseDirs, Exts)(BaseDirs searchIconDirs, Exts extensions)
if (isInputRange!(BaseDirs) && isForwardRange!(Exts) &&
    is(ElementType!BaseDirs : string) && is(ElementType!Exts : string))
{
    return searchIconDirs.filter!(isDirNothrow).map!(basePath => basePath.dirEntries(SpanMode.shallow).filter!(
        filePath => filePath.isFileNothrow && extensions.canFind(filePath.extension)
    )).joiner;
}

/**
 * Lookup icon alternatives beyond the icon themes. May be used as fallback lookup, if lookupIcon returned empty range.
 * Returns: The range of found icon file paths.
 * Example:
----------
auto result = lookupFallbackIcon("folder", baseIconDirs(), [".png", ".xpm"]);
----------
 * See_Also: $(D icontheme.paths.baseIconDirs), $(D lookupIcon), $(D lookupFallbackIcons)
 */
auto lookupFallbackIcon(BaseDirs, Exts)(string iconName, BaseDirs searchIconDirs, Exts extensions)
if (isInputRange!(BaseDirs) && isForwardRange!(Exts) &&
    is(ElementType!BaseDirs : string) && is(ElementType!Exts : string))
{
    return searchIconDirs.map!(basePath =>
        extensions
            .map!(extension => buildPath(basePath, iconName ~ extension)).cache()
            .filter!(isFileNothrow)
    ).joiner;
}

/**
 * Find fallback icon outside of icon themes. The first found is returned.
 * See_Also: $(D lookupFallbackIcon), $(D icontheme.paths.baseIconDirs)
 */
string findFallbackIcon(BaseDirs, Exts)(string iconName, BaseDirs searchIconDirs, Exts extensions)
{
    auto r = lookupFallbackIcon(iconName, searchIconDirs, extensions);
    if (r.empty) {
        return null;
    } else {
        return r.front;
    }
}

///
version(iconthemeFileTest) unittest
{
    assert(findFallbackIcon("pidgin", ["test"], defaultIconExtensions) == buildPath("test", "pidgin.png"));
    assert(findFallbackIcon("nonexistent", ["test"], defaultIconExtensions).empty);
}

/**
 * Find icon closest of the size. It uses icon theme cache wherever possible. The first perfect match is used.
 * Params:
 *  iconName = Name of icon to search as defined by Icon Theme Specification (i.e. without path and extension parts).
 *  size = Preferred icon size to get.
 *  iconThemes = Range of $(D icontheme.file.IconThemeFile) objects.
 *  searchIconDirs = Base icon directories.
 *  extensions = Allowed file extensions.
 *  allowFallback = Allow searching for non-themed fallback if could not find icon in themes (non-themed icon can be any size).
 * Returns: Icon file path or empty string if not found.
 * Note: If icon of some size was found in the icon theme, this algorithm does not check following themes, even if they contain icons with closer size. Therefore the icon found in the more preferred theme always has presedence over icons from other themes.
 * See_Also: $(D icontheme.paths.baseIconDirs), $(D lookupIcon), $(D findFallbackIcon), $(D iconSizeDistance)
 */
string findClosestIcon(alias subdirFilter = (a => true), IconThemes, BaseDirs, Exts)(string iconName, uint size, IconThemes iconThemes, BaseDirs searchIconDirs, Exts extensions, Flag!"allowFallbackIcon" allowFallback = Yes.allowFallbackIcon)
{
    uint minDistance = uint.max;
    string closest;

    lookupIcon!(delegate bool(const(IconSubDir) subdir) {
        return minDistance != 0 && subdirFilter(subdir) && iconSizeDistance(subdir, size) <= minDistance;
    })(iconName, iconThemes, searchIconDirs, extensions, delegate void(IconSearchResult!(ElementType!IconThemes) t) {
        auto path = t.filePath;
        auto subdir = t.subdir;
        auto theme = t.iconTheme;

        uint distance = iconSizeDistance(subdir, size);
        if (distance < minDistance) {
            minDistance = distance;
            closest = path;
        }
    });

    if (closest.empty && allowFallback) {
        return findFallbackIcon(iconName, searchIconDirs, extensions);
    } else {
        return closest;
    }
}

///
version(iconthemeFileTest) unittest
{
    auto baseDirs = ["test"];
    auto iconThemes = [openIconTheme("Tango", baseDirs), openIconTheme("hicolor", baseDirs)];

    string found;

    //exact match
    found = findClosestIcon("folder", 32, iconThemes, baseDirs);
    assert(found == buildPath("test", "Tango", "32x32/places", "folder.png"));

    found = findClosestIcon("folder", 24, iconThemes, baseDirs);
    assert(found == buildPath("test", "Tango", "24x24/devices", "folder.png"));

    found = findClosestIcon!(subdir => subdir.context == "Places")("folder", 32, iconThemes, baseDirs);
    assert(found == buildPath("test", "Tango", "32x32/places", "folder.png"));

    found = findClosestIcon!(subdir => subdir.context == "Places")("folder", 24, iconThemes, baseDirs);
    assert(found == buildPath("test", "Tango", "32x32/places", "folder.png"));

    found = findClosestIcon!(subdir => subdir.context == "MimeTypes")("folder", 32, iconThemes, baseDirs);
    assert(found.empty);

    //hicolor has exact match, but Tango is more preferred.
    found = findClosestIcon("folder", 64, iconThemes, baseDirs);
    assert(found == buildPath("test", "Tango", "32x32/places", "folder.png"));

    //find xpm
    found = findClosestIcon("folder", 32, iconThemes, baseDirs, [".xpm"]);
    assert(found == buildPath("test", "Tango", "32x32/places", "folder.xpm"));

    //find big png, not exact match
    found = findClosestIcon("folder", 200, iconThemes, baseDirs);
    assert(found == buildPath("test", "Tango", "128x128/places", "folder.png"));

    //svg is closer
    found = findClosestIcon("folder", 200, iconThemes, baseDirs, [".png", ".svg"]);
    assert(found == buildPath("test", "Tango", "scalable/places", "folder.svg"));

    //lookup with fallback
    found = findClosestIcon("pidgin", 96, iconThemes, baseDirs);
    assert(found == buildPath("test", "pidgin.png"));

    //lookup without fallback
    found = findClosestIcon("pidgin", 96, iconThemes, baseDirs, defaultIconExtensions, No.allowFallbackIcon);
    assert(found.empty);

    found = findClosestIcon("text-plain", 48, iconThemes, baseDirs);
    assert(found == buildPath("test", "hicolor", "48x48/mimetypes", "text-plain.png"));

    found = findClosestIcon!(subdir => subdir.context == "MimeTypes")("text-plain", 48, iconThemes, baseDirs);
    assert(found == buildPath("test", "hicolor", "48x48/mimetypes", "text-plain.png"));

    found = findClosestIcon!(subdir => subdir.context == "Actions")("text-plain", 48, iconThemes, baseDirs);
    assert(found.empty);
}

/**
 * ditto, but with predefined extensions and fallback allowed.
 * See_Also: $(D defaultIconExtensions)
 */
string findClosestIcon(alias subdirFilter = (a => true), IconThemes, BaseDirs)(string iconName, uint size, IconThemes iconThemes, BaseDirs searchIconDirs)
{
    return findClosestIcon!subdirFilter(iconName, size, iconThemes, searchIconDirs, defaultIconExtensions);
}

/**
 * Find icon of the largest size. It uses icon theme cache wherever possible.
 * Params:
 *  iconName = Name of icon to search as defined by Icon Theme Specification (i.e. without path and extension parts).
 *  iconThemes = Range of $(D icontheme.file.IconThemeFile) objects.
 *  searchIconDirs = Base icon directories.
 *  extensions = Allowed file extensions.
 *  allowFallback = Allow searching for non-themed fallback if could not find icon in themes.
 * Returns: Icon file path or empty string if not found.
 * Note: If icon of some size was found in the icon theme, this algorithm does not check following themes, even if they contain icons with larger size. Therefore the icon found in the most preferred theme always has presedence over icons from other themes.
 * See_Also: $(D icontheme.paths.baseIconDirs), $(D lookupIcon), $(D findFallbackIcon)
 */
string findLargestIcon(alias subdirFilter = (a => true), IconThemes, BaseDirs, Exts)(string iconName, IconThemes iconThemes, BaseDirs searchIconDirs, Exts extensions, Flag!"allowFallbackIcon" allowFallback = Yes.allowFallbackIcon)
{
    uint max = 0;
    string largest;

    lookupIcon!(delegate bool(const(IconSubDir) subdir) {
        return subdirFilter(subdir) && subdir.size() >= max;
    })(iconName, iconThemes, searchIconDirs, extensions, delegate void(IconSearchResult!(ElementType!IconThemes) t) {
        auto path = t.filePath;
        auto subdir = t.subdir;
        auto theme = t.iconTheme;

        if (subdir.size() > max) {
            max = subdir.size();
            largest = path;
        }
    }, Yes.reverse);

    if (largest.empty && allowFallback) {
        return findFallbackIcon(iconName, searchIconDirs, extensions);
    } else {
        return largest;
    }
}

///
version(iconthemeFileTest) unittest
{
    auto baseDirs = ["test"];
    auto iconThemes = [openIconTheme("Tango", baseDirs), openIconTheme("hicolor", baseDirs)];

    string found;

    found = findLargestIcon("folder", iconThemes, baseDirs);
    assert(found == buildPath("test", "Tango", "128x128/places", "folder.png"));

    found = findLargestIcon("desktop", iconThemes, baseDirs);
    assert(found == buildPath("test", "Tango", "32x32/places", "desktop.png"));

    found = findLargestIcon("desktop", iconThemes, baseDirs, [".svg", ".png"]);
    assert(found == buildPath("test", "Tango", "scalable/places", "desktop.svg"));

    //lookup with fallback
    found = findLargestIcon("pidgin", iconThemes, baseDirs);
    assert(found == buildPath("test", "pidgin.png"));

    //lookup without fallback
    found = findLargestIcon("pidgin", iconThemes, baseDirs, defaultIconExtensions, No.allowFallbackIcon);
    assert(found.empty);
}

/**
 * ditto, but with predefined extensions and fallback allowed.
 * See_Also: $(D defaultIconExtensions)
 */
string findLargestIcon(alias subdirFilter = (a => true), IconThemes, BaseDirs)(string iconName, IconThemes iconThemes, BaseDirs searchIconDirs)
{
    return findLargestIcon!subdirFilter(iconName, iconThemes, searchIconDirs, defaultIconExtensions);
}

/**
 * Distance between desired size and minimum or maximum size value supported by icon theme subdirectory.
 */
@nogc @safe uint iconSizeDistance(in IconSubDir subdir, uint matchSize) nothrow pure
{
    const uint size = subdir.size();
    const uint minSize = subdir.minSize();
    const uint maxSize = subdir.maxSize();
    const uint threshold = subdir.threshold();

    final switch(subdir.type()) {
        case IconSubDir.Type.Fixed:
        {
            if (size > matchSize) {
                return size - matchSize;
            } else if (size < matchSize) {
                return matchSize - size;
            } else {
                return 0;
            }
        }
        case IconSubDir.Type.Scalable:
        {
            if (matchSize < minSize) {
                return minSize - matchSize;
            } else if (matchSize > maxSize) {
                return matchSize - maxSize;
            } else {
                return 0;
            }
        }
        case IconSubDir.Type.Threshold:
        {
            if (matchSize < size - threshold) {
                return (size - threshold) - matchSize;
            } else if (matchSize > size + threshold) {
                return matchSize - (size + threshold);
            } else {
                return 0;
            }
        }
    }
}

///
unittest
{
    auto fixed = IconSubDir(32, IconSubDir.Type.Fixed);
    assert(iconSizeDistance(fixed, fixed.size()) == 0);
    assert(iconSizeDistance(fixed, 30) == 2);
    assert(iconSizeDistance(fixed, 35) == 3);

    auto threshold = IconSubDir(32, IconSubDir.Type.Threshold, "", 0, 0, 5);
    assert(iconSizeDistance(threshold, threshold.size()) == 0);
    assert(iconSizeDistance(threshold, threshold.size() - threshold.threshold()) == 0);
    assert(iconSizeDistance(threshold, threshold.size() + threshold.threshold()) == 0);
    assert(iconSizeDistance(threshold, 26) == 1);
    assert(iconSizeDistance(threshold, 39) == 2);

    auto scalable = IconSubDir(32, IconSubDir.Type.Scalable, "", 24, 48);
    assert(iconSizeDistance(scalable, scalable.size()) == 0);
    assert(iconSizeDistance(scalable, scalable.minSize()) == 0);
    assert(iconSizeDistance(scalable, scalable.maxSize()) == 0);
    assert(iconSizeDistance(scalable, 20) == 4);
    assert(iconSizeDistance(scalable, 50) == 2);
}

/**
 * Check if matchSize belongs to subdir's size range.
 */
@nogc @safe bool matchIconSize(in IconSubDir subdir, uint matchSize) nothrow pure
{
    const uint size = subdir.size();
    const uint minSize = subdir.minSize();
    const uint maxSize = subdir.maxSize();
    const uint threshold = subdir.threshold();

    final switch(subdir.type()) {
        case IconSubDir.Type.Fixed:
            return size == matchSize;
        case IconSubDir.Type.Threshold:
            return matchSize <= (size + threshold) && matchSize >= (size - threshold);
        case IconSubDir.Type.Scalable:
            return matchSize >= minSize && matchSize <= maxSize;
    }
}

///
unittest
{
    auto fixed = IconSubDir(32, IconSubDir.Type.Fixed);
    assert(matchIconSize(fixed, fixed.size()));
    assert(!matchIconSize(fixed, fixed.size() - 2));

    auto threshold = IconSubDir(32, IconSubDir.Type.Threshold, "", 0, 0, 5);
    assert(matchIconSize(threshold, threshold.size() + threshold.threshold()));
    assert(matchIconSize(threshold, threshold.size() - threshold.threshold()));
    assert(!matchIconSize(threshold, threshold.size() + threshold.threshold() + 1));
    assert(!matchIconSize(threshold, threshold.size() - threshold.threshold() - 1));

    auto scalable = IconSubDir(32, IconSubDir.Type.Scalable, "", 24, 48);
    assert(matchIconSize(scalable, scalable.minSize()));
    assert(matchIconSize(scalable, scalable.maxSize()));
    assert(!matchIconSize(scalable, scalable.minSize() - 1));
    assert(!matchIconSize(scalable, scalable.maxSize() + 1));
}

/**
 * Find icon closest to the given size among given alternatives.
 * Params:
 *  alternatives = range of $(D IconSearchResult)s, usually returned by $(D lookupIcon).
 *  matchSize = desired size of icon.
 */
string matchBestIcon(Range)(Range alternatives, uint matchSize)
{
    uint minDistance = uint.max;
    string closest;

    foreach(t; alternatives) {
        auto path = t[0];
        auto subdir = t[1];
        uint distance = iconSizeDistance(subdir, matchSize);
        if (distance < minDistance) {
            minDistance = distance;
            closest = path;
        }
        if (minDistance == 0) {
            return closest;
        }
    }

    return closest;
}

private void openBaseThemesHelper(Range)(ref IconThemeFile[] themes, IconThemeFile iconTheme,
                                      Range searchIconDirs,
                                      IconThemeFile.IconThemeReadOptions options)
{
    foreach(name; iconTheme.inherits()) {
        if (!themes.canFind!(function(theme, name) {
            return theme.internalName == name;
        })(name)) {
            try {
                IconThemeFile f = openIconTheme(name, searchIconDirs, options);
                if (f) {
                    themes ~= f;
                    openBaseThemesHelper(themes, f, searchIconDirs, options);
                }
            } catch(Exception e) {

            }
        }
    }
}

/**
 * Recursively find all themes the given theme is inherited from.
 * Params:
 *  iconTheme = Original icon theme to search for its base themes. Included as first element in resulting array.
 *  searchIconDirs = Base icon directories to search icon themes.
 *  fallbackThemeName = Name of fallback theme which is loaded the last. Not used if empty. It's NOT loaded twice if some theme in inheritance tree has it as base theme.
 *  options = Options for $(D icontheme.file.IconThemeFile) reading.
 * Returns:
 *  Array of unique $(D icontheme.file.IconThemeFile) objects represented base themes.
 */
IconThemeFile[] openBaseThemes(Range)(IconThemeFile iconTheme,
                                      Range searchIconDirs,
                                      string fallbackThemeName = "hicolor",
                                      IconThemeFile.IconThemeReadOptions options = IconThemeFile.IconThemeReadOptions.init)
if(isForwardRange!Range && is(ElementType!Range : string))
{
    IconThemeFile[] themes;
    openBaseThemesHelper(themes, iconTheme, searchIconDirs, options);

    if (fallbackThemeName.length) {
        auto fallbackFound = themes.filter!(theme => theme !is null).find!(theme => theme.internalName == fallbackThemeName);
        if (fallbackFound.empty) {
            IconThemeFile fallbackTheme;
            collectException(openIconTheme(fallbackThemeName, searchIconDirs, options), fallbackTheme);
            if (fallbackTheme) {
                themes ~= fallbackTheme;
            }
        }
    }

    return themes;
}

///
version(iconthemeFileTest) unittest
{
    auto tango = openIconTheme("NewTango", ["test"]);
    auto baseThemes = openBaseThemes(tango, ["test"]);

    assert(baseThemes.length == 2);
    assert(baseThemes[0].internalName() == "Tango");
    assert(baseThemes[1].internalName() == "hicolor");

    baseThemes = openBaseThemes(tango, ["test"], null);
    assert(baseThemes.length == 1);
    assert(baseThemes[0].internalName() == "Tango");
}
