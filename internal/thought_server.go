package internal

import (
	"context"
	"log/slog"

	"github.com/alexhokl/cbt/database"
	"github.com/alexhokl/cbt/proto"
)

// AddThought attaches a further negative thought to a record.
func (s *RecordServer) AddThought(ctx context.Context, req *proto.AddThoughtRequest) (*proto.ThoughtRecord, error) {
	ctx, span := startSpan(ctx, "AddThought")
	defer span.End()

	userID, err := userIDFromContext(ctx)
	if err != nil {
		return nil, err
	}

	inputs := toThoughtInputs([]*proto.ThoughtInput{req.GetThought()})
	record, err := database.AddThought(s.DB.WithContext(ctx), userID, uint(req.GetRecordId()), inputs[0])
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

// UpdateThought changes the wording of a thought and, optionally, the biases
// attached to it.
func (s *RecordServer) UpdateThought(ctx context.Context, req *proto.UpdateThoughtRequest) (*proto.ThoughtRecord, error) {
	ctx, span := startSpan(ctx, "UpdateThought")
	defer span.End()

	userID, err := userIDFromContext(ctx)
	if err != nil {
		return nil, err
	}

	// A nil slice means "leave the biases alone" and an empty non-nil slice
	// means "detach them all", so the wrapper's presence is what decides,
	// not the length of the list inside it.
	var biases []string
	if req.Biases != nil {
		biases = req.GetBiases().GetNames()
		if biases == nil {
			biases = []string{}
		}
	}

	record, err := database.UpdateThought(s.DB.WithContext(ctx), userID, uint(req.GetId()), req.GetBody(), biases)
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

// SetHotThought marks a thought as the strongest of its record.
func (s *RecordServer) SetHotThought(ctx context.Context, req *proto.SetHotThoughtRequest) (*proto.ThoughtRecord, error) {
	ctx, span := startSpan(ctx, "SetHotThought")
	defer span.End()

	userID, err := userIDFromContext(ctx)
	if err != nil {
		return nil, err
	}

	record, err := database.SetHotThought(s.DB.WithContext(ctx), userID, uint(req.GetId()))
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

// SetThoughtFactual records whether a thought was judged an accurate reading
// of the situation rather than a distorted one.
func (s *RecordServer) SetThoughtFactual(ctx context.Context, req *proto.SetThoughtFactualRequest) (*proto.ThoughtRecord, error) {
	ctx, span := startSpan(ctx, "SetThoughtFactual")
	defer span.End()

	userID, err := userIDFromContext(ctx)
	if err != nil {
		return nil, err
	}

	record, err := database.SetThoughtFactual(s.DB.WithContext(ctx), userID, uint(req.GetId()), req.GetFactual())
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

// DeleteThought removes a thought from its record. The updated record is
// returned rather than an empty response so the caller does not have to fetch
// it again to redraw.
func (s *RecordServer) DeleteThought(ctx context.Context, req *proto.DeleteThoughtRequest) (*proto.ThoughtRecord, error) {
	ctx, span := startSpan(ctx, "DeleteThought")
	defer span.End()

	userID, err := userIDFromContext(ctx)
	if err != nil {
		return nil, err
	}

	// The record identifier is read before the delete, since afterwards there
	// is nothing left to resolve it from.
	thought, err := database.GetThought(s.DB.WithContext(ctx), userID, uint(req.GetId()))
	if err != nil {
		return nil, mapDatabaseError(err)
	}

	if err := database.DeleteThought(s.DB.WithContext(ctx), userID, uint(req.GetId())); err != nil {
		return nil, mapDatabaseError(err)
	}

	slog.InfoContext(ctx, "thought deleted",
		slog.Uint64("thought_id", uint64(req.GetId())),
		slog.Uint64("record_id", uint64(thought.ThoughtRecordID)),
	)

	record, err := database.GetThoughtRecord(s.DB.WithContext(ctx), userID, thought.ThoughtRecordID)
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
