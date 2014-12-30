// Written in the D programming language.

/**

This module contains cross-platform file access utilities



Synopsis:

----
import dlangui.core.files;
----

Copyright: Vadim Lopatin, 2014
License:   Boost License 1.0
Authors:   Vadim Lopatin, coolreader.org@gmail.com
*/
module dlangui.core.files;

import std.algorithm;

private import dlangui.core.logger;
private import std.process;
private import std.path;
private import std.file;
private import std.utf;

version (Windows) {
    /// path delimiter (\ for windows, / for others)
    immutable char PATH_DELIMITER = '\\';
} else {
    /// path delimiter (\ for windows, / for others)
    immutable char PATH_DELIMITER = '/';
}

/// Filesystem root entry / bookmark types
enum RootEntryType : uint {
    /// filesystem root
    ROOT,
    /// current user home
    HOME,
    /// removable drive
    REMOVABLE,
    /// fixed drive
    FIXED,
    /// network
    NETWORK,
    /// cd rom
    CDROM,
    /// sd card
    SDCARD,
    /// custom bookmark
    BOOKMARK,
}

/// Filesystem root entry item
struct RootEntry {
    private RootEntryType _type;
    private string _path;
    private dstring _display;
    this(RootEntryType type, string path, dstring display = null) {
        _type = type;
        _path = path;
        _display = display;
        if (display is null) {
            _display = toUTF32(baseName(path));
        }
    }
    /// Returns type
    @property RootEntryType type() { return _type; }
    /// Returns path
    @property string path() { return _path; }
    /// Returns display label
    @property dstring label() { return _display; }
    /// Returns icon resource id
    @property string icon() {
        switch (type) {
            case RootEntryType.NETWORK:
                return "folder-network";
            case RootEntryType.BOOKMARK:
                return "folder-bookmark";
            case RootEntryType.CDROM:
                return "drive-optical";
            case RootEntryType.FIXED:
                return "drive-harddisk";
            case RootEntryType.HOME:
                return "user-home";
            case RootEntryType.ROOT:
                return "computer";
            case RootEntryType.SDCARD:
                return "media-flash-sd-mmc";
            case RootEntryType.REMOVABLE:
                return "device-removable-media";
            default:
                return "folder-blue";
        }
    }
}

/// Returns 
@property RootEntry homeEntry() {
    return RootEntry(RootEntryType.HOME, homePath);
}

/// returns array of system root entries
@property RootEntry[] getRootPaths() {
    RootEntry[] res;
    res ~= RootEntry(RootEntryType.HOME, homePath);
    version (posix) {
        res ~= RootEntry(RootEntryType.ROOT, "/", "File System"d);
    }
    version (Windows) {
        import win32.windows;
        uint mask = GetLogicalDrives();
        for (int i = 0; i < 26; i++) {
            if (mask & (1 << i)) {
                char letter = cast(char)('A' + i);
                string path = "" ~ letter ~ ":\\";
                dstring display = ""d ~ letter ~ ":"d;
                // detect drive type
                RootEntryType type;
                uint wtype = GetDriveTypeA(("" ~ path).ptr);
                //Log.d("Drive ", path, " type ", wtype);
                switch (wtype) {
                    case DRIVE_REMOVABLE:
                        type = RootEntryType.REMOVABLE;
                        break;
                    case DRIVE_REMOTE:
                        type = RootEntryType.NETWORK;
                        break;
                    case DRIVE_CDROM:
                        type = RootEntryType.CDROM;
                        break;
                    default:
                        type = RootEntryType.FIXED;
                        break;
                }
                res ~= RootEntry(type, path, display);
            }
        }
    }
    return res;
}

/// returns true if directory is root directory (e.g. / or C:\)
bool isRoot(string path) {
    string root = rootName(path);
    if (path.equal(root))
        return true;
    return false;
}

/// returns parent directory for specified path
string parentDir(string path) {
    return buildNormalizedPath(path, "..");
}

/// Filters file name by pattern list
bool filterFilename(string filename, string[] filters) {
    return true;
}

/** List directory content 
    
    Optionally filters file names by filter.

    Result will be placed into entries array.

    Returns true if directory exists and listed successfully, false otherwise.
*/
bool listDirectory(string dir, bool includeDirs, bool includeFiles, bool showHiddenFiles, string[] filters, ref DirEntry[] entries) {

    entries.length = 0;

    if (!isDir(dir)) {
        return false;
    }

    if (!isRoot(dir) && includeDirs) {
        entries ~= DirEntry(appendPath(dir, ".."));
    }

    try {
        DirEntry[] dirs;
        DirEntry[] files;
        foreach (DirEntry e; dirEntries(dir, SpanMode.shallow)) {
            string fn = baseName(e.name);
            if (!showHiddenFiles && fn.startsWith("."))
                continue;
            if (e.isDir) {
                dirs ~= e;
            } else if (e.isFile) {
                files ~= e;
            }
        }
        if (includeDirs)
            foreach(DirEntry e; dirs)
                entries ~= e;
        if (includeFiles)
            foreach(DirEntry e; files)
                if (filterFilename(e.name, filters))
                    entries ~= e;
        return true;
    } catch (FileException e) {
        return false;
    }

}

/** Returns true if char ch is / or \ slash */
bool isPathDelimiter(char ch) {
    return ch == '/' || ch == '\\';
}

/// Returns current directory
@property string currentDir() {
    return getcwd();
}

/** Returns current executable path only, including last path delimiter - removes executable name from result of std.file.thisExePath() */
@property string exePath() {
    string path = thisExePath();
    int lastSlash = 0;
    for (int i = 0; i < path.length; i++)
        if (path[i] == PATH_DELIMITER)
            lastSlash = i;
    return path[0 .. lastSlash + 1];
}

/// Returns user's home directory
@property string homePath() {
    string path;
    version (Windows) {
        path = environment.get("USERPROFILE");
        if (path is null)
            path = environment.get("HOME");
    } else {
        path = environment.get("HOME");
    }
    if (path is null)
        path = "."; // fallback to current directory
    return path;
}

/** 
    
    Returns application data directory

    On unix, it will return path to subdirectory in home directory - e.g. /home/user/.subdir if ".subdir" is passed as a paramter.

    On windows, it will return path to subdir in APPDATA directory - e.g. C:\Users\User\AppData\Roaming\.subdir.

 */
string appDataPath(string subdir = null) {
    string path;
    version (Windows) {
        path = environment.get("APPDATA");
    }
    if (path is null)
        path = homePath;
    if (subdir !is null) {
        path ~= PATH_DELIMITER;
        path ~= subdir;
    }
    return path;
}

/// Converts path delimiters to standard for platform inplace in buffer(e.g. / to \ on windows, \ to / on posix), returns buf
char[] convertPathDelimiters(char[] buf) {
    foreach(ref ch; buf) {
        version (Windows) {
            if (ch == '/')
                ch = '\\';
        } else {
            if (ch == '\\')
                ch = '/';
        }
    }
    return buf;
}

/** Converts path delimiters to standard for platform (e.g. / to \ on windows, \ to / on posix) */
string convertPathDelimiters(string src) {
    char[] buf = src.dup;
    return cast(string)convertPathDelimiters(buf);
}

/** Appends file path parts with proper delimiters e.g. appendPath("/home/user", ".myapp", "config") => "/home/user/.myapp/config" */
string appendPath(string[] pathItems ...) {
    char[] buf;
    foreach (s; pathItems) {
        if (buf.length && !isPathDelimiter(buf[$-1]))
            buf ~= PATH_DELIMITER;
        buf ~= s;
    }
    return convertPathDelimiters(buf).dup;
}

/**  Appends file path parts with proper delimiters (as well converts delimiters inside path to system) to buffer e.g. appendPath("/home/user", ".myapp", "config") => "/home/user/.myapp/config" */
char[] appendPath(char[] buf, string[] pathItems ...) {
    foreach (s; pathItems) {
        if (buf.length && !isPathDelimiter(buf[$-1]))
            buf ~= PATH_DELIMITER;
        buf ~= s;
    }
    return convertPathDelimiters(buf);
}

/** Split path into elements, e.g. /home/user/dir1 -> ["home", "user", "dir1"], "c:\dir1\dir2" -> ["c:", "dir1", "dir2"] */
string[] splitPath(string path) {
	string[] res;
	int start = 0;
	for (int i = 0; i <= path.length; i++) {
		char ch = i < path.length ? path[i] : 0;
		if (ch == '\\' || ch == '/' || ch == 0) {
			if (start < i)
				res ~= path[start .. i].dup;
			start = i + 1;
		}
	}
	return res;
}
