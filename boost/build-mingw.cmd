@echo off

setlocal

set version=1_80_0
set work_dir=%~dp0
set work_dir=%work_dir:~0,-1%
set pkg_name=boost_%version%
set pkg_file=%pkg_name%.7z
set src_dir=%work_dir%\%pkg_name%
set build_dir=%work_dir%\build
set install_dir=D:\Library\libboost

set compile_core=8
set arch="x64"
@REM set arch="x86"
set tool_set=gcc

if %arch% == "x64" (
    set addr_model=64
) else (
    set addr_model=32
)

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
    echo **** CANNOT FIND MINGW ****
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

cd /D %src_dir%
call bootstrap.bat %tool_set%

echo.
echo **** B2 PROJECT GENERATED ****
echo.

b2 -j%compile_core% --build-dir=%build_dir% --prefix=%install_dir% --layout=tagged --build-type=complete threading=multi link=static runtime-link=shared address-model=%addr_model% install

mkdir %install_dir%\bin
move %install_dir%\lib\*.dll %install_dir%\bin

echo.
echo **** COMPILATION AND DISTRIBUTION FINISHED ****
echo.

cd /D %work_dir%
rmdir /S /Q %src_dir% %build_dir%

echo.
echo **** SRC AND BUILD DIR DELETED ****
echo.

pause