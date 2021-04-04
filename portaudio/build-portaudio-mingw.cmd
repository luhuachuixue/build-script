@echo off

setlocal

set portaudio_version=19.7.0
set work_dir=%~dp0
set work_dir=%work_dir:~0,-1%
set portaudio_pkg_name=portaudio-19.7.0-RC2
set portaudio_src_dir=%work_dir%\%portaudio_pkg_name%
set portaudio_build_dir=%work_dir%\tmp-build
set portaudio_install_dir=D:\Library\libportaudio

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

where /Q mingw32-make
if errorlevel 1 (
    echo **** CANNOT FIND MINGW32-MAKE ****
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
cmake -G"MinGW Makefiles" -S. -B%portaudio_build_dir% -DCMAKE_INSTALL_PREFIX=%portaudio_install_dir% ^
    -DPA_BUILD_SHARED=OFF -DPA_BUILD_STATIC=ON

echo.
echo **** CMAKE MAKEFILE GENERATED ****
echo.

cd /D %portaudio_build_dir%
mingw32-make -j8

echo.
echo **** COMPILATION FINISHED ****
echo.

mingw32-make install

echo.
echo **** BINARY DISTRIBUTION FINISHED ****
echo.

cd /D %work_dir%
rmdir /S /Q %portaudio_src_dir% %portaudio_build_dir%

echo.
echo **** SRC AND BUILD DIR DELETED ****
echo.

pause