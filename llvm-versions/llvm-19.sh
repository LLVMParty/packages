#!/bin/bash
export LLVM_VERSION="19.1.7"
export LLVM_TAG="ghcr.io/llvmparty/packages/ubuntu:22.04-llvm$LLVM_VERSION"
export LLVM_URL="https://github.com/llvm/llvm-project/releases/download/llvmorg-$LLVM_VERSION/llvm-project-$LLVM_VERSION.src.tar.xz"
export LLVM_SHA256="82401fea7b79d0078043f7598b835284d6650a75b93e64b6f761ea7b63097501"
export BUILD_ARGS="--build-arg LLVM_URL=$LLVM_URL --build-arg LLVM_SHA256=$LLVM_SHA256"

docker buildx build $BUILD_ARGS --platform linux/arm64 -t "$LLVM_TAG" . -f llvm.Dockerfile
if [ $? != 0 ]; then exit 1; fi
docker buildx build $BUILD_ARGS --platform linux/amd64 -t "$LLVM_TAG" . -f llvm.Dockerfile
if [ $? != 0 ]; then exit 1; fi
docker buildx build $BUILD_ARGS --platform linux/arm64,linux/amd64 -t "$LLVM_TAG" . -f llvm.Dockerfile
if [ $? != 0 ]; then exit 1; fi
docker push "$LLVM_TAG"
if [ $? != 0 ]; then exit 1; fi
