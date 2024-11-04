# TODO: pass compiler flags

set(CONFIGURE_ARGS
    "-Db_ndebug=true"
    "-Dtesting=disabled"
    "-Dunit_testing=disabled"
    "-Dprefix=${CMAKE_INSTALL_PREFIX}"
    "-Dbuildtype=debugoptimized"
    "-Dpkg_config_path=${CMAKE_INSTALL_PREFIX}/lib/pkgconfig"
)

if(USE_SANITIZERS)
    list(APPEND CONFIGURE_ARGS
        "-Db_ndebug=false"
        "-Db_sanitize=address,undefined"
        "-Db_lundef=false"
    )
endif()

if(BUILD_SHARED_LIBS)
    list(APPEND CONFIGURE_ARGS "-Ddefault_library=shared")
else()
    list(APPEND CONFIGURE_ARGS "-Ddefault_library=static")
endif()

ExternalProject_Add(bitwuzla
    GIT_REPOSITORY
        "https://github.com/LLVMParty/bitwuzla"
    GIT_TAG
        "sanitizers"
    GIT_PROGRESS
        ON
    GIT_SHALLOW
        ON
    CMAKE_CACHE_ARGS
        ${CMAKE_ARGS}
    BUILD_IN_SOURCE
        1
    CONFIGURE_COMMAND
        "meson"
        "setup"
        "build"
        ${CONFIGURE_ARGS}
    BUILD_COMMAND
        "ninja" "-C" "<SOURCE_DIR>/build"
    INSTALL_COMMAND
        "ninja" "-C" "<SOURCE_DIR>/build" "install"
    PREFIX
        bitwuzla-prefix
)

# TODO: generate BITWUZLAVersion.cmake as well file
configure_file("${CMAKE_CURRENT_SOURCE_DIR}/BITWUZLAConfig.cmake.in" "${CMAKE_INSTALL_PREFIX}/lib/cmake/bitwuzla/BITWUZLAConfig.cmake" @ONLY)
