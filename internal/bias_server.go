package internal

import (
	"context"

	"github.com/alexhokl/cbt/database"
	"github.com/alexhokl/cbt/proto"
	"google.golang.org/protobuf/types/known/emptypb"
)

// ListBiases returns the user's cognitive bias vocabulary, ordered by name.
func (s *RecordServer) ListBiases(ctx context.Context, _ *proto.ListBiasesRequest) (*proto.ListBiasesResponse, error) {
	ctx, span := startSpan(ctx, "ListBiases")
	defer span.End()

	userID, err := userIDFromContext(ctx)
	if err != nil {
		return nil, err
	}

	biases, err := database.ListBiases(s.DB.WithContext(ctx), userID)
	if err != nil {
		return nil, mapDatabaseError(err)
	}

	converted, err := toProtoBiases(biases)
	if err != nil {
		return nil, err
	}

	endSpanOk(span)

	return &proto.ListBiasesResponse{Biases: converted}, nil
}

// CreateBias adds a user defined bias alongside the seeded ones.
func (s *RecordServer) CreateBias(ctx context.Context, req *proto.CreateBiasRequest) (*proto.CognitiveBias, error) {
	ctx, span := startSpan(ctx, "CreateBias")
	defer span.End()

	userID, err := userIDFromContext(ctx)
	if err != nil {
		return nil, err
	}

	bias, err := database.CreateBias(s.DB.WithContext(ctx), userID, req.GetName())
	if err != nil {
		return nil, mapDatabaseError(err)
	}

	converted, err := toProtoBias(*bias)
	if err != nil {
		return nil, err
	}

	endSpanOk(span)

	return converted, nil
}

// RenameBias renames a user defined bias. Builtin biases are rejected, since
// the seeded names are how a record is read back against the source material.
func (s *RecordServer) RenameBias(ctx context.Context, req *proto.RenameBiasRequest) (*proto.CognitiveBias, error) {
	ctx, span := startSpan(ctx, "RenameBias")
	defer span.End()

	userID, err := userIDFromContext(ctx)
	if err != nil {
		return nil, err
	}

	bias, err := database.RenameBias(s.DB.WithContext(ctx), userID, uint(req.GetId()), req.GetName())
	if err != nil {
		return nil, mapDatabaseError(err)
	}

	converted, err := toProtoBias(*bias)
	if err != nil {
		return nil, err
	}

	endSpanOk(span)

	return converted, nil
}

// DeleteBias removes a user defined bias that is no longer in use.
func (s *RecordServer) DeleteBias(ctx context.Context, req *proto.DeleteBiasRequest) (*emptypb.Empty, error) {
	ctx, span := startSpan(ctx, "DeleteBias")
	defer span.End()

	userID, err := userIDFromContext(ctx)
	if err != nil {
		return nil, err
	}

	if err := database.DeleteBias(s.DB.WithContext(ctx), userID, uint(req.GetId())); err != nil {
		return nil, mapDatabaseError(err)
	}

	endSpanOk(span)

	return &emptypb.Empty{}, nil
}
