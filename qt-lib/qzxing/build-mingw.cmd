@echo off

setlocal

set version=3.3.0
set work_dir=%~dp0
set work_dir=%work_dir:~0,-1%
set pkg_name=qzxing-%version%
set pkg_file=%pkg_name%.zip
set src_dir=%work_dir%\%pkg_name%
set project_name=QZXing.pro
set project=%src_dir%\src\%project_name%
set build_dir=%work_dir%\build
set install_dir=D:\Library\QZXing

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

mkdir %build_dir%

call %qt_env%

cd /D %src_dir%\src
%sed_tool% -i "s/enable_decoder_1d_barcodes/#enable_decoder_1d_barcodes/" %project_name%
%sed_tool% -i "s/enable_decoder_data_matrix/#enable_decoder_data_matrix/" %project_name%
%sed_tool% -i "s/enable_decoder_aztec/#enable_decoder_aztec/" %project_name%
%sed_tool% -i "s/enable_decoder_pdf17/#enable_decoder_pdf17/" %project_name%
%sed_tool% -i "s/enable_encoder_qr_code/#enable_encoder_qr_code/" %project_name%

cd /D %build_dir%
qmake %project%
@REM qmake %project% CONFIG+=staticlib

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

copy %src_dir%\src\QZXing.h %install_dir%\include
copy %src_dir%\src\QZXing_global.h %install_dir%\include
copy release\*.a %install_dir%\lib
copy release\*.dll %install_dir%\bin

echo.
echo **** DISTRIBUTION FINISHED ****
echo.

cd /D %work_dir%
rmdir /S /Q %src_dir% %build_dir%

echo.
echo **** SRC AND BUILD DIR DELETED ****
echo.

pause