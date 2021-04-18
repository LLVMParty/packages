@echo off
set LLVM_VERSION=11.0.0
7z x -bd llvm-project-%LLVM_VERSION%.tar.xz
7z x -bd -aoa llvm-project-%LLVM_VERSION%.tar
set LLVM_DIR=%~dp0llvm-project-%LLVM_VERSION%