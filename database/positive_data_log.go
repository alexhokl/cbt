package database

import (
	"errors"
	"fmt"
	"strings"
	"time"

	"gorm.io/gorm"
)

var (
	// ErrPositiveDataLogNotFound is returned when a positive data log does not
	// exist.
	ErrPositiveDataLogNotFound = errors.New("positive data log not found")
	// ErrBeliefEmpty is returned when the self-critical belief of a log is
	// blank. It is the one column a log cannot do without.
	ErrBeliefEmpty = errors.New("belief must not be empty")
	// ErrDataLogEvidenceNotFound is returned when a row of evidence does not
	// exist.
	ErrDataLogEvidenceNotFound = errors.New("evidence not found")
	// ErrDataLogEvidenceEmpty is returned when a row of evidence is blank.
	ErrDataLogEvidenceEmpty = errors.New("evidence must not be empty")
	// ErrBeliefRatingEmpty is returned when a rating rates neither belief.
	ErrBeliefRatingEmpty = errors.New("a belief rating must rate at least one of the beliefs")
	// ErrBeliefRatingRange is returned when a belief rating is outside 0-100.
	ErrBeliefRatingRange = errors.New("a belief rating must be between 0 and 100")
)

// PositiveDataLogFilter narrows a listing of positive data logs.
type PositiveDataLogFilter struct {
	// Search matches free text across both beliefs and every row of evidence,
	// case insensitively.
	Search string
}

// DataLogEvidenceInput is a row of evidence as supplied by the caller.
type DataLogEvidenceInput struct {
	Body    string
	NotedAt *time.Time
}

// BeliefRatingInput rates the beliefs of a log. A nil percentage leaves that
// belief unrated this time; at least one must be given.
type BeliefRatingInput struct {
	BeliefPercent      *int
	AlternativePercent *int
}

// CreatePositiveDataLogInput is a new log as supplied by the caller. Only
// Belief is required. Rating is stored as the first rating when it rates
// either belief.
type CreatePositiveDataLogInput struct {
	Belief            string
	AlternativeBelief string
	Rating            BeliefRatingInput
	Evidence          []DataLogEvidenceInput
}

// UpdatePositiveDataLogInput carries the beliefs to reword on an existing log.
// A nil field is left as it is. Ratings are not changed here: a new rating is
// appended with RateBeliefs, so the history is never rewritten.
type UpdatePositiveDataLogInput struct {
	Belief            *string
	AlternativeBelief *string
}

// CreatePositiveDataLog creates a log together with its first rating and any
// evidence supplied up front.
func CreatePositiveDataLog(db *gorm.DB, userID uint, input CreatePositiveDataLogInput) (*PositiveDataLog, error) {
	belief := strings.TrimSpace(input.Belief)
	if belief == "" {
		return nil, ErrBeliefEmpty
	}

	var log PositiveDataLog
	err := db.Transaction(func(tx *gorm.DB) error {
		log = PositiveDataLog{
			Belief:            belief,
			AlternativeBelief: strings.TrimSpace(input.AlternativeBelief),
			UserID:            userID,
		}
		if err := tx.Create(&log).Error; err != nil {
			return fmt.Errorf("failed to create the positive data log: %w", err)
		}

		if input.Rating.BeliefPercent != nil || input.Rating.AlternativePercent != nil {
			if err := createBeliefRating(tx, userID, log.ID, input.Rating); err != nil {
				return err
			}
		}

		for _, evidence := range input.Evidence {
			if err := createDataLogEvidence(tx, userID, log.ID, evidence); err != nil {
				return err
			}
		}

		return loadPositiveDataLog(tx, userID, log.ID, &log)
	})
	if err != nil {
		return nil, err
	}

	return &log, nil
}

// ListPositiveDataLogs returns the user's logs, the most recently added to
// first. Each log is returned with its evidence and ratings.
func ListPositiveDataLogs(db *gorm.DB, userID uint, filter PositiveDataLogFilter) ([]PositiveDataLog, error) {
	query := preloadPositiveDataLog(db).Where("user_id = ?", userID)

	if search := strings.TrimSpace(filter.Search); search != "" {
		pattern := "%" + strings.ToLower(search) + "%"
		query = query.Where(
			db.Where("LOWER(belief) LIKE ?", pattern).
				Or("LOWER(alternative_belief) LIKE ?", pattern).
				Or("EXISTS (SELECT 1 FROM positive_data_log_evidences WHERE positive_data_log_evidences.positive_data_log_id = positive_data_logs.id AND positive_data_log_evidences.deleted_at IS NULL AND LOWER(positive_data_log_evidences.body) LIKE ?)", pattern),
		)
	}

	var logs []PositiveDataLog
	if err := query.Order("updated_at DESC, id DESC").Find(&logs).Error; err != nil {
		return nil, fmt.Errorf("failed to list the positive data logs: %w", err)
	}

	return logs, nil
}

// GetPositiveDataLog returns a single log with its evidence and ratings.
func GetPositiveDataLog(db *gorm.DB, userID uint, id uint) (*PositiveDataLog, error) {
	var log PositiveDataLog
	if err := loadPositiveDataLog(db, userID, id, &log); err != nil {
		return nil, err
	}

	return &log, nil
}

// UpdatePositiveDataLog rewords the beliefs of a log. Fields left nil keep
// their current value.
func UpdatePositiveDataLog(db *gorm.DB, userID uint, id uint, input UpdatePositiveDataLogInput) (*PositiveDataLog, error) {
	var log PositiveDataLog
	err := db.Transaction(func(tx *gorm.DB) error {
		if err := findPositiveDataLog(tx, userID, id, &log); err != nil {
			return err
		}

		updates := map[string]any{}
		if input.Belief != nil {
			belief := strings.TrimSpace(*input.Belief)
			if belief == "" {
				return ErrBeliefEmpty
			}
			updates["belief"] = belief
		}
		if input.AlternativeBelief != nil {
			updates["alternative_belief"] = strings.TrimSpace(*input.AlternativeBelief)
		}

		if len(updates) > 0 {
			if err := tx.Model(&log).Updates(updates).Error; err != nil {
				return fmt.Errorf("failed to update the positive data log: %w", err)
			}
		}

		return loadPositiveDataLog(tx, userID, id, &log)
	})
	if err != nil {
		return nil, err
	}

	return &log, nil
}

// AddDataLogEvidence appends a row of evidence to a log.
func AddDataLogEvidence(db *gorm.DB, userID uint, logID uint, input DataLogEvidenceInput) (*PositiveDataLog, error) {
	var log PositiveDataLog
	err := db.Transaction(func(tx *gorm.DB) error {
		if err := findPositiveDataLog(tx, userID, logID, &log); err != nil {
			return err
		}
		if err := createDataLogEvidence(tx, userID, logID, input); err != nil {
			return err
		}
		if err := touchPositiveDataLog(tx, &log); err != nil {
			return err
		}

		return loadPositiveDataLog(tx, userID, logID, &log)
	})
	if err != nil {
		return nil, err
	}

	return &log, nil
}

// DeleteDataLogEvidence removes a row of evidence and returns the log it was
// on.
func DeleteDataLogEvidence(db *gorm.DB, userID uint, id uint) (*PositiveDataLog, error) {
	var log PositiveDataLog
	err := db.Transaction(func(tx *gorm.DB) error {
		var evidence PositiveDataLogEvidence
		err := tx.Where("user_id = ?", userID).First(&evidence, id).Error
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return fmt.Errorf("%w: %d", ErrDataLogEvidenceNotFound, id)
		}
		if err != nil {
			return fmt.Errorf("failed to query the evidence: %w", err)
		}

		if err := tx.Delete(&evidence).Error; err != nil {
			return fmt.Errorf("failed to delete the evidence: %w", err)
		}
		if err := findPositiveDataLog(tx, userID, evidence.PositiveDataLogID, &log); err != nil {
			return err
		}
		if err := touchPositiveDataLog(tx, &log); err != nil {
			return err
		}

		return loadPositiveDataLog(tx, userID, evidence.PositiveDataLogID, &log)
	})
	if err != nil {
		return nil, err
	}

	return &log, nil
}

// RateBeliefs appends a rating of both beliefs to a log, stamped now. Earlier
// ratings are kept, so coming back to a log adds to its history rather than
// replacing it.
func RateBeliefs(db *gorm.DB, userID uint, logID uint, input BeliefRatingInput) (*PositiveDataLog, error) {
	var log PositiveDataLog
	err := db.Transaction(func(tx *gorm.DB) error {
		if err := findPositiveDataLog(tx, userID, logID, &log); err != nil {
			return err
		}
		if err := createBeliefRating(tx, userID, logID, input); err != nil {
			return err
		}
		if err := touchPositiveDataLog(tx, &log); err != nil {
			return err
		}

		return loadPositiveDataLog(tx, userID, logID, &log)
	})
	if err != nil {
		return nil, err
	}

	return &log, nil
}

// DeletePositiveDataLog removes a log along with its evidence and ratings.
func DeletePositiveDataLog(db *gorm.DB, userID uint, id uint) error {
	return db.Transaction(func(tx *gorm.DB) error {
		var log PositiveDataLog
		if err := findPositiveDataLog(tx, userID, id, &log); err != nil {
			return err
		}

		if err := tx.Where("positive_data_log_id = ?", id).Where("user_id = ?", userID).Delete(&PositiveDataLogEvidence{}).Error; err != nil {
			return fmt.Errorf("failed to delete the evidence: %w", err)
		}
		if err := tx.Where("positive_data_log_id = ?", id).Where("user_id = ?", userID).Delete(&BeliefRating{}).Error; err != nil {
			return fmt.Errorf("failed to delete the belief ratings: %w", err)
		}
		if err := tx.Delete(&log).Error; err != nil {
			return fmt.Errorf("failed to delete the positive data log: %w", err)
		}

		return nil
	})
}

// createDataLogEvidence validates and inserts a single row of evidence.
func createDataLogEvidence(tx *gorm.DB, userID uint, logID uint, input DataLogEvidenceInput) error {
	body := strings.TrimSpace(input.Body)
	if body == "" {
		return ErrDataLogEvidenceEmpty
	}

	evidence := PositiveDataLogEvidence{
		Body:              body,
		NotedAt:           input.NotedAt,
		PositiveDataLogID: logID,
		UserID:            userID,
	}
	if err := tx.Create(&evidence).Error; err != nil {
		return fmt.Errorf("failed to create the evidence: %w", err)
	}

	return nil
}

// createBeliefRating validates and inserts a single rating, stamped now.
func createBeliefRating(tx *gorm.DB, userID uint, logID uint, input BeliefRatingInput) error {
	if input.BeliefPercent == nil && input.AlternativePercent == nil {
		return ErrBeliefRatingEmpty
	}
	for _, percent := range []*int{input.BeliefPercent, input.AlternativePercent} {
		if percent != nil && (*percent < 0 || *percent > 100) {
			return ErrBeliefRatingRange
		}
	}

	rating := BeliefRating{
		RatedAt:            time.Now(),
		BeliefPercent:      input.BeliefPercent,
		AlternativePercent: input.AlternativePercent,
		PositiveDataLogID:  logID,
		UserID:             userID,
	}
	if err := tx.Create(&rating).Error; err != nil {
		return fmt.Errorf("failed to create the belief rating: %w", err)
	}

	return nil
}

// touchPositiveDataLog moves a log to the top of the listing when a row is
// added to or removed from it, since a log is returned to rather than
// written once.
func touchPositiveDataLog(tx *gorm.DB, log *PositiveDataLog) error {
	if err := tx.Model(log).Update("updated_at", time.Now()).Error; err != nil {
		return fmt.Errorf("failed to update the positive data log: %w", err)
	}

	return nil
}

// preloadPositiveDataLog loads the evidence and the ratings of a log, each
// oldest first.
func preloadPositiveDataLog(tx *gorm.DB) *gorm.DB {
	return tx.
		Preload("Evidence", func(db *gorm.DB) *gorm.DB { return db.Order("id ASC") }).
		Preload("Ratings", func(db *gorm.DB) *gorm.DB { return db.Order("rated_at ASC, id ASC") })
}

// findPositiveDataLog loads a log by identifier without its associations,
// translating a missing row into ErrPositiveDataLogNotFound. The query is
// scoped to the given user so cross-user access is reported as not found
// rather than leaking existence.
func findPositiveDataLog(tx *gorm.DB, userID uint, id uint, log *PositiveDataLog) error {
	err := tx.Where("user_id = ?", userID).First(log, id).Error
	if errors.Is(err, gorm.ErrRecordNotFound) {
		return fmt.Errorf("%w: %d", ErrPositiveDataLogNotFound, id)
	}
	if err != nil {
		return fmt.Errorf("failed to query the positive data log: %w", err)
	}

	return nil
}

// loadPositiveDataLog loads a log together with its evidence and ratings.
func loadPositiveDataLog(tx *gorm.DB, userID uint, id uint, log *PositiveDataLog) error {
	err := preloadPositiveDataLog(tx).
		Where("user_id = ?", userID).
		First(log, id).Error
	if errors.Is(err, gorm.ErrRecordNotFound) {
		return fmt.Errorf("%w: %d", ErrPositiveDataLogNotFound, id)
	}
	if err != nil {
		return fmt.Errorf("failed to query the positive data log: %w", err)
	}

	return nil
}
