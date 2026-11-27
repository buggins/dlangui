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
    }

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
    }

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

/**
Writes `data` as the whole content of file `path` (created if missing) without leaving a truncated or half-written
file when writing fails (#1277).

The data goes to a new temporary file in the same directory first (created exclusively, never through an existing
file or link), is flushed to the disk, and then replaces the file in one step: POSIX `rename()`; on Windows
`ReplaceFileW`, which keeps the original's attributes, ACL and creation time (or `MoveFileExW` for a new file). On
POSIX the temporary file is readable by its owner only until it gets the original's group and permission bits,
before the data is written. If anything fails before the replace, the temporary file is deleted and the original is
untouched; that includes a full disk.

The file is written in place instead, as a plain overwrite, when replacing it would change what it is:
- `atomic` is false;
- it isn't a regular file: a symbolic link (written through the link), another reparse point (Windows), a device
  or a FIFO;
- it has more than one hard link (a rename would split it from its other names);
- it belongs to another user, or (POSIX) its group can't be given to the new file;
- creating files in its directory isn't allowed (permissions, a read-only file system, a too long name);
- Windows refuses to replace it (another program has it open without allowing that).

`sync` also flushes an in-place write to the disk, and on POSIX the directory after a replace, so that the new name
survives a crash right after the save.

`written` gets the state of the written file, read from its open handle after the data was flushed.

The data is kept in memory by the caller, so the whole file is encoded before it is written.

Returns false (and logs why) if the file couldn't be written; with an in-place write the file may then be truncated,
as with any plain overwrite.
*/
bool writeFileSafely(string path, const(ubyte)[] data, out FileState written, bool atomic = true, bool sync = false) {
    import dlangui.core.filewatch : normalizedFilePath;
    string target = normalizedFilePath(path);
    try {
        bool existing;
        if (!atomic || !canReplaceByRename(target, existing))
            return writeInPlace(target, data, sync, written);
        std.stdio.File f;
        string tmp;
        final switch (createTempFile(target, existing, f, tmp)) {
            case CreateStatus.created:
                break;
            case CreateStatus.notAllowed:
                return writeInPlace(target, data, sync, written);
            case CreateStatus.exists:
            case CreateStatus.failed:
                return false; // e.g. a full disk: the original is untouched
        }
        try {
            if (existing && !takeOverAttributes(f, target)) {
                f.close();
                removeQuietly(tmp);
                Log.w("writeFileSafely: cannot give the group of ", target, " to a new file, writing it in place");
                return writeInPlace(target, data, sync, written);
            }
            // flushed to the disk before the replace, or a crash soon after it can leave an empty file
            writeAndClose(f, tmp, data, true, written, target);
        } catch (Exception e) {
            if (f.isOpen)
                f.close();
            removeQuietly(tmp);
            Log.e("writeFileSafely: cannot write ", tmp, ": ", e.msg);
            return false; // the original is untouched
        }
        final switch (replaceByTemp(target, tmp)) {
            case ReplaceResult.replaced:
                if (sync)
                    syncDirectoryOf(target);
                return true;
            case ReplaceResult.failed:
                removeQuietly(tmp);
                return false;
            case ReplaceResult.writeInPlace:
                removeQuietly(tmp);
                return writeInPlace(target, data, sync, written);
            case ReplaceResult.tempKept:
                return false; // the data is in the temporary file, named in the log
        }
    } catch (Exception e) {
        Log.e("writeFileSafely: cannot write ", target, ": ", e.msg);
        return false;
    }
}

import dlangui.core.filewatch : FileState;
static import std.stdio;

version (unittest) {
    // called after the data was written to the temporary file (its name) and before it is closed; may throw
    package __gshared void delegate(string tmp) safeWriteTestHook;
}

private enum ReplaceResult { replaced, failed, writeInPlace, tempKept }
private enum CreateStatus { created, exists, notAllowed, failed }

// a temporary file name next to target: name.ext.~dlangui-<random>.tmp
private string safeWriteTempName(string target) {
    import std.format : format;
    import std.random : uniform;
    return format("%s.~dlangui-%08x%08x.tmp", target, uniform!uint, uniform!uint);
}

// creates a new temporary file next to target, retrying when the name exists; logs failures
private CreateStatus createTempFile(string target, bool ownerOnly, out std.stdio.File file, out string name) {
    foreach (attempt; 0 .. 16) {
        name = safeWriteTempName(target);
        int error;
        CreateStatus status = createNewFile(name, ownerOnly, file, error);
        final switch (status) {
            case CreateStatus.created:
                return status;
            case CreateStatus.exists:
                continue;
            case CreateStatus.notAllowed:
                Log.w("writeFileSafely: cannot create a temporary file for ", target, " (error ", error,
                        "), writing it in place");
                return status;
            case CreateStatus.failed:
                Log.e("writeFileSafely: cannot create a temporary file for ", target, ", error ", error);
                return status;
        }
    }
    Log.e("writeFileSafely: no free temporary file name for ", target);
    return CreateStatus.failed;
}

// writes data, flushes (and syncs), reads the state of the written file from the handle (path: the name it gets)
private void writeAndClose(ref std.stdio.File f, string fileName, const(ubyte)[] data, bool sync,
        out FileState written, string path) {
    scope (exit)
        f.close();
    f.rawWrite(data);
    version (unittest) {
        if (safeWriteTestHook)
            safeWriteTestHook(fileName);
    }
    f.flush();
    if (sync)
        f.sync();
    written = FileState.read(f, path);
}

private bool writeInPlace(string target, const(ubyte)[] data, bool sync, out FileState written) {
    try {
        std.stdio.File f = openInPlace(target);
        writeAndClose(f, target, data, sync, written, target);
        return true;
    } catch (Exception e) {
        Log.e("writeFileSafely: cannot write ", target, ": ", e.msg);
        return false;
    }
}

version (Posix) {
    import core.sys.posix.sys.stat : stat_t, lstat, stat, fstat, fchmod, S_IFMT, S_IFREG;
    import core.sys.posix.unistd : access, geteuid, fchown, close, unlink, fsync, W_OK;
    import core.sys.posix.sys.types : uid_t;
    import core.sys.posix.fcntl : open, O_WRONLY, O_RDONLY, O_CREAT, O_EXCL;
    import core.stdc.errno : errno, ENOENT, EEXIST, EACCES, EPERM, EROFS, ENAMETOOLONG;
    import std.string : toStringz;
    private import std.conv : octal;

    // replacing target by a rename keeps what it is: no file yet, or a regular file of the current user without
    // other hard links, in a directory where files can be created
    // @trusted: lstat/access get zero-terminated copies and a local buffer
    private bool canReplaceByRename(string target, out bool existing) @trusted {
        stat_t st;
        if (lstat(toStringz(target), &st) != 0)
            return errno == ENOENT; // a new file; another error: the plain write reports it
        existing = true;
        if ((st.st_mode & S_IFMT) != S_IFREG || st.st_nlink > 1 || st.st_uid != geteuid())
            return false;
        return access(toStringz(dirName(target)), W_OK) == 0;
    }

    // errors creating a file where writing the existing file may still work; not a full disk or quota
    private bool createErrorAllowsInPlace(int error) @safe pure nothrow @nogc {
        return error == EACCES || error == EPERM || error == EROFS || error == ENAMETOOLONG;
    }

    // a new file, never an existing file or link (O_EXCL); ownerOnly: mode 0600 until takeOverAttributes, else the
    // default mode of new files (umask)
    // @trusted: open/close/unlink get a zero-terminated copy; the descriptor belongs to `file` after fdopen
    private CreateStatus createNewFile(string name, bool ownerOnly, out std.stdio.File file, out int error) @trusted {
        int fd = open(toStringz(name), O_WRONLY | O_CREAT | O_EXCL, ownerOnly ? octal!600 : octal!666);
        if (fd < 0) {
            error = errno;
            if (error == EEXIST)
                return CreateStatus.exists;
            return createErrorAllowsInPlace(error) ? CreateStatus.notAllowed : CreateStatus.failed;
        }
        try {
            file.fdopen(fd, "wb");
        } catch (Exception e) {
            close(fd);
            unlink(toStringz(name));
            return CreateStatus.failed;
        }
        return CreateStatus.created;
    }

    // gives the new file the group and permission bits of target; false if the group can't be given
    // @trusted: stat/fstat/fchown/fchmod on a local buffer and the open descriptor of `tmp`
    private bool takeOverAttributes(ref std.stdio.File tmp, string target) @trusted {
        stat_t st, own;
        if (stat(toStringz(target), &st) != 0)
            return true; // gone meanwhile: the replace creates it anew
        int fd = tmp.fileno;
        if (fstat(fd, &own) == 0 && own.st_gid != st.st_gid && fchown(fd, cast(uid_t)-1, st.st_gid) != 0)
            return false;
        fchmod(fd, st.st_mode & octal!7777); // after fchown, which may clear set-id bits
        return true;
    }

    private std.stdio.File openInPlace(string target) {
        return std.stdio.File(target, "wb");
    }

    private void removeQuietly(string fn) {
        try {
            if (exists(fn))
                remove(fn);
        } catch (Exception e) {
            Log.w("cannot delete ", fn, ": ", e.msg);
        }
    }

    private ReplaceResult replaceByTemp(string target, string tmp) {
        try {
            rename(tmp, target);
            return ReplaceResult.replaced;
        } catch (Exception e) {
            Log.e("writeFileSafely: cannot replace ", target, ": ", e.msg);
            return ReplaceResult.failed;
        }
    }

    // @trusted: open/fsync/close of a descriptor that doesn't leave the function
    private void syncDirectoryOf(string target) @trusted {
        int fd = open(toStringz(dirName(target)), O_RDONLY);
        if (fd >= 0) {
            fsync(fd);
            close(fd);
        }
    }
} else version (Windows) {
    import core.sys.windows.windows;
    import dlangui.core.filewatch : longPathName;

    private const(wchar)* winName(string name) {
        return toUTF16z(longPathName(name));
    }

    // replacing target keeps what it is: no file yet, or a plain file (no reparse point, directory or device)
    // without other hard links
    // @trusted: Win32 calls with zero-terminated copies and a local buffer; the handle doesn't leave the function
    private bool canReplaceByRename(string target, out bool existing) @trusted {
        DWORD attrs = GetFileAttributesW(winName(target));
        if (attrs == INVALID_FILE_ATTRIBUTES) {
            DWORD err = GetLastError();
            return err == ERROR_FILE_NOT_FOUND; // a new file; another error: the plain write reports it
        }
        existing = true;
        if (attrs & (FILE_ATTRIBUTE_REPARSE_POINT | FILE_ATTRIBUTE_DIRECTORY | FILE_ATTRIBUTE_DEVICE))
            return false;
        HANDLE h = CreateFileW(winName(target), FILE_READ_ATTRIBUTES,
                FILE_SHARE_READ | FILE_SHARE_WRITE | FILE_SHARE_DELETE, null, OPEN_EXISTING, FILE_FLAG_BACKUP_SEMANTICS, null);
        if (h == INVALID_HANDLE_VALUE)
            return true;
        scope (exit)
            CloseHandle(h);
        BY_HANDLE_FILE_INFORMATION info;
        return !GetFileInformationByHandle(h, &info) || info.nNumberOfLinks <= 1;
    }

    // errors creating a file where writing the existing file may still work; not a full disk or quota
    private bool createErrorAllowsInPlace(int error) @safe pure nothrow @nogc {
        return error == ERROR_ACCESS_DENIED || error == ERROR_WRITE_PROTECT || error == ERROR_FILENAME_EXCED_RANGE
            || error == ERROR_INVALID_NAME;
    }

    // a new file, never an existing file or link (CREATE_NEW); its ACL comes from the directory
    // @trusted: CreateFileW with a zero-terminated copy; the handle belongs to `file` after windowsHandleOpen
    private CreateStatus createNewFile(string name, bool ownerOnly, out std.stdio.File file, out int error) @trusted {
        HANDLE h = CreateFileW(winName(name), GENERIC_WRITE, FILE_SHARE_READ, null, CREATE_NEW, FILE_ATTRIBUTE_NORMAL,
                null);
        if (h == INVALID_HANDLE_VALUE) {
            error = cast(int)GetLastError();
            if (error == ERROR_FILE_EXISTS || error == ERROR_ALREADY_EXISTS)
                return CreateStatus.exists;
            return createErrorAllowsInPlace(error) ? CreateStatus.notAllowed : CreateStatus.failed;
        }
        try {
            file.windowsHandleOpen(h, "wb");
        } catch (Exception e) {
            CloseHandle(h);
            DeleteFileW(winName(name));
            return CreateStatus.failed;
        }
        return CreateStatus.created;
    }

    private bool takeOverAttributes(ref std.stdio.File tmp, string target) {
        return true; // ReplaceFileW gives the new file the original's attributes and ACL
    }

    // opens target for writing from its start, emptied; works for hidden files and files other programs have open
    // with write sharing, and for long paths
    // @trusted: Win32 calls with zero-terminated copies; the handle belongs to the File after windowsHandleOpen
    private std.stdio.File openInPlace(string target) @trusted {
        import std.exception : ErrnoException;
        HANDLE h = CreateFileW(winName(target), GENERIC_WRITE, FILE_SHARE_READ | FILE_SHARE_WRITE, null, OPEN_ALWAYS,
                FILE_ATTRIBUTE_NORMAL, null);
        if (h == INVALID_HANDLE_VALUE)
            throw new Exception("cannot open " ~ target ~ " for writing, error " ~ errorCode(GetLastError()));
        if (!SetEndOfFile(h)) {
            DWORD err = GetLastError();
            CloseHandle(h);
            throw new Exception("cannot empty " ~ target ~ ", error " ~ errorCode(err));
        }
        std.stdio.File f;
        try {
            f.windowsHandleOpen(h, "wb");
        } catch (Exception e) {
            CloseHandle(h);
            throw e;
        }
        return f;
    }

    private string errorCode(DWORD err) @safe pure {
        import std.conv : to;
        return to!string(err);
    }

    // @trusted: DeleteFileW with a zero-terminated copy
    private void removeQuietly(string fn) @trusted {
        if (!DeleteFileW(winName(fn)) && GetLastError() != ERROR_FILE_NOT_FOUND)
            Log.w("cannot delete ", fn, ", error ", GetLastError());
    }

    // @trusted: ReplaceFileW with zero-terminated copies; returns 0 or the error
    private DWORD replaceFile(string target, string tmp) @trusted {
        return ReplaceFileW(winName(target), winName(tmp), null, REPLACEFILE_IGNORE_MERGE_ERRORS, null, null)
            ? 0 : GetLastError();
    }

    // @trusted: MoveFileExW with zero-terminated copies; returns 0 or the error
    private DWORD moveFile(string from, string to, bool replaceExisting) @trusted {
        DWORD flags = MOVEFILE_WRITE_THROUGH | (replaceExisting ? MOVEFILE_REPLACE_EXISTING : 0);
        return MoveFileExW(winName(from), winName(to), flags) ? 0 : GetLastError();
    }

    private ReplaceResult replaceByTemp(string target, string tmp) {
        DWORD err = replaceFile(target, tmp);
        if (err == 0)
            return ReplaceResult.replaced;
        switch (err) {
            case ERROR_FILE_NOT_FOUND:
                // no original: a new file, or deleted meanwhile
                err = moveFile(tmp, target, true);
                if (err == 0)
                    return ReplaceResult.replaced;
                break;
            case ERROR_UNABLE_TO_MOVE_REPLACEMENT:
            case ERROR_UNABLE_TO_MOVE_REPLACEMENT_2:
                // the original is deleted (or, _2, renamed); the data is still in the temporary file under its name
                DWORD moveErr = moveFile(tmp, target, false);
                if (moveErr == 0)
                    return ReplaceResult.replaced;
                Log.e("writeFileSafely: cannot replace ", target, " (error ", err, ", then ", moveErr,
                        "), the saved data is in ", tmp);
                return ReplaceResult.tempKept;
            case ERROR_SHARING_VIOLATION:
            case ERROR_ACCESS_DENIED:
            case ERROR_USER_MAPPED_FILE:
                // open in another program that doesn't allow replacing it: it may still allow writing it
                Log.w("writeFileSafely: cannot replace ", target, " (error ", err, "), writing it in place");
                return ReplaceResult.writeInPlace;
            default:
                break;
        }
        Log.e("writeFileSafely: cannot replace ", target, ", error ", err);
        return ReplaceResult.failed;
    }

    private void syncDirectoryOf(string target) {
        // NTFS commits the rename with its metadata; there is no directory handle to flush
    }
} else {
    private bool canReplaceByRename(string target, out bool existing) {
        existing = exists(target);
        return !existing || isFile(target);
    }

    private bool createErrorAllowsInPlace(int error) {
        return true;
    }

    private CreateStatus createNewFile(string name, bool ownerOnly, out std.stdio.File file, out int error) {
        if (exists(name))
            return CreateStatus.exists;
        try {
            file = std.stdio.File(name, "wb");
            return CreateStatus.created;
        } catch (Exception e) {
            return CreateStatus.notAllowed;
        }
    }

    private bool takeOverAttributes(ref std.stdio.File tmp, string target) {
        return true;
    }

    private std.stdio.File openInPlace(string target) {
        return std.stdio.File(target, "wb");
    }

    private void removeQuietly(string fn) {
        try {
            if (exists(fn))
                remove(fn);
        } catch (Exception e) {
            Log.w("cannot delete ", fn, ": ", e.msg);
        }
    }

    private ReplaceResult replaceByTemp(string target, string tmp) {
        try {
            rename(tmp, target);
            return ReplaceResult.replaced;
        } catch (Exception e) {
            Log.e("writeFileSafely: cannot replace ", target, ": ", e.msg);
            return ReplaceResult.failed;
        }
    }

    private void syncDirectoryOf(string target) {
    }
}

unittest {
    import std.conv : to;
    import std.datetime.systime : Clock;
    import std.range : walkLength;
    import dlangui.core.filewatch : FileChangeKind;
    string dir = buildPath(tempDir, "dlangui-safe-write-test-" ~ to!string(Clock.currStdTime));
    mkdirRecurse(dir);
    scope (exit)
        rmdirRecurse(dir);
    string fn = buildPath(dir, "a.txt");
    size_t filesInDir() { return dirEntries(dir, SpanMode.shallow).walkLength; }
    FileState written;

    // a new file, then a replaced one: the content, no temporary file left, the written state
    assert(writeFileSafely(fn, cast(const(ubyte)[])"first", written));
    assert(readText(fn) == "first" && filesInDir() == 1);
    assert(written.exists && written.size == 5 && written.compareTo(FileState.read(fn)) == FileChangeKind.unchanged);
    FileState before = FileState.read(fn);
    assert(writeFileSafely(fn, cast(const(ubyte)[])"second!", written));
    assert(readText(fn) == "second!" && filesInDir() == 1);
    FileState after = FileState.read(fn);
    assert(written.size == 7 && written.compareTo(after) == FileChangeKind.unchanged);
    assert(written.modified == after.modified); // the time read from the handle stays after closing
    if (before.hasFileId && after.hasFileId)
        assert(before.fileId != after.fileId); // replaced by the temporary file

    // in place when asked: the same file
    assert(writeFileSafely(fn, cast(const(ubyte)[])"third", written, false));
    assert(readText(fn) == "third");
    if (after.hasFileId)
        assert(FileState.read(fn).fileId == after.fileId);

    // a failed write leaves the original and no temporary file
    safeWriteTestHook = (string tmp) { throw new Exception("simulated write error"); };
    assert(!writeFileSafely(fn, cast(const(ubyte)[])"lost", written));
    safeWriteTestHook = null;
    assert(readText(fn) == "third" && filesInDir() == 1);

    // a temporary file name that exists (e.g. a planted link) is never written through
    {
        string taken = buildPath(dir, "taken.tmp");
        std.file.write(taken, "keep");
        std.stdio.File f;
        int error;
        assert(createNewFile(taken, true, f, error) == CreateStatus.exists && !f.isOpen);
        assert(readText(taken) == "keep");
        remove(taken);
    }

    version (Posix) {
        import core.sys.posix.unistd : symlink, link;
        import core.stdc.errno : ENOSPC, EDQUOT;
        // a full disk or quota while creating the temporary file fails without touching the original
        assert(createErrorAllowsInPlace(EACCES) && createErrorAllowsInPlace(EROFS));
        assert(!createErrorAllowsInPlace(ENOSPC) && !createErrorAllowsInPlace(EDQUOT));
        // only regular files are replaced
        bool existing;
        assert(!canReplaceByRename("/dev/null", existing) && existing);
        assert(!canReplaceByRename(dir, existing));
        assert(canReplaceByRename(buildPath(dir, "new.txt"), existing) && !existing);
        // a new file gets the default mode of new files
        string fresh = buildPath(dir, "fresh.txt"), plain = buildPath(dir, "plain.txt");
        assert(writeFileSafely(fresh, cast(const(ubyte)[])"x", written));
        std.file.write(plain, "x");
        assert((getAttributes(fresh) & octal!777) == (getAttributes(plain) & octal!777));
        remove(fresh);
        remove(plain);
        // permission bits are kept; a private file's new content is never readable by others while written
        setAttributes(fn, octal!600);
        uint tmpMode = uint.max;
        safeWriteTestHook = (string tmp) { tmpMode = getAttributes(tmp) & octal!777; };
        assert(writeFileSafely(fn, cast(const(ubyte)[])"private", written));
        safeWriteTestHook = null;
        assert(tmpMode == octal!600 && (getAttributes(fn) & octal!777) == octal!600);
        setAttributes(fn, octal!640);
        assert(writeFileSafely(fn, cast(const(ubyte)[])"mode", written));
        assert((getAttributes(fn) & octal!777) == octal!640);
        // a symbolic link stays a link, its target gets the content
        string linkName = buildPath(dir, "link.txt");
        assert(symlink(toStringz(fn), toStringz(linkName)) == 0);
        assert(writeFileSafely(linkName, cast(const(ubyte)[])"via link", written));
        assert(isSymlink(linkName) && readText(fn) == "via link");
        remove(linkName);
        // a file with another hard link stays shared
        string hard = buildPath(dir, "hard.txt");
        assert(link(toStringz(fn), toStringz(hard)) == 0);
        assert(writeFileSafely(fn, cast(const(ubyte)[])"both names", written));
        assert(readText(hard) == "both names");
        remove(hard);
    }
    version (Windows) {
        import std.array : replicate;
        assert(createErrorAllowsInPlace(ERROR_ACCESS_DENIED) && !createErrorAllowsInPlace(ERROR_DISK_FULL));
        bool existing;
        assert(!canReplaceByRename(dir, existing) && existing);
        // ReplaceFileW keeps the original's attributes; an in-place write works for a hidden file too
        setAttributes(fn, getAttributes(fn) | FILE_ATTRIBUTE_HIDDEN);
        assert(writeFileSafely(fn, cast(const(ubyte)[])"hidden", written));
        assert(readText(fn) == "hidden" && (getAttributes(fn) & FILE_ATTRIBUTE_HIDDEN));
        assert(writeFileSafely(fn, cast(const(ubyte)[])"hidden 2", written, false));
        assert(readText(fn) == "hidden 2" && (getAttributes(fn) & FILE_ATTRIBUTE_HIDDEN));
        setAttributes(fn, getAttributes(fn) & ~FILE_ATTRIBUTE_HIDDEN);
        // open in another program that doesn't allow deleting or replacing it, but allows writing: written in place
        HANDLE other = CreateFileW(toUTF16z(fn), GENERIC_READ, FILE_SHARE_READ | FILE_SHARE_WRITE, null,
                OPEN_EXISTING, 0, null);
        assert(other != INVALID_HANDLE_VALUE);
        bool ok = writeFileSafely(fn, cast(const(ubyte)[])"while open", written);
        CloseHandle(other);
        assert(ok && readText(fn) == "while open" && filesInDir() == 1);
        // a path longer than MAX_PATH: created, then replaced
        string longDir = buildPath(dir, "d".replicate(200 - dir.length > 100 ? 200 - dir.length : 100));
        mkdir(longDir);
        string longName = buildPath(longDir, "f".replicate(100) ~ ".txt");
        assert(longName.length > MAX_PATH);
        assert(writeFileSafely(longName, cast(const(ubyte)[])"long 1", written));
        assert(writeFileSafely(longName, cast(const(ubyte)[])"long 22", written));
        assert(readText(`\\?\` ~ longName) == "long 22" && FileState.read(longName).size == 7);
        remove(`\\?\` ~ longName);
        rmdir(longDir);
    }
}
