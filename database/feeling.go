package database

import (
	"errors"
	"fmt"
	"strings"

	"gorm.io/gorm"
)

var (
	// ErrFeelingNotFound is returned when a feeling does not exist.
	ErrFeelingNotFound = errors.New("feeling not found")
	// ErrFeelingNameEmpty is returned when a feeling name normalises to
	// nothing.
	ErrFeelingNameEmpty = errors.New("feeling name must not be empty")
	// ErrFeelingIntensityRange is returned when a rating falls outside 0-100.
	ErrFeelingIntensityRange = errors.New("feeling intensity must be between 0 and 100")
	// ErrFeelingNotOnRecord is returned when re-rating a feeling that belongs
	// to a map of worry. Only a thought record has a challenge step.
	ErrFeelingNotOnRecord = errors.New("only a feeling on a thought record can be re-rated")
)

// FeelingInput is a feeling as supplied by the caller: a name and an optional
// 0-100 rating of how strongly it was felt.
type FeelingInput struct {
	Name      string
	Intensity *int
}

// NormaliseFeelingName reduces a feeling name to its canonical form, so that
// "Anxious" and " anxious " are the same feeling.
func NormaliseFeelingName(name string) string {
	return strings.ToLower(strings.TrimSpace(name))
}

// validateIntensity checks that a rating, when given, is a percentage.
func validateIntensity(intensity *int) error {
	if intensity == nil {
		return nil
	}
	if *intensity < 0 || *intensity > 100 {
		return fmt.Errorf("%w: %d", ErrFeelingIntensityRange, *intensity)
	}
	return nil
}

// buildFeelings turns caller supplied feelings into rows ready to be created
// against the given parent. Exactly one of thoughtRecordID and mapOfWorryID is
// expected to be non-nil; the feelings_single_parent trigger is the backstop.
//
// Blank names are rejected rather than skipped: a feeling the caller bothered
// to send but did not name is a mistake worth reporting, not a row to discard
// silently.
func buildFeelings(inputs []FeelingInput, userID uint, thoughtRecordID, mapOfWorryID *uint) ([]Feeling, error) {
	feelings := make([]Feeling, 0, len(inputs))
	for _, input := range inputs {
		name := NormaliseFeelingName(input.Name)
		if name == "" {
			return nil, ErrFeelingNameEmpty
		}
		if err := validateIntensity(input.Intensity); err != nil {
			return nil, err
		}

		feelings = append(feelings, Feeling{
			Name:            name,
			IntensityBefore: input.Intensity,
			ThoughtRecordID: thoughtRecordID,
			MapOfWorryID:    mapOfWorryID,
			UserID:          userID,
		})
	}

	return feelings, nil
}

// AddFeeling attaches a feeling to an existing thought record.
func AddFeeling(db *gorm.DB, userID uint, thoughtRecordID uint, input FeelingInput) (*ThoughtRecord, error) {
	var record ThoughtRecord
	err := db.Transaction(func(tx *gorm.DB) error {
		if err := findThoughtRecord(tx, userID, thoughtRecordID, &record); err != nil {
			return err
		}

		feelings, err := buildFeelings([]FeelingInput{input}, userID, &thoughtRecordID, nil)
		if err != nil {
			return err
		}
		if err := tx.Create(&feelings).Error; err != nil {
			return fmt.Errorf("failed to add the feeling: %w", err)
		}

		return loadThoughtRecord(tx, userID, thoughtRecordID, &record)
	})
	if err != nil {
		return nil, err
	}

	return &record, nil
}

// AddMapFeeling attaches a feeling to an existing map of worry.
func AddMapFeeling(db *gorm.DB, userID uint, mapID uint, input FeelingInput) (*MapOfWorry, error) {
	var mapOfWorry MapOfWorry
	err := db.Transaction(func(tx *gorm.DB) error {
		if err := findMapOfWorry(tx, userID, mapID, &mapOfWorry); err != nil {
			return err
		}

		feelings, err := buildFeelings([]FeelingInput{input}, userID, nil, &mapID)
		if err != nil {
			return err
		}
		if err := tx.Create(&feelings).Error; err != nil {
			return fmt.Errorf("failed to add the feeling: %w", err)
		}

		return loadMapOfWorry(tx, userID, mapID, &mapOfWorry)
	})
	if err != nil {
		return nil, err
	}

	return &mapOfWorry, nil
}

// DeleteFeeling removes a feeling from whichever record it belongs to.
func DeleteFeeling(db *gorm.DB, userID uint, id uint) error {
	return db.Transaction(func(tx *gorm.DB) error {
		var feeling Feeling
		if err := findFeeling(tx, userID, id, &feeling); err != nil {
			return err
		}
		if err := tx.Delete(&feeling).Error; err != nil {
			return fmt.Errorf("failed to delete the feeling: %w", err)
		}
		return nil
	})
}

// findFeeling loads a feeling by identifier, translating a missing row into
// ErrFeelingNotFound. The query is scoped to the given user so cross-user
// access is reported as not found rather than leaking existence.
func findFeeling(tx *gorm.DB, userID uint, id uint, feeling *Feeling) error {
	err := tx.Where("user_id = ?", userID).First(feeling, id).Error
	if errors.Is(err, gorm.ErrRecordNotFound) {
		return fmt.Errorf("%w: %d", ErrFeelingNotFound, id)
	}
	if err != nil {
		return fmt.Errorf("failed to query the feeling: %w", err)
	}

	return nil
}
