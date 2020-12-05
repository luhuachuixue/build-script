@echo off

setlocal

set work_dir=%~dp0
set work_dir=%work_dir:~0,-1%
set live555_pkg_name=live555-latest
set live555_src_dir=%work_dir%\live
set live555_install_dir=D:\Library\Live555
set msvc_env="C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\VC\Auxiliary\Build\vcvars64.bat"
set msvc_path="C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\VC\Tools\MSVC\14.16.27023"

cd /D %work_dir%

if not exist %live555_pkg_name%.tar.gz (
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

if exist %live555_src_dir% (
    rmdir /S /Q %live555_src_dir%
)

if exist %live555_install_dir% (
    rmdir /S /Q %live555_install_dir%
)

7z x -aoa %live555_pkg_name%.tar.gz
7z x -aoa %live555_pkg_name%.tar
del /Q %live555_pkg_name%.tar

cd /D %live555_src_dir%
powershell -Command "(gc win32config) -replace '!include    <ntwin32.mak>', '#!include    <ntwin32.mak>' | Out-File win32config"
powershell -Command "(gc win32config) -replace 'c:\\Program Files\\DevStudio\\Vc', '%msvc_path%' | Out-File win32config"
powershell -Command "(gc win32config) -replace '\(TOOLS32\)\\bin\\cl', '(TOOLS32)\bin\Hostx64\x64\cl' | Out-File win32config"
powershell -Command "(gc win32config) -replace 'LINK =			\$\(link\) -out:', 'LINK = link ws2_32.lib /out:' | Out-File win32config"
powershell -Command "(gc win32config) -replace 'LIBRARY_LINK =		lib -out:', 'LIBRARY_LINK = lib /out:' | Out-File win32config"
powershell -Command "(gc win32config) -replace 'msvcirt.lib', 'msvcrt.lib' | Out-File win32config"
REM powershell -Command "(gc win32config) -replace '-DNO_OPENSSL=1', '-DNO_OPENSSL=1 -DDEBUG' | Out-File win32config"

cd WindowsAudioInputDevice
powershell -Command "(gc WindowsAudioInputDevice.mak) -replace '!include    <ntwin32.mak>', '#!include    <ntwin32.mak>' | Out-File WindowsAudioInputDevice.mak"
powershell -Command "(gc WindowsAudioInputDevice.mak) -replace 'c:\\Program Files\\DevStudio\\Vc', '%msvc_path%' | Out-File WindowsAudioInputDevice.mak"
powershell -Command "(gc WindowsAudioInputDevice.mak) -replace '\(TOOLS32\)\\bin\\cl', '(TOOLS32)\bin\Hostx64\x64\cl' | Out-File WindowsAudioInputDevice.mak"
powershell -Command "(gc WindowsAudioInputDevice.mak) -replace 'LINK =			\$\(link\) -out:', 'LINK = link ws2_32.lib /out:' | Out-File WindowsAudioInputDevice.mak"
powershell -Command "(gc WindowsAudioInputDevice.mak) -replace 'LIBRARY_LINK =		lib -out:', 'LIBRARY_LINK = lib /out:' | Out-File WindowsAudioInputDevice.mak"
powershell -Command "(gc WindowsAudioInputDevice.mak) -replace 'msvcirt.lib', 'msvcrt.lib' | Out-File WindowsAudioInputDevice.mak"
REM powershell -Command "(gc WindowsAudioInputDevice.mak) -replace '-DNO_OPENSSL=1', '-DNO_OPENSSL=1 -DDEBUG' | Out-File WindowsAudioInputDevice.mak"
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

mkdir %live555_install_dir%
mkdir %live555_install_dir%\bin
mkdir %live555_install_dir%\include
mkdir %live555_install_dir%\lib

copy %live555_src_dir%\mediaServer\*.exe %live555_install_dir%\bin
copy %live555_src_dir%\proxyServer\*.exe %live555_install_dir%\bin
copy %live555_src_dir%\hlsProxy\*.exe %live555_install_dir%\bin
copy %live555_src_dir%\testProgs\*.exe %live555_install_dir%\bin
copy %live555_src_dir%\WindowsAudioInputDevice\*.exe %live555_install_dir%\bin
copy %live555_src_dir%\liveMedia\*.lib %live555_install_dir%\lib
copy %live555_src_dir%\liveMedia\*.pdb %live555_install_dir%\lib
copy %live555_src_dir%\groupsock\*.lib %live555_install_dir%\lib
copy %live555_src_dir%\groupsock\*.pdb %live555_install_dir%\lib
copy %live555_src_dir%\UsageEnvironment\*.lib %live555_install_dir%\lib
copy %live555_src_dir%\UsageEnvironment\*.pdb %live555_install_dir%\lib
copy %live555_src_dir%\BasicUsageEnvironment\*.lib %live555_install_dir%\lib
copy %live555_src_dir%\BasicUsageEnvironment\*.pdb %live555_install_dir%\lib
move %live555_src_dir%\liveMedia\include %live555_install_dir%\include\liveMedia
move %live555_src_dir%\groupsock\include %live555_install_dir%\include\groupsock
move %live555_src_dir%\UsageEnvironment\include %live555_install_dir%\include\UsageEnvironment
move %live555_src_dir%\BasicUsageEnvironment\include %live555_install_dir%\include\BasicUsageEnvironment

echo.
echo **** BINARY DISTRIBUTION FINISHED ****
echo.

cd /D %work_dir%
rmdir /S /Q %live555_src_dir%

echo.
echo **** SRC DIR DELETED ****
echo.

pause