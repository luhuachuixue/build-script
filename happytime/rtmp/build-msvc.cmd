@echo off

setlocal

set work_dir=%~dp0
set work_dir=%work_dir:~0,-1%
set pkg_name=happytime-rtmp-pusher-code
set pkg_file=%pkg_name%.zip
set src_dir=%work_dir%\%pkg_name%
set build_dir=%src_dir%\RtmpPusher
set install_dir=D:\Library\rtmp\pusher

set vs_version=2022
@REM set vs_version=2017
set arch="x64"
@REM set arch="x86"

if %vs_version% == 2022 (
    set msvc_prefix="C:/Program Files/Microsoft Visual Studio/2022/Enterprise/VC/Auxiliary/Build"
    set win_target_ver=10.0.19041.0
    set msvc_tool_ver=17.0
    set msvc_toolset_ver=143
) else (
    set msvc_prefix="C:/Program Files (x86)/Microsoft Visual Studio/2017/Enterprise/VC/Auxiliary/Build"
    set win_target_ver=10.0.17763.0
    set msvc_tool_ver=15.0
    set msvc_toolset_ver=141
)

if %arch% == "x64" (
    set msvc_bat=vcvars64.bat
    set dir_platform=x64
) else (
    set msvc_bat=vcvars32.bat
    set dir_platform=Win32
)

set msvc_env=%msvc_prefix%/%msvc_bat%

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

if exist %src_dir% (
    rmdir /S /Q %src_dir%
)

if exist %build_dir% (
    rmdir /S /Q %build_dir%
)

if exist %install_dir% (
    rmdir /S /Q %install_dir%
)

7z x -aoa %pkg_file%

call %msvc_env%
cd /D %build_dir%
powershell -Command "(gc RtmpPusher.vcxproj) -replace '14.0', '%msvc_tool_ver%' | Out-File RtmpPusher.vcxproj"
powershell -Command "(gc RtmpPusher.vcxproj) -replace 'v140', 'v%msvc_toolset_ver%' | Out-File RtmpPusher.vcxproj"
powershell -Command "(gc RtmpPusher.vcxproj) -replace '8.1', '%win_target_ver%' | Out-File RtmpPusher.vcxproj"

MSBuild RtmpPusher.vcxproj /p:Configuration=Release
@REM MSBuild RtmpPusher.vcxproj /p:Configuration=Debug

echo.
echo **** COMPILATION FINISHED ****
echo.

mkdir %install_dir%
copy %build_dir%\x64\Release\*.exe %install_dir%
copy %build_dir%\config.xml %install_dir%

echo.
echo **** DISTRIBUTION FINISHED ****
echo.

cd /D %work_dir%
rmdir /S /Q %src_dir%

echo.
echo **** SRC DIR DELETED ****
echo.

pause