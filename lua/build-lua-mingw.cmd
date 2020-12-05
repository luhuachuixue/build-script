@echo off

setlocal

set lua_version=5.4.2
set work_dir=%~dp0
set work_dir=%work_dir:~0,-1%
set lua_pkg_name=lua-%lua_version%
set lua_src_dir=%work_dir%\%lua_pkg_name%
set lua_install_dir=D:\Library\lua

if not exist %lua_pkg_name%.tar.gz (
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

if exist %lua_src_dir% (
    rmdir /S /Q %lua_src_dir%
)

if exist %lua_install_dir% (
    rmdir /S /Q %lua_install_dir%
)

7z x -aoa %lua_pkg_name%.tar.gz
7z x -aoa %lua_pkg_name%.tar
del /Q %lua_pkg_name%.tar

cd /D %lua_src_dir%
mingw32-make PLAT=mingw -j8

echo.
echo **** COMPILATION FINISHED ****
echo.

mkdir %lua_install_dir%
mkdir %lua_install_dir%\bin
mkdir %lua_install_dir%\include
mkdir %lua_install_dir%\lib

copy %lua_src_dir%\src\*.exe %lua_install_dir%\bin
copy %lua_src_dir%\src\*.dll %lua_install_dir%\bin
copy %lua_src_dir%\src\lua.hpp %lua_install_dir%\include
copy %lua_src_dir%\src\lua.h %lua_install_dir%\include
copy %lua_src_dir%\src\luaconf.h %lua_install_dir%\include
copy %lua_src_dir%\src\lualib.h %lua_install_dir%\include
copy %lua_src_dir%\src\lauxlib.h %lua_install_dir%\include
copy %lua_src_dir%\src\*.a %lua_install_dir%\lib

echo.
echo **** BINARY DISTRIBUTION FINISHED ****
echo.

%lua_install_dir%\bin\lua.exe -v

echo.
echo **** BINARY DISTRIBUTION TEST SUCCESSFULLY ****
echo.

cd /D %work_dir%
rmdir /S /Q %lua_src_dir%

echo.
echo **** SRC DIR DELETED ****
echo.

pause