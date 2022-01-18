BASE_DIR=`pwd`
echo "current path: $BASE_DIR"

SCRIPTDIR="$(cd "$(dirname "$0")"; pwd)" # " # This extra quote fixes syntax highlighting in mcedit
echo "SCRIPTDIR '$SCRIPTDIR'."

# Add common build methods
. "$SCRIPTDIR"/build-common.sh

echo "version '$1'."

#-----------------------------------------------------------------------------------------------------------------
CLEAN=no
register_option "--clean"    do_clean     "Delete all previously downloaded and built files, then exit."
do_clean () {	CLEAN=yes; }


#LIBRARIES=--with-libraries=date_time,filesystem,program_options,regex,signals,system,thread,iostreams,locale
LIBRARIES=
register_option "--with-libraries=<list>" do_with_libraries "Comma separated list of libraries to build."
do_with_libraries () {
  for lib in $(echo $1 | tr ',' '\n') ; do LIBRARIES="--with-$lib ${LIBRARIES}"; done
}

register_option "--without-libraries=<list>" do_without_libraries "Comma separated list of libraries to exclude from the build."
do_without_libraries () {	LIBRARIES="--without-libraries=$1"; }
do_without_libraries () {
  for lib in $(echo $1 | tr ',' '\n') ; do LIBRARIES="--without-$lib ${LIBRARIES}"; done
}

register_option "--prefix=<path>" do_prefix "Prefix to be used when installing libraries and includes."
do_prefix () {
    if [ -d $1 ]; then
        PREFIX=$1;
    fi
}

ARCHLIST=
register_option "--arch=<list>" do_arch "Comma separated list of architectures to build: arm64-v8a,armeabi,armeabi-v7a,mips,mips64,x86,x86_64"
do_arch () {
  for ARCH in $(echo $1 | tr ',' '\n') ; do ARCHLIST="$ARCH ${ARCHLIST}"; done
}

ANDROID_TARGET_32=21
ANDROID_TARGET_64=21
register_option "--target-version=<version>" select_target_version \
                "Select Android's target version" "$ANDROID_TARGET_32"
select_target_version () {

    if [ "$1" -lt 16 ]; then
        ANDROID_TARGET_32="16"
        ANDROID_TARGET_64="21"
    elif [ "$1" = 20 ]; then
        ANDROID_TARGET_32="19"
        ANDROID_TARGET_64="21"
    elif [ "$1" -lt 21 ]; then
        ANDROID_TARGET_32="$1"
        ANDROID_TARGET_64="21"
    elif [ "$1" = 25 ]; then
        ANDROID_TARGET_32="24"
        ANDROID_TARGET_64="24"
    else
        ANDROID_TARGET_32="$1"
        ANDROID_TARGET_64="$1"
    fi
}

#-----------------------------------------------------------------------------------------------------------------
PROGRAM_PARAMETERS="<ndk-root>"
PROGRAM_DESCRIPTION=\
"       Boost For Android\n"\
"Copyright (C) 2010 Mystic Tree Games\n"\

extract_parameters $@

#-----------------------------------------------------------------------------------------------------------------
BUILD_DIR="./build/"
#VSOMEIP_TAR="vsomeip-.tar.bz2"
#VSOMEIP_DIR="vsomeip-"
VSOMEIP_TAR=
VSOMEIP_DIR=vsomeip-3.1.20.3

#-----------------------------------------------------------------------------------------------------------------
if [ $CLEAN = yes ] ; then
	echo "Cleaning: $BUILD_DIR"
	#rm -f -r $PROGDIR/$BUILD_DIR

	echo "Cleaning: $VSOMEIP_DIR"
	#rm -f -r $PROGDIR/$VSOMEIP_DIR

	echo "Cleaning: $VSOMEIP_TAR"
	#rm -f $PROGDIR/$VSOMEIP_TAR

	echo "Cleaning: logs"
	rm -f -r logs
	rm -f build.log

  [ "$DOWNLOAD" = "yes" ] || exit 0
fi

# It is almost never desirable to have the boost-X_Y_Z directory from
# previous builds as this script doesn't check in which state it's
# been left (bootstrapped, patched, built, ...). Unless maybe during
# a debug, in which case it's easy for a developer to comment out
# this code.

#if [ -d "$PROGDIR/$VSOMEIP_DIR" ]; then
	#echo "Cleaning: $VSOMEIP_DIR"
	#rm -f -r $PROGDIR/$VSOMEIP_DIR
#fi

#if [ -d "$PROGDIR/$BUILD_DIR" ]; then
	#echo "Cleaning: $BUILD_DIR"
	#rm -f -r $PROGDIR/$BUILD_DIR
#fi

#-----------------------------------------------------------------------------------------------------------------
# android ndk root dir
echo "PARAMETERS: $PARAMETERS"
AndroidNDKRoot=$PARAMETERS
if [ -z "$AndroidNDKRoot" ] ; then
  if [ -n "${ANDROID_BUILD_TOP}" ]; then # building from Android sources
    AndroidNDKRoot="${ANDROID_BUILD_TOP}/prebuilts/ndk/current"
    export AndroidSourcesDetected=1
  elif [ -z "`which ndk-build`" ]; then
    dump "ERROR: You need to provide a <ndk-root>!"
    exit 1
  else
    AndroidNDKRoot=`which ndk-build`
    AndroidNDKRoot=`dirname $AndroidNDKRoot`
  fi
  echo "Using AndroidNDKRoot = $AndroidNDKRoot"
else
  # User passed the NDK root as a parameter. Make sure the directory
  # exists and make it an absolute path. ".cmd" is for Windows support.
  if [ ! -f "$AndroidNDKRoot/ndk-build" ] && [ ! -f "$AndroidNDKRoot/ndk-build.cmd" ]; then
    dump "ERROR: $AndroidNDKRoot is not a valid NDK root"
    exit 1
  fi
  AndroidNDKRoot=$(cd $AndroidNDKRoot; pwd -P)
fi
export AndroidNDKRoot

echo "AndroidNDKRoot: $AndroidNDKRoot"


CMAKE_SOMEIP_PATH_VER=$(ls -lr $AndroidNDKRoot/../../cmake | grep -v grep | grep ^d | awk '{print $9}')
CMAKE_SOMEIP_PATH=$(cd $AndroidNDKRoot/../../cmake/$CMAKE_SOMEIP_PATH_VER/bin; pwd)
echo "CMAKE_SOMEIP_PATH_VER: $CMAKE_SOMEIP_PATH_VER"
echo "CMAKE_SOMEIP_PATH: $CMAKE_SOMEIP_PATH"

# 相对路径转绝对路径
NDK_BUNDLE_PATH=$(cd $AndroidNDKRoot/../../ndk-bundle; pwd)
echo "NDK_BUNDLE_PATH: $NDK_BUNDLE_PATH"

#-----------------------------------------------------------------------------------------------------------------
# Check platform patch
case "$HOST_OS" in
    linux)
        PlatformOS=linux
        ;;
    darwin|freebsd)
        PlatformOS=darwin
        ;;
    windows|cygwin)
        PlatformOS=windows
        ;;
    *)  # let's play safe here
        PlatformOS=linux
esac

echo "#-----------------------------------------------------------------------------------------------------------------"
echo "PlatformOS: $PlatformOS"
echo "#*****************************************************************************************************************"

#-----------------------------------------------------------------------------------------------------------------
# 
NDK_RELEASE_FILE=$AndroidNDKRoot"/RELEASE.TXT"
if [ -f "${NDK_RELEASE_FILE}" ]; then
    NDK_RN=`cat $NDK_RELEASE_FILE | sed 's/^r\(.*\)$/\1/g'`
elif [ -n "${AndroidSourcesDetected}" ]; then
    if [ -f "${ANDROID_BUILD_TOP}/ndk/docs/CHANGES.html" ]; then
        NDK_RELEASE_FILE="${ANDROID_BUILD_TOP}/ndk/docs/CHANGES.html"
        NDK_RN=`grep "android-ndk-" "${NDK_RELEASE_FILE}" | head -1 | sed 's/^.*r\(.*\)$/\1/'`
    elif [ -f "${ANDROID_BUILD_TOP}/ndk/docs/text/CHANGES.text" ]; then
        NDK_RELEASE_FILE="${ANDROID_BUILD_TOP}/ndk/docs/text/CHANGES.text"
        NDK_RN=`grep "android-ndk-" "${NDK_RELEASE_FILE}" | head -1 | sed 's/^.*r\(.*\)$/\1/'`
    else
        dump "ERROR: can not find ndk version"
        exit 1
    fi
else
    NDK_RELEASE_FILE=$AndroidNDKRoot"/source.properties"
    if [ -f "${NDK_RELEASE_FILE}" ]; then
        NDK_RN=`cat $NDK_RELEASE_FILE | grep 'Pkg.Revision' | sed -E 's/^.*[=] *([0-9]+[.][0-9]+)[.].*/\1/g'`
    else
        dump "ERROR: can not find ndk version"
        exit 1
    fi
fi

echo "#-----------------------------------------------------------------------------------------------------------------"
echo "NDK_RELEASE_FILE : $NDK_RELEASE_FILE"
echo "Detected Android NDK version $NDK_RN"
echo "#*****************************************************************************************************************"

CONFIG_VARIANT=someip

case "$NDK_RN" in
	4*)
		TOOLCHAIN=${TOOLCHAIN:-arm-eabi-4.4.0}
		CXXPATH=$AndroidNDKRoot/build/prebuilt/$PlatformOS-x86/${TOOLCHAIN}/bin/arm-eabi-g++
		TOOLSET=gcc-androidR4
		;;
	5*)
		TOOLCHAIN=${TOOLCHAIN:-arm-linux-androideabi-4.4.3}
		CXXPATH=$AndroidNDKRoot/toolchains/${TOOLCHAIN}/prebuilt/$PlatformOS-x86/bin/arm-linux-androideabi-g++
		TOOLSET=gcc-androidR5
		;;
	7-crystax-5.beta3)
		TOOLCHAIN=${TOOLCHAIN:-arm-linux-androideabi-4.6.3}
		CXXPATH=$AndroidNDKRoot/toolchains/${TOOLCHAIN}/prebuilt/$PlatformOS-x86/bin/arm-linux-androideabi-g++
		TOOLSET=gcc-androidR7crystax5beta3
		;;
	8)
		TOOLCHAIN=${TOOLCHAIN:-arm-linux-androideabi-4.4.3}
		CXXPATH=$AndroidNDKRoot/toolchains/${TOOLCHAIN}/prebuilt/$PlatformOS-x86/bin/arm-linux-androideabi-g++
		TOOLSET=gcc-androidR8
		;;
	8b|8c|8d)
		TOOLCHAIN=${TOOLCHAIN:-arm-linux-androideabi-4.6}
		CXXPATH=$AndroidNDKRoot/toolchains/${TOOLCHAIN}/prebuilt/$PlatformOS-x86/bin/arm-linux-androideabi-g++
		TOOLSET=gcc-androidR8b
		;;
	8e|9|9b|9c|9d)
		TOOLCHAIN=${TOOLCHAIN:-arm-linux-androideabi-4.6}
		CXXPATH=$AndroidNDKRoot/toolchains/${TOOLCHAIN}/prebuilt/$PlatformOS-x86/bin/arm-linux-androideabi-g++
		TOOLSET=gcc-androidR8e
		;;
	"8e (64-bit)")
		TOOLCHAIN=${TOOLCHAIN:-arm-linux-androideabi-4.6}
		CXXPATH=$AndroidNDKRoot/toolchains/${TOOLCHAIN}/prebuilt/${PlatformOS}-x86_64/bin/arm-linux-androideabi-g++
		TOOLSET=gcc-androidR8e
		;;
	"9 (64-bit)"|"9b (64-bit)"|"9c (64-bit)"|"9d (64-bit)")
		TOOLCHAIN=${TOOLCHAIN:-arm-linux-androideabi-4.6}
		CXXPATH=$AndroidNDKRoot/toolchains/${TOOLCHAIN}/prebuilt/${PlatformOS}-x86_64/bin/arm-linux-androideabi-g++
		TOOLSET=gcc-androidR8e
		;;
	"10 (64-bit)"|"10b (64-bit)"|"10c (64-bit)"|"10d (64-bit)")
		TOOLCHAIN=${TOOLCHAIN:-arm-linux-androideabi-4.6}
		CXXPATH=$AndroidNDKRoot/toolchains/${TOOLCHAIN}/prebuilt/${PlatformOS}-x86_64/bin/arm-linux-androideabi-g++
		TOOLSET=gcc-androidR8e
		;;
	"10 (64-bit)"|"10b (64-bit)"|"10c (64-bit)"|"10d (64-bit)")
		TOOLCHAIN=${TOOLCHAIN:-arm-linux-androideabi-4.6}
		CXXPATH=$AndroidNDKRoot/toolchains/${TOOLCHAIN}/prebuilt/${PlatformOS}-x86_64/bin/arm-linux-androideabi-g++
		TOOLSET=gcc-androidR8e
		;;
	"16.0"|"16.1"|"17.1"|"17.2"|"18.0"|"18.1")
		TOOLCHAIN=${TOOLCHAIN:-llvm}
		CXXPATH=$AndroidNDKRoot/toolchains/${TOOLCHAIN}/prebuilt/${PlatformOS}-x86_64/bin/clang++
		TOOLSET=clang
		;;
	"19.0"|"19.1"|"19.2"|"20.0"|"20.1"|"21.0"|"21.1"|"21.2"|"21.3"|"21.4"|"22.1")
		TOOLCHAIN=${TOOLCHAIN:-llvm}
		CXXPATH=$AndroidNDKRoot/toolchains/${TOOLCHAIN}/prebuilt/${PlatformOS}-x86_64/bin/clang++
		TOOLSET=clang
		CONFIG_VARIANT=ndk19
		;;
	"23.0"|"23.1")
		TOOLCHAIN=${TOOLCHAIN:-llvm}
		CXXPATH=$AndroidNDKRoot/toolchains/${TOOLCHAIN}/prebuilt/${PlatformOS}-x86_64/bin/clang++
		TOOLSET=clang
		CONFIG_VARIANT=ndk23
		;;
	*)
		echo "Undefined or not supported Android NDK version: $NDK_RN"
		exit 1
esac

if [ -n "${AndroidSourcesDetected}" -a "${TOOLSET}" '!=' "clang" ]; then # Overwrite CXXPATH if we are building from Android sources
    CXXPATH="${ANDROID_TOOLCHAIN}/arm-linux-androideabi-g++"
fi

if [ -z "${ARCHLIST}" ]; then
  ARCHLIST=armeabi-v7a
  if [ "$TOOLSET" = "clang" ]; then

    case "$NDK_RN" in
      # NDK 17+: Support for ARMv5 (armeabi), MIPS, and MIPS64 has been removed.
      "17.1"|"17.2"|"18.0"|"18.1"|"19.0"|"19.1"|"19.2"|"20.0"|"20.1"|"21.0"|"21.1"|"21.2"|"21.3"|"21.4"|"22.1"|"23.0"|"23.1")
        ARCHLIST="arm64-v8a armeabi-v7a x86 x86_64"
        ;;
      *)
        ARCHLIST="arm64-v8a armeabi armeabi-v7a mips mips64 x86 x86_64"
    esac
  fi
fi

if [ "${ARCHLIST}" '!=' "armeabi" ] && [ "${TOOLSET}" '!=' "clang" ]; then
    echo "Old NDK versions only support ARM architecture"
    exit 1
fi

echo Building with TOOLSET=$TOOLSET CONFIG_VARIANT=${CONFIG_VARIANT} CXXPATH=$CXXPATH CFLAGS=$CFLAGS CXXFLAGS=$CXXFLAGS | tee $PROGDIR/build.log

# Check if the ndk is valid or not
if [ ! -f $CXXPATH ]
then
	echo "Cannot find C++ compiler at: $CXXPATH"
	exit 1
fi

#-----------------------------------------------------------------------------------------------------------------
# 
echo "# ---------------"
echo "# Build using NDK"
echo "# ---------------"

echo "NCPU : $NCPU"
if [ -z "$NCPU" ]; then
	NCPU=4
	if uname -s | grep -i "linux" > /dev/null ; then
		NCPU=`cat /proc/cpuinfo | grep -c -i processor`
	fi
fi
echo "NCPU : $NCPU"

for ARCH in $ARCHLIST; do

	echo "Building boost for android for $ARCH"
	(

		if [ -n "$WITH_ICONV" ] || echo $LIBRARIES | grep locale; then
			if [ -e libiconv-libicu-android ]; then
				echo "ICONV and ICU already downloaded"
			else
				echo "Downloading libiconv-libicu-android repo"
				git clone --depth=1 https://github.com/pelya/libiconv-libicu-android.git || exit 1
			fi

			if [ -e libiconv-libicu-android/$ARCH/libicuuc.a ]; then
				echo "ICONV and ICU already compiled"
				else
				echo "boost_locale selected - compiling ICONV and ICU"
				cd libiconv-libicu-android
				ARCHS=$ARCH PATH=$AndroidNDKRoot:$PATH ./build.sh || exit 1
				cd ..
			fi
		fi

		cd $VSOMEIP_DIR

		rmdir -p CMakeFiles/
		rm -rf CMakeCache.txt  
		
		#sleep 5
		
		echo "Adding pathname: `dirname $CXXPATH`"
		# `AndroidBinariesPath` could be used by user-config-*.jam
		export AndroidBinariesPath=`dirname $CXXPATH`
		export PATH=$AndroidBinariesPath:$PATH
		export AndroidNDKRoot=$AndroidNDKRoot
		export AndroidTargetVersion32=$ANDROID_TARGET_32
		export AndroidTargetVersion64=$ANDROID_TARGET_64
		export NO_BZIP2=1
		export PlatformOS=$PlatformOS
		

		cflags=""
		for flag in $CFLAGS; do cflags="$cflags cflags=$flag"; done

		cxxflags=""
		for flag in $CXXFLAGS; do cxxflags="$cxxflags cxxflags=$flag"; done

		LIBRARIES_BROKEN=""
		if [ "$TOOLSET" = "clang" ]; then
			JAMARCH="`echo ${ARCH} | tr -d '_-'`" # Remove all dashes, b2 does not like them
			TOOLSET_ARCH=${TOOLSET}-${JAMARCH}
			TARGET_OS=android
			if [ "$ARCH" = "armeabi" ]; then
				if [ -z "$LIBRARIES" ]; then
					echo "Disabling boost_math library on armeabi architecture, because of broken toolchain" | tee -a $PROGDIR/build.log
					LIBRARIES_BROKEN="--without-math"
				elif echo $LIBRARIES | grep math; then
					dump "ERROR: Cannot build boost_math library for armeabi architecture because of broken toolchain"
					dump "       However, it is explicitly included"
					exit 1
				fi
			fi
		else
			TOOLSET_ARCH=${TOOLSET}
			TARGET_OS=linux
		fi
		
		PLATFORM=$ARCH
		BUILDTYPE=Debug
		BUILD_HOST=$AndroidBinariesPath
		BUILD_DIR=./

		BOOST_PACK_PATH=~/Downloads/someip/19/$PLATFORM
		CURRENT_BOOST_VERSION=boost-1_74
		CURRENT_BOOST_VERSION_NO=107300

		BOOST_VER_INCLUDE_NAME=$(ls -lr $BOOST_PACK_PATH/include | grep -v grep | grep ^d | awk '{print $9}')

		
		echo "# -----------------------------------------------------------------------------------------------"
		echo "AndroidBinariesPath : $AndroidBinariesPath"
		echo "AndroidNDKRoot : $AndroidNDKRoot"
		echo "AndroidTargetVersion32 : $AndroidTargetVersion32"
		echo "AndroidTargetVersion64 : $AndroidTargetVersion64"
		echo "PlatformOS : $PlatformOS"
		echo "cflags : $cflags"
		echo "cxxflags : $cxxflags"
		echo "TOOLSET_ARCH : $TOOLSET_ARCH"
		echo "# -----------------------------------------------------------------------------------------------"

		echo "# -----------------------------------------------------------------------------------------------"
		echo "CMAKE_SOMEIP_PATH : $CMAKE_SOMEIP_PATH"
		echo "NDK_BUNDLE_PATH : $NDK_BUNDLE_PATH"
		echo "PLATFORM : $PLATFORM"
		echo "BUILD_HOST : $BUILD_HOST"
		echo "BOOST_PACK_PATH : $BOOST_PACK_PATH"
		echo "BOOST_VER_INCLUDE_NAME : $BOOST_VER_INCLUDE_NAME"
		echo "# -----------------------------------------------------------------------------------------------"

		
		#if [ -d ./set_boost_config.cmake ]; then
			rm -rf ./set_boost_config.cmake
			echo "# ------rm -rf ./set_boost_config.cmake---------" 
		#fi


		echo "set(BOOST_ROOT $BOOST_PACK_PATH)" >> ./set_boost_config.cmake 
		echo "set(BOOST_INCLUDEDIR $BOOST_PACK_PATH/include/$CURRENT_BOOST_VERSION)" >> ./set_boost_config.cmake 
		echo "set(BOOST_LIBRARYDIR $BOOST_PACK_PATH/lib)" >> ./set_boost_config.cmake  
		echo "set(Boost_FOUND 1)" >> ./set_boost_config.cmake 
		echo "set(Boost_INCLUDE_DIR $BOOST_PACK_PATH/include/$CURRENT_BOOST_VERSION)" >> ./set_boost_config.cmake 
		echo "set(Boost_LIBRARY_DIR $BOOST_PACK_PATH/lib)" >> ./set_boost_config.cmake  
		echo "set(Boost_VERSION $CURRENT_BOOST_VERSION_NO)" >> ./set_boost_config.cmake 
		

		${CMAKE_SOMEIP_PATH}/cmake \
			-DCMAKE_BUILD_TYPE=$BUILD_DIR/$TOOLSET_ARCH \
        		-DCMAKE_INSTALL_PREFIX=$BUILD_DIR/$TOOLSET_ARCH \
			-DCMAKE_TOOLCHAIN_FILE=${AndroidNDKRoot}/build/cmake/android.toolchain.cmake \
			-DANDROID_ABI=${PLATFORM} \
			-DANDROID_NDK=${AndroidNDKRoot} \
			-DANDROID_STL=c++_shared \
			-DANDROID_TOOLCHAIN=$TOOLSET_ARCH \
			-DCMAKE_C_COMPILER=${BUILD_HOST}/aarch64-linux-android21-clang \
			-DCMAKE_CXX_COMPILER=${BUILD_HOST}/aarch64-linux-android21-clang++ \
			-DBoost_FOUND=1 \
			-DCMAKE_BUILD_TYPE=${BUILDTYPE} \
			-DENABLE_COMPAT=1 \
			-DVSOMEIP_INSTALL_ROUTINGMANAGERD=ON \
			-DENABLE_MULTIPLE_ROUTING_MANAGERS=1 \
			
		make VERBOSE=1
		make install

		# PIPESTATUS variable is defined only in Bash, and we are using /bin/sh, which is not Bash on newer Debian/Ubuntu
	)


done # for ARCH in $ARCHLIST

