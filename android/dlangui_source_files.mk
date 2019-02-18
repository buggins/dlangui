#MY_DIR=$(dirname $(readlink -f $0))
#DLANGUI_DIR=$(dirname $MY_DIR)
#echo "DLANGUI DIR: $DLANGUI_DIR"

DLANGUI_SOURCES="\
$DLANGUI_DIR/src/dlangui/platforms/android/androidapp.d \
$DLANGUI_DIR/src/dlangui/platforms/android/imm.d \
$DLANGUI_DIR/src/dlangui/platforms/common/startup.d \
$DLANGUI_DIR/src/dlangui/platforms/common/platform.d \
$DLANGUI_DIR/src/dlangui/dialogs/filedlg.d \
$DLANGUI_DIR/src/dlangui/dialogs/dialog.d \
$DLANGUI_DIR/src/dlangui/dialogs/msgbox.d \
$DLANGUI_DIR/src/dlangui/dialogs/inputbox.d \
$DLANGUI_DIR/src/dlangui/dialogs/settingsdialog.d \
$DLANGUI_DIR/src/dlangui/core/asyncsocket.d \
$DLANGUI_DIR/src/dlangui/core/config.d \
$DLANGUI_DIR/src/dlangui/core/textsource.d \
$DLANGUI_DIR/src/dlangui/core/css.d \
$DLANGUI_DIR/src/dlangui/core/filemanager.d \
$DLANGUI_DIR/src/dlangui/core/files.d \
$DLANGUI_DIR/src/dlangui/core/events.d \
$DLANGUI_DIR/src/dlangui/core/collections.d \
$DLANGUI_DIR/src/dlangui/core/stdaction.d \
$DLANGUI_DIR/src/dlangui/core/types.d \
$DLANGUI_DIR/src/dlangui/core/queue.d \
$DLANGUI_DIR/src/dlangui/core/parseutils.d \
$DLANGUI_DIR/src/dlangui/core/i18n.d \
$DLANGUI_DIR/src/dlangui/core/dom.d \
$DLANGUI_DIR/src/dlangui/core/editable.d \
$DLANGUI_DIR/src/dlangui/core/math3d.d \
$DLANGUI_DIR/src/dlangui/core/logger.d \
$DLANGUI_DIR/src/dlangui/core/settings.d \
$DLANGUI_DIR/src/dlangui/core/linestream.d \
$DLANGUI_DIR/src/dlangui/core/streams.d \
$DLANGUI_DIR/src/dlangui/core/cssparser.d \
$DLANGUI_DIR/src/dlangui/core/signals.d \
$DLANGUI_DIR/src/dlangui/graphics/drawbuf.d \
$DLANGUI_DIR/src/dlangui/graphics/xpm/xpmcolors.d \
$DLANGUI_DIR/src/dlangui/graphics/xpm/reader.d \
$DLANGUI_DIR/src/dlangui/graphics/ftfonts.d \
$DLANGUI_DIR/src/dlangui/graphics/images.d \
$DLANGUI_DIR/src/dlangui/graphics/scene/model.d \
$DLANGUI_DIR/src/dlangui/graphics/scene/objimport.d \
$DLANGUI_DIR/src/dlangui/graphics/scene/camera.d \
$DLANGUI_DIR/src/dlangui/graphics/scene/node.d \
$DLANGUI_DIR/src/dlangui/graphics/scene/material.d \
$DLANGUI_DIR/src/dlangui/graphics/scene/effect.d \
$DLANGUI_DIR/src/dlangui/graphics/scene/drawableobject.d \
$DLANGUI_DIR/src/dlangui/graphics/scene/light.d \
$DLANGUI_DIR/src/dlangui/graphics/scene/scene3d.d \
$DLANGUI_DIR/src/dlangui/graphics/scene/transform.d \
$DLANGUI_DIR/src/dlangui/graphics/scene/mesh.d \
$DLANGUI_DIR/src/dlangui/graphics/scene/fbximport.d \
$DLANGUI_DIR/src/dlangui/graphics/scene/skybox.d \
$DLANGUI_DIR/src/dlangui/graphics/resources.d \
$DLANGUI_DIR/src/dlangui/graphics/glsupport.d \
$DLANGUI_DIR/src/dlangui/graphics/iconprovider.d \
$DLANGUI_DIR/src/dlangui/graphics/colors.d \
$DLANGUI_DIR/src/dlangui/graphics/gldrawbuf.d \
$DLANGUI_DIR/src/dlangui/graphics/fonts.d \
$DLANGUI_DIR/src/dlangui/graphics/domrender/domrender.d \
$DLANGUI_DIR/src/dlangui/graphics/domrender/renderblock.d \
$DLANGUI_DIR/src/dlangui/package.d \
$DLANGUI_DIR/src/dlangui/dml/dmlhighlight.d \
$DLANGUI_DIR/src/dlangui/dml/annotations.d \
$DLANGUI_DIR/src/dlangui/dml/tokenizer.d \
$DLANGUI_DIR/src/dlangui/dml/parser.d \
$DLANGUI_DIR/src/dlangui/widgets/grid.d \
$DLANGUI_DIR/src/dlangui/widgets/groupbox.d \
$DLANGUI_DIR/src/dlangui/widgets/styles.d \
$DLANGUI_DIR/src/dlangui/widgets/combobox.d \
$DLANGUI_DIR/src/dlangui/widgets/lists.d \
$DLANGUI_DIR/src/dlangui/widgets/srcedit.d \
$DLANGUI_DIR/src/dlangui/widgets/widget.d \
$DLANGUI_DIR/src/dlangui/widgets/statusline.d \
$DLANGUI_DIR/src/dlangui/widgets/toolbars.d \
$DLANGUI_DIR/src/dlangui/widgets/tree.d \
$DLANGUI_DIR/src/dlangui/widgets/controls.d \
$DLANGUI_DIR/src/dlangui/widgets/dmlwidgets.d \
$DLANGUI_DIR/src/dlangui/widgets/popup.d \
$DLANGUI_DIR/src/dlangui/widgets/progressbar.d \
$DLANGUI_DIR/src/dlangui/widgets/tabs.d \
$DLANGUI_DIR/src/dlangui/widgets/editors.d \
$DLANGUI_DIR/src/dlangui/widgets/appframe.d \
$DLANGUI_DIR/src/dlangui/widgets/charts.d \
$DLANGUI_DIR/src/dlangui/widgets/layouts.d \
$DLANGUI_DIR/src/dlangui/widgets/winframe.d \
$DLANGUI_DIR/src/dlangui/widgets/metadata.d \
$DLANGUI_DIR/src/dlangui/widgets/scrollbar.d \
$DLANGUI_DIR/src/dlangui/widgets/scroll.d \
$DLANGUI_DIR/src/dlangui/widgets/docks.d \
$DLANGUI_DIR/src/dlangui/widgets/menu.d \
$DLANGUI_DIR/3rdparty/android/native_window.d \
$DLANGUI_DIR/3rdparty/android/looper.d \
$DLANGUI_DIR/3rdparty/android/storage_manager.d \
$DLANGUI_DIR/3rdparty/android/window.d \
$DLANGUI_DIR/3rdparty/android/log.d \
$DLANGUI_DIR/3rdparty/android/obb.d \
$DLANGUI_DIR/3rdparty/android/bitmap.d \
$DLANGUI_DIR/3rdparty/android/asset_manager.d \
$DLANGUI_DIR/3rdparty/android/keycodes.d \
$DLANGUI_DIR/3rdparty/android/input.d \
$DLANGUI_DIR/3rdparty/android/rect.d \
$DLANGUI_DIR/3rdparty/android/configuration.d \
$DLANGUI_DIR/3rdparty/android/sensor.d \
$DLANGUI_DIR/3rdparty/android/native_activity.d \
$DLANGUI_DIR/3rdparty/android/android_native_app_glue.d \
$DLANGUI_DIR/3rdparty/android/android_native_app_glue_impl.d \
$DLANGUI_DIR/3rdparty/jni.d \
$DLANGUI_DIR/3rdparty/fontconfig/functions.d \
$DLANGUI_DIR/3rdparty/fontconfig/fctypes.d \
$DLANGUI_DIR/3rdparty/fontconfig/package.d \
$DLANGUI_DIR/3rdparty/GLES3/gl3.d \
$DLANGUI_DIR/3rdparty/dimage/image.d \
$DLANGUI_DIR/3rdparty/dimage/memory.d \
$DLANGUI_DIR/3rdparty/dimage/array.d \
$DLANGUI_DIR/3rdparty/dimage/stream.d \
$DLANGUI_DIR/3rdparty/dimage/bitio.d \
$DLANGUI_DIR/3rdparty/dimage/zlib.d \
$DLANGUI_DIR/3rdparty/dimage/idct.d \
$DLANGUI_DIR/3rdparty/dimage/jpeg.d \
$DLANGUI_DIR/3rdparty/dimage/png.d \
$DLANGUI_DIR/3rdparty/dimage/huffman.d \
$DLANGUI_DIR/3rdparty/dimage/compound.d \
$DLANGUI_DIR/3rdparty/GLES2/gl2.d \
$DLANGUI_DIR/3rdparty/GLES/gl.d \
$DLANGUI_DIR/3rdparty/EGL/eglplatform.d \
$DLANGUI_DIR/3rdparty/EGL/egl.d \
$DLANGUI_DIR/deps/DerelictFT/source/derelict/freetype/functions.d \
$DLANGUI_DIR/deps/DerelictFT/source/derelict/freetype/ft.d \
$DLANGUI_DIR/deps/DerelictFT/source/derelict/freetype/types.d \
$DLANGUI_DIR/deps/DerelictUtil/source/derelict/util/sharedlib.d \
$DLANGUI_DIR/deps/DerelictUtil/source/derelict/util/exception.d \
$DLANGUI_DIR/deps/DerelictUtil/source/derelict/util/system.d \
$DLANGUI_DIR/deps/DerelictUtil/source/derelict/util/wintypes.d \
$DLANGUI_DIR/deps/DerelictUtil/source/derelict/util/loader.d \
$DLANGUI_DIR/deps/DerelictUtil/source/derelict/util/xtypes.d \
"

#echo $DLANGUI_SOURCES

DLANGUI_SOURCE_PATHS="\
-I$DLANGUI_DIR/src \
-I$DLANGUI_DIR/3rdparty \
-I$DLANGUI_DIR/deps/DerelictUtil \
-I$DLANGUI_DIR/deps/DerelictFT \
-I$DLANGUI_DIR/deps/DerelictGL3 \
"

DLANGUI_IMPORT_PATHS="\
-J$DLANGUI_DIR/views \
-J$DLANGUI_DIR/views/res \
-J$DLANGUI_DIR/views/res/mdpi \
-J$DLANGUI_DIR/views/res/hdpi \
-J$DLANGUI_DIR/views/res/i18n \
-J$DLANGUI_DIR/views/res/shaders \
"

DLANGUI_LDLIBS="\
-lgcc \
-llog \
-landroid \
-lEGL \
-lGLESv3 \
-lc \
-lm \
"

#-lGLESv1_CM \

#echo "Import paths: $DLANGUI_IMPORT_PATHS"
#echo "Source paths: $DLANGUI_SOURCE_PATHS"

#$DLANGUI_DIR/deps/DerelictGL3/source/derelict/opengl3/ext.d \
#$DLANGUI_DIR/deps/DerelictGL3/source/derelict/opengl3/functions.d \
#$DLANGUI_DIR/deps/DerelictGL3/source/derelict/opengl3/glx.d \
#$DLANGUI_DIR/deps/DerelictGL3/source/derelict/opengl3/cgl.d \
#$DLANGUI_DIR/deps/DerelictGL3/source/derelict/opengl3/deprecatedConstants.d \
#$DLANGUI_DIR/deps/DerelictGL3/source/derelict/opengl3/gl3.d \
#$DLANGUI_DIR/deps/DerelictGL3/source/derelict/opengl3/types.d \
#$DLANGUI_DIR/deps/DerelictGL3/source/derelict/opengl3/internal.d \
#$DLANGUI_DIR/deps/DerelictGL3/source/derelict/opengl3/wglext.d \
#$DLANGUI_DIR/deps/DerelictGL3/source/derelict/opengl3/wgl.d \
#$DLANGUI_DIR/deps/DerelictGL3/source/derelict/opengl3/glxext.d \
#$DLANGUI_DIR/deps/DerelictGL3/source/derelict/opengl3/arb.d \
#$DLANGUI_DIR/deps/DerelictGL3/source/derelict/opengl3/deprecatedFunctions.d \
#$DLANGUI_DIR/deps/DerelictGL3/source/derelict/opengl3/constants.d \
#$DLANGUI_DIR/deps/DerelictGL3/source/derelict/opengl3/gl.d \
