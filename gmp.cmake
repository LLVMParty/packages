# TODO: pass compiler flags

set(DEFAULT_C_CXX_FLAGS "-pedantic")

if(CMAKE_OSX_SYSROOT)
    set(DEFAULT_C_CXX_FLAGS "${DEFAULT_C_CXX_FLAGS} -isysroot ${CMAKE_OSX_SYSROOT}")
endif()

set(CONFIGURE_ARGS
    "--enable-cxx"
    "--prefix"
    "${CMAKE_INSTALL_PREFIX}"
    "CC=${CMAKE_C_COMPILER}"
    "CXX=${CMAKE_CXX_COMPILER}"
    "CFLAGS=${CMAKE_C_FLAGS} ${DEFAULT_C_CXX_FLAGS}"
    "CXXFLAGS=${CMAKE_CXX_FLAGS} ${DEFAULT_C_CXX_FLAGS}"
    "LDFLAGS=${CMAKE_EXE_LINKER_FLAGS}"
)

if(BUILD_SHARED_LIBS)
    list(APPEND CONFIGURE_ARGS "--enable-shared=yes --enable-static=no")
else()
    list(APPEND CONFIGURE_ARGS "--enable-shared=no --enable-static=yes")
endif()

ExternalProject_Add(gmp
    URL
        https://gmplib.org/download/gmp/gmp-6.3.0.tar.xz
    URL_MD5
        956dc04e864001a9c22429f761f2c283
    CMAKE_CACHE_ARGS
        ${CMAKE_ARGS}
    CONFIGURE_COMMAND
        "<SOURCE_DIR>/configure" ${CONFIGURE_ARGS}
    BUILD_COMMAND
        "make"
    INSTALL_COMMAND
        "make" "install"
    PREFIX
        gmp-prefix
)

# TODO: generate GMPVersion.cmake as well file
configure_file("${CMAKE_CURRENT_SOURCE_DIR}/GMPConfig.cmake.in" "${CMAKE_INSTALL_PREFIX}/lib/cmake/gmp/GMPConfig.cmake" @ONLY)
