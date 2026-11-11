package database

import (
	"errors"
	"testing"
)

func TestCreateFormulationRejectsAnEmptyOne(t *testing.T) {
	db := setupTestDB(t)

	tests := []struct {
		name  string
		input FormulationInput
	}{
		{"nothing", FormulationInput{}},
		{"whitespace", FormulationInput{Beliefs: "  ", Thoughts: "\n"}},
	}

	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			_, err := CreateFormulation(db, testUserID, test.input)
			if !errors.Is(err, ErrFormulationEmpty) {
				t.Errorf("expected ErrFormulationEmpty but got %v", err)
			}
		})
	}
}

func TestCreateFormulationFromAnyColumn(t *testing.T) {
	db := setupTestDB(t)

	// Working backwards from the thoughts is as valid as starting from the
	// early experiences.
	formulation, err := CreateFormulation(db, testUserID, FormulationInput{Thoughts: " there is no point getting to know them "})
	if err != nil {
		t.Fatalf("failed to create the formulation: %v", err)
	}
	if formulation.Thoughts != "there is no point getting to know them" {
		t.Errorf("expected the thoughts to be trimmed but got %q", formulation.Thoughts)
	}
	if formulation.EarlyExperiences != "" || formulation.Beliefs != "" {
		t.Error("expected the other columns to be blank")
	}
}

func TestCreateFormulationStoresEveryColumn(t *testing.T) {
	db := setupTestDB(t)

	formulation, err := CreateFormulation(db, testUserID, FormulationInput{
		EarlyExperiences: "moved school three times as a child",
		Beliefs:          "people move on",
		Assumptions:      "if I get attached, it will end",
		RulesForLiving:   "keep new colleagues at arm's length",
		Events:           "invited to a team lunch",
		Thoughts:         "there is no point getting to know them",
		Behaviours:       "eats at the desk",
	})
	if err != nil {
		t.Fatalf("failed to create the formulation: %v", err)
	}

	got, err := GetFormulation(db, testUserID, formulation.ID)
	if err != nil {
		t.Fatalf("failed to get the formulation: %v", err)
	}
	expected := []string{
		"moved school three times as a child",
		"people move on",
		"if I get attached, it will end",
		"keep new colleagues at arm's length",
		"invited to a team lunch",
		"there is no point getting to know them",
		"eats at the desk",
	}
	for index, value := range got.values() {
		if value != expected[index] {
			t.Errorf("expected %s to be %q but got %q", formulationColumns[index], expected[index], value)
		}
	}
}

func TestUpdateFormulation(t *testing.T) {
	db := setupTestDB(t)

	formulation, err := CreateFormulation(db, testUserID, FormulationInput{Thoughts: "there is no point getting to know them"})
	if err != nil {
		t.Fatalf("failed to create the formulation: %v", err)
	}

	formulation, err = UpdateFormulation(db, testUserID, formulation.ID, UpdateFormulationInput{
		Beliefs:    stringPtr(" people move on "),
		Behaviours: stringPtr("eats at the desk"),
	})
	if err != nil {
		t.Fatalf("failed to update the formulation: %v", err)
	}
	if formulation.Beliefs != "people move on" || formulation.Behaviours != "eats at the desk" {
		t.Errorf("unexpected columns %q and %q", formulation.Beliefs, formulation.Behaviours)
	}
	if formulation.Thoughts != "there is no point getting to know them" {
		t.Errorf("expected the thoughts to be left alone but got %q", formulation.Thoughts)
	}

	// Clearing one column is fine while another remains.
	formulation, err = UpdateFormulation(db, testUserID, formulation.ID, UpdateFormulationInput{Thoughts: stringPtr("")})
	if err != nil {
		t.Fatalf("failed to clear a column: %v", err)
	}
	if formulation.Thoughts != "" {
		t.Errorf("expected the thoughts to be cleared but got %q", formulation.Thoughts)
	}

	_, err = UpdateFormulation(db, testUserID, formulation.ID, UpdateFormulationInput{
		Beliefs:    stringPtr(" "),
		Behaviours: stringPtr(""),
	})
	if !errors.Is(err, ErrFormulationEmpty) {
		t.Errorf("expected ErrFormulationEmpty but got %v", err)
	}
}

func TestFormulationTriggerRejectsAnEmptyRow(t *testing.T) {
	db := setupTestDB(t)

	formulation := Formulation{Beliefs: "  ", UserID: testUserID}
	if err := db.Create(&formulation).Error; err == nil {
		t.Error("expected the trigger to reject the formulation")
	}
}

func TestListFormulationsSearchesEveryColumn(t *testing.T) {
	db := setupTestDB(t)

	if _, err := CreateFormulation(db, testUserID, FormulationInput{
		Beliefs: "people move on",
		Events:  "invited to a team lunch",
	}); err != nil {
		t.Fatalf("failed to create the formulation: %v", err)
	}
	if _, err := CreateFormulation(db, testUserID, FormulationInput{
		RulesForLiving: "always finish a book once started",
	}); err != nil {
		t.Fatalf("failed to create the formulation: %v", err)
	}

	tests := []struct {
		search   string
		expected int
	}{
		{"", 2},
		{"LUNCH", 1},
		{"book", 1},
		{"garden", 0},
	}

	for _, test := range tests {
		t.Run(test.search, func(t *testing.T) {
			formulations, err := ListFormulations(db, testUserID, FormulationFilter{Search: test.search})
			if err != nil {
				t.Fatalf("failed to list the formulations: %v", err)
			}
			if len(formulations) != test.expected {
				t.Errorf("expected %d formulations but got %d", test.expected, len(formulations))
			}
		})
	}
}

func TestFormulationIsScopedToItsUser(t *testing.T) {
	db := setupTestDB(t)

	formulation, err := CreateFormulation(db, testUserID, FormulationInput{Beliefs: "people move on"})
	if err != nil {
		t.Fatalf("failed to create the formulation: %v", err)
	}

	tests := []struct {
		name string
		call func() error
	}{
		{"get", func() error {
			_, err := GetFormulation(db, otherUserID, formulation.ID)
			return err
		}},
		{"update", func() error {
			_, err := UpdateFormulation(db, otherUserID, formulation.ID, UpdateFormulationInput{Beliefs: stringPtr("something else")})
			return err
		}},
		{"delete", func() error {
			return DeleteFormulation(db, otherUserID, formulation.ID)
		}},
	}

	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			if err := test.call(); !errors.Is(err, ErrFormulationNotFound) {
				t.Errorf("expected ErrFormulationNotFound but got %v", err)
			}
		})
	}

	formulations, err := ListFormulations(db, otherUserID, FormulationFilter{})
	if err != nil {
		t.Fatalf("failed to list the formulations: %v", err)
	}
	if len(formulations) != 0 {
		t.Errorf("expected no formulations for the other user but got %d", len(formulations))
	}
}

func TestDeleteFormulation(t *testing.T) {
	db := setupTestDB(t)

	formulation, err := CreateFormulation(db, testUserID, FormulationInput{Beliefs: "people move on"})
	if err != nil {
		t.Fatalf("failed to create the formulation: %v", err)
	}
	if err := DeleteFormulation(db, testUserID, formulation.ID); err != nil {
		t.Fatalf("failed to delete the formulation: %v", err)
	}
	if _, err := GetFormulation(db, testUserID, formulation.ID); !errors.Is(err, ErrFormulationNotFound) {
		t.Errorf("expected ErrFormulationNotFound but got %v", err)
	}
}
