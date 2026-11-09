package database

import (
	"errors"
	"fmt"
	"strings"
	"time"

	"gorm.io/gorm"
)

var (
	// ErrBehaviouralExperimentNotFound is returned when a behavioural
	// experiment does not exist.
	ErrBehaviouralExperimentNotFound = errors.New("behavioural experiment not found")
	// ErrPlanEmpty is returned when the plan of an experiment is blank. It is
	// the one column an experiment cannot do without.
	ErrPlanEmpty = errors.New("plan must not be empty")
)

// BehaviouralExperimentFilter narrows a listing of behavioural experiments.
type BehaviouralExperimentFilter struct {
	// Completed selects experiments by whether their outcome has been
	// recorded. Nil returns both. False is the queue of experiments still to
	// be carried out.
	Completed *bool
	// Since restricts the listing to experiments carried out on or after this
	// instant, falling back to the creation time where the user did not say.
	Since *time.Time
	// Search matches free text across every column of the experiment, case
	// insensitively.
	Search string
}

// CreateBehaviouralExperimentInput is a new experiment as supplied by the
// caller. Only Plan is required. Feelings are the ones predicted, rated before
// the experiment.
type CreateBehaviouralExperimentInput struct {
	Plan       string
	OccurredAt *time.Time
	Prediction string
	Feelings   []FeelingInput
}

// UpdateBehaviouralExperimentInput carries the columns to change on an
// existing experiment. A nil field is left as it is. Changing the outcome
// columns here corrects them without stamping the experiment complete.
type UpdateBehaviouralExperimentInput struct {
	Plan            *string
	OccurredAt      *time.Time
	ClearOccurredAt bool
	Prediction      *string
	Outcome         *string
	Learned         *string
	BuildOn         *string
}

// CompleteBehaviouralExperimentInput carries the second sitting of an
// experiment: what actually happened, what was learned, how to build on it,
// and how it actually felt.
type CompleteBehaviouralExperimentInput struct {
	// Outcome answers "what actually happened?".
	Outcome string
	// Learned answers "what have you learned from this?".
	Learned string
	// BuildOn answers "how can you build on this?".
	BuildOn string
	// FeelingIntensitiesAfter maps the identifier of a predicted feeling to
	// how strongly it was actually felt.
	FeelingIntensitiesAfter map[uint]int
	// NewFeelings are feelings that were felt but not predicted. Their rating
	// is stored as IntensityAfter, since there was no prediction to compare
	// it with.
	NewFeelings []FeelingInput
}

// CreateBehaviouralExperiment creates an experiment together with any
// predicted feelings supplied up front.
func CreateBehaviouralExperiment(db *gorm.DB, userID uint, input CreateBehaviouralExperimentInput) (*BehaviouralExperiment, error) {
	plan := strings.TrimSpace(input.Plan)
	if plan == "" {
		return nil, ErrPlanEmpty
	}

	var experiment BehaviouralExperiment
	err := db.Transaction(func(tx *gorm.DB) error {
		experiment = BehaviouralExperiment{
			Plan:       plan,
			OccurredAt: input.OccurredAt,
			Prediction: strings.TrimSpace(input.Prediction),
			UserID:     userID,
		}
		if err := tx.Create(&experiment).Error; err != nil {
			return fmt.Errorf("failed to create the behavioural experiment: %w", err)
		}

		if len(input.Feelings) > 0 {
			feelings, err := buildFeelings(input.Feelings, userID, feelingParent{BehaviouralExperimentID: &experiment.ID})
			if err != nil {
				return err
			}
			if err := tx.Create(&feelings).Error; err != nil {
				return fmt.Errorf("failed to create the feelings: %w", err)
			}
		}

		return loadBehaviouralExperiment(tx, userID, experiment.ID, &experiment)
	})
	if err != nil {
		return nil, err
	}

	return &experiment, nil
}

// ListBehaviouralExperiments returns the user's experiments, most recent
// first.
func ListBehaviouralExperiments(db *gorm.DB, userID uint, filter BehaviouralExperimentFilter) ([]BehaviouralExperiment, error) {
	query := db.Preload("Feelings").Where("user_id = ?", userID)

	if filter.Completed != nil {
		if *filter.Completed {
			query = query.Where("completed_at IS NOT NULL")
		} else {
			query = query.Where("completed_at IS NULL")
		}
	}
	if filter.Since != nil {
		query = query.Where("COALESCE(occurred_at, created_at) >= ?", *filter.Since)
	}
	if search := strings.TrimSpace(filter.Search); search != "" {
		pattern := "%" + strings.ToLower(search) + "%"
		query = query.Where(
			db.Where("LOWER(plan) LIKE ?", pattern).
				Or("LOWER(prediction) LIKE ?", pattern).
				Or("LOWER(outcome) LIKE ?", pattern).
				Or("LOWER(learned) LIKE ?", pattern).
				Or("LOWER(build_on) LIKE ?", pattern),
		)
	}

	var experiments []BehaviouralExperiment
	if err := query.Order("COALESCE(occurred_at, created_at) DESC, id DESC").Find(&experiments).Error; err != nil {
		return nil, fmt.Errorf("failed to list the behavioural experiments: %w", err)
	}

	return experiments, nil
}

// GetBehaviouralExperiment returns a single experiment with its feelings.
func GetBehaviouralExperiment(db *gorm.DB, userID uint, id uint) (*BehaviouralExperiment, error) {
	var experiment BehaviouralExperiment
	if err := loadBehaviouralExperiment(db, userID, id, &experiment); err != nil {
		return nil, err
	}

	return &experiment, nil
}

// UpdateBehaviouralExperiment changes the free text columns of an experiment.
// Fields left nil keep their current value.
func UpdateBehaviouralExperiment(db *gorm.DB, userID uint, id uint, input UpdateBehaviouralExperimentInput) (*BehaviouralExperiment, error) {
	var experiment BehaviouralExperiment
	err := db.Transaction(func(tx *gorm.DB) error {
		if err := findBehaviouralExperiment(tx, userID, id, &experiment); err != nil {
			return err
		}

		updates := map[string]any{}
		if input.Plan != nil {
			plan := strings.TrimSpace(*input.Plan)
			if plan == "" {
				return ErrPlanEmpty
			}
			updates["plan"] = plan
		}
		if input.ClearOccurredAt {
			updates["occurred_at"] = nil
		} else if input.OccurredAt != nil {
			updates["occurred_at"] = *input.OccurredAt
		}
		prose := []struct {
			column string
			value  *string
		}{
			{"prediction", input.Prediction},
			{"outcome", input.Outcome},
			{"learned", input.Learned},
			{"build_on", input.BuildOn},
		}
		for _, field := range prose {
			if field.value != nil {
				updates[field.column] = strings.TrimSpace(*field.value)
			}
		}

		if len(updates) > 0 {
			if err := tx.Model(&experiment).Updates(updates).Error; err != nil {
				return fmt.Errorf("failed to update the behavioural experiment: %w", err)
			}
		}

		return loadBehaviouralExperiment(tx, userID, id, &experiment)
	})
	if err != nil {
		return nil, err
	}

	return &experiment, nil
}

// CompleteBehaviouralExperiment records the second sitting of an experiment:
// what actually happened, what was learned, how to build on it, and how
// strongly each feeling was actually felt. CompletedAt is stamped so the
// experiment leaves the queue of those still to be carried out.
//
// Completing an experiment again is allowed and re-stamps it, as with
// challenging a thought record. Blank prose leaves the stored column alone, so
// a second sitting can add to the first without repeating it.
func CompleteBehaviouralExperiment(db *gorm.DB, userID uint, id uint, input CompleteBehaviouralExperimentInput) (*BehaviouralExperiment, error) {
	var experiment BehaviouralExperiment
	err := db.Transaction(func(tx *gorm.DB) error {
		if err := findBehaviouralExperiment(tx, userID, id, &experiment); err != nil {
			return err
		}

		updates := map[string]any{"completed_at": time.Now()}
		prose := []struct {
			column string
			value  string
		}{
			{"outcome", input.Outcome},
			{"learned", input.Learned},
			{"build_on", input.BuildOn},
		}
		for _, field := range prose {
			if value := strings.TrimSpace(field.value); value != "" {
				updates[field.column] = value
			}
		}
		if err := tx.Model(&experiment).Updates(updates).Error; err != nil {
			return fmt.Errorf("failed to complete the behavioural experiment: %w", err)
		}

		parent := feelingParent{BehaviouralExperimentID: &id}
		if err := applyFeelingRerating(tx, userID, parent, input.FeelingIntensitiesAfter); err != nil {
			return err
		}

		if len(input.NewFeelings) > 0 {
			feelings, err := buildFeelings(input.NewFeelings, userID, parent)
			if err != nil {
				return err
			}
			// A feeling that was not predicted has no rating from before the
			// experiment; its rating is what was actually felt.
			for index := range feelings {
				feelings[index].IntensityAfter = feelings[index].IntensityBefore
				feelings[index].IntensityBefore = nil
			}
			if err := tx.Create(&feelings).Error; err != nil {
				return fmt.Errorf("failed to create the feelings: %w", err)
			}
		}

		return loadBehaviouralExperiment(tx, userID, id, &experiment)
	})
	if err != nil {
		return nil, err
	}

	return &experiment, nil
}

// DeleteBehaviouralExperiment removes an experiment along with its feelings.
func DeleteBehaviouralExperiment(db *gorm.DB, userID uint, id uint) error {
	return db.Transaction(func(tx *gorm.DB) error {
		var experiment BehaviouralExperiment
		if err := findBehaviouralExperiment(tx, userID, id, &experiment); err != nil {
			return err
		}

		if err := tx.Where("behavioural_experiment_id = ?", id).Where("user_id = ?", userID).Delete(&Feeling{}).Error; err != nil {
			return fmt.Errorf("failed to delete the feelings: %w", err)
		}
		if err := tx.Delete(&experiment).Error; err != nil {
			return fmt.Errorf("failed to delete the behavioural experiment: %w", err)
		}

		return nil
	})
}

// findBehaviouralExperiment loads an experiment by identifier without its
// associations, translating a missing row into
// ErrBehaviouralExperimentNotFound. The query is scoped to the given user so
// cross-user access is reported as not found rather than leaking existence.
func findBehaviouralExperiment(tx *gorm.DB, userID uint, id uint, experiment *BehaviouralExperiment) error {
	err := tx.Where("user_id = ?", userID).First(experiment, id).Error
	if errors.Is(err, gorm.ErrRecordNotFound) {
		return fmt.Errorf("%w: %d", ErrBehaviouralExperimentNotFound, id)
	}
	if err != nil {
		return fmt.Errorf("failed to query the behavioural experiment: %w", err)
	}

	return nil
}

// loadBehaviouralExperiment loads an experiment together with its feelings.
func loadBehaviouralExperiment(tx *gorm.DB, userID uint, id uint, experiment *BehaviouralExperiment) error {
	err := tx.
		Preload("Feelings").
		Where("user_id = ?", userID).
		First(experiment, id).Error
	if errors.Is(err, gorm.ErrRecordNotFound) {
		return fmt.Errorf("%w: %d", ErrBehaviouralExperimentNotFound, id)
	}
	if err != nil {
		return fmt.Errorf("failed to query the behavioural experiment: %w", err)
	}

	return nil
}
