package internal

import (
	"context"
	"errors"
	"log/slog"

	"github.com/alexhokl/cbt/database"
	"github.com/alexhokl/cbt/proto"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
	"google.golang.org/protobuf/types/known/emptypb"
	"gorm.io/gorm"
)

// RecordServer implements the record gRPC service on top of a GORM database.
//
// Handlers are deliberately thin: they resolve the caller, translate the
// request, delegate to the database package, and translate the result. Every
// invariant lives in the database package so the CLI, the mobile client and
// any future caller are held to the same rules.
type RecordServer struct {
	proto.UnimplementedRecordServiceServer
	DB *gorm.DB
}

// NewRecordServer creates a record service implementation backed by the given
// database connection.
func NewRecordServer(db *gorm.DB) *RecordServer {
	return &RecordServer{DB: db}
}

// userIDFromContext extracts the authenticated user identifier placed in the
// context by the authentication interceptor. Handlers return an
// Unauthenticated status when it is missing so the request is rejected before
// any database access.
func userIDFromContext(ctx context.Context) (uint, error) {
	userID, ok := ctx.Value(contextKeyUser{}).(uint)
	if !ok {
		return 0, status.Error(codes.Unauthenticated, "authentication required")
	}
	return userID, nil
}

// ListThoughtRecords returns the user's thought records, most recent event
// first.
func (s *RecordServer) ListThoughtRecords(ctx context.Context, req *proto.ListThoughtRecordsRequest) (*proto.ListThoughtRecordsResponse, error) {
	ctx, span := startSpan(ctx, "ListThoughtRecords")
	defer span.End()

	userID, err := userIDFromContext(ctx)
	if err != nil {
		return nil, err
	}

	records, err := database.ListThoughtRecords(s.DB.WithContext(ctx), userID, database.ThoughtRecordFilter{
		Challenged: req.Challenged,
		Since:      fromProtoTimestamp(req.GetSince()),
		Search:     req.GetSearch(),
	})
	if err != nil {
		return nil, mapDatabaseError(err)
	}

	converted, err := toProtoThoughtRecords(records)
	if err != nil {
		return nil, err
	}

	endSpanOk(span)

	return &proto.ListThoughtRecordsResponse{Records: converted}, nil
}

// CreateThoughtRecord creates a record together with any thoughts and feelings
// supplied up front.
func (s *RecordServer) CreateThoughtRecord(ctx context.Context, req *proto.CreateThoughtRecordRequest) (*proto.ThoughtRecord, error) {
	ctx, span := startSpan(ctx, "CreateThoughtRecord")
	defer span.End()

	userID, err := userIDFromContext(ctx)
	if err != nil {
		return nil, err
	}

	record, err := database.CreateThoughtRecord(s.DB.WithContext(ctx), userID, database.CreateThoughtRecordInput{
		Event:           req.GetEvent(),
		OccurredAt:      fromProtoTimestamp(req.GetOccurredAt()),
		AlternativeView: req.GetAlternativeView(),
		FeelingsNow:     req.GetFeelingsNow(),
		Thoughts:        toThoughtInputs(req.GetThoughts()),
		Feelings:        toFeelingInputs(req.GetFeelings()),
	})
	if err != nil {
		return nil, mapDatabaseError(err)
	}

	recordCreated(ctx, recordTypeThoughtRecord)
	// Only the identifier and the shape of the record are logged. What the
	// user wrote never leaves the database; see AGENTS.md.
	slog.InfoContext(ctx, "thought record created",
		slog.Uint64("record_id", uint64(record.ID)),
		slog.Int("thoughts", len(record.Thoughts)),
		slog.Int("feelings", len(record.Feelings)),
	)

	converted, err := toProtoThoughtRecord(record)
	if err != nil {
		return nil, err
	}

	endSpanOk(span)

	return converted, nil
}

// GetThoughtRecord returns a single record by identifier.
func (s *RecordServer) GetThoughtRecord(ctx context.Context, req *proto.GetThoughtRecordRequest) (*proto.ThoughtRecord, error) {
	ctx, span := startSpan(ctx, "GetThoughtRecord")
	defer span.End()

	userID, err := userIDFromContext(ctx)
	if err != nil {
		return nil, err
	}

	record, err := database.GetThoughtRecord(s.DB.WithContext(ctx), userID, uint(req.GetId()))
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

// UpdateThoughtRecord changes the free text columns of a record.
func (s *RecordServer) UpdateThoughtRecord(ctx context.Context, req *proto.UpdateThoughtRecordRequest) (*proto.ThoughtRecord, error) {
	ctx, span := startSpan(ctx, "UpdateThoughtRecord")
	defer span.End()

	userID, err := userIDFromContext(ctx)
	if err != nil {
		return nil, err
	}

	record, err := database.UpdateThoughtRecord(s.DB.WithContext(ctx), userID, uint(req.GetId()), database.UpdateThoughtRecordInput{
		Event:           req.Event,
		OccurredAt:      fromProtoTimestamp(req.GetOccurredAt()),
		ClearOccurredAt: req.GetClearOccurredAt(),
		AlternativeView: req.AlternativeView,
		FeelingsNow:     req.FeelingsNow,
	})
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

// ChallengeThoughtRecord records the second sitting of a thought record.
func (s *RecordServer) ChallengeThoughtRecord(ctx context.Context, req *proto.ChallengeThoughtRecordRequest) (*proto.ThoughtRecord, error) {
	ctx, span := startSpan(ctx, "ChallengeThoughtRecord")
	defer span.End()

	userID, err := userIDFromContext(ctx)
	if err != nil {
		return nil, err
	}

	reratings := make(map[uint]int, len(req.GetFeelingReratings()))
	for _, rerating := range req.GetFeelingReratings() {
		reratings[uint(rerating.GetFeelingId())] = int(rerating.GetIntensityAfter())
	}

	// The biases wrapper is what distinguishes "leave the biases alone" from
	// "detach them all", which proto3 cannot express on a repeated field.
	judgements := make(map[uint]database.ThoughtJudgement, len(req.GetThoughts()))
	for _, judgement := range req.GetThoughts() {
		converted := database.ThoughtJudgement{IsFactual: judgement.GetIsFactual()}
		if judgement.Biases != nil {
			names := judgement.GetBiases().GetNames()
			if names == nil {
				names = []string{}
			}
			converted.Biases = names
		}
		judgements[uint(judgement.GetThoughtId())] = converted
	}

	record, err := database.ChallengeThoughtRecord(s.DB.WithContext(ctx), userID, uint(req.GetId()), database.ChallengeInput{
		AlternativeView:         req.GetAlternativeView(),
		FeelingsNow:             req.GetFeelingsNow(),
		FeelingIntensitiesAfter: reratings,
		Thoughts:                judgements,
	})
	if err != nil {
		return nil, mapDatabaseError(err)
	}

	// How long a record sat before being challenged is the one thing worth
	// measuring about the practice, which is meant to happen the same evening.
	if record.ChallengedAt != nil {
		recordChallengeLatency(ctx, record.ChallengedAt.Sub(record.CreatedAt).Hours())
	}
	slog.InfoContext(ctx, "thought record challenged",
		slog.Uint64("record_id", uint64(record.ID)),
	)

	converted, err := toProtoThoughtRecord(record)
	if err != nil {
		return nil, err
	}

	endSpanOk(span)

	return converted, nil
}

// DeleteThoughtRecord removes a record along with its thoughts and feelings.
func (s *RecordServer) DeleteThoughtRecord(ctx context.Context, req *proto.DeleteThoughtRecordRequest) (*emptypb.Empty, error) {
	ctx, span := startSpan(ctx, "DeleteThoughtRecord")
	defer span.End()

	userID, err := userIDFromContext(ctx)
	if err != nil {
		return nil, err
	}

	if err := database.DeleteThoughtRecord(s.DB.WithContext(ctx), userID, uint(req.GetId())); err != nil {
		return nil, mapDatabaseError(err)
	}

	slog.InfoContext(ctx, "thought record deleted",
		slog.Uint64("record_id", uint64(req.GetId())),
	)

	endSpanOk(span)

	return &emptypb.Empty{}, nil
}

// mapDatabaseError translates the sentinel errors of the database package into
// gRPC status errors. The error logging interceptor takes care of recording
// them, so handlers only have to return the result.
//
// The sentinel messages are safe to return verbatim: they name the kind of
// thing that went wrong and the identifier involved, never the content of a
// record.
func mapDatabaseError(err error) error {
	switch {
	case err == nil:
		return nil
	case errors.Is(err, database.ErrThoughtRecordNotFound),
		errors.Is(err, database.ErrMapOfWorryNotFound),
		errors.Is(err, database.ErrThoughtNotFound),
		errors.Is(err, database.ErrFeelingNotFound),
		errors.Is(err, database.ErrBiasNotFound):
		return status.Error(codes.NotFound, err.Error())
	case errors.Is(err, database.ErrBiasExists):
		return status.Error(codes.AlreadyExists, err.Error())
	case errors.Is(err, database.ErrEventEmpty),
		errors.Is(err, database.ErrThoughtBodyEmpty),
		errors.Is(err, database.ErrFeelingNameEmpty),
		errors.Is(err, database.ErrFeelingIntensityRange),
		errors.Is(err, database.ErrBiasNameEmpty),
		errors.Is(err, database.ErrMultipleHotThoughts),
		errors.Is(err, database.ErrMapDerivedFromSelf):
		return status.Error(codes.InvalidArgument, err.Error())
	case errors.Is(err, database.ErrBiasBuiltin),
		errors.Is(err, database.ErrBiasInUse),
		errors.Is(err, database.ErrThoughtFactualWithBias),
		errors.Is(err, database.ErrMapHasAlternatives),
		errors.Is(err, database.ErrFeelingNotOnRecord):
		return status.Error(codes.FailedPrecondition, err.Error())
	default:
		return status.Errorf(codes.Internal, "%v", err)
	}
}
