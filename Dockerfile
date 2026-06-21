# Standalone product-catalog-service image for aiden-demo (gRPC + OTLP → Datadog agent).
# Copyright The OpenTelemetry Authors — SPDX-License-Identifier: Apache-2.0

FROM golang:1.25-bookworm AS builder

WORKDIR /usr/src/app/

COPY go.mod go.sum ./
RUN go mod download

COPY genproto/oteldemo/ genproto/oteldemo/
COPY internal/ internal/
COPY products/ products/
COPY main.go ./

RUN CGO_ENABLED=0 GOOS=linux GO111MODULE=on go build -ldflags "-s -w" -o product-catalog main.go

FROM gcr.io/distroless/static-debian12:nonroot

WORKDIR /usr/src/app/

COPY --from=builder /usr/src/app/product-catalog ./
COPY --from=builder /usr/src/app/products ./products/

ENV PRODUCT_CATALOG_PORT=3550
ENV DD_SERVICE=product-catalog-service
ENV DD_ENV=demo

EXPOSE 3550

ENTRYPOINT ["./product-catalog"]
