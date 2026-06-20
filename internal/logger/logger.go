package logger

import (
	"context"
	"encoding/json"
	"fmt"
	"os"
	"time"

	"github.com/DataDog/dd-trace-go/v2/ddtrace/tracer"
)

func serviceName() string {
	if name := os.Getenv("DD_SERVICE"); name != "" {
		return name
	}
	return "product-catalog-service"
}

func envName() string {
	if env := os.Getenv("DD_ENV"); env != "" {
		return env
	}
	return "demo"
}

func write(ctx context.Context, level, message string, fields map[string]any) {
	entry := map[string]any{
		"level":     level,
		"status":    level,
		"message":   message,
		"service":   serviceName(),
		"env":       envName(),
		"timestamp": time.Now().UTC().Format(time.RFC3339Nano),
	}
	for key, value := range fields {
		entry[key] = value
	}
	if ctx != nil {
		if span, ok := tracer.SpanFromContext(ctx); ok {
			traceCtx := span.Context()
			entry["dd.trace_id"] = traceCtx.TraceID()
			entry["dd.span_id"] = fmt.Sprintf("%d", traceCtx.SpanID())
		}
	}
	data, _ := json.Marshal(entry)
	fmt.Println(string(data))
}

// ErrorContext logs structured JSON errors for Datadog file tail collection.
func ErrorContext(ctx context.Context, message string, fields map[string]any) {
	write(ctx, "error", message, fields)
}

// InfoContext logs structured JSON info events.
func InfoContext(ctx context.Context, message string, fields map[string]any) {
	write(ctx, "info", message, fields)
}
