@echo off

setlocal

set version=4.0.0
set work_dir=%~dp0
set work_dir=%work_dir:~0,-1%
set pkg_name=JKQtPlotter-%version%
set pkg_file=%pkg_name%.zip
set src_dir=%work_dir%\%pkg_name%
set build_dir=%work_dir%\build
set install_dir=D:\Library\JKQtPlotter

set compile_core=8
set arch="x64"
@REM set arch="x86"

set qt_prefix=C:/Qt/Qt5.12.12/5.12.12
if %arch% == "x64" (
    set qt_toolset=mingw73_64
) else (
    set qt_toolset=mingw73_32
)
set qt_cmake_prefix=%qt_prefix%/%qt_toolset%
set qt_env="%qt_cmake_prefix%/bin/qtenv2.bat"

if not exist %pkg_file% (
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

if not exist %qt_env% (
    echo **** UNSET CORRECT QT ENV ****
    pause
    exit
)

if exist %src_dir% (
    rmdir /S /Q %src_dir%
)

if exist %build_dir% (
    rmdir /S /Q %build_dir%
)

if exist %install_dir% (
    rmdir /S /Q %install_dir%
)

7z x -aoa %pkg_file%

mkdir %build_dir%

call %qt_env%

cd /D %src_dir%
cmake -G"MinGW Makefiles" -S. -B%build_dir% -DCMAKE_INSTALL_PREFIX=%install_dir% ^
    -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH=%qt_cmake_prefix% ^
    -DJKQtPlotter_BUILD_SHARED_LIBS=ON -DJKQtPlotter_BUILD_STATIC_LIBS=ON -DJKQtPlotter_BUILD_EXAMPLES=OFF

echo.
echo **** CMAKE MAKEFILE GENERATED ****
echo.

cd /D %build_dir%
mingw32-make -j%compile_core% install

echo.
echo **** COMPILATION AND DISTRIBUTION FINISHED ****
echo.

cd /D %work_dir%
rmdir /S /Q %src_dir% %build_dir%

echo.
echo **** SRC AND BUILD DIR DELETED ****
echo.

pause