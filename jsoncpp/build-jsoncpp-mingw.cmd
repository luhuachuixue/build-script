@echo off

setlocal

set jsoncpp_version=1.9.4
set work_dir=%~dp0
set work_dir=%work_dir:~0,-1%
set jsoncpp_pkg_name=jsoncpp-%jsoncpp_version%
set jsoncpp_src_dir=%work_dir%\%jsoncpp_pkg_name%
set jsoncpp_build_dir=%work_dir%\build
set jsoncpp_install_dir=D:\Library\libjsoncpp

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

where /Q mingw32-make
if errorlevel 1 (
    echo **** CANNOT FIND MINGW32-MAKE ****
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
cmake -G"MinGW Makefiles" -S. -B%jsoncpp_build_dir% -DCMAKE_INSTALL_PREFIX=%jsoncpp_install_dir% ^
    -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=OFF -DBUILD_STATIC_LIBS=ON

echo.
echo **** CMAKE MAKEFILE GENERATED ****
echo.

cd /D %jsoncpp_build_dir%
mingw32-make -j8

echo.
echo **** COMPILATION FINISHED ****
echo.

mingw32-make install

echo.
echo **** BINARY DISTRIBUTION FINISHED ****
echo.

cd /D %work_dir%
rmdir /S /Q %jsoncpp_src_dir% %jsoncpp_build_dir%

echo.
echo **** SRC AND BUILD DIR DELETED ****
echo.

pause