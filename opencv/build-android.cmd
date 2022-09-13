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
set install_dir=D:\Library\OpenCV\OpenCV-Android

set eigen_cmake_dir=D:\Library\libeigen\share\eigen3\cmake
set sed_tool="C:\Program Files\Git\usr\bin\sed.exe"
@REM set http_proxy=http://127.0.0.1:7890
@REM set https_proxy=http://127.0.0.1:7890

set compile_core=8
set build_android_shared=0
set build_android_project=1
set build_android_example=0
set install_android_example=1
set android_stl=c++_static
@REM set android_stl=c++_shared
set android_abi=arm64-v8a
@REM set android_abi=armeabi-v7a
set android_platform=24

set ant_tool=D:/Library/ant/bin/ant.bat
set android_sdk_dir=C:/Users/chuixue/AppData/Local/Android/Sdk
@REM set android_sdktools_dir=%android_sdk_dir%/cmdline-tools/latest
set android_sdktools_dir=%android_sdk_dir%/tools
@REM set android_ndk_dir=%android_sdk_dir%/ndk/25.1.8937393
@REM set android_ndk_dir=%android_sdk_dir%/ndk/23.2.8568313
set android_ndk_dir=%android_sdk_dir%/ndk/21.4.7075529
@REM set android_ndk_dir=%android_sdk_dir%/ndk/17.2.4988734
set cross_cmake_file=%android_ndk_dir%/build/cmake/android.toolchain.cmake

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

if %build_android_shared% == 0 (
    set build_shared=OFF
    set build_fat_java_lib=ON
) else (
    set build_shared=ON
    set build_fat_java_lib=OFF
)

if %build_android_project% == 0 (
    set build_android_projects=OFF
) else (
    set build_android_projects=ON
)

if %build_android_example% == 0 (
    if exist %src_dir%\modules\java\android_sdk\CMakeLists.txt (
        cd /D %src_dir%\modules\java\android_sdk
        %sed_tool% -i "s/[#]*COMMAND .\/gradlew/#COMMAND .\/gradlew/g" CMakeLists.txt
    )

    set build_android_examples=OFF

    if exist %src_dir%\samples\android\CMakeLists.txt (
        cd /D %src_dir%\samples\android
        %sed_tool% -i "s/if(0)/if(HAVE_opencv_highgui)/g" CMakeLists.txt
    )

    if exist %src_dir%\samples\android\face-detection\jni\CMakeLists.txt (
        cd /D %src_dir%\samples\android\face-detection\jni
        %sed_tool% -i "s/\"opencv_objdetect\"/\"opencv_java\"/g" CMakeLists.txt
        %sed_tool% -i "s/target_link_libraries(${target} ${ANDROID_OPENCV_COMPONENTS} log)/target_link_libraries(${target} ${ANDROID_OPENCV_COMPONENTS})/g" CMakeLists.txt
    )

    if exist %src_dir%\samples\android\tutorial-2-mixedprocessing\jni\CMakeLists.txt (
        cd /D %src_dir%\samples\android\tutorial-2-mixedprocessing\jni
        %sed_tool% -i "s/\"opencv_features2d\"/\"opencv_java\"/g" CMakeLists.txt
    )

    if exist %src_dir%\samples\android\tutorial-4-opencl\jni\CMakeLists.txt (
        cd /D %src_dir%\samples\android\tutorial-4-opencl\jni
        %sed_tool% -i "s/\"opencv_imgproc\"/\"opencv_java\"/g" CMakeLists.txt
    )
) else (
    if exist %src_dir%\modules\java\android_sdk\CMakeLists.txt (
        cd /D %src_dir%\modules\java\android_sdk
        %sed_tool% -i "s/[#]*COMMAND .\/gradlew/COMMAND .\/gradlew/g" CMakeLists.txt
    )

    set build_android_projects=ON
    set build_android_examples=ON

    set ANDROID_SDK_ROOT=%android_sdk_dir%
    set ANDROID_NDK=%android_ndk_dir%
    set ANDROID_HOME=%android_sdk_dir%
    set ANDROID_NDK_HOME=%android_ndk_dir%

    if %build_android_shared% == 0 (
        if exist %src_dir%\samples\android\CMakeLists.txt (
            cd /D %src_dir%\samples\android
            %sed_tool% -i "s/if(0)/if(HAVE_opencv_highgui)/g" CMakeLists.txt
        )

        if exist %src_dir%\samples\android\face-detection\jni\CMakeLists.txt (
            cd /D %src_dir%\samples\android\face-detection\jni
            %sed_tool% -i "s/\"opencv_objdetect\"/\"opencv_java\"/g" CMakeLists.txt
            %sed_tool% -i "s/target_link_libraries(${target} ${ANDROID_OPENCV_COMPONENTS} log)/target_link_libraries(${target} ${ANDROID_OPENCV_COMPONENTS})/g" CMakeLists.txt
        )

        if exist %src_dir%\samples\android\tutorial-2-mixedprocessing\jni\CMakeLists.txt (
            cd /D %src_dir%\samples\android\tutorial-2-mixedprocessing\jni
            %sed_tool% -i "s/\"opencv_features2d\"/\"opencv_java\"/g" CMakeLists.txt
        )

        if exist %src_dir%\samples\android\tutorial-4-opencl\jni\CMakeLists.txt (
            cd /D %src_dir%\samples\android\tutorial-4-opencl\jni
            %sed_tool% -i "s/\"opencv_imgproc\"/\"opencv_java\"/g" CMakeLists.txt
        )
    ) else (
        if exist %src_dir%\samples\android\CMakeLists.txt (
            cd /D %src_dir%\samples\android
            %sed_tool% -i "s/if(HAVE_opencv_highgui)/if(0)/g" CMakeLists.txt
        )

        if exist %src_dir%\samples\android\face-detection\jni\CMakeLists.txt (
            cd /D %src_dir%\samples\android\face-detection\jni
            %sed_tool% -i "s/\"opencv_java\"/\"opencv_objdetect\"/g" CMakeLists.txt
            %sed_tool% -i "s/target_link_libraries(${target} ${ANDROID_OPENCV_COMPONENTS})/target_link_libraries(${target} ${ANDROID_OPENCV_COMPONENTS} log)/g" CMakeLists.txt
        )

        if exist %src_dir%\samples\android\tutorial-2-mixedprocessing\jni\CMakeLists.txt (
            cd /D %src_dir%\samples\android\tutorial-2-mixedprocessing\jni
            %sed_tool% -i "s/\"opencv_java\"/\"opencv_features2d\"/g" CMakeLists.txt
        )

        if exist %src_dir%\samples\android\tutorial-4-opencl\jni\CMakeLists.txt (
            cd /D %src_dir%\samples\android\tutorial-4-opencl\jni
            %sed_tool% -i "s/\"opencv_java\"/\"opencv_imgproc\"/g" CMakeLists.txt
        )
    )
)

if %install_android_example% == 0 (
    set install_android_examples=OFF
) else (
    set build_android_projects=ON
    set install_android_examples=ON
)

cd /D %src_dir%
cmake -G"MinGW Makefiles" -DCMAKE_TOOLCHAIN_FILE=%cross_cmake_file% -S. -B%build_dir% -DCMAKE_INSTALL_PREFIX=%install_dir% -DCMAKE_BUILD_TYPE=Release ^
    -DANT_EXECUTABLE=%ant_tool% -DANDROID_SDK=%android_sdk_dir% -DANDROID_SDK_TOOLS=%android_sdktools_dir% -DANDROID_NDK=%android_ndk_dir% ^
    -DANDROID_STL=%android_stl% -DANDROID_ABI=%android_abi% -DANDROID_PLATFORM=%android_platform% -DANDROID_NATIVE_API_LEVEL=%android_platform% ^
    -DBUILD_ANDROID_PROJECTS=%build_android_projects% -DBUILD_ANDROID_EXAMPLES=%build_android_examples% -DINSTALL_ANDROID_EXAMPLES=%install_android_examples% ^
    -DWITH_ANDROID_MEDIANDK=ON -DWITH_ANDROID_NATIVE_CAMERA=ON ^
    -DOPENCV_EXTRA_MODULES_PATH=%extra_mod_dir% -DBUILD_SHARED_LIBS=%build_shared% -DBUILD_FAT_JAVA_LIB=%build_fat_java_lib% ^
    -DOPENCV_ENABLE_NONFREE=ON -DWITH_OPENMP=ON -DWITH_OPENCL=ON -DWITH_OPENCL_SVM=ON -DWITH_TBB=ON -DBUILD_TBB=ON ^
    -DWITH_PROTOBUF=ON -DBUILD_PROTOBUF=ON -DWITH_OPENEXR=ON -DBUILD_OPENEXR=ON ^
    -DWITH_JASPER=OFF -DBUILD_JASPER=OFF -DWITH_OPENJPEG=ON -DBUILD_OPENJPEG=ON ^
    -DWITH_EIGEN=ON -DEigen3_DIR=%eigen_cmake_dir% -DWITH_OPENGL=OFF -DWITH_QT=OFF -DBUILD_opencv_cvv=OFF ^
    -DWITH_FREETYPE=OFF -DBUILD_opencv_freetype=OFF -DWITH_OPENVX=OFF -DWITH_OPENCLAMDBLAS=OFF -DWITH_IPP=OFF ^
    -DOPENCV_GENERATE_SETUPVARS=OFF -DWITH_TESSERACT=OFF -DWITH_CUDA=OFF ^
    -DBUILD_opencv_world=OFF -DBUILD_opencv_rgbd=ON -DWITH_VTK=OFF -DBUILD_opencv_viz=OFF ^
    -DBUILD_PACKAGE=OFF -DBUILD_PERF_TESTS=OFF -DBUILD_TESTS=OFF -DBUILD_opencv_ts=OFF ^
    -DBUILD_JAVA=ON -DBUILD_opencv_java=ON -DBUILD_opencv_java_bindings_generator=ON ^
    -DBUILD_opencv_python3=OFF -DBUILD_opencv_python_bindings_generator=OFF -DBUILD_opencv_python_tests=OFF ^
    -DBUILD_opencv_js=OFF -DBUILD_opencv_js_bindings_generator=OFF

echo.
echo **** CMAKE MAKEFILE GENERATED ****
echo.

cd /D %build_dir%
mingw32-make -j%compile_core%

echo.
echo **** COMPILATION FINISHED ****
echo.

mingw32-make -j%compile_core% install

if %build_android_example% == 1 (
    if %build_android_shared% == 1 (
        if exist %install_dir%\samples\CMakeLists.txt (
            cd /D %install_dir%\samples
            %sed_tool% -i "s/if(0)/if(HAVE_opencv_highgui)/g" CMakeLists.txt
        )

        if exist %install_dir%\samples\face-detection\jni\CMakeLists.txt (
            cd /D %install_dir%\samples\face-detection\jni
            %sed_tool% -i "s/\"opencv_objdetect\"/\"opencv_java\"/g" CMakeLists.txt
            %sed_tool% -i "s/target_link_libraries(${target} ${ANDROID_OPENCV_COMPONENTS} log)/target_link_libraries(${target} ${ANDROID_OPENCV_COMPONENTS})/g" CMakeLists.txt
        )

        if exist install_dir%\samples\tutorial-2-mixedprocessing\jni\CMakeLists.txt (
            cd /D %install_dir%\samples\tutorial-2-mixedprocessing\jni
            %sed_tool% -i "s/\"opencv_features2d\"/\"opencv_java\"/g" CMakeLists.txt
        )

        if exist %install_dir%\samples\tutorial-4-opencl\jni\CMakeLists.txt (
            cd /D %install_dir%\samples\tutorial-4-opencl\jni
            %sed_tool% -i "s/\"opencv_imgproc\"/\"opencv_java\"/g" CMakeLists.txt
        )
    )
)

echo.
echo **** BINARY DISTRIBUTION FINISHED ****
echo.

cd /D %work_dir%
rmdir /S /Q %src_dir% %build_dir%

echo.
echo **** SRC AND BUILD DIR DELETED ****
echo.

pause