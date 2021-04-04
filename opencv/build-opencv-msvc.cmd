@echo off

setlocal

set opencv_version=4.5.2
set work_dir=D:\tmp
set opencv_pkg_name=opencv-%opencv_version%
set opencv_extra_pkg_name=opencv_contrib-%opencv_version%
set opencv_src_dir=%work_dir%\%opencv_pkg_name%
set opencv_extra_mod_dir=%opencv_src_dir%\%opencv_extra_pkg_name%\modules
set opencv_build_dir=%work_dir%\build
set opencv_install_dir=D:\Library\OpenCV\OpenCV-MSVC
set cmake_eigen_dir=D:\Library\libeigen\share\eigen3\cmake
set cmake_tbb_dir=D:\Library\tbb\tbb\cmake
set opencv_dir_toolset=vc15
set sed_tool="C:\Program Files\Git\usr\bin\sed.exe"
@REM set http_proxy=http://127.0.0.1:7890
@REM set https_proxy=http://127.0.0.1:7890
set opencv_dir_platform=x64
set cmake_qt_prefix=C:/Qt/Qt5.12.10/5.12.10/msvc2017_64
set cmake_gen_type="Visual Studio 15 2017 Win64"
set msvc_env="C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\VC\Auxiliary\Build\vcvars64.bat"
@REM set opencv_dir_platform=x86
@REM set cmake_qt_prefix=C:/Qt/Qt5.12.10/5.12.10/msvc2017
@REM set cmake_gen_type="Visual Studio 15 2017"
@REM set msvc_env="C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\VC\Auxiliary\Build\vcvars32.bat"

if not exist %opencv_pkg_name%.zip (
    echo **** NOT FIND CODE PACKAGE ****
    pause
    exit
)

if not exist %opencv_extra_pkg_name%.zip (
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

if exist %opencv_src_dir% (
    rmdir /S /Q %opencv_src_dir%
)

if exist %opencv_build_dir% (
    rmdir /S /Q %opencv_build_dir%
)

if exist %opencv_install_dir% (
    rmdir /S /Q %opencv_install_dir%
)

7z x -aoa %opencv_pkg_name%.zip -o%work_dir%
7z x -aoa %opencv_extra_pkg_name%.zip -o%opencv_src_dir%
if not defined http_proxy (
    7z x -aoa .cache.zip -o%opencv_src_dir%
)

cd /D %opencv_extra_mod_dir%\cvv\src\stfl
%sed_tool% -i "1s/^/\xef\xbb\xbf/" stringutils.cpp
cd /D %opencv_src_dir%\modules\java\generator
%sed_tool% -i "s/open(path, \"rt\")/open(path, \"rt\", -1, \"utf-8\")/g" gen_java.py

cd /D %opencv_src_dir%
cmake -G%cmake_gen_type% -S. -B%opencv_build_dir% -DCMAKE_INSTALL_PREFIX=%opencv_install_dir% ^
    -DOPENCV_EXTRA_MODULES_PATH=%opencv_extra_mod_dir% -DBUILD_SHARED_LIBS=ON ^
    -DBUILD_JAVA=ON -DBUILD_opencv_java=ON -DBUILD_opencv_java_bindings_generator=ON ^
    -DOPENCV_ENABLE_NONFREE=ON -DWITH_OPENMP=ON -DWITH_OPENCL=ON -DWITH_OPENCL_SVM=ON ^
    -DBUILD_PROTOBUF=ON -DWITH_PROTOBUF=ON -DBUILD_JASPER=ON -DWITH_JASPER=ON ^
    -DWITH_IPP=ON -DBUILD_IPP_IW=ON -DOPENCV_IPP_GAUSSIAN_BLUR=ON -DWITH_TBB=ON -DTBB_DIR=%cmake_tbb_dir% ^
    -DWITH_EIGEN=ON -DEigen3_DIR=%cmake_eigen_dir% -DWITH_WIN32UI=OFF -DWITH_OPENGL=ON -DWITH_QT=ON ^
    -DQT_MAKE_EXECUTABLE=%cmake_qt_prefix%/bin/qmake.exe -DQt5_DIR=%cmake_qt_prefix%/lib/cmake/Qt5 ^
    -DQt5Concurrent_DIR=%cmake_qt_prefix%/lib/cmake/Qt5Concurrent -DQt5Core_DIR=%cmake_qt_prefix%/lib/cmake/Qt5Core ^
    -DQt5Gui_DIR=%cmake_qt_prefix%/lib/cmake/Qt5Gui -DQt5OpenGL_DIR=%cmake_qt_prefix%/lib/cmake/Qt5OpenGL ^
    -DQt5Test_DIR=%cmake_qt_prefix%/lib/cmake/Qt5Test -DQt5Widgets_DIR=%cmake_qt_prefix%/lib/cmake/Qt5Widgets ^
    -DWITH_FREETYPE=OFF -DBUILD_opencv_freetype=OFF ^
    -DBUILD_opencv_world=OFF -DBUILD_opencv_cvv=ON -DWITH_VTK=OFF -DBUILD_opencv_viz=OFF ^
    -DWITH_OPENJPEG=OFF -DWITH_OPENVX=OFF -DWITH_OPENCLAMDBLAS=OFF -DBUILD_opencv_js=OFF ^
    -DOPENCV_ALLOCATOR_STATS_COUNTER_TYPE=int64_t -DOPENCV_GENERATE_SETUPVARS=OFF -DWITH_TESSERACT=OFF -DWITH_CUDA=OFF ^
    -DBUILD_PACKAGE=OFF -DBUILD_PERF_TESTS=OFF -DBUILD_TESTS=OFF -DBUILD_opencv_ts=OFF -DBUILD_opencv_rgbd=OFF ^
    -DBUILD_opencv_python3=OFF -DBUILD_opencv_python_bindings_generator=OFF -DBUILD_opencv_python_tests=OFF

echo.
echo **** CMAKE VS-PROJECT GENERATED ****
echo.

call %msvc_env%
cd /D %opencv_build_dir%
MSBuild INSTALL.vcxproj /p:Configuration=Release
MSBuild ALL_BUILD.vcxproj /t:clean
MSBuild ALL_BUILD.vcxproj /p:Configuration=Debug

@REM copy %opencv_build_dir%\bin\Debug\*.pdb %opencv_install_dir%\%opencv_dir_platform%\%opencv_dir_toolset%\bin
copy %opencv_build_dir%\bin\Debug\*.dll %opencv_install_dir%\%opencv_dir_platform%\%opencv_dir_toolset%\bin
copy %opencv_build_dir%\lib\Debug\*.lib %opencv_install_dir%\%opencv_dir_platform%\%opencv_dir_toolset%\lib
cd /D %opencv_install_dir%\%opencv_dir_platform%\%opencv_dir_toolset%\lib
del /Q ade.lib opencv_java*.lib

echo.
echo **** COMPILATION AND DISTRIBUTION FINISHED ****
echo.

cd /D %work_dir%
rmdir /S /Q %opencv_src_dir% %opencv_build_dir%

echo.
echo **** SRC AND BUILD DIR DELETED ****
echo.

pause