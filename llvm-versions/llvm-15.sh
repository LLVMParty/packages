#!/bin/bash
export LLVM_VERSION="15.0.7"
export LLVM_TAG="ghcr.io/llvmparty/packages/ubuntu:22.04-llvm$LLVM_VERSION"
export LLVM_URL="https://github.com/llvm/llvm-project/releases/download/llvmorg-$LLVM_VERSION/llvm-project-$LLVM_VERSION.src.tar.xz"
export LLVM_SHA256="8b5fcb24b4128cf04df1b0b9410ce8b1a729cb3c544e6da885d234280dedeac6"
export BUILD_ARGS="--build-arg LLVM_URL=$LLVM_URL --build-arg LLVM_SHA256=$LLVM_SHA256"

docker buildx build $BUILD_ARGS --platform linux/arm64 -t "$LLVM_TAG" . -f llvm.Dockerfile
if [ $? != 0 ]; then exit 1; fi
docker buildx build $BUILD_ARGS --platform linux/amd64 -t "$LLVM_TAG" . -f llvm.Dockerfile
if [ $? != 0 ]; then exit 1; fi
docker buildx build $BUILD_ARGS --platform linux/arm64,linux/amd64 -t "$LLVM_TAG" . -f llvm.Dockerfile
if [ $? != 0 ]; then exit 1; fi
docker push "$LLVM_TAG"
if [ $? != 0 ]; then exit 1; fi
