package internal

import (
	"context"

	"github.com/alexhokl/cbt/database"
	"github.com/alexhokl/cbt/proto"
	"google.golang.org/protobuf/types/known/emptypb"
)

// AddFeeling attaches a rated feeling to a thought record.
func (s *RecordServer) AddFeeling(ctx context.Context, req *proto.AddFeelingRequest) (*proto.ThoughtRecord, error) {
	ctx, span := startSpan(ctx, "AddFeeling")
	defer span.End()

	userID, err := userIDFromContext(ctx)
	if err != nil {
		return nil, err
	}

	inputs := toFeelingInputs([]*proto.FeelingInput{req.GetFeeling()})
	record, err := database.AddFeeling(s.DB.WithContext(ctx), userID, uint(req.GetRecordId()), inputs[0])
	if err != nil {
		return nil, mapDatabaseError(err)
	}

	converted, err := toProtoThoughtRecord(record)
	if err != nil {
		return nil, err
	}

	endSpanOk(span)

	return converted, nil
}

// AddMapFeeling attaches a rated feeling to a map of worry.
func (s *RecordServer) AddMapFeeling(ctx context.Context, req *proto.AddMapFeelingRequest) (*proto.MapOfWorry, error) {
	ctx, span := startSpan(ctx, "AddMapFeeling")
	defer span.End()

	userID, err := userIDFromContext(ctx)
	if err != nil {
		return nil, err
	}

	inputs := toFeelingInputs([]*proto.FeelingInput{req.GetFeeling()})
	mapOfWorry, err := database.AddMapFeeling(s.DB.WithContext(ctx), userID, uint(req.GetMapId()), inputs[0])
	if err != nil {
		return nil, mapDatabaseError(err)
	}

	converted, err := toProtoMapOfWorry(mapOfWorry)
	if err != nil {
		return nil, err
	}

	endSpanOk(span)

	return converted, nil
}

// DeleteFeeling removes a feeling from whichever record it belongs to.
func (s *RecordServer) DeleteFeeling(ctx context.Context, req *proto.DeleteFeelingRequest) (*emptypb.Empty, error) {
	ctx, span := startSpan(ctx, "DeleteFeeling")
	defer span.End()

	userID, err := userIDFromContext(ctx)
	if err != nil {
		return nil, err
	}

	if err := database.DeleteFeeling(s.DB.WithContext(ctx), userID, uint(req.GetId())); err != nil {
		return nil, mapDatabaseError(err)
	}

	endSpanOk(span)

	return &emptypb.Empty{}, nil
}
