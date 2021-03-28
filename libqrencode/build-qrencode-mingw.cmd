@echo off

setlocal

set qrencode_version=4.1.1
set work_dir=%~dp0
set work_dir=%work_dir:~0,-1%
set qrencode_pkg_name=libqrencode-%qrencode_version%
set qrencode_src_dir=%work_dir%\%qrencode_pkg_name%
set qrencode_build_dir=%work_dir%\build
set qrencode_install_dir=D:\Library\libqrencode

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

where /Q mingw32-make
if errorlevel 1 (
    echo **** CANNOT FIND MINGW32-MAKE ****
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
cmake -G"MinGW Makefiles" -S. -B%qrencode_build_dir% -DCMAKE_INSTALL_PREFIX=%qrencode_install_dir% ^
    -DBUILD_SHARED_LIBS=OFF -DWITH_TOOLS=OFF

echo.
echo **** CMAKE MAKEFILE GENERATED ****
echo.

cd /D %qrencode_build_dir%
mingw32-make -j8

echo.
echo **** COMPILATION FINISHED ****
echo.

mingw32-make install

echo.
echo **** BINARY DISTRIBUTION FINISHED ****
echo.

cd /D %work_dir%
rmdir /S /Q %qrencode_src_dir% %qrencode_build_dir%

echo.
echo **** SRC AND BUILD DIR DELETED ****
echo.

pause