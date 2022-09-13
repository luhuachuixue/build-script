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

@REM set vs_version=2022
set vs_version=2017
set arch="x64"
@REM set arch="x86"

set qt_prefix=C:/Qt/Qt5.12.12/5.12.12
if %vs_version% == 2022 (
    set msvc_prefix="C:/Program Files/Microsoft Visual Studio/2022/Enterprise/VC/Auxiliary/Build"
    set cmake_gen_type="Visual Studio 17 2022"
    if %arch% == "x64" (
        set qt_toolset=msvc2022_64
    ) else (
        set qt_toolset=msvc2022
    )
) else (
    set msvc_prefix="C:/Program Files (x86)/Microsoft Visual Studio/2017/Enterprise/VC/Auxiliary/Build"
    set cmake_gen_type="Visual Studio 15 2017"
    if %arch% == "x64" (
        set qt_toolset=msvc2017_64
    ) else (
        set qt_toolset=msvc2017
    )
)

if %arch% == "x64" (
    set msvc_bat=vcvars64.bat
    set cmake_gen_arch=x64
) else (
    set msvc_bat=vcvars32.bat
    set cmake_gen_arch=Win32
)

set msvc_env=%msvc_prefix%/%msvc_bat%
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

if not exist %qt_env% (
    echo **** UNSET CORRECT QT ENV ****
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

mkdir %build_dir%

call %qt_env%
call %msvc_env%

cd /D %src_dir%
cmake -G%cmake_gen_type% -A%cmake_gen_arch% -S. -B%build_dir% -DCMAKE_INSTALL_PREFIX=%install_dir% ^
    -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH=%qt_cmake_prefix% ^
    -DJKQtPlotter_BUILD_SHARED_LIBS=ON -DJKQtPlotter_BUILD_STATIC_LIBS=ON -DJKQtPlotter_BUILD_EXAMPLES=OFF

echo.
echo **** CMAKE VS-PROJECT GENERATED ****
echo.

cd /D %build_dir%
MSBuild INSTALL.vcxproj /m /p:Configuration=Release

echo.
echo **** COMPILATION AND DISTRIBUTION FINISHED ****
echo.

cd /D %work_dir%
rmdir /S /Q %src_dir% %build_dir%

echo.
echo **** SRC AND BUILD DIR DELETED ****
echo.

pause