package internal

import (
	"context"
	"log/slog"

	"github.com/alexhokl/cbt/database"
	"github.com/alexhokl/cbt/proto"
	"google.golang.org/protobuf/types/known/emptypb"
)

// ListBehaviouralExperiments returns the user's behavioural experiments, most
// recent first.
func (s *RecordServer) ListBehaviouralExperiments(ctx context.Context, req *proto.ListBehaviouralExperimentsRequest) (*proto.ListBehaviouralExperimentsResponse, error) {
	ctx, span := startSpan(ctx, "ListBehaviouralExperiments")
	defer span.End()

	userID, err := userIDFromContext(ctx)
	if err != nil {
		return nil, err
	}

	experiments, err := database.ListBehaviouralExperiments(s.DB.WithContext(ctx), userID, database.BehaviouralExperimentFilter{
		Completed: req.Completed,
		Since:     fromProtoTimestamp(req.GetSince()),
		Search:    req.GetSearch(),
	})
	if err != nil {
		return nil, mapDatabaseError(err)
	}

	converted, err := toProtoBehaviouralExperiments(experiments)
	if err != nil {
		return nil, err
	}

	endSpanOk(span)

	return &proto.ListBehaviouralExperimentsResponse{Experiments: converted}, nil
}

// CreateBehaviouralExperiment creates an experiment with its predicted
// feelings.
func (s *RecordServer) CreateBehaviouralExperiment(ctx context.Context, req *proto.CreateBehaviouralExperimentRequest) (*proto.BehaviouralExperiment, error) {
	ctx, span := startSpan(ctx, "CreateBehaviouralExperiment")
	defer span.End()

	userID, err := userIDFromContext(ctx)
	if err != nil {
		return nil, err
	}

	experiment, err := database.CreateBehaviouralExperiment(s.DB.WithContext(ctx), userID, database.CreateBehaviouralExperimentInput{
		Plan:       req.GetPlan(),
		OccurredAt: fromProtoTimestamp(req.GetOccurredAt()),
		Prediction: req.GetPrediction(),
		Feelings:   toFeelingInputs(req.GetFeelings()),
	})
	if err != nil {
		return nil, mapDatabaseError(err)
	}

	recordCreated(ctx, recordTypeBehaviouralExperiment)
	slog.InfoContext(ctx, "behavioural experiment created",
		slog.Uint64("experiment_id", uint64(experiment.ID)),
		slog.Int("feeling_count", len(experiment.Feelings)),
	)

	converted, err := toProtoBehaviouralExperiment(experiment)
	if err != nil {
		return nil, err
	}

	endSpanOk(span)

	return converted, nil
}

// GetBehaviouralExperiment returns a single experiment by identifier.
func (s *RecordServer) GetBehaviouralExperiment(ctx context.Context, req *proto.GetBehaviouralExperimentRequest) (*proto.BehaviouralExperiment, error) {
	ctx, span := startSpan(ctx, "GetBehaviouralExperiment")
	defer span.End()

	userID, err := userIDFromContext(ctx)
	if err != nil {
		return nil, err
	}

	experiment, err := database.GetBehaviouralExperiment(s.DB.WithContext(ctx), userID, uint(req.GetId()))
	if err != nil {
		return nil, mapDatabaseError(err)
	}

	converted, err := toProtoBehaviouralExperiment(experiment)
	if err != nil {
		return nil, err
	}

	endSpanOk(span)

	return converted, nil
}

// UpdateBehaviouralExperiment changes the free text columns of an experiment.
func (s *RecordServer) UpdateBehaviouralExperiment(ctx context.Context, req *proto.UpdateBehaviouralExperimentRequest) (*proto.BehaviouralExperiment, error) {
	ctx, span := startSpan(ctx, "UpdateBehaviouralExperiment")
	defer span.End()

	userID, err := userIDFromContext(ctx)
	if err != nil {
		return nil, err
	}

	experiment, err := database.UpdateBehaviouralExperiment(s.DB.WithContext(ctx), userID, uint(req.GetId()), database.UpdateBehaviouralExperimentInput{
		Plan:            req.Plan,
		OccurredAt:      fromProtoTimestamp(req.GetOccurredAt()),
		ClearOccurredAt: req.GetClearOccurredAt(),
		Prediction:      req.Prediction,
		Outcome:         req.Outcome,
		Learned:         req.Learned,
		BuildOn:         req.BuildOn,
	})
	if err != nil {
		return nil, mapDatabaseError(err)
	}

	converted, err := toProtoBehaviouralExperiment(experiment)
	if err != nil {
		return nil, err
	}

	endSpanOk(span)

	return converted, nil
}

// CompleteBehaviouralExperiment records the second sitting of an experiment.
func (s *RecordServer) CompleteBehaviouralExperiment(ctx context.Context, req *proto.CompleteBehaviouralExperimentRequest) (*proto.BehaviouralExperiment, error) {
	ctx, span := startSpan(ctx, "CompleteBehaviouralExperiment")
	defer span.End()

	userID, err := userIDFromContext(ctx)
	if err != nil {
		return nil, err
	}

	reratings := make(map[uint]int, len(req.GetFeelingReratings()))
	for _, rerating := range req.GetFeelingReratings() {
		reratings[uint(rerating.GetFeelingId())] = int(rerating.GetIntensityAfter())
	}

	experiment, err := database.CompleteBehaviouralExperiment(s.DB.WithContext(ctx), userID, uint(req.GetId()), database.CompleteBehaviouralExperimentInput{
		Outcome:                 req.GetOutcome(),
		Learned:                 req.GetLearned(),
		BuildOn:                 req.GetBuildOn(),
		FeelingIntensitiesAfter: reratings,
		NewFeelings:             toFeelingInputs(req.GetNewFeelings()),
	})
	if err != nil {
		return nil, mapDatabaseError(err)
	}

	slog.InfoContext(ctx, "behavioural experiment completed",
		slog.Uint64("experiment_id", uint64(experiment.ID)),
		slog.Int("rerated_count", len(reratings)),
		slog.Int("new_feeling_count", len(req.GetNewFeelings())),
	)

	converted, err := toProtoBehaviouralExperiment(experiment)
	if err != nil {
		return nil, err
	}

	endSpanOk(span)

	return converted, nil
}

// DeleteBehaviouralExperiment removes an experiment along with its feelings.
func (s *RecordServer) DeleteBehaviouralExperiment(ctx context.Context, req *proto.DeleteBehaviouralExperimentRequest) (*emptypb.Empty, error) {
	ctx, span := startSpan(ctx, "DeleteBehaviouralExperiment")
	defer span.End()

	userID, err := userIDFromContext(ctx)
	if err != nil {
		return nil, err
	}

	if err := database.DeleteBehaviouralExperiment(s.DB.WithContext(ctx), userID, uint(req.GetId())); err != nil {
		return nil, mapDatabaseError(err)
	}

	slog.InfoContext(ctx, "behavioural experiment deleted",
		slog.Uint64("experiment_id", uint64(req.GetId())),
	)

	endSpanOk(span)

	return &emptypb.Empty{}, nil
}
