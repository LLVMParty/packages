set(remill_DIR "${CMAKE_CURRENT_LIST_DIR}/remill")

if(NOT EXISTS "${remill_DIR}" OR NOT EXISTS "${remill_DIR}/CMakeLists.txt")
    message(STATUS "Submodule 'remill' not initialized, running git...")
    execute_process(
        COMMAND "${GIT_EXECUTABLE}" rev-parse --show-toplevel
        WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
        OUTPUT_VARIABLE git_root
        OUTPUT_STRIP_TRAILING_WHITESPACE
        COMMAND_ERROR_IS_FATAL ANY
    )
    execute_process(
        COMMAND "${GIT_EXECUTABLE}" submodule update --init
        WORKING_DIRECTORY "${git_root}"
        COMMAND_ERROR_IS_FATAL ANY
    )
endif()

file(GLOB sleigh_patches LIST_DIRECTORIES FALSE
    "${remill_DIR}/dependencies/sleigh_patches/*.patch"
)
list(SORT sleigh_patches)

if(NOT sleigh_patches)
    message(FATAL_ERROR "ENABLE_SLEIGH did not find any patches in sleigh_patches")
endif()

string(REPLACE ";" "\\;" sleigh_patches_arg "${sleigh_patches}")

simple_git(https://github.com/lifting-bits/sleigh 7c6b742
    "-Dsleigh_ADDITIONAL_PATCHES:STRING=${sleigh_patches_arg}"
    "-Dsleigh_ENABLE_TESTS:BOOL=OFF"
    "-Dsleigh_RELEASE_TYPE:STRING=HEAD"
    "-Dsleigh_BUILD_SUPPORT:BOOL=ON"
    "-Dsleigh_BUILD_SLEIGHSPECS:BOOL=ON"
)

ExternalProject_Add_Step(sleigh ppc_e200_spec_install
    COMMAND
        "${CMAKE_COMMAND}"
        "-Dinstall_prefix:PATH=${CMAKE_INSTALL_PREFIX}"
        "-Dbinary_dir:PATH=<BINARY_DIR>"
        -P "${CMAKE_CURRENT_LIST_DIR}/build_ppc_e200_sla.cmake"
    DEPENDEES install
)

ExternalProject_Add(remill
    SOURCE_DIR
        "${remill_DIR}"
    CMAKE_CACHE_ARGS
        ${CMAKE_ARGS}
        "-DREMILL_ENABLE_TESTING:STRING=OFF"
        "-DREMILL_FETCH_SLEIGH:STRING=OFF"
    CMAKE_GENERATOR
        "Ninja"
    # Always trigger the build step (necessary because there is no download step)
    BUILD_ALWAYS
        ON
)