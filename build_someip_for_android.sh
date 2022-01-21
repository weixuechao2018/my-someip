#!/bin/bash

BASEPATH=.

# ----------------------------------------------------------------------------------------------------------------------------
# 需要修改的变量

# 硬件平台架构
#PLATFORM=arm64-v8a
#PLATFORM=armeabi-v7a
#PLATFORM=x86    	# android x86
PLATFORM=x86_64 	# PC LINUX 这个编译不能用


#BUILD_ENV_PLATFORM="Android"
BUILD_ENV_PLATFORM="Linux"

BUILDTYPE=Debug

# ----------------------------------------------------------------------------------------------------------------------------
# boost set config
CURRENT_BOOST_ROOT_PATH=~/Downloads/someip/21/$PLATFORM
CURRENT_BOOST_VERSION=boost-1_74
CURRENT_BOOST_VERSION_NO=107400

# ----------------------------------------------------------------------------------------------------------------------------
# rm
rm -rf CMakeCache.txt
rm -rf CMakeFiles
rm -rf cmake_install.cmake
rm -rf Makefilu:wqe
rm -rf CTestTestfile.cmake
rm -rf ${BASEPATH}/$PLATFORM

# ----------------------------------------------------------------------------------------------------------------------------
SCRIPTDIR="$(cd "$(dirname "$0")"; pwd)"

rm -rf $SCRIPTDIR/set_boost_config.cmake 
rm -rf $SCRIPTDIR/set_someip_config.cmake 
rm -rf $SCRIPTDIR/*.so*
# ----------------------------------------------------------------------------------------------------------------------------

BUILD_NDK_VERSION_NO=
NDKPATH=
CMAKEPATH=

ANDROID_TARGET_32=
ANDROID_TARGET_64=

if [[ "x86_64" = $PLATFORM ]];
then

NDKPATH=
CMAKEPATH=

ANDROID_TARGET_32=
ANDROID_TARGET_64=
else
# 编译使用android ndk version
BUILD_NDK_VERSION_NO=21.0.6113669

NDKPATH=~/Android/Sdk/ndk/$BUILD_NDK_VERSION_NO
CMAKEPATH=~/Android/Sdk/cmake/3.18.1/bin

ANDROID_TARGET_32=21
ANDROID_TARGET_64=21
fi

#
BUILD_HOST=
ANDROID_PLATFORMS_LOG_VER=
if [[ "arm64-v8a" = $PLATFORM ]];
then
	if [[ "Android" = $BUILD_ENV_PLATFORM ]];
	then
		echo "---------------------------------------------------Android arm64-v8a-------------------------------------------------------------------"
		BUILD_HOST=~/Android/Sdk/ndk/$BUILD_NDK_VERSION_NO/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android$ANDROID_TARGET_64-
		#sed -i '/find_package( Boost 1.55 COMPONENTS system thread filesystem REQUIRED )/d' $SCRIPTDIR/CMakeLists.txt
		ANDROID_PLATFORMS_LOG_VER=$ANDROID_TARGET_64
		echo "set(ANDROID_LOG_LIB ${NDKPATH}/platforms/android-${ANDROID_PLATFORMS_LOG_VER})" >> $SCRIPTDIR/set_someip_config.cmake
	elif [[ "Linux" = $BUILD_ENV_PLATFORM ]];
	then
		echo "---------------------------------------------------linux arm64-v8a-------------------------------------------------------------------"
	else
		echo "---------------------------------------------------arm64-v8a config error------------------------------------------------------------"
	fi
elif [[ "armeabi-v7a" = $PLATFORM ]];
then
	if [[ "Android" = $BUILD_ENV_PLATFORM ]];
	then
		echo "---------------------------------------------------Android armeabi-v7a-------------------------------------------------------------------"
		BUILD_HOST=~/Android/Sdk/ndk/$BUILD_NDK_VERSION_NO/toolchains/llvm/prebuilt/linux-x86_64/bin/armv7a-linux-androideabi$ANDROID_TARGET_32-
		#sed -i '/find_package( Boost 1.55 COMPONENTS system thread filesystem REQUIRED )/d' $SCRIPTDIR/CMakeLists.txt
		ANDROID_PLATFORMS_LOG_VER=$ANDROID_TARGET_32
		echo "set(ANDROID_LOG_LIB ${NDKPATH}/platforms/android-${ANDROID_PLATFORMS_LOG_VER})" >> $SCRIPTDIR/set_someip_config.cmake
	elif [[ "Linux" = $BUILD_ENV_PLATFORM ]];
	then
		echo "---------------------------------------------------linux armeabi-v7a-------------------------------------------------------------------"
	else
		echo "---------------------------------------------------armeabi-v7a config error------------------------------------------------------------"
	fi
elif [[ "x86" = $PLATFORM ]];
then
	if [[ "Android" = $BUILD_ENV_PLATFORM ]];
	then
		echo "---------------------------------------------------Android x86-------------------------------------------------------------------"
		BUILD_HOST=~/Android/Sdk/ndk/$BUILD_NDK_VERSION_NO/toolchains/llvm/prebuilt/linux-x86_64/bin/x86_64-linux-android$ANDROID_TARGET_64-
		ANDROID_PLATFORMS_LOG_VER=$ANDROID_TARGET_64
		echo "set(ANDROID_LOG_LIB ${NDKPATH}/platforms/android-${ANDROID_PLATFORMS_LOG_VER})" >> $SCRIPTDIR/set_someip_config.cmake
	else
		echo "---------------------------------------------------x86 config error-------------------------------------------------------------------"
	fi
else [[ "x86_64" = $PLATFORM ]];
	ANDROID_PLATFORMS_LOG_VER=$ANDROID_TARGET_64
	#echo "set(ANDROID_LOG_LIB ${NDKPATH}/platforms/android-${ANDROID_PLATFORMS_LOG_VER})" >> $SCRIPTDIR/set_someip_config.cmake	
fi

echo "BUILD_HOST:$BUILD_HOST"


# ----------------------------------------------------------------------------------------------------------------------------
#echo "add_definitions(-DAndroid)" >> $SCRIPTDIR/set_someip_config.cmake 
#echo "add_definitions(-DSystemD_FOUND)" >> $SCRIPTDIR/set_someip_config.cmake

if [[ "Android" = $BUILD_ENV_PLATFORM ]];
	then
	echo "set(CMAKE_SYSTEM_NAME $BUILD_ENV_PLATFORM)" >> $SCRIPTDIR/set_someip_config.cmake
elif [[ "Linux" = $BUILD_ENV_PLATFORM ]];
then
	echo "set(CMAKE_SYSTEM_NAME $BUILD_ENV_PLATFORM)" >> $SCRIPTDIR/set_someip_config.cmake
else
	echo "---------------------------------------------------set_someip_config.cmake config error-----------------------------------------------------"
fi
echo "set(CMAKE_INSTALL_PREFIX ${BASEPATH}/$PLATFORM)" >> $SCRIPTDIR/set_someip_config.cmake

#set (SystemD_FOUND 1)

echo "set(BOOST_ROOT $CURRENT_BOOST_ROOT_PATH)" >> $SCRIPTDIR/set_boost_config.cmake 
echo "set(BOOST_INCLUDEDIR $CURRENT_BOOST_ROOT_PATH/include/$CURRENT_BOOST_VERSION)" >> $SCRIPTDIR/set_boost_config.cmake 
echo "set(BOOST_LIBRARYDIR $CURRENT_BOOST_ROOT_PATH/lib)" >> $SCRIPTDIR/set_boost_config.cmake  
echo "set(Boost_FOUND 1)" >> $SCRIPTDIR/set_boost_config.cmake 
echo "set(Boost_INCLUDE_DIR $CURRENT_BOOST_ROOT_PATH/include/$CURRENT_BOOST_VERSION)" >> $SCRIPTDIR/set_boost_config.cmake 
echo "set(Boost_LIBRARY_DIR $CURRENT_BOOST_ROOT_PATH/lib)" >> $SCRIPTDIR/set_boost_config.cmake  
echo "set(Boost_VERSION $CURRENT_BOOST_VERSION_NO)" >> $SCRIPTDIR/set_boost_config.cmake 


# ----------------------------------------------------------------------------------------------------------------------------

if [[ "x86_64" = $PLATFORM ]];
then
	cmake \
		-DCMAKE_INSTALL_PREFIX=${BASEPATH}/$PLATFORM \
		-DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
		-DCMAKE_BUILD_TYPE=${BUILDTYPE} \
		-DCMAKE_C_COMPILER=${BUILD_HOST}gcc \
		-DCMAKE_CXX_COMPILER=${BUILD_HOST}g++ \
		-DENABLE_COMPAT=1 \
		-DVSOMEIP_INSTALL_ROUTINGMANAGERD=ON \
		-DENABLE_MULTIPLE_ROUTING_MANAGERS=1 \
		${BASEPATH}
else
	if [[ "Android" = $BUILD_ENV_PLATFORM ]];
	then
		${CMAKEPATH}/cmake \
			-DCMAKE_INSTALL_PREFIX=${BASEPATH}/$PLATFORM \
			-DCMAKE_TOOLCHAIN_FILE=${NDKPATH}/build/cmake/android.toolchain.cmake \
			-DANDROID_ABI=${PLATFORM} \
			-DCMAKE_ANDROID_ARCH_ABI=${PLATFORM} \
			-DANDROID_NDK=${NDKPATH} \
			-DCMAKE_ANDROID_NDK=${NDKPATH} \
			-DANDROID_NATIVE_API_LEVEL=21 \
			-DANDROID_PLATFORM=android-19 \
			-DCMAKE_SYSTEM_VERSION=19 \
			-DCMAKE_SYSTEM_NAME=Android \
			-DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
			-DANDROID_STL=c++_shared \
			-DCMAKE_BUILD_TYPE=${BUILDTYPE} \
			-DANDROID_TOOLCHAIN=clang \
			-DCMAKE_C_COMPILER=${BUILD_HOST}clang \
			-DCMAKE_CXX_COMPILER=${BUILD_HOST}clang++ \
			-DENABLE_COMPAT=1 \
			-DVSOMEIP_INSTALL_ROUTINGMANAGERD=ON \
			-DENABLE_MULTIPLE_ROUTING_MANAGERS=1 \
			${BASEPATH}
	elif [[ "Linux" = $BUILD_ENV_PLATFORM ]]; # arm linux下编译暂时用不到还未实现
	then
		${CMAKEPATH}/cmake \
			-DCMAKE_INSTALL_PREFIX=${BASEPATH}/$PLATFORM \
			-DCMAKE_TOOLCHAIN_FILE=${NDKPATH}/build/cmake/android.toolchain.cmake \
			-DANDROID_ABI=${PLATFORM} \
			-DCMAKE_ANDROID_ARCH_ABI=${PLATFORM} \
			-DANDROID_NDK=${NDKPATH} \
			-DCMAKE_ANDROID_NDK=${NDKPATH} \
			-DANDROID_NATIVE_API_LEVEL=21 \
			-DANDROID_PLATFORM=android-19 \
			-DCMAKE_SYSTEM_VERSION=19 \
			-DCMAKE_SYSTEM_NAME=Android \
			-DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
			-DANDROID_STL=c++_shared \
			-DCMAKE_BUILD_TYPE=${BUILDTYPE} \
			-DANDROID_TOOLCHAIN=clang \
			-DCMAKE_C_COMPILER=${BUILD_HOST}clang \
			-DCMAKE_CXX_COMPILER=${BUILD_HOST}clang++ \
			-DENABLE_COMPAT=1 \
			-DVSOMEIP_INSTALL_ROUTINGMANAGERD=ON \
			-DENABLE_MULTIPLE_ROUTING_MANAGERS=1 \
			${BASEPATH}
	else
		echo "---------------------------------------------------cmake build error------------------------------------------------------------"
	fi
	
fi

make VERBOSE=1
make install
set +x



#-H/Users/apple/development/CxxTest/app/src/main/cpp # 源码目录,AS特有(可选,as的cmake必要)
#-B/Users/apple/development/CxxTest/app/.cxx/cmake/debug/arm64-v8a # 编译产出的临时文件目录, AS特有 (可选, as的cmake必要)
#-DCMAKE_CXX_FLAGS=-std=c++14 # c++附加的编译参数, 这里意思采用c++14标准编译 (可选)
#-DCMAKE_BUILD_TYPE=Debug # 编译类型, Debug/Release, Release模式下so会小一点,删除了符号表.
#-DCMAKE_TOOLCHAIN_FILE=/Users/apple/developer/AndroidSDK/ndk/21.3.6528147/build/cmake/android.toolchain.cmake # 工具链文件路径(必要,重要)
#-DCMAKE_ANDROID_ARCH_ABI=arm64-v8a # 架构类型(必要)
#-DANDROID_ABI=arm64-v8a # (可选)
#-DCMAKE_ANDROID_NDK=/Users/apple/developer/AndroidSDK/ndk/21.3.6528147 # (必要)
#-DANDROID_NDK=/Users/apple/developer/AndroidSDK/ndk/21.3.6528147 # (可选)
#-DANDROID_PLATFORM=android-19 # 最小支持版本(可选)
#-DCMAKE_EXPORT_COMPILE_COMMANDS=ON # 是否导出详细编译参数(可选)
#-DCMAKE_LIBRARY_OUTPUT_DIRECTORY=/Users/apple/development/CxxTest/app/build/intermediates/cmake/debug/obj/arm64-v8a # lib临时目录(可选)
#-DCMAKE_MAKE_PROGRAM=/Users/apple/developer/AndroidSDK/cmake/3.10.2.4988404/bin/ninja # 构建工具, 根据需要(可选)
#-DCMAKE_SYSTEM_NAME=Android # 系统名称(必要,重要)
#-DCMAKE_SYSTEM_VERSION=19 # 最小支持版本(必要)
#-GNinja # 生成类型, ninja据说比make要快, 默认生成Makefile (可选)
