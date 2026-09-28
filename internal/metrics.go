package internal

import (
	"context"

	"go.opentelemetry.io/otel/attribute"
	"go.opentelemetry.io/otel/metric"
)

const meterName = "cbt"

// appMetrics is the package-level handle to the registered application
// metrics. It is populated by SetupOTel once the global MeterProvider has been
// installed, and read by the gRPC handlers and the authentication interceptors
// when they record business-level measurements. It remains nil when telemetry
// is disabled (OTEL_SDK_DISABLED=true) or when instrument registration fails;
// every recording site must guard against a nil value so a missing meter never
// panics the request path.
var appMetrics *Metrics

// Metrics holds the OpenTelemetry instruments used to record
// application-level measurements for the cbt gRPC API. They complement the
// automatic rpc.server.* metrics emitted by the otelgrpc stats handler with
// dimensions the stats handler cannot see: how much journalling is happening,
// and how long records sit before they are challenged.
//
// These instruments deliberately carry no content. What a user wrote, which
// biases they identified and how strongly they felt anything are never
// exported: the attribute sets below are limited to record types and outcomes.
// See AGENTS.md.
type Metrics struct {
	// AuthAttempts counts every authentication attempt observed by the
	// authentication interceptors, labelled by the auth mode (tailscale or
	// dummy) and the outcome (success or failure).
	AuthAttempts metric.Int64Counter

	// RecordsCreated counts records as they are written, labelled by record
	// type (thought_record or map_of_worry). It answers whether the practice
	// is actually being kept up, which is the single thing worth measuring
	// about a journal.
	RecordsCreated metric.Int64Counter

	// ChallengeLatency records the time between a thought record being created
	// and being challenged, in hours. A record is meant to be worked through
	// the same evening, so the distribution says whether that is happening.
	ChallengeLatency metric.Float64Histogram
}

// Attribute keys used by the application metrics. Centralised here so the
// spelling is consistent across recording sites.
const (
	attrAuthMode   = attribute.Key("auth.mode")
	attrAuthResult = attribute.Key("auth.result")
	attrRecordType = attribute.Key("record.type")
)

// Record type attribute values.
const (
	recordTypeThoughtRecord = "thought_record"
	recordTypeMapOfWorry    = "map_of_worry"
)

// challengeLatencyBuckets are hours. The SDK default boundaries are tuned for
// latency in seconds and would put every observation in the last bucket. The
// interesting distinctions are "same evening" (under 12 hours), "next day",
// and "left for a week", so the boundaries are spread accordingly.
var challengeLatencyBuckets = []float64{1, 6, 12, 24, 48, 168, 720}

// NewMetrics registers all application-level instruments on the provided meter
// and returns a Metrics handle holding them. The meter is expected to be the
// global one (otel.Meter(meterName)) so that the PeriodicReader in SetupOTel
// exports the recorded data points; passing a separate meter would silently
// orphan the instruments.
//
// Registration errors are returned to the caller, which is expected to log
// them and continue (matching the non-fatal telemetry pattern in SetupOTel).
func NewMetrics(meter metric.Meter) (*Metrics, error) {
	authAttempts, err := meter.Int64Counter(
		"cbt.auth.attempts",
		metric.WithDescription("Number of authentication attempts observed by the auth interceptors"),
	)
	if err != nil {
		return nil, err
	}

	recordsCreated, err := meter.Int64Counter(
		"cbt.records.created",
		metric.WithDescription("Number of records created, by record type"),
	)
	if err != nil {
		return nil, err
	}

	challengeLatency, err := meter.Float64Histogram(
		"cbt.challenge.latency",
		metric.WithDescription("Hours between a thought record being created and being challenged"),
		metric.WithUnit("h"),
		metric.WithExplicitBucketBoundaries(challengeLatencyBuckets...),
	)
	if err != nil {
		return nil, err
	}

	return &Metrics{
		AuthAttempts:     authAttempts,
		RecordsCreated:   recordsCreated,
		ChallengeLatency: challengeLatency,
	}, nil
}

// --- Recording helpers -------------------------------------------------
//
// Each helper is a no-op when appMetrics is nil. The nil check is deliberately
// kept inside the helper rather than at every call site so that handlers stay
// focused on business logic; a missing meter (because telemetry is disabled or
// registration failed) must never panic the request path.

// recordAuthAttempt increments the auth.attempts counter with the given mode
// and result labels.
func recordAuthAttempt(ctx context.Context, mode, result string) {
	if appMetrics == nil {
		return
	}
	appMetrics.AuthAttempts.Add(
		ctx,
		1,
		metric.WithAttributes(
			attrAuthMode.String(mode),
			attrAuthResult.String(result),
		),
	)
}

// recordCreated increments the records.created counter for the given record
// type.
func recordCreated(ctx context.Context, recordType string) {
	if appMetrics == nil {
		return
	}
	appMetrics.RecordsCreated.Add(
		ctx,
		1,
		metric.WithAttributes(attrRecordType.String(recordType)),
	)
}

// recordChallengeLatency records how many hours a record sat before it was
// challenged. Negative durations are dropped rather than recorded: they can
// only come from a clock adjustment and would skew the distribution.
func recordChallengeLatency(ctx context.Context, hours float64) {
	if appMetrics == nil || hours < 0 {
		return
	}
	appMetrics.ChallengeLatency.Record(ctx, hours)
}
