# Reference: https://www.docker.com/blog/faster-multi-platform-builds-dockerfile-cross-compilation-guide/

# Build stage (no need to optimize for size)
FROM ubuntu:22.04 AS build
WORKDIR /tmp

# Create superbuild project
COPY superbuild.cmake llvm.cmake ./
COPY <<EOF CMakeLists.txt
cmake_minimum_required(VERSION 3.22)
project(llvm)
include(superbuild.cmake)
include(llvm.cmake)
EOF

# CMake APT repository
RUN <<EOF
apt update
apt install --no-install-recommends -y \
    ca-certificates \
    gpg \
    wget \
    sudo
wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | sudo tee /usr/share/keyrings/kitware-archive-keyring.gpg >/dev/null
echo 'deb [signed-by=/usr/share/keyrings/kitware-archive-keyring.gpg] https://apt.kitware.com/ubuntu/ jammy main' | sudo tee /etc/apt/sources.list.d/kitware.list >/dev/null
EOF

# Install compilers to bootstrap LLVM
RUN <<EOF
apt update
apt install --no-install-recommends -y \
    cmake \
    python-is-python3 \
    git \
    make \
    ninja-build \
    libz-dev \
    libzstd-dev \
    libxml2-dev \
    build-essential
EOF

# Build LLVM
RUN <<EOF
mkdir /llvm
cmake -B build "-DCMAKE_INSTALL_PREFIX=/llvm"
cmake --build build
rm -rf build
EOF

# Actual final image
FROM ubuntu:22.04 AS llvm
LABEL org.opencontainers.image.source=https://github.com/LLVMParty/packages

# Copy LLVM installation
COPY --from=build /llvm /usr/local/

# Install common development packages
RUN <<EOF
apt update
apt install --no-install-recommends -y \
    ca-certificates \
    gpg \
    wget \
    sudo
wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | sudo tee /usr/share/keyrings/kitware-archive-keyring.gpg >/dev/null
echo 'deb [signed-by=/usr/share/keyrings/kitware-archive-keyring.gpg] https://apt.kitware.com/ubuntu/ jammy main' | sudo tee /etc/apt/sources.list.d/kitware.list >/dev/null
apt update
apt install --no-install-recommends -y \
    cmake \
    curl \
    python-is-python3 \
    git \
    make \
    ninja-build \
    libstdc++-12-dev \
    ncurses-dev \
    libz-dev \
    libzstd-dev \
    libxml2-dev \
    binutils
apt autoremove -y
rm -rf /var/lib/apt/lists/*
EOF
