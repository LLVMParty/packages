# packages

**Important**: This repository serves as an example and does not come with support or guarantees in any way.

## Local builds

```sh
cmake -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build
```

This will create a [CMake prefix](https://cmake.org/cmake/help/latest/command/find_package.html#search-procedure), which you pass to your project with `-DCMAKE_PREFIX_PATH=/path/to/packages/install`. See [`presentation.md`](./presentation.md) and [`dependencies.md`](./dependencies.md) for more details.

## Docker Image Build Instructions

**Note**: End users do not need to run these commands, they are just here for reference.

Build `packages/ubuntu`:

```
export LLVM_TAG="ghcr.io/llvmparty/packages/ubuntu:22.04-llvm19.1.7"
docker buildx build --platform linux/arm64 -t "$LLVM_TAG" . -f llvm.Dockerfile
docker buildx build --platform linux/amd64 -t "$LLVM_TAG" . -f llvm.Dockerfile
docker buildx build --platform linux/arm64,linux/amd64 -t "$LLVM_TAG" . -f llvm.Dockerfile
docker push "$LLVM_TAG"
```

Build `packages/dependencies`:

```
export HASH=$(python hash.py --simple | cut -c 1-8)
export DATE="$(date +"%Y%m%d")"
export TAG="ghcr.io/llvmparty/packages/dependencies:22.04-llvm19-$DATE-$HASH"
docker buildx build --platform linux/arm64 -t "$TAG" . -f dependencies.Dockerfile
docker buildx build --platform linux/amd64 -t "$TAG" . -f dependencies.Dockerfile
docker buildx build --platform linux/arm64,linux/amd64 -t "$TAG" . -f dependencies.Dockerfile
docker push "$TAG"
```

References:
- https://www.docker.com/blog/faster-multi-platform-builds-dockerfile-cross-compilation-guide/
- https://docs.docker.com/build/building/multi-stage/
