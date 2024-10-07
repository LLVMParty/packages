FROM ghcr.io/llvmparty/packages/ubuntu:22.04-llvm19.1.0 AS build
WORKDIR /tmp
COPY \
    CMakeLists.txt  \
    hash.py \
    llvm.cmake \
    superbuild.cmake \
    xed.cmake \
    XEDConfig.cmake.in \
    ubuntu-dependencies.sh \
    ./

# Install compilation dependencies
RUN ./ubuntu-dependencies.sh && rm -rf /var/lib/apt/lists/*

# Build dependencies
RUN <<EOF
mkdir /dependencies
python hash.py --debug --simple > /dependencies/hash.txt
cmake -B build "-DCMAKE_INSTALL_PREFIX=/dependencies" -DUSE_SYSTEM_LLVM=ON
cmake --build build
rm -rf build
EOF

# Actual final image
FROM ghcr.io/llvmparty/packages/ubuntu:22.04-llvm19.1.0 AS dependencies
LABEL org.opencontainers.image.source=https://github.com/LLVMParty/packages

COPY --from=build /dependencies /dependencies
ENV CMAKE_PREFIX_PATH=/dependencies \
    LD_LIBRARY_PATH="/dependencies/lib" \
    PATH="/dependencies/bin:$PATH"
