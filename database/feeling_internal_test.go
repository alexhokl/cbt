package database

import (
	"errors"
	"testing"

	"gorm.io/gorm"
)

func TestAddFeelingAttachesToTheRecord(t *testing.T) {
	db := setupTestDB(t)

	record, err := CreateThoughtRecord(db, testUserID, CreateThoughtRecordInput{Event: "an event"})
	if err != nil {
		t.Fatalf("failed to create the record: %v", err)
	}

	updated, err := AddFeeling(db, testUserID, record.ID, FeelingInput{Name: "Ashamed", Intensity: intPtr(45)})
	if err != nil {
		t.Fatalf("failed to add the feeling: %v", err)
	}

	if len(updated.Feelings) != 1 {
		t.Fatalf("expected 1 feeling but got %d", len(updated.Feelings))
	}
	if updated.Feelings[0].Name != "ashamed" {
		t.Errorf("expected the name to be normalised but got %q", updated.Feelings[0].Name)
	}
}

func TestAddFeelingRejectsABlankName(t *testing.T) {
	db := setupTestDB(t)

	record, err := CreateThoughtRecord(db, testUserID, CreateThoughtRecordInput{Event: "an event"})
	if err != nil {
		t.Fatalf("failed to create the record: %v", err)
	}

	// A feeling the caller bothered to send but did not name is a mistake
	// worth reporting, not a row to discard silently.
	if _, err := AddFeeling(db, testUserID, record.ID, FeelingInput{Name: "  "}); !errors.Is(err, ErrFeelingNameEmpty) {
		t.Errorf("expected ErrFeelingNameEmpty but got %v", err)
	}
}

func TestDeleteFeelingIsScopedToTheUser(t *testing.T) {
	db := setupTestDB(t)

	record, err := CreateThoughtRecord(db, testUserID, CreateThoughtRecordInput{
		Event:    "my event",
		Feelings: []FeelingInput{{Name: "anxious"}},
	})
	if err != nil {
		t.Fatalf("failed to create the record: %v", err)
	}

	if err := DeleteFeeling(db, otherUserID, record.Feelings[0].ID); !errors.Is(err, ErrFeelingNotFound) {
		t.Errorf("expected ErrFeelingNotFound but got %v", err)
	}
}

// The remaining tests write through GORM directly rather than through the
// operations, because the operations are careful never to produce these rows.
// The point is that the database refuses them anyway, so a future code path
// that bypasses this package cannot leave a row the rest of the application
// cannot make sense of.

func TestFeelingsTriggerRejectsRowsWithoutAParent(t *testing.T) {
	db := setupTestDB(t)

	feeling := Feeling{Name: "anxious", UserID: testUserID}
	if err := db.Create(&feeling).Error; err == nil {
		t.Error("expected an orphaned feeling to be rejected")
	}
}

func TestFeelingsTriggerRejectsRowsWithTwoParents(t *testing.T) {
	db := setupTestDB(t)

	record, err := CreateThoughtRecord(db, testUserID, CreateThoughtRecordInput{Event: "an event"})
	if err != nil {
		t.Fatalf("failed to create the record: %v", err)
	}
	mapOfWorry, err := CreateMapOfWorry(db, testUserID, CreateMapOfWorryInput{Event: "an event"})
	if err != nil {
		t.Fatalf("failed to create the map: %v", err)
	}

	// A feeling with two parents would appear on two unrelated records.
	feeling := Feeling{
		Name:            "anxious",
		UserID:          testUserID,
		ThoughtRecordID: &record.ID,
		MapOfWorryID:    &mapOfWorry.ID,
	}
	if err := db.Create(&feeling).Error; err == nil {
		t.Error("expected a feeling with two parents to be rejected")
	}
}

func TestFeelingsTriggerRejectsAnIntensityOutOfRange(t *testing.T) {
	db := setupTestDB(t)

	record, err := CreateThoughtRecord(db, testUserID, CreateThoughtRecordInput{Event: "an event"})
	if err != nil {
		t.Fatalf("failed to create the record: %v", err)
	}

	tests := []struct {
		name      string
		intensity int
	}{
		{"below zero", -5},
		{"above one hundred", 150},
	}

	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			feeling := Feeling{
				Name:            "anxious",
				UserID:          testUserID,
				ThoughtRecordID: &record.ID,
				IntensityBefore: intPtr(test.intensity),
			}
			if err := db.Create(&feeling).Error; err == nil {
				t.Error("expected an out of range intensity to be rejected")
			}
		})
	}
}

func TestFeelingsTriggerRejectsRerating0nAMapOfWorry(t *testing.T) {
	db := setupTestDB(t)

	mapOfWorry, err := CreateMapOfWorry(db, testUserID, CreateMapOfWorryInput{
		Event:    "an event",
		Feelings: []FeelingInput{{Name: "anxious", Intensity: intPtr(60)}},
	})
	if err != nil {
		t.Fatalf("failed to create the map: %v", err)
	}

	// A map of worry has no challenge step, so its feelings are rated once.
	err = db.Model(&Feeling{}).
		Where("id = ?", mapOfWorry.Feelings[0].ID).
		Update("intensity_after", 20).Error
	if err == nil {
		t.Error("expected re-rating a map's feeling to be rejected")
	}
}

func TestThoughtsTriggerRejectsASecondHotThought(t *testing.T) {
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

	// SetHotThought clears the previous flag first; writing directly skips
	// that step and must be refused.
	err = db.Model(&NegativeThought{}).
		Where("id = ?", record.Thoughts[1].ID).
		Update("is_hot", true).Error
	if err == nil {
		t.Error("expected a second hot thought to be rejected")
	}
}

func TestMapsTriggerRejectsSelfDerivation(t *testing.T) {
	db := setupTestDB(t)

	mapOfWorry, err := CreateMapOfWorry(db, testUserID, CreateMapOfWorryInput{Event: "an event"})
	if err != nil {
		t.Fatalf("failed to create the map: %v", err)
	}

	err = db.Model(&MapOfWorry{}).
		Where("id = ?", mapOfWorry.ID).
		Update("derived_from_id", mapOfWorry.ID).Error
	if err == nil {
		t.Error("expected a map derived from itself to be rejected")
	}
	if err != nil && errors.Is(err, gorm.ErrRecordNotFound) {
		t.Errorf("expected a constraint violation but got %v", err)
	}
}
