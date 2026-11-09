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
	// to a map of worry. Only a thought record and a behavioural experiment
	// have a second sitting.
	ErrFeelingNotOnRecord = errors.New("only a feeling on a thought record or a behavioural experiment can be re-rated")
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

// feelingParent names the record a feeling belongs to. Exactly one field is
// expected to be non-nil; the feelings_one_parent trigger is the backstop.
type feelingParent struct {
	ThoughtRecordID         *uint
	MapOfWorryID            *uint
	BehaviouralExperimentID *uint
}

// owns reports whether the feeling belongs to this parent.
func (p feelingParent) owns(feeling Feeling) bool {
	same := func(a, b *uint) bool { return a != nil && b != nil && *a == *b }
	return same(p.ThoughtRecordID, feeling.ThoughtRecordID) ||
		same(p.MapOfWorryID, feeling.MapOfWorryID) ||
		same(p.BehaviouralExperimentID, feeling.BehaviouralExperimentID)
}

// String names the parent for error messages, by kind and identifier only.
func (p feelingParent) String() string {
	switch {
	case p.ThoughtRecordID != nil:
		return fmt.Sprintf("thought record %d", *p.ThoughtRecordID)
	case p.MapOfWorryID != nil:
		return fmt.Sprintf("map of worry %d", *p.MapOfWorryID)
	case p.BehaviouralExperimentID != nil:
		return fmt.Sprintf("behavioural experiment %d", *p.BehaviouralExperimentID)
	default:
		return "no record"
	}
}

// buildFeelings turns caller supplied feelings into rows ready to be created
// against the given parent, with the rating stored as IntensityBefore.
//
// Blank names are rejected rather than skipped: a feeling the caller bothered
// to send but did not name is a mistake worth reporting, not a row to discard
// silently.
func buildFeelings(inputs []FeelingInput, userID uint, parent feelingParent) ([]Feeling, error) {
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
			Name:                    name,
			IntensityBefore:         input.Intensity,
			ThoughtRecordID:         parent.ThoughtRecordID,
			MapOfWorryID:            parent.MapOfWorryID,
			BehaviouralExperimentID: parent.BehaviouralExperimentID,
			UserID:                  userID,
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

		feelings, err := buildFeelings([]FeelingInput{input}, userID, feelingParent{ThoughtRecordID: &thoughtRecordID})
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

		feelings, err := buildFeelings([]FeelingInput{input}, userID, feelingParent{MapOfWorryID: &mapID})
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

// AddExperimentFeeling attaches a predicted feeling to an existing behavioural
// experiment.
func AddExperimentFeeling(db *gorm.DB, userID uint, experimentID uint, input FeelingInput) (*BehaviouralExperiment, error) {
	var experiment BehaviouralExperiment
	err := db.Transaction(func(tx *gorm.DB) error {
		if err := findBehaviouralExperiment(tx, userID, experimentID, &experiment); err != nil {
			return err
		}

		feelings, err := buildFeelings([]FeelingInput{input}, userID, feelingParent{BehaviouralExperimentID: &experimentID})
		if err != nil {
			return err
		}
		if err := tx.Create(&feelings).Error; err != nil {
			return fmt.Errorf("failed to add the feeling: %w", err)
		}

		return loadBehaviouralExperiment(tx, userID, experimentID, &experiment)
	})
	if err != nil {
		return nil, err
	}

	return &experiment, nil
}

// applyFeelingRerating writes the second-sitting rating of each named
// feeling. Feelings belonging to another record are rejected so a mistyped
// identifier cannot quietly rewrite an unrelated entry.
func applyFeelingRerating(tx *gorm.DB, userID uint, parent feelingParent, ratings map[uint]int) error {
	for feelingID, intensity := range ratings {
		if err := validateIntensity(&intensity); err != nil {
			return err
		}

		var feeling Feeling
		if err := findFeeling(tx, userID, feelingID, &feeling); err != nil {
			return err
		}
		if !parent.owns(feeling) {
			return fmt.Errorf("%w: %d does not belong to %s", ErrFeelingNotFound, feelingID, parent)
		}

		if err := tx.Model(&feeling).Update("intensity_after", intensity).Error; err != nil {
			return fmt.Errorf("failed to re-rate the feeling: %w", err)
		}
	}

	return nil
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
