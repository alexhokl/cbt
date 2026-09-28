package database

import (
	"errors"
	"fmt"
	"strings"
	"time"

	"gorm.io/gorm"
)

var (
	// ErrThoughtRecordNotFound is returned when a thought record does not
	// exist.
	ErrThoughtRecordNotFound = errors.New("thought record not found")
	// ErrEventEmpty is returned when the event of a record is blank. It is the
	// one column a record cannot do without: everything else is filled in over
	// the hours that follow.
	ErrEventEmpty = errors.New("event must not be empty")
)

// ThoughtRecordFilter narrows a listing of thought records.
type ThoughtRecordFilter struct {
	// Challenged selects records by whether they have been challenged. Nil
	// returns both. False is the day's work queue.
	Challenged *bool
	// Since restricts the listing to records whose event occurred on or after
	// this instant, falling back to the creation time for records where the
	// user did not say when the event happened.
	Since *time.Time
	// Search matches free text across the event, the alternative view and the
	// bodies of the thoughts, case insensitively.
	Search string
}

// CreateThoughtRecordInput is a new thought record as supplied by the caller.
// Only Event is required; a record is routinely opened with nothing else and
// completed later.
type CreateThoughtRecordInput struct {
	Event           string
	OccurredAt      *time.Time
	AlternativeView string
	FeelingsNow     string
	Thoughts        []ThoughtInput
	Feelings        []FeelingInput
}

// UpdateThoughtRecordInput carries the columns to change on an existing
// record. A nil field is left as it is, which is what allows a record to be
// filled in a column at a time.
type UpdateThoughtRecordInput struct {
	Event           *string
	OccurredAt      *time.Time
	ClearOccurredAt bool
	AlternativeView *string
	FeelingsNow     *string
}

// ThoughtJudgement is the outcome of examining one thought during a challenge:
// which distortions it carries, or that it carries none because the thought
// was an accurate reading of the situation.
//
// Both halves live in one value so they cannot disagree. Validation is applied
// to the resulting state of the thought, not just to what this request
// carries, so marking a thought factual is refused when biases recorded
// earlier are still attached.
type ThoughtJudgement struct {
	// Biases replaces the biases on the thought. Nil leaves whatever is
	// already attached alone; an empty slice detaches them all, which is how a
	// thought is recorded as carrying no distortion.
	Biases []string
	// IsFactual records that the thought was judged an accurate reading.
	IsFactual bool
}

// ChallengeInput carries the second sitting of a thought record: the
// alternative view, the re-rating of each feeling, and the judgement made
// about each thought.
type ChallengeInput struct {
	// AlternativeView answers "is there any other way I can look at this?".
	AlternativeView string
	// FeelingsNow answers "how do I feel now?" in prose.
	FeelingsNow string
	// FeelingIntensitiesAfter maps a feeling identifier to its re-rating.
	FeelingIntensitiesAfter map[uint]int
	// Thoughts maps a thought identifier to the judgement made about it. Bias
	// names must already exist; unknown names are reported rather than coined.
	Thoughts map[uint]ThoughtJudgement
}

// CreateThoughtRecord creates a thought record together with any thoughts and
// feelings supplied up front. The whole record is written in one transaction
// so a rejected thought cannot leave a half-built record behind.
func CreateThoughtRecord(db *gorm.DB, userID uint, input CreateThoughtRecordInput) (*ThoughtRecord, error) {
	event := strings.TrimSpace(input.Event)
	if event == "" {
		return nil, ErrEventEmpty
	}

	var record ThoughtRecord
	err := db.Transaction(func(tx *gorm.DB) error {
		record = ThoughtRecord{
			Event:           event,
			OccurredAt:      input.OccurredAt,
			AlternativeView: strings.TrimSpace(input.AlternativeView),
			FeelingsNow:     strings.TrimSpace(input.FeelingsNow),
			UserID:          userID,
		}
		if err := tx.Create(&record).Error; err != nil {
			return fmt.Errorf("failed to create the thought record: %w", err)
		}

		if err := createThoughts(tx, userID, record.ID, input.Thoughts); err != nil {
			return err
		}

		if len(input.Feelings) > 0 {
			feelings, err := buildFeelings(input.Feelings, userID, &record.ID, nil)
			if err != nil {
				return err
			}
			if err := tx.Create(&feelings).Error; err != nil {
				return fmt.Errorf("failed to create the feelings: %w", err)
			}
		}

		return loadThoughtRecord(tx, userID, record.ID, &record)
	})
	if err != nil {
		return nil, err
	}

	return &record, nil
}

// ListThoughtRecords returns the user's thought records, most recent event
// first. Records are ordered by when the event happened rather than when it
// was typed, falling back to the creation time when the user did not say.
func ListThoughtRecords(db *gorm.DB, userID uint, filter ThoughtRecordFilter) ([]ThoughtRecord, error) {
	query := db.
		Preload("Thoughts").
		Preload("Thoughts.Biases").
		Preload("Feelings").
		Where("user_id = ?", userID)

	if filter.Challenged != nil {
		if *filter.Challenged {
			query = query.Where("challenged_at IS NOT NULL")
		} else {
			query = query.Where("challenged_at IS NULL")
		}
	}
	if filter.Since != nil {
		query = query.Where("COALESCE(occurred_at, created_at) >= ?", *filter.Since)
	}
	if search := strings.TrimSpace(filter.Search); search != "" {
		pattern := "%" + strings.ToLower(search) + "%"
		query = query.Where(
			db.Where("LOWER(event) LIKE ?", pattern).
				Or("LOWER(alternative_view) LIKE ?", pattern).
				Or("id IN (?)", db.
					Table("negative_thoughts").
					Select("thought_record_id").
					Where("user_id = ?", userID).
					Where("deleted_at IS NULL").
					Where("LOWER(body) LIKE ?", pattern),
				),
		)
	}

	var records []ThoughtRecord
	if err := query.Order("COALESCE(occurred_at, created_at) DESC, id DESC").Find(&records).Error; err != nil {
		return nil, fmt.Errorf("failed to list the thought records: %w", err)
	}

	return records, nil
}

// GetThoughtRecord returns a single thought record with its thoughts, the
// biases on each thought, and its feelings.
func GetThoughtRecord(db *gorm.DB, userID uint, id uint) (*ThoughtRecord, error) {
	var record ThoughtRecord
	if err := loadThoughtRecord(db, userID, id, &record); err != nil {
		return nil, err
	}

	return &record, nil
}

// UpdateThoughtRecord changes the free text columns of a record. Fields left
// nil keep their current value, so a record can be completed one column at a
// time as the user works through it.
func UpdateThoughtRecord(db *gorm.DB, userID uint, id uint, input UpdateThoughtRecordInput) (*ThoughtRecord, error) {
	var record ThoughtRecord
	err := db.Transaction(func(tx *gorm.DB) error {
		if err := findThoughtRecord(tx, userID, id, &record); err != nil {
			return err
		}

		updates := map[string]any{}
		if input.Event != nil {
			event := strings.TrimSpace(*input.Event)
			if event == "" {
				return ErrEventEmpty
			}
			updates["event"] = event
		}
		if input.ClearOccurredAt {
			updates["occurred_at"] = nil
		} else if input.OccurredAt != nil {
			updates["occurred_at"] = *input.OccurredAt
		}
		if input.AlternativeView != nil {
			updates["alternative_view"] = strings.TrimSpace(*input.AlternativeView)
		}
		if input.FeelingsNow != nil {
			updates["feelings_now"] = strings.TrimSpace(*input.FeelingsNow)
		}

		if len(updates) > 0 {
			if err := tx.Model(&record).Updates(updates).Error; err != nil {
				return fmt.Errorf("failed to update the thought record: %w", err)
			}
		}

		return loadThoughtRecord(tx, userID, id, &record)
	})
	if err != nil {
		return nil, err
	}

	return &record, nil
}

// ChallengeThoughtRecord records the second sitting of a thought record: the
// alternative view, the prose answer to "how do I feel now?", the re-rating of
// each feeling, and the biases identified in each thought. ChallengedAt is
// stamped so the record leaves the unchallenged queue.
//
// Challenging a record that has already been challenged is allowed and
// re-stamps it. Coming back to a record a second time with a clearer head is
// the practice working, not a conflict to reject.
func ChallengeThoughtRecord(db *gorm.DB, userID uint, id uint, input ChallengeInput) (*ThoughtRecord, error) {
	var record ThoughtRecord
	err := db.Transaction(func(tx *gorm.DB) error {
		if err := findThoughtRecord(tx, userID, id, &record); err != nil {
			return err
		}

		updates := map[string]any{"challenged_at": time.Now()}
		if view := strings.TrimSpace(input.AlternativeView); view != "" {
			updates["alternative_view"] = view
		}
		if now := strings.TrimSpace(input.FeelingsNow); now != "" {
			updates["feelings_now"] = now
		}
		if err := tx.Model(&record).Updates(updates).Error; err != nil {
			return fmt.Errorf("failed to challenge the thought record: %w", err)
		}

		if err := applyFeelingRerating(tx, userID, id, input.FeelingIntensitiesAfter); err != nil {
			return err
		}
		if err := applyThoughtJudgements(tx, userID, id, input.Thoughts); err != nil {
			return err
		}

		return loadThoughtRecord(tx, userID, id, &record)
	})
	if err != nil {
		return nil, err
	}

	return &record, nil
}

// applyFeelingRerating writes the post-challenge rating of each named feeling.
// Feelings belonging to another record are rejected so a mistyped identifier
// cannot quietly rewrite an unrelated entry.
func applyFeelingRerating(tx *gorm.DB, userID uint, recordID uint, ratings map[uint]int) error {
	for feelingID, intensity := range ratings {
		if err := validateIntensity(&intensity); err != nil {
			return err
		}

		var feeling Feeling
		if err := findFeeling(tx, userID, feelingID, &feeling); err != nil {
			return err
		}
		if feeling.ThoughtRecordID == nil || *feeling.ThoughtRecordID != recordID {
			return fmt.Errorf("%w: %d does not belong to thought record %d", ErrFeelingNotFound, feelingID, recordID)
		}

		if err := tx.Model(&feeling).Update("intensity_after", intensity).Error; err != nil {
			return fmt.Errorf("failed to re-rate the feeling: %w", err)
		}
	}

	return nil
}

// applyThoughtJudgements records what was decided about each thought: the
// biases it carries, and whether it was judged an accurate reading.
//
// Biases are replaced rather than added to, which keeps the challenge
// idempotent: running it again with a corrected list leaves the corrected
// list, not the union of both attempts. A nil list leaves the existing biases
// alone, so a judgement can record only that a thought is factual.
func applyThoughtJudgements(tx *gorm.DB, userID uint, recordID uint, judgements map[uint]ThoughtJudgement) error {
	for thoughtID, judgement := range judgements {
		var thought NegativeThought
		if err := findThought(tx, userID, thoughtID, &thought); err != nil {
			return err
		}
		if thought.ThoughtRecordID != recordID {
			return fmt.Errorf("%w: %d does not belong to thought record %d", ErrThoughtNotFound, thoughtID, recordID)
		}

		if judgement.Biases != nil {
			biases, err := findBiasesByName(tx, userID, judgement.Biases)
			if err != nil {
				return err
			}
			// The contradiction is checked against the state the thought is
			// about to be left in, so a judgement that only sets IsFactual is
			// still caught against biases attached by an earlier sitting.
			if judgement.IsFactual && len(biases) > 0 {
				return fmt.Errorf("%w: thought %d carries %d", ErrThoughtFactualWithBias, thoughtID, len(biases))
			}
			if err := tx.Model(&thought).Association("Biases").Replace(biases); err != nil {
				return fmt.Errorf("failed to attach the cognitive biases: %w", err)
			}
		} else if judgement.IsFactual {
			count := tx.Model(&thought).Association("Biases").Count()
			if count > 0 {
				return fmt.Errorf("%w: thought %d carries %d", ErrThoughtFactualWithBias, thoughtID, count)
			}
		}

		if judgement.IsFactual != thought.IsFactual {
			if err := tx.Model(&thought).Update("is_factual", judgement.IsFactual).Error; err != nil {
				return fmt.Errorf("failed to record whether the thought is factual: %w", err)
			}
		}
	}

	return nil
}

// DeleteThoughtRecord removes a record along with its thoughts and feelings.
// The children are soft deleted explicitly because GORM does not cascade a
// soft delete to associations.
func DeleteThoughtRecord(db *gorm.DB, userID uint, id uint) error {
	return db.Transaction(func(tx *gorm.DB) error {
		var record ThoughtRecord
		if err := findThoughtRecord(tx, userID, id, &record); err != nil {
			return err
		}

		if err := tx.Where("thought_record_id = ?", id).Where("user_id = ?", userID).Delete(&NegativeThought{}).Error; err != nil {
			return fmt.Errorf("failed to delete the thoughts: %w", err)
		}
		if err := tx.Where("thought_record_id = ?", id).Where("user_id = ?", userID).Delete(&Feeling{}).Error; err != nil {
			return fmt.Errorf("failed to delete the feelings: %w", err)
		}
		if err := tx.Delete(&record).Error; err != nil {
			return fmt.Errorf("failed to delete the thought record: %w", err)
		}

		return nil
	})
}

// findThoughtRecord loads a record by identifier without its associations,
// translating a missing row into ErrThoughtRecordNotFound. The query is scoped
// to the given user so cross-user access is reported as not found rather than
// leaking existence.
func findThoughtRecord(tx *gorm.DB, userID uint, id uint, record *ThoughtRecord) error {
	err := tx.Where("user_id = ?", userID).First(record, id).Error
	if errors.Is(err, gorm.ErrRecordNotFound) {
		return fmt.Errorf("%w: %d", ErrThoughtRecordNotFound, id)
	}
	if err != nil {
		return fmt.Errorf("failed to query the thought record: %w", err)
	}

	return nil
}

// loadThoughtRecord loads a record together with its thoughts, the biases on
// each thought, and its feelings.
func loadThoughtRecord(tx *gorm.DB, userID uint, id uint, record *ThoughtRecord) error {
	err := tx.
		Preload("Thoughts").
		Preload("Thoughts.Biases").
		Preload("Feelings").
		Where("user_id = ?", userID).
		First(record, id).Error
	if errors.Is(err, gorm.ErrRecordNotFound) {
		return fmt.Errorf("%w: %d", ErrThoughtRecordNotFound, id)
	}
	if err != nil {
		return fmt.Errorf("failed to query the thought record: %w", err)
	}

	return nil
}
