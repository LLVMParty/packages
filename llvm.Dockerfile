# Reference: https://www.docker.com/blog/faster-multi-platform-builds-dockerfile-cross-compilation-guide/
ARG UBUNTU_VERSION=22.04
ARG LLVM_URL
ARG LLVM_SHA256

# Build stage (no need to optimize for size)
FROM ubuntu:${UBUNTU_VERSION} AS build

# Inherit arguments
# https://docs.docker.com/build/building/variables/#scoping
ARG LLVM_URL
ARG LLVM_SHA256

WORKDIR /tmp

# Create superbuild project
COPY superbuild.cmake llvm.cmake ./
COPY <<EOF CMakeLists.txt
cmake_minimum_required(VERSION 3.24)
project(llvm)
include(superbuild.cmake)
include(llvm.cmake)
EOF

# CMake APT repository
RUN \
apt update && \
apt install --no-install-recommends -y \
    ca-certificates \
    gpg \
    wget \
    sudo \
    && \
wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | sudo tee /usr/share/keyrings/kitware-archive-keyring.gpg >/dev/null && \
echo 'deb [signed-by=/usr/share/keyrings/kitware-archive-keyring.gpg] https://apt.kitware.com/ubuntu/ jammy main' | sudo tee /etc/apt/sources.list.d/kitware.list >/dev/null

# Install compilers to bootstrap LLVM
RUN \
apt update && \
apt install --no-install-recommends -y \
    cmake \
    python-is-python3 \
    git \
    make \
    ninja-build \
    libz-dev \
    libzstd-dev \
    libxml2-dev \
    flex \
    bison \
    build-essential

# Build LLVM
RUN \
mkdir /llvm && \
cmake -B build "-DCMAKE_INSTALL_PREFIX=/llvm" "-DBUILD_SHARED_LIBS=ON" "-DLLVM_URL=${LLVM_URL}" "-DLLVM_SHA256=${LLVM_SHA256}" && \
cmake --build build && \
rm -rf build

# Actual final image
FROM ubuntu:${UBUNTU_VERSION} AS llvm
LABEL org.opencontainers.image.source=https://github.com/LLVMParty/packages

# Copy LLVM installation
COPY --from=build /llvm /usr/local/

# Install common development packages
RUN \
apt update && \
apt install --no-install-recommends -y \
    ca-certificates \
    gpg \
    wget \
    sudo \
    && \
wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | sudo tee /usr/share/keyrings/kitware-archive-keyring.gpg >/dev/null && \
echo 'deb [signed-by=/usr/share/keyrings/kitware-archive-keyring.gpg] https://apt.kitware.com/ubuntu/ jammy main' | sudo tee /etc/apt/sources.list.d/kitware.list >/dev/null && \
apt update && \
rm /usr/share/keyrings/kitware-archive-keyring.gpg && \
apt install --no-install-recommends -y \
    kitware-archive-keyring \
    cmake \
    curl \
    python-is-python3 \
    python3-pip \
    git \
    git-lfs \
    make \
    ninja-build \
    libstdc++-12-dev \
    ncurses-dev \
    libz-dev \
    libzstd-dev \
    libxml2-dev \
    binutils \
    flex \
    bison \
    pkg-config \
    && \
apt autoremove -y && \
rm -rf /var/lib/apt/lists/* && \
python -m pip --no-cache-dir install meson
