package database

import (
	"errors"
	"testing"
	"time"
)

func TestCreateThoughtRecordRequiresAnEvent(t *testing.T) {
	db := setupTestDB(t)

	tests := []struct {
		name  string
		event string
	}{
		{"empty", ""},
		{"whitespace only", "   "},
	}

	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			if _, err := CreateThoughtRecord(db, testUserID, CreateThoughtRecordInput{Event: test.event}); !errors.Is(err, ErrEventEmpty) {
				t.Errorf("expected ErrEventEmpty but got %v", err)
			}
		})
	}
}

func TestCreateThoughtRecordAcceptsTheEventAlone(t *testing.T) {
	db := setupTestDB(t)

	// A record is routinely opened in the moment with nothing but the event
	// and completed over the hours that follow, so every other column has to
	// be optional.
	record, err := CreateThoughtRecord(db, testUserID, CreateThoughtRecordInput{
		Event: "a meeting was moved without telling me",
	})
	if err != nil {
		t.Fatalf("failed to create the thought record: %v", err)
	}

	if record.Event != "a meeting was moved without telling me" {
		t.Errorf("unexpected event %q", record.Event)
	}
	if record.ChallengedAt != nil {
		t.Error("expected a new record to be unchallenged")
	}
	if len(record.Thoughts) != 0 || len(record.Feelings) != 0 {
		t.Errorf("expected no thoughts or feelings but got %d and %d", len(record.Thoughts), len(record.Feelings))
	}
}

func TestCreateThoughtRecordStoresThoughtsAndFeelings(t *testing.T) {
	db := setupTestDB(t)

	record, err := CreateThoughtRecord(db, testUserID, CreateThoughtRecordInput{
		Event: "a meeting was moved without telling me",
		Thoughts: []ThoughtInput{
			{Body: "they do not think my input matters", IsHot: true, Biases: []string{"mind-reading"}},
			{Body: "I will be left out of the next one"},
		},
		Feelings: []FeelingInput{
			{Name: "Annoyed", Intensity: intPtr(70)},
			{Name: "anxious"},
		},
	})
	if err != nil {
		t.Fatalf("failed to create the thought record: %v", err)
	}

	if len(record.Thoughts) != 2 {
		t.Fatalf("expected 2 thoughts but got %d", len(record.Thoughts))
	}
	if len(record.Feelings) != 2 {
		t.Fatalf("expected 2 feelings but got %d", len(record.Feelings))
	}

	var hot *NegativeThought
	for index := range record.Thoughts {
		if record.Thoughts[index].IsHot {
			hot = &record.Thoughts[index]
		}
	}
	if hot == nil {
		t.Fatal("expected one thought to be marked as the strongest")
	}
	if len(hot.Biases) != 1 || hot.Biases[0].Name != "mind-reading" {
		t.Errorf("expected the hot thought to carry the mind-reading bias but got %v", hot.Biases)
	}

	// Feeling names are normalised so the same emotion spelled differently
	// aggregates across records.
	if record.Feelings[0].Name != "annoyed" {
		t.Errorf("expected the feeling name to be normalised but got %q", record.Feelings[0].Name)
	}
	if record.Feelings[0].IntensityBefore == nil || *record.Feelings[0].IntensityBefore != 70 {
		t.Errorf("expected an intensity of 70 but got %v", record.Feelings[0].IntensityBefore)
	}
	if record.Feelings[1].IntensityBefore != nil {
		t.Error("expected an unrated feeling to carry no intensity")
	}
}

func TestCreateThoughtRecordRejectsUnknownBiases(t *testing.T) {
	db := setupTestDB(t)

	// A bias is a vocabulary term, not a free tag: an unrecognised name is far
	// more likely a typo than an intent to coin a new distortion.
	_, err := CreateThoughtRecord(db, testUserID, CreateThoughtRecordInput{
		Event:    "an event",
		Thoughts: []ThoughtInput{{Body: "a thought", Biases: []string{"catastrophizing"}}},
	})
	if !errors.Is(err, ErrBiasNotFound) {
		t.Errorf("expected ErrBiasNotFound but got %v", err)
	}
}

func TestCreateThoughtRecordIsAtomic(t *testing.T) {
	db := setupTestDB(t)

	// The second thought is rejected, so the record that was written first
	// must be rolled back rather than left half built.
	_, err := CreateThoughtRecord(db, testUserID, CreateThoughtRecordInput{
		Event: "an event",
		Thoughts: []ThoughtInput{
			{Body: "a valid thought"},
			{Body: "   "},
		},
	})
	if !errors.Is(err, ErrThoughtBodyEmpty) {
		t.Fatalf("expected ErrThoughtBodyEmpty but got %v", err)
	}

	records, err := ListThoughtRecords(db, testUserID, ThoughtRecordFilter{})
	if err != nil {
		t.Fatalf("failed to list the thought records: %v", err)
	}
	if len(records) != 0 {
		t.Errorf("expected the failed creation to leave no records but got %d", len(records))
	}
}

func TestCreateThoughtRecordRejectsMultipleHotThoughts(t *testing.T) {
	db := setupTestDB(t)

	_, err := CreateThoughtRecord(db, testUserID, CreateThoughtRecordInput{
		Event: "an event",
		Thoughts: []ThoughtInput{
			{Body: "first", IsHot: true},
			{Body: "second", IsHot: true},
		},
	})
	if !errors.Is(err, ErrMultipleHotThoughts) {
		t.Errorf("expected ErrMultipleHotThoughts but got %v", err)
	}
}

func TestCreateThoughtRecordRejectsAnIntensityOutOfRange(t *testing.T) {
	db := setupTestDB(t)

	tests := []struct {
		name      string
		intensity int
	}{
		{"below zero", -1},
		{"above one hundred", 101},
	}

	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			_, err := CreateThoughtRecord(db, testUserID, CreateThoughtRecordInput{
				Event:    "an event",
				Feelings: []FeelingInput{{Name: "anxious", Intensity: intPtr(test.intensity)}},
			})
			if !errors.Is(err, ErrFeelingIntensityRange) {
				t.Errorf("expected ErrFeelingIntensityRange but got %v", err)
			}
		})
	}
}

func TestChallengeThoughtRecordStampsAndFills(t *testing.T) {
	db := setupTestDB(t)

	record, err := CreateThoughtRecord(db, testUserID, CreateThoughtRecordInput{
		Event:    "a meeting was moved without telling me",
		Thoughts: []ThoughtInput{{Body: "they do not think my input matters", IsHot: true}},
		Feelings: []FeelingInput{{Name: "anxious", Intensity: intPtr(80)}},
	})
	if err != nil {
		t.Fatalf("failed to create the thought record: %v", err)
	}

	challenged, err := ChallengeThoughtRecord(db, testUserID, record.ID, ChallengeInput{
		AlternativeView:         "the invite may simply have failed to send",
		FeelingsNow:             "calmer",
		FeelingIntensitiesAfter: map[uint]int{record.Feelings[0].ID: 20},
		Thoughts:                map[uint]ThoughtJudgement{record.Thoughts[0].ID: {Biases: []string{"catastrophising"}}},
	})
	if err != nil {
		t.Fatalf("failed to challenge the thought record: %v", err)
	}

	if challenged.ChallengedAt == nil {
		t.Error("expected the record to be stamped as challenged")
	}
	if challenged.AlternativeView != "the invite may simply have failed to send" {
		t.Errorf("unexpected alternative view %q", challenged.AlternativeView)
	}
	if challenged.FeelingsNow != "calmer" {
		t.Errorf("unexpected feelings now %q", challenged.FeelingsNow)
	}

	// The re-rating is the point of the exercise: it is how the user sees
	// whether the alternative view landed.
	after := challenged.Feelings[0].IntensityAfter
	if after == nil || *after != 20 {
		t.Errorf("expected the feeling to be re-rated to 20 but got %v", after)
	}
	if len(challenged.Thoughts[0].Biases) != 1 || challenged.Thoughts[0].Biases[0].Name != "catastrophising" {
		t.Errorf("expected the thought to carry the catastrophising bias but got %v", challenged.Thoughts[0].Biases)
	}
}

func TestChallengeThoughtRecordReplacesBiasesRatherThanAdding(t *testing.T) {
	db := setupTestDB(t)

	record, err := CreateThoughtRecord(db, testUserID, CreateThoughtRecordInput{
		Event:    "an event",
		Thoughts: []ThoughtInput{{Body: "a thought", Biases: []string{"blaming"}}},
	})
	if err != nil {
		t.Fatalf("failed to create the thought record: %v", err)
	}

	// Re-running a challenge with a corrected list must leave the corrected
	// list, not the union of both attempts.
	challenged, err := ChallengeThoughtRecord(db, testUserID, record.ID, ChallengeInput{
		Thoughts: map[uint]ThoughtJudgement{record.Thoughts[0].ID: {Biases: []string{"self-blame"}}},
	})
	if err != nil {
		t.Fatalf("failed to challenge the thought record: %v", err)
	}

	if len(challenged.Thoughts[0].Biases) != 1 {
		t.Fatalf("expected exactly 1 bias but got %d", len(challenged.Thoughts[0].Biases))
	}
	if challenged.Thoughts[0].Biases[0].Name != "self-blame" {
		t.Errorf("expected the bias to be replaced but got %q", challenged.Thoughts[0].Biases[0].Name)
	}
}

func TestChallengeThoughtRecordRejectsForeignChildren(t *testing.T) {
	db := setupTestDB(t)

	first, err := CreateThoughtRecord(db, testUserID, CreateThoughtRecordInput{
		Event:    "first event",
		Thoughts: []ThoughtInput{{Body: "first thought"}},
		Feelings: []FeelingInput{{Name: "anxious"}},
	})
	if err != nil {
		t.Fatalf("failed to create the first record: %v", err)
	}
	second, err := CreateThoughtRecord(db, testUserID, CreateThoughtRecordInput{Event: "second event"})
	if err != nil {
		t.Fatalf("failed to create the second record: %v", err)
	}

	// A mistyped identifier must not quietly rewrite an unrelated entry.
	t.Run("feeling", func(t *testing.T) {
		_, err := ChallengeThoughtRecord(db, testUserID, second.ID, ChallengeInput{
			FeelingIntensitiesAfter: map[uint]int{first.Feelings[0].ID: 10},
		})
		if !errors.Is(err, ErrFeelingNotFound) {
			t.Errorf("expected ErrFeelingNotFound but got %v", err)
		}
	})
	t.Run("thought", func(t *testing.T) {
		_, err := ChallengeThoughtRecord(db, testUserID, second.ID, ChallengeInput{
			Thoughts: map[uint]ThoughtJudgement{first.Thoughts[0].ID: {Biases: []string{"blaming"}}},
		})
		if !errors.Is(err, ErrThoughtNotFound) {
			t.Errorf("expected ErrThoughtNotFound but got %v", err)
		}
	})
}

func TestChallengeThoughtRecordIsRepeatable(t *testing.T) {
	db := setupTestDB(t)

	record, err := CreateThoughtRecord(db, testUserID, CreateThoughtRecordInput{Event: "an event"})
	if err != nil {
		t.Fatalf("failed to create the thought record: %v", err)
	}

	first, err := ChallengeThoughtRecord(db, testUserID, record.ID, ChallengeInput{AlternativeView: "first attempt"})
	if err != nil {
		t.Fatalf("failed to challenge the thought record: %v", err)
	}

	// Coming back to a record with a clearer head is the practice working, not
	// a conflict to reject.
	second, err := ChallengeThoughtRecord(db, testUserID, record.ID, ChallengeInput{AlternativeView: "a better attempt"})
	if err != nil {
		t.Fatalf("failed to challenge the record a second time: %v", err)
	}
	if second.AlternativeView != "a better attempt" {
		t.Errorf("unexpected alternative view %q", second.AlternativeView)
	}
	if second.ChallengedAt.Before(*first.ChallengedAt) {
		t.Error("expected the record to be re-stamped on a second challenge")
	}
}

func TestListThoughtRecordsFiltersByChallengeState(t *testing.T) {
	db := setupTestDB(t)

	pending, err := CreateThoughtRecord(db, testUserID, CreateThoughtRecordInput{Event: "unchallenged event"})
	if err != nil {
		t.Fatalf("failed to create the pending record: %v", err)
	}
	done, err := CreateThoughtRecord(db, testUserID, CreateThoughtRecordInput{Event: "challenged event"})
	if err != nil {
		t.Fatalf("failed to create the record to challenge: %v", err)
	}
	if _, err := ChallengeThoughtRecord(db, testUserID, done.ID, ChallengeInput{AlternativeView: "another view"}); err != nil {
		t.Fatalf("failed to challenge the record: %v", err)
	}

	unchallenged := false
	challenged := true
	tests := []struct {
		name     string
		filter   ThoughtRecordFilter
		expected []uint
	}{
		{"unchallenged is the work queue", ThoughtRecordFilter{Challenged: &unchallenged}, []uint{pending.ID}},
		{"challenged", ThoughtRecordFilter{Challenged: &challenged}, []uint{done.ID}},
		{"unfiltered returns both", ThoughtRecordFilter{}, []uint{done.ID, pending.ID}},
	}

	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			records, err := ListThoughtRecords(db, testUserID, test.filter)
			if err != nil {
				t.Fatalf("failed to list the thought records: %v", err)
			}
			if len(records) != len(test.expected) {
				t.Fatalf("expected %d records but got %d", len(test.expected), len(records))
			}
			for index, id := range test.expected {
				if records[index].ID != id {
					t.Errorf("expected record %d at position %d but got %d", id, index, records[index].ID)
				}
			}
		})
	}
}

func TestListThoughtRecordsOrdersByWhenTheEventHappened(t *testing.T) {
	db := setupTestDB(t)

	// The record typed second describes something that happened days earlier,
	// so it must sort last. Ordering by the creation time would invert this.
	older := time.Now().Add(-72 * time.Hour)
	recent, err := CreateThoughtRecord(db, testUserID, CreateThoughtRecordInput{Event: "this morning"})
	if err != nil {
		t.Fatalf("failed to create the recent record: %v", err)
	}
	backdated, err := CreateThoughtRecord(db, testUserID, CreateThoughtRecordInput{
		Event:      "three days ago",
		OccurredAt: &older,
	})
	if err != nil {
		t.Fatalf("failed to create the backdated record: %v", err)
	}

	records, err := ListThoughtRecords(db, testUserID, ThoughtRecordFilter{})
	if err != nil {
		t.Fatalf("failed to list the thought records: %v", err)
	}
	if len(records) != 2 {
		t.Fatalf("expected 2 records but got %d", len(records))
	}
	if records[0].ID != recent.ID || records[1].ID != backdated.ID {
		t.Errorf("expected the backdated record to sort last but got %d then %d", records[0].ID, records[1].ID)
	}
}

func TestListThoughtRecordsSearchesThoughtBodies(t *testing.T) {
	db := setupTestDB(t)

	match, err := CreateThoughtRecord(db, testUserID, CreateThoughtRecordInput{
		Event:    "an unremarkable event",
		Thoughts: []ThoughtInput{{Body: "the last train was cancelled again"}},
	})
	if err != nil {
		t.Fatalf("failed to create the matching record: %v", err)
	}
	if _, err := CreateThoughtRecord(db, testUserID, CreateThoughtRecordInput{Event: "something else entirely"}); err != nil {
		t.Fatalf("failed to create the other record: %v", err)
	}

	// Searching only the event would miss the record whose subject is stated
	// in the thought rather than the situation.
	records, err := ListThoughtRecords(db, testUserID, ThoughtRecordFilter{Search: "CANCELLED"})
	if err != nil {
		t.Fatalf("failed to search the thought records: %v", err)
	}
	if len(records) != 1 || records[0].ID != match.ID {
		t.Fatalf("expected only the matching record but got %d records", len(records))
	}
}

func TestListThoughtRecordsIsScopedToTheUser(t *testing.T) {
	db := setupTestDB(t)

	if _, err := CreateThoughtRecord(db, testUserID, CreateThoughtRecordInput{Event: "my event"}); err != nil {
		t.Fatalf("failed to create the record: %v", err)
	}

	records, err := ListThoughtRecords(db, otherUserID, ThoughtRecordFilter{})
	if err != nil {
		t.Fatalf("failed to list the other user's records: %v", err)
	}
	if len(records) != 0 {
		t.Errorf("expected another user to see no records but got %d", len(records))
	}
}

func TestGetThoughtRecordHidesOtherUsersRecords(t *testing.T) {
	db := setupTestDB(t)

	record, err := CreateThoughtRecord(db, testUserID, CreateThoughtRecordInput{Event: "my event"})
	if err != nil {
		t.Fatalf("failed to create the record: %v", err)
	}

	// Not found rather than forbidden, so the existence of the record is not
	// leaked to another user.
	if _, err := GetThoughtRecord(db, otherUserID, record.ID); !errors.Is(err, ErrThoughtRecordNotFound) {
		t.Errorf("expected ErrThoughtRecordNotFound but got %v", err)
	}
}

func TestUpdateThoughtRecordLeavesUnsetColumnsAlone(t *testing.T) {
	db := setupTestDB(t)

	record, err := CreateThoughtRecord(db, testUserID, CreateThoughtRecordInput{
		Event:           "an event",
		AlternativeView: "an early alternative",
	})
	if err != nil {
		t.Fatalf("failed to create the record: %v", err)
	}

	// Filling one column at a time is how a record is completed, so a nil
	// field must not blank out what is already there.
	feelingsNow := "steadier"
	updated, err := UpdateThoughtRecord(db, testUserID, record.ID, UpdateThoughtRecordInput{FeelingsNow: &feelingsNow})
	if err != nil {
		t.Fatalf("failed to update the record: %v", err)
	}

	if updated.AlternativeView != "an early alternative" {
		t.Errorf("expected the alternative view to survive but got %q", updated.AlternativeView)
	}
	if updated.FeelingsNow != "steadier" {
		t.Errorf("unexpected feelings now %q", updated.FeelingsNow)
	}
}

func TestUpdateThoughtRecordCanClearTheEventTime(t *testing.T) {
	db := setupTestDB(t)

	occurred := time.Now().Add(-time.Hour)
	record, err := CreateThoughtRecord(db, testUserID, CreateThoughtRecordInput{
		Event:      "an event",
		OccurredAt: &occurred,
	})
	if err != nil {
		t.Fatalf("failed to create the record: %v", err)
	}

	// A nil OccurredAt means "leave it alone", so clearing needs its own flag.
	updated, err := UpdateThoughtRecord(db, testUserID, record.ID, UpdateThoughtRecordInput{ClearOccurredAt: true})
	if err != nil {
		t.Fatalf("failed to update the record: %v", err)
	}
	if updated.OccurredAt != nil {
		t.Errorf("expected the event time to be cleared but got %v", updated.OccurredAt)
	}
}

func TestUpdateThoughtRecordRejectsABlankEvent(t *testing.T) {
	db := setupTestDB(t)

	record, err := CreateThoughtRecord(db, testUserID, CreateThoughtRecordInput{Event: "an event"})
	if err != nil {
		t.Fatalf("failed to create the record: %v", err)
	}

	blank := "   "
	if _, err := UpdateThoughtRecord(db, testUserID, record.ID, UpdateThoughtRecordInput{Event: &blank}); !errors.Is(err, ErrEventEmpty) {
		t.Errorf("expected ErrEventEmpty but got %v", err)
	}
}

func TestDeleteThoughtRecordRemovesItsChildren(t *testing.T) {
	db := setupTestDB(t)

	record, err := CreateThoughtRecord(db, testUserID, CreateThoughtRecordInput{
		Event:    "an event",
		Thoughts: []ThoughtInput{{Body: "a thought"}},
		Feelings: []FeelingInput{{Name: "anxious"}},
	})
	if err != nil {
		t.Fatalf("failed to create the record: %v", err)
	}

	if err := DeleteThoughtRecord(db, testUserID, record.ID); err != nil {
		t.Fatalf("failed to delete the record: %v", err)
	}

	// GORM does not cascade a soft delete to associations, so the children are
	// removed explicitly and must not be left behind.
	var thoughts int64
	if err := db.Model(&NegativeThought{}).Where("thought_record_id = ?", record.ID).Count(&thoughts).Error; err != nil {
		t.Fatalf("failed to count the thoughts: %v", err)
	}
	if thoughts != 0 {
		t.Errorf("expected the thoughts to be deleted but %d remain", thoughts)
	}

	var feelings int64
	if err := db.Model(&Feeling{}).Where("thought_record_id = ?", record.ID).Count(&feelings).Error; err != nil {
		t.Fatalf("failed to count the feelings: %v", err)
	}
	if feelings != 0 {
		t.Errorf("expected the feelings to be deleted but %d remain", feelings)
	}
}

func TestDeleteThoughtRecordIsScopedToTheUser(t *testing.T) {
	db := setupTestDB(t)

	record, err := CreateThoughtRecord(db, testUserID, CreateThoughtRecordInput{Event: "my event"})
	if err != nil {
		t.Fatalf("failed to create the record: %v", err)
	}

	if err := DeleteThoughtRecord(db, otherUserID, record.ID); !errors.Is(err, ErrThoughtRecordNotFound) {
		t.Errorf("expected ErrThoughtRecordNotFound but got %v", err)
	}
}

func TestChallengeThoughtRecordClearsBiasesWhenGivenAnEmptyList(t *testing.T) {
	db := setupTestDB(t)

	record, err := CreateThoughtRecord(db, testUserID, CreateThoughtRecordInput{
		Event:    "a meeting was moved without telling me",
		Thoughts: []ThoughtInput{{Body: "they do not think my input matters", Biases: []string{"mind-reading"}}},
	})
	if err != nil {
		t.Fatalf("failed to create the record: %v", err)
	}

	// Detaching every bias is how a thought carrying no distortion is
	// recorded, and how a bias attached by mistake is taken off again. The
	// mobile challenge screen sends exactly this when no chip is selected.
	challenged, err := ChallengeThoughtRecord(db, testUserID, record.ID, ChallengeInput{
		Thoughts: map[uint]ThoughtJudgement{record.Thoughts[0].ID: {Biases: []string{}}},
	})
	if err != nil {
		t.Fatalf("failed to challenge the record: %v", err)
	}

	if len(challenged.Thoughts[0].Biases) != 0 {
		t.Errorf("expected the biases to be detached but got %d", len(challenged.Thoughts[0].Biases))
	}
}

func TestChallengeThoughtRecordKeepsBiasesWhenTheListIsNil(t *testing.T) {
	db := setupTestDB(t)

	record, err := CreateThoughtRecord(db, testUserID, CreateThoughtRecordInput{
		Event:    "a meeting was moved without telling me",
		Thoughts: []ThoughtInput{{Body: "they do not think my input matters", Biases: []string{"mind-reading"}}},
	})
	if err != nil {
		t.Fatalf("failed to create the record: %v", err)
	}

	// A nil list means "leave them alone", which is what lets a judgement
	// record something else about the thought without redoing the bias work.
	challenged, err := ChallengeThoughtRecord(db, testUserID, record.ID, ChallengeInput{
		Thoughts: map[uint]ThoughtJudgement{record.Thoughts[0].ID: {}},
	})
	if err != nil {
		t.Fatalf("failed to challenge the record: %v", err)
	}

	if len(challenged.Thoughts[0].Biases) != 1 {
		t.Errorf("expected the bias to survive but got %d", len(challenged.Thoughts[0].Biases))
	}
}

func TestChallengeThoughtRecordMarksAThoughtFactual(t *testing.T) {
	db := setupTestDB(t)

	record, err := CreateThoughtRecord(db, testUserID, CreateThoughtRecordInput{
		Event:    "the last train was cancelled",
		Thoughts: []ThoughtInput{{Body: "I will not get home before midnight"}},
	})
	if err != nil {
		t.Fatalf("failed to create the record: %v", err)
	}

	// Accepting that a thought was accurate is a real outcome of the exercise,
	// not an absence of one, so it is recorded rather than left implicit.
	challenged, err := ChallengeThoughtRecord(db, testUserID, record.ID, ChallengeInput{
		Thoughts: map[uint]ThoughtJudgement{record.Thoughts[0].ID: {IsFactual: true}},
	})
	if err != nil {
		t.Fatalf("failed to challenge the record: %v", err)
	}

	if !challenged.Thoughts[0].IsFactual {
		t.Error("expected the thought to be marked factual")
	}
}

func TestChallengeThoughtRecordRejectsFactualWithABias(t *testing.T) {
	db := setupTestDB(t)

	record, err := CreateThoughtRecord(db, testUserID, CreateThoughtRecordInput{
		Event:    "a meeting was moved without telling me",
		Thoughts: []ThoughtInput{{Body: "they do not think my input matters", Biases: []string{"mind-reading"}}},
	})
	if err != nil {
		t.Fatalf("failed to create the record: %v", err)
	}

	tests := []struct {
		name      string
		judgement ThoughtJudgement
	}{
		{
			// The contradiction is stated within the one request.
			"named in the same judgement",
			ThoughtJudgement{Biases: []string{"mind-reading"}, IsFactual: true},
		},
		{
			// The bias was attached by an earlier sitting and is not mentioned
			// here, so the check has to look at the stored state too.
			"attached earlier and left alone",
			ThoughtJudgement{IsFactual: true},
		},
	}

	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			_, err := ChallengeThoughtRecord(db, testUserID, record.ID, ChallengeInput{
				Thoughts: map[uint]ThoughtJudgement{record.Thoughts[0].ID: test.judgement},
			})
			if !errors.Is(err, ErrThoughtFactualWithBias) {
				t.Errorf("expected ErrThoughtFactualWithBias but got %v", err)
			}
		})
	}
}
