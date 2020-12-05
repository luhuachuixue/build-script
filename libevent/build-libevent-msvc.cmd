@echo off

setlocal

set libevent_version=2.1.12
set work_dir=%~dp0
set work_dir=%work_dir:~0,-1%
set libevent_pkg_name=libevent-release-%libevent_version%-stable
set libevent_src_dir=%work_dir%\%libevent_pkg_name%
set libevent_build_dir=%work_dir%\build
set libevent_install_dir=D:\Library\libevent
set openssl_root_dir=D:\Library\OpenSSL
set zlib_inc_dir=D:\Library\libzlib\include
set zlib_lib=D:\Library\libzlib\lib\zlib.lib
set cmake_gen_type="Visual Studio 15 2017 Win64"
set msvc_env="C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\VC\Auxiliary\Build\vcvars64.bat"

if not exist %libevent_pkg_name%.zip (
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

if exist %libevent_src_dir% (
    rmdir /S /Q %libevent_src_dir%
)

if exist %libevent_build_dir% (
    rmdir /S /Q %libevent_build_dir%
)

if exist %libevent_install_dir% (
    rmdir /S /Q %libevent_install_dir%
)

7z x -aoa %libevent_pkg_name%.zip

cd /D %libevent_src_dir%
cmake -G%cmake_gen_type% -S. -B%libevent_build_dir% -DCMAKE_INSTALL_PREFIX=%libevent_install_dir% ^
    -DOPENSSL_ROOT_DIR=%openssl_root_dir% -DZLIB_INCLUDE_DIR=%zlib_inc_dir% -DZLIB_LIBRARY=%zlib_lib%

echo.
echo **** CMAKE VS-PROJECT GENERATED ****
echo.

call %msvc_env%
cd /D %libevent_build_dir%
MSBuild INSTALL.vcxproj /p:Configuration=Release
@REM MSBuild INSTALL.vcxproj /p:Configuration=Debug

move %libevent_install_dir%\lib\*.dll %libevent_install_dir%\bin

echo.
echo **** COMPILATION AND DISTRIBUTION FINISHED ****
echo.

cd /D %work_dir%
rmdir /S /Q %libevent_src_dir% %libevent_build_dir%

echo.
echo **** SRC AND BUILD DIR DELETED ****
echo.

pause