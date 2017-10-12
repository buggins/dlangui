/**
 * Getting XDG base directories.
 * Note: These functions are defined only on freedesktop systems.
 * Authors:
 *  $(LINK2 https://github.com/FreeSlave, Roman Chistokhodov)
 * Copyright:
 *  Roman Chistokhodov, 2016
 * License:
 *  $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0).
 * See_Also:
 *  $(LINK2 https://specifications.freedesktop.org/basedir-spec/latest/index.html, XDG Base Directory Specification)
 */

module xdgpaths;

import isfreedesktop;

version(D_Ddoc)
{
    /**
     * Path to runtime user directory.
     * Returns: User's runtime directory determined by $(B XDG_RUNTIME_DIR) environment variable.
     * If directory does not exist it tries to create one with appropriate permissions. On fail returns an empty string.
     */
    @trusted string xdgRuntimeDir() nothrow;

    /**
     * The ordered set of non-empty base paths to search for data files, in descending order of preference.
     * Params:
     *  subfolder = Subfolder which is appended to every path if not null.
     * Returns: Data directories, without user's one and with no duplicates.
     * Note: This function does not check if paths actually exist and appear to be directories.
     * See_Also: $(D xdgAllDataDirs), $(D xdgDataHome)
     */
    @trusted string[] xdgDataDirs(string subfolder = null) nothrow;

    /**
     * The ordered set of non-empty base paths to search for data files, in descending order of preference.
     * Params:
     *  subfolder = Subfolder which is appended to every path if not null.
     * Returns: Data directories, including user's one if could be evaluated.
     * Note: This function does not check if paths actually exist and appear to be directories.
     * See_Also: $(D xdgDataDirs), $(D xdgDataHome)
     */
    @trusted string[] xdgAllDataDirs(string subfolder = null) nothrow;

    /**
     * The ordered set of non-empty base paths to search for configuration files, in descending order of preference.
     * Params:
     *  subfolder = Subfolder which is appended to every path if not null.
     * Returns: Config directories, without user's one and with no duplicates.
     * Note: This function does not check if paths actually exist and appear to be directories.
     * See_Also: $(D xdgAllConfigDirs), $(D xdgConfigHome)
     */
    @trusted string[] xdgConfigDirs(string subfolder = null) nothrow;

    /**
     * The ordered set of non-empty base paths to search for configuration files, in descending order of preference.
     * Params:
     *  subfolder = Subfolder which is appended to every path if not null.
     * Returns: Config directories, including user's one if could be evaluated.
     * Note: This function does not check if paths actually exist and appear to be directories.
     * See_Also: $(D xdgConfigDirs), $(D xdgConfigHome)
     */
    @trusted string[] xdgAllConfigDirs(string subfolder = null) nothrow;

    /**
     * The base directory relative to which user-specific data files should be stored.
     * Returns: Path to user-specific data directory or empty string on error.
     * Params:
     *  subfolder = Subfolder to append to determined path.
     *  shouldCreate = If path does not exist, create directory using 700 permissions (i.e. allow access only for current user).
     * See_Also: $(D xdgAllDataDirs), $(D xdgDataDirs)
     */
    @trusted string xdgDataHome(string subfolder = null, bool shouldCreate = false) nothrow;

    /**
     * The base directory relative to which user-specific configuration files should be stored.
     * Returns: Path to user-specific configuration directory or empty string on error.
     * Params:
     *  subfolder = Subfolder to append to determined path.
     *  shouldCreate = If path does not exist, create directory using 700 permissions (i.e. allow access only for current user).
     * See_Also: $(D xdgAllConfigDirs), $(D xdgConfigDirs)
     */
    @trusted string xdgConfigHome(string subfolder = null, bool shouldCreate = false) nothrow;

    /**
     * The base directory relative to which user-specific non-essential files should be stored.
     * Returns: Path to user-specific cache directory or empty string on error.
     * Params:
     *  subfolder = Subfolder to append to determined path.
     *  shouldCreate = If path does not exist, create directory using 700 permissions (i.e. allow access only for current user).
     */
    @trusted string xdgCacheHome(string subfolder = null, bool shouldCreate = false) nothrow;
}

static if (isFreedesktop)
{
    private {
        import std.algorithm : splitter, map, filter, canFind;
        import std.array;
        import std.conv : octal;
        import std.exception : collectException, enforce;
        import std.file;
        import std.path : buildPath, dirName;
        import std.process : environment;
        import std.string : toStringz;

        import core.sys.posix.unistd;
        import core.sys.posix.sys.stat;
        import core.sys.posix.sys.types;
        import core.stdc.string;
        import core.stdc.errno;

        static if (is(typeof({import std.string : fromStringz;}))) {
            import std.string : fromStringz;
        } else { //own fromStringz implementation for compatibility reasons
            @system static pure inout(char)[] fromStringz(inout(char)* cString) {
                return cString ? cString[0..strlen(cString)] : null;
            }
        }

        enum mode_t privateMode = octal!700;
    }

    version(unittest) {
        import std.algorithm : equal;

        private struct EnvGuard
        {
            this(string env) {
                envVar = env;
                envValue = environment.get(env);
            }

            ~this() {
                if (envValue is null) {
                    environment.remove(envVar);
                } else {
                    environment[envVar] = envValue;
                }
            }

            string envVar;
            string envValue;
        }
    }

    private string[] pathsFromEnvValue(string envValue, string subfolder = null) nothrow {
        string[] result;
        try {
            foreach(path; splitter(envValue, ':').filter!(p => !p.empty).map!(p => buildPath(p, subfolder))) {
                if (path[$-1] == '/') {
                    path = path[0..$-1];
                }
                if (!result.canFind(path)) {
                    result ~= path;
                }
            }
        } catch(Exception e) {

        }
        return result;
    }

    unittest
    {
        assert(pathsFromEnvValue("") == (string[]).init);
        assert(pathsFromEnvValue(":") == (string[]).init);
        assert(pathsFromEnvValue("::") == (string[]).init);

        assert(pathsFromEnvValue("path1:path2") == ["path1", "path2"]);
        assert(pathsFromEnvValue("path1:") == ["path1"]);
        assert(pathsFromEnvValue("path1/") == ["path1"]);
        assert(pathsFromEnvValue("path1/:path1") == ["path1"]);
        assert(pathsFromEnvValue("path2:path1:path2") == ["path2", "path1"]);
    }

    private string[] pathsFromEnv(string envVar, string subfolder = null) nothrow {
        string envValue;
        collectException(environment.get(envVar), envValue);
        return pathsFromEnvValue(envValue, subfolder);
    }

    private bool ensureExists(string dir) nothrow
    {
        bool ok;
        try {
            ok = dir.exists;
            if (!ok) {
                mkdirRecurse(dir.dirName);
                ok = mkdir(dir.toStringz, privateMode) == 0;
            } else {
                ok = dir.isDir;
            }
        } catch(Exception e) {
            ok = false;
        }
        return ok;
    }

    unittest
    {
        import std.file;
        import std.stdio;

        string temp = tempDir();
        if (temp.length) {
            string testDir = buildPath(temp, "xdgpaths-unittest-tempdir");
            string testFile = buildPath(testDir, "touched");
            string testSubDir = buildPath(testDir, "subdir");
            try {
                mkdir(testDir);
                File(testFile, "w");
                assert(!ensureExists(testFile));
                enforce(ensureExists(testSubDir));
            } catch(Exception e) {

            } finally {
                collectException(rmdir(testSubDir));
                collectException(remove(testFile));
                collectException(rmdir(testDir));
            }
        }
    }

    private string xdgBaseDir(string envvar, string fallback, string subfolder = null, bool shouldCreate = false) nothrow {
        string dir;
        collectException(environment.get(envvar), dir);
        if (dir.length == 0) {
            string home;
            collectException(environment.get("HOME"), home);
            dir = home.length ? buildPath(home, fallback) : null;
        }

        if (dir.length == 0) {
            return null;
        }

        if (shouldCreate) {
            if (ensureExists(dir)) {
                if (subfolder.length) {
                    string path = buildPath(dir, subfolder);
                    try {
                        if (!path.exists) {
                            mkdirRecurse(path);
                        }
                        return path;
                    } catch(Exception e) {

                    }
                } else {
                    return dir;
                }
            }
        } else {
            return buildPath(dir, subfolder);
        }
        return null;
    }

    version(unittest) {
        void testXdgBaseDir(string envVar, string fallback) {
            auto homeGuard = EnvGuard("HOME");
            auto dataHomeGuard = EnvGuard(envVar);

            auto newHome = "/home/myuser";
            auto newDataHome = "/home/myuser/data";

            environment[envVar] = newDataHome;
            assert(xdgBaseDir(envVar, fallback) == newDataHome);
            assert(xdgBaseDir(envVar, fallback, "applications") == buildPath(newDataHome, "applications"));

            environment.remove(envVar);
            environment["HOME"] = newHome;
            assert(xdgBaseDir(envVar, fallback) == buildPath(newHome, fallback));
            assert(xdgBaseDir(envVar, fallback, "icons") == buildPath(newHome, fallback, "icons"));

            environment.remove("HOME");
            assert(xdgBaseDir(envVar, fallback).empty);
            assert(xdgBaseDir(envVar, fallback, "mime").empty);
        }
    }

    @trusted string[] xdgDataDirs(string subfolder = null) nothrow
    {
        auto result = pathsFromEnv("XDG_DATA_DIRS", subfolder);
        if (result.length) {
            return result;
        } else {
            return [buildPath("/usr/local/share", subfolder), buildPath("/usr/share", subfolder)];
        }
    }

    ///
    unittest
    {
        auto dataDirsGuard = EnvGuard("XDG_DATA_DIRS");

        auto newDataDirs = ["/usr/local/data", "/usr/data"];

        environment["XDG_DATA_DIRS"] = "/usr/local/data:/usr/data:/usr/local/data/:/usr/data/";
        assert(xdgDataDirs() == newDataDirs);
        assert(equal(xdgDataDirs("applications"), newDataDirs.map!(p => buildPath(p, "applications"))));

        environment.remove("XDG_DATA_DIRS");
        assert(xdgDataDirs() == ["/usr/local/share", "/usr/share"]);
        assert(equal(xdgDataDirs("icons"), ["/usr/local/share", "/usr/share"].map!(p => buildPath(p, "icons"))));
    }

    @trusted string[] xdgAllDataDirs(string subfolder = null) nothrow
    {
        string dataHome = xdgDataHome(subfolder);
        string[] dataDirs = xdgDataDirs(subfolder);
        if (dataHome.length) {
            return dataHome ~ dataDirs;
        } else {
            return dataDirs;
        }
    }

    ///
    unittest
    {
        auto homeGuard = EnvGuard("HOME");
        auto dataHomeGuard = EnvGuard("XDG_DATA_HOME");
        auto dataDirsGuard = EnvGuard("XDG_DATA_DIRS");

        auto newDataHome = "/home/myuser/data";
        auto newDataDirs = ["/usr/local/data", "/usr/data"];
        environment["XDG_DATA_HOME"] = newDataHome;
        environment["XDG_DATA_DIRS"] = "/usr/local/data:/usr/data";

        assert(xdgAllDataDirs() == newDataHome ~ newDataDirs);

        environment.remove("XDG_DATA_HOME");
        environment.remove("HOME");

        assert(xdgAllDataDirs() == newDataDirs);
    }

    @trusted string[] xdgConfigDirs(string subfolder = null) nothrow
    {
        auto result = pathsFromEnv("XDG_CONFIG_DIRS", subfolder);
        if (result.length) {
            return result;
        } else {
            return [buildPath("/etc/xdg", subfolder)];
        }
    }

    ///
    unittest
    {
        auto dataConfigGuard = EnvGuard("XDG_CONFIG_DIRS");

        auto newConfigDirs = ["/usr/local/config", "/usr/config"];

        environment["XDG_CONFIG_DIRS"] = "/usr/local/config:/usr/config";
        assert(xdgConfigDirs() == newConfigDirs);
        assert(equal(xdgConfigDirs("menus"), newConfigDirs.map!(p => buildPath(p, "menus"))));

        environment.remove("XDG_CONFIG_DIRS");
        assert(xdgConfigDirs() == ["/etc/xdg"]);
        assert(equal(xdgConfigDirs("autostart"), ["/etc/xdg"].map!(p => buildPath(p, "autostart"))));
    }

    @trusted string[] xdgAllConfigDirs(string subfolder = null) nothrow
    {
        string configHome = xdgConfigHome(subfolder);
        string[] configDirs = xdgConfigDirs(subfolder);
        if (configHome.length) {
            return configHome ~ configDirs;
        } else {
            return configDirs;
        }
    }

    ///
    unittest
    {
        auto homeGuard = EnvGuard("HOME");
        auto configHomeGuard = EnvGuard("XDG_CONFIG_HOME");
        auto configDirsGuard = EnvGuard("XDG_CONFIG_DIRS");

        auto newConfigHome = "/home/myuser/data";
        environment["XDG_CONFIG_HOME"] = newConfigHome;
        auto newConfigDirs = ["/usr/local/data", "/usr/data"];
        environment["XDG_CONFIG_DIRS"] = "/usr/local/data:/usr/data";

        assert(xdgAllConfigDirs() == newConfigHome ~ newConfigDirs);

        environment.remove("XDG_CONFIG_HOME");
        environment.remove("HOME");

        assert(xdgAllConfigDirs() == newConfigDirs);
    }

    @trusted string xdgDataHome(string subfolder = null, bool shouldCreate = false) nothrow {
        return xdgBaseDir("XDG_DATA_HOME", ".local/share", subfolder, shouldCreate);
    }

    unittest
    {
        testXdgBaseDir("XDG_DATA_HOME", ".local/share");
    }

    @trusted string xdgConfigHome(string subfolder = null, bool shouldCreate = false) nothrow {
        return xdgBaseDir("XDG_CONFIG_HOME", ".config", subfolder, shouldCreate);
    }

    unittest
    {
        testXdgBaseDir("XDG_CONFIG_HOME", ".config");
    }

    @trusted string xdgCacheHome(string subfolder = null, bool shouldCreate = false) nothrow {
        return xdgBaseDir("XDG_CACHE_HOME", ".cache", subfolder, shouldCreate);
    }

    unittest
    {
        testXdgBaseDir("XDG_CACHE_HOME", ".cache");
    }

    version(XdgPathsRuntimeDebug) {
        private import std.stdio;
    }

    @trusted string xdgRuntimeDir() nothrow // Do we need it on BSD systems?
    {
        import std.exception : assumeUnique;
        import core.sys.posix.pwd;

        try { //one try to rule them all and for compatibility reasons
            const uid_t uid = getuid();
            string runtime;
            collectException(environment.get("XDG_RUNTIME_DIR"), runtime);

            if (!runtime.length) {
                passwd* pw = getpwuid(uid);

                try {
                    if (pw && pw.pw_name) {
                        runtime = tempDir() ~ "/runtime-" ~ assumeUnique(fromStringz(pw.pw_name));

                        if (!(runtime.exists && runtime.isDir)) {
                            if (mkdir(runtime.toStringz, privateMode) != 0) {
                                version(XdgPathsRuntimeDebug) stderr.writefln("Failed to create runtime directory %s: %s", runtime, fromStringz(strerror(errno)));
                                return null;
                            }
                        }
                    } else {
                        version(XdgPathsRuntimeDebug) stderr.writeln("Failed to get user name to create runtime directory");
                        return null;
                    }
                } catch(Exception e) {
                    version(XdgPathsRuntimeDebug) collectException(stderr.writefln("Error when creating runtime directory: %s", e.msg));
                    return null;
                }
            }
            stat_t statbuf;
            stat(runtime.toStringz, &statbuf);
            if (statbuf.st_uid != uid) {
                version(XdgPathsRuntimeDebug) collectException(stderr.writeln("Wrong ownership of runtime directory %s, %d instead of %d", runtime, statbuf.st_uid, uid));
                return null;
            }
            if ((statbuf.st_mode & octal!777) != privateMode) {
                version(XdgPathsRuntimeDebug) collectException(stderr.writefln("Wrong permissions on runtime directory %s, %o instead of %o", runtime, statbuf.st_mode, privateMode));
                return null;
            }

            return runtime;
        } catch (Exception e) {
            version(XdgPathsRuntimeDebug) collectException(stderr.writeln("Error when getting runtime directory: %s", e.msg));
            return null;
        }
    }

    version(xdgpathsFileTest) unittest
    {
        string runtimePath = buildPath(tempDir(), "xdgpaths-runtime-test");
        try {
            collectException(std.file.rmdir(runtimePath));

            if (mkdir(runtimePath.toStringz, privateMode) == 0) {
                auto runtimeGuard = EnvGuard("XDG_RUNTIME_DIR");
                environment["XDG_RUNTIME_DIR"] = runtimePath;
                assert(xdgRuntimeDir() == runtimePath);

                if (chmod(runtimePath.toStringz, octal!777) == 0) {
                    assert(xdgRuntimeDir() == string.init);
                }

                std.file.rmdir(runtimePath);
            } else {
                version(XdgPathsRuntimeDebug) stderr.writeln(fromStringz(strerror(errno)));
            }
        } catch(Exception e) {
            version(XdgPathsRuntimeDebug) stderr.writeln(e.msg);
        }
    }
}
