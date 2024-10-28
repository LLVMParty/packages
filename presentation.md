---
marp: true
class: invert
---

<style scoped>
section {
    text-align: center;
}
</style>

# C++ dependencies with CMake superbuild and Docker

<br><br><br><br><br><br><br>

_Duncan Ogilvie_

---

# Challenges

Sharing dependencies for C++ projects comes with a lot of challenges:

- Compilation time
  - LLVM can take an hour to build on a powerful machine
  - We observed more than 4 hours on GitHub Actions
- Disk usage
  - More than 15 GiB required while building
  - Distributions are around 1 GiB compressed
- Reproducible environment
  - Local builds on developer machines
  - Continuous integration (GitHub Actions)

---

# CMake: packaging basics

The library is built in 3 stages:

1. Configuration: `cmake -G Ninja -B build -DMYPROJECT_OPTION=ON`
2. Build: `cmake --build build`
3. Install: `cmake --install build --prefix build/install`

---

# CMake: example prefix (capstone)

```
┌── bin
│   └── cstool
├── include
│   └── capstone
│       ├── capstone.h
│       └── *.h
└── lib
    ├── cmake
    │   └── capstone
    │       ├── capstone-config-version.cmake
    │       ├── capstone-config.cmake
    │       ├── capstone-targets-noconfig.cmake
    │       └── capstone-targets.cmake
    ├── libcapstone.a
    └── pkgconfig
        └── capstone.pc
```

---

# CMake: consuming the library

In your project's `CMakeLists.txt`:

```cmake
cmake_minimum_required(VERSION 3.24)
project(MyProject)

find_package(capstone REQUIRED)

add_executable(myproject src/main.cpp)
target_link_libraries(myproject PRIVATE capstone::capstone)
```

<br>

Configuration command line:

```sh
cmake -B build -DCMAKE_PREFIX_PATH=/capstone/build/install
```

---

# CMake: superbuild overview

```
┌── dependencies        <== Superbuild project
│   ├── CMakeLists.txt
│   ├── build           <== Superbuild build directory
│   └── install         <== Superbuild install prefix
│       └── bin/lib/...
├── src
│   └── main.cpp
└── CMakeLists.txt      <== Main project
```

Compilation:

```sh
# Build the dependencies
cmake -B dependencies/build -S dependencies
cmake --build dependencies/build

# Build the main project
cmake -B build -DCMAKE_PREFIX_PATH=dependencies/install
cmake --build build
```

---

# CMake: superbuild example

```cmake
option(LLVM_ENABLE_ASSERTIONS "Enable assertions in LLVM" ON)

ExternalProject_Add(llvm
    URL
        "https://github.com/llvm/llvm-project/releases/download/llvmorg-19.1.0/llvm-project-19.1.0.src.tar.xz"
    URL_HASH
        "SHA256=5042522b49945bc560ff9206f25fb87980a9b89b914193ca00d961511ff0673c"
    CMAKE_CACHE_ARGS
        ${CMAKE_ARGS}
        "-DLLVM_ENABLE_PROJECTS:STRING=lld;clang;clang-tools-extra"
        "-DLLVM_ENABLE_ASSERTIONS:STRING=${LLVM_ENABLE_ASSERTIONS}"
        "-DLLVM_ENABLE_DUMP:STRING=${LLVM_ENABLE_ASSERTIONS}"
        "-DLLVM_ENABLE_RTTI:STRING=ON"
        "-DLLVM_ENABLE_LIBEDIT:STRING=OFF"
        "-DLLVM_PARALLEL_LINK_JOBS:STRING=1"
        "-DLLVM_ENABLE_DIA_SDK:STRING=OFF"
    CMAKE_GENERATOR
        "Ninja"
    SOURCE_SUBDIR
        "llvm"
)
```

---

# CMake: integrating other build systems

The [`ExternalProject_Add`](https://cmake.org/cmake/help/latest/module/ExternalProject.html) command allows you to specify custom build/patch/install commands:

```cmake
ExternalProject_Add(xed
    GIT_REPOSITORY
        "https://github.com/intelxed/xed"
    GIT_TAG
        "v2022.10.11"
    GIT_PROGRESS
        ON
    GIT_SHALLOW
        ON
    CMAKE_CACHE_ARGS
        ${CMAKE_ARGS}
    CONFIGURE_COMMAND
        "${CMAKE_COMMAND}" -E true
    BUILD_COMMAND
        "${Python3_EXECUTABLE}" "<SOURCE_DIR>/mfile.py" ${MFILE_ARGS}
    INSTALL_COMMAND
        "${CMAKE_COMMAND}" -E copy_directory <BINARY_DIR>/install "${CMAKE_INSTALL_PREFIX}"
    PREFIX
        xed-prefix
)

# TODO: generate XEDVersion.cmake as well file
configure_file("${CMAKE_CURRENT_SOURCE_DIR}/XEDConfig.cmake.in" "${CMAKE_INSTALL_PREFIX}/lib/cmake/XED/XEDConfig.cmake" @ONLY)
```

---

# Docker

## Image layers

- Base: `ubuntu:22.04`
- LLVM: `ghcr.io/llvmparty/packages/llvm:22.04-llvm19.1.0`
  - Takes the longest time to build, so we create a separate layer
- Final: `ghcr.io/llvmparty/packages/dependencies:22.04-llvm19.1.0-xxx`

**Note**: we use [multi-stage](https://docs.docker.com/build/building/multi-stage/) builds to limit the final image size!

## [Multi-platform build](https://docs.docker.com/build/building/multi-platform/)

```sh
docker buildx build --platform linux/arm64,linux/amd64 -t "$LLVM_TAG" . -f llvm.Dockerfile
```

The final images are pushed to a (public) docker registry.

---

# GitHub Actions

```yaml
jobs:
  build:
    runs-on: ubuntu-22.04
    container:
      image: ghcr.io/llvmparty/packages/dependencies:22.04-llvm19-20241007-3f858ff9
  steps:
      - name: Checkout
        uses: actions/checkout@v4
        with:
          submodules: recursive

      - name: Build Project
        run: |
          cmake -B build -G Ninja
          cmake --build build
```

---

# Devcontainers

`.devcontainer/devcontainer.json`:

```json
{
    "name": "MyProject",
    "image": "ghcr.io/llvmparty/packages/dependencies:22.04-llvm19-20241007-3f858ff9",
    "customizations": {
        "vscode": {
            "extensions": [
                "llvm-vs-code-extensions.vscode-clangd",
                // Add more extensions here
            ]
        },
        "codespaces": {
            "openFiles": [
                "src/main.cpp"
            ]
        }
    },
    "remoteEnv": {
        "PATH": "${containerWorkspaceFolder}/build:${containerEnv:PATH}"
    },
    "postCreateCommand": ".devcontainer/post-create.sh"
}
```

---

# Demo

Questions?