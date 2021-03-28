@echo off

setlocal

set portaudio_version=19.7.0
set work_dir=%~dp0
set work_dir=%work_dir:~0,-1%
set portaudio_pkg_name=pa_stable_candidate_v190700_20210307
set portaudio_src_dir=%work_dir%\%portaudio_pkg_name%
set portaudio_build_dir=%work_dir%\tmp-build
set portaudio_install_dir=D:\Library\libportaudio
set cmake_gen_type="Visual Studio 15 2017 Win64"
set msvc_env="C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\VC\Auxiliary\Build\vcvars64.bat"
@REM set cmake_gen_type="Visual Studio 15 2017"
@REM set msvc_env="C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\VC\Auxiliary\Build\vcvars32.bat"

if not exist %portaudio_pkg_name%.zip (
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

if exist %portaudio_src_dir% (
    rmdir /S /Q %portaudio_src_dir%
)

if exist %portaudio_build_dir% (
    rmdir /S /Q %portaudio_build_dir%
)

if exist %portaudio_install_dir% (
    rmdir /S /Q %portaudio_install_dir%
)

7z x -aoa %portaudio_pkg_name%.zip

cd /D %portaudio_src_dir%
cmake -G%cmake_gen_type% -S. -B%portaudio_build_dir% -DCMAKE_INSTALL_PREFIX=%portaudio_install_dir% ^
    -DPA_BUILD_SHARED=OFF -DPA_BUILD_STATIC=ON

echo.
echo **** CMAKE VS-PROJECT GENERATED ****
echo.

call %msvc_env%
cd /D %portaudio_build_dir%
MSBuild INSTALL.vcxproj /p:Configuration=Release
@REM MSBuild INSTALL.vcxproj /p:Configuration=Debug

echo.
echo **** COMPILATION AND DISTRIBUTION FINISHED ****
echo.

cd /D %work_dir%
rmdir /S /Q %portaudio_src_dir% %portaudio_build_dir%

echo.
echo **** SRC AND BUILD DIR DELETED ****
echo.

pause