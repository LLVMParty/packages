@echo off
call vs2019 x64
mkdir build && cd build
rem TODO: disable /INCREMENTAL(?)
cmake -G Ninja %LLVM_DIR%\llvm -DCMAKE_BUILD_TYPE=RelWithDebInfo -DLLVM_ENABLE_PROJECTS=clang;lld
cmake --build .
cmake --install . --prefix ../install