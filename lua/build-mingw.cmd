@echo off

setlocal

set version=5.4.4
set work_dir=%~dp0
set work_dir=%work_dir:~0,-1%
set pkg_name=lua-%version%
set pkg_file=%pkg_name%.tar.gz
set src_dir=%work_dir%\%pkg_name%
set install_dir=D:\Library\lua

set compile_core=8

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

where /Q mingw32-make
if errorlevel 1 (
    echo **** CANNOT FIND MINGW32-MAKE ****
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

cd /D %src_dir%
mingw32-make PLAT=mingw -j%compile_core%

echo.
echo **** COMPILATION FINISHED ****
echo.

mkdir %install_dir%
mkdir %install_dir%\bin
mkdir %install_dir%\include
mkdir %install_dir%\lib

copy %src_dir%\src\*.exe %install_dir%\bin
copy %src_dir%\src\*.dll %install_dir%\bin
copy %src_dir%\src\lua.hpp %install_dir%\include
copy %src_dir%\src\lua.h %install_dir%\include
copy %src_dir%\src\luaconf.h %install_dir%\include
copy %src_dir%\src\lualib.h %install_dir%\include
copy %src_dir%\src\lauxlib.h %install_dir%\include
copy %src_dir%\src\*.a %install_dir%\lib

echo.
echo **** BINARY DISTRIBUTION FINISHED ****
echo.

%install_dir%\bin\lua.exe -v

echo.
echo **** BINARY DISTRIBUTION TEST SUCCESSFULLY ****
echo.

cd /D %work_dir%
rmdir /S /Q %src_dir%

echo.
echo **** SRC DIR DELETED ****
echo.

pause