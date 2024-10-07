# https://alexreinking.com/blog/how-to-use-cmake-without-the-agonizing-pain-part-1.html
cmake_minimum_required(VERSION 3.22)

project(dependencies)

option(USE_SYSTEM_LLVM "Use system LLVM" OFF)

if(USE_SYSTEM_LLVM)
    if(CMAKE_HOST_SYSTEM_NAME MATCHES "Darwin" AND NOT CMAKE_PREFIX_PATH)
        execute_process(
            COMMAND brew --prefix llvm 
            RESULT_VARIABLE BREW_LLVM
            OUTPUT_VARIABLE BREW_LLVM_PREFIX
            OUTPUT_STRIP_TRAILING_WHITESPACE
        )
        if(BREW_LLVM EQUAL 0 AND EXISTS "${BREW_LLVM_PREFIX}")
            set(CMAKE_PREFIX_PATH "${BREW_LLVM_PREFIX}")
            message(STATUS "Found LLVM keg installed by Homebrew at ${BREW_LLVM_PREFIX}")
        else()
            message(FATAL_ERROR "LLVM not found, to install: brew install llvm")
        endif()
    endif()
    find_package(LLVM CONFIG REQUIRED)
    message(STATUS "LLVM ${LLVM_PACKAGE_VERSION}: ${LLVM_DIR}")
endif()

include(superbuild.cmake)

simple_git(https://github.com/nlohmann/json v3.11.3
    "-DJSON_BuildTests:STRING=OFF"
)
simple_git(https://github.com/ToruNiina/toml11 1340692 # master (2023-06-06)
    "-DCMAKE_CXX_STANDARD:STRING=11"
)
simple_git(https://github.com/yhirose/cpp-httplib v0.13.1
    "-DHTTPLIB_USE_OPENSSL_IF_AVAILABLE:STRING=OFF"
    "-DHTTPLIB_IS_USING_BROTLI:STRING=OFF"
    "-DHTTPLIB_USE_BROTLI_IF_AVAILABLE:STRING=OFF"
)
simple_git(https://github.com/gflags/gflags v2.2.2
)
simple_git(https://github.com/google/glog v0.6.0
    "-DGFLAGS_USE_TARGET_NAMESPACE:STRING=ON"
)
simple_git(https://github.com/google/googletest v1.15.2
    "-Dgtest_force_shared_crt:STRING=ON"
    "-DGFLAGS_USE_TARGET_NAMESPACE:STRING=ON"
)
simple_git(https://github.com/redis/hiredis afc29ee)
simple_git(https://github.com/Tessil/ordered-map v1.1.0)
simple_git(https://github.com/fmtlib/fmt 10.2.1
    "-DFMT_DOC:STRING=OFF"
    "-DFMT_TEST:STRING=OFF"
    "-DFMT_SYSTEM_HEADERS:STRING=ON"
)
simple_git(https://github.com/gabime/spdlog e593f66
    "-DSPDLOG_FMT_EXTERNAL:STRING=ON"
    "-DSPDLOG_SYSTEM_INCLUDES:STRING=ON"
    "-DSPDLOG_BUILD_EXAMPLE:STRING=OFF"
)
simple_git(https://github.com/lief-project/LIEF 0.15.1
    "-DLIEF_EXAMPLES:STRING=OFF"
    "-DLIEF_USE_CCACHE:STRING=OFF"
)
simple_git(https://github.com/capstone-engine/capstone 5.0.3
    "-DCAPSTONE_BUILD_TESTS:STRING=OFF"
)
simple_git(https://github.com/Z3Prover/z3 z3-4.13.2
    "-DZ3_BUILD_LIBZ3_SHARED:STRING=OFF"
)
simple_git(https://github.com/LLVMParty/minisat modern-package-v1
    "-DBUILD_SHARED_LIBS:STRING=OFF"
)
simple_git(https://github.com/stp/stp a9bc247d98cd98213b2d0f6821dc51b823c50483
    "-DBUILD_EXECUTABLES:STRING=OFF"
    "-DSTATICCOMPILE:STRING=ON"
)
include(xed.cmake)
if(NOT USE_SYSTEM_LLVM)
    include(llvm.cmake)
endif()
simple_git(https://github.com/LLVMParty/remill llvm-19-v1
    "-DUSE_SYSTEM_DEPENDENCIES:STRING=ON"
    "-DREMILL_ENABLE_TESTING:STRING=OFF"
)
simple_git(https://github.com/LLVMParty/alive2 cmake-package-souper-v7)
simple_git(https://github.com/LLVMParty/souper cmake-package-v6)
