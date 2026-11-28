/**
The state of a file on disk, and how to compare a remembered state with the current one.

Editors remember the state of the file they loaded or saved, and later compare it with the disk to find out whether
another program changed or deleted the file (#783, #1275). The file watch service (`FileWatchService`, #785, #1301)
watches files and directories for many subscribers and reports changes as the same `FileChangeKind`, on the UI thread.

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
    package string longPathName(string path) @safe pure {
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

// ---------------------------------------------------------------------------------------------------------------------
// File watch service (#785, #1301): subscriptions, delivery on the UI thread, polling backend

import dlangui.core.events : CustomEventTarget;
import core.sync.mutex : Mutex;
import core.time : Duration, MonoTime, msecs, seconds;

/// one change reported by `FileWatchService`
struct FileChange {
    /// how the file changed (never `unchanged`)
    FileChangeKind kind;
    /// absolute, normalized path of the file (for a directory subscription: of the entry)
    string path;
    /// the file's state as the service read it (with a checksum when the subscription's baseline has one)
    FileState state;
}

/**
Called on the UI thread with the changes found since the last call; `subscription` is the one the handler was given
to. Not called after `subscription.cancel()` returns.
*/
alias FileChangeHandler = void delegate(FileWatchSubscription subscription, const(FileChange)[] changes);

/// what a directory subscription watches
struct DirectoryWatchOptions {
    /// also the subdirectories (and theirs)
    bool recursive;
    /// glob patterns for file names to report (`std.path.globMatch`); empty = all files and the directories
    /// themselves (when they appear or disappear); with patterns, matching files only
    string[] include;
    /// glob patterns for names of files and directories to skip; a skipped directory isn't even scanned
    string[] exclude;
}

/// how the service's polling backend runs
enum FileWatchMode {
    /// a background thread scans the watched paths every `pollInterval` (default)
    thread,
    /// no thread: the application calls `FileWatchService.poll()`, e.g. from a timer of a widget
    manual,
}

/**
A subscription to changes of a file or a directory (`FileWatchService.watchFile`, `watchDirectory`). The handler runs
on the UI thread of the target window; `update()` and `cancel()` are UI-thread calls too.
*/
final class FileWatchSubscription {
    private FileWatchService _service;
    private CustomEventTarget _target;
    private string _path;
    private bool _isDirectory;
    private DirectoryWatchOptions _options;
    // guarded by _mutex: shared with the watcher thread
    private Mutex _mutex;
    private FileChangeHandler _handler;
    private FileState _baseline;            // file: the state the subscriber trusts
    private FileState _reported;            // file: the last state reported, or the baseline
    private DirectoryListing _listing;      // directory: the listing reported, or the one of the first scan
    private bool _listingReady;             // directory: the first scan has read the baseline listing
    private ulong _createdGeneration;       // directory: scans started before it subscribed
    private FileChange[] _pending;
    private bool _deliveryQueued;
    private bool _cancelled;
    private bool _wantChecksum;             // file: the baseline has a checksum, so the service computes them
    private bool _needsCheck = true;        // file: compare with the disk at the next scan (new, or update())

    private this(FileWatchService service, CustomEventTarget target, string path, bool isDirectory,
            FileChangeHandler handler) {
        _service = service;
        _target = target;
        _path = path;
        _isDirectory = isDirectory;
        _handler = handler;
        _mutex = new Mutex();
    }

    /// absolute, normalized path of the watched file or directory
    @property string path() const { return _path; }
    /// true for a directory subscription
    @property bool isDirectory() const { return _isDirectory; }
    /// the window (or other target) whose UI thread runs the handler
    @property CustomEventTarget target() { return _target; }

    /// true after `cancel()`, or when the service stopped (target window destroyed, shutdown)
    @property bool cancelled() {
        _mutex.lock();
        scope (exit) _mutex.unlock();
        return _cancelled;
    }

    /**
    A file subscription's new baseline, e.g. after a save, a reload, or "keep my text": changes found so far that the
    handler wasn't called for yet are dropped when they match it.
    */
    void update(FileState newBaseline) {
        assert(!_isDirectory, "update(FileState) is for file subscriptions");
        _mutex.lock();
        scope (exit) _mutex.unlock();
        _baseline = newBaseline;
        _reported = newBaseline;
        _wantChecksum = newBaseline.hasChecksum;
        _needsCheck = true; // the next scan compares the new baseline with the disk
    }

    /// stops the notifications: the handler is not called after this returns (idempotent)
    void cancel() {
        _mutex.lock();
        bool wasCancelled = _cancelled;
        _cancelled = true;
        _handler = null; // a destroyed subscriber's closure isn't kept alive or called
        _pending = null;
        _mutex.unlock();
        if (!wasCancelled && _service)
            _service.removeSubscription(this);
    }

    // watcher side: queues a change; returns true if a delivery has to be posted
    private bool queueChange(FileChange change) {
        if (_cancelled)
            return false;
        _pending ~= change;
        if (_deliveryQueued)
            return false;
        _deliveryQueued = true;
        return true;
    }

    // UI side: the posted delivery
    private void deliver() {
        FileChange[] changes;
        FileChangeHandler handler;
        FileState baseline;
        _mutex.lock();
        if (_cancelled) {
            _mutex.unlock();
            return;
        }
        changes = _pending;
        _pending = null;
        _deliveryQueued = false;
        handler = _handler;
        baseline = _baseline;
        _mutex.unlock();
        if (!changes.length || !handler)
            return;
        if (!_isDirectory && !stillChanged(baseline, changes[$ - 1].state))
            return; // the app's own save, or changed and changed back
        handler(this, changes); // on the UI thread, outside the lock
    }

    // recheck on the UI thread: size and time only, plus the checksum the watcher computed for the same state
    private bool stillChanged(const FileState baseline, const FileState reported) {
        FileState current = FileState.read(_path);
        if (current.unknown)
            return true;
        if (reported.hasChecksum && current.exists == reported.exists && current.size == reported.size
                && current.modified == reported.modified) {
            current.checksum = reported.checksum;
            current.hasChecksum = true;
        }
        return !baseline.sameAs(current);
    }
}

// a directory listing: relative path -> state of the entry
private alias DirectoryListing = FileState[string];

// a watched file, shared by all subscriptions to its path
private final class WatchedFile {
    string path;
    FileWatchSubscription[] subscriptions;
    // watcher side only
    FileState observed;     // the state of the last scan
    bool observedValid;
    FileState settling;     // a new state, waiting to stay the same for settleTime
    bool isSettling;
    MonoTime changedAt;
}

// a watched directory, shared by subscriptions with the same path and options
private final class WatchedDirectory {
    string key;
    string path;
    DirectoryWatchOptions options;
    FileWatchSubscription[] subscriptions;
    // watcher side only
    DirectoryListing observed;
    bool observedValid;
    DirectoryListing settling;
    bool isSettling;
    MonoTime changedAt;
}

/**
Watches files and directories for many subscribers (#785, #1301), one service per process (`instance`). A
subscriber states the file state it trusts (`watchFile`) or gets the directory listing of the first scan after it
subscribed (`watchDirectory`), and its handler is called on the UI thread of its target window when the disk no longer matches.

Changes for a path are held until it is quiet for `settleTime` (writers truncate, write in parts, or write a temporary
file and rename it over). Before a file subscription's handler runs, the file state is read again on the UI thread:
the notification is dropped when it equals the baseline (the app's own save after `update()`, or a file changed and
changed back). The backend polls (a background thread by default, see `mode`); watches are shared per path.

All methods are UI-thread calls.
*/
final class FileWatchService {
    private static __gshared FileWatchService _instance;

    /**
    The target of subscriptions created with a null target: set by the platform (its first window). Called on the
    UI thread when subscribing.
    */
    static __gshared CustomEventTarget delegate() defaultTarget;

    /// the service of this process, created on first use
    static @property FileWatchService instance() {
        if (!_instance)
            _instance = new FileWatchService();
        return _instance;
    }

    /// true if the service exists (`instance` creates it)
    static @property bool hasInstance() {
        return _instance !is null;
    }

    /// stops the service: cancels all subscriptions and stops the watcher thread (the platform calls it on exit)
    static void shutdown() {
        if (!_instance)
            return;
        _instance.stop();
        _instance = null;
    }

    /// cancels the subscriptions whose handlers run on `target` (the platform calls it when a window is destroyed)
    static void cancelTarget(CustomEventTarget target) {
        if (!_instance || !target)
            return;
        foreach (s; _instance.subscriptionsOf(target))
            s.cancel();
    }

    private Mutex _lock; // guards the watch lists and the thread state
    private Mutex _scanLock; // one scan at a time (the watcher thread, poll())
    private ulong _scanGeneration; // scans started; a directory subscription is adopted by a later scan (#1303)
    private WatchedFile[string] _files;
    private WatchedDirectory[string] _directories;
    private FileWatchMode _mode = FileWatchMode.thread;
    private Duration _pollInterval = 2.seconds;
    private Duration _settleTime = 300.msecs;
    private WatcherThread _thread;

    private this() {
        _lock = new Mutex();
        _scanLock = new Mutex();
    }

    /// how the backend runs; changing it stops or starts the watcher thread
    @property FileWatchMode mode() const { return _mode; }
    /// ditto
    @property FileWatchService mode(FileWatchMode mode) {
        _mode = mode;
        if (mode == FileWatchMode.manual)
            stopThread();
        else
            startThreadIfNeeded();
        return this;
    }

    /// time between scans of the polling backend (default 2 s)
    @property Duration pollInterval() const { return _pollInterval; }
    /// ditto
    @property FileWatchService pollInterval(Duration interval) {
        _lock.lock();
        _pollInterval = interval;
        _lock.unlock();
        wake();
        return this;
    }

    /// how long a changed path has to stay unchanged before it is reported (default 300 ms)
    @property Duration settleTime() const { return _settleTime; }
    /// ditto
    @property FileWatchService settleTime(Duration time) {
        _lock.lock();
        _settleTime = time;
        _lock.unlock();
        return this;
    }

    /**
    Watches a file: `handler` is called (on `target`'s UI thread) when the file no longer matches `baseline`
    (`FileState.compareTo`), e.g. modified, deleted, or created when the baseline is a missing file; also when it
    differs already at subscribe time. With a checksum in the baseline, the service computes checksums for changed
    sizes or times too, so a file touched or written with the same content isn't reported.

    The subscription is cancelled when its target window is destroyed. A null target is `defaultTarget` at subscribe
    time (the platform's first window): pass the window the subscriber lives in.
    */
    FileWatchSubscription watchFile(FileState baseline, FileChangeHandler handler, CustomEventTarget target = null) {
        assert(baseline.path.length, "watchFile: the baseline has no path");
        target = resolveTarget(target);
        string path = normalizedFilePath(baseline.path);
        auto s = new FileWatchSubscription(this, target, path, false, handler);
        s._baseline = baseline;
        s._reported = baseline;
        s._wantChecksum = baseline.hasChecksum;
        _lock.lock();
        WatchedFile* found = path in _files;
        WatchedFile w = found ? *found : null;
        if (!w) {
            w = new WatchedFile();
            w.path = path;
            _files[path] = w;
        }
        w.subscriptions ~= s;
        _lock.unlock();
        startThreadIfNeeded();
        wake();
        return s;
    }

    /**
    Watches a directory: `handler` is called (on `target`'s UI thread; null = `defaultTarget`) with the entries
    added (`created`), removed (`deleted`) and changed (`modified`) since the first scan's listing, or since
    the last call. Entries are files and, with `options.recursive`, the subdirectories' files; without
    `options.include` patterns, directories themselves are reported too when they appear or disappear.

    The baseline listing is read by the next scan, off the UI thread (in `FileWatchMode.manual`: by the next
    `poll()`), so subscribing doesn't wait for a large tree; changes made before that scan aren't reported.
    Excluding what isn't needed (`options.exclude`) still makes each scan cheaper. Target: as for `watchFile`.
    */
    FileWatchSubscription watchDirectory(string path, DirectoryWatchOptions options, FileChangeHandler handler,
            CustomEventTarget target = null) {
        assert(path.length, "watchDirectory: no path");
        target = resolveTarget(target);
        path = normalizedFilePath(path);
        auto s = new FileWatchSubscription(this, target, path, true, handler);
        s._options = options; // the baseline listing comes with the next scan (#1303)
        string key = directoryKey(path, options);
        _lock.lock();
        WatchedDirectory* found = key in _directories;
        WatchedDirectory w = found ? *found : null;
        if (!w) {
            w = new WatchedDirectory();
            w.key = key;
            w.path = path;
            w.options = options;
            _directories[key] = w;
        }
        s._createdGeneration = _scanGeneration;
        w.subscriptions ~= s;
        _lock.unlock();
        startThreadIfNeeded();
        wake();
        return s;
    }

    /// scans the watched paths now instead of at the next interval, e.g. when a window is activated
    void checkNow() {
        if (_mode == FileWatchMode.manual) {
            poll();
        } else {
            startThreadIfNeeded(); // also restarts a thread an error ended
            wake();
        }
    }

    /**
    One scan of all watched paths in the calling thread, as the watcher thread does: for `FileWatchMode.manual`
    (call it from a timer) and for tests. A changed path is reported by a later call, after `settleTime`.
    */
    void poll() {
        scan(null);
    }

    /// number of watched paths (files and directories), shared by subscriptions; for tests and diagnostics
    @property size_t watchedPathCount() {
        _lock.lock();
        scope (exit) _lock.unlock();
        return _files.length + _directories.length;
    }

    private CustomEventTarget resolveTarget(CustomEventTarget target) {
        if (!target && defaultTarget)
            target = defaultTarget();
        if (!target)
            throw new Exception("FileWatchService: no target window to deliver changes to");
        return target;
    }

    private static string directoryKey(string path, const DirectoryWatchOptions options) {
        import std.array : join;
        import std.conv : to;
        return path ~ "\n" ~ to!string(options.recursive) ~ "\n" ~ options.include.join("\t") ~ "\n"
            ~ options.exclude.join("\t");
    }

    // removes a cancelled subscription; drops the watch when it was the last one
    private void removeSubscription(FileWatchSubscription s) {
        import std.algorithm : remove;
        _lock.lock();
        scope (exit) _lock.unlock();
        if (s._isDirectory) {
            string key = directoryKey(s._path, s._options);
            if (WatchedDirectory* w = key in _directories) {
                (*w).subscriptions = (*w).subscriptions.remove!(x => x is s);
                if (!(*w).subscriptions.length)
                    _directories.remove(key);
            }
        } else if (WatchedFile* w = s._path in _files) {
            (*w).subscriptions = (*w).subscriptions.remove!(x => x is s);
            if (!(*w).subscriptions.length)
                _files.remove(s._path);
        }
    }

    private FileWatchSubscription[] subscriptionsOf(CustomEventTarget target) {
        FileWatchSubscription[] res;
        _lock.lock();
        scope (exit) _lock.unlock();
        foreach (w; _files)
            foreach (s; w.subscriptions)
                if (s._target is target)
                    res ~= s;
        foreach (w; _directories)
            foreach (s; w.subscriptions)
                if (s._target is target)
                    res ~= s;
        return res;
    }

    private void stop() {
        stopThread();
        FileWatchSubscription[] all;
        _lock.lock();
        foreach (w; _files)
            all ~= w.subscriptions;
        foreach (w; _directories)
            all ~= w.subscriptions;
        _lock.unlock();
        foreach (s; all)
            s.cancel();
    }

    // ---- polling backend

    // one scan: reads the states without the lock, then reports what settled
    // one scan; aborted (the watcher thread's stop) ends it early, between paths and directory entries
    private void scan(scope bool delegate() aborted) {
        _scanLock.lock();
        scope (exit) _scanLock.unlock();
        WatchedFile[] files;
        WatchedDirectory[] directories;
        Duration settle;
        ulong generation;
        _lock.lock();
        generation = ++_scanGeneration;
        files = _files.values;
        directories = _directories.values;
        settle = _settleTime;
        _lock.unlock();
        MonoTime now = MonoTime.currTime;
        foreach (w; files) {
            if (aborted && aborted())
                return;
            scanFile(w, now, settle);
        }
        foreach (w; directories) {
            if (aborted && aborted())
                return;
            scanDirectory(w, now, settle, generation, aborted);
        }
    }

    // true while some path waits for its settle time: the next scan comes sooner
    private bool anySettling() {
        _lock.lock();
        scope (exit) _lock.unlock();
        foreach (w; _files)
            if (w.isSettling)
                return true;
        foreach (w; _directories)
            if (w.isSettling)
                return true;
        return false;
    }

    private void scanFile(WatchedFile w, MonoTime now, Duration settle) {
        FileState current = FileState.read(w.path);
        if (current.unknown)
            return; // no news: check again later
        if (!w.isSettling) {
            if (w.observedValid && sameMetadata(w.observed, current)) {
                // no change on disk; a new subscription or a new baseline is still compared with it
                if (anyNeedsCheck(w))
                    reportFile(w, current);
                return;
            }
            // first scan, or a change: wait until it stays the same for the settle time
            w.settling = current;
            w.isSettling = true;
            w.changedAt = now;
            if (settle > Duration.zero)
                return;
        } else if (!sameMetadata(w.settling, current)) {
            w.settling = current; // still changing
            w.changedAt = now;
            return;
        } else if (now - w.changedAt < settle) {
            return;
        }
        w.isSettling = false;
        w.observed = current;
        w.observedValid = true;
        reportFile(w, current);
    }

    // compares the settled state with each subscription's last reported state; queues and posts the changes
    private void reportFile(WatchedFile w, FileState current) {
        FileWatchSubscription[] subs;
        _lock.lock();
        subs = w.subscriptions.dup;
        _lock.unlock();
        FileState withChecksum;
        bool checksumRead;
        foreach (s; subs) {
            s._mutex.lock();
            FileState reported = s._reported;
            bool wantChecksum = s._wantChecksum;
            s._mutex.unlock();
            FileState state = current;
            if (wantChecksum && current.exists && !sameMetadata(reported, current)) {
                // the checksum decides when only the time (or the file id) differs: read once per scan
                if (!checksumRead) {
                    withChecksum = FileState.read(w.path, true);
                    checksumRead = true;
                }
                if (sameMetadata(withChecksum, current))
                    state = withChecksum;
            }
            s._mutex.lock();
            scope (exit) s._mutex.unlock();
            s._needsCheck = false;
            // against the current baseline: update() may have come meanwhile
            FileChangeKind kind = s._reported.compareTo(state);
            if (kind == FileChangeKind.unchanged)
                continue;
            s._reported = state;
            // posted under the lock: once cancel() has returned, nothing is posted to the target
            if (s.queueChange(FileChange(kind, w.path, state)))
                s._target.executeInUiThread(&s.deliver);
        }
    }

    // true if a subscription of the watched file wants a comparison with the disk (new, or update())
    private bool anyNeedsCheck(WatchedFile w) {
        FileWatchSubscription[] subs;
        _lock.lock();
        subs = w.subscriptions.dup;
        _lock.unlock();
        foreach (s; subs) {
            s._mutex.lock();
            bool check = s._needsCheck && !s._cancelled;
            s._mutex.unlock();
            if (check)
                return true;
        }
        return false;
    }

    private void scanDirectory(WatchedDirectory w, MonoTime now, Duration settle, ulong generation,
            scope bool delegate() aborted) {
        DirectoryListing current;
        if (!readListing(w.path, w.options, current, aborted))
            return; // stopped in the middle: a partial listing is neither compared nor adopted
        adoptBaselines(w, current, generation);
        if (!w.isSettling) {
            if (w.observedValid && sameListing(w.observed, current))
                return;
            w.settling = current;
            w.isSettling = true;
            w.changedAt = now;
            if (settle > Duration.zero)
                return;
        } else if (!sameListing(w.settling, current)) {
            w.settling = current;
            w.changedAt = now;
            return;
        } else if (now - w.changedAt < settle) {
            return;
        }
        w.isSettling = false;
        w.observed = current;
        w.observedValid = true;
        FileWatchSubscription[] subs;
        _lock.lock();
        subs = w.subscriptions.dup;
        _lock.unlock();
        foreach (s; subs) {
            s._mutex.lock();
            scope (exit) s._mutex.unlock();
            if (!s._listingReady)
                continue; // subscribed after this scan's adoption; its baseline comes with the next scan
            FileChange[] changes = listingChanges(w.path, s._listing, current);
            bool post;
            foreach (c; changes)
                post = s.queueChange(c) || post;
            if (changes.length)
                s._listing = current;
            // posted under the lock: once cancel() has returned, nothing is posted to the target
            if (post)
                s._target.executeInUiThread(&s.deliver);
        }
    }

    // new subscriptions of the directory take the listing of this scan as their baseline (#1303); only those created
    // before the scan started: one created while the listing was read waits for the next scan
    private void adoptBaselines(WatchedDirectory w, DirectoryListing current, ulong generation) {
        FileWatchSubscription[] subs;
        _lock.lock();
        subs = w.subscriptions.dup;
        _lock.unlock();
        foreach (s; subs) {
            s._mutex.lock();
            if (!s._listingReady && s._createdGeneration < generation) {
                s._listing = current;
                s._listingReady = true;
            }
            s._mutex.unlock();
        }
    }

    // ---- watcher thread

    private void startThreadIfNeeded() {
        _lock.lock();
        scope (exit) _lock.unlock();
        if (_thread && !_thread.isRunning)
            _thread = null; // ended by an error: start a new one
        if (_mode != FileWatchMode.thread || _thread || (!_files.length && !_directories.length))
            return;
        _thread = new WatcherThread(this);
        _thread.start();
    }

    private void stopThread() {
        WatcherThread t;
        _lock.lock();
        t = _thread;
        _thread = null;
        _lock.unlock();
        if (t)
            t.stopAndJoin(); // a long directory walk in progress ends at its next entry
    }

    private void wake() {
        _lock.lock();
        WatcherThread t = _thread;
        _lock.unlock();
        if (t)
            t.wake();
    }

    // the time until the next scan
    private Duration nextScanDelay() {
        _lock.lock();
        Duration interval = _pollInterval;
        Duration settle = _settleTime;
        _lock.unlock();
        if (anySettling() && settle < interval)
            return settle > Duration.zero ? settle : 1.msecs;
        return interval;
    }
}

// the polling backend's thread: scans, then waits for the next interval, a wake() or the stop
private final class WatcherThread {
    import core.sync.condition : Condition;
    import core.thread : Thread;

    private FileWatchService _service;
    private Thread _thread;
    private Mutex _mutex;
    private Condition _condition;
    private bool _stopping;
    private bool _woken;
    private shared bool _abort; // set by stopAndJoin(): the scan in progress ends early (#1303)
    debug private int _failures; // scan failures logged (the first few)

    this(FileWatchService service) {
        _service = service;
        _mutex = new Mutex();
        _condition = new Condition(_mutex);
        _thread = new Thread(&run);
        _thread.isDaemon = true; // never keeps the process alive
    }

    void start() {
        _thread.start();
    }

    @property bool isRunning() {
        return _thread.isRunning;
    }

    // checked by the scan between paths and directory entries
    private bool aborted() {
        import core.atomic : atomicLoad;
        return atomicLoad(_abort);
    }

    void wake() {
        _mutex.lock();
        _woken = true;
        _condition.notify();
        _mutex.unlock();
    }

    void stopAndJoin() {
        import core.atomic : atomicStore;
        atomicStore(_abort, true);
        _mutex.lock();
        _stopping = true;
        _condition.notify();
        _mutex.unlock();
        _thread.join(false);
    }

    private void run() {
        for (;;) {
            _mutex.lock();
            bool stopping = _stopping;
            _woken = false;
            _mutex.unlock();
            if (stopping)
                return;
            try {
                _service.scan(&aborted);
            } catch (Exception e) {
                // a scan error (e.g. a directory removed while listed) is retried at the next scan
                debug {
                    if (_failures++ < 3) {
                        import dlangui.core.logger : Log;
                        Log.w("FileWatchService: scan failed: ", e.msg);
                    }
                }
            }
            Duration delay = _service.nextScanDelay();
            _mutex.lock();
            if (!_stopping && !_woken)
                _condition.wait(delay);
            _mutex.unlock();
        }
    }
}

// same existence, size, time and identity (no checksums): what the watcher compares between scans
private bool sameMetadata(const FileState a, const FileState b) @safe pure nothrow @nogc {
    if (a.exists != b.exists)
        return false;
    if (!a.exists)
        return true;
    if (a.size != b.size || a.modified != b.modified)
        return false;
    return !(a.hasFileId && b.hasFileId && a.fileId != b.fileId);
}

private bool sameListing(const DirectoryListing a, const DirectoryListing b) {
    if (a.length != b.length)
        return false;
    foreach (name, state; a) {
        const(FileState)* other = name in b;
        if (!other || !sameMetadata(state, *other))
            return false;
    }
    return true;
}

// the changes from listing `before` to `after`, sorted by path
private FileChange[] listingChanges(string dir, const DirectoryListing before, const DirectoryListing after) {
    import std.algorithm : sort;
    import std.path : buildPath;
    import std.string : chomp;
    string entryPath(string name) {
        return buildPath(dir, name.chomp("/")); // directories are keyed with a trailing "/"
    }
    FileChange[] res;
    foreach (name, state; after) {
        const(FileState)* old = name in before;
        if (!old)
            res ~= FileChange(FileChangeKind.created, entryPath(name), state);
        else if (!sameMetadata(*old, state))
            res ~= FileChange(FileChangeKind.modified, entryPath(name), state);
    }
    foreach (name, state; before) {
        if (name !in after) {
            FileState gone;
            gone.path = state.path;
            res ~= FileChange(FileChangeKind.deleted, entryPath(name), gone);
        }
    }
    sort!((a, b) => a.path < b.path)(res);
    return res;
}

// the listing of a directory: files (and directories) by path relative to dir; a missing directory = empty; false if
// aborted() said to stop in the middle (res is then partial)
private bool readListing(string dir, const DirectoryWatchOptions options, out DirectoryListing res,
        scope bool delegate() aborted = null) {
    import std.file : DirEntry, dirEntries, SpanMode, FileException;
    import std.path : baseName, buildPath, globMatch;
    bool stopped;
    bool matchesAny(string name, const string[] patterns) {
        foreach (p; patterns)
            if (globMatch(name, p))
                return true;
        return false;
    }
    void walk(string path, string relative) {
        DirEntry[] entries;
        try {
            foreach (DirEntry e; dirEntries(path, SpanMode.shallow, false)) {
                if (aborted && aborted()) {
                    stopped = true; // also in the middle of a huge directory
                    return;
                }
                entries ~= e;
            }
        } catch (FileException) {
            return; // missing or unreadable: listed as empty
        }
        foreach (e; entries) {
            if (stopped || (aborted && aborted())) {
                stopped = true;
                return;
            }
            string name = baseName(e.name);
            if (matchesAny(name, options.exclude))
                continue;
            string rel = relative.length ? buildPath(relative, name) : name;
            bool isDir;
            FileState state;
            try {
                isDir = e.isDir;
                state.path = normalizedFilePath(e.name);
                state.exists = true;
                state.size = isDir ? 0 : e.size;
                state.modified = isDir ? state.modified : e.timeLastModified;
            } catch (FileException) {
                continue; // removed while listed
            }
            if (isDir) {
                if (!options.include.length)
                    res[rel ~ "/"] = state; // a directory: reported when it appears or disappears
                if (options.recursive)
                    walk(e.name, rel);
            } else if (!options.include.length || matchesAny(name, options.include)) {
                res[rel] = state;
            }
        }
    }
    walk(dir, null);
    return !stopped;
}

version (unittest) {
    // stands in for a window: queues the posted deliveries until run() (the "UI thread") executes them
    private final class TestTarget : CustomEventTarget {
        import dlangui.core.events : CustomEvent;
        private Mutex _m;
        private void delegate()[] _queue;
        this() { _m = new Mutex(); }
        void postEvent(CustomEvent event) { assert(0, "not used"); }
        void executeInUiThread(void delegate() runnable) {
            _m.lock();
            _queue ~= runnable;
            _m.unlock();
        }
        @property size_t queued() {
            _m.lock();
            scope (exit) _m.unlock();
            return _queue.length;
        }
        // runs the queued deliveries; returns how many there were
        size_t run() {
            _m.lock();
            auto q = _queue;
            _queue = null;
            _m.unlock();
            foreach (r; q)
                r();
            return q.length;
        }
    }

    // a test service in manual mode with no settle time: a change is reported by the second poll()
    private FileWatchService testService() {
        auto svc = new FileWatchService();
        svc._mode = FileWatchMode.manual;
        svc._settleTime = Duration.zero;
        return svc;
    }
}

// file subscriptions: modified, deleted, created; delivered through the target; the app's own save is dropped
unittest {
    import std.conv : to;
    import std.file : mkdirRecurse, rmdirRecurse, tempDir, write, remove, rename, exists, setTimes, timeLastModified;
    import std.path : buildPath;
    import std.process : thisProcessID;
    string dir = buildPath(tempDir, "dlangui-filewatch-svc-" ~ to!string(thisProcessID));
    mkdirRecurse(dir);
    scope (exit) rmdirRecurse(dir);
    string fn = buildPath(dir, "a.txt");
    write(fn, "one\n");

    auto svc = testService();
    scope (exit) svc.stop();
    auto target = new TestTarget();
    FileChange[] got;
    int calls;
    void handler(FileWatchSubscription s, const(FileChange)[] changes) {
        calls++;
        got = changes.dup;
    }
    auto sub = svc.watchFile(FileState.read(fn, true), &handler, target);
    assert(svc.watchedPathCount == 1 && !sub.isDirectory && sub.path == normalizedFilePath(fn));

    // nothing changed: nothing posted
    svc.poll();
    svc.poll();
    assert(target.run() == 0 && calls == 0);

    // modified: reported by the second scan (the first one waits for the settle time, here zero scans)
    write(fn, "one two\n");
    svc.poll();
    svc.poll();
    assert(target.queued == 1 && calls == 0); // only on the "UI thread"
    assert(target.run() == 1);
    assert(calls == 1 && got.length == 1 && got[0].kind == FileChangeKind.modified);
    assert(got[0].path == normalizedFilePath(fn) && got[0].state.size == 8 && got[0].state.hasChecksum);
    // reported once: the next scans see the same state
    svc.poll();
    svc.poll();
    assert(target.run() == 0 && calls == 1);

    // the app's own save: seen by the watcher before update(), dropped by the recheck on the UI thread
    write(fn, "saved by the app\n");
    svc.poll();
    svc.poll();
    assert(target.queued == 1);
    sub.update(FileState.read(fn, true));
    target.run();
    assert(calls == 1);
    // ... and after update() the state isn't reported at all
    write(fn, "saved again\n");
    FileState saved = FileState.read(fn, true);
    sub.update(saved);
    svc.poll();
    svc.poll();
    assert(target.run() == 0 && calls == 1);

    // touched: with a checksum in the baseline, the same content is no change
    setTimes(fn, timeLastModified(fn), timeLastModified(fn) + 5.seconds);
    svc.poll();
    svc.poll();
    assert(target.run() == 0 && calls == 1);

    // changed and changed back (content and time) before the handler runs: dropped
    write(fn, "changed for a moment\n");
    svc.poll();
    svc.poll();
    assert(target.queued == 1);
    write(fn, "saved again\n");
    setTimes(fn, saved.modified, saved.modified);
    target.run();
    assert(calls == 1);

    // replaced by another file (a rename-over save by another program)
    string tmp = buildPath(dir, "a.tmp");
    write(tmp, "written by another program\n");
    rename(tmp, fn);
    svc.poll();
    svc.poll();
    target.run();
    assert(calls == 2 && got.length == 1 && got[0].kind == FileChangeKind.modified);

    // deleted, then created again
    remove(fn);
    svc.poll();
    svc.poll();
    target.run();
    assert(calls == 3 && got[0].kind == FileChangeKind.deleted && !got[0].state.exists);
    write(fn, "back\n");
    svc.poll();
    svc.poll();
    target.run();
    assert(calls == 4 && got[0].kind == FileChangeKind.created && got[0].state.exists);

    // a file that doesn't exist yet: created
    string later = buildPath(dir, "later.txt");
    auto sub2 = svc.watchFile(FileState.read(later), &handler, target);
    svc.poll();
    svc.poll();
    assert(target.run() == 0);
    write(later, "x");
    svc.poll();
    svc.poll();
    target.run();
    assert(calls == 5 && got[0].kind == FileChangeKind.created && got[0].path == normalizedFilePath(later));
    sub2.cancel();
    sub.cancel();
    assert(svc.watchedPathCount == 0 && sub.cancelled);
}

// cancel: a delivery already posted doesn't call the handler; shared, counted watches; cancelTarget; settle time
unittest {
    import std.conv : to;
    import std.file : mkdirRecurse, rmdirRecurse, tempDir, write;
    import std.path : buildPath;
    import std.process : thisProcessID;
    import core.thread : Thread;
    string dir = buildPath(tempDir, "dlangui-filewatch-cancel-" ~ to!string(thisProcessID));
    mkdirRecurse(dir);
    scope (exit) rmdirRecurse(dir);
    string fn = buildPath(dir, "a.txt");
    write(fn, "one\n");

    auto svc = testService();
    scope (exit) svc.stop();
    auto t1 = new TestTarget();
    auto t2 = new TestTarget();
    int calls1, calls2;
    auto a = svc.watchFile(FileState.read(fn), (s, c) { calls1++; }, t1);
    auto b = svc.watchFile(FileState.read(fn), (s, c) { calls2++; }, t2);
    assert(svc.watchedPathCount == 1); // one watch for both

    // cancel after the delivery was posted, before it runs: the handler isn't called
    write(fn, "one two\n");
    svc.poll();
    svc.poll();
    assert(t1.queued == 1 && t2.queued == 1);
    a.cancel();
    a.cancel(); // idempotent
    t1.run();
    t2.run();
    assert(calls1 == 0 && calls2 == 1);
    assert(svc.watchedPathCount == 1); // still watched for b

    // the target is destroyed: its subscriptions are cancelled
    auto c = svc.watchFile(FileState.read(fn), (s, ch) { calls1++; }, t1);
    FileWatchService saved = FileWatchService._instance;
    FileWatchService._instance = svc;
    scope (exit) FileWatchService._instance = saved;
    FileWatchService.cancelTarget(t1);
    assert(c.cancelled && !b.cancelled);

    // settle time: a file still being written is reported once it stays the same for settleTime
    svc._settleTime = 50.msecs;
    write(fn, "a\n");
    svc.poll(); // the change is seen
    write(fn, "ab\n");
    svc.poll(); // still changing: wait again
    svc.poll();
    assert(t2.queued == 0);
    Thread.sleep(80.msecs);
    svc.poll();
    assert(t2.run() == 1 && calls2 == 2);
    b.cancel();
    assert(svc.watchedPathCount == 0);

    // no target and no default target: an error, not a subscription that can't deliver
    bool thrown;
    try
        svc.watchFile(FileState.read(fn), (s, ch) {}, null);
    catch (Exception)
        thrown = true;
    assert(thrown && svc.watchedPathCount == 0);
}

// directory subscriptions: added, removed, modified entries; recursive; exclude and include filters
unittest {
    import std.algorithm : canFind, map;
    import std.array : array;
    import std.conv : to;
    import std.file : mkdirRecurse, rmdirRecurse, tempDir, write, remove;
    import std.path : buildPath;
    import std.process : thisProcessID;
    string dir = buildPath(tempDir, "dlangui-filewatch-dir-" ~ to!string(thisProcessID));
    mkdirRecurse(buildPath(dir, "sub"));
    mkdirRecurse(buildPath(dir, ".git"));
    scope (exit) rmdirRecurse(dir);
    write(buildPath(dir, "a.d"), "a");
    write(buildPath(dir, "notes.txt"), "n");
    write(buildPath(dir, "sub", "b.d"), "b");
    write(buildPath(dir, ".git", "HEAD"), "h");

    auto svc = testService();
    scope (exit) svc.stop();
    auto target = new TestTarget();
    FileChange[] all, flat, onlyD;
    auto rec = svc.watchDirectory(dir, DirectoryWatchOptions(true, null, [".git"]),
            (s, c) { all ~= c; }, target);
    auto shallow = svc.watchDirectory(dir, DirectoryWatchOptions(false, null, [".git"]),
            (s, c) { flat ~= c; }, target);
    auto dfiles = svc.watchDirectory(dir, DirectoryWatchOptions(true, ["*.d"], [".git"]),
            (s, c) { onlyD ~= c; }, target);
    assert(rec.isDirectory && svc.watchedPathCount == 3);
    // subscribing reads no listing: the first scan does (#1303)
    assert(!rec._listingReady && rec._listing is null);
    svc.poll();
    assert(rec._listingReady && rec._listing.length);
    svc.poll();
    assert(target.run() == 0);

    write(buildPath(dir, "a.d"), "a changed");
    write(buildPath(dir, "c.d"), "c");
    write(buildPath(dir, "notes.txt"), "more notes");
    remove(buildPath(dir, "sub", "b.d"));
    mkdirRecurse(buildPath(dir, "newdir"));
    write(buildPath(dir, ".git", "index"), "excluded");
    svc.poll();
    svc.poll();
    target.run();

    string p(string[] parts...) { return normalizedFilePath(buildPath(dir ~ parts)); }
    bool has(FileChange[] list, FileChangeKind kind, string path) {
        foreach (c; list)
            if (c.kind == kind && c.path == path)
                return true;
        return false;
    }
    assert(has(all, FileChangeKind.modified, p("a.d")));
    assert(has(all, FileChangeKind.created, p("c.d")));
    assert(has(all, FileChangeKind.modified, p("notes.txt")));
    assert(has(all, FileChangeKind.deleted, p("sub", "b.d")));
    assert(has(all, FileChangeKind.created, p("newdir")));
    assert(all.length == 5, to!string(all.map!(c => c.path).array)); // nothing from the excluded .git
    // not recursive: the subdirectory's file isn't listed
    assert(!has(flat, FileChangeKind.deleted, p("sub", "b.d")) && flat.length == 4);
    // include *.d: no notes.txt, no directories
    assert(onlyD.length == 3 && has(onlyD, FileChangeKind.deleted, p("sub", "b.d")));
    assert(!onlyD.map!(c => c.path).canFind(p("notes.txt")));

    // reported once
    svc.poll();
    svc.poll();
    assert(target.run() == 0);
    rec.cancel();
    shallow.cancel();
    dfiles.cancel();
    assert(svc.watchedPathCount == 0);
}

// the watcher thread: a change is delivered without poll(); the thread stops with the service
unittest {
    import std.conv : to;
    import std.file : mkdirRecurse, rmdirRecurse, tempDir, write;
    import std.path : buildPath;
    import std.process : thisProcessID;
    import core.thread : Thread;
    string dir = buildPath(tempDir, "dlangui-filewatch-thread-" ~ to!string(thisProcessID));
    mkdirRecurse(dir);
    scope (exit) rmdirRecurse(dir);
    string fn = buildPath(dir, "a.txt");
    write(fn, "one\n");

    auto svc = new FileWatchService();
    svc._pollInterval = 10.msecs;
    svc._settleTime = 20.msecs;
    auto target = new TestTarget();
    int calls;
    FileChangeKind kind;
    auto sub = svc.watchFile(FileState.read(fn), (s, c) { calls++; kind = c[$ - 1].kind; }, target);
    assert(svc._thread !is null); // started by the first subscription
    write(fn, "one two\n");
    foreach (i; 0 .. 300) {
        if (target.queued)
            break;
        Thread.sleep(10.msecs);
    }
    target.run();
    assert(calls == 1 && kind == FileChangeKind.modified);
    // manual mode stops the thread; thread mode starts it again
    svc.mode = FileWatchMode.manual;
    assert(svc._thread is null);
    svc.mode = FileWatchMode.thread;
    assert(svc._thread !is null);
    sub.cancel();
    svc.stop();
    assert(svc._thread is null);
}

// review fixes: a subscriber joining an existing watch (or after update()) with a baseline the disk no longer
// matches is told at the next scan; checksums follow the baseline, also after a delete; a dead thread restarts
unittest {
    import std.conv : to;
    import std.file : mkdirRecurse, rmdirRecurse, tempDir, write, remove, setTimes, timeLastModified;
    import std.path : buildPath;
    import std.process : thisProcessID;
    string dir = buildPath(tempDir, "dlangui-filewatch-review-" ~ to!string(thisProcessID));
    mkdirRecurse(dir);
    scope (exit) rmdirRecurse(dir);
    string fn = buildPath(dir, "a.txt");
    write(fn, "one\n");
    FileState old = FileState.read(fn, true);
    write(fn, "one changed\n");

    auto svc = testService();
    scope (exit) svc.stop();
    auto target = new TestTarget();
    int callsA, callsB;
    FileChangeKind kindB;
    auto a = svc.watchFile(FileState.read(fn, true), (s, c) { callsA++; }, target);
    svc.poll();
    svc.poll();
    assert(target.run() == 0 && callsA == 0);
    // B joins the existing watch with the state it loaded before the file changed
    auto b = svc.watchFile(old, (s, c) { callsB++; kindB = c[$ - 1].kind; }, target);
    svc.poll();
    target.run();
    assert(callsB == 1 && kindB == FileChangeKind.modified && callsA == 0);
    // update() with a state the disk doesn't match: reported at the next scan too
    b.update(old);
    svc.poll();
    target.run();
    assert(callsB == 2);
    b.cancel();

    // checksums follow the baseline: after a delete and a create, a touch is still no change
    remove(fn);
    svc.poll();
    svc.poll();
    target.run();
    write(fn, "back\n");
    svc.poll();
    svc.poll();
    target.run();
    assert(callsA == 2);
    setTimes(fn, timeLastModified(fn), timeLastModified(fn) + 5.seconds);
    svc.poll();
    svc.poll();
    assert(target.run() == 0 && callsA == 2);
    a.cancel();

    // a watcher thread that ended (here: stopped behind the service's back) is started again by checkNow()
    auto svc2 = new FileWatchService();
    scope (exit) svc2.stop();
    svc2._pollInterval = 10.msecs;
    auto c = svc2.watchFile(FileState.read(fn), (s, ch) {}, target);
    WatcherThread first = svc2._thread;
    assert(first !is null);
    first.stopAndJoin();
    assert(!first.isRunning);
    svc2.checkNow();
    assert(svc2._thread !is null && svc2._thread !is first && svc2._thread.isRunning);
    c.cancel();
}

// #1303: the directory baseline comes with the first scan; joining a shared watch; an aborted scan reports and
// adopts nothing; stopping the thread resets the abort flag
unittest {
    import std.conv : to;
    import std.file : mkdirRecurse, rmdirRecurse, tempDir, write;
    import std.path : buildPath;
    import std.process : thisProcessID;
    string dir = buildPath(tempDir, "dlangui-filewatch-1303-" ~ to!string(thisProcessID));
    mkdirRecurse(dir);
    scope (exit) rmdirRecurse(dir);
    write(buildPath(dir, "a.d"), "a");

    auto svc = testService();
    scope (exit) svc.stop();
    auto target = new TestTarget();
    FileChange[] gotA, gotB;
    auto a = svc.watchDirectory(dir, DirectoryWatchOptions(), (s, c) { gotA ~= c; }, target);
    // a change before the first scan is part of the baseline, not reported
    write(buildPath(dir, "early.d"), "e");
    svc.poll();
    svc.poll();
    assert(target.run() == 0 && a._listingReady);

    // an aborted scan (the thread is being stopped): nothing reported, no baseline adopted
    auto b = svc.watchDirectory(dir, DirectoryWatchOptions(), (s, c) { gotB ~= c; }, target);
    assert(svc.watchedPathCount == 1); // shares a's watch
    write(buildPath(dir, "late.d"), "l");
    svc.scan(() => true); // stops before the first path
    WatchedDirectory w = svc._directories.values[0];
    svc.scanDirectory(w, MonoTime.currTime, Duration.zero, ulong.max, () => true); // stops in the walk
    assert(target.run() == 0 && !b._listingReady);
    // the next scan: b adopts the current listing (late.d included), a gets late.d
    svc.poll();
    svc.poll();
    target.run();
    assert(b._listingReady && !gotB.length);
    assert(gotA.length == 1 && gotA[0].kind == FileChangeKind.created
        && gotA[0].path == normalizedFilePath(buildPath(dir, "late.d")));
    // from now on both see changes
    write(buildPath(dir, "both.d"), "b");
    svc.poll();
    svc.poll();
    target.run();
    assert(gotA.length == 2 && gotB.length == 1);
    // a subscription created while a scan reads the listing waits for the next scan
    ulong generation = svc._scanGeneration; // the scan "started" before the subscribe
    auto d = svc.watchDirectory(dir, DirectoryWatchOptions(), (s, c) {}, target);
    svc.scanDirectory(w, MonoTime.currTime, Duration.zero, generation, null);
    assert(!d._listingReady && b._listingReady);
    svc.poll();
    assert(d._listingReady);
    d.cancel();
    a.cancel();
    b.cancel();

    // a directory walk stops at its next entry when told to, and says so
    DirectoryListing listing;
    assert(!readListing(dir, DirectoryWatchOptions(true), listing, () => true));
    assert(readListing(dir, DirectoryWatchOptions(true), listing, () => false) && listing.length == 4);

    // stopping the thread sets the abort flag only while it waits for the thread
    auto svc2 = new FileWatchService();
    svc2._pollInterval = 10.msecs;
    auto c = svc2.watchDirectory(dir, DirectoryWatchOptions(true), (s, ch) {}, target);
    assert(svc2._thread !is null);
    svc2.mode = FileWatchMode.manual;
    assert(svc2._thread is null);
    svc2.poll(); // manual polls still scan
    assert(c._listingReady);
    c.cancel();
    svc2.stop();
}
