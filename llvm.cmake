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
