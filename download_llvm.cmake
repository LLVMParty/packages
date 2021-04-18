# License: BSL-1.0

if(NOT LLVM_VERSION)
    message(FATAL_ERROR "Missing argument -DLLVM_VERSION=...")
endif()

set(LLVM_URL "https://github.com/llvm/llvm-project/archive/refs/tags/llvmorg-${LLVM_VERSION}.tar.gz")
get_filename_component(LLVM_FILE "${LLVM_URL}" NAME)

set(LLVM_ARCHIVE "${CMAKE_CURRENT_SOURCE_DIR}/${LLVM_FILE}")
if(NOT EXISTS "${LLVM_ARCHIVE}")
    message(STATUS "Downloading ${LLVM_URL} ...")
    file(DOWNLOAD "${LLVM_URL}" "${LLVM_ARCHIVE}")
else()
    message(STATUS "${LLVM_FILE} already downloaded")
endif()

set(LLVM_DIR "${CMAKE_CURRENT_SOURCE_DIR}/llvm-${LLVM_VERSION}")
if(NOT IS_DIRECTORY "${LLVM_DIR}")
    message(STATUS "Extracting ${LLVM_FILE} ...")
    file(ARCHIVE_EXTRACT
        INPUT
            "${LLVM_ARCHIVE}"
        DESTINATION
            "${CMAKE_CURRENT_SOURCE_DIR}"
    )
    file(RENAME "${CMAKE_CURRENT_SOURCE_DIR}/llvm-project-llvmorg-${LLVM_VERSION}" "${CMAKE_CURRENT_SOURCE_DIR}/llvm-${LLVM_VERSION}")
else()
    message(STATUS "${LLVM_FILE} already extracted")
endif()