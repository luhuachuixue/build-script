@echo off

setlocal

set version=7.85.0
set work_dir=%~dp0
set work_dir=%work_dir:~0,-1%
set pkg_name=curl-%version%
set pkg_file=%pkg_name%.zip
set src_dir=%work_dir%\%pkg_name%
set build_dir=%work_dir%\build
set install_dir=D:\Library\curl

set openssl_dir=D:/Library/OpenSSL
set zlib_dir=D:/Library/libzlib
set zlib_inc_dir=%zlib_dir%/include
set zlib_lib=%zlib_dir%/lib/zlib.lib
set zstd_dir=D:/Library/zstd
set zstd_inc_dir=%zstd_dir%/include
set zstd_lib=%zstd_dir%/lib/zstd.lib
set libssh2_dir=D:/Library/libssh2
set libssh2_inc_dir=%libssh2_dir%/include
set libssh2_lib=%libssh2_dir%/lib/libssh2.lib
set nghttp2_dir=D:/Library/nghttp2
set nghttp2_inc_dir=%nghttp2_dir%/include
set nghttp2_lib=%nghttp2_dir%/lib/nghttp2.lib

set compile_full=1
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

7z x -aoa %pkg_file%

cd /D %src_dir%

if %compile_full% == 0 (
    cmake -G%cmake_gen_type% -A%cmake_gen_arch% -S. -B%build_dir% -DCMAKE_INSTALL_PREFIX=%install_dir% ^
        -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=OFF -DBUILD_SHARED_LIBS=ON ^
        -DENABLE_UNIX_SOCKETS=OFF -DUSE_LIBIDN2=OFF -DUSE_WIN32_IDN=ON ^
        -DCURL_ENABLE_SSL=ON -DCURL_USE_OPENSSL=ON -DOPENSSL_ROOT_DIR=%openssl_dir%
) else (
    cmake -G%cmake_gen_type% -A%cmake_gen_arch% -S. -B%build_dir% -DCMAKE_INSTALL_PREFIX=%install_dir% ^
        -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=OFF -DBUILD_SHARED_LIBS=ON ^
        -DENABLE_UNIX_SOCKETS=OFF -DUSE_LIBIDN2=OFF -DUSE_WIN32_IDN=ON ^
        -DCURL_ENABLE_SSL=ON -DCURL_USE_OPENSSL=ON -DOPENSSL_ROOT_DIR=%openssl_dir% ^
        -DCURL_ZLIB=ON -DZLIB_INCLUDE_DIR=%zlib_inc_dir% -DZLIB_LIBRARY=%zlib_lib% ^
        -DCURL_ZSTD=ON -DZstd_INCLUDE_DIR=%zstd_inc_dir% -DZstd_LIBRARY=%zstd_lib% ^
        -DLIBSSH2_INCLUDE_DIR=%libssh2_inc_dir% -DLIBSSH2_LIBRARY=%libssh2_lib% ^
        -DUSE_NGHTTP2=ON -DNGHTTP2_INCLUDE_DIR=%nghttp2_inc_dir% -DNGHTTP2_LIBRARY=%nghttp2_lib%
)

echo.
echo **** CMAKE VS-PROJECT GENERATED ****
echo.

call %msvc_env%
cd /D %build_dir%
MSBuild INSTALL.vcxproj /p:Configuration=Release
@REM MSBuild INSTALL.vcxproj /p:Configuration=Debug

cd /D %openssl_dir%
copy bin\*.dll %install_dir%\bin

if %compile_full% == 1 (
    cd /D %zlib_dir%
    copy bin\*.dll %install_dir%\bin
    cd /D %zstd_dir%
    copy bin\*.dll %install_dir%\bin
    cd /D %libssh2_dir%
    copy bin\*.dll %install_dir%\bin
    cd /D %nghttp2_dir%
    copy bin\*.dll %install_dir%\bin
)

echo.
echo **** COMPILATION AND DISTRIBUTION FINISHED ****
echo.

cd /D %work_dir%
rmdir /S /Q %src_dir% %build_dir%

echo.
echo **** SRC AND BUILD DIR DELETED ****
echo.

pause