package internal

import (
	"math"
	"time"

	"github.com/alexhokl/cbt/database"
	"github.com/alexhokl/cbt/proto"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
	"google.golang.org/protobuf/types/known/timestamppb"
)

// toProtoID narrows a database identifier to the 32 bit width used on the
// wire. Identifiers are assigned by SQLite and will not realistically reach
// this bound, but a silent truncation would hand the client a valid looking
// identifier pointing at the wrong record, so it is reported instead.
func toProtoID(id uint) (uint32, error) {
	if uint64(id) > math.MaxUint32 {
		return 0, status.Errorf(codes.Internal, "identifier %d is too large to represent", id)
	}
	return uint32(id), nil
}

// toProtoIntensity narrows an optional rating to the 32 bit width used on the
// wire. Ratings are constrained to 0-100 by both the operations and a trigger,
// so no range check is repeated here.
func toProtoIntensity(intensity *int) *int32 {
	if intensity == nil {
		return nil
	}
	// The value cannot overflow: an intensity is a percentage, held to 0-100
	// by validateIntensity in the operations and by the feelings_intensity_range
	// trigger in the schema, so anything reaching here is already in range.
	narrowed := int32(*intensity) // #nosec G115
	return &narrowed
}

// fromProtoIntensity widens an optional wire rating to the operation input
// type, leaving an absent rating nil so "not rated" stays distinct from "rated
// zero".
func fromProtoIntensity(intensity *int32) *int {
	if intensity == nil {
		return nil
	}
	widened := int(*intensity)
	return &widened
}

// toProtoTimestamp converts an optional time to its wire representation,
// leaving a nil time absent rather than rendering the zero time.
func toProtoTimestamp(value *time.Time) *timestamppb.Timestamp {
	if value == nil {
		return nil
	}
	return timestamppb.New(*value)
}

// fromProtoTimestamp converts an optional wire timestamp back to a time,
// leaving an absent timestamp nil.
func fromProtoTimestamp(value *timestamppb.Timestamp) *time.Time {
	if value == nil {
		return nil
	}
	converted := value.AsTime()
	return &converted
}

// toProtoBias converts a cognitive bias to its wire representation.
func toProtoBias(bias database.CognitiveBias) (*proto.CognitiveBias, error) {
	id, err := toProtoID(bias.ID)
	if err != nil {
		return nil, err
	}

	return &proto.CognitiveBias{
		Id:        id,
		Name:      bias.Name,
		IsBuiltin: bias.IsBuiltin,
	}, nil
}

// toProtoBiases converts a list of cognitive biases to their wire
// representation.
func toProtoBiases(biases []database.CognitiveBias) ([]*proto.CognitiveBias, error) {
	converted := make([]*proto.CognitiveBias, 0, len(biases))
	for _, bias := range biases {
		protoBias, err := toProtoBias(bias)
		if err != nil {
			return nil, err
		}
		converted = append(converted, protoBias)
	}

	return converted, nil
}

// toProtoThought converts a negative thought and the biases attached to it.
func toProtoThought(thought database.NegativeThought) (*proto.NegativeThought, error) {
	id, err := toProtoID(thought.ID)
	if err != nil {
		return nil, err
	}

	biases, err := toProtoBiases(thought.Biases)
	if err != nil {
		return nil, err
	}

	converted := &proto.NegativeThought{
		Id:        id,
		Body:      thought.Body,
		IsHot:     thought.IsHot,
		IsFactual: thought.IsFactual,
		Biases:    biases,
	}

	if thought.ParentID != nil {
		parentID, err := toProtoID(*thought.ParentID)
		if err != nil {
			return nil, err
		}
		converted.ParentId = &parentID
	}

	return converted, nil
}

// toProtoFeeling converts a rated feeling to its wire representation.
func toProtoFeeling(feeling database.Feeling) (*proto.Feeling, error) {
	id, err := toProtoID(feeling.ID)
	if err != nil {
		return nil, err
	}

	return &proto.Feeling{
		Id:              id,
		Name:            feeling.Name,
		IntensityBefore: toProtoIntensity(feeling.IntensityBefore),
		IntensityAfter:  toProtoIntensity(feeling.IntensityAfter),
	}, nil
}

// toProtoFeelings converts a list of feelings to their wire representation.
func toProtoFeelings(feelings []database.Feeling) ([]*proto.Feeling, error) {
	converted := make([]*proto.Feeling, 0, len(feelings))
	for _, feeling := range feelings {
		protoFeeling, err := toProtoFeeling(feeling)
		if err != nil {
			return nil, err
		}
		converted = append(converted, protoFeeling)
	}

	return converted, nil
}

// toProtoThoughtRecord converts a thought record together with its thoughts
// and feelings.
func toProtoThoughtRecord(record *database.ThoughtRecord) (*proto.ThoughtRecord, error) {
	if record == nil {
		return nil, status.Error(codes.Internal, "thought record is missing")
	}

	id, err := toProtoID(record.ID)
	if err != nil {
		return nil, err
	}

	thoughts := make([]*proto.NegativeThought, 0, len(record.Thoughts))
	for _, thought := range record.Thoughts {
		protoThought, err := toProtoThought(thought)
		if err != nil {
			return nil, err
		}
		thoughts = append(thoughts, protoThought)
	}

	feelings, err := toProtoFeelings(record.Feelings)
	if err != nil {
		return nil, err
	}

	return &proto.ThoughtRecord{
		Id:              id,
		Event:           record.Event,
		OccurredAt:      toProtoTimestamp(record.OccurredAt),
		AlternativeView: record.AlternativeView,
		FeelingsNow:     record.FeelingsNow,
		ChallengedAt:    toProtoTimestamp(record.ChallengedAt),
		Thoughts:        thoughts,
		Feelings:        feelings,
		CreatedAt:       timestamppb.New(record.CreatedAt),
		UpdatedAt:       timestamppb.New(record.UpdatedAt),
	}, nil
}

// toProtoThoughtRecords converts a list of thought records.
func toProtoThoughtRecords(records []database.ThoughtRecord) ([]*proto.ThoughtRecord, error) {
	converted := make([]*proto.ThoughtRecord, 0, len(records))
	for index := range records {
		protoRecord, err := toProtoThoughtRecord(&records[index])
		if err != nil {
			return nil, err
		}
		converted = append(converted, protoRecord)
	}

	return converted, nil
}

// toProtoMapOfWorry converts a map of worry together with its feelings. The
// map it was derived from is not inlined: GetMapOfWorry returns it as a
// sibling field so the client can render the two side by side without
// unbounded nesting.
func toProtoMapOfWorry(mapOfWorry *database.MapOfWorry) (*proto.MapOfWorry, error) {
	if mapOfWorry == nil {
		return nil, status.Error(codes.Internal, "map of worry is missing")
	}

	id, err := toProtoID(mapOfWorry.ID)
	if err != nil {
		return nil, err
	}

	feelings, err := toProtoFeelings(mapOfWorry.Feelings)
	if err != nil {
		return nil, err
	}

	converted := &proto.MapOfWorry{
		Id:                    id,
		Event:                 mapOfWorry.Event,
		OccurredAt:            toProtoTimestamp(mapOfWorry.OccurredAt),
		Thoughts:              mapOfWorry.Thoughts,
		WhatTheseThoughtsMean: mapOfWorry.WhatTheseThoughtsMean,
		PhysicalSensations:    mapOfWorry.PhysicalSensations,
		ResultantBehaviour:    mapOfWorry.ResultantBehaviour,
		Feelings:              feelings,
		CreatedAt:             timestamppb.New(mapOfWorry.CreatedAt),
		UpdatedAt:             timestamppb.New(mapOfWorry.UpdatedAt),
	}

	if mapOfWorry.DerivedFromID != nil {
		derivedFromID, err := toProtoID(*mapOfWorry.DerivedFromID)
		if err != nil {
			return nil, err
		}
		converted.DerivedFromId = &derivedFromID
	}

	return converted, nil
}

// toProtoMapsOfWorry converts a list of maps of worry.
func toProtoMapsOfWorry(maps []database.MapOfWorry) ([]*proto.MapOfWorry, error) {
	converted := make([]*proto.MapOfWorry, 0, len(maps))
	for index := range maps {
		protoMap, err := toProtoMapOfWorry(&maps[index])
		if err != nil {
			return nil, err
		}
		converted = append(converted, protoMap)
	}

	return converted, nil
}

// toFeelingInputs converts wire feelings to the operation input type.
func toFeelingInputs(inputs []*proto.FeelingInput) []database.FeelingInput {
	converted := make([]database.FeelingInput, 0, len(inputs))
	for _, input := range inputs {
		converted = append(converted, database.FeelingInput{
			Name:      input.GetName(),
			Intensity: fromProtoIntensity(input.Intensity),
		})
	}

	return converted
}

// toThoughtInputs converts wire thoughts to the operation input type.
func toThoughtInputs(inputs []*proto.ThoughtInput) []database.ThoughtInput {
	converted := make([]database.ThoughtInput, 0, len(inputs))
	for _, input := range inputs {
		converted = append(converted, database.ThoughtInput{
			Body:   input.GetBody(),
			IsHot:  input.GetIsHot(),
			Biases: input.GetBiases(),
		})
	}

	return converted
}
