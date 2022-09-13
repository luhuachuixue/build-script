@echo off

setlocal

set work_dir=%~dp0
set work_dir=%work_dir:~0,-1%
set build_dir=%work_dir%\build

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
    set mysql_prefix=D:/Library/mysql-5.7.38-winx64
) else (
    set msvc_bat=vcvars32.bat
    set mysql_prefix=D:/Library/mysql-5.7.38-win32
)

set src_dir=%qt_prefix%/Src/qtbase/src/plugins/sqldrivers
set project="%src_dir%/sqldrivers.pro"

set msvc_env=%msvc_prefix%/%msvc_bat%
set qt_env="%qt_prefix%/%qt_toolset%/bin/qtenv2.bat"
set mysql_inc_path="%mysql_prefix%/include"
set mysql_lib_path="%mysql_prefix%/lib"

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

if exist %build_dir% (
    rmdir /S /Q %build_dir%
)

mkdir %build_dir%

call %qt_env%
call %msvc_env%

cd /D %build_dir%
qmake %project% -- MYSQL_INCDIR=%mysql_inc_path% MYSQL_LIBDIR=%mysql_lib_path%

echo.
echo **** QMAKE VS-PROJECT GENERATED ****
echo.

nmake sub-mysql
copy /Y %build_dir%\plugins\sqldrivers\*.dll "%qt_prefix%"\%qt_toolset%\plugins\sqldrivers
copy /Y %build_dir%\lib\cmake\Qt5Sql\*.cmake "%qt_prefix%"\%qt_toolset%\lib\cmake\Qt5Sql

echo.
echo **** COMPILATION AND DISTRIBUTION FINISHED ****
echo.

cd /D %src_dir%
rmdir /S /Q %build_dir%

echo.
echo **** BUILD DIR DELETED ****
echo.

pause