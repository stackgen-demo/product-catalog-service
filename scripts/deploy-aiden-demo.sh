#!/usr/bin/env bash
# Build (optional), apply product-catalog-service to aiden-demo, refresh Datadog log tail config.
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

echo "==> apply datadog log config (aiden-demo workloads)"
kubectl apply -f k8s/datadog-logs-config.yaml
kubectl -n "$NAMESPACE" rollout restart deployment/datadog-agent
kubectl -n "$NAMESPACE" rollout status deployment/datadog-agent --timeout=120s

echo "==> apply product-catalog-service"
kubectl apply -f k8s/product-catalog-service.yaml
kubectl -n "$NAMESPACE" rollout status deployment/product-catalog-service --timeout=180s

kubectl -n "$NAMESPACE" get pods -l 'app in (aiden-demo,product-catalog-service,datadog-agent)' -o wide
echo "product-catalog-service deployed. Datadog: service:product-catalog-service env:demo"
