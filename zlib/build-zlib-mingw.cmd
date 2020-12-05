@echo off

setlocal

set zlib_version=1.2.11
set work_dir=%~dp0
set work_dir=%work_dir:~0,-1%
set zlib_pkg_name=zlib-%zlib_version%
set zlib_src_dir=%work_dir%\%zlib_pkg_name%
set zlib_build_dir=%work_dir%\build
set zlib_install_dir=D:\Library\libzlib

if not exist %zlib_pkg_name%.zip (
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

if exist %zlib_src_dir% (
    rmdir /S /Q %zlib_src_dir%
)

if exist %zlib_build_dir% (
    rmdir /S /Q %zlib_build_dir%
)

if exist %zlib_install_dir% (
    rmdir /S /Q %zlib_install_dir%
)

7z x -aoa %zlib_pkg_name%.zip

cd /D %zlib_src_dir%
cmake -G"MinGW Makefiles" -S. -B%zlib_build_dir% -DCMAKE_INSTALL_PREFIX=%zlib_install_dir%

echo.
echo **** CMAKE MAKEFILE GENERATED ****
echo.

cd /D %zlib_build_dir%
mingw32-make -j8

echo.
echo **** COMPILATION FINISHED ****
echo.

mingw32-make install

echo.
echo **** BINARY DISTRIBUTION FINISHED ****
echo.

cd /D %work_dir%
rmdir /S /Q %zlib_src_dir% %zlib_build_dir%

echo.
echo **** SRC AND BUILD DIR DELETED ****
echo.

pause