#!/bin/bash

# Determine the right libstdc++ cross-compilation package
# Reference: https://packages.ubuntu.com/jammy/devel/
arch=$(uname -m)
if [ "$arch" == "aarch64" ]; then
    cross_packages="libstdc++-12-dev-armhf-cross"
elif [ "$arch" == "x86_64" ]; then
    cross_packages="libstdc++-9-dev-i386-cross"
else
    echo "Unsupported architecture: $arch"
    exit 1
fi

# Install the dependencies
./kitware-archive.sh
apt-get update && apt-get install -y \
    git \
    cmake \
    ninja-build \
    flex \
    bison \
    g++-12 \
    gcc-12 \
    python3 \
    libxml2-dev \
    ncurses-dev \
    libz-dev \
    libsqlite3-dev \
    sqlite3 \
    $cross_packages \
    && rm -rf /var/lib/apt/lists/*
