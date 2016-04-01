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


/// path delimiter (\ for windows, / for others)
enum char PATH_DELIMITER = dirSeparator[0];

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
        switch (type) with(RootEntryType)
        {
            case NETWORK:
                return "folder-network";
            case BOOKMARK:
                return "folder-bookmark";
            case CDROM:
                return "drive-optical";
            case FIXED:
                return "drive-harddisk";
            case HOME:
                return "user-home";
            case ROOT:
                return "computer";
            case SDCARD:
                return "media-flash-sd-mmc";
            case REMOVABLE:
                return "device-removable-media";
            default:
                return "folder-blue";
        }
    }
}

/// Returns user's home directory entry
@property RootEntry homeEntry() {
    return RootEntry(RootEntryType.HOME, homePath);
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

version(linux)
{
    import core.stdc.stdio : FILE;
    struct mntent
    {
        char *mnt_fsname;   /* Device or server for filesystem.  */
        char *mnt_dir;      /* Directory mounted on.  */
        char *mnt_type;     /* Type of filesystem: ufs, nfs, etc.  */
        char *mnt_opts;     /* Comma-separated options for fs.  */
        int mnt_freq;       /* Dump frequency (in days).  */
        int mnt_passno;     /* Pass number for `fsck'.  */
    };
    
    extern(C) @nogc nothrow 
    {
        FILE *setmntent(const char *file, const char *mode);
        mntent *getmntent(FILE *stream);
        mntent *getmntent_r(FILE * stream, mntent *result, char * buffer, int bufsize);
        int addmntent(FILE* stream, const mntent *mnt);
        int endmntent(FILE * stream);
        char *hasmntopt(const mntent *mnt, const char *opt);
    }
    
    string unescapeLabel(string label)
    {
        import std.string : replace;
        return label.replace("\\x20", " ")
                    .replace("\\x9", " ") //actually tab
                    .replace("\\x5c", "\\")
                    .replace("\\xA", " "); //actually newline
    }
    
    bool isSpecialFileSystem(const(char)[] dir, const(char)[] type)
    {
        import std.string : startsWith;
        if (dir.startsWith("/dev") || dir.startsWith("/proc") || dir.startsWith("/sys") || 
            dir.startsWith("/var/run") || dir.startsWith("/var/lock"))
        {
            return true;
        }
        
        if (type == "tmpfs" || type == "rootfs" || type == "rpc_pipefs") {
            return true;
        }
        return false;
    }
}

/// returns array of system root entries
@property RootEntry[] getRootPaths() {
    RootEntry[] res;
    res ~= RootEntry(RootEntryType.HOME, homePath);
    version (Posix) {
        res ~= RootEntry(RootEntryType.ROOT, "/", "File System"d);
    }
    version(linux) {
        import std.string : fromStringz;
        import std.format : format;
        
        mntent ent;
        char[1024] buf;
        FILE* f = setmntent("/etc/mtab", "r");
        
        if (f) {
            scope(exit) endmntent(f);
            while(getmntent_r(f, &ent, buf.ptr, cast(int)buf.length) !is null) {
                auto fsName = fromStringz(ent.mnt_fsname);
                auto mountDir = fromStringz(ent.mnt_dir);
                auto type = fromStringz(ent.mnt_type);
                
                if (mountDir == "/" || //root is already added
                    isSpecialFileSystem(mountDir, type)) //don't list special file systems
                {
                    continue;
                }
                
                string label;
                enum byLabel = "/dev/disk/by-label";
                try {
                    foreach(entry; dirEntries(byLabel, SpanMode.shallow))
                    {
                        if (entry.isSymlink) {
                            auto normalized = buildNormalizedPath(byLabel, entry.readLink);
                            if (normalized == fsName) {
                                label = entry.name.baseName.unescapeLabel();
                            }
                        }
                    }
                } catch(Exception e) {
                    
                }
                
                if (!label.length) {
                    label = format("%s volume", type);
                }
                
                auto entryType = (type == "vfat") ? RootEntryType.REMOVABLE : RootEntryType.FIXED; //just a guess
                res ~= RootEntry(entryType, mountDir.idup, label.toUTF32);
            }   
        }
    }
    
    version (Windows) {
        import win32.windows;
        uint mask = GetLogicalDrives();
        foreach(int i; 0 .. 26) {
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
bool isRoot(in string path) pure nothrow {
    string root = rootName(path);
    if (path.equal(root))
        return true;
    return false;
}

/// returns parent directory for specified path
string parentDir(in string path) pure nothrow {
    return buildNormalizedPath(path, "..");
}

/// check filename with pattern
bool filterFilename(in string filename, in string pattern) pure nothrow {
    return globMatch(filename.baseName, pattern);
}
/// Filters file name by pattern list
bool filterFilename(in string filename, in string[] filters) pure nothrow {
    if (filters.length == 0)
        return true; // no filters - show all
    foreach(pattern; filters) {
        if (filterFilename(filename, pattern))
            return true;
    }
    return false;
}

/** List directory content 
    
    Optionally filters file names by filter.

    Result will be placed into entries array.

    Returns true if directory exists and listed successfully, false otherwise.
*/
bool listDirectory(in string dir, in bool includeDirs, in bool includeFiles, in bool showHiddenFiles, in string[] filters, ref DirEntry[] entries, in bool showExecutables = false) {
    entries.length = 0;
    
    import std.exception : collectException;
    bool dirExists;
    collectException(dir.isDir, dirExists);
    if (!dirExists) {
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
        dirs.sort!((a,b) => filenameCmp!(std.path.CaseSensitive.no)(a,b) < 0);
        files.sort!((a,b) => filenameCmp!(std.path.CaseSensitive.no)(a,b) < 0);
        if (includeDirs)
            foreach(DirEntry e; dirs)
                entries ~= e;
        if (includeFiles)
            foreach(DirEntry e; files) {
                bool passed = false;
                if (showExecutables) {
                    uint attr_mask = (1 << 0) | (1 << 3) | (1 << 6);
                    version(Windows) {
                        passed = e.name.endsWith(".exe") || e.name.endsWith(".EXE") 
                            || e.name.endsWith(".cmd") || e.name.endsWith(".CMD") 
                            || e.name.endsWith(".bat") || e.name.endsWith(".BAT");
                    } else version (Posix) {
                        // execute permission for others
                        passed = (e.attributes & attr_mask) != 0;
                    } else version(OSX) {
                        passed = (e.attributes & attr_mask) != 0;
                    }
                } else {
                    passed = filterFilename(e.name, filters);
                }
                if (passed)
                    entries ~= e;
            }
        return true;
    } catch (FileException e) {
        return false;
    }

}

/// Returns true if char ch is / or \ slash
bool isPathDelimiter(in char ch) pure nothrow {
    return ch == '/' || ch == '\\';
}

/// Returns current directory
alias currentDir = std.file.getcwd;

/// Returns current executable path only, including last path delimiter - removes executable name from result of std.file.thisExePath()
@property string exePath() {
    string path = thisExePath();
    int lastSlash = 0;
    for (int i = cast(int)path.length - 1; i >= 0; i--)
        if (path[i] == PATH_DELIMITER) {
            lastSlash = i;
            break;
        }
    return path[0 .. lastSlash + 1];
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

/// Converts path delimiters to standard for platform (e.g. / to \ on windows, \ to / on posix)
string convertPathDelimiters(in string src) {
    char[] buf = src.dup;
    return cast(string)convertPathDelimiters(buf);
}

/// Appends file path parts with proper delimiters e.g. appendPath("/home/user", ".myapp", "config") => "/home/user/.myapp/config"
string appendPath(string[] pathItems ...) {
    char[] buf;
    foreach (s; pathItems) {
        if (buf.length && !isPathDelimiter(buf[$-1]))
            buf ~= PATH_DELIMITER;
        buf ~= s;
    }
    return convertPathDelimiters(buf).dup;
}

///  Appends file path parts with proper delimiters (as well converts delimiters inside path to system) to buffer e.g. appendPath("/home/user", ".myapp", "config") => "/home/user/.myapp/config"
char[] appendPath(char[] buf, string[] pathItems ...) {
    foreach (s; pathItems) {
        if (buf.length && !isPathDelimiter(buf[$-1]))
            buf ~= PATH_DELIMITER;
        buf ~= s;
    }
    return convertPathDelimiters(buf);
}

/** Deprecated: use std.path.pathSplitter instead.
    Splits path into elements, e.g. /home/user/dir1 -> ["home", "user", "dir1"], "c:\dir1\dir2" -> ["c:", "dir1", "dir2"]
*/
deprecated string[] splitPath(string path) {
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

/// for executable name w/o path, find absolute path to executable
string findExecutablePath(string executableName) {
    import std.string : split;
    version (Windows) {
        if (!executableName.endsWith(".exe"))
            executableName = executableName ~ ".exe";
    }
    string currentExeDir = dirName(thisExePath());
    string inCurrentExeDir = absolutePath(buildNormalizedPath(currentExeDir, executableName));
    if (exists(inCurrentExeDir) && isFile(inCurrentExeDir))
        return inCurrentExeDir; // found in current directory
    string pathVariable = environment.get("PATH");
    if (!pathVariable)
        return null;
    string[] paths = pathVariable.split(pathSeparator);
    foreach(path; paths) {
        string pathname = absolutePath(buildNormalizedPath(path, executableName));
        if (exists(pathname) && isFile(pathname))
            return pathname;
    }
    return null;
}
