# Product Catalog Service

gRPC product catalog for the **aiden-demo** namespace on EKS. Ships OTLP traces, metrics, and logs to the shared Datadog agent (US3), same pattern as [order-service](https://github.com/stackgen-demo/order-service).

Service name in Datadog: **`product-catalog-service`**

## Local run

```bash
export PRODUCT_CATALOG_PORT=3550
go run .
```

Expected startup logs:

```json
{"message":"starting grpc server at :3550","severity":"info"}
```

## Container image (GHCR)

Push to `main` runs [`.github/workflows/docker-publish.yml`](.github/workflows/docker-publish.yml):

`ghcr.io/stackgen-demo/product-catalog-service:latest`

Make the GHCR package **public** after the first CI run (Packages → product-catalog-service → Change visibility).

## Deploy to aiden-demo

**Prerequisites:** [order-service](https://github.com/stackgen-demo/order-service) stack applied (`kubectl apply -f ../order-service/k8s/stack.yaml`), `datadog-secret` present, and OTLP enabled on the agent:

```bash
kubectl -n aiden-demo set env deployment/datadog-agent \
  DD_OTLP_CONFIG_RECEIVER_PROTOCOLS_GRPC_ENDPOINT=0.0.0.0:4317
```

```bash
# After CI publishes the image (or local build):
PUSH=true ./scripts/deploy-aiden-demo.sh
# Or apply manifests only:
./scripts/deploy-aiden-demo.sh
```

## Datadog

- APM: `service:product-catalog-service env:demo`
- gRPC port **3550** (`product-catalog-service.aiden-demo.svc:3550`)

## Legacy ECR workflow

[`.github/workflows/build-product-catalog-service.yml`](.github/workflows/build-product-catalog-service.yml) still publishes to AWS ECR for the retail-store Helm chart. Prefer GHCR + `k8s/` for aiden-demo.

## Regenerate protos

From a checkout that includes the OpenTelemetry demo `pb/` tree:

```bash
go generate .
```

## Bump dependencies

```bash
go get -u -t ./...
go mod tidy
```
