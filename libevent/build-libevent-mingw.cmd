@echo off

setlocal

set libevent_version=2.1.12
set work_dir=%~dp0
set work_dir=%work_dir:~0,-1%
set libevent_pkg_name=libevent-%libevent_version%-stable
set libevent_src_dir=%work_dir%\%libevent_pkg_name%
set libevent_build_dir=%work_dir%\build
set libevent_install_dir=D:\Library\libevent
set openssl_root_dir=D:\Library\OpenSSL
set zlib_inc_dir=D:\Library\libzlib\include
set zlib_lib=D:\Library\libzlib\lib\libzlib.dll.a

if not exist %libevent_pkg_name%.tar.gz (
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

if exist %libevent_src_dir% (
    rmdir /S /Q %libevent_src_dir%
)

if exist %libevent_build_dir% (
    rmdir /S /Q %libevent_build_dir%
)

if exist %libevent_install_dir% (
    rmdir /S /Q %libevent_install_dir%
)

7z x -aoa %libevent_pkg_name%.tar.gz
7z x -aoa %libevent_pkg_name%.tar
del /Q %libevent_pkg_name%.tar

cd /D %libevent_src_dir%
cmake -G"MinGW Makefiles" -S. -B%libevent_build_dir% -DCMAKE_INSTALL_PREFIX=%libevent_install_dir% ^
    -DOPENSSL_ROOT_DIR=%openssl_root_dir% -DZLIB_INCLUDE_DIR=%zlib_inc_dir% -DZLIB_LIBRARY=%zlib_lib%

echo.
echo **** CMAKE MAKEFILE GENERATED ****
echo.

cd /D %libevent_build_dir%
mingw32-make -j8

echo.
echo **** COMPILATION FINISHED ****
echo.

mingw32-make install
move %libevent_install_dir%\lib\*.dll %libevent_install_dir%\bin

echo.
echo **** BINARY DISTRIBUTION FINISHED ****
echo.

cd /D %work_dir%
rmdir /S /Q %libevent_src_dir% %libevent_build_dir%

echo.
echo **** SRC AND BUILD DIR DELETED ****
echo.

pause