# AGENTS.md — DlangUI

Notes for AI agents and contributors working on this repository.

**Development environment.** The environment notes here (building, testing, GUI checks) come from a Windows host with
WSL2 (Ubuntu): Linux builds, unit tests and X11 checks run in WSL, Windows builds and GUI checks run on the host from
the same shell (WSL interop, PowerShell). Notes for other setups (pure Linux, macOS) may be added later.
Machine-specific details (paths, helper scripts) belong in an untracked `AGENTS.local.md`; maintainers may also keep
local work notes (`PLAN.md`, `BACKLOG.md`, `WORDWRAP.md`) out of git.

## Project overview

DlangUI is a cross-platform GUI library for the D programming language.

- Original author: Vadim Lopatin (`buggins`). Repository: https://github.com/buggins/dlangui
- The DUB package `dlangui` was owned by **Grim Maple** (`GrimMaple`); since 2026-11-24 the owner has access again and the GitHub webhook is configured: pushed tags reach code.dlang.org automatically (then listed up to 0.21.1; check with `curl -s https://code.dlang.org/api/packages/dlangui/latest`).
- GitHub collaborators: `and3md`, `GrimMaple`, `shiche`.
- License: Boost 1.0 (`LICENSE.txt`). Default theme icons have their own license (`LICENSE_default_theme_icons.txt`).
- Current version: **v0.25.1** (tagged 2026-11-28 on 998b24cf, annotated tag, release issue #1297, PR #1298; v0.25.0 on c6423887; v0.24.0 on 994713a3; v0.23.0 on 09111f47; v0.22.0 on d0195a31; v0.21.1 on ec6ccc27; v0.21.0 on d88b9d71; v0.20.0 on 9a5ce859; v0.19.0 on 3164e4f2; v0.18.0 on 3e535fd3; v0.17.1 on 82524e8f; v0.17.0 on bb9bd515; v0.16.1 on 26460bf2; v0.16.0 on 320c3092; v0.15.0 on 67b9ea5d; v0.14.0 on 41b0cc68; v0.13.1 on 3eb2a958; v0.13.0 on 72f9e955; v0.12.1 on 4b3f9330; v0.12.0 on 6055445c, v0.11.3 on 6c4d801c, v0.11.2 on c8e72402, v0.11.1 on 78ebe5cb, v0.11.0 on d80a2043). code.dlang.org needs ~4-40 min to list a new tag (v0.23.0: ~6 min; v0.25.0, v0.25.1: ~4 min). GitHub release notes start with a `## DlangUI vX.Y.Z` heading (the release issue holds the same notes). `views/DLANGUI_VERSION` must be updated by hand before tagging.
- Design is mostly inspired by the Android UI API: two-phase layout (measure, then layout), styles and themes,
  nine-patch images, XML state drawables, `layoutWidth`/`layoutHeight` set to `FILL_PARENT`/`WRAP_CONTENT`, and `layoutWeight`.
- The library started as a D port, with heavy refactoring, of the C++ OpenGL UI framework from the Cool Reader project.
- It is **not thread safe**. All UI work must happen on the UI thread. From other threads, use
  `Window.executeInUiThread(delegate)` or `Window.postEvent(CustomEvent)`.

## Workflow rules (mandatory)

- **Every change needs a GitHub Issue and a Pull Request.** Never commit directly to `master`.
  (Repo setting since 2026-11-08: PR branches are deleted automatically on merge.)
  1. Create an issue with `gh issue create`, or reuse an existing one.
  2. Work on a feature branch.
  3. Open a PR into `master` that references the issue (`Fixes #N`).
- **Code review before each commit.** AI agents run a code review (Claude Code: `/code-review medium`) on the
  pending changes before committing. If it reports findings that should be fixed, list them for the user (with your verdict: confirmed or
  not, fix now or separate issue) and ask which ones to apply before committing. Findings left for later get their
  own issues.
- PRs are created as drafts. Changes made with an AI agent say so: commit messages end with a `Co-Authored-By:`
  line for the agent, PR bodies with a "Generated with" line.
- CI (`.github/workflows/pipeline.yml`) runs on pushes and PRs to `master`. 9 build jobs, a `dip1000` job and a `dscanner` job. Build jobs:
  - {ubuntu, windows} × {dmd-latest, ldc-latest}
  - ubuntu dmd-2.100.2, ubuntu-24.04 ldc-1.30.0, windows dmd-2.100.2 (minimum frontend)
  - ubuntu-24.04 ldc-1.36.0 (Ubuntu 24.04's LDC; old LDC binaries need libxml2.so.2, missing on ubuntu-latest = 26.04 since Nov 2026, #890)
  - macos ldc-latest (arm64)
  Steps: `dub test` in `examples/helloworld`, `dub test`, `dub test -c console` (#1051: console-only code and the
  terminal key/mouse parsing tests), then example1, dmledit and tetris built in the default and
  `console` configurations (`dub build --root=examples/<name>`); Windows also builds them with `-c sdl`, Ubuntu with
  `-c x11` (after `apt-get install libx11-dev libglx-dev`).
  The `dip1000` job (#907; ubuntu dmd/ldc-latest, windows dmd-latest) adds build types `unittest-dip1000` and
  `debug-dip1000` (`-preview=dip1000`) to `dub.json` for the run, then `dub test -b unittest-dip1000` and the library
  configs with `-b debug-dip1000`. Build type flags apply to all packages (needed: the flag changes attribute
  inference and the mangled names of template instances shared with dependencies, e.g. inilike; root-only dflags
  fail to link with dmd 2.114). Locally: same sed line as the CI step, run, restore `dub.json`; never commit it.
  To reproduce dmd 2.114 link errors, install it into a temporary directory (`install.sh -p <dir> install
  dmd-2.114.0`); LDC 1.36 doesn't show them.
  `@safe` work (#907, Nov 2026): virtual methods, interfaces and delegate types get no new attributes (classes
  nothing subclasses may be made `final`: Tokenizer, MLParser); `@trusted` only in small helpers with a comment why
  (casts of new arrays to immutable, calloc/free with a single owner, calls into known concrete streams). `Log.*`
  is callable from `@safe` code when the arguments are (#931); exceptions (`Throwable.toString`) are `@system`.
  Old compilers (DMD 2.100.2, LDC 1.30) warn about discarded results of `pure` calls: a real bug every time so far.
  A separate `dscanner` job runs D-Scanner with `dscanner.ini` and fails on any warning (#906). Run it locally before
  committing: `dub run dscanner@0.16.0-beta.5 -- --styleCheck --config dscanner.ini src`. Suppress an intended case
  with `@("nolint(<check key>)")` on the declaration (function, class, module), with a comment why; nolint doesn't
  work for unused variables: name RAII guards `_` (`auto _ = ClipRectSaver(...)`).
  **TODO (recurring): the pin is a pre-release.** Check for a D-Scanner release (`gh release list -R
  dlang-community/D-Scanner -L 3`) and move CI, `dscanner.ini` and this note to it when 0.16.0 is out.
  DUB packages are cached (`actions/cache`, key: OS, compiler, hash of all `dub.json`, month), so code.dlang.org
  outages only matter on a cold cache; then rerun the failed jobs (`gh run rerun <id> --failed`).
- Code style: follow the [D Style](https://dlang.org/dstyle.html) (see `CODING_STYLE.md`).
  - Indent with 4 spaces, never tabs.
  - Class names are `CamelCase`. Methods and properties are `camelCase`. Private and protected fields are `_camelCase`.
  - PRs that only change styling will **not** be merged. Restyling code you are already changing is fine.
- `AGENTS.md` is tracked (since 2026-11-28; untracked before). `AGENTS.local.md`, `PLAN.md`, `BACKLOG.md` and
  `WORDWRAP.md` are local files (`.git/info/exclude`): never commit them.

## Building and testing

The minimum compiler frontend is DMD 2.100.2.

Reference environment (WSL2): LDC 1.36.0 (frontend 2.106) and DUB 1.36.0 installed system-wide; a DMD installed with
the dlang `install.sh` into the home directory (`source ~/dlang/dmd-<version>/activate` in the same shell command, then
`--compiler=dmd`). On the Windows host: a D compiler and git.

```sh
dub build                 # library, "default" configuration -> lib/libdlangui.a
dub build -c x11          # another configuration (see table below)
dub test                  # unittests (config dlangui-test-default)
cd examples/example1 && dub build        # demo app; binary goes to examples/example1/bin/
dub run dlangui:example1                 # run a sub-package from the repo root
```

Baseline status on 2026-11-04 (LDC 1.36, Linux/WSL2):

| Command | Result |
|---|---|
| `dub build` (default) | OK, about 9 s |
| `dub build -c x11` | OK |
| `dub test` | OK |
| `examples/example1`: `dub build` | OK |
| `examples/helloworld`: `dub build -c console` | OK |
| `examples/example1`: `dub build -c console` | OK (fixed since; built in CI) |

Unittests live in many modules (`dub test`: "37 modules passed unittests" in Nov 2026), among them:
- `core/types.d`, `core/collections.d`, `core/signals.d`, `core/linestream.d`, `core/files.d`, `core/math3d.d`
- `widgets/styles.d`
- `graphics/fonts.d`: test font and font manager classes (presence cache, fallback lists, cache GC, glyph lookup,
  default fallback faces, FontList)

There are no GUI or integration tests. Testing tips:
- Check that a new unittest really runs to its end: some tests return early (e.g. the font lookup test needs
  `FontManager.instance` to be null). Temporarily put `assert(0, "REACHED")` at the end and look for it in the output.
- For a regression test, check that it fails with the old code (temporarily revert the fix).
- Unittests that create widgets need a theme: `import dlangui.widgets.styles : useTestTheme; auto _ = useTestTheme();`
  (#987, PR #994; sets the default theme only if none is set, removes it at scope end). `ScrollBar.measure()` loads
  images and crashes without the image cache: lay out without measuring, or use a test subclass with a fixed `measure()`
  (scroll.d #985 test).
- Editors (EditBox, EditLine) can't be created in unittests: there is no `FontManager.instance`, and setting the
  text measures it (segfault in `Style.font`). Put the logic into static functions and test those (#1145:
  `forEachLineMatch`, `currentMatchIndex`, `nextMatchIndex`). Tests that need drawables swap in a temporary
  `_drawableCache`/`_imageCache` (resources.d tests, #1160); ImageCache doesn't exist in console builds.
  `SourceEdit` crashes already in its constructor (checked for #1291); test `EditableContent` directly.
- `EditableContent` file tests (#1276-#1294): `version(unittest)` hooks `EditableContent.testHookAfterRead`
  (called after each read in `load()`; change the file there, or throw `ErrnoException`/`Exception` to reach the
  error paths) and `dlangui.core.files.safeWriteTestHook` (throw to simulate a failed save). Set a throwing hook
  only around the call under test (precondition loads run it too) and reset it in `scope(exit)`.
- Mutation checks: disable exactly the added line (`git diff -U0` gives its number); the same text can exist
  elsewhere in the file (a #1282 mutation hit an older identical line and passed).
- Theme changes (#1160): `Platform.onThemeChanged()` clears the caches and refreshes `currentTheme`, then
  calls `dispatchThemeChanged()` for every window through the abstract `forEachWindow()`, which each backend
  implements from its window list (#1173, PR #1216; a custom `external` backend must implement it too).
- `version (Windows)` / `version (OSX)` code is compiled and unit-tested only on that platform: run `dub test` on
  Windows too (see Windows checks below); macOS is covered only by CI. Say in the PR what was not verified.
- GUI checks:
  - Linux (WSLg): the X11 test tools may see no app windows at all; then render headlessly
    with a small test app that draws with `Font.drawText` into a `ColorDrawBuf` and writes the pixels
    (PPM -> PNG).
  - X11 checks without touching the user's display (packages xvfb, x11-xserver-utils, x11-apps):
    a private server `Xvfb :99 -screen 0 1280x800x24 -nolisten tcp -noreset`, apps run with `DISPLAY=:99`. Without a
    window manager the X11 backend dies with BadAtom (#1181): create the `_NET_WM_*` atoms on :99 first (a small ctypes
    script calling `XInternAtom`). Screenshots: `xwd -root` -> PNG (a small converter, no PIL needed); close the
    app normally with a `WM_DELETE_WINDOW` ClientMessage to the windows on :99 (a small ctypes script). `Xft.dpi` on
    :99 only: `echo "Xft.dpi: 144" | DISPLAY=:99 xrdb -merge`. gdb can't attach (ptrace_scope); start under gdb.
    Window manager on :99 only: `DISPLAY=:99 openbox &` (package openbox). Window states (#1190, PR #1199):
    X11 records maximized/minimized/fullscreen/normal only when the WM reports them (`wmState()` reads
    `_NET_WM_STATE`), so compare `windowState` with the WM's truth: a small script that prints ICCCM
    `WM_STATE` and `_NET_WM_STATE` of our window on :99. Without a WM, these requests return false.
    Unmapped windows (#1197, PR #1208): states requested before `show()` or while hidden go into `_NET_WM_STATE`
    (only if the WM lists it in `_NET_SUPPORTED`) and WM_HINTS initial_state; a hidden window is mapped at once in
    the requested state. Restore within 2 s of an iconify request maps again when the iconify is reported (#1198).
    Test with a hook that logs "TEST: <action> returned" and sample the WM truth 1.2 s after each such log line
    (fixed-time sampling drifted and gave false alarms). Simulate WMs that ignore REMOVE HIDDEN (mutter, KWin) by
    commenting out that message temporarily. Open X11 follow-ups: #1203-#1207 (twm/ICCCM-only: #1207).
  - Runtime DPI changes (#1162, #1163, PR #1183): `Platform.setSystemScreenDpi()` reloads the theme and lays out on a
    change. X11 watches RESOURCE_MANAGER on screen 0's root (applied in the outermost `pumpEvents()`), resizes normal
    windows by the ratio. Win32 is per-monitor v2 aware: `WM_GETDPISCALEDSIZE` answers the size (requested size in
    `setWindowState()`, else client scaled from the window's `_sizeDpi` to the new SCREEN_DPI), `WM_DPICHANGED`
    applies the suggested rect. Test Win32 with a hook sending both messages to example1's own window. SCREEN_DPI is
    global (per-window DPI: #1184; open points: #1185, #1187).
  - example1's window title is `<tab name> - dlangui example 1` (e.g. "Controls - dlangui example 1").
  - Debug builds report leaks at exit ("Non-zero ... instance count", "Resource leak: destroying resource while
    shutdown!"). Every GUI check ends with closing the app and looking for them (`ui.log` on Windows).
  - Objects holding resources (widgets, drawables, fonts, draw buffers, styles, windows, caches) must be destroyed
    explicitly: destruction by the GC is a leak (#975). It is logged in all builds as "Resource leak: destroyed by
    the GC, not explicitly: <class> [id]" (first 20, then one "(more are not reported)" line; Log.* calls from GC
    finalizers: "Log call in a destructor run by the GC skipped"). `dub test` prints "Resource leak: N objects
    holding resources destroyed by the GC after the unittests" at exit. **Before each commit**: `dub test` output and
    the app's log (GUI checks) must have no "Resource leak", "instance count" or "destroyed by the GC" lines.
  - Destructors: `if (destroyedByGC(this.classinfo.name)) return;` in the class where a resource hierarchy's
    destructor chain ends (Widget, RefCountedObject, Style, Window, Platform, FontManager, ImageCache, DrawableCache);
    `if (inGCFinalizer()) return;` first in every other destructor (classes and structs) that touches other objects,
    OS/GL handles or logs (struct field destructors run even after an early return: Ref, ObjectList, font lists).
    Freeing own malloc memory is fine. `Ref` doesn't release in a GC finalizer: a shared object (cached font,
    drawable) referenced by a leaked one stays alive and is reported too; fix the first reported leak. A unittest that
    leaks on purpose uses a thread (no stack refers to the objects after join), collects first, and saves/restores
    the counters (`muteLeakReports()`/`restoreLeakReportCounters()`) so later leaks are still named. In `dub test`
    (no log file) the leak reports go to stderr.
- Console checks (tmux): console apps log to `ui.log` in their working directory, not stderr. Leak checks need a
  normal exit (dmledit: click File, then Exit; helloworld: its Cancel button), not `tmux kill-session`. Ctrl+H
  arrives as Backspace and there is no CSI-u parsing: open panels through a temporary hook in the example
  (e.g. `ed.dispatchAction(ACTION_EDITOR_REPLACE)` after `window.show()`, never committed).
- If gdc is installed besides ldc2/dmd, dub may pick it (seen for `dub test`, example builds and `dub run dscanner`)
  and fail: pass `--compiler=ldc2` (or `dmd`) to every dub command.
- Fonts without installing them on Linux: a private fontconfig config via `FONTCONFIG_FILE`, which includes
  `/etc/fonts/fonts.conf` and adds `<dir>` entries with downloaded fonts. Distributions ship Noto CJK as .ttc
  collections (NotoSansCJK-Regular.ttc, face 0 = JP); test with those, not with single .otf files.
- Windows checks: a second checkout on the Windows host (`<win-work>\dlangui`, next to `<win-work>\dlangide`) is
  built with the Windows DMD from WSL (`cmd.exe /c <script>.bat`, `powershell.exe -NoProfile -ExecutionPolicy Bypass
  -File <script>.ps1`); copy changed files there converted to CRLF (git autocrlf), so scripted patches must match
  `\r\n`. GUI input comes from a small PowerShell helper that finds our app's window by its exact title and posts
  messages to it (`PostMessage`: mouse clicks in client coordinates, key presses, any message), takes screenshots of
  that window only and closes it; it never activates or touches other windows. WSL interop sometimes fails with
  `UtilAcceptVsock ... accept4 failed 110`; retry. Machine-specific script names go to `AGENTS.local.md`.
  - `git pull` the Windows checkouts before testing; they lag behind master. Check that the build succeeded before
    starting the app: a failed build leaves the old exe, which then runs (#623 test). Reset them afterwards
    (`git checkout -- .`).
  - Posted input: clicks work on tabs, menus, editor text and tree items (a click only selects; a posted Enter
    opens the item or settings page). In DlangIDE posted clicks don't press Buttons (toolbar, message bar, dialog
    buttons; in dmledit they did): press a dialog's default button with a posted Enter, move the focus with Tab; for
    message bar buttons add a temporary key hook to the editor in the Windows copy (e.g. F9/F11/F12 ->
    `onMessageAction(bar, externalChangeActions(_externalChangeShown)[i])`). Typing with .NET `SendKeys` (it
    activates our window) can't send Ctrl+letter (Ctrl+S/F/H/R): use menus; `^{END}` works.
  - Window activation without touching other windows: post `WM_ACTIVATE` with wParam 0, then 1; it runs
    focus-triggered code such as the EditBox external change check.
  - DlangIDE's toolbar Save is disabled while the editor doesn't have the focus; File > Save works.
  - WSL's `/mnt/c` can briefly show a stale state of a file Windows just replaced or deleted: check with
    PowerShell `Test-Path`.
  - dmledit opens no file at start: a temporary hook `(cast(EditFrame)window.mainWidget).openSourceFile(path);`
    after `window.show()` (Windows copy only); its window title is then the path.
  - Privacy: file dialog screenshots show the Windows user folder in the places list: crop them.

### DUB configurations (root `dub.json`)

The backend and features are chosen at compile time with D `version` identifiers. `src/dlangui/core/config.d` maps
those identifiers to compile-time `enum bool` flags:
- `BACKEND_SDL`, `BACKEND_X11`, `BACKEND_WIN32`, `BACKEND_DSFML`, `BACKEND_ANDROID`, `BACKEND_CONSOLE`
- `BACKEND_GUI`, `ENABLE_OPENGL`, `ENABLE_FREETYPE`, `WIDGET_STYLE_CONSOLE`

Code branches on these flags with `static if`.

| Config | Versions | Backend | Notes |
|---|---|---|---|
| `default` | `USE_OPENGL`, `EmbedStandardResources`, `GL_32`; posix: `USE_SDL`, `USE_FREETYPE`, `SDL_205`; win: `Unicode` | **Win32** on Windows (because there is no `USE_*` backend version), **SDL2** on posix | bindbc-opengl, bindbc-freetype, bindbc-sdl |
| `sdl` | `USE_SDL`, `USE_OPENGL`, `USE_FREETYPE`, … | SDL2 on every platform | copies `SDL2.dll` and `libfreetype-6.dll` on Windows |
| `x11` | `USE_X11`, `USE_FREETYPE`, `USE_OPENGL`, `GL_32` | Native X11 + GLX | deps `x11`, `glx-d` |
| `sfml` | `USE_DSFML`, … | DSFML | likely bit-rotted |
| `console` | `USE_CONSOLE` | ANSI or Win32 text console (`platforms/ansi_console`) | no OpenGL or FreeType; uses console theme and resources |
| `minimal` | `NO_OPENGL`, `ForceLogs`, … | SDL on posix, Win32 on Windows | no OpenGL |
| `external` | `USE_EXTERNAL` | user-supplied | needs `external_cfg.d` in the app's string-import path to define the config enums; `platforms/external/externalapp.d` is a stub |

Android uses `USE_ANDROID` (or `version(Android)`) and is built with makefiles and Gradle, not DUB. See below.

Other version identifiers:
- `NO_OPENGL`, `NO_FREETYPE`
- `ForceLogs`
- `EmbedStandardResources`
- `GL_32` (GL 3.2 core profile; this is the default `Platform.GLVersionMajor/Minor` of 3.2)
- `SDL_205` (#1114; was `SDL_204`): bindbc-sdl 1.4 lists `SDL_DuplicateSurface` (SDL 2.0.6) for 2.0.5, so SDL 2.0.5
  (the shipped DLL) loads as "bad library"; dlangui accepts it if the essential functions are there
  (`sdlCheckMissingSymFunc`) and checks optional ones with `sdlHasFunction("SDL_...")` before calling them
- `ENABLE_PROFILING` (Windows `main` instead of `WinMain`)

Dependencies:
- `inilike`, `icontheme`, `arsd-official:dom` (XML), `arsd-official:image_files` (PNG/JPEG decoding); arsd `~>12.1` since #746 (arsd.dom has its own `strip`: import `std.string : strip` selectively where both are imported)
- `bindbc-opengl`, `bindbc-freetype`, `bindbc-sdl`
- `x11`, `glx-d`, `dsfml` (only for some configs)
- Linux links `libz`. Windows links `ole32`, plus `opengl32` and `user32` depending on config.
- bindbc-freetype 1.3+ and bindbc-sdl 1.5+ (bindbc-common 1.x) don't compile with DMD 2.100.2 (named arguments); keep `~>1.2.4` / `~>1.4.5` unless the minimum frontend is raised. bindbc-sdl 2.x is SDL3.
- Shared libraries loaded at runtime: SDL2, FreeType, OpenGL, fontconfig. FreeType falls back to `libfreetype.so.6` (bindbc-freetype tries only `libfreetype.so`, BindBC/bindbc-freetype#22). On Windows bindbc-freetype tries only `freetype.dll`/`freetype-6.dll`; dlangui ships `libfreetype-6.dll` (FreeType 2.8.1, lacks 3 CID functions → `badLibrary`), so Windows FreeType never loaded until PR #826 (#825). Release builds on Windows don't log; use a debug build to see `ui.log`.

## Repository layout

```
dub.json                 root package (staticLibrary, targetPath lib/), configs, subPackages = examples
src/win_app.def          obsolete (OMF/OPTLINK only, -m32omf): APP_ENTRY_POINT's WinMain makes GUI programs (#962)
src/dlangui/             library sources (~65k lines of D)
  package.d              `import dlangui;` public-imports the commonly used modules
  core/                  types, events, signals, collections, logger, i18n, settings, files, editable text model, streams, math3d, async sockets
  graphics/              DrawBuf (software and GL), colors, fonts (FreeType, Win32), resources/drawables, images, icon providers, glsupport, xpm, scene/ (3D engine)
  widgets/               all widgets, layouts, styles/themes, DML widget registration
  dialogs/               Dialog base, file dialog, message box, input box, settings dialog
  dml/                   DML (DlangUI Markup Language) tokenizer, parser, syntax highlighter
  platforms/common/      platform.d (abstract Window and Platform, APP_ENTRY_POINT), startup.d (init of fonts, logs and resources)
  platforms/sdl/         SDL2 backend
  platforms/windows/     Win32 backend (+ GDI fonts and draw buffer, optional WGL OpenGL)
  platforms/x11/         native X11 backend (+ GLX)
  platforms/dsfml/       SFML backend
  platforms/android/     Android NativeActivity backend (EGL/GLES)
  platforms/ansi_console/ text-mode backend (ANSI terminals and Windows console)
  platforms/external/    stub for a user-provided backend
3rdparty/                bundled bindings: EGL, GLES/GLES2/GLES3, android NDK headers, fontconfig, jni.d, isfreedesktop.d
views/                   string-import path
  DLANGUI_VERSION        version string, returned by DLANGUI_VERSION(); update by hand before tagging a release
  standard_resources.list, console_standard_resources.list   resources embedded by EmbedStandardResources
  res/                   themes (theme_default.xml, theme_dark.xml, console_theme_default.xml), state-drawable XMLs,
                         .9.png nine-patches, .tim console images, mdpi/ and hdpi/ icons, i18n/std_{en,ru,pl}.ini, shaders/
examples/                sample apps (listed below)
android/                 Android build support (android_project template, LDC armv7a makefile, dlangui_source_files.mk)
libs/windows/{x86,x86_64}/  prebuilt SDL2.dll and libfreetype-6.dll copied by DUB on Windows
lib/                     build output (libdlangui.a; ignored by git)
params.json, project.ddoc  GitHub Pages and ddox doc generation leftovers
```

### Examples (`examples/`)

Registered as root `subPackages`, so they run as `dub run dlangui:<name>`:
- `helloworld`: DML form
- `example1`: widget gallery; the CI target
- `dmledit`: DML editor with live preview
- `d3d`: 3D scene
- `dminer`: Minecraft-like voxel 3D demo
- `tetris`
- `ircclient`
- `spreadsheet`
- `dragon`: drawing, with a console config

Not registered as subPackages:
- `bezier`, `themetest`
- `editlinelist` (its `dub.json` was fixed in #748)
- `android`: Gradle project
- `derelictcocoatest-monod-osx`: obsolete

Most examples also carry stale Visual D (`.visualdproj`) and Mono-D (`.dproj`) project files.

## Core API

### Application entry point

```d
import dlangui;
mixin APP_ENTRY_POINT;          // generates main()/WinMain that calls the backend's DLANGUImain

extern (C) int UIAppMain(string[] args) {
    Platform.instance.uiTheme = "theme_default";   // optional, this is the default
    Window window = Platform.instance.createWindow("Title", null /*parent*/, WindowFlag.Resizable, 800, 600);
    window.mainWidget = parseML(q{ VerticalLayout { TextWidget { text: "Hello" } } });
    window.show();
    return Platform.instance.enterMessageLoop();
}
```

The backend's `DLANGUImain` (or `DLANGUIWinMain` on Windows) starts the app. It runs, in order:
1. `initLogs()`
2. `initResourceManagers()` (font manager, image and drawable caches, standard widget registration for DML)
3. creates the backend `Platform` and calls `Platform.setInstance`
4. calls the user's `UIAppMain`
5. tears everything down, then calls `releaseResourcesOnAppExit()`, which reports leaked ref-counted objects

The declarations live in `platforms/common/platform.d`. The implementations live in `platforms/common/startup.d` and in each backend's `*app.d`.

### Platform and Window (`platforms/common/platform.d`)

**`Platform`** is abstract. The singleton is `Platform.instance`, also available as the `platform` property.
- Abstract members:
  - `createWindow`, `closeWindow`, `enterMessageLoop`
  - clipboard: `hasClipboardText`, `getClipboardText`, `setClipboardText` (`mouseBuffer` selects the X11 primary selection)
  - `requestLayout`
- Settings:
  - `uiLanguage` (i18n code), `uiTheme` (theme resource id)
  - `resourceDirs` (search paths for external resources)
  - `uiDialogDisplayMode` (dialogs as windows or as in-window popups)
  - `defaultWindowIcon`, `iconProvider`
- `openURL`, `showInFileManager`
- OpenGL: `GLVersionMajor` and `GLVersionMinor` (default 3.2), `multisamples` (not on Linux)

**`Window`** is abstract and implements `CustomEventTarget`.
- Abstract members:
  - `show`, `close`, `invalidate`
  - `windowCaption`, `windowIcon`
- Content: `mainWidget`
- Window state: `setWindowState` / `maximizeWindow` / `minimizeWindow` / `moveWindow` / `resizeWindow`,
  `windowState`, `windowRect`, `saveWindowState` / `restoreWindowState` (to `Setting`)
- Focus: `focusedWidget`, `setFocus`
- Popups and tooltips: `showPopup` / `removePopup`, `showTooltip`
- Dialog helpers: `showMessageBox`, `showInputBox`
- Timers: `setTimer(widget, ms)` / `cancelTimer`; the target gets `Widget.onTimer(id)`
- Cross-thread: `postEvent`, `executeInUiThread`
- Mouse cursor: `overrideCursorType`
- Callbacks: `onCanClose`, `onClose`, `onFilesDropped`; signals `windowStateChanged`, `windowActivityChanged`
- Sizing: `windowOrContentResizeMode` (shrink widgets / resize window / scroll content)
- Window flags (`WindowFlag`): `Resizable`, `Fullscreen`, `Modal`, `MeasureSize`, `Borderless`, `ExpandSize`

### Widgets (`widgets/widget.d`)

- `Widget` is the base class.
- `WidgetGroup` adds children. `WidgetGroupDefaultDrawing` draws its children automatically.
- Identity and lookup: `id`, `childById!T("id")`
- Style: `styleId`. Most visual properties are style-backed: margins, padding, colors, font, alignment, min/max size,
  `layoutWidth`, `layoutHeight`, `layoutWeight`.
  - Setters return `Widget`, so calls can be chained:
    `new Widget("id").layoutWidth(FILL_PARENT).padding(Rect(4,4,4,4))`.
  - Changing a style-backed property makes the widget its own copy of the style (`ownStyle`).
- State: a `State` bitset (Focused, Pressed, Hovered, Checked, Enabled, Selected, …). `visibility` is Visible, Invisible or Gone.
  Other flags: `enabled`, `checkable`, `clickable`, `focusable`, `tabOrder`, `focusGroup`.
- Layout follows a two-phase protocol:
  1. `measure(parentWidth, parentHeight)` sets the measured size through `measuredContent`.
  2. `layout(Rect)` assigns the final rectangle.
  3. `onDraw(DrawBuf)` draws the widget.
  - Call `requestLayout()` or `invalidate()` when something changes.
  - Special sizes: `FILL_PARENT`, `WRAP_CONTENT`, and `makePercentSize`.
  - Units in DML and themes: px, pt, %, …
- Events: `onMouseEvent`, `onKeyEvent`, `onEvent(CustomEvent)`, `onTimer`, `animate(interval)` (when `animating` is true).
- Actions and menus:
  - `Action` (in `core/events.d`) has an id, label, icon and accelerators.
  - `handleAction` and `dispatchAction` route actions. `updateActionState` drives the enabled and checked state of menus and toolbars.
  - Standard actions live in `core/stdaction.d` and `dialogs/dialog.d` (`ACTION_OK`, …).
- Signals (`core/signals.d`): `Signal!Interface` and `Listener!Interface` fields such as `click`, `checkChange`, `focusChange`,
  `keyEvent`, `mouseEvent`, `onAction`.
  - Assign a delegate: `btn.click = delegate(Widget w) { …; return true; };`
  - Or add one: `btn.click.connect(...)`, `addOnClickListener(...)`.
- Text is `dstring` (UTF-32) throughout the UI API. `UIString` holds either a raw string or a translatable resource id.
- Ownership: a parent owns and destroys its children (`ObjectList`). Resources (`DrawBuf`, `Font`, `Drawable`) are
  ref-counted with `Ref!T`: `DrawBufRef`, `FontRef`, `DrawableRef`.

Widget catalog, by module:

| Module | Widgets |
|---|---|
| `controls.d` | TextWidget, MultilineTextWidget, Button, ImageWidget, ImageButton, ImageCheckButton, ImageTextButton, LinkButton, UrlImageTextButton, CheckBox, RadioButton, SwitchButton, CanvasWidget, HSpacer, VSpacer |
| `layouts.d` | LinearLayout, VerticalLayout, HorizontalLayout, FrameLayout, TableLayout, ResizerWidget |
| `editors.d` | EditLine, EditBox, LogWidget, SpinCtrl, FindPanel; EditWidgetBase uses `core/editable.d` (EditableContent, undo, syntax highlight hooks) |
| `srcedit.d` | SourceEdit (code editor) |
| `lists.d` | ListWidget, StringListWidget, ListAdapter family |
| `grid.d` | GridWidgetBase, StringGridWidget, adapters |
| `tree.d` | TreeWidget, TreeItem |
| `tabs.d` | TabWidget, TabControl, TabHost |
| `menu.d` | MainMenu, PopupMenu, MenuItem |
| `combobox.d` | ComboBox, ComboEdit, IconTextComboBox |
| `scroll.d` / `scrollbar.d` | ScrollWidget, ScrollWidgetBase, ScrollBar, SliderWidget |
| `docks.d` | DockHost, DockWindow |
| `appframe.d` | AppFrame (main menu + toolbar + status line + body, background operations) |
| `toolbars.d` | ToolBarHost, ToolBar, ToolBarImageButton, ToolBarComboBox |
| `statusline.d` | StatusLine + panels |
| `popup.d` | PopupWidget |
| `groupbox.d` | GroupBox |
| `progressbar.d` | ProgressBarWidget |
| `charts.d` | SimpleBarChart |
| `processoutput.d` | ProcessOutputWidget (registered for DML since #709) |
| `winframe.d` | WindowFrame (used by dialogs and docks) |
| `dialogs/` | Dialog, FileDialog, MessageBox, InputBox, SettingsDialog |

### DML (DlangUI Markup Language)

- Syntax is QML-like: `parseML(q{ ClassName { id: x; prop: value; Child { … } } })`. See `dml/parser.d`.
- Widgets must be registered before DML can create them.
  - `widgets/dmlwidgets.d` registers the standard set with `mixin(registerWidgetMetadataClass!T)`.
  - Custom widgets use `mixin(registerWidgets!(...))` or the same `registerWidgetMetadataClass`.
- Properties are applied through the `setStringProperty`, `setIntProperty`, … overrides on each widget.

### Styles, themes and resources

- `widgets/styles.d` defines `Style`, `Theme`, `Align` and `TextFlag`. The current theme is the global `currentTheme`.
- Themes are XML files, e.g. `views/res/theme_default.xml`, holding `<color id=…>`, `<style id=… parent=…>` and state sub-styles.
  - Set the theme with `Platform.instance.uiTheme = "theme_dark"`.
- State styles (#848, PR #1002): `forState()` picks from merged states: own states the parent lacks first, then the
  parent's merged states in their order with own same-key states (same mask and value) merged over them; unset properties
  come from the style's normal state, so parent state values beat child normal values. Built lazily, updated in place
  (`Style._statesRevision`); widget own styles use the same merge. Theme diffs: dump effective values of all styles x
  states before/after (temporary unittest).
- **Color format is `0xAARRGGBB` with inverted alpha**: `00` is opaque and `FF` is fully transparent. `COLOR_TRANSPARENT = 0xFFFFFFFF`.
- `graphics/resources.d` defines `Drawable` and its subclasses:
  - Image, nine-patch (`.9.png`), State (XML), Solid, Gradient, Border, BoxShadow, Combined, OpenGL
  - `drawableCache` resolves a resource id (file name without extension) by searching `resourceDirs` and embedded resources.
  - `imageCache` caches decoded images.
- Embedded resources: an app lists files in `views/resources.list` and calls
  `embeddedResourceList.addResources(embedResourcesFromList!("resources.list")())`.
  The library embeds its own resources under `version(EmbedStandardResources)`. Console builds use `console_*.list`.
- i18n: `.ini` files in `res/i18n/` (`std_<lang>.ini` for the library, `<lang>.ini` for the app). Look strings up through `UIString` and `UIStringTranslator`.
- HiDPI: `SCREEN_DPI` and `overrideScreenDPI` in `core/types.d`, `pt` units, `mdpi`/`hdpi` image folders. On X11 desktops `Xft.dpi` is used if set (PR #717, `platforms/common/xftdpi.d`).
  `BASE_DPI` (96) is the reference DPI of 100%: 1x image sizes are px at `BASE_DPI`, hdpi images are 2x (PR #844).
  DPI detection by backend:
  - Win32: per-monitor v2 aware; the window's monitor DPI, followed on `WM_DPICHANGED` (#1163).
  - SDL: `Xft.dpi` on X11 desktops (#706), else `SDL_GetDisplayDPI`; plus the drawable-to-window size ratio for HiDPI
    scaling such as macOS Retina (#101).
  - X11 backend: `Xft.dpi` from the root window's RESOURCE_MANAGER, followed at runtime (#1162).
  Sizes set in code in pixels (#840, PR #1006): keep them as pixels at 100% and convert with `scaledPixels(px)`
  (`px * SCREEN_DPI / BASE_DPI`, exact at 100%, unchanged in console builds) where they are used (measure/layout/draw),
  not once in a constructor. Points can't keep e.g. 3 px exact at 100%. GUI checks: for a 100% comparison on a scaled desktop set
  `overrideScreenDPI = 96` at example1's start (temporarily, not committed); click positions scale with the DPI.
- SVG images (#843, PR #844): `.svg` resources found by id (a .png with the same id wins in resource dirs), rendered by
  arsd.svg (NanoSVG) at `SCREEN_DPI` in `ImageCache.getScaled()` (`renderSvg`/`renderSvgToSize` in images.d).
  `currentColor` = theme text color (`svgCurrentColor`, set by the `currentTheme` setter; a change drops SVG images and
  cached drawables). Size suffix `name.24x24.svg` = 24x24 px at `BASE_DPI`, id stays `name` (`svgSizeSuffix()`).
  Clip `<rect>`/`<circle>` are converted to paths (arsd keeps only `<path>` in `<clipPath>`). No `<text>`; `<use>`
  loses its own transform. Standard icons: 15 JetBrains IntelliJ Platform SVGs in `views/res/icons` (PR #851, Apache-2.0,
  `LICENSE_JetBrains_icons.txt`), `_dark` variants mapped in theme_dark.xml with `<drawable id=... value=..._dark/>`;
  emblem-added/-removed/-unknown/-important and place icons stay PNG. Planned: SVG nine-patch via file name (#847),
  place icons (#845).
- Resource leaks: all `Ref`s must be released explicitly (owner: don't mask leaks). A Ref in a dynamic array or AA
  is not released by `destroy()` of its owner: clear them in a destructor (PR #850).
  Growing an array of Refs with `arr.length = n` or `~=` may reallocate: the runtime copies the elements with
  postblit (extra references) and the old copies stay in the old block until the GC finalizes it, so objects are
  destroyed only by the GC at exit (#900). Allocate the new array, move the elements, clear the old slots. The same
  applies to compacting: clear the slots items were moved from (#892). Debug builds report leftovers
  at exit ("Non-zero ... instance count when exiting"); example1 exits with all counts 0.

### Graphics

- `DrawBuf` is the abstract drawing surface (`graphics/drawbuf.d`).
  - `ColorDrawBuf`: 32-bit software buffer
  - `GrayDrawBuf`
  - `GLDrawBuf` (`graphics/gldrawbuf.d`): batches scene items into GL calls through `graphics/glsupport.d` (GL 3.x core, shaders in `views/res/shaders`)
  - `Win32ColorDrawBuf`
  - `ConsoleDrawBuf`
- If OpenGL fails to initialize at runtime, the app falls back to software rendering (`openglEnabled` / `setOpenglEnabled`).
  Apps can request software rendering with `setOpenglEnabled(false)` before creating the first window; all backends
  honor it (Win32 #866, SDL/X11 #874). Subpixel text needs it (#833). example1: `--no-opengl`, and View menu items
  Screen DPI, Font Gamma, Subpixel Rendering (#860, #872) for testing rendering.
- Fonts (`graphics/fonts.d`): `FontManager.instance`, `Font`, `FontRef`, glyph cache, subpixel rendering, hinting modes.
  - Backends: FreeType (`ftfonts.d`, with fontconfig on Linux), Win32 GDI (`win32fonts.d`), console fonts.
  - Kerning (PR #865): pair offsets from `FT_Get_Kerning` / `GetKerningPairsW` (kern table only, no GPOS), applied in
    `Font.measureText()` by moving the boundary between the two glyphs; monospace fonts skip it. Windows UI font: Segoe UI
    first in `theme_default.xml` since PR #881 (with ClearType subpixel rendering by default, `systemSubpixelRenderingMode()`);
    #796 stays open for the system UI font (face and size from the OS, `system-ui`). Since PR #1131 the fallback theme
    in `styles.d` (`DEFAULT_THEME_FONT_FACE`) and the Win32 SansSerif fallback also start with Segoe UI. The fallback
    theme (`createDefaultTheme()`) has all custom colors of the theme file (PR #1135, checked by a unittest: add a new
    `<color>` to both).
  - Fallback fonts (#778, tracking issue #888; PRs #886, #889, #892, #893, #895, #898, #902):
    - `Font.hasCodepoint(ch)`: presence flags (`CodepointPresenceCache`, 2 bits per code point in an `EnumArray`)
      shared by all sizes of a face variant. FreeType keeps them in `FontFileItem`, Win32 per (face, weight, italic).
    - `Font.getCharGlyph(ch)` (the public API, used by measureText/drawText): the font's own glyph, else the first
      fallback font in list order that `hasCodepoint` and returns a glyph from `getOwnCharGlyph` (its own glyphs
      only, never its fallbacks, so circular lists are fine), else the font's replacement/missing glyph (on Win32,
      GDI font linking). Engines implement `getOwnCharGlyph`. No lookup for control characters and above U+FFFF
      (#779). Kerning only between two own glyphs.
    - Fallback faces per `FontFamily`: `FontManager.setFallbackFaces/fallbackFaces/defaultFallbackFaces`. Defaults
      per platform: Latin, symbols, CJK (order by system language: `systemCjkLanguage()`), other scripts, last
      resort; sources in the doc comment. Filtered to installed faces once per family
      (`installedFallbackFaces`, reset by `installedFacesChanged()` and `setFallbackFaces`); the primary face is
      skipped. The list of a font is created on its first missing character (`FallbackFontList`, lazy instances).
    - Fixed pitch fonts: whole cells, 2 for East Asian Wide/Fullwidth (`isWideChar`, generated from Unicode
      EastAsianWidth.txt), glyphs centered in their cells. `Font.charCells`; ConsoleFont: always 1.
    - Fallback references can form cycles: `FontManager.cleanup()` is a mark-and-sweep (roots: fonts with
      `refCount > 1 + references from fallback lists`); manager destructors call `releaseFallbackFonts()` first.
    - Cost (measured, #897): a presence check is about 3.5 ns per fallback font tried.
  - FreeType notes: font collections (.ttc) need the face index (fontconfig `FC_INDEX`, `registerFontFaces()`);
    weight from the OS/2 table; `FT_LOAD_NO_BITMAP` for antialiased glyphs, retried without it for bitmap-only fonts;
    `FT_LOAD_RENDER` sets the slot format to BITMAP even for outline glyphs.
  - Win32 GDI notes: `GetGlyphOutlineW` takes a character code (UTF-16 only; GDI font linking applies);
    `GetGlyphIndicesW` + `GGI_MARK_NONEXISTING_GLYPHS` is a plain cmap lookup (no linking);
    `GetCharacterPlacementW` shapes and returns no glyph for a lone combining mark.
- 3D (`graphics/scene/`): `Scene3d`, `Node3d`, `Camera`, `Light`, `Material`, `Effect`, `Mesh`, `Model`, `SkyBox`, plus OBJ and FBX import.
  Embedded in the UI through `OpenGLDrawable` / `CanvasWidget` (see `examples/d3d` and `examples/dminer`).

### Other core modules

- `core/logger.d`: `Log.d/i/w/e/v`. Logs go to `ui.log` on Windows and to stderr elsewhere. The default level is TRACE in debug builds and WARN in release.
- `core/settings.d`: `Setting` / `SettingsFile`, a JSON-like settings tree used by `SettingsDialog` and window state saving.
- `core/files.d`: file system roots, known folders, `exePath`, `appendPath`, file filters.
- `core/filemanager.d`: open in OS file manager.
- `core/asyncsocket.d`: thread-backed async client socket that posts events to the UI thread.
- `core/linestream.d`: encoding-detecting line reader and writer (ASCII, UTF-8, UTF-16 LE/BE, UTF-32 LE/BE).
- `core/editable.d`: text model behind the editors (undo buffer, marks, line icons, wrapping, syntax support).
- `core/queue.d`: `BlockingQueue`.
- `core/math3d.d`: vectors and matrices.

### Files and external changes (v0.25, #783 phases 1-2)

- `core/filewatch.d` (#1275): `FileState` (exists, size, modification time, file id, optional CRC-64 checksum),
  read by path or from an open file; `compareTo()` gives a `FileChangeKind` (`unchanged`, `modified`, `deleted`,
  `created`, `overflow`). A state that can't be read is `unknown` and is never reported as a change; same checksum
  with another time is unchanged (touch, git checkout of identical content).
- `core/files.d` `writeFileSafely()` (#1277): exclusive temp file in the same directory, then POSIX `rename()` or
  Windows `ReplaceFileW`; written in place for symbolic links, hard-linked files, devices, files of other owners.
- `EditableContent`:
  - `load(filename)` (#1276) reads the whole file with its state from the same handle, again while another program
    writes it (`LOAD_RETRIES`); files over `maxInMemoryLoadSize` (64 MB) are decoded while read. A failed load
    notifies listeners (`ReplaceContent`) and takes the new file's name with the default format (#1282).
  - `fileState`, `fileStateUncertain`, `keepFileContent`/`fileContent`; `checkExternalChange()` (by content when
    only the time changed) and `acceptExternalState()` (#1278); `reload()` replaces the changed lines as one undo
    step, `EditAction.Reload`, and leaves the content saved (#1279).
  - `save(filename)` goes through `writeFileSafely` (`atomicSave`, `syncOnSave`); a successful save makes the file
    the content's file (#1294). Name, state and kept content are set before `markSaved()` notifies listeners. The
    stream overload doesn't change the content's file.
- `EditBox` (#1280): `externalChangeMode` (`ignore` = default, apps opt in; `notify`; `reloadUnmodified`;
  `defaultExternalChangeMode` for all editors; dmledit and DlangIDE opt in). Checked by a 1 ms timer after the editor
  gets the focus (also on window activation) and by `checkBeforeSave()` (the save question Overwrite / Reload /
  Cancel). The question stays while the file is as it was when it was asked (`keepsExternalChangeMessage()`,
  #1290). Bar buttons go to `messageAction` first, then `handleExternalChangeAction()`; Save/Overwrite call
  `saveAfterExternalChange()` (SourceEdit: `save(fn)`, which keeps the file name when saving fails, #1291).
  Messages in `std_{en,ru,pl}.ini`.
- i18n: an application's `<lang>.ini` is loaded after `std_<lang>.ini` and overrides the same keys (DlangIDE uses
  this for es/cs/de translations of library strings).

## Cross-platform support

| Platform | Backend(s) | Fonts | GL | Status |
|---|---|---|---|---|
| Windows (x86, x86_64) | Win32 (default), SDL2 | Win32 GDI (default), optional FreeType | WGL, optional | Primary; in CI (dmd and ldc) |
| Linux | SDL2 (default), native X11 | FreeType + fontconfig | SDL GL / GLX | Primary; in CI (dmd and ldc) |
| macOS | SDL2 | FreeType (hardcoded font paths) | SDL GL | "Theoretically supported, not guaranteed" (README); untested |
| Android | NativeActivity (`platforms/android`) | FreeType (bundled) | EGL / GLES | Built with makefiles (`android/`, `examples/android`, `examples/dminer/android_project`); likely bit-rotted |
| Text terminals | `console` config (ANSI on posix, Win32 console on Windows) | console | – | Working for simple apps |
| SFML | `sfml` config | FreeType | GL | Legacy |
| Custom | `external` config | user-supplied | user-supplied | Stub |

Backend feature gaps found by inspecting the code:

- **Dropping files onto a window** (`Window.handleDroppedFiles`): Win32, SDL (`SDL_DROPFILE`, #705, #1116) and X11 (XDND).
- **Window state changes** (`setWindowState`): implemented in SDL, Win32 and X11. Missing in DSFML, Android and console.
- **Mouse cursor shape** (`setCursorType`): implemented in SDL, Win32, X11 and console.
- **DPI detection**: see HiDPI above (Win32, SDL and X11 detect it; DSFML, Android and console don't follow changes).
- **OpenGL multisampling**: Win32 only (the SDL attribute is commented out; X11 doesn't request it).
- **`Platform.openURL` / `showInFileManager`**: generic implementation in `platforms/common` and `core/filemanager.d`.

## Downstream: DlangIDE

`../dlangide` is the biggest real-world DlangUI app. Its own notes are in `../dlangide/AGENTS.md`.

It depends on a dlangui version range from code.dlang.org (`~>0.25.1` since DlangIDE #623; git commit pins until
v0.21.1, code.dlang.org listed only 0.13.1 until 2026-11-24). After a release, raise the range in DlangIDE's four
places (see its AGENTS.md) once code.dlang.org lists it. To build DlangIDE against this checkout, set
`"dlangui": {"path": "../dlangui"}` in `../dlangide/dub.selections.json` (gitignored).

## Known issues and gotchas

- `bezier`, `themetest` and `editlinelist` are not in the root `subPackages` (owner's decision, 2026-11-08).
- `.visualdproj` and `.dproj` IDE project files throughout `examples/` are stale.
- Destroy widgets explicitly (or let their parent destroy them). Resources are ref-counted, and leaks are reported at app exit.
- The `README.md` "Third party components" section has typos (`binbc-opengl`).
- WSLg (Weston) window manager quirks: `_NET_FRAME_EXTENTS` = 38/59 px including a 32 px shadow, but the client sits 6/27 px inside the frame; windows are mapped off-screen (-32730) first; synthetic ConfigureNotify events report positions not reached yet; SDL never reports the maximized state. Test helper idea: read the real client position with `XTranslateCoordinates` (#820, PR #829).
- Phobos bug (dlang/phobos#11160, DMD 2.114 and LDC 1.36): `indexOf(dstring, dstring, No.caseSensitive)` misses
  matches (`find` with a predicate computes its skip with `!=`): "Text" is not found in "    TextWidget". Editor search
  is affected (#1144); `string` arguments take another path and work.
- Console editors (#1139): fills are opaque, so search matches are drawn before the selection; `textPosToClient()`
  rects are 1 unit wide (a cell in the console): fill up to `endrc.left`, not `endrc.right`.
- `sfml` config doesn't build on master: `dsfmlapp.d` imports Derelict's `gl3` (#1157 area). Compile check: a stub
  `derelict/opengl3/gl3.d` with `public import bindbc.opengl;` in a temporary dir, `DFLAGS="-I<dir> -g -d-debug" dub build
  -c sfml --build-mode=allAtOnce`. Android code is under `version(Android)` (compiler-defined, needs
  `-mtriple=armv7a-unknown-linux-androideabi`); a compile-only check stops in `gldrawbuf.d` (`Tex2D`), so Android
  changes are reviewed by reading only. Check that such a check reaches the changed code with a deliberate error.
- arsd-official `ico` subpackage doesn't build alone (its dub.json lacks `png`/`bmp` deps); dlangui parses ICO itself (#211). arsd has no GIF decoder.
- Recurring code review findings (fonts work, Nov 2026); check these before committing:
  - Caches per font instance are per size: share per face where possible, and measure before adding a cache (#897).
  - Rare paths that create many objects: e.g. one emoji created every fallback font at every size (#895 review).
  - Platform data that can't be verified here (macOS paths, face names): read names from the files where possible,
    and state in the PR what is unverified.
  - Locale-dependent results: Han characters take the forms of the first CJK font, so CJK order follows the system
    language (#895).
  - Unittest checks that can't fail (e.g. testing a property the code under test guarantees by construction).
  - Fixes for a bug found while testing something else get their own issue and PR (e.g. #900 during #899).
- Recurring code review findings (file watch work, Nov 2026):
  - A widget destroyed inside its own event handler (closing a tab from a message bar button): post the action
    with `window.executeInUiThread` (DlangIDE #622).
  - Related fields changed in steps with a notification or a throwing call in between: set them together, then
    notify (#1294: file name, state and content before `markSaved()`).
  - Remembered UI state compared by kind only: a kept save question must still describe the same file state (#1290).
  - Stored continuations (a close waiting for a question's answer) must be dropped when their context ends: any
    answer, an edit, the question replaced (DlangIDE #622, #624).
  - Focus-triggered checks run when a menu or dialog closes and can replace what the action just showed (#1290).
  - An error reported twice (a message box and a message bar).
  - Doc comments not updated with a behavior change; a new unittest inserted between a comment and its test.
