# AGENTS

Owner: Cesar Rodriguez
Style: concise, telegraphic, noun-phrases ok, minimal tokens. ASCII only.

## Repo purpose
- Product Catalog Service: gRPC service serving product data from JSON files in `products/`.
- Loads product catalog at startup and reloads on interval; exposes List/Get/Search APIs.
- Instrumented with OpenTelemetry (traces, metrics, logs) and OpenFeature flagd.

## Tech stack
- Go (module), gRPC, protobuf
- OpenTelemetry SDK + OTLP gRPC exporters
- OpenFeature + flagd provider
- Dockerfile (service image); proto generator Dockerfile in `genproto/`

## Bootstrap / build / run (local)
- Go module deps: `go mod download`
- Build binary: `go build -o /go/bin/product-catalog/` (per README)
- Run locally: `PRODUCT_CATALOG_PORT=3550 go run .`
- Docker build: `docker compose build product-catalog` (if compose file present)
- Regenerate protos: `make docker-generate-protobuf` (if Makefile present)

## Test / lint
- Tests: `go test ./...` (if tests present)
- Vet: `go vet ./...` (if present)
- Formatting: `gofmt -w .` (if needed)

## Key directories / files
- `main.go`: gRPC server, catalog load/reload, OpenTelemetry setup
- `products/`: JSON catalog files (ListProductsResponse format)
- `genproto/`: generated protobuf Go types (checked in)
- `genproto/Dockerfile`: proto generation image

## CI / workflows
- No `.github/workflows` found in this repo. If CI exists upstream, mirror local commands above.

## Common gotchas
- `PRODUCT_CATALOG_PORT` is required; service logs error if missing.
- Working directory must be repo root to find `./products/*.json`.
- `PRODUCT_CATALOG_RELOAD_INTERVAL` sets reload seconds; <=0 defaults to 10.
- `go:generate` expects `../../pb/demo.proto`; likely works only in parent monorepo.
- OTLP exporters assume a collector; without one, startup may log export errors.
- Feature flag `productCatalogFailure` (flagd) can force error on product id `OLJCESPC7Z`.
