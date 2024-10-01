Build the images:

```
export TAG="ghcr.io/llvmparty/packages/ubuntu:22.04-llvm19.1.0"
docker buildx build --platform linux/arm64 -t "$TAG" .
docker buildx build --platform linux/amd64 -t "$TAG" .
docker buildx build --platform linux/arm64,linux/amd64 -t "$TAG" .
```

Push to GitHub Container Registry:

```
docker push "$TAG"
```