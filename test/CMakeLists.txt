cmake_minimum_required(VERSION 3.20)

project(test)

# Set the optimization level

if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release)
endif()

add_compile_options(-Wall -Wextra)
set(CMAKE_CXX_FLAGS_DEBUG "-O0 -gfull")
set(CMAKE_CXX_FLAGS_RELEASE "-O3 -g0 -fomit-frame-pointer -march=native")

# Find the dependencies

set(GFLAGS_USE_TARGET_NAMESPACE ON)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

find_package(Z3 REQUIRED)
find_package(LLVM-Wrapper REQUIRED)
find_package(Alive2 REQUIRED)
find_package(Souper REQUIRED)
find_package(remill REQUIRED)
find_package(LIEF REQUIRED)
find_package(capstone REQUIRED)
find_package(fmt REQUIRED)
find_package(spdlog REQUIRED)
find_package(tsl-ordered-map REQUIRED)
find_package(toml11 REQUIRED)
find_package(STP REQUIRED)
find_package(httplib REQUIRED)
find_package(bitwuzla REQUIRED)

# Create target

add_executable(${PROJECT_NAME} main.cpp)
target_link_libraries(${PROJECT_NAME} PRIVATE
    LLVM-Wrapper
    souper
    remill
    remill_settings
    LIEF::LIEF
    capstone::capstone
    spdlog::spdlog
    tsl::ordered_map
    toml11::toml11
    stp
    httplib::httplib
    bitwuzla::bitwuzla
)

target_compile_features(${PROJECT_NAME} PRIVATE
    cxx_std_20
)

set_target_properties(${PROJECT_NAME} PROPERTIES
    POSITION_INDEPENDENT_CODE ON
)
