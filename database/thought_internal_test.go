package database

import (
	"errors"
	"testing"
)

func TestSetHotThoughtMovesTheFlag(t *testing.T) {
	db := setupTestDB(t)

	record, err := CreateThoughtRecord(db, testUserID, CreateThoughtRecordInput{
		Event: "an event",
		Thoughts: []ThoughtInput{
			{Body: "first", IsHot: true},
			{Body: "second"},
		},
	})
	if err != nil {
		t.Fatalf("failed to create the record: %v", err)
	}

	// The hot thought is the single strongest one, so marking another must
	// move the flag rather than add a second.
	updated, err := SetHotThought(db, testUserID, record.Thoughts[1].ID)
	if err != nil {
		t.Fatalf("failed to set the hot thought: %v", err)
	}

	hotCount := 0
	for _, thought := range updated.Thoughts {
		if thought.IsHot {
			hotCount++
			if thought.ID != record.Thoughts[1].ID {
				t.Errorf("expected thought %d to be hot but %d is", record.Thoughts[1].ID, thought.ID)
			}
		}
	}
	if hotCount != 1 {
		t.Errorf("expected exactly 1 hot thought but got %d", hotCount)
	}
}

func TestAddThoughtAsHotClearsThePrevious(t *testing.T) {
	db := setupTestDB(t)

	record, err := CreateThoughtRecord(db, testUserID, CreateThoughtRecordInput{
		Event:    "an event",
		Thoughts: []ThoughtInput{{Body: "first", IsHot: true}},
	})
	if err != nil {
		t.Fatalf("failed to create the record: %v", err)
	}

	updated, err := AddThought(db, testUserID, record.ID, ThoughtInput{Body: "a stronger one", IsHot: true})
	if err != nil {
		t.Fatalf("failed to add the thought: %v", err)
	}

	hotCount := 0
	for _, thought := range updated.Thoughts {
		if thought.IsHot {
			hotCount++
		}
	}
	if hotCount != 1 {
		t.Errorf("expected exactly 1 hot thought but got %d", hotCount)
	}
}

func TestAddThoughtRejectsABlankBody(t *testing.T) {
	db := setupTestDB(t)

	record, err := CreateThoughtRecord(db, testUserID, CreateThoughtRecordInput{Event: "an event"})
	if err != nil {
		t.Fatalf("failed to create the record: %v", err)
	}

	if _, err := AddThought(db, testUserID, record.ID, ThoughtInput{Body: "  "}); !errors.Is(err, ErrThoughtBodyEmpty) {
		t.Errorf("expected ErrThoughtBodyEmpty but got %v", err)
	}
}

func TestUpdateThoughtLeavesBiasesAloneWhenNotGiven(t *testing.T) {
	db := setupTestDB(t)

	record, err := CreateThoughtRecord(db, testUserID, CreateThoughtRecordInput{
		Event:    "an event",
		Thoughts: []ThoughtInput{{Body: "a thought", Biases: []string{"blaming"}}},
	})
	if err != nil {
		t.Fatalf("failed to create the record: %v", err)
	}

	// A nil slice means "leave them", which is what allows the wording to be
	// corrected without redoing the bias work.
	updated, err := UpdateThought(db, testUserID, record.Thoughts[0].ID, "a better worded thought", nil)
	if err != nil {
		t.Fatalf("failed to update the thought: %v", err)
	}

	if updated.Thoughts[0].Body != "a better worded thought" {
		t.Errorf("unexpected body %q", updated.Thoughts[0].Body)
	}
	if len(updated.Thoughts[0].Biases) != 1 {
		t.Errorf("expected the bias to survive but got %d biases", len(updated.Thoughts[0].Biases))
	}
}

func TestUpdateThoughtDetachesBiasesWhenGivenAnEmptyList(t *testing.T) {
	db := setupTestDB(t)

	record, err := CreateThoughtRecord(db, testUserID, CreateThoughtRecordInput{
		Event:    "an event",
		Thoughts: []ThoughtInput{{Body: "a thought", Biases: []string{"blaming"}}},
	})
	if err != nil {
		t.Fatalf("failed to create the record: %v", err)
	}

	// An empty but non-nil slice is an explicit instruction to clear them.
	updated, err := UpdateThought(db, testUserID, record.Thoughts[0].ID, "a thought", []string{})
	if err != nil {
		t.Fatalf("failed to update the thought: %v", err)
	}
	if len(updated.Thoughts[0].Biases) != 0 {
		t.Errorf("expected the biases to be detached but got %d", len(updated.Thoughts[0].Biases))
	}
}

func TestDeleteThoughtDetachesItsBiases(t *testing.T) {
	db := setupTestDB(t)

	record, err := CreateThoughtRecord(db, testUserID, CreateThoughtRecordInput{
		Event:    "an event",
		Thoughts: []ThoughtInput{{Body: "a thought", Biases: []string{"blaming"}}},
	})
	if err != nil {
		t.Fatalf("failed to create the record: %v", err)
	}
	thoughtID := record.Thoughts[0].ID

	if err := DeleteThought(db, testUserID, thoughtID); err != nil {
		t.Fatalf("failed to delete the thought: %v", err)
	}

	// The join table carries no soft delete column, so a surviving row would
	// pin a bias that is no longer referenced by anything visible.
	var joinRows int64
	if err := db.Table("thought_biases").Where("negative_thought_id = ?", thoughtID).Count(&joinRows).Error; err != nil {
		t.Fatalf("failed to count the join rows: %v", err)
	}
	if joinRows != 0 {
		t.Errorf("expected the join rows to be removed but %d remain", joinRows)
	}
}

func TestThoughtOperationsAreScopedToTheUser(t *testing.T) {
	db := setupTestDB(t)

	record, err := CreateThoughtRecord(db, testUserID, CreateThoughtRecordInput{
		Event:    "my event",
		Thoughts: []ThoughtInput{{Body: "my thought"}},
	})
	if err != nil {
		t.Fatalf("failed to create the record: %v", err)
	}
	thoughtID := record.Thoughts[0].ID

	tests := []struct {
		name string
		run  func() error
	}{
		{"add", func() error {
			_, err := AddThought(db, otherUserID, record.ID, ThoughtInput{Body: "theirs"})
			return err
		}},
		{"update", func() error {
			_, err := UpdateThought(db, otherUserID, thoughtID, "theirs", nil)
			return err
		}},
		{"set hot", func() error {
			_, err := SetHotThought(db, otherUserID, thoughtID)
			return err
		}},
		{"delete", func() error { return DeleteThought(db, otherUserID, thoughtID) }},
	}

	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			err := test.run()
			if !errors.Is(err, ErrThoughtNotFound) && !errors.Is(err, ErrThoughtRecordNotFound) {
				t.Errorf("expected a not found error but got %v", err)
			}
		})
	}
}

func TestSetThoughtFactualRecordsAndUndoes(t *testing.T) {
	db := setupTestDB(t)

	record, err := CreateThoughtRecord(db, testUserID, CreateThoughtRecordInput{
		Event:    "the last train was cancelled",
		Thoughts: []ThoughtInput{{Body: "I will not get home before midnight"}},
	})
	if err != nil {
		t.Fatalf("failed to create the record: %v", err)
	}
	thoughtID := record.Thoughts[0].ID

	marked, err := SetThoughtFactual(db, testUserID, thoughtID, true)
	if err != nil {
		t.Fatalf("failed to mark the thought factual: %v", err)
	}
	if !marked.Thoughts[0].IsFactual {
		t.Error("expected the thought to be marked factual")
	}

	// Undoing has to be possible: without it a mistaken judgement could never
	// be corrected, since attaching a bias afterwards would be refused.
	unmarked, err := SetThoughtFactual(db, testUserID, thoughtID, false)
	if err != nil {
		t.Fatalf("failed to undo the judgement: %v", err)
	}
	if unmarked.Thoughts[0].IsFactual {
		t.Error("expected the judgement to be undone")
	}
}

func TestSetThoughtFactualRejectsAThoughtCarryingABias(t *testing.T) {
	db := setupTestDB(t)

	record, err := CreateThoughtRecord(db, testUserID, CreateThoughtRecordInput{
		Event:    "a meeting was moved without telling me",
		Thoughts: []ThoughtInput{{Body: "they do not think my input matters", Biases: []string{"mind-reading"}}},
	})
	if err != nil {
		t.Fatalf("failed to create the record: %v", err)
	}

	// Silently detaching the bias would discard work the user had already
	// done, so the contradiction is reported instead.
	if _, err := SetThoughtFactual(db, testUserID, record.Thoughts[0].ID, true); !errors.Is(err, ErrThoughtFactualWithBias) {
		t.Errorf("expected ErrThoughtFactualWithBias but got %v", err)
	}
}

func TestSetThoughtFactualIsScopedToTheUser(t *testing.T) {
	db := setupTestDB(t)

	record, err := CreateThoughtRecord(db, testUserID, CreateThoughtRecordInput{
		Event:    "my event",
		Thoughts: []ThoughtInput{{Body: "my thought"}},
	})
	if err != nil {
		t.Fatalf("failed to create the record: %v", err)
	}

	if _, err := SetThoughtFactual(db, otherUserID, record.Thoughts[0].ID, true); !errors.Is(err, ErrThoughtNotFound) {
		t.Errorf("expected ErrThoughtNotFound but got %v", err)
	}
}

func TestNewThoughtIsNeitherFactualNorBiased(t *testing.T) {
	db := setupTestDB(t)

	record, err := CreateThoughtRecord(db, testUserID, CreateThoughtRecordInput{
		Event:    "a report came back covered in comments",
		Thoughts: []ThoughtInput{{Body: "my work is not good enough"}},
	})
	if err != nil {
		t.Fatalf("failed to create the record: %v", err)
	}

	// Carrying no biases is the state every thought starts in, so it cannot by
	// itself mean the thought was judged accurate. A new thought must assert
	// nothing either way.
	if record.Thoughts[0].IsFactual {
		t.Error("expected a new thought not to claim to be factual")
	}
	if len(record.Thoughts[0].Biases) != 0 {
		t.Errorf("expected a new thought to carry no biases but got %d", len(record.Thoughts[0].Biases))
	}
}
