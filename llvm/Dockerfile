# Reference: https://www.docker.com/blog/faster-multi-platform-builds-dockerfile-cross-compilation-guide/

# Build stage (no need to optimize for size)
FROM ubuntu:22.04 AS build
WORKDIR /cxx-common
COPY *.sh CMakeLists.txt ./
RUN ./ubuntu-dependencies.sh
RUN \
    cmake -B build \
        "-DCMAKE_C_COMPILER=$(which gcc-12)" \
        "-DCMAKE_CXX_COMPILER=$(which g++-12)" \
        "-DCMAKE_INSTALL_PREFIX=$(pwd)/install" \
        && \
    cmake --build build && \
    rm -rf build

# Actual final image
FROM ubuntu:22.04 AS cxx-common
WORKDIR /cxx-common/install
COPY --from=build /cxx-common/install .
ENV CMAKE_PREFIX_PATH=/cxx-common/install
ENV LD_LIBRARY_PATH=/cxx-common/install/lib
RUN apt-get update && apt-get install -y \
    libstdc++-12-dev \
    libxml2-dev \
    ncurses-dev \
    libz-dev \
    libsqlite3-dev \
    sqlite3 \
    && apt remove -y gcc g++ gcc-12 g++-12 \
    && apt autoremove -y \
    && rm -rf /var/lib/apt/lists/*
LABEL org.opencontainers.image.source=https://github.com/LLVMParty/packages