@echo off

setlocal

set cjson_version=1.7.14
set work_dir=%~dp0
set work_dir=%work_dir:~0,-1%
set cjson_pkg_name=cJSON-%cjson_version%
set cjson_src_dir=%work_dir%\%cjson_pkg_name%
set cjson_build_dir=%work_dir%\build
set cjson_install_dir=D:\Library\libcjson
set cmake_gen_type="Visual Studio 15 2017 Win64"
set msvc_env="C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\VC\Auxiliary\Build\vcvars64.bat"
@REM set cmake_gen_type="Visual Studio 15 2017"
@REM set msvc_env="C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\VC\Auxiliary\Build\vcvars32.bat"

if not exist %cjson_pkg_name%.zip (
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

if exist %cjson_src_dir% (
    rmdir /S /Q %cjson_src_dir%
)

if exist %cjson_build_dir% (
    rmdir /S /Q %cjson_build_dir%
)

if exist %cjson_install_dir% (
    rmdir /S /Q %cjson_install_dir%
)

7z x -aoa %cjson_pkg_name%.zip

cd /D %cjson_src_dir%
cmake -G%cmake_gen_type% -S. -B%cjson_build_dir% -DCMAKE_INSTALL_PREFIX=%cjson_install_dir% ^
    -DENABLE_CJSON_TEST=OFF -DENABLE_CJSON_UTILS=ON -DBUILD_SHARED_LIBS=OFF

echo.
echo **** CMAKE VS-PROJECT GENERATED ****
echo.

call %msvc_env%
cd /D %cjson_build_dir%
MSBuild INSTALL.vcxproj /p:Configuration=Release
@REM MSBuild INSTALL.vcxproj /p:Configuration=Debug

echo.
echo **** COMPILATION AND DISTRIBUTION FINISHED ****
echo.

cd /D %work_dir%
rmdir /S /Q %cjson_src_dir% %cjson_build_dir%

echo.
echo **** SRC AND BUILD DIR DELETED ****
echo.

pause