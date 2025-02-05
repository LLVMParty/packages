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

# Install compilation dependencies (Kitware GPG key expires frequently)
RUN \
wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | sudo tee /usr/share/keyrings/kitware-archive-keyring.gpg >/dev/null && \
echo 'deb [signed-by=/usr/share/keyrings/kitware-archive-keyring.gpg] https://apt.kitware.com/ubuntu/ jammy main' | sudo tee /etc/apt/sources.list.d/kitware.list >/dev/null && \
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

COPY --from=build /dependencies /dependencies
ENV CMAKE_PREFIX_PATH="/dependencies" \
    LD_LIBRARY_PATH="/dependencies/lib" \
    PATH="/dependencies/bin:$PATH"
