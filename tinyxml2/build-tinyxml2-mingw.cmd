@echo off

setlocal

set tinyxml2_version=9.0.0
set work_dir=%~dp0
set work_dir=%work_dir:~0,-1%
set tinyxml2_pkg_name=tinyxml2-%tinyxml2_version%
set tinyxml2_src_dir=%work_dir%\%tinyxml2_pkg_name%
set tinyxml2_build_dir=%work_dir%\build
set tinyxml2_install_dir=D:\Library\libtinyxml2

if not exist %tinyxml2_pkg_name%.zip (
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

if exist %tinyxml2_src_dir% (
    rmdir /S /Q %tinyxml2_src_dir%
)

if exist %tinyxml2_build_dir% (
    rmdir /S /Q %tinyxml2_build_dir%
)

if exist %tinyxml2_install_dir% (
    rmdir /S /Q %tinyxml2_install_dir%
)

7z x -aoa %tinyxml2_pkg_name%.zip

cd /D %tinyxml2_src_dir%
cmake -G"MinGW Makefiles" -S. -B%tinyxml2_build_dir% -DCMAKE_INSTALL_PREFIX=%tinyxml2_install_dir% -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=OFF

echo.
echo **** CMAKE MAKEFILE GENERATED ****
echo.

cd /D %tinyxml2_build_dir%
mingw32-make

echo.
echo **** COMPILATION FINISHED ****
echo.

mingw32-make install

echo.
echo **** BINARY DISTRIBUTION FINISHED ****
echo.

cd /D %work_dir%
rmdir /S /Q %tinyxml2_src_dir% %tinyxml2_build_dir%

echo.
echo **** SRC AND BUILD DIR DELETED ****
echo.

pause