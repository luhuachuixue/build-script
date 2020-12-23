@echo off

setlocal

set opencv_version=4.5.1
set work_dir=D:\tmp
set opencv_pkg_name=opencv-%opencv_version%
set opencv_extra_pkg_name=opencv_contrib-%opencv_version%
set opencv_src_dir=%work_dir%\%opencv_pkg_name%
set opencv_extra_mod_dir=%opencv_src_dir%\%opencv_extra_pkg_name%\modules
set opencv_build_dir=%work_dir%\build
set opencv_install_dir=D:\Library\OpenCV\OpenCV-MinGW
set cmake_eigen_dir=D:\Library\libeigen\share\eigen3\cmake
set cmake_qt_prefix=C:/Qt/Qt5.12.10/5.12.10/mingw73_64
set http_proxy=http://127.0.0.1:7890
set https_proxy=http://127.0.0.1:7890

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

where /Q mingw32-make
if errorlevel 1 (
    echo **** CANNOT FIND MINGW32-MAKE ****
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

cd /D %opencv_src_dir%
cmake -G"MinGW Makefiles" -S. -B%opencv_build_dir% -DCMAKE_INSTALL_PREFIX=%opencv_install_dir% ^
    -DOPENCV_EXTRA_MODULES_PATH=%opencv_extra_mod_dir% -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON ^
    -DOPENCV_ENABLE_NONFREE=ON -DWITH_OPENMP=ON -DWITH_OPENCL=ON -DWITH_OPENCL_SVM=ON ^
    -DBUILD_PROTOBUF=ON -DWITH_PROTOBUF=ON -DBUILD_JASPER=ON -DWITH_JASPER=ON ^
    -DWITH_EIGEN=ON -DEigen3_DIR=%cmake_eigen_dir% -DWITH_OPENGL=ON -DWITH_QT=ON ^
    -DQT_MAKE_EXECUTABLE=%cmake_qt_prefix%/bin/qmake.exe -DQt5_DIR=%cmake_qt_prefix%/lib/cmake/Qt5 ^
    -DQt5Concurrent_DIR=%cmake_qt_prefix%/lib/cmake/Qt5Concurrent -DQt5Core_DIR=%cmake_qt_prefix%/lib/cmake/Qt5Core ^
    -DQt5Gui_DIR=%cmake_qt_prefix%/lib/cmake/Qt5Gui -DQt5OpenGL_DIR=%cmake_qt_prefix%/lib/cmake/Qt5OpenGL ^
    -DQt5Test_DIR=%cmake_qt_prefix%/lib/cmake/Qt5Test -DQt5Widgets_DIR=%cmake_qt_prefix%/lib/cmake/Qt5Widgets ^
    -DBUILD_opencv_world=OFF -DBUILD_opencv_cvv=ON -DWITH_VTK=OFF -DBUILD_opencv_viz=OFF ^
    -DWITH_OPENJPEG=OFF -DWITH_OPENVX=OFF -DWITH_IPP=OFF -DWITH_TBB=OFF -DWITH_OPENCLAMDBLAS=OFF ^
    -DOPENCV_ALLOCATOR_STATS_COUNTER_TYPE=int64_t -DOPENCV_GENERATE_SETUPVARS=OFF -DWITH_TESSERACT=OFF -DWITH_CUDA=OFF ^
    -DBUILD_PACKAGE=OFF -DBUILD_PERF_TESTS=OFF -DBUILD_TESTS=OFF -DBUILD_opencv_ts=OFF -DBUILD_opencv_rgbd=OFF ^
    -DBUILD_opencv_js=OFF -DBUILD_JAVA=OFF -DBUILD_opencv_java=OFF -DBUILD_opencv_java_bindings_generator=OFF ^
    -DBUILD_opencv_python3=OFF -DBUILD_opencv_python_bindings_generator=OFF -DBUILD_opencv_python_tests=OFF

echo.
echo **** CMAKE MAKEFILE GENERATED ****
echo.

cd /D %opencv_build_dir%
mingw32-make -j8

echo.
echo **** COMPILATION FINISHED ****
echo.

mingw32-make install

echo.
echo **** BINARY DISTRIBUTION FINISHED ****
echo.

cd /D %work_dir%
rmdir /S /Q %opencv_src_dir% %opencv_build_dir%

echo.
echo **** SRC AND BUILD DIR DELETED ****
echo.

pause