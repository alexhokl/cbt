package internal

import (
	"context"

	"google.golang.org/grpc"
)

// dummyUserID is the user injected when Tailscale authentication is not
// enabled. It matches the first user created by a fresh database, so a local
// server behaves exactly like an authenticated one from the handlers' point of
// view.
const dummyUserID = uint(1)

// DummyAuthenticationInterceptor is a placeholder for an authentication
// interceptor, used when Tailscale authentication is not enabled. It injects a
// fixed user identifier so the rest of the request handling is identical to
// the authenticated path.
func DummyAuthenticationInterceptor(
	ctx context.Context,
	req any,
	info *grpc.UnaryServerInfo,
	handler grpc.UnaryHandler,
) (any, error) {
	ctx = context.WithValue(ctx, contextKeyUser{}, dummyUserID)
	resp, err := handler(ctx, req)
	if err != nil {
		recordAuthAttempt(ctx, "dummy", "failure")
	} else {
		recordAuthAttempt(ctx, "dummy", "success")
	}
	return resp, err
}

// DummyStreamAuthenticationInterceptor is a placeholder for a streaming
// authentication interceptor, used when Tailscale authentication is not
// enabled.
func DummyStreamAuthenticationInterceptor(
	srv any,
	ss grpc.ServerStream,
	info *grpc.StreamServerInfo,
	handler grpc.StreamHandler,
) error {
	ctx := context.WithValue(ss.Context(), contextKeyUser{}, dummyUserID)
	wrapped := &wrappedServerStream{ServerStream: ss, ctx: ctx}
	return handler(srv, wrapped)
}

// wrappedServerStream wraps a grpc.ServerStream to override the context.
type wrappedServerStream struct {
	grpc.ServerStream
	ctx context.Context
}

func (w *wrappedServerStream) Context() context.Context {
	return w.ctx
}
