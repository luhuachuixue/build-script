@echo off

setlocal

set nlohmann_version=3.9.1
set work_dir=%~dp0
set work_dir=%work_dir:~0,-1%
set nlohmann_pkg_name=json-%nlohmann_version%
set nlohmann_src_dir=%work_dir%\%nlohmann_pkg_name%
set nlohmann_build_dir=%work_dir%\build
set nlohmann_install_dir=D:\Library\libnlohmann

if not exist %nlohmann_pkg_name%.zip (
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

if exist %nlohmann_src_dir% (
    rmdir /S /Q %nlohmann_src_dir%
)

if exist %nlohmann_build_dir% (
    rmdir /S /Q %nlohmann_build_dir%
)

if exist %nlohmann_install_dir% (
    rmdir /S /Q %nlohmann_install_dir%
)

7z x -aoa %nlohmann_pkg_name%.zip

cd /D %nlohmann_src_dir%
cmake -G"MinGW Makefiles" -S. -B%nlohmann_build_dir% -DCMAKE_INSTALL_PREFIX=%nlohmann_install_dir% -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=OFF

echo.
echo **** CMAKE MAKEFILE GENERATED ****
echo.

cd /D %nlohmann_build_dir%
mingw32-make

echo.
echo **** COMPILATION FINISHED ****
echo.

mingw32-make install

echo.
echo **** BINARY DISTRIBUTION FINISHED ****
echo.

cd /D %work_dir%
rmdir /S /Q %nlohmann_src_dir% %nlohmann_build_dir%

echo.
echo **** SRC AND BUILD DIR DELETED ****
echo.

pause