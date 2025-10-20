set -xe

#############################################################
### CONFIG
#############################################################
export TOOLCHAIN_ROOT=${HOME}/Android/Sdk/ndk/28.2.13676358
export HOST_ARCH=linux-x86_64
export CMAKE_POLICY_VERSION_MINIMUM=3.5

#############################################################
### DERIVED CONFIG
#############################################################
export SYS_ROOT=${TOOLCHAIN_ROOT}/toolchains/llvm/prebuilt/${HOST_ARCH}/sysroot
export TOOLCHAIN_BIN=${TOOLCHAIN_ROOT}/toolchains/llvm/prebuilt/${HOST_ARCH}/bin
export API_LEVEL=29
export CC="${TOOLCHAIN_BIN}/aarch64-linux-android${API_LEVEL}-clang"
export CXX="${TOOLCHAIN_BIN}/aarch64-linux-android${API_LEVEL}-clang++"
export LD=${TOOLCHAIN_BIN}/aarch64-linux-android-ld
export AR=${TOOLCHAIN_BIN}/aarch64-linux-android-ar
export RANLIB=${TOOLCHAIN_BIN}/aarch64-linux-android-ranlib
export STRIP=${TOOLCHAIN_BIN}/aarch64-linux-android-strip
export BUILD_ROOT=$(dirname $(readlink -f "$0"))
export PATH=${TOOLCHAIN_BIN}:${PATH}
export PREFIX=${BUILD_ROOT}/toolchain/arm64-v8a
export PKG_CONFIG_PATH=${PREFIX}/lib/pkgconfig
export NCORES=$(getconf _NPROCESSORS_ONLN)

mkdir -p ${PREFIX}
mkdir -p ${PREFIX}/lib
mkdir -p ${PREFIX}/include

ln -s ${SYS_ROOT}/usr/lib/aarch64-linux-android/libc++_shared.so ${PREFIX}/lib/ || true

#############################################################
### LIBUSB
#############################################################
cd ${BUILD_ROOT}/libusb/android/jni
git clean -xdf

export NDK=${TOOLCHAIN_ROOT}
export APP_MK=${BUILD_ROOT}/libusb/android/jni/Application.mk
export LIBUSB_MK=${BUILD_ROOT}/libusb/android/jni/libusb.mk

${NDK}/ndk-build clean APP_ABI=arm64-v8a \
  APP_PLATFORM=android-${API_LEVEL} \
  NDK_APPLICATION_MK=${APP_MK} \
  APP_BUILD_SCRIPT=${LIBUSB_MK} \
  USE_PC_NAME=1
${NDK}/ndk-build -B -r -R APP_ABI=arm64-v8a \
  APP_PLATFORM=android-${API_LEVEL} \
  NDK_APPLICATION_MK=${APP_MK} \
  APP_BUILD_SCRIPT=${LIBUSB_MK} \
  USE_PC_NAME=1

cp ${BUILD_ROOT}/libusb/android/libs/arm64-v8a/libusb-1.0.so ${PREFIX}/lib
cp ${BUILD_ROOT}/libusb/libusb/libusb.h ${PREFIX}/include

#############################################################
### HACK RF
#############################################################
cd ${BUILD_ROOT}/hackrf/host/
git clean -xdf

mkdir build
cd build

cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DCMAKE_TOOLCHAIN_FILE=${TOOLCHAIN_ROOT}/build/cmake/android.toolchain.cmake \
  -DANDROID_ABI=arm64-v8a \
  -DANDROID_ARM_NEON=ON \
  -DANDROID_NATIVE_API_LEVEL=${API_LEVEL} \
  -DANDROID_STL=c++_shared \
  -DENABLE_STATIC_LIB=OFF \
  -DCMAKE_FIND_ROOT_PATH=${PREFIX} \
  ../

make -j ${NCORES}
make install

#############################################################
### RTL SDR
#############################################################
cd ${BUILD_ROOT}/rtl-sdr
git clean -xdf

mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DCMAKE_TOOLCHAIN_FILE=${TOOLCHAIN_ROOT}/build/cmake/android.toolchain.cmake \
  -DANDROID_ABI=arm64-v8a \
  -DANDROID_ARM_NEON=ON \
  -DANDROID_NATIVE_API_LEVEL=${API_LEVEL} \
  -DANDROID_STL=c++_shared \
  -DENABLE_STATIC_LIBS=False \
  -DCMAKE_FIND_ROOT_PATH=${PREFIX} \
  ../

make -j ${NCORES}
make install

#############################################################
### SOAPY
#############################################################
cd ${BUILD_ROOT}/SoapySDR
git clean -xdf

mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DCMAKE_TOOLCHAIN_FILE=${TOOLCHAIN_ROOT}/build/cmake/android.toolchain.cmake \
  -DANDROID_ABI=arm64-v8a \
  -DANDROID_ARM_NEON=ON \
  -DANDROID_NATIVE_API_LEVEL=${API_LEVEL} \
  -DANDROID_STL=c++_shared \
  -DENABLE_DOCS=OFF \
  -DENABLE_APPS=OFF \
  -DENABLE_PYTHON=OFF \
  -DENABLE_PYTHON3=OFF \
  -DENABLE_TESTS=OFF \
  -DCMAKE_FIND_ROOT_PATH=${PREFIX} \
  ../

make -j ${NCORES}
make install

#############################################################
### SOAPY RTL-SDR
#############################################################
cd ${BUILD_ROOT}/SoapyRTLSDR
git clean -xdf

mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DCMAKE_TOOLCHAIN_FILE=${TOOLCHAIN_ROOT}/build/cmake/android.toolchain.cmake \
  -DANDROID_ABI=arm64-v8a \
  -DANDROID_ARM_NEON=ON \
  -DANDROID_NATIVE_API_LEVEL=${API_LEVEL} \
  -DANDROID_STL=c++_shared \
  -DCMAKE_FIND_ROOT_PATH=${PREFIX} \
  ../

make -j ${NCORES}
make install

ln -s ${PREFIX}/lib/SoapySDR/modules0.8-3/librtlsdrSupport.so ${PREFIX}/lib/ || true

