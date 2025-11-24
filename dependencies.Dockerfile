ARG LLVM_VERSION=22.04-llvm19.1.7

FROM ghcr.io/llvmparty/packages/ubuntu:${LLVM_VERSION} AS build
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

# Install remill cross-compilation dependencies
RUN \
./ubuntu-dependencies.sh && \
rm -rf /var/lib/apt/lists/*

# Build dependencies
RUN \
mkdir /dependencies && \
python hash.py --debug --simple > /dependencies/hash.txt && \
cmake -B build "-DCMAKE_INSTALL_PREFIX=/dependencies" -DCMAKE_BUILD_TYPE=RelWithDebInfo -DUSE_EXTERNAL_LLVM=ON && \
cmake --build build && \
rm -rf build

# Actual final image
FROM ghcr.io/llvmparty/packages/ubuntu:${LLVM_VERSION} AS dependencies
LABEL org.opencontainers.image.source=https://github.com/LLVMParty/packages

COPY --from=build /dependencies /dependencies
ENV CMAKE_PREFIX_PATH="/dependencies" \
    LD_LIBRARY_PATH="/dependencies/lib" \
    PATH="/dependencies/bin:$PATH"
