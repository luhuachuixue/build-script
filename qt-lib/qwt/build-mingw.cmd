@echo off

setlocal

set version=6.2.0
set work_dir=%~dp0
set work_dir=%work_dir:~0,-1%
set pkg_name=qwt-%version%
set pkg_file=%pkg_name%.zip
set src_dir=%work_dir%\%pkg_name%
set project_name=qwt.pro
set project_name2=qwtconfig.pri
set project=%src_dir%\%project_name%
set build_dir=%work_dir%\build
set install_dir=D:/Library/Qwt

set sed_tool="C:\Program Files\Git\usr\bin\sed.exe"

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

if not exist %sed_tool% (
    echo **** UNSET CORRECT SED TOOL ****
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
%sed_tool% -i "/classincludes/c classincludes" %project_name%
%sed_tool% -i "/doc/d" %project_name%
%sed_tool% -i "s|QWT_INSTALL_PREFIX    = C:/Qwt-$$QWT_VERSION|QWT_INSTALL_PREFIX = %install_dir%|" %project_name2%
%sed_tool% -i "s|QWT_CONFIG     += QwtExamples|#QWT_CONFIG     += QwtExamples|" %project_name2%
%sed_tool% -i "s|QWT_CONFIG     += QwtTests|#QWT_CONFIG     += QwtTests|" %project_name2%
@REM %sed_tool% -i "s|QWT_CONFIG           += QwtDll|#QWT_CONFIG           += QwtDll|" %project_name2%

mkdir %build_dir%

call %qt_env%

cd /D %build_dir%
qmake %project%

echo.
echo **** QMAKE MAKEFILE GENERATED ****
echo.

mingw32-make -j%compile_core%

echo.
echo **** COMPILATION FINISHED ****
echo.

mingw32-make -j%compile_core% install

echo.
echo **** DISTRIBUTION FINISHED ****
echo.

cd /D %work_dir%
rmdir /S /Q %src_dir% %build_dir%

echo.
echo **** SRC AND BUILD DIR DELETED ****
echo.

pause