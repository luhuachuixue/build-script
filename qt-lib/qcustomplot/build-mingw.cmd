@echo off

setlocal

set work_dir=%~dp0
set work_dir=%work_dir:~0,-1%
set pkg_file=QCustomPlot.tar.gz
set pkg_file2=QCustomPlot-sharedlib.tar.gz
set src_dir=%work_dir%\qcustomplot
set project=%src_dir%\qcustomplot-sharedlib\sharedlib-compilation\sharedlib-compilation.pro
set build_dir=%work_dir%\build
set install_dir=D:\Library\QCustomPlot

set compile_core=8
set arch="x64"
@REM set arch="x86"

set qt_prefix=C:/Qt/Qt5.12.12/5.12.12
if %arch% == "x64" (
    set qt_toolset=mingw73_64
) else (
    set qt_toolset=mingw73_32
)
set qt_env="%qt_prefix%/%qt_toolset%/bin/qtenv2.bat"

if not exist %pkg_file% (
    echo **** NOT FIND CODE PACKAGE ****
    pause
    exit
)

if not exist %pkg_file2% (
    echo **** NOT FIND CODE PACKAGE 2 ****
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

if not exist %qt_env% (
    echo **** UNSET CORRECT QT ENV ****
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

7z x %pkg_file% -so | 7z x -aoa -si -ttar
7z x %pkg_file2% -so | 7z x -aoa -si -ttar -o%src_dir%

mkdir %build_dir%

call %qt_env%

cd /D %build_dir%
qmake %project%
@REM qmake %project% CONFIG+=static

echo.
echo **** QMAKE MAKEFILE GENERATED ****
echo.

mingw32-make -j%compile_core%

echo.
echo **** COMPILATION FINISHED ****
echo.

mkdir %install_dir%
mkdir %install_dir%\include
mkdir %install_dir%\lib
mkdir %install_dir%\bin

copy %src_dir%\qcustomplot.h %install_dir%\include
copy release\*.a %install_dir%\lib
copy release\*.dll %install_dir%\bin
copy debug\*.a %install_dir%\lib
copy debug\*.dll %install_dir%\bin

echo.
echo **** DISTRIBUTION FINISHED ****
echo.

cd /D %work_dir%
rmdir /S /Q %src_dir% %build_dir%

echo.
echo **** SRC AND BUILD DIR DELETED ****
echo.

pause