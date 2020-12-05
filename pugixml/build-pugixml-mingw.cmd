@echo off

setlocal

set pugixml_version=1.11.1
set work_dir=%~dp0
set work_dir=%work_dir:~0,-1%
set pugixml_pkg_name=pugixml-%pugixml_version%
set pugixml_src_dir=%work_dir%\%pugixml_pkg_name%
set pugixml_build_dir=%work_dir%\build
set pugixml_install_dir=D:\Library\libpugixml

if not exist %pugixml_pkg_name%.zip (
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

if exist %pugixml_src_dir% (
    rmdir /S /Q %pugixml_src_dir%
)

if exist %pugixml_build_dir% (
    rmdir /S /Q %pugixml_build_dir%
)

if exist %pugixml_install_dir% (
    rmdir /S /Q %pugixml_install_dir%
)

7z x -aoa %pugixml_pkg_name%.zip

echo.
echo **** COMPILATION STARTED ****
echo.

mkdir %pugixml_build_dir%
cd /D %pugixml_src_dir%\src
g++ -O3 -DNDEBUG -Wall -std=c++11 -m64 -c pugixml.cpp -o %pugixml_build_dir%\pugixml.o

echo.
echo %pugixml_build_dir%\pugixml.o
echo **** COMPILATION FINISHED ****
echo.

ar -crs %pugixml_build_dir%\libpugixml.a %pugixml_build_dir%\pugixml.o

echo.
echo %pugixml_build_dir%\libpugixml.a
echo **** LIBRARY GENERATED ****
echo.

mkdir %pugixml_install_dir%
mkdir %pugixml_install_dir%\include
mkdir %pugixml_install_dir%\lib
copy %pugixml_src_dir%\src\*.hpp %pugixml_install_dir%\include
copy %pugixml_src_dir%\src\*.cpp %pugixml_install_dir%\include
copy %pugixml_build_dir%\*.a %pugixml_install_dir%\lib

echo.
echo **** BINARY DISTRIBUTION FINISHED ****
echo.

cd /D %work_dir%
rmdir /S /Q %pugixml_src_dir% %pugixml_build_dir%

echo.
echo **** SRC AND BUILD DIR DELETED ****
echo.

pause