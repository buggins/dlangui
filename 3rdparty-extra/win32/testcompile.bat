@call :testuni
@call :testuni -version=Unicode
@goto :eof

:testuni
@call :testversion %*
@call :testversion %* -version=Windows2000
@call :testversion %* -version=WindowsXP
@call :testversion %* -version=Windows2003
@call :testversion %* -version=WindowsVista
@call :testversion %* -version=Win32_Winsock1
@call :testversion %* -version=IE7
@goto :eof

:testversion
@call :testone -m32 %*
@call :testone -m64 %*
@goto :eof

:testone
dmd -I.. -c %* testall.d
@if errorlevel 1 exit 1
@goto :eof
