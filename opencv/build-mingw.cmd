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
set install_dir=D:\Library\OpenCV\OpenCV-MinGW

set eigen_cmake_dir=D:\Library\libeigen\share\eigen3\cmake
@REM set http_proxy=http://127.0.0.1:7890
@REM set https_proxy=http://127.0.0.1:7890

set opencv_with_qt=0
set compile_core=8
set arch="x64"
@REM set arch="x86"

set dir_toolset=mingw
set qt_prefix=C:/Qt/Qt5.12.12/5.12.12
if %arch% == "x64" (
    set qt_toolset=mingw73_64
) else (
    set qt_toolset=mingw73_32
)
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

where /Q mingw32-make
if errorlevel 1 (
    echo **** CANNOT FIND MINGW32-MAKE ****
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

cd /D %src_dir%
if %opencv_with_qt% == 0 (
    cmake -G"MinGW Makefiles" -S. -B%build_dir% -DCMAKE_INSTALL_PREFIX=%install_dir% -DCMAKE_BUILD_TYPE=Release ^
        -DOPENCV_EXTRA_MODULES_PATH=%extra_mod_dir% -DBUILD_SHARED_LIBS=ON ^
        -DOPENCV_ENABLE_NONFREE=ON -DWITH_OPENMP=ON -DWITH_OPENCL=ON -DWITH_OPENCL_SVM=ON ^
        -DWITH_PROTOBUF=ON -DBUILD_PROTOBUF=ON -DWITH_OPENEXR=ON -DBUILD_OPENEXR=ON ^
        -DWITH_OPENJPEG=ON -DBUILD_OPENJPEG=ON -DWITH_JASPER=OFF -DBUILD_JASPER=OFF ^
        -DWITH_EIGEN=ON -DEigen3_DIR=%eigen_cmake_dir% -DWITH_OPENGL=ON -DWITH_QT=OFF -DBUILD_opencv_cvv=OFF ^
        -DWITH_FREETYPE=OFF -DBUILD_opencv_freetype=OFF -DWITH_OPENVX=OFF -DWITH_OPENCLAMDBLAS=OFF -DWITH_IPP=OFF -DWITH_TBB=OFF ^
        -DOPENCV_GENERATE_SETUPVARS=OFF -DWITH_TESSERACT=OFF -DWITH_CUDA=OFF ^
        -DBUILD_opencv_world=OFF -DBUILD_opencv_rgbd=ON -DWITH_VTK=OFF -DBUILD_opencv_viz=OFF ^
        -DBUILD_PACKAGE=OFF -DBUILD_PERF_TESTS=OFF -DBUILD_TESTS=OFF -DBUILD_opencv_ts=OFF ^
        -DBUILD_JAVA=ON -DBUILD_opencv_java=ON -DBUILD_opencv_java_bindings_generator=ON ^
        -DBUILD_opencv_python3=OFF -DBUILD_opencv_python_bindings_generator=OFF -DBUILD_opencv_python_tests=OFF ^
        -DBUILD_opencv_js=OFF -DBUILD_opencv_js_bindings_generator=OFF
) else (
    cmake -G"MinGW Makefiles" -S. -B%build_dir% -DCMAKE_INSTALL_PREFIX=%install_dir% -DCMAKE_BUILD_TYPE=Release ^
        -DOPENCV_EXTRA_MODULES_PATH=%extra_mod_dir% -DBUILD_SHARED_LIBS=ON ^
        -DOPENCV_ENABLE_NONFREE=ON -DWITH_OPENMP=ON -DWITH_OPENCL=ON -DWITH_OPENCL_SVM=ON ^
        -DWITH_PROTOBUF=ON -DBUILD_PROTOBUF=ON -DWITH_OPENEXR=ON -DBUILD_OPENEXR=ON ^
        -DWITH_OPENJPEG=ON -DBUILD_OPENJPEG=ON -DWITH_JASPER=OFF -DBUILD_JASPER=OFF ^
        -DWITH_EIGEN=ON -DEigen3_DIR=%eigen_cmake_dir% -DWITH_OPENGL=ON -DWITH_QT=ON -DBUILD_opencv_cvv=ON ^
        -DQT_MAKE_EXECUTABLE=%qt_cmake_prefix%/bin/qmake.exe -DQt5_DIR=%qt_cmake_prefix%/lib/cmake/Qt5 ^
        -DQt5Concurrent_DIR=%qt_cmake_prefix%/lib/cmake/Qt5Concurrent -DQt5Core_DIR=%qt_cmake_prefix%/lib/cmake/Qt5Core ^
        -DQt5Gui_DIR=%qt_cmake_prefix%/lib/cmake/Qt5Gui -DQt5OpenGL_DIR=%qt_cmake_prefix%/lib/cmake/Qt5OpenGL ^
        -DQt5Test_DIR=%qt_cmake_prefix%/lib/cmake/Qt5Test -DQt5Widgets_DIR=%qt_cmake_prefix%/lib/cmake/Qt5Widgets ^
        -DWITH_FREETYPE=OFF -DBUILD_opencv_freetype=OFF -DWITH_OPENVX=OFF -DWITH_OPENCLAMDBLAS=OFF -DWITH_IPP=OFF -DWITH_TBB=OFF ^
        -DOPENCV_GENERATE_SETUPVARS=OFF -DWITH_TESSERACT=OFF -DWITH_CUDA=OFF ^
        -DBUILD_opencv_world=OFF -DBUILD_opencv_rgbd=ON -DWITH_VTK=OFF -DBUILD_opencv_viz=OFF ^
        -DBUILD_PACKAGE=OFF -DBUILD_PERF_TESTS=OFF -DBUILD_TESTS=OFF -DBUILD_opencv_ts=OFF ^
        -DBUILD_JAVA=ON -DBUILD_opencv_java=ON -DBUILD_opencv_java_bindings_generator=ON ^
        -DBUILD_opencv_python3=OFF -DBUILD_opencv_python_bindings_generator=OFF -DBUILD_opencv_python_tests=OFF ^
        -DBUILD_opencv_js=OFF -DBUILD_opencv_js_bindings_generator=OFF
)

echo.
echo **** CMAKE MAKEFILE GENERATED ****
echo.

cd /D %build_dir%
mingw32-make -j%compile_core%

echo.
echo **** COMPILATION FINISHED ****
echo.

mingw32-make -j%compile_core% install

echo.
echo **** BINARY DISTRIBUTION FINISHED ****
echo.

cd /D %work_dir%
rmdir /S /Q %src_dir% %build_dir%

echo.
echo **** SRC AND BUILD DIR DELETED ****
echo.

pause