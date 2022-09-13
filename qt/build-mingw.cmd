@echo off

setlocal

set ver_major=6
set ver_minor=3
set ver_patch=2
set version=%ver_major%.%ver_minor%.%ver_patch%
set work_dir=D:\tmp
set pkg_name=qt-everywhere-src-%version%
set pkg_file=%pkg_name%.zip
set src_dir=%work_dir%\%pkg_name%
set build_dir=%work_dir%\build
set install_dir=D:\Library\Qt-MinGW
set pkg_dir=%~dp0
set pkg_dir=%pkg_dir:~0,-1%
set qt_env=%pkg_dir%\qtenv2.bat

set qt_llvm_dir=D:\Library\libclang

set compile_core=8
@REM ----------------------------------------
@REM 0: debug+release; 1: debug; 2: release;
@REM ----------------------------------------
set compile_type=0

set windows_sdk_ver=10.0.19041.0
@REM set windows_sdk_ver=10.0.17763.0
set arch="x64"
@REM set arch="x86"

@REM set windows_sdk_prefix=C:\Program Files (x86)\Windows Kits\10\bin\%windows_sdk_ver%
@REM if %arch% == "x64" (
@REM     set windows_sdk_arch=x64
@REM ) else (
@REM     set windows_sdk_arch=x86
@REM )
@REM set windows_sdk=%windows_sdk_prefix%\%windows_sdk_arch%
@REM set PATH=%windows_sdk%;%PATH%

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

where /Q ninja
if errorlevel 1 (
    echo **** CANNOT FIND NINJA ****
    pause
    exit
)

where /Q mingw32-make
if errorlevel 1 (
    echo **** CANNOT FIND MINGW32-MAKE ****
    pause
    exit
)

if not exist %work_dir% (
    mkdir %work_dir%
)

if not exist %src_dir% (
    7z x -aoa %pkg_file% -o%work_dir%
)

if exist %build_dir% (
    rmdir /S /Q %build_dir%
)

if exist %install_dir% (
    rmdir /S /Q %install_dir%
)

if %compile_type% == 0 (
    set config_opt=-debug-and-release
) else if %compile_type% == 1 (
    set config_opt=-debug
) else (
    set config_opt=-release -optimize-size
    set LLVM_INSTALL_DIR=%qt_llvm_dir%
)

where /Q fxc
if errorlevel 1 (
    echo **** CANNOT FIND D3D FXC ****

    if %ver_major% GEQ 6 (
        set config_d3d12=
    ) else (
        set config_d3d12=-no-feature-d3d12
    )
) else (
    echo **** FIND D3D FXC RELEASE ONLY ****

    set config_d3d12=
    set config_opt=-release -optimize-size
    set LLVM_INSTALL_DIR=%qt_llvm_dir%
)

if %ver_major% GEQ 6 (
    set config_quick3d=-no-quick3d-assimp
    set LLVM_INSTALL_DIR=
) else (
    set config_quick3d=
)

mkdir %build_dir%

cd /D %build_dir%
call %src_dir%\configure.bat -prefix %install_dir% -opensource -confirm-license ^
                    -qt-zlib -qt-libpng -qt-libjpeg -qt-pcre -qt-freetype -qt-harfbuzz ^
                    -opengl desktop %config_d3d12% %config_quick3d% -skip qtwebengine -nomake tests -nomake examples ^
                    -shared %config_opt% -strip -platform win32-g++ -no-pch

if %ver_major% GEQ 6 (
    echo.
    echo **** CMAKE-PROJECT GENERATED ****
    echo.

    cmake --build . --parallel

    echo.
    echo **** COMPILATION FINISHED ****
    echo.

    cmake --install .
) else (
    echo.
    echo **** MAKEFILE GENERATED ****
    echo.

    mingw32-make -j%compile_core%

    echo.
    echo **** COMPILATION FINISHED ****
    echo.

    mingw32-make -j%compile_core% install
)

if exist %qt_env% (
    echo **** FIND QT ENV ****
    copy %qt_env% %install_dir%\bin
)

echo.
echo **** DISTRIBUTION FINISHED ****
echo.

cd /D %work_dir%
rmdir /S /Q %build_dir%

echo.
echo **** BUILD DIR DELETED ****
echo.

pause