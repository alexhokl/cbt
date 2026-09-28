package database

import (
	"errors"
	"testing"
)

func TestSeedBuiltinBiasesCreatesTheCatalogue(t *testing.T) {
	db := setupTestDB(t)

	biases, err := ListBiases(db, testUserID)
	if err != nil {
		t.Fatalf("failed to list the biases: %v", err)
	}
	if len(biases) != len(BuiltinBiasNames) {
		t.Fatalf("expected %d seeded biases but got %d", len(BuiltinBiasNames), len(biases))
	}

	seeded := make(map[string]bool, len(biases))
	for _, bias := range biases {
		seeded[bias.Name] = bias.IsBuiltin
	}
	for _, name := range BuiltinBiasNames {
		isBuiltin, ok := seeded[name]
		if !ok {
			t.Errorf("expected the bias %q to be seeded", name)
			continue
		}
		if !isBuiltin {
			t.Errorf("expected the bias %q to be marked as builtin", name)
		}
	}
}

func TestSeedBuiltinBiasesIsIdempotent(t *testing.T) {
	db := setupTestDB(t)

	// Seeding runs whenever a user is resolved, so repeating it must not
	// duplicate the catalogue.
	if err := SeedBuiltinBiases(db, testUserID); err != nil {
		t.Fatalf("expected a repeated seed to succeed but got %v", err)
	}

	biases, err := ListBiases(db, testUserID)
	if err != nil {
		t.Fatalf("failed to list the biases: %v", err)
	}
	if len(biases) != len(BuiltinBiasNames) {
		t.Errorf("expected %d biases after reseeding but got %d", len(BuiltinBiasNames), len(biases))
	}
}

func TestSeedBuiltinBiasesIsPerUser(t *testing.T) {
	db := setupTestDB(t)

	// Two users each own their own copy of the catalogue, so one user editing
	// their vocabulary cannot affect the other.
	mine, err := ListBiases(db, testUserID)
	if err != nil {
		t.Fatalf("failed to list my biases: %v", err)
	}
	theirs, err := ListBiases(db, otherUserID)
	if err != nil {
		t.Fatalf("failed to list the other user's biases: %v", err)
	}

	if len(mine) != len(theirs) {
		t.Fatalf("expected both users to hold %d biases but got %d and %d", len(BuiltinBiasNames), len(mine), len(theirs))
	}
	for index := range mine {
		if mine[index].ID == theirs[index].ID {
			t.Errorf("expected the users to own distinct bias rows but both hold id %d", mine[index].ID)
		}
	}
}

func TestCreateBiasNormalisesTheName(t *testing.T) {
	db := setupTestDB(t)

	bias, err := CreateBias(db, testUserID, "  Comparing Myself To Others  ")
	if err != nil {
		t.Fatalf("failed to create the bias: %v", err)
	}
	if bias.Name != "comparing myself to others" {
		t.Errorf("expected the name to be normalised but got %q", bias.Name)
	}
	if bias.IsBuiltin {
		t.Error("expected a user defined bias not to be marked as builtin")
	}
}

func TestCreateBiasRejectsBlankNames(t *testing.T) {
	db := setupTestDB(t)

	tests := []struct {
		name  string
		input string
	}{
		{"empty", ""},
		{"whitespace only", "   "},
	}

	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			if _, err := CreateBias(db, testUserID, test.input); !errors.Is(err, ErrBiasNameEmpty) {
				t.Errorf("expected ErrBiasNameEmpty but got %v", err)
			}
		})
	}
}

func TestCreateBiasRejectsDuplicates(t *testing.T) {
	db := setupTestDB(t)

	// A name that differs only in case or padding is the same bias, so the
	// duplicate must be reported rather than quietly accepted.
	if _, err := CreateBias(db, testUserID, "CATASTROPHISING"); !errors.Is(err, ErrBiasExists) {
		t.Errorf("expected ErrBiasExists but got %v", err)
	}
}

func TestRenameBiasRejectsBuiltins(t *testing.T) {
	db := setupTestDB(t)

	biases, err := ListBiases(db, testUserID)
	if err != nil {
		t.Fatalf("failed to list the biases: %v", err)
	}

	// The seeded names are how a record is read back against the source
	// material, so they are fixed.
	if _, err := RenameBias(db, testUserID, biases[0].ID, "something else"); !errors.Is(err, ErrBiasBuiltin) {
		t.Errorf("expected ErrBiasBuiltin but got %v", err)
	}
}

func TestDeleteBiasRejectsBuiltins(t *testing.T) {
	db := setupTestDB(t)

	biases, err := ListBiases(db, testUserID)
	if err != nil {
		t.Fatalf("failed to list the biases: %v", err)
	}

	if err := DeleteBias(db, testUserID, biases[0].ID); !errors.Is(err, ErrBiasBuiltin) {
		t.Errorf("expected ErrBiasBuiltin but got %v", err)
	}
}

func TestRenameBiasAcceptsUserDefinedBiases(t *testing.T) {
	db := setupTestDB(t)

	bias, err := CreateBias(db, testUserID, "comparing")
	if err != nil {
		t.Fatalf("failed to create the bias: %v", err)
	}

	renamed, err := RenameBias(db, testUserID, bias.ID, "Comparing Myself")
	if err != nil {
		t.Fatalf("failed to rename the bias: %v", err)
	}
	if renamed.Name != "comparing myself" {
		t.Errorf("expected the renamed bias to be normalised but got %q", renamed.Name)
	}
}

func TestRenameBiasRejectsAnExistingName(t *testing.T) {
	db := setupTestDB(t)

	bias, err := CreateBias(db, testUserID, "comparing")
	if err != nil {
		t.Fatalf("failed to create the bias: %v", err)
	}

	if _, err := RenameBias(db, testUserID, bias.ID, "blaming"); !errors.Is(err, ErrBiasExists) {
		t.Errorf("expected ErrBiasExists but got %v", err)
	}
}

func TestDeleteBiasRejectsBiasesInUse(t *testing.T) {
	db := setupTestDB(t)

	bias, err := CreateBias(db, testUserID, "comparing")
	if err != nil {
		t.Fatalf("failed to create the bias: %v", err)
	}

	if _, err := CreateThoughtRecord(db, testUserID, CreateThoughtRecordInput{
		Event:    "scrolled through other people's holidays",
		Thoughts: []ThoughtInput{{Body: "everyone is doing better than me", Biases: []string{"comparing"}}},
	}); err != nil {
		t.Fatalf("failed to create the thought record: %v", err)
	}

	// Detaching a bias silently would change how a past record reads, so a
	// bias in use is reported instead.
	if err := DeleteBias(db, testUserID, bias.ID); !errors.Is(err, ErrBiasInUse) {
		t.Errorf("expected ErrBiasInUse but got %v", err)
	}
}

func TestDeleteBiasRemovesAnUnusedBias(t *testing.T) {
	db := setupTestDB(t)

	bias, err := CreateBias(db, testUserID, "comparing")
	if err != nil {
		t.Fatalf("failed to create the bias: %v", err)
	}

	if err := DeleteBias(db, testUserID, bias.ID); err != nil {
		t.Fatalf("failed to delete the bias: %v", err)
	}

	biases, err := ListBiases(db, testUserID)
	if err != nil {
		t.Fatalf("failed to list the biases: %v", err)
	}
	if len(biases) != len(BuiltinBiasNames) {
		t.Errorf("expected the catalogue to be back to %d biases but got %d", len(BuiltinBiasNames), len(biases))
	}
}

func TestBiasOperationsAreScopedToTheUser(t *testing.T) {
	db := setupTestDB(t)

	bias, err := CreateBias(db, testUserID, "comparing")
	if err != nil {
		t.Fatalf("failed to create the bias: %v", err)
	}

	// Another user's bias must look absent rather than forbidden, so its
	// existence is not leaked.
	t.Run("rename", func(t *testing.T) {
		if _, err := RenameBias(db, otherUserID, bias.ID, "theirs"); !errors.Is(err, ErrBiasNotFound) {
			t.Errorf("expected ErrBiasNotFound but got %v", err)
		}
	})
	t.Run("delete", func(t *testing.T) {
		if err := DeleteBias(db, otherUserID, bias.ID); !errors.Is(err, ErrBiasNotFound) {
			t.Errorf("expected ErrBiasNotFound but got %v", err)
		}
	})
}
