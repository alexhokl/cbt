package internal

import (
	"context"
	"log/slog"

	"github.com/alexhokl/cbt/database"
	"github.com/alexhokl/cbt/proto"
	"google.golang.org/protobuf/types/known/emptypb"
)

// ListFormulations returns the user's formulations, the most recently changed
// first.
func (s *RecordServer) ListFormulations(ctx context.Context, req *proto.ListFormulationsRequest) (*proto.ListFormulationsResponse, error) {
	ctx, span := startSpan(ctx, "ListFormulations")
	defer span.End()

	userID, err := userIDFromContext(ctx)
	if err != nil {
		return nil, err
	}

	formulations, err := database.ListFormulations(s.DB.WithContext(ctx), userID, database.FormulationFilter{
		Search: req.GetSearch(),
	})
	if err != nil {
		return nil, mapDatabaseError(err)
	}

	converted, err := toProtoFormulations(formulations)
	if err != nil {
		return nil, err
	}

	endSpanOk(span)

	return &proto.ListFormulationsResponse{Formulations: converted}, nil
}

// CreateFormulation creates a formulation from whichever columns are given.
func (s *RecordServer) CreateFormulation(ctx context.Context, req *proto.CreateFormulationRequest) (*proto.Formulation, error) {
	ctx, span := startSpan(ctx, "CreateFormulation")
	defer span.End()

	userID, err := userIDFromContext(ctx)
	if err != nil {
		return nil, err
	}

	formulation, err := database.CreateFormulation(s.DB.WithContext(ctx), userID, database.FormulationInput{
		EarlyExperiences: req.GetEarlyExperiences(),
		Beliefs:          req.GetBeliefs(),
		Assumptions:      req.GetAssumptions(),
		RulesForLiving:   req.GetRulesForLiving(),
		Events:           req.GetEvents(),
		Thoughts:         req.GetThoughts(),
		Behaviours:       req.GetBehaviours(),
	})
	if err != nil {
		return nil, mapDatabaseError(err)
	}

	recordCreated(ctx, recordTypeFormulation)
	slog.InfoContext(ctx, "formulation created",
		slog.Uint64("formulation_id", uint64(formulation.ID)),
	)

	converted, err := toProtoFormulation(formulation)
	if err != nil {
		return nil, err
	}

	endSpanOk(span)

	return converted, nil
}

// GetFormulation returns a single formulation by identifier.
func (s *RecordServer) GetFormulation(ctx context.Context, req *proto.GetFormulationRequest) (*proto.Formulation, error) {
	ctx, span := startSpan(ctx, "GetFormulation")
	defer span.End()

	userID, err := userIDFromContext(ctx)
	if err != nil {
		return nil, err
	}

	formulation, err := database.GetFormulation(s.DB.WithContext(ctx), userID, uint(req.GetId()))
	if err != nil {
		return nil, mapDatabaseError(err)
	}

	converted, err := toProtoFormulation(formulation)
	if err != nil {
		return nil, err
	}

	endSpanOk(span)

	return converted, nil
}

// UpdateFormulation changes the columns of a formulation.
func (s *RecordServer) UpdateFormulation(ctx context.Context, req *proto.UpdateFormulationRequest) (*proto.Formulation, error) {
	ctx, span := startSpan(ctx, "UpdateFormulation")
	defer span.End()

	userID, err := userIDFromContext(ctx)
	if err != nil {
		return nil, err
	}

	formulation, err := database.UpdateFormulation(s.DB.WithContext(ctx), userID, uint(req.GetId()), database.UpdateFormulationInput{
		EarlyExperiences: req.EarlyExperiences,
		Beliefs:          req.Beliefs,
		Assumptions:      req.Assumptions,
		RulesForLiving:   req.RulesForLiving,
		Events:           req.Events,
		Thoughts:         req.Thoughts,
		Behaviours:       req.Behaviours,
	})
	if err != nil {
		return nil, mapDatabaseError(err)
	}

	converted, err := toProtoFormulation(formulation)
	if err != nil {
		return nil, err
	}

	endSpanOk(span)

	return converted, nil
}

// DeleteFormulation removes a formulation.
func (s *RecordServer) DeleteFormulation(ctx context.Context, req *proto.DeleteFormulationRequest) (*emptypb.Empty, error) {
	ctx, span := startSpan(ctx, "DeleteFormulation")
	defer span.End()

	userID, err := userIDFromContext(ctx)
	if err != nil {
		return nil, err
	}

	if err := database.DeleteFormulation(s.DB.WithContext(ctx), userID, uint(req.GetId())); err != nil {
		return nil, mapDatabaseError(err)
	}

	slog.InfoContext(ctx, "formulation deleted",
		slog.Uint64("formulation_id", uint64(req.GetId())),
	)

	endSpanOk(span)

	return &emptypb.Empty{}, nil
}
