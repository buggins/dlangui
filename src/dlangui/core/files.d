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
    /// standard user folder: desktop
    DESKTOP,
    /// standard user folder: documents
    DOCUMENTS,
    /// standard user folder: downloads
    DOWNLOADS,
    /// standard user folder: music
    MUSIC,
    /// standard user folder: pictures
    PICTURES,
    /// standard user folder: videos
    VIDEOS,
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
                return "drive-removable-media";
            case DESKTOP:
                return "user-desktop";
            case DOCUMENTS:
                return "folder-documents";
            case DOWNLOADS:
                return "folder-download";
            case MUSIC:
                return "folder-music";
            case PICTURES:
                return "folder-pictures";
            case VIDEOS:
                return "folder-videos";
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

version(OSX) {} else version(Posix)
{
    private bool isSpecialFileSystem(const(char)[] dir, const(char)[] type)
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

    /**
     * Returns true if a mount point should be listed as a place for the user to browse (file dialog places),
     * roughly as GTK file choosers do.
     *
     * Listed: mounts under /media and /run/media, direct children of /mnt (e.g. /mnt/c on WSL), mounts in the
     * home directory, network file systems, and custom top-level mounts (e.g. /data).
     * Skipped: system directories (/usr, /var, /snap, /boot, /run, /opt, ...), system file system types
     * (squashfs, snap fuse, overlay, autofs, ...), and special file systems.
     * Whether the mount point is a directory is checked by the caller.
     */
    package bool isUserMount(const(char)[] dir, const(char)[] type, const(char)[] home)
    {
        import std.algorithm : canFind, startsWith, count;
        if (dir == "/" || isSpecialFileSystem(dir, type))
            return false;
        static immutable string[] systemTypes = [
            "squashfs", "fuse.snapfuse", "overlay", "autofs", "devtmpfs", "devpts", "proc", "sysfs", "securityfs",
            "cgroup", "cgroup2", "pstore", "bpf", "debugfs", "tracefs", "configfs", "fusectl", "mqueue",
            "hugetlbfs", "binfmt_misc", "efivarfs", "nsfs", "ramfs", "selinuxfs", "nullfs", "devfs", "fdescfs",
            "procfs", "linprocfs", "linsysfs", "fuse.gvfsd-fuse", "fuse.portal", "fuse.lxcfs",
        ];
        if (systemTypes.canFind(type))
            return false;
        bool under(const(char)[] prefix) { return dir.startsWith(prefix) && dir.length > prefix.length; }
        // depth: number of path components ("/mnt/c" -> 2)
        size_t depth = dir.count('/') - (dir.length > 1 && dir[$ - 1] == '/' ? 1 : 0);
        if (under("/media/") || under("/run/media/"))
            return true;
        if (under("/mnt/"))
            return depth == 2; // /mnt/c, but not /mnt/wslg/distro
        if (home.length > 1 && home[0] == '/' && under(home[$ - 1] == '/' ? home : home ~ "/"))
            return true;
        static immutable string[] systemDirs = [
            "/bin", "/boot", "/dev", "/etc", "/home", "/lib", "/lib32", "/lib64", "/libx32", "/lost+found",
            "/media", "/mnt", "/opt", "/proc", "/root", "/run", "/sbin", "/snap", "/srv", "/sys", "/tmp",
            "/usr", "/var", "/compat", "/rescue",
        ];
        foreach (sd; systemDirs)
            if (dir == sd || dir.startsWith(sd ~ "/"))
                return false;
        static immutable string[] networkTypes = [
            "nfs", "nfs4", "cifs", "smb3", "smbfs", "davfs", "fuse.sshfs", "fuse.rclone",
        ];
        if (networkTypes.canFind(type))
            return true;
        return depth == 1; // custom top-level mount, e.g. /data
    }

    unittest {
        enum home = "/home/user";
        assert(isUserMount("/media/user/USB", "vfat", home));
        assert(isUserMount("/run/media/user/DISK", "ext4", home));
        assert(isUserMount("/mnt/c", "9p", home));
        assert(isUserMount("/mnt/data", "ext4", home));
        assert(isUserMount("/home/user/remote", "fuse.sshfs", home));
        assert(isUserMount("/data", "ext4", home));
        assert(isUserMount("/shares/projects", "nfs4", home));
        assert(!isUserMount("/", "ext4", home));
        assert(!isUserMount("/home", "ext4", home));
        assert(!isUserMount("/boot/efi", "vfat", home));
        assert(!isUserMount("/snap", "ext4", home));
        assert(!isUserMount("/snap/core20/2922", "squashfs", home));
        assert(!isUserMount("/snap/clion/525", "fuse.snapfuse", home));
        assert(!isUserMount("/var/lib/docker", "ext4", home));
        assert(!isUserMount("/usr/lib/wsl/drivers", "9p", home));
        assert(!isUserMount("/usr/lib/modules/6.6.87.2-microsoft-standard-WSL2", "overlay", home));
        assert(!isUserMount("/mnt/wslg/distro", "ext4", home));
        assert(!isUserMount("/mnt/wslg", "tmpfs", home));
        assert(!isUserMount("/run/user/1000/gvfs", "fuse.gvfsd-fuse", home));
        assert(!isUserMount("/opt/data", "ext4", home));
        assert(!isUserMount("/proc/sys/fs/binfmt_misc", "binfmt_misc", home));
    }

    private string getDeviceLabelFallback(in char[] type, in char[] fsName, in char[] mountDir)
    {
        import std.format : format;
        if (type == "vboxsf") {
            return "VirtualBox shared folder";
        }
        if (type == "fuse.gvfsd-fuse") {
            return "GNOME Virtual file system";
        }
        return format("%s (%s)", mountDir.baseName, type);
    }

    private RootEntryType getDeviceRootEntryType(in char[] type)
    {
        switch(type)
        {
            case "iso9660":
                return RootEntryType.CDROM;
            case "vfat":
                return RootEntryType.REMOVABLE;
            case "cifs":
            case "davfs":
            case "fuse.sshfs":
            case "nfs":
            case "nfs4":
                return RootEntryType.NETWORK;
            default:
                return RootEntryType.FIXED;
         }
    }
}

version(FreeBSD)
{
private:
    import core.sys.posix.sys.types;

    enum MFSNAMELEN = 16;          /* length of type name including null */
    enum MNAMELEN  = 88;          /* size of on/from name bufs */
    enum STATFS_VERSION = 0x20030518;      /* current version number */

    struct fsid_t
    {
        int[2] val;
    }

    struct statfs {
        uint f_version;         /* structure version number */
        uint f_type;            /* type of filesystem */
        ulong f_flags;           /* copy of mount exported flags */
        ulong f_bsize;           /* filesystem fragment size */
        ulong f_iosize;          /* optimal transfer block size */
        ulong f_blocks;          /* total data blocks in filesystem */
        ulong f_bfree;           /* free blocks in filesystem */
        long  f_bavail;          /* free blocks avail to non-superuser */
        ulong f_files;           /* total file nodes in filesystem */
        long  f_ffree;           /* free nodes avail to non-superuser */
        ulong f_syncwrites;      /* count of sync writes since mount */
        ulong f_asyncwrites;         /* count of async writes since mount */
        ulong f_syncreads;       /* count of sync reads since mount */
        ulong f_asyncreads;      /* count of async reads since mount */
        ulong[10] f_spare;       /* unused spare */
        uint f_namemax;         /* maximum filename length */
        uid_t     f_owner;          /* user that mounted the filesystem */
        fsid_t    f_fsid;           /* filesystem id */
        char[80]      f_charspare;      /* spare string space */
        char[MFSNAMELEN] f_fstypename; /* filesystem type name */
        char[MNAMELEN] f_mntfromname;  /* mounted filesystem */
        char[MNAMELEN] f_mntonname;    /* directory on which mounted */
    };

    extern(C) @nogc nothrow
    {
        int getmntinfo(statfs **mntbufp, int flags);
    }
}

version(linux)
{
private:
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
}

/// returns array of system root entries
@property RootEntry[] getRootPaths() {
    RootEntry[] res;
    res ~= RootEntry(RootEntryType.HOME, homePath);
    version (Posix) {
        import dlangui.core.i18n : UIString;
        res ~= RootEntry(RootEntryType.ROOT, "/", UIString.fromId("FILE_SYSTEM", "File System"d).value);
    }
    version(OSX) {} else version(Posix) {
        string home = homePath;
        // mount point exists and is a directory (bind mounts of single files are skipped)
        bool isDirectory(const(char)[] path) {
            import std.exception : collectException;
            bool d;
            return collectException(std.file.isDir(path), d) is null && d;
        }
        // the same mount point mounted twice
        bool seen(const(char)[] path) {
            foreach (ref e; res)
                if (e.path == path)
                    return true;
            return false;
        }
    }
    version(Android) {
        // do nothing
    } else version(linux) {
        import std.string : fromStringz;
        import std.exception : collectException;

        mntent ent;
        char[1024] buf;
        FILE* f = setmntent("/etc/mtab", "r");

        if (f) {
            scope(exit) endmntent(f);
            while(getmntent_r(f, &ent, buf.ptr, cast(int)buf.length) !is null) {
                auto fsName = fromStringz(ent.mnt_fsname);
                auto mountDir = fromStringz(ent.mnt_dir);
                auto type = fromStringz(ent.mnt_type);

                // only places a user would browse; root is already added
                if (!isUserMount(mountDir, type, home) || !isDirectory(mountDir) || seen(mountDir))
                    continue;

                string label;
                enum byLabel = "/dev/disk/by-label";
                if (fsName.isAbsolute) {
                    try {
                        foreach(entry; dirEntries(byLabel, SpanMode.shallow))
                        {
                                string resolvedLink;
                                if (entry.isSymlink && collectException(entry.readLink, resolvedLink) is null) {
                                    auto normalized = buildNormalizedPath(byLabel, resolvedLink);
                                if (normalized == fsName) {
                                    label = entry.name.baseName.unescapeLabel();
                                }
                            }
                        }
                    } catch(Exception e) {

                    }
                }

                if (!label.length) {
                    label = getDeviceLabelFallback(type, fsName, mountDir);
                }
                auto entryType = getDeviceRootEntryType(type);
                res ~= RootEntry(entryType, mountDir.idup, label.toUTF32);
            }
        }
    }

    version(FreeBSD) {
        import std.string : fromStringz;

        statfs* mntbufsPtr;
        int mntbufsLen = getmntinfo(&mntbufsPtr, 0);
        if (mntbufsLen) {
            auto mntbufs = mntbufsPtr[0..mntbufsLen];

            foreach(buf; mntbufs) {
                auto type = fromStringz(buf.f_fstypename.ptr);
                auto fsName = fromStringz(buf.f_mntfromname.ptr);
                auto mountDir = fromStringz(buf.f_mntonname.ptr);

                if (!isUserMount(mountDir, type, home) || !isDirectory(mountDir) || seen(mountDir))
                    continue;

                string label = getDeviceLabelFallback(type, fsName, mountDir);
                res ~= RootEntry(getDeviceRootEntryType(type), mountDir.idup, label.toUTF32);
            }
        }
    }

    version (Windows) {
        import core.sys.windows.windows;
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

version(Windows)
{
private:
    import core.sys.windows.windows;
    import core.sys.windows.shlobj;
    import core.sys.windows.wtypes;
    import core.sys.windows.objbase;
    import core.sys.windows.objidl;

    alias GUID KNOWNFOLDERID;

    extern(Windows) @nogc @system HRESULT _dummy_SHGetKnownFolderPath(const(KNOWNFOLDERID)* rfid, DWORD dwFlags, HANDLE hToken, wchar** ppszPath) nothrow;

    enum KNOWNFOLDERID FOLDERID_Links = {0xbfb9d5e0, 0xc6a9, 0x404c, [0xb2,0xb2,0xae,0x6d,0xb6,0xaf,0x49,0x68]};
}

/// returns array of user bookmarked directories
RootEntry[] getBookmarkPaths() nothrow
{
    RootEntry[] res;
    version(OSX) {

    } else version(Android) {

    } else version(Posix) {
        /*
         * Probably we should follow https://www.freedesktop.org/wiki/Specifications/desktop-bookmark-spec/ but it requires XML library.
         * So for now just try to read GTK3 bookmarks. Should be compatible with GTK file dialogs, Nautilus and other GTK file managers.
         */

        import std.string : startsWith;
        import std.stdio : File;
        import std.exception : collectException;
        import std.uri : decode;
        try {
            enum fileProtocol = "file://";
            auto configPath = environment.get("XDG_CONFIG_HOME");
            if (!configPath.length) {
                configPath = buildPath(homePath(), ".config");
            }
            auto bookmarksFile = buildPath(configPath, "gtk-3.0/bookmarks");
            foreach(line; File(bookmarksFile, "r").byLineCopy()) {
                if (line.startsWith(fileProtocol)) {
                    auto splitted = line.findSplit(" ");
                    string path;
                    if (splitted[1].length) {
                        path = splitted[0][fileProtocol.length..$];
                    } else {
                        path = line[fileProtocol.length..$];
                    }
                    path = decode(path);
                    if (path.isAbsolute) {
                        // Note: GTK supports regular files in bookmarks too, but we allow directories only.
                        bool dirExists;
                        collectException(path.isDir, dirExists);
                        if (dirExists) {
                            dstring label;
                            if (splitted[1].length) {
                                label = splitted[2].toUTF32;
                            } else {
                                label = path.baseName.toUTF32;
                            }
                            res ~= RootEntry(RootEntryType.BOOKMARK, path, label);
                        }
                    }
                }
            }
        } catch(Exception e) {

        }
    } else version(Windows) {
        /*
         * This will not include bookmarks of special items and virtual folders like Recent Files or Recycle bin.
         */

        import core.stdc.wchar_ : wcslen;
        import std.exception : enforce;
        import std.utf : toUTF16z;
        import std.file : dirEntries, SpanMode;
        import std.string : endsWith;

        try {
            auto shell = enforce(LoadLibraryA("Shell32"));
            scope(exit) FreeLibrary(shell);

            auto ptrSHGetKnownFolderPath = cast(typeof(&_dummy_SHGetKnownFolderPath))enforce(GetProcAddress(shell, "SHGetKnownFolderPath"));

            wchar* linksFolderZ;
            const linksGuid = FOLDERID_Links;
            enforce(ptrSHGetKnownFolderPath(&linksGuid, 0, null, &linksFolderZ) == S_OK);
            scope(exit) CoTaskMemFree(linksFolderZ);

            string linksFolder = linksFolderZ[0..wcslen(linksFolderZ)].toUTF8;

            enforce(SUCCEEDED(CoInitialize(null)));
            scope(exit) CoUninitialize();

            HRESULT hres;
            IShellLink psl;

            auto clsidShellLink = CLSID_ShellLink;
            auto iidShellLink = IID_IShellLinkW;
            hres = CoCreateInstance(&clsidShellLink, null, CLSCTX.CLSCTX_INPROC_SERVER, &iidShellLink, cast(LPVOID*)&psl);
            enforce(SUCCEEDED(hres), "Failed to create IShellLink instance");
            scope(exit) psl.Release();

            IPersistFile ppf;
            auto iidPersistFile = IID_IPersistFile;
            hres = psl.QueryInterface(cast(GUID*)&iidPersistFile, cast(void**)&ppf);
            enforce(SUCCEEDED(hres), "Failed to query IPersistFile interface");
            scope(exit) ppf.Release();

            foreach(linkFile; dirEntries(linksFolder, SpanMode.shallow)) {
                if (!linkFile.name.endsWith(".lnk")) {
                    continue;
                }
                try {
                    wchar[MAX_PATH] szGotPath;
                    WIN32_FIND_DATA wfd;

                    hres = ppf.Load(linkFile.name.toUTF16z, STGM_READ);
                    enforce(SUCCEEDED(hres), "Failed to load link file");

                    hres = psl.Resolve(null, SLR_FLAGS.SLR_NO_UI);
                    enforce(SUCCEEDED(hres), "Failed to resolve link");

                    hres = psl.GetPath(szGotPath.ptr, szGotPath.length, &wfd, 0);
                    enforce(SUCCEEDED(hres), "Failed to get path of link target");

                    auto path = szGotPath[0..wcslen(szGotPath.ptr)];

                    if (path.length && path.toUTF8.isDir) {
                        res ~= RootEntry(RootEntryType.BOOKMARK, path.toUTF8, linkFile.name.baseName.stripExtension.toUTF32);
                    }
                } catch(Exception e) {

                }
            }
        } catch(Exception e) {

        }
    }
    return res;
}

/// Standard user folders
enum SpecialFolder {
    Desktop,
    Documents,
    Downloads,
    Music,
    Pictures,
    Videos,
}

version (Windows) {
private:
    // from KnownFolders.h
    enum KNOWNFOLDERID FOLDERID_Desktop   = {0xB4BFCC3A, 0xDB2C, 0x424C, [0xB0,0x29,0x7F,0xE9,0x9A,0x87,0xC6,0x41]};
    enum KNOWNFOLDERID FOLDERID_Documents = {0xFDD39AD0, 0x238F, 0x46AF, [0xAD,0xB4,0x6C,0x85,0x48,0x03,0x69,0xC7]};
    enum KNOWNFOLDERID FOLDERID_Downloads = {0x374DE290, 0x123F, 0x4565, [0x91,0x64,0x39,0xC4,0x92,0x5E,0x46,0x7B]};
    enum KNOWNFOLDERID FOLDERID_Music     = {0x4BD8D571, 0x6D19, 0x48D3, [0xBE,0x97,0x42,0x22,0x20,0x08,0x0E,0x43]};
    enum KNOWNFOLDERID FOLDERID_Pictures  = {0x33E28130, 0x4E1E, 0x4676, [0x83,0x5A,0x98,0x39,0x5C,0x3B,0xC3,0xBB]};
    enum KNOWNFOLDERID FOLDERID_Videos    = {0x18989B1D, 0x99B5, 0x455B, [0x84,0x1C,0xAB,0x7C,0x74,0xE4,0xDD,0xFC]};

    /// path of a Windows known folder, or null
    string knownFolderPath(const KNOWNFOLDERID id) nothrow {
        import core.stdc.wchar_ : wcslen;
        try {
            auto shell = LoadLibraryA("Shell32");
            if (!shell)
                return null;
            scope(exit) FreeLibrary(shell);
            auto ptrSHGetKnownFolderPath = cast(typeof(&_dummy_SHGetKnownFolderPath))GetProcAddress(shell, "SHGetKnownFolderPath");
            if (!ptrSHGetKnownFolderPath)
                return null;
            wchar* pathZ;
            KNOWNFOLDERID guid = id;
            if (ptrSHGetKnownFolderPath(&guid, 0, null, &pathZ) != S_OK)
                return null;
            scope(exit) CoTaskMemFree(pathZ);
            return pathZ[0 .. wcslen(pathZ)].toUTF8;
        } catch (Exception e) {
            return null;
        }
    }
}

/**
 * Parses the content of an XDG user-dirs.dirs file (lines like `XDG_DOCUMENTS_DIR="$HOME/Documents"`).
 *
 * Returns: map from key without prefix and suffix (e.g. "DOCUMENTS") to absolute path;
 * folders set to the home directory (meaning "disabled") are not included.
 */
string[string] parseXdgUserDirs(string content, string home) {
    import std.string : lineSplitter, strip, startsWith, endsWith;
    string[string] res;
    while (home.length > 1 && home[$ - 1] == '/')
        home = home[0 .. $ - 1];
    foreach (rawLine; content.lineSplitter) {
        string line = rawLine.strip;
        if (!line.length || line[0] == '#')
            continue;
        auto eq = line.findSplit("=");
        string key = eq[0].strip;
        string value = eq[2].strip;
        if (!eq[1].length || !key.startsWith("XDG_") || !key.endsWith("_DIR") || value.length < 2 || value[0] != '"')
            continue;
        // quoted value, backslash escapes
        string v;
        bool closed = false;
        for (size_t i = 1; i < value.length; i++) {
            char ch = value[i];
            if (ch == '\\' && i + 1 < value.length) {
                v ~= value[++i];
            } else if (ch == '"') {
                closed = true;
                break;
            } else {
                v ~= ch;
            }
        }
        if (!closed)
            continue;
        string path;
        if (v.startsWith("$HOME")) {
            string rest = v[5 .. $];
            if (rest.length && rest[0] != '/')
                continue; // e.g. "$HOMEX"
            while (rest.length && rest[$ - 1] == '/')
                rest = rest[0 .. $ - 1];
            if (!rest.length)
                continue; // the home directory itself: disabled
            path = home ~ rest;
        } else if (v.startsWith("/")) {
            path = v;
            while (path.length > 1 && path[$ - 1] == '/')
                path = path[0 .. $ - 1];
            if (path == home)
                continue;
        } else {
            continue;
        }
        res[key[4 .. $ - 4]] = path;
    }
    return res;
}

unittest {
    string content = `# This file is written by xdg-user-dirs-update
XDG_DESKTOP_DIR="$HOME/Desktop"
XDG_DOWNLOAD_DIR="$HOME/Загрузки"
XDG_TEMPLATES_DIR="$HOME/"
XDG_PUBLICSHARE_DIR="$HOME"
XDG_DOCUMENTS_DIR="/data/docs/"
XDG_MUSIC_DIR = "$HOME/My \"Music\""
XDG_PICTURES_DIR=$HOME/Pictures
XDG_VIDEOS_DIR="/home/user"
NOT_XDG="$HOME/x"
`;
    auto dirs = parseXdgUserDirs(content, "/home/user/");
    assert(dirs["DESKTOP"] == "/home/user/Desktop");
    assert(dirs["DOWNLOAD"] == "/home/user/Загрузки");
    assert(dirs["DOCUMENTS"] == "/data/docs");
    assert(dirs["MUSIC"] == `/home/user/My "Music"`);
    assert("TEMPLATES" !in dirs); // home: disabled
    assert("PUBLICSHARE" !in dirs);
    assert("PICTURES" !in dirs); // not quoted
    assert("VIDEOS" !in dirs); // home: disabled
    assert(dirs.length == 4);
}

/// Returns the path of a standard user folder, or null if it isn't defined or doesn't exist
string getSpecialFolderPath(SpecialFolder folder) {
    string path;
    version (Windows) {
        final switch (folder) {
            case SpecialFolder.Desktop: path = knownFolderPath(FOLDERID_Desktop); break;
            case SpecialFolder.Documents: path = knownFolderPath(FOLDERID_Documents); break;
            case SpecialFolder.Downloads: path = knownFolderPath(FOLDERID_Downloads); break;
            case SpecialFolder.Music: path = knownFolderPath(FOLDERID_Music); break;
            case SpecialFolder.Pictures: path = knownFolderPath(FOLDERID_Pictures); break;
            case SpecialFolder.Videos: path = knownFolderPath(FOLDERID_Videos); break;
        }
    } else version (OSX) {
        // always these folders in the home directory (Finder only localizes their display names)
        static immutable string[] names = ["Desktop", "Documents", "Downloads", "Music", "Pictures", "Movies"];
        path = buildPath(homePath, names[folder]);
    } else version (Android) {
        // not supported
    } else version (Posix) {
        // XDG user directories
        static immutable string[] keys = ["DESKTOP", "DOCUMENTS", "DOWNLOAD", "MUSIC", "PICTURES", "VIDEOS"];
        static immutable string[] defaults = ["Desktop", "Documents", "Downloads", "Music", "Pictures", "Videos"];
        string home = homePath;
        string configHome = environment.get("XDG_CONFIG_HOME");
        if (!configHome.length)
            configHome = buildPath(home, ".config");
        string dirsFile = buildPath(configHome, "user-dirs.dirs");
        string content;
        try {
            if (exists(dirsFile))
                content = readText(dirsFile);
        } catch (Exception e) {
            Log.w("Cannot read ", dirsFile, ": ", e.msg);
        }
        if (content.length) {
            auto dirs = parseXdgUserDirs(content, home);
            if (auto p = keys[folder] in dirs)
                path = *p;
        } else {
            path = buildPath(home, defaults[folder]); // no user-dirs.dirs: common default names
        }
    }
    if (!path.length)
        return null;
    try {
        if (!exists(path) || !isDir(path))
            return null;
    } catch (Exception e) {
        return null;
    }
    return path;
}

/// Returns entries for the standard user folders which exist, in the given order, without duplicates
RootEntry[] getSpecialFolderPaths(const SpecialFolder[] folders = [SpecialFolder.Desktop, SpecialFolder.Documents,
        SpecialFolder.Downloads, SpecialFolder.Music, SpecialFolder.Pictures, SpecialFolder.Videos]) {
    import dlangui.core.i18n : UIString;
    static immutable string[] labelIds = ["FOLDER_DESKTOP", "FOLDER_DOCUMENTS", "FOLDER_DOWNLOADS", "FOLDER_MUSIC", "FOLDER_PICTURES", "FOLDER_VIDEOS"];
    static immutable dstring[] fallbacks = ["Desktop"d, "Documents"d, "Downloads"d, "Music"d, "Pictures"d, "Videos"d];
    static immutable RootEntryType[] types = [RootEntryType.DESKTOP, RootEntryType.DOCUMENTS, RootEntryType.DOWNLOADS,
        RootEntryType.MUSIC, RootEntryType.PICTURES, RootEntryType.VIDEOS];
    RootEntry[] res;
    string home = homePath;
    foreach (folder; folders) {
        string path = getSpecialFolderPath(folder);
        if (!path.length || path == home)
            continue;
        bool dup = false;
        foreach (ref e; res)
            if (e.path == path)
                dup = true;
        if (dup)
            continue;
        res ~= RootEntry(types[folder], path, UIString.fromId(labelIds[folder], fallbacks[folder]).value);
    }
    return res;
}

/// returns true if directory is root directory (e.g. / or C:\\)
bool isRoot(in string path) pure nothrow {
    string root = rootName(path);
    if (path.equal(root))
        return true;
    return false;
}

/**
 * Check if path is hidden.
 */
bool isHidden(in string path) nothrow {
    version(Windows) {
        import core.sys.windows.winnt : FILE_ATTRIBUTE_HIDDEN;
        import std.exception : collectException;
        uint attrs;
        if (collectException(path.getAttributes(), attrs) is null) {
            return (attrs & FILE_ATTRIBUTE_HIDDEN) != 0;
        } else {
            return false;
        }
    } else version(Posix) {
        //TODO: check for hidden attribute on macOS
        return path.baseName.startsWith(".");
    } else {
        return false;
    }
}

///
unittest
{
    version(Posix) {
        assert(!"path/to/normal_file".isHidden());
        assert("path/to/.hidden_file".isHidden());
    }
}

private bool isReadable(in string filePath) nothrow
{
    version(Posix) {
        import core.sys.posix.unistd : access, R_OK;
        import std.string : toStringz;
        return access(toStringz(filePath), R_OK) == 0;
    } else {
        // TODO: Windows version
        return true;
    }
}

private bool isWritable(in string filePath) nothrow
{
    version(Posix) {
        import core.sys.posix.unistd : access, W_OK;
        import std.string : toStringz;
        return access(toStringz(filePath), W_OK) == 0;
    } else {
        // TODO: Windows version
        return true;
    }
}

private bool isExecutable(in string filePath) nothrow
{
    version(Windows) {
        //TODO: Use GetEffectiveRightsFromAclW? For now just check extension
        string extension = filePath.extension;
        foreach(ext; [".exe", ".com", ".bat", ".cmd"]) {
            if (filenameCmp(extension, ext) == 0)
                return true;
        }
        return false;
    } else version(Posix) {
        import core.sys.posix.unistd : access, X_OK;
        import std.string : toStringz;
        return access(toStringz(filePath), X_OK) == 0;
    } else {
        return false;
    }
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

enum AttrFilter
{
    none = 0,
    files      = 1 << 0, /// Include regular files that match the filters.
    dirs       = 1 << 1, /// Include directories.
    hidden     = 1 << 2, /// Include hidden files and directoroies.
    parent     = 1 << 3, /// Include parent directory (..). Takes effect only with includeDirs.
    thisDir    = 1 << 4, /// Include this directory (.). Takes effect only with  includeDirs.
    special    = 1 << 5, /// Include special files (On Unix: socket and device files, FIFO) that match the filters.
    readable   = 1 << 6, /// Listing only readable files and directories.
    writable   = 1 << 7, /// Listing only writable files and directories.
    executable = 1 << 8, /// Include only executable files. This filter does not affect directories.
    allVisible = AttrFilter.files | AttrFilter.dirs, /// Include all non-hidden files and directories without parent directory, this directory and special files.
    all        = AttrFilter.allVisible | AttrFilter.hidden /// Include all files and directories including hidden ones but without parent directory, this directory and special files.
}

/** List directory content

    Optionally filters file names by filter (not applied to directories).

    Returns true if directory exists and listed successfully, false otherwise.
    Throws: Exception if $(D dir) is not directory or some error occured during directory listing.
 */
DirEntry[] listDirectory(in string dir, AttrFilter attrFilter = AttrFilter.all, in string[] filters = [])
{
    DirEntry[] entries;

    DirEntry[] dirs;
    DirEntry[] files;
    foreach (DirEntry e; dirEntries(dir, SpanMode.shallow)) {
        if (!(attrFilter & AttrFilter.hidden) && e.name.isHidden())
            continue;
        if ((attrFilter & AttrFilter.readable) && !e.name.isReadable())
            continue;
        if ((attrFilter & AttrFilter.writable) && !e.name.isWritable())
            continue;
        if (!e.isDir && (attrFilter & AttrFilter.executable) && !e.name.isExecutable())
            continue;
        if (e.isDir && (attrFilter & AttrFilter.dirs)) {
            dirs ~= e;
        } else if ((attrFilter & AttrFilter.files) && filterFilename(e.name, filters)) {
            if (e.isFile) {
                files ~= e;
            } else if (attrFilter & AttrFilter.special) {
                files ~= e;
            }
        }
    }
    if ((attrFilter & AttrFilter.dirs) && (attrFilter & AttrFilter.thisDir) ) {
        entries ~= DirEntry(appendPath(dir, ".")) ~ entries;
    }
    if (!isRoot(dir) && (attrFilter & AttrFilter.dirs) && (attrFilter & AttrFilter.parent)) {
        entries ~= DirEntry(appendPath(dir, ".."));
    }
    dirs.sort!((a,b) => filenameCmp!(std.path.CaseSensitive.no)(a.name,b.name) < 0);
    files.sort!((a,b) => filenameCmp!(std.path.CaseSensitive.no)(a.name,b.name) < 0);
    entries ~= dirs;
    entries ~= files;
    return entries;
}

/** List directory content

    Optionally filters file names by filter (not applied to directories).

    Result will be placed into entries array.

    Returns true if directory exists and listed successfully, false otherwise.
*/
deprecated bool listDirectory(in string dir, in bool includeDirs, in bool includeFiles, in bool showHiddenFiles, in string[] filters, ref DirEntry[] entries, in bool showExecutables = false) {
    entries.length = 0;

    AttrFilter attrFilter;
    if (includeDirs) {
        attrFilter |= AttrFilter.dirs;
        attrFilter |= AttrFilter.parent;
    }
    if (includeFiles)
        attrFilter |= AttrFilter.files;
    if (showHiddenFiles)
        attrFilter |= AttrFilter.hidden;
    if (showExecutables)
        attrFilter |= AttrFilter.executable;

    import std.exception : collectException;
    return collectException(listDirectory(dir, attrFilter, filters), entries) is null;
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

/// Returns current executable path and file name
@property string exeFilename() {
    return thisExePath();
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

/// if pathName is not absolute path, convert it to absolute (assuming it is relative to current directory)
string toAbsolutePath(string pathName) {
    import std.path : isAbsolute, absolutePath, buildNormalizedPath;
    if (pathName.isAbsolute)
        return pathName;
    return pathName.absolutePath.buildNormalizedPath;
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

/**
Parse `text/uri-list` (RFC 2483) data, as used by drag and drop (e.g. XDND on X11).

Returns: local file paths of `file:` URIs, percent-decoded.
Empty lines, comments (lines starting with `#`) and URIs with other schemes are skipped.
Accepted forms: `file:///path`, `file://localhost/path`, `file://host/path` (host is ignored), `file:/path`.
*/
string[] parseFileUriList(const(char)[] uriList) {
    import std.algorithm : startsWith;
    import std.string : lineSplitter, strip, indexOf;
    import std.uni : toLower;
    string[] res;
    foreach (line; uriList.lineSplitter) {
        auto uri = line.strip;
        if (uri.length == 0 || uri[0] == '#')
            continue;
        if (uri.length < 5 || uri[0 .. 5].toLower != "file:")
            continue;
        auto rest = uri[5 .. $];
        if (rest.startsWith("//")) {
            // authority (host) part: up to the next '/'
            auto slash = rest[2 .. $].indexOf('/');
            if (slash < 0)
                continue;
            rest = rest[2 + slash .. $];
        }
        if (!rest.startsWith("/"))
            continue;
        string path = percentDecode(rest);
        if (path.length)
            res ~= path;
    }
    return res;
}

/// decode %XX escapes; invalid escapes are kept as is
private string percentDecode(const(char)[] s) {
    static int hexValue(char c) {
        if (c >= '0' && c <= '9') return c - '0';
        if (c >= 'a' && c <= 'f') return c - 'a' + 10;
        if (c >= 'A' && c <= 'F') return c - 'A' + 10;
        return -1;
    }
    char[] res;
    res.reserve(s.length);
    for (size_t i = 0; i < s.length; i++) {
        if (s[i] == '%' && i + 2 < s.length) {
            int hi = hexValue(s[i + 1]);
            int lo = hexValue(s[i + 2]);
            if (hi >= 0 && lo >= 0) {
                res ~= cast(char)(hi * 16 + lo);
                i += 2;
                continue;
            }
        }
        res ~= s[i];
    }
    return cast(string)res;
}

///
unittest {
    assert(parseFileUriList("") == []);
    assert(parseFileUriList("file:///home/user/a.txt") == ["/home/user/a.txt"]);
    // CRLF separated list, as required by RFC 2483, with percent-encoded characters
    assert(parseFileUriList("file:///tmp/a%20b.txt\r\nfile:///tmp/%D0%BF%D1%80%D0%B8%D0%B2%D0%B5%D1%82.txt\r\n")
           == ["/tmp/a b.txt", "/tmp/привет.txt"]);
    // LF only, comments, empty lines, other schemes
    assert(parseFileUriList("# comment\n\nhttp://example.com/x\nfile:///x/y\n  \nsmb://server/share\n") == ["/x/y"]);
    // host forms
    assert(parseFileUriList("file://localhost/etc/hosts") == ["/etc/hosts"]);
    assert(parseFileUriList("file://myhost/data/f") == ["/data/f"]);
    assert(parseFileUriList("FILE:///upper/case") == ["/upper/case"]);
    assert(parseFileUriList("file:/single/slash") == ["/single/slash"]);
    // malformed
    assert(parseFileUriList("file://hostonly") == []);
    assert(parseFileUriList("file:relative/path") == []);
    // invalid escapes are kept
    assert(parseFileUriList("file:///a%zzb%2") == ["/a%zzb%2"]);
    assert(parseFileUriList("file:///100%25") == ["/100%"]);
}
