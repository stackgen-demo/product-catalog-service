# Dockerfile for Product Catalog Service
# This Dockerfile is designed for the standalone repository structure
# where files are at the root level, not in src/product-catalog/

# Copyright The OpenTelemetry Authors
# SPDX-License-Identifier: Apache-2.0

FROM golang:1.24-bookworm AS builder

WORKDIR /usr/src/app/

# Copy go mod files
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download

# Copy source files
COPY genproto/oteldemo/ genproto/oteldemo/
COPY products/ products/
COPY main.go ./

# Build the application
RUN CGO_ENABLED=0 GOOS=linux GO111MODULE=on go build -ldflags "-s -w" -o product-catalog main.go

# Final stage - use distroless for security
FROM gcr.io/distroless/static-debian12:nonroot

WORKDIR /usr/src/app/

# Copy the binary from builder
COPY --from=builder /usr/src/app/product-catalog ./

# Expose the port (default 8080, can be overridden via env)
EXPOSE 8080

# Run the application
ENTRYPOINT [ "./product-catalog" ]
