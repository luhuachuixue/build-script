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
set install_dir=D:\Library\Qt-MSVC
set pkg_dir=%~dp0
set pkg_dir=%pkg_dir:~0,-1%
set qt_env=%pkg_dir%\qtenv2.bat

set qt_llvm_dir=D:\Library\libclang

set compile_core=8
@REM ----------------------------------------
@REM 0: debug+release; 1: debug; 2: release;
@REM ----------------------------------------
set compile_type=0

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
) else (
    set msvc_bat=vcvars32.bat
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

where /Q ninja
if errorlevel 1 (
    echo **** CANNOT FIND NINJA ****
    pause
    exit
)

@REM where /Q jom
@REM if errorlevel 1 (
@REM     echo **** CANNOT FIND JOM ****
@REM     pause
@REM     exit
@REM )

if not exist %msvc_env% (
    echo **** UNSET CORRECT MSVC ENV ****
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

mkdir %build_dir%

call %msvc_env%

cd /D %build_dir%
call %src_dir%\configure.bat -prefix %install_dir% -opensource -confirm-license ^
                    -qt-zlib -qt-libpng -qt-libjpeg -qt-pcre -qt-freetype -qt-harfbuzz ^
                    -opengl dynamic -skip qtwebengine -nomake tests -nomake examples ^
                    -shared %config_opt% -strip -platform win32-msvc -mp

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
    echo **** VS-PROJECT GENERATED ****
    echo.

    @REM jom -j%compile_core%
    nmake

    echo.
    echo **** COMPILATION FINISHED ****
    echo.

    @REM jom -j%compile_core% install
    nmake install
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