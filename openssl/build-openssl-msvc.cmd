@echo off

setlocal

set openssl_version=1.1.1l
set work_dir=%~dp0
set work_dir=%work_dir:~0,-1%
set openssl_pkg_name=openssl-%openssl_version%
set openssl_src_dir=%work_dir%\%openssl_pkg_name%
set openssl_install_dir=D:\Library\OpenSSL
set openssl_ssl_dir=%openssl_install_dir%\ssl
set target_platform=VC-WIN64A
set msvc_env="C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\VC\Auxiliary\Build\vcvars64.bat"
@REM set target_platform=VC-WIN32
@REM set msvc_env="C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\VC\Auxiliary\Build\vcvars32.bat"

if not exist %openssl_pkg_name%.tar.gz (
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

where /Q perl
if errorlevel 1 (
    echo **** CANNOT FIND PERL ****
    pause
    exit
)

if not exist %msvc_env% (
    echo **** UNSET CORRECT MSVC ENV ****
    pause
    exit
)

if exist %openssl_src_dir% (
    rmdir /S /Q %openssl_src_dir%
)

if exist %openssl_install_dir% (
    rmdir /S /Q %openssl_install_dir%
)

7z x -aoa %openssl_pkg_name%.tar.gz
7z x -aoa %openssl_pkg_name%.tar
del /Q %openssl_pkg_name%.tar pax_global_header

cd /D %openssl_src_dir%
perl Configure %target_platform% --prefix=%openssl_install_dir% --openssldir=%openssl_ssl_dir%

echo.
echo **** NMAKE FILE GENERATED ****
echo.

call %msvc_env%
nmake

echo.
echo **** COMPILATION FINISHED ****
echo.

nmake install

echo.
echo **** BINARY DISTRIBUTION FINISHED ****
echo.

cd /D %work_dir%
rmdir /S /Q %openssl_src_dir%

echo.
echo **** SRC DIR DELETED ****
echo.

pause