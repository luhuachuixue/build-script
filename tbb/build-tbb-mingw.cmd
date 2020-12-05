@echo off

setlocal

set tbb_version=2020.3
set work_dir=%~dp0
set work_dir=%work_dir:~0,-1%
set tbb_pkg_name=oneTBB-%tbb_version%
set tbb_src_dir=%work_dir%\%tbb_pkg_name%
set tbb_install_dir=D:\Library\libtbb

if not exist %tbb_pkg_name%.zip (
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

where /Q mingw32-make
if errorlevel 1 (
    echo **** CANNOT FIND MINGW ****
    pause
    exit
)

if exist %tbb_src_dir% (
    rmdir /S /Q %tbb_src_dir%
)

if exist %tbb_install_dir% (
    rmdir /S /Q %tbb_install_dir%
)

7z x -aoa %tbb_pkg_name%.zip

cd /D %tbb_src_dir%
mingw32-make -j8 stdver=c++11 compiler=gcc arch=intel64 runtime=mingw

echo.
echo **** COMPILATION FINISHED ****
echo.

mkdir %tbb_install_dir%
mkdir %tbb_install_dir%\include
mkdir %tbb_install_dir%\bin
mkdir %tbb_install_dir%\lib

xcopy /E %tbb_src_dir%\include %tbb_install_dir%\include
cd build\windows_intel64_gcc_mingw*
copy *.dll %tbb_install_dir%\bin
copy *.a %tbb_install_dir%\lib
copy *.def %tbb_install_dir%\lib
copy *.o %tbb_install_dir%\lib
copy *.d %tbb_install_dir%\lib

echo.
echo **** BINARY DISTRIBUTION FINISHED ****
echo.

cd /D %work_dir%
rmdir /S /Q %tbb_src_dir%

echo.
echo **** SRC DIR DELETED ****
echo.

pause