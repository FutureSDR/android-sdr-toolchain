ARG CMDLINE_TOOLS_VERSION=11076708_latest
ARG NDK_VERSION=28.2.13676358
ARG CMAKE_VERSION=3.22.1
ARG BUILD_TOOLS=34.0.0
ARG PLATFORM=29
ARG USERNAME=builder
ARG UID=1000
ARG GID=1000

# FROM debian:bookworm AS build
# FROM public.ecr.aws/debian/debian:bookworm AS build
FROM mirror.gcr.io/library/debian:bookworm AS build

ARG CMDLINE_TOOLS_VERSION
ARG NDK_VERSION
ARG CMAKE_VERSION
ARG BUILD_TOOLS
ARG PLATFORM
ARG USERNAME
ARG UID
ARG GID

RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates curl unzip git bash openssh-client \
      libc6 libstdc++6 libgcc1 file make cmake ninja-build \
      python3 \
      openjdk-17-jdk-headless \
 && rm -rf /var/lib/apt/lists/*

RUN groupadd -g ${GID} ${USERNAME} && useradd -m -u ${UID} -g ${GID} -s /bin/bash ${USERNAME}
USER ${USERNAME}

WORKDIR /home/${USERNAME}
COPY --chown=$USERNAME:$USERNAME . .

ENV HOME=/home/${USERNAME}
ENV DEBIAN_FRONTEND=noninteractive
ENV ANDROID_HOME=${HOME}/Android/Sdk
ENV ANDROID_SDK_ROOT=${ANDROID_HOME}
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH=$JAVA_HOME/bin:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools:$ANDROID_SDK_ROOT/emulator:$PATH

RUN mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools ${ANDROID_SDK_ROOT}/licenses

RUN curl -fsSL \
      https://dl.google.com/android/repository/commandlinetools-linux-${CMDLINE_TOOLS_VERSION}.zip \
      -o /tmp/cmdline-tools.zip \
 && unzip -q /tmp/cmdline-tools.zip -d /tmp/cmdline-tools \
 && mv /tmp/cmdline-tools/cmdline-tools ${ANDROID_SDK_ROOT}/cmdline-tools/latest \
 && rm -rf /tmp/cmdline-tools* \
 && mkdir -p ${ANDROID_SDK_ROOT}/platforms ${ANDROID_SDK_ROOT}/build-tools ${ANDROID_SDK_ROOT}/ndk \
 && yes | sdkmanager --licenses >/dev/null || true

RUN set -eux; \
    pkgs="\
      platform-tools \
      platforms;android-${PLATFORM} \
      build-tools;${BUILD_TOOLS} \
      ndk;${NDK_VERSION} \
      cmake;${CMAKE_VERSION} \
    "; \
    yes | sdkmanager ${pkgs}; \
    yes | sdkmanager --licenses

RUN echo "SDK installed at: ${ANDROID_SDK_ROOT}" \
 && sdkmanager --list | head -n 200 || true

RUN ./build_aarch64.sh

# artifacts
FROM scratch AS artifacts

ARG USERNAME
ARG NDK_VERSION

COPY --from=build /home/${USERNAME}/toolchain/arm64-v8a/lib/libusb1.0.so /out/arm64-v8a/lib/
COPY --from=build /home/${USERNAME}/toolchain/arm64-v8a/lib/libusb1.0.so /out/arm64-v8a/lib/
COPY --from=build /home/${USERNAME}/toolchain/arm64-v8a/lib/librtlsdr.so /out/arm64-v8a/lib/
COPY --from=build /home/${USERNAME}/toolchain/arm64-v8a/lib/libSoapySDR.so /out/arm64-v8a/lib/
COPY --from=build /home/${USERNAME}/toolchain/arm64-v8a/lib/SoapySDR/modules0.8-3/librtlsdrSupport.so /out/arm64-v8a/lib/
COPY --from=build /home/${USERNAME}/toolchain/arm64-v8a/include/ /out/arm64-v8a/include/
COPY --from=build /home/${USERNAME}/Android/Sdk/ndk/${NDK_VERSION}/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/lib/aarch64-linux-android/libc++_shared.so /out/arm64-v8a/lib/
COPY --from=build /home/${USERNAME}/toolchain/jni/ /out/jni/

