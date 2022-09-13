@echo off

setlocal

set version=1.1.1q
set work_dir=%~dp0
set work_dir=%work_dir:~0,-1%
set pkg_name=openssl-%version%
set pkg_file=%pkg_name%.tar.gz
set src_dir=%work_dir%\%pkg_name%
set install_dir=D:\Library\OpenSSL
set ssl_dir=%install_dir%\ssl

set vs_version=2022
@REM set vs_version=2017
set arch="x64"
@REM set arch="x86"

if %vs_version% == 2022 (
    set msvc_prefix="C:/Program Files/Microsoft Visual Studio/2022/Enterprise/VC/Auxiliary/Build"
) else (
    set msvc_prefix="C:/Program Files (x86)/Microsoft Visual Studio/2017/Enterprise/VC/Auxiliary/Build"
)

if %arch% == "x64" (
    set msvc_bat=vcvars64.bat
    set target_platform=VC-WIN64A
) else (
    set msvc_bat=vcvars32.bat
    set target_platform=VC-WIN32
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

where /Q perl
if errorlevel 1 (
    echo **** CANNOT FIND PERL ****
    pause
    exit
)

where /Q nasm
if errorlevel 1 (
    echo **** CANNOT FIND NASM ****
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

if exist %install_dir% (
    rmdir /S /Q %install_dir%
)

7z x %pkg_file% -so | 7z x -aoa -si -ttar
del /Q pax_global_header

cd /D %src_dir%
perl Configure %target_platform% --prefix=%install_dir% --openssldir=%ssl_dir%
@REM perl Configure %target_platform% --prefix=%install_dir% --openssldir=%ssl_dir% no-asm no-shared

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
rmdir /S /Q %src_dir%

echo.
echo **** SRC DIR DELETED ****
echo.

pause