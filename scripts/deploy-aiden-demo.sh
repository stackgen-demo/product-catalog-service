#!/usr/bin/env bash
# Apply product-catalog-service to aiden-demo (log paths live in order-service k8s/stack.yaml).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NAMESPACE="${NAMESPACE:-aiden-demo}"
IMAGE="${IMAGE:-ghcr.io/stackgen-demo/product-catalog-service:latest}"
PUSH="${PUSH:-false}"

cd "$ROOT"

if [[ "$PUSH" == "true" ]]; then
  echo "==> docker build + push $IMAGE"
  docker buildx build --platform linux/amd64,linux/arm64 -t "$IMAGE" --push .
fi

echo "==> apply product-catalog-service"
kubectl apply -f k8s/product-catalog-service.yaml
kubectl -n "$NAMESPACE" rollout status deployment/product-catalog-service --timeout=180s

kubectl -n "$NAMESPACE" get pods -l app=product-catalog-service -o wide
echo "product-catalog-service deployed. Datadog: service:product-catalog-service env:demo"
