#!/bin/bash
export LLVM_VERSION="21.1.1"
export LLVM_TAG="ghcr.io/llvmparty/packages/ubuntu:22.04-llvm$LLVM_VERSION"
export LLVM_URL="https://github.com/llvm/llvm-project/releases/download/llvmorg-$LLVM_VERSION/llvm-project-$LLVM_VERSION.src.tar.xz"
export LLVM_SHA256="8863980e14484a72a9b7d2c80500e1749054d74f08f8c5102fd540a3c5ac9f8a"
export BUILD_ARGS="--build-arg LLVM_URL=$LLVM_URL --build-arg LLVM_SHA256=$LLVM_SHA256"

docker buildx build $BUILD_ARGS --platform linux/arm64 -t "$LLVM_TAG" . -f llvm.Dockerfile
if [ $? != 0 ]; then exit 1; fi
docker buildx build $BUILD_ARGS --platform linux/amd64 -t "$LLVM_TAG" . -f llvm.Dockerfile
if [ $? != 0 ]; then exit 1; fi
docker buildx build $BUILD_ARGS --platform linux/arm64,linux/amd64 -t "$LLVM_TAG" . -f llvm.Dockerfile
if [ $? != 0 ]; then exit 1; fi
docker push "$LLVM_TAG"
if [ $? != 0 ]; then exit 1; fi
