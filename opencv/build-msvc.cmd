@echo off

setlocal

set version=4.6.0
set work_dir=D:\tmp
set pkg_name=opencv-%version%
set pkg_file=%pkg_name%.zip
set extra_pkg_name=opencv_contrib-%version%
set extra_pkg_file=%extra_pkg_name%.zip
set src_dir=%work_dir%\%pkg_name%
set extra_mod_dir=%src_dir%\%extra_pkg_name%\modules
set build_dir=%work_dir%\build
set install_dir=D:\Library\OpenCV\OpenCV-MSVC

set eigen_cmake_dir=D:\Library\libeigen\share\eigen3\cmake
set tbb_cmake_dir=D:\Library\tbb\lib\cmake\tbb
set sed_tool="C:\Program Files\Git\usr\bin\sed.exe"
@REM set http_proxy=http://127.0.0.1:7890
@REM set https_proxy=http://127.0.0.1:7890

set opencv_with_qt=0
@REM set vs_version=2022
set vs_version=2017
set arch="x64"
@REM set arch="x86"

set qt_prefix=C:/Qt/Qt5.12.12/5.12.12
if %vs_version% == 2022 (
    set msvc_prefix="C:/Program Files/Microsoft Visual Studio/2022/Enterprise/VC/Auxiliary/Build"
    set cmake_gen_type="Visual Studio 17 2022"
    set dir_toolset=vc17
    if %arch% == "x64" (
        set qt_toolset=msvc2022_64
    ) else (
        set qt_toolset=msvc2022
    )
) else (
    set msvc_prefix="C:/Program Files (x86)/Microsoft Visual Studio/2017/Enterprise/VC/Auxiliary/Build"
    set cmake_gen_type="Visual Studio 15 2017"
    set dir_toolset=vc15
    if %arch% == "x64" (
        set qt_toolset=msvc2017_64
    ) else (
        set qt_toolset=msvc2017
    )
)

if %arch% == "x64" (
    set msvc_bat=vcvars64.bat
    set cmake_gen_arch=x64
    set dir_platform=x64
) else (
    set msvc_bat=vcvars32.bat
    set cmake_gen_arch=Win32
    set dir_platform=x86
)

set msvc_env=%msvc_prefix%/%msvc_bat%
set qt_cmake_prefix=%qt_prefix%/%qt_toolset%

if not exist %pkg_file% (
    echo **** NOT FIND CODE PACKAGE ****
    pause
    exit
)

if not exist %extra_pkg_file% (
    echo **** NOT FIND EXTRA CODE PACKAGE ****
    pause
    exit
)

where /Q curl
if errorlevel 1 (
    echo **** CANNOT FIND CURL ****
    pause
    exit
)

if defined http_proxy (
    curl raw.githubusercontent.com
    if errorlevel 1 (
        echo **** INVALID PROXY ****
        pause
        exit
    )
) else (
    if not exist .cache.zip (
        echo **** NOT FIND DOWNLOAD PACKAGE ****
        pause
        exit
    )
)

where /Q 7z
if errorlevel 1 (
    echo **** CANNOT FIND 7-Zip ****
    pause
    exit
)

where /Q cmake
if errorlevel 1 (
    echo **** CANNOT FIND CMAKE ****
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

if not exist %work_dir% (
    mkdir %work_dir%
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

7z x -aoa %pkg_file% -o%work_dir%
7z x -aoa %extra_pkg_file% -o%src_dir%
if not defined http_proxy (
    7z x -aoa .cache.zip -o%src_dir%
)

cd /D %extra_mod_dir%\cvv\src\stfl
%sed_tool% -i "1s/^/\xef\xbb\xbf/" stringutils.cpp
cd /D %src_dir%\modules\java\generator
%sed_tool% -i "s/open(path, \"rt\")/open(path, \"rt\", -1, \"utf-8\")/g" gen_java.py
cd /D %src_dir%\modules\core\src
%sed_tool% -i "/tbb_stddef.h/d" parallel.cpp

cd /D %src_dir%
if %opencv_with_qt% == 0 (
    cmake -G%cmake_gen_type% -A%cmake_gen_arch% -S. -B%build_dir% -DCMAKE_INSTALL_PREFIX=%install_dir% ^
        -DOPENCV_EXTRA_MODULES_PATH=%extra_mod_dir% -DBUILD_SHARED_LIBS=ON ^
        -DOPENCV_ENABLE_NONFREE=ON -DWITH_OPENMP=ON -DWITH_OPENCL=ON -DWITH_OPENCL_SVM=ON ^
        -DWITH_PROTOBUF=ON -DBUILD_PROTOBUF=ON -DWITH_OPENEXR=ON -DBUILD_OPENEXR=ON ^
        -DWITH_OPENJPEG=ON -DBUILD_OPENJPEG=ON -DWITH_JASPER=OFF -DBUILD_JASPER=OFF ^
        -DWITH_IPP=ON -DBUILD_IPP_IW=ON -DOPENCV_IPP_GAUSSIAN_BLUR=ON -DWITH_TBB=ON -DTBB_DIR=%tbb_cmake_dir% ^
        -DWITH_EIGEN=ON -DEigen3_DIR=%eigen_cmake_dir% -DWITH_OPENGL=ON -DWITH_QT=OFF -DBUILD_opencv_cvv=OFF ^
        -DWITH_FREETYPE=OFF -DBUILD_opencv_freetype=OFF -DWITH_OPENVX=OFF -DWITH_OPENCLAMDBLAS=OFF ^
        -DOPENCV_GENERATE_SETUPVARS=OFF -DWITH_TESSERACT=OFF -DWITH_CUDA=OFF ^
        -DBUILD_opencv_world=OFF -DBUILD_opencv_rgbd=ON -DWITH_VTK=OFF -DBUILD_opencv_viz=OFF ^
        -DBUILD_PACKAGE=OFF -DBUILD_PERF_TESTS=OFF -DBUILD_TESTS=OFF -DBUILD_opencv_ts=OFF ^
        -DBUILD_JAVA=ON -DBUILD_opencv_java=ON -DBUILD_opencv_java_bindings_generator=ON ^
        -DBUILD_opencv_python3=OFF -DBUILD_opencv_python_bindings_generator=OFF -DBUILD_opencv_python_tests=OFF ^
        -DBUILD_opencv_js=OFF -DBUILD_opencv_js_bindings_generator=OFF
) else (
    cmake -G%cmake_gen_type% -A%cmake_gen_arch% -S. -B%build_dir% -DCMAKE_INSTALL_PREFIX=%install_dir% ^
        -DOPENCV_EXTRA_MODULES_PATH=%extra_mod_dir% -DBUILD_SHARED_LIBS=ON ^
        -DOPENCV_ENABLE_NONFREE=ON -DWITH_OPENMP=ON -DWITH_OPENCL=ON -DWITH_OPENCL_SVM=ON ^
        -DWITH_PROTOBUF=ON -DBUILD_PROTOBUF=ON -DWITH_OPENEXR=ON -DBUILD_OPENEXR=ON ^
        -DWITH_OPENJPEG=ON -DBUILD_OPENJPEG=ON -DWITH_JASPER=OFF -DBUILD_JASPER=OFF ^
        -DWITH_IPP=ON -DBUILD_IPP_IW=ON -DOPENCV_IPP_GAUSSIAN_BLUR=ON -DWITH_TBB=ON -DTBB_DIR=%tbb_cmake_dir% ^
        -DWITH_EIGEN=ON -DEigen3_DIR=%eigen_cmake_dir% -DWITH_OPENGL=ON -DWITH_QT=ON -DBUILD_opencv_cvv=ON ^
        -DQT_MAKE_EXECUTABLE=%qt_cmake_prefix%/bin/qmake.exe -DQt5_DIR=%qt_cmake_prefix%/lib/cmake/Qt5 ^
        -DQt5Concurrent_DIR=%qt_cmake_prefix%/lib/cmake/Qt5Concurrent -DQt5Core_DIR=%qt_cmake_prefix%/lib/cmake/Qt5Core ^
        -DQt5Gui_DIR=%qt_cmake_prefix%/lib/cmake/Qt5Gui -DQt5OpenGL_DIR=%qt_cmake_prefix%/lib/cmake/Qt5OpenGL ^
        -DQt5Test_DIR=%qt_cmake_prefix%/lib/cmake/Qt5Test -DQt5Widgets_DIR=%qt_cmake_prefix%/lib/cmake/Qt5Widgets ^
        -DWITH_FREETYPE=OFF -DBUILD_opencv_freetype=OFF -DWITH_OPENVX=OFF -DWITH_OPENCLAMDBLAS=OFF ^
        -DOPENCV_GENERATE_SETUPVARS=OFF -DWITH_TESSERACT=OFF -DWITH_CUDA=OFF ^
        -DBUILD_opencv_world=OFF -DBUILD_opencv_rgbd=ON -DWITH_VTK=OFF -DBUILD_opencv_viz=OFF ^
        -DBUILD_PACKAGE=OFF -DBUILD_PERF_TESTS=OFF -DBUILD_TESTS=OFF -DBUILD_opencv_ts=OFF ^
        -DBUILD_JAVA=ON -DBUILD_opencv_java=ON -DBUILD_opencv_java_bindings_generator=ON ^
        -DBUILD_opencv_python3=OFF -DBUILD_opencv_python_bindings_generator=OFF -DBUILD_opencv_python_tests=OFF ^
        -DBUILD_opencv_js=OFF -DBUILD_opencv_js_bindings_generator=OFF
)

echo.
echo **** CMAKE VS-PROJECT GENERATED ****
echo.

call %msvc_env%
cd /D %build_dir%
MSBuild INSTALL.vcxproj /p:Configuration=Debug
@REM MSBuild ALL_BUILD.vcxproj /t:clean
MSBuild INSTALL.vcxproj /p:Configuration=Release

copy %build_dir%\bin\Debug\*.pdb %install_dir%\%dir_platform%\%dir_toolset%\bin
copy %build_dir%\bin\Release\*.pdb %install_dir%\%dir_platform%\%dir_toolset%\bin
move %install_dir%\bin\*.exe %install_dir%\%dir_platform%\%dir_toolset%\bin

cd /D %install_dir%\%dir_platform%\%dir_toolset%\bin
if exist opencv_annotationd.exe (
    del /Q opencv_annotationd.exe
)
if exist opencv_interactive-calibrationd.exe (
    del /Q opencv_interactive-calibrationd.exe
)
if exist opencv_model_diagnosticsd.exe (
    del /Q opencv_model_diagnosticsd.exe
)
if exist opencv_versiond.exe (
    del /Q opencv_versiond.exe
)
if exist opencv_version_win32d.exe (
    del /Q opencv_version_win32d.exe
)
if exist opencv_visualisationd.exe (
    del /Q opencv_visualisationd.exe
)
if exist opencv_waldboost_detectord.exe (
    del /Q opencv_waldboost_detectord.exe
)
if exist opencv_createsamplesd.exe (
    del /Q opencv_createsamplesd.exe
)
if exist opencv_traincascaded.exe (
    del /Q opencv_traincascaded.exe
)
if exist opencv_annotationd.pdb (
    del /Q opencv_annotationd.pdb
)
if exist opencv_interactive-calibrationd.pdb (
    del /Q opencv_interactive-calibrationd.pdb
)
if exist opencv_model_diagnosticsd.pdb (
    del /Q opencv_model_diagnosticsd.pdb
)
if exist opencv_versiond.pdb (
    del /Q opencv_versiond.pdb
)
if exist opencv_version_win32d.pdb (
    del /Q opencv_version_win32d.pdb
)
if exist opencv_visualisationd.pdb (
    del /Q opencv_visualisationd.pdb
)
if exist opencv_waldboost_detectord.pdb (
    del /Q opencv_waldboost_detectord.pdb
)
if exist opencv_createsamplesd.pdb (
    del /Q opencv_createsamplesd.pdb
)
if exist opencv_traincascaded.pdb (
    del /Q opencv_traincascaded.pdb
)

echo.
echo **** COMPILATION AND DISTRIBUTION FINISHED ****
echo.

cd /D %work_dir%
rmdir /S /Q %src_dir% %build_dir%

echo.
echo **** SRC AND BUILD DIR DELETED ****
echo.

pause