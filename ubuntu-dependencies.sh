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
apt update && apt install --no-install-recommends -y $cross_packages "$@"
