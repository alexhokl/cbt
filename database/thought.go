package database

import (
	"errors"
	"fmt"
	"strings"

	"gorm.io/gorm"
)

var (
	// ErrThoughtNotFound is returned when a negative thought does not exist.
	ErrThoughtNotFound = errors.New("thought not found")
	// ErrThoughtBodyEmpty is returned when the body of a thought is blank.
	ErrThoughtBodyEmpty = errors.New("thought must not be empty")
	// ErrMultipleHotThoughts is returned when more than one thought of the
	// same record is marked as the strongest.
	ErrMultipleHotThoughts = errors.New("a thought record must not carry more than one hot thought")
	// ErrThoughtFactualWithBias is returned when a thought is marked as an
	// accurate reading of the situation while it still carries a cognitive
	// bias. A thought cannot be both accurate and distorted, and the
	// combination is far more likely a mistyped identifier than an intent.
	ErrThoughtFactualWithBias = errors.New("a thought judged factual must not carry a cognitive bias")
)

// ThoughtInput is a negative automatic thought as supplied by the caller.
type ThoughtInput struct {
	Body string
	// IsHot marks this as the strongest thought of the record, the one
	// conventionally circled on paper and challenged first.
	IsHot bool
	// Biases are the names of the thinking errors identified in this thought.
	// They must already exist: a bias is a vocabulary term rather than a free
	// tag, so an unrecognised name is reported as a typo rather than coined.
	Biases []string
}

// createThoughts writes the supplied thoughts against a record, attaching any
// named biases. At most one thought may be marked hot; the check happens here
// so the caller gets a named error rather than a trigger abort.
func createThoughts(tx *gorm.DB, userID uint, recordID uint, inputs []ThoughtInput) error {
	hotSeen := false
	for _, input := range inputs {
		body := strings.TrimSpace(input.Body)
		if body == "" {
			return ErrThoughtBodyEmpty
		}
		if input.IsHot {
			if hotSeen {
				return ErrMultipleHotThoughts
			}
			hotSeen = true
		}

		biases, err := findBiasesByName(tx, userID, input.Biases)
		if err != nil {
			return err
		}

		thought := NegativeThought{
			Body:            body,
			IsHot:           input.IsHot,
			ThoughtRecordID: recordID,
			UserID:          userID,
			Biases:          biases,
		}
		if err := tx.Create(&thought).Error; err != nil {
			return fmt.Errorf("failed to create the thought: %w", err)
		}
	}

	return nil
}

// AddThought attaches a further thought to an existing record.
func AddThought(db *gorm.DB, userID uint, recordID uint, input ThoughtInput) (*ThoughtRecord, error) {
	var record ThoughtRecord
	err := db.Transaction(func(tx *gorm.DB) error {
		if err := findThoughtRecord(tx, userID, recordID, &record); err != nil {
			return err
		}
		if input.IsHot {
			if err := clearHotThoughts(tx, userID, recordID); err != nil {
				return err
			}
		}
		if err := createThoughts(tx, userID, recordID, []ThoughtInput{input}); err != nil {
			return err
		}

		return loadThoughtRecord(tx, userID, recordID, &record)
	})
	if err != nil {
		return nil, err
	}

	return &record, nil
}

// UpdateThought changes the wording of a thought and, optionally, the biases
// attached to it. A nil Biases slice leaves the existing biases alone; an
// empty non-nil slice detaches them all.
func UpdateThought(db *gorm.DB, userID uint, id uint, body string, biases []string) (*ThoughtRecord, error) {
	trimmed := strings.TrimSpace(body)
	if trimmed == "" {
		return nil, ErrThoughtBodyEmpty
	}

	var record ThoughtRecord
	err := db.Transaction(func(tx *gorm.DB) error {
		var thought NegativeThought
		if err := findThought(tx, userID, id, &thought); err != nil {
			return err
		}

		if err := tx.Model(&thought).Update("body", trimmed).Error; err != nil {
			return fmt.Errorf("failed to update the thought: %w", err)
		}

		if biases != nil {
			resolved, err := findBiasesByName(tx, userID, biases)
			if err != nil {
				return err
			}
			if err := tx.Model(&thought).Association("Biases").Replace(resolved); err != nil {
				return fmt.Errorf("failed to attach the cognitive biases: %w", err)
			}
		}

		return loadThoughtRecord(tx, userID, thought.ThoughtRecordID, &record)
	})
	if err != nil {
		return nil, err
	}

	return &record, nil
}

// SetHotThought marks a thought as the strongest of its record, clearing the
// flag from its siblings in the same transaction so the record never carries
// two.
func SetHotThought(db *gorm.DB, userID uint, id uint) (*ThoughtRecord, error) {
	var record ThoughtRecord
	err := db.Transaction(func(tx *gorm.DB) error {
		var thought NegativeThought
		if err := findThought(tx, userID, id, &thought); err != nil {
			return err
		}

		if err := clearHotThoughts(tx, userID, thought.ThoughtRecordID); err != nil {
			return err
		}
		if err := tx.Model(&thought).Update("is_hot", true).Error; err != nil {
			return fmt.Errorf("failed to mark the thought as the strongest: %w", err)
		}

		return loadThoughtRecord(tx, userID, thought.ThoughtRecordID, &record)
	})
	if err != nil {
		return nil, err
	}

	return &record, nil
}

// DeleteThought removes a thought from its record, detaching any biases first
// so no join rows are left pointing at it.
func DeleteThought(db *gorm.DB, userID uint, id uint) error {
	return db.Transaction(func(tx *gorm.DB) error {
		var thought NegativeThought
		if err := findThought(tx, userID, id, &thought); err != nil {
			return err
		}

		if err := tx.Model(&thought).Association("Biases").Clear(); err != nil {
			return fmt.Errorf("failed to detach the cognitive biases: %w", err)
		}
		if err := tx.Delete(&thought).Error; err != nil {
			return fmt.Errorf("failed to delete the thought: %w", err)
		}

		return nil
	})
}

// GetThought returns a single thought by identifier, principally so a caller
// can learn which record it belongs to before removing it.
func GetThought(db *gorm.DB, userID uint, id uint) (*NegativeThought, error) {
	var thought NegativeThought
	if err := findThought(db, userID, id, &thought); err != nil {
		return nil, err
	}

	return &thought, nil
}

// SetThoughtFactual records whether a thought was judged an accurate reading
// of the situation. Marking a thought factual while it still carries a
// cognitive bias is rejected rather than silently detaching the biases: that
// would discard work the user had already done, without saying so.
func SetThoughtFactual(db *gorm.DB, userID uint, id uint, factual bool) (*ThoughtRecord, error) {
	var record ThoughtRecord
	err := db.Transaction(func(tx *gorm.DB) error {
		var thought NegativeThought
		if err := findThought(tx, userID, id, &thought); err != nil {
			return err
		}

		if factual {
			count := tx.Model(&thought).Association("Biases").Count()
			if count > 0 {
				return fmt.Errorf("%w: thought %d carries %d", ErrThoughtFactualWithBias, id, count)
			}
		}

		if err := tx.Model(&thought).Update("is_factual", factual).Error; err != nil {
			return fmt.Errorf("failed to record whether the thought is factual: %w", err)
		}

		return loadThoughtRecord(tx, userID, thought.ThoughtRecordID, &record)
	})
	if err != nil {
		return nil, err
	}

	return &record, nil
}

// clearHotThoughts unmarks every hot thought of a record. It runs before a new
// one is marked so the single hot thought invariant holds at every statement
// boundary the trigger can observe.
func clearHotThoughts(tx *gorm.DB, userID uint, recordID uint) error {
	if err := tx.
		Model(&NegativeThought{}).
		Where("thought_record_id = ?", recordID).
		Where("user_id = ?", userID).
		Where("is_hot = ?", true).
		Update("is_hot", false).Error; err != nil {
		return fmt.Errorf("failed to clear the previous strongest thought: %w", err)
	}

	return nil
}

// findThought loads a thought by identifier, translating a missing row into
// ErrThoughtNotFound. The query is scoped to the given user so cross-user
// access is reported as not found rather than leaking existence.
func findThought(tx *gorm.DB, userID uint, id uint, thought *NegativeThought) error {
	err := tx.Where("user_id = ?", userID).First(thought, id).Error
	if errors.Is(err, gorm.ErrRecordNotFound) {
		return fmt.Errorf("%w: %d", ErrThoughtNotFound, id)
	}
	if err != nil {
		return fmt.Errorf("failed to query the thought: %w", err)
	}

	return nil
}
