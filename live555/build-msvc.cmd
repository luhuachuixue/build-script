@echo off

setlocal

set work_dir=%~dp0
set work_dir=%work_dir:~0,-1%
set pkg_name=live555-latest
set pkg_file=%pkg_name%.tar.gz
set src_dir=%work_dir%\live
set install_dir=D:\Library\Live555

set vs_version=2022
@REM set vs_version=2017
set arch="x64"
@REM set arch="x86"

if %vs_version% == 2022 (
    set msvc_prefix="C:/Program Files/Microsoft Visual Studio/2022/Enterprise/VC/Auxiliary/Build"
    set msvc_path="C:\Program Files/Microsoft Visual Studio\2022\Enterprise\VC\Tools\MSVC\14.33.31629"
) else (
    set msvc_prefix="C:/Program Files (x86)/Microsoft Visual Studio/2017/Enterprise/VC/Auxiliary/Build"
    set msvc_path="C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\VC\Tools\MSVC\14.16.27023"
)

if %arch% == "x64" (
    set msvc_bat=vcvars64.bat
    set os_arch=x64
) else (
    set msvc_bat=vcvars32.bat
    set os_arch=x86
)

set msvc_env=%msvc_prefix%/%msvc_bat%

cd /D %work_dir%

if not exist %pkg_file% (
    echo **** NOT FIND CODE PACKAGE ****
    pause
    exit
)

where /Q 7z
if errorlevel 1 (
    echo **** CANNOT FIND 7-Zip ****
    pause
    exit
)

if not exist %msvc_env% (
    echo **** UNSET CORRECT MSVC ENV ****
    pause
    exit
)

if not exist %msvc_path% (
    echo **** UNSET CORRECT MSVC PATH ****
    pause
    exit
)

if exist %src_dir% (
    rmdir /S /Q %src_dir%
)

if exist %install_dir% (
    rmdir /S /Q %install_dir%
)

7z x %pkg_file% -so | 7z x -aoa -si -ttar
@REM icacls "%src_dir%" /T /grant:r everyone:(F)
@REM icacls "%src_dir%" /T /grant:r Administrators:(F)
@REM icacls "%src_dir%" /T /grant:r Users:(F)

cd /D %src_dir%
powershell -Command "(gc win32config) -replace '!include    <ntwin32.mak>', '#!include    <ntwin32.mak>' | Out-File win32config"
powershell -Command "(gc win32config) -replace 'c:\\Program Files\\DevStudio\\Vc', '%msvc_path%' | Out-File win32config"
powershell -Command "(gc win32config) -replace '\(TOOLS32\)\\bin\\cl', '(TOOLS32)\bin\Host%os_arch%\%os_arch%\cl' | Out-File win32config"
powershell -Command "(gc win32config) -replace 'LINK =			\$\(link\) -out:', 'LINK = link ws2_32.lib /out:' | Out-File win32config"
powershell -Command "(gc win32config) -replace 'LIBRARY_LINK =		lib -out:', 'LIBRARY_LINK = lib /out:' | Out-File win32config"
powershell -Command "(gc win32config) -replace 'msvcirt.lib', 'msvcrt.lib' | Out-File win32config"
@REM powershell -Command "(gc win32config) -replace '-DNO_OPENSSL=1', '-DNO_OPENSSL=1 -DDEBUG' | Out-File win32config"

@REM -----------------------------------------------------------------------------------------------------------------
@REM setsockopt() 4th parameter type is different between Windows and UNIX
@REM Windows winsock2.h: int setsockopt(SOCKET s, int level, int optname, const char *optval, int optlen);
@REM UNIX  sys/socket.h: int setsockopt(int sockfd, int level, int optname, const void *optval, socklen_t optlen);
@REM -----------------------------------------------------------------------------------------------------------------
powershell -Command "(gc win32config) -replace '-DNO_OPENSSL=1', '-DNO_OPENSSL=1 -DNO_GETIFADDRS' | Out-File win32config"
powershell -Command "(gc groupsock\GroupsockHelper.cpp) -replace '&one,', '(char *)&one,' | Out-File groupsock\GroupsockHelper.cpp"
powershell -Command "(gc groupsock\GroupsockHelper.cpp) -replace 'option_value,', '(char *)option_value,' | Out-File groupsock\GroupsockHelper.cpp"

cd WindowsAudioInputDevice
powershell -Command "(gc WindowsAudioInputDevice.mak) -replace '!include    <ntwin32.mak>', '#!include    <ntwin32.mak>' | Out-File WindowsAudioInputDevice.mak"
powershell -Command "(gc WindowsAudioInputDevice.mak) -replace 'c:\\Program Files\\DevStudio\\Vc', '%msvc_path%' | Out-File WindowsAudioInputDevice.mak"
powershell -Command "(gc WindowsAudioInputDevice.mak) -replace '\(TOOLS32\)\\bin\\cl', '(TOOLS32)\bin\Host%os_arch%\%os_arch%\cl' | Out-File WindowsAudioInputDevice.mak"
powershell -Command "(gc WindowsAudioInputDevice.mak) -replace 'LINK =			\$\(link\) -out:', 'LINK = link ws2_32.lib /out:' | Out-File WindowsAudioInputDevice.mak"
powershell -Command "(gc WindowsAudioInputDevice.mak) -replace 'LIBRARY_LINK =		lib -out:', 'LIBRARY_LINK = lib /out:' | Out-File WindowsAudioInputDevice.mak"
powershell -Command "(gc WindowsAudioInputDevice.mak) -replace 'msvcirt.lib', 'msvcrt.lib' | Out-File WindowsAudioInputDevice.mak"
@REM powershell -Command "(gc WindowsAudioInputDevice.mak) -replace '-DNO_OPENSSL=1', '-DNO_OPENSSL=1 -DDEBUG' | Out-File WindowsAudioInputDevice.mak"
cd ..

call %msvc_env%
call genWindowsMakefiles.cmd

cd liveMedia
nmake /B -f liveMedia.mak
cd ..\groupsock
nmake /B -f groupsock.mak
cd ..\UsageEnvironment
nmake /B -f UsageEnvironment.mak
cd ..\BasicUsageEnvironment
nmake /B -f BasicUsageEnvironment.mak
cd ..\testProgs
nmake /B -f testProgs.mak
cd ..\mediaServer
nmake /B -f mediaServer.mak
cd ..\proxyServer
nmake /B -f proxyServer.mak
cd ..\hlsProxy
nmake /B -f hlsProxy.mak
cd ..\WindowsAudioInputDevice
nmake /B -f WindowsAudioInputDevice.mak

echo.
echo **** COMPILATION FINISHED ****
echo.

mkdir %install_dir%
mkdir %install_dir%\bin
mkdir %install_dir%\include
mkdir %install_dir%\lib

copy %src_dir%\mediaServer\*.exe %install_dir%\bin
copy %src_dir%\proxyServer\*.exe %install_dir%\bin
copy %src_dir%\hlsProxy\*.exe %install_dir%\bin
copy %src_dir%\testProgs\*.exe %install_dir%\bin
copy %src_dir%\WindowsAudioInputDevice\*.exe %install_dir%\bin
copy %src_dir%\liveMedia\*.lib %install_dir%\lib
copy %src_dir%\liveMedia\*.pdb %install_dir%\lib
copy %src_dir%\groupsock\*.lib %install_dir%\lib
copy %src_dir%\groupsock\*.pdb %install_dir%\lib
copy %src_dir%\UsageEnvironment\*.lib %install_dir%\lib
copy %src_dir%\UsageEnvironment\*.pdb %install_dir%\lib
copy %src_dir%\BasicUsageEnvironment\*.lib %install_dir%\lib
copy %src_dir%\BasicUsageEnvironment\*.pdb %install_dir%\lib
move %src_dir%\liveMedia\include %install_dir%\include\liveMedia
move %src_dir%\groupsock\include %install_dir%\include\groupsock
move %src_dir%\UsageEnvironment\include %install_dir%\include\UsageEnvironment
move %src_dir%\BasicUsageEnvironment\include %install_dir%\include\BasicUsageEnvironment

echo.
echo **** BINARY DISTRIBUTION FINISHED ****
echo.

cd /D %work_dir%
rmdir /S /Q %src_dir%

echo.
echo **** SRC DIR DELETED ****
echo.

pause