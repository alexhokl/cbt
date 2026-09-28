package database

import (
	"errors"
	"testing"
)

func TestCreateMapOfWorryStoresEveryColumn(t *testing.T) {
	db := setupTestDB(t)

	mapOfWorry, err := CreateMapOfWorry(db, testUserID, CreateMapOfWorryInput{
		Event:                 "a report came back covered in comments",
		Thoughts:              "my work is not good enough",
		WhatTheseThoughtsMean: "sooner or later they will work out I cannot do this",
		PhysicalSensations:    "tight chest",
		ResultantBehaviour:    "put off opening the review until the next morning",
		Feelings:              []FeelingInput{{Name: "anxious", Intensity: intPtr(65)}},
	})
	if err != nil {
		t.Fatalf("failed to create the map: %v", err)
	}

	if mapOfWorry.WhatTheseThoughtsMean != "sooner or later they will work out I cannot do this" {
		t.Errorf("unexpected meaning %q", mapOfWorry.WhatTheseThoughtsMean)
	}
	if mapOfWorry.ResultantBehaviour != "put off opening the review until the next morning" {
		t.Errorf("unexpected behaviour %q", mapOfWorry.ResultantBehaviour)
	}
	if len(mapOfWorry.Feelings) != 1 || mapOfWorry.Feelings[0].Name != "anxious" {
		t.Errorf("expected one anxious feeling but got %v", mapOfWorry.Feelings)
	}
}

func TestCreateMapOfWorryRequiresAnEvent(t *testing.T) {
	db := setupTestDB(t)

	if _, err := CreateMapOfWorry(db, testUserID, CreateMapOfWorryInput{Event: "  "}); !errors.Is(err, ErrEventEmpty) {
		t.Errorf("expected ErrEventEmpty but got %v", err)
	}
}

func TestCreateMapOfWorryLinksTheAlternative(t *testing.T) {
	db := setupTestDB(t)

	origin, err := CreateMapOfWorry(db, testUserID, CreateMapOfWorryInput{
		Event:              "a report came back covered in comments",
		Thoughts:           "my work is not good enough",
		ResultantBehaviour: "put off opening the review until the next morning",
	})
	if err != nil {
		t.Fatalf("failed to create the original map: %v", err)
	}

	// The contrast between the two readings of the same event is the whole
	// point of the exercise, so the link is modelled rather than left implicit.
	alternative, err := CreateMapOfWorry(db, testUserID, CreateMapOfWorryInput{
		Event:              "a report came back covered in comments",
		Thoughts:           "the comments are detailed because someone read it properly",
		ResultantBehaviour: "worked through the comments one at a time",
		DerivedFromID:      &origin.ID,
	})
	if err != nil {
		t.Fatalf("failed to create the alternative map: %v", err)
	}

	if alternative.DerivedFromID == nil || *alternative.DerivedFromID != origin.ID {
		t.Fatalf("expected the alternative to be derived from %d but got %v", origin.ID, alternative.DerivedFromID)
	}
	if alternative.DerivedFrom == nil {
		t.Fatal("expected the original map to be loaded alongside the alternative")
	}
	if alternative.DerivedFrom.ResultantBehaviour != "put off opening the review until the next morning" {
		t.Errorf("unexpected original behaviour %q", alternative.DerivedFrom.ResultantBehaviour)
	}
}

func TestCreateMapOfWorryRejectsAnUnknownOrigin(t *testing.T) {
	db := setupTestDB(t)

	missing := uint(404)
	_, err := CreateMapOfWorry(db, testUserID, CreateMapOfWorryInput{
		Event:         "an event",
		DerivedFromID: &missing,
	})
	if !errors.Is(err, ErrMapOfWorryNotFound) {
		t.Errorf("expected ErrMapOfWorryNotFound but got %v", err)
	}
}

func TestCreateMapOfWorryRejectsAnotherUsersOrigin(t *testing.T) {
	db := setupTestDB(t)

	origin, err := CreateMapOfWorry(db, testUserID, CreateMapOfWorryInput{Event: "my event"})
	if err != nil {
		t.Fatalf("failed to create the original map: %v", err)
	}

	// Deriving from a map you cannot see would otherwise leak its existence.
	_, err = CreateMapOfWorry(db, otherUserID, CreateMapOfWorryInput{
		Event:         "their event",
		DerivedFromID: &origin.ID,
	})
	if !errors.Is(err, ErrMapOfWorryNotFound) {
		t.Errorf("expected ErrMapOfWorryNotFound but got %v", err)
	}
}

func TestListAlternativesReturnsTheReworkings(t *testing.T) {
	db := setupTestDB(t)

	origin, err := CreateMapOfWorry(db, testUserID, CreateMapOfWorryInput{Event: "an event"})
	if err != nil {
		t.Fatalf("failed to create the original map: %v", err)
	}
	alternative, err := CreateMapOfWorry(db, testUserID, CreateMapOfWorryInput{
		Event:         "an event",
		DerivedFromID: &origin.ID,
	})
	if err != nil {
		t.Fatalf("failed to create the alternative map: %v", err)
	}

	alternatives, err := ListAlternatives(db, testUserID, origin.ID)
	if err != nil {
		t.Fatalf("failed to list the alternatives: %v", err)
	}
	if len(alternatives) != 1 || alternatives[0].ID != alternative.ID {
		t.Fatalf("expected the alternative to be returned but got %d maps", len(alternatives))
	}
}

func TestDeleteMapOfWorryRejectsOneWithAlternatives(t *testing.T) {
	db := setupTestDB(t)

	origin, err := CreateMapOfWorry(db, testUserID, CreateMapOfWorryInput{Event: "an event"})
	if err != nil {
		t.Fatalf("failed to create the original map: %v", err)
	}
	if _, err := CreateMapOfWorry(db, testUserID, CreateMapOfWorryInput{
		Event:         "an event",
		DerivedFromID: &origin.ID,
	}); err != nil {
		t.Fatalf("failed to create the alternative map: %v", err)
	}

	// Removing the original would strip the alternative of the contrast that
	// gives it its meaning.
	if err := DeleteMapOfWorry(db, testUserID, origin.ID); !errors.Is(err, ErrMapHasAlternatives) {
		t.Errorf("expected ErrMapHasAlternatives but got %v", err)
	}
}

func TestDeleteMapOfWorryRemovesItsFeelings(t *testing.T) {
	db := setupTestDB(t)

	mapOfWorry, err := CreateMapOfWorry(db, testUserID, CreateMapOfWorryInput{
		Event:    "an event",
		Feelings: []FeelingInput{{Name: "anxious"}},
	})
	if err != nil {
		t.Fatalf("failed to create the map: %v", err)
	}

	if err := DeleteMapOfWorry(db, testUserID, mapOfWorry.ID); err != nil {
		t.Fatalf("failed to delete the map: %v", err)
	}

	var feelings int64
	if err := db.Model(&Feeling{}).Where("map_of_worry_id = ?", mapOfWorry.ID).Count(&feelings).Error; err != nil {
		t.Fatalf("failed to count the feelings: %v", err)
	}
	if feelings != 0 {
		t.Errorf("expected the feelings to be deleted but %d remain", feelings)
	}
}

func TestUpdateMapOfWorryLeavesUnsetColumnsAlone(t *testing.T) {
	db := setupTestDB(t)

	mapOfWorry, err := CreateMapOfWorry(db, testUserID, CreateMapOfWorryInput{
		Event:              "an event",
		PhysicalSensations: "lethargy",
	})
	if err != nil {
		t.Fatalf("failed to create the map: %v", err)
	}

	behaviour := "decided not to go out"
	updated, err := UpdateMapOfWorry(db, testUserID, mapOfWorry.ID, UpdateMapOfWorryInput{ResultantBehaviour: &behaviour})
	if err != nil {
		t.Fatalf("failed to update the map: %v", err)
	}

	if updated.PhysicalSensations != "lethargy" {
		t.Errorf("expected the sensations to survive but got %q", updated.PhysicalSensations)
	}
	if updated.ResultantBehaviour != behaviour {
		t.Errorf("unexpected behaviour %q", updated.ResultantBehaviour)
	}
}

func TestListMapsOfWorrySearchesEveryColumn(t *testing.T) {
	db := setupTestDB(t)

	match, err := CreateMapOfWorry(db, testUserID, CreateMapOfWorryInput{
		Event:              "an unremarkable event",
		ResultantBehaviour: "put off opening the review until the next morning",
	})
	if err != nil {
		t.Fatalf("failed to create the matching map: %v", err)
	}
	if _, err := CreateMapOfWorry(db, testUserID, CreateMapOfWorryInput{Event: "something else"}); err != nil {
		t.Fatalf("failed to create the other map: %v", err)
	}

	maps, err := ListMapsOfWorry(db, testUserID, MapOfWorryFilter{Search: "REVIEW"})
	if err != nil {
		t.Fatalf("failed to search the maps: %v", err)
	}
	if len(maps) != 1 || maps[0].ID != match.ID {
		t.Fatalf("expected only the matching map but got %d maps", len(maps))
	}
}

func TestMapOfWorryOperationsAreScopedToTheUser(t *testing.T) {
	db := setupTestDB(t)

	mapOfWorry, err := CreateMapOfWorry(db, testUserID, CreateMapOfWorryInput{Event: "my event"})
	if err != nil {
		t.Fatalf("failed to create the map: %v", err)
	}

	tests := []struct {
		name string
		run  func() error
	}{
		{"get", func() error {
			_, err := GetMapOfWorry(db, otherUserID, mapOfWorry.ID)
			return err
		}},
		{"update", func() error {
			_, err := UpdateMapOfWorry(db, otherUserID, mapOfWorry.ID, UpdateMapOfWorryInput{})
			return err
		}},
		{"delete", func() error { return DeleteMapOfWorry(db, otherUserID, mapOfWorry.ID) }},
	}

	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			if err := test.run(); !errors.Is(err, ErrMapOfWorryNotFound) {
				t.Errorf("expected ErrMapOfWorryNotFound but got %v", err)
			}
		})
	}
}
