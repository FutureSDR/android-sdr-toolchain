# Android SDR Toolchain

This project builds SDR drivers as shared libraries to be used in Android applications.
The drivers integrate with Android and do *not* require rooting the device.

The drivers will be available in the `toolchain/jni` folder which can be symlinked in code structure of the Android app, typically `app/src/main/jni`.

## Usage

- Clone this repository with `git clone --recursive https://github.com/FutureSDR/android-sdr-toolchain.git`.
- Download and install [Android Studio](https://developer.android.com/studio).
- Select a NDK version and Android API for your application.
- Use SDK Manager (Tools -> SDK Manager) to download the Android Platform SDK in the corresponding version and the NDK and build tools.
- Adapt the paths at the top of the build script (at the moment there is only one for aarch64).
- Run the build script: `./build_aarch64.sh`.

## Docker Build

Run `./docker_build.sh` to create artifacts (requires BuildKit backend).
The output will be put into the `out` directory, which can be used similar to the `toolchain` directory for non-Docker builds.
