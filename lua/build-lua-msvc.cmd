@echo off

setlocal

set lua_ver_major=5
set lua_ver_minor=4
set lua_ver_patch=3
set lua_suffix=%lua_ver_major%%lua_ver_minor%
set lua_version=%lua_ver_major%.%lua_ver_minor%.%lua_ver_patch%
set work_dir=%~dp0
set work_dir=%work_dir:~0,-1%
set lua_pkg_name=lua-%lua_version%
set lua_src_dir=%work_dir%\%lua_pkg_name%
set lua_install_dir=D:\Library\lua
set msvc_env="C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\VC\Auxiliary\Build\vcvars64.bat"
@REM set msvc_env="C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\VC\Auxiliary\Build\vcvars32.bat"

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

if not exist %msvc_env% (
    echo **** UNSET CORRECT MSVC ENV ****
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

mkdir %lua_install_dir%
mkdir %lua_install_dir%\bin
mkdir %lua_install_dir%\include
mkdir %lua_install_dir%\lib

call %msvc_env%
cd /D %lua_src_dir%\src
cl /c /nologo /W3 /O2 /Ob1 /Oi /Gs /MD /D_CRT_SECURE_NO_DEPRECATE l*.c
del /Q lua.obj luac.obj
lib /OUT:liblua%lua_suffix%.lib *.obj
copy *.lib %lua_install_dir%\lib
del /Q *.obj

echo.
echo **** STATIC LIBRARY GENERATED ****
echo.

cl /c /nologo /W3 /O2 /Ob1 /Oi /Gs /MD /D_CRT_SECURE_NO_DEPRECATE /DLUA_BUILD_AS_DLL l*.c
rename lua.obj lua.o
rename luac.obj luac.o
link /DLL /IMPLIB:lua%lua_suffix%.lib /OUT:lua%lua_suffix%.dll *.obj
link /OUT:lua.exe lua.o lua%lua_suffix%.lib
link /OUT:luac.exe luac.o *.obj
del /Q luac.exp luac.lib

echo.
echo **** EXE AND DYNAMIC LIBRARY GENERATED ****
echo.

copy lua.hpp %lua_install_dir%\include
copy lua.h %lua_install_dir%\include
copy luaconf.h %lua_install_dir%\include
copy lualib.h %lua_install_dir%\include
copy lauxlib.h %lua_install_dir%\include

copy *.exe %lua_install_dir%\bin
copy *.exp %lua_install_dir%\bin
copy *.dll %lua_install_dir%\bin
copy *.lib %lua_install_dir%\lib

echo.
echo **** ALL DISTRIBUTION FINISHED ****
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