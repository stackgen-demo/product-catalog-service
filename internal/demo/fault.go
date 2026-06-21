package demo

import (
	"math/rand"
	"os"
	"strconv"
	"strings"
)

// FaultMode returns CATALOG_DEMO_FAULT env value (feature, rank, or empty).
func FaultMode() string {
	return strings.ToLower(strings.TrimSpace(os.Getenv("CATALOG_DEMO_FAULT")))
}

// FailureFraction returns CATALOG_FAILURE_FRACTION in [0,1].
func FailureFraction() float64 {
	raw := os.Getenv("CATALOG_FAILURE_FRACTION")
	if raw == "" {
		return 0
	}
	value, err := strconv.ParseFloat(raw, 64)
	if err != nil || value < 0 {
		return 0
	}
	if value > 1 {
		return 1
	}
	return value
}

// ShouldInjectFeatureFailure returns true when env or flagd should fail OLJCESPC7Z lookups.
func ShouldInjectFeatureFailure(productID string, flagdEnabled bool) bool {
	if productID != "OLJCESPC7Z" {
		return false
	}
	if FaultMode() == "feature" {
		return true
	}
	fraction := FailureFraction()
	if fraction > 0 && rand.Float64() < fraction {
		return true
	}
	return flagdEnabled
}

// ShouldForceRankPanic returns true when rank fault mode is enabled.
func ShouldForceRankPanic() bool {
	return FaultMode() == "rank"
}
