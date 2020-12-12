@echo off

setlocal

set boost_version=1_75_0
set work_dir=%~dp0
set work_dir=%work_dir:~0,-1%
set boost_pkg_name=boost_%boost_version%
set boost_src_dir=%work_dir%\%boost_pkg_name%
set boost_build_dir=%work_dir%\build
set boost_install_dir=D:\Library\libboost
set tool_set=vc141
set msvc_env="C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\VC\Auxiliary\Build\vcvars64.bat"

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

if not exist %msvc_env% (
    echo **** UNSET CORRECT MSVC ENV ****
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

call %msvc_env%
cd /D %boost_src_dir%
call bootstrap.bat %tool_set%

echo.
echo **** B2 PROJECT GENERATED ****
echo.

b2 -j8 --build-dir=%boost_build_dir% --prefix=%boost_install_dir% --build-type=complete threading=multi link=shared runtime-link=shared address-model=64 install

mkdir %boost_install_dir%\bin
move %boost_install_dir%\lib\*.dll %boost_install_dir%\bin

echo.
echo **** COMPILATION AND DISTRIBUTION FINISHED ****
echo.

cd /D %work_dir%
rmdir /S /Q %boost_src_dir% %boost_build_dir%

echo.
echo **** SRC AND BUILD DIR DELETED ****
echo.

pause