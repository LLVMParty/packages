find_package(Python3 COMPONENTS Interpreter REQUIRED)
message(STATUS "Python3: ${Python3_EXECUTABLE}")

# TODO: pass compiler flags

set(CONFIGURE_ARGS
    "--prefix"
    "<SOURCE_DIR>/install"
    "release"
)

if(BUILD_SHARED_LIBS)
    list(APPEND CONFIGURE_ARGS "--shared")
else()
    list(APPEND CONFIGURE_ARGS "--static")
endif()

ExternalProject_Add(bitwuzla
    GIT_REPOSITORY
        "https://github.com/bitwuzla/bitwuzla"
    GIT_TAG
        "0.6.0"
    GIT_PROGRESS
        ON
    GIT_SHALLOW
        ON
    CMAKE_CACHE_ARGS
        ${CMAKE_ARGS}
    BUILD_IN_SOURCE
        1
    CONFIGURE_COMMAND
        "${Python3_EXECUTABLE}" "<SOURCE_DIR>/configure.py" ${CONFIGURE_ARGS}
    BUILD_COMMAND
        "ninja" "-C" "<SOURCE_DIR>/build" "install"
    INSTALL_COMMAND
        "${CMAKE_COMMAND}" -E copy_directory <SOURCE_DIR>/install "${CMAKE_INSTALL_PREFIX}"
    PREFIX
        bitwuzla-prefix
)

# TODO: generate BITWUZLAVersion.cmake as well file
configure_file("${CMAKE_CURRENT_SOURCE_DIR}/BITWUZLAConfig.cmake.in" "${CMAKE_INSTALL_PREFIX}/lib/cmake/bitwuzla/BITWUZLAConfig.cmake" @ONLY)
