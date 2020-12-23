@echo off

setlocal

set eigen_version=3.3.9
set work_dir=%~dp0
set work_dir=%work_dir:~0,-1%
set eigen_pkg_name=eigen-%eigen_version%
set eigen_src_dir=%work_dir%\%eigen_pkg_name%
set eigen_build_dir=%work_dir%\build
set eigen_install_dir=D:\Library\libeigen
set cmake_boost_dir=D:\Library\libboost\lib\cmake\Boost-1.75.0
set cmake_gen_type="Visual Studio 15 2017 Win64"
set msvc_env="C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\VC\Auxiliary\Build\vcvars64.bat"

if not exist %eigen_pkg_name%.zip (
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

if exist %eigen_src_dir% (
    rmdir /S /Q %eigen_src_dir%
)

if exist %eigen_build_dir% (
    rmdir /S /Q %eigen_build_dir%
)

if exist %eigen_install_dir% (
    rmdir /S /Q %eigen_install_dir%
)

7z x -aoa %eigen_pkg_name%.zip

cd /D %eigen_src_dir%
cmake -G%cmake_gen_type% -S. -B%eigen_build_dir% -DCMAKE_INSTALL_PREFIX=%eigen_install_dir% -DEIGEN_TEST_CXX11=ON -DBoost_DIR=%cmake_boost_dir%

echo.
echo **** CMAKE VS-PROJECT GENERATED ****
echo.

call %msvc_env%
cd /D %eigen_build_dir%
MSBuild INSTALL.vcxproj /p:Configuration=Release

echo.
echo **** COMPILATION AND DISTRIBUTION FINISHED ****
echo.

cd /D %work_dir%
rmdir /S /Q %eigen_src_dir% %eigen_build_dir%

echo.
echo **** SRC AND BUILD DIR DELETED ****
echo.

pause