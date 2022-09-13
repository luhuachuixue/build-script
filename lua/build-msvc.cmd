@echo off

setlocal

set ver_major=5
set ver_minor=4
set ver_patch=4
set suffix=%ver_major%%ver_minor%
set version=%ver_major%.%ver_minor%.%ver_patch%
set work_dir=%~dp0
set work_dir=%work_dir:~0,-1%
set pkg_name=lua-%version%
set pkg_file=%pkg_name%.tar.gz
set src_dir=%work_dir%\%pkg_name%
set install_dir=D:\Library\lua

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

if not exist %msvc_env% (
    echo **** UNSET CORRECT MSVC ENV ****
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

mkdir %install_dir%
mkdir %install_dir%\bin
mkdir %install_dir%\include
mkdir %install_dir%\lib

call %msvc_env%
cd /D %src_dir%\src
cl /c /nologo /W3 /O2 /Ob1 /Oi /Gs /MD /D_CRT_SECURE_NO_DEPRECATE l*.c
del /Q lua.obj luac.obj
lib /OUT:liblua%suffix%.lib *.obj
copy *.lib %install_dir%\lib
del /Q *.obj

echo.
echo **** STATIC LIBRARY GENERATED ****
echo.

cl /c /nologo /W3 /O2 /Ob1 /Oi /Gs /MD /D_CRT_SECURE_NO_DEPRECATE /DLUA_BUILD_AS_DLL l*.c
rename lua.obj lua.o
rename luac.obj luac.o
link /DLL /IMPLIB:lua%suffix%.lib /OUT:lua%suffix%.dll *.obj
link /OUT:lua.exe lua.o lua%suffix%.lib
link /OUT:luac.exe luac.o *.obj
del /Q luac.exp luac.lib

echo.
echo **** EXE AND DYNAMIC LIBRARY GENERATED ****
echo.

copy lua.hpp %install_dir%\include
copy lua.h %install_dir%\include
copy luaconf.h %install_dir%\include
copy lualib.h %install_dir%\include
copy lauxlib.h %install_dir%\include

copy *.exe %install_dir%\bin
copy *.exp %install_dir%\bin
copy *.dll %install_dir%\bin
copy *.lib %install_dir%\lib

echo.
echo **** ALL DISTRIBUTION FINISHED ****
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