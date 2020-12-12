@echo off

setlocal

set boost_version=1_75_0
set work_dir=%~dp0
set work_dir=%work_dir:~0,-1%
set boost_pkg_name=boost_%boost_version%
set boost_src_dir=%work_dir%\%boost_pkg_name%
set boost_build_dir=%work_dir%\build
set boost_install_dir=D:\Library\libboost
set tool_set=gcc

if not exist %boost_pkg_name%.7z (
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

if exist %boost_src_dir% (
    rmdir /S /Q %boost_src_dir%
)

if exist %boost_build_dir% (
    rmdir /S /Q %boost_build_dir%
)

if exist %boost_install_dir% (
    rmdir /S /Q %boost_install_dir%
)

7z x -aoa %boost_pkg_name%.7z

cd /D %boost_src_dir%
call bootstrap.bat %tool_set%

echo.
echo **** B2 PROJECT GENERATED ****
echo.

b2 -j8 --build-dir=%boost_build_dir% --prefix=%boost_install_dir% --layout=tagged --build-type=complete threading=multi link=static runtime-link=shared address-model=64 install

@REM mkdir %boost_install_dir%\bin
@REM move %boost_install_dir%\lib\*.dll %boost_install_dir%\bin

echo.
echo **** COMPILATION AND DISTRIBUTION FINISHED ****
echo.


@REM setlocal EnableDelayedExpansion

@REM cd /D %boost_install_dir%\lib

@REM set "str1=-mt"
@REM for /f "delims=" %%i in ('dir /b *.a') do (
@REM set "var=%%i"
@REM rename "%%i" "!var:%str1%=!"
@REM )

@REM set "str2=-x64"
@REM for /f "delims=" %%i in ('dir /b *.a') do (
@REM set "var=%%i"
@REM rename "%%i" "!var:%str2%=!"
@REM )

@REM echo.
@REM echo **** LIBRARY RENAME FINISHED ****
@REM echo.

cd /D %work_dir%
rmdir /S /Q %boost_src_dir% %boost_build_dir%

echo.
echo **** SRC AND BUILD DIR DELETED ****
echo.

pause