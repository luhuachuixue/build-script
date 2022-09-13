@echo off

setlocal

set version=1.10.0
set work_dir=%~dp0
set work_dir=%work_dir:~0,-1%
set pkg_name=libssh2-%version%
set pkg_file=%pkg_name%.tar.gz
set src_dir=%work_dir%\%pkg_name%
set build_dir=%work_dir%\build
set install_dir=D:\Library\libssh2

set zlib_dir=D:/Library/libzlib
set zlib_inc_dir=%zlib_dir%/include
set zlib_lib=%zlib_dir%/lib/libzlib.dll.a

set compile_core=8

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

if exist %src_dir% (
    rmdir /S /Q %src_dir%
)

if exist %build_dir% (
    rmdir /S /Q %build_dir%
)

if exist %install_dir% (
    rmdir /S /Q %install_dir%
)

7z x %pkg_file% -so | 7z x -aoa -si -ttar

cd /D %src_dir%
cmake -G"MinGW Makefiles" -S. -B%build_dir% -DCMAKE_INSTALL_PREFIX=%install_dir% ^
    -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=OFF -DBUILD_EXAMPLES=OFF -DBUILD_SHARED_LIBS=ON ^
    -DENABLE_ZLIB_COMPRESSION=ON -DZLIB_INCLUDE_DIR=%zlib_inc_dir% -DZLIB_LIBRARY=%zlib_lib%

echo.
echo **** CMAKE MAKEFILE GENERATED ****
echo.

cd /D %build_dir%
mingw32-make -j%compile_core%

echo.
echo **** COMPILATION FINISHED ****
echo.

mingw32-make install

cd /D %zlib_dir%
copy bin\*.dll %install_dir%\bin

echo.
echo **** BINARY DISTRIBUTION FINISHED ****
echo.

cd /D %work_dir%
rmdir /S /Q %src_dir% %build_dir%

echo.
echo **** SRC AND BUILD DIR DELETED ****
echo.

pause