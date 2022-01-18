# 环境的设置
BASEPATH=.

BUILD_NDK_VERSION_NO=19.2.5345600

BUILD_HOST=~/Android/Sdk/ndk/$BUILD_NDK_VERSION_NO/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android21
NDKPATH=~/Android/Sdk/ndk/$BUILD_NDK_VERSION_NO/
CMAKEPATH=~/Android/Sdk/cmake/3.18.1/bin

PLATFORM=arm64-v8a
BUILDTYPE=Debug

BUILD_CROSS_TOOL_C=${BUILD_HOST}-clang
BUILD_CROSS_TOOL_CXX=${BUILD_HOST}-clang++

# boos 设置
CURRENT_BOOST_ROOT_PATH=~/Downloads/someip/19/$PLATFORM
CURRENT_BOOST_VERSION=boost-1_74
CURRENT_BOOST_VERSION_NO=107300

rm -rf CMakeCache.txt
rm -rf CMakeFiles
rm -rf cmake_install.cmake
rm -rf Makefilu:wqe
rm -rf CTestTestfile.cmake
rm -rf Makefile

SCRIPTDIR="$(cd "$(dirname "$0")"; pwd)"

rm -rf $SCRIPTDIR/set_boost_config.cmake 
rm -rf $SCRIPTDIR/set_someip_config.cmake 

echo "add_definitions(-DANDROID)" >> $SCRIPTDIR/set_someip_config.cmake
echo "add_definitions(-DSystemD_FOUND)" >> $SCRIPTDIR/set_someip_config.cmake
#set (SystemD_FOUND 1)

echo "set(BOOST_ROOT $CURRENT_BOOST_ROOT_PATH)" >> $SCRIPTDIR/set_boost_config.cmake 
echo "set(BOOST_INCLUDEDIR $CURRENT_BOOST_ROOT_PATH/include/$CURRENT_BOOST_VERSION)" >> $SCRIPTDIR/set_boost_config.cmake 
echo "set(BOOST_LIBRARYDIR $CURRENT_BOOST_ROOT_PATH/lib)" >> $SCRIPTDIR/set_boost_config.cmake  
echo "set(Boost_FOUND 1)" >> $SCRIPTDIR/set_boost_config.cmake 
echo "set(Boost_INCLUDE_DIR $CURRENT_BOOST_ROOT_PATH/include/$CURRENT_BOOST_VERSION)" >> $SCRIPTDIR/set_boost_config.cmake 
echo "set(Boost_LIBRARY_DIR $CURRENT_BOOST_ROOT_PATH/lib)" >> $SCRIPTDIR/set_boost_config.cmake  
echo "set(Boost_VERSION $CURRENT_BOOST_VERSION_NO)" >> $SCRIPTDIR/set_boost_config.cmake 

#echo "set(CMAKE_C_COMPILER $BUILD_CROSS_TOOL_C)" >> $SCRIPTDIR/set_boost_config.cmake 
#echo "set(CMAKE_CXX_COMPILER $BUILD_CROSS_TOOL_CXX)" >> $SCRIPTDIR/set_boost_config.cmake 

${CMAKEPATH}/cmake \
	-DCMAKE_TOOLCHAIN_FILE=${NDKPATH}/build/cmake/android.toolchain.cmake \
	-DANDROID_ABI=${PLATFORM} \
	-DANDROID_NDK=${NDKPATH} \
	-DANDROID_NATIVE_API_LEVEL=21 \
	-DANDROID_PLATFORM=android-21 \
	-DANDROID_STL=c++_shared \
	-DCMAKE_BUILD_TYPE=${BUILDTYPE} \
	-DANDROID_TOOLCHAIN=clang \
	-DCMAKE_C_COMPILER=${BUILD_HOST}-clang \
	-DCMAKE_CXX_COMPILER=${BUILD_HOST}-clang++ \
	-DCMAKE_INSTALL_PREFIX=${BASEPATH}/out/ \
	-DENABLE_COMPAT=1 \
	-DVSOMEIP_INSTALL_ROUTINGMANAGERD=ON \
	-DENABLE_MULTIPLE_ROUTING_MANAGERS=1 \
	${BASEPATH}
make VERBOSE=1
make install
set +x
