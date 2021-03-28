@echo off

setlocal

set qrencode_version=4.1.1
set work_dir=%~dp0
set work_dir=%work_dir:~0,-1%
set qrencode_pkg_name=libqrencode-%qrencode_version%
set qrencode_src_dir=%work_dir%\%qrencode_pkg_name%
set qrencode_build_dir=%work_dir%\build
set qrencode_install_dir=D:\Library\libqrencode
set cmake_gen_type="Visual Studio 15 2017 Win64"
set msvc_env="C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\VC\Auxiliary\Build\vcvars64.bat"
@REM set cmake_gen_type="Visual Studio 15 2017"
@REM set msvc_env="C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\VC\Auxiliary\Build\vcvars32.bat"

if not exist %qrencode_pkg_name%.zip (
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

where /Q cmake
if errorlevel 1 (
    echo **** CANNOT FIND CMAKE ****
    pause
    exit
)

if not exist %msvc_env% (
    echo **** UNSET CORRECT MSVC ENV ****
    pause
    exit
)

if exist %qrencode_src_dir% (
    rmdir /S /Q %qrencode_src_dir%
)

if exist %qrencode_build_dir% (
    rmdir /S /Q %qrencode_build_dir%
)

if exist %qrencode_install_dir% (
    rmdir /S /Q %qrencode_install_dir%
)

7z x -aoa %qrencode_pkg_name%.zip

cd /D %qrencode_src_dir%
cmake -G%cmake_gen_type% -S. -B%qrencode_build_dir% -DCMAKE_INSTALL_PREFIX=%qrencode_install_dir% ^
    -DBUILD_SHARED_LIBS=OFF -DWITH_TOOLS=OFF

echo.
echo **** CMAKE VS-PROJECT GENERATED ****
echo.

call %msvc_env%
cd /D %qrencode_build_dir%
MSBuild INSTALL.vcxproj /p:Configuration=Release
@REM MSBuild INSTALL.vcxproj /p:Configuration=Debug

echo.
echo **** COMPILATION AND DISTRIBUTION FINISHED ****
echo.

cd /D %work_dir%
rmdir /S /Q %qrencode_src_dir% %qrencode_build_dir%

echo.
echo **** SRC AND BUILD DIR DELETED ****
echo.

pause