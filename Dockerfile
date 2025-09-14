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
    grep -o "https:\/\/dl.google.com\/android\/repository\/commandlinetools\-linux\-[0-9]*_latest\.zip" | head -n 1 | \
    xargs curl -o /tmp/cmdline-tools.zip -L
RUN unzip -q /tmp/cmdline-tools.zip -d /tmp && \
    rm /tmp/cmdline-tools.zip && \
    mkdir -p "${ANDROID_SDK_ROOT}/cmdline-tools/latest" && \
    mv /tmp/cmdline-tools/* "${ANDROID_SDK_ROOT}/cmdline-tools/latest/"
ENV PATH="${PATH}:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin"

RUN yes | sdkmanager --licenses
# Install SDK components
# Per documentation when using ndkr23 and up with the `-Wl,-z,max-page-size=16384` flags
# we get 16KB alignment (https://developer.android.com/guide/practices/page-sizes#compile-r26-lower).
# Alignment can be checked with this: https://developer.android.com/guide/practices/page-sizes#elf-alignment
RUN sdkmanager "build-tools;33.0.1" "platforms;android-35" "platform-tools" "cmake;3.22.1" "ndk;23.2.8568313"
ENV ANDROID_NDK_ROOT="${ANDROID_SDK_ROOT}/ndk/23.2.8568313"

# Clean
RUN apt-get remove --autoremove -y unzip
RUN apt-get clean && rm -rf /var/lib/apt/lists/*