@echo off

setlocal

set work_dir=%~dp0
set work_dir=%work_dir:~0,-1%
set gb28181_pkg_name=happytime-gb28181-device-code
set gb28181_src_dir=%work_dir%\%gb28181_pkg_name%
set gb28181_build_dir=%gb28181_src_dir%\GB28181Device
set gb28181_install_dir=D:\Library\gb28181\device
set msvc_tool_ver=15.0
set msvc_toolset_ver=141
set win_target_ver=10.0.17763.0
set os_arch=x64
set msvc_env="C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\VC\Auxiliary\Build\vcvars64.bat"
@REM set os_arch=Win32
@REM set msvc_env="C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\VC\Auxiliary\Build\vcvars32.bat"

if not exist %gb28181_pkg_name%.zip (
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

if exist %gb28181_src_dir% (
    rmdir /S /Q %gb28181_src_dir%
)

if exist %gb28181_build_dir% (
    rmdir /S /Q %gb28181_build_dir%
)

if exist %gb28181_install_dir% (
    rmdir /S /Q %gb28181_install_dir%
)

7z x -aoa %gb28181_pkg_name%.zip

call %msvc_env%
cd /D %gb28181_build_dir%
powershell -Command "(gc GB28181Device.vcxproj) -replace '14.0', '%msvc_tool_ver%' | Out-File GB28181Device.vcxproj"
powershell -Command "(gc GB28181Device.vcxproj) -replace 'v140', 'v%msvc_toolset_ver%' | Out-File GB28181Device.vcxproj"
powershell -Command "(gc GB28181Device.vcxproj) -replace '</RootNamespace>', '</RootNamespace><WindowsTargetPlatformVersion>%win_target_ver%</WindowsTargetPlatformVersion>' | Out-File GB28181Device.vcxproj"

MSBuild GB28181Device.vcxproj /p:Configuration=Release
@REM MSBuild GB28181Device.vcxproj /p:Configuration=Debug

echo.
echo **** COMPILATION FINISHED ****
echo.

mkdir %gb28181_install_dir%
copy %gb28181_build_dir%\%os_arch%\Release\*.exe %gb28181_install_dir%
copy %gb28181_build_dir%\config.xml %gb28181_install_dir%
copy %gb28181_build_dir%\test.mp4 %gb28181_install_dir%

echo.
echo **** DISTRIBUTION FINISHED ****
echo.

cd /D %work_dir%
rmdir /S /Q %gb28181_src_dir%

echo.
echo **** SRC DIR DELETED ****
echo.

pause