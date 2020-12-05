@echo off

setlocal

set jsoncpp_version=1.9.4
set work_dir=%~dp0
set work_dir=%work_dir:~0,-1%
set jsoncpp_pkg_name=jsoncpp-%jsoncpp_version%
set jsoncpp_src_dir=%work_dir%\%jsoncpp_pkg_name%
set jsoncpp_build_dir=%work_dir%\build
set jsoncpp_install_dir=D:\Library\libjsoncpp
set cmake_gen_type="Visual Studio 15 2017 Win64"
set msvc_env="C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\VC\Auxiliary\Build\vcvars64.bat"

if not exist %jsoncpp_pkg_name%.zip (
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

if exist %jsoncpp_src_dir% (
    rmdir /S /Q %jsoncpp_src_dir%
)

if exist %jsoncpp_build_dir% (
    rmdir /S /Q %jsoncpp_build_dir%
)

if exist %jsoncpp_install_dir% (
    rmdir /S /Q %jsoncpp_install_dir%
)

7z x -aoa %jsoncpp_pkg_name%.zip

cd /D %jsoncpp_src_dir%
cmake -G%cmake_gen_type% -S. -B%jsoncpp_build_dir% -DCMAKE_INSTALL_PREFIX=%jsoncpp_install_dir% ^
    -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON -DBUILD_STATIC_LIBS=OFF

echo.
echo **** CMAKE VS-PROJECT GENERATED ****
echo.

call %msvc_env%
cd /D %jsoncpp_build_dir%
MSBuild INSTALL.vcxproj /p:Configuration=Release
@REM MSBuild INSTALL.vcxproj /p:Configuration=Debug

echo.
echo **** COMPILATION AND DISTRIBUTION FINISHED ****
echo.

cd /D %work_dir%
rmdir /S /Q %jsoncpp_src_dir% %jsoncpp_build_dir%

echo.
echo **** SRC AND BUILD DIR DELETED ****
echo.

pause