package internal

import (
	"context"
	"errors"
	"testing"

	"github.com/alexhokl/cbt/database"
	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/peer"
	"google.golang.org/grpc/status"
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
	"net"
	"tailscale.com/client/tailscale/apitype"
	"tailscale.com/tailcfg"
)

// fakeIdentityLookup stands in for the tsnet node so the interceptor can be
// tested without a live tailnet.
type fakeIdentityLookup struct {
	loginName string
	err       error
}

func (f *fakeIdentityLookup) GetCallerIdentityFromRemoteIPAddress(_ context.Context, _ string) (*apitype.WhoIsResponse, error) {
	if f.err != nil {
		return nil, f.err
	}
	return &apitype.WhoIsResponse{
		UserProfile: &tailcfg.UserProfile{LoginName: f.loginName},
	}, nil
}

func newInterceptorTestDB(t *testing.T) *gorm.DB {
	t.Helper()

	db, err := gorm.Open(sqlite.Open(":memory:"), &gorm.Config{Logger: logger.Discard})
	if err != nil {
		t.Fatalf("failed to open test database: %v", err)
	}
	if err := database.AutoMigrate(db); err != nil {
		t.Fatalf("failed to migrate test database: %v", err)
	}

	return db
}

// contextWithPeer returns a context carrying a peer address, which is what the
// interceptor reads the caller's IP from.
func contextWithPeer(address string) context.Context {
	return peer.NewContext(context.Background(), &peer.Peer{
		Addr: &net.TCPAddr{IP: net.ParseIP(address), Port: 41234},
	})
}

func TestDummyInterceptorInjectsTheLocalUser(t *testing.T) {
	var got uint
	handler := func(ctx context.Context, _ any) (any, error) {
		got, _ = ctx.Value(contextKeyUser{}).(uint)
		return nil, nil
	}

	if _, err := DummyAuthenticationInterceptor(context.Background(), nil, &grpc.UnaryServerInfo{}, handler); err != nil {
		t.Fatalf("expected the interceptor to succeed but got %v", err)
	}
	if got != dummyUserID {
		t.Errorf("expected user %d but got %d", dummyUserID, got)
	}
}

func TestTailscaleInterceptorCreatesAndSeedsTheUser(t *testing.T) {
	db := newInterceptorTestDB(t)
	interceptor := NewTailscaleAuthenticationInterceptor(db, &fakeIdentityLookup{loginName: "someone@example.com"})

	var got uint
	handler := func(ctx context.Context, _ any) (any, error) {
		got, _ = ctx.Value(contextKeyUser{}).(uint)
		return nil, nil
	}

	ctx := contextWithPeer("100.64.0.1")
	if _, err := interceptor.Intercept(ctx, nil, &grpc.UnaryServerInfo{}, handler); err != nil {
		t.Fatalf("expected the interceptor to succeed but got %v", err)
	}
	if got == 0 {
		t.Fatal("expected a user to be injected")
	}

	// A user without the catalogue cannot challenge a record, since the bias
	// names would not resolve. Seeding therefore has to happen at first sight,
	// not on first use.
	biases, err := database.ListBiases(db, got)
	if err != nil {
		t.Fatalf("failed to list the biases: %v", err)
	}
	if len(biases) != len(database.BuiltinBiasNames) {
		t.Errorf("expected %d seeded biases but got %d", len(database.BuiltinBiasNames), len(biases))
	}
}

func TestTailscaleInterceptorCachesTheAddress(t *testing.T) {
	db := newInterceptorTestDB(t)
	lookup := &fakeIdentityLookup{loginName: "someone@example.com"}
	interceptor := NewTailscaleAuthenticationInterceptor(db, lookup)

	handler := func(context.Context, any) (any, error) { return nil, nil }
	ctx := contextWithPeer("100.64.0.1")

	if _, err := interceptor.Intercept(ctx, nil, &grpc.UnaryServerInfo{}, handler); err != nil {
		t.Fatalf("the first call failed: %v", err)
	}

	// The second call must be served from the address cache. Making the lookup
	// fail proves WhoIs is not consulted again.
	lookup.err = errors.New("WhoIs must not be called again")
	if _, err := interceptor.Intercept(ctx, nil, &grpc.UnaryServerInfo{}, handler); err != nil {
		t.Errorf("expected the cached address to be used but got %v", err)
	}
}

func TestTailscaleInterceptorRejectsAnUnknownCaller(t *testing.T) {
	db := newInterceptorTestDB(t)
	interceptor := NewTailscaleAuthenticationInterceptor(db, &fakeIdentityLookup{err: errors.New("no such peer")})

	handler := func(context.Context, any) (any, error) { return nil, nil }
	_, err := interceptor.Intercept(contextWithPeer("100.64.0.9"), nil, &grpc.UnaryServerInfo{}, handler)

	if status.Code(err) != codes.Unauthenticated {
		t.Errorf("expected Unauthenticated but got %v", status.Code(err))
	}
}

func TestTailscaleInterceptorRejectsAMissingPeer(t *testing.T) {
	db := newInterceptorTestDB(t)
	interceptor := NewTailscaleAuthenticationInterceptor(db, &fakeIdentityLookup{loginName: "someone@example.com"})

	handler := func(context.Context, any) (any, error) { return nil, nil }
	_, err := interceptor.Intercept(context.Background(), nil, &grpc.UnaryServerInfo{}, handler)

	if status.Code(err) != codes.Internal {
		t.Errorf("expected Internal but got %v", status.Code(err))
	}
}

func TestRecordingHelpersTolerateAMissingMeter(t *testing.T) {
	// Telemetry is optional: a missing meter must never panic the request
	// path, so every recording site no-ops on a nil handle.
	appMetrics = nil

	recordAuthAttempt(context.Background(), "dummy", "success")
	recordCreated(context.Background(), recordTypeThoughtRecord)
	recordChallengeLatency(context.Background(), 12)
}
