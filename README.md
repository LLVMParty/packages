# packages

## Build instructions

**Note**: End users do not need to run these commands, they are just here for reference.

Build `packages/ubuntu`:

```
export TAG="ghcr.io/llvmparty/packages/ubuntu:22.04-llvm19.1.0"
docker buildx build --platform linux/arm64 -t "$TAG" . -f llvm.Dockerfile
docker buildx build --platform linux/amd64 -t "$TAG" . -f llvm.Dockerfile
docker buildx build --platform linux/arm64,linux/amd64 -t "$TAG" . -f llvm.Dockerfile
docker push "$TAG"
```

Build `packages/dependencies`:

```
export HASH=$(python hash.py --short)
export DATE="$(date +"%Y%m%d")"
export TAG="ghcr.io/llvmparty/packages/dependencies:22.04-llvm19-$DATE-$HASH"
docker buildx build --platform linux/arm64 -t "$TAG" . -f dependencies.Dockerfile
docker buildx build --platform linux/amd64 -t "$TAG" . -f dependencies.Dockerfile
docker buildx build --platform linux/arm64,linux/amd64 -t "$TAG" . -f dependencies.Dockerfile
docker push "$TAG"
```
