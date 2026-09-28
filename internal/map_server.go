package internal

import (
	"context"
	"log/slog"

	"github.com/alexhokl/cbt/database"
	"github.com/alexhokl/cbt/proto"
	"google.golang.org/protobuf/types/known/emptypb"
)

// ListMapsOfWorry returns the user's maps of worry, most recent event first.
func (s *RecordServer) ListMapsOfWorry(ctx context.Context, req *proto.ListMapsOfWorryRequest) (*proto.ListMapsOfWorryResponse, error) {
	ctx, span := startSpan(ctx, "ListMapsOfWorry")
	defer span.End()

	userID, err := userIDFromContext(ctx)
	if err != nil {
		return nil, err
	}

	maps, err := database.ListMapsOfWorry(s.DB.WithContext(ctx), userID, database.MapOfWorryFilter{
		Since:  fromProtoTimestamp(req.GetSince()),
		Search: req.GetSearch(),
	})
	if err != nil {
		return nil, mapDatabaseError(err)
	}

	converted, err := toProtoMapsOfWorry(maps)
	if err != nil {
		return nil, err
	}

	endSpanOk(span)

	return &proto.ListMapsOfWorryResponse{Maps: converted}, nil
}

// CreateMapOfWorry creates a map, optionally as an alternative reworking of an
// existing one.
func (s *RecordServer) CreateMapOfWorry(ctx context.Context, req *proto.CreateMapOfWorryRequest) (*proto.MapOfWorry, error) {
	ctx, span := startSpan(ctx, "CreateMapOfWorry")
	defer span.End()

	userID, err := userIDFromContext(ctx)
	if err != nil {
		return nil, err
	}

	var derivedFromID *uint
	if req.DerivedFromId != nil {
		id := uint(req.GetDerivedFromId())
		derivedFromID = &id
	}

	mapOfWorry, err := database.CreateMapOfWorry(s.DB.WithContext(ctx), userID, database.CreateMapOfWorryInput{
		Event:                 req.GetEvent(),
		OccurredAt:            fromProtoTimestamp(req.GetOccurredAt()),
		Thoughts:              req.GetThoughts(),
		WhatTheseThoughtsMean: req.GetWhatTheseThoughtsMean(),
		PhysicalSensations:    req.GetPhysicalSensations(),
		ResultantBehaviour:    req.GetResultantBehaviour(),
		DerivedFromID:         derivedFromID,
		Feelings:              toFeelingInputs(req.GetFeelings()),
	})
	if err != nil {
		return nil, mapDatabaseError(err)
	}

	recordCreated(ctx, recordTypeMapOfWorry)
	slog.InfoContext(ctx, "map of worry created",
		slog.Uint64("map_id", uint64(mapOfWorry.ID)),
		slog.Bool("is_alternative", mapOfWorry.DerivedFromID != nil),
	)

	converted, err := toProtoMapOfWorry(mapOfWorry)
	if err != nil {
		return nil, err
	}

	endSpanOk(span)

	return converted, nil
}

// GetMapOfWorry returns a map together with the maps it should be read
// against: the one it reworks, and the reworkings of it. They are returned as
// sibling fields rather than nested inside the map so the client can render
// them side by side, which is the point of recording the link at all.
func (s *RecordServer) GetMapOfWorry(ctx context.Context, req *proto.GetMapOfWorryRequest) (*proto.GetMapOfWorryResponse, error) {
	ctx, span := startSpan(ctx, "GetMapOfWorry")
	defer span.End()

	userID, err := userIDFromContext(ctx)
	if err != nil {
		return nil, err
	}

	mapOfWorry, err := database.GetMapOfWorry(s.DB.WithContext(ctx), userID, uint(req.GetId()))
	if err != nil {
		return nil, mapDatabaseError(err)
	}

	converted, err := toProtoMapOfWorry(mapOfWorry)
	if err != nil {
		return nil, err
	}

	response := &proto.GetMapOfWorryResponse{Map: converted}

	if mapOfWorry.DerivedFrom != nil {
		derivedFrom, err := toProtoMapOfWorry(mapOfWorry.DerivedFrom)
		if err != nil {
			return nil, err
		}
		response.DerivedFrom = derivedFrom
	}

	alternatives, err := database.ListAlternatives(s.DB.WithContext(ctx), userID, uint(req.GetId()))
	if err != nil {
		return nil, mapDatabaseError(err)
	}
	convertedAlternatives, err := toProtoMapsOfWorry(alternatives)
	if err != nil {
		return nil, err
	}
	response.Alternatives = convertedAlternatives

	endSpanOk(span)

	return response, nil
}

// UpdateMapOfWorry changes the free text columns of a map.
func (s *RecordServer) UpdateMapOfWorry(ctx context.Context, req *proto.UpdateMapOfWorryRequest) (*proto.MapOfWorry, error) {
	ctx, span := startSpan(ctx, "UpdateMapOfWorry")
	defer span.End()

	userID, err := userIDFromContext(ctx)
	if err != nil {
		return nil, err
	}

	mapOfWorry, err := database.UpdateMapOfWorry(s.DB.WithContext(ctx), userID, uint(req.GetId()), database.UpdateMapOfWorryInput{
		Event:                 req.Event,
		OccurredAt:            fromProtoTimestamp(req.GetOccurredAt()),
		ClearOccurredAt:       req.GetClearOccurredAt(),
		Thoughts:              req.Thoughts,
		WhatTheseThoughtsMean: req.WhatTheseThoughtsMean,
		PhysicalSensations:    req.PhysicalSensations,
		ResultantBehaviour:    req.ResultantBehaviour,
	})
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

// DeleteMapOfWorry removes a map along with its feelings.
func (s *RecordServer) DeleteMapOfWorry(ctx context.Context, req *proto.DeleteMapOfWorryRequest) (*emptypb.Empty, error) {
	ctx, span := startSpan(ctx, "DeleteMapOfWorry")
	defer span.End()

	userID, err := userIDFromContext(ctx)
	if err != nil {
		return nil, err
	}

	if err := database.DeleteMapOfWorry(s.DB.WithContext(ctx), userID, uint(req.GetId())); err != nil {
		return nil, mapDatabaseError(err)
	}

	slog.InfoContext(ctx, "map of worry deleted",
		slog.Uint64("map_id", uint64(req.GetId())),
	)

	endSpanOk(span)

	return &emptypb.Empty{}, nil
}
