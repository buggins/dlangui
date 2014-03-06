set PATH=C:\D\dmd2\windows\bin;C:\Program Files\Microsoft SDKs\Windows\v7.1\\bin;%PATH%
dmd -g -debug -X -Xf"Debug\test.json" -deps="Debug\test.dep" -c -of"Debug\test.obj" main.d
if errorlevel 1 goto reportError

set LIB="C:\D\dmd2\windows\bin\\..\lib"
echo. > Debug\test.build.lnkarg
echo "Debug\test.obj","Debug\test.exe_cv","Debug\test.map",user32.lib+ >> Debug\test.build.lnkarg
echo kernel32.lib/NOMAP/CO/NOI >> Debug\test.build.lnkarg

"C:\Tools\VisualDAddon\pipedmd.exe" -deps Debug\test.lnkdep link.exe @Debug\test.build.lnkarg
if errorlevel 1 goto reportError
if not exist "Debug\test.exe_cv" (echo "Debug\test.exe_cv" not created! && goto reportError)
echo Converting debug information...
"C:\Tools\VisualDAddon\cv2pdb\cv2pdb.exe" "Debug\test.exe_cv" "Debug\test.exe"
if errorlevel 1 goto reportError
if not exist "Debug\test.exe" (echo "Debug\test.exe" not created! && goto reportError)

goto noError

:reportError
echo Building Debug\test.exe failed!

:noError
