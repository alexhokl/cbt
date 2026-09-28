package internal

import (
	"context"
	"testing"

	"github.com/alexhokl/cbt/database"
	"github.com/alexhokl/cbt/proto"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
)

// testUserID matches the identifier injected by the dummy authentication
// interceptor, so the handler tests exercise the same scoping the server does.
const testUserID = uint(1)

// newTestServer opens an in-memory database with a seeded user and returns a
// server backed by it.
func newTestServer(t *testing.T) *RecordServer {
	t.Helper()

	db, err := gorm.Open(sqlite.Open(":memory:"), &gorm.Config{Logger: logger.Discard})
	if err != nil {
		t.Fatalf("failed to open test database: %v", err)
	}
	if err := database.AutoMigrate(db); err != nil {
		t.Fatalf("failed to migrate test database: %v", err)
	}
	if _, err := database.EnsureUser(db, database.LocalUsername); err != nil {
		t.Fatalf("failed to create the test user: %v", err)
	}

	return NewRecordServer(db)
}

// authenticatedContext returns a context carrying the test user, standing in
// for what the authentication interceptor would have injected.
func authenticatedContext() context.Context {
	return context.WithValue(context.Background(), contextKeyUser{}, testUserID)
}

// statusCode extracts the gRPC code from an error, so assertions can name the
// code rather than match on the message.
func statusCode(err error) codes.Code {
	return status.Code(err)
}

func TestHandlersRejectAnUnauthenticatedContext(t *testing.T) {
	server := newTestServer(t)
	ctx := context.Background()

	// Every handler must refuse before touching the database, so a missing
	// interceptor cannot expose another user's records.
	tests := []struct {
		name string
		run  func() error
	}{
		{"ListThoughtRecords", func() error {
			_, err := server.ListThoughtRecords(ctx, &proto.ListThoughtRecordsRequest{})
			return err
		}},
		{"CreateThoughtRecord", func() error {
			_, err := server.CreateThoughtRecord(ctx, &proto.CreateThoughtRecordRequest{Event: "an event"})
			return err
		}},
		{"GetThoughtRecord", func() error {
			_, err := server.GetThoughtRecord(ctx, &proto.GetThoughtRecordRequest{Id: 1})
			return err
		}},
		{"ChallengeThoughtRecord", func() error {
			_, err := server.ChallengeThoughtRecord(ctx, &proto.ChallengeThoughtRecordRequest{Id: 1})
			return err
		}},
		{"DeleteThoughtRecord", func() error {
			_, err := server.DeleteThoughtRecord(ctx, &proto.DeleteThoughtRecordRequest{Id: 1})
			return err
		}},
		{"ListMapsOfWorry", func() error {
			_, err := server.ListMapsOfWorry(ctx, &proto.ListMapsOfWorryRequest{})
			return err
		}},
		{"CreateMapOfWorry", func() error {
			_, err := server.CreateMapOfWorry(ctx, &proto.CreateMapOfWorryRequest{Event: "an event"})
			return err
		}},
		{"ListBiases", func() error {
			_, err := server.ListBiases(ctx, &proto.ListBiasesRequest{})
			return err
		}},
	}

	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			if got := statusCode(test.run()); got != codes.Unauthenticated {
				t.Errorf("expected Unauthenticated but got %v", got)
			}
		})
	}
}

func TestCreateThoughtRecordReturnsTheWholeRecord(t *testing.T) {
	server := newTestServer(t)
	ctx := authenticatedContext()

	record, err := server.CreateThoughtRecord(ctx, &proto.CreateThoughtRecordRequest{
		Event: "a meeting was moved without telling me",
		Thoughts: []*proto.ThoughtInput{
			{Body: "they do not think my input matters", IsHot: true, Biases: []string{"mind-reading"}},
		},
		Feelings: []*proto.FeelingInput{
			{Name: "anxious", Intensity: proto2Int32(80)},
		},
	})
	if err != nil {
		t.Fatalf("failed to create the record: %v", err)
	}

	if record.GetEvent() != "a meeting was moved without telling me" {
		t.Errorf("unexpected event %q", record.GetEvent())
	}
	if len(record.GetThoughts()) != 1 {
		t.Fatalf("expected 1 thought but got %d", len(record.GetThoughts()))
	}
	if !record.GetThoughts()[0].GetIsHot() {
		t.Error("expected the thought to be marked as the strongest")
	}
	if len(record.GetThoughts()[0].GetBiases()) != 1 {
		t.Errorf("expected 1 bias but got %d", len(record.GetThoughts()[0].GetBiases()))
	}
	if record.GetFeelings()[0].GetIntensityBefore() != 80 {
		t.Errorf("expected an intensity of 80 but got %d", record.GetFeelings()[0].GetIntensityBefore())
	}
	if record.ChallengedAt != nil {
		t.Error("expected a new record to be unchallenged")
	}
}

func TestCreateThoughtRecordMapsValidationFailures(t *testing.T) {
	server := newTestServer(t)
	ctx := authenticatedContext()

	tests := []struct {
		name     string
		request  *proto.CreateThoughtRecordRequest
		expected codes.Code
	}{
		{
			"a blank event",
			&proto.CreateThoughtRecordRequest{Event: "   "},
			codes.InvalidArgument,
		},
		{
			"an unknown bias",
			&proto.CreateThoughtRecordRequest{
				Event:    "an event",
				Thoughts: []*proto.ThoughtInput{{Body: "a thought", Biases: []string{"catastrophizing"}}},
			},
			codes.NotFound,
		},
		{
			"two hot thoughts",
			&proto.CreateThoughtRecordRequest{
				Event: "an event",
				Thoughts: []*proto.ThoughtInput{
					{Body: "first", IsHot: true},
					{Body: "second", IsHot: true},
				},
			},
			codes.InvalidArgument,
		},
		{
			"an intensity out of range",
			&proto.CreateThoughtRecordRequest{
				Event:    "an event",
				Feelings: []*proto.FeelingInput{{Name: "anxious", Intensity: proto2Int32(120)}},
			},
			codes.InvalidArgument,
		},
	}

	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			_, err := server.CreateThoughtRecord(ctx, test.request)
			if got := statusCode(err); got != test.expected {
				t.Errorf("expected %v but got %v (%v)", test.expected, got, err)
			}
		})
	}
}

func TestGetThoughtRecordReportsAMissingRecordAsNotFound(t *testing.T) {
	server := newTestServer(t)
	ctx := authenticatedContext()

	_, err := server.GetThoughtRecord(ctx, &proto.GetThoughtRecordRequest{Id: 404})
	if got := statusCode(err); got != codes.NotFound {
		t.Errorf("expected NotFound but got %v", got)
	}
}

func TestChallengeThoughtRecordRoundTrips(t *testing.T) {
	server := newTestServer(t)
	ctx := authenticatedContext()

	created, err := server.CreateThoughtRecord(ctx, &proto.CreateThoughtRecordRequest{
		Event:    "an event",
		Thoughts: []*proto.ThoughtInput{{Body: "a thought"}},
		Feelings: []*proto.FeelingInput{{Name: "anxious", Intensity: proto2Int32(80)}},
	})
	if err != nil {
		t.Fatalf("failed to create the record: %v", err)
	}

	challenged, err := server.ChallengeThoughtRecord(ctx, &proto.ChallengeThoughtRecordRequest{
		Id:              created.GetId(),
		AlternativeView: "there is another reading of this",
		FeelingsNow:     "steadier",
		FeelingReratings: []*proto.FeelingRerating{
			{FeelingId: created.GetFeelings()[0].GetId(), IntensityAfter: 25},
		},
		Thoughts: []*proto.ThoughtJudgement{
			{
				ThoughtId: created.GetThoughts()[0].GetId(),
				Biases:    &proto.BiasNames{Names: []string{"mind-reading"}},
			},
		},
	})
	if err != nil {
		t.Fatalf("failed to challenge the record: %v", err)
	}

	if challenged.ChallengedAt == nil {
		t.Error("expected the record to be stamped as challenged")
	}
	if challenged.GetFeelings()[0].GetIntensityAfter() != 25 {
		t.Errorf("expected the feeling to be re-rated to 25 but got %d", challenged.GetFeelings()[0].GetIntensityAfter())
	}
	if len(challenged.GetThoughts()[0].GetBiases()) != 1 {
		t.Errorf("expected 1 bias but got %d", len(challenged.GetThoughts()[0].GetBiases()))
	}
}

func TestListThoughtRecordsFiltersTheWorkQueue(t *testing.T) {
	server := newTestServer(t)
	ctx := authenticatedContext()

	pending, err := server.CreateThoughtRecord(ctx, &proto.CreateThoughtRecordRequest{Event: "still to work through"})
	if err != nil {
		t.Fatalf("failed to create the pending record: %v", err)
	}
	done, err := server.CreateThoughtRecord(ctx, &proto.CreateThoughtRecordRequest{Event: "already done"})
	if err != nil {
		t.Fatalf("failed to create the record to challenge: %v", err)
	}
	if _, err := server.ChallengeThoughtRecord(ctx, &proto.ChallengeThoughtRecordRequest{Id: done.GetId()}); err != nil {
		t.Fatalf("failed to challenge the record: %v", err)
	}

	unchallenged := false
	response, err := server.ListThoughtRecords(ctx, &proto.ListThoughtRecordsRequest{Challenged: &unchallenged})
	if err != nil {
		t.Fatalf("failed to list the records: %v", err)
	}
	if len(response.GetRecords()) != 1 || response.GetRecords()[0].GetId() != pending.GetId() {
		t.Fatalf("expected only the unchallenged record but got %d records", len(response.GetRecords()))
	}
}

func TestUpdateThoughtLeavesBiasesAloneWhenTheWrapperIsAbsent(t *testing.T) {
	server := newTestServer(t)
	ctx := authenticatedContext()

	created, err := server.CreateThoughtRecord(ctx, &proto.CreateThoughtRecordRequest{
		Event:    "an event",
		Thoughts: []*proto.ThoughtInput{{Body: "a thought", Biases: []string{"blaming"}}},
	})
	if err != nil {
		t.Fatalf("failed to create the record: %v", err)
	}
	thoughtID := created.GetThoughts()[0].GetId()

	// The wrapper's presence is what distinguishes "leave them" from "clear
	// them"; proto3 cannot mark a repeated field optional, hence the message.
	t.Run("absent keeps them", func(t *testing.T) {
		updated, err := server.UpdateThought(ctx, &proto.UpdateThoughtRequest{Id: thoughtID, Body: "reworded"})
		if err != nil {
			t.Fatalf("failed to update the thought: %v", err)
		}
		if len(updated.GetThoughts()[0].GetBiases()) != 1 {
			t.Errorf("expected the bias to survive but got %d", len(updated.GetThoughts()[0].GetBiases()))
		}
	})

	t.Run("empty clears them", func(t *testing.T) {
		updated, err := server.UpdateThought(ctx, &proto.UpdateThoughtRequest{
			Id:     thoughtID,
			Body:   "reworded again",
			Biases: &proto.BiasNames{},
		})
		if err != nil {
			t.Fatalf("failed to update the thought: %v", err)
		}
		if len(updated.GetThoughts()[0].GetBiases()) != 0 {
			t.Errorf("expected the biases to be cleared but got %d", len(updated.GetThoughts()[0].GetBiases()))
		}
	})
}

func TestDeleteThoughtReturnsTheUpdatedRecord(t *testing.T) {
	server := newTestServer(t)
	ctx := authenticatedContext()

	created, err := server.CreateThoughtRecord(ctx, &proto.CreateThoughtRecordRequest{
		Event: "an event",
		Thoughts: []*proto.ThoughtInput{
			{Body: "first"},
			{Body: "second"},
		},
	})
	if err != nil {
		t.Fatalf("failed to create the record: %v", err)
	}

	// Returning the record rather than an empty response saves the caller a
	// round trip to redraw.
	record, err := server.DeleteThought(ctx, &proto.DeleteThoughtRequest{Id: created.GetThoughts()[0].GetId()})
	if err != nil {
		t.Fatalf("failed to delete the thought: %v", err)
	}
	if len(record.GetThoughts()) != 1 {
		t.Errorf("expected 1 remaining thought but got %d", len(record.GetThoughts()))
	}
}

func TestGetMapOfWorryReturnsBothSidesOfTheContrast(t *testing.T) {
	server := newTestServer(t)
	ctx := authenticatedContext()

	origin, err := server.CreateMapOfWorry(ctx, &proto.CreateMapOfWorryRequest{
		Event:              "a report came back covered in comments",
		ResultantBehaviour: "put off opening the review until the next morning",
	})
	if err != nil {
		t.Fatalf("failed to create the original map: %v", err)
	}

	originID := origin.GetId()
	alternative, err := server.CreateMapOfWorry(ctx, &proto.CreateMapOfWorryRequest{
		Event:              "a report came back covered in comments",
		ResultantBehaviour: "worked through the comments one at a time",
		DerivedFromId:      &originID,
	})
	if err != nil {
		t.Fatalf("failed to create the alternative map: %v", err)
	}

	t.Run("from the original", func(t *testing.T) {
		response, err := server.GetMapOfWorry(ctx, &proto.GetMapOfWorryRequest{Id: originID})
		if err != nil {
			t.Fatalf("failed to get the map: %v", err)
		}
		if len(response.GetAlternatives()) != 1 || response.GetAlternatives()[0].GetId() != alternative.GetId() {
			t.Errorf("expected the alternative to be returned but got %d", len(response.GetAlternatives()))
		}
	})

	t.Run("from the alternative", func(t *testing.T) {
		response, err := server.GetMapOfWorry(ctx, &proto.GetMapOfWorryRequest{Id: alternative.GetId()})
		if err != nil {
			t.Fatalf("failed to get the map: %v", err)
		}
		if response.GetDerivedFrom() == nil || response.GetDerivedFrom().GetId() != originID {
			t.Error("expected the original map to be returned alongside the alternative")
		}
	})
}

func TestDeleteMapOfWorryReportsAlternativesAsFailedPrecondition(t *testing.T) {
	server := newTestServer(t)
	ctx := authenticatedContext()

	origin, err := server.CreateMapOfWorry(ctx, &proto.CreateMapOfWorryRequest{Event: "an event"})
	if err != nil {
		t.Fatalf("failed to create the original map: %v", err)
	}
	originID := origin.GetId()
	if _, err := server.CreateMapOfWorry(ctx, &proto.CreateMapOfWorryRequest{
		Event:         "an event",
		DerivedFromId: &originID,
	}); err != nil {
		t.Fatalf("failed to create the alternative map: %v", err)
	}

	_, err = server.DeleteMapOfWorry(ctx, &proto.DeleteMapOfWorryRequest{Id: originID})
	if got := statusCode(err); got != codes.FailedPrecondition {
		t.Errorf("expected FailedPrecondition but got %v", got)
	}
}

func TestBiasHandlersProtectTheSeededVocabulary(t *testing.T) {
	server := newTestServer(t)
	ctx := authenticatedContext()

	response, err := server.ListBiases(ctx, &proto.ListBiasesRequest{})
	if err != nil {
		t.Fatalf("failed to list the biases: %v", err)
	}
	if len(response.GetBiases()) != len(database.BuiltinBiasNames) {
		t.Fatalf("expected %d seeded biases but got %d", len(database.BuiltinBiasNames), len(response.GetBiases()))
	}

	builtinID := response.GetBiases()[0].GetId()

	tests := []struct {
		name string
		run  func() error
	}{
		{"rename", func() error {
			_, err := server.RenameBias(ctx, &proto.RenameBiasRequest{Id: builtinID, Name: "something else"})
			return err
		}},
		{"delete", func() error {
			_, err := server.DeleteBias(ctx, &proto.DeleteBiasRequest{Id: builtinID})
			return err
		}},
	}

	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			if got := statusCode(test.run()); got != codes.FailedPrecondition {
				t.Errorf("expected FailedPrecondition but got %v", got)
			}
		})
	}
}

func TestCreateBiasReportsADuplicateAsAlreadyExists(t *testing.T) {
	server := newTestServer(t)
	ctx := authenticatedContext()

	_, err := server.CreateBias(ctx, &proto.CreateBiasRequest{Name: "Catastrophising"})
	if got := statusCode(err); got != codes.AlreadyExists {
		t.Errorf("expected AlreadyExists but got %v", got)
	}
}

// proto2Int32 returns a pointer to the given rating, for the optional wire
// intensity fields.
func proto2Int32(value int32) *int32 {
	return &value
}

func TestChallengeClearsBiasesWhenGivenAnEmptyList(t *testing.T) {
	server := newTestServer(t)
	ctx := authenticatedContext()

	created, err := server.CreateThoughtRecord(ctx, &proto.CreateThoughtRecordRequest{
		Event: "a meeting was moved without telling me",
		Thoughts: []*proto.ThoughtInput{
			{Body: "they do not think my input matters", Biases: []string{"mind-reading"}},
		},
	})
	if err != nil {
		t.Fatalf("failed to create the record: %v", err)
	}

	// This is the request the mobile challenge screen sends when every chip is
	// deselected, so the wire shape matters as much as the operation beneath.
	challenged, err := server.ChallengeThoughtRecord(ctx, &proto.ChallengeThoughtRecordRequest{
		Id: created.GetId(),
		Thoughts: []*proto.ThoughtJudgement{
			{ThoughtId: created.GetThoughts()[0].GetId(), Biases: &proto.BiasNames{}},
		},
	})
	if err != nil {
		t.Fatalf("failed to challenge the record: %v", err)
	}

	if len(challenged.GetThoughts()[0].GetBiases()) != 0 {
		t.Errorf("expected the biases to be detached but got %d", len(challenged.GetThoughts()[0].GetBiases()))
	}
}

func TestChallengeKeepsBiasesWhenTheWrapperIsAbsent(t *testing.T) {
	server := newTestServer(t)
	ctx := authenticatedContext()

	created, err := server.CreateThoughtRecord(ctx, &proto.CreateThoughtRecordRequest{
		Event: "a meeting was moved without telling me",
		Thoughts: []*proto.ThoughtInput{
			{Body: "they do not think my input matters", Biases: []string{"mind-reading"}},
		},
	})
	if err != nil {
		t.Fatalf("failed to create the record: %v", err)
	}

	// An absent wrapper is what distinguishes "leave them alone" from "detach
	// them all"; proto3 cannot express that on a repeated field.
	challenged, err := server.ChallengeThoughtRecord(ctx, &proto.ChallengeThoughtRecordRequest{
		Id:       created.GetId(),
		Thoughts: []*proto.ThoughtJudgement{{ThoughtId: created.GetThoughts()[0].GetId()}},
	})
	if err != nil {
		t.Fatalf("failed to challenge the record: %v", err)
	}

	if len(challenged.GetThoughts()[0].GetBiases()) != 1 {
		t.Errorf("expected the bias to survive but got %d", len(challenged.GetThoughts()[0].GetBiases()))
	}
}

func TestSetThoughtFactualRoundTrips(t *testing.T) {
	server := newTestServer(t)
	ctx := authenticatedContext()

	created, err := server.CreateThoughtRecord(ctx, &proto.CreateThoughtRecordRequest{
		Event:    "the last train was cancelled",
		Thoughts: []*proto.ThoughtInput{{Body: "I will not get home before midnight"}},
	})
	if err != nil {
		t.Fatalf("failed to create the record: %v", err)
	}

	if created.GetThoughts()[0].GetIsFactual() {
		t.Error("expected a new thought not to claim to be factual")
	}

	record, err := server.SetThoughtFactual(ctx, &proto.SetThoughtFactualRequest{
		Id:      created.GetThoughts()[0].GetId(),
		Factual: true,
	})
	if err != nil {
		t.Fatalf("failed to mark the thought factual: %v", err)
	}
	if !record.GetThoughts()[0].GetIsFactual() {
		t.Error("expected the thought to be marked factual")
	}
}

func TestFactualWithABiasIsReportedAsFailedPrecondition(t *testing.T) {
	server := newTestServer(t)
	ctx := authenticatedContext()

	created, err := server.CreateThoughtRecord(ctx, &proto.CreateThoughtRecordRequest{
		Event: "a meeting was moved without telling me",
		Thoughts: []*proto.ThoughtInput{
			{Body: "they do not think my input matters", Biases: []string{"mind-reading"}},
		},
	})
	if err != nil {
		t.Fatalf("failed to create the record: %v", err)
	}
	thoughtID := created.GetThoughts()[0].GetId()

	tests := []struct {
		name string
		run  func() error
	}{
		{"via SetThoughtFactual", func() error {
			_, err := server.SetThoughtFactual(ctx, &proto.SetThoughtFactualRequest{Id: thoughtID, Factual: true})
			return err
		}},
		{"via a challenge", func() error {
			_, err := server.ChallengeThoughtRecord(ctx, &proto.ChallengeThoughtRecordRequest{
				Id:       created.GetId(),
				Thoughts: []*proto.ThoughtJudgement{{ThoughtId: thoughtID, IsFactual: true}},
			})
			return err
		}},
	}

	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			if got := statusCode(test.run()); got != codes.FailedPrecondition {
				t.Errorf("expected FailedPrecondition but got %v", got)
			}
		})
	}
}

func TestSetThoughtFactualRejectsAnUnauthenticatedContext(t *testing.T) {
	server := newTestServer(t)

	_, err := server.SetThoughtFactual(context.Background(), &proto.SetThoughtFactualRequest{Id: 1})
	if got := statusCode(err); got != codes.Unauthenticated {
		t.Errorf("expected Unauthenticated but got %v", got)
	}
}
