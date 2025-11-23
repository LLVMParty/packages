ARG LLVM_VERSION=22.04-llvm17.0.6

FROM ghcr.io/llvmparty/packages/ubuntu:${LLVM_VERSION} AS build
WORKDIR /tmp

COPY \
    superbuild.cmake \
    xed.cmake \
    XEDConfig.cmake.in \
    ./

# Create superbuild project
COPY <<EOF CMakeLists.txt
cmake_minimum_required(VERSION 3.22)

project(cxx-common)

find_package(LLVM CONFIG REQUIRED)

include(superbuild.cmake)

simple_git(https://github.com/gflags/gflags 52e94563eba1968783864942fedf6e87e3c611f4
)
simple_git(https://github.com/google/glog v0.7.1
    "-DGFLAGS_USE_TARGET_NAMESPACE:STRING=ON"
    "-DBUILD_TESTING:STRING=OFF"
)
simple_git(https://github.com/google/googletest v1.17.0
    "-Dgtest_force_shared_crt:STRING=ON"
    "-DGFLAGS_USE_TARGET_NAMESPACE:STRING=ON"
)

include(xed.cmake)
EOF

# Build dependencies
RUN \
mkdir /dependencies && \
cmake -B build "-DCMAKE_INSTALL_PREFIX=/dependencies" -DUSE_EXTERNAL_LLVM=ON && \
cmake --build build && \
rm -rf build

# Actual final image
FROM ghcr.io/llvmparty/packages/ubuntu:${LLVM_VERSION} AS cxx-common

# Install remill cross-compilation dependencies
COPY ubuntu-dependencies.sh ./
RUN \
./ubuntu-dependencies.sh && \
rm -rf /var/lib/apt/lists/*

COPY --from=build /dependencies /dependencies
ENV CMAKE_PREFIX_PATH="/dependencies" \
    LD_LIBRARY_PATH="/dependencies/lib" \
    PATH="/dependencies/bin:$PATH"
