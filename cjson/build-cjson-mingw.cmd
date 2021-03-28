@echo off

setlocal

set cjson_version=1.7.14
set work_dir=%~dp0
set work_dir=%work_dir:~0,-1%
set cjson_pkg_name=cJSON-%cjson_version%
set cjson_src_dir=%work_dir%\%cjson_pkg_name%
set cjson_build_dir=%work_dir%\build
set cjson_install_dir=D:\Library\libcjson

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

where /Q mingw32-make
if errorlevel 1 (
    echo **** CANNOT FIND MINGW32-MAKE ****
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
cmake -G"MinGW Makefiles" -S. -B%cjson_build_dir% -DCMAKE_INSTALL_PREFIX=%cjson_install_dir% ^
    -DENABLE_CJSON_TEST=OFF -DENABLE_CJSON_UTILS=ON -DBUILD_SHARED_LIBS=OFF

echo.
echo **** CMAKE MAKEFILE GENERATED ****
echo.

cd /D %cjson_build_dir%
mingw32-make -j8

echo.
echo **** COMPILATION FINISHED ****
echo.

mingw32-make install

echo.
echo **** BINARY DISTRIBUTION FINISHED ****
echo.

cd /D %work_dir%
rmdir /S /Q %cjson_src_dir% %cjson_build_dir%

echo.
echo **** SRC AND BUILD DIR DELETED ****
echo.

pause