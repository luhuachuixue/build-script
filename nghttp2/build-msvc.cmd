@echo off

setlocal

set version=1.49.0
set work_dir=%~dp0
set work_dir=%work_dir:~0,-1%
set pkg_name=nghttp2-%version%
set pkg_file=%pkg_name%.tar.xz
set src_dir=%work_dir%\%pkg_name%
set build_dir=%work_dir%\build
set install_dir=D:\Library\nghttp2

set openssl_dir=D:/Library/OpenSSL
set zlib_dir=D:/Library/libzlib
set zlib_inc_dir=%zlib_dir%/include
set zlib_lib=%zlib_dir%/lib/zlib.lib

set vs_version=2022
@REM set vs_version=2017
set arch="x64"
@REM set arch="x86"

if %vs_version% == 2022 (
    set msvc_prefix="C:/Program Files/Microsoft Visual Studio/2022/Enterprise/VC/Auxiliary/Build"
    set cmake_gen_type="Visual Studio 17 2022"
) else (
    set msvc_prefix="C:/Program Files (x86)/Microsoft Visual Studio/2017/Enterprise/VC/Auxiliary/Build"
    set cmake_gen_type="Visual Studio 15 2017"
)

if %arch% == "x64" (
    set msvc_bat=vcvars64.bat
    set cmake_gen_arch=x64
) else (
    set msvc_bat=vcvars32.bat
    set cmake_gen_arch=Win32
)

set msvc_env=%msvc_prefix%/%msvc_bat%

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

if not exist %msvc_env% (
    echo **** UNSET CORRECT MSVC ENV ****
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
cmake -G%cmake_gen_type% -A%cmake_gen_arch% -S. -B%build_dir% -DCMAKE_INSTALL_PREFIX=%install_dir% ^
    -DCMAKE_BUILD_TYPE=Release -DENABLE_LIB_ONLY=ON -DENABLE_SHARED_LIB=ON -DENABLE_STATIC_LIB=OFF -DENABLE_APP=OFF -DENABLE_HTTP3=OFF ^
    -DOPENSSL_ROOT_DIR=%openssl_dir% -DZLIB_INCLUDE_DIR=%zlib_inc_dir% -DZLIB_LIBRARY=%zlib_lib%

echo.
echo **** CMAKE VS-PROJECT GENERATED ****
echo.

call %msvc_env%
cd /D %build_dir%
MSBuild INSTALL.vcxproj /p:Configuration=Release
@REM MSBuild INSTALL.vcxproj /p:Configuration=Debug

cd /D %openssl_dir%
copy bin\*.dll %install_dir%\bin
cd /D %zlib_dir%
copy bin\*.dll %install_dir%\bin

echo.
echo **** COMPILATION AND DISTRIBUTION FINISHED ****
echo.

cd /D %work_dir%
rmdir /S /Q %src_dir% %build_dir%

echo.
echo **** SRC AND BUILD DIR DELETED ****
echo.

pause