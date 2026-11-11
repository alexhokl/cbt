package internal

import (
	"context"
	"log/slog"

	"github.com/alexhokl/cbt/database"
	"github.com/alexhokl/cbt/proto"
	"google.golang.org/protobuf/types/known/emptypb"
)

// ListPositiveDataLogs returns the user's positive data logs, the most
// recently added to first.
func (s *RecordServer) ListPositiveDataLogs(ctx context.Context, req *proto.ListPositiveDataLogsRequest) (*proto.ListPositiveDataLogsResponse, error) {
	ctx, span := startSpan(ctx, "ListPositiveDataLogs")
	defer span.End()

	userID, err := userIDFromContext(ctx)
	if err != nil {
		return nil, err
	}

	logs, err := database.ListPositiveDataLogs(s.DB.WithContext(ctx), userID, database.PositiveDataLogFilter{
		Search: req.GetSearch(),
	})
	if err != nil {
		return nil, mapDatabaseError(err)
	}

	converted, err := toProtoPositiveDataLogs(logs)
	if err != nil {
		return nil, err
	}

	endSpanOk(span)

	return &proto.ListPositiveDataLogsResponse{Logs: converted}, nil
}

// CreatePositiveDataLog creates a log with its first rating and any evidence
// supplied up front.
func (s *RecordServer) CreatePositiveDataLog(ctx context.Context, req *proto.CreatePositiveDataLogRequest) (*proto.PositiveDataLog, error) {
	ctx, span := startSpan(ctx, "CreatePositiveDataLog")
	defer span.End()

	userID, err := userIDFromContext(ctx)
	if err != nil {
		return nil, err
	}

	evidence := make([]database.DataLogEvidenceInput, 0, len(req.GetEvidence()))
	for _, row := range req.GetEvidence() {
		evidence = append(evidence, toDataLogEvidenceInput(row))
	}

	log, err := database.CreatePositiveDataLog(s.DB.WithContext(ctx), userID, database.CreatePositiveDataLogInput{
		Belief:            req.GetBelief(),
		AlternativeBelief: req.GetAlternativeBelief(),
		Rating: database.BeliefRatingInput{
			BeliefPercent:      fromProtoIntensity(req.BeliefPercent),
			AlternativePercent: fromProtoIntensity(req.AlternativePercent),
		},
		Evidence: evidence,
	})
	if err != nil {
		return nil, mapDatabaseError(err)
	}

	recordCreated(ctx, recordTypePositiveDataLog)
	slog.InfoContext(ctx, "positive data log created",
		slog.Uint64("data_log_id", uint64(log.ID)),
		slog.Int("evidence_count", len(log.Evidence)),
		slog.Int("rating_count", len(log.Ratings)),
	)

	converted, err := toProtoPositiveDataLog(log)
	if err != nil {
		return nil, err
	}

	endSpanOk(span)

	return converted, nil
}

// GetPositiveDataLog returns a single log by identifier.
func (s *RecordServer) GetPositiveDataLog(ctx context.Context, req *proto.GetPositiveDataLogRequest) (*proto.PositiveDataLog, error) {
	ctx, span := startSpan(ctx, "GetPositiveDataLog")
	defer span.End()

	userID, err := userIDFromContext(ctx)
	if err != nil {
		return nil, err
	}

	log, err := database.GetPositiveDataLog(s.DB.WithContext(ctx), userID, uint(req.GetId()))
	if err != nil {
		return nil, mapDatabaseError(err)
	}

	converted, err := toProtoPositiveDataLog(log)
	if err != nil {
		return nil, err
	}

	endSpanOk(span)

	return converted, nil
}

// UpdatePositiveDataLog rewords the beliefs of a log.
func (s *RecordServer) UpdatePositiveDataLog(ctx context.Context, req *proto.UpdatePositiveDataLogRequest) (*proto.PositiveDataLog, error) {
	ctx, span := startSpan(ctx, "UpdatePositiveDataLog")
	defer span.End()

	userID, err := userIDFromContext(ctx)
	if err != nil {
		return nil, err
	}

	log, err := database.UpdatePositiveDataLog(s.DB.WithContext(ctx), userID, uint(req.GetId()), database.UpdatePositiveDataLogInput{
		Belief:            req.Belief,
		AlternativeBelief: req.AlternativeBelief,
	})
	if err != nil {
		return nil, mapDatabaseError(err)
	}

	converted, err := toProtoPositiveDataLog(log)
	if err != nil {
		return nil, err
	}

	endSpanOk(span)

	return converted, nil
}

// DeletePositiveDataLog removes a log along with its evidence and ratings.
func (s *RecordServer) DeletePositiveDataLog(ctx context.Context, req *proto.DeletePositiveDataLogRequest) (*emptypb.Empty, error) {
	ctx, span := startSpan(ctx, "DeletePositiveDataLog")
	defer span.End()

	userID, err := userIDFromContext(ctx)
	if err != nil {
		return nil, err
	}

	if err := database.DeletePositiveDataLog(s.DB.WithContext(ctx), userID, uint(req.GetId())); err != nil {
		return nil, mapDatabaseError(err)
	}

	slog.InfoContext(ctx, "positive data log deleted",
		slog.Uint64("data_log_id", uint64(req.GetId())),
	)

	endSpanOk(span)

	return &emptypb.Empty{}, nil
}

// AddDataLogEvidence appends a row of evidence to a log.
func (s *RecordServer) AddDataLogEvidence(ctx context.Context, req *proto.AddDataLogEvidenceRequest) (*proto.PositiveDataLog, error) {
	ctx, span := startSpan(ctx, "AddDataLogEvidence")
	defer span.End()

	userID, err := userIDFromContext(ctx)
	if err != nil {
		return nil, err
	}

	log, err := database.AddDataLogEvidence(s.DB.WithContext(ctx), userID, uint(req.GetLogId()), toDataLogEvidenceInput(req.GetEvidence()))
	if err != nil {
		return nil, mapDatabaseError(err)
	}

	slog.InfoContext(ctx, "evidence added to positive data log",
		slog.Uint64("data_log_id", uint64(log.ID)),
		slog.Int("evidence_count", len(log.Evidence)),
	)

	converted, err := toProtoPositiveDataLog(log)
	if err != nil {
		return nil, err
	}

	endSpanOk(span)

	return converted, nil
}

// DeleteDataLogEvidence removes a row of evidence and returns its log.
func (s *RecordServer) DeleteDataLogEvidence(ctx context.Context, req *proto.DeleteDataLogEvidenceRequest) (*proto.PositiveDataLog, error) {
	ctx, span := startSpan(ctx, "DeleteDataLogEvidence")
	defer span.End()

	userID, err := userIDFromContext(ctx)
	if err != nil {
		return nil, err
	}

	log, err := database.DeleteDataLogEvidence(s.DB.WithContext(ctx), userID, uint(req.GetId()))
	if err != nil {
		return nil, mapDatabaseError(err)
	}

	slog.InfoContext(ctx, "evidence deleted from positive data log",
		slog.Uint64("data_log_id", uint64(log.ID)),
		slog.Uint64("evidence_id", uint64(req.GetId())),
	)

	converted, err := toProtoPositiveDataLog(log)
	if err != nil {
		return nil, err
	}

	endSpanOk(span)

	return converted, nil
}

// RateBeliefs appends a rating of both beliefs to a log.
func (s *RecordServer) RateBeliefs(ctx context.Context, req *proto.RateBeliefsRequest) (*proto.PositiveDataLog, error) {
	ctx, span := startSpan(ctx, "RateBeliefs")
	defer span.End()

	userID, err := userIDFromContext(ctx)
	if err != nil {
		return nil, err
	}

	log, err := database.RateBeliefs(s.DB.WithContext(ctx), userID, uint(req.GetLogId()), database.BeliefRatingInput{
		BeliefPercent:      fromProtoIntensity(req.BeliefPercent),
		AlternativePercent: fromProtoIntensity(req.AlternativePercent),
	})
	if err != nil {
		return nil, mapDatabaseError(err)
	}

	// The percentages themselves are record content and stay out of the log.
	slog.InfoContext(ctx, "positive data log rated",
		slog.Uint64("data_log_id", uint64(log.ID)),
		slog.Int("rating_count", len(log.Ratings)),
	)

	converted, err := toProtoPositiveDataLog(log)
	if err != nil {
		return nil, err
	}

	endSpanOk(span)

	return converted, nil
}
