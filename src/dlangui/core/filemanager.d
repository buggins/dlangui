module dlangui.core.filemanager;
import dlangui.core.logger;
import isfreedesktop;

/**
 * Show and select directory or file in OS file manager.
 *
 * On Windows this shows file in File Exporer.
 *
 * On macOS it reveals file in Finder.
 *
 * On Freedesktop systems this function finds user preferred program that used to open directories.
 *  If found file manager is known to this function, it uses file manager specific way to select file.
 *  Otherwise it fallbacks to opening $(D pathName) if it's directory or parent directory of $(D pathName) if it's file.
 */
@trusted bool showInFileManager(string pathName) {
    import std.process;
    import std.path;
    import std.file;
    Log.i("showInFileManager(", pathName, ")");
    string normalized = buildNormalizedPath(pathName);
    if (!normalized.exists) {
        Log.e("showInFileManager failed - file or directory does not exist");
        return false;
    }
    import std.string;
    try {
        version (Windows) {
            import core.sys.windows.windows;
            import dlangui.core.files;
            import std.utf : toUTF16z;

            string explorerPath = findExecutablePath("explorer.exe");
            if (!explorerPath.length) {
                Log.e("showInFileManager failed - cannot find explorer.exe");
                return false;
            }
            string arg = "/select,\"" ~ normalized ~ "\"";
            STARTUPINFO si;
            si.cb = si.sizeof;
            PROCESS_INFORMATION pi;
            Log.d("showInFileManager: ", explorerPath, " ", arg);
            arg = "\"" ~ explorerPath ~ "\" " ~ arg;
            auto res = CreateProcessW(null, //explorerPath.toUTF16z,
                                        cast(wchar*)arg.toUTF16z,
                                        null, null, false, DETACHED_PROCESS,
                                        null, null, &si, &pi);
            if (!res) {
                Log.e("showInFileManager failed to run explorer.exe");
                return false;
            }
            return true;
        } else version (OSX) {
            string exe = "/usr/bin/osascript";
            string[] args;
            args ~= exe;
            args ~= "-e";
            args ~= "tell application \"Finder\" to reveal (POSIX file \"" ~ normalized ~ "\")";
            Log.d("Executing command: ", args);
            auto pid = spawnProcess(args);
            wait(pid);
            args[2] = "tell application \"Finder\" to activate";
            Log.d("Executing command: ", args);
            pid = spawnProcess(args);
            wait(pid);
            return true;
        } else version(Android) {
            Log.w("showInFileManager is not implemented for current platform");
        } else static if (isFreedesktop) {
            import std.stdio : File;
            import std.algorithm : map, filter, splitter, canFind, equal, findSplit;
            import std.exception : collectException, assumeUnique;
            import std.path : buildPath, absolutePath, isAbsolute, dirName, baseName;
            import std.range;
            import std.string : toStringz;
            import std.typecons : Tuple, tuple;
            static import std.stdio;
            import inilike.common;
            import inilike.range;
            import xdgpaths;

            string toOpen = pathName;

            static string unescapeQuotedArgument(string value) nothrow pure
            {
                static immutable Tuple!(char, char)[] pairs = [
                    tuple('`', '`'),
                    tuple('$', '$'),
                    tuple('"', '"'),
                    tuple('\\', '\\')
                ];
                return doUnescape(value, pairs);
            }

            static auto unquoteExec(string unescapedValue) pure
            {
                auto value = unescapedValue;
                string[] result;
                size_t i;

                static string parseQuotedPart(ref size_t i, char delimeter, string value)
                {
                    size_t start = ++i;
                    bool inQuotes = true;

                    while(i < value.length && inQuotes) {
                        if (value[i] == '\\' && value.length > i+1 && value[i+1] == '\\') {
                            i+=2;
                            continue;
                        }

                        inQuotes = !(value[i] == delimeter && (value[i-1] != '\\' || (i>=2 && value[i-1] == '\\' && value[i-2] == '\\') ));
                        if (inQuotes) {
                            i++;
                        }
                    }
                    if (inQuotes) {
                        throw new Exception("Missing pair quote");
                    }
                    return unescapeQuotedArgument(value[start..i]);
                }

                char[] append;
                bool wasInQuotes;
                while(i < value.length) {
                    if (value[i] == ' ' || value[i] == '\t') {
                        if (!wasInQuotes && append.length >= 1 && append[$-1] == '\\') {
                            append[$-1] = value[i];
                        } else {
                            if (append !is null) {
                                result ~= append.assumeUnique;
                                append = null;
                            }
                        }
                        wasInQuotes = false;
                    } else if (value[i] == '"' || value[i] == '\'') {
                        append ~= parseQuotedPart(i, value[i], value);
                        wasInQuotes = true;
                    } else {
                        append ~= value[i];
                        wasInQuotes = false;
                    }
                    i++;
                }

                if (append !is null) {
                    result ~= append.assumeUnique;
                }

                return result;
            }

            static string urlToFilePath(string url) nothrow pure
            {
                enum protocol = "file://";
                if (url.length > protocol.length && url[0..protocol.length] == protocol) {
                    return url[protocol.length..$];
                } else {
                    return url;
                }
            }

            static string[] expandExecArgs(in string[] unquotedArgs, in string[] urls = null, string iconName = null, string displayName = null, string fileName = null) pure
            {
                string[] toReturn;
                foreach(token; unquotedArgs) {
                    if (token == "%F") {
                        toReturn ~= urls.map!(url => urlToFilePath(url)).array;
                    } else if (token == "%U") {
                        toReturn ~= urls;
                    } else if (token == "%i") {
                        if (iconName.length) {
                            toReturn ~= "--icon";
                            toReturn ~= iconName;
                        }
                    } else {
                        static void expand(string token, ref string expanded, ref size_t restPos, ref size_t i, string insert)
                        {
                            if (token.length == 2) {
                                expanded = insert;
                            } else {
                                expanded ~= token[restPos..i] ~ insert;
                            }
                            restPos = i+2;
                            i++;
                        }

                        string expanded;
                        size_t restPos = 0;
                        bool ignore;
                        loop: for(size_t i=0; i<token.length; ++i) {
                            if (token[i] == '%' && i<token.length-1) {
                                switch(token[i+1]) {
                                    case 'f': case 'u':
                                    {
                                        if (urls.length) {
                                            string arg = urls.front;
                                            if (token[i+1] == 'f') {
                                                arg = urlToFilePath(arg);
                                            }
                                            expand(token, expanded, restPos, i, arg);
                                        } else {
                                            ignore = true;
                                            break loop;
                                        }
                                    }
                                    break;
                                    case 'c':
                                    {
                                        expand(token, expanded, restPos, i, displayName);
                                    }
                                    break;
                                    case 'k':
                                    {
                                        expand(token, expanded, restPos, i, fileName);
                                    }
                                    break;
                                    case 'd': case 'D': case 'n': case 'N': case 'm': case 'v':
                                    {
                                        ignore = true;
                                        break loop;
                                    }
                                    case '%':
                                    {
                                        expand(token, expanded, restPos, i, "%");
                                    }
                                    break;
                                    default:
                                    {
                                        throw new Exception("Unknown or misplaced field code: " ~ token);
                                    }
                                }
                            }
                        }

                        if (!ignore) {
                            toReturn ~= expanded ~ token[restPos..$];
                        }
                    }
                }

                return toReturn;
            }

            static bool isExecutable(string program) nothrow
            {
                import core.sys.posix.unistd;
                return access(program.toStringz, X_OK) == 0;
            }

            static string findExecutable(string program, const(string)[] binPaths) nothrow
            {
                if (program.isAbsolute && isExecutable(program)) {
                    return program;
                } else if (program.baseName == program) {
                    foreach(path; binPaths) {
                        auto candidate = buildPath(path, program);
                        if (isExecutable(candidate)) {
                            return candidate;
                        }
                    }
                }
                return null;
            }

            static void parseConfigFile(string fileName, string wantedGroup, bool delegate (string, string) onKeyValue)
            {
                auto r = iniLikeFileReader(fileName);
                foreach(group; r.byGroup())
                {
                    if (group.groupName == wantedGroup)
                    {
                        foreach(entry; group.byEntry())
                        {
                            if (entry.length && !isComment(entry)) {
                                auto pair = parseKeyValue(entry);
                                if (!isValidKey(pair.key)) {
                                    return;
                                }
                                if (!onKeyValue(pair.key, pair.value.unescapeValue)) {
                                    return;
                                }
                            }
                        }
                        return;
                    }
                }
            }

            static string[] findFileManagerCommand(string app, const(string)[] appDirs, const(string)[] binPaths) nothrow
            {
                foreach(appDir; appDirs) {
                    bool fileExists;
                    auto appPath = buildPath(appDir, app);
                    collectException(appPath.isFile, fileExists);
                    if (!fileExists) {
                        //check if file in subdirectory exist. E.g. kde4-dolphin.desktop refers to kde4/dolphin.desktop
                        auto appSplitted = findSplit(app, "-");
                        if (appSplitted[1].length && appSplitted[2].length) {
                            appPath = buildPath(appDir, appSplitted[0], appSplitted[2]);
                            collectException(appPath.isFile, fileExists);
                        }
                    }

                    if (fileExists) {
                        try {
                            bool canOpenDirectory; //not used for now. Some file managers does not have MimeType in their .desktop file.
                            string exec, tryExec, icon, displayName;

                            parseConfigFile(appPath, "Desktop Entry", delegate bool(string key, string value) {
                                if (key.equal("MimeType")) {
                                    canOpenDirectory = value.splitter(';').canFind("inode/directory");
                                } else if (key.equal("Exec")) {
                                    exec = value;
                                } else if (key.equal("TryExec")) {
                                    tryExec = value;
                                } else if (key.equal("Icon")) {
                                    icon = value;
                                } else if (key.equal("Name")) {
                                    displayName = value;
                                }
                                return true;
                            });

                            if (exec.length) {
                                if (tryExec.length) {
                                    auto program = findExecutable(tryExec, binPaths);
                                    if (!program.length) {
                                        continue;
                                    }
                                }
                                return expandExecArgs(unquoteExec(exec), null, icon, displayName, appPath);
                            }

                        } catch(Exception e) {

                        }
                    }
                }

                return null;
            }

            static void execShowInFileManager(string[] fileManagerArgs, string toOpen)
            {
                toOpen = toOpen.absolutePath();
                switch(fileManagerArgs[0].baseName) {
                    //nautilus and nemo select item if it's a file
                    case "nautilus":
                    case "nemo":
                        fileManagerArgs ~= toOpen;
                        break;
                    //dolphin needs --select option
                    case "dolphin":
                    case "konqueror":
                        fileManagerArgs ~= ["--select", toOpen];
                        break;
                    default:
                    {
                        bool pathIsDir;
                        collectException(toOpen.isDir, pathIsDir);
                        if (!pathIsDir) {
                            fileManagerArgs ~= toOpen.dirName;
                        } else {
                            fileManagerArgs ~= toOpen;
                        }
                    }
                        break;
                }

                File inFile, outFile, errFile;
                try {
                    inFile = File("/dev/null", "rb");
                } catch(Exception) {
                    inFile = std.stdio.stdin;
                }
                try {
                    auto nullFile = File("/dev/null", "wb");
                    outFile = nullFile;
                    errFile = nullFile;
                } catch(Exception) {
                    outFile = std.stdio.stdout;
                    errFile = std.stdio.stderr;
                }

                auto processConfig = Config.none;
                static if (is(typeof(Config.detached)))
                {
                    processConfig |= Config.detached;
                }
                spawnProcess(fileManagerArgs, inFile, outFile, errFile, null, processConfig);
            }

            string configHome = xdgConfigHome();
            string appHome = xdgDataHome("applications");

            auto configDirs = xdgConfigDirs();
            auto appDirs = xdgDataDirs("applications");

            auto allAppDirs = xdgAllDataDirs("applications");
            auto binPaths = environment.get("PATH").splitter(':').filter!(p => p.length > 0).array;

            string[] fileManagerArgs;
            foreach(mimeappsList; chain(only(configHome), only(appHome), configDirs, appDirs).map!(p => buildPath(p, "mimeapps.list"))) {
                try {
                    parseConfigFile(mimeappsList, "Default Applications", delegate bool(string key, string value) {
                        if (key.equal("inode/directory") && value.length) {
                            auto app = value;
                            fileManagerArgs = findFileManagerCommand(app, allAppDirs, binPaths);
                            return false;
                        }
                        return true;
                    });
                } catch(Exception e) {

                }

                if (fileManagerArgs.length) {
                    execShowInFileManager(fileManagerArgs, toOpen);
                    return true;
                }
            }

            foreach(mimeinfoCache; allAppDirs.map!(p => buildPath(p, "mimeinfo.cache"))) {
                try {
                    parseConfigFile(mimeinfoCache, "MIME Cache", delegate bool(string key, string value) {
                        if (key > "inode/directory") { //no need to proceed, since MIME types are sorted in alphabetical order.
                            return false;
                        }
                        if (key.equal("inode/directory") && value.length) {
                            auto alternatives = value.splitter(';').filter!(p => p.length > 0);
                            foreach(alternative; alternatives) {
                                fileManagerArgs = findFileManagerCommand(alternative, allAppDirs, binPaths);
                                if (fileManagerArgs.length) {
                                    break;
                                }
                            }
                            return false;
                        }
                        return true;
                    });
                } catch(Exception e) {

                }

                if (fileManagerArgs.length) {
                    execShowInFileManager(fileManagerArgs, toOpen);
                    return true;
                }
            }

            Log.e("showInFileManager -- could not find application to open directory");
            return false;
        } else {
            Log.w("showInFileManager is not implemented for current platform");
        }
    } catch (Exception e) {
        Log.e("showInFileManager -- exception while trying to open file browser");
    }
    return false;
}
