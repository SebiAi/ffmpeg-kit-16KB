FROM ubuntu:22.04

# Dependencies
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
# According to readme of android README
    autoconf \
    automake \
    libtool \
    pkg-config \
    curl \
    git \
    doxygen \
    nasm \
    cmake \
    gcc \
    gperf \
    texinfo \
    yasm \
    bison \
    autogen \
    wget \
    autopoint \
    meson \
    ninja-build \
    ragel \
    groff \
    gtk-doc-tools \
    libtasn1-dev \
# srt lib
    tclsh \
# gnutls (gnulib-tool, asn1Parser)
    gnulib \
    libtasn1-bin \
# Android SDK
    openjdk-17-jdk-headless

# Tools for the Dockerfile itself
RUN apt-get install -y \
    unzip

ENV ANDROID_SDK_ROOT=/opt/android-sdk
# Download and extract
RUN curl -s https://developer.android.com/studio | \
    grep -o "https:\/\/dl.google.com\/android\/repository\/commandlinetools\-linux\-[0-9]*_latest\.zip" | \
    head -n 1 | \
    xargs curl -o /tmp/cmdline-tools.zip -L
RUN unzip -q /tmp/cmdline-tools.zip -d /tmp && \
    rm /tmp/cmdline-tools.zip && \
    mkdir -p "${ANDROID_SDK_ROOT}/cmdline-tools/latest" && \
    mv /tmp/cmdline-tools/* "${ANDROID_SDK_ROOT}/cmdline-tools/latest/" && \
    rmdir /tmp/cmdline-tools
ENV PATH="${PATH}:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin"

RUN yes | sdkmanager --licenses
# Install SDK components
RUN sdkmanager "build-tools;33.0.1" "platforms;android-35" "platform-tools" "cmake;3.22.1"
# Download canary release of LTS NDK r23 that has a 16KB aligned "libc++_shared.so" library

# Per documentation when using ndkr23 and up with the `-Wl,-z,max-page-size=16384` flags
# we get 16KB alignment (https://developer.android.com/guide/practices/page-sizes#compile-r26-lower).
# But the regular r23 ndk does not have a 16KB aligned libc++_shared.so. => Use canary release.
# Alignment can be checked with this: https://developer.android.com/guide/practices/page-sizes#elf-alignment
ENV ANDROID_NDK_ROOT="/opt/android-ndk"
RUN curl -s https://ci.android.com/builds/submitted/12186248/linux/latest/android-ndk-12186248-linux-x86_64.zip | \
    grep -o "https:\/\/storage.googleapis.com\/android-build\/builds\/aosp-ndk-release-r23-linux-linux\/12186248\/[a-z0-9]\+\/android-ndk-12186248-linux-x86_64.zip[^\"]\+" | \
    head -n 1 | \
    sed 's/\\u0026/\&/g' | \
    xargs curl -o /tmp/ndk.zip -L
RUN unzip -q /tmp/ndk.zip -d /tmp && \
    rm /tmp/ndk.zip && \
    mkdir -p "${ANDROID_NDK_ROOT}" && \
    mv /tmp/android-ndk-r23d-canary/* "${ANDROID_NDK_ROOT}/"

# Clean
RUN apt-get remove --autoremove -y unzip
RUN apt-get clean && rm -rf /var/lib/apt/lists/*