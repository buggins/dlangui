/**
The state of a file on disk, and how to compare a remembered state with the current one.

Editors remember the state of the file they loaded or saved, and later compare it with the disk to find out whether
another program changed or deleted the file (#783, #1275). The file watch service (#785) joins this module later and
reports changes as the same `FileChangeKind`.

Synopsis:
----
import dlangui.core.filewatch;

FileState loaded = FileState.read("app.d", true);   // with a checksum
// ... later
final switch (loaded.compareTo(FileState.read("app.d", true))) { ... }
----
*/
module dlangui.core.filewatch;

import std.datetime.systime : SysTime;
import std.stdio : File;

/**
How a file changed, compared with a remembered state. `unchanged` is the result of comparisons and state checks
(`FileState.compareTo`, editors' change checks); a file watcher never delivers it.
*/
enum FileChangeKind : ubyte {
    /// the file is as remembered (also: still missing)
    unchanged,
    /// the file was written, or replaced by another file
    modified,
    /// the file was there and is gone
    deleted,
    /// the file was missing and is there now
    created,
    /// changes may have been missed (a watcher's event queue overflowed): read the state again
    overflow,
}

/**
Identity of a file on its file system: device and inode on POSIX, volume serial and file index on Windows. On ReFS
volumes, whose file ids are 128-bit, the 64-bit index may not be unique.
*/
struct FileId {
    ulong device;
    ulong index;
}

/// CRC-64 (ECMA-182) of data, the checksum `FileState` keeps
ulong fileChecksum(const(ubyte)[] data) @safe pure nothrow @nogc {
    import std.digest.crc : CRC64ECMA;
    CRC64ECMA crc;
    crc.put(data);
    return checksumValue(crc.finish());
}

private ulong checksumValue(const ubyte[8] hash) @safe pure nothrow @nogc {
    ulong res = 0;
    foreach (b; hash)
        res = (res << 8) | b;
    return res;
}

/**
The state of a file on disk: whether it exists, its size, modification time, and optionally a checksum of its content
and its identity on the file system.

Compare a remembered state with the current one with `compareTo`: a different existence, size or time is a change,
except that when both states carry a checksum, a different time (or file identity) with the same checksum is not:
`touch`, or a `git checkout` of identical content, leaves the file unchanged.
*/
struct FileState {
    /// absolute, normalized path
    string path;
    /// false for a missing (deleted, not yet created) file
    bool exists;
    /// size in bytes
    ulong size;
    /// modification time, at the precision the file system gives
    SysTime modified;
    /// checksum of the content (`fileChecksum`), valid when hasChecksum is true
    ulong checksum;
    /// ditto
    bool hasChecksum;
    /// identity of the file, valid when hasFileId is true: it changes when the file is replaced by another one
    FileId fileId;
    /// ditto
    bool hasFileId;
    /**
    The state couldn't be read: an error other than "not found", e.g. access denied, a file being deleted, a network
    file system that doesn't answer. `exists` is false; `compareTo` gives `unchanged` for it (no news: check again
    later), so a transient error isn't taken for a deleted file.
    */
    bool unknown;

    /**
    Reads the state of file `path`; a missing file gives `exists == false`, an error other than "not found" also
    `unknown == true`. With `withChecksum`, the content is read and its checksum kept; size and time are read just
    before, so a file being written meanwhile can give a checksum that doesn't match them: read it again after a
    change is reported.
    */
    static FileState read(string path, bool withChecksum = false) {
        FileState res;
        res.path = normalizedFilePath(path);
        if (!readPathState(res))
            return res;
        if (withChecksum) {
            try {
                res.checksum = fileChecksumOf(res.path);
                res.hasChecksum = true;
            } catch (Exception) {
                // vanished or unreadable since the state was read: keep the state without a checksum
            }
        }
        return res;
    }

    /**
    Reads the state of an open file: size, time and identity belong to the file that is open, even if `path` names
    another file by now. A file open for writing must be flushed (or its data written with unbuffered calls) first:
    the system doesn't know about data still in the `File`'s buffer. A closed `file` gives `unknown`.
    */
    static FileState read(ref File file, string path) {
        FileState res;
        res.path = normalizedFilePath(path);
        readHandleState(file, res);
        return res;
    }

    /// ditto, with the file's content as read: its checksum is kept (an empty or null `content` = an empty file)
    static FileState read(ref File file, string path, const(ubyte)[] content) {
        FileState res = read(file, path);
        if (res.exists) {
            res.checksum = fileChecksum(content);
            res.hasChecksum = true;
        }
        return res;
    }

    /**
    How `current` differs from this state (the remembered one, e.g. the file as loaded): `unchanged`, `modified`,
    `deleted` or `created`. If either state is `unknown`, the result is `unchanged`.
    */
    FileChangeKind compareTo(const FileState current) const @safe pure nothrow @nogc {
        if (unknown || current.unknown)
            return FileChangeKind.unchanged;
        if (!exists)
            return current.exists ? FileChangeKind.created : FileChangeKind.unchanged;
        if (!current.exists)
            return FileChangeKind.deleted;
        if (size != current.size)
            return FileChangeKind.modified;
        bool otherFile = hasFileId && current.hasFileId && fileId != current.fileId;
        if (modified == current.modified && !otherFile)
            return hasChecksum && current.hasChecksum && checksum != current.checksum
                ? FileChangeKind.modified : FileChangeKind.unchanged;
        // touched, or replaced by another file: the content decides if both checksums are known
        if (hasChecksum && current.hasChecksum)
            return checksum == current.checksum ? FileChangeKind.unchanged : FileChangeKind.modified;
        return FileChangeKind.modified;
    }

    /// true if `other` is the same file state (`compareTo(other) == unchanged`)
    bool sameAs(const FileState other) const @safe pure nothrow @nogc {
        return compareTo(other) == FileChangeKind.unchanged;
    }
}

/// absolute, normalized form of path, as FileState keeps it
string normalizedFilePath(string path) @safe {
    import std.path : absolutePath, buildNormalizedPath;
    return path.length ? buildNormalizedPath(absolutePath(path)) : path;
}

private ulong fileChecksumOf(string path) {
    import std.digest.crc : CRC64ECMA;
    CRC64ECMA crc;
    version (Windows)
        auto f = File(longPathName(path), "rb");
    else
        auto f = File(path, "rb");
    foreach (chunk; f.byChunk(64 * 1024))
        crc.put(chunk);
    return checksumValue(crc.finish());
}

version (Posix) {
    import core.sys.posix.sys.stat : stat_t, stat, fstat;

    // modification time of a stat result; the field name differs between systems
    private SysTime statModified(const ref stat_t st) @safe pure nothrow {
        import std.datetime.systime : unixTimeToStdTime;
        static if (__traits(hasMember, stat_t, "st_mtim"))
            return SysTime(unixTimeToStdTime(st.st_mtim.tv_sec) + st.st_mtim.tv_nsec / 100);
        else static if (__traits(hasMember, stat_t, "st_mtimespec"))
            return SysTime(unixTimeToStdTime(st.st_mtimespec.tv_sec) + st.st_mtimespec.tv_nsec / 100);
        else static if (__traits(hasMember, stat_t, "st_mtimensec"))
            return SysTime(unixTimeToStdTime(st.st_mtime) + st.st_mtimensec / 100);
        else
            return SysTime(unixTimeToStdTime(st.st_mtime));
    }

    private void fromStat(const ref stat_t st, ref FileState res) @safe pure nothrow {
        res.exists = true;
        res.size = st.st_size;
        res.modified = statModified(st);
        res.fileId = FileId(st.st_dev, st.st_ino);
        res.hasFileId = true;
    }

    // @trusted: stat() writes into the local stat_t only; the path is copied to a zero-terminated string
    private bool readPathState(ref FileState res) @trusted {
        import core.stdc.errno : errno, ENOENT, ENOTDIR;
        import std.string : toStringz;
        stat_t st;
        if (stat(toStringz(res.path), &st) != 0) {
            // missing (also: a path component that isn't a directory); anything else: state unknown
            res.unknown = errno != ENOENT && errno != ENOTDIR;
            return false;
        }
        fromStat(st, res);
        return true;
    }

    private bool readHandleState(ref File file, ref FileState res) @trusted {
        stat_t st;
        if (!file.isOpen || fstat(file.fileno, &st) != 0) {
            res.unknown = true;
            return false;
        }
        fromStat(st, res);
        return true;
    }
} else version (Windows) {
    import core.sys.windows.windows;

    // @trusted: takes the address of a field of the caller's struct for FILETIMEToSysTime, which only reads it
    // during the call (without -preview=dip1000, @safe code may not take that address)
    private void fromInfo(const ref BY_HANDLE_FILE_INFORMATION info, ref FileState res) @trusted {
        import std.datetime.systime : FILETIMEToSysTime;
        res.exists = true;
        res.size = (cast(ulong)info.nFileSizeHigh << 32) | info.nFileSizeLow;
        res.modified = FILETIMEToSysTime(&info.ftLastWriteTime);
        res.fileId = FileId(info.dwVolumeSerialNumber, (cast(ulong)info.nFileIndexHigh << 32) | info.nFileIndexLow);
        res.hasFileId = true;
    }

    // an absolute path in the form that works beyond MAX_PATH (260 characters) for applications that don't
    // declare long path awareness: \\?\ prefix (\\?\UNC\ for a network path)
    private string longPathName(string path) @safe pure {
        import std.algorithm : startsWith;
        if (path.length < 248 || path.startsWith(`\\?\`))
            return path;
        return path.startsWith(`\\`) ? `\\?\UNC\` ~ path[2 .. $] : `\\?\` ~ path;
    }

    unittest {
        import std.array : replicate;
        assert(longPathName(`C:\a\b.d`) == `C:\a\b.d`);
        string deep = `C:\` ~ "x".replicate(260);
        assert(longPathName(deep) == `\\?\` ~ deep);
        assert(longPathName(`\\server\share\` ~ "x".replicate(260)) == `\\?\UNC\server\share\` ~ "x".replicate(260));
    }

    // @trusted: the handle is opened for attributes only and closed here; GetFileInformationByHandle writes into
    // the local struct
    private bool readPathState(ref FileState res) @trusted {
        import std.utf : toUTF16z;
        HANDLE h = CreateFileW(toUTF16z(longPathName(res.path)), FILE_READ_ATTRIBUTES,
                FILE_SHARE_READ | FILE_SHARE_WRITE | FILE_SHARE_DELETE, null, OPEN_EXISTING,
                FILE_FLAG_BACKUP_SEMANTICS, null);
        if (h == INVALID_HANDLE_VALUE) {
            // missing; anything else (access denied, a file being deleted, a network error): state unknown
            immutable err = GetLastError();
            res.unknown = err != ERROR_FILE_NOT_FOUND && err != ERROR_PATH_NOT_FOUND && err != ERROR_INVALID_NAME;
            return false;
        }
        scope (exit)
            CloseHandle(h);
        BY_HANDLE_FILE_INFORMATION info;
        if (!GetFileInformationByHandle(h, &info)) {
            res.unknown = true;
            return false;
        }
        fromInfo(info, res);
        return true;
    }

    private bool readHandleState(ref File file, ref FileState res) @trusted {
        BY_HANDLE_FILE_INFORMATION info;
        if (!file.isOpen || !GetFileInformationByHandle(file.windowsHandle, &info)) {
            res.unknown = true;
            return false;
        }
        fromInfo(info, res);
        return true;
    }
} else {
    private bool readPathState(ref FileState res) {
        import std.file : exists, getSize, isFile, timeLastModified;
        try {
            if (!exists(res.path))
                return false;
            res.exists = true;
            res.size = isFile(res.path) ? getSize(res.path) : 0;
            res.modified = timeLastModified(res.path);
            return true;
        } catch (Exception) {
            res.exists = false;
            res.unknown = true;
            return false;
        }
    }

    private bool readHandleState(ref File file, ref FileState res) {
        if (!file.isOpen) {
            res.unknown = true;
            return false;
        }
        return readPathState(res);
    }
}

unittest {
    import std.conv : to;
    import std.datetime.systime : Clock;
    import std.file : mkdirRecurse, rmdirRecurse, tempDir, write, remove, rename, setTimes, timeLastModified;
    import std.path : buildPath;
    import core.time : seconds;
    import std.conv : octal;

    string dir = buildPath(tempDir, "dlangui-filewatch-test-" ~ Clock.currStdTime.to!string);
    mkdirRecurse(dir);
    scope (exit)
        rmdirRecurse(dir);
    string fn = buildPath(dir, "a.txt");

    // missing, then created
    FileState missing = FileState.read(fn);
    assert(!missing.exists && missing.path == normalizedFilePath(fn));
    assert(missing.compareTo(FileState.read(fn)) == FileChangeKind.unchanged);
    write(fn, "hello");
    FileState created = FileState.read(fn, true);
    assert(created.exists && created.size == 5 && created.hasChecksum);
    version (Posix) assert(created.hasFileId);
    version (Windows) assert(created.hasFileId);
    assert(created.checksum == fileChecksum(cast(const(ubyte)[])"hello"));
    assert(missing.compareTo(created) == FileChangeKind.created);
    assert(created.compareTo(FileState.read(fn, true)) == FileChangeKind.unchanged);
    assert(created.sameAs(FileState.read(fn)));

    // modified with the same size: a later time
    SysTime t0 = timeLastModified(fn);
    write(fn, "world");
    setTimes(fn, t0 + 2.seconds, t0 + 2.seconds);
    assert(created.compareTo(FileState.read(fn)) == FileChangeKind.modified);
    assert(created.compareTo(FileState.read(fn, true)) == FileChangeKind.modified);
    // same size and time, other content: only the checksum tells
    setTimes(fn, t0, t0);
    assert(created.compareTo(FileState.read(fn)) == FileChangeKind.unchanged);
    assert(created.compareTo(FileState.read(fn, true)) == FileChangeKind.modified);

    // touched: a new time, the same content
    write(fn, "hello");
    setTimes(fn, t0 + 4.seconds, t0 + 4.seconds);
    assert(created.compareTo(FileState.read(fn)) == FileChangeKind.modified); // no checksum: the time decides
    assert(created.compareTo(FileState.read(fn, true)) == FileChangeKind.unchanged);

    // replaced by another file (write a temp file, rename it over) with the same content, size and time
    setTimes(fn, t0, t0);
    FileState before = FileState.read(fn);
    FileState beforeSum = FileState.read(fn, true);
    string tmp = buildPath(dir, "a.txt.tmp");
    write(tmp, "hello");
    setTimes(tmp, t0, t0);
    rename(tmp, fn);
    FileState replaced = FileState.read(fn);
    if (before.hasFileId && replaced.hasFileId) {
        assert(before.fileId != replaced.fileId);
        assert(before.compareTo(replaced) == FileChangeKind.modified);
    }
    assert(beforeSum.compareTo(FileState.read(fn, true)) == FileChangeKind.unchanged);

    // deleted, then created again
    remove(fn);
    FileState gone = FileState.read(fn, true);
    assert(!gone.exists && !gone.hasChecksum);
    assert(before.compareTo(gone) == FileChangeKind.deleted);
    write(fn, "again");
    assert(gone.compareTo(FileState.read(fn)) == FileChangeKind.created);

    // from an open file: the state of the file that is open, with the checksum of the content given
    {
        auto f = File(fn, "rb");
        ubyte[] content = f.rawRead(new ubyte[16]);
        FileState fromHandle = FileState.read(f, fn, content);
        f.close();
        FileState fromPath = FileState.read(fn, true);
        assert(fromHandle.exists && fromHandle.size == 5 && fromHandle.hasChecksum);
        assert(fromHandle.compareTo(fromPath) == FileChangeKind.unchanged);
        assert(fromHandle.modified == fromPath.modified && fromHandle.fileId == fromPath.fileId);
    }
    {
        File closed;
        FileState s = FileState.read(closed, fn);
        assert(!s.exists && s.unknown);
        assert(before.compareTo(s) == FileChangeKind.unchanged);
    }

    // an empty file read through its handle: the checksum of empty content is kept (null content too)
    {
        string empty = buildPath(dir, "empty.txt");
        write(empty, "");
        auto f = File(empty, "rb");
        FileState s = FileState.read(f, empty, null);
        f.close();
        assert(s.exists && s.size == 0 && s.hasChecksum && s.checksum == fileChecksum(null));
        setTimes(empty, t0 + 6.seconds, t0 + 6.seconds); // touched
        assert(s.compareTo(FileState.read(empty, true)) == FileChangeKind.unchanged);
    }

    // a file that can't be read for another reason than "not found": unknown, not deleted
    version (Posix) {
        import std.file : setAttributes;
        string locked = buildPath(dir, "locked");
        mkdirRecurse(locked);
        string inner = buildPath(locked, "f.txt");
        write(inner, "x");
        FileState seen = FileState.read(inner);
        setAttributes(locked, octal!0);
        FileState s = FileState.read(inner);
        setAttributes(locked, octal!755);
        if (s.exists) {
            // running as root: permissions don't apply
        } else {
            assert(s.unknown);
            assert(seen.compareTo(s) == FileChangeKind.unchanged);
        }
    }
}
