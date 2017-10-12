module dlangui.graphics.iconprovider;

/**
 * Getting images for standard system icons and file paths.
 *
 * Copyright: Roman Chistokhodov, 2017
 * License:   Boost License 1.0
 * Authors:   Roman Chistokhodov, freeslave93@gmail.com
 *
 */

import dlangui.graphics.drawbuf;
import dlangui.core.logger;
import isfreedesktop;

/**
 * Crossplatform names for some of system icons.
 */
enum StandardIcon
{
    document,
    application,
    folder,
    folderOpen,
    driveFloppy,
    driveFixed,
    driveRemovable,
    driveCD,
    driveDVD,
    server,
    printer,
    find,
    help,
    sharedItem,
    link,
    trashcanEmpty,
    trashcanFull,
    mediaCDAudio,
    mediaDVDAudio,
    mediaDVD,
    mediaCD,
    fileAudio,
    fileImage,
    fileVideo,
    fileZip,
    fileUnknown,
    warning,
    information,
    error,
    password,
    rename,
    deleteItem,
    computer,
    laptop,
    users,
    deviceCellphone,
    deviceCamera,
    deviceCameraVideo,
}

/**
 * Base class for icon provider.
 */
abstract class IconProviderBase
{
    /**
     * Get image of standard icon. If icon was not found use fallback.
     */
    final DrawBufRef getStandardIcon(StandardIcon icon, lazy DrawBufRef fallback)
    {
        auto image = getStandardIcon(icon);
        return image.isNull() ? fallback() : image;
    }
    /**
     * Get image of icon associated with file path. If icon was not found use fallback.
     */
    final DrawBufRef getIconForFilePath(string filePath, lazy DrawBufRef fallback)
    {
        auto image = getIconForFilePath(filePath);
        return image.isNull() ? fallback() : image;
    }

    /**
     * Get image of standard icon. Return the null image if icon was not found in the system.
     */
    DrawBufRef getStandardIcon(StandardIcon icon);

    /**
     * Get image of icon associated with file path. Return null image if icon was not found in the system.
     * Default implementation detects icon for a directory and for a file using the list of hardcoded extensions.
     *
     */
    DrawBufRef getIconForFilePath(string filePath)
    {
        // TODO: implement specifically for different platforms
        import std.path : extension;
        import std.uni : toLower;
        import std.file : isDir, isFile;
        import std.exception : collectException;
        bool isdir;
        collectException(isDir(filePath), isdir);
        if (isdir) {
            return getStandardIcon(StandardIcon.folder);
        }
        if (!filePath.extension.length) {
            return getStandardIcon(StandardIcon.fileUnknown);
        }
        switch(filePath.extension.toLower) with(StandardIcon)
        {
            case ".jpeg": case ".jpg": case ".png": case ".bmp":
                return getStandardIcon(fileImage);
            case ".wav": case ".mp3": case ".ogg":
                return getStandardIcon(fileAudio);
            case ".avi": case ".mkv":
                return getStandardIcon(fileVideo);
            case ".doc": case ".docx":
                return getStandardIcon(document);
            case ".zip": case ".rar": case ".7z": case ".gz":
                return getStandardIcon(fileZip);
            default:
                return DrawBufRef(null);
        }
    }
}

/**
 * Dummy icon provider. Always returns null images or fallbacks. Available on all platforms.
 */
class DummyIconProvider : IconProviderBase
{
    override DrawBufRef getStandardIcon(StandardIcon icon)
    {
        return DrawBufRef(null);
    }
    override DrawBufRef getIconForFilePath(string filePath)
    {
        return DrawBufRef(null);
    }
}

version(Windows)
{
    import core.sys.windows.windows;
    enum SHSTOCKICONID {
        SIID_DOCNOASSOC         = 0,
        SIID_DOCASSOC           = 1,
        SIID_APPLICATION        = 2,
        SIID_FOLDER             = 3,
        SIID_FOLDEROPEN         = 4,
        SIID_DRIVE525           = 5,
        SIID_DRIVE35            = 6,
        SIID_DRIVEREMOVE        = 7,
        SIID_DRIVEFIXED         = 8,
        SIID_DRIVENET           = 9,
        SIID_DRIVENETDISABLED   = 10,
        SIID_DRIVECD            = 11,
        SIID_DRIVERAM           = 12,
        SIID_WORLD              = 13,
        SIID_SERVER             = 15,
        SIID_PRINTER            = 16,
        SIID_MYNETWORK          = 17,
        SIID_FIND               = 22,
        SIID_HELP               = 23,
        SIID_SHARE              = 28,
        SIID_LINK               = 29,
        SIID_SLOWFILE           = 30,
        SIID_RECYCLER           = 31,
        SIID_RECYCLERFULL       = 32,
        SIID_MEDIACDAUDIO       = 40,
        SIID_LOCK               = 47,
        SIID_AUTOLIST           = 49,
        SIID_PRINTERNET         = 50,
        SIID_SERVERSHARE        = 51,
        SIID_PRINTERFAX         = 52,
        SIID_PRINTERFAXNET      = 53,
        SIID_PRINTERFILE        = 54,
        SIID_STACK              = 55,
        SIID_MEDIASVCD          = 56,
        SIID_STUFFEDFOLDER      = 57,
        SIID_DRIVEUNKNOWN       = 58,
        SIID_DRIVEDVD           = 59,
        SIID_MEDIADVD           = 60,
        SIID_MEDIADVDRAM        = 61,
        SIID_MEDIADVDRW         = 62,
        SIID_MEDIADVDR          = 63,
        SIID_MEDIADVDROM        = 64,
        SIID_MEDIACDAUDIOPLUS   = 65,
        SIID_MEDIACDRW          = 66,
        SIID_MEDIACDR           = 67,
        SIID_MEDIACDBURN        = 68,
        SIID_MEDIABLANKCD       = 69,
        SIID_MEDIACDROM         = 70,
        SIID_AUDIOFILES         = 71,
        SIID_IMAGEFILES         = 72,
        SIID_VIDEOFILES         = 73,
        SIID_MIXEDFILES         = 74,
        SIID_FOLDERBACK         = 75,
        SIID_FOLDERFRONT        = 76,
        SIID_SHIELD             = 77,
        SIID_WARNING            = 78,
        SIID_INFO               = 79,
        SIID_ERROR              = 80,
        SIID_KEY                = 81,
        SIID_SOFTWARE           = 82,
        SIID_RENAME             = 83,
        SIID_DELETE             = 84,
        SIID_MEDIAAUDIODVD      = 85,
        SIID_MEDIAMOVIEDVD      = 86,
        SIID_MEDIAENHANCEDCD    = 87,
        SIID_MEDIAENHANCEDDVD   = 88,
        SIID_MEDIAHDDVD         = 89,
        SIID_MEDIABLURAY        = 90,
        SIID_MEDIAVCD           = 91,
        SIID_MEDIADVDPLUSR      = 92,
        SIID_MEDIADVDPLUSRW     = 93,
        SIID_DESKTOPPC          = 94,
        SIID_MOBILEPC           = 95,
        SIID_USERS              = 96,
        SIID_MEDIASMARTMEDIA    = 97,
        SIID_MEDIACOMPACTFLASH  = 98,
        SIID_DEVICECELLPHONE    = 99,
        SIID_DEVICECAMERA       = 100,
        SIID_DEVICEVIDEOCAMERA  = 101,
        SIID_DEVICEAUDIOPLAYER  = 102,
        SIID_NETWORKCONNECT     = 103,
        SIID_INTERNET           = 104,
        SIID_ZIPFILE            = 105,
        SIID_SETTINGS           = 106,
        SIID_DRIVEHDDVD         = 132,
        SIID_DRIVEBD            = 133,
        SIID_MEDIAHDDVDROM      = 134,
        SIID_MEDIAHDDVDR        = 135,
        SIID_MEDIAHDDVDRAM      = 136,
        SIID_MEDIABDROM         = 137,
        SIID_MEDIABDR           = 138,
        SIID_MEDIABDRE          = 139,
        SIID_CLUSTEREDDRIVE     = 140,
        SIID_MAX_ICONS          = 175
    };

    private struct SHSTOCKICONINFO {
        DWORD cbSize;
        HICON hIcon;
        int   iSysImageIndex;
        int   iIcon;
        WCHAR[MAX_PATH] szPath;
    };

    private extern(Windows) HRESULT _dummy_SHGetStockIconInfo(SHSTOCKICONID siid, UINT uFlags, SHSTOCKICONINFO *psii);

    class WindowsIconProvider : IconProviderBase
    {
        this()
        {
            import std.windows.syserror;
            _shell = wenforce(LoadLibraryA("Shell32"), "Could not load Shell32 library");
            _SHGetStockIconInfo = cast(typeof(&_dummy_SHGetStockIconInfo))wenforce(GetProcAddress(_shell, "SHGetStockIconInfo"), "Could not load SHGetStockIconInfo");
        }
        ~this()
        {
            if (_shell) {
                FreeLibrary(_shell);
            }
            foreach(ref buf; _cache)
            {
                buf.clear();
            }
        }

        DrawBufRef getIconFromStock(SHSTOCKICONID id)
        {
            if (_SHGetStockIconInfo) {
                auto found = id in _cache;
                if (found) {
                    return *found;
                }
                HICON icon = getStockIcon(id);
                if (icon) {
                    scope(exit) DestroyIcon(icon);
                    auto image = DrawBufRef(iconToImage(icon));
                    _cache[id] = image;
                    return image;
                } else {
                    _cache[id] = DrawBufRef(null); // save the fact that the icon was not found
                }
            }
            return DrawBufRef(null);
        }

        override DrawBufRef getStandardIcon(StandardIcon icon)
        {
            if (_SHGetStockIconInfo) {
                return getIconFromStock(standardIconToStockId(icon));
            }
            return DrawBufRef(null);
        }

    private:
        SHSTOCKICONID standardIconToStockId(StandardIcon icon) nothrow pure
        {
            with(SHSTOCKICONID)
            final switch(icon) with(StandardIcon)
            {
                case document:
                    return SIID_DOCASSOC;
                case application:
                    return SIID_APPLICATION;
                case folder:
                    return SIID_FOLDER;
                case folderOpen:
                    return SIID_FOLDEROPEN;
                case driveFloppy:
                    return SIID_DRIVE35;
                case driveRemovable:
                    return SIID_DRIVEREMOVE;
                case driveFixed:
                    return SIID_DRIVEFIXED;
                case driveCD:
                    return SIID_DRIVECD;
                case driveDVD:
                    return SIID_DRIVEDVD;
                case server:
                    return SIID_SERVER;
                case printer:
                    return SIID_PRINTER;
                case find:
                    return SIID_FIND;
                case help:
                    return SIID_HELP;
                case sharedItem:
                    return SIID_SHARE;
                case link:
                    return SIID_LINK;
                case trashcanEmpty:
                    return SIID_RECYCLER;
                case trashcanFull:
                    return SIID_RECYCLERFULL;
                case mediaCDAudio:
                    return SIID_MEDIACDAUDIO;
                case mediaDVDAudio:
                    return SIID_MEDIAAUDIODVD;
                case mediaDVD:
                    return SIID_MEDIADVD;
                case mediaCD:
                    return SIID_MEDIABLANKCD;
                case fileAudio:
                    return SIID_AUDIOFILES;
                case fileImage:
                    return SIID_IMAGEFILES;
                case fileVideo:
                    return SIID_VIDEOFILES;
                case fileZip:
                    return SIID_ZIPFILE;
                case fileUnknown:
                    return SIID_DOCNOASSOC;
                case warning:
                    return SIID_WARNING;
                case information:
                    return SIID_INFO;
                case error:
                    return SIID_ERROR;
                case password:
                    return SIID_KEY;
                case rename:
                    return SIID_RENAME;
                case deleteItem:
                    return SIID_DELETE;
                case computer:
                    return SIID_DESKTOPPC;
                case laptop:
                    return SIID_MOBILEPC;
                case users:
                    return SIID_USERS;
                case deviceCellphone:
                    return SIID_DEVICECELLPHONE;
                case deviceCamera:
                    return SIID_DEVICECAMERA;
                case deviceCameraVideo:
                    return SIID_DEVICEVIDEOCAMERA;
            }
        }

        HICON getStockIcon(SHSTOCKICONID id)
        {
            assert(_SHGetStockIconInfo !is null);
            enum SHGSI_ICON = 0x000000100;
            SHSTOCKICONINFO info;
            info.cbSize = SHSTOCKICONINFO.sizeof;
            if (_SHGetStockIconInfo(id, SHGSI_ICON, &info) == S_OK) {
                return info.hIcon;
            }
            Log.d("Could not get icon from stock. Id: ", id);
            return null;
        }

        ColorDrawBuf iconToImage(HICON hIcon)
        {
            BITMAP bm;
            ICONINFO iconInfo;
            GetIconInfo(hIcon, &iconInfo);
            GetObject(iconInfo.hbmColor, BITMAP.sizeof, &bm);
            const int width = bm.bmWidth;
            const int height = bm.bmHeight;
            const int bytesPerScanLine = (width * 3 + 3) & 0xFFFFFFFC;
            const int size = bytesPerScanLine * height;
            BITMAPINFO infoheader;
            infoheader.bmiHeader.biSize = BITMAPINFOHEADER.sizeof;
            infoheader.bmiHeader.biWidth = width;
            infoheader.bmiHeader.biHeight = height;
            infoheader.bmiHeader.biPlanes = 1;
            infoheader.bmiHeader.biBitCount = 24;
            infoheader.bmiHeader.biCompression = BI_RGB;
            infoheader.bmiHeader.biSizeImage = size;

            ubyte[] pixelsIconRGB = new ubyte[size];
            ubyte[] alphaPixels	= new ubyte[size];
            HDC hDC = CreateCompatibleDC(null);
            scope(exit) DeleteDC(hDC);

            HBITMAP hBmpOld = cast(HBITMAP)SelectObject(hDC, cast(HGDIOBJ)(iconInfo.hbmColor));
            if(!GetDIBits(hDC, iconInfo.hbmColor, 0, height, cast(LPVOID) pixelsIconRGB.ptr, &infoheader, DIB_RGB_COLORS))
                return null;
            SelectObject(hDC, hBmpOld);

            if(!GetDIBits(hDC, iconInfo.hbmMask, 0,height,cast(LPVOID)alphaPixels.ptr, &infoheader, DIB_RGB_COLORS))
                return null;

            const int lsSrc = width*3;
            auto colorDrawBuf = new ColorDrawBuf(width, height);
            for(int y=0; y<height; y++)
            {
                const int linePosSrc = (height-1-y)*lsSrc;
                auto pixelLine = colorDrawBuf.scanLine(y);
                for(int x=0; x<width; x++)
                {
                    const int currentSrcPos  = linePosSrc+x*3;
                    // BGR -> ARGB
                    const uint red = pixelsIconRGB[currentSrcPos+2];
                    const uint green = pixelsIconRGB[currentSrcPos+1];
                    const uint blue = pixelsIconRGB[currentSrcPos];
                    const uint alpha = alphaPixels[currentSrcPos];
                    const uint color = (red << 16) | (green << 8) | blue | (alpha << 24);
                    pixelLine[x] = color;
                }
            }
            return colorDrawBuf;
        }

        DrawBufRef[SHSTOCKICONID] _cache;
        HANDLE _shell;
        typeof(&_dummy_SHGetStockIconInfo) _SHGetStockIconInfo;
    }

    alias WindowsIconProvider NativeIconProvider;
} else static if (isFreedesktop) {
    import icontheme;
    import std.typecons : tuple;
    import dlangui.graphics.images;
    class FreedesktopIconProvider : IconProviderBase
    {
        this()
        {
            _baseIconDirs = baseIconDirs();
            auto themeName = currentIconThemeName();
            IconThemeFile iconTheme = openIconTheme(themeName, _baseIconDirs);
            if (iconTheme) {
                _iconThemes ~= iconTheme;
                _iconThemes ~= openBaseThemes(iconTheme, _baseIconDirs);
            }
            foreach(theme; _iconThemes) {
                theme.tryLoadCache();
            }
        }

        ~this()
        {
            foreach(ref buf; _cache)
            {
                buf.clear();
            }
        }

        DrawBufRef getIconFromTheme(string name, string context = null)
        {
            auto found = name in _cache;
            if (found) {
                return *found;
            }
            string iconPath;
            try {
                if (context.length) {
                    iconPath = findClosestIcon!(subdir => subdir.context == context)(name, 32, _iconThemes, _baseIconDirs);
                } else {
                    iconPath = findClosestIcon(name, 32, _iconThemes, _baseIconDirs);
                }
            } catch(Exception e) {
                Log.e("Error while searching for icon", name);
                Log.e(e);
            }

            if (iconPath.length) {
                auto image = DrawBufRef(loadImage(iconPath));
                _cache[name] = image;
                return image;
            } else {
                _cache[name] = DrawBufRef(null);
            }
            return DrawBufRef(null);
        }

        override DrawBufRef getStandardIcon(StandardIcon icon)
        {
            auto t = standardIconToNameAndContext(icon);
            return getIconFromTheme(t[0], t[1]);
        }

    private:
        auto standardIconToNameAndContext(StandardIcon icon) nothrow pure
        {
            final switch(icon) with(StandardIcon)
            {
                case document:
                    return tuple("x-office-document", "MimeTypes");
                case application:
                    return tuple("application-x-executable", "MimeTypes");
                case folder:
                    return tuple("folder", "Places");
                case folderOpen:
                    return tuple("folder-open", "Status");
                case driveFloppy:
                    return tuple("media-floppy", "Devices");
                case driveRemovable:
                    return tuple("drive-removable-media", "Devices");
                case driveFixed:
                    return tuple("drive-harddisk", "Devices");
                case driveCD:
                    return tuple("drive-optical", "Devices");
                case driveDVD:
                    return tuple("drive-optical", "Devices");
                case server:
                    return tuple("network-server", "Places");
                case printer:
                    return tuple("printer", "Devices");
                case find:
                    return tuple("edit-find", "Actions");
                case help:
                    return tuple("help-contents", "Actions");
                case sharedItem:
                    return tuple("emblem-shared", "Emblems");
                case link:
                    return tuple("emblem-symbolic-link", "Emblems");
                case trashcanEmpty:
                    return tuple("user-trash", "Places");
                case trashcanFull:
                    return tuple("user-trash-full", "Status");
                case mediaCDAudio:
                    return tuple("media-optical-audio", "Devices");
                case mediaDVDAudio:
                    return tuple("media-optical-audio", "Devices");
                case mediaDVD:
                    return tuple("media-optical", "Devices");
                case mediaCD:
                    return tuple("media-optical", "Devices");
                case fileAudio:
                    return tuple("audio-x-generic", "MimeTypes");
                case fileImage:
                    return tuple("image-x-generic", "MimeTypes");
                case fileVideo:
                    return tuple("video-x-generic", "MimeTypes");
                case fileZip:
                    return tuple("application-zip", "MimeTypes");
                case fileUnknown:
                    return tuple("unknown", "MimeTypes");
                case warning:
                    return tuple("dialog-warning", "Status");
                case information:
                    return tuple("dialog-information", "Status");
                case error:
                    return tuple("dialog-error", "Status");
                case password:
                    return tuple("dialog-password", "Status");
                case rename:
                    return tuple("edit-rename", "Actions");
                case deleteItem:
                    return tuple("edit-delete", "Actions");
                case computer:
                    return tuple("computer", "Devices");
                case laptop:
                    return tuple("computer-laptop", "Devices");
                case users:
                    return tuple("system-users", "Applications");
                case deviceCellphone:
                    return tuple("phone", "Devices");
                case deviceCamera:
                    return tuple("camera-photo", "Devices");
                case deviceCameraVideo:
                    return tuple("camera-video", "Devices");
            }
        }

        DrawBufRef[string] _cache;
        string[] _baseIconDirs;
        IconThemeFile[] _iconThemes;
    }
    alias FreedesktopIconProvider NativeIconProvider;
} else {
    alias DummyIconProvider NativeIconProvider;
}
