@echo off

setlocal

set pugixml_version=1.11.3
set work_dir=%~dp0
set work_dir=%work_dir:~0,-1%
set pugixml_pkg_name=pugixml-%pugixml_version%
set pugixml_src_dir=%work_dir%\%pugixml_pkg_name%
set pugixml_build_dir=%work_dir%\build
set pugixml_install_dir=D:\Library\libpugixml
set cmake_gen_type="Visual Studio 15 2017 Win64"
set msvc_env="C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\VC\Auxiliary\Build\vcvars64.bat"

if not exist %pugixml_pkg_name%.zip (
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

if exist %pugixml_src_dir% (
    rmdir /S /Q %pugixml_src_dir%
)

if exist %pugixml_build_dir% (
    rmdir /S /Q %pugixml_build_dir%
)

if exist %pugixml_install_dir% (
    rmdir /S /Q %pugixml_install_dir%
)

7z x -aoa %pugixml_pkg_name%.zip

cd /D %pugixml_src_dir%
cmake -G%cmake_gen_type% -S. -B%pugixml_build_dir% -DCMAKE_INSTALL_PREFIX=%pugixml_install_dir% ^
    -DBUILD_SHARED_AND_STATIC_LIBS=OFF -DBUILD_SHARED_LIBS=ON

echo.
echo **** CMAKE VS-PROJECT GENERATED ****
echo.

call %msvc_env%
cd /D %pugixml_build_dir%
MSBuild INSTALL.vcxproj /p:Configuration=Release
@REM MSBuild INSTALL.vcxproj /p:Configuration=Debug

echo.
echo **** COMPILATION AND DISTRIBUTION FINISHED ****
echo.

cd /D %work_dir%
rmdir /S /Q %pugixml_src_dir% %pugixml_build_dir%

echo.
echo **** SRC AND BUILD DIR DELETED ****
echo.

pause