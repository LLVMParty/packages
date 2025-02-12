FROM ghcr.io/llvmparty/packages/ubuntu:22.04-llvm19.1.0 AS build
WORKDIR /tmp
COPY \
    bitwuzla.cmake \
    bitwuzlaConfig.cmake.in \
    CMakeLists.txt  \
    gmp.cmake \
    GMPConfig.cmake.in \
    hash.py \
    llvm.cmake \
    superbuild.cmake \
    xed.cmake \
    XEDConfig.cmake.in \
    ubuntu-dependencies.sh \
    ./

# I forgot to install some dependencies in the base image
RUN \
wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | sudo tee /usr/share/keyrings/kitware-archive-keyring.gpg >/dev/null && \
apt update && \
rm /usr/share/keyrings/kitware-archive-keyring.gpg && \
apt install --no-install-recommends -y \
    kitware-archive-keyring \
    python3-pip \
    && \
rm -rf /var/lib/apt/lists/* && \
python -m pip --no-cache-dir install meson

# Install remill cross-compilation dependencies
RUN \
./ubuntu-dependencies.sh && \
rm -rf /var/lib/apt/lists/*

# Build dependencies
RUN \
mkdir /dependencies && \
python hash.py --debug --simple > /dependencies/hash.txt && \
cmake -B build "-DCMAKE_INSTALL_PREFIX=/dependencies" -DUSE_EXTERNAL_LLVM=ON && \
cmake --build build && \
rm -rf build

# Actual final image
FROM ghcr.io/llvmparty/packages/ubuntu:22.04-llvm19.1.0 AS dependencies
LABEL org.opencontainers.image.source=https://github.com/LLVMParty/packages

# I forgot to install some dependencies in the base image
RUN \
wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | sudo tee /usr/share/keyrings/kitware-archive-keyring.gpg >/dev/null && \
apt update && \
rm /usr/share/keyrings/kitware-archive-keyring.gpg && \
apt install --no-install-recommends -y \
    kitware-archive-keyring \
    python3-pip \
    && \
rm -rf /var/lib/apt/lists/* && \
python -m pip --no-cache-dir install meson

COPY --from=build /dependencies /dependencies
ENV CMAKE_PREFIX_PATH="/dependencies" \
    LD_LIBRARY_PATH="/dependencies/lib" \
    PATH="/dependencies/bin:$PATH"
