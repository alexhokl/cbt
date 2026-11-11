package database

import (
	"errors"
	"testing"
	"time"
)

func TestCreatePositiveDataLogRequiresABelief(t *testing.T) {
	db := setupTestDB(t)

	tests := []struct {
		name   string
		belief string
	}{
		{"empty", ""},
		{"whitespace", "  \n"},
	}

	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			_, err := CreatePositiveDataLog(db, testUserID, CreatePositiveDataLogInput{Belief: test.belief})
			if !errors.Is(err, ErrBeliefEmpty) {
				t.Errorf("expected ErrBeliefEmpty but got %v", err)
			}
		})
	}
}

func TestCreatePositiveDataLogStoresEverything(t *testing.T) {
	db := setupTestDB(t)
	notedAt := time.Date(2026, 11, 3, 9, 0, 0, 0, time.UTC)

	log, err := CreatePositiveDataLog(db, testUserID, CreatePositiveDataLogInput{
		Belief:            "  I am always late ",
		AlternativeBelief: " I am on time for most things",
		Rating:            BeliefRatingInput{BeliefPercent: intPtr(70), AlternativePercent: intPtr(30)},
		Evidence: []DataLogEvidenceInput{
			{Body: " arrived early for the dentist ", NotedAt: &notedAt},
			{Body: "caught the first train on Monday"},
		},
	})
	if err != nil {
		t.Fatalf("failed to create the log: %v", err)
	}

	if log.Belief != "I am always late" {
		t.Errorf("expected the belief to be trimmed but got %q", log.Belief)
	}
	if log.AlternativeBelief != "I am on time for most things" {
		t.Errorf("expected the alternative to be trimmed but got %q", log.AlternativeBelief)
	}
	if len(log.Ratings) != 1 {
		t.Fatalf("expected one rating but got %d", len(log.Ratings))
	}
	rating := log.Ratings[0]
	if rating.BeliefPercent == nil || *rating.BeliefPercent != 70 {
		t.Errorf("expected the belief rated 70 but got %v", rating.BeliefPercent)
	}
	if rating.AlternativePercent == nil || *rating.AlternativePercent != 30 {
		t.Errorf("expected the alternative rated 30 but got %v", rating.AlternativePercent)
	}
	if len(log.Evidence) != 2 {
		t.Fatalf("expected two rows of evidence but got %d", len(log.Evidence))
	}
	if log.Evidence[0].Body != "arrived early for the dentist" {
		t.Errorf("expected the evidence to be trimmed and in order but got %q", log.Evidence[0].Body)
	}
	if log.Evidence[0].NotedAt == nil || !log.Evidence[0].NotedAt.Equal(notedAt) {
		t.Errorf("expected the evidence dated %v but got %v", notedAt, log.Evidence[0].NotedAt)
	}
	if log.Evidence[1].NotedAt != nil {
		t.Errorf("expected undated evidence but got %v", log.Evidence[1].NotedAt)
	}
}

func TestCreatePositiveDataLogWithoutRatingStoresNone(t *testing.T) {
	db := setupTestDB(t)

	log, err := CreatePositiveDataLog(db, testUserID, CreatePositiveDataLogInput{Belief: "I am always late"})
	if err != nil {
		t.Fatalf("failed to create the log: %v", err)
	}
	if len(log.Ratings) != 0 {
		t.Errorf("expected no ratings but got %d", len(log.Ratings))
	}
}

func TestCreatePositiveDataLogRejectsBadRowsWhole(t *testing.T) {
	tests := []struct {
		name     string
		input    CreatePositiveDataLogInput
		expected error
	}{
		{
			name: "blank evidence",
			input: CreatePositiveDataLogInput{
				Belief:   "I am always late",
				Evidence: []DataLogEvidenceInput{{Body: "arrived early for the dentist"}, {Body: " "}},
			},
			expected: ErrDataLogEvidenceEmpty,
		},
		{
			name: "rating out of range",
			input: CreatePositiveDataLogInput{
				Belief: "I am always late",
				Rating: BeliefRatingInput{BeliefPercent: intPtr(101)},
			},
			expected: ErrBeliefRatingRange,
		},
	}

	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			db := setupTestDB(t)

			_, err := CreatePositiveDataLog(db, testUserID, test.input)
			if !errors.Is(err, test.expected) {
				t.Fatalf("expected %v but got %v", test.expected, err)
			}

			// The transaction must not leave a half-built log behind.
			logs, err := ListPositiveDataLogs(db, testUserID, PositiveDataLogFilter{})
			if err != nil {
				t.Fatalf("failed to list the logs: %v", err)
			}
			if len(logs) != 0 {
				t.Errorf("expected no logs but got %d", len(logs))
			}
		})
	}
}

func TestRateBeliefsKeepsTheHistory(t *testing.T) {
	db := setupTestDB(t)

	log, err := CreatePositiveDataLog(db, testUserID, CreatePositiveDataLogInput{
		Belief: "I am always late",
		Rating: BeliefRatingInput{BeliefPercent: intPtr(70), AlternativePercent: intPtr(30)},
	})
	if err != nil {
		t.Fatalf("failed to create the log: %v", err)
	}

	if _, err := RateBeliefs(db, testUserID, log.ID, BeliefRatingInput{BeliefPercent: intPtr(55), AlternativePercent: intPtr(45)}); err != nil {
		t.Fatalf("failed to rate the beliefs: %v", err)
	}
	log, err = RateBeliefs(db, testUserID, log.ID, BeliefRatingInput{AlternativePercent: intPtr(60)})
	if err != nil {
		t.Fatalf("failed to rate the beliefs: %v", err)
	}

	if len(log.Ratings) != 3 {
		t.Fatalf("expected three ratings but got %d", len(log.Ratings))
	}
	if *log.Ratings[0].BeliefPercent != 70 || *log.Ratings[1].BeliefPercent != 55 {
		t.Errorf("expected the earlier ratings to be kept in order but got %v, %v", *log.Ratings[0].BeliefPercent, *log.Ratings[1].BeliefPercent)
	}
	last := log.Ratings[2]
	if last.BeliefPercent != nil {
		t.Errorf("expected the belief unrated but got %v", *last.BeliefPercent)
	}
	if last.AlternativePercent == nil || *last.AlternativePercent != 60 {
		t.Errorf("expected the alternative rated 60 but got %v", last.AlternativePercent)
	}
	if last.RatedAt.IsZero() {
		t.Error("expected the rating to be stamped")
	}
}

func TestRateBeliefsValidates(t *testing.T) {
	db := setupTestDB(t)

	log, err := CreatePositiveDataLog(db, testUserID, CreatePositiveDataLogInput{Belief: "I am always late"})
	if err != nil {
		t.Fatalf("failed to create the log: %v", err)
	}

	tests := []struct {
		name     string
		input    BeliefRatingInput
		expected error
	}{
		{"neither belief", BeliefRatingInput{}, ErrBeliefRatingEmpty},
		{"belief below range", BeliefRatingInput{BeliefPercent: intPtr(-1)}, ErrBeliefRatingRange},
		{"alternative above range", BeliefRatingInput{AlternativePercent: intPtr(101)}, ErrBeliefRatingRange},
	}

	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			_, err := RateBeliefs(db, testUserID, log.ID, test.input)
			if !errors.Is(err, test.expected) {
				t.Errorf("expected %v but got %v", test.expected, err)
			}
		})
	}
}

func TestBeliefRatingTriggers(t *testing.T) {
	db := setupTestDB(t)

	log, err := CreatePositiveDataLog(db, testUserID, CreatePositiveDataLogInput{Belief: "I am always late"})
	if err != nil {
		t.Fatalf("failed to create the log: %v", err)
	}

	tests := []struct {
		name   string
		rating BeliefRating
	}{
		{"neither belief", BeliefRating{}},
		{"out of range", BeliefRating{BeliefPercent: intPtr(150)}},
	}

	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			rating := test.rating
			rating.RatedAt = time.Now()
			rating.PositiveDataLogID = log.ID
			rating.UserID = testUserID
			if err := db.Create(&rating).Error; err == nil {
				t.Error("expected the trigger to reject the rating")
			}
		})
	}
}

func TestAddAndDeleteDataLogEvidence(t *testing.T) {
	db := setupTestDB(t)

	log, err := CreatePositiveDataLog(db, testUserID, CreatePositiveDataLogInput{Belief: "I am always late"})
	if err != nil {
		t.Fatalf("failed to create the log: %v", err)
	}

	if _, err := AddDataLogEvidence(db, testUserID, log.ID, DataLogEvidenceInput{Body: " "}); !errors.Is(err, ErrDataLogEvidenceEmpty) {
		t.Errorf("expected ErrDataLogEvidenceEmpty but got %v", err)
	}

	log, err = AddDataLogEvidence(db, testUserID, log.ID, DataLogEvidenceInput{Body: "arrived early for the dentist"})
	if err != nil {
		t.Fatalf("failed to add the evidence: %v", err)
	}
	if len(log.Evidence) != 1 {
		t.Fatalf("expected one row of evidence but got %d", len(log.Evidence))
	}

	log, err = DeleteDataLogEvidence(db, testUserID, log.Evidence[0].ID)
	if err != nil {
		t.Fatalf("failed to delete the evidence: %v", err)
	}
	if len(log.Evidence) != 0 {
		t.Errorf("expected no evidence but got %d", len(log.Evidence))
	}

	if _, err := DeleteDataLogEvidence(db, testUserID, 999); !errors.Is(err, ErrDataLogEvidenceNotFound) {
		t.Errorf("expected ErrDataLogEvidenceNotFound but got %v", err)
	}
}

func TestUpdatePositiveDataLog(t *testing.T) {
	db := setupTestDB(t)

	log, err := CreatePositiveDataLog(db, testUserID, CreatePositiveDataLogInput{
		Belief:            "I am always late",
		AlternativeBelief: "I am sometimes late",
	})
	if err != nil {
		t.Fatalf("failed to create the log: %v", err)
	}

	log, err = UpdatePositiveDataLog(db, testUserID, log.ID, UpdatePositiveDataLogInput{AlternativeBelief: stringPtr(" I am on time for most things ")})
	if err != nil {
		t.Fatalf("failed to update the log: %v", err)
	}
	if log.Belief != "I am always late" {
		t.Errorf("expected the belief to be left alone but got %q", log.Belief)
	}
	if log.AlternativeBelief != "I am on time for most things" {
		t.Errorf("unexpected alternative %q", log.AlternativeBelief)
	}

	if _, err := UpdatePositiveDataLog(db, testUserID, log.ID, UpdatePositiveDataLogInput{Belief: stringPtr(" ")}); !errors.Is(err, ErrBeliefEmpty) {
		t.Errorf("expected ErrBeliefEmpty but got %v", err)
	}
}

func TestListPositiveDataLogsSearchesEvidence(t *testing.T) {
	db := setupTestDB(t)

	late, err := CreatePositiveDataLog(db, testUserID, CreatePositiveDataLogInput{
		Belief:   "I am always late",
		Evidence: []DataLogEvidenceInput{{Body: "arrived early for the dentist"}},
	})
	if err != nil {
		t.Fatalf("failed to create the log: %v", err)
	}
	if _, err := CreatePositiveDataLog(db, testUserID, CreatePositiveDataLogInput{
		Belief:            "I never finish a book",
		AlternativeBelief: "I finish the ones I enjoy",
	}); err != nil {
		t.Fatalf("failed to create the log: %v", err)
	}

	tests := []struct {
		search   string
		expected int
	}{
		{"", 2},
		{"DENTIST", 1},
		{"enjoy", 1},
		{"late", 1},
		{"garden", 0},
	}

	for _, test := range tests {
		t.Run(test.search, func(t *testing.T) {
			logs, err := ListPositiveDataLogs(db, testUserID, PositiveDataLogFilter{Search: test.search})
			if err != nil {
				t.Fatalf("failed to list the logs: %v", err)
			}
			if len(logs) != test.expected {
				t.Errorf("expected %d logs but got %d", test.expected, len(logs))
			}
		})
	}

	// Deleted evidence must no longer match.
	if _, err := DeleteDataLogEvidence(db, testUserID, late.Evidence[0].ID); err != nil {
		t.Fatalf("failed to delete the evidence: %v", err)
	}
	logs, err := ListPositiveDataLogs(db, testUserID, PositiveDataLogFilter{Search: "dentist"})
	if err != nil {
		t.Fatalf("failed to list the logs: %v", err)
	}
	if len(logs) != 0 {
		t.Errorf("expected deleted evidence not to match but got %d logs", len(logs))
	}
}

func TestDeletePositiveDataLogRemovesItsRows(t *testing.T) {
	db := setupTestDB(t)

	log, err := CreatePositiveDataLog(db, testUserID, CreatePositiveDataLogInput{
		Belief:   "I am always late",
		Rating:   BeliefRatingInput{BeliefPercent: intPtr(70)},
		Evidence: []DataLogEvidenceInput{{Body: "arrived early for the dentist"}},
	})
	if err != nil {
		t.Fatalf("failed to create the log: %v", err)
	}

	if err := DeletePositiveDataLog(db, testUserID, log.ID); err != nil {
		t.Fatalf("failed to delete the log: %v", err)
	}

	if _, err := GetPositiveDataLog(db, testUserID, log.ID); !errors.Is(err, ErrPositiveDataLogNotFound) {
		t.Errorf("expected ErrPositiveDataLogNotFound but got %v", err)
	}
	var evidence, ratings int64
	db.Model(&PositiveDataLogEvidence{}).Where("positive_data_log_id = ?", log.ID).Count(&evidence)
	db.Model(&BeliefRating{}).Where("positive_data_log_id = ?", log.ID).Count(&ratings)
	if evidence != 0 || ratings != 0 {
		t.Errorf("expected the rows to be deleted but found %d evidence and %d ratings", evidence, ratings)
	}
}

func TestPositiveDataLogIsScopedToItsUser(t *testing.T) {
	db := setupTestDB(t)

	log, err := CreatePositiveDataLog(db, testUserID, CreatePositiveDataLogInput{
		Belief:   "I am always late",
		Evidence: []DataLogEvidenceInput{{Body: "arrived early for the dentist"}},
	})
	if err != nil {
		t.Fatalf("failed to create the log: %v", err)
	}

	tests := []struct {
		name     string
		call     func() error
		expected error
	}{
		{"get", func() error {
			_, err := GetPositiveDataLog(db, otherUserID, log.ID)
			return err
		}, ErrPositiveDataLogNotFound},
		{"update", func() error {
			_, err := UpdatePositiveDataLog(db, otherUserID, log.ID, UpdatePositiveDataLogInput{Belief: stringPtr("something else")})
			return err
		}, ErrPositiveDataLogNotFound},
		{"add evidence", func() error {
			_, err := AddDataLogEvidence(db, otherUserID, log.ID, DataLogEvidenceInput{Body: "something else"})
			return err
		}, ErrPositiveDataLogNotFound},
		{"delete evidence", func() error {
			_, err := DeleteDataLogEvidence(db, otherUserID, log.Evidence[0].ID)
			return err
		}, ErrDataLogEvidenceNotFound},
		{"rate", func() error {
			_, err := RateBeliefs(db, otherUserID, log.ID, BeliefRatingInput{BeliefPercent: intPtr(10)})
			return err
		}, ErrPositiveDataLogNotFound},
		{"delete", func() error {
			return DeletePositiveDataLog(db, otherUserID, log.ID)
		}, ErrPositiveDataLogNotFound},
	}

	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			if err := test.call(); !errors.Is(err, test.expected) {
				t.Errorf("expected %v but got %v", test.expected, err)
			}
		})
	}

	logs, err := ListPositiveDataLogs(db, otherUserID, PositiveDataLogFilter{})
	if err != nil {
		t.Fatalf("failed to list the logs: %v", err)
	}
	if len(logs) != 0 {
		t.Errorf("expected no logs for the other user but got %d", len(logs))
	}
}
