package database

import (
	"errors"
	"fmt"
	"strings"

	"gorm.io/gorm"
)

var (
	// ErrFormulationNotFound is returned when a formulation does not exist.
	ErrFormulationNotFound = errors.New("formulation not found")
	// ErrFormulationEmpty is returned when every column of a formulation
	// would be blank.
	ErrFormulationEmpty = errors.New("a formulation must not be empty")
)

// FormulationFilter narrows a listing of formulations.
type FormulationFilter struct {
	// Search matches free text across every column, case insensitively.
	Search string
}

// FormulationInput is a new formulation as supplied by the caller. Any column
// may be left blank, but not all of them.
type FormulationInput struct {
	EarlyExperiences string
	Beliefs          string
	Assumptions      string
	RulesForLiving   string
	Events           string
	Thoughts         string
	Behaviours       string
}

// UpdateFormulationInput carries the columns to change on an existing
// formulation. A nil field is left as it is.
type UpdateFormulationInput struct {
	EarlyExperiences *string
	Beliefs          *string
	Assumptions      *string
	RulesForLiving   *string
	Events           *string
	Thoughts         *string
	Behaviours       *string
}

// formulationColumns lists the columns of a formulation in the order the
// exercise is written, so that create, update and search treat them alike.
var formulationColumns = []string{
	"early_experiences",
	"beliefs",
	"assumptions",
	"rules_for_living",
	"events",
	"thoughts",
	"behaviours",
}

// values returns the input in the order of formulationColumns.
func (input FormulationInput) values() []string {
	return []string{
		input.EarlyExperiences,
		input.Beliefs,
		input.Assumptions,
		input.RulesForLiving,
		input.Events,
		input.Thoughts,
		input.Behaviours,
	}
}

// values returns the input in the order of formulationColumns.
func (input UpdateFormulationInput) values() []*string {
	return []*string{
		input.EarlyExperiences,
		input.Beliefs,
		input.Assumptions,
		input.RulesForLiving,
		input.Events,
		input.Thoughts,
		input.Behaviours,
	}
}

// values returns the stored columns in the order of formulationColumns.
func (formulation Formulation) values() []string {
	return FormulationInput{
		EarlyExperiences: formulation.EarlyExperiences,
		Beliefs:          formulation.Beliefs,
		Assumptions:      formulation.Assumptions,
		RulesForLiving:   formulation.RulesForLiving,
		Events:           formulation.Events,
		Thoughts:         formulation.Thoughts,
		Behaviours:       formulation.Behaviours,
	}.values()
}

// CreateFormulation creates a formulation from whichever columns are given.
func CreateFormulation(db *gorm.DB, userID uint, input FormulationInput) (*Formulation, error) {
	trimmed := make([]string, len(formulationColumns))
	for index, value := range input.values() {
		trimmed[index] = strings.TrimSpace(value)
	}
	if allBlank(trimmed) {
		return nil, ErrFormulationEmpty
	}

	formulation := Formulation{
		EarlyExperiences: trimmed[0],
		Beliefs:          trimmed[1],
		Assumptions:      trimmed[2],
		RulesForLiving:   trimmed[3],
		Events:           trimmed[4],
		Thoughts:         trimmed[5],
		Behaviours:       trimmed[6],
		UserID:           userID,
	}
	if err := db.Create(&formulation).Error; err != nil {
		return nil, fmt.Errorf("failed to create the formulation: %w", err)
	}

	return &formulation, nil
}

// ListFormulations returns the user's formulations, the most recently changed
// first.
func ListFormulations(db *gorm.DB, userID uint, filter FormulationFilter) ([]Formulation, error) {
	query := db.Where("user_id = ?", userID)

	if search := strings.TrimSpace(filter.Search); search != "" {
		pattern := "%" + strings.ToLower(search) + "%"
		matches := db.Where("LOWER("+formulationColumns[0]+") LIKE ?", pattern)
		for _, column := range formulationColumns[1:] {
			matches = matches.Or("LOWER("+column+") LIKE ?", pattern)
		}
		query = query.Where(matches)
	}

	var formulations []Formulation
	if err := query.Order("updated_at DESC, id DESC").Find(&formulations).Error; err != nil {
		return nil, fmt.Errorf("failed to list the formulations: %w", err)
	}

	return formulations, nil
}

// GetFormulation returns a single formulation.
func GetFormulation(db *gorm.DB, userID uint, id uint) (*Formulation, error) {
	var formulation Formulation
	if err := findFormulation(db, userID, id, &formulation); err != nil {
		return nil, err
	}

	return &formulation, nil
}

// UpdateFormulation changes the columns of a formulation. Fields left nil keep
// their current value. An update that would leave every column blank is
// rejected.
func UpdateFormulation(db *gorm.DB, userID uint, id uint, input UpdateFormulationInput) (*Formulation, error) {
	var formulation Formulation
	err := db.Transaction(func(tx *gorm.DB) error {
		if err := findFormulation(tx, userID, id, &formulation); err != nil {
			return err
		}

		merged := formulation.values()
		updates := map[string]any{}
		for index, value := range input.values() {
			if value == nil {
				continue
			}
			merged[index] = strings.TrimSpace(*value)
			updates[formulationColumns[index]] = merged[index]
		}
		if allBlank(merged) {
			return ErrFormulationEmpty
		}

		if len(updates) > 0 {
			if err := tx.Model(&formulation).Updates(updates).Error; err != nil {
				return fmt.Errorf("failed to update the formulation: %w", err)
			}
		}

		return findFormulation(tx, userID, id, &formulation)
	})
	if err != nil {
		return nil, err
	}

	return &formulation, nil
}

// DeleteFormulation removes a formulation.
func DeleteFormulation(db *gorm.DB, userID uint, id uint) error {
	var formulation Formulation
	if err := findFormulation(db, userID, id, &formulation); err != nil {
		return err
	}
	if err := db.Delete(&formulation).Error; err != nil {
		return fmt.Errorf("failed to delete the formulation: %w", err)
	}

	return nil
}

// findFormulation loads a formulation by identifier, translating a missing
// row into ErrFormulationNotFound. The query is scoped to the given user so
// cross-user access is reported as not found rather than leaking existence.
func findFormulation(tx *gorm.DB, userID uint, id uint, formulation *Formulation) error {
	err := tx.Where("user_id = ?", userID).First(formulation, id).Error
	if errors.Is(err, gorm.ErrRecordNotFound) {
		return fmt.Errorf("%w: %d", ErrFormulationNotFound, id)
	}
	if err != nil {
		return fmt.Errorf("failed to query the formulation: %w", err)
	}

	return nil
}

// allBlank reports whether every value is empty once trimmed.
func allBlank(values []string) bool {
	for _, value := range values {
		if strings.TrimSpace(value) != "" {
			return false
		}
	}

	return true
}
