#!/bin/bash

BASEPATH=.

# ----------------------------------------------------------------------------------------------------------------------------
# 需要修改的变量

# 硬件平台架构
#PLATFORM=arm64-v8a
#PLATFORM=armeabi-v7a
#PLATFORM=x86    	# android x86
PLATFORM=x86_64 	# PC LINUX 这个编译不能用


PlatformOS="Android"
#PlatformOS="Linux"      # linux或 arm linux 下需要编译相关的boost

BUILDTYPE=Debug

# ----------------------------------------------------------------------------------------------------------------------------
# boost set config
if [[ "Android" = $PlatformOS ]];
then
	CURRENT_BOOST_ROOT_PATH=~/Downloads/"Boost-for-Android-master"/20/$PLATFORM
elif [[ "Linux" = $PlatformOS ]];
then
	CURRENT_BOOST_ROOT_PATH=~/Downloads/someip/linux_x86_64
else
	echo "---------------------------------------------------CURRENT_BOOST_ROOT_PATH config error------------------------------------------------------------"
fi

CURRENT_BOOST_VERSION_NUM=1_74
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
rm -rf $SCRIPTDIR/set_boost_static_imported_config.cmake
rm -rf $SCRIPTDIR/*.so*
# ----------------------------------------------------------------------------------------------------------------------------

BUILD_NDK_VERSION_NO=
NDKPATH=
CMAKEPATH=

ANDROID_TARGET_32=
ANDROID_TARGET_64=

if [[ "Linux" = $PlatformOS ]];
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
AndroidBinariesPath=
ANDROID_PLATFORMS_LOG_VER=
if [[ "arm64-v8a" = $PLATFORM ]];
then
	if [[ "Android" = $PlatformOS ]];
	then
		echo "---------------------------------------------------Android arm64-v8a-------------------------------------------------------------------"
		AndroidBinariesPath=~/Android/Sdk/ndk/$BUILD_NDK_VERSION_NO/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android$ANDROID_TARGET_64-
		#sed -i '/find_package( Boost 1.55 COMPONENTS system thread filesystem REQUIRED )/d' $SCRIPTDIR/CMakeLists.txt
		ANDROID_PLATFORMS_LOG_VER=$ANDROID_TARGET_64
		echo "set(ANDROID_LOG_LIB ${NDKPATH}/platforms)" >> $SCRIPTDIR/set_someip_config.cmake 	#为了解决android log编译错误
	elif [[ "Linux" = $PlatformOS ]];
	then
		echo "---------------------------------------------------linux arm64-v8a-------------------------------------------------------------------"
	else
		echo "---------------------------------------------------arm64-v8a config error------------------------------------------------------------"
	fi
elif [[ "armeabi-v7a" = $PLATFORM ]];
then
	if [[ "Android" = $PlatformOS ]];
	then
		echo "---------------------------------------------------Android armeabi-v7a-------------------------------------------------------------------"
		AndroidBinariesPath=~/Android/Sdk/ndk/$BUILD_NDK_VERSION_NO/toolchains/llvm/prebuilt/linux-x86_64/bin/armv7a-linux-androideabi$ANDROID_TARGET_32-
		#sed -i '/find_package( Boost 1.55 COMPONENTS system thread filesystem REQUIRED )/d' $SCRIPTDIR/CMakeLists.txt
		ANDROID_PLATFORMS_LOG_VER=$ANDROID_TARGET_32
		echo "set(ANDROID_LOG_LIB ${NDKPATH}/platforms)" >> $SCRIPTDIR/set_someip_config.cmake	#为了解决android log编译错误
	elif [[ "Linux" = $PlatformOS ]];
	then
		echo "---------------------------------------------------linux armeabi-v7a-------------------------------------------------------------------"
	else
		echo "---------------------------------------------------armeabi-v7a config error------------------------------------------------------------"
	fi
elif [[ "x86" = $PLATFORM ]];
then
	if [[ "Android" = $PlatformOS ]];
	then
		echo "---------------------------------------------------Android x86-------------------------------------------------------------------"
		AndroidBinariesPath=~/Android/Sdk/ndk/$BUILD_NDK_VERSION_NO/toolchains/llvm/prebuilt/linux-x86_64/bin/i686-linux-android$ANDROID_TARGET_32-
		ANDROID_PLATFORMS_LOG_VER=$ANDROID_TARGET_32
		echo "set(ANDROID_LOG_LIB ${NDKPATH}/platforms)" >> $SCRIPTDIR/set_someip_config.cmake	#为了解决android log编译错误
		#echo "set(LOCAL_CFLAGS += -m32)" >> $SCRIPTDIR/set_someip_config.cmake
		#echo "set(LOCAL_CFLAGS += -m32)" >> $SCRIPTDIR/set_someip_config.cmake

		#echo "set(ADDRESS_MODEL 32)" >> $SCRIPTDIR/set_someip_config.cmake
		#echo "set(NODE_TARGET x86)" >> $SCRIPTDIR/set_someip_config.cmake

	else
		echo "---------------------------------------------------x86 config error-------------------------------------------------------------------"
	fi
else [[ "x86_64" = $PLATFORM ]];
	if [[ "Android" = $PlatformOS ]];
	then
		echo "---------------------------------------------------Android x86-------------------------------------------------------------------"
		AndroidBinariesPath=~/Android/Sdk/ndk/$BUILD_NDK_VERSION_NO/toolchains/llvm/prebuilt/linux-x86_64/bin/x86_64-linux-android$ANDROID_TARGET_64-
		ANDROID_PLATFORMS_LOG_VER=$ANDROID_TARGET_64
		echo "set(ANDROID_LOG_LIB ${NDKPATH}/platforms)" >> $SCRIPTDIR/set_someip_config.cmake	#为了解决android log编译错误
		#echo "set(LOCAL_CFLAGS += -m64)" >> $SCRIPTDIR/set_someip_config.cmake
		#echo "set(LOCAL_CFLAGS += -m64)" >> $SCRIPTDIR/set_someip_config.cmake
		
		#echo "set(ADDRESS_MODEL 64)" >> $SCRIPTDIR/set_someip_config.cmake
		#echo "set(NODE_TARGET x64)" >> $SCRIPTDIR/set_someip_config.cmake
	else
		echo "---------------------------------------------------x86 config error-------------------------------------------------------------------"
	fi
fi

echo "AndroidBinariesPath:$AndroidBinariesPath"


# ----------------------------------------------------------------------------------------------------------------------------
#echo "add_definitions(-DAndroid)" >> $SCRIPTDIR/set_someip_config.cmake 
#echo "add_definitions(-DSystemD_FOUND)" >> $SCRIPTDIR/set_someip_config.cmake

if [[ "Android" = $PlatformOS ]];
then
	echo "set(CMAKE_SYSTEM_NAME $PlatformOS)" >> $SCRIPTDIR/set_someip_config.cmake

	if [[ "x86_64" != $PLATFORM ]];
	then
		echo "set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DWITHOUT_SYSTEMD")" >> $SCRIPTDIR/set_someip_config.cmake
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

elif [[ "Linux" = $PlatformOS ]];
then
	echo "set(CMAKE_SYSTEM_NAME $PlatformOS)" >> $SCRIPTDIR/set_someip_config.cmake

	echo "set(CMAKE_INSTALL_PREFIX ${BASEPATH}/$PLATFORM)" >> $SCRIPTDIR/set_someip_config.cmake

	#set (SystemD_FOUND 1)
	
	echo "set(BOOST_ROOT $CURRENT_BOOST_ROOT_PATH)" >> $SCRIPTDIR/set_boost_config.cmake 
	echo "set(BOOST_INCLUDEDIR $CURRENT_BOOST_ROOT_PATH/include/$CURRENT_BOOST_VERSION)" >> $SCRIPTDIR/set_boost_config.cmake 
	echo "set(BOOST_LIBRARYDIR $CURRENT_BOOST_ROOT_PATH/lib)" >> $SCRIPTDIR/set_boost_config.cmake  
	echo "set(Boost_FOUND 1)" >> $SCRIPTDIR/set_boost_config.cmake 
	echo "set(Boost_INCLUDE_DIR $CURRENT_BOOST_ROOT_PATH/include/$CURRENT_BOOST_VERSION)" >> $SCRIPTDIR/set_boost_config.cmake 
	echo "set(Boost_LIBRARY_DIR $CURRENT_BOOST_ROOT_PATH/lib)" >> $SCRIPTDIR/set_boost_config.cmake  
	echo "set(Boost_VERSION $CURRENT_BOOST_VERSION_NO)" >> $SCRIPTDIR/set_boost_config.cmake 
else
	echo "---------------------------------------------------set_someip_config.cmake config error-----------------------------------------------------"
fi


ARCH_BIT=


if [[ "Android" = $PlatformOS ]];
then
	if [[ "armeabi-v7a" = $PLATFORM ]];
	then
		ARCH_BIT="a32"
	elif [[ "arm64-v8a" = $PLATFORM ]];
	then
		ARCH_BIT="a64"	
	elif [[ "x86" = $PLATFORM ]];
	then
		ARCH_BIT="x32"
	elif [[ "x86_64" = $PLATFORM ]];
	then
		ARCH_BIT="x64"
	else
		exit 1
	fi
elif [[ "Linux" = $PlatformOS ]];
then
	if [[ "armeabi-v7a" = $PLATFORM ]];
	then
		ARCH_BIT="a32"
	elif [[ "arm64-v8a" = $PLATFORM ]];
	then
		ARCH_BIT="a64"	
	elif [[ "x86" = $PLATFORM ]];
	then
		ARCH_BIT="x32"
	elif [[ "x86_64" = $PLATFORM ]];
	then
		ARCH_BIT="x64"
	else
		exit 1
	fi
else
	echo "---------------------------------------------------set_someip_config.cmake config error-----------------------------------------------------"
fi

#if [[ "Android" = $PlatformOS ]];
if [[ "???" = $PlatformOS ]];
then
	
	echo "add_library(boost_system STATIC IMPORTED)" >> $SCRIPTDIR/set_boost_static_imported_config.cmake 
	echo "set_target_properties(boost_system PROPERTIES IMPORTED_LOCATION  ${CURRENT_BOOST_ROOT_PATH/lib}/libboost_system-clang-mt-$ARCH_BIT-$CURRENT_BOOST_VERSION_NUM.a)" >> $SCRIPTDIR/set_boost_static_imported_config.cmake 

	echo "add_library(boost_thread STATIC IMPORTED)" >> $SCRIPTDIR/set_boost_static_imported_config.cmake 
	echo "set_target_properties(boost_system PROPERTIES IMPORTED_LOCATION  ${CURRENT_BOOST_ROOT_PATH/lib}/libboost_thread-clang-mt-$ARCH_BIT-$CURRENT_BOOST_VERSION_NUM.a)" >> $SCRIPTDIR/set_boost_static_imported_config.cmake 

	echo "add_library(boost_log_setup STATIC IMPORTED)" >> $SCRIPTDIR/set_boost_static_imported_config.cmake 
	echo "set_target_properties(boost_system PROPERTIES IMPORTED_LOCATION  ${CURRENT_BOOST_ROOT_PATH/lib}/libboost_log_setup-clang-mt-$ARCH_BIT-$CURRENT_BOOST_VERSION_NUM.a)" >> $SCRIPTDIR/set_boost_static_imported_config.cmake 

	echo "add_library(boost_log STATIC IMPORTED)" >> $SCRIPTDIR/set_boost_static_imported_config.cmake 
	echo "set_target_properties(boost_system PROPERTIES IMPORTED_LOCATION  ${CURRENT_BOOST_ROOT_PATH/lib}/libboost_log-clang-mt-$ARCH_BIT-$CURRENT_BOOST_VERSION_NUM.a)" >> $SCRIPTDIR/set_boost_static_imported_config.cmake 

	echo "add_library(boost_filesystem STATIC IMPORTED)" >> $SCRIPTDIR/set_boost_static_imported_config.cmake 
	echo "set_target_properties(boost_system PROPERTIES IMPORTED_LOCATION  ${CURRENT_BOOST_ROOT_PATH/lib}/libboost_filesystem-clang-mt-$ARCH_BIT-$CURRENT_BOOST_VERSION_NUM.a)" >> $SCRIPTDIR/set_boost_static_imported_config.cmake 

	echo "set(Boost_LIBRARIES "log" "boost_system" "boost_thread" "boost_log" "boost_log_setup" "boost_filesystem")" >> $SCRIPTDIR/set_boost_static_imported_config.cmake
#elif [[ "Linux" = $PlatformOS ]];
elif [[ "?????" = $PlatformOS ]];
then
	echo "add_library(boost_system STATIC IMPORTED)" >> $SCRIPTDIR/set_boost_static_imported_config.cmake 
	echo "set_target_properties(boost_system PROPERTIES IMPORTED_LOCATION  ${CURRENT_BOOST_ROOT_PATH/lib}/libboost_system.a)" >> $SCRIPTDIR/set_boost_static_imported_config.cmake 

	echo "add_library(boost_thread STATIC IMPORTED)" >> $SCRIPTDIR/set_boost_static_imported_config.cmake 
	echo "set_target_properties(boost_system PROPERTIES IMPORTED_LOCATION  ${CURRENT_BOOST_ROOT_PATH/lib}/libboost_thread.a)" >> $SCRIPTDIR/set_boost_static_imported_config.cmake 

	echo "add_library(boost_log_setup STATIC IMPORTED)" >> $SCRIPTDIR/set_boost_static_imported_config.cmake 
	echo "set_target_properties(boost_system PROPERTIES IMPORTED_LOCATION  ${CURRENT_BOOST_ROOT_PATH/lib}/libboost_log_setup.a)" >> $SCRIPTDIR/set_boost_static_imported_config.cmake 

	echo "add_library(boost_log STATIC IMPORTED)" >> $SCRIPTDIR/set_boost_static_imported_config.cmake 
	echo "set_target_properties(boost_system PROPERTIES IMPORTED_LOCATION  ${CURRENT_BOOST_ROOT_PATH/lib}/libboost_log.a)" >> $SCRIPTDIR/set_boost_static_imported_config.cmake 

	echo "add_library(boost_filesystem STATIC IMPORTED)" >> $SCRIPTDIR/set_boost_static_imported_config.cmake 
	echo "set_target_properties(boost_system PROPERTIES IMPORTED_LOCATION  ${CURRENT_BOOST_ROOT_PATH/lib}/libboost_filesystem.a)" >> $SCRIPTDIR/set_boost_static_imported_config.cmake 

	echo "set(Boost_LIBRARIES "log" "boost_system" "boost_thread" "boost_log" "boost_log_setup" "boost_filesystem")" >> $SCRIPTDIR/set_boost_static_imported_config.cmake
else
	echo "#--------------------------------------------------------------------------------------------------------" >> $SCRIPTDIR/set_boost_static_imported_config.cmake
fi
#set(Boost_LIBRARIES "log" "boost_system" "boost_thread" "boost_log" "boost_log_setup" "boost_filesystem")

# ----------------------------------------------------------------------------------------------------------------------------
export PATH=$AndroidBinariesPath:$PATH
export AndroidNDKRoot=$AndroidBinariesPath
export AndroidTargetVersion32=$ANDROID_TARGET_32
export AndroidTargetVersion64=$ANDROID_TARGET_64
export NO_BZIP2=1
export PlatformOS=$PlatformOS

if [[ "Android" = $PlatformOS ]];
then
	${CMAKEPATH}/cmake \
		-DCMAKE_INSTALL_PREFIX=${BASEPATH}/$PLATFORM \
		-DCMAKE_TOOLCHAIN_FILE=${NDKPATH}/build/cmake/android.toolchain.cmake \
		-DANDROID_ABI=${PLATFORM} \
		-DCMAKE_ANDROID_ARCH_ABI=${PLATFORM} \
		-DANDROID_NDK=${NDKPATH} \
		-DCMAKE_ANDROID_NDK=${NDKPATH} \
		-DANDROID_NATIVE_API_LEVEL=21 \
		-DANDROID_PLATFORM=android-$ANDROID_PLATFORMS_LOG_VER \
		-DCMAKE_SYSTEM_VERSION=$ANDROID_PLATFORMS_LOG_VER \
		-DCMAKE_SYSTEM_NAME=Android \
		-DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
		-DANDROID_STL=c++_shared \
		-DCMAKE_BUILD_TYPE=${BUILDTYPE} \
		-DANDROID_TOOLCHAIN=clang \
		-DCMAKE_C_COMPILER=${AndroidBinariesPath}clang \
		-DCMAKE_CXX_COMPILER=${AndroidBinariesPath}clang++ \
		-DENABLE_COMPAT=1 \
		-DVSOMEIP_INSTALL_ROUTINGMANAGERD=ON \
		-DENABLE_MULTIPLE_ROUTING_MANAGERS=1 \
		${BASEPATH}
elif [[ "Linux" = $PlatformOS ]]; 
then
	if [[ "x86_64" = $PLATFORM ]] && [[ "x86" = $PlatformOS ]];
	then
		cmake \
			-DCMAKE_INSTALL_PREFIX=${BASEPATH}/linux_$PLATFORM \
			-DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
			-DCMAKE_BUILD_TYPE=${BUILDTYPE} \
			-DCMAKE_C_COMPILER=${AndroidBinariesPath}gcc \
			-DCMAKE_CXX_COMPILER=${AndroidBinariesPath}g++ \
			-DENABLE_COMPAT=1 \
			-DVSOMEIP_INSTALL_ROUTINGMANAGERD=ON \
			-DENABLE_MULTIPLE_ROUTING_MANAGERS=1 \
			${BASEPATH}
	else # arm linux下编译暂时用不到还未实现
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
		-DCMAKE_C_COMPILER=${AndroidBinariesPath}clang \
		-DCMAKE_CXX_COMPILER=${AndroidBinariesPath}clang++ \
		-DENABLE_COMPAT=1 \
		-DVSOMEIP_INSTALL_ROUTINGMANAGERD=ON \
		-DENABLE_MULTIPLE_ROUTING_MANAGERS=1 \
		${BASEPATH}
	fi
else
	echo "---------------------------------------------------cmake build error------------------------------------------------------------"
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
