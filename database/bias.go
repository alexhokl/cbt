package database

import (
	"errors"
	"fmt"
	"strings"

	"gorm.io/gorm"
)

var (
	// ErrBiasNotFound is returned when a cognitive bias does not exist.
	ErrBiasNotFound = errors.New("cognitive bias not found")
	// ErrBiasExists is returned when a cognitive bias name is already taken.
	ErrBiasExists = errors.New("cognitive bias already exists")
	// ErrBiasInUse is returned when deleting a bias that is still attached to
	// at least one thought.
	ErrBiasInUse = errors.New("cognitive bias is still attached to thoughts")
	// ErrBiasNameEmpty is returned when a bias name normalises to nothing.
	ErrBiasNameEmpty = errors.New("cognitive bias name must not be empty")
	// ErrBiasBuiltin is returned when renaming or deleting one of the seeded
	// biases. The seeded vocabulary is the one catalogued in the source
	// material, and records are read back against it.
	ErrBiasBuiltin = errors.New("a builtin cognitive bias cannot be renamed or deleted")
)

// BuiltinBiasNames are the nine cognitive biases of the standard vocabulary.
// They are seeded for every user on first sight and are neither renameable nor
// deletable.
//
// The names are already normalised, so they can be compared against
// CognitiveBias.Name directly.
var BuiltinBiasNames = []string{
	"generalising the specific",
	"mind-reading",
	"magnification and filtering",
	"polarised thinking",
	"catastrophising",
	"personalisation",
	"blaming",
	"self-blame",
	"rigid thinking",
}

// NormaliseBiasName reduces a bias name to its canonical form. It is the
// single definition of bias identity: any two names with the same normalised
// form refer to the same bias.
func NormaliseBiasName(name string) string {
	return strings.ToLower(strings.TrimSpace(name))
}

// normaliseBiasNames normalises a list of names, dropping blanks and
// duplicates while preserving the order in which names were first seen.
func normaliseBiasNames(names []string) []string {
	seen := make(map[string]struct{}, len(names))
	result := make([]string, 0, len(names))

	for _, name := range names {
		normalised := NormaliseBiasName(name)
		if normalised == "" {
			continue
		}
		if _, ok := seen[normalised]; ok {
			continue
		}
		seen[normalised] = struct{}{}
		result = append(result, normalised)
	}

	return result
}

// SeedBuiltinBiases inserts any of the nine builtin biases the user does not
// already have. It is called when a user is created and is safe to call again:
// existing rows are left untouched, so it can be used to backfill a user
// created before a name was added to the list.
func SeedBuiltinBiases(db *gorm.DB, userID uint) error {
	return db.Transaction(func(tx *gorm.DB) error {
		for _, name := range BuiltinBiasNames {
			var bias CognitiveBias
			err := tx.Where("name = ?", name).Where("user_id = ?", userID).First(&bias).Error
			switch {
			case err == nil:
				continue
			case !errors.Is(err, gorm.ErrRecordNotFound):
				return fmt.Errorf("failed to query the cognitive bias %q: %w", name, err)
			}

			bias = CognitiveBias{Name: name, IsBuiltin: true, UserID: userID}
			if err := tx.Create(&bias).Error; err != nil {
				return fmt.Errorf("failed to seed the cognitive bias %q: %w", name, err)
			}
		}

		return nil
	})
}

// ListBiases returns every cognitive bias owned by the user, ordered by name.
func ListBiases(db *gorm.DB, userID uint) ([]CognitiveBias, error) {
	var biases []CognitiveBias
	if err := db.Where("user_id = ?", userID).Order("name ASC").Find(&biases).Error; err != nil {
		return nil, fmt.Errorf("failed to list the cognitive biases: %w", err)
	}

	return biases, nil
}

// CreateBias creates a user-defined cognitive bias. A name that is already
// taken is reported rather than silently returning the existing row, so an
// accidental duplicate is visible.
func CreateBias(db *gorm.DB, userID uint, name string) (*CognitiveBias, error) {
	normalised := NormaliseBiasName(name)
	if normalised == "" {
		return nil, ErrBiasNameEmpty
	}

	var bias CognitiveBias
	err := db.Transaction(func(tx *gorm.DB) error {
		switch err := tx.Where("name = ?", normalised).Where("user_id = ?", userID).First(&bias).Error; {
		case err == nil:
			return fmt.Errorf("%w: %s", ErrBiasExists, normalised)
		case !errors.Is(err, gorm.ErrRecordNotFound):
			return fmt.Errorf("failed to query the cognitive bias: %w", err)
		}

		bias = CognitiveBias{Name: normalised, UserID: userID}
		if err := tx.Create(&bias).Error; err != nil {
			return fmt.Errorf("failed to create the cognitive bias: %w", err)
		}

		return nil
	})
	if err != nil {
		return nil, err
	}

	return &bias, nil
}

// RenameBias changes the name of a user-defined cognitive bias. Builtin biases
// are rejected: the seeded names are how a record is read back against the
// source material. Renaming a bias to the name it already has is a no-op
// rather than a conflict.
func RenameBias(db *gorm.DB, userID uint, id uint, name string) (*CognitiveBias, error) {
	normalised := NormaliseBiasName(name)
	if normalised == "" {
		return nil, ErrBiasNameEmpty
	}

	var bias CognitiveBias
	err := db.Transaction(func(tx *gorm.DB) error {
		if err := findBias(tx, userID, id, &bias); err != nil {
			return err
		}
		if bias.IsBuiltin {
			return fmt.Errorf("%w: %s", ErrBiasBuiltin, bias.Name)
		}
		if bias.Name == normalised {
			return nil
		}

		var existing CognitiveBias
		switch err := tx.Where("name = ?", normalised).Where("user_id = ?", userID).Where("id <> ?", id).First(&existing).Error; {
		case err == nil:
			return fmt.Errorf("%w: %s", ErrBiasExists, normalised)
		case !errors.Is(err, gorm.ErrRecordNotFound):
			return fmt.Errorf("failed to query the cognitive bias: %w", err)
		}

		if err := tx.Model(&bias).Update("name", normalised).Error; err != nil {
			return fmt.Errorf("failed to rename the cognitive bias: %w", err)
		}

		return findBias(tx, userID, id, &bias)
	})
	if err != nil {
		return nil, err
	}

	return &bias, nil
}

// DeleteBias removes a user-defined cognitive bias that is no longer attached
// to any thought. Biases in use are reported rather than silently detached, so
// deleting one can never quietly change how a past record reads.
func DeleteBias(db *gorm.DB, userID uint, id uint) error {
	return db.Transaction(func(tx *gorm.DB) error {
		var bias CognitiveBias
		if err := findBias(tx, userID, id, &bias); err != nil {
			return err
		}
		if bias.IsBuiltin {
			return fmt.Errorf("%w: %s", ErrBiasBuiltin, bias.Name)
		}

		var count int64
		if err := tx.
			Table("thought_biases").
			Joins("JOIN negative_thoughts ON negative_thoughts.id = thought_biases.negative_thought_id").
			Where("thought_biases.cognitive_bias_id = ?", id).
			Where("negative_thoughts.user_id = ?", userID).
			Where("negative_thoughts.deleted_at IS NULL").
			Count(&count).Error; err != nil {
			return fmt.Errorf("failed to count the thoughts using the cognitive bias: %w", err)
		}
		if count > 0 {
			return fmt.Errorf("%w: %s is attached to %d thought(s)", ErrBiasInUse, bias.Name, count)
		}

		// Any remaining join rows belong to soft deleted thoughts. The join
		// table has no soft delete column of its own, so they are removed here
		// to avoid leaving rows pointing at a bias that no longer exists.
		if err := tx.Exec("DELETE FROM thought_biases WHERE cognitive_bias_id = ?", id).Error; err != nil {
			return fmt.Errorf("failed to detach the cognitive bias: %w", err)
		}

		if err := tx.Delete(&bias).Error; err != nil {
			return fmt.Errorf("failed to delete the cognitive bias: %w", err)
		}

		return nil
	})
}

// findBiasesByName resolves names to biases that already exist, reporting any
// that do not. Unlike labels in a todo list, a bias is a vocabulary term
// rather than a free tag: a name that does not resolve is far more likely to
// be a typo than an intent to coin a new distortion, so it is reported instead
// of created.
func findBiasesByName(db *gorm.DB, userID uint, names []string) ([]CognitiveBias, error) {
	normalised := normaliseBiasNames(names)
	if len(normalised) == 0 {
		return nil, nil
	}

	var biases []CognitiveBias
	if err := db.Where("name IN ?", normalised).Where("user_id = ?", userID).Find(&biases).Error; err != nil {
		return nil, fmt.Errorf("failed to query the cognitive biases: %w", err)
	}

	found := make(map[string]struct{}, len(biases))
	for _, bias := range biases {
		found[bias.Name] = struct{}{}
	}
	for _, name := range normalised {
		if _, ok := found[name]; !ok {
			return nil, fmt.Errorf("%w: %s", ErrBiasNotFound, name)
		}
	}

	return biases, nil
}

// findBias loads a bias by identifier, translating a missing row into
// ErrBiasNotFound. The query is scoped to the given user so cross-user access
// is reported as not found rather than leaking existence.
func findBias(tx *gorm.DB, userID uint, id uint, bias *CognitiveBias) error {
	err := tx.Where("user_id = ?", userID).First(bias, id).Error
	if errors.Is(err, gorm.ErrRecordNotFound) {
		return fmt.Errorf("%w: %d", ErrBiasNotFound, id)
	}
	if err != nil {
		return fmt.Errorf("failed to query the cognitive bias: %w", err)
	}

	return nil
}
