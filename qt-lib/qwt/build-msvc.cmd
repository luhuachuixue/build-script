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

@REM set vs_version=2022
set vs_version=2017
set arch="x64"
@REM set arch="x86"

set qt_prefix=C:/Qt/Qt5.12.12/5.12.12
if %vs_version% == 2022 (
    set msvc_prefix="C:/Program Files/Microsoft Visual Studio/2022/Enterprise/VC/Auxiliary/Build"
    if %arch% == "x64" (
        set qt_toolset=msvc2022_64
    ) else (
        set qt_toolset=msvc2022
    )
) else (
    set msvc_prefix="C:/Program Files (x86)/Microsoft Visual Studio/2017/Enterprise/VC/Auxiliary/Build"
    if %arch% == "x64" (
        set qt_toolset=msvc2017_64
    ) else (
        set qt_toolset=msvc2017
    )
)

if %arch% == "x64" (
    set msvc_bat=vcvars64.bat
) else (
    set msvc_bat=vcvars32.bat
)

set msvc_env=%msvc_prefix%/%msvc_bat%
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

if not exist %qt_env% (
    echo **** UNSET CORRECT QT ENV ****
    pause
    exit
)

if not exist %msvc_env% (
    echo **** UNSET CORRECT MSVC ENV ****
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
%sed_tool% -i "s|win32 {|win32-msvc {\n  QMAKE_CXXFLAGS += /MP\n}\nwin32 {|" %project_name2%
%sed_tool% -i "s|QWT_CONFIG     += QwtExamples|#QWT_CONFIG     += QwtExamples|" %project_name2%
%sed_tool% -i "s|QWT_CONFIG     += QwtTests|#QWT_CONFIG     += QwtTests|" %project_name2%
@REM %sed_tool% -i "s|QWT_CONFIG           += QwtDll|#QWT_CONFIG           += QwtDll|" %project_name2%

mkdir %build_dir%

call %qt_env%
call %msvc_env%

cd /D %build_dir%
qmake %project%

echo.
echo **** QMAKE VS-PROJECT GENERATED ****
echo.

nmake

echo.
echo **** COMPILATION FINISHED ****
echo.

nmake install

echo.
echo **** DISTRIBUTION FINISHED ****
echo.

cd /D %work_dir%
rmdir /S /Q %src_dir% %build_dir%

echo.
echo **** SRC AND BUILD DIR DELETED ****
echo.

pause